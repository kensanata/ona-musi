# Ona Musi is a wiki engine
# Copyright (C) 2020  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

=head1 OnaMusi::Storage::Files

Ona Musi is a wiki. By default, it stores its data in files. The following
properties can be set:

C<pages> is the directory where page files are stored.
The key C<pages_dir> in the config file can be used to change it.
The environment variable C<ONA_MUSI_PAGES_DIR> can be used to override it.

C<html> is the directory where cached HTML is stored.
The key C<cache_dir> in the config file can be used to change it.
The environment variable C<ONA_MUSI_HTML_DIR> can be used to override it.

C<keep> is the directory where kept pages are stored.
These are the older versions of page files.
The key C<keep_dir> in the config file can be used to change it.
The environment variable C<ONA_MUSI_KEEP_DIR> can be used to override it.

C<changes.log> is the file where changes are logged.
The key C<log_file> in the config file can be used to change it.
The environment variable C<ONA_MUSI_LOG_FILE> can be used to override it.

=over

=cut

package OnaMusi::Storage::Files;
use Mojo::Base -base;
use Mojo::IOLoop;
use Modern::Perl '2018';
use File::Slurper qw(read_text write_text);
use File::ReadBackwards;
use OnaMusi::Change;

has 'log';
has 'config';
has 'pages_dir' => sub { $ENV{ONA_MUSI_PAGES_DIR} or shift->config->{pages_dir} or "pages" };
has 'cache_dir' => sub { $ENV{ONA_MUSI_HTML_DIR} or shift->config->{cache_dir} or "html" };
has 'keep_dir' => sub { $ENV{ONA_MUSI_KEEP_DIR} or shift->config->{keep_dir} or "keep" };
has 'log_file' => sub { $ENV{ONA_MUSI_LOG_FILE} or shift->config->{log_file} or "changes.log" };
has 'fs' => "\x1e"; # ASCII field separator

sub with_locked_file {
  my ($filename, $code) = @_;
  my $lock = "$filename.lock";
  # try creating a lock and run the code
  if (mkdir $lock) {
    $code->();
    rmdir($lock);
  } else {
    # if that didn't work, try again every second
    my ($id, $id2);
    $id = Mojo::IOLoop->recurring(
      1 => sub {
	if (mkdir $lock) {
	  $code->();
	  rmdir $lock;
	  Mojo::IOLoop->remove($id);
	  Mojo::IOLoop->remove($id2);
	}
      });
    # also make sure there's a lock removal just in case
    $id2 = Mojo::IOLoop->timer(5 => sub { unlink($lock) });
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
  };
}

=item C<pages>

Get a reference to a list of all the page names.

=cut

sub pages {
  my ($self) = @_;
  my @ids;
  if (opendir my $d, $self->pages_dir) {
    # skip dot files and Emacs backup files, without extensions
    @ids = sort
	map { s/\.[a-z]+$//; $_ }
    	grep { $_ !~ /^\./ and $_ !~ /~$/ } readdir $d;
  }
  return \@ids;
}

sub page_filename {
  my ($self, $id) = @_;
  my $dir = $self->pages_dir;
  $id =~ s/^\.+//; # strip leading dots
  return "$dir/$id" if -r "$dir/$id"; # return exact matches
  for (glob "$dir/$id.*") { # find matches with an extension
    return $_ if /$dir\/$id\.[a-z]+$/ and -f;
  }
  my $original_id = $id; # make a copy for later
  if ($id =~ s/\.[a-z]+$//) { # perhaps if we strip the extension
    return "$dir/$id" if -r "$dir/$id"; # return exact matches
    for (glob "$dir/$id.*") { # find matches with an extension
      return $_ if /$dir\/$id\.[a-z]+$/ and -f;
    }
    return "$dir/$original_id"; # a new file with an extension
  }
  return "$dir/$id.md"; # if it doesn't have an extension, make it markdown
}

sub keep_name {
  my ($self, $id) = @_;
  $id =~ s/^\.+//; # strip leading dots
  $id =~ s/\.[a-z]+$//; # strip the extension
  return $self->keep_dir . "/$id";
}

sub cache_filename {
  my ($self, $id) = @_;
  $id =~ s/^\.+//; # strip leading dots
  $id =~ s/\.[a-z]+$//; # strip the extension
  return $self->cache_dir . "/$id.html"; # use HTML
}

=item C<read_page>

Get the content of a page.

=cut

sub read_page {
  my ($self, $id) = @_;
  my $filename = $self->page_filename($id);
  return read_text($filename) if -r $filename;
  return ""; # this is shown for new pages
}

=item C<write_page>

Write the content of a page. When writing a page, lock it first. Also write the
change log withing the same lock so that revisions for a page come in the right
order.

=cut

sub write_page {
  my ($self, $id, $text, $change) = @_;
  $self->clear_cache($id);
  my $filename = $self->page_filename($id);
  mkdir $self->pages_dir, 0775;
  with_locked_file($filename, sub {
    $change //= OnaMusi::Change->new(ts => time, id => $id);
    $self->keep_revision($filename, $change);
    write_text($filename, $text);
    $self->write_change($change) if defined $change;
  });
}

sub clear_cache {
  my ($self, $id) = @_;
  my $filename = $self->cache_filename($id);
  unlink $filename;
}

sub keep_revision {
  my ($self, $filename, $change) = @_;
  my $keep_dir = $self->keep_dir;
  my $keep_file = $self->keep_name($change->id);
  my $revision = $change->revision || $self->latest_revision($keep_file);
  $revision++;
  $revision++ while -e "$keep_file.~$revision~";
  $self->log->warn("Merge not implemented: overwriting changes") if $change->revision and $revision - $change->revision > 1;
  if ($revision > 1) {
    write_text("$keep_file.~$revision~", read_text($filename));
  }
  $change->revision($revision);
}

sub latest_revision {
  my ($self, $keep_file) = @_;
  my $rev = 0;
  for (<$keep_file.~*~>) {
    next unless /^$keep_file.~(\d+)~/;
    $rev = $1 if $1 > $rev;
  }
  return $rev;
}

=item C<cached_page>

Get the cached HTML of a page, if available.

=cut

sub cached_page {
  my ($self, $id) = @_;
  my $filename = $self->cache_filename($id);
  my $stale = $self->stale_cache($filename, $self->page_filename($id));
  return read_text($filename) if -r $filename and not $stale;
  return undef;
}

sub stale_cache {
  my ($self, $cache, $page) = @_;
  my $m1 = (stat($cache))[9] if -f $cache; # mtime
  my $m2 = (stat($page))[9] if -f $page;   # mtime
  return $m1 < $m2 if $m1 and $m2;
}

=item C<cached_page>

Write the HTML of a page into the cache.

=cut

sub cache_page {
  my ($self, $id, $html) = @_;
  my $filename = $self->cache_filename($id);
  # needs lock
  mkdir $self->cache_dir, 0775;
  with_locked_file($filename, sub { write_text($filename, $html) });
}

=item C<delete_page>

Deletes the page and its cached copy.

=cut

sub delete_page {
  my ($self, $id) = @_;
  $self->clear_cache($id);
  my $filename = $self->page_filename($id);
  unlink $filename if -f $filename;
}

=item C<write_change>

Write an L<OnaMusi::Change> to the log file.

=cut

sub write_change {
  my ($self, $change) = @_;
  with_locked_file $self->log_file, sub {
    open(my $fh, ">>:encoding(UTF-8)", $self->log_file)
	or die "Cannot append to log file " . $self->log_file . ": $!";
    print $fh join($self->fs,
		   $change->ts,
		   $change->id,
		   $change->revision,
		   $change->minor ? 1 : 0,
		   $change->author || "",
		   $change->code || "",
		   $change->summary || "") . "\n";
    close($fh);
  };
}

=item C<read_changes>

Read a list of L<OnaMusi::Change> items from the log file.
Use L<OnaMusi::Filter> to filter them.

The problem with reading the changes from a log file is that they are in the
wrong order. This is why we need L<File::ReadBackwards>.

=cut

sub read_changes {
  my ($self, $filter) = @_;
  my @changes;
  my %seen;
  my $log = File::ReadBackwards->new($self->log_file) or return ();
  while ($_ = $log->readline) {
    last if not defined;
    chomp;
    my ($ts, $id, $revision, $minor, $author, $code, $summary) = split $self->fs;
    next if $filter->id and $filter->id ne $id;
    next if not $filter->all and $seen{$id};
    next if $filter->minor and not $minor;
    next if $filter->author and $filter->author ne $author;
    $seen{$id} = 1 if not $filter->all; # only fill it when necessary
    my $keep_file = $self->keep_name($id);
    my $change = OnaMusi::Change->new(
      ts => time, id => $id, revision => $revision, minor => $minor,
      author => $author, code => $code, summary => $summary,
      kept => -e "$keep_file.~$revision~");
    unshift(@changes, $change);
    last if $filter->n and @changes > $filter->n;
  }
  return \@changes;
}

=back

=cut

1;

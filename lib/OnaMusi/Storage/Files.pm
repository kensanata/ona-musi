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

Ona Musi is a wiki. By default, it stores its data in files. This class provides
all the functionality for it.

=over

=cut

package OnaMusi::Storage::Files;

use Modern::Perl '2018';
use File::Slurper qw(read_text write_text);

sub new { bless {}, shift }

my $page_dir = "pages";
my $cache_dir = "html";

=item C<page_dir>

Get or set the directory where pages are stored. Defaults to C<pages>.

=cut

sub page_dir {
  my ($self, $val) = @_;
  $page_dir = $val if defined $val;
  return $page_dir;
}

=item C<cache_dir>

Get or set the directory where HTML files are stored. Defaults to C<html>.

=cut

sub cache_dir {
  my ($self, $val) = @_;
  $cache_dir = $val if defined $val;
  return $cache_dir;
}

=item C<pages>

Get a reference to a list of all the page names.

=cut

sub pages {
  my ($self) = @_;
  my @ids;
  if (opendir my $d, $page_dir) {
    @ids = sort
	map { s/\.[a-z]+$//; $_ }
	grep { $_ ne '.' and $_ ne '..' and $_ !~ /~$/ } readdir $d;
  }
  return \@ids;
}

sub page_filename {
  my ($self, $id) = @_;
  return "$page_dir/$id" if -r "$page_dir/$id"; # return exact matches
  for (glob "$page_dir/$id.*") { # find matches with an extension
    return $_ if /$page_dir\/$id\.[a-z]+$/ and -f;
  }
  my $original_id = $id; # make a copy for later
  if ($id =~ s/\.[a-z]+$//) { # perhaps if we strip the extension
    return "$page_dir/$id" if -r "$page_dir/$id"; # return exact matches
    for (glob "$page_dir/$id.*") { # find matches with an extension
      return $_ if /$page_dir\/$id\.[a-z]+$/ and -f;
    }
    return "$page_dir/$original_id"; # a new file with an extension
  }
  return "$page_dir/$id.md"; # if it doesn't have an extension, make it markdown
}

sub cache_filename {
  my ($self, $id) = @_;
  $id =~ s/\.[a-z]+$//; # strip the extension
  return "$cache_dir/$id.html"; # use HTML
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

Write the content of a page.

=cut

sub write_page {
  my ($self, $id, $text) = @_;
  $self->clear_cache($id);
  my $filename = $self->page_filename($id);
  # needs lock
  mkdir $page_dir, 0775;
  write_text($filename, $text);
}

sub stale_cache {
  my ($self, $cache, $page) = @_;
  my $m1 = (stat($cache))[9] if -f $cache; # mtime
  my $m2 = (stat($page))[9] if -f $page;   # mtime
  return $m1 < $m2 if $m1 and $m2;
}

sub clear_cache {
  my ($self, $id) = @_;
  my $filename = $self->cache_filename($id);
  unlink $filename;
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

=item C<cached_page>

Write the HTML of a page into the cache.

=cut

sub cache_page {
  my ($self, $id, $html) = @_;
  my $filename = $self->cache_filename($id);
  # needs lock
  mkdir $cache_dir, 0775;
  write_text($filename, $html);
}

=back

=cut

1;

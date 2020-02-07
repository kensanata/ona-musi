package OnaMusi::Storage::Files;

use Modern::Perl '2018';
use File::Slurper qw(read_text write_text);

sub new { bless {}, shift }

my $page_dir = "pages";
my $cache_dir = "html";

sub page_dir {
  my ($self, $val) = @_;
  $page_dir = $val if defined $val;
  return $page_dir;
}

sub cache_dir {
  my ($self, $val) = @_;
  $cache_dir = $val if defined $val;
  return $cache_dir;
}

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

sub read_page {
  my ($self, $id) = @_;
  my $filename = $self->page_filename($id);
  return read_text($filename) if -r $filename;
  return ""; # this is shown for new pages
}

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

sub cached_page {
  my ($self, $id) = @_;
  my $filename = $self->cache_filename($id);
  my $stale = $self->stale_cache($filename, $self->page_filename($id));
  return read_text($filename) if -r $filename and not $stale;
  return undef;
}

sub cache_page {
  my ($self, $id, $html) = @_;
  my $filename = $self->cache_filename($id);
  # needs lock
  mkdir $cache_dir, 0775;
  write_text($filename, $html);
}

1;

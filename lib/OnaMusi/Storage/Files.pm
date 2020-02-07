package OnaMusi::Storage::Files;

use Modern::Perl '2018';
use File::Slurper qw(read_text write_text);

sub new { bless {}, shift }

our $dir = "pages";

sub dir {
  my ($self, $val) = @_;
  $dir = $val if defined $val;
  return $dir;
}

sub pages {
  my ($self) = @_;
  my @ids;
  if (opendir my $d, $dir) {
    @ids = sort
	map { s/\.[a-z]+$//; $_ }
	grep { $_ ne '.' and $_ ne '..' and $_ !~ /~$/ } readdir $d;
  }
  return \@ids;
}

sub page_filename {
  my ($self, $id) = @_;
  return "$dir/$id" if -r "$dir/$id"; # return exact matches
  for (glob "$dir/$id.*") { # find matches with an extension
    return $_ if /$dir\/$id\.[a-z]+$/ and -f;
  }
  return "$dir/$id" if $id =~ /\.[a-z]+$/; # a new file with an extension
  return "$dir/$id.md"; # if it doesn't have an extension, make it markdown
}

sub read_page {
  my ($self, $id) = @_;
  my $filename = $self->page_filename($id);
  return read_text($filename) if -r $filename;
  return ""; # this is shown for new pages
}

sub write_page {
  my ($self, $id, $text) = @_;
  my $filename = $self->page_filename($id);
  write_text($filename, $text);
}

1;

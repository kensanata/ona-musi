use Modern::Perl;
use Test::More;
use File::Slurper qw(read_text);
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use OnaMusi::Storage::Files;

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";
my $file = "test-$test/test.log";

sub slow_writer {
  my $str = time;
  open my $fh, '>>', $file or return;
  print $fh "$str\n";
  sleep 2;
  print $fh "$str\n";
  diag $str;
  close($fh);
}

diag "forking...in parallel";
my @children;
for (1 .. 5) {
  my $child = fork;
  if ($child == 0) {
    OnaMusi::Storage::Files::with_locked_file $file, sub { slow_writer };
    exit;
  }
  push(@children, $child);
}
for my $child (@children) { waitpid($child, 0) };

my $data = read_text $file;
ok($data, "$file read");
my %h = split(/\s+/, $data);
my $previous = 0;
for my $key (sort keys %h) {
  is($key, $h{$key}, "timestamp $key arrived in order");
  ok($previous < $key, "$key is bigger than the last one");
}

done_testing 11;

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

# test config
my $t = Test::Mojo->new('OnaMusi', {
  storage => 'OnaMusi::Storage::Git',
  markup => 'Text::Markup',
  pages_dir => "test-$test/pages",
  cache_dir => "test-$test/html" });

$t->app->storage->write_page('test', 'this is a test');

ok(-f "test-$test/pages/test.md", "file was written");

is($t->app->storage->read_page('test'), 'this is a test', "file was read");

$t->app->storage->delete_page('test');

ok(! -e "test-$test/pages/test.md", "file was deleted");

done_testing;

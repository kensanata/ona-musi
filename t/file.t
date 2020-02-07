use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";

is($t->app->storage->page_dir, "pages",
   "page directory is set to 'pages'");

is($t->app->storage->page_dir("test-$test/pages"), "test-$test/pages",
   "page directory changed to 'test-$test/pages'");

is($t->app->storage->cache_dir, "html",
   "cache directory is set to 'html'");

is($t->app->storage->cache_dir("test-$test/html"), "test-$test/html",
   "cache directory changed to 'test-$test/html'");

is($t->app->storage->page_dir, "test-$test/pages",
   "page directory unchanged");

mkdir "test-$test";

$t->app->storage->write_page('test', 'this is a test');

ok(-f "test-$test/pages/test.md", "file was written");

is($t->app->storage->read_page('test'), 'this is a test', "file was read");

$t->app->storage->cache_page('test', 'this is cached');

ok(-f "test-$test/html/test.html", "cache was written");

is($t->app->storage->cached_page('test'), 'this is cached', "cache was read");

done_testing;

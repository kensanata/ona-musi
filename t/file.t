use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

# test environment variables

$ENV{ONA_MUSI_PAGES_DIR} = "test-$test/pages";
$ENV{ONA_MUSI_HTML_DIR} = "test-$test/html";

$t->app->storage->write_page('test', 'this is a test');

ok(-f "test-$test/pages/test.md", "file was written");

is($t->app->storage->read_page('test'), 'this is a test', "file was read");

$t->app->storage->cache_page('test', 'this is cached');

ok(-f "test-$test/html/test.html", "cache was written");

is($t->app->storage->cached_page('test'), 'this is cached', "cache was read");

delete $ENV{ONA_MUSI_PAGES_DIR};
delete $ENV{ONA_MUSI_HTML_DIR};

# test config

my $config = $t->app->plugin('Config');
$config->{pages_dir} = "test-$test/pages-x";
$config->{cache_dir} = "test-$test/html-x";
$t->app->storage->init($config);

$t->app->storage->write_page('test-x', 'this is a test');

ok(-f "test-$test/pages-x/test-x.md", "file was written");

is($t->app->storage->read_page('test-x'), 'this is a test', "file was read");

$t->app->storage->cache_page('test-x', 'this is cached');

ok(-f "test-$test/html-x/test-x.html", "cache was written");

is($t->app->storage->cached_page('test-x'), 'this is cached', "cache was read");

# deleting

$t->app->storage->delete_page('test-x');

ok(! -e "test-$test/pages-x/test-x.md", "file was deleted");
ok(! -e "test-$test/html-x/test-x.html", "cache was deleted");

done_testing;

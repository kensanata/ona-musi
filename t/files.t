use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use OnaMusi::Change;

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

# test environment variables

$ENV{ONA_MUSI_PAGES_DIR} = "test-$test/pages";
$ENV{ONA_MUSI_HTML_DIR} = "test-$test/html";
$ENV{ONA_MUSI_LOG_FILE} = "test-$test/changes.log";

$t->app->storage->write_page('test', 'this is a test');

ok(-f "test-$test/pages/test.md", "file was written");

is($t->app->storage->read_page('test'), 'this is a test', "file was read");

$t->app->storage->cache_page('test', 'this is cached');

ok(-f "test-$test/html/test.html", "cache was written");

is($t->app->storage->cached_page('test'), 'this is cached', "cache was read");

# changes

my $change = OnaMusi::Change->new(
  ts => "ts", id => "id", revision => "revision",
  minor => "minor", author => "author", code => "code",
  summary => "summary");
$t->app->storage->write_change($change);

ok(-f "test-$test/changes.log", "log file was written");

ok(open(my $log, "<:encoding(UTF-8)", "test-$test/changes.log"), "log file was opened");
my $fs = $t->app->storage->fs;
my $line = <$log>;
chomp $line;
my @data = split(/$fs/, $line);
close($log);

is($data[0], 'ts', 'change log: timestamp');
is($data[1], 'id', 'change log: id');
is($data[2], 'revision', 'change log: revision');
is($data[3], '1', 'change log: minor');
is($data[4], 'author', 'change log: author');
is($data[5], 'code', 'change log: code');
is($data[6], 'summary', 'change log: summary');

delete $ENV{ONA_MUSI_PAGES_DIR};
delete $ENV{ONA_MUSI_HTML_DIR};
delete $ENV{ONA_MUSI_LOG_FILE};

# test config
$t = Test::Mojo->new('OnaMusi', {
  storage => 'OnaMusi::Storage::Files',
  markup => 'Text::Markup',
  pages_dir => "test-$test/pages-x",
  cache_dir => "test-$test/html-x",
  log_file => "test-$test/changes-x.log" });

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

# changes

$t->app->storage->write_change($change);

ok(-f "test-$test/changes-x.log", "log file was written");

ok(open($log, "<:encoding(UTF-8)", "test-$test/changes-x.log"), "log file was opened");
$fs = $t->app->storage->fs;
$line = <$log>;
chomp $line;
@data = split(/$fs/, $line);
close($log);

is($data[0], 'ts', 'change log: timestamp');
is($data[1], 'id', 'change log: id');
is($data[2], 'revision', 'change log: revision');
is($data[3], '1', 'change log: minor');
is($data[4], 'author', 'change log: author');
is($data[5], 'code', 'change log: code');
is($data[6], 'summary', 'change log: summary');

done_testing;

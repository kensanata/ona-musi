use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use OnaMusi::Change;
use OnaMusi::Filter;

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

# test environment variables

$ENV{ONA_MUSI_PAGES_DIR} = "test-$test/pages";
$ENV{ONA_MUSI_HTML_DIR} = "test-$test/html";
$ENV{ONA_MUSI_LOG_FILE} = "test-$test/changes.log";

$t->app->storage->write_page('test', undef, 'this is a test');

ok(-f "test-$test/pages/test.md", "file was written");

my $text = $t->app->storage->read_page('test');
is($text, 'this is a test', "file was read");

$t->app->storage->cache_page('test', 'this is cached');

ok(-f "test-$test/html/test.html", "cache was written");

is($t->app->storage->cached_page('test'), 'this is cached', "cache was read");

# changes

ok(open(my $log, "<:encoding(UTF-8)", "test-$test/changes.log"), "log file was opened");
my $fs = $t->app->storage->fs;
my $line = <$log>;
chomp $line;
my @data = split(/$fs/, $line);
close($log);

ok($data[0] > time - 10, 'change log: timestamp');
is($data[1], 'test', 'change log: id');
is($data[2], '1', 'change log: revision');
is($data[3], '0', 'change log: minor');
is($data[4], 'Anonymous', 'change log: author');
is($data[5], undef, 'change log: code');
is($data[6], undef, 'change log: summary');

# add a complete change entry and redo it all

my $change = OnaMusi::Change->new(
  ts => "ts", id => "id", revision => "revision",
  minor => "minor", author => "author", code => "code",
  summary => "summary");
$t->app->storage->write_change($change);

my $filter = OnaMusi::Filter->new(id => "id", minor => 1);
$change = $t->app->storage->read_changes($filter)->[0];

ok($data[0] > time - 10, 'change log: timestamp');
is($change->id, 'id', 'change log: id');
is($change->revision, 'revision', 'change log: revision');
is($change->minor, '1', 'change log: minor');
is($change->author, 'author', 'change log: author');
is($change->code, 'code', 'change log: code');
is($change->summary, 'summary', 'change log: summary');

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

$t->app->storage->write_page('test-x', 'md', 'this is a test');

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

ok(-f "test-$test/changes-x.log", "log file x was written");

$filter = OnaMusi::Filter->new(id => "test-x", minor => 0);
$change = $t->app->storage->read_changes($filter)->[0];

ok($data[0] > time - 10, 'change log: timestamp');
is($change->id, 'test-x', 'change log: id');
is($change->revision, 1, 'change log: revision');
is($change->minor, 0, 'change log: minor');
is($change->author, 'Anonymous', 'change log: author');
is($change->code, '', 'change log: code');
is($change->summary, '', 'change log: summary');

done_testing;

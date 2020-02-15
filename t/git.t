use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Temp;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $test = int(rand(1000));
my $dir = File::Temp->newdir();
mkdir $dir;

# test config
my $t = Test::Mojo->new('OnaMusi', {
  storage => 'OnaMusi::Storage::Git',
  markup => 'Text::Markup',
  pages_dir => "$dir/pages",
  cache_dir => "$dir/html" });

$t->app->storage->write_page('test', 'md', 'this is a test');

ok(-f "$dir/pages/test.md", "file was written");

is($t->app->storage->read_page('test'), 'this is a test', "file was read");

$t->app->storage->delete_page('test');

ok(! -e "$dir/pages/test.md", "file was deleted");

done_testing;

# Delete the tempdir if tests passed
$dir->unlink_on_destroy(Test::More->builder->is_passing);

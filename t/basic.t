use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";

is($t->app->storage->page_dir("test-$test/pages"), "test-$test/pages",
   "page directory changed to 'test-$test/pages'");

is($t->app->storage->cache_dir("test-$test/html"), "test-$test/html",
   "cache directory changed to 'test-$test/html'");

mkdir "test-$test";

$t->get_ok('/')
    ->status_is(302);

$t->ua->max_redirects(1);

# templates/list.html.ep
$t->get_ok('/')
    ->status_is(200)
    ->text_is('h1' => 'All Pages');

# public/help.html
$t->get_ok('/help.html')
    ->status_is(200)
    ->text_is('h1' => 'OnaMusi Help');

# templates/edit.html.ep
$t->get_ok('/edit/test.md')
    ->status_is(200)
    ->text_is('h1' => 'Edit test.md');

# save
$t->post_ok('/save/test.md'
	    => form
	    => {content => "# This is a test\n\nHello!"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# templates/view.html.ep
$t->get_ok('/view/test.md')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# html
$t->get_ok('/html/test.md')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# text
$t->get_ok('/raw/test.md')
    ->status_is(200)
    ->content_is("# This is a test\n\nHello!");

# templates/edit.html.ep
$t->get_ok('/edit/test.md')
    ->status_is(200)
    ->text_is('textarea' => "# This is a test\n\nHello!");

# templates/list.html.ep
$t->get_ok('/list')
    ->status_is(200)
    ->text_is('ul li a' => 'test'); # no file extension!

# templates/view.html.ep without extension
$t->get_ok('/view/test')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# html without extension
$t->get_ok('/html/test')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# text without extension
$t->get_ok('/raw/test')
    ->status_is(200)
    ->content_is("# This is a test\n\nHello!");

# templates/edit.html.ep without extension
$t->get_ok('/edit/test')
    ->status_is(200)
    ->text_is('textarea' => "# This is a test\n\nHello!");

# save without extension
$t->post_ok('/save/test'
	    => form
	    => {content => "# This is a test\n\n¡Hola!"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => '¡Hola!');

# templates/edit.html.ep with the wrong extension
$t->get_ok('/edit/test.bb')
    ->status_is(200)
    ->text_is('textarea' => "# This is a test\n\n¡Hola!");

# save with the wrong extension (still markdown!)
$t->post_ok('/save/test.bb'
	    => form
	    => {content => "# This is a test\n\nOlá!"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Olá!');

done_testing();

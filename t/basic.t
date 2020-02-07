use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";

is($t->app->storage->dir, "pages",
   "default directory is set to 'pages'");

is($t->app->storage->dir("test-$test"), "test-$test",
   "default directory is set to 'test-$test'");

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
	    => {content => "# This is a test\n\nHello"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello');

# templates/view.html.ep
$t->get_ok('/view/test.md')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello');

# html
$t->get_ok('/html/test.md')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello');

# text
$t->get_ok('/raw/test.md')
    ->status_is(200)
    ->content_is("# This is a test\n\nHello");

# templates/edit.html.ep
$t->get_ok('/edit/test.md')
    ->status_is(200)
    ->text_is('textarea' => "# This is a test\n\nHello");

# templates/list.html.ep
$t->get_ok('/list')
    ->status_is(200)
    ->text_is('ul li a' => 'test'); # no file extension!

# templates/view.html.ep without extension
$t->get_ok('/view/test')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello');

# html without extension
$t->get_ok('/html/test')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello');

# text without extension
$t->get_ok('/raw/test')
    ->status_is(200)
    ->content_is("# This is a test\n\nHello");

# templates/edit.html.ep without extension
$t->get_ok('/edit/test')
    ->status_is(200)
    ->text_is('textarea' => "# This is a test\n\nHello");

# save without extension
$t->post_ok('/save/test'
	    => form
	    => {content => "# This is a test\n\n¡Hola!"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => '¡Hola!');

done_testing();

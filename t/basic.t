use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use File::Slurper qw(write_text);
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

my $config = $t->app->plugin('Config');

$config->{pages_dir} = "test-$test/pages";
$config->{cache_dir} = "test-$test/html";
# no security questions
$config->{question} = undef;
$config->{answer} = undef;

$t->app->storage->init($config);
$t->app->question->init($config);

$t->get_ok('/')
    ->status_is(302);

$t->ua->max_redirects(1);

# templates/view.html.ep but the 'home' page doesn't exist
$t->get_ok('/')
    ->status_is(404);

# public/help.html
$t->get_ok('/help.html')
    ->status_is(200)
    ->text_is('h1' => 'OnaMusi Help');

# templates/edit.html.ep
$t->get_ok('/edit/test.md')
    ->status_is(200)
    ->text_is('h1' => 'Edit test.md');

# save with diagnosis example
$t->post_ok('/page/test.md'
	    => form
	    => {content => "# This is a test\n\nHello!"})
    ->status_is(200)->or(sub { diag $t->tx->res->dom->all_text })
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Hello!');

# templates/page.html.ep
$t->get_ok('/page/test.md')
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

# templates/page.html.ep without extension
$t->get_ok('/page/test')
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
$t->post_ok('/page/test'
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
$t->post_ok('/page/test.bb'
	    => form
	    => {content => "# This is a test\n\nOlá!"})
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Olá!');

# make sure the cache is considered stale
sleep(1);

# change file directly ("manually")
write_text("test-$test/pages/test.md", "# This is a test\n\nSalut!");

# templates/page.html.ep without extension
$t->get_ok('/page/test')
    ->status_is(200)
    ->text_is('h1' => 'This is a test')
    ->text_is('p' => 'Salut!');

done_testing();

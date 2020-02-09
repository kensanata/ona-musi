use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

my $t = Test::Mojo->new('OnaMusi');

my $test = int(rand(1000));
diag "test-$test";
mkdir "test-$test";

my $config = $t->app->plugin('Config');

$config->{pages_dir} = "test-$test/pages";
$config->{cache_dir} = "test-$test/html";

$config->{question} = 'Name a colour of the rainbow!';
$config->{answer} = '\b(red|orange|yellow|green|blue|indigo|violet)\b';

$t->app->storage->init($config);
$t->app->question->init($config);

$t->ua->max_redirects(1);

# templates/view.html.ep but the 'home' page doesn't exist
$t->get_ok('/')
    ->status_is(404);

# templates/edit.html.ep
$t->get_ok('/edit/home')
    ->status_is(200)
    ->text_is('h1' => 'Edit home');

# first save results in a question
$t->post_ok('/page/home'
	    => form
	    => {id => 'home', content => "# Home\n\nHello!"})
    ->status_is(200)
    ->text_is('h1' => 'First time editor? Welcome!');

# answer the question and save
$t->post_ok('/page/home'
	    => form
	    => {id => 'home', answer => 'red', content => "# Home\n\nHello!"})
    ->status_is(200)
    ->text_is('h1' => 'Home')
    ->text_is('p' => 'Hello!');

# no question on subsequent edits because of the cookie
$t->post_ok('/page/home'
	    => form
	    => {id => 'home', content => "# Home\n\nالسّلام عليكم"})
    ->status_is(200)
    ->text_is('h1' => 'Home')
    ->text_is('p' => 'السّلام عليكم');

done_testing;

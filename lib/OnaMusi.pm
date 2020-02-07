package OnaMusi;
use Mojo::Base 'Mojolicious';
use Text::Markup;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by config file
  my $config = $self->plugin('Config');

  # Configure the application
  $self->secrets($config->{secrets});
  eval "require $config->{storage}";
  eval "require $config->{markup}";

  # Helper to lazy initialize and store our model object.
  $self->helper(storage => sub { state $storage = $config->{storage}->new });
  $self->helper(markup => sub { state $render = $config->{markup}->new });

  # Router
  my $r = $self->routes;
  $r->get('/' => sub {my $c = shift; $c->redirect_to('list')})->name('home');
  $r->get('/list')->to(controller => 'search', action => 'list')->name('list');
  $r->get('/html/#id')->to(controller => 'view', action => 'html')->name('html');
  $r->get('/raw/#id')->to(controller => 'view', action => 'raw')->name('raw');
  $r->get('/view/#id')->to(controller => 'view', action => 'view')->name('view');
  $r->get('/edit/#id')->to(controller => 'edit', action => 'edit')->name('edit');
  $r->post('/save/#id')->to(controller => 'edit', action => 'save')->name('save');
}

1;

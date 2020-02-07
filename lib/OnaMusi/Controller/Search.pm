package OnaMusi::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub list {
  my $c = shift;
  my $ids = $c->storage->pages();
  $c->render(template => 'list', ids => $ids);
}

1;

package OnaMusi::Controller::Edit;
use Mojo::Base 'Mojolicious::Controller';

sub edit {
  my $c = shift;
  my $id = $c->param('id');
  my $text = $c->storage->read_page($id);
  $c->render(template => 'edit', content => $text);
}

sub save {
  my $c = shift;
  my $id = $c->param('id');
  my $text = $c->param('content');
  $text =~ s/\r\n/\n/g; # use regular EOL convention
  $c->storage->write_page($id, $text);
  $c->redirect_to('view', id => $id);
}

1;

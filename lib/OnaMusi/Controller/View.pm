package OnaMusi::Controller::View;
use Mojo::Base 'Mojolicious::Controller';

sub html {
  my $c = shift;
  my $filename = $c->storage->page_filename($c->param('id'));
  my $html = -f $filename ? $c->markup->parse(file => $filename) : "";
  $html =~ s/<\/?(html|body|head|meta .*)>\s*//g;
  utf8::decode($html);
  $c->render(text => $html, format => 'html');
}

sub raw {
  my $c = shift;
  my $text = $c->storage->read_page($c->param('id'));
  $c->render(text => $text, format => 'text');
}

sub view {
  my $c = shift;
  my $id = $c->param('id');
  my $filename = $c->storage->page_filename($id);
  my $html;
  my $cache;
  if (-f $filename) {
    $cache = $c->storage->cached_page($id);
    $html = $cache || $c->markup->parse(file => $filename);
  } else {
    my $url = $c->url_for("/edit/$id");
    $html = qq{<p>This page does not exist but you can <a href="$url">create it</a> now, if you want.};
  }
  utf8::decode($html);
  $c->storage->cache_page($id, $html) unless $cache;
  $html =~ s/<\/?(html|body|head|meta .*)>\s*//g;
  $c->render(template => 'view', content => $html);
}

1;

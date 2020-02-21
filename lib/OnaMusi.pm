# Ona Musi is a wiki engine
# Copyright (C) 2020  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

=head1 OnaMusi

Ona Musi is a wiki. OnaMusi is a L<Mojolicious> application. On startup, it
reads the config file and sets up all the routes.

See L<Mojolicious::Guides::Routing> for more information about routing.

See L<Mojolicious::Plugin::Config> for more information about the config file.

Important keys in the config file:

=over

=item C<storage> names a class that does storage

=item C<markup> names a class that handles markup

=back

See L<OnaMusi::Storage::Files> for the default implementation which stores all
the info as files.

See L<Text::Markup> for the default implementation which converts the text
people write to HTML.

=cut

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
  $self->helper(storage => sub { state $storage = $config->{storage}->new(config => $config, log => $self->app->log) });
  $self->helper(markup => sub { state $render = $config->{markup}->new(config => $config) });
  $self->helper(question => sub { require OnaMusi::Questions; state $question = OnaMusi::Questions->new($config) });

  # Router
  my $r = $self->routes;
  $r->get('/' => sub {my $c = shift; $c->redirect_to('/page/home')})->name('home');
  $r->get('/list')->to(controller => 'search', action => 'list')->name('list');
  $r->get('/changes')->to(controller => 'changes', action => 'html')->name('changes');
  $r->get('/html/#id')->to(controller => 'view', action => 'html')->name('html');
  $r->get('/raw/#id')->to(controller => 'view', action => 'raw')->name('raw');
  $r->get('/page/#id')->to(controller => 'view', action => 'view')->name('view');
  $r->get('/edit/#id')->to(controller => 'edit', action => 'edit')->name('edit');

  my $question_answered = $r->under(sub { $self->app->question->ask(@_) });
  $question_answered->delete('/page/#id')->to(controller => 'edit', action => 'delete')->name('delete');
  $question_answered->post('/page/#id')->to(controller => 'edit', action => 'save')->name('save');
  $r->post('/page/#id/preview')->to(controller => 'edit', action => 'preview')->name('preview');
}

1;

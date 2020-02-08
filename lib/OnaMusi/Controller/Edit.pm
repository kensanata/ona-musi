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

=head1 OnaMusi::Controller::Edit

Ona Musi is a wiki. This class is a L<Mojolicious::Controller> and provides two
actions:

=over

=cut

package OnaMusi::Controller::Edit;
use Mojo::Base 'Mojolicious::Controller';

=item C<edit>

This reads the page named by the C<id> parameter from storage and uses the
C<edit.html.ep> template to allow users to edit it.

=cut

sub edit {
  my $c = shift;
  my $id = $c->param('id');
  my $text = $c->storage->read_page($id);
  $c->render(template => 'edit', content => $text);
}


=item C<delete>

This deletes the page named by the C<id> parameter from storage and uses the
C<view.html.ep> template to allow users to recreate it.

=cut

sub delete {
  my $c = shift;
  my $id = $c->param('id');
  $c->storage->delete_page($id);
  $c->redirect_to('view', id => $id);
}

=item C<save>

This writes the page named by the C<id> parameter to storage. It's content is
determined by the C<content> parameter. The user is then redirected to the
C<view> action. See L<OnaMusi::Controller::View>.

=cut

sub save {
  my $c = shift;
  my $id = $c->param('id');
  my $text = $c->param('content');
  $text =~ s/\r\n/\n/g; # use regular EOL convention
  $c->storage->write_page($id, $text);
  $c->redirect_to('view', id => $id);
}

=back

=cut

1;

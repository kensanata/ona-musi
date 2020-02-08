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

Ona Musi is a wiki. This class is a L<Mojolicious::Controller> and provides one
action:

=over

=cut

package OnaMusi::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

=item C<list>

This lists all the page in storage and uses the C<list.html.ep> template to show
them.

=cut

sub list {
  my $c = shift;
  my $ids = $c->storage->pages();
  $c->render(template => 'list', ids => $ids);
}

=back

=cut

1;

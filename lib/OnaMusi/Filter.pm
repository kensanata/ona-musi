# OnaMusi is a wiki engine
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

=head1 OnaMusi::Filter

Instances of this class act as a container for various attributes describing a
filter to the list of changes. See L<OnaMusi::Change> for more.

If you add more filter attributes, be sure to change the following:

=cut

package OnaMusi::Filter;
use Mojo::Base -base;

has 'n' => 30;          # limit to the last n items
has 'id';		# limit to a specific page name
has 'author';         	# limit to a specific author
has 'minor' => 0;     	# include minor changes
has 'all' => 0;       	# just the last one

1;

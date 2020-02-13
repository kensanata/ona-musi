# Oddmuse is a wiki engine
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

=head1 OnaMusi::Change

The actual representation of the change log is determined by the storage
backend.

The fields are:

=over

=item C<ts> is the change timestamp, in seconds since the beginning of the
epoch.

=item C<id> is the name of the page.

=item C<revision> is the revision that was changed, which is equivalent to the
number of edits made to a page. The first revision is number 1.

=item C<author> is the name of the author, if specified.

=item C<code> is a code based on the IP of the author.

=item C<summary> is the single-line summary provided for the change, if any.

=back

=cut

package OnaMusi::Change;
use Mojo::Base -base;

has 'ts';
has 'id';
has 'revision';
has 'minor';
has 'author';
has 'code';
has 'summary';

1;

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

=head1 OnaMusi::Controller::Changes

Ona Musi is a wiki. This class is a L<Mojolicious::Controller> and produces
"Recent Changes", the log of what has changed.

Changes are rendered using the C<changes.html.ep> template. This happens via an
array called C<changes>.

=over

=item C<date> in the format C<YYYY-mm-dd>.

=item C<first> is set when this is the first change in the list of
changes. The template uses this for the first day heading.

=item C<last> is set when this is the last change in the list of
changes. The template uses this for HTML cleanup.

=item C<day> is set when this change is on a different date compared
to previous changes. The template uses this for subsequent day
heading.

=item C<time> in the format C<hh-mm-ss>.

=item C<minor> to indicate whether this is a minor change.

=item C<id> is the name of the page affected.

=item C<revision> is the revision that was changed, which is
equivalent to the number of edits made to a page. The first revision
is number 1. To look at the change, however, you'd want to look at the
result, the revision after that! Thus, for the last change, there is
no keep file!

=item C<author> is the name of the author, if specified.

=item C<code> is a code used to identify changes when no author was
provided. In this case the IP number of the user making the change is
used to compute four numbers in the range from 1 to 8, and these
numbers are then turned into a color using the default CSS. This
generates little color codes that look a bit like flags.

=item C<summary> is the summary provided for the change, if any.

=back

The template also gets a hash for the filter.

=over

=item C<n> is the number of latest items to be shown

=item C<id> is the name of the page.

=item C<author> is the name of the author.

=item C<minor> is set when minor changes are included.

=item C<all> is set when all changes are included, not just the last
change per page.

=back

Functions

=over

=cut

package OnaMusi::Controller::Changes;
use Mojo::Base 'Mojolicious::Controller';
use OnaMusi::Filter;

=item C<html>

This reads the page named by the C<id> parameter from storage, and parses and
renders the resulting HTML. The cache is not used.

=cut

sub html {
  my $c = shift;
  my $all = $c->param('all');
  my $minor = $c->param('minor');
  my $id = $c->param('id');
  my $author = $c->param('author');
  my $filter = OnaMusi::Filter->new(all => $all, minor => $minor, id => $id, author => $author);
  my $changes = $c->storage->read_changes($filter);
  $c->render(template => 'changes', filter => $filter, changes => $changes);
}

=item C<raw>

This reads the page named by the C<id> parameter from storage and shows it
directly, as raw text.

=cut

sub raw {
  my $c = shift;
}

=item C<view>

This shows the page named by the C<id> parameter. If possible, the HTML is
retrieved from the cache. If no cached HTML is in storage, the page itself is
read from storage, parsed, rendered, and the cache is updated. The page is shown
using the C<view.html.ep> template.

=cut

sub feed {
  my $c = shift;
}

=back

=cut

1;

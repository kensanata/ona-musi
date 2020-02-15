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

Ona Musi is a wiki. This class is a L<Mojolicious::Controller> and provides the
following actions:

=over

=cut

package OnaMusi::Controller::Edit;
use Mojo::Base 'Mojolicious::Controller';
use OnaMusi::Change;
use B;

=item C<edit>

This reads the page named by the C<id> parameter from storage and uses the
C<edit.html.ep> template to allow users to edit it.

The C<type> parameter is used to suggest an extension for new pages. The default
is C<md>. This comes from the C<empty.html.ep> template. If the page already
exists, the C<type> you provide is ignored and the actual C<type> is returned.

=cut

sub edit {
  my $c = shift;
  my $id = $c->param('id');
  my ($text, $type) = $c->storage->read_page($id, $c->param('type'));
  $c->render(template => 'edit', content => $text, type => $type);
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

Parameters expected:

=over

=item C<id> is the page id

=item C<type> is the file extension to use for new pages, that is: it is only
used if there is no revision (and it defaults to C<md>)

=item C<content> is the new page content

=item C<revision> is the revision being edited, useful for automatic merging of
changes

=item C<minor> indicates a "minor" change; this usually means that such changes
should not show up in RSS feeds or get sent to subscribers via mail and the like

=item C<author> is the name of the author making the change

=item C<summary> is the summary to provide for the change; it's shown in the
list of changes

=back

=cut

sub save {
  my $c = shift;
  my $id = $c->param('id');
  my $type = $c->param('type');
  my $text = $c->param('content');
  my $revision = $c->param('revision');
  my $minor = $c->param('minor') ? 1 : 0;
  my $author = $c->param('author');
  my $summary = $c->param('summary');
  $text =~ s/\r\n/\n/g; # use regular EOL convention
  my $change = OnaMusi::Change->new(
    ts => time, id => $id, revision => $revision, minor => $minor,
    author => $author, code => code($c), summary => $summary);
  $c->storage->write_page($id, $type, $text, $change);
  $c->redirect_to('view', id => $id);
}

sub code {
  my $c = shift;
  my $hash = unpack("L",B::hash($c->tx->remote_address));
  my $octal = sprintf("%o", $hash); # octal is 0-7
  return substr($octal, 0, 4); # first four digits
}

=back

=cut

1;

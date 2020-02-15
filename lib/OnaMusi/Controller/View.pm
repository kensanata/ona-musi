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

Ona Musi is a wiki. This class is a L<Mojolicious::Controller> and provides
three actions:

=over

=cut

package OnaMusi::Controller::View;
use Mojo::Base 'Mojolicious::Controller';

=item C<html>

This reads the page named by the C<id> parameter from storage, and parses and
renders the resulting HTML. The cache is not used.

=cut

sub html {
  my $c = shift;
  my $filename = $c->storage->page_filename($c->param('id'));
  my $html = -f $filename ? $c->markup->parse(file => $filename) : "";
  $html =~ s/<\/?(html|body|head|meta .*)>\s*//g;
  utf8::decode($html);
  $c->render(text => $html, format => 'html');
}

=item C<raw>

This reads the page named by the C<id> parameter from storage and shows it
directly, as raw text.

=cut

sub raw {
  my $c = shift;
  my $text = $c->storage->read_page($c->param('id'));
  $c->render(text => $text, format => 'txt');
}

=item C<view>

This shows the page named by the C<id> parameter. If possible, the HTML is
retrieved from the cache. If no cached HTML is in storage, the page itself is
read from storage, parsed, rendered, and the cache is updated. The page is shown
using the C<view.html.ep> template.

=cut

sub view {
  my $c = shift;
  my $id = $c->param('id');
  my $filename = $c->storage->page_filename($id);
  my $html;
  my $cache;
  if (-f $filename) {
    $cache = $c->storage->cached_page($id);
    $html = $cache || $c->markup->parse(file => $filename);
    utf8::decode($html);
    $c->storage->cache_page($id, $html) unless $cache;
    $html =~ s/<\/?(html|body|head|meta .*)>\s*//g;
    $c->render(template => 'view', content => $html);
  } else {
    $c->render(template => 'empty', id => $id, status => 404);
  }
}

=back

=cut

1;

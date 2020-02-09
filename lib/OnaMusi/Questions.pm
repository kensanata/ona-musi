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

=head1 OnaMusi::Questions

Ona Musi is a wiki. This class provides the "questino asker" functionality to
discourage spambots. In order to use it, add two keys to the config file:

=over

=item C<question> is a question to ask of first-time editors

=item C<answer> is a regular expression to check the answer

=back

Once the user has answered the question correctly, the answer is stored in the
cookie.

=cut

package OnaMusi::Questions;
use Modern::Perl '2018';

sub new {
  my ($class, $config) = @_;
  my $self = {};
  bless $self, $class;
  $self->init($config);
  return $self;
}

my $question;
my $answer;

sub init {
  my ($self, $config) = @_;
  $question = $config->{question};
  $answer = $config->{answer};
}

=pod

The functions provided by this class:

=over

=item C<ask>

This is the code to use for C<under> in order to protect a route from use by
bots. See L<Mojolicious::Guides::Routing> for more. If a question needs to be
asked, the C<question.html.ep> template is used. The following paramters are
passed through:

=over

=item C<id>

=item C<content>

=back

The template is then supposed to call the correct route again.

=cut

sub ask {
  my ($self, $c) = @_;
  # no question configured
  return 1 unless $question;

  my $input = $c->cookie('answer');
  # the correct answer was found in the cookie
  return 1 if $input and $input =~ /$answer/;

  $input = $c->param('answer');
  if ($input and $input =~ /$answer/) {
    # store the correct answer in the cookie
    $c->cookie('answer', $input);
    return 1;
  }

  warn "question\n";
  $c->render(template => 'question',
	     question => $question,
	     action => $c->current_route,
	     id => $c->param('id'),
	     content => $c->param('content'));
  return undef;
}

=back

=cut

1;

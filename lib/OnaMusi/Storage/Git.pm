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

=encoding utf8

=head1 OnaMusi::Storage::Git

Ona Musi is a wiki. By default, it stores its data in files. This module extends
L<OnaMusi::Storage::Files> – it checks files into a git repository.

C<pages> is the directory where page files are stored.
The key C<pages_dir> in the config file can be used to change it.
The environment variable C<ONA_MUSI_PAGES_DIR> can be used to override it.
This is also the git repository.

C<html> is the directory where cached HTML is stored.
The key C<cache_dir> in the config file can be used to change it.
The environment variable C<ONA_MUSI_HTML_DIR> can be used to override it.

=over

=cut

package OnaMusi::Storage::Git;
use Mojo::Base 'OnaMusi::Storage::Files';
use Modern::Perl '2018';
use Git;
use Cwd;

has 'repo' => sub {
  my $dir = getcwd;
  chdir $self->pages_dir;
  my $repo = Git->repository;
  chdir $dir;
  return $repo;
};

=item C<write_page>

After calling C<write_page>, the following C<git> commands are executed:

=over

=item C<git init> if no C<.git> directory exists in the C<pages> directory

=item C<git add> for the C<pages> directory

=item C<git commit>

=back

See L<Git> for the module handling the calls to C<git>.

=cut

sub write_page {
  my ($self, $id, $text) = @_;
  $self->SUPER::write_page($id, $text);
  my $dir = getcwd;
  chdir $self->pages_dir;
  $self->repo->command_noisy('init') unless -d "/.git";
  $self->repo->command_noisy('add', $self->pages_dir);
  $self->repo->command_noisy('commit', "--message=Edit $id");
  chdir $dir;
}

=item C<delete_page>

After calling C<delete_page>, the following C<git> commands are executed:

=over

=item C<git rm>

=item C<git commit>

=back

=cut

sub delete_page {
  my ($self, $id) = @_;
  $self->SUPER::delete_page($id);
  my $dir = getcwd;
  chdir $self->pages_dir;
  $self->repo->command_noisy('rm', $self->page_filename($id));
  $self->repo->command_noisy('commit', "--message=Delete $id");
  chdir $dir;
}

=back

=cut

1;

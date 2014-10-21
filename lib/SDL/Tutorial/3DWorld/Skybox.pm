package SDL::Tutorial::3DWorld::Skybox;

=pod

=head1 NAME

SDL::Tutorial::3DWorld::Skybox - Better than a uniform sky colour

=head1 DESCRIPTION

A Skybox is a common method for drawing a full photographic background
for a 3D World visible in all directions.

It consists of a large cube with a set of six special pre-rendered
textures that stich together at the edges, creating the appearance of
a large surrounding environment.

For more information on the general concept of a sky box see
L<http://en.wikipedia.org/wiki/Skybox_%28video_games%29>.

This basic implementation takes a directory and looks for six image files
within it called F<north.bmp>, F<south.bmp>, F<east.bmp>, F<west.bmp>,
F<up.bmp> and F<down.bmp>.

The textures are projected onto the cube and uniformly lit, ignoring the
normal lighting model.

The main special effects "trick" to implementing a skybox is that it will
rotate with the rest of the world but match the movements of the camera
so that artifacts in the skybox texture stay the same size regardless of
the movement of the camera (making them appear to be a long way away).

=head1 METHODS

=cut

use strict;
use warnings;
use File::Spec ();
use OpenGL;
use SDL::Tutorial::3DWorld::Texture ();

our $VERSION = '0.04';

=pod

=head2 new

  # Load a skybox from a set of files included within a distribution
  my $sky = SDL::Tutorial::3DWorld::Skybox->new(
      directory => File::Spec->catdir(
          File::ShareDir::dist_dir('SDL-Tutorial-3DWorld'), 'skybox'
      )
  );

The C<new> constructor creates a new skybox object.

It takes a single C<directory> parameter which should be a directory that
exists, and contains the six named BMP skybox texture files.

Although the existance of the texture files will be checked at constructor
time, they will not actually be loaded until you run the world (during the
init phase).

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;

	# Check params
	my $type      = $self->type;
	my $directory = $self->directory;
	unless ( $type ) {
		die "Missing or invalid skybox texture file type";
	}
	unless ( defined $directory and -d $directory ) {
		die "Missing or invalid skybox texture directory";
	}

	# Locate the five main textures
	foreach my $side ( qw{ north east south west up } ) {
		$self->{$side} = SDL::Tutorial::3DWorld::Texture->new(
			file => File::Spec->catfile(
				$directory, "$side.$type",
			),
		);
	}

	# Many sky boxes don't have a bottom texture, we are ok with that
	local $@;
	$self->{down} = eval {
		SDL::Tutorial::3DWorld::Texture->new(
			file => File::Spec->catfile(
				$directory, "down.$type",
			)
		);
	};

	return $self;
}

=pod

=head2 directory

The C<directory> accessor returns the skybox texture directory.

=cut

sub directory {
	$_[0]->{directory};
}

=pod

=head2 type

The C<type> accessor returns the file type of the skybox textures.

=cut

sub type {
	$_[0]->{type};
}





######################################################################
# Engine Interface

sub init {
	my $self = shift;

	# Initialise all the textures
	foreach my $side ( qw{ north east south west up down } ) {
		$self->{$side}->init if $self->{$side};
	}

	return 1;
}

sub display {
	my $self = shift;
	glDisable( GL_LIGHTING );

	# Activate the north face texture
	$self->{north}->display;

	# Draw the north face with the texture
	glColor3d( 1, 1, 1 );
	glBegin( GL_QUADS );
	glTexCoord2f( 0.0, 0.0 ); glVertex3f( -1.0,  1.0, 1 ); # Bottom Left
	glTexCoord2f( 1.0, 0.0 ); glVertex3f(  1.0,  1.0, 1 ); # Bottom Right
	glTexCoord2f( 1.0, 1.0 ); glVertex3f(  1.0, -1.0, 1 ); # Top Right
	glTexCoord2f( 0.0, 1.0 ); glVertex3f( -1.0, -1.0, 1 ); # Top Left
	glEnd();

	glEnable( GL_LIGHTING );
	return 1;
}

=cut

=pod

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SDL-Tutorial-3DWorld>

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 SEE ALSO

L<SDL>, L<OpenGL>

=head1 COPYRIGHT

Copyright 2010 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

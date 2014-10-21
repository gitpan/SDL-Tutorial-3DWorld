package SDL::Tutorial::3DWorld::Actor::Billboard;

use 5.008;
use strict;
use warnings;
use SDL::Tutorial::3DWorld           ();
use SDL::Tutorial::3DWorld::OpenGL   ();
use SDL::Tutorial::3DWorld::Texture  ();
use SDL::Tutorial::3DWorld::Material ();
use SDL::Tutorial::3DWorld::Actor    ();

our $VERSION = '0.32';
our @ISA     = 'SDL::Tutorial::3DWorld::Actor';





######################################################################
# Constructor and Accessors

sub new {
	my $class = shift;
	my $self  = bless {
		blending => 1,
		@_,
	}, $class;

	# Convert the texture to a full material
	$self->{material} = SDL::Tutorial::3DWorld::Material->new(
		ambient => [ 1, 1, 1, 0.5 ],
		diffuse => [ 1, 1, 1, 0.5 ],
		texture => SDL::Tutorial::3DWorld::Texture->new(
			file => $self->{texture},
			tile => 0,
		),
	);

	return $self;
}

sub display {
	my $self = shift;
	$self->SUPER::display(@_);

	# Rotate towards the camera
	my $camera = SDL::Tutorial::3DWorld->current->camera;
	OpenGL::glRotatef( -$camera->{angle},      0, 1, 0 );
	OpenGL::glRotatef( -$camera->{elevation}, -1, 0, 0 );

	# Switch to the sprite
	$self->{material}->display;

	# Draw the sprite quad.
	# The texture seems to wrap a little unless we use the 0.01 here.
	OpenGL::glDisable( OpenGL::GL_LIGHTING );
	OpenGL::glBegin( OpenGL::GL_QUADS );
	OpenGL::glTexCoord2f( 0, 0 ); OpenGL::glVertex3f( -0.5,  1,  0 ); # Top Left
	OpenGL::glTexCoord2f( 0, 1 ); OpenGL::glVertex3f( -0.5,  0,  0 ); # Bottom Left
	OpenGL::glTexCoord2f( 1, 1 ); OpenGL::glVertex3f(  0.5,  0,  0 ); # Bottom Right
	OpenGL::glTexCoord2f( 1, 0 ); OpenGL::glVertex3f(  0.5,  1,  0 ); # Top Right
	OpenGL::glEnd();
	OpenGL::glEnable( OpenGL::GL_LIGHTING );

	return 1;
}

1;

/**
 *
 * This is a basic demonstration of particle emitters
 *
 * The configuration variables on particles are:
 *
 * emission - how much particles per frame are created
 * speed - how fast are the particles moving
 * angle - angle of the particle emitter in degrees.
 *         0 degrees is to the right, 270 to the top
 * gravity - vertical speed increase/decrease per frame
 *
 * you can add random behaviour by the variables
 *
 * emissionDistribution
 * speedDistribution
 * angleDistribution
 *
 * e.g. a angleDistribution of 60 would and a angle of 90
 * would mean the particles varying randomly between 60-120
 *
 * all variables are float
 *
 * */

#include <sge.h>

// define our data that is passed to our redraw function
typedef struct {
	SGEPARTICLES *pixelparticles;
	SGEPARTICLES *spriteparticles;
} MainStateData;

// redraw the screen and update game logics, if any
void on_redraw(SGEGAMESTATE *state)
{
	// prepare event and data variable form the gamestat passed to that
	// function
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;

	// has the user closed the window?
	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}

	sgeClearScreen();

	// rotate the pixel particles by 5 degrees/frame
	data->pixelparticles->angle+=5;
	// draw the pixel particles
	sgeParticlesDraw(data->pixelparticles);

	// move the spriteparticles in a smooth motion across the screen
	data->spriteparticles->x=cos(M_PI/180*(data->spriteparticles->runtime%360))*140+160;
	// draw the sprite particles
	sgeParticlesDraw(data->spriteparticles);

	// finally display the screen
	sgeFlip();
}

// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	SGEFILE *file;
	SGESPRITE *sprite;
	MainStateData data;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO,NOJOYSTICK);
	sgeOpenScreen("SGE Particles",320,240,32,NOFULLSCREEN);
	sgeHideMouse();

	// add a pixel particle emitter
	// rgb color range between 0x20/0x80/0x20 and 0xff/0xff/0x30
	data.pixelparticles=sgeParticlesPixelNew(0x20,0x80,0x20,0xff,0xff,0x30);
	data.pixelparticles->x=160;
	data.pixelparticles->y=50;
	data.pixelparticles->speed=2;
	// emit particles into the angle direction +/- 8
	data.pixelparticles->angle=90;
	data.pixelparticles->angleDistribution=16;
	// let the particles die after 50 frames
	data.pixelparticles->timeToLive=50;
	// +/- 10
	data.pixelparticles->timeToLiveDistribution=20;


	// read the sprite for using it with a sprite particle emitter
	file=sgeOpenFile("data.d","asdf");
	sprite=sgeSpriteNewFile(file, "cloud.png");
	sgeCloseFile(file);

	// add the sprite particle emitter
	data.spriteparticles=sgeParticlesSpriteNew(sprite);
	data.spriteparticles->emission=10;
	data.spriteparticles->y=220;
	// add negative gravity so the particles increase
	// its speed upwards
	data.spriteparticles->gravity=-.1;
	data.spriteparticles->angle=270;
	data.spriteparticles->angleDistribution=90;
	data.spriteparticles->timeToLive=120;
	data.spriteparticles->timeToLiveDistribution=140;
	data.spriteparticles->speed=.5;

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// start the game running with 30 frames per seconds
	sgeGameStateManagerRun(manager, 30);

	// clean up
	sgeParticlesDestroy(data.pixelparticles);
	sgeParticlesDestroy(data.spriteparticles);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}


/**
 *
 * This is a basic demonstration of the minimum code for a gameloop using sge2d.
 *
 * It just plots out a red rectangle in the middle of the screen and waits for
 * the user to close the window.
 * */

#include <sge.h>

// define our data that is passed to our redraw function
typedef struct {
	Uint32 color;
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

	// draw a rectangle
	//
	// IMPORTANT: you should always lock and unlock surfaces if directly
	// altering pixeldata, on some platforms, e.g. the gp2x, it will lead
	// to a crash if you dont do so.
	//
	// you'll have to do so on most sgegfx.h functions. you do *NOT* need
	// to lock a surface, if you blit on it (e.g. drawing sprites or using
	// SDL_BlitSurface
	sgeLock(screen);
	sgeFillRect(screen, 100,100,120,40,data->color);
	sgeUnlock(screen);

	// finally display the screen
	sgeFlip();
}

// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	MainStateData data;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO,NOJOYSTICK);
	sgeOpenScreen("Basic SGE loop",320,240,32,NOFULLSCREEN);
	sgeHideMouse();

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	// this is just to demonstrate the use of the gamestate data
	// everything added to the gamestate data will be available in the gamestates
	// function (on_redraw on this example) as a 'global' data
	data.color = sgeMakeColor(0xff,0,0,0xff);

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// start the game running with 30 frames per seconds
	sgeGameStateManagerRun(manager, 30);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}

/**
 *
 * This is a basic demonstration of the minimum code for a gameloop using sge2d.
 *
 * It just plots out a red rectangle in the middle of the screen and waits for
 * the user to close the window.
 * */

#include <sge.h>

// define a structure to hold our sprite and a random direction
typedef struct {
	SGESPRITE *sprite;
	int dirx;
	int diry;
} SpriteInfo;

// define our data that is passed to our redraw function
typedef struct {
	SGEARRAY *sprites;
} MainStateData;

// redraw the screen and update game logics, if any
void on_redraw(SGEGAMESTATE *state) {
	int i,n,collided;
	SpriteInfo *collider;
	SpriteInfo *spriteinfo;

	// prepare event and data variable form the gamestat passed to that
	// function
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;

	// has the user closed the window?
	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}

	// clear screen to black color
	sgeClearScreen();

	// loop through all sprites
	for (i=0;i<data->sprites->numberOfElements;i++) {
		// get the spriteinfo struct from the array
		spriteinfo=sgeArrayGet(data->sprites, i);

		// now move sprites and turn direction if the move over the screenborder
		spriteinfo->sprite->x+=spriteinfo->dirx;
		if ( (spriteinfo->dirx<0 && spriteinfo->sprite->x<0) || (spriteinfo->dirx>0 && spriteinfo->sprite->x>640-sgeSpriteWidth(spriteinfo->sprite)) ) {
			spriteinfo->dirx*=-1;
		}
		spriteinfo->sprite->y+=spriteinfo->diry;
		if ( (spriteinfo->diry<0 && spriteinfo->sprite->y<0) || (spriteinfo->diry>0 && spriteinfo->sprite->y>480-sgeSpriteHeight(spriteinfo->sprite)) ) {
			spriteinfo->diry*=-1;
		}

		// check collision against all other sprites...
		collided=0;
		for (n=0;n<data->sprites->numberOfElements&&collided==0;n++) {
			if (n!=i) { // ... except for itself
				collider=sgeArrayGet(data->sprites,n);
				if (sgeSpriteCollide(spriteinfo->sprite,collider->sprite)) {
					collided=1;
				}
			}
		}

		// if collided, turn direction and move in the new direction
		if (collided) {
			if (collider->sprite->x>spriteinfo->sprite->x) {
				spriteinfo->dirx=-1;
				collider->dirx=1;
			} else {
				spriteinfo->dirx=1;
				collider->dirx=-1;
			}
			if (collider->sprite->y>spriteinfo->sprite->y) {
				spriteinfo->diry=-1;
				collider->diry=1;
			} else {
				spriteinfo->diry=1;
				collider->diry=-1;
			}
			spriteinfo->sprite->x+=spriteinfo->dirx*2;
			spriteinfo->sprite->y+=spriteinfo->diry*2;
		}

		// finally draw the sprite
		sgeSpriteDraw(spriteinfo->sprite, screen);
	}

	// finally display the screen
	sgeFlip();
}

// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	SGEFILE *file;
	SpriteInfo *spriteinfo;

	MainStateData data;
	int x,y;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO,NOJOYSTICK);
	sgeOpenScreen("Basic SGE loop",640,480,32,NOFULLSCREEN);
	sgeHideMouse();

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	// now open the data file, encrypted with password 'asdf'
	// the datafile is built with 'make data'
	file=sgeOpenFile("data.d","asdf");

	data.sprites=sgeArrayNew();

	// we now create a array of sprites
	for (y=0;y<480;y+=48) {
		for (x=0;x<640;x+=48) {

			// we hold our data in a SpriteInfo struct
			sgeNew(spriteinfo, SpriteInfo);

			// load the sprite and set starting positions
			spriteinfo->sprite=sgeSpriteNewFile(file, "sprite.png");
			spriteinfo->sprite->x=x;
			spriteinfo->sprite->y=y;

			// update position for collision detection
			// handled automatically when drawing the sprite
			// but because we check for collision before drawing
			// we have to call this once
			sgeSpriteUpdatePosition(spriteinfo->sprite);

			// set random directions
			if (sgeRandom(0,1)) {
				spriteinfo->dirx=1;
			} else {
				spriteinfo->dirx=-1;
			}
			if (sgeRandom(0,1)) {
				spriteinfo->diry=1;
			} else {
				spriteinfo->diry=-1;
			}

			// finally add our SpriteInfo struct to our state data...
			sgeArrayAdd(data.sprites,(void *)spriteinfo);
		}
	}
	sgeCloseFile(file);

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// start the game running with 30 frames per seconds
	sgeGameStateManagerRun(manager, 30);

	// used quitted, so we have to clean up all of our data
	for (y=0;y<data.sprites->numberOfElements;y++) {
		// we get the first (!!) element, you have to get the first, because
		// later we will remove the current element and so the array will get
		// one element smaller
		spriteinfo=sgeArrayGet(data.sprites,0);
		sgeSpriteDestroy(spriteinfo->sprite); // destroy the sprite itself
		sgeFree(spriteinfo); // destroy the spriteinfo struct
		sgeArrayRemove(data.sprites,0); // remove the first (!!) element
	}
	// free the array itself
	sgeArrayDestroy(data.sprites);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}

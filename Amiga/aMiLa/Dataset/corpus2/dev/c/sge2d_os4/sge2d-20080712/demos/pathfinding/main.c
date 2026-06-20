/**
 *
 * This is a basic pathfinding demonstration
 *
 * we will generate a random maze and will try to
 * find the way from the lower left corner to the
 * upper right corner
 *
 * */

#include <sge.h>

#define STEP_X 16
#define STEP_Y 16

// define our data that is passed to our redraw function
typedef struct {
	SGEPATHFINDER *pathFinder;
	int found;
	SGEFONT *font;
	int leftStart;
	int rightStart;
	int disableDiagonal;
} MainStateData;

void doPathFind(MainStateData *data) {
	int x,y;

	// create a random pathfinder environment
	for (y=0;y<240/STEP_Y;y++) {
		for (x=0;x<320/STEP_X;x++) {
			if (sgeRandom(0,100)<30) {
				sgePathFinderSet(data->pathFinder,x,y,1);
			} else {
				sgePathFinderSet(data->pathFinder,x,y,0);
			}
		}
	}

	// set random startpoints left and right
	data->leftStart=sgeRandom(0,240/STEP_Y-1);
	data->rightStart=sgeRandom(0,240/STEP_Y-1);

	// ensure that start end endpoint are never blocked
	sgePathFinderSet(data->pathFinder,320/STEP_X-1,data->rightStart,0);
	sgePathFinderSet(data->pathFinder,0,data->leftStart,0);

	// now find the path, if possible
	data->found=sgePathFinderFind(data->pathFinder, 0, data->leftStart, 320/STEP_X-1, data->rightStart);
}

// redraw the screen and update game logics, if any
void on_redraw(SGEGAMESTATE *state) {
	int x,y;
	int xx=0,yy=0;
	SGEPATHFINDERINFO *pi;

	// prepare event and data variable form the gamestat passed to that
	// function
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;

	// has the user closed the window?
	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}
	// redraw on space/fire
	if (es.fire.pressed) {
		doPathFind(data);
		sgeClearScreen();
	}
	// toggle diagonal movement on m_key/y_button
	if (es.y.released) {
		data->disableDiagonal=(data->disableDiagonal+1)%2;
		sgePathFinderDiagonal(data->pathFinder, data->disableDiagonal);
		sgeClearScreen();
	}

	// print the maze
	yy=0;
	for (y=0;y<240;y+=STEP_Y) {
		xx=0;
		for (x=0;x<320;x+=STEP_X) {
			if (sgePathFinderGet(data->pathFinder,xx,yy)) {
				sgeFillRect(screen, x, y, STEP_X, STEP_Y, sgeMakeColor(0xff,0,0,0xff));
			}
			xx++;
		}
		yy++;
	}

	// print the path or a error message if no path was possible
	if (data->found) {
		for (x=0;x<data->pathFinder->path->numberOfElements;x++) {
			pi=sgeArrayGet(data->pathFinder->path, x);
			sgeFillRect(screen, pi->x*STEP_X, pi->y*STEP_Y, STEP_X, STEP_Y, sgeMakeColor(0,0xff,0,0xff));
		}
	} else {
		sgeFontPrintBitmap(data->font, screen, 10, 10, "No possible solution");
	}
	// print start/end point in extra colors
	sgeFillRect(screen, 0, data->leftStart*STEP_Y, STEP_X, STEP_Y, sgeMakeColor(0xff,0,0xff,0xff));
	sgeFillRect(screen, 320-STEP_X, data->rightStart*STEP_Y, STEP_X, STEP_Y, sgeMakeColor(0xff,0,0xff,0xff));

	if (data->disableDiagonal==ENABLE_DIAGONAL) {
		sgeFontPrintBitmap(data->font, screen, 10, 200, "m - Toggle diagonal - on");
	} else {
		sgeFontPrintBitmap(data->font, screen, 10, 200, "m - Toggle diagonal - off");
	}
	sgeFontPrintBitmap(data->font, screen, 10, 220, "space - Redraw");
	// finally display the screen
	sgeFlip();
}


// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEFILE *f;
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

	// create the pathfinder
	data.pathFinder=sgePathFinderNew(320/STEP_X,240/STEP_Y);

	// enable diagonal movement by default
	data.disableDiagonal=ENABLE_DIAGONAL;

	// generate maze and find path of random start/end points
	doPathFind(&data);

	// load the bitmap font from the data file
	f=sgeOpenFile("data.d","asdf");
	data.font=sgeFontNewFile(f, SGEFONT_BITMAP, "font.png");
	sgeCloseFile(f);

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// start the game running with 30 frames per seconds
	sgeGameStateManagerRun(manager, 30);

	// clean up
	sgePathFinderDestroy(data.pathFinder);
	sgeFontDestroy(data.font);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}

/**
 *
 * This is a basic demonstration of sprite animbanks
 *
 * Move the cursor to move the figure
 * */

#include <sge.h>

// define our data that is passed to our redraw function
typedef struct {
	SGESPRITE *player;
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

	sgeFillRect(screen, 0,0,320,240,sgeMakeColor(0x40,0x40,0x40,0xff));

	// check if we need to change the animbank and restart animation
	if (es.down.pressed) {
		sgeSpriteSetAnimBank(data->player, 0);
		sgeSpriteAnimate(data->player, YES);
	}
	else if (es.left.pressed) {
		sgeSpriteSetAnimBank(data->player, 1);
		sgeSpriteAnimate(data->player, YES);
	}
	else if (es.up.pressed) {
		sgeSpriteSetAnimBank(data->player, 2);
		sgeSpriteAnimate(data->player, YES);
	}
	else if (es.right.pressed) {
		sgeSpriteSetAnimBank(data->player, 3);
		sgeSpriteAnimate(data->player, YES);
	}

	// move the player
	if (es.down.held) {
		data->player->y+=2;
	}
	else if (es.right.held) {
		data->player->x+=2;
	}
	else if (es.left.held) {
		data->player->x-=2;
	}
	else if (es.up.held) {
		data->player->y-=2;
	} else {
		// stop animation if no key is held
		sgeSpriteAnimate(data->player, NO);
		// display frame 3, a more standing like frame
		sgeSpriteForceFrame(data->player, 3);
	}
	
	sgeSpriteDraw(data->player, screen);

	// finally display the screen
	sgeFlip();
}

// this is the main function, you don't use main(), as this is handled different
// on some platforms
int run(int argc, char *argv[]) {
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	SGEFILE *f;
	MainStateData data;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO,NOJOYSTICK);
	sgeOpenScreen("SGE Sprite AnimBanks",320,240,32,NOFULLSCREEN);
	sgeHideMouse();

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	// read spritedata
	f=sgeOpenFile("data.d","asdf");

	data.player=sgeSpriteNew();

	// load files 0001-0010 to first animbank (walking down)
	sgeSpriteAddFileRange(data.player,f,"data/animbanks_%04d.png", 1, 10);

	// load 0011-0020 to a new anim bank (walking left)
	sgeSpriteAddAnimBank(data.player);
	sgeSpriteAddFileRange(data.player,f,"data/animbanks_%04d.png", 11, 20);

	// load 0021-0030 to a new anim bank (walking up)
	sgeSpriteAddAnimBank(data.player);
	sgeSpriteAddFileRange(data.player,f,"data/animbanks_%04d.png", 21, 30);

	// load 0031-0040 to a new anim bank (walking right)
	sgeSpriteAddAnimBank(data.player);
	sgeSpriteAddFileRange(data.player,f,"data/animbanks_%04d.png", 31, 40);

	sgeCloseFile(f);

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

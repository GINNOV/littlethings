#include <sge.h>

typedef struct {
	SGESPRITE *testimage;
	SGESPRITE *testcollider;
	SGESPRITE *testanim;
	SGESPRITEGROUP *colliders;
	SGESPRITEGROUP *players;
	SGESTAGE *stage;
	SGEFONT *font;
	float zoom;
	float rotation;
} MainStateData;

void on_redraw(SGEGAMESTATE *state)
{
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;
	// int x;
	// int y;
	Uint32 col = sgeMakeColor(30,30,30,0x20);
	Uint32 collcol = sgeMakeColor(30,0,0,0x20);

	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}

	if (es.down.held) data->testimage->y+=2;
	if (es.up.held) data->testimage->y-=2;
	if (es.left.held) data->testimage->x-=2;
	if (es.right.held) data->testimage->x+=2;

	data->testimage->x = MINMAX(data->testimage->x, 0, screen->w-sgeSpriteWidth(data->testimage)-1);
	data->testimage->y = MINMAX(data->testimage->y, 0, screen->h-sgeSpriteHeight(data->testimage)-1);

	data->stage->cameraX=data->stage->w*(double)((double)data->testimage->x/(double)(screen->w-sgeSpriteWidth(data->testimage)));
	data->stage->cameraY=data->stage->h*(double)((double)data->testimage->y/(double)(screen->h-sgeSpriteHeight(data->testimage)));

	sgeStageDrawLayer(data->stage, screen, 0);

	sgeLock(screen);
	sgeDrawLine(screen, 0, 0, data->testimage->x, data->testimage->y, col);
	sgeDrawLine(screen, 0, 0, data->testimage->x, data->testimage->y+10, col);
	sgeDrawLine(screen, 0, 0, data->testimage->x, data->testimage->y+20, col);
	sgeDrawLine(screen, 0, 0, data->testimage->x, data->testimage->y+30, col);
	sgeDrawLine(screen, 0, 0, data->testimage->x, data->testimage->y+40, col);
	sgeUnlock(screen);

	if (sgeStageSpriteGroupCollideSpriteGroup(data->stage, 1, 0, RELATIVE)) {
		sgeFillRect(screen,1,0,100,100,collcol);
	}

	sgeStageDrawSpriteGroup(data->stage, 0);
	sgeSpriteGroupDraw(data->players);

	sgeStageDrawLayer(data->stage, screen, 1);

	sgeFontPrint(data->font, screen, 10, screen->h-sgeFontGetLineHeight(data->font)-10, "Hello World");

	sgeSpriteDrawRotoZoomed(data->testimage, data->rotation, data->zoom, screen);
	data->rotation+=.02;
	data->zoom+=.005;

	sgeFlip();
}

int run(int argc, char *argv[]) {

	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	SGEFILE *tmp;
	// SGESOUND *mus;
	MainStateData data;

	sgeInit(NOAUDIO,JOYSTICK);
	sgeOpenScreen("SGE libtest",320,240,32,NOFULLSCREEN);
	sgeHideMouse();

	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->data = &data;

	data.colliders=sgeSpriteGroupNew();
	data.players=sgeSpriteGroupNew();

	data.stage=sgeStageNew(640, 480);
	sgeStageAddSpriteGroup(data.stage, data.colliders);
	sgeStageAddSpriteGroup(data.stage, data.players);
	data.testanim=sgeSpriteNew();
	sgeSpriteSetFPS(data.testanim,20);
	tmp=sgeOpenFile("data.d","asdf");
	data.testimage=sgeSpriteNewFile(tmp, "data/ice0001.png");
	sgeStageAddLayer(data.stage, sgeSpriteNewFile(tmp, "data/winterbackground.png"), 0, 0);
	sgeStageSetLayerHeight(data.stage, sgeStageAddLayer(data.stage, sgeSpriteNewFile(tmp, "data/winterlands.png"), 0, 240), 800);
	data.testcollider=sgeSpriteNewFile(tmp, "data/ice0010.png");
	sgeSpriteAddFileRange(data.testanim, tmp, "data/ice%04d.png", 1, 20);
	sgeSpriteGroupAddSprite(data.colliders,sgeSpriteNewFileRange(tmp, "data/ice%04d.png", 1, 20));
	// mus=sgeSoundNew(tmp, "data/KDE_Logout_1.ogg");

	data.font=sgeFontNewFile(tmp, SGEFONT_BITMAP, "data/font.png");

	sgeCloseFile(tmp);

	sgeSpriteAddWayPoint(data.testcollider, 100, 200);
	sgeSpriteAddWayPoint(data.testcollider, 100, 0);
	sgeSpriteAddWayPoint(data.testcollider, 0, 200);
	sgeSpriteAddWayPoint(data.testcollider, 200, 100);
	sgeSpriteAddWayPoint(data.testcollider, 200, 200);

	sgeSpriteGroupAddSprite(data.colliders, data.testcollider);
	sgeSpriteGroupAddSprite(data.players, data.testimage);

	data.zoom=0.1;
	data.rotation=0.1;


	// sgeSoundPlay(mus, LOOP, 4000);
	// data.testcollider->x=(screen->w>>1)-(sgeSpriteWidth(data.testcollider)>>1);
	// data.testcollider->y=(screen->h>>1)-(sgeSpriteHeight(data.testcollider)>>1);

	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);
	sgeSpriteStartMovement(data.testcollider, 2);
	sgeGameStateManagerRun(manager, 30);

	sgeStageDestroy(data.stage);
	sgeCloseScreen();
	return 0;
}

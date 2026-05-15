#ifndef STRUCTURES_H 
#define STRUCTURES_H 
 
struct collected { 
  UBYTE coal; 
  UBYTE excesscoal; 
  UBYTE capacitors; 
  UBYTE robboMsgCount; 
};

struct moveControls { 
  BOOL stoneHit; 
  BOOL frameHit; 
  UBYTE anotherHit; // sprawdzam czy po uderzeniu w kamien chce jeszcze raz, zeby sie HUD 2 razy nie rozwijal 
  UBYTE kierunek;  
  UBYTE kierunekHold; 
}; 

struct coordinates { // coordsy do rysowania falkona i kontrolowania zeby sie nie wypierdolil za ekran
  UBYTE falkonx;
  UBYTE falkony; // pozycja falkona na tablicy z tilesami 32x32
  UBYTE falkonFace; // kierunek dziobem
  BYTE krawedzx; // do sprawdzania czy chcemy wyleciec za ekran, BYTE - ze znakiem bo moze byc -1
  BYTE krawedzy;
};

struct stateControls {   // checking the states of different 
  BOOL falkonIdleControl;    // elements and situations
  UBYTE flyingAnimControl;   // to handle them correctly
  BOOL stonehitAnimControl;
  BOOL hudScrollingControl; // check hud up/down and what to do next
  UBYTE levelScoreControl;
  UBYTE youWin;  // bad naming - check which ending/gameover to proceed
  UBYTE robboMsgCtrl; // checks if theres a need for scrolling hud etc.
}; 

struct anim {       // variables for handling animation
  UBYTE robboFrame; // of various elements on screen
  UBYTE robboTick;
  UBYTE robboTempo;

  UBYTE portalGlowTick;
  UBYTE portalGlowFrame; 
  UBYTE portalGlowX;
  UBYTE portalGlowY;
  UBYTE portalTickTempo;

  UBYTE redCapacitorsAnimTileCheck;
  UBYTE redCapacitorsAnimTick;
  UBYTE blueCapacitorsAnimTileCheck; 
  UBYTE blueCapacitorsAnimTick;
  UBYTE tickTempo;

  UBYTE stonehitAnimTick;
  UBYTE stonehitAnimFrame;

  UBYTE flyingTick;
  UBYTE flyingFrame;

  UBYTE falkonIdle;
  UBYTE idleFrame;
  UBYTE falkonIdleTempo;

  UBYTE hudScrollingTick; // scrolling up/down on Robbo & ESP tick

  UBYTE hudTickTempo;  // amiga mode hud animation variables
  UBYTE hudAnimTick;
  UBYTE hudTickFrame;

  BYTE levelScoreTick;
  UBYTE levelAnimFrame;
  UBYTE levelScoreTempo;
}; 

struct flyingAnim { 
  // bad naming, but these are variables for drawing flying animation
  // frame by frame moving per pixel:
  // drawing Background on previous position, then
  // drawing animation tile on the new position
  UWORD uwPosX;
  UWORD uwPosY;
  UWORD uwPreviousX;
  UWORD uwPreviousY;
  UWORD newPosX;
  UWORD newPosY;
  UWORD HitPosX;
  UWORD HitPosY;
  UBYTE tempX;   // remember to use meaningful names next time ! !
  UBYTE tempY;   // lesson learned ... 

};

struct misc { // other but important variables
  UBYTE level;
  UBYTE doubleBufferFrameControl;
  UBYTE audioFadeIn;
  UBYTE robboMsgNr;
  UBYTE HUDfontColor; //23
  UBYTE HUDcollisionMsg;
  UBYTE holdLastLevelForContinue;
};

struct db // handling double buffer, if true then will be drawn again in next frame
{
  BOOL robbo;
  BOOL hudAnimDB;
  BOOL levelScoreDB;
  BOOL portalGlowDB;   
};

#endif // STRUCTURES_H 
#include "game.h"
#include "states.h"
#include "mystdlib.h"
#include <ace/managers/key.h>
#include <ace/managers/game.h>
#include <ace/managers/system.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/blit.h> // Blitting fns
#include <ace/managers/state.h>
#include <ace/managers/rand.h>
#include <ace/managers/sprite.h>
#include <ace/utils/file.h>
#include <ace/utils/font.h>
#include <ace/utils/string.h>
#include <ace/utils/palette.h>
#include <mini_std/stdio.h>

#define false 0
#define true 1
#define SCORE_COLOR 1
#define WALL_HEIGHT 1
#define WALL_COLOR 1
#define PADDLE_SPEED 2
#define MAXPIPES 4
#define MAXBIRDS 5
#define BIRD_BG_BUFFER_WIDTH 32//CEIL_TO_FACTOR(16,16)
//-------------------------------------------------------------- NEW STUFF START
//AMiga Pal 320x256
#define PLAYFIELD_HEIGHT (256-32) //32 for the top viewport height
#define PLAYFIELD_WIDTH (320)

static tView *s_pView; // View containing all the viewports
static tVPort *s_pVpScore; // Viewport for score
static tSimpleBufferManager *s_pScoreBuffer;
static tVPort *s_pVpMain; // Viewport for playfield
static tSimpleBufferManager *s_pMainBuffer;
static tRandManager *s_pRandManager;

static tBitMap *s_pBmBirds[MAXBIRDS];
static tBitMap *s_pBmBirdMask[MAXBIRDS];
static tBitMap *s_pSpriteTopData[MAXPIPES];
static tBitMap *s_pSpriteBottomData[MAXPIPES];
static tBitMap *s_pSpriteSrc;
static tBitMap *pBmBackground;
static tBitMap *s_pBmBirdMaskImage[2];

static UBYTE s_hasBGToRestore[2];

static tSprite *s_pSpriteTop[MAXPIPES];//sprites for the top and bottom, one of each for each upto maxpipes
static tSprite *s_pSpriteBottom[MAXPIPES];
g_obj player; //player object declaration

tFont *fallfontsmall; //global for font
tTextBitMap *scoretextbitmap;//global for score text

//game vars
char scorebuffer[20];
int gSCORE = 0;
int g_highScore = 0; //needs to be assigned prior to initialization
short pipesdisplay = 1;
short birdplay = 0;
short pipestart = 320; //set to 320 so the pipes start off field.

ULONG startTime;
UBYTE g_scored = false;

//arrays holding previous positions of the player and pipes
tUwCoordYX s_pPlayerPrevPos[2];

UBYTE s_ubBufferIndex = 0;

void gameGsCreate(void) {
  tRayPos sRayPos = getRayPos();

  s_pRandManager = randCreate(1+(sRayPos.bfPosY << 8), 1 + sRayPos.bfPosX);

  s_pView = viewCreate(0,TAG_VIEW_GLOBAL_PALETTE, 1,TAG_END);
  
  // Viewport for score bar - on top of screen
  s_pVpScore = vPortCreate(0,
    TAG_VPORT_VIEW, s_pView,
    TAG_VPORT_BPP, 4,
    TAG_VPORT_HEIGHT, 32,
  TAG_END);
  s_pScoreBuffer = simpleBufferCreate(0,
    TAG_SIMPLEBUFFER_VPORT, s_pVpScore,
    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR,
  TAG_END);

  // Now let's do the same for main playfield
  s_pVpMain = vPortCreate(0,
    TAG_VPORT_VIEW, s_pView,
    TAG_VPORT_BPP, 4,
  TAG_END);
    s_pMainBuffer = simpleBufferCreate(0,
    TAG_SIMPLEBUFFER_VPORT, s_pVpMain,
    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_INTERLEAVED,
    TAG_SIMPLEBUFFER_IS_DBLBUF, 1, //add this line in for double buffering
    TAG_END);

  paletteLoad("data/flappypal6.plt", s_pVpScore->pPalette, 32); //replaces palette
  
  pBmBackground = bitmapCreateFromFile("data/background.bm",0);//load the background
  
  for(UWORD x = 0; x < s_pMainBuffer->uBfrBounds.uwX; x+=16){//fills out the background
    for(UWORD y = 0; y < s_pMainBuffer->uBfrBounds.uwY; y+=16){
      blitCopyAligned(pBmBackground,x,y,s_pMainBuffer->pBack,x,y,16,16);
      blitCopyAligned(pBmBackground,x,y,s_pMainBuffer->pFront,x,y,16,16);
    }
  }
  //bitmapDestroy(pBmBackground);
  spriteManagerCreate(s_pView, 0);
  systemSetDmaBit(DMAB_SPRITE, 1);
 
  // Draw line separating score VPort and main VPort, leave one line blank after it
  blitLine(
    s_pScoreBuffer->pBack,
    0, s_pVpScore->uwHeight - 2,
    s_pVpScore->uwWidth - 1, s_pVpScore->uwHeight - 2,
    SCORE_COLOR, 0xFFFF, 0 // Try patterns 0xAAAA, 0xEEEE, etc.
  );

  gSCORE = 99999999;  //set to 99999999 so the bitmap is big enough to handle larger numbers
  //g_highScore = 0; //getHighScore();  //get the highscore from the file, returning zero if no file
  char i_highScore[20]; //buffer string to hold the highscore
  stringDecimalFromULong(g_highScore, i_highScore); //convert to short

  fallfontsmall = fontCreate("myacefont.fnt");//create font

  tTextBitMap *highscorebitmap = fontCreateTextBitMapFromStr(fallfontsmall, "High Score ");//create the bitmap with HIGHSCORE
  fontDrawTextBitMap(s_pScoreBuffer->pBack, highscorebitmap, 0,10, 5, FONT_COOKIE); //draw the text
  highscorebitmap = fontCreateTextBitMapFromStr(fallfontsmall, i_highScore);  //reuse the bitmap from writing the highscore text  
  fontDrawTextBitMap(s_pScoreBuffer->pBack, highscorebitmap, 73,10, 5, FONT_COOKIE); //write out the highscore

  tTextBitMap *textbitmap = fontCreateTextBitMapFromStr(fallfontsmall, "Score ");
  fontDrawTextBitMap(s_pScoreBuffer->pBack, textbitmap, 0,20, 5, FONT_COOKIE);
  
  //convert the score from int to string for drawing
  stringDecimalFromULong(gSCORE, scorebuffer);
  scoretextbitmap = fontCreateTextBitMapFromStr(fallfontsmall, scorebuffer); //redo bitmap
  gSCORE = 0;
  
  startTime = timerGet();
  
  //placeholder for player
  player.x = 35;
  player.y = (s_pVpMain->uwHeight - player.h) / 2;
  player.w = 15;
  player.h = 12;
  player.yvel = 2;

  s_pBmBirdMaskImage[0] = bitmapCreate(BIRD_BG_BUFFER_WIDTH, player.h,4,0);
  s_pBmBirdMaskImage[1] = bitmapCreate(BIRD_BG_BUFFER_WIDTH, player.h,4,0);
  s_hasBGToRestore[0] = 0;
  s_hasBGToRestore[1] = 0;
  //create first batch of pipes to fill the array
  makebirds();//make the bitmaps for the frames
  makePipes();
  for (short i = 0; i < MAXPIPES; i++) {
    short pos = randUwMinMax(s_pRandManager, 62, 150); //recalculate position and the gap between pipes(range)
    short range = randUwMinMax(s_pRandManager, 66, 96);
  
    //top pipes intionlistion
    s_pSpriteTop[i]->wY = 32;
    UWORD uwHeight = (s_pSpriteTop[i]->wY + pos - (range / 2)) - s_pSpriteTop[i]->wY;
  
    blitCopy(
    s_pSpriteSrc,0,s_pSpriteSrc->Rows - uwHeight,
    s_pSpriteTopData[i],0,0,
    16, uwHeight, MINTERM_COOKIE
    );
    s_pSpriteTop[i]->uwHeight = uwHeight;
    s_pSpriteTop[i]->wX = pipestart;
    //bottompipe
    s_pSpriteBottom[i]->wX = pipestart;
    s_pSpriteBottom[i]->wY = pos + (range / 2);
    s_pSpriteBottom[i]->uwHeight = (256 - s_pSpriteBottom[i]->wY);

    spriteSetEnabled(s_pSpriteTop[i],0); //disable the sprite so it doesn't show.
    spriteSetEnabled(s_pSpriteBottom[i],0);
  }

  systemUnuse();
  // Load the view
  viewLoad(s_pView);
}

/*The following is a breakdown of the logic of the collides() function:
The first condition checks if the x-coordinate of the first block is less than the x-coordinate of the second block plus the width of the second block. This ensures that the first block is not to the right of the second block.
The second condition checks if the x-coordinate of the first block plus the width of the first block is greater than the x-coordinate of the second block. This ensures that the first block is not to the left of the second block.
The third condition checks if the y-coordinate of the first block is less than the y-coordinate of the second block plus the height of the second block. This ensures that the first block is not above the second block.
The fourth condition checks if the y-coordinate of the first block plus the height of the first block is greater than the y-coordinate of the second block. This ensures that the first block is not below the second block.
If all of these conditions are met, then the two blocks collide.*/
//collision detection function takes a player object and a sprite object and return if there is a collision. 14 is the 'width' of the sprite
UBYTE CollisionTop(g_obj *a, tSprite b){
    return (a->x < b.wX + 14 && 
          a->x + a->w > b.wX && 
          a->y < b.wY + (b.uwHeight - 32) && //32 is subtracted since the sprites(for toppipe) start from Y = 0 not The viewport height which is 32.
          a->y + a->h > b.wY);
}
UBYTE CollisionBottom(g_obj *a, tSprite b){
    return (a->x < b.wX + 14 && 
          a->x + a->w > b.wX && 
          a->y < b.wY + b.uwHeight && 
          a->y + a->h > (b.wY - 32)); //something about 32 on the low pipe Y was causing issues with the collision detection
}

void gameGsLoop(void) {
  // This will loop every frame
  if(keyCheck(KEY_ESCAPE)) {
    gameExit();
  }
  for (short int i = 0; i <pipesdisplay; i++) {//enables only the active sprites so they don;t stack at the startpoint.
    spriteSetEnabled(s_pSpriteTop[i],1);
    spriteSetEnabled(s_pSpriteBottom[i],1);
  }
  //activates the sprite channels.
  for(short j = 0; j < MAXPIPES; j++) {//does this need to hapopen every loop?
     //process each sprite
    spriteProcess(s_pSpriteTop[j]);
    spriteProcess(s_pSpriteBottom[j]); //
    spriteProcessChannel(j * 2);
    spriteProcessChannel(j * 2 + 1);
  }
  //undraw player
  if(s_hasBGToRestore[s_ubBufferIndex]){//this saves the background under the player syncing up with the double buffer system
    blitCopy(s_pBmBirdMaskImage[s_ubBufferIndex],0,0,
    s_pMainBuffer->pBack,s_pPlayerPrevPos[s_ubBufferIndex].uwX,s_pPlayerPrevPos[s_ubBufferIndex].uwY,
    player.w,player.h, MINTERM_COOKIE);
  }
 
  //**Move things accross*8

  for (short i = 0; i < pipesdisplay; i++) {
      if(s_pSpriteTop[i]->wX <=-16 || s_pSpriteBottom[i]->wX <=-16){//neg 16 so it's off screen. Since they are sprites it can be drawn 'off screen'
        short pos = randUwMinMax(s_pRandManager, 62, 150); //recalculate position and the gap between pipes(range)
        short range = randUwMinMax(s_pRandManager, 66, 96);
       
        spriteSetEnabled(s_pSpriteTop[i],0);//unenable the sprite
        spriteSetEnabled(s_pSpriteBottom[i],0);
       
        s_pSpriteTop[i]->wY = 32;
        UWORD uwHeight = (s_pSpriteTop[i]->wY + pos - (range / 2)) - s_pSpriteTop[i]->wY;
        blitCopy(
        s_pSpriteSrc,0,s_pSpriteSrc->Rows - uwHeight,
        s_pSpriteTopData[i],0,0,
        16, uwHeight, MINTERM_COOKIE
        );
        s_pSpriteTop[i]->uwHeight = uwHeight;
        s_pSpriteTop[i]->wX = pipestart;

        //bottompipe
        s_pSpriteBottom[i]->wX = pipestart;
        s_pSpriteBottom[i]->wY = pos + (range / 2);
        s_pSpriteBottom[i]->uwHeight = (256 - s_pSpriteBottom[i]->wY);

        spriteSetEnabled(s_pSpriteTop[i],1);
        spriteSetEnabled(s_pSpriteBottom[i],1);

        //add to scoreboard
        g_scored = true;
      }

      else {//move the pipes across the playfield
        s_pSpriteTop[i]->wX -= 1;
        s_pSpriteBottom[i]->wX -= 1;
      }
      //if the player touches a pipe
      if(CollisionTop(&player, *s_pSpriteTop[i]) || CollisionBottom(&player, *s_pSpriteBottom[i])){ //true set for toppie to sub 32 for the starting y value.
        systemSetDmaBit(DMAB_SPRITE, 0);//disable srpties
        for (short i=0; i < MAXPIPES; i++) {//move them offscreen *This is done so junk data doesn't affect the menu screen
          s_pSpriteTop[i]->wX = -16;
          s_pSpriteBottom[i]->wX = -16;
        }
        stateChange(g_pStateManager, g_pMenuState); //switch to the menu state to ask to replay
        //need to destroy the sprites and data
        lightHighScoreCheck(); //check the HS and write if required
        pipesdisplay = 1; //reset the pipedisplay to 1 so on reply not all pipes are spawned
        //trashGFX();
        return;
      }
  }

  //controls
  if(keyCheck(KEY_SPACE)){  //move player up
    player.y = MAX(player.y - PADDLE_SPEED, 0);
    birdplay++; //run the animation
  }
  else{
    player.y = MIN(player.y + player.yvel , 210);
    birdplay = 4; //set the bird to wings down for falling
  }
 
  //this is done here, since the player has been undrawn, so we want to swap the player frame while it's undrawn
  if(birdplay == MAXBIRDS) birdplay = 0; //reset animation loop back to 0
  
  //save BG under bird
  blitCopy(s_pMainBuffer->pBack,player.x,player.y,
  s_pBmBirdMaskImage[s_ubBufferIndex],0,0,
  player.w,player.h, MINTERM_COOKIE);
  s_hasBGToRestore[s_ubBufferIndex] = 1;

   //**Draw things**
  //update the previous position array
  s_pPlayerPrevPos[s_ubBufferIndex].uwX = player.x;
  s_pPlayerPrevPos[s_ubBufferIndex].uwY = player.y;

  // Redraw the player at new position
  blitCopyMask(
  s_pBmBirds[birdplay],0,0,//copy the mask from the birdmask pos 0,0 to the main buffer at player.x/y
  s_pMainBuffer->pBack,player.x,player.y, 
  player.w, player.h,s_pBmBirdMask[birdplay]->Planes[0]);

  //timer handling the pipes being spawned, reset to 1 at game reset
  ULONG currentTime = timerGet();
  if (currentTime - startTime > randUwMinMax(s_pRandManager, 60, 222) && pipesdisplay < MAXPIPES) {//timer is frames since starttime which is 1/50 of a second.
      pipesdisplay++;
      startTime = currentTime;
  }

  if(g_scored){//if the player scores, update the score board. 
    g_scored = false;
    updateScore();
  }
  //update the index
  s_ubBufferIndex = !s_ubBufferIndex;
  viewProcessManagers(s_pView);//might be wrong
  copProcessBlocks();
  systemIdleBegin();
  vPortWaitUntilEnd(s_pVpMain);
  //vPortWaitForEnd(s_pVpMain);
  systemIdleEnd();
  }

void gameGsDestroy(void) {
  logBlockBegin("gameGsDestroy");
  systemUse();
  for(short int i = 0; i < MAXBIRDS; i++){
    bitmapDestroy(s_pBmBirdMask[i]);
    bitmapDestroy(s_pBmBirds[i]);
  }
  for (short k = 0; k < 2; k++){
    bitmapDestroy(s_pBmBirdMaskImage[k]);
  }
  
  bitmapDestroy(pBmBackground);
  systemSetDmaBit(DMAB_SPRITE, 0);
  spriteManagerDestroy();
  // This will also destroy all associated viewports and viewport managers
  viewDestroy(s_pView);
  logBlockEnd("gameGsDestroy");
}

void updateScore(void) {  //bug seems to appear where text for 10000 + seems to be erroring with: ERR: Text '10000' doesn't fit in text bitmap, text needs: 33,8, bitmap size: 32,8
    gSCORE = gSCORE + 100;  //add score
    stringDecimalFromULong(gSCORE, scorebuffer);
    blitRect(s_pScoreBuffer->pBack, 40, 20, scoretextbitmap->uwActualWidth, scoretextbitmap->uwActualHeight, 0); //erase scorebuffer
    fontFillTextBitMap(fallfontsmall, scoretextbitmap, scorebuffer);//refill
    fontDrawTextBitMap(s_pScoreBuffer->pBack, scoretextbitmap, 40,20, 6, FONT_COOKIE);  //draw
}
// void trashGFX(){//trashes all the bitmaps and sprites after a game is fin ** not qwuite working the way i thought
//   systemUse();
//   for(short int i = 0; i < MAXBIRDS; i++){
//     bitmapDestroy(s_pBmBirdMask[i]);
//     bitmapDestroy(s_pBmBirds[i]);
//   }
//   for(short j = 0; j < MAXPIPES; j++){
//     spriteRemove(s_pSpriteTop[j]);
//     spriteRemove(s_pSpriteBottom[j]);
//   }
//   bitmapDestroy(s_pBmBirdMaskImage);
//   bitmapDestroy(pBmBackground);
//   systemSetDmaBit(DMAB_SPRITE, 0);
//   spriteManagerDestroy();
//   systemUnuse();
// }

void lightHighScoreCheck(void) {//session based HS keeping until file system stuff cna be sorted.
  if(g_highScore < gSCORE) g_highScore = gSCORE;
}

// void highScoreCheck(void) {
//   int score = gSCORE;
//   char charScore[30];
//   char filename[20] = "scoresheet.txt";
//   systemUse();

//   if(!fileExists(filename)){  //check if the file exists, if not create and add the score
//       tFile *file = fileOpen(filename, "w");
//       stringDecimalFromULong(score,charScore);
//       fileWriteStr(file, charScore);//add the score to the file 
//       fileClose(file); 
//   }
//   else{//if file exsits, read the score chec against the player score, if greater write to file else do nothing
//     short tScore = g_highScore; //since the highscore should be pulled in at the start, no need to call it again
//     //function to return highest score in the file.
//    // logWrite("TScore Is: %d\n", tScore);

//     if(score > tScore){//if score is greater than the current HS then add it to the end.
//       tFile *file = fileOpen(filename, "wb");
//       stringDecimalFromULong(score,charScore);
//       fileWriteStr(file,charScore);
//       fileWriteStr(file, ","); //using comma to seperate the scores
//       fileClose(file);
//     }
//   }
//   systemUnuse();
// }
// //reads through the scoresheet to find the highest score and returns that to compare it with the current score by the player
// short getHighScore(void){
//   int highScore = 0;
//   char filename[20] = "scoresheet.txt";
//   systemUse();
  
//   if((!fileExists(filename))){
//     systemUnuse();
//     return 0; //return 0 if the file does not exist
//   } 

//   tFile *file = fileOpen(filename, "r");
//   if(!file) {
//     systemUnuse();
//     return 102; //set to 2 so i know it was a cope out
//   }

//   char tline[512];
//   while(fgets(tline, 512, file)){//issues getting the tokens into the array of lines
//     char *token = strtok(tline, ",");
//     while(token){
//       //logWrite("File Reading: %s\n", token); 
//       int tScore = strtol(token, &token, 10);  //convert to short //why is this returning zero?
//       if(tScore > highScore) highScore = tScore;  //if the read score is > than the HS then overwirte it.
//       token = strtok(NULL, "\n");
//       if(token == NULL) break;
//     }
//   }
  
//   fileClose(file);
//   systemUnuse();
//   return highScore; //return the Highest found score.
//   /*In Theory the last int he file should be the highest if this works correctly. This could get resource intensive if a person has hundreds of High scores*/
// }

void makebirds(void){
  //s_pBmBird = bitmapCreate(16,12,4,0); //16px wide, 12 high
  s_pBmBirds[0] = bitmapCreateFromFile("data/birdt1.bm",0);
  s_pBmBirdMask[0] = bitmapCreateFromFile("data/birdt1_mask.bm", 0);
  s_pBmBirds[1] = bitmapCreateFromFile("data/birdt2.bm",0);
  s_pBmBirdMask[1] = bitmapCreateFromFile("data/birdt2_mask.bm", 0);
  s_pBmBirds[2] = bitmapCreateFromFile("data/birdt3.bm",0);
  s_pBmBirdMask[2] = bitmapCreateFromFile("data/birdt3_mask.bm", 0);
  s_pBmBirds[3] = bitmapCreateFromFile("data/birdt4.bm",0);
  s_pBmBirdMask[3] = bitmapCreateFromFile("data/birdt4_mask.bm", 0);
  s_pBmBirds[4] = bitmapCreateFromFile("data/birdt5.bm",0);
  s_pBmBirdMask[4] = bitmapCreateFromFile("data/birdt5_mask.bm", 0);
}

void makePipes(void) {
  s_pSpriteSrc = bitmapCreateFromFile("data/fullpipe.bm",0);
  for(short i = 0; i < MAXPIPES; i++){
    s_pSpriteTopData[i] = bitmapCreate(16,185,2,BMF_INTERLEAVED);//112 is the half hieght of the screen and the max size of the sprite.
    s_pSpriteTop[i] = spriteAdd(i * 2,s_pSpriteTopData[i]);//top //i is the channel number, they are in pairs upto 3 pairs. On paper it's four pairs but in reality no.
    
    s_pSpriteBottomData[i] = bitmapCreateFromFile("data/fullpipe.bm",0);
    s_pSpriteBottom[i] = spriteAdd(i * 2 + 1,s_pSpriteBottomData[i]);//bottom
  }
}

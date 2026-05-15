#include <graphics/view.h>
#include "iff.h"
#include "GameParam.h"

extern UWORD LunarCMap[32];
extern struct ViewPort VPort;


struct SpriteImage AlienShip[NUMALIENSHAPES];

extern UWORD LoadingColors[32];

#include <hardware/custom.h>
#include <hardware/dmabits.h>

struct SpriteImage LoadingScreen;
struct SpriteImage Stuff1Image;
struct SpriteImage Spare1Image;
struct SpriteImage Spare2Image;
struct SpriteImage Spare3Image;
struct SpriteImage Spare4Image;
struct SpriteImage Spare5Image;
struct SpriteImage Spare6Image;
struct SpriteImage Spare7Image;
struct SpriteImage Spare8Image;
struct SpriteImage Spare9Image;
struct SpriteImage Spare10Image;
struct SpriteImage Spare11Image;
struct SpriteImage Spare12Image;

struct SpriteImage FaceImage;
struct SpriteImage FireBall_16;
struct SpriteImage PanelImage;
struct SpriteImage EyeImage;
struct SpriteImage DeadEyeImage;
struct SpriteImage SpitBugImage;
struct SpriteImage BugBornLeft;
struct SpriteImage BugBornRight;
struct SpriteImage SqueezyVBug;
struct SpriteImage SqueezyHBug;
struct SpriteImage SweepMissileImage;
struct SpriteImage AlienBulletImage;
struct SpriteImage TurretShape;
struct SpriteImage TokenImage;
struct SpriteImage JustMe;/* This is the good guy */
struct SpriteImage ScrollScreen;
struct SpriteImage ExplosionImage[2];
struct SpriteImage BonusDigits;
struct SpriteImage ScreenMask;
struct SpriteImage ClockWork;

UWORD PanelColors[32];
extern struct LevelBlock *CurrentLevel;

/*****************************************************
 * This routine loads auxillary screens              *
 ******************************************_-=BN=-_**/
 
void LoadSideScreens()
{
  LoadImages("Stuff-1",&Stuff1Image,NULL);
  LoadImages("LoadingScreen",&LoadingScreen,LoadingColors);
  LoadImages("Panel",&PanelImage,PanelColors);
  LoadImages("ShipBobs",&FaceImage,NULL);
}

void LoadAny()
{
   int i;
   char Name[50];

   ScreenMask.Frames[0]=NULL;

   Spare1Image.Count=-1;
   Spare2Image.Count=-1;
   Spare3Image.Count=-1;
   Spare4Image.Count=-1;
   Spare5Image.Count=-1;
   Spare6Image.Count=-1;
   Spare7Image.Count=-1;
   Spare8Image.Count=-1;
   Spare9Image.Count=-1;
   Spare10Image.Count=-1;
   Spare11Image.Count=-1;
   Spare12Image.Count=-1;
   EyeImage.Count=-1;
   ClockWork.Count=-1;
   FireBall_16.Count=-1;
   DeadEyeImage.Count=-1;

   SpitBugImage.Count=-1;
   BugBornLeft.Count=-1;
   BugBornRight.Count=-1;
   SqueezyVBug.Count=-1;
   SqueezyHBug.Count=-1;
   SweepMissileImage.Count=-1;
   AlienBulletImage.Count=-1;
   TurretShape.Count=-1;
   TokenImage.Count=-1;
   ScrollScreen.Count=-1;
   BonusDigits.Count=-1;

   LoadImages("spit-bug",&SpitBugImage,NULL);
   LoadImages("Born-Left",&BugBornLeft,NULL);
   LoadImages("Born-Right",&BugBornRight,NULL);
   LoadImages("AlienBullet",&AlienBulletImage,NULL);
   LoadImages("BonusScores",&BonusDigits,NULL);
   LoadImages("token",&TokenImage,NULL);
   LoadImages("bang",&ExplosionImage[0],NULL);
   LoadImages("just_me",&JustMe,NULL);

   LoadImages("VSqueeze-Bug",&SqueezyVBug,NULL);
   LoadImages("HSqueeze-Bug",&SqueezyHBug,NULL);
   for(i=1;i<=NUMALIENSHAPES;++i) {
      sprintf(Name,"ships%1d",i);
      LoadImages(Name,&AlienShip[i-1],NULL);
   }
}


void FreeAliens()
{
UBYTE	loop;
   for(loop = 0; loop < NUMALIENSHAPES ; loop++)
      FreeSpriteImage(&AlienShip[loop]);
}   

void FreeMe()
{
   FreeSpriteImage(&JustMe);
}

void FreeAllImages()
{/* Free's all memory that may have been allocated by loader */
   FreeAliens();
   FreeSpriteImage(&ExplosionImage[0]);
   FreeMe();
   /*FreeScreen(); Done by DeAllocView */
}


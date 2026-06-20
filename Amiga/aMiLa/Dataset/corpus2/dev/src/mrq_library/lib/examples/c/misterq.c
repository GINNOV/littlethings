/************************************************************/
/* example program for mrq.library                          */
/* author: Marcin 'Igor' Wieczorek                          */
/* e-mail: mwieczor@us.edu.pl                               */
/* date: 06.09.2000                                         */
/************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <exec/exec.h>
#include <proto/exec.h>
#include <dos/dos.h>
#include <proto/dos.h>
#include <intuition/intuition.h>

#include <libraries/mrq.h>
#include <proto/mrq.h>

/************************************************************/
void StartCode(void);
void EndCode(void);

/************************************************************/
struct Library *MisterQLibBase;
struct MisterQBase *MisterQBase;
struct MScreen *screen;
struct IntuiMessage *msg;

APTR picture = NULL;
APTR palette = NULL;
char *filename = NULL;

/************************************************************/
/************************************************************/

void main()
{
   int x=0;
   ULONG klasa;

   StartCode();
   MRequest("This is MRequest!\nLet's check other functions!",MisterQBase);

   if((filename = AslFILERequest("LoadRGB32",MisterQBase)) == 0)
   {
      MRequest("Loading palette failed!\nExiting...",MisterQBase);
      EndCode();
      exit(10);
   }

   if( (palette = MLoadFile(filename,MisterQBase,MEMF_ANY)) == 0)
   {
      MRequest("Loading palette failed!\nExiting...",MisterQBase);
      AslFreeFILERequest(filename);
      EndCode();
      exit(10);
   }

   AslFreeFILERequest(filename);

   MSaveFile("ram:file.rgb32",MisterQBase,palette,3080);

   if((filename = AslFILERequest("Chunky (640x480)",MisterQBase)) == 0)
   {
      MRequest("Loading chunky data failed!\nExiting...",MisterQBase);
      EndCode();
      exit(10);
   }

   if( (picture = MLoadFile(filename,MisterQBase,MEMF_ANY)) == 0)
   {
      MRequest("Loading chunky data failed!\nExiting...",MisterQBase);
      AslFreeFILERequest(filename);
      EndCode();
      exit(10);
   }
   AslFreeFILERequest(filename);

   if( (screen = MOpenScreen(MisterQBase,640,480,0,palette)) == NULL )
   {
      MRequest("Can't open scren!\nExiting...",MisterQBase);
      EndCode();
      exit(10);
   }

   C2P(MisterQBase,picture,640,480,0,0);

   do
   {
      WaitPort(screen->s_Win_Base->UserPort);
      msg = GetMessage(screen->s_Win_Base->UserPort,MisterQBase);
      klasa = msg->Class;
   } while (klasa != IDCMP_MOUSEBUTTONS);


   MCloseScreen(MisterQBase,screen);

   x = Rnd(500L,MisterQBase);
   printf("Random: %d\n",x);

   MRequest("and let's check CopyBytes...\nI'm going to save palette in file RAM:plik.test",MisterQBase);
   CopyBytes(palette,picture,3080);
   MSaveFile("ram:plik.test",MisterQBase,picture,3080);

   EndCode();
}

/************************************************************/
void StartCode()
{
   MisterQLibBase = OpenLibrary("mrq.library",0);
   MisterQBase = MisterQInit();
}

/************************************************************/
void EndCode()
{
   if( palette != NULL)
   {
      MFreeFile(palette,MisterQBase);
      palette = NULL;
   }

   if( picture != NULL)
   {
      MFreeFile(picture,MisterQBase);
      picture = NULL;
   }

   MisterQCleanUp(MisterQBase);
   CloseLibrary(MisterQLibBase);
}

/************************************************************/

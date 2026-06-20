#include <stdio.h>
#include "header:iff.h"

extern void LoadImages();

struct SpriteImage Sprite;
UWORD CMap[32];

UWORD Image[18][2];
UWORD *Data;

struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;

extern void *OpenLibrary();

void dprintf()
{ while(0); }

void SetUpInterrupt()
{ while(0); }

void RemoveInterrupt()
{ while(0); }

void main(argc,argv)
int argc;
char **argv;
{
   FILE *fin,*fout;
   struct GraphObject *Ob;
   int Row;
   if(argc==1) {
      printf("Program to change Brush to Amiga Sprite C\n");
      printf(" Params:-\n");
      printf("    arg1 name of packed brush 16x16x2\n");
      printf("    arg2 name of C file to be made\n");
      printf("\n\n\nWritten by _-=BN=-_ 88\n");
      exit(0);
   }
   GfxBase=OpenLibrary("graphics.library",0L);
   IntuitionBase=OpenLibrary("intuition.library",0L);
   LoadImages(argv[1],&Sprite,CMap);		/* Load Bob */
   Ob=(struct GraphObject *)Sprite.Frames[0];
   if(Ob->Width!=16||Ob->Height!=16||Ob->RDepth!=2) {
      printf("   Object must be 16 x 16 in 2 planes\n");
      FreeSpriteImage(&Sprite);
      CloseLibrary(GfxBase);
      CloseLibrary(IntuitionBase);
      exit(0);
   }
   fout=fopen(argv[2],"w");
   fprintf(fout,"UWORD name[36]={\n");
   fprintf(fout,"    0x0000,0x0000,\n");
   Data=(UWORD *)Ob->Image;
   for(Row=0;Row<16;++Row) {
      fprintf(fout,"   0x%04x, 0x%04x,\n",*Data,*(Data+16));
      Data++;
   }
   fprintf(fout,"    0x0000,0x0000\n};\n");
   fprintf(fout,"\nUWORD Color[]={\n");
   for(Row=1;Row<4;++Row)
      fprintf(fout,"   %d,\n",CMap[Row]);
   fprintf(fout,"};\n");
      
   fclose(fout);

   FreeSpriteImage(&Sprite);
   CloseLibrary(GfxBase);
   CloseLibrary(IntuitionBase);
   exit(0);
}

#include <stdio.h>
#include "header:iff.h"

extern void LoadImages();

struct SpriteImage Sprite;
UWORD CMap[32];

UWORD *Data;

struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;

extern void *OpenLibrary();

void SetUpInterrupt()
{ while(0); }

void RemoveInterrupt()
{ while(0); }

void main(argc,argv)
int argc;
char **argv;
{
   FILE *fin,*fout,*fout2;
   struct GraphObject *Ob;
   WORD Row,Pair;
   int i;
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

      fout=fopen(argv[2],"w");
      fout2=fopen(argv[3],"w");
   
   for(i=0;i<Sprite.Count;++i) {
      Ob=(struct GraphObject *)Sprite.Frames[i];
      if(Ob->Width!=64||Ob->Height!=49||Ob->RDepth!=4) {
         printf("   Object must be 64 x 49 in 4 planes\n");
         FreeSpriteImage(&Sprite);
         CloseLibrary(GfxBase);
         CloseLibrary(IntuitionBase);
         exit(0);
      }
	
      for(Pair=0;Pair<4;++Pair) {
         Data=(UWORD *)Ob->Image+Pair;
         fprintf(fout,"UWORD LoadSprite%d[]={\n    0x0,0x0,\n",Pair*2+0);
         fprintf(fout2,"UWORD LoadSprite%d[]={\n   0x0,0x0,\n",Pair*2+1);
         for(Row=0;Row<32;++Row) {
            fprintf(fout2,"    0x%x,0x%x,\n",*(Data+2*128),*(Data+3*128));
            fprintf(fout, "    0x%x,0x%x,\n",*(Data+0*128),*(Data+1*128));
            Data+=4;
         }
         fprintf(fout, "    0x0000,0x0000\n};\n");
         fprintf(fout2,"    0x0000,0x0000\n};\n");
      }
   }
         
   fprintf(fout,"UWORD SpriteColors[16]={\n");
   for(Row=0;Row<16;++Row) {
      fprintf(fout,"   0x%x,\n",CMap[Row]);
      printf("%3d 0x%4x\n",Row,CMap[Row]);
   }
   fprintf(fout,"};\n");
         
   fclose(fout);
   fclose(fout2);

   FreeSpriteImage(&Sprite);
   CloseLibrary(GfxBase);
   CloseLibrary(IntuitionBase);
   exit(0);
}

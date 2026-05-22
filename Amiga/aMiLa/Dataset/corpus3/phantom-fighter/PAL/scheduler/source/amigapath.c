#include <exec/types.h>
#include <stdio.h>
#include "header:iff.h"

#define ID_XPNT MakeID('X','P','N','T')
#define ID_YPNT MakeID('Y','P','N','T')
#define ID_ASET MakeID('A','S','E','T')
#define ID_ASEQ MakeID('A','S','E','Q')

struct ChunkHeader chunk;

extern double sqrt();
extern char *malloc();

WORD NoPts;
ULONG VectorSize;
WORD *XPnts;
WORD *YPnts;
ULONG NumDirs,Angle;

FILE *fin=NULL,*fout=NULL;

/* Tester for make */

#include <math.h>
 
double MyAtan(dy,dx)
int dy,dx;
{
  double t,tdx,tdy;
  tdx=(double)dx;
  tdy=(double)dy;
  if(dx==0)
    {
    if(dy>=0)return 3.14159/2;
    return -3.14159/2;
    }
  if(tdy<0)tdy=-tdy;
  if(tdx<0)tdx=-tdx;
  t=atan(tdy/tdx);
  switch (2*(dy<0)+(dx<0))
    {
    case 0:
      return t;
    case 1:
      return (3.14159-t);
    case 2:
      return ((1.5707-t)-3.14159/2);
    case 3:
      return (t+3.14159);
    }
}

WORD CvtToFrmNo(dy,dx)
WORD dy,dx;

{
  int dir;
  dir=(int)(57.3*MyAtan(dy,dx));
  if(dir<0)dir+=360;
  return (NumDirs-1-(dir/Angle+5)%(NumDirs-1));
}

ULONG GetNextChunk()
{
   if(fread(&chunk,sizeof(chunk),1,fin)==-1) {
      printf("  Bad iff file\n");
      fclose(fin);
      fclose(fout);
      exit(0);
   }
   printf("Read Chunk %4s\n",&chunk.ckID);
   return chunk.ckID;
}

void SkipChunk()
{
   fseek(fin,chunk.ckSize,1);
}

void FindChunk(ckid)
ULONG ckid;
{
   while(GetNextChunk()!=ckid)SkipChunk();
}

WORD round(a)
double a;
{
   if(a>=0.0)
      return (WORD)(a+0.5);
   else
      return (WORD)(a-0.5);
}

void PrintANM_Elem(Rep,Dx,Dy)
WORD Rep,Dx,Dy;
{
   WORD FrmNo;
   FrmNo=CvtToFrmNo(Dx,Dy);
   fprintf(fout,"   {%d,%d,%d,%d},\n",Rep,FrmNo,Dx,Dy);
}

void ProcessNumbers()
{
   WORD i;
   WORD LastX,LastY;
   ULONG Dis;
   double Dx,Dy;
   WORD NumSteps;
   LastX=XPnts[0];
   LastY=YPnts[0];
   for(i=1;i<NoPts;++i) {
      printf("Going from %4d,%4d to %4d,%4d\n",(WORD)LastX,
      					       (WORD)LastY,
                                               XPnts[i],
                                               YPnts[i]);
      Dis=(XPnts[i]-LastX)*(XPnts[i]-LastX)+
          (YPnts[i]-LastY)*(YPnts[i]-LastY);
      Dis=round(sqrt((double)Dis));
      NumSteps=round((double)Dis/(double)VectorSize);
      
      if(NumSteps==0)NumSteps=1;
      
      Dx=(double)(XPnts[i]-LastX)/(double)NumSteps;
      Dy=(double)(YPnts[i]-LastY)/(double)NumSteps;
      
      if(NumSteps<2)
         PrintANM_Elem(1,XPnts[i]-LastX,YPnts[i]-LastY);
      else {
         PrintANM_Elem(NumSteps-1,round(Dx),round(Dy));
         LastX+=(NumSteps-1)*round(Dx);
         LastY+=(NumSteps-1)*round(Dy);
         PrintANM_Elem(1,XPnts[i]-LastX,YPnts[i]-LastY);
      }

      LastX=XPnts[i];
      LastY=YPnts[i];
   }
}

void PrintHelp()
{
   printf("Program to convert AnimSeq files from Bobeditor to C Source\n");
   printf("for phantom fighter\n\n");
   printf("   DoPattern infile(str) outfile(str) VectorSize(int) NumDirs(int)\n");
}

void main(argc,argv)
WORD argc;
char **argv;
{
   if(argc!=5) {
      PrintHelp();
      exit(0);
   }
   
   fin=fopen(argv[1],"r");
   if(!fin) {
      printf("  Can't find input file\n");
      exit(0);
   }
   printf("Opened %s \n",argv[1]);
   
   chunk.ckID=0;
   while(1) {
      GetNextChunk();
      switch(chunk.ckID) {
         case ID_FORM:
            fseek(fin,4,1);
            break;
         default:
            SkipChunk();
      }
      if(chunk.ckID==ID_ASET)break;
   }
   
   fout=fopen(argv[2],"w");
   if(!fout) {
      printf("  Can't open output file\n");
      fclose(fin);
      exit(0);
   }
   
   printf("Opened %s\n",argv[2]);
   
   sscanf(argv[3],"%d",&VectorSize);
   
   sscanf(argv[4],"%d",&NumDirs);

   printf("Vector %4d NumDirs %4d\n",VectorSize,NumDirs);

   Angle=360/NumDirs;
   FindChunk(ID_XPNT);
   
   NoPts=chunk.ckSize>>1;
   
   printf("Points %4d\n",NoPts);

   XPnts=(WORD *)malloc(chunk.ckSize);
   YPnts=(WORD *)malloc(chunk.ckSize);
   

   if(-1==fread(XPnts,chunk.ckSize,1,fin)) {
       printf("  Can't read XPnts\n");
       fclose(fin);
       fclose(fout);
       exit(0);
   }

   printf("Read XPnts\n");
   FindChunk(ID_YPNT);
   
   if(-1==fread(YPnts,chunk.ckSize,1,fin)) {
       printf("  Can't read YPnts\n");
       fclose(fin);
       fclose(fout);
       exit(0);
   }

   printf("Read YPnts\n");
   fprintf(fout,"/* Start X %d Y %d */\n",XPnts[0],YPnts[0]);
   ProcessNumbers();
   
   fclose(fin);
   fclose(fout);
   exit(0);
}

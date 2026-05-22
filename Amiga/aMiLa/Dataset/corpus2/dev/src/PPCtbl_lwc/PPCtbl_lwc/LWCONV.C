#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Theese setting should be changed depending on the compiler

#define BYTE unsigned char   // 1 byte unsigned
#define WORD unsigned short   // 2 bytes unsigned
#define LONG unsigned long   // 4 bytes unsigned
#define SBYTE char     // 1 byte signed
#define SWORD short     // 2 bytes signed
#define SLONG long     // 4 bytes signed
#define FLOAT float     // 4 bytes float
#define DOUBLE double     // 8 bytes float (Could be 4 for lower precision)
// NOTE!! No size check is done for the DOUBLE, so be sure it's correct

// User definable constants (Could be changed for smaller buffer etc)

#define MAXOBJECTSIZE (128*1024)
#define MAXCOORDS  	32768
#define MAXSURFACES  1024
#define MAXPOLYGONS  32768
#define MAXIMAGELINES 8192   // *768  = bytesize
#define MAXPALETTELINES (512)   // *1024 = Byte size

#define MAXIMAGESIZE (128*1024)
#define MAXIMAGES  1024
#define MAXOBJECTS  256
#define MAXIMGENTRYS 2048

// Some none changeable constants

#define HEADERSIZE  (64+4+4+4)

#define MINVALUE  -100000000
#define MAXVALUE   100000000

#define PI   3.14159265359
#define HALFPI  (PI/2)
#define TWOPI  (PI*2)

#define BYTEM1  (0xff)
#define WORDM1  (0xffff)
#define LONGM1  (0xffffffff)

// Theese defines turned out to be needed, since some compilers can't handle
// if(x=='ILBM')...

#define _ILBM  0x494C424D
#define _CMAP  0x434D4150
#define _BMHD  0x424D4844
#define _BODY  0x424F4459
#define _FLAG  0x464C4147
#define _COLR  0x434F4C52
#define _TSIZ  0x5453495A
#define _TCTR  0x54435452
#define _TFAL  0x5446414C
#define _TVEL  0x5456454C
#define _TCLR  0x54434C52
#define _TFP0  0x54465030
#define _TFP1  0x54465031
#define _POLS  0x504F4C53
#define _SRFS  0x53524653
#define _SURF  0x53555246
#define _SPEC  0x53504543
#define _REFL  0x5245464C
#define _TRAN  0x5452414E
#define _GLOS  0x474C4F53
#define _RSAN  0x5253414E
#define _RIND  0x52494E44
#define _EDGE  0x45444745
#define _SMAN  0x534D414E
#define _CTEX  0x43544558
#define _DTEX  0x44544558
#define _STEX  0x53544558
#define _RTEX  0x52544558
#define _TTEX  0x54544558
#define _BTEX  0x42544558
#define _TAMP  0x54414D50
#define _TIMG  0x54494D47
#define _BIMG  0x42494D47
#define _RIMG  0x52494D47
#define _TFLG  0x54464C47
#define _LUMI  0x4C554D49
#define _DIFF  0x44494646
#define _PNTS  0x504E5453
#define _FORM  0x464F524D
#define _LWOB  0x4C574F42
#define _IMSQ  0x494D5351

// Structure globals etc

struct  SurfaceStruct{
       WORD Flags;

       WORD ReflectionShift;
       WORD ReflectionStrength;
       WORD ReflectionColours;

       WORD ReflectionWidth;
       WORD ReflectionHeight;
       LONG ReflectionOfs;
       LONG ReflectionPalOfs;

       LONG TextureOfs;
       LONG TexturePalOfs;
       WORD TextureWidth;
       WORD TextureHeight;
       WORD TextureColours;
       BYTE TextureAxis;
       BYTE MapType;


       LONG BumpTextureOfs;
       LONG BumpTexturePalOfs;
       WORD BumpTextureWidth;
       WORD BumpTextureHeight;
       WORD BumpTextureColours;

       FLOAT BumpAmp;

       FLOAT TextureXScale;
       FLOAT TextureYScale;
       FLOAT TextureZScale;
       FLOAT TextureXPos;
       FLOAT TextureYPos;
       FLOAT TextureZPos;
       FLOAT TextureP0;
       FLOAT TextureP1;

       BYTE Red;
       BYTE Green;
       BYTE Blue;
       BYTE RTEX;
       BYTE TTEX;
       BYTE BTEX;
       WORD Luminosity;
       WORD Diffusion;
       WORD Specularity;
       WORD Glossiness;

       BYTE TAnim;
       BYTE TAnimLoop;
       WORD TAnimSpeed;
       WORD TAnimFrames;
       WORD TAnimStart;

       BYTE RAnim;
       BYTE RAnimLoop;
       WORD RAnimSpeed;
       WORD RAnimFrames;
       WORD RAnimStart;

       BYTE BAnim;
       BYTE BAnimLoop;
       WORD BAnimSpeed;
       WORD BAnimFrames;
       WORD BAnimStart;

       WORD Transparency;

      };

struct   PolyFlat{   BYTE Mode;
         BYTE Dummy1;
         BYTE Side;
         BYTE Dummy2;
         LONG PaletteOffset;
         LONG Dummy3;
         LONG Dummy4;
        };

struct   PolyTexture{  BYTE Mode;
         BYTE Dummy1;
         BYTE Side;
         BYTE Dummy2;
         WORD ImageNumber;
         WORD Dummy3;
         LONG Dummy4;
         LONG Dummy5;
        };

struct   PolyReflect{  BYTE Mode;
         BYTE ReflectionShift;
         BYTE Side;
         BYTE Dummy1;
         WORD ReflectionImageNumber;
         WORD Dummy2;
         LONG Dummy3;
         LONG Dummy4;
        };

struct   PolyTReflect{  BYTE Mode;
         BYTE ReflectionShift;
         BYTE Side;
         BYTE ColourShift;
         WORD ImageNumber;
         WORD ReflectionImageNumber;
         LONG ReflectionColourOffset;
         LONG Dummy1;
        };

struct   PolyBReflect{  BYTE Mode;
         BYTE ReflectionShift;
         BYTE Side;
         BYTE Dummy1;
         WORD ReflectionImageNumber;
         WORD BumpImageNumber;
         LONG Dummy2;
         LONG Dummy3;
        };

struct   PolyBTReflect{  BYTE Mode;
         BYTE ReflectionShift;
         BYTE Side;
         BYTE ColourShift;
         WORD ImageNumber;
         WORD ReflectionImageNumber;
         WORD BumpImageNumber;
         WORD Dummy1;
         LONG ReflectionColourOffset;
        };


union   PolySurface{
         struct PolyFlat   Flat;
         struct PolyTexture  Texture;
         struct PolyReflect  Reflection;
         struct PolyTReflect  TReflection;
         struct PolyBReflect  BReflection;
         struct PolyBTReflect BTReflection;
       };

struct   ImageEntry{   LONG ImageOffset;
         LONG NewImageOffset;
         LONG PaletteOffset;
         WORD Frames;
         WORD FrameSpeed;  /* 0 mean change every frame */
         BYTE FrameLoop;
         BYTE Reflection;
         WORD NextImage;
         WORD HSize;
         WORD VSize;
         FLOAT Bump;
       };


BYTE  DefaultFlare[256*256]={
#include "Flare.Inc"      // The default flare-image
         };

struct  ImageEntry ImageList[MAXIMGENTRYS];

union  PolySurface PolyS[MAXSURFACES];

WORD  SaveAsFloat = 0;

LONG  ObjectBuffer[MAXOBJECTSIZE/4];
FLOAT  ObjectCoord[MAXCOORDS*3];
FLOAT  PhongCoord[MAXCOORDS*3];
FLOAT  SavedObjectCoord[MAXCOORDS*3];
FLOAT  SavedPhongCoord[MAXCOORDS*3];


BYTE  PhongUsedCoord[MAXCOORDS];
BYTE  ObjectUsedCoord[MAXCOORDS];
BYTE  SavedPhongUsedCoord[MAXCOORDS];
BYTE  SavedObjectUsedCoord[MAXCOORDS];

LONG  ObjectOffset;


BYTE  ImageBuffer[MAXIMAGELINES*256];
BYTE  ImageBuffer2[MAXIMAGELINES*256*2];
BYTE  ImageBufferMap[MAXIMAGELINES*32][2];
BYTE  PaletteBuffer[MAXPALETTELINES*256*4];
BYTE  TempImage[MAXIMAGESIZE];
BYTE  DecompImage[MAXIMAGESIZE];
BYTE  ReadImageNames[MAXIMAGES][209];
LONG  ReadImageOfs[MAXIMAGES];
LONG  ReadImagePalOfs[MAXIMAGES];
WORD  ReadImageWidth[MAXIMAGES];
WORD  ReadImageHeight[MAXIMAGES];
WORD  ReadImageColours[MAXIMAGES];
WORD  ReadImageBpls[MAXIMAGES];
WORD  ReadImagePUsed[MAXIMAGES];
WORD  OptX[2][31];

WORD  ObjectShort;
FLOAT  UVData[MAXPOLYGONS][6];
WORD  PolyData[MAXPOLYGONS][4];
struct  SurfaceStruct SurfaceAttr[MAXSURFACES];
BYTE * SurfacePtr[MAXSURFACES];


WORD  MorphMode;
WORD  WritePC;
LONG  ImageLists;
LONG  TotalSurface;
LONG  SurfaceBase;

FILE  * OutputFile;

SWORD  AmbientR;
SWORD  AmbientG;
SWORD  AmbientB;
SWORD  BackR;
SWORD  BackG;
SWORD  BackB;
FLOAT  AmbientInt;

WORD  UsePhong;
WORD  UseMapping;
LONG  LastImageLine;
LONG  LastPaletteLine;
WORD  ReadImages;
LONG  LastOptimized;


LONG  ObjectCoords;
FLOAT  ObjectMaxX;
FLOAT  ObjectMinX;
FLOAT  ObjectMaxY;
FLOAT  ObjectMinY;
FLOAT  ObjectMaxZ;
FLOAT  ObjectMinZ;
LONG  Surfaces;
LONG  SurfAttribs;
LONG  Polygons;

WORD  ImageWidth,ImageHeight;
WORD  ImageColours;
WORD  ImageCompression;
BYTE *  ImagePtr;
BYTE *  ImagePalPtr;
LONG  ImageBplSize;
WORD  ImageBpls;
LONG  PaletteOfs;
LONG  ImageOfs;
LONG  ImageRow;

SBYTE  Space[]="                        \0";
LONG  SpaceStep = 2;
SBYTE  * SpacePtr=&Space[24];

FLOAT  Scale;
FLOAT  ScaleX;
FLOAT  ScaleY;
FLOAT  ScaleZ;

WORD  AngleScale  = 1024;
FLOAT  LWAngleScale = 360.0;

FLOAT  FramesPerSecond;
WORD  RemovePath;

LONG  NumberOfVertexes;
LONG  NumberOfPolygons;

BYTE  TextureCenterX	=	0;
BYTE  TextureCenterY	=	0;
BYTE  OptimizeFull		=	0;
BYTE  MakeFlares		=	0;

/* ###############################################################################################

Error/Usage routines

############################################################################################### */

void USage(void){
 printf("Usage: lwconv [-iflmortsxy] <infile.lwo> <outfile.tob>\n\n");
 printf("                -i      All writing in intel byte order.\n");
 printf("                -f      Coordinates saved as floats (4 bytes).\n");
 printf("                -l      Makes all lights to flares.\n");
 printf("                -m      Animated morph mode.\n");
 printf("                -o      Full imagebuffer optimization\n");
 printf("                -r      Remove path from all filenames before reading.\n");
 printf("                -t<n>   Set timescaling to <n> frames/second.\n");
 printf("                -s<n>   Set coordinatesclaing to <n>, n=1.0 meters in LW.\n");
 printf("                -x      Center textures and UV around X\n");
 printf("                -y      Center textures and UV around Y\n");
 printf("        ex.  lwconv -i -t36.0 test.lws myscene.tob\n");
 printf("                Convert the scene 'test.lws' at 36.0 fps and save\n");
 printf("                in PC-mode to file 'myscene.tob'\n\n");
 exit(-1);
}

void Error(SBYTE * text){
 printf("\n%sError !! %s\n\n",SpacePtr,text);
 USage();
}


/* ###############################################################################################

Read from memory routines

############################################################################################### */


LONG GetLong(BYTE * ptr){
LONG l=0;
BYTE b;
 b=*(ptr);
 l|=b;
 l<<=8;
 b=*(ptr+1);
 l|=b;
 l<<=8;
 b=*(ptr+2);
 l|=b;
 l<<=8;
 b=*(ptr+3);
 l|=b;
 return(l);
}

WORD GetWord(BYTE * ptr){
WORD l=0;
BYTE b;
 b=*(ptr);
 l|=b;
 l<<=8;
 b=*(ptr+1);
 l|=b;
 return(l);
}

FLOAT GetFloat(BYTE * ptr){
LONG l;
FLOAT f;
 l=GetLong(ptr);
 memmove((BYTE *)&f,(BYTE *)&l,4);
 return(f);
}

/* ###############################################################################################

Misc routines

############################################################################################### */

BYTE strcmp(BYTE * a,BYTE *b){
BYTE c;
 do{
  c=*(a++);
  if(c!=*(b++))return(0xff);
 }while(c!=0);
 return(0);
}

WORD strlen(BYTE * a){
WORD c=0;
 while(*(a++)!=0)c++;
 return(c-1);
}

BYTE ColourInterpol(BYTE c0,SWORD c1,WORD Factor){
WORD c;
SLONG a0,a1;
SLONG q;
 c=(WORD)c0;
 a0=(SLONG)c;
 a1=(SLONG)c1;
 q=(SLONG)Factor;
 a1-=a0;
 q=256-q;
 a1*=q;
 a1/=256;
 a1+=a0;
 if(a1<0)a1=0;
 if(a1>255)a1=255;
 c=(WORD)a1;
 return((BYTE)c);
}

SBYTE * FixPath(SBYTE * s){
LONG l;
SBYTE c;
 if(RemovePath==0)return(s);
 l=strlen(s)+1;
 s+=l;
 do{
  c=*(s-1);
  if( (c=='\\')||(c==':')||(c=='/') ){
   return(s);
  }
  s--;
  l--;
 }while(l>0);
 return(s);
}

void countup(char *text){
  char ch;
  int ofs=0;
  int add=1;
  while(*(text+ofs++)!=0);
  while( (--ofs!=0)&&(add!=0)){
    ch=*(text+ofs);
    if(ch=='9'){
     ch='0';
 }else{
   if(ch>='0')if(ch<='8'){
         ch=ch+add;
        add=0;
  }
    }
    *(text+ofs)=ch;
  }
}

/* ###############################################################################################

Image list routines

############################################################################################### */

WORD ImageAnim = 0;

WORD  GetImageNumber(LONG ImageOffset,LONG PaletteOffset,WORD HSize,WORD VSize,WORD Reflection,FLOAT BumpHeight){
WORD n;
 if(ImageAnim==0)if(ImageLists!=0){
  for(n=0;n<ImageLists;n++){
   if( (ImageList[n].Reflection==2)&&(Reflection==2)){
    if(ImageOffset==ImageList[n].ImageOffset)if(PaletteOffset==ImageList[n].PaletteOffset){
     return(n*2);
    }
   }
   if( (ImageList[n].Reflection==1)&&(Reflection==1)){
    if(ImageOffset==ImageList[n].ImageOffset)if(PaletteOffset==ImageList[n].PaletteOffset){
     return(n*2);
    }
   }
   if( (ImageList[n].Reflection==1)&&(Reflection==0)){
    if(ImageOffset==ImageList[n].ImageOffset)if(PaletteOffset==ImageList[n].PaletteOffset){
     return(n*2);
    }
   }
   if( (ImageList[n].Reflection==0)&&(Reflection==1)){
    if(ImageOffset==ImageList[n].ImageOffset)if(PaletteOffset==ImageList[n].PaletteOffset){
     if((ImageOffset&1)==0){
      return(n*2);
     }
    }
   }
  }
 }
 ImageAnim=0;
 ImageList[ImageLists].ImageOffset=ImageOffset;
 ImageList[ImageLists].PaletteOffset=PaletteOffset;
 ImageList[ImageLists].FrameSpeed=1;
 ImageList[ImageLists].Frames=1;
 ImageList[ImageLists].FrameLoop=0;
 ImageList[ImageLists].NextImage=ImageLists<<1;
 ImageList[ImageLists].Bump=BumpHeight;
 ImageList[ImageLists].HSize=HSize;
 ImageList[ImageLists].VSize=VSize;
 ImageList[ImageLists].Reflection=Reflection;
 ImageLists++;
 if(ImageLists==MAXIMGENTRYS)Error("Too many image entrys!!");
 return((ImageLists-1)<<1);
}

/* ###############################################################################################

Image/Palette buffer routines

############################################################################################### */

void ClearUsedList(void){
LONG l;
 for(l=0;l<MAXIMAGELINES*32;l++){
  ImageBufferMap[l][0]=0;
  ImageBufferMap[l][1]=0;
 }
}

void  InitImageBuffer(void){
LONG l;
LONG q;
 for(l=0;l<MAXIMAGELINES*256;l++)ImageBuffer[l]=0;
 for(l=0;l<MAXIMAGELINES*256;l++)ImageBuffer2[l*2]=0;
 for(l=0;l<MAXIMAGELINES*256;l++)ImageBuffer2[l*2+1]=0;
 ClearUsedList();
 LastImageLine=0;
 ReadImages=0;
 LastPaletteLine = 0;
 for(l=0;l<MAXPALETTELINES;l++){
  for(q=0;q<1024;q++)PaletteBuffer[l*1024+q]=0xff;
 }
}

LONG  PutPalette(BYTE * palptr,WORD XSize,WORD YSize){
WORD w,d;
LONG pos;
LONG l;
LONG q;
LONG x,y;
LONG ofs;
LONG ofs2;
 if(YSize>MAXPALETTELINES-LastPaletteLine)Error("Palette memory full!!");
 for(y=0;y<MAXPALETTELINES-YSize;y++){
  for(x=0;x<256;x++){
   if(PaletteBuffer[y*1024+x*4+0]==0){
    w=0;
    for(q=0;q<YSize;q++){
     for(l=0;l<XSize;l++){
      ofs=(y+q)*1024+(x+l)*4;
      ofs2=q*XSize*3+l*3;
      if( (PaletteBuffer[ofs+0]!=0)||
       (PaletteBuffer[ofs+1]!=*(palptr+ofs2+0))||
       (PaletteBuffer[ofs+2]!=*(palptr+ofs2+1))||
       (PaletteBuffer[ofs+3]!=*(palptr+ofs2+2))
      ){
       q=YSize;
       l=XSize;
       w=1;
      }else{

      }
     }
    }
    if(w==0){
     return(y*1024+x*4);
    }
   }
  }
 }
 for(y=0;y<MAXPALETTELINES-YSize;y++){
  for(x=0;x<256;x++){
   if(PaletteBuffer[y*1024+x*4+0]!=0){
    w=0;
    for(q=0;q<YSize;q++){
     for(l=0;l<XSize;l++){
      if(PaletteBuffer[(y+q)*1024+(x+l)*4+0]==0){
       q=YSize;
       l=XSize;
       w=1;
      }
     }
    }
    if(w==0){
     pos=y*1024+x*4;
     for(q=0;q<YSize;q++){
      for(l=0;l<XSize;l++){
       PaletteBuffer[(y+q)*1024+(x+l)*4+0]=0;
       PaletteBuffer[(y+q)*1024+(x+l)*4+1]=*(palptr++);
       PaletteBuffer[(y+q)*1024+(x+l)*4+2]=*(palptr++);
       PaletteBuffer[(y+q)*1024+(x+l)*4+3]=*(palptr++);
      }
     }
     if(y+q>LastPaletteLine)LastPaletteLine=y+q;
     return(pos);
    }
   }
  }
 }
 Error("Palette memory full!!");
 return(0);
}

LONG  PutImage(BYTE * imageptr,WORD HSize,WORD VSize){
LONG x,y,xx,yy,f;
LONG ofs,bits;
 printf("\n%sMoving to imagebuffer..",SpacePtr);
 HSize>>=3;
 if(VSize>MAXIMAGELINES)Error("Imagebuffer full!!");
 for(y=0;y<(MAXIMAGELINES-VSize);y++){
  for(x=0;x<32;x++){
   f=0;
   for(yy=0;yy<VSize;yy++){
    for(xx=0;xx<HSize;xx++){
     if(ImageBufferMap[((y+yy)<<5)+(x+xx)][0]!=0){
      f=1;
      xx=HSize;
      yy=VSize;
     }
    }
   }
   if(f==0){
    for(yy=0;yy<VSize;yy++){
     for(xx=0;xx<HSize;xx++){
      ImageBufferMap[((y+yy)<<5)+(x+xx)][0]=0xff;
     }
    }
    ofs=(y*256)+(x*8);
    for(yy=0;yy<VSize;yy++){
     for(xx=0;xx<HSize;xx++){
      for(bits=0;bits<8;bits++){
       ImageBuffer[((y+yy)<<8)+(((x+xx)<<3)+bits)]=*(imageptr++);
      }
     }
    }
    yy=y+VSize;
    if(yy>LastImageLine)LastImageLine=yy;
    printf("done!");
    return(ofs);
   }
  }
 }
 Error("Imagebuffer full!!");
 return(-1);
}

LONG GetColourTable(LONG Ofs,WORD Colours,BYTE R,BYTE G,BYTE B,WORD Factor){
BYTE * ptr;
BYTE * SourcePtr;
LONG l;
 ptr=&TempImage[0];
 SourcePtr=&PaletteBuffer[Ofs];
 for(l=0;l<Colours;l++){
  SourcePtr++;
  *(ptr++)=ColourInterpol(*(SourcePtr++),(SWORD)((WORD)R),Factor);
  *(ptr++)=ColourInterpol(*(SourcePtr++),(SWORD)((WORD)G),Factor);
  *(ptr++)=ColourInterpol(*(SourcePtr++),(SWORD)((WORD)B),Factor);
 }
 return(PutPalette(&TempImage[0],Colours,1));
}

/* ###############################################################################################

Graphic convertion routines

############################################################################################### */

void Planar2Chunky(BYTE * Source,BYTE * Dest,LONG HSize,LONG VSize){
LONG xx;
LONG yy,d;
WORD bits;
WORD b,c;
FILE * f;
 f=fopen("TEST","wb");
 fwrite(Source,30000,1,f);
 fclose(f);
 printf("\n%sConverting to chunky..",SpacePtr);
 HSize>>=3;
 for(yy=0;yy<VSize;yy++){
  for(xx=0;xx<HSize;xx++){
   for(bits=0;bits<8;bits++){
    b=0;
    for(d=0;d<ImageBpls;d++){
     c=(WORD)((BYTE *)*(Source+yy*(SLONG)ImageRow*(SLONG)ImageBpls+xx+((SLONG)ImageBpls-1-d)*(SLONG)ImageRow));
     c&=0x00ff;
     c>>=(7-bits);
     c&=0x0001;
     b<<=1;
     b+=c;
    }
    *(Dest++)=(BYTE)b;
   }
  }
 }
 printf("done!");
}

/* ###############################################################################################

Phong related routines

############################################################################################### */


WORD PhongRadius = 128;
WORD PhongColours= 128;
LONG PhongOfs;
LONG PhongPalOfs;
WORD PhongShift;

void InsertPhongColour(BYTE r,BYTE g,BYTE b,WORD diff,WORD spec,WORD glos){
WORD rr,gg,bb;
SLONG dr,dg,db;
SLONG sr,sg,sb;
SLONG ar,ag,ab;
SLONG rad1,rad2;
SLONG q;
WORD c;
FLOAT f,f2;
FLOAT	q0;
BYTE * ptr;
// Debug stuff
// FILE * inf;
//----------- Specularity colour --
 if(glos<=16){
  glos = 32;
 }else{
  if(glos<=64){
   glos = 64;
  }else{
   if(glos<=256){
    glos = 80;
   }else{
    glos = 94;
   }
  }
 }
//debug
//printf("\n%d %d %d\n",r,g,b);
//printf("%d %d %d\n",diff,spec,glos);
 rr=(WORD)r;
 gg=(WORD)g;
 bb=(WORD)b;
 dr=(SLONG)rr;
 dg=(SLONG)gg;
 db=(SLONG)bb;
 q0=AmbientR;
 q0*=AmbientInt;
 q0*=2.0;
 dr=q0-dr;
 q0=AmbientG;
 q0*=AmbientInt;
 q0*=2.0;
 dg=q0-dg;
 q0=AmbientB;
 q0*=AmbientInt;
 q0*=2.0;
 db=q0-db;
 dr*=(SLONG)spec;
 dg*=(SLONG)spec;
 db*=(SLONG)spec;
 sr=dr/256;
 sg=dg/256;
 sb=db/256;
 sr+=(SLONG)rr;
 sg+=(SLONG)gg;
 sb+=(SLONG)bb;
 dr=(SLONG)rr;
 dg=(SLONG)gg;
 db=(SLONG)bb;
 dr=BackR-dr;
 dg=BackG-dg;
 db=BackB-db;
 dr*=(SLONG)diff;
 dg*=(SLONG)diff;
 db*=(SLONG)diff;
 ar=dr/256;
 ag=dg/256;
 ab=db/256;
 ar+=(SLONG)rr;
 ag+=(SLONG)gg;
 ab+=(SLONG)bb;
 dr=(SLONG)rr;
 dg=(SLONG)gg;
 db=(SLONG)bb;
 rad1=PhongColours*(SLONG)glos;
 rad1/=(96+1);
 if(rad1<3)rad1=3;
 rad2=PhongColours-rad1;
 if(rad2==0){
  rad1--;
  rad2++;
 }
// printf("Specpoint: %d %d %d",sr,sg,sb);
// printf("Middle: %d %d %d\n",dr,dg,db);
// printf("Back: %d %d %d\n",ar,ag,ab);
// printf("Rads: %d %d\n",rad1,rad2);
 ptr=&TempImage[0];
 for(c=0;c<rad1;c++){
  f=c;
  f*=HALFPI;
  f/=rad1;
  f=1.0-cos(HALFPI-f);
  f2=(FLOAT)ar-(FLOAT)dr;
  f2*=f;
  f2+=(FLOAT)dr;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
  f2=(FLOAT)ag-(FLOAT)dg;
  f2*=f;
  f2+=(FLOAT)dg;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
  f2=(FLOAT)ab-(FLOAT)db;
  f2*=f;
  f2+=(FLOAT)db;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
 }
 for(c=0;c<rad2;c++){
  f=c;
  f*=PI;
  f/=rad2;
  f=1.0+cos(f);
  f/=2.0;
  f=1.0-f;
  f2=(FLOAT)sr-(FLOAT)dr;
  f2*=f;
  f2+=(FLOAT)dr;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
  f2=(FLOAT)sg-(FLOAT)dg;
  f2*=f;
  f2+=(FLOAT)dg;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
  f2=(FLOAT)sb-(FLOAT)db;
  f2*=f;
  f2+=(FLOAT)db;
  q=(SWORD)f2;
  if(q<0)q=0;
  if(q>255)q=255;
  rr=(WORD)q;
  *(ptr++)=(BYTE)rr;
 }

// Debug stuff
// inf=fopen("PALETTE.ACT","wb");
// fwrite(&TempImage[0],768,1,inf);
// fclose(inf);



 PhongPalOfs=PutPalette(&TempImage[0],PhongColours,1);
}

void RenderPhongMap(void){
BYTE * ptr;
SLONG x,y,xx,yy;
SLONG v;
 if(PhongShift!=0){
  printf("\n%sPhongmap already rendered!",SpacePtr);
  return;
 }
 printf("\n%sRendering phongmap %dx%d,%d scales..",SpacePtr,PhongRadius<<1,PhongRadius<<1,PhongColours);
 ptr=&TempImage[0];
 for(y=0;y<PhongRadius*2;y++){
  yy=y-PhongRadius;
  yy=yy*yy;
  for(x=0;x<PhongRadius*2;x++){
   xx=x-PhongRadius;
   xx*=xx;
   v=(SLONG)sqrt(xx+yy);
   v*=PhongColours;
   v/=PhongRadius;
   v=PhongColours-1-v;
   if(v<0)v=0;
   *(ptr++)=(BYTE)v;
  }
 }
 printf("done!");
 PhongOfs=PutImage(&TempImage[0],PhongRadius<<1,PhongRadius<<1);
 v=PhongRadius*256;
 PhongOfs+=v;
 if(PhongRadius==128)PhongShift=5;
 if(PhongRadius==64)PhongShift=6;
 if(PhongRadius==32)PhongShift=7;
 if(PhongRadius==16)PhongShift=8;
 if(PhongRadius==8)PhongShift=9;
 if(PhongRadius==4)PhongShift=10;
}

LONG MakeColourTable(WORD Strength,LONG Ofs0,LONG Col0,LONG Ofs1,LONG Col1,BYTE * Shift){
LONG pos;
WORD c0,c1;
BYTE bits;
SLONG r0,g0,b0;
SLONG r1,g1,b1;
SLONG s,s1;
LONG x0,y0,x1,y1;
BYTE * ptr;
FILE * f;
BYTE tb;
LONG tl;
/*
 tl=Ofs0;
 Ofs0=Ofs1;
 Ofs1=tl;
 tl=Col0;
 Col0=Col1;
 Col1=tl;
*/
 s=(SLONG)Strength;
 if(s>512)s=512;
 s1=512-s;
 c0=0;
 c1=0;
 if(Col0>0)c0=2;
 if(Col0>2)c0=4;
 if(Col0>4)c0=8;
 if(Col0>8)c0=16;
 if(Col0>16)c0=32;
 if(Col0>32)c0=64;
 if(Col0>64)c0=128;
 if(Col0>128)c0=256;
 if(Col1>0){c1=2;bits=1;};
 if(Col1>2){c1=4;bits=2;};
 if(Col1>4){c1=8;bits=3;};
 if(Col1>8){c1=16;bits=4;};
 if(Col1>16){c1=32;bits=5;};
 if(Col1>32){c1=64;bits=6;};
 if(Col1>64){c1=128;bits=7;};
 if(Col1>128){c1=256;bits=8;};
 *(Shift)=bits;
 ptr=&ImageBuffer2[0];
 for(Col0=0;Col0<c0;Col0++){
  r0=(SLONG)((LONG)PaletteBuffer[Ofs0+Col0*4+1]);
  g0=(SLONG)((LONG)PaletteBuffer[Ofs0+Col0*4+2]);
  b0=(SLONG)((LONG)PaletteBuffer[Ofs0+Col0*4+3]);
  r0*=s;
  g0*=s;
  b0*=s;
  for(Col1=0;Col1<c1;Col1++){
   r1=(SLONG)((LONG)PaletteBuffer[Ofs1+Col1*4+1]);
   g1=(SLONG)((LONG)PaletteBuffer[Ofs1+Col1*4+2]);
   b1=(SLONG)((LONG)PaletteBuffer[Ofs1+Col1*4+3]);
   r1*=s1;
   g1*=s1;
   b1*=s1;
   r1+=r0;
   g1+=g0;
   b1+=b0;
   r1/=512;
   g1/=512;
   b1/=512;
   if(r1<0)r1=0;
   if(r1>255)r1=255;
   if(g1<0)g1=0;
   if(g1>255)g1=255;
   if(b1<0)b1=0;
   if(b1>255)b1=255;
   *(ptr++)=r1;
   *(ptr++)=g1;
   *(ptr++)=b1;
  }
 }
 return(PutPalette(&ImageBuffer2[0],c1,c0));
}


/* ###############################################################################################

File loading routines

############################################################################################### */


LONG LoadFile(SBYTE * filename,BYTE * buffer,LONG buffermax){
FILE * f;
LONG l;
 printf("%sReading file '%s'..",SpacePtr,filename);
 f=fopen(filename,"rb");
 if(f==0)Error("Couldn't open from file!!");
 fseek(f,0,2);
 l=ftell(f);
 fseek(f,0,0);
 printf(" %d bytes ..",l);
 if(fread(buffer,l,1,f)==0){
  fclose(f);
  Error("Couldn't read from file!!");
 }
 fclose(f);
 printf("ok!\n");
 return(l);
}

WORD LoadImageTest = 0;
WORD LoadImageLoaded = 0xffff;

void LoadImage(BYTE * Name){
BYTE * ptr;
LONG length;
SLONG hunklength;
SLONG processed,l;
BYTE * p;
BYTE * TempPtr;
WORD Flag;
BYTE b;
WORD c,i;
 LoadImageLoaded=0xffff;
 Name=FixPath(Name);
 if(ReadImages!=0)if(LoadImageTest==0){
  for(c=0;c<ReadImages;c++){
   p=Name;
   ptr=&ReadImageNames[c][0];
   i=0;
   do{
    b=*(ptr++);
    if(b!=*(p++))i=1;
   }while(b!=0);
   if(i==0){
    printf("%sFile already loaded",SpacePtr);
    ImageOfs=ReadImageOfs[c];
    PaletteOfs=ReadImagePalOfs[c];
    ImageWidth=ReadImageWidth[c];
    ImageHeight=ReadImageHeight[c];
    ImageColours=ReadImageColours[c];
    ImageBpls=ReadImageBpls[c];
    LoadImageLoaded=c;
    return;
   }
  }
 }
 ptr=&TempImage[0];
 length=LoadFile(Name,ptr,MAXIMAGESIZE);
 if(GetLong(ptr)!=_FORM)Error("This is NOT an IFF-file!!");
 ptr+=4;
 length=GetLong(ptr);
 ptr+=4;
 if(GetLong(ptr)!=_ILBM)Error("This is NOT an ILBM-file!!");
 ptr+=4;
 printf("%sProcessing hunks:",SpacePtr);
 SpacePtr-=SpaceStep;
 ImagePtr=0;
 ImagePalPtr=0;
 ImageWidth=0;
 do{
  l=GetLong(ptr);
  hunklength=GetLong(ptr+4);
  *(ptr+4)=0;
  printf("\n%sILBMID: '%s' Size: %ld bytes",SpacePtr,ptr,hunklength);
  ptr+=8;
  p=ptr;
  Flag=0;
  SpacePtr-=SpaceStep;
  if(l==_BMHD){
   Flag=1;
   printf(" ILBM info");
   ImageWidth=GetWord(p);
   p+=2;
   ImageHeight=GetWord(p);
   p+=6;
   ImageBpls=(WORD)*(p);
   p+=2;
   ImageCompression=(WORD)*(p);
   printf("\n%sImage width:  %d",SpacePtr,ImageWidth);
   printf("\n%sImage height: %d",SpacePtr,ImageHeight);
   printf("\n%sNumber of bitplanes: %d",SpacePtr,ImageBpls);
   if(ImageWidth>256)Error("Image to wide!!");
   if(ImageHeight>MAXIMAGELINES)Error("Image to high!!");
   if(ImageHeight<8)Error("Image height to low!!");
   if(ImageWidth==0)Error("Image has invalid width!!");
   if(ImageHeight==0)Error("Image has invalid height!");
   if((ImageWidth&7)!=0)Error("Width must be a multiple of 8!!");
   if(ImageBpls==0)Error("No bitplanes in image!!");
   if(ImageBpls>8)Error("Too many bitplanes in image!!");
   ImageBplSize=(LONG)ImageWidth>>3;
   ImageBplSize*=(LONG)ImageHeight;
   printf("\n%sBitplanesize: %d bytes",SpacePtr,ImageBplSize);
   if(ImageCompression==0){
    printf("\n%sCompression: Off",SpacePtr);
   }else{
    printf("\n%sCompression: On",SpacePtr);
   }
   ImageRow=ImageWidth>>3;
  }
  if(l==_CMAP){
   Flag=1;
   printf(" Colour palette");
   ImageColours=hunklength/3;
   printf("\n%sNumber of colours:  %d",SpacePtr,ImageColours);
   if(ImageColours>256)Error("Image has to many palette entrys!!");
   ImagePalPtr=p;
  }
  if(l==_BODY){
   Flag=1;
   printf(" Bitmapped data");
   ImagePtr=p;
  }
  if(Flag==0){
   printf("\n%sUnknown hunk!!",SpacePtr);
  }else{
  }
  SpacePtr+=SpaceStep;
  ptr+=hunklength;
  processed=(ptr-((BYTE *)&TempImage[0]));
 }while(processed<length);
 SpacePtr+=SpaceStep;
 if(ImageWidth==0)Error("Couldn't get size information!!");
 if(ImagePalPtr==0)Error("Image has no palette!!");
 if(ImagePtr==0)Error("Image has no bitmap!!");
 PaletteOfs=PutPalette(ImagePalPtr,ImageColours,1);
 TempPtr=&DecompImage[0];
 if(ImageCompression!=0){
  printf("\n%sDecompressing image.. ",SpacePtr);
  ptr=ImagePtr;
  p=&DecompImage[0];
  length=0;
  do{
   b=*(ptr++);
   if((b&0x80)==0){
    c=(WORD)b;
    c=c&0x007f;
    c++;
    length+=(LONG)c;
    for(i=0;i<c;i++)*(p++)=*(ptr++);
   }else{
    c=(WORD)b;
    c=255-c;
    c=c&0x007f;
    c+=2;
    length+=(LONG)c;
    b=*(ptr++);
    for(i=0;i<c;i++)*(p++)=b;
   }
  }while(length<ImageBplSize*ImageBpls);
  if(length!=ImageBplSize*ImageBpls)Error("Decompression failed!! (Corupted data?)");
  ImagePtr=&DecompImage[0];
  TempPtr=&TempImage[0];
  printf("done!");
 }
 Planar2Chunky(ImagePtr,TempPtr,ImageWidth,ImageHeight);
 ImageOfs=PutImage(TempPtr,ImageWidth,ImageHeight);
 p=&ReadImageNames[ReadImages][0];
 ptr=Name;
 do{
  b=*(ptr++);
  *(p++)=b;
 }while(b!=0);
 ReadImageOfs[ReadImages]=ImageOfs;
 ReadImagePalOfs[ReadImages]=PaletteOfs;
 ReadImageWidth[ReadImages]=ImageWidth;
 ReadImageHeight[ReadImages]=ImageHeight;
 ReadImageColours[ReadImages]=ImageColours;
 ReadImageBpls[ReadImages]=ImageBpls;
 ReadImages++;
 if(ReadImages==MAXIMAGES)Error("Too many images!!");
}

/* ###############################################################################################

Texture UV mapping routines

############################################################################################### */


FLOAT fract(FLOAT num){
 return(num-floor(num));
}

FLOAT fract2(FLOAT num){
 return(num);
}

void xyztoh(FLOAT x,FLOAT y,FLOAT z,FLOAT *h)
{
 if((x==0.0)&&(z==0.0)){
  *h=0.0;
 }else if(z==0.0){
   *h=(x<0.0)?HALFPI:-HALFPI;
  }else if(z<0.0){
   *h=-atan(x/z)+PI;
  }else{
   *h=-atan(x/z);
  }
}

void xyztohp(FLOAT x,FLOAT y,FLOAT z,FLOAT *h,FLOAT *p)
{
 if((x==0.0)&&(z==0.0)){
  *h=0.0;
  if(y!=0.0){
   *p=(y<0.0)?-HALFPI:HALFPI;
  }else{
   *p=0.0;
  }
 }else{
  if(z==0.0){
   *h=(x<0.0)?HALFPI:-HALFPI;
  }else if(z<0.0){
   *h=-atan(x/z)+PI;
       }else
   *h=-atan(x/z);
   x=sqrt(x*x+z*z);
   if(x==0.0){
             *p=(y<0.0)?-HALFPI:HALFPI;
         }else
    *p=atan(y/x);
    }
}

void GetUV( WORD Type,FLOAT * xyz,
    FLOAT xp,FLOAT yp,FLOAT zp,
    FLOAT xs,FLOAT ys,FLOAT zs,
    FLOAT p0,FLOAT p1,
    BYTE axis,
    WORD Width,WORD Height,
    FLOAT * u,FLOAT * v){
FLOAT x,y,z,s,t;
FLOAT lon,lat;
 x=*(xyz)-xp;
 y=*(xyz+1)-yp;
 z=*(xyz+2)-zp;
 if(Type==1){      /* Planar image */
   s = (axis == 1) ? z / zs + .5 : x / xs + .5;
   t = (axis == 2) ? -z / zs + .5 : -y / ys + .5;

  *(u) = (FLOAT)(fract2(s)*((FLOAT)(Width-4)))+2;
  *(v) = (FLOAT)(fract2(t)*((FLOAT)(Height-4)))+2;


  if(TextureCenterX!=0)*(u)=*(u)-((FLOAT)Width/2);
  if(TextureCenterY!=0)*(v)=*(v)-((FLOAT)Height/2);
  return;
 }
 if(Type==2){      /* Spherical */
  if(axis==1){
   xyztohp(z,x,-y,&lon,&lat);
  }else if(axis==2){
   xyztohp(-x,y,z,&lon,&lat);
  }else{
   xyztohp(-x,z,-y,&lon,&lat);
  }
  lon=1.0-lon/TWOPI;
  lat=0.5-lat/PI;
  if(p0!=1.0)lon=fract(lon)*p0;
  if(p1!=1.0)lat=fract(lat)*p1;
  *(u)=(FLOAT)(fract2(lon)*((FLOAT)(Width-4)))+2;
  *(v)=(FLOAT)(fract2(lat)*((FLOAT)(Height-4)))+2;
  if(TextureCenterX!=0)*(u)=*(u)-(FLOAT)Width/2;
  if(TextureCenterY!=0)*(v)=*(v)-(FLOAT)Height/2;
  return;
    }
 if(Type==3){      /* Cylindrical */
  if(axis==1){
   xyztoh(z,x,-y,&lon);
   t=-x/xs+0.5;
  }else if(axis==2){
   xyztoh(-x,y,z,&lon);
   t=-y/ys+0.5;
  }else{
   xyztoh(-x,z,-y,&lon);
   t=-z/zs+0.5;
  }
  lon=1.0-lon/TWOPI;
  if(p0!=1.0)lon=fract(lon)*p0;
  *(u)=(FLOAT)(fract2(lon)*((FLOAT)(Width-4)))+2;
  *(v)=(FLOAT)(fract2(t)*((FLOAT)(Height-4)))+2;
  if(TextureCenterX!=0)*(u)=*(u)-(FLOAT)Width/2;
  if(TextureCenterY!=0)*(v)=*(v)-(FLOAT)Height/2;
  return;
 }
 Error("Unknown mapping type!!");
}


/* ###############################################################################################

Decoding (HUNK) routines

############################################################################################### */

WORD NextTextureType;

char * PSLastImage;
BYTE PSLastImageF;

void  ProcessSubHunk(LONG ID,LONG Length,BYTE * ptr){
BYTE flag = 0;
BYTE * p;
LONG l;
WORD w;
SBYTE cmp[]="(sequence)\0";
 if(ID==_COLR){           // Colour subhunk COLR
  flag=1;
  SurfaceAttr[SurfAttribs].Red=*(ptr++);
  SurfaceAttr[SurfAttribs].Green=*(ptr++);
  SurfaceAttr[SurfAttribs].Blue=*(ptr++);
  printf("\n%sR:$%02x G:$%02x B:$%02x",SpacePtr,SurfaceAttr[SurfAttribs].Red,SurfaceAttr[SurfAttribs].Green,SurfaceAttr[SurfAttribs].Blue);
 }
 if(ID==_FLAG){           // Flags subhunk FLAG
  flag=1;
  SurfaceAttr[SurfAttribs].Flags=GetWord(ptr);
  printf("\n%sFlag:$%04x",SpacePtr,SurfaceAttr[SurfAttribs].Flags);
//  0 = Luminos
//  1 = Outline
//  2 = Smothing
//  3 = Colour highlights
//  4 = Colour filter
//  5 = Opaque edge
//  6 = Transparent edge
//  7 = Sharp terminator
//  8 = Double sided
//  9 = Additive
 }
 if(ID==_LUMI){           // Luminosity subhunk LUMI
  flag=1;
  printf("\n%sLuminosity: %d%%",SpacePtr,(GetWord(ptr)*100)/256);
  SurfaceAttr[SurfAttribs].Luminosity=GetWord(ptr);
 }
 if(ID==_DIFF){           // Diffusion subhunk DIFF
  flag=1;
  printf("\n%sDiffusion: %d%%",SpacePtr,(GetWord(ptr)*100)/256);
  SurfaceAttr[SurfAttribs].Diffusion=GetWord(ptr);
 }
 if(ID==_SPEC){           // Specularity subhunk SPEC
  flag=1;
  printf("\n%sSpecularity: %d%%",SpacePtr,(GetWord(ptr)*100)/256);
  SurfaceAttr[SurfAttribs].Specularity=GetWord(ptr);
 }
 if(ID==_REFL){           // Reflection  subhunk REFL
  flag=1;
  printf("\n%sReflection strength: %d%%",SpacePtr,(GetWord(ptr)*100)/256);
  SurfaceAttr[SurfAttribs].ReflectionStrength=GetWord(ptr);
 }
 if(ID==_TRAN){           // Transparency  subhunk TRAN
  flag=1;
  w=GetWord(ptr);
  printf("\n%sTransparency: ",SpacePtr);
  if(w<13){
   printf("\n%sNone",SpacePtr);
   SurfaceAttr[SurfAttribs].Transparency=0;
  }
  if(w>12)if(w<65){
   printf("\n%sTexture 0 or Halfbright",SpacePtr);
   SurfaceAttr[SurfAttribs].Transparency=4;
  }
  if(w>64)if(w<129){
   printf("\n%sSubtractive",SpacePtr);
   SurfaceAttr[SurfAttribs].Transparency=1;
  }
  if(w>128)if(w<193){
   printf("\n%sAdditive",SpacePtr);
   SurfaceAttr[SurfAttribs].Transparency=2;
  }
  if(w>192){
   printf("\n%sHigher",SpacePtr);
   SurfaceAttr[SurfAttribs].Transparency=3;
  }
 }
 if(ID==_GLOS){           // Glossiness  subhunk GLOS
  flag=1;
  printf("\n%sGlossiness: %d",SpacePtr,GetWord(ptr));
  SurfaceAttr[SurfAttribs].Glossiness=GetWord(ptr);
 }
 if(ID==_RSAN){           // Reflection angle  subhunk RSAN
  flag=1;
  printf("\n%sReflection angle (Not supported)",SpacePtr,GetWord(ptr));
 }
 if(ID==_RIND){           //       subhunk RIND
  flag=1;
  printf("\n%sRefractive index (Not supported)",SpacePtr);
 }
 if(ID==_EDGE){           //       subhunk EDGE
  flag=1;
  printf("\n%sEdge transparency (Not supported)",SpacePtr);
 }
 if(ID==_SMAN){           //       subhunk SMAN
  flag=1;
  printf("\n%sPolygon adjacent (Not supported)",SpacePtr);
 }
 if(ID==_CTEX){           //       subhunk CTEX
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   flag=0;
   printf(" Texture type:");
   printf("\n%s'%s'",SpacePtr,ptr);
   if(strcmp(ptr,"Planar Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=1;
   }
   if(strcmp(ptr,"Spherical Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=2;
   }
   if(strcmp(ptr,"Cylindrical Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=3;
   }
   if(flag==0)Error("Mapping type not supported!!");
   SurfaceAttr[SurfAttribs].TTEX=1;
  }
  flag=1;
 }
 if(ID==_DTEX){           //       subhunk DTEX
  flag=1;
  printf("\n%sDiffusion texture (Not supported)",SpacePtr);
 }
 if(ID==_STEX){           //       subhunk STEX
  flag=1;
  printf("\n%sSpecular texture (Not supported)",SpacePtr);
 }
 if(ID==_RTEX){           //       subhunk RTEX
  flag=1;
  printf("\n%sUse reflection texture",SpacePtr);
  SurfaceAttr[SurfAttribs].RTEX=1;
  NextTextureType = 1;
 }
 if(ID==_TTEX){           //       subhunk TTEX
  flag=1;
  printf("\n%sUse texture",SpacePtr);
  SurfaceAttr[SurfAttribs].TTEX=1;
  NextTextureType = 0;
 }
 if(ID==_BTEX){           //       subhunk BTEX
  if((SurfaceAttr[SurfAttribs].TextureColours==0)){
   flag=0;
   printf(" Bumptexture type:");
   printf("\n%s'%s'",SpacePtr,ptr);
   if(strcmp(ptr,"Planar Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=1;
   }
   if(strcmp(ptr,"Spherical Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=2;
   }
   if(strcmp(ptr,"Cylindrical Image Map\0")==0){
    flag=1;
    SurfaceAttr[SurfAttribs].MapType=3;
   }
   if(flag==0)Error("Mapping type not supported!!");
  }
  SurfaceAttr[SurfAttribs].BTEX=1;
  flag=1;
  NextTextureType = 2;
 }
 if(ID==_TAMP){           //       subhunk TAMP
  flag=1;
  printf("\n%sBumptexture ampliude: %f%%",SpacePtr,100*GetFloat(ptr));
  SurfaceAttr[SurfAttribs].BumpAmp=GetFloat(ptr);
 }
 if(ID==_TIMG){           // Texture map subhunk TIMG
  if(NextTextureType==0){
   if(strcmp("(none)\0",ptr)!=0){
    flag=0;
    p=ptr;
    while(*(p++)!=0);
    for(l=0;l<10;l++){
     if(*(--p)!=cmp[10-l])flag=1;
    }
    if(flag!=0){
     printf("\n%sTexture map: '%s'\n",SpacePtr,ptr);
     LoadImage(ptr);
    }else{
     *(p-2)=0;
     printf("\n%sTexture map: '%s' (anim)\n",SpacePtr,ptr);
     PSLastImage=ptr;
     PSLastImageF=1;
     LoadImage(ptr);
    }
    SurfaceAttr[SurfAttribs].TextureOfs=ImageOfs;
    SurfaceAttr[SurfAttribs].TexturePalOfs=PaletteOfs;
    SurfaceAttr[SurfAttribs].TextureWidth=ImageWidth;
    SurfaceAttr[SurfAttribs].TextureHeight=ImageHeight;
    SurfaceAttr[SurfAttribs].TextureColours=ImageColours;
    SurfaceAttr[SurfAttribs].TTEX=1;
   }else{
    printf("\n%sNo texture!!\n",SpacePtr);
   }
   flag=1;
  }else{
   if(NextTextureType==1)ID=_RIMG;
   if(NextTextureType==2)ID=_BIMG;   // This one is a fake !!!! :D
  }
 }
 if(ID==_BIMG){           // Texture map subhunk TIMG
//  if(NextTextureType==2){
   if(strcmp("(none)\0",ptr)!=0){
    flag=0;
    p=ptr;
    while(*(p++)!=0);
    for(l=0;l<10;l++){
     if(*(--p)!=cmp[10-l])flag=1;
    }
    if(flag!=0){
     printf("\n%sBumptexture map: '%s'\n",SpacePtr,ptr);
     LoadImage(ptr);
    }else{
     *(p-2)=0;
     printf("\n%sBumptexture map: '%s' (anim)\n",SpacePtr,ptr);
     PSLastImage=ptr;
     PSLastImageF=3;
     LoadImage(ptr);
    }
    SurfaceAttr[SurfAttribs].BumpTextureOfs=ImageOfs;
    SurfaceAttr[SurfAttribs].BumpTexturePalOfs=PaletteOfs;
    SurfaceAttr[SurfAttribs].BumpTextureWidth=ImageWidth;
    SurfaceAttr[SurfAttribs].BumpTextureHeight=ImageHeight;
    SurfaceAttr[SurfAttribs].BumpTextureColours=ImageColours;
    SurfaceAttr[SurfAttribs].BTEX=1;
   }else{
    printf("\n%sNo bumptexture!!\n",SpacePtr);
   }
//  }
  flag=1;
 }
 if(ID==_RIMG){           // Reflection map subhunk RIMG
//  if(NextTextureType==1){
   flag=0;
   if(strcmp("(none)\0",ptr)!=0){
    p=ptr;
    while(*(p++)!=0);
    for(l=0;l<10;l++){
     if(*(--p)!=cmp[10-l])flag=1;
    }
    if(flag!=0){
     printf("\n%sReflection map: '%s'\n",SpacePtr,ptr);
     LoadImage(ptr);
    }else{
     *(p-2)=0;
     printf("\n%sReflection map: '%s' (anim)\n",SpacePtr,ptr);
     PSLastImage=ptr;
     PSLastImageF=2;
     LoadImage(ptr);
    }
    l=ImageWidth;
    if(ImageHeight<l)l=ImageHeight;
    if( !((l==8)||(l==16)||(l==32)||(l==64)||(l==128)||(l==256)) )Error("Reflection image diameter must be 2^x !!");
    l>>=1;
    l=4096/l;
    if(l==32)w=5;
    if(l==64)w=6;
    if(l==128)w=7;
    if(l==256)w=8;
    if(l==512)w=9;
    if(l==1024)w=10;
    printf("\n%sReflection shift: %d",SpacePtr,(WORD)l);
    l=(LONG)ImageHeight;
    l>>=1;
    l<<=8;
    SurfaceAttr[SurfAttribs].ReflectionOfs=ImageOfs+l;
    SurfaceAttr[SurfAttribs].ReflectionPalOfs=PaletteOfs;
    SurfaceAttr[SurfAttribs].ReflectionShift=w;
    SurfaceAttr[SurfAttribs].ReflectionColours=ImageColours;
    SurfaceAttr[SurfAttribs].RTEX=1;
    SurfaceAttr[SurfAttribs].ReflectionWidth=ImageWidth;
    SurfaceAttr[SurfAttribs].ReflectionHeight=ImageHeight;
   }else{
    printf("\n%sNo reflection texture!!\n",SpacePtr);
   }
//  }
  flag=1;
 }
 if(ID==_IMSQ){           // Texture map subhunk IMSQ
  if(PSLastImageF==0)Error("Couldn't locate animation start file!!");
  if(PSLastImageF==1){
   printf("\n%sTexture animation!!",SpacePtr);
   printf("\n%sSpeed (offset): %d",SpacePtr,GetWord(ptr)+1);
   if(GetWord(ptr+2)==0){
    printf("\n%sLooping:        Off",SpacePtr);
   }else{
    printf("\n%sLooping:        On",SpacePtr);
   }
   printf("\n%sFrames:         %d",SpacePtr,GetWord(ptr+4));
   if(GetWord(ptr+4)>1){
    SurfaceAttr[SurfAttribs].TAnim    = 1;
    SurfaceAttr[SurfAttribs].TAnimLoop   = (BYTE)GetWord(ptr+2);
    SurfaceAttr[SurfAttribs].TAnimSpeed   = GetWord(ptr)+1;
    SurfaceAttr[SurfAttribs].TAnimFrames  = GetWord(ptr+4);
    SurfaceAttr[SurfAttribs].TAnimStart   = ReadImages;
    if(LoadImageLoaded==0xffff){
     LoadImageTest=1;
     for(l=0;l<SurfaceAttr[SurfAttribs].TAnimFrames-1;l++){
      printf("\n");
      countup(PSLastImage);
      LoadImage(PSLastImage);
     }
     LoadImageTest=0;
    }else{
     printf("\n%sAnimation already loaded!!",SpacePtr);
     SurfaceAttr[SurfAttribs].TAnimStart  = LoadImageLoaded+1;
    }
   }
  }
  if(PSLastImageF==2){
   printf("\n%sReflection animation!!",SpacePtr);
   printf("\n%sSpeed (offset): %d",SpacePtr,GetWord(ptr)+1);
   if(GetWord(ptr+2)==0){
    printf("\n%sLooping:        Off",SpacePtr);
   }else{
    printf("\n%sLooping:        On",SpacePtr);
   }
   printf("\n%sFrames:         %d",SpacePtr,GetWord(ptr+4));
   if(GetWord(ptr+4)>1){
    SurfaceAttr[SurfAttribs].RAnim    = 1;
    SurfaceAttr[SurfAttribs].RAnimLoop   = (BYTE)GetWord(ptr+2);
    SurfaceAttr[SurfAttribs].RAnimSpeed   = GetWord(ptr)+1;
    SurfaceAttr[SurfAttribs].RAnimFrames  = GetWord(ptr+4);
    SurfaceAttr[SurfAttribs].RAnimStart   = ReadImages;
    if(LoadImageLoaded==0xffff){
     LoadImageTest=1;
     for(l=0;l<SurfaceAttr[SurfAttribs].RAnimFrames-1;l++){
      printf("\n");
      countup(PSLastImage);
      LoadImage(PSLastImage);
     }
     LoadImageTest=0;
    }else{
     printf("\n%sAnimation already loaded!!",SpacePtr);
     SurfaceAttr[SurfAttribs].RAnimStart  = LoadImageLoaded+1;
    }
   }
  }
  if(PSLastImageF==3){
   printf("\n%sBump animation!!",SpacePtr);
   printf("\n%sSpeed (offset): %d",SpacePtr,GetWord(ptr)+1);
   if(GetWord(ptr+2)==0){
    printf("\n%sLooping:        Off",SpacePtr);
   }else{
    printf("\n%sLooping:        On",SpacePtr);
   }
   printf("\n%sFrames:         %d",SpacePtr,GetWord(ptr+4));
   if(GetWord(ptr+4)>1){
    SurfaceAttr[SurfAttribs].BAnim    = 1;
    SurfaceAttr[SurfAttribs].BAnimLoop   = (BYTE)GetWord(ptr+2);
    SurfaceAttr[SurfAttribs].BAnimSpeed   = GetWord(ptr)+1;
    SurfaceAttr[SurfAttribs].BAnimFrames  = GetWord(ptr+4);
    SurfaceAttr[SurfAttribs].BAnimStart   = ReadImages;
    if(LoadImageLoaded==0xffff){
     LoadImageTest=1;
     for(l=0;l<SurfaceAttr[SurfAttribs].BAnimFrames-1;l++){
      printf("\n");
      countup(PSLastImage);
      LoadImage(PSLastImage);
     }
     LoadImageTest=0;
    }else{
     printf("\n%sAnimation already loaded!!",SpacePtr);
     SurfaceAttr[SurfAttribs].BAnimStart  = LoadImageLoaded+1;
    }
   }
  }
  flag=1;
  PSLastImageF=0;
 }
 if(ID==_TFLG){           // Texture map subhunk TFLG
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   printf(" Texture flag bits");
   w=GetWord(ptr);
   flag=0;
   if((w&1)!=0){
    flag++;
    l=0;
   }
   if((w&2)!=0){
    flag++;
    l=1;
   }
   if((w&4)!=0){
    flag++;
    l=2;
   }
   if(flag!=1)Error("Illegal texture flags!!");
   printf("\n%sTexture axis: ",SpacePtr);
   if(l==0)printf("X");
   if(l==1)printf("Y");
   if(l==2)printf("Z");
   SurfaceAttr[SurfAttribs].TextureAxis=(BYTE)(l+1);
  }
  flag=1;

 }
 if(ID==_TSIZ){           // Texture map subhunk TSIZ
  flag=1;
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   printf(" Texture size scale");
   SurfaceAttr[SurfAttribs].TextureXScale=GetFloat(ptr);
   SurfaceAttr[SurfAttribs].TextureYScale=GetFloat(ptr+4);
   SurfaceAttr[SurfAttribs].TextureZScale=GetFloat(ptr+8);
   printf("\n%sTexture X Scale: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureXScale);
   printf("\n%sTexture Y Scale: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureYScale);
   printf("\n%sTexture Z Scale: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureZScale);
  }
 }
 if(ID==_TCTR){           // Texture map subhunk TCTR
  flag=1;
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   printf(" Texture center position");
   SurfaceAttr[SurfAttribs].TextureXPos=GetFloat(ptr);
   SurfaceAttr[SurfAttribs].TextureYPos=GetFloat(ptr+4);
   SurfaceAttr[SurfAttribs].TextureZPos=GetFloat(ptr+8);
   printf("\n%sTexture X Position: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureXPos);
   printf("\n%sTexture Y Position: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureYPos);
   printf("\n%sTexture Z Position: %f",SpacePtr,SurfaceAttr[SurfAttribs].TextureZPos);
  }
 }
 if(ID==_TFAL){           //       subhunk TFAL
  flag=1;
  printf("\n%sTexture falloff (Not supported)",SpacePtr);
 }
 if(ID==_TVEL){           //       subhunk TFAL
  flag=1;
  printf("\n%sTexture velocity (Not supported)",SpacePtr);
 }
 if(ID==_TCLR){           //       subhunk TCLR
  flag=1;
  printf("\n%sTexture colour change (Not supported)",SpacePtr);
 }
 if(ID==_TFP0){           // Surface hunk TFP0
  flag=1;
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   printf(" Texture parameter 0");
   SurfaceAttr[SurfAttribs].TextureP0=GetFloat(ptr);
   printf("\n%sT0: %f",SpacePtr,GetFloat(ptr));
  }
 }
 if(ID==_TFP1){           // Surface hunk TFP1
  flag=1;
  if((SurfaceAttr[SurfAttribs].TextureColours==0)||(NextTextureType==0)){
   printf(" Texture parameter 1");
   SurfaceAttr[SurfAttribs].TextureP1=GetFloat(ptr);
   printf("\n%sT1: %f",SpacePtr,GetFloat(ptr));
  }
 }
 if(flag==0){
  printf("\n%sunknown subhunk!",SpacePtr);
 }else{
 }
}

void  ProcessHunk(LONG ID,LONG Length,BYTE * ptr){
BYTE flag = 0;
LONG data,l;
WORD Attr;
FLOAT f;
FLOAT * fptr;
 if(ID==_PNTS){           // Point hunk PNTS
  flag=1;
  ObjectCoords=Length/12;
  printf(" Pointdata\n%sCoordinates: %ld",SpacePtr,ObjectCoords);
  if(ObjectCoords>MAXCOORDS)Error("To many coordinates!!");
  fptr=&ObjectCoord[0];
  SpacePtr-=SpaceStep;
  for(l=0;l<ObjectCoords;l++){
   data=GetLong(ptr);
   ptr+=4;
   memmove(&f,&data,4);
   memmove(fptr,&f,4);
   fptr+=1;
   if(f>ObjectMaxX)ObjectMaxX=f;
   if(f<ObjectMinX)ObjectMinX=f;
   data=GetLong(ptr);
   ptr+=4;
   memmove(&f,&data,4);
   memmove(fptr,&f,4);
   fptr+=1;
   if(f>ObjectMaxY)ObjectMaxY=f;
   if(f<ObjectMinY)ObjectMinY=f;
   data=GetLong(ptr);
   ptr+=4;
   memmove(&f,&data,4);
   memmove(fptr,&f,4);
   fptr+=1;
   if(f>ObjectMaxZ)ObjectMaxZ=f;
   if(f<ObjectMinZ)ObjectMinZ=f;
  }
  SpacePtr+=SpaceStep;
  printf("\n%sX-Range: %12f to %12f",SpacePtr,ObjectMinX,ObjectMaxX);
  printf("\n%sY-Range: %12f to %12f",SpacePtr,ObjectMinY,ObjectMaxY);
  printf("\n%sZ-Range: %12f to %12f",SpacePtr,ObjectMinZ,ObjectMaxZ);
 }

 if(ID==_POLS){           // Polygon hunk POLS
  flag=1;
  printf(" Polygondata");
  l=0;
  SpacePtr-=SpaceStep;
  do{
   if(GetWord(ptr)!=3)Error("Currently just supporting triangular polygons!!");
   ptr+=2;
   l+=2;
   Attr=GetWord(ptr+6);
   if(Attr>32767)Error("Currently not supporting detailpolygons!!");
   PolyData[Polygons][0]=Attr;
   PolyData[Polygons][1]=GetWord(ptr);
   PolyData[Polygons][2]=GetWord(ptr+2);
   PolyData[Polygons][3]=GetWord(ptr+4);
   if(++Polygons==MAXPOLYGONS)Error("Too many polygons!!");
   ptr+=8;
   l+=8;
  }while(l<Length);
  SpacePtr+=SpaceStep;
  printf("\n%sPolygons: %ld",SpacePtr,Polygons);
 }
 if(ID==_SRFS){           // Surface hunk SRFS
  flag=1;
  printf(" Surfacenamedata");
  l=0;
  SpacePtr-=SpaceStep;
  do{
   SurfacePtr[Surfaces++]=ptr;
   printf("\n%s'%s'",SpacePtr,ptr);
   while(*(ptr++)!=0)l++;
   ptr--;
   l++;
   if(Surfaces==MAXSURFACES)Error("Too many surfaces!!");
   while( (*(++ptr)==0)&&(l<Length))l++;
  }while(l<Length);
  SpacePtr+=SpaceStep;
  printf("\n%sSurfaces: %ld",SpacePtr,Surfaces);
 }
 if(ID==_SURF){           // Surface hunk SURF
  NextTextureType=0;
  flag=1;
  l=0;
  printf(" '%s'",ptr);
  while(*(ptr++)!=0)l++;
  l++;
  if((l&1)!=0){
   ptr++;
   l++;
  }
  PSLastImageF=0;
  SpacePtr-=SpaceStep;
  SurfaceAttr[SurfAttribs].Flags    = 0;
  SurfaceAttr[SurfAttribs].ReflectionShift = 0;
  SurfaceAttr[SurfAttribs].ReflectionStrength = 0;
  SurfaceAttr[SurfAttribs].ReflectionColours = 0;
  SurfaceAttr[SurfAttribs].ReflectionWidth = 0;
  SurfaceAttr[SurfAttribs].ReflectionHeight = 0;
  SurfaceAttr[SurfAttribs].ReflectionOfs  = 0;
  SurfaceAttr[SurfAttribs].ReflectionPalOfs = 0;
  SurfaceAttr[SurfAttribs].TextureOfs   = 0;
  SurfaceAttr[SurfAttribs].TexturePalOfs  = 0;
  SurfaceAttr[SurfAttribs].TextureWidth  = 0;
  SurfaceAttr[SurfAttribs].TextureHeight  = 0;
  SurfaceAttr[SurfAttribs].TextureColours  = 0;
  SurfaceAttr[SurfAttribs].TextureAxis  = 0;
  SurfaceAttr[SurfAttribs].TextureXScale  = 1.0;
  SurfaceAttr[SurfAttribs].TextureYScale  = 1.0;
  SurfaceAttr[SurfAttribs].TextureZScale  = 1.0;
  SurfaceAttr[SurfAttribs].TextureXPos  = 0;
  SurfaceAttr[SurfAttribs].TextureYPos  = 0;
  SurfaceAttr[SurfAttribs].TextureZPos  = 0;
  SurfaceAttr[SurfAttribs].TextureP0   = 1.0;
  SurfaceAttr[SurfAttribs].TextureP1   = 1.0;
  SurfaceAttr[SurfAttribs].MapType   = 0;
  SurfaceAttr[SurfAttribs].BumpTextureOfs  = 0;
  SurfaceAttr[SurfAttribs].BumpTexturePalOfs = 0;
  SurfaceAttr[SurfAttribs].BumpTextureWidth = 0;
  SurfaceAttr[SurfAttribs].BumpTextureHeight = 0;
  SurfaceAttr[SurfAttribs].BumpTextureColours = 0;
  SurfaceAttr[SurfAttribs].BumpAmp   = 0;
  SurfaceAttr[SurfAttribs].Red    = 0;
  SurfaceAttr[SurfAttribs].Green    = 0;
  SurfaceAttr[SurfAttribs].Blue    = 0;
  SurfaceAttr[SurfAttribs].RTEX    = 0;
  SurfaceAttr[SurfAttribs].TTEX    = 0;
  SurfaceAttr[SurfAttribs].BTEX    = 0;
  SurfaceAttr[SurfAttribs].Luminosity   = 256;
  SurfaceAttr[SurfAttribs].Diffusion   = 0;
  SurfaceAttr[SurfAttribs].Specularity  = 0;
  SurfaceAttr[SurfAttribs].Glossiness   = 0;
  SurfaceAttr[SurfAttribs].TAnim    = 0;
  SurfaceAttr[SurfAttribs].TAnimLoop   = 0;
  SurfaceAttr[SurfAttribs].TAnimSpeed   = 0;
  SurfaceAttr[SurfAttribs].TAnimFrames  = 0;
  SurfaceAttr[SurfAttribs].TAnimStart   = 0;
  SurfaceAttr[SurfAttribs].RAnim    = 0;
  SurfaceAttr[SurfAttribs].RAnimLoop   = 0;
  SurfaceAttr[SurfAttribs].RAnimSpeed   = 0;
  SurfaceAttr[SurfAttribs].RAnimFrames  = 0;
  SurfaceAttr[SurfAttribs].RAnimStart   = 0;
  SurfaceAttr[SurfAttribs].BAnim    = 0;
  SurfaceAttr[SurfAttribs].BAnimLoop   = 0;
  SurfaceAttr[SurfAttribs].BAnimSpeed   = 0;
  SurfaceAttr[SurfAttribs].BAnimFrames  = 0;
  SurfaceAttr[SurfAttribs].BAnimStart   = 0;
  SurfaceAttr[SurfAttribs].Transparency  = 0;
  if(ObjectShort==0){
   do{
    Attr=GetWord(ptr+4);
    printf("\n%sSUBID: '%s'",SpacePtr,ptr);
    SpacePtr-=SpaceStep;
    ProcessSubHunk(GetLong(ptr),(LONG)Attr,ptr+6);
    SpacePtr+=SpaceStep;
    ptr+=6;
    l+=6;
    ptr+=Attr;
    l+=Attr;
   }while(l<Length);
  }
  SpacePtr+=SpaceStep;
  SurfAttribs++;
  if(SurfAttribs==MAXSURFACES)Error("Too many surfaces!!");
 }
 if(flag==0){
  printf("\n%sunknown hunk!\n",SpacePtr);
 }else{
  printf("\n");
 }
}



void InsertTAnim(LONG l){
LONG p,q;
 if(SurfaceAttr[l].TAnim!=0){
  ImageList[ImageLists-1].FrameSpeed=SurfaceAttr[l].TAnimSpeed;
  ImageList[ImageLists-1].Frames=SurfaceAttr[l].TAnimFrames;
  ImageList[ImageLists-1].FrameLoop=SurfaceAttr[l].TAnimLoop;
  p=SurfaceAttr[l].TexturePalOfs;
  for(q=0;q<SurfaceAttr[l].TAnimFrames-1;q++){
   ImageList[ImageLists].ImageOffset=ReadImageOfs[SurfaceAttr[l].TAnimStart+q];
   ImageList[ImageLists].PaletteOffset=p;
   ImageList[ImageLists].FrameSpeed=1;
   ImageList[ImageLists].Frames=1;
   ImageList[ImageLists].FrameLoop=0;
   ImageList[ImageLists].NextImage=ImageLists<<1;
   ImageList[ImageLists].Bump=0;
   ImageList[ImageLists].HSize=ReadImageWidth[SurfaceAttr[l].TAnimStart+q];
   ImageList[ImageLists].VSize=ReadImageHeight[SurfaceAttr[l].TAnimStart+q];
   ImageList[ImageLists].Reflection=0;
   ImageLists++;
   if(ImageLists==MAXIMGENTRYS)Error("Too many image entrys!!");
  }
 }
}


void InsertRAnim(LONG l){
LONG p,q;
 if(SurfaceAttr[l].RAnim!=0){
  ImageList[ImageLists-1].FrameSpeed=SurfaceAttr[l].RAnimSpeed;
  ImageList[ImageLists-1].Frames=SurfaceAttr[l].RAnimFrames;
  ImageList[ImageLists-1].FrameLoop=SurfaceAttr[l].RAnimLoop;
  p=SurfaceAttr[l].ReflectionPalOfs;
  for(q=0;q<SurfaceAttr[l].RAnimFrames-1;q++){
   ImageList[ImageLists].ImageOffset=ReadImageOfs[SurfaceAttr[l].RAnimStart+q]+ReadImageHeight[SurfaceAttr[l].RAnimStart+q]*128;
   ImageList[ImageLists].PaletteOffset=p;
   ImageList[ImageLists].FrameSpeed=1;
   ImageList[ImageLists].Frames=1;
   ImageList[ImageLists].FrameLoop=0;
   ImageList[ImageLists].NextImage=ImageLists<<1;
   ImageList[ImageLists].Bump=0;
   ImageList[ImageLists].HSize=ReadImageWidth[SurfaceAttr[l].RAnimStart+q];
   ImageList[ImageLists].VSize=ReadImageHeight[SurfaceAttr[l].RAnimStart+q];
   ImageList[ImageLists].Reflection=1;
   ImageLists++;
   if(ImageLists==MAXIMGENTRYS)Error("Too many image entrys!!");
  }
 }
}

void InsertBAnim(LONG l){
LONG p,q;
float f;
 if(SurfaceAttr[l].BAnim!=0){
  ImageList[ImageLists-1].FrameSpeed=SurfaceAttr[l].BAnimSpeed;
  ImageList[ImageLists-1].Frames=SurfaceAttr[l].BAnimFrames;
  ImageList[ImageLists-1].FrameLoop=SurfaceAttr[l].BAnimLoop;
  p=SurfaceAttr[l].ReflectionPalOfs;
  f=SurfaceAttr[l].BumpAmp;
  for(q=0;q<SurfaceAttr[l].BAnimFrames-1;q++){
   ImageList[ImageLists].ImageOffset=ReadImageOfs[SurfaceAttr[l].BAnimStart+q];
   ImageList[ImageLists].PaletteOffset=p;
   ImageList[ImageLists].FrameSpeed=1;
   ImageList[ImageLists].Frames=1;
   ImageList[ImageLists].FrameLoop=0;
   ImageList[ImageLists].NextImage=ImageLists<<1;
   ImageList[ImageLists].Bump=f;
   ImageList[ImageLists].HSize=ReadImageWidth[SurfaceAttr[l].BAnimStart+q];
   ImageList[ImageLists].VSize=ReadImageHeight[SurfaceAttr[l].BAnimStart+q];
   ImageList[ImageLists].Reflection=2;
   ImageLists++;
   if(ImageLists==MAXIMGENTRYS)Error("Too many image entrys!!");
  }
 }
}



/* ###############################################################################################

Object load main routine

############################################################################################### */

LONG LoadObject(SBYTE * filename){
LONG ObjectFSize;
LONG q,l,processed;
LONG length;
LONG hunklength;
WORD w;
WORD attr,type;
WORD u,v;
FLOAT ux,vx;
WORD mode;
LONG Coords;
LONG p;
BYTE * ptr;
BYTE RGB[3];
FLOAT v0x,v0y,v0z;
FLOAT v1x,v1y,v1z;
FLOAT nx,ny,nz;
FLOAT le;
BYTE Side;
 filename=FixPath(filename);
 ObjectCoords= 0;
 Surfaces = 0;
 SurfAttribs = 0;
 Polygons = 0;
 ObjectMaxX = MINVALUE;
 ObjectMinX = MAXVALUE;
 ObjectMaxY = MINVALUE;
 ObjectMinY = MAXVALUE;
 ObjectMaxZ = MINVALUE;
 ObjectMinZ = MAXVALUE;
 ptr=(BYTE *)&ObjectBuffer;
 ObjectFSize=LoadFile(filename,ptr,MAXOBJECTSIZE);
 l=GetLong(ptr);
 ptr+=4;
 if(l!=_FORM)Error("This is not an IFF-file!!");
 length=GetLong(ptr);
 ptr+=4;
 if(length!=ObjectFSize-8)Error("Length of IFF-file is corrupted!!");
 l=GetLong(ptr);
 ptr+=4;
 if(l!=_LWOB)Error("This is not a LightWave object-file!!");
 printf("\n%sProcessing hunks:\n",SpacePtr);
 SpacePtr-=SpaceStep;
 do{
  l=GetLong(ptr);
  hunklength=GetLong(ptr+4);
  *(ptr+4)=0;
  printf("%sID: '%s'",SpacePtr,ptr);
  ptr+=8;
  SpacePtr-=SpaceStep;
  ProcessHunk(l,hunklength,ptr);
  SpacePtr+=SpaceStep;
  ptr+=hunklength;
  processed=(ptr-((BYTE *)&ObjectBuffer));
 }while(processed<length);
 SpacePtr+=SpaceStep;
 if(ObjectCoords==0)Error("No coordinates in object!!");
 if(Polygons==0)Error("No polygons in object!!");
 if(Surfaces==0)Error("No surfaces in object!!");
// if(Surfaces!=SurfAttribs)Error("Wrong surfaces in object!!");
 w=0;
 for(l=0;l<Surfaces;l++){
  if(SurfaceAttr[l].TTEX!=0)w=1;
  if(SurfaceAttr[l].BTEX!=0)w=1;
 }
 UseMapping = 0;
 if(ObjectShort!=0)w=0;
 if(w!=0){          /*   Mapping textures  */
  printf("\n%sMapping textures..",SpacePtr);
  Coords=0;
  for(l=0;l<Polygons;l++){
   attr=PolyData[l][0];
   if(attr!=0){
    Coords+=3;
    attr--;
    type=SurfaceAttr[attr].MapType;
    if(type!=0){
     for(w=0;w<3;w++){  /* 3 coords */
      if(SurfaceAttr[attr].TextureColours==0){
       GetUV(type,(FLOAT *)&ObjectCoord[PolyData[l][w+1]*3],
         SurfaceAttr[attr].TextureXPos,
         SurfaceAttr[attr].TextureYPos,
         SurfaceAttr[attr].TextureZPos,
         SurfaceAttr[attr].TextureXScale,
         SurfaceAttr[attr].TextureYScale,
         SurfaceAttr[attr].TextureZScale,
         SurfaceAttr[attr].TextureP0,
         SurfaceAttr[attr].TextureP1,
         SurfaceAttr[attr].TextureAxis,
         SurfaceAttr[attr].BumpTextureWidth,
         SurfaceAttr[attr].BumpTextureHeight,
         &ux,&vx);
      }else{
       GetUV(type,(FLOAT *)&ObjectCoord[PolyData[l][w+1]*3],
         SurfaceAttr[attr].TextureXPos,
         SurfaceAttr[attr].TextureYPos,
         SurfaceAttr[attr].TextureZPos,
         SurfaceAttr[attr].TextureXScale,
         SurfaceAttr[attr].TextureYScale,
         SurfaceAttr[attr].TextureZScale,
         SurfaceAttr[attr].TextureP0,
         SurfaceAttr[attr].TextureP1,
         SurfaceAttr[attr].TextureAxis,
         SurfaceAttr[attr].TextureWidth,
         SurfaceAttr[attr].TextureHeight,
         &ux,&vx);
      }
       UVData[l][w*2]=ux;
       UVData[l][w*2+1]=vx;
     }
    }else{
     UVData[l][0]=0;
     UVData[l][1]=0;
     UVData[l][2]=0;
     UVData[l][3]=0;
     UVData[l][4]=0;
     UVData[l][5]=0;
    }
   }else{
    Error("Polygon without any surface!!");
   }
  }
  if(Coords!=0){
   printf(" %ld UV coordinates mapped!",Coords);
   UseMapping = 1;
  }else{
   printf("No mapping used!!");
  }
 }
 printf("\n%sScaling coordinates..",SpacePtr);
 for(l=0;l<ObjectCoords;l++)ObjectUsedCoord[l]=0;
 for(l=0;l<Polygons;l++){
  ObjectUsedCoord[PolyData[l][1]]=1;
  ObjectUsedCoord[PolyData[l][2]]=1;
  ObjectUsedCoord[PolyData[l][3]]=1;
 }
 ObjectMaxX=MINVALUE;
 ObjectMinX=MAXVALUE;
 ObjectMaxY=MINVALUE;
 ObjectMinY=MAXVALUE;
 ObjectMaxZ=MINVALUE;
 ObjectMinZ=MAXVALUE;
 Coords=0;
 for(l=0;l<ObjectCoords;l++){
  if(ObjectUsedCoord[l]!=0)Coords++;
  ObjectCoord[l*3+0]*=(Scale*ScaleX);
  if(ObjectCoord[l*3+0]>ObjectMaxX)ObjectMaxX=ObjectCoord[l*3+0];
  if(ObjectCoord[l*3+0]<ObjectMinX)ObjectMinX=ObjectCoord[l*3+0];
  ObjectCoord[l*3+1]*=(Scale*ScaleY);
  if(ObjectCoord[l*3+1]>ObjectMaxY)ObjectMaxY=ObjectCoord[l*3+1];
  if(ObjectCoord[l*3+1]<ObjectMinY)ObjectMinY=ObjectCoord[l*3+1];
  ObjectCoord[l*3+2]*=(Scale*ScaleX);
  if(ObjectCoord[l*3+2]>ObjectMaxZ)ObjectMaxZ=ObjectCoord[l*3+2];
  if(ObjectCoord[l*3+2]<ObjectMinZ)ObjectMinZ=ObjectCoord[l*3+2];
 }
 printf(" %ld scaled",ObjectCoords);
 SpacePtr-=SpaceStep;
 printf("\n%sX-Range: %12f to %12f",SpacePtr,ObjectMinX,ObjectMaxX);
 printf("\n%sY-Range: %12f to %12f",SpacePtr,ObjectMinY,ObjectMaxY);
 printf("\n%sZ-Range: %12f to %12f",SpacePtr,ObjectMinZ,ObjectMaxZ);
 printf("\n%sUsed coordinates: %ld",SpacePtr,Coords);
 SpacePtr+=SpaceStep;
 if(ObjectShort==0){
  printf("\n%sProcessing surfaces..",SpacePtr);
  SpacePtr-=SpaceStep;
  for(l=0;l<Surfaces;l++){
   if(SurfaceAttr[l].ReflectionStrength!=0)if(SurfaceAttr[l].ReflectionColours==0){
    RenderPhongMap();
    InsertPhongColour(SurfaceAttr[l].Red,SurfaceAttr[l].Green,SurfaceAttr[l].Blue,
          SurfaceAttr[l].Diffusion,SurfaceAttr[l].Specularity,SurfaceAttr[l].Glossiness);
    SurfaceAttr[l].ReflectionOfs=PhongOfs;
    SurfaceAttr[l].ReflectionPalOfs=PhongPalOfs;
    SurfaceAttr[l].ReflectionShift=PhongShift;
    SurfaceAttr[l].ReflectionColours=PhongColours;
    SurfaceAttr[l].ReflectionWidth=PhongRadius*2;
    SurfaceAttr[l].ReflectionHeight=PhongRadius*2;
    SurfaceAttr[l].RTEX=1;
   }
  }
  SpacePtr+=SpaceStep;
  printf("\n%sTranslating surfacedata..",SpacePtr);
  SurfaceBase=TotalSurface;
  for(l=0;l<Surfaces;l++){
   mode=0;
   TotalSurface++;
   if(SurfaceAttr[l].BumpAmp>0.05)if(SurfaceAttr[l].BTEX!=0)mode+=4;
   if(SurfaceAttr[l].ReflectionStrength!=0)if(SurfaceAttr[l].RTEX!=0)mode+=2;
   if(SurfaceAttr[l].TextureColours!=0)if(SurfaceAttr[l].TTEX!=0)mode+=1;
   Side=(BYTE)(( (SurfaceAttr[l].Flags>>8) &0x0001));
   if(mode==4)mode=0;
   if(mode==5)mode=1;
   if(SurfaceAttr[l].Transparency==4)mode=0;

   if(mode==0){    /* Flat */
    PolyS[l+SurfaceBase].Flat.Mode = 0;
    SurfaceAttr[l].Red=ColourInterpol(SurfaceAttr[l].Red,BackR,SurfaceAttr[l].Luminosity);
    SurfaceAttr[l].Green=ColourInterpol(SurfaceAttr[l].Green,BackG,SurfaceAttr[l].Luminosity);
    SurfaceAttr[l].Blue=ColourInterpol(SurfaceAttr[l].Blue,BackB,SurfaceAttr[l].Luminosity);
    RGB[0]=SurfaceAttr[l].Red;
    RGB[1]=SurfaceAttr[l].Green;
    RGB[2]=SurfaceAttr[l].Blue;
	PolyS[l+SurfaceBase].Flat.PaletteOffset = PutPalette(&RGB[0],1,1);
    PolyS[l+SurfaceBase].Flat.Side   = Side;
   }
   if(mode==1){    /* Texture */
    PolyS[l+SurfaceBase].Texture.Mode = 1;
    SurfaceAttr[l].TexturePalOfs = GetColourTable( SurfaceAttr[l].TexturePalOfs,
                 SurfaceAttr[l].TextureColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);

    ImageAnim=SurfaceAttr[l].TAnim;
    PolyS[l+SurfaceBase].Texture.ImageNumber = GetImageNumber(SurfaceAttr[l].TextureOfs,SurfaceAttr[l].TexturePalOfs,SurfaceAttr[l].TextureWidth,SurfaceAttr[l].TextureHeight,0,0);
    PolyS[l+SurfaceBase].Texture.Side   = Side;
    InsertTAnim(l);
   }
   if(mode==2){    /* Reflection */



    SurfaceAttr[l].ReflectionPalOfs = GetColourTable( SurfaceAttr[l].ReflectionPalOfs,
                 SurfaceAttr[l].ReflectionColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);

    PolyS[l+SurfaceBase].Reflection.Mode = 2;
    PolyS[l+SurfaceBase].Reflection.ReflectionShift   = (BYTE)SurfaceAttr[l].ReflectionShift;
    ImageAnim=SurfaceAttr[l].RAnim;
    PolyS[l+SurfaceBase].Reflection.ReflectionImageNumber = GetImageNumber(SurfaceAttr[l].ReflectionOfs,SurfaceAttr[l].ReflectionPalOfs,SurfaceAttr[l].ReflectionWidth,SurfaceAttr[l].ReflectionHeight,1,0);
    PolyS[l+SurfaceBase].Reflection.Side     = Side;
    InsertRAnim(l);
   }
   if(mode==3){    /*  TReflection */
    SurfaceAttr[l].TexturePalOfs = GetColourTable( SurfaceAttr[l].TexturePalOfs,
                 SurfaceAttr[l].TextureColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);
    SurfaceAttr[l].ReflectionPalOfs = GetColourTable( SurfaceAttr[l].ReflectionPalOfs,
                 SurfaceAttr[l].ReflectionColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);
    PolyS[l+SurfaceBase].TReflection.Mode = 3;
    PolyS[l+SurfaceBase].TReflection.ReflectionShift  = (BYTE)SurfaceAttr[l].ReflectionShift;
    ImageAnim=SurfaceAttr[l].TAnim;
    PolyS[l+SurfaceBase].TReflection.ImageNumber   = GetImageNumber(SurfaceAttr[l].TextureOfs,SurfaceAttr[l].TexturePalOfs,SurfaceAttr[l].TextureWidth,SurfaceAttr[l].TextureHeight,0,0);
    InsertTAnim(l);
    ImageAnim=SurfaceAttr[l].RAnim;
    PolyS[l+SurfaceBase].TReflection.ReflectionImageNumber = GetImageNumber(SurfaceAttr[l].ReflectionOfs,SurfaceAttr[l].ReflectionPalOfs,SurfaceAttr[l].ReflectionWidth,SurfaceAttr[l].ReflectionHeight,1,0);
    InsertRAnim(l);
    PolyS[l+SurfaceBase].TReflection.ReflectionColourOffset = MakeColourTable(
                       SurfaceAttr[l].ReflectionStrength,
                       SurfaceAttr[l].ReflectionPalOfs,
                       SurfaceAttr[l].ReflectionColours,
                       SurfaceAttr[l].TexturePalOfs,
                       SurfaceAttr[l].TextureColours,
                       &PolyS[l+SurfaceBase].TReflection.ColourShift);
    PolyS[l+SurfaceBase].TReflection.Side   = Side;
   }
   if(mode==6){    /* BReflection */
    if(SurfaceAttr[l].ReflectionWidth!=256)Error("Reflection width must be 256 when using bumpmaps!!");
    if(SurfaceAttr[l].ReflectionHeight!=256)Error("Reflection height must be 256 when using bumpmaps!!");
    SurfaceAttr[l].ReflectionPalOfs = GetColourTable( SurfaceAttr[l].ReflectionPalOfs,
                 SurfaceAttr[l].ReflectionColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);
    PolyS[l+SurfaceBase].BReflection.Mode = 4;
    PolyS[l+SurfaceBase].BReflection.ReflectionShift  = (BYTE)SurfaceAttr[l].ReflectionShift;
    ImageAnim=SurfaceAttr[l].RAnim;
    PolyS[l+SurfaceBase].BReflection.ReflectionImageNumber = GetImageNumber(SurfaceAttr[l].ReflectionOfs,SurfaceAttr[l].ReflectionPalOfs,SurfaceAttr[l].ReflectionWidth,SurfaceAttr[l].ReflectionHeight,1,0);
    InsertRAnim(l);
    ImageAnim=SurfaceAttr[l].BAnim;
    PolyS[l+SurfaceBase].BReflection.BumpImageNumber  = GetImageNumber(SurfaceAttr[l].BumpTextureOfs,SurfaceAttr[l].BumpTexturePalOfs,SurfaceAttr[l].BumpTextureWidth,SurfaceAttr[l].BumpTextureHeight,2,SurfaceAttr[l].BumpAmp);
    InsertBAnim(l);
    PolyS[l+SurfaceBase].BReflection.Side   = Side;
   }
   if(mode==7){    /*  BTReflection */
    if(SurfaceAttr[l].ReflectionWidth!=256)Error("Reflection width must be 256 when using bumpmaps!!");
    if(SurfaceAttr[l].ReflectionHeight!=256)Error("Reflection height must be 256 when using bumpmaps!!");
    if(SurfaceAttr[l].BumpTextureWidth!=SurfaceAttr[l].TextureWidth)Error("Bumpmap width and texturemap width must be the same!!");
    if(SurfaceAttr[l].BumpTextureHeight!=SurfaceAttr[l].TextureHeight)Error("Bumpmap height and texturemap height must be the same!!");
    SurfaceAttr[l].TexturePalOfs = GetColourTable( SurfaceAttr[l].TexturePalOfs,
                 SurfaceAttr[l].TextureColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);
    SurfaceAttr[l].ReflectionPalOfs = GetColourTable( SurfaceAttr[l].ReflectionPalOfs,
                 SurfaceAttr[l].ReflectionColours,
                 SurfaceAttr[l].Red,
                 SurfaceAttr[l].Green,
                 SurfaceAttr[l].Blue,
                 SurfaceAttr[l].Luminosity);
    PolyS[l+SurfaceBase].BTReflection.Mode = 5;
    PolyS[l+SurfaceBase].BTReflection.ReflectionShift  = (BYTE)SurfaceAttr[l].ReflectionShift;
    ImageAnim=SurfaceAttr[l].TAnim;
    PolyS[l+SurfaceBase].BTReflection.ImageNumber   = GetImageNumber(SurfaceAttr[l].TextureOfs,SurfaceAttr[l].TexturePalOfs,SurfaceAttr[l].TextureWidth,SurfaceAttr[l].TextureHeight,0,0);
    InsertTAnim(l);
    ImageAnim=SurfaceAttr[l].RAnim;
    PolyS[l+SurfaceBase].BTReflection.ReflectionImageNumber = GetImageNumber(SurfaceAttr[l].ReflectionOfs,SurfaceAttr[l].ReflectionPalOfs,SurfaceAttr[l].ReflectionWidth,SurfaceAttr[l].ReflectionHeight,1,0);
    InsertRAnim(l);
    PolyS[l+SurfaceBase].BTReflection.ReflectionColourOffset = MakeColourTable(
                       SurfaceAttr[l].ReflectionStrength,
                       SurfaceAttr[l].ReflectionPalOfs,
                       SurfaceAttr[l].ReflectionColours,
                       SurfaceAttr[l].TexturePalOfs,
                       SurfaceAttr[l].TextureColours,
                       &PolyS[l+SurfaceBase].TReflection.ColourShift);
    ImageAnim=SurfaceAttr[l].BAnim;
    PolyS[l+SurfaceBase].BTReflection.BumpImageNumber  = GetImageNumber(SurfaceAttr[l].BumpTextureOfs,SurfaceAttr[l].BumpTexturePalOfs,SurfaceAttr[l].BumpTextureWidth,SurfaceAttr[l].BumpTextureHeight,2,SurfaceAttr[l].BumpAmp);
    InsertBAnim(l);
    PolyS[l+SurfaceBase].BTReflection.Side   = Side;
   }
   PolyS[l+SurfaceBase].BTReflection.Mode+=(SurfaceAttr[l].Transparency*8);
  }
  printf("%ld surfaces done!",Surfaces);
 }
 w=0;
 for(l=0;l<Surfaces;l++){
  if(SurfaceAttr[l].ReflectionStrength!=0)if(SurfaceAttr[l].RTEX!=0)w=1;
 }
 UsePhong=0;
 if(ObjectShort!=0)w=1;
 if(w!=0){              /* Env mapping */
  for(l=0;l<ObjectCoords;l++)PhongUsedCoord[l]=0;
  UsePhong=1;
  printf("\n%sCalculating environment constants..",SpacePtr);
  for(l=0;l<ObjectCoords*3;l++){
   PhongCoord[l]=0;
  }
  for(l=0;l<Polygons;l++){
   if( ((SurfaceAttr[PolyData[l][0]-1].ReflectionStrength!=0)&&(SurfaceAttr[PolyData[l][0]-1].RTEX!=0))||(ObjectShort!=0)){
    PhongUsedCoord[PolyData[l][1]]=1;
    PhongUsedCoord[PolyData[l][2]]=1;
    PhongUsedCoord[PolyData[l][3]]=1;
   }
   v0x=ObjectCoord[PolyData[l][2]*3+0]-ObjectCoord[PolyData[l][1]*3+0];
   v0y=ObjectCoord[PolyData[l][2]*3+1]-ObjectCoord[PolyData[l][1]*3+1];
   v0z=ObjectCoord[PolyData[l][2]*3+2]-ObjectCoord[PolyData[l][1]*3+2];
   v1x=ObjectCoord[PolyData[l][3]*3+0]-ObjectCoord[PolyData[l][1]*3+0];
   v1y=ObjectCoord[PolyData[l][3]*3+1]-ObjectCoord[PolyData[l][1]*3+1];
   v1z=ObjectCoord[PolyData[l][3]*3+2]-ObjectCoord[PolyData[l][1]*3+2];
   nx=v0y*v1z-v0z*v1y;
   ny=v0z*v1x-v0x*v1z;
   nz=v0x*v1y-v0y*v1x;
   le=nx*nx+ny*ny+nz*nz;
   le=sqrt(le);
   nx=nx*4096/le;
   ny=ny*4096/le;
   nz=nz*4096/le;
   PhongCoord[PolyData[l][1]*3+0]+=nx;
   PhongCoord[PolyData[l][1]*3+1]+=ny;
   PhongCoord[PolyData[l][1]*3+2]+=nz;
   PhongCoord[PolyData[l][2]*3+0]+=nx;
   PhongCoord[PolyData[l][2]*3+1]+=ny;
   PhongCoord[PolyData[l][2]*3+2]+=nz;
   PhongCoord[PolyData[l][3]*3+0]+=nx;
   PhongCoord[PolyData[l][3]*3+1]+=ny;
   PhongCoord[PolyData[l][3]*3+2]+=nz;
  }
  for(l=0;l<ObjectCoords;l++){
   le=PhongCoord[l*3+0]*PhongCoord[l*3+0]+PhongCoord[l*3+1]*PhongCoord[l*3+1]+PhongCoord[l*3+2]*PhongCoord[l*3+2];
   le=sqrt(le);
   if(le==0)le=1;
   PhongCoord[l*3+0]=PhongCoord[l*3+0]*4095.0/le;
   PhongCoord[l*3+1]=PhongCoord[l*3+1]*4095.0/le;
   PhongCoord[l*3+2]=PhongCoord[l*3+2]*4095.0/le;
  }
  printf(" %ld coords calculated!",ObjectCoords);
  Coords=0;
  for(l=0;l<ObjectCoords;l++){
   if(PhongUsedCoord[l]!=0)Coords++;
  }
  SpacePtr-=SpaceStep;
  printf("\n%s%ld phong coords need to be rotated.",SpacePtr,Coords);
  SpacePtr+=SpaceStep;
 }
 return(0);
}


/* ###############################################################################################

ReArrange Image Buffer

############################################################################################### */

LONG UniqeImages;
LONG OptimizedOffset[MAXIMAGES];
LONG OptimizedNewOffset[MAXIMAGES];
LONG BumpUniqeImages;
LONG BumpOptimizedOffset[MAXIMAGES];
LONG BumpOptimizedNewOffset[MAXIMAGES];

LONG PutOptimized1(LONG Offset,WORD Width,WORD Height){
LONG x,y;
LONG w,h;
WORD q;
LONG ofs;
LONG yend;
LONG p;
 if(UniqeImages!=0){
  for(x=0;x<UniqeImages;x++){
   if(OptimizedOffset[x]==Offset){
    return(OptimizedNewOffset[x]);
   }
  }
 }
 yend=LastOptimized+1;
 if(Height>LastOptimized)yend=Height+1;
 for(p=0;p<2;p++){
  for(y=0;y<yend-Height;y++){
   for(x=0;x<32;x++){
    if(ImageBufferMap[y*32+x][p]!=0){
     q=0;
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       if(ImageBufferMap[(y+h)*32+(x+w)][p]==0){
        q=1;
        h=Height;
        w=Width/8;
       }
      }
     }
     if(q==0){
      ofs=y*512+x*16+p;
	  q=1;
	  if(OptimizeFull!=0){
       q=0;
	   for(h=0;h<Height;h++){
        for(w=0;w<Width;w++){
         if(ImageBuffer2[ofs+h*512+w*2]!=ImageBuffer[Offset+h*256+w]){
          q=1;
          h=Height;
          w=Width;
         }
       	}
       }
	  }
      if(q==0){
       return(ofs);
      }
     }
    }
   }
  }
 }
 for(y=0;y<yend-Height;y++){
  for(x=0;x<32;x++){
   if(ImageBufferMap[y*32+x][1]==0){
    q=0;
    for(h=0;h<Height;h++){
     for(w=0;w<(Width/8);w++){
      if(ImageBufferMap[(y+h)*32+(x+w)][1]!=0){
       q=1;
       h=Height;
       w=Width/8;
      }
     }
    }
    if(q==0){
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       ImageBufferMap[(y+h)*32+(x+w)][1]=0xff;
      }
     }
     ofs=y*512+x*16+1;
     for(h=0;h<Height;h++){
      for(w=0;w<Width;w++){
       ImageBuffer2[ofs+h*512+w*2]=ImageBuffer[Offset+h*256+w];
      }
     }
     if((y+Height)>LastOptimized)LastOptimized=y+Height;
     OptimizedOffset[UniqeImages]=Offset;
     OptimizedNewOffset[UniqeImages++]=ofs;
     return(ofs);
    }
   }
  }
 }
 return(-1);
}

LONG PutOptimized0(LONG Offset,WORD Width,WORD Height){
LONG x,y;
LONG w,h;
WORD q;
LONG ofs;
LONG yend;
LONG p;
 if(UniqeImages!=0){
  for(x=0;x<UniqeImages;x++){
   if(OptimizedOffset[x]==Offset){
    return(OptimizedNewOffset[x]);
   }
  }
 }
 if(Height>MAXIMAGELINES)Error("Image optimize buffer full!!");
 yend=LastOptimized+1;
 if(Height>LastOptimized)yend=Height+1;
 for(p=0;p<2;p++){
  for(y=0;y<yend-Height;y++){
   for(x=0;x<32;x++){
    if(ImageBufferMap[y*32+x][p]!=0){
     q=0;
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       if(ImageBufferMap[(y+h)*32+(x+w)][p]==0){
        q=1;
        h=Height;
        w=Width/8;
       }
      }
     }
     if(q==0){
      ofs=y*512+x*16+p;
	  q=1;
	  if(OptimizeFull!=0){
       q=0;
       for(h=0;h<Height;h++){
        for(w=0;w<Width;w++){
         if(ImageBuffer2[ofs+h*512+w*2]!=ImageBuffer[Offset+h*256+w]){
          q=1;
          h=Height;
          w=Width;
         }
        }
       }
	  }
      if(q==0){
       return(ofs);
      }
     }
    }
   }
  }
 }
 for(y=0;y<MAXIMAGELINES-Height;y++){
  for(x=0;x<32;x++){
   if(ImageBufferMap[y*32+x][0]==0){
    q=0;
    for(h=0;h<Height;h++){
     for(w=0;w<(Width/8);w++){
      if(ImageBufferMap[(y+h)*32+(x+w)][0]!=0){
       q=1;
       h=Height;
       w=Width/8;
      }
     }
    }
    if(q==0){
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       ImageBufferMap[(y+h)*32+(x+w)][0]=0xff;
      }
     }
     ofs=y*512+x*16;
     for(h=0;h<Height;h++){
      for(w=0;w<Width;w++){
       ImageBuffer2[ofs+h*512+w*2]=ImageBuffer[Offset+h*256+w];
      }
     }
     if((y+Height)>LastOptimized)LastOptimized=y+Height;
     OptimizedOffset[UniqeImages]=Offset;
     OptimizedNewOffset[UniqeImages++]=ofs;
     return(ofs);
    }
   }
  }
 }
 Error("Image optimize buffer full!!");
 return(-1);
}

LONG PutOptimizedRef(LONG Offset,WORD Width,WORD Height){
LONG x,y;
LONG w,h;
WORD q;
LONG ofs;
LONG yend;
LONG p;
 Offset=Offset-(Height/2)*256;
 if(UniqeImages!=0){
  for(x=0;x<UniqeImages;x++){
   if(OptimizedOffset[x]==Offset){
    return(OptimizedNewOffset[x]+(Height/2)*512);
   }
  }
 }
 if(Height>MAXIMAGELINES)Error("Image optimize buffer full!!");
 yend=LastOptimized+1;
 if(Height>LastOptimized)yend=Height+1;
 for(p=0;p<1;p++){
  for(y=0;y<yend-Height;y++){
   for(x=0;x<32;x++){
    if(ImageBufferMap[y*32+x][p]!=0){
     q=0;
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       if(ImageBufferMap[(y+h)*32+(x+w)][p]==0){
        q=1;
        h=Height;
        w=Width/8;
       }
      }
     }
     if(q==0){
      ofs=y*512+x*16+p;
	  q=1;
	  if(OptimizeFull!=0){
	   q=0;
       for(h=0;h<Height;h++){
        for(w=0;w<Width;w++){
         if(ImageBuffer2[ofs+h*512+w*2]!=ImageBuffer[Offset+h*256+w]){
          q=1;
          h=Height;
          w=Width;
         }
        }
       }
	  }
      if(q==0){
       return(ofs+(Height/2)*512);
      }
     }
    }
   }
  }
 }
 for(y=0;y<MAXIMAGELINES-Height;y++){
  for(x=0;x<32;x++){
   if(ImageBufferMap[y*32+x][0]==0){
    q=0;
    for(h=0;h<Height;h++){
     for(w=0;w<(Width/8);w++){
      if(ImageBufferMap[(y+h)*32+(x+w)][0]!=0){
       q=1;
       h=Height;
       w=Width/8;
      }
     }
    }
    if(q==0){
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       ImageBufferMap[(y+h)*32+(x+w)][0]=0xff;
      }
     }
     ofs=y*512+x*16;
     for(h=0;h<Height;h++){
      for(w=0;w<Width;w++){
       ImageBuffer2[ofs+h*512+w*2]=ImageBuffer[Offset+h*256+w];
      }
     }
     if((y+Height)>LastOptimized)LastOptimized=y+Height;
     OptimizedOffset[UniqeImages]=Offset;
     OptimizedNewOffset[UniqeImages++]=ofs;
     return(ofs+(Height/2)*512);
    }
   }
  }
 }
 Error("Image optimize buffer full!!");
 return(0);
}


WORD GetBump(BYTE * Addr,WORD XPos,WORD YPos,WORD Width,WORD Height,FLOAT Scale){
WORD w;
BYTE x,y;
LONG l;
FLOAT c,x0,y0;
 l=(LONG)YPos;
 l<<=8;
 l+=(LONG)XPos;
 w=(WORD)*(Addr+l);
 c=(FLOAT)w;
 XPos++;
 XPos%=Width;
 l=(LONG)YPos;
 l<<=8;
 l+=(LONG)XPos;
 w=(WORD)*(Addr+l);
 x0=(FLOAT)w;
 XPos+=Width;
 XPos--;
 XPos%=Width;
 YPos++;
 YPos%=Height;
 l=(LONG)YPos;
 l<<=8;
 l+=(LONG)XPos;
 w=(WORD)*(Addr+l);
 y0=(FLOAT)w;
 x0-=c;
 y0-=c;
 x0*=Scale;
 y0*=Scale;
 if(x0<-127)x0=-127;
 if(x0>127)x0=127;
 if(y0<-127)y0=-127;
 if(y0>127)y0=127;
 x=(BYTE)x0;
 y=(BYTE)y0;

 if(WritePC==0){
  w=(WORD)y;
  w<<=8;
  w+=(WORD)x;
 }else{
  w=(WORD)x;
  w<<=8;
  w+=(WORD)y;
 }
 return(w);
}

LONG PutOptimizedBump(LONG Offset,WORD Width,WORD Height,FLOAT Bump){
LONG x,y;
LONG w,h;
WORD q;
LONG ofs;
WORD b;
 if(BumpUniqeImages!=0){
  for(x=0;x<BumpUniqeImages;x++){
   if(BumpOptimizedOffset[x]==Offset){
    return(BumpOptimizedNewOffset[x]);
   }
  }
 }
 if(Height>MAXIMAGELINES)Error("Image optimize buffer full!!");
 SpacePtr-=SpaceStep;
 printf("\n%sOptimizing bumpmap..",SpacePtr);
 for(y=0;y<MAXIMAGELINES-Height;y++){
  for(x=0;x<32;x++){
   if(ImageBufferMap[y*32+x][0]==0)if(ImageBufferMap[y*32+x][1]==0){
    q=0;
    for(h=0;h<Height;h++){
     for(w=0;w<(Width/8);w++){
      if((ImageBufferMap[(y+h)*32+(x+w)][0]!=0)||(ImageBufferMap[(y+h)*32+(x+w)][1]!=0)){
       q=1;
       h=Height;
       w=Width/8;
      }
     }
    }
    if(q==0){
     for(h=0;h<Height;h++){
      for(w=0;w<(Width/8);w++){
       ImageBufferMap[(y+h)*32+(x+w)][0]=0xff;
       ImageBufferMap[(y+h)*32+(x+w)][1]=0xff;
      }
     }
     ofs=y*512+x*16;
     for(h=0;h<Height;h++){
      for(w=0;w<Width;w++){
       b=GetBump(&ImageBuffer[Offset],w,h,Width,Height,Bump);
       ImageBuffer2[ofs+h*512+w*2]=(BYTE)((WORD)b&0x00ff);
       ImageBuffer2[ofs+h*512+w*2+1]=(BYTE)(((WORD)(b>>8))&0x00ff);
      }
     }
     if((y+Height)>LastOptimized)LastOptimized=y+Height;
     SpacePtr+=SpaceStep;
     printf("done!");
     BumpOptimizedOffset[BumpUniqeImages]=Offset;
     BumpOptimizedNewOffset[BumpUniqeImages++]=ofs;
     return(ofs);
    }
   }
  }
 }
 Error("Image optimize buffer full!!");
 return(0);
}





void OptimizeImageBuffer(void){
LONG l;
LONG w;
LONG q;
LONG a;
LONG o;
LONG xx;
SBYTE Types[3][11]={"texture   \0","reflection\0","bump      \0"};
 LastOptimized=0;
 if(ImageLists==0){
  printf("\n%sNo optimizing of imagebuffer needed!",SpacePtr);
  return;
 }
 printf("\n%sOptimizing imagebuffer.",SpacePtr);
 SpacePtr-=SpaceStep;
 printf("\n%sImages in buffer: %d",SpacePtr,ImageLists);
 SpacePtr-=SpaceStep;
 ClearUsedList();
 UniqeImages=0;
 BumpUniqeImages=0;
 for(l=0;l<31;l++){
  w=(32-l)*8;
// Fit bumpmaps (needs 2 bytes,start at even !!!!) maps
  for(q=0;q<ImageLists;q++){
   if(ImageList[q].HSize==w)if(ImageList[q].Reflection==2){
    ImageList[q].NewImageOffset=PutOptimizedBump(ImageList[q].ImageOffset,ImageList[q].HSize,ImageList[q].VSize,ImageList[q].Bump);
   }
  }
// Fit reflectionmaps (start at even !!!!) maps
  for(q=0;q<ImageLists;q++){
   if(ImageList[q].HSize==w)if(ImageList[q].Reflection==1){
    ImageList[q].NewImageOffset=PutOptimizedRef(ImageList[q].ImageOffset,ImageList[q].HSize,ImageList[q].VSize);
   }
  }
 }
 for(l=0;l<31;l++){
  w=(32-l)*8;
// Fit texturemaps
  for(q=0;q<ImageLists;q++){
   if(ImageList[q].HSize==w)if(ImageList[q].Reflection==0){
    xx=0;
    for(a=0;a<ImageLists;a++){
     if(ImageList[a].Reflection==1){
      o=ImageList[a].ImageOffset-(ImageList[a].VSize/2)*256;
      if(o==ImageList[q].ImageOffset){
       ImageList[q].NewImageOffset=ImageList[a].NewImageOffset-(ImageList[a].VSize/2)*512;
       xx=1;
      }
     }
    }
    if(xx==0){
     a=PutOptimized1(ImageList[q].ImageOffset,ImageList[q].HSize,ImageList[q].VSize);
     if(a!=(LONG)-1){
      ImageList[q].NewImageOffset=a;
     }else{
      ImageList[q].NewImageOffset=PutOptimized0(ImageList[q].ImageOffset,ImageList[q].HSize,ImageList[q].VSize);
     }
    }
   }
  }
 }
 printf("\n%sNo: Type:      Size:   Offset:  Palette:",SpacePtr);
 for(q=0;q<ImageLists;q++){
  if(ImageList[q].Reflection==1)ImageList[q].NewImageOffset-=(((LONG)ImageList[q].VSize)*((LONG)256));
  if(TextureCenterX!=0)ImageList[q].NewImageOffset+=((LONG)ImageList[q].HSize);
  if(TextureCenterY!=0)ImageList[q].NewImageOffset+=(((LONG)ImageList[q].VSize)*((LONG)256));
  printf("\n%s%03d %s %03dx%03d %8ld %8ld",SpacePtr,q,&Types[ImageList[q].Reflection][0],ImageList[q].HSize,ImageList[q].VSize,ImageList[q].NewImageOffset,ImageList[q].PaletteOffset);
 }
 SpacePtr+=SpaceStep;
 printf("\n%sUnique images: %ld",SpacePtr,UniqeImages+BumpUniqeImages);
 SpacePtr+=SpaceStep;
}

/* ###############################################################################################

Lowlevel saving routines

############################################################################################### */

SBYTE  SaveErr[]="Couldn't write to file!! (Disk full??)\0";

void WriteBYTE(FILE * F,BYTE b){
 if(fwrite(&b,1,1,F)==0){
  fclose(F);
  Error(&SaveErr[0]);
 }
}

void WriteWORD(FILE * F,WORD w){
BYTE a[2];
 if(WritePC==0){
  a[0]=(BYTE)((w>>8)&0xff);
  a[1]=(BYTE)((w)&0xff);
  if(fwrite(&a[0],2,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }else{
  if(fwrite(&w,2,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }
}

void WriteLONG(FILE * F,LONG w){
BYTE a[4];
 if(WritePC==0){
  a[0]=(BYTE)((w>>24)&0xff);
  a[1]=(BYTE)((w>>16)&0xff);
  a[2]=(BYTE)((w>>8)&0xff);
  a[3]=(BYTE)((w)&0xff);
  if(fwrite(&a[0],4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }else{
  if(fwrite(&w,4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }
}

void WriteInt(FILE * F,SWORD w){
BYTE a[2];
WORD q;
 memmove(&q,&w,2);
 if(WritePC==0){
  a[0]=(BYTE)((q>>8)&0xff);
  a[1]=(BYTE)((q)&0xff);
  if(fwrite(&a[0],2,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }else{
  if(fwrite(&w,2,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }
}

void WriteFloat(FILE * F,FLOAT w){
BYTE a[4];
LONG q;
 memmove(&q,&w,4);
 if(WritePC==0){
  a[0]=(BYTE)((q>>24)&0xff);
  a[1]=(BYTE)((q>>16)&0xff);
  a[2]=(BYTE)((q>>8)&0xff);
  a[3]=(BYTE)((q)&0xff);
  if(fwrite(&a[0],4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }else{
  if(fwrite(&q,4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }
}

void Writeslong(FILE * F,SLONG w){
BYTE a[4];
LONG q;
 memmove(&q,&w,4);
 if(WritePC==0){
  a[0]=(BYTE)((q>>24)&0xff);
  a[1]=(BYTE)((q>>16)&0xff);
  a[2]=(BYTE)((q>>8)&0xff);
  a[3]=(BYTE)((q)&0xff);
  if(fwrite(&a[0],4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }else{
  if(fwrite(&q,4,1,F)==0){
   fclose(F);
   Error(&SaveErr[0]);
  }
 }
}

/* ###############################################################################################

Highlevel saving routines

############################################################################################### */

LONG WriteSurface(FILE * f){
LONG l;
BYTE t;
BYTE ok;
 printf("\n%sWriting surfaces..     ",SpacePtr);
 for(l=0;l<TotalSurface;l++){
  t=PolyS[l].Flat.Mode;
  WriteBYTE(f,t);
  t%=8;
  ok=0;
  if(t==0){
   WriteBYTE(f,0);
   WriteBYTE(f,PolyS[l].Flat.Side);
   WriteBYTE(f,0);
   WriteLONG(f,PolyS[l].Flat.PaletteOffset);
   WriteLONG(f,0);
   WriteLONG(f,0);
   ok=1;
  }
  if(t==1){
   WriteBYTE(f,0);
   WriteBYTE(f,PolyS[l].Texture.Side);
   WriteBYTE(f,0);
   WriteWORD(f,PolyS[l].Texture.ImageNumber);
   WriteWORD(f,0);
   WriteLONG(f,0);
   WriteLONG(f,0);
   ok=1;
  }
  if(t==2){
   WriteBYTE(f,PolyS[l].Reflection.ReflectionShift);
   WriteBYTE(f,PolyS[l].Reflection.Side);
   WriteBYTE(f,0);
   WriteWORD(f,PolyS[l].Reflection.ReflectionImageNumber);
   WriteWORD(f,0);
   WriteLONG(f,0);
   WriteLONG(f,0);
   ok=1;
  }
  if(t==3){
   WriteBYTE(f,PolyS[l].TReflection.ReflectionShift);
   WriteBYTE(f,PolyS[l].TReflection.Side);
   WriteBYTE(f,PolyS[l].TReflection.ColourShift);
   WriteWORD(f,PolyS[l].TReflection.ImageNumber);
   WriteWORD(f,PolyS[l].TReflection.ReflectionImageNumber);
   WriteLONG(f,PolyS[l].TReflection.ReflectionColourOffset);
   WriteLONG(f,0);
   ok=1;
  }
  if(t==4){
   WriteBYTE(f,PolyS[l].BReflection.ReflectionShift);
   WriteBYTE(f,PolyS[l].BReflection.Side);
   WriteBYTE(f,PolyS[l].TReflection.ColourShift);
   WriteWORD(f,PolyS[l].BReflection.ReflectionImageNumber);
   WriteWORD(f,PolyS[l].BReflection.BumpImageNumber);
   WriteLONG(f,0);
   WriteLONG(f,0);
   ok=1;
  }
  if(t==5){
   WriteBYTE(f,PolyS[l].BTReflection.ReflectionShift);
   WriteBYTE(f,PolyS[l].BTReflection.Side);
   WriteBYTE(f,PolyS[l].BTReflection.ColourShift);
   WriteWORD(f,PolyS[l].BTReflection.ImageNumber);
   WriteWORD(f,PolyS[l].BTReflection.ReflectionImageNumber);
   WriteWORD(f,PolyS[l].BTReflection.BumpImageNumber);
   WriteWORD(f,0);
   WriteLONG(f,PolyS[l].BTReflection.ReflectionColourOffset);
   ok=1;
  }
  if(ok==0){
		// debug
		printf("\nType %d was found at number %d",t,l);
		Error("Wrong type in surface list!!");
	   }
 }
 printf("%10ld bytes saved!",TotalSurface*16);
 return(TotalSurface*16);
}


LONG ObjectHeaderSize = 8*4;

LONG WriteObject(FILE * f){
LONG l,q;
FLOAT big;
DOUBLE x,y,z;
LONG Header;
FLOAT	v0x,v0y,v0z,v1x,v1y,v1z;
FLOAT	nx,ny,nz;
FLOAT	le;
 Header=ObjectHeaderSize;
 printf("\n%sWriting objectdata..   ",SpacePtr);
 if(ObjectShort!=0)return(0);
 WriteLONG(f,ObjectCoords);
 WriteLONG(f,Header);
 Header+=(ObjectCoords*16);
 if(UsePhong==0){
  WriteLONG(f,0);
  WriteLONG(f,0);
 }else{
  WriteLONG(f,ObjectCoords);
  WriteLONG(f,Header);
  Header+=(ObjectCoords*16);
 }
 WriteLONG(f,Polygons);
 WriteLONG(f,Header);
 Header+=(Polygons*32);
 if(UseMapping==0){
  WriteLONG(f,0);
 }else{
  WriteLONG(f,Header);
  Header+=(Polygons*32);
 }
 ObjectOffset+=Header;
 big=-10;
 for(l=0;l<ObjectCoords;l++){
  x=(DOUBLE)ObjectCoord[l*3+0];
  y=(DOUBLE)ObjectCoord[l*3+1];
  z=(DOUBLE)ObjectCoord[l*3+2];
  x*=x;
  y*=y;
  z*=z;
  x=sqrt(x+y+z);
  if(x>big)big=x;
 }
 big*=1.03;
 if(SaveAsFloat==0){
  WriteLONG(f,(LONG)big);
  for(l=0;l<ObjectCoords;l++){
   Writeslong(f,(SLONG)ObjectUsedCoord[l]);
   Writeslong(f,(SLONG)ObjectCoord[l*3+0]);
   Writeslong(f,(SLONG)ObjectCoord[l*3+1]);
   Writeslong(f,(SLONG)ObjectCoord[l*3+2]);
  }
 }else{
  WriteFloat(f,big);
  for(l=0;l<ObjectCoords;l++){
   Writeslong(f,(SLONG)ObjectUsedCoord[l]);
   WriteFloat(f,ObjectCoord[l*3+0]);
   WriteFloat(f,ObjectCoord[l*3+1]);
   WriteFloat(f,ObjectCoord[l*3+2]);
  }
 }
 if(UsePhong!=0){
  for(l=0;l<ObjectCoords;l++){
   if(SaveAsFloat==0){
    Writeslong(f,(SLONG)PhongUsedCoord[l]);
    Writeslong(f,(SLONG)PhongCoord[l*3+0]);
    Writeslong(f,(SLONG)PhongCoord[l*3+1]);
    Writeslong(f,(SLONG)PhongCoord[l*3+2]);
   }else{
    Writeslong(f,(SLONG)PhongUsedCoord[l]);
    WriteFloat(f,PhongCoord[l*3+0]);
    WriteFloat(f,PhongCoord[l*3+1]);
    WriteFloat(f,PhongCoord[l*3+2]);
   }
  }
 }
 for(q=0;q<Polygons;q++){
  l=(LONG)PolyData[q][1];
  l<<=4;
  WriteLONG(f,l);
  l=(LONG)PolyData[q][2];
  l<<=4;
  WriteLONG(f,l);
  l=(LONG)PolyData[q][3];
  l<<=4;
  WriteLONG(f,l);
  l=(LONG)PolyData[q][0]+SurfaceBase;
  l--;
  l<<=4;
  WriteWORD(f,l);
  WriteWORD(f,0);
 /*** Calc plane ekv ***/
   v0x=ObjectCoord[PolyData[q][2]*3+0]-ObjectCoord[PolyData[q][1]*3+0];
   v0y=ObjectCoord[PolyData[q][2]*3+1]-ObjectCoord[PolyData[q][1]*3+1];
   v0z=ObjectCoord[PolyData[q][2]*3+2]-ObjectCoord[PolyData[q][1]*3+2];
   v1x=ObjectCoord[PolyData[q][3]*3+0]-ObjectCoord[PolyData[q][1]*3+0];
   v1y=ObjectCoord[PolyData[q][3]*3+1]-ObjectCoord[PolyData[q][1]*3+1];
   v1z=ObjectCoord[PolyData[q][3]*3+2]-ObjectCoord[PolyData[q][1]*3+2];
   nx=v0y*v1z-v0z*v1y;
   ny=v0z*v1x-v0x*v1z;
   nz=v0x*v1y-v0y*v1x;
   le=nx*nx+ny*ny+nz*nz;
   le=sqrt(le);
   nx=nx*4096.0/le;
   ny=ny*4096.0/le;
   nz=nz*4096.0/le;
   v0x=ObjectCoord[PolyData[q][1]*3+0];
   v0y=ObjectCoord[PolyData[q][1]*3+1];
   v0z=ObjectCoord[PolyData[q][1]*3+2];
   v0x*=nx;
   v0y*=ny;
   v0z*=nz;
   v0x=-v0x;
   v0x-=v0y;
   v0x-=v0z;
   if(SaveAsFloat==0){
    WriteLONG(f,(LONG)nx);
   	WriteLONG(f,(LONG)ny);
   	WriteLONG(f,(LONG)nz);
   	WriteLONG(f,(LONG)v0x);
   }else{
    WriteFloat(f,nx/4096.0);
   	WriteFloat(f,ny/4096.0);
   	WriteFloat(f,nz/4096.0);
   	WriteFloat(f,v0x/4096.0);
   }
 }
 if(UseMapping!=0){
  for(q=0;q<Polygons;q++){
   if(SaveAsFloat==0){
    WriteLONG(f,(LONG)UVData[q][0]);
   	WriteLONG(f,(LONG)UVData[q][1]);
   	WriteLONG(f,(LONG)UVData[q][2]);
   	WriteLONG(f,(LONG)UVData[q][3]);
   	WriteLONG(f,(LONG)UVData[q][4]);
   	WriteLONG(f,(LONG)UVData[q][5]);
	WriteLONG(f,0);
	WriteLONG(f,0);
   }else{
    WriteFloat(f,UVData[q][0]);
   	WriteFloat(f,UVData[q][1]);
   	WriteFloat(f,UVData[q][2]);
   	WriteFloat(f,UVData[q][3]);
   	WriteFloat(f,UVData[q][4]);
   	WriteFloat(f,UVData[q][5]);
	WriteFloat(f,0);
	WriteFloat(f,0);
	}
  }
 }
 printf("%10ld bytes saved!",Header);
 return(Header);
}

void WriteAnimObjectHeader(FILE * f,FLOAT big,LONG usephong){
LONG Header;
 Header=ObjectHeaderSize;
 WriteLONG(f,ObjectCoords);
 WriteLONG(f,Header);
 Header+=(ObjectCoords*16);
//debug
 printf("\n\nGURKA:  %ld\n",usephong);
 if(usephong==0){
  WriteLONG(f,0);
  WriteLONG(f,0);
 }else{
  WriteLONG(f,ObjectCoords);
  WriteLONG(f,Header);
  Header+=(ObjectCoords*16);
 }
 WriteLONG(f,Polygons);
 WriteLONG(f,Header);
 Header+=(Polygons*32);
 if(UseMapping==0){
  WriteLONG(f,0);
 }else{
  WriteLONG(f,Header);
  Header+=(Polygons*32);
 }
 if(SaveAsFloat==0){
 	WriteLONG(f,(LONG)big);
 }else{
 	WriteFloat(f,big);
 }
}

LONG WriteImage(FILE * f){
LONG l;
 printf("\n%sWriting imagedata..    ",SpacePtr);
 if(LastOptimized==0)return(0);
 if(fwrite(&ImageBuffer2[0],512*LastOptimized,1,f)==0)Error(&SaveErr[0]);
 printf("%10ld bytes saved!",512*LastOptimized);
 return(512*LastOptimized);
}

LONG WriteImageList(FILE * f){
LONG l;
 printf("\n%sWriting imagelist..    ",SpacePtr);
 for(l=0;l<ImageLists;l++){
  WriteLONG(f,ImageList[l].NewImageOffset);
  WriteLONG(f,ImageList[l].PaletteOffset);
  WriteWORD(f,ImageList[l].Frames);
  WriteWORD(f,ImageList[l].FrameSpeed);
  WriteBYTE(f,ImageList[l].FrameLoop);
  WriteBYTE(f,(BYTE)(ImageList[l].HSize/2));
  WriteBYTE(f,ImageList[l].Reflection);
  WriteBYTE(f,(BYTE)(ImageList[l].VSize/2));
 }
 printf("%10ld bytes saved!",ImageLists*16);
 return(ImageLists*16);
}

LONG WritePalette(FILE * f){
 printf("\n%sWriting palette..      ",SpacePtr);
 if(LastPaletteLine!=0)if(fwrite(&PaletteBuffer[0],LastPaletteLine*256*4,1,f)==0)Error(&SaveErr[0]);
 printf("%10ld bytes saved!",LastPaletteLine*256*4);
 return(LastPaletteLine*256*4);
}

LONG ProcessObject(SBYTE * filename){
LONG offset;
LONG q;
 SpacePtr-=SpaceStep;
 offset=ObjectOffset;
 LoadObject(filename);
 SpacePtr+=SpaceStep;
 q=WriteObject(OutputFile);
 return(offset);
}


//########################################################################
//############################################## SCENE-RELATED ROUTINES ##
//########################################################################



#define MAXKEYFRAMES 4096
#define MAXANIMFRAMES 8192
#define MAXMOTIONLENGTH  (4096)
#define MAXMOTIONFRAMES  (MAXOBJECTS*MAXMOTIONLENGTH)
#define MAXENVELOPES 1024
#define MAXENVFRAMES 8192
#define MAXANIMBUFFER 32768

struct SceneObjectStr{ SBYTE Name[208];
      WORD Type;
    //    0  Object
    //    1  Light
    //    2  Camera
    //    3  Morph target
      WORD Loop;
      WORD InfoChannels;
      WORD KeyFrames;
      LONG KeyFrameStart;
      BYTE Red;
      BYTE Green;
      BYTE Blue;
      FLOAT Int;
      WORD LightType;
      WORD LightImageType;
      FLOAT LightSpot;
      FLOAT LightSize;
      WORD MotionType;
      WORD MotionTarget;
      LONG MotionFrames;
      FLOAT CameraZoom;
      LONG MotionOfs;
      WORD MotionComplete;
      WORD MorphTarget;
      LONG AnimFrames;
      WORD AnimLoop;
      LONG AnimEnvelope;
      LONG AnimOffset;
      LONG ObjectOffset;  // Light image offset for light
      LONG CoordOffset;  // Light palette offset for light
      LONG ParentEntry;
      WORD Hidden;
      FLOAT ScaleX;
      FLOAT ScaleY;
      FLOAT ScaleZ;
      };

#define MOTIONCHANNELS 6
typedef DOUBLE   MotionChannelVectors[MOTIONCHANNELS];
typedef struct  KeyFrameStruct{  MotionChannelVectors  cv;
          DOUBLE  tens,cont,bias;
          SWORD   linear;
          SWORD   step;
         }KeyFrameType;

typedef struct MotionStruct{   KeyFrameType *keylist;
          SWORD     keys,steps;
       }Motion;

SBYTE * SceneArg[32];
FLOAT KeyFrame[MAXKEYFRAMES][11];
BYTE MotionData[MAXMOTIONFRAMES*13];
LONG AnimData[MAXANIMFRAMES/4];
LONG AnimBuffer[MAXANIMBUFFER];
LONG MorphObjectOffset[MAXENVFRAMES][2];
FLOAT EnvelopeValues[MAXENVFRAMES];
FLOAT EnvelopeData[MAXENVELOPES*16][6];
WORD EnvelopeKeyFrames[MAXENVELOPES];
LONG EnvelopePtr[MAXENVELOPES];
struct SceneObjectStr SceneObject[MAXOBJECTS];
KeyFrameType KeyList[MAXMOTIONLENGTH];


BYTE * ScenePtr;
LONG SceneLength;
LONG ScenePos;
WORD SceneObjects;

LONG KeyFrames;

WORD SceneStartFrame	=	1;
WORD SceneEndFrame		=	30;
WORD SceneFrameSteps	=	1;
LONG SceneFrames;
FLOAT SceneFPS;
FLOAT SceneOldFPS;

LONG AnimOfs;
LONG MotionOfs;
LONG EnvelopeDataPtr;
WORD Envelopes;
WORD EnvCurrent;
LONG AnimBufferOffset;
LONG WorldObjects;
WORD CameraObject;

/* ###############################################################################################

Scene Reading Routines (Low level)

############################################################################################### */

FLOAT ReadFloat(SBYTE * ptr){
FLOAT sign = 1.0;
FLOAT decimal = 1.0;
DOUBLE number = 0.0;
FLOAT t;
DOUBLE expsign = 10.0;
LONG expvalue= 0;
WORD w;
BYTE d;
BYTE b;
BYTE e;
 if(*(ptr)=='-'){
  sign=-1.0;
  ptr++;
 }
 d=0;
 e=0;
 do{
  b=*(ptr++);
  if(b!=0){
   if((b=='.')||(b==',')){
    if(d!=0)Error("Too many decimalsigns!!");
    d=1;
   }else{
    if(b=='e'){
     if(*(ptr)=='-'){
      expsign=0.10;
      ptr++;
     }
     e=1;
    }else{
     if(b<'0')Error("Illegal ASCII-char in number field!!");
     if(b>'9')Error("Illegal ASCII-char in number field!!");
     t=((FLOAT)(b-'0'));
     if(e==0){
      if(d!=0){
       decimal/=10.0;
       t*=decimal;
       number+=t;
      }else{
       number*=10.0;
       number+=t;
      }
     }else{
      expvalue*=10;
      expvalue+=(LONG)(b-'0');
     }
    }
   }
  }
 }while(b!=0);
 number*=sign;
 if(expvalue!=0){
  for(w=0;w<expvalue;w++){
   number*=expsign;
  }
 }
 return(number);
}

LONG ReadLONG(SBYTE * ptr){
 return((LONG)ReadFloat(ptr));
}

SLONG ReadLongInt(SBYTE * ptr){
 return((SLONG)ReadFloat(ptr));
}

void NextRow(void){
BYTE * p;
WORD w;
BYTE b;
 p=ScenePtr;
 do{
 }while(*(++ScenePtr)!=0);
 ScenePtr--;
 do{
  SceneLength++;
 }while(*(++ScenePtr)==0);
 b=1;
 for(w=0;w<32;w++){
  if(b!=0){
   if(*(p)<33)while(*(++p)<33);
   SceneArg[w]=(SBYTE *)p;
   while(*(p++)>32);
   if(*(p-1)==32){
    *(p-1)=0;
   }else{
    b=0;
   }
  }else{
   SceneArg[w]=(SBYTE *)p;
  }
 }
}

/* ###############################################################################################

Spline calculating routines

############################################################################################### */


// Compute Hermite spline coeficients for t, where 0 <= t <= 1.

void Hermite (DOUBLE t,DOUBLE *h1,DOUBLE *h2,DOUBLE *h3,DOUBLE *h4){
DOUBLE t2,t3,z;
 t2=t*t;
 t3=t*t2;
 z=3.0*t2-t3-t3;
 *h1=1.0-z;
 *h2=z;
 *h3=t3-t2-t2+t;
 *h4=t3-t2;
}

// Compute the motion channel vector for the given step.  Step can be
// fractional but values correspond to frames.

void MotionCalcStep( Motion * mot,
      SLONG * xs,
      SLONG * ys,
      SLONG * zs,
      WORD * xa,
      WORD * ya,
      WORD * za,
      DOUBLE step){
KeyFrameType *keyPrev;
KeyFrameType *key0;
KeyFrameType *key1;
KeyFrameType *keyNext;
DOUBLE   t,h1,h2,h3,h4,res,d10;
DOUBLE   dd0a,dd0b,ds1a,ds1b;
DOUBLE   adj0,adj1,dd0,ds1;
SWORD   i,tlength;
WORD	forcelin;
	forcelin=0;
 if(mot->keys<4)forcelin=1;
// If there is but one key, the values are constant.
 if(mot->keys==1){
  res=mot->keylist[0].cv[0];
  res*=Scale;
  *(xs)=(SLONG)res;
  res=mot->keylist[0].cv[1];
  res*=Scale;
  *(ys)=(SLONG)res;
  res=mot->keylist[0].cv[2];
  res*=Scale;
  *(zs)=(SLONG)res;
  res=mot->keylist[0].cv[3];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(xa)=((WORD)(res))%AngleScale;
  res=mot->keylist[0].cv[4];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(ya)=((WORD)(res))%AngleScale;
  res=mot->keylist[0].cv[5];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(za)=((WORD)(res))%AngleScale;
  return;
 }
 key0=mot->keylist;
 key0+=(mot->keys-1);
 if(key0->step<step){
  res=key0->cv[0];
  res*=Scale;
  *(xs)=(SLONG)res;
  res=key0->cv[1];
  res*=Scale;
  *(ys)=(SLONG)res;
  res=key0->cv[2];
  res*=Scale;
  *(zs)=(SLONG)res;
  res=key0->cv[3];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(xa)=((WORD)(res))%AngleScale;
  res=key0->cv[4];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(ya)=((WORD)(res))%AngleScale;
  res=key0->cv[5];
  res*=(DOUBLE)AngleScale;
  res/=LWAngleScale;
  res+=(8*AngleScale);
  *(za)=((WORD)(res))%AngleScale;
  return;
 }
// Get keyframe pair to evaluate.  This should be within the range
// of the motion or this will raise an illegal access.
 key0=mot->keylist;
 while(step>key0[1].step)key0++;


 key1=key0+1;
 keyPrev=key0-1;
 keyNext=key1+1;
 if(key0==mot->keylist)keyPrev=key0;
 if(key1==mot->keylist+mot->keys-1)keyNext=key1;

 step-=key0->step;
// Get tween length and fractional tween position.
 tlength=key1->step-key0->step;
 t=step/tlength;
// Precompute spline coefficients.
 if((!key1->linear)&&(forcelin==0)){
  Hermite(t,&h1,&h2,&h3,&h4);
  dd0a=(1.0-key0->tens)*(1.0+key0->cont)*(1.0+key0->bias);
  dd0b=(1.0-key0->tens)*(1.0-key0->cont)*(1.0-key0->bias);
  ds1a=(1.0-key1->tens)*(1.0-key1->cont)*(1.0+key1->bias);
  ds1b=(1.0-key1->tens)*(1.0+key1->cont)*(1.0-key1->bias);
  if(key0->step!=0)adj0=tlength/(DOUBLE)((key1->step)-(keyPrev->step));
  if(key1->step!=mot->steps)adj1=tlength/(DOUBLE)((keyNext->step)-(key0->step));
 }

// Compute the channel components.
 for(i=0;i<MOTIONCHANNELS;i++){
  d10=key1->cv[i]-key0->cv[i];
  if((!key1->linear)&&(forcelin==0)){
   if(key0->step==0){
    dd0=0.5*(dd0a+dd0b)*d10;
   }else{
    dd0=adj0*(dd0a*((key0->cv[i])-(keyPrev->cv[i]))+dd0b*d10);
   }
   if(key1->step==mot->steps){
    ds1=0.5*(ds1a+ds1b)*d10;
   }else{
    ds1=adj1*(ds1a*d10+ds1b*((keyNext->cv[i])-(key1->cv[i])));
   }
   res=key0->cv[i]*h1+key1->cv[i]*h2+dd0*h3+ds1*h4;

  }else{
   res=key0->cv[i]+t*d10;
  }
  if(i<3){
   res*=Scale;
  }else{
   res*=(DOUBLE)AngleScale;
   res/=LWAngleScale;
   res+=(8*AngleScale);
  }
  if(i==0)*(xs)=(SLONG)res;
  if(i==1)*(ys)=(SLONG)res;
  if(i==2)*(zs)=(SLONG)res;
  if(i==3)*(xa)=((WORD)(res))%AngleScale;
  if(i==4)*(ya)=((WORD)(res))%AngleScale;
  if(i==5)*(za)=((WORD)(res))%AngleScale;
 }
}

void InsertMotion(BYTE * Dest,SLONG xp,SLONG yp,SLONG zp,WORD xa,WORD ya,WORD za){
LONG l;
LONG l0;
LONG l1;
 memmove(&l,&xp,4);
 *(Dest+2)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+1)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+0)=(BYTE)(l&0x0000ff);
 Dest+=3;
 memmove(&l,&yp,4);
 *(Dest+2)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+1)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+0)=(BYTE)(l&0x0000ff);
 Dest+=3;
 memmove(&l,&zp,4);
 *(Dest+2)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+1)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+0)=(BYTE)(l&0x0000ff);
 Dest+=3;
 l=(LONG)(xa);
 l%=1024;
 l0=(LONG)(ya);
 l0%=1024;
 l1=(LONG)(za);
 l1%=1024;
 l<<=22;
 l0<<=12;
 l1<<=2;
 l|=l0;
 l|=l1;
 *(Dest+3)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+2)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+1)=(BYTE)(l&0x0000ff);
 l>>=8;
 *(Dest+0)=(BYTE)(l&0x0000ff);
}

void MakeMotionPath(struct SceneObjectStr * obj){
LONG l,q;
LONG LastFrame;
WORD w;
FLOAT f;
SLONG PosX,PosY,PosZ;
WORD AngX,AngY,AngZ;
Motion m;
 if(obj->MotionType==0)Error("No motion (positioning) for object!!");
 if(obj->MotionType==2)Error("No position for object!!");
 if(obj->Type==3){
  printf("\n%sNo motion needed for morphtarget",SpacePtr-SpaceStep);
  return;
 }
 if(obj->ParentEntry!=0){
  l=obj->ParentEntry-1;
  w=0;
  do{
   if(SceneObject[l].Type==3)w=1;
   if(SceneObject[l].ParentEntry!=0)l=SceneObject[l].ParentEntry-1;
   if(SceneObject[l].Type==3)w=1;
  }while((w==0)&&(SceneObject[l].ParentEntry!=0));
  if(w==1){
   printf("\n%sNo motion needed for morphtarget",SpacePtr-SpaceStep);
   return;
  }
 }
 SpacePtr-=SpaceStep;
 printf("\n%sKeyframes:    %d",SpacePtr,obj->KeyFrames);
 obj->MotionOfs=MotionOfs;
 for(l=0;l<obj->KeyFrames;l++){
  KeyList[l].cv[0]=KeyFrame[obj->KeyFrameStart+l][0];
  KeyList[l].cv[1]=KeyFrame[obj->KeyFrameStart+l][1];
  KeyList[l].cv[2]=KeyFrame[obj->KeyFrameStart+l][2];
  KeyList[l].cv[3]=KeyFrame[obj->KeyFrameStart+l][3];
  KeyList[l].cv[4]=KeyFrame[obj->KeyFrameStart+l][4];
  KeyList[l].cv[5]=KeyFrame[obj->KeyFrameStart+l][5];
  f=KeyFrame[obj->KeyFrameStart+l][6];
  f*=SceneFPS;
  f/=SceneOldFPS;
  KeyList[l].step=(SWORD)f;
  KeyList[l].linear=(SWORD)KeyFrame[obj->KeyFrameStart+l][7];
  KeyList[l].tens=KeyFrame[obj->KeyFrameStart+l][8];
  KeyList[l].cont=KeyFrame[obj->KeyFrameStart+l][9];
  KeyList[l].bias=KeyFrame[obj->KeyFrameStart+l][10];
 }
 LastFrame=(LONG)f;
 if(LastFrame==0)LastFrame=1;
 m.keylist=&KeyList[0];
 m.keys=obj->KeyFrames;
 m.steps=SceneFrames;
 if(LastFrame>SceneFrames)LastFrame=SceneFrames;
 for(l=0;l<LastFrame;l++){
  MotionCalcStep(&m,
      &PosX,
      &PosY,
      &PosZ,
      &AngX,
      &AngY,
      &AngZ,
      l);
  InsertMotion(&MotionData[MotionOfs],PosX,PosY,PosZ,AngX,AngY,AngZ);
  MotionOfs+=13;
  if(MotionOfs==MAXMOTIONFRAMES)Error("Too many motion frames!!");
 }
 obj->MotionFrames=LastFrame;
 printf("\n%sMotionoffset: %d",SpacePtr,obj->MotionOfs);
 printf("\n%sMotionframes: %d",SpacePtr,obj->MotionFrames);
 obj->MotionComplete=0;
 if(obj->MotionType==1)obj->MotionComplete=1;
 SpacePtr+=SpaceStep;
}

/* ###############################################################################################

Evelope routines

############################################################################################### */

LONG InsertEnvelope(void){
WORD q;
WORD w;
DOUBLE f;
 EnvCurrent=Envelopes;
 NextRow();
 if(strcmp("1\0",SceneArg[0])!=0)Error("Only supporting 1 channeld envelopes!!");
 NextRow();
 EnvelopeKeyFrames[EnvCurrent]=ReadLONG(SceneArg[0]);
 printf("\n%sEnvelope keyframes: %d",SpacePtr-SpaceStep,EnvelopeKeyFrames[EnvCurrent]);
 EnvelopePtr[EnvCurrent]=EnvelopeDataPtr;
 for(q=0;q<EnvelopeKeyFrames[EnvCurrent];q++){
  NextRow();
  EnvelopeData[EnvelopeDataPtr][0]=ReadFloat(SceneArg[0]);
  NextRow();
  for(w=1;w<6;w++){
   EnvelopeData[EnvelopeDataPtr][w]=ReadFloat(SceneArg[w-1]);
  }
  EnvelopeDataPtr++;
  if(EnvelopeDataPtr==MAXENVELOPES*16)Error("Too much envelopedata!!");
 }
 Envelopes++;
 if(Envelopes==MAXENVELOPES)Error("Too many envelopes!!");
 return(EnvCurrent);
}

void ProcessEnvelopes(void){
LONG l;
LONG q;
LONG a;
DOUBLE f;
 if(Envelopes==0)return;
 printf("\n%sTimescaling envelopes..",SpacePtr);
 for(l=0;l<Envelopes;l++){
  q=EnvelopeKeyFrames[l];
  for(a=0;a<q;a++){
   f=EnvelopeData[EnvelopePtr[l]+a][1];
   f*=SceneFPS;
   f/=SceneOldFPS;
   EnvelopeData[EnvelopePtr[l]+a][1]=f;
  }
 }
 printf("done!");
}

LONG GetEnvelopeFrames(LONG EnvelopeNumber){
LONG l;
 l=EnvelopeKeyFrames[EnvelopeNumber];
 l--;
 l+=EnvelopePtr[EnvelopeNumber];
 return((LONG)EnvelopeData[l][1]);
}

void MakeEnvelopeSpline(Motion * mot,
      FLOAT * dest,
      DOUBLE step){
KeyFrameType *keyPrev;
KeyFrameType *key0;
KeyFrameType *key1;
KeyFrameType *keyNext;
DOUBLE   t,h1,h2,h3,h4,res,d10;
DOUBLE   dd0a,dd0b,ds1a,ds1b;
DOUBLE   adj0,adj1,dd0,ds1;
SWORD   i,tlength;
// If there is but one key, the values are constant.
 if(mot->keys==1){
  *(dest)=mot->keylist[0].cv[0];
  return;
 }
 key0=mot->keylist;
 key0+=(mot->keys-1);
 if(key0->step<step){
  *(dest)=mot->keylist[0].cv[0];
  return;
 }
// Get keyframe pair to evaluate.  This should be within the range
// of the motion or this will raise an illegal access.
 key0=mot->keylist;
 while(step>key0[1].step)key0++;
 key1=key0+1;
 keyPrev=key0-1;
 keyNext=key1+1;
 if(key0==mot->keylist)keyPrev=key0;
 if(key1==mot->keylist+mot->keys-1)keyNext=key1;
 step-=key0->step;
// Get tween length and fractional tween position.
 tlength=key1->step-key0->step;
 t=step/tlength;
// Precompute spline coefficients.
 if(!key1->linear){
  Hermite(t,&h1,&h2,&h3,&h4);
  dd0a=(1.0-key0->tens)*(1.0+key0->cont)*(1.0+key0->bias);
  dd0b=(1.0-key0->tens)*(1.0-key0->cont)*(1.0-key0->bias);
  ds1a=(1.0-key1->tens)*(1.0-key1->cont)*(1.0+key1->bias);
  ds1b=(1.0-key1->tens)*(1.0+key1->cont)*(1.0-key1->bias);
  if(key0->step!=0)adj0=tlength/(DOUBLE)((key1->step)-(keyPrev->step));
  if(key1->step!=mot->steps)adj1=tlength/(DOUBLE)((keyNext->step)-(key0->step));
 }

// Compute the channel components.
 for(i=0;i<MOTIONCHANNELS;i++){
  d10=key1->cv[i]-key0->cv[i];
  if(!key1->linear){
   if(key0->step==0){
    dd0=0.5*(dd0a+dd0b)*d10;
   }else{
    dd0=adj0*(dd0a*((key0->cv[i])-(keyPrev->cv[i]))+dd0b*d10);
   }
   if(key1->step==mot->steps){
    ds1=0.5*(ds1a+ds1b)*d10;
   }else{
    ds1=adj1*(ds1a*d10+ds1b*((keyNext->cv[i])-(key1->cv[i])));
   }
   res=key0->cv[i]*h1+key1->cv[i]*h2+dd0*h3+ds1*h4;

  }else{
   res=key0->cv[i]+t*d10;
  }
  if(i==0)*(dest)=res;
 }
}

void MakeEnvelopeValues(LONG EnvelopeNumber){
LONG l;
Motion m;
LONG frames;
FLOAT f;
 for(l=0;l<EnvelopeKeyFrames[EnvelopeNumber];l++){
  KeyList[l].cv[0]=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][0];
  KeyList[l].cv[1]=0;
  KeyList[l].cv[2]=0;
  KeyList[l].cv[3]=0;
  KeyList[l].cv[4]=0;
  KeyList[l].cv[5]=0;
  KeyList[l].step=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][1];
  KeyList[l].linear=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][2];
  KeyList[l].tens=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][3];
  KeyList[l].cont=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][4];
  KeyList[l].bias=EnvelopeData[EnvelopePtr[EnvelopeNumber]+l][5];
 }
 frames=(LONG)GetEnvelopeFrames(EnvelopeNumber);
 m.keylist=&KeyList[0];
 m.keys=EnvelopeKeyFrames[EnvelopeNumber];
 m.steps=frames;
 if(frames>=MAXENVFRAMES)Error("Too many envelopeframes!!");
 for(l=0;l<frames;l++){
  MakeEnvelopeSpline(&m,&f,l);
  EnvelopeValues[l]=f;
 }
}

/* ###############################################################################################

Scene Reading Routines (High level)

############################################################################################### */


void LoadScene(SBYTE * name){
LONG l,q;
WORD w;
LONG sob;
SBYTE CameraName[]="Camera\0";
SLONG l0,l1;
WORD BehaviorType;
WORD waslight=0;
 SceneObjects = 0;
 KeyFrames  = 0;
 EnvCurrent  = 0;
 EnvelopeDataPtr = 0;
 printf("\n%sReading scene '%s'",SpacePtr,name);
 SpacePtr-=SpaceStep;
 ScenePtr=&TempImage[0];
 printf("\n%s",SpacePtr);
 SceneLength=LoadFile(name,ScenePtr,MAXIMAGESIZE);
 for(l=0;l<SceneLength;l++){
  if(*(ScenePtr+l)<32)*(ScenePtr+l)=0;
 }
 *(ScenePtr+l+1)=0;
 *(ScenePtr+l+2)=32;
 ScenePos=0;
 NextRow();
 if(strcmp("LWSC\0",SceneArg[0])!=0)Error("This is NOT a LightWave scene file!!");
 NextRow();
 if(strcmp("1\0",SceneArg[0])!=0)Error("Only supports scenefileversion 1 !!");
 SpacePtr-=SpaceStep;
 do{
  NextRow();
  ScenePos=ScenePtr-&TempImage[0];
  if(strcmp("FirstFrame\0",SceneArg[0])==0){
   SceneStartFrame=ReadLONG(SceneArg[1]);
   printf("\n%sStart animationframe: %ld",SpacePtr,SceneStartFrame);
  }
  if(strcmp("LastFrame\0",SceneArg[0])==0){
   SceneEndFrame=ReadLONG(SceneArg[1]);
   printf("\n%sEnd animationframes: %ld",SpacePtr,SceneEndFrame);
  }
  if(strcmp("FrameStep\0",SceneArg[0])==0){
   SceneFrameSteps=ReadLONG(SceneArg[1]);
   printf("\n%sFrame steps: %ld",SpacePtr,SceneFrameSteps);
  }
  if(strcmp("FramesPerSecond\0",SceneArg[0])==0){
   SceneFPS=ReadFloat(SceneArg[1]);
   printf("\n%sFrames/second: %f",SpacePtr,SceneFPS);
  }
  if(strcmp("LoadObject\0",SceneArg[0])==0){
   sob=SceneObjects;
   SceneObjects++;
   if(SceneObjects==MAXOBJECTS)Error("Too many objects!!");
   memmove(&SceneObject[sob].Name[0],SceneArg[1],strlen(SceneArg[1])+1);
   SceneObject[sob].Type=0;
   printf("\n\n%sObject '%s' numbered as %d",SpacePtr,SceneArg[1],sob);
   SceneObject[sob].MotionType=0;
   BehaviorType=0;
   SceneObject[sob].MorphTarget=WORDM1;
   SceneObject[sob].ParentEntry=0;
   SceneObject[sob].Hidden=0;
  }
  if(strcmp("ParentObject\0",SceneArg[0])==0){
   SceneObject[sob].ParentEntry=ReadLONG(SceneArg[1]);
   printf("\n%sObject number %d is a childobject to object number %d",SpacePtr,sob,SceneObject[sob].ParentEntry-1);
  }
  if(strcmp("ObjectMotion\0",SceneArg[0])==0){
   if(strcmp("(unnamed)\0",SceneArg[1])!=0)Error("Don't support external motion files!!");
   SpacePtr-=SpaceStep;
   NextRow();
   SceneObject[sob].InfoChannels=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of info channels: %d",SpacePtr,SceneObject[sob].InfoChannels);
   if(SceneObject[sob].InfoChannels!=9)Error("Only supporting 9 channels!!");
   NextRow();
   SceneObject[sob].KeyFrames=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of keyframes: %d",SpacePtr,SceneObject[sob].KeyFrames);
   SceneObject[sob].KeyFrameStart=KeyFrames;
   for(q=0;q<SceneObject[sob].KeyFrames;q++){
    NextRow();
    for(w=0;w<6;w++){
     KeyFrame[KeyFrames][w]=ReadFloat(SceneArg[w]);
    }
    if(q==0){
     SceneObject[sob].ScaleX=ReadFloat(SceneArg[6]);
     SceneObject[sob].ScaleY=ReadFloat(SceneArg[7]);
     SceneObject[sob].ScaleZ=ReadFloat(SceneArg[8]);
     printf("\n%sObject scaling X: %f",SpacePtr,SceneObject[sob].ScaleX);
     printf("\n%sObject scaling Y: %f",SpacePtr,SceneObject[sob].ScaleY);
     printf("\n%sObject scaling Z: %f",SpacePtr,SceneObject[sob].ScaleZ);
    }else{
     l0=ReadFloat(SceneArg[6])*50.0;
     l1=SceneObject[sob].ScaleX*50.0;
     if(l0!=l1)Error("Object time scaling not supported!!");
     l0=ReadFloat(SceneArg[7])*50.0;
     l1=SceneObject[sob].ScaleY*50.0;
     if(l0!=l1)Error("Object time scaling not supported!!");
     l0=ReadFloat(SceneArg[8])*50.0;
     l1=SceneObject[sob].ScaleZ*50.0;
     if(l0!=l1)Error("Object time scaling not supported!!");
    }
    NextRow();
    for(w=0;w<5;w++){
     KeyFrame[KeyFrames][6+w]=ReadFloat(SceneArg[w]);
    }
    KeyFrames++;
    if(KeyFrames==MAXKEYFRAMES)Error("Too many keyframes!!");
   }
   SpacePtr+=SpaceStep;
   SceneObject[sob].MotionType|=1;
  }
  if(strcmp("EndBehavior\0",SceneArg[0])==0){
   if(waslight==0){
   w=ReadLONG(SceneArg[1]);
   if(w==0)w=1;
   w--;
   if(w==0){
    printf("\n%sLooping off",SpacePtr);
   }else{
    printf("\n%sLooping on",SpacePtr);
   }
   if(BehaviorType==0){
    SceneObject[sob].Loop=w;
   }else{
    SceneObject[sob].AnimLoop=w;
   }
   }else{
   	waslight=0;
   }
  }
  if(strcmp("Metamorph\0",SceneArg[0])==0){
   printf("\n%sMetamorph used on object number %d",SpacePtr,sob);
   BehaviorType=1;
   if(strcmp("(envelope)\0",SceneArg[1])!=0)Error("Metamorph evelopes must be used!!");
   SceneObject[sob].AnimEnvelope=InsertEnvelope();
  }
  if(strcmp("MorphTarget\0",SceneArg[0])==0){
   SceneObject[sob].MorphTarget=ReadLONG(SceneArg[1])-1;
   printf("\n%sMorphtarget is object number %d",SpacePtr,SceneObject[sob].MorphTarget);
  }
  if(strcmp("MorphSurfaces\0",SceneArg[0])==0){
   if(strcmp("0\0",SceneArg[1])!=0)Error("Can't morph surfaces!!");
  }
  if(strcmp("BackdropColor\0",SceneArg[0])==0){
	BackR=(BYTE)ReadLONG(SceneArg[1]);
	BackG=(BYTE)ReadLONG(SceneArg[2]);
	BackB=(BYTE)ReadLONG(SceneArg[3]);
    printf("\n\n%sBackdrop colour: $%02x %02x %02x",SpacePtr,BackR,BackG,BackB);
  }
  if(strcmp("AmbientColor\0",SceneArg[0])==0){
   AmbientR=(BYTE)ReadLONG(SceneArg[1]);
   AmbientG=(BYTE)ReadLONG(SceneArg[2]);
   AmbientB=(BYTE)ReadLONG(SceneArg[3]);
   printf("\n\n%sAmbient colour: $%02x %02x %02x",SpacePtr,AmbientR,AmbientG,AmbientB);
  }
  if(strcmp("AmbIntensity\0",SceneArg[0])==0){
   AmbientInt=ReadFloat(SceneArg[1]);
   printf("\n%sAmbient intensity: %f%%",SpacePtr,AmbientInt*100.0);
  }
  if(MakeFlares!=0){
  if(strcmp("AddLight\0",SceneArg[0])==0){
   printf("\n\n%sAdding light",SpacePtr);
   sob=SceneObjects;
   SceneObjects++;
   if(SceneObjects==MAXOBJECTS)Error("Too many objects!!");
   SceneObject[sob].Type=1;
   SceneObject[sob].MotionType=0;
   SceneObject[sob].Int=1.0;
   SceneObject[sob].LightSize=0.5;
   SceneObject[sob].LightSpot=0.01;
   SceneObject[sob].Name[0]=0;
   SceneObject[sob].LightType=0;
   BehaviorType=0;
  }
  if(strcmp("LightName\0",SceneArg[0])==0){
   printf("\n%sLight '%s' numbered as %d",SpacePtr,SceneArg[1],sob);
   memmove(&SceneObject[sob].Name[0],SceneArg[1],strlen(SceneArg[1])+1);
  }
  if(strcmp("LightMotion\0",SceneArg[0])==0){
   if(strcmp("(unnamed)\0",SceneArg[1])!=0)Error("Don't support external lightmotion files!!");
   SpacePtr-=SpaceStep;
   NextRow();
   SceneObject[sob].InfoChannels=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of info channels: %d",SpacePtr,SceneObject[sob].InfoChannels);
   if(SceneObject[sob].InfoChannels!=9)Error("Only supporting 9 channels!!");
   NextRow();
   SceneObject[sob].KeyFrames=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of keyframes: %d",SpacePtr,SceneObject[sob].KeyFrames);
   SceneObject[sob].KeyFrameStart=KeyFrames;
   for(q=0;q<SceneObject[sob].KeyFrames;q++){
    NextRow();
    for(w=0;w<6;w++){
     KeyFrame[KeyFrames][w]=ReadFloat(SceneArg[w]);
    }
    if(q==0){
     SceneObject[sob].ScaleX=ReadFloat(SceneArg[6]);
     SceneObject[sob].ScaleY=ReadFloat(SceneArg[7]);
     SceneObject[sob].ScaleZ=ReadFloat(SceneArg[8]);
//     printf("\n%sLight scaling X: %f",SpacePtr,SceneObject[sob].ScaleX);
//     printf("\n%sLight scaling Y: %f",SpacePtr,SceneObject[sob].ScaleY);
//     printf("\n%sLight scaling Z: %f",SpacePtr,SceneObject[sob].ScaleZ);
    }else{
     if(ReadFloat(SceneArg[6])!=SceneObject[sob].ScaleX)Error("Light time scaling not supported!!");
     if(ReadFloat(SceneArg[7])!=SceneObject[sob].ScaleY)Error("Light time scaling not supported!!");
     if(ReadFloat(SceneArg[8])!=SceneObject[sob].ScaleZ)Error("Light time scaling not supported!!");
    }
    NextRow();
    for(w=0;w<5;w++){
     KeyFrame[KeyFrames][6+w]=ReadFloat(SceneArg[w]);
    }
    KeyFrames++;
    if(KeyFrames==MAXKEYFRAMES)Error("Too many keyframes!!");
   }
   SpacePtr+=SpaceStep;
   SceneObject[sob].MotionType|=1;
  }
  if(strcmp("LightColor\0",SceneArg[0])==0){
   SceneObject[sob].Red=(BYTE)ReadLONG(SceneArg[1]);
   SceneObject[sob].Green=(BYTE)ReadLONG(SceneArg[2]);
   SceneObject[sob].Blue=(BYTE)ReadLONG(SceneArg[3]);
   printf("\n%sLight colour: $%02x %02x %02x",SpacePtr,SceneObject[sob].Red,SceneObject[sob].Green,SceneObject[sob].Blue);
  }
  if(strcmp("LgtIntensity\0",SceneArg[0])==0){
   SceneObject[sob].Int=ReadFloat(SceneArg[1]);
   printf("\n%sLight intensity: %f%%",SpacePtr,SceneObject[sob].Int*100.0);
  }
  if(strcmp("LightType\0",SceneArg[0])==0){
   SceneObject[sob].LightType=ReadLONG(SceneArg[1]);
   if((SceneObject[sob].LightType&7)==0){
    printf("\n%sLight type: Flare",SpacePtr);
   }
   if((SceneObject[sob].LightType&7)==1){
    printf("\n%sLight type: Blob",SpacePtr);
   }
   if((SceneObject[sob].LightType&7)==2){
    printf("\n%sLight type: Imagemapped",SpacePtr);
   }
  }
  if(strcmp("FlareIntensity\0",SceneArg[0])==0){
   SceneObject[sob].LightSize=ReadFloat(SceneArg[1]);
   if(SceneObject[sob].LightSize<0.01)SceneObject[sob].LightSize=0.001;
   printf("\n%sLight diameter: %f meters",SpacePtr,SceneObject[sob].LightSize);
  }
  if(strcmp("FlareDissolve\0",SceneArg[0])==0){
   SceneObject[sob].LightSpot=ReadFloat(SceneArg[1]);
   printf("\n%sLight spot intensity: %f%%",SpacePtr,SceneObject[sob].LightSpot*100.0);
  }
  if(strcmp("LightProjImage\0",SceneArg[0])==0){
   printf("\n%sLight map: '%s'",SpacePtr,SceneArg[1]);
   memmove(&SceneObject[sob].Name[0],SceneArg[1],strlen(SceneArg[1])+1);
   SceneObject[sob].LightType+=0x80;
  }
  if(strcmp("ShadowType\0",SceneArg[0])==0){
   SceneObject[sob].LightImageType=ReadLONG(SceneArg[1]);
   if(SceneObject[sob].LightImageType==0){
    printf("\n%sLightimage palette: Image",SpacePtr);
   }else{
    printf("\n%sLightimage palette: Calculated",SpacePtr);
   }
  }
  }else{
  	waslight=1;
  }

  if(strcmp("ShowCamera\0",SceneArg[0])==0){
   sob=SceneObjects;
   SceneObjects++;
   if(SceneObjects==MAXOBJECTS)Error("Too many objects!!");
   printf("\n\n%sAdding camera numbered as %d",SpacePtr,sob);
   SceneObject[sob].Type=2;
   SceneObject[sob].MotionType=0;
   SceneObject[sob].CameraZoom=1.0;
   memmove(&SceneObject[sob].Name[0],&CameraName[0],strlen(&CameraName[0])+1);
   BehaviorType=0;
  }
  if(strcmp("CameraMotion\0",SceneArg[0])==0){
   if(strcmp("(unnamed)\0",SceneArg[1])!=0)Error("Don't support external cameramotion files!!");
   SpacePtr-=SpaceStep;
   NextRow();
   SceneObject[sob].InfoChannels=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of info channels: %d",SpacePtr,SceneObject[sob].InfoChannels);
   if(SceneObject[sob].InfoChannels!=9)Error("Only supporting 9 channels!!");
   NextRow();
   SceneObject[sob].KeyFrames=ReadLONG(SceneArg[0]);
   printf("\n%sNumber of keyframes: %d",SpacePtr,SceneObject[sob].KeyFrames);
   SceneObject[sob].KeyFrameStart=KeyFrames;
   for(q=0;q<SceneObject[sob].KeyFrames;q++){
    NextRow();
    for(w=0;w<6;w++){
     KeyFrame[KeyFrames][w]=ReadFloat(SceneArg[w]);
    }
    if(q==0){
     SceneObject[sob].ScaleX=ReadFloat(SceneArg[6]);
     SceneObject[sob].ScaleY=ReadFloat(SceneArg[7]);
     SceneObject[sob].ScaleZ=ReadFloat(SceneArg[8]);
//     printf("\n%sCamera scaling X: %f",SpacePtr,SceneObject[sob].ScaleX);
//     printf("\n%sCamera scaling Y: %f",SpacePtr,SceneObject[sob].ScaleY);
//     printf("\n%sCamera scaling Z: %f",SpacePtr,SceneObject[sob].ScaleZ);
    }else{
     if(ReadFloat(SceneArg[6])!=SceneObject[sob].ScaleX)Error("Camera time scaling not supported!!");
     if(ReadFloat(SceneArg[7])!=SceneObject[sob].ScaleY)Error("Camera time scaling not supported!!");
     if(ReadFloat(SceneArg[8])!=SceneObject[sob].ScaleZ)Error("Camera time scaling not supported!!");
    }
    NextRow();
    for(w=0;w<5;w++){
     KeyFrame[KeyFrames][6+w]=ReadFloat(SceneArg[w]);
    }
    KeyFrames++;
    if(KeyFrames==MAXKEYFRAMES)Error("Too many keyframes!!");
   }
   SpacePtr+=SpaceStep;
   SceneObject[sob].MotionType|=1;
  }
  if(strcmp("TargetObject\0",SceneArg[0])==0){
   Error("Target objects not supported!!");
   SceneObject[sob].MotionTarget=ReadLONG(SceneArg[1])-1;
   printf("\n%sMotion target is object %d",SpacePtr,SceneObject[sob].MotionTarget);
   SceneObject[sob].MotionType|=2;
  }
  if(strcmp("ZoomFactor\0",SceneArg[0])==0){
   if(strcmp("(envelope)\0",SceneArg[1])==0)Error("ZoomFactor evelopes can't be used!!");
   SceneObject[sob].CameraZoom=ReadFloat(SceneArg[1]);
   printf("\n%sCamera zoom factor: %f",SpacePtr,SceneObject[sob].CameraZoom*100.0);
  }
 }while(ScenePos<SceneLength);
 SpacePtr+=SpaceStep;
 SpacePtr+=SpaceStep;
}
/* ###############################################################################################

Object animation related routines

############################################################################################### */

LONG InsertAnimObjectType0( LONG Frames,
        LONG Looping,
        LONG BaseObjectOffset,
        LONG AnimObjectOffset,
        LONG AnimObjectSize){
LONG offset;
LONG l;
SBYTE ErrMsg[]="Animbuffer full!!\0";
 offset=AnimBufferOffset;
 if(Frames<2)Frames=1;
 AnimBuffer[AnimBufferOffset++]=Frames;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 AnimBuffer[AnimBufferOffset++]=Looping;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 AnimBuffer[AnimBufferOffset++]=0;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 if(Frames<2){
  AnimBuffer[AnimBufferOffset++]=BaseObjectOffset;
  if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
  AnimBuffer[AnimBufferOffset++]=BaseObjectOffset;
  if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 }else{
  for(l=0;l<Frames;l++){
   AnimBuffer[AnimBufferOffset++]=BaseObjectOffset;
   if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
   AnimBuffer[AnimBufferOffset++]=AnimObjectOffset+AnimObjectSize*l;
   if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
  }
 }
 return(offset*4);
}

LONG InsertAnimObjectType1( LONG Frames,
        LONG Looping,
        LONG BaseObjectOffset
        ){
LONG offset;
LONG l,q;
LONG * a;
LONG * b;
SBYTE ErrMsg[]="Animbuffer full!!\0";
 if(Frames<2)return(InsertAnimObjectType0(Frames,Looping,BaseObjectOffset,0,0));
 offset=AnimBufferOffset;
 AnimBuffer[AnimBufferOffset++]=Frames;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 AnimBuffer[AnimBufferOffset++]=Looping;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 AnimBuffer[AnimBufferOffset++]=1;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 AnimBuffer[AnimBufferOffset++]=BaseObjectOffset;
 if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 for(l=0;l<Frames;l++){
  AnimBuffer[AnimBufferOffset++]=MorphObjectOffset[l][0];
  if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
  AnimBuffer[AnimBufferOffset++]=MorphObjectOffset[l][1];
  if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
  if(SaveAsFloat==0){
	AnimBuffer[AnimBufferOffset++]=(LONG)EnvelopeValues[l];
  }else{
  	a=&q;
  	b=(LONG *)&EnvelopeValues[l];
  	*(a)=*(b);
  	AnimBuffer[AnimBufferOffset++]=q;
  }
  if(AnimBufferOffset>=MAXANIMBUFFER)Error(&ErrMsg[0]);
 }
 return(offset*4);
}

LONG WriteAnimBuffer(FILE * f){
SLONG l;
 printf("\n%sWriting animationdata..",SpacePtr);
 for(l=0;l<AnimBufferOffset;l++){
  WriteLONG(f,AnimBuffer[l]);
 }
 printf("%10ld bytes saved!",AnimBufferOffset*4);
 return(AnimBufferOffset*4);
}

LONG WriteMotionBuffer(FILE * f){
SLONG l;
LONG q;
 printf("\n%sWriting motiondata..   ",SpacePtr);
 q=MotionOfs;
 if(MotionOfs%4!=0){
  q+=4;
  q-=(MotionOfs%4);
 }
 for(l=0;l<q;l++){
  WriteBYTE(f,MotionData[l]);
 }

 printf("%10ld bytes saved!",q);
 return(q);
}

#define OBJECTENTRYSIZE  28
#define OBJECTENTRYHEADER 20

LONG WriteWorldData(FILE * f){
LONG l;
LONG size=OBJECTENTRYHEADER;
 printf("\n%sWriting scenedata..    ",SpacePtr);
 WriteLONG(f,SceneFrames);
 WriteLONG(f,SceneObject[CameraObject].MotionFrames);
 WriteLONG(f,SceneObject[CameraObject].Loop);
 WriteLONG(f,SceneObject[CameraObject].MotionOfs);
 WriteLONG(f,WorldObjects);
 for(l=0;l<SceneObjects;l++){
  if(SceneObject[l].Type<2){
   WriteLONG(f,SceneObject[l].MotionFrames);
   WriteLONG(f,SceneObject[l].Loop);
   WriteLONG(f,SceneObject[l].MotionOfs);
   if(SceneObject[l].ParentEntry==0){
    WriteLONG(f,0);
   }else{
    WriteLONG(f,(SceneObject[l].ParentEntry-1)*OBJECTENTRYSIZE+OBJECTENTRYHEADER);
   }
   if(SceneObject[l].Type==0){
    WriteLONG(f,2);
   }else{
    WriteLONG(f,3);
   }
   WriteLONG(f,SceneObject[l].CoordOffset);
   WriteLONG(f,SceneObject[l].AnimOffset);
   size+=OBJECTENTRYSIZE;
  }
 }
 printf("%10ld bytes saved!",size);
 return(size);
}

/* ###############################################################################################

Morphing related routines

############################################################################################### */

void MakeMorphObject(struct SceneObjectStr * obj,struct SceneObjectStr * target){
LONG l,q;
WORD SavedUsePhong;
LONG SavedObjectCoords;
LONG offset;
LONG Frames;
LONG Size;
DOUBLE f;
FLOAT big;
FLOAT x,y,z;
 SpacePtr-=SpaceStep;
 printf("\n%sMoving coordinates to temp..",SpacePtr+SpaceStep);
 big=-10;
 for(l=0;l<ObjectCoords;l++){
  x=(DOUBLE)ObjectCoord[l*3+0];
  y=(DOUBLE)ObjectCoord[l*3+1];
  z=(DOUBLE)ObjectCoord[l*3+2];
  x*=x;
  y*=y;
  z*=z;
  x=sqrt(x+y+z);
  if(x>big)big=x;
 }
 for(l=0;l<ObjectCoords*3;l++){
  SavedObjectCoord[l]=ObjectCoord[l];
 }
 for(l=0;l<ObjectCoords;l++){
  SavedObjectUsedCoord[l]=ObjectUsedCoord[l];
 }
 if(UsePhong!=0){
//debug
//	printf("\n\n\nPhong Used!!!!!!!!!!!!!!!!!!!!!\n\n");
  for(l=0;l<ObjectCoords*3;l++){
   SavedPhongCoord[l]=PhongCoord[l];
  }
  for(l=0;l<ObjectCoords;l++){
   SavedPhongUsedCoord[l]=PhongUsedCoord[l];
  }
 }
 SavedUsePhong=UsePhong;
 SavedObjectCoords=ObjectCoords;
 printf("done!\n");
 ObjectShort=1;
 offset=ProcessObject(&target->Name[0]);
 if(ObjectCoords!=SavedObjectCoords)Error("Morphobject has not the same amount of coordinates!!");
 ObjectShort=0;
 Size=ObjectCoords*16;
 for(l=0;l<ObjectCoords*3;l++){
  ObjectCoord[l]-=SavedObjectCoord[l];
 }
 if(SavedUsePhong!=0){
  Size+=(ObjectCoords*16);
  for(l=0;l<ObjectCoords*3;l++){
   PhongCoord[l]-=SavedPhongCoord[l];
  }
 }
 Size+=ObjectHeaderSize;
 Frames=GetEnvelopeFrames(obj->AnimEnvelope);
 printf("\n%sMorphframes: %ld",SpacePtr,Frames);
 printf("\n%sFramesize: %ld bytes",SpacePtr,Size);
 MakeEnvelopeValues(obj->AnimEnvelope);
 obj->AnimOffset=InsertAnimObjectType0( Frames,
           obj->AnimLoop,
           obj->ObjectOffset,
           ObjectOffset,
           Size);
 for(l=0;l<ObjectCoords;l++){
  x=(DOUBLE)ObjectCoord[l*3+0];
  y=(DOUBLE)ObjectCoord[l*3+1];
  z=(DOUBLE)ObjectCoord[l*3+2];
  x*=x;
  y*=y;
  z*=z;
  x=sqrt(x+y+z);
  if(x>big)big=x;
 }
 big*=1.03;
 for(q=0;q<Frames;q++){
  WriteAnimObjectHeader(OutputFile,big,SavedUsePhong);
  if(EnvelopeValues[q]>1.0)Error("Maximum 100% morph in animated mode!!");
  for(l=0;l<ObjectCoords;l++){
   Writeslong(OutputFile,(SLONG)SavedObjectUsedCoord[l]);
   f=ObjectCoord[l*3+0];
   f*=EnvelopeValues[q];
   f+=SavedObjectCoord[l*3+0];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
   f=ObjectCoord[l*3+1];
   f*=EnvelopeValues[q];
   f+=SavedObjectCoord[l*3+1];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
   f=ObjectCoord[l*3+2];
   f*=EnvelopeValues[q];
   f+=SavedObjectCoord[l*3+2];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
  }
  if(SavedUsePhong!=0){
//debug
//printf("\n\nSaving phongcoords for morphtarget!!!\n\n");
   for(l=0;l<ObjectCoords;l++){
    WriteInt(OutputFile,(SWORD)SavedPhongUsedCoord[l]);
    f=PhongCoord[l*3+0];
    f*=EnvelopeValues[q];
    f+=SavedPhongCoord[l*3+0];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
    f=PhongCoord[l*3+1];
    f*=EnvelopeValues[q];
    f+=SavedPhongCoord[l*3+1];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
    f=PhongCoord[l*3+2];
    f*=EnvelopeValues[q];
    f+=SavedPhongCoord[l*3+2];
   if(SaveAsFloat==0){
   	Writeslong(OutputFile,(SLONG)f);
   }else{
   	WriteFloat(OutputFile,(FLOAT)f);
   }
   }
  }
  ObjectOffset+=Size;
 }
 SpacePtr+=SpaceStep;
}

#define MAXMORPHOBJECTS  256

LONG MorphOffset[MAXMORPHOBJECTS];
struct SceneObjectStr * MorphPtr[MAXMORPHOBJECTS];


void MakeMorphObjectReal(struct SceneObjectStr * obj,struct SceneObjectStr * target1){
WORD SavedUsePhong;
LONG SavedObjectCoords;
LONG a,l,q,Frames;
FLOAT f,x,y,z,big;
LONG Size;
LONG objs;
LONG offset[2];
 MorphPtr[0]=obj;
 MorphPtr[1]=target1;
 objs=2;
 do{
  q=0;
  for(l=0;l<SceneObjects;l++){
//   if(SceneObject[l].Type==0){
    for(a=0;a<objs;a++){
     if(&SceneObject[l]!=MorphPtr[a]){
      if(SceneObject[l].ParentEntry!=0){
       if(&SceneObject[SceneObject[l].ParentEntry-1]==MorphPtr[objs-1]){
        q=1;
        MorphPtr[objs++]=&SceneObject[l];
        SceneObject[l].Hidden=1;
       }
      }
     }
    }
//   }
  }

 }while(q!=0);
 Frames=GetEnvelopeFrames(obj->AnimEnvelope);
 if(Frames<2)MakeMorphObject(obj,target1);
 printf("\n%sFrames in morph:  %d",SpacePtr,Frames);
 printf("\n%sObjects in morph: %d",SpacePtr,objs);
 SpacePtr-=SpaceStep;
 for(l=0;l<ObjectCoords;l++){
  SavedObjectUsedCoord[l]=ObjectUsedCoord[l];
 }
 for(l=0;l<ObjectCoords*3;l++){
  SavedPhongCoord[l]=PhongCoord[l];
 }
 SavedUsePhong=UsePhong;
 SavedObjectCoords=ObjectCoords;
 Size=ObjectCoords*16;
 if(SavedUsePhong!=0){
  Size+=(ObjectCoords*16);
 }
 Size+=ObjectHeaderSize;
 MorphOffset[0]=obj->ObjectOffset;
 ObjectShort=1;
 for(a=1;a<objs;a++){
  printf("\n%sConverting morphtarget: %d\n",SpacePtr+SpaceStep,a);
  MorphOffset[a]=ProcessObject(&MorphPtr[a]->Name[0]);

// offa debug
 printf("\nMorph offset %d = %d",a,MorphOffset[a]);
 printf("\nSavedPhong: %ld\n",SavedUsePhong);

  if(ObjectCoords!=SavedObjectCoords)Error("Morphobject has not the same amount of coordinates!!");
  big=-10;
  for(l=0;l<ObjectCoords;l++){
   x=(DOUBLE)ObjectCoord[l*3+0];
   y=(DOUBLE)ObjectCoord[l*3+1];
   z=(DOUBLE)ObjectCoord[l*3+2];
   x*=x;
   y*=y;
   z*=z;
   x=sqrt(x+y+z);
   if(x>big)big=x;
  }
  big*=1.03;
  WriteAnimObjectHeader(OutputFile,big,SavedUsePhong);
  for(l=0;l<ObjectCoords;l++){
   if(SaveAsFloat==0){
    Writeslong(OutputFile,(SLONG)SavedObjectUsedCoord[l]);
   	Writeslong(OutputFile,(SLONG)ObjectCoord[l*3+0]);
   	Writeslong(OutputFile,(SLONG)ObjectCoord[l*3+1]);
   	Writeslong(OutputFile,(SLONG)ObjectCoord[l*3+2]);
   }else{
    WriteFloat(OutputFile,(FLOAT)SavedObjectUsedCoord[l]);
   	WriteFloat(OutputFile,ObjectCoord[l*3+0]);
   	WriteFloat(OutputFile,ObjectCoord[l*3+1]);
   	WriteFloat(OutputFile,ObjectCoord[l*3+2]);
   }
  }
 if(SavedUsePhong!=0){
   for(l=0;l<ObjectCoords;l++){
   if(SaveAsFloat==0){
    Writeslong(OutputFile,(SLONG)SavedPhongUsedCoord[l]);
    Writeslong(OutputFile,(SLONG)PhongCoord[l*3+0]);
    Writeslong(OutputFile,(SLONG)PhongCoord[l*3+1]);
    Writeslong(OutputFile,(SLONG)PhongCoord[l*3+2]);
   }else{
    WriteFloat(OutputFile,(FLOAT)SavedPhongUsedCoord[l]);
    WriteFloat(OutputFile,PhongCoord[l*3+0]);
    WriteFloat(OutputFile,PhongCoord[l*3+1]);
    WriteFloat(OutputFile,PhongCoord[l*3+2]);
	}
   }
 }
  ObjectOffset+=Size;
 }
 ObjectShort=0;
 printf("\n%sFramesize: %ld bytes",SpacePtr,Size);
 MakeEnvelopeValues(obj->AnimEnvelope);

 for(l=0;l<Frames;l++){
  f=EnvelopeValues[l];
  f*=256.0;
  if(f<0)f=0.0;
  q=(LONG)(f);
  a=q>>8;
  q&=0xff;
  if(a>objs-1)a=objs-1;

 //debug

  MorphObjectOffset[l][0]=MorphOffset[a];
  if(a!=objs)a++;
  MorphObjectOffset[l][1]=MorphOffset[a];
  while(f>=256.0)f-=256.0;
  EnvelopeValues[l]=f;
 }
 obj->AnimOffset=InsertAnimObjectType1( Frames,
           obj->AnimLoop,
           obj->ObjectOffset);
 SpacePtr+=SpaceStep;
}

/* ###############################################################################################

Scene Processing

############################################################################################### */

void ProcessScene(void){
LONG l;
WORD w;
FLOAT f;
LONG CoordStart=0;
SWORD x0,y0,x1,y1,x2,y2,x3,y3;
SWORD ww,hh;
 AnimBufferOffset=0;
 ObjectShort  =0;
 MotionOfs  =0;
 SceneOldFPS  =SceneFPS;
 WorldObjects =0;

 f=SceneStartFrame;
 f*=FramesPerSecond;


 f/=SceneOldFPS;
 SceneStartFrame=f;
 f=SceneEndFrame;
 f*=FramesPerSecond;
 f/=SceneOldFPS;
 SceneEndFrame=f;
 SceneFPS=FramesPerSecond;
 SceneFrames=SceneEndFrame-SceneStartFrame+1;

// printf("\n\n\napa %f\n\n\n",(FLOAT)SceneFrameSteps);

 SceneFrames/=SceneFrameSteps;
 printf("\n\n%sProcessing scene",SpacePtr);


 SpacePtr-=SpaceStep;

 printf("\n%sObjects in scene: %d",SpacePtr,SceneObjects);
 if(SceneObjects==0)Error("No objects in scene!!");
//----------------------------------------- Test for morph objects --
	 for(l=0;l<SceneObjects;l++){
//offa
//  printf("\nobject %d has type %d",l,SceneObject[l].Type);
  if(SceneObject[l].Type==(WORD)0||SceneObject[l].Type==(WORD)3 ){
	  printf("\nobject %d has morphtarget %d",l,SceneObject[l].MorphTarget);
   if(SceneObject[l].MorphTarget!=WORDM1){
    SceneObject[SceneObject[l].MorphTarget].Type=3;
    printf("\n%sObject number %d tagged as morphobject",SpacePtr,SceneObject[l].MorphTarget);
   }
  }
 }
//--------------------------------------------- Find camera object --
 w=0;
 for(l=0;l<SceneObjects;l++){
  if(SceneObject[l].Type==2){
   CameraObject=l;
   w++;
  }
  SceneObject[l].MotionComplete=0;
 }
 if(w==0)Error("No camera in scene!!");
 if(w!=1)Error("Too many cameras in scene!! (???)");
 Scale*=SceneObject[CameraObject].CameraZoom;
 printf("\n%sGlobal scale factor: %f",SpacePtr,Scale);
 printf("\n%sFrames: %ld",SpacePtr,SceneFrames);
 printf("\n%sFrames/second: %f",SpacePtr,SceneFPS);
//---------------------------------------------- Make motionpaths --
 printf("\n%sMakeing motion paths",SpacePtr);
 SpacePtr-=SpaceStep;
 for(l=0;l<SceneObjects;l++){
  printf("\n%sObject '%s'",SpacePtr,&SceneObject[l].Name[0]);
  MakeMotionPath(&SceneObject[l]);
 }
 printf("\n%sMotion frames created: %ld",SpacePtr,MotionOfs/13);
 printf("\n%sMotion memory needed:  %ld bytes",SpacePtr,MotionOfs);
 SpacePtr+=SpaceStep;
 ProcessEnvelopes();
//------------------------------------------------ Convert objects --
 printf("\n%sConverting objects",SpacePtr);
 SpacePtr-=SpaceStep;
 for(l=0;l<SceneObjects;l++){
  ScaleX=SceneObject[l].ScaleX;
  ScaleY=SceneObject[l].ScaleY;
  ScaleZ=SceneObject[l].ScaleZ;
  if(SceneObject[l].Type==0){
   if(SceneObject[l].Hidden==0){
    printf("\n%sConverting object numbered as %d\n",SpacePtr,l);
    SceneObject[l].ObjectOffset=ProcessObject(&SceneObject[l].Name[0]);
    NumberOfVertexes+=ObjectCoords;
    NumberOfPolygons+=Polygons;
    SceneObject[l].CoordOffset=CoordStart;
    CoordStart+=(ObjectCoords*16);
    printf("\n%sObject offset: %ld",SpacePtr,SceneObject[l].ObjectOffset);
    if(SceneObject[l].MorphTarget!=WORDM1){
     WorldObjects++;
     if(MorphMode==0){
      MakeMorphObject(&SceneObject[l],&SceneObject[SceneObject[l].MorphTarget]);
     }else{
      MakeMorphObjectReal(&SceneObject[l],&SceneObject[SceneObject[l].MorphTarget]);
     }
    }else{
     WorldObjects++;
     SceneObject[l].AnimOffset=InsertAnimObjectType0(1,0,SceneObject[l].ObjectOffset,0,0);
    }
   }
  }
  if(SceneObject[l].Type==1){   /* Flares */
   printf("\n%sConverting light numbered as %d",SpacePtr,l);
   SpacePtr-=SpaceStep;
   if((SceneObject[l].LightType&7)==0){ /* Flare */
    SceneObject[l].AnimOffset=ObjectOffset;
    printf("\n%sLight type:      Flare",SpacePtr);
    printf("\n%sLight intensity: %f%%",SpacePtr,SceneObject[l].Int*100.0);
    printf("\n%sLight spot size: %f%%",SpacePtr,SceneObject[l].LightSpot*100.0);
    printf("\n%sLight size:      %f meters",SpacePtr,SceneObject[l].LightSize);
    PhongOfs=PutImage(&DefaultFlare[0],256,256);
    w=PhongColours;
    PhongColours=256;
    InsertPhongColour(SceneObject[l].Red,SceneObject[l].Green,SceneObject[l].Blue,
          256,(WORD)(SceneObject[l].Int*256.0),(WORD)(2048.0*(SceneObject[l].LightSpot*SceneObject[l].LightSpot)) );
    PhongColours=w;
    w=GetImageNumber(PhongOfs,PhongPalOfs,256,256,0,0);
	PolyS[TotalSurface].Texture.ImageNumber=w;
	f=SceneObject[l].LightSize*Scale;
    SceneObject[l].CoordOffset=CoordStart;
    CoordStart+=(4*8);  /* I coordinate for every flare */
	if(SaveAsFloat==0){
		WriteLONG(OutputFile,(LONG)sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteLONG(OutputFile,(LONG)f);
    	WriteWORD(OutputFile,256);
    	WriteWORD(OutputFile,256);
	}else{
		WriteFloat(OutputFile,sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteFloat(OutputFile,f);
    	WriteWORD(OutputFile,256);
    	WriteWORD(OutputFile,256);
	}
	x0=0;
    y0=0;
    x1=256;
    y1=0;
    x2=0;
    y2=256;
    x3=256;
    y3=256;
    ww=256;
    hh=256;
   }
   if((SceneObject[l].LightType&7)==1){ /* Blob */
    SceneObject[l].AnimOffset=ObjectOffset;
    printf("\n%sLight type:      Blob",SpacePtr);
    printf("\n%sLight intensity: %f%%",SpacePtr,SceneObject[l].Int*100.0);
    printf("\n%sLight spot size: %f%%",SpacePtr,SceneObject[l].LightSpot*100.0);
    printf("\n%sLight size:      %f meters",SpacePtr,SceneObject[l].LightSize);
    RenderPhongMap();
    InsertPhongColour(SceneObject[l].Red,SceneObject[l].Green,SceneObject[l].Blue,
          256,(WORD)(SceneObject[l].Int*256.0),(WORD)(2048.0*(SceneObject[l].LightSpot*SceneObject[l].LightSpot)) );
    w=GetImageNumber(PhongOfs-PhongRadius*256,PhongPalOfs,PhongRadius*2,PhongRadius*2,0,0);
	PolyS[TotalSurface].Texture.ImageNumber=w;
    f=SceneObject[l].LightSize*Scale;
    SceneObject[l].CoordOffset=CoordStart;
    CoordStart+=(4*8);  /* I coordinate for every flare */
	if(SaveAsFloat==0){
		WriteLONG(OutputFile,(LONG)sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteLONG(OutputFile,(LONG)f);
    	WriteWORD(OutputFile,PhongRadius*2);
    	WriteWORD(OutputFile,PhongRadius*2);
	}else{
		WriteFloat(OutputFile,sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteFloat(OutputFile,f);
    	WriteWORD(OutputFile,PhongRadius*2);
    	WriteWORD(OutputFile,PhongRadius*2);
	}
	x0=0;
    y0=0;
    x1=PhongRadius*2;
    y1=0;
    x2=0;
    y2=PhongRadius*2;
    x3=PhongRadius*2;
    y3=PhongRadius*2;
    ww=PhongRadius*2;
    hh=PhongRadius*2;
   }
   if((SceneObject[l].LightType&7)==2){ /* Image mapped */
    if(SceneObject[l].LightType<100)Error("Imagemapped flare selected without an image!!!");
    printf("\n%sLight type:      Imagemapped",SpacePtr);
    printf("\n%sLight intensity: %f%%\n",SpacePtr,SceneObject[l].Int*100.0);
    LoadImage(&SceneObject[l].Name[0]);
    if(SceneObject[l].LightImageType==0){
     printf("\n%sLightimage palette: Image",SpacePtr);
     printf("\n%sLight size:      %f meters",SpacePtr,SceneObject[l].LightSize);
     PaletteOfs = GetColourTable( PaletteOfs,
             ImageColours,
             SceneObject[l].Red,
             SceneObject[l].Green,
             SceneObject[l].Blue,
             (WORD)(SceneObject[l].Int*256.0));
     w=GetImageNumber(ImageOfs,PaletteOfs,ImageWidth,ImageHeight,0,0);
	PolyS[TotalSurface].Texture.ImageNumber=w;
     f=SceneObject[l].LightSize*Scale;
     SceneObject[l].CoordOffset=CoordStart;
     CoordStart+=(4*8);  /* I coordinate for every flare */
	if(SaveAsFloat==0){
		WriteLONG(OutputFile,(LONG)sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteLONG(OutputFile,(LONG)f);
    	WriteWORD(OutputFile,ImageWidth);
    	WriteWORD(OutputFile,ImageHeight);
	}else{
		WriteFloat(OutputFile,sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteFloat(OutputFile,f);
    	WriteWORD(OutputFile,ImageWidth);
    	WriteWORD(OutputFile,ImageHeight);
	}
     x0=0;
     y0=0;
     x1=ImageWidth;
     y1=0;
	 x2=0;
     y2=ImageHeight;
     x3=ImageWidth;
     y3=ImageHeight;
     ww=ImageWidth;
     hh=ImageHeight;
    }else{
     printf("\n%sLightimage palette: Calculated",SpacePtr);
     printf("\n%sLight spot size: %f%%",SpacePtr,SceneObject[l].LightSpot*100.0);
     printf("\n%sLight size:      %f meters",SpacePtr,SceneObject[l].LightSize);
     w=PhongColours;
     PhongColours=ImageColours;
     InsertPhongColour(SceneObject[l].Red,SceneObject[l].Green,SceneObject[l].Blue,
           256,(WORD)(SceneObject[l].Int*256.0),(WORD)(2048.0*(SceneObject[l].LightSpot*SceneObject[l].LightSpot)) );
     PhongColours=w;
     w=GetImageNumber(ImageOfs,PhongPalOfs,ImageWidth,ImageHeight,0,0);
	PolyS[TotalSurface].Texture.ImageNumber=w;
     f=SceneObject[l].LightSize*Scale;
     SceneObject[l].CoordOffset=CoordStart;
     CoordStart+=(4*8);  /* I coordinate for every flare */
	if(SaveAsFloat==0){
		WriteLONG(OutputFile,(LONG)sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteLONG(OutputFile,(LONG)f);
    	WriteWORD(OutputFile,ImageWidth);
    	WriteWORD(OutputFile,ImageHeight);
	}else{
		WriteFloat(OutputFile,sqrt(f*f*2.0));
    	WriteWORD(OutputFile,w);
    	WriteWORD(OutputFile,TotalSurface*16);
    	WriteFloat(OutputFile,f);
    	WriteWORD(OutputFile,ImageWidth);
    	WriteWORD(OutputFile,ImageHeight);
	}
     x0=0;
     y0=0;
     x1=ImageWidth;
     y1=0;
     x2=0;
     y2=ImageHeight;
     x3=ImageWidth;
     y3=ImageHeight;
     ww=ImageWidth;
     hh=ImageHeight;
    }
   }
//debug
	PolyS[TotalSurface].Flat.Mode=25;
	PolyS[TotalSurface].Texture.Side=1;
	TotalSurface++;


   ww>>=1;
   hh>>=1;
   if(TextureCenterX!=0){
    x0-=ww;
    x1-=ww;
    x2-=ww;
    x3-=ww;
   }
   if(TextureCenterY!=0){
    y0-=hh;
    y1-=hh;
    y2-=hh;
    y3-=hh;
   }
   if(SaveAsFloat==0){
   Writeslong(OutputFile,x0);
   Writeslong(OutputFile,y0);
   Writeslong(OutputFile,x1);
   Writeslong(OutputFile,y1);
   Writeslong(OutputFile,x3);
   Writeslong(OutputFile,y3);
   Writeslong(OutputFile,0);
   Writeslong(OutputFile,0);
   Writeslong(OutputFile,x0);
   Writeslong(OutputFile,y0);
   Writeslong(OutputFile,x3);
   Writeslong(OutputFile,y3);
   Writeslong(OutputFile,x2);
   Writeslong(OutputFile,y2);
   Writeslong(OutputFile,0);
   Writeslong(OutputFile,0);
   }else{
   WriteFloat(OutputFile,x0);
   WriteFloat(OutputFile,y0);
   WriteFloat(OutputFile,x1);
   WriteFloat(OutputFile,y1);
   WriteFloat(OutputFile,x3);
   WriteFloat(OutputFile,y3);
   WriteFloat(OutputFile,0);
   WriteFloat(OutputFile,0);
   WriteFloat(OutputFile,x0);
   WriteFloat(OutputFile,y0);
   WriteFloat(OutputFile,x3);
   WriteFloat(OutputFile,y3);
   WriteFloat(OutputFile,x2);
   WriteFloat(OutputFile,y2);
   WriteFloat(OutputFile,0);
   WriteFloat(OutputFile,0);
   }
   WriteBYTE(OutputFile,25);
   WriteBYTE(OutputFile,0);
   WriteBYTE(OutputFile,1);
   WriteBYTE(OutputFile,0);
   WriteWORD(OutputFile,w);
   WriteWORD(OutputFile,0);
   WriteLONG(OutputFile,0);
   WriteLONG(OutputFile,0);
   ObjectOffset+=96;
   WorldObjects++;
   SpacePtr+=SpaceStep;
  }
 }
 SpacePtr+=SpaceStep;
 printf("\n%sObjects in world: %ld",SpacePtr,WorldObjects);
 SpacePtr+=SpaceStep;
}



/* ###############################################################################################

Main

############################################################################################### */

SBYTE lowcase(SBYTE c){
 if(c>='A')if(c<='Z')c+=32;
 return(c);
}


SBYTE * ArgPtr[32];
WORD  Arguments;

void GetArguments(SWORD argc,SBYTE * argv[]){
LONG l;
LONG q;
SBYTE  c;
 if(argc<2){
  Arguments=0;
  return;
 }
 Arguments=0;
 for(l=0;l<argc;l++){
  if(*(argv[l])=='-'){
   for(q=1;q<=strlen(argv[l]);q++){
    c=lowcase(*(argv[l]+q));
     if(c=='i'){
     printf("\n%s*NOTE* Write mode is now intel byteorder (PC)",SpacePtr);
     WritePC=1;
    }
    if(c=='m'){
     printf("\n%s*NOTE* Morph mode is now 'animation'",SpacePtr);
     MorphMode = 0;
    }
    if(c=='r'){
     printf("\n%s*NOTE* Removing paths from all filenames.",SpacePtr);
     RemovePath = 1;
    }
    if(c=='f'){
     printf("\n%s*NOTE* Coordinates are now saved as float (4 bytes).",SpacePtr);
     SaveAsFloat = 1;
    }
     if(c=='t'){
     FramesPerSecond = ReadFloat(argv[l]+q+1);
     printf("\n%s*NOTE* Timescaling is set to %f frames/second.",SpacePtr,FramesPerSecond);
     if(FramesPerSecond<1)Error("Need atleast 1 frame/second!!");
    }
    if(c=='s'){
     Scale = ReadFloat(argv[l]+q+1);
     printf("\n%s*NOTE* Coordinate scaling is now set to %f.",SpacePtr,Scale);
     if(Scale==0)Error("Can't scale scene with 0!!");
    }
    if(c=='x'){
     printf("\n%s*NOTE* Texture coordinates are now centered around X",SpacePtr);
	 TextureCenterX=1;
    }
    if(c=='y'){
     printf("\n%s*NOTE* Texture coordinates are now centered around Y",SpacePtr);
	 TextureCenterY=1;
    }
    if(c=='o'){
     printf("\n%s*NOTE* Full imagebufferoptimazation will be done",SpacePtr);
	 OptimizeFull=1;
    }
    if(c=='l'){
     printf("\n%s*NOTE* Making all lights as flares",SpacePtr);
	 MakeFlares=1;
    }
   }
  }else{
   ArgPtr[Arguments++]=argv[l];
  }
 }
}



LONG ObjectOffsets[MAXOBJECTS];
LONG WorldOfs;

SWORD main(SWORD argc,SBYTE * argv[]){
LONG l;
FILE * f;
LONG Offset[10];
LONG Size[10];
WORD w;
BYTE * b;
SBYTE Wrong[]="This program is compiled with wrong settings!!\0";
 printf("\nLightWave object converter v3.4 -- Copyright (C) 1996 TBL");
 printf("\nProgrammed by Equalizer (Daniel Hansen)\n");
 if((SWORD)(sizeof(BYTE))!=(SWORD)1){
  printf("\nBYTE==%d !!",sizeof(BYTE));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(WORD))!=(SWORD)2){
  printf("\nWORD==%d !!",sizeof(WORD));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(LONG))!=(SWORD)4){
  printf("\nLONG==%d !!",sizeof(WORD));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(SBYTE))!=(SWORD)1){
  printf("\nSBYTE==%d !!",sizeof(WORD));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(SWORD))!=(SWORD)2){
  printf("\nSWORD==%d !!",sizeof(SWORD));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(SLONG))!=(SWORD)4){
  printf("\nSLONG==%d !!",sizeof(SLONG));
  Error(&Wrong[0]);
 }
 if((SWORD)(sizeof(FLOAT))!=(SWORD)4){
  printf("\nFLOAT==%d !!",sizeof(FLOAT));
  Error(&Wrong[0]);
 }
 w=42;
 b=(BYTE *)&w;
 if(*(b)!=42){
  printf("\nMotorola byteorder is used on this platform.\n\n");
 }else{
  printf("\nIntel byteorder is used on this platform.\n\n");
 }
//---------------------------------------------------------------- User variables --
 RemovePath  = 0;
 MorphMode  = 1;
 WritePC   = 0;
 FramesPerSecond = 50.0;
 Scale   = 128.0;
 GetArguments(argc,argv);
 if(Arguments!=3)Error("Wrong number of arguments !!");
 InitImageBuffer();
//------------------------------------------------------------- Default variables --
 WorldOfs   = 0;
 TotalSurface  = 0;
 PhongShift   = 0;
 ImageLists   = 0;
 ObjectOffset  = 0;
 AmbientR   = 0;
 AmbientG   = 0;
 AmbientB   = 0;
 BackR 	  = 0;
 BackG 	  = 0;
 BackB 	  = 0;
 NumberOfVertexes = 0;
 NumberOfPolygons = 0;
//---------------------------------------------------------------- End of init --
 OutputFile=fopen(ArgPtr[2],"wb");
 if(OutputFile==0)Error("Couldn't open outputfile!!");
 for(l=0;l<HEADERSIZE;l++){
  WriteBYTE(OutputFile,0);
 }
 Offset[0]=HEADERSIZE;
 LoadScene(ArgPtr[1]);
 ProcessScene();
 OptimizeImageBuffer();
 Size[0]=ObjectOffset;
 Offset[1]=Offset[0]+Size[0];
 Size[1]=WriteImageList(OutputFile);
 Offset[2]=Offset[1]+Size[1];
 Size[2]=WriteSurface(OutputFile);
 Offset[3]=Offset[2]+Size[2];
 Size[3]=WriteImage(OutputFile);
 Offset[4]=Offset[3]+Size[3];
 Size[4]=WritePalette(OutputFile);
 Offset[5]=Offset[4]+Size[4];
 Size[5]=WriteAnimBuffer(OutputFile);
 Offset[6]=Offset[5]+Size[5];
 Size[6]=WriteMotionBuffer(OutputFile);
 Offset[7]=Offset[6]+Size[6];
 Size[7]=WriteWorldData(OutputFile);
 Offset[8]=Offset[7]+Size[7];
 if(fseek(OutputFile,0,0)!=0)Error("Couldn't seek to start of file!!");
 for(l=0;l<8;l++){
  WriteLONG(OutputFile,Offset[l]);
  WriteLONG(OutputFile,Size[l]);
 }
 WriteLONG(OutputFile,NumberOfVertexes);
 WriteLONG(OutputFile,NumberOfPolygons);
 WriteBYTE(OutputFile,0);
 WriteBYTE(OutputFile,BackR);
 WriteBYTE(OutputFile,BackG);
 WriteBYTE(OutputFile,BackB);
 fclose(OutputFile);
 printf("\n\n%sTotalsize: %ld bytes",SpacePtr,Offset[8]);
 printf("\n%sTotal number of vertexes to rotates: %ld\n",SpacePtr,NumberOfVertexes);


// Debug stuff
f=fopen("IMAGE.RAW","wb");
 WriteImage(f);
fclose(f);
 //f=fopen("PALETTE.RAW","wb");
 //if(fwrite(&PaletteBuffer[1],LastPaletteLine*256*4,1,f)==0)Error(&SaveErr[0]);
 //fclose(f);
 return(0);
}
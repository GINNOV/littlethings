#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <magic/magic.h>
#include <magic/magic_protos.h>
#include <magic/magic_pragmas.h>

#include "gl/outputhandler.h"

//
// VERY simple output handler for AmigaMesaRTL
// Szymon Ulatowski <szulat@friko6.onet.pl>
//
// 20.08.1998 - Initial version
// 12.09.1998 - changed to the new driver interface
//
//  no configuration, uses default magic image
//  (that has to be 24 bit)
//  in case of any problems - silently refuses to initialize!
//
//  usage:
//   1.start MagicServer
//   2.create a magic image in any magic-aware application (eg.ImageFX)
//   3.now the Mesa graphics is redirected to your application!

#define DB kprintf

AmigaMesaRTLContext ctx;
UBYTE *buffer;
struct Library *mesadriverBase;
struct MagicBase *MagicBase;
struct MagicHandle *mh;
long lock;
long w,h,d;

__asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext mesacontext, register __a1 struct TagItem *tags)
{
long mode;
lock=0;
buffer=0;
mesadriverBase=0;
MagicBase=0;
mh=0;
ctx = mesacontext;
DB("get driver\n");
Delay(50);
if (!(mesadriverBase = (struct Library *)GetTagData(OH_DriverBase,NULL,tags))) goto fail;
DB("get output\n");
Delay(50);
if (!stricmp(GetTagData(OH_OutputType,"",tags),"window"))
	if (!GetTagData(OH_Output,0,tags)) goto fail;
DB("get mode\n");
Delay(50);
AmigaMesaRTLGetContextAttr(AMRTL_Mode,mesacontext,&mode);
if (mode!=AMRTL_RGBAMode) goto fail;
DB("get magic\n");
Delay(50);
if (!(MagicBase = (struct MagicBase *)OpenLibrary(MAGIC_NAME, 34))) goto fail;
DB("get image\n");
Delay(50);
if (!(mh = OpenMagicImage(NULL, NULL, TAG_END))) goto fail;
DB("get sizes\n");
Delay(50);
w = mh->Object->Width;
h = mh->Object->Height;
d = mh->Object->Depth;
buffer=malloc(w);
if (d!=3) goto fail;
DB("lock image\n");
Delay(50);
if (!(AttemptLockMagicImage(mh, LMI_Write))) goto fail;
DB("everything ok\n");
Delay(50);
lock=1;
	return 1;

fail:
	DeleteOutputHandler();
	return 0;
}

__asm __saveds void DeleteOutputHandler(void)
{
DB("delete\n");
Delay(50);
if (lock) UnlockMagicImage(mh);
lock=0;
if (buffer) free(buffer);
buffer=0;
if (mh) CloseMagicImage(mh);
mh=0;
if(MagicBase) CloseLibrary(MagicBase);
MagicBase=0;
}

__asm __saveds int ResizeOutputHandler(void)
{return 1;}

__asm __saveds int ProcessOutput(void)
{
UBYTE *src,*rgb,*dst;
int y,bw,x;
AmigaMesaRTLGetContextAttr(AMRTL_Buffer,ctx,&rgb);
AmigaMesaRTLGetContextAttr(AMRTL_BufferWidth,ctx,&bw);
DB("process output\n");

for (y=0;y<h;y++,rgb+=(4*bw))
	{
//   if (!(PutMagicImageData(mh, y, 1, GMI_RGBA, rgb, TAG_END))) return 0;
	for (x=w,src=rgb,dst=buffer;x>0;x--,dst++,src+=4) (*dst)=(*src);
  	if (!(PutMagicImageData(mh, y, 1, GMI_Red, buffer, TAG_END))) return 0;
	for (x=w,src=rgb+1,dst=buffer;x>0;x--,dst++,src+=4) (*dst)=(*src);
  	if (!(PutMagicImageData(mh, y, 1, GMI_Green, buffer, TAG_END))) return 0;
	for (x=w,src=rgb+2,dst=buffer;x>0;x--,dst++,src+=4) (*dst)=(*src);
  	if (!(PutMagicImageData(mh, y, 1, GMI_Blue, buffer, TAG_END))) return 0;
	}
RedrawMagicImage(mh,0,0,w,h);
	return 1;
}

__asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{ }

__asm __saveds ULONG SetOutputHandlerAttrsA(register __a0 struct TagItem *tags)
{ return 0; }

__asm __saveds ULONG GetOutputHandlerAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
switch(attr)
	{
		case OH_Width: *data = w; break;
		case OH_Height: *data = h; break;
		default:		return(0);
	}
return(1);
}


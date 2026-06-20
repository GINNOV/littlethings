/* FaderFunctions.c - (22-Feb-1999)
 * mad.nano (mad.nano@mailcity.com)
 *
 * Feel free to use/modify this code as much as you like.
 *
 * USE AT YOUR OWN RISK. I AM NOT RESPONSIBLE FOR
 * ANY DAMAGE THIS CODE MIGHT DO.
 * 
 */

#include <exec/memory.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>


extern struct Library *SysBase;
extern struct Library *GfxBase;

void FadeBlack( struct Screen * , APTR , UWORD );
void FadeWhite( struct Screen * , APTR , UWORD );
void FadeCol2Col( struct Screen * , APTR , APTR , UWORD );
void FadeBlack2Col( struct Screen * , APTR , UWORD );
void FadeWhite2Col( struct Screen * , APTR , UWORD );
void FillWhite(APTR);
void SetSpeed(UWORD);

ULONG step=0;



void FadeBlack(struct Screen *s,APTR ct,UWORD fspd)
{
	int cols,a,b;
	ULONG *pt;
	UWORD cur;
	SetSpeed(fspd);
	cols=*((UWORD *)ct);
	do
	{
		pt=(ULONG *)((ULONG)ct+(ULONG)4);
		cur=256*3;
		
		for(a=0;a<cols;a++)
		{
			for(b=0;b<3;b++)
			{
				if(*pt>step) *(pt++)-=step;
				else {*(pt++)=0x00000000;cur--;}
			}
		}
		LoadRGB32(&s->ViewPort,(ULONG *)ct);
	} while(cur);
	return;
}



void FadeWhite(struct Screen *s,APTR ct,UWORD fspd)
{
	int cols,a,b;
	ULONG *pt;
	UWORD cur;
	SetSpeed(fspd);
	cols=*((UWORD *)ct);
	do
	{
		pt=(ULONG *)((ULONG)ct+(ULONG)4);
		cur=256*3;
		for(a=0;a<cols;a++)
		{
			for(b=0;b<3;b++)
			{
				if(*pt<(0xFFFFFFFF-step)) *(pt++)+=step;
				else {*(pt++)=0xFFFFFFFF;cur--;}
			}
		}
		LoadRGB32(&s->ViewPort,(ULONG *)ct);
	} while(cur);
	return;
}



void FadeCol2Col(struct Screen *s,APTR ifrom,APTR to,UWORD fspd)
{
	int cols,a,b;
	APTR from=NULL;
	ULONG *pa,*pb,delta;
	UWORD cur,pos;

	if((from=AllocVec(3080,MEMF_FAST|MEMF_CLEAR)))
	{
		SetSpeed(fspd);
		if( *((UWORD *)ifrom) < *((UWORD *)to)) cols=*((UWORD *)ifrom);
		else cols=*((UWORD *)to);
		CopyMem(ifrom,from,cols*12+8);
		do
		{
			pa=(ULONG *)((ULONG)from+(ULONG)4);
			pb=(ULONG *)((ULONG)to+(ULONG)4);
			cur=256*3;
			for(a=0;a<cols;a++)
			{
				for(b=0;b<3;b++)
				{
					if(*pa > *pb) { delta = *pa - *pb; pos=0; }
					else { delta = *pb - *pa; pos=1; }
					
					if(delta>step)
					{
						if(pos) *pa+=step;
						else *pa-=step;
					}
					else { *pa=*pb; cur--; }
					pa++;pb++;
				}
			}
			LoadRGB32(&s->ViewPort,(ULONG *)from);
		} while(cur);
		FreeVec(from);
	}
	return;
}



void FadeBlack2Col(struct Screen *s,APTR to,UWORD fspd)
{
	int cols,a,b;
	APTR from=0;
	ULONG *pa,*pb;
	UWORD cur=0;
	if((from=AllocVec(3080,MEMF_FAST|MEMF_CLEAR)))
	{
		SetSpeed(fspd);
		*(UWORD *)from=*((UWORD *)to);
		cols=*((UWORD *)to);
		do
		{
			pa=(ULONG *)((ULONG)to+(ULONG)4);
			pb=(ULONG *)((ULONG)from+(ULONG)4);
			cur=256*3;
			for(a=0;a<cols;a++)
			{
				for(b=0;b<3;b++)
				{
					if((*(pa)-*pb)>step) { *(pb++)+=step; pa++; }
					else { *(pb++)=*(pa++); cur--; }
				}
			}
			LoadRGB32(&s->ViewPort,(ULONG *)from);
		} while(cur);
		FreeVec(from);
	}
	return;
}



void FadeWhite2Col(struct Screen *s,APTR to,UWORD fspd)
{
	int cols,a,b;
	APTR from=0;
	ULONG *pa,*pb;
	UWORD cur=0;
	if((from=AllocVec(3080,MEMF_FAST|MEMF_CLEAR)))
	{
		FillWhite(from);
		SetSpeed(fspd);
		*(UWORD *)from=*((UWORD *)to);
		cols=*((UWORD *)to);
		do
		{
			pa=(ULONG *)((ULONG)to+(ULONG)4);
			pb=(ULONG *)((ULONG)from+(ULONG)4);
			cur=256*3;
			for(a=0;a<cols;a++)
			{
				for(b=0;b<3;b++)
				{
					if((*pb-*pa)>step) { *(pb++)-=step; pa++;}
					else { *(pb++)=*(pa++); cur--; }
				}
			}
			LoadRGB32(&s->ViewPort,(ULONG *)from);
		} while(cur);
		FreeVec(from);
	}
	return;
}



void FillWhite(APTR table)
{
	ULONG *pt;
	int i;
	pt=(ULONG *)((ULONG)table+(ULONG)4);
	for(i=0;i<(256*3);i++)
	{
		*(pt++)=0xFFFFFFFF;
	}
	return;
}
void SetSpeed(UWORD spd)
{
	if(spd>30) spd=30;
	if(!spd) step=0x00800000/2;
	else step=0x00800000*spd;
	return;
}



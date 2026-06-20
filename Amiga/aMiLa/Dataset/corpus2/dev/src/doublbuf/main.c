// set tabs to 4

#include	"main.h"

//#include	<everything!>		// use premade GST with <proto/all.h> file
								// instead

long openshit(void);
void closeshit(void);

struct	Screen	*screen;
extern struct ExtNewScreen NewScreenStructure;

struct	ViewPort	*VP;

struct	RastPort	*RP;			// RP = &screen->RastPort;
struct	RastPort	*RP1;
struct	RastPort	*RP2;

struct	MsgPort		*safe_port1;
struct	MsgPort		*disp_port1;
struct	MsgPort		*safe_port2;
struct	MsgPort		*disp_port2;


extern struct	ExecBase	*SysBase;
struct	DosLibrary	*DOSBase;
struct	IntuitionBase *IntuitionBase;
struct	GfxBase		*GfxBase;

struct BitMap *bitmap1;
struct BitMap *bitmap2;

struct	ScreenBuffer	*screenbuffer1;
struct	ScreenBuffer	*screenbuffer2;

/*  For recall:
 
struct ScreenBuffer
{
    struct BitMap *sb_BitMap;		/* BitMap of this buffer */
    struct DBufInfo *sb_DBufInfo;	/* DBufInfo for this buffer */
};

struct DBufInfo {
	APTR	dbi_Link1;
	ULONG	dbi_Count1;
	struct Message dbi_SafeMessage;		/* replied to when safe to write to old bitmap */
	APTR dbi_UserData1;			/* first user data */

	APTR	dbi_Link2;
	ULONG	dbi_Count2;
	struct Message dbi_DispMessage;	/* replied to when new bitmap has been displayed at least
							once */
	APTR	dbi_UserData2;			/* second user data */
	ULONG	dbi_MatchLong;
	APTR	dbi_CopPtr1;
	APTR	dbi_CopPtr2;
	APTR	dbi_CopPtr3;
	UWORD	dbi_BeamPos1;
	UWORD	dbi_BeamPos2;
};

*/

#define	GfxText(RP,x,y,string)	(Move(RP,x,y),Text(RP,string,strlen(string)))

void main()
{
	Forbid();

	if(openshit())
	{
		long SafeToChange = TRUE;

		long a;

		GfxText(RP2,100,100,"Buffer 2");
		GfxText(RP1,100,100,"bUFFER 1");	// so the change can be noticed

		for(a=0;a<100;a++)
		{
			if(! SafeToChange)
				while(! GetMsg(disp_port1)) Wait(1l<<(disp_port1->mp_SigBit));
				// make sure the previous buffer was seen for at least 1 frame

			ChangeScreenBuffer(screen,screenbuffer2);
			
			while(! GetMsg(disp_port2)) Wait(1l<<(disp_port2->mp_SigBit));
			ChangeScreenBuffer(screen,screenbuffer1);
			SafeToChange = FALSE;

		}

/*		if(! SafeToChange2)
		{
			while(! GetMsg(disp_port2)) Wait(1L<<(disp_port2->mp_SigBit));
			while(! GetMsg(safe_port2)) Wait(1L<<(safe_port2->mp_SigBit));
		}
*/	
//		if(! SafeToChange1)
		{
			while(! GetMsg(disp_port1)) Wait(1L<<(disp_port1->mp_SigBit));
			while(! GetMsg(safe_port1)) Wait(1L<<(safe_port1->mp_SigBit));
		}

	}

	closeshit();

	Permit();
}

long openshit(void)
{
	long ok=0;

	DOSBase = 		(struct DosLibrary *)		OpenLibrary("dos.library",39);
	IntuitionBase = (struct IntuitionBase *)	OpenLibrary("intuition.library",39);
	GfxBase	= 		(struct GfxBase *)			OpenLibrary("graphics.library",39);

	if(DOSBase && IntuitionBase && GfxBase)
	{
		bitmap1 = AllocBitMap(cube_screen_width, cube_screen_len, cube_screen_depth, BMF_CLEAR + BMF_DISPLAYABLE + BMF_INTERLEAVED, NULL);
		bitmap2 = AllocBitMap(cube_screen_width, cube_screen_len, cube_screen_depth, BMF_CLEAR + BMF_DISPLAYABLE + BMF_INTERLEAVED, NULL);

		if(bitmap1 && bitmap2)
		{
			NewScreenStructure.CustomBitMap = bitmap1;
	
			if(screen = OpenScreen((struct NewScreen *)&NewScreenStructure))
			{
				Printf("screen opened ok\n");
	
				screenbuffer1 = AllocScreenBuffer(screen, bitmap1, NULL);
				screenbuffer2 = AllocScreenBuffer(screen, bitmap2, NULL);

				if (screenbuffer1 && screenbuffer2)
				{
					VP = &screen->ViewPort;

					RP1 = AllocVec(sizeof(struct RastPort), MEMF_CLEAR);
					RP2 = AllocVec(sizeof(struct RastPort), MEMF_CLEAR);

					if(RP1 && RP2)
					{
						InitRastPort(RP1);
						InitRastPort(RP2);

						RP1->BitMap = bitmap1;
						RP2->BitMap = bitmap2;

						Printf("secondary buffers ok\n");

						safe_port1 = CreateMsgPort();
						disp_port1 = CreateMsgPort();
						safe_port2 = CreateMsgPort();
						disp_port2 = CreateMsgPort();

						if(safe_port1 && disp_port1 && safe_port2 && disp_port2 )
						{
							screenbuffer1->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = safe_port1;
							screenbuffer1->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = disp_port1;

							screenbuffer2->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = safe_port2;
							screenbuffer2->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = disp_port2;

							ok = 1;

							Printf("synchro ports installed\n");

						}
					}
				}
			}
		}
	}	

	return(ok);
}

void closeshit(void)
{
	
	if(screen)
	{
		DeleteMsgPort(disp_port2);
		DeleteMsgPort(safe_port2);
		DeleteMsgPort(disp_port1);
		DeleteMsgPort(safe_port1);

		FreeVec(RP2);
		FreeVec(RP1);
		FreeScreenBuffer(screen,screenbuffer2);
		FreeScreenBuffer(screen,screenbuffer1);
		CloseScreen(screen);
	}

	WaitBlit();

	FreeBitMap(bitmap2);
	FreeBitMap(bitmap1);

	CloseLibrary((struct Library *)GfxBase);
	CloseLibrary((struct Library *)IntuitionBase);
	CloseLibrary((struct Library *)DOSBase);
}

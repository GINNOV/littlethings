;/* Anim.c - Animation example -- works with 1.3 and later.
If EXISTS animtools.c
	LC -b1 -cfist -v -j73 animtools.c  ;  Create AnimTools object file
Else
	Echo "Requires animtools.c (which isn't here) in order to compile."
	Quit
EndIf
LC -b1 -cfist -v -j73 anim.c
Blink FROM LIB:c.o,animtools.o,anim.o TO anim LIBRARY LIB:LC.lib,LIB:Amiga.lib
Quit ;


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.

*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuitionbase.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gels.h>

#include "animtools.h"
#include "animtools_proto.h"

#include <stdlib.h>
#include <stdio.h>

int CXBRK(void) { return(0); } /* disable lattice CTRL-C handling */

/*--------------------------------------------------------------*/
/*                                                              */
/*--------------------------------------------------------------*/
struct AnimOb *setupBoing(SHORT dbufing);
struct AnimOb *setupMan(SHORT dbufing);
struct AnimOb *setupWorm(SHORT dbufing);

WORD anEdgeORoutine(struct AnimOb *anOb);
WORD bounceORoutine(struct AnimOb *anOb);
WORD goInFrontOfHead(struct AnimComp *aComp);
WORD goBehindHead(struct AnimComp *aComp);

VOID runAnimation(struct Window *win, SHORT dbufing,
				  struct AnimOb **animKey, struct BitMap **myBitMaps);

LONG setupPlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height);
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height);
VOID freePlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height);
VOID freeBitMaps(struct BitMap **myBitMaps,
					LONG depth, LONG width, LONG height);

struct GelsInfo *setupDisplay(struct Window **win,
							  SHORT dbufing, struct BitMap **myBitMaps);
VOID DrawGels(struct Window *win, struct AnimOb **animKey, SHORT dbufing,
			  WORD *toggleFrame, struct BitMap **myBitMaps);

/*--------------------------------------------------------------*/
/*                                                              */
/*--------------------------------------------------------------*/
#define ANFS	ANFRACSIZE
#define BNFS	(ANFRACSIZE-2)
#define CNFS	(ANFRACSIZE-2)

/* These are used for MeMask (1 << ID_xxx) */
#define ID_BORDER 0
#define ID_WRM    3
#define ID_BNG    4
#define ID_MAN    5

#define SBMWIDTH  320  /* My screen size constants. */
#define SBMHEIGHT 200
#define SBMDEPTH    4
#define SCRNMODE NULL  /* (HIRES | LACE) for NewScreen, ends up in view.*/

#define RBMWIDTH  320  /* My raster size constants. (These CAN differ) */
#define RBMHEIGHT 200
#define RBMDEPTH    4

/*--------------------------------------------------------------*/
/*                                                              */
/*--------------------------------------------------------------*/
struct NewScreen ns =
	{
	0, 0, SBMWIDTH, SBMHEIGHT, SBMDEPTH, 0, 0, SCRNMODE,
	CUSTOMSCREEN | SCREENQUIET, NULL, NULL, NULL, NULL
	};

/* this is a little window that will let us get a CLOSEWINDOW message */
struct NewWindow nw =
	{
	0, 0, 25, 12, 0, 0, CLOSEWINDOW,
	WINDOWCLOSE | BORDERLESS | RMBTRAP, NULL, NULL, NULL, NULL,
	NULL, 0, 0, SBMWIDTH, SBMHEIGHT-1, CUSTOMSCREEN
	};

struct IntuitionBase *IntuitionBase	= NULL;
struct GfxBase		 *GfxBase		= NULL;

int return_code;

#include "anim_images.h"
/*--------------------------------------------------------------*/
/* Structures for the worm sequence.                            */
/*--------------------------------------------------------------*/

NEWBOB newWrmBob =
	{
	NULL,				/* nb_Image - image is null for sequences	*/
						/*			  data comes from NEWANIMSEQ	*/
	WRMWWIDTH,			/* nb_WordWidth - width of the bob			*/
	WRMHEIGHT,			/* nb_LineHeight - height of the bob		*/
	WRMDEPTH,			/* nb_ImageDepth - depth of image data		*/
	0x3,				/* nb_PlanePick - planes to put data in		*/
	0x0,				/* nb_PlaneOnOff - empty planes to set		*/
	SAVEBACK | OVERLAY,	/* nb_BFlags - flags for the bob			*/
	0,					/* nb_DBuf - 1=dbuf, 0=not dbuf				*/
	RBMDEPTH,			/* nb_RasDepth - num planes in raster		*/
	0,					/* nb_X - bob x position					*/
	0,					/* nb_Y - bob y position					*/
	(1L << ID_BORDER),	/* nb_HitMask - hit mask					*/
	(1L << ID_WRM),		/* nb_MeMask - me mask						*/
	};
NEWANIMSEQ newWrmSeq =
	{
	NULL,				/* nas_HeadOb - head object for the seq		*/
	(WORD *)WrmImage,	/* nas_Images - array of images				*/
	WrmXTranses,		/* nas_Xt - x offsets from central object	*/
	WrmYTranses,		/* nas_Yt - y offsets from central object	*/
	WrmTimes,			/* nas_Times - timing values for objects	*/
	WrmCRoutines,		/* nas_Routines - array of comp routines	*/
	0,					/* nas_CFlags - comp flags					*/
	WRMCOUNT,			/* nas_Count - number of comps in sequence	*/
	0,					/* nas_SingleImage - 1=single image for seq.*/
						/*					 0=multiple images      */
	};

/*--------------------------------------------------------------*/
/* Structures for the man sequence                              */
/*--------------------------------------------------------------*/

NEWBOB newNearLegBob =
	{
	NULL, MANLWWIDTH, MANLHEIGHT, MANLDEPTH, 0x3, 0xC,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_MAN),
	};
NEWANIMSEQ newNearLegSeq =
	{
	NULL, (WORD *)manLImage, manLXTranses, manLYTranses, manLTimes,
	manLCRoutines, 0, MANLCOUNT, 0,
	};

NEWBOB newFarLegBob =
	{
	NULL, MANLWWIDTH, MANLHEIGHT, MANLDEPTH, 0x3, 0x8,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_MAN),
	};
NEWANIMSEQ newFarLegSeq =
	{
	NULL, (WORD *)manLImage, manLXTranses, manLYTranses, manLTimes,
	manLCRoutines, 0, MANLCOUNT, 0,
	};

NEWBOB newNearArmBob =
	{
	NULL, MANAWWIDTH, MANAHEIGHT, MANADEPTH, 0x3, 0xC,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_MAN),
	};
NEWANIMSEQ newNearArmSeq =
	{
	NULL, (WORD *)manAImage, manAXTranses, manAYTranses, manATimes,
	manACRoutines, 0, MANACOUNT, 0,
	};

NEWBOB newFarArmBob =
	{
	NULL, MANAWWIDTH, MANAHEIGHT, MANADEPTH, 0x3, 0x8,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_MAN),
	};
NEWANIMSEQ newFarArmSeq =
	{
	NULL, (WORD *)manAImage, manAXTranses, manAYTranses, manATimes,
	manACRoutines, 0, MANACOUNT, 0,
	};

NEWBOB newTrunkBob =
	{
	NULL, MANTWWIDTH, MANTHEIGHT, MANTDEPTH, 0x3, 0xC,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_MAN),
	};
NEWANIMSEQ newTrunkSeq =
	{
	NULL, (WORD *)manTImage, manTXTranses, manTYTranses, manTTimes,
	manTCRoutines, 0, MANTCOUNT, 0,
	};

/*--------------------------------------------------------------*/
/* Structures for the boing ball and satellites.                */
/*--------------------------------------------------------------*/

NEWBOB newBoingBob =
	{
	NULL, BNG3WWIDTH, BNG3HEIGHT, BNG3DEPTH, 0xD, 0x2,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_BNG),
	};
NEWANIMSEQ newBoingSeq =
	{
	NULL, (WORD *)boing3Image, boing3XTranses, boing3YTranses,
	boing3Times, boing3CRoutines, 0, BNG3COUNT, 0,
	};

NEWBOB newSatABob =
	{
	NULL, SATWWIDTH, SATHEIGHT, SATDEPTH, 0xC, 0x0,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_BNG),
	};
NEWANIMSEQ newSatASeq =
	{
	NULL, (WORD *)satImage, satAXTranses, satAYTranses,
	satTimes, satACRoutines, 0, SATCOUNT, 1,
	};
NEWBOB newSatBBob =
	{
	NULL, SATWWIDTH, SATHEIGHT, SATDEPTH, 0xC, 0x3,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_BNG),
	};
NEWANIMSEQ newSatBSeq =
	{
	NULL, (WORD *)satImage, satBXTranses, satBYTranses,
	satTimes, satBCRoutines, 0, SATCOUNT, 1,
	};
NEWBOB newSatCBob =
	{
	NULL, SATWWIDTH, SATHEIGHT, SATDEPTH, 0x3, 0x0,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0, (1L<<ID_BORDER), (1L<<ID_BNG),
	};
NEWANIMSEQ newSatCSeq =
	{
	NULL, (WORD *)satImage, satCXTranses, satCYTranses,
	satTimes, satCCRoutines, 0, SATCOUNT, 1,
	};

/*--------------------------------------------------------------*/
/*--------------------------------------------------------------*/
/*                      PROCEDURES                              */
/*--------------------------------------------------------------*/
/*--------------------------------------------------------------*/

/*--------------------------------------------------------------
** setupBoing() - allocate and initialize an object that will
** display as a boing ball with orbiting sattellites.
**
** this is an animation object with four animation sequences.
** (boing and three sattellites.)
** (note that the sattellites all share the same single image data.)
**
** return NULL on failure.
*/
struct AnimOb *setupBoing(SHORT dbufing)
{
struct AnimOb	*bngOb;
struct AnimComp *bngComp;
struct AnimComp *satAComp;
struct AnimComp *satBComp;
struct AnimComp *satCComp;

if (NULL != (bngOb = AllocMem((LONG)sizeof(struct AnimOb), MEMF_CLEAR)))
	{
	bngOb->NextOb		= NULL;
	bngOb->PrevOb		= NULL;
	bngOb->Clock		= 0;
	bngOb->AnY			= 50;
	bngOb->AnX			= 50;
	bngOb->AnOldY		= bngOb->AnY;
	bngOb->AnOldX		= bngOb->AnX;
	bngOb->YVel			= 3 << ANFRACSIZE;
	bngOb->XVel			= 3 << ANFRACSIZE;
	bngOb->YAccel		= 0;
	bngOb->XAccel		= 0;
	bngOb->RingYTrans	= BNG3RINGY << ANFRACSIZE;
	bngOb->RingXTrans	= BNG3RINGX << ANFRACSIZE;
	bngOb->AnimORoutine	= bounceORoutine;
	bngOb->AUserExt		= 0;

	newBoingBob.nb_DBuf    = dbufing;
	newBoingSeq.nas_HeadOb = bngOb;

	satACRoutines[4]	  = goInFrontOfHead;
	satACRoutines[12]	  = goBehindHead;
	satBCRoutines[8]      = goInFrontOfHead;
	satBCRoutines[0]      = goBehindHead;
	satCCRoutines[4]      = goInFrontOfHead;
	satCCRoutines[12]     = goBehindHead;

	newSatABob.nb_DBuf	  = dbufing;
	newSatBBob.nb_DBuf	  = dbufing;
	newSatCBob.nb_DBuf	  = dbufing;
	newSatASeq.nas_HeadOb = bngOb;
	newSatBSeq.nas_HeadOb = bngOb;
	newSatCSeq.nas_HeadOb = bngOb;

	if (NULL != (bngComp = makeSeq(&newBoingBob, &newBoingSeq)))
		{
		bngComp->Flags |= RINGTRIGGER;
		bngOb->HeadComp = bngComp;

		if (NULL != (satAComp = makeSeq(&newSatABob, &newSatASeq)))
			{
			bngComp->AnimBob->Before = satAComp->AnimBob;
			satAComp->AnimBob->After = bngComp->AnimBob;

			if (NULL != (satBComp = makeSeq(&newSatBBob, &newSatBSeq)))
				{
				satAComp->AnimBob->Before = satBComp->AnimBob;
				satBComp->AnimBob->After = satAComp->AnimBob;

				if (NULL != (satCComp = makeSeq(&newSatCBob, &newSatCSeq)))
					{
					satBComp->AnimBob->Before = satCComp->AnimBob;
					satCComp->AnimBob->After = satBComp->AnimBob;

					bngComp->NextComp  = satAComp;
					bngComp->PrevComp  = NULL;

					satAComp->NextComp = satBComp;
					satAComp->PrevComp = bngComp;

					satBComp->NextComp = satCComp;
					satBComp->PrevComp = satAComp;

					satCComp->NextComp = NULL;
					satCComp->PrevComp = satBComp;

					return(bngOb);
					}
				freeSeq(satBComp,RBMDEPTH);
				}
			freeSeq(satAComp,RBMDEPTH);
			}
		freeSeq(bngComp,RBMDEPTH);
		}
	FreeMem(bngOb, (LONG)sizeof(struct AnimOb));
	}
return_code = RETURN_WARN;
return(NULL);
}

/*--------------------------------------------------------------
** setupMan() - allocate and initialize an object that will
** display as a walking man.
**
** this is an animation object with five animation sequences.
** (body, two arms and two legs.)
**
** return NULL on failure.
*/
struct AnimOb *setupMan(SHORT dbufing)
{
struct AnimOb *manOb;

struct AnimComp *trunkComp;
struct AnimComp *farArmComp;
struct AnimComp *farLegComp;
struct AnimComp *nearArmComp;
struct AnimComp *nearLegComp;

if (NULL != (manOb = AllocMem((LONG)sizeof(struct AnimOb), MEMF_CLEAR)))
	{
	manOb->NextOb		= NULL;
	manOb->PrevOb		= NULL;
	manOb->Clock		= 0;
	manOb->AnY			= ((2 * MANHEIGHT) << ANFRACSIZE);
	manOb->AnX			= 0;
	manOb->AnOldY		= manOb->AnY;
	manOb->AnOldX		= manOb->AnX;
	manOb->YVel			= 0;
	manOb->XVel			= 0;
	manOb->YAccel		= 0;
	manOb->XAccel		= 0;
	manOb->RingYTrans	= (MANRINGY << ANFRACSIZE);
	manOb->RingXTrans	= (MANRINGX << ANFRACSIZE);
	manOb->AnimORoutine	= anEdgeORoutine;
	manOb->AUserExt		= 0;

	newTrunkBob.nb_DBuf   = dbufing;
	newFarArmBob.nb_DBuf  = dbufing;
	newFarLegBob.nb_DBuf  = dbufing;
	newNearArmBob.nb_DBuf = dbufing;
	newNearLegBob.nb_DBuf = dbufing;

	newTrunkSeq.nas_HeadOb   = manOb;
	newFarArmSeq.nas_HeadOb  = manOb;
	newFarLegSeq.nas_HeadOb  = manOb;
	newNearArmSeq.nas_HeadOb = manOb;
	newNearLegSeq.nas_HeadOb = manOb;

	if (NULL != (trunkComp = makeSeq(&newTrunkBob, &newTrunkSeq)))
		{
		trunkComp->Flags |= RINGTRIGGER;

		if (NULL != (farArmComp = makeSeq(&newFarArmBob, &newFarArmSeq)))
			{
			trunkComp->AnimBob->Before = farArmComp->AnimBob;
			farArmComp->AnimBob->After = trunkComp->AnimBob;

			if (NULL != (farLegComp = makeSeq(&newFarLegBob, &newFarLegSeq)))
				{
				farArmComp->AnimBob->Before = farLegComp->AnimBob;
				farLegComp->AnimBob->After = farArmComp->AnimBob;

				if (NULL != (nearArmComp =
							makeSeq(&newNearArmBob, &newNearArmSeq)))
					{
					nearArmComp =
						nearArmComp->NextSeq->NextSeq->NextSeq->NextSeq;
					farLegComp->AnimBob->Before = nearArmComp->AnimBob;
					nearArmComp->AnimBob->After = farLegComp->AnimBob;

					if (NULL != (nearLegComp =
									makeSeq(&newNearLegBob, &newNearLegSeq)))
						{
						nearLegComp =
							nearLegComp->NextSeq->NextSeq->NextSeq->NextSeq;
						nearArmComp->AnimBob->Before = nearLegComp->AnimBob;
						nearLegComp->AnimBob->After = nearArmComp->AnimBob;

						manOb->HeadComp = trunkComp;

						trunkComp->PrevComp = NULL;
						trunkComp->NextComp = farArmComp;

						farArmComp->PrevComp = trunkComp;
						farArmComp->NextComp = farLegComp;

						farLegComp->PrevComp = farArmComp;
						farLegComp->NextComp = nearArmComp;

						nearArmComp->PrevComp = farLegComp;
						nearArmComp->NextComp = nearLegComp;

						nearLegComp->PrevComp = nearArmComp;
						nearLegComp->NextComp = NULL;

						return(manOb);
						}
					freeSeq(nearArmComp,RBMDEPTH);
					}
				freeSeq(farLegComp,RBMDEPTH);
				}
			freeSeq(farArmComp,RBMDEPTH);
			}
		freeSeq(trunkComp,RBMDEPTH);
		}
	FreeMem(manOb, (LONG)sizeof(struct AnimOb));
	}
return_code = RETURN_WARN;
return(NULL);
}

/*--------------------------------------------------------------
** setupBoing() - allocate and initialize an object that will
** display as an inch worm.
**
** this is an animation object with only one animation sequence.
**
** return NULL on failure.
*/
struct AnimOb *setupWorm(SHORT dbufing)
{
struct AnimOb   *wormOb;
struct AnimComp *wormComp;

if (NULL != (wormOb = AllocMem((LONG)sizeof(struct AnimOb), MEMF_CLEAR)))
	{
	wormOb->NextOb		 = NULL;
	wormOb->PrevOb		 = NULL;
	wormOb->Clock		 = 0;
	wormOb->AnY			 = ((RBMHEIGHT - WRMHEIGHT - 5) << ANFRACSIZE);
	wormOb->AnX			 = (10L << ANFRACSIZE);
	wormOb->AnOldY		 = wormOb->AnY;
	wormOb->AnOldX		 = wormOb->AnX;
	wormOb->YVel		 = 0;
	wormOb->XVel		 = 0;
	wormOb->YAccel		 = 0;
	wormOb->XAccel		 = 0;
	wormOb->RingYTrans	 = (WRMRINGY << ANFRACSIZE);
	wormOb->RingXTrans	 = (WRMRINGX << ANFRACSIZE);
	wormOb->AnimORoutine = anEdgeORoutine;
	wormOb->AUserExt	 = 0;

	newWrmBob.nb_DBuf	 = dbufing;
	newWrmSeq.nas_HeadOb = wormOb;

	if (NULL != (wormComp = makeSeq(&newWrmBob, &newWrmSeq)))
		{
		wormComp->Flags |= RINGTRIGGER;
		wormOb->HeadComp = wormComp;

		return(wormOb);
		}
	}
return_code = RETURN_WARN;
return(NULL);
}

/*--------------------------------------------------------------
** This ORoutine makes the Object restart on left edge if it has
** gone off the right of the screen. If it has gone off the top,
** it is restarted at the bottom. It is used for the worm and the
** man. It works for animations that move to the right, and
** optionally up, ONLY.
*/
WORD anEdgeORoutine(struct AnimOb *anOb)
{
struct AnimComp *acptr;
struct AnimComp *seqptr;

acptr = anOb->HeadComp;

while (acptr)
	{
	seqptr = acptr;
	do	{
		if (seqptr->AnimBob->BobVSprite->Flags & GELGONE)
			{
			seqptr->AnimBob->BobVSprite->Flags &= ~GELGONE;
			anOb->AnX = -10L << ANFRACSIZE;
			if (anOb->AnY <= 0)
				anOb->AnY = (RBMHEIGHT-60L) << ANFRACSIZE;
			}
		seqptr = seqptr->NextSeq;
		} while (seqptr != acptr && (seqptr));
	acptr = acptr->NextComp;
	}
return(0) ;
}

/*--------------------------------------------------------------
** This ORoutine makes the Object Bounce off Borders.
*/
WORD bounceORoutine(struct AnimOb *anOb)
{
SHORT Y;
SHORT X;

Y = anOb->AnY >> ANFRACSIZE;
X = anOb->AnX >> ANFRACSIZE;

if ((Y<0 && anOb->YVel < 0) ||
	((Y+anOb->HeadComp->AnimBob->BobVSprite->Height > RBMHEIGHT) &&
	 (anOb->YVel > 0)))
	{
	anOb->YVel = -(anOb->YVel);
	}

if (((X < 0) && (anOb->XVel < 0)) ||
	((X + (anOb->HeadComp->AnimBob->BobVSprite->Width << 4) > RBMWIDTH) &&
	 (anOb->XVel > 0)))
	{
	anOb->XVel = -(anOb->XVel);
	}
return(0) ;
}

/*--------------------------------------------------------------
** This CRoutine rearranges Bob Before and After pointers in a
** way that makes the Component passed look like it is in front
** of its' head component.
** 
** Used for Boing satelittes.
** 
** So that they go in front of AND behind the boing ball.
*/
WORD goInFrontOfHead(struct AnimComp *aComp)
{
/* close up hole */
if (aComp->AnimBob->Before != NULL)
	aComp->AnimBob->Before->After = aComp->AnimBob->After;
if (aComp->AnimBob->After != NULL)
	aComp->AnimBob->After->Before = aComp->AnimBob->Before;

/* reinsert */
aComp->AnimBob->Before = aComp->HeadOb->HeadComp->AnimBob->Before;
aComp->AnimBob->After = aComp->HeadOb->HeadComp->AnimBob;
if (aComp->AnimBob->Before != NULL)
	aComp->AnimBob->Before->After = aComp->AnimBob;
aComp->HeadOb->HeadComp->AnimBob->Before = aComp->AnimBob;

return(0) ;
}

/*--------------------------------------------------------------
** This CRoutine rearranges Bob Before and After pointers in a
** way that makes the Component passed look like it is behind
** its' head component.
*/
WORD goBehindHead(struct AnimComp *aComp)
{
if (aComp->AnimBob->Before != NULL)
	aComp->AnimBob->Before->After = aComp->AnimBob->After;
if (aComp->AnimBob->After != NULL)
	aComp->AnimBob->After->Before = aComp->AnimBob->Before;

aComp->AnimBob->After = aComp->HeadOb->HeadComp->AnimBob->After;
aComp->AnimBob->Before = aComp->HeadOb->HeadComp->AnimBob;
if (aComp->AnimBob->After != NULL)
	aComp->AnimBob->After->Before = aComp->AnimBob;
aComp->HeadOb->HeadComp->AnimBob->After = aComp->AnimBob;

return(0) ;
}

/*--------------------------------------------------------------
**
*/
VOID runAnimation(struct Window *win,
				  SHORT dbufing,
				  struct AnimOb **animKey,
				  struct BitMap **myBitMaps)
{
struct IntuiMessage  *intuiMsg;
WORD toggleFrame;

toggleFrame = 0;

/* everything opened, and allocated, and initialized.
** Now I just hang out, move the gels, tell the system to redraw them,
** and let the collision and anim routines bounce them about.
*/
for (;;)
	{
	/* All the work done here */
	DrawGels(win, animKey, dbufing, &toggleFrame, myBitMaps);

	while (intuiMsg = (struct IntuiMessage *)GetMsg(win->UserPort))
		{
		if (intuiMsg->Class == CLOSEWINDOW)
			{
			ReplyMsg((struct Message *)intuiMsg);
			return;
			}
		ReplyMsg((struct Message *)intuiMsg);
		}
	}
}

/*---------------------------------------------------------
** allocate the bit planes for a screen bit map.
*/
LONG setupPlanes(struct BitMap *bitMap,
				 LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
	{
	if (NULL != (bitMap->Planes[plane_num] =
					(PLANEPTR)AllocRaster(width, height)))
		BltClear(bitMap->Planes[plane_num], (width / 8) * height, 1);
	else
		{
		freePlanes(bitMap, depth, width, height);
		return_code = RETURN_WARN;
		return(NULL);
		}
	}
return(TRUE);
}

/*---------------------------------------------------------
** allocate the bit maps for a double buffered screen.
*/
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height)
{
/* this must be static -- it cannot go away when the routine exits. */
static struct BitMap *myBitMaps[2];

if (NULL != (myBitMaps[0] =
		(struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR)))
	{
	if (NULL != (myBitMaps[1] =
		(struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR)))
		{
		InitBitMap(myBitMaps[0], depth, width, height);
		InitBitMap(myBitMaps[1], depth, width, height);

		if (NULL != setupPlanes(myBitMaps[0], depth, width, height))
			{
			if (NULL != setupPlanes(myBitMaps[1], depth, width, height))
				return(myBitMaps);

			freePlanes(myBitMaps[0], depth, width, height);
			}
		FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
		}
	FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
	}
return_code = RETURN_WARN;
return(NULL);
}

/*--------------------------------------------------------------
** free up the memory allocated by setupPlanes().
*/
VOID	freePlanes(struct BitMap *bitMap,
				   LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
	{
	if (NULL != bitMap->Planes[plane_num])
		FreeRaster(bitMap->Planes[plane_num], width, height);
	}
}

/*--------------------------------------------------------------
** free up the memory allocated by setupBitMaps().
*/
VOID	freeBitMaps(struct BitMap **myBitMaps,
					LONG depth, LONG width, LONG height)
{
freePlanes(myBitMaps[0], depth, width, height);
freePlanes(myBitMaps[1], depth, width, height);

FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
}

/*--------------------------------------------------------------
**
*/
struct GelsInfo *setupDisplay(struct Window **win,
							  SHORT dbufing,
							  struct BitMap **myBitMaps)
{
struct GelsInfo	   *gInfo;
struct Screen	   *screen;
struct ViewPort	   *vport;
struct RastPort    *rport;

if (dbufing)
	{
	/* Screen type. We alloc two BitMaps. See DBLBUF comments. */
	ns.Type |= CUSTOMBITMAP;
	ns.CustomBitMap = myBitMaps[0];
	}

if ((screen = (struct Screen *)OpenScreen(&ns)) != NULL)
	{
	vport = &screen->ViewPort;
	rport = &screen->RastPort;

	SetRGB4(vport, 0x0, 0x0, 0x0, 0x0); /* Black */
	SetRGB4(vport, 0x1, 0x0, 0x6, 0x0); /* dk green */
	SetRGB4(vport, 0x2, 0x0, 0x9, 0x0); /* med green */
	SetRGB4(vport, 0x3, 0x0, 0xC, 0x0); /* lt green */
	SetRGB4(vport, 0x4, 0x1, 0x1, 0x7); /* dk blue */
	SetRGB4(vport, 0x5, 0x7, 0x0, 0x8); /* dk violet */
	SetRGB4(vport, 0x6, 0x6, 0x6, 0x6); /* dk grey */
	SetRGB4(vport, 0x7, 0x7, 0x1, 0x0); /* dk red */
	SetRGB4(vport, 0x8, 0x3, 0x3, 0xB); /* med blue */
	SetRGB4(vport, 0x9, 0xB, 0x0, 0xC); /* med violet */
	SetRGB4(vport, 0xA, 0x9, 0x9, 0x9); /* med grey */
	SetRGB4(vport, 0xB, 0xB, 0x0, 0x0); /* med red */
	SetRGB4(vport, 0xC, 0x5, 0x5, 0xF); /* lt blue */
	SetRGB4(vport, 0xD, 0xE, 0x0, 0xF); /* lt violet */
	SetRGB4(vport, 0xE, 0xF, 0xF, 0xF); /* lt grey (white) */
	SetRGB4(vport, 0xF, 0xF, 0x0, 0x0); /* lt red */

	/* put some stuff in the background, so we can
	** see that it does not get destroyed.
	*/
	SetAPen(rport, 0xA);
	SetDrMd(rport, JAM1);
	Move(rport, 70, 105);
	Text(rport, "Animation Example...", 20);

	nw.Screen = screen;
	if ((*win = (struct Window *)OpenWindow(&nw)) != NULL)
		{
		if (dbufing)
			{
			(*win)->WScreen->RastPort.Flags = DBUFFER;

			/* copy the rast port data into the alternate rast port */
			(*win)->WScreen->RastPort.BitMap = myBitMaps[1];
			BltBitMapRastPort(myBitMaps[0], 0,0, &(*win)->WScreen->RastPort,
						0,0, RBMWIDTH, RBMHEIGHT, 0xC0);
			(*win)->WScreen->RastPort.BitMap = myBitMaps[0];
			}

		/* set up the gels system.
		** 0x03 says: when you allocate sprites for me, don't ever use
		** sprites zero or one. This guarantees that sprite zero, the
		** intuition pointer, stays intact. Remember sprite one shares
		** colors with sprite zero.
		*/
		if (NULL != (gInfo = setupGelSys(&(*win)->WScreen->RastPort, 0x03)))
			return(gInfo);

		CloseWindow(*win);
		}
	CloseScreen(screen);
	}
return_code = RETURN_WARN;
return(NULL);
}

/*--------------------------------------------------------------
** DrawGels part of loop.
*/
VOID DrawGels(struct Window *win,
			  struct AnimOb **animKey,
			  SHORT dbufing,
			  WORD *toggleFrame,
			  struct BitMap **myBitMaps)
{
Animate(animKey, &win->WScreen->RastPort);

SortGList(&win->WScreen->RastPort);   /* Put the list in order. */
DoCollision(&win->WScreen->RastPort); /* Collision routines may called now */
SortGList(&win->WScreen->RastPort);	  /* Put the list in order. */

if (dbufing)
	win->WScreen->ViewPort.RasInfo->BitMap = myBitMaps[*toggleFrame];

/* Draw 'em. */
DrawGList(&win->WScreen->RastPort, &win->WScreen->ViewPort);

if (dbufing)
	{
	MakeScreen(win->WScreen);	/* Tell intuition to do it's stuff. */
	RethinkDisplay();			/* Does a MrgCop & LoadView. */

	*toggleFrame ^= 1;
	/* Flip to the next BitMap. */
	win->WScreen->RastPort.BitMap = myBitMaps[*toggleFrame];
	}
else
	WaitTOF();
}

/*--------------------------------------------------------------
**
*/
VOID main(int argc, char **argv)
{
struct BitMap	**myBitMaps;
struct AnimOb	 *boingOb;
struct AnimOb	 *wormOb;
struct AnimOb	 *manOb;
struct Window	 *win;
struct Screen	 *screen;
struct GelsInfo	 *gInfo;
struct AnimOb	 *animKey;
SHORT dbufing;

return_code = RETURN_OK; /* a global variable, yech! */


if (argc > 1)
	dbufing = 1;  /* run double buffered when arguments */
else
	{
	dbufing = 0;  /* not double buff */
	if (argc)
		printf("Program will run double buffered if there are\nany command line arguments.\n");
	}

if (NULL == (IntuitionBase = (struct IntuitionBase *)
		OpenLibrary(INTUITIONNAME, 34L)))
	return_code = RETURN_FAIL;
else
	{
	if (NULL == (GfxBase = (struct GfxBase *)
			OpenLibrary(GRAPHICSNAME, 34L)))
		return_code = RETURN_FAIL;
	else
		{
		if ((!dbufing) ||
			(NULL != (myBitMaps=setupBitMaps(RBMDEPTH,RBMWIDTH,RBMHEIGHT))))
			{
			if (NULL != (gInfo = setupDisplay(&win,dbufing,myBitMaps)))
				{
				InitAnimate(&animKey);
				/* Simple sequenced animation. (Boing ball)
				** Simple animation using XTrans and YTrans.
				** (tiny orbiting satellite)
				*/
				if (NULL != (boingOb = setupBoing(dbufing)))
					{
					AddAnimOb(boingOb, &animKey, &win->WScreen->RastPort);
					if (NULL != (wormOb = setupWorm(dbufing)))
						{
						AddAnimOb(wormOb, &animKey, &win->WScreen->RastPort);
						if (NULL != (manOb = setupMan(dbufing)))
							{
							AddAnimOb(manOb, &animKey,
										&win->WScreen->RastPort);
							runAnimation(win, dbufing, &animKey, myBitMaps);
							freeOb(manOb, RBMDEPTH);
							}
						freeOb(wormOb, RBMDEPTH);
						}
					freeOb(boingOb, RBMDEPTH);
					}

				cleanupGelSys(gInfo, &win->WScreen->RastPort);
				screen = win->WScreen;
				CloseWindow(win);
				CloseScreen(screen);
				}

			if (dbufing)
				freeBitMaps(myBitMaps, RBMDEPTH, RBMWIDTH, RBMHEIGHT);
			}
		CloseLibrary((struct Library *)GfxBase);
		}
	CloseLibrary((struct Library *)IntuitionBase);
	}
exit(return_code);
}

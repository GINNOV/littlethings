typedef struct newBob {
WORD	   *nb_Image;
SHORT	    nb_WordWidth;
SHORT	    nb_LineHeight;
SHORT	    nb_ImageDepth;
SHORT	    nb_PlanePick;
SHORT	    nb_PlaneOnOff;
SHORT	    nb_BFlags;
SHORT	    nb_DBuf;
SHORT	    nb_RasDepth;
SHORT	    nb_X;
SHORT	    nb_Y;
USHORT	    nb_HitMask;
USHORT	    nb_MeMask;
} NEWBOB ;

struct GelsInfo *setupGelSys(struct RastPort *rPort, BYTE reserved);
VOID		cleanupGelSys(struct GelsInfo *gInfo, struct RastPort *rPort);
struct Bob	*makeBob(NEWBOB *nBob);
VOID		freeBob(struct Bob *bob, LONG rasdepth);


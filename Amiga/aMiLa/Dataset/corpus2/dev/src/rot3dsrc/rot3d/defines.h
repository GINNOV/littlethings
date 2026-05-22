
/* rot global include file
 *  Used by rot.c megamap.c megadraw.c objects.c lists.c
 */

/******************************************************************
* from rot.c
******************************************************************/
/*#include "tracker.h"*/

#define SCREENX screenx
#define SCREENY screeny
#define DEPTH 5
#define SBYTESPERROW	(SCREENX>>3)
#define SCREENMODE 0
#define SCREENOVR 0
#define SCREENX1 SCREENX-1
#define SCREENY1 SCREENY-1
#define SCALE 2
#define SCREENYFUCK 0
#define ASPECT .85
#define FIX 3.14159/180
#define BOX 2.0
#define MAXPOINTS 128
#define MAXEDGES 128
#define MAXPOLY 128
#define DIST 4.0
#define WALLWIDTH 256
#define WALLHEIGHT 128
#define ROTATE 6
#define TRANSLATE 0.05
#define MIN(x,y) (((x)<(y)) ? (x) : (y))
#define MAX(x,y) (((x)>(y)) ? (x) : (y))
#define ABS(x) (((x)<0) ? -(x) : (x))
#define NORTH 0
#define SOUTH 2
#define EAST 1
#define WEST 3

extern struct Screen *Screen;
extern struct BitMap bm1,fastbm,mapbm;
extern float transX,transY;
extern BYTE Direction(float angle);
extern float angle;
extern float points[MAXPOINTS][3];
extern float subpoints[MAXPOINTS][3];
extern short numedges;
extern UBYTE edges[MAXEDGES][3];
extern short PointInBox(float x,float y);
extern void PointInWall(float x,float y);
extern short inside;
extern void PlotMap();
extern UBYTE *heighttolight;

/******************************************************************
* from blitter.c
******************************************************************/

#define NUMMISC 1
#define NUMITEMS 3

typedef struct
{
	PLANEPTR Planes[6];		/*  0  5 Planes of color + mask */
	UBYTE BytesPerRow;		/*  24 Plane Width in Bytes */
	UBYTE Rows;				/*  25 Number or Rows High */
	UBYTE Width;			/*  26 Actual Width in pixels */
	UBYTE UsedPlanes;		/*  27 The Planes that are used */
	UBYTE PlaneValue;		/*  28 The Value 1/0 to place in unused planes */
	UBYTE Flags;			/*  29 see below */
	UBYTE Pointer;			/*  30 Is the Planes[bit] a copy? */
	UBYTE Pad;
} Brush;

		/*  Flag definitions
		BitNo
		 0		Flipable?
		 1		VFlipState
		 2		HFlipState
		 3	*/

extern void NewBltBrush(Brush *brush,struct BitMap *bm,short x,short y,BYTE flags);
extern BYTE monocolor;
extern short clipheight;
extern BYTE cleared;
/*extern void CleanItUp();*/
extern struct RastPort buffer;
extern struct RastPort bltbuffer;
extern struct BitMap bltmap;
extern Brush *bltbrush;
extern struct Window *FirstWindow;
/*extern void GetInput(short *x, short *y, char *c);*/
/*extern void DrawMiscScreen(short screen);*/
/*extern void LoadItems(void);*/

/******************************************************************
* from lists.c
******************************************************************/

/* listrec types */
#define NOTHING 0
#define AUTOCLOSEDOOR 1
#define STAYOPENDOOR 2
#define SECRETDOOR 3
#define BUTTON_BOOL 4
#define IN 1
#define OUT 0

typedef struct node *ListRecPtr;
typedef struct node
{
/* Generic elements */
	BYTE 	type;			/* type of dungeon, use #DEFINES here! */
	float 	x,y,z; 			/* xyz coords of object in dungeon, if any */
	short 	brushnumber;	/* index into brushes[][] that object uses, if any*/
	BYTE 	active;			/* if !active, skip this record. */
	BYTE 	direction;		/* 0=N, 1=E, 2=S, 3=W;  direction object is facing*/
	short 	state;         	/* used for miscellaneous purposes */
	short   wall1, wall2;   /* changes a wall# when active/deactive */
	short   scrx,scry;      /* Flat screen coords of object */
	float   distance;       /* distance from object to you (squared) */
	short   dotable;        /* state info saying what to do */

/* Door fields */
	BYTE 	key;			/* which key/button is req'd to open this door */
	BYTE 	open;			/* 1=open,  0=closed */
	short 	edge;			/* which "edge[]" entry is the door */

	ListRecPtr next;
	ListRecPtr prev;

} ListRec;

extern ListRec *DeleteNode(ListRec *node, ListRec *list);
extern ListRec *InsertNode(ListRec *node, ListRec *list);
extern void InsertDoor(short edge, BYTE type, BYTE key, BYTE dir);
extern void InsertButton(int edge, short dir, short start, short out, short in, short y);
extern ListRec *doors;
extern ListRec *objects;
extern ListRec *buttons;
extern void PrintNode(ListRec *p);
extern void PrintList(ListRec *p);

/******************************************************************
* from objects.c
******************************************************************/

extern void ActivateDoor();
extern void MoveDoors();

/******************************************************************
* from digisoun.c
******************************************************************/

extern short OpenAudio();
extern short SnagChannel(short ch);
extern short FinishAudio();
extern struct ExtIOB *GetIOB(long ch);
extern       ReEmployIOB();
extern long	 FreeIOB(struct  ExtIOB *iob,long ch);
extern long  InitBlock(struct ExtIOB *iob,WORD channel);
extern long  ControlChannel(long channel,long command);
extern long  GetChannel(long ch);
extern long  FreeChannel(long ch);
extern       InitSoundSample(long ch,short data,short vol,short per,short reps);
extern long	 LoadSample(short data,char *sample);
extern UWORD Error(long ErrFlag,char *ProgMsg);
extern void	 PlaySample(short chan,short data,short vol,short per,short reps);
extern char	 UnpackFibBytes(register char *inp,register long n,char *outp,register char val);
extern void	 Unpack(long total,long start);
extern short FindChannel(short type,UBYTE *memPtr);
extern long	 ModifySample(short ch,short volume,short rate);
extern void	 SinglePlay(char *fname,short volume,short rate,short reps);
extern void	 PlaySound(UBYTE *memPtr,short volume,short rate,short reps);
extern UBYTE *LoadSound(char *filename);
extern void	 FreeSound(UBYTE *memPtr);
extern void	 CheckSampleTimer();
extern short RepeatPlay(UBYTE *memPtr,short volume,short rate);
extern void  StopRepeatPlay(short channel);



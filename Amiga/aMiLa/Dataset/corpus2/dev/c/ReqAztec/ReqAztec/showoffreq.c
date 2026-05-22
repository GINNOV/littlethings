/*
 *	showoffreq.c - Copyright © 1990 by Devil's child.
 *
 *	Created:	25 Oct 1990  17:12:40
 *	Modified:	26 Oct 1990  19:37:08
 *
 *	Make>> make
 */

#include <libraries/reqbase.h>
#include <req_pragmas.h>

#define	WIDTH  640
#define	HEIGHT 200
#define	DEPTH  3

#define	GADGETSTARTX	20
#define	GADGETSTARTY	60

#define	IDCMP	(GADGETUP)
#define	FLAGS	(BACKDROP|SMART_REFRESH|ACTIVATE|BORDERLESS)

struct IntuitionBase	*IntuitionBase;
struct GfxBase			*GfxBase;
struct ReqLib			*ReqBase;
struct Window			*window;
struct Screen			*screen;

struct NewScreen ns =
	{
	0, 0,					/* LeftEdge, TopEdge */
	WIDTH, HEIGHT, DEPTH,	/* Width, Height, Depth */
	0, 1,					/* DetailPen, BlockPen */
	HIRES,					/* ViewModes */
	CUSTOMSCREEN,			/* Type */
	NULL,					/* Font */
	(UBYTE *)"Show off requester library.",	/* Title */
	NULL,					/* Gadgets */
	NULL					/* Bitmap */
	};

struct NewWindow nw =
	{
	0,0,					/* LeftEdge, TopEdge */
	WIDTH,HEIGHT,			/* Width, Height */
	-1,-1,					/* DetailPen, BlockPen */
	IDCMP,					/* IDCMPFlags */
	FLAGS,					/* Flags */
	NULL,					/* FirstGadget */
	NULL,					/* CheckMark */
	NULL,					/* Title */
	NULL,					/* Screen */
	NULL,					/* BitMap */
	79, 30,					/* MinWidth, MinHeight */
	640, 200,				/* MaxWidth, MaxHeight */
	CUSTOMSCREEN			/* Type (of screen) */
	};


struct Process	*myprocess;
APTR	olderrorwindow;



	/* I declared this variable as global, rather than just declaring it as */
	/* a regular local variable because I need to make sure that all of the */
	/* fields are initialized to zero. */
	/* Also, the quit_cleanup routine needs to be able to access it to purge */
	/* the directory buffers which I have chosen to use (by setting the */
	/* FRQCACHINM flag. */

struct FileReq	MyFileReqStruct;
char filename[REQ_FCHARS];
char directoryname[REQ_DSIZE];

void ShowFileRequester(void)
	{
	char	answerarray[REQ_DSIZE+REQ_FCHARS];

	answerarray[0] = 0;

		/* Initialize the 'PathName' field so that the file requester will */
		/* construct a complete path name for me.  It will also put the two */
		/* parts of the answer (directory and file name) into the directory */
		/* file name which I also decided to supply it with.  Since the */
		/* directory and file name arrays are present, it will use their */
		/* initial contents as the initial file and directory.  If they aren't */
		/* present it will leave both blank to start. */
	MyFileReqStruct.PathName = answerarray;
	MyFileReqStruct.Dir = directoryname;
	MyFileReqStruct.File = filename;

		/* The directory caching of this file requester is one of its nice */
		/* features, so I decided to show it off.  It is completely optional */
		/* though, so if you don't want it, don't set this flag.  If you do */
		/* want it, don't forget to call PurgeFiles() when you are done. */
	MyFileReqStruct.Flags = FRQCACHINGM;

		/* Initialize a few colour fields.  Not strictly necessary, but */
		/* personally, I like having my files a different colour from my */
		/* directories. */
	MyFileReqStruct.dirnamescolor = 2;
	MyFileReqStruct.devicenamescolor = 2;
		/* I could also make it larger, pass it a file and/or directory */
		/* name, set the window title, set various flags and customize */
		/* in many other ways, but I wanted to show that it can be easily */
		/* used without having to fill in a lot of fields. */
	if (FileRequester(&MyFileReqStruct))
		SimpleRequest("System Request","You selected the file '%s'.", answerarray);
	else
		SimpleRequest("System Request","You didn't select a file.");
	}



void ShowColorRequester(void)
	{
	ColorRequester(1L);		/* Pass it the color you want to start out being highlit. */
							/* It actually returns the colour that the user chose, but */
							/* I'm not interested in that value. */

		/* If you want to give more parameters to the colour requester, you can */
		/* call ExtendedColorRequester with the address of an ExtendedColorRequest */
		/* structure.  Currently the only additional parameter this lets you pass */
		/* is the address of the window the requester should appear in.  This can */
		/* normally be done more easily by specifying it in the pr_WindowPtr field */
		/* of your process structure, as long as you are a process rather than a. */
		/* task. */
	}



void ShowSimpleText(void)
	{
	SimpleRequest("System Request",
"     SimpleRequest()  is  a  tiny bit of\n"
"glue  code  which  passes  a single text\n"
"string  (with  optional  printf()  style\n"
"formatting) to the TextRequest() routine\n"
"in  the  library.   The  SimpleRequest()\n"
"routine  can  be  easily modified to fit\n"
"your own peculiar purposes.");
	}



char *yesno[] =
	{
	"no",
	"yes",
	};

void ShowTwoGadText(void)
	{
	short	result;

	result = TwoGadRequest("System Request","Just testing the two gadget requester.");
	SimpleRequest("System Request","You responded with a '%s' to this requester.", yesno[result]);
	}



char *response[] =
	{
	"You really should use it.",
	"Excellent choice.  You have good taste.",
	"Oh come one, make up your mind.\nYou won't regret choosing 'yes'.",
	};

void ShowThreeGadText(void)
	{
	struct TRStructure	MyTextStruct;
	short	result;

	MyTextStruct.Text = "     Would you use the requester library\n"
						"in your programs?";
		/* The Controls field doesn't actually have to be initialized, unless you */
		/* are using printf() style formatting of the Text string. */
	MyTextStruct.Window = 0;	/* This must be zero or a valid window pointer. */
	MyTextStruct.MiddleText = "Perhaps...";
	MyTextStruct.PositiveText = "Oh yeah, for sure!";
	MyTextStruct.NegativeText = "Methinks not.";
	MyTextStruct.Title = "Show off text requester.";
	MyTextStruct.KeyMask = AMIGAKEYS;		/* Allow only keys together with the amiga */
											/*  qualifiers to be used for keyboard shortcuts. */
	MyTextStruct.textcolor = 1;
	MyTextStruct.detailcolor = 0;
	MyTextStruct.blockcolor = 1;
	MyTextStruct.versionnumber = 0;
	MyTextStruct.rfu1 = 0;
	MyTextStruct.rfu2 = 0;
	result = TextRequest(&MyTextStruct);
	SimpleRequest("System Request",response[result]);
	}



	/* I declared this variable globally, rather than just declaring it as */
	/* a regular local variable because I need to make sure that all of the */
	/* fields are initialized to zero. */
	/* Also, the quit_cleanup routine needs to be able to access it to purge */
	/* the directory buffers which I have chosen to use (by setting the */
	/* FRQCACHINM flag. */
	/* I could have used the same structure I used for the file requester, */
	/* but I decided not to, so that the two requesters could have separate */
	/* directory caches. */

struct FileReq	MyFontReqStruct;

void ShowFontRequester(void)
	{
	char	fontname[REQ_FCHARS];
	char	dirname[REQ_DSIZE];

		/* You do have to tell the font requester what directory to look */
		/* in, usually fonts:. */

	strcpy(dirname, "fonts:");
	fontname[0] = 0;

		/* Tell the file requester to be a font requester. */
		/* The directory caching of this file requester is one of its nice */
		/* features, so I decided to show it off.  It is completely optional */
		/* though, so if you don't want it, don't set the caching flag.  If you do */
		/* want it, don't forget to call PurgeFiles() when you are done. */
	MyFontReqStruct.Flags |= FRQGETFONTSM | FRQCACHINGM;

	MyFontReqStruct.Dir = dirname;
	MyFontReqStruct.File = fontname;
		/* Initialize a colour field.  Not strictly necessary, but */
		/* personally, I like having my fonts a different colour */
		/* from the font size list. */
	MyFontReqStruct.fontnamescolor = 2;
	if (FileRequester(&MyFontReqStruct))
		SimpleRequest("System Request","You selected the font '%s',\n"
					  "size %ld, style %ld.", fontname, (long)MyFontReqStruct.FontYSize, (long)MyFontReqStruct.FontStyle);
	else
		SimpleRequest("System Request","You didn't select a font.");
	}



#define	TEXTLENGTH	75

void ShowGetText(void)
	{
	char	mybuffer[TEXTLENGTH];

		/* Note that the buffer you pass to GetString must be initialized.  */
		/* If you don't want any text to appear by default, just put a zero */
		/* at the beginning of the array. */

	strcpy(mybuffer, "The default text.");
	if (GetString(mybuffer, "Type anything, then hit return.", (struct Window *)0L, 50L, (long)TEXTLENGTH))
		SimpleRequest("System Request","I'll bet you typed:\n"
					  "'%s'.", mybuffer);
	else
		SimpleRequest("System Request","You didn't enter anything!");
	}



void ShowGetLong(void)
	{
	struct GetLongStruct	mygetlongstruct;

	mygetlongstruct.titlebar = "Enter a number.";
	mygetlongstruct.defaultval = 1234;
	mygetlongstruct.minlimit = -100000;
	mygetlongstruct.maxlimit = 100000;
	mygetlongstruct.window = 0;			/* Must be zeroed or req.lib will use it as a window pointer. */
	mygetlongstruct.versionnumber = 0;
	mygetlongstruct.flags = 0;
	mygetlongstruct.rfu2 = 0;
	if (GetLong(&mygetlongstruct))
		SimpleRequest("System Request","You entered the number '%ld'.", mygetlongstruct.result);
	else
		SimpleRequest("System Request","You didn't enter a number.");
	}



void quit_cleanup(char *message)
	{
	if (window)
		CloseWindow(window);
	if (screen)
		CloseScreen(screen);
	if (ReqBase)
		{
		PurgeFiles(&MyFileReqStruct);	/* Only necessary if the FRQCACHINGM flag */
		PurgeFiles(&MyFontReqStruct);	/* is set in the file requester structure. */
		CloseLibrary((void *)ReqBase);
		}
	if (GfxBase)
		CloseLibrary(GfxBase);
	if (IntuitionBase)
		CloseLibrary(IntuitionBase);
	if (message)
		puts(message);
	exit(0);
	}



void _abort(void)
	{
	quit_cleanup("User abort requested.");
	}



void bye(void)
	{
	myprocess->pr_WindowPtr = olderrorwindow;
	quit_cleanup((char *)0);
	}



struct gadgetandfunction
	{
	char	*gadgettext;
	void	(*functionpointer)(void);
	};

struct gadgetandfunction gadgetlist[] =
	{
		{
		"Show the file requester.",
		ShowFileRequester,
		},
		{
		"Show the color requester.",
		ShowColorRequester,
		},
		{
		"Show a simple text requester.",
		ShowSimpleText,
		},
		{
		"Show a two gadget requester.",
		ShowTwoGadText,
		},
		{
		"Show a three gadget requester.",
		ShowThreeGadText,
		},
		{
		"Show the font requester.",
		ShowFontRequester,
		},
		{
		"Show the 'get text' requester.",
		ShowGetText,
		},
		{
		"Show the 'get number' requester.",
		ShowGetLong,
		},

		{
		"Exit the demo.",
		bye,
		},
	};

#define	NUMGADGETS	(sizeof(gadgetlist) / sizeof(struct gadgetandfunction))

struct GadgetBlock	gadgetblocks[NUMGADGETS];

void main(void)
	{
	short	x, y, gadgetnum;
	struct IntuiMessage	messagecopy, *message;
	struct Gadget		*gadgetpointer;

		/* First we do the usual opening up of libraries, pretty standard stuff. */

	if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 33L)))
		quit_cleanup("Requires 1.2 operating system.");

	if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 33L)))
		quit_cleanup("Couldn't open graphics.");

	if (!(ReqBase = (struct ReqLib *)OpenLibrary("req.library", 0L)))
		quit_cleanup("Couldn't open the req library.");

		/* Then we open up a nice 640 by 200, three bitplane screen.  This demo */
		/* can be easily modified to work on the workbench screen.  Simply */
		/* take out the open screen command, and change the NewWindow Type field */
		/* to WBENCHSCREEN.  All of the requesters will then open on the */
		/* workbench screen. */

	if (!(screen = (struct Screen *)OpenScreen(&ns)))
		quit_cleanup("Couldn't open screen.");

	for (gadgetnum = 0; gadgetnum < NUMGADGETS; gadgetnum++)
		{
		x = GADGETSTARTX + (gadgetnum & 1) * (WIDTH / 2);
		y = GADGETSTARTY + (gadgetnum / 2) * 20;
		LinkGadget(&gadgetblocks[gadgetnum], gadgetlist[gadgetnum].gadgettext, &nw, (long)x, (long)y);
		gadgetblocks[gadgetnum].Gadget.GadgetID = gadgetnum;
		}

		/* Find the address of the last gadget added, the 'goodbye' gadget */
		/* and adjust it so that it appears in the middle at the top. */
	gadgetpointer = &gadgetblocks[NUMGADGETS-1].Gadget;
	gadgetpointer->TopEdge = 20;
	gadgetpointer->LeftEdge = (WIDTH - gadgetpointer->Width) / 2;

	nw.Screen = screen;
	if (!(window = (struct Window *)OpenWindow(&nw)))
		quit_cleanup("Couldn't open window.");

		/* Now we set the pr_WindowPtr field in our process structure to */
		/* point at our window so that DOS requesters and requester library */
		/* requestes will open up on our custom screen, instead of on the */
		/* workbench screen. NOTE!!!!!  It is VERY important that you restore */
		/* this variable before the program exits.  This is why I make a copy */
		/* of the previous value before I change it.  IF YOU DON'T RESTORE IT */
		/* when you exit, NASTY THINGS WILL HAPPEN!! (but only sometimes).  */
		/* If you execute a program WITHOUT using the 'run' command and it */
		/* sets the pr_WindowPtr to point at it's window, and then exits */
		/* without restoring it, the next DOS requester for that process will */
		/* try to come up on a screen that NO LONGER EXISTS - which will probably */
		/* BLOW UP YOUR MACHINE!  The pr_WindowPtr is restored in the bye() */
		/* routine. */

	myprocess = (struct Process *)FindTask((char *)0);
	olderrorwindow = myprocess->pr_WindowPtr;
	myprocess->pr_WindowPtr = (APTR)window;

		/* Now we enter our main processing loop.  All we do is wait for */
		/* GADGETUP messages (the only kind the IDCMP port is set to */
		/* receive) and call the function associated with each gadget */
		/* that the user presses.  One of those gadgets is an exit */
		/* gadget which calls the 'bye' routine, which frees up all */
		/* resources and exits.  This is how this loop, which seems to */
		/* never terminate, terminates. */

	while (TRUE)
		{
		WaitPort(window->UserPort);
		message = (struct IntuiMessage *)GetMsg(window->UserPort);
		messagecopy = *message;
		ReplyMsg((struct Message *)message);
		gadgetnum = ((struct Gadget *)(messagecopy.IAddress))->GadgetID;

		gadgetlist[gadgetnum].functionpointer();
		}
	}

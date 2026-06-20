
#ifndef AMIPHONEMSG
#define AMIPHONEMSG

#include <exec/ports.h>

/* This header is to be included in both AmiPhone and AmiPhoned,
   as this is the packet I'll use to communicate between them. */
   
struct AmiPhoneInfo {
	struct Message PhoneMsg;/* Header */
	UBYTE ubCurrComp;	/* sample width we're receiving at */
	UBYTE ubControl;	/* Control byte--not currently used */
	ULONG ulLastPacketSize;	/* size of last packet-note these are not TCP packets! */
	BOOL  BErrorR;		/* Have we had any receive trouble? */
	int   nPri;		/* AmiPhone can tell us to change priority here */
	struct Task * daemonTask;  /* Pointer to us */
	BOOL  BWantWindowOpen;  /* Used by AmiPhone to trigger AmiPhoned's window open/close */
	BOOL  BWindowIsOpen;	/* Used by AmiPhoned to show current status */
};

#define AMIPHONE_PORT_NAME "AmiPhone_Rend"
#define RECEIVE_BUFFER_SIZE 3000

#define MSG_CONTROL_INVALID	0x00	/* should never be used */
#define MSG_CONTROL_HI		0x01	/* "I'm here!" */
#define MSG_CONTROL_BYE		0x02	/* "I'm leaving!" */

/* Below is the message structure used by AmiPhone to communicate with
   its graphics subtask.  */

#define MSG_CONTROL_DOGRAPH	0x04	/* "Draw the bandwidth meter, etc." */
#define MSG_CONTROL_DOANIM	0x08	/* "Draw the microphone icon" */

#define MSG_CONTROL_IMLEAVING	0x10	/* another "I'm leaving!" */

#define MSG_CONTROL_RELEASE     0x20	/* let go of the parallel port! */

#define MSG_CONTROL_UPDATE	0x40    /* "Check the shared data!" */
#define MSG_CONTROL_DOTITLE     0x80    /* "Update the title bar" */

#define GRAPHICSTASKNAME  "AmiPhone Graphics Daemon"
#define GRAPHICSPORTNAME  "AmiPhone Graphics Port"

struct AmiPhoneGraphicsInfo {
	struct Message GraphMessage;	/* header */
	UBYTE ubCommand;		/* What to do */
	int   nImageTop;		/* tell which frame of the Mic anim to draw */
	UBYTE ubCurrLocalComp;		/* Current local compression mode */
	UBYTE ubCurrRemoteComp;		/* Current remote compression mode */
	int   nBarHeightS;		/* Height of the send graph bar */
	BOOL  BErrorS;			/* Have we had any send errors? */
	int   nBarHeightR;		/* Height of the receive graph bar */
	BOOL  BErrorR;			/* Have we had any receive errors? */
};

#endif
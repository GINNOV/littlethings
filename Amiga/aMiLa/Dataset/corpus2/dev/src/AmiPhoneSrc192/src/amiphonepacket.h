#ifndef AMIPHONEPACKET_H
#define AMIPHONEPACKET_H

/* Current Version number for both AmiPhone and AmiPhoned */
/* Make sure ALL THREE of these #define lines are in-sync! */
#define VERSION_NUMBER 		192
#ifdef DEBUG_FLAG
#define VERSION_STRING 	"$VER: 1.92D"
#else
#define VERSION_STRING 	"$VER: 1.92"
#endif

/* common macros */
#define UNLESS(x) if(!(x))
#define UNTIL(x)  while(!(x))
#define EXIT(m,n) {SetExitMessage(m,n);exit(n);}

/* message structures that will be passed as packets from AmiPhone to AmiPhoned */
#define MIN_SAMPLE_RATE           1600
#define DEFAULT_MAX_SAMPLE_RATE   9999
#define ABSOLUTE_MAX_SAMPLE_RATE 32767
#define MIN_PACKET_SIZE  	   100
#define MAX_PACKET_SIZE 	  8950
#define MAX_PACKET_INTERVAL      (0.7)
#define MIN_PACKET_INTERVAL     (0.09)

/* this is the largest an AmiPhone data packet will be */
#define MAXTRANSBUFSIZE		9000

#define PHONECOMMAND_CONNECT	'C'
	#define PCCONNECT_CONVERSE	'T'
	#define PCCONNECT_RELAY		'E'
	
#define PHONECOMMAND_DISCONNECT	'H'
#define PHONECOMMAND_DATA	'D'

#define PHONECOMMAND_DENY	'X'

#define PHONECOMMAND_FLUSH	'F'
#define PHONECOMMAND_VWARN      'V'	/* Causes Requester on receiver's end */

#define PHONECOMMAND_REPLY	'R'
	#define PCREPLY_WILLLISTEN	 'L'	/* subTypes for ..._REPLY */
	#define PCREPLY_TWOWAY           '2'	/* 			  */
	#define PCREPLY_LEAVEMESSAGE     'M'	/*			  */
	#define PCREPLY_CANTLEAVEMESSAGE 'Z'    /*                        */
	
#define COMPRESS_INVALID	0
#define COMPRESS_NONE		1
#define COMPRESS_ADPCM2		2
#define COMPRESS_ADPCM3		3
#define COMPRESS_MAX		4

struct AmiPhonePacketHeader {
	UBYTE	ubCommand;		/* controls what to do! */
	UBYTE	ubType;			/* basically a subfield of ubCommand */
	LONG	lSeqNum;		/* Sequencing number */
	ULONG 	ulBPS;			/* Sample speed, or misc data if not a sample */
	ULONG 	ulDataLen;		/* number of bytes of data after this */
	ULONG   ulJoinCode;		/* Used for reliable decompression of ADPCM */
};


struct AmiPhoneSendBuffer {
	struct AmiPhonePacketHeader header;
	UBYTE			    ubData[(MAXTRANSBUFSIZE- sizeof(struct AmiPhonePacketHeader))];
};

#endif
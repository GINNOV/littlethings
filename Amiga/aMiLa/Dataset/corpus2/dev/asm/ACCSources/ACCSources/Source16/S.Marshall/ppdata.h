/*******************************************
*  PowerPacker DATA file support function  *
*                                          *
*    include file                (Aug '89) *
*******************************************/

/* decrunch colors */
#define DECR_COL0			(UBYTE)0
#define DECR_COL1			(UBYTE)1
#define DECR_POINTER		(UBYTE)2
#define DECR_SCROLL		(UBYTE)3
#define DECR_NONE			(UBYTE)4

/* error codes */
#define PP_LOADOK			0
#define PP_LOCKERR		1000
#define PP_OPENERR		1001
#define PP_READERR		1002
#define PP_NOMEMORY		1003
#define PP_CRYPTED		1004
#define PP_PASSERR		1005

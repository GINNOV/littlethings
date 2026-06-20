/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: LibBase.h
**		$DESCRIPTION: Header file for LibBase
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef LIBBASE_H
#define LIBBASE_H

struct RXCFBase
{
	struct Library				 LibNode;

	BPTR							 Segment;
};

#define RXERR_NO_MEMORY			ERR10_003
#define RXERR_INVALID_MSGPKT	ERR10_010
#define RXERR_FUNC_NOT_FOUND	ERR10_015
#define RXERR_WRONG_NUM_ARGS	ERR10_017
#define RXERR_INVALID_ARG		ERR10_018

/* Field definitions */

#define RXARG(Num)	(RxMsg->rm_Args[Num])

#define RXARG0	(RxMsg->rm_Args[0])
#define RXARG1	(RxMsg->rm_Args[1])
#define RXARG2	(RxMsg->rm_Args[2])
#define RXARG3	(RxMsg->rm_Args[3])
#define RXARG4	(RxMsg->rm_Args[4])
#define RXARG5	(RxMsg->rm_Args[5])

#define RX_PFUNC_ARGS	struct RexxMsg * RxMsg, UBYTE ** ResStr, VOID *
#define RX_FUNC_ARGS		struct RexxMsg * RxMsg, UBYTE ** ResStr

/* ARexx support functions */

RegCall LONG GetRxVar ( REGA0 struct Message *, REGA1 UBYTE *, REGA2 UBYTE ** );
RegCall LONG SetRxVar ( REGA0 struct Message *, REGA1 UBYTE *, REGD0 UBYTE *, REGD1 ULONG );

#endif /* LIBBASE_H */

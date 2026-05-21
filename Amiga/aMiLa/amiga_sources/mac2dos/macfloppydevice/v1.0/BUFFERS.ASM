*********************************************************
*	Copyright (c) 1987 Central Coast Software	*
*	    268 Bowie Dr, Los Osos, CA 93402		*
*	     All rights reserved, worldwide		*
*********************************************************

	INCLUDE	"MAC.I"

	XDEF	VolBuf,BitMapBuf
;	XDEF	MacBuffer
;	XDEF	DosBuffer	
	XDEF	LINBUF

	CNOP 0,2

LINBUF
VolBuf		DS.B	VolBufSize/2	;Volume BUFFER
BitMapBuf	DS.B	VolBufSize/2
;MacBuffer	DS.B	MacBufSize	;Mac block BUFFER
;DosBuffer	DS.B	DosBufSize	;AMIGA block BUFFER

	END

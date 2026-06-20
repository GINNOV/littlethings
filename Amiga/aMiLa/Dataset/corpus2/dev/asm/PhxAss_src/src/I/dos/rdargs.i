 ifnd DOS_RDARGS_I
DOS_RDARGSS_I set 1
*
*  dos/rdargs.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1995
*

	IFND EXEC_NODES_I
	INCLUDE "exec/nodes.i"
	ENDC


; CSource
		rsreset
CS_Buffer	rs.l	1
CS_Length	rs.l	1
CS_CurChr	rs.l	1
CS_SIZEOF	rs


; RDArgs
		rsreset
RDA_Source	rs.b	CS_SIZEOF
RDA_DAList	rs.l	1
RDA_Buffer	rs.l	1
RDA_BufSiz	rs.l	1
RDA_ExtHelp	rs.l	1
RDA_Flags	rs.l	1
RDA_SIZEOF	rs

	BITDEF	RDA,STDIN,0
	BITDEF	RDA,NOALLOC,1
	BITDEF	RDA,NOPROMPT,2

MAX_TEMPLATE_ITEMS	equ	100
MAX_MULTIARGS	equ	128

 endc

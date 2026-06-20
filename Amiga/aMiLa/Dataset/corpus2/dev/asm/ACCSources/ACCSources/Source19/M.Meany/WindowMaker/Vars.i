
; Data defenitions for Makewindow utility.

		rsreset

edit.ptr	rs.l		1		window pointer
edit.rp		rs.l		1		RastPort pointer
edit.up		rs.l		1		UserPort pointer

user.ptr	rs.l		1
user.rp		rs.l		1

editwin.ptr	rs.l		1
editwin.up	rs.l		1
editwin.rp	rs.l		1

OutHandle	rs.l		1		space for save handle
InHandle	rs.l		1		space for load handle
header		rs.l		1		space for file header

CancelFlag	rs.l		1

ErrorNum	rs.l		1		space for error code
Winidcmp	rs.l		1		space for IDCMP value
WinLab		rs.l		1		space for ptr to window label
WinStruct	rs.b		nw_SIZE		space for a new window
LabelPtr	rs.l		1		space for ptr to title label
WinTitle	rs.b		82		space for title

LoadFileStruct	rs.b	fr_SIZEOF+4	space for load filerequest struct

SaveFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct

SaveSFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct

LoadFileData	rs.b	FCHARS+2	;reserve space for filename buffer

LoadDirData	rs.b	DSIZE+1		;reserve space for path buffer

SaveFileData	rs.b	FCHARS+2	;reserve space for filename buffer

SaveDirData	rs.b	DSIZE+1		;reserve space for path buffer

SaveSFileData	rs.b	FCHARS+2	;reserve space for filename buffer

SaveSDirData	rs.b	DSIZE+1		;reserve space for path buffer

LoadPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

SavePathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

SaveSPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

RDFBuffer	rs.b		1000		RawDoFmt buffer

VarsSize	rs.w		0		Size of mem block




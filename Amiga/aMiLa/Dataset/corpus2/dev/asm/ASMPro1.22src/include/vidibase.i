	IFND	VIDI_VIDIBASE_I
VIDI_VIDIBASE_I	SET	1

*****************************************************************************
*
*  ROMBO Productions -- Vidi-Amiga library assembly include file
*
*****************************************************************************
*
*  Details:
*
*	Vidi-Amiga:Vidi/Include/vidibase.i
*	version 1.15, as of Thursday 18th January 1990
*	by Keith Wilson, Rombo
*
*****************************************************************************

	IFND	EXEC_TYPES_I
	INCLUDE	"exec/types.i"		; for UBYTE, ULONG etc.
	ENDC

	IFND	DEVICES_PARALLEL_I
	INCLUDE	"devices/parallel.i"	; for IOEXTPar_SIZE
	ENDC

	IFND	EXEC_LIBRARIES_I
	INCLUDE	"exec/libraries.i"	; for LIB_SIZE
	ENDC



	STRUCTURE VidiBase,LIB_SIZE
	UBYTE	vb_Flags		; for internal library use
	UBYTE	vb_Reserved		; may be used in future
	APTR	vb_SegList		; system use
	APTR	vb_Pad1			; for backwards compatibility
	APTR	vb_DosBase		; dos.library base
	APTR	vb_GfxBase		; graphics.library base
	APTR	vb_IntBase		; intuition.library base
					; (you may steal these to save
					; 	opening them yourself)
	UWORD	vb_VidiFlags		; VIDI_USED/SYNC_FREE/LACED
	STRUCT	vb_Spare,IOEXTPar_SIZE	; used as general workspace
	LABEL	VidiBase_SIZEOF


VIDI_NO_SYNC		EQU	-1	; error codes
VIDI_NO_MEMORY		EQU	-2
VIDI_BUSY		EQU	-3
VIDI_PAR_BUSY		EQU	-4
VIDI_WIDTH		EQU	-5
VIDI_TOO_DEEP		EQU	-6


IFF_READ		EQU	0	; used in mysterious ways
IFF_WRITE		EQU	-1


SYNC_ODD_B		EQU	0	; sync types
SYNC_EVEN_B		EQU	1
SYNC_FREE		EQU	0
SYNC_ODD		EQU	1<<SYNC_ODD_B
SYNC_EVEN		EQU	1<<SYNC_EVEN_B
SYNC_LACED		EQU	SYNC_ODD+SYNC_EVEN
SYNC_MASK		EQU	SYNC_LACED


READ_WINDOW_B		EQU	2	; other flags
OUTSIDE_WINDOW_B	EQU	3
ANY_BITMAP_B		EQU	4
LOW_FIRST_B		EQU	5
MERGE_CALL_B		EQU	6
MERGE_BETTER_B		EQU	7
VIDI_PAL_B		EQU	13
VIDI_BUS_B		EQU	14
VIDI_USED_B		EQU	15

READ_WINDOW		EQU	1<<READ_WINDOW_B
OUTSIDE_WINDOW		EQU	1<<OUTSIDE_WINDOW_B
ANY_BITMAP		EQU	1<<ANY_BITMAP_B
LOW_FIRST		EQU	1<<LOW_FIRST_B
MERGE_CALL		EQU	1<<MERGE_CALL_B
MERGE_BETTER		EQU	1<<MERGE_BETTER_B
VIDI_PAL		EQU	1<<VIDI_PAL_B
VIDI_BUS		EQU	1<<VIDI_BUS_B
VIDI_USED		EQU	1<<VIDI_USED_B


	ENDC


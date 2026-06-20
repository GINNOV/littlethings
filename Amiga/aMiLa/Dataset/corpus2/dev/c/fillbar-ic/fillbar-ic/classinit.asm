
;---------------------------------------------------------------------------

        NOLIST

        INCLUDE "exec/types.i"
        INCLUDE "exec/libraries.i"
        INCLUDE "exec/lists.i"
        INCLUDE "exec/alerts.i"
        INCLUDE "exec/initializers.i"
        INCLUDE "exec/resident.i"
        INCLUDE "libraries/dos.i"
        INCLUDE "utility/hooks.i"

        INCLUDE "fillbar_rev.i"
        INCLUDE "classbase.i"

        LIST

;---------------------------------------------------------------------------

	XREF	_CreateClass
	XREF	_DestroyClass

	XREF	_LVOSMult32
	XREF    _LVOUMult32
	XREF	_LVOSDivMod32
	XREF	_LVOUDivMod32

        XREF    ENDCODE

;---------------------------------------------------------------------------

	SECTION CODE

        XDEF    LibInit
        XDEF    LibOpen
        XDEF    LibClose
        XDEF    LibExpunge
        XDEF	LibReserved
        XDEF	@CallCHook
;		XDEF	_CallCHook

;---------------------------------------------------------------------------

; First executable location, must return an error to the caller
Start:
        moveq   #-1,d0
        rts

;-----------------------------------------------------------------------

ROMTAG:
        DC.W    RTC_MATCHWORD           ; UWORD RT_MATCHWORD
        DC.L    ROMTAG                  ; APTR  RT_MATCHTAG
        DC.L    ENDCODE                 ; APTR  RT_ENDSKIP
        DC.B    RTF_AUTOINIT            ; UBYTE RT_FLAGS
        DC.B    VERSION                 ; UBYTE RT_VERSION
        DC.B    NT_LIBRARY              ; UBYTE RT_TYPE
        DC.B    0                       ; BYTE  RT_PRI
        DC.L    LibName                 ; APTR  RT_NAME
        DC.L    LibId                   ; APTR  RT_IDSTRING
        DC.L    LibInitTable            ; APTR  RT_INIT

LibName DC.B 'fillbar.image',0
LibId   VSTRING

        CNOP    0,4

LibInitTable:
        DC.L    ClassLib_SIZEOF
        DC.L    LibFuncTable
        DC.L    0
        DC.L    LibInit

V_DEF	MACRO
	DC.W	\1+(*-LibFuncTable)
	ENDM

LibFuncTable:
	DC.W	-1
        V_DEF	LibOpen
        V_DEF	LibClose
        V_DEF	LibExpunge
        V_DEF	LibReserved
        DC.W   -1

;-----------------------------------------------------------------------

; Library Init entry point called when library is first loaded in memory
; On entry, D0 points to library base, A0 has lib seglist, A6 has SysBase
; Returns 0 for failure or the library base for success.
LibInit:
        movem.l a0/a5/d7,-(sp)
        move.l  d0,a5
        move.l  a6,cb_SysBase(a5)
        move.l  a0,cb_SegList(a5)

        move.w	#REVISION,LIB_REVISION(a5)

        move.l  #AO_GraphicsLib,d7
        lea     GfxName(pc),a1
        bsr.s	OpenLib
        move.l  d0,cb_GfxBase(a5)

        move.l  #AO_Intuition,d7
        lea     IntuitionName(pc),a1
        bsr.s	OpenLib
        move.l  d0,cb_IntuitionBase(a5)

        move.l  #AO_UtilityLib,d7
        lea     UtilityName(pc),a1
        bsr.s	OpenLib
        move.l  d0,cb_UtilityBase(a5)

        move.l  a5,d0
        movem.l (sp)+,a0/a5/d7
        rts

OpenLib:
        moveq   #LIBVERSION,d0
        CALL    OpenLibrary
        move.l	(sp)+,a0	; pop return address
        tst.l   d0		; did lib open?
        beq.s   FailInit	; nope, so exit
        jmp	(a0)		; yes, so return

FailInit:
        bsr     CloseLibs
        or.l    #AG_OpenLib,d7
        CALL	Alert
        movem.l (sp)+,a0/a5/d7
        moveq   #0,d0
        rts

LIBVERSION    EQU  37
GfxName       DC.B "graphics.library",0
IntuitionName DC.B "intuition.library",0
UtilityName   DC.B "utility.library",0

        CNOP    0,2

;-----------------------------------------------------------------------

; Library open entry point called every OpenLibrary()
; On entry, A6 has ClassBase, task switching is disabled
; Returns 0 for failure, or ClassBase for success.
LibOpen:
	tst.w	LIB_OPENCNT(a6)
	bne.s	1$

	bsr	_CreateClass
	tst.w	d0
	bne.s	1$

	moveq	#0,d0
	rts

1$:
        addq.w  #1,LIB_OPENCNT(a6)
        bclr    #LIBB_DELEXP,LIB_FLAGS(a6)
        move.l  a6,d0
        rts

;-----------------------------------------------------------------------

; Library close entry point called every CloseLibrary()
; On entry, A6 has ClassBase, task switching is disabled
; Returns 0 normally, or the library seglist when lib should be expunged
;   due to delayed expunge bit being set
LibClose:
	subq.w	#1,LIB_OPENCNT(a6)
	bne.s	1$			; if openers, don't remove class

	bsr	_DestroyClass		; zero openers, so try to remove class

1$:
	; if delayed expunge bit set, then try to get rid of the library
	btst	#LIBB_DELEXP,LIB_FLAGS(a6)
	bne.s	CloseExpunge

	; delayed expunge not set, so stick around
	moveq	#0,d0
	rts

CloseExpunge:
	; if no library users, then just remove the library
	tst.w	LIB_OPENCNT(a6)
	beq.s	DoExpunge

	; still some library users, so forget about flushing
	bclr	#LIBB_DELEXP,LIB_FLAGS(a6)
	moveq	#0,d0
	rts

;-----------------------------------------------------------------------

; Library expunge entry point called whenever system memory is lacking
; On entry, A6 has ClassBase, task switching is disabled
; Returns the library seglist if the library open count is 0, returns 0
; otherwise and sets the delayed expunge bit.
LibExpunge:
        tst.w   LIB_OPENCNT(a6)
        beq.s   DoExpunge

        tst.l   cl_Class(a6)
        beq.s   DoExpunge

        bset    #LIBB_DELEXP,LIB_FLAGS(a6)
        moveq   #0,d0
        rts

DoExpunge:
        movem.l d2/a5/a6,-(sp)
        move.l  a6,a5
        move.l  cb_SegList(a5),d2

        move.l  a5,a1
        REMOVE

        move.l  cb_SysBase(a5),a6
        bsr.s   CloseLibs

        move.l  a5,a1
        moveq   #0,d0
        move.w  LIB_NEGSIZE(a5),d0
        sub.l   d0,a1
        add.w   LIB_POSSIZE(a5),d0
        CALL    FreeMem

        move.l  d2,d0
        movem.l (sp)+,d2/a5/a6
        rts

;-----------------------------------------------------------------------

LibReserved:
        moveq   #0,d0
        rts

;-----------------------------------------------------------------------

CloseLibs:
        move.l  cb_GfxBase(a5),a1
        CALL    CloseLibrary

        move.l  cb_IntuitionBase(a5),a1
        CALL    CloseLibrary

        move.l  cb_UtilityBase(a5),a1
        GO	CloseLibrary

;-----------------------------------------------------------------------


; Restores context and calls high-level language hook
@CallCHook:
;_CallCHook:
	movem.l	a5/a6,-(sp)
	movem.l	h_SubEntry(a0),a5/a6	; h_SubEntry into A5, h_Data into A6
	jsr	(a5)			; call HLL
	movem.l	(sp)+,a5/a6
	rts

;-----------------------------------------------------------------------

        END

;╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗
;╗╗╗╗╗
;╗╗╗╗╗  $VER: xyz.library 1.0 (22.4.95)
;╗╗╗╗╗
;╗╗╗╗╗  Framework by Dennis Jacobfeuerborn.
;╗╗╗╗╗
;╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗

		OPT     O+
		SECTION xyz,CODE

LIBNAME         MACRO
		Dc.b    "xyz.library",0
		ENDM
LIBVERSION      MACRO
		Dc.b    "$VER: xyz.library 1.0 (day.month.year)",0
		ENDM

VERSION         =       1
REVISION        =       0

;Begin ╗╗╗╗╗ INCLUDES лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		IncDir  ASMInclude:
		Include My/Macros.I

		Include Exec/Execbase.i
		Include Exec/Exec.i
		Include Exec/Types.i
		Include Exec/Initializers.i
		Include Exec/Libraries.i
		Include Exec/Lists.i
;End
;Begin ╗╗╗╗╗ STRUCTURES лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
		INITVARS        OOPSBase,LIB_SIZE
			BVAR    Flags
			BVAR    Pad0
			LVAR    SysBase
			LVAR    SegList
		ENDVARS         OOPSBase

		INITVARS        GlobalVars,0
			LVAR    ReturnCode
		ENDVARS         GlobalVars
;End

;Begin ╗╗╗╗╗ Dummy Startup-code лллллллллллллллллллллллллллллллллллллллллллллллллллл
		Moveq   #-1,d0                  ; Don't even try to run me !!!
		Rts
;End
;Begin ╗╗╗╗╗ ROMTag Structure лллллллллллллллллллллллллллллллллллллллллллллллллллллл
ROMTag          Dc.w    RTC_MATCHWORD   ;uword  rt_matchword
		Dc.l    ROMTag          ;aptr   rt_matchtag
		Dc.l    EndOfLib        ;aptr   rt_endskip
		Dc.b    RTF_AUTOINIT    ;ubyte  rt_flags
		Dc.b    VERSION         ;ubyte  rt_version
		Dc.b    NT_LIBRARY      ;ubyte  rt_type
		Dc.b    0               ;ubyte  rt_pri
		Dc.l    LibraryName     ;aptr   rt_name
		Dc.l    LibraryID       ;aptr   rt_idstring
		Dc.l    InitTable       ;aptr   rt_init
;End
;Begin ╗╗╗╗╗ Library Names & ID лллллллллллллллллллллллллллллллллллллллллллллллллллл
LibraryName     LIBNAME
LibraryID       LIBVERSION
		Even
;End
;Begin ╗╗╗╗╗ Library Initialisation Table лллллллллллллллллллллллллллллллллллллллллл
InitTable       Dc.l    OOPSBase_SIZE           ;structure size (library base)
		Dc.l    FunctionTable           ;function list
		Dc.l    LibBaseData             ;information for initializing
		Dc.l    InitRoutine             ;own routine for initialization
;End
;Begin ╗╗╗╗╗ Library Function Table лллллллллллллллллллллллллллллллллллллллллллллллл
FunctionTable   Dc.l    Open                    ; The basic lib functions
		Dc.l    Close
		Dc.l    Expunge
		Dc.l    Null

		Dc.l    Place your functions here !
		Dc.l    -1
;End
;Begin ╗╗╗╗╗ LibBaseData ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
LibBaseData     INITBYTE        LN_TYPE,NT_LIBRARY
		INITLONG        LN_NAME,LibraryName
		INITBYTE        LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
		INITWORD        LIB_VERSION,VERSION
		INITWORD        LIB_REVISION,REVISION
		INITLONG        LIB_IDSTRING,LibraryID
		Dc.l            0       ;end!
;End

;Begin ╗╗╗╗╗ InitRoutine ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
InitRoutine     Movem.l d2-d7/a2-a6,-(sp)
		Move.l  d0,a5

		VPUT.l  a6,SysBase
		VPUT.l  a0,SegList

		Move.l  a5,d0
		Movem.l (sp)+,d2-d7/a2-a6
		Rts

.Free           Moveq   #0,d0
		Move.l  a5,a1
		Move.w  LIB_NEGSIZE(a5),d0
		Sub.l   d0,a1
		Add.w   LIB_POSSIZE(a5),d0
		CALL    FreeMem
		Movem.l (sp)+,d2-d7/a2-a6
		Moveq   #0,d0
		Rts
;End
;Begin ╗╗╗╗╗ Open лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Open            Addq.w  #1,LIB_OPENCNT(a6)
		BClr    #LIBB_DELEXP,var_Flags(a6)
		Move.l  a6,d0
		Rts
;End
;Begin ╗╗╗╗╗ Close ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Close           Subq.w  #1,LIB_OPENCNT(a6)
		Bne.s   Close_NotLast

		BTst    #LIBB_DELEXP,var_Flags(a6)
		Beq.s   Close_NoDelayedExpunge

		Bsr.s   Expunge
Close_NoDelayedExpunge
Close_NotLast   Moveq   #0,d0
		Rts
;End
;Begin ╗╗╗╗╗ Expunge ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Expunge         Move.l  a5,-(sp)
		Move.l  a6,a5
		VGET.l  SysBase,a6

		Tst.w   LIB_OPENCNT(a5)
		Beq.s   Expunge_Ok

		BSet    #LIBB_DELEXP,var_Flags(a5)
		Move.l  a5,a6
		Move.l  (sp)+,a5
		Moveq   #0,d0
		Rts

Expunge_Ok      Move.l  d2,-(sp)

		VGET.l  SegList,d2

		Move.l  a5,a1
		CALL    Remove

		Moveq   #0,d0
		Move.l  a5,a1
		Move.w  LIB_NEGSIZE(a5),d0
		Sub.l   d0,a1
		Add.w   LIB_POSSIZE(a5),d0
		CALL    FreeMem
		Move.l  d2,d0

		Move.l  (sp)+,d2
		Move.l  a5,a6
		Move.l  (sp)+,a5
		Rts
;End
;Begin ╗╗╗╗╗ Null лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Null            Moveq   #0,d0
		Rts
;End
	;*** your routines starting from -30 ...

EndOfLib
	END

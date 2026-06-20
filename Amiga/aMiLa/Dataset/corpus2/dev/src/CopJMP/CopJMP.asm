;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»
;»»»»»  $VER: CopperJMP.asm 1.0 (15.9.95)
;»»»»»
;»»»»»  Programmed by Dennis Jacobfeuerborn.
;»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

      OPT     O+,D+
      SECTION CopperJMP,CODE

;Begin »»»»» INCLUDES «««««««««««««««««««««««««««««««««««««««««««««««««««««««««
		Include My/Macros.I
		Include Exec/Memory.I
		Include Graphics/GfxBase.I
;End
;Begin »»»»» STRUCTURES «««««««««««««««««««««««««««««««««««««««««««««««««««««««
		INITVARS        CopperJMPBase,0
			LVAR    GfxBase
			LVAR    OldCopper
			WVAR    Intena
			WVAR    Dmacon
		ENDVARS         CopperJMPBase

; STACKFRAMES -----------------------------------------------------------------

		INITVARS        global,0
			LVAR    ReturnCode
		ENDVARS         global
;End

;Begin »»»»» Main() () ««««««««««««««««««««««««««««««««««««««««««««««««««««««««
Main            Movem.l d1-d7/a0-a6,-(sp)
		Lea     VarTable(pc),a5
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Bsr     Init
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
.wm             Btst    #6,$bfe001
		Bne.s   .wm
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
.Exit           Bsr     Exit
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Movem.l (sp)+,d1-d7/a0-a6
		Moveq   #0,d0
		Rts
;End

;Begin »»»»» Init()
Init            Movem.l d1-d7/a0-a6,-(sp)
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Lea     GfxName(pc),a1
		Moveq   #32,d0
		CALL    Exec,OpenLibrary
		VPUT.l  d0,GfxBase
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		VPUT.w  $dff01c,Intena
		Move.w  #$7fff,$dff09a
		VPUT.w  $dff002,Dmacon
		Move.w  #$7fff,$dff096
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		VGET.l  GfxBase,a6
		VPUT.l  gb_copinit(a6),OldCopper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Lea     CopJMP,a0
		Move.l  #CopperList2,d0
		Move.w  d0,2(a0)
		Swap    d0
		Move.w  d0,6(a0)
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Move.l  #CopperList1,$dff080
		Move.w  #0,$dff088
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Move.w  #$83f0,$dff096
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
.Exit           Movem.l (sp)+,d1-d7/a0-a6
		Rts
;End
;Begin »»»»» Exit() ()
Exit            Movem.l d0-d7/a0-a6,-(sp)
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Move.w  #$7fff,$dff096
		VGET.w  Dmacon,d0
		Or.w    #$8000,d0
		Move.w  d0,$dff096
		Move.w  #$7fff,$dff09a
		Move.w  #$7fff,$dff09c
		VGET.w  Intena,d0
		Or.w    #$8000,d0
		Move.w  d0,$dff09a
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		VGET.l  OldCopper,$dff080
		Move.w  #0,$dff088
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		VGET.l  GfxBase,a1
		CALL    Exec,CloseLibrary
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
		Movem.l (sp)+,d0-d7/a0-a6
		Rts
;End

;Begin »»»»» DATA «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
GfxName         Dc.b    "graphics.library",0
		Even

VarTable        Dcb.b   CopperJMPBase_SIZE,0
		Even

	SECTION Copper1,DATA_C

CopperList2     Dc.w    $100,$0200,$1fc,0
		Dc.w    $800f,-2
		Dc.w    $106,$0000,$180,$500
		Dc.w    $106,$0200,$180,$500
		Dc.l    -2

		Dc.b    "These copperlists are not connected !"
		Even

CopperList1     Dc.w    $100,$0200,$1fc,0
		Dc.w    $106,$0000,$180,$050
		Dc.w    $106,$0200,$180,$050
CopJMP          Dc.w    $86,0
		Dc.w    $84,0
		Dc.w    $8a,0
   END
;End

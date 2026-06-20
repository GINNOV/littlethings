**************************************************
* Support routines for demo - AGA fades,         *
* interupts, linedraw, handy tables, handy       *
* routines etc. USE WITH LOADER.O!               *
* ---------------------------------------------- *
*                                                *
**************************************************

		   Machine   68020
;;; "Includes"
		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"
		   Include   "Loader.i"

		   xref      OldInt
		   xref      OldDMA
		   xref      OldLev3
		   xref      SyncBit

		   Incdir    "!Includes:OS3.0/"
		   Include   "exec/memory.i"
		   Include   "exec/exec.i"
		   Include   "dos/dos.i"
		   Include   "dos/dosextens.i"
;;;
;;; "Exported functions & datas"
		   xdef      _SetPtrs
		   xdef      _Sync
		   xdef      _InstallCopper

		   xdef      _AllocPublic
		   xdef      _AllocChip
		   xdef      _FreeMem
		   xdef      _FreeAll
		   xdef      _FreeMany

		   xdef      _AddVBLInt
		   xdef      _RemVBLInt

		   xdef      _SetColByte
		   xdef      _InitFade
		   xdef      _DoFade

		   xdef      P61_WaitCRow2
		   xdef      P61_WaitCRow
		   xdef      P61_WaitPos

		   xdef      _Sin1024
		   xdef      _InitSinus
		   xdef      _InitSinus2
;;;

		   Section   code,CODE

;;; "_SetPtrs"
*************************************************************
* Sätter pekare i copperlistor.                             *
* IN:    d0 - Antal bytes mellan varje bitplan (ex. 10240). *
*        d1 - Adress till skärm, sprites etc.               *
*        d2 - Hur många pekare som ska sättas (d2=ANTAL-1). *
*        a0 - Adress till första pekaren.                   *                                  *
* UT:    INGET                                              *
*                                                           *
* Förstör inga register.                                    *
*************************************************************
_SetPtrs:          Movem.l   d1-d2/a0,-(a7)
.SetPtrs           Move.w    d1,6(a0)
		   Swap      d1
		   Move.w    d1,2(a0)
		   Swap      d1
		   Add.l     d0,d1
		   Addq.l    #8,a0
		   Dbra      d2,.SetPtrs
		   Movem.l   (a7)+,d1-d2/a0
		   Rts
;;;
;;; "_Sync"
_Sync:             Movem.l   d0,-(a7)
		   Move.w    #0,SyncBit
.Sync              Move.w    SyncBit,d0
		   Beq       .Sync
		   ;Move.w    #0,SyncBit
		   Movem.l   (a7)+,d0
		   Rts
;;;
;;; "_InstallCopper"
_InstallCopper:    Movem.l   a5,-(a7)
		   Lea       Custom,a5
		   Move.l    a0,cop1lc(a5)
		   Move.w    d0,copjmp1(a5)
		   Move.w    #DMAF_SETCLR!DMAF_RASTER!DMAF_COPPER,dmacon(a5)
		   Movem.l   (a7)+,a5
		   Rts
;;;

;;; "_AllocPublic"
*********************************************************
* Allokerar PUBLIC minne.                               *
* IN: d0 - Storleken på minnet du vill allokera.        *
*     d1 - ID (1 och uppåt)                             *
* UT: d0 - Adressen till minnet, eller NOLL om det inte *
*          finns något ledigt.                          *
*                                                       *
* Förstör inga register.                                *
*********************************************************
_AllocPublic:      Movem.l   d1-d7/a0-a6,-(a7)

		   Lea       MemHeader,a0
		   Move.l    #128-1,d3
		   Moveq     #0,d2
.checklop          Tst.l     (a0)
		   Bne       .next
		   Move.l    a0,d2
		   Bra       .done
.next              Add.l     #12,a0
		   Dbra      d3,.checklop

.done              Tst.l     d2
		   Beq       .nomem
		   Move.l    d2,a5
		   Move.l    d0,d7
		   Move.l    d1,d6

		   Move.l    #MEMF_CLEAR,d1
		   Move.l    _ExecBase,a6
		   Jsr       _LVOAllocMem(a6)
		   Tst.l     d0
		   Beq       .nomem

		   Move.l    d0,(a5)+
		   Move.l    d6,(a5)+
		   Move.l    d7,(a5)+

		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts

.nomem             Moveq     #0,d0
		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts
;;;
;;; "_AllocChip"
*********************************************************
* Allokerar CHIP minne.                                 *
* IN: d0 - Storleken på minnet du vill allokera.        *
*     d1 - ID (1 och uppåt)                             *
* UT: d0 - Adressen till minnet, eller NOLL om det inte *
*          finns något ledigt.                          *
*                                                       *
* Förstör inga register.                                *
*********************************************************
_AllocChip:        Movem.l   d1-d7/a0-a6,-(a7)

		   Lea       MemHeader,a0
		   Move.l    #128-1,d3
		   Moveq     #0,d2
.checklop          Tst.l     (a0)
		   Bne       .next
		   Move.l    a0,d2
		   Bra       .done
.next              Add.l     #12,a0
		   Dbra      d3,.checklop

.done              Tst.l     d2
		   Beq       .nomem
		   Move.l    d2,a5
		   Move.l    d0,d7
		   Move.l    d1,d6

		   Move.l    #MEMF_CLEAR!MEMF_CHIP,d1
		   Move.l    _ExecBase,a6
		   Jsr       _LVOAllocMem(a6)
		   Tst.l     d0
		   Beq       .nomem

		   Move.l    d0,(a5)+
		   Move.l    d6,(a5)+
		   Move.l    d7,(a5)+

		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts

.nomem             Moveq     #0,d0
		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts
;;;
;;; "_FreeMem"
*********************************************************
* Frigör minne.                                         *
* IN: d0 - Adressen till minnet du vill frigöra.        *
* UT: VOID                                              *
*                                                       *
* Förstör inga register.                                *
*********************************************************
_FreeMem:          Movem.l   d0-d3/a0-a2,-(a7)
		   Lea       MemHeader,a0
		   Move.l    #128-1,d1
.checklop          Cmp.l     (a0),d0
		   Beq       .found
		   Add.l     #12,a0
		   Dbra      d1,.checklop
		   Movem.l   (a7)+,d0-d3/a0-a2
		   Rts

.found             Move.l    (a0),a1             ;Address
		   Move.l    8(a0),d0            ;Size

		   Clr.l     (a0)
		   Clr.l     4(a0)
		   Clr.l     8(a0)

		   Move.l    _ExecBase,a6
		   Jsr       _LVOFreeMem(a6)
		   Movem.l   (a7)+,d0-d3/a0-a2
		   Rts
;;;
;;; "_FreeAll"
*********************************************************
* Frigör allt minne.                                    *
* IN: VOID                                              *
* UT: VOID                                              *
*                                                       *
* Förstör inga register.                                *
*********************************************************
_FreeAll:          Movem.l   d0-d3/a0-a2,-(a7)
		   Lea       MemHeader,a0
		   Move.l    #128-1,d1

.checklop          Tst.l     (a0)
		   Bne       .found
.next              Add.l     #12,a0
		   Dbra      d1,.checklop
		   Movem.l   (a7)+,d0-d3/a0-a2
		   Rts

.found             Movem.l   d0-d1/a0,-(a7)
		   Move.l    (a0),a1             ;Address
		   Move.l    8(a0),d0            ;Size
		   Clr.l     (a0)
		   Clr.l     4(a0)
		   Clr.l     8(a0)

		   Move.l    _ExecBase,a6
		   Jsr       _LVOFreeMem(a6)
		   Movem.l   (a7)+,d0-d1/a0
		   Bra       .next
;;;
;;; "_FreeMany"
*********************************************************
* Frigör allt minne med speciellt ID.                   *
* IN: d0 - ID                                           *
* UT: VOID                                              *
*                                                       *
* Förstör inga register.                                *
*********************************************************
_FreeMany:         Movem.l   d0-d3/a0-a2,-(a7)
		   Lea       MemHeader,a0
		   Move.l    #128-1,d1

.checklop          Cmp.l     4(a0),d0
		   Beq       .found
.next              Add.l     #12,a0
		   Dbra      d1,.checklop
		   Movem.l   (a7)+,d0-d3/a0-a2
		   Rts

.found             Movem.l   d0-d1/a0,-(a7)
		   Move.l    (a0),a1             ;Address
		   Move.l    8(a0),d0            ;Size
		   Clr.l     (a0)
		   Clr.l     4(a0)
		   Clr.l     8(a0)

		   Move.l    _ExecBase,a6
		   Jsr       _LVOFreeMem(a6)
		   Movem.l   (a7)+,d0-d1/a0
		   Bra       .next
;;;

;;; "_AddVBLInt"
**************************************************************
* Lägger till en VBL-interrupt till kedjan.                  *
* IN: a0 - addressen till interruptrutinen                   *
* UT: d0 - Resultat - 0=ingen interruptplats ledig,          *
*                     1-8=interruptplatsen interrupten blev  *
*                     installerad i.                         *
*                                                            *
**************************************************************
_AddVBLInt:        Movem.l   d1-d7/a0-a6,-(a7)

		   Move.l    _VBR,a1
		   Move.l    #Lev3Int,$6c(a1)
		   Move.l    #$8020,$dff09a

		   Lea       VBLChain,a2
		   Move.l    #8-1,d3
		   Moveq     #0,d2
		   Moveq     #1,d4
.checklop          Tst.l     (a2)
		   Bne       .next
		   Move.l    a2,d2
		   Bra       .done
.next              Addq.l    #4,a2
		   Addq.l    #1,d4
		   Dbra      d3,.checklop

.done              Tst.l     d2
		   Beq       .noavailable
		   Move.l    d2,a2

		   Move.l    a0,(a2)
		   Move.l    d4,d0
		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts

.noavailable       Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #0,d0
		   Rts
;;;
;;; "_RemVBLInt"
******************************************************
* Tar bort en interrupt från kedjan.                 *
* IN: d0 - nummret på interruptplatsen (1-8).        *
* UT: VOID                                           *
*                                                    *
******************************************************
_RemVBLInt:        Movem.l   d0/a0,-(a7)

		   Lea       VBLChain,a0
		   Subq.l    #1,d0
		   Clr.l     (a0,d0.l*4)

		   Bsr       _Sync
		   Bsr       _Sync

		   Movem.l   (a7)+,d0/a0
		   Rts
;;;
;;; "Lev3 Interrupt Handler"
Lev3Int:           Movem.l   d0-d7/a0-a6,-(a7)
		   Btst      #5,$dff01f
		   Beq       .novblreq

		   Move.w    #1,SyncBit

.int1              Lea       VBLChain,a0
		   Tst.l     (a0)
		   Beq       .int2
		   Move.l    (a0),a1
		   Jsr       (a1)

.int2              Lea       VBLChain,a0
		   Tst.l     4(a0)
		   Beq       .int3
		   Move.l    4(a0),a1
		   Jsr       (a1)

.int3              Lea       VBLChain,a0
		   Tst.l     8(a0)
		   Beq       .int4
		   Move.l    8(a0),a1
		   Jsr       (a1)

.int4              Lea       VBLChain,a0
		   Tst.l     12(a0)
		   Beq       .int5
		   Move.l    12(a0),a1
		   Jsr       (a1)

.int5              Lea       VBLChain,a0
		   Tst.l     16(a0)
		   Beq       .int6
		   Move.l    16(a0),a1
		   Jsr       (a1)

.int6              Lea       VBLChain,a0
		   Tst.l     20(a0)
		   Beq       .int7
		   Move.l    20(a0),a1
		   Jsr       (a1)

.int7              Lea       VBLChain,a0
		   Tst.l     24(a0)
		   Beq       .int8
		   Move.l    24(a0),a1
		   Jsr       (a1)

.int8              Lea       VBLChain,a0
		   Tst.l     28(a0)
		   Beq       .novblreq
		   Move.l    28(a0),a1
		   Jsr       (a1)

.novblreq          Move.w    #%1110000,$dff09c
		   Movem.l   (a7)+,d0-d7/a0-a6
		   Nop
		   Rte
;;;

;;; "_SetColByte"
*****************************************
* Ställer in färgen direkt i hårdvaran  *
* IN:   d0 - Färg(0-255)                *
*       d1 - R värde                    *
*       d2 - G värde                    *
*       d3 - B värde                    *
*                                       *
* UT:   VOID                            *
*                                       *
* Förstör inga register.                *
*****************************************
_SetColByte:       Movem.l   d0-d7/a0-a1,-(a7)
		   Lea       Custom,a5
		   Move.w    d0,d4
		   And.w     #$00e0,d4
		   Lsl.w     #8,d4
		   Move.w    d4,a0               ;Calculate Colorbank
		   Or.w      #$0200,d4
		   Move.w    d4,a1

		   ;Get ECS part of RGB value

		   Move.b    d1,d5
		   Lsr.b     #4,d5               ;Red

		   Move.b    d2,d4
		   Lsr.b     #4,d4
		   And.b     #$f,d4              ;Green
		   Lsl.w     #4,d5
		   Or.b      d4,d5
	
		   Move.b    d3,d4
		   Lsr.b     #4,d4
		   And.b     #$f,d4              ;Blue
		   Lsl.w     #4,d5
		   Or.b      d4,d5

		   ;Get AGA part of RGB value

		   Move.b    d1,d6               ;Red

		   Move.b    d2,d4
		   And.b     #$f,d4              ;Green
		   Lsl.w     #4,d6
		   Or.b      d4,d6
	
		   Move.b    d3,d4
		   And.b     #$f,d4              ;Blue
		   Lsl.w     #4,d6
		   Or.b      d4,d6

		   And.l     #31,d0
		   Lsl.l     #1,d0               ;Calculate Color Register
		   Add.l     #$180,d0

		   Move.w    a0,bplcon3(a5)
		   And.w     #$fff,d5
		   Move.w    d5,(a5,d0)          ;Set color
		   Move.w    a1,bplcon3(a5)
		   And.w     #$fff,d6
		   Move.w    d6,(a5,d0)

		   Movem.l   (a7)+,d0-d7/a0-a1
		   Rts
;;;
;_SetCol16:
;_SetCol32:
;_SetColSplit:

;_PolCol16:
;_PolCol32:

;_MixCol16:
;_MixCol32:

;_Col16To32:
;_Col32To16:

;;; "_InitFade"
_InitFade
*************************************************
* Förbereder strukturen för en skalning mellan  *
* färger.                                       *
*                                               *
* IN:   d0 - Antal färger(Byt inte!)            *
*       d1 - Längd på skalning (1-n)            *
*       d2 - Första färg                        *
*       d3 - Mask till BPLCON3                  *
*       a0 - pekare till startfärg-värden.      *
*       a1 - pekare till slutfärg-värden.       *
*       a2 - pekare till 8192 bytes struktur.   *
*                                               *
* UT:                                           *
*                                               *
* Förstör bara input-register.                  *
*************************************************


	movem.l d0-d7/a0-a6,-(sp)

	tst.l   d1
	bne     .NoDivBy0

	moveq.l #1,d1                           ;Just to secure the
						;routine from a 
						;stupid user.
.NoDivBy0

	subq.l  #1,d0                           ;Another stupid
	and.l   #255,d0                         ;user preventer.
	addq.l  #1,d0

	move.l  a2,a3
	add.l   #3088,a3
	move.l  d1,(a2)+                        ;Store length of scaling
	move.l  d2,(a2)+                        ;Store first colour
	move.l  d0,(a2)+                        ;Store amount of colours
	move.l  d3,(a2)+                        ;Store BPLCON3 mask

	sub.l   #1,d0

.AGAPrepareColor
	addq.l  #1,a0
	addq.l  #1,a1
	move.l  #2,d4                           ;Loop 3 times (R,G,B)

.AGAPrepareGun
	clr.l   d2
	clr.l   d3
	move.b  (a0)+,d2                        ;Get source colour component
	lsl.l   #8,d2                           ;multiply by 256
	move.b  (a1)+,d3                        ;Get dest colour component
	lsl.l   #8,d3                           ;multiply by 256
	sub.l   d2,d3                           ;Get differance
	divs.l  d1,d3                           ;divide the diff. with the length
	move.l  d3,(a2)+                        ;Store component-adder
	move.l  d2,(a3)+                        ;Store source colour

	dbra    d4,.AGAPrepareGun
	dbra    d0,.AGAPrepareColor
	movem.l (sp)+,d0-d7/a0-a6
	rts
;;;
;;; "_DoFade"
_DoFade
*********************************************************
* Skalar övergången mellan 1 eller mer färger.          *
* Skalar max 256 färger.                                *
* OBS! Du måste kalla _AGAInitFade                      *
* först!                                                *
*                                                       *
* IN:   a0 - pekare till reserverad arbetslista         *
*                                                       *
* UT:   d0 - >0 om skalningen är klar                   *
*                                                       *
* Förstör bara input-register                           *
*********************************************************

	movem.l d0-d7/a0-a6,-(sp)

	Lea.l   Custom,a5

	tst.l   (a0)                            ;Fade finished?
	ble     .FadeFinished                   ;branch if d4<0

	move.l  a0,a1
	add.l   #3088,a1
	subq.l  #1,(a0)+                        ;decrease counter
	move.l  (a0)+,d4                        ;First colour
	move.l  (a0)+,d7                        ;Get amount of colours
	move.l  (a0)+,d5                        ;Get BPLCON3 mask

	subq.l  #1,d7
.AGAFadeColor

	move.l  (a0)+,d1                        ;Get R adder
	add.l   d1,(a1)+                        ;Modify R component
	move.l  (a0)+,d1                        ;Get G adder
	add.l   d1,(a1)+                        ;Modify G component
	move.l  (a0)+,d1                        ;Get B adder
	add.l   d1,(a1)+                        ;Modify B component

	sub.l   #12,a1
	move.l  d4,d0
	move.l  (a1)+,d1
	lsr.l   #8,d1
	move.l  (a1)+,d2
	lsr.l   #8,d2
	move.l  (a1)+,d3
	lsr.l   #8,d3

	movem.l d4-d5/d7,-(sp)                  ;Store essential regs

	and.w   #$00e0,d4
	lsl.w   #8,d4
	or.w    d5,d4
	move.w  d4,a4                           ;Calculate Colorbank
	or.w    #$0200,d4
	move.w  d4,a6

	;Get ECS part of RGB value

	move.b  d1,d5
	lsr.b   #4,d5                           ;Red

	move.b  d2,d4
	lsr.b   #4,d4
	and.b   #$f,d4                          ;Green
	lsl.w   #4,d5
	or.b    d4,d5

	move.b  d3,d4
	lsr.b   #4,d4
	and.b   #$f,d4                          ;Blue
	lsl.w   #4,d5
	or.b    d4,d5

	;Get AGA part of RGB value

	move.b  d1,d6                           ;Red

	move.b  d2,d4
	and.b   #$f,d4                          ;Green
	lsl.w   #4,d6
	or.b    d4,d6

	move.b  d3,d4
	and.b   #$f,d4                          ;Blue
	lsl.w   #4,d6
	or.b    d4,d6

	and.l   #31,d0
	lsl.l   #1,d0                           ;Calculate Color Register
	add.l   #$180,d0

	move.w  a4,bplcon3(a5)
	move.w  d5,(a5,d0)                      ;Set color
	move.w  a6,bplcon3(a5)
	move.w  d6,(a5,d0)

	movem.l (sp)+,d4-d5/d7                  ;Restore regs

	addq.l  #1,d4                           ;increase colour pointer

	dbra    d7,.AGAFadeColor

	movem.l (sp)+,d0-d7/a0-a6
	moveq.l #0,d0                           ;Return NOT_FINISHED signal
	rts

.FadeFinished

	movem.l (sp)+,d0-d7/a0-a6
	moveq.l #-128,d0                        ;Return FINISHED signal
	rts
;;;


;;; "P61_WaitPos"
**********************************
* IN: d0 - pos                   *
**********************************
P61_WaitPos:       Movem.l   d1,-(a7)
.lop
		   Btst      #2,$dff016
		   Beq       .break

		   Move.w    P61_Pos,d1
		   Cmp.w     d0,d1
		   Blt       .lop
		   Movem.l   (a7)+,d1

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Movem.l   (a7)+,d1
		   Rts

;;;
;;; "P61_WaitCRow"
**********************************
* IN: d0.w - Row                 *
**********************************
P61_WaitCRow:      Movem.l   d1,-(a7)
.lop
		   Btst      #2,$dff016
		   Beq       .break

		   Move.w    P61_CRow,d1
		   Cmp.w     d0,d1
		   Blt       .lop
		   Movem.l   (a7)+,d1

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Movem.l   (a7)+,d1
		   Rts
;;;
;;; "P61_WaitCRow2"
**********************************
* IN: d0 - Row                   *
**********************************
P61_WaitCRow2:     Movem.l   d1,-(a7)
.lop
		   Btst      #2,$dff016
		   Beq       .break

		   Move.w    P61_CRow,d1
		   Cmp.w     d0,d1
		   Bgt       .lop
		   Movem.l   (a7)+,d1

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Movem.l   (a7)+,d1
		   Rts
;;;

;;; "_InitSinus"
_InitSinus:        Lea       _Sin1024,a0
		   Move.l    #512-1,d0

.lop               Move.w    (a0),d1
		   Neg.w     d1
		   Move.w    d1,512*2(a0)
		   Addq.l    #2,a0
		   Dbra      d0,.lop

		   Rts
;;;

		   Section   data,DATA

_Sin1024:          Include   "SinList512-256.i"
		   Ds.b      1024

		   Section   bss,BSS

MemHeader:         Ds.l      128*3            ;Address.l,ID.l,Size.l
VBLChain:          Ds.l      8


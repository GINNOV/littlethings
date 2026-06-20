;********************************************************************
;
;                                YachtC
;  Copyright 1985 by Sheldon Leemon.  Feel free to copy and distribute the
;  program and source code, but don't try to sell, license, or otherwise
;  commercially exploit it.
;
;  If you have questions or comments, you may contact the author through
;  Delphi (username = DRX) or Compuserve ID 72705,1355.  No late-night
;  phone calls, please.
;
;*********************************************************************
;
;Version 2.0  modifications by Mark Schretlen of Calgary,Alberta
;             86-03-16   ( some fixes & Steve Bennett's "scales"
;             incorporated with calls to Happy, Bomb, and YahtzeeSound).
;
;Version 3.0  further modifications by M. Schretlen for
;             multitasking "scales" 87-12-30.
;
;Version 4.0  Converted C to assembly code. Revamped audio portion of
;             program to use dissidents' custom music library. Jeff Glatt

                       SECTION YachtC4Code,CODE

   SMALLOBJ ;PC relative mode for CAPE assembler. If MANX, search for MANX
            ;comments and make appropriate changes. Also eliminate this
            ;PC relative directive. Please read "ManxPCBug" on this disc
            ;because I've used a switch which Manx will probably assemble
            ;incorrectly. Why not buy a real assembler instead of Manx Asm?

  ;MANX - uncomment these two lines
  ;far code  ;Everyone else says "Small Data" if desired. Just like Manx to
  ;far data  ;do it completely backwards.

   ;from amiga.lib or small.lib
   XREF     _LVOOpenFont,_LVOCloseFont,_LVOSetFont
   XREF     _LVOSetAPen,_LVOSetDrMd,_LVOPolyDraw,_LVOLoadRGB4
   XREF     _LVOWait,_LVOGetMsg,_LVOReplyMsg,_LVOPutMsg
   XREF     _LVOOpenWindow,_LVOCloseWindow,_LVOOpenScreen,_LVOCloseScreen
   XREF     _LVOOpenLibrary,_LVOCloseLibrary
   XREF     _LVORemoveGadget,_LVOAddGadget,_LVOOnGadget,_LVOOffGadget
   XREF     _LVOAutoRequest,_LVOSetMenuStrip,_LVOViewPortAddress
   XREF     _LVODraw,_LVOMove,_LVOText,_LVODrawImage
   XREF     _LVOAllocMem,_LVOFreeMem
   XREF     _LVOCurrentTime

   ;from SmallStart.asm
   XREF     _SysBase,_DOSBase,_ThisTask,_exit

   ;from CHIP.asm
   XREF     OneSpot,TwoSpot,ThreeSpot,FourSpot,FiveSpot,SixSpot

 ;  XREF     _do_sound,_init_sound

_do_sound:
_init_sound rts

   XDEF   _main
_main:
    link     a5,#-358
 ;---Open libs, screen, windows
    bsr      open_libs
    beq      Cleanup
 ;---Initialize sound
    jsr      _init_sound
 ;---do_sound(YAHSOUND,7)
    pea      7
    pea      1
    jsr      _do_sound
    addq.l   #8,sp
 ;---draw the score pad
    bsr      draw_scorecard
;==================get number of players================
; while return value < 64, (wait until number of players selected from menu)
.18 bsr      IMsg     ;returns 64,65,66,or 67 for players
    moveq    #63,d1
    sub.w    d1,d0
    bls.s    .18
    move.w   d0,d6    ;number of players (1-4)
;===============initialize the scores================
    moveq    #4-1,d3      ;initialize 4 score cards
;for cats = 0 to < SCORECATS scores[players][cats++] = -1)
;==========blank the scoring columns to -1 to start with==========
.22 moveq    #84,d0
    mulu.w   d3,d0
    lea      -350(a5),a0
    adda.l   d0,a0
    moveq    #20-1,d2     ;20 scores in this players score structure
    moveq    #-1,d1
.27 move.l   d1,(a0)+
    Dbra     d2,.27
  ;---Now re-initialize certain fields
  ;---except for the rows with graphics or totals (they = 0)
  ;---scores[players][6] = 0
    lea      -326(a5),a0
    clr.l    0(a0,d0.l)
  ;---scores[players][7] = 0
    lea      -322(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][8] = 0
    lea      -318(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][9] = 0
    lea      -314(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][17] = 0
    lea      -282(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][18] = 0
    lea      -278(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][19] = 0
    lea      -274(a5),a0
    clr.l    0(a0,d0.l)
 ;---scores[players][20] = 0
    lea      -270(a5),a0
    clr.l    0(a0,d0.l)
    Dbra     d3,.22
;=================draw the score pad================
    bsr      draw_scorecard
;================Draw the 4 player Names=============
  ;---Set DrawMode to JAM1
    moveq    #0,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetDrMd(a6)
    moveq    #0,d2
.30 bsr      Name
    addq.b   #1,d2
    cmp.w    d6,d2
    bcs.s    .30
;========================play a whole game==============
 ;======for turns = 1 to 13 (score slots on a Yachtze Card)
    moveq    #13-1,d7
  ;=======for cur_player = 1 to #ofplayers
.34 moveq    #0,d2
    lea      -350(a5),a3    ;scores[player0]
   ;---highlight the player's name
.38 moveq    #5,d0          ;JAM2+INVERSVID
    movea.l  RastPort,a1
    jsr      _LVOSetDrMd(a6)
    bsr      Name
   ;---get dice values
    lea      -2(a5),a4      ;bones structure + 10 [start is -12(a5)]
    bsr      roll_dice
   ;---do_sound(DICEROLL,4)
    pea      4
    pea      4
    jsr      _do_sound
    addq.w   #8,sp
   ;---score_turn(scores[cur_player],bones,cur_player)
    lea      -12(a5),a0
    bsr      score_turn
   ;---unhighlight the player's name
    moveq    #1,d0          ;JAM2
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetDrMd(a6)
    bsr      Name
   ;---next player
    moveq    #84,d0
    adda.l   d0,a3     ;next player's scores structure
    addq.b   #1,d2
    cmp.w    d6,d2
    bcs.s    .38
   ;---one score slot complete
    Dbra     d7,.34
    bra      .18       ;go back for next game, or quit

;================== "BONES" STRUCTURE ========================
;   12 byte structure holding current dice values and # of rolls
;bones dc.w  die1value    ;0(BASE) value of die #1
;      dc.w  die2value    ;2
;      dc.w  die3value    ;4
;      dc.w  die4value    ;6
;      dc.w  die5value    ;8
;      dc.w  #ofRolls     ;10  total rolls/turns (3 max)
;
; This routine rolls all 5 dice (via Rollrep), waits for user to select and
; change dice for 3 turns/rolls (via IMsg and Shake), and returns the bones
; structure with final, filled-in values.
;
; roll_dice(bones+10)
;              a4

   XDEF   roll_dice
roll_dice:
    movem.l  d2/a2/a3,-(sp)
    movea.l  _IntuitionBase,a6
    lea      DieGadg5,a3     ;start with last die's gadget
    moveq    #5-1,d2         ;last die number
 ;---bones[#ofRolls] = 1
    moveq    #1,d0
    move.w   d0,(a4)
 ;---this die's Gadget Activation = TOGGLESELECT
.45 Bset.b   #0,14(a3)
 ;---roll all 5 dice and store results (i.e. the 1st turn/roll)
    bsr      Rollrep
    move.w   d0,-(a4)
    moveq    #44,d1
    suba.l   d1,a3
    Dbra     d2,.45
 ;---Turn on the "ROLL" gadget
    suba.l   a2,a2
    movea.l  ScoreWindow,a1
    lea      RollGadget,a0
    jsr      _LVOOnGadget(a6)
;============while changed=1 AND bones[TURNS] < 3 ==================
  ;while flag < 17 OR flag > 24  (wait til "ROLL" gadget selected)
.49 bsr      IMsg
    cmp.w    #17,d0
    bcs.s    .49
    cmp.w    #24,d0
    bhi.s    .49         ;branch back if not ROLL gadget
  ;----shake whichever die is selected
    movea.l  _IntuitionBase,a6
    bsr      Shake       ;returns # of dice selected for change
    move.b   d0,d1
    beq.s    .48         ;exit if none changed
    moveq    #3,d0
    sub.w    10(a4),d0
    bhi.s    .49         ;branch if not 3 rolls yet (turn = 0,1,or 2)
  ;----Turn "ROLL" Gadget off
.48 movea.l  ScoreWindow,a1
    lea      RollGadget,a0
    jsr      _LVOOffGadget(a6)
 ;---Disable all 5 dice gadgets
    moveq    #5-1,d1
    lea      DieGadg1+14,a0
    moveq    #44,d0
.54 clr.w    (a0)        ;this die's Gadget Activation = NULL
    adda.l   d0,a0
    Dbra     d1,.54
;=============CHECK FOR YAHTZEE (all 5 die equal)==============
;if all 5 bones values are equal, then do_sound(YAHSOUND,5)
    move.w   (a4)+,d0
    cmp.w    (a4)+,d0
    bne.s    .56
    cmp.w    (a4)+,d0
    bne.s    .56
    cmp.w    (a4)+,d0
    bne.s    .56
    sub.w    (a4)+,d0
    bne.s    .56
    pea      5
    pea      1
    jsr      _do_sound
    addq.l   #8,sp
.56 movem.l  (sp)+,d2/a2/a3
    rts

;**************************************************************
; This routine evaluates the current dice values in the bones array
; in terms of the score they produce for the scoring category (passed
; as row for the function "Evaluate" which returns the score).
;
;score_turn(scores,bones,cur_player)
;             a3    a0      d2

   XDEF   score_turn
score_turn:
    link     a5,#-22
    movem.l  d3/a2,-(sp)
 ;-----Zero out temporary sort array
    moveq    #7-1,d0
    lea      -20(a5),a2 ;values[0]
    movea.l  a2,a1
.62 clr.w    (a2)+
    Dbra     d0,.62
;============for 5 die (sort dice by number of spots)===========
    moveq    #5-1,d0
    lea      12(a1),a2  ;values[6]
.66 move.w   (a0)+,d1   ;bones[die#]
  ;---add (1+bones[die#]) to value[6]  /* add die to total */
    add.w    d1,(a2)    ;total of all 5 die
    addq.w   #1,(a2)
  ;---add 1 to values[bones[die#]]
    add.w    d1,d1
    addq.w   #1,0(a1,d1.w)
    Dbra     d0,.66
;===============position score gadget==================
;ScoreGadget.LeftEdge = VLINL + (VLINS*cur_player) + 4
    moveq    #90,d0
    mulu.w   d2,d0
    addi.w   #132,d0
    move.w   d0,_ScoreGadget+4
;==============show possible scores to let player select===============
    moveq    #17-1,d3   ;do 17 rows
    lea      68(a3),a2  ;past row #16
 ;----if scores[row] = -1, then no score there yet
.70 move.l   -(a2),d0
    bpl.s    .72
 ;----erase dots with bg pen
    moveq    #0,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetAPen(a6)
    ;---ShowDots (row,cur_player)
    move.w   d2,d0
    move.w   d3,d1
    bsr      ShowDots
 ;---show possible scores in purple
    moveq    #PURP,d0
    movea.l  RastPort,a1
    jsr      _LVOSetAPen(a6)
    ;---score = Evaluate(values,row)
    lea      -20(a5),a0
    bsr      Evaluate
   ;---ShowScore (score,row,cur_player)
    move.l   d2,-(sp)
    move.l   d3,-(sp)
    move.l   d0,-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
.72 Dbra     d3,.70
;====wait  until user clicks on a score of an unused category=======
;   while row > 17 OR scores[row] is not = -1 (already scored slot)
.73 bsr      IMsg
    moveq    #17,d1
    sub.w    d0,d1
    bcs.s    .73
    move.w   d0,d3           ;row # (0 to 17)
    add.b    d0,d0
    add.w    d0,d0
    move.l   0(a2,d0.w),d1
    bpl.s    .73             ;branch back if already scored
  ;----selected score in forest green
    moveq    #FGRP,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetAPen(a6)
  ;---score = Evaluate(values,row)   /* evaluate row selected */
    lea      -20(a5),a0
    bsr      Evaluate
    move.w   d0,-2(a5)
  ;---ShowScore (score,row,cur_player), and save score in score structure
    move.l   d2,-(sp)
    move.w   d3,d1
    move.l   d3,-(sp)
    add.b    d1,d1
    add.w    d1,d1
    move.l   d0,0(a2,d1.w)   ;store score in the this row's field
    move.l   d0,-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
;**************Steve Bennett's "scales" sounds.**************
;if score < 3 OR (score < 6 AND row > 2)  do_sound(BOMBSOUND,5)
    move.w   -2(a5),d0
    cmp.b    #3,d0
    bcs.s    .77
    cmp.b    #6,d0
    bcc.s    .76
    cmp.w    #2,d3
    bls.s    .76
.77 pea      5
    pea      3
    jsr      _do_sound
    addq.w   #8,sp
    bra      .78
;else if (score > 18 AND row < 6) OR (score > 25 AND row > 8)
;do_sound(HAPPYSOUND,5)
.76 cmpi.b   #18,d0
    bls.s    .81
    cmp.w    #6,d3
    bcs.s    .80
.81 cmpi.b   #25,d0
    bls.s    .79
    cmp.w    #8,d3
    bls.s    .79
.80 pea      5
    pea      2
    jsr      _do_sound
    addq.w   #8,sp
    bra.s    .78
;else if (score < 20 AND row > 8)  do_sound(HAPPYSOUND,1)
.79 cmpi.b   #20,d0
    bcc.s    .78
    cmp.w    #8,d3
    bhi.s    .80
;=================if row < 7====================
.78 moveq    #7,d1
    sub.w    d1,d3
    bcc.s    .84
  ;---ClearRow(7,cur_player)
    move.w   d2,d0
    ;        #7,d1
    bsr      ClearRow
  ;ShowScore (scores[7],7,cur_player)   /* do upper sub-total
    move.l   d2,-(sp)
    pea      7
    move.w   -2(a5),d0
    add.w    d0,30(a3)     ;add score to scores[7]
    move.l   28(a3),-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
    bra.s    .85
  ;----ClearRow(18,cur_player)
.84 move.w   d2,d0
    moveq    #18,d1
    bsr      ClearRow
  ;ShowScore (scores[18],18,cur_player)   /* or else lower total
    move.l   d2,-(sp)
    pea      18
    move.w   -2(a5),d0
    add.w    d0,74(a3)     ;add score to scores[18]
    move.l   72(a3),-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
;if scores[7] > BONUS
.85 moveq    #63,d0
    sub.l    28(a3),d0
    bhi.s    .86
  ;---ClearRow(8,cur_player)
    move.w   d2,d0
    moveq    #8,d1
    bsr      ClearRow
  ;ShowScore (scores[8] = 35, 8, cur_player)   /* check for bonus
    move.l   d2,-(sp)
    pea      8
    moveq    #35,d0
    move.l   d0,32(a3)
    move.l   d0,-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
;==============add sub-totals to total and display=============
  ;---ClearRow(20,cur_player)
.86 move.w   d2,d0
    moveq    #20,d1
    bsr      ClearRow
  ;ShowScore (scores[20]=scores[7]+scores[8]+scores[18],20,cur_player)
    move.l   d2,-(sp)
    pea      20
    move.l   28(a3),d0
    add.l    32(a3),d0
    add.l    72(a3),d0
    move.l   d0,80(a3)
    move.l   d0,-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
;============================= Do 17 Rows =============================
    moveq    #17-1,d3
    lea      68(a3),a2  ;past row #16
;----Check if this row is unscored still
.89 move.l   -(a2),d0
    bpl.s    .91
;------erase the score of this row with bg pen
    moveq    #0,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetAPen(a6)
  ;---score = Evaluate(values,row
    lea      -20(a5),a0
    bsr      Evaluate
  ;---ShowScore (score,row,cur_player)
    move.l   d2,-(sp)
    move.l   d3,-(sp)
    move.l   d0,-(sp)
    bsr      _ShowScore
    lea      12(sp),sp
;==========draw dots in black pen===============
    moveq    #7,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetAPen(a6)
   ;----ShowDots (row,cur_player)
    move.w   d2,d0
    move.w   d3,d1
    bsr      ShowDots
;------------Next row------------
.91 Dbra     d3,.89
    movem.l  (sp)+,d3/a2
    unlk     a5
    rts

;********************************************************************
; Handles IntuiEvents of MENUPICK, GADGETUP, and CLOSEWINDOW. If CLOSEWINDOW,
; exits immediately. If GADGETUP, returns 0 to 17 for row in scorecard.
; Returns between 17 to 24 for ROLL gadg. Otherwise, default return = 35.
; If MENUPICK, returns 64 + # of players if MENU #0 selected, 32 if MENU #1
; selected.

   XDEF   IMsg
IMsg:
     movem.l  d2-d4/a2,-(sp)
 ;---Initially, flag = 35
     moveq    #35,d2
 ;----Wait for Score window message, then get it
     movea.l  ScoreWindow,a0
     movea.l  86(a0),a2
     move.b   15(a2),d1
     moveq    #0,d0
     Bset.l   d1,d0
     movea.l  _SysBase,a6
     jsr      _LVOWait(a6)
.95  movea.l  a2,a0
     jsr      _LVOGetMsg(a6)
     move.l   d0,d1
     bne.s    .96
  ;---return flag
     move.w   d2,d0
     movem.l  (sp)+,d2-d4/a2
     rts
.96  movea.l  d0,a1
     lea      20(a1),a0
     move.l   (a0)+,-(sp)
     move.w   (a0)+,d3         ;CODE
     addq.l   #8,a0
     move.w   (a0)+,d4         ;MOUSEY
     jsr      _LVOReplyMsg(a6)
     move.l   (sp)+,d0         ;CLASS
     Btst.l   #6,d0
     bne.s    .100
     Btst.l   #8,d0
     bne.s    .101
     Btst.l   #9,d0
     beq.s    .95
;===============case CLOSEWINDOW:==================
.99  movem.l  (sp)+,d2-d4/a2
     bra      Cleanup
;===============case GADGETUP:=====================
 ;---flag (i.e. row #) = (MOUSEY-29)/8
.100 move.w   d4,d2
     moveq    #29,d1
     sub.w    d1,d2
     lsr.w    #3,d2
     bra.s    .95
;==============case MENUPICK:====================
.101 move.w   d3,d1
     andi.w   #$1F,d3
     beq      .104
     subq.w   #1,d3
     bne.s    .95
   ;=============MENU 1:
.105 lsr.w    #5,d1
     andi.w   #$3F,d1
     beq.s   .108
   ;----------ITEM 1:
   ; Show the about requester
.109 move.w   #148,d3
     lea      _AboutText+200,a1
.PP  movem.l  a2/a3/a6,-(sp)
     move.w   #515,d2
     moveq    #0,d0
     moveq    #0,d1
     movea.l  ScoreWindow,a0
     lea      _OKText,a3
     suba.l   a2,a2
     movea.l  _IntuitionBase,a6
     jsr      _LVOAutoRequest(a6)
     movem.l  (sp)+,a2/a3/a6
   ;---flag = 32
     moveq    #32,d2
     bra      .95
  ;--------ITEM 0:
  ; Show the Instructions requester
.108 move.w   #180,d3
     lea      _InstructText+260,a1
     bra.s    .PP
;==============MENU 0:
  ;-----flag (i.e. number of players + 64) = 64 + ITEMNUM
.104 lsr.w    #5,d1
     andi.w   #$3F,d1
     moveq    #64,d2
     add.b    d1,d2
     bra      .95

;==================================================================
;changed = Shake(bones, IntuitionBase)
;                 a4         a6

   XDEF   Shake
Shake:
     movem.l  d2/d3/a2/a3,-(sp)
     moveq    #0,d3        ;initially, changed = 0
     moveq    #5-1,d2      ;# of die
     lea      DieGadg5,a3  ;start with last die
     suba.l   a2,a2        ;for OnGadget
  ;---Turn on this die
.115 movea.l  ScoreWindow,a1
     movea.l  a3,a0
     jsr      _LVOOnGadget(a6)
  ;If this die's Flags = SELECTED, then roll die and store result
     Btst.b   #7,13(a3)
     beq.s    .113
     bsr.s    Rollrep
     move.l   d2,d1
     add.b    d1,d1
     move.w   d0,0(a4,d1.l)
;=============Deselect the die Gadget==============
;Since its not nice to change the SELECTED flag while the gadget is active
;(only the user is supposed to do that by clicking on it), we'll be nice
;and first Remove the die gadget from the list, THEN change the flag
;and finally, Add it back to the list again.
   ;---RemoveGadget(BdWdw, &DieGadg[die#])
     movea.l  a3,a1
     movea.l  ScoreWindow,a0
     jsr      _LVORemoveGadget(a6)
  ;---toggle SELECTED flag
     Bchg.b   #7,13(a3)
  ;---AddGadget(BdWdw,&DieGadg[die#],Gadget#)
     movea.l  a3,a1
     movea.l  ScoreWindow,a0
     jsr      _LVOAddGadget(a6)
     addq.b   #1,d3
.113 moveq    #44,d0
     suba.l   d0,a3      ;next die Gadget
     Dbra     d2,.115
  ;----increment bones[TURNS] (another roll finished)
     addq.w   #1,10(a4)
  ;---return total number of changed (selected) dice
     move.w   d3,d0
     movem.l  (sp)+,d2/d3/a2/a3
     rts

;==================================================================
;throw = Rollrep(die_number, DieGadgAddr, Intuitionbase)
;                   d2           a3            a6

   XDEF   Rollrep
Rollrep:
     move.l   d3,-(sp)
     move.l   d4,-(sp)
     moveq    #9-1,d3     ;do 9 random throws before final value returned
  ;----throw = random()%6
roll bsr.s    random
     moveq    #6,d1
     divu     d1,d0
     swap     d0
     move.w   d0,d4
  ;---Blank out the Die face
     moveq    #31,d1      ;BLANKS
     mulu.w   d2,d1
     moveq    #20,d0      ;BLANKT
     add.w    d0,d1       ;TopOffset = (BLANKS*Die#)+BLANKIT
     move.w   #530,d0     ;LeftOffset = BLANKL
     lea      BlankImage,a1
     movea.l  RastPort,a0
     movem.l  d0/d1/a0,-(sp)
     jsr      _LVODrawImage(a6)
;---Draw the die Image that was thrown and store address in die's Gadget-
;   Render field for subsequent updates
     moveq    #20,d0
     mulu.w   d4,d0
     lea      Die1Image,a1
     adda.l   d0,a1          ;The image struct of this die
     move.l   a1,18(a3)      ;store in die's GadgetRender field
     movem.l  (sp)+,d0/d1/a0
     jsr      _LVODrawImage(a6)
     Dbra     d3,roll
   ;---return(throw)
     move.w   d4,d0
     move.l   (sp)+,d4
     move.l   (sp)+,d3
     rts

  XDEF random,RAND
random:
 ;----RAND = RAND * 1103515245 + 12345
   move.l   #1103515245,d1
   move.l   RAND,d0
   bsr.s    multiply
   addi.l   #12345,d0
   move.l   d0,RAND
 ;-----return (RAND/65536) % 32768
   clr.w    d0
   swap     d0        ;divide by 65536
   Bclr.l   #15,d0
   rts

   XDEF multiply
 ;This routine multiplies 2 numbers passed in d0 and d1.
 ;d0 x d1 = d0  (unsigned)
multiply movea.l d2,a0   ;save d2 and d3
         movea.l d3,a1
       move.l  d0,d2
       move.l  d1,d3
       swap    d2
       swap    d3
       mulu    d1,d2
       mulu    d0,d3
       mulu    d1,d0
       add.w   d3,d2
       swap    d2
       clr.w   d2
       add.l   d2,d0
         move.l  a1,d3   ;restore d2 and d3
         move.l  a0,d2
       rts

RAND dc.l 1

;==================================================================
;score = Evaluate (values,row)
;                    a0   d3
evl  dc.w     .zr-evl2
     dc.w     .zr-evl2
     dc.w     .zr-evl2
     dc.w     .140-evl2
     dc.w     .148-evl2
     dc.w     .156-evl2
     dc.w     .164-evl2
     dc.w     .176-evl2
     dc.w     .199-evl2
     dc.w     .205-evl2

   XDEF   Evaluate
Evaluate:
     move.l   d2,-(sp)
  ;--------switch(row)
     move.l   d3,d1
     subq.l   #7,d1
     bls.s    .0to5
     moveq    #10,d0
     cmp.l    d0,d1
     bcc.s    .zr
     add.b    d1,d1
     move.w   evl(pc,d1.w),d1
evl2 jmp      evl2(pc,d1.w)
;=================case 0: through case 5:=====================
  ;----return (row+1)*values[row]  (return total of desired spots)
.0to5:
     move.w   d3,d0
     move.l   d3,d1
     addq.b   #1,d0
     add.b    d1,d1
     adda.l   d1,a0
     mulu.w   (a0),d0
     bra.s    .139
;===============case 10: 3 of a kind===============
.140 moveq    #2,d1
     bra.s    KD
;===============case 11: 4 of a kind===============
.148 moveq    #3,d1
KD   moveq    #0,d0
  ;----if values[count] > 3, return values[6] (total of dice) instead of 0
     moveq    #6-1,d2
     lea      12(a0),a1
.151 cmp.w    (a0)+,d1
     bcc.s    .149
     move.w   (a1),d0
.149 Dbra     d2,.151
     bra.s    .139
;==============case 12: full house=============
.156 moveq    #0,d1
  ;---if values[count] > 1, flagg = flagg + values[count]
     moveq    #6-1,d2
     moveq    #1,d0
.159 cmp.w    (a0)+,d0
     bcc.s    .158
     add.w    -2(a0),d1
.158 Dbra     d2,.159
 ;---If flagg = 5, return 25. Otherwise 0.
     moveq    #0,d0
     subq.b   #5,d1
     bne.s    .139
     moveq    #25,d0
.139 move.l   (sp)+,d2
     rts
;============case 13: small straight============
.164 moveq    #3-1,d1    ;do 3 checks
SRT  movea.l  a0,a1
     moveq    #4-1,d2    ;check for 4 numbers in order
  ;---Is there 1 (or more) of this #?
AGN  move.w   (a1)+,d0
     Dbeq     d2,AGN     ;fall through if no occurences of this #
     bne.s    strt       ;must be a straight of 4 numbers
  ;---Try next 4 numbers
     addq.l   #2,a0
     Dbra     d1,SRT
     bra.s    .zr
strt moveq    #30,d0
     bra.s    .139
;==============case 14: large straight===============
.176 moveq    #2-1,d1    ;do 2 checks
SRt  movea.l  a0,a1
     moveq    #5-1,d2    ;check for 5 numbers in order
  ;---Is there 1 (or more) of this #?
AGn  move.w   (a1)+,d0
     Dbeq     d2,AGn     ;fall through if no occurences of this #
     bne.s    strT       ;must be a straight of 4 numbers
  ;---Try next 4 numbers
     addq.l   #2,a0
     Dbra     d1,SRt
.zr  moveq    #0,d0
     bra.s    .139
strT moveq    #40,d0
     bra.s    .139
;================case 15: Yachtze==============
  ;---if values[count] = 5, then return 50
.199 moveq    #6-1,d2   ;do 6 die
     moveq    #0,d0
     moveq    #5,d1     ;check for 5 of this die
.202 cmp.w    (a0)+,d1
     Dbeq     d2,.202
     bne      .139
     moveq    #50,d0
     bra      .139
;=============case 16: Chance============
   ;----return values[6]
.205 moveq    #0,d0
     move.w   12(a0),d0
     bra      .139

;==================================================================
;ShowScore(score,row,player)

   XDEF   _ShowScore
_ShowScore:
   movem.l  d2/a2,-(sp)
   movea.l  _GfxBase,a6
 ;---SetDrMd to JAM1
   moveq    #0,d0
   movea.l  RastPort,a1
   movea.l  a1,a2
   jsr      _LVOSetDrMd(a6)
 ;---Move (BdRp,DOTL + (DOTS*player), (row*TEXTS)+DOTT )
   move.w   18(sp),d1
   lsl.w    #3,d1
   moveq    #36,d2
   add.w    d2,d1
   move.w   22(sp),d0
   mulu.w   #90,d0
   move.b   #155,d2
   add.w    d2,d0
   movea.l  a2,a1
   jsr      _LVOMove(a6)
 ;---Text (BdRp, "    ",4)
   moveq    #4,d0
   lea      Spaces,a0
   movea.l  a2,a1
   jsr      _LVOText(a6)
 ;---format_4(score_str,score)
   move.l   12(sp),d0
   lea      Zeros,a0
   bsr.s    format_4
;Move (BdRp,DOTL + (DOTS*player + ((4-length)*SPACEW) ), (row*TEXTS)+DOTT )
   move.w   22(sp),d0
   mulu.w   #90,d0
   add.w    #155,d0   ;x
  ;---
   move.w   18(sp),d1
   lsl.w    #3,d1
   moveq    #36,d2
   add.w    d2,d1        ;y
   movea.l  a2,a1
   jsr      _LVOMove(a6)
 ;---Text (BdRp, score_str, length)
   moveq    #4,d0
   lea      Zeros,a0
   movea.l  a2,a1
   movem.l  (sp)+,d2/a2
   jmp      _LVOText(a6)

;===================================================================
; An sprintf for positive hex to decimal ascii string, 4 digit field. Blanks
; are filled for leading zeros, and buffer padded out to 4 chars.
;
;            format_4(value, Buffer)
;                      d0      a0

Conversion dc.w  1000,100,10,1

   XDEF   format_4
format_4:
     movem.l d2-d4,-(sp)
     moveq   #0,d4       ;leading zero flag
;---Convert the value to Decimal
     moveq   #4-1,d2     ;do 4 digits
     lea     Conversion,a1
g07  moveq   #0,d1       ;where to store the converted digit
     move.w  (a1)+,d3    ;the next conversion factor
;---Convert a digit field (for example, the 10s digit)
Rep1 cmp.w   d3,d0
     bcs.s   g011
     addq.b  #1,d1
     sub.l   d3,d0
     bra.s   Rep1
;---Check whether we have a leading digit of zero. If so, move
;---on to the next field unless this IS the last field in
;---which case we have to store a 0. If this digit is
;---not a zero, then print it.
g011 move.b  d1,d3  ;test for 0 digit
     beq.s   g012
     moveq   #1,d4  ;indicate non-zero digit (only set once)
g012 move.b  d4,d3
     bne.s   g013
     move.w  d2,d3
     beq.s   g013   ;branch if the 1's digit AND value is zero
     moveq   #' ',d1
     bra.s   SF
;---Convert to Ascii and store this digit
g013 addi.b  #'0',d1
SF   move.b  d1,(a0)+
g014 Dbra    d2,g07     ;next digit calculation
     clr.b   (a0)
     movem.l (sp)+,d2-d4
     rts

;=================================================================
;ShowDots (row,player)
;           d1   d0

   XDEF   ShowDots
ShowDots:
 ;----Move (BdRp,DOTL + (DOTS*player), (row*TEXTS)+DOTT )
   move.l   d2,-(sp)
   lsl.w    #3,d1
   moveq    #36,d2
   add.w    d2,d1
   moveq    #90,d2
   mulu.w   d2,d0
   move.b   #155,d2
   add.w    d2,d0
   movea.l  RastPort,a1
   move.l   (sp),d2
   move.l   a1,(sp)
   movea.l  _GfxBase,a6
   jsr      _LVOMove(a6)
 ;---SetDrMd to JAM1
   moveq    #0,d0
   movea.l  (sp),a1
   jsr      _LVOSetDrMd(a6)
 ;---Print out '....'
   moveq    #4,d0
   lea      Dots,a0
   movea.l  (sp)+,a1
   jmp      _LVOText(a6)

Dots  dc.b   '....',0
Zeros dc.b   '0000',0

;======================================================================
;ClearRow (row,player)
;           d1   d0

   XDEF   ClearRow
ClearRow:
 ;----Move (BdRp,DOTL + (DOTS*player), (row*TEXTS)+DOTT )
   move.l   d2,-(sp)
   lsl.w    #3,d1
   moveq    #36,d2
   add.w    d2,d1
   moveq    #90,d2
   mulu.w   d2,d0
   move.b   #155,d2
   add.w    d2,d0
   movea.l  RastPort,a1
   move.l   (sp),d2
   move.l   a1,(sp)
   movea.l  _GfxBase,a6
   jsr      _LVOMove(a6)
 ;---SetDrMd to JAM2
   moveq    #1,d0
   movea.l  (sp),a1
   jsr      _LVOSetDrMd(a6)
 ;---Output "    "
   moveq    #4,d0
   lea      Spaces,a0
   movea.l  (sp)+,a1
   jmp      _LVOText(a6)

;====================================================================
;Name (player, _GfxBase)
;        d2       a6

   XDEF   Name
Name:
 ;---Move(BdRp, DOTL -(2*SPACEW) + (DOTS*player), TEXTT+2)
   moveq    #90,d0
   mulu.w   d2,d0
   moveq    #0,d1
   move.b   #135,d1
   add.w    d1,d0
   moveq    #22,d1
   movea.l  RastPort,a1
   move.l   a1,-(sp)
   jsr      _LVOMove(a6)
 ;---Text(BdRp, textline[MAXLINES+player], 8)
   movea.l  (sp)+,a1
   moveq    #8,d0
   moveq    #23,d1    ;MAXLINES
   add.w    d2,d1
   add.w    d1,d1
   add.w    d1,d1
   lea      _textline,a0
   adda.w   d1,a0
   movea.l  (a0),a0
   jmp      _LVOText(a6)

;===================================================================
;  Open intuition, graphics libs, font, windows, screen, set menu
;  returns d0 = 1 if successful, 0 if something failed.

LIB_VERSION equ 33

                XDEF  open_libs
open_libs:
;======Open The Intuition Library=======
B0  moveq    #LIB_VERSION,d0
    lea      IntuitionName,a1
    movea.l  _SysBase,a6
    jsr      _LVOOpenLibrary(a6)
    move.l   d0,_IntuitionBase
    beq      B10
;======Open The Graphics Library========
B1  moveq    #LIB_VERSION,d0
    lea      GfxName,a1
    jsr      _LVOOpenLibrary(a6)
    move.l   d0,_GfxBase
    beq      B10
;========Open the Topaz 8 Font==========
B4  lea      TextAttr,a0
    movea.l  _GfxBase,a6
    jsr      _LVOOpenFont(a6)
    move.l   d0,FontPtr
    beq      B10
;==========Open Custom Screen===========
B5  lea      NewScreen,a0
    movea.l  _IntuitionBase,a6
    jsr      _LVOOpenScreen(a6)
    move.l   d0,Screen
    beq      B10
    lea      NewWindow,a0
    move.l   d0,30(a0)
;=========Open the main window==========
    jsr      _LVOOpenWindow(a6)
    move.l   d0,ScoreWindow
    beq      B10
;====Get Pointer to Window's RastPort=====
B6  movea.l  d0,a0
    movea.l  50(a0),a1
    move.l   a1,RastPort         ;the address our this window's rastport.
;====Set the Font for this window to Topaz 8====
B7  movea.l  FontPtr,a0
    movea.l  _GfxBase,a6
    jsr      _LVOSetFont(a6)
;====Attach our menus to the window======
B8  lea      _BdMenu,a1
    movea.l  ScoreWindow,a0
    movea.l  _IntuitionBase,a6
    jsr      _LVOSetMenuStrip(a6)
;====Get the Front Window's ViewPort==========
    movea.l  ScoreWindow,a0
    jsr      _LVOViewPortAddress(a6)
    move.l   d0,_WVPort
;=======load our new set of (8) colors======
    movea.l  d0,a0
    moveq    #8,d0
    lea      _colormap,a1
    movea.l  _GfxBase,a6
    jsr      _LVOLoadRGB4(a6)
;====Indicate that everything worked=====
    moveq    #1,d0               ;If we got here, indicate success by d0 = 1.
B10 rts

   XDEF   draw_scorecard
draw_scorecard:
     link     a5,#-8
     movem.l  d2/d3/a2/a3/a4,-(sp)
;====================Set up the board outline===========================
  ;--SetAPen to BLKP
     moveq    #7,d0
     movea.l  RastPort,a1
     movea.l  a1,a2
     movea.l  _GfxBase,a6
     jsr      _LVOSetAPen(a6)
  ;--Move to (0,VLINT)
     moveq    #13,d1      ;VLINT
     moveq    #0,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---SetDrMd = JAM2
     moveq    #1,d0
     movea.l  a2,a1
     jsr      _LVOSetDrMd(a6)
  ;---PolyDraw  8 boardlines points
     lea      _boardlines,a0
     moveq    #8,d0
     movea.l  a2,a1
     jsr      _LVOPolyDraw(a6)
;==============Put in text and horizontal lines for board===========
  ;---Move to (TEXTL,TEXTT+2)
     moveq    #22,d1
     moveq    #5,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---Print out "players"
     lea      _textline,a3
     movea.l  (a3)+,a0
     movea.l  a0,a1
len  move.b   (a1)+,d0
     bne.s    len
     subq.l   #1,a1
     move.l   a1,d0
     sub.l    a0,d0
     movea.l  a2,a1
     jsr      _LVOText(a6)
;===========for count = 1 to < MAXLINES==================
     moveq    #1,d0
     move.w   d0,-8(a5)
     moveq    #28,d2       ;Y position = (line# * TEXTS) + TEXTT
  ;---if the textline string = ' ' then draw a line
.238 movea.l  (a3)+,a4
     move.b   (a4),d0
     bne.s    .239
  ;----Move to (1,[count*HLINS+HLINT])
     move.w   d2,d1
     subq.w   #2,d1
     moveq    #1,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;-----Draw to (HLINR,[count*HLINS+HLINT])
     move.w   d2,d1
     subq.w   #2,d1
     move.w   #489,d0
     movea.l  a2,a1
     jsr      _LVODraw(a6)
     bra.s    .236
;=======else, print the text and do columns=============
   ;---Move(BdRp,TEXTL,(count*TEXTS)+TEXTT)
.239 move.w   d2,d1
     moveq    #5,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---Text(BdRp,textline[count],strlen(textline[count]))
     movea.l  a4,a0
leN  move.b   (a4)+,d0
     bne.s    leN
     subq.l   #1,a4
     move.l   a4,d0
     sub.l    a0,d0
     movea.l  a2,a1
     jsr      _LVOText(a6)
   ;=========for column = 0 to < MAXPLAYERS
     moveq    #4-1,d3
  ;----ClearRow(count-2,column)
.243 move.w    d3,d0
     move.w    -8(a5),d1
     subq.w    #2,d1
     bsr       ClearRow
  ;---ShowDots(count-2,column)
     move.w    d3,d0
     move.w    -8(a5),d1
     subq.w    #2,d1
     bsr       ShowDots
     Dbra      d3,.243
.236 addq.w    #8,d2
     addq.w    #1,-8(a5)
     cmp.w     #23,-8(a5)
     bcs.s     .238
;==================Draw vertical lines for board==================
;   for count = 0 to < MAXPLAYERS    should replace this with DrawBorder
     moveq    #4-1,d3
     moveq    #127,d2
     addq.b   #2,d2     ;VLINL+1
  ;----Move(BdRp,(count*VLINS)+VLINL+1,VLINT)
.246 move.w   d2,d0
     moveq    #13,d1    ;VLINT
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---Draw(BdRp,(count*VLINS)+VLINL+1,VLINB)
     moveq    #0,d1
     move.b   #199,d1
     move.w   d2,d0
     movea.l  a2,a1
     jsr      _LVODraw(a6)
  ;---Move(BdRp,(count*VLINS)+VLINL,VLINT)
     moveq    #13,d1
     subq.w   #1,d2
     move.w   d2,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---Draw(BdRp,(count*VLINS)+VLINL,VLINB)
     move.w   d2,d0
     moveq    #0,d1
     move.b   #199,d1
     movea.l  a2,a1
     jsr      _LVODraw(a6)
     moveq    #91,d1      ;VLINS+1
     add.w    d1,d2       ;next line y position
     Dbra     d3,.246
;=======================Blank players names======================
   ;---SetDrMd = JAM2
     moveq    #1,d0
     movea.l  a2,a1
     jsr      _LVOSetDrMd(a6)
     moveq    #4-1,d3
     move.w   #135,d2
  ;---Move(BdRp, DOTL - (2*SPACEW) + (DOTS*count), TEXTT+2)
.249 moveq    #22,d1
     move.w   d2,d0
     movea.l  a2,a1
     jsr      _LVOMove(a6)
  ;---Output 8 spaces
     moveq    #8,d0
     lea      Spaces,a0
     movea.l  a2,a1
     jsr      _LVOText(a6)
     moveq    #90,d1
     add.w    d1,d2
     Dbra     d3,.249
;================Set initial 5 die images to Sixes=======================
     moveq    #5-1,d3
     moveq    #20,d2    ;BLANKT
     movea.l  _IntuitionBase,a6
   ;DrawImage (BdRp, &Blank, BLANKL, (BLANKS*count) + BLANKT)
.252 move.w   d2,d1
     move.w   #530,d0
     lea      BlankImage,a1
     movea.l  a2,a0
     movem.l  d0/d1/a0,-(sp)
     jsr      _LVODrawImage(a6)
  ;DrawImage (BdRp, &DieImage[5], BLANKL, (BLANKS*count) + BLANKT)
     movem.l  (sp)+,d0/d1/a0
     lea      Die6Image,a1
     jsr      _LVODrawImage(a6)
     moveq    #31,d1    ;BLANKS
     add.w    d1,d2
     Dbra     d3,.252
;================use time to seed random number generator============
   ;---CurrentTime(&Seconds,&Micros)
     lea      -8(a5),a1
     lea      -4(a5),a0
     jsr      _LVOCurrentTime(a6)
   ;---seed random generator with Micros
     move.l   -8(a5),RAND
     movem.l  (sp)+,d2/d3/a2/a3/a4
     unlk     a5
     rts

   XDEF   Cleanup
Cleanup:
  ;----do_sound(NULL,0)
    clr.l   -(sp)
    clr.l   -(sp)
    jsr      _do_sound
    addq.l   #8,sp
  ;---Close BdWdw window
noM movea.l  _IntuitionBase,a6
    move.l   ScoreWindow,d0
    beq.s    noW
    movea.l  d0,a0
    jsr      _LVOCloseWindow(a6)
  ;---Close BdScr screen
noW move.l   Screen,d0
    beq.s    NoS
    movea.l  d0,a0
    jsr      _LVOCloseScreen(a6)
  ;---Close Graphics and Intuition Libraries
NoS movea.l  _SysBase,a6
    move.l   _GfxBase,d0
    beq.s    noG
    movea.l  d0,a1
    jsr      _LVOCloseLibrary(a6)
noG move.l   _IntuitionBase,d0
    beq.s    noI
    movea.l  d0,a1
    jsr      _LVOCloseLibrary(a6)
noI clr.l    -(sp)
    jsr      _exit

  ;MANX need this section directive
  ;   SECTION  YahtzeeData,DATA

   XDEF     _GfxBase,_IntuitionBase,Screen,ScoreWindow,_BackWdw,_WVPort
_IntuitionBase dc.l 0
_GfxBase       dc.l 0
Screen         dc.l 0
FontPtr        dc.l 0
ScoreWindow    dc.l 0
RastPort       dc.l 0
_BackWdw       dc.l 0
_WVPort        dc.l 0

;=========================== NEWSCREEN STRUCTURE =========================
   XDEF   NewScreen
NewScreen:
   dc.w   0,0,640,200 ;LEFTEDGE,TOPEDGE,WIDTH,HEIGHT
   dc.w   3
   dc.b   5,2
   dc.w   $8000
   dc.w   15
   dc.l   TextAttr
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000

;============================ NEWWINDOW STRUCTURES =======================
   XDEF   NewWindow
NewWindow:
   dc.w   0,0,640,200
   dc.b   6,3
 ;---IDCMPFlags = CLOSEWINDOW | GADGETUP | MENUPICK
   dc.l   $0340
   dc.l   $180c
   dc.l   _ScoreGadget
   dc.l   $0000
   dc.l   NBTitle
   dc.l   $0000
   dc.l   $0000
   dc.w   0,0,0,0
   dc.w   15

;=========================== BORDER FOR SCORECARD =========================
HLINR equ 489
VLINT equ 13
VLINB equ 199
HLINL equ 1

   XDEF   _boardlines
_boardlines:  dc.w  HLINR,VLINT,HLINR,VLINB,HLINL-1,VLINB,HLINL-1,VLINT
              dc.w  HLINL,VLINT,HLINL,VLINB,HLINR-1,VLINB,HLINR-1,VLINT

;======================== PEN COLORS (COLORMAP) =====================
BGRP equ 0
REDP equ 1
GRNP equ 2
YELP equ 3
FGRP equ 4
PURP equ 5
BLUP equ 6
BLKP equ 7

   XDEF  _colormap
_colormap:
   dc.w   $FFF   ;WHITE  (background color)
   dc.w   $F00   ;RED    (color of window-close box)
   dc.w   $0F0   ;GREEN  (color of menu title)
   dc.w   $FF0   ;YELLOW (color of window-close dot)
   dc.w   $0B1   ;FOREST GREEN (scores)
   dc.w   $91F   ;PURPLE (color of possible scores)
   dc.w   $00F   ;BLUE
   dc.w   $000   ;BLACK

;==================== TEXT ATTRIBUTE STRUCTURE (Topaz 9) =================
   XDEF   TextAttr
TextAttr:
   dc.l   FontName
   dc.w   9
   dc.b   0
   dc.b   1

;================== IMAGE STRUCTURE FOR BLANKING DIE ================
   XDEF   BlankImage
BlankImage:
   dc.w   0,0,56,23
   dc.w   1
   dc.l   $0000
   dc.b   0,1
   dc.l   $0000

;================= IMAGE STRUCTURES FOR 6 FACES OF A DIE ==================
   XDEF   Die1Image,Die2Image,Die3Image,Die4Image,Die5Image,Die6Image
Die1Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   OneSpot
   dc.b   2,1
   dc.l   $0000

Die2Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   TwoSpot
   dc.b   2,1
   dc.l   $0000

Die3Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   ThreeSpot
   dc.b   2,1
   dc.l   $0000

Die4Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   FourSpot
   dc.b   2,1
   dc.l   $0000

Die5Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   FiveSpot
   dc.b   2,1
   dc.l   $0000

Die6Image:
   dc.w   4,2,48,19
   dc.w   1
   dc.l   SixSpot
   dc.b   2,1
   dc.l   $0000

;================== GADGET STRUCTURES FOR 5 DICE ==================
   XDEF   DieGadg1
DieGadg1:
   dc.l   DieGadg2
   dc.w   530,20,56,23
   dc.w   6          ;Flags = GADGIMAGE | GADGHIMAGE
   dc.w   0          ;Activation is initially none. Only enabled when rolled
   dc.w   1          ;BOOLGADGET type
   dc.l   Die6Image  ;Selected Image is changed depending on die roll
   dc.l   BlankImage ;DeSelected Image is always Blank
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   1
   dc.l   0

DieGadg2:
   dc.l   DieGadg3
   dc.w   530,51,56,23
   dc.w   6
   dc.w   0
   dc.w   1
   dc.l   Die6Image
   dc.l   BlankImage
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   2
   dc.l   $0000

DieGadg3:
   dc.l   DieGadg4
   dc.w   530,82,56,23
   dc.w   6
   dc.w   0
   dc.w   1
   dc.l   Die6Image
   dc.l   BlankImage
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   3
   dc.l   $0000

DieGadg4:
   dc.l   DieGadg5
   dc.w   530,113,56,23
   dc.w   6
   dc.w   0
   dc.w   1
   dc.l   Die6Image
   dc.l   BlankImage
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   4
   dc.l   $0000

DieGadg5:
   dc.l   0
   dc.w   530,144,56,23
   dc.w   6
   dc.w   0
   dc.w   1
   dc.l   Die6Image
   dc.l   BlankImage
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   5
   dc.l   $0000

   XDEF   _RollText
_RollText:
   dc.b   2
   dc.b   1
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   7
   dc.l   TextAttr
   dc.l   ROLL
   dc.l   $0000

ROLL dc.b ' ROLL',0

   XDEF   RollGadget
RollGadget:
   dc.l   DieGadg1
   dc.w   530,175,56,23
   dc.w   260
   dc.w   1
   dc.w   1
   dc.l   BlankImage
   dc.l   $0000
   dc.l   _RollText
   dc.l   $0000
   dc.l   $0000
   dc.w   6
   dc.l   0

   XDEF   _ScoreGadget
_ScoreGadget:
   dc.l   RollGadget
   dc.w   132,29,84,136
   dc.w   3
   dc.w   1
   dc.w   1
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.l   $0000
   dc.w   7
   dc.l   0

   XDEF   _AboutText
_AboutText:
   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   9
   dc.l   TextAttr
   dc.l   .4+0
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   18
   dc.l   TextAttr
   dc.l   .4+46
   dc.l   _AboutText

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   27
   dc.l   TextAttr
   dc.l   .4+92
   dc.l   _AboutText+20

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   36
   dc.l   TextAttr
   dc.l   .4+138
   dc.l   _AboutText+40

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   45
   dc.l   TextAttr
   dc.l   .4+184
   dc.l   _AboutText+60

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   54
   dc.l   TextAttr
   dc.l   .4+230
   dc.l   _AboutText+80

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   63
   dc.l   TextAttr
   dc.l   .4+276
   dc.l   _AboutText+100

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   72
   dc.l   TextAttr
   dc.l   .4+322
   dc.l   _AboutText+120

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   81
   dc.l   TextAttr
   dc.l   .4+368
   dc.l   _AboutText+140

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   90
   dc.l   TextAttr
   dc.l   .4+414
   dc.l   _AboutText+160

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   20
   dc.w   98
   dc.l   TextAttr
   dc.l   .4+460
   dc.l   _AboutText+180

;=========================== TEXT ============================
   XDEF  _textline
_textline:
   dc.l   SC1
   dc.l   SC2
   dc.l   SC3
   dc.l   SC4
   dc.l   SC5
   dc.l   SC6
   dc.l   SC7
   dc.l   SC8
   dc.l   SC9
   dc.l   SC10
   dc.l   SC11
   dc.l   SC12
   dc.l   SC13
   dc.l   SC14
   dc.l   SC15
   dc.l   SC16
   dc.l   SC17
   dc.l   SC18
   dc.l   SC19
   dc.l   SC20
   dc.l   SC21
   dc.l   SC22
   dc.l   SC23
   dc.l   SC24
   dc.l   SC25
   dc.l   SC26
   dc.l   SC27

   XDEF   _InstructText
_InstructText:
   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   9
   dc.l   TextAttr
   dc.l   .5+0
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   18
   dc.l   TextAttr
   dc.l   .5+47
   dc.l   _InstructText

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   27
   dc.l   TextAttr
   dc.l   .5+94
   dc.l   _InstructText+20

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   36
   dc.l   TextAttr
   dc.l   .5+141
   dc.l   _InstructText+40

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   45
   dc.l   TextAttr
   dc.l   .5+188
   dc.l   _InstructText+60

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   54
   dc.l   TextAttr
   dc.l   .5+235
   dc.l   _InstructText+80

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   63
   dc.l   TextAttr
   dc.l   .5+282
   dc.l   _InstructText+100

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   72
   dc.l   TextAttr
   dc.l   .5+329
   dc.l   _InstructText+120

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   81
   dc.l   TextAttr
   dc.l   .5+376
   dc.l   _InstructText+140

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   90
   dc.l   TextAttr
   dc.l   .5+423
   dc.l   _InstructText+160

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   99
   dc.l   TextAttr
   dc.l   .5+470
   dc.l   _InstructText+180

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   108
   dc.l   TextAttr
   dc.l   .5+517
   dc.l   _InstructText+200

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   117
   dc.l   TextAttr
   dc.l   .5+564
   dc.l   _InstructText+220

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   16
   dc.w   126
   dc.l   TextAttr
   dc.l   .5+611
   dc.l   _InstructText+240

   XDEF   _OKText
_OKText:
   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   6
   dc.w   3
   dc.l   TextAttr
   dc.l   .6
   dc.l   $0000

.6 dc.b   32,80,114,111,99,101,101,100,32,0

   XDEF   _Menu0IText
_Menu0IText:
   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   .7+0
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   .7+22
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   .7+44
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   .7+66
   dc.l   $0000

   XDEF   _Menu1IText
_Menu1IText:
   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   INSTR
   dc.l   $0000

   dc.b   6
   dc.b   0
   dc.b   1
   dc.b   0
   dc.w   0
   dc.w   0
   dc.l   TextAttr
   dc.l   ABOUT
   dc.l   $0000

   XDEF   _Menu0Item
_Menu0Item:
   dc.l   _Menu0Item+34
   dc.w   0,0,210,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu0IText
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1

   dc.l   _Menu0Item+68
   dc.w   0,9,210,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu0IText+20
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1
 
   dc.l   _Menu0Item+102
   dc.w   0,18,210,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu0IText+40
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1

   dc.l   $0000
   dc.w   0,27,210,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu0IText+60
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1

   XDEF   _Menu1Item
_Menu1Item:
   dc.l   _Menu1Item+34
   dc.w   0,0,140,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu1IText
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1

   dc.l   $0000
   dc.w   0,9,140,9
   dc.w   82
   dc.l   $0000
   dc.l   _Menu1IText+20
   dc.l   $0000
   dc.b   0,0
   dc.l   $0000
   dc.w   -1

   XDEF   _BdMenu
_BdMenu:
   dc.l   _BdMenu+30
   dc.w   40
   dc.w   0
   dc.w   90
   dc.w   0
   dc.w   1
   dc.l   START
   dc.l   _Menu0Item
   ds.b   8

   dc.l   $0000
   dc.w   160
   dc.w   0
   dc.w   130
   dc.w   0
   dc.w   1
   dc.l   INFO
   dc.l   _Menu1Item
   ds.b   8

SC1  dc.b   'Players'
SC2:
SC9:
SC12:
SC20:
SC22:
     dc.b   0
SC3  dc.b   'Aces       ',0
SC4  dc.b   'Twos       ',0
SC5  dc.b   'Threes     ',0
SC6  dc.b   'Fours      ',0
SC7  dc.b   'Fives      ',0
SC8  dc.b   'Sixes      ',0
SC10 dc.b   'Upper Total',0
SC11 dc.b   'Bonus      ',0
SC13 dc.b   '3 of a Kind',0
SC14 dc.b   '4 of a Kind',0
SC15 dc.b   'Full House ',0
SC16 dc.b   'Sm Straight',0
SC17 dc.b   'Lg Straight',0
SC18 dc.b   'Yacht     ',0
SC19 dc.b   'Yarboro    ',0
SC21 dc.b   'Lower Total',0
SC23 dc.b   'Grand Total',0
SC24 dc.b   '  One   ',0
SC25 dc.b   '  Two   ',0
SC26 dc.b   ' Three  ',0
SC27 dc.b   '  Four  ',0

.4 dc.b  '                                             ',0
   dc.b  '                    YachtC                   ',0
   dc.b  '       Copyright 1985 by Sheldon Leemon      ',0
   dc.b  '                                             ',0
   dc.b  '  You may copy and distribute this program   ',0
   dc.b  '  freely (i.e. for no money), but any kind   ',0
   dc.b  '   of commercial exploitation is a no-no.    ',0
   dc.b  '  ****   Version 4.0  by Jeff Glatt   ****   ',0
   dc.b  '  Based on a version by Mark Schretlen with  ',0
   dc.b  '   "scales" sound sources by Steve Bennett.  ',0
   dc.b  '                                             ',0

.5 dc.b  '                                              ',0
   dc.b  '                 Instructions                 ',0
   dc.b  '                                              ',0
   dc.b  '  To start game, select 1-4 Player game from  ',0
   dc.b  '  the Project menu.  Each  player gets up to  ',0
   dc.b  '  3 rolls of the  dice to make the best hand  ',0
   dc.b  '  possible.  Click on the  dice you  wish to  ',0
   dc.b  '  change, then click on the button below the  ',0
   dc.b  '  dice to roll.  If you  are satisfied  with  ',0
   dc.b  '  your hand, and wish to score, click on the  ',0
   dc.b  '  button  without  blanking  any  dice.  All  ',0
   dc.b  '  possible scores will appear in  purple  on  ',0
   dc.b  '  the scorepad.  Click on the one you want.   ',0
   dc.b  '                                              ',0

.7 dc.b  ' Start 1-Player Game ',0
   dc.b  ' Start 2-Player Game ',0
   dc.b  ' Start 3-Player Game ',0
   dc.b  ' Start 4-Player Game ',0

INSTR dc.b  ' Instructions ',0
ABOUT dc.b  ' About YachtC ',0
  
START dc.b  ' Start ',0
INFO  dc.b  ' Information ',0
  
FontName      dc.b 'topaz.font',0
IntuitionName dc.b 'intuition.library',0
GfxName       dc.b 'graphics.library',0

NBTitle dc.b '                     YachtC (V4.0)               ',0
Spaces dc.b '                             ',0

   END

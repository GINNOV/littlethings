   XREF   _LVOAllocMem,_LVOFreeMem
   XREF   _LVOFreeSignal,_LVOAllocSignal
   XREF   _LVOOffGadget,_LVOOnGadget,_LVOAddGadget,_LVORemoveGadget
   XREF   _LVOTranslate
   XREF   _LVOAbortIO,_LVOSendIO,_LVODoIO
   XREF   _LVOAutoRequest
   XREF   _LVOWaitBOVP
   XREF   _LVODisplayBeep
   XREF   _LVOReplyMsg,_LVOGetMsg,_LVOPutMsg,_LVOWait
   XREF   _LVOSetMenuStrip
   XREF   _LVORefreshGadgets
   XREF   _LVORectFill,_LVOMove,_LVODraw,_LVOText
   XREF   _LVOSetAPen
   XREF   _LVOOpenWindow,_LVOCloseWindow
   XREF   _LVOFindTask
   XREF   _LVOOpenDevice,_LVOCloseDevice
   XREF   _LVOOpenLibrary,_LVOCloseLibrary

   XREF   _SysBase,_DOSBase,_exit  ;from StartUp.o

; This program is probably copyright Commodore-Amiga.  It was mailed
; to me directly by Bruce Barrett at Commodore-Amiga in response to a
; to a question about a previous version's copyright status.  I
; therefore assume that it is Commodore-Amiga's intention that this
; program be freely redistributable.  Fred Fish, 3-Jan-86.
;
; This program was written to show the use of gadgets in a
; window. Thus one menu, one auto requester, but lots of gadget types.
; For the sake of example, two mutual exclude gadgets
; (female/male) are shown that perform a function that might
; be better implemented as a toggle image, in a manner similar
; to that shown in the inflection Mode gadget.
; Again for the sake of example, the proportional gadgets
; are generated dynamicly (that is, copied from a template and
; filled in), whereas most gadgets are declared staticly in
; the struct declaration, which saves the initialization code space.
; Lastly, for the sake of example, this program is extremely
; verbose in the way of comments. Hope you don't mind.
;
; Written by David M Lucas.

; Pen numbers to draw gadget borders/images/text with
;REDP equ  3        ; color in register 3 once was red
;BLKP equ  2        ; color in register 2 was black
;WHTP equ  1        ; color in register 1 was white
;BLUP equ  0        ; color in register 0 was blue

   XDEF   open_libs
open_libs:
       movea.l  _SysBase,a6
;-------Open Intuition--------
       moveq    #33,d0            ;VERSION #33
       lea      IntuitionTitle,a1
       jsr      _LVOOpenLibrary(a6)
       move.l   d0,_IntuitionBase
       beq.s    errLib
;----Open Graphics--------
       moveq    #33,d0            ;VERSION #33
       lea      GraphicsTitle,a1
       jsr      _LVOOpenLibrary(a6)
       move.l   d0,_GfxBase
       beq.s    errLib
;----Open Graphics--------
       moveq    #33,d0            ;VERSION #33
       lea      TranslatorTitle,a1
       jsr      _LVOOpenLibrary(a6)
       move.l   d0,_TranslatorBase
errLib rts

   XDEF   _main
_main:
    link     a5,#-14
;=======Open those libraries that the program uses directly======
    bsr.s    open_libs
    bne.s    OP
.7  bsr      exit_program     ;never returns
;=======Open the Narrator Device========
OP  lea      VoiceIOB,a1
    movea.l  a1,a2
    moveq    #0,d0
    moveq    #0,d1
    lea      Narrator,a0
    jsr      _LVOOpenDevice(a6)
    move.b   d0,_NarratorOpenError
    bne.s    .7
;=====Copy the VoiceIOB defaults to MouthIO, and initialize a few fields=====
    lea      MouthIO,a0
    movea.l  a0,a1
    moveq    #17-1,d0
cpy move.l   (a2)+,(a0)+
    Dbra     d0,cpy
    move.w   (a2),(a0)
  ;----Store the address of ReadPort
    move.l   #ReadPort,14(a1)
  ;----Change the Command to CMD_READ (instead of CMD_WRITE)
    move.w   #2,28(a1)
;======Now allocate memory accessable by the chips for images======
    bsr      get_chip_mem
    beq.s    .7
;=======Allocate signals/setup Talk and Read ports=========
    moveq    #-1,d0
    movea.l  _SysBase,a6
    jsr      _LVOAllocSignal(a6)
    move.b   d0,TalkPort+15
    bmi.s    .7
    suba.l   a1,a1
    jsr      _LVOFindTask(a6)
    move.l   d0,TalkPort+16
    move.l   d0,ReadPort+16
    moveq    #-1,d0
    jsr      _LVOAllocSignal(a6)
    move.b   d0,ReadPort+15
    bmi.s    .7
;========Open the ControlWindow===========
    movea.l  _IntuitionBase,a6
    move.l   _FaceWindow,d0
    bne.s    .49
;----------Open the Window----------------
    lea      _NewControlWindow,a0
    jsr      _LVOOpenWindow(a6)
    move.l   d0,_ControlWindow
    beq      .7
    movea.l  d0,a0
    move.l   50(a0),RastPort
;-----Attach Menu Strip to window---------
    ;WindowPtr in a0
    lea      Menu0,a1
    jsr      _LVOSetMenuStrip(a6)
;=======fill background of window=========
.49 moveq    #2,d0
    movea.l  RastPort,a1
    movea.l  _GfxBase,a6
    jsr      _LVOSetAPen(a6)
    movea.l  _ControlWindow,a0
    moveq    #0,d3
    move.w   114(a0),d3
    moveq    #0,d2
    move.w   112(a0),d2
    moveq    #0,d1
    moveq    #0,d0
    movea.l  50(a0),a1
    jsr      _LVORectFill(a6)
 ;----RefreshGadgets
    suba.l   a2,a2
    movea.l  _ControlWindow,a1
    lea      PropGadget3,a0
    movea.l  _IntuitionBase,a6
    jsr      _LVORefreshGadgets(a6)
;====================IDCMP MAIN LOOP==============================
;---Wait for a message sent to ControlWindow's, FaceWindow's, VoiceIOB's
;   (TalkPort), or MouthIO's (ReadPort) message port
.53 move.l   _ControlWindow,a0
    move.l   86(a0),a1
    moveq    #0,d0
    move.b   15(a1),d1
    Bset.l   d1,d0
    move.l   _FaceWindow,a0
    move.l   86(a0),a1
    move.b   15(a1),d1
    Bset.l   d1,d0
    movea.l  VoiceIOB+14,a0
    move.b   15(a0),d1
    Bset.l   d1,d0
    movea.l  MouthIO+14,a0
    move.b   15(a0),d1
    Bset.l   d1,d0
    movea.l  _SysBase,a6
    jsr      _LVOWait(a6)
    move.l   d0,-4(a5)
;================now check to see to what we owe the intrusion========
  ;---Check for message from ControlWindow
    move.l   _ControlWindow,a0
    move.l   86(a0),a1
    move.b   15(a1),d1
    Bclr.l   d1,d0
    beq      .54
  ;----Get the message
.55 movea.l  _ControlWindow,a1
    movea.l  86(a1),a0
    movea.l  _SysBase,a6
    jsr      _LVOGetMsg(a6)
    move.l   d0,_MyIntuiMessage
    beq.s    .54
  ;-----Get all the needed info and give message back
    movea.l  d0,a1
    move.l   20(a1),-(sp)     ;Class
    move.w   24(a1),-10(a5)   ;Code
    move.l   28(a1),-14(a5)   ;IAddress
    jsr      _LVOReplyMsg(a6)
    move.l   (sp)+,d0
    sub.l    #64,d0
    beq.s    .60
    sub.l    #192,d0
    beq.s    .59
    sub.l    #256,d0
    bne.s    .64
;================case CLOSEWINDOW:================
  ;---Empty the window's message port
.61 movea.l  _SysBase,a6
.LL movea.l  _ControlWindow,a1
    movea.l  86(a1),a0
    jsr      _LVOGetMsg(a6)
    move.l   d0,d1
    beq      .7
    move.l   d0,a1
    jsr      _LVOReplyMsg(a6)
    bra.s    .LL
;===============case MENUPICK:===================
.59 movea.l  _ControlWindow,a0
    move.w   -10(a5),d0
    bsr      handle_menu
    bra.s    .55
;==============case GADGETUP: reply, then process==========
.60 movea.l  -14(a5),a1
    bsr      handle_up
    bra      .55
;=================default:==================
.64 bra      .55
;=======Check for activity in FaceWindow=============
.54 movea.l  _FaceWindow,a0
    movea.l  86(a0),a1
    move.b   15(a1),d1
    move.l   -4(a5),d0
    Bclr.l   d1,d0
    beq.s    .65
.66 movea.l  _FaceWindow,a1
    movea.l  86(a1),a0
    movea.l  _SysBase,a6
    jsr      _LVOGetMsg(a6)
    move.l   d0,_MyIntuiMessage
    beq.s    .65
    move.l   d0,a1
    move.l   20(a1),d0
    subq.l   #1,d0
    beq.s    .70
    subq.l   #1,d0
    beq.s    .72
    sub.l    #254,d0
    bne.s    .73
;===============case MENUPICK:================
.71 movea.l  _FaceWindow,a0
    move.w   24(a1),d0
    bsr      handle_menu
   ; bra.s    .70
;===============case SIZEVERIFY:==============
.70:
;===============DEFAULT:=====================
.73 movea.l  _MyIntuiMessage,a1
    movea.l  _SysBase,a6
    jsr      _LVOReplyMsg(a6)
    bra.s    .66
;==============case NEWSIZE: Don't reply until processed=======
.72 bsr      draw_face
    bra.s    .70
;=============A voice SendIO (Write) has completed============
.65 movea.l  _IntuitionBase,a6
    move.l   VoiceIOB+14,a0
    move.b   15(a0),d1
    move.l   -4(a5),d0
    Bclr.l   d1,d0
    beq      .74
;======Was it Sucessful? filter out the abort error======
    cmpi.b   #-2,VoiceIOB+31
    bne.s    .75
    clr.b    VoiceIOB+31
  ;----Check for error
.75 move.b   VoiceIOB+31,d0
    beq      .76
  ;-----flash this screen, if error
    movea.l  _ControlWindow,a1
    movea.l  46(a1),a0
    jsr      _LVODisplayBeep(a6)
  ;=====let user see where phoneme string was bad.
  ;------Remove PhonStrGadget
    lea      _PhonStrGadget,a1
    movea.l  _ControlWindow,a0
    jsr      _LVORemoveGadget(a6)
    move.w   d0,_i
;move the cursor to the error char
;PhonInfo.BufferPos = VoiceIOB's message.io_Actual -1
    move.l   VoiceIOB+32,d0
    subq.l   #1,d0
    move.w   d0,_PhonInfo+8
; assure cursor (error point) is shown in gad.
; within 29 (number of chars shown) of front
;if (VoiceIOB's message.io_Actual < 29)
;PhonInfo.DispPos = 0
;within 29 of end
    cmpi.l   #29,VoiceIOB+32
    bcc.s    .77
    clr.w    _PhonInfo+12
    bra.s    .78
;else if ((VoiceIOB's message.io_Length -
;VoiceIOB's message.io_Actual) < 29)
;PhonInfo.DispPos = VoiceIOB's message.io_Length
.77 move.l   VoiceIOB+36,d0
    move.l   d0,d1
    sub.l    VoiceIOB+32,d0
    cmpi.l   #29,d0
    bcc.s    .79
    subi.l   #29,d1
    move.w   d1,_PhonInfo+12
    bra.s    .78
;PhonInfo.DispPos = VoiceIOB's message.io_Actual - 15
.79 move.l   VoiceIOB+32,d0
    subi.l   #15,d0
    move.w   d0,_PhonInfo+12
  ;------Add PhonStrGadget
.78 moveq    #0,d0
    move.w   _i,d0
    lea      _PhonStrGadget,a1
    move.l   _ControlWindow,a0
    jsr      _LVOAddGadget(a6)
  ;------Refresh PhonStrGadget
    suba.l   a2,a2
    movea.l  _ControlWindow,a1
    lea      _PhonStrGadget,a0
    jsr      _LVORefreshGadgets(a6)
  ;----VoiceIOB's message.io_Error = 0
    clr.b    VoiceIOB+31
  ;----Turn on SpeakGadget
.76 suba.l   a2,a2
    movea.l  _ControlWindow,a1
    lea      _SpeakGadget,a0
    jsr      _LVOOnGadget(a6)
  ;----Turn on FaceGadget
    suba.l   a2,a2
    movea.l  _ControlWindow,a1
    lea      _FaceGadget,a0
    jsr      _LVOOnGadget(a6)
;==============A mouth DoIO (Read) has completed=============
.74 movea.l  MouthIO+14,a0
    move.l   -4(a5),d0
    move.b   15(a0),d1
    Bclr.l   d1,d0
    beq      .53
  ;
    movea.l  _GfxBase,a6
    movea.l  _FaceWindow,a0
    move.l   46(a0),a1          ;face window's screen
    lea      44(a1),a0          ;screen's viewport
    jsr      _LVOWaitBOVP(a6)
  ;----Set ForePen to white
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    moveq    #1,d0
    jsr      _LVOSetAPen(a6)
;RectFill(FaceWindow->RPort, 0, EyesBottom,
;Window's GZZWidth, Window's GZZHeight)
    movea.l  _FaceWindow,a0
    moveq    #0,d3
    move.w   114(a0),d3
    moveq    #0,d2
    move.w   112(a0),d2
    moveq    #0,d1
    move.w   _EyesBottom,d1
    moveq    #0,d0
    movea.l  50(a0),a1
    jsr      _LVORectFill(a6)
;if (MouthWMult == 0)
;LipWidth = mouth_io.width >> 1
    move.w   _MouthWMult,d1
    bne.s    .82
    moveq    #0,d0
    move.b   MouthIO+70,d0
    lsr.b    #1,d0
    move.w   d0,_LipWidth
    bra.s    .83
;LipWidth = mouth_io.width * MouthWMult
.82 moveq    #0,d0
    move.b   MouthIO+70,d0
    mulu     d1,d0
    move.w   d0,_LipWidth
;if (MouthHMult == 0)
;LipHeight = mouth_io.height >> 1
.83 move.w   _MouthHMult,d1
    bne.s    .84
    moveq    #0,d0
    move.b   MouthIO+71,d0
    lsr.b    #1,d0
    move.w   d0,_LipHeight
    bra.s    .85
;LipHeight = mouth_io.height * (MouthHMult)
.84 moveq    #0,d0
    move.b   MouthIO+71,d0
    mulu     d1,d0
    move.w   d0,_LipHeight
  ;----Set ForePen to Red
.85 movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    moveq    #3,d0
    jsr      _LVOSetAPen(a6)
;----Move to one corner of the mouth
    moveq    #0,d1
    move.w   _YMouthCenter,d1
    moveq    #0,d0
    move.w   _XMouthCenter,d0
    sub.w    _LipWidth,d0
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    jsr      _LVOMove(a6)
;======DRAW THE 4 LINE SEGMENTS THAT COMPRISE THE (OPEN) MOUTH=======
    moveq    #0,d1
    move.w   _YMouthCenter,d1
    sub.w    _LipHeight,d1
    moveq    #0,d0
    move.w   _XMouthCenter,d0
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    jsr      _LVODraw(a6)
    moveq    #0,d1
    move.w   _YMouthCenter,d1
    moveq    #0,d0
    move.w   _XMouthCenter,d0
    add.w    _LipWidth,d0
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    jsr      _LVODraw(a6)
    moveq    #0,d1
    move.w   _YMouthCenter,d1
    add.w    _LipHeight,d1
    moveq    #0,d0
    move.w   _XMouthCenter,d0
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    jsr      _LVODraw(a6)
    moveq    #0,d1
    move.w   _YMouthCenter,d1
    moveq    #0,d0
    move.w   _XMouthCenter,d0
    sub.w    _LipWidth,d0
    movea.l  _FaceWindow,a0
    movea.l  50(a0),a1
    jsr      _LVODraw(a6)
;the narrator will give an error when the write has completed and I've tried
;to read. I stop trying when that happens.
    lea      MouthIO,a1
    move.b   31(a1),d0  ;check io_Error
    bne      .53
    movea.l  _SysBase,a6
    jsr      _LVOSendIO(a6)
    bra      .53

;======================================================
; This handles the MENUpick. Since only 1 menu/subitem, make sure that
; menu # and item # are 0.
;
;handle_menu(code, w)
;            d0   a0

   XDEF   handle_menu
handle_menu:
    move.w   d0,d1
    andi.w   #$1F,d0
    bne.s    .92
    movem.l  d2/d3/a2/a3,-(sp)
    lsr.w    #5,d1
    andi.w   #$3F,d1
    bne.s    .92
    moveq    #47,d3
    moveq    #0,d2
    move.b   #280,d2
    moveq    #0,d1
    moveq    #0,d0
    lea      _OKIText,a3
    suba.l   a2,a2
    lea      _ReqText3,a1
    movea.l  _IntuitionBase,a6
    jsr      _LVOAutoRequest(a6)
    movem.l  (sp)+,d2/d3/a2/a3
.92 rts

;====================================================
; Handles a GADGETUP message.
;
;gadgetmessage(IAddress)
;                 a1

   XDEF   handle_up
handle_up:
;==========DECODE WHICH GADGET WAS SELECTED========
     lea      _FaceGadget,a0
     cmpa.l   a0,a1
     beq      FACE
     lea      _StopGadget,a0
     cmpa.l   a0,a1
     beq      STOP
     lea      _FemaleGadget,a0
     cmpa.l   a0,a1
     beq      FMG
     lea      _MaleGadget,a0
     cmpa.l   a0,a1
     beq      MG
     lea      _TranslateGadget,a0
     cmpa.l   a0,a1
     beq      TRAN
     lea      _SpeakGadget,a0
     cmpa.l   a0,a1
     beq      SPK
     lea      PropGadget0,a0
     cmpa.l   a0,a1
     beq      PRP0
     lea      PropGadget1,a0
     cmpa.l   a0,a1
     beq      PRP1
     lea      PropGadget2,a0
     cmpa.l   a0,a1
     beq      PRP2
     lea      PropGadget3,a0
     cmpa.l   a0,a1
     beq      PRP3
     lea      _ModeGadget,a0
     cmpa.l   a0,a1
     bne      .137
 ;ignore the _EnglStrGadget and _PhonStrGadget
;==============ModeGadget===================
   ;----if ModeGadget's Flags = SELECTED, then voiceIOB's mode = ROBOTIC0
     moveq    #1,d1
     move.b   13(a0),d0
     bmi.s    .101
   ;----Otherwise, mode = NATURALF0
     moveq    #0,d1
.101 move.w   d1,VoiceIOB+52
     rts
;=============FaceGadget===============
   ;----if FaceGadget's Flags = SELECTED, then open it. Otherwise, close it.
FACE movea.l  _IntuitionBase,a6
     move.b   13(a0),d0
     bpl.s    .105
    ;---VoiceIOB's mouths = 1
     move.b   #1,VoiceIOB+66  ;indicate that reads will be forthcoming
    ;----Open the FaceWindow
     lea      _NewFaceWindow,a0
     jsr      _LVOOpenWindow(a6)
     move.l   d0,_FaceWindow
     bne.s    .106
     bsr      exit_program
   ;----Attach the menu to the FaceWindow
.106 lea      Menu0,a1
     movea.l  d0,a0
     jsr      _LVOSetMenuStrip(a6)
   ;----Draw the face in the opened FaceWindow
     bsr      draw_face
     rts
   ;----FaceGadget was DESELECTED, so it must now be closed.
    ;-----VoiceIOB's mouths = 0
.105 clr.b    VoiceIOB+66
    ;---Store last Left, Top, Width, and Height for next open
     move.l   _FaceWindow,a0
     lea      _NewFaceWindow,a1
     move.w   4(a0),(a1)
     move.w   6(a0),2(a1)
     move.w   8(a0),4(a1)
     move.w   10(a0),6(a1)
     jsr      _LVOCloseWindow(a6)
     clr.l    _FaceWindow
     rts
;==========StopGadget==============
  ;----Abort the IO
STOP lea     VoiceIOB,a1
     movea.l _SysBase,a6
     jsr     _LVOAbortIO(a6)
  ;----reset VoiceIOB's message.io_Error
     clr.b   VoiceIOB+31
  ;----reset mouth_io.voice.message.io_Error
     clr.b   MouthIO+31
     rts
;=========FemaleGadget===============
; Since this program changes a flag that intuition expects
; only the user to change (SELECTED bit), this program has
; to remove, then change, then add this gadget. Then by
; passing the address of this gadget to RefreshGadgets(),
; only the gadgets from here to the start of the list will
; be refreshed, which minimizes the visible flash that
; RefreshGadgets() can introduce.
; If one of the two gadgets (female/male) is hit, toggle
; the selection of the other gadget (since the gadget hit
; was toggled by intuition when it was hit).
  ;----if FemaleGadget's Flags = SELECTED, then VoiceIOB's sex = FEMALE
FMG  movea.l  _IntuitionBase,a6
     moveq    #1,d1
     move.b   13(a0),d0
     bmi.s    .112
   ;---Otherwise VoiceIOB's sex = MALE
     moveq    #0,d1
.112 move.w   d1,VoiceIOB+54
   ;----Remove the MaleGadget
     lea      _MaleGadget,a1
     move.l   _ControlWindow,a0
     jsr      _LVORemoveGadget(a6)
   ;----MaleGadget's Flags = SELECTED
     Bchg.b   #7,_MaleGadget+13
   ;-----Add the MaleGadget
     lea      _MaleGadget,a1
     move.l   _ControlWindow,a0
     jsr      _LVOAddGadget(a6)
   ;-----Refresh the MaleGadget
REF  suba.l   a2,a2
     movea.l  _ControlWindow,a1
     lea      _MaleGadget,a0
     jsr      _LVORefreshGadgets(a6)
     rts
;===============MaleGadget=============
  ;----if MaleGadget's Flags = SELECTED, then VoiceIOB's sex = MALE
MG   movea.l  _IntuitionBase,a6
     moveq    #0,d1
     move.b   13(a0),d0
     bmi.s    .116
   ;-----Otherwise, VoiceIOB's sex = FEMALE
     moveq    #1,d1
.116 move.w   d1,VoiceIOB+54
   ;-----Remove the FemaleGadget
     lea      _FemaleGadget,a1
     move.l   _ControlWindow,a0
     jsr      _LVORemoveGadget(a6)
   ;----FemaleGadget's Flags = SELECTED
     Bchg.b   #7,_FemaleGadget+13
   ;----Add the FemaleGadget
     lea      _FemaleGadget,a1
     move.l   _ControlWindow,a0
     jsr      _LVOAddGadget(a6)
   ;---Refresh MaleGadget
     bra.s    REF
;===========Check for TranslateGadget==============
;  Since the program changes the contents of the string
;  gadgets' buffer and it's size, which is something else
;  intuition doesn't expect a program (as opposed to the
;  user) to do. The program must remove, then change, then
;  add this gadget, and then by passing the address of this
;  gadget to RefreshGadgets(), only the gadgets from here
;  to the start of the list will be refreshed, which
;  minimizes the visible flash that RefreshGadgets() can introduce.
   ;RemoveGadget the PhonStrGadget
TRAN lea      _PhonStrGadget,a1
     move.l   _ControlWindow,a0
     movea.l  _IntuitionBase,a6
     jsr      _LVORemoveGadget(a6)
     move.w   d0,-(sp)
     move.l   a6,-(sp)
  ;---Translate the EnglBuffer and put it into the PhonBuffer
     moveq    #0,d1
     move.w   _PhonInfo+10,d1
     lea      _PhonBuffer,a1
     moveq    #0,d0
     move.w   _EnglInfo+16,d0
     lea      _EnglBuffer,a0
     movea.l  _TranslatorBase,a6
     jsr      _LVOTranslate(a6)
     movea.l  (sp)+,a6
     move.b   d0,_TranslatorError
     beq.s    .120
  ;----flash this screen if an error in translating
     movea.l  _ControlWindow,a1
     movea.l  46(a1),a0
     jsr      _LVODisplayBeep(a6)
  ; Hey! NumChars includes the terminating NULL.
  ;/* This must be done. */
  ;PhonInfo.NumChars = VoiceIOB's message.io_Length + 1
.120 lea      VoiceIOB,a0
     lea      _PhonInfo,a1
     move.l   36(a0),d0
     addq.l   #1,d0
     move.w   d0,16(a1)
  ;if (PhonInfo.DispPos > VoiceIOB's message.io_Length)
  ;PhonInfo.DispPos = VoiceIOB's message.io_Length
     move.w   12(a1),d0
     sub.w    36(a0),d0
     bls.s    .121
     move.w   38(a0),12(a1)
  ;AddGadget(ControlWindow, &PhonStrGadget, i)
.121 moveq    #0,d0
     move.w   (sp)+,d0
     lea      _PhonStrGadget,a1
     move.l   _ControlWindow,a0
     jsr      _LVOAddGadget(a6)
  ;----Refresh PhonStrGadget
     suba.l   a2,a2
     movea.l  _ControlWindow,a1
     lea      _PhonStrGadget,a0
     jsr      _LVORefreshGadgets(a6)
     rts
;=================SpeakGadget=================
  ;----Turn off the SpeakGadget
SPK  movea.l  _IntuitionBase,a6
     suba.l   a2,a2
     movea.l  _ControlWindow,a1
     lea      _SpeakGadget,a0
     jsr      _LVOOffGadget(a6)
  ;----Turn off the FaceGadget
     suba.l   a2,a2
     movea.l  _ControlWindow,a1
     lea      _FaceGadget,a0
     jsr      _LVOOffGadget(a6)
   ;VoiceIOB's message.io_Length = # of chars in PhonBuffer
     lea      _PhonBuffer,a0
     move.l   a0,d0
len  move.b   (a0)+,d1
     bne.s    len
     subq.l   #1,a0
     suba.l   d0,a0
     lea      VoiceIOB,a1
     move.l   a0,36(a1)
   ;----Send the IO
     movea.l  _SysBase,a6
     jsr      _LVOSendIO(a6)
   ;----if VoiceIOB's mouths = 1
     cmpi.b   #1,VoiceIOB+66
     bne.s    .137
   ;mouth_io's voice.message.io_Error = 0
     lea      MouthIO,a1
     clr.b    31(a1)
   ;----Send the mouth IO
     jsr      _LVOSendIO(a6)
     rts
;===============Props[0]==============
   ;-----PropRange = RNGFREQ
PRP0 move.w   #23001,d1
  ;VoiceIOB's sampfreq = (( (PropInfo[0].HorizPot >> 1)
  ;* PropRange) >> 15) + MINFREQ
     move.w   PropInfo0+2,d0
     lsr.w    #1,d0
     mulu     d1,d0
     moveq    #15,d1
     lsr.l    d1,d0
     addi.w   #5000,d0
     move.w   d0,VoiceIOB+64
     rts
;==================Props[1]============
   ;-----PropRange = RNGRATE
;VoiceIOB's rate = (((PropInfo[1].HorizPot >> 1)
;* PropRange) >> 15) + MINRATE
PRP1 move.w   PropInfo1+2,d0
     lsr.w    #1,d0
     mulu     #361,d0
     moveq    #15,d1
     lsr.l    d1,d0
     addi.w   #40,d0
     move.w   d0,VoiceIOB+48
     rts
;================Props[2]================
  ;-----PropRange = RNGPITCH
  ;VoiceIOB's pitch = (((PropInfo[2].HorizPot >> 1)
  ;* PropRange) >> 15) + MINPITCH
PRP2 move.w   PropInfo2+2,d0
     lsr.w    #1,d0
     mulu     #256,d0
     moveq    #15,d1
     lsr.l    d1,d0
     addi.w   #65,d0
     move.w   d0,VoiceIOB+50
     rts
;================Props[3]================
  ;----PropRange = RNGVOL
  ;VoiceIOB's volume = (((PropInfo[3].HorizPot >> 1)
  ;* PropRange) >> 15) + MINVOL
PRP3 moveq    #65,d1
     move.w   PropInfo3+2,d0
     lsr.w    #1,d0
     mulu     d1,d0
     moveq    #15,d1
     lsr.l    d1,d0
     move.w   d0,VoiceIOB+62
.137 rts

;=============================================================
; This calculates variables used to draw the mouth and eyes, as well as
; redrawing the face. Proportionality makes it very wierd, but it's
; wierder if you don't use a GimmeZeroZero window and GZZWidth/GZZHeight.

   XDEF   draw_face
draw_face:
     movea.l  _FaceWindow,a0
;----set mouth center position based on size of window
     move.w   112(a0),d0      ;Window's current width
     lsr.w    #1,d0           ;divide by 2
     move.w   d0,_XMouthCenter
;----set left edge position of left eye based on size of window
     lsr.w    #1,d0
     move.w   d0,_EyesLeft    ;width/4
;----multiplier for mouth width
;   MouthWMult = GZZWidth/16
     lsr.w    #4,d0
     move.w   d0,_MouthWMult
;EyesTop = GZZHeight/4 - GZZHeight/16
     move.w   114(a0),d0      ;Window's current height
     lsr.w    #2,d0           ;divide by 4
     move.w   d0,d1
     lsr.w    #2,d1           ;divide by 16
     sub.w    d1,d0
     move.w   d0,_EyesTop
;EyesBottom = EyesTop + (GZZHeight/8) + 1
     move.w   114(a0),d0
     move.w   d0,d1
     lsr.w    #3,d0
     add.w    _EyesTop,d0
     addq.w   #1,d0
     move.w   d0,_EyesBottom
;yaw = GZZHeight - EyesBottom
     sub.w    _EyesBottom,d1
     move.w   d1,_yaw
     move.w   d1,d0
;YMouthCenter = (yaw/2) + EyesBottom
     lsr.w    #1,d1
     add.w    _EyesBottom,d1
     move.w   d1,_YMouthCenter
;MouthHMult = yaw/32
     lsr.w    #5,d0
     move.w   d0,_MouthHMult
;==========Set ForePen to White=============
     movea.l  _FaceWindow,a0
     movea.l  50(a0),a1
     movea.l  _GfxBase,a6
     moveq    #1,d0
     jsr      _LVOSetAPen(a6)
;---Fill the FaceWindow's background
     movea.l  _FaceWindow,a0
     moveq    #0,d3
     move.w   114(a0),d3
     moveq    #0,d2
     move.w   112(a0),d2
     moveq    #0,d1
     moveq    #0,d0
     movea.l  50(a0),a1
     jsr      _LVORectFill(a6)
;=============Set ForePen to Blue============
     movea.l  _FaceWindow,a0
     movea.l  50(a0),a1
     moveq    #0,d0
     jsr      _LVOSetAPen(a6)
 ;----Fill in the eyes
     movea.l  _FaceWindow,a0
     moveq    #0,d3
     move.w   114(a0),d3
     lsr.w    #3,d3
     add.w    _EyesTop,d3
     moveq    #0,d2
     move.w   112(a0),d2
     lsr.w    #3,d2
     add.w    _EyesLeft,d2
     moveq    #0,d1
     move.w   _EyesTop,d1
     moveq    #0,d0
     move.w   _EyesLeft,d0
     movea.l  50(a0),a1
     jsr      _LVORectFill(a6)
     movea.l  _FaceWindow,a0
     moveq    #0,d2
     move.w   112(a0),d2
     lsr.w    #1,d2
     move.l   d2,d0
     move.w   d2,d1
     lsr.w    #2,d1
     add.w    d1,d2
     add.w    d1,d2
     add.w    d1,d0
     moveq    #0,d1
     move.w   _EyesTop,d1
     moveq    #0,d3
     move.w   114(a0),d3
     lsr.w    #3,d3
     add.w    d1,d3
     movea.l  50(a0),a1
     jsr      _LVORectFill(a6)
  ;----Set ForePen to Red
     movea.l  _FaceWindow,a0
     movea.l  50(a0),a1
     moveq    #3,d0
     jsr      _LVOSetAPen(a6)
  ;---draw the mouth (as a straight line - mouth not open)
     moveq    #0,d0
     move.w   _XMouthCenter,d0
     movea.l  _FaceWindow,a0
     move.w   112(a0),d1
     lsr.w    #3,d1
     sub.w    d1,d0
     moveq    #0,d1
     move.w   _YMouthCenter,d1
     movea.l  50(a0),a1
     jsr      _LVOMove(a6)
     moveq    #0,d0
     move.w   _XMouthCenter,d0
     movea.l  _FaceWindow,a0
     move.w   112(a0),d1
     lsr.w    #3,d1
     add.w    d1,d0
     moveq    #0,d1
     move.w   _YMouthCenter,d1
     movea.l  50(a0),a1
     jsr      _LVODraw(a6)
     rts

;============================================================
; Deallocate any memory, and close all of the windows/screens/devices/
; libraries in reverse order to make things work smoothly. And be sure to
; check that the open/allocation was successful before closing/deallocating.

   XDEF   exit_program
exit_program:
     movea.l  _SysBase,a6
;----Free the read_port signal
     moveq    #0,d0
     move.b   ReadPort+15,d0
     bmi.s    .143
     jsr      _LVOFreeSignal(a6)
;-----Free the talk_port signal
.143 moveq    #0,d0
     move.b   TalkPort+15,d0
     bmi.s    .144
     jsr      _LVOFreeSignal(a6)
;----Close the FaceWindow
.144 movea.l  _IntuitionBase,a6
     move.l   _FaceWindow,d0
     beq.s    .145
     movea.l  d0,a0
     jsr      _LVOCloseWindow(a6)
.145 move.l   _ControlWindow,d0
     beq.s    .146
     movea.l  d0,a0
     jsr      _LVOCloseWindow(a6)
;-------freeimages makes sure image allocation was successful
.146 bsr      free_chip_mem
;----Close the narrator device
     move.b   _NarratorOpenError,d0
     bne.s    .147
     lea      VoiceIOB,a1
     jsr      _LVOCloseDevice(a6)
;---Close Whichever Libs are Open
.147 move.l   _TranslatorBase,d0
     beq.s    .148
     movea.l  d0,a1
     jsr      _LVOCloseLibrary(a6)
.148 move.l   _GfxBase,d0
     beq.s    .149
     movea.l  d0,a1
     jsr      _LVOCloseLibrary(a6)
.149 move.l   _IntuitionBase,d0
     beq.s    .150
     movea.l  d0,a1
     jsr      _LVOCloseLibrary(a6)
.150 clr.l    -(sp)
     jsr      _exit    ;exits

;=====================================================================
; Allocate chip memory for gadget images, and set the
; pointers in the corresponding image structures to point
; to these images. This must be done because the program
; could be loaded into expansion memory (off the side of
; the box), which the custom chips cannot access.
; And images must be in chip ram (that's memory that the
; custom chips can access, the internal 512K).
; Allocate them all, stop and return false on failure.

   XDEF   get_chip_mem
get_chip_mem:
;----Allocate chip mem to copy FemaleData
     moveq    #2,d1            ;MEMF_CHIP
     moveq    #40,d0           ;# of Bytes
     movea.l  _SysBase,a6
     jsr      _LVOAllocMem(a6)
     move.l   d0,_FemaleImage+10
     beq      .155
;----Copy initialized FemaleIData to chip mem block
     lea      _FemaleIData,a0
     movea.l  d0,a1
     moveq    #20-1,d0
.163 move.w   (a0)+,(a1)+
     Dbra     d0,.163
;----Allocate chip mem to copy MaleData
     moveq    #2,d1            ;MEMF_CHIP
     moveq    #40,d0           ;# of Bytes
     jsr      _LVOAllocMem(a6)
     move.l   d0,_MaleImage+10
     beq.s    .155
;----Copy initialized MaleIData to chip mem block
     lea      _MaleIData,a0
     movea.l  d0,a1
     moveq    #20-1,d0
.164 move.w   (a0)+,(a1)+
     Dbra     d0,.164
;----Allocate chip mem to copy HumanData
     moveq    #2,d1
     moveq    #120,d0
     jsr      _LVOAllocMem(a6)
     move.l   d0,_HumanImage+10
     beq.s    .155
;----Copy initialized HumanIData to chip mem block
     lea      _HumanIData,a0
     movea.l  d0,a1
     moveq    #60-1,d0
.169 move.w   (a0)+,(a1)+
     Dbra     d0,.169
;----Allocate chip mem to copy RobotData
     moveq    #2,d1
     moveq    #120,d0
     jsr      _LVOAllocMem(a6)
     move.l   d0,_RobotImage+10
     beq.s    .155
;----Copy initialized RobotIData to chip mem block
     lea      _RobotIData,a0
     movea.l  d0,a1
     moveq    #60-1,d0
.168 move.w   (a0)+,(a1)+
     Dbra     d0,.168
;----Allocate (Zeroed) chip mem for FaceData
     move.l   #$10002,d1
     moveq    #60,d0
     jsr      _LVOAllocMem(a6)
     move.l   d0,_FaceImage+10
     beq.s    .155
;----Allocate (ZEROED) chip mem for StopData
     move.l   #$10002,d1
     moveq    #60,d0
     jsr      _LVOAllocMem(a6)
     move.l   d0,_StopImage+10
     beq.s    .155
     moveq    #1,d0
.155 rts

;========================================================
; Deallocate the memory that was used for images, if pointers are not 0.

   XDEF   free_chip_mem
free_chip_mem:
     movea.l  _SysBase,a6
     move.l   _RobotImage+10,d1
     beq.s    .181
     moveq    #120,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.181 move.l   _HumanImage+10,d1
     beq.s    .182
     moveq    #120,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.182 move.l   _MaleImage+10,d1
     beq.s    .183
     moveq    #40,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.183 move.l   _FemaleImage+10,d1
     beq.s    .184
     moveq    #40,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.184 move.l   _FaceImage+10,d1
     beq.s    .185
     moveq    #60,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.185 move.l   _StopImage+10,d1
     beq.s    .186
     moveq    #60,d0
     movea.l  d1,a1
     jsr      _LVOFreeMem(a6)
.186 rts

   XDEF   TextAttr
TextAttr:
   dc.l   TopazName
   dc.w   8       ;TOPAZ_EIGHTY
   dc.b   0,0

   XDEF   _audio_chan
_audio_chan: dc.b 3,5,10,12 ;Which audio channels to use

TalkPort:
          dc.l 0,0
          dc.b 4,0
          dc.l 0
          dc.b 0,-1        ;PA_SIGNAL,MP_SIGBIT
          dc.l 0
PortList1 dc.l PortList2
PortList2 dc.l 0
PortList3 dc.l PortList1
          dc.w 0

ReadPort:
          dc.l 0,0
          dc.b 4,0
          dc.l 0
          dc.b 0,-1        ;PA_SIGNAL,MP_SIGBIT
          dc.l 0
portList1 dc.l portList2
portList2 dc.l 0
portList3 dc.l portList1
          dc.w 0

;===========Narrator Write Request block=============
VoiceIOB:
 ;---Embedded Message Structure
    dc.l  0,0
    dc.b  0,0
    dc.l  0
    dc.l  TalkPort       ;mn_ReplyPort 14(BASE)
    dc.w  70             ;mn_Length    18(BASE)
 ;---Embedded Expanded IORequest Structure
dev dc.l  0              ;io_Device    20(BASE)
    dc.l  0              ;io_Unit      24(BASE)
    dc.w  3              ;io_Command   28(BASE)
    dc.b  0              ;io_Flags     30(BASE)
    dc.b  0              ;io_Error     31(BASE)  SIGNED
    dc.l  0              ;io_Actual    32(BASE)
    dc.l  0              ;io_Length    36(BASE)
    dc.l  _PhonBuffer    ;io_Data      40(BASE)
    dc.l  0              ;io_Offset    44(BASE)
 ;---Narrator device additional fields
    dc.w  0              ;rb_rate      48(BASE)
    dc.w  0              ;rb_pitch     50(BASE)
    dc.w  0              ;rb_mode      52(BASE)
    dc.w  0              ;rb_pitch     54(BASE)
    dc.l  _audio_chan    ;rb_ch_masks  56(BASE)
    dc.w  4              ;rb_mn_masks  60(BASE)
    dc.w  0              ;rb_volume    62(BASE)
    dc.w  0              ;rb_sampfreq  64(BASE)
    dc.b  0              ;rb_mouths    66(BASE)
    dc.b  0              ;rb_chanmask  67(BASE) internal use
    dc.b  0              ;rb_numchan   68(BASE) internal use
    dc.b  0              ;Pad          69(BASE)

;========Narrator Read Request block (used for the mouth)===========
; The Read Request to the narrator has 4 additional bytes beyond the end
; of the Write Request. They are:
;   dc.b  0              ;rb_width     70(BASE)
;   dc.b  0              ;rb_height    71(BASE)
;   dc.b  0              ;rb_shape     72(BASE) internal use
;   dc.b  0              ;Pad          73(BASE)
MouthIO: ds.b 74

   XDEF   _NarratorOpenError,_TranslatorError
_NarratorOpenError: dc.b -1     ;Narrator not yet opened (Flag)
_TranslatorError:   dc.b 0

_i dc.w 0

;These are used to draw the eyes and mouth size relative
_MouthWMult   dc.w 0
_EyesLeft     dc.w 0
_MouthHMult   dc.w 0
_EyesTop      dc.w 0
_EyesBottom   dc.w 0
_YMouthCenter dc.w 0 ;Pixels from top edge
_XMouthCenter dc.w 0 ;Pixels from left edge
_yaw          dc.w 0
_LipWidth     dc.w 0
_LipHeight    dc.w 0

;/* String Gadgets *********************************************
;
;First the string gadgets.
;  1) because the Phonetic string is refreshed programaticly
;  (that is, deleted and added again) quite often, and doing
;  this requires the use of RefreshGadgets(), and this causes
;  gadgets that are closer to the beginning of the list than
;  the gadget given to RefreshGadgets() to flicker.
;  2) because they don't flicker when OTHER gadgets
;  (ie female/male, coming up) are deleted and added.
;
; These'll be used to put a nice double line border around
; each of the two string gadgets.

; y,x pairs drawn as a connected line. Be sure to have an even
; number of arguments (ie complete pairs).

   XDEF   _StrVectors
_StrVectors:
   dc.w   0,0,297,0,297,14,0,14,0,1,296,1,296,13,1,13,1,1

   XDEF   _StrBorder
_StrBorder:
   dc.w   -4,-3       ;initial offsets, gadget relative
   dc.b   1,0         ;ForePen = 1, BackPen = 0
   dc.b   0           ;JAM1
   dc.b   9           ;number of vectors
   dc.l   _StrVectors ;pointer to the actual array of vectors
   dc.l   0           ;no Next Border

; The same undo buffer is used for both string gadgets,
; this is sized to largest so that largest fits.
_UndoBuffer ds.b 768

; English String Gadget is where the user types in English
   XDEF   _EnglBuffer
_EnglBuffer:
   dc.b   'This is amiga speaking.',0
   ds.b   488

   XDEF   _EnglInfo
_EnglInfo:
;pointer to I/O buffer
   dc.l   _EnglBuffer
;pointer to undo buffer
   dc.l   _UndoBuffer
;buffer position
   dc.w   0
;max number of chars, including NULL
   dc.w   512
;first char in display, undo positions
   dc.w   0
   dc.w   0
;number of chars (currently) in the buffer
   dc.w   24
;position variables calculated by Intuition
   dc.w   0,0,0
;no pointer to RastPort
   dc.l   0
;not a LongInt string gadget
   dc.l   0
;no pointer to alternate keymap
   dc.l   0

   XDEF   _EnglText
_EnglText:
;FrontPen, BackPen
   dc.b   1,0
;DrawMode = JAM1, Pad
   dc.b   0,0
;LeftEdge, TopEdge (relative to gadget)
   dc.w   0,-13
;pointer to TextFont
   dc.l   TextAttr
;pointer to Text
   dc.l   English
;no pointer to NextText
   dc.l   0

   XDEF   _EnglStrGadget
_EnglStrGadget:
;pointer to Next Gadget
   dc.l   0
;(Left Top Width Height) Hit Box
   dc.w   11,63,290,10
;   GADGHCOMP,        /* Flags */
   dc.w   0
;   RELVERIFY,        /* Activation flags */
   dc.w   1
;   STRGADGET,        /* Type */
   dc.w   4
;pointer to Border Image
   dc.l   _StrBorder
;no pointer to SelectRender
   dc.l   0
;pointer to Gadget IntuiText
   dc.l   _EnglText
;no MutualExclude
   dc.l   0
;pointer to SpecialInfo
   dc.l   _EnglInfo
;no ID
   dc.w   0
;no pointer to special data
   dc.l   0

; Phonetic string gadget is where the program puts the
; translated string, necessating a call to RefreshGadgets(),
; and is where the user can type in Phonemes.

   XDEF   _PhonBuffer
_PhonBuffer:
   dc.b  'DHIHS IHZ AHMIY3GAH SPIY4KIHNX.',0
   ds.b   736

   XDEF   _PhonInfo
_PhonInfo:
   dc.l   _PhonBuffer
   dc.l   _UndoBuffer
   dc.w   0,768,0,0,32,0,0,0
   dc.l   0
;not a LongInt string gadget
   dc.l   0
   dc.l   0

   XDEF   _PhonText
_PhonText:
   dc.b   1,0,0,0
   dc.w   0,-13
   dc.l   TextAttr
   dc.l   Phonetic
   dc.l   0

   XDEF   _PhonStrGadget
_PhonStrGadget:
   dc.l   _EnglStrGadget
   dc.w   11,94,290,10,0,1,4
   dc.l   _StrBorder
   dc.l   0
   dc.l   _PhonText
   dc.l   0
   dc.l   _PhonInfo
   dc.w   0
   dc.l   0

; Now come the Boolean Gadgets.
; The female/male pair shows the simplest implementation I
; could think of to show how you can do mutual-exclude type
; things yourself. They are two toggle gadgets that use
; highlight image. The program starts with one selected, and
; then if either of them are hit, both toggle. Gadgets must
; be deleted and added whenever you want to change structure
; member values that intuition expects to be coming from the
; user, not a program (like the SELECTED bit in flags). Note
; that certain structure values CAN be changed programaticly
; without all this broohaha. Haha. Consult the intuition manual.

; Female Toggle (Highlight Image)
; (Quasi mutual exclude with Male Toggle)
   XDEF   _FemaleImage
_FemaleImage:
   dc.w   0,0       ;Left,Top
   dc.w   20,10,1   ;Width, Height, Depth
   dc.l   $0000     ;ImageData (must be chip. Will be allocated)
   dc.b   1         ;PlanePick
   dc.b   0         ;PlaneOnOff
   dc.b   0,0,0,0

   XDEF   _FemaleGadget
_FemaleGadget:
   dc.l   _PhonStrGadget
   dc.w   134,34,20,10
  ;GADGIMAGE|GADGHCOMP
   dc.w   4
  ;Activation flags = RELVERIFY | GADGIMMEDIATE | TOGGLESELECT
   dc.w   259
   dc.w   1          ;Type = BOOLGADGET
   dc.l   _FemaleImage
   dc.l   0
   dc.l   0
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

;Male Toggle (Highlight Image)
;(Quasi mutual Exclude with above)
   XDEF   _MaleImage
_MaleImage:
   dc.w   0,0       ;Left,Top
   dc.w   20,10,1   ;Width, Height, Depth
   dc.l   $0000     ;ImageData
   dc.b   1         ;PlanePick
   dc.b   0         ;PlaneOnOff
   dc.b   0,0,0,0

   XDEF   _MaleGadget
_MaleGadget:
   dc.l   _FemaleGadget
   dc.w   154,34,20,10
  ;GADGIMAGE|GADGHCOMP|SELECTED
   dc.w   132
  ;Activation = RELVERIFY | GADGIMMEDIATE | TOGGLESELECT | ACTIVATE
   dc.w   4355
   dc.w   1
   dc.l   _MaleImage
   dc.l   0
   dc.l   0
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

; This boolean toggle gadget has an
; alternate image that indicates
; selection. The image stays flipped
; until it gets another hit. (it toggles)

; Inflection Mode Toggle (AltImage)

   XDEF   _HumanImage
_HumanImage:
   dc.w   0,0,40,20,1
   dc.l   0
   dc.b   1,0,0,0,0,0

   XDEF   _RobotImage
_RobotImage:
   dc.w   0,0,40,20,1
   dc.l   0
   dc.b   1,0,0,0,0,0

   XDEF   _ModeGadget
_ModeGadget:
   dc.l   _MaleGadget
   dc.w   134,2,40,20
;   GADGIMAGE | GADGHIMAGE, /* Flags */
   dc.w   6
;   /* Activation flags */
;   RELVERIFY | GADGIMMEDIATE | TOGGLESELECT,
   dc.w   259
   dc.w   1
   dc.l   _HumanImage
   dc.l   _RobotImage
   dc.l   0
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

;Face Toggle (image and text)

   XDEF   _FaceIText
_FaceIText:
   dc.b   1,0,1,0
   dc.w   4,1
   dc.l   TextAttr
   dc.l   Face
   dc.l   0

   XDEF   _FaceImage
_FaceImage:
   dc.w   0,0,40,10,1
   dc.l   0
   dc.b   1,0,0,0,0,0

   XDEF   _FaceGadget
_FaceGadget:
   dc.l   _ModeGadget
   dc.w   134,23,40,10
;   GADGIMAGE | GADGHCOMP,  /* Flags */
   dc.w   4
;   /* Activation flags */
;   RELVERIFY | GADGIMMEDIATE | TOGGLESELECT,
   dc.w   259
   dc.w   1
   dc.l   _FaceImage
   dc.l   0
   dc.l   _FaceIText
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

;/* Stop Hit (image and text) ******************************/
   XDEF   _StopIText
_StopIText:
   dc.b   1,0,1,0
   dc.w   4,1
   dc.l   TextAttr
   dc.l   Stop
   dc.l   0

   XDEF   _StopImage
_StopImage:
   dc.w   0,0,40,10,1
   dc.l   0
   dc.b   1,0,0,0,0,0

   XDEF   _StopGadget
_StopGadget:
   dc.l   _FaceGadget
   dc.w   134,45,40,10
;   GADGIMAGE | GADGHCOMP,  /* Flags */
   dc.w   4
;   RELVERIFY | GADGIMMEDIATE, /* Activation flags */
   dc.w   3
   dc.w   1
   dc.l   _StopImage
   dc.l   0
   dc.l   _StopIText
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

; This is a hit (as opposed to toggle)
; gadget that starts the translation.
; Translate Hit (Highlight image)

   XDEF   _TransVectors
_TransVectors:
   dc.w   0,0,79,0,79,13,0,13,0,1,78,1,78,12,1,12,1,1

   XDEF   _TransBorder
_TransBorder:
   dc.w   -4,-3
   dc.b   1,0,0,9
   dc.l   _TransVectors
   dc.l   0

   XDEF   _TranslateIText
_TranslateIText:
   dc.b   1,0,1,0
   dc.w   0,0
   dc.l   TextAttr
   dc.l   Translate
   dc.l   0

   XDEF   _TranslateGadget
_TranslateGadget:
   dc.l   _StopGadget
   dc.w   229,48,71,8
   dc.w   0,3,1
   dc.l   _TransBorder
   dc.l   0
   dc.l   _TranslateIText
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

;/* This is a hit (as opposed to toggle) Starts the narration */
;/* Speak Hit (Highlight Image) *******************************/

   XDEF   _SpeakVectors
_SpeakVectors:
   dc.w   0,0,47,0,47,13,0,13,0,1,46,1,46,12,1,12,1,1

   XDEF   _SpeakBorder
_SpeakBorder:
   dc.w   -4,-3
   dc.b   1,0,0,9
   dc.l   _SpeakVectors
   dc.l   0

   XDEF   _SpeakIText
_SpeakIText:
   dc.b   1,0,1,0
   dc.w   0,0
   dc.l   TextAttr
   dc.l   Speak
   dc.l   0

   XDEF   _SpeakGadget
_SpeakGadget:
   dc.l   _TranslateGadget
   dc.w   261,79,40,8,0,3,1
   dc.l   _SpeakBorder
   dc.l   0
   dc.l   _SpeakIText
   dc.l   0
   dc.l   0
   dc.w   0
   dc.l   0

;==============PROPORTIONAL GADGETS==================

;dummy AUTOKNOB Images are required
;Image structures for 4 gadgets
PropImage0:
   dc.w   0,0,0,0,0
   dc.l   0
   dc.b   0,0,0,0,0,0
PropImage1:
   dc.w   0,0,0,0,0
   dc.l   0
   dc.b   0,0,0,0,0,0
PropImage2:
   dc.w   0,0,0,0,0
   dc.l   0
   dc.b   0,0,0,0,0,0
PropImage3:
   dc.w   0,0,0,0,0
   dc.l   0
   dc.b   0,0,0,0,0,0
PropImage19:
   dc.w   0,0,0,0,0
   dc.l   0
   dc.b   0,0,0,0,0,0

   XDEF   PropText0
PropText0:
   dc.b   1,0,0,0
   dc.w   0,-10
   dc.l   TextAttr
   dc.l   Sample
   dc.l   0
PropText1:
   dc.b   1,0,0,0
   dc.w   0,-10
   dc.l   TextAttr
   dc.l   Rate
   dc.l   0
PropText2:
   dc.b   1,0,0,0
   dc.w   0,-10
   dc.l   TextAttr
   dc.l   Pitch
   dc.l   0
PropText3:
   dc.b   1,0,0,0
   dc.w   0,-10
   dc.l   TextAttr
   dc.l   Volume
   dc.l   0

   XDEF   PropInfo0
PropInfo0:
   dc.w   3      ;AUTOKNOB|FREEHORIZ
   dc.w   49009,0
;Bodies: Horiz is 1/8, Vert is 1/8
   dc.w   $1FFF
   dc.w   $1FFF
   dc.w   0,0,0,0,0,0
PropInfo1:
   dc.w   3,20024,0,$1FFF,$1FFF,0,0,0,0,0,0
PropInfo2:
   dc.w   3,11565,0,$1FFF,$1FFF,0,0,0,0,0,0
PropInfo3:
   dc.w   3,65535,0,$1FFF,$1FFF,0,0,0,0,0,0

   XDEF   PropGadget0
PropGadget0:
   dc.l   _SpeakGadget
   dc.w   7,12,115,10
   dc.w   4            ;GADGHCOMP|GADGIMAGE
   dc.w   3            ;GADGIMMEDIATE|RELVERIFY
   dc.w   3            ;PROPGADGET
   dc.l   PropImage0,0,PropText0,0,PropInfo0
   dc.w   0
   dc.l   0
PropGadget1:
   dc.l   PropGadget0
   dc.w   7,34,115,10,4,3,3
   dc.l   PropImage1,0,PropText1,0,PropInfo1
   dc.w   0
   dc.l   0
PropGadget2:
   dc.l   PropGadget1
   dc.w   190,12,115,10,4,3,3
   dc.l   PropImage2,0,PropText2,0,PropInfo2
   dc.w   0
   dc.l   0
PropGadget3:
   dc.l   PropGadget2
   dc.w   190,34,115,10,4,3,3
   dc.l   PropImage3,0,PropText3,0,PropInfo3
   dc.w   0
   dc.l   0

   XDEF   _IntuitionBase,_GfxBase,_TranslatorBase
_IntuitionBase:  dc.l 0
_GfxBase:        dc.l 0
_TranslatorBase: dc.l 0

;==========Only one menu. (Goes on both Control and Face Windows)===========

   XDEF   MenuIntuiText
MenuIntuiText:
   dc.b   0,1,1,0
   dc.w   0,0
   dc.l   TextAttr,About,0

   XDEF   MenuItem0
MenuItem0:
   dc.l   0
   dc.w   0,0,150,8
   dc.w   $52       ;ITEMTEXT|ITEMENABLED|HIGHCOMP
   dc.l   0
   dc.l   MenuIntuiText
   dc.l   0
   dc.b   0,0
   dc.l   0
   dc.w   -1        ;NextSelect = MENUNULL

   XDEF   Menu0
Menu0:
   dc.l   0
   dc.w   0,0,150,0
   dc.w   1        ;MENUENABLED
   dc.l   SMenu
   dc.l   MenuItem0,0,0

   XDEF   _ReqText1
_ReqText1:
   dc.b   0,1,1,0
   dc.w   5,23
   dc.l   TextAttr
   dc.l   Version
   dc.l   0

   XDEF   _ReqText2
_ReqText2:
   dc.b   0,1,1,0
   dc.w   5,13
   dc.l   TextAttr
   dc.l   Free
   dc.l   _ReqText1

   XDEF   _ReqText3
_ReqText3:
   dc.b   0,1,1,0
   dc.w   5,3
   dc.l   TextAttr
   dc.l   Author
   dc.l   _ReqText2

   XDEF   _OKIText
_OKIText:
   dc.b   0,1,1,0
   dc.w   6,3
   dc.l   TextAttr
   dc.l   OK
   dc.l   0

   XDEF   _ControlWindow,_FaceWindow,RastPort
_ControlWindow: dc.l 0
_FaceWindow:    dc.l 0
RastPort        dc.l 0
_MyIntuiMessage dc.l 0

   XDEF   _NewControlWindow
_NewControlWindow:
   dc.w   0,11,321,123
   dc.b   -1,-1
   dc.l   $340     ;IDCMP = GADGETUP|CLOSEWINDOW|MENUPICK
;WindowFlags = WINDOWDRAG|WINDOWDEPTH|WINDOWCLOSE|GIMMEZEROZERO|ACTIVATE
   dc.l   $140e
   dc.l   PropGadget3
   dc.l   0
   dc.l   ST
   dc.l   0
   dc.l   0
   dc.w   20,20,321,123
   dc.w   1

   XDEF   _NewFaceWindow
_NewFaceWindow:
   dc.w   321,11,64,44
   dc.b   -1,-1
   dc.l   $103     ;IDCMP = SIZEVERIFY|NEWSIZE|MENUPICK
; WINDOWDRAG|WINDOWDEPTH|WINDOWSIZING|SIZEBBOTTOM|GIMMEZEROZERO|ACTIVATE
   dc.l   $1427
   dc.l   0
   dc.l   0
   dc.l   Face
   dc.l   0
   dc.l   0
   dc.w   32,44,640,200
   dc.w   1

   XDEF   _FemaleIData
_FemaleIData:
;   ----    -  These nibbles matter to image.
   dc.w   0,0,$F0,0,$198,0,$30C,0,$198,0,$F0,0,$60,0,$1F8,0,$60,0,0,0

   XDEF   _MaleIData
_MaleIData:
   dc.w   0,0,$3E,0,$E,0,$36,0,$1E0,0,$330,0,$618,0,$330,0,$1E0,0,0,0

   XDEF   _HumanIData
_HumanIData:
;   ----   ----   --   These nibbles matter to image.
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,7,$9E00,0,1,$8600,0,0,0,0,0,0,0
   dc.w   0,$2000,0,0,$1000,0,0,$800,0,0,$7C00,0,0,0,0,0,0,0,0,0,0
   dc.w   0,$7800,0,0,0,0,0,0,0,0,0,0,0,0,0

   XDEF   _RobotIData
_RobotIData:
;   ----   ----   --   These nibbles matter to image.
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,7,$9E00,0,4,$9200,0,7,$9E00,0,0,0,0
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,$F800,0,1,$800,0,1,$F800,0
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0

English   dc.b 'English:',0
Phonetic  dc.b 'Phonetics:',0
Version   dc.b 'Version 1.1  21 Dec, 1985',0
Free      dc.b 'Freeware - Public Domain ',0
Author    dc.b 'Written by David M Lucas ',0
OK        dc.b 'OK',0
ST        dc.b 'SpeechToy',0
SMenu     dc.b 'SpeechToy Menu',0
About     dc.b 'About SpeechToy...',0
Speak     dc.b 'Speak',0
Translate dc.b 'Translate',0
Stop      dc.b 'Stop',0
Face      dc.b 'Face',0
Volume    dc.b 'Volume:',0
Pitch     dc.b 'Pitch:',0
Rate      dc.b 'Rate:',0
Sample    dc.b 'Sample Freq:',0
TopazName dc.b 'topaz.font',0
IntuitionTitle  dc.b 'intuition.library',0
GraphicsTitle   dc.b 'graphics.library',0
TranslatorTitle dc.b 'translator.library',0
Narrator        dc.b 'narrator.device',0

   END

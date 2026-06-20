;************************** TYPE and TELL ****************************
;
; Original C Code By: Giorgio Galeotti
;
; Anakin Research Inc.
; Rexdale, Ontatio, Canada.
; Tel. 416-744-4246
;
; Assembly version by Jeff Glatt. Needs to be linked with a startup code.
;
; This program will install an input device handler before the Intuition one,
; inspect all keys typed by the user and spell them out in real time.
;
; Just run this program as a background task. To quit the program, press:
; "CONTROL LEFT-SHIFT LEFT-ALT RIGHT-AMIGA" at the same time.

   XREF   _CreateExtIO,_DeleteExtIO  ;Standard C functions (use the 32 bit
   XREF   _CreateStdIO,_DeleteStdIO  ;versions only)
   XREF   _CreatePort,_DeletePort

   XREF   _LVOWaitTOF                ;Amiga.lib _LVO labels
   XREF   _LVOTranslate
   XREF   _LVODoIO
   XREF   _LVORawKeyConvert
   XREF   _LVOWait,_LVOSignal
   XREF   _LVOAllocSignal,_LVOFreeSignal
   XREF   _LVOOpenLibrary,_LVOCloseLibrary
   XREF   _LVOOpenDevice,_LVOCloseDevice

   XREF   _SysBase,_DOSBase,_exit,_ThisTask  ;From SmallStart.asm

   SECTION TypeTellCode,CODE

LIB_VERSION equ 33

   XDEF   _main
_main:
    movea.l  _SysBase,a6
;Open the console device with unit = -1. This will return an IOBlock
;with the io_Device field initialized to the Console device base.
;See page B-27 of "Libraries and Devices" console.device/OpenDevice
    moveq   #0,d1
    movea.l _InputRequestBlock,a1
    moveq   #-1,d0         ;don't actually open a console
    lea     ConsoleName,a0
    jsr     _LVOOpenDevice(a6)
    move.l  d0,d1
    beq.s   .4             ;branch if no error
 ;---Exit with error 100
    pea     100
    jsr     _exit
 ;---Get the address of Console Device's base structure
.4  lea      _InputRequestBlock,a0
    movea.l  (a0),a1
    move.l   20(a1),_ConsoleDevice
  ;---InputRequestBlock pointer = 0 (For clean up purposes)
    clr.l    (a0)
  ;---Close the console device
    jsr      _LVOCloseDevice(a6)
;Open the Graphics library, since it's needed to do the WaitTOF()
;calls in the input handler
    moveq   #LIB_VERSION,d0
    lea     GfxName,a1
    jsr     _LVOOpenLibrary(a6)
    move.l   d0,_GfxBase
    bne.s   .5
 ;---Exit with error 110
    moveq    #110,d0
    bra      _CleanUp_Exit
 ;---Get a signal bit so that our input handler can wake us up
 ;---when there is something in the buffer
.5  moveq    #-1,d0
    jsr      _LVOAllocSignal(a6)
    move.b   d0,_MainSignal
    bpl.s    .SS
 ;---Exit with error 115
    moveq    #115,d0
    bra      _CleanUp_Exit
 ;---Make a mask of the signal
.SS moveq    #0,d1
    Bset.l   d0,d1
    move.l   d1,MainSigMask
  ;---get the address of our MainTask
  ;  suba.l   a1,a1            ;SmallStart.asm does this already. If you
  ;  jsr      _LVOFindTask(a6) ;aren't using it, uncomment this and create
  ;  move.l   d0,_ThisTask     ;a LONG variable, _ThisTask.
  ;---Get a port for the input device
    clr.l    -(sp)
    clr.l    -(sp)
    jsr      _CreatePort
    addq.w   #8,sp
    move.l   d0,_InputDevPort
    bne.s    .6
  ;---Exit with error 120
    moveq    #120,d0
    bra      _CleanUp_Exit
 ;---Get an InputRequestBlock
.6  move.l   d0,-(sp)
    jsr      _CreateStdIO
    addq.w   #4,sp
    move.l   d0,_InputRequestBlock
    bne.s   .7
 ;---Exit with error 130
    moveq    #0,d0
    move.b   #130,d0
    bra      _CleanUp_Exit
;============Open the input device==============
.7  moveq   #0,d1
    movea.l d0,a1
    moveq   #0,d0
    lea     InputName,a0
    jsr     _LVOOpenDevice(a6)
    move.l  d0,d1
    bne.s   .8
    Bset.b  #0,DevicesOpen
    bra.s   .9
  ;---Exit with error 140
.8  moveq    #0,d0
    move.b   #140,d0
    bra      _CleanUp_Exit
;========Get ready to install our own input device handler===========
  ;---InputRequestBlock's io_Command = IND_ADDHANDLER
.9  movea.l  _InputRequestBlock,a1
    moveq    #9,d0
    move.w   d0,28(a1)
  ;---InputRequestBlock's io_Data = the address of handlerInt structure
    move.l   #handlerInt,40(a1)
;-----Install the handler
    jsr      _LVODoIO(a6)
;==============Open the translator library==============
    moveq    #LIB_VERSION,d0
    lea      TransName,a1
    jsr      _LVOOpenLibrary(a6)
    move.l   d0,_TranslatorBase
    bne.s    .10
  ;---Exit with error 500
    moveq    #0,d0
    move.w   #500,d0
    bra      _CleanUp_Exit
;===========Open the Narrator device for writes==========
  ;---Get a WritePort
.10 clr.l    -(sp)
    clr.l    -(sp)
    jsr      _CreatePort
    addq.w   #8,sp
    move.l   d0,_WritePort
    bne.s    .11
  ;---Exit with error 510
    moveq    #0,d0
    move.w   #510,d0
    bra      _CleanUp_Exit
  ;---Get an IOB, WriteNarrator
.11 pea      70
    move.l   d0,-(sp)
    jsr      _CreateExtIO
    addq.w   #8,sp
    move.l   d0,_WriteNarrator
    bne.s    .12
  ;---Exit with error 520
    moveq    #0,d0
    move.w   #520,d0
    bra      _CleanUp_Exit
  ;---Open the Narrator device
.12 moveq    #0,d1
    movea.l  d0,a1
    moveq    #0,d0
    lea      NarrDevName,a0
    jsr      _LVOOpenDevice(a6)
    move.l   d0,d1
    bne.s    .13
    Bset.b   #1,DevicesOpen
    bra.s    .14
  ;---Exit with error 140
.13 moveq    #0,d0
    move.b   #140,d0
    bra      _CleanUp_Exit
;=====Set up part of the narrator's IOB (the fields that never change)=====
.14 movea.l  _WriteNarrator,a1
  ;---io_Command = CMD_WRITE
    moveq    #3,d0
    move.w   d0,28(a1)
  ;---WriteNarrator's rate     = DEFRATE+100
    moveq    #0,d0
    move.b   #250,d0
    move.w   d0,48(a1)
  ;---ch_masks  = AudioChannels
    lea      56(a1),a0
    move.l   #_AudioChannels,(a0)+     ;56(IOB)
  ;---nm_masks  = sizeof AudioChannels
    moveq    #4,d0
    move.w   d0,(a0)+                  ;60(IOB)
  ;---WriteNarrator's volume   = DEFVOL
    moveq    #64,d0
    move.w   d0,(a0)+                  ;62(IOB)
  ;--WriteNarrator's sampfreq = DEFFREQ
    move.w   #22200,(a0)               ;64(IOB)

;Do the main control routine and sit there until the user requests to quit

;This routine contains the loop that keeps checking everything the user does
;at the keyboard so that appropriate actions can be taken.
;  actual = # of bytes returned by RawKeyConvert
;  buffer = Buffer used by RawKeyConvert() to put results in

   XDEF   TheBigLoop
TheBigLoop:
  ;----if Counter is not 0, then something is in the buffer
    move.b    Counter,d0
    bne.s     .21
  ;---Otherwise, sleep til signalled
SLP movea.l   _SysBase,a6
    move.l    MainSigMask,d0
    Bset.b    #0,_Waiting     ;indicate "main is asleep" to event_handler()
    jsr       _LVOWait(a6)
    and.l     MainSigMask,d0
    beq.s     SLP
  ;---Get our last position in the buffer
.21 moveq     #22,d1
    move.w    _Emptier,d0
    mulu.w    d1,d0
    lea       _EventRing,a0
    adda.l    d0,a0
;=======Check if user requested to quit Type&Tell=======
; if Event's ie_Qualifier is QUIT_CODE_1 OR QUIT_CODE_2
; then CleanUp_Exit(1000)
    move.w    8(a0),d1
    subi.w    #QUIT_CODE_1,d1
    beq.s     .23
    subi.w    #QUIT_CODE_2-QUIT_CODE_1,d1
    bne.s     .22
.23 moveq     #0,d0
    move.w    #1000,d0
    bra       _CleanUp_Exit  ;never returns
;Convert raw-key event to ANSI standard. Assume default keymap.
;actual = RawKeyConvert(&EventRing[Emptier],buffer,30,0)
.22 move.l    a2,-(sp)
    suba.l    a2,a2           ;no keymap, use default
    moveq     #30,d1
    lea       rawkeyBuf,a1
    ;current EventRing address in a0
    move.l    a0,-(sp)
    movea.l   _ConsoleDevice,a6
    jsr       _LVORawKeyConvert(a6)
    movea.l   (sp)+,a1
    movea.l   (sp)+,a2
  ;if actual is 1 (a simple ascii char) then do SpeakASCII(buffer)
    lea       rawkeyBuf,a0
    subq.l    #1,d0
    beq       SpeakASCII
  ;--else SpeakQualifier( EventRing's Address ) more than 1 char in the
  ;  buffer, must be a control sequence.
    ; Fall through to SpeakQualifier
;***************************************************
;SpeakQualifier(Event)
;                a1
; The keystroke did not translate to any single ASCII character,
; but nevertheless, it must be called out.

   XDEF   SpeakQualifier
SpeakQualifier:
    movea.l  _WriteNarrator,a0
    adda.w   #50,a0
  ;---WriteNarrator's pitch    = DEFPITCH+100
    moveq    #0,d0
    move.b   #210,d0
    move.w   d0,(a0)+
  ;---WriteNarrator's mode     = NATURALF0
    clr.w    (a0)+
  ;---WriteNarrator's sex      = FEMALE
    moveq    #1,d0
    move.w   d0,(a0)
;---do a switch on the passed Rawkey Event's ie_Code field---
    move.w   6(a1),d0
    subi.w   #76,d0
    beq      .102
    subq.w   #1,d0
    beq      .105
    subq.w   #1,d0
    beq      .104
    subq.w   #1,d0
    beq      .103
    subq.w   #1,d0
    beq.s    .84
    subq.w   #1,d0
    beq      .85
    subq.w   #1,d0
    beq      .86
    subq.w   #1,d0
    beq      .87
    subq.w   #1,d0
    beq      .88
    subq.w   #1,d0
    beq      .89
    subq.w   #1,d0
    beq      .90
    subq.w   #1,d0
    beq      .91
    subq.w   #1,d0
    beq      .92
    subq.w   #1,d0
    beq      .93
    subq.w   #6,d0
    beq      .101
    subq.w   #1,d0
    beq      .95
    subq.w   #1,d0
    beq      .95
    subq.w   #1,d0
    beq      .106
    subq.w   #1,d0
    beq      .94
    subq.w   #1,d0
    beq      .97
    subq.w   #1,d0
    beq      .97
    subq.w   #1,d0
    beq      .99
    subq.w   #1,d0
    beq      .100
    subi.w   #123,d0
    beq      .107
    bra      .25
; case 0x50: Translate("FUNCTION 1",10,OutputString,100)
.84 moveq    #12,d0
    lea      F1,a0
    bra      .40
; case 0x51: Translate("FUNCTION 2",10,OutputString,100)
.85 moveq    #12,d0
    lea      F2,a0
    bra      .40
; case 0x52: Translate("FUNCTION 3",10,OutputString,100)
.86 moveq    #14,d0
    lea      F3,a0
    bra      .40
; case 0x53: Translate("FUNCTION 4",10,OutputString,100)
.87 moveq    #13,d0
    lea      F4,a0
    bra      .40
; case 0x54: Translate("FUNCTION 5",10,OutputString,100)
.88 moveq    #13,d0
    lea      F5,a0
    bra      .40
; case 0x55: Translate("FUNCTION 6",10,OutputString,100)
.89 moveq    #12,d0
    lea      F6,a0
    bra      .40
; case 0x56: Translate("FUNCTION 7",10,OutputString,100)
.90 moveq    #14,d0
    lea      F7,a0
    bra      .40
; case 0x57: Translate("FUNCTION 8",10,OutputString,100)
.91 moveq    #14,d0
    lea      F8,a0
    bra      .40
; case 0x58: Translate("FUNCTION 9",10,OutputString,100)
.92 moveq    #13,d0
    lea     F9,a0
    bra     .40
; case 0x59: Translate("FUNCTION TEN",12,OutputString,100)
.93 moveq   #12,d0
    lea     F10,a0
    bra     .40
; case 0x63: Translate("CONTROL",7,OutputString,100)
.94 moveq   #7,d0
    lea     CONTROL,a0
    bra     .40
;case 0x60 or 0x61: Translate("SHIFT",5,OutputString,100)
.95 moveq   #5,d0
    lea     SHIFT,a0
    bra     .40
; case 0x65: Translate("ALTERNATE",9,OutputString,100)
.97 moveq   #9,d0
    lea     ALTERNATE,a0
    bra     .40
; case 0x66: Translate("LEFT AMIGA",10,OutputString,100)
.99 moveq   #10,d0
    lea     LEFTAMG,a0
    bra     .40
; case 0x67: Translate("RIGHT AMIGA",11,OutputString,100)
.100 moveq   #11,d0
     lea     RIGHTAMG,a0
     bra     .40
;case 0x5f: Translate("HELP",4,OutputString,100)
.101 moveq   #4,d0
     lea     HELP,a0
     bra     .40
; case 0x4c: Translate("GO UP",5,OutputString,100)
.102 moveq   #5,d0
     lea     GOUP,a0
     bra     .40
; case 0x4f: Translate("GO LEFT",7,OutputString,100)
.103 moveq   #7,d0
     lea     GOLEFT,a0
     bra     .40
; case 0x4e: Translate("GO RIGHT",8,OutputString,100)
.104 moveq   #8,d0
     lea     GORIGHT,a0
     bra     .40
; case 0x4d: Translate("GO DOWN",7,OutputString,100)
.105 moveq   #7,d0
     lea     GODOWN,a0
     bra     .40
; case 0x62: Translate("CAPS LOCK ON",12,OutputString,100)
.106 moveq   #12,d0
     lea     CAPSON,a0
     bra     .40
; case 0xe2: Translate("CAPS LOCK OFF",13,OutputString,100)
.107 moveq   #13,d0
     lea     CAPSOFF,a0
     bra     .40

;******************************************************
;SpeakASCII(inputbuffer)
;               a0
;
;Speak the ASCII character contained in buffer.

   XDEF   SpeakASCII
SpeakASCII:
     movea.l  _WriteNarrator,a1
 ;---Check if the char is 'A' to 'Z' or '0' to '9'
     move.b   (a0),d0
     cmpi.b   #'A',d0
     bcs.s    .34
     cmpi.b   #'Z',d0
     bls.s    .33
.34  cmpi.b   #'0',d0
     bcs.s    .32
     cmpi.b   #'9',d0
     bhi.s    .32
 ;---If so....
  ;---WriteNarrator's pitch    = DEFPITCH
.33  moveq    #110,d1
     move.w   d1,50(a1)
  ;---WriteNarrator's mode     = NATURALF0
     clr.w    52(a1)
  ;---WriteNarrator's sex      = MALE
     clr.w    54(a1)
  ;---Translate(buffer,1,OutputString,100) translate the char
     moveq    #1,d0
     bra      .40
;======================================
 ;---Check if the char is 'a' to 'z'
.32  cmpi.b   #'a',d0
     bcs.s    .36
     cmpi.b   #'z',d0
     bhi.s    .36
  ;---WriteNarrator's pitch    = DEFPITCH+50
     move.b   #160,d1
     move.w   d1,50(a1)
  ;---WriteNarrator's mode     = NATURALF0
     clr.w    52(a1)
  ;---WriteNarrator's sex      = FEMALE
     moveq    #1,d0
     move.w   d0,54(a1)
     bra      .40
;=====OTHERWISE, USE THE FOLLOWING SETTINGS=========
  ;---WriteNarrator's pitch    = DEFPITCH
.36  moveq    #110,d1
     move.w   d1,50(a1)
  ;---WriteNarrator's mode     = NATURALF0
     clr.w    52(a1)
  ;---WriteNarrator's sex      = MALE
     clr.w    54(a1)
;========See if it is a control character ($01 to $1A)=======
     cmpi.b   #1,d0
     bcs      .25
     move.b   d0,d1
     subi.b   #$1B,d0
     bcc.s    .37
   ;-----copy "CONTROL" to buffer
     lea      CONTROL,a1
     move.l   a0,d0       ;save buffer address
CStr move.b   (a1)+,(a0)+
     bne.s    CStr
   ;---add a space at the end of CONTROL
     move.b   #' ',-1(a0)
     addi.b   #$40,d1     ;convert to ascii letter
     move.b   d1,(a0)
   ;Translate(buffer,9,OutputString,100)
     movea.l  d0,a0
     moveq    #9,d0
     bra      .40
;=========else switch on the character===========
.37  beq      .41       ;ESC
     subq.b   #5,d0
     beq      .42       ;SPACE
     subq.b   #1,d0
     beq      .43       ;!
     subq.b   #1,d0
     beq      .44       ;"
     subq.b   #1,d0
     beq      .45       ;#
     subq.b   #1,d0
     beq      .46       ;$
     subq.b   #1,d0
     beq      .47       ;%
     subq.b   #1,d0
     beq      .48       ;&
     subq.b   #1,d0
     beq      .49       ;'
     subq.b   #1,d0
     beq      .50       ;(
     subq.b   #1,d0
     beq      .51       ;)
     subq.b   #1,d0
     beq      .52       ;*
     subq.b   #1,d0
     beq      .53       ;+
     subq.b   #1,d0
     beq      .54       ;,
     subq.b   #1,d0
     beq      .55       ;-
     subq.b   #1,d0
     beq      .56       ;.
     subq.b   #1,d0
     beq      .57       ;/
     subi.b   #11,d0
     beq      .58       ;:
     subq.b   #1,d0
     beq      .59       ;;
     subq.b   #1,d0
     beq      .60       ;<
     subq.b   #1,d0
     beq      .62       ;=
     subq.b   #1,d0
     beq      .61       ;>
     subq.b   #1,d0
     beq      .63       ;?
     subq.b   #1,d0
     beq      .64       ;@
     subi.b   #27,d0
     beq      .65       ;[
     subq.b   #1,d0
     beq      .66       ;\
     subq.b   #1,d0
     beq      .67       ;]
     subq.b   #1,d0
     beq      .68       ;^
     subq.b   #1,d0
     beq      .69       ;_
     subq.b   #1,d0
     beq      .70       ;
     subi.b   #27,d0
     beq      .71       ;{
     subq.b   #1,d0
     beq      .72       ;|
     subq.b   #1,d0
     beq      .73       ;}
     subq.b   #1,d0
     beq      .74       ;TILDA
     subq.b   #1,d0
     beq      .75       ;DEL
     bra      .25       ;rts if not any of these (what is it???)
; case 0x1b: "ESCAPE"
.41  moveq    #6,d0
     lea      ESCAPE,a0
     bra      .40
; case ' ': "SPACE"
.42  moveq    #5,d0
     lea      SPACE,a0
     bra      .40
; case '!': "EXCLAMATION"
.43  moveq    #11,d0
     lea      EXCLAM,a0
     bra      .40
; case '"': "DOUBLE QUOTE"
.44  moveq    #12,d0
     lea      DQ,a0
     bra      .40
; case '#': "SHARP"
.45  moveq    #5,d0
     lea      SHARP,a0
     bra      .40
; case '$': "DOLLAR"
.46  moveq    #6,d0
     lea      DOLLAR,a0
     bra      .40
; case '%': "PERCENT"
.47  moveq    #7,d0
     lea      PERCENT,a0
     bra      .40
; case '&': "AND"
.48  moveq    #3,d0
     lea      AND,a0
     bra      .40
; case '\'': "RIGHT QUOTE"
.49  moveq    #11,d0
     lea      RQUOTE,a0
     bra     .40
; case '(': "LEFT PARENTHESIS"
.50  moveq    #16,d0
     lea      LP,a0
     bra      .40
; case ')': "RIGHT PARENTHESIS"
.51  moveq    #17,d0
     lea      RP,a0
     bra      .40
; case '*': "STAR"
.52  moveq    #4,d0
     lea      STAR,a0
     bra      .40
; case '+': "PLUS"
.53  moveq    #4,d0
     lea      PLUS,a0
     bra      .40
; case ',': "COMMA"
.54  moveq    #5,d0
     lea      COMMA,a0
     bra      .40
; case '-': "MYNUS"
.55  moveq    #5,d0
     lea      MYNUS,a0
     bra      .40
; case '.': "DOT"
.56  moveq    #3,d0
     lea      DOT,a0
     bra      .40
; case '/': "SLASH"
.57  moveq    #5,d0
     lea      SLASH,a0
     bra      .40
; case ':': "COLON"
.58  moveq    #5,d0
     lea      COLON,a0
     bra      .40
; case ';': "SEMI COLON"
.59  moveq    #10,d0
     lea      SCOLON,a0
     bra      .40
; case '<': "LESS THAN"
.60  moveq    #9,d0
     lea      LESS,a0
     bra      .40
; case '>': "GREATER THAN"
.61  moveq    #12,d0
     lea      GREAT,a0
     bra      .40
; case '=': "EQUAL"
.62  moveq    #5,d0
     lea      EQUAL,a0
     bra      .40
; case '?': "QUESTION"
.63  moveq    #8,d0
     lea      QUES,a0
     bra.s    .40
; case '@': "AT"
.64  moveq    #2,d0
     lea      AT,a0
     bra.s    .40
; case '[': "LEFT BRACKET"
.65  moveq    #12,d0
     lea      LBRACK,a0
     bra.s    .40
; case '\\': "BACKSLASH"
.66  moveq    #9,d0
     lea      BSLASH,a0
     bra.s    .40
; case ']': "RIGHT BRACKET"
.67  moveq    #13,d0
     lea      RBRACK,a0
     bra.s    .40
; case '^': "CARROT"
.68  moveq    #6,d0
     lea      CARROT,a0
     bra.s    .40
; case '_': "UNDER SCORE"
.69  moveq    #11,d0
     lea      SCORE,a0
     bra.s    .40
; case '`': "LEFT QUOTE"
.70  moveq    #10,d0
     lea      LQUOTE,a0
     bra.s    .40
; case '{': "LEFT BRACE"
.71  moveq    #10,d0
     lea      LBRACE,a0
     bra.s    .40
; case '|': "VERTICAL BAR"
.72  moveq    #12,d0
     lea      VBAR,a0
     bra.s    .40
; case '}': "RIGHT BRACE"
.73  moveq    #11,d0
     lea      RBRACE,a0
     bra.s    .40
; case '~': "TILDA"
.74  moveq    #5,d0
     lea      TILDA,a0
     bra.s    .40
; case $7f: "DELETE"
.75  moveq    #6,d0
     lea      DEL,a0
.40  movea.l  _TranslatorBase,a6
     moveq    #100,d1
     lea      _OutputString,a1
     jsr      _LVOTranslate(a6)
  ;---WriteNarrator's io_Data = address of OutputString
DOIT lea      _OutputString,a0
     movea.l  _WriteNarrator,a1
     move.l   a0,40(a1)
     move.l   a0,d0
  ;---WriteNarrator's io_Length = length of OutputString
CNT  move.b   (a0)+,d1
     bne.s    CNT
     subq.l   #1,a0
     sub.l    d0,a0
     move.l   a0,36(a1)
  ;----And speak it
     movea.l  _SysBase,a6
     jsr      _LVODoIO(a6)
;===============================================
  ;---indicate one less event in the buffer
.25  subq.b   #1,Counter
  ;---Check for Buffer wrap
     addq.w   #1,_Emptier
     moveq    #50,d0
     sub.w    _Emptier,d0
     bhi      TheBigLoop   ;back to main loop
     clr.w    _Emptier
     bra      TheBigLoop

;**************************************************************
; Clean up all allocated resources and exit

   XDEF   _CleanUp_Exit
_CleanUp_Exit:
     move.l   d0,-(sp)     ;push return code
     movea.l  _SysBase,a6
;=======Remove our input handler and device from the chain======
     move.l   _InputRequestBlock,d0
     beq.s    .115
  ;---InputRequestBlock's io_Command = IND_REMHANDLER
     movea.l  d0,a1
     moveq    #10,d0
     move.w   d0,28(a1)
  ;---InputRequestBlock's io_Data = address of handlerInt
     move.l   #handlerInt,40(a1)
     jsr      _LVODoIO(a6)
   ;----Close Input Device
     Bclr.b   #0,DevicesOpen
     beq.s    .116
     movea.l  _InputRequestBlock,a1
     jsr      _LVOCloseDevice(a6)
  ;---Free the main signal
.116 move.b   _MainSignal,d0
     bmi.s    .FS
     jsr      _LVOFreeSignal(a6)
   ;----DeleteStdIO InputRequestBlock
.FS  move.l   _InputRequestBlock,-(sp)
     jsr      _DeleteStdIO
     addq.w   #4,sp
   ;----DeletePort InputDevPort
.115 move.l   _InputDevPort,d0
     beq.s    .117
     move.l   d0,-(sp)
     jsr      _DeletePort
     addq.w   #4,sp
   ;-----Close Narrator Device
.117 Bclr.b   #1,DevicesOpen
     beq.s    .118
     movea.l  _WriteNarrator,a1
     jsr      _LVOCloseDevice(a6)
   ;----DeleteExtIO WriteNarrator
.118 move.l   _WriteNarrator,d0
     beq.s    .119
     pea      70
     move.l   d0,-(sp)
     jsr      _DeleteExtIO
     addq.w   #8,sp
   ;----Close Translator library
.119 move.l   _TranslatorBase,d0
     beq.s    .120
     movea.l  d0,a1
     jsr      _LVOCloseLibrary(a6)
  ;----DeletePort WritePort
.120 move.l   _WritePort,d0
     beq.s    .121
     move.l   d0,-(sp)
     jsr      _DeletePort
     addq.w   #4,sp
  ;----Close Graphics
.121 move.l   _GfxBase,d0
     beq.s    .122
     movea.l  d0,a1
     jsr      _LVOCloseLibrary(a6)
.122 jsr      _exit

;*****************************************************************
; InputEvent = myhandler(EventChain,ISDATA)
;    d0                      a0       a1
; This input handler inserts itself at a higher priority than the Intuition
; handler. It will intercept all raw-key events and put them into the
; ringbuffer, EventRing, so that the main task's big_loop can use the data to
; keep track of what keys have been pressed by the user.
; This looks at all events in the EventChain and puts in the buffer all
; raw-key events whose time stamp indicates that we haven't looked at them
; before. Hopefully the system links new events at the end of the chain, so
; that all time stamps are in order.

TDNestCnt equ 295
   XREF   _LVOPermit

   XDEF   event_handler
event_handler:
     movem.l  a0/a2/a3/a6,-(sp)
     movea.l  a1,a3       ;save ISDATA (currentBuf)
  ;---Forbid
     movea.l  _SysBase,a6
  ;   addq.b   #1,TDNestCnt(a6)
  ;---Get the first InputEvent in EventChain
     movea.l  a0,a2
  ;---Check if Event's ie_Class = IECLASS_RAWKEY
.128 move.b   4(a2),d0
     subq.b   #1,d0
     bne.s    .129         ;if not, ignore it
; if Event's ie_TimeStamp.tv_micro > lastmicro AND
; Event's ie_TimeStamp.tv_secs >= lastsecond  OR
; Event's ie_TimeStamp.tv_secs >  lastsecond
     move.l   18(a2),d0
     move.l   14(a2),d1
     cmp.l    6(a3),d1    ;lastsecond
     bcs.s    .129
     bne.s    .131
     cmp.l    10(a3),d0   ;lastmicro
     bls.s    .129
  ;---Store this Event's time in our variables
.131 move.l   d0,10(a3)
     move.l   d1,6(a3)
  ;---Make our own copy of the event in the EventRing buffer
     moveq    #11-1,d0     ;size of an amiga InputEvent = 22 bytes, but we
     movea.l  a2,a1        ;can copy a WORD at a time with even addresses.
     movea.l  (a3),a0      ;get current address within EventRing
cpyE move.w   (a1)+,(a0)+
     Dbra     d0,cpyE
  ;---Indicate that there's one more item in the EventRing buffer
     addq.b   #1,4(a3)     ;Counter
  ;---Check for buffer wrap (at the end of EventRing?)
     move.l   a3,d0        ;end of EventRing
     sub.l    a0,d0
     bhi.s    .134
     lea      _EventRing,a0
  ;---Save next address within EventRing
.134 move.l   a0,(a3)
;---Is the main task's big_loop asleep?
     Bclr.b   #0,5(a3)      ;Waiting
     beq.s    .136
  ;---If so, wake up main
     move.l   14(a3),d0     ;MainSigMask
     movea.l  _ThisTask,a1
     jsr      _LVOSignal(a6)
; The buffer may fill eventually. In case that happens, do some waits
; to give the main task some time to empty the buffer a bit. A completely
; busy loop would tie up the system forever.
.136 moveq    #47,d0
     sub.b    4(a3),d0
     bcc.s    .129
     move.l   a6,-(sp)
     movea.l  _GfxBase,a6
     jsr      _LVOWaitTOF(a6)
     jsr      _LVOWaitTOF(a6)
     jsr      _LVOWaitTOF(a6)
     movea.l  (sp)+,a6
     bra.s    .136
   ;---Get Event's ie_NextEvent (i.e. the next InputEvent in the list)
.129 movea.l  (a2),a2
   ;---any more events?
     move.l   a2,d0
     bne.s    .128        ;go back if more
   ;  jsr      _LVOPermit(a6)
     movem.l  (sp)+,a0/a2/a3/a6
   ;----return EventChain
     move.l   a0,d0
     rts

   SECTION TypeTellData,DATA

INPUT_RING_SIZE equ 50    ;# of InputEvents that can fit in EventRing buffer
QUIT_CODE_1     equ $8099 ;Control-shift-alt-alt's event qualifier
QUIT_CODE_2     equ $809d ;As above but with Caps-Lock ON

   XDEF   _InputDevPort,_InputRequestBlock,DevicesOpen
_InputDevPort      dc.l 0 ;address of replyPort for input device
_InputRequestBlock dc.l 0 ;address of IOB for input device

;----Interrupt Structure for event_handler routine------
   XDEF handlerInt
handlerInt  dc.l 0,0                   ;to maintain a linked list
            dc.b 2,51                  ;LN_TYPE, LN_PRIORITY
            dc.l 0                     ;LN_NAME
            dc.l currentBuf            ;IS_DATA
            dc.l event_handler         ;IS_CODE

 ;These must be in this order
   XDEF   currentBuf,_Emptier,Counter,lastsecond,lastmicro,_EventRing
   XDEF   _MainSignal,_Waiting,MainSigMask
   XDEF   _TranslatorBase,_ConsoleDevice,_GfxBase
;Raw key events buffer that can hold up to 50 InputEvents (of 22 bytes each)
_EventRing  ds.b 1100
currentBuf  dc.l _EventRing  ;for event_handler()
Counter     dc.b 0           ;for both event_handler() and main()
_Waiting    dc.b 0           ;set by main() before going to sleep
lastsecond  dc.l 0
lastmicro   dc.l 0           ;For event_handler() routine
MainSigMask dc.l 0           ;for event_handler to wake up main()
_Emptier    dc.w 0           ;for main()
DevicesOpen dc.b 0
_MainSignal dc.b $FF
_GfxBase        dc.l 0
_TranslatorBase dc.l 0
_ConsoleDevice  dc.l 0

   XDEF   _WriteNarrator,_WritePort
_WriteNarrator      dc.l 0  ;IOB for narrator device
_WritePort          dc.l 0  ;output port for narrator device

   XDEF   _AudioChannels
_AudioChannels:
   dc.b   3,5,10,12

;Translated output string buffer
_OutputString ds.b 100
rawkeyBuf     ds.b 30
InputName   dc.b 'input.device',0
GfxName     dc.b 'graphics.library',0
TransName   dc.b 'translator.library',0
ConsoleName dc.b 'console.device',0
NarrDevName dc.b 'narrator.device',0
CAPSON      dc.b 'CAPS LOCK ON',0
CAPSOFF     dc.b 'CAPS LOCK OFF',0
GODOWN      dc.b 'GO DOWN',0
GORIGHT     dc.b 'GO RIGHT',0
GOLEFT      dc.b 'GO LEFT',0
GOUP        dc.b 'GO UP',0
HELP        dc.b 'HELP',0
CONTROL     dc.b 'CONTROL',0
SHIFT       dc.b 'SHIFT',0
RIGHTAMG    dc.b 'RIGHT AMIGA',0
LEFTAMG     dc.b 'LEFT AMIGA',0
ALTERNATE   dc.b 'ALTERNATE',0
F10         dc.b 'FUNCTION TEN',0
F9          dc.b 'FUNCTION NINE',0
F8          dc.b 'FUNCTION EIGHT',0
F7          dc.b 'FUNCTION SEVEN',0
F6          dc.b 'FUNCTION SIX',0
F5          dc.b 'FUNCTION FIVE',0
F4          dc.b 'FUNCTION FOUR',0
F3          dc.b 'FUNCTION THREE',0
F2          dc.b 'FUNCTION TWO',0
F1          dc.b 'FUNCTION ONE',0
ESCAPE      dc.b 'ESCAPE',0
EXCLAM      dc.b 'EXCLAMATION',0
DQ          dc.b 'DOUBLE QUOTE',0
SHARP       dc.b 'SHARP',0
SPACE       dc.b 'SPACE',0
DOLLAR      dc.b 'DOLLAR',0
PERCENT     dc.b 'PERCENT',0
VBAR        dc.b 'VERTICAL BAR',0
RBRACE      dc.b 'RIGHT BRACE',0
LBRACE      dc.b 'LEFT BRACE',0
TILDA       dc.b 'TILDA',0
DEL         dc.b 'DELETE',0
LQUOTE      dc.b 'LEFT QUOTE',0
SCORE       dc.b 'UNDER SCORE',0
CARROT      dc.b 'CARROT',0
RBRACK      dc.b 'RIGHT BRACKET',0
BS          dc.b 'BACKSPACE',0
BSLASH      dc.b 'BACKSLASH',0
QUES        dc.b 'QUESTION',0
AT          dc.b 'AT',0
LBRACK      dc.b 'LEFT BRACKET',0
SCOLON      dc.b 'SEMI COLON',0
EQUAL       dc.b 'EQUAL',0
GREAT       dc.b 'GREATER THAN',0
LESS        dc.b 'LESS THAN',0
COLON       dc.b 'COLON',0
SLASH       dc.b 'SLASH',0
DOT         dc.b 'DOT',0
STAR        dc.b 'STAR',0
PLUS        dc.b 'PLUS',0
MYNUS       dc.b 'MYNUS',0
COMMA       dc.b 'COMMA',0
RP          dc.b 'RIGHT PARENTHESIS',0
LP          dc.b 'LEFT PARENTHESIS',0
AND         dc.b 'AND',0
RQUOTE      dc.b 'RIGHT QUOTE',0

   END

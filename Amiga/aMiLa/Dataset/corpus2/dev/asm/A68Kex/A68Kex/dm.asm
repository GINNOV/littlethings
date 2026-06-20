*
* This is a remake of
*
*  :ts=8 bk=0
* Disk mapper.  Uses trackdisk.device to grab and read sector bitmap
* to discover what's allocated, then displays a (hopefully) pretty picture
* showing disk useage.
*
* Crufted together by Leo Schwab while desperately bored.  8606.8
* Turned into something working for the Manx compiler.  8607.23
*
* from AmigaLibDisk33
* with a few minor enhancements.
*
* This implementation was written by:
* E. Lenz
* Johann-Fichte-Strasse 11
* 8 Munich 40
* Germany
*

_AbsExecBase        equ 4

**** exec *****

_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOAllocMem     equ -$c6
_LVOFreeMem      equ -$d2
_LVOAddPort      equ -$162
_LVORemPort      equ -$168
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e
_LVOOpenDevice   equ -$1bc
_LVOCloseDevice  equ -$1c2
_LVODoIO         equ -$1c8
_LVOOpenLibrary  equ -$228

**** intuition ******

_LVOCloseWindow    equ -$48
_LVOOpenWindow     equ -$cc
_LVOSetMenuStrip   equ -$108

***** graphics ******

_LVOText            equ -$3c
_LVOMove            equ -$f0
_LVODraw            equ -$f6
_LVORectFill        equ -$132
_LVOSetAPen         equ -$156

***** dos *****

_LVOLock          equ -$54
_LVOUnLock        equ -$5a
_LVOInfo          equ -$72

ACCESS_READ        equ -2
ID_NO_DISK_PRESENT equ -1
MEMF_CHIP          equ 2
TD_MOTOR           equ 9
TD_CHANGENUM       equ $d
wd_RPort           equ $32
wd_UserPort        equ $56
pr_MsgPort         equ $5c
pr_CLI             equ $ac
ThisTask           equ $114
VBlankFrequency    equ $212
MEMF_CLEAR         equ $10000

BITMAPINDEX        equ 79*4

long             set 4
InfoData         set 0
id_NumSoftErrors set InfoData
InfoData         set InfoData+long
id_UnitNumber    set InfoData
InfoData         set InfoData+long
id_DiskState     set InfoData
InfoData         set InfoData+long
id_NumBlocks     set InfoData
InfoData         set InfoData+long
id_NumBlocksUsed set InfoData
InfoData         set InfoData+long
id_BytesPerBlock set InfoData
InfoData         set InfoData+long
id_DiskType      set InfoData
InfoData         set InfoData+long
id_VolumeNode    set InfoData
InfoData         set InfoData+long
id_InUse         set InfoData
InfoData         set InfoData+long
id_SIZEOF        set InfoData

       XREF request

       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0 for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)
       move.l  d0,WBenchMsg

isCLI  cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
       beq.s   isNTSC
       move.w  #256,nw+6

isNTSC lea     GfxName(pc),a1        open graphics library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,GfxBase
       beq.s   Gexit

       lea     IntName(pc),a1        open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,IntBase
       beq.s   Gexit

       lea     DosName(pc),a1        open dos library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,DosBase
Gexit  beq     exit

Trok   lea     nw(pc),a0             open window
       movea.l IntBase(pc),a6
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
       beq.s   Gexit


; Set menu

       movea.l d0,a0           which window
       lea     Menu1(pc),a1    which menu
       jsr     _LVOSetMenuStrip(a6)

       movea.l window(pc),a0
       movea.l wd_RPort(a0),a5

       bra.s   disk            initialize with DF0:

wait   movea.l _AbsExecBase,a6
       moveq   #0,d7
       movea.l window(pc),a0
       movea.l wd_UserPort(a0),a0  load Window.UserPort
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   wait         No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in d7

       beq.s   wait
       cmpi.l  #$200,d7
       beq.s   exit

       cmpi.l  #$100,d7
       bne.s   wait

; Choice from menu

       movea.l window(pc),a0
       movea.l $5e(a0),a0   Load Window.MessageKey
       move.w  $18(a0),d0   Load message code
       move.w  d0,d1
       andi.w  #$f,d1
       bne.s   wait

       andi.w  #$f0,d0      Menu 1
       bne.s   menu12       Submenu 1
disk   move.l  #'DF0:',d0
gwait  lea     buf(pc),a0
       move.l  d0,(a0)+
       clr.l   (a0)
       bsr     Map
       bra.s   wait

menu12 cmpi.w  #$20,d0      Submenu 2
       bne.s   menu13
       move.l  #'DF1:',d0
       bra.s   gwait

menu13 cmpi.w  #$40,d0      Submenu 3
       bne.s   menu14
       move.l  #'DF2:',d0
       bra.s   gwait

menu14 cmpi.w  #$60,d0      Submenu 4
       bne.s   wait
       move.l  #'DF3:',d0
       bra.s   gwait

exit   movea.l IntBase(pc),a6
       move.l  window(pc),d0
       beq.s   noWin
       movea.l d0,a0
       jsr     _LVOCloseWindow(a6)    close window

noWin  movea.l _AbsExecBase,a6
       tst.l   WBenchMsg
       beq.s   NoBenh
       jsr     _LVOForbid(a6)       reply to WB
       movea.l WBenchMsg(pc),a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

NoBenh move.l  IntBase(pc),d1       close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  GfxBase(pc),d1       close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  move.l  DosBase(pc),d1       close dos library
       beq.s   NoDos
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

NoDos  moveq   #0,d0                no error
       rts

************************
* Disk Map
************************

Error  movem.l a4-a5,-(a7)
       suba.l  a1,a1             no second line
       suba.l  a2,a2             no third line
       lea     hdtxt(pc),a3      header
       lea     OkTxt(pc),a4      gadget text
       suba.l  a5,a5             no 2nd gadget
       moveq   #0,d0
       moveq   #1,d1
       jsr     request
       movem.l (a7)+,a4-a5
       rts

Map    lea     free(pc),a0        initilize free sectors
       move.l  #1758,(a0)
       movea.l DosBase(pc),a6     get the unit number from the
       lea     buf(pc),a0         device name
       move.l  a0,d1
       move.l  #ACCESS_READ,d2
       jsr     _LVOLock(a6)
       lea     nolock(pc),a0
       move.l  d0,lok
       beq.s   Error

       movea.l _AbsExecBase,a6
       moveq   #id_SIZEOF,d0
       move.l  #MEMF_CLEAR,d1
       jsr     _LVOAllocMem(a6)
       lea     nomem(pc),a0
       movea.l d0,a4
       tst.l   d0
       beq.s   Error

       movea.l DosBase(pc),a6
       move.l  lok(pc),d1
       move.l  d0,d2
       jsr     _LVOInfo(a6)

       lea     nodisk(pc),a0
       move.l  id_DiskType(a5),d0
       cmp.l   #ID_NO_DISK_PRESENT,d0
GoErr  beq.s   Error

       move.l  id_UnitNumber(a4),unit

       movea.l _AbsExecBase,a6
       movea.l a4,a1
       moveq   #id_SIZEOF,d0
       jsr     _LVOFreeMem(a6)             made it!

       lea     reply(pc),a1                get a reply port
       move.l  ThisTask(a6),$10(a1)
       jsr     _LVOAddPort(a6)

       lea     TrackName(pc),a0            open trackdisk device
       move.l  unit(pc),d0
       lea     diskio(pc),a1
       moveq   #0,d1
       jsr     _LVOOpenDevice(a6)
       lea     noget(pc),a0
       tst.l   d0
       bne     Error

       move.l  #1024,d0                     allocate disk buffer
       move.l  #MEMF_CLEAR|MEMF_CHIP,d1
       jsr     _LVOAllocMem(a6)
       lea     nobuf(pc),a0
       move.l  d0,diskbuffer
       beq.s   GoErr

       moveq   #0,d0                 get boot block
       bsr     GetSec
       movea.l diskbuffer(pc),a0
       move.l  (a0),d0
       cmpi.l  #'DOS'*$100,d0         check if boot disk
       bne.s   stand                 (accept only DOS disks)
       move.l  8(a0),d0              bitmap sector if check sum ok
       cmpi.l  #1760,d0              can't be more than 1759
       bcc.s   stand
       moveq   #0,d2
       move.w  #$ff,d1
check  add.l   (a0)+,d2              see if check sum ok
       bcc.s   noc
       addq.l  #1,d2
noc    dbra    d1,check
       not.l   d2
       beq.s   nostd
stand  move.l  #880,d0               assume standard root block
nostd  bsr     GetSec
       movea.l diskbuffer(pc),a0
       move.l  BITMAPINDEX(a0),d0
       move.l  d0,sectno             remember bitmap sector
       bsr     GetSec

       lea     reply(pc),a1
       jsr     _LVORemPort(a6)        remove reply port

       lea     diskio(pc),a1
       jsr     _LVOCloseDevice(a6)    close trackdisk device

       movea.l DosBase(pc),a6         unlock disk
       move.l  lok(pc),d1
       jsr     _LVOUnLock(a6)

***********************************************
*
* now all we have to do is display the bitmap
*
***********************************************
XX     equ         6
YY     equ         6
XOFF   equ         30
YOFF   equ         25


       movea.l GfxBase(pc),a6  clear screen
       moveq   #0,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)

       movea.l a5,a1
       moveq   #0,d0
       moveq   #0,d1
       move.l  #640,d2
       move.l  #250,d3
       jsr     _LVORectFill(a6)

       movea.l a5,a1
       moveq   #3,d0
       jsr     _LVOSetAPen(a6)

       movea.l a5,a1
       moveq   #XOFF,d0
       moveq   #YOFF,d1
       moveq   #XX,d2
       add.l   d0,d2
       moveq   #YY,d3
       add.l   d3,d3
       add.l   d1,d3
       jsr     _LVORectFill(a6)

i equr d7
k equr d6
n equr d5
NUMLONGS  equ 880/16

       moveq   #1,i
loop1  movea.l diskbuffer(pc),a0
       move.l  i,k
       asl.l   #2,k
       move.l  0(a0,k.l),k
       moveq   #0,n
loop2  cmpi.l  #NUMLONGS,i
       blt.s   doit
       cmpi.l  #30,n
       bge.s   dont
doit   move.l  k,d0
       not.l   d0
       and.l   #1,d0
       beq.s   next

       move.l  i,d4
       subq.l  #1,d4
       asl.l   #5,d4
       add.l   n,d4
       addq.l  #2,d4       l = (i-1 << 5) + n + 2;

       move.l  d4,d1
       divu    #22,d1
       moveq   #0,d0
       move.w  d1,d0
       mulu    #XX,d0
       add.l   #XOFF,d0    x = (l / 22) * XX + XOFF;

       move.l  d4,d2
       divu    #22,d2
       swap    d2
       moveq   #0,d1
       move.w  d2,d1
       mulu    #YY,d1
       add.l   #YOFF,d1     y = (l % 22) * YY + YOFF;

BRKOVER  equ       91
SEP      equ       6

       cmpi.l  #BRKOVER,d1
       blt.s   nosep
       addi.l  #SEP,d1      if (y >= BRKOVER) y += SEP;

nosep  move.l  d0,d2
       addi.l  #XX-1,d2
       move.l  d1,d3
       addi.l  #YY-1,d3
       movea.l a5,a1
       jsr     _LVORectFill(a6)   RectFill (rp, x, y, x+XX-1, y+YY-1);
       sub.l   #1,free

next   asr.l   #1,k
dont   addq    #1,n
       cmpi.l  #32,n
       blt     loop2
       addq    #1,i
       cmpi.l  #NUMLONGS,i
       ble     loop1

**************
*
* Draw grid
*
**************

       movea.l a5,a1
       moveq   #1,d0
       jsr     _LVOSetAPen(a6)

x equr d7

       moveq   #XOFF,x
xloop  movea.l a5,a1
       move.l  x,d0
       moveq   #YOFF,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  x,d0
       moveq   #YOFF,d1
       addi.l  #11*YY,d1
       jsr     _LVODraw(a6)
       movea.l a5,a1
       move.l  x,d0
       move.l  #BRKOVER+SEP,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  x,d0
       move.l  #BRKOVER+SEP,d1
       add.l   #11*YY,d1
       jsr     _LVODraw(a6)
       addq.l  #XX,x
       cmpi.l  #80*XX+XOFF,x
       ble.s   xloop

y equr d7

       moveq   #0,y
yloop  movea.l a5,a1
       move.l  #XOFF,d0
       move.l  y,d1
       add.l   #YOFF,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF+80*XX,d0
       move.l  y,d1
       add.l   #YOFF,d1
       jsr     _LVODraw(a6)
       movea.l a5,a1
       move.l  #XOFF,d0
       move.l  y,d1
       add.l   #BRKOVER+SEP,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF+80*XX,d0
       move.l  y,d1
       add.l   #BRKOVER+SEP,d1
       jsr     _LVODraw(a6)
       addq.l  #YY,y
       cmpi.l  #11*YY,y
       ble.s   yloop

       movea.l a5,a1
       move.l  #XOFF+XX/2,d0
       moveq   #YOFF,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF+XX/2,d0
       moveq   #YOFF-3,d1
       jsr     _LVODraw(a6)

       movea.l a5,a1
       move.l  #XOFF+80*XX-XX/2,d0
       moveq   #YOFF,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF+80*XX-XX/2,d0
       moveq   #YOFF-3,d1
       jsr     _LVODraw(a6)

       movea.l a5,a1
       move.l  #XOFF,d0
       moveq   #YOFF+YY/2,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF-3,d0
       moveq   #YOFF+YY/2,d1
       jsr     _LVODraw(a6)

       movea.l a5,a1
       move.l  #XOFF,d0
       moveq   #YOFF+YY*10+YY/2,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  #XOFF-3,d0
       moveq   #YOFF+YY*10+YY/2,d1
       jsr     _LVODraw(a6)

       movea.l a5,a1
       move.l  #XOFF-1,d0
       moveq   #YOFF-3,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text1(pc),a0
       moveq   #1,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #XOFF+79*XX-1,d0
       moveq   #YOFF-3,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text2(pc),a0
       moveq   #2,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #XOFF-12,d0
       moveq   #YOFF+6,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text1(pc),a0
       moveq   #1,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #XOFF-20,d0
       moveq   #YOFF+11*YY,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text3(pc),a0
       moveq   #2,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #520,d0
       moveq   #60,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text4(pc),a0
       moveq   #9,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #520,d0
       move.l  #132,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text5(pc),a0
       moveq   #9,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #XOFF,d0
       move.l  #176,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text6(pc),a0
       moveq   #17,d0
       jsr     _LVOText(a6)
       move.l  sectno(pc),d0
       bsr     ShowPr

       movea.l a5,a1
       move.l  #250,d0
       move.l  #176,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text7(pc),a0
       moveq   #14,d0
       jsr     _LVOText(a6)
       move.l  free(pc),d0
       bsr     ShowPr

       movea.l a5,a1
       move.l  #450,d0
       move.l  #176,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text8(pc),a0
       moveq   #11,d0
       jsr     _LVOText(a6)
       move.l  #1760,d0
       sub.l   free(pc),d0
       bsr     ShowPr

       movea.l a5,a1
       move.l  #520,d0
       moveq   #60,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text4(pc),a0
       moveq   #9,d0
       jsr     _LVOText(a6)

       movea.l a5,a1
       move.l  #520,d0
       move.l  #132,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       lea     text5(pc),a0
       moveq   #9,d0
       jsr     _LVOText(a6)

       move.l  #1024,d0                free disk buffer
       movea.l diskbuffer(pc),a1
       movea.l _AbsExecBase,a6
       jsr     _LVOFreeMem(a6)

       rts

GetSec lea     diskio(pc),a1          get a sector from disk
       lea     reply(pc),a0
       move.l  a0,14(a1)
       move.w  #2,28(a1)
       move.l  diskbuffer(pc),40(a1)
       move.l  #1024,36(a1)
       mulu    #512,d0
       move.l  d0,44(a1)
       jsr     _LVODoIO(a6)

       lea     diskio(pc),a1         switch motor off
       move.w  #TD_MOTOR,28(a1)
       clr.l   36(a1)
       jsr     _LVODoIO(a6)
       rts

********************************************
*                                          *
* Write number in d0 as decimal to console *
*                                          *
********************************************


ShowPr movem.l d0-d3/a0-a1,-(a7)
       tst.l   d0                 zero is a special case
       beq.s   zero
       lea     Prime(pc),a1
       movea.l a1,a0
       move.l  #'0000',d1
       move.l  d1,(a1)+
       move.l  d1,(a1)+
       move.l  d1,(a1)+
       lea     Num(pc),a1
plop   move.l  (a1)+,d1
       addq.l  #1,a0
pnext  cmp.l   d1,d0
       bcs.s   plop
       sub.l   d1,d0
       addq.b  #1,(a0)
       tst.l   d0
       bne.s   pnext
       lea     Prime(pc),a0
       moveq   #11,d0
ptest  cmpi.b  #'0',(a0)
       bne.s   endp
       subq.l  #1,d0
       addq.l  #1,a0
       bra.s   ptest
endp   movea.l a5,a1
       jsr     _LVOText(a6)
       movem.l (a7)+,d0-d3/a0-a1
       rts

zero   lea     Prime(pc),a0
       move.w  #'00',(a0)
       moveq   #1,d0
       bra.s   endp

Num       dc.l 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10,1

nolock      dc.b "Can't obtain lock.",0
            even
nomem       dc.b "Can't get InfoData memory.",0
            even
noinfo      dc.b 'Call to Info() failed.',0
            even
nodisk      dc.b 'No disk in drive.',0
            even
noget       dc.b "Can't get at disk.",0
            even
nobuf       dc.b "Can't allocate disk buffer.",0
            even

text8       dc.b 'Allocated: '
text7       dc.b 'Sectors free: '
text6       dc.b 'Bitmap on sector '
text2       dc.b '79'
text4       dc.b 'Surface 0'
text5       dc.b 'Surface '
text3       dc.b '1'
text1       dc.b '0'
            even

diskio
message     ds.w 10
io          ds.w 6
ioreq       ds.w 8
reply       ds.l 8

WBenchMsg   dc.l 0
DosBase     dc.l 0
GfxBase     dc.l 0
IntBase     dc.l 0
lok         dc.l 0
unit        dc.l 0
diskbuffer  dc.l 0
sectno      dc.l 0
free        dc.l 0
window      dc.l 0

; requester texts

hdtxt       dc.b ' DiskMapper Request',0
OkTxt       dc.b ' OK',0
            even

buf
DosName     dc.b 'dos.library',0
            even

Prime
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
TrackName   dc.b 'trackdisk.device',0
            even

title       dc.b  'Disk Allocation Map',0
            even

***** Window definition *****

nw          dc.w 0,0         Position left,top
            dc.w 640,199     Size width,height
            dc.b 0,1         Colors detail-,block pen
            dc.l $340        IDCMP-Flags
            dc.l $140f       Window flags
            dc.l 0           ^Gadget
            dc.l 0           ^Menu check
            dc.l title       ^Window name
nws         dc.l 0           ^Screen structure,
            dc.l 0           ^BitMap
            dc.w 100         MinWidth
            dc.w 40          MinHeight
            dc.w -1          MaxWidth
            dc.w -1,1        MaxHeight,Screen type

**** menu definition ****

Menu1       dc.l 0           Next menu
            dc.w 50,0        Position left edge,top edge
            dc.w 50,20       Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext1      Text for menu header
            dc.l item11      ^First in chain
            dc.l 0,0         Internal

mtext1      dc.b 'Disk',0
            even

item11      dc.l item12      next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 50,10       Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I11txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I11txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item11txt   Pointer to text
            dc.l 0           Next text

item11txt   dc.b 'DF0:',0
            even

item12      dc.l item13      next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 50,10       Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I12txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I12txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item12txt   Pointer to text
            dc.l 0           Next text

item12txt   dc.b 'DF1:',0
            even

item13      dc.l item14      next in chained list
            dc.w 0,20        Position left edge,top edge
            dc.w 50,10       Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I13txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I13txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item13txt   Pointer to text
            dc.l 0           Next text

item13txt   dc.b 'DF2:',0
            even

item14      dc.l 0           next in chained list
            dc.w 0,30        Position left edge,top edge
            dc.w 50,10       Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I14txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I14txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item14txt   Pointer to text
            dc.l 0           Next text

item14txt   dc.b 'DF3:',0
            even
            end



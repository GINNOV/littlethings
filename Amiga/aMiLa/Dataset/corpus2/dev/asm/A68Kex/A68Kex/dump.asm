***************************************
*                                     *
*        DUMP memory contents         *
*                                     *
* written by E. Lenz                  *
*            Johann-Fichte-Strasse 11 *
*            8 Munich 40              *
*            Germany                  *
*                                     *
***************************************



*****************************************************
*               The FIND function
* The find function is rather slow and cannot be
* stopped (try searching 16MB) but it searches all of
* memory (excepting the RTC and custom chip areas:
* $C80000 - $D7FFFF and $DC0000 - $DFFFFF )
* so nothing can be hidden. Although my Buffer will
* not be found by find, it always finds a replica
* used by DOS.
*****************************************************

 XREF Disasm1,file,load,_Request

; EXEC.library routines

_AbsExecBase       equ 4
_LVOForbid         equ -$84
_LVOPermit         equ -$8a
_LVOAllocMem       equ -$c6
_LVOFreeMem        equ -$d2
_LVOWait           equ -$13e
_LVOGetMsg         equ -$174
_LVOReplyMsg       equ -$17a
_LVOWaitPort       equ -$180
_LVOCloseLibrary   equ -$19e
_LVOOpenLibrary    equ -$228

; GRAPHICS.library routines

_LVOText           equ -$3c
_LVOMove           equ -$f0

; INTUITION.library routines

_LVOCloseWindow    equ -$48
_LVOOpenWindow     equ -$cc
_LVOSetMenuStrip   equ -$108

; DOS.library routines

_LVOOpen         equ -$1e
_LVOClose        equ -$24
_LVORead         equ -$2a
_LVOWrite        equ -$30

wd_UserPort     equ $56
pr_MsgPort      equ $5c
pr_CLI          equ $ac
ThisTask        equ $114
VBlankFrequency equ $212

             code

             movea.l _AbsExecBase,a6

; Start from Workbench ?

             moveq   #0,d0
             movea.l ThisTask(a6),a4
             tst.l   pr_CLI(a4)
             bne.s   OpenLibs   Not from WB

; Get WB Message

             lea     pr_MsgPort(a4),a0
             jsr     _LVOWaitPort(a6)
             jsr     _LVOGetMsg(a6)


; Open librarys


OpenLibs     move.l  d0,-(a7)

             cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
             beq.s   isNTSC
             move.w  #256,NewWindow+6

isNTSC       lea     GfxName(pc),a1   Open graphics.library
             moveq   #0,d0
             jsr     _LVOOpenLibrary(a6)
             move.l  d0,GfxBase   Save graphics base address
             beq.s   Gexit

             lea     DosName(pc),a1    Open dos.library
             moveq   #0,d0
             jsr     _LVOOpenLibrary(a6)
             move.l  d0,DosBase
             beq.s   Gexit

             lea     IntuitionName(pc),a1 Open intuition.library
             moveq   #0,d0
             jsr     _LVOOpenLibrary(a6)
             move.l  d0,IntuitionBase Save intuition base address
             beq.s   Gexit

; Open window

             movea.l d0,a6         Base address = IntuitionBase
             lea     NewWindow(pc),a0
             jsr     _LVOOpenWindow(a6)
             move.l  d0,Window  Save pointer to window structure
Gexit        beq     exit

; Set menu
             movea.l d0,a0           which window
             lea     Menu1(pc),a1    which menu
             jsr     _LVOSetMenuStrip(a6)

; Initial output

             move.w  #0,Micro
             move.w  #10,Times        Initialize page multiplier
             move.w  #10,Wordl        Initialize word multiplier
             move.l  #$fc0000,MemAdr  Initialize MemAdr
             bsr     PrintMem
             movea.l _AbsExecBase,a6

; get disk buffer

             move.l  #$420,d0
             moveq   #2,d1
             jsr     _LVOAllocMem(a6)
             move.l  d0,diskbuff
             beq.s   Gexit

; Main program

Main         movea.l Window(pc),a0
             movea.l wd_UserPort(a0),a0
             move.b  $f(a0),d1   Load signal bit
             moveq   #1,d0
             lsl.l   d1,d0
             jsr     _LVOWait(a6)

MsgLoop      movea.l _AbsExecBase,a6
             movea.l Window(pc),a0
             movea.l wd_UserPort(a0),a0
             jsr     _LVOGetMsg(a6)
             tst.l   d0
             beq.s   Main          No message

             movea.l d0,a1
             move.l  $14(a1),d7       Message in a7
             movea.l IntuitionBase,a6


             cmpi.l  #4,d7       Refresh window
             bne.s   Gadget

;Refresh window

             bsr     PrintMem
             bra.s   MsgLoop

; Gadgets selected

Gadget       cmpi.l  #$40,d7
             bne     MenuPick

             movea.l Window(pc),a0
             movea.l $5e(a0),a0   Load Window.MessageKey
             movea.l $1c(a0),a0   Load pointer to Gadget
             move.w  $26(a0),d0   Load gadget ID
             move.l  Number(pc),d1

             tst.w   gagsec
             beq.s   ismem
             cmpi.w  #3,d0
             bge.s   ismem
             bsr     Gsec
             bra.s   Fresh

ismem        cmpi.w  #1,d0
             beq.s   Fresh2       Gadget #1 -> page down

             cmpi.w  #2,d0
             beq.s   Fresh3       Gadget #2 -> page back

             move.w  Times(pc),d1
             move.l  Number(pc),d2
             mulu    d2,d1
             cmpi.w  #3,d0        Gadget #3 -> forwards # pages
             bne.s   gag4
Fresh2       move.l  MemAdr(pc),d0
             add.l   d1,d0
             bra.s   Fresh1

gag4         cmpi.w  #4,d0
             bne.s   gag5
Fresh3       move.l  MemAdr(pc),d0 Gadget #4 -> back # pages
             sub.l   d1,d0
Fresh1       move.l  d0,MemAdr
Fresh        bsr     PrintMem
             bra     MsgLoop

gag5         moveq   #2,d1        Gadget #5 -> Word forward
             cmpi.w  #5,d0
             beq.s   Fresh3

             cmpi.w  #6,d0        Gadget #6 -> Word backwards
             beq.s   Fresh2

             move.w  Wordl(pc),d1
             lsl.w   #1,d1
             cmpi.w  #7,d0
             beq.s   Fresh3       Gadget #7 -> # words forward
             bne.s   Fresh2


MenuPick     cmpi.l  #$100,d7
             bne     CloseWindow

; Choice from menu

             movea.l Window(pc),a0
             movea.l $5e(a0),a0   Load Window.MessageKey
             move.w  $18(a0),d0   Load message code
             move.w  d0,d1
             andi.w  #$f,d1
             bne.s   ismenu2

             andi.w  #$f0,d0      Menu 1 set flag
             move.w  d0,AHFlag
Gfresh       bra.s   Fresh

ismenu2      cmpi.w  #1,d1
             bne.s   ismenu3
             move.w  d0,d1
             andi.w  #$f0,d0      Menu 2
             bne.s   menu22
             bsr     GetAddress   Submenu 1
             bra.s   Gfresh
menu22       cmpi.w  #$20,d0
             bne.s   menu23
             bsr     GetPage      Submenu 2
             bra.s   Gfresh
menu23       cmpi.w  #$40,d0
             bne.s   menu24
             bsr     Sword        Submenu 3
             bra.s   Gfresh
menu24       cmpi.w  #$60,d0
             bne.s   menu25
             bsr     Find         Submenu 4
             bra.s   Gfresh
menu25       cmpi.w  #$80,d0
             bne.s   menu26
             bsr     Change       Submenu 5
             bra.s   Gfresh
menu26       cmpi.w  #$a0,d0
             bne.s   Gfresh
             cmpi.w  #$a1,d1      Submenu 6
             bne.s   m1
             moveq   #0,d0        6.1 68000
             bra.s   ismic
m1           cmpi.w  #$8a1,d1
             bne.s   m2
             moveq   #1,d0        6.2 68010
             bra.s   ismic
m2           moveq   #2,d0        6.3 68020
ismic        move.w  d0,Micro
Xfresh       bra.s   Gfresh

ismenu3      cmpi.w  #2,d1         Menu 3
             bne.s   GMsg
             andi.w  #$f0,d0
             bne.s   menu32
             bsr     loads         Submenu 1
             bra.s   Xfresh
menu32       cmpi.w  #$20,d0
             bne.s   menu33
             move.w  Menflg(pc),d0 Submenu 2
             andi.w  #$100,d0
             move.w  d0,gagsec
GMsg         bra     MsgLoop
menu33       cmpi.w  #$40,d0
             bne.s   GMsg
             bsr     Loadf         Submenu 3
             bra.s   Xfresh

CloseWindow  cmpi.l  #$200,d7      Close window
             bne.s   GMsg

;Window closed end program

             movea.l Window(pc),a0 Close window
             jsr     _LVOCloseWindow(a6)


;Close library

exit         movea.l _AbsExecBase,a6
             move.l  diskbuff(pc),d0
             beq.s   no_disk
             movea.l d0,a1
             move.l  #$420,d0
             jsr     _LVOFreeMem(a6)

no_disk      move.l  GfxBase(pc),d0   Close graphics lib
             beq.s   No_Gfx
             movea.l d0,a1
             jsr     _LVOCloseLibrary(a6)

No_Gfx       move.l  IntuitionBase(pc),d0 Close intuition lib
             beq.s   No_Intui
             movea.l d0,a1
             jsr     _LVOCloseLibrary(a6)

No_Intui     move.l  DosBase(pc),d0    Close dos lib
             beq.s   No_Dos
             movea.l d0,a1
             jsr     _LVOCloseLibrary(a6)

No_Dos       move.l  (a7)+,d0
             beq.s   Nbench

             jsr     _LVOForbid(a6)
             movea.l d0,a1
             jsr     _LVOReplyMsg(a6)  Reply to WB
             jsr     _LVOPermit(a6)

Nbench       moveq   #0,d0    No errors
             rts

**********
* Routines
**********

; Print memory contents

PrintMem     move.l  a6,-(sp)    Save old base address
             move.l  MemAdr(pc),temp initialize memory address
             movea.l GfxBase(pc),a6  Base address = graphics base
             movea.l Window(pc),a4
             movea.l $32(a4),a5
             moveq   #8,d7        y start
prloop       moveq   #0,d0        x pos = 0
             move.l  d7,d1        y pos
             movea.l a5,a1        rastport
             jsr     _LVOMove(a6)    set cursor

             cmpi.w  #$40,AHFlag
             beq.s   Disassem
             bsr.s   convert      write into buffer
             bra.s   Print

Disassem     move.l  temp(pc),Begin
             move.l  temp(pc),RelAddr
             lea     Begin(pc),a0
             jsr     Disasm1
             move.l  Begin(pc),temp

Print        lea     Buffer(pc),a0
             moveq   #80,d0
             movea.l a5,a1
             jsr     _LVOText(a6)  print line
             addq.b  #8,d7         increment y
             move.w  d7,d0
             addi.w  #$20,d0     can we print another line?
             cmp.w   $a(a4),d0
             blt.s   prloop
             move.l  temp(pc),d0
             sub.l   MemAdr(pc),d0
             move.l  d0,Number
             movea.l (sp)+,a6    restore base address
             rts

; Convert memory content to readable

convert      movea.l temp(pc),a0       Begin of memory
             lea     Buffer(pc),a1     Begin of buffer
             lea     Buffer+43(pc),a2  Ascii display in buffer
             move.b  #$20,(a2)+        Space between hex + ASCII
             bsr.s   start

             tst.w   AHFlag
             bne.s   Ascii

             moveq   #$f,d2         Bytes per line
cloop        move.b  d2,d3
             andi.b  #3,d3
             cmpi.b  #3,d3
             bne.s   noblnk
             moveq   #$20,d3        Space after long word
             move.b  d3,(a1)+
noblnk       move.b  (a0)+,d0       get byte
             move.b  d0,d1
             cmpi.b  #$20,d1
             bge.s   isok
             moveq   #$2e,d1
isok         move.b  d1,(a2)+       write ASCII
             bsr.s   byte4          write hex
             dbeq    d2,cloop
             movea.l a2,a1
aend         move.l  a0,temp        Increment address
             moveq   #19,d0
             moveq   #$20,d1
clop         move.b  d1,(a1)+
             dbra    d0,clop
             rts

; Memory output ASCII

Ascii        moveq   #$34,d2
aloop        move.b  (a0)+,d0
             cmpi.b  #$20,d0
             bge.s   nocor
             moveq   #'.',d0
nocor        move.b  d0,(a1)+
             dbeq    d2,aloop
             bra.s   aend

; Write start address

start        move.l  a0,d0
             swap    d0
             bsr.s   byte4          1st byte of address
             move.l  a0,d0
             lsr.w   #8,d0
             bsr.s   byte4          2nd byte of address
             move.l  a0,d0
             bsr.s   byte4          3rd byte of address
             move.b  #':',(a1)+
             rts

; Convert byte to ASCII and write into buffer

byte4        move.b  d0,d1          save byte
             lsr.b   #4,d0          high half byte
             bsr.s   byte3
             move.b  d1,d0          restore byte

; Convert half byte to ASCII and write into buffer

byte3        andi.b  #$f,d0         take lower half byte
             addi.b  #$30,d0        convert to "0" - "9"
             cmpi.b  #$3a,d0        above "9"?
             blt.s   ncor
             addq.b  #7,d0          convert to "A" - "F"
ncor         move.b  d0,(a1)+       write into buffer
             rts

; Console handler

ConWind      movea.l DosBase(pc),a6
             move.l  d5,d1
             move.l  #$3ed,d2      Open for read + write
             jsr     _LVOOpen(a6)
             move.l  d0,ConHandle
             beq.s   nocon

             move.l  d0,d1
             move.l  d6,d2
             move.l  d7,d3
             jsr     _LVOWrite(a6)

             move.l  ConHandle(pc),d1
             move.l  #Buffer,d2
             moveq   #60,d3
             jsr     _LVORead(a6)

             move.l  ConHandle(pc),d1
             jsr     _LVOClose(a6)
nocon        rts

*** Get start address ***

GetAddress   move.l  #cname,d5
             move.l  #ctext,d6
             moveq   #cend-ctext,d7
             bsr.s   ConWind

; Write new memory address

             bsr.s   Reconvert
             bne.s   nmem
             move.l  d1,MemAdr
nmem         rts

*** Get page multiplier ***

GetPage      move.l  #pname,d5
             move.l  #ptext,d6
             moveq   #pend-ptext,d7
             bsr.s   ConWind

; Write new page multiplier

             bsr.s   Reconvert
             bne.s   nopage
             move.w  d1,Times
nopage       rts

*** Get word multiplier ***

Sword        move.l  #wname,d5
             move.l  #wtext,d6
             moveq   #wend-wtext,d7
             bsr     ConWind

; Write new word multiplier

             bsr.s   Reconvert
             bne.s   noword
             move.w  d1,Wordl
noword       rts

; Convert input to Hex

Reconvert    moveq   #0,d0
             moveq   #0,d2
             lea     Buffer(pc),a0
             moveq   #0,d1
             move.b  (a0)+,d0
             cmpi.b  #'$',d0    First char $?
             bne.s   read1      then ignore

readbuf      move.b  (a0)+,d0   Get next char
read1        cmpi.b  #$a,d0     End of input?
             beq.s   readend
             addq.l  #1,d2
             subi.b  #$30,d0    Convert to hex
             blt.s   nogo       Error in input
             cmpi.b  #9,d0
             ble.s   risok       0..9 ok
             cmpi.b  #16,d0
             ble.s   nogo        :..§ not ok
             subq.b  #7,d0
             cmpi.b  #15,d0
             ble.s   risok       A..F ok
             subi.b  #$20,d0
             blt.s   nogo        G..  notok
             cmpi.b  #15,d0
             bgt.s   nogo        a..f ok
risok        lsl.l   #4,d1
             add.l   d0,d1
             bra.s   readbuf

nogo         moveq   #1,d0      Nogood
             rts
readend      tst.l   d2
             beq.s   nogo       No input
             moveq   #0,d0      Is ok
             rts

; Find memory pattern

Find         move.l  #fname,d5
             move.l  #ftext,d6
             moveq   #fend-ftext,d7
             bsr     ConWind

; See what you can find

             movem.l d2-d7,-(a7)
             lea     Buffer(pc),a0  Find length of string
             moveq   #-1,d3
leng         addq.l  #1,d3
             cmpi.b  #$a,(a0)+
             bne.s   leng
             tst.l   d3         String of length 0?
             beq     nofind

             cmpi.b  #'$',Buffer First char $?
             bne.s   nodoll
             bsr     Reconvert   First convert to hex
             bne.s   nofind
             move.l  d1,Buffer
             moveq   #4,d3

nodoll       move.l  MemAdr(pc),d0
             move.l  d0,d1
             move.l  #Buffer,d2
             move.l  #$c80000,d4
             move.l  #$dc0000,d5
             sub.l   d3,d4
             sub.l   d3,d5

; d0 = current memory address
; d1 = begin of search
; d2 = begin of buffer
; d3 = length of string
; d4 = 1st custom chip area
; d5 = 2nd custom chip area
; d6 = number of corresponding characters

findloop     addq.l  #1,d0        Increment address
             andi.l  #$ffffff,d0     mod 16KB

             cmp.l   d1,d0       End of search?
             beq.s   nofind      Not found

             cmp.l   d2,d0       Begin of buffer?
             bne.s   custom
             add.l   d3,d0       Set to end of buffer

custom       cmp.l   d4,d0       Custom chips?
             bne.s   nofirst
             move.l  #$d80000,d0 Jump over custom chips

nofirst      cmp.l   d5,d0       Custom chips?
             bne.s   find1
             move.l  #$e00000,d0 Jump over rtc + custom chips

find1        moveq   #0,d6     Number of corresponding chars
             move.l  d2,a0     Begin of find string
             move.l  d0,a1     Begin of memory
inner        cmpm.b  (a0)+,(a1)+
             bne.s   findloop  No correspondence
             addq.l  #1,d6     Inc number of found chars
             cmp.l   d6,d3     Was that all?
             bne.s   inner

             move.l  d0,MemAdr String found

nofind       movem.l (a7)+,d2-d7

nof1         rts

; Change memory

Change       movea.l MemAdr(pc),a0   Write start address
             lea     haddress(pc),a1
             bsr     start

             move.l  #hname,d5
             move.l  #htext,d6
             moveq   #hend-htext,d7
             bsr     ConWind
             bsr     Reconvert
             bne.s   nochange
             movea.l MemAdr(pc),a0
             move.l  d1,(a0)
             rts

; Load file

Loadf        moveq   #0,d0
             move.l  #160,d1
             moveq   #18,d2
             lea     FileLoad(pc),a0
             jsr     _Request
             tst.l   d0
             beq.s   nochange
             jsr     file
             tst.l   d7
             bne.s   nochange
             move.l  a3,MemAdr
nochange     rts

; Load sector

loads        move.l  #jname,d5
             move.l  #jtext,d6
             moveq   #jend-jtext,d7
             bsr     ConWind
             bsr     Reconvert
             bne.s   nochange
loadss       move.l  d1,secnum
             lea     Buffer(pc),a0
             move.l  diskbuff(pc),d0
             move.l  Unitno(pc),d2
             jsr     load
             adda.l  a0,a0
             beq.s   nochange
             move.l  diskbuff(pc),MemAdr
             rts

; Get next sector

Gsec         move.l  secnum(pc),d1
             cmpi.w  #1,d0
             bne.s   subt
             addq.l  #2,d1
             bra.s   gogo
subt         subq.l  #2,d1
gogo         movea.l d1,a0
             move.l  d1,d7
             lea     Buffer(pc),a1
             bsr     start
             move.b  #$a,-(a1)
             move.l  d7,d1
             bra.s   loadss

IntuitionBase    ds.l 1        Pointer to intuition base
GfxBase          ds.l 1        Pointer to graphics base
DosBase          ds.l 1        Pointer to dos base
Window           ds.l 1        Pointer to window structure
diskbuff         ds.l 1        Pointer to disk buffer
gagsec           ds.w 1        Lock gagdets to sector mode
secnum           ds.l 1        sector number
Unitno           dc.l 0        Unit number

cname            dc.b 'CON:100/100/200/90/Start address',0
                 even
ctext            dc.b 'New start address',$d,$a
cend:
                 even

pname            dc.b 'CON:100/100/200/90/Page multiplier',0
                 even

ptext            dc.b 'New page multiplier',$d,$a
pend:
                 even

wname            dc.b 'CON:100/100/200/90/Word multiplier',0
                 even

wtext            dc.b 'New word multiplier',$d,$a
wend:
                 even

fname            dc.b 'CON:100/100/200/90/'
item24txt        dc.b 'Find',0
                 even

ftext            dc.b 'Find:',$d,$a,'$...HEX pattern'
                 dc.b $d,$a,'else ASCII pattern',$d,$a
fend:
                 even

hname            dc.b 'CON:100/100/200/90/'
item25txt        dc.b 'Change',0
                 even

htext            dc.b 'Change '
haddress         dc.b 'FFFFFF:',$d,$a
hend:
                 even

jname            dc.b 'CON:100/100/200/90/'
item31txt        dc.b 'Sector',0
                 even

jtext            dc.b 'Sector',$d,$a
jend:
                 even

item33txt        dc.b 'Load',0
                 even

FileLoad         dc.b 'dump - load a file',0
                 even

; Communication structure

Begin        ds.l 1            Begin of disassembly
RelAddr      ds.l 1            Relative address
Micro        ds.w 1            Microprocessor type
OpCode       ds.w 1            Opcode translation
Type1        ds.w 1            Type of 1st operand
Len1         ds.w 1            Length of 1st address
Addr1        ds.l 1            1st address
Type2        ds.w 1            Type of 2nd operand
Len2         ds.w 1            Length of 2nd operand
Addr2        ds.l 1            2nd address
Total        ds.w 1            Total no of bytes
Buffer       ds.b 20           Output buffer

; Once the libraries have been opened the texts are no longer
; needed so the space is reused as the output buffer


IntuitionName    dc.b 'intuition.library',0
GfxName          dc.b 'graphics.library',0
DosName          dc.b 'dos.library',0
                 even

; ***** Window definition *****

NewWindow        dc.w 0,0       Position left,top
                 dc.w 610,199   Size width,height
                 dc.b 2,1       Colors detail-,block pen
                 dc.l $344      IDCMP-Flags
                 dc.l $144f     Window flags
                 dc.l Gadget1   ^Gadget
ConHandle        dc.l 0         ^Menu check
                                ;Pointer to console handler
MemAdr           dc.l Wdname    ^Window name
                                ;Memory address (PrintMem)
Number           dc.l 0         ^Screen structure,
                                ;Display count (PrintMem)
Wind2            dc.l 0         ^BitMap
                                ;Pointer to 2nd Window structure
Times            dc.w 100       MinWidth
                                ;Page multiplier
Wordl            dc.w 40        MinHeight
                                ;Word multiplier
AHFlag           dc.w 640       MaxWidth
                                ;0 = Ascii + Hex  0 <> Ascii only
temp             dc.w 256,1     MaxHeight,Screen type
                                ;Tempory memory address (PrintMem)

Wdname           dc.b 'Dump',0
                 even

**** menu definition ****

Menu1            dc.l Menu2     Next menu
                 dc.w 50,0      Position left edge,top edge
                 dc.w 50,20     Dimensions width,height
                 dc.w 1         Menu enabled
                 dc.l mtext1    Text for menu header
                 dc.l item11    ^First in chain
                 dc.l 0,0       Internal

mtext1           dc.b 'Mode',0
                 even

item11           dc.l item12    next in chained list
                 dc.w 0,0       Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I11txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I11txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item11txt Pointer to text
                 dc.l 0         Next text

item11txt        dc.b 'ASCII and HEX',0
                 even

item12           dc.l item13    next in chained list
                 dc.w 0,10      Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I12txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I12txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item12txt Pointer to text
                 dc.l 0         Next text

item12txt        dc.b 'ASCII only',0
                 even

item13           dc.l 0         next in chained list
                 dc.w 0,20      Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I13txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I13txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item13txt Pointer to text
                 dc.l 0         Next text

item13txt        dc.b 'Disassembled',0
                 even


***** 2nd menu definition *****

Menu2            dc.l Menu3     Next menu
                 dc.w 150,0     Position left edge,top edge
                 dc.w 70,20     Dimensions width,height
                 dc.w 1         Menu enabled
                 dc.l mtext2    Text for menu header
                 dc.l item21    ^First in chain
                 dc.l 0,0       Internal

mtext2           dc.b 'Options',0
                 even


item21           dc.l item22    next in chained list
                 dc.w 0,0       Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I21txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I21txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item21txt Pointer to text
                 dc.l 0         Next text

item21txt        dc.b 'Set start',0
                 even

item22           dc.l item23    next in chained list
                 dc.w 0,10      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I22txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I22txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item22txt Pointer to text
                 dc.l 0         Next text

item22txt        dc.b 'Set page',0
                 even

item23           dc.l item24    next in chained list
                 dc.w 0,20      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I23txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I23txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item23txt Pointer to text
                 dc.l 0         Next text

item23txt        dc.b 'Set word',0
                 even

item24           dc.l item25    next in chained list
                 dc.w 0,30      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I24txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I24txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item24txt Pointer to text
                 dc.l 0         Next text


item25           dc.l item26    next in chained list
                 dc.w 0,40      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I25txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I25txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item25txt Pointer to text
                 dc.l 0         Next text

item26           dc.l 0         next in chained list
                 dc.w 0,50      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I26txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l item261
                 dc.w 0


I26txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item26txt Pointer to text
                 dc.l 0         Next text

item26txt        dc.b 'Micro',0
                 even


item261          dc.l item262   next in chained list
                 dc.w 80,0      Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $15b      itemtext+highcomp+itemenabled+checkit+checked
                 dc.l 6         Mutual exclude
                 dc.l I261txt   Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I261txt          dc.b 0          Front pen  (blue)
                 dc.b 1          Back pen   (white)
                 dc.b 0,0        Draw mode
                 dc.w 0          Left edge
                 dc.w 0          Top edge
                 dc.l 0          Text font
                 dc.l item261txt Pointer to text
                 dc.l 0          Next text

item261txt       dc.b '   68000',0
                 even

item262          dc.l item263   next in chained list
                 dc.w 80,10     Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $5b       itemtext+highcomp+itemenabled+checkit
                 dc.l 5         Mutual exclude
                 dc.l I262txt   Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I262txt          dc.b 0          Front pen  (blue)
                 dc.b 1          Back pen   (white)
                 dc.b 0,0        Draw mode
                 dc.w 0          Left edge
                 dc.w 0          Top edge
                 dc.l 0          Text font
                 dc.l item262txt Pointer to text
                 dc.l 0          Next text

item262txt       dc.b '   68010',0
                 even


item263          dc.l 0         next in chained list
                 dc.w 80,20     Position left edge,top edge
                 dc.w 80,10     Dimensions width,height
                 dc.w $5b       itemtext+highcomp+itemenabled+checkit
                 dc.l 3         Mutual exclude
                 dc.l I263txt   Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I263txt          dc.b 0          Front pen  (blue)
                 dc.b 1          Back pen   (white)
                 dc.b 0,0        Draw mode
                 dc.w 0          Left edge
                 dc.w 0          Top edge
                 dc.l 0          Text font
                 dc.l item263txt Pointer to text
                 dc.l 0          Next text

item263txt       dc.b '   68020',0
                 even

Menu3            dc.l 0         Next menu
                 dc.w 250,0     Position left edge,top edge
                 dc.w 50,20     Dimensions width,height
                 dc.w 1         Menu enabled
                 dc.l mtext3    Text for menu header
                 dc.l item31    ^First in chain
                 dc.l 0,0       Internal

mtext3           dc.b 'Disk',0
                 even

item31           dc.l item32    next in chained list
                 dc.w 0,0       Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I31txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0


I31txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item31txt Pointer to text
                 dc.l 0         Next text

item32           dc.l item33    next in chained list
                 dc.w 0,10      Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
Menflg           dc.w $5b       itemtext+highcomp+checkit+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I32txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0

I32txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item32txt Pointer to text
                 dc.l 0         Next text

item32txt        dc.b '   Gags to sec',0
                 even

item33           dc.l 0         next in chained list
                 dc.w 0,20      Position left edge,top edge
                 dc.w 120,10    Dimensions width,height
                 dc.w $52       itemtext+highcomp+itemenabled
                 dc.l 0         Mutual exclude
                 dc.l I33txt    Pointer to intuition text
                 dc.l 0
                 dc.b 0,0
                 dc.l 0
                 dc.w 0

I33txt           dc.b 0         Front pen  (blue)
                 dc.b 1         Back pen   (white)
                 dc.b 0,0       Draw mode
                 dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.l 0         Text font
                 dc.l item33txt Pointer to text
                 dc.l 0         Next text

*** Gadget definition ***

Gadget1          dc.l Gadget2   +0 Next gadget
                 dc.w 10        +4 Left edge
                 dc.w -15       +6 Top edge
                 dc.w 20        +8 Width
                 dc.w 10        +A Height
                 dc.w 8         +C Flags
                 dc.w 1         +E Activation
                 dc.w 1         +10 Gadget type
                 dc.l Border1   +12 Rendered as border or image
                 dc.l 0         +16 Select render
                 dc.l 0         +1A ^Gadget text
                 dc.l 0         +1E Mutual exclude
                 dc.l 0         +22 Special info
                 dc.w 1         +26 Gadget ID
                 dc.l 0         +28 User data

Border1          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs1    Vector coordinate pairs
                 dc.l 0         Next border

Pairs1           dc.w 0,0       Lines which constitute the gadget
                 dc.w 10,0
                 dc.w 10,8
                 dc.w 8,6
                 dc.w 10,8
                 dc.w 12,6
                 dc.w 10,8
                 dc.w 10,0
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,0

Gadget2          dc.l Gadget3   Next gadget
                 dc.w 50        Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border2   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 2         Gadget ID
                 dc.l 0         User data

Border2          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs2    Vector coordinate pairs
                 dc.l 0         Next border

Pairs2           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 10,10
                 dc.w 10,2
                 dc.w 8,4
                 dc.w 10,2
                 dc.w 12,4
                 dc.w 10,2
                 dc.w 10,10
                 dc.w 0,10
                 dc.w 0,0

Gadget3          dc.l Gadget4   Next gadget
                 dc.w 90        Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border3   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 3         Gadget ID
                 dc.l 0         User data

Border3          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs3    Vector coordinate pairs
                 dc.l 0         Next border

Pairs3           dc.w 0,0       Lines which constitute the gadget
                 dc.w 8,0
                 dc.w 8,6
                 dc.w 7,5
                 dc.w 10,8
                 dc.w 13,5
                 dc.w 12,6
                 dc.w 12,0
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,0

Gadget4          dc.l Gadget5   Next gadget
                 dc.w 130       Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border4   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 4         Gadget ID
                 dc.l 0         User data

Border4          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs4    Vector coordinate pairs
                 dc.l 0         Next border

Pairs4           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 12,10
                 dc.w 12,4
                 dc.w 13,5
                 dc.w 10,2
                 dc.w 7,5
                 dc.w 8,4
                 dc.w 8,10
                 dc.w 0,10
                 dc.w 0,0

Gadget5          dc.l Gadget6   Next gadget
                 dc.w 170       Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border5   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 5         Gadget ID
                 dc.l 0         User data

Border5          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs5    Vector coordinate pairs
                 dc.l 0         Next border

Pairs5           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,5
                 dc.w 16,5
                 dc.w 14,4
                 dc.w 16,5
                 dc.w 14,6
                 dc.w 16,5
                 dc.w 0,5
                 dc.w 0,0

Gadget6          dc.l Gadget7   Next gadget
                 dc.w 210       Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border6   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 6         Gadget ID
                 dc.l 0         User data

Border6          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs6    Vector coordinate pairs
                 dc.l 0         Next border

Pairs6           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,5
                 dc.w 4,5
                 dc.w 6,4
                 dc.w 4,5
                 dc.w 6,6
                 dc.w 4,5
                 dc.w 20,5
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,0

Gadget7          dc.l Gadget8   Next gadget
                 dc.w 250       Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border7   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 7         Gadget ID
                 dc.l 0         User data

Border7          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs7    Vector coordinate pairs
                 dc.l 0         Next border

Pairs7           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,6
                 dc.w 15,6
                 dc.w 14,7
                 dc.w 15,5
                 dc.w 14,3
                 dc.w 15,4
                 dc.w 0,4
                 dc.w 0,0

Gadget8          dc.l 0         Next gadget
                 dc.w 290       Left edge
                 dc.w -15       Top edge
                 dc.w 20        Width
                 dc.w 10        Height
                 dc.w 8         Flags
                 dc.w 1         Activation
                 dc.w 1         Gadget type
                 dc.l Border8   Rendered as border or image
                 dc.l 0         Select render
                 dc.l 0         ^Gadget text
                 dc.l 0         Mutual exclude
                 dc.l 0         Special info
                 dc.w 8         Gadget ID
                 dc.l 0         User data

Border8          dc.w 0         Left edge
                 dc.w 0         Top edge
                 dc.b 1,2       Front pen,back pen
                 dc.b 1,12      Draw mode,number of coord pairs
                 dc.l Pairs8    Vector coordinate pairs
                 dc.l 0         Next border

Pairs8           dc.w 0,0       Lines which constitute the gadget
                 dc.w 20,0
                 dc.w 20,4
                 dc.w 6,4
                 dc.w 7,3
                 dc.w 5,5
                 dc.w 7,7
                 dc.w 6,6
                 dc.w 20,6
                 dc.w 20,10
                 dc.w 0,10
                 dc.w 0,0

             end


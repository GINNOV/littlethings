***************************************
* say - speak a text file             *
*                                     *
* written by E. Lenz                  *
*            Johann-Fichte-Strasse 11 *
*            8 Munich 40              *
*            Germany                  *
*                                     *
***************************************

**** exec ****

_AbsExecBase     equ 4
_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOAddPort      equ -$162
_LVORemPort      equ -$168
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e
_LVOOpenDevice   equ -$1bc
_LVOCloseDevice  equ -$1c2
_LVODoIo         equ -$1c8
_LVOOpenLibrary  equ -$228

**** dos *****

_LVOOpen     equ -$1e
_LVOClose    equ -$24
_LVORead     equ -$2a
_LVOWrite    equ -$30

***** translator ****

_LVOTranslate equ -$1e

TC_SIGRECVD      equ $1a
pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212
SIGBREAK_ANY     equ $1000

        XREF ReadLn,request,_Request

        move.l  a0,d7             save instruction from CLI
        move.l  d0,d4
        subq.w  #1,d4
        clr.b   0(a0,d4.w)

        movea.l _AbsExecBase,a6   test if WB or CLI
        movea.l ThisTask(a6),a0
        move.l  a0,writerep+$10
        lea     TC_SIGRECVD(a0),a1  get task signal address
        move.l  a1,TaskSigs

        moveq   #0,d0
        tst.l   pr_CLI(a0)
        bne.s   isCLI

        lea     pr_MsgPort(a0),a0        for WB get WB Message
        jsr     _LVOWaitPort(a6)
        jsr     _LVOGetMsg(a6)
        moveq   #0,d4             make sure there's no instruction

isCLI   move.l  d0,-(a7)

        cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
        beq.s   isNTSC
        move.l  #'256/',window+12

isNTSC  lea     transname(pc),a1     open translator library
        moveq   #0,d0
        jsr     _LVOOpenLibrary(a6)
        movea.l d0,a4
        tst.l   d0           this is one of the few cases
        bne.s   Transok      where this test is vital
        lea     transname(pc),a0   first line
        lea     notfnd(pc),a1     second line
        suba.l  a2,a2             no third line
        lea     hdtxt(pc),a3      header
        lea     OkTxt(pc),a4      gadget text
        suba.l  a5,a5             no 2nd gadget
        moveq   #0,d0
        moveq   #1,d1
        jsr     request
        suba.l  a3,a3
        bra     nocon

Transok lea     dosname(pc),a1    open DOS library
        moveq   #0,d0
        jsr     _LVOOpenLibrary(a6)
        movea.l d0,a3
        tst.l   d0
        beq.s   Gerror

        movea.l d0,a6             open Console window
        move.l  #window,d1
        move.l  #1005,d2
        jsr     _LVOOpen(a6)
        movea.l d0,a5
        tst.l   d0
Gerror  beq     error

        movea.l _AbsExecBase,a6
        lea     writerep(pc),a1
        jsr     _LVOAddPort(a6)

        lea     talkio(pc),a1
        moveq   #0,d0
        moveq   #0,d1
        lea     nardevice(pc),a0
        jsr     _LVOOpenDevice(a6)
        tst.l   d0
        bne     exit

        movea.l a3,a6
        move.l  d7,d1
        tst.l   d4
        bne.s   file

        moveq   #0,d0
        move.l  #160,d1
        moveq   #18,d2
        lea     title(pc),a0
        jsr     _Request
        move.l  d0,d1
        bra.s   file

        move.l  #filename,d1      open old file
file    move.l  #1005,d2
        jsr     _LVOOpen(a6)
        move.l  d0,filehandle
Gexit   beq     exit

        lea     talkio(pc),a1
        move.l  #writerep,14(a1)
        move.w  #150,48(a1)      rate 40-400
        move.w  #110,50(a1)      pitch 65-320
        move.w  #0,52(a1)        mode  0-1
        move.w  #0,54(a1)        sex   0-1
        move.l  #amaps,56(a1)    masks
        move.w  #4,60(a1)        4 masks
        move.w  #64,62(a1)       volume
        move.w  #22200,64(a1)

saylop  bsr     Read
        move.l  d1,d4
        beq.s   Gexit

        movea.l TaskSigs,a0      test for ***BREAK***
        move.l  (a0),d0
        andi.l  #SIGBREAK_ANY,d0
        bne.s   Gexit

        lea     outtext(pc),a1 clear translated stuff
        moveq   #0,d0
        moveq   #$7f,d1
clear   move.l  d0,(a1)+
        dbra    d1,clear

        move.l  a1,a2          write to console
        move.l  a5,d1
        move.l  #Buffer,d2
        move.l  d4,d3
        jsr     _LVOWrite(a6)

        cmpi.l   #1,d4
        beq.s    saylop

        move.l  d4,d0
        clr.b   -1(a2)

        lea     Buffer(pc),a0
        lea     outtext(pc),a1
        move.l  #512,d1
        movea.l a4,a6
        jsr     _LVOTranslate(a6)

        lea     talkio(pc),a1
        move.w  #3,28(a1)
        move.l  #512,36(a1)
        move.l  #outtext,40(a1)
        move.l  _AbsExecBase,a6
        jsr     _LVODoIo(a6)
        bra     saylop

exit    move.l  _AbsExecBase,a6
        lea     writerep(pc),a1
        jsr     _LVORemPort(a6)

        lea     talkio(pc),a1
        jsr     _LVOCloseDevice(a6)

        movea.l a4,a1               close translator library
        jsr     _LVOCloseLibrary(a6)

error   move.l  a3,a6

        move.l  filehandle(pc),d1  close file
        beq.s   nofile
        jsr     _LVOClose(a6)

nofile  move.l  a5,d1            close console
        beq.s   nocon
        jsr     _LVOClose(a6)

nocon   move.l  _AbsExecBase,a6
        move.l  (a7)+,d0
        beq.s   NoBench
        jsr     _LVOForbid(a6)    reply to WB
        movea.l d0,a1
        jsr     _LVOReplyMsg(a6)
        jsr     _LVOPermit(a6)

NoBench move.l  a3,d0
        beq.s   NoDos
        movea.l d0,a1             close dos.lib
        jsr     _LVOCloseLibrary(a6)
NoDos   moveq   #0,d0
        rts

Read    movem.l a2-a5,-(a7)
        movea.l a3,a6
        move.l  BufNum(pc),d0
        movea.l BufPnt(pc),a0
        movea.l #Buf2,a1
        movea.l #Buffer,a2
        movea.l filehandle(pc),a3
        jsr     ReadLn
        move.l  d0,BufNum
        move.l  a0,BufPnt
        movem.l (a7)+,a2-a5
        rts

TaskSigs   ds.l 1
amaps      dc.b 3,5,10,12

transname  dc.b 'translator.library',0
dosname    dc.b 'dos.library',0
nardevice  dc.b 'narrator.device',0
           even

; requester texts

notfnd     dc.b ' not found',0
hdtxt      dc.b ' Say Request',0
OkTxt      dc.b ' OK',0
           even

title      dc.b 'load file to SAY',0
           even

filename   ds.b 80

window     dc.b 'CON:0/0/639/199/Say - abort with ^C',0
           even


filehandle dc.l 0
narread    ds.l 20
talkio     ds.l 20
writerep   ds.l 8
BufNum     dc.l 0
BufPnt     dc.l 0
Buffer     ds.b 200
Buf2       ds.b 200
outtext    ds.l $100
           end



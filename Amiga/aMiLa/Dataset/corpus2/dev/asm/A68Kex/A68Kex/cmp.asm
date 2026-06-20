*****************************************
*                                       *
* cmp - compare two files               *
*                                       *
* written by E. Lenz                    *
*            Johann-Fichte-Strasse 11   *
*            8 Munich 40                *
*            Germany                    *
*                                       *
*****************************************

      XREF Disasm1,_Request

_AbsExecBase     equ 4

*****EXEC*******

_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e

_LVOOpenLibrary  equ -$228

*****DOS*****

_LVOOpen         equ -$1e
_LVOClose        equ -$24
_LVORead         equ -$2a
_LVOWrite        equ -$30

pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212
MODE_OLDFILE     equ 1005

         movea.l a0,a5             save instruction from CLI
         move.l  d0,d4

         movea.l _AbsExecBase,a6   test if WB or CLI
         movea.l ThisTask(a6),a0
         tst.l   pr_CLI(a0)
         bne.s   isCLI

         lea     pr_MsgPort(a0),a0 for WB get WB Message
         jsr     _LVOWaitPort(a6)
         jsr     _LVOGetMsg(a6)
         move.l  d0,WBenchMsg
         moveq   #1,d4             make sure there's no instruction

isCLI    cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
         beq.s   isNTSC
         move.l  #'256/',window+12

isNTSC   lea     dosname(pc),a1    open DOS library
         moveq   #0,d0
         jsr     _LVOOpenLibrary(a6)
         move.l  d0,dosbase
         beq.s   Gexit

         movea.l d0,a6             open Console window
         move.l  #window,d1
         move.l  #MODE_OLDFILE,d2
         jsr     _LVOOpen(a6)
         move.l  d0,conhandle
Gexit    beq     exit

         subq.l  #1,d4
         beq.s   noinst            no instruction from CLI

         lea     file1(pc),a0      transfer input file name
         moveq   #0,d2
trans1   move.b  (a5)+,d0
         cmpi.b  #' ',d0
         beq.s   toFile
         move.b  d0,(a0)+
         addq.l  #1,d2
         subq.l  #1,d4
         bne.s   trans1

toFile   move.b  #$a,(a0)+
         move.l  d2,f1length
toFile1  subq.l  #1,d4
         beq.s   noinst
         move.b  (a5)+,d0
         cmpi.b  #' ',d0
         beq.s   toFile1

         lea     file2(pc),a0
trans2   move.b  d0,(a0)+
         move.b  (a5)+,d0
         addq.l  #1,f2length
         cmpi.b  #$a,d0
         beq.s   Parse
         subq.l  #1,d4
         bne.s   trans2


noinst   moveq   #0,d0
         move.l  #160,d1
         moveq   #18,d2
         lea     first(pc),a0
         jsr     _Request
         moveq   #-1,d0
         lea     file1(pc),a1
f1       addq.l  #1,d0
         move.b  (a0)+,(a1)+
         bne.s   f1
         move.l  d0,f1length

         moveq   #0,d0
         move.l  #160,d1
         moveq   #18,d2
         lea     second(pc),a0
         jsr     _Request
         moveq   #-1,d0
         lea     file2(pc),a1
f2       addq.l  #1,d0
         move.b  (a0)+,(a1)+
         bne.s   f2
         move.l  d0,f2length
         bra.s   noParse

Parse    lea     file1(pc),a0      zero behind strings
Floop    cmpi.b  #$a,(a0)+
         bne.s   Floop
         clr.b   -(a0)

         lea     file2(pc),a0
Gloop    cmpi.b  #$a,(a0)+
         bne.s   Gloop
         clr.b   -(a0)

noParse  move.l  #file1,d1         open first file
         move.l  #MODE_OLDFILE,d2
         jsr     _LVOOpen(a6)
         move.l  d0,InFile
         beq.s   exit

         move.l  #file2,d1         open second file
         move.l  #MODE_OLDFILE,d2
         jsr     _LVOOpen(a6)
         move.l  d0,OutFile
         beq.s   exit

         move.l  f1length(pc),d0
         lea     file1(pc),a0
         move.b  #$a,0(a0,d0)

         move.l  f2length(pc),d0
         lea     file2(pc),a0
         move.b  #$a,0(a0,d0)

         moveq   #0,d4
         clr.w   Micro

         bsr.s   Compare

exit     move.l  conhandle(pc),d1  close console
         beq.s   FileIn
         jsr     _LVOClose(a6)

FileIn   move.l  InFile(pc),d1     close input file
         beq.s   noIn
         jsr     _LVOClose(a6)

noIn     move.l  OutFile(pc),d1    close output file
         beq.s   noOut
         jsr     _LVOClose(a6)

noOut    move.l  _AbsExecBase,a6
         move.l  WBenchMsg(pc),d7
         beq.s   NoBench
         jsr     _LVOForbid(a6)    reply to WB
         movea.l d7,a1
         jsr     _LVOReplyMsg(a6)
         jsr     _LVOPermit(a6)

NoBench  move.l  dosbase(pc),a1    close dos.lib
         jsr     _LVOCloseLibrary(a6)
         moveq   #0,d0
         rts

*****ROUTINES******

Compare  move.l  InFile(pc),d1     fill buffer
         move.l  #Buffer2,d2
         moveq   #80,d3
         jsr     _LVORead(a6)
         move.l  d0,BufNum2
         move.l  NextRel(pc),RelAddr
         add.l   d0,NextRel

         move.l  OutFile(pc),d1
         move.l  #Inst,d2
         moveq   #80,d3
         jsr     _LVORead(a6)
         cmp.l   BufNum2(pc),d0
         bne.s   length
         tst.l   d0
         beq.s   issame

         lea     Buffer2(pc),a0
         lea     Inst(pc),a1
         subq.l  #1,d0
         moveq   #0,d5
cmpl1    addq.l  #1,d4
         addq.l  #1,d5
         cmpm.b  (a0)+,(a1)+
         bne.s   differ
cmplp    dbra    d0,cmpl1
         bra.s   Compare

issame   tst.l   difr
         bne.s   yyy
         move.l  #same,d2
         moveq   #22,d3
         bra.s   xxx

length   move.l  #NoLength,d2
         moveq   #16,d3
xxx      move.l  conhandle(pc),d1  write message to console
         jsr     _LVOWrite(a6)
yyy      move.l  conhandle(pc),d1  wait until keypressed
         move.l  #align2,d2
         moveq   #2,d3
         jsr     _LVORead(a6)

         rts

differ   movem.l d0/d4-d5/a0-a1,-(a7)
         move.l  #1,difr
         move.l  #diff,d2
         moveq   #17,d3
         move.l  conhandle(pc),d1  write message to console
         jsr     _LVOWrite(a6)
         move.l  #Hextxt,d6
         subq.l  #1,d4
         bsr     decout
         bsr     hex
         move.l  #ata,d2
         moveq   #24,d3
         move.l  conhandle(pc),d1  write message to console
         jsr     _LVOWrite(a6)

; ASCII difference

         move.l  #file1,d2
         move.l  f1length(pc),d3
         addq.l  #1,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         lea     Buffer2(pc),a0
         bsr     Ascii

         move.l  #file2,d2
         move.l  f2length(pc),d3
         addq.l  #1,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         lea     Inst(pc),a0
         bsr     Ascii

; HEX difference

         move.l  #file1,d2
         move.l  f1length(pc),d3
         addq.l  #1,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         lea     Buffer2(pc),a1
         bsr     HexOut

         move.l  #file2,d2
         move.l  f2length(pc),d3
         addq.l  #1,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         lea     Inst(pc),a1
         bsr     HexOut

; press key for disassembled

         move.l  #key,d2
         moveq   #32,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)

         move.l  conhandle(pc),d1  wait until keypressed
         move.l  #OutBuf,d2
         moveq   #2,d3
         jsr     _LVORead(a6)

; disassembled difference

         lea     file1(pc),a0
         lea     OutBuf(pc),a1
         moveq   #0,d0
         move.l  f1length(pc),d1
         subq.l  #1,d1
tran1    move.b  (a0)+,(a1)+
         addq.l  #1,d0
         dbra    d1,tran1
clr1     cmpi.l  #40,d0
         bge.s   filetwo
         move.b  #' ',(a1)+
         addq.l  #1,d0
         bra.s   clr1
filetwo  lea     file2(pc),a0
         move.l  f2length(pc),d1
tran2    move.b  (a0)+,(a1)+
         addq.l  #1,d0
         dbra    d1,tran2

         move.l  #OutBuf,d2
         move.l  d0,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)

         move.l  #Buffer2,d4       begin file 1
         move.l  #Inst,d6          begin file 2
         move.l  RelAddr(pc),d7    relative address
         move.l  d7,-(a7)

DisLp    lea     Begin(pc),a0
         move.l  d4,(a0)
         move.l  d7,RelAddr
         jsr     Disasm1
         move.l  Begin(pc),d4
         move.l  RelAddr(pc),d7
         lea     Buffer(pc),a0
         lea     OutBuf(pc),a1
         moveq   #6,d1
rela     move.b  (a0)+,(a1)+
         dbra    d1,rela
         lea     Buffer+40,a0
         moveq   #39,d1
trns1    move.b  (a0)+,(a1)+
         dbra    d1,trns1

         lea     Begin(pc),a0
         move.l  d6,(a0)
         jsr     Disasm1
         move.l  Begin(pc),d6
         lea     Buffer+40,a0
         lea     OutBuf+40,a1
         moveq   #28,d1
trns2    move.b  (a0)+,(a1)+
         dbra    d1,trns2
         move.b  #$a,(a1)
         sub.w   Total(pc),d5
         bgt.s   WriteOut

         lea     invtext(pc),a0    invert line
         lea     Out1(pc),a1
         moveq   #8,d0
invt1    move.b  (a0)+,(a1)+
         dbra    d0,invt1
         lea     Out2(pc),a1
         moveq   #8,d0
invt2    move.b  (a0)+,(a1)+
         dbra    d0,invt2
         move.b  #$a,(a1)
         moveq   #100,d5
         move.l  #Out1,d2
         moveq   #88,d3
         bra.s   ReWrite

WriteOut move.l  #OutBuf,d2
         moveq   #70,d3
ReWrite  move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)

         cmpi.l  #align2,d4
         blt     DisLp

         move.l  #yes,d2
         moveq   #18,d3
         move.l  conhandle(pc),d1  write message to console
         jsr     _LVOWrite(a6)

         move.l  conhandle(pc),d1  wait until keypressed
         move.l  #align2,d2
         moveq   #2,d3
         jsr     _LVORead(a6)

         move.l  (a7)+,RelAddr
         movem.l (a7)+,d0/d4-d5/a0-a1
         move.b  align2(pc),d1
         cmpi.b  #'n',d1
         beq.s   Gcmp
         cmpi.b  #'N',d1
         bne     cmplp

Gcmp     rts


; decimal  output

decout   move.l  d4,-(a7)
         lea     OutBuf(pc),a0
         moveq   #0,d0
wrlop    andi.l  #$ffff,d4
         tst.l   d4
         beq.s   back
         divu    #10,d4
         swap    d4
         move.b  d4,(a0)+
         swap    d4
         addq.l  #1,d0
         bra.s   wrlop

back     tst.l   d0                   zero is a special case
         bne.s   bakk
         addq.l  #1,d0
         clr.b   OutBuf
bakk     movea.l d6,a0
         moveq   #6,d1
         subq.l  #1,d0
clr      cmp.l   d0,d1
         beq.s   endclr
         move.b  #' ',-(a0)
         subq.l  #1,d1
         bra.s   clr

endclr   lea     OutBuf(pc),a1
rewlop   move.b  (a1)+,d1
         addi.b  #'0',d1
         move.b  d1,-(a0)
         dbra    d0,rewlop
         move.l  (a7)+,d4
         rts

; HEX output

hex      lea     hex1(pc),a0
         move.l  d4,d0
         andi.l  #$f000,d0
         lsr.l   #8,d0
         lsr.l   #4,d0
         bsr.s   byte
         andi.l  #$f00,d0
         lsr.l   #8,d0
         bsr.s   byte
real     move.l  d4,d0
         andi.l  #$f0,d0
         lsr.l   #4,d0
         bsr.s   byte
         andi.l  #$f,d0

byte     cmpi.b  #9,d0
         ble.s   bok
         addq.l  #7,d0
bok      addi.l  #'0',d0
         move.b  d0,(a0)+
         move.l  d4,d0
         rts

; write Ascii

Ascii    lea     OutBuf(pc),a1
         moveq   #79,d1
         move.l  d5,-(a7)
Asc1     move.b  (a0)+,d0             get byte
         move.b  d0,d2
         andi.b  #$7f,d2
         cmpi.b  #$20,d2
         bge.s   isok
         moveq   #$2e,d0
isok     subq.l  #1,d5
         bne.s   nextAsc
         bsr.s   invert
nextAsc  move.b  d0,(a1)+             write ASCII
         dbra    d1,Asc1
         move.l  (a7)+,d5
         move.b  #$a,(a1)
         move.l  #OutBuf,d2
         moveq   #99,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         rts

invert   movem.l d1/a0,-(a7)
         lea     invtext(pc),a0
         moveq   #8,d1
inv1     move.b  (a0)+,(a1)+
         dbra    d1,inv1
         move.b  d0,(a1)+
         moveq   #7,d1
inv2     move.b  (a0)+,(a1)+
         dbra    d1,inv2
         move.b  (a0),d0
         movem.l (a7)+,d1/a0
         rts

; write Hex

HexOut   lea     OutBuf(pc),a0
         moveq   #79,d1
         moveq   #0,d4
         move.l  d5,-(a7)
Hex1     move.b  (a1)+,d4             get byte
         subq.l  #1,d5
         bne.s   nextHex
         bsr.s   invh
         bra.s   nexth
nextHex  bsr     real
nexth    dbra    d1,Hex1
         move.l  (a7)+,d5
         move.b  #$a,(a0)
         move.l  #OutBuf,d2
         move.l  #179,d3
         move.l  conhandle(pc),d1
         jsr     _LVOWrite(a6)
         rts

invh     movem.l d1/a1,-(a7)
         lea     invtext(pc),a1
         moveq   #8,d1
inv3     move.b  (a1)+,(a0)+
         dbra    d1,inv3
         bsr     real
         moveq   #8,d1
inv4     move.b  (a1)+,(a0)+
         dbra    d1,inv4
         movem.l (a7)+,d1/a1
         rts

dosbase    dc.l 0
conhandle  dc.l 0
InFile     dc.l 0
OutFile    dc.l 0
WBenchMsg  dc.l 0
NextRel    dc.l 0
difr       dc.l 0

key        dc.b $a,' press RETURN for disassembled',$a
yes        dc.b $a,' press N to exit',$a

invtext    dc.b $9b,'0;31;43',$6d,$9b,'0;31;40',$6d

NoLength   dc.b 'different length'
same       dc.b 'the files are the same'
diff       dc.b 'the files differ',$a
ata        dc.b 'at  FFFFFF'
Hextxt     dc.b ' or HEX: '
hex1       dc.b 'FFFF',$a
           cnop 0,2

f1length   dc.l 0
file1      ds.b 80       file names
f2length   dc.l 0
file2      ds.b 80

Inst       ds.b 80

BufNum2    dc.l 0
Buffer2    ds.b 80
align2     ds.b 1
Out1       ds.b 9
OutBuf     ds.b 69
Out2       ds.b 131

; Communication structure

Begin      ds.l 1            Begin of disassembly
RelAddr    ds.l 1            Relative address
Micro      ds.w 1            Microprocessor type
OpCode     ds.w 1            Opcode translation
Type1      ds.w 1            Type of 1st operand
Len1       ds.w 1            Length of 1st address
Addr1      ds.l 1            1st address
Type2      ds.w 1            Type of 2nd operand
Len2       ds.w 1            Length of 2nd operand
Addr2      ds.l 1            2nd address
Total      ds.w 1            Total no of bytes
Buffer     ds.b 40           Output buffer

dosname    dc.b 'dos.library',0
           cnop 0,2

window     dc.b 'CON:0/0/639/199/Compare files',0
           cnop 0,2

first      dc.b 'cmp two files - first file',0
           even

second     dc.b 'cmp two files - second file',0
           even

           end


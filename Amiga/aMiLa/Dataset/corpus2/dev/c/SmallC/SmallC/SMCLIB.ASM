;
; some system equates
;
AbsExecBase  equ  $4
MODE_OLDFILE equ  1005
MODE_NEWFILE equ  1006
;
;        Register equates
;
bx    equr     d0
dx    equr     d1
;
;        Macro definitions
;
lref     MACRO
         xref     _LVO\1
         ENDM
;
;
;
call     MACRO
         jsr      _LVO\1(a6)
         ENDM
;
;
;
         lref     OpenLibrary
         lref     CloseLibrary
         lref     Open
         lref     Close
         lref     Read
         lref     Write
         lref     Input
         lref     Output
;
;
;
         section  ONE
;
;
;
   nop
;
;        Define entry point
;
   xdef     CCINIT
CCINIT:
;
;        Save stack pointer for EXIT
;
   move.l   sp,StkPtr
;
;        Initialize work areas
;
   clr.l    HandFlgs
   clr.l    HandFlgs+4
;
;        Open DOS library
;
   move.l   #dosname,a1
   clr      d0
   move.l   AbsExecBase,a6
   call     OpenLibrary
   move.l   d0,a6
   tst.l    d0
   beq      CCWRAP
;
;        Find standard file handles
;
   call     Input
   move.l   d0,StdIn
   beq      CCWRAP
   call     Output
   move.l   d0,StdOut
   beq      CCWRAP
   rts
;
;        Close opened libraries
;
   xdef     CCWRAP
CCWRAP:
   move.l   a6,a1
   move.l   AbsExecBase,a6
   call     CloseLibrary
   clr.l    d0
   rts
;
;
;
   xdef     CCDIV
CCDIV:
   divs     bx,dx
   move.w   dx,bx
   ext.l    bx
   asr.l    #8,dx
   asr.l    #8,dx
   rts
;
;
;
   xdef     QZPUTCHAR
QZPUTCHAR:
   move.l   4(sp),d0
   move.l   d0,d7
   move.b   d0,CharBuff
   bsr      Wr1Byte
   move.l   d7,d0
   rts
;
;
;
Wr1Byte:
   move.l   StdOut,d1
   move.l   #CharBuff,d2
   move.l   #1,d3
   call     Write
   rts
;
;
;
   xdef     QZBELL
QZBELL:
   move.l   #7,bx
   move.l   bx,-(sp)
   bsr      QZPUTCHAR
   move.l   (sp)+,bx
   rts
;
;
;
   xdef     QZCLRSCREE
QZCLRSCREE:
   rts
;
;
;
   xdef     QZGETS
QZGETS:
   move.l   4(sp),a4
   move.l   StdIn,d1
   move.l   a4,d2
   move.l   #80,d3
   call     Read
   clr.b    -1(a4,d0.l)
   move.l   d0,a4
   move.b   #10,d0
   move.b   d0,CharBuff
   bsr      Wr1Byte
   move.l   a4,d0
   rts
;
;
;
   xdef     QZFOPEN
QZFOPEN:
   move.l   #HandFlgs,a0
   moveq    #7,d2
   clr.l    d3
1$ tst.b    (a0)+
   beq      2$
   addq.l   #1,d3
   dbra     d2,1$
   bra      fail
2$ not.b    -(a0)
   move.l   d3,Unit
   asl.l    #2,d3
   move.l   d3,HandOffs
   move.l   #MODE_OLDFILE,d2
   move.l   4(sp),a0
   move.b   (a0),d0
   cmp.b    #'r',d0
   beq      4$
   cmp.b    #'R',d0
   beq      4$
   cmp.b    #'w',d0
   beq      3$
   cmp.b    #'W',d0
   bne      fail
3$ move.l   #MODE_NEWFILE,d2
4$ move.l   8(sp),d1
   call     Open
   tst.l    d0
   beq      fail
   move.l   #Handles,a0
   move.l   HandOffs,d1
   move.l   d0,0(a0,d1.l)
   move.l   Unit,bx
   addq.l   #1,bx
   rts
fail:
   clr.l    bx
   rts
;
;
;
   xdef     QZGETC
QZGETC:
   bsr      GetHandl
   move.l   #CharBuff,d2
   move.l   #1,d3
   call     Read
   tst.l    d0
   beq      eof
   move.b   CharBuff,bx
   ext.w    bx
   ext.l    bx
   rts
eof:
   move.l   #-1,bx
   rts
;
;
;
   xdef     QZPUTC
QZPUTC:
   move.l   8(sp),d0
   move.l   d0,d7
   move.b   d0,CharBuff
   bsr      GetHandl
   move.l   #CharBuff,d2
   move.l   #1,d3
   call     Write
   move.l   d7,bx
   rts
;
;
;
   xdef     QZFCLOSE
QZFCLOSE:
   bsr      GetHandl
   call     Close
   move.l   4(sp),d0
   subq.l   #1,d0
   move.l   #HandFlgs,a0
   clr.b    0(a0,d0.l)
   clr.l    bx
   rts
;
;
;
GetHandl:
   move.l   8(sp),d0
   subq.l   #1,d0
   asl.l    #2,d0
   move.l   #Handles,a0
   move.l   0(a0,d0.l),d1
   rts
;
;
;
   xdef     QZEXIT
QZEXIT:
   move.l   StkPtr,sp
   addq     #4,sp
   rts
;  
;
;
         section  TWO,data
;
;        DOS Library name
;
dosname  dc.b     'dos.library',0
;
;
;
         section  THREE,bss
;
;
;
CharBuff ds.b     1
         ds.b     1
;
;
;
StkPtr   ds.l     1
;
;
;
StdIn    ds.l     1     ;input file handle
StdOut   ds.l     1     ;output file handle
HandOffs ds.l     1     ;offset to handle being opened
Unit     ds.l     1     ;Value returned by open
HandFlgs ds.b     8     ;Handle 'in-use' flags
Handles  ds.l     8     ;Room for 8 handles
;
;
;
   end

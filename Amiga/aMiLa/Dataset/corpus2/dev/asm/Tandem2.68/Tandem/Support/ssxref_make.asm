* ssxref_make.asm  v. 0.09  25.2.97

 bra Cold                                ;*** must be run from CLI ***

infile: dc.b 'Support/FD3.1',0           ;*** paths relative to CD of input
outfile: dc.b 'Support/ssxref.asm',0     ;*** and output files

extras:                                  ;*** supplement infile here
 dc.b '_AbsExecBase: EQU $00000004',$0A

delim: dc.b 0
 ds.w 0

_AbsExecBase equ $00000004
_LVOOpenLibrary equ $FFFFFDD8
_LVOCloseLibrary equ $FFFFFE62
_LVOAllocMem: equ $FFFFFF3A
_LVOFreeMem: equ $FFFFFF2E
_LVOOpen: equ $FFFFFFE2
_LVOClose: equ $FFFFFFDC
_LVORead: equ $FFFFFFD6
_LVOWrite: equ $FFFFFFD0

* input/output buffer
memory: ds.l 1

* system information
dosname: dc.b 'dos.library',0

* diskfile data
handle: ds.l 1 ;file handle during i/o

* allocmem,open dos library
Cold:
 move.l _AbsExecBase,a6 ;allocate memory
 move.l #200000,d0
 moveq #1,d1
 jsr _LVOAllocMem(a6)
 move.l d0,memory
 beq.s Co_quit ;go if can't
 lea dosname,a1
 clr.l d0
 jsr _LVOOpenLibrary(a6) ;open dos
 tst.l d0
 beq.s Co_free
 move.l d0,a6 ;a6=dosbase
 bsr Warm
 move.l a6,a1
 move.l _AbsExecBase,a6
 jsr _LVOCloseLibrary(a6) ;close dos
Co_free:
 move.l memory,a1
 move.l #200000,d0
 jsr _LVOFreeMem(a6) ;free memory
Co_quit:
 rts     ;exit

* input & output a6=dosbase
Warm:
 move.l #infile,d1 ;open infile
 move.l #1005,d2
 jsr _LVOOpen(a6)
 move.l d0,d1
 beq.s Wm_quit     ;go if can't
 move.l d1,-(a7)
 move.l memory,d2
 add.l #100000,d2   ;load at memory+100000
 move.l #100000,d3
 jsr _LVORead(a6)
 move.l (a7)+,d1
 move.l d0,-(a7)
 jsr _LVOClose(a6)   ;close infile
 move.l (a7)+,d6
 ble.s Wm_quit
 add.l d2,d6         ;d2=infile d6=infile top
 bsr Calc
 movem.l d2-d3,-(a7) ;save outfile data
 move.l #outfile,d1
 move.l #1006,d2
 jsr _LVOOpen(a6)    ;open outfile
 movem.l (a7)+,d2-d3
 move.l d0,d1
 beq.s Wm_quit      ;go if can''t open
 move.l d1,-(a7)
 jsr _LVOWrite(a6)   ;send outfile
 move.l (a7)+,d1
 jsr _LVOClose(a6)   ;close outfile
Wm_quit:
 rts

* prepare output data  d2=outfile d6=outfile top (send d2,d3 for Write)
Calc:
 move.l d2,a0  ;a0=infile
 lea extras,a2 ;transfer extras
 lea delim,a3
 move.l memory,a1 ;a1=outfile
 move.l a1,d2  ;d2=outfile bot
Cc_tfr1:
 move.b (a2)+,(a1)+
 cmp.l a2,a3
 bne Cc_tfr1
 clr.l d5      ;d5=bias
 clr.l d4      ;d4=0 if public
Cc_item:
 cmp.l d6,a0
 bge Cc_wrap ;-> if eof
Cc_chr1:
 cmp.b #33,(a0)  ;skip null lines, of lines starting with a space
 bcs.s Cc_slof
 cmp.b #'#',(a0) ;-> if #
 beq.s Cc_hash
 cmp.b #'*',(a0) ;slof if *
 bne Cc_got      ;else, a libname
Cc_slof:
 cmp.b #$0A,(a0)+ ;skip rest of inline
 bne Cc_slof
 bra Cc_item
Cc_hash:
 addq.l #1,a0
 cmp.b #'#',(a0)+ ;another #?
 bne Cc_slof      ;no, skip (can't happen)
 cmp.b #'b',(a0)  ;go if b
 beq.s Cc_bias
 cmp.b #'p',(a0)+ ;ignore if not ##b or ##p
 bne Cc_slof
 clr.l d4
 cmp.b #'r',(a0)+ ;if ##pr private, else ##p public
 bne Cc_slof
 moveq #-1,d4 ;d4=-1 private
 bra Cc_slof
Cc_bias:
 addq.l #1,a0
 cmp.b #'i',(a0)+ ;##bi=bias, else ignore ##b
 bne Cc_slof
 addq.l #3,a0 ;skip 'as '
 clr.l d5 ;d5 holds new bias
 clr.l d0
Cc_val:
 move.b (a0)+,d0
 sub.b #'0',d0
 bcs.s Cc_neg
 cmp.b #10,d0
 bcc.s Cc_neg
 mulu #10,d5
 add.l d0,d5
 bra Cc_val
Cc_neg:
 neg.l d5
 bra Cc_item
Cc_got:
 tst.l d4
 beq.s Cc_sendr ;cont if public
 sub.l #6,d5
 bra Cc_slof ;else, fix bias & skip
Cc_sendr:
 move.b #'_',(a1)+
 move.b #'L',(a1)+
 move.b #'V',(a1)+
 move.b #'O',(a1)+
Cc_send:
 move.b (a0)+,d0 ;send until eol or (
 cmp.b #$0A,d0
 beq.s Cc_asc
 move.b d0,(a1)+
 cmp.b #'(',d0
 bne Cc_send
 subq.l #1,a1
Cc_slof2:
 cmp.b #$0A,(a0)+
 bne Cc_slof2
Cc_asc:
 move.b #':',(a1)+
 move.b #' ',(a1)+
 move.b #'E',(a1)+
 move.b #'Q',(a1)+
 move.b #'U',(a1)+
 move.b #' ',(a1)+
 move.b #'$',(a1)+
 move.l d5,d0
 move.w #$1000,d1 ;send lsw of bias (in ascii)
Cc_dig:
 moveq #'0'-1,d3
Cc_sub:
 addq.w #1,d3
 cmp.b #'9'+1,d3
 bne.s Cc_cry
 moveq #'A',d3
Cc_cry:
 sub.w d1,d0
 bcc Cc_sub
 add.w d1,d0
 move.b d3,(a1)+
 lsr.w #4,d1
 bne Cc_dig
 move.b #$0A,(a1)+ ;send eol
Cc_down:
 sub.l #6,d5 ;fix bias
 bra Cc_item ;& to next item
Cc_wrap:
 move.l a1,d3 ;d3=outfile size d2=outfile bot
 sub.l d2,d3
 rts

***************************************
* ReadLn  - read one line of an       *
*           Ascii file                *
*                                     *
* If the routine returns with d0 = 0  *
* the file has been completely read   *
*                                     *
* written by E. Lenz                  *
*            Johann-Fichte-Strasse 11 *
*            8 Munich 40              *
*            Germany                  *
*                                     *
***************************************

; INPUT
; d0 number of bytes in buffer
; a0 buffer pointer
; a1 begin of buffer            ( input buffer = 200 bytes )
; a2 where to write the line to ( output buffer = 200 bytes )
; a3 file handler
; a6 dos base

; OUTPUT
; d0 new number of bytes in buffer
; d1 number of bytes read
; a0 new buffer pointer

_LVORead equ -$2a

        XDEF ReadLn

ReadLn     movem.l d2-d7/a1-a5,-(a7)

           moveq   #0,d1            no bytes read

           tst.l   d0
           bne.s   nextGet
           bsr.s   FillBuf
           tst.l   d0
           beq.s   nomore           no bytes left in file

nextGet    move.b  (a0)+,d2         transfer a byte
           move.b  d2,(a2)+
           addq.l  #1,d1            increment pointers
           cmpi.l  #200,d1          do not write 
           blt.s   noovf            beyond buffer
           moveq   #0,d0
           bra.s   nomore
noovf      subq.l  #1,d0
           bne.s   noFill
           bsr.s   FillBuf
           tst.l   d0
           beq.s   nomore           no bytes left in file
noFill     cmpi.b  #$a,d2
           bne.s   nextGet
nomore     movem.l (a7)+,d2-d7/a1-a5
           rts

FillBuf    movem.l d1-d2/a1,-(a7)
           move.l  a3,d1         fill buffer
           move.l  a1,d2
           move.l  #200,d3
           jsr     _LVORead(a6)
           cmpi.l  #-1,d0        treat error as zero bytes read
           bne.s   isok
           moveq   #0,d0
isok       movem.l (a7)+,d1-d2/a1
           movea.l a1,a0          buffer pointer = begin of buffer
           rts
           end


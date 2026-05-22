*
* Copyright (c) 1992 Commodore-Amiga, Inc.
* 
* This example is provided in electronic form by Commodore-Amiga, Inc. for 
* use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
* published by Addison-Wesley (ISBN 0-201-56775-X).
* 
* The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
* information on the correct usage of the techniques and operating system 
* functions presented in these examples.  The source and executable code 
* of these examples may only be distributed in free electronic form, via 
* bulletin board or as part of a fully non-commercial and freely 
* redistributable diskette.  Both the source and executable code (including 
* comments) must be included, without modification, in any copy.  This 
* example may not be published in printed form or distributed with any
* commercial product.  However, the programming techniques and support
* routines set forth in these examples may be used in the development
* of original executable software products for Commodore Amiga computers.
* 
* All other rights reserved.
* 
* This example is provided "as-is" and is subject to change; no
* warranties are made.  All use is at your own risk. No liability or
* responsibility is assumed.
*
**********************************************************************
*
* Transfer routine for HP_LaserJet
*
**********************************************************************

        INCLUDE "exec/types.i"

        INCLUDE "intuition/intuition.i"
        INCLUDE "devices/printer.i"
        INCLUDE "devices/prtbase.i"
        INCLUDE "devices/prtgfx.i"

        XREF    _PD

        XDEF    _Transfer

        SECTION         printer,CODE
_Transfer:
; Transfer(PInfo, y, ptr)
; struct PrtInfo *PInfo         4-7
; UWORD y;                      8-11
; UBYTE *ptr;                   12-15
;

        movem.l d2-d6/a2-a3,-(sp)       ;save regs used

        movea.l 32(sp),a0               ;a0 = PInfo
        move.l  36(sp),d0               ;d0 = y
        movea.l 40(sp),a1               ;a1 = ptr

        move.w  pi_width(a0),d1         ;d1 = width
        subq.w  #1,d1                   ;adjust for dbra

        move.w  pi_threshold(a0),d3     ;d3 = threshold, thresholding?
        beq.s   grey_scale              ;no, grey-scale

threshold:
; a0 - PInfo
; a1 - ptr
; d0 - y
; d1 - width
; d3 - threshold

        eori.b  #15,d3                  ;d3 = dvalue
        movea.l pi_ColorInt(a0),a2      ;a2 = ColorInt ptr
        move.w  pi_xpos(a0),d2          ;d2 = x
        movea.l pi_ScaleX(a0),a0        ;a0 = ScaleX (sxptr)

; a0 - sxptr
; a1 - ptr
; a2 - ColorInt ptr
; a3 - dmatrix ptr (NOT USED)
; d0 - byte to set (x >> 3)
; d1 - width
; d2 - x
; d3 - dvalue
; d4 - Black
; d5 - sx
; d6 - bit to set

twidth_loop:
        move.b  PCMBLACK(a2),d4         ;d4 = Black
        addq.l  #ce_SIZEOF,a2           ;advance to next entry

        move.w  (a0)+,d5                ;d5 = # of times to use this pixel (sx)

        cmp.b   d3,d4                   ;render this pixel?
        ble.s   tsx_end                 ;no, skip to next pixel.
        subq.w  #1,d5                   ;adjust for dbra

tsx_render:                             ;yes, render this pixel sx times
        move.w  d2,d0
        lsr.w   #3,d0                   ;compute byte to set
        move.w  d2,d6
        not.w   d6                      ;compute bit to set
        bset.b  d6,0(a1,d0.w)           ;*(ptr + x >> 3) |= 2 ^ x

        addq.w  #1,d2                   ;x++
        dbra    d5,tsx_render           ;sx--
        dbra    d1,twidth_loop          ;width--
        bra.s   exit                    ;all done

tsx_end:
        add.w   d5,d2                   ;x += sx
        dbra    d1,twidth_loop          ;width--
        bra.s   exit

grey_scale:
; a0 - PInfo
; a1 - ptr
; d0 - y
; d1 - width

        movea.l pi_ColorInt(a0),a2      ;a2 = ColorInt ptr
        moveq.l #3,d2
        and.w   d0,d2                   ;d2 = y & 3
        lsl.w   #2,d2                   ;d2 = (y & 3) << 2
        movea.l pi_dmatrix(a0),a3       ;a3 = dmatrix
        adda.l  d2,a3                   ;a3 = dmatrix + ((y & 3) << 2)
        move.w  pi_xpos(a0),d2          ;d2 = x
        movea.l pi_ScaleX(a0),a0        ;a0 = ScaleX (sxptr)

; a0 - sxptr
; a1 - ptr
; a2 - ColorInt ptr
; a3 - dmatrix ptr
; d0 - byte to set (x >> 3)
; d1 - width
; d2 - x
; d3 - dvalue (dmatrix[x & 3])
; d4 - Black
; d5 - sx
; d6 - bit to set

gwidth_loop:
        move.b  PCMBLACK(a2),d4         ;d4 = Black
        addq.l  #ce_SIZEOF,a2           ;advance to next entry

        move.w  (a0)+,d5                ;d5 = # of times to use this pixel (sx)
        subq.w  #1,d5                   ;adjust for dbra

gsx_loop:
        moveq.l #3,d3
        and.w   d2,d3                   ;d3 = x & 3
        move.b  0(a3,d3.w),d3           ;d3 = dmatrix[x & 3]

        cmp.b   d3,d4                   ;render this pixel?
        ble.s   gsx_end                 ;no, skip to next pixel.

        move.w  d2,d0
        lsr.w   #3,d0                   ;compute byte to set
        move.w  d2,d6
        not.w   d6                      ;compute bit to set
        bset.b  d6,0(a1,d0.w)           ;*(ptr + x >> 3) |= 2 ^ x

gsx_end
        addq.w  #1,d2                   ;x++
        dbra    d5,gsx_loop             ;sx--
        dbra    d1,gwidth_loop          ;width--

exit:
        movem.l (sp)+,d2-d6/a2-a3       ;restore regs used
        moveq.l #0,d0                   ;flag all ok
        rts                             ;goodbye

        END

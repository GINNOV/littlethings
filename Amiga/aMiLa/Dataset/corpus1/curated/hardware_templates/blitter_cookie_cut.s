;==============================================================================
; Title:       Amiga Blitter Cookie-Cut Copy Routine
; Assembler:   vasmm68k_mot
; Description: Demonstrates how to use the Amiga Blitter to perform a masked
;              "cookie-cut" copy from Source A (with mask C) to Destination D,
;              polling the Blitter busy flag for completion.
;==============================================================================

    SECTION Code,CODE

; Routine to execute a masked Blitter copy
; A0 = Pointer to source bitmap data (Channel A)
; A1 = Pointer to mask data (Channel C)
; A2 = Pointer to background destination data (Channel B)
; A3 = Pointer to output destination data (Channel D)
; D0 = Width in words
; D1 = Height in lines
; D2 = Source modulo in bytes
; D3 = Destination modulo in bytes
BlitterMaskedCopy:
    movem.l d2-d4/a4-a6,-(sp)
    lea     $dff000,a4          ; Base address of Amiga custom chips

    ; Wait for any active Blitter operation to complete
.wait_blit1:
    btst    #6,$002(a4)         ; Check BBUSY bit of DMACONR ($dff002)
    bne.s   .wait_blit1

    ; Set modulo registers
    move.w  d2,$064(a4)         ; BLTAMOD (Source A Modulo)
    move.w  d2,$062(a4)         ; BLTBMOD (Background B Modulo)
    move.w  d2,$060(a4)         ; BLTCMOD (Mask C Modulo)
    move.w  d3,$066(a4)         ; BLTDMOD (Destination D Modulo)

    ; Set mask registers
    move.w  #$ffff,$044(a4)     ; BLTAFWM (First Word Mask)
    move.w  #$ffff,$046(a4)     ; BLTALWM (Last Word Mask)

    ; Set channel pointers
    move.l  a0,$050(a4)         ; BLTAPT (Source A Address)
    move.l  a2,$04c(a4)         ; BLTBPT (Background B Address)
    move.l  a1,$048(a4)         ; BLTCPT (Mask C Address)
    move.l  a3,$054(a4)         ; BLTDPT (Destination D Address)

    ; Set control registers
    ; BLTCON0: Channels A, B, C, D active, logic function LF = $ca (Cookie Cut)
    ; $FCA0: A, B, C, D enabled, LF = $ca (D = A*C + B*/C)
    move.w  #$fca0,$040(a4)     ; BLTCON0
    move.w  #$0000,$042(a4)     ; BLTCON1 (No shifts, normal copy)

    ; Trigger the Blitter!
    ; BLTSIZE: Height in bits 6-15, Width in words in bits 0-5
    ; Format: (Height << 6) | Width
    lsl.w   #6,d1
    and.w   #$ffc0,d1
    and.w   #$003f,d0
    or.w    d0,d1
    move.w  d1,$058(a4)         ; BLTSIZE (Starts the blit!)

    ; Wait for completion
.wait_blit2:
    btst    #6,$002(a4)         ; Check BBUSY
    bne.s   .wait_blit2

    movem.l (sp)+,d2-d4/a4-a6
    rts

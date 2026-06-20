
; Decode - Decode data previously encoded by LhEncode

; Inputs:  d0 - size of source region
;          a0 - pointer to source region
;          a1 - pointer to destination region
;!NO!(was a2) - pointer to beginning of auxilary buffer (4500 bytes)
;
; Outputs: d0 - size of destination region (after decompression)

; Note:    Previous contents of d0/d1, a0/a1 must be considered
;          gone.

LHDecode: clr.l   -(sp)         ; Size of auxilary buffer (unused)
        pea     AuxBuffer(pc) ; Auxilary buffer

        clr.l   -(sp)         ; Size of destination buffer (unused)
        pea     (a1)          ; lh_Dst

        move.l  d0,-(sp)      ; lh_SrcSize
        pea     (a0)          ; lh_Src

        lea     (sp),a0       ; At this point we have created a
                              ; properly initialized LhBuffer-
                              ; sized structure right on the stack.

        lea     DecodeDump(pc),a1 ; DecodeDump is the starting address
                              ; of Decode.bin (can be located
                              ; anywhere).

        jsr     (a1)          ; Decompress data...

        lea     6*4(sp),sp    ; Restore previous stack pointer

        rts                   ; and return

DecodeDump	incbin source:P.KENT/LHLIB/DECODE.BIN	; Raw decode binary...
AuxBuffer	ds.b	4500

;------------------------------------------------------------------------------
; Routine: DisableDMA
; Purpose: Writes to the DMACON register to halt the DMA controller operation.
; Address: $dff096 (DMACON)
; Parameter: None
; Returns: Execution continues after the DMA controller is disabled.
;------------------------------------------------------------------------------

DisableDMA:
    move.w #0, $dff096    ; Write word 0 to DMACON ($dff096).
                           ; This clears the GO bit and halts the DMA transfer.
    rts                   ; Return from subroutine.
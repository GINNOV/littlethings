; ==========================================================
;   Amiga 68000 Audio Sine Channel 0 Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _PlayAudio
_PlayAudio:
            lea        $dff000,a6

            ; 1. Set channel 0 pointer to sample data
            lea        SineWave(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LCH/AUD0LCL

            ; 2. Set sample length (in words)
            move.w     #4,$a4(a6)           ; AUD0LEN (8 bytes = 4 words)

            ; 3. Set volume (0 to 64)
            move.w     #64,$a8(a6)          ; AUD0VOL (Max)

            ; 4. Set period (lower = higher pitch)
            move.w     #428,$a6(a6)         ; AUD0PER (~440Hz Sine)

            ; 5. Enable audio DMA channel 0
            move.w     #$8201,$96(a6)       ; DMACON: AUD0EN and DMAEN
            rts

            ALIGN      4
SineWave:
            ; 8-bit signed audio sample wave data (8 bytes)
            dc.b       0, 90, 127, 90, 0, -90, -127, -90

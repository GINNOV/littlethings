;---------------------------------------------------------
; PRO-PACK 6502 Unpack Routine - Method 2
;
; Copyright (c) 1992 Rob Northen Computing
;
; File: C6502_2.S
;
; Date: 03.03.92
;---------------------------------------------------------

; ZERO-PAGE ADDRESSES

IN      EQU     $          ; 16 bit address of packed file
OUT     EQU     IN+2       ; 16 bit address to unpack file

SPOS    EQU     OUT+2
SLEN    EQU     SPOS+2

RELOAD  MACRO
        LDA (IN),Y
        INY
        BNE @\@
        INC IN+1
@\@
        ROL A
        ENDM

GETBIT  MACRO
        ASL A
        ENDM

GETRAW  MACRO
        LDA (IN),Y
        STA (OUT,X)
        INY
        BNE @\@
        INC IN+1
@\@
        INC OUT
        BNE @\@
        INC OUT+1
@\@
        ENDM

;---------------------------------------------------------
; 6502 Unpack Routine - Method 2
;
; On entry,
;
; IN  = address of packed file (16 bit address)
; OUT = address to unpack file (16 bit address)
;
; On exit,
;
; registers undefined
;---------------------------------------------------------
UNPACK
        CLD
        SEC
        LDX #0
        LDY #18
        RELOAD
        GETBIT
        JMP XLOOP

;---------------------------------------------------------

FETCH0
        RELOAD
        BNE BACK0

RAW
        LDX #4
X4BITS
        GETBIT
        BEQ FETCH0
BACK0
        ROL SPOS+1
        DEX
        BNE X4BITS
        PHA
        LDX SPOS+1
        INX
        INX
        INX
        TYA
        ADC IN
        STA IN
        BCC @1
        INC IN+1
@1
        LDY #0
RAWLP
        LDA (IN),Y
        STA (OUT),Y
        INY
        LDA (IN),Y
        STA (OUT),Y
        INY
        LDA (IN),Y
        STA (OUT),Y
        INY
        LDA (IN),Y
        STA (OUT),Y
        INY
        DEX
        BNE RAWLP
        TYA
        CLC
        ADC OUT
        STA OUT
        BCC @1
        INC OUT+1
@1
        PLA
        JMP XLOOP

;---------------------------------------------------------

FETCH1
        RELOAD
        BNE BACK1
FETCH2
        RELOAD
        BNE BACK2
FETCH3
        RELOAD
        BNE BACK3

GTLEN
        GETBIT
        BEQ FETCH1
BACK1
        ROL SLEN
        GETBIT
        BEQ FETCH2
BACK2
        BCC COPY
        GETBIT
        BEQ FETCH3
BACK3
        DEC SLEN
        ROL SLEN
        LDX SLEN
        CPX #9
        BEQ RAW
        LDX #0
        BEQ COPY

;---------------------------------------------------------

FETCH4
        RELOAD
        BNE BACK4
FETCH5
        RELOAD
        BNE BACK5
FETCH6
        RELOAD
        BNE BACK6
FETCH7
        RELOAD
        BNE BACK7

COPY
        GETBIT
        BEQ FETCH4
BACK4
        BCC BYTEDISP
        GETBIT
        BEQ FETCH5
BACK5
        ROL SPOS+1
        GETBIT
        BEQ FETCH6
BACK6
        BCC @1
        JMP BIGDISP
@1
        CPX SPOS+1
        BNE BYTEDISP
        INC SPOS+1
ANOTHER
        GETBIT
        BEQ FETCH7
BACK7
        ROL SPOS+1
BYTEDISP
        PHA
        LDA OUT
        CLC
        SBC (IN),Y
        STA SPOS
        LDA OUT+1
        SBC SPOS+1
        STA SPOS+1
        INY
        BNE @1
        INC IN+1
@1
        TYA
        PHA
        LDY #0
        LDA SLEN
        LSR A
        BEQ BYTEDISP3
        TAX
BYTEDISP2
        LDA (SPOS),Y
        STA (OUT),Y
        INY
        LDA (SPOS),Y
        STA (OUT),Y
        INY
        DEX
        BNE BYTEDISP2
BYTEDISP3
        BCC BYTEDISP4
        LDA (SPOS),Y
        STA (OUT),Y
        INY
        CLC
BYTEDISP4
        TYA
        ADC OUT
        STA OUT
        BCC @1
        INC OUT+1
@1
        PLA
        TAY
        PLA
        BNE XLOOP

;---------------------------------------------------------

GTBITS
        RELOAD
        BCS STRING
XBYTE
        PHA
        GETRAW
        PLA
XLOOP
        GETBIT
        BCS CHKZ
        PHA
        GETRAW
        PLA
        GETBIT
        BCC XBYTE
CHKZ
        BEQ GTBITS

;---------------------------------------------------------

STRING
        STX SPOS+1
        STX SLEN
        INC SLEN
        INC SLEN
        GETBIT
        BEQ FETCH8
BACK8
        BCS SMALLS
        JMP GTLEN
SMALLS
        GETBIT
        BEQ FETCH9
BACK9
        BCS @1
        JMP BYTEDISP
@1
        INC SLEN
        GETBIT
        BEQ FETCH10
BACK10
        BCS @1
        JMP COPY
@1
        PHA
        LDA (IN),Y
        STA SLEN
        PLA
        INY
        BNE @2
        INC IN+1
@2
        CPX SLEN
        BEQ OVERNOUT
        PHA
        LDA SLEN
        CLC
        ADC #8
        STA SLEN
        PLA
        JMP COPY
BIGDISP
        GETBIT
        BEQ FETCH11
BACK11
        PHA
        LDA SPOS+1
        ROL A
        ORA #4
        STA SPOS+1
        PLA
        GETBIT
        BEQ FETCH12
BACK12
        BCC @1
        JMP BYTEDISP
@1
        JMP ANOTHER
FETCH8
        RELOAD
        BNE BACK8
FETCH9
        RELOAD
        BNE BACK9
FETCH10
        RELOAD
        BNE BACK10
FETCH11
        RELOAD
        BNE BACK11
FETCH12
        RELOAD
        BNE BACK12
OVERNOUT
        GETBIT
        BNE CHECK4END
        RELOAD
CHECK4END
        BCC @1
        JMP XLOOP
@1
        RTS


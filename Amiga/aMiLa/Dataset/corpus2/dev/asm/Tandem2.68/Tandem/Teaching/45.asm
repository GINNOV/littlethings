* 45.asm    TLfloat              version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; TLfloat allows you to change an ASCII string to the format that an FPU
; uses for its input. Strangely, tandem.library does not use the FPU to
; do TLfloat, but of course the FPU would immediately be called to FMOVE
; TLfloat's output into one of its registers.

; TLfloat points A0 to the delimiter of the float, so for example if you
; input  123.45,  then TLfloat will return with A0 pointint to the , which
; is the delimiter of the float. Thus, you can use TLfloat to evaluate
; 1 by 1 sets of floats separated by commas, spaces, or whatever. TLfloat
; is very flexible and hopefully clever in what it will accept as an input.


strings: dc.b 0
st_1: dc.b 'Test TLFloat',0 ;1
 dc.b 'Input a float (e.g. -123.45, 1.76E-5)',0 ;2
 dc.b 'bad: no mantissa digits ',0 ;3
 dc.b 'bad: abs(exponent)>999 after normalising ',0 ;4
 dc.b 'bad: no digits after E ',0 ;5

 ds.w 0


* demonstrate TLfloat
Program:
 TLwindow #-1              ;initialise
 beq Pr_quit

Pr_cyc:
 clr.b (a4)
 TLreqinput #2,str,#25     ;get next input
 beq Pr_quit               ;done if cancel

 move.l a4,a0              ;tfr input to buff+100
 move.l a4,a1
 move.l a1,a2
 add.l #100,a2             ;a2=buff+100
 move.l a2,a1
Pr_tfr:
 move.b (a0)+,(a1)+
 bne Pr_tfr

 move.l a4,a3              ;a3=buff+200
 add.l #200,a3

 TLfloat a2,a3             ;put float in buff+200 (12 bytes)
 bne.s Pr_good             ;go if good

 addq.w #2,d0              ;convert d0 to error string num
 TLstra0 d0                ;point to error string
 move.l a4,a1
Pr_bad:
 move.b (a0)+,(a1)+        ;error string to buffer
 bne Pr_bad
 bra.s Pr_pik              ;append for input

Pr_good:
 move.l a3,a0              ;convert ouput to ASCII
 move.l a4,a1
 moveq #5,d1               ;(6 words)

Pr_word:
 move.w (a0)+,d0           ;get word
 moveq #3,d2               ;(4 nybbles)

Pr_nybb:
 rol.w #4,d0               ;get next nybble
 move.w d0,d3              ;convert to hex
 and.w #15,d3
 add.b #'0',d3
 cmp.b #':',d3
 bcs.s Pr_asc
 add.b #'A'-':',d3         ;(only 1st byte should get here!)

Pr_asc:
 move.b d3,(a1)+           ;put ASCII of nybble
 dbra d2,Pr_nybb
 move.b #' ',(a1)+         ;spc between words
 dbra d1,Pr_word

Pr_pik:
 move.b #'}',(a1)+         ;append '}' then input
 move.b #' ',(a1)+
 move.l a2,a0

Pr_app:
 move.b (a0)+,(a1)+
 bne Pr_app

 TLreqchoose               ;show 'output } input', wait for acknowledge
 bra Pr_cyc                ;repeat until cancel

Pr_quit:
 rts

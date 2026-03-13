* 
* This is a old intro coded by me (Chucky) a long time ago. 
* I found this on a CD when setting up my laptop as an AmigaXL 
* machine..  well..  loaded UAE on my desktop machine and found out 
* that all files was there..  so well why not release the source 
* someone maybe wants to check this code..  not THAT good coded maybe 
* but I am quite pleased anyway. 
* for you who doesnt know.. I was a member of an OOOOLD demogroup called 
* The Gang and The Gang was a member of TRIANGLE 
* 
* Later I joined groups like Addonic, Sargon, X-Trade and ViRTUAL 
* 
* Well  enjoy this code.. you can mail me at: 
* 
*      chucky<at>hertell.nu 
* 
* Any comments, please mail..  would be fun if someone thinks this is 
* a good idea to release my old sources.  I will release more when I find 
* them 
* 
* Take care... 
* 
* Intro coded with AsmOne by the way 
* 
 
 Section intro,Code_C

j: 
 move.w #32,$dff1dc 
 move.l SP,STACKPOINTER 
 move.l $4,a6 
 jsr -150(a6) 
 move.l d0,sysstack 
ClearSpritePointers: 
 lea SpritePointers1(pc),a0 
 lea SpritePointers1(pc),a1 
 move.w #7,d0 
 move.l #Dummy,d1 
ClearS: 
 move.w d1,6(a0) 
 move.w d1,6(a1) 
 swap d1 
 move.w d1,2(a0) 
 move.w d1,2(a1) 
 swap d1 
 addi.l #8,a0 
 addi.l #8,a1 
 dbf d0,ClearS 
 bset #1,$bfe001

 jsr PrintGang 
 jsr FixLogoPos 
 bsr printscreen

 move.l #copperlist,$dff080 
 move.w $dff088,d0 
 move.w #$8380,$dff096

 move.w #%1000010000000000,$dff096 
 bsr bpinit

 move.l #bild,d0 
 move.w d0,bilden+6 
 swap d0 
 move.w d0,bilden+2

koll: 
 cmp.b #$ff,$dff006 
 bne.s koll

 Bsr SineScroller 
 bsr bpmusic 
 bsr cycle

 btst #6,$bfe001 
 bne.L koll

Exit: 
 move.w #$f,$dff096 
 move.w #%0000010000000000,$dff096 
 move.l $4,a6 
 move.l sysstack,d0 
 jsr -156(a6) 
 lea graph,a1 
 jsr -408(a6) 
 move.l d0,a6 
 move.l 38(a6),$dff080 
 move.w #$c000,$dff09a 
 move.l STACKPOINTER,SP 
 clr.l d0 
 clr.l d1 
 rts

;······························································ 
;· 1 Pixel Sinus Scroller coded by Chucky of The Gang! a FAST · 
;·   motherfucker BUT it will be EVEN FASTER!  my goals is:   · 
;· 1 Pixel Sinus scroller in Hi-Res!  1Pix sinus in a tube in · 
;·  lores OR Hires!  and a 64 pixel HIGH 1 Pixel scroller in  · 
;·                        LO-RES OR HIRES!                    · 
;······························································

SineScroller: 
 bsr s16Scr 
 bsr sinblit 
 bsr doublebuffer 
 rts

vblt: 
 move.w #$09f0,$dff040 
 clr.w  $dff042 
 move.l #$ffffffff,$dff044 
 move.w #$8040,$dff096 
 rts

Spos: dc.w 0

SWrap: 
 clr.l pos  ;Rensa Pos (LongWord) 
 bra S16Scr1  ;Hoppa te rutinen S15Scr1

S16Scr: 
 bsr SpixBlitta  ;Hoppa te subrutinen Spixblitta 
 addq.w #1,Spos  ;Addera Spos med 1 (Word) 
 cmp.w #8,Spos  ;Kolla om Spos e 8 (Word) 
 beq.s S16Scr1  ;Ja Hoppa till S16Scr1 
 rts   ;Avsluta

S16Scr1: 
 move.w #0,Spos  ;Rensa Spos (Word) 
 moveq #0,d0  ;Rensa D0  SNABBare an Clr.l d0 
 lea text(pc),a0  ;Ladda A0 me var texten e 
 add.l pos,a0  ;Addera Pos till A0 
 addq.l #1,pos  ;Addera Pos med 1 
 move.b (a0),d0  ;Ladda D0 med innehallet i adressen som 
    ;A0 innehaller 
 tst.b d0  ;Kollar om D0 e noll 
 beq SWrap  ;Japp hoppa till SWrap

 sub.b #$20,d0  ;Subtrahera $20 (32) pa D0 
 add.w d0,d0  ;Addera D0 med D0! snabbare an att 
    ;multiplicera med 2 
 lea ascii(pc),a0 ;Ladda A0 med var ASCII tabellen e i 
    ;minnet 
 move.w (a0,d0),d2 ;Ladda D2 med vardet adressen A0+D0 e 
 

 bsr.s vblt  ;Hoppa till subrutinen Vblt 
 move.l #chr,d1  ;Ladda D1 med var i minnet CHR e 
 add.w d2,d1  ;Addera d2 pa D1 
 move.l d1,$dff050 ;Ladda Dff050 med D1 
 move.l #Screen1+40,$dff054 ;Ladda Dff054 med var skarmen 
    ;e plus 40 
 move.w #40,$dff066 ;Ladda Dff066 med 40 
 move.w #78,$dff064 ;Ladda Dff064 med 78 
 move.w #16*64+1,$dff058 ;Storlek pa blittningen a starta! 
; hojd    ^^    ^ Bredd i words! (16 Pixels!) 
 rts   ;Avsluta

SPixBlitta: 
 bsr vblt  ;Hoppa till subrutinen vblt 
 move.w #$e9f0,$dff040 ;Ladda Dff040 med $e9f0 
    ;9f0=vanlig blit  $e=Scrolla 
    ;skiten $e (14) pixels at HOGER! 
    ;(grejjas te 2 pixels at vanster sedan)

 move.l #Screen1+2,d1 ;Ladda Source med var bilden e i minnet 
    ;plus 2 (D1) 
 move.l #Screen1,d0 ;Ladda Destination med var bilden ligger 
    ;(D0) 
 move.l d1,$dff050 
 move.l d0,$dff054 
 move.w #0,$dff066 
 move.w #0,$dff064 
 move.w #16*64+21,$dff058 
 rts

pos: dc.l 0

ASCII:   ;Ascii tabell en lista pa hur mycke man ska 
   ;addera for att komma till onskat tecken i 
   ;fonten! efter den Ascii standard som star i 
   ;bla basic manualen!  startar med SPACE!

 dc.w 0,56,0,0,0,0,0,0,0,0,0 
 dc.w 0,0,60,58,0,0,0,0,0,0,0,0,0,0,0,54,0,0,0,0,60 
 dc.w 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32 
 dc.w 34,36,38,40,42,44,46,48,50,52,0,0,0

Screen1: blk.b 50*42,0 ;Scrollbitplane!  nar scrollen INTE 
    ;e i sinus!!!!

Chr:  incbin "sinfnt" ;fonten

Vanta: 
 btst #14,$dff002 ;Kolla om bit 14 i Dff002 e 1 
 bne.s vanta  ;nepp hoppa till Vanta 
 rts   ;avsluta 
 

SinBlit:  ;Satter sinus pa scrollen! 
   ;DETTA kommer ni inte fatta natt av :-)

 lea $dff040,a4  ;Ladda a4 med $dff040 
 bsr vanta  ;Hoppa te subrutinen Vanta

 move.w #$100,(a4) ;Ladda adressen som a4 innehaller med 
    ;$100  (satt blittret pa att rensa!) 
 move.w  #0,2(a4) ;Nollstall adressen som a4+2 innehaller

 move.l scr,$14(a4) ;Ladda adressen som a4 + $14 innehaller 
    ;med det som finns i scr 
 move.w #0,$26(a4) ;rensa adressen som 14 + $26 innehaller

 move.w #146*64+24,$18(a4) ;satter storlek a startar 
     ;blittret! (rensa skarmen) 
 jsr FixLogoPos 
 bsr vanta  ;Hoppa te subrutinen Vanta

 move.w #$dfc,(a4) ;Ladda adressen som a4 innehaller med 
    ;DFC  mao satt blittret pa 2 st sourcer 
    ;som ska blandas ihop! 
 move.w #40,$26(a4) ;Satt adressen som a4+$26 innehaller med 
    ;40 
 move.l #$00280028,$22(a4) ;Satt adressen som a4+$22 innehaller 
    ;med $00280028

 lea scrpos(pc),a2 ;Ladda a2 med var scrpos e i minnet 
 lea SinPos(pc),a3 ;ladda a3 med var sinpos e i minnet

 move.b (a3),1(a3) ;flytta de som adressen i a3 innehaller 
    ;te adressen aom a3+1 innehaller 
 addq.b #3,(a3)  ;subtrahera minnet i adressen som a3 
    ;innehaller

 lea sajnus(pc),a1 ;ladda a1 men var sajnus e i minnet

 move.l scr,(a2)  ;flytta de som finns i scr te den 
    ;adressen som a2 innehaller

 move.w #19,d6  ;ladda d6 med 19 
    ;(hur manga word stor scrollen e! 
    ; 19 e MAX!) 
 move.l #screen1,d2 ;Ladda d2 med VAR Screen1 e i minnet!

 move.l #pixadd,d5 ;Ladda d5 med var pixadd e i minnet

 move.w #15*64+1,d3 ;ladda d3 med storlek pa blittningen

Loopa: 
 move.l d5,a0  ;addera d5 pa a0 
 moveq #15,d7  ;ladda d7 med 15 (snabb version av move) 
Loop: 
 moveq #0,d1  ;rensa d1 
 move.b 1(a3),d1  ;ladda d1 med det som adressen som a3+1 innehaller

 move.l (a2),d0  ;ladda D0 med det som adressen som a2 innehaller 
 add.w d1,d1  ;addera d1 me d1 
 addq.b #1,1(a3)  ;Addera 1 (BYTE) dar pa den adressen som a3+1 innehaller

 add.w (a1,d1.w),d0 ;Addera d0 med det som finns i adressen dar a1+d1 innehaller 
 move.w (a0),4(a4) ;Ladda de som adressen aom a4+4 innehaller 
    ;till den adressen som a0 innehaller 
 move.w (a0)+,6(a4) 
 move.l d2,$10(a4) ;ladda adressen som a4+$10 innehaller 
 add.w #6*42,d0 
 move.l d0,$c(a4) 
 move.l d0,$14(a4) 
 move.w d3,$18(a4) 
 dbf d7,loop  ;subtrahera d7 med 1 om det inte 
    ;blir negativt sa hoppa till loop 
 addq #2,d2  ;subtrahera d2 med 2 
 addq.l #2,(a2)  ;subtrahera 2 pa dan adressen som 
    ;a2 innehaller 
 dbf d6,loopa 
 rts   ;avsluta

SinPos: dc.w 0 
ScrPos: dc.l 0

systack: dc.l 0

Scr: dc.l Screen3 
Scr1: dc.l Screen2

DoubleBuffer: 
 move.l Scr,d0  ;Ladda d0 med de som finns i scr 
 move.l scr1,scr  ;ladda scr med de som finns i scr1 
 move.l d0,scr1  ;ladda scr1 med d0 
 move.l scr1,d0 
 sub.l #2,d0 
 move.w d0,Visa+6 ;slang de som finns i scr1 te visa+2 
 swap d0 
 move.w d0,visa+2 ;slang de som finns i scr1+2 te visa+6 
 rts   ;avsluta 
 

PixAdd:    ;Bara villka bittar som ska blittas 
 dc.w %1000000000000000 
 dc.w %0100000000000000 
 dc.w %0010000000000000 
 dc.w %0001000000000000 
 dc.w %0000100000000000 
 dc.w %0000010000000000 
 dc.w %0000001000000000 
 dc.w %0000000100000000 
 dc.w %0000000010000000 
 dc.w %0000000001000000 
 dc.w %0000000000100000 
 dc.w %0000000000010000 
 dc.w %0000000000001000 
 dc.w %0000000000000100 
 dc.w %0000000000000010 
 dc.w %0000000000000001

Text:  ;texten! 
 dc.b "         THIS INTRO WAS CODED BY CHUCKY SEVERAL YEARS AGO AND" 
 DC.B " WAS NEVER RELEASED AND I JUST FOUND IT ON A CD SO I DECIDED" 
 DC.B " JUST TO MAKE THE WHOLE THING OPEN SOURCE LIKE I WILL DO WITH " 
 DC.B " ALL OLD STUFF I FIND.  JUST FOR FUN YOU KNOW             " 
 EVEN

 DC 0

EVEN 
 

Cycle: 
 add.w #1,.pussy 
 cmp.w #16,.Pussy 
 bne.s .return 
 clr.w .Pussy 
 lea Colors,a0 
 move.w .pos,d0 
 move.w (a0,d0),d1 
 cmp.w #$0,d1 
 beq.s .wrap 
 add.w #2,.pos 
 move.w d1,Color+2 
.return: 
 rts 
.Wrap: 
 clr.w .pos 
 bra.s Cycle 
.Pos: 
 dc.w 0 
.Pussy: 
 dc.w 0

Copperlist:  ;jobbig a forklara! 
SpritePointers1: 
 dc.l $01200000,$01220000,$01240000,$01260000,$01280000,$012a0000 
 dc.l $012c0000,$012e0000,$01300000,$01320000,$01340000,$01360000 
 dc.l $01380000,$013a0000,$013c0000,$013e0000 
 dc.l $01040040 
 dc.l $01003600,$00920030,$009400d0,$008e2481 
 dc.l $01800000,$01820fff,$01840666,$01860aaa 
Color: dc.l $01920f00 
 dc.l $0090c4bc 
Delay: 
 dc.l $01020000 
 dc.l $010800fe,$010a0000 
 dc.l $01800000,$01820fff 
Bpl: 
 dc.l $00e00000,$00e20000 
Bpl1: 
 dc.l $00e80000,$00ea0000 
visa: 
 dc.l $00e40000,$00e60000

 dc.l $d101ff00

 dc.l $01001200,$00920038,$009400d0,$008ed281 
 dc.l $01800000,$01820222,$01020000 
 dc.l $0090f9cc,$01080000 
Bilden: 
 dc.l $00e00000,$00e20000 
 dc.l $d301ff00,$01820444 
 dc.l $d401ff00,$01820666 
 dc.l $d601ff00,$01820888 
 dc.l $d701ff00,$01820aaa 
 dc.l $d801ff00,$01820ccc 
 dc.l $d901ff00,$01820eee 
 dc.l $f301ff00,$01820ccc 
 dc.l $f401ff00,$01820aaa 
 dc.l $f501ff00,$01820888 
 dc.l $f601ff00,$01820666 
 dc.l $f701ff00,$01820444 
 dc.l $f801ff00,$01820222 
 dc.l $fffffffe 
 

graph: dc.b 'graphics.library',0 
 EVEN 
SYSSTACK: dc.l 0 
STACKPOINTER: dc.l 0 
Dummy: dc.l 0

 EVEN

Sajnus:  ;sinusdatan!  sinusposition * 42 
; Data made with Chucky's Sinus Maker in HI-SOFT Basic (COMPILED) 
 Dc.w $AD4,$AFE,$B52,$B7C,$BD0,$BFA,$C4E,$CA2,$CCC,$D20,$D4A,$D9E,$DC8 
 Dc.w $E1C,$E46,$E9A,$EC4,$F18,$F42,$F96,$FC0,$1014,$103E,$1068,$10BC 
 Dc.w $10E6,$1110,$113A,$118E,$11B8,$11E2,$120C,$1236,$128A,$12B4,$12DE,$1308 
 Dc.w $1332,$135C,$1386,$13B0,$13B0,$13DA,$1404,$142E,$1458,$1458,$1482,$14AC 
 Dc.w $14AC,$14D6,$14D6,$1500,$1500,$152A,$152A,$152A,$1554,$1554,$1554,$1554 
 Dc.w $1554,$1554,$1554,$157E,$1554,$1554,$1554,$1554,$1554,$1554,$1554,$152A 
 Dc.w $152A,$152A,$1500,$1500,$14D6,$14D6,$14AC,$14AC,$1482,$1458,$1458,$142E 
 Dc.w $1404,$13DA,$13B0,$13B0,$1386,$135C,$1332,$1308,$12DE,$12B4,$128A,$1236 
 Dc.w $120C,$11E2,$11B8,$118E,$113A,$1110,$10E6,$10BC,$1068,$103E,$1014,$FC0 
 Dc.w $F96,$F42,$F18,$EC4,$E9A,$E46,$E1C,$DC8,$D9E,$D4A,$D20,$CCC 
 Dc.w $CA2,$C4E,$BFA,$BD0,$B7C,$B52,$AFE,$AD4,$A80,$A2C,$A02,$9AE 
 Dc.w $984,$930,$8DC,$8B2,$85E,$834,$7E0,$7B6,$762,$738,$6E4,$6BA 
 Dc.w $666,$63C,$5E8,$5BE,$56A,$540,$516,$4C2,$498,$46E,$444,$3F0 
 Dc.w $3C6,$39C,$372,$348,$2F4,$2CA,$2A0,$276,$24C,$222,$1F8,$1CE 
 Dc.w $1CE,$1A4,$17A,$150,$126,$126,$FC,$D2,$D2,$A8,$A8,$7E 
 Dc.w $7E,$54,$54,$54,$2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A 
 Dc.w $2A,$2A,$2A,$2A,$2A,$2A,$2A,$54,$54,$54,$7E,$7E 
 Dc.w $A8,$A8,$D2,$D2,$FC,$126,$126,$150,$17A,$1A4,$1CE,$1CE 
 Dc.w $1F8,$222,$24C,$276,$2A0,$2CA,$2F4,$348,$372,$39C,$3C6,$3F0 
 Dc.w $444,$46E,$498,$4C2,$516,$540,$56A,$5BE,$5E8,$63C,$666,$6BA 
 Dc.w $6E4,$738,$762,$7B6,$7E0,$834,$85E,$8B2,$8DC,$930,$984,$9AE 
 Dc.w $A02,$A2C,$A80,$AD4

 ;abcdef

Colors: 
 dc.w $f00,$e10,$d20,$c30,$b40,$a50,$960,$870,$780,$690,$5a0,$4b0 
 dc.w $3c0,$2d0,$2e0,$1f0,$0f1,$0f2,$0f3,$0f4,$0f5,$0f6,$0f7,$0f8 
 dc.w $0f9,$0fa,$0fb,$0fc,$0fd,$0fe,$0ff,$0ef,$0df,$0cf,$0bf,$0af 
 dc.w $09f,$08f,$07f,$06f,$05f,$04f,$03f,$02f,$01f,$10f,$20f,$30f 
 dc.w $40f,$50f,$60f,$70f,$80f,$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f 
 dc.w $f0e,$f0d,$f0c,$f0b,$d0a,$f09,$f08,$f07,$f06,$f05,$f04,$f03 
 dc.w $f02,$f00,0 
 

PrintScreen: 
 move.l textpos,a2 
 cmp.b #1,(a2) 
 beq.s textend 
 move.l TextYpos,d1 
 moveq #0,d0 
 bsr.s printline8 
 move.l a2,TextPos 
 add.l #1,TextYpos 
 bra.s PrintScreen

TextEnd: 
 move.l #ttext,textpos 
 move.l #0,textypos 
 rts

TextPos: dc.l tText 
TextYpos: dc.l 0

Printline8: ;D0=Xpos D1=Ypos A2=Textstring 
 lea Bild,a0 
 mulu #320,d1 
 add.w d0,d1 
 add.w d1,a0 
printline81: 
 move.l a0,a3 
 clr.l d0 
 move.b (a2)+,d0 
 cmp.b #$0,d0 
 beq nomoreprnt 
 cmp.b #'a',d0 
 blt noletter 
 bclr #5,d0 
noletter: 
 bsr putchr8 
 move.l a3,a0 
 adda.l #1,a0 
 bra printline81 
nomoreprnt: 
 rts

PutChr8: ;D0=Char A0=Screen 
 lea font,a1 
 sub.b #$20,d0 
 clr.l d1 
 move.b d0,d1 
 mulu #8,d1 
 add.w d1,a1 
 move.w #7,d1

PutChr81: 
 move.b (a1)+,(a0) 
 adda.l #40,a0 
 dbf d1,putchr81 
 rts

ttext:;     1234567890123456789012345678901234567890' 
 dc.b " ",0 
 DC.b '----------------------------------------',0 
 DC.b '     OLD INTRO BY CHUCKY OF ADDONIC',0 
 DC.b '----------------------------------------',0 
 DC.b '  ',0 
 DC.b 1

 EVEN

font: 
;********************************************************* 
;*                                                       * 
;*  Font from the 64 to AMIGA by Tigershark of THE GANG  * 
;*                                                       * 
;********************************************************* 
; FONT:6,P,R 
;********************************************************* 
 DC.B  0, 0, 0, 0, 0, 0, 0, 0;" " 
 DC.B  14, 14, 12, 8, 8, 32, 48, 0;"!" 
 DC.B  102, 102, 34, 0, 0, 0, 0, 0;""" 
 DC.B  108, 108, 127, 54, 127, 27, 27, 0;"#" 
 DC.B  24, 62, 96, 60, 6, 124, 24, 0;"$" 
 DC.B  102, 110, 12, 24, 48, 115, 99, 0;"%" 
 DC.B  60, 102, 60, 56, 103, 102, 63, 0;"&" 
 DC.B  12, 12, 24, 0, 0, 0, 0, 0;"'" 
 DC.B  12, 24, 48, 48, 24, 12, 6, 0;"(" 
 DC.B  48, 24, 12, 6, 6, 12, 24, 0;")" 
 DC.B  0, 102, 60, 12, 30, 51, 0, 0;"1" 
 DC.B  0, 24, 24, 127, 12, 12, 0, 0;"+" 
 DC.B  0, 0, 0, 0, 0, 24, 24, 8;"," 
 DC.B  0, 0, 0, 127, 112, 0, 0, 0;"-" 
 DC.B  0, 0, 0, 0, 0, 24, 24, 0;"." 
 DC.B  0, 6, 12, 24, 24, 48, 96, 0;"/" 
 DC.B  127, 99, 99, 99, 115, 115, 127, 0;"0" 
 DC.B  24, 24, 24, 28, 28, 28, 28, 0;"1" 
 DC.B  127, 115, 3, 127, 96, 112, 127, 0;"2" 
 DC.B  127, 115, 3, 30, 3, 119, 127, 0;"3" 
 DC.B  96, 96, 112, 118, 127, 14, 14, 0;"4" 
 DC.B  127, 96, 112, 127, 3, 115, 127, 0;"5" 
 DC.B  127, 103, 112, 127, 99, 115, 127, 0;"6" 
 DC.B  127, 115, 3, 3, 7, 7, 7, 0;"7" 
 DC.B  127, 99, 115, 62, 99, 115, 127, 0;"8" 
 DC.B  127, 99, 115, 127, 3, 115, 127, 0;"9" 
 DC.B  0, 0, 24, 24, 0, 12, 12, 0;":" 
 DC.B  0, 0, 24, 24, 0, 12, 12, 4;";" 
 DC.B  14, 24, 48, 48, 24, 12, 7, 0;"<" 
 DC.B  0, 127, 112, 0, 127, 112, 0, 0;"=" 
 DC.B  112, 24, 14, 7, 6, 12, 56, 0;">" 
 DC.B  30, 39, 3, 14, 24, 32, 48, 24;"?" 
 DC.B  0, 0, 0, 0, 0, 0, 0, 0;"@" 
 DC.B  96, 112, 120, 108, 126, 99, 97, 0;"A" 
 DC.B  112, 108, 100, 124, 102, 99, 126, 0;"B" 
 DC.B  48, 104, 96, 96, 96, 113, 30, 0;"C" 
 DC.B  112, 120, 108, 102, 99, 99, 126, 0;"D" 
 DC.B  56, 96, 96, 124, 96, 112, 31, 0;"E" 
 DC.B  28, 48, 48, 62, 48, 48, 48, 0;"F" 
 DC.B  24, 52, 96, 96, 102, 115, 30, 0;"G" 
 DC.B  108, 108, 102, 126, 99, 99, 99, 0;"H" 
 DC.B  16, 16, 24, 24, 28, 28, 28, 0;"I" 
 DC.B  126, 24, 12, 6, 99, 99, 62, 0;"J" 
 DC.B  100, 108, 120, 112, 120, 110, 99, 0;"K" 
 DC.B  64, 64, 96, 96, 112, 112, 127, 0;"L" 
 DC.B  100, 108, 126, 122, 107, 99, 99, 0;"M" 
 DC.B  108, 108, 118, 118, 107, 103, 99, 0;"N" 
 DC.B  28, 46, 102, 99, 99, 115, 30, 0;"O" 
 DC.B  56, 54, 51, 51, 62, 48, 48, 0;"P" 
 DC.B  28, 46, 102, 99, 101, 114, 29, 0;"Q" 
 DC.B  112, 108, 102, 124, 120, 108, 99, 0;"R" 
 DC.B  48, 104, 96, 60, 3, 115, 62, 0;"S" 
 DC.B  126, 108, 12, 6, 6, 7, 7, 0;"T" 
 DC.B  108, 108, 102, 102, 99, 115, 62, 0;"U" 
 DC.B  102, 102, 102, 54, 54, 30, 12, 0;"V" 
 DC.B  108, 102, 102, 107, 107, 127, 50, 0;"W" 
 DC.B  108, 108, 56, 60, 102, 99, 99, 0;"X" 
 DC.B  102, 102, 54, 60, 28, 12, 12, 0;"Y" 
 DC.B  124, 108, 24, 48, 48, 96, 127, 0;"Z" 
 DC.B  60, 48, 48, 24, 24, 24, 30, 0;"[" 
 DC.B  12, 18, 48, 124, 48, 98, 252, 0;"\" 
 DC.B  60, 12, 12, 6, 6, 6, 30, 0;"]" 
 DC.B  0, 24, 60, 126, 24, 24, 24, 24;"^" 
 DC.B  0, 16, 48, 127, 127, 48, 16, 0;"_" 
  
 

; ©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©© 
; ©©                                                  ©© 
; ©©        Soundmonitor V2.0 - Replay Routine        ©© 
; ©©  Modified to run in DEVPAC ][ by STARR 26/03/90  ©© 
; ©©                                                  ©© 
; ©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©

bpinit:  lea samples(pc),a0 
  lea bpsong(pc),a1 
  clr.b numtables 
  cmpi.w #'V.',26(a1) 
  bne.s bpnotv2 
  cmpi.b #'2',28(a1) 
  bne.s bpnotv2 
  move.b 29(a1),numtables 
bpnotv2: move.l #512,d0 
  move.w 30(a1),d1  ;d1 now contains length in steps 
  moveq #1,d2    ;1 is highest pattern number 
  mulu #4,d1    ;4 voices per step 
  subq.w #1,d1    ;correction for DBRA 
findhighest: cmp.w (a1,d0),d2  ;Is it higher 
  bge.s nothigher   ;No 
  move.w (a1,d0),d2  ;Yes, so let D2 be highest 
nothigher: addq.l #4,d0    ;Next Voice 
  dbra d1,findhighest  ;And search 
  move.w 30(a1),d1 
  mulu #16,d1    ;16 bytes per step 
  move.l #512,d0    ;header is 512 bytes 
  mulu #48,d2    ;48 bytes per pattern 
  add.l d2,d0 
  add.l d1,d0    ;offset for samples 
  add.l #bpsong,d0 
  move.l d0,tables 
  moveq #0,d1 
  move.b numtables,d1  ;Number of tables 
  lsl.l #6,d1    ;x 64 
  add.l d1,d0 
  move.l #14,d1    ;15 samples 
  add.l #32,a1 
initloop: move.l d0,(a0)+ 
  cmpi.b #$ff,(a1) 
  beq.s bpissynth 
  move.w 24(a1),d2 
  mulu #2,d2    ;Length is in words 
  add.l d2,d0    ;offset next sample 
bpissynth: add.l #32,a1    ;Length of Sample Part in header 
  dbra d1,initloop 
  rts

bpmusic: bsr bpsynth 
  subq.b #1,arpcount 
  moveq #3,d0 
  lea bpcurrent(pc),a0 
  move.l #$dff0a0,a1 
bploop1: move.b 12(a0),d4 
  ext.w d4 
  add.w d4,(a0) 
  tst.b $1e(a0) 
  bne.s bplfo 
  move.w (a0),6(a1) 
bplfo:  move.l 4(a0),(a1) 
  move.w 8(a0),4(a1) 
  tst.b 11(a0) 
  bne.s bpdoarp 
  tst.b 13(a0) 
  beq.s not2 
bpdoarp: tst.b arpcount 
  bne.s not0 
  move.b 11(a0),d3 
  move.b 13(a0),d4 
  and.w #240,d4 
  and.w #240,d3 
  lsr.w #4,d3 
  lsr.w #4,d4 
  add.w d3,d4 
  add.b 10(a0),d4 
  bsr bpplayarp 
  bra.s not2 
not0:  cmpi.b #1,arpcount 
  bne.s not1 
  move.b 11(a0),d3 
  move.b 13(a0),d4 
  and.w #15,d3 
  and.w #15,d4 
  add.w d3,d4 
  add.b 10(a0),d4 
  bsr bpplayarp 
  bra.s not2 
not1:  move.b 10(a0),d4 
  bsr bpplayarp 
not2:  lea $10(a1),a1 
  lea $20(a0),a0 
  dbra d0,bploop1 
  tst.b arpcount 
  bne.s arpnotzero 
  move.b #3,arpcount 
arpnotzero: subq.b #1,bpcount 
  beq.s bpskip1 
  rts 
bpskip1: move.b bpdelay,bpcount 
bpplay:  bsr.s bpnext 
  move.w dma,$dff096 
  ;move.l #$1f4,d0  ;is this a waste ????? 
bpxx:  ;dbra d0,bpxx 
  moveq #3,d0 
  move.l #$dff0a0,a1 
  moveq #1,d1 
  lea bpcurrent(pc),a2 
  lea bpbuffer(pc),a5 
bploop2: btst #15,(a2) 
  beq.s bpskip7 
  bsr bpplayit 
bpskip7: asl.w #1,d1 
  lea $10(a1),a1 
  lea $20(a2),a2 
  lea $24(a5),a5 
  dbra d0,bploop2 
  rts 
bpnext:  clr.w dma 
  lea bpsong(pc),a0 
  move.l #$dff0a0,a3 
  moveq #3,d0 
  moveq #1,d7 
  lea bpcurrent(pc),a1 
bploop3: moveq #0,d1 
  move.w bpstep,d1 
  lsl.w #4,d1 
  move.l d0,d2 
  lsl.l #2,d2 
  add.l d2,d1 
  add.l #512,d1 
  move.w (a0,d1),d2 
  move.b 2(a0,d1),st 
  move.b 3(a0,d1),tr 
  subq.w #1,d2 
  mulu #48,d2 
  moveq #0,d3 
  move.w 30(a0),d3 
  lsl.w #4,d3 
  add.l d2,d3 
  move.l #$00000200,d4 
  move.b bppatcount,d4 
  add.l d3,d4 
  move.l d4,a2 
  add.l a0,a2 
  moveq #0,d3 
  move.b (a2),d3 
  tst.b d3 
  bne.s bpskip4 
  bra bpoptionals 
bpskip4: clr.w 12(a1)     ;Clear autoslide/autoarpeggio 
  move.b 1(a2),d4 
  and.b #15,d4 
  cmpi.b #10,d4      ;Option 10->transposes off 
  bne.s bp_do1 
  move.b 2(a2),d4 
  and.b #240,d4     ;Higher nibble=transpose 
  bne.s bp_not1 
bp_do1:  add.b tr,d3 
  ext.w d3 
bp_not1: move.b d3,10(a1)   ; Voor Arpeggio's 
  lea bpper(pc),a4 
  lsl.w #1,d3 
  move.w -2(a4,d3.w),(a1) 
  bset #15,(a1) 
  move.b #$ff,2(a1) 
  moveq #0,d3 
  move.b 1(a2),d3 
  lsr.b #4,d3 
  and.b #15,d3 
  tst.b d3 
  bne.s bpskip5 
  move.b 3(a1),d3 
bpskip5:  move.b 1(a2),d4 
  and.b #15,d4 
  cmpi.b #10,d4    ;option 10 
  bne.s bp_do2 
  move.b 2(a2),d4 
  and.b #15,d4 
  bne.s bp_not2 
bp_do2:  add.b st,d3 
bp_not2: cmpi.w #1,8(a1) 
  beq.s bpsamplechange 
  cmp.b 3(a1),d3 
  beq.s bpoptionals 
bpsamplechange: move.b d3,3(a1) 
  or.w d7,dma 
bpoptionals:  moveq #0,d3 
  moveq #0,d4 
  move.b 1(a2),d3 
  and.b #15,d3 
  move.b 2(a2),d4 
  cmpi.b #0,d3   ; Optionals Here 
  bne.s notopt0 
  move.b d4,11(a1) 
notopt0: cmpi.b #1,d3 
  bne.s bpskip3 
  move.w d4,8(a3) 
  move.b d4,2(a1)   ; Volume ook in BPCurrent 
bpskip3: cmpi.b #2,d3     ; Set Speed 
  bne.s bpskip9 
  move.b d4,bpcount 
  move.b d4,bpdelay 
bpskip9: cmpi.b #3,d3    ; Filter = LED control 
  bne.s bpskipa 
  tst.b d4 
  bne.s bpskipb 
  bset #1,$bfe001 
  bra.s bpskip2 
bpskipb: bclr #1,$bfe001 
bpskipa: cmpi.b #4,d3    ; PortUp 
  bne.s noportup 
  sub.w d4,(a1)    ; Slide data in BPCurrent 
  clr.b 11(a1)    ; Arpeggio's uit 
noportup: cmpi.b #5,d3    ; PortDown 
  bne.s noportdn 
  add.w d4,(a1)    ; Slide down 
  clr.b 11(a1) 
noportdn: cmpi.b #6,d3   ; SetRepCount 
  bne.s notopt6 
  move.b d4,bprepcount 
notopt6: cmpi.b #7,d3   ; DBRA repcount 
  bne.s notopt7 
  subq.b #1,bprepcount 
  beq.s notopt7 
  move.w d4,bpstep 
notopt7: cmpi.b #8,d3   ;Set AutoSlide 
  bne.s notopt8 
  move.b d4,12(a1) 
notopt8: cmpi.b #9,d3   ;Set AutoArpeggio 
  bne.s notopt9 
  move.b d4,13(a1) 
notopt9: 
bpskip2: lea $10(a3),a3 
  lea $20(a1),a1 
  asl.w #1,d7 
  dbra d0,bploop3 
  addq.b #3,bppatcount 
  cmpi.b #48,bppatcount 
  bne.s bpskip8 
  move.b #0,bppatcount 
  addq.w #1,bpstep 
  lea bpsong(pc),a0 
  move.w 30(a0),d1 
  cmp.w bpstep,d1 
  bne.s bpskip8 
  move.w #0,bpstep 
bpskip8: rts

bpplayit: bclr #15,(a2) 
  tst.l (a5)    ;Was EG used 
  beq.s noeg1    ;No ?? 
  moveq #0,d3    ;Well then copy 
  move.l (a5),a4    ;Old waveform back 
  moveq #7,d7    ;to waveform tables 
eg1loop: move.l 4(a5,d3.w),(a4)+  ;Copy... 
  addq.w #4,d3    ;Copy... 
  dbra d7,eg1loop   ;Copy... 
noeg1:  move.w (a2),6(a1)  ;Period from bpcurrent 
  moveq #0,d7 
  move.b 3(a2),d7   ;Instrument number 
  move.l d7,d6    ;Also in d6 
  lsl.l #5,d7    ;Header offset 
  lea bpsong(pc),a3 
  cmpi.b #$ff,(a3,d7.w)  ;Is synthetic 
  beq.s bpplaysynthetic  ;Yes ?? 
  clr.l (a5)    ;EG Off 
  clr.b $1a(a2)    ;Synthetic mode off 
  clr.w $1e(a2)    ;Lfo Off 
  add.l #24,d7    ;24 is name->ignore 
  lsl.l #2,d6    ;x4 for sample offset 
  move.l #samples,a4 
  move.l -4(a4,d6),d4  ;Fetch sample pointer 
  beq.s bp_nosamp   ;is zero->no sample 
  move.l d4,(a1)    ;Sample pointer in hardware 
  move.w (a3,d7),4(a1)  ;length in hardware 
  move.b 2(a2),9(a1)  ;and volume from bpcurrent 
  cmpi.b #$ff,2(a2)  ;Use default volume 
  bne.s skipxx    ;No ?? 
  move.w 6(a3,d7),8(a1)  ;Default volume in hardware 
skipxx:  move.w 4(a3,d7),8(a2)  ;Length in bpcurrent 
  moveq #0,d6 
  move.w 2(a3,d7),d6  ;Calculate repeat 
  add.l d6,d4 
  move.l d4,4(a2)   ;sample start in bpcurrent 
  cmpi.w #1,8(a2)   ;has sample repeat part 
  bne.s bpskip6    ;Yes ?? 
bp_nosamp: move.l #null,4(a2)  ;Play no sample 
  bra.s bpskip10 
bpskip6: move.w 8(a2),4(a1)  ;Length to hardware 
  move.l 4(a2),(a1)  ;pointer to hardware 
bpskip10: or.w #$8000,d1   ;Turn on DMA for this voice 
  move.w d1,$dff096  ;Yeah, do it 
  rts 
bpplaysynthetic:move.b #$1,$1a(a2)  ;Synthetic mode on 
  clr.w $e(a2)    ;EG Pointer restart 
  clr.w $10(a2)    ;LFO Pointer restart 
  clr.w $12(a2)    ;ADSR Pointer restart 
  move.w 22(a3,d7.w),$14(a2) ;EG Delay 
  addq.w #1,$14(a2)  ;0 is nodelay 
  move.w 14(a3,d7.w),$16(a2) ;LFO Delay 
  addq.w #1,$16(a2)  ;So I need correction 
  move.w #1,$18(a2)  ;ADSR Delay->Start immediate 
  move.b 17(a3,d7.w),$1d(a2) ;EG OOC 
  move.b 9(a3,d7.w),$1e(a2) ;LFO OOC 
  move.b 4(a3,d7.w),$1f(a2) ;ADSR OOC 
  move.b 19(a3,d7.w),$1c(a2) ;Current EG Value 
  move.l tables,a4  ; so far so good,now what ?? 
  moveq #0,d3   ;Pointer to waveform tables 
  move.b 1(a3,d7.w),d3  ;Which waveform 
  lsl.l #6,d3    ;x64 is length waveform table 
  add.l d3,a4 
  move.l a4,(a1)    ;Sample Pointer 
  move.l a4,4(a2)   ;In bpcurrent 
  move.w 2(a3,d7.w),4(a1)  ;Length in words 
  move.w 2(a3,d7.w),8(a2)  ;Length in bpcurrent 
  tst.b 4(a3,d7.w)  ;Is ADSR on 
  beq.s bpadsroff   ;No ?? 
  move.l tables,a4  ;Tables 
  moveq #0,d3 
  move.b 5(a3,d7.w),d3  ;ADSR table number 
  lsl.l #6,d3    ;x64 for length 
  add.l d3,a4    ;Add it 
  moveq #0,d3 
  move.b (a4),d3    ;Get table value 
  add.b #128,d3    ;I want it from 0..255 
  lsr.w #2,d3    ;Divide by 4->0..63 
  cmpi.b #$ff,2(a2) 
  bne.s bpskip99 
  move.b 25(a3,d7.w),2(a2) 
bpskip99: moveq #0,d4 
  move.b 2(a2),d4   ;Default volume 
  mulu d4,d3    ;default maal init volume 
  lsr.w #6,d3    ;divide by 64 
  move.w d3,8(a1)   ;is new volume 
  bra.s bpflipper 
bpadsroff: move.b 2(a2),9(a1) 
  cmpi.b #$ff,2(a2) 
  bne.s bpflipper   ;No ADSR 
  move.b 25(a3,d7.w),9(a1) ;So use default volume 
bpflipper: move.l 4(a2),a4   ;Pointer on waveform 
  move.l a4,(a5)    ;Save it 
  moveq #0,d3    ;Save Old waveform 
  moveq #7,d4    ;data in bpbuffer 
eg2loop: move.l (a4,d3.w),4(a5,d3.w) 
  addq.w #4,d3    ;Copy 
  dbra d4,eg2loop 
  tst.b 17(a3,d7.w)  ;EG off 
  beq bpskip10   ;Yes ?? 
  tst.b 19(a3,d7.w)  ;Is there an init value for EG 
  beq bpskip10   ;No ?? 
  moveq #0,d3 
  move.b 19(a3,d7.w),d3 
  lsr.l #3,d3    ;Divide by 8 ->0..31 
  move.b d3,$1c(a2)  ;Current EG Value 
  subq.l #1,d3    ;-1,DBRA correction 
eg3loop: neg.b (a4)+ 
  dbra d3,eg3loop 
  bra bpskip10 
bpplayarp: lea bpper(pc),a4 
  ext.w d4 
  asl.w #1,d4 
  move.w -2(a4,d4.w),6(a1) 
  rts 
bpsynth: move.l #3,d0 
  lea bpcurrent(pc),a2 
  lea $dff0a0,a1 
  lea bpsong(pc),a3 
  lea bpbuffer(pc),a5 
bpsynthloop: tst.b $1a(a2)    ;Is synthetic sound 
  beq.s bpnosynth   ;No ?? 
  bsr.s bpyessynth   ;Yes 
bpnosynth: lea $24(a5),a5 
  lea $20(a2),a2 
  lea $10(a1),a1 
  dbra d0,bpsynthloop 
  rts 
bpyessynth: moveq #0,d7 
  move.b 3(a2),d7   ;Which instr. was I playing 
  lsl.w #5,d7    ;x32, is length of instr. 
  tst.b $1f(a2)    ;ADSR off 
  beq.s bpendadsr   ;Yes ?? 
  subq.w #1,$18(a2)  ;Delay,May I 
  bne.s bpendadsr   ;No ?? 
  moveq #0,d3 
  move.b 8(a3,d7.w),d3 
  move.w d3,$18(a2)  ;Reset Delay Counter 
  move.l tables,a4 
  move.b 5(a3,d7.w),d3  ;Which ADSR table 
  lsl.l #6,d3    ;x64 
  add.l d3,a4    ;This is my table 
  move.w $12(a2),d3  ;Get ADSR table pointer 
  moveq #0,d4 
  move.b (a4,d3.w),d4  ;Value from table 
  add.b #128,d4    ;Want it from 0..255 
  lsr.w #2,d4    ;And now from 0..63 
  moveq #0,d3 
  move.b 2(a2),d3   ;Current Volume 
  mulu d3,d4    ;MultiPly with table volume 
  lsr.w #6,d4    ;Divide by 64=New volume 
  move.w d4,8(a1)   ;Volume in hardware 
  addq.w #1,$12(a2)  ;Increment of ADSR pointer 
  move.w 6(a3,d7.w),d4  ;Length of adsr table 
  cmp.w $12(a2),d4  ;End of table reached 
  bne.s bpendadsr   ;No ?? 
  clr.w $12(a2)    ;Clear ADSR Pointer 
  cmpi.b #1,$1f(a2)  ;Once 
  bne.s bpendadsr   ;No ?? 
  clr.b $1f(a2)    ;ADSR off 
bpendadsr: tst.b $1e(a2)    ;LFO On 
  beq.s bpendlfo   ;No ?? 
  subq.w #1,$16(a2)  ;LFO delay,May I 
  bne.s bpendlfo   ;No 
  moveq #0,d3 
  move.b 16(a3,d7.w),d3 
  move.w d3,$16(a2)  ;Set LFO Count 
  move.l tables,a4 
  move.b 10(a3,d7.w),d3  ;Which LFO table 
  lsl.l #6,d3    ;x64 
  add.l d3,a4 
  move.w $10(a2),d3  ;LFO pointer 
  moveq #0,d4 
  move.b (a4,d3.w),d4  ;That's my value 
  ext.w d4    ;Make it a word 
  ext.l d4    ;And a longword 
  moveq #0,d5 
  move.b 11(a3,d7.w),d5  ;LFO depth 
  tst.b d5 
  beq.s bpnotx 
  divs d5,d4    ;Calculate it 
bpnotx:  move.w (a2),d5    ;Period 
  add.w d4,d5    ;New Period 
  move.w d5,6(a1)   ;In hardware 
  addq.w #1,$10(a2)  ;Next position 
  move.w 12(a3,d7.w),d3  ;LFO table Length 
  cmp.w $10(a2),d3  ;End Reached 
  bne.s bpendlfo   ;NO ?? 
  clr.w $10(a2)    ;Reset LFO Pointer 
  cmpi.b #1,$1e(a2)  ;Once LFO 
  bne.s bpendlfo   ;NO ?? 
  clr.b $1e(a2)    ;LFO Off 
bpendlfo: tst.b $1d(a2)    ;EG On 
  beq bpendeg    ;No ?? 
  subq.w #1,$14(a2)  ;EG delay,May I 
  bne bpendeg    ;No 
  tst.l (a5) 
  beq.s bpendeg 
  moveq #0,d3 
  move.b 24(a3,d7.w),d3 
  move.w d3,$14(a2)  ;Set EG Count 
  move.l tables,a4 
  move.b 18(a3,d7.w),d3  ;Which EG table 
  lsl.l #6,d3    ;x64 
  add.l d3,a4 
  move.w $e(a2),d3  ;EG pointer 
  moveq #0,d4 
  move.b (a4,d3.w),d4  ;That's my value 
  move.l (a5),a4    ;Pointer to waveform 
  add.b #128,d4    ;0..255 
  lsr.l #3,d4    ;0..31 
  moveq #0,d3 
  move.b $1c(a2),d3  ;Old EG Value 
  move.b d4,$1c(a2) 
  add.l d3,a4    ;WaveForm Position 
  move.l a5,a6    ;Buffer 
  add.l d3,a6    ;Position 
  addq.l #4,a6    ;For adress in buffer 
  cmp.b d3,d4    ;Compare old with new value 
  beq.s bpnexteg   ;no change ?? 
  bgt bpishigh   ;new value is higher 
bpislow: sub.l d4,d3    ;oldvalue-newvalue 
  subq.l #1,d3    ;Correction for DBRA 
bpegloop1a: move.b -(a6),d4 
  move.b d4,-(a4) 
  dbra d3,bpegloop1a 
  bra.s bpnexteg 
bpishigh: sub.l d3,d4    ;Newvalue-oldvalue 
  subq.l #1,d4    ;Correction for DBRA 
bpegloop1b: move.b (a6)+,d3 
  neg.b d3 
  move.b d3,(a4)+   ;DoIt 
  dbra d4,bpegloop1b 
bpnexteg: addq.w #1,$e(a2)  ;Next position 
  move.w 20(a3,d7.w),d3  ;EG table Length 
  cmp.w $e(a2),d3   ;End Reached 
  bne.s bpendeg    ;NO ?? 
  clr.w $e(a2)    ;Reset EG Pointer 
  cmpi.b #1,$1d(a2)  ;Once EG 
  bne.s bpendeg    ;NO ?? 
  clr.b $1d(a2)    ;EG Off 
bpendeg: rts

null:  dc.w 0 
bpcurrent: dc.w 0,0   ;periode,instrument =(volume.b,instr nr.b) 
  dc.l null   ;start 
  dc.w 1    ;length (words) 
  dc.b 0,0,0,0    ;noot,arpeggio,autoslide,autoarpeggio 
  dc.w 0,0,0   ;EG,LFO,ADSR pointers 
  dc.w 0,0,0   ;EG,LFO,ADSR count 
  dc.b 0,0   ;Synthetic yes/no, Volume Slide 
  dc.b 0,0   ;Current EG value,EG OOC 
  dc.b 0,0   ;LFO OOC,ADSR OOC

  dc.w 0,0 
  dc.l null 
  dc.w 1,0,0 
  dc.w 0,0,0,0,0,0,0,0,0

  dc.w 0,0 
  dc.l null 
  dc.w 1,0,0 
  dc.w 0,0,0,0,0,0,0,0,0

  dc.w 0,0 
  dc.l null 
  dc.w 1,0,0 
  dc.w 0,0,0,0,0,0,0,0,0

bpstep:  dc.w 0 
bppatcount: dc.b 0 
st:  dc.b 0 
tr:  dc.b 0 
bpcount: dc.b 1 
bpdelay: dc.b 6 
arpcount: dc.b 1 
bprepcount: dc.b 1 
numtables: dc.b 0

  even

dma:  dc.w 0 
tables:  dc.l 0

bpbuffer: ds.b 144 
  dc.w 6848,6464,6080,5760,5440,5120,4832,4576,4320,4064,3840,3616 
  dc.w 3424,3232,3040,2880,2720,2560,2416,2288,2160,2032,1920,1808 
  dc.w 1712,1616,1520,1440,1360,1280,1208,1144,1080,1016,0960,0904

bpper:  dc.w 0856,0808,0760,0720,0680,0640,0604,0572,0540,0508,0480,0452 
  dc.w 0428,0404,0380,0360,0340,0320,0302,0286,0270,0254,0240,0226 
  dc.w 0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113 
  dc.w 0107,0101,0095,0090,0085,0080,0076,0072,0068,0064,0060,0057

samples: ds.l 15

bpsong: 
  incbin "spaceship505"

 EVEN

 bsr printgang

LogoPos: 
 dc.w 0

FixLogoPos: 
 lea LogoPos(pc),a0 
 moveq #0,d0 
 move.w (a0),d0 
 add.w #4,(a0) 
 cmp.w #$940,(a0) 
 ble NotThere 
 clr.w (a0) 
 bra.s FixLogoPos 
NotThere:

 divu #16,d0 
 move.w d0,d2 
 add.w d2,d2 
 swap d0 
 move.w #$f,d1 
 sub d0,d1 
 move.w d1,Delay+2

 move.l #plane,d0 
 add.w d2,d0 
 move.w d0,bpl+6 
 swap d0 
 move.w d0,bpl+2 
 move.l #plane1,d0 
 add.w d2,d0 
 move.w d0,bpl1+6 
 swap d0 
 move.w d0,bpl1+2 
 rts

PrintGang: 
 moveq #0,d4 
 lea gangtext,a0 
 move.w #4,d6

PrintGang2: 
 move.w #57,d7 
 moveq #0,d3 
PrintGang1: 
 cmp.b #'1',(a0)+ 
 bne.s GangNotSet 
 move.l d3,d1 
 move.l d4,d2 
 bsr.s blitta

GangNotSet: 
 add.l #1,d3 
 dbf d7,PrintGang1

 add.l #$2500,d4 
 dbf d6,PrintGang2 
 rts

hh: dc.w 0

VVanta: 
 btst #14,$dff002 
 bne.s Vvanta 
 rts

blitta: 
 bsr vvanta 
 jsr vblt 
 move.l #plane,d0 ;DESTINATION D

 add.l d1,d1 
 add.l d1,d1 
 add.l d1,d0 
 add.l d2,d0

 move.l #Ruta,$dff050 
 move.l d0,$dff054 
 move.w #292,$dff066     ;SATT MODULO D 
 move.w #0,$dff064     ;SATT MODULO A 
 move.w #32*64+2,$dff058   ;SATT STORLEK,STARTA BLT

 bsr.s vvanta

 move.l #plane1,d0 ;DESTINATION D

 add.l d1,d0 
 add.l d2,d0

 move.l #Ruta1,$dff050 
 move.l d0,$dff054 
 move.w #292,$dff066     ;SATT MODULO D 
 move.w #0,$dff064     ;SATT MODULO A 
 move.w #32*64+2,$dff058   ;SATT STORLEK,STARTA BLT 
 rts

Ruta: 
 dc.l %11111111111111111111111111111111 
 dc.l %11111111111111111111111111111110 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %11111111111111111111111111111100 
 dc.l %10000000000000000000000000000000 
 dc.l %00000000000000000000000000000000 
 

Ruta1: 
 dc.l %00000000000000000000000000000000 
 dc.l %00000000000000000000000000000001 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %00111111111111111111111111111111 
 dc.l %01111111111111111111111111111111 
 dc.l %11111111111111111111111111111111

GangText:  ;74 
; blk.b 10,'0' 
 dc.b '0000000001110111110011111000111100110011011110011110000000' 
 dc.b '0100000011110110011011001101100110111011001100110011000100' 
 dc.b '1110000110110110011011001101100110111111001100110000001110' 
 dc.b '0100001111110110011011001101100110110111001100110011000100' 
 dc.b '0000011000110111110011111000111100110011011110011110000000' 
 blk.b 6,'0' 
  
 

 EVEN 
 

Bild: blk.w 40*40,0

 blk.w 10000,0

Screen2: blk.w 180*42,0 ;bilderna dar sinusscrollen e 
Screen3: blk.w 180*42,0 ;i bojt format!  tva bilder e ett 
    ;tvang annars ser de for javligt ut! 
Plane1: blk.w 296*162,0 
 

Plane: blk.w 296*162,0

 EVEN

End: 
 
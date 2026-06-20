* 32.asm    TLgetfont and TLnewfont     version 0.01   8.6.99


 include 'Front.i'        ;*** change to 'Tandem.i' to step thru TL's ***


; This program introduces the selection of fonts. There are 5 subrountines
; for this. they use a table of fonts which is pointed to by xxp_FSuite.
; There can be 10 fonts, numbered 0-9, and each of these can have 4 forms,
; theoretically, 40 fonts in all. The window(s) can each have a font &
; font style attached. Or, they can have Topaz/8 attached, i.e. font 0,
; as they do initially.

; Font 0 is always Topaz/8. So, you can use fonts 1-9. If you use TLgetfont
; or TLaslfont on any font already opened, it will be closed, and any
; windows using it will revert to font 0, i.e. Topaz/8.

; Here are the subroutines:
;
; TLGetfont:  puts a predetermined fontname and height in an FSuite entry,
;             and closes anything already there. Does not open the font.
; TLAslfont:  as TLGetfont, but puts up a requester for the font.
; TLNewfont:  attaches an xxp_FSuite font & style to the xxp_ window.
; TLFsub:     closes an Fsuite font (called automatically by TLWclose)

; The commonest font styles are:
;   0 plain
;   1 bold
;   2 italic
;   3 bold+italic


strings: dc.b 0
st_1: dc.b 'Demonstrate TLGetfont and TLNewfont',0 ;1
st_2: dc.b 'Times.font',0 ;2
 dc.b 'This is in Font 0..',0 ;3
 dc.b 'But this is in Font 1!!',0 ;4
 dc.b 'Oh - back to Font 0. Life goes on.',0 ;5
 dc.b 'Perhaps it shouldn''t. So, click my close gadget.',0 ;6

 ds.w 0


* Demonstrate fonts
Program:
 TLwindow0
 beq.s Pr_quit
 bsr Test                  ;do test of Getfont,&c
Pr_quit:
 rts

* test Getfont, &c
Test:
 TLgetfont #st_2,#1,#24    ;name=Times.font, FSuite number=1, height=24
 TLstring #3,#10,#15       ;print string 3 at (10,15) in font 0 (Topaz/8)
 TLnewfont #1,#0,#0        ;attach font 1 (Times/24), style 0 (plain)
 beq Te_quit        ;go if bad (can only happen on 1st call of a font)

 TLstring #4,#10,#25       ;print string 4 at (10,25) in times/24 plain
 TLnewfont #0,#0,#0        ;back to font 0 for window
 TLstring #5,#10,#50       ;print string 5 at (10,50) in prefs font
 move.l xxp_AcWind(a4),a5  ;point a5 to active window (i.e. window 0)
 move.b #2,xxp_FrontPen(a5) ;use colour 2 for variety (default colour 1)
 move.w #4,xxp_Tspc(a5)    ;and spread out text spacing (default spacing 0)
 TLstring #6,#10,#60       ;print string 6 at (10,60) in prefs font

Te_wait:
 TLkeyboard                ;wait for response
 cmp.b #$93,d0             ;re-try if not close window
 bne Te_wait

Te_quit:
 rts                       ;note that Front0.i closes all fonts & windows


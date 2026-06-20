* 34.asm     Demonstrate TLaslfont, TLwupdate      version 0.01    8.6.99


 include 'Front.i'        ;*** change to 'Tandem.i' to step thru TL's ***


; tandem.library allows you to easily use Amiga's Gadtools library to make
; menus. You can also make several different types of requesters, which
; cover all the basic type of requesters needed for most applications.

; There are asl.library requesters for font and file selection, and 5
; other types, for a full and comprehensive range of user interaction.
; All these 5 types are font-sensitive, and have provision for built-in
; help. Subsequent teaching files will demonstrate the use of these
; requesters.

; I will first introduce the TLAslfont subroutine. It is the same as
; TLGetfont, but puts up a requester for you to choose the font and size.
; Note how easy tandem.library makes this.

; The TLbad MACRO shows a convenient way to send an error report to the
; user if things go wrong. First, it sends a message to the monitor with
; TLoutput. Then, it sets xxp_ackn<>0; this tells Front0.i to ask the user
; to press <return> to acknowledge before closing down in a CLI error
; condition.

; This program refreshes the window, by using redrawing whenever TLKeyboard
; returns a window resized IDCMP. This method works adequately for smart
; refresh windows. You need to put the drawing of the window into a
; subroutine, and use TLTrim (called by TLstring), not TLText. TLText is
; faster, but TLTrim checks that the text fits, so use it if there is any
; doubt. Note that since the act of resizing the window does not change
; the window layout (unlike 33.asm), it is not necessary to call TLreqcls
; before closing the window, but rather TLwupdate. This means a less
; flickery window update.


strings: dc.b 0
st_1: dc.b 'Demonstrate TLAslfont',0 ;1
 dc.b 'Here is some normal font',0 ;2
 dc.b 'This is in your selected font!',0 ;3
 dc.b '(Close window gadget to quit; other to recycle)',0 ;4
 dc.b 'Error: Text too large to fit in window',0 ;5
 dc.b 'Error: out of chip RAM:',0 ;6
 dc.b 'Use zoom gadget to demonstrate refreshing.',0 ;7

 ds.w 0


* program to test Aslfont
Program:
 TLwindow #0,#0,#0,#200,#50,#640,#200,#0,#st_1 ;open window 0
 beq.s Pr_quit             ;go if can't
 bsr Test                  ;do test of Aslfont
 rts            ;quit ok

Pr_quit:
 TLbad #6                  ;report error
 rts


* test TLAslfont
Test:
 TLreqcls                  ;clear window
 TLaslfont #1              ;select font 1
 bne.s Te_chosen           ;go if ok
 tst.l xxp_errn(a4)        ;EQ if cancel, else can't open requester
 beq Te_quit               ;quit without error if cancel selected

 TLbad #6                  ;else error condition (asl out of mem)
 rts

Te_chosen:
 bsr Refresh               ;print on window
 TLkeyboard                ;get response
 cmp.b #$96,d0
 beq Te_chosen             ;redraw if size window
 cmp.b #$93,d0             ;reccyle until close window (or cancel asl)
 bne Test

Te_quit:
 rts


* print everything on window (self contained, so can use as refresh)
Refresh:
 TLwupdate                 ;update window dims
 TLnewfont #0,#0,#0        ;attach topaz/8 plain to main window
 TLstring #2,#0,#0         ;print normal font
 TLnewfont #1,#0,#0        ;attach selected font - style plain, main window
 TLstring #3,#0,#12        ;print message in selected font
 TLtsize                   ;get message size
 add.l #12,d6              ;go to bot of text (text height + 12)
 TLnewfont #0,#0,#0        ;re=attach topaz/8 plain
 TLstring #4,#0,d6         ;message below string 3
 add.w #10,d6
 TLstring #7,#0,d6         ;further message below string 4
 rts

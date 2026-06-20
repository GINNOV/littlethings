* 25.asm      Open a screen       version 0.00   1.9.97

* this program illustrates the use of tags. Instead of passing a structure
* to OpenScreen, you pass tags for whatever you want. All possible tags
* that remain unpassed get default values. See under "Screens" in the
* ROM Kernal Manual. I chose to send the 5 tags below. I pushed the tags
* into the stack, and then discarded them after opening the screen.

* For tag details, see the autodoc for intuition.library _LVOOpenScreen

 include 'Front.i'         ;*** Change to Tandem.i to step thru TL's ***

strings: dc.b 0
st_1: dc.b 'My screen!  (please wait a couple of seconds)',0       ;1
 ds.w 0

pens: dc.l -1              ;default pens structure

Program:
 sub.l #6*8+4,a7           ;room for 6 tags (8 bytes per tag + 4 at end)
 move.l a7,a0
 move.l #SA_Width,(a0)+    ; 1st tag: width=same as display clip
 move.l #STDSCREENWIDTH,(a0)+
 move.l #SA_Height,(a0)+   ; 2nd tag: height=same as display clip
 move.l #STDSCREENHEIGHT,(a0)+
 move.l #SA_Depth,(a0)+    ; 3rd tag: depth=2 (depth 2 = 4 colours)
 move.l #2,(a0)+
 move.l #SA_Pens,(a0)+     ; 4th tag: pass SA_Pens to get 3D look
 move.l #pens,(a0)+
 move.l #SA_Title,(a0)+    ; 5th tag: send title
 move.l #st_1,(a0)+
 move.l #SA_DisplayID,(a0)+ ; 6th tag: display (hires)
 move.l #HIRES_KEY,(a0)+
 move.l #TAG_DONE,(a0)     ;delimit tag list
 move.l xxp_intb(a4),a6
 sub.l a0,a0               ;a0 is null, since no NewScreen structure
 move.l a7,a1              ;a1 points to taglist
 jsr _LVOOpenScreenTagList(a6) ;open screen
 add.l #6*8+4,a7           ;discard tag list, restore stack
 tst.l d0
 beq.s Pr_bad              ;go if couldn't open screen
 move.l d0,-(a7)           ;save screen pointer (for later closing)
 move.l xxp_dosb(a4),a6
 move.l #200,d1
 jsr _LVODelay(a6)         ;wait about 4 seconds (=200 intuiticks)
 move.l (a7)+,a0           ;a0=screen (for closing)
 move.l xxp_intb(a4),a6
 jsr _LVOCloseScreen(a6)   ;close screen
 rts                       ;& return good
Pr_bad:
 sub.l a0,a0
 jsr _LVODisplayBeep(a6)   ;if bad, beep existing screens
 rts                       ;& return bad

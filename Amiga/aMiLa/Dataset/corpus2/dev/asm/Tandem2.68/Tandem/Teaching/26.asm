* 26.asm      Open a window          version 0.00    1.9.97

; This program does what Teaching/20.asm did, and then opens a window.
; it also sets up an IDCMP port (see the IDCMP section under intuition
; i/o methods in the ROM Kernal manual). The only IDCMP message
; receivable is the close gadget, so the program waits until you click
; the close gadget, and then closes the window & screen, and exits.

; Notice that you can resize and move the window, of which your program is
; oblivious, before you click the close gadget. If your program needed to
; know that the window is moved and/or resized, you could arrange to get
; IDCMP messages for that.

; For tag details, see the autodoc for OpenWindow

; You will see later that there is a simpler way to open a window using
; Front.i; so this program is simply for instructional purposes. Note the
; way putting OpenScreen & OpenWindow in subroutines makes the logic of
; Program easier to follow.

 include 'Front.i'        ;*** save to Tandem.i if stepping thru TL's ***

strings: dc.b 0
st_1: dc.b 'My screen',0   ;1
st_2: dc.b 'My window (click the close gadget)',0   ;2
 ds.w 0

screen: ds.l 1             ;screen opened by Screen
window: ds.l 1             ;window opened by Window

pens: dc.l -1              ;default pens structure

* open screen & window; close & exit when close gadget clicked
Program:
 bsr OpenScreen            ;open a screen
 beq.s Pr_bad              ;bad if couldn't
 bsr OpenWindow            ;open a window on the screen
 beq.s Pr_close            ;bad if couldn't (unlikely)
 move.l window,a2
 move.l wd_UserPort(a2),a0 ;point to the port for IDCMP messages
 move.l xxp_sysb(a4),a6
 jsr _LVOWaitPort(a6)      ;wait for an IDCMP message to appear
 move.l wd_UserPort(a2),a0
 jsr _LVOGetMsg(a6)        ;get the message
 move.l d0,a1
 jsr _LVOReplyMsg(a6)      ;reply without inspection - must be close window
 move.l xxp_intb(a4),a6    ;closewindow gadget clicked, so close window
 move.l window,a0
 jsr _LVOCloseWindow(a6)   ;(this deletes any un-got messages)
Pr_close:
 move.l xxp_intb(a4),a6    ;close the screen (no windows must be open)
 move.l screen,a0
 jsr _LVOCloseScreen(a6)
 rts                       ;& return ok
Pr_bad:
 move.l xxp_intb(a4),a6
 sub.l a0,a0
 jsr _LVODisplayBeep(a6)   ;if bad, beep existing screens
 rts                       ;& return bad

* open a screen
OpenScreen:
 sub.l #6*8+4,a7           ;room for 6 tags (8 bytes per tag + 4 at end)
 move.l a7,a0
 move.l #SA_Width,(a0)+    ; 1st tag: width=640
 move.l #STDSCREENWIDTH,(a0)+
 move.l #SA_Height,(a0)+   ; 2nd tag: height=200/256
 move.l #STDSCREENHEIGHT,(a0)+
 move.l #SA_Depth,(a0)+    ; 3rd tag: depth=2
 move.l #2,(a0)+
 move.l #SA_Pens,(a0)+     ; 4th tag: pass SA_Pens to get new look
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
 move.l d0,screen
 rts                       ;EQ if bad

* open a window on the screen already opened
OpenWindow:
 sub.l #10*8+4,a7          ;room for 10 tags
 move.l a7,a0
 move.l #WA_Left,(a0)+     ; 1st tag: left posn
 move.l #100,(a0)+
 move.l #WA_Top,(a0)+      ; 2nd tag: top posn
 move.l #30,(a0)+
 move.l #WA_Width,(a0)+    ; 3rd tag: width
 move.l #400,(a0)+
 move.l #WA_Height,(a0)+   ; 4th tag: height
 move.l #150,(a0)+
 move.l #WA_Flags,(a0)+    ; 5th tag: flags (system gadgets)
1$: equ WFLG_CLOSEGADGET!WFLG_SIZEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
 move.l #1$,(a0)+
 move.l #WA_IDCMP,(a0)+    ; 6th tag: IDCMP (only signal if window closes)
 move.l #IDCMP_CLOSEWINDOW,(a0)+
 move.l #WA_Title,(a0)+    ; 7th tag: widow title
 move.l #st_2,(a0)+
 move.l #WA_CustomScreen,(a0)+ ; 8th flag: screen pointer
 move.l screen,(a0)+
 move.l #WA_MinWidth,(a0)+ ; 9th flag: minimum width
 move.l #200,(a0)+
 move.l #WA_MinHeight,(a0)+ ; 10th flag: minimum height
 move.l #20,(a0)+
 move.l #TAG_DONE,(a0)     ;delimit tag list
 move.l xxp_intb(a4),a6
 sub.l a0,a0               ;no NewWindow structure
 move.l a7,a1              ;point to taglist
 jsr _LVOOpenWindowTagList(a6) ;open window
 add.l #10*8+4,a7          ;discard flags, restore stack
 move.l d0,window          ;remember window structure address
 rts                       ;EQ if bad, NE if good

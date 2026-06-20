* 65.asm  TLtabs     version 0.01     8.6.97


 include 'Front.i'


; ***** Important notes about this Program *****

; TLtabs is used to draw a set of thumbtab cards on a window, and monitor
; them. tandem.library has several sets of routines like this:

; - TLtabs,TLtabmon    - for a set of thumbtab cards
; - TLslider,TLslimon  - for a slider
; - TLscroll           - for a window scroller
; - TLbutprt,TLbutmon  - for a set of buttons

; Unlike tandem.library requesters, which take over everything and use their
; own window, the above are rendered on a window with other things, and
; share the window. You can of course use gadtools.library gadgets, which
; are sophisticated, as each gadget sends its own special IDCMP messages to
; you. But tandem.library requires you to monitor each TLkeyboard you get,
; to see if the input is from any of the above.

; Follow the logic of the program below to see how you do this. You first
; set up a set of tab cards, & decide what you will do in each. You can of
; course have all sorts of other things on the window. Basically, the user
; is expected to click things to activate them, so what your program must
; do, is see what gets clicked, and activate it for the user, until
; something else gets clicked.

; The program below sets up a set of 4 tab cards, which do various things.
; You will see how to go from card to card under user control (by clicking
; thumb tabs), or under program control. You will see how to edit strings on
; a tab card, how to use buttons, &c.

; You will see that this program uses a set of 12 tiny grafix which you can
; show with TLpict - these are useful for all sorts of things, but they
; are inflexible in that TLpict doesn't allow you to specify the pens used
; to draw them. The grafix allow rounded corners on a bevelled box, arrows
; pointing in 4 directions, a checkmark and a tiny tandem.library logo.

; I didn't make this program font-sensitive, or it would have been too long
; and messy to take in easily.


wdth: EQU 160               ;tabcard minimum body width (20 chrs)
hght: EQU 120               ;tabcard body height
xpos: EQU 20                ;tabcard xpos
ypos: EQU 10                ;tabcard ypos


;data for tabs
tab: ds.w 1                 ;currently operative tab

;tab1 data
rec: ds.w 1                 ;-1recessed,0normal
t1ps: ds.w 2                ;bev box posn

;tab2 data
name: ds.b 20               ;name as entered


strings: dc.b 0
st_1: dc.b 'TLTabs demonstration',0 ;1
 dc.b 'Abc\Defg\Hij\Klmn',0 ;2
 dc.b 'I am Tab card Abc!',0 ;3
 dc.b 'I am Tab card Defg!',0 ;4
 dc.b 'I am Tab card Hij!',0 ;5
 dc.b 'I am Tab card Klmn!',0 ;6
 dc.b 'TLpict icons 0-B...',0 ;7
 dc.b '0 1 2 3 4 5 6 7',0 ;8
 dc.b '8 9 A B C D E F',0 ;9
 dc.b 'Click the box',0 ;10
 dc.b 'for a shriek',0 ;11
 dc.b 'for a query',0 ;12
 dc.b '!',0 ;13
 dc.b '?',0 ;14
 dc.b 'Enter your name...',0 ;15
 dc.b 'Name',0 ;16
 dc.b 'Quit',0 ;17
 dc.b 'Art!',0 ;18
 dc.b 'Go to Tabcard Abc',0 ;19

 ds.w 0


* demonstrate TLtabs
Program:
 TLwindow #0,#0,#0,#380,#120,#640,#256,#-1,#st_1 ;open window 0
 beq Pr_quit

 clr.w rec                 ;initialise data
 clr.b name

 TLtabs #2,#wdth,#hght     ;set up tabs:  heders in string 2, body 160X120

Pr_draw:
 TLtabs #0,#1,#xpos,#ypos  ;draw with tab1 active

 move.l xxp_AcWind(a4),a5  ;a5 is currently popped window       } used by
 moveq #xpos+4,d6          ;d6 is lhs of printable area of body } T1render
 moveq #ypos+1,d7                                               }
 add.l xxp_tblh(a4),d7     ;d7 is top of printable area of body }

 bsr T1render              ;draw tab1

Pr_wait:
 TLkeyboard                ;get keyboard

Pr_pick:
 TLwupdate
 cmp.b #$1B,d0             ;quit if Esc
 beq Pr_quit
 cmp.b #$93,d0             ;quit if Close window
 beq Pr_quit

*******                    ;note: we would monitor for other things on the
*******                    ;window here, if there were other things on it.
*******                    ;If yes, process them, & go to Pr_wait.

 move.l xxp_AcWind(a4),a5  ;a5 is currently popped window
 moveq #xpos+4,d6          ;d6 is lhs of printable area of body
 moveq #ypos+1,d7
 add.l xxp_tblh(a4),d7     ;d7 is top of printable area of body

 move.l d0,d4              ;save d0
 cmp.b #$80,d0             ;only call TLtabmon if left mouse button
 bne.s Pr_cont             ;else go monitor whichever tabcard at front

 TLtabmon d1,d2,#xpos,#ypos ;see if thumbtabs clicked
 beq.s Pr_cont             ;no, go monitor whichever tabcard at front

 move.w d0,tab             ;yes, note which tab is now operative
 cmpi.w #2,d0              ;go draw whichever thumbtab clicked
 bcs Pr_t1dr
 beq Pr_t2dr
 cmpi.w #4,d0
 bcs Pr_t3dr
 bra Pr_t4dr

Pr_cont:
 move.l d4,d0              ;restore d0 from TLkeboard
 sub.w xxp_LeftEdge(a5),d1 ;make lmb relative to window printable area
 sub.w xxp_TopEdge(a5),d2

 cmpi.w #2,tab             ;branch to whichever tab
 bcs Pr_tab1               ;(each test if the TLKeyboard is relevent to it)
 beq Pr_tab2               ;(if so, they act upon it, else discard it)
 cmpi.w #4,tab
 bcs Pr_tab3
 bra Pr_tab4

Pr_t1dr:                   ;draw tab1
 bsr T1render
 bra Pr_wait

Pr_t2dr:                   ;draw tab2
 bsr T2render
 bra Pr_wait

Pr_t3dr:                   ;draw tab3
 bsr T3render
 bra Pr_wait

Pr_t4dr:                   ;draw tab4
 bsr T4render
 bra Pr_wait


Pr_tab1:                   ;monitor tab1
 bsr T1monitor
 bra Pr_wait

Pr_tab2:                   ;monitor tab2
 clr.l xxp_kybd(a4)        ;clear in case Reqedit ends with click
 bsr T2monitor             ;do the monitoring
 tst.l xxp_kybd(a4)        ;was there a click?
 beq Pr_wait               ;no, wait for one
 bra.s Pr_ccyc             ;yes, get it as an input

Pr_tab3:                   ;monitor tab3 (sets EQ if quit requested)
 bsr T3monitor
 beq Pr_quit               ;go if quit requested
 bra Pr_wait

Pr_tab4:                   ;monitor tab4
 bsr T4monitor
 bra Pr_wait

Pr_ccyc:                   ;process a keyboard input inherited from
 move.l xxp_kybd(a4),d0    ;    monitoring a page
 move.l xxp_kybd+4(a4),d1
 move.l xxp_kybd+8(a4),d2
 cmp.b #$1B,d0             ;(don't quit from here if Esc)
 bne Pr_pick
 clr.b d0
 bra Pr_pick

Pr_done:                   ;clear tabs area & quit (Esc or close window)
 TLtabs #0,#0,#xpos,#ypos

Pr_quit:
 rts


* render tab1
T1render:
 TLreqarea d6,d7,#wdth,#hght,#3 ;clear display area in case re-calling

 move.l xxp_AcWind(a4),a5  ;print title
 move.w #$0203,xxp_FrontPen(a5)
 TLstring #3,d6,d7
 subq.b #1,xxp_FrontPen(a5)

 move.l d7,d2              ;print string 10
 add.w #20,d2
 move.l d6,d1
 TLstring #10,d1,d2

 tst.w rec                 ;go if recessed
 bmi .t1rc

 addq.w #8,d2              ;'for a shriek...'
 TLstring #11,d1,d2
 subq.w #4,d2
 add.w #108,d1
 TLpict #6,d1,d2
 add.w #26,d1
 TLstring #14,d1,d2
 subq.w #6,d2
 sub.w #12,d1
 TLreqbev d1,d2,#36,#20
 bra .t1cu

.t1rc:                     ;print 'for a query..'
 addq.w #8,d2
 TLstring #12,d1,d2
 subq.w #4,d2
 add.w #108,d1
 TLpict #6,d1,d2
 add.w #26,d1
 TLstring #13,d1,d2
 subq.w #6,d2
 sub.w #12,d1
 TLreqbev d1,d2,#36,#20,rec

.t1cu:
 move.w d1,t1ps            ;remember where the reqbev was (for T1monitor)
 move.w d2,t1ps+2

 TLstring #7,#24,#88       ;show TLPict samples
 TLstring #8,#24,#96
 TLpict #0,#24,#108
 TLpict #1,#40,#108
 TLpict #2,#56,#108
 TLpict #3,#72,#108
 TLpict #4,#88,#108
 TLpict #5,#104,#108
 TLpict #6,#120,#108
 TLpict #7,#136,#108
 TLstring #9,#24,#120
 TLpict #8,#24,#132
 TLpict #9,#40,#132
 TLpict #10,#56,#132
 TLpict #11,#72,#132
 TLpict #12,#88,#132
 TLpict #13,#104,#132
 TLpict #14,#120,#132
 TLpict #15,#136,#132
 rts


* render tab2
T2render:
 move.l xxp_AcWind(a4),a5  ;print title
 move.w #$0203,xxp_FrontPen(a5)
 TLstring #4,d6,d7
 subq.b #1,xxp_FrontPen(a5)

 TLstring #15,#24,#60      ;print instructions, bev
 TLstring #16,#24,#72
 TLreqbev #68,#71,#100,#10

 sub.w #20,a7              ;print name (so far)
 move.l a7,a0
 move.l #xxp_xtext,(a0)+
 move.l #name,(a0)+
 move.l #xxp_xcrsr,(a0)+
 move.l #-1,(a0)+
 clr.l (a0)
 TLreqedit #72,#72,a7
 add.w #20,a7
 rts


* render tab3
T3render:
 move.l xxp_AcWind(a4),a5  ;print title
 move.w #$0203,xxp_FrontPen(a5)
 TLstring #5,d6,d7
 subq.b #1,xxp_FrontPen(a5)

 TLstring #17,#40,#40      ;quit button
 TLreqbev #38,#39,#34,#10

 TLreqarea #74,#75,#60,#30,#0 ;draw a picture
 TLreqbev #74,#75,#60,#30
 TLreqarea #82,#79,#44,#22,#3
 TLreqbev #82,#79,#44,#22
 TLpict #0,#82,#79
 TLpict #3,#118,#79
 TLpict #4,#82,#93
 TLpict #5,#118,#93
 TLpict #11,#100,#86
 TLpict #8,#100,#107
 TLstring #18,#88,#116
 rts


* render tab4
T4render:
 move.l xxp_AcWind(a4),a5  ;print title
 move.w #$0203,xxp_FrontPen(a5)
 TLstring #6,d6,d7
 subq.b #1,xxp_FrontPen(a5)

 TLstring #19,#36,#70
 TLreqbev #34,#69,#142,#10
 rts


* monitor tab1
T1monitor:
 cmp.b #$80,d0             ;quit unless lmb
 bne.s T1_quit

 sub.w t1ps,d1             ;quit unless in bev
 bcs.s T1_quit
 sub.w t1ps+2,d2
 bcs.s T1_quit
 cmp.w #36,d1
 bcc.s T1_quit
 cmp.w #20,d2
 bcc.s T1_quit

 move.w rec,d0             ;flip-flop rec
 eori.w #-1,d0
 move.w d0,rec
 bsr T1render

T1_quit:
 rts


* monitor tab2:
T2monitor:
 cmp.b #$80,d0             ;quit unless lmb
 bne.s T2_quit

 sub.w #72,d1              ;quit unless clicked in box
 bcs.s T2_quit
 sub.w #72,d2
 bcs.s T2_quit
 cmp.w #96,d1
 bcc.s T2_quit
 cmp.w #8,d2
 bcc.s T2_quit

 sub.w #20,a7              ;edit name
 move.l a7,a0
 move.l #xxp_xtext,(a0)+
 move.l #name,(a0)+
 move.l #xxp_xmaxc,(a0)+
 move.l #12,(a0)+
 clr.l (a0)+
 TLreqedit #72,#72,a7
 add.w #20,a7

 move.l xxp_FWork(a4),a0   ;tfr name as edited to name
 lea name,a1
T2_tfr:
 move.b (a0)+,(a1)+
 bne T2_tfr

T2_quit:
 rts


* monitor tab3:
T3monitor:
 cmp.b #$80,d0             ;don't quit unless lmb
 bne.s T3_unqt

 sub.w #38,d1              ;don't quit if clicked outside quit button
 bcs.s T3_unqt
 cmp.w #34,d1
 bcc.s T3_unqt
 sub.w #39,d2
 bcs.s T3_unqt
 cmp.w #10,d2
 bcc.s T3_unqt

T3_quit:                   ;exit here to quit
 moveq #0,d0
 rts

T3_unqt:                   ;exit here NOT to quit
 moveq #-1,d0
 rts


* monitor tab4:
T4monitor:
 cmp.w #$80,d0             ;go unless lmb click
 bne.s T4_quit

 sub.w #34,d1              ;go unless button clicked
 bcs.s T4_quit
 cmp.w #134,d1
 bcc.s T4_quit
 sub.w #69,d2
 bcs.s T4_quit
 cmp.w #10,d2
 bcc.s T4_quit

 move.w #1,tab            ;note tab1 in front
 TLtabs #0,#1,#20,#10     ;bring tab1's thumbtab forward
 bsr T1render             ;render tab1 body (needed data still in A5,D6,D7)

T4_quit:
 rts

* 67.asm     TLbutmon        0.00        8.6.99)


 include 'Front.i'


;box size & contents data
xwid: ds.l 1                ;width of 2nd box set
radi: ds.l 1                ;which button of 1st box set selected
prev: ds.w 1                ;previous box clicked (ASCII of set,box)


strings: dc.b 0
st_1: dc.b  'TLbutmon demonstration',0 ;1
 dc.b 'Error: out of chip ram',0 ;2
 dc.b 'A box\Another\Yet another\Yes! Another\The Last non-blank box',0 ;3
 dc.b 'Click me!',0 ;4
 dc.b 'No - click me!',0 ;5
 dc.b 'Or, click me',0 ;6
 dc.b 'Click any box from either set of buttons',0 ;7
 dc.b '(Click the close window gadget to quit)',0 ;8
 dc.b 'Set 1 - radio buttons',0 ;9
 dc.b 'Set 2 - some boxes with text',0 ;10
 dc.b 'Your last click was set '
st_11a: dc.b ' , box '
st_11b: dc.b ' ',0 ;11

 ds.w 0


Program:
 TLwindow #-1
 beq Pr_bad
 TLwindow #0,#0,#0,#200,#100,xxp_Width(a4),xxp_Height(a4),#0,#st_1
 beq Pr_bad

 clr.w prev                ;no input yet

Pr_draw:                   ;draw the window contents
 TLreqcls                  ;clear window, update window size

 move.l xxp_AcWind(a4),a5  ;print instructions
 move.w #$0200,xxp_FrontPen(a5)
 TLstring #7,#10,#5
 TLstring #8,#10,#13
 subq.b #1,xxp_FrontPen(a5)

 TLstring #9,#10,#43       ;print 1st set
 TLstring #4,#30,#54
 TLstring #5,#30,#69
 TLstring #5,#30,#84
 move.l #10,xxp_butx(a4)   ;posn = 10,53
 move.l #53,xxp_buty(a4)
 move.l #12,xxp_butw(a4)   ;size = 12 X 10
 move.l #10,xxp_buth(a4)
 move.l #15,xxp_btdy(a4)   ;dy = 15   (no dx since butk=1)
 move.l #1,xxp_butk(a4)    ;columns = 1
 move.l #3,xxp_butl(a4)    ;rows = 3
 TLbutprt                  ;print buttons

 TLstring #10,#10,#106     ;print 2nd set
 move.l #116,xxp_buty(a4)
 TLstra0 #3                ;point to button contents
 TLbutstr a0               ;set butx,buty for them
 move.l xxp_butw(a4),xwid  ;cache button width
 move.l xxp_butw(a4),xxp_btdx(a4) ;buttons touch horz & vert
 move.l xxp_buth(a4),xxp_btdy(a4)
 move.l #3,xxp_butk(a4)    ;columns = 3
 move.l #2,xxp_butl(a4)    ;rows = 2
 TLbuttxt a0               ;print text in them
 TLbutprt                  ;print buttons

Pr_chek:
 move.l radi,d2            ;print checkmark
 mulu #15,d2
 add.w #54,d2              ;ypos = radi * btdy + 54
 TLpict #10,#12,d2         ;pict 10 at 12,d2

Pr_prev:
 tst.w prev                ;go if not input yet
 beq.s Pr_wait
 move.b prev,st_11a        ;else, show last input
 move.b prev+1,st_11b
 TLstring #11,#10,#150

Pr_wait:                   ; wait for user response
 TLwcheck
 bne Pr_draw               ;redraw if window resized
 TLkeyboard                ;get input
 cmp.b #$93,d0
 beq Pr_quit               ;quit if close window
 cmp.b #$80,d0
 bne Pr_wait               ;else reject unless lmb

 move.l #10,xxp_butx(a4)   ;set up to monitor 1st button set
 move.l #53,xxp_buty(a4)
 move.l #12,xxp_butw(a4)
 move.l #10,xxp_buth(a4)
 move.l #15,xxp_btdy(a4)
 move.l #1,xxp_butk(a4)
 move.l #3,xxp_butl(a4)

 TLbutmon d1,d2            ;was 1st set clicked?
 beq.s Pr_set2             ;no, to second set
 move.b #'1',prev
 move.b #'0',prev+1        ;record lst keyboard input
 add.b d0,prev+1

 move.l radi,d1            ;d1 = old checkmark
 subq.l #1,d0              ;d0 = new chweckmark, 0-2
 move.l d0,radi            ;which save in radi
 mulu #15,d1
 add.w #54,d1
 TLreqarea #12,d1,#8,#8,#0 ;clear old checkmark
 bra Pr_chek               ;print new checkmark, to next input

Pr_set2:                   ;set up to monitor 2nd button set
 move.l #116,xxp_buty(a4)
 move.l xwid,xxp_butw(a4)
 move.l xxp_butw(a4),xxp_btdx(a4)
 move.l #10,xxp_buth(a4)
 move.l #10,xxp_btdy(a4)
 move.l #3,xxp_butk(a4)
 move.l #2,xxp_butl(a4)

 TLbutmon d1,d2            ;monitor 2nd button set
 beq Pr_wait               ;go if neither set
 move.b #'2',prev          ;else record which clicked
 move.b #'0',prev+1
 add.b d0,prev+1
 bra Pr_prev               ;& await next input

Pr_bad:                    ;report out of mem if bad
 TLbad #2

Pr_quit:                   ;exit from Program
 rts

* 72.asm     TLdropdown    version 0.00    8.9.99


 include 'Front.i'


; The program draws & monitors a drop down menu. If you wanted it to be
; a cycle gadet, you'd put 'cycle' for \8, like this:
;
; To draw:
;
;     TLdropdown draw,#4,#6,mood,#20,#25,,cycle  ;draw
;
; To monitor;
;
;     TLdropdown monitor,#4,#6,mood,#20,#25,,cycle   ;monitor


mood: ds.l 1              ;holds the operative mood (1+)


strings: dc.b 0
st_1: dc.b 'TLdropdown demo',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'Choose a mood, or click the window close gadget',0 ;3
 dc.b 'Happiness is',0 ;4
 dc.b 'Sadness is',0 ;5
 dc.b 'Boredom is',0 ;6
 dc.b 'Fascination is',0 ;7
 dc.b 'Fear is',0 ;8
 dc.b 'Relief is',0 ;9
 dc.b 'Someone gets JAVA working on Amiga',0 ;10
 dc.b 'People are buying PCs             ',0 ;11
 dc.b 'Downloading a newsgroup           ',0 ;12
 dc.b 'The Amiga workbench               ',0 ;13
 dc.b 'Programming a printer driver      ',0 ;14
 dc.b 'I didn''t crash                    ',0 ;15
 dc.b '(I should reappear when the drop down disappears)',0 ;16

 ds.w 0


* demonstrate TLdoprdown
Program:
 TLwindow #0,#0,#0,#200,#40,#640,#200,#0,#st_1
 beq Pr_bad

Pr_resize:                 ;here if window resized
 TLreqcls                  ;clear window
 TLstring #3,#20,#10       ;print instructions
 TLstring #16,#20,#58      ;writing underneath
 move.l #1,mood            ;initialise mood

 TLdropdown draw,#4,#6,mood,#20,#25    ;draw with initial mood

Pr_report:                 ;report mood so far
 moveq #9,d0
 add.l mood,d0
 TLstring d0,#154,#26

Pr_wait:                   ;wait for user response
 TLwcheck                  ;go if window resized
 bne Pr_resize
 TLkeyboard                ;get input
 cmp.b #$93,d0
 beq Pr_quit               ;quit if close window
 cmp.b #$1B,d0
 beq Pr_quit               ;quit if Esc
 cmp.b #$80,d0
 bne Pr_wait               ;else ignore unless lmb

 move.l d1,xxp_kybd+4(a4)
 move.l d2,xxp_kybd+8(a4)
 TLdropdown monitor,#4,#6,mood,#20,#25,,#5  ;monitor dropdown
 beq Pr_wait

 move.l d0,mood            ;set new mood
 bra Pr_report             ;report response, wait for next

Pr_bad:
 TLbad #2

Pr_quit:
 rts

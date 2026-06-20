* 73.asm     Demonstrate TLreqedit   version 0.01    8.6.99
*            Modified to allow TLputilbm of text


 include 'Front.i'


; TLreqedit is a comlex and powerful routine. It allows you to format
; individual characters & whole lines in many different ways. Although
; this program is long, that is because of programming the various buttons
; in the demo. TLreqedit is itself easy to use.


;text & styl data
text: ds.b 100             ;text
styl: ds.b 100             ;styl

jam1: ds.l 1               ;-1 if jam1
case: ds.l 1               ;<> if case
styb: ds.l 1               ;<> if styb
fixt: ds.l 1               ;<> if fixt
cspc: ds.l 1               ;cspc
maxj: ds.l 1               ;maxj
wdth: ds.l 1               ;text wdth (600, or 500 if shrt)
ltyp: ds.l 1               ;justification
revs: ds.l 1               ;<> if reversed
crsr: ds.l 1               ;cursor

;strings
strings: dc.b 0
 dc.b 'Demonstrate TLreqedit',0 ;1
 dc.b 'Font Jam1 Case Styb Fixt Cspc Maxj Shrt Save',0 ;2
 dc.b 'Line formatting, editing',0 ;3
 dc.b 'Font Style',0 ;4
 dc.b 'Bold   Ctrl/B',0 ;5
 dc.b 'Italic Ctrl/I',0 ;6
 dc.b 'Wide   Ctrl/W',0 ;7
 dc.b 'Shadow Ctrl/S',0 ;8
 dc.b 'Superscript  Ctrl/Up arrow',0 ;9
 dc.b 'Subscript    Ctrl/Dn arrow',0 ;10
 dc.b 'Under/Overlining',0 ;11
 dc.b 'Single Under Ctrl/U',0 ;12
 dc.b 'Over         Ctrl/E',0 ;13
 dc.b 'Under+Over   Ctrl/F',0 ;14
 dc.b 'Double Under Ctrl/G',0 ;15
 dc.b 'Dbl Under+Over  Ctrl/H',0 ;16
 dc.b 'Dotted Under Ctrl/O',0 ;17
 dc.b 'Strike Through  Ctrl/V',0 ;18
 dc.b 'Justification',0 ;19
 dc.b 'Right Justify  Ctrl/R',0 ;20
 dc.b 'Full Justify   Ctrl/J',0 ;21
 dc.b 'Center         Ctrl/C',0 ;22
 dc.b 'Left Justify   Ctrl/L',0 ;23
 dc.b 'Complement  Shift/Ctrl/C',0 ;24
 dc.b 'Erase (x-out)  Ctrl/X',0 ;25
 dc.b 'Undo        Shift/Ctrl/U',0 ;26
 dc.b 'Restore     Shift/Ctrl/R',0 ;27
 dc.b 'Space fill  Shift/Ctrl/S',0 ;28
 dc.b 'Force Fixed    Ctrl/P',0 ;29
 dc.b 'Specify inter-chr spaces (0-31, normally 0)',0 ;30
 dc.b 'Draw Mode (Jam1 is demo only - not usually used if text editable)',0
 dc.b 'Jam1  (normally for text display only)',0 ;32
 dc.b 'Jam2  (for text display &/or text editing)',0 ;33
 dc.b 'Fixed/Proportional',0 ;34
 dc.b 'Force a proportional font to be shown fixed',0 ;35
 dc.b 'Show font proportional/fixed as it normally is',0 ;36
 dc.b 'Max full justify cspace (0-15 normally 5)(0 to force)',0 ;37
 dc.b 'Show initial "AaBb" in chr style...',0 ;38
 dc.b 'Unchanged - i.e. as "AaBb"',0 ;39
 dc.b 'All upper case',0 ;40
 dc.b 'All lower case',0 ;41
 dc.b 'Small caps (works best for largish fonts)',0 ;42
 dc.b 'Press <Help> for assistance!!!',0 ;43
 dc.b 'Notes concerning this demo...',0 ;44
 dc.b 0 ;45
 dc.b '1. Click "Shrt" to make the demo make a short line, without',0
 dc.b '   sideways scrolling, so you see better the effect of line',0 ;47
 dc.b '   justification. Click it again so you can go back to',0
 dc.b '   sideways scrolling.',0 ;49
 dc.b 0 ;50
 dc.b '2. If you choose "Jam1" the view mucks up when you type - this is',0
 dc.b '   not a bug - jam1 is suitable for display only, but not typing.',0
 dc.b '   The same applies also with case, which mucks up as soon as you',0
 dc.b '   type. Have something showing before you choose either.',0 ;54
 dc.b 0 ;55
 dc.b '3. "Save" saves the tablet as an IFF file in RAM:Temp.iff',0 ;56
 dc.b ' ',0 ;57
 dc.b ' ',0 ;58
 dc.b ' ',0 ;59
 dc.b 'Style byte for text (e.g. 01=bold 02=italic)(0=none) 00-FF',0 ;60
 dc.b 'RAM:Temp.iff',0 ;61 ;filename to save as IFF

 ds.w 0


ment:
 TLnm 1,3      ;Line formatting, editing
 TLnm 2,4    ;  Font Style
 TLnm 3,5    ;    Bold        Ctrl/b
 TLnm 3,6    ;    Italic      Ctrl/i
 TLnm 3,7    ;    Wide        Ctrl/w
 TLnm 3,8    ;    Shadow      Ctrl/s
 TLnm 3,9    ;    Superscript Ctrl/up
 TLnm 3,10    ;    Subscript   Ctrl/down
 TLnm 2,11    ;  Under/Overlining
 TLnm 3,12    ;    Single Under   Ctrl/u
 TLnm 3,13    ;    Over           Ctrl/e
 TLnm 3,14    ;    Under+Over     Ctrl/f
 TLnm 3,15    ;    Double Under   Ctrl/g
 TLnm 3,16    ;    Dbl Under+Over Ctrl/h
 TLnm 3,17    ;    Dotted Under   Ctrl/o
 TLnm 3,18    ;    Strike Through
 TLnm 2,19    ;  Justification
 TLnm 3,20    ;    Right Justify Ctrl/r
 TLnm 3,21    ;    Full Justify  Ctrl/j
 TLnm 3,22    ;    Center        Ctrl/c
 TLnm 3,23    ;    Left Justify  Ctrl/l
 TLnm 3,29    ;    Force Fixed   Ctrl/p
 TLnm 2,24    ;  Complement
 TLnm 2,25    ;  Erase (x-out)  Ctrl/x
 TLnm 2,26    ;  Undo           Shift/Ctrl/u
 TLnm 2,27    ;  Restore        Shift/Ctrl/r
 TLnm 2,28    ;  Space fill     Shift/Ctrl/s
 TLnm 4,0      ;(End)


;demonstrate TLReqedit
Program:
 TLwindow #-1
 TLwindow #0,#0,#0,#640,xxp_Height(a4),#640,xxp_Height(a4),#0,#strings+1
 beq Pr_bad
 TLreqinfo #44,#16         ;preliminary info

 TLreqmenu #ment           ;init menu
 beq Pr_bad
 TLreqmuset

 clr.l jam1                ;init line format data
 clr.l case
 clr.l styb
 clr.l fixt
 clr.l cspc
 clr.l ltyp
 move.l #5,maxj
 move.l #600,wdth
 clr.l revs
 clr.l crsr

 lea text,a0               ;init text
 clr.b (a0)

 tst.l case
 bne.s Pr_some
 tst.l jam1
 beq.s Pr_none
Pr_some:
 move.l #'AaBb',(a0)       ;some init if case or jam1
 clr.b 4(a0)
Pr_none:

 clr.l styl
 clr.b styl+4

Pr_font:                   ;choose a font
 TLaslfont #1
 beq Pr_bad

Pr_edit:                   ;(re-)edit the text
 TLreqcls
 TLnewfont #0,#0,#0
 TLstring #2,#10,#5
 moveq #6,d0
 moveq #8,d1
Pr_boxes:
 TLreqbev d0,#4,#40,#10
 add.w #40,d0
 dbra d1,Pr_boxes

 move.l xxp_AcWind(a4),a5  ;advise to ask for help
 move.w #$0200,xxp_FrontPen(a5)
 TLstring #43,#382,#5
 subq.b #1,xxp_FrontPen(a5)

 TLnewfont #1,#0,#0
 bne.s Pr_cont

Pr_badf:
 move.l #10,xxp_errn(a4)
 bra Pr_bad

Pr_cont:
 move.l xxp_AcWind(a4),a5
 move.w #$0100,xxp_FrontPen(a5)

 move.l xxp_FSuite(a4),a0  ;set d7 = font ysize
 add.w #xxp_fsiz,a0
 move.l xxp_plain(a0),a1
 moveq #0,d7
 move.w tf_YSize(a1),d7

 addq.w #2,d7              ;box around tablet
 TLreqarea #6,#19,#504,d7,#2
 TLreqbev #6,#19,#504,d7,box,,#3

 sub.w #140,a7             ;room for 17 tags
 move.l a7,a0
 move.l #xxp_xtext,(a0)+   ;tag 1:  text address
 move.l #text,(a0)+
 tst.l styb                ;(no styl address if styb)
 bne.s Pr_tag3
 move.l #xxp_xstyl,(a0)+   ;tag 2:  styl address
 move.l #styl,(a0)+
Pr_tag3:
 move.l #xxp_xmaxt,(a0)+   ;tag 3:  tablet width
 move.l #500,(a0)+
 move.l #xxp_xmaxw,(a0)+   ;tag 4:  max line width
 move.l wdth,(a0)+
 move.l #xxp_xmaxc,(a0)+   ;tag 5:  max chrs
 move.l #80,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 6:  crsr
 move.l crsr,(a0)+
 move.l #xxp_xmenu,(a0)+   ;tag 7:  use menu 0
 move.l #0,(a0)+
 move.l #xxp_xforb,(a0)+   ;tag 8:  forbids - none
 clr.l (a0)+
 move.l #xxp_xjam1,(a0)+   ;tag 9:  jam1
 move.l jam1,(a0)+
 move.l #xxp_xcase,(a0)+   ;tag 10: case
 move.l case,(a0)+
 move.l #xxp_xstyb,(a0)+   ;tag 11: styb
 move.l styb,(a0)+
 move.l #xxp_xffix,(a0)+   ;tag 12: fixt
 move.l fixt,(a0)+
 move.l #xxp_xcspc,(a0)+   ;tag 13: cspc
 move.l cspc,(a0)+
 move.l #xxp_xmaxj,(a0)+   ;tag 14: maxj
 move.l maxj,(a0)+
 move.l #xxp_xfgbg,(a0)+   ;tag 15: pens
 move.l #$00000100,(a0)+
 move.l #xxp_xltyp,(a0)+   ;tag 16: ltyp
 move.l ltyp,(a0)+
 move.l #xxp_xrevs,(a0)+   ;tag 17: revs
 move.w revs,d0
 ext.l d0
 move.l d0,(a0)+
 clr.l (a0)                ;delimit tags
 move.l a7,a0
 TLreqedit #8,#20,a0       ;do the edit
 add.w #140,a7

 move.l xxp_FWork(a4),a0   ;save the results
 move.l a0,a1
 add.w #256,a1
 lea text,a2
 clr.b 99(a0)              ;(max 99 chrs to be safe - can't be >80?)
 lea styl,a3
Save:
 move.b (a1)+,(a3)+
 move.b (a0)+,(a2)+
 bne Save

 move.b xxp_chnd+2(a4),d4  ;get final ltyp
 and.b #3,d4
 move.b d4,ltyp+3
 move.l xxp_crsr(a4),crsr  ;get final crsr

 cmp.w #5,d0               ;go if click off tablet
 beq.s Pr_clik
 cmp.w #1,d0               ;quit if Esc
 beq Pr_quit
 cmp.w #13,d0              ;quit if close window
 beq Pr_quit
 cmp.w #8,d0               ;recycle if 0-7
 bcs Pr_edit
 cmp.w #12,d0              ;recycle if 12+
 bcc Pr_edit
 bra Pr_badf               ;else, bad (only can't attach font possible)

Pr_clik:
 move.l xxp_AcWind(a4),a5
 move.l xxp_kybd+4(a4),d0
 sub.w xxp_LeftEdge(a5),d0
 bcs Pr_edit
 move.l xxp_kybd+8(a4),d1
 sub.w xxp_TopEdge(a5),d1
 bcs Pr_edit
 sub.w #6,d0
 bcs Pr_edit
 divu #40,d0               ;d0 = 0-8 if box clicked
 cmp.w #9,d0
 bcc Pr_edit
 cmp.w #4,d1
 bcs Pr_edit
 cmp.w #15,d1
 bcc Pr_edit
 cmp.w #1,d0
 bcs Pr_font               ;go to whichever box clicked
 beq Pr_jam1
 cmp.w #3,d0
 bcs Pr_case
 beq Pr_styb
 cmp.w #5,d0
 bcs Pr_fixt
 beq Pr_cspc
 cmp.w #7,d0
 bcs Pr_maxj
 beq Pr_shrt
 cmp.w #9,d0
 bcs Pr_revs
 bra Pr_edit

Pr_jam1:                   ;get jam1 (0/-1)
 clr.l jam1
 TLreqchoose #31,#2
 cmp.w #1,d0
 bne Pr_edit
 subq.l #1,jam1
 bra Pr_edit

Pr_case:                   ;get case (0-3)
 TLreqchoose #38,#4
 subq.l #1,d0
 bcs Pr_edit
 move.l d0,case
 bra Pr_edit

Pr_styb:                   ;get styb (0,1-255)
 clr.b (a4)
 TLreqinput #60,hex,#2
 beq Pr_edit
 move.b d0,styb+3
 bra Pr_edit

Pr_fixt:                   ;get fixt (0/-1)
 clr.l fixt
 TLreqchoose #34,#2
 cmp.w #1,d0
 bne Pr_edit
 subq.l #1,fixt
 bra Pr_edit

Pr_cspc:                   ;get cspc (0-31)
 clr.b (a4)
 TLreqinput #30,num,#2
 beq Pr_edit
 cmp.w #32,d0
 bcc Pr_cspc
 move.l d0,cspc
 bra Pr_edit

Pr_maxj:                   ;get maxj (0-15)
 clr.b (a4)
 TLreqinput #37,num,#2
 beq Pr_edit
 cmp.w #16,d0
 bcc Pr_maxj
 move.l d0,maxj
 bra Pr_edit

Pr_shrt:
 tst.l revs               ;(forbid choosing long if revs)
 bmi Pr_edit
 move.l wdth,d0
 move.l #500,wdth
 cmp.l #600,d0
 beq Pr_edit
 move.l #600,wdth
 bra Pr_edit

Pr_revs:                   ;quick & dirty dump of tablet to RAM:Temp.iff

;###########

 moveq #6,d4               ;set d4,d5 = posn of tablet on screen
 moveq #19,d5
 move.l xxp_AcWind(a4),a5  ;add offset of window interior
 add.w xxp_LeftEdge(a5),d4
 add.w xxp_TopEdge(a5),d5
 move.l xxp_Window(a5),a0
 add.w wd_LeftEdge(a0),d4  ;add screen offset of window
 add.w wd_TopEdge(a0),d5

 move.l xxp_FSuite(a4),a0  ;set d7 = font ysize
 add.w #xxp_fsiz,a0
 move.l xxp_plain(a0),a1
 moveq #0,d7
 move.w tf_YSize(a1),d7

 addq.w #2,d7              ;box around tablet = 6,19,504,d7

 TLstrbuf #61              ;filename to buffer
 move.l xxp_Screen(a4),a1  ;a1 = the workbench screen
 move.l sc_RastPort+rp_BitMap(a1),a0 ;a0 = the workbench screen's bitmap
 TLputilbm d4,d5,#504,d7,a0  ;save the tablet as RAM:Temp.iff

;###########

 bra Pr_edit

Pr_bad:                    ;here to report error
 TLerror
 TLreqchoose

Pr_quit:
 rts

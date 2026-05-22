* 38.asm     TLreqmenu       version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; This program is designed to demonstrate the use of TLreqmenu.
; To use TLreqmenu, you must first create a NewMenu structure, and then
; call TLreqmenu. This creates a value in xxp_Menu which can then be
; used by TLreqmuset to attach the menu strip to a window, or TLreqmuclr
; to detach it. While the menu strip is attached, if the user makes a menu
; selection, it will be returned by the next TLkeyboard, with the value
; $95 in D0; the menu num, item num and sub-item num will be in D1-D3.
; If any of these are null, they will be -1 (n.b. separator bars count
; as items, but cannot be selected).

; When you set up the NewMenu, you can if you like put string numbers in
; Label fields, which TLreqmenu will convert to pointers. You may also use
; one only string with some/all of the hotkey characters in it in order.
; Then, put that string number in the CommKey field, and Reqmenu will
; convert it to a pointer. (Although TLnm's change their contents when run,
; they can safely be rerun, or be part of a PURE program).

; the newmenu memory area below (an instance of a NewMenu structure) uses
; the TLnm MACRO.  TLnm requires \1 to be 1,2,3 or 4 for NM_TITLE,
; NM_ITEM, NM_SUB or NM_END. \2 is the string number of the label.
; \3 (if present) is the string number of the CommKeys string. If \2
; is -1, it is an NM_BARLABEL. (You can also use pointers instead of
; string numbers for \2 and \3 if you want). Refer also to
; libraries/gadtools.i for details of Amiga's NewMenu structure. \4 and
; \5 (if present) are explained in tandem.i's AUTODOC for TLnm.


* The NewMenu structure (the \2 and \3 values refer to string numbers)
newmenu:
 TLnm 1,3      ;Menu 0
 TLnm 2,4,13   ;  Item 0         A
 TLnm 2,5      ;  Item 0
 TLnm 3,6,13   ;    Sub-item 0   B
 TLnm 3,7      ;    Sub-item 1
 TLnm 2,8      ;  Item 2
 TLnm 2,-1     ;  (bar)
 TLnm 2,9      ;  Item 3
 TLnm 1,10     ;Menu 1
 TLnm 2,11,13  ;  Item 0         C
 TLnm 2,12     ;  Item 1
 TLnm 4,0      ;delimiter


strings: dc.b 0
st_1: dc.b 'Test TLReqmenu',0 ;1
 dc.b 'You chose menu '
st_2a: dc.b ' , item '
st_2b: dc.b ' , sub-item '
st_2c: dc.b ' .',0            ;2
 dc.b 'Menu 0',0              ;3
 dc.b 'Item 0',0              ;4 CommKey A
 dc.b 'Item 1',0              ;5
 dc.b 'Sub-item 0',0          ;6 CommKey B
 dc.b 'Sub-item 1',0          ;7
 dc.b 'Item 2',0              ;8
 dc.b 'Item 4 (bar=3)',0      ;9
 dc.b 'Menu 1',0              ;10
 dc.b 'Item 0',0              ;11 CommKey C
 dc.b 'Item 1',0              ;12
 dc.b 'ABC',0                 ;13 (the CommKeys)
 dc.b '(Choose a menu item, or click close gadget)',0           ;14
 dc.b 'Error: can''t open screen/window. Out of chip memory',0  ;15
 dc.b 'Error: the gadtools.library could not set up the menu',0 ;16

 ds.w 0


* program to demonstrate  TLreqmenu
Program:
 TLwindow #0,#0,#0,#300,#120,#640,#256,#0,#st_1
 beq.s Pr_quit             ;go if can't
 bsr Test                  ;do test of Reqmenu
 rts

Pr_quit:
 TLbad #15
 rts


* test Reqmenu
Test:
 TLreqmenu #newmenu        ;set up xxp_Menu
 beq Te_bad                ;bad if can't
 TLreqmuset                ;attach menu to window
 TLstring #14,#20,#19      ;ask user to select an item

Te_wait:
 TLkeyboard                ;get response
 cmp.w #$93,d0
 beq.s Te_quit             ;done if close gadget
 cmp.w #$95,d0
 bne Te_wait               ;else, keep waiting until menu item selected
 add.b #'0',d1
 move.b d1,st_2a           ;report menu number ('0' if null)
 add.b #'0',d2
 move.b d2,st_2b           ;report item number ('0' if null)
 add.b #'0',d3
 move.b d3,st_2c           ;report sub-item no ('0' if null)
 TLstring #2,#20,#40       ;report choice, and continue
 bra Te_wait

Te_quit:
 rts

Te_bad:
 TLbad #16                 ;error condition if can't create menu
 rts

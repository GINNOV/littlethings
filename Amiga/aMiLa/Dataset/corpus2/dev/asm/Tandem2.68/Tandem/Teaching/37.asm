* 37.asm     TLaslfile          version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; TLaslfile puts up a requester to allow the user to choose a filepath
; for loading or saving. The demonstration below does not actually go on
; to open the file; so it is just for demonstration purposes. The filepath
; will be relative to the CD when TLAslfile runs. To use the MACRO
; TLaslfile, you:
;
;  point \1 to a DS.B to hold the directory part of the filepath
;  point \2 to a DS.B to hold the file part of the filepath
;  set \3 to the string number of the hail
;  set \4 to ld or sv   (if you omit \4, ld is assumed)
;
; the \1 and \2 should be of length 128 and 32 to be safe. You can make
; them null strings, or give them initial values to act as prompts.
; The Asl requester updates the \1 and \2 buffer to contain the path you
; choose, and TLasfile puts the total path (relative to the CD) in xxp_buff,
; ready for you to call TLOpenread or TLOpenwrite.


strings: dc.b 0
st_1: dc.b 'Test TLAslfile',0 ;1
 dc.b 'This is an TLAslfile requester',0 ;2
 dc.b 'You chose cancel',0 ;3
 dc.b 'Error: Can''t open  window - out of chip memory',0 ;4

 ds.w 0


dir: ds.b 128
fil: ds.b 32


* program to demonstrate TLaslfile
Program:
 TLwindow0                 ;open window
 beq.s Pr_quit             ;go if can't
 bsr Test                  ;do test of Aslfile
 TLwclose                  ;close window & screen
 rts                       ;return ok

Pr_quit:
 TLbad #4                  ;return bad if out of chip memory
 rts

* test Reqinput
Test:
 clr.b dir                 ;directory here (null prompt)
 clr.b fil                 ;file here (null prompt)
 TLaslfile #dir,#fil,#2,ld
 bne.s Te_good
 TLstrbuf #3               ;if cancel, report in buffer, else send path

Te_good:
 TLreqchoose               ;report choice
 rts

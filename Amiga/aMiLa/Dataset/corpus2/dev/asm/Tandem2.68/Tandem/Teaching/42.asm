* 42.asm     Demonstrate TLassdev       version 0.00      1.9.97


 INCLUDE 'Front.i'

; This test if an assign exists, without putting up an annoying
; system requester if it doesn't. If it does exist, it tells you
; what it is (primarily) assigned to.


strings: dc.b 0
 dc.b 'LIBS',0 ;1   (note - do NOT put trailing :)
 dc.b 'EH?? LIBS: Doesn''t exist?? Impossible!!',0 ;2
 dc.b $0C,'LIBS: is assigned to:',0 ;3
 dc.b $0A,'(Press <return> to acknowledge)',0 ;4

 ds.w 0


* demonstrate TLAssdev
Program:
 TLoutstr #3     ;string 3 to CLI
 TLstrbuf #1     ;'LIBS' to buffer
 TLassdev        ;get its assign
 bne.s Pr_report ;go if ok
 TLstrbuf #2     ;else, report string 2 (can't happen?)

Pr_report:
 TLoutput        ;put assign
 TLoutstr #4     ;send string 4
 TLinput         ;get acknowledge
 rts

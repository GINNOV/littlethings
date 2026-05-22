* 24.asm    Program to demonstrate tandem.library    version 0.00  1.9.97

 include 'Front.i'        ;*** change to Tandem.i to step thru TL's ***

; If you were assembling a program for actual use, you would assemble
; it with Front.i, not Tandem.i. To step through Tandem.i routines:
; 1. when you come to  jsr TLxxx(a6), place a breakpoint at TLxxx
; 2. then press run. This will stop at your breakpoint.
; 3. step through the TLxxx to see how it works.
; 4. the TLxxx will finally rts back to the mcline after the jsr in step 1
; 5. But, if you simply single step any jsr, tandem will step right
;    through it in 1 step (hence the need for steps 1-4 to step through it)

; The program below conducts a conversation through the CLI window. If you
; were to run it through the workbench, Front.i would open a CLI-like
; monitor window, so the program would work just the same. The program
; uses MACRO calls. The program shows how you can use TL routines to do some
; basic tasks, and illustrates a primitive user interface via the CLI
; window.

* message strings
strings: dc.b 0
 dc.b $0C,'Hello, CLI window',0 ;1
 dc.b 'RAM:Temp',0 ;2
 dc.b 'Out of memory: no public memory',0 ;3
 dc.b 'Out of memory: no chip memory',0 ;4
 dc.b 'Everything worked ok',0 ;5
 dc.b 'Input an unsigned integer (less than 2 billion)',0 ;6
 dc.b '(All done: Press <Return> to acknowledge)',0 ;7
 dc.b 'Read/Write error',0 ;8
 dc.b 'You input:',0 ;9
 dc.b '10,000 bytes of public mem created OK.',0 ;10
 dc.b 'Now, I''ll save string 12 to RAM:Temp, The MACROs are:',0 ;11
 dc.b 'This is string 12 (34 bytes long)',0 ;12
 dc.b '  TLstrbuf #2        (tfr string 2, i.e. ''RAM:Temp'', to buff)',0
 dc.b '  TLopenwrite        (open RAM:Temp)',0 ;14
 dc.b '  TLstra0 #12        (point a0 to string 12)',0 ;15
 dc.b '  TLwritefile a0,#34 (write 34 bytes [= len of string 12] to file)',0
 dc.b '  TLclosefile        (close file)',0 ;17
 dc.b 'Now, I''ll read RAM:Temp back in back again. The MACROs are:',0 ;18
 dc.b '  TLstrbuf #2        (tfr string 2, i.e. ''RAM:Temp'', to buff)',0
 dc.b '  TLopenread         (open RAM:Temp)',0 ;20
 dc.b '  TLreadfile a4,#76  (read up to 76 bytes to buff)',0 ;21
 dc.b '  TLclosefile        (close file)',0 ;22
 dc.b '  TLoutput           (send string 12 to CLI)',0 ;23
 dc.b 'Now, I''ll get a message from you. The MACROs are:',0 ;24
 dc.b '  TLoutstr #6        (prompt)',0 ;25
 dc.b '  TLinput            (get input from user)',0 ;26
 dc.b '  TLaschex a4        (get hex of number in buff to d0)',0 ;27
 dc.b '  move.l d0,-(a7)    (save d0)',0 ;28
 dc.b '  TLoutstr #9        (send string 9)',0 ;29
 dc.b '  TLhexasc (a7)+,a4  (convert input back to ascii in buff)',0 ;30
 dc.b '  clr.b (a0)         (delimit number)',0 ;31
 dc.b '  TLoutput           (echo number back to CLI window)',0 ;32
 dc.b '(Press <Return> to acknowledge)',$0A,0 ;33
 dc.b '10,000 bytes of chip mem created OK.',0 ;34
 dc.b 'RAM:Temp read & printed - string 12 s/be above this line.',0 ;35
 dc.b 0 ;36
 dc.b 'Now, I''ll issue the MACRO:   TLpublic 10000',0 ;37
 dc.b 'Now, I''ll issue the MACRO:   TLchip 10000',0 ;38
 dc.b 'RAM:Temp now created.',0 ;39

 ds.w 0

* memory pointers
pubmem: ds.l 1             ;pointer to 10000 bytes of public memory here
chipmem: ds.l 1            ;pointer to 10000 bytes of chip memory here

* program entry point - called by Front0.i with A4 pointing to xxp_tndm
Program:

 TLoutstr #1               ;* greetings
 TLoutstr #36

 TLoutstr #37              ;* will create 10000 publilc
 TLpublic #10000           ;create 10000 bytes of public mem
 move.l d0,pubmem          ;remember where
 beq Pr_bad1               ;go if out of public mem
 TLoutstr #10              ;success
 TLoutstr #36

 TLoutstr #38              ;* success, will create 10000 chip
 TLchip #10000             ;create 10000 bytes of chip mem   } Front.i
 move.l d0,chipmem         ;remember where                   } does so
 beq Pr_bad2               ;go if out of chip mem            } automaitcally
 TLoutstr #34              ;success
 TLoutstr #36

 TLoutstr #33              ;* wait for acknowledge
 TLinput

 TLoutstr #11              ;* will create RAM:Temp
 TLoutstr #13
 TLoutstr #14
 TLoutstr #15
 TLoutstr #16
 TLoutstr #17
 TLstrbuf #2               ;tfr 'RAM:Temp' to buff
 TLopenwrite               ;open RAM:Temp for writing
 beq Pr_bad3               ;go if can't
 TLstra0 #12               ;point a0 to string 12
 TLwritefile a0,#34        ;write 33 bytes (= len of string 12)
 beq Pr_bad3               ;go if can't (TLwritefile closes file if bad)
 TLclosefile               ;close the file.  RAM:Temp now exists
 TLoutstr #39              ;success
 TLoutstr #36

 TLoutstr #18              ;* will read RAM:Temp
 TLoutstr #19
 TLoutstr #20
 TLoutstr #21
 TLoutstr #22
 TLoutstr #23
 TLstrbuf #2               ;tfr 'RAM:Temp' to buff
 TLopenread                ;open RAM:Temp for reading
 beq Pr_bad3               ;go if can't
 TLreadfile a4,#76         ;read it back into buff (should read 33 bytes)
 beq Pr_bad3               ;go if can't (TLreadfile closes file if bad))
 TLclosefile               ;close the file; string 12 s/be at start of buff
 TLoutput                  ;send string 12 (as saved and read) to CLI window
 TLoutstr #35              ;success
 TLoutstr #36

 TLoutstr #33              ;* wait for acknowledge
 TLinput

 TLoutstr #24              ;* will get input
 TLoutstr #25
 TLoutstr #26
 TLoutstr #27
 TLoutstr #28
 TLoutstr #29
 TLoutstr #30
 TLoutstr #31
 TLoutstr #32
 TLoutstr #33
 TLoutstr #6               ;send string 6 to CLI window
 TLinput                   ;get user response

 TLaschex a4               ;get hex of number in buff to d0
 move.l d0,-(a7)           ;save d0
 TLoutstr #9               ;send string 9
 move.l (a7)+,d0           ;get num that was input
 TLhexasc d0,a4            ;convert d0 back to ascii in buff
 clr.b (a0)                ;delimit number (TLHexasc points A0 past)
 TLoutput                  ;echo number back to CLI window
 bra.s Pr_good             ;go wrap up

Pr_bad1:
 moveq #3,d0               ;error message - string 3
 bra.s Pr_quit

Pr_bad2:
 moveq #4,d0               ;error message - string 4
 bra.s Pr_quit

Pr_bad3:
 moveq #8,d0               ;error message - string 8
 bra.s Pr_quit

Pr_good:
 moveq #5,d0               ;ok message - string 5

Pr_quit:
 TLoutstr d0               ;send closing message
 TLoutstr #7               ;ask for acknowledge
 TLinput                   ;wait for closing message
 rts                       ;back to Front.i to close down

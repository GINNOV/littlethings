* 31.asm     Demonstrate TLerror       Version 0.00   1.9.97


 include 'Front.i'        ;*** change to 'Tandem.i to step thru TL's ***


; Most tandem.library routines can return with an error condition. Their
; MACRO's will generally return EQ if in error. Your program can find the
; specifics of the error in xxp_errn(a4). Programs which can return an
; error leave xxp_errn(a4)=0 if ok, else they return an error number. If
; you call TLerror while xxp_errn(a4)<>0, then it will put an error report
; in (a4) (where you can put it up on a requester for acknowledgement), and
; TLerror also sends the error report to the monitor. If there is a DOS
; error, TLerror also sends that to the monitor.

; The prgram below does everything on the monitor (CLI), rather than using
; intuition windows.


strings: dc.b 0
 dc.b $0C,'Demonstrate TLerror',0 ;1
 dc.b 'First, I will try to "Makedir PRT:Fred", which is illegal',0 ;2
 dc.b 'After that failed, I called TLError, which puts this in buffer:',0 ;3
 dc.b '(Press <return> to acknowledge)',0 ;4
st_5: dc.b 'Makedir >NIL: PRT:Fred',0 ;5     <- an illegal DOS command
st_6: dc.b 'List >NIL: RAM:',0 ;6     <- a legal DOS command
 dc.b 'Now, I''ll send a (hopefully) legal command:  "List >NIL: RAM:"',0 ;7
 dc.b 'Here is what TLerror reports (i.e. nothing since legal)',0 ;8
 dc.b 0 ;9

 ds.w 0


* sample program
Program:
 TLoutstr #1               ;greetings
 TLoutstr #9

 TLoutstr #2               ;send string 2
 TLoutstr #4
 TLinput

 TLoutstr #3               ;string 3 first (else TLerror reports on this)

 move.l xxp_dosb(a4),a6    ;set up to execute st_5 (=string 5) as a command
 move.l #st_5,d1
 moveq #0,d2
 moveq #0,d3
 jsr _LVOExecute(a6)       ;send an illegal command, to cause an error

 TLerror                   ;get error report to buff

 TLoutstr #9
 TLoutstr #4
 TLinput

 TLoutstr #9
 TLoutstr #7               ;now send strings 7 and 8
 TLoutstr #8
 move.l #st_6,d1           ;now send a legal command (at st_6, string 6)
 moveq #0,d2               ;(if you re-run this, it will be illegal, since
 moveq #0,d3               ; RAM:Fred will already exist)
 jsr _LVOExecute(a6)

 TLerror                   ;get error report to buff

 TLoutstr #9
 TLoutstr #4               ;send to op window
 TLinput                   ;wait for acknowledge
 rts

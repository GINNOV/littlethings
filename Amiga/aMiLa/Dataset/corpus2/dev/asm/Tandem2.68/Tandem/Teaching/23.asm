* 23.asm      Introduce Tandem's standard frontend    version 0.00   1.9.97


* This program simply puts a message on Tandem's CLI window. When you
* run this program, you will see the message appear (after running, press
* Left Amiga/M to switch screens so you can see Tandem's CLI window)


* If you step this program through, you will see it first sets up a 1024
* byte block in the stack, with A4 pointing to it. It then opens libraries,
* and a few other bits & pieces, and finally calls 'Program'; in order for
* the front end to work, you need to make the entry point of your program
* a subroutine called 'Program', and also a list of 0 or more null delimited
* strings labelled 'strings' (as below). The frontend opens the commonest
* libraries, and tandem.library, and then closes them after calling Program,
* so you can thus forget the nuisance of opening & closing the commonest
* libraries. tandem.library calls do all sorts of other things, and there
* are MACROs in incall.i for easy calling of tandem.library routines.


 include 'Front.i'         ;opens libraries etc and BSR's Program

* text strings
strings: dc.b 0            ;Front.i requires this line
 dc.b 'Hello, world',0     ;string 1
 ds.w 0                    ;re-align mc

* print a hello message
Program:                   ;Entry point is Program, A4 points to xxp_tndm
 move.l xxp_tanb(a4),a6    ;get tanbase
 moveq #1,d0
 jsr _LVOTLStrbuf(a6)      ;tfr string 1 to xxp_buff
 jsr _LVOTLOutput(a6)      ;ouput xxp_buff to output window
 rts                       ;quit

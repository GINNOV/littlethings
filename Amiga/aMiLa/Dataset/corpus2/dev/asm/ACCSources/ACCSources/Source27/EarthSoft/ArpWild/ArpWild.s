;
; Program to allow the use of '*' as a wildcard. (WB2.0+ only).
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Since this program is so short, this source file constitutes the
; entire of the documentation.
;
; Despite its name, this program does NOT require arp.library.
;
; When run on a WB2.0+ Amiga, this program will allow the use of
; '*' as a universal wildcard, instead of (nay, as well as) the more
; cumbersome '#?'. The name 'ArpWild' is in acknowledgement of the
; fact that ARP thought of the idea before Commodore, and many of us
; have been using ARP's wildcards under WB1.3 for some time already.
;
; To use this program, copy it onto your boot disc, anywhere in the
; command search path. Then edit the file "s:user-startup" to include
; the command ArpWild (AFTER the command search path has been
; established).
;
; CAVEATS:
;
; The new AmigaDOS '*' wildcard behaves ALMOST like the old ARP '*',
; but not identically. In fact, the AmigaDOS usage is very slightly
; preferable. The difference occurs when the wildcard pattern consists
; ONLY of a single '*'. Under the old ARP scheme, this would represent
; all files in the current directory, but under 2.0 AmigaDOS, it
; means THE CURRENT SHELL. Thus "Type * to T:temp" will expect input
; from the keyboard instead of concatenating all files.
;
; This minor difference means that accessing the current shell's
; console, either for input or output, is extremely simple and
; straightforward.
;
; The question arises, however, "How do you represent all files in
; the current directory?". Well - you could go back to using the old
; fashioned '#?', but that's boring. My favourite is to use '**' for
; this special case.
;

; Assemble using Devpac 3 using preassembled header "system.gs"

; Have inserted required includes, MM.

	incdir	sys:include2.0/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

ArpWild	
;
; Open the dos.library.
;
	move.l	4.w,a6				a6 = base of exec.library
	lea.l	Name(pc),a1
	move.l	#36,d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq.b	Exit				Abort if couldn't open library
	move.l	d0,a6				a6 = base of dos.library
;
; Set the wildstar flag.
;
	move.l	dl_Root(a6),a0			a0 = root node
	bset	#RNB_WILDSTAR-24,rn_Flags(a0)	Flag in ms byte of longword
;
; Print a message.
;
	move.l	#Text2,d1
	jsr	_LVOPutStr(a6)

	move.l	#Text3,d1
	jsr	_LVOPutStr(a6)
;
; Close the dos.library.
;
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
Exit	rts
;
; Various strings...
;
Name	dc.b	'dos.library',0
Text1	dc.b	'$','VER: '
Text2	dc.b	'ArpWild 2.0 (29.08.92)',0
Text3	dc.b	' by Arcane Jill',$A
	dc.b	"'*' is now available as a universal wildcard",$A,0
;
; PUBLIC DOMAIN NOTICE
;
; This program is public domain and freely distributable.
; It was written by Arcane Jill (of EarthSoft).
;

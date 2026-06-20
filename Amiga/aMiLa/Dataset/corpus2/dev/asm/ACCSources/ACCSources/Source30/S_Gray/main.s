
;	         A UTILITY FIRST  ©  STEVE GRAY
;                - ------- -----     ----- ----

;-------->>>     Special Thanks  To Mark Meany
;                ------- ------  -- ---- -----

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		include		intuition/intuitionbase.i

		move.b		#0,-1(a0,d0)
		move.l		a0,filename		
			
;--open lib	
		lea		dosname,a1		a1 -->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary
		beq		error
		move.l		d0,_DOSBase
		
;--Open intuition library and store its base pointer

		lea		IntName,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		tst.l		d0
		beq		error
		move.l		d0,_IntuitionBase
		
		
;--Intro
		CALLDOS		Output
		move.l		d0,STD_OUT
		beq		error_no
		bsr		cls
		lea		Intro,a0
		bsr		PrintMsg
		bsr		GetFilename
		bsr		cls

;--start	
		CALLDOS		Output			get handle
		move.l		d0,STD_OUT		store it
		beq		error_no		quit if no handle
		lea		message,a0
		bsr		PrintMsg		write text
		
;--get output
		CALLDOS		Output			get output handle
		move.l		d0,CLI_out		and store it
		beq		error_no		quit if no handle
		
;--get input
		CALLDOS		Input			get input handle
		move.l		d0,CLI_in		and store it
		beq		error_no		quit if no handle
 
;--get reply
		move.l		CLI_in,d1		d1=file handle (keyboard)
		move.l		#buf,d2			d2=addr of buffer
		move.l		#buf_len,d3		d3=max num of chars
		CALLDOS		Read			get user reply
		move.l		d0,reply_len		save reply length
		
		bsr		cls
				
;--write greeting

		move.l		CLI_out,d1		d1=file handle
		move.l		#message1,d2		d2=addr of message
		move.l		#msg1_len,d3		d3=length of message
		CALLDOS		Write			write text into CLI

;--echo user			
		move.l		CLI_out,d1		d1=file handle
		move.l		#buf,d2			d2=addr of message
       		move.l		reply_len,d3		d3=length of message
		CALLDOS		Write			write text into CLI
		
		bsr		msg1
;---------------------------------------------------------------------------
menumain	bsr		submenu
		bsr		msg2
;---------------------------------------------------------------------------		
;--Decisions	
		move.l		filename,a0
		cmpi.b		#'',(a0)
		beq		Select

		cmpi.b		#'!',(a0)
		beq		Bye		
			
		cmpi.b		#'?',(a0)
		beq		Help
		
		cmpi.b		#'0',(a0)
		beq		Prefs
		
		cmpi.b		#'1',(a0)
		beq		txt
		
		cmpi.b		#'2',(a0)
		beq		fmaster
		
		cmpi.b		#'3',(a0)
		beq		dsid
		
		cmpi.b		#'4',(a0)
		beq		dcopy
		
		cmpi.b		#'5',(a0)
		beq		ppack

		cmpi.b		#'6',(a0)
		beq		kefcon		

		cmpi.b		#'7',(a0)
		beq		titan
		
		cmpi.b		#'8',(a0)
		beq		pcalc
		
		cmpi.b		#'9',(a0)
		beq		space
		
		cmpi.b		#'<',(a0)
		beq		music1
		
		cmpi.b		#'>',(a0)
		beq		music2
		
		cmpi.b		#'*',(a0)
		beq		Pplayer
		
		cmpi.b		#'@',(a0)
		beq		hlp2
		
		cmpi.b		#'$',(a0)
		beq		Cli
		
		cmpi.b		#'%',(a0)
		beq		sinfo		
		
		cmpi.b		#'^',(a0)
		beq		warn
		
		bne		menumain
							
;---------------------------------------------------------------------------						
;--close dos	

error_no	move.l		_DOSBase,a1		error_no handle	
		CALLEXEC	CloseLibrary
;--close int		
		move.l		_IntuitionBase,a1
		CALLEXEC	CloseLibrary
error		rts
		

;--SUBROUTINES
;  -------------------------------------------------------------------------

PrintMsg

; Entry	 ------ a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.

		move.l		a0,a1			get a working copy

		moveq.l		#-1,d3			reset counter
loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne		loop			if not loop back

;--Make sure there was a message

		tst.l		d3			was there a message ?
		beq		.error			if not, graceful exit

;--Get handle of output file

		move.l		STD_OUT,d1		d1=file handle
		beq		.error			leave if no handle

;--Now print the message
;  At this point, d3 already holds length of message
;  and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it
.error		rts

;---------------------------------------------------------------------------

GetFilename	CALLDOS		Input		get keyboard handle
		move.l		d0,STD_IN	store it
		beq		error		leave if no handle

		move.l		STD_IN,d1	d1=handle
		move.l		#key_buffer,d2	d2=addr of buffer
		move.l		#buf_len,d3	d3=max num of chars to read
		CALLDOS		Read		get user input

;--Save addr of filename and 0 terminate it

		lea		key_buffer,a0	a0=addr of filename
		move.l		a0,filename	save addr of filename
		move.b		#0,-1(a0,d0)	0 terminate

;--Get first character of filename into register d0. If this is
;  a 0 byte then the user pressed return and wants to quit. This
;  value will be passed back to the calling program.

		moveq.l		#0,d0
		move.b		(a0),d0
		rts
;---------------------------------------------------------------------------	
;--Clear the Cli...Thankyou, Mike Cross

cls
	jsr	-60(A6)		Output() - Get CLI handle
	move.l	D0,D1
	lea	Buffer,A0	Write clr codes
	move.l	A0,D2
	moveq.l	#4,D3
	jsr	-48(A6)		Write()
	tst.l	D0
	bmi.s	Err
	moveq.l	#0,D0		
Exit	rts	
 
Err	jsr	-132(A6)	IoErr() - Get error code for
	rts			CLI Why command	
	even
	
Buffer	dc.b	$9b,$48,$9b,$4a
;---------------------------------------------------------------------------
msg1

;--Get keyboard handle

		CALLDOS		Input		get keyboard handle
		move.l		d0,STD_OUT	store it
		beq		error		leave if no handle

;--Display a prompt to the user
		
		lea		answer,a0	a0=addr of prompt message
		bsr		PrintMsg	print it
		bsr		GetFilename		
		rts
;---------------------------------------------------------------------------
submenu		bsr		cls
		lea		menu,a0
		bsr		PrintMsg
		rts
;---------------------------------------------------------------------------
;--Get keyboard handle

msg2		CALLDOS		Input		get keyboard handle
		move.l		d0,STD_OUT	store it
		beq		error		leave if no handle

;--Display a prompt to the user
		
		lea		choice,a0	a0=addr of prompt message
		bsr		PrintMsg	print it
		bsr		GetFilename
		rts		
;---------------------------------------------------------------------------
Select		bne		menumain
		bsr		cls
		lea		nokey,a0
		bsr		PrintMsg
		bsr		GetFilename
		bra		menumain
		rts
;---------------------------------------------------------------------------

Help		bne		menumain
		bsr		cls
		lea		helpmsg,a0
		bsr		PrintMsg
		bsr		GetFilename
		bra		menumain
		rts		
;---------------------------------------------------------------------------

hlp2		bne		menumain
		bsr		cls
		lea		help2,a0
		bsr		PrintMsg
		bsr		GetFilename
		bra		menumain
		rts		
;---------------------------------------------------------------------------

Bye		bsr		cls
		lea		endmsg,a0
		bsr		PrintMsg
		bra		Wb
;---------------------------------------------------------------------------
;--Run WorkBench

Wb		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Bench,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		Open	
;---------------------------------------------------------------------------
;--Run BackDrop

Open		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Back,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		error_no
;---------------------------------------------------------------------------
;--Run Preferences

Prefs		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Pref,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run text editor

txt		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Editor,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run FileMaster

fmaster		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#FileM,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain

;---------------------------------------------------------------------------
;--Run Deksid

dsid		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#DekS,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run Dcopy2

dcopy		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Dc2,d1			d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run powerpacker

ppack		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#PowerPack,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run Kefconverter

kefcon		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Kconvert,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run TitanCruncher

titan		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Tcrunch,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run ProCalc

pcalc		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#ProCal,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run Space Game

space		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Game,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run Music1

music1		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#sound1,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run Music2

music2		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#sound2,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		bra		menumain
;---------------------------------------------------------------------------
;--Run PowerPlayer

Pplayer		bne		menumain
		bsr		cls
		lea		pscreen,a0
		bsr		PrintMsg
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Power,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7		
		bra		menumain
;---------------------------------------------------------------------------
;--Run Newcli

Cli		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#newcli,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7				
		bra		menumain
;---------------------------------------------------------------------------
;--Run SysInfo

sinfo		bne		menumain
		bsr		cls
		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#sysinf,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7				
		bra		menumain
;---------------------------------------------------------------------------
;--Warning 1.2/3 Users

warn		bsr		cls
		lea		warning,a0
		bsr		PrintMsg

loopM		btst		#6,$bfe001
		beq		menumain
		
		btst		#10,$dff016
		beq		GURU
		
		bne		loopM
;---------------------------------------------------------------------------
;--Call the Alert  ---Thanks Raistlin

GURU
						; Bring alert on screen
CALLALERT
	move.l	RECOVERY_ALERT,d0		; Not a fatal alert
	lea	string,a0			; address of info for text
	move.l	#50,d1				; Height of alert box
	CALLINT	DisplayAlert			; Display the alert

	cmpi.b	#0,d0				; Was RMB pressed?
	beq	CALLALERT			; If so redisplay Alert
	bra	menumain
;---------------------------------------------------------------------------			
;--DATA
;  ----	
	
dosname		dc.b	'dos.library',0
_DOSBase	dc.l		0

IntName		dc.b	"intuition.library",0
_IntuitionBase	dc.l	0

STD_IN		dc.l		0
STD_OUT		dc.l		0

CLI_out		dc.l		0
CLI_in		dc.l		0

filename	dc.l		0

string		dc.w	160				X pos of text 
		dc.b	25			 	Y Pos of text
		dc.b	' HI  FROM  STEVE  YOUR  FRIENDLY  GURU !',0 
		dc.b	0			

Pref		dc.b		'Dos:devs/prefs',0
		even
Editor		dc.b		'Dos:pdir/txted',0
		even
FileM		dc.b		'Dos:pdir/filemaster',0
		even
DekS		dc.b		'Dos:pdir/deksid',0
		even
Dc2		dc.b		'Dos:pdir/dcopy2',0
		even
PowerPack	dc.b		'Dos:pdir/powerpacker',0
		even
Kconvert	dc.b		'Dos:pdir/kefconverter',0
		even
Tcrunch		dc.b		'Dos:pdir/titancrunch',0
		even
ProCal		dc.b		'Dos:pdir/procalc',0
		even
Game		dc.b		'Dos:pdir/SpaceInvaders',0
		even
sound1		dc.b		'Dos:devs/nplayer -p4 Dos:s/FantasyMusic',0
		even
sound2		dc.b		'Dos:devs/nplayer -p4 Dos:s/Nebulos',0
		even
Power		dc.b		'Dos:pdir/powerplay Dos:s/Cool',0
		even
newcli		dc.b		'Dos:c/Newcli',0
		even
sysinf		dc.b		'Dos:pdir/sysinfo',0
		even
Bench		dc.b		'Dos:c/Loadwb',0
		even
Back		dc.b		'Dos:devs/myscreen',0
		even
						
;--Display messages

Intro		dc.b	$0a,$0a,$0a,$0a,$0a
		dc.b	'                          A  FRONT  END  UTILITY '
		dc.b	$0a,$0a
		dc.b	'                          ©  Coding  STEVE  GRAY '
		dc.b	$0a,$0a,$0a,$0a,$0a
		dc.b	'   Return> To Continue  ',0

message		dc.b	$0a,$0a,$0a
		dc.b	$0a,'Enter Your Name Please -->  ',0
msg_len		equ	*-message
		even
key_buffer	ds.b	200		
buf		ds.b	34
buf_len
		even			

message1	dc.b	$0a,$0a,$0a,$0a,$0a,$0a
		dc.b	$0a,'                             Hi There  '
msg1_len	equ	*-message1
		even
reply_len	dc.l		0		
		
menu		dc.b	$0a
		dc.b	'                          FRONT  END  ©  STEVE GRAY ',$0a
		dc.b	'                          -----  ---     ----- ---- ',$0a
		dc.b	'                                  THE  MENU',$0a
		dc.b	$0a
		dc.b	'      [ ? ]  Help                               Help 2  --------    [ @ ]',$0a
		dc.b	$0a
		dc.b	'      [ ! ]  Quit                               BackGround Music 1  [ < ]',$0a
		dc.b	$0a
		dc.b	'      [ 0 ]  Preferences                        BackGround Music 2  [ > ]',$0a
		dc.b	$0a
		dc.b	'      [ 1 ]  Text  Editor                       PowerPlayer         [ * ] ',$0a
		dc.b	$0a
		dc.b	'      [ 2 ]  FileMaster                         Run a Cli           [ $ ]',$0a
		dc.b	$0a
		dc.b	'      [ 3 ]  DekSid ',$0a
		dc.b	$0a
		dc.b	'      [ 4 ]  DCopy2 ',$0a
		dc.b	$0a
		dc.b	'      [ 5 ]  PowerPacker                             ~PINK ~FLOYD',$0a
		dc.b	$0a
		dc.b	'      [ 6 ]  Kefconvert ',$0a
		dc.b	$0a
		dc.b	'      [ 7 ]  TitanCrunch ',$0a
		dc.b	$0a
		dc.b	'      [ 8 ]  ProCalc                            Guru..      >>>>    [ ^ ]',$0a
		dc.b	$0a
		dc.b	'      [ 9 ]  The One And Only                   System Info ____    [ % ]',$0a    
		dc.b	$0a,0
		even
		
answer		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		dc.b	' Return> To Continue ',0
		even

choice		dc.b	' Please Make a Choice -->   ',0
		even
nokey		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a		
		dc.b	'         I REALLY THINK IT WOULD BE BETTER IF YOU MADE A DECISION'
		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		dc.b	' Return> To Continue ',0	
		even
		
helpmsg		dc.b	$0a,$0a 
		dc.b	'       { ? }  Gives  You  This  Screen',$0a
		dc.b	$0a
		dc.b	'       { ! }  Quit   -- Goodbye !',$0a
		dc.b	$0a
		dc.b    '       { 0 }  Gives You Preferences !!',$0a
		dc.b	$0a
		dc.b	'       { 1 }  Easy  to  Use  Text  Editor',$0a
		dc.b	$0a
		dc.b	'       { 2 }  Excellent  File  Editor',$0a
		dc.b	$0a
		dc.b	'       { 3 }  Excellent  Disk  Editor',$0a
		dc.b	$0a
		dc.b	'       { 4 }  A Very  Good " Disk Copier "',$0a
		dc.b	$0a
		dc.b	'       { 5 }  Versatile  Crunching  Utility',$0a
		dc.b	$0a
		dc.b	'       { 6 }  Good  Piccy  Conversion  Utility',$0a
		dc.b	$0a
		dc.b	'       { 7 }  For  That  Hard  To  Crunch  Program',$0a
		dc.b	$0a
		dc.b	'       { 8 }  A  Powerful  Programmers  Calculator',$0a
		dc.b	$0a
		dc.b	'       { 9 }  Probably  The  Best  Game  Of  All',$0a
		dc.b	$0a,$0a
		dc.b	' Return> To Continue ',0		
		even
		
pscreen		dc.b	$0a,$0a,$0a,$0a,$0a
		dc.b	'                   A NIFTY  BIT  OF  MUSIC  AND  GRAPHICS',$0a
		dc.b	$0a
		dc.b	'                   LEFT  MOUSE  OR  F1 > F10  EXIT',$0a
		dc.b	$0a
		dc.b	'                                                 ---- Steve',0                         
		even
				
help2		dc.b	$0a,$0a
		dc.b	'    " When Selected " DCopy Likes To Be In Charge... ',$0a    
		dc.b	$0a
		dc.b	'   { DCopy -- Sometimes Asks For Volume Dos to be Inserted ',$0a
		dc.b	$0a
		dc.b	'     Ignore It -- ( Click On Cancel )}',$0a
		dc.b	$0a
		dc.b	'     It Is Advisable Not To Have Any BackGround Music If Using DCopy ',$0a
		dc.b	$0a
		dc.b	'     It Is Pointless Running Any BackGround Music If PowerPlay Is Selected ',$0a
		dc.b	$0a
		dc.b	'     System Info !! ',$0a
		dc.b	$0a
		dc.b	'     WORKS OK! ON THE [ 1.3 SYSTEM ]     ___~Steve ',$0a
		dc.b	$0a,$0a
		dc.b	'     MAKE A BACKUP OF THIS DISK  " IF LIKE ME.. YOU LIKE TO GET NOSEY " ',$0a
		dc.b	$0a
		dc.b	'                  THIS  DISK  IS  TOTALLY  VIRUS  FREE ',$0a
		dc.b	'                  ----  ----  --  -------  -----  ---- ',$0a   
		dc.b	$0a
		dc.b	' >>> I HAVE INCLUDED POWERPACKER V3.0a ..WHICH I PURCHASED FOR £10.00 <<<',$0a
		dc.b	$0a
		dc.b	'   >>>  ONLY TO SEE VERSION 3.0b FREE WITH THE CU AMIGA MAGAZINE !! <<<',$0a
		dc.b	$0a,$0a,$0a
		dc.b	'  Return> To Continue ',0       
		even
		
warning		dc.b	$0a,$0a,$0a,$0a
		dc.b	'                        ////////////////////////////////////\  ',$0a
		dc.b	'                       /                                  / /  ',$0a
		dc.b	'                      /                                  / /   ',$0a
		dc.b	'                     /    1.3  Users  Are  You  SURE    / /    ',$0a
		dc.b	'                    /                                  / /     ',$0a
		dc.b	'                   /                                  / /      ',$0a
		dc.b	'                   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/       ',$0a
		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		dc.b	'    -- Left Mouse   .. Better Not! ',$0a
		dc.b	$0a
		dc.b	'    -- Right Mouse  .. Why Not! ',$0a,0
		
endmsg		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a 
		dc.b	'                       Thanks For Using This Utility '
		dc.b	$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,0	
		even
		
;---------------------------------------------------------------------------

; ----------------  Thankyou  -->>>>  ACC..  To Any And Everyone..

;---------------------------------------------------------------------------		

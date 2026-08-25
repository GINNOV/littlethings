; ---------------------------------------------------------------------	

; Function name:     EventHandler()

; Purpose:           Handles window menu events

; Input Parameters:  Address of IDCMP user-port should be in a2. 

; Output parameters: None

; Register Usage:    a0: Used by WaitPort() and GetMsg()  
                     
;                    a1: Used by ReplyMsg()
                     
;                    a2: Holds user-port address

;                    d0: Used by WaitPort() and GetMsg()
                     
;                    d1: Unused but possibly altered by system functions

;                    d2: Used as an exit flag (quit when non-zero)

;		     d3: Used to hold message class field

;		     d4: Used to hold message code field


; Other Notes:       Within EventHandler() all registers are preserved

; ---------------------------------------------------------------------

EventHandler   	movem.l	d0-d4/a0-a2,-(a7)	preserve registers
		clr.l	d2			clear exit flag
EventHandler2	movea.l	a2,a0			port address  
		CALLSYS	WaitPort,_SysBase  
		jsr	GetMessage           
		cmpi.l	#TRUE,d2		exit flag set?
		bne.s	EventHandler2
		movem.l	(a7)+,d0-d4/a0-a2	restore registers
		rts				logical end of routine

; ---------------------------------------------------------------------
                     
GetMessage	movea.l	a2,a0			get port address in a0
		CALLSYS	GetMsg,_SysBase		get the message
		tst.l	d0
		beq.s	GetMessageExit		did it exist?
		movea.l	d0,a1			copy pointer to a1
		move.l	im_Class(a1),d3		copy message class
		move.w	im_Code(a1),d4		copy message code
		CALLSYS	ReplyMsg,_SysBase	then send message back

		cmpi.l	#IDCMP_CLOSEWINDOW,d3
		bne.s	MenuMessage
		moveq	#TRUE,d2		set QUIT signal to exit routine 
		bra.s	GetMessage
		
MenuMessage	cmpi.l	#IDCMP_MENUPICK,d3 	check message class
		bne.s	GetMessage		ignore other message types           	

		cmpi.w	#MENUNULL,d4
		beq.s	GetMessage		ignore if MENUNULL
		lsr.w	#5,d4			extract menu item number
		andi.b	#$3F,d4			(will be either 0 or 1)
		beq.s	SelectFile
		moveq	#TRUE,d2		set QUIT signal to exit routine 
		bra.s	GetMessage
		
SelectFile	jsr	DoNothing		call a dummy routine
		bra.s	GetMessage		check for more messages!

GetMessageExit	rts				d2 holds exit flag

; ---------------------------------------------------------------------

DoNothing	rts				does exactly what it says

; ---------------------------------------------------------------------

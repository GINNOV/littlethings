*
* Example of reading the Amiga Keyboard from Assembler
* Must be polled to see if a character is ready, generates
* no interrupts that I know of.
* Reads A500 and A1000 as documented in manual, can't be sure
* about A2000??????
*
* Written by Brian Kelly (Emerald Software) 24-Jun-88 
*
* Notes: The H/W manual does not tell the whole story and you
*        must do a little messing about to "manualify" it so that
*        the codes you get back are the same as those on page 239 
*        of the H/W manual.
*        The way that I acknowledge the receipt of a character is
*        a shot in the dark. The manual is exceedingly hazy about
*        how it should be done. The way I do it is allow the keyboard
*        processor to clock the serial port on the ODD 8520 and send 
*        a zero character. This when padded out with start and stop
*        bits should produce the desired low pulse for the other end.
*        It works 100% of the time for me so I must be doin' something
*        right.
*
* Calling Mechanisms:
*
*         Call SetupKeyboard first to disable interrupts and stuff
*         Call ReadKeyboard to get a keycode in d0.w, -1 implies no key press


IntCReg         equ     $bfed01		* Interrupt Control reg for ODD 8520
ControlRegA	equ	$bfee01		* CRA of the ODD 8520
SerialDataReg	equ	$bfec01		* Serial Data Register of ODD 8520
TimerAH		equ	$bfe501		* Timer A High Reg
TimerAL		equ	$bfe401		* Timer A Low Reg

* Fristly call this to setup the ODD 8520 CIA so that there
* are NO interrupts caused by anything then we can poll it to see
* if anything interesting is to be read.

		XDEF	_SetupKeyboard
_SetupKeyboard:	move.b	#%00001000,IntCReg	* Code to turn OFF all interrupts
                andi.b	#%10111111,ControlRegA	* Serial Port set to input mode
                rts
             
* Call this to read the keyboard, it returns a word value in d0
* This code is (eventually) as per hardware manual, -1 if nothing 
* interesting has happened to the keyboard

		XDEF	_ReadKeyboard
_ReadKeyboard:	move.b	IntCReg,d0	* Get the current state of the Int's
		btst.l	#3,d0		* Test to see if Data Reg is full ??
                beq.s	FallOut		* Nothing to get
		move.b	SerialDataReg,d0	* Get the byte
                bsr	SendAck		* Send ACK to the other processor
                ror.b	#1,d0		* Get the UP/DOWN bit to bit 7
                eori.b	#$ff,d0		* Negate everything
                andi.w	#$ff,d0		* Make sure it's +ve
		rts			
FallOut:	moveq.l	#-1,d0		* Nothing Pressed
		rts

* Call this to send an ACK signal to the keyboard processor
* See page 236 and pages F6-F7 of the H/W manual for absolutely
* no "meaty" info on how it SHOULD be done.

SendAck:	
		move.b	#%01000001,ControlRegA	* Init timer and serial port
		move.b	#0,TimerAH		* High value for Count
                move.b	#1,TimerAL		* Low value for Count
		move.b	#$00,SerialDataReg	* Send -________- for ACK
10$:            btst.b	#3,IntCReg		* Check for completion
         	beq.s	10$			* Loop 'till done
                andi.b	#%10111111,ControlRegA	* Serial Port set to input 
                rts				* Finished..........


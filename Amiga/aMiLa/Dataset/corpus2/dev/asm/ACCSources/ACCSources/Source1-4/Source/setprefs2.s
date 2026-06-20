*	PROGRAM TO ALTER THE STANDARD SCREEN COLOURS

*	(C)1990 MIKE CROSS

*	PLEASE NOTE - THIS PROGRAM COULD EASILY BE ALTERED TO
*	READ THE SYSTEM-CONFIGURATION IN FROM THE DISK, ALTER IT
*	AND THEN SAVE IT BACK TO THE DISK.

	Opt	C-

	move.l	$4,a6
	lea	IntName,a1
	jsr	-408(a6)	* Open Intuiton Library
	beq	Error
	move.l	d0,IntBase	* Save Base Structure
		


	move.l	IntBase,a6
	lea	Prefs,a0	* Buffer to store Prefs in
	move.w	#232,d0		* Buffer size
	jsr	-132(a6)	* GetPrefs()
	
	
	lea	Prefs,a0
	move.w	#$fff,110(a0)	* Screen Colours (110-116)
	move.w	#$000,112(a0)
	move.w	#$555,114(a0)
	move.w	#$999,116(a0)
	move.w	#$001,108(a0)	* Pointer Ticks (Fastest) 
	
	
	
	lea	Prefs,a0
	move.w	#232,d0		* Size
	move.w	#1,d1		* Don`t know what this does!
	jsr	-324(a6)	* SetPrefs()
	


	move.l	$4,a6
	move.l	IntBase,a1
	jsr	-414(a6)
Error	rts
	
	
Prefs	dcb.b	232,0		* Storage for preferences

IntName	dc.b	"intuition.library",0

IntBase	dc.l	0


	

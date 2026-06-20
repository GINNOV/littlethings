

* IMMORTAL's special macros ,v1.1


	IFND _PHXMACRO_I
	include phxmacros.i

	IFND LVOS_I
	include lvos.i		;CallLib is defined there

	IFND _IMMORTAL1_I
_IMMORTAL1_I 	set 	-1


*
*	Contents:
*	
*	MExec <function name>			calls an exec function
*	MAlloc <bytesize> <requirements>	allocates memory ->d0
*	MFree	<memoryblock>			frees the memory
*	MOpenLibrary	<libraryname> <version> opens library -->d0
*	MCloseLibrary	<#lib pointer>		closes library
*	MDosCall <function name>		calls the dos funct
*	MPrint  <text>				prints text, no LF
*	MPrintL <text>				prints text with LF
*	MExit2Dos <exitcode>			exits program
*	MPrintHex <#pointer2value> 		prints a long hex number
*	MPrintDec <#pointer2value>		prints a long dec number

*	MOpenDos				Opens dos.Library
*	MCloseDos				Closes dos.library
*	MOpenGfx				Opens graphics.library
*	MCloseGfx				Closes graphics.library
*	MOpenIntuition				Opens intuition.library
*	MCloseIntuition				Closes

* First of all some exec macros

MExec	MACRO
	push.l a6
	move.l _AbsExecBase.w,a6
	CallLb \1
	pop.l a6
	ENDM

;now memory allocation, result in d0


MAlloc	MACRO		;MAlloc #bytesize,#requirements
	push.l d1
	move.l \1,d0
	move.l \2,d1
	MExec AllocVec
	pop.l d1
	ENDM

MFree   MACRO		;MFree #memoryblock
	push.l a1
	move.l \1,a1
	MExec FreeVec
	pop.l a1
	ENDM
	
MOpenLibrary	MACRO	;MOpenLibrary LibName,version
		push.l a1
		leastr \1,a1
		move.l #\2,d0
		MExec OpenLibrary
		pop.l a1
		ENDM

MCloseLibrary	MACRO	; #librarypointer
		push.l a1
		move.l \1,a1
		MExec CloseLibrary
		pop.l a1
		ENDM
		
MDosCall	MACRO	;MDosCall func  ! requires defined _DosAbsBase variable!!!!
		push.l a6
		move.l _DosAbsBase,a6
		CallLb \1
		pop.l a6
		ENDM

MPrint		MACRO 	;MPrint text
		push.l a1
		push.l d1
		leastr \1,a1
		move.l a1,d1
		MDosCall PutStr
		pop.l a1
		pop.l d1
		ENDM
		 
* MISC STUFF

MPrintL		MACRO	;MPrintL text
		MPrint \1
		MPrint 10
		ENDM


MExit2Dos	MACRO	; MExit2Dos <exitcode>
		move.l \1,d0
		rts
		ENDM

MPrintHex	MACRO	; MPrintHex <#pointer2val>
		MPrint "$"
		push.l a0
		push.l d1
		push.l d2	 
		leastr "%lx",a0
		move.l a0,d1
		move.l \1,d2
		MDosCall VPrintf
		pop.l d2
		pop.l d1
		pop.l a0
		ENDM

MPrintDec	MACRO	; MPrintDec <#pointer2val>
		push.l a0
		push.l d1
		push.l d2	 
		leastr "%ld",a0
		move.l a0,d1
		move.l \1,d2
		MDosCall VPrintf
		pop.l d2
		pop.l d1
		pop.l a0
		ENDM

*   .....................................................

MOpenDos	MACRO  ;
		MOpenLibrary "dos.library" ,0
		move.l d0,_DosAbsBase	
		ENDM

MCloseDos	MACRO
		MCloseLibrary _DosAbsBase
		ENDM

MOpenGfx	MACRO 
		MOpenLibrary "graphics.library",0
		move.l d0,_GfxAbsBase
		ENDM

MCloseGfx	MACRO
		MCloseLibrary _GfxAbsBase
		ENDM

MOpenIntuition	MACRO
		MOpenLibrary  "intuition.library",0
		move.l d0,_IntuitionAbsBase
		ENDM

MCloseIntuition MACRO
		MCloseLibrary _IntuitionAbsBase
		ENDM
		


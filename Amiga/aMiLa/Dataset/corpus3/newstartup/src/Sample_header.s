	*««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««*
	*
	*   © 1996 by Kenneth C. Nilsen. E-Mail: kennecni@idgOnline.no
	*
	*   Name
	*	Sample header version 2.0 with tutorial examples
	*
	*   Function
	*	Shows example setup in source. Please read the docs for more
	*	information on how to use the macros.
	*
	*   Inputs
	*	
	*
	*   Notes
	*	Please remove any unwanted info and use this as your
	*	standard header.
	*
	*   Bugs
	*	
	*   Created	: 06.10.96
	*   Last change	: 06.10.96
	*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*

*## For the Startup.asm:

StartSkip	=	1		;0=WB/CLI, 1=CLI only  (AsmOne)

;CpuCheck	set	1		;if these aren't defined the CPU or/
;MathCheck	set	1		;and math check will be ignored

Processor	=	0		;0/680x0/0x0
MathProc	=	0		;0/68881/68882/68040/68060

*## For the DUMPSTRING macro:

;DODUMP		SET	1		;define to activate DebugDump and
					;InitDebugHandler else they will be
					;ignored (not assembled)

*## Default includes:

		Incdir	inc:
		Include	Startup.asm

*## Version string to be looked for with C:Version :

	dc.b	"$VER: SampleHeader 1.0  (06.10.96)",10
	dc.b	"This header is PUBLIC DOMAIN",0
	even
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
Init:	TaskName	"Test"	;use "<Test>" for DevPac/BarFly
	DefLib	dos,39	;open dos.library version 39 (kick 3.0+)
	DefEnd

Start:	InitDebugHandler	"CON:0/20/640/160/Debug Output/WAIT/CLOSE"

	DebugDump	"This is only assembled when DODUMP SET 1",0

	NextArg
	beq.b	Close		;any arguments ?

	LibBase	dos		;use dos base

	StartFrom		;check where we started from
	beq.b	Dos		;started from CLI

Dos:
*·············································································*
Close	Return	0
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
*·············································································*
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*

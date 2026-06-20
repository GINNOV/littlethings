; $VER: AssTexts.asm 4.46 (14.10.14)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2014
;
;            Englische Default-Texte
;
; **********************************************

	far				; Large Code/Data-Model

	ttl	"PhxAss - Locale Strings"


; *** Cross-References ***

	xdef	DefStringBase


	section	DefStr,data

DefStringBase:
	; Alle englischen Default-Strings
	dc.b	"\nCopyright 1991-2014 by Frank Wille\n",0		*00*
	dc.b	"\nImportant parameters:\n",0				*01*
	dc.b	"  TO <name>\t\t\tSet object name\n",0
	dc.b	"  DS=SYMDEBUG\t\t\tAppend symbol debug blocks\n",0
	dc.b	"  DL=LINEDEBUG\t\t\tAppend source level debugging information\n",0
	dc.b	"  OPT <flags>\t\t\tDetermine optimization level\n",0
	dc.b	"  SC=SMALLCODE\t\t\tForce small code model\n",0
	dc.b	"  SD=SMALLDATA <basReg>[,<sec>] Force small data model\n",0
	dc.b	"  SET <symbol[=value]>\t\tPreset symbol value (default: 1)\n",0 *08*
	IFND	FREEASS
	dc.b	"  LIST <name>\t\t\tListing file\n",0
	dc.b	"  EQU <name>\t\t\tEquates file\n",0
	dc.b	"  I=INCPATH <path1[,path2,...]>\tDefine include paths\n",0
	dc.b	"  H=HEADINC <name1[,name2,...]>\tInclude files\n",0	*12*
	dcb.b	5,0
	ELSE
	dcb.b	9,0
	ENDC
	dc.b	"\nRefer to documentation for more options.\n",0	*18*
	dc.b	0

	dc.b	"Pass %d\n",0						*20*
	dc.b	"Optimize '%c' ignored !\n",0

	dc.b	"\n%ld lines in %d.%02d sec = %ld lines/min.\n",0	*22*
	dc.b	"Global symbols: %ld\nLocal symbols:  %ld\n",0
	dc.b	"Bytes gained by optimization: %ld\n",0
	dc.b	"Code: ",0
	dc.b	"Data: ",0
	dc.b	"BSS:  ",0
	dc.b	"%3d section(s)  %7ld bytes\n",0
	dc.b	"none\n",0

	IFND	FREEASS
	dc.b	"%s    %38s    Page %-3d\n\n",0				*30*
	dc.b	0,0,0

	dc.b	"***  SECTIONS  ***\n\n"				*34*
	dc.b	"No  Name                             Type            First referenced"
	dc.b	10,0
	dc.b	"CODE",0						*35*
	dc.b	"DATA",0
	dc.b	"BSS",0
	dc.b	"OFFS",0
	dc.b	0

	dc.b	"\n\n***  SYMBOLS  ***\n\n"				*40*
	dc.b	"Symbol           Value    Section Line  References\n",0
	dc.b	" +++ MACRO +++  ",0
	dc.b	"  -- SET Symbol --     ",0
	dc.b	"*** unreferenced ***\n",0
	dc.b	0,0,0,0,0

	dc.b	"***  Equates file for %-32s %s  ***\n\n",0		*49*
	ELSE
	dcb.b	20,0
	ENDC

	dc.b	"%s\n%d %s\n in line %ld (= line %ld of %s)\n\n",0	*50*
	dc.b	"Do you want to continue (y/n) ? ",0
	dc.b	"Init",0
	dc.b	"CleanUp",0
	dc.b	"Divide up your source or buy more RAM",0
	dc.b	"\n*** BREAK - Assembly terminated\n",0			*55*
	dc.b	"In line %ld of macro %s:\n",0
	dc.b	0,0,0,0,0,0

	dc.b	"Y",0							*63*
	dc.b	"00 No errors.\n",0					*64*
	dc.b	"Out of memory",0
	dc.b	"Unable to open utility.library",0
	dc.b	"Can't open timer.device",0
	dc.b	"DREL16 out of range",0
	dc.b	"Invalid PHXOPTIONS file",0
	dc.b	"rsrvd",0
	dc.b	"HEADINC: file name expected",0
	dc.b	"IncDir path name expected",0
	dc.b	"rsrvd",0
	dc.b	"SMALLDATA: Illegal base register",0 ; 10
	dc.b	"MACHINE not supported",0
	dc.b	"File doesn't exist",0
	dc.b	"Missing include file name",0
	dc.b	"Read error",0
	dc.b	"String buffer overflow",0
	dc.b	"Too many sections",0
	dc.b	"Symbol can't be made external",0
	dc.b	"Symbol was declared twice",0
	dc.b	"Unable to make XREF symbol",0
	dc.b	"Illegal opcode extension",0 ; 20
	dc.b	"Illegal macro parameter",0
	dc.b	"Illegal characters in label",0
	dc.b	"Unknown directive",0
	dc.b	"Too many parameters for a macro",0
	dc.b	"Can't open trackdisk.device",0
	dc.b	"Argument buffer overflow",0
	dc.b	"Bad register list",0
	dc.b	"Missing label",0
	dc.b	"Illegal seperator for a register list",0
	dc.b	"SET, MACRO, XDEF, XREF and PUBLIC are illegal for a local symbol",0 ; 30
	dc.b	"Not a register (try d0-d7 or a0-a7 or sp)",0
	dc.b	"Too many ')'",0
	dc.b	"Unknown addressing mode",0
	dc.b	"Addressing mode not supported",0
	dc.b	"Can't use macro in operand",0
	dc.b	"Undefined symbol",0
	dc.b	"Missing register",0
	dc.b	"Need data-register",0
	dc.b	"Need address-register",0
	dc.b	"Word at odd address",0	; 40
	dc.b	"Syntax error in operand",0
	dc.b	"Relocatability error",0
	dc.b	"Too large distance",0
	dc.b	"Displacement expected",0
	dc.b	"Valid address expected",0
	dc.b	"Missing argument",0
	dc.b	"Need numeric symbol",0
	dc.b	"Displacement outside of section",0
	dc.b	"Only one distance allowed",0
	dc.b	"Missing bracket/parenthesis",0	; 50
	dc.b	"Expression stack overflow",0
	dc.b	"Unable to negate an address",0
	dc.b	"Can't use distance and reloc in the same expression",0
	dc.b	"Shift error (wrong type or negative count)",0
	dc.b	"Can't multiply an address",0
	dc.b	"Overflow during multiplication",0
	dc.b	"Can't divide an address",0
	dc.b	"Division by zero",0
	dc.b	"No logical operation allowed on addresses",0
	dc.b	"Need two addresses to make a distance",0 ; 60
	dc.b	"Unable to sum addresses",0
	dc.b	"Write error",0
	dc.b	"Not a byte-, word- or long-string",0
	dc.b	"Can't subtract a XREF",0
	dc.b	"Impossible in absolute mode",0
	dc.b	"Unknown error (fatal program failure)",0
	dc.b	"No externals in absolute mode",0
	dc.b	"Out of range",0
	dc.b	"Assembly aborted",0
	dc.b	"Missing ENDC/ENDIF",0	; 70
	dc.b	"Missing macro name",0
	dc.b	"Missing ENDM",0
	dc.b	"Can't define macro within a macro",0
	dc.b	"Unexpected ENDM",0
	dc.b	"Unexpected ENDC/ENDIF",0
	dc.b	"Impossible in relative mode",0
	dc.b	"Parameter buffer overflow",0
	dc.b	"Illegal REPT count",0
	dc.b	"Unable to create file",0
	dc.b	"No reference list without a listing file",0 ; 80
	dc.b	"No address allowed here",0
	dc.b	"Illegal characters in symbol",0
	dc.b	"Source code too large (max. 65535 lines)",0
	dc.b	"No floating point without the appropriate math-libraries",0
	dc.b	"Overflow during float calculation",0
	dc.b	"Illegal symbol type in float expression",0
	dc.b	"rsrvd",0
	dc.b	"rsrvd",0
	dc.b	"Type of SET can't be changed",0
	dc.b	"Can't mix LOAD, FILE and TRACKDISK",0 ; 90
	dc.b	"Near mode not activated",0
	dc.b	"Instruction not implemented in your machine",0
	dc.b	"Illegal scale factor",0
	dc.b	"Missing operand",0
	dc.b	"Section doesn't exist",0
	dc.b	"Illegal RORG offset",0
	dc.b	"Immediate operand size error",0
	dc.b	"Missing ENDR",0
	dc.b	"Unexpected ENDR",0
	dc.b	"REPT nesting depth exceeded",0	; 100
	dc.b	"Already a directive name",0
	dc.b	"SAVE nesting depth exceeded",0
	dc.b	"Unexpected RESTORE",0
	dc.b	"Missing RESTORE",0

	end

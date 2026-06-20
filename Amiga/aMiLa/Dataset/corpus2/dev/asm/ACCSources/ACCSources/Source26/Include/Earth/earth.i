	IFND	EARTH_EARTH_I
EARTH_EARTH_I	set	1

;$VER: earth_earth_i 3.2 (19.06.92)

_a6MODE		set	0
_AbsExecBase	equ	4
_OPTMASK	equ	$80000000

;==========================
; Declaring the usage of a6
;==========================
;
; When the library calling routines call a library function, register
; a6 is used to point to the library base. You can specify whether a6
; should be treated as scratch (in which case the macros will corrupt
; a6) or not (in which case the macros will preserve a6).
;
; If this macro is omitted then a6 will be treated as scratch,
; unless the data register is a6, in which case it will not.

SETA6	MACRO	;mode
	IFC	'\1','SCRATCH'
_a6MODE	set	0
	ENDC
	IFC	'\1','KEEP'
_a6MODE	set	1
	ENDC
	ENDM

;============================
; Declaring the data register
;============================
;
; You need to declare which register will be used to access your
; private data, so that the library calling routines know where to
; find the library base. This macro does the job. You should use it
; once at the top of each file (after "earth/earth.i" obviously),
; or, preferably, in an include file of your own.
;
; If the SETDATA macro is NOT used, then the library calling macros
; will assume that there is no private data pointer register in use,
; and that the library base variable is stored as global data.

SETDATA	MACRO	;register
_data_h	set	$\1
	IFEQ	_data_h-$a6
_a6MODE	set	1
	ENDC
	ENDM

;===============================
; Using library-dependent macros
;===============================

XMACRO	MACRO	;base,macro,parameters...
_xmMODE	set	0
	IFD	_data_h
_xmMODE	set	1
	ENDC
	IFC	'\1','AbsExec'
_xmMODE	set	0
	ENDC
	IFNE	_a6MODE
	movem.l	a6,-(sp)
	ENDC
	IFEQ	_xmMODE
	move.l	_\1Base,a6
	ELSEIF

	IFEQ	_data_h-$A4
	move.l	_\1Base(a4),a6
	ENDC
	IFEQ	_data_h-$A5
	move.l	_\1Base(a5),a6
	ENDC
	IFEQ	_data_h-$A6
	move.l	_\1Base(a6),a6
	ENDC

	ENDC
	\2	\3,\4,\5,\6,\7,\8,\9,\A,\B,\C
	IFNE	_a6MODE
	movem.l	(sp)+,a6
	ENDC
	ENDM

;=========================
; Calling library routines
;=========================
;
; Please note the difference between BSRSYS and BSREXEC -
; BSREXEC uses the pointer at address 4. Therefore it will work on all
;	machines, however, a specific version number cannot be relied
;	upon.
; BSRSYS, on the other hand, relies on the existance of a data-relative
;	variable called _SysBase, and therefore can be made to use
;	a specific version of the library.
;
; The simple macro CALL is very useful, if a6 is already correct.

;
; Call a function from any library, given a6 correct
;
CALL	MACRO	;function
	jsr	_LVO\1(a6)
	ENDM

;
; Call a function from various other miscellaneous libraries
;
BSRARP	MACRO
	XMACRO	Arp,CALL,\1		arp.library
	ENDM

BSRASL	MACRO
	XMACRO	Asl,CALL,\1		asl.library
	ENDM

BSRCX	MACRO
	XMACRO	Cx,CALL,\1		commodities.library
	ENDM

BSRFONT	MACRO
	XMACRO	DiskFont,CALL,\1	diskfont.library
	ENDM

BSRDOS	MACRO
	XMACRO	DOS,CALL,\1		dos.library
	ENDM

BSREARTH MACRO
	XMACRO	Earth,CALL,\1		earth.library
	ENDM

BSREXEC	MACRO
	IFGE	_LVO\1-_LVOCopyMemQuick
	XMACRO	AbsExec,CALL,\1		exec.library (from _AbsExecBase)
	ELSEIF
	FAIL	Function unavailable under WB1.2
	ENDC
	ENDM

BSRSYS	MACRO
	XMACRO	Sys,CALL,\1		exec.library (from _SysBase)
	ENDM

BSREXP	MACRO
	XMACRO	Expansion,CALL,\1	expansion.library
	ENDM

BSRGAD	MACRO
	XMACRO	GadTools,CALL,\1	gadtools.library
	ENDM

BSRGFX	MACRO
	XMACRO	GfxBase,CALL,\1		graphics.library
	ENDM

BSRICON	MACRO
	XMACRO	Icon,CALL,\1		icon.library
	ENDM

BSRIFF	MACRO
	XMACRO	IFFParse,CALL,\1	iffparse.library
	ENDM

BSRINT	MACRO
	XMACRO	Intuition,CALL,\1	intuition.library
	ENDM

BSRKMAP	MACRO
	XMACRO	Keymap,CALL,\1		keymap.library
	ENDM

BSRLAYER MACRO
	XMACRO	Layers,CALL,\1		layers.library
	ENDM

BSRMFB	MACRO
	XMACRO	Math,CALL,\1		mathffp.library
	ENDM

BSRMIDB	MACRO
	XMACRO	MathIeeeDoubBas,CALL,\1	mathieeedoubbas.library
	ENDM

BSRMIDT	MACRO
	XMACRO	MathIeeeDoubTrans,CALL,\1 mathieeedoubtrans.library
	ENDM

BSRMISB	MACRO
	XMACRO	MathIeeeSingBas,CALL,\1	mathieeesingbas.library
	ENDM

BSRMIST	MACRO
	XMACRO	MathIeeeSingTrans,CALL,\1 mathieeesingtrans.library
	ENDM

BSRMTB	MACRO
	XMACRO	MathTrans,CALL,\1	mathtrans.library
	ENDM

BSROBJ	MACRO
	XMACRO	Object,CALL,\1		object.library
	ENDM

BSRREXX	MACRO
	XMACRO	RexxSys,CALL,\1		rexxsyslib.library
	ENDM

BSRTRANS MACRO
	XMACRO	Translator,CALL,\1	translator.library
	ENDM

BSRUTIL	MACRO
	XMACRO	Utility,CALL,\1		utility.library
	ENDM

BSRWB	MACRO
	XMACRO	Workbench,CALL,\1	workbench.library
	ENDM

;===========================================
; Automatic opening and closing of libraries
;===========================================
;
; Usage of this macro is as follows:
;	LIBRARY basename,libname[,version[,OPT]]
; where:
;	basename is the name of the library base variable, eg. _DOSBase
;	libname is the name of the library itself, eg. dos.library
;	version is the (optional) version number required
;	OPT is a special keyword which, if present, will prevent the
;		program from aborting if the library would not open.

LIBRARY	MACRO
	section	LIBRARIES,DATA
\1	dc.l	\1_libinfo
	section LIBINFO,DATA
	IFC	'\3',''
__version__	set	0
	ELSEIF
__version__	set	\3
	ENDC
	IFC	'\4','OPT'
__libmask__	set	$80000000
	ELSEIF
__libmask__	set	0
	ENDC
	even
\1_libinfo
	dc.l	__libmask__|__version__
	dc.b	'\2',0
	ENDM

;==============
; Constant data
;==============
;
; If you use constant (ie. read-only) variables when using EarthMagic,
; then you should use the following macros.

CONSTANT MACRO	;name
	SECTION	CONSTANT\1,DATA
	ENDM

CONSTANT_C MACRO ;name
	SECTION	CONSTANT\1,DATA_C
	ENDM

CONSTANT_F MACRO ;name
	SECTION	CONSTANT\1,DATA_F
	ENDM

;============
; Remote data
;============
;
; If you use remote variables when using EarthMagic,
; then you should use the following macros.

UREMOTE	MACRO	;name,size[,requirements]
	SECTION	REMOTE,DATA
\1	dc.l	_R1_\1
	SECTION	\1,DATA
_R1_\1	dc.l	\2
	dc.l	0
	IFC	'\3',''
	dc.l	0
	ELSEIF
	dc.l	\3
	ENDC
	ENDM

IREMOTE	MACRO	;name[,requirements]
	SECTION	REMOTE,DATA
\1	dc.l	_R1_\1
	SECTION	\1,DATA
_R1_\1	dc.l	_R2_\1-_R1_\1
	dc.l	_R2_\1-_R1_\1
	IFC	'\2',''
	dc.l	0
	ELSEIF
	dc.l	\2
	ENDC
	ENDM

ENDREM	MACRO	;name
_R2_\1	;
	ENDM

;=====================
; Automatic variables
;====================
;
; If you use automatic (ie. on the stack) variables, then you need
; to keep track of how much is on the stack at all times.
; These macros will help you achieve this.

SPRESET	MACRO
SPCOUNT	set	0
	ENDM

SPADD	MACRO
	IFC	'\0','l'
SPCOUNT	set	SPCOUNT+4*(\1)
	ENDC
	IFC	'\0','L'
SPCOUNT	set	SPCOUNT+4*(\1)
	ENDC
	IFC	'\0','b'
SPCOUNT	set	SPCOUNT+\1
	ENDC
	IFC	'\0','B'
SPCOUNT	set	SPCOUNT+\1
	ENDC
	IFC	'\0',''
SPCOUNT	set	SPCOUNT+2*(\1)
	ENDC
	IFC	'\0','w'
SPCOUNT	set	SPCOUNT+2*(\1)
	ENDC
	IFC	'\0','W'
SPCOUNT	set	SPCOUNT+2*(\1)
	ENDC
	ENDM

SPSUB	MACRO	;numregs
	SPADD.\0 -(\1)
	ENDM

	ENDC


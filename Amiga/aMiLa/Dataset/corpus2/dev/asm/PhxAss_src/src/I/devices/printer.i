 ifnd DEVICES_PRINTER_I
DEVICES_PRINTER_I set 1
*
*  devices/printer.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd EXEC_IO_I
 include "exec/io.i"
 endc

 DEVINIT
 DEVCMD PRD_READWRITE
 DEVCMD PRD_PRTCOMMAND
 DEVCMD PRD_DUMPRPORT
 DEVCMD PRD_QUERY

aRIS equ 0
aRIN equ 1
aIND equ 2
aNEL equ 3
aRI equ 4
aSGR0 equ 5
aSGR3 equ 6
aSGR23 equ 7
aSGR4 equ 8
aSGR24 equ 9
aSGR1 equ 10
aSGR22 equ 11
aSFC equ 12
aSBC equ 13
aSHORP0 equ 14
aSHORP2 equ 15
aSHORP1 equ 16
aSHORP4 equ 17
aSHORP3 equ 18
aSHORP6 equ 19
aSHORP5 equ 20
aDEN6 equ 21
aDEN5 equ 22
aDEN4 equ 23
aDEN3 equ 24
aDEN2 equ 25
aDEN1 equ 26
aSUS2 equ 27
aSUS1 equ 28
aSUS4 equ 29
aSUS3 equ 30
aSUS0 equ 31
aPLU equ 32
aPLD equ 33
aFNT0 equ 34
aFNT1 equ 35
aFNT2 equ 36
aFNT3 equ 37
aFNT4 equ 38
aFNT5 equ 39
aFNT6 equ 40
aFNT7 equ 41
aFNT8 equ 42
aFNT9 equ 43
aFNT10 equ 44
aPROP2 equ 45
aPROP1 equ 46
aPROP0 equ 47
aTSS equ 48
aJFY5 equ 49
aJFY7 equ 50
aJFY6 equ 51
aJFY0 equ 52
aJFY3 equ 53
aJFY1 equ 54
aVERP0 equ 55
aVERP1 equ 56
aSLPP equ 57
aPERF equ 58
aPERF0 equ 59
aLMS equ 60
aRMS equ 61
aTMS equ 62
aBMS equ 63
aSTBM equ 64
aSLRM equ 65
aCAM equ 66
aHTS equ 67
aVTS equ 68
aTBC0 equ 69
aTBC3 equ 70
aTBC1 equ 71
aTBC4 equ 72
aTBCALL equ 73
aTBSALL equ 74
aEXTEND equ 75
aRAW equ 76

* struct IOPrtCmdReq
 rsset io_SIZE
io_PrtCommand	rs.w 1
io_Parm0	rs.b 1
io_Parm1	rs.b 1
io_Parm2	rs.b 1
io_Parm3	rs.b 1
iopcr_SIZEOF	rs

* struct IODRPReq
 rsset io_SIZE
io_RastPort	rs.l 1
io_ColorMap	rs.l 1
io_Modes	rs.l 1
io_SrcX 	rs.w 1
io_SrcY 	rs.w 1
io_SrcWidth	rs.w 1
io_SrcHeight	rs.w 1
io_DestCols	rs.l 1
io_DestRows	rs.l 1
io_Special	rs.w 1
iodrpr_SIZEOF	rs

SPECIAL_MILCOLS equ 1
SPECIAL_MILROWS equ 2
SPECIAL_FULLCOLS equ 4
SPECIAL_FULLROWS equ 8
SPECIAL_FRACCOLS equ 16
SPECIAL_FRACROWS equ 32
SPECIAL_CENTER equ 64
SPECIAL_ASPECT equ 128
SPECIAL_DENSITY1 equ $100
SPECIAL_DENSITY2 equ $200
SPECIAL_DENSITY3 equ $300
SPECIAL_DENSITY4 equ $400
SPECIAL_DENSITY5 equ $500
SPECIAL_DENSITY6 equ $600
SPECIAL_DENSITY7 equ $700
SPECIAL_NOFORMFEED equ $800
SPECIAL_TRUSTME equ $1000
SPECIAL_NOPRINT equ $2000
SPECIAL_DENSITYMASK equ $700
SPECIAL_DIMENSIONSMASK equ $bf

PDERR_NOERR equ 0
PDERR_CANCEL equ 1
PDERR_NOTGRAPHICS equ 2
PDERR_INVERTHAM equ 3
PDERR_BADDIMENSION equ 4
PDERR_DIMENSIONOVFLOW equ 5
PDERR_INTERNALMEMORY equ 6
PDERR_BUFFERMEMORY equ 7
PDERR_TOOKCONTROL equ 8

 endc

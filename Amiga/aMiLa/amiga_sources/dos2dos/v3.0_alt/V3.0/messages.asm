*****************************************************************
*								*
*	Dos-2-Dos message strings				*
*								*
*	Feb 23, 1989						*
*								*
*****************************************************************

	XDEF	QuesTxt
	XDEF	HLPTEXT
	XDEF	HLPTEXTLEN
	XDEF	QuesTxtLen

	XDEF	CHIP_MEM.
	XDEF	BAD_ARGS.
	XDEF	DUP_DRV.
	XDEF	DUP_FILE.
	XDEF	DUP1.
	XDEF	DUP2.
	XDEF	NO_FILE.
	XDEF	BAD_NAME.
	XDEF	DRV_ERR.
	XDEF	DEV_ERR.
	XDEF	OPEN_ERR.
	XDEF	BAD_CMD.
	XDEF	NEW_NAME.
	XDEF	PAYN.
	XDEF	HOW_TO.
;;	XDEF	USERAM1.
;;	XDEF	USERAM2.
	XDEF	CLEAN.
	XDEF	PMORE.
	XDEF	EOF.
	XDEF	WHICH_DRIVE.
	XDEF	NO_DRV1.
	XDEF	NO_DRV2.
	XDEF	FMSG1.
	XDEF	FMSG2.
	XDEF	FormFail.
	XDEF	FormComp.
	XDEF	CPYING.
	XDEF	BREAK.
	XDEF	Deleting.
	XDEF	CANT_DEL.
	XDEF	BAD_DIR.
	XDEF	DISK_FULL.
	XDEF	DIR_FULL.
	XDEF	FILES.
	XDEF	BYTES.
	XDEF	DIR.
	XDEF	NotFlop.
	XDEF	BadFormat.
	XDEF	FMSG3.
	XDEF	DIR_OF.
	XDEF	SPACE.
	XDEF	SPACES.

	XDEF	WRITE_ERR.
	XDEF	DRV_NR.
	XDEF	READ_ERR.
	XDEF	PROT.
	XDEF	NoTimer.
	XDEF	YES.,NO.

YES.	DC.B	3,'YES'
NO.	DC.B	2,'NO'

QuesTxt:
	DC.B	13,10
	DC.B	'D2D drive: command',13,10
	DC.B	'Example: D2D DF2: COPY DF2:*.BAT -A -R',13,10

HLPTEXT:
	DC.B	13,10
	DC.B	'        Dos-2-Dos Command Summary:',13,10,10
	DC.B	'  Display directory............. DIR or DIR drive:path',13,10
	DC.B	'  Change current directory...... CHDIR drive:path',13,10
	DC.B	'  Display ASCII file contents... TYPE drive:path\file',13,10
	DC.B	'  Copy a file (general form).... COPY drive:path\file drive:path/file -A -R',13,10
	DC.B	'  Copy one ASCII file........... COPY DF2:MYFILE.ASM DF0:C/NEWFILE.ASM -A',13,10
	DC.B	'  Copy MS-DOS/Atari files....... COPY DF2:*.ASM',13,10
	DC.B	'  Copy AmigaDOS files........... COPY #?.ASM',13,10
	DC.B	'  Copy and convert ASCII files.. add -A to COPY command line',13,10
	DC.B	'  Suppress ''Replace?'' question.. add -R to COPY command line',13,10
	DC.B	'  Delete a file................. DELETE drive:path\file',13,10
	DC.B	'  Format an MS-DOS DSDD disk.... FORMAT',13,10
	DC.B	'  Format an Atari ST DSDD disk.. FORMAT /A',13,10 
	DC.B	'  Display this summary.......... HELP, or ?',13,10
	DC.B	'  Select another MS-DOS drive... RESTART',13,10
	DC.B	'  Exit to AmigaDOS.............. EXIT, or X',13,10
HLPTEXTLEN	EQU *-HLPTEXT
QuesTxtLen	EQU *-QuesTxt

CHIP_MEM.	DC.B	13,'Out of memory'
BAD_ARGS.	DC.B	13,'Bad arguments'
DUP_DRV.	DC.B	48,'Source and destination drives cannot be the same'
DUP_FILE.	DC.B	46,'Destination file already exists.  Replace it? '
DUP1.		DC.B	6,'File "'
DUP2.		DC.B	31,'" already exists.  Replace it? '
NO_FILE.	DC.B	20,'Can''t find that file'
BAD_NAME.	DC.B	24,'Invalid MS-DOS file name'
DRV_ERR.	DC.B	31,'Device not defined in Mountlist'
DEV_ERR.	DC.B	36,'Unable to locate that device or file'
OPEN_ERR.	DC.B	30,'Unable to create AmigaDOS file'
BAD_CMD.	DC.B	48,'Unknown command.  Type HELP for command summary.'
NEW_NAME.	DC.B	37,'Please enter a new MS-DOS file name: '
PAYN.		DC.B	27,'Please answer "yes" or "no"'
HOW_TO.		DC.B	49,'Type HELP or ? for summary of Dos-2-Dos commands.'
;;USERAM1.	DC.B	55,'Warning -- you cannot use DF0 to access AmigaDOS files.'
;;USERAM2.	DC.B	50,'Use RAM: or an external floppy drive.  See Manual.'
CLEAN.		DC.B	4,$9B,$46,$9B,$4B	;erase preceeding line
PMORE.		DC.B	57,27,'[33mPress Return for more, press ESC Return to '
		DC.B	'exit.',27,'[0m'
EOF.		DC.B	38,10,13,27,'[33mEnd of file.  Press Return.',27,'[0m'

WHICH_DRIVE. 	DC.B	52
	DC.B 'Enter the device to be used for MS-DOS/ATARI files: '
NO_DRV1. 	DC.B 61
	DC.B 'Your Amiga auto-configuration equipment list doesn''t include '
NO_DRV2.	DC.B 61
	DC.B 'Dos-2-Dos assumes it is a non-Amiga external 5.25-inch drive.'

FMSG1.		DC.B	27,'Insert diskette into drive '
FMSG2.		DC.B	29,' and press RETURN when ready.'
FormFail.	DC.B	31,'Write error; formatting failed.'
FormComp.	DC.B	20,'Formatting complete.'
CPYING.		DC.B	10,'  Copying '
BREAK.		DC.B	8,'***Break'
Deleting.	DC.B	11,'  Deleting '

CANT_DEL.	DC.B	22,'Can''t delete that file'
BAD_DIR.	DC.B	17,'Invalid directory'
DISK_FULL.	DC.B	22,'MS-DOS/Atari disk full'
DIR_FULL.	DC.B	27,'MS-DOS/Atari directory full'
FILES.		DC.B	12,' file(s),   '
BYTES.		DC.B	11,' bytes free'
DIR.		DC.B	8,'  <DIR> '
NotFlop.	DC.B	32,'Can''t format - not a floppy disk'
BadFormat.	DC.B	29,'Not valid MS-DOS/Atari format'
FMSG3.		DC.B	18,13,'Formatting track '
DIR_OF. 	DC.B	14,'Directory of  '
SPACE.		DC.B	1,' '
SPACES. 	DC.B	2,'  '

WRITE_ERR.	DC.B	30,'MS-DOS/Atari disk write error'
DRV_NR. 	DC.B	28,'MS-DOS/Atari drive not ready'
READ_ERR. 	DC.B	29,'MS-DOS/Atari drive read error'
PROT. 		DC.B	36,'MS-DOS/Atari disk is write protected'
NoTimer.	DC.B	23,'Can''t open timer device'


	END

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
	XDEF	USERAM1.
	XDEF	USERAM2.
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

QuesTxt:
	DC.B	13,10
;	DC.B	'D2D drive: command',13,10
	DC.B	'D2D diskettenhet: kommando',13,10
;	DC.B	'Example: D2D DF2: COPY DF2:*.BAT -A -R',13,10
	DC.B	'Exempel: D2D DF2: COPY DF2:*.BAT -A -R',13,10

HLPTEXT:
	DC.B	13,10
;	DC.B	'        Dos-2-Dos Command Summary:',13,10,10
	DC.B	'        Dos-2-Dos Kommandosummering:',13,10,10
;	DC.B	' Display directory............. DIR or DIR drive:path',13,10
	DC.B	' Visa katalog................... DIR eller DIR enhet:sökväg',13,10
;	DC.B	' Change current directory...... CHDIR drive:path',13,10
	DC.B	' Ändra aktuell katalog.......... CHDIR enhet:sökväg',13,10
;	DC.B	' Display ASCII file contents... TYPE drive:path\file',13,10
	DC.B	' Visa ASCII-fil................. TYPE enhet:sökväg\fil',13,10
;	DC.B	' Copy a file (general form).... COPY drive:path\file drive:path/file -A -R',13,10
	DC.B	' Kopiera en fil (allmän form)... COPY enhet:sökväg\fil enhet:sökväg/fil -A -R',13,10
;	DC.B	' Copy one ASCII file........... COPY DF2:MYFILE.ASM DF0:C/NEWFILE.ASM -A',13,10
	DC.B	' Kopiera en ASCII-fil........... COPY DF2:MINFIL.ASM DF0:C/NYFIL.ASM -A',13,10
;	DC.B	' Copy MS-DOS/Atari files....... COPY DF2:*.ASM',13,10
	DC.B	' Kopiera MS-DOS/ATARI-filer..... COPY DF2:*.ASM',13,10
;	DC.B	' Copy AmigaDOS files........... COPY #?.ASM',13,10
	DC.B	' Kopiera AmigaDOS-filer......... COPY DF2:#?.ASM',13,10
;	DC.B	' Copy and convert ASCII files.. add -A to COPY command line',13,10
	DC.B	' Kopiera/konvertera ASCII-filer. lägg till -A på COPY-raden',13,10
;	DC.B	' Suppress ''Replace?'' question.. add -R to COPY command line',13,10
	DC.B	' Bekräfta ej vid "Ersätta?"..... lägg till -R på COPY-raden',13,10
;	DC.B	' Delete a file................. DELETE drive:path\file',13,10
	DC.B	' Radera en fil.................. DELETE enhet:sökväg\fil',13,10
;	DC.B	' Format an MS-DOS DSDD disk.... FORMAT',13,10
	DC.B	' Formattera DSDD MS-DOSdiskett.. FORMAT',13,10
;	DC.B	' Format an Atari ST DSDD disk.. FORMAT /A',13,10 
	DC.B	' Formattera DSDD AtariSTdiskett. FORMAT /A',13,10
;	DC.B	' Display this summary.......... HELP, or ?',13,10
	DC.B	' Visa denna summering........... ?',13,10
;	DC.B	' Select another MS-DOS drive... RESTART',13,10
	DC.B	' Byt till en annan MS-DOS-enhet. RESTART',13,10
;	DC.B	' Exit to AmigaDOS.............. EXIT, or X',13,10
	DC.B	' Avsluta programmet............. EXIT, eller X',13,10
HLPTEXTLEN	EQU *-HLPTEXT
QuesTxtLen	EQU *-QuesTxt

CHIP_MEM.	;DC.B	13,'Out of memory'
		DC.B	13,'Ej nog minne.'
BAD_ARGS.	;DC.B	13,'Bad arguments'
		DC.B	13,'Fel argument.'
DUP_DRV.	;DC.B	48,'Source and destination drives cannot be the same'
		DC.B	51,'Utgåangs och destinationsenhet kan inte vara samma.'
DUP_FILE.	;DC.B	46,'Destination file already exists.  Replace it? '
		DC.B	48,'Destinationsfilen existerar redan. Ersätta den? '
DUP1.		;DC.B	6,'File "'
		DC.B	7,'Filen "'
DUP2.		;DC.B	31,'" already exists.  Replace it? '
		DC.B	32,'" existerar redan. Ersätta den? '
NO_FILE.	;DC.B	20,'Can''t find that file'
		DC.B	23,'Kan ej hitta den filen.'
BAD_NAME.	;DC.B	24,'Invalid MS-DOS file name'
		DC.B	25,'Otillåtet MS-DOS filnamn.'
DRV_ERR.	;DC.B	31,'Device not defined in Mountlist'
		DC.B	34,'Enheten ej definierad i Mountlist.'
DEV_ERR.	;DC.B	36,'Unable to locate that device or file'
		DC.B	37,'Kan ej hitta den enheten eller filen.'
OPEN_ERR.	;DC.B	30,'Unable to create AmigaDOS file'
		DC.B	28,'Kan ej skapa AmigaDos-filen.'
BAD_CMD.	;DC.B	48,'Unknown command.  Type HELP for command summary.'
		DC.B	54,'Okänt kommando. Skriv "?" för summering av kommandona.'
NEW_NAME.	;DC.B	37,'Please enter a new MS-DOS file name: '
		DC.B	30,'Ange ett nytt MS-DOS filnamn: '
PAYN.		;DC.B	27,'Please answer "yes" or "no"'
		DC.B	22,'Ange "ja" eller "nej".'
YES.		DC.B	2,'JA'
NO.		DC.B	3,'NEJ'
HOW_TO.		;DC.B	49,'Type HELP or ? for summary of Dos-2-Dos commands.'
		DC.B	48,'Skriv "?" för summering av Dos-2-Dos kommandona.'
USERAM1.	;DC.B	55,'Warning -- you cannot use DF0 to access AmigaDOS files.'
		DC.B	54,'Varning -- du kan inte använda DF0 för AmigaDOS-filer.'
USERAM2.	;DC.B	50,'Use RAM: or an external floppy drive.  See Manual.'
		DC.B	39,'Använd RAM: eller an extern diskettenhet.'
CLEAN.		DC.B	4,$9B,$46,$9B,$4B	;erase preceeding line
PMORE.		;DC.B	57,27,'[33m'
		;DC.B	'Press Return for more, press ESC Return to exit.'
		;DC.B	27,'[0m'
		DC.B	58,27,'[33m'
		DC.B	'Tryck på RETUR för mer eller ESC för att avsluta.'
		DC.B	27,'[0m'
EOF.		;DC.B	38,10,13,27,'[33m'
		;DC.B	'End of file.  Press Return.'
		;DC.B	27,'[0m'
		DC.B	38,10,13,27,'[33m'
		DC.B	'Slut på filen. Tryck RETUR.'
		DC.B	27,'[0m'

WHICH_DRIVE. 	DC.B	48
	;DC.B 'Enter the device to be used for MS-DOS/ATARI files: '
	DC.B 'Ange enhet att användas för MS-DOS/ATARI-filer: '
NO_DRV1. 	DC.B 59
	;DC.B 'Your Amiga auto-configuration equipment list doesn''t include '
	DC.B 'Din Amigas autokonfigurerade tillbehörslista inkluderar ej '
NO_DRV2.	DC.B 60
;	DC.B 'Dos-2-Dos assumes it is a non-Amiga external 5.25-inch drive.'
	DC.B 'Dos-2-Dos antar att det är en icke-Amiga 5.25" diskettenhet.'

FMSG1.		;DC.B	27,'Insert diskette into drive '
		DC.B	35,'Mata in disketten i diskettenheten '
FMSG2.		;DC.B	29,' and press RETURN when ready.'
		DC.B	26,' och tryck därefter RETUR.'
FormFail.	;DC.B	31,'Write error; formatting failed.'
		DC.B	38,'Skrivfel: formatteringen misslyckades.'
FormComp.	;DC.B	20,'Formatting complete.'
		DC.B	24,'Formatteringen komplett.'
CPYING.		;DC.B	10,'  Copying '
		DC.B	11,'  Kopeirar '
BREAK.		;DC.B	8,'***Break'
		DC.B	10,'***Avbrott'
Deleting.	;DC.B	11,'  Deleting '
		DC.B	10,'  Raderar '

CANT_DEL.	;DC.B	22,'Can''t delete that file'
		DC.B	23,'Kan ej radera den filen.'
BAD_DIR.	;DC.B	17,'Invalid directory'
		DC.B	18,'Otillåten katalog.'
DISK_FULL.	;DC.B	22,'MS-DOS/Atari disk full'
		DC.B	21,'MS-DOS-disketten full.'
DIR_FULL.	;DC.B	27,'MS-DOS/Atari directory full'
		DC.B	21,'MS-DOS-katalogen full.'
FILES.		;DC.B	12,' file(s),   '
		DC.B	12,' fil(er),   '
BYTES.		;DC.B	11,' bytes free'
		DC.B	13,' bytes lediga'
DIR.		;DC.B	8,'  <DIR> '
		DC.B	8,'  <KAT> '
NotFlop.	;DC.B	32,'Can''t format - not a floppy disk'
		DC.B	33,'Kan ej formattera - ej en diskett.'
BadFormat.	;DC.B	29,'Not valid MS-DOS/Atari format'
		DC.B	32,'Ej korrekt MS-DOS diskettformat.'
FMSG3.		;DC.B	18,13,'Formatting track '
		DC.B	18,13,'Formatterar spår '
DIR_OF. 	;DC.B	14,'Directory of  '
		DC.B	14,'Katalog över  '
SPACE.		DC.B	1,' '
SPACES. 	DC.B	2,'  '

WRITE_ERR.	;DC.B	30,'MS-DOS/Atari disk write error'
		DC.B	29,'Skrivfel på MS-DOS-disketten.'
DRV_NR. 	;DC.B	28,'MS-DOS/Atari drive not ready'
		DC.B	30,'MS-DOS-diskettenheten ej klar.'
READ_ERR. 	;DC.B	29,'MS-DOS/Atari drive read error'
		DC.B	27,'Läsfel på MS-DOS-disketten.'
PROT. 		;DC.B	36,'MS-DOS/Atari disk is write protected'
		DC.B	39,'MS-DOS-disketten är skrivskyddad.'
NoTimer.	;DC.B	23,'Can''t open timer device'
		DC.B	27,'Kan ej öppna "timer device".'


	END

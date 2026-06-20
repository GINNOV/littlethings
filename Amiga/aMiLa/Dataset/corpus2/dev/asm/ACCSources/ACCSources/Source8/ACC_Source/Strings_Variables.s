*****************************************************************************
*******************************  CONSTANTS  *********************************
*****************************************************************************

; Data defenition area

Console_name:
		dc.b		'console.device',0
		EVEN

printername	dc.b		'prt:',0
		EVEN

Run_comm	dc.b		'ram:source',0
		EVEN
Run_arg		dc.b		$0a,0
default_CON	dc.b		'con:0/11/640/200/Default_Window',0

Asm_comm	dc.b		'ram:source.s -iclub8:include -d',0
Link_comm	dc.b		'ram:source.o to '
AsmPBuffer	dcb.b		32,0

ramname		dc.b		'ram:source.s',0
objname		dc.b		'ram:source.o',0
asm_CON		dc.b		'con:0/11/640/200/Assembling',0
AsmMemName	dc.b		'ram:source',0
		EVEN
A68k_name	dc.b		'club8:c/A68k',0
Blink_name	dc.b		'club8:c/Blink',0
		EVEN
status_text2	dc.b	'Line: %4ld      Col: %4ld      Message: %-32.32s',0
		EVEN

*****************************************************************************		
; Messages displayed in console windows

mb_msg		dc.b		$0a,' ACC Message: PRESS LEFT MOUSE BUTTON TO CONTINUE.'
mb_len		equ		*-mb_msg
		even
*****************************************************************************


; ACC messages for the status line.
;				'                               '
status_msg0	dc.b		'OK.',0
		even

status_msg1	dc.b		'No file loaded.',0
		even
		
status_msg2	dc.b		'Top of file.',0
		even
		
status_msg3	dc.b		'Bottom of file.',0
		even
		
status_msg4	dc.b		'Invalid line number.',0
		even

status_msg5	dc.b		'String not found.',0
		even
		
status_msg6	dc.b		'Text file larger than buffer.',0
		even

status_msg7	dc.b		'No pathname selected.',0
		even

status_msg8	dc.b		'No memory for file info block.',0
		even
		
status_msg9	dc.b		'Could not Lock file.',0
		even
		
status_msg10	dc.b		'Could not open Input file.',0
		even
		
status_msg11	dc.b		'Could not open Output file.',0
		even
		
status_msg12	dc.b		'Could not open Assembly window.',0
		even
		
status_msg13	dc.b		'Could not open Default window.',0
		even
		
status_msg14	dc.b		'Could not open Printer Device.',0
		even


status_msg20	dc.b		'Function not yet implemented.',0
		even

;***********************************************************
;		Cursor IText Structures
;***********************************************************

curline_text	dc.b	1,0	colours to use
		dc.b	RP_JAM2	mode to use
		dc.b	0
		dc.w	0,0	text position in window
		dc.l	0	font to use (standard)
curline.ptr	dc.l	0	pointer to text
		dc.l	0

cur_text	dc.b	3,0	colours to use
		dc.b	RP_JAM2	mode to use
		dc.b	0
		dc.w	0,0	text position in window
		dc.l	0	font to use (standard)
		dc.l	cursor	pointer to text
		dc.l	0	end of text list

cursor		dc.b	' ',0
		even

;***********************************************************
;		File Requester Names
;***********************************************************

Requesterflags	EQU	0

;------	This is the text for requesters title

LoadText	dc.b	'Load File ',0

SaveText	dc.b	'Save File ',0

InsertTitle	dc.b	'Insert File ',0
		EVEN

;***********************************************************
	SECTION	Variables,BSS
;***********************************************************
; Variables 

_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_ArpBase	ds.l		1
stack		ds.l		1




		rsreset

script_handle	rs.l		1
old_size	rs.l		1
window.ptr	rs.l		1		window struct pointer
window.rp	rs.l		1		window rastport pointer
window.up	rs.l		1		windows userport pointer
start_line	rs.l		1		address of 1st line on screen
start_line_num	rs.l		1		number of 1st line
start_col_num	rs.l		1
num_lines	rs.l		1		number of lines in file
cur_addr	rs.l		1		addr in edit buffer of cur
cur_pos		rs.l		1		num of bytes into edit buffer
cur_line	rs.l		1		addr of line at cursor
cur_line_num	rs.l		1		number of line at cursor
cur_line_len	rs.l		1		len of edit buffer
cur_x		rs.l		1		screen x position of cursor
cur_y		rs.l		1		screen y position of cursor
max_curx	rs.l		1		max value cur_x may take
temp		rs.l		1		scratch register
scrn_width	rs.l		1		width of screen for scroll
scrn_size	rs.l		1		lines on screen
text_size	rs.l		1		size of text file ( bytes )
msg1		rs.b		500		buffer for printing
font.height	rs.l		1		height of win font
font.width	rs.l		1		width of win font
linespace	rs.w		1
LastItem	rs.l		1
itn		rs.w		1
line.ptr	rs.l		1
linenum		rs.l		1		text y position	
about.ptr	rs.l		1
status_msg.ptr	rs.l		1
print_start	rs.l		1
print_size	rs.l		1
quit_flag	rs.w		1
asm_handle	rs.l		1
default_handle	rs.l		1
Load_handle	rs.l		1
Save_handle	rs.l		1
file_info	rs.l		1
file_lock	rs.l		1
AsmP.ptr	rs.l		1
A68k_Seg	rs.l		1
Blink_Seg	rs.l		1
changes		rs.l		1		flag if file is alterd
line_changes	rs.l		1		flag if line is alterd
edit_buffer	rs.b		256		holds line being edited

node		rs.l		1

start_list	rs.l		1
		rs.l		1
		rs.b		1
		
		rs.b		1		make pc even
		
end_list	rs.l		1
		rs.l		1
		rs.b		1
		
		rs.b		1		make pc even
		
handle		rs.l		1
filehd		rs.l		1
copy_buf	rs.l		1
read_buf	rs.l		1


status_text	rs.b		72

LoadFileStruct	rs.b	fr_SIZEOF+4	space for load filerequest struct

SaveFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct

InsertFileStruct rs.b	fr_SIZEOF+4	space for insert filerequest struct

LoadFileData	rs.b	FCHARS+2	;reserve space for filename buffer

LoadDirData	rs.b	DSIZE+1		;reserve space for path buffer

SaveFileData	rs.b	FCHARS+2	;reserve space for filename buffer

SaveDirData	rs.b	DSIZE+1		;reserve space for path buffer

InsertFileData	rs.b	FCHARS+2

InsertDirData	rs.b	DSIZE+1

LoadPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

SavePathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

InsertPathName	rs.b	DSIZE+FCHARS+3

PrCtrlBlk	rs.b	pcb_Sizeof

Zombie_Message	rs.b	zm_SIZEOF

Console_StdIO	rs.b	IOSTD_SIZE

Console_IOEvent	rs.b	ie_SIZEOF

ConvertBuffer	rs.b	BuffSize+2
		
BSS_Size	rs.b	0

 ;This is the assembly language INCLUDE file for the FileIO requester

; The file IO which is returned by GetFileIO() looks like this
;
;  The FileIO structure (264 bytes):
;FileIO dc.w  0      ;Flags WORD
;       ds.b  30     ;FileName buffer (contents must be NULL terminated)
;       ds.b  132    ;DrawerName buffer
;       ds.b  30     ;DiskName buffer
;       dc.l   0     ;DOS filehandle lock
;       dc.w   0     ;NameCount (total # of filenames in filename list)
;       dc.w   0     ;NameStart (ID of filename in top "select name" display)
;       dc.w   0     ;CurrentPick (ID of filename selected and highlighted)
;       dc.l NameKey ;address of Remember structure for filename list
;       dc.w   0     ;VolumeIndex (ID of current disk being examined)
;       dc.w   0     ;VolumeCount (total # of DOS disk devices in disk list)
;       dc.l VolKey  ;address of Remember structure for disk list
;the next 2 fields are for WB pattern match (i.e. Icon files displayed only)
;       dc.w   0     ;DiskObjectType to match
;       dc.l   0     ;ToolTypes string address to match
;       dc.l   0     ;address of extension string to match
;       dc.w   0     ;size of extension string
;       dc.l   0     ;address of CustomHandler structure
;       dc.w   0     ;X position of the requester
;       dc.w   0     ;Y position of the requester
;       dc.l   0     ;free bytes on current disk
;       dc.l   0     ;bytesize of selected file (or 0 if the file doesn't exist yet)
;       dc.l   0     ;WindowTitle
;       dc.l   0     ;Buffer
;       dc.l   0     ;Rawkey Code
;       dc.l   0     ;OriginalLock (do not alter)
;       dc.b   0     ;Error number
;       dc.b   0     ;DrawMode
;       dc.b   0     ;PenA
;       dc.b   0     ;PenB

; so here are the offsets from the base for each field:

FILEIO_FLAGS     equ 0
FILEIO_FILENAME  equ 2
FILEIO_DRAWER    equ 32
FILEIO_DISK      equ 164
FILEIO_LOCK      equ 194
FILEIO_NAMECOUNT equ 198
FILEIO_NAMESTART equ 200
FILEIO_CURRPICK  equ 202
FILEIO_FILELIST  equ 204
FILEIO_VOLINDEX  equ 208
FILEIO_VOLCOUNT  equ 210
FILEIO_VOLLIST   equ 212
FILEIO_MATCHTYPE equ 216
FILEIO_TOOLTYPES equ 218
FILEIO_EXTENSION equ 222
FILEIO_EXTSIZE   equ 226
FILEIO_CUSTOM    equ 228
FILEIO_X         equ 232
FILEIO_Y         equ 234
FILEIO_FREEBYTES equ 236
FILEIO_FILESIZE  equ 240
FILEIO_TITLE     equ 244
FILEIO_BUFFER    equ 248
FILEIO_RAWCODE   equ 252
FILEIO_ORIGINALLOCK equ 256
FILEIO_ERRNO     equ 260
FILEIO_DRAWMODE  equ 261
FILEIO_PENA      equ 262
FILEIO_PENB      equ 263

SIZEOF_FILEIO    equ 264

;  So, to access the FileIO's Tooltypes field, you can do this
;
;move.l  myFileIO,a0             ;the base returned from GetFileIO()
;move.l  FILEIO_TOOLTYPES(a0),d0 ;get the value in this field

; Here the the flag bit numbers

NO_CARE_REDRAW   equ 0
USE_DEVICE_NAMES equ 1
EXTENSION_MATCH  equ 2
DOUBLECLICK_OFF  equ 3
WBENCH_MATCH     equ 4
MATCH_OBJECTTYPE equ 5
MATCH_TOOLTYPE   equ 6
INFO_SUPPRESS    equ 7

ALLOCATED_FILEIO equ 8  ;NEVER alter this
CUSTOM_HANDLERS  equ 9
WINDOW_OPENED    equ 10 ;NEVER alter this
TITLE_CHANGED    equ 11
DISK_HAS_CHANGED equ 13

; So to enable the USE_DEVICE_NAMES feature, do this
;
;movea.l  myFileIO,a0           ;the base
;move.w   FILEIO_FLAGS(a0),d0   ;get the current flags
;bset.l   #USE_DEVICE_NAMES,d0  ;enable this feature (clear the bit to disable)
;move.w   d0,FILEIO_FLAGS(a0)   ;save the new flags
 
 ;======= ERRNO numbers returned in FileIO error field =========

ERR_MANUAL  equ 1   ;the path was entered manually via the title bar with no
                    ;errors or cancellation.
ERR_SUCCESS equ 0   ;everything went OK in DoFileIO() or DoFileIOWindow()
ERR_CANCEL  equ -1  ;the filename procedure was CANCELED by the user
ERR_WINDOW  equ -2  ;the window couldn't open (in DoFileIOWindow())
ERR_APPGADG equ -3  ;the requester was CANCELED by an application gadget
                    ;(via an installed CUSTOM gadget handler returning TRUE)

 ;====== AutoFileMessage() numbers =========
ALERT_OUTOFMEM       equ  0
ALERT_BAD_DIRECTORY  equ  1
READ_WRITE_ERROR     equ  2 ; Error in reading or writing file
 ;The next 3 display "YES" and "NO" prompts, returning d0=1 for yes, 0 for no
FILE_EXISTS          equ  3 ; File already exists. Overwrite?
SAVE_CHANGES         equ  4 ; Changes have been made. Save them?
REALLY_QUIT          equ  5 ; Do you really want to quit?

 ;======FileIO library routine vector offsets from library base=====
_LVODoFileIOWindow  equ -30
_LVOGetFileIO       equ -36
_LVODoFileIO        equ -42
_LVOGetFullPathname equ -48
_LVOAutoFileMessage equ -54
_LVOReleaseFileIO   equ -60
_LVOAutoMessage     equ -66
_LVOSetWaitPointer  equ -72
_LVOResetBuffer     equ -78
_LVOAutoMessageLen  equ -84
_LVOAutoPrompt3     equ -90
_LVOUserEntry       equ -96
_LVOPromptUserEntry equ -102
_LVOGetRawkey       equ -108
_LVODecodeRawkey    equ -114
_LVOTypeFilename    equ -120
_LVOSetTitle        equ -126
_LVOResetTitle      equ -132
_LVOParseString     equ -138

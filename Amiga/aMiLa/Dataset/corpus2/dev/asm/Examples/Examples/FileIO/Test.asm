 ;====Uncomment these directives for MANX asm only!!
 ; far   code ;so that we can use register a4, and no limit on program size.
 ; far   data

 SMALLOBJ ;CAPE PC relative addressing substituted for absolute

 INCLUDE  "rad:FileIO.i"

 ;======Amiga Library routines======
   XREF    _LVOCloseLibrary,_LVOCloseScreen,_LVOCloseWindow,_LVOSetMenuStrip
   XREF    _LVOOpenWindow,_LVOOpenScreen,_LVOOpenLibrary
   XREF    _LVOGetMsg,_LVOReplyMsg,_LVOWait,_LVOMove,_LVOText
   XREF    _LVOSetAPen,_LVOSetBPen,_LVOSetDrMd

 ;======From the startup code======
   XREF    _SysBase,_DOSBase

 ;======From dissidents utilities lib
   XREF up_to_low_case_str,append

; This program opens and utilizes the requester library in order to obtain
; a full pathname string from the user. When the user clicks the right mouse
; button, the program calls TestFileIO which calls the library routine that
; does the entire requester operation. A menu is included in order to enable
; certain features such as:
; EXTENSION - Sets the FileIO's EXTENSION_MATCH flag so that only filenames
;             that end in a specified extension are matched. I have allowed
;             the user to type in the extension he wishes via the FileIO's
;             PromptUserEntry function (extension must be specified in lower
;             case).
; WORKBENCH - Gives workbench pattern matching (i.e. only .info files are
;             displayed but without the .info) A file not ending in .info is
;             ignored.
; DEVICE    - Uses device names (i.e. DF0:) instead of the disk's real name.
; CUSTOM    - Inserts a custom handler for the requester's StartUpHandler
;             which just displays an autorequester message.
; TYPENAME  - Uses the lib function TypeFilename to completely bypass the
;             file requester, and uses the titlebar instead.

; Any or all of these can be set simultaneously, but you should enable one
; at a time to see the actual effect.
; If running this program from the CLI and you specify any argument on the
; command (i.e.  1> TestFileIO blort ), then the window will open on a hires
; screen. You can then see what the requester looks like in hires.

LIB_VERSION equ 33

;  For Manx,   ln -o TestFileIO  ManxStartUp.o  main.o  cl32.lib
;
;  For Others, Blink StartUp.o main.o amiga.lib NODEBUG to TestFileIO

ExtBufSize equ 21  ;(30-1)-PromptLen

   SECTION FileIOTestCode,CODE

   XDEF   _main
_main:
    movem.l   d2-d7/a2-a6,-(sp)
    movea.l   _SysBase,a6
;======Open The Intuition Library=======
    moveq     #LIB_VERSION,d0
    lea       IntuitionName,a1
    jsr       _LVOOpenLibrary(a6)
    lea       _IntuitionBase,a4
    move.l    d0,(a4)+
    beq       C7
;======Open The Graphics Library========
    moveq     #LIB_VERSION,d0
    lea       GfxName,a1
    jsr       _LVOOpenLibrary(a6)
    move.l    d0,(a4)+
    beq       C6
;*******Open the "Brand New, Improved, Exciting" Requester library*********
    moveq     #0,d0            ;any version (for now)
    lea       RequesterName,a1
    jsr       _LVOOpenLibrary(a6)
    move.l    d0,(a4)+
    beq       C5
;=====If started from WBench, then don't open a CUSTOM screen
    movea.l   _IntuitionBase,a6
    move.l    52(sp),d0
    beq.s     .9
;=====If opened from CLI with any argument, then open CUSTOM screen
    subq.l    #2,48(sp)
    bcs.s     .9
    lea       newScreen,a0
    jsr       _LVOOpenScreen(a6)
    lea       newWindow,a0
   ;-----Window's Screen = ScreenPtr
    move.l    d0,30(a0)
    beq.s     .9A             ;If an error, forget the screen!
   ;-----Window's Type = CUSTOMSCREEN
    move.w    #15,46(a0)
;=========Open the FileIO window==========
.9  lea       newWindow,a0
.9A jsr       _LVOOpenWindow(a6)
    move.l    d0,(a4)+
    beq       C2
    movea.l   d0,a3
   ;---Get Window's RastPort
    move.l    50(a3),(a4)
;====Attach our menu to the window======
    lea       ProjectMenu,a1
    movea.l   a3,a0
     ;  _IntuitionBase,a6
    jsr       _LVOSetMenuStrip(a6)
;-----Get a FileIO structure
E1  movea.l   _RequesterBase,a6
    jsr       _LVOGetFileIO(a6)
    movea.l   d0,a4
    move.l    d0,d1
    beq       IOe          ;If NULL, then error, so exit this test program.
;---Set Colors and DrawMode
    moveq     #1,d0
    move.b    d0,FILEIO_DRAWMODE(a4)
    movea.l   RastPort,a2
    movea.l   a2,a1
    movea.l   _GfxBase,a6
    jsr       _LVOSetDrMd(a6)
    moveq     #2,d0
    move.b    d0,FILEIO_PENA(a4)
    movea.l   a2,a1
    jsr       _LVOSetAPen(a6)
    moveq     #0,d0
    move.b    d0,FILEIO_PENB(a4)
    movea.l   a2,a1
    jsr       _LVOSetBPen(a6)
;====Set up custom handlers for the FileIO but don't enable the flag yet===
    move.l    #HandlerBlock,FILEIO_CUSTOM(a4) ;the address of our handler vectors
;====Set up the XY co-ordinates of where the requester will open====
; If we used DoFileIOWindow(), we wouldn't need to set co-ordinates.
    moveq     #6,d0
    move.w    d0,FILEIO_X(a4)  ;x position
    moveq     #11,d0
    move.w    d0,FILEIO_Y(a4)  ;y position
 ;---Get the buffer where the complete Path will be stored
    move.l   #buffer,FILEIO_BUFFER(a4)
 ;---Set up EXTENTION in case the user wants to enable it via function key 4
 ;   If we allow this feature, we must supply a buffer of at least 30 bytes
 ;   If we don't want the user to utilize this feature, then FILEIO_EXTENTION
 ;   field must be zeroed and EXTENTION_MATCH flag cleared whenever we
 ;   aren't using this feature.
    lea      ExtMatch,a0
    move.l   a0,FILEIO_EXTENSION(a4)
;====Create a mask of the Window's UserPort's mp_Sigbit=====
E3  movea.l   86(a3),a0
    move.b    15(a0),d0
    moveq     #0,d7
    Bset.l    d0,d7
;=====Get the message that arrived at our UserPort====
E4  movea.l   86(a3),a0
    movea.l   _SysBase,a6
    jsr       _LVOGetMsg(a6)
    move.l    d0,d1
    bne.s     E7
;===Check if we are ready to exit the program=====
E5  Btst.b    #0,Quit
    beq       E15
;----Print out "Click Mouse to start demo....
    movea.l   RastPort,a2
    moveq     #5,d0
    moveq     #75,d1
    movea.l   a2,a1           ;our window's RastPort
    move.l    a6,-(sp)        ;save _SysBase
    movea.l   _GfxBase,a6
    jsr       _LVOMove(a6)
    moveq     #36,d0          ;# of bytes to output.
    lea       Click,a0
    movea.l   a2,a1
    jsr       _LVOText(a6)
    movea.l   (sp)+,a6        ;restore _SysBase
;===Wait for a message sent to our Window (from Intuition)===
E6  move.l    d7,d0
    jsr       _LVOWait(a6)
    bra.s     E4
;====Copy all the info we want from the IntuiMessage====
E7  movea.l   d0,a1
    lea       20(a1),a0  ;get the address of the first field to copy.
    move.l    (a0)+,d6   ;Copy the Class field to d6
    move.w    (a0)+,d5   ;Copy the Code field to d5
    move.w    (a0)+,d4   ;Copy the qualifier field to d4
    movea.l   (a0)+,a2   ;Copy the IAddress field to a2
    move.w    (a0)+,d3   ;Copy MouseX position to d3
    move.w    (a0)+,d2   ;Copy MouseY position to d2
;====Now reply to the message so Intuition can dispose of it
E8  ;Address of the message is in a1.
    jsr       _LVOReplyMsg(a6)
;========switch (class)=========
    Bclr.l    #9,d6  ;CLOSEWINDOW
    bne       CW
    Bclr.l    #8,d6  ;MENUPICK
    bne.s     MU
    Bclr.l    #3,d6  ;MOUSEBUTTONS
    beq       E4
;---Make sure that it's an UP select if MOUSEBUTTONS
    subi.b    #$68,d5
    beq       E4     ;ignore down
;===The FOLLOWING ROUTINE IS OUR TEST CALL. WHEN THE USER IS DONE (in FileIO lib)
;===HE WILL SELECT EITHER THE CANCEL OR OK! GADGET. IF CANCEL, TestFileIO
;===DOES NOTHING. IF OK!, TestFileIO JUSTS PRINTS THE SELECTED FILENAME.
E2  bsr       TestFileIO
  ;If TestFileIO returns a 1, then we should CLEAR the NO_CARE_REDRAW
  ;flag in any FileIOs that had it SET. We aren't using this feature though
  ;because another application might change the disks unbeknowst to us.
  ;NO_CARE_REDRAW is only SET when you don't care if the list of names
  ;displayed is updated to include any recent changes by another task.
  ;We probably should clear it though, just in case the user set it.
    bra     E4
;=========case MENUPICK:===============
; Actually, if the user selects some of these flags via the function keys,
; our menu checkmarks won't accurately reflect the real state of the
; option. We really should set the menuitem's CHECKED flag depending on the
; toggled state of the FileIO flag. This is just a simple example though.
; Normally, you wouldn't need to have menus for these options since in the
; case of CUSTOM handlers it should be invisible to the user. For things
; like INFO_SUPPRESS, let the user set it himself with the function keys.
  ;------Determine which item
MU lsr.w   #5,d5         ;Shift the item # bits into lowest bits of reg.
   andi.w  #$3F,d5       ;Isolate the Item # from the Menu and subitem #.
   beq.s   G4            ;branch if Item #0 (Extension)
   subq.w  #1,d5
   beq     G3            ;branch if Item #1 (WB)
   subq.w  #1,d5
   beq     G5            ;branch if Item #2 (Device)
   subq.w  #1,d5
   beq     G1            ;branch if Item #3 (Custom)
   subq.w  #1,d5
   beq     G6            ;branch if Item #4 (No Info)
   subq.w  #1,d5
   beq     AB            ;branch if Item #5 (About)
   subq.w  #1,d5
   bne     E4            ;branch if not Item #6 (TypeName)
;---We deliberately call TypeFilename instead of DoFileIO
   bchg.b  #0,Flag
   bra     E4
;---Display Info about this program
AB movem.l a2/a3,-(sp)
   movea.l a3,a0         ;window
   lea     Msg1,a1
   lea     Msg2,a2
   lea     Msg3,a3
   movea.l _RequesterBase,a6
   jsr     _LVOAutoPrompt3(a6)
   movem.l (sp)+,a2/a3
   bra     E4
G6 Bchg.b  #INFO_SUPPRESS,1(a4)  ;toggle the INFO_SUPPRESS flag ON/OFF
   bra     E4
G1 Bchg.b  #1,(a4)       ;toggle the CUSTOM_HANDLERS flag ON/OFF
   bra     E4
G4 Bchg.b  #EXTENSION_MATCH,1(a4) ;toggle the EXTENSION_MATCH flag ON/OFF
   bne     E4
 ;WARNING: Must have RAWKEY set in order to call PromptUserEntry or UserEntry
 ;---get the user's choice of extention
   lea     ExtPrompt,a0
   moveq   #ExtBufSize,d0
   lea     ExtMatch,a1  ;display the previous extention
   movea.l a4,a2
   ;window in a3
   movea.l _RequesterBase,a6
   jsr     _LVOPromptUserEntry(a6)
 ;---Did he enter anything?
   move.l  d0,d1    ;buffer
   bne     MF
   Bclr.b  #EXTENSION_MATCH,1(a4) ;turn it back off
   bra     E4
 ;---Set the FileIO match string and size of string
 ;---Now we copy buffer to ExtMatch buffer, converting to all lower case
 ;   since the library needs to see the match string in lower case ONLY.
MF movea.l d0,a1
   lea     ExtMatch,a0
   jsr     up_to_low_case_str
   move.w  d0,FILEIO_EXTSIZE(a4) ;size of extension (don't count NULL)
   bra     E4
G3 Bchg.b  #WBENCH_MATCH,1(a4) ;toggle the WBENCH_MATCH
   bra     E4
G5 Bchg.b  #USE_DEVICE_NAMES,1(a4) ;toggle USE_DEVICE_NAMES
   bra     E4
;=========case CLOSEWINDOW:============
CW  Bclr.b    #0,Quit
    bra       E4
;======if an error, indicate NO_MEMORY. This is a FileIO routine
;======and is callable even if GetFileIO() fails
IOe movea.l   a3,a0
    moveq     #0,d0
    movea.l   _RequesterBase,a6
    jsr       _LVOAutoFileMessage(a6)
;========NOW BEGINS OUR EXIT ROUTINE=========
E15 movea.l   a4,a1                ;If the pointer to FileIO was NULL, then
    movea.l   _RequesterBase,a6    ;ReleaseFileIO just returns, so it's safe to
    jsr       _LVOReleaseFileIO(a6) ;always release any return value of GetFileIO.
;=====Close the Window and Screen======
C1  movea.l   _IntuitionBase,a6
    movea.l   a3,a0
    jsr       _LVOCloseWindow(a6)
C2  move.l    ScreenPtr,d0
    beq.s     C3            ;check if we specified a screen
    movea.l   d0,a0
    ; _IntuitionBase in a6
    jsr       _LVOCloseScreen(a6)
;=====Close Whichever Libs are Open (_SysBase in a6 for ALL calls)=====
C3  movea.l  _SysBase,a6
    movea.l  _RequesterBase,a1
    jsr      _LVOCloseLibrary(a6)
C5  movea.l  _GfxBase,a1
    jsr      _LVOCloseLibrary(a6)
C6  movea.l  _IntuitionBase,a1
    jsr      _LVOCloseLibrary(a6)
C7  movem.l  (sp)+,d2-d7/a2-a6
    rts

;*******************************************
; This just calls the DoFileIO library routine and displays a msg on return.
; (GetFileIO must have been called with success first).
; The DoFileIO routine returns -1 if the user selected CANCEL,
; or returns the address of the Pathname string if OK! was selected. At this
; point, we could call a load or save operation using this filename string,
; but instead, we simply display the chosen name.
;   TestFileIO(FileIO, window)
;                a4      a3

typename:
;--This shows what would happen (automatically) if the lib was in use on a
;  call to DoFileIO(), or the requester couldn't open.
   jsr       _LVOTypeFilename(a6)
   bra.s     cex
   XDEF TestFileIO
TestFileIO:
    movea.l  _RequesterBase,a6
 ;-----DoFileIO(FileIO, window, Buffer)
    movea.l  a3,a1
    movea.l  a4,a0
    Btst.b   #0,Flag
    bne.s    typename
    jsr      _LVODoFileIO(a6)
cex move.l   d0,d1
    beq.s    .error 
 ;must have been an error. If we were using DoFileIOWindow(), the window
 ;might not have opened. For DoFileIO(), we shouldn't see a 0 return.
 ;We could check the FileIO's ERRNO field to see what the specific error
 ;was.
    addq.l   #1,d1
    beq.s    .can        ;If -1, user must have selected CANCEL
 ;-----AutoMessage(buffer, window) Display our path.
    ;buffer in d0
    movea.l  a3,a0
    jsr      _LVOAutoMessage(a6)
; Now we could check the FileIO's Filename field to see if the user entered
; a file, or just a drawer or disk name alone. If not NULL, we have a filename.
; Next we would check the FILEIO_FILESIZE field. If this is 0, then
; the user must have typed in a filename that doesn't yet exist. We could
; create it now. Otherwise, this field tells us how large the selected file is.
    move.b   FILEIO_FILENAME(a4),d0
    beq.s    dirdisk
    move.l   FILEIO_FILESIZE(a4),d0
    bne.s    exists
    move.l   #NoExist,d0
    movea.l  a3,a0
    jsr      _LVOAutoMessage(a6)
;----Clear the DISK_HAS_CHANGED flag. If it was SET, return 1. Else return 0.
; (i.e. return d0=1 if the user swapped disks during DoFileIO() else 0)
; We only need to bother with this if we had SET the NO_CARE_REFRESH flag
; (or the user did via function key 6).
exists:
    moveq    #1,d0
    Bclr.b   #5,(a4)
    bne.s    .32
  ;---Otherwise, return 0
    moveq    #0,d0
.32 rts
.error: move.l  #errmsg,d0
prt     movea.l a3,a0
        jsr     _LVOAutoMessage(a6)
        bra.s   exists
.can    move.l  #cancel,d0
        bra.s   prt
dirdisk move.l  #just,d0
        bra.s   prt

start_msg: ;a custom handler for requester's REQSET
    movea.l  window,a0
    move.l   #MSG,d0
    move.l   a6,-(sp)        ;must save a6 (non-scratch) here
    movea.l  _RequesterBase,a6
    jsr      _LVOAutoMessage(a6)  ;depending on if the user selects OK or
    movea.l  (sp)+,a6             ;NO, the internal library's startup handler
    rts                           ;will be executed or skipped.

  ; SECTION MainData,DATA  ;Not needed for CAPE PC relative addressing!!

   XDEF _IntuitionBase,_GfxBase,ScreenPtr
   XDEF _RequesterBase
 ;must be in this order
_IntuitionBase dc.l 0
_GfxBase       dc.l 0
_RequesterBase dc.l 0
window         dc.l 0
RastPort       dc.l 0

   XDEF   newScreen
newScreen:
   dc.w   0,0         ;LeftEdge, TopEdge
   dc.w   640,400     ;Width, Height
   dc.w   2           ;Depth
   dc.b   0,1         ;Detail, Block pens
   dc.w   -32764      ;ViewPort Modes HIRES|LACE (must set/clr HIRES as needed)
   dc.w   15          ;CUSTOMSCREEN
   dc.l   TextAttr    ;Font
   dc.l   ScrTitle
   dc.l   0           ;Gadgets
   dc.l   0           ;CustomBitmap

   XDEF   newWindow
newWindow:
          dc.w   30,30
          dc.w   306,145
          dc.b   0,1
 ;IDCMP = MOUSEBUTTONS|CLOSEWINDOW|MENUPICK|RAWKEY
 ;Must have RAWKEY set in order to call PromptUserEntry,UserEntry,GetString
          dc.l   $708
 ;WindowFlags = WINDOWDRAG|WINDOWDEPTH|SMART_REFRESH|ACTIVATE|WINDOWSIZE
 ;(no FOLLOWMOUSE allowed as that messes up the requester when using
 ;DoFileIO(). If you need FOLLOWMOUSE, then use DoFileIOWindow() to open
 ;the req in its own window.)
          dc.l   $100F
          dc.l   0
          dc.l   0
          dc.l   WINTITLE
ScreenPtr dc.l   0
          dc.l   0
          dc.w   306,145
          dc.w   600,240
          dc.w   1         ;WBENCHSCREEN

;==========THE PROJECT MENU===========

ProjectMenu:
   dc.l 0
   dc.w 0,0
   dc.w 90,0
   dc.w 1
   dc.l ProjectTitle
   dc.l ExtItem
   dc.w 0,0,0,0

;======The Items in Menu0========
 ;These are MenuItem structures for the preceding Menu Structure.
ExtItem   dc.l WBItem
          dc.w 0,0
          dc.w 200,10
          dc.w $5F
          dc.l 0
          dc.l ExtText
          dc.l 0
          dc.b 'E'
          dc.b 0
          dc.l 0
          dc.w 0
WBItem    dc.l DevItem
          dc.w 0,10,200,10
          dc.w $5F
          dc.l 0,WBText,0
          dc.b 'W'
          dc.b 0
          dc.l 0
          dc.w 0
DevItem   dc.l CusItem
          dc.w 0,20,200,10,$5F
          dc.l 0,DevText,0
          dc.b 'D',0
          dc.l 0
          dc.w 0
CusItem   dc.l InfoItem
          dc.w 0,30,200,10,$5F
          dc.l 0,CusText,0
          dc.b 'C',0
          dc.l 0
          dc.w 0
InfoItem  dc.l AboutItem
          dc.w 0,40,200,10,$5F
          dc.l 0,InfoText,0
          dc.b 'I',0
          dc.l 0
          dc.w 0
AboutItem dc.l TypeItem
          dc.w 0,50,200,10,86
          dc.l 0,AboutText,0
          dc.b 'A',0
          dc.l 0
          dc.w 0
TypeItem  dc.l 0
          dc.w 0,60,200,10,$5F
          dc.l 0,TypeText,0
          dc.b 'T',0
          dc.l 0
          dc.w 0
ExtText   dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,ExtString,0
WBText    dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,WBString,0
DevText   dc.b 0,1,1,0
          dc.w 19          ;allow room for the checkmark
          dc.w 0
          dc.l TextAttr,DevString,0
CusText   dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,CusString,0
InfoText  dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,NoInfoString,0
AboutText dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,AboutString,0
TypeText dc.b 0,1,1,0
          dc.w 19,0
          dc.l TextAttr,TypeString,0

TextAttr:        ;Topaz 8 is a ROM font so doesn't need to be opened
   dc.l   FONTNAME
   dc.w   8      ;TOPAZ_EIGHTY
   dc.b   0,0

HandlerBlock: ;these are the addresses of my custom handlers for the requester's
              ;REQSET, GADGETUP and GADGETDOWN, DISKINSERTED, RAWKEY, and
              ;MOUSEMOVE respectively. Note that I only installed a StartUp
              ;handler. The rest are NULL because I don't care about them.
   dc.l   start_msg     ;StartUpHandler
   dc.l   $0000         ;GadgetHandler
   dc.l   $0000         ;NewDiskHandler
   dc.l   $0000         ;KeyHandler
   dc.l   $0000         ;MouseMoveHandler

Quit dc.b 1  ;When this is a 0, the user wants to exit.

ScrTitle      dc.b 'Example FileIO Program Screen',0
WINTITLE      dc.b 'Example FileIO Program Window',0
Click         dc.b 'Click mouse for demo or CLOSEWINDOW.',0
IntuitionName dc.b 'intuition.library',0
IconName      dc.b 'icon.library',0
DOSName       dc.b 'dos.library',0
GfxName       dc.b 'graphics.library',0
RequesterName dc.b 'requester.library',0
FONTNAME      dc.b 'topaz.font',0
errmsg        dc.b 'Error in accessing the requester',0
cancel        dc.b 'The CANCEL gadget was selected.',0
ExtString     dc.b 'Extension',0
CusString     dc.b 'Custom',0
WBString      dc.b 'WorkBench',0
DevString     dc.b 'Device',0
NoInfoString  dc.b 'No Info',0
AboutString   dc.b 'About',0
TypeString    dc.b 'Type Name',0
MSG           dc.b 'This is my custom handler',0
ProjectTitle  dc.b 'Project',0
NoExist       dc.b 'This file does not yet exist',0
Msg1   dc.b 'An example of using the FileIO lib',0
Msg2   dc.b 'written by Jeff Glatt',0
Msg3   dc.b '< dissidents >',0
Flag   dc.b 0
just   dc.b 'This is a drawer or disk, not a file.',0

PromptLen  equ  7
ExtPrompt  dc.b 'Match >',0

buffer    ds.b 202  ;for the complete pathname
ExtMatch  ds.b 30   ;for extension match, must be big enough for extension
                    ;and ExtPrompt because of the way PromptUserEntry works.


   END

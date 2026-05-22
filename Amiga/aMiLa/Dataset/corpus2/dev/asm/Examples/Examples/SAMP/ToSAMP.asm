 ;Assembled with Innovatronic's CAPE assembler with the SMALLOBJ directive.
 ;(i.e. PC relative code) For other assemblers, uncomment the section
 ;directive before the data section.
 ;Link as follows
 ;Blink SmallStart.o ToSAMP.o small.lib NODEBUG to ToSAMP
 ;where SmallStart.o is the startup code included with this program and
 ;small.lib is Bryce Nesbitt's amiga lib.
 ;For Manx,
 ;as -cd -o ToSAMP ManxStartUp.o ToSAMP.o -lcl32
 ;
 ; This example uses R.J. Mical's FileIO requester in a special library form
 ; prepared by
 ;                           dissidents

  SMALLOBJ

  INCLUDE  "FileIO.i" ;requires RJ Mical's FileIO in library form

         SECTION  ToSampCode,CODE

   XREF  _DOSBase,_SysBase ;from StartUp code

   XREF  _LVOOpenLibrary,_LVOCloseLibrary,_LVOOpenWindow,_LVOCloseWindow
   XREF  _LVOAllocMem,_LVOFreeMem
   XREF  _LVOGetMsg,_LVOReplyMsg,_LVOWait,_LVOWaitPort
   XREF  _LVOPrintIText,_LVODrawImage
   XREF  _LVOMove,_LVOText,_LVOSetAPen
   XREF  _LVOOpen,_LVORead,_LVOWrite,_LVOClose,_LVODelay
   XREF  _LVOLock,_LVOUnLock,_LVOExamine,_LVODeleteFile

MODE_OLDFILE equ 1005
MODE_NEWFILE equ 1006
LIB_VERSION  equ 33

   XDEF print_type
print_type:
    bsr.s   blank
    moveq   #0,d0
    move.b  d5,d0
    add.b   d0,d0
    add.b   d0,d0
    lea     TYPES,a0
    adda.l  d0,a0
    move.l  (a0),a4
    moveq   #0,d2
    move.b  (a4)+,d2
    move.b  d2,NumOfChoices
    moveq   #10,d3
    moveq   #10,d4
mgg moveq   #26,d0
    add.w   d3,d4
    move.w  d4,d1
    bsr.s   print_msg  ;returns end of msg (beginning of next string)
    Dbra    d2,mgg
    rts

blank:
   moveq   #17-1,d2
   moveq   #10,d3
   moveq   #10,d4
mG lea     SPACES,a4
   moveq   #26,d0
   add.w   d3,d4
   move.w  d4,d1
   bsr.s   print_msg
   Dbra    d2,mG
   rts

  XDEF print_msg  ;string passed in a4, x in d0, y in d1
print_msg:
    movea.l   RastPort,a2
    movea.l   a2,a1
    movea.l   _GfxBase,a6
    jsr       _LVOMove(a6)
    movea.l   a4,a0
len move.b    (a4)+,d0
    bne.s     len
    move.l    a4,d0
    subq.l    #1,d0
    sub.l     a0,d0           ;length of string
    movea.l   a2,a1           ;RastPort
    jmp       _LVOText(a6)

   XDEF print_directions
print_directions:
   lea     Directions,a4
   lea     Positions,a5
   moveq   #10-1,d2
   moveq   #10,d3
   moveq   #10,d4
mg move.w  (a5)+,d0
   add.w   d3,d4
   move.w  d4,d1
   bsr.s   print_msg  ;returns end of msg (beginning of next string)
   Dbra    d2,mg
   rts

   XDEF print_family
print_family:
   bsr     blank
   lea     Family,a4
   moveq   #17-1,d2
   moveq   #10,d3
   moveq   #10,d4
MG moveq   #26,d0
   add.w   d3,d4
   move.w  d4,d1
   bsr.s   print_msg  ;returns end of msg (beginning of next string)
   Dbra    d2,MG
   rts

Positions dc.w 38,28,38,26,30,39,29,24,30,84

   XDEF _main
_main:
;---Open Gfx Library
        movea.l  _SysBase,a6
        moveq    #LIB_VERSION,d0
        lea      GfxName,a1
        jsr      _LVOOpenLibrary(a6)
        move.l   d0,_GfxBase
        bne.s    xx
        rts
;---Open Intuition
xx      moveq    #LIB_VERSION,d0
        lea      IntuitionName,a1
        jsr      _LVOOpenLibrary(a6)
        move.l   d0,_IntuitionBase
        beq      clG
;---Open the main window
        lea      newWindow,a0
        move.l   a6,-(sp)
        movea.l  d0,a6
        jsr      _LVOOpenWindow(a6)
        movea.l  (sp)+,a6
        move.l   d0,WindowPtr
        beq      clI
        move.l   d0,a0
        move.l   50(a0),RastPort
  ;---Open the FileIO (requester) library
        moveq     #0,d0            ;any version (for now)
        lea       RequesterName,a1
        jsr       _LVOOpenLibrary(a6)
        move.l    d0,_RequesterBase
        bne.s     gotit
         ;---error
        lea       FileReqErr,a4
        moveq     #5,d0
        moveq     #75,d1
        bsr       print_msg
        moveq     #100,d1
        movea.l   _DOSBase,a6
        jsr       _LVODelay(a6)
        bra       clW
;===================Get the FileIO Structure========================
gotit   movea.l   d0,a6
        jsr       _LVOGetFileIO(a6)
        move.l    d0,FileIO
        bne.s     gotIO
        lea       IOerR,a4
        moveq     #5,d0
        moveq     #75,d1 
        bsr       print_msg
        moveq     #100,d1
        movea.l   _DOSBase,a6
        jsr       _LVODelay(a6)
        bra       clF
  ;---Set up info file suppression
gotIO   movea.l   d0,a0
        Bset.b    #INFO_SUPPRESS,1(a0)  ;INFO_SUPPRESS ON
  ;--Set up the XY co-ordinates of where the requester will open
  ; If we used DoFileIOWindow(), we wouldn't need to set co-ordinates.
        moveq     #6,d0
        move.w    d0,FILEIO_X(a0)  ;x position
        moveq     #11,d0
        move.w    d0,FILEIO_Y(a0)  ;y position
  ;---Setup buffer for path name
        lea       _BUFFER,a1
        move.l    a1,FILEIO_BUFFER(a0)
        moveq     #1,d0
        move.b    d0,FILEIO_DRAWMODE(a0)
        move.b    d0,FILEIO_PENA(a0)
;====Create a mask of the Window's UserPort's mp_Sigbit=====
        movea.l   WindowPtr,a3
        movea.l   86(a3),a0
        move.b    15(a0),d0
        moveq     #0,d7
        Bset.l    d0,d7
;----Print out Directions
        bsr       print_directions
;********************** MAIN LOOP ******************************
;=====Get the message that arrived at our UserPort====
E4     movea.l   86(a3),a0
       movea.l   _SysBase,a6
       jsr       _LVOGetMsg(a6)
       move.l    d0,d1
       bne.s     E7
;===Check if we are ready to exit the program=====
       Btst.b    #0,Quit
       beq       delFile
;===Wait for a message sent to our Window (from Intuition)===
       move.l    d7,d0
       jsr       _LVOWait(a6)
       bra.s     E4
;====Copy all the info we want from the IntuiMessage====
E7    movea.l   d0,a1
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
      Bclr.l    #3,d6  ;MOUSEBUTTONS
      bne.s     GADG
      Bclr.l    #9,d6  ;CLOSEWINDOW
      beq.s     E4
;=========case CLOSEWINDOW:============
CW    Bclr.b    #0,Quit
      bra.s     E4
;---Make sure that it's an UP select if MOUSEBUTTONS
GADG  subi.b    #$68,d5
      beq       E4     ;ignore down
     ;---get the user's filename and load the 8SVX file
E2    bsr       load_8SVX
      subq.b    #1,d0
      bne.s     Cerr
     ;---Convert the file to SAMP and save
      bsr       convert_8SVX
      subq.b    #1,d0
      bne.s     Cerr
     ;---Indicate a successful conversion
      lea       Success,a4
  ;---delete the 8SVX conversion buffer if it exists
Cerr  bsr       free_data
  ;---Print the returned message
      movea.l   _RequesterBase,a6
      movea.l   a3,a0
      move.l    a4,d0
      jsr       _LVOAutoMessage(a6)
      movea.l   _SysBase,a6
ep    movea.l   86(a3),a0
      jsr       _LVOGetMsg(a6)
      move.l    d0,d1
      bne.s     ep
;******************** Exit the Program *********************
     ;If the pointer to FileIO was NULL, then
     ;ReleaseFileIO just returns, so it's safe to
     ;always release any return value of GetFileIO.
delFile  movea.l  FileIO,a1
         movea.l  _RequesterBase,a6
         jsr      _LVOReleaseFileIO(a6)
    ;---Close the graphics lib
clF      movea.l  _RequesterBase,a1
         movea.l  _SysBase,a6
         jsr      _LVOCloseLibrary(a6)
    ;---Close the window
clW      movea.l  WindowPtr,a0
         movea.l  _IntuitionBase,a6
         jsr      _LVOCloseWindow(a6)
    ;---Close the Intuition Lib
clI      movea.l  _SysBase,a6
         movea.l  _IntuitionBase,a1
         jsr      _LVOCloseLibrary(a6)
    ;---Close the graphics lib
clG      movea.l  _GfxBase,a1
         jmp      _LVOCloseLibrary(a6)

  XDEF load_8SVX
load_8SVX:
       movem.l  d2/d3/d4/d5,-(sp)
 ;---Get the user's filename via the FileIO requester
       movea.l  WindowPtr,a1
       movea.l  FileIO,a0
       movea.l  _RequesterBase,a6
       jsr      _LVODoFileIO(a6)
       move.l   d0,d1
       bne.s    L92    ;If 0, must have been an error
       lea      LibErr,a4
outL   movem.l  (sp)+,d2/d3/d4/d5
       rts
L92    addq.l   #1,d0
       bne.s    L90
    ;If -1, user must have selected CANCEL
       lea      Cancel,a4
       bra.s    outL
   ;---Get the File's Size
L90    movea.l   FileIO,a0
       move.l    FILEIO_FILESIZE(a0),d0
       move.l    d0,FileSize
       bne.s     L89
       ;---If size = 0, then this file must not exist (in this directory)
L95    lea       CantFind,a4
       bra.s     outL
   ;---get a conversion buffer to copy in the entire 8SVX file
L89    movea.l   _SysBase,a6
       moveq     #1,d1
       jsr       _LVOAllocMem(a6)
       move.l    d0,_8SVXData   ;the address of conversion buffer
       bne.s     L93
       move.l    d0,FileSize    ;size of conversion buffer
       lea       NoMem,a4
       bra.s     outL
   ;---Open the file
L93    moveq     #0,d2
       move.w    #MODE_OLDFILE,d2
       lea       _BUFFER,a0
       move.l    a0,d1
       movea.l   _DOSBase,a6
       jsr       _LVOOpen(a6)
       move.l    d0,d4
       beq.s     L95
   ;---Make sure that this is an 8SVX file
       moveq     #20,d3     ;read the first 20 bytes
       move.l    _8SVXData,d2
       move.l    d4,d1
       jsr       _LVORead(a6)
       sub.l     d0,d3
       bne.s     CloseR
       movea.l   _8SVXData,a0
       addq.l    #8,a0
       move.l    _8SVX,d0
       sub.l     (a0),d0
       beq.s     readin
       ;---Not 8SVX
NotIFF move.l    d4,d1
       jsr       _LVOClose(a6)
       moveq     #0,d0
       lea       Not8SVX,a4
       bra       outL
   ;---Read in the rest of the file (starting with VHDR's oneShotHiSamples)
readin move.l    FileSize,d3
       moveq     #20,d0
       sub.l     d0,d3
       move.l    _8SVXData,d2 
       move.l    d4,d1
       jsr       _LVORead(a6)
       sub.l     d0,d3
CloseR move.l    d4,d1
       jsr       _LVOClose(a6)
       moveq     #1,d0
       move.l    d3,d1
       beq       outL
       lea       ReadErr,a4
       moveq     #0,d0
       bra       outL

; This frees the conversion buffer when we are done with it.

  XDEF free_data
free_data:
     lea     _8SVXData,a0
     move.l  (a0),d0
     beq.s   no8D
     clr.l   (a0)+
     movea.l d0,a1
     move.l  (a0),d0  ;FileSize
     clr.l   (a0)
     movea.l _SysBase,a6
     jmp     _LVOFreeMem(a6)
no8D move.l  d0,4(a0)
     rts

   XDEF divide
 ;This routine divides 2 LONGS passed in d0 and d1.
 ;d0 = d0/d1 with d2 = the remainder.
divide:
    moveq   #0,d2
    moveq   #31,d3
_1  asl.l   #1,d0
    roxl.l  #1,d2
    cmp.l   d1,d2
    bcs.s   _2
    sub.l   d1,d2
    addq.l  #1,d0
_2  Dbra    d3,_1
    rts

   XDEF convert_8SVX
convert_8SVX:
     movem.l  d2/d3/d4/d5/a3/a4,-(sp)
  ;---Make the SAMP playMap. Assign each interpolation an octave in the map
     movea.l  _8SVXData,a4
     lea      playMap,a1
     moveq    #0,d0
     move.b   14(a4),d0  ;the number of octaves in the 8SVX file
     beq      CCC
  ;---limit to 10 octaves of the 8SVX file (numbered 1 to 10)
     moveq    #10,d1
     cmp.b    d1,d0
     bls.s    okOT
     move.b   d1,d0
okOT move.b   d0,numOfWaves
nto  moveq    #12-1,d1  ;1 octave of notes
octt move.b   d0,(a1)+
     move.b   d0,(a1)+
     move.b   d0,(a1)+
     move.b   d0,(a1)+
     Dbra     d1,octt
     subq.b   #1,d0
     bne.s    nto
  ;---Store the sampleRate
     move.w   12(a4),d1  ;samplesPerSec
     beq.s    def
     move.l   d1,sampleRate
     ;---calculate samplePeriod
     move.l   #1000000000,d0 ;in nanoseconds
     bsr.s    divide
     move.l   d0,samplePeriod
def  lea      20(a4),a0      ;the chunk after VHDR
;================PROCESS AN 8SVX CHUNK================
nChk bsr      DoWeWantIt
     beq      BodyHandler ;the last chunk in 8SVX
     subq.b   #1,d0
     beq.s    DoName
     subq.b   #1,d0
     beq      DoATAK
     subq.b   #1,d0
     beq      DoRLSE
   ;---Throw away this chunk
thrw move.l   4(a0),d0 ;chunk size
     Btst.l   #0,d0
     beq.s    even
     addq.l   #1,d0
even addq.l   #8,a0
     adda.l   d0,a0    ;skip to the end of the chunk
     bra.s    nChk
;--'NAME': Copy the "Master" name to name buffer and count # of chars
;  including NULL (+1 to append the wave number). Calculate the final
;  resulting chunk size. Make sure that the name is an even # of bytes.
DoName:
     lea      name,a1
     moveq    #19-1,d0 ;copy 19 chars (including NULL) Max
     movea.l  a0,a3
     addq.l   #8,a3
     move.l   a1,d1
cnm  move.b   (a3)+,(a1)+
     Dbeq     d0,cnm
     move.l   a1,d0
     clr.b    -(a1)
     sub.l    d1,d0  ;length of 1 wave name counting NULL
     addq.l   #1,d0  ;allow for appending the wave (octave) number
     Btst.l   #0,d0
     beq.s    EVEN
     addq.l   #1,d0
     move.b   #' ',(a1)+
EVEN move.l   a1,nameNULL
     moveq    #0,d1
     move.b   numOfWaves,d1
     mulu.w   d1,d0     
     move.l   d0,nameSize
     bra.s    thrw
;---Note the address and size (bytes) of the ATAK chunk. We'll copy it to
;   disc verbatim...once for each wave.
DoATAK:
     movea.l  a0,a3
     addq.l   #4,a3
     move.l   (a3)+,d0
     move.l   d0,sizeOfATAK ;This should always be even.
     move.l   a3,ATAKptr    ;addr of EGpoints[]
   ;---add the (size of chunk) x numOfWaves to sizeOfBODY
sze  moveq    #0,d1
     move.b   numOfWaves,d1
     mulu.w   d1,d0        ;should actually be a LONG multiply just in case!
     add.l    d0,sizeOfBODY
     bra.s    thrw
DoRLSE:
     movea.l  a0,a3
     addq.l   #4,a3
     move.l   a3,RLSEptr  ;addr of sizeOfRLSE
     move.l   (a3)+,d0
     move.l   d0,sizeOfRLSE
     bra.s    sze
;================== BODY ==========================
BodyHandler:
 ;===Calculate size of BODY and total size of all chunks
     addq.l   #8,a0       ;get beginning of sample data
     lea      SampleInfo0,a3
     move.b   numOfWaves,d0
     subq.b   #1,d0
     move.l   (a4),d4  ;oneShotHiSamples
     move.l   4(a4),d5 ;repeatHiSamples
     move.l   a0,(a3)+
     move.l   d4,(a3)+
     move.l   d4,d1
     add.l    d5,d1    ;total size of this wave
     move.l   d1,d2    ;store sum of all wave sizes in d2
     moveq    #80,d3   ;80 byte waveHeader in BODY for each wave
     bra.s    _1o
  ;---Store one wave's waveHeader
agns move.l   a0,(a3)+ ;start address of sample data
     lsl.l    #1,d4    ;2x oneShot size
     move.l   d4,(a3)+ ;size of oneShot (also loopStart offset)
     lsl.l    #1,d5    ;size of loop portion
     move.l   d5,d1
     add.l    d4,d1
     add.l    d1,d2
_1o  add.l    d3,d2    ;add size of waveHeader
     move.l   d1,(a3)+ ;loopEnd offset (also this wave's waveSize)
     adda.l   d1,a0    ;next wave
     Dbra     d0,agns
     add.l    d2,sizeOfBODY
  ;---calculate the total size of ALL chunks in the SAMP file
     move.l   nameSize,d0
     beq.s    noNh
     addq.l   #8,d0    ;add 8 bytes for NAME header
noNh add.l    sizeOfBODY,d0
     add.l    d0,sizeOfChunks
;============== ASK THE USER TO DETERMINE THE INSTRUMENT TYPE =============
  ;---Determine the family
     bsr       print_family
     movea.l   _SysBase,a6
fam  move.l    d7,d0
     jsr       _LVOWait(a6)
     movea.l   WindowPtr,a1
     movea.l   86(a1),a0
     jsr       _LVOGetMsg(a6)
     move.l    d0,d1
     beq.s     fam
     movea.l   d0,a1
     lea       20(a1),a0  ;get the address of the first field to copy.
     move.l    (a0)+,d2   ;Copy the Class field
     move.w    (a0)+,d5   ;Copy the Code field to d5
   ;Address of the message is in a1.
     jsr       _LVOReplyMsg(a6)
   ;---wait for rawkey
     Bclr.l    #10,d2 ;RAWKEY
     beq.s     fam
   ;---Decode rawkey into Family nibble
     Bclr.l    #7,d5
     bne.s     fam    ;key up
     Btst.l    #5,d5
     beq.s     row1
     moveq     #22,d1
     sub.b     d1,d5
     bcs.s     unkn
     cmpi.b    #14,d5
     bcc.s     unkn
     bra.s     gtyp
row1 moveq     #16,d1
     sub.b     d1,d5
     bcs.s     unkn
     cmpi.b    #10,d5
     bcc.s     unkn
gtyp bsr       print_type
     addq.b    #1,d5
type move.l    d7,d0
     movea.l   _SysBase,a6
     jsr       _LVOWait(a6)
     movea.l   WindowPtr,a1
     movea.l   86(a1),a0
     jsr       _LVOGetMsg(a6)
     move.l    d0,d1
     beq.s     type
     movea.l   d0,a1
     lea       20(a1),a0  ;get the address of the first field to copy.
     move.l    (a0)+,d2   ;Copy the Class field
     move.w    (a0)+,d3   ;Copy the Code field to d3
   ;Address of the message is in a1.
     jsr       _LVOReplyMsg(a6)
   ;---wait for rawkey
     Bclr.l    #10,d2 ;RAWKEY
     beq.s     type
     Bclr.l    #7,d3
     bne.s     type    ;key up
   ;---Decode rawkey into Type nibble
     Btst.l    #5,d3
     beq.s     roW1
     moveq     #22,d1
     sub.b     d1,d3
     bcs.s     unkn
     bra.s     gtby
roW1 moveq     #16,d1
     sub.b     d1,d3
     bcs.s     unkn
     cmpi.b    #10,d3
     bcc.s     unkn
gtby cmp.b     NumOfChoices,d3
     bhi.s     unkn
     addq.b    #1,d3
     lsl.b     #4,d3
     or.b      d3,d5
     move.b    d5,Itype
  ;---Ask user if he wants to save to the same Filename with .SAMP extention
unkn lea      _BUFFER,a0
     lea      SAMPext,a1
     movem.l  a2/a3,-(sp)
     bsr      appendstr
     movea.l  _RequesterBase,a6
     movea.l  WindowPtr,a0
     lea      _BUFFER,a2
     lea      Same,a1
     suba.l   a3,a3
     jsr      _LVOAutoPrompt3(a6)
     movem.l  (sp)+,a2/a3
     move.b   d0,d1
     bne.s    sav
  ;---Get a new name via the FileIO lib
  ;-----DoFileIO(FileIO, window)
     movea.l  WindowPtr,a1
     movea.l  FileIO,a0
     jsr      _LVODoFileIO(a6)
     addq.l   #1,d0
     bne.s    sav
    ;If -1, user must have selected CANCEL. Abort the Conversion.
     lea      Cancel,a4
outS movem.l  (sp)+,d2/d3/d4/d5/a3/a4
     rts
  ;---Create this file
sav  lea      _BUFFER,a0
     movea.l  _DOSBase,a6
     move.l   a0,d1
     moveq    #0,d2
     move.w   #MODE_NEWFILE,d2
     jsr      _LVOOpen(a6)
     move.l   d0,d4
     bne.s    fh
    ;---error
CCC  lea      CantCreate,a4
     bra.s    outS
   ;---Write SAMP and MHDR chunks, and the 8 byte NAME header (if it exists)
fh   move.l   #516+8+8,d3
     move.l   nameSize,d2
     beq.s    nNH
     addq.l   #8,d3
nNH  lea      SAMP,a0
     move.l   a0,d2
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     beq.s    wwOK
    ;--WRITE error
WE   move.l   d4,d1
     jsr      _LVOClose(a6)
     lea      _BUFFER,a0
     move.l   a0,d1
     jsr      _LVODeleteFile(a6)
     lea      WriteErr,a4
     moveq    #0,d0
     bra.s    outS
  ;---Write the NAME chunk (if nameSize is not 0)
wwOK move.l   nameSize,d0
     beq.s    WrOK
     moveq    #0,d5
     move.b   numOfWaves,d5
     subq.b   #1,d5
     ;---append the wave number each time that we write out the name
nnnn movea.l  nameNULL,a0
     move.b   d5,d1
     addi.b   #'0',d1
     move.b   d1,(a0)+
     clr.b    (a0)+
     lea      name,a1
     move.l   a1,d2
     suba.l   a1,a0
     move.l   a0,d3
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne.s    WE
     Dbra     d5,nnnn
  ;---Save the 8 byte BODY header
WrOK lea      BODY,a0
     moveq    #8,d3
     move.l   a0,d2
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne.s    WE
;********** SAVE WAVES (80 byte waveHeader and data for each wave) *********
     lea      SampleInfo0,a3
     moveq    #0,d5
     move.b   numOfWaves,d5
     moveq    #12,d0
     mulu.w   d5,d0
     addq.b   #6,d0
     move.b   d0,rootNote  ;set the rootNote for the highest octave
     subq.b   #1,d5
;================ SAVE 1 WAVE =====================
savesam:
  ;---Store BODY parameters for this wave
     lea      waveSize,a0
     move.l   8(a3),(a0)+ ;store loopEnd in waveSize
     addq.w   #1,(a0)     ;inc midiSampNum
     addq.l   #8,a0
     addq.l   #4,a0
     move.l   4(a3),(a0)+ ;store loopStart
     move.l   8(a3),(a0)+ ;store loopEnd
     subi.b   #12,(a0)    ;dec to middle of previous octave
  ;---Write the 80 byte waveHeader
     moveq    #80,d3
     lea      waveHeader,a0
     move.l   a0,d2
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne      WE
  ;---see if there are ATAK EgPoints to write
     move.l   ATAKptr,d2
     beq.s    noAT
     move.l   sizeOfATAK,d3
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne      WE
  ;---Write any RLSE EgPoints
noAT move.l   RLSEptr,d2
     beq.s    noRT
     move.l   sizeOfRLSE,d3
     move.l   d4,d1
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne      WE
  ;---write the wave's data
noRT move.l   (a3)+,d2
     move.l   d4,d1
     addq.l   #4,a3
     move.l   (a3)+,d3
     jsr      _LVOWrite(a6)
     sub.l    d0,d3
     bne      WE
  ;---do the next wave
     Dbra     d5,savesam
  ;---close the file and return success
     move.l   d4,d1
     jsr      _LVOClose(a6)
     moveq    #1,d0
     bra      outS

  XDEF appendstr
appendstr:
     move.b  (a0)+,d1
     bne.s   appendstr
     subq.l  #1,a0
appp move.b  (a1)+,(a0)+
     bne.s   appp
     rts

   XDEF DoWeWantIt
DoWeWantIt:
    move.l  (a0),d0
    cmp.l   NAME,d0
    beq.s   itsNAME
    cmp.l   ATAK,d0
    beq.s   itsATAK
    cmp.l   RLSE,d0
    beq.s   itsRLSE
    sub.l   BODY,d0
    bne.s   unKn
    rts
itsNAME:
    moveq   #1,d0
    rts
itsATAK:
    moveq   #2,d0
    rts
itsRLSE:
    moveq   #3,d0
    rts
unKn:
    moveq   #-1,d0
    rts

    ; SECTION ToSAMPData,Data   ;UnComment if not using CAPE

   XDEF   newWindow
newWindow:
          dc.w   0,0
          dc.w   640,200
          dc.b   0,1
 ;IDCMP = MOUSEBUTTONS|CLOSEWINDOW|RAWKEY
          dc.l   $608
;WindowFlags = WINDOWCLOSE|WINDOWDEPTH|SMART_REFRESH|ACTIVATE (no FOLLOWMOUSE
;allowed as that messes up the requester when using DoFileIO(). If you need
;FOLLOWMOUSE, then use DoFileIOWindow() to open the req in its own window.)
          dc.l   $100C
          dc.l   0
          dc.l   0
          dc.l   WINTITLE
ScreenPtr dc.l   0
          dc.l   0
          dc.w   96,30
          dc.w   320,200
          dc.w   1         ;WBENCHSCREEN

TextAttr:        ;Topaz 8 is a ROM font so doesn't need to be opened
   dc.l   FONTNAME
   dc.w   8      ;TOPAZ_EIGHTY
   dc.b   0,0

  XDEF _GfxBase,_IntuitionBase,_RequesterBase,WindowPtr,RastPort
  XDEF _8SVXData,FileSize,FileIO,RequesterName,nameNULL,name,nameSize,NAME

_GfxBase       dc.l  0
_IntuitionBase dc.l  0
_RequesterBase dc.l  0
WindowPtr      dc.l  0
RastPort       dc.l  0
_8SVXData      dc.l  0
FileSize       dc.l  0
FileIO         dc.l  0

ATAK      dc.b  'ATAK'
RLSE      dc.b  'RLSE'
_8SVX     dc.b  '8SVXVHDR'
nameNULL  dc.l  name
name      ds.b  20    ;buffer for the NAME chunk

   XDEF SAMP,sizeOfChunks,MHDR,sizeOfMHDR,playMap,numOfWaves,BODY,sizeOfBODY
   XDEF name,waveSize,midiSampNum,loopType,sampleRate,samplePeriod
   XDEF loopStartPoint,loopEndPoint,rootNote,sizeOfATAK,ATAKptr,RLSEptr
   XDEF sizeOfRLSE,SampleInfo0,sizeOfFATK

;===================== SAMP PORTION ==========================
SAMP           dc.b 'SAMP'
sizeOfChunks   dc.l 516+8+8 ;MHDR size + MHDR Header + BODY Header (add
                            ;sizeOfBODY, nameSize, other chunks size)
;------------------------------
MHDR           dc.b 'MHDR'
sizeOfMHDR     dc.l 516
playMap        ds.l 128 ;4 bytes for each of 128 midi notes
numOfWaves     dc.b 0
sampleFormat   dc.b 8
Flags          dc.b 0
playMode       dc.b 1   ;MULTI default

NAME           dc.b 'NAME'
nameSize       dc.l 0

;------------------------------
BODY           dc.b 'BODY'
sizeOfBODY     dc.l 0 ;add size of ATAK, RLSE, waveSize, and 80 bytes
                      ;(for each wave's header)
  ;for each wave, store these 80 bytes
waveHeader:
waveSize       dc.l 0
midiSampNum    dc.w -1    ;inc for each wave
loopType       dc.b 0     ;forward
Itype          dc.b 0     ;unKnown
samplePeriod   dc.l 55556 ;ditto
sampleRate     dc.l 18000 ;assume some default 
loopStartPoint dc.l 0
loopEndPoint   dc.l 0
rootNote       dc.b 0     ;set to the note # in middle of each octave (i.e.
                          ;note number = 6 for the lowest octave)
velocityStart  dc.b 0
velStartTable  ds.w 16
sizeOfATAK     dc.l 0
sizeOfRLSE     dc.l 0
sizeOfFATK     dc.l 0
sizeOfFRLS     dc.l 0
sizeOfUserData dc.l 0
typeOfData     dc.w 0


ATAKptr        dc.l 0
RLSEptr        dc.l 0

; For 10 waves
SampleInfo0 dc.l 0 ;oneShot Start
            dc.l 0 ;byte offset to loopStart
            dc.l 0 ;byte offset to loopEnd (from wave beginning)
SampleInfo1 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo2 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo3 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo4 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo5 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo6 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo7 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo8 dc.l 0
            dc.l 0
            dc.l 0
SampleInfo9 dc.l 0
            dc.l 0
            dc.l 0

  XDEF SAMPext,Same,NoMem,ReadErr,WriteErr,Not8SVX,Cancel,CantFind
  XDEF CantCreate,Quit,LibErr,Success,_BUFFER,Directions

SAMPext        dc.b  '.SAMP',0
Same           dc.b  'Would you like to save this SAMP file as',0
NoMem          dc.b  'No memory for copy buffer.',0
ReadErr        dc.b  'A read error occurred.',0
WriteErr       dc.b  'A write error occurred.',0
Not8SVX        dc.b  'Not an IFF 8SVX file',0
Cancel         dc.b  'Conversion canceled',0
CantFind       dc.b  'Cannot find the source file.',0
CantCreate     dc.b  'Cannot create the destination file.',0
WINTITLE       dc.b  '8SVX to SAMP Conversion  ® 1989  dissidents',0
Quit           dc.b  1
LibErr         dc.b  'FileIO library failure',0
Success        dc.b  '8SVX file successfully converted.',0

 ; Use the following string area for filename buffer
_BUFFER:
GfxName        dc.b  'graphics.library',0
IntuitionName  dc.b  'intuition.library',0
RequesterName  dc.b  'requester.library',0
FileReqErr     dc.b  'Cannot find the "requester.library"',0
IOerR          dc.b  'Cannot get a FileIO structure.',0
Click          dc.b  'Click mouse for file selection or CLOSEWINDOW.',0
FONTNAME       dc.b  'topaz.font',0
Directions:
 dc.b 'This program will convert an IFF 8SVX sampled sound file to the SAMP',0 
 dc.b 'format. It requires the FileIO library in the libs drawer of your boot',0
 dc.b 'disk. Click the mouse select button to begin filename selection, or',0
 dc.b 'click on the CLOSE gadget to exit. Select the name of the 8SVX file to',0
 dc.b 'be converted via the FileIO requester, then select OK. If the file is',0
 dc.b 'successfully loaded and converted, you will be prompted to save the',0
 dc.b 'new SAMP file in the same directory with a .SAMP extention added. You',0
 dc.b 'may otherwise choose to enter a new name via the FileIO string gadgets.',0
 dc.b 'If the SAMP file is successfully saved, a requester will indicate so.',0
 dc.b 'This program was written by Jeff Glatt of dissidents.',0
Family:
 dc.b 'Press one of the following keys for the instrument family',0
 dc.b ' ',0
 dc.b 'Q = String',0
 dc.b 'W = Woodwind',0
 dc.b 'E = Keyboard',0
 dc.b 'R = Guitar',0
 dc.b 'T = Voice',0
 dc.b 'Y = Drum1',0
 dc.b 'U = Drum2',0
 dc.b 'I = Percussion1',0
 dc.b 'O = Brass1',0
 dc.b 'P = Brass2',0
 dc.b 'A = Cymbal',0
 dc.b 'S = Effect1',0
 dc.b 'D = Effect2',0
 dc.b 'F = Synth',0
 dc.b 'Hit RETURN for Unknown',0
SPACES:
 dc.b '                                                                        ',0
 
 CNOP 0,2
TYPES dc.l STRING,WOOD,KEY,GUIT,VOICE,DR1,DR2,PER1,BRASS1,BRASS2
      dc.l CYMBAL,EFF1,EFF2,SYNTH
STRING: dc.b 15-1
 dc.b 'Q = Violin bowed',0
 dc.b 'W = Violin pluck',0
 dc.b 'E = Violin Glissando',0
 dc.b 'R = Violin tremulo',0
 dc.b 'T = Viola bow',0
 dc.b 'Y = Viola pluck',0
 dc.b 'U = Viola glis.',0
 dc.b 'I = Viola trem.',0
 dc.b 'O = Cello bow',0
 dc.b 'P = Cello pluck',0
 dc.b 'A = Cello glis.',0
 dc.b 'S = Cello trem.',0
 dc.b 'D = Bass bowed',0
 dc.b 'F = Bass pluck (jazz bass)',0
 dc.b 'G = Bass trem.',0
BRASS1 dc.b 14-1
 dc.b 'Q = Baritone sax',0
 dc.b 'W = Bari Growl',0
 dc.b 'E = Tenor Sax',0
 dc.b 'R = Tenor Growl',0
 dc.b 'T = Alto Sax',0
 dc.b 'Y = Alto Growl',0
 dc.b 'U = Soprano sax',0
 dc.b 'I = Soprano Growl',0
 dc.b 'O = Trumpet',0
 dc.b 'P = Muted Trumpet',0
 dc.b 'A = Trumpet Drop',0
 dc.b 'S = Trombone',0
 dc.b 'D = Trombone slide',0
 dc.b 'F = Trombone Mute',0
BRASS2: dc.b 4-1
 dc.b 'Q = French Horn',0
 dc.b 'W = Tuba',0
 dc.b 'E = Flugal Horn',0
 dc.b 'R = English Horn',0
WOOD: dc.b 9-1
 dc.b 'Q = Clarinet',0
 dc.b 'W = Flute',0
 dc.b 'E = Pan Flute',0
 dc.b 'R = Oboe',0
 dc.b 'T = Piccolo',0
 dc.b 'Y = Recorder',0
 dc.b 'U = Basson',0
 dc.b 'I = Bass Clarinet',0
 dc.b 'O = Harmonica',0
KEY: dc.b 10-1
 dc.b 'Q = Grand Piano',0
 dc.b 'W = Elec. Piano',0
 dc.b 'E = HonkyTonk Piano',0
 dc.b 'R = Toy Piano',0
 dc.b 'T = Harpsichord',0
 dc.b 'Y = Clavinet',0
 dc.b 'U = Pipe Organ',0
 dc.b 'I = Hammond B-3',0
 dc.b 'O = Farfisa Organ',0
 dc.b 'P = Harp',0
DR1: dc.b 15-1
 dc.b 'Q = Kick',0
 dc.b 'W = Snare',0
 dc.b 'E = Tom',0
 dc.b 'R = Timbales',0
 dc.b 'T = Conga Hit',0
 dc.b 'Y = Conga Slap',0
 dc.b 'U = Brush Snare',0
 dc.b 'I = Elec. Snare',0
 dc.b 'O = Elec. Kick',0
 dc.b 'P = Elec. Tom',0
 dc.b 'A = RimShot',0
 dc.b 'S = Cross Stick',0
 dc.b 'D = Bongo',0
 dc.b 'F = Steel Drum',0
 dc.b 'G = Double Tom',0
DR2: dc.b 3-1
 dc.b 'Q = Timbani',0
 dc.b 'W = Timpani Roll',0
 dc.b 'E = Log Drum',0
PER1: dc.b 12-1
 dc.b 'Q = Block',0
 dc.b 'W = Cowbell',0
 dc.b 'E = Triangle',0
 dc.b 'R = Tambourine',0
 dc.b 'T = Whistle',0
 dc.b 'Y = Maracas',0
 dc.b 'U = Bell',0
 dc.b 'I = Vibes',0
 dc.b 'O = Marimba',0
 dc.b 'P = Xylophone',0
 dc.b 'A = Tubular Bells',0
 dc.b 'S = Glockenspeil',0
CYMBAL: dc.b 10-1
 dc.b 'Q = Closed Hihat',0
 dc.b 'W = Open Hihat',0
 dc.b 'E = Step Hihat',0
 dc.b 'R = Ride',0
 dc.b 'T = Bell Cymbal',0
 dc.b 'Y = Crash',0
 dc.b 'U = Choke Crash ',0
 dc.b 'I = Gong',0
 dc.b 'O = Bell Tree',0
 dc.b 'P = Cymbal Roll',0
GUIT: dc.b 15-1
 dc.b 'Q = Electric',0
 dc.b 'W = Muted Electric',0
 dc.b 'E = Distorted',0
 dc.b 'R = Acoustic',0
 dc.b 'T = 12-String',0
 dc.b 'Y = Nylon String',0
 dc.b 'U = Power Chord',0
 dc.b 'I = Harmonics',0
 dc.b 'O = Chord Strum',0
 dc.b 'P = Banjo',0
 dc.b 'A = Elec. Bass',0
 dc.b 'S = Slapped Bass',0
 dc.b 'D = Popped Bass',0
 dc.b 'F = Sitar',0
 dc.b 'G = Mandolin',0
VOICE: dc.b 7-1
 dc.b 'Q = Male Ahh',0
 dc.b 'W = Female Ahh',0
 dc.b 'E = Male OOO',0
 dc.b 'R = Female OOO',0
 dc.b 'T = Female Breathy',0
 dc.b 'Y = Laugh',0
 dc.b 'U = Whistle',0
EFF1: dc.b 15-1
 dc.b 'Q = Explosion',0
 dc.b 'W = Gunshot',0
 dc.b 'E = Creaking Door Open',0
 dc.b 'R = Door Slam',0
 dc.b 'T = Door Close',0
 dc.b 'Y = Spacegun',0
 dc.b 'U = Jet Engine',0
 dc.b 'I = Propeller',0
 dc.b 'O = Helocopter',0
 dc.b 'P = Broken Glass',0
 dc.b 'A = Thunder',0
 dc.b 'S = Rain',0
 dc.b 'D = Birds',0
 dc.b 'F = Jungle Noises',0
 dc.b 'G = Footstep',0
EFF2: dc.b 15-1
 dc.b 'Q = Machine Gun',0
 dc.b 'W = Telephone',0
 dc.b 'E = Dog bark',0
 dc.b 'R = Dog Growl',0
 dc.b 'T = Boat Whistle',0
 dc.b 'Y = Ocean',0
 dc.b 'U = Wind',0
 dc.b 'I = Crowd Boos',0
 dc.b 'O = Applause',0
 dc.b 'P = Roaring Crowds',0
 dc.b 'A = Scream',0
 dc.b 'S = Sword Clash',0
 dc.b 'D = Avalance',0
 dc.b 'F = Bouncing Ball',0
 dc.b 'G = Ball against bat or club',0
SYNTH dc.b 6-1
 dc.b 'Q = Strings',0
 dc.b 'W = Square',0
 dc.b 'E = Sawtooth',0
 dc.b 'R = Triangle',0
 dc.b 'T = Sine',0
 dc.b 'Y = Noise',0
NumOfChoices dc.b 0

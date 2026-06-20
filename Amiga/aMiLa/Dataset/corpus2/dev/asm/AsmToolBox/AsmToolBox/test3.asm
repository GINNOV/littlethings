; TEST3.ASM by Warren A. Ring
;
; This program shows how the warlib disk I/O routines work.  You can open,
; create, rename, and delete files.  Once open, you can close the file, or
; read, write, or seek in it.  You can also display or modify records.
; In this example, we can create files with 16-byte fixed record lengths.
; Each record contains a phrase padded with spaces to make it 16 characters
; long.  After exiting this program, you can see the exact hex bytes by
; entering "1>type <filename> opt h", where <filename> is the name of the
; file you created.

   section code

   include "macros.asm"

   Start                   ;Perform starting housekeeping
X1
   Display <'O)pen, C)reate, R)ename, D)elete, E)xit: '>
   ReadCon #Selection      ;Get a selection from the console

   StrCmp  #Selection,#O   ;If the selection is not "O",
   BNE     X2              ; then jump to X2
   Display <'Which file? '>
   ReadCon #Filename1      ;Get a file name from the console
   Open    #Filename1,File1;Try to open the file
   BEQ     X1A             ;If the file did not open, then jump to X1A
   Display <'The file is open',LF>
   BRA     X10             ;Jump to X10
X1A
   Display <'There is no such file',LF>
   BRA     X1              ;Jump to X1

X2
   StrCmp  #Selection,#C   ;If the selection is not "C",
   BNE     X3              ; then jump to X3
   Display <'Which file? '>
   ReadCon #Filename1      ;Get a file name from the console
   Create  #Filename1,File1;Try to create the file
   BEQ     X2A             ;If the file was not created, then jump to X2A
   Display <'The file is open',LF>
   BRA     X10             ;Jump to X10
X2A
   Display <'I cannot create it',LF>
   BRA     X1              ;Jump to X1

X3
   StrCmp  #Selection,#R   ;If the selection is not "R",
   BNE     X4              ; then jump to X4
   Display <'Which file? '>
   ReadCon #Filename1      ;Get the old file name from the console
   Display <'New filename? '>
   ReadCon #Filename2      ;Get the new file name
   Rename  #Filename1,#Filename2;Try to rename the file
   BEQ     X3A             ;If the file was not renamed, then jump to X3A
   Display <'The file is renamed',LF>
   BRA     X1              ;Jump to X1
X3A
   Display <'I cannot rename it',LF>
   BRA     X1              ;Jump to X1

X4
   StrCmp  #Selection,#D   ;If the selection was not "D",
   BNE     X5              ; then jump to X5
   Display <'Which file? '>
   ReadCon #Filename1      ;Get a file name from the console
   Delete  #Filename1      ;Try to delete the file
   BEQ     X4A             ;If the file was not deleted, then jump to X4A
   Display <'The file is deleted',LF>
   BRA     X1              ;Jump to X1
X4A
   Display <'I cannot delete it',LF>
   BRA     X1              ;Jump to X1

X5
   StrCmp  #Selection,#E   ;If the selection was not "E",
   BNE     X6              ; then jump to X6
   Display <'Exiting...',10>
   BRA     X99             ;Jump to X99

X6
   BRA     X1              ;Jump to X1

X10
   Display <'C)lose, R)ead, W)rite, D)isplayRec, M)odifyRec, S)eek: '>
   ReadCon #Selection      ;Get a selection from the console
   StrCmp  #Selection,#C   ;If the selection was not "C",
   BNE     X11             ; then jump to X11
   Close   File1           ;Try to close the file (ignore any errors)
   BRA     X1              ;Jump to X1

X11
   StrCmp  #Selection,#R   ;If the selection was not "R",
   BNE     X12             ; then jump to X12
   Read    File1,#Record1  ;Read a record from the file
   ADDQ.L  #1,RecNum1      ;Increment the record number
   StrLen  #Record1        ;If there were some bytes read,
   BNE     X10             ; then jump to X10
   Display <'Unwritten record',LF>
   BRA     X10             ;Jump to X10

X12
   StrCmp  #Selection,#W   ;If the selection was not "W",
   BNE     X13             ; then jump to X13
   ADDQ.L  #1,RecNum1      ;Increment the record number
   Write   File1,#Record1  ;Write a record to the file
   BGT     X10             ;If any bytes were written, then jump to X10
   Display <'Error',LF>
   BRA     X10             ;Jump to X10

X13
   StrCmp  #Selection,#D   ;If the selection was not "D",
   BNE     X14             ; then jump to X14
   Display <'Record '>
   ItoA    RecNum1,#Selection;Convert the record number to ASCII
   WritCon #Selection      ;Display the record number
   Display <', the word is "'>
   WritCon #Record1        ;Display the record
   Display <'"',LF>
   BRA     X10             ;Jump to X10

X14
   StrCmp  #Selection,#M   ;If the selection was not "W",
   BNE     X15             ; then jump to X15
   Display <'Enter a new word: '>
   ReadCon #Word           ;Get a line from the console
   StrCpy  #Spaces,#Record1;Pad the line with spaces to make it
   StrCpy  #Word,#Record1  ; 16 chars long
   MOVE.L  #16,D0          ;Assign the line length to 16 bytes
   MOVE.L  D0,Record1+4
   BRA     X10             ;Jump to X10

X15
   StrCmp  #Selection,#S   ;If the selection was not "S",
   BNE     X16             ; then jump to X16
   Display <'Enter the record number: '>
   ReadCon #Selection      ;Get a record number from the console
   AtoI    #Selection,RecNum1;Convert the record number from ASCII to binary
   MOVE.L  RecNum1,D0      ;Convert the record number to a file offset
   LSL.L   #4,D0           ; (by multiplying the record number by 16)
   MOVE.L  D0,File1Offset
   Seek    File1,File1Offset;Seek to the file offset
   BRA     X10             ;Jump to X10

X16
   BRA     X10             ;Jump to X10

X99
   Exit                ;Perform ending housekeeping, and exit

   include "warlib.asm"

   section data

       String  C,'C'
       String  D,'D'
       String  E,'E'
       String  M,'M'
       String  O,'O'
       String  R,'R'
       String  S,'S'
       String  W,'W'
       String  Spaces,<'                '>

       StrBuf  Filename1,16
       StrBuf  Filename2,16
       StrBuf  Word,16
       StrBuf  Record1,16
       StrBuf  Selection,16

File1          DC.L    0
RecNum1        DC.L    0
File1Offset    DC.L    0

   end

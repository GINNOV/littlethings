; WARLIB.ASM   Library routines by Warren A. Ring

OpenDOSLibrary

;This routine opens the DOS liibrary

   MOVEM.L D0/A1/A5-A6,-(A7)   ;(Push registers)

   MOVE.L  A0,ScanPointer      ;Set the ScanPointer and ScanCounter to scan
   MOVE.L  D0,ScanCounter      ; the CLI line

   MOVE.L  _AbsExecBase,A6     ;Open the dos library
   LEA.L   DosName,A1
   MOVEQ   #0,D0               ;(Specify "any version")
   JSR     _LVOOpenLibrary(A6)
   MOVE.L  D0,DosLibraryHandle

   MOVE.L  DosLibraryHandle,A5 ;Save the console
   JSR     _LVOInput(A5)       ; input handle
   MOVE.L  D0,ConIn            ; locally

   MOVE.L  DosLibraryHandle,A5 ;Save the console
   JSR     _LVOOutput(A5)      ; output handle
   MOVE.L  D0,ConOut           ; locally

   MOVEM.L (A7)+,D0/A1/A5-A6   ;(Pop registers)

   RTS                 ;Return

DosName   DC.B    'dos.library',0
   CNOP    0,2


CloseDOSLibrary

;This routine closes the DOS library

   MOVEM.L A1/A6,-(A7)         ;(Push registers)

   MOVE.L  _AbsExecBase,A6     ;Close the dos
   MOVE.L  DosLibraryHandle,A1 ; library
   JSR     _LVOCloseLibrary(A6)

   MOVEM.L (A7)+,A1/A6         ;(Pop registers)

   RTS                         ;Return


OpenFile

;This routine opens an already-existing file

;In:  A0 => a string buffer containing the filename
;Out: A1 => the file handle (0 = file doesn't exist)
;     Zero Flag = Clear if the file exists,
;                 Set if the file doesn't exist

   MOVEM.L D0-D3/A0/A6,-(A7)      ;(Push registers)

;First, we must convert the filename from string buffer form to "C" form
   ADDQ.L  #4,A0               ;(Make A0 point to the current useage of
                               ; the filename string buffer)
   MOVE.L  (A0)+,D1            ;Set the byte counter (D1) to the current
                               ; useage of the string buffer
                               ;(Make A0 point to the first data byte of
                               ; the filename)
   MOVE.L  D1,D2               ;Create a temporary buffer on the stack
   ADDQ.L  #3,D2               ; of the length of the filename, +1, rounded
   ANDI.L  #$FFFE,D2           ; up to the next word boundary
   SUB.L   D2,A7               ;(D2 = the size of the temporary buffer on
                               ; the stack)
   MOVE.L  A7,A2               ;(Make A2 point to the temporary buffer)
   MOVE.L  A7,A3               ;(Make A3 point to the temporary buffer)
   SUBQ.L  #1,D1
OpenFile2
   MOVE.B  (A0)+,(A2)+         ;Copy the filename from the filename string
   DBRA    D1,OpenFile2
   MOVE.B  #0,(A2)

   MOVE.L  A3,D1               ;Open the file
   MOVEM.L A1/D2,-(A7)
   MOVE.L  #MODE_OLDFILE,D2
   MOVE.L  DosLibraryHandle,A6
   JSR     _LVOOpen(A6)
   MOVEM.L (A7)+,A1/D2

   ADD.L   D2,A7               ;Delete the temporary buffer

   MOVE.L  D0,(A1)             ;(Set the caller's file handle value)
   MOVEM.L (A7)+,D0-D3/A0/A6   ;(Pop registers)
   RTS                         ;Return


CreateFile

;This routine creates a new file

;In:  A0 => a string buffer containing the filename
;Out: A1 => the file handle (0 = file could not be created)
;     Zero Flag = Clear if the file was created,
;                 Set if the file wasn't created

;Notes: This routine deletes any already-existing file of the same name
;
;       A create operation may fail because an already-existing file under
;       the same name has its protection attribute set, or there is
;       insufficient disk space to create the new file.

   MOVEM.L D0-D3/A0/A6,-(A7)      ;(Push registers)

;First, we must convert the filename from string buffer form to "C" form
   ADDQ.L  #4,A0               ;(Make A0 point to the current useage of
                               ; the filename string buffer)
   MOVE.L  (A0)+,D1            ;Set the byte counter (D1) to the current
                               ; useage of the string buffer
                               ;(Make A0 point to the first data byte of
                               ; the filename)
   MOVE.L  D1,D2               ;Create a temporary buffer on the stack
   ADDQ.L  #3,D2               ; of the length of the filename, +1, rounded
   ANDI.L  #$FFFE,D2           ; up to the next word boundary
   SUB.L   D2,A7               ;(D2 = the size of the temporary buffer on
                               ; the stack)
   MOVE.L  A7,A2               ;(Make A2 point to the temporary buffer)
   MOVE.L  A7,A3               ;(Make A3 point to the temporary buffer)
   SUBQ.L  #1,D1
CreateFile2
   MOVE.B  (A0)+,(A2)+         ;Copy the filename from the filename string
   DBRA    D1,CreateFile2
   MOVE.B  #0,(A2)

   MOVE.L  A3,D1               ;Create the file
   MOVEM.L A1/D2,-(A7)
   MOVE.L  #MODE_NEWFILE,D2
   MOVE.L  DosLibraryHandle,A6
   JSR     _LVOOpen(A6)
   MOVEM.L (A7)+,A1/D2

   ADD.L   D2,A7               ;Delete the temporary buffer

   MOVE.L  D0,(A1)             ;(Set the caller's file handle value)
   MOVEM.L (A7)+,D0-D3/A0/A6   ;(Pop registers)
   RTS                         ;Return


DeleteFile

;This routine deletes a file

;In:  A0 => a string buffer containing the filename
;Out: D0 = the status (0 = file could not be deleted)

;Note:  A delete operation may fail because the existing file has its
;       protection attribute set.

   MOVEM.L D0-D3/A0/A2/A3/A6,-(A7)      ;(Push registers)

;First, we must convert the filename from string buffer form to "C" form
   ADDQ.L  #4,A0               ;(Make A0 point to the current useage of
                               ; the filename string buffer)
   MOVE.L  (A0)+,D1            ;Set the byte counter (D1) to the current
                               ; useage of the string buffer
                               ;(Make A0 point to the first data byte of
                               ; the filename)
   MOVE.L  D1,D2               ;Create a temporary buffer on the stack
   ADDQ.L  #3,D2               ; of the length of the filename, +1, rounded
   ANDI.L  #$FFFE,D2           ; up to the next word boundary
   SUB.L   D2,A7               ;(D2 = the size of the temporary buffer on
                               ; the stack)
   MOVE.L  A7,A2               ;(Make A2 point to the temporary buffer)
   MOVE.L  A7,A3               ;(Make A3 point to the temporary buffer)
   SUBQ.L  #1,D1
DeleteFile2
   MOVE.B  (A0)+,(A2)+         ;Copy the filename from the filename string
   DBRA    D1,DeleteFile2
   MOVE.B  #0,(A2)

   MOVE.L  A3,D1               ;Delete the file
   MOVEM.L A1,-(A7)
   MOVE.L  DosLibraryHandle,A6
   JSR     _LVODeleteFile(A6)
   MOVEM.L (A7)+,A1

   ADD.L   D2,A7               ;Delete the temporary buffer

   TST.L   D0                  ;(Set/clear the Zero Flag)
   MOVEM.L (A7)+,D0-D3/A0/A2/A3/A6   ;(Pop registers)
   RTS                         ;Return


ReadFile

;This routine reads a record from a file

;In:  A0 => the file handle
;     A1 => a string buffer to receive the data from the file
;Out: D0 = the number of characters read from the file
;
;Note: This routine overwrites any data already in the string buffer

   MOVEM.L D1-D3/A0-A1/A5,-(A7)  ;(Push registers)

   MOVE.L  A0,D1            ;(File specifier)
   MOVE.L  A1,D2            ;(Buffer location)
   ADDQ.L  #8,D2
   MOVE.L  (A1),D3          ;(# of bytes to get)
   MOVEM.L A1,-(A7)
   MOVE.L  DosLibraryHandle,A5
   JSR     _LVORead(A5)
   MOVEM.L (A7)+,A1
   ADDQ.L  #4,A1           ;Set the current useage to the number of
   MOVE.L  D0,(A1)         ; bytes read

   MOVEM.L (A7)+,D1-D3/A0-A1/A5 ;(Pop registers)

   RTS                      ;Return
   

WriteFile

;This routine writes a record to a file

;In:  A0 => the file handle
;     A1 => a string buffer containing the data for the file
;Out: D0 = the number of characters written to the file
;          (-1 = write error, possibly disk full)

   MOVEM.L D1-D3/A0-A1/A5,-(A7)  ;(Push registers)

   MOVE.L  A0,D1            ;(File specifier)
   MOVE.L  A1,D2            ;(Buffer location)
   ADDQ.L  #8,D2
   ADDQ.L  #4,A1
   MOVE.L  (A1),D3          ;(# of bytes to write)
   MOVE.L  DosLibraryHandle,A5
   JSR     _LVOWrite(A5)

   MOVEM.L (A7)+,D1-D3/A0-A1/A5 ;(Pop registers)

   RTS                      ;Return


SeekFile

;This routine moves the position in a file at which the next read or write
; is to take place.

;In:  A0 => the file handle
;     D0 = the offset
;     D1 = the mode:
;             -1 = the offset is from the beginning of the file
;              0 = the offset is from the current position in the file
;              1 = the offset is from the end of file
;Out: D0 = the previous position
;          (-1 = seek error)
;
;Notes: When a file is opened, the position at which the next read or write
;       is to take place is the beginning of file.  This position advances
;       to the byte just beyond the end of each record as that record is
;       read, so that if you read a file sequentially, you need never use the
;       Seek system call.
;
;       If you wish to append data to the end of a file, you seek with an
;       offset of zero, and a mode of 1.

   MOVEM.L D1-D3/A0-A1/A5,-(A7)  ;(Push registers)

   MOVE.L  D1,D3           ;(mode)
   MOVE.L  D0,D2           ;(offset)
   MOVE.L  A0,D1           ;(file handle)
   MOVE.L  DosLibraryHandle,A5
   JSR     _LVOSeek(A5)

   MOVEM.L (A7)+,D1-D3/A0-A1/A5 ;(Pop registers)

   RTS                      ;Return

 
CloseFile

;This routine closes a previously-opened file.

;In: A0 => the file handle

   MOVEM.L D1/A0/A5,-(A7)  ;(Push registers)

   MOVE.L  A0,D1
   MOVE.L  DosLibraryHandle,A5
   JSR     _LVOClose(A5)

   MOVEM.L (A7)+,D1/A0/A5  ;(Pop registers)

   RTS                      ;Return


RenameFile

;This routine renames a file

;In:  A0 => a string buffer containing the current filename
;     A1 => a string buffer containing the new filename
;Out: D0 = the status (0 = file could not be renamed)

;Notes: Directory names may be included in the filenames.  Thus, this
;       function can serve as a move function within a volume.
;
;       A delete operation may fail because the destination file already
;       exists, or because a named directory doesn't exist.

   MOVEM.L D1-D3/D7/A0-A4/A6,-(A7);(Push registers)

   MOVE.L  A7,D7               ;(Save the stack pointer in D7)

;First, we must convert the source filename from SB form to "C" form
   ADDQ.L  #4,A0               ;(Make A0 point to the current useage of
                               ; the filename string buffer)
   MOVE.L  (A0)+,D1            ;Set the byte counter (D1) to the current
                               ; useage of the string buffer
                               ;(Make A0 point to the first data byte of
                               ; the filename)
   MOVE.L  D1,D2               ;Create a temporary buffer on the stack
   ADDQ.L  #3,D2               ; of the length of the filename, +1, rounded
   ANDI.L  #$FFFE,D2           ; up to the next word boundary
   SUB.L   D2,A7               ;(D2 = the size of the temporary buffer on
                               ; the stack)
   MOVE.L  A7,A2               ;(Make A2 point to the temporary buffer)
   MOVE.L  A7,A3               ;(Make A3 point to the temporary buffer)
   SUBQ.L  #1,D1
RenameFile1
   MOVE.B  (A0)+,(A2)+         ;Copy the filename from the filename string
   DBRA    D1,RenameFile1
   MOVE.B  #0,(A2)

;Next, we must convert the destination filename from SB form to "C" form
   ADDQ.L  #4,A1               ;(Make A1 point to the current useage of
                               ; the filename string buffer)
   MOVE.L  (A1)+,D1            ;Set the byte counter (D1) to the current
                               ; useage of the string buffer
                               ;(Make A1 point to the first data byte of
                               ; the filename)
   MOVE.L  D1,D2               ;Create a temporary buffer on the stack
   ADDQ.L  #3,D2               ; of the length of the filename, +1, rounded
   ANDI.L  #$FFFE,D2           ; up to the next word boundary
   SUB.L   D2,A7               ;(D2 = the size of the temporary buffer on
                               ; the stack)
   MOVE.L  A7,A2               ;(Make A2 point to the temporary buffer)
   MOVE.L  A7,A4               ;(Make A4 point to the temporary buffer)
   SUBQ.L  #1,D1
RenameFile2
   MOVE.B  (A1)+,(A2)+         ;Copy the filename from the filename string
   DBRA    D1,RenameFile2
   MOVE.B  #0,(A2)

;Now we rename the file
   MOVE.L  A3,D1               ;Rename the file
   MOVE.L  A4,D2
   MOVE.L  DosLibraryHandle,A6
   JSR     _LVORename(A6)

   MOVE.L  D7,A7               ;(Restore the stack pointer)
   TST.L   D0                  ;(Set/clear the Zero Flag)
   MOVEM.L (A7)+,D1-D3/D7/A0-A4/A6;(Pop registers)
   RTS                         ;Return


DisplayCrlf
           WritCon #DisplayCrlf_7
           RTS
DisplayCrlf_7
           DC.L    1,1
           DC.B    10
           CNOP    0,2


DisplaySpace
           WritCon #DisplaySpace_7
           RTS
DisplaySpace_7
           DC.L    1,1
           DC.B    ' '
           CNOP    0,2


Left_              ;BASIC Fn: B$ = Left$(A$, I)
                   ;         <A1>       <A0> D0

                   ;In: A0 => source buffer
                   ;    A1 => dest buffer
                   ;    D0 = Number of bytes to copy

   MOVEM.L D0-D2/A0-A1,-(A7) ;(Push registers)

   MOVE.L  (A1),D2 ;(Set D2 to the max length of B$)

   ADDQ.L  #4,A1   ;(Make A1 point to the current useage of B$)
   MOVE.L  #0,(A1) ;Set the current useage of B$ to zero

   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVE.L  D0,D1   ;Set the byte counter (D1) to the minimum of: (1) I,
   CMP.L   (A0),D1 ; (2) the current useage of A$, (3) and the maximum
   BLE     Left_1  ; length of B$
   MOVE.L  (A0),D1
Left_1
   CMP.L   D2,D1
   BLE     Left_2
   MOVE.L  D2,D1
Left_2

   TST.L   D1      ;If the byte counter is 0 or negative,
   BLE     Left_9  ; then jump to Left_9
   MOVE.L  D1,(A1) ;Set the current useage of B$ to the byte counter
   ADDQ.L  #4,A0   ;(Make A0 point to the first data byte of A$)
   ADDQ.L  #4,A1   ;(Make A1 point to the first data byte of B$)

   SUBI.L  #1,D1   ;Copy the data bytes from A$ to B$
Left_3
   MOVE.B  (A0)+,(A1)+
   DBRA    D1,Left_3

Left_9
   MOVEM.L (A7)+,D0-D2/A0-A1 ;(Pop registers)
   RTS             ;Return


Mid_               ;BASIC Fn: B$ = Mid$(A$, I, J)
                   ;         <A1>     <A0> D0 D1

                   ;In: A0 => source buffer
                   ;    A1 => dest buffer
                   ;    D0 = The position in A$ to start copying
                   ;    D1 = Number of bytes to copy

   MOVEM.L D0-D3/A0-A1,-(A7) ;(Push registers)

   MOVE.L  (A1),D2 ;(Set D2 to the max length of B$)

   ADDQ.L  #4,A1   ;(Make A1 point to the current useage of B$)
   MOVE.L  #0,(A1) ;Set the current useage of B$ to zero

   TST.L   D0      ;If I is 0 or negative, then jump to Mid_9
   BLE     Mid_9

   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVE.L  (A0),D3 ;Set the byte counter (D3) to the minimum of: (1) J,
   SUB.L   D0,D3   ; (2) the current useage of A$ - I + 1, and (3) the
   ADDQ.L  #1,D3   ; maximum length of B$
   CMP.L   D1,D3
   BLE     Mid_1
   MOVE.L  D1,D3
Mid_1
   CMP.L   D2,D3
   BLE     Mid_2
   MOVE.L  D2,D3
Mid_2

   TST.L   D3      ;If the byte counter is 0 or negative,
   BLE     Mid_9  ; then jump to Mid_9
   MOVE.L  D3,(A1) ;Set the current useage of B$ to the byte counter
   ADDQ.L  #4,A0   ;(Make A0 point to the first data byte of A$)
   ADDQ.L  #4,A1   ;(Make A1 point to the first data byte of B$)

   ADDA.L  D0,A0   ;(Make A0 point to byte I in A$)
   SUBQ.L  #1,A0
   SUBI.L  #1,D3   ;Copy the data bytes from A$ to B$
Mid_3
   MOVE.B  (A0)+,(A1)+
   DBRA    D3,Mid_3

Mid_9
   MOVEM.L (A7)+,D0-D3/A0-A1 ;(Pop registers)
   RTS             ;Return


Right_             ;BASIC Fn: B$ = Right$(A$, I)
                   ;         <A1>        <A0> D0

                   ;In: A0 => source buffer
                   ;    A1 => dest buffer
                   ;    D0 = The number of bytes in A$, from the right end,
                   ;         to start copying

   MOVEM.L D0-D2/A0-A1,-(A7) ;(Push registers)

   MOVE.L  (A1),D2 ;(Set D2 to the max length of B$)

   ADDQ.L  #4,A1   ;(Make A1 point to the current useage of B$)
   MOVE.L  #0,(A1) ;Set the current useage of B$ to zero

   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVE.L  D0,D1   ;Set the byte counter (D1) to the minimum of: (1) I,
   CMP.L   (A0),D1 ; (2) the current useage of A$, (3) the max length of B$
   BLE     Right_1
   MOVE.L  (A0),D1
Right_1
   CMP.L   D2,D1
   BLE     Right_2
   MOVE.L  D2,D1
Right_2

   TST.L   D1      ;If the byte counter is 0 or negative,
   BLE     Right_9 ; then jump to Right_9
   MOVE.L  D1,(A1) ;Set the current useage of B$ to the byte counter)
   MOVE.L  (A0),D2 ;(Set D2 to the current length of A$)
   ADDQ.L  #4,A0   ;(Make A0 point to the first data byte of A$)
   ADDQ.L  #4,A1   ;(Make A1 point to the first data byte of B$)
   SUB.L   D1,D2   ;(Make A0 point to the last byte in A$, minus the
   ADDA.L  D2,A0   ; byte counter)
   SUBQ.L  #1,D1   ;Copy the data bytes from A$ to B$
Right_3
   MOVE.B  (A0)+,(A1)+
   DBRA    D1,Right_3

Right_9
   MOVEM.L (A7)+,D0-D2/A0-A1 ;(Push registers)
   RTS             ;Return


StrCpy_            ;BASIC Fn: B$ = A$
                   ;         <A1> <A0>

                   ;In: A0 => source buffer (A$)
                   ;    A1 => dest buffer (B$)

   MOVEM.L D0,-(A7);(Push registers)
   MOVE.L  (A0),D0 ;Set the number of bytes to copy to the max length of A$
   JSR     Left_   ;Copy the data bytes from A$ to B$
   MOVE.L  (A7)+,D0;(Pop registers)
   RTS             ;Return


StrCat_            ;BASIC Fn: B$ = B$ + A$

                   ;In: A0 => source buffer (A$)
                   ;    A1 => dest buffer (B$)

   MOVEM.L D0-D2/A0-A1,-(A7) ;(Push registers)

   MOVE.L  (A1),D0 ;(Set D0 to the max length of B$)
   ADDQ.L  #4,A1   ;(Make A1 point to the current useage of B$)
   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVE.L  (A1),D2 ;(Set D2 to the current useage of B$)
   MOVE.L  (A0),D1 ;Set the byte counter (D1) to the current useage of A$
   ADD.L   (A1),D1 ; plus the current useage of B$
   CMP.L   D0,D1   ;If the byte counter > the max length of B$,
   BLE     StrCat_1; then set the byte counter to the max useage of B$
   MOVE.L  D0,D1
StrCat_1
   MOVE.L  D1,(A1) ;Set the current useage of B$ to the byte counter
   SUB.L   D2,D1   ;Subtract the current useage of B$ from the byte counter
   TST.L   D1      ;If the byte counter is now zero,
   BEQ     StrCat_9; then jump to StrCat_9
   ADDQ.L  #4,A0   ;(Make A0 point to the first data byte of A$)
   ADDQ.L  #4,A1   ;(Make A1 point to the byte after the last byte currently
   ADD.L   D2,A1   ; used by B$)
   SUBQ.L  #1,D1   ;Copy the bytes from A$ to B$
StrCat_2
   MOVE.B  (A0)+,(A1)+
   DBRA    D1,StrCat_2
StrCat_9

   MOVEM.L (A7)+,D0-D2/A0-A1 ;(Pop registers)

   RTS             ;Return


StrCmp_            ;C fn: I = (A$==B$);

;This routine indicates whether or not A$ = B$

;In: A0 => source buffer (A$)
;    A1 => dest buffer (B$)
;Out: <Zero flag> = Set if the strings are equal,
;                 = Clear if the strings are unequal

   MOVEM.L D0/A0-A1,-(A7) ;(Push registers)

   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   ADDQ.L  #4,A1   ;(Make A1 point to the current useage of B$)

   MOVE.L  (A0),D0 ;Set the byte counter (D0) to the current useage of A$

   CMPM.L  (A0)+,(A1)+;If the current useage of A$ <> the current useage
   BNE     StrCmp_9; of B$, then jump to StrCmp_9

   SUBQ.L  #1,D0   ;If the A$ data bytes <> the B$ data bytes,
StrCmp_5           ; then jump to StrCmp_9
   CMPM.B  (A0)+,(A1)+
   BNE     StrCmp_9
   DBRA    D0,StrCmp_5
   ORI     #$4,CCR ;Set the zero flag

StrCmp_9
   MOVEM.L (A7)+,D0/A0-A1 ;(Pop registers)

   RTS             ;Return


StrLen_            ;BASIC Fn: I = LEN(A$)

;This routine indicates the current length of a string

;In:  A0 => the buffer (A$)
;Out: D0 = the current useage of A$

   MOVEM.L A0,-(A7)    ;(Push registers)

   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVE.L  (A0),D0 ;Set D0 to the current useage of A$

   MOVEM.L (A7)+,A0    ;(Pop registers)

   RTS             ;Return


Scanw_

;This routine scans a string for the next visible word

;In:  ScanPointer => the next byte in the string to be scanned
;     ScanCounter = the number of bytes in the string remaining
;                   to be scanned
;     A0 => the dest buffer
;Out: ScanPointer, ScanCounter are updated
;
;Note: This routine skips over spaces, tabs, and other invisible characters

   MOVEM.L D0-D2/A0-A2,-(A7)    ;(Push registers)

   MOVE.L  (A0)+,D1;(Set D1 to the max length of A$)
   MOVE.L  A0,A1   ;(Make A1 point to the current length of A$)
   MOVE.L  #0,(A1) ;Set the current useage of A$ to 0
   ADDQ.L  #4,A0   ;Advance the dest buffer pointer (A0) to the first data
                   ; byte of A$
   MOVE.L  ScanPointer,A2;(Set A1 to the scan pointer)
   MOVE.L  ScanCounter,D2;If the scan counter (D2) is zero,
   BEQ     Scanw_9       ; then jump to Scanw_9
Scanw_1
   MOVE.B  (A2)+,D0;Fetch the character at which the scan pointer points,
                   ; and advance the scan pointer
   SUBQ.L  #1,D2   ;Decrement the scan counter
   CMPI.B  #'!',D0 ;If the character is visible, then jump to Scanw_2
   BLT     Scanw_3
   CMPI.B  #$7F,D0
   BLT     Scanw_2
Scanw_3
   TST.L   D2      ;If the scan counter is zero, then jump to Scanw_9
   BEQ     Scanw_9
   BRA     Scanw_1 ;Jump to Scanw_1
Scanw_2
   MOVE.B  D0,(A0)+;Place the character into A$,
                   ; and advance the dest buffer pointer
   ADD.L   #1,(A1) ;Increment the current useage of A$
   CMP.L   (A1),D1 ;If the current useage of A$ = the max length of A$,
   BEQ     Scanw_9 ; then jump to Scanw_9
   TST.L   D2      ;If the scan counter is zero, then jump to Scanw_9
   BEQ     Scanw_9
   MOVE.B  (A2)+,D0;Fetch the character at which the scan pointer points,
                   ; and advance the scan pointer
   SUBQ.L  #1,D2   ;Decrement the scan counter
   CMPI.B  #'!',D0 ; If the character is visible, then jump to Scanw_2
   BCC     Scanw_2

Scanw_9
   MOVE.L  A2,ScanPointer;(Update the scan pointer)
   MOVE.L  D2,ScanCounter;(Update the scan counter)

   MOVEM.L (A7)+,D0-D2/A0-A2    ;(Pop registers)

   RTS             ;Return


Scana_

;This routine scans a string for the next alphanumeric word

;In:  ScanPointer => the next byte in the string to be scanned
;     ScanCounter = the number of bytes in the string remaining
;                   to be scanned
;     A0 => the dest buffer
;Out: ScanPointer, ScanCounter are updated
;
;Note: This routine skips over spaces, tabs, and invisible characters
;      including non-alphanumeric characters

   MOVEM.L D0-D2/A0-A2,-(A7)    ;(Push registers)

   MOVE.L  (A0)+,D1;(Set D1 to the max length of A$)
   MOVE.L  A0,A1   ;(Make A1 point to the current length of A$)
   MOVE.L  #0,(A1) ;Set the current useage of A$ to 0
   ADDQ.L  #4,A0   ;Advance the dest buffer pointer (A0) to the first data
                   ; byte of A$
   MOVE.L  ScanPointer,A2;(Set A1 to the scan pointer)
   MOVE.L  ScanCounter,D2;If the scan counter (D2) is zero,
   BEQ     Scana_9       ; then jump to Scana_9
Scana_1
   MOVE.B  (A2)+,D0;Fetch the character at which the scan pointer points,
                   ; and advance the scan pointer
   SUBQ.L  #1,D2   ;Decrement the scan counter
   CMPI.B  #$30,D0 ;If the character is alphanumeric, then jump to Scana_2
   BLT     Scana_3
   CMPI.B  #$3A,D0
   BLT     Scana_2
   CMPI.B  #$41,D0
   BLT     Scana_3
   CMPI.B  #$5B,D0
   BLT     Scana_2
   CMPI.B  #$61,D0
   BLT     Scana_3
   CMPI.B  #$7B,D0
   BLT     Scana_2
Scana_3
   TST.L   D2      ;If the scan counter is zero, then jump to Scana_9
   BEQ     Scana_9
   BRA     Scana_1 ;Jump to Scana_1
Scana_2
   MOVE.B  D0,(A0)+;Place the character into A$,
                   ; and advance the dest buffer pointer
   ADD.L   #1,(A1) ;Increment the current useage of A$
   CMP.L   (A1),D1 ;If the current useage of A$ = the max length of A$,
   BEQ     Scana_9 ; then jump to Scana_9
   TST.L   D2      ;If the scan counter is zero, then jump to Scana_9
   BEQ     Scana_9
   MOVE.B  (A2)+,D0;Fetch the character at which the scan pointer points,
                   ; and advance the scan pointer
   SUBQ.L  #1,D2   ;Decrement the scan counter
   CMPI.B  #$30,D0 ; If the character is alphanumeric, then jump to Scana_2
   BLT     Scana_4
   CMPI.B  #$3A,D0
   BLT     Scana_2
   CMPI.B  #$41,D0
   BLT     Scana_4
   CMPI.B  #$5B,D0
   BLT     Scana_2
   CMPI.B  #$61,D0
   BLT     Scana_4
   CMPI.B  #$7B,D0
   BLT     Scana_2
Scana_4

Scana_9
   MOVE.L  A2,ScanPointer;(Update the scan pointer)
   MOVE.L  D2,ScanCounter;(Update the scan counter)

   MOVEM.L (A7)+,D0-D2/A0-A2    ;(Pop registers)

   RTS             ;Return


Scanc_

;This routine scans a string for the next character

;In:  ScanPointer => the next byte in the string to be scanned
;     ScanCounter = the number of bytes in the string remaining
;                   to be scanned
;     A0 => the dest buffer
;Out: ScanPointer, ScanCounter are updated
;

   MOVEM.L D0-D2/A0-A2,-(A7)    ;(Push registers)

   MOVEQ.L #0,D0   ;Set the byte counter to 0
   ADDQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVEA.L ScanPointer,A1;(Set A1 to the scan pointer)
   MOVE.L  ScanCounter,D1;(Set D1 to the scan counter)
   BEQ     Scanc_9 ;If the scan counter is 0, then jump to Scanc_9
   MOVE.B  (A1)+,D2;Fetch the character at which the scan pointer points,
                   ; and advance the scan pointer
   SUBQ.L  #1,D1   ;Decrement the scan counter
   ADDQ.L  #4,A0   ;(Make A0 point to the first data byte in A$)
   MOVE.B  D2,(A0) ;Place the character in the buffer
   SUBQ.L  #4,A0   ;(Make A0 point to the current useage of A$)
   MOVEQ.L #1,D0   ;Set the byte counter to 1
Scanc_9
   MOVE.L  D0,(A0) ;Set the current useage in A$ to the byte counter
   MOVE.L  A1,ScanPointer;(Update the scan pointer)
   MOVE.L  D1,ScanCounter;(Update the scan counter)

   MOVEM.L (A7)+,D0-D2/A0-A2    ;(Pop registers)

   RTS             ;Return


ItoA_              ;BASIC Fn: A$ = STR$(I)
                   ;         (A0)      (D0)

;This routine converts a signed integer from binary to a decimal ASCII
; string

   MOVEM.L D0-D4/A0-A4,-(A7) ;(Push registers)

   MOVE.L  #ItoA_values,A1;Set the table pointer (A1) to the beginning of
                   ; the table
   MOVEQ.L #10,D1  ;Set the table counter (D1) to the length of the table
   MOVEQ.L #0,D4   ;Set the character counter (D4) to 0
   MOVE.L  (A0)+,D2;Set the limit value (D2) to the max length of A$
   MOVE.L  A0,A2   ;(Make A2 point to the current useage of A$)
   ADDQ.L  #4,A0   ;(Make A0 and A4 point to the first data byte in A$)
   MOVE.L  A0,A4
   TST.L   D0      ;If I >= 0, then jump to ItoA_1
   BPL     ItoA_1
   MOVE.B  #'-',(A0)+;Place a '-' in A$, and advance the A$ pointer
   ADDQ.L  #1,D4   ;Increment the character counter
   CMP.L   D2,D4   ;If the character counter equals the limit value,
   BEQ     ItoA_5  ; then jump to ItoA_5
   NEG.L   D0      ;Complement I
ItoA_1
   CMP.L   (A1),D0 ;If I >= the table value,
   BCC     ItoA_2  ; then jump to ItoA_2
   ADDQ.L  #4,A1   ;Advance the table pointer
   SUBQ.L  #1,D1   ;Decrement the table counter
   CMPI.L  #1,D1   ;If the table counter is not yet 1,
   BNE     ItoA_1  ; then jump to ItoA_1
ItoA_2
   MOVE.B  #'0',(A0);Set the character to '0'
   ADDQ.L  #1,D4   ;Increment the character counter
ItoA_3
   SUB.L   (A1),D0 ;Subtract the table value from I
   BCS     ItoA_4  ;If I is negative, then jump to ItoA_4
   ADDQ.B  #1,(A0) ;Increment the data byte in A$
   BRA     ItoA_3  ;Jump to ItoA_3
ItoA_4
   ADD.L   (A1),D0 ;Add the table value to I, making I positive again
   ADDQ.L  #4,A1   ;Advance the table pointer to the next value
   SUBQ.L  #1,D1   ;Decrement the table counter
   BEQ     ItoA_7  ;If the table counter is zero, then jump to ItoA_7
   ADDQ.L  #1,A0   ;Advance the A$ pointer
   CMP.L   D4,D2   ;If the character counter <= the limit value,
   BGT     ItoA_2  ; then jump to ItoA_2
ItoA_5
   MOVE.L  D2,(A2) ;Set the current useage of A$ to the max length of A$
   SUBQ.L  #1,D4   ;Fill the buffer with astericks
ItoA_6
   MOVE.B  #'*',(A4)+
   DBRA    D4,ItoA_6
   BRA     ItoA_8  ;Jump to Itoa_8
ItoA_7
   MOVE.L  D4,(A2) ;Set the current useage of A$ to the character count
ItoA_8
   MOVEM.L (A7)+,D0-D4/A0-A4 ;(Pop registers)
   RTS             ;Return
   
ItoA_values
   DC.L      1000000000
   DC.L       100000000
   DC.L        10000000
   DC.L         1000000
   DC.L          100000
   DC.L           10000
   DC.L            1000
   DC.L             100
   DC.L              10
   DC.L               1
   

AtoI_              ;BASIC Fn: I = VAL(A$)
                   ;         (D0)    (A0)

;This routine converts a decimal ASCII string to a signed binary integer 

   MOVEM.L D1-D4/A0-A1,-(A7) ;(Push registers)

   MOVEQ.L #0,D0   ;Set the character field to zero
   MOVEQ.L #0,D2   ;Set the result (D2) to 0
   MOVEQ.L #0,D3   ;Clear the negative flag (D3)
   ADDQ.L  #4,A0   ;(Make A1 point to the current useage of A$)
   MOVE.L  A0,A1
   MOVE.L  (A0)+,D1;Set the byte counter (D1) to the current useage of A$
                   ;(Make A0 point to the first data byte in A$)
   BEQ     AtoI_9  ;If the byte counter is zero, then jump to AtoI_9
   MOVE.B  (A0)+,D0;Fetch the first data byte in A$
                   ;(Make A0 point to the second data byte in A$)
   CMPI.B  #'-',D0 ;If the byte is not a '-', then jump to AtoI_1
   BNE     AtoI_1
   MOVEQ.L #1,D3   ;Set the negative flag
   BRA     AtoI_4  ;Jump to AtoI_4
AtoI_1
   CMPI.B  #'0',D0 ;If the byte is not numeric, then jump to AtoI_9
   BLT     AtoI_9
   CMPI.B  #'9',D0
   BGT     AtoI_9
   LSL.L   #1,D2   ;Multiply the result by 10
   MOVE.L  D2,D4
   LSL.L   #2,D2
   ADD.L   D4,D2
   SUBI.B  #'0',D0 ;Convert the byte to binary
   ADD.L   D0,D2   ;Add the byte to the result
AtoI_4
   SUBQ.L  #1,D1   ;Decrement the byte counter
   BEQ     AtoI_9  ;If the byte counter is zero, then jump to AtoI_9
   MOVE.B  (A0)+,D0;Fetch the next data byte in A$
                   ;(Make A0 point to the next data byte in A$)
   BRA     AtoI_1  ;Jump to AtoI_1
AtoI_9
   TST.L   D3      ;If the negative flag is clear, then jump to AtoI_A
   BEQ     AtoI_A
   NEG.L   D2      ;Negate the result
AtoI_A
   MOVE.L  D2,D0   ;Set D0 to the result

   MOVEM.L (A7)+,D1-D4/A0-A1 ;(Pop registers)

   RTS             ;Return


HAtoI_             ;BASIC Fn: I = HEX(A$)
                   ;         (D0)    (A0)

;This routine converts a hex-ASCII string to a binary integer
;
;Note: Conversion stops if a non-hex-ASCII character is encountered in
;      the string

   MOVEM.L D1-D2,-(A7) ;(Push registers)

   MOVEQ.L #0,D2   ;Set the result (D2) to 0
   ADDQ.L  #4,A0   ;Set the limit value (D1) to the current length of A$
   MOVE.L  (A0)+,D1;(Make A0 point to the current useage of A$)
HAtoI_1
   MOVE.B  (A0)+,D0;If the first (next) character in A$ is not a hex-ASCII
   JSR     IsHexASCII; character, then jump to HAtoI_7
   BEQ     HAtoI_7
   CMPI.B  #'9'+1,D0;Convert the hex-ASCII character to a binary value
   BCS     HAtoI_2
   ANDI.B  #$0F,D0
   ADD.L   #9,D0
   BRA     HAtoI_3
HAtoI_2
   SUB.L   #'0',D0
HAtoI_3
   LSL.L   #4,D2   ;Shift the result left 4 bits
   OR.L    D0,D2   ;'Or' the binary value into the result
   SUBQ.L  #1,D1   ;Decrement the limit value
   BNE     HAtoI_1 ;If the limit value is not yet zero,
                   ; then jump to HAtoI_1
HAtoI_7

   MOVE.L  D2,D0   ;(Set D0 to the result)
   MOVEM.L (A7)+,D1-D2 ;(Pop registers)

   RTS             ;Return


ItoHA8_            ;BASIC Fn: A$ = STR8HEX$(I)
                   ;         (A0)          (D0)

   MOVEM.L D1,-(A7);(Push registers)

   MOVEQ.L #8,D1   ;Set the field width to 8
   JSR     ItoHA_  ;Convert the field

   MOVEM.L (A7)+,D1;(Pop registers)

   RTS             ;Return


ItoHA4_            ;BASIC Fn: A$ = STR4HEX$(I)
                   ;         (A0)          (D0)

   MOVEM.L D1,-(A7);(Push registers)

   MOVEQ.L #4,D1   ;Set the field width to 4
   JSR     ItoHA_  ;Convert the field

   MOVEM.L (A7)+,D1;(Pop registers)

   RTS             ;Return


ItoHA2_            ;BASIC Fn: A$ = STR2HEX$(I)
                   ;         (A0)          (D0)

   MOVEM.L D1,-(A7);(Push registers)

   MOVEQ.L #2,D1   ;Set the field width to 2
   JSR     ItoHA_  ;Convert the field

   MOVEM.L (A7)+,D1;(Pop registers)

   RTS             ;Return


ItoHA1_            ;BASIC Fn: A$ = STR1HEX$(I)
                   ;         (A0)          (D0)

   MOVEM.L D1,-(A7);(Push registers)

   MOVEQ.L #1,D1   ;Set the field width to 1
   JSR     ItoHA_  ;Convert the field

   MOVEM.L (A7)+,D1;(Pop registers)

   RTS             ;Return


ItoHA_             ;BASIC Fn: A$ = STRHEX$(I)
                   ;         (A0)         (D0)

;In: D1 = the number of hex-ASCII characters to convert

   MOVEM.L D0-D5,-(A7) ;(Push registers)

   MOVE.L  D1,D2   ;(Set D2 to the field width -1)
   SUBQ.L  #1,D2
   MOVE.L  (A0)+,D3;If the max length of A$ < the field width,
   CMP.L   D1,D3   ; (Make A0 point to the current useage of A$)
   BLT     ItoHA_7 ; then jump to ItoHA_7
                   ; (Set D3 to the max length of A$)
   MOVE.L  D1,(A0)+;Set the current useage of A$ to the field width
                   ;(Make A0 point to the first data byte of A$)
   CMPI.L  #1,D1   ;If the field width is 1,
   BEQ     ItoHA_2 ; then jump to ItoHA_2

   MOVE.L  D2,D4   ;Rotate I right by the field width -1 times 4 bits
   SUBQ.L  #1,D4
ItoHA_1
   ROR.L   #4,D0
   DBRA    D4,ItoHA_1

ItoHA_2
   MOVE.L  D2,D4   ;Set the counter to the field width -1
ItoHA_3
   MOVE.B  D0,D5   ;Convert I bits 3-0 to a hex-ASCII character
   AND.L   #$0F,D5
   ADD.L   #'0',D5
   CMP.L   #'9'+1,D5
   BLT     ItoHA_4
   ADDQ.L  #7,D5
ItoHA_4
   MOVE.B  D5,(A0)+;Place the character in A$
                   ;(Make A0 point to the next data byte in A$)
   ROL.L   #4,D0   ;Rotate I left by 4 bits
   DBRA    D4,ItoHA_3;Decrement the counter
                   ;If the counter is not yet -1, then jump to ItoHA_2
   BRA     ItoHA_9 ;Jump to ItoHA_9

ItoHA_7
   MOVE.L  D3,(A0)+;Set the current useage of A$ to the max length of A$
   SUBQ.L  #1,D3   ;Fill A$ with astericks
ItoHA_8
   MOVE.B  #'*',(A0)+
   DBRA    D3,ItoHA_8

ItoHA_9
   MOVEM.L (A7)+,D0-D5 ;(Pop registers)

   RTS             ;Return


IsHexASCII             ;Is hex-ASCII routine

                       ;This routine determines whether or not a character
                       ; is a valid hex-ASCII character

                       ;In: <D0.B> = the character

                       ;Out: <Zero> = Clear if the character is a hex-ASCII
                       ;       character,
                       ;            = Set if the character is not a hex-
                       ;       ASCII character

   MOVE.L  D0,-(A7)    ;Push registers

   ANDI.L  #$FF,D0     ;Strip off all but bits 7-0

   CMPI.B  #'0',D0     ;If the character is not a hex-ASCII character,
   BMI     IsHex8      ; then jump to IsHex8
   CMPI.B  #'9'+1,D0   ;If in the range "0" - "9", then jump to IsHex4
   BMI     IsHex4
   CMPI.B  #'A',D0
   BMI     IsHex8
   CMPI.B  #'F'+1,D0   ;If in the range "A" - "F", then jump to IF#4
   BMI     IsHex4
   CMPI.B  #'a',D0
   BMI     IsHex8
   CMPI.B  #'f'+1,D0   ;If in the range "0" - "f", then jump to IsHex4
   BMI     IsHex4
   BRA     IsHex8      ;Jump to IsHex8

IsHex4
   MOVE.L  (A7)+,D0    ;Pop registers
   ANDI    #$FB,CCR    ;Clear the zero flag
   BRA     IsHex9

IsHex8
   MOVE.L  (A7)+,D0    ;Pop registers
   ORI     #$04,CCR    ;Set the zero flag

IsHex9
   RTS                 ;Return


   IFND    ScanPointer
ScanPointer
   DS.L    1
   ENDC

   IFND    ScanCounter
ScanCounter
   DS.L    1
   ENDC

   IFND    ConIn
ConIn
   DS.L    1
   ENDC

   IFND    ConOut
ConOut
   DS.L    1
   ENDC

   IFND    DosLibraryHandle
DosLibraryHandle
   DS.L    1
   ENDC

   IFND    SystemSP
SystemSP
   DS.L    1
   ENDC

   IFND    MODE_OLDFILE
MODE_OLDFILE         EQU   1005
   ENDC

   IFND    MODE_NEWFILE
MODE_NEWFILE         EQU   1006
   ENDC


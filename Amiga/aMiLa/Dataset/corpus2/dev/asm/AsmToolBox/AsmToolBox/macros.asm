   XREF    _LVOOpenLibrary
   XREF    _LVOOpen
   XREF    _LVOClose
   XREF    _LVORename
   XREF    _LVODeleteFile
   XREF    _LVOInput
   XREF    _LVOOutput
   XREF    _LVORead
   XREF    _LVOWrite
   XREF    _LVOSeek
   XREF    _LVOCloseLibrary

   XREF    _AbsExecBase

   IFND    LF
LF EQU     10
   ENDC

;NA = Number of Arguments
;SB = the location of a string buffer

Start      MACRO               ;(no args)
           MOVE.L  A7,SystemSP
           JSR     OpenDOSLibrary
           ENDM

Open       MACRO
           MOVEM.L A0-A1,-(A7)
           MOVE.L  \1,A0       ;\1 => SB containing the filename
           MOVE.L  #\2,A1
           JSR     OpenFile
           MOVEM.L (A7)+,A0-A1
           ENDM

Create     MACRO
           MOVEM.L A0-A1,-(A7)
           MOVE.L  \1,A0       ;\1 => SB containing the filename
           MOVE.L  #\2,A1      ;\2 => the file handle
           JSR     CreateFile
           MOVEM.L (A7)+,A0-A1
           ENDM

Read       MACRO
           MOVEM.L A0-A1,-(A7)
           MOVE.L  \1,A0       ;\1 => the file handle
           MOVE.L  \2,A1       ;\2 => SB to receive the disk record
           JSR     ReadFile
           MOVEM.L (A7)+,A0-A1
           ENDM

Write      MACRO
           MOVEM.L A0-A1,-(A7)
           MOVE.L  \1,A0       ;\1 => the file handle
           MOVE.L  \2,A1       ;\2 => SB containing the disk record
           JSR     WriteFile
           MOVEM.L (A7)+,A0-A1
           ENDM

Seek       MACRO
           MOVEM.L A0/D0-D1,-(A7)
           MOVE.L  \1,A0       ;\1 => the file handle
           MOVE.L  \2,D0       ;\2 => the position to which to seek
           MOVE.L  #-1,D1
           JSR     SeekFile
           MOVEM.L (A7)+,A0/D0-D1
           ENDM

Close      MACRO
           MOVEM.L A0,-(A7)
           MOVE.L  \1,A0       ;\1 => the file handle
           JSR     CloseFile
           MOVEM.L (A7)+,A0
           ENDM

Rename     MACRO
           MOVEM.L A0-A1,-(A7)
           MOVE.L  \1,A0       ;\1 => SB containing the current filename
           MOVE.L  \2,A1       ;\2 => SB containing the new filename
           JSR     RenameFile
           MOVEM.L (A7)+,A0-A1
           ENDM

Delete     MACRO
           MOVEM.L A0,-(A7)
           MOVE.L  \1,A0       ;\1 => SB containing the filename
           JSR     DeleteFile
           MOVEM.L (A7)+,A0
           ENDM

ReadCon    MACRO               ;\1 => SB containing text to send to the
                               ; console
           MOVEM.L D0/A0-A1,-(A7)
           MOVE.L  ConIn,A0
           MOVE.L  \1,A1
           JSR     ReadFile
           MOVE.L  \1,A1       ;(Lop off the terminating LineFeed)
           ADDQ.L  #4,A1
           SUBI.L  #1,(A1)
           MOVEM.L (A7)+,D0/A0-A1
           ENDM

WritCon    MACRO               ;\1 => SB containing text to send to the
                               ; console
           MOVEM.L D0/A0-A1,-(A7)
           MOVE.L  ConOut,A0
           MOVE.L  \1,A1
           JSR     WriteFile
           MOVEM.L (A7)+,D0/A0-A1
           ENDM

SetScan    MACRO                ;\1 => SB to scan later
           MOVEM.L A0,-(A7)
           MOVEA.L \1,A0
           ADDQ.L  #4,A0
           MOVE.L  (A0),ScanCounter
           ADDQ.L  #4,A0
           MOVE.L  A0,ScanPointer
           MOVEM.L (A7)+,A0
           ENDM

Scanc      MACRO               ;\1 => SB to receive the next character
           MOVEM.L A0,-(A7)    ; scanned
           MOVEA.L \1,A0
           JSR     Scanc_
           MOVEM.L (A7)+,A0
           ENDM

Scanw      MACRO               ;\1 => SB to receive the next word scanned
           MOVEM.L A0,-(A7)
           MOVEA.L \1,A0
           JSR     Scanw_
           MOVEM.L (A7)+,A0
           ENDM

Scana      MACRO               ;\1 => SB to receive the next alphanumeric
           MOVEM.L A0,-(A7)    ; word scanned (stopping at punctuation and
           MOVEA.L \1,A0       ; special characters)
           JSR     Scana_
           MOVEM.L (A7)+,A0
           ENDM

StrCpy     MACRO               ;\1 => SB to copy
           MOVEM.L A0/A1,-(A7) ;\2 => SB to copy to
           MOVEA.L \1,A0
           MOVEA.L \2,A1
           JSR     StrCpy_
           MOVEM.L (A7)+,A0/A1
           ENDM

StrCat     MACRO               ;\1 => SB to concatenate
           MOVEM.L A0/A1,-(A7) ;\2 => SB to be concatenated onto
           MOVEA.L \1,A0
           MOVEA.L \2,A1
           JSR     StrCat_
           MOVEM.L (A7)+,A0/A1
           ENDM

StrCmp     MACRO               ;\1 => SB to compare
           MOVEM.L A0/A1,-(A7) ;\2 => SB to compare
           MOVEA.L \1,A0       ; (Zero flag is set or cleared accordingly)
           MOVEA.L \2,A1
           JSR     StrCmp_
           MOVEM.L (A7)+,A0/A1
           ENDM

StrLen     MACRO               ;\1 => SB to examine the length of
           MOVEM.L A0/A1,-(A7)
           MOVEA.L \1,A0
           JSR     StrLen_
           MOVEM.L (A7)+,A0/A1
           ENDM

Left       MACRO               ;\1 => SB containing the source string
           MOVEM.L A0/A1/D0,-(A7)
           MOVEA.L \1,A0       ;\2 = number of bytes to copy
           MOVE.L  \2,D0       ;\3 => SB containing the destination string
           MOVEA.L \3,A1
           JSR     Left_
           MOVEM.L (A7)+,A0/A1/D0
           ENDM

Mid        MACRO               ;\1 => SB containing the source string
           MOVEM.L A0/A1/D0/D1,-(A7)
           MOVEA.L \1,A0       ;\2 = point at which to start copying
           MOVE.L  \2,D0       ;\3 = number of bytes to copy
           MOVE.L  \3,D1       ;\4 => SB containing the destination string
           MOVEA.L \4,A1
           JSR     Mid_
           MOVEM.L (A7)+,A0/A1/D0/D1
           ENDM

Right      MACRO               ;\1 => SB containing the source string
           MOVEM.L A0/A1/D0,-(A7)
           MOVEA.L \1,A0       ;\2 = number of bytes to copy
           MOVE.L  \2,D0       ;\3 => SB containing the destination string
           MOVEA.L \3,A1
           JSR     Right_
           MOVEM.L (A7)+,A0/A1/D0
           ENDM

AtoI       MACRO               ;\1 => SB to be converted
           MOVEM.L D0/A0,-(A7) ;\2 => integer result
           MOVE.L  \1,A0
           JSR     AtoI_
           MOVE.L  D0,\2
           MOVEM.L (A7)+,D0/A0
           ENDM

ItoA       MACRO               ;\1 => integer to be converted
                               ;\2 => SB result
           MOVEM.L D0/A0,-(A7)
           MOVE.L  \1,D0
           MOVE.L  \2,A0
           JSR     ItoA_
           MOVEM.L (A7)+,D0/A0
           ENDM

HAtoI      MACRO
           MOVEM.L D0/A0,-(A7)
           MOVE.L  \1,A0
           JSR     HAtoI_
           MOVE.L  D0,\2
           MOVEM.L (A7)+,D0/A0
           ENDM

ItoHA8     MACRO
           MOVEM.L D0/A0,-(A7)
           MOVE.L  \1,D0
           MOVE.L  \2,A0
           JSR     ItoHA8_
           MOVEM.L (A7)+,D0/A0
           ENDM

ItoHA4     MACRO
           MOVEM.L D0/A0,-(A7)
           MOVE.W  \1,D0
           MOVE.L  \2,A0
           JSR     ItoHA4_
           MOVEM.L (A7)+,D0/A0
           ENDM

ItoHA2     MACRO
           MOVEM.L D0/A0,-(A7)
           MOVE.B  \1,D0
           MOVE.L  \2,A0
           JSR     ItoHA2_
           MOVEM.L (A7)+,D0/A0
           ENDM

ItoHA1     MACRO
           MOVEM.L D0/A0,-(A7)
           MOVE.B  \1,D0
           MOVE.L  \2,A0
           JSR     ItoHA1_
           MOVEM.L (A7)+,D0/A0
           ENDM

Exit       MACRO               ;(no args)
           JSR     CloseDOSLibrary
           MOVEA.L SystemSP,A7
           RTS
           ENDM

Crlf       MACRO               ;(no args)
           JSR     DisplayCrlf
           ENDM

Space      MACRO               ;(no args)
           JSR     DisplaySpace
           ENDM

Display    MACRO               ;\1 => SB to be displayed on the console
           MOVEM.L D0,-(A7)
           WritCon #Displ\@
           BRA     Displ_3\@
Displ\@    DC.L    Displ_2\@-Displ_1\@,Displ_2\@-Displ_1\@
Displ_1\@  DC.B    \1
Displ_2\@
           CNOP    0,2
Displ_3\@  MOVEM.L (A7)+,D0
           ENDM

StrBuf     MACRO               ;\1 = a string buffer label
           CNOP    0,2         ;\2 = the maximum length of the string buffer
\1
           DC.L    \2,0
           DS.B    \2
           CNOP    0,2
           ENDM

String     MACRO               ;\1 = a string buffer label
           CNOP    0,2         ;\2 = the string
\1
String\@   DC.L    String_2\@-String_1\@,String_2\@-String_1\@
String_1\@ DC.B    \2
String_2\@
           CNOP    0,2
           ENDM



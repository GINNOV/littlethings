* --------------------------------------------------------------------
* Example CH12-1.s
* --------------------------------------------------------------------
; some system include files...
   
         include exec/types.i
         include exec/libraries.i
         include exec/exec_lib.i
         include dos/dos_lib.i    
* --------------------------------------------------------------------    

CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM

; CALLSYS macro is used to extend LINKLIB and thus avoid the explicit 
; use of the _LVO prefixes in the function names...

* --------------------------------------------------------------------    

WRITEDOS MACRO

         movem.l    d1-d3,-(sp)             preserve registers d1-d3
         
         move.l   \2,d1                     DOS output file handle
         
         move.l   #\1,d2                    start of message 
         
         move.l   #\1_SIZEOF,d3             size of message
         
         CALLSYS  Write,_DOSBase            DOS call to write message
         
         movem.l    (sp)+,d1-d3             restore registers d1-d3
    
         ENDM

; WRITEDOS is used to Write() DOS text messages and control character 
; streams. The macro expects the user to supply a text label followed 
; by a valid DOS output handle. 

; Usage:          WRITEDOS <text_label>,<dos_handle>
 
; Example:        WRITEDOS message, _stdout 

; Within the program each message X must have a corresponding size EQUate, 
; X_SIZEOF, containing the size of the message. An easy way to set this up 
; is to define the size label immediately after defining the message itself 
; and use the assembler's location counter to do the length calculation, 
; like this... 

;                 message           dc.b 'test text',0

;                 message_SIZEOF    EQU *-message
 
* --------------------------------------------------------------------    
; EQUate definitions...

_AbsExecBase EQU    4

LF           EQU   10

NULL	     EQU    0

* --------------------------------------------------------------------
; main program code...
     
         move.l   _AbsExecBase,_SysBase      set up SysBase variable

         lea      dos_name,a1                library name start in a1
    
         moveq    #0,d0                      any version will do
    
         CALLSYS  OpenLibrary,_SysBase       macro (see text for details)
    
         move.l   d0,_DOSBase                store returned value

         beq      EXIT                       test result for success

; if we reach here then the DOS library is open and its functions can 
; be safely used! 

         CALLSYS  Output,_DOSBase            get default output handle
         
         move.l   d0,_stdout                 store output handle 

         beq      CLOSELIB

; have obtained valid output handle so message can be written...

         WRITEDOS message, _stdout           get DOS to write message


; all done so now we can close DOS library...

CLOSELIB move.l   _DOSBase,a1                base needed in a1        
    
         CALLSYS  CloseLibrary, _SysBase
    
    
; and terminate the program via an rts instruction...    

EXIT     clr.l    d0

         rts                                 logical end of program
        
* --------------------------------------------------------------------    
; variables and static data...

_stdout           ds.l    1

_SysBase          ds.l    1

_DOSBase          ds.l    1
    
dos_name          dc.b 'dos.library',0
    
message           dc.b 'this is just my line of test text',LF
    
message_SIZEOF    EQU *-message
    
* --------------------------------------------------------------------

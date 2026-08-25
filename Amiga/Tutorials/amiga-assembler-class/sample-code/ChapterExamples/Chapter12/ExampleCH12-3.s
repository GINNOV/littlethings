* --------------------------------------------------------------------
* Example CH12-3.s
* --------------------------------------------------------------------
; some system include files...
   
         include exec/types.i
         include exec/libraries.i
         include exec/exec_lib.i
         include dos/dos_lib.i
             
* --------------------------------------------------------------------    
; see text and notes with earlier programs

CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM

* --------------------------------------------------------------------    
; see text and notes with earlier programs
  
WRITEDOS MACRO

         movem.l    d1-d3,-(sp)             preserve registers d1-d3
         
         move.l   \2,d1                     DOS output file handle
         
         move.l   #\1,d2                    start of message 
         
         move.l   #\1_SIZEOF,d3             size of message
         
         CALLSYS  Write,_DOSBase            DOS call to write message
         
         movem.l    (sp)+,d1-d3             restore registers d1-d3
    
         ENDM

* --------------------------------------------------------------------    
; EQUate definitions...

_AbsExecBase EQU    4

LF           EQU   10

NULL         EQU    0

* --------------------------------------------------------------------
; main program code...
     
         move.l   _AbsExecBase,_SysBase      set up SysBase variable
     
         move.l   a0,cli_args_p              save DOS supplied CLI pointer 

         move.l   d0,cli_args_size           and command argument length
                  
         lea      dos_name,a1                library name start in a1

         moveq    #0,d0                      any version will do
    
         CALLSYS  OpenLibrary,_SysBase       
    
         move.l   d0,_DOSBase                store library base

         beq      EXIT                       check result

; DOS library is open and its functions can be safely used! 

         CALLSYS  Output,_DOSBase            get default output handle
         
         move.l   d0,_stdout                 store output handle 

         beq      CLOSELIB


; valid output handle is available so do the argument print... 

         move.l   cli_args_size,d3           orig argument size
         
         subq.l   #1,d3                      ignore terminal linefeed

         beq      CLOSELIB                   no arguments provided
                 
PRINT    move.l   _stdout,d1                 DOS output file handle

         move.l   cli_args_p,d2              needed since DOS destroys d2 
      
         CALLSYS  Write,_DOSBase             print d3 characters of argument 

         WRITEDOS linefeed, _stdout          print a linefeed

         subq.l   #1,d3                      decrease character count
         
         bne      PRINT                      keep going if d3 is non-zero
         
         WRITEDOS linefeed, _stdout          print linefeed to finish


; all done so now we can close DOS library...

CLOSELIB move.l   _DOSBase,a1                base needed in a1        
    
         CALLSYS  CloseLibrary, _SysBase
    
    
; and terminate the program...    

EXIT     clr.l     d0

         rts                                 logical end of program
        
* --------------------------------------------------------------------    
; variables and static data...

_stdout           ds.l    1

_SysBase          ds.l    1

_DOSBase          ds.l    1

cli_args_p        ds.l    1

cli_args_size     ds.l    1
    
dos_name          dc.b 'dos.library',NULL
    
linefeed          dc.b LF

linefeed_SIZEOF   EQU *-linefeed

* --------------------------------------------------------------------

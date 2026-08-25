* --------------------------------------------------------------------
* Example CH12-5.s
* --------------------------------------------------------------------
; some system include files...
   
         include exec/types.i
         include exec/libraries.i
         include exec/exec_lib.i
         include dos/dos_lib.i
             
* --------------------------------------------------------------------
; external reference declarations...

         XREF _printf

         XDEF _stdout
         
         XDEF _DOSBase
                  
* --------------------------------------------------------------------    

CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM

; CALLSYS macro is used to extend LINKLIB and thus avoid the explicit 
; use of the _LVO prefixes in the function names...

* --------------------------------------------------------------------    
; EQUate definitions...

_AbsExecBase EQU    4

LF           EQU   10

NULL         EQU    0

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

; Have obtained valid output handle so message can be written. This time  
; the amiga.lib printf() routine is being used to print the... 

         move.l   _SysBase,-(sp)             push  library base
 
         pea      format_string              push format string address
         
         jsr      _printf                    use amiga.lib printf()

         addq.l   #8,sp                      shortcut way to adjust stack
         
         
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
    
dos_name          dc.b 'dos.library',NULL
    
format_string     dc.b '%lx hex',LF,NULL
* --------------------------------------------------------------------



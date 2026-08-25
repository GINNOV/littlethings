* --------------------------------------------------------------------
* Example CH10-1.s
* --------------------------------------------------------------------
; some system include files...
   
         include exec/types.i
         include exec/libraries.i
    	 include exec/exec_lib.i
    	 
* --------------------------------------------------------------------    
; a macro to extend LINKLIB and thus avoid the explicit use 
; of the _LVO prefixes in the function names...

CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM

* --------------------------------------------------------------------    
; EQUate definitions...

_AbsExecBase EQU    4
    
* --------------------------------------------------------------------
; main program code...
     
         lea      intuition_name,a1          library name start in a1
    
         moveq    #0,d0                      any version will do
    
         CALLSYS  OpenLibrary,_AbsExecBase   macro (see text for details)
    
         move.l   d0,_IntuitionBase          store returned value

         beq      EXIT                       test result for success

; if we reach here then the intuition library is open and its 
; functions can be safely used! 
    
; as it happens however all we shall do for this example is 
; close the library like this...

         move.l   _IntuitionBase,a1          base needed in a1        
    
         CALLSYS  CloseLibrary, _AbsExecBase
    
    
; and terminate the program...    

EXIT     clr.l   d0

         rts                                 logical end of program
        
* --------------------------------------------------------------------    
; variables and static data...

_IntuitionBase   ds.l    1
    
intuition_name   dc.b 'intuition.library',0
    
* --------------------------------------------------------------------

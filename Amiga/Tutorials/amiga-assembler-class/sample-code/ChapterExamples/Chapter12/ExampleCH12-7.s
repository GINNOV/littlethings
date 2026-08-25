* --------------------------------------------------------------------
* Example CH12-7.s
* --------------------------------------------------------------------
; some system include files...
   
           include exec/types.i
           include exec/libraries.i
           include exec/exec_lib.i
           include dos/dos_lib.i
               
* --------------------------------------------------------------------
; external reference declarations...

           XREF _printf

           XREF _afp
         
           XREF _fpa

           EXTERN_LIB SPExp
              
           XDEF _stdout
         
           XDEF _DOSBase
         
* --------------------------------------------------------------------    

CALLSYS    MACRO

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
; main program code starts by checking for a CLI/Shell argument line...

           cmpi     #1,d0                      check for data?
           
           beq      EXIT                       no data so quit!

; providing one exists we check that it isn't oversize...

           cmpi     #number_SIZEOF,d0
           
           bgt      EXIT                       line too long so quit!


; since it is OK we copy it to the number buffer...

           lea      number,a1                  destination pointer
           
           subq     #2,d0                      disregard terminator
           
LOOP       move.b   (a0)+,(a1)+                copy string
           
           dbra     d0,LOOP
           
           move.b   #NULL,(a1)                 NULL terminate string

     
; and then continue by opening libraries etc...

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

           beq      CLOSEDOS


; now let's try and open the maths library...

           lea      math_name,a1               library name start in a1
    
           moveq    #0,d0                      any version will do
    
           CALLSYS  OpenLibrary,_SysBase       macro (see text for details)
    
           move.l   d0,_MathBase               store returned value

           beq      CLOSEDOS                   test result for success

; and the mathtrans library...

           lea      mathtrans_name,a1          library name start in a1
    
           moveq    #0,d0                      any version will do
    
           CALLSYS  OpenLibrary,_SysBase       macro (see text for details)
    
           move.l   d0,_MathTransBase          store returned value

           beq      CLOSEMATHS                 test result for success

; at this point the DOS, maths, and mathtrans libraries are all open 
; so we can do some sums...

; first convert the number to fast floating point form...

           pea      number                     push pointer
         
           jsr      _afp                       an amiga.lib routine

           addq.l   #4,sp                      adjust stack


; result is in d0 already so now calculate the exp()

           CALLSYS  SPExp,_MathTransBase       values sent/returned in d0


; not being done in this example but this is where we should check the 
; overflow flag to see whether the result is valid!  

; instead back to ASCII form (ffp result is already in register d0)

           pea      result                     push result pointer

           move.l   d0,-(sp)                   push ffp value 
         
           jsr      _fpa                       convert back to ASCII

           addq.l   #8,sp                      adjust stack
    
         
; and print result...

           pea      result                     push sum string pointer
 
           pea      format_string              push format string address
         
           jsr      _printf                    use amiga.lib printf()

           addq.l   #8,sp                      shortcut way to adjust stack
         
         
; all done so now we can close the libraries...

CLOSETRANS move.l   _MathTransBase,a1          base needed in a1        
    
           CALLSYS  CloseLibrary, _SysBase


CLOSEMATHS move.l   _MathBase,a1               base needed in a1        
    
           CALLSYS  CloseLibrary, _SysBase

 
CLOSEDOS   move.l   _DOSBase,a1                base needed in a1        
    
           CALLSYS  CloseLibrary, _SysBase
    
    
; and terminate the program...    

EXIT       clr.l    d0

           rts                                 logical end of program
        
* --------------------------------------------------------------------    
; variables and static data...

_stdout           ds.l    1

_SysBase          ds.l    1

_DOSBase          ds.l    1
    
_MathBase         ds.l    1

_MathTransBase    ds.l    1

dos_name          dc.b 'dos.library',NULL

math_name         dc.b 'mathffp.library',NULL

mathtrans_name    dc.b 'mathtrans.library',NULL
    
format_string     dc.b '%s',LF,NULL

                  EVEN
                  
number            ds.b 32

number_SIZEOF     EQU *-number

result            ds.b 16

* --------------------------------------------------------------------



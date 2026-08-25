* --------------------------------------------------------------------
* Example CH12-8.s
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
; general EQUate definitions...

_AbsExecBase     EQU   4

LF               EQU  10

NULL             EQU   0

* --------------------------------------------------------------------
; error number EQUate definitions...

NO_ERRORS        EQU   0

NO_ARGUMENTS     EQU   1

LONG_ARGUMENTS   EQU   2

NO_MATHS         EQU   3

NO_TRANS         EQU   4

OVERFLOW         EQU   5

* --------------------------------------------------------------------
; program starts by checking size of CLI/Shell argument line...

           clr.b    error_flag
               
LBOUND     cmpi.b   #1,d0                 
           
           bne      UBOUND                    

           move.b   #NO_ARGUMENTS,error_flag  

           bra      OPENDOS
           
UBOUND     cmpi.b   #number_SIZEOF,d0

           bls      COPYARGS
                      
           move.b   #LONG_ARGUMENTS,error_flag 
                      
           bra      OPENDOS                    
           
COPYARGS   lea      number,a1                  destination pointer
           
           subq.b   #2,d0                      disregard line terminator
           
LOOP       move.b   (a0)+,(a1)+                copy string
           
           dbeq     d0,LOOP
           
           move.b   #NULL,(a1)                 NULL terminate string
     
OPENDOS    move.l   _AbsExecBase,_SysBase      set up SysBase 

           lea      dos_name,a1                and open DOS library
    
           moveq    #0,d0                      any version will do
    
           CALLSYS  OpenLibrary,_SysBase       macro (see text for details)
    
           move.l   d0,_DOSBase                store returned value

           beq      EXIT                       test result for success

; if we reach here then the DOS library is open and its functions can 
; be safely used! 

           CALLSYS  Output,_DOSBase            get default output handle
         
           move.l   d0,_stdout                 store output handle 

           beq      CLOSEDOS


; This next code is tricky unless you realize what is happening. The 
; 68000 hasn't got conditional subroutine instructions so I create my 
; own by pushing a return address on the stack and then conditionally 
; BRANCHING to the appropriate subroutine.

DOS_OPEN   pea      CLOSEDOS

           tst.b    error_flag                 command line error?
           
           beq      ARGS_OK                    next subroutine level

           rts
           
CLOSEDOS   tst.b    error_flag                 were there any errors?

           beq      CLOSEDOS1                  skip error message if not  

           jsr      ErrorMsg                   

CLOSEDOS1  move.l   _DOSBase,a1                base needed in a1        
    
           CALLSYS  CloseLibrary, _SysBase
    
; all done so exit back to CLI/Shell...    

EXIT       clr.l    d0 

           rts                                 logical end of program

* --------------------------------------------------------------------
; Remember that this diagram level is coded as a subroutine

ARGS_OK    pea      ARGS_OK1                   push a return address
            
           jsr      OpenMaths                  zero flag clear on failure
            
           beq      MATHS_OPEN                 next subroutine level
           
ARGS_OK1   rts                                 twin execution - see text
            
* --------------------------------------------------------------------
; another diagram level coded as a subroutine

MATHS_OPEN  pea     MATHS_OPEN1                push a return address

            jsr     OpenTrans                  zero flag clear on failure

            beq     TRANS_OPEN                 next subroutine level
    
            rts
            
MATHS_OPEN1 jsr     CloseMaths

            rts
 
* --------------------------------------------------------------------
; yet another diagram level coded as a subroutine and at this point the 
; DOS, maths, and mathtrans libraries are open and useable... 

TRANS_OPEN  pea     TRANS_OPEN1                push return address
             
            pea     number                     push pointer
         
            jsr     _afp                       data comes back in d0
            
            add.l   #4,sp                      adjust stack                     
  
            CALLSYS SPExp,_MathTransBase       values sent/returned in d0

            bvc     PRINT_DATA                 check for overflow

            move.b  #OVERFLOW,error_flag
         
            rts 
         
TRANS_OPEN1 jsr     CloseTrans

            rts

* --------------------------------------------------------------------
; lowest diagram level coded again as a subroutine


PRINT_DATA  pea     result                     result already in d0

            move.l  d0,-(sp)                   push ffp value 
         
            jsr     _fpa                       convert back to ASCII
 
            addq.l  #8,sp                      adjust stack
    
            pea     result                     push sum string pointer
 
            pea     string_format              push format string address
         
            jsr     _printf                    use amiga.lib printf()
 
            addq.l  #8,sp                      shortcut way to adjust stack

            rts

* --------------------------------------------------------------------

; If OpenMaths() routine fails the zero flag will be CLEAR on return!

OpenMaths  lea     math_name,a1                library name start in a1
    
           moveq   #0,d0                       any version will do
    
           CALLSYS OpenLibrary,_SysBase        macro (see text for details)
    
           move.l  d0,_MathBase                store returned value

           beq     OpenMaths1                  branch taken if open failed
           
           clr.l   d0                          open OK so set zero flag
           
           rts
           
OpenMaths1 move.b  #NO_MATHS,error_flag        will CLEAR z flag

           rts 
           
* --------------------------------------------------------------------

; If OpenTrans() routine fails the zero flag will be CLEAR on return!

OpenTrans  lea     mathtrans_name,a1           library name start in a1
    
           moveq   #0,d0                       any version will do
    
           CALLSYS OpenLibrary,_SysBase        macro (see text for details)
    
           move.l  d0,_MathTransBase           store returned value

           beq     OpenTrans1                  branch taken if open failed
           
           clr.l   d0                          open OK so set zero flag
           
           rts
           
OpenTrans1 move.b  #NO_TRANS,error_flag        will CLEAR z flag

           rts

* --------------------------------------------------------------------

CloseMaths move.l  _MathBase,a1                base needed in a1        
    
           CALLSYS CloseLibrary, _SysBase

           rts

* --------------------------------------------------------------------
           
CloseTrans move.l  _MathTransBase,a1           base needed in a1        
    
           CALLSYS CloseLibrary, _SysBase
           
           rts
           
* --------------------------------------------------------------------
; following routine uses the value present in error_number to identify 
; the n'th address in a table of error message pointers...

ErrorMsg   clr.l   d0                          could contain garbage!

           move.b  error_flag,d0               get error number 
  
           lsl.l   #2,d0                       multiply by 4

           move.l  #error_table,a0             load table base address 
                    
           move.l  0(a0,d0.l),-(sp)            push table entry contents 
            
           pea     string_format               push format string
             
           jsr     _printf                     print error message
             
           add.l   #8,sp                       adjust stack                     
    
           rts                               

* --------------------------------------------------------------------

; variables and static data...

_stdout           ds.l    1

_SysBase          ds.l    1

_DOSBase          ds.l    1
    
_MathBase         ds.l    1

_MathTransBase    ds.l    1

error_flag        ds.b    1
                  
dos_name          dc.b 'dos.library',NULL

math_name         dc.b 'mathffp.library',NULL

mathtrans_name    dc.b 'mathtrans.library',NULL
   
error0            dc.b 'no errors',NULL

error1            dc.b 'no value supplied',NULL

error2            dc.b 'command string too long',NULL

error3            dc.b 'could not open maths library',NULL

error4            dc.b 'could not open mathtrans library',NULL

error5            dc.b 'result produced an overflow',NULL

string_format     dc.b '%s',LF,NULL

                  EVEN
                  
number            ds.b 32

number_SIZEOF     EQU *-number

result            ds.b 16

error_table       dc.l error0,error1,error2,error3,error4,error5

* --------------------------------------------------------------------



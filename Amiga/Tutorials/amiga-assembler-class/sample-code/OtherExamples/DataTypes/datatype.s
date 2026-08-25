
* --------------------------------------------------------------------
* datatype.s
* --------------------------------------------------------------------

_AbsExecBase         EQU    4

_LVOOpenLibrary      EQU -552

_LVOCloseLibrary     EQU -414

_LVOOutput           EQU  -60  

_LVOWrite            EQU  -48

_LVOLock             EQU  -84

_LVOUnLock           EQU  -90

_LVOObtainDataTypeA  EQU  -36

_LVOReleaseDataType  EQU  -42

dtn_Header           EQU   28

ACCESS_READ          EQU   -2

DTST_FILE            EQU    2

NULL                 EQU    0
 
LF                   EQU   10

SPACE                EQU   32
                     

                     XDEF  _DOSBase

                     XDEF  _stdout
                                          
                     XREF  _printf


LINKLIB MACRO
   
         IFGT NARG-2

           FAIL   ;too many arguments

         ENDC
    
         move.l   a6,-(sp)
   
         move.l   \2,a6
   
         jsr      \1(a6)
   
         move.l (sp)+,a6
   
         ENDM


CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM


WRITEDOS MACRO

         movem.l  d1-d3,-(sp)                preserve registers d1-d3
         
         move.l   \2,d1                      DOS output file handle
         
         move.l   #\1,d2                     start of message 
         
         move.l   #\1_SIZEOF,d3              size of message
         
         CALLSYS  Write,_DOSBase             DOS call to write message
         
         movem.l  (sp)+,d1-d3                restore registers d1-d3
    
         ENDM

* --------------------------------------------------------------------

; begin by copying first command line argument...
   
getarg1  lea       filename,a1

         subq.l    #1,d0                needed because loop goes to -1

copy     move.b    (a0),(a1)+

         cmpi.b    #SPACE,(a0)+

         dbeq      d0,copy

         subq.l    #1,a1

         move.b    #NULL,(a1)                 add terminal null 
   
* --------------------------------------------------------------------
     
         move.l   _AbsExecBase,_SysBase      set up SysBase variable

         lea      dos_name,a1                library name start in a1
    
         moveq    #0,d0                      any version will do
    
         CALLSYS  OpenLibrary,_SysBase      
    
         move.l   d0,_DOSBase                store returned value

         beq      exit                       quit if NULL


; if we reach here the DOS library is open and functions can be used...

         CALLSYS  Output,_DOSBase            get default output handle
         
         move.l   d0,_stdout                 store output handle 

         beq      closedos


; have obtained valid output handle so at least messages can be written
; - now try and open datatypes library...

         lea      datatypes_name,a1          library name start in a1
    
         moveq    #0,d0                      any version will do
    
         CALLSYS  OpenLibrary,_SysBase      
    
         move.l   d0,_DataTypesBase          store returned value

         beq      no_dt_lib                  was it OK?
    
        
; if open was OK we now get a lock on the specified file...

dt_open  move.l   #filename,d1

         moveq    #ACCESS_READ,d2

         CALLSYS  Lock,_DOSBase

         move.l   d0,lock
    
         beq      no_lock


; and try to obtain the datatype...

         moveq    #DTST_FILE,d0
    
         move.l   lock,a0
    
         move.w   #NULL,a1          no attributes
    
         CALLSYS  ObtainDataTypeA,_DataTypesBase
    
         move.l   d0,datatype_p

         beq.s    no_dt                      was it OK?

; if all went well a datatype description can be obtained from the header...

dt_found move.l   d0,a0
         
         move.l   dtn_Header(a0),a0
         
         move.l   (a0),-(sp)                 first field is datatype description 
                
         pea      format
    
         jsr      _printf
         
         addq.l   #8,sp
    
  
; all done so free all resources that we obtained...
    
         move.l   datatype_p,a0
    
         CALLSYS  ReleaseDataType,_DataTypesBase
    
         bra.s    unlock

         
no_dt    WRITEDOS bad_dt,_stdout              write message
    
unlock   move.l   lock,d1

         CALLSYS  UnLock,_DOSBase
    
         bra.s    closedts

   
no_lock  WRITEDOS bad_lock,_stdout  
                
closedts move.l   _DataTypesBase,a1           base needed in a1        
    
         CALLSYS  CloseLibrary,_SysBase

         bra.s    closedos
         

no_dt_lib WRITEDOS bad_dt_lib,_stdout         write message
         

closedos move.l   _DOSBase,a1                 base needed in a1        
    
         CALLSYS  CloseLibrary,_SysBase


exit     clr.l    d0
         
         rts                                  logical end of program
        
* --------------------------------------------------------------------    
; variables and static data...

_stdout           ds.l    1

_SysBase          ds.l    1

_DOSBase          ds.l    1

_DataTypesBase    ds.l    1

datatype_p        ds.l    1

lock              ds.l    1
    
filename          ds.b   50

dos_name          dc.b 'dos.library',NULL
    
datatypes_name    dc.b 'datatypes.library',NULL

bad_dt_lib        dc.b 'sorry - cannot open the datatypes library',LF

bad_dt_lib_SIZEOF  EQU *-bad_dt_lib

bad_dt            dc.b 'sorry - no datatype available',LF

bad_dt_SIZEOF      EQU *-bad_dt

bad_lock          dc.b 'sorry - could not find this file',LF

bad_lock_SIZEOF   EQU *-bad_lock

format            dc.b  '%s',LF,NULL

                  END
                      
* --------------------------------------------------------------------



** library.asm ** smalldata (taskshared)

;000517 : added xrefs for init, open, close and expunge
; added code to call them, let see if it works.
; this means the programmer must/got_the_power to
; use theese functions.
;000521. not working. dont know if it is this
; or something else bugging.. will comment out
; and try again.
;000521 : it was about not returning libbase (d0) in initroutine !!
;000522 : the same globals as in startup.asm is now
; defined here. all except _SysBase is set to NIL!
; if u want to open libs, do it in init(), close
; them in expunge(). be sure to return NIL in d0
; in init() if something goes wrong! And to handle the error!
; 000616 : forgot to init a4 before calling
; users init, open, close, expunge. FIXED
; optimised from 312 bytes to 290 bytes ! :)
  
        INCDIR "cinc:" 
        INCLUDE "exec/initializers.i" 
        INCLUDE "exec/libraries.i" 
        INCLUDE "exec/resident.i" 

   incdir "ainc:" 
 
   include "lib/exec.i" 
   include "lib/dos.i" 
 
****** globals ******
 
 xdef _SysBase 
 xdef _DOSBase 
 xdef _IntuitionBase 
 xdef _GfxBase 
 xdef _UtilityBase 
 xdef _arg 
 xdef _stdin 
 xdef _stdout 
 xdef _exception 
 xdef _exceptioninfo 
 xdef _LITTEL 
 xdef _G1 
 xdef _G2 
 xdef _G3 
 xdef _G4 


****** the four required userfunctions imported from main binary ******

   xref init 
   xref open
   xref close
   xref expunge

****** theese are imported from main binary ******
 
   xref Lib.VERSION 
   xref Lib.REVISION 
   xref Lib.Name 
   xref Lib.IDString 
   xref Lib.funcTable 
 
****** linker ..hmm.. what its called-- ***

   xref _DATA_BAS_ 
 
***** export theese to main binary ****

   xdef Lib.Open 
   xdef Lib.Close 
   xdef Lib.Expunge 
   xdef Lib.Extfunc 
 
***** we dont care much for poor 68000 do we ? *****

    MACHINE 68020 
 
**** smalldata, ofcource ****

    near A4,-1 
   
    code 

***********************************************
 
Lib.Prevent: 
        MoveQ #-1,d0 
        rts 

***********************************************
 
Lib.RomTag: 
               ;STRUCTURE RT,0 
        dc.w RTC_MATCHWORD ; UWORD RT_MATCHWORD 
        dc.l Lib.RomTag        ; APTR  RT_MATCHTAG 
        dc.l Lib.EndCode       ; APTR  RT_ENDSKIP 
        dc.b RTF_AUTOINIT  ; UBYTE RT_FLAGS 
        dc.b Lib.VERSION   ; UBYTE RT_VERSION 
        dc.b NT_LIBRARY    ; UBYTE RT_TYPE 
        dc.b 0             ; BYTE  RT_PRI 
        dc.l Lib.Name      ; APTR  RT_NAME 
        dc.l Lib.IDString  ; APTR  RT_IDSTRING 
        dc.l Lib.InitTable     ; APTR  RT_INIT 

************************************************
 
Lib.InitTable: 
        dc.l 34 ;LIB_SIZEOF  ; size of library base data, sizeof(struct Library) 
        dc.l Lib.funcTable   ; pointer function pointer table below 
        dc.l Lib.dataTable   ; pointer to the library data initializer table 
        dc.l Lib.initRoutine ; routine to run 

************************************************
 
Lib.dataTable: 
        INITBYTE     LN_TYPE,NT_LIBRARY 
        INITLONG     LN_NAME,Lib.Name 
        INITBYTE     LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED 
        INITWORD     LIB_VERSION,Lib.VERSION 
        INITWORD     LIB_REVISION,Lib.REVISION 
        INITLONG     LIB_IDSTRING,Lib.IDString 
        dc.l 0 

************************************************
 
Lib.initRoutine:     ; (segment list:a0, libbase:d0) 

   * save all regs *
   movem.l d1-d7/a0-a6, -(a7)

   * smalldata *
   lea _DATA_BAS_, a4   ;init smalldata (task shared) 
   lea 32766(a4), a4    ; 
   move.l a4, littel_a4 ;

   * save seglist *
   move.l a0, _seglist(a4)

   * save libbase *
   move.l d0, _libbase(a4)
 
   * open sysbase  * 
   move.l 4, a6 
   move.l a6, _SysBase(A4) 


   
;---- user init ----
   ;* save all regs *
   ;movem.l d1-d7/a0-a6, -(a7)
   ;* get global access *
   ;move.l littel_a4, a4
   * call user init *
   bsr init
   ;* restore all regs *
   ;movem.l (a7)+, d1-d7/a0-a6
   * check if it went okey * 
   tst.l d0
   * on error, do something about it! *
   beq init_error  
;-------------------------
;

       * get libbase in d0, it means it went ok *
       move.l _libbase(a4), d0

       bra init_end    
init_error:
       * houston...we have a problem... * 
       move.l #0, d0
init_end:
       * restore all regs *
       movem.l (a7)+, d1-d7/a0-a6
       rts 



****************************************

     ;--------------------------------------------- 
     ; The four required functions: 
     ; ****Assembler source code version**** 
     ;--------------------------------------------- 
 
Lib.Open:     ; (libptr:A6, version:D0) 
         
       ; Increase the library's open counter 
       addq.w   #1,LIB_OPENCNT(a6) 
 
       ; Clear delayed expunges (standard procedure) 
       bclr     #LIBB_DELEXP,LIB_FLAGS(a6) 


;-------user open-------------------
   * save all regs *
   movem.l d1-d7/a0-a6, -(A7)
   * get global access *
   move.l littel_a4, a4
   * call user open *
   bsr open
   * restore all regs *
   movem.l (a7)+, d1-d7/a0-a6
   * check if okey *
   tst.l d0
   * if not, we do something about it *
   beq open_error
;----------------------------

       * Return library base, as a sign of success * 
       move.l   a6,d0

       bra open_end 
open_error:
       * houston...well..you know... *
       move.l #0, d0
open_end: 
       rts 

***************************************
 
Lib.Close:     ; (libptr:a6) 


;------user close------------
   * save the damn regs *
   movem.l d1-d7/a0-a6, -(a7)
   * get the damn global access *
   move.l littel_a4, a4
   * call the damn user close *
   bsr close
   * restore the damn regs *
   movem.l (a7)+, d1-d7/a0-a6
;----------------------------  

       ; set the return value 
       moveq    #0,d0 
 
       ; Decrease the library's open counter 
       subq.w   #1,LIB_OPENCNT(a6) 
 
       ; If there is anyone still open, return 
       bne.s    Lib.retlabel 
 
       ; Is there a delayed expunge waiting? 
       btst     #LIBB_DELEXP,LIB_FLAGS(a6) 
       beq.s    Lib.retlabel 
 
       ; Do the expunge! 
       bsr      Lib.Expunge ; returns the segment list 
 
Lib.retlabel: 
       rts 

**************************************
 
Lib.Expunge:     ; (libptr:a6) 
  
       ; Is the library still open? 
       tst.w    LIB_OPENCNT(a6) 
       beq      Lib.notopen 
 
       ; It is still open. set the delayed expunge flag 
       ; and return zero 
       bset     #LIBB_DELEXP,LIB_FLAGS(a6) 
       moveq    #0,d0 
       rts      ; return 
 
Lib.notopen: ; Get rid of us! 


;-----user expunge----------------------
   * save regs *
   movem.l d1-d7/a0-a6, -(a7)
   * get global access *
   move.l littel_a4, a4
   * call user expunge *
   bsr expunge
;-------------------------

   ; Store our segment list in d2
   move.l   _seglist(a4),d2

   move.l _SysBase(a4), a6
   move.l _libbase(a4), a5

   ; Unlink from library list
   move.l   a5,a1
   jsr      Remove(a6) ; This removes our node from the list

   ; Free our memory
   moveq    #0,d0
   move.l   a5,a1
   move.w   LIB_NEGSIZE(a5),d0

   sub.l    d0,a1
   add.w    LIB_POSSIZE(a5),d0

   jsr      FreeMem(a6) ; This frees the memory we occupied

   ; Return the segment list
   move.l   d2,d0

   * restore regs *
   movem.l (a7)+, d1-d7/a0-a6

   rts
;----------------------------------
 
 
Lib.Extfunc:     ; should return zero 
        moveq   #0,d0 
        rts 
 
   xdef littel_a4 
 
littel_a4: 
   ds.l 1 
 
   ;data 
 
 
Lib.EndCode: 
 
 
  xdef _SysBase, _DOSBase, _IntuitionBase, _GfxBase, _UtilityBase 
  xdef _arg, _stdin, _stdout, _exception, _exceptioninfo 
  xdef _LITTEL, _G1, _G2, _G3, _G4 
 
  BSS 
 
_SysBase: 
   ds.l 1 
_DOSBase: 
   ds.l 1 
_IntuitionBase: 
   ds.l 1 
_GfxBase: 
   ds.l 1 
_UtilityBase: 
   ds.l 1 
_arg: 
   ds.l 1 
_stdin: 
   ds.l 1 
_stdout: 
   ds.l 1 
_exception: 
   ds.l 1 
_exceptioninfo: 
   ds.l 1 
_LITTEL: 
   ds.l 1 
_reserved1: 
   ds.l 1 
_reserved2: 
   ds.l 1 
_G1: 
   ds.l 1 
_G2: 
   ds.l 1 
_G3: 
   ds.l 1 
_G4: 
   ds.l 1 
_seglist: ;not exported, just internal
   ds.l 1
_libbase: ;not exported, just internal
   ds.l 1 
  
   END 

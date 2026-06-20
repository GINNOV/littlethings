;*************************************************************************
; ParOut.asm - Parallel port resource example. Shows how to allocate and
;              communicate directly with the parallel port hardware.
;
; Orig C code by Phillip Lindsay (c) Commodore-Amiga, Inc.   
; Unlimited use granted as long as copyright notice remains intact.
;
; Asm version by Jeff Glatt
;
; Blink StartUp.o ParOut.o NODEBUG to ParOut

   ;CAPE directives
   OPTIMON
   ADDSYM
   OBJFILE   "rad:ParOut.o"
   SMALLOBJ

   ;from small.lib
   XREF   _LVOSignal,_LVOAllocSignal,_LVOFreeSignal,_LVOWait,_LVOOpenResource

   ;from   SmallStart.o
   XREF   _SysBase,_DOSBase,_ThisTask

;parallel port hardware addresses and bits
CIAF_PRTRBUSY   equ   0
ciab_pra         equ   $BFD000
ciab_ddra      equ   $BFD200

ciaa_ddrb      equ   $BFE301
ciaa_prb         equ   $BFE101

;for ciaa.resource
_LVOSetICR         equ   -24
_LVORemICRVector   equ   -12
_LVOAddICRVector   equ   -6
_LVOAbleICR         equ   -18
CIAICRB_FLG         equ   4
CIAICRF_FLG         equ   16   ;bit #4 set for handshaking

;for misc.resource, see "Libraries and Devices" pg C-8
_LVOGetMiscResource   equ   -6
_LVOFreeMiscResource   equ   -12
MR_PARALLELPORT   equ   2
MR_PARALLELBITS   equ   3

   XDEF   _main
_main:
;================ OPEN RESOURCES (used to grab hardware responsibly)========
; In order to obtain exclusive access to hardware in the Amiga with the
; knowledge and consent of Exec, we must "allocate" the hardware via the
; CIAA and Misc resources. These software modules help make it easier to
; set up the hardware, as well as informing Exec that no other task should
; be allowed to use the hardware while we "own" it. In this way, we can
; write directly to parallel port hardware addresses, without worrying about
; some task using the printer or parallel devices. Exec will prevent those
; devices from gaining access to the hardware, as those devices "allocate"
; the hardware via the resources, just as we are about to do. The resources
; only allow one task to "own" the hardware at a time. See appendix C of the
; "Libraries and Devices" manual.
   ;---Open the ciaa.resource
      lea      CIAAName,a1
      moveq      #0,d0
      movea.l   _SysBase,a6
      jsr      _LVOOpenResource(a6)
      move.l   d0,_CIAAResource
      bne.s      ociaa
      moveq      #10,d0
      rts
   ;---Open the misc.resource
ociaa   lea      MiscName,a1
      moveq      #0,d0
      jsr      _LVOOpenResource(a6)
      move.l   d0,_MiscResource
      bne.s      omisc
      moveq      #20,d0
      rts
;=======================GRAB PARALLEL HARDWARE===========================   
;This is where we get our 8bits for parallel transfer. Remember, if some
;other task "allocated" MR_PARALLELPORT before us, then this routine will
;return a non-zero value (i.e. the Name of the dirty sod who stole the
;parallel port). This means "forget it chump. You can't use the hardware
;until this other bozo frees it". If we get a 0, then the hardware is ours.
omisc   lea      Name,a1               ;Our Name
      moveq      #MR_PARALLELPORT,d0   ;unit
      movea.l   d0,a6                  ;MiscResource Base
      jsr      _LVOGetMiscResource(a6)
      move.l   d0,d1
      beq.s      port
   ;---Oops. Someone else must have grabbed this hardware before us.
      moveq      #30,d0
      rts
;This is where we get busy(bit 0), pout(bit 1), sel(bit 2) lines
port   lea      Name,a1               ;name
      moveq      #MR_PARALLELBITS,d0   ;unit
      jsr      _LVOGetMiscResource(a6)
      move.l   d0,d1
      beq.s      bits
   ;---Oops. Someone else must have grabbed this hardware before us.
      moveq      #40,d2
      bra      Free1
;================== ALLOCATE A SIGNAL TO WAKE UP _main =====================
   ;---Allocate a Signal for waking us up
bits   moveq      #-1,d0
      movea.l   _SysBase,a6
      jsr      _LVOAllocSignal(a6)
      move.b   d0,d7
      bpl.s      mask
      ;---If error, Free MR_PARALLELPORT and MR_PARALLELBITS
      moveq      #50,d2
      bra      Free2
   ;----Make a mask of the signal and store it where our handshake interrupt
   ;    code can get it; in the IS_DATA field of our interrupt structure.
mask   moveq      #0,d1
      Bset.l   d0,d1
      move.l   d1,SigMask
;**** Now we own the parallel port, let's get a handshake interrupt setup ****
; We now add an interrupt vector for the CIAICRB_FLG bit of the parallel
; port. This is the "handshaking" bit that an external device connected to
; the parallel port would toggle to inform us when it is ready for something.
      lea      CIAAInterrupt,a1
      moveq      #CIAICRB_FLG,d0
      movea.l   _CIAAResource,a6
      jsr      _LVOAddICRVector(a6)
      move.l   d0,d1
      beq.s      hand
   ;---If an error, free hardware so others can use it
      moveq      #50,d2
      bra.s      Free3
;-----Disable HandShake interrupt (before we set up data direction regs)----
hand   moveq      #CIAICRF_FLG,d0
      jsr      _LVOAbleICR(a6)
;=========== Now we write the hardware addresses directly ===============
;---make CIAA port B all 8 "outputs" (a 1 bit means that pin is an out)-----
      move.b   #$FF,ciaa_ddrb
;----make BUSY, SEL, POUT lines "inputs" on CIAA port A---
      andi.b   #$FF,ciab_ddra
;----Clear any pending HandShake interrupts (before we enable handshaking)
      moveq      #CIAICRF_FLG,d0
      jsr      _LVOSetICR(a6)
;----Finally, enable HandShake interrupt----
      moveq      #0,d0
      move.b   #144,d0         ;CIAICRF_FLG with enable (bit #7) set
      jsr      _LVOAbleICR(a6)
;========================== OUTPUT DATA LOOP ===============================
; We are now going to output our NULL-terminated string one byte at a time,
; waiting for the external device to ACK (handshake) after each received byte.
      lea      Message,a2      ;the string to output
      movea.l   _SysBase,a6
aByte   move.b   (a2)+,d0
      beq.s      Free5            ;end of our string yet?
   ;---Make sure that the device is not busy. We do this by busy polling
   ;   the PRTRBUSY line of ciab.ciapra. Actually, if the device were taking
   ;    a long time, this busy wait would eat up processor time, but we
   ;    assume that the device accepts data quickly.   
busy   Btst.b   #CIAF_PRTRBUSY,ciab_pra
      bne.s      busy
   ;---write this ascii byte to output port (viola! Out the parallel port)
      move.b   d0,ciaa_prb
   ;----Wait for the external device to ACK (on the HandShake line)
   ;    Gee, I hope that you have some intelligent device hooked up now!!!
      move.l   SigMask,d0
      jsr      _LVOWait(a6)
      bra.s      aByte
;=================Free resources (parallel port) and exit=================
; Now free the hardware for someone else to use
   ;---error code = OK
Free5   moveq      #0,d2
   ;---Disable the HandShake interrupt (before we remove it)
      moveq      #16,d0
      movea.l   _CIAAResource,a6
      jsr      _LVOAbleICR(a6)
   ;---Remove the HandShake interrupt
Free4   lea      CIAAInterrupt,a1
      moveq      #4,d0
      movea.l   _CIAAResource,a6
      jsr      _LVORemICRVector(a6)
   ;---Free Signal
Free3   move.b   d7,d0
      movea.l   _SysBase,a6
      jsr      _LVOFreeSignal(a6)
   ;---Free MR_PARALLELBITS
Free2   moveq      #MR_PARALLELBITS,d0
      movea.l   _MiscResource,a6
      jsr      _LVOFreeMiscResource(a6)
   ;---Free MR_PARALLELPORT
Free1   moveq      #MR_PARALLELPORT,d0
      movea.l   _MiscResource,a6
      jsr      _LVOFreeMiscResource(a6)
   ;---return error code to DOS
      move.l   d2,d0
      rts

;=========================================================================
; This routine is called (via the operating system) whenever an external
; device sets the "handshaking" line of the parallel port. We installed
; this interrupt handler in _main. This routine simply wakes _main up.
; _main waits for an ACK after each byte of our string is pumped out the port.
; Exec puts our IS_DATA in a1. Our IS_DATA should be our wakeup mask. Now
; we only need to get the address of our main task which our StartUp.o
; startup code placed at the label _ThisTask.

   XDEF   CIAARoutine
CIAARoutine:
   move.l   a1,d0
   movea.l   _ThisTask,a1
   movea.l   _SysBase,a6
   jsr      _LVOSignal(a6)
   moveq      #0,d0
   rts

   XDEF   _CIAAResource,_MiscResource
_CIAAResource   dc.l   0
_MiscResource   dc.l   0

NT_INTERRUPT   equ   2

   XDEF   CIAAInterrupt,SigMask
   ;The interrupt structure for the "handshaking" line of the parallel port.
CIAAInterrupt:
   dc.l   0,0
   dc.b   NT_INTERRUPT,0
   dc.l   Name
SigMask:
   dc.l   0            ;we'll store our wakeup mask in the IS_DATA field
   dc.l   CIAARoutine   ;IS_CODE (routine executed when "handshake" occurs)

   XDEF   IntuitionName,CIAAName,MiscName
IntuitionName   dc.b   'intuition.library',0
CIAAName         dc.b   'ciaa.resource',0
MiscName         dc.b   'misc.resource',0

   XDEF   Name
Name   dc.b   'Parallel Test',0

   XDEF   Message
   ;This is the NULL-terminated string we'll send out of the parallel port.
Message   dc.b   'This is a test of the parallel port',0

   END

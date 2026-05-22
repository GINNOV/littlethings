*************************************************************************
*                                                                       *
*                                                                       *
*       Program Name:   NoClick3.5                                      *
*                                                                       *
*       Version Date:   26 August 1989                                  *
*                                                                       *
*       Based on the original NoClick program posted by                 *
*       Dan Babcock to PLINK in May 1989                                *
*                                                                       *
*       With thanks to Werner Guenther for showing the use of           *
*       FindName to generate the trackdisk task list, and               *
*       pointing out the possibility of changing the code's             *
*       jump table.  Thanks also to Dwight Blubaugh for flagging        *
*       the stack frame problem with 68010/20/30 systems.               *
*                                                                       *
*       Copyright (c) 1989 - Norman Iscove  iscove@utoroci (bitnet)     *
*                                                                       *
*       USAGE:  Place in c: directory.  Type 'NoClick3.5' from CLI,     *
*       or include in Startup-sequence, preferably after FastMemFirst.  *
*       Safer not to invoke it when disks are concurrently active.      *
*                                                                       *
*       FUNCTION:                                                       *
*                                                                       *
*       Intended to eliminate clicking of empty drives installed in     *
*       Amiga 500, 1000 or 2x00 computers, provided the particular      *
*       drive models respond quietly to negative stepping of the        *
*       heads past track 0.  The program checks for and sets            *
*       additional floppy drives if also present.  Aborts harmlessly    *
*       if a second execution is attempted.  Also repairs a known       *
*       bug in the trackdisk.device code involving raw read and         *
*       write calls.                                                    *
*                                                                       *
*       Works by copying the trackdisk.device code from rom into        *
*       ram.  A single byte is modified so that the drive heads         *
*       will be stepped (silently) in a negative rather than            *
*       positive direction during the regular system checks for a       *
*       disk change.  One word is also altered to repair the raw        *
*       read/write bug.  After creating the copy and fixing it, the     *
*       program changes the system vectors in each drive's task         *
*       structure to point to the ram copy.                             *
*                                                                       *
*                                                                       *
*       ENTRY REGISTERS:  none assumed                                  *
*                                                                       *
*       EXIT  REGISTERS:  d2-d7/a2-a6 preserved in entry condition      *
*                         d0 = 0                                        *
*                                                                       *
*       ASSUMPTIONS:                                                    *
*                                                                       *
*       Private structure of the trackdisk.device code in rom is        *
*       not documented.  The offsets of the pointers to start and       *
*       end of the code, and the offsets of the bytes to be altered     *
*       are all determined by inspection of the code in the 1.3 rom.    *
*                                                                       *
*       CAVEAT:                                                         *
*                                                                       *
*       Has been tested and works on a B2000 running KS/WB 1.3 V34.2    *
*       with two internal floppy drives, 2 MB expansion memory (2058)   *
*       and no hard drive.                                              *
*                                                                       *
*************************************************************************
 
 
 
        INCLUDE 'sys:include/exec/exec_lib.i'
 
*-----------------------------------------------------------------------*
*               Save the incoming registers                             *
*-----------------------------------------------------------------------*
noclick:   movem.l d2-d7/a2-a6,-(sp)
        movea.l 4,a6            ;a6 = execbase
 
 
*-----------------------------------------------------------------------*
*       Make a list of all the trackdisk tasks                          *
*-----------------------------------------------------------------------*
tasklist:
        moveq   #1,d6           ;d6 = counter (search through two lists)
        lea     tasks,a3        ;a3 = pointer to my list of td tasks
        lea     tdname,a4       ;a4 = pointer to "trackdisk.device"
        jsr     _LVODisable(a6) ;disable interrupts & task switching
        lea     406(a6),a0      ;a0 = start of taskready queue
nexttask:
        move.l  a4,a1           ;a1 = pointer to "trackdisk.device"
        jsr     _LVOFindName(a6) ;find the next task with this name
        move.l  d0,(a3)+        ;save task pointer in my list, sets cond.
        movea.l d0,a0           ;a0 = start for next FindName search
        bne.s   nexttask        ;check for next task if not zero
waitqueue:
        lea     -4(a3),a3       ;correct pointer
        lea     420(a6),a0      ;a0 = start of taskwait queue
        dbf     d6,nexttask
        jsr     _LVOEnable(a6)
 
 
*-----------------------------------------------------------------------*
*               Abort if already installed                              *
*-----------------------------------------------------------------------*
check:
        lea     tasks,a4        ;1st entry is the one that was ready
        bsr     nextset
        move.l  $46(a3),a0      ;a0 = finalPC, td code that task exits to
        cmp.l   #$f80000,a0     ;exit if already pointing to ram
        bls     exitnoclick
 
 
*-----------------------------------------------------------------------*
*       Find trackdisk.device in rom, get start, end, size              *
*-----------------------------------------------------------------------*
findcode:
 
        lea     tdname,a0
        moveq   #0,d0           ;unit df0:
        moveq   #0,d1           ;flags
        lea     iorequest,a1
        jsr     _LVOOpenDevice(a6) ;open the trackdisk.device
        bne     exitnoclick
        move.l  iodevice,a3     ;a3 = trackdisk library base address C03AE4
        lea     iorequest,a1
        jsr     _LVOCloseDevice(a6)
        move.l  $0A(a3),a1      ;ln_name(a3) (C03AEE) points to string
                                ; 'trackdisk.device' at FE957E
        sub.w   #$18,a1         ;a1 = FE9566
        move.l  (a1),d2         ;d2 = start of trackdisk routine in rom,
                                ;     FE9564.
        add.w   #4,a1           ;a1 = FE956A
        move.l  (a1),a0         ;a0 = end of trackdisk routine in rom,
                                ;     FEB05C
        suba    d2,a0           ;a0 = signed length of trackdisk routine
        moveq   #0,d3
        move.w  a0,d3           ;d3 = unsigned length (bytes) of td routine
        addq    #3,d3           ;ensure all copied if not multiple of 4
 
 
*-----------------------------------------------------------------------*
*              Allocate some ram and copy to it                         *
*-----------------------------------------------------------------------*
copy:
        move.l  d3,d0           ;d0 = number of bytes
        moveq   #1,d1           ;d1 = MEMF_PUBLIC, fastmem if available
        jsr     _LVOAllocMem(a6)
        move.l  d0,a1           ;d0,a1 = location of reserved block in ram
        lsr.w   #2,d3           ;d3 = number of longs to copy
        move.l  d2,a0           ;a0 = start of rom routine
 
cploop:
        move.l  (a0)+,(a1)+     ;copy rom routine to ram
        dbra    d3,cploop
 
 
*-----------------------------------------------------------------------*
*   This section will fix the copy's jump table so that _all_ system    *
*   calls to the trackdisk tasks will use only the code in the ram      *
*   copy.  If the table is not altered, most of the calls will jump     *
*   back into the rom original.  It is not necessary to change the      *
*   jump table for the rmvclick patch to take effect.                   *
*-----------------------------------------------------------------------*
;fixjumps:
;       move.l  d2,d3          ;d3 = start of rom routine
;       sub.l   d0,d3          ;- start of ram copy = offset
;       movea.l d0,a0          ;a0 = start of ram copy
;       lea     $a1c(a0),a0    ;a0 = pointer to copy's jump table
;       moveq   #21,d4         ;d4 = 22 functions to patch
;fj1:
;       sub.l   d3,(a0)+       ;correct the address of each function
;       dbf     d4,fj1
 
 
*-----------------------------------------------------------------------*
*                   Stop the clicks                                     *
*-----------------------------------------------------------------------*
rmvclick:
        move.l  d0,a5           ;a5 = location of copy
        bchg    #7,$0105(a5)    ;fix the critical byte
 
 
*-----------------------------------------------------------------------*
*    Repair the trackdisk read/write bug originally at $feaf9c (1.3).   *
*    The fix has no effect unless the fixjumps section is implemented.  *
*-----------------------------------------------------------------------*
fixbug:
        move.w  #$0C80,$1A38(a5) ;change to cmp.l #$8000,d0
 
 
*-----------------------------------------------------------------------*
*       Fix each task's exit vector to point to ram version             *
*-----------------------------------------------------------------------*
checkcpu:
        moveq   #0,d4           ;d4 = 0, offset for fixptrs
        move.w  296(a6),d5      ;AttnFlags = 0 if cpu is 68000, set cond.
        beq.s   fixptrs         ;branch if cpu is 68000
        moveq   #4,d4           ;d4 = 4 if not 68000
 
fixptrs:
        lea     tasks,a4        ;a4 = address of task list
        bsr.s   nextset         ;a3 = tc_SPReg for listed task
        move.l  $46(a3,d4),a2   ;a2 = finalPC, td code that task exits to
        sub.l   d2,a2           ;a2 = offset of code from start (d2) in rom
        add.l   a2,a5           ;a5 = corresponding address in ram copy
 
        jsr     _LVODisable(a6)
        move.l  a5,$46(a3,d4)   ;replace corrected finalPC pointer
        jsr     _LVOEnable(a6)
 
fixloop:
        bsr.s   nextset
        beq.s   exitnoclick            ;exit on a1 = 0 (address next listed task)
        jsr     _LVODisable(a6)
        move.l  a5,$46(a3,d4)   ;replace corrected finalPC pointer
        jsr     _LVOEnable(a6)
        bra.s   fixloop
 
 
*-----------------------------------------------------------------------*
*                       Done                                            *
*-----------------------------------------------------------------------*
exitnoclick:
        movem.l (sp)+,d2-d7/a2-a6 ;restore the incoming registers
        moveq   #0,d0             ;tell system no error
        rts
 
 
 
 
;*** subroutines
 
*-----------------------------------------------------------------------*
*       Find task's exit pointer to trackdisk code                      *
*                                                                       *
*       Exit registers:  a1 = address of task structure                 *
*                        a3 = tc_SPReg                                  *
*                        d0 = a1                                        *
*                        z flag = 0 if no more tasks                    *
*-----------------------------------------------------------------------*
nextset:
        move.l  (a4)+,a1        ;a1 = address of this task structure
        move.l  $36(a1),a3      ;a3 = tc_SPReg for this task
        move.l  a1,d0           ;test for a1=0
        rts
 
 
;*** data
 
 
tdname:
        dc.b    'trackdisk.device',0
        EVEN
 
iorequest:
        dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
iodevice:
        dc.b    0,0,0,0
iounit:
        dc.b    0,0,0,0,0,0,0,0
        EVEN
 
tasks:
    ds.l    4   ;room for 4 drives
    dc.l    0   ;end of list marker
 


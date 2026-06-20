****************************************************************************
*                                                                          *
*  Comments copyright (c) 1989 Markus Wandel                               *
*                                                                          *
*  Release date:  February 3, 1989.                                        *
*                                                                          *
*  The following is a complete disassembly of the Amiga 1.2 "exec", as     *
*  found on a kickstart disk for an Amiga 1000.  Everything is shown,      *
*  right down to the padding introduced by the linker, and unused code     *
*  fragments which probably made it in by accident.                        *
*                                                                          *
*  Thorough familiarity with the Rom Kernel Manual: Exec, with suitable    *
*  updates to version 1.2, and the exec subdirectory of the include files, *
*  is assumed in all comments.  Where existing documentation appears to    *
*  be inadequate, or a particular section of code is judged to be more     *
*  interesting than most, comments are more extensive.                     *
*                                                                          *
*  Absolutely no guarantee is made of the correctness of all information   *
*  supplied below, nor of its usefulness.                                  *
*                                                                          *
*  Note that virtually all references to "ROM" actually refer to the       *
*  write-protected RAM which the kickstart disk loads into.  The genuine   *
*  ROMs on Amiga 500 and 2000 computers may not contain exactly the same   *
*  code, although most of it should be similar.                            *
*                                                                          *
*  The completed disassembly file is not redistributable, and contains     *
*  code which is copyrighted by Commodore-Amiga, and comments which are    *
*  copyrighted by Markus Wandel.  The source file used to make the         *
*  disassembly is distributable under a limited set of conditions as       *
*  outlined in the accompanying documentation.                             *
*                                                                          *
*  For Commodore-Amiga's copyright notice, see a few lines farther down.   *
*                                                                          *
****************************************************************************

        ; This match word is used when looking for ROMs.

FC0000  1111

        ; The ROM can be started by jumping to its base address plus 2,
        ; or by mapping it at location zero and resetting.  Either way,
        ; the machine starts running at FC00D2 (in the latter case, because
        ; the 68000's PC is loaded from location 4 at cold start).

FC0002  jmp       FC00D2

FC0008  0000                        Garbage.
FC000A  FFFF

        ; The following version number doesn't appear to be used
        ; from within exec.library.

FC000C  0021
FC000E  00B4

        ; The following version number appears in the exec.library
        ; node, and this copy is checked to ensure it is still valid.

FC0010  0021                        Version.
FC0012  00C0                        Revision.

FC0014  FFFFFFFF                    Garbage.

        ; The exec's ID string
        ; --------------------

FC0018  "exec 33.192 (8 Oct 1986)", CR, LF, 00, 00

FC0034  FFFFFFFF                    Garbage.

        ; Copyright notice.
        ; -----------------

FC0038  CR, LF, LF, "AMIGA ROM Operating System and Libraries", CR, LF
FC0065  "Copyright (C) 1985, Commodore-Amiga, Inc.", CR, LF
FC0090  "All Rights Reserved.", CR, LF, 00, 00

        ; Library name
        ; ------------

FC00A8  "exec.library", 00, 00

        ; The RomTag structure.
        ; ---------------------

FC00B6  4AFC                        RTC_MATCHWORD   (start of ROMTAG marker)
FC00B8  00FC00B6                    RT_MATCHTAG     (pointer RTC_MATCHWORD)
FC00BC  00FC323A                    RT_ENDSKIP      (pointer to end of code)
FC00C0  00                          RT_FLAGS        (no flags)
FC00C1  21                          RT_VERSION      (version number)
FC00C2  09                          RT_TYPE         (NT_LIBRARY)
FC00C3  78                          RT_PRI          (priority = 126)
FC00C4  00FC00A8                    RT_NAME         (pointer to name)
FC00C8  00FC0018                    RT_IDSTRING     (pointer to ID string)
FC00CC  00FC00D2                    RT_INIT         (execution address)


FC00D0  reset     

        ; We start running here.

FC00D2  lea       040000,SP         Set stack pointer to top of first 128K.
FC00D8  move.l    #$020000,D0
FC00DE  subq.l    #1,D0             Delay loop.
FC00E0  bgt.s     FC00DE

        ; If the ROM is also visible at F00000, or if there is another
        ; ROM there, jump there.

FC00E2  lea       FC0000(PC),A0     Load base address of ROM we're in.
FC00E6  lea       F00000,A1         Load (absolute address) F00000.
FC00EC  cmp.l     A1,A0             Are we at F00000?
FC00EE  beq.s     FC00FE            If so, don't execute the following.
FC00F0  lea       FC00FE(PC),A5     This is relative, i.e. always points
                                    12 bytes down from where we are.
FC00F4  cmp.w     #$1111,(A1)       If "1111" not found at F00000, then
FC00F8  bne.s     FC00FE            continue running below, else start
FC00FA  jmp       2(A1)             running at F00002.

        ; Set up port A on the first CIA (8520-A).

FC00FE  move.b    #3,BFE201         Set low two bits for output.
FC0106  move.b    #2,BFE001         Set boot ROM off, power light dim.

        ; Disable interrupts and DMA.

FC010E  lea       DFF000,A4         Base address of custom chip area.
FC0114  move.w    #$7FFF,D0
FC0118  move.w    D0,$9A(A4)        Disable all interrupts.
FC011C  move.w    D0,$9C(A4)        Clear all pending interrupts.
FC0120  move.w    D0,$96(A4)        Disable all DMA.

        ; Set a blank, dark gray display.

FC0124  move.w    #$0200,$0100(A4)  BPLCON0 = Blank screen.
FC012A  move.w    #0,$0110(A4)      Bitplane 0 data = all zeros.
FC0130  move.w    #$0444,$0180(A4)  Background colour = dark gray.

        ; Set up the Exception Vector Table.  Vectors 2 through 47
        ; (Bus Error through TRAP #15) are all all set to the initial
        ; exception handler.  If any exception occurs now, the screen
        ; will turn yellow, the power light will flash, and the computer
        ; will be reset.

FC0136  move.w    #8,A0             Start at address 8 (vector #2).
FC013A  move.w    #$2D,D1           Do 46 vectors.
FC013E  lea       FC05B4(PC),A1     Address of initial exception handler.
FC0142  move.l    A1,(A0)+          Set one vector
FC0144  dbra      D1,FC0142(PC)     Loop back.

        ; See if the system wants a guru put up after reboot.

        ; This works as follows:  If for some reason, a guru can't be put
        ; up in the normal fashion, the system writes "HELP" at location
        ; zero, writes the alert data (number and 32-bit parameter) at
        ; location $000100, and resets.

        ; Early in the startup code (right here), this "HELP" is checked
        ; for.  If it is present, it is removed, and the data at location
        ; $000100 is loaded into registers D6 and D7.  If no "HELP" is
        ; found, register D6 is loaded with -1.  This data will later be
        ; put at ExecBase->LastAlert, once the ExecBase structure has been
        ; built.  The following subroutine call does all this.

FC0148  bra       FC30C4            Check for "HELP" at location 0.

        ; Check whether there is already a valid ExecBase data structure.
        ; This is important, since it indicates whether we need to clear and
        ; reconfigure memory (wiping out recoverable RAM disks and such),
        ; or whether we already know the memory configuration and can leave
        ; it untouched.

        ; Note that if the machine crashed in such a way that the ExecBase
        ; structure got clobbered, memory will be cleared.

FC014C  move.l    4,D0              Get pointer at location 4.
FC0150  btst      #0,D0             Check if it is an odd address.
FC0154  bne.s     FC01CE            Go reconfigure memory if it is.
FC0156  move.l    D0,A6             Assume we are pointing to ExecBase.
FC0158  add.l     $26(A6),D0        Get complement of ExecBase.
FC015C  not.l     D0                Check it.
FC015E  bne.s     FC01CE            Go reconfigure memory if it didn't match.
FC0160  moveq     #0,D1
FC0162  lea       $22(A6),A0        Checksum the static part of the ExecBase
FC0166  moveq     #$18,D0           data structure.
FC0168  add.w     (A0)+,D1
FC016A  dbra      D0,FC0168(PC)
FC016E  not.w     D1                Verify the checksum.
FC0170  bne.s     FC01CE            Go reconfigure memory if not valid.

        ; If we get this far, we are reasonably confident that the ExecBase
        ; structure is OK, and run the cold start capture code if there
        ; is any.

FC0172  move.l    $2A(A6),D0        Get the cold start capture vector.
FC0176  beq.s     FC0184            Branch if it is zero.
FC0178  move.l    D0,A0
FC017A  lea       FC0184(PC),A5     Where to come back afterward.
FC017E  clr.l     $2A(A6)           Clear the cold start capture vector.
FC0182  jmp       (A0)              Jump to the cold start capture code.

        ; We come here if the cold start capture vector was zero, or
        ; upon return from the cold-start capture code.  We continue
        ; to verify the ExecBase structure.

FC0184  bchg      #1,BFE001         Flip the power light to bright.

FC018C  move.l    FC0010(PC),D0     Check the version/revision numbers
FC0190  cmp.l     $14(A6),D0        stored in ExecBase against those in ROM.
FC0194  bne.s     FC01CE            Go reconfigure memory if no match.

FC0196  move.l    $3E(A6),A3        Get end address of chip memory.
FC019A  cmp.l     #$080000,A3       Greater than 512K?
FC01A0  bhi.s     FC01CE            If so, it must be invalid.
FC01A2  cmp.l     #$040000,A3       Less than 256K?
FC01A8  bcs.s     FC01CE            If so, it must be invalid.

FC01AA  move.l    $4E(A6),A4        Get end address of $C00000 memory.
FC01AE  move.l    A4,D0
FC01B0  beq       FC0240            All OK if no $C00000 memory.
FC01B4  cmp.l     #$DC0000,A4       Check more than 1.5 meg (invalid).
FC01BA  bhi.s     FC01CE            Go reconfigure memory if so.
FC01BC  cmp.l     #$C40000,A4       Check if less than 256K (invalid).
FC01C2  bcs.s     FC01CE            Go reconfigure memory if so.
FC01C4  move.l    A4,D0
FC01C6  and.l     #$03FFFF,D0       Check that ends on a 256K boundary.
FC01CC  beq.s     FC0240            All OK if it does.

        ; If we come here, it was decided that there is no valid ExecBase
        ; data structure.  This means we have to figure out what the memory
        ; configuration of the machine is.

        ; First, calculate ExecBase based on the assumption that the ExecBase
        ; structure will end up in chip RAM.  This would put it at $0676,
        ; just far enough past the exception vector table to make room for
        ; the jump table.

FC01CE  lea       $0400,A6          Calculate $0676.
FC01D2  sub.w     #$FD8A,A6         (don't ask me why they do it like this).

        ; Now go and check for memory in the $C00000 - $DC0000 area.
        ; This allows for a maximum of 1.75 megabytes of non-chip memory
        ; to be automatically configured if located at $C00000.

FC01D6  lea       C00000,A0         Lower bound for $C00000 memory.
FC01DC  lea       DC0000,A1         High bound for $C00000 memory.
FC01E2  lea       FC01EA(PC),A5     Return address.
FC01E6  bra       FC061A            Go check how much we have.
FC01EA  move.l    A4,D0             Did we find any expansion memory?
FC01EC  beq.s     FC0208            If not, skip the following.

        ; The machine has expansion RAM at $C00000.  We put the ExecBase
        ; structure there to save chip memory.  This puts it at $C00276.

FC01EE  move.l    #$C00000,A6       Calculate $C00276.
FC01F4  sub.w     #$FD8A,A6

        ; Now we clear the expansion memory to zeros.

FC01F8  move.l    A4,D0             Get end address of expansion memory.
FC01FA  lea       C00000,A0         Get start address of expansion memory.
FC0200  lea       FC0208(PC),A5     Set return address.
FC0204  bra       FC0602            Go clear the memory.

        ; Having figured out the end address of expansion memory (in A4),
        ; and the value to use for ExecBase (in A6), we now check how much
        ; chip memory we have.  Any memory in the first 2 megabytes of
        ; address space is considered to be chip memory.  Less than 256K
        ; of chip memory is considered a fatal error.

FC0208  lea       0,A0              Start looking at location 0.
FC020C  lea       200000,A1         Don't look past 2 megabytes.
FC0212  lea       FC021A(PC),A5     Set the return address.
FC0216  bra       FC0592            Go check the memory.
FC021A  cmp.l     #$040000,A3       Do we have at least 256K of chip memory?
FC0220  bcs.s     FC0238            Bomb if not.

        ; Clear chip memory.  Everything from $C0 (right after the end of
        ; the initial exception vector table we've set up) to the end of
        ; chip memory is cleared.

FC0222  move.l    #0,0              Clear location 0.
FC022A  move.l    A3,D0
FC022C  lea       $C0,A0            Set start address to $C0 (end of vectors)
FC0230  lea       FC0240(PC),A5     Set return address.
FC0234  bra       FC0602            Go clear the chip memory.

        ; Since we have found less than 256K of chip memory, some of it
        ; must not be working.  Turn the screen bright green, blink the
        ; power light, and reset.

FC0238  move.w    #$C0,D0
FC023C  bra       FC05B8

        ; We continue here after we've figured out where the chip memory
        ; ends (256K or greater) and where the $C00000 memory ends
        ; (0 if none present).  The two addresses are in A3 and A4,
        ; respectively.

FC0240  lea       DFF000,A0         Point to base of custom chip area.
FC0246  move.w    #$7FFF,$96(A0)    Disable all DMA.
FC024C  move.w    #$0200,$0100(A0)  Set BPLCON0 for a blank screen.
FC0252  move.w    #0,$0110(A0)      Set bitplane 0 data to zeros.
FC0258  move.w    #$0888,$0180(A0)  Set background colour to medium gray.

        ; Clear most of the ExecBase structure to zeros.

FC025E  lea       $54(A6),A0        Point at ExecBase->IntVects.
FC0262  movem.l   $0222(A6),D2-D4   Get KickMemPtr, KickTagPtr, KickCheckSum.
FC0268  moveq     #0,D0
FC026A  move.w    #$7D,D1           Clear all of ExecBase from IntVects
FC026E  move.l    D0,(A0)+          to the end of the structure.
FC0270  dbra      D1,FC026E(PC)
FC0274  movem.l   D2-D4,$0222(A6)   Restore Kick variables saved above.

        ; Set up the ExecBase pointer at location 4, and its complement
        ; in the ExecBase structure.

FC027A  move.l    A6,4              Install ExecBase pointer at location 4.
FC027E  move.l    A6,D0
FC0280  not.l     D0
FC0282  move.l    D0,$26(A6)        Install ExecBase complement check value.

        ; Set up the system stack.

FC0286  move.l    A4,D0             Try to put stack in $C00000 RAM.
FC0288  bne.s     FC028C            Do we have any $C00000 RAM?
FC028A  move.l    A3,D0             If not, use chip RAM.
FC028C  move.l    D0,SP             Set system stack pointer.
FC028E  move.l    D0,$36(A6)        Store system stack upper bound.
FC0292  sub.l     #$001800,D0       Allow 6K bytes for system stack.
FC0298  move.l    D0,$3A(A6)        Store system stack lower bound.

        ; Store the memory configuration.  Next reset will use this if
        ; still intact, and not clear memory.

FC029C  move.l    A3,$3E(A6)        Store top of chip memory.
FC02A0  move.l    A4,$4E(A6)        Store top of $C00000 memory.

        ; Part 2 of the deferred-guru procedure.  Long ago, we set up
        ; registers D6 and D7 with the data for ExecBase->LastAlert.
        ; The following call writes them there.  Now all is ready for
        ; the "alert.hook" mechanism to put up the deferred guru, if
        ; one was wanted.

FC02A4  bsr       FC30E4            Setup ExecBase->LastAlert.

FC02A8  bsr       FC0546            Check CPU type, and if 68881 present.
FC02AC  or.w      D0,$0128(A6)      Or the result into the Attention flags.

        ; Initialize the exec lists.  This is driven from a data table which
        ; contains the offsets from ExecBase where the various lists are,
        ; and the list types.

FC02B0  lea       FC02D2(PC),A1     Point to the table.
FC02B4  move.w    (A1)+,D0          Get a table entry.
FC02B6  beq       FC033E            Zero marks the end.
FC02BA  lea       0(A6,D0.w),A0     Add to ExecBase to get absolute address.
FC02BE  move.l    A0,(A0)           Clear the list by setting its head
FC02C0  addq.l    #4,(A0)           pointer to point to itself,
FC02C2  clr.l     4(A0)             clearing its "Tail" field,
FC02C6  move.l    A0,8(A0)          and setting up the "TailPred" pointer.
FC02CA  move.w    (A1)+,D0          Get the list type.
FC02CC  move.b    D0,$0C(A0)        Put it into the list header.
FC02D0  bra.s     FC02B4            Loop back to do next list.

        ; Table of list header offsets and types.

FC02D2  0142 000A       MemList       (ExecBase + $142, type = NT_MEMORY)
FC02D6  0150 0008       ResourceList  (ExecBase + $150, type = NT_RESOURCE)
FC02DA  015E 0003       DeviceList    (ExecBase + $15E, type = NT_DEVICE)
FC02DE  017A 0009       LibList       (ExecBase + $17A, type = NT_LIBRARY)
FC02E2  0188 0004       PortList      (ExecBase + $188, type = NT_MSGPORT)
FC02E6  0196 0001       TaskReady     (ExecBase + $196, type = NT_TASK)
FC02EA  01A4 0001       TaskWait      (ExecBase + $1A4, type = NT_TASK)
FC02EE  016C 0002       IntrList      (ExecBase + $16C, type = NT_INTERRUPT)
FC02F2  01B2 000B       SoftInts[0]   (ExecBase + $1B2, type = NT_SOFTINT)
FC02F6  01C2 000B       SoftInts[1]   (ExecBase + $1C2, type = NT_SOFTINT)
FC02FA  01D2 000B       SoftInts[2]   (ExecBase + $1D2, type = NT_SOFTINT)
FC02FE  01E2 000B       SoftInts[3]   (ExecBase + $1E2, type = NT_SOFTINT)
FC0302  01F2 000B       SoftInts[4]   (ExecBase + $1F2, type = NT_SOFTINT)
FC0306  0214 000F       SemaphoreList (ExecBase + $214, type = NT_SIGNALSEM)

FC030A  0000            End of table marker.

        ; Table used to initialize the exec's library node.

FC030C  09              Type     = NT_LIBRARY.
FC030D  00              Priority = 0.
FC030E  00FC00A8        Name     = pointer to "exec.library".
FC0312  06              Flags    = LIBF_CHANGED | LIBF_SUMUSED.
FC0313  00              Pad.
FC0314  0000            NegSize    (not set yet).
FC0316  024C            PosSize.
FC0318  0021            Version.
FC031A  00C0            Revision.
FC031C  00FC0018        IdString = pointer to "exec ..."
FC0320  00000000        Checksum   (not set yet).
FC0324  0001            OpenCnt  = 1.

        ; Names to use in the system free-memory lists.

FC0326  "Chip Memory", 00
FC0332  "Fast Memory", 00


FC033E  lea       FC2FB4(PC),A0     Get address of task crash routine.
FC0342  move.l    A0,$0130(A6)      Install in default trap code.
FC0346  move.l    A0,$0134(A6)      Install in default exception code.

FC034A  move.l    #$FC1CEC,$0138(A6)    Set the default task exit address.
FC0352  move.l    #$00FFFF,$013C(A6)    Preallocate the lower 16 signals.
FC035A  move.w    #$8000,$0140(A6)      Preallocate TRAP #15 (for use
                                        in ROM-Wack breakpoints).

FC0360  lea       8(A6),A1          Initialize the exec.library node
FC0364  lea       FC030C(PC),A0     up to and including the OpenCnt
FC0368  moveq     #$0C,D0           field, from the table above.
FC036A  move.w    (A0)+,(A1)+
FC036C  dbra      D0,FC036A(PC)

FC0370  move.l    A6,A0             Make the library jump vector, using the
FC0372  lea       FC1A40(PC),A1     table at $FC1A40, and the MakeFunctions()
FC0376  move.l    A1,A2             routine.  Setting A2 to the table address
FC0378  bsr       FC1576            signals that the table is relative.
FC037C  move.w    D0,$10(A6)        Install library negative size.

FC0380  move.l    A4,D0             See if we have expansion memory.
FC0382  beq.s     FC03A8            Branch past this if we don't.

        ; Add expansion memory at $C00000 to the free memory lists.

FC0384  lea       $024C(A6),A0      First free location = ExecBase + $024C.
FC0388  lea       FC0332(PC),A1     Name = "Fast Memory".
FC038C  moveq     #0,D2             Put in memory list at priority 0.
FC038E  move.w    #5,D1             Attributes = MEMF_FAST | MEMF_PUBLIC.
FC0392  move.l    A4,D0             Get end address of expansion memory.
FC0394  sub.l     A0,D0             Subtract address of first free location.
FC0396  sub.l     #$001800,D0       Subtract system stack size.
FC039C  bsr       FC19EA            Build free list and add it to system.

FC03A0  lea       $0400,A0          Free chip memory starts at $0400.
FC03A4  moveq     #0,D0             Space for stack already reserved.
FC03A6  bra.s     FC03B2

        ; Add chip memory to free memory lists.  Enter here if there is
        ; no expansion memory, and ExecBase therefore resides at the bottom
        ; of chip memory.

        ; Note how chip memory is added to the system list at a lower
        ; priority than expansion memory.  This causes it to be allocated
        ; only when specifically requested or when expansion memory is full.

FC03A8  lea       $024C(A6),A0      Free chip memory is at ExecBase + $024C.
FC03AC  move.l    #$FFFFE800,D0     Reserve 6K for system stack.

        ; Enter here if we do have expansion memory, with D0 and A0 set
        ; up as above.

FC03B2  move.w    #3,D1             Attributes = MEMF_CHIP | MEMF_PUBLIC.
FC03B6  move.l    A0,A2
FC03B8  lea       FC0326(PC),A1     Name = "Chip Memory".
FC03BC  moveq     #-$0A,D2          Priority = -10.
FC03BE  add.l     A3,D0             Get end address of free chip memory.
FC03C0  sub.l     A0,D0             Subtract address of first free location.
FC03C2  bsr       FC19EA            Build free list and add it to system.

FC03C6  move.l    A6,A1             Get ExecBase.
FC03C8  bsr       FC140C            Add the exec to the system library list.

        ; Set the exception vector table up for actual system operation.
        ; Up to this point, any interrupt or exception would have caused
        ; the screen to turn yellow and the computer to reset.

        ; The format of the data table used here is explained in comments
        ; at the front of the data table.

FC03CC  lea       FC0778(PC),A0     Point to data table.
FC03D0  move.l    A0,A1             Set up base address for the offsets.
FC03D2  move.w    #8,A2             Point to exception vector #2.
FC03D6  bra.s     FC03DE            Enter the loop at the bottom.

FC03D8  lea       0(A0,D0.w),A3     Convert table entry to absolute address.
FC03DC  move.l    A3,(A2)+          Store the handler address in the EVT.
FC03DE  move.w    (A1)+,D0          Get the next data table entry.
FC03E0  bne.s     FC03D8            Loop until end of table reached.

FC03E2  move.w    $0128(A6),D0      See if we are running on a 68010/020.
FC03E6  btst      #0,D0
FC03EA  beq.s     FC041E            Skip the following if not.

        ; Special initialization for machines using a 68010/020.

FC03EC  lea       FC087C(PC),A0     Point at 68010/020 bus error handler.
FC03F0  move.w    #8,A1
FC03F4  move.l    A0,(A1)+          Fix the bus error vector.
FC03F6  move.l    A0,(A1)+          Fix the address error vector.

FC03F8  move.l    #$FC08BA,-$1C(A6)     Use a different Supervisor() routine.

        ; Fix GetCC() for 68010/020 processors.

        ; We simply load the instruction sequence "MOVE.W CCR,D0 / RTS" into
        ; the place where the library jump vector to GetCC() normally is.

FC0400  move.l    #$42C04E75,-$0210(A6)

        ; Check if we have a 68881 numeric coprocessor, and if so, fix up
        ; some more vectors.  This needs to be done since we also need to
        ; save the 68881's context when we switch tasks.

FC0408  btst      #4,D0                 Do we have a 68881?  If so,
FC040C  beq.s     FC041E
FC040E  move.l    #$FC108A,-$34(A6)     Use a different Switch() function.
FC0416  move.l    #$FC10E8,-$3A(A6)     Use a different Dispatch() funciton.

        ; Regular 68000's continue here.

FC041E  bsr       FC125C            Initialize the exec interrupt handlers.

FC0422  lea       DFF000,A0         Point to the custom chips.
FC0428  move.w    #$8200,$96(A0)    Enable all DMA.
FC042E  move.w    #$C000,$9A(A0)    Enable the interrupt system.
FC0434  move.w    #$FFFF,$0126(A6)  Set the interrupt disable level to -1.

FC043A  bsr       FC22FA            Initialize ROM-Wack.

FC043E  moveq     #0,D1             Checksum the static part of the ExecBase
FC0440  lea       $22(A6),A0        data structure.
FC0444  move.w    #$16,D0           This is used after a reset to see if
FC0448  add.w     (A0)+,D1          the data structure has been clobbered.
FC044A  dbra      D0,FC0448(PC)
FC044E  not.w     D1
FC0450  move.w    D1,$52(A6)        Store the checksum.

        ; Now we are going to manufacture the very first task.
        ; We use AllocEntry() to obtain a block of memory.  This is then
        ; used to hold the MemList from AllocEntry(), the task's stack,
        ; and the task descriptor.

FC0454  lea       FC04CC(PC),A0     Point to the MemList.
FC0458  bsr       FC191E            AllocEntry()
FC045C  move.l    D0,A2             Get the address of the MemList.

        ; It's assumed here that the allocated memory follows directly
        ; after the MemList.  A safe assumption, since we still have
        ; unfragmented memory.  We now create a task descriptor at the
        ; top of the allocated memory.  The stack pointer for the task
        ; is initialized below the task descriptor.

FC045E  lea       $1010(A2),A0      Point near the top of the memory block.
FC0462  lea       8(A0),A1          Point to the future task descriptor.
FC0466  add.l     #$000010,D0
FC046C  move.l    D0,$3A(A1)        Store stack lower bound.
FC0470  move.l    A0,$3E(A1)        Store stack upper bound.
FC0474  move.l    A0,$36(A1)        Set the initial stack pointer image.
FC0478  move      A0,USP            Set the stack pointer itself.
FC047A  clr.b     9(A1)             Priority = 0.
FC047E  move.b    1,8(A1)           Node type = NT_TASK.
FC0484  move.l    #$FC00A8,$0A(A1)  Task name = "exec.library".

        ; We initialize the task's memory list to empty, then enqueue
        ; the MemList holding all this memory there.  This means that
        ; when the task dies, the memory will automatically be deallocated.

FC048C  lea       $4A(A1),A0        Point to the task's memory list.
FC0490  move.l    A0,(A0)           Initialize it to empty.
FC0492  addq.l    #4,(A0)
FC0494  clr.l     4(A0)
FC0498  move.l    A0,8(A0)
FC049C  exg       A1,A2             Enqueue the MemList from AllocEntry()
FC049E  bsr       FC15D8            on the task's memory list.
FC04A2  exg       A1,A2             Get the task address back.

        ; Make this the current task, and make it ready to run.
        ; initialPC and finalPC are both initialized as zero, but no
        ; harm results, since the task can't start running yet.

FC04A4  move.l    A1,$0114(A6)      Make this the current task.
FC04A8  sub.l     A2,A2             Clear A2.
FC04AA  move.l    A2,A3             Clear A3.
FC04AC  bsr       FC1C48            AddTask()
FC04B0  move.l    $0114(A6),A1      Get the pointer to the task again.
FC04B4  move.b    #2,$0F(A1)        Make the task state TS_RUN.
FC04BA  bsr       FC1600            Unlink it from the TaskReady queue.

        ; A historic moment:  We turn the supervisor mode flag off.
        ; Starting right now, we are running as a task named "exec.library",
        ; and the multitasking system is operational.

FC04BE  and.w     #0,SR             Turn the supervisor bit off.
FC04C2  addq.b    #1,$0127(A6)      Forbid()
FC04C6  jsr       -$8A(A6)          Permit()
FC04CA  bra.s     FC0500


       ; The MemList used to allocate memory for the initial task.

FC04CC 00000000 00000000 00000000 0000    A dummy list node.

FC04DA 0001                               1 block of memory desired.
FC04DC 00010001                           MEMF_PUBLIC | MEMF_CLEAR
FC04E0 00001064                           1124 bytes.


       ; Table of areas to look for RomTags in.  I don't know why the
       ; FC0000 - 1000000 area is covered twice.  The F00000 to F80000
       ; area appears to be an alternate or additional place to put ROMs.

FC04E4 00FC0000 01000000
FC04EC 00FC0000 01000000
FC04F4 00F00000 00F80000

FC04FC FFFFFFFF                           End of list marker.


        ; Scan for RomTags, process the KickMemPtr and KickTagPtr
        ; variables, and build a table of all the resident modules found.
        ; The address of the table of resident modules is stored in
        ; the ExecBase data structure.

FC0500  lea       FC04E4(PC),A0     Point to table of ROM address spaces.
FC0504  bsr       FC0900            Scan for RomTags, etc.
FC0508  move.l    D0,$012C(A6)      Store the result in ExecBase->ResModules.

FC050C  bclr      #1,BFE001         Set the power light to bright.

        ; Handle the "cool start" capture vector.  Note that if we decided
        ; (much) earlier that ExecBase had been clobbered, it will have
        ; been rebuilt from scratch, and the cool start capture vector
        ; will be zero.  Thus, we don't have to verify it further.

FC0514  move.l    $2E(A6),D0        Get the "cool start" capture vector.
FC0518  beq.s     FC051E            Branch past the following if zero.
FC051A  move.l    D0,A0
FC051C  jsr       (A0)              Call the "cool start" capture code.

        ; Another historic moment.  We call InitCode() to initialize the
        ; resident modules.  This is where all the other stuff in the ROMs,
        ; stuff in RAM which survived the reboot, etc. comes online.  We
        ; indicate that all those modules with the RTF_COLDSTART flag set
        ; should be initialized now.

FC051E  moveq     #1,D0             RTF_COLDSTART flag must be set.
FC0520  moveq     #0,D1             Minimum version is 0 (any will do).
FC0522  bsr       FC0AF0            InitCode().

        ; Yet another capture vector, this time the "WarmCapture" one.

FC0526  move.l    $32(A6),D0        Check the "WarmCapture" vector.
FC052A  beq.s     FC0530            Branch past this if zero.
FC052C  move.l    D0,A0
FC052E  jsr       (A0)              Call the warm start capture code.

        ; I assume that when the DOS came online, it took over.  This
        ; task looks like it's heading into a dead end.

        ; Clear all the CPU registers except for ExecBase and the stack
        ; pointer.

FC0530  moveq     #$0D,D0             Push 14 longwords of zero on
FC0532  clr.l     -(SP)               the stack.
FC0534  dbra      D0,FC0532(PC)
FC0538  movem.l   (SP)+,D0-D7/A0-A5   Read them off again into the registers.

        ; This is the end of the road.

                                    Do forever
FC053C  jsr       -$72(A6)            Debug()
FC0540  move.l    4,A6                Get ExecBase.
FC0544  bra.s     FC053C            End


        ; Determine CPU type and whether FPP is present.
        ; ----------------------------------------------

        ; We need to know whether a non-68000 CPU is present for two
        ; reasons:  First, on the 68000, at least one instruction
        ; (MOVE.W SR,<ea>) is available in user mode, whereas on the
        ; newer CPU's, it is privileged.  Second, on the newer CPU's,
        ; when an exception occurs, more information is saved on the
        ; stack, and in the case of a bus error, the CPU's entire state
        ; is dumped there so that virtual memory computers (big UNIX
        ; boxes for example) can recover from page faults.

        ; Note that the 68020 can do everything the 68010 can, and thus,
        ; if a 68020 is detected, both the AFB_68010 and the AFB_68020
        ; flags will be set.

        ; We need to know whether there's an FPP present since, for task
        ; switches, we want to save the FPP registers on the stack as
        ; as the CPU registers, so each task can think it has the FPP
        ; all to itself.

FC0546  movem.l   A2/A3,-(SP)

        ; We are going to try 68010/020 and 68881 instructions.  These will
        ; cause error exceptions if the respective parts aren't present, so
        ; we set up to trap these.

FC054A  move.l    $10,A0            Save "Illegal Instruction" error vector.
FC054E  move.l    $2C,A2            Save "1111 Opcode" error vector.
FC0552  lea       FC0582(PC),A1     Point to temporary exception handler.
FC0556  move.l    A1,$10            Install this address in both vectors.
FC055A  move.l    A1,$2C
FC055E  move.l    SP,A1             Save the stack pointer.

        ; Initialize the flags to zero (D0), and point to address zero (D1).
        ; Then we try to set the 68010 Vector Base Register, which determines
        ; where the exception vector table is.  In the 68000, this is hard
        ; wired at zero.  If the 68010 is present, we set it to zero.

FC0560  moveq     #0,D0
FC0562  moveq     #0,D1
FC0564  movec     D1,VBR            Set Vector Base Register to 0.

        ; If we're still here, the CPU is at least a 68010.  We thus set
        ; the AFB_68010 flag.  Then we try to access a 68020-specific
        ; feature, namely, we try to enable its instruction cache.

FC0568  bset      #0,D0             Set AFB_68010 flag.
FC056C  moveq     #1,D1
FC056E  movec     D1,CACR           Try enabling the 68020 cache.

        ; If we're still here, we have a 68020, and so we set the AFB_68020
        ; flag.  Then we see if we also have a 68881 FPP, by trying to
        ; access one of its registers.  Note that this will not cause an
        ; exception if no FPP is present.

FC0572  bset      #1,D0             Set AFB_68020 flag.
FC0576  fmove.l   FPCR,D1           Try reading a 68881 register.
FC057A  tst.l     D1                Did it work?
FC057C  bne.s     FC0582
FC057E  bset      #4,D0             If so, set the AFB_68881 flag.

        ; We continue here either from above, or, on plain Amigas, by
        ; an error exception from one of the foreign instructions above.
        ; D0 contains all the flags which have been set along the way.
        ; We restore the two changed entries in the EVT and the stack
        ; pointer, then exit.

FC0582  move.l    A1,SP             Restore the stack pointer.
FC0584  move.l    A0,$10            Restore the exception vectors.
FC0588  move.l    A2,$2C
FC058C  movem.l   (SP)+,A2/A3
FC0590  rts       


        ; Chip Memory Checking Routine
        ; ----------------------------

        ; This routine checks for the presence of memory.  It is used at
        ; startup to determine how much chip memory is available.  Note
        ; that it can't be used to check for memory at $C00000, and a
        ; special routine is provided to do this further on.

        ; On entry, A0 is the lower bound of the area to check, and A1 is
        ; the high bound.  Memory is checked in 4K blocks.

FC0592  moveq     #0,D1
FC0594  move.l    D1,(A0)               Write a zero to the first location.
FC0596  move.l    A0,A2                 Save the first location.
FC0598  move.l    #$F2D4B698,D0         Use this as a signature value.

        ; Main loop:  We enter here to check each 4K block.

FC059E  lea       $1000(A0),A0          Increment current location by 4K.
FC05A2  cmp.l     A0,A1                 See if upper bound reached.
FC05A4  bls.s     FC05B0                If so, exit from the loop.
FC05A6  move.l    D0,(A0)               Write the signature into memory.

        ; Longword 0 of the block being checked was initially cleared to
        ; zero.  If it is now no longer zero, we have "wrapped around",
        ; i.e. due to incomplete address decoding, we have written the
        ; signature value at the beginning of the block.  When this
        ; occurs, we have reached the end of memory, even though the
        ; signature value would read back correctly.

FC05A8  tst.l     (A2)                  Check location 0.
FC05AA  bne.s     FC05B0                Exit if signature appears there.
FC05AC  cmp.l     (A0),D0               See if signature can be read back.
FC05AE  beq.s     FC059E                If successful, go check more memory.

        ; Done, return the end address of memory to the user.  Return
        ; via indirect jump through A5 since we don't have a stack yet.

FC05B0  move.l    A0,A3
FC05B2  jmp       (A5)


        ; Error System Reset Routine
        ; --------------------------

        ; This is the routine which blinks the power light, then resets
        ; the computer.  It is called from the startup code if a failure
        ; of any sort is detected.  The colour of the screen indicates
        ; the type of failure.

        ; This is the exception entry point.  All vectors in the
        ; Exception Vector Table point here while the ROM kernel is
        ; initializing itself.  A yellow screen means an unexpected
        ; exception has occurred.

FC05B4  move.w    #$0CC0,D0             Colour number for yellow.

        ; This is the non-exception entry point.  From here on down it's
        ; a general purpose routine which can be entered with a coulour
        ; number in D0.

FC05B8  lea       DFF000,A4             Point to the custom chips.
FC05BE  move.w    #$0200,$0100(A4)      Set BPLCON0 for a blank screen.
FC05C4  move.w    #0,$0110(A4)          Set bitplane 0 data to zeros.
FC05CA  move.w    D0,$0180(A4)          Set background colour to yellow.

FC05CE  moveq     #$0A,D1               For D1 = 1 to 10 do
FC05D0  moveq     #-1,D0                  Set delay to 1 time unit.
FC05D2  bset      #1,BFE001               Make power light dim.
FC05DA  dbra      D0,FC05D2(PC)           Delay.
FC05DE  lsr.w     #1,D0                   Set delay to 0.5 time unit.
FC05E0  bclr      #1,BFE001               Make power light bright.
FC05E8  dbra      D0,FC05E0(PC)           Delay.
FC05EC  dbra      D1,FC05D2(PC)         Endfor

        ; Note:  The "boot" and "ig" commands from ROM-Wack jump here.

FC05F0  move.l    #$020000,D0           Delay some more.
FC05F6  subq.l    #1,D0
FC05F8  bgt.s     FC05F6

FC05FA  reset                           Reset everything external to the CPU.


        ; Get the initial PC from the ROM (now mapped at zero due to the
        ; reset instruction) and start over.

FC05FC  move.l    4,A0
FC0600  jmp       (A0)


        ; Memory Clear Subroutine
        ; -----------------------

        ; This subroutine clears a block of memory.  The start address is
        ; in A0, the end address is in D0.  Since we may not have a stack,
        ; the return address is provided in A5.

FC0602  moveq     #0,D2                 Value to store in memory.
FC0604  sub.l     A0,D0                 Compute number of bytes to clear.
FC0606  lsr.l     #2,D0                 Divide by 4 (number of longwords).
FC0608  move.l    D0,D1                 Put the low-order 16 bits in D0,
FC060A  swap      D1                    and the high-order ones in D1, and
FC060C  bra.s     FC0610                start at the bottom (for dbra's).
FC060E  move.l    D2,(A0)+              Clear a longword.
FC0610  dbra      D0,FC060E(PC)         Loop until current 256K block done.
FC0614  dbra      D1,FC060E(PC)         Loop until everything done.
FC0618  jmp       (A5)                  Return to caller.


        ; $C00000 Expansion RAM Checker
        ; -----------------------------

        ; The following routine checks for the presence of memory
        ; in the $C00000 - $DC0000 area.  This is a nontrivial exercise,
        ; since if there is no memory there, we see images of the custom
        ; chip registers there instead, due to incomplete address decoding.
        ;
        ; This took a while to figure out, so I'm commenting it
        ; very heavily for my own satisfaction.

        ; Register A4 holds the end address of the block where we know
        ; RAM to reside.  At first, we initialize this to the start address.
        ; Then, each time through the loop, we copy A4 to a temporary
        ; register, which we increment by 256K.

FC061A  move.l    A0,A4                 Copy start address into A4.
FC061C  move.l    A4,A2                 Copy A4 into temporary register.
FC061E  add.l     #$040000,A2           Add 256K to temporary register.

        ; Now we write to an address $0F66 bytes less than the temporary
        ; register.  If there is RAM here, this will write into it near
        ; the top of the 256K block.  If there isn't, this will write to
        ; the INTENA register and disable all interrupts.

FC0624  move.w    #$3FFF,-$0F66(A2)     Write to RAM or INTENA.

        ; Now we read an address $0FE4 bytes below the temporary address.
        ; If there is memory here, this will read it.  Otherwise, it will
        ; read the INTENAR register.  If we find a non-zero value, it must
        ; be memory, since all bits in INTENAR were reset above.  Otherwise,
        ; it could be either (memory could happen to contain zero).

FC062A  tst.w     -$0FE4(A2)            Read RAM or INTENAR.
FC062E  bne.s     FC063E                If not zero, we've found memory.

        ; We got a zero.  Make sure this isn't INTENAR by causing bits
        ; to be set in it.  We set all of them except for the master
        ; interrupt enable.  Again, if there's RAM here, this won't do
        ; anything to INTENAR, and we'll continue to see a zero.

FC0630  move.w    #$BFFF,-$0F66(A2)     Write to RAM or INTENA.

        ; Read the same location as before.  If this returns anything but
        ; $3FFF, it's fine.  $3FFF means we're seeing INTENAR.  If it's
        ; still zero, it's RAM.  Anything else would be a fatal error, but
        ; that isn't checked for.

FC0636  cmp.w     #$3FFF,-$0FE4(A2)     Read RAM or INTENAR.
FC063C  beq.s     FC0644                Exit from loop if INTENAR seen.

        ; Now we bump up A4 by copying the temporary register back.  This
        ; means we have found a valid 256K block.  We then go on looking
        ; until we've reached the upper limit of the address space to check.

FC063E  move.l    A2,A4                 Update A4 (means memory was found).
FC0640  cmp.l     A4,A1                 Compare to upper limit.
FC0642  bhi.s     FC061C                Keep looking if not reached.

        ; Continue here when we've reached the end of the space to check,
        ; or finally seen an image of the INTENAR register.  We return the
        ; end address of the detected RAM in A4, or zero A4 if no RAM
        ; was found.

FC0644  move.w    #$7FFF,-$0F66(A2)     Disable all interrupts.
FC064A  cmp.l     A0,A4                 Was A4 ever updated?
FC064C  bne.s     FC0650                If so, return it.
FC064E  sub.l     A4,A4                 Zero A4 (indicates no memory).
FC0650  jmp       (A5)                  Return to caller.

FC0652  0000                            Padding

---------------------------------------------------------------------------
  AddDevice( device )
             A1
---------------------------------------------------------------------------

FC0654  lea       $015E(A6),A0      Point to the system device list.
FC0658  bsr       FC1682            Add the device to the list.
FC065C  jsr       -$01AA(A6)        Update the device's vector checksum.
FC0660  rts       


---------------------------------------------------------------------------
  RemDevice( device )
             A1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this.

FC0662  bra       FC141A            Just go to RemLibrary().


---------------------------------------------------------------------------
  error = OpenDevice( devName, unitNumber, ioRequest, flags )
  D0                  A0       D0          A1         D1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this, presumably so it can pull devices off
        ; disk if they aren't already in the device list.

FC0666  move.l    A2,-(SP)
FC0668  move.l    A1,A2             Point to the ioRequest.
FC066A  clr.b     $1F(A1)           Clear the io_Error field in it.
FC066E  movem.l   D0/D1,-(SP)
FC0672  move.l    A0,A1
FC0674  lea       $015E(A6),A0      Point to the system device list.
FC0678  addq.b    #1,$0127(A6)      Forbid()
FC067C  bsr       FC165A            FindName()
FC0680  move.l    D0,A0             Get the pointer to the device.
FC0682  movem.l   (SP)+,D0/D1
FC0686  move.l    A0,$14(A2)        Store it in the ioRequest.
FC068A  beq.s     FC06AC            Return -1 if device not found.
FC068C  clr.l     $18(A2)           Clear the io_Unit pointer.
FC0690  move.l    A2,A1
FC0692  move.l    A6,-(SP)          Save ExecBase.
FC0694  move.l    A0,A6             Point A6 to the device's base address.
FC0696  jsr       -6(A6)            Call the device's Open() function.
FC069A  move.l    (SP)+,A6          Restore ExecBase.
FC069C  move.b    $1F(A2),D0        Get the io_Error (from the Open() call).
FC06A0  ext.w     D0                Extend to a longword for return to
FC06A2  ext.l     D0                the caller.
FC06A4  jsr       -$8A(A6)          Permit()
FC06A8  move.l    (SP)+,A2
FC06AA  rts       

        ; Continue here if the device was not found.

FC06AC  moveq     #-1,D0            Set the return value to -1.
FC06AE  move.b    D0,$1F(A2)        Set the io_Error field to -1.
FC06B2  bra.s     FC06A4


---------------------------------------------------------------------------
  CloseDevice( ioRequest )
               A1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this.

FC06B4  addq.b    #1,$0127(A6)      Forbid()
FC06B8  move.l    A6,-(SP)          Save ExecBase.
FC06BA  move.l    $14(A1),A6        Get the pointer to the device node.
FC06BE  jsr       -$0C(A6)          Call the device's Close() function.
FC06C2  move.l    (SP)+,A6          Restore ExecBase.
FC06C4  jsr       -$8A(A6)          Permit()
FC06C8  rts       


---------------------------------------------------------------------------
  SendIO( ioRequest )
          A1
---------------------------------------------------------------------------

        ; The command is sent to device with the "quick I/O" bit not set.
        ; This means the device must always respond by sending the
        ; I/O request back as a reply message when done.

FC06CA  clr.b     $1E(A1)           Clear the "quick I/O" bit.
FC06CE  move.l    A6,-(SP)          Save ExecBase.
FC06D0  move.l    $14(A1),A6        Get pointer to device node.
FC06D4  jsr       -$1E(A6)          Call the device's "BeginIO" entry point.
FC06D8  move.l    (SP)+,A6          Restore ExecBase.
FC06DA  rts       


---------------------------------------------------------------------------
  error = DoIO( ioRequest )
  D0            A1
---------------------------------------------------------------------------

        ; The command is sent to the device with the "quick I/O" bit set.
        ; This allows the device to decide whether to process the request
        ; synchronously or asynchronously.

FC06DC  move.l    A1,-(SP)          Save ioRequest pointer for later.
FC06DE  move.b    #1,$1E(A1)        Set the "quick I/O" bit.
FC06E4  move.l    A6,-(SP)          Save ExecBase.
FC06E6  move.l    $14(A1),A6        Get pointer to device node.
FC06EA  jsr       -$1E(A6)          Call the device's "BeginIO" entry point.
FC06EE  move.l    (SP)+,A6          Restore ExecBase.
FC06F0  move.l    (SP)+,A1          Get ioRequest pointer back.

        ; Now fall through to WaitIO.


---------------------------------------------------------------------------
  error = WaitIO( ioRequest )
  D0              A1
---------------------------------------------------------------------------

        ; If the "quick I/O" bit is set, then the call to the device
        ; in BeginIO() finished the I/O operation synchronously, and
        ; we can return to the caller.  Otherwise, we must wait for
        ; the reply message from the device.

FC06F2  btst      #0,$1E(A1)        Check the "quick I/O" bit.
FC06F8  bne.s     FC0744            If still set, the I/O is complete.

        ; "quick I/O" bit was not (or no longer) set, so we need to
        ; wait for the reply message from the device.

FC06FA  move.l    A2,-(SP)          Save A2.
FC06FC  move.l    A1,A2             Save pointer to the ioRequest.
FC06FE  move.l    $0E(A2),A0        Get pointer to the reply port.
FC0702  move.b    $0F(A0),D1        Get the reply port's signal bit.
FC0706  moveq     #0,D0
FC0708  bset      D1,D0             Convert to signal mask.

FC070A  move.w    #$4000,DFF09A     Disable()
FC0712  addq.b    #1,$0126(A6)

FC0716  cmp.b     #7,8(A2)          Check if the ioRequest became NT_REPLYMSG
FC071C  beq.s     FC0724
FC071E  jsr       -$013E(A6)        Wait for the signal.
FC0722  bra.s     FC0716            Go back and check the ioRequest again.

FC0724  move.l    A2,A1             Unlink the ioRequest from the reply
FC0726  move.l    (A1),A0           port's message queue.
FC0728  move.l    4(A1),A1
FC072C  move.l    A0,(A1)
FC072E  move.l    A1,4(A0)

FC0732  subq.b    #1,$0126(A6)      Enable()
FC0736  bge.s     FC0740
FC0738  move.w    #$C000,DFF09A

FC0740  move.l    A2,A1             Restore pointer to the ioRequest.
FC0742  move.l    (SP)+,A2          Restore A2.
FC0744  move.b    $1F(A1),D0        Get the error field from the ioRequest.
FC0748  ext.w     D0                Extend to long word.
FC074A  ext.l     D0
FC074C  rts       


---------------------------------------------------------------------------
  result = CheckIO( ioRequest )
  D0                A1
---------------------------------------------------------------------------

FC074E  btst      #0,$1E(A1)        Check the "quick I/O" bit.
FC0754  beq.s     FC075A            If set, request is done, so...
FC0756  move.l    A1,D0             Return address of ioRequest.
FC0758  rts       
FC075A  cmp.b     #7,8(A1)          Check if ioRequest type is NT_REPLYMSG
FC0760  beq.s     FC0766            If so, it is finished.
FC0762  moveq     #0,D0             Return zero.
FC0764  rts       
FC0766  move.l    A1,D0             Return address of ioRequest.
FC0768  rts       


---------------------------------------------------------------------------
  AbortIO( ioRequest )
           A1
---------------------------------------------------------------------------

FC076A  move.l    A6,-(SP)          Save ExecBase.
FC076C  move.l    $14(A1),A6        Get pointer to the device node.
FC0770  jsr       -$24(A6)          Call the device's "AbortIO" entry point.
FC0774  move.l    (SP)+,A6          Restore ExecBase.
FC0776  rts       


        ; Table used to set up the exception vector table.

        ; Each entry is a 16-bit offset from the table's base address
        ; to the address of the exception handler for that exception.
        ; The final longword of zeros marks the end of the table.

        ; The first entry means that the handler for exception number 2
        ; (bus error) is at $FC0778 + $64.  The next entry is for exception
        ; number 3, and so on through to the end of the TRAP instruction
        ; vectors.

FC0778 00640066 0068006A 006C006E 015A0072
FC0788 00740076 0078007A 007C007E 00800080
FC0798 00800080 00800080 00800080 008004DA
FC07A8 052E0560 05B80646 068C06D2 00820084
FC07B8 00860088 008A008C 008E0090 00920094
FC07C8 00960098 009A009C 009E00A0

FC07D4 0000                         End of table marker.

FC07D6 0000                         Padding.


        ; Exception entry points.  The indicated entries in the Exception
        ; Vector Table are set to point here.

        ; The BSR instructions are used so that the stacked return address
        ; from the BSR can be used to find out which exception occurred.

FC07D8  bsr.s     FC0828
FC07DA  bsr.s     FC0828
FC07DC  bsr.s     FC083A            Bus error.
FC07DE  bsr.s     FC083A            Address error.
FC07E0  bsr.s     FC0850            Illegal instruction.
FC07E2  bsr.s     FC0850            Divide by zero.
FC07E4  bsr.s     FC0850            CHK instruction.
FC07E6  bsr.s     FC0850            TRAPV instruction.
FC07E8  bsr.s     FC0850
FC07EA  bsr.s     FC0850            Trace mode.
FC07EC  bsr.s     FC0850            "1010" opcode.
FC07EE  bsr.s     FC0850            "1111" opcode.
FC07F0  bsr.s     FC0850            Reserved vector #12.
FC07F2  bsr.s     FC0850            Reserved vector #13.
FC07F4  bsr.s     FC0828            Reserved vector #14.
FC07F6  bsr.s     FC0828            Reserved vector #15.
FC07F8  bra.s     FC081A            Reserved vectors #16-23, spurious int.
FC07FA  bsr.s     FC0866            TRAP #0
FC07FC  bsr.s     FC0866            TRAP #1
FC07FE  bsr.s     FC0866            TRAP #2
FC0800  bsr.s     FC0866            TRAP #3
FC0802  bsr.s     FC0866            TRAP #4
FC0804  bsr.s     FC0866            TRAP #5
FC0806  bsr.s     FC0866            TRAP #6
FC0808  bsr.s     FC0866            TRAP #7
FC080A  bsr.s     FC0866            TRAP #8
FC080C  bsr.s     FC0866            TRAP #9
FC080E  bsr.s     FC0866            TRAP #10
FC0810  bsr.s     FC0866            TRAP #11
FC0812  bsr.s     FC0866            TRAP #12
FC0814  bsr.s     FC0866            TRAP #13
FC0816  bsr.s     FC0866            TRAP #14
FC0818  bsr.s     FC0866            TRAP #15

        ; Handler for reserved exceptions #16-23 and spurious interrupts.
        ; These are dead ends (click for Guru).

FC081A  or.w      #$0700,SR         Disable all maskable interrupts.
FC081E  move.l    #$8100000A,-(SP)  Alert number (fatal).
FC0824  bra       FC2FB4            Freeze the task.

        ; Another exception handler.  This one is a dead end also.

FC0828  or.w      #$0700,SR         Disable all maskable interrupts.
FC082C  sub.l     #$FC07DA,(SP)
FC0832  lsr       2(SP)             Make alert number.
FC0836  bra       FC2FB4            Freeze the task.

        ; Handler for bus and address errors (long stack frame).
        ; These two can be caught by the task if set up to do so.

FC083A  sub.l     #$FC07DA,(SP)     Use the return address on the stack
FC0840  lsr       2(SP)             to compute the exception number.
FC0844  btst      #5,$0C(SP)        See if error occurred in supervisor mode.
FC084A  beq.s     FC0894            If not, go to task's trap routine.
FC084C  bra       FC2FB4            Freeze the task.

        ; Handler for miscellaneous other errors.
        ; These can be caught by the task.

FC0850  sub.l     #$FC07DA,(SP)     Use the return address on the stack
FC0856  lsr       2(SP)             to compute the exception number.
FC085A  btst      #5,4(SP)          See if error occurred in supervisor mode.
FC0860  beq.s     FC0894            If not, go to task's trap routine.
FC0862  bra       FC2FB4            Guru time if in supervisor mode.

        ; Handler for TRAP instructions.

FC0866  sub.l     #$FC07BC,(SP)     Use the return address on the stack
FC086C  lsr       2(SP)             to compute the exception number.
FC0870  btst      #5,4(SP)          See if error occurred in supervisor mode.
FC0876  bne       FC2FB4            Guru time if in supervisor mode.
FC087A  bra.s     FC0894            Else go to task specific trap routine.

        ; Bus error handler for 68010/020 processors.  These processors
        ; produce a more detailed stack frame when they hit a bus error
        ; (for use in virtual memory systems).  The bus and address
        ; error exception vectors are set to point here at system startup
        ; if such a processor is being used.

FC087C  clr.l     -(SP)             Push a zero from the stack.
FC087E  move.w    $0A(SP),2(SP)     Read the exception number.
FC0884  and.w     #$0FFF,2(SP)      Convert it to a format compatible
FC088A  lsr       2(SP)             with the numbering scheme used
FC088E  lsr       2(SP)             elsewhere.
FC0892  bra.s     FC085A            Process the exception normally.

        ; We get here if various exceptions occurred in user mode.
        ; This looks up an exception handler address in the current task's
        ; descriptor, and jumps there.  This allows each task to specify
        ; what is to happen if it causes an exception or executes a
        ; TRAP instruction.

        ; The task can clean up the stack and continue running if it
        ; wants to.  All its registers are preserved.

FC0894  movem.l   A0/A1,-(SP)       Reserve 4 words on stack and save A0.
FC0898  move.l    4,A0              Get ExecBase
FC089C  move.l    $0114(A0),A0      Get the current task pointer.
FC08A0  move.l    $32(A0),4(SP)     Get current task's tc_TrapCode address
                                    and put it on the stack for the RTS.
FC08A6  move.l    (SP)+,A0          Restore A0.
FC08A8  rts       


---------------------------------------------------------------------------
  Supervisor( code_to_execute )
              A5
---------------------------------------------------------------------------

        ; This routine is used to run things with the CPU in supervisor
        ; mode.  The address of the code to execute once we're in supervisor
        ; mode is passed in A5.

        ; First, we tamper with the status register (attempt to set the
        ; supervisor mode bit).  If successful, we are already in supervisor
        ; mode.  If not, there will be a privilege violation, handled by
        ; the exception handler below.

FC08AA  or.w      #$2000,SR         Tamper with the status register.

        ; Are we still here?  If so, we are already in supervisor mode.
        ; Fake an exception by pushing status register and PC on the stack.

FC08AE  pea       FC08B8            Push a fake program counter.
FC08B4  move      SR,-(SP)          Push the status register.
FC08B6  jmp       (A5)              Go execute the caller's code.
FC08B8  rts       

        ; The following is 68010/020 version of the above.  It is used
        ; if the startup code has detected such a processor and pointed
        ; the Supervisor() vector here.

FC08BA  or.w      #$2000,SR         Tamper with the status register.
FC08BE  subq.l    #8,SP             Make room on the stack.
FC08C0  move      SR,(SP)           Store status register.
FC08C2  move.l    #$FC08B8,2(SP)    Store fake program counter.
FC08CA  move.w    #$20,6(SP)        Store 68010/020 stack frame type.
FC08D0  jmp       (A5)              Go execute the caller's code.

        ; Privilege violation exception handler.

        ; First, we find out where the CPU was when it got the privilege
        ; violation.

FC08D2  cmp.l     #$FC08AA,2(SP)    Was it the 68000 Supervisor() function?
FC08DA  beq.s     FC08E6
FC08DC  cmp.l     #$FC08BA,2(SP)    Was it the 68010/020 version?
FC08E4  bne.s     FC08F0
FC08E6  move.l    #$FC08B8,2(SP)    Yes, fix return address, and go
FC08EE  jmp       (A5)              execute the caller's code.

        ; If we get here, it was a real privilege violation, i.e. not one
        ; of the intentionally caused ones above.

FC08F0  or.w      #$0700,SR         Disable all maskable interrupts.
FC08F4  move.l    #$000008,-(SP)    Make alert number.
FC08FA  bra       FC085A            Freeze the current task or guru.


FC08FE  0000                        Padding.



        ; ROMTAG Scanner and "KickMemPtr/KickTagPtr" Processor
        ; ----------------------------------------------------

        ; The routines in this section do two things.  One, they scan a
        ; section of the CPU addressing space for resident modules, each
        ; flagged by a "RomTag".  For an example of what a RomTag looks
        ; like, check out the one at the very beginning of the exec.

        ; The start and end addresses of each piece of CPU address space
        ; to look for RomTags in are given in a table, to which A0 must
        ; point on entry.

        ; A temporary list is built, containing nodes which each point to
        ; a RomTag.  Each resident module has a name, and no two modules
        ; with the same name are allowed.  If there is a conflict, the
        ; one with the higher version number or priority wins and the
        ; other one is discarded.

        ; After the list of RomTags has been compiled, we process something
        ; called the KickMemPtr and the KickTagPtr, found in the ExecBase
        ; structure.  The former points to a chain of MemLists.  The latter
        ; points to an odd type of chain containing pointers to RomTags.
        ; If you really need to know the format of this chain, read the
        ; comments at the appropriate code.

        ; All the MemList structures, and tables of RomTag addresses, pointed
        ; to by these pointers, have a checksum, also stored in ExecBase.
        ; If the checksum we calculate doesn't match that checksum, we
        ; discard all the data (assume it has been damaged in a system crash
        ; before the reboot).

        ; If the checkum matches, then we try to allocate all the pieces
        ; of memory pointed to by the KickMemPtr MemLists.  If this is
        ; successful, we add all the KickTagPtr RomTags to the RomTag list.
        ; Presumably, the KickMemPtr list will indicate where RAM-resident
        ; modules are located, and if we were able to reclaim them before
        ; the memory got allocated for something else, we add them to the
        ; system again after a reboot.

        ; Finally, we process the RomTag list.  This takes the form of
        ; building a table of resident module addresses, terminated with
        ; a zero, in memory allocated for that purpose.  The RomTag list is
        ; deallocated.  Note that the table of module addresses has the
        ; same format as one of the entries in the KickTagPtr list.

        ; Each resident module can have a flag set in its RomTag which
        ; which causes it to be automatically initialized later.


FC0900  movem.l   D3/D4/A2-A4,-(SP)

        ; First, create a temporary list structure to hold the found RomTags
        ; in.  The list header is put on the stack.

FC0904  link      A5,#-$0E          Reserve 14 bytes on the stack (enough
FC0908  move.l    SP,A3             for a list header), and get the address.
FC090A  move.l    A3,(A3)           Clear the list to empty.
FC090C  addq.l    #4,(A3)
FC090E  clr.l     4(A3)
FC0912  move.l    A3,8(A3)

        ; Now process the table of areas to look for RomTags in.  Call the
        ; RomTag scanning routine with the data from each table entry to
        ; find all the RomTags in that section of address space.

FC0916  move.l    A0,A2             Point to the start of the address table.
FC0918  tst.l     (A2)              See if end of table reached.
FC091A  bmi.s     FC0926            Negative value indicates end.
FC091C  move.l    (A2)+,A4          Get the start address and the end address
FC091E  move.l    (A2)+,D4          of an area to look for RomTags in.
FC0920  bsr       FC0948            Scan the  area for RomTags.
FC0924  bra.s     FC0918            Loop until end of list reached.

        ; Now process the "Kick" variables in ExecBase.  These apparently
        ; exist to allow a set of resident modules (such as a RRD) to
        ; survive a system reboot.  If the checksum of all the data tables
        ; is still valid, we claim the memory and add the RomTags to
        ; the list.

FC0926  bsr       FC0A3C            SumKickData()
FC092A  cmp.l     $022A(A6),D0      Verify the checksum against the old one.
FC092E  bne.s     FC093C            Skip the following if not valid.
FC0930  bsr       FC0A94            Try to reallocate all the MemLists.
FC0934  tst.l     D0                Did we get all the memory back?
FC0936  beq.s     FC093C            If not, don't bother with the KickTags.
FC0938  bsr       FC0A14            Process the list of "KickTags".
FC093C  bsr       FC09DE            Build a table of RomTag addresses.
FC0940  unlk      A5                Deallocate the RomTag list header.
FC0942  movem.l   (SP)+,D3/D4/A2-A4
FC0946  rts       


        ; This routine scans an area indicated by A4 (start address) and
        ; D4 (end address) for RomTag structures, and puts any found RomTags
        ; on the RomTag list.  If there is more than one version of any
        ; given RomTag, the newest one wins, the older ones are discarded.

FC0948  movem.l   D2/A5,-(SP)
FC094C  move.w    #$4AFC,D2         Load the RomTag matchword.
FC0950  move.l    D4,D0             Get the end address.
FC0952  sub.l     A4,D0             Subtract the start address.
FC0954  bls.s     FC097E            If less than zero, return.
FC0956  lsr.l     #1,D0             Divide the result by 2 (number of words).
FC0958  subq.l    #1,D0             Decrement by 1 (for DBcc instruction).
FC095A  move.l    D0,D1             Split into two halves (since DBcc can
FC095C  swap      D1                only use 16-bit counters).
FC095E  bra.s     FC0962
FC0960  cmp.w     (A4)+,D2          Look for the RomTag matchword.
FC0962  dbeq      D0,FC0960(PC)
FC0966  dbeq      D1,FC0960(PC)     Loop until entire area scanned.
FC096A  bne.s     FC097E            Exit if end reached.

        ; We've found a RomTag matchword.  A4 points to it.  Check if
        ; this is really a RomTag by verifying the pointer directly
        ; after the matchword.

FC096C  lea       -2(A4),A5         Point to the matchword.
FC0970  cmp.l     (A4),A5           See the longword directly after the
                                    matchword points to it.
FC0972  bne.s     FC0962            Not a valid RomTag if not.

        ; We are pointing to a valid RomTag.  Add it to the RomTag list.

FC0974  bsr       FC0984            Add RomTag to list of found ones.

        ; Each RomTag has in it a pointer (RT_ENDSKIP) which points to
        ; the address where to start looking for the next RomTag, i.e.
        ; the end of whatever code/data is associated with it.

FC0978  move.l    6(A5),A4          Skip to the end of the module.
FC097C  bra.s     FC0950            Start looking for the next one.
FC097E  movem.l   (SP)+,D2/A5
FC0982  rts       


        ; This subroutine adds a RomTag to the list of found RomTags.
        ; If the current RomTag has the same name as a RomTag already in
        ; the list, the older (or if same age, lower priority) version
        ; is discarded.  Memory is allocated to hold each node as needed.

FC0984  move.l    A3,A0             Point to the temporary list on the stack.
FC0986  move.l    $0E(A5),A1        Get the name of this RomTag.
FC098A  bsr       FC165A            FindName()
FC098E  tst.l     D0                Did we find a node with this name?
FC0990  beq.s     FC09B8            If not, go and add the tag to the list.
FC0992  move.l    D0,A1             Point to the node we found.
FC0994  move.l    $0E(A1),A0        Compare the version numbers of the list
FC0998  move.b    $0B(A5),D0        node and the newly found RomTag to find
FC099C  cmp.b     $0B(A0),D0        out which is more recent.
FC09A0  blt.s     FC09DC            Discard current RomTag if older.
FC09A2  bgt.s     FC09AE            Use current one if newer.
FC09A4  move.b    $0D(A5),D0        Version numbers match, so compare
FC09A8  cmp.b     $0D(A0),D0        the priority fields.
FC09AC  blt.s     FC09DC            Discard current RomTag if lower priority.

        ; This RomTag supersedes a previous one, which is already in the
        ; list.  Therefore we discard the one in the list.

FC09AE  move.l    A1,D0             Point to the node in the list.
FC09B0  bsr       FC1600            Unlink it from the list.
FC09B4  move.l    D0,A1             Keep a pointer to the node's memory.
FC09B6  bra.s     FC09C6            Go and make a new node out of it.

        ; We enter here if this RomTag doesn't supersede some other one.
        ; This means we have to allocate some memory for a list node to
        ; store information about it.

FC09B8  moveq     #0,D1             No particular memory requirements.
FC09BA  moveq     #$12,D0           14 bytes.
FC09BC  jsr       -$C6(A6)          Go and allocate the memory.
FC09C0  tst.l     D0                Did we get the memory?
FC09C2  beq.s     FC09DC            If not, skip the following.
FC09C4  move.l    D0,A1             Point to the memory.

        ; We have obtained 14 bytes of memory one way or another, and we
        ; now build a list node and add it to the list of found RomTags.

FC09C6  move.b    $0D(A5),9(A1)     Copy the RomTag's priority.
FC09CC  move.l    $0E(A5),$0A(A1)   Copy the RomTag's name.
FC09D2  move.l    A5,$0E(A1)        Store the RomTag's address.
FC09D6  move.l    A3,A0
FC09D8  bsr       FC1634            And enqueue on the RomTag list.
FC09DC  rts       


        ; RomTag list to resident module table converter.

        ; This routine scans the temporary RomTag list, and builds a table
        ; of resident module addresses from it.  The list itself is
        ; deallocated.

FC09DE  moveq     #4,D0             Start with 1 longword needed.
FC09E0  move.l    (A3),D4           Start at the head node of the list.
FC09E2  move.l    D4,A1             Get pointer to the current node.
FC09E4  move.l    (A1),D4           Get pointer to the next node.
FC09E6  beq.s     FC09EC            End of list reached if zero.
FC09E8  addq.l    #4,D0             4 longwords needed for this node.
FC09EA  bra.s     FC09E2            Scan the rest of the list.
FC09EC  move.l    #$010001,D1       MEMF_PUBLIC | MEMF_CLEAR.
FC09F2  jsr       -$C6(A6)          Allocate memory.
FC09F6  move.l    D0,A2             Get pointer to allocated memory.
FC09F8  move.l    D0,D3             Save a copy of it.
FC09FA  move.l    (A3),D4           Start at the head of the RomTag list.
FC09FC  move.l    D4,A1             Get pointer to current node.
FC09FE  move.l    (A1),D4           Get pointer to next node.
FC0A00  beq.s     FC0A0E            End of list reached if zero.
FC0A02  move.l    $0E(A1),(A2)+     Store pointer to this RomTag.
FC0A06  moveq     #$12,D0           14 bytes.
FC0A08  jsr       -$D2(A6)          FreeMem() the list node.
FC0A0C  bra.s     FC09FC            Go process next list node.
FC0A0E  clr.l     (A2)              Mark end of "KickTag" list.
FC0A10  move.l    D3,D0             Return its base address.
FC0A12  rts       


        ; KickTagPtr processor.

        ; This routine steps through the table(s) of RomTag addresses
        ; pointed to by the KickTagPtr, and adds all the RomTags pointed
        ; to by these addresses to the list of found RomTags.

FC0A14  movem.l   A2/A5,-(SP)
FC0A18  move.l    $0226(A6),D0      Get the KickTagPtr.
FC0A1C  beq.s     FC0A36            Just exit if it is zero.
FC0A1E  move.l    D0,A2             Point to the first tag.
FC0A20  move.l    (A2)+,D0          Read a longword from the current tag.
FC0A22  beq.s     FC0A36            Exit if end of list reached.
FC0A24  bmi.s     FC0A2E            If this is a link, handle it.
FC0A26  move.l    D0,A5             Data must be a pointer to a RomTag.
FC0A28  bsr       FC0984            Add the RomTag to the list.
FC0A2C  bra.s     FC0A20            Continue with current node.
FC0A2E  bclr      #$1F,D0           Strip high bit from pointer to next
FC0A32  move.l    D0,A2             node in the list of "KickTags".
FC0A34  bra.s     FC0A20            Go process the next node.
FC0A36  movem.l   (SP)+,A2/A5
FC0A3A  rts       


---------------------------------------------------------------------------
  SumKickData()
---------------------------------------------------------------------------

        ; This routine computes the KickCheckSum by checksumming all the
        ; tables associated with the KickMemPtr and KickTagPtr pointers.
        ; The result should is the KickCheckSum.

FC0A3C  movem.l   D2-D4,-(SP)
FC0A40  lea       $0222(A6),A0      Point to the KickMemPtr in ExecBase.
FC0A44  movem.l   (A0),D3/D4        Get the KickMemPtr and the KickTagPtr.
FC0A48  clr.l     (A0)+             Clear both to zero in the ExecBase
FC0A4A  clr.l     (A0)+             structure.
FC0A4C  moveq     #-1,D0            Start checksum at -1.
FC0A4E  move.l    D3,D2             Start at the old KickMemPtr.

FC0A50  tst.l     D2                End of list reached?
FC0A52  beq.s     FC0A68            Exit from loop if so.
FC0A54  move.l    D2,A0             Point to current MemList.
FC0A56  move.l    (A0),D2           Get pointer to next MemList.
FC0A58  move.w    $0E(A0),D1        Get the number of entries in the MemList.
FC0A5C  add.w     D1,D1             Double it and add 4 more longwords, to
FC0A5E  add.w     #4,D1             get the size (in longwords) of this list.
FC0A62  bsr       FC0A8E            Checksum the MemList.
FC0A66  bra.s     FC0A50            Go process next MemList, if any.

FC0A68  move.l    D4,D2             Get the old KickTagPtr.
FC0A6A  beq.s     FC0A80            Skip the following if none.
FC0A6C  move.l    D2,A0             Point to the start of the list.
FC0A6E  bra.s     FC0A72            Start checksumming the list.

FC0A70  add.l     D2,D0             Add a longword to the checksum.
FC0A72  move.l    (A0)+,D2          Get first data word at this node.
FC0A74  beq.s     FC0A80            Exit if end of list reached.
FC0A76  bpl.s     FC0A70            If high bit clear, add the data to the
                                    checksum and go on to the next longword.
FC0A78  bclr      #$1F,D2           Clear the high bit.
FC0A7C  move.l    D2,A0             Use result as pointer to next node.
FC0A7E  bra.s     FC0A72            Continue processing the list.
FC0A80  movem.l   D3/D4,$0222(A6)   Put KickMemPtr/KickTagPtr back.
FC0A86  movem.l   (SP)+,D2-D4
FC0A8A  rts       

        ; Subroutine to checksum all the entries in a MemList.

FC0A8C  add.l     (A0)+,D0
FC0A8E  dbra      D1,FC0A8C(PC)
FC0A92  rts       


        ; The KickMemPtr points to a list of MemLists, each pointing to
        ; some number of chunks of memory.  This routine steps through
        ; all the MemLists, allocating all those chunks.  If any can't
        ; be allocated (memory already grabbed by someone else), it returns
        ; zero.  If successful, it returns 1.


FC0A94  move.l    $0222(A6),D4      Start where the KickMemPtr points.
FC0A98  tst.l     D4                End of list reached?
FC0A9A  beq.s     FC0ABC            If so, return 1 and exit.
FC0A9C  move.l    D4,A2             Point to the current MemList.
FC0A9E  move.l    (A2),D4           Get pointer to the next MemList.
FC0AA0  lea       $0E(A2),A2        Advance past the MemList header.
FC0AA4  move.w    (A2)+,D3          Get number of entries in this MemList.
FC0AA6  moveq     #1,D0             Fake "successful allocation" return code.
FC0AA8  bra.s     FC0AB4            Enter the loop.

        ; Allocate all the pieces of memory indicated by this MemList.

FC0AAA  move.l    (A2)+,A1          Get the address of this entry.
FC0AAC  move.l    (A2)+,D0          Get the size of this entry.
FC0AAE  jsr       -$CC(A6)          AllocAbs()
FC0AB2  tst.l     D0                Successful?
FC0AB4  dbeq      D3,FC0AAA(PC)     If so and more entries remain, loop.

        ; When we come out of the loop, if the zero flag is set, we were
        ; unable to reclaim a piece of memory specified in the MemList.
        ; In this case, return zero and exit.  Otherwise, we have allocated
        ; them all and go on to the next MemList.

FC0AB8  beq.s     FC0ABE            If failed, go exit.
FC0ABA  bra.s     FC0A98            Else proces next MemList.
FC0ABC  moveq     #1,D0             Indicate all is OK.
FC0ABE  rts       


---------------------------------------------------------------------------
  resident = FindResident( name )
  D0                       A1
---------------------------------------------------------------------------

FC0AC0  movem.l   A2/A3,-(SP)
FC0AC4  move.l    $012C(A6),A2      Get pointer to the resident module table.
FC0AC8  move.l    A1,A3

        ; Outer loop:  Step through the table(s) of RomTags, looking
        ; for one whose name matches the wanted one.

FC0ACA  move.l    (A2)+,D0          Get a RomTag address from the table.
FC0ACC  beq.s     FC0AEA            Return zero if end of table reached.
FC0ACE  bgt.s     FC0AD8            If table entry is a link then
FC0AD0  bclr      #$1F,D0             clear its high bit.
FC0AD4  move.l    D0,A2               use it as a new table pointer.
FC0AD6  bra.s     FC0ACA              Go to the top of the loop.
FC0AD8  move.l    D0,A1             Endif
FC0ADA  move.l    A3,A0             Get pointer to desired name.
FC0ADC  move.l    $0E(A1),A1        Point to RomTag's name field.

        ; Inner loop:  Compare the wanted name with that in the RomTag.

FC0AE0  cmpm.b    (A0)+,(A1)+       Compare a character.
FC0AE2  bne.s     FC0ACA            Back to top of loop if not equal.
FC0AE4  tst.b     -1(A0)            Did we reach the terminating zeros?
FC0AE8  bne.s     FC0AE0            Compare more characters if not.

        ; Fall through with the module's address in D0.

FC0AEA  movem.l   (SP)+,A2/A3
FC0AEE  rts       


---------------------------------------------------------------------------
  InitCode( startClass, version )
            D0          D1
---------------------------------------------------------------------------

        ; This function initializes modules from the resident module list.

        ; The resident module list is one or more tables of RomTag addresses.
        ; Such tables can be linked together by including the address of the
        ; next table, with the high bit set, as the last address in a table.

        ; We are given a set of required flags in D0, and a minimum
        ; version number in D1.  Modules which have flags not set whose bits
        ; appear in D0, or are of a lower version than D1, will not be
        ; initialized.

FC0AF0  movem.l   D2/D3/A2,-(SP)
FC0AF4  move.l    $012C(A6),A2          Get the ResModules pointer.
FC0AF8  move.b    D0,D2                 Get forbidden flags.
FC0AFA  move.b    D1,D3                 Get cutoff version number.
FC0AFC  move.l    (A2)+,D0              Read a module address from the table.
FC0AFE  beq.s     FC0B22                Exit if end of table reached.
FC0B00  bgt.s     FC0B0A                Is the high bit set?  If so, it's
FC0B02  bclr      #$1F,D0               a pointer to another table, so strip
FC0B06  move.l    D0,A2                 the high bit off, point to the next
FC0B08  bra.s     FC0AFC                table, and process it.

FC0B0A  move.l    D0,A1                 Check the module's version number
FC0B0C  cmp.b     $0B(A1),D3            against the cutoff.
FC0B10  bgt.s     FC0AFC                Ignore module if too low.
FC0B12  move.b    $0A(A1),D0            Get the module's flags.
FC0B16  and.b     D2,D0                 Check against mask.
FC0B18  beq.s     FC0AFC                Ignore it if required ones not set.
FC0B1A  moveq     #0,D1
FC0B1C  jsr       -$66(A6)              InitResident()
FC0B20  bra.s     FC0AFC                Process next resident module.
FC0B22  movem.l   (SP)+,D2/D3/A2
FC0B26  rts       


---------------------------------------------------------------------------
  InitResident( resident, segList )
                A1        D1
---------------------------------------------------------------------------

        ; This initializes a resident module.  The pointer to the module
        ; is in register A1.  If the RT_FLAGS byte at offset 10 from
        ; the module pointer has the RTF_AUTOINIT flag set, we let the
        ; module initialize itself by calling its initialization code.

        ; Otherwise we assume it's a library type of thing, and call
        ; MakeLibrary with a set of parameters taken from the module.
        ; If the MakeLibrary succeeds, we add the module to the appropriate
        ; system list.

FC0B28  btst      #7,$0A(A1)            Check the RTF_AUTOINIT flag.
FC0B2E  bne.s     FC0B3C
FC0B30  move.l    $16(A1),A1            Get the RT_INIT address.
FC0B34  moveq     #0,D0
FC0B36  move.l    D1,A0                 Get the segList pointer.
FC0B38  jsr       (A1)                  Call the module's init code.
FC0B3A  bra.s     FC0B7E

        ; The RTF_AUTOINIT flag was not set, so we MakeLibrary() the
        ; module instead.  Note that the address at RT_INIT points to
        ; a data structure containing parameters for MakeLibrary().

FC0B3C  movem.l   A1/A2,-(SP)
FC0B40  move.l    $16(A1),A1            Get the initialization address.
FC0B44  movem.l   (A1),D0/A0-A2         Get parameters for MakeLibrary.
FC0B48  jsr       -$54(A6)              MakeLibrary()
FC0B4C  movem.l   (SP)+,A0/A2
FC0B50  move.l    D0,-(SP)              Store the library pointer.
FC0B52  beq.s     FC0B7C                If zero, just return it and exit.

        ; The library has been created successfully.

FC0B54  move.l    D0,A1                 Get the library pointer.
FC0B56  move.b    $0C(A0),D0            Get the module's node type.
FC0B5A  cmp.b     #3,D0                 If the node type is NT_DEVICE then
FC0B5E  bne.s     FC0B66
FC0B60  jsr       -$01B0(A6)              AddDevice().
FC0B64  bra.s     FC0B7C
FC0B66  cmp.b     #9,D0                 Else if it is NT_LIBRARY then
FC0B6A  bne.s     FC0B72
FC0B6C  jsr       -$018C(A6)              AddLibrary().
FC0B70  bra.s     FC0B7C
FC0B72  cmp.b     #8,D0                 Else if it is NT_RESOURCE then
FC0B76  bne.s     FC0B7C
FC0B78  jsr       -$01E6(A6)              AddResource().
FC0B7C  move.l    (SP)+,D0              Endif.
FC0B7E  rts       


        ; InitStruct entry point to copy one byte several times (-186).

FC0B80  move.b    (A1)+,D1              Get the byte initially.
FC0B82  move.b    D1,(A0)+              Copy it the required number of times.
FC0B84  dbra      D0,FC0B82(PC)
FC0B88  bra.s     FC0BD6                Back to main loop.

        ; Entry ponint for invalid InitStruct commands (-176).  Guru time.

FC0B8A  movem.l   D7/A5/A6,-(SP)        Save registers.
FC0B8E  move.l    #$81000007,D7         Alert number (fatal).
FC0B94  move.l    4,A6                  Get ExecBase
FC0B98  jsr       -$6C(A6)              Put up the Alert.
FC0B9C  movem.l   (SP)+,D7/A5/A6        This never gets executed.

        ; InitStruct entry point to copy one longword several times (-154).

FC0BA0  move.l    A1,D1                 Round A1 up to next even address.
FC0BA2  addq.l    #1,D1
FC0BA4  and.b     #$FE,D1
FC0BA8  move.l    D1,A1
FC0BAA  move.l    (A1)+,D1              Get the longword initially.
FC0BAC  move.l    D1,(A0)+              Copy it the required number of times.
FC0BAE  dbra      D0,FC0BAC(PC)
FC0BB2  bra.s     FC0BD6                Back to main loop.

        ; InitStruct entry point to copy one word several times (-134).

FC0BB4  move.l    A1,D1                 Round A1 up to next even address.
FC0BB6  addq.l    #1,D1
FC0BB8  and.b     #$FE,D1
FC0BBC  move.l    D1,A1
FC0BBE  move.w    (A1)+,D1              Get the word initially.
FC0BC0  move.w    D1,(A0)+              Copy it the required number of times.
FC0BC2  dbra      D0,FC0BC0(PC)
FC0BC6  bra.s     FC0BD6                Back to main loop.


---------------------------------------------------------------------------
  InitStruct( initTable, memory, size )
              A1         A2      D0
---------------------------------------------------------------------------

FC0BC8  move.l    A2,A0             Get structure base address.
FC0BCA  lsr.w     #1,D0             Divide size by 2 (get size in words)
FC0BCC  bra.s     FC0BD0
FC0BCE  clr.w     (A0)+             Loop: Clear the structure's memory.
FC0BD0  dbra      D0,FC0BCE(PC)

FC0BD4  move.l    A2,A0             Get structure base address again.
FC0BD6  clr.w     D0
FC0BD8  move.b    (A1)+,D0          Read a byte from the initTable.
FC0BDA  beq.s     FC0C38            If it is zero, we're done.
FC0BDC  bclr      #7,D0             Check and reset offset flag.
FC0BE0  beq.s     FC0BFC            Branch if it was not set.

        ; Process an offset command (10ssnnnn or 11ssnnnn).

FC0BE2  bclr      #6,D0             Check and reset byte/rptr flag.
FC0BE6  beq.s     FC0BF4            Branch if it was not set.
FC0BE8  subq.l    #1,A1             Back up over command byte.
FC0BEA  move.l    (A1)+,D1          Get cmd byte + 24 bit data.
FC0BEC  and.l     #$FFFFFF,D1       Mask out the command byte.
FC0BF2  bra.s     FC0BF8

        ; Process an offset/byte command (10ssnnnn).

FC0BF4  moveq     #0,D1
FC0BF6  move.b    (A1)+,D1          Get next byte from table into D1.

        ; Continue here for both offset commands.  In each case, A1 now
        ; points at the next even address in the initTable, and D1 contains
        ; the offset we have just fetched from it, as a longword.

FC0BF8  move.l    A2,A0             Get structure base address.
FC0BFA  add.l     D1,A0             Add offset just computed.

        ; Continue here for all commands,  A0 now holds the absolute
        ; address where the next operand should go, D0 contains what is
        ; left of the command byte, and A1 points at the current even
        ; address in the table.

FC0BFC  move.w    D0,D1               Get the command byte
FC0BFE  lsr.w     #3,D1               Shift and mask it so it becomes
FC0C00  and.w     #$0E,D1             2 * (sdd)
FC0C04  move.w    FC0C3A(D1.w),D1     Get the jump offset from the table.
FC0C08  and.w     #$0F,D0             Mask all but (nnnn) out of the command.
FC0C0C  jmp       FC0C3A(D1.w)        Jump to the right routine.

        ; Entry point for copying multiple bytes (-42).

FC0C10  move.b    (A1)+,(A0)+       Copy one byte.
FC0C12  dbra      D0,FC0C10(PC)     Loop until required number done.

FC0C16  move.l    A1,D0             Round A1 up to next even address.
FC0C18  addq.l    #1,D0
FC0C1A  bclr      #0,D0
FC0C1E  move.l    D0,A1
FC0C20  bra.s     FC0BD6            Go back to main loop.

        ; Entry point for copying multiple longwords (-24).

        ; Simply falls through to word copy routine, set up to copy twice as
        ; many words.  An extra 1 must be added to compensate for the effects
        ; of the "dbra" instruction.

FC0C22  add.w     D0,D0             D0 = (2 * D0) + 1.
FC0C24  addq.w    #1,D0

        ; Entry point for copying multiple words (-20).

FC0C26  move.l    A1,D1             Round A1 up to next even address.
FC0C28  addq.l    #1,D1
FC0C2A  and.b     #$FE,D1
FC0C2E  move.l    D1,A1
FC0C30  move.w    (A1)+,(A0)+       Move the data.
FC0C32  dbra      D0,FC0C30(PC)
FC0C36  bra.s     FC0BD6            Go back to top of main loop.

FC0C38  rts       

        ; Dispatch table for InitStruct.

FC0C3A  FFE8      -24               (sdd = 000) longword, count.
FC0C3C  FFEC      -20               (sdd = 001) word, count.
FC0C3E  FFD6      -42               (sdd = 010) byte, count.
FC0C40  FF50      -176              (sdd = 011) Invalid.
FC0C42  FF66      -154              (sdd = 100) longword, repeat.
FC0C44  FF7A      -134              (sdd = 101) word, repeat.
FC0C46  FF46      -186              (sdd = 110) byte, repeat.
FC0C48  FF50      -176              (sdd = 111) Invalid.

FC0C4A  0000                                          Padding.


        ; The following is used to bail out of an interrupt which we should
        ; have ignored.

FC0C4C  movem.l   (SP)+,D0/D1/A0/A1/A5/A6
FC0C50  rte       

        ; Level 1 Autovector interrupt entry point.
        ; -----------------------------------------

FC0C52  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0C56  lea       DFF000,A0         Point to custom chip register area.
FC0C5C  move.l    4,A6              Get ExecBase.
FC0C60  move.w    $1C(A0),D1        Get interrupt enable register.
FC0C64  btst      #$0E,D1           Check master interrupt enable.
FC0C68  beq.s     FC0C4C            Bail out if no interrupts enabled.
FC0C6A  and.w     $1E(A0),D1        Check for pending & enabled interrupts.

FC0C6E  btst      #0,D1             Serial port transmit interrupt?
FC0C72  beq.s     FC0C80
FC0C74  movem.l   $54(A6),A1/A5     Get IntVects[0] handler data.
FC0C7A  pea       -$24(A6)          Push address of ExitIntr()
FC0C7E  jmp       (A5)

FC0C80  btst      #1,D1             Disk block finished interrupt?
FC0C84  beq.s     FC0C92
FC0C86  movem.l   $60(A6),A1/A5     Get IntVects[1] handler data.
FC0C8C  pea       -$24(A6)          Push address of ExitIntr()
FC0C90  jmp       (A5)

FC0C92  btst      #2,D1             Software generated interrupt?
FC0C96  beq.s     FC0CA4
FC0C98  movem.l   $6C(A6),A1/A5     Get IntVects[2] handler data.
FC0C9E  pea       -$24(A6)          Push address of ExitIntr()
FC0CA2  jmp       (A5)

FC0CA4  bra.s     FC0C4C            Bail out if nothing found.

        ; Level 2 Autovector interrupt entry point.
        ; -----------------------------------------

FC0CA6  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0CAA  lea       DFF000,A0         See level 1 for comments.
FC0CB0  move.l    4,A6
FC0CB4  move.w    $1C(A0),D1
FC0CB8  btst      #$0E,D1
FC0CBC  beq.s     FC0C4C
FC0CBE  and.w     $1E(A0),D1

FC0CC2  btst      #3,D1             I/O port or timer interrupt?
FC0CC6  beq.s     FC0CD4
FC0CC8  movem.l   $78(A6),A1/A5     Get IntVects[3] handler data.
FC0CCE  pea       -$24(A6)          Push address of ExitIntr()
FC0CD2  jmp       (A5)

FC0CD4  bra       FC0C4C            Bail out if nothing found.

        ; Level 3 Autovector interrupt entry point.
        ; -----------------------------------------

FC0CD8  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0CDC  lea       DFF000,A0         See level 1 for comments.
FC0CE2  move.l    4,A6
FC0CE6  move.w    $1C(A0),D1
FC0CEA  btst      #$0E,D1
FC0CEE  beq       FC0C4C
FC0CF2  and.w     $1E(A0),D1

FC0CF6  btst      #6,D1             Blitter finished?
FC0CFA  beq.s     FC0D08
FC0CFC  movem.l   $9C(A6),A1/A5     Get IntVects[6] handler data.
FC0D02  pea       -$24(A6)          Push address of ExitIntr()
FC0D06  jmp       (A5)

FC0D08  btst      #5,D1             Start of vertical blank?
FC0D0C  beq.s     FC0D1A
FC0D0E  movem.l   $90(A6),A1/A5     Get IntVects[5] handler data.
FC0D14  pea       -$24(A6)          Push address of ExitIntr()
FC0D18  jmp       (A5)

FC0D1A  btst      #4,D1             Copper interrupt?
FC0D1E  beq.s     FC0D2C
FC0D20  movem.l   $84(A6),A1/A5     Get IntVects[4] handler data.
FC0D26  pea       -$24(A6)          Push address of ExitIntr()
FC0D2A  jmp       (A5)

FC0D2C  bra       FC0C4C            Bail out if nothing found.

        ; Level 4 Autovector interrupt entry point.
        ; -----------------------------------------

FC0D30  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0D34  lea       DFF000,A0         See level 1 for comments.
FC0D3A  move.l    4,A6
FC0D3E  move.w    $1C(A0),D1
FC0D42  btst      #$0E,D1
FC0D46  beq       FC0C4C
FC0D4A  and.w     $1E(A0),D1

FC0D4E  btst      #8,D1             Audio channel 1?
FC0D52  beq.s     FC0D62
FC0D54  movem.l   $B4(A6),A1/A5     Get IntVects[8] handler data.
FC0D5A  pea       FC0DA2            Use special ExitIntr() below.
FC0D60  jmp       (A5)

FC0D62  btst      #$0A,D1           Audio channel 3?
FC0D66  beq.s     FC0D76
FC0D68  movem.l   $CC(A6),A1/A5     Get IntVects[10] handler data.
FC0D6E  pea       FC0DA2            Use special ExitIntr() below.
FC0D74  jmp       (A5)

FC0D76  btst      #7,D1             Audio channel 0?
FC0D7A  beq.s     FC0D8A
FC0D7C  movem.l   $A8(A6),A1/A5     Get IntVects[7] handler data.
FC0D82  pea       FC0DA2            Use special ExitIntr() below.
FC0D88  jmp       (A5)

FC0D8A  btst      #9,D1             Audio channel 2?
FC0D8E  beq.s     FC0D9E
FC0D90  movem.l   $C0(A6),A1/A5     Get IntVects[9] handler data.
FC0D96  pea       FC0DA2            Use special ExitIntr() below.
FC0D9C  jmp       (A5)

FC0D9E  bra       FC0C4C            Bail out if nothing found.

        ; This routine allows a single invocation of the level 4 interrupt
        ; handler to service all level 4 interrupts which are pending or
        ; become pending while one is serviced.

FC0DA2  lea       DFF000,A0         Point at custom chip register area.
FC0DA8  move.l    4,A6              Get ExecBase.
FC0DAC  move.w    #$0780,D1         Mask for all level 4 interrupt bits.
FC0DB0  and.w     $1C(A0),D1
FC0DB4  and.w     $1E(A0),D1        Find enabled and pending level 4 ints.
FC0DB8  bne.s     FC0D4E            If any still pending, go service them.

FC0DBA  jmp       -$24(A6)          Otherwise, do ExitIntr()

        ; Level 5 Autovector interrupt entry point.
        ; -----------------------------------------

FC0DBE  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0DC2  lea       DFF000,A0         See level 1 for comments.
FC0DC8  move.l    4,A6
FC0DCC  move.w    $1C(A0),D1
FC0DD0  btst      #$0E,D1
FC0DD4  beq       FC0C4C
FC0DD8  and.w     $1E(A0),D1

FC0DDC  btst      #$0C,D1           Disk sync interrupt?
FC0DE0  beq.s     FC0DEE
FC0DE2  movem.l   $E4(A6),A1/A5     Get IntVects[12] handler data.
FC0DE8  pea       -$24(A6)          Push address of ExitIntr()
FC0DEC  jmp       (A5)

FC0DEE  btst      #$0B,D1           Serial port receive interrupt?
FC0DF2  beq.s     FC0E00
FC0DF4  movem.l   $D8(A6),A1/A5     Get IntVects[11] handler data.
FC0DFA  pea       -$24(A6)          Push address of ExitIntr()
FC0DFE  jmp       (A5)

FC0E00  bra       FC0C4C            Bail out if nothing found.

        ; Level 6 Autovector interrupt entry point.
        ; -----------------------------------------

FC0E04  movem.l   D0/D1/A0/A1/A5/A6,-(SP)

FC0E08  lea       DFF000,A0         See level 1 for comments.
FC0E0E  move.l    4,A6
FC0E12  move.w    $1C(A0),D1
FC0E16  btst      #$0E,D1
FC0E1A  beq       FC0C4C
FC0E1E  and.w     $1E(A0),D1

FC0E22  btst      #$0E,D1           Special copper interrupt?
FC0E26  beq.s     FC0E34
FC0E28  movem.l   $FC(A6),A1/A5     Get IntVects[14] handler data.
FC0E2E  pea       -$24(A6)          Push address of ExitIntr()
FC0E32  jmp       (A5)

FC0E34  btst      #$0D,D1           External level 6 interrupt?
FC0E38  beq.s     FC0E46
FC0E3A  movem.l   $F0(A6),A1/A5     Get IntVects[13] handler data.
FC0E40  pea       -$24(A6)          Push address of ExitIntr()
FC0E44  jmp       (A5)

FC0E46  bra       FC0C4C            Bail out if nothing found.

        ; Level 7 Autovector interrupt entry point.
        ; -----------------------------------------

FC0E4A  movem.l   D0/D1/A0/A1/A5/A6,-(SP)
FC0E4E  move.l    4,A6
FC0E52  movem.l   $0108(A6),A1/A5     Get IntVects[15] handler data.
FC0E58  jsr       (A5)
FC0E5A  movem.l   (SP)+,D0/D1/A0/A1/A5/A6
FC0E5E  rte       


---------------------------------------------------------------------------
  ExitIntr()
---------------------------------------------------------------------------

        ; This routine is called after an interrupt handler has finished.
        ; It checks if a task switch is necessary.  If not, it returns
        ; from the interrupt.  Otherwise, it drops into the scheduler.

        ; The initial check for supervisor mode is very important.  If
        ; the CPU was in supervisor mode, then there either was no task
        ; running (CPU stopped), or the task had already been interrupted
        ; by a lower priority interrupt.  In either case, we may not do
        ; a task switch.  In the former case, it will be done after the
        ; CPU comes out of the STOP instruction in the dispatcher, and
        ; in the latter, it will be taken care of by the lowest priority
        ; interrupt handler (which interrupted the CPU while it was not
        ; in supervisor mode).

FC0E60  btst      #5,$18(SP)          Check if CPU was in supervisor mode.
FC0E66  bne.s     FC0E80              If so, just return from interrupt.
FC0E68  move.l    4,A6                Get ExecBase.
FC0E6C  tst.b     $0127(A6)           See if task switching is disabled.
FC0E70  bge.s     FC0E80              If so, just return from interrupt.

FC0E72  btst      #7,$0124(A6)        Check the scheduling attention flag.
FC0E78  beq.s     FC0E80              Return from interrupt if not set.

FC0E7A  move.w    #$2000,SR           Enable all interrupts.
FC0E7E  bra.s     FC0E8A

FC0E80  movem.l   (SP)+,D0/D1/A0/A1/A5/A6
FC0E84  rte       


---------------------------------------------------------------------------
  Schedule()
---------------------------------------------------------------------------

        ; This is the scheduler.  It is called with the current task's
        ; registers saved on the system stack, as put there by the interrupt
        ; entry point, and PC/SR as put there by the interrupt itself.
        ;
        ; The scheduler checks if the task should be suspended and another
        ; task run in its place.  The following decision is made:
        ;
        ; IF the current task has an exception pending THEN
        ;    reschedule the current task, so that it will be redispatched,
        ;    so that the dispatcher can process the exception.
        ; ELSEIF the TaskReady queue is empty THEN
        ;    the current task is the only runnable task in the system, so
        ;    let it continue running.
        ; ELSEIF the TaskReady queue contains a higher priority task THEN
        ;    do a task switch.
        ; ELSEIF the current task's time slice has expired THEN
        ;    reschedule the current task (it may be redispatched right away,
        ;    with a new time slice).
        ; ELSE
        ;    let the current task keep running.
        ; ENDIF

FC0E86  movem.l   D0/D1/A0/A1/A5/A6,-(SP)
FC0E8A  move.w    #$2700,SR           Mask all maskable interrupts.
FC0E8E  bclr      #7,$0124(A6)        Reset the scheduling attention flag.
FC0E94  move.l    $0114(A6),A1        Get the current task pointer.
FC0E98  btst      #5,$0E(A1)          Check the task's TB_EXCEPT flag.
FC0E9E  bne.s     FC0EBE
FC0EA0  lea       $0196(A6),A0        Point to the TaskReady queue.
FC0EA4  cmp.l     8(A0),A0            Check if the queue is empty.
FC0EA8  beq.s     FC0E80              If so, return from interrupt.
FC0EAA  move.l    (A0),A0             Get the queue's head node.
FC0EAC  move.b    9(A0),D1            Get the head node's priority.
FC0EB0  cmp.b     9(A1),D1            Compare to the current task's priority.
FC0EB4  bge.s     FC0EBE              Switch tasks if higher priority.
FC0EB6  btst      #6,$0124(A6)        Check the time slice expired flag.
FC0EBC  beq.s     FC0E80              If not expired, return from interrupt.

        ; If we get this far, it is necessary to put the current task on
        ; the TaskReady queue and then run the one at the head of the queue.
        ; This may be the same one if a TB_EXCEPT is being processed.

FC0EBE  lea       $0196(A6),A0        Point to the TaskReady queue.
FC0EC2  bsr       FC1634              Enqueue the current task.
FC0EC6  move.b    #3,$0F(A1)          Make the task's state TS_READY.
FC0ECC  move.w    #$2000,SR           Enable all interrupts.

        ; Get the current task's saved registers back.  They may have been
        ; put on the stack when an interrupt occurred, or at the start of
        ; this routine.

FC0ED0  movem.l   (SP)+,D0/D1/A0/A1/A5

FC0ED4  move.l    (SP),-(SP)          Insert some space in the system stack.
FC0ED6  move.l    -$34(A6),4(SP)      Put in the address of Switch().
FC0EDC  move.l    (SP)+,A6            Get A6 from the stack.
FC0EDE  rts                           Go to Switch().


---------------------------------------------------------------------------
  Switch()

  [Version for machines without a numeric coprocessor]
---------------------------------------------------------------------------

        ; The ExecBase "Switch()" vector points here if no FPP is installed.

        ; This routine does a task switch.  It stores the context of
        ; the currently running task, then drops into the dispatcher.

        ; The routine stores the current CPU context on the user
        ; stack.  The status register and program counter are popped from
        ; the supervisor stack.  The current interrupt disable nesting
        ; level and the user stack pointer are then saved in this task's
        ; task descriptor.

        ; If the TB_SWITCH bit is set in the task descriptor, the task's
        ; TC_SWITCH function is called.

FC0EE0  move      #$2000,SR             Enable all interrupts.
FC0EE4  move.l    A5,-(SP)              Stack A5 on the supervisor stack.
FC0EE6  move      USP,A5                Get the user stack pointer.
FC0EE8  movem.l   D0-D7/A0-A6,-(A5)     Stack all registers on user stack.

FC0EEC  move.l    4,A6                  Get ExecBase

FC0EF0  move.w    $0126(A6),D0          Get current interrupt disable level.
FC0EF4  move.w    #$FFFF,$0126(A6)      Set interrupt disable level to -1.
FC0EFA  move.w    #$C000,DFF09A         Enable interrupts.

FC0F02  move.l    (SP)+,$34(A5)         Fix A5 in the saved register set.
FC0F06  move.w    (SP)+,-(A5)           Save the status register.
FC0F08  move.l    (SP)+,-(A5)           Save the program counter.

FC0F0A  lea       FC0FA6(PC),A4         Address of context-restore routine
                                        for machines without an FPP.

FC0F0E  move.l    $0114(A6),A3          Find the current task descriptor.
FC0F12  move.w    D0,$10(A3)            Store interrupt disable level.
FC0F16  move.l    A5,$36(A3)            Store user stack pointer.
FC0F1A  btst      #6,$0E(A3)            Check the TB_SWITCH bit
FC0F20  beq.s     FC0F3C
FC0F22  move.l    $42(A3),A5            If TB_SWITCH bit was set, then
FC0F26  jsr       (A5)                  call this task's TC_SWITCH function.
FC0F28  bra.s     FC0F3C


---------------------------------------------------------------------------
  Dispatch()

  [Version for machines without a numeric coprocessor]
---------------------------------------------------------------------------

        ; This routine dispatches the next runnable task, if there is one.

        ; If the TaskReady queue is empty, the routine waits, stopping
        ; the processor and checking the queue again each time it resumes
        ; running (after an interrupt).

        ; When a runnable task is found, it is dispatched.  Its context
        ; and interrupt disable level are restored, and the TB_LAUNCH
        ; and TB_EXCEPT flags are checked.  If either is set, they are
        ; handled.

FC0F2A  lea       FC0FA6(PC),A4         Address of context-restore routine
                                        for machines without an FPP.

FC0F2E  move.w    #$FFFF,$0126(A6)      Initialize interrupt disable level
FC0F34  move.w    #$C000,DFF09A         at -1, and enable interrupts.

FC0F3C  lea       $0196(A6),A0          Point at the TaskReady queue.
FC0F40  move      #$2700,SR             Mask all maskable interrupts.
FC0F44  move.l    (A0),A3               Check for a task descriptor at
FC0F46  move.l    (A3),D0               the front of the queue.
FC0F48  bne.s     FC0F5A

        ; TaskReady queue is empty.  Halt the processor until the next
        ; interrupt, then check for runnable tasks again.

FC0F4A  addq.l    #1,$0118(A6)          Increment the idle counter.
FC0F4E  bset      #7,$0124(A6)          Set the rescheduling attention flag.
FC0F54  stop      #$2000                Enable all interrupts and stop.
FC0F56  move.l    D0,D0
FC0F58  bra.s     FC0F40                Go back and check for runnable tasks.

        ; We have a runnable task.

FC0F5A  move.l    D0,(A0)               Unlink the task descriptor from
FC0F5C  move.l    D0,A1                 the TaskReady queue.
FC0F5E  move.l    A0,4(A1)
FC0F62  addq.l    #1,$011C(A6)          Increment the dispatch counter.

FC0F66  move.l    A3,$0114(A6)          Set the current task pointer.

FC0F6A  move.w    $0120(A6),$0122(A6)   Initialize the time-slice counter.

FC0F70  bclr      #6,$0124(A6)          Reset the time slice expired flag.
FC0F76  move.b    #2,$0F(A3)            Set the task's state to TS_RUN.

FC0F7C  move.w    $10(A3),$0126(A6)     Restore the interrupt disable level.
FC0F82  tst.b     $0126(A6)
FC0F86  bmi.s     FC0F90                Disable interrupts if interrupt
FC0F88  move.w    #$4000,DFF09A         disable level >= 0.

FC0F90  move      #$2000,SR             Enable all interrupts.
FC0F94  move.b    $0E(A3),D0            Get the task's flags.
FC0F98  and.b     #$A0,D0               Check for TB_EXCEPT or TB_LAUNCH.
FC0F9C  beq.s     FC0FA0
FC0F9E  bsr.s     FC0FB6                Process the flags if either was set.

FC0FA0  move.l    $36(A3),A5            Get the user stack pointer.

FC0FA4  jmp       (A4)                  Restore the CPU context.


        ; Context Restore routine (non-FPP version)
        ; -----------------------------------------

        ; Pop the task's CPU context off the user stack, and start it
        ; running.  The program counter and status register are set by
        ; storing them on the supervisor stack for the "RTE" instruction.

FC0FA6  lea       $42(A5),A2            Get the user stack pointer.
FC0FAA  move      A2,USP                Set it.
FC0FAC  move.l    (A5)+,-(SP)           Get the program counter.
FC0FAE  move.w    (A5)+,-(SP)           Get the status register.
FC0FB0  movem.l   (A5),D0-D7/A0-A6      Restore all the other registers.
FC0FB4  rte                             And start running the task.

        ; Subroutine to handle TB_LAUNCH and TB_EXCEPT.

FC0FB6  btst      #7,D0                 Check the TB_LAUNCH bit.
FC0FBA  beq.s     FC0FC6
FC0FBC  move.b    D0,D2                 If it was set, call the task's
FC0FBE  move.l    $46(A3),A5            TC_LAUNCH routine.
FC0FC2  jsr       (A5)
FC0FC4  move.b    D2,D0                 Restore D0.
FC0FC6  btst      #5,D0                 Check the TB_EXCEPT bit.
FC0FCA  bne.s     FC0FCE
FC0FCC  rts                             Return if it was clear.


---------------------------------------------------------------------------
  Exception()
---------------------------------------------------------------------------

        ; This routine handles task-level exception processing.

        ; It checks whether any signals have occurred which should cause
        ; a software exception.  If so, it calls the task's exception
        ; processing routine.  After this returns, it restores everything
        ; so that the task itself can be dispatched.

FC0FCE  bclr      #5,$0E(A3)            Reset the TB_EXCEPT bit.

FC0FD4  move.w    #$4000,DFF09A         Disable()
FC0FDC  addq.b    #1,$0126(A6)

FC0FE0  move.l    $1A(A3),D0            Get received signals.
FC0FE4  and.l     $1E(A3),D0            Compare with exception signals.
FC0FE8  eor.l     D0,$1E(A3)            If any exception signals were set,
FC0FEC  eor.l     D0,$1A(A3)            reset them in both places.

FC0FF0  subq.b    #1,$0126(A6)          Enable()
FC0FF4  bge.s     FC0FFE
FC0FF6  move.w    #$C000,DFF09A

FC0FFE  move.l    $36(A3),A1            Get the user stack pointer.

        ; Store tc_Flags, tc_State, tc_IDNestCnt, tc_TDNestCnt on user stack.

FC1002  move.l    $0E(A3),-(A1)

        ; If interrupts have been disabled exactly once, then enable them.

FC1006  tst.b     $0126(A6)
FC100A  bne.s     FC101A
FC100C  subq.b    #1,$0126(A6)
FC1010  bge.s     FC101A
FC1012  move.w    #$C000,DFF09A

        ; Put the address of an exception post-processing routine on the
        ; user stack.  This gets executed when the exception routine
        ; does an RTS.

FC101A  move.l    #$FC103A,-(A1)        Put return address on user stack.
FC1020  move      A1,USP                Set user stack pointer.
FC1022  btst      #0,$0129(A6)          See if this is a plain 68000.
FC1028  beq.s     FC102E
FC102A  move.w    #$20,-(SP)            Make 68010/020 extended stack frame.

FC102E  move.l    $2A(A3),-(SP)         Put exception code and a fake status
FC1032  clr.w     -(SP)                 word on the supervisor stack.
FC1034  move.l    $26(A3),A1            Point to the exception handler's
                                        data segment.
FC1038  rte       

        ; Continue here after the user's exception handling routine has run.

FC103A  move.l    4,A6                  Get ExecBase.
FC103E  lea       FC1046(PC),A5         Where to go in supervisor mode.
FC1042  jmp       -$1E(A6)              Go to supervisor mode.

FC1046  lea       FC0FA6(PC),A4         Address of context restore routine.

FC104A  btst      #0,$0129(A6)          Is this a 68010/020?
FC1050  beq.s     FC1060
FC1052  addq.l    #2,SP                 If so, handle extended stack frame.

FC1054  btst      #4,$0129(A6)          Do we have a 688881?
FC105A  beq.s     FC1060
FC105C  lea       FC10F0(PC),A4         If so, use the other context-restore.

FC1060  addq.l    #6,SP                 Pop PC and SR from stack.
FC1062  move.l    $0114(A6),A3          Get current task descriptor.
FC1066  or.l      D0,$1E(A3)            Set the exception signals up again.
FC106A  move      USP,A1                Get the user stack pointer.

        ; Restore tc_Flags, tc_State, tc_IDNestCnt, tc_TDNestCnt from
        ; user stack.

FC106C  move.l    (A1)+,$0E(A3)
FC1070  move.l    A1,$36(A3)            Set USP image in task descriptor.
FC1074  move.w    $10(A3),$0126(A6)     Restore interrupt disable level.
FC107A  tst.b     $0126(A6)
FC107E  bmi.s     FC1088
FC1080  move.w    #$4000,DFF09A         Disable interrupts if needed.
FC1088  rts       


---------------------------------------------------------------------------
  Switch()

  [Version for machines with a 68881 FPP]
---------------------------------------------------------------------------

FC108A  move      #$2000,SR             Enable all interrupts.
FC108E  move.l    A5,-(SP)              Store A5 on the supervisor stack.
FC1090  move      USP,A5                Get the user stack pointer.
FC1092  movem.l   D0-D7/A0-A6,-(A5)     Save all registers on user stack.
FC1096  move.l    4,A6                  Get ExecBase.
FC109A  move.w    $0126(A6),D0          Get current interrupt disable level.
FC109E  move.w    #$FFFF,$0126(A6)      Set interrupt disable level to -1.
FC10A4  move.w    #$C000,DFF09A         Enable interrupts.
FC10AC  move.l    (SP)+,$34(A5)         Fix A5 in the saved register set.
FC10B0  move.w    (SP)+,-(A5)           Save the status register.
FC10B2  move.l    (SP)+,-(A5)           Save the program counter.

        ; 68020/68881 specific material.  Without documentation for those
        ; processors, I can't comment this.

FC10B4  fsave     -(A5)
FC10B6  tst.b     (A5)
FC10B8  beq.s     FC10E0
FC10BA  moveq     #-1,D2
FC10BC  move.w    (SP),D1
FC10BE  and.w     #$F000,D1
FC10C2  cmp.w     #$9000,D1
FC10C6  bne.s     FC10D6
FC10C8  addq.l    #2,SP
FC10CA  move.l    (SP)+,-(A5)
FC10CC  move.l    (SP)+,-(A5)
FC10CE  move.l    (SP)+,-(A5)
FC10D0  move.w    #$20,-(SP)
FC10D4  move.w    D1,D2
FC10D6  fmovem.x  FP0-FP7,-(A5)
FC10DA  fmovem.l  FPCR/FPSR/FPIAR,-(A5)
FC10DE  move.w    D2,-(A5)

FC10E0  lea       FC10F0(PC),A4         Point to 68881 context restore.

        ; The rest of the processing for Switch() is the same, so enter
        ; the "plain" version in the middle.

FC10E4  bra       FC0F0E


---------------------------------------------------------------------------
  Dispatch()

  [Version for machines with a 68881 FPP]
---------------------------------------------------------------------------

FC10E8  lea       FC10F0(PC),A4         Point to 68881 context-restore.

        ; The regular Dispatch() can be used for the rest.

FC10EC  bra       FC0F2E


        ; Special 68881 FPP compatible context restore
        ; --------------------------------------------

        ; 68020/68881 specific material.  Without documentation for those
        ; processors, I can't comment this.

FC10F0  move.b    (A5),D0
FC10F2  beq.s     FC1110
FC10F4  addq.l    #2,A5
FC10F6  fmovem.l  (A5)+,FPCR/FPSR/FPIAR
FC10FA  fmovem.x  (A5)+,FP0-FP7
FC10FE  cmp.b     #$90,D0
FC1102  bne.s     FC1110
FC1104  addq.l    #2,SP
FC1106  move.l    (A5)+,-(SP)
FC1108  move.l    (A5)+,-(SP)
FC110A  move.l    (A5)+,-(SP)
FC110C  move.w    #$9020,-(SP)
FC1110  frestore  (A5)+

FC1112  lea       $42(A5),A2            This part is the same as the regular
FC1116  move      A2,USP                context-restore routine.
FC1118  move.l    (A5)+,-(SP)
FC111A  move.w    (A5)+,-(SP)
FC111C  movem.l   (A5),D0-D7/A0-A6
FC1120  rte       


---------------------------------------------------------------------------
  oldSR = SetSR( newSR, mask)
  D0             D0     D1
---------------------------------------------------------------------------

FC1122  move.l    A5,A0
FC1124  lea       FC112E(PC),A5     What to execute in supervisor mode.
FC1128  jsr       -$1E(A6)          Enter supervisor mode.
FC112C  rts       

FC112E  move.l    A0,A5             Now in supervisor mode.  Restore A5.
FC1130  move.w    (SP),A0           Get status register from stack.
FC1132  and.w     D1,D0             Mask unwanted bits out of newSR.
FC1134  not.w     D1
FC1136  and.w     D1,(SP)           Get unchanged bits from old status reg.
FC1138  or.w      D0,(SP)           Or in the bits to be changed.
FC113A  moveq     #0,D0
FC113C  move.w    A0,D0             Return old status codes in D0.
FC113E  rte                         Load status reg. and return to user mode.


---------------------------------------------------------------------------
  conditions = GetCC()
  D0

  [Version for 68000 machines only]
---------------------------------------------------------------------------

        ; The ExecBase vector will have been changed not to point here
        ; unless the CPU is a 68000, since the following instruction would
        ; bomb with a privilege violation on 68010/020 processors.

FC1140  move      SR,D0             Get the status register.
FC1142  and.w     #$FF,D0           Clear all but the condition codes.
FC1146  rts       


---------------------------------------------------------------------------
  oldSysStack = SuperState()
  D0
---------------------------------------------------------------------------

FC1148  move.l    A5,A0
FC114A  lea       FC1154(PC),A5     What to execute in supervisor mode.
FC114E  jsr       -$1E(A6)          Enter supervisor mode.
FC1152  rts       

FC1154  move.l    A0,A5             Continue here.  Restore A5.
FC1156  clr.l     D0
FC1158  bset      #5,(SP)           Set supervisor bit in status word.
FC115C  bne.s     FC1172            Do nothing more if it was already set.

FC115E  move      (SP)+,SR          Get status register from stack.
FC1160  move.l    SP,D0             Save supervisor stack pointer.
FC1162  move      USP,SP            Load user stack pointer.

FC1164  btst      #0,$0129(A6)      Check if running on a plain 68000.
FC116A  beq.s     FC116E
FC116C  addq.l    #2,D0             Pop 68010/020 exception info from stack.
FC116E  addq.l    #4,D0             Pop exception return address from stack.

FC1170  rts                         Return to user.

FC1172  rte       


---------------------------------------------------------------------------
  UserState( sysStack )
             D0
---------------------------------------------------------------------------

FC1174  move.l    A5,A0
FC1176  lea       FC117E(PC),A5     Where to go in supervisor mode.
FC117A  jmp       -$1E(A6)          Enter supervisor mode (just in case).
FC117E  move.l    A0,A5             Restore A5.
FC1180  move.w    (SP)+,D1          Get status register from stack.
FC1182  move      SP,USP            Copy stack pointer to user stack pointer.
FC1184  move.l    D0,SP             Set the system stack pointer.
FC1186  bclr      #$0D,D1           Clear the supervisor mode bit.
FC118A  move      D1,SR
FC118C  rts                         Return to the user.


---------------------------------------------------------------------------
  oldInterrupt = SetIntVector( intNumber, interrupt )
  D0                           D0         A1
---------------------------------------------------------------------------

        ; This routine makes an interrupt node the active interrupt node
        ; for a given interrupt number.  This node corresponds to an
        ; interrupt handler.  There can only be one node associated with
        ; each interrupt number.

        ; Note: Never try to SetIntVector() one of the interrupts which are
        ; dispatched as chains of servers.  The handler which does this
        ; does not use regular interrupt vectors or nodes, and it would not
        ; be possible to hook it up to the interrupt again if it became
        ; disconnected.

FC118E  mulu      #$0C,D0           Compute address of
FC1192  lea       $54(A6,D0.w),A0   ExecBase->IntVects[intNumber]

FC1196  move.w    #$4000,DFF09A     Disable()
FC119E  addq.b    #1,$0126(A6)

FC11A2  move.l    8(A0),D0          Get pointer to current interrupt node.
FC11A6  move.l    A1,8(A0)          Install pointer to new interrupt node.

FC11AA  beq.s     FC11BA            If there is a new node, then
FC11AC  move.l    $0E(A1),0(A0)       Install interrupt data pointer.
FC11B2  move.l    $12(A1),4(A0)       Install interrupt code pointer.
FC11B8  bra.s     FC11C4            Else
FC11BA  moveq     #-1,D1              Set code and data pointers to -1.
FC11BC  move.l    D1,0(A0)
FC11C0  move.l    D1,4(A0)          Endif

FC11C4  subq.b    #1,$0126(A6)      Enable()
FC11C8  bge.s     FC11D2
FC11CA  move.w    #$C000,DFF09A
FC11D2  rts       


---------------------------------------------------------------------------
   AddIntServer( intNumber, interrupt )
                 D0         A1
---------------------------------------------------------------------------

        ; Adds an interrupt server to the server chain for a given
        ; interrupt number.  The interrupt number must be one of the
        ; set for which interrupt server lists have been set up.

        ; The interrupt for which the server is being added will be enabled
        ; if it is not already enabled.

FC11D4  move.l    D2,-(SP)
FC11D6  move.l    D0,D2             Save interrupt number.
FC11D8  move.l    D0,D1
FC11DA  mulu      #$0C,D0           Compute
FC11DE  lea       $54(A6,D0.w),A0   ExecBase->IntVects[intNumber].is_Node
FC11E2  move.l    0(A0),A0

FC11E6  move.w    #$4000,DFF09A     Disable()
FC11EE  addq.b    #1,$0126(A6)

FC11F2  bsr       FC1634            Enqueue the interrupt server.

FC11F6  move.w    #$8000,D0         Hardware-enable the interrupt
FC11FA  bset      D2,D0             corresponding to the server just added.
FC11FC  move.w    D0,DFF09A

FC1202  subq.b    #1,$0126(A6)      Enable()
FC1206  bge.s     FC1210
FC1208  move.w    #$C000,DFF09A

FC1210  move.l    (SP)+,D2
FC1212  rts       


---------------------------------------------------------------------------
   RemIntServer( intNumber, interrupt )
                 D0         A1
---------------------------------------------------------------------------

        ; This routine takes an interrupt server off the server chain for
        ; a given interrupt.  The interrupt is disabled if this leaves the
        ; server chain empty.

FC1214  move.l    D2,-(SP)
FC1216  mulu      #$0C,D0           Compute
FC121A  lea       $54(A6,D0.w),A0   ExecBase->IntVects[intNumber].is_Node
FC121E  move.l    0(A0),A0

FC1222  move.l    D0,D2             Save interrupt number and node.
FC1224  move.l    A0,D1

FC1226  move.w    #$4000,DFF09A     Disable()
FC122E  addq.b    #1,$0126(A6)

FC1232  bsr       FC1600            Unlink interrupt server from the chain.
FC1236  move.l    D1,A0
FC1238  cmp.l     8(A0),A0          Check if the chain is now empty.
FC123C  bne       FC124A

FC1240  moveq     #0,D1             Chain is empty.  Disable the interrupt
FC1242  bset      D2,D1             corresponding to this node.
FC1244  move.w    D1,DFF09A

FC124A  subq.b    #1,$0126(A6)      Enable()
FC124E  bge.s     FC1258
FC1250  move.w    #$C000,DFF09A

FC1258  move.l    (SP)+,D2
FC125A  rts       


        ; The following routine is used at system startup to initialize
        ; the exec's internal interrupt handlers.

        ; It initializes the server chains used to dispatch servers for
        ; I/O and timer, Copper, vertical blank, external level 6, and
        ; non-maskable interrupts, and establishes vectors to the exec's
        ; built-in interrupt handlers.

        ; For each server chain, a 22-byte data structure is built,
        ; consisting of a list header and 4 words of control data.  The
        ; 5 server chain headers are put into a contiguous 110-byte
        ; section of memory.  The server chains are initialized to empty,
        ; and the rest of the data structure is initialized with the
        ; data required to assert, deassert, and cancel the interrupt.


FC125C  movem.l   D2/D3/A2/A3,-(SP)
FC1260  move.l    #$00006E,D0       110 bytes needed.
FC1266  move.l    #$010001,D1       Attributes = MEMF_PUBLIC | MEMF_CLEAR.
FC126C  bsr       FC1794            Request memory.
FC1270  tst.l     D0                See if we got the memory.
FC1272  bne.s     FC128A
FC1274  movem.l   D7/A5/A6,-(SP)    If not, it's guru time!
FC1278  move.l    #$81000006,D7     Use this alert number.
FC127E  move.l    4,A6              Get ExecBase.
FC1282  jsr       -$6C(A6)          Go put up the alert.
FC1286  movem.l   (SP)+,D7/A5/A6    Never reached.

FC128A  moveq     #4,D2             Loop 5 times (4 + 1 for dbra).
FC128C  move.l    D0,A2             Get pointer to allocated memory.
FC128E  lea       FC12DE(PC),A3     Point to the data table below.

        ; Loop:  Divide the 110 byte data area up into five data
        ; structures, each consisting of a list header and some control
        ; words.

FC1292  move.l    A2,D1             Save pointer to current node.
FC1294  move.l    A2,(A2)           Initialize the node's server chain
FC1296  addq.l    #4,(A2)           to empty.
FC1298  clr.l     4(A2)
FC129C  move.l    A2,8(A2)

FC12A0  lea       $0E(A2),A2        Point to the node's data area.
FC12A4  move.w    (A3)+,D3          Get interrupt number from table.
FC12A6  moveq     #0,D0             Make the control word needed to disable
FC12A8  bset      D3,D0             this interrupt.
FC12AA  move.w    D0,(A2)+          Write it in the node's data area.
FC12AC  bset      #$0F,D0           Make the control word needed to enable
FC12B0  move.w    D0,(A2)+          this interrupt and store it also.
FC12B2  move.w    (A3)+,(A2)+       Get the cancel interrupt control word.
FC12B4  move.w    (A3)+,(A2)+       Move a word of pad data.
FC12B6  lea       FC12FC(PC),A1     Point to the generic interrupt handler.

        ; Set up this interrupt in the exec table.  The interrupt vector
        ; is at ExecBase + $54 + 12 * interrupt number.  We write the code
        ; and data addresses only; we don't bother with the node address.

FC12BA  mulu      #$0C,D3
FC12BE  movem.l   D1/A1,$54(A6,D3.w)

FC12C4  dbra      D2,FC1292(PC)     Loop until all interrupts done.

        ; Install the address of the software interrupt handler.  The
        ; software interrupt lists have already been cleared earlier in
        ; the system startup code.

FC12C8  move.l    #$FC1380,$70(A6)

        ; Now enable interrupts and exit.  Note that only the software
        ; interrupts are enabled.  The interrupts handled by the handler
        ; below will be enabled if and when servers are put on their
        ; chains.  Interrupts handled external to the exec must be enabled
        ; by whoever provides the handler.

FC12D0  move.w    #$8004,DFF09A
FC12D8  movem.l   (SP)+,D2/D3/A2/A3
FC12DC  rts       


        ; Interrupt initialization table.  Each line consists of an
        ; interrupt number, and a control word which is used to cancel
        ; the interrupt if pending.  The last column appears to be padding.


FC12DE  0003 0008 0000
FC12E4  0005 0020 0000
FC12EA  0004 0010 0000
FC12F0  000D 2000 0000
FC12F6  000F 0000 0000


        ; Generic Interrupt Handler
        ; -------------------------

        ; Each logical interrupt (0-15) has a handler.  Some logical
        ; interrupts are accessible to the user not as handlers, but rather,
        ; as chains of servers.  Most of these (all but the Blitter one)
        ; use this code, which acts as a handler and dispatches the servers.

        ; A data structure set up by the previous routine exists for each
        ; interrupt to store the list header for the server chain, and some
        ; control words.

FC12FC  move.w    $12(A1),-(SP)
FC1300  move.l    A2,-(SP)
FC1302  move.l    (A1),A2          Check the head of the server chain.

        ; Main loop:  Here we dispatch a server from the queue.

FC1304  move.l    (A2),D0          Is this the end of the chain?
FC1306  beq.s     FC1316           If so, exit.
FC1308  movem.l   $0E(A2),A1/A5    Get the server's code and data addresses.
FC130E  jsr       (A5)             Call it.

        ; Servers return with the zero flag indicating whether they have
        ; taken care of the interrupt.  We keep calling servers until
        ; we either run out or until one returns the zero flag clear.

FC1310  bne.s     FC1316           If the zero flag is clear, exit.
FC1312  move.l    (A2),A2          Go to next node in the queue.
FC1314  bra.s     FC1304           Go back to top of loop.

        ; Either we ran out of servers, or one of them accepted the
        ; interrupt.  Either way, clear the interrupt and exit.

FC1316  move.l    (SP)+,A2
FC1318  move.w    (SP)+,DFF09C     Clear the interrupt.
FC131E  rts       


---------------------------------------------------------------------------
  Cause( interrupt )
         A1
---------------------------------------------------------------------------

FC1320  move.w    #$4000,DFF09A     Disable()
FC1328  addq.b    #1,$0126(A6)

FC132C  cmp.b     #$0B,8(A1)        Check if node type is already NT_SOFTINT.
FC1332  beq.s     FC1370            If so, do nothing.

FC1334  move.b    #$0B,8(A1)        Make node type NT_SOFTINT.
FC133A  moveq     #0,D0
FC133C  move.b    9(A1),D0          Get node priority.
FC1340  and.w     #$F0,D0           Truncate to a multiple of 16.
FC1344  ext.w     D0                Sign extend to a word quantity.
FC1346  lea       $01D2(A6),A0      Point at middle of ExecBase->SoftInts
FC134A  add.w     D0,A0             Get address of SoftInts entry correspon-
                                    ding to this priority (-32,-16,0,16,32).

        ; Now enqueue the node on the SoftIntList for this priority.

FC134C  lea       4(A0),A0
FC1350  move.l    4(A0),D0          Get old TailPred pointer.
FC1354  move.l    A1,4(A0)          Set TailPred pointer to new node.
FC1358  move.l    A0,(A1)           Set forward pointer of new node.
FC135A  move.l    D0,4(A1)          Set back pointer of new node.
FC135E  move.l    D0,A0
FC1360  move.l    A1,(A0)           Set forward pointer of old tail node.

FC1362  bset      #5,$0124(A6)      Set the software interrupt pending flag.
FC1368  move.w    #$8004,DFF09C     Generate a level 1 "software" interrupt.
FC1370  subq.b    #1,$0126(A6)      Enable()
FC1374  bge.s     FC137E
FC1376  move.w    #$C000,DFF09A
FC137E  rts       

        ; Software Interrupt Handler
        ; --------------------------

        ; This is the interrupt handler for logical interrupt #2, which
        ; is used for software interrupts.  It will be called as soon after
        ; the above routine as its interrupt priority will allow.

FC1380  move.w    #4,DFF09C         Clear the interrupt.
FC1388  bclr      #5,$0124(A6)      Clear the software int. pending flag.
FC138E  bne.s     FC1392            If it wasn't set, ignore the interrupt.
FC1390  rts       

FC1392  move.w    #4,DFF09A         Disable further software interrupts.
FC139A  bra.s     FC13C2            Go and scan the SoftInts table.

        ; This code is called (from below) when a non-empty SoftIntList
        ; has been found.  The pointer of the list will be in A0.

FC139C  move.w    #$2700,SR         Mask all maskable interrupts.
FC13A0  move.l    (A0),A1           Get the pointer to the first list node.
FC13A2  move.l    (A1),D0
FC13A4  beq.s     FC13AE
FC13A6  move.l    D0,(A0)           Unlink the node from the list.
FC13A8  exg       A1,D0
FC13AA  move.l    A0,4(A1)
FC13AE  move.l    D0,A1
FC13B0  move.b    #2,8(A1)          Make the node type NT_INTERRUPT.
FC13B6  move.w    #$2000,SR         Enable all interrupts.
FC13BA  movem.l   $0E(A1),A1/A5     Get the interrupt code and data.
FC13C0  jsr       (A5)              Call the node's interrupt handler.

        ; The following scans the SoftInts[] table for non-empty
        ; SoftIntLists.  If it finds one, it executes the code above.

FC13C2  moveq     #4,D0             Loop 5 times (1 less for dbra).
FC13C4  lea       $01F2(A6),A0      Start at SoftInts[4] (priority 32).
FC13C8  move.w    #4,DFF09C         Clear the software interrupt.
FC13D0  cmp.l     8(A0),A0          See if there are any nodes on this list.
FC13D4  bne.s     FC139C            If so, process the list.
FC13D6  lea       -$10(A0),A0       Otherwise, go to next lower priority,
FC13DA  dbra      D0,FC13D0(PC)     and loop back.

        ; No (more) nodes found.

FC13DE  move      #$2100,SR
FC13E2  move.w    #$8004,DFF09A     Reenable software interrupts and exit.
FC13EA  rts       


---------------------------------------------------------------------------
  Disable()
---------------------------------------------------------------------------

        ; Hardware disable all interrupts, and log the fact that this
        ; was done in the interrupt disable nesting level counter.

FC13EC  move.w    #$4000,DFF09A
FC13F4  addq.b    #1,$0126(A6)
FC13F8  rts       


---------------------------------------------------------------------------
  Enable()
---------------------------------------------------------------------------

        ; Decrement the interrupt level nesting counter, and if it goes
        ; negative, enable interrupts again.

FC13FA  subq.b    #1,$0126(A6)
FC13FE  bge.s     FC1408
FC1400  move.w    #$C000,DFF09A
FC1408  rts       

FC140A  0000                        Padding.


---------------------------------------------------------------------------
  AddLibrary( library )
              A1
---------------------------------------------------------------------------

FC140C  lea       $017A(A6),A0      Point to system library list.
FC1410  bsr       FC1682            Add the library to the list.
FC1414  bsr       FC1498            Update the library vector checksum.
FC1418  rts       


---------------------------------------------------------------------------
  error = RemLibrary( library )
  D0                  A1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this.

FC141A  move.l    A1,D0
FC141C  addq.b    #1,$0127(A6)      Forbid()
FC1420  move.l    A6,-(SP)          Save ExecBase.
FC1422  move.l    D0,A6
FC1424  jsr       -$12(A6)          Call the library's Expunge() function.
FC1428  move.l    (SP)+,A6          Restore ExecBase.
FC142A  jsr       -$8A(A6)          Permit()
FC142E  rts       


---------------------------------------------------------------------------
  library = OldOpenLibrary( libName )
  D0                        A1
---------------------------------------------------------------------------

        ; This is just OpenLibrary() without the "version" parameter.

FC1430  moveq     #0,D0             Any version of the library will do.
FC1432  jsr       -$0228(A6)        OpenLibrary()
FC1436  rts       


---------------------------------------------------------------------------
  library = OpenLibrary( libName, version )
  D0                     A1       D0
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this, presumably so it can pull libraries off
        ; disk if they aren't already in the library list.

        ; Note how several versions of a library can be in the system
        ; library list (although the initial RomTag system of putting them
        ; there will only take the newest one), and this routine will keep
        ; looking for one new enough to satisfy the request if it finds
        ; one which is too old.

FC1438  move.l    D2,-(SP)
FC143A  move.l    D0,D2
FC143C  addq.b    #1,$0127(A6)      Forbid()
FC1440  lea       $017A(A6),A0      Point to the system library list.
FC1444  bsr       FC165A            FindName()
FC1448  tst.l     D0                Did we find the library?
FC144A  beq.s     FC145E            Return zero and exit if not.
FC144C  move.l    D0,A0
FC144E  cmp.w     $14(A0),D2        Check the version number.
FC1452  bgt.s     FC1444            Try to find another one if too old.

        ; We have an acceptable library.

FC1454  move.l    A6,-(SP)          Save ExecBase.
FC1456  move.l    A0,A6             Point A6 at the library base address.
FC1458  jsr       -6(A6)            Call the library's Open() function.
FC145C  move.l    (SP)+,A6          Restore ExecBase.
FC145E  jsr       -$8A(A6)          Permit()
FC1462  move.l    (SP)+,D2
FC1464  rts       


---------------------------------------------------------------------------
  CloseLibrary( library )
                A1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this.

FC1466  addq.b    #1,$0127(A6)      Forbid()
FC146A  move.l    A6,-(SP)          Save ExecBase.
FC146C  move.l    A1,A6
FC146E  jsr       -$0C(A6)          Call the library's Close() function.
FC1472  move.l    (SP)+,A6          Restore ExecBase.
FC1474  jsr       -$8A(A6)          Permit()
FC1478  rts       


---------------------------------------------------------------------------
  oldFunc = SetFunction( library, funcOffset, funcEntry )
  D0                     A1       A0.W        D0
---------------------------------------------------------------------------

FC147A  bset      #1,$0E(A1)        Indicate that library is modified.
FC1480  lea       0(A1,A0.w),A0     Compute address of jump instruction.
FC1484  move.l    2(A0),-(SP)       Get the old jump destination address.
FC1488  move.w    #$4EF9,(A0)       Install a "JMP" instruction.
FC148C  move.l    D0,2(A0)          Install the new destination address.
FC1490  bsr       FC1498            Re-checksum the library.
FC1494  move.l    (SP)+,D0          Return the previous jump destination.
FC1496  rts       


---------------------------------------------------------------------------
  SumLibrary( library )
              A1
---------------------------------------------------------------------------

FC1498  btst      #2,$0E(A1)        Check the "sum used" flag.
FC149E  beq.s     FC14EA            If sum not used, then don't bother.

FC14A0  addq.b    #1,$0127(A6)
FC14A4  bclr      #1,$0E(A1)        Clear the "changed" flag.
FC14AA  beq.s     FC14B0
FC14AC  clr.w     $1C(A1)           If the flag was set, clear the checksum.
FC14B0  move.l    A1,A0
FC14B2  move.w    $10(A1),D0        Get the negative size.
FC14B6  lsr.w     #1,D0             Divide by 2 (gives size in words).
FC14B8  moveq     #0,D1             Start the sum at zero.
FC14BA  bra.s     FC14BE

        ; Loop:  Add up all the 16-bit words in the library's jump vector.

FC14BC  add.w     -(A0),D1
FC14BE  dbra      D0,FC14BC(PC)

FC14C2  move.w    $1C(A1),D0        Get the old checksum.
FC14C6  beq.s     FC14E2
FC14C8  cmp.w     D0,D1             Old checksum wasn't zero, so compare
FC14CA  beq.s     FC14E6            it to the new checksum.

        ; Checksums didn't match, so put up an alert.

FC14CC  movem.l   D7/A5/A6,-(SP)
FC14D0  move.l    #$81000003,D7     Library checksum alert number.
FC14D6  move.l    4,A6
FC14DA  jsr       -$6C(A6)          Call the alert function.
FC14DE  movem.l   (SP)+,D7/A5/A6

FC14E2  move.w    D1,$1C(A1)        Store the new checksum in the library.

FC14E6  jsr       -$8A(A6)          Enable multitasking.
FC14EA  rts       


---------------------------------------------------------------------------
  library = MakeLibrary( vectors, structure, init, dataSize, segList )
  D0                     A0       A1         A2    D0        D1
---------------------------------------------------------------------------

FC14EC  movem.l   D2-D7/A2/A3,-(SP)

FC14F0  move.l    D0,D2             Size of library data area.
FC14F2  move.l    A0,D4             Pointer to library vector table.
FC14F4  move.l    A1,D5             Pointer to initialization structure.
FC14F6  move.l    A2,D6             Function to call after creating library.
FC14F8  move.l    D1,D7             SegList (for DOS use).
FC14FA  move.l    A0,D3             Get pointer to vector table.
FC14FC  beq.s     FC151E            Skip the following if no vectors.

FC14FE  move.l    A0,A3
FC1500  moveq     #-1,D3
FC1502  move.l    D3,D0             Check if vector data is absolute or
FC1504  cmp.w     (A3),D0           relative (first word = -1).
FC1506  bne.s     FC1512
FC1508  addq.l    #2,A3             Relative vectors.  Skip over the flag.
FC150A  cmp.w     (A3)+,D0          Count the vectors up to the terminating
FC150C  dbeq      D3,FC150A(PC)     flag.  D3 holds -(number of vectors + 1)
FC1510  bra.s     FC1518
FC1512  cmp.l     (A3)+,D0          Absolute vectors.  Count as above.
FC1514  dbeq      D3,FC1512(PC)
FC1518  not.w     D3                Make number of vectors positive.
FC151A  mulu      #6,D3             Multiply by 6.

FC151E  move.l    D2,D0
FC1520  add.l     D3,D0             Add size of data area.

FC1522  move.l    #$010001,D1       MEMF_PUBLIC | MEMF_CLEAR
FC1528  jsr       -$C6(A6)          Request memory for library node.

FC152C  tst.l     D0                See if the memory was allocated.
FC152E  bne.s     FC1536
FC1530  moveq     #0,D0             Didn't get any memory.  Fail by returning
FC1532  bra       FC1570            a nil pointer to the caller.

FC1536  move.l    D0,A3             Point to start of allocated memory.
FC1538  add.l     D3,A3             Skip over jump vector area.
FC153A  move.w    D3,$10(A3)        Install negative size in library node.
FC153E  move.w    D2,$12(A3)        Install positive size.
FC1542  move.l    A3,A0
FC1544  sub.l     A2,A2             Clear A2.
FC1546  move.l    D4,A1             Point at vector table again.
FC1548  cmp.w     #$FFFF,(A1)       Check if vectors are relative.
FC154C  bne.s     FC1552
FC154E  addq.l    #2,A1             If vectors are relative, skip over flag,
FC1550  move.l    D4,A2             and set A2 to vector table address.

FC1552  bsr       FC1576            Install the jump vector.

FC1556  tst.l     D5                Check if there is an initialization
FC1558  beq.s     FC1564            structure.  Skip the following if not.

FC155A  move.l    A3,A2
FC155C  move.l    D5,A1
FC155E  moveq     #0,D0             Do not clear memory before initializing.
FC1560  jsr       -$4E(A6)          Process the initialization structure.

FC1564  move.l    A3,D0             Get pointer to library node.
FC1566  tst.l     D6                Check if there is initialization code.
FC1568  beq.s     FC1570            Skip the following if not.

FC156A  move.l    D6,A1             Get the address of the code.
FC156C  move.l    D7,A0             Get the address of the segList
FC156E  jsr       (A1)              Call the initialization code.

FC1570  movem.l   (SP)+,D2-D7/A2/A3
FC1574  rts       


---------------------------------------------------------------------------
  size = MakeFunctions( vectors, offset )
  D0                    A1       A2
---------------------------------------------------------------------------

FC1576  move.l    A3,-(SP)
FC1578  moveq     #0,D0             Clear size counter.
FC157A  move.l    A2,D1             Check if vector table is relative.
FC157C  beq.s     FC1594

        ; Process a relative vector initialization table.

FC157E  move.w    (A1)+,D1          Get a relative table entry.
FC1580  cmp.w     #$FFFF,D1         Check if end of table marker.
FC1584  beq.s     FC15A8
FC1586  lea       0(A2,D1.w),A3     Compute absolute vector address.
FC158A  move.l    A3,-(A0)          Install in jump vector.
FC158C  move.w    #$4EF9,-(A0)      Install "JMP" instruction.
FC1590  addq.l    #6,D0             Increment size counter.
FC1592  bra.s     FC157E

        ; Process an absolute vector initialization table.

FC1594  move.l    (A1)+,D1          Get an absolute table entry.
FC1596  cmp.l     #$FFFFFFFF,D1     Check if end of table marker.
FC159C  beq.s     FC15A8
FC159E  move.l    D1,-(A0)          Install it in the jump table.
FC15A0  move.w    #$4EF9,-(A0)      Install "JMP" instruction.
FC15A4  addq.l    #6,D0             Increment size counter.
FC15A6  bra.s     FC1594

FC15A8  move.l    (SP)+,A3          Done, return to caller.
FC15AA  rts       


---------------------------------------------------------------------------
  Insert( list, node, listNode )
          A0    A1    A2
---------------------------------------------------------------------------

FC15AC  move.l    A2,D0         Check if node to insert after is zero.
FC15AE  beq       FC15D8        If so, do an AddHead instead.

FC15B2  move.l    (A2),D0       See if list node indicates end of list.
FC15B4  beq       FC15C6        Branch if so.

        ; If we get this far, A2 must point to a list node.

FC15B8  move.l    D0,A0
FC15BA  movem.l   D0/A2,(A1)    Set forward and back pointers of new node.
FC15BE  move.l    A1,4(A0)      Set back pointer of next node.
FC15C2  move.l    A1,(A2)       Set forward pointer of previous node.
FC15C4  rts       

        ; The "Successor" field of the listNode was zero, i.e. listNode
        ; is really the end of list marker.  In this case, insert just
        ; before listNode, i.e. at the end of the list (undocumented).

FC15C6  move.l    A2,(A1)       Set forward pointer of new node to end.
FC15C8  move.l    4(A2),A0      Get old TailPred pointer
FC15CC  move.l    A0,4(A1)      Link previous end node to new node.
FC15D0  move.l    A1,4(A2)      Set the TailPred pointer to the new node.
FC15D4  move.l    A1,(A0)       Link this node to the previous end node.
FC15D6  rts       


---------------------------------------------------------------------------
  AddHead( list, node )
           A0    A1
---------------------------------------------------------------------------

FC15D8  move.l    (A0),D0       Get old pointer to first node.
FC15DA  move.l    A1,(A0)       Make the first node the new node.
FC15DC  movem.l   D0/A0,(A1)    Set forward and back pointers in new node.
FC15E0  move.l    D0,A0
FC15E2  move.l    A1,4(A0)      Fix back pointer in previous first node.
FC15E6  rts       


---------------------------------------------------------------------------
  AddTail( list, node )
           A0    A1
---------------------------------------------------------------------------

FC15E8  lea       4(A0),A0      Point A0 to list's "Tail" field.
FC15EC  move.l    4(A0),D0      Save old value of TailPred field.
FC15F0  move.l    A1,4(A0)      Make the new node the last node.
FC15F4  move.l    A0,(A1)       Set new node's back pointer to list header.
FC15F6  move.l    D0,4(A1)      Set new node's back pointer.
FC15FA  move.l    D0,A0
FC15FC  move.l    A1,(A0)       Link new node to previous last node.
FC15FE  rts       


---------------------------------------------------------------------------
  Remove( node )
          A1
---------------------------------------------------------------------------

FC1600  move.l    (A1),A0       Get pointer to successor node.
FC1602  move.l    4(A1),A1      Get pointer to predecessor node.
FC1606  move.l    A0,(A1)       Point predecessor to successor.
FC1608  move.l    A1,4(A0)      Point successor to predecessor.
FC160C  rts       


---------------------------------------------------------------------------
  node = RemHead( list )
  D0              A0
---------------------------------------------------------------------------

FC160E  move.l    (A0),A1       Get list's head pointer.
FC1610  move.l    (A1),D0       Get first node's successor.
FC1612  beq.s     FC161C        If zero, list is empty, so return zero.

FC1614  move.l    D0,(A0)       Point head pointer past removed node.
FC1616  exg       A1,D0
FC1618  move.l    A0,4(A1)      Point new head node back at list header.
FC161C  rts       


---------------------------------------------------------------------------
  node = RemTail( list )
  D0              A0
---------------------------------------------------------------------------

FC161E  move.l    8(A0),A1      Get list's TailPred pointer.
FC1622  move.l    4(A1),D0      Check if the last node has a predecessor.
FC1626  beq.s     FC1632        If not, the list is empty, so return zero.
FC1628  move.l    D0,8(A0)      Point TailPred pointer at second-last node.
FC162C  exg       A1,D0
FC162E  move.l    A0,(A1)       Point second-last node at the list header.
FC1630  addq.l    #4,(A1)       Increment to point at "Tail" field.
FC1632  rts       


---------------------------------------------------------------------------
  Enqueue( list, node )
           A0    A1
---------------------------------------------------------------------------

FC1634  move.b    9(A1),D1      Get the priority field of the node.
FC1638  move.l    (A0),D0       Get the head pointer of the queue.

        ; Loop:  Keep skipping nodes until the end of the list is
        ; reached or the next node has a lower priority.

FC163A  move.l    D0,A0         Point at the current node.
FC163C  move.l    (A0),D0       Check if there is a successor.
FC163E  beq.s     FC1646        If not, we are at the end of the list.
FC1640  cmp.b     9(A0),D1      Compare priorities.
FC1644  ble.s     FC163A        Loop until priority is lower than new node's.

        ; A0 now points at the node to insert before, or at the end
        ; of the list (i.e. the list header plus 4).

FC1646  move.l    4(A0),D0      Get old value of back pointer
                                (or TailPred pointer of list header).
FC164A  move.l    A1,4(A0)      Change it to point to the new node.
FC164E  move.l    A0,(A1)       Set new node's forward pointer.
FC1650  move.l    D0,4(A1)      Set new node's back pointer to last node
                                skipped, or list header.
FC1654  move.l    D0,A0
FC1656  move.l    A1,(A0)       Set list's head field, or forward pointer
                                of previous node, to new node.
FC1658  rts       


---------------------------------------------------------------------------
  node = FindName( start, name )
  D0               A0     A1
---------------------------------------------------------------------------

FC165A  move.l    A2,-(SP)
FC165C  move.l    A0,A2             Point to list header or first node.
FC165E  move.l    A1,D1             Save address of match string in D1.
FC1660  move.l    (A2),D0
FC1662  beq.s     FC167C            Exit if list is empty.

        ; Main loop:  Check if node pointed to by D0 has the same name
        ; as the string pointed to by D1.

FC1664  move.l    D0,A2             Get the address of the node to check.
FC1666  move.l    (A2),D0
FC1668  beq.s     FC167C            Exit if this is the end of the list.

FC166A  move.l    $0A(A2),A0        Point A0 at name of this node.
FC166E  move.l    D1,A1             Point A1 at match string.

        ; Inner loop:  Compare the strings.

FC1670  cmpm.b    (A0)+,(A1)+       Compare one character.
FC1672  bne.s     FC1664            Skip to next node if not equal.
FC1674  tst.b     -1(A0)            Was this the terminating zero?
FC1678  bne.s     FC1670            Continue comparing if not.

FC167A  move.l    A2,D0             Got a match - point D0 to the node.

FC167C  move.l    D1,A1             Restore registers and exit.
FC167E  move.l    (SP)+,A2
FC1680  rts       

        ; Protected enqueue and dequeue routines
        ; --------------------------------------

FC1682  addq.b    #1,$0127(A6)      Forbid()
FC1686  bsr.s     FC1634            Enqueue()
FC1688  jsr       -$8A(A6)          Permit()
FC168C  rts       

FC168E  addq.b    #1,$0127(A6)      Forbid()
FC1692  bsr       FC1600            Remove()
FC1696  jsr       -$8A(A6)          Permit()
FC169A  rts       


---------------------------------------------------------------------------
  memoryBlock = Allocate( freeList, byteSize )
  D0                      A0        D0
---------------------------------------------------------------------------

FC169C  tst.l     D0                Zero bytes requested?
FC169E  beq.s     FC16EC            If so, just return.
FC16A0  movem.l   D3/A2/A3,-(SP)
FC16A4  addq.l    #7,D0             Round D0 up to nearest multiple of 8.
FC16A6  and.b     #$F8,D0
FC16AA  moveq     #0,D3
FC16AC  cmp.l     $1C(A0),D0        Compare D0 to total number of bytes free.
FC16B0  bhi       FC16E6            If greater, return zero.
FC16B4  lea       $10(A0),A2        Point at the link to the first MemChunk.

        ; Loop:  Scan the free list for a MemChunk big enough to satisfy
        ; the request.

FC16B8  move.l    (A2),D3           Get the pointer to the next MemChunk.
FC16BA  beq.s     FC16E6            If no more MemChunks, return zero.
FC16BC  move.l    D3,A1
FC16BE  cmp.l     4(A1),D0          Check D0 against size of this chunk.
FC16C2  bls.s     FC16C8            If smaller or equal, take it.
FC16C4  move.l    A1,A2             Otherwise, go to next MemChunk.
FC16C6  bra.s     FC16B8            Continue searching.

        ; This is where memory fragmentation occurs.  If the block we've
        ; found is bigger than what we need, we take what we need and make
        ; a smaller block out of the rest.

FC16C8  beq.s     FC16DE            If sizes are not the same, then
FC16CA  lea       0(A1,D0.l),A3       Compute address of leftover block.
FC16CE  move.l    (A1),(A3)           Move the MemChunk pointer up.
FC16D0  move.l    4(A1),D3            Get the current size.
FC16D4  sub.l     D0,D3               Subtract the allocated amount.
FC16D6  move.l    D3,4(A3)            Put it into the new MemChunk.
FC16DA  move.l    A3,(A2)             Link to previous MemChunk (or header).
FC16DC  bra.s     FC16E0            Else
FC16DE  move.l    (A1),(A2)           Unlink this MemChunk.
                                    Endif
FC16E0  sub.l     D0,$1C(A0)        Decrease free memory value in header.
FC16E4  move.l    A1,D3             Get address of allocated block.

FC16E6  move.l    D3,D0             Return zero or address of block.
FC16E8  movem.l   (SP)+,D3/A2/A3
FC16EC  rts       

        ; Routine to put up a "Corrupt Free List" dead-end alert.

FC16EE  movem.l   D7/A5/A6,-(SP)
FC16F2  move.l    #$81000005,D7     Alert number.
FC16F8  move.l    4,A6              Get ExecBase.
FC16FC  jsr       -$6C(A6)          Put up the alert.
FC1700  movem.l   (SP)+,D7/A5/A6    Never reached.


---------------------------------------------------------------------------
  Deallocate( freeList, memoryBlock, byteSize )
              A0        A1           D0
---------------------------------------------------------------------------

FC1704  tst.l     D0                See if byte size is zero.
FC1706  beq.s     FC177C            Do nothing if so.
FC1708  movem.l   D3/A2,-(SP)
FC170C  move.l    A1,D1
FC170E  moveq     #-8,D3            Truncate block address to nearest
FC1710  and.l     D3,D1             multiple of 8.
FC1712  exg       A1,D1             Find out by how much that decreased
FC1714  sub.l     A1,D1             the address, then add this amount to
FC1716  add.l     D1,D0             the number of bytes to free.
FC1718  addq.l    #7,D0             Now round number of bytes to free up to
FC171A  and.l     D3,D0             nearest multiple of 8.
FC171C  beq       FC1778            Exit if the result is zero bytes.

        ; Block address and size are now nice multiples of 8, so we can
        ; go ahead and put the block into the free list.

FC1720  lea       $10(A0),A2        Point at the link to the first MemChunk.
FC1724  move.l    (A2),D3           Get the address of the first MemChunk.
FC1726  beq.s     FC1748            Branch if there are no MemChunks.

        ; Main loop: Find the first MemChunk with an address greater than
        ; that of our memory block.

FC1728  cmp.l     D3,A1             Compare addresses.
FC172A  bcs.s     FC1734            Exit loop if right MemChunk found.
FC172C  beq.s     FC177E            If addresses are equal, guru time!
FC172E  move.l    D3,A2
FC1730  move.l    (A2),D3           Get address of next MemChunk.
FC1732  bne.s     FC1728            Continue searching.

        ; A2 now points at the link which comes directly before the position
        ; where our block must be inserted.  First, we check whether this
        ; is the start of the list.  If so, we just link it in.

FC1734  moveq     #$10,D1           Compute address of MemHeader's link.
FC1736  add.l     A0,D1
FC1738  cmp.l     A2,D1             See if A2 still points there.
FC173A  beq.s     FC1748            If so, insert block at head of the list.

        ; We are somewhere other than at the start of the list.  It is
        ; possible that we can join the block to the previous MemChunk.
        ; Try this now.

FC173C  move.l    4(A2),D3          Compute first address after the
FC1740  add.l     A2,D3             previous MemChunk.
FC1742  cmp.l     A1,D3             Compare to address of our new block.
FC1744  beq.s     FC1752            If equal, join the two together.
FC1746  bhi.s     FC177E            If greater, free list is corrupt.

        ; Enter here to make a new MemChunk and link it into the free list.

FC1748  move.l    (A2),(A1)         Set new MemChunk's link field.
FC174A  move.l    A1,(A2)           Point previous link at the MemChunk.
FC174C  move.l    D0,4(A1)          Put the block size into the MemChunk.
FC1750  bra.s     FC1758

        ; Enter here to attach the new block to the previous MemChunk.

FC1752  add.l     D0,4(A2)          Add to previous MemChunk's size.
FC1756  move.l    A2,A1             Back pointer up to that MemChunk.

        ; Now the block is taken care of.  Either we have built a MemChunk
        ; for it, or we have attached it to a MemChunk directly before the
        ; block.  Either way, the address of the MemChunk where the block
        ; now is is in A1.  It remains to check whether we can join this
        ; MemChunk with the next one down the line.

FC1758  tst.l     (A1)              See if there is a next MemChunk.
FC175A  beq.s     FC1774            Exit if not.
FC175C  move.l    4(A1),D3          Get our MemChunk's size.
FC1760  add.l     A1,D3             Add to its base address.
FC1762  cmp.l     (A1),D3           Compare to address of next MemChunk.
FC1764  bhi.s     FC177E            If higher, free list is corrupt.
FC1766  bne.s     FC1774            If not equal, we can't join them.

        ; If we get this far, we can join this MemChunk to the next one down
        ; the line, so we delete the next one and add its size to this one.

FC1768  move.l    (A1),A2           Get pointer to next MemChunk.
FC176A  move.l    (A2),(A1)         Fetch its link and put in our MemChunk.
FC176C  move.l    4(A2),D3          Get its size.
FC1770  add.l     D3,4(A1)          Add to size of our MemChunk.

        ; This is where all the paths meet again.

FC1774  add.l     D0,$1C(A0)        Add size of freed block to free counter.
FC1778  movem.l   (SP)+,D3/A2
FC177C  rts       

        ; Error exit routine.  Generate a dead-end alert.

FC177E  movem.l   D7/A5/A6,-(SP)
FC1782  move.l    #$81000009,D7     Alert number.
FC1788  move.l    4,A6              Get ExecBase.
FC178C  jsr       -$6C(A6)          Go put up the alert.
FC1790  movem.l   (SP)+,D7/A5/A6    Never reached.


---------------------------------------------------------------------------
  memoryBlock = AllocMem( byteSize, requirements )
  D0                      D0        D1
---------------------------------------------------------------------------

        ; NOTE: Some other part of the system, presumably DOS, will patch
        ; itself in ahead of this, presumably so it can throw out unused
        ; libraries, devices, fonts, etc. when memory runs low.

FC1794  addq.b    #1,$0127(A6)      Forbid()
FC1798  movem.l   D2/D3/A2,-(SP)
FC179C  move.l    D0,D3
FC179E  move.l    D1,D2
FC17A0  lea       $0142(A6),A2      Point to the system free memory list.

        ; Loop:  Step through the system free memory list looking for
        ; a MemHeader which can satisfy the memory request.

FC17A4  move.l    (A2),A2           Get pointer to a MemHeader.
FC17A6  tst.l     (A2)              End of memory list reached?
FC17A8  bne.s     FC17AE
FC17AA  moveq     #0,D0             If so, return a null pointer and exit.
FC17AC  bra.s     FC17E6
FC17AE  move.w    $0E(A2),D0        Get the MemHeader's attributes.
FC17B2  and.w     D2,D0             Check against needed attributes.
FC17B4  cmp.w     D2,D0
FC17B6  bne.s     FC17A4            Go to next MemHeader if not present.

        ; The current MemHeader has the right attribute flags, now try
        ; to get a block of the required size out of its free list.

FC17B8  move.l    A2,A0             Point to the MemHeader.
FC17BA  move.l    D3,D0             Indicate size of block required.
FC17BC  bsr       FC169C            Allocate()
FC17C0  tst.l     D0                Did we get the memory?
FC17C2  beq.s     FC17A4            If not, go to next MemHeader.

        ; We got a memory block.  Clear it if necessary.

FC17C4  btst      #$10,D2           Was the MEMF_CLEAR flag set?
FC17C8  beq.s     FC17E6            Just return if not.
FC17CA  moveq     #0,D1
FC17CC  addq.l    #3,D3             Convert number of bytes to nearest number
FC17CE  lsr.l     #2,D3             of longwords.
FC17D0  move.l    D0,A0             Point to the memory block.
FC17D2  bra.s     FC17D6            Enter the loop at the bottom.

        ; Loop: Clear the memory block.

FC17D4  move.l    D1,(A0)+          Clear one longword.
FC17D6  dbra      D3,FC17D4(PC)     Loop back until none remain.

FC17DA  swap      D3                DBRA instruction only uses low 16 bits
FC17DC  tst.w     D3                as program counter, so if any remain
FC17DE  beq.s     FC17E6            set in the upper half of D3, decrement
FC17E0  subq.w    #1,D3             them manually and loop back.
FC17E2  swap      D3
FC17E4  bra.s     FC17D4

FC17E6  jsr       -$8A(A6)          Permit()
FC17EA  movem.l   (SP)+,D2/D3/A2
FC17EE  rts       


---------------------------------------------------------------------------
  FreeMem( memoryBlock, byteSize )
           A1           D0
---------------------------------------------------------------------------

FC17F0  addq.b    #1,$0127(A6)      Forbid()
FC17F4  tst.l     D0                Is number of bytes to free zero?
FC17F6  beq.s     FC1814            If so, just exit.
FC17F8  lea       $0142(A6),A0      Point to system free memory list.

        ; Loop: Look for the right MemHeader to put the block back into.

FC17FC  move.l    (A0),A0           Point to the next MemHeader.
FC17FE  tst.l     (A0)              End of list reached?

        ; If no MemHeader can be found to put this block on, something
        ; is wrong, so it's guru time.

FC1800  beq       FC16EE            Guru time if end of list reached.

        ; See if the block falls into the address range covered by this
        ; MemHeader.

FC1804  cmp.l     $14(A0),A1        Does block start before mh_Lower?
FC1808  bcs.s     FC17FC            If so, try next MemHeader.
FC180A  cmp.l     $18(A0),A1        Does block start after mh_Upper?
FC180E  bcc.s     FC17FC            If so, try next MemHeader.

        ; The block belongs to this MemHeader, so go link it back into
        ; the free list.

FC1810  bsr       FC1704            Deallocate()
FC1814  jsr       -$8A(A6)          Permit()
FC1818  rts       


---------------------------------------------------------------------------
  attributes = TypeOfMem( address )
  D0                      A1
---------------------------------------------------------------------------

FC181A  addq.b    #1,$0127(A6)      Forbid()
FC181E  lea       $0142(A6),A0      Point to system free memory list.
FC1822  moveq     #0,D0
FC1824  move.l    (A0),A0           Point to next MemHeader.
FC1826  tst.l     (A0)              End of list reached?
FC1828  beq.s     FC183A            If so, return zero and exit.
FC182A  cmp.l     $14(A0),A1        Check if the block is in the address
FC182E  bcs.s     FC1824            range covered by this MemHeader.
FC1830  cmp.l     $18(A0),A1
FC1834  bcc.s     FC1824            If it is, return the contents of the
FC1836  move.w    $0E(A0),D0        MemHeader's attribute field.
FC183A  jsr       -$8A(A6)          Permit()
FC183E  rts       


---------------------------------------------------------------------------
  memoryBlock = AllocAbs( byteSize, location )
  D0                      D0        A1
---------------------------------------------------------------------------

FC1840  addq.b    #1,$0127(A6)      Forbid()
FC1844  movem.l   D2-D4/A2/A3,-(SP)
FC1848  move.l    A1,D2             Get the start address.
FC184A  and.l     #$000007,D2       Truncate down to nearest multiple of 8.
FC1850  sub.l     D2,A1
FC1852  add.l     D2,D0             Add any difference to number of bytes
FC1854  addq.l    #7,D0             wanted, then round number of bytes
FC1856  and.b     #$F8,D0           up to nearest multiple of 8.
FC185A  lea       $0142(A6),A0      Point to the system free memory list.

        ; Loop: Scan through all the MemHeaders in the free list.

FC185E  move.l    (A0),A0           Point to next MemHeader.
FC1860  tst.l     (A0)              End of list reached?
FC1862  beq.s     FC18CC            If so, allocation failed, return zero.

        ; Check whether the block we want is covered by this MemHeader.

FC1864  cmp.l     $14(A0),A1        If block starts before this MemHeader's
FC1868  bcs.s     FC185E            area, go on to the next one.
FC186A  cmp.l     $18(A0),A1        If block starts after this MemHeader's
FC186E  bcc.s     FC185E            area, go on to next one.

        ; The desired block starts in the address range covered by this
        ; MemHeader, so it's either this one or nothing.

        ; Quick check:  If the total number of bytes free in this MemHeader's
        ; free list is less than the size of the block wanted, then the
        ; allocation is going to fail anyway.

FC1870  cmp.l     $1C(A0),D0         Check block size against mh_Free.
FC1874  bhi.s     FC18CC             Allocation failed if higher.
FC1876  move.l    A1,A3              Get start address of block wanted.
FC1878  move.l    A1,D2
FC187A  add.l     D0,D2              Compute end address of block wanted.
FC187C  lea       $10(A0),A2         Point to link to first MemChunk.

        ; Loop:  Find the MemChunk in the free list which contains the
        ; wanted block.

FC1880  move.l    (A2),D3            Get pointer to next MemChunk.
FC1882  beq.s     FC18CC             Allocation failed if no more MemChunks.
FC1884  move.l    D3,A1
FC1886  move.l    4(A1),D4           Get the MemChunk's size.
FC188A  add.l     D3,D4              Compute its end address.
FC188C  cmp.l     D2,D4              Check against needed end address.
FC188E  bcc.s     FC1894             Exit loop if equal or higher.
FC1890  move.l    A1,A2
FC1892  bra.s     FC1880             Go to the next MemChunk.

        ; We have a MemChunk whose end address is greater than or equal
        ; to the end address of the block we want.  It's either this
        ; MemChunk or none at all.

FC1894  cmp.l     A3,D3              Check start addresses.
FC1896  bhi.s     FC18CC             Allocation failed if needed block
                                     starts before this MemChunk.

        ; The block we want is entirely within this MemChunk, so now we
        ; cut it out and make zero, one or two MemChunks out of what's left.

FC1898  sub.l     D0,$1C(A0)         Remove block size from free count.
FC189C  sub.l     D2,D4              Compare end addresses.
FC189E  bne.s     FC18A4

        ; The end addresses of the allocated block and the MemChunk it
        ; was in were exactly equal.

FC18A0  move.l    (A1),A0
FC18A2  bra.s     FC18B0

        ; Memory was left over between the allocated block and the end of
        ; the MemChunk.  Make a new MemChunk out of this and link it into
        ; the free list.

FC18A4  lea       0(A3,D0.l),A0      Compute base address of new MemChunk.
FC18A8  move.l    (A1),(A0)          Store pointer to next MemChunk.
FC18AA  move.l    A0,(A1)            Link to previous MemChunk.
FC18AC  move.l    D4,4(A0)           Store number of bytes in MemChunk.

        ; At this point, whatever was left after the block was taken
        ; care of, and a pointer to the next MemChunk after the block is
        ; in A0.

FC18B0  cmp.l     A3,D3              Compare start addresses.
FC18B2  beq.s     FC18BE

        ; The block started after the beginning of this MemChunk, so we
        ; just truncate the MemChunk to contain the leftover memory before
        ; the allocated block.

FC18B4  sub.l     A3,D3
FC18B6  neg.l     D3                 Compute remaining size.
FC18B8  move.l    D3,4(A1)           Store in the MemChunk.
FC18BC  bra.s     FC18C0             All done.

        ; The block started exactly at the beginning of the MemChunk, so
        ; the MemChunk must be deleted.

FC18BE  move.l    A0,(A2)            Unlink this MemChunk from the chain.
FC18C0  move.l    A3,D0              Return address of allocated block.
FC18C2  movem.l   (SP)+,D2-D4/A2/A3
FC18C6  jsr       -$8A(A6)           Permit()
FC18CA  rts       

FC18CC  moveq     #0,D0              Return zero if allocation failed.
FC18CE  bra.s     FC18C2


---------------------------------------------------------------------------
  size = AvailMem( requirements )
  D0               D1
---------------------------------------------------------------------------

FC18D0  movem.l   D3/A2,-(SP)
FC18D4  moveq     #0,D3             Initialize free memory counter.
FC18D6  lea       $0142(A6),A1      Point at the ExecBase->MemList.
FC18DA  addq.b    #1,$0127(A6)      Forbid()
FC18DE  move.l    (A1),A1
FC18E0  tst.l     (A1)              Get address of first MemHeader.
FC18E2  beq.s     FC1912            Exit if list is empty.
FC18E4  move.w    $0E(A1),D0        Get this MemHeader's attributes.
FC18E8  and.w     D1,D0             Mask with required attributes.
FC18EA  cmp.w     D1,D0             Check if all attributes are satisfied.
FC18EC  bne.s     FC18DE            Go to next MemHeader if not.
FC18EE  btst      #$11,D1           Are we looking for the largest
                                    contiguous block of memory?
FC18F2  bne.s     FC18FA
FC18F4  add.l     $1C(A1),D3        If not, just add the size,
FC18F8  bra.s     FC18DE            and loop back.

        ; We are looking for the largest contiguous block of memory.

FC18FA  move.l    $10(A1),D0        Get address of first MemChunk.
FC18FE  beq.s     FC18DE            Loop back if there is no MemChunk.
FC1900  move.l    D0,A0
FC1902  cmp.l     4(A0),D3          See if this MemChunk is the biggest yet.
FC1906  bge.s     FC190E
FC1908  move.l    A0,A2             If it is, keep its base address (why?),
FC190A  move.l    4(A0),D3          and its size.
FC190E  move.l    (A0),D0
FC1910  bra.s     FC18FE            Go to next MemChunk.
FC1912  jsr       -$8A(A6)          Permit()
FC1916  move.l    D3,D0             Return the accumulated or largest size.
FC1918  movem.l   (SP)+,D3/A2
FC191C  rts       


---------------------------------------------------------------------------
  memList = AllocEntry( memList )
  D0                    A0
---------------------------------------------------------------------------

FC191E  movem.l   D2/D3/A2/A3,-(SP)
FC1922  move.l    A0,A2             Save pointer to request MemList.
FC1924  moveq     #0,D2             Clear loop counter.
FC1926  moveq     #0,D3
FC1928  move.w    $0E(A2),D3        Get the number of MemEntries.
FC192C  move.l    D3,D0
FC192E  lsl.l     #3,D0             Compute the size of the MemList needed
FC1930  add.l     #$000010,D0       to keep track of the MemEntries.
FC1936  move.l    #$010000,D1       Set MEMF_CLEAR.
FC193C  jsr       -$C6(A6)          Allocate that amount of memory.
FC1940  tst.l     D0                If we didn't get it, go exit.
FC1942  beq.s     FC19A2
FC1944  move.l    D0,A3             Point to base of new MemList structure.
FC1946  move.w    D3,$0E(A3)        Put in the number of MemEntries.
FC194A  lea       $10(A2),A2        Point to MemEntries in request MemList.
FC194E  lea       $10(A3),A3        Point to MemEntries in result MemList.
                                    For each MemEntry do
FC1952  move.l    0(A2),D1            Get its required attributes.
FC1956  move.l    4(A2),D0            Get its required size.
FC195A  move.l    D0,4(A3)            Store the size in the result list.
FC195E  beq.s     FC1968              If size is not zero then
FC1960  jsr       -$C6(A6)              Allocate the memory.
FC1964  tst.l     D0                    Go exit if unsuccessful.
FC1966  beq.s     FC198A              Endif
FC1968  move.l    D0,0(A3)            Store memory address in result list.
FC196C  addq.l    #8,A2               Go to next request MemEntry.
FC196E  addq.l    #8,A3               Go to next result MemEntry.
FC1970  addq.l    #1,D2               Increment loop counter.
FC1972  cmp.l     D2,D3               Compare to number of MemEntries.
FC1974  bgt.s     FC1952            Endfor.
FC1976  lsl.l     #3,D2
FC1978  neg.l     D2                Compute -(size of MemEntry list).
FC197A  lea       -$10(A2,D2.l),A2  Point A2 back at the request MemList.
FC197E  lea       -$10(A3,D2.l),A3  Point A3 back at the result MemList.
FC1982  move.l    A3,D0             Return the address of the result MemList.
FC1984  movem.l   (SP)+,D2/D3/A2/A3
FC1988  rts       

        ; Enter here if one of the MemEntries could not be allocated.

FC198A  move.l    D1,D3             Save size of the allocate which failed.
FC198C  tst.l     D2                Test number of allocated MemEntries.
FC198E  beq.s     FC19A4            Exit if none remaining.
FC1990  subq.l    #1,D2             Decrement number of MemEntries.
FC1992  subq.l    #8,A3             Point to the allocated MemEntry.
FC1994  move.l    0(A3),A1          Get the address and size of the block
FC1998  move.l    4(A3),D0          corresponding to it.
FC199C  jsr       -$D2(A6)          Deallocate the block.
FC19A0  bra.s     FC198C            Go back and check for more MemEntries.

        ; Enter here if the AllocEntry failed, after deallocating anything
        ; which was allocated before the failure.

FC19A2  move.l    D1,D3             Get size of the allocate which failed.
FC19A4  move.l    D3,D0
FC19A6  bset      #$1F,D0           Set the high bit.
FC19AA  bra.s     FC1984            Return it to the user.


---------------------------------------------------------------------------
  FreeEntry( memList )
             A0
---------------------------------------------------------------------------

FC19AC  movem.l   D2/A2/A3,-(SP)
FC19B0  move.l    A0,A2             Point to the MemList.
FC19B2  lea       $10(A2),A3        Point to the first MemEntry.
FC19B6  move.w    $0E(A2),D2        Get number of MemEntries.
FC19BA  bra.s     FC19CC            For each MemEntry in the MemList do
FC19BC  move.l    0(A3),A1            Get the address of the memory block.
FC19C0  move.l    4(A3),D0            Get the sizde of the memory block.
FC19C4  beq.s     FC19CA              If size is not zero then
FC19C6  jsr       -$D2(A6)              Deallocate the block.
FC19CA  addq.l    #8,A3               Endif
FC19CC  dbra      D2,FC19BC(PC)     Endfor
FC19D0  moveq     #0,D0
FC19D2  move.w    $0E(A2),D0        Get the number of MemEntries again.
FC19D6  lsl.l     #3,D0
FC19D8  add.l     #$000010,D0       Compute the size of the MemList.
FC19DE  move.l    A2,A1             Point to the base of the MemList.
FC19E0  jsr       -$D2(A6)          Deallocate it.
FC19E4  movem.l   (SP)+,D2/A2/A3
FC19E8  rts       


---------------------------------------------------------------------------
  error = AddMemList( size, attributes, pri, base, name )
  D0                  D0    D1          D2   A0    A1
---------------------------------------------------------------------------

        ; This routine takes a block of memory, builds a MemHeader at the
        ; start of it, and puts the rest of the block into the MemHeader's
        ; free list.  Then it adds the MemHeader to the system free memory
        ; list.

FC19EA  move.l    A1,$0A(A0)        Store the name in the MemHeader.
FC19EE  lea       $20(A0),A1        Compute first address after MemHeader.
FC19F2  move.b    #$0A,8(A0)        MemHeader's node type is NT_MEMORY.
FC19F8  move.b    D2,9(A0)          Set the MemHeader's priority.
FC19FC  move.w    D1,$0E(A0)        Set the memory attributes.
FC1A00  move.l    A1,D1
FC1A02  addq.l    #7,D1             Round the base address of the block up
FC1A04  and.b     #$F8,D1           to the nearest multiple of 8.
FC1A08  exg       A1,D1
FC1A0A  sub.l     A1,D1             Compute by how much it changed,
FC1A0C  add.l     D1,D0             and add this amount to the length.
FC1A0E  and.b     #$F8,D0           Truncate the length to a multiple of 8.
FC1A12  sub.l     #$000020,D0       Subtract the size of the MemHeader.
FC1A18  move.l    A1,$10(A0)        Store base address as lower bound of
FC1A1C  move.l    A1,$14(A0)        memory and link to first MemChunk.
FC1A20  move.l    A1,D1
FC1A22  add.l     D0,D1             Compute upper bound address.
FC1A24  move.l    D1,$18(A0)        Store it in the MemHeader.
FC1A28  move.l    D0,$1C(A0)        Store the amount of free memory.
FC1A2C  move.l    D0,4(A1)          Build a MemChunk at the start of free
FC1A30  clr.l     (A1)              memory (clear link, store size).
FC1A32  move.l    A0,A1             Get base address of MemHeader
FC1A34  lea       $0142(A6),A0      Point to the system free memory list.
FC1A38  bsr       FC1682            Put the MemHeader on the list.
FC1A3C  rts       

FC1A3E  0000                        Padding.


        ; Data table used to build the exec jump vector table.

        ; There are 105 entries, corresponding to the 105 exec functions,
        ; followed by a -1 table end marker.  Each entry is a 16-bit
        ; relative offset from the start of the table.

FC1A40 08A008A8 08AC08AC EE6AF420 F44604F8
FC1A50 F4A0F4EA F58EF0B0 F188FAAC FB36F080
FC1A60 F0E81596 08EEF9AC F9BA051A 0520F6E2
FC1A70 F708F734 F74EF794 F7D4F8E0 FC5CFCC4
FC1A80 FD54FE00 FDB0FE90 FEDEFF6C FB6CFB98
FC1A90 FBA8FBC0 FBCEFBDE FBF4FC1A 020802B4
FC1AA0 03340388 03E203D8 04900408 058405BC
FC1AB0 054E0574 00D800F0 00F4016E 019C01B6
FC1AC0 01DEF9CC F9DAF9F0 FA26FA3A FA58EC14
FC1AD0 EC22EC26 EC74EC9C EC8AED0E ECB2ED2A
FC1AE0 01E801F0 01F407B8 07C207EE 06A8F700
FC1AF0 FDDA131C 1332F9F8 13541374 13C41428
FC1B00 145814CE 14F414E4 14F0EFFC FFAA1504
FC1B10 1500

FC1B12 FFFF                         End of table marker.

FC1B14 FFFF                         Looks like garbage.
FC1B16 0000


---------------------------------------------------------------------------
  AddPort( port )
           A1
---------------------------------------------------------------------------

FC1B18  lea       $14(A1),A0        Address of port's message list.
FC1B1C  move.l    A0,(A0)           Initialize the list's head pointer.
FC1B1E  addq.l    #4,(A0)
FC1B20  clr.l     4(A0)             Initialize the list's Tail field.
FC1B24  move.l    A0,8(A0)          Initialize the list's TailPred pointer.
FC1B28  lea       $0188(A6),A0      Address of the public message port list.
FC1B2C  bra       FC1682            Safely add port to the list.


---------------------------------------------------------------------------
  RemPort( port )
           A1
---------------------------------------------------------------------------

        ; Call a general purpose subroutine which unlinks something from
        ; its queue while disabling multitasking.

FC1B30  bra       FC168E


---------------------------------------------------------------------------
  PutMsg( port, message )
          A0    A1
---------------------------------------------------------------------------

FC1B34  move.b    #5,8(A1)          Make sure message node type is NT_MESSAGE
FC1B3A  move.l    A0,D1
FC1B3C  lea       $14(A0),A0        Compute address of port's message list

FC1B40  move.w    #$4000,DFF09A     Disable()
FC1B48  addq.b    #1,$0126(A6)

        ; Enqueue the message at the end of the port's message list

FC1B4C  lea       4(A0),A0          Point A0 at port's Tail field.
FC1B50  move.l    4(A0),D0          Save pointer to last node in list
FC1B54  move.l    A1,4(A0)          Make new node the last node
FC1B58  move.l    A0,(A1)           New node has no next node
FC1B5A  move.l    D0,4(A1)          Link new node back to old last node
FC1B5E  move.l    D0,A0
FC1B60  move.l    A1,(A0)           Link old last node to new node

        ; Do whatever needs to be done on message arrival.

FC1B62  move.l    D1,A1
FC1B64  move.l    $10(A1),D1        Get address of message port's task.
FC1B68  beq.s     FC1B9E            Exit if port has no task.

FC1B6A  move.b    $0E(A1),D0        Get port's flag bits.
FC1B6E  and.w     #3,D0
FC1B72  beq.s     FC1B8E            Decode the flag bits.
FC1B74  cmp.b     #1,D0
FC1B78  bne.s     FC1B82

        ; Processing for PA_SOFTINT

FC1B7A  move.l    D1,A1
FC1B7C  jsr       -$B4(A6)          Cause the software interrupt.
FC1B80  bra.s     FC1B9E

        ; If PA_IGNORE, do nothing.

FC1B82  cmp.b     #2,D0
FC1B86  beq.s     FC1B9E

        ; (Undocumented?) processing for mp_Flags = 3.  Apparently,
        ; calls a subroutine at mp_SigTask.

FC1B88  move.l    D1,A0
FC1B8A  jsr       (A0)
FC1B8C  bra.s     FC1B9E

        ; Processing for PA_SIGNAL

FC1B8E  move.b    $0F(A1),D0        Get SigBit.
FC1B92  move.l    D1,A1
FC1B94  moveq     #0,D1             Compute corresponding signal mask.
FC1B96  bset      D0,D1
FC1B98  move.l    D1,D0
FC1B9A  jsr       -$0144(A6)        Signal the task.

FC1B9E  subq.b    #1,$0126(A6)      Enable()
FC1BA2  bge.s     FC1BAC
FC1BA4  move.w    #$C000,DFF09A
FC1BAC  rts       


---------------------------------------------------------------------------
  message = GetMsg( port )
  D0                A0
---------------------------------------------------------------------------

FC1BAE  lea       $14(A0),A0        Point A0 at head of port's message list.

FC1BB2  move.w    #$4000,DFF09A     Disable()
FC1BBA  addq.b    #1,$0126(A6)

        ; Try to dequeue a message from the message list.

FC1BBE  move.l    (A0),A1           Get head pointer into A1.
FC1BC0  move.l    (A1),D0
FC1BC2  beq.s     FC1BCC            If list is empty, just return zero.
FC1BC4  move.l    D0,(A0)
FC1BC6  exg       A1,D0             Unlink the message from the list.
FC1BC8  move.l    A0,4(A1)

        ; Reenable interrupts if necessary and exit.

FC1BCC  subq.b    #1,$0126(A6)      Enable()
FC1BD0  bge.s     FC1BDA
FC1BD2  move.w    #$C000,DFF09A
FC1BDA  rts       


---------------------------------------------------------------------------
  ReplyMsg( message )
            A1
---------------------------------------------------------------------------

FC1BDC  move.l    $0E(A1),D0        Get address of reply port.
FC1BE0  bne.s     FC1BEA
FC1BE2  move.b    #6,8(A1)          No reply port.  Set node type to
FC1BE8  rts                         NT_FREEMSG and exit.

FC1BEA  move.b    #7,8(A1)          Set node type to NT_REPLYMSG.
FC1BF0  move.l    D0,A0
FC1BF2  bra       FC1B3A            Send the message via the reply port.


---------------------------------------------------------------------------
  message = WaitPort( port )
  D0                  A0
---------------------------------------------------------------------------

FC1BF6  move.l    $14(A0),A1        Get head pointer of port's message list.
FC1BFA  tst.l     (A1)              Check if list is empty.
FC1BFC  bne.s     FC1C1A            If not empty, return right away.

FC1BFE  move.b    $0F(A0),D1        List was empty.  Get signal bit.
FC1C02  lea       $14(A0),A0        Point A0 at message list.
FC1C06  moveq     #0,D0
FC1C08  bset      D1,D0             Compute signal mask.
FC1C0A  move.l    A2,-(SP)
FC1C0C  move.l    A0,A2
FC1C0E  jsr       -$013E(A6)        Wait()
FC1C12  move.l    (A2),A1
FC1C14  tst.l     (A1)              Check message list.
FC1C16  beq.s     FC1C0E            If still empty, go back and wait again.
FC1C18  move.l    (SP)+,A2
FC1C1A  move.l    A1,D0             Return first message in the list.
FC1C1C  rts       


---------------------------------------------------------------------------
  port = FindPort( name )
  D0               A1
---------------------------------------------------------------------------

FC1C1E  lea       $0188(A6),A0      Point to the public port list.
FC1C22  jsr       -$0114(A6)        Search it for a port of the given name.
FC1C26  rts       


---------------------------------------------------------------------------
  AddResource( resource )
               A1
---------------------------------------------------------------------------

FC1C28  lea       $0150(A6),A0      Point to the resource list.
FC1C2C  bra       FC1682            Add the resource to the list.


---------------------------------------------------------------------------
  RemResource( resource )
               A1
---------------------------------------------------------------------------

FC1C30  bra       FC168E            Unlink the resource from the list.


---------------------------------------------------------------------------
  resource = OpenResource( resName )
  D0                       A1
---------------------------------------------------------------------------

FC1C34  lea       $0150(A6),A0      Point to the resource list.
FC1C38  addq.b    #1,$0127(A6)      Forbid()
FC1C3C  bsr       FC165A            FindName()
FC1C40  jsr       -$8A(A6)          Permit()
FC1C44  rts       


FC1C46  0000                        Padding.

---------------------------------------------------------------------------
  AddTask( task, initialPC, finalPC )
           A1    A2         A3
---------------------------------------------------------------------------

FC1C48  moveq     #0,D1
FC1C4A  move.b    #1,$0F(A1)        Make the task state TS_ADDED.
FC1C50  move.b    D1,$0E(A1)        Clear the task's flags.
FC1C54  move.w    #$FFFF,$10(A1)    Set IDNestCnt and TDNestCnt to -1.
FC1C5A  move.l    $013C(A6),$12(A1)
FC1C60  move.l    D1,$16(A1)        Task is not waiting for any signals.
FC1C64  move.l    D1,$1A(A1)        Task has not received any signals.
FC1C68  move.l    D1,$1E(A1)        Task does not have any exception signals.
FC1C6C  move.w    $0140(A6),$22(A1) Set allocated traps.
FC1C72  move.w    D1,$24(A1)        No traps are enabled.

FC1C76  tst.l     $32(A1)           Install default system exception handler
FC1C7A  bne.s     FC1C82            if the user has not provided one.
FC1C7C  move.l    $0130(A6),$32(A1)
FC1C82  tst.l     $2A(A1)
FC1C86  bne.s     FC1C8E
FC1C88  move.l    $0134(A6),$2A(A1)

FC1C8E  move.l    $36(A1),A0        Get the initial stack pointer.
FC1C92  move.l    A3,-(A0)          Put the exit code address on the stack.
FC1C94  bne.s     FC1C9A
FC1C96  move.l    $0138(A6),(A0)    Use system default if no exit code.

FC1C9A  moveq     #$0E,D1           Clear 15 longwords below the process's
FC1C9C  clr.l     -(A0)             initial stack pointer, so all registers
FC1C9E  dbra      D1,FC1C9C(PC)     will be zero when initially loaded.

FC1CA2  clr.w     -(A0)             Clear the initial status register.
FC1CA4  move.l    A2,-(A0)          Put the initial PC on the stack.

FC1CA6  btst      #4,$0129(A6)      If we have a 68881, then put another
FC1CAC  beq.s     FC1CB2            longword on the stack.
FC1CAE  moveq     #0,D0
FC1CB0  move.l    D0,-(A0)
FC1CB2  move.l    A0,$36(A1)        Put the initial stack pointer back.

FC1CB6  lea       $0196(A6),A0
FC1CBA  move.w    #$4000,DFF09A     Disable()
FC1CC2  addq.b    #1,$0126(A6)
FC1CC6  move.b    #3,$0F(A1)        Make the task state TS_READY.
FC1CCC  bsr       FC1634            Put the task on the TaskReady queue.
FC1CD0  move.l    $0196(A6),D0
FC1CD4  subq.b    #1,$0126(A6)      Enable()
FC1CD8  bge.s     FC1CE2
FC1CDA  move.w    #$C000,DFF09A
FC1CE2  cmp.l     A1,D0             If the task ended up at the front of the
FC1CE4  bne.s     FC1CEA            TaskReady queue, then
FC1CE6  jsr       -$30(A6)          Reschedule()
FC1CEA  rts       

        ; System default task exit function
        ; ---------------------------------

FC1CEC  move.l    4,A6              Get ExecBase.
FC1CF0  moveq     #0,D0
FC1CF2  move.l    D0,A1             Ask for current task to be removed.

        ; fall through into RemTask.


---------------------------------------------------------------------------
  RemTask( task )
           A1
---------------------------------------------------------------------------

FC1CF4  movem.l   D2/D3,-(SP)
FC1CF8  move.l    A1,D3             Check address of task to be removed.
FC1CFA  bne.s     FC1D02            Branch if not zero.
FC1CFC  move.l    $0114(A6),D3      If zero, use the current task.
FC1D00  bra.s     FC1D26
FC1D02  cmp.l     $0114(A6),A1      If not zero, check if it was the current
FC1D06  beq.s     FC1D26            task anyway.

        ; The following is executed only if the task to be removed is not
        ; the current one.  This is because the currently running task isn't
        ; on a queue anywhere.

FC1D08  move.w    #$4000,DFF09A     Disable()
FC1D10  addq.b    #1,$0126(A6)
FC1D14  bsr       FC1600            Unlink the task from its queue.
FC1D18  subq.b    #1,$0126(A6)
FC1D1C  bge.s     FC1D26            Enable()
FC1D1E  move.w    #$C000,DFF09A

FC1D26  move.l    D3,A1             Get the address of the task back.
FC1D28  move.b    #6,$0F(A1)        Make the task TS_REMOVED.
FC1D2E  cmp.l     $0114(A6),A1      Check if it is the current task.
FC1D32  bne.s     FC1D38
FC1D34  addq.b    #1,$0127(A6)      If so, disable task switching now.

FC1D38  lea       $4A(A1),A0        Point to allocated memory list.
FC1D3C  move.l    (A0),D2
FC1D3E  beq.s     FC1D58            Exit if the head pointer is zero,
FC1D40  cmp.l     8(A0),A0          or if the tail pointer points back at
FC1D44  beq       FC1D58            the list header.
FC1D48  clr.l     (A0)              Zero the list head pointer.

        ; Loop:  Release all the memory blocks which the task had allocated.

FC1D4A  move.l    D2,A0             Get pointer to current list node.
FC1D4C  move.l    (A0),D2           Get pointer to next list node.
FC1D4E  beq       FC1D58            Exit if the end of the list was reached.
FC1D52  jsr       -$E4(A6)          FreeEntry() this list node.
FC1D56  bra.s     FC1D4A            Back to the head of the loop.

FC1D58  cmp.l     $0114(A6),D3      Check if the current task was removed.
FC1D5C  bne.s     FC1D6C            If not, indicate success and exit.
FC1D5E  lea       FC1D66(PC),A5
FC1D62  jmp       -$1E(A6)          Go to supervisor mode.
FC1D66  addq.l    #6,SP             Pop exception data from the stack.
FC1D68  jmp       -$3C(A6)          Dispatch() a new task.

FC1D6C  moveq     #0,D0             If the current task was not removed,
FC1D6E  movem.l   (SP)+,D2/D3       indicate success and return.
FC1D72  rts       


---------------------------------------------------------------------------
  task = FindTask( name )
  D0               A1
---------------------------------------------------------------------------

FC1D74  move.l    A1,D0             See if a name was given.
FC1D76  bne.s     FC1D7E
FC1D78  move.l    $0114(A6),D0      If not, use this task.
FC1D7C  bra.s     FC1DC6
FC1D7E  lea       $0196(A6),A0      Point at the TaskReady queue.
FC1D82  move.w    #$4000,DFF09A     Disable()
FC1D8A  addq.b    #1,$0126(A6)
FC1D8E  jsr       -$0114(A6)        Call FindName() to look for the task.
FC1D92  tst.l     D0                Check if found, return address if so.
FC1D94  bne.s     FC1DB8
FC1D96  lea       $01A4(A6),A0      Task not found, try TaskWait queue.
FC1D9A  jsr       -$0114(A6)        Call FindName() to look for the task.
FC1D9E  tst.l     D0                Check if found, return address if so.
FC1DA0  bne.s     FC1DB8
FC1DA2  move.l    $0114(A6),A0      Still not found, compare name with that
FC1DA6  move.l    $0A(A0),A0        of the current task.
FC1DAA  cmpm.b    (A0)+,(A1)+
FC1DAC  bne.s     FC1DB8            If names differ, return zero (not found).
FC1DAE  tst.b     -1(A0)
FC1DB2  bne.s     FC1DAA
FC1DB4  move.l    $0114(A6),D0      Task was the current task.
FC1DB8  subq.b    #1,$0126(A6)      Enable()
FC1DBC  bge.s     FC1DC6
FC1DBE  move.w    #$C000,DFF09A
FC1DC6  rts       


---------------------------------------------------------------------------
  oldPriority = SetTaskPri( task, priority )
  D0                        A1    D0
---------------------------------------------------------------------------

FC1DC8  move.w    #$4000,DFF09A     Disable()
FC1DD0  addq.b    #1,$0126(A6)
FC1DD4  move.b    9(A1),-(SP)       Save the task's current priority.
FC1DD8  move.b    D0,9(A1)          Set the task's new priority.
FC1DDC  cmp.l     $0114(A6),A1      Check if it was the current task.
FC1DE0  beq.s     FC1E00            If so, go reschedule it.
FC1DE2  cmp.b     #3,$0F(A1)        Check if the task was TS_READY.
FC1DE8  bne.s     FC1E04            If not, we're done.
FC1DEA  move.l    A1,D0
FC1DEC  bsr       FC1600            Take the task out of the TaskReady queue.
FC1DF0  lea       $0196(A6),A0
FC1DF4  move.l    D0,A1             And put it back in the right place
FC1DF6  bsr       FC1634            corresponding to its new priority.
FC1DFA  cmp.l     $0196(A6),A1      See if it ended up at the front.
FC1DFE  bne.s     FC1E04            If not, we're done.

        ; If we get here, either we've changed the priority of the current
        ; task, or we've moved another task to the front of the TaskReady
        ; queue.  Either way, we have to check if the current task should
        ; be preempted.

FC1E00  jsr       -$30(A6)          Reschedule()
FC1E04  subq.b    #1,$0126(A6)
FC1E08  bge.s     FC1E12            Enable()
FC1E0A  move.w    #$C000,DFF09A
FC1E12  moveq     #0,D0
FC1E14  move.b    (SP)+,D0          Return the previous priority.
FC1E16  rts       


---------------------------------------------------------------------------
  oldSignals = SetExcept( newSignals, signalMask )
  D0                      D0          D1
---------------------------------------------------------------------------

FC1E18  move.l    $0114(A6),A1      Get pointer to current task.
FC1E1C  lea       $1E(A1),A0        Point to its SigExcept longword.
FC1E20  bra.s     FC1E2A            Drop into SetSignal.


---------------------------------------------------------------------------
  oldSignals = SetSignal( newSignals, signalMask )
  D0                      D0          D1
---------------------------------------------------------------------------

FC1E22  move.l    $0114(A6),A1      Get pointer to current task.
FC1E26  lea       $1A(A1),A0        Point to its SigRecvd longword.

        ; This code is common to SetExcept and SetSignal.

FC1E2A  and.l     D1,D0             Mask out signals to be left alone.
FC1E2C  move.w    #$4000,DFF09A     Disable()
FC1E34  addq.b    #1,$0126(A6)
FC1E38  move.l    (A0),-(SP)        Save current value of signal word.
FC1E3A  not.l     D1                Make mask of singnals to leave alone.
FC1E3C  and.l     (A0),D1           Get those signals only.
FC1E3E  or.l      D0,D1             Or in the changed signals.
FC1E40  move.l    D1,(A0)           Put the result back in the task.

        ; Now we drop into Signal(), which will process any new signals
        ; we may have set in the SigRecvd longword.

FC1E42  move.l    $1A(A1),D0        Get the SigRecvd data.
FC1E46  bra.s     FC1E5C            Drop into Signal.


---------------------------------------------------------------------------
  Signal( task, signals )
          A1    D0
---------------------------------------------------------------------------

FC1E48  lea       $1A(A1),A0        Get the set of received signals.
FC1E4C  move.w    #$4000,DFF09A     Disable()
FC1E54  addq.b    #1,$0126(A6)
FC1E58  move.l    (A0),-(SP)        Store the signals.
FC1E5A  or.l      D0,(A0)           Or the new signals into the old ones.

        ; The code from here down is common to SetExcept, SetSignal, and
        ; Signal.  It checks if the task whose signals are being modified
        ; should be awakened.

FC1E5C  move.l    $1E(A1),D1        Check the exception signals,
FC1E60  and.l     D0,D1             and see if any of them have become set.
FC1E62  bne.s     FC1EAE            If so, go process them.
FC1E64  cmp.b     #4,$0F(A1)        See if the task is in the TS_WAIT state.
FC1E6A  bne.s     FC1EBE            If not, we're done.
FC1E6C  and.l     $16(A1),D0        See if a signal being waited for has been
FC1E70  beq.s     FC1EBE            set.  If not, we are done.

        ; We have set a signal which the task was currently waiting for,
        ; so we must awaken it.  First, we take it out of the TaskWait
        ; list then we make it TS_READY, then we put it on the TaskReady
        ; queue and check if it should preempt the current task.

FC1E72  lea       $01A4(A6),A0
FC1E76  move.l    A1,D0             Save pointer to the task.
FC1E78  move.l    (A1),A0           Get pointer to the next task in the list.
FC1E7A  move.l    4(A1),A1          Get pointer to the previous task.
FC1E7E  move.l    A0,(A1)           Unlink from the previous task.
FC1E80  move.l    A1,4(A0)          Unlink from the next task.
FC1E84  move.l    D0,A1             Restore pointer to the task.
FC1E86  move.b    #3,$0F(A1)        Make the task TS_READY.
FC1E8C  lea       $0196(A6),A0      Point to the TaskReady queue.
FC1E90  bsr       FC1634            Enqueue the task in the right place.
FC1E94  cmp.l     $0196(A6),A1      Check if it was put at the head of the
FC1E98  bne.s     FC1EBE            TaskReady queue, and exit if not.
FC1E9A  subq.b    #1,$0126(A6)
FC1E9E  bge.s     FC1EA8            Enable()
FC1EA0  move.w    #$C000,DFF09A
FC1EA8  move.l    (SP)+,D0          Return old signals to caller eventually.
FC1EAA  jmp       -$30(A6)          Reschedule() so the task can run.

        ; Enter here if we have set an exception signal, or if a previously
        ; set signal has become an exception signal.

FC1EAE  bset      #5,$0E(A1)        Set the task's TB_EXCEPT flag.
FC1EB4  cmp.b     #4,$0F(A1)        See if it is in the TS_WAIT state.

        ; If the task for which the exception occurred was in the TS_WAIT
        ; state, make it TS_READY and move it from the TaskWait list to
        ; the TaskReady queue.  Otherwise, just dispatch it.

FC1EBA  beq.s     FC1E72
FC1EBC  bra.s     FC1E9A

        ; Exit here if the current task was allowed to keep running (i.e.
        ; the other task did not preempt it).

FC1EBE  subq.b    #1,$0126(A6)      Enable()
FC1EC2  bge.s     FC1ECC
FC1EC4  move.w    #$C000,DFF09A
FC1ECC  move.l    (SP)+,D0          Return old signals.
FC1ECE  rts       


---------------------------------------------------------------------------
  signals = Wait( signalSet )
  D0              D0
---------------------------------------------------------------------------

FC1ED0  move.l    $0114(A6),A1      Get the pointer to the current task.
FC1ED4  move.l    D0,$16(A1)        Record which signals we are waiting for.
FC1ED8  move.w    #$4000,DFF09A     Disable()
FC1EE0  addq.b    #1,$0126(A6)
FC1EE4  bra.s     FC1F1A            Enter the loop at the bottom.

        ; Main loop:  We stay here until we have a signal we want.

FC1EE6  move.b    #4,$0F(A1)        Make the task state TS_WAIT.
FC1EEC  lea       $01A4(A6),A0      Point to the TaskWait list.
FC1EF0  lea       4(A0),A0
FC1EF4  move.l    4(A0),D0          Unlink the task from the TaskReady
FC1EF8  move.l    A1,4(A0)          queue, and put it in the TaskWait
FC1EFC  move.l    A0,(A1)           list.
FC1EFE  move.l    D0,4(A1)
FC1F02  move.l    D0,A0
FC1F04  move.l    A1,(A0)

        ; Here we block.  Calling Switch() gives control to any other
        ; process.  Eventually, someone else doing a Signal() will put us
        ; back on the TaskReady list, and then we will return from the
        ; Switch() when our priority comes up again.

FC1F06  move.l    A5,A0             Save A5.
FC1F08  lea       -$36(A6),A5       Get ready to call Switch(), but first...
FC1F0C  jsr       -$1E(A6)          Enter Supervisor mode.

        ; We're back.  See if we now have a signal we want.

FC1F10  move.l    A0,A5             Restore A5.
FC1F12  move.l    $0114(A6),A1      Get pointer to current process.
FC1F16  move.l    $16(A1),D0        Get the signals we are waiting for.

        ; We initially enter here to see if we have to block at all, and
        ; again each time we have been unblocked to see if we can now
        ; continue running.

FC1F1A  move.l    $1A(A1),D1        Get the signals which are currently set.
FC1F1E  and.l     D0,D1             Check against signals to wait for.
FC1F20  beq.s     FC1EE6            If not, go back and block again.

        ; Eventually, we end up here.  We now have one or more signals
        ; that were being waited for.  We take these out of the set of
        ; received signals, since we will return them to the caller.

FC1F22  eor.l     D1,$1A(A1)        Update the set of received signals.
FC1F26  subq.b    #1,$0126(A6)
FC1F2A  bge.s     FC1F34            Enable()
FC1F2C  move.w    #$C000,DFF09A
FC1F34  move.l    D1,D0             Return the signals.
FC1F36  rts       


---------------------------------------------------------------------------
  Reschedule()
---------------------------------------------------------------------------

        ; This function is used when it is possible that a task should
        ; be preempted and another task run in its place.  It sets the
        ; scheduling attention flag to force the scheduler to do its thing
        ; as soon as possible.  If multitasking is disabled, that's all
        ; it does, since Permit() will do the rest when multitasking is
        ; turned on again.  If interrupts are disabled, it sets the software
        ; generated interrupt.  Since this is not accompanied by setting
        ; the software interrupt pending flag, it will do nothing but
        ; run ExitIntr() as soon as the interrupt level allows it.
        ; ExitIntr() will then cause the outstanding scheduling operation
        ; to be done.

        ; Note that part of Permit() is used to switch into supervisor
        ; mode and call the scheduler.

FC1F38  bset      #7,$0124(A6)      Set the scheduling attention flag.
FC1F3E  sne       D0                Save its previous state.
FC1F40  tst.b     $0127(A6)         Check if multitasking enabled.
FC1F44  bge.s     FC1F58            If not, exit.
FC1F46  tst.b     $0126(A6)         Check if interrupts enabled.
FC1F4A  blt.s     FC1F74            If so, go and do the scheduling.
FC1F4C  tst.b     D0                Check the (old) scheduling attn flag.
FC1F4E  bne.s     FC1F58            Exit if it was already set.
FC1F50  move.w    #$8004,DFF09C     Assert the software generated interrupt.
FC1F58  rts       


---------------------------------------------------------------------------
  Forbid()
---------------------------------------------------------------------------

FC1F5A  addq.b    #1,$0127(A6)      Increment the TDNestCnt.
FC1F5E  rts       


---------------------------------------------------------------------------
  Permit()
---------------------------------------------------------------------------

FC1F60  subq.b    #1,$0127(A6)      Decrement the TDNestCnt.
FC1F64  bge.s     FC1F80            Exit if still positive.
FC1F66  tst.b     $0126(A6)         Check if interrupts disabled.
FC1F6A  bge.s     FC1F80            Exit if yes.

        ; The current task has just reenabled multitasking.  If the system
        ; is waiting to switch tasks, now is the time to do it.

FC1F6C  btst      #7,$0124(A6)      Check the scheduling attention flag.
FC1F72  beq.s     FC1F80            Exit if not pending.
FC1F74  move.l    A5,-(SP)          Save A5.
FC1F76  lea       FC1F82(PC),A5     Set address to go to in supervisor mode.
FC1F7A  jsr       -$1E(A6)          Enter supervisor mode.
FC1F7E  move.l    (SP)+,A5          Restore A5 and return.
FC1F80  rts       

        ; This is executed in supervisor mode.

FC1F82  btst      #5,(SP)           Check caller's supervisor mode flag.
FC1F86  beq.s     FC1F8A            If the caller was in supervisor mode,
FC1F88  rte                         then don't switch tasks.

        ; Eventually, this task will be dispatched again, using the program
        ; counter and status register left on the stack by the supervisor
        ; mode call.  Then it continues running above, pops A5 from the
        ; stack, and returns to the caller.

FC1F8A  jmp       -$2A(A6)          Go and do the scheduling.


---------------------------------------------------------------------------
  trapNum = AllocTrap( trapNum )
  D0                   D0
---------------------------------------------------------------------------

FC1F8E  move.l    $0114(A6),A1      Get pointer to the current task.
FC1F92  move.w    $22(A1),D1        Get the task's TrapAlloc flags.
FC1F96  cmp.b     #$FF,D0           See if we want a particular trap number.
FC1F9A  beq.s     FC1FA2
FC1F9C  bset      D0,D1             If so, set this trap number's flag bit.
FC1F9E  beq.s     FC1FAE            If it wasn't set, indicate success.
FC1FA0  bra.s     FC1FAC            It was already set, indicate failure.

        ; Look for a free trap number.

FC1FA2  moveq     #$0F,D0           16 traps to check.  Start at #15.
FC1FA4  bset      D0,D1             Try to set this trap's flag bit.
FC1FA6  beq.s     FC1FAE            If not set before, indicate success.
FC1FA8  dbra      D0,FC1FA4(PC)     Loop until all flags checked.
FC1FAC  moveq     #-1,D0            Indicate failure.
FC1FAE  move.w    D1,$22(A1)        Put updated trap flags back.
FC1FB2  rts       


---------------------------------------------------------------------------
  FreeTrap( trapNum )
            D0
---------------------------------------------------------------------------

FC1FB4  move.l    $0114(A6),A1      Get pointer to the current task.
FC1FB8  move.w    $22(A1),D1        Get the task's TrapAlloc flags.
FC1FBC  bclr      D0,D1             Clear the specified flag.
FC1FBE  move.w    D1,$22(A1)        Put the flags back.
FC1FC2  rts       


---------------------------------------------------------------------------
  signalNum = AllocSignal( signalNum )
  D0                       D0
---------------------------------------------------------------------------

FC1FC4  move.l    $0114(A6),A1      Get pointer to the current task.
FC1FC8  move.l    $12(A1),D1        Get the task's SigAlloc flags.
FC1FCC  cmp.b     #$FF,D0           See if we want a particular signal.
FC1FD0  beq.s     FC1FD8
FC1FD2  bset      D0,D1             If so, try to set its flag.
FC1FD4  beq.s     FC1FE6            Indicate success if it was clear.
FC1FD6  bra.s     FC1FE2            Indicate failure if already set.

        ; Look for a free signal.

FC1FD8  moveq     #$1F,D0           32 Signals to check.  Start at 31.
FC1FDA  bset      D0,D1             Try to set the signal's flag.
FC1FDC  beq.s     FC1FE6            If it wasn't already set, success.
FC1FDE  dbra      D0,FC1FDA(PC)     Otherwise, keep looking.
FC1FE2  moveq     #-1,D0            Indicate failure.
FC1FE4  bra.s     FC1FFA

FC1FE6  move.l    D1,$12(A1)        Success.  Update allocated signal flags.
FC1FEA  moveq     #-1,D1
FC1FEC  bclr      D0,D1             Set all but this signal bit in D1.
FC1FEE  and.l     D1,$1A(A1)        Make sure this signal isn't set.
FC1FF2  and.l     D1,$1E(A1)        Make sure it's not an exception signal.
FC1FF6  and.l     D1,$16(A1)        Indicate that we are not waiting for it.
FC1FFA  rts       


---------------------------------------------------------------------------
  FreeSignal( signalNum )
              D0
---------------------------------------------------------------------------

FC1FFC  move.l    $0114(A6),A1      Get pointer to the current task.
FC2000  move.l    $12(A1),D1        Get the SigAlloc flags.
FC2004  bclr      D0,D1             Clear the indicated signal bit.
FC2006  move.l    D1,$12(A1)        Put the flags back.
FC200A  rts       


        ; Subroutines for RawDoFmt()
        ; --------------------------

        ; Find the length of a null-terminated string pointed to by A0.
        ; For efficiency, the length is counted up as a negative number.

FC200C  moveq     #-1,D2                Start the length at -1.
FC200E  tst.b     (A0)+                 Get string character, test for end.
FC2010  dbeq      D2,FC200E(PC)         Count, and loop until end of string.
FC2014  neg.l     D2
FC2016  subq.w    #1,D2                 Convert length to correct +ve value.
FC2018  rts       


        ; Evaluate a decimal numeric constant pointed to by A4.

FC201A  clr.l     D0                    Start the result at 0.
FC201C  clr.l     D2
FC201E  move.b    (A4)+,D2              Get a character from the input.
FC2020  cmp.b     #'0',D2
FC2024  bcs.s     FC203E
FC2026  cmp.b     #'9',D2               If not a numeric digit, exit.
FC202A  bhi.s     FC203E
FC202C  add.l     D0,D0                 Multiply previous result by 10.
FC202E  move.l    D0,D1
FC2030  add.l     D0,D0
FC2032  add.l     D0,D0
FC2034  add.l     D1,D0
FC2036  sub.b     #'0',D2               Convert digit to number 0 - 9.
FC203A  add.l     D2,D0                 Add to result.
FC203C  bra.s     FC201E                Go evaluate next character.

        ; Finish up by pointing back at the non-digit character.

FC203E  subq.l    #1,A4                 Backspace the input pointer.
FC2040  rts       


        ; Convert the number in D4 to its decimal ASCII representation.

FC2042  tst.l     D4                    Is the number zero?
FC2044  beq.s     FC207A                If so, just output "0" and return.
FC2046  bmi.s     FC204C                Is it negative?
FC2048  neg.l     D4                    If not, make it negative.
FC204A  bra.s     FC2050
FC204C  move.b    #'-',(A5)+            If so, output a "-".

        ; The minus sign is taken care of, and negative the number to
        ; be output is in D4.

FC2050  lea       FC2084,A0             Point at table of divisors.
FC2056  clr.w     D1                    Clear the "non-zero digit" flag.

FC2058  move.l    (A0)+,D2              Get a divisor from the table.
FC205A  beq.s     FC207A                If zero, output last digit and exit.

        ; Subtract the current divisor from the number as many times as
        ; possible (actually, add to its negative).

FC205C  moveq     #-1,D0                Start the counter at -1.
FC205E  add.l     D2,D4                 Try to add the divisor to D4.
FC2060  dbgt      D0,FC205E(PC)         Loop until D4 is greater than zero.
FC2064  sub.l     D2,D4                 Make the number less than zero again.
FC2066  addq.w    #1,D0                 Increment the counter by 1.

        ; D0 now contains negative the current digit to output.  Discard
        ; it if it is a leading zero.

FC2068  bne.s     FC206E                If the current digit is zero then
FC206A  tst.w     D1                    if no non zero digits have been
FC206C  beq.s     FC2058                output, then discard it.

        ; Output the digit.

FC206E  moveq     #-1,D1                Set "non-zero digit" flag.
FC2070  neg.b     D0                    Make D0 positive.
FC2076  add.b     #'0',D0               Convert to an ASCII digit.
FC2076  move.b    D0,(A5)+              Put it into the buffer.
FC2078  bra.s     FC2058                Go do the next digit.

        ; Enter here to output the last digit, or the single "0" if the
        ; number is zero.

FC207A  neg.b     D4                    Make D0 positive.
FC207C  add.b     #'0',D4               Convert to an ASCII digit.
FC2080  move.b    D4,(A5)+              Put it into the buffer.
FC2082  rts       


        ; Table of divisors.

FC2084  3B9ACA00                        1000000000 decimal.
FC2088  05F5E100                         100000000 decimal.
FC208C  00989680                          10000000 decimal.
FC2090  000F4240                           1000000 decimal.
FC2094  000186A0                            100000 decimal.
FC2098  00002710                             10000 decimal.
FC209C  000003E8                              1000 decimal.
FC20A0  00000064                               100 decimal.
FC20A4  0000000A                                10 decimal.
FC20A8  00000000                                 0 decimal.


        ; Convert the number in D4 to its hexadecimal ASCII representation.

FC20AC  tst.l     D4                    Is the number zero?
FC20AE  beq.s     FC207A                If so, just output "0" and exit.
FC20B0  clr.w     D1                    Clear "non-zero digit" flag.
FC20B2  btst      #2,D3                 Is the data 32 bits long?
FC20B6  bne.s     FC20BE
FC20B8  moveq     #3,D2                 If not, output 4 digits,
FC20BA  swap      D4                    from the high word of D4.
FC20BC  bra.s     FC20C0
FC20BE  moveq     #7,D2                 If so, output 8 digits.

        ; Digit output loop.

FC20C0  rol.l     #4,D4                 Rotate leftmost digit into bits 0-3.
FC20C2  move.b    D4,D0
FC20C4  and.b     #$0F,D0               Mask out all but bits 0-3.

        ; Skip leading zeros.

FC20C8  bne.s     FC20CE                If no non-zero digit has been
FC20CA  tst.w     D1                    encountered yet, and this is a zero,
FC20CC  beq.s     FC20E2                skip it.

FC20CE  moveq     #-1,D1                Set "non-zero digit" flag.
FC20D0  cmp.b     #9,D0                 Is the digit greater than 9?
FC20D4  bhi.s     FC20DC
FC20D6  add.b     #'0',D0               If not, convert to ASCII numeral.
FC20DA  bra.s     FC20E0
FC20DC  add.b     #$37,D0               If so, convert to upper case letter.
FC20E0  move.b    D0,(A5)+              Put digit in buffer.
FC20E2  dbra      D2,FC20C0(PC)         Loop until all digits done.
FC20E6  rts       


---------------------------------------------------------------------------
  RawDoFmt( FormatString, DataStream, PutChProc, PutChData )
            A0            A1          A2         A3
---------------------------------------------------------------------------

FC20E8  movem.l   D2-D6/A2-A5,-(SP)
FC20EC  link      A6,#-$10              Reserve stack space for buffer.
FC20F0  move.l    A1,-(SP)              Store data stream pointer.
FC20F2  move.l    A0,A4                 Point to the format string.
FC20F4  move.b    (A4)+,D0              Get a byte from the format string.
FC20F6  beq.s     FC2102                Check for end and exit if found.
FC20F8  cmp.b     #'%',D0               Check for format specifier.
FC20FC  beq.s     FC210C                Process it if found.
FC20FE  jsr       (A2)                  Otherwise, output the character,
FC2100  bra.s     FC20F4                and go on to the next one.
FC2102  jsr       (A2)                  Output the terminating zero.
FC2104  unlk      A6                    Deallocate the output buffer.
FC2106  movem.l   (SP)+,D2-D6/A2-A5
FC210A  rts       

        ; Enter here if the "%" format specifier was found.  Next we check
        ; for the characters "-", signaling that the printed item should
        ; be left-aligned in its field, and "0", signaling that leading
        ; zeros should be attached.

FC210C  lea       -$10(A6),A5           Point to the output buffer.
FC2110  clr.w     D3                    Clear the option flags.
FC2112  cmp.b     #'-',(A4)             Left alignment desired?
FC2116  bne.s     FC211E
FC2118  bset      #0,D3                 If so, set the corresponding flag,
FC211C  addq.l    #1,A4                 and go on to the next character.
FC211E  cmp.b     #'0',(A4)             Zero fill desired?
FC2122  bne.s     FC2128
FC2124  bset      #1,D3                 If so, set the corresponding flag.
FC2128  bsr       FC201A                Get the field width.
FC212C  move.w    D0,D6                 Store it in D6.
FC212E  clr.l     D5                    Assume no maximum length.
FC2130  cmp.b     #'.',(A4)             Maximum length specifier?
FC2134  bne.s     FC213E
FC2136  addq.w    #1,A4                 If so, go on to the next character,
FC2138  bsr       FC201A                and get the maximum length.
FC213C  move.w    D0,D5                 Store maximum length.
FC213E  cmp.b     #'l',(A4)             32 bit data?
FC2142  bne.s     FC214A
FC2144  bset      #2,D3                 If so, set the corresponding flag,
FC2148  addq.w    #1,A4                 and go on to the next character.

        ; At this point, we have interpreted a format string of the format
        ; "%-0xxx.yyyl".  In D3, bit 0 is set if the "-" was present, bit 1
        ; is set if the "0" was present, and bit 2 is set if the "l"
        ; was present.  D6 contains the value of "xxx" (numeric constant),
        ; and D5 contains the value of "yyy" if present, or 0 if not.

        ; Now we process the actual format characters: "s" for string, "c"
        ; for character, "d" for decimal, "x" for hex.  In all cases, the
        ; goal is to build a null-terminated string, pointed to by A0,
        ; containing the formatted output.

FC214A  move.b    (A4)+,D0              Get the next character.
FC214C  cmp.b     #'d',D0               Decimal output?
FC2150  bne.s     FC215A                Skip to next option if not.
FC2152  bsr.s     FC2168                Get data item.
FC2154  bsr       FC2042                Format as decimal number.
FC2158  bra.s     FC21A2                Output the buffer.
FC215A  cmp.b     #'x',D0               Hexadecimal output?
FC215E  bne.s     FC2188                Skip to next option if not.
FC2160  bsr.s     FC2168                Get data item.
FC2162  bsr       FC20AC                Format as hexadecimal number.
FC2166  bra.s     FC21A2                Output the buffer.

        ; Subroutine to get a number from the data stream.  We get either
        ; a word or a longword, depending on whether an "l" was in the
        ; format specification.

FC2168  btst      #2,D3                 If data size is 16 bits then
FC216C  bne.s     FC217C
FC216E  move.l    4(SP),A1                Get data stream pointer.
FC2172  move.w    (A1)+,D4                Get a word from the data stream.
FC2174  move.l    A1,4(SP)                Put data stream pointer back.
FC2178  ext.l     D4                      Extend to longword.
FC217A  rts                             Else
FC217C  move.l    4(SP),A1                Get data stream pointer.
FC2180  move.l    (A1)+,D4                Get a longword from data stream.
FC2182  move.l    A1,4(SP)                Put data stream pointer back.
FC2186  rts                             Endif

        ; Continue here if not formatting a number.

FC2188  cmp.b     #'s',D0               String output?
FC218C  bne.s     FC2196                If not, skip to next.
FC218E  move.l    (SP),A1               Get data stream pointer.
FC2190  move.l    (A1)+,A5              Point directly at the string.
FC2192  move.l    A1,(SP)               Put data stream pointer back.
FC2194  bra.s     FC21A8                Output the string.
FC2196  cmp.b     #'c',D0               Single character output?
FC219A  bne       FC20FE                If not, discard format specifier.
FC219E  bsr.s     FC2168                Get character from input stream.
FC21A0  move.b    D4,(A5)+              Put it into the buffer.

        ; Numeric and character output, having put their formatted argument
        ; into the buffer, meet here.

FC21A2  clr.b     (A5)                  Zero-terminate the buffer.
FC21A4  lea       -$10(A6),A5           Point back to its start.

        ; All output options continue here.  A5 now points to a
        ; null-terminated string to output.

FC21A8  move.l    A5,A0
FC21AA  bsr       FC200C                Find the length of the string.
FC21AE  tst.w     D5                    Was a maximum length specified?
FC21B0  beq.s     FC21B6
FC21B2  cmp.w     D5,D2                 If so, and if the output string is
FC21B4  bhi.s     FC21B8                longer, set the length to the
FC21B6  move.w    D2,D5                 maximum length.
FC21B8  sub.w     D5,D6                 Compute amount of padding needed.
FC21BA  bpl.s     FC21BE
FC21BC  clr.w     D6                    Set to zero if negative.
FC21BE  btst      #0,D3                 Was left alignment desired?
FC21C2  bne.s     FC21CC
FC21C4  bsr.s     FC21DE                If not, output padding first.
FC21C6  bra.s     FC21CC
FC21C8  move.b    (A5)+,D0              Loop to copy the string to the output
FC21CA  jsr       (A2)                  until its end or the given maximum
FC21CC  dbra      D5,FC21C8(PC)         number of characters.
FC21D0  btst      #0,D3                 Was left alignment desired?
FC21D4  beq       FC20F4
FC21D8  bsr.s     FC21DE                If so, output padding now.
FC21DA  bra       FC20F4                Continue with format string.


        ; Subroutine to output the right amount of padding.

FC21DE  move.b    #' ',D2               Assume padding with spaces.
FC21E2  btst      #1,D3                 Was zero-fill desired?
FC21E6  beq.s     FC21F2
FC21E8  move.b    #'0',D2               If so, pad with zeros.
FC21EC  bra.s     FC21F2
FC21EE  move.b    D2,D0                 Loop to output the required number
FC21F0  jsr       (A2)                  of padding characters.
FC21F2  dbra      D6,FC21EE(PC)
FC21F6  rts       


---------------------------------------------------------------------------
  RawIOInit()
---------------------------------------------------------------------------

        ; Set the serial port for receiving 8 bit data at 9600 bps.

FC21F8  move.w    #$0174,DFF032         Set up the SERPER register.
FC2200  rts       


---------------------------------------------------------------------------
  RawMayGetChar()
---------------------------------------------------------------------------

FC2202  moveq     #-1,D0
FC2204  move.w    DFF018,D1             Read SERDATR.
FC220A  btst      #$0E,D1               Is a byte in the receive buffer?
FC220E  beq.s     FC2220                If not, return -1 and exit.
FC2210  move.w    #$0800,DFF09C         Clear the serial receive interrupt.
FC2218  and.l     #$00007F,D1           Get the received character.
FC221E  move.l    D1,D0                 Return it to the caller.
FC2220  rts       


        ; Subroutine to wait for a character on the serial port.

FC2222  bsr.s     FC2202                RawMayGetChar()
FC2224  tst.l     D0                    Did we get a character?
FC2226  bmi.s     FC2222                Continue waiting if not.
FC2228  rts                             Return the character.


        ; This looks like a C entry point for RawPutChar.

FC222A  move.l    4(SP),D0              Get the first C parameter.

---------------------------------------------------------------------------
  RawPutChar()
---------------------------------------------------------------------------

        ; Don't output code 0, and expand newlines to CRLF.

FC222E  tst.b     D0                    Is the character to send zero?
FC2230  beq.s     FC2272                If so, don't send it.
FC2232  move.w    D0,-(SP)              Save the character.
FC2234  cmp.b     #$0A,D0               Is it a newline?
FC2238  bne.s     FC223E
FC223A  moveq     #$0D,D0               If so, send a carriage return first.
FC223C  bsr.s     FC2240
FC223E  move.w    (SP)+,D0              Get the character back.

        ; Enter here to send the character in D0 on the serial port.

FC2240  move.w    DFF018,D1             Read SERDATR.
FC2246  btst      #$0D,D1               Transmitter ready?
FC224A  beq.s     FC2240                Wait until true.

FC224C  and.w     #$FF,D0               Mask out all but bits 0-7.
FC2250  or.w      #$0100,D0             Set the stop bit.
FC2254  move.w    D0,DFF030             Write to SERDAT.

        ; Handle XON/XOFF and/or escape into the debugger if DEL pressed.

FC225A  bsr.s     FC2202                RawMayGetChar()
FC225C  cmp.b     #$13,D0               Did we get an XOFF?
FC2260  bne.s     FC2266
FC2262  bsr.s     FC2222                If yes, wait for any other character.
FC2264  bra.s     FC225C
FC2266  cmp.b     #$7F,D0               Did we get a DEL?
FC226A  bne.s     FC2272                Return if not.
FC226C  bsr       FC232E                If so, Debug()
FC2270  bra.s     FC225C                On return, check for XOFF again.
FC2272  rts       


        ; C compatible routine to print a string.

FC2274  move.l    4(SP),A0              Get first C parameter (string addr.)

        ; Assembly language entry point (address in A0).

FC2278  move.b    (A0)+,D0              Get a string character.
FC227A  beq.s     FC228C                Exit if is the terminating zero.
FC227C  cmp.b     #$0A,D0               Is it a newline?
FC2280  bne.s     FC2288
FC2282  moveq     #$0D,D0               If so, output a CR first.
FC2284  bsr.s     FC222E
FC2286  moveq     #$0A,D0
FC2288  bsr.s     FC222E                Output the character.
FC228A  bra.s     FC2278                Go on to next character.
FC228C  rts       


        ; C compatible function to output a hex number.  First argument
        ; is the number, second one is the number of digits.  The number
        ; will be output with one space following.

FC228E  movem.l   4(SP),D0/D1           Get C parameters.

        ; Assembly language entry point.

FC2294  movem.l   D2/D3,-(SP)
FC2298  move.l    D0,D2
FC229A  moveq     #8,D3
FC229C  sub.w     D1,D3                 Compute 8 - number of digits.
FC229E  bra.s     FC22A2                Loop that many times, rotating the
FC22A0  rol.l     #4,D2                 number left by a digit each time,
FC22A2  dbra      D3,FC22A0(PC)         to left-align the number in D2.

FC22A6  move.w    D1,D3                 Get number of digits.
FC22A8  bra.s     FC22C2
FC22AA  rol.l     #4,D2                 Shift current digit into bits 0-3.
FC22AC  moveq     #$0F,D0
FC22AE  and.b     D2,D0                 Extract bits 0-3 from the number.
FC22B0  cmp.b     #9,D0                 Numeric or alphabetic digit?
FC22B4  bls.s     FC22BA
FC22B6  add.b     #7,D0                 If alphabetic, add ('A'-'9').
FC22BA  add.b     #'0',D0               Convert to ASCII digit.
FC22BE  bsr       FC222E                Output the digit.
FC22C2  dbra      D3,FC22AA(PC)         Loop until all digits done.
FC22C6  moveq     #$20,D0
FC22C8  bsr       FC222E                Output a space.
FC22CC  movem.l   (SP)+,D2/D3
FC22D0  rts       


        ; Entry point to do a RawDoFmt() to the serial port.

FC22D2  move.l    A2,-(SP)              Save A2.
FC22D4  lea       FC222E(PC),A2         Point A2 to RawPutChar() function.
FC22D8  bsr       FC20E8                RawDoFmt()
FC22DC  move.l    (SP)+,A2              Restore A2.
FC22DE  rts       


---------------------------------------------------------------------------
  Open()
---------------------------------------------------------------------------

        ; This gets executed if someone actually opens "exec.library".

FC22E0  move.l    A6,D0                 Return ExecBase.
FC22E2  addq.w    #1,$20(A6)            Increment exec.library open count.
FC22E6  rts       


---------------------------------------------------------------------------
  Close()
---------------------------------------------------------------------------

        ; This gets executed if someone tries to close "exec.library".

FC22E8  subq.w    #1,$20(A6)            Decrement exec.library open count.


---------------------------------------------------------------------------
  Expunge()
---------------------------------------------------------------------------

        ; This gets executed if someone tries to Expunge() the exec.
        ; Needless to say, we won't do anything of the sort, but we'll make
        ; the caller happy by returning zero.

        ; The reserved jump vector (at ExecBase - 24) also points here.

FC22EC  moveq     #0,D0
FC22EE  rts       


        ; ROM-Wack
        ; --------

        ; This is the Amiga's ROM resident mini-debugger.  The following
        ; string is sent out the serial port when it starts up.

FC22F0  LF, "rom-wack", 00

        ; ROM-Wack has a private, 236 byte data area at $000200.  The
        ; following is a memory map of this area.  Addresses are given as
        ; hex offsets from $000200.

        ;-------------------------------------------------------------------
        ; 00  (32 bit)  Pointer to current key bindings.
        ; 04  (32 bit)  Saved key binding pointer if not using main ones.
        ; 08  (32 bit)  Value of last number entered by the user.
        ; 0C  (32 bit)  The "current address" for all operations.
        ; 10 - 13       (not used).
        ; 14  (32 bit)  The current "frame size".
        ; 18  (32 bit)  The upper limit address for searches and fills.
        ; 1C  (16 bit)  Number of characters in the input buffer.
        ; 1E  (8 bit)   Flag indicating whether the "frame" should be
        ;               redisplayed after a command has executed.
        ; 1F  (8 bit)   Flag indicating whether we are in "alter" mode.
        ; 20  (16 bit)  Flag indicating whether there is unprocessed data
        ;               in the buffer (0 if yes, 1 if no).
        ; 22  (16 bit)  Number of digits in the number most recently entered.
        ; 24  (16 bit)  Flag indicating whether a number is being gathered as
        ;               a parameter to a command, or being entered unprompted
        ;               (in which case it becomes the current address).
        ; 26  (32 bit)  Indirection stack pointer (for following pointers).
        ; 2A - 4F       (not used).
        ; 50 - 81       Input buffer for user commands.
        ; 82  (16 bit)  Last character typed by the user.
        ; 84  (32 bit)  Pointer to data area on the stack, holding CPU and
        ;               process related information (map farther down)
        ; 88  (16 bit)  Instruction to use for breakpoints (TRAP #15).
        ; 8A - E9       Breakpoint table.  Each entry consists of an address
        ;               where an instruction was replaced with TRAP #15, and
        ;               the word which had been there before.
        ; EA  (16 bit)  Value to be written to INTENA to restore serial
        ;               port interrupts to their original state.
        ;-------------------------------------------------------------------


        ; This gets called from the exec initialization code.

FC22FA  move.l    A6,-(SP)              Save ExecBase.
FC22FC  move.l    #$000200,A6           Point to ROM-Wack's data area.
FC2302  bsr       FC2472                Initialize it.
FC2306  move.l    (SP)+,A6              Restore ExecBase.
FC2308  move.l    #$FC2342,$42(A6)      Install default ExecBase->DebugEntry.
FC2310  move.l    #$FC232E,-$70(A6)     Install default Debug() vector.
FC2318  bsr       FC21F8                RawIOInit()
FC231C  rts       


        ; Special exception handlers for ROM-Wack
        ; ---------------------------------------

        ; ROM-Wack trace exception handler.

FC231E  move.l    #$000009,-(SP)        Push "Trace" exception number.
FC2324  bra.s     FC2342                Enter the debugger.

        ; ROM-Wack breakpoint exception handler.  A "TRAP #15" instruction
        ; is used for the breakpoint.

FC2326  move.l    #$00002F,-(SP)        Push "TRAP #15" exception number.
FC232C  bra.s     FC2342                Enter the debugger.

---------------------------------------------------------------------------
  Debug()
---------------------------------------------------------------------------

        ; This entry point is used when an actual function call to Debug()
        ; is made.  We set up the supervisor stack to look like it would
        ; after an exception handled by the exec exception entry points.

FC232E  move.l    A5,-(SP)              Save A5.
FC2330  lea       FC2338(PC),A5         Where to go in supervisor mode.
FC2334  jmp       -$1E(A6)              Supervisor()

        ; We now have an exception stack frame from the Supervisor() call.

FC2338  move      USP,A5                Pop the return address from the
FC233A  move.l    (A5)+,-(SP)           Debug() call from the user stack.
FC233C  move      A5,USP
FC233E  move.l    (SP)+,A5              Get the return address back.
FC2340  clr.l     -(SP)                 Fake exception number zero.

        ; Now the supervisor and user stacks look as if an exception had
        ; occurred and was handled by the exec, with the difference that
        ; the original value of A5 is on the supervisor stack, and A5 now
        ; contains the return address from the Debug() call.


        ; Exception entry point.
        ; ----------------------

        ; The debugger is entered here with the stacks already set up as
        ; above (by the system exception handler).  First, we verify if
        ; the stack is even working (pointing at RAM).

FC2342  move.l    #$F1E2D3C4,-(SP)      Put a signature on the stack.
FC2348  cmp.l     #$F1E2D3C4,(SP)+      Check if it can be read back.
FC234E  beq.s     FC235E

        ; A signature pushed on the supervisor stack could not be read
        ; back, so we are in serious trouble.  Initialize the stack at
        ; the top of the first 256K of chip memory.  Put a fake exception
        ; stack frame on the new stack.

FC2350  move.l    #$040000,SP           Start stack at 256K.
FC2356  clr.l     -(SP)                 Fake program counter.
FC2358  clr.w     -(SP)                 Fake status register.
FC235A  clr.l     -(SP)                 Push exception number -1.
FC235C  not.l     (SP)

        ; We now have a working supervisor stack with the exception
        ; number and stack frame on it.

FC235E  movem.l   D0-D7/A0-A6,-(SP)     Save most of the CPU registers.
FC2362  lea       $3C(SP),A5            Point A5 at the exception number.
FC2366  lea       -$16(SP),SP           Reserve 22 bytes of stack space,
FC236A  move.l    SP,A4                 and point A4 to the bottom of this.
FC236C  clr.l     $12(A4)
FC2370  move.l    (A5)+,D3              Get the exception number.
FC2372  move.l    D3,$0E(A4)            Store it.
FC2376  move.l    A5,$0A(A4)            Store supervisor stack pointer.
FC237A  move      USP,A0
FC237C  move.l    A0,6(A4)              Store user stack pointer.

        ; When a 680x0 hits an exception, it pushes the program counter, then
        ; the status register, onto the supervisor stack.  For bus and
        ; address errors, however, more information is saved.  On 68010 and
        ; 68020 processors, this comes before the program counter and status
        ; register, i.e. the stack pointer after an exception always points
        ; at these.  On the 68000, however, 8 bytes of other information
        ; are pushed on the stack AFTER the PC and SP.  The following code
        ; compensates for this.

FC2380  bsr       FC0546                Check CPU/FPP configuration.
FC2384  tst.b     D0                    Is it a plain vanilla 68000?
FC2386  bne.s     FC2396
FC2388  cmp.w     #3,D3                 Was it an address error?
FC238C  bgt.s     FC2396
FC238E  cmp.w     #2,D3                 Was it a bus error?
FC2392  blt.s     FC2396
FC2394  addq.l    #8,A5                 If either, skip past bus error info.

        ; For all CPUs, A5 now points to where the status register and
        ; program counter are stored on the supervisor stack.

FC2396  btst      #5,(A5)               Check the supervisor mode bit.
FC239A  bne.s     FC23A6                If it was set,
FC239C  move.l    4,A0                  get ExecBase,
FC23A0  move.l    $0114(A0),$12(A4)     and get the current task pointer.
FC23A6  move.w    (A5)+,4(A4)           Get and store the status register.
FC23AA  move.l    (A5),0(A4)            Get and store the program counter.

        ; Time for a summary (so I don't get confused).  A4 currently
        ; points at a data structure, on the supervisor stack, containing
        ; the following:

        ; (60 bytes) Register dump (D0-D7, A0-A6).

        ; (32 bit)   Current task pointer or zero.
        ; (32 bit)   Number of the exception that got us here (see below).
        ; (32 bit)   Saved supervisor stack pointer.
        ; (32 bit)   Saved user stack pointer.
        ; (16 bit)   Saved status register (from exception stack frame).
        ; (32 bit)   Saved program counter (from exception stack frame).

        ; If the exception number is zero, Debug() was used to get here.

        ; If the exception number is -1, we somehow got here, but the
        ; supervisor stack pointer was clobbered and not pointing to RAM.
        ; In this case, we have just set it to 256K, and the saved
        ; program counter and status register are invalid.

FC23AE  move.l    #$000200,A6           Point to ROM-Wack's data area.

        ; Disable serial port interrupts, and make a control word which,
        ; when written to INTENA, will return them to their original status.

FC23B4  move.w    DFF01C,$EA(A6)        Store interrupt enable status.
FC23BC  move.w    #$0801,D0             Disable serial port interrupts.
FC23C0  move.w    D0,DFF09A
FC23C6  bset      #$0F,D0               Make the control word to be used
FC23CA  and.w     D0,$EA(A6)            to restore those two interrupts.

FC23CE  bsr       FC21F8                RawIOInit()
FC23D2  lea       FC22F0(PC),A0
FC23D6  bsr       FC2278                Print a newline and "rom-wack".

FC23DA  move.l    A4,$84(A6)            Save pointer to stack-resident data.
FC23DE  moveq     #-2,D2                Make the saved exception program
FC23E0  and.l     0(A4),D2              counter even (if not already so),
FC23E4  move.l    D2,0(A4)              and put it back.
FC23E8  move.l    D2,$0C(A6)            Set the "current address" there.
FC23EC  cmp.l     #$00002F,$0E(A4)      Did a TRAP #15 get us here?
FC23F4  bne.s     FC23FE                Skip the following if not.

        ; Special handling for breakpoints.  Back the PC up by 2 (over
        ; the TRAP #15 instruction used for the breakpoint), and clear
        ; the breakpoint (restore the original instruction).

FC23F6  subq.l    #2,$0C(A6)            Back up to breakpoint address.
FC23FA  bsr       FC28A2                "clear" the breakpoint.

FC23FE  move.l    $0C(A6),0(A4)         Update the saved program counter.
FC2404  move.l    A4,A1                 Point to the stack-resident data.

        ; Install the exception vectors needed for breakpoints and
        ; single-stepping.

FC2406  move.l    #$FC2326,$BC          Install TRAP #15 exception vector.
FC240E  move.l    #$FC231E,$24          Install "Trace" exception vector.
FC2416  move.l    #$01000000,$18(A6)    Set the search limit to 16 megabytes.
FC241E  bsr       FC27EA                Display the ROM-Wack register frame.
FC2422  bsr       FC2B94                Enter the ROM-Wack main loop.


        ; Entry point for <Tab> command.

        ; Entry point to run a single instruction in trace mode.  This does
        ; everything required to resume running as below, but with the trace
        ; mode bit set in the saved status register, so only a single
        ; instruction will be executed after the RTE (and then we come back
        ; in at the top).

FC2426  move.l    $84(A6),A0            Point to data on system stack.
FC242A  move.w    4(A0),$56(A0)         Get the saved status register, set
FC2430  or.w      #$8000,$56(A0)        the trace mode bit, and store it.
FC2436  bra.s     FC2452

        ; Set up to continue running after exit from ROM-Wack.  Note that
        ; to compensate for the different exception stack frame formats of
        ; bus error and regular exceptions, we don't even try to compensate
        ; for the format of the exception stack frame, just build one
        ; containing a simple status register and program counter right
        ; above the register dump.  This allows the RTE instruction to
        ; conveniently resume running whatever called ROM-Wack, but
        ; some garbage may be left on the stack.

        ; Entry point for "go" command.

        ; This starts running wherever the current address is pointing.

FC2438  move.l    $84(A6),A0            Point to data on system stack.
FC243C  move.l    $0C(A6),0(A0)         Make PC the current address.

        ; Entry point for "^D" and "resume" commands.

        ; This continues running where it left off.

FC2442  move.l    $84(A6),A0
FC2446  move.w    4(A0),$56(A0)         Get the saved status register.
FC244C  and.w     #$7FFF,$56(A0)        Clear the trace mode flag and put
                                        it on the stack.
FC2452  move.w    $EA(A6),DFF09A        Restore serial port interrupt status.
FC245A  move.l    0(A0),$58(A0)         Put the program counter on the stack.
FC2460  move.l    6(A0),A1              Get the saved user stack pointer,
FC2464  move      A1,USP                and restore it.
FC2466  lea       $16(A0),SP            Point to the register dump.
FC246A  movem.l   (SP)+,D0-D7/A0-A6     Restore all the other registers.
FC246E  addq.l    #4,SP                 Pop the exception number.
FC2470  rte                             Return from the exception.


        ; Subroutine to initialize ROM-Wack's data area.

FC2472  move.l    A6,A0                 Point to data area.
FC2474  move.w    #$75,D0
FC2478  clr.w     (A0)+                 Clear 236 bytes.
FC247A  dbra      D0,FC2478(PC)
FC247E  move.l    #$FC3254,0(A6)        Use primary key bindings.
FC2486  move.l    #$000010,$14(A6)      Frame size = 16 bytes.
FC248E  move.w    #$4E4F,$88(A6)        Use "TRAP #15" for breakpoints.
FC2494  rts       

FC2496  0000                            Padding.

        ; A lot of the functions in ROM-Wack have C compatible entry points
        ; (which get the parameters from the stack), and most of them have
        ; C compatible return values (in D0).  I guess this is to interface
        ; them to other functions, written in C, in the bigger versions of
        ; Wack.  Likewise, the following are probably C interface functions,
        ; but they (and most of the C entry points) aren't used anywhere.


        ; "Peek" function for C.  Takes address, returns 16-bit contents.

FC2498  move.l    4(SP),A0
FC249C  move.l    (A0),D0
FC249E  rts       

        ; I have no idea why this is here twice.

FC24A0  move.l    4(SP),A0
FC24A4  move.w    (A0),D0
FC24A6  rts       

        ; "Poke" function for C.  Takes address and a word, and stores the
        ; word at the address given.

FC24A8  movem.l   4(SP),A0/A1
FC24AE  move.w    A1,(A0)
FC24B0  rts       


        ; Entry point for "user" command.

        ; Takes all the data currently resident on the supervisor
        ; stack (exception stack frame, exception number, register dump,
        ; ROM-Wack data area, and any other stuff), and moves it onto the
        ; user stack.  Then puts the CPU into user mode.

        ; In effect, this switches ROM-Wack from running as part of the
        ; exec kernel (in supervisor mode) to running as a plain, ordinary
        ; task, along with other tasks.  The good side is that the system
        ; can now go and clean up (flush disk buffers, etc), while the
        ; user can go on playing with ROM-Wack.  The bad side is that the
        ; task which did Debug() or trapped into ROM-Wack is stuck there
        ; forever.  "go", and "resume" commands will no longer work.

FC24B2  move.l    $84(A6),A0            Point to data area on stack.
FC24B6  btst      #5,4(A0)              Was CPU in supervisor mode?
FC24BC  bne.s     FC24EC                If not, exit.
FC24BE  move.l    6(A0),A1              Get the user stack pointer.
FC24C2  lea       -$5C(A1),A1           Reserve 92 bytes on user stack.
FC24C6  move.l    A1,$84(A6)            Make this the new data area.
FC24CA  lea       $5C(A1),A1            Point to top of new data area.
FC24CE  add.w     #$5C,A0               Point to top of old data area.
FC24D2  move.l    A0,D1                 Save the supervisor stack pointer.
FC24D4  move.l    A0,D0
FC24D6  sub.l     SP,D0
FC24D8  bra.s     FC24DC                Copy exception stack frame, register
FC24DA  move.b    -(A0),-(A1)           dump, data area, and any other stuff
FC24DC  dbra      D0,FC24DA(PC)         to the user stack.
FC24E0  move.l    D1,SP                 Bump supervisor stack pointer up.
FC24E2  move      A1,USP                Bump user stack pointer down.
FC24E4  move.l    $84(A6),A0
FC24E8  move      4(A0),SR              Get the saved status register.
FC24EC  bsr       FC2A72                Print a newline.
FC24F0  rts       


        ; String compare function.  This checks if a command entered by
        ; the user, pointed to by A1, matches a command, pointed to by A0,
        ; from the command table.  It returns zero if so, else it returns
        ; the character number at which the mismatch occurred.

        ; C style entry point.

FC24F2  movem.l   4(SP),A0/A1

        ; Assembler entry point.

FC24F8  moveq     #-1,D0
FC24FA  move.b    (A0)+,D1              Get a byte from reference string.
FC24FC  beq.s     FC2508                End of string?
FC24FE  cmp.b     (A1)+,D1              Compare to byte from second string.
FC2500  dbne      D0,FC24FA(PC)         Loop while strings are equal.
FC2504  neg.l     D0                    Compute number of equal characters.
FC2506  bra.s     FC250E                Exit.

FC2508  cmp.b     (A1)+,D1              Check if other string ends also.
FC250A  bne.s     FC250E
FC250C  moveq     #0,D0                 Return zero (strings match).
FC250E  rts       


        ; Entry point for <Return> command (Redisplay frame).

FC2510  move.b    #1,$1E(A6)            Request redisplay of current frame.
FC2516  rts       


        ; I don't know what this is for.  It's not referenced anywhere.

FC2518  move.l    8(A6),D0
FC251C  move.l    D0,-(SP)
FC251E  addq.l    #4,SP
FC2520  rts       


        ; Entry point for ">", <Space> commands (Move forward a word).

FC2522  addq.l    #2,$0C(A6)            Increment current address by 1 word.
FC2526  move.b    #1,$1E(A6)            Request frame display.
FC252C  btst      #1,$1F(A6)
FC2532  beq.s     FC2540
FC2534  bsr       FC2A72                Print a newline.
FC2538  bsr       FC261A
FC253C  clr.b     $1E(A6)
FC2540  rts       


        ; Entry point for "<", <Backspace> commands (Move back a word).

FC2542  subq.l    #2,$0C(A6)            Decrement current address by 1 word.
FC2546  move.b    #1,$1E(A6)            Request frame display.
FC254C  btst      #1,$1F(A6)
FC2552  beq.s     FC2560
FC2554  bsr       FC2A72                Print a newline.
FC2558  bsr       FC261A
FC255C  clr.b     $1E(A6)
FC2560  rts       


        ; Entry point for "." command (move forward a frame).

FC2562  move.l    $14(A6),D0            Get frame size.
FC2566  add.l     D0,$0C(A6)            Add to current address.
FC256A  move.b    #1,$1E(A6)            Request frame display.
FC2570  rts       


        ; Entry point for "," command (move back a frame).

FC2572  move.l    $14(A6),D0            Get frame size.
FC2576  sub.l     D0,$0C(A6)            Subtract from current address.
FC257A  move.b    #1,$1E(A6)            Request frame display.
FC2580  rts       


        ; Entry point for "[" command.

        ; This follows a pointer at the current address.

FC2582  move.l    $26(A6),A1            Get indirection stack pointer.
FC2586  move.l    $0C(A6),A0            Get current location.
FC258A  move.l    A0,(A1)+              Store in indirection stack.
FC258C  move.l    A1,$26(A6)            Put indirection stack pointer back.
FC2590  moveq     #-2,D0                Make the current location even.
FC2592  and.l     (A0),D0               Get the pointer.
FC2594  move.l    D0,$0C(A6)            Put it in the current location.
FC2598  move.b    #1,$1E(A6)            Request display of frame.
FC259E  rts       


        ; Entry point for "]" command.

        ; This walks undoes a "[" command, good for walking back along
        ; singly linked lists or backing out of nested structure pointers.

FC25A0  move.l    $26(A6),A1            Get indirection stack pointer.
FC25A4  move.l    -(A1),$0C(A6)         Get address from indirection stack.
FC25A8  move.b    #1,$1E(A6)            Request frame display.
FC25AE  move.l    A1,$26(A6)            Update the indirection stack pointer.
FC25B2  rts       


        ; Entry point for "+" command.

FC25B4  moveq     #$2B,D0               Echo "+" on the user's terminal.
FC25B6  bsr       FC222E
FC25BA  bsr       FC2BF0                Read a number from the keyboard.
FC25BE  tst.l     D0
FC25C0  beq       FC2A72                If none, print newline and exit.
FC25C4  move.l    8(A6),D0              Get the number which was entered.
FC25C8  add.l     D0,$0C(A6)            Add to current address.
FC25CC  move.b    #1,$1E(A6)            Request frame redisplay.
FC25D2  rts       


        ; Entry point for "-" command.

FC25D4  moveq     #$2D,D0               Echo "-" on the user's terminal.
FC25D6  bsr       FC222E
FC25DA  bsr       FC2BF0                Read a number from the keyboard.
FC25DE  tst.l     D0
FC25E0  beq       FC2A72                If none, print newline and exit.
FC25E4  move.l    8(A6),D0              Get the number which was entered.
FC25E8  sub.l     D0,$0C(A6)            Subtract from the current address.
FC25EC  move.b    #1,$1E(A6)            Request frame redisplay.
FC25F2  rts       


        ; The following isn't referenced anywhere.  Perhaps an outdated
        ; bit of code to set the current address to the last number entered.
        ; This is now unnecessary.

FC25F4  move.l    8(A6),$0C(A6)
FC25FA  move.b    #1,$1E(A6)
FC2600  rts       


        ; Entry point for ":" command (set frame size).

FC2602  moveq     #$3A,D0               Echo ":" on the terminal.
FC2604  bsr       FC222E
FC2608  bsr       FC2BF0                Get a number from the terminal.
FC260C  move.l    8(A6),$14(A6)         Set the frame size.
FC2612  move.b    #1,$1E(A6)            Request frame redisplay.
FC2618  rts       


        ; Routine to print a prompt for memory-modify commands.

FC261A  move.l    $0C(A6),D0            Get the current address.
FC261E  bsr       FC2780                Print it (6 digits).
FC2622  tst.l     $14(A6)               Is the frame size zero?
FC2626  beq.s     FC2638                If frame size is not zero, then
FC2628  move.l    D0,A0
FC262A  move.w    (A0),D0                 Get word at current address.
FC262C  bsr       FC2788                  Print it (4 digits).
FC2630  moveq     #$3D,D0                 Print "=".
FC2632  bsr       FC222E
FC2636  bra.s     FC2640                Else
FC2638  lea       FC2668(PC),A0           Print "xxxx ="
FC263C  bsr       FC2278                Endif
FC2640  rts       


        ; Entry point for "=" command (modify one word of memory).

        ; This is also used by the "alter" routine below.  It returns 1
        ; if a value was entered, and 0 if not.

FC2642  bsr.s     FC261A                Print a prompt.
FC2644  bsr       FC2BF0                Get a number from the terminal.
FC2648  tst.l     D0                    Did we get one?
FC264A  beq.s     FC2658
FC264C  move.l    $0C(A6),A0            If so, update the word pointed
FC2650  move.l    8(A6),D0              to by the current address with the
FC2654  move.w    D0,(A0)               data which was entered, and return
FC2656  moveq     #1,D0                 a non-zero value.
FC2658  btst      #1,$1F(A6)            Are we in "alter" mode?
FC265E  bne.s     FC2666
FC2660  move.b    #1,$1E(A6)            If not, request frame redisplay.
FC2666  rts       

FC2668  "xxxx =", 00, 00


        ; Entry point for "alter" command.

FC2670  bset      #1,$1F(A6)            Set "alter mode" flag.
FC2676  bsr       FC2A72                Print a newline.
FC267A  bsr.s     FC2642                Do an "=" command.
FC267C  tst.l     D0
FC267E  beq.s     FC2686                If a value was entered, increase the
FC2680  addq.l    #2,$0C(A6)            current location by 2, and loop back.
FC2684  bra.s     FC2676

FC2686  bclr      #1,$1F(A6)            Clear "alter mode" flag.
FC268C  bsr       FC2A72                Print a newline.
FC2690  rts       


        ; I don't know what this is for.  Perhaps a remnant from an old
        ; version of ROM-Wack, or something from a bigger version of Wack.
        ; It's not called from anywhere.

FC2692  lea       FC269C(PC),A0         Point to the string below.
FC2696  bsr       FC2278                Print it.
FC269A  rts       

FC269C  LF, "not yet implemented", LF, 00


        ; Entry point for "list" command.

        ; This will traverse a standard exec list, displaying information
        ; about each node.  It should be called when the current address is
        ; either that of the list header, or of any node.

FC26B2  move.l    A2,-(SP)
FC26B4  move.l    $0C(A6),A2            Get the current address.
FC26B8  tst.l     4(A2)                 List header ("Tail" field zero)?
FC26BC  bne.s     FC26C0
FC26BE  move.l    (A2),A2               If yes, go to first node.
FC26C0  move.l    (A2),D0               See if now at end of list (or empty).
FC26C2  beq.s     FC26F4                If no more nodes, exit.
FC26C4  move.l    $0A(A2),D0            Get the node's name.
FC26C8  bne.s     FC26D0                If name pointer is null, replace
FC26CA  move.l    #$FC271E,D0           it with a pointer to a zero.
FC26D0  move.l    D0,-(SP)              Save name pointer on stack.
FC26D2  moveq     #0,D0
FC26D4  move.b    9(A2),D0              Get priority field.
FC26D8  move.l    D0,-(SP)              Put it on the stack.
FC26DA  move.b    8(A2),D0              Get type field.
FC26DE  move.l    D0,-(SP)              Put it on the stack.
FC26E0  pea       (A2)                  Put node address to stack.
FC26E2  move.l    SP,A1                 Point to data on stack.
FC26E4  lea       FC26FC(PC),A0         Point to format string below.
FC26E8  bsr       FC22D2                RawDoFmt() to serial port.
FC26EC  lea       $14(SP),SP            Pop data back off the stack.
FC26F0  move.l    (A2),A2               Move to next node.
FC26F2  bra.s     FC26C0                Loop until no more nodes.
FC26F4  bsr       FC2A72                Print a newline.
FC26F8  move.l    (SP)+,A2
FC26FA  rts       

FC26FC  LF, "%06lx  type %-2ld  pri %-4ld "%s"", 00, 00


        ; Subroutine to display a "frame" of data from memory.  On entry,
        ; the address of the frame is given in D0, and its size in D1.

        ; Data is displayed in lines of up to 8 words, and as an address,
        ; followed by hex words, followed by their ASCII character
        ; equivalents.

FC2720  movem.l   D0/D2/D3/A2/A3,-(SP)
FC2724  link      A5,#-$28              Reserve 40 bytes of stack space.
FC2728  bsr       FC2A72                Print a newline.
FC272C  move.l    D0,A2
FC272E  move.l    D1,D2                 Set number of bytes remaining.
FC2730  beq.s     FC2770                Just exit if frame size is zero.

        ; Outer loop:  Display one line of the frame.

FC2732  move.l    A2,D0
FC2734  bsr.s     FC2780                Print the address.
FC2736  moveq     #7,D3                 Maximum 8 words per line.
FC2738  lea       -$20(A5),A3           Point to reserved stack space.

        ; Inner loop:  Display one word of data.

FC273C  move.w    (A2)+,D0              Get a word from memory.
FC273E  bsr.s     FC2788                Print it.
FC2740  move.l    D0,-(SP)
FC2742  lsr.w     #8,D0                 Get high 8 bits of current word.
FC2744  bsr       FC2ABC                Convert to printable data.
FC2748  move.w    D0,(A3)+              Add to character string.
FC274A  move.l    (SP)+,D0
FC274C  bsr       FC2ABC                Do likewise for low 8 bits.
FC2750  move.w    D0,(A3)+
FC2752  subq.l    #2,D2                 Decrement number of bytes remaining.
FC2754  ble.s     FC2766                Exit if zero,
FC2756  dbra      D3,FC273C(PC)         otherwise continue until line full.

        ; End of line reached.

FC275A  clr.w     (A3)+                 Mark end of character string.
FC275C  lea       -$20(A5),A0           Point to beginning.
FC2760  bsr       FC2A86                Print the string and a newline.
FC2764  bra.s     FC2732                Go and do next line.

        ; End of frame reached.

FC2766  clr.w     (A3)+                 Mark end of character string.
FC2768  lea       -$20(A5),A0           Point to beginning.
FC276C  bsr       FC2A86                Print the string and a newline.
FC2770  unlk      A5
FC2772  movem.l   (SP)+,D0/D2/D3/A2/A3
FC2776  rts       


        ; Subroutine to display an 8-digit hex number.

FC2778  movem.l   D0/D1/A0/A1,-(SP)
FC277C  moveq     #8,D1                 8 digits.
FC277E  bra.s     FC278E


        ; Subroutine to display a 6-digit hex number (address).

FC2780  movem.l   D0/D1/A0/A1,-(SP)
FC2784  moveq     #6,D1                 6 digits.
FC2786  bra.s     FC278E


        ; Subroutine to display a 4-digit hex number.

FC2788  movem.l   D0/D1/A0/A1,-(SP)
FC278C  moveq     #4,D1                 4 digits.
FC278E  bsr       FC2294                Go print the number.
FC2792  movem.l   (SP)+,D0/D1/A0/A1
FC2796  rts       


        ; Subroutine to print the "DR:", "AR:", and "SF:" portions of
        ; the ROM-Wack register frame.

FC2798  movem.l   D2/A2,-(SP)
FC279C  move.l    A0,A2
FC279E  moveq     #7,D2                 7 Data registers.
FC27A0  lea       FC2864(PC),A0         Point to "\nDR: " string.
FC27A4  bsr.s     FC27D8                Display data registers.
FC27A6  moveq     #6,D2                 6 Address registers.
FC27A8  lea       FC286A(PC),A0         Point to "\nAR: " string.
FC27AC  bsr.s     FC27D8                Display address registers.
FC27AE  addq.l    #4,A2                 Skip exception number on stack.
FC27B0  btst      #5,(A2)               Supervisor mode?
FC27B4  bne.s     FC27BC
FC27B6  sub.w     #$50,A2               If not, get saved USP.
FC27BA  move.l    (A2),A2
FC27BC  lea       FC2870(PC),A0         Point to "\nSF: " string.
FC27C0  bsr       FC2278                Print it.
FC27C4  moveq     #$0E,D2
FC27C6  move.w    (A2)+,D0              Display 14 words of stack data.
FC27C8  bsr.s     FC2788
FC27CA  dbra      D2,FC27C6(PC)
FC27CE  bsr       FC2A72                Print a newline.
FC27D2  movem.l   (SP)+,D2/A2
FC27D6  rts       


        ; Subroutine to print a string pointed to by A0, followed by (D2)
        ; longwords from memory pointed to by A2.

FC27D8  bsr       FC2278                Print the string.
FC27DC  move.l    (A2)+,D0
FC27DE  bsr.s     FC2778                Loop and print all the data.
FC27E0  dbra      D2,FC27DC(PC)
FC27E4  rts       


        ; Subroutine to print the first ("PC: ...") line of the register
        ; frame, followed by the rest of the register frame via the routine
        ; above.  Note, we just give RawDoFmt() a format string describing
        ; the data structure on the supervisor stack

        ; Also entry point for "regs" command.

FC27E6  move.l    $84(A6),A1            Get pointer to stack-resident data.
FC27EA  move.l    A1,-(SP)
FC27EC  lea       FC27FC(PC),A0         Point to format string.
FC27F0  bsr       FC22D2                Format the data.
FC27F4  move.l    (SP)+,A1
FC27F6  lea       $16(A1),A0            Point to the register dump area.
FC27FA  bra.s     FC2798                Print it.


        ; Text strings used to display register frames.  The second one
        ; isn't used anywhere.

FC27FC  LF, "PC: %06lx  SR: %04x  USP: %06lx  SSP: %06lx  XCPT: "
FC2830  "%04lx  TASK: %06lx", 00

FC2843  LF, "PC: %06lx  SR: %04x  USP: %06lx", 00

FC2864  LF, "DR: ", 00
FC286A  LF, "AR: ", 00
FC2870  LF, "SF: ", 00


        ; Memory fill routine.  Fills (D1) words, starting at (D0), with
        ; the value in D2.  Not used anywhere.

FC2876  move.l    A2,-(SP)
FC2878  move.l    D0,A2
FC287A  bra.s     FC287E
FC287C  move.w    D2,(A2)+
FC287E  dbra      D1,FC287C(PC)
FC2882  move.l    (SP)+,A2
FC2884  rts       


        ; Subroutine to find a breakpoint in the breakpoint table, given
        ; its address.  If successful, returns address of breakpoint table
        ; entry, if not, returns zero.

FC2886  bsr       FC2A72                Print a newline.
FC288A  lea       $8A(A6),A0            Point to breakpoint table.
FC288E  moveq     #$0F,D1
FC2890  cmp.l     (A0),A1               Scan breakpoint table for a
FC2892  beq.s     FC289E                breakpoint address matching A1.
FC2894  addq.l    #6,A0
FC2896  dbra      D1,FC2890(PC)
FC289A  moveq     #0,D0                 Not found, so return zero.
FC289C  rts       
FC289E  move.l    A0,D0                 Return address of table entry.
FC28A0  rts       

        ; Entry point for "clear" command.

        ; Deactivate the breakpoint at the current program address,
        ; if there is one.

FC28A2  move.l    $0C(A6),A1            Get current address.
FC28A6  bsr.s     FC2886                See if it is a breakpoint address.
FC28A8  beq.s     FC28B0
FC28AA  clr.l     (A0)                  If so, deactivate it and write the
FC28AC  move.w    4(A0),(A1)            original instruction back.
FC28B0  rts       


        ; Entry point for "reset" command.

        ; Deactivates all breakpoints.

FC28B2  lea       $8A(A6),A1            Point to ROM-Wack's breakpoint table.
FC28B6  moveq     #$0F,D1               Size of breakpoint table - 1.
FC28B8  move.l    (A1),D0               Get breakpoint address.
FC28BA  beq.s     FC28C4                If breakpoint in use then
FC28BC  move.l    D0,A0
FC28BE  clr.l     (A1)                    Clear breakpoint address.
FC28C0  move.w    4(A1),(A0)              Fix instruction at breakpoint.
                                        Endif
FC28C4  addq.l    #6,A1                 Go to next table entry.
FC28C6  dbra      D1,FC28B8(PC)         Loop until whole table done.
FC28CA  bsr       FC2A72                Print a newline.
FC28CE  rts       


        ; Entry point for "set" command.

        ; Activates a breakpoint at the current address.

FC28D0  move.l    $0C(A6),A1            Get current address.
FC28D4  bsr.s     FC2886                See if it is a breakpoint.
FC28D6  bne.s     FC28FC                If so, do nothing.
FC28D8  lea       $8A(A6),A0
FC28DC  moveq     #$0F,D1               Scan the breakpoint table for an
FC28DE  tst.l     (A0)                  unused entry.
FC28E0  beq.s     FC28F2
FC28E2  addq.l    #6,A0
FC28E4  dbra      D1,FC28DE(PC)

        ; No unused breakpoint table entry found.

FC28E8  lea       FC28FE(PC),A0         Point at "too many" string.
FC28EC  bsr       FC2278                Print it.
FC28F0  bra.s     FC28FC                Return.

        ; Unused entry in the breakpoint table found.  Activate a breakpoint.

FC28F2  move.w    (A1),4(A0)            Save instruction at breakpoint.
FC28F6  move.w    $88(A6),(A1)          Replace with TRAP #15.
FC28FA  move.l    A1,(A0)               Save the breakpoint address.
FC28FC  rts       

FC28FE  LF, "too many", LF, 00, 00


        ; Entry point for "show" command.

        ; Lists all active breakpoints.

FC290A  lea       $8A(A6),A0            Point to breakpoint table.
FC290E  moveq     #$0F,D1               Loop for 16 entries.
FC2910  move.l    (A0),D0               Get current breakpoint address.
FC2912  beq.s     FC291C                Skip if zero.
FC2914  bsr       FC2A72                Print a newline.
FC2918  bsr       FC2780                Print the breakpoint address.
FC291C  addq.l    #6,A0                 Go to next table entry.
FC291E  dbra      D1,FC2910(PC)         Loop until done.
FC2922  bsr       FC2A72                Print a newline.
FC2926  rts       

FC2928  rts                             Garbage.


        ; Subroutine to get a character and echo it to the user.

FC292A  bsr       FC2222                Get a character.
FC292E  move.l    D0,-(SP)
FC2930  bsr       FC222E                Echo it back.
FC2934  move.l    (SP)+,D0
FC2936  rts       

        ; Entry point for "!" command (Modify a register).

FC2938  movem.l   D2/A2,-(SP)
FC293C  moveq     #$21,D0               Print "!".
FC293E  bsr       FC222E
FC2942  bsr.s     FC292A                Get a character.
FC2944  bsr       FC2D48                Convert to upper case.
FC2948  move.l    $84(A6),A1            Get pointer to stack-resident data.
FC294C  lea       $16(A1),A0            Point to data register dump area.
FC2950  moveq     #7,D2                 Maximum data register # = 7.
FC2952  cmp.b     #'D',D0               [D]ata register?
FC2956  beq.s     FC2970
FC2958  lea       $20(A0),A0            Point to address register dump.
FC295C  moveq     #6,D2                 Maximum address register # = 6.
FC295E  cmp.b     #'A',D0               [A]ddress register?
FC2962  beq.s     FC2970
FC2964  lea       6(A1),A2              Point to user stack pointer.
FC2968  cmp.b     #'U',D0               [U]SP?
FC296C  beq.s     FC298C                If so, go change it.
FC296E  bra.s     FC29A8                Otherwise, exit.

        ; Enter here with A0 pointing to a dump area containing sequential
        ; images of the address or data registers, and D2 containing the
        ; maximum register number.

FC2970  bsr.s     FC292A                Get a character.
FC2972  cmp.w     #8,D0                 Backspace?
FC2976  beq.s     FC29A8                If so, exit.
FC2978  bsr       FC2AAC                Is it a digit?
FC297C  bne.s     FC29A8                If not, exit.
FC297E  sub.w     #$30,D0               Convert to number.
FC2982  cmp.b     D0,D2                 Greater than maximum?
FC2984  blt.s     FC29A8                If so, exit.
FC2986  lsl.w     #2,D0                 Compute offset to given register.
FC2988  lea       0(A0,D0.w),A2         Compute address of register.

        ; Enter here with A2 pointing to a longword containing the image
        ; of the register to modify.

FC298C  move.l    (A2),D0               Get the current value.
FC298E  bsr       FC2A62                Print a space.
FC2992  bsr       FC2778                Display value as 8 hex digits.
FC2996  moveq     #$3D,D0               Print "="
FC2998  bsr       FC222E
FC299C  bsr       FC2BF0                Get the new value from the user.
FC29A0  tst.b     D0                    Was a value entered?
FC29A2  beq.s     FC29A8                If not, exit.
FC29A4  move.l    8(A6),(A2)            Update the register.
FC29A8  bsr       FC2A72                Print a newline.
FC29AC  movem.l   (SP)+,D2/A2
FC29B0  rts       


        ; Entry point for "^" and "limit" commands.

        ; This copies the current address to the "limit" address, i.e. the
        ; address to stop searching or filling memory at.

FC29B2  move.l    $0C(A6),$18(A6)       Copy current address to limit.
FC29B8  move.b    #1,$1E(A6)            Request frame redisplay.
FC29BE  rts       


        ; Entry point for "find" command.

FC29C0  movem.l   A2/A3,-(SP)
FC29C4  bsr.s     FC2A04                Get the search pattern.
FC29C6  beq.s     FC29D4                Exit if none entered.
FC29C8  bsr.s     FC29E0                Do the searching.
FC29CA  beq.s     FC29D4                Exit if not found.
FC29CC  bclr      #0,D0                 Round result address down to even.
FC29D0  move.l    D0,$0C(A6)            Store it in current address.
FC29D4  move.b    #1,$1E(A6)            Request frame redisplay.
FC29DA  movem.l   (SP)+,A2/A3
FC29DE  rts       

        ; Search routine for the "find" command.

FC29E0  move.l    A4,-(SP)
FC29E2  lea       -2(A0),A4             Start searching at start address - 2.

FC29E6  move.l    D0,D1                 Set the number of bytes to match.
FC29E8  move.l    A3,A1                 Set the search pattern address.
FC29EA  addq.l    #1,A4                 Go to next address.
FC29EC  move.l    A4,A0
FC29EE  cmp.l     A0,A2                 See if limit address reached.
FC29F0  ble.s     FC29FE                If so, return false.
FC29F2  cmpm.b    (A1)+,(A0)+           Compare one byte.
FC29F4  bne.s     FC29E6                Go to next address if mismatch.
FC29F6  subq.w    #1,D1                 Decrement byte counter.
FC29F8  bgt.s     FC29EE                Loop until all matched.
FC29FA  move.l    A4,D0                 Found: return the address where.
FC29FC  bra.s     FC2A00
FC29FE  moveq     #0,D0                 Return false.
FC2A00  move.l    (SP)+,A4
FC2A02  rts       

        ; Search/fill pattern input routine.  Prompts for a pattern,
        ; accepts it, and returns the following:

        ;   D0: Number of bytes in search pattern.
        ;   D1: True if pattern entered, false if aborted.
        ;   A0: Lower bound for search.
        ;   A2: Upper bound for search.
        ;   A3: Address of search pattern.

FC2A04  lea       FC2A2C(PC),A0         Point to "pattern? " string.
FC2A08  bsr       FC2278                Print it.
FC2A0C  bsr       FC2BF0                Get a number from the terminal.
FC2A10  tst.w     D0                    Did we get one?
FC2A12  beq.s     FC2A2A                If not, return false.
FC2A14  addq.w    #1,D0
FC2A16  lsr.w     #1,D0                 Compute 4-(d+1)/2, where d is the
FC2A18  moveq     #4,D1                 number of digits entered.
FC2A1A  sub.w     D0,D1
FC2A1C  lea       8(A6,D1.w),A3         Get the number entered.
FC2A20  move.l    $0C(A6),A0            Get the current address,
FC2A24  move.l    $18(A6),A2            and the limit address.
FC2A28  moveq     #1,D1                 Return true.
FC2A2A  rts       

FC2A2C  " pattern? ", 00, 00


        ; Entry point for "fill" command.

FC2A38  movem.l   A2/A3,-(SP)
FC2A3C  bsr.s     FC2A04                Get the fill pattern.
FC2A3E  beq.s     FC2A42
FC2A40  bsr.s     FC2A4E                If one entered, go do the fill.
FC2A42  move.b    #1,$1E(A6)            Request frame redisplay.
FC2A48  movem.l   (SP)+,A2/A3
FC2A4C  rts       

        ; Fill routine for the "fill" command.

FC2A4E  subq.l    #1,D0                 Adjust number of bytes for "dbra".
FC2A50  move.l    D0,D1                 Initialize loop counter.
FC2A52  move.l    A3,A1                 Initialize pattern address.
FC2A54  cmp.l     A0,A2                 Upper limit reached?
FC2A56  ble.s     FC2A60                Exit if so.
FC2A58  move.b    (A1)+,(A0)+           Copy one byte from the fill pattern.
FC2A5A  dbra      D1,FC2A54(PC)         Loop until pattern done.
FC2A5E  bra.s     FC2A50                Loop back and do pattern again.
FC2A60  rts       


        ; Subroutine to print a single space.

FC2A62  movem.l   D0/D1/A0/A1,-(SP)
FC2A66  moveq     #$20,D0               Character code for a space.
FC2A68  bsr       FC222E                RawPutChar()
FC2A6C  movem.l   (SP)+,D0/D1/A0/A1
FC2A70  rts       


        ; Subroutine to print a single newline.

FC2A72  movem.l   D0/D1/A0/A1,-(SP)
FC2A76  lea       FC2A84(PC),A0         Point to string below.
FC2A7A  bsr       FC2278                Print it.
FC2A7E  movem.l   (SP)+,D0/D1/A0/A1
FC2A82  rts       

FC2A84  LF, 00


        ; Subroutine to print string at address pointed to by A0, followed
        ; by a newline.

FC2A86  movem.l   D0/D1/A0/A1,-(SP)
FC2A8A  bsr       FC2278                Print the string.
FC2A8E  bsr.s     FC2A72                Print a newline.
FC2A90  movem.l   (SP)+,D0/D1/A0/A1
FC2A94  rts       


        ; I don't know what this is for.  It's not referenced anywhere.

FC2A96  moveq     #$0D,D0
FC2A98  rts       


        ; Subroutine to get a character.  Returns with the zero flag clear
        ; if a character was received, set otherwise.

FC2A9A  movem.l   D0/D1/A0/A1,-(SP)
FC2A9E  bsr       FC2202
FC2AA2  cmp.w     #$FFFF,D0
FC2AA6  movem.l   (SP)+,D0/D1/A0/A1
FC2AAA  rts       


        ; Isdigit() type of function.  Enter with a character in D0, returns
        ; with the zero flag set if the character is a numeric digit.

FC2AAC  cmp.b     #'0',D0
FC2AB0  blt.s     FC2ABA
FC2AB2  cmp.b     #'9',D0
FC2AB6  bgt.s     FC2ABA
FC2AB8  cmp.b     D0,D0
FC2ABA  rts       


        ; Subroutine to convert an 8-bit code in D0 to a 2 character
        ; printable ASCII version.

        ; Codes 0 and 128-255 return "..", control codes are shown as "^A"
        ; to "^\", other characters are shown as a space, then the actual
        ; character.

FC2ABC  move.l    D2,-(SP)
FC2ABE  move.w    #$2E2E,D2             Move ".." into D2.
FC2AC2  tst.b     D0                    Is the code zero?
FC2AC4  beq.s     FC2AE2                If so, return ".." and exit.
FC2AC6  btst      #7,D0                 Is the high bit set?
FC2ACA  bne.s     FC2AE2                If so, return ".." and exit.
FC2ACC  move.w    #$2000,D2             Move space and null into D2.
FC2AD0  move.b    D0,D1
FC2AD2  and.b     #$E0,D1               If the character is a control code,
FC2AD6  bne.s     FC2AE0
FC2AD8  move.w    #$5E00,D2               Move "^" and null into D2.
FC2ADC  or.b      #$40,D0                 Convert to printable character.
FC2AE0  move.b    D0,D2                   Put it into D2.
                                        Endif
FC2AE2  move.l    D2,D0                 Return D2.
FC2AE4  move.l    (SP)+,D2
FC2AE6  rts       


        ; ROM-Wack command execution function.  Calls the command function
        ; given in A0, and on return, displays the current "frame" if
        ; requested by the command function.

FC2AE8  clr.b     $1E(A6)
FC2AEC  move.l    4(SP),A0              Get the command function address.
FC2AF0  jsr       (A0)                  Execute the function.
FC2AF2  tst.b     $1E(A6)               Need to display frame?
FC2AF6  beq.s     FC2B04                Exit if not.
FC2AF8  move.l    $0C(A6),D0            Get current address.
FC2AFC  move.l    $14(A6),D1            Get frame size.
FC2B00  bsr       FC2720                Display the frame.
FC2B04  rts       


        ; Entry point for "?" command (Display multi-character commands).

FC2B06  move.l    A2,-(SP)
FC2B08  move.l    #$FC33A6,A2           Point to ROM-Wack command table.
FC2B0E  move.b    (A2)+,D0              Get a character.
FC2B10  beq.s     FC2B18
FC2B12  bsr       FC222E                If not zero, print it, and loop
FC2B16  bra.s     FC2B0E                back to do the next one.
FC2B18  bsr       FC2A62                Print a space.
FC2B1C  tst.b     (A2)                  Another zero?
FC2B1E  bne.s     FC2B0E                If not, loop back & print next cmd.
FC2B20  bsr       FC2A72                Print a newline.
FC2B24  move.l    (SP)+,A2
FC2B26  rts       


        ; ROM-Wack command dispatch table scanner.

        ; Enter with a character code in D0.  This routine runs through the
        ; command table, and returns either the address of the command table
        ; entry matching the character, or zero.

        ; Each command table entry either corresponds to exactly one
        ; character, or to a range of characters.  This may sound confusing,
        ; but I've commented the command table itself, so you can just look
        ; there and it will be perfectly obvious.

FC2B28  move.l    D0,D1
FC2B2A  move.l    0(A6),A0              Point to command table.
FC2B2E  bra.s     FC2B3C
FC2B30  move.l    (A0),D0               Get link to next table entry.
FC2B32  and.l     #$FFFFFF,D0           Strip off high 8 bits.
FC2B38  beq.s     FC2B4C                Exit if no next entry.
FC2B3A  move.l    D0,A0                 Point ot next entry.
FC2B3C  cmp.b     4(A0),D1              See if command matches table entry.
FC2B40  beq.s     FC2B4A                Exit if it does.
FC2B42  blt.s     FC2B30                Go to next entry if smaller.
FC2B44  cmp.b     5(A0),D1              Check if in range.
FC2B48  bgt.s     FC2B30                Go to next entry if not.
FC2B4A  move.l    A0,D0                 Return table entry address.
FC2B4C  rts       


        ; ROM-Wack command dispatcher.  Given a command character, looks it
        ; up in the command dispatch table and executes the command if found.

        ; C style entry point.

FC2B4E  move.l    4(SP),D0

        ; Assembler entry point.

FC2B52  bsr.s     FC2B28                Look command up in command table.
FC2B54  tst.l     D0                    Found it?
FC2B56  beq.s     FC2B64                Exit if not.
FC2B58  move.l    D0,A0
FC2B5A  move.l    6(A0),-(SP)           Get execution address from table
                                        and store it on the stack.
FC2B5E  bsr       FC2AE8                Execute the function.
FC2B62  addq.l    #4,SP                 Pop address back off the table.
FC2B64  rts       


        ; Multi-character command lookup function.

        ; This takes a pointer to a command string in A0, and looks it up
        ; in the table of multi-character commands.  It returns the address
        ; of the table entry corresponding to the command, or zero if the
        ; command was not found.

        ; C style entry point.

FC2B66  move.l    4(SP),A0

        ; Assembler entry point.

FC2B6A  movem.l   A2/A3,-(SP)
FC2B6E  move.l    A0,A2
FC2B70  lea       FC33F4,A3             Point at command dispatch table.
FC2B76  bra.s     FC2B7E
FC2B78  move.l    (A3),D0               Get pointer to next table entry.
FC2B7A  beq.s     FC2B8E                Exit if null (end of table).
FC2B7C  move.l    D0,A3
FC2B7E  move.l    4(A3),A0              Get pointer to string.
FC2B82  move.l    A2,A1                 Point to string to match.
FC2B84  bsr       FC24F8                Compare them.
FC2B88  tst.l     D0                    Got a match?
FC2B8A  bne.s     FC2B78                Keep looking if not.
FC2B8C  move.l    A3,D0                 Return table address.
FC2B8E  movem.l   (SP)+,A2/A3
FC2B92  rts       


        ; ROM-Wack main loop:  Gets a character from the user, then
        ; interprets it, then gets next characer, etc.

FC2B94  bsr       FC2222                Get a character from the user.
FC2B98  move.b    D0,$82(A6)            Store it.
FC2B9C  bsr.s     FC2B52                Process it.
FC2B9E  bra.s     FC2B94                Go get next character.


        ; Entry point for letters, numbers and underline characters typed
        ; at the ROM-Wack command level.  This function collects them in
        ; a buffer.

FC2BA0  lea       FC3334,A0             Address of secondary key bindings.
FC2BA6  cmp.l     0(A6),A0              Already using them?
FC2BAA  beq.s     FC2BBE

        ; This is the first character of a multi character command, so
        ; clear the buffer and point to the other set of key bindings.

FC2BAC  clr.w     $1C(A6)               Zero characters in buffer so far.
FC2BB0  move.l    0(A6),4(A6)           Save address of primary key bindings.
FC2BB6  move.l    #$FC3334,0(A6)        Point at secondary key bindings.

FC2BBE  cmp.b     #' ',$82(A6)          Was the key a space?
FC2BC4  beq.s     FC2BEA                If so, ignore it (kludge, see below).
FC2BC6  move.w    $1C(A6),D0            Get number of chars in buffer
FC2BCA  cmp.w     #$32,D0               50 characters already?
FC2BCE  bge.s     FC2BEA                If equal or more, ignore this one.
FC2BD0  move.b    $82(A6),D0            Get command character.
FC2BD4  bsr       FC222E                Echo it to the user.
FC2BD8  lea       $50(A6),A0            Point to buffer.
FC2BDC  move.w    $1C(A6),D0            Get offset into buffer.
FC2BE0  move.b    $82(A6),0(A0,D0.w)    Store character in buffer.
FC2BE6  addq.w    #1,$1C(A6)            Increment buffer count.
FC2BEA  clr.w     $20(A6)               There is unprocessed data in the
FC2BEE  rts                             buffer, so set the flag.


        ; Entry point to get a number from the user.

FC2BF0  move.b    #' ',$82(A6)           Start using secondary key bindings.
FC2BF6  bsr.s     FC2BA0
FC2BF8  move.w    #1,$24(A6)             Indicate that input is being
                                         gathered for a specific function.

        ; Loop to read the digits.  We stay in this loop, using the
        ; secondary (input gathering) key bindings until some command
        ; function switches us back to the primary ones.  That means
        ; the user either canceled the line, or pressed RETURN.

FC2BFE  cmp.l     #$FC3334,0(A6)         Using secondary key bindings now?
FC2C06  bne.s     FC2C16                 Exit loop if not.
FC2C08  bsr       FC2222                 Get a key from the user.
FC2C0C  move.b    D0,$82(A6)             Store it in "last key typed".
FC2C10  bsr       FC2B52                 Dispatch it as a command character.
FC2C14  bra.s     FC2BFE                 Loop.

        ; The input line has been processed.  Either it was a command
        ; (and was executed), or it was a number, or it was an error.

FC2C16  clr.w     $24(A6)                Clear "parameter input" flag.
FC2C1A  moveq     #0,D0
FC2C1C  move.b    $22(A6),D0             Get number of digits.
FC2C20  tst.w     $20(A6)                If no useful data in buffer (line
FC2C24  beq.s     FC2C28                 canceled, command already executed,
FC2C26  moveq     #0,D0                  bad symbol...), return zero digits.
FC2C28  rts       


        ; Entry point for <Space> while using the secondary key bindings.

FC2C2A  rts       


        ; Entry point for CTRL-U and CTRL-X.  Point back to the original
        ; set of key bindings, and set the buffer to empty.

FC2C2C  move.w    #$FFFF,$1C(A6)        -1 characters in buffer.
FC2C32  move.l    4(A6),0(A6)           Restore top-level key bindings.
FC2C38  bsr       FC2A72                Print a linefeed.
FC2C3C  move.w    #1,$20(A6)            Buffer contains no useful data.
FC2C42  rts       


        ; Entry point for <Backspace>.  This deletes one charaacter from
        ; the input buffer.

FC2C44  tst.w     $1C(A6)               Any characters in the buffer?
FC2C48  ble.s     FC2C2C                If none, cancel input.
FC2C4A  lea       $50(A6),A0            Point to buffer.
FC2C4E  move.w    $1C(A6),D0            Get buffer offset.
FC2C52  clr.b     0(A0,D0.w)            Clear last character in buffer.
FC2C56  subq.w    #1,$1C(A6)            Decrement buffer count.
FC2C5A  lea       FC2C6A(PC),A0         Point to string below.
FC2C5E  bsr       FC2278                Print it.
FC2C62  tst.w     $1C(A6)               Is buffer now empty?
FC2C66  ble.s     FC2C2C                If so, cancel input.
FC2C68  rts       

        ; String used to erase one character from the user's terminal.

FC2C6A  08, " ", 08, 00


        ; Entry point for <Return>.

FC2C6E  move.l    4(A6),0(A6)           Restore previous key bindings.
FC2C74  lea       $50(A6),A0            Point to input buffer.
FC2C78  move.w    $1C(A6),D0            Get number of characters in it.
FC2C7C  bgt.s     FC2C88
FC2C7E  move.w    #1,$20(A6)            Indicate that no data is in the
                                        buffer waiting for processing.
FC2C84  moveq     #0,D0
FC2C86  rts       

        ; There was data in the buffer, now interpret it.

FC2C88  clr.b     0(A0,D0.w)            Zero-terminate the buffer.
FC2C8C  lea       $50(A6),A0            Point to it.
FC2C90  bsr       FC2B6A                Look command up in table.
FC2C94  tst.l     D0                    Branch if not found.
FC2C96  beq.s     FC2CB0
FC2C98  move.w    #1,$20(A6)            Indicate that buffer was processed.
FC2C9E  move.l    D0,A0                 Get the command table offset.
FC2CA0  move.l    $0A(A0),-(SP)         Get execution address from table.
FC2CA4  bsr       FC2AE8                Execute the command.
FC2CA8  clr.b     $1E(A6)               Clear frame redisplay flag.
FC2CAC  addq.l    #4,SP                 Pop execution address of stack.
FC2CAE  rts       

        ; Continue here if the buffer contained a string not found
        ; in the command table.  For a full Wack, this means it would
        ; either be a number, or a symbol.  For ROM-Wack, it's either
        ; a number or an error.

FC2CB0  lea       $50(A6),A0            Point to the string in the buffer.
FC2CB4  lea       8(A6),A1              Point to input number location.
FC2CB8  bsr       FC2CFC                Interpret input buffer as a number.
FC2CBC  move.b    D0,$22(A6)            Store number of digits.
FC2CC0  bne.s     FC2CD2
FC2CC2  move.w    #1,$20(A6)            If 0 digits (bad hex number), print
FC2CC8  lea       FC2CEA(PC),A0         "unknown symbol", indicate that no
FC2CCC  bsr       FC2278                data is waiting in the buffer, and
FC2CD0  rts                             exit.

        ; Continue here if number of digits was non-zero.  If the number
        ; wasn't being gathered as a parameter to another command, make it
        ; the current location.

FC2CD2  tst.w     $24(A6)               Parameter being gathered?
FC2CD6  bne.s     FC2CE8                Exit if so.
FC2CD8  moveq     #-2,D0                Round number down to even.
FC2CDA  and.l     8(A6),D0
FC2CDE  move.l    D0,$0C(A6)            Set the current location to it.
FC2CE2  bset      #0,$1E(A6)            Request (re)display of frame.
FC2CE8  rts       

FC2CEA  LF, "unknown symbol", LF, 00, 00


        ; Hex number interpreting routine.

FC2CFC  move.l    D2,-(SP)
FC2CFE  moveq     #0,D1                 Start result at zero.
FC2D00  moveq     #-1,D2                Start with "-1 digits".
FC2D02  move.l    D1,D0
FC2D04  bra.s     FC2D0E                Jump into the loop.
FC2D06  addq.l    #5,D0                 Entry point for hex digits:  Add 10.
FC2D08  addq.l    #5,D0
FC2D0A  lsl.l     #4,D1                 Shift previous number left by 4 bits.
FC2D0C  add.l     D0,D1                 Add in new digit.
FC2D0E  addq.l    #1,D2                 Increment digit counter.
FC2D10  move.b    (A0)+,D0              Get a digit from the input string.
FC2D12  beq.s     FC2D3A                Exit if end of string reached.
FC2D14  sub.b     #'0',D0               Subtract '0'.
FC2D18  blt.s     FC2D38                Exit if result less than zero.
FC2D1A  cmp.b     #$0A,D0               Greater than 9?
FC2D1E  blt.s     FC2D0A                Branch if not.
FC2D20  sub.b     #$11,D0               Subtract 17.
FC2D24  blt.s     FC2D38                Exit if result less than zero.
FC2D26  cmp.b     #6,D0                 Branch if less than 7.
FC2D2A  blt.s     FC2D06
FC2D2C  sub.b     #$20,D0               Subtract ('a' - 'A').
FC2D30  blt.s     FC2D38                Branch if less than zero.
FC2D32  cmp.b     #6,D0
FC2D36  blt.s     FC2D06                Branch if less than 7.

        ; If we branch here, the number entered contained an invalid
        ; hexadecimal digit.

FC2D38  moveq     #0,D2                 Return "0 digits".

        ; Branch here if end of string reached with no invalid digits.

FC2D3A  move.l    D1,(A1)               Store result where indicated.
FC2D3C  move.l    D2,D0                 Return number of digits.
FC2D3E  move.l    (SP)+,D2
FC2D40  rts       


        ; Some sort of format string.  Not used anywhere.

FC2D42  " %lx ", 00


        ; Toupper() type of function.  Converts character in D0 to upper
        ; case if necessary.

FC2D48  cmp.b     #'a',D0               Less than 'a'?
FC2D4C  blt.s     FC2D58
FC2D4E  cmp.b     #'z',D0               Greater than 'z'?
FC2D52  bgt.s     FC2D58
FC2D54  sub.b     #$20,D0               If neither, convert to upper case.
FC2D58  rts       

FC2D5A  0000                            Padding.

---------------------------------------------------------------------------
  result = Procure( semaphore, bidMessage )
  D0                A0         A1
---------------------------------------------------------------------------

        ; A Procure/Vacate semaphore is a message port structure plus a
        ; counter.  A task can "lock" the semaphore, by calling Procure().
        ; Further attempts to lock the semaphore won't succeed until the
        ; original locker unlocks the semaphore by Vacate().

        ; A sm_Bids value of -1 indicates that the semaphore is free, zero
        ; indicates it's locked and no one is waiting, 1 means one task is
        ; waiting, etc.

        ; Whenever Procure() is called, a pointer to a message must be
        ; given.  This message is enqueued on the semaphore's port if the
        ; semaphore is not currently available, and returned when the
        ; caller's turn comes up to get the lock.  If the semaphore was
        ; available (sm_Bids = -1), the message is not used.

FC2D5C  addq.w    #1,$22(A0)            Increment the sm_Bids field.
FC2D60  bne.s     FC2D6A                Check if the semaphore was free.
FC2D62  move.l    A1,$10(A0)            If it was, store pointer to the
                                        current locker's message
FC2D66  moveq     #1,D0                 and return TRUE.
FC2D68  rts       
FC2D6A  jsr       -$016E(A6)            If it wasn't, enqueue the message
FC2D6E  moveq     #0,D0                 on the semaphore's port and return
FC2D70  bra.s     FC2D68                FALSE.


---------------------------------------------------------------------------
  Vacate( semaphore )
          A0
---------------------------------------------------------------------------

        ; A task which has successfully obtained a semaphore via Procure()
        ; calls this to release it again.  The sm_Bids field is decremented.
        ; If it was zero and ends up at -1, nobody else was waiting to use
        ; the semaphore.  If it ends up positive, someone else is waiting
        ; and we must send his bid message back to let him know he has it
        ; now.  The first message enqueued on the semaphore's port is the
        ; task which has waited longest and gets it.

FC2D72  clr.l     $10(A0)               Clear pointer to locker's message.
FC2D76  subq.w    #1,$22(A0)            Decrement sm_Bids field.
FC2D7A  bge.s     FC2D7E                Return if it is now -1.
FC2D7C  rts       
FC2D7E  move.l    A0,-(SP)              Save semaphore pointer.
FC2D80  jsr       -$0174(A6)            Dequeue the oldest bid message.
FC2D84  move.l    (SP)+,A0              Restore semaphore pointer.
FC2D86  move.l    D0,$10(A0)            Store pointer to the message.
FC2D8A  beq.s     FC2D7C                Exit if no message (error).
FC2D8C  move.l    D0,A1
FC2D8E  jsr       -$017A(A6)            ReplyMsg() to inform the waiting
FC2D92  bra.s     FC2D7C                task, then exit.


---------------------------------------------------------------------------
  InitSemaphore( signalSemaphore )
                 A0
---------------------------------------------------------------------------

FC2D94  lea       $10(A0),A1            Point to the waiting task list.
FC2D98  move.l    A1,(A1)               Initialize it to empty.
FC2D9A  addq.l    #4,(A1)
FC2D9C  clr.l     4(A1)
FC2DA0  move.l    A1,8(A1)
FC2DA4  clr.l     $28(A0)               Clear the ss_Owner field to null.
FC2DA8  clr.w     $0E(A0)               Clear the ss_NestCount to zero.
FC2DAC  move.w    #$FFFF,$2C(A0)        Set the ss_QueueCount to -1.
FC2DB2  rts       


---------------------------------------------------------------------------
  ObtainSemaphore( signalSemaphore )
                   A0
---------------------------------------------------------------------------

FC2DB4  addq.b    #1,$0127(A6)          Forbid()
FC2DB8  addq.w    #1,$2C(A0)            Increment the ss_QueueCount.
FC2DBC  bne.s     FC2DC6

        ; If the ss_Queuecount is now 0, then the semaphore was free and
        ; we got it.  Set the pointer to the owning task, set the nesting
        ; level to 1, and exit.

FC2DBE  move.l    $0114(A6),$28(A0)     Store pointer to owning task.
FC2DC4  bra.s     FC2DFA

        ; The ss_Queuecount was not -1, so the semaphore was already owned
        ; by someone.  Check if it is the calling task.

FC2DC6  movem.l   D0/D1/A0/A1,-(SP)
FC2DCA  move.l    $0114(A6),A1          Get current task pointer.
FC2DCE  cmp.l     $28(A0),A1            Do we own the semaphore already?
FC2DD2  beq.s     FC2DF6                If so, increment nest count and exit.

        ; Another task owns the semaphore at the moment, so we must block.
        ; Since all non-running tasks must be on the TaskWait queue, we
        ; can't just enqueue the task on the semaphore.  Instead, we build
        ; a temporary node on the stack, and enqueue that.  Then we clear
        ; signal #2, and wait for someone to set it, which will occur when
        ; the current owner of the semaphore releases it.  When we wake up,
        ; we deallocate the temporary node, and return to the user.

FC2DD4  lea       -$0C(SP),SP           Reserve 12 bytes of stack space.
FC2DD8  move.l    A1,8(SP)              Store pointer to this task.
FC2DDC  bclr      #4,$1D(A1)            Clear signal #2.
FC2DE2  lea       $10(A0),A0            Point to waiting task list.
FC2DE6  move.l    SP,A1
FC2DE8  bsr       FC15E8                Enqueue the temporary list node.
FC2DEC  moveq     #$10,D0
FC2DEE  jsr       -$013E(A6)            Wait for signal #2.
FC2DF2  lea       $0C(SP),SP            Release the reserved stack space.
FC2DF6  movem.l   (SP)+,D0/D1/A0/A1

FC2DFA  addq.w    #1,$0E(A0)            Increment the nesting count.
FC2DFE  jsr       -$8A(A6)              Permit()
FC2E02  rts       


---------------------------------------------------------------------------
  ReleaseSemaphore( signalSemaphore )
                    A0
---------------------------------------------------------------------------

FC2E04  subq.w    #1,$0E(A0)            Decrement the nesting count.
FC2E08  beq.s     FC2E12                If zero, release the semaphore.
FC2E0A  bmi.s     FC2E50                If it went negative, guru city!
FC2E0C  subq.w    #1,$2C(A0)            Otherwise, just decrement the
FC2E10  bra.s     FC2E4E                ss_QueueCount and exit.

        ; Continue here when the nesting count went to zero, and we
        ; therefore don't want the semaphore any more.

FC2E12  addq.b    #1,$0127(A6)          Forbid()
FC2E16  subq.w    #1,$2C(A0)            Decrement the ss_QueueCount.
FC2E1A  blt.s     FC2E46                If now -1, nobody was waiting.

        ; The ss_Queuecount is still positive, so someone is blocked on
        ; the semaphore and waiting to be awakened.  The first (oldest)
        ; entry on the semaphore's queue gets it.

FC2E1C  movem.l   D0/D1/A1,-(SP)
FC2E20  move.l    A0,D1                 Save semaphore pointer.
FC2E22  lea       $10(A0),A0            Point to semaphore's queue.
FC2E26  bsr       FC160E                RemHead()
FC2E2A  tst.l     D0                    If the queue was empty, guru city!
FC2E2C  beq.s     FC2E50

        ; We have a pointer (in D0) to a node which identifies the
        ; waiting process (the temporary one allocated on that process's
        ; stack).

FC2E2E  move.l    D1,A0
FC2E30  move.l    D0,A1
FC2E32  move.l    8(A1),A1              Get pointer to waiting task.
FC2E36  move.l    A1,$28(A0)            Make this task the ss_Owner.
FC2E3A  moveq     #$10,D0
FC2E3C  jsr       -$0144(A6)            Set waiting task's signal #2.
FC2E40  movem.l   (SP)+,D0/D1/A1
FC2E44  bra.s     FC2E4A                Exit.

        ; Continue here if nobody was waiting for the semaphore.  In this
        ; case just clear the semaphore's owner field.

FC2E46  clr.l     $28(A0)               Clear ss_Owner to null.
FC2E4A  jsr       -$8A(A6)              Permit()
FC2E4E  rts       

        ; Put up an alert if the semaphore's nest count went negative
        ; (should never happen, we give away the semaphore when it reaches
        ; zero), or if the semaphore's queue was empty even though the
        ; ss_QueueCount said it isn't.

FC2E50  movem.l   D7/A5/A6,-(SP)
FC2E54  move.l    #$81000008,D7         Alert number (fatal).
FC2E5A  move.l    4,A6                  Get ExecBase.
FC2E5E  jsr       -$6C(A6)              Put up the alert.
FC2E62  movem.l   (SP)+,D7/A5/A6        Never executed.
FC2E66  bra.s     FC2E4E


---------------------------------------------------------------------------
  success = AttemptSemaphore( signalSemaphore )
  D0                          A0
---------------------------------------------------------------------------

FC2E68  move.l    $0114(A6),A1          Get pointer to current task.
FC2E6C  addq.b    #1,$0127(A6)          Forbid()
FC2E70  addq.w    #1,$2C(A0)            Increment the ss_QueueCount.
FC2E74  beq.s     FC2E88                Branch if now zero.
FC2E76  cmp.l     $28(A0),A1            Do we own the semaphore already?
FC2E7A  beq.s     FC2E8C                Branch if true.
FC2E7C  subq.w    #1,$2C(A0)            Decrement the ss_QueueCount again.
FC2E80  jsr       -$8A(A6)              Permit()
FC2E84  moveq     #0,D0                 Return FALSE.
FC2E86  bra.s     FC2E96

        ; Continue here if we were able to get the semaphore.

FC2E88  move.l    A1,$28(A0)            Install pointer to owning task.
FC2E8C  addq.w    #1,$0E(A0)            Increment nest count.
FC2E90  jsr       -$8A(A6)              Permit()
FC2E94  moveq     #1,D0                 Return TRUE.
FC2E96  rts       


---------------------------------------------------------------------------
  ObtainSemaphoreList( list )
                       A0
---------------------------------------------------------------------------

        ; This function is given a linked list of semaphore structures, and
        ; obtains them all.  This is done in two passes.  On the first pass,
        ; a SemaphoreRequest is enqueued on all semaphores which aren't free,
        ; and all the free ones are grabbed.

        ; On the second pass, the list is traversed again.  This time, if
        ; we already have a semaphore, we just pass it, otherwise, we wait
        ; for it.

        ; Note:  Whereas ObtainSemaphore() builds its SemaphoreRequest node
        ; on the task's stack, this one uses the single copy inside the
        ; semaphore structure.  This means that a crash is sure to result
        ; if more than one task tries to ObtainSemaphoreList and several
        ; end up waiting for the same semaphore.  The documentation has
        ; a bit more to say about this.

FC2E98  movem.l   D2/A2/A3,-(SP)
FC2E9C  moveq     #0,D1                 Clear the "need to wait" flag.
FC2E9E  move.l    $0114(A6),A2          Get pointer to current task.
FC2EA2  addq.b    #1,$0127(A6)          Forbid()
FC2EA6  move.l    A0,A3
FC2EA8  move.l    0(A3),D2              Point to first semaphore in list.
FC2EAC  move.l    D2,A1
FC2EAE  move.l    (A1),D2               End of list reached?
FC2EB0  beq.s     FC2EDC                Exit loop if so.
FC2EB2  addq.w    #1,$2C(A1)            Increment current semaphore's count.
FC2EB6  beq.s     FC2ED2                Branch if now zero.
FC2EB8  cmp.l     $28(A1),A2            Check if the semaphore is ours.
FC2EBC  beq.s     FC2ED6                Branch if true.
FC2EBE  move.l    A2,$24(A1)            Use the ss_MultipleLink structure
FC2EC2  lea       $10(A1),A0            to enqueue our semaphore request on
FC2EC6  lea       $1C(A1),A1            the semaphore's wait queue.
FC2ECA  bsr       FC15E8
FC2ECE  moveq     #1,D1                 Indicate that we need to wait.
FC2ED0  bra.s     FC2EAC                Go to next semaphore in list.

        ; We got a semaphore.

FC2ED2  move.l    A2,$28(A1)            Make us the owner of this semaphore.
FC2ED6  addq.w    #1,$0E(A1)            Increment its nest count.
FC2EDA  bra.s     FC2EAC                Try next semaphore in the list.

        ; The end of the list was reached.

FC2EDC  tst.l     D1                    Did we get all the semaphores?
FC2EDE  beq.s     FC2F04                If so, exit.

        ; We have to wait for at least one semaphore in the list.

FC2EE0  move.l    0(A3),D2              Go to the start of the list.
FC2EE4  move.l    D2,A3
FC2EE6  move.l    (A3),D2               End of list reached?
FC2EE8  beq.s     FC2F04                If so, exit.
FC2EEA  cmp.l     $28(A3),A2            Do we own this semaphore?
FC2EEE  bne.s     FC2EFC
FC2EF0  tst.w     $0E(A3)               If we do, and its nest count is not
FC2EF4  bne.s     FC2EE4                zero, go on to the next one.
FC2EF6  addq.w    #1,$0E(A3)            Increment the nest count.
FC2EFA  bra.s     FC2EE4                Go on to the next one.

        ; Wait for a semaphore.

FC2EFC  moveq     #$10,D0
FC2EFE  jsr       -$013E(A6)            Wait for signal #2.
FC2F02  bra.s     FC2EEA                Go back and check if we have it now.
FC2F04  jsr       -$8A(A6)              Permit()
FC2F08  movem.l   (SP)+,D2/A2/A3
FC2F0C  rts       


---------------------------------------------------------------------------
  ReleaseSemaphoreList( list )
                        A0
---------------------------------------------------------------------------

FC2F0E  move.l    D2,-(SP)
FC2F10  move.l    0(A0),D2              Go to the start of the list.
FC2F14  move.l    D2,A0                 Go to first/next node.
FC2F16  move.l    (A0),D2               End of list reached?
FC2F18  beq.s     FC2F20                If so, exit.
FC2F1A  jsr       -$023A(A6)            ReleaseSemaphore()
FC2F1E  bra.s     FC2F14                Loop until all done.
FC2F20  move.l    (SP)+,D2
FC2F22  rts       


---------------------------------------------------------------------------
  AddSemaphore( signalSemaphore )
                A1
---------------------------------------------------------------------------

FC2F24  jsr       -$022E(A6)            InitSemaphore()
FC2F28  lea       $0214(A6),A0          Point to global semaphore list.
FC2F2C  bra       FC1682                Add the semaphore to the list.


---------------------------------------------------------------------------
  RemSemaphore( signalSemaphore )
                A1
---------------------------------------------------------------------------

FC2F30  bra       FC168E                Unlink semaphore from whatever
                                        list it's in.

---------------------------------------------------------------------------
  signalSemaphore = FindSemaphore( name )
  D0                               A1
---------------------------------------------------------------------------

FC2F34  lea       $0214(A6),A0          Point to global semaphore list.
FC2F38  jsr       -$0114(A6)            FindName()
FC2F3C  rts       


FC2F3E  0000                            Padding.


---------------------------------------------------------------------------
  CopyMemQuick( source, dest, size )
                A0      A1    D0
---------------------------------------------------------------------------

        ; The caller guarantees that the source and destination are even,
        ; and that the transfer count is a multiple of 4.  This allows us
        ; to skip some of the strategy below.

FC2F40  moveq     #0,D1                 0 bytes left over after longword copy.
FC2F42  bra.s     FC2F64                Go copy (at least) as longwords.


---------------------------------------------------------------------------
  CopyMem( source, dest, size )
           A0      A1    D0
---------------------------------------------------------------------------

        ; This is an interesting tutorial on efficient 68000 memory moving.

        ; Note that this is not necessarily the best way to move memory on
        ; a 68010 or 68020, since both of these processors have expanded
        ; features designed to make memory moving more efficient, and all
        ; the computational overhead of choosing the right copying method
        ; might not be worth it.

FC2F44  moveq     #$0C,D1               Less than 12 bytes to copy?
FC2F46  cmp.l     D1,D0
FC2F48  bcs.s     FC2FA2                If so, just copy byte by byte.

        ; The following bit of code handles odd/even source and destination
        ; addresses.  The following is done:

        ; Source and destination even:  Just continue.
        ; Source and destination odd:   Copy 1 byte.  Both addresses are now
        ;                               even, so we can continue.
        ; Source even, dest. odd:       Copy byte by byte.
        ; Source odd, destination even: Copy one byte, then copy the rest
        ;                               byte by byte.

        ; Note that there is nothing we can do if the source and destination
        ; differ by an odd number, i.e. are "out of phase".  In such a case,
        ; we must copy byte by byte.

FC2F4A  move.l    A0,D1
FC2F4C  btst      #0,D1                 Is the source address odd?
FC2F50  beq.s     FC2F56                Branch past the following if not.
FC2F52  move.b    (A0)+,(A1)+           Copy one byte.
FC2F54  subq.l    #1,D0                 Decrement transfer count.
FC2F56  move.l    A1,D1
FC2F58  btst      #0,D1                 Is the destination address odd?
FC2F5C  bne.s     FC2FA2                If so, transfer byte by byte.

        ; Both the source and destination addresses are (now) even.
        ; The worst that can happen now is that we have to move the data
        ; as individual longwords.  First, compute how many bytes will
        ; be left over after we move the data as longwords, and save this
        ; value.

FC2F5E  move.l    D0,D1                 Find how many bytes will be left
FC2F60  and.w     #3,D1                 if data is copied as longwords.
FC2F64  move.w    D1,-(SP)              Save this number.

        ; The "move multiple" approach below copies 48 bytes of data with
        ; only two instructions.  But to use it, 48 bytes of registers need
        ; to be saved and restored, and so it's not worth it unless we have
        ; at least two 48 byte "batches" to copy.

FC2F66  moveq     #$60,D1
FC2F68  cmp.l     D1,D0                 96 or more bytes to move?
FC2F6A  bcs.s     FC2F86                If not, copy as longwords.
FC2F6C  movem.l   D1-D7/A2-A6,-(SP)     Save 12 registers on the stack.
FC2F70  movem.l   (A0)+,D1-D7/A2-A6     Get 48 bytes with one instruction.
FC2F74  movem.l   D1-D7/A2-A6,(A1)      Move them to the destination.
FC2F78  moveq     #$30,D1
FC2F7A  add.l     D1,A1                 Add 48 to destination address.
FC2F7C  sub.l     D1,D0                 Subtract 48 from transfer count.
FC2F7E  cmp.l     D1,D0                 Copy another batch if 48 or more
FC2F80  bcc.s     FC2F70                bytes remain to be copied.
FC2F82  movem.l   (SP)+,D1-D7/A2-A6     Restore the 12 registers.

        ; Whatever the case, D0 now contains the number of bytes left over.
        ; Copy as many of these as possible as longwords.

FC2F86  lsr.l     #2,D0                 See how many longwords to copy.
FC2F88  beq.s     FC2F9A                Branch if none.
FC2F8A  subq.l    #1,D0                 Adjust for dbra.
FC2F8C  move.l    D0,D1                 Split up into two 16-bit values.
FC2F8E  swap      D0
FC2F90  move.l    (A0)+,(A1)+           Copy the longwords.
FC2F92  dbra      D1,FC2F90(PC)
FC2F96  dbra      D0,FC2F90(PC)

        ; Done copying longwords.  Get the number of bytes left over (0-3)
        ; from the stack and fall into the byte copy routine.

FC2F9A  move.w    (SP)+,D1              Restore number of bytes left over.
FC2F9C  beq.s     FC2FB2                Exit if none.
FC2F9E  moveq     #0,D0                 High 16 bits of byte count = 0.
FC2FA0  bra.s     FC2FAA                Enter the byte copy loop.

        ; Copy as individual bytes, either to clean up odds and ends after
        ; copying in larger chunks, or because copying in larger chunks
        ; wasn't worth it.

FC2FA2  move.w    D0,D1                 Split transfer count up into two
FC2FA4  swap      D0                    16-bit sections.
FC2FA6  bra.s     FC2FAA                Enter loop at bottom (for dbra).
FC2FA8  move.b    (A0)+,(A1)+           Copy the bytes.
FC2FAA  dbra      D1,FC2FA8(PC)
FC2FAE  dbra      D0,FC2FA8(PC)
FC2FB2  rts       


        ; System exception alert entry point
        ; ----------------------------------

        ; If an exception occurs or a TRAP instruction is executed while the
        ; CPU is in supervisor mode, we jump here, since we have no task to
        ; blame it on.  If a task was running, we use its tc_TrapCode vector
        ; instead, but at powerup, the exec default for this vector is also
        ; initialized to point here.  Later, it is stolen by some other
        ; part of the system so the "Software error - task held" window can
        ; be put up before the guru.


FC2FB4  movem.l   D0-D7/A0-A7,$0180     Dump the registers.
FC2FBA  lea       2(SP),A5              Point at exception data on the stack.
FC2FBE  move.l    4,D0                  Get ExecBase.
FC2FC2  btst      #0,D0                 Is it even?
FC2FC6  bne.s     FC2FCE
FC2FC8  move.l    D0,A0                 If so, point where the current task
FC2FCA  lea       $0114(A0),A5          pointer probably is.
FC2FCE  move.l    (SP),D7               Get the exception number.
FC2FD0  and.l     #$00FFFF,D7           Mask out any garbage.

        ; Fall into Alert().  alertNum is the exception number from the
        ; stack, and A5 points either to the current task pointer, or to
        ; the exception data on the stack.


---------------------------------------------------------------------------
  Alert( alertNum, parameters )
         D7        A5
---------------------------------------------------------------------------

        ; This routine has a relatively failsafe mechanism for getting an
        ; alert message up on the screen.  I call this the "deferred guru".

        ; Right away, a signature ("HELP") is installed at location 0, and
        ; the guru data is stored at location $000100.  If the system hangs
        ; now, the user will get the guru after he/she reboots manually
        ; via CTRL-Amiga-Amiga.  If for any reason it decides it's in
        ; serious trouble, it will reset itself, with the same effect.

FC2FD6  move.w    #$4000,DFF09A         Disable all interrupts.
FC2FDE  move.l    #$48454C50,D0

        ; If location 0 ALREADY contains "HELP", something is wrong, and
        ; no matter what the requested alert was, we reset the computer.

FC2FE4  cmp.l     0,D0                  See if "HELP" is at location zero.
FC2FE8  beq       FC305E                If so, unrecoverable crash.

        ; Store our own "deferred guru" data at 0 and $000100.  Then see
        ; if we should use it.  If ExecBase has been clobbered, or the
        ; stack is not working, or the unrecoverable alert bit is set,
        ; we blink the power light, and reset the computer.  The guru will
        ; come up during the reboot.

FC2FEC  move.l    D0,0                  Move "HELP" at location 0 now.
FC2FF0  lea       $0100,A0              Point at location $000100.
FC2FF4  move.l    D7,(A0)+              Store alert number there.
FC2FF6  move.l    (A5),(A0)+            Store the parameter.

FC2FF8  move.l    4,D0                  Get ExecBase.
FC2FFC  move.l    D0,D1

        ; Without checking, I would assume that this is where the famous
        ; "Recoverable alert doesn't work with expansion memory" bug is.

        ; Namely, if the ExecBase structure isn't in the first 64K of
        ; memory, we assume that it isn't OK.  With $C00000 memory, it
        ; will be at $C00276, and KABOOM, this fails, and the system
        ; resets, doing the unrecoverable alert thing via the "deferred
        ; alert" mechanism discussed earlier.

FC2FFE  and.l     #$FF0001,D1           Is ExecBase in the first 64K?
FC3004  bne.s     FC305E                If not, unrecoverable crash.
FC3006  move.l    D0,A6
FC3008  add.l     $26(A6),D0            Check ExecBase complement pointer.
FC300C  addq.l    #1,D0
FC300E  bne.s     FC305E                Unrecoverable crash if not valid.
FC3010  move.l    #$F1E2D3C4,D0         Check if the stack is working by
FC3016  move.l    D0,-(SP)              pushing a signature and trying to
FC3018  cmp.l     (SP)+,D0              pop it off again.
FC301A  bne.s     FC3054                Unrecoverable crash if not working.
FC301C  tst.l     D7                    Test high bit of alert number.
FC301E  bmi.s     FC305E                Branch if unrecoverable.

        ; Processing for recoverable alerts.  If we get this far, we have
        ; verified that the "dead end alert" flag was not set, that the
        ; ExecBase pointer and structure are probably OK, and that the
        ; stack is working (stack pointer pointing to RAM).

FC3020  lea       $0202(A6),A0          Point to ExecBase->LastAlert.
FC3024  move.l    D7,(A0)+              Store alert number.
FC3026  move.l    (A5),(A0)+            Store parameter.
FC3028  bsr       FC30EC                Call the guru alert routine.

FC302C  and.l     #$FFFF0000,D7         Was the subsystem ID field zero?
FC3032  bne.s     FC3044                If not, return to the caller.

        ; The alert number was of the form 0000xxxx.  This means that it
        ; must have been a system exception.  Presumably, the user has had
        ; the option of pressing the left or right mouse button, reflected
        ; in D0 as returned from the guru routine.  Accordingly, we
        ; reset or go to the debugger.

FC3034  tst.l     D0                    Test the guru routine's return code.
FC3036  movem.l   $0180,D0-D7/A0-A7     Restore the registers.
FC303C  bne       FC05F0                Reset if zero flag not set.
FC3040  bra       FC2342                Else go to ROM-Wack.

FC3044  tst.l     $0126(A6)             Enable interrupts if they are
FC3048  bge.s     FC3052                supposed to be enabled.
FC304A  move.w    #$C000,DFF09A
FC3052  rts       


        ; Unrecoverable system crash entry point
        ; --------------------------------------

        ; This routine blinks the power light slowly 6 times, and checks
        ; whether the user presses DEL on a terminal attached to the
        ; serial port.  If DEL is received, it jumps to ROM-Wack.  If
        ; DEL is not received, it resets the computer.  This may or may
        ; not lead to a guru, depending on how locations 0 and $000100 were
        ; set up before this was called.

        ; Entry point for when the stack is not working (stack pointer
        ; clobbered).  Set the stack pointer to 256K, and build a fake
        ; exception stack frame below it.

FC3054  move.l    #$040000,SP           Set stack pointer to 256K
FC305A  clr.l     -(SP)                 Build fake exception stack frame.
FC305C  clr.w     -(SP)

        ; Entry point for when the stack was working.

FC305E  or.b      #3,BFE201             Set CIA data direction register.
FC3066  and.b     #$FE,BFE001           Set power light to bright.

        ; Force the CPU into supervisor mode.  If the MOVE.W #$2700,SR
        ; instruction bombs the first time, it will work the second time.

FC306E  move.l    #$FC3076,$20          Set privilege violation vector.
FC3076  move.w    #$2700,SR             Mask all maskable interrupts.

        ; Blink the power light slowly 6 times and look for a DEL character
        ; coming in through the serial port at 9600 bps.  If such a character
        ; is received, go to the debugger.

FC307A  moveq     #5,D1                 Set loop counter to 5.
FC307C  move.w    #$0174,DFF032         Set serial port for 8 bits, 9600 bps.
FC3084  moveq     #-1,D0
FC3086  bset      #1,BFE001             Set power light to dim.
FC308E  dbra      D0,FC3086(PC)         Delay.
FC3092  bclr      #1,BFE001             Set power light to bright.
FC309A  dbra      D0,FC3092(PC)         Delay.
FC309E  move.w    DFF018,D0             Read the serial port.
FC30A4  move.w    #$0800,DFF09C         Clear serial port interrupt bit.
FC30AC  and.b     #$7F,D0
FC30B0  cmp.b     #$7F,D0               Did we receive a DEL character?
FC30B4  dbeq      D1,FC3084(PC)         If not, keep blinking the light.
FC30B8  bmi       FC05F0                If DEL not pressed, reset.

        ; The user pressed DEL.  Push the exception number on the stack
        ; and enter the debugger.

FC30BC  move.l    D7,-(SP)
FC30BE  jmp       FC2342                Go to ROM-Wack.


        ; "Deferred Guru" support routines
        ; --------------------------------

        ; The following routine is called early in the startup code.  Since
        ; there is no stack at that point, it returns via a jump, rather
        ; than an RTS.  It removes the "HELP" at zero, if present, and
        ; loads D6 and D7 with the data for ExecBase->LastAlert.

FC30C4  move.l    #$FFFFFFFF,D6         Load -1 into D6
FC30CA  cmp.l     #$48454C50,0          See if location 0 contains "HELP".
FC30D2  bne       FC014C                If not, go back to init. code.
FC30D6  clr.l     0                     Clear location 0.
FC30DA  movem.l   $0100,D6/D7           Load D6 and D7 from location $0100.
FC30E0  bra       FC014C                Go back to init. code.

        ; The following subroutine is called later, after the ExecBase
        ; structure has been built.  It writes the data determined above
        ; (still in D6 and D7) into ExecBase->LastAlert.

FC30E4  movem.l   D6/D7,$0202(A6)
FC30EA  rts       


        ; Guru Alert Routine
        ; ------------------

        ; This routine puts the big red "Guru" message up on the screen,
        ; waits for the user to click the mouse button, then returns.

        ; The routine is called with the alert number and parameters stored
        ; at LastAlert in the ExecBase structure.  This routine reads the
        ; alert number from there and decides what to do with it.

        ; An alert number of -1 means that no alert was outstanding, and
        ; therefore, the routine returns right away.  This means that if
        ; it is called via the "alert.hook" mechanism, and no alert was
        ; pending from before the reboot, nothing will happen.

        ; If the alert number is not -1, an alert will be generated.  The
        ; following algorithm is used to decide what the first string in
        ; the alert should say.

        ; IF the alert number is of the form xxxx01xxxxxxxx THEN
        ;   Make the alert message "Not enough memory".
        ; ELSEIF the high bit in the alert number is clear, and the
        ;        "general error" field is not zero THEN
        ;   Make the alert message "Recoverable Alert".
        ; ELSE
        ;   Make the alert message "Software Failure".
        ; ENDIF

        ; When the alert is finished (the user pressed the mouse button),
        ; the LastAlert field in ExecBase is cleared to -1, and the longword
        ; at location 0 is cleared to zero.


FC30EC  movem.l   D2/D7/A2/A3/A6,-(SP)

FC30F0  moveq     #$0A,D1               Delay for a while.
FC30F2  moveq     #-1,D0
FC30F4  dbra      D0,FC30F4(PC)
FC30F8  dbra      D1,FC30F4(PC)

FC30FC  move.l    $0202(A6),D2          Get the alert number.
FC3100  moveq     #-1,D0                Compare to -1 (indicates no alert).
FC3102  cmp.l     D0,D2
FC3104  beq.s     FC317C                Exit if equal.
FC3106  lea       -$C8(SP),SP           Reserve 200 bytes of stack space.
FC310A  lea       (SP),A3               Point to base of reserved area.

        ; Decide which alert message to use.

FC310C  lea       FC31AA(PC),A0         Point to "Software Failure" string.
FC3110  move.l    D2,D0                 Get the alert number.
FC3112  swap      D0                    Get the general error number.
FC3114  cmp.b     #1,D0                 Is it an AG_NoMemory type of alert?
FC3118  bne.s     FC3120                If so, point to "Not enough Memory"
FC311A  lea       FC3194(PC),A0         string.
FC311E  bra.s     FC312E
FC3120  btst      #$1F,D2               If otherwise, check the dead-end
FC3124  bne.s     FC312E                alert flag.  If it is clear, but
FC3126  tst.w     D0                    the Subsystem/General error fields
FC3128  beq.s     FC312E                are not zero, then point to the
FC312A  lea       FC31BF(PC),A0         "Recoverable Alert" string.

FC312E  bsr.s     FC318A                Copy the string into the buffer.
FC3130  lea       FC31D5(PC),A0         Point to "Press left mouse button..."
FC3134  bsr.s     FC318A                Copy the string into the buffer.
FC3136  clr.b     (A3)+                 Put a zero into the buffer.
FC3138  lea       FC31FC(PC),A0         Point to "Guru Meditation..." string.
FC313C  lea       $0202(A6),A1          Point to alert data.
FC3140  lea       FC3184(PC),A2         Point to character output routine.
FC3144  jsr       -$020A(A6)            RawDoFmt()

FC3148  lea       FC321B(PC),A1         Point to "intuition.library".
FC314C  moveq     #0,D0                 Minimum version is 0 (any).
FC314E  jsr       -$0228(A6)            OpenLibrary()
FC3152  tst.l     D0                    Did it open OK?
FC3154  beq.s     FC316E                If not, skip the following.
FC3156  move.l    A6,A3                 Save ExecBase.
FC3158  move.l    D0,A6                 Get IntuitionBase.
FC315A  clr.l     D0                    Tell intuition that the alert # is 0.
FC315C  lea       (SP),A0               Point to the alert string.
FC315E  moveq     #$28,D1               Alert should be 40 video lines high.
FC3160  jsr       -$5A(A6)              DisplayAlert()
FC3164  move.l    D0,A2
FC3166  move.l    A6,A1                 Get IntuitionBase.
FC3168  move.l    A3,A6                 Restore ExecBase.
FC316A  jsr       -$019E(A6)            CloseLibrary()

FC316E  lea       $C8(SP),SP            Deallocate string space on stack.
FC3172  clr.l     0                     Remove "HELP" at 0, if present.
FC3176  moveq     #-1,D0
FC3178  move.l    D0,$0202(A6)          Set LastAlert to -1.

        ; Set the return code.  If intuition.library didn't open, A2 contains
        ; a non-zero address, so a non-zero return value results.  If
        ; intuition could be called, this is the return code from the
        ; DisplayAlert() call.

FC317C  move.l    A2,D0                 Set return code.
FC317E  movem.l   (SP)+,D2/D7/A2/A3/A6
FC3182  rts       

        ; Character output routine for RawDoFmt() while putting together
        ; the "Guru Meditation #..." message.

FC3184  move.b    D0,(A3)+              Put character in buffer.
FC3186  clr.b     (A3)                  Zero-terminate the buffer.
FC3188  rts       

        ; Routine to copy a given string to the output buffer while
        ; building the guru message.

FC318A  clr.b     (A3)+                 Put a zero into the buffer.
FC318C  move.b    (A0)+,(A3)+           Copy the given string.
FC318E  bne.s     FC318C
FC3190  st        (A3)+                 Terminate buffer with $FF.
FC3192  rts       

        ; Strings used for the guru message.

FC3194  "&", 0F, "Not enough memory. ", 00
FC31AA  "&", 0F, "Software Failure. ", 00
FC31BF  "&", 0F, "Recoverable Alert. ", 00
FC31D5  EA, 0F, "Press left mouse button to continue.", 00
FC31FC  8E, 1E, "Guru Meditation #%08lx.%08lx", 00

        ; Name used to open intuition to put up the alert.

FC321B  "intuition.library", 00


        ; The "alert.hook" mechanism
        ; --------------------------

        ; This is a RomTag.  At system startup, this will be found and added
        ; to the resident module list.  Since it has the RTW_COLDSTART flag
        ; set, it will be initialized along with the other libraries,
        ; devices, etc.  The RTF_AUTOINIT flag is not set, therefore, the
        ; code at RT_INIT is called.

        ; The code at RT_INIT is the Guru routine.  This reads the LastAlert
        ; field in ExecBase.  If this is not -1, then an alert is still
        ; outstanding (from before the reboot), and this puts it up, lets
        ; the user click the mouse button, then returns.  The resident
        ; module initialization then continues, the DOS boots, and the
        ; system comes up.

        ; The purpose of all this is to allow the system to defer display
        ; of a guru message until after the system has been cold-started.


FC322D  "alert.hook", CR, LF, 00

FC323A  4AFC                    RTC_MATCHWORD   (start of ROMTAG marker)
FC323C  00FC323A                RT_MATCHTAG     (pointer RTC_MATCHWORD)
FC3240  00FC3254                RT_ENDSKIP      (pointer to end of code)
FC3244  01                      RT_FLAGS        (RTW_COLDSTART)
FC3245  21                      RT_VERSION      (33 decimal)
FC3246  00                      RT_TYPE         (NT_UNKNOWN)
FC3247  05                      RT_PRI          (priority = 5)
FC3248  00FC322D                RT_NAME         (pointer to name)
FC324C  00FC322D                RT_IDSTRING     (pointer to ID string)
FC3250  00FC30EC                RT_INIT         (execution address)


        ; ROM-Wack command dispatch tables ("Key bindings").
        ; --------------------------------------------------

        ; ROM-Wack can be in one of two modes when a key is pressed.  It can
        ; be waiting for a command, or it can be in the process of gathering
        ; a multi character command.  The two tables below decide what to do
        ; with the key in each case.

        ; Each table entry has 4 fields.  These are, address of next table
        ; entry to try if key doesn't match this one, lowest key value for
        ; this table entry, highest key value (if several) or zero, address
        ; to jump to.

        ; Primary command dispatch table.

FC3254  00FC325E 04 00 00FC2442         ^D
FC325E  00FC3268 0D 00 00FC2510         <Return>
FC3268  00FC3272 09 00 00FC2426         <Tab>
FC3272  00FC327C 3F 00 00FC2B06         ?
FC327C  00FC3286 2E 00 00FC2562         .
FC3286  00FC3290 2C 00 00FC2572         ,
FC3290  00FC329A 3E 00 00FC2522         >
FC329A  00FC32A4 3C 00 00FC2542         <
FC32A4  00FC32AE 08 00 00FC2542         <Backspace>
FC32AE  00FC32B8 20 00 00FC2522         <Space>
FC32B8  00FC32C2 5B 00 00FC2582         [
FC32C2  00FC32CC 5D 00 00FC25A0         ]
FC32CC  00FC32D6 3A 00 00FC2602         :
FC32D6  00FC32E0 2B 00 00FC25B4         +
FC32E0  00FC32EA 2D 00 00FC25D4         -
FC32EA  00FC32F4 3D 00 00FC2642         =
FC32F4  00FC32FE 21 00 00FC2938         !
FC32FE  00FC3308 5E 00 00FC29B2         ^
FC3308  00FC3312 5F 00 00FC2BA0         _
FC3312  00FC331C 30 39 00FC2BA0         0 - 9
FC331C  00FC3326 61 7A 00FC2BA0         a - z
FC3326  00FC3330 41 5A 00FC2BA0         A - Z

FC3330  00000000                        End of table marker.


        ; Secondary command dispatch table (used while a command
        ; and/or address is being typed).

FC3334  00FC333E 08 00 00FC2C44         <Backspace>
FC333E  00FC3348 0D 00 00FC2C6E         <Return>
FC3348  00FC3352 18 00 00FC2C2C         <CTRL-X>
FC3352  00FC335C 15 00 00FC2C2C         <CTRL-U>
FC335C  00FC3366 3E 00 00FC2522         >
FC3366  00FC3370 3C 00 00FC2542         <
FC3370  00FC337A 20 00 00FC2C2A         <Space>
FC337A  00FC3384 5F 00 00FC2BA0         _
FC3384  00FC338E 30 39 00FC2BA0         0 - 9
FC338E  00FC3398 61 7A 00FC2BA0         a - z
FC3398  00FC33A2 41 5A 00FC2BA0         A - Z

FC33A2  00000000                        End of table marker.


        ; Table of multi-character ROM-Wack commands.

FC33A6  "alter", 00, "boot", 00, "clear", 00, "fill", 00
FC33BC  "find", 00, "go", 00, "ig", 00, "limit", 00, "list", 00
FC33D2  "regs", 00, "reset", 00, "resume", 00, "set", 00
FC33E8  "show", 00, "user", 00, 00, 00


        ; Dispatch table for multicharacter commands.

        ; The fields are link to next table entry, address of command string,
        ; an unused value (presumably from a larger version of Wack), and
        ; the address to jump to for that command.

FC33F4  00FC3402 00FC33A6 0001 00FC2670     "alter"
FC3402  00FC3410 00FC33AC 0001 00FC05F0     "boot"
FC3410  00FC341E 00FC33B1 0001 00FC28A2     "clear"
FC341E  00FC342C 00FC33B7 0001 00FC2A38     "fill"
FC342C  00FC343A 00FC33BC 0001 00FC29C0     "find"
FC343A  00FC3448 00FC33C1 0001 00FC2438     "go"
FC3448  00FC3456 00FC33C4 0001 00FC05F0     "ig"
FC3456  00FC3464 00FC33C7 0001 00FC29B2     "limit"
FC3464  00FC3472 00FC33CD 0001 00FC26B2     "list"
FC3472  00FC3480 00FC33D2 0001 00FC27E6     "regs"
FC3480  00FC348E 00FC33D7 0001 00FC28B2     "reset"
FC348E  00FC349C 00FC33DD 0001 00FC2442     "resume"
FC349C  00FC34AA 00FC33E4 0001 00FC28D0     "set"
FC34AA  00FC34B8 00FC33E8 0001 00FC290A     "show"
FC34B8  00FC34C6 00FC33ED 0001 00FC24B2     "user"
FC34C6  00000000

FC34CA  0000                            Padding.

        ; That's it.  The next RomTag (for the audio.device) comes right
        ; after the two bytes of padding shown above.

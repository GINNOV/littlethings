                opt     l+,o+,ow-,inconce

*-- AutoRev header do NOT edit!
*
*   Program         :   memfunc.s
*   Copyright       :   © Copyright 1991-92 Jaba Development
*   Author          :   Jan van den Baard
*   Creation Date   :   06-Apr-91
*   Current version :   2.2
*   Translator      :   Devpac version 2.14
*
*   REVISION HISTORY
*
*   Date          Version         Comment
*   ---------     -------         ------------------------------------------
*   12-Apr-92     2.2             Should be enforcer and mungwall free now.
*   19-May-91     2.1             Added 'Vec' routines.
*   06-Apr-91     1.1             Initial version!
*
*-- REV_END --*

            incdir      'sys:asm20/'
            include     'mymacros.i'
            include     'libraries/nofrag.i'
            include     'exec/exec_lib.i'

            xdef        GetMemoryChain
            xdef        AllocItem
            xdef        FreeItem
            xdef        FreeMemoryChain
            xdef        AllocVecItem
            xdef        FreeVecItem

ROUND       MACRO
            addq.l      #7,\1
            and.l       #-8,\1
            ENDM

_SysBase    EQU         $0004

;
; Allocate and initialize a MemoryChain for use. It allocates the structure
; from the system free memory pool and then initializes it.
;
GetMemoryChain:
            pushem.l    d2/a2/a6
            move.l      d0,d2               ; block size to d2
            move.l      (_SysBase).w,a6
            moveq       #mc_SIZEOF,d0
            move.l      #MEMF_PUBLIC!MEMF_CLEAR,d1
            libcall     AllocMem            ; allocate chain structure
            move.l      d0,a2               ; put it in a2
            tst.l       d0
            beq.s       NoChain             ; FAILED !?!?!
            lea.l       mc_Blocks(a2),a0
            NEWLIST     a0                  ; initialize block list
            lea.l       mc_Items(a2),a0
            NEWLIST     a0                  ; initialize item list
            ROUND       d2                  ; allign the block size
            move.l      d2,mc_BlockSize(a2) ; put it in the structure
            move.l      a2,d0
NoChain:    popem.l     d2/a2/a6
            rts

;
; Deallocate a block of memory. It removes all "Free Items" from the
; chain it's "Free Item List" and then deallocates the memory the
; block used.
;
FreeBlock:  pushem.l    a2-a3/a5-a6
            move.l      a0,a2               ; chain to a2
            move.l      a1,a3               ; block to a3
            lea.l       mc_Items(a2),a5
            move.l      il_First(a5),a5     ; first item in a5
FBLoop:     tst.l       mit_Next(a5)        ; is there a next item ?
            beq.s       FBDone              ; no.. done
            cmp.l       mit_Block(a5),a3    ; item in the block ?
            bne.s       FBNotSame           ; no.. get next item
            move.l      a5,a1
            REMOVE                          ; remove item from the list
            lea.l       mc_Items(a2),a5
            move.l      il_First(a5),a5
            bra.s       FBLoop              ; start from the begin
FBNotSame:  move.l      mit_Next(a5),a5
            bra.s       FBLoop              ; try the next item
FBDone:     move.l      a3,a1
            REMOVE                          ; remove block from the list
            move.l      (_SysBase).w,a6
            move.l      a3,a1
            move.l      mc_BlockSize(a2),d0
            add.l       #mb_SIZEOF,d0
            libcall     FreeMem             ; free the block's memory
            popem.l     a2-a3/a5-a6
            rts

;
; Allocate a block of memory for a chain. This routine allocates enough
; memory from the system free memory pool to hold the MemoryBlock
; structure and the number of bytes specified with GetMemoryChain().
; Then it initializes the MemoryBlock structure and creates one "Free Item"
; the size of the whole block. Then it hangs this item in the chain it's
; "Free Item List"
;
AllocBlock: pushem.l    d2/a2-a3/a5-a6
            move.l      a0,a2               ; chain to a2
            move.l      d0,d2               ; reqs to d2
            move.l      d2,d1
            move.l      mc_BlockSize(a2),d0
            add.l       #mb_SIZEOF,d0       ; add room for Block structure
            move.l      (_SysBase).w,a6
            libcall     AllocMem            ; allocate the memory
            move.l      d0,a3               ; put it in a3
            tst.l       d0
            beq.s       ABNoMem             ; FAILED !?!?!
            move.l      d2,mb_Requirements(a3) ; set block reqs
            clr.l       mb_BytesUsed(a3)    ; clear bytes used counter
            lea.l       mc_Blocks(a2),a0
            move.l      a3,a1
            ADDHEAD                         ; add block in the list
            move.l      a3,a5
            add.l       #mb_SIZEOF,a5       ; get first item in a5
            move.l      a3,mit_Block(a5)    ; set it's block
            move.l      mc_BlockSize(a2),mit_Size(a5) ; set it's size
            lea.l       mc_Items(a2),a0
            move.l      a5,a1
            ADDHEAD                         ; add item in the list
            move.l      a3,d0               ; return the block
ABEnd:      popem.l     d2/a2-a3/a5-a6
            rts
ABNoMem:    cldat       d0                  ; alloc failed.. return 0
            bra.s       ABEnd

;
; This routine optimizes a MemoryBlock. It looks up all "Free Items"
; located in the block and hangs them in a seperate list. Then it starts
; to look for items that are located directly after eachother in memory.
; If it find such items it will merge them together into on bigger item.
; It continues to do this until it doesn't find items located after each-
; other anymore. This will prevent the fragmentizing in the memory chain
; itself.
;
OptimizeBlock:
            link        a6,#-il_SIZEOF      ; create stack space
            pushem.l    d2/a2-a6
            move.l      a0,a2               ; chain to a2
            move.l      a1,a3               ; block to a3
            lea.l       -il_SIZEOF(a6),a0
            NEWLIST     a0                  ; init buffer list
            lea.l       mc_Items(a2),a4
            move.l      il_First(a4),a4     ; first item to a4
OBLoop1:    tst.l       mit_Next(a4)        ; is there a next item ?
            beq.s       OBDone1             ; no.. done
            cmp.l       mit_Block(a4),a3    ; item in the block ?
            bne.s       OBNotSame1          ; no.. skip it
            move.l      a4,a1
            REMOVE                          ; remove item
            lea.l       -il_SIZEOF(a6),a0
            move.l      a4,a1
            ADDTAIL                         ; put item in buffer list
            lea.l       mc_Items(a2),a4
            move.l      il_First(a4),a4
            bra.s       OBLoop1             ; start from the begin
OBNotSame1: move.l      mit_Next(a4),a4
            bra.s       OBLoop1             ; try the next item
OBDone1:    lea.l       -il_SIZEOF(a6),a0
            move.l      il_First(a0),a4     ; first buffer item in a4
OBLoop2:    tst.l       mit_Next(a4)        ; is there a next item ?
            beq.s       OBDone2             ; no.. done
            move.l      a4,d2
            add.l       mit_Size(a4),d2     ; addres behind item to d2
            move.l      a4,a5
OBLoop3:    tst.l       mit_Next(a5)        ; is there a next item ?
            beq.s       OBDone3             ; no.. done
            cmp.l       d2,a5               ; d2 is a5 ?
            bne.s       OBNotSame2          ; no.. skip it
            move.l      mit_Size(a5),d0
            add.l       d0,mit_Size(a4)     ; join a4 with a5
            add.l       d0,d2
            move.l      a5,a1
            REMOVE                          ; remove a5 from the list
            lea.l       -il_SIZEOF(a6),a0
            move.l      il_First(a0),a5
            bra.s       OBLoop3             ; start from the begin
OBNotSame2: move.l      mit_Next(a5),a5
            bra.s       OBLoop3             ; try the next item
OBDone3:    move.l      mit_Next(a4),a4
            bra.s       OBLoop2             ; try the next item
OBDone2:    lea.l       -il_SIZEOF(a6),a0
            REMHEAD                         ; remove item from the buffer
            tst.l       d0                  ; is it 0 ?
            beq.s       NoMore              ; yes.. all done
            move.l      d0,a1
            lea.l       mc_Items(a2),a0
            ADDHEAD                         ; add it to the list
            bra.s       OBDone2
NoMore:     popem.l     d2/a2-a6
            unlk        a6
            rts

;
; This routines looks through the "Free Item List" of the chain to find
; a "Free Item" that meets the requested size and requirements.
;
FindSpace:  pushem.l    d2-d3/a2-a3
            move.l      a0,a2               ; chain to a2
            move.l      d0,d2               ; size to d2
            move.l      d1,d3               ; reqs to d3
            lea.l       mc_Items(a2),a3
            move.l      il_First(a3),a3     ; first item to a3
FSLoop:     tst.l       mit_Next(a3)        ; is there a next item ?
            beq.s       FSDone              ; no.. done
            move.l      mit_Block(a3),a0
            cmp.l       mb_Requirements(a0),d3 ; requirements OK ?
            bne.s       FSNotSame           ; no.. skip it
            cmp.l       mit_Size(a3),d2     ; size OK ?
            bhi.s       FSNotSame           ; no.. skip it
            move.l      a3,d0               ; return the item
            bra.s       FSEnd
FSNotSame:  move.l      mit_Next(a3),a3
            bra.s       FSLoop              ; try the next item
FSDone:     cldat       d0                  ; no item found
FSEnd:      popem.l     d2-d3/a2-a3
            rts

;
; Allocate memory from a chain. This routine uses FindSpace() to find a
; suitable "Free Item" in the chain. If it does not find such an item it
; will allocate a new MemoryBlock.
;
AllocItem:  pushem.l    d2-d4/a2-a5
            move.l      a0,a2               ; chain to a2
            move.l      d0,d2               ; size to d2
            move.l      d1,d3               ; reqs to d3
            bclr.l      #16,d3              ; clear MEMF_CLEAR   bit
            bclr.l      #17,d3              ; clear MEMF_LARGEST bit
            cmp.l       #mit_SIZEOF,D2      ; size > mit_SIZEOF ?
            bhi.s       ASOK                ; yes.. ok
            move.l      #mit_SIZEOF,d2      ; else make it that big
ASOK:       ROUND       d2                  ; allign the size
            cmp.l       mc_BlockSize(a2),d2
            bhi.s       NoMem
            move.l      d3,d1
            move.l      d2,d0
            move.l      a2,a0
            bsr         FindSpace           ; find a suitable item
            move.l      d0,a4               ; put it in a4
            tst.l       d0
            bne.s       HaveSpace           ; found one..
            move.l      d3,d0
            move.l      a2,a0
            bsr         AllocBlock          ; allocate a block
            move.l      d0,a4               ; put it in a4
            tst.l       d0
            beq         NoMem               ; no more memory (wheeee)
            add.l       #mb_SIZEOF,a4       ; get first item
;
; NOTE: This routine will split up the item if the size left
; is big enough to hold a "MemoryItem" structure. If not it won't
; split the item up the size left will not be used again. This means
; that after a chain has been used for some time to (de)allocate items
; in it is possible that not all bytes of a block can be used.
;
HaveSpace:  move.l      mit_Block(a4),a3    ; get block in a3
            cmp.l       mit_Size(a4),d2     ; size equals item size ?
            beq.s       NoSplit             ; yes.. don't split it
            move.l      mit_Size(a4),d4
            sub.l       d2,d4
            cmp.l       #mit_SIZEOF,d4      ; size left < mit_SIZEOF ?
            bcs.s       NoSplit             ; yes.. don't split it
            move.l      a4,a5
            add.l       d2,a5               ; new item in a5
            move.l      d4,mit_Size(a5)     ; set new item size
            move.l      a3,mit_Block(a5)    ; set new item block
            lea.l       mc_Items(a2),a0
            move.l      a5,a1
            ADDHEAD                         ; add it in the list
NoSplit:    move.l      a4,a1
            REMOVE                          ; remove it from the list
            move.l      a4,a0
            move.l      d2,d0
            bsr         ClearAlloc          ; clear memory
            add.l       d2,mb_BytesUsed(a3) ; increase bytes used counter
            move.l      a4,d0               ; return the pointer
AIEnd:      popem.l     d2-d4/a2-a5
            rts
NoMem:      cldat   d0                      ; no memory.. return 0
            bra.s   AIEnd

;
; Free memory in a MemoryChain. This routine takes the pointer it has
; been passed and check to see what block it was allocated in. Then it
; will convert the memory pointed to in a "Free Item" and hang it in the
; "Free Item List" of the chain. If the MemoryBlock is empty after this
; the routine will deallocate the block.
;
FreeItem:   pushem.l    d2/a2-a4
            move.l      a0,a2               ; chain to a2
            move.l      a1,a3               ; memptr to a3
            move.l      d0,d2               ; size to d2
            cmp.l       #mit_SIZEOF,d2      ; size > mit_SIZEOF ?
            bhi.s       FSOK                ; yes.. ok
            move.l      #mit_SIZEOF,d2      ; else make it that big
FSOK:       ROUND       d2                  ; allign the size
            bsr         FindBlock           ; find it's block
            move.l      d0,a4               ; and put it in a4
            tst.l       d0
            beq         FRDone              ; block 0.. don't free
            move.l      a4,mit_Block(a3)    ; set item block
            move.l      d2,mit_Size(a3)     ; set item size
            sub.l       d2,mb_BytesUsed(a4) ; decrease bytes used count
            move.l      a3,a1
            lea.l       mc_Items(a2),a0
            ADDHEAD                         ; add item in the list
            tst.l       mb_BytesUsed(a4)
            bne.s       FROpt               ; block not free
            move.l      mit_Block(a3),a1
            move.l      a2,a0
            bsr         FreeBlock           ; free the block
            bra.s       FRDone
FROpt:      move.l      a2,a0
            move.l      a4,a1
            bsr         OptimizeBlock       ; optimize the block
FRDone:     popem.l     d2/a2-a4
            rts

;
; This routine looks for the block in which memory was allocated.
;
FindBlock:  push.l      a2
            lea.l       mc_Blocks(a0),a2
            move.l      bl_First(a2),a2     ; first block to a2
FBBLoop:    tst.l       mb_Next(a2)         ; is there a next block ?
            beq.s       FBBDone             ; no.. done
            move.l      a2,d0
            cmp.l       d0,a1               ; memptr < block start ?
            bmi.s       FBBNotSame          ; yes.. skip it
            add.l       #mb_SIZEOF,d0
            add.l       mc_BlockSize(a0),d0
            cmp.l       d0,a1               ; memptr > block end ?
            bhi.s       FBBNotSame          ; yes.. skip it
            move.l      a2,d0               ; return block
            bra.s       EndFBB
FBBNotSame: move.l      mb_Next(a2),a2
            bra.s       FBBLoop             ; try the next block
FBBDone:    cldat       d0                  ; block not found.. return 0
EndFBB:     pop.l       a2
            rts

;
; Deallocate all MemoryBlocks from the chain and, if requested,
; deallocate the chain to.
;
FreeMemoryChain:
            pushem.l    d2/a2-a3/a6
            move.l      a0,a2               ; chain to a2
            move.l      d0,d2               ; struct free flag
            move.l      (_SysBase).w,a6
FMCLoop:    lea.l       mc_Blocks(a2),a0
            REMHEAD                         ; remove a block
            move.l      d0,a1               ; put it in a1
            tst.l       d0
            beq.s       ChkDone             ; block 0 then done
            move.l      mc_BlockSize(a2),d0
            add.l       #mb_SIZEOF,d0
            libcall     FreeMem             ; free it's memory
            bra.s       FMCLoop
ChkDone:    tst.l       d2
            bne.s       AllDone             ; free structure!
            lea.l       mc_Items(a2),a0
            NEWLIST     a0
            lea.l       mc_Blocks(a2),a0
            NEWLIST     a0
            bra.s       FMCEnd
AllDone:    move.l      a2,a1
            moveq       #mc_SIZEOF,d0
            libcall     FreeMem             ; free the chain structure
FMCEnd:     popem.l     d2/a2-a3/a6
            rts

;
; Fill the allocated item with zero's.
;
ClearAlloc: lsr.l       #2,d0               ; size / 4
            dec.l       d0
Loop:       clr.l       (a0)+               ; clear a long word
            dbra        d0,Loop
            rts

;
; The same as AllocItem() exept that it remebers the size
; allocated.
;
AllocVecItem:
            push.l      d2
            addq.l      #4,d0               ; make room to store size
            move.l      d0,d2               ; save to size
            bsr         AllocItem           ; allocate the item
            move.l      d0,a0               ; result to a0
            tst.l       d0
            beq.s       NoVecMem            ; failed !?!?!
            move.l      d2,(a0)+            ; store size
            move.l      a0,d0               ; return memory pointer
NoVecMem:   pop.l       d2
            rts

;
; Free the memory allocated with AllocVecItem()
;
FreeVecItem:
            subq.l      #4,a1               ; get orig alloc address
            move.l      (a1),d0             ; get the size
            bsr         FreeItem            ; free the memory
            rts

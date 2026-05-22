**
**      Fire and Scale
**      for Feedback effect
**      PowerPC/WarpOS
**
**      Auteur:
**      BOULAIS Sebastien
**      5.jan.00
**      Révision: 11.4.00
**

.Include        'includes:powerpc/pasm/ppcmacros.i'
.Include        'includes:lvo/pasm/powerpc_lib.i'

.Section        FeedBackPPC_Code,"c4F"

.Global         FireAndScale
.Global         Fire
.Global         Scale

# r4    ->      ChunkyBuffer 1
# r5    ->      ChunkyBuffer 2
# r6    ->      WindowHeight
# r22   ->      XArray
# r23   ->      YArray

FireAndScale:
        Mflr    r31
        Bl      Fire
        Bl      Scale
        Mtlr    r31
        Blr

# PTR ChunkyBuffer      ->      r4
# Hauteur - 1           ->      r6

Fire:   Subi    r6,r6,1
        Mulli   r30,r6,320
        Mtctr   r30

        Mr      r7,r4

.MACRO  Blur
        Lbz     r8,0(r7)
        Lbz     r9,1(r7)
        Lbz     r10,2(r7)
        Lbz     r11,320(r7)
        Add     \1,r8,r9
        Add     \1,\1,r10
        Add     \1,\1,r11
        Srwi.   \1,\1,2
        Beq+    Ok\@
        Subi    \1,\1,1
Ok\@:
.ENDM

FireLoop:
        Blur    r8
        Stbu    r8,1(r7)
        Bdnz+   FireLoop
        Blr

*-----------------------------------------
*-----------------------------------------
**
**      Scale
**      PowerPC/WarpOS
**
**      Auteur:
**      BOULAIS Sebastien
**      30.jan.00
**      Heavy optimization 24.02.00 (1 STWU rather 4 STBU !)
**

# PTR Source            ->      r4
# PTR Destination       ->      r5
# PTR Window Height     ->      r6
# PTR XArray            ->      r22
# PTR YArray            ->      r23

Scale:  La      r5,-4(r5)
        La      r11,-2(r23)
        Li      r30,1

LoopA:  Li      r7,320/8
        Mtctr   r7

        La      r10,-2(r22)
        Lhzu    r20,2(r11)      # y_offset -> r20

        Add     r26,r20,r4      # buffer + y_offset -> r26

.MACRO  Copy8
        Lhzu    r20,2(r10)
        Lbzx    r15,r26,r20
        Lhzu    r20,2(r10)
        Lbzx    r16,r26,r20
        Lhzu    r20,2(r10)
        Lbzx    r17,r26,r20
        Lhzu    r20,2(r10)
        Lbzx    r18,r26,r20
        Rlwimi  r18,r17,8,16,23
        Rlwimi  r18,r16,16,8,15
        Rlwimi  r18,r15,24,0,7
        Stwu    r18,4(r5)
.ENDM

LoopB:  Copy8
        Copy8
        Bdnz+   LoopB

        Sub.    r6,r6,r30
        Bge+    LoopA
        Blr

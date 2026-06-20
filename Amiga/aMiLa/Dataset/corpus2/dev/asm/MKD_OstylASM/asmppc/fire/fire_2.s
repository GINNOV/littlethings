**
**      Fire
**      PowerPC/WarpOS
**
**      Auteur:
**      BOULAIS Sebastien
**      30.jan.00
**

.Include        'includes:powerpc/pasm/ppcmacros.i'
.Include        'includes:lvo/pasm/powerpc_lib.i'

.Section        FireCode,"c4F"

.Global         Fire

# PTR ChunkyBuffer      ->      r4
# Size - 1              ->      r5

Fire:           Mtctr   r5

FireLoop:       Lbz     r8,0(r4)
                Lbz     r9,1(r4)
                Lbz     r10,2(r4)
                Lbz     r11,320(r4)

                Add     r8,r8,r9
                Add     r8,r8,r10
                Add     r8,r8,r11
                Srwi.   r8,r8,2
                Beq+    Ok
                Subi    r8,r8,1

Ok:             Stbu    r8,1(r4)
                Bdnz    FireLoop
                Blr






     

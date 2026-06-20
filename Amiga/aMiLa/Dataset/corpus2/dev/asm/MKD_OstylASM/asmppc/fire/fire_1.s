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

Fire:           La      r7,1(r4)
                Mtctr   r5

FireLoop:       Lbz     r8,(r7)
                Lbz     r9,-1(r7)
                Lbz     r10,1(r7)
                Lbz     r11,320(r7)

                Add     r8,r8,r9
                Add     r8,r8,r10
                Add     r8,r8,r11
                Srwi.   r8,r8,2
                Beq+    Ok
                Subi    r8,r8,1

Ok:             Stb     r8,(r7)

                La      r7,1(r7)
                Bdnz    FireLoop
                Blr






     

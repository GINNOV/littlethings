##      Rendu de gouraud triangle
##      PowerPC - PAsm Wos
##
##      Auteur:
##      -------
##      BOULAIS Sébastien
##      4.nov.1999
##
##      Révision 22.12.99
##

.Include        'includes:powerpc/pasm/ppcmacros.i'

.Section        GouraudPowerPC,"c4F"

.Global GouraudPPC

.Baserel        datas,r2

.Set    clipdroit,320-1
.Set    clipbas,200-1
.Set    dymax,300

# -> r3         _PowerPCBase
# -> r4         PTR chunky buffer
# -> r5         PTR liste des polygone (lightwave)
# -> r6         PTR sommets en 2d
# -> r23        PTR liste polygones visibles
# -> r24        PTR couleurs des sommets
# -> r25        Shade offset

# r13 réservé à la macros Exg

GouraudPPC:
        Lhz     r14,(r23)
        Tsth    r14
        Beq-    PasDePolygone
        Mtctr   r14

LoopPolygone:
        Lhzu    r14,2(r23)
        Mulli   r14,r14,10
        Add     r14,r14,r5
        La      r14,2(r14)

# r14 = PTR sur le polygone

        Lhz     r15,0(r14)              # p1 -> r15
        Lhz     r16,2(r14)              # p2 -> r16
        Lhz     r17,4(r14)              # p3 -> r17
        Lhz     r26,6(r14)              # index -> r26
        Subi    r26,r26,1
        Mullw   r26,r26,r25             # offset -> r26

# intensitées au sommets du triangle

        Add     r15,r15,r15
        Add     r16,r16,r16
        Add     r17,r17,r17
        Lhzx    r27,r15,r24             # i1 -> r27
        Lhzx    r28,r16,r24             # i2 -> r28
        Lhzx    r29,r17,r24             # i3 -> r29
        Add     r27,r27,r26             # i1+offset
        Add     r28,r28,r26             # i2+offset
        Add     r29,r29,r26             # i3+offset

# coords du triangle

        Slwi    r15,r15,2
        Slwi    r16,r16,2
        Slwi    r17,r17,2
        Lwzx    r18,r15,r6              # x1 -> r18
        La      r15,4(r15)
        Lwzx    r15,r15,r6              # y1 -> r15
        Lwzx    r19,r16,r6              # x2 -> r19
        La      r16,4(r16)
        Lwzx    r16,r16,r6              # y2 -> r16
        Lwzx    r20,r17,r6              # x3 -> r20
        La      r17,4(r17)
        Lwzx    r17,r17,r6              # y3 -> r17

#--------------------
#---- Trie les Y ----

.Macro  Exg
        Mr      r13,\1
        Mr      \1,\2
        Mr      \2,r13
.Endm

TrieY:  Cmpw    r17,r15
        Bge+    TrieY_ok1
        Exg     r20,r18
        Exg     r17,r15
        Exg     r29,r27

TrieY_ok1:
        Cmpw    r16,r15
        Bge+    TrieY_ok2
        Exg     r18,r19
        Exg     r16,r15
        Exg     r28,r27

TrieY_ok2:
        Cmpw    r17,r16
        Bge+    TrieY_fin
        Exg     r19,r20
        Exg     r17,r16
        Exg     r28,r29

TrieY_fin:

.Set    xcntr,320/2
.Set    ycntr,200/2

        Li      r14,xcntr
        Add     r18,r18,r14
        Add     r19,r19,r14
        Add     r20,r20,r14
        Li      r14,ycntr
        Add     r15,r15,r14
        Add     r16,r16,r14
        Add     r17,r17,r14

        La      r14,points(r2)

        Stw     r18,(r14)
        Stwu    r15,4(r14)
        Stwu    r27,4(r14)

        Stwu    r19,4(r14)
        Stwu    r16,4(r14)
        Stwu    r28,4(r14)

        Stwu    r20,4(r14)
        Stwu    r17,4(r14)
        Stwu    r29,4(r14)

        Stwu    r18,4(r14)
        Stwu    r15,4(r14)
        Stwu    r27,4(r14)

        Mfctr   r12

#--------------------------------
#---- Pré-clipping verticale ----
        Tstw    r17
        Ble     NxtTriangle

        Cmpwi   r15,clipbas
        Bge     NxtTriangle

#-------------------------
#---- calcul triangle ----
# -> r4         buffer chunky

        La      r27,points(r2)
        La      r28,p1p2(r2)

        Li      r14,3
        Mtctr   r14

TriangleLoop:
        Mr      r15,r28

        Lwz     r16,0(r27)
        Lwzu    r17,4(r27)
        Lwzu    r18,4(r27)
        Lwzu    r19,4(r27)
        Lwz     r20,4(r27)
        Lwz     r21,8(r27)

#-----------------------------
#---- calcul coeff droite ----
# -> r16/r19    x1 & x2
# -> r17/r20    y1 & y2
# -> r18/r21    i1 & i2

        Cmpw    r20,r17                 # compare y2 à y1
        Bge+    Y_ok

        Exg     r16,r19
        Exg     r17,r20
        Exg     r18,r21

Y_ok:   Sub     r19,r19,r16             # dx -> r19
        Sub     r20,r20,r17             # dy -> r20

        Sth     r20,0(r15)              # dy -> tableau
        Subi    r15,r15,1

        Tsth    r20
        Beq-    Dy0

        Swap    r19
        Divw    r19,r19,r20             # coeff pente -> r19

#------------------------------
#---- calcul coeff dégradé ----

        Sub     r21,r21,r18             # di -> r21
        Swap    r21
        Divw    r21,r21,r20             # coeff dégradé -> r21

#------------------------
#---- interpolations ----
# -> r16        x1
# -> r18        c1
# -> r19        coeff de la pente
# -> r21        coeff du dégradé

# r19   (p.w ; P.w)
# r21   (c.w ; C.w)

        Swap    r19
        Swap    r21

# r19   (P.w ; p.w)
# r21   (C.w ; c.w)

        Mr      r14,r19
        Mh      r19,r21
        Mh      r21,r14

# r19   (P.w ; c.w)
# r21   (C.w ; p.w)

        Mfctr   r14
        Mtctr   r20

        Li      r20,0                   # Clear carry
        Adde    r20,r20,r20             #

EdgeLoop:
        Sthu    r16,3(r15)
        Stb     r18,2(r15)
        Adde    r16,r21,r16
        Adde    r18,r19,r18
        Bdnz    EdgeLoop

        Mtctr   r14
Dy0:    La      r28,8+(3*dymax)(r28)
        Bdnz    TriangleLoop

        La      r22,points(r2)
        Lwz     r27,4(r22)

#----------------------------
#---- Routine de traçage ----
# -> r4         buffer chunky
# -> r27        y_haut

TraceTriangle:
        La      r28,p1p2(r2)
        La      r29,p2p3(r2)
        La      r30,p3p1(r2)

        Mflr    r31                     # sauve l'adresse de retour
        Mr      r11,r27

        Mulli   r27,r27,320
        Add     r27,r4,r27              # chunkybuffer + (yhaut*320) -> r27

        Lhz     r14,0(r30)
        Tsth    r14
        Beq-    FinPASS
        Subi    r30,r30,1

TrianglePASS1:
        Lhz     r14,0(r28)               # hauteur -> r14
        Tsth    r14
        Beq-    TrianglePASS2
        Mtctr   r14
        Subi    r28,r28,1
        Bl      Remplissage

TrianglePASS2:
        Mr      r28,r29
        Lhz     r14,0(28)               # hauteur -> r14
        Tsth    r14
        Beq-    FinPASS
        Mtctr   r14
        Subi    r28,r28,1
        Bl      Remplissage

FinPASS:
        Mtlr    r31                     # restaure l'adresse de retour

NxtTriangle:
        Mtctr   r12
        Bdnz    LoopPolygone

PasDePolygone:
        Blr

#------------------
#---- ScanLine ----
# -> r27        départ Chunky buffer
# -> r28        PTR Tableau des coords x1
# -> r30        PTR Tableau des coords x2
# -> r14        Hauteur à remplir

Remplissage:
        Lhzu    r15,3(r28)              # x1 -> r15
        Lhzu    r16,3(r30)              # x2 -> r16
        Lbz     r17,2(r28)              # i1 -> r17
        Lbz     r18,2(r30)              # i2 -> r18

#---- clipping vertical----
        Cmpwi   r11,clipbas
        Bge-    Stop

        Tstw    r11
        Blt-    NxtSeg

#---- Trie les extremitées
        Cmpw    r16,r15
        Bgt     SegmentOk

        Exg     r15,r16         # échange x1 & x2
        Exg     r17,r18         # échange i1 & i2

SegmentOk:

# r15&r17 = x&i_gauche
# r16&r18 = x&i_droite

        Sub.    r19,r16,r15             # largeur du segment -> r19
        #Tstw    r19
        Beq-    NxtSeg

        Sub     r20,r18,r17             # différence intensitées -> r20

        Add     r21,r27,r15             # adresse du segment -> r21
        #Subi    r21,r21,1

# interpolation

        Swap    r20
        Divw    r20,r20,r19
        Swap    r20

        Mfctr   r14
        Mtctr   r19

        Li      r19,0                   # Clear carry
        Adde    r19,r19,r19             #

ScanLoop:
        Stbu    r17,1(r21)
        Adde    r17,r20,r17
        Bdnz    ScanLoop

        Mtctr   r14

NxtSeg: La      r27,320(r27)
        Addi    r11,r11,1
        Bdnz    Remplissage

Stop:   Blr

# ---- DATAS SECTION ----

.Section        datas,"drw4F"

.Bss    points,4*12

.Bss    p1p2,8+(dymax*3),0
.Bss    p2p3,8+(dymax*3),0
.Bss    p3p1,8+(dymax*3),0


;   Polygon texture mapping
;
;   Ostyl of Mankind
;   Rev Date: 21.2.2003
;
;   Input Registers:
;      r2  =   *_LinkerDB
;      r3  =   *PowerPC_BASE
;      r4  =   *struct firstlwobj
;      r5  =   *struct ChunkyScreen

        MACHINE     68040
        LINKABLE

        SECTION     Code_F

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

local   SETR        stack

        ;---- Code options

Yes             EQU     1
No              EQU     0

;TrueColor       SET     Yes
ChunkyWidth     EQU     320
ChunkyHeight    EQU     200

        ;---- Equates

MaxSegSize  EQU     320
xn          EQU     0
yn          EQU     4
zn          EQU     8

            XDEF    PolyDraw15PPC

PolyDraw15PPC:
            Pushlr
            Lwz     r7,lwo_Transforms+nobj_SortList(r4)
            Lhz     r6,0(r7)
            Mr.     r6,r6
            Beq-    Leave

PolyLoop:   La      r7,2(r7)
            Push    r7
            Lwz     r8,lwo_PolygonsPTR(r4)
            Lhz     r7,0(r7)
            Mulli   r7,r7,10
            Add     r7,r7,r8

            Lhz     r10,2(r7)   ;p1
            Lhz     r11,4(r7)   ;p2
            Lhz     r12,6(r7)   ;p3
            Slwi    r10,r10,2
            Slwi    r11,r11,2
            Slwi    r12,r12,2
            Mulli   r13,r10,3
            Mulli   r14,r11,3
            Mulli   r15,r12,3

            Lwz     r8,lwo_StructLwSurf(r4)
            Lhz     r7,8(r7)
            Subi    r7,r7,1
            Mulli   r7,r7,lws_SIZEOF
            Add     r7,r7,r8
            Lwz     r7,lws_UVList(r7)

            Add     r10,r10,r7  ;uv1
            Add     r11,r11,r7  ;uv2
            Add     r12,r12,r7  ;uv3
            Lwz     r7,lwo_Transforms+nobj_2dVertices(r4)
            Add     r13,r13,r7  ;xyz1
            Add     r14,r14,r7  ;xyz2
            Add     r15,r15,r7  ;xyz3

            ;----

            Lwz     r16,yn(r13)
            Lwz     r17,yn(r14)
            Lwz     r18,yn(r15)

Exg         MACRO
            Mr      r31,\1
            Mr      \1,\2
            Mr      \2,r31
            ENDM

TrieY1:     Cmpw    r16,r18
            Ble     TrieY2
            Exg     r16,r18
            Exg     r13,r15
            Exg     r10,r12

TrieY2:     Cmpw    r16,r17
            Ble     TrieY3
            Exg     r16,r17
            Exg     r14,r13
            Exg     r10,r11

TrieY3:     Cmpw    r17,r18
            Ble     TrieY4
            Exg     r17,r18
            Exg     r14,r15
            Exg     r11,r12

TrieY4:     ;----

            Push    r5

            Mr      r27,r16
            Mulli   r31,r16,320         ;yhaut*320  -> r10
            Add     r31,r31,r31

            Lhz     r26,cks_ChunkyHeight(r5)
            Lwz     r5,cks_ChunkyMap(r5)
            Add     r5,r5,r31           ;scanptr    -> r5

            ;----

            La      r30,CoeffHM
            Bl      InterLat

            La      r30,CoeffHB
            Exg     r14,r15
            Exg     r11,r12
            Bl      InterLat

            La      r30,CoeffMB
            Exg     r13,r15
            Exg     r10,r12
            Bl      InterLat

            ;----

            Lwz     r7,lwo_Targa(r4)
            Lwz     r7,tga_Converted(r7)

            ;----

            La      r8,CoeffHB
            La      r9,CoeffHM
            Lwz     r10,8(r9)                   ;MB_step -> r10
            Lwz     r11,8(r8)                   ;HB_step -> r11

            Cmpw    r10,r11
            Blt     PolyFill2
            Beq     Done

            ;----

PolyFill1:  Lwzu    r10,4(r8)                   ;xa         -> r10
            Lwzu    r11,4(r8)                   ;xa_step    -> r11
            Lwz     r31,0(r9)                   ;dy         -> r31
            Lwzu    r12,4(r9)                   ;xb         -> r12
            Lwzu    r13,4(r9)                   ;xb_step    -> r13
            Bl      Loop2

            La      r9,CoeffMB
            Lwz     r31,0(r9)                   ;dy         -> r31
            Lwzu    r12,4(r9)                   ;xb         -> r12
            Lwzu    r13,4(r9)                   ;xb_step    -> r13
            Bl      Loop2

            ;----

            B       Done

            ;----

PolyFill2:  Lwz     r31,0(r9)                   ;dy         -> r31
            Lwzu    r10,4(r9)                   ;xa         -> r10
            Lwzu    r11,4(r9)                   ;xa_step    -> r11
            Lwzu    r12,4(r8)                   ;xb         -> r12
            Lwzu    r13,4(r8)                   ;xb_step    -> r13
            Mr      r0,r8
            Mr      r8,r9
            Mr      r9,r0
            Bl      Loop2

            La      r8,CoeffMB
            Lwz     r31,0(r8)                   ;dy         -> r31
            Lwzu    r10,4(r8)                   ;xa         -> r10
            Lwzu    r11,4(r8)                   ;xa_step    -> r11
            Bl      Loop2

            ;----

Done:       Pop     r5
            Pop     r7
            Subi    r6,r6,1
            Mr.     r6,r6
            Bgt+    PolyLoop
Leave       Poplr
            Blr

;----------------------------------------------------------
;
;       interpolations latterals
;
;----------------------------------------------------------

InterLat:   Lwz     r16,xn(r13)         ;xa
            Lwz     r17,xn(r14)         ;xb
            Sub     r18,r17,r16         ;xb-xa=dx

            Lwz     r19,yn(r13)         ;ya
            Lwz     r20,yn(r14)         ;yb
            Sub     r19,r20,r19         ;yb-ya=dy
            Stw     r19,0(r30)          ;sauve dy
            Cmpwi   r19,MaxSegSize
            Blt+    Derive
            La      r19,Done
            Mtlr    r19
            Blr

Derive      Slwi    r18,r18,16
            Addi    r19,r19,1
            Divw    r18,r18,r19         ;dx/dy

            Slwi    r16,r16,16
            Stwu    r16,4(r30)          ;sauve xa
            Stwu    r18,4(r30)          ;sauve xa_step

            ;----

            Liw     r31,(65536*16384)<<1
            Lwz     r16,zn(r13)         ;za
            Lwz     r17,zn(r14)         ;zb
            Divw    r16,r31,r16         ;k(1/za)
            Divw    r17,r31,r17         ;k(1/zb)
            Sub     r18,r17,r16
            Divw    r18,r18,r19         ;(k/zb - k/za)/dy

            ;----

            Lwz     r20,0(r10)
            Rlwinm  r21,r20,16,16,31    ;ua
            Rlwinm  r22,r20,0,16,31     ;va
            Mullw   r21,r21,r16         ;ua*(k/za)
            Mullw   r22,r22,r16         ;va*(k/za)

            Lwz     r20,0(r11)
            Rlwinm  r23,r20,16,16,31    ;ub
            Rlwinm  r24,r20,0,16,31     ;vb
            Mullw   r23,r23,r17         ;ub*(k/zb)
            Mullw   r24,r24,r17         ;vb*(k/zb)

            Sub     r23,r23,r21         ;du
            Sub     r24,r24,r22         ;dv
            Divw    r23,r23,r19         ;[k(ub/zb - ua/za)]/dy
            Divw    r24,r24,r19         ;[k(vb/zb - va/za)]/dy

            ;----

            Mtctr   r19

InterLoop:  Add     r16,r16,r18         ;prochain k/z
            Add     r21,r21,r23         ;prochain ku/z
            Add     r22,r22,r24         ;prochain kv/z
            Stwu    r16,4(r30)          ;format : SSSS iiff
            Stwu    r21,4(r30)          ;format : SSii ffff
            Stwu    r22,4(r30)          ;format : SSii ffff
            Bdnz+   InterLoop
            Blr

;----------------------------------------------------------
;
;       scanline
;
;----------------------------------------------------------

Loop2:      Mr.         r31,r31         ;dy = 0 ?
            Beq-        StopScan

Loop3:      Add         r10,r10,r11     ;prochain xa
            Add         r12,r12,r13     ;prochain xb
            Srawi       r23,r10,16
            Srawi       r24,r12,16
            Sub.        r28,r24,r23
            Ble-        NextScan

            ;----

            Lwzu        r14,4(r8)       ;k/za -> r14
            Lwzu        r15,4(r9)       ;k/zb -> r15
            Sub         r15,r15,r14
            Divw        r15,r15,r28     ;dz/dx

            ;----

            Lwzu        r16,4(r8)       ;k(ua/za) -> r16
            Lwzu        r17,4(r8)       ;k(va/za) -> r17
            Lwzu        r18,4(r9)       ;k(uv/zb) -> r18
            Lwzu        r19,4(r9)       ;k(vb/zb) -> r19
            Sub         r18,r18,r16
            Sub         r19,r19,r17
            Divw        r18,r18,r28
            Divw        r19,r19,r28
            Slwi        r18,r18,2
            Slwi        r19,r19,2
            Slwi        r16,r16,2
            Slwi        r17,r17,2

            ;---- Clipping vertical

            Cmpw        r27,r26
            Bge-        StopScan
            Mr.         r27,r27
            Ble-        NextScan

            ;---- Clipping horizontal

            Cmpwi       r23,320
            Bge-        NextScan
            Mr.         r24,r24
            Ble-        NextScan

            Cmpwi       r24,320
            Ble         ClipRight
            Li          r24,320
ClipRight   Li          r20,0
            Sub.        r20,r20,r23
            Ble         ClipDone
            Li          r23,0
ClipDone    Sub.        r28,r24,r23
            Ble-        NextScan

            ;----

            Add         r23,r23,r23
            Add         r23,r23,r5
            La          r23,-2(r23)

            ;---- Pré-interpolation

            Mr.     r20,r20
            Ble+    NotClipped
            Mullw   r24,r15,r20
            Add     r14,r14,r24
            Mullw   r24,r18,r20
            Add     r16,r16,r24
            Mullw   r24,r19,r20
            Add     r17,r17,r24

NotClipped  ;----

            Liw         r20,65536*16384
            Mtctr       r28

ScanLoop:   Divw        r21,r20,r14         ;k/(k/z) = z
            Mulhw       r22,r21,r16         ;z * k(u/z) = ku
            Mulhw       r21,r21,r17         ;z * k(v/z) = kv
            Rlwimi      r22,r21,8,16,23
            Add         r22,r22,r22         ;2VU
            Lhzx        r21,r22,r7
            Sthu        r21,2(r23)
            Add         r14,r14,r15         ;prochain k/z
            Add         r16,r16,r18         ;prochain ku/z
            Add         r17,r17,r19         ;prochain kv/z
            Bdnz+       ScanLoop
   
            ;----

NextScan:   La          r5,320*2(r5)
            Addi        r27,r27,1
            Subi        r31,r31,1
            Mr.         r31,r31
            Bgt+        Loop3
StopScan:   Blr


*********************************************************************
*
*   DATAS SECTION
*
*********************************************************************

                SECTION Bss_F

CoeffHM         Ds.L    (3+MaxSegSize)*4
CoeffMB         Ds.L    (3+MaxSegSize)*4
CoeffHB         Ds.L    (3+MaxSegSize)*4

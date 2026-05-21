
                ; Load Address: $2ffc
                ; File Size: $9df
                ; File End: $cdf3
                ;
                ; Memory Map
                ;
                ;       Content         Start           End             Length
                ;       ----------------------------------------------------------
                ;       Loader          $00000800
                ;       Code            $00002ffc       $0000cd73       $00009df7
                ;       Data            $0001fffc       $0002a41a       $0000a41e
                ;       Data2 (mobile)  $0002a416       $00050043       $00025c2d
                ;       Data4 (wing)    $0002a416       $00056819       $0002c403
                ;       Stack           $0005c1f0       $00056819       (largest area of free mem - 59d7 bytes (22,999 decimal)
                ;       Display         $0005c200       $00068000       $0000be00
                ;       Music           $00068f7c       $0007c60e       $00013692
                ;       Panel           $0007c7fc       $00080000       $00003804
                ;
                ; Notes:
                ;  The memory map for these levels are packed full of data.
                ;
                
                section code_iff,code_c

                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"

TEST_BUILD_LEVEL        EQU     1
;TEST_BATMOBILE          EQU     1                               ; comment out to test Batwing

        IFD TEST_BUILD_LEVEL
BATMOBILE_TIMERVALUE    EQU     $6000                           ;  60 minutes on the timer for testing
BATWING_TIMERVALUE      EQU     $6000                           ;  60 minutes on the timer for testing
        ELSE
BATMOBILE_TIMERVALUE    EQU     $6000                           ;  Original minutes on the timer for testing
BATWING_TIMERVALUE      EQU     $6000                           ;  Original minutes on the timer for testing
        ENDC



        IFND    TEST_BUILD_LEVEL
                org     $2ffc                                         ; original load address
        ENDC




; Loader Constants
LOADER_TITLE_SCREEN             EQU $00000820                       ; Load Title Screen 
LOADER_LEVEL_1                  EQU $00000824                       ; Load Level 1
LOADER_LEVEL_2                  EQU $00000828                       ; Load Level 2
LOADER_LEVEL_3                  EQU $0000082c                       ; Load Level 3
LOADER_LEVEL_4                  EQU $00000830                       ; Load Level 4
LOADER_LEVEL_5                  EQU $00000834                       ; Load Level 5

          

        ; test/release constants
DISPLAY_BUFFER_SIZE     EQU     $be00
DISPLAY_BUFFER_SIZE_W   EQU     DISPLAY_BUFFER_SIZE/2
DISPLAY_BUFFER_SIZE_L   EQU     DISPLAY_BUFFER_SIZE/4
DISPLAY_BITPLANE_SIZE   EQU     $000017c0               ; 6080 bytes (6080/40 = 152)

        IFND     TEST_BUILD_LEVEL
STACK_TOP               EQU     $0005c1f0
DISPLAY_BUFFER          EQU     $0005c200
DISPLAY_BUFFER_1        EQU     DISPLAY_BUFFER
DISPLAY_BUFFER_2        EQU     DISPLAY_BUFFER+(DISPLAY_BUFFER_SIZE/2)
        ENDC
        IFD     TEST_BUILD_LEVEL
STACK_TOP               EQU     stack_address
DISPLAY_BUFFER          EQU     display_buffer
DISPLAY_BUFFER_1        EQU     DISPLAY_BUFFER
DISPLAY_BUFFER_2        EQU     DISPLAY_BUFFER+$5f00
        ENDC



    IFD TEST_BUILD_LEVEL
DATA_ADDRESS                    EQU     L0001fffc
 
    ELSE
DATA_ADDRESS                    EQU     $0001fffc           
    ENDC
DATA_OFFSET_0                   EQU     DATA_ADDRESS+$4                 ; $00020000 - $0001fffc = $4       
DATA_OFFSET_1                   EQU     DATA_ADDRESS+$4b04              ; $00024b00 - $0001fffc = $4b04
DATA_OFFSET_2                   EQU     DATA_ADDRESS+$6bea              ; $00026be6 - $0001fffc = $6bea
DATA_OFFSET_3                   EQU     DATA_ADDRESS+$8804              ; $00028800 - $0001fffc = $8804
DATA_OFFSET_4                   EQU     DATA_ADDRESS+$5504              ; $00025500 - $0001fffc = $5504
DATA_OFFSET_5                   EQU     DATA_ADDRESS+$6048              ; $00026044 - $0001fffc = $6048
DATA_OFFSET_6                   EQU     DATA_ADDRESS+$6538              ; $00026534 - $0001fffc = $6538


        ; DATA2.IFF/DATA4.IFF - Constants
        IFND    TEST_BUILD_LEVEL
DATA24_ADDRESS                  EQU     $0002a416
        ENDC
        IFD     TEST_BUILD_LEVEL
DATA24_ADDRESS                  EQU     L0002a416
        ENDC

; sorted by address location
DATA24_OFFSET_0                 EQU     DATA24_ADDRESS+$4               ; $0002a41a - $2a416 =     ; start address
DATA24_OFFSET_7                 EQU     DATA24_ADDRESS+$b49a            ; $000358b0 - $2a416 = $b49a
DATA24_OFFSET_6                 EQU     DATA24_ADDRESS+$b936            ; $00035d4c - $2a416 = $b936
DATA24_OFFSET_5                 EQU     DATA24_ADDRESS+$be18            ; $0003622e - $2a416 = $be18
DATA24_OFFSET_9                 EQU     DATA24_ADDRESS+$cbb2            ; $00036fc8 - $2a416 = $cbb2
DATA24_OFFSET_23                EQU     DATA24_ADDRESS+$d8cc            ; $00037ce2 - $2a416 = $d8cc
DATA24_OFFSET_24                EQU     DATA24_ADDRESS+$d90c            ; $00037d22 - $2a416 = $d90c
DATA24_OFFSET_25                EQU     DATA24_ADDRESS+$d93c            ; $00037d52 - $2a416 = $d93c
DATA24_OFFSET_26                EQU     DATA24_ADDRESS+$d96c            ; $00037d82 - $2a416 = $d96c
DATA24_OFFSET_27                EQU     DATA24_ADDRESS+$d98c            ; $00037da2 - $2a416 = $d98c
DATA24_OFFSET_28                EQU     DATA24_ADDRESS+$d9ac            ; $00037dc2 - $2a416 = $d9ac
DATA24_OFFSET_31                EQU     DATA24_ADDRESS+$d9cc            ; $00037de2 - $2a416 = $d9cc

DATA24_OFFSET_29                EQU     DATA24_ADDRESS+$d9dc            ; $00037df2 - $2a416 = $d9dc
DATA24_OFFSET_30                EQU     DATA24_ADDRESS+$d9fc            ; $00037e12 - $2a416 = $d9fc
DATA24_OFFSET_11                EQU     DATA24_ADDRESS+$e34a            ; $00038760 - $2a416 = $e34a
DATA24_OFFSET_12                EQU     DATA24_ADDRESS+$ec7c            ; $00039092 - $2a416 = $ec7c
DATA24_OFFSET_17                EQU     DATA24_ADDRESS+$eccc            ; $000390e2 - $2a416 = $eccc
DATA24_OFFSET_13                EQU     DATA24_ADDRESS+$f810            ; $00039c26 - $2a416 = $f810
DATA24_OFFSET_18                EQU     DATA24_ADDRESS+$fcac            ; $0003a0c2 - $2a416 = $fcac
DATA24_OFFSET_14                EQU     DATA24_ADDRESS+$100ca           ; $0003a4e0 - $2a416 = $100ca
DATA24_OFFSET_15                EQU     DATA24_ADDRESS+$10c4a           ; $0003b060 - $2a416 = $10c4a
DATA24_OFFSET_19                EQU     DATA24_ADDRESS+$1131c           ; $0003b732 - $2a416 = $1131c
DATA24_OFFSET_16                EQU     DATA24_ADDRESS+$117de           ; $0003bbf4 - $2a416 = $117de
DATA24_OFFSET_20                EQU     DATA24_ADDRESS+$12c8e           ; $0003d0a4 - $2a416 = $12c8e
DATA24_OFFSET_8                 EQU     DATA24_ADDRESS+$12dfe           ; $0003d214 - $2a416 = $12dfe
DATA24_OFFSET_1                 EQU     DATA24_ADDRESS+$13aaa           ; $0003dec0 - $2a416 = $13aaa
DATA24_OFFSET_21                EQU     DATA24_ADDRESS+$1404c           ; $0003e462 - $2a416 = $1404c
DATA24_OFFSET_22                EQU     DATA24_ADDRESS+$169ea           ; $00040e00 - $2a416 = $169ea
DATA24_OFFSET_10                EQU     DATA24_ADDRESS+$1817c           ; $00042592 - $2a416 = $1817c
DATA24_OFFSET_2                 EQU     DATA24_ADDRESS+$1b812           ; $00045c28 - $2a416 = $1b812
DATA24_OFFSET_3                 EQU     DATA24_ADDRESS+$1a230           ; $00044646 - $2a416 = $1a230
DATA24_OFFSET_4                 EQU     DATA24_ADDRESS+$21fe8           ; $0004c3fe - $2a416 = $21fe8


        IFD     TEST_BUILD_LEVEL
stack_address
code_start   
                IFD     TEST_BATMOBILE
                        jmp start_batmobile   
                ELSE  
                        jmp start_batwing
                ENDC     
        ENDC
        


L00002ffc               dc.l    $00002ffc
colourtest              dc.w    $0000

                        ; -------------- start batmobile level ------------
start_batmobile         ; original address $00003000
L00003000               bra.b   L00003010

                        ; --------------- start/set batwing level ---------------
start_batwing           ; original address $00003002
L00003002               move.w  #$0001,game_type        ; L00008d1e        ; batwing = 1
L0000300a               jmp     start_common            ; L0000301e

                        ; -------------- set batmobile level --------------
set_batmobile           ; original address $00003010
L00003010               move.w  #$0000,game_type        ; L00008d1e        ; batmobile = 0
L00003018               jmp    start_common             ; L0000301e


                        ; -------------- common startup code --------------
start_common            ; original address $0000301e
                        ;jsr     _DEBUG_COLOURS
L0000301e               moveq   #$00,d0
L00003020               move.w  #$7fff,CUSTOM+INTENA            ; $00dff09a
L00003028               move.w  #$1fff,CUSTOM+DMACON            ; $00dff096
L00003030               move.w  #$0200,CUSTOM+BPLCON0           ; $00dff100
L00003038               move.l  d0,CUSTOM+BPLCON1               ; $00dff102
L0000303e               move.w  #$4000,CUSTOM+DSKLEN            ; $00dff024
L00003046               move.l  d0,CUSTOM+BLTCON0               ; $00dff040
L0000304c               move.w  #$0041,CUSTOM+BLTSIZE           ; $00dff058 *** WHY! ***

L00003054               move.w  #$834f,CUSTOM+DMACON            ; $00dff096 - ENABLE,BITPLANE,DMAEN,BLITTER,AUDIO
L0000305c               move.w  #$7fff,CUSTOM+ADKCON            ; $00dff09e

                        ; reset sprites
L00003064               moveq   #$07,d7
L00003066               lea.l   CUSTOM+SPR0POS,a0               ; $00dff140,a0
L0000306c_loop          move.w  d0,(a0)
L0000306e               addq.w  #$08,a0
L00003070               dbf.w   d7,L0000306c_loop 

                        ; reset audio
L00003074               moveq   #$03,d7
L00003076               lea.l   CUSTOM+AUD0VOL,a0               ; $00dff0a8,a0
L0000307c_loop          move.w  d0,(a0) 
L0000307e               lea.l   $0010(a0),a0
L00003082               dbf.w   d7,L0000307c_loop

                        ; reset colours
L00003086               lea.l   CUSTOM+COLOR00,a0               ; $00dff180,a0
L0000308c               moveq   #$1f,d7
L0000308e_loop          move.w  d0,(a0)+
L00003090               dbf.w   d7,L0000308e_loop

                        ; init CIAA & CIAB
L00003094               move.b  #$7f,$00bfed01
L0000309c               move.b  d0,$00bfee01
L000030a2               move.b  d0,$00bfef01
L000030a8               move.b  d0,$00bfe001
L000030ae               move.b  #$03,$00bfe201
L000030b6               move.b  d0,$00bfe101
L000030bc               move.b  #$ff,$00bfe301
L000030c4               move.b  #$7f,$00bfdd00
L000030cc               move.b  d0,$00bfde00
L000030d2               move.b  d0,$00bfdf00
L000030d8               move.b  #$c0,$00bfd000
L000030e0               move.b  #$c0,$00bfd200
L000030e8               move.b  #$ff,$00bfd100
L000030f0               move.b  #$ff,$00bfd300

                        ; init stack
L000030f8               lea.l   STACK_TOP,a7                    ; $0005c1f0,a7 ; stack

L000030fe               jsr     L0000310a
                        pea.l   L0000310a
L00003104               jmp     AUDIO_PLAYER_INIT               ; $00068f80                       ; music
                        ; return here (pea.l L0000310a)

                        ; init interrupt autovectors
L0000310a               moveq   #$02,d7                         ; only level 1 - 3  handlers are initialised
L0000310c               lea.l   L000031ba,a0
L00003112               lea.l   $00000064,a1                    ; level 1 autovector
L00003118               move.l  (a0)+,(a1)+
L0000311a               dbf.w   d7,L00003118

                        ; more JOYDAT and CIA init
L0000311e               move.w  #$ff00,CUSTOM+POTGO             ; $00dff034
L00003126               move.w  d0,CUSTOM+JOYTEST               ; $00dff036
L0000312c               or.b    #$ff,$00bfd100
L00003134               and.b   #$87,$00bfd100
L0000313c               and.b   #$87,$00bfd100
L00003144               or.b    #$ff,$00bfd100
L0000314c               move.b  #$f0,$00bfe601
L00003154               move.b  #$37,$00bfeb01
L0000315c               move.b  #$11,$00bfef01
L00003164               move.b  #$91,$00bfd600
L0000316c               move.b  d0,$00bfdb00
L00003172               move.b  d0,$00bfdf00

L00003178               move.w  #$7fff,CUSTOM+INTREQ            ; $00dff09c
L00003180               tst.b   $00bfed01
L00003186               move.b  #$8a,$00bfed01
L0000318e               tst.b   $00bfdd00
L00003194               move.b  #$93,$00bfdd00
L0000319c               move.w  #$e078,CUSTOM+INTENA            ; $00dff09a - (PORTS 2, COPER,VERTB,BLIT 3)

L000031a4               bsr.w   clear_display_memory            ; L00003810
L000031a8               lea.l   copper_list,a0                  ; L000031d2,a0
L000031ae               bsr.w   initialise_display              ; L00003758
L000031b2               bsr.w   double_buffer_display           ; L000037c8

L000031b6               bra.w   initalise_game                  ; L00003822




                        ; --------------- interrupt handler table -------------
interrupt_handler_table ; original address $000031ba
L000031ba               dc.l    level1_interrupt_handler        ; L00003306               ; level 1 interrupt handler       
                        dc.l    level2_interrupt_handler        ; L0000333e               ; level 2 interrupt handler
                        dc.l    level3_interrupt_handler        ; L00003364               ; level 3 interrupt handler
                        dc.l    level4_interrupt_handler        ; L000033a0               ; level 4 interrupt handler - unused
L000031ca               dc.l    level5_interrupt_handler        ; L000033b6               ; level 5 interrupt handler - unused
                        dc.l    level6_interrupt_handler        ; L000033dc               ; level 6 interrupt handler - unused



                        even
                        ; ----------------- copper list -----------------------
copper_list             ; original address $000031d2
L000031d2               dc.w    $400f,$fffe
                        dc.w    $00e0
L000031d8               dc.w    $0000  
L000031da               dc.w    $00e2
L000031dc               dc.w    $0000
                        dc.w    $00e4
L000031e0               dc.w    $0000
                        dc.w    $00e6
L000031e4               dc.w    $0000
                        dc.w    $00e8
L000031e8               dc.w    $0000 
L000031ea               dc.w    $00ea
L000031ec               dc.w    $0000
                        dc.w    $00ec
L000031f0               dc.w    $0000
                        dc.w    $00ee
L000031f4               dc.w    $0000
bgcolour                dc.w    $0180,$0000   
L000031fa               dc.w    $0182,$0002
                        dc.w    $0184,$0888
                        dc.w    $0186,$0eee
                        dc.w    $0188,$0060
L0000320a               dc.w    $018a,$0800
                        dc.w    $018c,$0c00
                        dc.w    $018e,$0ccc
                        dc.w    $0190,$0aaa 
L0000321a               dc.w    $0192,$0666
                        dc.w    $0194,$0000
                        dc.w    $0196,$0c60
                        dc.w    $0198,$0ea2  
L0000322a               dc.w    $019a,$0ee0
                        dc.w    $019c,$0ee8
                        dc.w    $019e,$0444

                        ; city sky blue fade
                        dc.w    $460f,$fffe 
L0000323a               dc.w    $0182,$0003
                        dc.w    $4b0f,$fffe
                        dc.w    $0182,$0004
                        dc.w    $500f,$fffe
L0000324a               dc.w    $0182,$0005
                        dc.w    $550f,$fffe
                        dc.w    $0182,$0006
                        dc.w    $5a0f,$fffe  
L0000325a               dc.w    $0182,$0007
                        dc.w    $5f0f,$fffe
                        dc.w    $0182,$0008
                        dc.w    $640f,$fffe 
L0000326a               dc.w    $0182,$0009
                        dc.w    $690f,$fffe
                        dc.w    $0182,$000a

                        ; v-wait for horizon colour change?
copper_horizon_wait     ; original address L00003276
L00003276               dc.w    $600f,$fffe  
L0000327a               dc.w    $0182,$0333

                        ; Panel bitplane ptrs & colours
                        dc.w    $d90f,$fffe
copper_panel_planes     dc.w    $00e0,$0007
                        dc.w    $00e2,$c89a  
L0000328a               dc.w    $00e4,$0007
                        dc.w    $00e6,$d01a
                        dc.w    $00e8,$0007
                        dc.w    $00ea,$d79a 
L0000329a               dc.w    $00ec,$0007
                        dc.w    $00ee,$df1a
copper_panel_colours
                        dc.w    $0180,$0000
                        dc.w    $0182,$0000
                        dc.w    $0184,$0000
                        dc.w    $0186,$0000
                        dc.w    $0188,$0000
                        dc.w    $018a,$0000  
                        dc.w    $018c,$0000
                        dc.w    $018e,$0000
                        dc.w    $0190,$0000
                        dc.w    $0192,$0000   
                        dc.w    $0194,$0000
                        dc.w    $0196,$0000
                        dc.w    $0198,$0000
                        dc.w    $019a,$0000  
                        dc.w    $019c,$0000
                        dc.w    $019e,$0000

                        ; colours (panel fade in/out)
panel_colours           ; original address $000032e6
L000032e6               dc.w    $0000,$0060 
L000032ea               dc.w    $0fff,$0008,$0a22,$0444,$0862,$0666,$0888,$0aaa 
L000032fa               dc.w    $0a40,$0c60,$0e80,$0ea0,$0ec0,$0eee 




                ; -------------------- level 1 interrupt handler --------------------
                ; installed as the level 1 autovector interrupt handler.
level1_interrupt_handler        ; original address $00003306
L00003306               move.l  d0,-(a7)
L00003308               move.w  CUSTOM+INTREQR,d0       ; $00dff01e,d0
L0000330e               btst.l  #$0002,d0               ; SOFTINT
L00003312               bne.b   softint_interrupt       ; L00003332 ; clear SOFTINT and exit

L00003314               btst.l  #$0001,d0               ; DSKBLK
L00003318               bne.b   dskblk_interrupt        ; L00003326 ; clear DSKBLK and exit

tbe_interrupt
L0000331a               move.w  #$0001,CUSTOM+INTREQ    ; $00dff09c ; clear TBE and exit
L00003322               move.l  (a7)+,d0
L00003324               rte

dskblk_interrupt
L00003326               move.w  #$0002,CUSTOM+INTREQ    ; $00dff09c ; clear DSKBLK and exit
L0000332e               move.l (a7)+,d0
L00003330               rte 

softint_interrupt
L00003332               move.w  #$0004,CUSTOM+INTREQ    ; $00dff09c ; clear SOFTINT and exit
L0000333a               move.l  (a7)+,d0
L0000333c               rte  




                ; -------------------- level 2 interrupt handler --------------------
                ; installed as the level 2 autovector interrupt handler.
level2_interrupt_handler        ; original address $0000333e
L0000333e               move.l  d0,-(a7)
L00003340               move.b  $00bfed01,d0
L00003346               bpl.b   not_ciaa_interrupt      ; L00003358 ; not CIAA interrupt (clear PORTS and exit)

L00003348               bsr.w   handle_ciaa_interrupt   ; L0000341a ; handle CIAA interrupt

L0000334c               move.w  #$0008,CUSTOM+INTREQ    ; $00dff09c ; clear PORTS and exit
L00003354               move.l  (a7)+,d0
L00003356               rte  

not_ciaa_interrupt
L00003358               move.w #$0008,CUSTOM+INTREQ     ; $00dff09c ; clear PORTS and exit
L00003360               move.l (a7)+,d0
L00003362               rte  



                ; -------------------- level 3 interrupt handler --------------------
                ; installed as the level 3 autovector interrupt handler.
level3_interrupt_handler        ; original address $00003364
L00003364               move.l  d0,-(a7)
L00003366               move.w  CUSTOM+INTREQR,d0       ; $00dff01e,d0            ; intreqr
L0000336c               btst.l  #$0004,d0               ; COPER
L00003370               bne.b   coper_interrupt         ; L00003394 

L00003372               btst.l  #$0005,d0               ; VERTB
L00003376               bne.b   vertb_interrupt         ; L00003384       

blit_interrupt
L00003378               move.w  #$0040,CUSTOM+INTREQ    ; $00dff09c ; clear BLIT and exit
L00003380               move.l  (a7)+,d0
L00003382               rte  

vertb_interrupt
L00003384               bsr.w   vertb_interrupt_handler ; L00003568 ; handle VERTB
L00003388               move.w  #$0020,CUSTOM+INTREQ    ; $00dff09c ; clear VERTB and exit
L00003390               move.l  (a7)+,d0
L00003392               rte  

coper_interrupt
L00003394               move.w #$0010,CUSTOM+INTREQ     ; $00dff09c ; clear COPER and exit
L0000339c               move.l (a7)+,d0
L0000339e               rte 



                ; -------------------- level 4 interrupt handler --------------------
                ; unused
level4_interrupt_handler        ; original address L000033a0
                        jsr     _DEBUG_ERROR            ; if called will hold on a flashing screen
L000033a0               move.l  d0,-(a7)
L000033a2               move.w  CUSTOM+INTREQR,d0       ; $00dff01e,d0
L000033a8               and.w   #$0780,d0               ; clear audio interrupts
L000033ac               move.w  d0,CUSTOM+INTENA        ; $00dff09a - disable audio interrupts
L000033b2               move.l  (a7)+,d0
L000033b4               rte  



                ; -------------------- level 5 interrupt handler --------------------
                ; unused
level5_interrupt_handler        ; original address $000033b6
                        jsr     _DEBUG_ERROR            ; if called will hold on a flashing screen
L000033b6               move.l  d0,-(a7)
L000033b8               move.w  CUSTOM+INTREQR,d0       ; $00dff01e,d0 
L000033be               btst.l  #$000c,d0               ; DSKSYN
L000033c2               bne.b   dsksyn_interrupt        ; L000033d0
L000033c4               move.w  #$0800,CUSTOM+INTREQ    ; $00dff09c ; clear RBF (serial buffer interrupt)
L000033cc               move.l  (a7)+,d0
L000033ce               rte 

dsksyn_interrupt
L000033d0               move.w  #$1000,CUSTOM+INTREQ    ; $00dff09c ; Clear DISKSYN and exit
L000033d8               move.l  (a7)+,d0
L000033da               rte  



                ; -------------------- level 6 interrupt handler --------------------
                ; unused
level6_interrupt_handler        ; original address $000033dc
                        jsr     _DEBUG_ERROR
L000033dc               move.l  d0,-(a7)
L000033de               move.w  CUSTOM+INTREQR,d0       ; $00dff01e,d0
L000033e4               btst.l  #$000e,d0               ; INTEN (h/w ref says enable only - don't think this is ever set on read)
L000033e8               bne.b   inten_interrupt         ; L0000340e

L000033ea               move.b  $00bfdd00,d0
L000033f0               bpl.b   not_ciab_interrupt      ; L00003402

L000033f2               bsr.w   ciab_interrupt_handler  ; L0000355a
L000033f6               move.w  #$2000,CUSTOM+INTREQ    ; $00dff09c ; clear EXTER (CIAB & disk index flag)
L000033fe               move.l  (a7)+,d0
L00003400               rte  

not_ciab_interrupt
L00003402               move.w  #$2000,CUSTOM+INTREQ    ; $00dff09c ; clear EXTER (CIAB & disk index flag)
L0000340a               move.l  (a7)+,d0
L0000340c               rte 

inten_interrupt
L0000340e               move.w #$4000,CUSTOM+INTREQ     ; $00dff09c ; clear INTEN (doesnt make sense)
L00003416               move.l (a7)+,d0
L00003418               rte 




                ; ----------------- handle CIAA interrupt --------------
handle_ciaa_interrupt   ; original address $0000341a
L0000341a               lsr.b   #$02,d0
L0000341c               bcc.b   L00003422
L0000341e               bsr.w   L0000361e
L00003422               lsr.b   #$02,d0
L00003424               bcc.b   L00003494
L00003426               movem.l d1-d2/a0,-(a7)
L0000342a               move.b  $00bfec01,d1
L00003430               not.b   d1
L00003432               lsr.b   #$01,d1
L00003434               bcc.b   L0000344c
L00003436               lea.l   L0000353a,a0
L0000343c               ext.w   d1
L0000343e               move.b  L00003496(pc,d1.w),d1
L00003442               move.w  d1,d2
L00003444               lsr.w   #$03,d2
L00003446               bclr.b  d1,$00(a0,d2.w)
L0000344a               bra.b   L00003488
L0000344c               lea.l   L0000353a,a0
L00003452               ext.w   d1
L00003454               move.b  L00003496(pc,d1.w),d1
L00003458               move.w  d1,d2
L0000345a               lsr.w   #$03,d2
L0000345c               bset.b  d1,$00(a0,d2.w)
L00003460               tst.b   d1
L00003462               beq.b   L00003488
L00003464               lea.l   L00003516,a0
L0000346a               move.w  L00003536,d2
L00003470               move.b  d1,$00(a0,d2.w)
L00003474               addq.w  #$01,d2
L00003476               and.w   #$001f,d2
L0000347a               cmp.w   L00003538,d2
L00003480               beq.b   L00003488
L00003482               move.w  d2,L00003536
L00003488               move.b  #$40,$00bfee01
L00003490               movem.l (a7)+,d1-d2/a0
L00003494               rts  



L00003496               dc.w    $2731,$3233,$3435,$3637,$3839,$302d,$3d5c,$0030         ;'1234567890-=\.0
L000034a6               dc.w    $5157,$4552,$5459,$5549,$4f50,$5b5d,$0031,$3233         ;qwertyuiop[].123
L000034b6               dc.w    $4153,$4446,$4748,$4a4b,$4c3b,$2300,$0034,$3536         ;asdfghjkl;#..456
L000034c6               dc.w    $005a,$5843,$5642,$4e4d,$2c2e,$2f00,$0037,$3839         ;.zxcvbnm,./..789
L000034d6               dc.w    $2008,$090d,$0d1b,$7f00,$0000,$2d00,$8c8d,$8e8f         ; .........-.....
L000034e6               dc.w    $8182,$8384,$8586,$8788,$898a,$2829,$2f2a,$2b8b       ;..........()/*+.
L000034f6               dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00003506               dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00003516               dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00003526               dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00003536               dc.w    $0000
L00003538               dc.w    $0000
L0000353a               dc.w    $0000,$0000,$0000,$0000,$0000,$0000                     ;................
L00003546               dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00003556               dc.w    $0000,$0000 




                        ; ----------------- ciab interrupt handler -----------------
                        ; $d0 - CIAB - ICR (interrupt control register)
ciab_interrupt_handler  ; original address $0000355a
L0000355a                       lsr.b   #$02,d0
L0000355c                       bcc.b   L00003566
L0000355e                       move.b  #$00,$00bfee01          ; is CIAB timer B - set CIAA - Control Register A (stop CIAA timer A)
L00003566                       rts 



                        ; ----------------- vertb interrupt handler -----------------
                        ; called from level 3 interrupt handler when VERTB interrupt
                        ; is generated.
vertb_interrupt_handler ; original address L00003568
L00003568                       movem.l d0-d7/a0-a6,-(a7)
                                ; set copper display bitplanes
L0000356c                       move.l  display_buffer1_ptr,d0          ; L000037c0,d0
L00003572                       move.w  d0,L000031dc
L00003578                       swap.w  d0
L0000357a                       move.w  d0,L000031d8
L00003580                       swap.w  d0
L00003582                       add.l   #DISPLAY_BITPLANE_SIZE,d0       ; #$000017c0,d0
L00003588                       move.w  d0,L000031e4
L0000358e                       swap.w  d0
L00003590                       move.w  d0,L000031e0 
L00003596                       swap.w  d0
L00003598                       add.l   #DISPLAY_BITPLANE_SIZE,d0       ;$000017c0,d0
L0000359e                       move.w  d0,L000031ec 
L000035a4                       swap.w  d0
L000035a6                       move.w  d0,L000031e8
L000035ac                       swap.w  d0
L000035ae                       add.l   #DISPLAY_BITPLANE_SIZE,d0       ;$000017c0,d0
L000035b4                       move.w  d0,L000031f4
L000035ba                       swap.w  d0
L000035bc                       move.w  d0,L000031f0 

L000035c2                       addq.w  #$01,frame_counter      ; L000037bc
L000035c8                       tst.w   L00008d20
L000035ce                       bne.b   L00003604               ; update music/sfx and exit

                                ; update score panel
L000035d0                      ;; pea.l   L000035dc
L000035d6                       jsr     PANEL_UPDATE            ; panel
                                ; return to here (pea.l L000035dc)

L000035dc                       tst.w   L00008d32
L000035e2                       bne.b   L00003604               ; update music/sfx and exit

L000035e4                       move.w  L00008f6e,d0
L000035ea                       neg.w   d0
L000035ec                       move.w  #$02ee,d1
L000035f0                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0)
L000035f6                       beq.b   L000035fc
L000035f8                       move.w  #$0384,d1
L000035fc                       add.w   d1,d0
L000035fe                       ;move.w  d0,AUDIO_OFFSET_L000690f0       ; $000690f0 ; music

L00003604
                                ;;;pea.l   L00003610
L0000360a                       ;jsr     AUDIO_PLAYER_UPDATE     ; $00068f98 ; music

L00003610                       move.b  #$00,$00bfee01          ; Clear CIAA control register A - stop CIAA timer A
L00003618                       movem.l (a7)+,d0-d7/a0-a6
L0000361c                       rts  



L0000361e                       movem.l d0-d7/a0-a6,-(a7)
L00003622                       bsr.w   L00003634
L00003626                       addq.w  #$01,L00003632
L0000362c                       movem.l (a7)+,d0-d7/a0-a6
L00003630                       rts 

L00003632                       dc.w    $0000
L00003634                       dc.w    $3039
L00003636                       dc.w    $00df
L00003638                       dc.w    $f00a

L0000363a                       move.w  L000036fe,d1
L00003640                       move.w  d0,L000036fe 
L00003646                       bsr.w   L000036c8
L0000364a                       move.b  d0,L00003705 
L00003650                       add.w   d1,L00003714 
L00003656                       add.w   d2,L00003716 
L0000365c                       btst.b  #$0006,$00bfe001
L00003664                       seq.b   L00003704 
L0000366a                       seq.b   L00003712 
L00003670                       btst.b  #$0002,$00dff016        ; POTGOR
L00003678                       seq.b   L00003713 
L0000367e                       move.w  CUSTOM+JOY1DAT,d0       ; $00dff00c,d0
L00003684                       move.w  L00003700,d1
L0000368a                       move.w  d0,L00003700 
L00003690                       bsr.b   L000036c8
L00003692                       move.b  d0,L00003709 
L00003698                       add.w   d1,L0000371a 
L0000369e                       add.w   d2,L0000371c 
L000036a4                       btst.b  #$0007,$00bfe001
L000036ac                       seq.b   L00003708 
L000036b2                       seq.b   L00003718 
L000036b8                       btst.b  #$0006,$00dff016        ; POTGOR
L000036c0                       seq.b   L00003719 
L000036c6                       rts  

L000036c8                       move.w  d0,d3
L000036ca                       move.w  d1,d2
L000036cc                       sub.b   d3,d1
L000036ce                       neg.b   d1
L000036d0                       ext.l   d1
L000036d2                       lsr.w   #$08,d2
L000036d4                       lsr.w   #$08,d3
L000036d6                       sub.b   d3,d2
L000036d8                       neg.b   d2
L000036da                       ext.l   d2
L000036dc                       moveq   #$03,d3
L000036de                       and.w   d0,d3
L000036e0                       lsr.w   #$06,d0
L000036e2                       and.w   #$000c,d0
L000036e6                       or.w    d3,d0
L000036e8                       move.b  L000036ee(pc,d0.w),d0
L000036ec                       rts 


L000036ee                       dc.w    $0002,$0a08
L000036f2                       dc.w    $0103 
L000036f4                       dc.w    $0b09,$0507 
L000036f8                       dc.w    $0f0d,$0406 
L000036fc                       dc.w    $0e0c 
L000036fe                       dc.w    $0000
L00003700                       dc.w    $0000
L00003702                       dc.w    $0000
L00003704                       dc.b    $00
L00003705                       dc.b    $00
L00003706                       dc.w    $0000
L00003708                       dc.b    $00
L00003709                       dc.b    $00
L0000370a                       dc.w    $0000,$0000
L0000370e                       dc.w    $0000,$0000
L00003712                       dc.b    $00
L00003713                       dc.b    $00
L00003714                       dc.w    $0000
L00003716                       dc.w    $0000
L00003718                       dc.b    $00
L00003719                       dc.b    $00
L0000371a                       dc.w    $0000
L0000371c                       dc.w    $0000

L0000371e                       move.l  d0,-(a7) 
L00003720                       bsr.b   L00003728
L00003722                       bne.b   L00003720
L00003724                       move.l  (a7)+,d0
L00003726                       rts  

L00003728                       movem.l d1-d2/a0,-(a7)
L0000372c                       lea.l   L00003516,a0
L00003732                       moveq   #$00,d0
L00003734                       movem.w L00003536,d1-d2
L0000373c                       cmp.w   d1,d2
L0000373e                       beq.b   L00003750
L00003740                       move.b  $00(a0,d2.w),d0
L00003744                       addq.w  #$01,d2
L00003746                       and.w   #$001f,d2
L0000374a                       move.w  d2,L00003538
L00003750                       tst.b   d0
L00003752                       movem.l (a7)+,d1-d2/a0
L00003756                       rts  


                        ;----------------- initialise display -------------------
                        ; a0 = copper_list
                        ;
initialise_display      ; original address $00003758
L00003758                       move.w  #$0080,CUSTOM+DMACON            ; $00dff096 - Disable COPPER
L00003760                       move.l  a0,CUSTOM+COP1LC                ; $00dff080 ; copper list
L00003766                       move.w  a0,CUSTOM+COPJMP1               ; $00dff088 ; copper strobe
L0000376c                       move.w  #$0038,CUSTOM+DDFSTRT           ; $00dff092
L00003774                       move.w  #$00d0,CUSTOM+DDFSTOP           ; $00dff094
L0000377c                       move.w  #$4181,CUSTOM+DIWSTRT           ; $00dff08e
L00003784                       move.w  #$09c1,CUSTOM+DIWSTOP           ; $00dff090
L0000378c                       move.w  #$0000,CUSTOM+BPL1MOD           ; $00dff108
L00003794                       move.w  #$0000,CUSTOM+BPL2MOD           ; $00dff10a
L0000379c                       move.w  #$4200,CUSTOM+BPLCON0           ; $00dff100 - 4 bitplanes, Colour

                  ; set bitplane ptrs if running a test build
                IFD     TEST_BUILD_LEVEL
                        move.l  #DISPLAY_BUFFER_1,display_buffer1_ptr
                        move.l  #DISPLAY_BUFFER_2,display_buffer2_ptr

                        lea     copper_panel_planes,a0
                        move.l  #PANEL_GFX,d0
                        move.w  d0,6(a0)
                        swap.w  d0
                        move.w  d0,2(a0)
                        swap.w  d0
                        add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                        move.w  d0,$0e(a0)
                        swap.w  d0
                        move.w  d0,$0a(a0)
                        swap.w  d0  
                        add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                        move.w  d0,$16(a0)
                        swap.w  d0
                        move.w  d0,$12(a0)
                        swap.w  d0        
                        add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                        move.w  d0,$1e(a0)
                        swap.w  d0
                        move.w  d0,$1a(a0)
                        swap.w  d0       
                ENDC

L000037a4                       clr.w   frame_counter                   ; L000037bc
L000037aa                       tst.w   frame_counter                   ; L000037bc
L000037b0                       beq.b   L000037aa
L000037b2                       move.w  #$8180,CUSTOM+DMACON            ; $00dff096 - Enable,Bitplane,Copper
L000037ba                       rts  


                        ; ----------- frame counter variables -----------
frame_and_target_counter ; original address $000037bc
frame_counter            ; original address $000037bc
L000037bc                       dc.w    $0000
target_frame_counter    ; original address $000037be
L000037be                       dc.w    $0002

                        ;------------- display buffer ptrs -------------
display_buffer_ptrs     ; original address $000037c0
display_buffer1_ptr     ; original address $000037c0
L000037c0                       dc.l    DISPLAY_BUFFER_1        ; $0005c200             ; display buffer 1
display_buffer2_ptr     ; original address $000037c4
L000037c4                       dc.l    DISPLAY_BUFFER_2        ; $00062100             ; display buffer 2



                        ; ---------------- double buffer display ---------------
double_buffer_display   ; original address $000037c8
L000037c8                       move.w  target_frame_counter,d0         ; L000037be,d0
L000037ce                       cmp.w   frame_counter,d0                ; L000037bc,d0
L000037d4                       bhi.b   L000037ce
L000037d6                       movem.l display_buffer_ptrs,d0-d1       ; L000037c0,d0-d1
L000037de                       exg.l   d0,d1
L000037e0                       movem.l d0-d1,display_buffer_ptrs       ; L000037c0
L000037e8                       move.w  frame_counter,d0                ; L000037bc,d0
L000037ee                       cmp.w   frame_counter,d0                ; L000037bc,d0
L000037f4                       beq.b   L000037ee
L000037f6                       clr.w   frame_counter                   ; L000037bc
L000037fc                       move.w  L00008d3a,d0                    ; horizon position?
L00003802                       not.b   d0
L00003804                       add.b   #$d9,d0                         ; $d9 = 217 (-39)
L00003808                       move.b  d0,copper_horizon_wait          ;L00003276 ; Copper Wait Instruction (vertical wait byte - does the horizon move up/down?)
L0000380e                       rts 




                        ; ----------------- clear display memory -----------------
clear_display_memory    ; original address $00003810
L00003810                       lea.l   DISPLAY_BUFFER,a0               ; $0005c200,a0 ; external address
L00003816                       move.w  #DISPLAY_BUFFER_SIZE_L-1,d7     ; #$2f7f,d7
L0000381a                       clr.l   (a0)+
L0000381c                       dbf.w   d7,L0000381a
L00003820                       rts  




                        ; -------------------- initialise game ---------------------
initalise_game          ; original address $00003822
L00003822                       pea.l   L00003834
L00003828                       pea.l   PANEL_INIT_LIVES        ; panel
L0000382e                       jmp     PANEL_INIT_ENERGY       ; panel

                                ;return here (pea.l L00003834)

                                ; test game type
L00003834                       tst.w   game_type               ; L00008d1e   (batwing = 1, batmobile = 0)             
L0000383a                       bne.w   batwing_start_level     ; L000038ec    




                        ; ------------------- batmobile start level ------------------
batmobile_start_level   ; original address L0000383e
L0000383e                       bsr.w   panel_fade_in                           ; L00003de0

                        ; draw intro text (back buffer)
L00003842                       lea.l   text_introduction,a0                    ; L00003e74,a0
L00003848                       bsr.w   large_text_plotter                      ; L0000410a
                        ; draw debug build text (back buffer)
                                lea.l   text_test_build,a0
                                bsr.w   small_text_plotter                      ; L0000410e
                        ; Wipetext to display.
L0000384c                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c

L00003850                       bsr.w   initialise_batmobile_data               ; L00008158

L00003854                       bsr.w   preshift_18_words                       ; L000074a4

L00003858                       lea.l   DATA24_OFFSET_1,a0                      ; $0003dec0,a0 ; Data2/Data4 offset address $3dec0-$2a416=$13aaa
L0000385e                       lea.l   DATA24_OFFSET_2,a1                      ; $00045c28,a1 ; Data2/4 offset address $45c28-$2a416=$1b812
L00003864                       bsr.w   mirror_sprite_gfx                       ; L00007b20

L00003868                       lea.l   DATA_OFFSET_2,a0                        ; $00026be6,a0 ; Data offset address $00026be6-$1fffc=$6bea
L0000386e                       lea.l   DATA_OFFSET_3,a1                        ; $00028800,a1 ; Data offset address $00028800=$1fffc=$8804
L00003874                       bsr.w   mirror_sprite_gfx                       ; L00007b20

L00003878                       bsr.w   panel_fade_in                           ; L00003de0

L0000387c                       move.w  #$03e7,L00008d22                        ; #$3e7 = 999 (Distance?)

L00003884                       move.w  #BATMOBILE_TIMERVALUE,d0
                                ;move.w  #$0500,d0                               ; BCD Timer Start Value 05:00 minutes
L00003888                       bsr.w   clear_state_init_panel                  ; L00003986

                                ; init unknown data values
L0000388c                       lea.l   L00008d5c,a0
L00003892                       move.w  #$0091,$0010(a0)
L00003898                       move.w  #$00bc,$0030(a0)
L0000389e                       move.w  #$0084,$002e(a0)
L000038a4                       move.w  #$0014,$002a(a0)
L000038aa                       move.w  #$fffc,$002c(a0)
L000038b0                       move.w  #$0004,L00008d2c
L000038b8                       move.w  #$0008,L00008d2e
L000038c0                       move.w  #$0002,L00008d30

                                ; Set (re)start distance to 999 or 500
L000038c8                       move.w  #$01f4,d0                               ; #$1f4 = 500 (level mid-point distance)
L000038cc                       cmp.w   L00008d22,d0                            
L000038d2                       bcc.b   L000038d8                               ; if L00008d22 < 500 then 
L000038d4                       move.w  #$03e7,d0                               ; reset distance to 999
L000038d8                       move.w  d0,L00008d22

L000038de                       move.l  #batmobile_section_list,road_section_list_ptr   ;#L00008236,L0000907c ; set initial road data ptr

L000038e8                       bra.w   common_game_initialisation              ; L000039aa




                        ; --------------------- batwing start level --------------------------
batwing_start_level     ; original address L000038ec 
L000038ec                       bsr.w   panel_fade_in                   ; L00003de0
L000038f0                       lea.l   text_gotham_carnival,a0         ; L00003ed0,a0
L000038f6                       bsr.w   large_text_plotter              ; L0000410a

                        ; draw debug build text (back buffer)
                                lea.l   text_test_build,a0
                                bsr.w   small_text_plotter  

L000038fa                       bsr.w   wipedisplay_backbuffer_to_front ; L00003d6c

L000038fe                       bsr.w   preshift_18_words               ; L000074a4

L00003902                       lea.l   DATA24_OFFSET_3,a0              ; $00044646,a0 ; Data2/4 offset $$00044646-$2a416=$1a230
L00003908                       lea.l   DATA24_OFFSET_4,a1              ; $0004c3fe,a1 ; Data2/4 offset $0004c3fe-$2a416=$21fe8
L0000390e                       bsr.w   mirror_sprite_gfx               ; L00007b20

L00003912                       lea.l   DATA_OFFSET_2,a0                ; $00026be6,a0 ; external address
L00003918                       lea.l   DATA_OFFSET_3,a1                ; $00028800,a1 ; external address
L0000391e                       bsr.w   mirror_sprite_gfx               ; L00007b20

L00003922                       bsr.w   initialise_batwing_data         ; L000081ce

L00003926                       move.w  #$0064,L00008d24                ; Balloons to Pop? #$64 = 100
L0000392e                       move.w  #BATWING_TIMERVALUE,d0
                                ;move.w  #$0300,d0                       ; BCD Level Timer Value 03:00 minutes
L00003932                       bsr.w   clear_state_init_panel          ; L00003986

                                ; init unknown data values
L00003936                       lea.l   L00008d5c,a0
L0000393c                       move.w  #$0064,$0010(a0)
L00003942                       move.w  #$0078,L00008f6e
L0000394a                       move.w  #$00c6,$0030(a0)
L00003950                       move.w  #$0070,$002e(a0)
L00003956                       move.w  #$0001,$002a(a0)
L0000395c                       move.w  #$ffec,$002c(a0)

                                ; set (re)start balloon total (100 or 50)
L00003962                       move.w  #$0032,d0                       ; d0 = #$32 = 50
L00003966                       cmp.w   L00008d24,d0
L0000396c                       bcc.b   L00003972
L0000396e                       move.w  #$0064,d0                       ; reset balloons to 100
L00003972                       move.w  d0,L00008d24                    ; set balloon total

L00003978                       move.l  #batwing_section_list,road_section_list_ptr     ; #L00008266,L0000907c ; set initial road data ptr

L00003982                       bra.w   common_game_initialisation                      ; L000039aa



                        ; ------------ clear level state and init the panel -------------
                        ; This routine clears 888 bytes of state between $8d26 - $909e
                        ; and initialises the panel timer with BCD value and player
                        ; energy.
                        ; IN:-
                        ;       d0.w = BCD Timer Value eg #$0300 = 03:00 minutes
                        ;
clear_state_init_panel
L00003986                       lea.l   L00008d26,a0
L0000398c                       move.w  #$01bb,d7               ; $1bb = (443 + 1 )* 2 = 888 bytes
L00003990_loop                  clr.w   (a0)+
L00003992                       dbf.w   d7,L00003990_loop

L00003996                       move.w  #$0002,L00008d2a
L0000399e                       pea.l   PANEL_INIT_ENERGY       ; panel
L000039a4                       jmp     PANEL_INIT_TIMER        ; panel
                                ; init timer, init energy & return




                        ; ------------------- common start level code ---------------
                        ; common game initialisation code jumped to after
                        ; batmobile or batwing specific initialisation.
                        ;
common_game_initialisation
L000039aa                       bsr.w   L00006a2c

L000039ae                       move.w  #$0000,L00008d26
L000039b6                       btst.b  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2   ;$0007c875        ; panel
L000039be                       bne.b   L000039ce
L000039c0                       moveq   #$01,d0
L000039c2                       pea.l   L000039ce
L000039c8                       jmp     AUDIO_PLAYER_INIT_SONG  ; $00068f90 ; music

                ; ------------------ game loop ---------------------
game_loop
L000039ce                       
                                ; increment background colour (show if game loop is running)
                                ;add.w   #1,colourtest
                                move.w  colourtest,bgcolour+2
                        ; common code (batmobile & batwing)
                                bsr.w   L00006ee6                       ; screen wipe?
L000039d2                       bsr.w   L000067ba
L000039d6                       bsr.w   L00006b02
L000039da                       bsr.w   L0000764a
L000039de                       bsr.w   L000074c8
L000039e2                       bsr.w   L00006d40
L000039e6                       bsr.w   L000051da
L000039ea                       bsr.w   L00005086
L000039ee                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0) 
L000039f4                       bne.b   L00003a00_batwing

                        ; batmobile specific
L000039f6_batmobile             bsr.w   L0000459c
L000039fa                       bsr.w   L000044a8
L000039fe                       bra.b   L00003a04_common

                        ; batwing specific
L00003a00_batwing               bsr.w   L000042be

                        ; common code again (batmobile & batwing)
L00003a04_common                bsr.w   L00004792
L00003a08                       bsr.w   L00005764
L00003a0c                       bsr.w   L00006f1c               ; draw road (crashing when moving)
L00003a10                       bsr.w   L00004cb2              ; draw sprites (car & buildings? - crashing)
L00003a14                       bsr.w   L00003f70               ; draw HUD (speed/distance)
L00003a18                       bsr.w   L00003be0               ; draw direction arrow (top-centre)
L00003a1c                       bsr.w   L00003a34
L00003a20                       pea.l   L000039ce                       ; game loop on stack
L00003a26                       move.w  L00008d2a,d0
L00003a2c                       bne.w   L00003cb8
L00003a30                       bra.w   double_buffer_display           ; L000037c8
                                ; use 'rts' to return address on the stack - game loop


L00003a34                       tst.w   L00008f66
L00003a3a                       bne.b   L00003a62
L00003a3c                       move.b  PANEL_STATUS_1,d0               ; $0007c874,d0            ; panel
L00003a42                       and.b   #$07,d0
L00003a46                       beq.b   L00003a60       ; 0 = exit
                        ; timer, nolives or life lost
L00003a48                       tst.w   game_type                       ; L00008d1e (batwing = 1, batmobile = 0)
L00003a4e                       beq.b   L00003a62
L00003a50                       tst.w   L00008d38
L00003a56                       bne.b   L00003a60
L00003a58                       move.w  #$0019,L00008d38
L00003a60                       rts  

L00003a62                       move.w  #$0001,L00008d20
L00003a6a                       btst.b  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1   ;$0007c874        ; panel
L00003a72                       bne.w   L00003b18       ; branch = no lives left
L00003a76                       pea.l   L00003a82
L00003a7c                       jmp     AUDIO_PLAYER_SILENCE    ; $00068f84  ; music
L00003a82                       pea.l   L00003a90
L00003a88                       moveq   #$03,d0
L00003a8a                       jmp     AUDIO_PLAYER_INIT_SONG  ; $00068f90 ; music

L00003a90                       btst.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1   ;$0007c874        ; panel
L00003a98                       beq.b   L00003abc
                        ; timer has expired
L00003a9a                       bsr.w   L00003d5a
L00003a9e                       lea.l   text_time_up,a0                         ; L00003f20,a0
L00003aa4                       bsr.w   large_text_plotter                      ; L0000410a
L00003aa8                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c

L00003aac                       clr.w   frame_counter                           ; L000037bc
L00003ab2                       cmp.w   #$0032,frame_counter                    ; L000037bc
L00003aba                       bcs.b   L00003ab2
L00003abc                       bsr.w   L00003d5a
L00003ac0                       lea.l   text_introduction,a0                    ; L00003e74,a0
L00003ac6                       lea.l   L00003884,a1
L00003acc                       tst.w   game_type                               ; L00008d1e (batwing = 1, batmobile = 0) 
L00003ad2                       beq.b   L00003ae0 

L00003ad4                       lea.l   text_gotham_carnival,a0                 ; L00003ed0,a0
L00003ada                       lea.l   L0000392e,a1
L00003ae0                       move.l  a1,(a7)
L00003ae2                       bsr.w   large_text_plotter                      ; L0000410a

L00003ae6                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c

L00003aea                       clr.w   frame_counter                           ; L000037bc
L00003af0                       cmp.w   #$0032,frame_counter                    ; L000037bc
L00003af8                       bcs.b   L00003af0
L00003afa                       cmp.w   #$0001,L00008f66 
L00003b02                       bne.b   L00003b0a
L00003b04                       pea.l   PANEL_LOSE_LIFE         ; panel
L00003b0a                       move.w  #$0000,L00008f66
L00003b12                       jmp     PANEL_ADD_LIFE          ; panel
                                ; use rts to return (pea.l PANEL_LOSE_LIFE)

L00003b18                       move.w  #$0001,L00008d20
L00003b20                       pea.l   L00003b2c
L00003b26                       jmp     AUDIO_PLAYER_SILENCE    ; $00068f84 ; music
L00003b2c                       pea.l   L00003b3a
L00003b32                       moveq   #$04,d0
L00003b34                       jmp     AUDIO_PLAYER_INIT_SONG  ; $00068f90 ; music

L00003b3a                       bsr.w   L00003d5a
L00003b3e                       lea.l   text_game_over,a0                       ; L00003f2c,a0
L00003b44                       bsr.w   large_text_plotter                      ; L0000410a
L00003b48                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c

L00003b4c                       clr.w   frame_counter                           ; L000037bc
L00003b52                       cmp.w   #$0050,frame_counter                    ; L000037bc
L00003b5a                       bcs.b   L00003b52
L00003b5c                       bsr.w   L00003d5a
L00003b60                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c
L00003b64                       bsr.w   panel_fade_out                          ; L00003e2c
L00003b68                       jmp     LOADER_TITLE_SCREEN                     ; $00000820 ; loader - TITLE SCREEN


L00003b6e                       move.w  #$0001,L00008d20
L00003b76                       pea.l   L00003b82
L00003b7c                       jmp     AUDIO_PLAYER_SILENCE    ; $00068f84 ; music
L00003b82                       pea.l   L00003b90
L00003b88                       moveq   #$02,d0
L00003b8a                       jmp     AUDIO_PLAYER_INIT_SONG  ; $00068f90; music

L00003b90                       bsr.w   L00003d5a
L00003b94                       lea.l   text_escaped_joker,a0                   ; L00003e92,a0
L00003b9a                       tst.w   game_type                               ; L00008d1e (batwing = 1, batmobile = 0) 
L00003ba0                       beq.b   L00003ba8 
L00003ba2                       lea.l   text_city_is_safe,a0                    ; L00003ee8,a0
L00003ba8                       bsr.w   large_text_plotter                      ; L0000410a
L00003bac                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c
L00003bb0                       clr.w   frame_counter                           ; L000037bc
L00003bb6                       cmp.w   #$0055,frame_counter                    ; L000037bc
L00003bbe                       bcs.b   L00003bb6
L00003bc0                       bsr.w   L00003d5a
L00003bc4                       bsr.w   wipedisplay_backbuffer_to_front         ; L00003d6c
L00003bc8                       bsr.w   panel_fade_out                          ; L00003e2c
L00003bcc                       tst.w   game_type                               ; L00008d1e (batwing = 1, batmobile = 0)
L00003bd2                       bne.b   L00003bda
L00003bd4                       jmp     LOADER_LEVEL_3                          ; $0000082c               ; loader
L00003bda                       jmp     LOADER_LEVEL_5                          ; $00000834               ; loader

L00003be0                       lea.l   L00008d5c,a6
L00003be6                       tst.w   game_type                               ; L00008d1e (batwing = 1, batmobile = 0)
L00003bec                       beq.b   L00003c2a
L00003bee                       tst.w   $0028(a6)
L00003bf2                       beq.b   L00003c14 
L00003bf4                       tst.w   L00008d34
L00003bfa                       bne.b   L00003c66
L00003bfc                       move.w  #$0001,L00008d34
L00003c04                       move.w  #$0001,L00008d32
L00003c0c                       moveq   #$07,d0
L00003c0e                       jmp     AUDIO_PLAYER_INIT_SFX           ; $00068f94 ; music

L00003c14                       tst.w   L00008d34
L00003c1a                       beq.b   L00003c66
L00003c1c                       moveq   #$07,d0
L00003c1e                       pea.l   L00003c66
L00003c24                       jmp     AUDIO_PLAYER_INIT_SFX_2         ; $00068f8c ; music

L00003c2a                       tst.w   $0032(a6)
L00003c2e                       beq.b   L00003c50
L00003c30                       tst.w   L00008d34
L00003c36                       bne.b   L00003c66
L00003c38                       move.w  #$0001,L00008d34
L00003c40                       move.w  #$0001,L00008d32
L00003c48                       moveq   #$09,d0
L00003c4a                       jmp     AUDIO_PLAYER_INIT_SFX           ; $00068f94 ; music

L00003c50                       tst.w   L00008d34
L00003c56                       beq.b   L00003c66
L00003c58                       moveq   #$09,d0
L00003c5a                       pea.l   L00003c66
L00003c60                       jmp     AUDIO_PLAYER_INIT_SFX_2         ; $00068f8c ; music
L00003c66                       tst.w   AUDIO_OFFSET_L000690a6          ; $000690a6 ; music
L00003c6c                       bne.b   L00003c90
L00003c6e                       move.w  #$0000,L00008d32
L00003c76                       move.w  #$0000,L00008d34
L00003c7e                       moveq   #$05,d0
L00003c80                       tst.w   game_type                       ; L00008d1e (batwing = 1, batmobile = 0)
L00003c86                       beq.b   L00003c8a
L00003c88                       moveq   #$06,d0
L00003c8a                       jmp     AUDIO_PLAYER_INIT_SFX           ; $00068f94 ; music

L00003c90                       rts  

L00003c92                       movem.l d1-d7/a0-a6,-(a7)
L00003c96                       move.w  #$0001,L00008d32
L00003c9e                       move.w  #$0000,L00008d34
L00003ca6                       pea.l   L00003cb2
L00003cac                       jmp     AUDIO_PLAYER_INIT_SFX           ; $00068f94 ; music
L00003cb2                       movem.l (a7)+,d1-d7/a0-a6
L00003cb6                       rts  

L00003cb8                       ;jsr     _DEBUG_COLOURS_PAUSE
                                move.w  #$0000,L00008d2a
L00003cc0                       move.w  #$0000,L00008d20
L00003cc8                       move.w  L00008d3a,d1                    ; horizon position
L00003cce                       not.b   d1
L00003cd0                       add.b   #$d9,d1                         ; #$d9 = 217 (-39)
L00003cd4                       move.b  d1,copper_horizon_wait          ; L00003276
L00003cda                       cmp.w   #$0002,d0
L00003cde                       beq.w   wipedisplay_backbuffer_to_front         ; L00003d6c
L00003ce2                       moveq   #$00,d0
L00003ce4                       moveq   #$26,d1
L00003ce6                       movea.l display_buffer1_ptr,a0          ; L000037c0,a0
L00003cec                       movea.l display_buffer2_ptr,a1          ; L000037c4,a1
L00003cf2                       lea.l   $28(a0,d1.w),a2
L00003cf6                       lea.l   $28(a1,d1.w),a3
L00003cfa                       lea.l   $00(a0,d0.w),a0
L00003cfe                       lea.l   $00(a1,d0.w),a1
L00003d02                       moveq   #$4b,d7
L00003d04                       move.w  (a1),(a0)
L00003d06                       move.w  $17c0(a1),$17c0(a0)
L00003d0c                       move.w  $2f80(a1),$2f80(a0)
L00003d12                       move.w  $4740(a1),$4740(a0)
L00003d18                       move.w  (a3),(a2)
L00003d1a                       move.w  $17c0(a3),$17c0(a2)
L00003d20                       move.w  $2f80(a3),$2f80(a2)
L00003d26                       move.w  $4740(a3),$4740(a2)
L00003d2c                       lea.l   $0050(a0),a0
L00003d30                       lea.l   $0050(a1),a1
L00003d34                       lea.l   $0050(a2),a2
L00003d38                       lea.l   $0050(a3),a3
L00003d3c                       dbf.w   d7,L00003d04
L00003d40                       addq.w  #$02,d0
L00003d42                       subq.w  #$02,d1
L00003d44                       bmi.b   L00003d58
L00003d46                       tst.w   frame_counter                   ; L000037bc
L00003d4c                       beq.b   L00003d46
L00003d4e                       move.w  #$0000,frame_counter            ; L000037bc
L00003d56                       bra.b   L00003ce6
L00003d58                       rts  

L00003d5a                       movea.l display_buffer2_ptr,a0          ; L000037c4,a0
L00003d60                       move.w  #$17bf,d7
L00003d64                       clr.l   (a0)+
L00003d66                       dbf.w   d7,L00003d64
L00003d6a                       rts  



                ; -------------------- wipe display - back buffer to front --------------------
                ; Wipes the display buffer by gradually copying the back buffer gfx 
                ; into the front buffer gfx.
                ;
wipedisplay_backbuffer_to_front ; original address L00003d6c
L00003d6c                       move.w  #$0028,d0                       ; d0 = 40
L00003d70                       move.w  #$0098,d1                       ; d1 = 151 (scan lines?)
L00003d74                       movem.l display_buffer_ptrs,a0-a1       ; L000037c0,a0-a1
L00003d7a                       clr.w   d2
wd_main_loop
L00003d7c                       moveq   #$7f,d3                         ; d3 = 127 (low 7 bits)
L00003d7e                       and.w   d2,d3                           ; d3 = low 7 bits of d2 (clamped to 127)
L00003d80                       moveq   #$0f,d5                         ; d5 = 15
L00003d82                       lsr.w   #$01,d3                         ; d3 = low 7 bits / 2
L00003d84                       bcc.b   L00003d88
wd_bit_shifted_out
L00003d86                       moveq.l #$fffffff0,d5                   ; d5 = -16
wd_no_bit_shifted_out
L00003d88                       cmp.w   d0,d3                           ; compare d3 with 40
L00003d8a                       bcc.b   L00003dd2                       ; d3 < 40
L00003d8c                       move.w  d2,d4
L00003d8e                       lsr.w   #$05,d4
L00003d90                       and.w   #$00fc,d4
L00003d94                       cmp.w   d1,d4
L00003d96                       bcc.b   L00003dd2
L00003d98                       mulu.w  d0,d4
L00003d9a                       add.w   d3,d4
L00003d9c                       move.w  d2,-(a7)
L00003d9e                       move.w  d0,d3
L00003da0                       mulu.w  d1,d3
L00003da2                       moveq   #$03,d7
wd_outer_loop
L00003da4                       move.w  d4,-(a7)
L00003da6                       moveq   #$03,d2
wd_inner_loop
L00003da8                       move.b  d5,d6                   ; d5 = display buffer byte mask, either = %00001111 or %11110000
L00003daa                       not.w   d6                      ; d6 = inverse display buffer byte mask
L00003dac                       and.b   $00(a0,d4.w),d6         ; d6 = either high 4 or low 4 bits of display byte
L00003db0                       move.b  d6,$00(a0,d4.w)         ; write back to dispaly (masked out byte)

L00003db4                       move.b  d5,d6                   ; d6 = inverse mask
L00003db6                       and.b   $00(a1,d4.w),d6         ; and back buffer display byte with mask
L00003dba                       or.b    $00(a0,d4.w),d6         ; merge back buffer display byte with front buffer
L00003dbe                       move.b  d6,$00(a0,d4.w)         ; store merged byte into display buffer
L00003dc2                       add.w   d0,d4                   ; increment display index
L00003dc4                       dbf.w   d2,wd_inner_loop          ;L00003da8
L00003dc8                       move.w  (a7)+,d4
L00003dca                       add.w   d3,d4
L00003dcc                       dbf.w   d7,wd_outer_loop          ; L00003da4
L00003dd0                       move.w  (a7)+,d2

L00003dd2                       mulu.w  #$0555,d2               ; 1365 (1351,1367 are prime)
L00003dd6                       addq.w  #$01,d2
L00003dd8                       and.w   #$1fff,d2               ; clamp d2 to 8192
L00003ddc                       bne.b   wd_main_loop               ; L00003d7c
L00003dde                       rts  



                ; -------------------- panel fade in ---------------------
panel_fade_in
L00003de0                       moveq   #$0f,d7
L00003de2                       lea.l   copper_panel_colours+2,a0               ; L000032a4,a0
L00003de6                       lea.l   panel_colours,a1                        ; L000032e6,a1
L00003dea                       moveq   #$0f,d6
L00003dec                       move.w  (a0),d0
L00003dee                       move.w  (a1)+,d1
L00003df0                       eor.w   d0,d1
L00003df2                       moveq   #$0f,d2
L00003df4                       and.w   d1,d2
L00003df6                       beq.b   L00003dfa
L00003df8                       addq.w  #$01,d0
L00003dfa                       moveq.l #$fffffff0,d2
L00003dfc                       and.b   d1,d2
L00003dfe                       beq.b   L00003e04
L00003e00                       add.w   #$0010,d0
L00003e04                       and.w   #$0f00,d1
L00003e08                       beq.b   L00003e0e
L00003e0a                       add.w   #$0100,d0
L00003e0e                       move.w  d0,(a0)
L00003e10                       addq.w  #$04,a0
L00003e12                       dbf.w   d6,L00003dec
L00003e16                       move.w  frame_counter,d0        ; L000037bc,d0
L00003e1c                       addq.w  #$04,d0
L00003e1e                       cmp.w   frame_counter,d0        ; L000037bc,d0
L00003e24                       bne.b   L00003e1e
L00003e26                       dbf.w   d7,L00003de2
L00003e2a                       rts  



                ; ------------------- panel fade out ---------------------
panel_fade_out
L00003e2c                       moveq   #$0f,d7
L00003e2e                       lea.l   copper_panel_colours+2,a0       ; L000032a4,a0
L00003e32                       moveq   #$0f,d6
L00003e34                       move.w  (a0),d0
L00003e36                       moveq   #$0f,d1
L00003e38                       and.w   d0,d1
L00003e3a                       beq.b   L00003e3e
L00003e3c                       subq.w  #$01,d0
L00003e3e                       move.w  #$00f0,d1
L00003e42                       and.w   d0,d1
L00003e44                       beq.b   L00003e4a
L00003e46                       sub.w   #$0010,d0
L00003e4a                       move.w  #$0f00,d1
L00003e4e                       and.w   d0,d1
L00003e50                       beq.b   L00003e56
L00003e52                       sub.w   #$0100,d0
L00003e56                       move.w  d0,(a0)
L00003e58                       addq.w  #$04,a0
L00003e5a                       dbf.w   d6,L00003e34
L00003e5e                       move.w  frame_counter,d0        ; L000037bc,d0
L00003e64                       addq.w  #$04,d0
L00003e66                       cmp.w   frame_counter,d0        ; L000037bc,d0
L00003e6c                       bne.b   L00003e66
L00003e6e                       dbf.w   d7,L00003e2e
L00003e72                       rts 


                                even
text_test_build                 dc.b    $05,$08,'TEST BUILD 28/02/2025',$00,$ff

                                even
text_introduction
L00003e74                       dc.b    $44,$07,'THE STREETS OF GOTHAM CITY',$00,$ff

                                even
text_escaped_joker
L00003e92                       dc.b    $3a,$07,'YOU HAVE ESCAPED THE JOKER',$00
                                dc.b    $4e,$06, 'BUT WHAT SECRETS LIE AHEAD...',$00,$ff

                                even
text_gotham_carnival
L00003ed0                       dc.b    $44,$0a,'GOTHAM CITY CARNIVAL',$00,$ff

                                even
text_city_is_safe
L00003ee8                       dc.b    $3a,$08,'THE CITY IS SAFE BUT THE',$00
                                dc.b    $4e,$08,'JOKER IS STILL AT LARGE',$00,$ff

                                even
text_time_up
L00003f20                       dc.b    $44,$10,'TIME UP',$00,$ff

                                even
text_game_over
L00003f2c                       dc.b    $44,$0f,'GAME OVER',$00,$ff

                                even
text_speed
L00003f3a                       dc.b    $02,$01,'SPEED',$00
text_speed_value                dc.b    $0c,$02,'000',$00,$ff

                                even
text_distance  
L00003f4a                       dc.b    $02,$1f,'DISTANCE',$00
text_distance_value             dc.b    $0c,$21,'99',$2e,'9',$00,$ff  

                                even
text_balloons
L00003f5e                       dc.b    $02,$1f,'BALLOONS',$00
text_balloons_value             dc.b    $0c,$22,'000',$00,$ff
                                even

L00003f70                       move.w  L00008f6e,d0
L00003f76                       tst.w   L00008d98
L00003f7c                       beq.b   L00003f8e
L00003f7e                       cmp.w   #$0002,L00008d98 
L00003f86                       bcs.b   L00003f8e 
L00003f88                       move.w  L00008f70,d0
L00003f8e                       lsr.w   #$01,d0
L00003f90                       lea.l   text_speed_value+2,a0   ; L00003f44,a0
L00003f96                       bsr.w   L00006780
L00003f9a                       lea.l   text_speed,a0           ; L00003f3a,a0
L00003fa0                       bsr.w   small_text_plotter      ; L0000410e
L00003fa4                       move.w  PANEL_ENERGY_VALUE,d0   ; $0007c88e,d0            ; panel
L00003faa                       cmp.w   #$0012,d0
L00003fae                       bcc.b   L00003fb6
L00003fb0                       move.w  d0,L00008d28
L00003fb6                       bsr.w   L00003728
L00003fba                       beq.b   L00003fd6
L00003fbc                       cmp.w   #$0081,d0
L00003fc0                       beq.w   L0000403e
L00003fc4                       cmp.w   #$0082,d0
L00003fc8                       beq.b   L0000400c
L00003fca                       cmp.w   #$001b,d0
L00003fce                       beq.b   L00004032
L00003fd0                       cmp.w   #$008a,d0
L00003fd4                       beq.b   L00003ffe 
L00003fd6                       tst.w   game_type                               ; L00008d1e (batwing = 1, batmobile = 0)
L00003fdc                       beq.w   L0000407a
L00003fe0                       move.w  L00008d24,d0
L00003fe6                       beq.w   L00003b6e
L00003fea                       lea.l   text_balloons_value+2,a0                ;  L00003f6b,a0
L00003ff0                       bsr.w   L00006780
L00003ff4                       lea.l   text_balloons,a0                        ; L00003f5e,a0
L00003ffa                       bra.w   small_text_plotter                      ; L0000410e
L00003ffe                       btst.b  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2  ; $0007c875 ; panel
L00004006                       beq.b   L00003fd6
                                ; cheat active
L00004008                       bra.w   L00003b6e

                                ; select music/sfx
L0000400c                       bchg.b  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2     ; $0007c875 ; panel
L00004014                       bne.b   L00004024
L00004016                       moveq   #$01,d0
L00004018                       pea.l   L00003fd6               
L0000401e                       jmp     AUDIO_PLAYER_INIT_SFX_1                 ; $00068f88 ; music
                                ; return (pea.l L00003fd6)

L00004024                       moveq   #$01,d0
L00004026                       pea.l   L00003fd6
L0000402c                       jmp     AUDIO_PLAYER_INIT_SONG                  ; $00068f90 ; music
                                ; return (pea.l L00003fd6)

                        ; set game over
L00004032                       bset.b  #PANEL_ST2_GAME_OVER,PANEL_STATUS_2     ; $0007c875 ; panel
L0000403a                       bra.w   L00003b18

L0000403e                       move.w  #$0001,L00008d20
L00004046                       pea.l   L0000405a
L0000404c                       move.w  game_type,d0                            ; L00008d1e,d0 (batwing = 1, batmobile = 0)
L00004052                       addq.w  #$05,d0
L00004054                       jmp     AUDIO_PLAYER_INIT_SFX_2                 ; $00068f8c ; music
L0000405a                       bsr.w   L00003728
L0000405e                       cmp.w   #$0081,d0
L00004062                       beq.b   L0000405a
L00004064                       bsr.w   L00003728
L00004068                       cmp.w   #$0081,d0
L0000406c                       bne.b   L00004064
L0000406e                       move.w  #$0000,L00008d20
L00004076                       bra.w   L00003fd6

L0000407a                       lea.l   text_distance_value+2,a0        ; L00003f57,a0
L00004080                       move.w  L00008d26,d1
L00004086                       move.w  L00008d22,d0
L0000408c                       beq.w   L00003b6e
L00004090                       sub.w   #$0006,d1
L00004094                       bmi.b   L000040a4
L00004096                       move.w  d1,L00008d26
L0000409c                       subq.w  #$01,d0
L0000409e                       move.w  d0,L00008d22
L000040a4                       bsr.w   L00006780
L000040a8                       move.b  $0000002e,(a0)+                 ; Exception Vector?
L000040ae                       move.b  d0,(a0)
L000040b0                       lea.l   text_distance,a0                ; L00003f4a,a0
L000040b6                       bsr.w   small_text_plotter              ; L0000410e
L000040ba                       move.w  L00008d30,d0
L000040c0                       mulu.w  #$0005,d0
L000040c4                       move.w  L00008d36,d1
L000040ca                       cmp.w   #$0005,d1
L000040ce                       bcc.b   L000040d2
L000040d0                       add.w   d1,d0
L000040d2                       lsl.w   #$04,d0
L000040d4                       lea.l   DATA24_OFFSET_9,a5              ; $00036fc8,a5 ; Data 2/4 - external address
L000040da                       lea.l   $02(a5,d0.w),a5
L000040de                       moveq   #$00,d3
L000040e0                       move.w  (a5)+,d4
L000040e2                       move.w  (a5)+,d5
L000040e4                       move.w  (a5)+,d7
L000040e6                       move.w  #$0090,d0
L000040ea                       moveq   #$02,d2
L000040ec                       add.w   d7,d2
L000040ee                       bsr.w   L00004e5e

L000040f2                       move.w  L00008d36,d0
L000040f8                       addq.w  #$01,d0
L000040fa                       cmp.w   #$0012,d0
L000040fe                       bcs.b   L00004102
L00004100                       moveq   #$00,d0
L00004102                       move.w  d0,L00008d36
L00004108                       rts     


                        ;--------------------- large text plotter -------------------
                        ; display text 8x16 characters (double height font)
                        ; IN:
                        ;  a0 - text message for display.
                        ;       - first two bytes of message are y,x
                        ;       - line ends with $00
                        ;       - message ends with $00,$ff
                        ;
large_text_plotter      ; original address $0000410a
L0000410a                       moveq.l  #$ffffffff,d6
L0000410c                       bra.b   L00004110


                        ;--------------------- small text plotter -------------------
                        ; display 8x8 characters (normal height font)
                        ; IN:
                        ;  a0 - text message for display.
                        ;       - first two bytes of message are y,x
                        ;       - line ends with $00
                        ;       - message ends with $00,$ff
                        ;
small_text_plotter      ; original address $0000410e
L0000410e                       moveq   #$00,d6
L00004110                       move.b  (a0)+,d0
L00004112                       bmi.w   L00004218
L00004116                       and.w   #$00ff,d0
L0000411a                       mulu.w  #$0028,d0
L0000411e                       move.b  (a0)+,d1
L00004120                       ext.w   d1
L00004122                       add.w   d1,d0
L00004124                       movea.l display_buffer2_ptr,a1          ; L000037c4,a1
L0000412a                       lea.l   $00(a1,d0.w),a1
L0000412e                       moveq   #$00,d0
L00004130                       move.b  (a0)+,d0
L00004132                       beq.b   L00004110
L00004134                       cmp.b   #$20,d0
L00004138                       beq.w   L000041b2
L0000413c                       moveq.l #$ffffffcd,d1
L0000413e                       cmp.b   #$41,d0
L00004142                       bcc.b   L00004168
L00004144                       moveq.l #$ffffffd4,d1
L00004146                       cmp.b   #$30,d0
L0000414a                       bcc.b   L00004168
L0000414c                       moveq   #$00,d1
L0000414e                       cmp.b   #$21,d0
L00004152                       beq.b   L0000416e
L00004154                       moveq   #$01,d1
L00004156                       cmp.b   #$28,d0
L0000415a                       beq.b   L0000416e
L0000415c                       moveq   #$02,d1
L0000415e                       cmp.b   #$29,d0
L00004162                       beq.b   L0000416e
L00004164                       moveq   #$03,d1
L00004166                       bra.b   L0000416e
L00004168                       add.b   d0,d1
L0000416a                       and.w   #$00ff,d1
L0000416e                       mulu.w  #$0028,d1
L00004172                       lea.l   L0000910e,a2
L00004178                       lea.l   $00(a2,d1.w),a2
L0000417c                       moveq   #$07,d7
L0000417e                       movea.l a1,a3
L00004180                       tst.w   d6
L00004182                       bmi.b   L000041ba
L00004184                       move.b  (a2)+,d1
L00004186                       and.b   d1,(a3)
L00004188                       move.b  (a2)+,d2
L0000418a                       or.b    d2,(a3)
L0000418c                       and.b   d1,$17c0(a3)
L00004190                       move.b  (a2)+,d2
L00004192                       or.b    d2,$17c0(a3)
L00004196                       and.b   d1,$2f80(a3)
L0000419a                       move.b  (a2)+,d2
L0000419c                       or.b    d2,$2f80(a3)
L000041a0                       and.b   d1,$4740(a3)
L000041a4                       move.b  (a2)+,d2
L000041a6                       or.b    d2,$4740(a3)
L000041aa                       lea.l   $0028(a3),a3
L000041ae                       dbf.w   d7,L00004184
L000041b2                       lea.l   $0001(a1),a1
L000041b6                       bra.w   L0000412e
L000041ba                       move.b  (a2)+,d1
L000041bc                       and.b   d1,(a3)
L000041be                       move.b  (a2)+,d2
L000041c0                       or.b    d2,(a3)
L000041c2                       and.b   d1,$17c0(a3)
L000041c6                       move.b  (a2)+,d2
L000041c8                       or.b    d2,$17c0(a3)
L000041cc                       and.b   d1,$2f80(a3)
L000041d0                       move.b  (a2)+,d2
L000041d2                       or.b    d2,$2f80(a3)
L000041d6                       and.b   d1,$4740(a3)
L000041da                       move.b  (a2)+,d2
L000041dc                       or.b    d2,$4740(a3)
L000041e0                       lea.l   $0028(a3),a3
L000041e4                       lea.l   -$0005(a2),a2
L000041e8                       move.b  (a2)+,d1
L000041ea                       and.b   d1,(a3)
L000041ec                       move.b  (a2)+,d2
L000041ee                       or.b    d2,(a3)
L000041f0                       and.b   d1,$17c0(a3)
L000041f4                       move.b  (a2)+,d2
L000041f6                       or.b    d2,$17c0(a3)
L000041fa                       and.b   d1,$2f80(a3)
L000041fe                       move.b  (a2)+,d2
L00004200                       or.b    d2,$2f80(a3)
L00004204                       and.b   d1,$4740(a3)
L00004208                       move.b  (a2)+,d2
L0000420a                       or.b    d2,$4740(a3)
L0000420e                       lea.l   $0028(a3),a3
L00004212                       dbf.w   d7,L000041ba
L00004216                       bra.b   L000041b2
L00004218                       rts  


                ; ----------------- maybe a psuedo random number? -----------------
                ; OUT: - D0.w = some randomish number?
L0000421a                       move.l  a0,-(a7)
L0000421c                       lea.l   L00004238,a0
L00004222                       addq.w  #$03,(a0)               ; $0d83
L00004224                       move.w  (a0)+,d0                ; d0 = $0d80
L00004226                       sub.w   #$008d,(a0)             ; $8d = 141
L0000422a                       add.w   (a0)+,d0                ; d0 = d71
L0000422c                       rol.w   #$01,d0                 ; $1ae2
L0000422e                       rol.w   (a0)
L00004230                       add.w   (a0),d0
L00004232                       move.w  d0,(a0)
L00004234                       movea.l (a7)+,a0
L00004236                       rts  

L00004238                       dc.w    $0d80
                                dc.w    $007b,$b26e






L0000423e                       dc.l    DATA24_OFFSET_17                ; $000390e2
                                dc.l    DATA24_OFFSET_19                ; $0003b732
                                dc.w    $0000,$0023
                                dc.l    L00004c22
                                
                                dc.l    DATA24_OFFSET_17                ; $000390e2
                                dc.l    DATA24_OFFSET_20                ; $0003d0a4
                                dc.w    $0000,$0023
                                dc.l    L00004c22
                                
                                dc.l    DATA24_OFFSET_17                ; $000390e2
                                dc.l    DATA24_OFFSET_21                ; $0003e462
                                dc.w    $0000,$002d
                                dc.l    L00004bda
                                
                                dc.l    DATA24_OFFSET_17                ; $000390e2
                                dc.l    DATA24_OFFSET_22                ; $00040e00
                                dc.w    $0000,$002d
                                dc.l    L00004c22
                                
                                dc.l    DATA24_OFFSET_18                ; $0003a0c2
                                dc.l    DATA24_OFFSET_19                ; $0003b732
                                dc.w    $0000,$0037
                                dc.l    L00004c22
                                
                                dc.l    DATA24_OFFSET_18                ; $0003a0c2
                                dc.l    DATA24_OFFSET_20                ; $0003d0a4
                                dc.w    $0000,$0037
                                dc.l    L00004c22
                                
                                dc.l    DATA24_OFFSET_18                ; $0003a0c2
                                dc.l    DATA24_OFFSET_21                ; $0003e462
                                dc.w    $0000,$0037
                                dc.l    L00004bda
                                
                                dc.l    DATA24_OFFSET_18                ; $0003a0c2
                                dc.l    DATA24_OFFSET_22                ; $00040e00
                                dc.w    $0000,$0037
                                dc.l    L00004c22 



                ;------------------ batwing specific ------------------
L000042be                       move.w  L00008f72,d0
L000042c4                       beq.w   L00004358
L000042c8                       sub.w   d0,L00008d2c
L000042ce                       bcc.w   L00004358
L000042d2                       bsr.w   L0000421a                       ; d0 = randomish number
L000042d6                       and.w   #$000f,d0
L000042da                       add.w   #$000a,d0
L000042de                       move.w  d0,L00008d2c
L000042e4                       bsr.w   L0000475a
L000042e8                       movea.l a6,a5
L000042ea                       pea.l   L0000435a
L000042f0                       bsr.w   L0000475a
L000042f4                       addq.l  #$04,a7
L000042f6                       bsr.w   L0000421a                       ; d0 = randomish number
L000042fa                       and.w   #$0003,d0
L000042fe                       move.b  d0,$0005(a5)
L00004302                       move.b  d0,$0005(a6)
L00004306                       lea.l   L0000478e,a0
L0000430c                       move.b  $00(a0,d0.w),d1
L00004310                       bsr.w   L0000421a                       ; d0 = randomish number
L00004314                       and.w   #$0007,d0
L00004318                       lsl.w   #$04,d0

L0000431a                       lea.l   L0000423e,a0
L00004320                       lea.l   $00(a0,d0.w),a0
L00004324                       move.l  (a0)+,$0012(a6)
L00004328                       move.b  d1,$0003(a6)
L0000432c                       move.l  #L00004362,$0016(a6)            ; handler routine address
L00004334                       move.l  a5,$0020(a6)
L00004338                       move.l  (a0)+,$0012(a5)
L0000433c                       add.w   (a0)+,d1
L0000433e                       move.b  d1,$0003(a5)
L00004342                       move.l  #L00004436,$0016(a5)            ; handler routine address
L0000434a                       move.w  (a0)+,$001c(a5)
L0000434e                       move.l  (a0),$0020(a5)
L00004352                       move.w  #$0001,$001a(a5)
L00004358                       rts 

L0000435a                       move.b #$00,$0000(a5)
L00004360                       rts  

L00004362                       move.b  $0008(a1),d0
L00004366                       beq.w   L00004434
L0000436a                       move.b  #$00,$0000(a1)
L00004370                       lea.l   L00008d5c,a6
L00004376                       tst.w   $003a(a6)
L0000437a                       bne.w   L00004434
L0000437e                       move.w  #$0005,$0032(a6)
L00004384                       move.w  #$0004,$003a(a6)
L0000438a                       moveq   #$00,d1
L0000438c                       cmp.b   #$02,d0
L00004390                       beq.b   L000043b4
L00004392                       cmp.b   #$03,d0
L00004396                       bne.b   L0000439a
L00004398                       moveq.l #$ffffffff,d1
L0000439a                       move.w  d1,$0038(a6)
L0000439e                       move.w  L00008f6e,d0
L000043a4                       ext.l   d0

L000043a6                       divu.w  #$000c,d0
L000043aa                       move.w  d0,$0036(a6)
L000043ae                       move.w  $0006(a1),d1
L000043b2                       lsr.w   #$06,d1
L000043b4                       move.w  L00008f6e,d0
L000043ba                       move.w  d0,d2
L000043bc                       ext.l   d0
L000043be                       divu.w  #$0003,d0
L000043c2                       move.w  $0006(a1),d1
L000043c6                       lsr.w   #$06,d1
L000043c8                       add.w   d1,d0
L000043ca                       move.w  d0,L00008f6e
L000043d0                       lea.l   L00008dfc,a6
L000043d6                       moveq   #$01,d6
L000043d8                       tst.w   $0000(a6)
L000043dc                       beq.b   L000043e6
L000043de                       lea.l   $0006(a6),a6
L000043e2                       dbf.w   d6,L000043d8
L000043e6                       move.w  #$0001,$0000(a6)
L000043ec                       move.w  $0010(a1),$0002(a6)
L000043f2                       move.w  $0026(a1),$0004(a6)
L000043f8                       movem.l d7/a1,-(a7)
L000043fc                       move.b  $0002(a1),d0
L00004400                       movea.l $0020(a1),a1
L00004404                       beq.b   L00004422
L00004406                       tst.b   $0000(a1)
L0000440a                       beq.b   L00004422
L0000440c                       cmp.b   $0002(a1),d0
L00004410                       bne.b   L00004422
L00004412                       bsr.b   L0000443e
L00004414                       moveq   #$0e,d0
L00004416                       pea.l   L00004422
L0000441c                       jmp     AUDIO_PLAYER_INIT_SFX_2         ; $00068f8c ; music

L00004422                       movem.l (a7)+,d7/a1
L00004426                       moveq   #$0d,d0
L00004428                       bsr.w   L00003c92
L0000442c                       moveq   #$01,d0
L0000442e                       jmp     PANEL_LOSE_ENERGY       ; panel

L00004434                       rts 




L00004436                       move.b  $0008(a1),d0
L0000443a                       bne.b   L0000443e
L0000443c                       rts  

L0000443e                       move.b  #$00,$0000(a1)
L00004444                       lea.l   L00008dc0,a6
L0000444a                       moveq   #$01,d6
L0000444c                       tst.w   $0000(a6)
L00004450                       beq.b   L0000445a
L00004452                       lea.l   $0014(a6),a6
L00004456                       dbf.w   d6,L0000444c
L0000445a                       move.w  $0010(a1),d0
L0000445e                       move.w  $0026(a1),d1
L00004462                       move.w  #$000c,$0000(a6)
L00004468                       move.w  #$0000,$0002(a6)
L0000446e                       move.w  d0,$0004(a6)
L00004472                       move.w  d1,$0006(a6)
L00004476                       add.w   #$0028,d0
L0000447a                       move.w  d0,$0008(a6)
L0000447e                       move.w  d1,$000a(a6)
L00004482                       sub.w   #$0028,d1
L00004486                       move.w  d0,$000c(a6)
L0000448a                       move.w  d1,$000e(a6)
L0000448e                       sub.w   #$0028,d0
L00004492                       move.w  d0,$0010(a6)
L00004496                       move.w  d1,$0012(a6)
L0000449a                       moveq   #$0e,d0
L0000449c                       bsr.w   L00003c92
L000044a0                       moveq   #$01,d0
L000044a2                       jmp     PANEL_LOSE_ENERGY       ; panel

L000044a8                       tst.w   L00008f64
L000044ae                       beq.w   L00004570
L000044b2                       tst.w   L00008f72
L000044b8                       beq.w   L00004570
L000044bc                       move.w  #$0000,L00008f64
L000044c4                       bsr.w   L0000475a
L000044c8                       move.b  #$00,$0005(a6)
L000044ce                       move.b  L0000478e,$0003(a6)
L000044d6                       move.l  #DATA24_OFFSET_8,$0012(a6)      ; #$0003d214,$0012(a6) ; DATA2/4 - addresses
L000044de                       move.l  #L00004572,$0016(a6)            ; addresses (routine below)
L000044e6                       move.w  #$0001,$0024(a6)
L000044ec                       bsr.w   L0000475a
L000044f0                       move.b  #$01,$0005(a6)
L000044f6                       move.b  L0000478f,$0003(a6)
L000044fe                       move.l  #DATA24_OFFSET_8,$0012(a6)      ; #$0003d214,$0012(a6) ; DATA2/4 - addresses
L00004506                       move.l  #L0000478c,$0016(a6)            ; addresses (rts)
L0000450e                       move.w  #$0001,$0024(a6)
L00004514                       move.b  #$15,$0002(a6)
L0000451a                       bsr.w   L0000475a
L0000451e                       move.b  #$02,$0005(a6)
L00004524                       move.b  L00004790,$0003(a6)
L0000452c                       move.l  #DATA24_OFFSET_8,$0012(a6)      ; #$0003d214,$0012(a6) ; DATA 2/4 - addresses
L00004534                       move.l  #L0000478c,$0016(a6)            ; addresses (rts)
L0000453c                       move.w  #$0001,$0024(a6)
L00004542                       bsr.w   L0000475a
L00004546                       move.b  #$03,$0005(a6)
L0000454c                       move.b  L00004791,$0003(a6)
L00004554                       move.l  #DATA24_OFFSET_8,$0012(a6)      ; #$0003d214,$0012(a6) ; DATA 2/4 - addresses
L0000455c                       move.l  #L0000478c,$0016(a6)            ; addresses (rts)
L00004564                       move.w  #$0001,$0024(a6)
L0000456a                       move.b  #$15,$0002(a6)
L00004570                       rts  

L00004572                       move.b  $0002(a1),d0
L00004576                       ext.w   d0
L00004578                       cmp.w   #$0004,d0
L0000457c                       bcc.b   L0000458a
L0000457e                       move.w  #$0001,L00008f66
L00004586                       moveq   #$00,d0
L00004588                       bra.b   L00004594
L0000458a                       lsl.w   #$04,d0
L0000458c                       cmp.w   L00008f6e,d0
L00004592                       bcc.b   L0000459a
L00004594                       move.w  d0,L00008f6e
L0000459a                       rts  



                ; --------------- batmobile specific update 1 ----------------
                ; 1st batmobile specific routine called from game_loop
                ;
L0000459c                       move.w  L00008f72,d0
L000045a2                       beq.w   L0000461c
L000045a6                       sub.w   d0,L00008d2c
L000045ac                       bcc.w   L0000461c
L000045b0                       bsr.w   L0000421a                       ; d0 = randomish number
L000045b4                       and.w   #$000f,d0
L000045b8                       add.w   L00008d2e,d0
L000045be                       move.w  d0,L00008d2c
                        ; find free object (a6)
L000045c4                       moveq   #$03,d7
                        ; search for free object struct (d7 = check 1st 4 entries)
L000045c6                       bsr.w   L0000475c                       
                        ; a6 = initialise object struct (or exit back to caller)
L000045ca                       bsr.w   L0000421a                       ; d0 = randomish number
L000045ce                       and.w   #$0003,d0
L000045d2                       move.b  d0,$0005(a6)
L000045d6                       lea.l   L0000478e,a0
L000045dc                       move.b  $00(a0,d0.w),$0003(a6)
L000045e2                       bsr.w   L0000421a                       ; d0 = randomish number
L000045e6                       and.w   #$00ff,d0
L000045ea                       add.w   #$0032,d0
L000045ee                       cmp.w   #$0096,d0
L000045f2                       bcc.w   L000045fa
L000045f6                       add.w   #$0096,d0
L000045fa                       move.w  d0,$0006(a6)
L000045fe                       bsr.w   L0000421a                       ; d0 = randomish number
L00004602                       and.w   #$0007,d0
L00004606                       lsl.w   #$02,d0
L00004608                       lea.l   L0000461e,a0
L0000460e                       move.l  $00(a0,d0.w),$0012(a6)
L00004614                       move.l  #L0000463e,$0016(a6)
L0000461c                       rts  


                                ; address offsets
L0000461e                       dc.l    DATA24_OFFSET_11        ; $00038760  
L00004622                       dc.l    DATA24_OFFSET_16        ; $0003bbf4  
L00004626                       dc.l    DATA24_OFFSET_12        ; $00039092  
L0000462a                       dc.l    DATA24_OFFSET_13        ; $00039c26  
L0000462e                       dc.l    DATA24_OFFSET_14        ; $0003a4e0  
L00004632                       dc.l    DATA24_OFFSET_15        ; $0003b060  
L00004636                       dc.l    DATA24_OFFSET_13        ; $00039c26  
L0000463a                       dc.l    DATA24_OFFSET_14        ; $0003a4e0  


L0000463e                       bsr.w   L000046c2
L00004642                       move.b  $0008(a1),d0
L00004646                       beq.b   L000046c0
L00004648                       move.b  #$00,$0008(a1)
L0000464e                       lea.l   L00008d5c,a6
L00004654                       tst.w   $003a(a6)
L00004658                       bne.b   L000046c0
L0000465a                       move.w  #$0005,$0032(a6)
L00004660                       move.w  #$0004,$003a(a6)
L00004666                       moveq   #$00,d1
L00004668                       cmp.b   #$02,d0
L0000466c                       beq.b   L00004690
L0000466e                       cmp.b   #$03,d0
L00004672                       bne.b   L00004676
L00004674                       moveq.l #$ffffffff,d1
L00004676                       move.w  d1,$0038(a6)
L0000467a                       move.w  L00008f6e,d0
L00004680                       ext.l   d0
L00004682                       divu.w  #$000c,d0
L00004686                       move.w  d0,$0036(a6)
L0000468a                       move.w  $0006(a1),d1
L0000468e                       lsr.w   #$06,d1
L00004690                       move.w  L00008f6e,d0
L00004696                       move.w  d0,d2
L00004698                       ext.l   d0
L0000469a                       divu.w  #$0003,d0
L0000469e                       move.w  $0006(a1),d1
L000046a2                       lsr.w   #$06,d1
L000046a4                       add.w   d1,d0
L000046a6                       move.w  d0,L00008f6e
L000046ac                       add.b   #$02,$0002(a1)
L000046b2                       moveq   #$0c,d0
L000046b4                       bsr.w   L00003c92
L000046b8                       moveq   #$03,d0
L000046ba                       jmp     PANEL_LOSE_ENERGY       ; panel

L000046c0                       rts  

L000046c2                       move.b  $0005(a1),d2
L000046c6                       move.b  $0002(a1),d0
L000046ca                       moveq   #$07,d6
L000046cc                       lea.l   L00008e0e,a2
L000046d2                       cmpa.l  a1,a2
L000046d4                       beq.b   L000046fe
L000046d6                       tst.b   $0000(a2)
L000046da                       beq.b   L000046fe
L000046dc                       move.b  $0002(a2),d1
L000046e0                       sub.b   d0,d1
L000046e2                       bcs.b   L000046fe
L000046e4                       cmp.b   #$03,d1
L000046e8                       bcc.b   L000046fe
L000046ea                       tst.w   $0024(a2)
L000046ee                       beq.b   L000046f8
L000046f0                       move.w  #$0000,$0006(a1)
L000046f6                       bra.b   L000046fe
L000046f8                       cmp.b   $0005(a2),d2
L000046fc                       beq.b   L00004708
L000046fe                       lea.l   $002a(a2),a2
L00004702                       dbf.w   d6,L000046d2
L00004706                       bra.b   L0000472c
L00004708                       tst.b   d2
L0000470a                       bne.b   L00004710
L0000470c                       moveq   #$01,d2
L0000470e                       bra.b   L00004728
L00004710                       cmp.b   #$03,d2
L00004714                       bne.b   L0000471a
L00004716                       moveq   #$02,d2
L00004718                       bra.b   L00004728

L0000471a                       bsr.w   L0000421a               ; d0 = randomish number
L0000471e                       addq.b  #$01,d2
L00004720                       btst.l  #$0000,d0
L00004724                       beq.b   L00004728 
L00004726                       subq.b  #$02,d2
L00004728                       move.b  d2,$0005(a1)
L0000472c                       lea.l   L0000478e,a2
L00004732                       ext.w   d2
L00004734                       move.b  $00(a2,d2.w),d1
L00004738                       move.b  $0003(a1),d0
L0000473c                       cmp.b   d0,d1
L0000473e                       beq.b   L00004758
L00004740                       bcc.b   L0000474c
L00004742                       subq.b  #$06,d0
L00004744                       cmp.b   d0,d1
L00004746                       bcs.b   L00004754
L00004748                       move.b  d1,d0
L0000474a                       bra.b   L00004754
L0000474c                       addq.b  #$06,d0
L0000474e                       cmp.b   d0,d1
L00004750                       bcc.b   L00004754
L00004752                       move.b  d1,d0
L00004754                       move.b  d0,$0003(a1)
L00004758                       rts  

L0000475a                       moveq   #$07,d7

                        ; find unused data structure (free actor object maybe?)
                        ; if found, a6 = address ptr
                        ; if not found return to caller of the caller
                        ; IN: d7 = loop counter
L0000475c                       lea.l   L00008e0e,a6
L00004762_loop                  tst.b   $0000(a6)
L00004766                       beq.b   L00004774
L00004768                       lea.l   $002a(a6),a6            ; 42 byte data structure
L0000476c                       dbf.w   d7,L00004762_loop
L00004770                       addq.l  #$04,a7                 ; scrub off original return address
L00004772                       rts                             ; return to caller of the caller

                        ; clear 42 byte struct & initialise values
L00004774                       moveq   #$14,d7                 ; clear 21 words (42 bytes)
L00004776                       movea.l a6,a4
L00004778_loop                  move.w  #$0000,(a4)+
L0000477c                       dbf.w   d7,L00004778_loop
L00004780                       move.b  #$16,$0002(a6)
L00004786                       move.b  #$01,$0000(a6)
L0000478c                       rts 


L0000478e                       dc.b    $28
L0000478f                       dc.b    $64
L00004790                       dc.b    $a4
L00004791                       dc.b    $e2


L00004792                       LEA.L   L00008122,A0
L00004798                       MOVE.L  A0,L00008f5e
L0000479E                       MOVE.L  #$ffffffff,D0
L000047A0                       MOVE.W  D0,(A0)
L000047A2                       ADDA.W  #$00000006,A0
L000047A4                       MOVE.W  D0,(A0)
L000047A6                       ADDA.W  #$00000006,A0
L000047A8                       MOVE.W  D0,(A0)
L000047AA                       ADDA.W  #$00000006,A0
L000047AC                       MOVE.W  D0,(A0)
L000047AE                       ADDA.W  #$00000006,A0
L000047B0                       MOVE.W  D0,(A0)
L000047B2                       ADDA.W  #$00000006,A0
L000047B4                       MOVE.W  D0,(A0)
L000047B6                       ADDA.W  #$00000006,A0
L000047B8                       MOVE.W  D0,(A0)
L000047BA                       ADDA.W  #$00000006,A0
L000047BC                       MOVE.W  D0,(A0)
L000047BE                       ADDA.W  #$00000006,A0
L000047C0                       MOVE.W  D0,(A0)

L000047c2                       lea.l   L0000909e,a0
L000047c8                       lea.l   L00008e0e,a1
L000047ce                       moveq   #$07,d7
L000047d0                       tst.b   $0000(a1)
L000047d4                       bne.b   L000047e0
L000047d6                       lea.l   $002a(a1),a1
L000047da                       dbf.w   d7,L000047d0
L000047de                       rts 

L000047e0                       moveq   #$00,d1
L000047e2                       move.w  d1,d0
L000047e4                       move.b  $0004(a1),d0
L000047e8                       move.b  $0006(a1),d1
L000047ec                       sub.b   $0007(a1),d0
L000047f0                       bcc.b   L000047f6
L000047f2                       add.b   #$01,d1
L000047f6                       add.b   $0002(a1),d1
L000047fa                       tst.b   $0001(a1)
L000047fe                       bne.b   L0000480e
L00004800                       cmp.b   #$18,d1
L00004804                       bcs.b   L00004824
L00004806                       move.b  #$00,$0000(a1)
L0000480c                       bra.b   L000047d6
L0000480e                       tst.b   d1
L00004810                       ble.b   L00004824
L00004812                       cmp.b   #$02,d1
L00004816                       bcs.b   L0000481e
L00004818                       cmp.b   #$be,d0
L0000481c                       bcc.b   L00004824
L0000481e                       move.b  #$be,d0
L00004822                       moveq   #$01,d1
L00004824                       move.b  d1,$0002(a1)
L00004828                       move.b  d0,$0004(a1)
L0000482c                       cmp.b   #$14,d1
L00004830                       bcc.w   L00004a2c
L00004834                       tst.b   d1
L00004836                       bne.b   L00004858
L00004838                       move.w  L00009078,d2
L0000483e                       and.b   #$e0,d2
L00004842                       not.b   d2
L00004844                       cmp.b   d0,d2
L00004846                       bcc.b   L00004858
L00004848                       tst.b   $0001(a1)
L0000484c                       bne.b   L000047d6
L0000484e                       move.b  #$00,$0000(a1)
L00004854                       bra.w   L000047d6

L00004858                       move.b  $5b(a0,d1.w),d0
L0000485c                       move.b  d0,d2
L0000485e                       sub.b   $5a(a0,d1.w),d0
L00004862                       move.b  $0004(a1),d1
L00004866                       mulu.w  d1,d0
L00004868                       lsr.w   #$08,d0
L0000486a                       move.w  d0,$000a(a1)
L0000486e                       sub.b   d0,d2
L00004870                       add.b   d2,d2
L00004872                       and.w   #$00ff,d2
L00004876                       lea.l   L00007bc8,a2
L0000487c                       lea.l   $00(a2,d2.w),a2
L00004880                       move.w  $0400(a2),d0
L00004884                       move.w  (a2),d1
L00004886                       sub.w   d1,d0
L00004888                       moveq   #$00,d2
L0000488a                       move.b  $0003(a1),d2
L0000488e                       mulu.w  d2,d0
L00004890                       lsr.l   #$08,d0
L00004892                       add.w   d1,d0
L00004894                       move.b  $0002(a1),d2
L00004898                       move.w  d2,d3
L0000489a                       lsr.b   #$02,d2
L0000489c                       add.w   d2,d0
L0000489e                       lsr.w   #$01,d3
L000048a0                       cmp.w   #$0007,d3
L000048a4                       bcs.b   L000048a8
L000048a6                       moveq   #$07,d3
L000048a8                       asl.w   #$04,d3
L000048aa                       movea.l $0012(a1),a2
L000048ae                       lea.l   $00(a2,d3.w),a2
L000048b2                       move.w  (a2),d3
L000048b4                       move.w  d3,$000c(a1)
L000048b8                       move.w  $0006(a2),$000e(a1)
L000048be                       move.w  d0,d6
L000048c0                       lsr.w   #$01,d3
L000048c2                       sub.w   d3,d0
L000048c4                       move.w  d0,$0010(a1)
L000048c8                       tst.w   $0028(a1)
L000048cc                       beq.b   L000048e4
L000048ce                       addq.w  #$06,$001c(a1)
L000048d2                       cmp.w   #$0050,$001c(a1)
L000048d8                       bcs.b   L000048ea
L000048da                       move.b  #$00,$0000(a1)
L000048e0                       bra.w   L000047d6

L000048e4                       tst.w   $001a(a1)
L000048e8                       beq.b   L00004910
L000048ea                       move.w  L00009078,d1
L000048f0                       and.w   #$00e0,d1
L000048f4                       add.b   $0002(a1),d1

L000048f8                       lea.l   L00007821,a2
L000048fe                       move.b  $00(a2,d1.w),d1
L00004902                       mulu.w  $001c(a1),d1
L00004906                       lsr.w   #$05,d1
L00004908                       add.w   $000a(a1),d1
L0000490c                       move.w  d1,$001e(a1)
L00004910                       move.b  $0002(a1),d1
L00004914                       cmp.b   #$02,d1
L00004918                       bcc.w   L000049f0
L0000491c                       ext.w   d1
L0000491e                       move.b  $01(a0,d1.w),d2
L00004922                       and.w   #$00ff,d2
L00004926                       add.w   #$0038,d2
L0000492a                       add.w   $000a(a1),d2
L0000492e                       move.w  d2,$0026(a1)
L00004932                       lea.l   L00008d5c,a2
L00004938                       move.w  $0010(a2),d3
L0000493c                       add.w   $002c(a2),d3
L00004940                       move.w  d3,d4
L00004942                       sub.w   $002a(a2),d4
L00004946                       tst.w   $001a(a1)
L0000494a                       beq.b   L000049aa
L0000494c                       cmp.w   d4,d2
L0000494e                       bcs.b   L000049aa
L00004950                       move.w  d2,d5
L00004952                       sub.w   $001e(a1),d5
L00004956                       move.w  d5,$0026(a1)
L0000495a                       bmi.b   L00004960
L0000495c                       cmp.w   d3,d5
L0000495e                       bcc.b   L000049aa
L00004960                       tst.b   d1
L00004962                       beq.b   L0000496c
L00004964                       tst.b   L00009079
L0000496a                       bpl.b   L000049aa
L0000496c                       sub.w   #$0008,d6
L00004970                       cmp.w   $0030(a2),d6
L00004974                       bcc.b   L000049aa
L00004976                       add.w   #$0010,d6
L0000497a                       cmp.w   $002e(a2),d6
L0000497e                       bcs.b   L000049aa
L00004980                       move.w  #$0000,$001a(a1)
L00004986                       move.w  #$0001,$0028(a1)
L0000498c                       subq.w  #$01,L00008d24
L00004992                       moveq   #$0f,d0
L00004994                       bsr.w   L00003c92
L00004998                       move.l  #$00000200,d0
L0000499e                       pea.l   L000049aa
L000049a4                       jmp     PANEL_ADD_SCORE            ; panel
                                ; return here (pea.l L000049aa)
L000049aa                       sub.w   $001e(a1),d2
L000049ae                       bmi.b   L000049f0
L000049b0                       tst.w   $0028(a1)
L000049b4                       bne.b   L000049f0
L000049b6                       cmp.w   d4,d2
L000049b8                       bcs.b   L000049f0
L000049ba                       sub.w   $000e(a1),d2
L000049be                       bmi.b   L000049c4
L000049c0                       cmp.w   d3,d2
L000049c2                       bcc.b   L000049f0
L000049c4                       cmp.w   $0030(a2),d0
L000049c8                       bcc.b   L000049f0
L000049ca                       move.w  $000c(a1),d2
L000049ce                       add.w   d2,d0
L000049d0                       cmp.w   $002e(a2),d0
L000049d4                       bcs.b   L000049f0
L000049d6                       lsr.w   #$01,d2
L000049d8                       sub.w   d2,d0
L000049da                       moveq   #$03,d1
L000049dc                       cmp.w   #$00b9,d0
L000049e0                       bcc.b   L000049ec
L000049e2                       moveq   #$02,d1
L000049e4                       cmp.w   #$0087,d0
L000049e8                       bcc.b   L000049ec

L000049ea                       moveq   #$01,d1
L000049ec                       move.b  d1,$0008(a1)
L000049f0                       move.b  $0002(a1),d0
L000049f4                       lsl.w   #$08,d0
L000049f6                       move.b  $0004(a1),d0
L000049fa                       not.b   d0
L000049fc                       lea.l   L00008122,a2
L00004a02                       moveq   #$07,d6
L00004a04                       move.w  (a2),d1
L00004a06                       bmi.b   L00004a28
L00004a08                       cmp.w   d0,d1
L00004a0a                       bcs.b   L00004a12
L00004a0c                       addq.l  #$06,a2
L00004a0e                       subq.w  #$01,d6
L00004a10                       bra.b   L00004a04
L00004a12                       subq.w  #$01,d6
L00004a14                       bmi.b   L00004a28
L00004a16                       lea.l   L00008152,a3
L00004a1c                       lea.l   -$0006(a3),a2
L00004a20                       move.l  -(a2),-(a3)
L00004a22                       move.w  -(a2),-(a3)
L00004a24                       dbf.w   d6,L00004a20
L00004a28                       move.w  d0,(a2)+
L00004a2a                       move.l  a1,(a2)
L00004a2c                       movea.l $0016(a1),a2
L00004a30                       pea.l   L000047d6
L00004a36                       jmp     (a2)


L00004a38                       movea.l L00008f5e,a4
L00004a3e                       cmp.b   (a4),d7
L00004a40                       beq.b   L00004a44
L00004a42                       rts  

L00004a44                       movea.l $0002(a4),a6
L00004a48                       addq.l  #$06,L00008f5e
L00004a4e                       movea.l $0012(a6),a5
L00004a52                       lea.l   $00(a5,d5.w),a5
L00004a56                       move.w  (a5)+,d1
L00004a58                       move.w  $0010(a6),d0                    ; bus error exception
L00004a5c                       bmi.b   L00004a68
L00004a5e                       cmp.w   #$0140,d0
L00004a62                       bcs.b   L00004a72
L00004a64                       bra.w   L00004a38

L00004a68                       add.w   d0,d1
L00004a6a                       bmi.b   L00004a38
L00004a6c                       cmp.w   #$0000,d1
L00004a70                       bcs.b   L00004a38
L00004a72                       tst.w   $001a(a6)
L00004a76                       bne.b   L00004a8e
L00004a78                       movem.l d5-d7/a0-a3,-(a7)
L00004a7c                       move.w  $000a(a6),d6
L00004a80                       sub.w   $001e(a6),d6
L00004a84                       bsr.w   L00004e0a
L00004a88                       movem.l (a7)+,d5-d7/a0-a3
L00004a8c                       bra.b   L00004a38

L00004a8e                       movem.l d0-d7/a0-a6,-(a7)
L00004a92                       movea.l $0020(a6),a5
L00004a96                       lsr.w   #$01,d5
L00004a98                       lea.l   $00(a5,d5.w),a5
L00004a9c                       lea.l   L00004c6a,a4
L00004aa2                       lea.l   $00(a4,d5.w),a4
L00004aa6                       add.w   (a5),d0
L00004aa8                       bmi.w   L00004b90
L00004aac                       cmp.w   #$0130,d0
L00004ab0                       bcc.w   L00004b90
L00004ab4                       move.w  $000a(a6),d6
L00004ab8                       move.w  $0002(a5),d7
L00004abc                       beq.w   L00004b90
L00004ac0                       add.w   d7,d6
L00004ac2                       add.w   $0004(a5),d7
L00004ac6                       add.w   $001e(a6),d7
L00004aca                       moveq   #$00,d2
L00004acc                       move.w  d2,d1
L00004ace                       move.b  (a1),d1
L00004ad0                       move.b  $0043(a1),d2
L00004ad4                       sub.w   d2,d1
L00004ad6                       bne.b   L00004aea
L00004ad8                       add.w   d6,d2
L00004ada                       bmi.w   L00004b90
L00004ade                       move.w  d2,d1
L00004ae0                       addq.w  #$01,d1
L00004ae2                       sub.w   d7,d1
L00004ae4                       bcc.b   L00004b06
L00004ae6                       add.w   d1,d7
L00004ae8                       bra.b   L00004b06

L00004aea                       tst.w   d6
L00004aec                       bmi.b   L00004af2
L00004aee                       sub.w   d6,d1
L00004af0                       bra.b   L00004af4

L00004af2                       add.w   d6,d1
L00004af4                       move.w  d1,d6
L00004af6                       beq.b   L00004ad8
L00004af8                       bmi.b   L00004ad8
L00004afa                       subq.w  #$01,d7
L00004afc                       sub.w   d6,d7
L00004afe                       bcs.w   L00004b90
L00004b02                       addq.w  #$01,d7
L00004b04                       bra.b   L00004ade

L00004b06                       movea.l display_buffer2_ptr,a0          ; L000037c4,a0
L00004b0c                       addq.w  #$01,d2
L00004b0e                       sub.w   d7,d2
L00004b10                       move.w  d2,d4
L00004b12                       lsl.w   #$02,d2
L00004b14                       add.w   d4,d2
L00004b16                       lsl.w   #$03,d2
L00004b18                       move.w  d0,d4
L00004b1a                       lsr.w   #$03,d0
L00004b1c                       bclr.l  #$0000,d0
L00004b20                       add.w   d2,d0
L00004b22                       lea.l   $00(a0,d0.w),a0
L00004b26                       and.w   #$000f,d4
L00004b2a                       move.w  (a4)+,d0
L00004b2c                       moveq.l #$ffffffff,d1
L00004b2e                       move.w  (a4)+,d1
L00004b30                       swap.w  d1
L00004b32                       movea.l (a4),a4
L00004b34                       subq.w  #$01,d4
L00004b36                       bmi.b   L00004b42
L00004b38                       ror.l   #$01,d1

L00004b3a                       lea.l   $0140(a4),a4
L00004b3e                       dbf.w   d4,L00004b38
L00004b42                       subq.w  #$01,d7
L00004b44                       lea.l   $17c0(a0),a1
L00004b48                       lea.l   $17c0(a1),a2
L00004b4c                       lea.l   $17c0(a2),a3
L00004b50                       moveq   #$00,d2
L00004b52                       tst.w   d0
L00004b54                       bmi.b   L00004b98
L00004b56                       and.l   d1,(a0)
L00004b58                       move.l  $00(a4,d2.w),d3
L00004b5c                       or.l    d3,(a0)
L00004b5e                       and.l   d1,(a1)
L00004b60                       move.l  $04(a4,d2.w),d3
L00004b64                       or.l    d3,(a1)
L00004b66                       and.l   d1,(a2)
L00004b68                       move.l  $08(a4,d2.w),d3
L00004b6c                       or.l    d3,(a2)
L00004b6e                       and.l   d1,(a3)
L00004b70                       move.l  $0c(a4,d2.w),d3
L00004b74                       or.l    d3,(a3)
L00004b76                       lea.l   $0028(a0),a0
L00004b7a                       lea.l   $0028(a1),a1
L00004b7e                       lea.l   $0028(a2),a2
L00004b82                       lea.l   $0028(a3),a3
L00004b86                       add.w   #$0010,d2
L00004b8a                       and.w   d0,d2
L00004b8c                       dbf.w   d7,L00004b56
L00004b90                       movem.l (a7)+,d0-d7/a0-a6
L00004b94                       bra.w   L00004a78

L00004b98                       and.l   d1,(a0)
L00004b9a                       move.l  $00(a4,d2.w),d3
L00004b9e                       or.l    d3,(a0)
L00004ba0                       and.l   d1,(a1)
L00004ba2                       move.l  $04(a4,d2.w),d3
L00004ba6                       or.l    d3,(a1)
L00004ba8                       and.l   d1,(a2)
L00004baa                       move.l  $08(a4,d2.w),d3
L00004bae                       or.l    d3,(a2)
L00004bb0                       and.l   d1,(a3)
L00004bb2                       move.l  $0c(a4,d2.w),d3
L00004bb6                       or.l    d3,(a3)
L00004bb8                       lea.l   $0028(a0),a0
L00004bbc                       lea.l   $0028(a1),a1
L00004bc0                       lea.l   $0028(a2),a2
L00004bc4                       lea.l   $0028(a3),a3
L00004bc8                       add.w   #$0010,d2
L00004bcc                       cmp.w   #$0030,d2
L00004bd0                       bne.b   L00004bd4
L00004bd2                       moveq   #$00,d2
L00004bd4                       dbf.w   d7,L00004b98
L00004bd8                       bra.b   L00004b90



L00004bda                       dc.w    $0032,$ffdc,$000a,$0000,$0021,$ffe4,$0008,$0000
L00004bea                       dc.w    $0018,$ffea,$0006,$0000,$0013,$ffee,$0004,$0000
L00004bfa                       dc.w    $0011,$fff2,$0002,$0000,$000e,$fff4,$0002,$0000
L00004c0a                       dc.w    $000c,$fff6,$0002,$0000,$000b,$fff8,$0002,$0000
L00004c1a                       dc.w    $000b,$fffa,$0002,$0000

L00004c22                       dc.w    $001d,$ffdc,$000a,$0000
L00004c2a                       dc.w    $0013,$ffe4,$0008,$0000,$000e,$ffea,$0006,$0000
L00004c3a                       dc.w    $000b,$ffee,$0004,$0000,$0009,$fff2,$0002,$0000
L00004c4a                       dc.w    $0008,$fff4,$0002,$0000,$0007,$fff6,$0002,$0000
L00004c5a                       dc.w    $0006,$fff8,$0002,$0000,$0006,$fffa,$0002,$0000

                                ; word, word, long (address)
L00004c6a                       dc.w    $0030,$07ff
                                dc.l    DATA24_OFFSET_23                ; $00037ce2
                                dc.w    $ffff,$07ff
                                dc.l    DATA24_OFFSET_24                ; $00037d22
                                dc.w    $ffff,$0fff
                                dc.l    DATA24_OFFSET_25                ; $00037d52
                                dc.w    $0010,$0fff
                                dc.l    DATA24_OFFSET_26                ; $00037d82
                                dc.w    $0010,$1fff
                                dc.l    DATA24_OFFSET_27                ; $00037da2
                                dc.w    $0010,$3fff
                                dc.l    DATA24_OFFSET_28                ; $00037dc2
                                dc.w    $0000,$3fff
                                dc.l    DATA24_OFFSET_31                ; $00037de2
                                dc.w    $0010,$7fff
                                dc.l    DATA24_OFFSET_29                ; $00037df2
                                dc.w    $0000,$7fff
                                dc.l    DATA24_OFFSET_30                ; $00037e12 



L00004cb2                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0)
L00004cb8                       beq.b   L00004cbe
L00004cba                       bsr.w   L00005f5a
L00004cbe                       lea.l   L0000909f,a0
L00004cc4                       lea.l   L000090e2,a1
L00004cca                       move.w  #$0014,d7
L00004cce                       move.w  #$0038,d0
L00004cd2                       add.b   d0,(a0)+
L00004cd4                       add.b   d0,(a1)+
L00004cd6                       dbf.w   d7,L00004cd2
L00004cda                       lea.l   L00008116,a0
L00004ce0                       lea.l   L000090b2,a1
L00004ce6                       lea.l   current_road_section_256_bytes,a2   ; L00008f74,a2
L00004cec                       lea.l   L00007a20,a3
L00004cf2                       move.w  L00009078,d0
L00004cf8                       and.w   #$00e0,d0
L00004cfc                       lea.l   $00(a3,d0.w),a3
L00004d00                       move.w  L00009076,d6
L00004d06                       add.b   #$53,d6
L00004d0a                       move.w  #$0013,d7
L00004d0e                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0)
L00004d14                       beq.w   L00005c88
L00004d18                       move.w  d7,d5
L00004d1a                       lsr.w   #$01,d5
L00004d1c                       cmp.w   #$0008,d5
L00004d20                       bcs.b   L00004d24
L00004d22                       moveq   #$08,d5
L00004d24                       asl.w   #$04,d5
L00004d26                       bsr.w   L00004a38
L00004d2a                       move.b  $00(a2,d6.w),d0
L00004d2e                       bne.b   L00004d56
L00004d30                       add.b   #$20,d6
L00004d34                       subq.w  #$02,a0
L00004d36                       move.b  $00(a2,d6.w),d0
L00004d3a                       bne.b   L00004da8
L00004d3c                       sub.b   #$21,d6
L00004d40                       subq.w  #$02,a0
L00004d42                       subq.w  #$01,a1
L00004d44                       dbf.w   d7,L00004d0e

L00004d48                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0)
L00004d4e                       beq.w   L00005c9c
L00004d52                       bra.w   L00005f92
L00004d56                       lsl.w   #$04,d0                 ; 4 byte structure?
L00004d58                       and.w   #$00f0,d0
L00004d5c                       lea.l   L00008bae,a4            ; direct reference to game init data?
L00004d62                       movea.l $00(a4,d0.w),a5         ; display object data struct (sprite/bob)
L00004d66                       move.b  $04(a4,d0.w),d1
L00004d6a                       move.b  $05(a4,d0.w),d2
L00004d6e                       move.b  $00(a3,d7.w),d0
L00004d72                       ext.w   d0
L00004d74                       ext.w   d1
L00004d76                       mulu.w  d1,d0
L00004d78                       ext.w   d2
L00004d7a                       beq.b   L00004d7e
L00004d7c                       divu.w  d2,d0
L00004d7e                       add.w   (a0),d0
L00004d80                       lea.l   $00(a5,d5.w),a5
L00004d84                       move.w  (a5)+,d1
L00004d86                       tst.w   d0
L00004d88                       bmi.b   L00004d92
L00004d8a                       cmp.w   #$0130,d0
L00004d8e                       bcs.b   L00004d9c
L00004d90                       bra.b   L00004d30
L00004d92                       add.w   d0,d1
L00004d94                       bmi.b   L00004d30
L00004d96                       cmp.w   #$fff0,d0
L00004d9a                       bcs.b   L00004d30
L00004d9c                       movem.l d5-d7/a0-a3,-(a7)
L00004da0                       bsr.b   L00004e08
L00004da2                       movem.l (a7)+,d5-d7/a0-a3
L00004da6                       bra.b   L00004d30

L00004da8                       lsl.w   #$04,d0
L00004daa                       and.w   #$00f0,d0
L00004dae                       lea.l   L00008c5e,a4
L00004db4                       movea.l $00(a4,d0.w),a5         ; display object data struct (sprite/bob)
L00004db8                       move.b  $04(a4,d0.w),d1
L00004dbc                       move.b  $05(a4,d0.w),d2
L00004dc0                       move.b  $00(a3,d7.w),d0
L00004dc4                       ext.w   d0
L00004dc6                       ext.w   d1
L00004dc8                       mulu.w  d1,d0
L00004dca                       ext.w   d2
L00004dcc                       beq.b   L00004dd0
L00004dce                       divu.w  d2,d0
L00004dd0                       neg.w   d0
L00004dd2                       add.w   #$000a,d0
L00004dd6                       add.w   (a0),d0
L00004dd8                       lea.l   $00(a5,d5.w),a5
L00004ddc                       move.w  (a5)+,d1
L00004dde                       sub.w   d1,d0
L00004de0                       bmi.b   L00004dec
L00004de2                       cmp.w   #$0130,d0
L00004de6                       bcs.b   L00004dfa
L00004de8                       bra.w   L00004d3c
L00004dec                       add.w   d0,d1
L00004dee                       bmi.w   L00004d3c
L00004df2                       cmp.w   #$0000,d1
L00004df6                       bcs.w   L00004d3c
L00004dfa                       movem.l d5-d7/a0-a3,-(a7)
L00004dfe                       bsr.b   L00004e08
L00004e00                       movem.l (a7)+,d5-d7/a0-a3
L00004e04                       bra.w   L00004d3c

                                ; a1 = object data (x,y, sprite id etc)
                                ; a5 = bob sprite object data
L00004e08                       moveq   #$00,d6
L00004e0a                       move.w  (a5)+,d4
L00004e0c                       move.w  (a5)+,d5                ; width?
L00004e0e                       move.w  (a5)+,d7                ; height

L00004e10                       moveq   #$00,d3
L00004e12                       move.w  d3,d2
L00004e14                       move.w  d3,d1                   ; d1,d2,d3 = $0.l

L00004e16                       move.b  (a1),d1
L00004e18                       move.b  $0043(a1),d2
L00004e1c                       sub.w   d2,d1
L00004e1e                       bne.b   L00004e3c
L00004e20                       add.w   d6,d2
L00004e22                       bmi.b   L00004e3a
L00004e24                       move.w  d2,d1
L00004e26                       addq.w  #$01,d1
L00004e28                       sub.w   d7,d1
L00004e2a                       bcc.b   L00004e5e
L00004e2c                       add.w   d1,d7
L00004e2e                       neg.w   d1
L00004e30                       subq.w  #$01,d1
L00004e32                       add.w   d5,d3
L00004e34                       dbf.w   d1,L00004e32
L00004e38                       bra.b   L00004e5e
L00004e3a                       rts  

L00004e3c                       tst.w   d6
L00004e3e                       bmi.b   L00004e44
L00004e40                       sub.w   d6,d1
L00004e42                       bra.b   L00004e46

L00004e44                       add.w   d6,d1
L00004e46                       move.w  d1,d6
L00004e48                       beq.b   L00004e20
L00004e4a                       bmi.b   L00004e20
L00004e4c                       subq.w  #$01,d7                 ; d7 = blit height
L00004e4e                       sub.w   d6,d7
L00004e50                       bcs.b   L00004e3a
L00004e52                       addq.w  #$01,d7
L00004e54                       bra.b   L00004e24

                                ; select blit routine 2
L00004e56                       lea.l   L00004fcc,a6                    ; select blit routine
L00004e5c                       bra.b   L00004e64

                                ; select blit routine 1
L00004e5e                       lea.l   L00004ec0,a6                    ; select blit routine
L00004e64                       move.w  d0,d1                           ; d0,d1 = x
L00004e66                       asr.w   #$04,d1                         ; divide by 16
L00004e68                       bmi.b   L00004e86
L00004e6a                       cmp.w   #$0000,d1
L00004e6e                       bcs.b   L00004e86
L00004e70                       moveq   #$00,d6
L00004e72                       add.w   d4,d1                           ; add offset to x value
L00004e74                       sub.w   #$0014,d1                       ; sub 20 from x (word offset) - mid screen? (20 bytes)
L00004e78                       bcs.b   L00004e82
                                ; d1 >= 20
L00004e7a                       sub.w   d4,d1
L00004e7c                       neg.w   d1
L00004e7e                       not.w   d6
L00004e80                       bra.b   L00004e9a

                                ; d1 < 20
L00004e82                       move.w  d4,d1
L00004e84                       bra.b   L00004e9a

                                ; clip left? 0 or -ve x value?
L00004e86                       add.w   d4,d1
L00004e88                       sub.w   #$0000,d1                       ; d1 = blit width
L00004e8c                       move.w  d1,d6
L00004e8e                       neg.w   d6
L00004e90                       add.w   d4,d6

L00004e92                       and.w   #$000f,d0
L00004e96                       or.w    #$0000,d0

L00004e9a                       movea.l display_buffer2_ptr,a0          ; L000037c4,a0
L00004ea0                       addq.w  #$01,d2
L00004ea2                       sub.w   d7,d2                           ; d7 = blit height


                                ; d2 = y value stored as byte
                                ; multiply d2 by 40 (screen width)
L00004ea4                       move.w  d2,d4
L00004ea6                       lsl.w   #$02,d2                         ; multiply by 4
L00004ea8                       add.w   d4,d2                           ; d2 = multiplied by 5
L00004eaa                       lsl.w   #$03,d2                         ; further multiply by 8 (5*8 = 40)

                                ; d0 = x value stored as byte (2 pixel resolution)
L00004eac                       move.w  d0,d4
L00004eae                       lsr.w   #$03,d0                         ; divide by 8 (x value stored as byte?)
L00004eb0                       bclr.l  #$0000,d0                       ; make even (word offset)
L00004eb4                       add.w   d2,d0                           ; add Y (d2) to X (d0)
L00004eb6                       lea.l   $00(a0,d0.w),a0                 ; a0 = playfield dest ptr
L00004eba                       and.w   #$000f,d4

L00004ebe                       jmp     (a6)                            ; Blit the GFX - $4fcc or 4ec0


                                ; ------------- blit routine 1 ---------------
                                ; d0 
                                ; d3 = ?????
                                ; d4 = shift/scroll value
                                ; d6 = ????? - maybe x pixel value/byte offset?
                                ; d7 = Blit Height
L00004ec0                       move.w  #$0000,CUSTOM+BLTALWM           ; $00dff046 - Blitter Last Word Mask
L00004ec8                       move.w  #$ffff,CUSTOM+BLTAFWM           ; $00dff044 - Blitter First Word Mask

L00004ed0                       lsl.w   #$01,d6
L00004ed2                       beq.b   L00004f06_do_blit               ; no shift, do blit.
L00004ed4                       bmi.b   L00004ef2

                        
                                ; set first word mask (and something to d3)
L00004ed6                       add.w   d6,d3                           ; source gfx x offset (bytes)
L00004ed8                       move.w  d4,d6                           ; d4,d6 = 0-15 shift value
L00004eda                       lsl.w   #$01,d6
L00004edc                       lea.l   blitter_first_word_masks,a1     ; L00004fac,a1
L00004ee2                       move.w  $00(a1,d6.w),CUSTOM+BLTAFWM     ; $00dff044 - Blitter First Word Mask based on shift value

                                ; if shift to left then blit starts 16 pixels further left?
L00004eea                       subq.w  #$02,a0                         ; decrement playfield dest ptr (16 pixels)
L00004eec                       subq.w  #$02,d3                         ; source gfx x offset (bytes)
L00004eee                       addq.w  #$01,d1                         ; increase blit width (16 pixels)
L00004ef0                       bra.b   L00004f06_do_blit


                                ; set last word mask 
L00004ef2                       move.w  d4,d6
L00004ef4                       lsl.w   #$01,d6
L00004ef6                       lea.l   blitter_last_word_masks,a1      ; L00004f8c,a1
L00004efc                       move.w  $00(a1,d6.w),CUSTOM+BLTALWM     ; $00dff046 - Blitter Last Word Mask based on shift value

L00004f04                       subq.w  #$01,d1                         ; descrease blit width

                                ; Cookie Cutter Blit Minterm $CA
                                ;  - A = Mask
                                ;  - B = GFX
                                ;  - C = Background
                                ;  - D = Background (dest)
                                ; d3 = source offset gfx data (clip value top-left offset to add)
                                ; d4 = GFX shift value 0-15
                                ; d5 = sprite width (unclipped bytes)
                                ; d7 = blit height
                                ; a5 = bob struct
L00004f06_do_blit               move.l  (a5),d0                         ; d0 = offset to start of GFX Data (from current ptr)
L00004f08                       lea.l   $00(a5,d0.l),a4                 ; a4 = Start of GFX Data
L00004f0c                       lea.l   $00(a4,d3.w),a4                 ; a4 = Source Mask GFX Data (top left)

                                ; get sprite per/bitplane size
L00004f10                       move.l  $0004(a5),d3                    ; d3 = mask size/per bitplane size

L00004f14                       lsl.w   #$06,d7                         ; d7 = blit height in words
L00004f16                       addq.w  #$01,d1                         ; d1 = increase blit width (words)
L00004f18                       move.w  d1,d2
L00004f1a                       or.w    d7,d1                           ; d1 = blitsize value

                                ; set A/B SRC shift and MINTERMS 
L00004f1c                       ror.w   #$04,d4                         ; d4 = blit Shift Values (into high 4 bits)
L00004f1e                       move.w  d4,CUSTOM+BLTCON1               ; $00dff042
L00004f24                       or.w    #$0fca,d4                       ; MINTERMS $CA = Cookie Cutter (use A,B,C,D channels)
L00004f28                       move.w  d4,CUSTOM+BLTCON0               ; $00dff040

                                ; calc dest modulo based on 'clipped sprite' width
L00004f2e                       lsl.w   #$01,d2                         ; convert 'clipped sprite' blit width to bytes (*2)
L00004f30                       sub.w   d2,d5                           ; sprite width (bytes)
L00004f32                       not.w   d2
L00004f34                       add.w   #$0029,d2                       ; add 41 to playfield modulo (modulo ignores odd values?)

                                ; keep a4 as mask ptr, a1 = src bitplane ptr
L00004f38                       movea.l a4,a1                           ; a1,a4 = ptr to sprite GFX (starts with mask)

                                ; set up blit params
L00004f3a                       move.w  d5,CUSTOM+BLTAMOD               ; $00dff064 - Mask Modulo
L00004f40                       move.w  d5,CUSTOM+BLTBMOD               ; $00dff062 - Gfx Modulo
L00004f46                       move.w  d2,CUSTOM+BLTCMOD               ; $00dff060 - Playfield Modulo (pf width-clipped sprite width)
L00004f4c                       move.w  d2,CUSTOM+BLTDMOD               ; $00dff066 - Playfield Modulo (pf width-clipped sprite width)

                                ; blit for each bitplane
L00004f52                       moveq   #$03,d7                         ; 3+1 bitplanes
L00004f54_blit_loop             lea.l   $00(a1,d3.l),a1                 ; a1 = Add bitplane size to a1 get source GFX data address.
L00004f58                       move.l  a4,CUSTOM+BLTAPT                ; $00dff050 - Mask Source Data
L00004f5e                       move.l  a1,CUSTOM+BLTBPT                ; $00dff04c - GFX Source Data
L00004f64                       move.l  a0,CUSTOM+BLTCPT                ; $00dff048 - Playfield Source Data
L00004f6a                       move.l  a0,CUSTOM+BLTDPT                ; $00dff054 - Playfield Dest Data
L00004f70                       move.w  d1,CUSTOM+BLTSIZE               ; $00dff058 - Start Blit

L00004f76_blit_wait             move.w  CUSTOM+DMACONR,d0               ; $00dff002,d0
L00004f7c                       btst.l  #$000e,d0
L00004f80                       bne.b   L00004f76_blit_wait

                                ; next bitplane
L00004f82                       lea.l   $17c0(a0),a0                    ; increment dest playfield bitplane
L00004f86                       dbf.w   d7,L00004f54_blit_loop
L00004f8a                       rts 


blitter_word_masks              ; original address L00004f8c
blitter_last_word_masks         ; original address L00004f8c
L00004f8c                       dc.w    $ffff,$fffe,$fffc,$fff8,$fff0,$ffe0,$ffc0 
L00004f9a                       dc.w    $ff80,$ff00,$fe00,$fc00,$f800,$f000,$e000,$c000 
L00004faa                       dc.w    $8000

blitter_first_word_masks        ; original address L00004fac
L00004fac                       dc.w    $0000,$0001,$0003,$0007,$000f,$001f,$003f 
L00004fba                       dc.w    $007f,$00ff,$01ff,$03ff,$07ff,$0fff,$1fff,$3fff
L00004fca                       dc.w    $7fff 



L00004fcc                       move.w  #$0000,$00dff046
L00004fd4                       move.w  #$ffff,$00dff044

L00004fdc                       lsl.w   #$01,d6
L00004fde                       beq.b   L00005012
L00004fe0                       bmi.b   L00004ffe
L00004fe2                       add.w   d6,d3
L00004fe4                       move.w  d4,d6
L00004fe6                       lsl.w   #$01,d6
L00004fe8                       lea.l   blitter_first_word_masks,a1             ; L00004fac,a1
L00004fee                       move.w  $00(a1,d6.w),$00dff044


L00004ff6                       subq.w  #$02,a0
L00004ff8                       subq.w  #$02,d3
L00004ffa                       addq.w  #$01,d1
L00004ffc                       bra.b   L00005012

L00004ffe                       move.w  d4,d6
L00005000                       lsl.w   #$01,d6
L00005002                       lea.l   blitter_last_word_masks,a1              ; L00004f8c,a1
L00005008                       move.w  $00(a1,d6.w),$00dff046

L00005010                       subq.w  #$01,d1


L00005012                       move.l  (a5),d0
L00005014                       lea.l   $00(a5,d0.l),a4
L00005018                       lea.l   $00(a4,d3.w),a4
L0000501c                       lsl.w   #$06,d7
L0000501e                       addq.w  #$01,d1
L00005020                       move.w  d1,d2
L00005022                       or.w    d7,d1
L00005024                       ror.w   #$04,d4
L00005026                       move.w  #$0000,$00dff042
L0000502e                       or.w    #$0b0a,d4
L00005032                       move.w  d4,$00dff040
L00005038                       lsl.w   #$01,d2
L0000503a                       sub.w   d2,d5
L0000503c                       not.w   d2
L0000503e                       add.w   #$0029,d2
L00005042                       movea.l a4,a1
L00005044                       move.w  d5,$00dff064
L0000504a                       move.w  d2,$00dff060
L00005050                       move.w  d2,$00dff066
L00005056                       moveq   #$03,d7
L00005058                       move.l  a4,$00dff050
L0000505e                       move.l  a0,$00dff048
L00005064                       move.l  a0,$00dff054
L0000506a                       move.w  d1,$00dff058
L00005070                       move.w  $00dff002,d0
L00005076                       btst.l  #$000e,d0
L0000507a                       bne.b   L00005070
L0000507c                       lea.l   $17c0(a0),a0
L00005080                       dbf.w   d7,L00005058
L00005084                       rts  

L00005086                       lea.l   L000080c8,a0
L0000508c                       lea.l   L00008d5c,a1
L00005092                       tst.w   $003a(a1)
L00005096                       bne.w   L000051d8
L0000509a                       moveq   #$00,d1
L0000509c                       move.w  (a0)+,d0
L0000509e                       bmi.b   L000050c2
L000050a0                       move.w  $002e(a1),d3
L000050a4                       addq.w  #$05,d3
L000050a6                       cmp.w   d3,d0
L000050a8                       bcs.b   L000050c2
L000050aa                       moveq   #$00,d6
L000050ac                       moveq   #$60,d2
L000050ae                       lea.l   L00008c5e,a3
L000050b4                       moveq   #$01,d1
L000050b6                       add.w   #$0037,d3
L000050ba                       cmp.w   d3,d0
L000050bc                       bcs.b   L000050e4
L000050be                       moveq   #$02,d1
L000050c0                       bra.b   L000050e4

L000050c2                       move.w  (a0)+,d0
L000050c4                       move.w  $0030(a1),d3
L000050c8                       subq.w  #$05,d3
L000050ca                       cmp.w   d3,d0
L000050cc                       bcc.b   L000050e4
L000050ce                       moveq.l #$ffffffff,d6
L000050d0                       moveq   #$40,d2

L000050d2                       lea.l   L00008bae,a3
L000050d8                       moveq   #$01,d1
L000050da                       sub.w   #$0037,d3
L000050de                       cmp.w   d3,d0
L000050e0                       bcc.b   L000050e4
L000050e2                       moveq   #$02,d1
L000050e4                       move.w  d1,L00008f62
L000050ea                       beq.w   L000051d8
L000050ee                       lea.l   L00007a20,a2
L000050f4                       move.w  L00009078,d3
L000050fa                       and.w   #$00e0,d3
L000050fe                       lea.l   $00(a2,d3.w),a2
L00005102                       lea.l   L0000909f,a4
L00005108                       lea.l   current_road_section_256_bytes,a5           ; L00008f74,a5
L0000510e                       add.b   L00009077,d2
L00005114                       move.b  $00(a5,d2.w),d1
L00005118                       bne.b   L0000512a
L0000511a                       move.b  $01(a5,d2.w),d1
L0000511e                       beq.w   L000051d8
L00005122                       move.w  $0002(a0),d0
L00005126                       addq.l  #$01,a2
L00005128                       addq.l  #$01,a4
L0000512a                       lsl.w   #$04,d1
L0000512c                       lea.l   $00(a3,d1.w),a3
L00005130                       move.b  $0004(a3),d2
L00005134                       move.b  $0005(a3),d3
L00005138                       move.b  (a2),d1
L0000513a                       ext.w   d2
L0000513c                       ext.w   d1
L0000513e                       mulu.w  d2,d1
L00005140                       ext.w   d3
L00005142                       beq.b   L00005146
L00005144                       divu.w  d3,d1
L00005146                       tst.w   d6
L00005148                       bmi.b   L00005154
L0000514a                       neg.w   d1
L0000514c                       add.w   #$000a,d1
L00005150                       sub.w   $000c(a3),d0
L00005154                       add.w   d1,d0
L00005156                       add.w   $0006(a3),d0
L0000515a                       move.b  (a4),d2
L0000515c                       and.w   #$00ff,d2
L00005160                       add.w   #$0038,d2

L00005164                       move.w  $0010(a1),d3
L00005168                       add.w   $002c(a1),d3
L0000516c                       move.w  d3,d4
L0000516e                       sub.w   $002a(a1),d4
L00005172                       cmp.w   d4,d2
L00005174                       bcs.b   L000051d8
L00005176                       sub.w   $000a(a3),d2
L0000517a                       bmi.b   L00005180
L0000517c                       cmp.w   d3,d2
L0000517e                       bcc.b   L000051d8
L00005180                       moveq   #$01,d1
L00005182                       cmp.w   $0030(a1),d0
L00005186                       bcc.b   L000051d8
L00005188                       add.w   $0008(a3),d0
L0000518c                       cmp.w   $002e(a1),d0
L00005190                       bcs.b   L000051d8
L00005192                       cmp.w   #$00a0,d0
L00005196                       bcs.b   L0000519a
L00005198                       addq.b  #$01,d1
L0000519a                       move.w  #$0004,$003a(a1)
L000051a0                       move.w  d6,$0038(a1)
L000051a4                       move.w  L00008f6e,d0
L000051aa                       ext.l   d0
L000051ac                       divu.w  #$0007,d0
L000051b0                       add.w   #$0008,d0
L000051b4                       move.w  d0,$0036(a1)
L000051b8                       move.w  L00008f6e,d0
L000051be                       ext.l   d0
L000051c0                       divu.w  #$0003,d0
L000051c4                       move.w  d0,L00008f6e
L000051ca                       moveq   #$0c,d0
L000051cc                       bsr.w   L00003c92
L000051d0                       moveq   #$03,d0
L000051d2                       jmp     PANEL_LOSE_ENERGY       ; Panel


L000051d8                       rts  


L000051da                       lea.l   L000090f9,a0
L000051e0                       movea.l a0,a1
L000051e2                       move.w  #$0014,d7
L000051e6                       move.w  d7,d6
L000051e8                       moveq   #$00,d0
L000051ea                       add.b   (a0),d0
L000051ec                       move.b  d0,(a0)+
L000051ee                       dbf.w   d7,L000051ea
L000051f2                       lea.l   L000080c8,a0
L000051f8                       lea.l   L00007bc8,a2
L000051fe                       lea.l   L00007fc8,a3
L00005204                       move.b  (a1)+,d0
L00005206                       lsl.w   #$01,d0
L00005208                       move.w  $00(a2,d0.w),(a0)+
L0000520c                       move.w  $00(a3,d0.w),(a0)+
L00005210                       dbf.w   d6,L00005204
L00005214                       rts  


L00005216                       dc.w    $ffce
L00005218                       dc.w    $0000,$ffe2
L0000521c                       dc.w    $0000,$ffec
L00005220                       dc.w    $0000,$fff6
L00005224                       dc.w    $0000,$fff8
L00005228                       dc.w    $0001,$fffc
L0000522c                       dc.w    $0001,$ffff
L00005230                       dc.w    $0001,$0001
L00005234                       dc.w    $0001,$0004
L00005238                       dc.w    $0001,$0008
L0000523c                       dc.w    $0001,$000a
L00005240                       dc.w    $0001,$0014
L00005244                       dc.w    $0001,$001e
L00005248                       dc.w    $0000,$0032
L0000524c                       dc.w    $0000


L0000524e                       MOVEA.L L000037c4,A5
L00005254                       lea.l   L00009bce,a4
L0000525a                       move.w  $0040(a6),d0
L0000525e                       move.w  $004a(a6),d1
L00005262                       move.w  $0042(a6),d2
L00005266                       move.w  $004c(a6),d3
L0000526a                       sub.w   d0,d1
L0000526c                       move.w  d2,d4
L0000526e                       sub.w   d3,d2
L00005270                       bcc.b   L0000527a
L00005272                       add.w   d1,d0
L00005274                       neg.w   d1
L00005276                       move.w  d3,d4
L00005278                       neg.w   d2
L0000527a                       move.w  d4,d3
L0000527c                       lsl.w   #$02,d3
L0000527e                       add.w   d4,d3
L00005280                       lsl.w   #$03,d3
L00005282                       lea.l   $00(a5,d3.w),a5
L00005286                       move.w  d2,d7
L00005288                       beq.w   L00005302
L0000528c                       subq.w  #$01,d7
L0000528e                       bmi.b   L000052b6
L00005290                       moveq   #$01,d4
L00005292                       tst.w   d1
L00005294                       bpl.w   L0000529c
L00005298                       neg.w   d1
L0000529a                       neg.w   d4
L0000529c                       cmp.w   d1,d2
L0000529e                       bcs.b   L000052d0
L000052a0                       move.b  d2,d3
L000052a2                       lsr.b   #$01,d3
L000052a4                       add.b   d1,d3
L000052a6                       cmp.b   d2,d3
L000052a8                       bcs.b   L000052ae
L000052aa                       sub.b   d2,d3
L000052ac                       add.w   d4,d0
L000052ae                       lea.l   -$0028(a5),a5
L000052b2                       dbf.w   d7,L000052b8
L000052b6                       rts  


L000052b8                       add.b   d1,d3
L000052ba                       cmp.b   d2,d3
L000052bc                       bcs.b   L000052c2
L000052be                       sub.b   d2,d3
L000052c0                       add.w   d4,d0
L000052c2                       bsr.w   L0000531e
L000052c6                       lea.l   -$0028(a5),a5
L000052ca                       dbf.w   d7,L000052a4
L000052ce                       rts  

L000052d0                       moveq   #$00,d3
L000052d2                       bsr.w   L0000531e
L000052d6                       add.w   d4,d0
L000052d8                       add.b   d2,d3
L000052da                       bcs.b   L000052e0
L000052dc                       cmp.b   d1,d3
L000052de                       bcs.b   L000052ec
L000052e0                       sub.b   d1,d3
L000052e2                       lea.l   -$0028(a5),a5
L000052e6                       dbf.w   d7,L000052ec
L000052ea                       rts  


L000052ec                       add.w   d4,d0
L000052ee                       add.b   d2,d3
L000052f0                       bcs.b   L000052f6
L000052f2                       cmp.b   d1,d3
L000052f4                       bcs.b   L000052d2
L000052f6                       sub.b   d1,d3
L000052f8                       lea.l   -$0028(a5),a5
L000052fc                       dbf.w   d7,L000052d2 
L00005300                       rts 


L00005302                       moveq   #$02,d2
L00005304                       tst.w   d1
L00005306                       beq.b   L0000531c
L00005308                       bpl.b   L0000530e
L0000530a                       neg.w   d2
L0000530c                       neg.w   d1
L0000530e                       lsr.w   #$01,d1
L00005310                       subq.w  #$01,d1
L00005312                       bsr.w   L0000531e
L00005316                       add.w   d2,d0
L00005318                       dbf.w   d1,L00005312
L0000531c                       rts  


L0000531e                       move.w  d0,d6
L00005320                       lsl.w   #$02,d6
L00005322                       and.w   #$003c,d6
L00005326                       lea.l   $00(a4,d6.w),a2
L0000532a                       move.w  d0,d6
L0000532c                       lsr.w   #$03,d6
L0000532e                       bclr.l  #$0000,d6
L00005332                       lea.l   $00(a5,d6.w),a3
L00005336                       move.l  $0040(a2),d6
L0000533a                       not.l   d6
L0000533c                       cmp.w   #$0130,d0
L00005340                       bcc.b   L000053a0
L00005342                       and.l   d6,(a3)
L00005344                       move.l  (a2),d5
L00005346                       or.l    d5,(a3)
L00005348                       and.l   d6,$17c0(a3)
L0000534c                       move.l  $0040(a2),d5
L00005350                       or.l    d5,$17c0(a3)
L00005354                       and.l   d6,$2f80(a3)
L00005358                       move.l  $0080(a2),d5
L0000535c                       or.l    d5,$2f80(a3)
L00005360                       and.l   d6,$4740(a3)
L00005364                       move.l  $00c0(a2),d5
L00005368                       or.l    d5,$4740(a3)
L0000536c                       lea.l   $0028(a3),a3
L00005370                       lea.l   $0100(a2),a2
L00005374                       and.l   d6,(a3)
L00005376                       move.l  (a2),d5
L00005378                       or.l    d5,(a3)
L0000537a                       and.l   d6,$17c0(a3)
L0000537e                       move.l  $0040(a2),d5
L00005382                       or.l    d5,$17c0(a3)
L00005386                       and.l   d6,$2f80(a3)
L0000538a                       move.l  $0080(a2),d5
L0000538e                       or.l    d5,$2f80(a3)
L00005392                       and.l   d6,$4740(a3)
L00005396                       move.l  $00c0(a2),d5
L0000539a                       or.l    d5,$4740(a3)
L0000539e                       rts 


L000053a0                       cmp.w   #$0140,d0
L000053a4                       bcc.b   L0000539e
L000053a6                       swap.w  d6
L000053a8                       and.w   d6,(a3)
L000053aa                       move.w  (a2),d5
L000053ac                       or.w    d5,(a3)
L000053ae                       and.w   d6,$17c0(a3)
L000053b2                       move.w  $0040(a2),d5
L000053b6                       or.w    d5,$17c0(a3)
L000053ba                       and.w   d6,$2f80(a3)
L000053be                       move.w  $0080(a2),d5
L000053c2                       or.w    d5,$2f80(a3)
L000053c6                       and.w   d6,$4740(a3)
L000053ca                       move.w  $00c0(a2),d5
L000053ce                       or.w    d5,$4740(a3)
L000053d2                       lea.l   $0028(a3),a3
L000053d6                       lea.l   $0100(a2),a2
L000053da                       and.w   d6,(a3)
L000053dc                       move.w  (a2),d5
L000053de                       or.w    d5,(a3)
L000053e0                       and.w   d6,$17c0(a3)
L000053e4                       move.w  $0040(a2),d5
L000053e8                       or.w    d5,$17c0(a3)
L000053ec                       and.w   d6,$2f80(a3)
L000053f0                       move.w  $0080(a2),d5
L000053f4                       or.w    d5,$2f80(a3)
L000053f8                       and.w   d6,$4740(a3)
L000053fc                       move.w  $00c0(a2),d5
L00005400                       or.w    d5,$4740(a3)
L00005404                       rts  


L00005406                       lea.l   L00008d5c,a6
L0000540c                       move.w  $003c(a6),d0
L00005410                       bne.b   L00005414 
L00005412                       rts  


L00005414                       cmp.w   #$0003,d0
L00005418                       beq.b   L00005412
L0000541a                       lea.l   L0000974e,a5
L00005420                       move.w  $0054(a6),d0
L00005424                       add.w   $004e(a6),d0
L00005428                       lsl.w   #$04,d0
L0000542a                       lea.l   $02(a5,d0.w),a5
L0000542e                       moveq   #$00,d3
L00005430                       move.w  (a5)+,d4
L00005432                       move.w  (a5)+,d5
L00005434                       move.w  (a5)+,d7
L00005436                       move.w  $004a(a6),d0
L0000543a                       move.w  $004c(a6),d2
L0000543e                       cmp.w   #$0140,d0
L00005442                       bcc.b   L00005412
L00005444                       addq.w  #$06,d2
L00005446                       subq.w  #$06,d0
L00005448                       bra.w   L00004e5e


L0000544c                       move.w  $003c(a6),d0
L00005450                       bne.b   L000054ba
L00005452                       tst.b   L00003708
L00005458                       bne.b   L0000545c
L0000545a                       rts  


L0000545c                       cmp.w   #$0050,L00008f6e
L00005464                       bcs.b   L0000545a
L00005466                       moveq   #$0a,d0
L00005468                       bsr.w   L00003c92
L0000546c                       move.w  #$0001,$003c(a6)
L00005472                       move.w  #$000e,$0044(a6)
L00005478                       move.w  #$007f,$004c(a6)
L0000547e                       move.w  #$007f,$0042(a6)
L00005484                       move.l  #L00005216,$0046(a6)
L0000548c                       move.w  #$007e,d0
L00005490                       moveq   #$00,d1
L00005492                       btst.l  #$0002,d5
L00005496                       bne.b   L000054ae
L00005498                       btst.l  #$0003,d5
L0000549c                       bne.b   L000054a8
L0000549e                       cmp.w   #$016d,L00009074
L000054a6                       bcc.b   L000054ae
L000054a8                       move.w  #$00c0,d0
L000054ac                       moveq   #$02,d1
L000054ae                       move.w  d0,$004a(a6)
L000054b2                       move.w  d0,$0040(a6)
L000054b6                       move.w  d1,$004e(a6)
L000054ba                       cmp.w   #$0002,d0
L000054be                       beq.w   L00005608
L000054c2                       cmp.w   #$0003,d0
L000054c6                       beq.w   L000056c0
L000054ca                       subq.w  #$01,$0044(a6)
L000054ce                       bpl.b   L000054da
L000054d0                       move.w  #$0000,$003c(a6)
L000054d6                       bra.w   L00005572

L000054da                       movea.l $0046(a6),a0
L000054de                       move.w  (a0)+,d0
L000054e0                       tst.w   $004e(a6)
L000054e4                       beq.b   L000054e8
L000054e6                       neg.w   d0
L000054e8                       add.w   d0,$004a(a6)
L000054ec                       move.w  (a0)+,$0054(a6)
L000054f0                       move.l  a0,$0046(a6)
L000054f4                       lea.l   current_road_section_256_bytes,a0           ; L00008f74,a0
L000054fa                       move.w  L00009076,d0
L00005500                       moveq   #$00,d6
L00005502                       add.b   #$40,d0
L00005506                       move.w  L00007ff2,d1
L0000550c                       add.w   #$0024,d1
L00005510                       tst.w   $004e(a6)
L00005514                       bne.b   L00005524
L00005516                       add.b   #$20,d0
L0000551a                       move.w  L00007bf2,d1
L00005520                       sub.w   #$0024,d1
L00005524                       cmp.b   #$01,$00(a0,d0.w)
L0000552a                       beq.b   L00005552
L0000552c                       tst.b   L00008f6e
L00005532                       beq.b   L00005572
L00005534                       move.b  L00008f6f,d2
L0000553a                       bmi.b   L00005544
L0000553c                       cmp.b   L00009079,d2
L00005542                       bcc.b   L00005572
L00005544                       add.b   #$01,d0
L00005548                       cmp.b   #$01,$00(a0,d0.w)
L0000554e                       bne.b   L00005572
L00005550                       moveq   #$01,d6
L00005552                       tst.w   d1
L00005554                       bmi.w   L00005572
L00005558                       move.w  d1,d2
L0000555a                       sub.w   $0040(a6),d2
L0000555e                       tst.w   $004e(a6)
L00005562                       bne.b   L00005574
L00005564                       cmp.w   #$0065,d1
L00005568                       bcc.b   L00005572
L0000556a                       neg.w   d2
L0000556c                       cmp.w   $004a(a6),d1
L00005570                       bcc.b   L00005580
L00005572                       rts  


L00005574                       cmp.w   #$00d9,d1
L00005578                       bcs.b   L00005572 
L0000557a                       cmp.w   $004a(a6),d1
L0000557e                       bcc.b   L00005572
L00005580                       move.w  d1,$004a(a6)
L00005584                       move.w  #$0002,$003c(a6)
L0000558a                       move.w  d2,$0050(a6)
L0000558e                       moveq   #$00,d5
L00005590                       move.w  d5,d0
L00005592                       tst.w   d6
L00005594                       beq.b   L0000559a
L00005596                       move.w  #$00fb,d0
L0000559a                       move.w  L00008f6e,d1
L000055a0                       move.w  d1,L00008f70
L000055a6                       move.w  d0,L00008f6e
L000055ac                       move.w  d5,$0004(a6)
L000055b0                       move.w  d5,$0002(a6)
L000055b4                       move.w  d5,L00003708
L000055ba                       divu.w  #$00a4,d1
L000055be                       mulu.w  #$0019,d1
L000055c2                       add.w   #$0019,d1
L000055c6                       move.w  #$004e,$0044(a6)
L000055cc                       move.w  d1,$0056(a6)
L000055d0                       move.w  d1,$0052(a6)
L000055d4                       move.w  #$00c0,L00009078
L000055dc                       move.w  #$0001,$0054(a6)
L000055e2                       moveq   #$00,d6
L000055e4                       tst.w   $004e(a6)
L000055e8                       beq.b   L000055ec
L000055ea                       moveq.l #$ffffffff,d6
L000055ec                       move.w  d6,$0038(a6)
L000055f0                       move.w  L00008f70,d0
L000055f6                       ext.l   d0
L000055f8                       divu.w  #$0009,d0
L000055fc                       addq.w  #$03,d0
L000055fe                       move.w  d0,$0036(a6)
L00005602                       moveq   #$0b,d0
L00005604                       bra.w   L00003c92

L00005608                       move.w  $0052(a6),d0
L0000560c                       move.w  $0044(a6),d7
L00005610                       move.w  d0,d1
L00005612                       mulu.w  #$013a,d1
L00005616                       divu.w  #$03e8,d1
L0000561a                       mulu.w  d1,d1
L0000561c                       divu.w  #$0005,d1
L00005620                       and.l   #$0000ffff,d1
L00005626                       divu.w  #$0064,d1
L0000562a                       move.w  d1,$0046(a6)
L0000562e                       cmp.w   $0050(a6),d1
L00005632                       bcc.b   L0000569c 
L00005634                       tst.w   $004e(a6)
L00005638                       beq.b   L0000564a
L0000563a                       add.w   #$00c0,d1
L0000563e                       move.w  L00007ff2,d4
L00005644                       add.w   #$0024,d4
L00005648                       bra.b   L0000565a 
L0000564a                       neg.w   d1
L0000564c                       add.w   #$007e,d1
L00005650                       move.w  L00007bf2,d4
L00005656                       sub.w   #$0024,d4
L0000565a                       move.w  d1,$0040(a6)
L0000565e                       move.w  d4,$004a(a6)
L00005662                       move.w  d0,d2
L00005664                       mulu.w  d7,d2
L00005666                       divu.w  #$000e,d2
L0000566a                       and.l   #$0000ffff,d2
L00005670                       divu.w  #$0064,d2
L00005674                       neg.w   d2
L00005676                       add.w   #$007f,d2
L0000567a                       move.w  d2,$0042(a6)
L0000567e                       add.w   $0056(a6),d0
L00005682                       move.w  d0,$0052(a6)
L00005686                       subq.w  #$01,d7
L00005688                       move.w  d7,$0044(a6)
L0000568c                       moveq   #$00,d5
L0000568e                       move.w  d5,L00008f6e
L00005694                       move.w  d5,L00003708
L0000569a                       rts  


L0000569c                       move.w  #$0003,$003c(a6)
L000056a2                       tst.w   $004e(a6)
L000056a6                       beq.b   L000056ae
L000056a8                       add.w   #$00c0,d1
L000056ac                       bra.b   L000056b4
L000056ae                       neg.w   d1
L000056b0                       add.w   #$007e,d1
L000056b4                       sub.w   $0040(a6),d1
L000056b8                       bpl.b   L000056bc
L000056ba                       neg.w   d1
L000056bc                       move.w  d1,$0044(a6)
L000056c0                       move.w  $0044(a6),d0
L000056c4                       addq.w  #$01,d0
L000056c6                       move.w  d0,$0044(a6)
L000056ca                       move.w  $0040(a6),d1
L000056ce                       tst.w   $004e(a6)
L000056d2                       beq.b   L000056de
L000056d4                       add.w   d0,d1
L000056d6                       cmp.w   #$01a4,d1
L000056da                       bcc.b   L000056ee
L000056dc                       bra.b   L000056e8
L000056de                       sub.w   d0,d1
L000056e0                       bpl.b   L000056e8
L000056e2                       cmp.w   #$ff9c,d1
L000056e6                       bcs.b   L000056ee
L000056e8                       move.w  d1,$0040(a6)
L000056ec                       bra.b   L0000568c

L000056ee                       move.w  #$0000,$003c(a6)
L000056f4                       bsr.w   L00006a2c
L000056f8                       move.w  L00008f70,L00008f6e
L00005702                       lea.l   $0008(a7),a7
L00005706                       movea.l display_buffer2_ptr,a0                  ; L000037c4,a0
L0000570c                       moveq   #$00,d0
L0000570e                       move.w  #$17bf,d7
L00005712                       move.l  d0,(a0)+
L00005714                       dbf.w   d7,L00005712
L00005718                       bsr.w   L00003ce2
L0000571c                       move.w  #$0001,L00008d2a
L00005724                       bra.w   L000039ce 


L00005728                       dc.w    $0005,$fff4
L0000572c                       dc.w    $0005,$fff8
L00005730                       dc.w    $0005,$fffc
L00005734                       dc.w    $0000,$fffe
L00005738                       dc.w    $0000,$ffff
L0000573c                       dc.w    $0000,$0001
L00005740                       dc.w    $0000,$0002
L00005744                       dc.w    $000a    
L00005746                       dc.w    $0004,$000a 
L0000574a                       dc.w    $0008  
L0000574c                       dc.w    $000a  
L0000574e                       dc.w    $000c  
L00005750                       dc.w    $0010,$0002  
L00005754                       dc.w    $000c      
L00005756                       dc.w    $0004,$0008   
L0000575a                       dc.w    $0006,$0004 
L0000575e                       dc.w    $0008      
L00005760                       dc.w    $0000,$000a 


L00005764                       lea.l   L00008d5c,a6
L0000576a                       tst.w   $003a(a6)
L0000576e                       beq.b   L00005774
L00005770                       subq.w  #$01,$003a(a6)
L00005774                       tst.w   $0032(a6)
L00005778                       beq.b   L0000577e
L0000577a                       subq.w  #$01,$0032(a6)
L0000577e                       move.w  $0022(a6),d0
L00005782                       addq.w  #$01,d0
L00005784                       and.w   #$0003,d0
L00005788                       move.w  d0,$0022(a6)
L0000578c                       btst.l  #$0000,d0
L00005790                       beq.b   L0000579c
L00005792                       addq.w  #$01,$0024(a6) 
L00005796                       and.w   #$0003,$0024(a6)
L0000579c                       move.w  L00003708,d5
L000057a2                       tst.w   L00008f66
L000057a8                       beq.w   L000057ae 
L000057ac                       moveq   #$00,d5
L000057ae                       tst.w   game_type               ; L00008d1e (batwing = 1, batmobile = 0)
L000057b4                       bne.w   L00005a28
L000057b8                       bsr.w   L0000544c
L000057bc                       move.w  $0018(a6),d0
L000057c0                       beq.b   L00005802
L000057c2                       subq.w  #$01,d0
L000057c4                       move.w  d0,$0018(a6)
L000057c8                       bne.b   L000057d0
L000057ca                       moveq   #$08,d0
L000057cc                       bsr.w   L00003c92
L000057d0                       movea.l $001c(a6),a0
L000057d4                       move.w  #$0000,L00003708
L000057dc                       move.w  (a0)+,$0016(a6)
L000057e0                       move.w  $0010(a6),d0
L000057e4                       add.w   (a0)+,d0
L000057e6                       move.w  d0,$0010(a6)
L000057ea                       add.w   #$007f,d0
L000057ee                       sub.w   #$0091,d0
L000057f2                       move.w  d0,$004c(a6)
L000057f6                       move.w  d0,$0042(a6)
L000057fa                       move.l  a0,$001c(a6)
L000057fe                       bra.w   L00005894
L00005802                       tst.w   $0036(a6)
L00005806                       beq.b   L0000581a
L00005808                       move.w  $0038(a6),d0
L0000580c                       add.w   #$0002,d0
L00005810                       move.w  d5,d1
L00005812                       and.w   #$0003,d1

L00005816                       cmp.w   d5,d1
L00005818                       beq.b   L00005894
L0000581a                       move.w  d5,d0
L0000581c                       move.w  L00008f6e,d2
L00005822                       move.w  d2,d3
L00005824                       move.w  #$fffb,d1
L00005828                       and.w   #$0003,d0
L0000582c                       beq.b   L0000587e
L0000582e                       move.w  #$ffe7,d1
L00005832                       btst.l  #$0000,d0
L00005836                       beq.b   L0000587e
L00005838                       move.w  #$01c3,d1
L0000583c                       move.w  L00008f62,d0
L00005842                       beq.b   L00005852
L00005844                       move.w  #$0078,d1
L00005848                       cmp.w   #$0001,d0
L0000584c                       bcs.b   L00005852
L0000584e                       move.w  #$0078,d1
L00005852                       sub.w   d1,d2
L00005854                       bcc.b   L00005876
L00005856                       add.w   #$0118,d1
L0000585a                       bcs.b   L00005868
L0000585c                       add.w   #$0118,d1
L00005860                       lsr.w   #$06,d1
L00005862                       or.w    #$0001,d1
L00005866                       bra.b   L0000587e

L00005868                       sub.w   #$0118,d1
L0000586c                       neg.w   d1
L0000586e                       lsr.w   #$06,d1
L00005870                       or.w    #$0001,d1
L00005874                       bra.b   L0000587e

L00005876                       lsr.w   #$06,d1
L00005878                       or.w    #$0001,d1
L0000587c                       neg.w   d1
L0000587e                       add.w   d3,d1
L00005880                       bpl.b   L00005884
L00005882                       moveq   #$00,d1
L00005884                       cmp.w   #$01c2,d1
L00005888                       bcs.b   L0000588e
L0000588a                       move.w  #$01c2,d1
L0000588e                       move.w  d1,L00008f6e
L00005894                       move.w  $0002(a6),d0
L00005898                       move.w  $0004(a6),d1
L0000589c                       tst.w   $0018(a6)
L000058a0                       bne.b   L0000590c
L000058a2                       btst.l  #$0002,d5
L000058a6                       bne.b   L000058d0
L000058a8                       btst.l  #$0003,d5
L000058ac                       bne.b   L000058be
L000058ae                       subq.w  #$02,d0
L000058b0                       bcc.w   L000058b6
L000058b4                       moveq   #$00,d0
L000058b6                       subq.w  #$02,d1
L000058b8                       bcc.b   L000058e2 
L000058ba                       moveq   #$00,d1
L000058bc                       bra.b   L000058e2 

L000058be                       addq.w  #$03,d0
L000058c0                       cmp.w   #$0010,d0
L000058c4                       bcs.b   L000058c8
L000058c6                       moveq   #$10,d0
L000058c8                       sub.w   d0,d1
L000058ca                       bcc.b   L000058e2
L000058cc                       moveq   #$00,d1
L000058ce                       bra.b   L000058e2
L000058d0                       addq.w  #$03,d1
L000058d2                       cmp.w   #$0010,d1
L000058d6                       bcs.b   L000058da
L000058d8                       moveq   #$10,d1
L000058da                       sub.w   d1,d0
L000058dc                       bcc.b   L000058e2
L000058de                       move.w  #$0000,d0
L000058e2                       move.w  L00008f6e,d2
L000058e8                       lsr.w   #$04,d2
L000058ea                       move.w  d2,d3
L000058ec                       lsr.w   #$02,d2
L000058ee                       add.w   d3,d2
L000058f0                       cmp.w   d2,d0
L000058f2                       bcs.b   L000058f6
L000058f4                       move.w  d2,d0
L000058f6                       cmp.w   d2,d1
L000058f8                       bcs.b   L000058fc

L000058fa                       move.w  d2,d1
L000058fc                       move.w  d0,$0002(a6)
L00005900                       move.w  d1,$0004(a6)
L00005904                       move.w  $0036(a6),d2
L00005908                       beq.b   L0000590c
L0000590a                       exg.l   d0,d1
L0000590c                       bsr.w   L00005980
L00005910                       moveq   #$02,d0
L00005912                       moveq.l #$ffffffff,d2
L00005914                       tst.w   d1
L00005916                       bpl.b   L0000591c 
L00005918                       neg.w   d1
L0000591a                       neg.w   d2
L0000591c                       cmp.w   #$0008,d1
L00005920                       bcs.b   L0000592c
L00005922                       add.w   d2,d0
L00005924                       cmp.w   #$0010,d1
L00005928                       bcs.b   L0000592c

L0000592a                       add.w   d2,d0
L0000592c                       move.w  d0,$0012(a6)
L00005930                       move.w  $0036(a6),d0
L00005934                       beq.w   L0000597e
L00005938                       ext.l   d0
L0000593a                       move.w  d0,d1
L0000593c                       tst.w   $0018(a6)
L00005940                       bne.b   L0000594e
L00005942                       mulu.w  #$0004,d1
L00005946                       divu.w  #$0005,d1
L0000594a                       move.w  d1,$0036(a6)
L0000594e                       move.w  d0,d1
L00005950                       lsr.w   #$03,d1
L00005952                       cmp.w   #$0003,d1
L00005956                       bcs.b   L0000595c
L00005958                       move.w  #$0002,d1
L0000595c                       add.w   #$0002,d1
L00005960                       tst.w   $0038(a6)
L00005964                       bmi.b   L0000596e 
L00005966                       neg.w   d1
L00005968                       add.w   #$0004,d1
L0000596c                       neg.w   d0
L0000596e                       add.w   d0,L00009074 
L00005974                       move.w  d1,$0012(a6)
L00005978                       move.w  #$0002,$0032(a6)
L0000597e                       rts 


L00005980                       moveq   #$00,d5
L00005982                       move.w  $000e(a6),d2
L00005986                       beq.b   L000059c6 
L00005988                       bpl.b   L0000598c 

L0000598a                       neg.w   d2
L0000598c                       move.w  #$005e,d3
L00005990                       divu.w  d2,d3
L00005992                       move.w  d3,d2
L00005994                       move.w  $000a(a6),d3
L00005998                       move.w  L00009078,d4
L0000599e                       sub.w   d3,d4
L000059a0                       beq.b   L000059c6
L000059a2                       sub.w   d2,d4
L000059a4                       bcs.b   L000059ac
L000059a6                       addq.w  #$01,d5
L000059a8                       add.b   d2,d3
L000059aa                       bcs.b   L000059a2
L000059ac                       tst.w   d5
L000059ae                       beq.b   L000059c2
L000059b0                       add.w   d5,$000c(a6)
L000059b4                       move.w  d5,d4
L000059b6                       lsl.w   #$01,d5
L000059b8                       add.w   d4,d5
L000059ba                       tst.w   $000e(a6)
L000059be                       bpl.b   L000059c2
L000059c0                       neg.w   d5
L000059c2                       move.w  d3,$000a(a6)
L000059c6                       add.w   $0034(a6),d5
L000059ca                       move.w  #$0000,$0034(a6)
L000059d0                       sub.w   d0,d1
L000059d2                       add.w   d1,d5

L000059d4                       tst.w   d1
L000059d6                       beq.b   L000059fc 
L000059d8                       move.w  d1,d0
L000059da                       and.b   #$0f,d0
L000059de                       bne.b   L000059fc 
L000059e0                       tst.w   d5
L000059e2                       bpl.b   L000059ee
L000059e4                       tst.w   d1
L000059e6                       bmi.b   L000059fc
L000059e8                       tst.w   d5
L000059ea                       bpl.b   L000059fc
L000059ec                       bra.b   L000059f6
L000059ee                       tst.w   d1
L000059f0                       bpl.b   L000059fc
L000059f2                       tst.w   d5
L000059f4                       bmi.b   L000059fc
L000059f6                       move.w  #$0002,$0032(a6)
L000059fc                       add.w   L00009074,d5
L00005a02                       move.w  #$0034,d2
L00005a06                       cmp.w   d2,d5
L00005a08                       bcc.b   L00005a0c
L00005a0a                       move.w  d2,d5
L00005a0c                       move.w  #$029f,d2
L00005a10                       cmp.w   d2,d5
L00005a12                       bcs.b   L00005a16 
L00005a14                       move.w  d2,d5
L00005a16                       move.w  d5,L00009074
L00005a1c                       addq.w  #$01,$0026(a6)
L00005a20                       and.w   #$0003,$0026(a6)
L00005a26                       rts     


L00005a28                       tst.w   L00008d38
L00005a2e                       beq.b   L00005a32
L00005a30                       rts  


L00005a32                       move.w  L00008f6e,d2
L00005a38                       move.w  d2,d3
L00005a3a                       moveq   #$00,d1
L00005a3c                       tst.b   L00003708 
L00005a42                       beq.b   L00005a86 
L00005a44                       move.w  d5,d0
L00005a46                       and.w   #$0003,d0
L00005a4a                       beq.b   L00005a86 
L00005a4c                       move.w  #$ffec,d1
L00005a50                       btst.l  #$0000,d0
L00005a54                       beq.b   L00005a86

L00005a56                       move.w  #$0200,d1
L00005a5a                       sub.w   d1,d2
L00005a5c                       bcc.b   L00005a7e
L00005a5e                       add.w   #$012c,d1
L00005a62                       bcs.b   L00005a70 
L00005a64                       add.w   #$012c,d1
L00005a68                       lsr.w   #$06,d1
L00005a6a                       or.w    #$0001,d1
L00005a6e                       bra.b   L00005a86
L00005a70                       sub.w   #$012c,d1
L00005a74                       neg.w   d1
L00005a76                       lsr.w   #$06,d1
L00005a78                       or.w    #$0001,d1
L00005a7c                       bra.b   L00005a86
L00005a7e                       lsr.w   #$06,d1
L00005a80                       or.w    #$0001,d1
L00005a84                       neg.w   d1
L00005a86                       add.w   d3,d1
L00005a88                       bpl.b   L00005a8c
L00005a8a                       moveq   #$78,d1
L00005a8c                       cmp.w   #$01ff,d1
L00005a90                       bcs.b   L00005a96
L00005a92                       move.w  #$01ff,d1
L00005a96                       cmp.w   #$0078,d1
L00005a9a                       bcc.b   L00005a9e
L00005a9c                       moveq   #$78,d1
L00005a9e                       move.w  d1,L00008f6e

L00005aa4                       lea.l   current_road_section_256_bytes,a0           ; L00008f74,a0
L00005aaa                       move.w  L00009076,d0
L00005ab0                       add.b   #$20,d0
L00005ab4                       moveq   #$00,d1
L00005ab6                       moveq   #$04,d2
L00005ab8                       move.b  $00(a0,d0.w),d3
L00005abc                       bmi.b   L00005ac0
L00005abe                       asr.b   #$01,d3
L00005ac0                       add.b   d3,d1
L00005ac2                       addq.b  #$01,d0
L00005ac4                       dbf.w   d2,L00005ab8
L00005ac8                       add.b   #$87,d1
L00005acc                       move.w  d1,$0020(a6)
L00005ad0                       move.w  $0006(a6),d0
L00005ad4                       move.w  $0008(a6),d1
L00005ad8                       tst.b   L00003708 
L00005ade                       bne.b   L00005aec 
L00005ae0                       btst.l  #$0000,d5
L00005ae4                       bne.b   L00005afa 
L00005ae6                       btst.l  #$0001,d5
L00005aea                       bne.b   L00005b0e
L00005aec                       subq.w  #$01,d0
L00005aee                       bcc.b   L00005af2
L00005af0                       moveq   #$00,d0
L00005af2                       subq.w  #$01,d1
L00005af4                       bcc.b   L00005b22
L00005af6                       moveq   #$00,d1
L00005af8                       bra.b   L00005b22

L00005afa                       move.w  d0,d2
L00005afc                       addq.w  #$01,d2
L00005afe                       cmp.w   #$0005,d2
L00005b02                       bcc.b   L00005b06
L00005b04                       move.w  d2,d0
L00005b06                       sub.w   d0,d1
L00005b08                       bcc.b   L00005b22
L00005b0a                       moveq   #$00,d1
L00005b0c                       bra.b   L00005b22
L00005b0e                       move.w  d1,d2
L00005b10                       addq.w  #$01,d2
L00005b12                       cmp.w   #$0005,d2
L00005b16                       bcc.b   L00005b1a
L00005b18                       move.w  d2,d1
L00005b1a                       sub.w   d1,d0
L00005b1c                       bcc.b   L00005b22
L00005b1e                       move.w  #$0000,d0
L00005b22                       move.w  L00008f6e,d2
L00005b28                       lsr.w   #$04,d2
L00005b2a                       move.w  d2,d3
L00005b2c                       lsr.w   #$02,d2
L00005b2e                       add.w   d3,d2
L00005b30                       bra.b   L00005b3e

L00005b32                       cmp.w   d2,d0
L00005b34                       bcs.b   L00005b38
L00005b36                       move.w  d2,d0
L00005b38                       cmp.w   d2,d1
L00005b3a                       bcs.b   L00005b3e
L00005b3c                       move.w  d2,d1
L00005b3e                       move.w  d0,$0006(a6)
L00005b42                       move.w  d1,$0008(a6)
L00005b46                       sub.w   d1,d0
L00005b48                       move.w  d0,d1
L00005b4a                       add.w   $0010(a6),d0
L00005b4e                       cmp.w   #$0026,d0
L00005b52                       bcc.b   L00005b58
L00005b54                       move.w  #$0026,d0
L00005b58                       move.w  $0020(a6),d2
L00005b5c                       cmp.w   d2,d0
L00005b5e                       bcs.b   L00005b90
L00005b60                       tst.w   $0028(a6)
L00005b64                       bne.b   L00005b6c

L00005b66                       move.w  #$0001,$0028(a6)
L00005b6c                       move.w  d2,d0
L00005b6e                       sub.w   #$0087,d2
L00005b72                       neg.w   d2
L00005b74                       bpl.b   L00005b78
L00005b76                       moveq   #$00,d2
L00005b78                       lsr.w   #$01,d2
L00005b7a                       add.w   $0006(a6),d2
L00005b7e                       cmp.w   #$0009,d2
L00005b82                       bcs.b   L00005b86
L00005b84                       moveq   #$09,d2
L00005b86                       move.w  #$0000,$0006(a6)
L00005b8c                       move.w  d2,$0008(a6)
L00005b90                       move.w  d0,$0010(a6)
L00005b94                       moveq   #$00,d0
L00005b96                       tst.w   d1
L00005b98                       beq.b   L00005bac
L00005b9a                       moveq   #$0a,d2
L00005b9c                       tst.w   d1
L00005b9e                       bpl.b   L00005ba4
L00005ba0                       moveq   #$05,d2
L00005ba2                       neg.w   d1
L00005ba4                       cmp.w   #$0002,d1
L00005ba8                       bcs.b   L00005bac

L00005baa                       move.w  d2,d0
L00005bac                       move.w  d0,$001e(a6)
L00005bb0                       move.w  $0002(a6),d0
L00005bb4                       move.w  $0004(a6),d1
L00005bb8                       btst.l  #$0002,d5
L00005bbc                       bne.b   L00005be4
L00005bbe                       btst.l  #$0003,d5
L00005bc2                       bne.b   L00005bd2
L00005bc4                       subq.w  #$03,d0
L00005bc6                       bcc.b   L00005bca
L00005bc8                       moveq   #$00,d0
L00005bca                       subq.w  #$03,d1
L00005bcc                       bcc.b   L00005bf6
L00005bce                       moveq   #$00,d1
L00005bd0                       bra.b   L00005bf6 
L00005bd2                       addq.w  #$04,d0
L00005bd4                       cmp.w   #$0012,d0
L00005bd8                       bcs.b   L00005bdc
L00005bda                       moveq   #$12,d0
L00005bdc                       sub.w   d0,d1
L00005bde                       bcc.b   L00005bf6
L00005be0                       moveq   #$00,d1
L00005be2                       bra.b   L00005bf6

L00005be4                       addq.w  #$04,d1
L00005be6                       cmp.w   #$0012,d1
L00005bea                       bcs.b   L00005bee
L00005bec                       moveq   #$12,d1
L00005bee                       sub.w   d1,d0
L00005bf0                       bcc.b   L00005bf6
L00005bf2                       move.w  #$0000,d0
L00005bf6                       move.w  L00008f6e,d2
L00005bfc                       lsr.w   #$04,d2
L00005bfe                       move.w  d2,d3
L00005c00                       lsr.w   #$02,d2
L00005c02                       add.w   d3,d2
L00005c04                       bra.b   L00005c12

L00005c06                       cmp.w   d2,d0
L00005c08                       bcs.b   L00005c0c
L00005c0a                       move.w  d2,d0
L00005c0c                       cmp.w   d2,d1
L00005c0e                       bcs.b   L00005c12
L00005c10                       move.w  d2,d1
L00005c12                       move.w  d0,$0002(a6)
L00005c16                       move.w  d1,$0004(a6)
L00005c1a                       bsr.w   L00005980
L00005c1e                       moveq   #$00,d0
L00005c20                       tst.w   d1
L00005c22                       beq.b   L00005c40
L00005c24                       moveq   #$03,d2
L00005c26                       tst.w   d1
L00005c28                       bpl.b   L00005c2e
L00005c2a                       moveq   #$01,d2
L00005c2c                       neg.w   d1
L00005c2e                       cmp.w   #$0006,d1
L00005c32                       bcs.b   L00005c40
L00005c34                       move.w  d2,d0
L00005c36                       cmp.w   #$000c,d1
L00005c3a                       bcs.b   L00005c40

L00005c3c                       add.w   #$0001,d0
L00005c40                       move.w  d0,$0012(a6)
L00005c44                       move.w  $0036(a6),d0
L00005c48                       beq.w   L00005c86
L00005c4c                       ext.l   d0
L00005c4e                       move.w  d0,d1
L00005c50                       mulu.w  #$0004,d1
L00005c54                       divu.w  #$0005,d1
L00005c58                       move.w  d1,$0036(a6)
L00005c5c                       move.w  d0,d1
L00005c5e                       lsr.w   #$03,d1
L00005c60                       cmp.w   #$0003,d1
L00005c64                       bcs.b   L00005c6a
L00005c66                       move.w  #$0002,d1
L00005c6a                       add.w   #$0002,d1
L00005c6e                       tst.w   $0038(a6)
L00005c72                       bmi.b   L00005c7c
L00005c74                       neg.w   d1
L00005c76                       add.w   #$0004,d1
L00005c7a                       neg.w   d0
L00005c7c                       add.w   d0,L00009074
L00005c82                       move.w  d1,$0012(a6)
L00005c86                       rts  


L00005c88                       tst.w   d7
L00005c8a                       bne.w   L00004d18
L00005c8e                       movem.l d6/d7/a0-a3,-(a7)
L00005c92                       bsr.b   L00005c9c
L00005c94                       movem.l (a7)+,d6/d7/a0-a3
L00005c98                       bra.w   L00004d18

L00005c9c                       lea.l   L00008d5c,a6
L00005ca2                       move.w  $003c(a6),d0
L00005ca6                       cmp.w   #$0002,d0
L00005caa                       bcc.w   L00005e86
L00005cae                       tst.w   d7
L00005cb0                       bpl.w   L00005f58
L00005cb4                       tst.w   d0
L00005cb6                       beq.b   L00005cde
L00005cb8                       move.w  $0012(a6),d0
L00005cbc                       sub.w   #$0002,d0
L00005cc0                       beq.b   L00005cd0
L00005cc2                       ext.l   d0
L00005cc4                       swap.w  d0
L00005cc6                       move.w  $004e(a6),d1
L00005cca                       lsr.w   #$01,d1
L00005ccc                       add.w   d0,d1
L00005cce                       bne.b   L00005cde
L00005cd0                       bsr.w   L0000524e
L00005cd4                       bsr.w   L00005406

L00005cd8                       lea.l   L00008d5c,a6
L00005cde                       move.w  $0012(a6),d1
L00005ce2                       add.w   $0016(a6),d1
L00005ce6                       move.w  d1,d3
L00005ce8                       lsl.w   #$02,d3
L00005cea                       lea.l   L000063d6,a4
L00005cf0                       move.w  #$0074,d0
L00005cf4                       add.w   $00(a4,d3.w),d0
L00005cf8                       move.w  #$0091,d2
L00005cfc                       add.w   $02(a4,d3.w),d2
L00005d00                       lea.l   DATA24_OFFSET_5,a5      ; $0003622e,a5 ; DATA2.IFF/DATA4.IFF external address
L00005d06                       movem.l d1-d3/a6,-(a7)
L00005d0a                       bsr.w   L000062a4
L00005d0e                       movem.l (a7)+,d1-d3/a6
L00005d12                       lea.l   L0000639a,a4
L00005d18                       move.w  #$0077,d0
L00005d1c                       add.w   $00(a4,d3.w),d0
L00005d20                       move.w  $0010(a6),d2
L00005d24                       add.w   $02(a4,d3.w),d2

L00005d28                       lea.l   DATA24_OFFSET_0,a5      ; $0002a41a,a5 ; DATA2.IFF/DATA4.IFF external address
L00005d2e                       bsr.w   L000062ce
L00005d32                       lea.l   L00008d5c,a6
L00005d38                       move.w  $0026(a6),d0
L00005d3c                       beq.b   L00005d68 
L00005d3e                       subq.w  #$01,d0
L00005d40                       and.w   #$0001,d0
L00005d44                       move.w  d0,d1
L00005d46                       move.w  $0012(a6),d2
L00005d4a                       lsl.w   #$01,d2
L00005d4c                       add.w   d2,d0
L00005d4e                       add.w   #$001d,d0
L00005d52                       mulu.w  #$000f,d1
L00005d56                       add.w   #$0069,d1
L00005d5a                       add.w   $0016(a6),d1

L00005d5e                       lea.l   DATA24_OFFSET_0,a5                      ; $0002a41a,a5 ; external address
L00005d64                       bsr.w   L00006206
L00005d68                       lea.l   L00008d5c,a6
L00005d6e                       tst.w   $0018(a6)
L00005d72                       bne.b   L00005dd8 
L00005d74                       tst.w   L00008f6e 
L00005d7a                       beq.b   L00005dd8 
L00005d7c                       move.w  L00008f62,d0
L00005d82                       beq.b   L00005d9a 
L00005d84                       cmp.w   #$0002,d0
L00005d88                       beq.b   L00005da0
L00005d8a                       moveq   #$01,d2
L00005d8c                       cmp.w   #$016d,L00009074
L00005d94                       bcc.b   L00005da2
L00005d96                       moveq   #$02,d2
L00005d98                       bra.b   L00005da2
L00005d9a                       tst.w   $0032(a6)
L00005d9e                       beq.b   L00005dd8
L00005da0                       moveq   #$03,d2
L00005da2                       move.w  $0024(a6),d0
L00005da6                       move.w  $0016(a6),d1

L00005daa                       lea.l   DATA24_OFFSET_0,a5                      ; $0002a41a,a5 ; external address
L00005db0                       lsr.w   #$01,d2
L00005db2                       bcc.b   L00005dc8
L00005db4                       movem.l d0-d2/a5-a6,-(a7)
L00005db8                       add.w   #$0019,d0
L00005dbc                       add.w   #$004b,d1
L00005dc0                       bsr.w   L00006206
L00005dc4                       movem.l (a7)+,d0-d2/a5-a6
L00005dc8                       lsr.w   #$01,d2
L00005dca                       bcc.b   L00005dd8
L00005dcc                       add.w   #$0015,d0
L00005dd0                       add.w   #$005a,d1
L00005dd4                       bsr.w   L00006206
L00005dd8                       move.w  L00008d28,d7
L00005dde                       beq.b   L00005e54
L00005de0                       lsr.w   #$02,d7
L00005de2                       neg.w   d7
L00005de4                       addq.w  #$04,d7
L00005de6                       cmp.w   #$0004,d7
L00005dea                       bcs.b   L00005dee
L00005dec                       moveq   #$03,d7

L00005dee                       lea.l   L00006718,a0
L00005df4                       movem.l d7/a0,-(a7)
L00005df8                       lea.l   L00008d5c,a6
L00005dfe                       move.w  (a0),d0
L00005e00                       addq.w  #$01,d0
L00005e02                       cmp.w   #$000c,d0
L00005e06                       bne.b   L00005e14
L00005e08                       bsr.w   L0000421a               ; d0 = randomish number
L00005e0c                       and.w   #$000f,d0
L00005e10                       add.w   #$000c,d0
L00005e14                       cmp.w   #$0014,d0
L00005e18                       bcs.b   L00005e1c
L00005e1a                       moveq   #$00,d0
L00005e1c                       move.w  d0,(a0)+ 
L00005e1e                       lsr.w   #$01,d0
L00005e20                       cmp.w   #$0006,d0
L00005e24                       bcc.b   L00005e48
L00005e26                       move.w  d0,d1
L00005e28                       lsl.w   #$02,d1
L00005e2a                       move.w  $00(a0,d1.w),d2
L00005e2e                       move.w  $02(a0,d1.w),d3
L00005e32                       add.w   #$0027,d0
L00005e36                       move.w  #$0087,d1
L00005e3a                       add.w   $0016(a6),d1

L00005e3e                       lea.l   DATA24_OFFSET_0,a5              ; $0002a41a,a5 ; external address
L00005e44                       bsr.w   L00006266
L00005e48                       movem.l (a7)+,d7/a0
L00005e4c                       lea.l   $001a(a0),a0
L00005e50                       dbf.w   d7,L00005df4

L00005e54                       lea.l   L00008d5c,a6
L00005e5a                       tst.w   $003c(a6)
L00005e5e                       beq.w   L00005f58
L00005e62                       move.w  $0012(a6),d0
L00005e66                       sub.w   #$0002,d0
L00005e6a                       beq.w   L00005f58
L00005e6e                       ext.l   d0
L00005e70                       swap.w  d0
L00005e72                       move.w  $004e(a6),d1
L00005e76                       lsr.w   #$01,d1
L00005e78                       add.w   d0,d1
L00005e7a                       beq.w   L00005f58
L00005e7e                       bsr.w   L0000524e
L00005e82                       bra.w   L00005406
L00005e86                       tst.w   d7
L00005e88                       bmi.w   L00005406
L00005e8c                       moveq   #$05,d0
L00005e8e                       cmp.w   #$0003,$003c(a6)
L00005e94                       beq.b   L00005eca
L00005e96                       move.w  $0050(a6),d1
L00005e9a                       move.w  d1,d2
L00005e9c                       sub.w   $0046(a6),d1

L00005ea0                       lsr.w   #$02,d2
L00005ea2                       move.w  d2,d3
L00005ea4                       cmp.w   d2,d1
L00005ea6                       bcs.b   L00005eca
L00005ea8                       moveq   #$04,d0
L00005eaa                       add.w   d3,d2
L00005eac                       cmp.w   d2,d1
L00005eae                       bcs.b   L00005eca
L00005eb0                       moveq   #$03,d0
L00005eb2                       add.w   d3,d2
L00005eb4                       cmp.w   d2,d1
L00005eb6                       bcs.b   L00005eca
L00005eb8                       moveq   #$02,d0
L00005eba                       add.w   d3,d2
L00005ebc                       cmp.w   d2,d1
L00005ebe                       bcs.b   L00005eca
L00005ec0                       moveq   #$01,d0
L00005ec2                       add.w   d3,d2
L00005ec4                       cmp.w   d2,d1
L00005ec6                       bcs.b   L00005eca
L00005ec8                       moveq   #$00,d0
L00005eca                       lea.l   L00006346,a4
L00005ed0                       tst.w   $004e(a6)
L00005ed4                       bne.b   L00005edc

L00005ed6                       lea.l   L000062f2,a4
L00005edc                       mulu.w  #$000e,d0
L00005ee0                       lea.l   $00(a4,d0.w),a4
L00005ee4                       cmp.w   #$0003,$003c(a6)
L00005eea                       beq.b   L00005efc
L00005eec                       tst.w   (a4)
L00005eee                       bne.b   L00005efc
L00005ef0                       movem.l a4/a6,-(a7)
L00005ef4                       bsr.w   L0000524e
L00005ef8                       movem.l (a7)+,a4/a6
L00005efc                       move.w  $0002(a4),d1
L00005f00                       bmi.b   L00005f24
L00005f02                       move.w  $0040(a6),d0
L00005f06                       move.w  $0042(a6),d2
L00005f0a                       add.w   $0004(a4),d0
L00005f0e                       add.w   $0006(a4),d2

L00005f12                       movem.l a4/a6,-(a7)
L00005f16                       lea.l   DATA24_OFFSET_5,a5      ; $0003622e,a5 ; DATA2.IFF/DATA4.IFF - external address
L00005f1c                       bsr.w   L000062a4
L00005f20                       movem.l (a7)+,a4/a6
L00005f24                       move.w  $0008(a4),d1
L00005f28                       move.w  $0040(a6),d0
L00005f2c                       move.w  $0042(a6),d2
L00005f30                       add.w   $000a(a4),d0
L00005f34                       add.w   $000c(a4),d2
L00005f38                       movem.l a4/a6,-(a7)

L00005f3c                       lea.l   DATA24_OFFSET_0,a5      ; $0002a41a,a5 ; DATA2.IFF/DATA4.IFF - external address
L00005f42                       bsr.w   L000062ce
L00005f46                       movem.l (a7)+,a4/a6
L00005f4a                       cmp.w   #$0003,$003c(a6)
L00005f50                       beq.b   L00005f58
L00005f52                       tst.w   (a4)
L00005f54                       bne.w   L0000524e
L00005f58                       rts  


                        ; --------------- update traffic - maybe ------------------

L00005f5a                       lea.l   L00008d5c,a6
L00005f60                       move.w  $0020(a6),d1
L00005f64                       move.w  d1,d2
L00005f66                       sub.w   $0010(a6),d1
L00005f6a                       lsr.w   #$04,d1
L00005f6c                       cmp.w   #$0004,d1
L00005f70                       bcs.b   L00005f76
L00005f72                       move.w  #$0004,d1
L00005f76                       move.w  d1,d3
L00005f78                       lsl.w   #$02,d3

L00005f7a                       lea.l   L00006704,a1
L00005f80                       move.w  #$005a,d0
L00005f84                       add.w   $00(a1,d3.w),d0
L00005f88                       lea.l   DATA24_OFFSET_7,a5      ; $000358b0,a5 ; DATA2.IFF/DATA4.IFF - external address
L00005f8e                       bra.w   L000062a4

L00005f92                       lea.l   L00008dfc,a6
L00005f98                       lea.l   DATA24_OFFSET_6,a5      ; $00035d4c,a5 ; DATA2.IFF/DATA4.IFF - external address
L00005f9e                       moveq   #$02,d7
L00005fa0_loop                  move.w  $0000(a6),d1
L00005fa4                       bne.b   L00005fb0
L00005fa6                       lea.l   $0006(a6),a6
L00005faa                       dbf.w   d7,L00005fa0_loop
L00005fae                       bra.b   L00005ff2

L00005fb0                       cmp.w   #$0009,d1
L00005fb4                       bcs.b   L00005fbe
L00005fb6                       move.w  #$0000,$0000(a6)
L00005fbc                       bra.b   L00005fa6

L00005fbe                       addq.w  #$01,$0000(a6)
L00005fc2                       subq.w  #$01,d1
L00005fc4                       lsr.w   #$01,d1

L00005fc6                       lea.l   L000066f4,a0
L00005fcc                       move.w  d1,d3
L00005fce                       lsl.w   #$02,d3
L00005fd0                       add.w   #$0011,d1
L00005fd4                       move.w  $0002(a6),d0
L00005fd8                       add.w   $00(a0,d3.w),d0
L00005fdc                       move.w  $0004(a6),d2
L00005fe0                       add.w   $02(a0,d3.w),d2
L00005fe4                       movem.l d7/a5-a6,-(a7)
L00005fe8                       bsr.w   L000062ce               ; ***** check this out *****
L00005fec                       movem.l (a7)+,d7/a5-a6

L00005ff0                       bra.b   L00005fa6

L00005ff2                       lea.l   L00008dc0,a6
L00005ff8                       lea.l   DATA24_OFFSET_10,a5     ; $00042592,a5 ; Data2/4 - external address
L00005ffe                       moveq   #$02,d7
L00006000_loop                  tst.w   $0000(a6)
L00006004                       bne.b   L00006012
L00006006                       lea.l   $0014(a6),a6
L0000600a                       dbf.w   d7,L00006000_loop
L0000600e                       bra.w   L000060c6

L00006012                       subq.w  #$01,$0000(a6)
L00006016                       move.w  $0002(a6),d1
L0000601a                       cmp.w   #$0003,d1
L0000601e                       bcc.b   L0000603a
L00006020                       addq.w  #$01,$0002(a6)
L00006024                       move.w  $0004(a6),d0
L00006028                       move.w  $0006(a6),d2
L0000602c                       movem.l d7/a5-a6,-(a7)
L00006030                       bsr.w   L000062ce               ; ***** check this out *****
L00006034                       movem.l (a7)+,d7/a5-a6
L00006038                       bra.b   L00006006

L0000603a                       move.w  $0004(a6),d0
L0000603e                       move.w  $0006(a6),d2
L00006042                       moveq   #$05,d1
L00006044                       sub.w   #$0010,$0004(a6)
L0000604a                       add.w   #$0010,$0006(a6)
L00006050                       movem.l d7/a5-a6,-(a7)
L00006054                       bsr.w   L000062c6               ; ***** check this out *****
L00006058                       movem.l (a7)+,d7/a5-a6
L0000605c                       move.w  $0008(a6),d0
L00006060                       move.w  $000a(a6),d2
L00006064                       moveq   #$06,d1
L00006066                       add.w   #$0010,$0008(a6)
L0000606c                       add.w   #$0010,$000a(a6)
L00006072                       movem.l d7/a5-a6,-(a7)
L00006076                       bsr.w   L000062c6               ; ***** check this out *****
L0000607a                       movem.l (a7)+,d7/a5-a6
L0000607e                       move.w  $000c(a6),d0
L00006082                       move.w  $000e(a6),d2
L00006086                       moveq   #$03,d1
L00006088                       add.w   #$0010,$000c(a6)
L0000608e                       sub.w   #$0010,$000e(a6)
L00006094                       movem.l d7/a5-a6,-(a7)
L00006098                       bsr.w   L000062c6               ; ***** check this out *****
L0000609c                       movem.l (a7)+,d7/a5-a6
L000060a0                       move.w  $0010(a6),d0
L000060a4                       move.w  $0012(a6),d2
L000060a8                       moveq   #$04,d1
L000060aa                       sub.w   #$0010,$0010(a6)
L000060b0                       sub.w   #$0010,$0012(a6)
L000060b6                       movem.l d7/a5-a6,-(a7)
L000060ba                       bsr.w   L000062c6               ; ***** check this out *****
L000060be                       movem.l (a7)+,d7/a5-a6
L000060c2                       bra.w   L00006006

L000060c6                       lea.l   L00008d5c,a6
L000060cc                       cmp.w   #$000a,$001e(a6)
L000060d2                       bne.b   L000060d8

L000060d4                       bsr.w   L000061de               ; ***** check this out *****
L000060d8                       lea.l   L00008d5c,a6
L000060de                       lea.l   L00006412,a5
L000060e4                       move.w  $0012(a6),d1
L000060e8                       add.w   $001e(a6),d1
L000060ec                       move.w  d1,d3
L000060ee                       lsl.w   #$01,d3
L000060f0                       move.w  $00(a5,d3.w),d2
L000060f4                       move.w  #$0062,d0
L000060f8                       add.w   $0010(a6),d2

L000060fc                       lea.l   DATA24_OFFSET_0,a5              ; $0002a41a,a5 ; external address
L00006102                       bsr.w   L000062ce               ; ***** check this out *****
L00006106                       lea.l   L00008d5c,a6
L0000610c                       move.w  $0026(a6),d0
L00006110                       beq.b   L00006132
L00006112                       move.w  #$0007,d2
L00006116                       move.w  $001e(a6),d1
L0000611a                       beq.b   L0000612a 
L0000611c                       move.w  #$000d,d2
L00006120                       cmp.w   #$0009,d1
L00006124                       bcc.b   L0000612a 
L00006126                       move.w  #$000a,d2
L0000612a                       add.w   d2,d0
L0000612c                       moveq   #$1e,d1
L0000612e                       bsr.w   L000061fc
L00006132                       lea.l   L00008d5c,a6
L00006138                       move.w  $0028(a6),d0
L0000613c                       beq.b   L0000616e 
L0000613e                       add.w   #$ffff,d0
L00006142                       moveq   #$00,d1
L00006144                       bsr.w   L000061fc

L00006148                       lea.l   L00008d5c,a6
L0000614e                       move.w  $0028(a6),d0
L00006152                       move.w  d0,d1
L00006154                       addq.w  #$01,d1
L00006156                       cmp.w   #$0005,d1
L0000615a                       bcs.w   L00006160
L0000615e                       moveq   #$00,d1
L00006160                       move.w  d1,$0028(a6)
L00006164                       add.w   #$ffff,d0
L00006168                       moveq   #$0f,d1
L0000616a                       bsr.w   L000061fc
L0000616e                       lea.l   L00008d5c,a6
L00006174                       cmp.w   #$000a,$001e(a6)
L0000617a                       beq.b   L0000617e
L0000617c                       bsr.b   L000061de               ; ***** check this out *****
L0000617e                       tst.w   L00008d38
L00006184                       beq.b   L000061dc
L00006186                       subq.w  #$01,L00008d38
L0000618c                       bne.b   L00006196
L0000618e                       move.w  #$0002,L00008f66

L00006196                       lea.l   L00006688,a1            ; 18 byte struct? 
L0000619c                       moveq   #$05,d7
L0000619e_loop                  movem.l d7/a1,-(a7)
L000061a2                       move.w  (a1),d0
L000061a4                       addq.w  #$01,d0
L000061a6                       cmp.w   #$000c,d0
L000061aa                       bcs.b   L000061b4
L000061ac                       moveq   #$0d,d0
L000061ae                       bsr.w   L00003c92               ; ***** check this out *****
L000061b2                       moveq   #$00,d0
L000061b4                       move.w  d0,(a1)+ 
L000061b6                       cmp.w   #$0004,d0
L000061ba                       bcc.b   L000061d0
L000061bc                       move.w  d0,d1
L000061be                       add.w   #$0011,d0

L000061c2                       lea.l   DATA24_OFFSET_6,a5      ; $00035d4c,a5 ; DATA2.IFF/DATA4.IFF - external address
L000061c8                       lea.l   L00008d5c,a6
L000061ce                       bsr.b   L00006210               ; ***** check this out *****
L000061d0                       movem.l (a7)+,d7/a1
L000061d4                       lea.l   $0012(a1),a1
L000061d8                       dbf.w   d7,L0000619e_loop
L000061dc                       rts  



L000061de                       move.w  L00008d28,d3
L000061e4                       beq.b   L000061dc
L000061e6                       move.w  $0022(a6),d0
L000061ea                       addq.w  #$04,d0
L000061ec                       moveq   #$2d,d1
L000061ee                       movem.l d0-d3/a6,-(a7)
L000061f2                       bsr.b   L00006240
L000061f4                       movem.l (a7)+,d0-d3/a6
L000061f8                       moveq   #$3c,d1
L000061fa                       bra.b   L00006240


L000061fc                       lea.l   DATA24_OFFSET_6,a5      ; $00035d4c,a5 ; DATA2.IFF/DATA4.IFF - external address
L00006202                       add.w   $001e(a6),d1
L00006206                       add.w   $0012(a6),d1
L0000620a                       lea.l   L00006430,a1
L00006210                       lsl.w   #$04,d0
L00006212                       lsl.w   #$02,d1
L00006214                       lea.l   $02(a5,d0.w),a5
L00006218                       move.w  (a5)+,d4
L0000621a                       move.w  (a5)+,d5
L0000621c                       move.w  (a5)+,d7
L0000621e                       move.w  #$0062,d0
L00006222                       move.w  $00(a1,d1.w),d2
L00006226                       cmp.w   #$0064,d2
L0000622a                       beq.b   L0000623e_rts
L0000622c                       add.w   d2,d0
L0000622e                       move.w  $0010(a6),d2
L00006232                       add.w   $02(a1,d1.w),d2
L00006236                       moveq   #$00,d3
L00006238                       move.w  d3,d6
L0000623a                       bra.w   L00004e20

L0000623e_rts                   rts



L00006240                       lea.l   DATA24_OFFSET_6,a5      ; $00035d4c,a5 ; DATA2.IFF/DATA4.IFF - external address
L00006246                       add.w   $001e(a6),d1
L0000624a                       add.w   $0012(a6),d1
L0000624e                       lea.l   L00006430,a1
L00006254                       lsl.w   #$04,d0
L00006256                       lsl.w   #$02,d1
L00006258                       lea.l   $02(a5,d0.w),a5
L0000625c                       move.w  (a5)+,d4
L0000625e                       move.w  (a5)+,d5
L00006260                       move.w  (a5)+,d7
L00006262                       sub.w   d3,d7
L00006264                       bra.b   L0000621e

L00006266                       add.w   $0012(a6),d1
L0000626a                       lea.l   L00006430,a1
L00006270                       lsl.w   #$04,d0
L00006272                       lsl.w   #$02,d1
L00006274                       lea.l   $02(a5,d0.w),a5
L00006278                       move.w  (a5)+,d4
L0000627a                       move.w  (a5)+,d5
L0000627c                       move.w  (a5)+,d7
L0000627e                       move.w  #$0062,d0
L00006282                       add.w   d2,d0
L00006284                       move.w  $00(a1,d1.w),d2
L00006288                       cmp.w   #$0064,d2
L0000628c                       beq.b   L000062a2_rts
L0000628e                       add.w   d2,d0
L00006290                       move.w  $0010(a6),d2
L00006294                       add.w   d3,d2
L00006296                       add.w   $02(a1,d1.w),d2
L0000629a                       moveq   #$00,d3
L0000629c                       move.w  d3,d6
L0000629e                       bra.w   L00004e20

L000062a2_rts                   rts



L000062a4                       lsl.w   #$04,d1
L000062a6                       lea.l   $00(a5,d1.w),a5
L000062aa                       move.w  (a5)+,d1
L000062ac                       cmp.w   #$0140,d0
L000062b0                       bcs.b   L000062ba
L000062b2                       bpl.b   L000062b8
L000062b4                       add.w   d0,d1
L000062b6                       bpl.b   L000062ba
L000062b8                       rts  

L000062ba                       moveq   #$00,d3
L000062bc                       move.w  (a5)+,d4
L000062be                       move.w  (a5)+,d5
L000062c0                       move.w  (a5)+,d7
L000062c2                       bra.w   L00004e56
L000062c6                       cmp.w   #$0098,d2
L000062ca                       bcs.b   L000062ce
L000062cc                       rts  

L000062ce                       lsl.w   #$04,d1
L000062d0                       lea.l   $00(a5,d1.w),a5
L000062d4                       move.w  (a5)+,d1
L000062d6                       cmp.w   #$0140,d0
L000062da                       bcs.b   L000062e4
L000062dc                       bpl.b   L000062e2
L000062de                       add.w   d0,d1
L000062e0                       bpl.b   L000062e4
L000062e2                       rts  

L000062e4                       moveq   #$00,d3
L000062e6                       move.w  d3,d6
L000062e8                       move.w  (a5)+,d4
L000062ea                       move.w  (a5)+,d5
L000062ec                       move.w  (a5)+,d7
L000062ee                       bra.w   L00004e20


L000062f2               dc.w    $0000,$000c,$fffb,$000c,$000c,$fffe,$000a,$0001
L00006302               dc.w    $000b,$fffb,$000e,$000b,$fffe,$000c,$0001,$000a
L00006312               dc.w    $fff7,$0010,$000a,$fffa,$000e,$0001,$ffff,$0000
L00006322               dc.w    $0000,$0012,$ffec,$000e,$0001,$ffff,$0000,$0000
L00006332               dc.w    $0013,$ffdc,$000e,$0001,$ffff,$0000,$0000,$0014
L00006342               dc.w    $ffc6,$0008

L00006346               dc.w    $0000,$000c,$ffbc,$000c,$000c,$ffbc
L00006352               dc.w    $000a,$0001,$000d,$ffbd,$000e,$000d,$ffbd,$000c
L00006362               dc.w    $0001,$000e,$ffb8,$0010,$000e,$ffb8,$000e,$0001
L00006372               dc.w    $ffff,$0000,$0000,$000f,$ffb2,$000e,$0001,$ffff
L00006382               dc.w    $0000,$0000,$0010,$ffb4,$000e,$0001,$ffff,$0000
L00006392               dc.w    $0000,$0011,$ffb6,$0008

L0000639a               dc.w    $0000,$0000,$0006,$0000
L000063a2               dc.w    $0007,$0000,$0006,$0000,$0003,$0000,$0000,$0002
L000063b2               dc.w    $0005,$0001,$0007,$0002,$0006,$0001,$0003,$0002
L000063c2               dc.w    $0000,$fffe,$0006,$fffd,$0007,$fffd,$0006,$fffd
L000063d2               dc.w    $0003,$fffe

L000063d6               dc.w    $0000,$0002,$0006,$0001,$0007,$0001
L000063e2               dc.w    $0006,$0001,$0004,$0002,$0000,$0003,$0005,$0002
L000063f2               dc.w    $0007,$0002,$0006,$0002,$0003,$0003,$0000,$0000
L00006402               dc.w    $0006,$ffff,$0007,$ffff,$0006,$ffff,$0004,$0000
L00006412               dc.w    $fffd,$ffff,$ffff,$ffff,$0000,$fffb,$fffc,$fffd
L00006422               dc.w    $fffc,$fffd,$fff8,$fff9,$fffb,$fff9,$fffb

L00006430               dc.w    $0020   
L00006432               dc.w    $0000,$0064,$0000,$0064,$0000,$0022,$0001,$0024
L00006442               dc.w    $0002,$0022,$fffe,$0064,$0000,$0064,$0000,$0022
L00006452               dc.w    $0000,$0024,$0001,$0020,$fffa,$0064,$0000,$0064
L00006462               dc.w    $0000,$0022,$fffb,$0024,$fffc,$0040,$0000,$003e
L00006472               dc.w    $0001,$003c,$0002,$0064,$0000,$0064,$0000,$003e
L00006482               dc.w    $fffe,$003e,$0000,$003c,$0001,$0064,$0000,$0064
L00006492               dc.w    $0000,$0040,$fffa,$003e,$fffb,$003c,$fffc,$0064
L000064a2               dc.w    $0000,$0064,$0000,$0030,$fff3,$0030,$fff3,$0030
L000064b2               dc.w    $fff3,$0030,$fff3,$0030,$fff3,$0030,$fff7,$0030
L000064c2               dc.w    $fff7,$002f,$fff7,$0030,$fff7,$0031,$fff7,$0030
L000064d2               dc.w    $ffec,$0030,$ffec,$0030,$ffec,$0030,$ffec,$0030
L000064e2               dc.w    $ffec,$0000,$ffeb,$0000,$ffe7,$0000,$ffe4,$0000
L000064f2               dc.w    $ffef,$0000,$fff2,$0000,$ffe9,$0000,$ffe5,$0000
L00006502               dc.w    $ffe2,$0000,$ffed,$0000,$fff0,$0000,$ffeb,$0000
L00006512               dc.w    $ffe7,$0000,$ffe4,$0000,$ffef,$0000,$fff2,$0052
L00006522               dc.w    $ffeb,$0052,$ffef,$0052,$fff2,$0052,$ffe7,$0052
L00006532               dc.w    $ffe4,$0052,$ffe9,$0052,$ffed,$0052,$fff0,$0052
L00006542               dc.w    $ffe5,$0052,$ffe2,$0052,$ffeb,$0052,$ffef,$0052
L00006552               dc.w    $fff2,$0052,$ffe7,$0052,$ffe4,$000e,$0000,$0008
L00006562               dc.w    $0000,$0004,$0000,$0000,$0000,$fffc,$0000,$000e
L00006572               dc.w    $0003,$0008,$0003,$0004,$0003,$0000,$0003,$fffc
L00006582               dc.w    $0003,$000e,$ffff,$0008,$ffff,$0004,$ffff,$0000
L00006592               dc.w    $ffff,$fffc,$ffff,$0060,$0000,$005c,$0000,$005a
L000065a2               dc.w    $0000,$0056,$0000,$0050,$0000,$0060,$0003,$005c
L000065b2               dc.w    $0003,$005a,$0003,$0056,$0003,$0050,$0003,$0060
L000065c2               dc.w    $ffff,$005c,$ffff,$005a,$ffff,$0056,$ffff,$0050
L000065d2               dc.w    $ffff,$0045,$fffe,$003f,$fffe,$0039,$fffe,$0034
L000065e2               dc.w    $fffe,$0030,$fffe,$0045,$0000,$003f,$0000,$0039
L000065f2               dc.w    $0000,$0034,$0000,$0030,$0000,$0045,$fffb,$003f
L00006602               dc.w    $fffb,$0039,$fffb,$0034,$fffb,$0030,$fffb,$0044
L00006612               dc.w    $ffff,$003e,$ffff,$0039,$fffe,$0033,$ffff,$002f
L00006622               dc.w    $ffff,$0044,$0001,$003e,$0001,$0039,$0000,$0033
L00006632               dc.w    $0001,$002f,$0001,$0044,$fffc,$003e,$fffc,$0039
L00006642               dc.w    $fffb,$0033,$fffc,$002f,$fffc,$0048,$fff0,$0043
L00006652               dc.w    $fff0,$003d,$fff0,$0038,$fff0,$0033,$fff0,$0048
L00006662               dc.w    $fff2,$0043,$fff2,$003d,$fff2,$0038,$fff2,$0033
L00006672               dc.w    $fff2,$0048,$ffeb,$0043,$ffeb,$003d,$ffeb,$0038
L00006682               dc.w    $ffeb,$0033,$ffeb

L00006688               dc.w    $0003,$0010,$fff4,$0010,$fff8 
L00006692               dc.w    $0000,$fffc,$0000,$0000,$0007,$0024,$ffee,$0024
L000066a2               dc.w    $fff2,$0014,$fff6,$0014,$fffa,$000a,$0038,$fffc
L000066b2               dc.w    $0038,$0000,$0028,$0004,$0028,$0008,$0002,$004c
L000066c2               dc.w    $fffe,$004c,$0002,$003c,$0006,$003c,$000a,$0005
L000066d2               dc.w    $0042,$fff0,$0042,$fff4,$0032,$fff8,$0032,$fffc
L000066e2               dc.w    $0000,$001a,$0002,$001a,$0006,$000a,$000a,$000a
L000066f2               dc.w    $000e

L000066f4               dc.w    $0010,$fff4,$0010,$fff8,$0000,$fffc,$0000
L00006702               dc.w    $0000

L00006704               dc.w    $0000,$0000,$0010,$0000,$0010,$0000,$0010
L00006712               dc.w    $0000,$0010,$0000

L00006718               dc.w    $0008,$fffe,$0000,$fffc,$0000
L00006722               dc.w    $fff8,$0002,$fff6,$0004,$fff5,$0006,$fff4,$0008
L00006732               dc.w    $000c,$ffee,$0008,$ffec,$0008,$ffe8,$000a,$ffe6
L00006742               dc.w    $000c,$ffe5,$000e,$ffe4,$0010,$0005,$000e,$0004
L00006752               dc.w    $000c,$0004,$0008,$0006,$0006,$0008,$0005,$000a
L00006762               dc.w    $0004,$000c,$0000,$0002,$0006,$0000,$0006,$fffc
L00006772               dc.w    $0008,$fffa,$000a,$fff9,$000c,$fff8,$000e 



L00006780                       moveq.l #$ffffffff,d1
L00006782                       addq.b  #$01,d1
L00006784                       sub.w   #$0064,d0
L00006788                       bcc.b   L00006782 
L0000678a                       add.w   #$0064,d0
L0000678e                       move.b  d1,d2
L00006790                       add.b   #$30,d1
L00006794                       move.b  d1,(a0)+ 
L00006796                       moveq.l #$ffffffff,d1
L00006798                       addq.b  #$01,d1
L0000679a                       sub.w   #$000a,d0
L0000679e                       bcc.b   L00006798 
L000067a0                       add.w   #$000a,d0
L000067a4                       lsl.b   #$04,d2
L000067a6                       or.b    d1,d2
L000067a8                       add.b   #$30,d1
L000067ac                       move.b  d1,(a0)+
L000067ae                       lsl.w   #$04,d2
L000067b0                       or.b    d0,d2
L000067b2                       add.b   #$30,d0
L000067b6                       move.b  d0,(a0) 
L000067b8                       rts  


L000067ba                       move.w  #$0000,L00008f72
L000067c2                       tst.b   L00008f6e
L000067c8                       beq.b   L000067cc
L000067ca                       bsr.b   L000067dc
L000067cc                       move.w  L00008f6e,d0
L000067d2                       add.b   d0,L00009079
L000067d8                       bcs.b   L000067dc
L000067da                       rts  


L000067dc                       move.l  #$00000010,d0
L000067e2                       pea.l   L000067ee
L000067e8                       jmp     PANEL_ADD_SCORE         ; Panel
                                ; return here (pea.l L000067ee)

L000067ee                       move.w  L00009076,d0
L000067f4                       addq.b  #$01,d0
L000067f6                       move.w  d0,L00009076
L000067fc                       addq.w  #$01,L00008f72
L00006802                       addq.w  #$01,L00008d26

L00006808                       lea.l   current_road_section_256_bytes,a0           ; L00008f74,a0
L0000680e                       move.w  L00009076,d0
L00006814                       add.b   #$1f,d0                                 ; add 31 (#$1f)
L00006818                       move.b  L00009098,d1
L0000681e                       sub.b   #$10,d1                                 ; sub 16 (#$10)
L00006822                       bcc.b   L0000683a
L00006824                       movea.l L00009084,a1
L0000682a                       move.b  (a1)+,d1
L0000682c                       beq.w   L000069ca
L00006830                       move.l  a1,L00009084
L00006836                       sub.b   #$10,d1
L0000683a                       move.b  d1,L00009098
L00006840                       and.b   #$0f,d1
L00006844                       btst.l  #$0003,d1
L00006848                       beq.b   L00006850
L0000684a                       and.w   #$0007,d1
L0000684e                       neg.b   d1
L00006850                       asl.b   #$01,d1
L00006852                       move.b  d1,$00(a0,d0.w)
L00006856                       add.b   #$20,d0
L0000685a                       move.b  L00009099,d1
L00006860                       sub.b   #$10,d1
L00006864                       bcc.b   L0000687c
L00006866                       movea.l L00009088,a1
L0000686c                       move.b  (a1)+,d1
L0000686e                       beq.w   L000069ca
L00006872                       move.l  a1,L00009088
L00006878                       sub.b   #$10,d1
L0000687c                       move.b  d1,L00009099
L00006882                       and.b   #$0f,d1
L00006886                       subq.b  #$08,d1
L00006888                       move.b  d1,$00(a0,d0.w)
L0000688c                       add.b   #$20,d0
L00006890                       add.w   #$0001,L0000907a
L00006898                       and.w   #$0001,L0000907a
L000068a0                       bne.b   L000068b4
L000068a2                       move.b  #$00,$00(a0,d0.w)
L000068a8                       add.b   #$20,d0
L000068ac                       move.b  #$00,$00(a0,d0.w)
L000068b2                       bra.b   L00006918


L000068b4                       move.b  L0000909b,d1
L000068ba                       sub.b   #$10,d1
L000068be                       bcc.b   L000068d6
L000068c0                       movea.l L00009094,a1
L000068c6                       move.b  (a1)+,d1
L000068c8                       beq.w   L000069ca
L000068cc                       move.l  a1,L00009094
L000068d2                       sub.b   #$10,d1
L000068d6                       move.b  d1,L0000909b
L000068dc                       and.b   #$0f,d1
L000068e0                       move.b  d1,$00(a0,d0.w)
L000068e4                       add.b   #$20,d0
L000068e8                       move.b  L0000909a,d1
L000068ee                       sub.b   #$10,d1
L000068f2                       bcc.b   L0000690a
L000068f4                       movea.l L00009090,a1
L000068fa                       move.b  (a1)+,d1
L000068fc                       beq.w   L000069ca
L00006900                       move.l  a1,L00009090
L00006906                       sub.b   #$10,d1
L0000690a                       move.b  d1,L0000909a
L00006910                       and.b   #$0f,d1
L00006914                       move.b  d1,$00(a0,d0.w)
L00006918                       add.b   #$20,d0
L0000691c                       move.b  L0000909c,d1
L00006922                       subq.b  #$01,d1
L00006924                       bcc.b   L00006974
L00006926                       movea.l L0000908c,a1
L0000692c                       move.b  (a1)+,d1
L0000692e                       beq.w   L000069ca
L00006932                       subq.b  #$01,d1
L00006934                       move.b  d1,L0000909c
L0000693a                       move.b  (a1)+,d1
L0000693c                       move.l  a1,L0000908c
L00006942                       cmp.b   #$40,d1
L00006946                       bcs.b   L00006958
L00006948                       rol.b   #$02,d1
L0000694a                       and.w   #$0003,d1
L0000694e                       subq.w  #$01,d1
L00006950                       move.w  d1,L00008d30
L00006956                       bra.b   L00006966


L00006958                       cmp.b   #$20,d1
L0000695c                       bne.b   L00006968
L0000695e                       move.w  #$0001,L00008f64
L00006966                       moveq   #$00,d1
L00006968                       move.b  d1,L0000909d
L0000696e                       move.b  d1,$00(a0,d0.w)
L00006972                       bra.b   L00006982
L00006974                       move.b  d1,L0000909c
L0000697a                       move.b  L0000909d,$00(a0,d0.w)
L00006982                       bsr.w   L00006bda
L00006986                       lea.l   L00008e0e,a0
L0000698c                       moveq   #$07,d7
L0000698e                       tst.b   $0000(a0)
L00006992                       beq.b   L000069c0
L00006994                       move.b  $0002(a0),d0
L00006998                       subq.b  #$01,d0
L0000699a                       bpl.b   L000069bc
L0000699c                       move.b  #$00,$0000(a0)
L000069a2                       tst.w   $001a(a0)
L000069a6                       beq.b   L000069c0
L000069a8                       tst.w   $0028(a0)
L000069ac                       bne.b   L000069c0
L000069ae                       pea.l   L000069c0
L000069b4                       moveq   #$01,d0
L000069b6                       jmp     PANEL_LOSE_ENERGY       ; Panel


L000069bc                       move.b  d0,$0002(a0)
L000069c0                       lea.l   $002a(a0),a0
L000069c4                       dbf.w   d7,L0000698e
L000069c8                       rts 



                ;-------------------- initialise road section values? -------------------
                ; sets up ptrs and clears values for the 1st/current road section
                ;
set_road_section_values
L000069ca                       movea.l L00009080,a0
L000069d0_loop                  move.l  (a0)+,d0
L000069d2                       bne.b   L000069d8
L000069d4                       movea.l (a0),a0
L000069d6                       bra.b   L000069d0_loop

L000069d8                       move.l  d0,L00009084
L000069de                       move.l  (a0)+,L00009088
L000069e4                       move.l  (a0)+,L00009094
L000069ea                       move.l  (a0)+,L00009090
L000069f0                       move.l  (a0)+,L0000908c
L000069f6                       move.l  a0,L00009080
L000069fc                       moveq   #$00,d0

L000069fe                       move.w  d0,L0000907a 
L00006a04                       move.b  d0,L00009098
L00006a0a                       move.b  d0,L00009099
L00006a10                       move.b  d0,L0000909b
L00006a16                       move.b  d0,L0000909a
L00006a1c                       move.b  d0,L0000909c
L00006a22                       move.b  d0,L0000909d
L00006a28                       bra.w   L00006808





                ; on initialisation, the road_section_ptr is either:-
                ;       - batmobile_section_list
                ;       - batwing_section_list
                ;
L00006a2c                       movea.l road_section_list_ptr,a0                ; L0000907c,a0 
L00006a32_loop                  move.l  (a0)+,d0
L00006a34                       bne.b   L00006a3a                               ; road block ptr is NOT NULL
L00006a36                       movea.l (a0),a0                                 ; if = $00000000 then next ptr back to start of list
L00006a38                       bra.b   L00006a32_loop

                                ; d0 = ptr to block of 5 road data ptrs.
L00006a3a                       move.l  d0,L00009080                            ; L00009080 = d0 (current road data ptrs) 
L00006a40                       move.l  a0,road_section_list_ptr                ; L0000907c - update to next road section ptr.
L00006a46                       moveq   #$00,d0
L00006a48                       move.w  d0,L00009076
L00006a4e                       move.w  d0,L00009078

                                ; clear block 64 longs (256 bytes)
L00006a54                       lea.l   current_road_section_256_bytes,a0       ; L00008f74,a0
L00006a5a                       move.w  #$003f,d7                               ; 63+1 loop counter
L00006a5e_loop                  move.l  d0,(a0)+
L00006a60                       dbf.w   d7,L00006a5e_loop

L00006a64                       bsr.w   L000069ca

L00006a68                       moveq   #$1f,d7
L00006a6a                       move.w  d7,-(a7)
L00006a6c                       bsr.w   L000067ee
L00006a70                       move.w  (a7)+,d7
L00006a72                       dbf.w   d7,L00006a6a

L00006a76                       lea.l   L00008d3c,a0
L00006a7c                       move.w  $0008(a0),d1
L00006a80                       movea.l a0,a1
L00006a82                       moveq   #$0f,d7
L00006a84                       move.w  #$0000,(a0)+
L00006a88                       dbf.w   d7,L00006a84

L00006a8c                       move.w  #$0058,$0006(a1)
L00006a92                       add.w   #$0028,d1
L00006a96                       cmp.w   #$0140,d1
L00006a9a                       bcs.b   L00006aa0
L00006a9c                       sub.w   #$0140,d1
L00006aa0                       move.w  d1,$0008(a1)
L00006aa4                       move.w  d1,$0018(a1)
L00006aa8                       move.w  #$016d,L00009074
L00006ab0                       rts 


L00006ab2                       dc.w    $ffff 
L00006ab4                       dc.w    $ffff 
L00006ab6                       dc.w    $7f7f 
L00006ab8                       dc.b    $55
L00006ab9                       dc.b    $55 
L00006aba                       dc.w    $0000
L00006abc                       dc.w    $0101
L00006abe                       dc.w    $0202
L00006ac0                       dc.b    $03
L00006ac1                       dc.b    $03
L00006ac2                       dc.w    $ffff 
L00006ac4                       dc.w    $ffff 
L00006ac6                       dc.w    $ffff 
L00006ac8                       dc.b    $7f
L00006ac9                       dc.b    $7f 
L00006aca                       dc.w    $0000 
L00006acc                       dc.w    $0101
L00006ace                       dc.w    $0202 
L00006ad0                       dc.w    $0303
L00006ad2                       dc.w    $0401 
L00006ad4                       dc.w    $0301
L00006ad6                       dc.w    $0201 
L00006ad8                       dc.w    $0101
L00006ada                       dc.w    $0301 
L00006adc                       dc.w    $0201
L00006ade                       dc.w    $0201
L00006ae0                       dc.w    $0102 
L00006ae2                       dc.w    $0201
L00006ae4                       dc.w    $0102
L00006ae6                       dc.w    $0103 
L00006ae8                       dc.w    $0104 
L00006aea                       dc.w    $0201 
L00006aec                       dc.w    $0101
L00006aee                       dc.w    $0102
L00006af0                       dc.w    $0102
L00006af2                       dc.w    $0101
L00006af4                       dc.w    $0102
L00006af6                       dc.w    $0102
L00006af8                       dc.w    $0104
L00006afa                       dc.w    $0102
L00006afc                       dc.w    $0104
L00006afe                       dc.w    $0104
L00006b00                       dc.w    $0106


L00006b02                       lea.l   L00008d3c,a0
L00006b08                       lea.l   L00006ae2,a1
L00006b0e                       lea.l   L00006ab2-1,a2          ; rts $4e75 ($75)
L00006b14                       move.w  #$0140,d7
L00006b18                       bsr.b   L00006b4a
L00006b1a                       move.w  $0006(a0),d0
L00006b1e                       move.w  d0,-(a7)
L00006b20                       lea.l   L00008d4c,a0
L00006b26                       lea.l   L00006aca,a1
L00006b2c                       lea.l   L00006ac1,a2
L00006b32                       move.w  #$0140,d7
L00006b36                       bsr.b   L00006b4a
L00006b38                       move.w  (a7)+,d0
L00006b3a                       sub.w   #$0058,d0
L00006b3e                       asr.w   #$01,d0
L00006b40                       add.w   #$006e,d0
L00006b44                       move.w  d0,$0006(a0)
L00006b48                       rts  


L00006b4a                       move.w  L00008f6e,d0
L00006b50                       bne.b   L00006b54
L00006b52                       rts  


L00006b54                       tst.w   $000e(a0)
L00006b58                       beq.w   L00006b98
L00006b5c                       subq.w  #$01,$000c(a0)
L00006b60                       bne.b   L00006b98
L00006b62                       lsr.w   #$05,d0
L00006b64                       and.w   #$00fe,d0
L00006b68                       add.w   $000a(a0),d0
L00006b6c                       moveq   #$00,d1
L00006b6e                       move.b  $00(a1,d0.w),d1
L00006b72                       move.w  d1,$000c(a0)
L00006b76                       move.b  $01(a1,d0.w),d1
L00006b7a                       tst.w   $000e(a0)
L00006b7e                       bmi.w   L00006b84
L00006b82                       neg.w   d1
L00006b84                       add.w   $0008(a0),d1
L00006b88                       bpl.b   L00006b8e
L00006b8a                       add.w   d7,d1
L00006b8c                       bra.b   L00006b94

L00006b8e                       cmp.w   d7,d1
L00006b90                       bcs.b   L00006b94
L00006b92                       sub.w   d7,d1
L00006b94                       move.w  d1,$0008(a0)
L00006b98                       move.w  $0002(a0),d0
L00006b9c                       beq.b   L00006bd8
L00006b9e                       bpl.b   L00006ba2
L00006ba0                       neg.w   d0
L00006ba2                       move.b  $00(a2,d0.w),d0
L00006ba6                       move.w  L00009078,d1
L00006bac                       sub.w   $0004(a0),d1
L00006bb0                       beq.b   L00006bd8
L00006bb2                       moveq   #$00,d2
L00006bb4                       move.w  d2,d3
L00006bb6                       sub.b   d0,d1
L00006bb8                       bcs.b   L00006bc0
L00006bba                       addq.w  #$01,d2
L00006bbc                       add.w   d0,d3
L00006bbe                       bra.b   L00006bb6


L00006bc0                       tst.w   d2
L00006bc2                       beq.b   L00006bd8
L00006bc4                       add.w   d2,$0000(a0)
L00006bc8                       tst.w   $0002(a0)
L00006bcc                       bpl.b   L00006bd0
L00006bce                       neg.w   d2
L00006bd0                       add.w   d2,$0006(a0)
L00006bd4                       add.w   d3,$0004(a0)
L00006bd8                       rts 


L00006bda                       lea.l   current_road_section_256_bytes,a6           ; L00008f74,a6
L00006be0                       lea.l   L00008d3c,a0
L00006be6                       lea.l   L00006ae2,a2
L00006bec                       lea.l   L00006ab9,a3
L00006bf2                       bsr.w   L00006cbc
L00006bf6                       lea.l   L00008d4c,a0
L00006bfc                       lea.l   L00006aca,a2
L00006c02                       lea.l   L00006ac9,a3
L00006c08                       bsr.w   L00006cbc
L00006c0c                       lea.l   L00008d5c,a1
L00006c12                       move.w  $000e(a1),d0
L00006c16                       bpl.b   L00006c1a
L00006c18                       neg.w   d0
L00006c1a                       sub.w   $000c(a1),d0
L00006c1e                       bcs.b   L00006c36
L00006c20                       beq.b   L00006c36
L00006c22                       move.w  d0,d1
L00006c24                       mulu.w  #$0003,d0
L00006c28                       add.w   d1,d0
L00006c2a                       tst.w   $000e(a1)
L00006c2e                       bpl.b   L00006c32
L00006c30                       neg.w   d0

L00006c32                       add.w   d0,$0034(a1)
L00006c36                       move.w  #$0000,$000a(a1)
L00006c3c                       move.w  #$0000,$000c(a1)
L00006c42                       move.w  $000e(a0),$000e(a1)
L00006c48                       move.w  L00009076,d0
L00006c4e                       add.b   #$21,d0
L00006c52                       moveq   #$00,d1
L00006c54                       move.b  $00(a6,d0.w),d0
L00006c58                       beq.b   L00006c62
L00006c5a                       moveq   #$05,d1
L00006c5c                       tst.b   d0
L00006c5e                       bmi.b   L00006c62
L00006c60                       moveq   #$0a,d1
L00006c62                       move.w  d1,$0016(a1)
L00006c66                       move.w  $001a(a1),d1
L00006c6a                       bpl.b   L00006cae
L00006c6c                       tst.b   d0
L00006c6e                       bmi.b   L00006cae
L00006c70                       neg.w   d1
L00006c72                       subq.w  #$02,d1
L00006c74                       bcs.b   L00006cae
L00006c76                       tst.w   $0018(a1)
L00006c7a                       bne.b   L00006cae
L00006c7c                       move.w  L00008f6e,d2
L00006c82                       lsr.w   #$07,d2
L00006c84                       not.w   d2
L00006c86                       addq.w  #$04,d2
L00006c88                       sub.w   d2,d1
L00006c8a                       bcs.b   L00006cae
L00006c8c                       beq.b   L00006cae
L00006c8e                       lsl.w   #$02,d1
L00006c90                       lea.l   L0000574c,a2
L00006c96                       lea.l   $00(a2,d1.w),a2
L00006c9a                       move.w  (a2)+,d1
L00006c9c                       move.w  (a2),$0018(a1)
L00006ca0                       lea.l   L00005728,a2
L00006ca6                       lea.l   $00(a2,d1.w),a2
L00006caa                       move.l  a2,$001c(a1)
L00006cae                       tst.b   d0
L00006cb0                       bpl.b   L00006cb6
L00006cb2                       or.w    #$ff00,d0
L00006cb6                       move.w  d0,$001a(a1)
L00006cba                       rts  


L00006cbc                       move.w  $0000(a0),d0
L00006cc0                       move.w  $0002(a0),d1
L00006cc4                       beq.b   L00006cde
L00006cc6                       bpl.b   L00006cca
L00006cc8                       neg.w   d1
L00006cca                       move.b  $00(a3,d1.w),d1
L00006cce                       sub.w   d0,d1
L00006cd0                       beq.b   L00006cde
L00006cd2                       tst.w   $0002(a0)
L00006cd6                       bpl.b   L00006cda
L00006cd8                       neg.w   d1
L00006cda                       add.w   d1,$0006(a0)
L00006cde                       move.w  L00009076,d0
L00006ce4                       add.b   #$22,d0
L00006ce8                       moveq   #$00,d1
L00006cea                       move.w  d1,$0004(a0)
L00006cee                       move.w  d1,$0000(a0)
L00006cf2                       move.b  $00(a6,d0.w),d1
L00006cf6                       bpl.b   L00006cfc
L00006cf8                       or.w    #$ff00,d1
L00006cfc                       move.w  d1,$0002(a0)
L00006d00                       move.w  L00009076,d0
L00006d06                       move.b  $00(a6,d0.w),d0
L00006d0a                       bpl.b   L00006d10
L00006d0c                       or.w    #$ff00,d0
L00006d10                       move.w  d0,$000e(a0)
L00006d14                       tst.w   d0
L00006d16                       beq.b   L00006d3a
L00006d18                       bpl.b   L00006d1c
L00006d1a                       neg.w   d0
L00006d1c                       asl.w   #$02,d0
L00006d1e                       move.w  d0,$000a(a0)
L00006d22                       tst.w   $000c(a0)
L00006d26                       bne.b   L00006d3e
L00006d28                       move.w  L00008f6e,d1
L00006d2e                       lsr.w   #$05,d1
L00006d30                       and.w   #$00fe,d1
L00006d34                       add.w   d0,d1
L00006d36                       move.b  $00(a2,d1.w),d0
L00006d3a                       move.w  d0,$000c(a0)
L00006d3e                       rts 


L00006d40                       lea.l   L00007bc8,a1
L00006d46                       lea.l   L00007cc8,a2
L00006d4c                       lea.l   L00007dc8,a3
L00006d52                       lea.l   L00007ec8,a4
L00006d58                       lea.l   L00007fc8,a5
L00006d5e                       move.w  #$006f,d7
L00006d62                       move.w  (a1)+,d1
L00006d64                       move.w  (a5)+,d0
L00006d66                       sub.w   d1,d0
L00006d68                       asr.w   #$01,d0
L00006d6a                       move.w  d0,d2
L00006d6c                       add.w   d1,d0
L00006d6e                       move.w  d0,(a3)+
L00006d70                       move.w  d2,d1
L00006d72                       asr.w   #$01,d2
L00006d74                       add.w   d2,d0
L00006d76                       move.w  d0,(a4)+
L00006d78                       sub.w   d1,d0
L00006d7a                       move.w  d0,(a2)+
L00006d7c                       dbf.w   d7,L00006d62 
L00006d80                       rts  


L00006d82                       move.l  a4,d2
L00006d84                       sub.l   #L0000909e,d2
L00006d8a                       cmp.w   #$0015,d2
L00006d8e                       bcc.w   L00006e96
L00006d92                       lea.l   L00007a20,a1
L00006d98                       move.w  L00009078,d1
L00006d9e                       and.w   #$00e0,d1
L00006da2                       add.b   d2,d1
L00006da4                       move.w  d7,d3
L00006da6                       lsl.w   #$01,d3
L00006da8                       btst.l  #$0000,d0
L00006dac                       bne.b   L00006e12
L00006dae                       btst.l  #$0001,d0
L00006db2                       bne.b   L00006de4
L00006db4                       move.b  -$01(a1,d1.w),d1         ;$ff(a1,d1.w),d1
L00006db8                       lea.l   $0400(a5),a1
L00006dbc                       move.w  (a1),d0
L00006dbe                       add.w   d1,d0
L00006dc0                       move.w  $00(a1,d3.w),d3
L00006dc4                       cmp.w   #$0001,d2
L00006dc8                       bne.b   L00006ddc
L00006dca                       move.w  L00009078,d2
L00006dd0                       and.w   #$00e0,d2
L00006dd4                       lsr.w   #$02,d2
L00006dd6                       sub.w   d2,d0
L00006dd8                       lsr.w   #$02,d2
L00006dda                       sub.w   d2,d0
L00006ddc                       sub.w   d0,d3
L00006dde                       move.w  d3,d1
L00006de0                       bra.w   L00006e6e 


L00006de4                       move.b  $00(a1,d1.w),d1
L00006de8                       lea.l   $0400(a5),a1
L00006dec                       move.w  (a1),d0
L00006dee                       move.w  $00(a1,d3.w),d3
L00006df2                       add.w   d1,d3
L00006df4                       cmp.w   #$0001,d2
L00006df8                       bne.b   L00006e0c
L00006dfa                       move.w  L00009078,d2
L00006e00                       and.w   #$00e0,d2
L00006e04                       lsr.w   #$02,d2
L00006e06                       add.w   d2,d0
L00006e08                       lsr.w   #$02,d2
L00006e0a                       add.w   d2,d0
L00006e0c                       sub.w   d0,d3
L00006e0e                       move.w  d3,d1
L00006e10                       bra.b   L00006e6e


L00006e12                       btst.l  #$0001,d0
L00006e16                       bne.b   L00006e44
L00006e18                       move.w  (a5),d0
L00006e1a                       move.b  -$01(a1,d1.w),d1 ; $ff(a1,d1.w),d1
L00006e1e                       sub.w   d1,d0
L00006e20                       move.w  $00(a5,d3.w),d3
L00006e24                       cmp.w   #$0001,d2
L00006e28                       bne.b   L00006e3c
L00006e2a                       move.w  L00009078,d2
L00006e30                       and.w   #$00e0,d2
L00006e34                       lsr.w   #$02,d2
L00006e36                       add.w   d2,d0
L00006e38                       lsr.w   #$02,d2
L00006e3a                       add.w   d2,d0
L00006e3c                       sub.w   d0,d3
L00006e3e                       move.w  d3,d1
L00006e40                       movea.l a5,a1
L00006e42                       bra.b   L00006e6e


L00006e44                       move.w  (a5),d0
L00006e46                       move.w  $00(a5,d3.w),d3
L00006e4a                       move.b  $00(a1,d1.w),d1
L00006e4e                       sub.w   d1,d3
L00006e50                       cmp.w   #$0001,d2
L00006e54                       bne.b   L00006e68
L00006e56                       move.w  L00009078,d2
L00006e5c                       and.w   #$00e0,d2
L00006e60                       lsr.w   #$02,d2
L00006e62                       sub.w   d2,d0
L00006e64                       lsr.w   #$02,d2
L00006e66                       sub.w   d2,d0
L00006e68                       sub.w   d0,d3
L00006e6a                       move.w  d3,d1
L00006e6c                       movea.l a5,a1
L00006e6e                       cmp.w   #$0002,d7
L00006e72                       bcs.b   L00006ee0
L00006e74                       move.w  d7,d2
L00006e76                       subq.w  #$01,d2
L00006e78                       tst.w   d1
L00006e7a                       bpl.b   L00006eae
L00006e7c                       neg.w   d1
L00006e7e                       cmp.w   d1,d7
L00006e80                       bcs.b   L00006e98
L00006e82                       move.b  d7,d3
L00006e84                       lsr.b   #$01,d3
L00006e86                       add.b   d1,d3
L00006e88                       cmp.b   d7,d3
L00006e8a                       bcs.b   L00006e90
L00006e8c                       sub.b   d7,d3
L00006e8e                       subq.w  #$01,d0
L00006e90                       move.w  d0,(a1)+
L00006e92                       dbf.w   d2,L00006e86
L00006e96                       rts  


L00006e98                       moveq   #$00,d3
L00006e9a                       subq.w  #$01,d0
L00006e9c                       add.b   d7,d3
L00006e9e                       bcs.b   L00006ea4
L00006ea0                       cmp.b   d1,d3
L00006ea2                       bcs.b   L00006e9a
L00006ea4                       sub.b   d1,d3
L00006ea6                       move.w  d0,(a1)+
L00006ea8                       dbf.w   d2,L00006e9a
L00006eac                       rts     


L00006eae                       cmp.w   d1,d7
L00006eb0                       bcs.w   L00006eca
L00006eb4                       move.b  d7,d3
L00006eb6                       lsr.b   #$01,d3
L00006eb8                       add.b   d1,d3
L00006eba                       cmp.b   d7,d3
L00006ebc                       bcs.b   L00006ec2
L00006ebe                       sub.b   d7,d3
L00006ec0                       addq.w  #$01,d0
L00006ec2                       move.w  d0,(a1)+
L00006ec4                       dbf.w   d2,L00006eb8
L00006ec8                       rts  


L00006eca                       moveq   #$00,d3
L00006ecc                       addq.w  #$01,d0
L00006ece                       add.b   d7,d3
L00006ed0                       bcs.b   L00006ed6
L00006ed2                       cmp.b   d1,d3
L00006ed4                       bcs.b   L00006ecc
L00006ed6                       sub.b   d1,d3
L00006ed8                       move.w  d0,(a1)+
L00006eda                       dbf.w   d2,L00006ecc
L00006ede                       rts  


L00006ee0                       add.w   d1,d0
L00006ee2                       move.w  d0,(a1)+
L00006ee4                       rts 


L00006ee6                       movea.l display_buffer2_ptr,a0                  ; L000037c4,a0
L00006eec                       move.l  a0,$00dff054
L00006ef2                       move.w  #$0000,$00dff066
L00006efa                       move.w  #$ffff,$00dff070
L00006f02                       move.w  #$01aa,$00dff040
L00006f0a                       move.w  #$0000,$00dff042
L00006f12                       move.w  #$2614,$00dff058
L00006f1a                       rts 


L00006f1c                       movea.l display_buffer2_ptr,a0                  ; L000037c4,a0
L00006f22                       lea.l   $2f80(a0),a0
L00006f26                       lea.l   L0000909f,a4
L00006f2c                       lea.l   L00007bc8,a5
L00006f32                       moveq   #$00,d5
L00006f34                       move.l  #$00000130,d6
L00006f3a                       moveq   #$60,d7
L00006f3c                       sub.b   (a4),d7
L00006f3e                       lea.l   current_road_section_256_bytes,a2   ; L00008f74,a2
L00006f44                       move.w  L00009076,d4
L00006f4a                       move.w  d4,d0
L00006f4c                       move.w  d4,d1
L00006f4e                       add.b   #$80,d4
L00006f52                       and.w   #$0001,d0
L00006f56                       move.w  d0,L00008f68
L00006f5c                       and.w   #$0002,d1
L00006f60                       lsr.w   #$01,d1
L00006f62                       move.w  d1,L00008f6a
L00006f68                       move.w  #$0002,L00008f6c
L00006f70                       tst.w   L00008f6a
L00006f76                       movea.l a0,a3
L00006f78                       bne.b   L00006f7e
L00006f7a                       lea.l   $2f80(a0),a3
L00006f7e                       move.b  $00(a2,d4.w),d0
L00006f82                       and.w   #$000f,d0
L00006f86                       beq.b   L00006fa0
L00006f88                       btst.l  #$0003,d0
L00006f8c                       beq.b   L00006f9a
L00006f8e                       and.l   #$00000003,d0
L00006f94                       swap.w  d0
L00006f96                       or.l    d0,d5
L00006f98                       bra.b   L00006fa6


L00006f9a                       bsr.w   L00006d82
L00006f9e                       movea.l a0,a3
L00006fa0                       and.l   #$0000ffff,d5
L00006fa6                       subq.b  #$01,d7
L00006fa8                       moveq   #$00,d0
L00006faa                       move.l  d0,d1
L00006fac                       move.l  d0,d2
L00006fae                       move.l  d0,d3
L00006fb0                       movem.l d0-d3,-(a0)
L00006fb4                       movem.l d0-d3,-(a0)
L00006fb8                       movem.l d0-d1,-(a0)
L00006fbc                       lea.l   $17e8(a0),a1
L00006fc0                       movem.l d0-d3,-(a1)
L00006fc4                       movem.l d0-d3,-(a1)
L00006fc8                       movem.l d0-d1,-(a1)
L00006fcc                       lea.l   $17e8(a1),a1
L00006fd0                       movem.l d0-d3,-(a1)
L00006fd4                       movem.l d0-d3,-(a1)
L00006fd8                       movem.l d0-d1,-(a1)

L00006fdc                       lea.l   -$0028(a3),a3
L00006fe0                       move.w  (a5)+,d1
L00006fe2                       btst.l  #$0010,d5
L00006fe6                       bne.b   L00007008
L00006fe8                       cmp.w   d6,d1
L00006fea                       bcc.b   L00007008
L00006fec                       move.w  d1,d0
L00006fee                       lsl.w   #$02,d0
L00006ff0                       and.w   #$003c,d0
L00006ff4                       or.w    d5,d0
L00006ff6                       lsr.w   #$03,d1
L00006ff8                       bclr.l  #$0000,d1
L00006ffc                       lea.l   L0000994e,a6
L00007002                       move.l  $00(a6,d0.w),$00(a3,d1.w)
L00007008                       tst.w   L00008f6a
L0000700e                       bne.w   L00007082
L00007012                       tst.w   L00008f68
L00007018                       bne.w   L00007082
L0000701c                       lea.l   L00009a8e,a6
L00007022                       move.w  $00fe(a5),d1
L00007026                       cmp.w   d6,d1
L00007028                       bcc.b   L00007042
L0000702a                       move.w  d1,d0
L0000702c                       lsl.w   #$02,d0
L0000702e                       and.w   #$003c,d0
L00007032                       or.w    d5,d0
L00007034                       lsr.w   #$03,d1
L00007036                       bclr.l  #$0000,d1
L0000703a                       move.l  $00(a6,d0.w),d0
L0000703e                       or.l    d0,$00(a0,d1.w)
L00007042                       move.w  $01fe(a5),d1

L00007046                       cmp.w   d6,d1
L00007048                       bcc.b   L00007062
L0000704a                       move.w  d1,d0
L0000704c                       lsl.w    #$02,d0
L0000704e                       and.w   #$003c,d0
L00007052                       or.w    d5,d0
L00007054                       lsr.w   #$03,d1
L00007056                       bclr.l  #$0000,d1
L0000705a                       move.l  $00(a6,d0.w),d0
L0000705e                       or.l    d0,$00(a0,d1.w)
L00007062                       move.w  $02fe(a5),d1
L00007066                       cmp.w   d6,d1
L00007068                       bcc.b   L00007082
L0000706a                       move.w  d1,d0
L0000706c                       lsl.w   #$02,d0
L0000706e                       and.w   #$003c,d0
L00007072                       or.w    d5,d0
L00007074                       lsr.w   #$03,d1
L00007076                       bclr.l  #$0000,d1
L0000707a                       move.l  $00(a6,d0.w),d0
L0000707e                       or.l    d0,$00(a0,d1.w)
L00007082                       btst.l  #$0011,d5
L00007086                       bne.b   L000070ae
L00007088                       move.w  $03fe(a5),d1
L0000708c                       cmp.w   d6,d1
L0000708e                       bcc.b   L000070ae
L00007090                       move.w  d1,d0
L00007092                       lsl.w   #$02,d0
L00007094                       and.w   #$003c,d0
L00007098                       or.w    d5,d0
L0000709a                       lsr.w   #$03,d1
L0000709c                       bclr.l  #$0000,d1
L000070a0                       lea.l   L0000994e,a6
L000070a6                       move.l  $00(a6,d0.w),d0
L000070aa                       or.l    d0,$00(a3,d1.w)
L000070ae                       add.l   #$00010000,d6
L000070b4                       dbf.w   d7,L00006fa8

L000070b8                       not.w   d7
L000070ba                       bra.b   L000070be
L000070bc                       addq.w  #$02,a5
L000070be                       bsr.b   L000070f4
L000070c0                       addq.b  #$01,d4
L000070c2                       move.b  (a4)+,d7
L000070c4                       sub.b   (a4),d7
L000070c6                       beq.b   L000070bc
L000070c8                       bpl.b   L000070ea
L000070ca                       bsr.b   L000070f4
L000070cc                       move.b  (a4)+,d0
L000070ce                       sub.b   (a4),d0
L000070d0                       cmp.b   #$e0,d0
L000070d4                       bcc.b   L000070dc
L000070d6                       cmp.b   #$50,d0
L000070da                       bcc.b   L00007122
L000070dc                       addq.w  #$02,a5
L000070de                       addq.b  #$01,d4
L000070e0                       add.b   d0,d7
L000070e2                       beq.b   L000070ca
L000070e4                       bmi.b   L000070ca
L000070e6                       bra.w   L00006f70
L000070ea                       cmp.b   #$50,d7
L000070ee                       bcs.w   L00006f70
L000070f2                       bra.b   L00007122
L000070f4                       eor.w   #$0001,L00008f68
L000070fc                       bne.b   L00007106
L000070fe                       eor.w   #$0001,L00008f6a
L00007106                       subq.w  #$01,L00008f6c
L0000710c                       bne.b   L00007120
L0000710e                       move.w  #$0003,L00008f6c 
L00007116                       cmp.w   #$0100,d5
L0000711a                       bcc.b   L00007120
L0000711c                       add.w   #$0040,d5
L00007120                       rts 


L00007122                       swap.w  d6
L00007124                       move.w  d6,L00008d3a                    ; horizon position
L0000712a                       movem.l d6/a0,-(a7)
L0000712e                       lea.l   DATA_OFFSET_1,a4                ; $00024b00,a4  ; DATA.IFF - (offset $4b04 = $24b00 - $1fffc ) external address
L00007134                       lea.l   L00008d4c,a5
L0000713a                       move.w  #$0020,d7
L0000713e                       move.w  $0006(a5),d0
L00007142                       bmi.w   L00007276
L00007146                       sub.w   d6,d0
L00007148                       beq.b   L00007174
L0000714a                       bcs.b   L0000716c
L0000714c                       add.w   d0,d6
L0000714e                       subq.w  #$01,d0
L00007150                       moveq   #$00,d1
L00007152                       move.l  d1,d2
L00007154                       move.l  d1,d3
L00007156                       move.l  d1,d4
L00007158                       move.l  d1,d5
L0000715a                       lea.l   -$17c0(a0),a0
L0000715e                       movem.l d1-d5,-(a0)
L00007162                       movem.l d1-d5,-(a0)
L00007166                       dbf.w   d0,L0000715e
L0000716a                       bra.b   L00007174
L0000716c                       add.w   d7,d0
L0000716e                       beq.w   L00007276
L00007172                       move.w  d0,d7
L00007174                       add.w   d7,d6
L00007176                       sub.w   #$0098,d6
L0000717a                       bcs.b   L00007188
L0000717c                       sub.w   d6,d7
L0000717e                       mulu.w  #$0050,d6

L00007182                       lea.l   $00(a4,d6.w),a4
L00007186                       moveq   #$00,d6
L00007188                       movea.l display_buffer2_ptr,a0                  ; L000037c4,a0
L0000718e                       lea.l   -$0002(a0),a0
L00007192                       neg.w   d6
L00007194                       beq.b   L000071a2
L00007196                       move.w  d6,d0
L00007198                       lsl.w   #$02,d0
L0000719a                       add.w   d6,d0
L0000719c                       lsl.w   #$03,d0
L0000719e                       lea.l   $00(a0,d0.w),a0
L000071a2                       lsl.w   #$06,d7
L000071a4                       move.w  d7,d6
L000071a6                       or.w    #$0015,d7
L000071aa                       move.w  $0008(a5),d0
L000071ae                       move.w  d0,d1
L000071b0                       and.w   #$000f,d0
L000071b4                       move.w  d0,d2
L000071b6                       ror.w   #$04,d0
L000071b8                       or.w    #$0b0a,d0
L000071bc                       move.w  d0,$00dff040
L000071c2                       move.w  #$0000,$00dff042
L000071ca                       lsl.w   #$01,d2

L000071cc                       lea.l   blitter_last_word_masks,a1      ; L00004f8c,a1
L000071d2                       move.w  $00(a1,d2.w),$00dff046
L000071da                       move.w  $20(a1,d2.w),$00dff044
L000071e2                       and.w   #$fff0,d1
L000071e6                       lsr.w   #$03,d1
L000071e8                       neg.w   d1
L000071ea                       add.w   #$0028,d1

L000071ee                       lea.l   -$02(a4,d1.w),a4                ; $fe
L000071f2                       move.w  #$0026,$00dff064
L000071fa                       move.w  #$fffe,$00dff060
L00007202                       move.w  #$fffe,$00dff066
L0000720a                       move.l  a4,$00dff050
L00007210                       move.l  a0,$00dff054
L00007216                       move.l  a0,$00dff048
L0000721c                       move.w  d7,$00dff058
L00007222                       move.w  $00dff002,d1
L00007228                       btst.l  #$000e,d1
L0000722c                       bne.b   L00007222
L0000722e                       lea.l   $0026(a0),a0
L00007232                       lea.l   $0026(a4),a4
L00007236                       move.w  #$004c,$00dff064
L0000723e                       move.w  #$0024,$00dff060
L00007246                       move.w  #$0024,$00dff066
L0000724e                       move.l  a4,$00dff050
L00007254                       move.l  a0,$00dff048
L0000725a                       move.l  a0,$00dff054
L00007260                       or.w    #$0002,d6
L00007264                       move.w  d6,$00dff058
L0000726a                       move.w  $00dff002,d0
L00007270                       btst.l  #$000e,d0
L00007274                       bne.b   L0000726a
L00007276                       movem.l (a7)+,d6/a0

L0000727a                       lea.l   DATA_OFFSET_0,a4        ; $00020000,a4 - DATA.IFF - external address
L00007280                       lea.l   L00008d3c,a5
L00007286                       move.w  #$0030,d7
L0000728a                       move.w  $0006(a5),d0
L0000728e                       bmi.w   L00007498
L00007292                       sub.w   d6,d0
L00007294                       bcc.b   L000072a2
L00007296                       add.w   d7,d0
L00007298                       beq.w   L00007498
L0000729c                       bcc.w   L00007498
L000072a0                       move.w  d0,d7
L000072a2                       add.w   d7,d6
L000072a4                       sub.w   #$0098,d6
L000072a8                       bcs.b   L000072b4
L000072aa                       sub.w   d6,d7
L000072ac                       mulu.w  #$0050,d6
L000072b0                       adda.w  d6,a4
L000072b2                       moveq   #$00,d6
L000072b4                       movea.l display_buffer2_ptr,a0                  ; L000037c4,a0
L000072ba                       lea.l   -$0002(a0),a0
L000072be                       neg.w   d6
L000072c0                       move.w  d6,-(a7)
L000072c2                       beq.b   L000072d0
L000072c4                       move.w  d6,d0
L000072c6                       lsl.w   #$02,d0
L000072c8                       add.w   d6,d0
L000072ca                       lsl.w   #$03,d0
L000072cc                       lea.l   $00(a0,d0.w),a0
L000072d0                       lsl.w   #$06,d7
L000072d2                       move.w  d7,d6
L000072d4                       or.w    #$0015,d7
L000072d8                       move.w  $0008(a5),d0
L000072dc                       move.w  d0,d1
L000072de                       and.w   #$000f,d0
L000072e2                       move.w  d0,d2
L000072e4                       ror.w   #$04,d0
L000072e6                       move.w  d0,d5
L000072e8                       move.w  d0,$00dff042
L000072ee                       or.w    #$0fca,d0
L000072f2                       move.w  d0,$00dff040
L000072f8                       lsl.w   #$01,d2

L000072fa                       lea.l   blitter_word_masks,a1           ; L00004f8c,a1
L00007300                       move.w  $00(a1,d2.w),$00dff046
L00007308                       move.w  $20(a1,d2.w),$00dff044

L00007310                       and.w   #$fff0,d1
L00007314                       lsr.w   #$03,d1
L00007316                       neg.w   d1
L00007318                       add.w   #$0028,d1
L0000731c                       lea.l   -$02(a4,d1.w),a4        ; $fe
L00007320                       movea.l a4,a5
L00007322                       move.w  #$0026,$00dff064
L0000732a                       move.w  #$0026,$00dff062
L00007332                       move.w  #$fffe,$00dff060
L0000733a                       move.w  #$fffe,$00dff066
L00007342                       lea.l   $0f00(a5),a5
L00007346                       move.l  a4,$00dff050
L0000734c                       move.l  a5,$00dff04c
L00007352                       move.l  a0,$00dff048
L00007358                       move.l  a0,$00dff054
L0000735e                       move.w  d7,$00dff058
L00007364                       move.w  $00dff002,d1
L0000736a                       btst.l  #$000e,d1
L0000736e                       bne.b   L00007364
L00007370                       move.w  #$004c,$00dff064
L00007378                       move.w  #$004c,$00dff062
L00007380                       move.w  #$0024,$00dff060
L00007388                       move.w  #$0024,$00dff066

L00007390                       lea.l   $0026(a4),a4
L00007394                       move.l  a4,$00dff050
L0000739a                       lea.l   $0026(a5),a1
L0000739e                       move.l  a1,$00dff04c
L000073a4                       lea.l   $0026(a0),a1
L000073a8                       move.l  a1,$00dff048
L000073ae                       move.l  a1,$00dff054
L000073b4                       or.w    #$0002,d6
L000073b8                       move.w  d6,$00dff058
L000073be                       move.w  $00dff002,d1
L000073c4                       btst.l  #$000e,d1
L000073c8                       bne.b   L000073be
L000073ca                       or.w    #$09f0,d5
L000073ce                       move.w  d5,$00dff040
L000073d4                       move.w  #$0026,$00dff064
L000073dc                       move.w  #$fffe,$00dff066
L000073e4                       moveq   #$02,d4
L000073e6                       lea.l   $0f00(a5),a5
L000073ea                       move.l  a5,$00dff050
L000073f0                       lea.l   $17c0(a0),a0
L000073f4                       move.l  a0,$00dff054
L000073fa                       move.w  d7,$00dff058
L00007400                       move.w  $00dff002,d1
L00007406                       btst.l  #$000e,d1
L0000740a                       bne.b   L00007400
L0000740c                       dbf.w   d4,L000073e6
L00007410                       move.w  d0,$00dff040
L00007416                       move.w  #$004c,$00dff064
L0000741e                       move.w  #$0024,$00dff066

L00007426                       lea.l   -$2cda(a5),a5
L0000742a                       moveq   #$02,d4
L0000742c                       lea.l   $0f00(a5),a5
L00007430                       move.l  a4,$00dff050
L00007436                       move.l  a5,$00dff04c
L0000743c                       lea.l   $17c0(a1),a1
L00007440                       move.l  a1,$00dff048
L00007446                       move.l  a1,$00dff054
L0000744c                       move.w  d6,$00dff058
L00007452                       move.w  $00dff002,d1
L00007458                       btst.l  #$000e,d1
L0000745c                       bne.b   L00007452
L0000745e                       dbf.w   d4,L0000742c
L00007462                       move.w  (a7)+,d6
L00007464                       beq.b   L00007496
L00007466                       subq.w  #$01,d6
L00007468                       moveq   #$00,d1
L0000746a                       move.l  d1,d2
L0000746c                       move.l  d1,d3
L0000746e                       move.l  d1,d4
L00007470                       move.l  d1,d5
L00007472                       lea.l   -$17c0(a0),a1
L00007476                       lea.l   -$17c0(a1),a2
L0000747a                       movem.l d1-d5,-(a0)
L0000747e                       movem.l d1-d5,-(a0)
L00007482                       movem.l d1-d5,-(a1)
L00007486                       movem.l d1-d5,-(a1)
L0000748a                       movem.l d1-d5,-(a2)
L0000748e                       movem.l d1-d5,-(a2)
L00007492                       dbf.w   d6,L0000747a
L00007496                       rts 


L00007498                       lea.l   $2f80(a0),a0
L0000749c                       sub.w   #$0098,d6
L000074a0                       neg.w   d6
L000074a2                       bra.b   L00007466



                                ; 
                                ; take high word from a1. 18 times
                                ; ^   take loop 16 times, 
                                ; |    ^  - store long into a0+
                                ; |    |  - shift left 1 bit
                                ; |    |        |
                                ; |    +--------+
                                ; |             |
                                ; +-------------+
                                ;
preshift_18_words       ; original address $000074a4
L000074a4                       lea.l   L0000994e,a0
L000074aa                       lea.l   L00009dce,a1
L000074b0                       moveq   #$11,d7                 ; 17 + 1 - outer loop
L000074b2                       moveq   #$00,d0
L000074b4                       move.w  (a1)+,d0
L000074b6                       swap.w  d0
L000074b8                       moveq   #$0f,d6                 ; 15 + 1 - inner loop
L000074ba                       move.l  d0,(a0)+                ; store pre-shifted long word
L000074bc                       lsr.l   #$01,d0
L000074be                       dbf.w   d6,L000074ba
L000074c2                       dbf.w   d7,L000074b2
L000074c6                       rts 





L000074c8                       move.w  L00009074,d5
L000074ce                       move.w  d5,-(a7)
L000074d0                       lea.l   L00007fc8,a5
L000074d6                       bsr.w   L000074e6
L000074da                       move.w  (a7)+,d5
L000074dc                       sub.w   #$01a9,d5
L000074e0                       lea.l   L00007bc8,a5
L000074e6                       lea.l   current_road_section_256_bytes,a0           ; L00008f74,a0
L000074ec                       move.w  L00009076,d6
L000074f2                       move.b  $00(a0,d6.w),d2
L000074f6                       move.w  L00009078,d1
L000074fc                       and.b   #$e0,d1
L00007500                       lea.l   L00007920,a1
L00007506                       adda.w  d1,a1
L00007508                       bsr.w   L00007704
L0000750c                       neg.b   d0
L0000750e                       add.b   #$80,d0
L00007512                       and.w   #$00fe,d0
L00007516                       lea.l   L00007720,a2
L0000751c                       lea.l   L000090b6,a3
L00007522                       moveq   #$15,d7
L00007524                       move.w  d5,d1
L00007526                       add.b   $00(a0,d6.w),d0
L0000752a                       addq.b  #$01,d6
L0000752c                       moveq   #$00,d2
L0000752e                       move.w  $00(a2,d0.w),d4
L00007532                       sub.w   d1,d4
L00007534                       add.w   #$001e,d4
L00007538                       ext.l   d4

L0000753a                       move.b  (a1)+,d3
L0000753c                       lsl.b   #$01,d3
L0000753e                       bcc.b   L00007544
L00007540                       move.l  d4,d2
L00007542                       asl.l   #$01,d2
L00007544                       asl.b   #$01,d3
L00007546                       bcc.b   L0000754a
L00007548                       add.l   d4,d2
L0000754a                       asl.l   #$01,d2
L0000754c                       asl.b   #$01,d3
L0000754e                       bcc.b   L00007552
L00007550                       add.l   d4,d2
L00007552                       asl.l   #$01,d2
L00007554                       asl.b   #$01,d3
L00007556                       bcc.b   L0000755a
L00007558                       add.l   d4,d2
L0000755a                       asl.l   #$01,d2
L0000755c                       asl.b   #$01,d3
L0000755e                       bcc.b   L00007562
L00007560                       add.l   d4,d2
L00007562                       asl.l   #$01,d2
L00007564                       asl.b   #$01,d3
L00007566                       bcc.b   L0000756a
L00007568                       add.l   d4,d2
L0000756a                       asl.l   #$01,d2
L0000756c                       asl.b   #$01,d3
L0000756e                       bcc.b   L00007572
L00007570                       add.l   d4,d2
L00007572                       asr.l   #$01,d2
L00007574                       asr.l   #$08,d2
L00007576                       move.b  d2,(a3)+
L00007578                       add.w   d2,d1
L0000757a                       asr.w   #$08,d2
L0000757c                       move.b  d2,$0015(a3)
L00007580                       dbf.w   d7,L00007526

L00007584                       lea.l   L0000909e,a1
L0000758a                       moveq   #$14,d7
L0000758c                       moveq   #$00,d1
L0000758e                       move.w  d1,d2
L00007590                       subq.b  #$02,d2
L00007592                       add.b   (a1)+,d2
L00007594                       sub.b   (a1),d2
L00007596                       bmi.w   L00007628
L0000759a                       addq.b  #$02,d2
L0000759c                       move.b  d2,$005a(a1)
L000075a0                       sub.b   d1,d2
L000075a2                       move.b  d2,d1
L000075a4                       subq.b  #$01,d1
L000075a6                       move.b  $002d(a1),d3
L000075aa                       bpl.b   L000075ea
L000075ac                       move.b  $0017(a1),d3
L000075b0                       neg.b   d3
L000075b2                       cmp.b   d3,d2
L000075b4                       bcs.b   L000075d0
L000075b6                       move.b  d2,d4
L000075b8                       lsr.b   #$01,d4
L000075ba                       add.b   d3,d4
L000075bc                       cmp.b   d2,d4
L000075be                       bcs.b   L000075c4
L000075c0                       sub.b   d2,d4
L000075c2                       subq.w  #$01,d5
L000075c4                       move.w  d5,(a5)+
L000075c6                       dbf.w   d1,L000075ba
L000075ca                       dbf.w   d7,L0000758c
L000075ce                       rts  


L000075d0                       moveq   #$00,d4
L000075d2                       subq.w  #$01,d5
L000075d4                       add.b   d2,d4
L000075d6                       bcs.b   L000075dc
L000075d8                       cmp.b   d3,d4
L000075da                       bcs.b   L000075d2
L000075dc                       sub.b   d3,d4
L000075de                       move.w  d5,(a5)+
L000075e0                       dbf.w   d1,L000075d2
L000075e4                       dbf.w   d7,L0000758c
L000075e8                       rts 



L000075ea                       move.b  $0017(a1),d3
L000075ee                       cmp.b   d3,d2
L000075f0                       bcs.w   L0000760e
L000075f4                       move.b  d2,d4
L000075f6                       lsr.b   #$01,d4
L000075f8                       add.b   d3,d4
L000075fa                       cmp.b   d2,d4
L000075fc                       bcs.b   L00007602
L000075fe                       sub.b   d2,d4
L00007600                       addq.w  #$01,d5
L00007602                       move.w  d5,(a5)+
L00007604                       dbf.w   d1,L000075f8
L00007608                       dbf.w   d7,L0000758c
L0000760c                       rts


L0000760e                       moveq   #$00,d4
L00007610                       addq.w  #$01,d5
L00007612                       add.b   d2,d4
L00007614                       bcs.b   L0000761a
L00007616                       cmp.b   d3,d4
L00007618                       bcs.b   L00007610
L0000761a                       sub.b   d3,d4
L0000761c                       move.w  d5,(a5)+
L0000761e                       dbf.w   d1,L00007610
L00007622                       dbf.w   d7,L0000758c
L00007626                       rts


L00007628                       move.b  #$01,$005a(a1)
L0000762e                       addq.b  #$01,d2
L00007630                       beq.b   L00007634
L00007632                       addq.b  #$01,d2
L00007634                       move.w  d2,d1
L00007636                       move.b  $002d(a1),d2
L0000763a                       lsl.w   #$08,d2
L0000763c                       move.b  $0017(a1),d2
L00007640                       add.w   d2,d5
L00007642                       move.w  d5,(a5)+
L00007644                       dbf.w   d7,L0000758e
L00007648                       rts 


L0000764a                       lea.l   current_road_section_256_bytes,a0           ; L00008f74,a0
L00007650                       move.w  L00009076,d6
L00007656                       add.b   #$20,d6
L0000765a                       move.b  $00(a0,d6.w),d2
L0000765e                       move.w  L00009078,d1
L00007664                       and.b   #$e0,d1
L00007668                       lea.l   L00007821,a1
L0000766e                       adda.w  d1,a1
L00007670                       bsr.w   L00007704
L00007674                       neg.b   d0
L00007676                       moveq   #$14,d7

L00007678                       lea.l   L0000909f,a2
L0000767e                       moveq   #$00,d1
L00007680                       move.w  d1,d3
L00007682                       move.b  (a1),d1
L00007684                       asl.w   #$01,d1
L00007686                       add.b   $00(a0,d6.w),d0
L0000768a                       beq.b   L00007700
L0000768c                       move.b  d0,d2
L0000768e                       bpl.b   L00007694
L00007690                       neg.w   d1
L00007692                       neg.b   d2
L00007694                       add.b   d2,d2
L00007696                       add.b   d2,d2
L00007698                       bcc.b   L0000769e
L0000769a                       move.w  d1,d3
L0000769c                       asl.w   #$01,d3
L0000769e                       asl.b   #$01,d2
L000076a0                       bcc.b   L000076a4
L000076a2                       add.w   d1,d3
L000076a4                       asl.w   #$01,d3
L000076a6                       asl.b   #$01,d2
L000076a8                       bcc.b   L000076ac
L000076aa                       add.w   d1,d3
L000076ac                       asl.w   #$01,d3
L000076ae                       asl.b   #$01,d2
L000076b0                       bcc.b   L000076b4
L000076b2                       add.w   d1,d3
L000076b4                       asl.w   #$01,d3
L000076b6                       asl.b   #$01,d2
L000076b8                       bcc.b   L000076bc
L000076ba                       add.w   d1,d3
L000076bc                       asl.w   #$01,d3
L000076be                       asl.b   #$01,d2
L000076c0                       bcc.b   L000076c4
L000076c2                       add.w   d1,d3
L000076c4                       asl.w   #$01,d3
L000076c6                       asl.b   #$01,d2
L000076c8                       bcc.b   L000076cc
L000076ca                       add.w   d1,d3
L000076cc                       asr.w   #$07,d3
L000076ce                       add.b   (a1)+,d3
L000076d0                       move.b  d3,(a2)+
L000076d2                       addq.b  #$01,d6
L000076d4                       dbf.w   d7,L0000767e

L000076d8                       move.b  #$a0,(a2)
L000076dc                       lea.l   L000090e2,a0
L000076e2                       lea.l   L0000909f,a1
L000076e8                       move.w  #$0014,d7
L000076ec                       move.b  #$60,d1
L000076f0                       move.b  (a1)+,d2
L000076f2                       cmp.b   d1,d2
L000076f4                       bpl.b   L000076f8
L000076f6                       move.b  d2,d1
L000076f8                       move.b  d1,(a0)+
L000076fa                       dbf.w   d7,L000076f0 
L000076fe                       rts  


L00007700                       move.b  d0,d3
L00007702                       bra.b   L000076ce
L00007704                       moveq   #$02,d7
L00007706                       moveq   #$00,d0
L00007708                       rol.b   #$01,d1
L0000770a                       bcc.w   L00007710
L0000770e                       add.b   d2,d0
L00007710                       asl.b   #$01,d0
L00007712                       dbf.w   d7,L00007708
L00007716                       roxr.b  #$01,d0


L00007718                       asr.b   #$03,d0
L0000771a                       moveq   #$00,d7
L0000771c                       addx.b  d7,d0
L0000771e                       rts  



L00007720       dc.w    $0000,$ec22,$f653,$f9b9,$fb6c,$fc72,$fd21,$fd9e
L00007730       dc.w    $fdfd,$fe46,$fe81,$feb1,$feda,$fefd,$ff1a,$ff34
L00007740       dc.w    $ff4b,$ff5f,$ff71,$ff82,$ff91,$ff9e,$ffaa,$ffb6
L00007750       dc.w    $ffc0,$ffca,$ffd3,$ffdc,$ffe4,$ffec,$fff3,$fffa
L00007760       dc.w    $0000,$0006,$000c,$0012,$0017,$001c,$0021,$0026
L00007770       dc.w    $002a,$002f,$0033,$0037,$003c,$0040,$0043,$0047
L00007780       dc.w    $002b,$004f,$0052,$0056,$0059,$005d,$0060,$0063
L00007790       dc.w    $0067,$006a,$006d,$0070,$0073,$0077,$007a,$007d
L000077a0       dc.w    $0080,$0083,$0086,$0089,$008d,$0090,$0093,$0096
L000077b0       dc.w    $0099,$009d,$00a0,$00a3,$00a7,$00aa,$00ae,$00b1
L000077c0       dc.w    $00b5,$00b9,$00bd,$00c0,$00c4,$00c9,$00cd,$00d1
L000077d0       dc.w    $00d6,$00da,$00df,$00e4,$00e9,$00ee,$00f4,$00fa
L000077e0       dc.w    $0100,$0106,$010d,$0114,$011c,$0124,$012d,$0136
L000077f0       dc.w    $0140,$014a,$0156,$0162,$016f,$017e,$018f,$01a1
L00007800       dc.w    $01b5,$01cc,$01e6,$0203,$0226,$024f,$027f,$02ba
L00007810       dc.w    $0303,$0362,$03df,$048e,$0594,$0747,$0aad,$14de
L00007820       dc.b    $60
L00007821       dc.b    $4a
L00007822       dc.w    $3c32,$2b25,$211e,$1b18,$1615,$1312,$1110
L00007830       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L00007840       dc.w    $604c,$3d33,$2c26,$221e,$1b19,$1715,$1312,$1110
L00007850       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L00007860       dc.w    $604f,$3f34,$2d27,$221e,$1b19,$1715,$1412,$1110
L00007870       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L00007880       dc.w    $6051,$4135,$2d27,$231f,$1c19,$1715,$1412,$1110
L00007890       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L000078a0       dc.w    $6054,$4237,$2e28,$231f,$1c1a,$1716,$1413,$1110
L000078b0       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L000078c0       dc.w    $6057,$4438,$2f29,$2420,$1d1a,$1816,$1413,$1110
L000078d0       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L000078e0       dc.w    $6059,$4639,$3029,$2420,$1d1a,$1816,$1413,$1210
L000078f0       dc.w    $0f0e,$0d0c,$0b0a,$0000,$0000,$0000,$0000,$0000
L00007900       dc.w    $605d,$483b,$312a,$2521,$1d1a,$1816,$1413,$1211
L00007910       dc.w    $100f,$0e0d,$0c0a,$0000,$0000,$0000,$0000,$0000
L00007920       dc.w    $ebc1,$aa8f,$8e6e,$5d66,$7155,$2e61,$3538,$3c40
L00007930       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L00007940       dc.w    $d5ca,$a78c,$8b6b,$7866,$4b51,$5961,$3538,$3c40
L00007950       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L00007960       dc.w    $b5cf,$b389,$8883,$7866,$4b51,$5930,$6638,$3c40
L00007970       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L00007980       dc.w    $a0ca,$bd9a,$8869,$7563,$6d51,$5930,$6638,$3c40
L00007990       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L000079a0       dc.w    $80db,$aaa7,$8580,$7563,$4976,$2c5d,$336b,$3c40
L000079b0       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L000079c0       dc.w    $60df,$b5a4,$827c,$7160,$694e,$555d,$336b,$3c40
L000079d0       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L000079e0       dc.w    $4bdb,$bea1,$957c,$7160,$694e,$555d,$3335,$7140
L000079f0       dc.w    $4449,$4e55,$5d66,$0000,$0000,$0000,$0000,$0000
L00007a00       dc.w    $20e7,$b9ad,$9279,$6e7c,$694e,$555d,$3335,$383c
L00007a10       dc.w    $4044,$494e,$555d,$0000,$0000,$0000,$0000,$0000
L00007a20       dc.w    $5343,$3830,$2924,$211d,$1a18,$1614,$1312,$100f
L00007a30       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007a40       dc.w    $5644,$3931,$2a25,$211d,$1b19,$1614,$1312,$100f
L00007a50       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007a60       dc.w    $5947,$3a32,$2b26,$211d,$1b19,$1615,$1312,$100f
L00007a70       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007a80       dc.w    $5b49,$3b32,$2b26,$221e,$1b18,$1615,$1311,$100f
L00007a90       dc.w    $0e0c,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007aa0       dc.w    $5f4a,$3e33,$2c27,$221e,$1c19,$1715,$1412,$100f
L00007ab0       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007ac0       dc.w    $624d,$3f34,$2d28,$2320,$1c1a,$1715,$1412,$100f
L00007ad0       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007ae0       dc.w    $644f,$4036,$2e28,$2320,$1c1a,$1715,$1413,$100f
L00007af0       dc.w    $0e0d,$0b0a,$0000,$0000,$0000,$0000,$0000,$0000
L00007b00       dc.w    $6951,$4237,$2f29,$241f,$1c1a,$1715,$1413,$1110
L00007b10       dc.w    $0f0e,$0c0c,$0000,$0000,$0000,$0000,$0000,$0000





                        ; ----------------------- mirror sprite gfx ---------------------------
                        ; Appears to be a routine that creates mirror images of the level gfx.
                        ; looks like it mirrors 9 blocks of sprite data (maybe zoom levels?)
                        ;
                        ; IN:-
                        ;       a0 = Source Data Address Offset 1 
                        ;       a1 = Destination Data Address Offset 2 (mirrored gfx)
                        ;
mirror_sprite_gfx       ; original address $00007b20
L00007b20                       moveq   #$08,d7                 ; 8+1 outer loop count L00007b26_loop
L00007b22                       lea.l   $0090(a1),a2            ; a2 = source Data 2 offset + $90

                        ; ------ next sprite block ------ loop 9 times
L00007b26_loop
L00007b26                       move.w  d7,-(a7)                ; save outer loop couter - d7

L00007b28                       move.w  (a0)+,d0                ; d0 = source data word.
L00007b2a                       move.w  d0,(a1)+                ; copy 1st word source => dest

L00007b2c                       move.w  (a0)+,(a1)+             ; copy 2nd word source => dest

L00007b2e                       move.w  (a0)+,d1                ; d1 = 3rd word
L00007b30                       move.w  d1,(a1)+                ; copy 3rd word source => dest

L00007b32                       move.w  (a0)+,d7                ; d7 = 4th word (total byte size)
L00007b34                       move.w  d7,(a1)+                ; copy 4th word source => dest

L00007b36                       move.l  (a0)+,d2                ; d2 = 5th long
L00007b38                       move.l  d2,(a1)+                ; copy 5th long source => dest

L00007b3a                       move.l  (a0)+,(a1)+             ; copy 6th word source => dest

                                ; d0 = 1st word
                                ; d1 = 3rd word (bytes size total)
                                ; d7 = 4th word (lines high?)
                                ; d2 = 5th long (source data offset)
                                ;
L00007b3c                       lea.l   -$08(a0,d2.w),a3        ; a3 = calculated source data ptr

                                ; calc shift value
L00007b40                       and.w   #$000f,d0               ; clamp 0-15
L00007b44                       neg.w   d0                      ; invert d0 (-ve)
L00007b46                       beq.b   L00007b4e 
L00007b48                       add.w   #$000f,d0
L00007b4c                       addq.w  #$01,d0                 ; d0 = data shift value

                                ; total bytes for sprite incl. mask
L00007b4e                       mulu.w  #$0005,d7               ; 4 bitplanes + 1 mask
L00007b52                       subq.w  #$01,d7                 ; adjust loop counter

L00007b54                       move.w  d1,d5                   ; d5 = total byte size
L00007b56                       lsr.w   #$01,d5                 ; divide by 2 = total word size
L00007b58                       subq.w  #$01,d5                 ; subtract 1 to get loop counter


                        ; ----- do next sprite ----- 
L00007b5a_loop
L00007b5a                       lea.l   $00(a2,d1.w),a2         ; a2 = end gfx ptr
L00007b5e                       move.w  d5,d6                   ; total number of words
L00007b60                       moveq   #$00,d2


                        ;----- mirror next 16 bit word -----
L00007b62_loop                  
L00007b62                       move.w  (a3)+,d3                ; d3 = source word
L00007b64                       moveq   #$00,d4                 ; clear mirrored word
                                ; mirror bit 1
L00007b66                       lsr.w   #$01,d3
L00007b68                       roxl.w  #$01,d4
                                ; mirror bit 2
L00007b6a                       lsr.w   #$01,d3
L00007b6c                       roxl.w  #$01,d4
                                ; mirror bit 3
L00007b6e                       lsr.w   #$01,d3
L00007b70                       roxl.w  #$01,d4
                                ; mirror bit 4
L00007b72                       lsr.w   #$01,d3
L00007b74                       roxl.w  #$01,d4
                                ; mirror bit 5
L00007b76                       lsr.w   #$01,d3
L00007b78                       roxl.w  #$01,d4
                                ; mirror bit 6
L00007b7a                       lsr.w   #$01,d3
L00007b7c                       roxl.w  #$01,d4
                                ; mirror bit 7
L00007b7e                       lsr.w   #$01,d3
L00007b80                       roxl.w  #$01,d4
                                ; mirror bit 8
L00007b82                       lsr.w   #$01,d3
L00007b84                       roxl.w  #$01,d4
                                ; mirror bit 9
L00007b86                       lsr.w   #$01,d3
L00007b88                       roxl.w  #$01,d4
                                ; mirror bit 10
L00007b8a                       lsr.w   #$01,d3
L00007b8c                       roxl.w  #$01,d4
                                ; mirror bit 11
L00007b8e                       lsr.w   #$01,d3
L00007b90                       roxl.w  #$01,d4
                                ; mirror bit 12
L00007b92                       lsr.w   #$01,d3
L00007b94                       roxl.w  #$01,d4
                                ; mirror bit 13
L00007b96                       lsr.w   #$01,d3
L00007b98                       roxl.w  #$01,d4
                                ; mirror bit 14
L00007b9a                       lsr.w   #$01,d3
L00007b9c                       roxl.w  #$01,d4
                                ; mirror bit 15
L00007b9e                       lsr.w   #$01,d3
L00007ba0                       roxl.w  #$01,d4
                                ; mirror bit 16
L00007ba2                       lsr.w   #$01,d3
L00007ba4                       roxl.w  #$01,d4

L00007ba6                       tst.w   d0                      ; test shift value
L00007ba8                       beq.b   L00007bae               ; if shift = 0 then store & continue.
L00007baa                       lsl.l   d0,d4                   ; else, shift data by shift value in d0
L00007bac                       or.w    d2,d4                   ; or in any previously shifted data

L00007bae                       move.w  d4,-(a2)                ; store mirrored word
L00007bb0                       swap.w  d4                      ; get shifted data
L00007bb2                       move.w  d4,d2                   ; d2 = shifted data to be added to next word.

L00007bb4                       dbf.w   d6,L00007b62_loop       ; loop for total number of words
                                ; end of mirror single sprite.

L00007bb8                       lea.l   $00(a2,d1.w),a2         ; increment pointer by sprite size. (next sprite)
L00007bbc                       dbf.w   d7,L00007b5a_loop

L00007bc0                       move.w  (a7)+,d7
L00007bc2                       dbf.w  d7,L00007b26_loop                ; do 8 + 1 loops
L00007bc6                       rts  




L00007bc8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007bd8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007be8       dc.w    $0000,$0000,$0000,$0000,$0000
L00007bf2       dc.w    $0000,$0000,$0000
L00007bf8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c08       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c18       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c28       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c38       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c48       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c58       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c68       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c78       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c88       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007c98       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ca8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007cb8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007cc8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007cd8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ce8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007cf8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d08       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d18       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d28       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d38       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d48       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d58       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d68       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d78       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d88       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007d98       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007da8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007db8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007dc8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007dd8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007de8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007df8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e08       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e18       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e28       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e38       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e48       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e58       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e68       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e78       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e88       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007e98       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ea8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007eb8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ec8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ed8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ee8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007ef8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f08       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f18       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f28       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f38       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f48       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f58       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f68       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f78       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f88       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007f98       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007fa8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007fb8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007fc8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007fd8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00007fe8       dc.w    $0000,$0000,$0000,$0000,$0000
L00007ff2       dc.w    $0000,$0000,$0000
L00007ff8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008008       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008018       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008028       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008038       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008048       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008058       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008068       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008078       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008088       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008098       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080a8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080b8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080c8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080d8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080e8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000080f8       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008108       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008116       dc.w    $0000
L00008118       dc.w    $0000,$0000,$0000,$0000,$0000
L00008122       dc.w    $0000,$0000,$0000
L00008128       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008138       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00008148       dc.w    $0000,$0000,$0000,$0000,$0000
L00008152       dc.w    $0000,$0000,$0000






                ; ------------------------- initialise batmobile data ------------------------------
                ; some batmobile init routine (similar to below)
                ; 20 bytes stored per loop iteration
                ;    Iteration         Loops   Bytes Stores             StartAddress
                ;       1               4+1     (20*5)+20 = 120         $00008288
                ;       2               2+1     (20*3)+20 = 080
                ;       3               3+1     (20*4)+20 = 100
                ;       4               5+1     (20*6)+20 = 140
                ;       5               1+1     (20*2)+20 = 060
                ;       6               1+1     (20*2)+20 = 060
                ;       7               4+1     (20*5)+20 = 120
                ;       8               0+1     (20*1)+20 = 040
                ;       9               0+1     (20*1)+20 = 040
                ;       10              0+1     (20*1)+20 = 040
                ;                                   Total = 800
                ; these blocks of data may represent road sections or something similar.
                ; maybe the pre-calculated values are the sections with turns in the road?
                ;
                ;
initialise_batmobile_data       ; original address $00008158
L00008158                       lea.l   L00008272,a5            ; list of data counts (10 items)
L0000815e                       lea.l   L00008288,a0            ; 1st list of ptrs (populated by this routine) 17 entries?

L00008164                       lea.l   L000085a8,a1            ; list of 6 byte structure (16 entries)
L0000816a                       lea.l   L00008642,a2            ; list of ptrs (8 entries)
L00008170                       lea.l   L00008662,a3            ; list of 26 byte structure (8 entries)
L00008176                       lea.l   L00008732,a4            ; unknown data ptr (shared with batmobile)

L0000817c                       move.w  (a5)+,d7                ; loop counts (4,2,3,5,1,1,4,0,0,0,-1)
L0000817e                       bmi.b   L000081cc_exit          ; exit if negative value. L000081cc

                        ; create batch of 5 long ptrs to data
L00008180_loop          ; original address $00008180
L00008180                       bsr.w   L0000421a               ; d0 = randomish number
L00008184                       and.w   #$000f,d0               ; clamp 0-15
L00008188                       mulu.w  #$0006,d0               ; multiply by struct size (6 bytes)
L0000818c                       lea.l   $00(a1,d0.w),a6         ; a6 = address of random struct.
L00008190                       move.l  a6,(a0)+                ; -- store address ptr 1 --

L00008192                       bsr.w   L0000421a               ; d0 = randomish number
L00008196                       and.w   #$0007,d0               ; clamp 0-7
L0000819a                       lsl.w   #$02,d0                 ; multiply by 4 (ptr size)
L0000819c                       move.l  $00(a2,d0.w),(a0)+      ; -- store address ptr 2 --

L000081a0                       bsr.w   L0000421a               ; d0 = randomish number
L000081a4                       and.w   #$0007,d0               ; clamp 0-7
L000081a8                       mulu.w  #$001a,d0               ; multiply by struct size (26 bytes)
L000081ac                       lea.l   $00(a3,d0.w),a6         ; a6 = ptr to struct
L000081b0                       move.l  a6,(a0)+                ; -- store address ptr 3 --

L000081b2                       and.w   #$0007,d0               ; clamp 0-7
L000081b6                       mulu.w  #$001a,d0               ; multiply by struct size (26 bytes)
L000081ba                       lea.l   $00(a3,d0.w),a6         ; a6 = ptr to struct
L000081be                       move.l  a6,(a0)+                ; -- store address ptr 4 --
L000081c0                       move.l  a4,(a0)+                ; -- store address ptr 5 -- static ptr L00008732

L000081c2                       dbf.w   d7,L00008180_loop       ; loop for number of times specified - L00008180

L000081c6                       lea.l   $0014(a0),a0            ; skip 20 bytes after each batch
L000081ca                       bra.b   L0000817c
L000081cc_exit
L000081cc                       rts  





                ; ------------------------- initialise batwing data ------------------------------
                ; some batwing init routine (similar to above)
                ; these blocks of data may represent road sections or something similar.
initialise_batwing_data                
L000081ce                       lea.l   L00008838,a0            ; 1st list of ptrs (populated by this routine) 25 entries

L000081d4                       lea.l   L00008a34,a1            ; list of 6 byte structure (16 entries)
L000081da                       lea.l   L00008ace,a2            ; list of ptrs (8 entries)
L000081e0                       lea.l   L00008aee,a3            ; list of 26 byte structure (8 entries)
L000081e6                       lea.l   L00008732,a4            ; unknown data ptr (shared with batmobile)

L000081ec                       moveq   #$18,d7                 ; 24+1 iterations for initialisation

                        ; create batch of 5 long ptrs to data
L000081ee_loop          ; original address $000081ee
L000081ee                       bsr.w   L0000421a               ; d0 = randomish number
L000081f2                       and.w   #$000f,d0               ; clamp 0-15
L000081f6                       mulu.w  #$0006,d0               ; multiply by struct size (6 bytes)
L000081fa                       lea.l   $00(a1,d0.w),a6         ; a6 = address of random struct.
L000081fe                       move.l  a6,(a0)+

L00008200                       bsr.w   L0000421a               ; d0 = randomish number
L00008204                       and.w   #$0007,d0               ; clamp 0-7
L00008208                       lsl.w   #$02,d0                 ; multiply by 4 (ptr size)
L0000820a                       move.l  $00(a2,d0.w),(a0)+      ; -- store address ptr 2 --

L0000820e                       bsr.w   L0000421a               ; d0 = randomish number
L00008212                       and.w   #$0007,d0               ; clamp 0-7
L00008216                       mulu.w  #$001a,d0               ; multiply by struct size (26 bytes)
L0000821a                       lea.l   $00(a3,d0.w),a6         ; a6 = ptr to struct
L0000821e                       move.l  a6,(a0)+                ; -- store address ptr 3 --

L00008220                       and.w   #$0007,d0               ; clamp 0-7
L00008224                       mulu.w  #$001a,d0               ; multiply by struct size (26 bytes)
L00008228                       lea.l   $00(a3,d0.w),a6         ; a6 = ptr to struct
L0000822c                       move.l  a6,(a0)+                ; -- store address ptr 4 --
L0000822e                       move.l  a4,(a0)+                ; -- store address ptr 5 -- static ptr L00008732

L00008230                       dbf.w   d7,L000081ee_loop
L00008234                       rts 


; end of program data? no idea what is contains yet.


                ; Batmobile level data structure ptrs
                ;   - list of road section ptrs for the Batmobile (guessing 1 section per turn-off)
                ;   - each containing batch (of 5 ptrs) contains a list of ptrs to other data
batmobile_section_list
L00008236       dc.l    L00008288       ; batch 1
                dc.l    L00008300       ; batch 2
                dc.l    L00008350       ; batch 3
                dc.l    L000083b4       ; batch 4
L00008246       dc.l    L00008440       ; batch 5
                dc.l    L0000847c       ; batch 6
                dc.l    L000084b8       ; batch 7
                dc.l    L00008530       ; batch 8
L00008256       dc.l    L00008558       ; batch 9
                dc.l    L00008580       ; batch 10
                dc.l    $00000000       ; NULL ptr
                dc.l    L00008236       ; ptr back to top of list above (for looping the road sections?)



                ; Batwing level data structure ptrs
                ;  - list of road section ptrs for the batwing (only 1 as no turn-offs)
                ;  - contains batches of 5 ptrs to other data
batwing_section_list
L00008266       dc.l    L00008838       ; Spawn point/level start point. Batwing 5 ptr batches (25 * 20 = 500 byte)
                dc.l    $00000000       ; NULL ptr
                dc.l    L00008266       ; ptr back to top of road section list (for looping the road section?)





                ;-----------------------------------------------------------------------------------------
                ; BATMOBILE INITIALISATION AND DATA
                ;-----------------------------------------------------------------------------------------
                ; list of counters use by init routine at (L00008158)
                ; number of iterations for creating the lists of ptrs that follow
                ; 10 data structures to initialise (starting below this list)
                ; what the data pointed to by these pointers represents is unkown currently.
L00008272       dc.w    $0004           ; 4+1 blocks of ptrs
                dc.w    $0002           ; 2+1 blocks of ptrs
                dc.w    $0003           ; 3+1 blocks of ptrs
                dc.w    $0005           ; 5+1 blocks of ptrs            
                dc.w    $0001           ; 1+1 blocks of ptrs
                dc.w    $0001           ; 1+1 blocks of ptrs
                dc.w    $0004           ; 4+1 blocks of ptrs
                dc.w    $0000           ; 0+1 blocks of ptrs
                dc.w    $0000           ; 0+1 blocks of ptrs
                dc.w    $0000           ; 0+1 blocks of ptrs
                dc.w    $ffff           ; end of list


                ; list of data ptrs initialised by routine at (L00008158)
L00008288       
                ; initialisation ptr batch 1 (5 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003

                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L000087d6
                dc.l    L0000878a
                dc.l    L00008736

                ; initialisation ptr batch 2 (3 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008300       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003
                
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L0000878a
                dc.l    L000087d6
                dc.l    L00008760

                ; initialisation ptr batch 3 (4 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008350       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003
                
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L000087d6
                dc.l    L0000878a
                dc.l    L00008736

                ; initialisation ptr batch 4 (6 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L000083b4       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003
                
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003
                
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L000087d6
                dc.l    L0000878a
                dc.l    L00008736

                ; initialisation ptr batch 5 (2 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008440       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003

                ; ptrs skipped by initialisation 
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L0000878a
                dc.l    L000087d6
                dc.l    L00008760

                ; initialisation ptr batch 6 (2 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L0000847c       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                 
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L000087d6
                dc.l    L0000878a
                dc.l    L00008736

                ; initialisation ptr batch 7 (5 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L000084b8       dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000003
                
                dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                 
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L0000878a
                dc.l    L000087d6
                dc.l    L00008760


                ; initialisation ptr batch 8 (1 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008530       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                  
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L0000878a
                dc.l    L000087d6
                dc.l    L00008760

                ; initialisation ptr batch 9 (1 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008558       dc.l    $c0000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                  
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L000087d6
                dc.l    L0000878a
                dc.l    L00008736

                ; initialisation ptr batch 10 (1 blocks of 5 ptrs + 1 block of 5 pre-set ptrs at end)
L00008580       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                ; ptrs skipped by initialisation                  
                dc.l    L00008824
                dc.l    L00008810
                dc.l    L0000878a
                dc.l    L000087d6
                dc.l    L00008760




                ; Batmobile initialisation/level data table
                ; 3 words/6 byte struct (16 entries) 
L000085a8       dc.w    $f0f0,$f050,$0000
                dc.w    $f0f1,$f150,$0000
                dc.w    $f1f2,$f150,$0000
                dc.w    $f0f9,$f950,$0000
                dc.w    $f9fa,$f950,$0000
                dc.w    $f0f0,$f059,$0000
                dc.w    $f1f2,$f151,$0000
                dc.w    $f0f0,$f050,$0000
                dc.w    $f1f0,$f950,$0000
                dc.w    $f0f0,$f051,$0000
                dc.w    $f0f9,$fa5a,$0000
                dc.w    $f9f9,$f151,$0000
                dc.w    $f0f0,$f050,$0000
                dc.w    $f1f1,$f050,$0000
                dc.w    $f0f0,$f150,$0000
                dc.w    $f0f0,$f959,$0000


                ; data referenced by ptr table below (probaly byte data all end with $00)
L00008608       dc.w    $f8f8,$f858,$0000
L0000860e       dc.w    $3847,$3625,$2425,$3647,$4849,$3a2b,$2c2b,$3a49,$3800
L00008620       dc.w    $f827,$2635,$4441,$184f,$4c3b,$2a29,$3800
L0000862e       dc.w    $e827,$2523,$2527,$2829,$2b2d,$2b29,$e800
L0000863c       dc.w    $a4f6,$faac,$0000


                ; Batmobile initialisation/level data
                ; list of ptrs to data in block above (8 entries)
L00008642       dc.l    L00008608         
L00008646       dc.l    L0000860e
                dc.l    L00008608
                dc.l    L00008620
                dc.l    L0000862e
L00008656       dc.l    L0000863c
                dc.l    L00008608
                dc.l    L0000860e


                ; Batmobile initialisation/level data
                ; list of 26 byte structures (8 entries)
                ; probaly all byte data as all end with $00
L00008662       dc.w    $1210,$1010,$1210,$1218,$1210,$1618,$1618,$1210,$1610,$1216,$1010,$1216,$1200
                dc.w    $1012,$1018,$1016,$1016,$1016,$1216,$1216,$1010,$1210,$1216,$1010,$1016,$1200
                dc.w    $1019,$1019,$1014,$1014,$1614,$1610,$1610,$1610,$1810,$1610,$1610,$1610,$1000
                dc.w    $1810,$1210,$1410,$1210,$1410,$1610,$1010,$1610,$1610,$1410,$1410,$1610,$1000
                dc.w    $1210,$1210,$1010,$1210,$1012,$1012,$1010,$1910,$1910,$1916,$1910,$1610,$1000
                dc.w    $1610,$1610,$1010,$1810,$1010,$1018,$1010,$1410,$1410,$1810,$1410,$1410,$1000
                dc.w    $1210,$1210,$1216,$1216,$1216,$1016,$1016,$1016,$1016,$1010,$1610,$1010,$1000
                dc.w    $1812,$1618,$1012,$1014,$1012,$1014,$1014,$1014,$1016,$1016,$1010,$1910,$1000



                ; level data shared between Batmobile & Batwing stages
L00008732       dc.w    $32c0,$0000   

       
       
       
                ; 6 references to L00008736
L00008736       dc.w    $0140,$2300,$0107,$0309,$0105,$0900,$0140,$1700
                dc.w    $0107,$0309,$0105,$0900,$0140,$1700,$0107,$0309
                dc.w    $0105,$0900,$0800,$0120,$ff00

                ; 6 references to L00008760
L00008760       dc.w    $0180,$2300,$0106,$030a,$0104,$0900,$0180,$1700
                dc.w    $0106,$030a,$0104,$0900,$0180,$1700,$0106,$030a
                dc.w    $0104,$0900,$0800,$0120,$ff00

                ; 11 references to L0000878a
L0000878a       dc.w    $1019,$1019,$1019,$1019,$1019,$1019,$1017,$1017
                dc.w    $1011,$2012,$1019,$1019,$1012,$1014,$1014,$1017
                dc.w    $1017,$1011,$2012,$1019,$1019,$1010,$1014,$1014
                dc.w    $1017,$1017,$1011,$2019,$1014,$1014,$1016,$1016
                dc.w    $1016,$1016,$1016,$1016,$f0f0,$f000

                ; 11 references to L000087d6
L000087d6       dc.w    $1019,$1019,$1019,$1019,$1a19,$1019,$1a19,$1a19
                dc.w    $1a19,$1019,$1a19,$1019,$1a19,$1019,$1a19,$1019
                dc.w    $1019,$1019,$1019,$1a19,$1019,$1019,$1a19,$1a19
                dc.w    $1019,$1a19,$1019,$f0f0,$f000

                ; 11 references to L00008810
L00008810       dc.w    $f8f8,$f8f8,$f8f8,$f8f8,$f8f8,$f8f8,$f8f8,$f8f8
                dc.w    $f8f8,$f8f8

                ; 11 references to L00008824
L00008824       dc.w    $f0f0,$f0f0,$f0f0,$f0f0,$f0f0,$f0f0,$f0f0,$f0f0
                dc.w    $f0f0,$f0f0





                ;---------------------------------------------------------------------
                ; Batwing Level Data (batched of 5 ptrs initialised at level start)
                ;---------------------------------------------------------------------
                ; each batch contains ptrs to other level data.
                ; probably road section data?
                ; 5 ptr batches for batwing level init data
                ; 25*5 batches = 200 bytes of ptrs to level data
                ;       - $8a30-$8838 = $1f8 (504 bytes) 
                ;       - $8a34-$8838 = $1fc (508 bytes) 
L00008838       dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000
                dc.l    $00000000

L00008a28       dc.l    $00000000       ; NULL ptr (end of batches above?)
L00008a30       dc.l    L00008838       ; ptr back to start of batches above



                ; Batwing initialisation data (16 structs of 6 bytes)
L00008a34       dc.w    $f0f0,$f050,$0000
                dc.w    $f0f1,$f150,$0000
                dc.w    $f1f2,$f150,$0000
                dc.w    $f0f9,$f950,$0000
                dc.w    $f9fa,$f950,$0000
                dc.w    $f0f0,$f059,$0000
                dc.w    $f1f2,$f151,$0000
                dc.w    $f0f0,$f050,$0000
                dc.w    $f1f0,$f950,$0000
                dc.w    $f0f0,$f051,$0000
                dc.w    $f0f9,$fa5a,$0000
                dc.w    $f9f9,$f151,$0000
                dc.w    $f0f0,$f050,$0000
                dc.w    $f1f1,$f050,$0000
                dc.w    $f0f0,$f150,$0000
                dc.w    $f0f0,$f959,$0000


                ; data referenced from the table below
L00008a94       dc.w    $f8f8,$f858,$0000
L00008a9a       dc.w    $3847,$3625,$2425,$3647,$4849,$3a2b,$2c2b,$3a49,$3800
L00008aac       dc.w    $f827,$2635,$4441,$184f,$4c3b,$2a29,$3800
L00008aba       dc.w    $e827,$2523,$2527,$2829,$2b2d,$2b29,$e800
L00008ac8       dc.w    $a4f6,$faac,$0000

                ; batwing initialisation data ptrs (8 entries)
                ; references data above.
L00008ace       dc.l    L00008a94
                dc.l    L00008a9a        
                dc.l    L00008a94
                dc.l    L00008aac
                dc.l    L00008aba
                dc.l    L00008ac8       
                dc.l    L00008a94
                dc.l    L00008a9a


                ; batwing initialisation data (8, 26 byte structures)
L00008aee       dc.w    $1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1b10,$1000
                dc.w    $1915,$1910,$1915,$1915,$1910,$1915,$1615,$1015,$1615,$1016,$1010,$1610,$1000
                dc.w    $1810,$1310,$1318,$1310,$1010,$1310,$1310,$1310,$1910,$1910,$1910,$1910,$1900
                dc.w    $1010,$1013,$1010,$1013,$1013,$1013,$1013,$1613,$1610,$1610,$1618,$1610,$1000
                dc.w    $1110,$1810,$1110,$1110,$1110,$1110,$1110,$1010,$1110,$1011,$1010,$1110,$1000
                dc.w    $101b,$1013,$1013,$1013,$101b,$1018,$1b10,$1b10,$1b16,$1316,$1013,$1013,$1000
                dc.w    $1110,$1110,$1810,$1010,$1010,$1010,$1010,$1010,$1010,$1010,$1810,$1010,$1000        
                dc.w    $1016,$1016,$1016,$1018,$101b
L00008bae       dc.w    $101b,$101b,$181b,$101b,$101b,$101b,$101b,$1000 ; routine at L00004d5c has its dirty fingers referencing this data directly. 


  ; contains DATA/GFX pointer offsets?
L00008bbe       dc.l    DATA_OFFSET_3                           ; $00028800
                dc.w    $0000,$0004,$0010,$005e,$0000,$0000
                dc.l    DATA24_OFFSET_1                         ; $0003dec0
                dc.w    $0101,$0018,$0058,$0098,$0000,$0000
                dc.l    DATA24_OFFSET_3                         ; $00044646
                dc.w    $0101,$0000,$0070,$0098,$0000,$0000
                dc.l    DATA24_OFFSET_1                         ; $0003dec0
                dc.w    $0201,$0018,$0058,$0098,$0000,$0000
                dc.l    DATA24_OFFSET_3                         ; $00044646
                dc.w    $0201,$0000,$0070,$0098,$0000,$0000
                dc.l    DATA_OFFSET_3                           ; $00028800
                dc.w    $0102,$0004,$0010,$005e,$0000,$0000
                dc.l    DATA_OFFSET_4                           ; $00025500
                dc.w    $0102,$0004,$000f,$0038,$0000,$0000
                dc.l    DATA_OFFSET_5                           ; $00026044
                dc.w    $0102,$0002,$0012,$0019,$0000,$0000
                dc.l    DATA_OFFSET_6                           ; $00026534
                dc.w    $0102,$0002,$0006,$0028,$0000,$0000
                dc.l    DATA24_OFFSET_2                         ; $00045c28
                dc.w    $0301,$0000,$0058,$0098,$0000,$0000

L00008c5e       dc.l    DATA24_OFFSET_3                         ; $00044646
                dc.w    $0102,$0000,$0070,$0098,$0000,$0000
                dc.l    DATA_OFFSET_2                           ; $00026be6
                dc.w    $0001,$0004,$0010,$005e,$002c,$0000
                dc.l    DATA24_OFFSET_2                         ; $00045c28
                dc.w    $0101,$0000,$0058,$0098,$0070,$0000
                dc.l    DATA24_OFFSET_4                         ; $0004c3fe
                dc.w    $0101,$0000,$0070,$0098,$0070,$0000
                dc.l    DATA24_OFFSET_2                         ; $00045c28
                dc.w    $0201,$0000,$0058,$0098,$0070,$0000
                dc.l    DATA24_OFFSET_4                         ; $0004c3fe
                dc.w    $0201,$0000,$0070,$0098,$0070,$0000
                dc.l    DATA_OFFSET_2                           ; $00026be6
                dc.w    $0102,$0004,$0010,$005e,$002c,$0000
                dc.l    DATA_OFFSET_4                           ; $00025500
                dc.w    $0102,$0004,$000f,$0038,$0038,$0000
                dc.l    DATA_OFFSET_5                           ; $00026044
                dc.w    $0102,$0002,$0012,$0019,$0019,$0000
                dc.l    DATA_OFFSET_6                           ; $00026534
                dc.w    $0102,$0002,$0006,$0028,$0028,$0000
                dc.l    DATA24_OFFSET_2                         ; $00045c28
                dc.w    $0301,$0000,$0058,$0098,$0070,$0000
                dc.l    DATA24_OFFSET_4                         ; $0004c3fe
                dc.w    $0102,$0000,$0070,$0098,$0070,$0000




                even
game_type       ; original address L00008d1e (batwing = 1,batmobile = 0)
L00008d1e       dc.w    $0000

L00008d20       dc.w    $0001
L00008d22       dc.w    $0000                           ; batmobile distance through level- initialised to #$03e7 (999)
L00008d24       dc.w    $0000                           ; batwing number of balloons left - initialised to #$0064 (100)
                dc.w    $0001,$0000,$0000 



                ; routine @L00003986 clears 888 bytes of data between $8d26 - $909e
                ;       - $8d26 + $378 = $909e
L00008d26       dc.w    $0000
L00008d28       dc.w    $0000
L00008d2a       dc.w    $0000                           ; initialised to the value #$0002
L00008d2c       dc.w    $0000
L00008d2e       dc.w    $0000
L00008d30       dc.w    $0000
L00008d32       dc.w    $0000
L00008d34       dc.w    $0000        
L00008d36       dc.w    $0000
L00008d38       dc.w    $0000
L00008d3a       dc.w    $0000                           ; maybe the horizon position
L00008d3c       dc.w    $0000,$0000,$0000,$0000,$0000       
L00008d46       dc.w    $0000,$0000,$0000
L00008d4c       dc.w    $0000,$0000,$0000,$0000,$0000     
L00008d56       dc.w    $0000,$0000,$0000


L00008d5c       dc.w    $0000,$0000,$0000,$0000,$0000    
L00008d66       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008d76       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008d86       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................

L00008d96       dc.w    $0000
L00008d98       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000      
L00008da6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00008db6       dc.w    $0000,$0000,$0000,$0000,$0000

L00008dc0       dc.w    $0000,$0000,$0000        
L00008dc6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008dd6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008de6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................

L00008df6       dc.w    $0000,$0000,$0000
L00008dfc       dc.w    $0000,$0000,$0000,$0000,$0000  
L00008e06       dc.w    $0000,$0000,$0000,$0000

L00008e0e       dc.w    $0000,$0000,$0000,$0000 
L00008e16       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e26       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e36       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e46       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e56       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e66       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e76       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e86       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008e96       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008ea6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008eb6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008ec6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008ed6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008ee6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008ef6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008f06       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008f16       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008f26       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008f36       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00008f46       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................

L00008f56       dc.w    $0000,$0000,$0000,$0000
L00008f5e       dc.w    $0000,$0000
L00008f62       dc.w    $0000
L00008f64       dc.w    $0000        
L00008f66       dc.w    $0000
L00008f68       dc.w    $0000
L00008f6a       dc.w    $0000
L00008f6c       dc.w    $0000

L00008f6e       dc.b    $00
L00008f6f       dc.b    $00
                even

L00008f70       dc.w    $0000
L00008f72       dc.w    $0000


                ; block of 64 ptrs to the current road section
                ; all initalised to the block of 5 ptrs
current_road_section_256_bytes
L00008f74       dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000


L00009074       dc.w    $0000  

L00009076       dc.b    $00
L00009077       dc.b    $00
L00009078       dc.b    $00
L00009079       dc.b    $00
                even

L0000907a       dc.w    $0000                           ; current road section value

road_section_list_ptr              
L0000907c       dc.l    $00000000                       ; ptr to entry in batmobile_section_list or batwing_section_list

road_section_5_ptrs
L00009080       dc.l    $00000000                       ; ptr to block 5 ptrs for current road block

L00009084       dc.l    $00000000                       ; current road section 5 ptrs (copy/working values)
L00009088       dc.l    $00000000
L0000908c       dc.l    $00000000
L00009090       dc.l    $00000000
L00009094       dc.l    $00000000
L00009098       dc.b    $00                             ; current road section byte values
L00009099       dc.b    $00
L0000909a       dc.b    $00
L0000909b       dc.b    $00
L0000909c       dc.b    $00
L0000909d       dc.b    $00
                ; routine @L00003986 clears 888 bytes of data between $8d26 - $909e
                ;       - $8d26 + $378 = $909e



L0000909e       dc.b    $60
L0000909f       dc.b    $00
                even

L000090a0       dc.w    $0000,$0000,$0000   
L000090a6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L000090b2       dc.w    $0000,$0000    
L000090b6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000090c6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
L000090d6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L000090e2       dc.w    $0000,$0000       
L000090e6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
L000090f6       dc.w    $0000
L000090f8       dc.b    $00
L000090f9       dc.b    $00
                even

L000090fa       dc.w    $0000,$0000,$0000,$0000,$0000,$0000 
L00009106       dc.w    $0000,$0000,$0000,$0000


                ; 1 reference to L0000910e
L0000910e       dc.w    $cf30,$3000,$00c7,$3038
L00009116       dc.w    $0800,$c730,$3808,$00c7,$3038,$0800,$c730,$3808         ;...08...08...08.
L00009126       dc.w    $00e7,$0018,$1800,$cf30,$3000,$00e7,$0018,$1800         ;.......00.......
L00009136       dc.w    $f30c,$0c00,$00e1,$181e,$0600,$e318,$1c04,$00e3         ;................
L00009146       dc.w    $181c,$0400,$e318,$1c04,$00e3,$181c,$0400,$f30c         ;................
L00009156       dc.w    $0c00,$00f9,$0006,$0600,$9f60,$6000,$00cf,$3030         ;.........``...00
L00009166       dc.w    $0000,$c730,$3808,$00c7,$3038,$0800,$c730,$3808         ;...08...08...08.
L00009176       dc.w    $00c7,$3038,$0800,$8760,$7818,$00cf,$0030,$3000         ;..08...`x....00.
L00009186       dc.w    $ff00,$0000,$00ff,$0000,$0000,$ff00,$0000,$00ff         ;................
L00009196       dc.w    $0000,$0000,$ff00,$0000,$009f,$6060,$0000,$8f60         ;..........``...`
L000091a6       dc.w    $7010,$00cf,$0030,$3000,$837c,$7c00,$0001,$c6fe         ;p....00..||.....
L000091b6       dc.w    $3800,$10ce,$ef21,$0000,$d6ff,$2900,$08e6,$f711         ;8....!....).....
L000091c6       dc.w    $0018,$c6e7,$2100,$807c,$7f03,$00c1,$003e,$3e00         ;....!..|.....>>.
L000091d6       dc.w    $c738,$3800,$00c3,$383c,$0400,$e318,$1c04,$00e3         ;.88...8<........
L000091e6       dc.w    $181c,$0400,$e318,$1c04,$00e3,$181c,$0400,$e318         ;................
L000091f6       dc.w    $1c04,$00f3,$000c,$0c00,$837c,$7c00,$0001,$c6fe         ;.........||.....
L00009206       dc.w    $3800,$900c,$6f63,$00e1,$181e,$0600,$c330,$3c0c         ;8...oc.......0<.
L00009216       dc.w    $0087,$6078,$1800,$00fe,$ff01,$0080,$007f,$7f00         ;..`x............
L00009226       dc.w    $837c,$7c00,$0001,$c6fe,$3800,$9806,$6761,$00c0         ;.||.....8...ga..
L00009236       dc.w    $3c3f,$0300,$e106,$1e18,$0038,$c6c7,$0100,$807c         ;<?.......8.....|
L00009246       dc.w    $7f03,$00c1,$003e,$3e00,$e31c,$1c00,$00c1,$3c3e         ;.....>>.......<>
L00009256       dc.w    $0200,$816c,$7e12,$0001,$ccfe,$3200,$01fe,$fe00         ;...l~.....2.....
L00009266       dc.w    $0080,$0c7f,$7300,$f10c,$0e02,$00f9,$0006,$0600         ;....s...........
L00009276       dc.w    $00fe,$ff00,$0000,$c0ff,$3f00,$1fc0,$e020,$0003         ;........?.... ..
L00009286       dc.w    $fcfc,$0000,$8006,$7f79,$0038,$c6c7,$0100,$807c         ;.......y.8.....|
L00009296       dc.w    $7f03,$00c1,$003e,$3e00,$837c,$7c00,$0001,$c6fe         ;.....>>..||.....
L000092a6       dc.w    $3800,$1cc0,$e323,$0003,$fcfc,$0000,$01c6,$fe38         ;8....#.........8
L000092b6       dc.w    $0018,$c6e7,$2100,$807c,$7f03,$00c1,$003e,$3e00         ;....!..|.....>>.
L000092c6       dc.w    $01fe,$fe00,$0080,$067f,$7900,$f00c,$0f03,$00e1         ;........y.......
L000092d6       dc.w    $181e,$0600,$e318,$1c04,$00c7,$3038,$0800,$c730         ;..........08...0
L000092e6       dc.w    $3808,$00e7,$0018,$1800,$837c,$7c00,$0001,$c6fe         ;8........||.....
L000092f6       dc.w    $3800,$18c6,$e721,$0080,$7c7f,$0300,$01c6,$fe38         ;8....!..|......8
L00009306       dc.w    $0018,$c6e7,$2100,$807c,$7f03,$00c1,$003e,$3e00         ;....!..|.....>>.
L00009316       dc.w    $837c,$7c00,$0001,$c6fe,$3800,$18c6,$e721,$0080         ;.||.....8....!..
L00009326       dc.w    $7e7f,$0100,$c006,$3f39,$0038,$c6c7,$0100,$807c         ;~.....?9.8.....|
L00009336       dc.w    $7f03,$00c1,$003e,$3e00,$ef10,$1000,$00c7,$3838         ;.....>>.......88
L00009346       dc.w    $0000,$c338,$3c04,$0083,$6c7c,$1000,$817c,$7e02         ;...8<...l|...|~.
L00009356       dc.w    $0001,$c6fe,$3800,$18c6,$e721,$009c,$0063,$6300         ;....8....!...cc.
L00009366       dc.w    $03fc,$fc00,$0001,$c6fe,$3800,$18c6,$e721,$0000         ;........8....!..
L00009376       dc.w    $fcff,$0300,$01c6,$fe38,$0018,$c6e7,$2100,$00fc         ;.......8....!...
L00009386       dc.w    $ff03,$0081,$007e,$7e00,$837c,$7c00,$0001,$c6fe         ;.....~~..||.....
L00009396       dc.w    $3800,$1cc0,$e323,$001f,$c0e0,$2000,$1fc0,$e020         ;8....#.... ....
L000093a6       dc.w    $0019,$c6e6,$2000,$807c,$7f03,$00c1,$003e,$3e00         ;.... ..|.....>>.
L000093b6       dc.w    $07f8,$f800,$0003,$ccfc,$3000,$19c6,$e620,$0018         ;........0.... ..
L000093c6       dc.w    $c6e7,$2100,$18c6,$e721,$0010,$ccef,$2300,$01f8         ;..!....!....#...
L000093d6       dc.w    $fe06,$0083,$007c,$7c00,$01fe,$fe00,$0000,$c0ff         ;.....||.........
L000093e6       dc.w    $3f00,$1fc0,$e020,$0007,$f8f8,$0000,$03c0,$fc3c         ;?.... .........<
L000093f6       dc.w    $001f,$c0e0,$2000,$01fe,$fe00,$0080,$007f,$7f00         ;.... ...........
L00009406       dc.w    $01fe,$fe00,$0000,$c0ff,$3f00,$1fc0,$e020,$0007         ;........?.... ..
L00009416       dc.w    $f8f8,$0000,$03c0,$fc3c,$001f,$c0e0,$2000,$1fc0         ;.......<.... ...
L00009426       dc.w    $e020,$009f,$0060,$6000,$837c,$7c00,$0001,$c6fe         ;. ...``..||.....
L00009436       dc.w    $3800,$1cc0,$e323,$0001,$defe,$2000,$10c6,$ef29         ;8....#.... ....)
L00009446       dc.w    $0018,$c6e7,$2100,$807e,$7f01,$00c0,$003f,$3f00         ;....!..~.....??.
L00009456       dc.w    $39c6,$c600,$0018,$c6e7,$2100,$18c6,$e721,$0000         ;9.......!....!..
L00009466       dc.w    $feff,$0100,$00c6,$ff39,$0018,$c6e7,$2100,$18c6         ;.......9....!...
L00009476       dc.w    $e721,$009c,$0063,$6300,$8778,$7800,$00c3,$303c         ;.!...cc..xx...0<
L00009486       dc.w    $0c00,$c730,$3808,$00c7,$3038,$0800,$c730,$3808         ;...08...08...08.
L00009496       dc.w    $00c7,$3038,$0800,$8778,$7800,$00c3,$003c,$3c00         ;..08...xx....<<.
L000094a6       dc.w    $f906,$0600,$00f8,$0607,$0100,$f806,$0701,$00f8         ;................
L000094b6       dc.w    $0607,$0100,$38c6,$c701,$0018,$c6e7,$2100,$807c         ;....8.......!..|
L000094c6       dc.w    $7f03,$00c1,$003e,$3e00,$39c6,$c600,$0010,$ccef         ;.....>>.9.......
L000094d6       dc.w    $2300,$01d8,$fe26,$0003,$f0fc,$0c00,$07d8,$f820         ;#....&.........
L000094e6       dc.w    $0013,$ccec,$2000,$19c6,$e620,$009c,$0063,$6300         ;.... .... ...cc.
L000094f6       dc.w    $3fc0,$c000,$001f,$c0e0,$2000,$1fc0,$e020,$001f         ;?....... .... ..
L00009506       dc.w    $c0e0,$2000,$1fc0,$e020,$0019,$c6e6,$2000,$00fe         ;.. .... .... ...
L00009516       dc.w    $ff01,$0080,$007f,$7f00,$39c6,$c600,$0010,$eeef         ;........9.......
L00009526       dc.w    $0100,$00fe,$ff01,$0000,$d6ff,$2900,$10c6,$ef29         ;..........)....)
L00009536       dc.w    $0018,$c6e7,$2100,$18c6,$e721,$009c,$0063,$6300         ;....!....!...cc.
L00009546       dc.w    $39c6,$c600,$0018,$e6e7,$0100,$08f6,$f701,$0000         ;9...............
L00009556       dc.w    $deff,$2100,$10ce,$ef21,$0018,$c6e7,$2100,$18c6         ;..!....!....!...
L00009566       dc.w    $e721,$009c,$0063,$6300,$837c,$7c00,$0001,$c6fe         ;.!...cc..||.....
L00009576       dc.w    $3800,$18c6,$e721,$0018,$c6e7,$2100,$18c6,$e721         ;8....!....!....!
L00009586       dc.w    $0018,$c6e7,$2100,$807c,$7f03,$00c1,$003e,$3e00         ;....!..|.....>>.
L00009596       dc.w    $03fc,$fc00,$0001,$c6fe,$3800,$18c6,$e721,$0000         ;........8....!..
L000095a6       dc.w    $fcff,$0300,$01c0,$fe3e,$001f,$c0e0,$2000,$1fc0         ;.......>.... ...
L000095b6       dc.w    $e020,$009f,$0060,$6000,$837c,$7c00,$0001,$c6fe         ;. ...``..||.....
L000095c6       dc.w    $3800,$18c6,$e721,$0018,$c6e7,$2100,$00da,$ff25         ;8....!....!....%
L000095d6       dc.w    $0000,$ccff,$3300,$8176,$7e08,$00c4,$003b,$3b00         ;....3..v~....;;.
L000095e6       dc.w    $03fc,$fc00,$0001,$c6fe,$3800,$18c6,$e721,$0000         ;........8....!..
L000095f6       dc.w    $fcff,$0300,$01cc,$fe32,$0018,$c6e7,$2100,$18c6         ;.......2....!...
L00009606       dc.w    $e721,$009c,$0063,$6300,$837c,$7c00,$0001,$c6fe         ;.!...cc..||.....
L00009616       dc.w    $3800,$1cc0,$e323,$0083,$7c7c,$0000,$c106,$3e38         ;8....#..||....>8
L00009626       dc.w    $0038,$c6c7,$0100,$807c,$7f03,$00c1,$003e,$3e00         ;.8.....|.....>>.
L00009636       dc.w    $03fc,$fc00,$0081,$307e,$4e00,$c730,$3808,$00c7         ;......0~n..08...
L00009646       dc.w    $3038,$0800,$c730,$3808,$00c7,$3038,$0800,$c730         ;08...08...08...0
L00009656       dc.w    $3808,$00e7,$0018,$1800,$39c6,$c600,$0018,$c6e7         ;8.......9.......
L00009666       dc.w    $2100,$18c6,$e721,$0018,$c6e7,$2100,$18c6,$e721         ;!....!....!....!
L00009676       dc.w    $0018,$c6e7,$2100,$807c,$7f03,$00c1,$003e,$3e00         ;....!..|.....>>.
L00009686       dc.w    $39c6,$c600,$0018,$c6e7,$2100,$18c6,$e721,$0080         ;9.......!....!..
L00009696       dc.w    $6c7f,$1300,$817c,$7e02,$00c1,$383e,$0600,$e310         ;l....|~...8>....
L000096a6       dc.w    $1c0c,$00f7,$0008,$0800,$39c6,$c600,$0018,$c6e7         ;........9.......
L000096b6       dc.w    $2100,$08d6,$f721,$0000,$d6ff,$2900,$00fe,$ff01         ;!....!....).....
L000096c6       dc.w    $0080,$7c7f,$0300,$816c,$7e12,$00c9,$0036,$3600         ;..|....l~....66.
L000096d6       dc.w    $39c6,$c600,$0018,$c6e7,$2100,$10ee,$ef01,$0080         ;9.......!.......
L000096e6       dc.w    $7c7f,$0300,$01ee,$fe10,$0018,$c6e7,$2100,$18c6         ;|...........!...
L000096f6       dc.w    $e721,$009c,$0063,$6300,$33cc,$cc00,$0011,$ccee         ;.!...cc.3.......
L00009706       dc.w    $2200,$11cc,$ee22,$0081,$787e,$0600,$c330,$3c0c         ;"...."..x~...0<.
L00009716       dc.w    $00c7,$3038,$0800,$c730,$3808,$00e7,$0018,$1800         ;..08...08.......
L00009726       dc.w    $03fc,$fc00,$0001,$ccfe,$3200,$8118,$7e66,$00c3         ;........2...~f..
L00009736       dc.w    $303c,$0c00,$8760,$7818,$0003,$ccfc,$3000,$01fc         ;0<...`x.....0...
L00009746       dc.w    $fe02,$0081,$007e,$7e00


                ; 1 reference to L0000974e
L0000974e       dc.w    $0010,$0001,$0002,$000b 
L00009756       dc.w    $0000,$0038,$0000,$0016,$0010,$0001,$0002,$000b         ;...8............
L00009766       dc.w    $0000,$0096,$0000,$0016,$0010,$0001,$0002,$000b         ;................
L00009776       dc.w    $0000,$00f4,$0000,$0016,$0010,$0001,$0002,$000b         ;................
L00009786       dc.w    $0000,$0152,$0000,$0016,$0000,$0000,$0000,$07e0         ;...r............
L00009796       dc.w    $1ffc,$3ffc,$1ffc,$07e0,$0000,$0000,$0000,$0000         ;..?.............
L000097a6       dc.w    $0000,$0000,$0000,$07c0,$1c00,$07c0,$0000,$0000         ;................
L000097b6       dc.w    $0000,$0000,$0000,$0000,$0000,$07e0,$1ffc,$3304         ;..............3.
L000097c6       dc.w    $1ffc,$07e0,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000097d6       dc.w    $0000,$07c0,$1000,$07c0,$0000,$0000,$0000,$0000         ;................
L000097e6       dc.w    $0000,$0000,$0000,$07e0,$1ffc,$3cfc,$1ffc,$07e0         ;..........<.....
L000097f6       dc.w    $0000,$0000,$0000,$0700,$1e00,$3c00,$7800,$ff80         ;..........<.x...
L00009806       dc.w    $ff80,$ff80,$7800,$3c00,$1e00,$0700,$0000,$0400         ;....x.<.........
L00009816       dc.w    $1800,$0000,$0000,$6300,$0000,$0000,$1800,$0400         ;......c.........
L00009826       dc.w    $0000,$0700,$1e00,$2400,$7800,$ff80,$9380,$ff80         ;......$.x.......
L00009836       dc.w    $7800,$2400,$1e00,$0700,$0000,$0400,$0000,$0000         ;x.$.............
L00009846       dc.w    $0000,$0000,$0000,$0000,$0000,$0400,$0000,$0700         ;................
L00009856       dc.w    $1e00,$3c00,$4800,$ff80,$ec80,$ff80,$4800,$3c00         ;..<.h.......h.<.
L00009866       dc.w    $1e00,$0700,$0000,$0000,$0000,$07e0,$3ff8,$3ffc         ;............?.?.
L00009876       dc.w    $3ff8,$07e0,$0000,$0000,$0000,$0000,$0000,$0000         ;?...............
L00009886       dc.w    $0000,$03e0,$0038,$03e0,$0000,$0000,$0000,$0000         ;.....8..........
L00009896       dc.w    $0000,$0000,$0000,$07e0,$3ff8,$20cc,$3ff8,$07e0         ;........?. .?...
L000098a6       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$03e0         ;................
L000098b6       dc.w    $0008,$03e0,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000098c6       dc.w    $0000,$07e0,$3ff8,$3f3c,$3ff8,$07e0,$0000,$0000         ;....?.?<?.......
L000098d6       dc.w    $0000,$00e0,$0078,$003c,$001e,$01ff,$01ff,$01ff         ;.....x.<........
L000098e6       dc.w    $001e,$003c,$0078,$00e0,$0000,$0020,$0018,$0000         ;...<.x..... ....
L000098f6       dc.w    $0000,$00c6,$0000,$0000,$0018,$0020,$0000,$00e0         ;........... ....
L00009906       dc.w    $0078,$0024,$001e,$01ff,$01c9,$01ff,$001e,$0024         ;.x.$...........$
L00009916       dc.w    $0078,$00e0,$0000,$0020,$0000,$0000,$0000,$0000         ;.x..... ........
L00009926       dc.w    $0000,$0000,$0000,$0020,$0000,$00e0,$0078,$003c         ;....... .....x.<
L00009936       dc.w    $0012,$01ff,$0137,$01ff,$0012,$003c,$0078,$00e0         ;.....7.....<.x..

                ; 1 reference to L00009946
L00009946       dc.w    $000e,$0000,$0000,$000e

      
                ; store shifted 18 separate 16bit values, preshifted into 16 longwords each
                ; each word stored as 16 longs (4 * 16 = 64 bytes)
                ; and 18 different values (18 * 64 = 1152 bytes)
L0000994e       dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000

                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000

                ; 2 references to L00009a8e (line 6 of preshifted values)
L00009a8e       dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000

                ; 2 references to L00009bce (line 11 of preshifted values)
L00009bce       dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                dc.l    $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000



                ; 18 words of data that are pre-shifted into 18 entries above.
                ; 2 references to L00009dce
L00009dce       dc.w    $ffc0   ; 1111111111000000
                dc.w    $7f80   ; 0111111110000000
                dc.w    $3f00   ; 0011111100000000
                dc.w    $1e00   ; 0001111000000000
                dc.w    $0c00   ; 0000110000000000
                dc.w    $07c0   ; 0000111110000000
                dc.w    $0380   ; 0000001110000000
                dc.w    $0300   ; 0000001100000000
                dc.w    $0100   ; 0000000100000000
                dc.w    $0100   ; 0000000100000000
                dc.w    $a000   ; 1010000000000000
                dc.w    $e000   ; 1110000000000000
                dc.w    $a000   ; 1010000000000000
                dc.w    $a000   ; 1010000000000000
                dc.w    $4000   ; 0100000000000000
                dc.w    $e000   ; 1110000000000000
                dc.w    $0000   ; 0000000000000000
                dc.w    $0000   ; 0000000000000000

                ; unused data
                dc.w    $0000
                dc.w    $0000         
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000
                dc.w    $0000         





                    ;-------------------------------------------------------------------------------------------
                    ; My Debug Routines
                    ;-------------------------------------------------------------------------------------------
                    ; I added the following routines to allow 'signals' to be flashed on screen, and/or
                    ; the game to be paused as required.
                    ;
                    ; The routines are used to modify routines so that I can flash the screen, pause the
                    ; game when certain code is executed.
                    ;

_DEBUG_ERROR
                move.w  #$f00,$dff180
                move.w  #$0f0,$dff180
                jmp     _DEBUG_ERROR

_DEBUG_PAUSE
                btst    #6,$bfe001
                bne.s   _DEBUG_PAUSE
                rts

_DEBUG_COLOURS
                movem.l d0-d1,-(a7)
                move.w  #$300,d1
.do_colours
                move.w  d0,$dff180
                add.w   #$1,d0
                dbf     d1,.do_colours
                
                movem.l (a7)+,d0-d1
                rts

_DEBUG_COLOURS_PAUSE
                move.w  d0,$dff180
                add.w   #$1,d0
                btst    #6,$bfe001
                bne.s   _DEBUG_COLOURS_PAUSE
                rts

_DEBUG_RED_PAUSE
                move.w  #$f00,$dff180
                btst    #6,$bfe001
                bne.s   _DEBUG_RED_PAUSE
                rts

_DEBUG_GREEN_PAUSE
                move.w  #$0f0,$dff180
                btst    #6,$bfe001
                bne.s   _DEBUG_RED_PAUSE
                rts

_DEBUG_BLUE_PAUSE
                move.w  #$00f,$dff180
                btst    #6,$bfe001
                bne.s   _DEBUG_RED_PAUSE
                rts

_MOUSE_WAIT
                btst    #6,$bfe001
                bne.s   _MOUSE_WAIT
                rts

_WAIT_FRAME
                move.l  d0,-(a7)
.loop
                move.w  frame_counter,d0
                cmp.w   frame_counter,d0
                beq.b   .loop
                move.l  (a7)+,d0
                rts

                    ;-------------------------------------------------------------------------------------------
                    ; End of My Debug Routines
                    ;-------------------------------------------------------------------------------------------



            ; if Test Build - Include Data.s
            IFD TEST_BUILD_LEVEL
                incdir  "../data/"
;                incdir "../../rawrippedfiles/disk2files-unpacked"
                include "data.s"
;L0001fffc       incbin "data.iff"
                even
            ENDC


            ; if Test Build (and TEST_BATMOBILE) - Include Data2.s
            IFD TEST_BUILD_LEVEL
                IFD TEST_BATMOBILE
                  incdir "../data2/"
;                  incdir "../../rawrippedfiles/disk2files-unpacked"
                  include "data2.s"
;L0002a416         incbin "data2.iff"
                  even
                ELSE
                  incdir "../data4/"
                  include "data4.s"
                  even
                ENDC
            ENDC

            ; If Test Build - Include the Bottom Panel (Score, Energy, Lives, Timer etc)
            IFD TEST_BUILD_LEVEL
                incdir      "../panel/"
                include     "panel.s" 
                even
            ENDC


             ; If Test Build - Include the Music
            IFD TEST_BUILD_LEVEL
                incdir      "../music/"
                include     "music.s" 
                even
            ENDC

            ; Id Test Build - Define Display buffer
            IFD TEST_BUILD_LEVEL
display_buffer  dcb.l   $2f80,$00000000
            ENDC



* --------------------------------------------------------------------
* intuition_test.s
* --------------------------------------------------------------------
; some system include files...

         include exec/types.i

         include exec/libraries.i

         include exec/exec_lib.i

         include intuition/intuition.i

         include intuition/screens.i
    
* --------------------------------------------------------------------    
; a macro to extend LINKLIB and thus avoid the explicit use 
; of the _LVO prefixes in the function names...

CALLSYS  MACRO

         LINKLIB _LVO\1,\2
    
         ENDM

* --------------------------------------------------------------------    

; System EQUates...

_AbsExecBase       EQU        4

_LVOOpenScreen     EQU     -198

_LVOCloseScreen    EQU      -66

_LVOOpenWindow     EQU     -204

_LVOCloseWindow    EQU      -72
 
_LVOLoadRGB        EQU     -192

_LVOPrintIText     EQU     -216

_LVODrawBorder     EQU     -108

_LVODrawImage      EQU     -114

_LVOSetMenuStrip   EQU     -264

_LVOClearMenuStrip EQU      -54

_LVORectFill       EQU     -306

_LVOSetAPen        EQU     -342

; Colour map EQUates...

BLACK             EQU        0               

GREY              EQU        1

WHITE             EQU        2

RED               EQU        3

GREEN             EQU        4

BLUE              EQU        5 

YELLOW            EQU        6 

MAUVE             EQU        7


; Screen EQUates...

SCREENWIDTH       EQU      320

SCREENHEIGHT      EQU      256

DEPTH             EQU        3


; General EQUates...

NULL              EQU        0

TRUE              EQU        1

* --------------------------------------------------------------------
; main program code...

OPEN_INTUITION    move.l  _AbsExecBase,_SysBase    store Exec library base
         
                  lea     intuition_name,a1        library name start in a1
    
                  moveq   #0,d0                    any version will do
    
                  CALLSYS OpenLibrary,_SysBase     macro (see text for details) 

                  move.l  d0,_IntuitionBase        store returned value

                  beq     EXIT                     test result for success


OPEN_GRAPHICS     lea     graphics_name,a1         library name start in a1
    
                  moveq   #0,d0                    any version will do
    
                  CALLSYS OpenLibrary,_SysBase     macro (see text for details) 

                  move.l  d0,_GfxBase              store returned value

                  beq     CLOSE_INTUITION          test result for success


OPEN_SCREEN       lea     new_screen,a0            new_screen base address

                  CALLSYS OpenScreen,_IntuitionBase
                  
                  move.l  d0,screen_p
                  
                  beq     CLOSE_GRAPHICS


LOAD_COLOURS      add.l    #sc_ViewPort,d0         screen_p already in d0

                  move.l   d0,a0                   viewport address now in a0

                  lea     colour_table,a1          pointer to colour map

                  move.w  #colour_table_SIZEOF,d0  colour map size

                  CALLSYS LoadRGB,_GfxBase
                  

OPEN_WINDOW       lea     new_window,a0            new_window base address
 
                  move.l  screen_p,nw_Screen(a0)   set screen pointer

                  CALLSYS OpenWindow,_IntuitionBase
                  
                  move.l  d0,window_p
                  
                  beq     CLOSE_SCREEN


ADD_MENU          move.l  window_p,a0

                  lea     Menu1,a1
             
                  CALLSYS SetMenuStrip,_IntuitionBase
                  
                  
SET_PEN_COLOUR    move.l  window_p,a1              get window address

                  move.l  wd_RPort(a1),a1          get rastport address           
                  
                  move.b  #BLACK,d0

                  CALLSYS SetAPen,_GfxBase
                  

PRINT_TEXT        move.l  window_p,a1              get window address

                  move.l  wd_RPort(a1),a0          get rastport address           

                  lea     intuitext1,a1
                  
                  move.l  #0,d0                    no additional offsets
                  
                  move.l  #0,d1

                  CALLSYS PrintIText,_IntuitionBase
 
             
SLEEP             move.l  window_p,a0              window base address
                 
                  move.l  wd_UserPort(a0),a2       user port 
                  
                  jsr     MessageHandler


REMOVE_MENU       move.l  window_p,a0

                  CALLSYS ClearMenuStrip,_IntuitionBase
  
  
CLOSE_WINDOW      move.l  window_p,a0

                  CALLSYS CloseWindow,_IntuitionBase


CLOSE_SCREEN      move.l  screen_p,a0

                  CALLSYS CloseScreen,_IntuitionBase
                                    

CLOSE_GRAPHICS    move.l  _GfxBase,a1              base needed in a1         
    
                  CALLSYS CloseLibrary,_SysBase


CLOSE_INTUITION   move.l  _IntuitionBase,a1        base needed in a1         
    
                  CALLSYS CloseLibrary,_SysBase
    
    
EXIT              clr.l    d0

                  rts                              logical end of program


* --------------------------------------------------------------------

; Function name:     MessageHandler()


; Purpose:           IDCMP menu and gadget message handler


; Input Parameters:  Address of IDCMP user-port should be in a2. 


; Output parameters: None


; Register Usage:    a0-a1/d0-d3: Used for system call parameters.

;                    a2:          Holds user-port address

;                    d4:          Used as exit flag (quit when non-zero)


; Other Notes:       All registers are preserved

* --------------------------------------------------------------------

MessageHandler       movem.l  d0-d4/a0-a2,-(sp)    preserve registers

                     clr.l    d4                   clear exit flag

MessageHandler2      clr.l    gadget_p             clear gadget pointer

                     move.l   a2,a0                port address
  
                     CALLSYS  WaitPort,_SysBase  

                     jsr      GetMessage           

                     cmpi.l   #TRUE,d4             exit flag set?

                     beq      MessageHandler3

                     tst.l    gadget_p             was a gadget hit?
                     
                     beq      MessageHandler2
                          
                     jsr      GadgetHandler        do gadget operations

                     bra      MessageHandler2
                    
MessageHandler3      movem.l   (sp)+,d0-d4/a0-a2   restore registers

                     rts                           logical end of routine

* --------------------------------------------------------------------
                     
GetMessage           move.l   a2,a0                get port address in a0

                     CALLSYS  GetMsg,_SysBase      get the message

                     tst.l    d0

                     beq      GetMessageExit       did it exist?

                     move.l   d0,a1                copy pointer to a1

 
                     cmpi.l   #MENUPICK,im_Class(a1) 

                     bne      CheckGadgets          
                      
                     cmpi.w   #MENUNULL,im_Code(a1)   
                     
                     beq      GetMessage1          false alarm?

                     move.l   #TRUE,d4             user wishes to quit   

                     bra      GetMessage1
                     
CheckGadgets         cmpi.l   #GADGETUP,im_Class(a1) 

                     bne      GetMessage1          

                     move.l   im_IAddress(a1),gadget_p   save gadget address
                     
                     
GetMessage1          CALLSYS  ReplyMsg,_SysBase

                     bra      GetMessage           check for more messages

GetMessageExit       rts                           d4 holds exit flag

* --------------------------------------------------------------------

GadgetHandler        move.l  gadget_p,a0

                     cmpi.w  #1,gg_GadgetID(a0)    gadget 1 hit?
                     
                     bne     GadgetHandler1
              
                     jsr     PrintText

                     rts
        
                                                   
GadgetHandler1       cmpi.w  #2,gg_GadgetID(a0)
                     
                     bne     GadgetHandler2        gadget 2 hit?
                     
                     jsr     DrawBorder

                     rts
        
        
GadgetHandler2       jsr     DrawImage             must be gadget 3
                     
                     rts
                     
* --------------------------------------------------------------------

PrintText            move.l  window_p,a1           get window address

                     move.l  wd_RPort(a1),a0       get rastport address           

                     lea     intuitext2,a1
                  
                     move.l  #0,d0                 no additional offsets
                  
                     move.l  #0,d1

                     CALLSYS PrintIText,_IntuitionBase
                     
                     rts

* --------------------------------------------------------------------

DrawBorder           move.l  window_p,a1           get window address

                     move.l  wd_RPort(a1),a0       get rastport address           

                     lea     border1,a1
                  
                     move.l  #0,d0                 no additional offsets
                  
                     move.l  #0,d1

                     CALLSYS DrawBorder,_IntuitionBase
                       
                     rts

* --------------------------------------------------------------------

DrawImage            move.l  window_p,a1           get window address

                     move.w  gg_Flags(a0),d0       get gadget state

                     eori.w  #SELECTED,d0          zero flag set = SELECTED 

                     beq     DrawImage1
                     
ClearImage           move.l  wd_RPort(a1),a1       get rastport address           

                     move.w  #44,d0                set image dimensions
                     
                     move.w  #130,d1               
                     
                     move.w  #44+232-1,d2
                     
                     move.w  #130+88-1,d3

                     CALLSYS RectFill,_GfxBase
                     
                     rts
                                          

DrawImage1           move.l  window_p,a1           get window address

                     move.l  wd_RPort(a1),a0       get rastport address           

                     lea     image1,a1
                  
                     move.l  #0,d0                 no additional offsets
                  
                     move.l  #0,d1

                     CALLSYS DrawImage,_IntuitionBase
              
                     rts
                     
* --------------------------------------------------------------------
; variables and static data...
    
_GfxBase          ds.l    1

_IntuitionBase    ds.l    1

_SysBase          ds.l    1

screen_p          ds.l    1

window_p          ds.l    1

gadget_p          ds.l    1

intuition_name    dc.b 'intuition.library',0

graphics_name     dc.b 'graphics.library',0

* --------------------------------------------------------------------
; screen definition...

    cnop 0,2        
        
new_screen

    dc.w    0,0                                    screen top left
    
    dc.w    SCREENWIDTH,SCREENHEIGHT               screen width and height

    dc.w    DEPTH                                  bitplane depth
    
    dc.b    WHITE,GREY                             detail and block pens
    
    dc.w    0                                      no special view modes
    
    dc.w    CUSTOMSCREEN                           screen type
    
    dc.l    NULL                                   no special font
    
    dc.l    NULL                                   no title
    
    dc.l    NULL                                   no gagdets
    
    dc.l    NULL                                   no custom bitmap
    
* --------------------------------------------------------------------
; window definition...

    cnop 0,2

new_window

    dc.w    0,0                                    window XY origin 

    dc.w    SCREENWIDTH,SCREENHEIGHT               width and height

    dc.b    WHITE,GREY                             detail and block pens

    dc.l    MENUPICK+GADGETUP                      IDCMP flags

    dc.l    SMART_REFRESH                          window flags

    dc.l    Gadget1                                first gadget 

    dc.l    NULL                                   no CHECKMARK imagery

    dc.l    NewWindowName                          window title

    dc.l    NULL                                   screen set at run-time

    dc.l    NULL                                   no custom bitmap

    dc.w    0,0                                    minimum width and height

    dc.w    0,0                                    maximum width and height

    dc.w    CUSTOMSCREEN                           screen type


NewWindowName

    dc.b    '*** Select window to activate menu ***',0


* --------------------------------------------------------------------
; screen colours definition...

    cnop 0,2

colour_table

    dc.w    $0000                                  BLACK (background)
    
    dc.w    $0888                                  GREY
       
    dc.w    $0FFF                                  WHITE
    
    dc.w    $0F00                                  RED
    
    dc.w    $00F0                                  GREEN
    
    dc.w    $000F                                  BLUE 
    
    dc.w    $0FF0                                  YELLOW 
    
    dc.w    $0F0F                                  MAUVE 

colour_table_SIZEOF EQU  *-colour_table

* --------------------------------------------------------------------
; border that appears when gadget is selected...

    cnop 0,2 
    
border1

    dc.w    40-2,60-2                              XY origin 

    dc.b    MAUVE,NULL,RP_COMPLEMENT               front & back pens and drawmode

    dc.b    5                                      number of XY vectors

    dc.l    BorderVectors1                         pointer to XY vectors

    dc.l    NULL                                   no next border


BorderVectors1

    dc.w    0,0

    dc.w    235,0

    dc.w    235,10

    dc.w    0,10

    dc.w    0,0

* --------------------------------------------------------------------
; text that appears when gadget is selected...

intuitext1

    dc.b    WHITE,NULL,RP_JAM1,0                   pens, drawmode and fill byte

    dc.w    40,60                                  XY origin

    dc.l    NULL                                   default font

    dc.l    ITextText1                             text pointer

    dc.l    NULL                                   


ITextText1
                                            
    dc.b    'PLEASE SELECT ITEM TO DISPLAY',0

    cnop 0,2


intuitext2

    dc.b    MAUVE,NULL,RP_COMPLEMENT,0             pens, drawmode and fill byte

    dc.w    20,72                                  XY origin 

    dc.l    NULL                                   default font

    dc.l    ITextText2                             text pointer

    dc.l    intuitext3                             next IntuiText structure


ITextText2

    dc.b    'As gadgets are selected an example',0

    cnop 0,2


intuitext3

    dc.b    MAUVE,NULL,RP_COMPLEMENT,0             pens, drawmode and fill byte

    dc.w    24,84                                  XY origin 

    dc.l    NULL                                   default font

    dc.l    ITextText3                             text pointer

    dc.l    intuitext4                             next structure


ITextText3

    dc.b    'item will be displayed or removed',0

   cnop 0,2


intuitext4

    dc.b    MAUVE,NULL,RP_COMPLEMENT,0             pens, drawmode and fill byte

    dc.w    20,96                                  XY origin 

    dc.l    NULL                                   default font

    dc.l    ITextText4                             text pointer

    dc.l    NULL                                   no next structure


ITextText4

    dc.b    'To exit from program use menu QUIT!',0

   cnop 0,2

* --------------------------------------------------------------------
; menu definition...

Menu1

   dc.l    NULL                            next menu 

   dc.w    0,0                             XY origin 

   dc.w    70,10                           hit box width and height

   dc.w    MENUENABLED                     flags

   dc.l    MenuName                        name

   dc.l    MenuItem1                       menu items

   dc.w    0,0,0,0   

   
MenuName

   dc.b    'Project',0

   cnop    0,2
   

MenuItem1

        dc.l    NULL                           no next menu item 

        dc.w    0,0                            XY origin 

        dc.w    40,8                           width and height

        dc.w    ITEMTEXT+ITEMENABLED+HIGHCOMP  flags

        dc.l    0

        dc.l    MenuIText1                     intuitext to be rendered 

        dc.l    NULL

        dc.b    NULL

        dc.b    NULL

        dc.l    NULL                           no sub- items 

        dc.w    MENUNULL

   
MenuIText1

        dc.b    RED,GREY,RP_COMPLEMENT,0       pens, drawmode and fill byte

        dc.w    0,0                            XY origin

        dc.l    NULL                           default font

        dc.l    MenuITextText1                 text

        dc.l    NULL                           no next structure


MenuITextText1

        dc.b    'Quit',0

        cnop 0,2

* --------------------------------------------------------------------
; gadget definitions...

Gadget1

        dc.l        Gadget2                    next gadget

        dc.w        18,24                      origin XY 

        dc.w        77,21                      hit box width and height

        dc.w        NULL                       gadget flags

        dc.w        RELVERIFY+TOGGLESELECT     activation flags

        dc.w        BOOLGADGET                 type flags

        dc.l        GagdetBorder1              gadget border 

        dc.l        NULL                       no alternate imagery 

        dc.l        GagdetIText1               gadget text 

        dc.l        NULL    

        dc.l        NULL       

        dc.w        1                          gadget ID

        dc.l        NULL      


GagdetBorder1

        dc.w        -1,-1                      XY origin 

        dc.b        BLUE,BLACK,RP_JAM1         pens and drawmode

        dc.b        5                          vector count

        dc.l        GagdetBorderVectors1       vector pointer

        dc.l        NULL                       no next border


GagdetBorderVectors1

        dc.w        0,0

        dc.w        78,0

        dc.w        78,22

        dc.w        0,22

        dc.w        0,0


GagdetIText1

        dc.b        WHITE,BLACK,RP_JAM2,0     pens, drawmode and fill byte

        dc.w        20,6                      XY origin 

        dc.l        NULL                      default font

        dc.l        GagdetITextText1          text

        dc.l        NULL     


GagdetITextText1

        dc.b        'Text',0

        cnop 0,2


Gadget2

        dc.l        Gadget3                   next gadget

        dc.w        124,24                    origin XY 

        dc.w        77,21                     hit box width and height

        dc.w        NULL                      gadget flags

        dc.w        RELVERIFY+TOGGLESELECT    activation flags

        dc.w        BOOLGADGET                gadget type 

        dc.l        GagdetBorder2             gadget border

        dc.l        NULL    

        dc.l        GagdetIText2              text

        dc.l        NULL 

        dc.l        NULL       

        dc.w        2                         gadget ID

        dc.l        NULL                          


GagdetBorder2

        dc.w        -1,-1                     XY origin 

        dc.b        BLUE,BLACK,RP_JAM1        pens and drawmode

        dc.b        5                         vector count

        dc.l        GagdetBorderVectors2      vector pointer

        dc.l        NULL                      no next border


GagdetBorderVectors2

        dc.w        0,0

        dc.w        78,0

        dc.w        78,22

        dc.w        0,22

        dc.w        0,0


GagdetIText2

        dc.b        WHITE,BLACK,RP_JAM2,0     pens, drawmode and fill byte

        dc.w        14,6                      XY origin

        dc.l        NULL                      default font

        dc.l        GagdetITextText2          text

        dc.l        NULL       

        
GagdetITextText2

        dc.b        'Border',0

        cnop 0,2
        

Gadget3

        dc.l        NULL                      no next gadget

        dc.w        230,24                    origin XY 

        dc.w        77,21                     hit box width and height

        dc.w        NULL                      gadget flags

        dc.w        RELVERIFY+TOGGLESELECT    activation flags

        dc.w        BOOLGADGET                gadget type 

        dc.l        GagdetBorder3             gadget border

        dc.l        NULL     

        dc.l        GagdetIText3              text 

        dc.l        NULL   

        dc.l        NULL   

        dc.w        3                         gadget ID

        dc.l        NULL      


GagdetBorder3

        dc.w        -1,-1                     XY origin

        dc.b        BLUE,BLACK,RP_JAM1        pens and drawmode

        dc.b        5                         vector count

        dc.l        GagdetBorderVectors3      vector pointer

        dc.l        NULL        

        
GagdetBorderVectors3

        dc.w        0,0

        dc.w        78,0

        dc.w        78,22

        dc.w        0,22

        dc.w        0,0


GagdetIText3

        dc.b        WHITE,BLACK,RP_JAM2,0     pens, drawmode and fill byte

        dc.w        17,6                      XY origin 

        dc.l        NULL                      default font

        dc.l        GagdetITextText3          text

        dc.l        NULL      

        
GagdetITextText3

        dc.b        'Image',0

* --------------------------------------------------------------------
; image description...

        cnop 0,2
image1

   dc.w  44,130                        XY origin 

   dc.w  232,88                        image width and height

   dc.w  3                             depth

   dc.l  ImageData1                    image data

   dc.b  $0007,$0000                   plane configurations

   dc.l  NULL                          no next image



        SECTION IMAGE,DATA_C

ImageData1
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$01FF,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $1FFC,$0000,$0000,$0000,$0000,$0FFF,$E000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF
   dc.w  $C000,$0000,$0000,$0000,$3FFF,$F800,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0007,$FFFF,$F000
   dc.w  $0000,$0000,$0000,$7FFF,$FC00,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$001F,$F80F,$FC00,$0000
   dc.w  $0000,$0001,$FFFF,$FF00,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$003F,$8000,$FE00,$0000,$0000
   dc.w  $0003,$FFFF,$FF80,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$007E,$0000,$3F00,$0000,$0000,$0003
   dc.w  $FFFF,$FF80,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$01F8,$0000,$0FC0,$0000,$0000,$0007,$FFFF
   dc.w  $FFC0,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $03F0,$0000,$07E0,$0000,$0000,$000F,$FFFF,$FFE0
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$03E0
   dc.w  $0000,$03E0,$0000,$0000,$000F,$FFFF,$FFE0,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0780,$0000
   dc.w  $00F0,$0000,$0000,$001F,$FFFF,$FFF0,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0F80,$0000,$00F8
   dc.w  $0000,$0000,$001F,$FFFF,$FFF0,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$1F00,$0000,$007C,$0000
   dc.w  $0000,$001F,$FFFF,$FFF0,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$1E00,$0000,$003C,$0000,$0000
   dc.w  $003F,$FFFF,$FFF8,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$3C00,$0000,$001E,$0000,$0000,$003F
   dc.w  $FFFF,$FFF8,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$3C00,$0000,$001E,$0000,$0000,$003F,$FFFF
   dc.w  $FFF8,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $7800,$0000,$000F,$0000,$0000,$003F,$FFFF,$FFF8
   dc.w  $03FE,$0000,$0000,$0000,$0000,$0000,$0000,$7800
   dc.w  $0000,$000F,$0000,$0000,$003F,$FFFF,$FFF8,$1FFF
   dc.w  $C000,$0000,$0000,$0000,$0000,$0000,$7000,$0000
   dc.w  $0007,$0000,$0000,$003F,$FFFF,$FFF8,$3FFF,$E000
   dc.w  $0000,$0000,$0000,$0000,$0000,$7000,$0000,$0007
   dc.w  $0000,$0000,$003F,$FFFF,$FFF8,$FFFF,$F800,$0000
   dc.w  $0000,$0000,$0000,$0000,$F000,$0000,$0007,$8000
   dc.w  $0FE0,$003F,$FFFF,$FFF9,$FFFF,$FC00,$0000,$0000
   dc.w  $0000,$0000,$0000,$F000,$0000,$0007,$8000,$FFFE
   dc.w  $003F,$FFFF,$FFFB,$FFFF,$FE00,$0000,$0000,$0000
   dc.w  $0000,$0000,$E000,$0000,$0003,$8003,$FFFF,$801F
   dc.w  $FFFF,$FFF3,$FFFF,$FE00,$0000,$0000,$0000,$0000
   dc.w  $0000,$E000,$0000,$0003,$800F,$FFFF,$E01F,$FFFF
   dc.w  $FFF7,$FFFF,$FF00,$0000,$0000,$0000,$0000,$0000
   dc.w  $E000,$0000,$0003,$801F,$FFFF,$F01F,$FFFF,$FFFF
   dc.w  $FFFF,$FF80,$0000,$0000,$0000,$0000,$0000,$E000
   dc.w  $0000,$0003,$803F,$FFFF,$F80F,$FFFF,$FFEF,$FFFF
   dc.w  $FF80,$0000,$0000,$0000,$0000,$0000,$E000,$0000
   dc.w  $0003,$80FF,$FFFF,$FE0F,$FFFF,$FFEF,$FFFF,$FF80
   dc.w  $0000,$0000,$0000,$0000,$0000,$E000,$0000,$0003
   dc.w  $80FF,$FFFF,$FE07,$FFFF,$FFDF,$FFFF,$FFC0,$0000
   dc.w  $0000,$0000,$0000,$0000,$E000,$0000,$0003,$81FF
   dc.w  $FFFF,$FF03,$FFFF,$FF9F,$FFFF,$FFC0,$0000,$0000
   dc.w  $0000,$0000,$0000,$F000,$0000,$0007,$83FF,$FFFF
   dc.w  $FF83,$FFFF,$FF9F,$FFFF,$FFC0,$0000,$0000,$0000
   dc.w  $0000,$0000,$F000,$0000,$0007,$87FF,$FFFF,$FFC1
   dc.w  $FFFF,$FF1F,$FFFF,$FFC0,$0000,$0000,$0000,$0000
   dc.w  $0000,$7000,$0000,$0007,$07FF,$FFFF,$FFC0,$7FFF
   dc.w  $FC1F,$FFFF,$FFC0,$0000,$0000,$0000,$0000,$0000
   dc.w  $7000,$0000,$0007,$0FFF,$FFFF,$FFE0,$3FFF,$F81F
   dc.w  $FFFF,$FFC0,$0000,$0000,$0000,$0000,$0000,$7800
   dc.w  $0000,$000F,$0FFF,$FFFF,$FFE0,$0FFF,$E01F,$FFFF
   dc.w  $FFC0,$0000,$0000,$0000,$0000,$0000,$7800,$0000
   dc.w  $000F,$1FFF,$FFFF,$FFF0,$01FF,$001F,$FFFF,$FFC0
   dc.w  $0000,$0000,$0000,$0000,$0000,$3C00,$0000,$001E
   dc.w  $1FFF,$FFFF,$FFF0,$0060,$001F,$FFFF,$FFC0,$0000
   dc.w  $0000,$0000,$0000,$0000,$3C00,$0000,$001E,$1FFF
   dc.w  $FFFF,$FFF0,$0060,$000F,$FFFF,$FF80,$0000,$0000
   dc.w  $0000,$0000,$0000,$1E00,$0000,$003C,$1FFF,$FFFF
   dc.w  $FFF0,$0060,$000F,$FFFF,$FF80,$0000,$0000,$0000
   dc.w  $0000,$0000,$1F00,$0000,$007C,$3FFF,$FFFF,$FFF8
   dc.w  $3FFF,$E00F,$FFFF,$FF80,$0000,$0000,$0000,$0000
   dc.w  $0000,$0F80,$0000,$00F8,$3FFF,$FFFF,$FFF8,$0060
   dc.w  $0007,$FFFF,$FF00,$0000,$0000,$0000,$0000,$0000
   dc.w  $0780,$0000,$00F0,$3FFF,$FFFF,$FFF8,$0060,$0003
   dc.w  $FFFF,$FE00,$0000,$0000,$0000,$0000,$0000,$03E0
   dc.w  $0000,$03E0,$3FFF,$FFFF,$FFF8,$0060,$0003,$FFFF
   dc.w  $FE00,$0000,$0000,$0000,$0000,$0000,$03F0,$0000
   dc.w  $07E0,$3FFF,$FFFF,$FFF8,$0060,$0001,$FFFF,$FC00
   dc.w  $0000,$0000,$0000,$0000,$0000,$01F8,$0000,$0FC0
   dc.w  $3FFF,$FFFF,$FFF8,$0060,$0000,$FFFF,$F800,$0000
   dc.w  $0000,$0000,$0000,$0000,$007E,$0000,$3F00,$3FFF
   dc.w  $FFFF,$FFF8,$0060,$0000,$3FFF,$E000,$0000,$0000
   dc.w  $0000,$0000,$0000,$003F,$8000,$FE00,$1FFF,$FFFF
   dc.w  $FFF0,$0060,$0000,$1FFF,$C000,$0000,$0000,$0000
   dc.w  $0000,$0000,$001F,$F80F,$FC00,$1FFF,$FFFF,$FFF0
   dc.w  $0060,$0000,$03FE,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0007,$FFFF,$F000,$1FFF,$FFFF,$FFF0,$0060
   dc.w  $0000,$0060,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0001,$FFFF,$C000,$1FFF,$FFFF,$FFF0,$0060,$0000
   dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $1FFC,$0000,$0FFF,$FFFF,$FFE0,$0090,$0000,$0060
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00C0
   dc.w  $0000,$0FFF,$FFFF,$FFE0,$0108,$0000,$3FFF,$E000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$00C0,$0000
   dc.w  $07FF,$FFFF,$FFC0,$0204,$0000,$0060,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$7FFF,$C000,$07FF
   dc.w  $FFFF,$FFC0,$0402,$0000,$0060,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$00C0,$0000,$03FF,$FFFF
   dc.w  $FF80,$0801,$0000,$0060,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$00C0,$0000,$01FF,$FFFF,$FF00
   dc.w  $1000,$8000,$0060,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$00C0,$0000,$00FF,$FFFF,$FE00,$2000
   dc.w  $4000,$0060,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$00C0,$0000,$00FF,$FFFF,$FE00,$4000,$2000
   dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $00C0,$0000,$003F,$FFFF,$F800,$8000,$1000,$0060
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00C0
   dc.w  $0000,$001F,$FFFF,$F000,$0000,$0000,$0060,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$00C0,$0000
   dc.w  $000F,$FFFF,$E000,$0000,$0000,$0060,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$00C0,$0000,$0003
   dc.w  $FFFF,$8000,$0000,$0000,$0060,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$00C0,$0000,$0000,$FFFE
   dc.w  $0000,$0000,$0000,$0090,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$00C0,$0000,$0000,$0FE0,$0000
   dc.w  $0000,$0000,$0108,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0120,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0204,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0210,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0402,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0408,$0000,$0000,$0000,$0000,$0000,$0000,$0801
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0804
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$1000,$8000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$1002,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$2000,$4000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$2001,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$4000,$2000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$4000,$8000,$0000,$0000
   dc.w  $0000,$0000,$0000,$8000,$1000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$8000,$4000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0001,$0000,$2000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$01FF,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0FFF,$E000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$3FFF,$F800,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$7F83,$FC00,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$07F0,$0000,$0000
   dc.w  $0000,$0001,$FC00,$7F00,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$7FFF,$0000,$0000,$0000
   dc.w  $0003,$F000,$1F80,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0001,$FFFF,$C000,$0000,$0000,$0003
   dc.w  $E000,$0F80,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0007,$FFFF,$F000,$0000,$0000,$0007,$8000
   dc.w  $03C0,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $000F,$FFFF,$F800,$0000,$0000,$000F,$8000,$03E0
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$001F
   dc.w  $FFFF,$FC00,$0000,$0000,$000F,$0000,$01E0,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$007F,$FFFF
   dc.w  $FF00,$0000,$0000,$001E,$0000,$00F0,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$007F,$FFFF,$FF00
   dc.w  $0000,$0000,$001E,$0000,$00F0,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$00FF,$FFFF,$FF80,$0000
   dc.w  $0000,$001C,$0000,$0070,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$01FF,$FFFF,$FFC0,$0000,$0000
   dc.w  $003C,$0000,$0078,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$03FF,$FFFF,$FFE0,$0000,$0000,$003C
   dc.w  $0000,$0078,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$03FF,$FFFF,$FFE0,$0000,$0000,$0038,$0701
   dc.w  $C038,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $07F8,$7FFF,$8FF0,$0000,$0000,$0038,$0701,$C038
   dc.w  $03FE,$0000,$0000,$0000,$0000,$0000,$0000,$07F0
   dc.w  $3FFF,$07F0,$0000,$3FF8,$0038,$0010,$0038,$1FFF
   dc.w  $C000,$0000,$0000,$0000,$0000,$0000,$0FF0,$3FFF
   dc.w  $07F8,$0003,$FFFF,$8038,$0038,$0038,$3FFF,$E000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0FF0,$3FFF,$07F8
   dc.w  $000F,$FFFF,$E038,$0038,$0038,$FF07,$F800,$0000
   dc.w  $0000,$0000,$0000,$0000,$0FF8,$7FFF,$8FF8,$003F
   dc.w  $FFFF,$F83C,$0038,$0079,$F800,$FC00,$0000,$0000
   dc.w  $0000,$0000,$0000,$0FFF,$FF7F,$FFF8,$007F,$FFFF
   dc.w  $FC3C,$0038,$007B,$F000,$7E00,$0000,$0000,$0000
   dc.w  $0000,$0000,$1FFF,$FE3F,$FFFC,$00FF,$FFFF,$FE1C
   dc.w  $0038,$0073,$C000,$1E00,$0000,$0000,$0000,$0000
   dc.w  $0000,$1FFF,$FC1F,$FFFC,$03FF,$FFFF,$FF9E,$0028
   dc.w  $00F7,$8000,$0F00,$0000,$0000,$0000,$0000,$0000
   dc.w  $1FFF,$FC1F,$FFFC,$07FF,$FFFF,$FFDE,$0400,$40FF
   dc.w  $8000,$0F80,$0000,$0000,$0000,$0000,$0000,$1FFF
   dc.w  $FC1F,$FFFC,$07FF,$FFFF,$FFCF,$0601,$81EF,$0000
   dc.w  $0780,$0000,$0000,$0000,$0000,$0000,$1FFF,$FC1F
   dc.w  $FFFC,$0FFF,$FFFF,$FFEF,$81C7,$03EE,$0000,$0380
   dc.w  $0000,$0000,$0000,$0000,$0000,$1FFF,$FC1F,$FFFC
   dc.w  $1FFF,$FFFF,$FFF7,$8078,$03DE,$0000,$03C0,$0000
   dc.w  $0000,$0000,$0000,$0000,$1FFF,$FC1F,$FFFC,$3FFF
   dc.w  $FFFF,$FFFB,$E000,$0F9E,$0000,$03C0,$0000,$0000
   dc.w  $0000,$0000,$0000,$0FFF,$FC1F,$FFF8,$3FFF,$FFFF
   dc.w  $FFFB,$F000,$1F9C,$0000,$01C0,$0000,$0000,$0000
   dc.w  $0000,$0000,$0FFF,$FC1F,$FFF8,$7FFF,$FFFF,$FFFD
   dc.w  $FC00,$7F1C,$0000,$01C0,$0000,$0000,$0000,$0000
   dc.w  $0000,$0FFF,$FC1F,$FFF8,$7FFF,$FFFF,$FFFC,$7F83
   dc.w  $FC1C,$0000,$01C0,$0000,$0000,$0000,$0000,$0000
   dc.w  $0FFF,$FDDF,$FFF8,$FFFF,$FFFF,$FFFE,$3FFF,$F81C
   dc.w  $0000,$01C0,$0000,$0000,$0000,$0000,$0000,$07FF
   dc.w  $FDDF,$FFF0,$FFF0,$FFFF,$1FFE,$0FFF,$E01C,$0000
   dc.w  $01C0,$0000,$0000,$0000,$0000,$0000,$07FF,$FFFF
   dc.w  $FFF0,$FFE0,$7FFE,$0FFE,$01FF,$001E,$0000,$03C0
   dc.w  $0000,$0000,$0000,$0000,$0000,$03E7,$FFFF,$E7E0
   dc.w  $FFE0,$7FFE,$0FFE,$0060,$001E,$0000,$03C0,$0000
   dc.w  $0000,$0000,$0000,$0000,$03E1,$FFFF,$87E1,$FFE0
   dc.w  $7FFE,$0FFF,$0060,$000E,$0000,$0380,$0000,$0000
   dc.w  $0000,$0000,$0000,$01F0,$FFFF,$0FC1,$FFF0,$FFFF
   dc.w  $1FFF,$0060,$000F,$0000,$0780,$0000,$0000,$0000
   dc.w  $0000,$0000,$00FC,$3FFC,$3F81,$FFFF,$FEFF,$FFFF
   dc.w  $3FFF,$E00F,$8000,$0F80,$0000,$0000,$0000,$0000
   dc.w  $0000,$007E,$07E0,$7F01,$FFFF,$FC7F,$FFFF,$0060
   dc.w  $0007,$8000,$0F00,$0000,$0000,$0000,$0000,$0000
   dc.w  $007F,$8001,$FF01,$FFFF,$F83F,$FFFF,$0060,$0003
   dc.w  $C000,$1E00,$0000,$0000,$0000,$0000,$0000,$001F
   dc.w  $F00F,$FC01,$FFFF,$F83F,$FFFF,$0060,$0003,$F000
   dc.w  $7E00,$0000,$0000,$0000,$0000,$0000,$000F,$FFFF
   dc.w  $F801,$FFFF,$F83F,$FFFF,$0060,$0001,$F800,$FC00
   dc.w  $0000,$0000,$0000,$0000,$0000,$0007,$FFFF,$F001
   dc.w  $FFFF,$F83F,$FFFF,$0060,$0000,$FF07,$F800,$0000
   dc.w  $0000,$0000,$0000,$0000,$0001,$FFFF,$C001,$FFFF
   dc.w  $F83F,$FFFF,$0060,$0000,$3FFF,$E000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$7FFF,$0001,$FFFF,$F83F
   dc.w  $FFFF,$0060,$0000,$1FFF,$C000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$07F0,$0001,$FFFF,$F83F,$FFFF
   dc.w  $0060,$0000,$03FE,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$FFFF,$F83F,$FFFE,$0060
   dc.w  $0000,$0060,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$FFFF,$F83F,$FFFE,$0060,$0000
   dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$FFFF,$FBBF,$FFFE,$0090,$0000,$0060
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$FFFF,$FBBF,$FFFE,$0108,$0000,$3FFF,$E000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $7FFF,$FFFF,$FFFC,$0204,$0000,$0060,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$7FCF
   dc.w  $FFFF,$CFFC,$0402,$0000,$0060,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$3FC3,$FFFF
   dc.w  $0FF8,$0801,$0000,$0060,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$3FE1,$FFFE,$1FF8
   dc.w  $1000,$8000,$0060,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$1FF8,$7FF8,$7FF0,$2000
   dc.w  $4000,$0060,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0FFC,$0FC0,$FFE0,$4000,$2000
   dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$07FF,$0003,$FFC0,$8000,$1000,$0060
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$07FF,$E01F,$FFC0,$0000,$0000,$0060,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $03FF,$FFFF,$FF80,$0000,$0000,$0060,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00FF
   dc.w  $FFFF,$FE00,$0000,$0000,$0060,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$007F,$FFFF
   dc.w  $FC00,$0000,$0000,$0090,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$003F,$FFFF,$F800
   dc.w  $0000,$0000,$0108,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$000F,$FFFF,$E000,$0000
   dc.w  $0000,$0204,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0003,$FFFF,$8000,$0000,$0000
   dc.w  $0402,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$3FF8,$0000,$0000,$0000,$0801
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0180,$0000,$0000,$0000,$1000,$8000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$FFFF,$8000,$0000,$0000,$2000,$4000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0180,$0000,$0000,$0000,$4000,$2000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0180
   dc.w  $0000,$0000,$0000,$8000,$1000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0180,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0180,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0180,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0180,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0180,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0180,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0180,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0180
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0240,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0420,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0810,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$1008,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$2004,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$4002,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $8001,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000
   dc.w  $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0002,$0000,$4000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$01FF,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $1FFC,$0000,$0000,$0000,$0000,$0FFF,$E000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0001,$FFFF
   dc.w  $C000,$0000,$0000,$0000,$3FFF,$F800,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0007,$FFFF,$F000
   dc.w  $0000,$0000,$0000,$7F83,$FC00,$0000,$0000,$C600
   dc.w  $1800,$0000,$0038,$3800,$001F,$F80F,$FC00,$0000
   dc.w  $0000,$0001,$FC00,$7F00,$0000,$0000,$C600,$1800
   dc.w  $0000,$0018,$1800,$003F,$8000,$FE00,$0000,$0000
   dc.w  $0003,$F000,$1F80,$0000,$0000,$C63C,$30EC,$3C00
   dc.w  $3C18,$1800,$007E,$0000,$3F00,$0000,$0000,$0003
   dc.w  $E000,$0F80,$0000,$0000,$D666,$0076,$6600,$0618
   dc.w  $1800,$01F8,$0000,$0FC0,$0000,$0000,$0007,$8000
   dc.w  $03C0,$0000,$0000,$FE7E,$0066,$7E00,$1E18,$1800
   dc.w  $03F0,$0000,$07E0,$0000,$0000,$000F,$8000,$03E0
   dc.w  $0000,$0000,$EE60,$0060,$6000,$6618,$1800,$03E0
   dc.w  $0000,$03E0,$0000,$0000,$000F,$0000,$01E0,$0000
   dc.w  $0000,$C63C,$00F0,$3C00,$3B3C,$3C00,$0780,$0000
   dc.w  $00F0,$0000,$0000,$001E,$0000,$00F0,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0F80,$0000,$00F8
   dc.w  $0000,$0000,$001E,$0000,$00F0,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$1F00,$0000,$007C,$0000
   dc.w  $0000,$001C,$0000,$0070,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$1E00,$0000,$003C,$0000,$0000
   dc.w  $003C,$0000,$0078,$0000,$0000,$1800,$0000,$E018
   dc.w  $0000,$0000,$3C00,$0000,$001E,$0000,$0000,$003C
   dc.w  $0000,$0078,$0000,$0000,$0000,$0000,$6000,$0000
   dc.w  $0000,$3C00,$0000,$001E,$0000,$0000,$0038,$0701
   dc.w  $C038,$0000,$0000,$387C,$003C,$6C38,$DC00,$0000
   dc.w  $7807,$8000,$700F,$0000,$0000,$0038,$0701,$C038
   dc.w  $0000,$0000,$1866,$0066,$7618,$6600,$0000,$780F
   dc.w  $C000,$F80F,$0000,$3FF8,$0038,$0010,$0038,$0000
   dc.w  $0000,$1866,$0060,$6618,$6600,$0000,$700F,$C000
   dc.w  $F807,$0003,$FFFF,$8038,$0038,$0038,$0000,$0000
   dc.w  $1866,$0066,$6618,$7C00,$0000,$700F,$C000,$F807
   dc.w  $000F,$FFFF,$E038,$0038,$0038,$00F8,$0000,$3C66
   dc.w  $003C,$E63C,$6000,$0000,$F007,$8000,$7007,$803F
   dc.w  $F01F,$F83C,$0038,$0078,$07FF,$0000,$0000,$0000
   dc.w  $0000,$F000,$0000,$F000,$0080,$0007,$807F,$0001
   dc.w  $FC3C,$0038,$0078,$0FFF,$8000,$0000,$0000,$0000
   dc.w  $0000,$0000,$E000,$01C0,$0003,$80FC,$0000,$7E1C
   dc.w  $0038,$0070,$3FFF,$E000,$0000,$0000,$0000,$0000
   dc.w  $0000,$E000,$03E0,$0003,$83F0,$0000,$1F9E,$0028
   dc.w  $00F0,$7FFF,$F000,$0000,$0000,$0000,$0000,$0000
   dc.w  $E000,$03E0,$0003,$87E0,$0000,$0FDE,$0400,$40F0
   dc.w  $7FFF,$F000,$0000,$0000,$0000,$0000,$0000,$E000
   dc.w  $03E0,$0003,$87C0,$0000,$07CF,$0601,$81E0,$FFFF
   dc.w  $F800,$663C,$663C,$EC66,$0000,$0000,$E000,$03E0
   dc.w  $0003,$8F00,$0000,$01EF,$81C7,$03E1,$FFFF,$FC00
   dc.w  $7766,$7766,$7666,$0000,$0000,$E000,$03E0,$0003
   dc.w  $9F00,$0000,$01F7,$8078,$03C1,$FFFF,$FC00,$6B7E
   dc.w  $6B66,$6666,$0000,$0000,$E000,$03E0,$0003,$BE00
   dc.w  $0000,$00FB,$E000,$0F81,$F1FC,$7C00,$6360,$6366
   dc.w  $603C,$0000,$0000,$F000,$03E0,$0007,$BC00,$0000
   dc.w  $007B,$F000,$1F83,$F1FC,$7E00,$633C,$633C,$F018
   dc.w  $0000,$0000,$F000,$03E0,$0007,$F800,$0000,$003D
   dc.w  $FC00,$7F03,$FFDF,$FE00,$0000,$0000,$0070,$0000
   dc.w  $0000,$7000,$03E0,$0007,$7800,$0000,$003C,$7F83
   dc.w  $FC03,$FF8F,$FE00,$0000,$0000,$0000,$0000,$0000
   dc.w  $7000,$0220,$0007,$F000,$0000,$001E,$3FFF,$F803
   dc.w  $FF8F,$FE00,$0000,$0000,$0000,$0000,$0000,$7800
   dc.w  $0220,$000F,$F00F,$0000,$E01E,$0FFF,$E003,$FF8F
   dc.w  $FE00,$0000,$0000,$0000,$0000,$0000,$7800,$0000
   dc.w  $000F,$E01F,$8001,$F00E,$01FF,$0001,$FF8F,$FC00
   dc.w  $0000,$0000,$0000,$0000,$0000,$3C18,$0000,$181E
   dc.w  $E01F,$8001,$F00E,$0060,$0001,$FF8F,$FC00,$0000
   dc.w  $0000,$0000,$0000,$0000,$3C1E,$0000,$781F,$E01F
   dc.w  $8001,$F00F,$0060,$0001,$FFAF,$FC00,$0000,$0000
   dc.w  $0000,$0000,$0000,$1E0F,$0000,$F03D,$E00F,$0000
   dc.w  $E00F,$0060,$0000,$F7FF,$7800,$0000,$0000,$0000
   dc.w  $0000,$0000,$1F03,$C003,$C07D,$C000,$0100,$0007
   dc.w  $3FFF,$E000,$73FC,$F000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0F81,$F81F,$80F9,$C000,$0380,$0007,$0060
   dc.w  $0000,$7C71,$F000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0780,$7FFE,$00F1,$C000,$07C0,$0007,$0060,$0000
   dc.w  $3F0F,$E000,$0000,$0000,$0000,$0000,$0000,$03E0
   dc.w  $0FF0,$03E1,$C000,$07C0,$0007,$0060,$0000,$0FFF
   dc.w  $8000,$0000,$0000,$0000,$0000,$0000,$03F0,$0000
   dc.w  $07E1,$C000,$07C0,$0007,$0060,$0000,$07FF,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$01F8,$0000,$0FC1
   dc.w  $C000,$07C0,$0007,$0060,$0000,$00F8,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$007E,$0000,$3F01,$C000
   dc.w  $07C0,$0007,$0060,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$003F,$8000,$FE01,$E000,$07C0
   dc.w  $000F,$0060,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$001F,$F80F,$FC01,$E000,$07C0,$000F
   dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0007,$FFFF,$F000,$E000,$07C0,$000E,$0060
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0001,$FFFF,$C000,$E000,$07C0,$000E,$0060,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $1FFC,$0000,$F000,$0440,$001E,$0090,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00C0
   dc.w  $0000,$F000,$0440,$001E,$0108,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$00C0,$0000
   dc.w  $7800,$0000,$003C,$0204,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$7FFF,$C000,$7830
   dc.w  $0000,$303C,$0402,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$00C0,$0000,$3C3C,$0000
   dc.w  $F078,$0801,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$00C0,$0000,$3E1E,$0001,$E0F8
   dc.w  $1000,$8000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$00C0,$0000,$1F07,$8007,$81F0,$2000
   dc.w  $4000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$00C0,$0000,$0F03,$F03F,$01E0,$4000,$2000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $00C0,$0000,$07C0,$FFFC,$07C0,$8000,$1000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00C0
   dc.w  $0000,$07E0,$1FE0,$0FC0,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$00C0,$0000
   dc.w  $03F0,$0000,$1F80,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$00C0,$0000,$00FC
   dc.w  $0000,$7E00,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$00C0,$0000,$007F,$0001
   dc.w  $FC00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$00C0,$0000,$003F,$F01F,$F800
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0120,$0000,$000F,$FFFF,$E000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0210,$0000,$0003,$FFFF,$8000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0408,$0000,$0000,$3FF8,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0804
   dc.w  $0000,$0000,$0180,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$1002,$0000
   dc.w  $0000,$FFFF,$8000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$2001,$0000,$0000
   dc.w  $0180,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$4000,$8000,$0000,$0180
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$8000,$4000,$0000,$0180,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0001,$0000,$2000,$0000,$0180,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0180,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0180,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0180,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0180,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0180,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0180
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0240,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0420,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0810,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$1008,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$2004,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$4002,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $8001,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000
   dc.w  $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0002,$0000,$4000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

* --------------------------------------------------------------------


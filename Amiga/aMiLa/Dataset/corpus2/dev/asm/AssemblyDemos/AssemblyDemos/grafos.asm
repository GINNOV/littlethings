;GRAFOS  By: Foster Hall
            include "startup.asm"

;Program Equates. These are defined here rather than in an Include File. This
;makes assembly faster.

;MENU EQUATES*
MENUPICK            EQU       $00000100
ITEMTEXT            EQU       2
ITEMENABLED         EQU       $10
HIGHCOMP            EQU       $40
HIGHBOX             EQU       $80
COMMSEQ             EQU       $4
MENUNULL            EQU       $0000FFFF
mi_SIZEOF           EQU       $22
Menu1Left           EQU       1
Menu1Width          EQU       9*8
ItemFlags           EQU       ITEMTEXT
CItemFlags          EQU       ITEMTEXT!ITEMENABLED!HIGHCOMP
MenuOn              EQU       $0001
JAM1                EQU       0

;WINDOW EQUATES*
wd_UserPort         EQU       $56
im_class            EQU       20
im_Code             EQU       $18
im_address          EQU       $1C
im_IDCMPWindow      EQU       $2c
wd_RPort            EQU       50
wd_MouseY           EQU       $c
wd_MouseX           EQU       $e
wd_MenuStrip        EQU       $1c
wd_IDCMP            EQU       $52
ACTIVATE            EQU       $1000
CLOSEWINDOW         EQU       $0200
MOUSEBUTTONS        EQU       $8
WINDOWCLOSE         EQU       $8
WINDOWDEPTH         EQU       $4
WINDOWSIZING        EQU       1
BORDERLESS          EQU       $0800
WBENCHSCREEN        EQU       $0001
SYSBASE             EQU       $4        this is the same as _AbsExecBase
MODE_OLDFILE        equ       $3ed

;library offsets.  This replaces the necessity to get the offsets from
;AMIGA-LIB, thus the program assembles faster. It still has to be
;linked though.
_AbsExecBase        equ       $4
GetPrefs            EQU       $ffffff7c
SetPrefs            EQU       $fffffebc
FindTask            equ       $fffffeda
DrawEllipse         EQU       $ffffff4c
OpenLibrary         EQU       $fffffdd8
OpenWindow          EQU       $ffffff34
Open                equ       $ffffffe2
CloseWindow         EQU       $ffffffb8
CloseLibrary        EQU       $fffffe62
Move                EQU       $ffffff10
Draw                EQU       $ffffff0a
SetAPen             EQU       $fffffeaa
SetDrMd             EQU       $fffffe9e
ScrollRaster        EQU       $fffffe74
Text                EQU       $ffffffc4
SetMenuStrip        EQU       $fffffef8
ClearMenuStrip      EQU       $ffffffca
GetMsg              EQU       $fffffe8c
WaitPort            equ       $fffffe80
ReplyMsg            EQU       $fffffe86
ItemAddress         EQU       $ffffff70

;this macro adds the "(A6)" to the end of all library calls
SYS:                MACRO
                    JSR     \1(A6)
                    ENDM

;THE FOLLOWING MACROS ARE FOR THE MENU STRIP
IntuiText           MACRO
            DC.B    \1      FrontPen
            DC.B    \2      BackPen
            DC.B    \3      DrawMode
            DC.B    0       KlugeFill00
            DC.W    \4      Leftedge
            DC.W    \5      TopEdge
            DC.L    \6      FontStuff
            DC.L    \7      YourText
            DC.L    \8      NextText
                    ENDM

Menu                MACRO

            DC.L    \1      mu_NextMenu
            DC.W    \2      mu_LeftEdge
            DC.W    \3      mu_TopEdge
            DC.W    \4      mu_Width
            DC.W    \5      mu_Height
            DC.W    \6      mu_Flags
            DC.L    \7      mu_MenuName
            DC.L    \8      mu_FirstItem
            DC.W    0,0,0,0

                    ENDM

MenuItem            MACRO

            DC.L    \1      mi_NextItem
            DC.W    \2      mi_LeftEdge
            DC.W    \3      mi_TopEdge
            DC.W    \4      mi_Width
            DC.W    \5      mi_Height
            DC.W    \6      mi_Flags
            DC.L    \7      mi_MutualExclude
            DC.L    \8      mi_ItemFill
            DC.L    \9      mi_SelectFill

                    ENDM

MenuItem2           MACRO

            DC.B    \1      mi_Command
            DC.B    0       Kluge
            DC.L    \2      mi_SubItem
            DC.W    \3      mi_NextSelect
                    ENDM
;LET'S GO THEN!
MAIN                MOVE.L    SP,SAVESP          SAVE THE STACK POINTER FIRST THING

OPENINTUITION
          MOVE.L    SYSBASE,A6          GET EXEC POINTER
          MOVE.L    #INTUITIONNAME,A1   GET NAME ADDRESS
          MOVE.L    #0,D0               LIBRARY VERSION  (0=DON'T CARE)
          SYS       OpenLibrary         OPEN LIBRARY
          MOVE.L    D0,INTUITIONBASE    STORE LIBRARY POINTER
          BEQ       ENDWINDOW
          BRA.S     DONEINT
INTUITIONNAME       DC.B      'intuition.library',0
INTUITIONBASE       DS.L      1
DONEINT

OPENGRAPHICS
          MOVE.L    SYSBASE,A6          GET EXEC BASE
          MOVE.L    #GFXNAME,A1         GET ADDRESS BASE FOR NAME
          MOVE.L    #0,D0               VERSION
          SYS       OpenLibrary         OPEN LIBRARY
          MOVE.L    D0,GFXBASE          STORE POINTER
          BEQ       ENDWINDOW
          BRA.S     DONEGFX
GFXNAME             DC.B      'graphics.library',0
GFXBASE             DS.L      1
DONEGFX

OPENWINDOW
          MOVE.L    INTUITIONBASE,A6
          MOVE.L    #MYWINDOW,A0
          SYS       OpenWindow
          MOVE.L    D0,WINDOWPOINTER
          BEQ       ENDWINDOW
          MOVE.L    D0,A0
          MOVE.L    wd_RPort(a0),RASTERPORT   GET THE RASTERPORT ADDRESS
          MOVE.L    wd_UserPort(a0),USERPORT
SETSTRIP
          MOVE.L    WINDOWPOINTER,A0
          MOVE.L    #MENUSTRIP,A1
          MOVE.L    INTUITIONBASE,A6
          SYS       SetMenuStrip
          BRA.S     TEXTPRINT

;THIS IS THE TEXT PRINT ROUTINE FOR THE OPENING PAGE*

PRINT     BSR.S     SETDRMD
PRINT2    BSR.S     SETAPEN
PRINT3    BSR.S     MOVE
          BSR.S     TEXT
          RTS
SETDRMD
          BSR.S     GA6RPA1
          MOVE      DRAWMODE,d0
          SYS       SetDrMd
          RTS
SETAPEN
          BSR.S     GA6RPA1
          MOVE      PENCOLOR,D0
          SYS       SetAPen
          RTS
TEXT
          BSR.S     GA6RPA1
          MOVE.L    TEXTPOINTER,A0
          MOVE      NUMCHARS,D0
          SYS       Text
          RTS
MOVE
          BSR.S     GA6RPA1
          MOVE      XPOSITION,D0
          MOVE      YPOSITION,D1
          SYS       Move
          RTS
DRAW
          BSR.S     GA6RPA1
          SYS       Draw
          RTS
GA6RPA1
          MOVE.L    GFXBASE,A6
          MOVE.L    RASTERPORT,A1
          RTS

;THIS ROUTINE POSITIONS THE LINE OF TEXT ON THE SCREEN AND THEN CALLS*
;THE ABOVE PRINT ROUTINE.                                            *

TEXTPRINT
          MOVE      #0,DRAWMODE
          MOVE      #2,PENCOLOR
          MOVE      #276,XPOSITION
          MOVE      #20,YPOSITION
          MOVE.L    #DATA1,TEXTPOINTER
          MOVE      #ENDDATA1-DATA1,NUMCHARS
          BSR       PRINT

          MOVE      #266,XPOSITION
          MOVE      #30,YPOSITION
          MOVE.L    #DATA2,TEXTPOINTER
          MOVE      #ENDDATA2-DATA2,NUMCHARS
          BSR       PRINT3
DRAWN
          ADDI      #1,YPOSITION
          ADDI      #1,PENCOLOR
          CMPI      #42,YPOSITION
          BEQ.S     MOVEIT
          BSR       PRINT2
          BRA.S     DRAWN
MOVEIT
          MOVE      #2,PENCOLOR
          MOVE      #260,XPOSITION
          MOVE      #50,YPOSITION
          MOVE.L    #DATA3,TEXTPOINTER
          MOVE      #ENDDATA3-DATA3,NUMCHARS
          BSR       PRINT2

          MOVE      #2,PENCOLOR
          MOVE      #260,XPOSITION
          MOVE      #60,YPOSITION
          MOVE.L    #DATA3A,TEXTPOINTER
          MOVE      #ENDDATA3A-DATA3A,NUMCHARS
          BSR       PRINT2

          MOVE      #2,PENCOLOR
          MOVE      #236,XPOSITION
          MOVE      #70,YPOSITION
          MOVE.L    #DATA3B,TEXTPOINTER
          MOVE      #ENDDATA3B-DATA3B,NUMCHARS
          BSR       PRINT2

          MOVE      #184,XPOSITION
          MOVE      #80,YPOSITION
          MOVE.L    #DATA4,TEXTPOINTER
          MOVE      #ENDDATA4-DATA4,NUMCHARS
          BSR       PRINT3

          MOVE      #112,XPOSITION
          MOVE      #90,YPOSITION
          MOVE.L    #DATA5,TEXTPOINTER
          MOVE      #ENDDATA5-DATA5,NUMCHARS
          BSR       PRINT3

          MOVE      #124,XPOSITION
          MOVE      #100,YPOSITION
          MOVE.L    #DATA6,TEXTPOINTER
          MOVE      #ENDDATA6-DATA6,NUMCHARS
          BSR       PRINT3

          MOVE      #120,XPOSITION
          MOVE      #110,YPOSITION
          MOVE.L    #DATA7,TEXTPOINTER
          MOVE      #ENDDATA7-DATA7,NUMCHARS
          BSR       PRINT3

          MOVE      #124,XPOSITION
          MOVE      #120,YPOSITION
          MOVE.L    #DATA8,TEXTPOINTER
          MOVE      #ENDDATA8-DATA8,NUMCHARS
          BSR       PRINT3
          MOVE      #161,BASEX
          MOVE      #160,BASEY
          MOVE      #160,BASEY1
          MOVE      #0,COUNT

;THIS ROUTINE DRAWS THE CIRCLE GRAPHICS ON THE TITLE SCREEN*

          BRA.S     YPOSIT
BLURB
          BSR       GA6RPA1
          MOVE      BASEX,D0
          MOVE      #13,D2
          MOVE      #08,D3
          JSR       DrawEllipse(a6)
          ADDI      #2,BASEX
          CMPI      #479,BASEX
          BGT.S     TITLESCREEN
          RTS
YPOSIT
          CMPI      #0,COUNT
          BNE.S     UPIT
          SUBI      #1,BASEY
          MOVE      BASEY,D1
          BSR.S     BLURB
          ADDI      #1,BASEY1
          MOVE      BASEY1,D1
          BSR.S     BLURB
          CMPI      #150,BASEY
          BGT.S     YPOSIT
          MOVE      #1,COUNT
          BRA.S     YPOSIT
UPIT
          ADDI      #1,BASEY
          MOVE      BASEY,D1
          BSR.S     BLURB
          SUBI      #1,BASEY1
          MOVE      BASEY1,D1
          BSR       BLURB
          CMPI      #180,BASEY
          BLT.S     YPOSIT
          MOVE      #0,COUNT
          BRA       YPOSIT

;THIS CHECKS THE POSITION OF THE MOUSE FOR EACH CORNER TO DETERMINE THE*
;CORRECT ACTION TO PERFORM                                             *

TITLESCREEN
          BSR.S     MOUSER
          BRA.S     TITLESCREEN
MOUSER
          BSR.S     GRAFOSCOLOR
MOUSER2
          MOVE.L    SYSBASE,A6
          MOVE.L    USERPORT,A0
          SYS       GetMsg
          TST.L     D0
          BEQ       RETURN
          MOVE.L    D0,A0
          MOVE.L    im_class(a0),IMCLASS
          CMPI.L    #MENUPICK,IMCLASS
          BNE       RETURN
          MOVE.W    im_Code(a0),IMCODE
MENUPICKED
          MOVE.W    IMCODE,d0
          MOVEA.L   #MENUSTRIP,a0
          MOVE.L    INTUITIONBASE,A6
          SYS       ItemAddress
          TST.L     D0
          BEQ       RETURN
          MOVEA.L   D0,A0
          MOVE.L    #34,D0
          MOVEA.L   0(A0,D0),A1
          JMP       (A1)
RESTART
          BSR.S     SCROLL
          JMP       TEXTPRINT
CLEAR
          BSR.S     SCROLL
CLEARLOOP
          BSR.S     MOUSER2
          BRA.S     CLEARLOOP
GRAFOSCOLOR
          ADDI      #1,PENCOLOR
          MOVE      #294,XPOSITION
          MOVE      #163,YPOSITION
          MOVE.L    #DATA2,TEXTPOINTER
          MOVE      #ENDDATA2-DATA2-8,NUMCHARS
          BSR       PRINT2
          RTS

;THIS IS THE SCREEN SCROLL ROUTINE THAT ACTUALLY MOVES EACH SCREEN*

SCROLL
          CLR.l     COUNT
SCROLLUP
          BSR       GA6RPA1
          MOVE      #0,D0
          MOVE      #5,D1
          MOVE      #0,D2
          MOVE      #0,D3
          MOVE      #640,D4
          MOVE      #200,D5
          SYS       ScrollRaster
          ADDI      #5,COUNT
          CMPI      #200,COUNT
          BLT.S     SCROLLUP
          CLR.l     COUNT
          RTS

;THE FOLLOWING ROUTINES DOES THE ACTUAL DRAW ROUTINE FOR THE SPIRALS*

DRAWLINE
          BSR.S     SCROLL
          MOVE      #320,XPOSITION
          MOVE      #100,YPOSITION
          BSR       MOVE
SPIRAL
          MOVEM     BASEX,XPOSITION
          MOVEM     BASEY,YPOSITION
          BSR       MOVE
CIRCLE
          MOVE      DRAWX,D0
          MOVE      DRAWY,D1
          BSR       DRAW

          CMPI      #0,COUNT
          BEQ.S     STAGE1
          CMPI      #1,COUNT
          BEQ.S     STAGE2
          CMPI      #2,COUNT
          BEQ.S     STAGE3
          CMPI      #3,COUNT
          BEQ.S     STAGE4
          BRA       LOOP
STAGE1
          ADDI      #8,DRAWY
          CMPI      #200,DRAWY
          BLT       LOOP
          ADDI      #1,COUNT
          MOVE      #200,DRAWY
STAGE2
          ADDI      #16,DRAWX
          CMPI      #640,DRAWX
          BLT       LOOP
          ADDI      #1,COUNT
          MOVE      #640,DRAWX
STAGE3
          SUBI      #8,DRAWY
          CMPI      #0,DRAWY
          BGT.S     LOOP
          ADDI      #1,COUNT
          MOVE      #0,DRAWY
STAGE4
          SUBI      #16,DRAWX
          CMPI      #0,DRAWX
          BGT.S     LOOP
          CLR       DRAWY
          CLR       DRAWX
          CLR       COUNT
MOUSEPOINT
          MOVE.L    WINDOWPOINTER,A0
          MOVEM     wd_MouseX(A0),BASEX
          MOVEM     wd_MouseY(A0),BASEY
TEST
          MOVE.L    WINDOWPOINTER,A0
          MOVE      wd_MouseX(A0),D0
          CMP       BASEX,D0
          BNE.S     COLOR
          MOVE      wd_MouseY(A0),D0
          CMP       BASEY,D0
          BNE.S     COLOR
          BSR       MOUSER2
          BRA.S     TEST
COLOR
          ADDI      #1,PENCOLOR
          BSR       SETAPEN

LOOP      BRA       SPIRAL

;THIS IS THE CIRCLE DRAW ROUTINE*

SMALLELLIPSE
          MOVE.W    #25,DRAWX
          MOVE.W    #17,DRAWY
          BRA.S     ELLIPSE

LARGEELLIPSE
          MOVE.W    #50,DRAWX
          MOVE.W    #40,DRAWY
ELLIPSE
          BSR       SCROLL

          MOVE      #2,PENCOLOR
          BSR.S     DOPEN
          MOVE      #320,D0
          MOVE      #100,D1
          BSR       MOVE
DRAW2
          BSR.S     DOCIRCLES
          BSR       MOUSER2
          BRA.S     DRAW2
DOPEN
          BSR       SETAPEN
          RTS
DOCIRCLES
          MOVE.L    WINDOWPOINTER,A0
          BSR       GA6RPA1
          MOVE      wd_MouseX(A0),d0
          MOVE      wd_MouseY(A0),d1
          MOVE      DRAWX,D2
          MOVE      DRAWY,D3
          JSR       DrawEllipse(a6)
RETURN    RTS

SIZEIT
          SUBI      #2,DRAWX
          SUBI      #2,DRAWY
          BEQ.S     RESETXY
          RTS
RESETXY
          MOVE      #75,DRAWX
          MOVE      #50,DRAWY
          RTS
;AND NOW WE CLOSE EVERYTHING OFF WHEN WE'RE DONE*

ENDWINDOW
          MOVE.L    WINDOWPOINTER,A0
          MOVE.L    INTUITIONBASE,A6
          SYS       ClearMenuStrip
          MOVE.L    WINDOWPOINTER,A0
          MOVE.L    INTUITIONBASE,A6
          SYS       CloseWindow

ENDINTUITION
          MOVE.L    INTUITIONBASE,A1
          MOVE.L    SYSBASE,A6
          SYS       CloseLibrary
EDNGFX
          MOVE.L    GFXBASE,A1
          SYS       CloseLibrary

          MOVE.L    SAVESP,SP
          RTS

;THIS SECTION HAS ALL THE DATA AND TEXT*

          SECTION  constants,DATA

MYIDCMP        EQU  MENUPICK
MYFLAGS        EQU  ACTIVATE!BORDERLESS

DATA1            DC.B 'Welcome to:'
ENDDATA1
DATA2            DC.B 'GRAFOS (V .01)'
ENDDATA2
DATA3            DC.B 'By: Foster Hall'
ENDDATA3
DATA3A           DC.B '12679-99th Ave.'
ENDDATA3A
DATA3B           DC.B 'Surrey, B.C. V3V 2P6'
ENDDATA3B
DATA4            DC.B 'A simple assembly language program'
ENDDATA4
DATA5            DC.B 'utilizing a few of the many AMIGA graphics routines.'
ENDDATA5
DATA6            DC.B ' This version is still in the experimental stage,'
ENDDATA6
DATA7            DC.B 'used primarily as a learning tool, with the hopes'
ENDDATA7
DATA8            DC.B 'that it will someday become a productive utility.'
ENDDATA8
          CNOP  0,4

MYWINDOW

                 DC.W      0         LEFT EDGE
                 DC.W      0         TOP EDGE
                 DC.W      640       WIDTH
                 DC.W      200       HEIGHT
                 DC.B      2         DETAIL PEN
                 DC.B      0         BLOCK PEN
                 DC.L      MYIDCMP   IDCMP FLAGS
                 DC.L      MYFLAGS   WINDOW FLAGS
                 DC.L      0         FIRST GADGET
                 DC.L      0         CHECKMARK
                 DC.L      0         WINDOW TITLE
                 DC.L      0         SCREEN
                 DC.L      0         CUSTOM BITMAP
                 DC.W      300       MIN. WIDTH
                 DC.W      10        MIN. HEIGHT
                 DC.W      -1        MAX. WIDTH
                 DC.W      -1        MAX HEIGHT
                 DC.W      WBENCHSCREEN

;this is the data for the menu strip, calling the macros defined at the
;top of the file.

MENUSTRIP
                 CNOP 0,4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MENU#1
M1               Menu         M2,Menu1Left,0,Menu1Width,8,MenuOn,M1T0,M1_1
M2               Menu         0,2+Menu1Width,0,Menu1Width,8,MenuOn,M2T0,M2_1

M1_1             MenuItem     M1_2,0,9*0,8*8,8,CItemFlags,0,Menu1Text1,0
                 MenuItem2    0,0,0
                 DC.L         RESTART

M1_2             MenuItem     M1_3,0,9*1,8*8,8,CItemFlags,0,Menu1Text2,0
                 MenuItem2    0,0,0
                 DC.L         CLEAR

M1_3             MenuItem     0,0,9*2,8*8,8,CItemFlags,0,Menu1Text3,0
                 MenuItem2    0,0,0
                 DC.L         ENDWINDOW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MENU#2
;;;;;
M2_1             MenuItem     M2_2,0,9*0,8*8,8,CItemFlags,0,Menu2Text1,0
                 MenuItem2    0,M2_1A,0
;;;;;
M2_1A            MenuItem     M2_1B,8*8,9*0,8*8,8,CItemFlags,0,Menu2Text1A,0
                 MenuItem2    0,0,0
                 DC.L         SMALLELLIPSE
;;;;;
M2_1B            MenuItem     0,8*8,9*1,8*8,8,CItemFlags,0,Menu2Text1B,0
                 MenuItem2    0,0,0
                 DC.L         LARGEELLIPSE
;;;;;
M2_2             MenuItem     0,0,9*1,8*8,8,CItemFlags,0,Menu2Text2,0
                 MenuItem2    0,0,0
                 DC.L         DRAWLINE

Menu1Text1       IntuiText    2,0,JAM1,0,0,TEXTATTR,M1T1,0
Menu1Text2       Intuitext    2,0,JAM1,0,0,TEXTATTR,M1T2,0
Menu1Text3       Intuitext    2,0,JAM1,0,0,TEXTATTR,M1T3,0
Menu2Text1       Intuitext    2,0,JAM1,0,0,TEXTATTR1,M2T1,0
Menu2Text1A      Intuitext    2,0,JAM1,0,0,0,M2T1A,0
Menu2Text1B      Intuitext    2,0,JAM1,0,0,0,M2T1B,0
Menu2Text2       IntuiText    2,0,JAM1,0,0,TEXTATTR1,M2T2,0

;;;;;
M1T0             DC.B         'PROJECT',0
M1T1             DC.B         'Restart',0
M1T2             DC.B         'Clear',0
M1T3             DC.B         'Quit',0
M2T0             DC.B         'EFFECTS',0
M2T1             DC.B         'Circles',0
M2T1A            DC.B         'Small',0
M2T1B            DC.B         'Large',0
M2T2             DC.B         'Spirals',0

TEXTATTR            DC.L      FONTNAME
                    DC.W      8
                    DC.B      7
                    DC.B      0
FONTNAME            DC.B      'topaz.font',0
TEXTATTR1           DC.L      FONTNAME
                    DC.W      8
                    DC.B      2
                    DC.B      0
;THIS SECTION SETS ASIDE THE STORAGE WE NEED FOR VARIOUS ROUTINES*

          SECTION  variables,BSS
SAVESP              DS.L      1
WINDOWPOINTER       DS.L      1
RASTERPORT          DS.L      1
PENCOLOR            DS.W      1
DRAWX               DS.W      1
DRAWY               DS.W      1
BASEX               DS.W      1
BASEY               DS.W      1
DRAWMODE            DS.W      1
COUNT               DS.L      1
TEXTPOINTER         DS.L      1
IMCODE              DS.L      1
IMCLASS             DS.L      1
NUMCHARS            DS.L      1
XPOSITION           DS.L      1
YPOSITION           DS.L      1
BASEY1              DS.L      1
USERPORT            DS.L      1
_SysBase            ds.l      1
                    END



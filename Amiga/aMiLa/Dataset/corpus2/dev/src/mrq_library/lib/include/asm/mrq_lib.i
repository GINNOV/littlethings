;$VER: mrq.library.i 1.11 (06.9.2000)  Marcin 'MisterQ' Kielesiïski


_LVOClearR               = -30
_LVOMisterQInit          = -36
_LVOMisterQCleanUp       = -42
_LVOMRequest             = -48
_LVOMLoadFile            = -54
_LVOMFreeFile            = -60
_LVOMSaveFile            = -66
_LVOCopyBytes            = -72
_LVOMCloseScreen         = -78
_LVOMOpenScreen          = -84
_LVOC2P                  = -90
_LVOAslFILERequest       = -96
_LVOAslFreeFILERequest   = -102
_LVODecConvert           = -108
_LVOHexConvert           = -114
_LVORomanConvert         = -120
_LVORnd                  = -126
_LVOWyswTXT              = -132
_LVOGetMessage           = -138
_LVOP2C                  = -144
_LVOSearchW              = -150
_LVOGetDynamicMessage    = -156
_LVODoubleBuffer         = -162
_LVOGetFPS               = -168

;-----
DOSLIB_ERROR  = $00000001
GFXLIB_ERROR  = $00000010
REQLIB_ERROR  = $00000100
INTLIB_ERROR  = $00001000
ASLLIB_ERROR  = $00010000
CYBERLIB_EROR = $00100000
GADLIB_ERROR  = $01000000

ALL_OK        = $ffffffff
;-----
AGA_DISPLAY   = $f000
CGX_DISPLAY   = $ff00
;-----

;Begin MisterQBase struct

;-----
dosbase		= 0
gfxbase 	= 4
intbase		= 8
reqtoolsbase	= 12
aslbase		= 16
cyberbase       = 20
;------
_szer           = 24
_chmaxx         = 28
_wys            = 32
_chmaxy         = 36
;------
ChunkyMode      = 40
;------
s_RastPort      = 42
WB_Base         = 46
WB_ViewPort     = 50
s_ScreenBase    = 54
;------
_bitplan0       = 58
_bitplan1       = 62
_bitplan2       = 66
_bitplan3       = 70
_bitplan4       = 74
_bitplan5       = 78
_bitplan6       = 82
_bitplan7       = 86
;------
LibraryError    = 90
;------
BestModeTags    = 94
ScreenTags      = 98
BitMapSTR       = 104
;------
FileRequest     = 108
_FileName       = 112
_DirName        = 116
_Path           = 120
_FileSize       = 124
_FileAddr       = 128
;------
tabdec1         = 132
tabdec2         = 136
tabhex1         = 140
tabroman1       = 144
;------
_kolor0         = 148
_kolor1         = 150
;------
s_WinBase       = 154
;------
gadbase         = 158
Mrnd            = 162
;------
Screen_Tags     = 166
;------
Precc           = 170 ;word
;------
WindowTags      = 172
ScrSTR          = 176
buff1           = 180
;------


;end MisterQBaseStruct

;------

;Begin MScreen Struct

;------

s_Win_Base      = 0
s_Screen_Base   = 4
s_Rast_Port     = 8
s_BitMap_STR    = 12
s_BestModeTags  = 16
s_ScreenTags    = 20
s_bitplan0      = 24
s_bitplan1      = 28
s_bitplan2      = 32
s_bitplan3      = 36
s_bitplan4      = 40
s_bitplan5      = 44
s_bitplan6      = 48
s_bitplan7      = 52
s_ModeID        = 56
s_UserPort      = 60
s_ViewPort      = 64
s_RasInfo       = 68
s_Height        = 72
s_Width         = 76
s_OffSet        = 80
s_WindowTags    = 84
;------

;end MScreen Struct


; struct VectorBase
vbase_LibNode equ 0
vbase_SegList equ 34
vbase_SysBase equ 38
vbase_GfxBase equ 42
vbase_MathBase equ 46
vbase_MathTransBase equ 50
vbase_BMapSize equ 54
vbase_long1 equ 58
vbase_long2 equ 62
vbase_long3 equ 66
vbase_long4 equ 70
vbase_word1 equ 74
vbase_word2 equ 76
vbase_savex equ 78
vbase_savey equ 82
vbase_savez equ 86
VectorBaseSIZE equ 90

; struct VGPoint
vgp_x equ 0
vgp_y equ 4
vgp_z equ 8
VGPointSIZE equ 12

; struct VGArea
vga_NextArea equ 0
vga_Color equ 4
vga_NumPoints equ 6
vga_PointArray equ 8
VGAreaSIZE equ 12

; struct VGObject
vgo_NextObject equ 0
vgo_Num equ 4
vgo_Flags equ 8
vgo_Pos equ 10
vgo_FirstArea equ 22
VGObjectSIZE equ 26

VGF_DRAW equ 1
VGF_FILL equ 2
VGF_HIDE equ 4


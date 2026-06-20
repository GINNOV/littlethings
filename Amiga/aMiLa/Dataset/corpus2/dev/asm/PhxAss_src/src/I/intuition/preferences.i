 IFND INTUITION_PREFERENCES_I
INTUITION_PREFERENCES_I SET 1
*
*  intuition/preferences.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc

 ifnd DEVICES_TIMER_I
 include "devices/timer.i"
 endc

FILENAME_SIZE	= 30
POINTERSIZE	= (1+16+1)<<1
TOPAZ_EIGHTY	= 8
TOPAZ_SIXTY	= 9

* struct Preferences
 rsreset
pf_FontHeight	rs.b 1
pf_PrinterPort	rs.b 1
pf_BaudRate	rs.w 1
pf_KeyRptSpeed	rs.b tv_SIZE
pf_KeyRptDelay	rs.b tv_SIZE
pf_DoubleClick	rs.b tv_SIZE
pf_PointerMatrix rs.w POINTERSIZE
pf_XOffset	rs.b 1
pf_YOffset	rs.b 1
pf_color17	rs.w 1
pf_color18	rs.w 1
pf_color19	rs.w 1
pf_PointerTicks rs.w 1
pf_color0	rs.w 1
pf_color1	rs.w 1
pf_color2	rs.w 1
pf_color3	rs.w 1
pf_ViewXOffset	rs.b 1
pf_ViewYOffset	rs.b 1
pf_ViewInitX	rs.w 1
pf_ViewInitY	rs.w 1
pf_EnableCLI	rs.w 1
pf_PrinterType	rs.w 1
pf_PrinterFilename rs.b FILENAME_SIZE
pf_PrintPitch	rs.w 1
pf_PrintQuality rs.w 1
pf_PrintSpacing rs.w 1
pf_PrintLeftMargin rs.w 1
pf_PrintRightMargin rs.w 1
pf_PrintImage	rs.w 1
pf_PrintAspect	rs.w 1
pf_PrintShade	rs.w 1
pf_PrintThreshold rs.w 1
pf_PaperSize	rs.w 1
pf_PaperLength	rs.w 1
pf_PaperType	rs.w 1
pf_SerRWBits	rs.b 1
pf_SerStopBuf	rs.b 1
pf_SerParShk	rs.b 1
pf_LaceWB	rs.b 1
pf_WorkName	rs.b FILENAME_SIZE
pf_RowSizeChange rs.b 1
pf_ColumnSizeChange rs.b 1
pf_PrintFlags	rs.w 1
pf_PrintMaxWidth rs.w 1
pf_PrintMaxHeight rs.w 1
pf_PrintDensity rs.w 1
pf_PrintXOffset rs.w 1
pf_wb_Width	rs.w 1
pf_wb_Height	rs.w 1
pf_wb_Depth	rs.b 1
pf_ext_size	rs.b 1
pf_SIZEOF	rs.w 0

LACEWB		= 1
PARALLEL_PRINTER = 0
SERIAL_PRINTER	= 1
BAUD_110	= 0
BAUD_300	= 1
BAUD_1200	= 2
BAUD_2400	= 3
BAUD_4800	= 4
BAUD_9600	= 5
BAUD_19200	= 6
BAUD_MIDI	= 7
FANFOLD 	= 0
SINGLE		= $80
PICA		= $000
ELITE		= $400
FINE		= $800
DRAFT		= $000
LETTER		= $100
SIX_LPI 	= $000
EIGHT_LPI	= $200
IMAGE_POSITIVE	= 0
IMAGE_NEGATIVE	= 1
ASPECT_HORIZ	= 0
ASPECT_VERT	= 1
SHADE_BW	= 0
SHADE_GREYSCALE = 1
SHADE_COLOR	= 2
US_LETTER	= $00
US_LEGAL	= $10
N_TRACTOR	= $20
W_TRACTOR	= $30
CUSTOM		= $40
CUSTOM_NAME	= $00
ALPHA_P_101	= $01
BROTHER_15XL	= $02
CBM_MPS1000	= $03
DIAB_630	= $04
DIAB_ADV_D25	= $05
DIAB_C_150	= $06
EPSON		= $07
EPSON_JX_80	= $08
OKIMATE_20	= $09
QUME_LP_20	= $0A
HP_LASERJET	= $0B
HP_LASERJET_PLUS = $0C
SBUF_512	= $00
SBUF_1024	= $01
SBUF_2048	= $02
SBUF_4096	= $03
SBUF_8000	= $04
SBUF_16000	= $05
SREAD_BITS	= $F0
SWRITE_BITS	= $0F
SSTOP_BITS	= $F0
SBUFSIZE_BITS	= $0F
SPARITY_BITS	= $F0
SHSHAKE_BITS	= $0F
SPARITY_NONE	= $00
SPARITY_EVEN	= $01
SPARITY_ODD	= $02
SHSHAKE_XON	= $00
SHSHAKE_RTS	= $01
SHSHAKE_NONE	= $02
CORRECT_RED	= $0001
CORRECT_GREEN	= $0002
CORRECT_BLUE	= $0004
CENTER_IMAGE	= $0008
IGNORE_DIMENSIONS = $0000
BOUNDED_DIMENSIONS = $0010
ABSOLUTE_DIMENSIONS = $0020
PIXEL_DIMENSIONS    = $0040
MULTIPLY_DIMENSIONS = $0080
INTEGER_SCALING     = $0100
ORDERED_DITHERING   = $0000
HALFTONE_DITHERING  = $0200
FLOYD_DITHERING     = $0400
ANTI_ALIAS	    = $0800
GREY_SCALE2	    = $1000
CORRECT_RGB_MASK    = (CORRECT_RED+CORRECT_GREEN+CORRECT_BLUE)
DIMENSIONS_MASK     = (BOUNDED_DIMENSIONS+ABSOLUTE_DIMENSIONS+PIXEL_DIMENSIONS+MULTIPLY_DIMENSIONS)
DITHERING_MASK	    = (HALFTONE_DITHERING+FLOYD_DITHERING)

 endc

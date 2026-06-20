

#ifndef LIBRARIES_CGXVIDEO_H
#define LIBRARIES_CGXVIDEO_H

#include <exec/types.h>

typedef APTR    VLayerHandle;


#define VOA_LeftIndent    0x88000001
#define VOA_RightIndent   0x88000002
#define VOA_TopIndent     0x88000003
#define VOA_BottomIndent  0x88000004

#define VOA_SrcType     0x88000005
#define VOA_SrcWidth    0x88000006
#define VOA_SrcHeight   0x88000007

#define VOA_Error       0x88000008

#define VOA_UseColorKey	0x88000009

#define VOA_UseBackfill 0x8800000a

#define VOA_BaseAddress 0x88000030
#define VOA_ColorKeyPen 0x88000031
#define VOA_ColorKey    0x88000032




#define VOERR_OK                0       
#define VOERR_INVSCRMODE        1       
#define VOERR_NOOVLMEMORY       2       
#define VOERR_INVSRCFMT         3       
#define VOERR_NOMEMORY          4       




#define SRCFMT_YUV16    0
#define SRCFMT_YCbCr16  1
#define SRCFMT_RGB15PC  2	
#define SRCFMT_RGB16PC  3	

#endif

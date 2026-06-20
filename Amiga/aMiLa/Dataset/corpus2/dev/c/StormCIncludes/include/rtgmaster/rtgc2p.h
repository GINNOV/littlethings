#include <exec/types.h>

struct c2p_Info
{
    WORD    CI_ColorDepth;           //CI_256, CI_128, CI_64, CI_EHB, CI_32..
    WORD    CI_CPU;                  //CI_68060, CI_68040, CI_68030....
    WORD    CI_Needs;                //CI_Aikiko, CI_MMU, CI_FPU...
    BYTE    CI_Dirty;                //TRUE/FALSE
    BYTE    CI_Hack;                 //TRUE/FALSE
    ULONG   CI_PixelSize;            //c2p_1x1...
    WORD    CI_WidthAlign;           //Width has to be divisible by <number>
    WORD    CI_HeightAlign;          //Height has to be divisible by <number>
    WORD    CI_Misc;                 //Different stuff...
    ULONG   CI_AmiCompatible;        //Is this compatible to RtgScreenAMI ?
    APTR    CI_Description;          //Pointer to a string
    APTR    CI_Initialization;       //Pointer to Initialization code
    APTR    CI_Expunge;              //Pointer to Expunge code
    APTR    CI_Normal_c2p;           //Pointer to c2p code
    APTR    CI_Normal_c2p_InterL;    //Pointer to Interleaved c2p
    APTR    CI_Scrambled_c2p;        //Pointer to Scrambled c2p
    APTR    CI_Scrambled_c2p_InterL; //Pointer to Scrambled Interleaved c2p
    BYTE    CI_Asynchrone;           //TRUE/FALSE
};

// CI_Colordepth

#define CI_256 256
#define CI_128 128
#define CI_64  64
#define CI_EHB 32
#define CI_32  16
#define CI_16  8
#define CI_8   4
#define CI_4   2
#define CI_2   1

// CI_CPU

#define CI_68060 1
#define CI_68040 2
#define CI_68030 4
#define CI_68020 8
#define CI_68060D 16
#define CI_68040D 32
#define CI_68030D 64
#define CI_68020D 128

// CI_Needs

#define CI_68060N 1
#define CI_68040N 2
#define CI_68030N 4
#define CI_Aikiko 8
#define CI_MMU    16
#define CI_FPU    32
#define CI_FAST   64
#define CI_2MB    128

// CI_Misc

#define CI_Smaller 1
#define CI_Fixed   2
#define CI_Destruct 4

#define c2p_1x1 1
#define c2p_1x2 2
#define c2p_2x1 4
#define c2p_2x2 8
#define c2p_4x2 16
#define c2p_2x4 32
#define c2p_4x4 64
#define c2p_Best 128
#define c2p_Fastest 256
#define c2p_Selected 512
#define c2p_1x1D 1024
#define c2p_1x2D 2048
#define c2p_2x1D 4096
#define c2p_2x2D 8192
#define c2p_4x2D 16384
#define c2p_2x4D 32768
#define c2p_4x4D 65536
#define c2p_BestD 131072
#define c2p_FastestD 262144
#define c2p_SelectedD 524288

#define c2p_err_Wrong_C2P 1
#define c2p_err_Wrong_Depth 2
#define c2p_warn_Wrong_Pixelmode 3
#define c2p_err_Wrong_Windowsize 4
#define c2p_warn_divisible 5
#define c2p_err_hardware 6
#define c2p_err_memory 7
#define c2p_err_internal 8
#define c2p_warn_internal 9

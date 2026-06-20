
/*
 * t:x.h
 *
 *  MACHINE GENERATED WITH FDTOPRAGMA
 */

#ifndef ToccataBase_INLINE
#define ToccataBase_INLINE

#include <src:AmiPhone/toccata/include/clib/toccata_protos.h>


#ifndef ToccataBase_DECLARED
extern struct Library *ToccataBase;
#endif


#pragma libcall ToccataBase T_NextFrequency 1e 001
#pragma libcall ToccataBase T_FindFrequency 24 001
#pragma libcall ToccataBase T_SetPart 2a 801
#pragma libcall ToccataBase T_GetPart 30 001
#pragma libcall ToccataBase T_Capture 36 801
#pragma libcall ToccataBase T_Playback 3c 801
#pragma libcall ToccataBase T_Pause 42 001
#pragma libcall ToccataBase T_Stop 48 001
#pragma libcall ToccataBase T_StartLevel 4e 801
#pragma libcall ToccataBase T_StopLevel 54 00
#pragma libcall ToccataBase T_Expand 5a 1002
#pragma libcall ToccataBase T_SaveSettings 60 001
#pragma libcall ToccataBase T_LoadSettings 66 001
#pragma libcall ToccataBase T_RawPlayback 6c 801
#pragma libcall ToccataBase T_IoErr 72 00

#endif


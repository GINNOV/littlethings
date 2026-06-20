#ifndef MBE_MCC_H
#define MBE_MCC_H

/*
 * MBE.mcc © 1994 by Johannes Beigel
 * Registered MUI class, Serial Number: 0621
 *
 * $VER: MBE_mcc.h 1.0 (31.08.94)
 */

#ifndef LIBRARIES_MUI_H
#include <libraries/mui.h>
#endif

/**********************************************************************/

#define MUIC_MBE "MBE.mcc"

/* specify the MBE brush ID: */
#define MUIA_MBE_ID 0x826D0000 /* [I..] ULONG */

/* Macro Section: *****************************************************/

#define MBEObject MUI_NewObject( MUIC_MBE

#define MBEImage( id )\
  MBEObject,\
    NoFrame,\
    MUIA_Background, MUII_BACKGROUND,\
    MUIA_MBE_ID, id,\
  End

#define MBEButton( id )\
  MBEObject,\
    ButtonFrame,\
    MUIA_Background, MUII_ButtonBack,\
    MUIA_InputMode, MUIV_InputMode_RelVerify,\
    MUIA_Image_FreeHoriz, TRUE,\
    MUIA_Image_FreeVert, TRUE,\
    MUIA_MBE_ID, id,\
  End

/* Registered MBE Brushes: ********************************************/

#define MBEB_Tape_Down       0x026D0000
#define MBEB_Tape_Eject      0x026D0001
#define MBEB_Tape_Pause      0x026D0002
#define MBEB_Tape_Play       0x026D0003
#define MBEB_Tape_PlayBack   0x026D0004
#define MBEB_Tape_Record     0x026D0005
#define MBEB_Tape_SearchBack 0x026D0006
#define MBEB_Tape_SearchForw 0x026D0007
#define MBEB_Tape_SkipNext   0x026D0008
#define MBEB_Tape_SkipPrev   0x026D0009
#define MBEB_Tape_Stop       0x026D000A
#define MBEB_Tape_Up         0x026D000B

#endif /* MBE_MCC_H */


	IFND	IMAGES_FILLBAR_I
IMAGES_FILLBAR_I	SET 1

**
**  $VER:  fillbar.i 43.4 (13.2.97)
**
**  Definitions for the FILLBAR BOOPSI image class
**
**  (C) Copyright 1997 Antonio Santos.
**  All Rights Reserved
**

;*****************************************************************************

    IFND EXEC_TYPES_I
    INCLUDE "exec/types.i"
    ENDC

    IFND UTILITY_TAGITEM_H
    INCLUDE "utility/tagitem.i"
    ENDC

    IFND INTUITION_IMAGECLASS_I
    INCLUDE "intuition/imageclass.i"
    ENDC

;*****************************************************************************

FILLBAR_Dummy					equ (TAG_USER+$04000000)
FILLBAR_FrameAround				equ (FILLBAR_Dummy+1)
FILLBAR_FrameInside				equ (FILLBAR_Dummy+2)
FILLBAR_LabelLeft				equ (FILLBAR_Dummy+3)
FILLBAR_LabelRight				equ (FILLBAR_Dummy+4)
FILLBAR_LabelLeftString			equ (FILLBAR_Dummy+5)
FILLBAR_LabelRightString		equ (FILLBAR_Dummy+6)
FILLBAR_LabelInside				equ (FILLBAR_Dummy+7)
FILLBAR_Value					equ (FILLBAR_Dummy+8)
FILLBAR_BGPen					equ (IA_BGPen)
FILLBAR_FGPen					equ (IA_FGPen)
FILLBAR_FillPen					equ (FILLBAR_Dummy+11)

	ENDC	; IMAGES_FILLBAR_I
	

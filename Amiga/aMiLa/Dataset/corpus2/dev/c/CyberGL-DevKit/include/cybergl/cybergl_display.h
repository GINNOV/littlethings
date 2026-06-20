/*
**	$VER: cybergl_display.h 1.1 (09.04.97)
**	
**	Copyright © 1996-1997 by phase5 digital products
**      All Rights reserved.
**
*/

#ifndef  _CYBERGL_DISPLAY_H
#define  _CYBERGL_DISPLAY_H

#include "cybergl.h"

#define GLWA_Dummy	(TAG_USER + 299)

/* CyberGL specific tags */

#define GLWA_RGBAMode           GLWA_Dummy + 0
#define GLWA_OffsetX            GLWA_Dummy + 1
#define GLWA_OffsetY            GLWA_Dummy + 2
#define GLWA_Error              GLWA_Dummy + 3
#define GLWA_Buffered           GLWA_Dummy + 4

/* window specific tags */

#define GLWA_Left		WA_Left			
#define GLWA_Top		WA_Top			
#define GLWA_Width		WA_Width		
#define GLWA_Height		WA_Height		
#define GLWA_DetailPen		WA_DetailPen		
#define GLWA_BlockPen		WA_BlockPen		
#define GLWA_IDCMP		WA_IDCMP		
#define GLWA_Flags		WA_Flags		
#define GLWA_Gadgets		WA_Gadgets		
#define GLWA_Checkmark		WA_Checkmark		
#define GLWA_Title		WA_Title		
#define GLWA_ScreenTitle	WA_ScreenTitle		
#define GLWA_CustomScreen	WA_CustomScreen		
#define GLWA_MinWidth		WA_MinWidth		
#define GLWA_MinHeight		WA_MinHeight		
#define GLWA_MaxWidth		WA_MaxWidth		
#define GLWA_MaxHeight		WA_MaxHeight		
#define GLWA_InnerWidth		WA_InnerWidth		
#define GLWA_InnerHeight	WA_InnerHeight		
#define GLWA_PubScreenName	WA_PubScreenName	
#define GLWA_PubScreen		WA_PubScreen		
#define GLWA_PubScreenFallBack	WA_PubScreenFallBack	
#define GLWA_Colors		WA_Colors		
#define GLWA_Zoom		WA_Zoom		        
#define GLWA_MouseQueue		WA_MouseQueue		
#define GLWA_BackFill		WA_BackFill		
#define GLWA_RptQueue		WA_RptQueue		
#define GLWA_SizeGadget		WA_SizeGadget		
#define GLWA_DragBar		WA_DragBar		
#define GLWA_DepthGadget	WA_DepthGadget		
#define GLWA_CloseGadget	WA_CloseGadget		
#define GLWA_Backdrop		WA_Backdrop		
#define GLWA_ReportMouse	WA_ReportMouse		
#define GLWA_NoCareRefresh	WA_NoCareRefresh	
#define GLWA_Borderless		WA_Borderless		
#define GLWA_Activate		WA_Activate		
#define GLWA_RMBTrap		WA_RMBTrap		
#define GLWA_SimpleRefresh	WA_SimpleRefresh	
#define GLWA_SmartRefresh	WA_SmartRefresh		
#define GLWA_SizeBRight		WA_SizeBRight		
#define GLWA_SizeBBottom	WA_SizeBBottom		
#define GLWA_AutoAdjust		WA_AutoAdjust		
#define GLWA_GimmeZeroZero	WA_GimmeZeroZero	
#define GLWA_MenuHelp		WA_MenuHelp		
#define GLWA_NewLookMenus	WA_NewLookMenus		
#define GLWA_AmigaKey		WA_AmigaKey		
#define GLWA_NotifyDepth	WA_NotifyDepth		
#define GLWA_Pointer		WA_Pointer		
#define GLWA_BusyPointer	WA_BusyPointer		
#define GLWA_PointerDelay	WA_PointerDelay		
#define GLWA_TabletMessages	WA_TabletMessages	
#define GLWA_HelpGroup		WA_HelpGroup		
#define GLWA_HelpGroupWindow	WA_HelpGroupWindow	

#endif

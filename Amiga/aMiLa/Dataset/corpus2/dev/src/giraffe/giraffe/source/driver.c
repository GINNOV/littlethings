/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: driver.c                                */
/*    |< |          RTG interface code                        */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include "driver.h"
#include "common.h"

extern struct Library *EGSBase;
extern struct Library *EGSBlitBase;

E_Symbol g_Selectors[g_SelCount];

int opendriver( void )
{
  if(EGSBase = (struct Library *)OpenLibrary("egs.library",0))
    {
      g_PixelMsgName       = E_GetSymbol(E_WritePixelName);
      g_RectangleMsgName   = E_GetSymbol(E_RectFillName);
      g_CopyMsgName        = E_GetSymbol(E_CopyBitMapName);
      g_StencilMsgName     = E_GetSymbol(E_FillMaskName);
      g_Stencil2MsgName    = E_GetSymbol(E_FillMaskBackName);
      g_StencilPattMsgName = E_GetSymbol(E_FillMaskMPattName);
      g_BitBltMsgName      = E_GetSymbol(E_BitBltName);
      g_UnpackMsgName      = E_GetSymbol(E_UnpackName);

      if(EGSBlitBase=(struct Library *)OpenLibrary("egsblit.library",0))
	return 1;
      CloseLibrary(EGSBase);
    }
  return 0;
}

void closedriver( void )
{
  CloseLibrary(EGSBlitBase);
  CloseLibrary(EGSBase);
  return;
}

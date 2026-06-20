/*
**     $VER: Gadgets.c V0.01 (14-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 14-06-96  Version 0.01      Initial module
**
**  Gadgets.c contains all the necessary functions to control your
**  gadgets. Gadgets.c needs the file Gadgets.h for the defenitions
**  of your gadgets.
**
*/

#include <exec/types.h>
#include <intuition/gadgetclass.h>
#include <proto/gadtools.h>

#include "IFFConverter.h"
#include "Gadgets.h"


// Define variables
struct Gadget *FirstGadget = NULL;

UWORD FileMode   = FM_Single;
UWORD RenderMode = RM_Interleave;

// Define protos
void  GetGadgetStatus(ULONG, ULONG, ...);
void  InitGadgets(void);
void  UpdateGadgets(ULONG Commands, ...);

/*
**  InitGadgets()
**
**     Is were your Gadgets are initialized. For this function to work,
**     you need to include 'Gadgets.h'!!!
**
**  pre:  None.
**  post: None.
*/
void InitGadgets()
{
   UWORD i;
   ULONG Kind;
   struct Gadget * PreviousGadget;
   struct NewGadget *GadgetToAdd;
   APTR GadgetTags;
   APTR register _VisualInfo = VisualInfo;
   APTR register ConverterFont;

   if(SystemFont)
      ConverterFont = &System_8;
   else
      ConverterFont = NULL;
      
   if( PreviousGadget = CreateContext(&FirstGadget) )
   {
      for (i=0; i<GD_Sentinal; i++)
      {
         Kind = PanelGadgets[i].MyGadgetType;
         GadgetToAdd                       = &(PanelGadgets[i].mng);
         GadgetTags                        = PanelGadgets[i].MyGadgetTags;
         PanelGadgets[i].mng.ng_VisualInfo = _VisualInfo;
         PanelGadgets[i].mng.ng_TextAttr   = ConverterFont;

         if(!( GadgetIAddress[i] = PreviousGadget = CreateGadgetA(Kind, PreviousGadget, GadgetToAdd, GadgetTags) ))
            ErrorHandler( IFFerror_GadCreate, (APTR)i );
      }
   }
   else
      ErrorHandler( IFFerror_GadCreate, (APTR)-1 );
}


/*
**  GetGadgetStatus(GadID, Commands)
**
**     Gets the status of a gadget. Status checking is controled through
**     'Commands'.
**
**  pre:  GadID - ID of gadget to check its status.
**        Commands - TagList of commands of what to check.
**  post: None.
**
*/
void GetGadgetStatus(ULONG GadID, ULONG Commands, ...)
{
   GT_GetGadgetAttrsA(GadgetIAddress[GadID], PanelWindow, NULL, (struct TagItem *)&Commands);
}


/*
**  UpdateGadgets(Commands)
**
**     Updates gadgets. You can change an inactive gadget into an active
**     gadget and visa versa. It's also possible to change a gadget
**     alltogether.
**
**  pre:  Commands -> Tag List of commands to change the gadget.
**                    First  Tag: GadgetID,
**                    Second Tag: Pointer to a tag list of attributes.
**  post: None.
*/
void UpdateGadgets(ULONG Commands, ...)
{
   ULONG *WhatCommands = &Commands;
   
   while (*WhatCommands != TAG_DONE)
      GT_SetGadgetAttrsA( (struct Gadget *) GadgetIAddress[*WhatCommands++], PanelWindow, NULL, (struct TagItem *)*WhatCommands++);
}

#ifndef  OGT_OBJECTIVEGADTOOLSBASE_H
#define  OGT_OBJECTIVEGADTOOLSBASE_H   1
/*
** $Filename: OGT/ObjectiveGadToolsBase.h $
** $Release : 1.0                         $
** $Revision: 1.000                       $
** $Date    : 18/10/92                    $
**
**
** (C) Copyright 1991,1992 Davide Massarenti
**              All Rights Reserved
*/

struct ObjectiveGadToolsBase
{
   struct Library        ogt_Library;
   UBYTE                 ogt_Flags;

   void                 *ogt_SegList;

   struct GfxBase       *ogt_GfxBase;
   struct LayersBase    *ogt_LayersBase;
   struct Library       *ogt_DiskfontBase;
   struct IntuitionBase *ogt_IntuitionBase;
   struct Library       *ogt_UtilityBase;
   struct Library       *ogt_KeymapBase;
   struct Library       *ogt_GadToolsBase;
   struct Library       *ogt_AslBase;
   struct Library       *ogt_WorkbenchBase;
};

#endif /* OGT_OBJECTIVEGADTOOLSBASE_H */

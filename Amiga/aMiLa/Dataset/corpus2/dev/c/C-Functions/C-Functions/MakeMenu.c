
/* Program for generating menues dynamicaly */
/* (C)Copyright 1988 by Lars Thuring */

/* May be freely distributed and used for any purpose as long as
   the Copyright notice is left unchanged. */

/* 24 oct 1987 V1.0 */
/* 24 nov 1987 V1.1 Library version */
/* 18 jan 1988 V1.2 Adjusted to K&R return values */
/* 19 jan 1988 V1.3 Select box of menu increased
                    NULL terminated text pointer list */
/* 28 apr 1988 V1.4 Bug; ItemExcl must be long value */


#include <exec/types.h>
#include <intuition/intuition.h>

#define DOMENU 1
#define DOITEM 2
#define DOSUB  3
#define DOALT  4

USHORT IntuiTextLength();        /* Return length of txt in pixels */

VOID MakeMenu( Data, M, I, Txt)
UBYTE *Data[];          /* Pointers to the texts and options to use */
struct Menu M[];        /* The Menu structs */
struct MenuItem I[];    /* and the MenuItem structs */
struct IntuiText Txt[]; /* The IntuiText structs */
   {
USHORT ix=0;                     /* Index to current Data[] */
USHORT strings=0;                /* Number of Data[] to process */
USHORT Mix=0,Iix=0,Tix=0;        /* Currently working with ... */
USHORT PreviousItem;             /* Last item generated in current menu */
USHORT NotFirstItem;             /* Set when true */
USHORT NotFirstSubItem;          /* Set when true */
USHORT OptStart,OptEnd;          /* Position of [ and ] in Data[ix] */

USHORT ItemLow=0;        /* First Item for current Menu */
USHORT SubLow=0;         /* First SubItem for current Item */

USHORT MenuX,ItemX=0,ItemY,SubX,SubY;   /* Values ... */
USHORT MenuW,ItemW=0,SubW;              /* Current min widths */

USHORT Op;               /* What current string is about anyway  */
UBYTE *p,*p2;            /* Pointer to Data[ix] and start of text */
USHORT trash,i=0;

USHORT menuspace = 14;   /* Inter menutext space */
USHORT itemspace =  7;   /* Item ditto */
USHORT chrwidth  =  7;   /* default characterwidth */
USHORT chrheight = 10;   /* default characterheight */

UBYTE *ExclString = "abcdefghijklmnopqrstuvwxyz01234";   /* For xor */
ULONG  ItemExcl;

USHORT MenuFlag,ItemFlag;           /* Set to defaults and changed if */
APTR   ThisItem,OtherItem;          /* options selected indicate so.  */
USHORT Style;                       /* How to write texts */
UBYTE  ItemChr=' ';                 /* right-AMIGA key command */

   /* Function: count strings, set values and write them into structs */

   MenuX=1;

   FOREVER                                /* Count strings passed */
      if (NOT Data[strings++]) break;

   while (--strings)
      {
      p=p2=Data[ix];                      /* Pointers to the text data */
      OptStart=strinstr( p, '[' )-1;      /* Start of options...       */
      OptEnd=strinstr( p, ']' )-1;        /*               ...and end  */
      p[OptEnd]='\0';                     /* Split string into 2 strings */

      while (*p2++);                      /* Point at text to be shown */
      p[OptEnd]=']';                      /* Restore source string */

   /* Set the defaults */

      MenuFlag = MENUENABLED;
      ItemFlag = ITEMTEXT | ITEMENABLED | HIGHCOMP;
      ItemExcl = 0;
      ThisItem = (APTR) &Txt[Tix];
      OtherItem = ThisItem;
      Style = JAM1;

   /* Now determine parameters and fill in current structs */

      for (i=OptStart; i<OptEnd; i++)     /* Find user needs */
         {
         switch ( p[i] )
            {
         case '_':                  /* Right amiga-key select */
            ItemFlag |= COMMSEQ;
            ItemChr = p[++i];
            break;
         case 'A':            /* Alternate text for previous item */
            Op=DOALT;
            break;
         case 'B':                  /* Show select by drawing box */
            ItemFlag &= ~(HIGHCOMP | HIGHIMAGE | HIGHNONE);
            ItemFlag |= HIGHBOX;
            break;
         case 'C':
            ItemFlag |= CHECKIT;
            break;
         case 'D':                  /* Menu/Item is disabled at first */
            MenuFlag &= ~MENUENABLED;
            ItemFlag &= ~ITEMENABLED;
            break;
         case 'H':                  /* Begin on next column */
            ItemLow = Iix;
            ItemX += ItemW + itemspace;
            ItemY = ItemW = 0;
            break;
         case 'I':                  /* This is a MenuItem */
            Op=DOITEM;
            SubW = SubY = SubX = NotFirstSubItem = 0;
            break;
         case 'J':                  /* Use FrontPen and BackPen */
            Style = JAM2;
            break;
         case 'M':                  /* This is a menuheader */
            Op=DOMENU;
            ItemW = ItemY = ItemX = PreviousItem = 0;
            NotFirstItem = 0;
            if (Iix) Mix++;         /* Will err if no items for menu 0 */
            break;
         case 'N':                  /* No indication when selected */
            ItemFlag &= ~(HIGHCOMP | HIGHBOX | HIGHIMAGE);
            ItemFlag |= HIGHNONE;
            break;
         case 'S':                  /* This is subitem */
            Op=DOSUB;
            break;
         case 'V':                  /* Item is marked from start */
            ItemFlag |= CHECKIT|CHECKED;
            break;
         default:
            if (trash = strinstr(ExclString, p[i]))   /* MutualExclude ? */
               ItemExcl |= 1 << (trash-1);            /* Position is >=1 */
            break;
            }
         }


      if ( Op == DOMENU )
         {
         if (Mix) M[Mix-1].NextMenu = &M[Mix];
            else M[Mix].NextMenu = NULL;
         M[Mix].LeftEdge = MenuX;
         MenuW = (strlen(p2)+1) * chrwidth+6;
         MenuX += MenuW + menuspace;
         M[Mix].Width = MenuW;
         M[Mix].Flags = MenuFlag;
         M[Mix].MenuName = p2;
         }

      if ( Op == DOITEM || Op == DOSUB || Op == DOALT )
         {
         Txt[Tix].FrontPen  = 3;
         Txt[Tix].BackPen   = 2;
         Txt[Tix].DrawMode  = Style;
         Txt[Tix].LeftEdge  = 2;
         Txt[Tix].TopEdge   = 1;
         Txt[Tix].ITextFont = NULL;
         Txt[Tix].IText     = p2;
         Txt[Tix].NextText  = NULL;
         }

      if (Op==DOITEM)
         {
         if (NOT PreviousItem) ItemLow = Iix;
         trash = IntuiTextLength( &Txt[Tix] )+4;
         if (trash>ItemW)
            {
            ItemW = trash;
            for (i=ItemLow; i<Iix; i++)
               I[i].Width = ItemW;
            }

         if (NotFirstItem) I[PreviousItem].NextItem = &I[Iix];
            else M[Mix].FirstItem = &I[Iix];

         I[Iix].NextItem      = NULL;
         I[Iix].LeftEdge      = ItemX;
         I[Iix].TopEdge       = ItemY;
         I[Iix].Width         = ItemW;
         I[Iix].Height        = chrheight;
         I[Iix].Flags         = ItemFlag;
         I[Iix].MutualExclude = ItemExcl;
         I[Iix].ItemFill      = ThisItem;
         I[Iix].SelectFill    = NULL;
         I[Iix].Command       = ItemChr;
         I[Iix].SubItem       = NULL;

         ItemY += chrheight;
         PreviousItem = Iix;
         NotFirstItem = TRUE;
         Iix++;
         Tix++;
         }
       
      if (Op==DOSUB)
         {
         if (NOT NotFirstSubItem) SubLow = Iix;
         SubX = ItemX + ItemW - 5;
         trash = IntuiTextLength( &Txt[Tix] )+4;
         if (trash>SubW)
            {
            SubW=trash;
            for (i=SubLow; i<Iix; i++)
               I[i].Width = SubW;
            }

         if (NotFirstSubItem) I[Iix-1].NextItem = &I[Iix];
         else
            {
            I[PreviousItem].SubItem = &I[Iix];
            SubLow = Iix;
            }

         I[Iix].NextItem      = NULL;
         I[Iix].LeftEdge      = SubX;
         I[Iix].TopEdge       = SubY;
         I[Iix].Width         = SubW;
         I[Iix].Height        = chrheight;
         I[Iix].Flags         = ItemFlag;
         I[Iix].MutualExclude = ItemExcl;
         I[Iix].ItemFill      = ThisItem;
         I[Iix].SelectFill    = NULL;
         I[Iix].Command       = ItemChr;
         I[Iix].SubItem       = NULL;

         SubY += chrheight;
         NotFirstSubItem = TRUE;
         Tix++;
         Iix++;
         }

      if (Op == DOALT)
         {
         I[Iix-1].Flags       &= ~(HIGHCOMP | HIGHBOX | HIGHNONE);
         I[Iix-1].Flags       |= HIGHIMAGE;
         I[Iix-1].SelectFill   = OtherItem;
         Tix++;
         }

      ix++;       /* Process next string */
      }

   }  /* End of MakeMenu() */



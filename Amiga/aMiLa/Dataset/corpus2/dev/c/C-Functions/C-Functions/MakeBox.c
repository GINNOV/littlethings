
/* Program for drawing Assorted Boxes */
/* (C)Copyright 1988 by Lars Thuring */

/* May be freely distributed and used for any purpose as long as
   the Copyright notice is left unchanged. */

/* 20 feb 1988 V0.1  Created */
/* 21 feb 1988 V0.2  Coordinates from subroutine,
                     May call itself for better boxes */
/* 28 feb 1988 V0.3  GetCoords: perspective box */
/* 10 mar 1988 V0.4  Doesn't destroy command string,
                     Passing of text to be printed,
                     BackPen & FrontPen selectable,
                     Box 3 */
/* 24 apr 1988 V0.5  k*=10+mode[i++]-'0'; doesn't compile correct */
/* 16 may 1988 V0.6  Bug; JAM1 -> JAM2;
                     Solid background colour option added;
                     F, C & J options affect target rp;
                     Very persistant "bug"; adjust i-- after Adigit() */

#include <exec/types.h>
#include <intuition/intuition.h>

/*#define DEBUG */

#define XOFF   0
#define YOFF   1
#define HSPACE 3
#define VSPACE 3

VOID MakeBox();               /* Purpose of this ... */
SHORT GetBoxCoordinates();    /* Spinoff product */

   /* No Globals */

VOID MakeBox(rp,x,y,w,h,mode) /* Draw a selected box in rp */
struct RastPort *rp;          /* Rastport for controlling para's */
SHORT x,y,                    /* Offsets into raster */
      w,h;                    /* Size of (inner) box */
UBYTE *mode;                  /* String with drawing options */
   {
BOOL   Adigit();              /* Return TRUE if ASCII digit */

int i,j,k,                    /* trash */
    DrawDone=FALSE,           /* Flag for one draw only per call */
    Solid=FALSE;              /* Default no fill background */

UBYTE *BoxTypes="0123",       /* Allowed boxtypes */
      *p=NULL;                /* Flag and pointer */

UBYTE FrontPen=AUTOFRONTPEN,BackPen=AUTOBACKPEN; /* Default defaults */
SHORT DrawMode = (SHORT) rp->DrawMode;

struct Border MyBorder;          /* Use as stencil */
SHORT xy[15][2],                 /* Max number of turning points */
      Count=0;                   /* Default is n */

struct IntuiText MyText;         /* Stencil for text */

   /* Here we go */

#ifdef DEBUG
   printf("entry string = %s.\n", mode);
#endif

   if (NOT( j=strlen(mode)))     /* Return if nothing to work with */
      return;

   if (k=strinstr(mode,']'))     /* Is a text passed ? */
      {                          /* Then set parameters not supplied */
      if (h == 0)
         h = rp->TxHeight+HSPACE*2-1;
      if (w == 0)
         w = (strlen(mode)-k)*rp->TxWidth+VSPACE*2-1;
      }

   /* Then get caller wishes */

   for(i=0;i<j;i++)              /* Set options */
      {
      if (DrawDone)
         break;
      switch( mode[i] )
         {
         case 'B':                        /* Select new BackPen */
            k=0;
            while (Adigit(mode[++i]))     /* if followed by ASCII digit */
               k=k*10+mode[i]-'0';        /* Add digit */
            BackPen=k;                    /* Future: check against rp */
            i--;
            break;

         case 'C':
            DrawMode=COMPLEMENT;
            rp->DrawMode = (BYTE) DrawMode;
            break;

         case 'F':                        /* Select new FrontPen */
            k=0;
            while (Adigit(mode[++i]))     /* if followed by ASCII digit */
               k=k*10+mode[i]-'0';        /* Add digit */
            FrontPen=k;                   /* Future: check against rp */
            SetAPen( rp, FrontPen);
            i--;
            break;

         case 'J':                        /* The other DrawMode */
            DrawMode=JAM2;
            rp->DrawMode = (BYTE) DrawMode;
            break;

         case 'S':                        /* Fill in background (Solid) */
            Solid=TRUE;
            break;

         case ']':            /* Then rest is text */

            p=mode+i+1;       /* Pointer to text */
            DrawDone=TRUE;    /* Skip rest */
            break;

         default:                                  /* Boxes ? */
            if (k=strinstr(BoxTypes, mode[i]))
               {
               Count=GetBoxCoordinates(&xy[0][0],w,h,k-1,NULL);
               MakeBox(rp,x,y,w,h,mode+i+1);      /* Get next before end */
               DrawDone=TRUE;
               }
            break;
         }
      }

   /* Now render background, text and box, if any */

   if (Solid)           /* Fill background with solid colour */
      {
      rp->DrawMode = (BYTE) DrawMode;
      RectFill(rp, x,y, x+w,y+h);
      }

   if (p)               /* Print text if one was passed */
      {
      MyText.LeftEdge   = VSPACE;
      MyText.TopEdge    = HSPACE;
      MyText.FrontPen   = FrontPen;
      MyText.BackPen    = BackPen;
      MyText.DrawMode   = DrawMode;
      MyText.ITextFont  = NULL;
      MyText.IText      = p;
      MyText.NextText   = NULL;

      PrintIText(rp,&MyText,x,y);
      }


   if (Count)             /* Don't draw if not got anything */
      {
      MyBorder.LeftEdge   = 0;
      MyBorder.TopEdge    = 0;
      MyBorder.FrontPen   = FrontPen;
      MyBorder.BackPen    = BackPen;
      MyBorder.DrawMode   = DrawMode;
      MyBorder.Count      = Count;
      MyBorder.XY         = &xy[0][0];
      MyBorder.NextBorder = NULL;

      DrawBorder(rp,&MyBorder,x,y);       /* */
      }

   }  /* End of MakeBox */



SHORT GetBoxCoordinates(xy,w,h,func,Size) /* Set Coordinates for Boxes */
SHORT (*xy)[2];                           /* Where to store Coordinates */
SHORT w,h;                                /* Size of (inner) box */
SHORT Size;                               /* + size */
int func;                                 /* Selected Box */
   {
SHORT Count=0;
   switch (func)
      {

      case 1:                                      /* 1 - Dropshadow */
         xy[0][XOFF] = w+1,   xy[0][YOFF] = 3;
         xy[1][XOFF] = w+1,   xy[1][YOFF] = h+1;
         xy[2][XOFF] = 3,     xy[2][YOFF] = h+1;
         xy[3][XOFF] = 3,     xy[3][YOFF] = h+2;
         xy[4][XOFF] = w+2,   xy[4][YOFF] = h+2;
         xy[5][XOFF] = w+2,   xy[5][YOFF] = 3;
         xy[6][XOFF] = w+3,   xy[6][YOFF] = 3;
         xy[7][XOFF] = w+3,   xy[7][YOFF] = h+3;
         xy[8][XOFF] = 3,     xy[8][YOFF] = h+3;
         Count=9;
         break;

      case 2:                                /* 2 - Perspective box */
         xy[0][XOFF] = 1,      xy[0][YOFF] = -1;
         xy[1][XOFF] = w/10,   xy[1][YOFF] = -h/8;
         xy[2][XOFF] = w*9/10, xy[2][YOFF] = -h/8;
         xy[3][XOFF] = w-1,    xy[3][YOFF] = -1;
         Count=4;
         break;

      case 3:                                /* 3 - As 2 but fixed depth */
         xy[0][XOFF] = 1,      xy[0][YOFF] = -1;
         xy[1][XOFF] = 3,      xy[1][YOFF] = -3;
         xy[2][XOFF] = w-3,    xy[2][YOFF] = -3;
         xy[3][XOFF] = w-1,    xy[3][YOFF] = -1;
         Count=4;
         break;

      case -1:                                     /* = special */
         Count=9;                      /* Current max Count possible */
         break;

      case 0:
      default:                                     /*   - Box */
         xy[0][XOFF] = 0,   xy[0][YOFF] = 0;
         xy[1][XOFF] = w,   xy[1][YOFF] = 0;
         xy[2][XOFF] = w,   xy[2][YOFF] = h;
         xy[3][XOFF] = 0,   xy[3][YOFF] = h;
         xy[4][XOFF] = 0,   xy[4][YOFF] = 1;       /* else 0,0 twice */
         Count=5;
         break;
      }

   return(Count);

   } /* End of GetBoxCoordinates() */




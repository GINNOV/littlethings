
/* Program for generating simple requesters dynamicaly */
/* (C)Copyright 1988 by Lars Thuring */

/* May be freely distributed and used for any purpose as long as
   the Copyright notice is left unchanged. */

/* Fri 13 nov 1987 V1.0 Make #2 */
/*     24 nov 1987 V1.1 Library version */
/*     18 jan 1988 V1.2 Adjusted for standard return values */
/*     19 feb 1988 V1.3 *Data[] must be concluded by NULL pointer */
/*     24 apr 1988 V1.4 j*=10+p[++i]-'0'; does not compile correct,
                        Renamed from MakeSimpleReq.c */
/*     17 may 1988 V1.5 01:22 "Bug" found in mb.c also here -
                        adjust with i-- after ++i failed ... */
/*     11 sep 1988 V1.6 Rendering of yes/no text. Thanks AutoDocs. */

#include <exec/types.h>
#include <intuition/intuition.h>

#define THETEXT 0x01
#define YESTXT  0x02
#define NOTXT   0x04
#define STRUCTSIZE sizeof(struct IntuiText)

int MakeAutoRequest();     /* Purpose of this ... */

   /* No Globals */

int MakeAutoRequest(w,Data)  /* Make a requester in window w */
struct Window *w;              /* Return -1 if couldn't make it */
UBYTE  *Data[];                /* Else return TRUE or FALSE */
   {
USHORT IntuiTextLength();     /* Return length of txt in pixels */
BOOL   Adigit();              /* Return TRUE if ASCII digit */
UBYTE *MyMem,*AllocMem();     /* Our buffer somwhere */
USHORT MyMemorySize;          /* Size of memory area */

USHORT OpCode,link,i,j;       /* OpCode, mode and trash */
USHORT ix=0;                  /* Loop index for Data[] */
USHORT strings=0;             /* Number of string passed as argument */
UBYTE  *p, *p2;               /* Data pointers */
USHORT OptStart,OptEnd;       /* Area of options */
USHORT ReqW=10, ReqH=10;      /* Physical parameters */
USHORT WidestText=0;          /* To determine min width of requester */

UBYTE  FrontPen=AUTOFRONTPEN,BackPen=AUTOBACKPEN; /* Default defaults */
SHORT  LeftEdge=AUTOLEFTEDGE,TopEdge=AUTOTOPEDGE;
SHORT  Xtxt=LeftEdge, Ytxt=TopEdge;                   /* Init offsets */
USHORT Yc = 8;                                        /* Linespacing  */
USHORT DrawMode=AUTODRAWMODE;
struct TextAttr *MyTextFont=NULL;         /* Not likely to be changed */

struct IntuiText *them;                   /* "Casted" into place later */
struct IntuiText *Body=NULL,*Plus=NULL,*Minus=NULL;
struct IntuiText *Previous=NULL;
USHORT PFlags=NULL,MFlags=NULL;           /* For terminating requester */

/* Function: count strings, set values and write them into structs */


   FOREVER                                /* Count strings passed */
      if (NOT Data[strings++] ) break;

   MyMemorySize = STRUCTSIZE * strings;      /* The necessary area */
   MyMem = AllocMem( MyMemorySize, 0 );      /* Get it from anywhere */
   if (MyMem)
      them = (struct IntuiText *) MyMem;     /* */
   else
      return (-1);            /* If couldn't get memory return error */

   while (--strings)
      {
      p=p2=Data[ix];                      /* Pointers to the text data */
      OptStart=strinstr( p, '[' )-1;      /* Start of options...       */
      OptEnd=strinstr( p, ']' )-1;        /*               ...and end  */
      p[OptEnd]='\0';                     /* Split string into 2 strings */

      while (*p2++);                      /* Point at text to be shown */
      p[OptEnd]=']';

   /* Set the defaults */

      link = TRUE;            /* Untill Positive- / Negative- text */
      OpCode = THETEXT;

   /* Now determine parameters and fill in current structs */

      for (i=OptStart; i<OptEnd; i++)     /* Find user needs */
         {
         switch ( p[i] )
            {
         case 'B':                        /* Select new BackPen */
            j=0;
            while (Adigit(p[++i]))        /* if followed by ASCII digit */
               j=j*10+p[i]-'0';           /* Add digit */
            BackPen=j;                    /* Future: check against rp */
            i--;                          /* Adjust for Adigit() */
            break;

         case 'F':                        /* Select new FrontPen */
            j=0;
            while (Adigit(p[++i]))        /* if followed by ASCII digit */
               j=j*10+p[i]-'0';           /* Add digit */
            FrontPen=j;                   /* Future: check against rp */
            i--;                          /* Adjust for Adigit() */
            break;

         case 'J':                        /* Select new drawing mode */
            if (p[++i] == '2')
               DrawMode = JAM2;
            else
               DrawMode = JAM1;
            break;

         case 'L':                        /* Set new Linespacing */
            j=0;
            while (Adigit(p[++i]))        /* if followed by ASCII digit */
               j=j*10+p[i]-'0';           /* Add digit */
            Yc=j;                         /* No check on validity */
            i--;                          /* Adjust for Adigit() */
            break;

         case 'N':                        /* Negative text */
            link = NULL;
            OpCode = NOTXT;
            Minus = them;
            break;

         case 'P':                        /* Positive text */
            link = NULL;
            OpCode = YESTXT;
            Plus = them;
            break;

         case 'T':                        /* Information text */
            if (Body)
               break;
            OpCode = THETEXT;
            Body = them;
            break;

         default:
            break;
            }
         }

      them->FrontPen    = FrontPen;          /* Text pen */
      them->BackPen     = BackPen;           /* Paper pen */
      them->DrawMode    = DrawMode;          /* JAM1 or JAM2 */
      them->LeftEdge    = Xtxt;              /* X for this string */
      them->TopEdge     = Ytxt;              /* Y for this string */
      them->ITextFont   = MyTextFont;        /* NULL */
      them->IText       = p2;                /* Characters */
      them->NextText    = NULL;              /* May change later */
      if (link && ix)                        /* Never link 1st text */
         Previous->NextText = them;


      if (OpCode == THETEXT)
         {
         Ytxt += Yc;
         j = IntuiTextLength(them)+4*LeftEdge; /* Get length and compare */
         if (j > WidestText)
            WidestText=j;
         }


      Previous = them;
      them++;
      ix++;                /* Process next string */
      }

   j = WidestText+LeftEdge+LeftEdge;
   if (j > ReqW)
      ReqW=j;

   j = Ytxt+3*(Yc+TopEdge)+TopEdge;
   if(j > ReqH)
      ReqH=j;

   if (Plus)
      {
      Plus->LeftEdge = LeftEdge;
      Plus->TopEdge = 3;
      }

   if (Minus)
      {
      Minus->LeftEdge = LeftEdge;
      Minus->TopEdge = 3;
      }


   i = AutoRequest(w,Body,Plus,Minus,PFlags,MFlags,ReqW,ReqH);

   FreeMem( MyMem, MyMemorySize );

   return (int)(i);

   }  /* End of MakeSimpleRequest() */




BOOL Adigit( c )    /* Return true if c is ASCII digit */
UBYTE c;
   {
   return (BOOL) ( c>='0' && c<='9' ? TRUE : FALSE);
   }



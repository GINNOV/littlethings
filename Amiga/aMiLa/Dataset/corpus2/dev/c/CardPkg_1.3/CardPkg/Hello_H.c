/************************************************************

    TML's C Language Card Image Package  v1.1

    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/
#include <stdlib.h>
#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>

#ifdef AZTEC_C
  #include <functions.h>
  #define __far
#endif
#ifdef __SASC
  #include <clib/alib_protos.h>
  #include <clib/intuition_protos.h>
  #include <clib/graphics_protos.h>
  #include <clib/dos_protos.h>
  #include <clib/exec_protos.h>
#endif

#include "CardHImages.h"
#include "Cards.h"

extern UWORD       RangeRand( ULONG );
extern ULONG __far RangeSeed;

struct IntuitionBase *IntuitionBase;
struct GfxBase       *GfxBase;

#define INTUITION_REV 28
#define GRAPHICS_REV  28

struct Window *Window;
struct NewWindow newwindow =
  {
        20,13,   /* window XY origin relative to TopLeft of screen */
        569,158, /* window width and height */
        0,1,     /* detail and block pens */
        CLOSEWINDOW,    /* IDCMP flags */
        WINDOWDRAG  | WINDOWDEPTH |
        WINDOWCLOSE | ACTIVATE    | NOCAREREFRESH,  /* other window flags */
        NULL,   /* first gadget in gadget list */
        NULL,   /* custom CHECKMARK imagery */
        (UBYTE *)" Testing Card Images ",       /* window title */
        NULL,   /* custom screen pointer */
        NULL,   /* custom bitmap */
        5,5,    /* minimum width and height */
        0xffff,0xffff,  /* maximum width and height */
        WBENCHSCREEN    /* destination screen type */
  };

CardID_t cards[56]; /* 52 "normal" and 4 "special" cards */

void clear_a_card( int i ) /* Remove a single card. */
  {
    ShowHCard( Window->RPort,
               CARD_NONE,
               Window->BorderLeft + 2 + (i / 7) * (CARD_H_WIDTH +5),
               Window->BorderTop  + 2 + (i % 7) * (CARD_H_HEIGHT+2)
             );
  }

void clear_cards( void )  /* Clear all the cards. */
  {
    int i;
    for (i=0; i<56; i++)
      {
        clear_a_card( i );
        Delay( 5L );
      }
  }

void show_a_card( int i )  /* Shows a single card ( cards[i] ). */
  {
    ShowHCard( Window->RPort,
               cards[i],
               Window->BorderLeft + 2 + (i / 7) * (CARD_H_WIDTH +5),
               Window->BorderTop  + 2 + (i % 7) * (CARD_H_HEIGHT+2)
             );
  }

void show_cards( void )  /* Show all the cards. */
  {
    int i;
    for (i=0; i<56; i++)
      show_a_card( i );
  }

void bubble_sort_and_show( void )
  {
    CardID_t tmp;
    int i,j;

    for (j=0 ;j<56; j++)
      for (i=0; i<55; i++)
        if ( cards[i] > cards[i+1] )  /* CardID_t's can be compared. */
          {
            tmp = cards[i];
                  cards[i] = cards[i+1];
                             cards[i+1] = tmp;
            show_a_card( i );
            show_a_card( i+1);
            WaitTOF();
            WaitTOF();   /* Slow it down enough to see the swaps! */
          }
  }

main()
  {
   IntuitionBase = (struct IntuitionBase *)
      OpenLibrary("intuition.library",(long)INTUITION_REV);
   if(IntuitionBase == NULL)
      exit(FALSE);

   GfxBase = (struct GfxBase *)
      OpenLibrary("graphics.library",(long)GRAPHICS_REV);
   if(GfxBase == NULL)
      exit(FALSE);

   if(( Window = (struct Window *) OpenWindow(&newwindow)) == NULL)
      exit(FALSE);

   /* RangeRand() uses RangeSeed.  We need to set RangeSeed to something  */
   /* different each time we run.  Here's one way to do it...     */

   CurrentTime( &RangeSeed, &RangeSeed );

   if ( CardRange( &cards[ 0], 52, sizeof(cards[0]), SUIT_SPADES,  1 ) &&   /* Normal cards  */
        CardRange( &cards[52],  4, sizeof(cards[0]), SUIT_SPECIAL, 1 )    ) /* Special cards */
     {
       show_cards();
       SetWindowTitles( Window," Here are the cards!","Testing Horizontal Cards");
       Delay( 250 );

       Shuffle( cards, 56, sizeof(cards[0]) );
       show_cards();
       SetWindowTitles( Window," The Cards are Shuffled.", (UBYTE *)0xffffffff);
       Delay( 250 );

       SetWindowTitles( Window," Let's sort them with a Bubble sort.",(UBYTE *)0xffffffff);
       bubble_sort_and_show();

       SetWindowTitles( Window,"<--Close me, I'm done.",(UBYTE *)0xffffffff);
     }

    Wait(1L << Window->UserPort->mp_SigBit);
    clear_cards();
    CloseWindow (                   Window        );
    CloseLibrary( (struct Library *)IntuitionBase );
    CloseLibrary( (struct Library *)GfxBase       );

    return 0;
  }

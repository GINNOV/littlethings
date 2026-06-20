/*** Hello_VBig.c ***/

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

#include "CardVBigImages.h"
#include "Cards.h"

#define ShowCard     ShowVBigCard
#define CARD_HEIGHT  CARD_VBIG_HEIGHT
#define CARD_WIDTH   CARD_VBIG_WIDTH

extern UWORD       RangeRand( ULONG );
extern ULONG __far RangeSeed;

struct IntuitionBase *IntuitionBase;
struct GfxBase       *GfxBase;

#define INTUITION_REV 28
#define GRAPHICS_REV  28

struct Window *Window;
struct NewWindow newwindow =
  {
        20,20,   /* window XY origin relative to TopLeft of screen */
        10+7*(CARD_WIDTH+3), 19+2*(CARD_HEIGHT+2), /* window width and height */
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

#define CX(i) ( Window->BorderLeft + 2 + (i) % 7 * (CARD_WIDTH +3))
#define CY(i) ( Window->BorderTop  + 2 + (i) / 7 * (CARD_HEIGHT+2))
#define CARDS 14 /* A "normal" suit and 1 "special" card at a time */
CardID_t cards[CARDS];


void clear_a_card( int i ) /* Remove a single card. */
  {
    ShowCard( Window->RPort, CARD_NONE, CX(i), CY(i) );
  }

void clear_cards( void )  /* Clear all the cards. */
  {
    int i;
    for (i=0; i<CARDS; i++)
      {
        clear_a_card( i );
        Delay( 5L );
      }
  }

void show_a_card( int i )  /* Shows a single card ( cards[i] ). */
  {
    ShowCard( Window->RPort, cards[i], CX(i), CY(i) );
  }

void show_cards( void )  /* Show all the cards. */
  {
    int i;
    for (i=0; i<CARDS; i++)
      show_a_card( i );
  }

void bubble_sort_and_show( void )
  {
    CardID_t tmp;
    int i,j;

    for (j=0 ;j<CARDS; j++)
      for (i=0; i<(CARDS-1); i++)
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

void suit_loop( int suit, CardID_t special, char *screen_title )
  {
   if ( CardRange( &cards[      0], CARDS-1, sizeof(cards[0]), suit,  1 ) && /* Normal suit */
        CardRange( &cards[CARDS-1],       1, sizeof(cards[0]), CardSuit(special), CardRank(special) ) ) /* Special cards */
     {
       show_cards();
       SetWindowTitles( Window,"<--Click me!  Here's a suit of cards.",screen_title);
       Wait(1L << Window->UserPort->mp_SigBit);

       Shuffle( cards, CARDS, sizeof(cards[0]) );
       show_cards();
       SetWindowTitles( Window,"<--Click me again! The Cards are Shuffled.",(UBYTE *)0xffffffff);
       Wait(1L << Window->UserPort->mp_SigBit);

       SetWindowTitles( Window," Let's sort them with a Bubble sort.",(UBYTE *)0xffffffff);
       bubble_sort_and_show();
       SetWindowTitles( Window,"<--Click me, I'm done.",(UBYTE *)0xffffffff);
       Wait(1L << Window->UserPort->mp_SigBit);
     }
  }
main()
  {
   IntuitionBase = (struct IntuitionBase *)
      OpenLibrary("intuition.library", (long)INTUITION_REV);
   if(IntuitionBase == NULL)
      exit(FALSE);

   GfxBase = (struct GfxBase *)
      OpenLibrary("graphics.library", (long)GRAPHICS_REV);
   if(GfxBase == NULL)
      exit(FALSE);

   if(( Window = (struct Window *) OpenWindow(&newwindow)) == NULL)
      exit(FALSE);

   /* RangeRand() uses RangeSeed.  We need to set RangeSeed to something  */
   /* different each time we run.  Here's one way to do it...     */

   CurrentTime( &RangeSeed, &RangeSeed );

   suit_loop( SUIT_SPADES,   CARD_JOKER, "Testing SPADES (hearts, clubs, diamonds still to go).");
   suit_loop( SUIT_HEARTS,   CARD_BLACK, "Testing HEARTS (clubs, diamonds still to go).");
   suit_loop( SUIT_CLUBS,    CARD_BLANK, "Testing CLUBS (diamonds still to go).");
   suit_loop( SUIT_DIAMONDS, CARD_BACK,  "Testing DIAMONDS.");
   clear_cards();
   CloseWindow (                   Window        );
   CloseLibrary( (struct Library *)IntuitionBase );
   CloseLibrary( (struct Library *)GfxBase       );

   return 0;
  }

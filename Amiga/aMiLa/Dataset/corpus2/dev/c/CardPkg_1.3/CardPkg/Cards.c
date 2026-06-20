/************************************************************

    TML's C Language Card Image Package  v1.1
    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/

#include <exec/types.h>
#include "Cards.h"

BOOL CardColorSwapping = TRUE;

BOOL ValidCardID( CardID_t card )
  {
    BOOL retcode = FALSE;
    UWORD suit, rank;
    rank = card & 0x0ff;
    suit = card >> 8;
    switch ( suit )
      {
        case SUIT_SPADES   :
        case SUIT_CLUBS    :
        case SUIT_DIAMONDS :
        case SUIT_HEARTS   : if ( rank > 0 && rank < 14 )
                                retcode = TRUE;
                             break;
        case SUIT_SPECIAL  : if ( rank > 0 && rank < 5 )
                                retcode = TRUE;
                             break;
        default            : retcode = FALSE;
                             break;
      }
    return retcode;
  }

CardID_t CardID( UWORD Suit, UWORD Rank )
  {
    CardID_t card = 0;

    card = (Suit << 8) | Rank;
    if ( ValidCardID( card ) )
        return card;
      else
        return 0;
  }

UWORD CardSuit( CardID_t id )
  {
    UWORD suit;
    if ( ValidCardID( id ) )
        suit = id >> 8;
      else
        suit = 0;
    return suit;
  }

UWORD CardRank( CardID_t id )
  {
    UWORD rank;
    if ( ValidCardID( id ) )
        rank = id & 0x0ff;
      else
        rank = 0;
    return rank;
  }

BOOL CardRange( CardID_t *where, UWORD count, UWORD offset, UWORD suit, UWORD rank )
  {
    if ( !ValidCardID( CardID(suit, rank) ) )
      return FALSE;

    if ( suit == SUIT_SPECIAL )
        {
          while ( count )
            {
              *where = CardID( suit, rank );
              where = where + offset/sizeof(CardID_t);
              count--;
              rank = (rank % 4 ) + 1;
            }
        }
      else
        {
          while ( count )
            {
              *where = CardID( suit, rank );
              where = where + offset/sizeof(CardID_t);
              count--;
              rank = (rank % 13 ) + 1;
              if (rank == 1)
                suit = ( suit % 4 ) + 1;
            }
        }
    return TRUE;
  }

extern ULONG RangeRand( ULONG );

void Shuffle( CardID_t *where, UWORD count, UWORD offset )
  {
    ULONG i;
    CardID_t ci;
    CardID_t *wi, *wj;

    for (i=0; i<count; i++)
      {
        wi = where + i                  * offset/sizeof(CardID_t);
        wj = where + RangeRand( count ) * offset/sizeof(CardID_t);
        ci = *wi;
             *wi = *wj;
                   *wj = ci;
      }
  }


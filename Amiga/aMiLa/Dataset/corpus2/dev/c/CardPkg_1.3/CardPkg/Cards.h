/************************************************************

    TML's C Language Card Image Package  v1.1
    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/

#ifndef CARDS_H
#define CARDS_H   1
#include <exec/types.h>

#define SUIT_SPADES   1
#define SUIT_HEARTS   2
#define SUIT_CLUBS    3
#define SUIT_DIAMONDS 4
#define SUIT_SPECIAL  5

#define SUIT_FIRST    1
#define SUIT_LAST     5

#define RANK_ACE      1
#define RANK_JACK    11
#define RANK_QUEEN   12
#define RANK_KING    13

#define CARD_JOKER    0x0501
#define CARD_BLACK    0x0502
#define CARD_BLANK    0x0503
#define CARD_BACK     0x0504

#define CARD_NONE     0xffff

typedef UWORD CardID_t;

extern BOOL     ValidCardID( CardID_t CardID             );
extern UWORD    CardSuit   ( CardID_t CardID             );
extern UWORD    CardRank   ( CardID_t CardID             );
extern CardID_t CardID     ( UWORD    Suit,   UWORD Rank );

extern BOOL     CardRange( CardID_t *where,
                           UWORD     count,
                           UWORD     offset,
                           UWORD     firstSuit,
                           UWORD     firstRank);

extern void     Shuffle(   CardID_t *where,
                           UWORD     count,
                           UWORD     offset);

extern BOOL CardColorSwapping;
#endif


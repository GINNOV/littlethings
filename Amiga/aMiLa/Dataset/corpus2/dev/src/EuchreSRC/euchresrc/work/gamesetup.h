/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright ???
 **
 ** File             : gamesetup.h
 ** Created on       : Thursday, 07-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.03
 **
 ** Purpose
 ** -------
 **   Some basic program attributes
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 01-Oct-97   Rick Keller            increased value of L_BAUER to 14
 ** 27-Aug-97   Rick Keller            added struct Trick
 ** 25-Aug-97   Rick Keller            instituted GameInfo structure
 ** 07-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
//gamesetup.h

#define SPADES    0
#define CLUBS     1
#define HEARTS    2
#define DIAMONDS  3

#define NINE      0
#define TEN       1
#define JACK      2
#define QUEEN     3
#define KING      4
#define ACE       5

#define NINE_TRUMP  6
#define TEN_TRUMP   7
#define QUEEN_TRUMP 8
#define KING_TRUMP  9
#define ACE_TRUMP   10
#define R_BAUER     11
#define L_BAUER     14

#define NOT_BAUER   100

#define CALL_LENGTH 57
#define CALL_WIDTH  74

#define CARD_LENGTH 95
#define CARD_WIDTH  63

#define PLAYER_0        0
#define PLAYER_1        1
#define PLAYER_2        2
#define PLAYER_3        3

#define INITIAL_SETUP   4

#ifndef  BETA_VERSION
    #define BETA_VERSION
#endif

#ifndef CARDS_STRUCT
#define CARDS_STRUCT

struct Cards
{
    WORD suit;
    WORD value;
    WORD trumpvalue;
    WORD Rbauer;
    BOOL used;
    struct Image *CardImage;
    struct Image *hCardImage;
};

#endif

#ifndef HAND_STRUCT
#define HAND_STRUCT
struct Hand
{
    struct Cards MyHand[5];
    WORD BestSuit;
    WORD BestSuitValue;
    WORD NumSuits;
};

#endif

#ifndef GAMEINFO_STRUCT
#define GAMEINFO_STRUCT
struct GameInfo
{
    short dealer;
    WORD trump_suit;
    WORD who_called;
    BOOL alone;
};

#endif

#ifndef ROUNDHAND_STRUCT
#define ROUNDHAND_STRUCT
struct RoundHand
{
    WORD suit;
    WORD round_value;
    BOOL used;
    struct Image *showcard;
};

#endif

#ifndef TRICK_STRUCT
#define TRICK_STRUCT
struct Trick
{
    WORD card_value;
    WORD suit;
    WORD played_by;
};
#endif

#ifndef CARDTRACK_STRUCT
#define CARDTRACK_STRUCT
struct CardTrack
{
    WORD cards_played;
    BOOL nine_played;
    BOOL ten_played;
    BOOL jack_played;
    BOOL queen_played;
    BOOL king_played;
    BOOL ace_played;
    BOOL lbower_played;
    BOOL rbower_played;
};
#endif


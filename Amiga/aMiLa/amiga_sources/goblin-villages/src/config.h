#ifndef GUARD_CONFIG_H
#define GUARD_CONFIG_H

#include <clib/exec_protos.h> // Amiga typedefs

/* Project Compilation flags */
extern const UBYTE GAME_MEMLOG;
extern const UBYTE GAME_DEBUG;

extern const UWORD WINDOW_SCREEN_WIDTH;
extern const UWORD WINDOW_SCREEN_HEIGHT;
extern const UWORD WINDOW_SCREEN_BPP;

// Kolory palety
// Nie wyrzucaj tego póki nie wyra¿ê na to zgody
// Czasem w kodzie lepiej napisaæ nazwê koloru ni¿ siê domyœlaæ, co konkretnego
// rysuje dany kawa³ek kodu - zw³aszcza w tekstach i rectanglach
// TODO: wywaliæ sta³e i wrzuciæ dla palety Selura

#define COLOR_BLACK     0
#define COLOR_NAVY      1
#define COLOR_2         2
#define COLOR_3         3
#define COLOR_BROWN     4
#define COLOR_LTBROWN   5
// 6..7: cieliste
#define COLOR_6         6
#define COLOR_7         7
#define COLOR_YELLOW    8
#define COLOR_LTGREEN   9
#define COLOR_GREEN     10
#define COLOR_TURQUOISE 11
#define COLOR_DRKGREEN	12
#define COLOR_13        13
#define COLOR_14        14
#define COLOR_PURPLE    15
#define COLOR_16        16
#define COLOR_DRKBLUE   17
#define COLOR_BLUE      18
#define COLOR_LTBLUE    19
#define COLOR_MIST      20
#define COLOR_WHITE     21
#define COLOR_22        22
#define COLOR_23        23
#define COLOR_24        24
#define COLOR_25        25
#define COLOR_26        26
#define COLOR_DRKRED    27
#define COLOR_RED       28
#define COLOR_PINK      29
#define COLOR_30        30
#define COLOR_31        31
#define COLOR_32        32

/* Docs */
#define IN
#define OUT
#define INOUT

#endif
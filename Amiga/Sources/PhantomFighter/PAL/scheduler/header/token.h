#ifndef TOKEN_H
#define TOKEN_H
#include "displist.h"
#include <exec/types.h>

#define TOK_FASTER	0
#define TOK_LASER	1
#define TOK_DOUBLE	2
#define TOK_PLASMA	3
#define TOK_SIDE	4
#define TOK_HOMER	5
#define MAXTOKENS 6

typedef struct {
   DSP_DLE DLE;				/* DLE for token */
   BYTE CurImage;
   BYTE MaxDelay,Delay;			/* For slowing it down */
} TokenDescriptor;


#endif

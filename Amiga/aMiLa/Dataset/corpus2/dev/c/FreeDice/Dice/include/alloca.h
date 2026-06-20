
/*
 *  ALLOCA.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef ALLOCA_H
#define ALLOCA_H

extern __regargs void *_dice_alloca(long);

#define alloca		_dice_alloca

#endif


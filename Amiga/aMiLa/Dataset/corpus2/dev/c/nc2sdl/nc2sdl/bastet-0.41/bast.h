#ifndef __BAST_H
#define __BAST_H

void bast_init();
void calc_ratings();
int choose_piece();

#endif //__BAST_H

//blocks mnemonics (must be same order as game.c)
//letter=block shape...
enum{BL_I=0,BL_O, BL_J, BL_L, BL_Z, BL_S, BL_T};

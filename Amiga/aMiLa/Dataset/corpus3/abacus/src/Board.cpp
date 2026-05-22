/*
* This file is part of Abacus.
* Copyright (C) 1997 Kai Nickel
* 
* Abacus is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Abacus is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Abacus.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*****************************************************************************************
  Board.cpp
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
  03.01.1997
*****************************************************************************************/

#include "Board.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*****************************************************************************************
  statische Elemente
*****************************************************************************************/

const char Board::black = 'O';
const char Board::white = 'X';
const char Board::empty = '.';

const int  Board::next[61][6] =
{
  {-1, -1,  1,  6,  5, -1}, {-1, -1,  2,  7,  6,  0}, {-1, -1,  3,  8,  7,  1}, // 00
  {-1, -1,  4,  9,  8,  2}, {-1, -1, -1, 10,  9,  3}, {-1,  0,  6, 12, 11, -1}, // 03
  { 0,  1,  7, 13, 12,  5}, { 1,  2,  8, 14, 13,  6}, { 2,  3,  9, 15, 14,  7}, // 06
  { 3,  4, 10, 16, 15,  8}, { 4, -1, -1, 17, 16,  9}, {-1,  5, 12, 19, 18, -1}, // 09
  { 5,  6, 13, 20, 19, 11}, { 6,  7, 14, 21, 20, 12}, { 7,  8, 15, 22, 21, 13}, // 12
  { 8,  9, 16, 23, 22, 14}, { 9, 10, 17, 24, 23, 15}, {10, -1, -1, 25, 24, 16}, // 15
  {-1, 11, 19, 27, 26, -1}, {11, 12, 20, 28, 27, 18}, {12, 13, 21, 29, 28, 19}, // 18
  {13, 14, 22, 30, 29, 20}, {14, 15, 23, 31, 30, 21}, {15, 16, 24, 32, 31, 22}, // 21
  {16, 17, 25, 33, 32, 23}, {17, -1, -1, 34, 33, 24}, {-1, 18, 27, 35, -1, -1}, // 24
  {18, 19, 28, 36, 35, 26}, {19, 20, 29, 37, 36, 27}, {20, 21, 30, 38, 37, 28}, // 27
  {21, 22, 31, 39, 38, 29}, {22, 23, 32, 40, 39, 30}, {23, 24, 33, 41, 40, 31}, // 30
  {24, 25, 34, 42, 41, 32}, {25, -1, -1, -1, 42, 33}, {26, 27, 36, 43, -1, -1}, // 33
  {27, 28, 37, 44, 43, 35}, {28, 29, 38, 45, 44, 36}, {29, 30, 39, 46, 45, 37}, // 36
  {30, 31, 40, 47, 46, 38}, {31, 32, 41, 48, 47, 39}, {32, 33, 42, 49, 48, 40}, // 39
  {33, 34, -1, -1, 49, 41}, {35, 36, 44, 50, -1, -1}, {36, 37, 45, 51, 50, 43}, // 42
  {37, 38, 46, 52, 51, 44}, {38, 39, 47, 53, 52, 45}, {39, 40, 48, 54, 53, 46}, // 45
  {40, 41, 49, 55, 54, 47}, {41, 42, -1, -1, 55, 48}, {43, 44, 51, 56, -1, -1}, // 48
  {44, 45, 52, 57, 56, 50}, {45, 46, 53, 58, 57, 51}, {46, 47, 54, 59, 58, 52}, // 51
  {47, 48, 55, 60, 59, 53}, {48, 49, -1, -1, 60, 54}, {50, 51, 57, -1, -1, -1}, // 54
  {51, 52, 58, -1, -1, 56}, {52, 53, 59, -1, -1, 57}, {53, 54, 60, -1, -1, 58}, // 57
  {54, 55, -1, -1, -1, 59}                                                      // 60
};

/*
Spielfeld:
                 00  01  02  03  04

               05  06  07  08  09  10

             11  12  13  14  15  16  17

           18  19  20  21  22  23  24  25

         26  27  28  29  30  31  32  33  34

           35  36  37  38  39  40  41  42

             43  44  45  46  47  48  49

               50  51  52  53  54  55

                 56  57  58  59  60

Richtungen:

       0   1

    5    X    2

       4   3
*/


/*****************************************************************************************
  Kon- /Destruktor
*****************************************************************************************/

Board::Board()
{
	Clear();
}


/*****************************************************************************************
  Dir
*****************************************************************************************/

int Board::Dir(int a, int b)
{
  for (int i = 0; i < 6; i++)
    if (next[a][i] == b) return i;
  return -1;
}


/*****************************************************************************************
  outBalls()
*****************************************************************************************/

int Board::outBalls(char player) const
{
	return (player == white) ? outwhite : outblack;
}


/*****************************************************************************************
  Clear
*****************************************************************************************/

void Board::Clear()
{
  strcpy(field, "XXXXXXXXXXX..XXX.............................OOO..OOOOOOOOOOO");
  me  		 = white;
  you 		 = black;
	outwhite = 0;
	outblack = 0;
	value    = 0;
}


/*****************************************************************************************
  Show
*****************************************************************************************/

/*
#include <iostream.h>

void Board::Show() const
{
  int o = 0, i, j;
  for (i = 5; i < 10; i++)
  {
    for (j = 0; j < 10 - i; j++) cout << " ";
    for (j = 0; j < i; j++) cout << field[o + j] << " ";
    o += i;
    cout << "\n";
  }
  for (i = 8; i >= 5; i--)
  {
    for (j = 0; j < 10 - i; j++) cout << " ";
    for (j = 0; j < i; j++) cout << field[o + j] << " ";
    o += i;
    cout << "\n";
  }
};
*/


/*****************************************************************************************
  Save / Load
*****************************************************************************************/

BOOL Board::Save(char* filename)
{
  BOOL ok = FALSE;
  FILE* f = fopen(filename, "w");
  if (f) 
  {
    ok = (fwrite(this, 1, sizeof(Board), f) == sizeof(Board));
    fclose(f);
  }
  return ok;
}

BOOL Board::Load(char* filename)
{
  BOOL ok = FALSE;
  FILE* f = fopen(filename, "r");
  if (f)
  {
    ok = (fread(this, 1, sizeof(Board), f) == sizeof(Board));
    fclose(f);
  }
  return ok;
}


/*****************************************************************************************
	Test
*****************************************************************************************/

int Board::Test1(int ball1, int dir) const
{
  int pos = next[ball1][dir];
  if (pos == -1) return -1;               // O-
  if (field[pos] == you  ) return -2;     // OX
  if (field[pos] == empty) return 0;      // O.
                                          // OO
  pos = next[pos][dir];
  if (pos == -1) return -1;               // OO-
  if (field[pos] == empty) return 0;      // OO.
  if (field[pos] == you  )                // OOX
  {
    pos = next[pos][dir];
    if (pos == -1) return 1;              // OOX-
    if (field[pos] == empty) return 0;    // OOX.
    return -2;                            // OOXO oder OOXX
  }                                       // OOO

  pos = next[pos][dir];
  if (pos == -1) return -1;               // OOO-
  if (field[pos] == empty) return 0;      // OOO.
  if (field[pos] == me   ) return -5;     // OOOO
                                          // OOOX
  pos = next[pos][dir];
  if (pos == -1) return 1;                // OOOX-
  if (field[pos] == empty) return 0;      // OOOX.
  if (field[pos] == me   ) return -5;     // OOOXO
                                          // OOOXX
  pos = next[pos][dir];
  if (pos == -1) return 1;                // OOOXX-
  if (field[pos] == empty) return 0;      // OOOXX.
  return -5;                              // OOOXXX oder OOOXXO
};

int Board::Test(int ball1, int dir, int ball2, int ball3) const
{
  if (ball2 != -1)
  {
    if (next[ball2][dir] == -1) return -1;
    if (field[next[ball2][dir]] != empty) return -3;
    if (ball3 != -1)
    {
      if (next[ball3][dir] == -1) return -1;
      if (field[next[ball3][dir]] != empty) return -3;
    }
    if (next[ball1][dir] == -1) return -1;
    if (field[next[ball1][dir]] != empty) return -3;
    return 0;
  }
  else
  {
    return Test1(ball1, dir);
  }
};


/*****************************************************************************************
	Move
*****************************************************************************************/

#include <iostream.h>

char Board::ChangePosTo(int pos, char neu)
{
	char alt = field[pos];
	if (alt == neu) return alt;
	field[pos] = neu;

	int r = 0, a = 0, n = 0;
	for (int dir = 0; dir < 6; dir++)
	{
		int x = next[pos][dir];
		if      (x == -1) 	      r += 4;
		else if (field[x] == alt) a += 2;
		else if (field[x] == neu) n += 2;
	}

	if 			(alt == white) value += r - a;
	else if (alt == black) value += a - r;

	if      (neu == white) value += n - r;
	else if (neu == black) value += r - n;

	return alt;
}


void Board::Move1(int ball1, int dir)
{
	/*
	**	Toggle player
	*/

	char tmp = me;
	me  = you;
	you = tmp;

	/*
	**	Reihe pushen
	*/

	tmp = empty;

  do
  {
		tmp = ChangePosTo(ball1, tmp);
		if (tmp == empty) return;	// Ende der Reihe

		ball1 = next[ball1][dir];
		if (ball1 == -1)					// Ende des Brettes
		{
			if (me == black)
			{
				value += 1000;
				outblack++;
			}
			else
			{
				value -= 1000;
				outwhite++;
			}
			return;
		}
  }
  while (TRUE);
}

void Board::Move(int ball1, int dir, int ball2, int ball3)
{
  if (ball2 != -1)
  {
		ChangePosTo(next[ball1][dir], me	 );
		ChangePosTo(ball1						, empty);
		ChangePosTo(next[ball2][dir], me	 );
		ChangePosTo(ball2						, empty);
    if (ball3 != -1)
    {
			ChangePosTo(next[ball3][dir], me	 );
			ChangePosTo(ball3						, empty);
    }

		char tmp = me;
		me  = you;
		you = tmp;
  }
  else
  {
    Move1(ball1, dir);
  }
}


/*****************************************************************************************
  Evaluate
*****************************************************************************************/

inline int Board::Evaluate() const
{
	return (me == white) ? value : - value;
}


/*****************************************************************************************
  AlphaBeta
*****************************************************************************************/

const int INFINITY = 20000;

int Board::AlphaBeta(int depth, int alpha, int beta) const
{
	depth--;
	int best = - INFINITY;
	Board b;

  for (int pos = 60; pos >= 0; pos--)
  {
    if (field[pos] == me)
    {
      for (int dir = 5; dir >= 0; dir--)
      {
        if (Test1(pos, dir) >= 0)
				{
					b = *this;
					b.Move1(pos, dir);

					int v;
					if (depth)
						v = - b.AlphaBeta(depth, -beta, -alpha);
					else
						v = - b.Evaluate();

					if (v > best) 
					{
						best = v;
						if (best >= beta) return best;
						if (best > alpha) alpha = best;
					}

				}
			}
		}
	}

	return best;
}


/*****************************************************************************************
  PrincipalVariation
*****************************************************************************************/

int Board::PrincipalVariation(int depth, int alpha, int beta)
{
	if (!depth) return Evaluate();
	depth--;
	int dir = 5, pos = -1;

	Board b = *this;
	b.NextMove(pos, dir);
	int best = - b.PrincipalVariation(depth, -beta, -alpha);

	while (b.NextMove(pos, dir) && best < beta)
	{
		if (best > alpha) alpha = best;
		int value = - b.PrincipalVariation(depth, -alpha - 1, -alpha);
		if (value > alpha && value < beta) 
			best = - b.PrincipalVariation(depth, -beta, -value);
		else if (value > best)
			best = value;

		b = *this;
	}

	return best;
}


/*****************************************************************************************
  ComputerMove
*****************************************************************************************/

void Board::Computer_Move(Status& status, int tiefe)
{
  status.Update(0, (14 - outBalls(me))*6);
  int nr = 1;

  /*
	**	Zufallsfeld erzeugen
	*/

	int rpos[61], p, dest;
  for (p = 0; p < 61; p++) rpos[p] = -1;
  for (p = 0; p < 61; p++)
  {
		do {dest = Random(61);}
		while (rpos[dest] != -1);
		rpos[dest] = p;
  }

	int rdir[6];
  for (p = 0; p < 6; p++) rdir[p] = -1;
  for (p = 0; p < 6; p++)
  {
		do {dest = Random(6);}
		while (rdir[dest] != -1);
		rdir[dest] = p;
  }


  /*
	**	Alle Möglichkeiten testen
	*/

	int 	best = - INFINITY;
	Board bestboard;
	tiefe--;

  for (p = 0; p < 61 && !status.Break(); p++)
  {
    int pos = rpos[p];
    if (field[pos] == me)
    {
      for (int d = 0; d < 6 && !status.Break(); d++)
      {
				status.Update(nr++);
				int dir = rdir[d];
        if (Test1(pos, dir) >= 0)
				{
					Board b = *this;
					b.Move1(pos, dir);
					int test;
					if (tiefe)
						test = - b.AlphaBeta(tiefe, -INFINITY, +INFINITY);
					else
						test = - b.Evaluate();
					if (test > best) 
					{
						best = test;
						bestboard = b;
					}
				}	// if Test1 >= 0
			} // for dir
		}	// if me
	}	// for pos

  *this = bestboard;
};


/*****************************************************************************************
  Sucessors
*****************************************************************************************/

BOOL Board::NextMove(int &pos, int &dir)
{
	do
	{
		dir++;
		if (dir == 6)
		{
			dir = 0;
			pos++;
			if (pos == 61) return FALSE;
		}
	}
	while (field[pos] != me || Test1(pos, dir) < 0);
	Move1(pos, dir);
	return TRUE;
}

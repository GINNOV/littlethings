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
/*******************************************************************************
	Board_main.cpp
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
	Last Change: 27.09.1996
*******************************************************************************/

#include <iostream.h>
#include <string.h>

/*******************************************************************************
	BOOL
*******************************************************************************/

#ifndef TRUE
	typedef int BOOL;
	const TRUE  = 1;
	const FALSE = 0;
#endif


#include "Board.cpp"


/*******************************************************************************
	main
*******************************************************************************/

int main()
{
	Board b;
	b.Clear();

	BOOL running = TRUE;
	char player = b.white;
	while (running)
	{
		b.Show();
		cout << "\n\n          00 01 02 03 04                     \n"
				 << "         05 06 07 08 09 10                   \n"
				 << "       11 12 13 14 15 16 17           0 1   \n"
				 << "      18 19 20 21 22 23 24 25        5 X 2  \n"
				 << "     26 27 28 29 30 31 32 33 34       4 3   \n"
				 << "      35 36 37 38 39 40 41 42               \n"
				 << "       43 44 45 46 47 48 49                 \n"
				 << "        50 51 52 53 54 55                   \n"
				 << "         56 57 58 59 60                     \n\n"
				 << "Player " << player << " : ball#";
		int ball1, ball2, ball3, dir;
		cin >> ball1;
		cout << "           direction#";
		cin >> dir;
		cout << "           2nd ball#";
		cin >> ball2;
		if (ball2 != -1)
		{
			cout << "           3rd ball#";
			cin >> ball3;
		}
		cout << "\n";
		int res = b.Test(ball1, dir, ball2, ball3);
		if (res >= 0)
		{
			b.Move(ball1, dir, ball2, ball3);
			cout << "Kugeldifferenz: " << res;
			if (player == b.white) player = b.black; else player = b.white;
		}
		else
		{
			cout << "Fehlercode: " << res;
		}
		cout << "\n\n";
	};

	return 0;
};
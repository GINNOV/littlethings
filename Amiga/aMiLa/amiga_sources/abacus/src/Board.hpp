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
#ifndef INCLUDE_BOARD_HPP
#define INCLUDE_BOARD_HPP
/*****************************************************************************************
  Board.hpp
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
  03.01.1997
*****************************************************************************************/

#include "Status.hpp"


class Board
{
  public:

    char  field[62];                //  Spielfeld
    char  me, you;                  //  Aktiver Spieler und Gegenspieler

    static const char black;
    static const char white;
    static const char empty;
    static const int  next[61][6];

					Board();

		int 	outBalls(char player) const;

    /*
    **  Initialisierung mit Startboard
    */

    void 	Clear();

    /*
    **  Brett als ASCII-Kunstwerk nach cout schicken
    */

    //void Show() const;

    /*
    **  Testet, ob Zug legal ist.
    **  Es wird vorausgesetzt, dass alle drei Kugeln von der
    **  selben Farbe sind und in einer Reihe liegen. Sonst aber nichts.
    **
    **  Rueckgabewert:   1  eine Kugel des Gegeners flog raus
    **                   0  keine Kugel folg raus
    **                  -1  Fehler: eigene Kugel(n) rausgeschmissen
    **                  -2  Fehler: keine Uebermacht
    **                  -3  Fehler: seitlich nicht leer
    **                  -5  Fehler: sonstiges
    */

    int 	Test(int, int dir, int, int) const;

    /*
    **  Fuehrt Zug ungeprueft aus
    */

    void 	Move(int, int dir, int, int);

    /*
    **  Fuehrt Zug fuer 'me' aus
    */

    void 	Computer_Move(Status& status, int depth);

    /*
    **  Speichern und Laden
    */

    BOOL 	Save(char* filename);
    BOOL 	Load(char* filename);

    /*
    **  Retourniert Richtung, in der sich b von a befindet (oder -1)
    */

    static int Dir(int a, int b);

	private:

		int 	outwhite, outblack;							// Anz. der verlorenen Kugeln
		int		value;													// Bewertungsindex für white

		char  ChangePosTo(int pos, char neu);	// Ändert Position in neue Farbe und
																					// retourniert alte. Führt randwhite/black
																					// mit.


    int 	Test1			(int, int dir) const;
    void 	Move1		 (int, int dir);

		int 	Evaluate() const;

		int 	AlphaBeta(int depth, int alpha, int beta) const;

		int 	PrincipalVariation(int depth, int alpha, int beta);



		BOOL	NextMove(int &pos, int &dir);

};
#endif

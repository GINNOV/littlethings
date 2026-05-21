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
#ifndef INCLUDE_BOARDCLASS_HPP
#define INCLUDE_BOARDCLASS_HPP
/****************************************************************************************
  BoardClass.hpp
-----------------------------------------------------------------------------------------

  CL_BoardClass (Area)

-----------------------------------------------------------------------------------------
  02.01.1997
****************************************************************************************/

#include "System.hpp"

#include "MCC.hpp"
#include "Board.hpp"
#include "Tools.hpp"


extern MUI_CustomClass *CL_Board;

#define MUIA_Board_Board			   	   	(TAGBASE_KAI | 0x1201)	//  [.S.]
#define MUIM_Board_NewSettings 				(TAGBASE_KAI | 0x1202)
#define MUIM_Board_Undo		 	   				(TAGBASE_KAI | 0x1204)
#define MUIM_Board_Winner			  	   	(TAGBASE_KAI | 0x1205)
#define MUIM_Board_Load		 	   				(TAGBASE_KAI | 0x1206)
#define MUIM_Board_Save		 	   				(TAGBASE_KAI | 0x1207)
#define MUIM_Board_NewGame 	   				(TAGBASE_KAI | 0x1208)
#define MUIM_Board_ComputerMove				(TAGBASE_KAI | 0x1209)


struct Board_Data
{
  Board board, last_board;            //  Spielfeld und letztes
  int   update_mode;                  //  
  BOOL  setsels;                      //  Selections setzen od. löschen
	int		ball[3];											//  Selektierte Bälle
  BOOL  diff;                         //  Zeichnen im Vgl. zum last_board;

  BOOL  newsettings;

  void  GetCenterOf(int, int&, int&); //  Kreismittelpunkt von feld[nr] berechnen
  int   GetNrOf    (int, int);        //  Feldindex der Mausposition berechnen
	ULONG ActivePlayerNr();							//  Akt. Spieler als Nummer

  /*
  **  Graphik Context
  */

  LONG  pen1, pen2, pen3, pen4;
  int   dx, dy, rx, ry, mdx, mdy, mrx, mry,
        left, right, top, bottom, 
        width, height;
  WORD  areabuffer[1000];
  BOOL  dirs;                         //  Mögl. Züge anzeigen
};


SAVEDS ASM ULONG Board_Dispatcher(REG(a0) struct IClass* cl, 
                                  REG(a2) Object*        obj, 
                                  REG(a1) Msg            msg);
#endif

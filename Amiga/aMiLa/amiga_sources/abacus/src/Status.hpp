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
#ifndef INCLUDE_STATUS_HPP
#define INCLUDE_STATUS_HPP
/*****************************************************************************************
  Status.hpp
------------------------------------------------------------------------------------------

	Universelle Status-Klasse zum Überwachen und Unterbrechen von Vorgängen,
	sowie zur Fehlerrückgabe.

------------------------------------------------------------------------------------------
  29.12.1996
*****************************************************************************************/

#include <exec/exec.h>		// wegen BOOL


class Status
{
	protected:

		int   				err;

	public:

		/*
		**	Konstruktor
		*/

									Status():err(0)
									{
									};

		/*
		**	Zwischenmeldung
		*/

		virtual void 	Update(int done = -1, int max = -1)
									{
									};

		/*
		**	Soll Berechnung abgebrochen werden?
		*/

		virtual BOOL 	Break()
									{
										return err != 0;
									};

		/*
		**	Fehler speichern, verursacht auch Abbruch
		*/

		virtual void	setError(int e)
									{
										err = e;
									};

		/*
		**	Fehler in Erfahrung bringen (0 = kein Fehler)
		*/

		virtual int		getError()
									{
										return err;
									};
};




#endif

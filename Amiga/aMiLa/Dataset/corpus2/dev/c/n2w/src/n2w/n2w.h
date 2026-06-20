/*
   n2w.h
   Copyright 2000, Chris F.A. Johnson

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

*/

/* string to use in front of a negative number; may be changed with -N option */
#define N2W_NEGSTRING "minus"

/* not currently used (version 2.0??) */
#define N2W_NEGPOSTSTRING "below zero"

/* string to use (default "and") in such numbers as
 *	"one hundred and thirty-four";
 * may be changed to "&" with --ampersand or -&
 * or deleted altogether with -u or --nand (for the U.S.A.)
 */
#define N2W_AND_TEXT "and"

/* could be set to "00 cents" or whatever you like;
   no command line option yet programmed for this */
#define NO_CENTS_STRING "only"

char * n2w( double nn );
void hwords( int n );
void addspace( char *);

/* uncomment these if you wish to use these arrays in other modules */ /*
extern char * numbers[];
extern char * tens_numbers[];
extern char * unit_numbers[];
*/

/* allow these to be set by calling program */
extern char * n2w_negstring;
extern char * n2w_and_text;
extern char * n2w_unit_string;

/* not currently used */
extern char * n2w_negpoststring;


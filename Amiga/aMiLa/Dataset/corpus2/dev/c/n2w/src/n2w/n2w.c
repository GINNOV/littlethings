/*
   n2w -- Convert numbers to words (English only)

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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "defs.h"
#include "n2w.h"

char *number_words[] =
{
  "zero", "one", "two", "three", "four", "five",
  "six", "seven", "eight", "nine", "ten",
  "eleven", "twelve", "thirteen", "fourteen", "fifteen",
  "sixteen", "seventeen", "eighteen", "nineteen", "twenty" };

char *tens_number_words[] =
{
  "zero", "ten", "twenty", "thirty", "forty",
  "fifty", "sixty", "seventy", "eighty", "ninety"
};

char *unit_number_words[] =
{
  "", "thousand", "million", "billion", "trillion",
};

char *n2w_negstring = N2W_NEGSTRING;
char *n2w_negpoststring = N2W_NEGPOSTSTRING;
char *n2w_and_text;
char *n2w_unit_string = "";

char *n2w_buf;

/*
    n2w() takes a double argumnt, which it splits into unsigned long
    (integer portion) and double (for the decimal fraction).

    Possible improvements are:
	 1. allow use of full range of double precision floating point
	 2. use a text string to store the number before conversion

    However, as this was originally intended for printing cheques,
    I have no need (I wish!) for numbers exceeding a couple of
    billion and will probably never get around to it.
*/

char *
n2w (double nn)
{
  int neg = (nn < 0);
  unsigned long n = (unsigned long) nn;
  double d = 0;
  int tens;
  int hundreds;
  int thousands;
  int millions;
  int billions;

  n2w_buf = malloc ( 256 );
  if ( n2w_buf == NULL )
    {
      return NULL;
    }

  thousands = millions = billions = 0;

  n2w_buf[0] = '\0';

  if (nn == 0)
    {
      return NULL;
    }

  if (verbose & 64)
    {
      fprintf (stderr, "\tn2w:\tnn == %f\n", nn);
      fprintf (stderr, "\tn2w:\t n == %ld\n", n);
      fprintf (stderr, "\tn2w:\t d == %f\n", d);
    }

  tens = n % 100;

  if (neg)
    {
      n = (unsigned long) -nn;
      if (n2w_negstring && n2w_negstring[0])
	{
	  sprintf (n2w_buf, "%s ", n2w_negstring);
	}
      d = -nn - (double) n;
    }
  else
    {
      d = nn - (double) n;
    }

  hundreds = n % 1000;

  if (n >= 1000)
    {
      thousands = (n % 1000000) / 1000;
      millions = (n % 1000000000) / 1000000;
      billions = n / 1000000000;

      if (billions)
	{
	  hwords (billions % 1000);
	  addspace (NULL);
	  strcat (n2w_buf, unit_number_words[3]);
	}

      if (millions)
	{
	  hwords (millions % 1000);
	  addspace (NULL);
	  strcat (n2w_buf, unit_number_words[2]);
	}
      hwords (thousands % 1000);
      if (thousands)
	{
	  addspace (NULL);
	  strcat (n2w_buf, unit_number_words[1]);
	}

      if (tens && (hundreds < 100))
	{
	  addspace (NULL);
	  strcat (n2w_buf, n2w_and_text);
	}
    }

  if (verbose & 64)
    {
      fprintf (stderr, "\tn2w: %lu\n", n);
    }

  hwords (n % 1000);

  if (n2w_buf[0] == '\0')
    {
      strcat (n2w_buf, number_words[0]);
    }

  if (n2w_unit_string[0] && eq_nstr (n2w_unit_string, "dollar", 6))
    {
      addspace (NULL);
      strcat (n2w_buf, n2w_unit_string);
      if ( ( n == 1 ) && ( toupper( n2w_buf[ strlen(n2w_buf) - 1 ] ) == 'S' ) )
	{
	  /* a bit of a kludge to take care of singular unit */
	  n2w_buf[ strlen(n2w_buf) - 1 ] = '\0';
	}
    }

  if (d)
    {
      if (eq_nstr (n2w_unit_string, "dollar", 6))
	{
	  int cents = 0;
	  char cbuf[8];

	  cents = (int) (d * 100 + .5);
	  addspace (NULL);
	  if (verbose & 64)
	    {
	      fprintf (stderr, "%s\n", cbuf);
	    }
	  strcat (n2w_buf, n2w_and_text);
	  addspace (NULL);
	  sprintf (n2w_buf, "%s%d cents", n2w_buf, cents);
	}
      else
	{
	  char dbuf[32];
	  int dl = 2;
	  addspace (NULL);
	  strcat (n2w_buf, "point");
	  sprintf (dbuf, "%f", d);
	  while (dbuf[strlen (dbuf) - 1] == '0')
	    {
	      dbuf[strlen (dbuf) - 1] = '\0';
	      if (verbose & 128)
		{
		  fprintf (stderr, "%s\n", dbuf);
		}
	    }

	  if (verbose & 64)
	    {
	      fprintf (stderr, "dbuf: %s\n", dbuf);
	    }

	  while (dbuf[dl])
	    {
	      addspace (NULL);
	      strcat (n2w_buf, number_words[dbuf[dl] - '0']);
	      ++dl;
	    }
	}
    }
  else if (eq_nstr (n2w_unit_string, "dollar", 6))
    {
      addspace (NULL);
      strcat ( n2w_buf, NO_CENTS_STRING);
    }

  if (n2w_unit_string[0] && !eq_nstr (n2w_unit_string, "dollar", 6))
    {
      addspace (NULL);
      strcat (n2w_buf, n2w_unit_string);
      if ( ( n == 1 ) && (d == 0) && ( toupper( n2w_buf[ strlen(n2w_buf) - 1 ] ) == 'S' ) )
	{
	  /* a bit of a kludge to take care of singular unit */
	  n2w_buf[ strlen(n2w_buf) - 1 ] = '\0';
	}
    }

  return n2w_buf;
}

void
hwords (int num)
{
  int hundreds, tens;
  /* int digits; */

  if ((num < 1) || (num > 999))
    {
      return;
    }

  hundreds = num / 100;
  /* digits = num % 10; */
  tens = num % 100;

  if (hundreds)
    {
      addspace (NULL);
      strcat (n2w_buf, number_words[hundreds]);
      strcat (n2w_buf, " hundred");
    }

  if (num > 100 && tens)
    {
      addspace (NULL);
      strcat (n2w_buf, n2w_and_text);
    }

  if (tens)
    {
      if (tens <= 20)
	{
	  addspace (NULL);
	  strcat (n2w_buf, number_words[tens]);
	}
      else
	{
	  addspace (NULL);
	  strcat (n2w_buf, tens_number_words[tens / 10]);
	  if (tens % 10)
	    {
	      strcat (n2w_buf, "-");
	      strcat (n2w_buf, number_words[tens % 10]);
	    }
	}
    }
}

void
addspace (char *str)
{
  char *s;
  int len;

  if (str == NULL)
    {
      s = n2w_buf;
    }
  else
    {
      s = str;
    }

  len = strlen (s);

  if (s[0] && (s[len - 1] != ' '))
    {
      /* is it more efficient to use strcat? */
      s[len] = ' ';
      s[len + 1] = '\0';
    }
}


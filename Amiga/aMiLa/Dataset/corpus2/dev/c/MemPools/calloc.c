/**
***  MemPools:  malloc() replacement using standard Amiga pool functions.
***  Copyright  (C)  1994    Jochen Wiedmann
***    changes       1998    Matthias Andree
***
***  This program is free software; you can redistribute it and/or modify
***  it under the terms of the GNU General Public License as published by
***  the Free Software Foundation; either version 2 of the License, or
***  (at your option) any later version.
***
***  This program is distributed in the hope that it will be useful,
***  but WITHOUT ANY WARRANTY; without even the implied warranty of
***  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***  GNU General Public License for more details.
***
***  You should have received a copy of the GNU General Public License
***  along with this program; if not, write to the Free Software
***  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
***
***
***  This file contains the calloc() replacement.
***
***
***  Computer:  Amiga 4000
***
***  Compilers: gcc 2.7.2
***             SAS/C 6.58
***
***
***  Author:    Jochen Wiedmann
***             Am Eisteich 9
***       72555 Metzingen
***             Germany
***
***             Phone: (0049) 7123 14881
***             Internet: jochen.wiedmann@uni-tuebingen.de
***
***  Bugfixes
***  Updates:   Matthias Andree
***             Stormstr. 14
***             58099 Hagen
***             Germany
***
***             Phone: +49-(0)23 31-96 30 72
***
***             E-Mail: mandree@dosis.uni-dortmund.de
***
**/




/*
    Include files and compiler specific stuff
*/
#include <stdlib.h>
#include <string.h>



void *calloc(size_t size, size_t numobjs)

{
    void *ptr;

    if ((size *= numobjs)) {
	if ((ptr = malloc(size))) {
	    memset(ptr, '\0', size);
	    return(ptr);
	}
    }
    return(NULL);
}

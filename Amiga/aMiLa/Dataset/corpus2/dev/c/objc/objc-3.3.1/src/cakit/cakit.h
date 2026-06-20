
/*
 * Computer Algebra Kit (c) 1993,2000 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cakit.h,v 1.14 2009/10/23 19:36:43 stes Exp $
 */

/*
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published 
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef __cakit__
#define __cakit__

#define __cakit_revision__ "3.0.1"

/* include ctype.h first (freebsd2.1.7 otherwise has missing rune_t
 * in the -D_POSIX_SOURCE case)
 */
#include <ctype.h>		/* isdigit() */

#include "cobject.h"

#include "cseq.h"
#include "ccltn.h"

#include "cseqc.h"
#include "ccltnsq.h"
#include "ccltnsqr.h"

#include "cfloat.h"
#include "ccomplex.h"
#include "integer.h"
#include "fraction.h"
#include "intmodp.h"

#include "matrix.h"
#include "vector.h"

#include "matsq.h"
#include "matsqsq.h"
#include "vectorc.h"
#include "ovectorc.h"
#include "ovectors.h"
#include "mvectorc.h"
#include "mvectors.h"
#include "ivectorc.h"
#include "ivectors.h"

#include "term.h"
#include "symbol.h"
#include "monomial.h"
#include "polynom.h"

#include "polyrseq.h"
#include "polyeseq.h"
#include "polycseq.h"

#include "monomc.h"
#include "dmonomc.h"
#include "dmonoms.h"
#include "smonomc.h"

#include "polc.h"

#include "srspolc.h"
#include "osrspolc.h"

#include "drspolc.h"
#include "odrspolc.h"
#include "odrspols.h"
#include "idrspolc.h"
#include "idrspols.h"
#include "mdrspolc.h"
#include "mdrspols.h"

#include "drdpolc.h"
#include "odrdpolc.h"
#include "odrdpols.h"
#include "idrdpolc.h"
#include "idrdpols.h"
#include "mdrdpolc.h"
#include "mdrdpols.h"

#include "sespolc.h"
#include "osespolc.h"

#include "despolc.h"
#include "odespolc.h"
#include "odespols.h"
#include "idespolc.h"
#include "idespols.h"
#include "mdespolc.h"
#include "mdespols.h"

#ifndef ODD
#define ODD(x)  (((x)&1) == 1)
#define EVEN(x) (((x)&1) == 0)
#endif

#ifndef MAX
#define MAX(x,y) (((x)>(y))?(x):(y))
#define MIN(x,y) (((x)<(y))?(x):(y))
#endif

/* exception handling return values */
#define SUCCESS (BOOL)0
#define FAILURE (BOOL)1

/* convenience macro */
#define strEq(x,y) (0 == strcmp((x),(y)))

#endif /* __cakit__ */
 

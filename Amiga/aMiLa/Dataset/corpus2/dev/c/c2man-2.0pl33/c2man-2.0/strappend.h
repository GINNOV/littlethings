/* $Id: strappend.h,v 2.0.1.1 1993/05/31 01:38:48 greyham Exp $
 * concatenate a list of strings, storing them in a malloc'ed region
 */
#include "config.h"

char *strappend _V((char *first, ...));

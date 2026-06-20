/* $Id: strconcat.h,v 2.0.1.1 1993/05/17 02:11:47 greyham Exp $
 * concatenate a list of strings, storing them in a malloc'ed region
 */
#include "config.h"

char *strconcat _V((const char *first, ...));

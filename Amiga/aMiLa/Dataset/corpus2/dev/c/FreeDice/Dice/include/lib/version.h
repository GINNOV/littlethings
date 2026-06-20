
/*
 *  LIB/VERSION.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef _LIB_VERSION_H
#define _LIB_VERSION_H

#define VERSION "V2.06"

#define DCOPYRIGHT static char *DCopyright = "(c)Copyright 1990 by Matthew Dillon, All Rights Reserved"

#ifdef REGISTERED
#define IDENT(file,subv)   static char *Ident = "@($)" file " " VERSION subv "R " __DATE__
#else
#define IDENT(file,subv)   static char *Ident = "@($)" file " " VERSION subv "  " __DATE__
#endif


#endif

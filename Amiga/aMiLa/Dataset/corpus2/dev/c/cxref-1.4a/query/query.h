/***************************************
  $Header: /home/amb/cxref/query/RCS/query.h 1.3 1996/02/24 14:53:52 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.0
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/


#ifndef QUERY_H
#define QUERY_H    /*+ To stop multiple inclusions. +*/

/* In input.c */

void LoadInCrossRefs(void);

/* In output.c */

void OutputCrossRef(char* name);

#endif /* QUERY_H */

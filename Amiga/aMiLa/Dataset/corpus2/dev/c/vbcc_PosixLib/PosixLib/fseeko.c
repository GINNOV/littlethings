/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2020
 *
 * $Id: fseeko.c,v 1.1 2020/10/06 09:24:09 phx Exp $
 */

#include <stdio.h>


int fseeko(FILE *f,off_t o,int w)
{
  return fseek(f,o,w);
}

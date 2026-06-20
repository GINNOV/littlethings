/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2020
 *
 * $Id: ftello.c,v 1.1 2020/10/06 09:24:09 phx Exp $
 */

#include <stdio.h>


off_t ftello(FILE *f)
{
  return (off_t)ftell(f);
}

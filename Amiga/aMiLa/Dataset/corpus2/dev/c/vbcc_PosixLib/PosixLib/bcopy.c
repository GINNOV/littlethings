/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003
 *
 * $Id: bcopy.c,v 1.3 2015/06/28 18:28:19 phx Exp $
 */

#include <string.h>


void bcopy(const void *src, void *dst, size_t len)
{
  memcpy(dst,src,len);
}

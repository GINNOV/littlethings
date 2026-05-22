/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2021
 *
 * $Id: endian.h,v 1.1 2021/08/18 10:49:11 phx Exp $
 */

#ifndef _SYS_ENDIAN_H_
#define _SYS_ENDIAN_H_

#define _LITTLE_ENDIAN  1234
#define _BIG_ENDIAN     4321
#define _PDP_ENDIAN     3412

#include <machine/endian_machdep.h>

#define LITTLE_ENDIAN   1234
#define BIG_ENDIAN      4321
#define PDP_ENDIAN      3412
#define BYTE_ORDER      _BYTE_ORDER

#endif  /* _SYS_ENDIAN_H_ */

/*	Some files including in this file are copyright by Tomasz Kaczanowski.
	You can use it for free, but you must add info about using this code
    and info about author. Remember also, that if you want to have new
    versions of this code and other codes for AmigaOS-like systems you
    should motivate author of this code. You can send him a small gift
    or mail or bug report.

    contact:
       kaczus (at) poczta (_) onet (_) pl
       or
       kaczus (at) wp (_) pl
    Don't forget also about Krashan!!!
*/
#ifndef _PROTO_TTENGINE_H
#define _PROTO_TTENGINE_H

#ifndef CLIB_TTENGINE_PROTOS_H
#include <clib/ttengine_protos.h>
#endif

#ifdef __GNUC__
#ifndef __PPC__
#include <inline/ttengine.hpp>
#else
#include <ppcinline/ttengine.hpp>
#endif
#elif defined(__VBCC__)
#ifndef __PPC__
#include <inline/ttengine_protos.hpp>
#endif
#else
#include <pragma/ttengine_lib.hpp>
#endif

#endif  /*  _PROTO_TTENGINE_H  */

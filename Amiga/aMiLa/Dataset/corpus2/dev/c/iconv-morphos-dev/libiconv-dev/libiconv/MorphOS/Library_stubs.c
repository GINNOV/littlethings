#include <proto/exec.h>
#include <exec/execbase.h>
#include <dos/dosextens.h>

#include <stddef.h>

#include "Library.h"

#ifdef BUILD_BASEREL_LIBRARY
asm
("
	.section \".text\"
	.align 2
	.type __restore_r13, @function
__restore_r13:
	lwz 13, 36(12)
	blr
__end__restore_r13:
	.size __restore_r13, __end__restore_r13 - __restore_r13
");
#endif

#define	PROTO(ret, name) ret name(int dummy1, int dummy2, int dummy3, int dummy4, int dummy5); ret SAVEDS ICONV_##name(int dummy1, int dummy2, int dummy3, int dummy4, int dummy5) { ((struct Process *)SysBase->ThisTask)->pr_Result2 = 0; return name(dummy1, dummy2, dummy3, dummy4, dummy5); }

typedef void * iconv_t;
PROTO(iconv_t, libiconv_open)
PROTO(size_t, libiconv)
PROTO(int, libiconv_close)
PROTO(int, libiconvctl)
PROTO(void, libiconvlist)
PROTO(void, libiconv_set_relocation_prefix)
PROTO(const char *, iconv_canonicalize)

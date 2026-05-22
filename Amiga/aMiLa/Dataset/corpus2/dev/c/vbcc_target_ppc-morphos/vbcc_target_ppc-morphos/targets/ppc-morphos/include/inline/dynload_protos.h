#ifndef _VBCCINLINE_DYNLOAD_H
#define _VBCCINLINE_DYNLOAD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void * __dlopen(const char * filename, int flags, void *) =
	"\tlwz\t0,-28(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define dlopen(filename, flags) __dlopen((filename), (flags), DynLoadBase)

int __dlclose(void * handle, void *) =
	"\tlwz\t0,-34(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define dlclose(handle) __dlclose((handle), DynLoadBase)

void * __dlsym(void * handle, const char * symbol, void *) =
	"\tlwz\t0,-40(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define dlsym(handle, symbol) __dlsym((handle), (symbol), DynLoadBase)

int __dladdr(const void * addr, Dl_info * info, void *) =
	"\tlwz\t0,-46(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define dladdr(addr, info) __dladdr((addr), (info), DynLoadBase)

const char * __dlerror(, void *) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define dlerror() __dlerror(, DynLoadBase)

#endif /*  _VBCCINLINE_DYNLOAD_H  */

#ifndef _VBCCINLINE_RESOURCE_H
#define _VBCCINLINE_RESOURCE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

RESOURCEFILE __RL_OpenResource(void *, APTR resource, struct Screen * screen, struct Catalog * catalog) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define RL_OpenResource(resource, screen, catalog) __RL_OpenResource(ResourceBase, (resource), (screen), (catalog))

VOID __RL_CloseResource(void *, RESOURCEFILE resfile) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define RL_CloseResource(resfile) __RL_CloseResource(ResourceBase, (resfile))

Object * __RL_NewObjectA(void *, RESOURCEFILE resfile, RESOURCEID resid, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define RL_NewObjectA(resfile, resid, tags) __RL_NewObjectA(ResourceBase, (resfile), (resid), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
Object * __linearvarargs __RL_NewObject(void *, RESOURCEFILE resfile, RESOURCEID resid, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define RL_NewObject(resfile, ...) __RL_NewObject(ResourceBase, (resfile), __VA_ARGS__)
#endif

VOID __RL_DisposeObject(void *, RESOURCEFILE resfile, Object * obj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define RL_DisposeObject(resfile, obj) __RL_DisposeObject(ResourceBase, (resfile), (obj))

Object ** __RL_NewGroupA(void *, RESOURCEFILE resfile, RESOURCEID id, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define RL_NewGroupA(resfile, id, taglist) __RL_NewGroupA(ResourceBase, (resfile), (id), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
Object ** __linearvarargs __RL_NewGroup(void *, RESOURCEFILE resfile, RESOURCEID id, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define RL_NewGroup(resfile, ...) __RL_NewGroup(ResourceBase, (resfile), __VA_ARGS__)
#endif

VOID __RL_DisposeGroup(void *, RESOURCEFILE resfile, Object ** obj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define RL_DisposeGroup(resfile, obj) __RL_DisposeGroup(ResourceBase, (resfile), (obj))

Object ** __RL_GetObjectArray(void *, RESOURCEFILE resfile, Object * obj, RESOURCEID id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define RL_GetObjectArray(resfile, obj, id) __RL_GetObjectArray(ResourceBase, (resfile), (obj), (id))

BOOL __RL_SetResourceScreen(void *, RESOURCEFILE resfile, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define RL_SetResourceScreen(resfile, screen) __RL_SetResourceScreen(ResourceBase, (resfile), (screen))

#endif /*  _VBCCINLINE_RESOURCE_H  */

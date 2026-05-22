#ifndef _VBCCINLINE_HASHTABLE_H
#define _VBCCINLINE_HASHTABLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __CreateHashTableTagList(CONST struct TagItem * taglist) =
	"\tlis\t11,HashTableBase@ha\n"
	"\tlwz\t12,HashTableBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CreateHashTableTagList(taglist) __CreateHashTableTagList((taglist))

VOID __DeleteHashTable(CONST_APTR hashtable, void *) =
	"\tlwz\t0,-34(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define DeleteHashTable(hashtable) __DeleteHashTable((hashtable), HashTableBase)

VOID __ClearHashTable(CONST_APTR hashtable, void *) =
	"\tlwz\t0,-40(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ClearHashTable(hashtable) __ClearHashTable((hashtable), HashTableBase)

size_t __GetHashTableAttribute(CONST_APTR hashtable, size_t attr, void *) =
	"\tlwz\t0,-46(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetHashTableAttribute(hashtable, attr) __GetHashTableAttribute((hashtable), (attr), HashTableBase)

BOOL __GetHashKeyByData(CONST_APTR hashtable, CONST_APTR data, size_t * keyptr, void *) =
	"\tlwz\t0,-52(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetHashKeyByData(hashtable, data, keyptr) __GetHashKeyByData((hashtable), (data), (keyptr), HashTableBase)

BOOL __GetHashDataByKey(CONST_APTR hashtable, size_t key, APTR * dataptr, void *) =
	"\tlwz\t0,-58(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetHashDataByKey(hashtable, key, dataptr) __GetHashDataByKey((hashtable), (key), (dataptr), HashTableBase)

BOOL __RemoveHashByData(CONST_APTR hashtable, CONST_APTR data, size_t * keyptr, void *) =
	"\tlwz\t0,-64(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RemoveHashByData(hashtable, data, keyptr) __RemoveHashByData((hashtable), (data), (keyptr), HashTableBase)

BOOL __RemoveHashByKey(CONST_APTR hashtable, size_t key, APTR * dataptr, void *) =
	"\tlwz\t0,-70(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RemoveHashByKey(hashtable, key, dataptr) __RemoveHashByKey((hashtable), (key), (dataptr), HashTableBase)

BOOL __InsertHash(CONST_APTR hashtable, size_t key, CONST_APTR data, void *) =
	"\tlwz\t0,-76(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define InsertHash(hashtable, key, data) __InsertHash((hashtable), (key), (data), HashTableBase)

size_t __IterateHashTable(CONST_APTR hashtable, BOOL (*iteratorfunc)(CONST_APTR, size_t, APTR, APTR), APTR userdata, void *) =
	"\tlwz\t0,-82(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IterateHashTable(hashtable, iteratorfunc, userdata) __IterateHashTable((hashtable), (iteratorfunc), (userdata), HashTableBase)

size_t __ResizeHashTable(CONST_APTR hashtable, void *) =
	"\tlwz\t0,-88(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ResizeHashTable(hashtable) __ResizeHashTable((hashtable), HashTableBase)

#endif /*  _VBCCINLINE_HASHTABLE_H  */

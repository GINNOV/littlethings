#ifndef _VBCCINLINE_NEWICON_H
#define _VBCCINLINE_NEWICON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct NewDiskObject * __GetNewDiskObject(void *, UBYTE * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define GetNewDiskObject(name) __GetNewDiskObject(NewIconBase, (name))

BOOL __PutNewDiskObject(void *, UBYTE * name, struct NewDiskObject * diskobj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define PutNewDiskObject(name, diskobj) __PutNewDiskObject(NewIconBase, (name), (diskobj))

void __FreeNewDiskObject(void *, struct NewDiskObject * diskobj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeNewDiskObject(diskobj) __FreeNewDiskObject(NewIconBase, (diskobj))

struct Image * __RemapChunkyImage(void *, struct ChunkyImage * MyChunkyImage, struct Screen * MyScreen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define RemapChunkyImage(MyChunkyImage, MyScreen) __RemapChunkyImage(NewIconBase, (MyChunkyImage), (MyScreen))

VOID __FreeRemappedImage(void *, struct Image * MyImage, struct Screen * MyScreen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define FreeRemappedImage(MyImage, MyScreen) __FreeRemappedImage(NewIconBase, (MyImage), (MyScreen))

struct NewDiskObject * __GetDefNewDiskObject(void *, LONG def_type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GetDefNewDiskObject(def_type) __GetDefNewDiskObject(NewIconBase, (def_type))

#endif /*  _VBCCINLINE_NEWICON_H  */

#ifndef _VBCCINLINE_BZ2_H
#define _VBCCINLINE_BZ2_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

const char * __BZ2_bzlibVersion() =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzlibVersion() __BZ2_bzlibVersion()

int __BZ2_bzCompressInit(bz_stream * a1, int a2, int a3, int a4) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzCompressInit(a1, a2, a3, a4) __BZ2_bzCompressInit((a1), (a2), (a3), (a4))

int __BZ2_bzCompress(bz_stream * a1, int a2) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzCompress(a1, a2) __BZ2_bzCompress((a1), (a2))

int __BZ2_bzCompressEnd(bz_stream * a1) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzCompressEnd(a1) __BZ2_bzCompressEnd((a1))

int __BZ2_bzDecompressInit(bz_stream * a1, int a2, int a3) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzDecompressInit(a1, a2, a3) __BZ2_bzDecompressInit((a1), (a2), (a3))

int __BZ2_bzDecompress(bz_stream * a1) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzDecompress(a1) __BZ2_bzDecompress((a1))

int __BZ2_bzDecompressEnd(bz_stream * a1) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzDecompressEnd(a1) __BZ2_bzDecompressEnd((a1))

int __BZ2_bzBuffToBuffCompress(char * a1, unsigned int * a2, char * a3, unsigned int a4, int a5, int a6, int a7) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzBuffToBuffCompress(a1, a2, a3, a4, a5, a6, a7) __BZ2_bzBuffToBuffCompress((a1), (a2), (a3), (a4), (a5), (a6), (a7))

int __BZ2_bzBuffToBuffDecompress(char * a1, unsigned int * a2, char * a3, unsigned int a4, int a5, int a6) =
	"\tlis\t11,BZ2Base@ha\n"
	"\tlwz\t12,BZ2Base@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define BZ2_bzBuffToBuffDecompress(a1, a2, a3, a4, a5, a6) __BZ2_bzBuffToBuffDecompress((a1), (a2), (a3), (a4), (a5), (a6))

#endif /*  _VBCCINLINE_BZ2_H  */

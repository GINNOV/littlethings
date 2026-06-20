#ifndef _VBCCINLINE_MPEGA_H
#define _VBCCINLINE_MPEGA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

MPEGA_STREAM * __MPEGA_open(void *, char * stream_name, MPEGA_CTRL * ctrl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MPEGA_open(stream_name, ctrl) __MPEGA_open(MPEGABase, (stream_name), (ctrl))

void __MPEGA_close(void *, MPEGA_STREAM * mpds) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define MPEGA_close(mpds) __MPEGA_close(MPEGABase, (mpds))

LONG __MPEGA_decode_frame(void *, MPEGA_STREAM * mpds, WORD * pcm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MPEGA_decode_frame(mpds, pcm) __MPEGA_decode_frame(MPEGABase, (mpds), (pcm))

LONG __MPEGA_seek(void *, MPEGA_STREAM * mpds, ULONG ms_time_position) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define MPEGA_seek(mpds, ms_time_position) __MPEGA_seek(MPEGABase, (mpds), (ms_time_position))

LONG __MPEGA_time(void *, MPEGA_STREAM * mpds, ULONG * ms_time_position) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define MPEGA_time(mpds, ms_time_position) __MPEGA_time(MPEGABase, (mpds), (ms_time_position))

LONG __MPEGA_find_sync(void *, BYTE * buffer, LONG buffer_size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MPEGA_find_sync(buffer, buffer_size) __MPEGA_find_sync(MPEGABase, (buffer), (buffer_size))

LONG __MPEGA_scale(void *, MPEGA_STREAM * mpds, LONG scale_percent) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define MPEGA_scale(mpds, scale_percent) __MPEGA_scale(MPEGABase, (mpds), (scale_percent))

#endif /*  _VBCCINLINE_MPEGA_H  */

#ifndef _VBCCINLINE_AC97MIXER_H
#define _VBCCINLINE_AC97MIXER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __AC97ReadIndex(void *, void * MixerObject, ULONG Offset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AC97ReadIndex(MixerObject, Offset) __AC97ReadIndex(AC97MixerBase, (MixerObject), (Offset))

LONG __AC97WriteIndex(void *, void * MixerObject, ULONG Offset, ULONG Data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AC97WriteIndex(MixerObject, Offset, Data) __AC97WriteIndex(AC97MixerBase, (MixerObject), (Offset), (Data))

LONG __AC97GetMixerAttr(void *, void * MixerObject, ULONG attr, void * valueptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AC97GetMixerAttr(MixerObject, attr, valueptr) __AC97GetMixerAttr(AC97MixerBase, (MixerObject), (attr), (valueptr))

LONG __AC97SetMixerAttr(void *, void * MixerObject, ULONG attr, LONG value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AC97SetMixerAttr(MixerObject, attr, value) __AC97SetMixerAttr(AC97MixerBase, (MixerObject), (attr), (value))

LONG __AC97GetInputAttr(void *, void * MixerObject, ULONG index, ULONG attr, void * valueptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AC97GetInputAttr(MixerObject, index, attr, valueptr) __AC97GetInputAttr(AC97MixerBase, (MixerObject), (index), (attr), (valueptr))

LONG __AC97SetInputAttr(void *, void * MixerObject, ULONG index, ULONG attr, LONG value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AC97SetInputAttr(MixerObject, index, attr, value) __AC97SetInputAttr(AC97MixerBase, (MixerObject), (index), (attr), (value))

LONG __AC97GetOutputAttr(void *, void * MixerObject, ULONG index, ULONG attr, void * valueptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define AC97GetOutputAttr(MixerObject, index, attr, valueptr) __AC97GetOutputAttr(AC97MixerBase, (MixerObject), (index), (attr), (valueptr))

LONG __AC97SetOutputAttr(void *, void * MixerObject, ULONG index, ULONG attr, LONG value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define AC97SetOutputAttr(MixerObject, index, attr, value) __AC97SetOutputAttr(AC97MixerBase, (MixerObject), (index), (attr), (value))

LONG __AC97AddMixerNotify(void *, void * MixerObject, ULONG type, struct Hook * hook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define AC97AddMixerNotify(MixerObject, type, hook) __AC97AddMixerNotify(AC97MixerBase, (MixerObject), (type), (hook))

LONG __AC97RemMixerNotify(void *, void * MixerObject, struct Hook * hook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define AC97RemMixerNotify(MixerObject, hook) __AC97RemMixerNotify(AC97MixerBase, (MixerObject), (hook))

LONG __AC97AddCodec(void *, struct AC97Mixer_CodecObject * CodecObject) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define AC97AddCodec(CodecObject) __AC97AddCodec(AC97MixerBase, (CodecObject))

VOID __AC97RemCodec(void *, struct AC97Mixer_CodecObject * CodecObject) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define AC97RemCodec(CodecObject) __AC97RemCodec(AC97MixerBase, (CodecObject))

void * __AC97AddCodecTagList(void *, struct AC97Mixer_CodecObject * CodecObject, CONST struct TagItem * TagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define AC97AddCodecTagList(CodecObject, TagList) __AC97AddCodecTagList(AC97MixerBase, (CodecObject), (TagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void * __linearvarargs __AC97AddCodecTags(void *, struct AC97Mixer_CodecObject * CodecObject, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define AC97AddCodecTags(CodecObject, ...) __AC97AddCodecTags(AC97MixerBase, (CodecObject), __VA_ARGS__)
#endif

VOID __AC97RemCodecByID(void *, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define AC97RemCodecByID(id) __AC97RemCodecByID(AC97MixerBase, (id))

#endif /*  _VBCCINLINE_AC97MIXER_H  */

#ifndef _VBCCINLINE_CAMD_H
#define _VBCCINLINE_CAMD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __LockCAMD(void *, ULONG locktype) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LockCAMD(locktype) __LockCAMD(CamdBase, (locktype))

void __UnlockCAMD(void *, APTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define UnlockCAMD(lock) __UnlockCAMD(CamdBase, (lock))

void __DeleteMidi(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DeleteMidi(mi) __DeleteMidi(CamdBase, (mi))

BOOL __SetMidiAttrsA(void *, struct MidiNode * mi, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SetMidiAttrsA(mi, tags) __SetMidiAttrsA(CamdBase, (mi), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __SetMidiAttrs(void *, struct MidiNode * mi, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SetMidiAttrs(mi, ...) __SetMidiAttrs(CamdBase, (mi), __VA_ARGS__)
#endif

ULONG __GetMidiAttrsA(void *, struct MidiNode * mi, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define GetMidiAttrsA(mi, tags) __GetMidiAttrsA(CamdBase, (mi), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetMidiAttrs(void *, struct MidiNode * mi, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define GetMidiAttrs(mi, ...) __GetMidiAttrs(CamdBase, (mi), __VA_ARGS__)
#endif

struct MidiNode * __NextMidi(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define NextMidi(mi) __NextMidi(CamdBase, (mi))

struct MidiNode * __FindMidi(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define FindMidi(name) __FindMidi(CamdBase, (name))

void __FlushMidi(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define FlushMidi(mi) __FlushMidi(CamdBase, (mi))

struct MidiLink * __AddMidiLinkA(void *, struct MidiNode * mi, LONG type, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AddMidiLinkA(mi, type, tags) __AddMidiLinkA(CamdBase, (mi), (type), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct MidiLink * __linearvarargs __AddMidiLink(void *, struct MidiNode * mi, LONG type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AddMidiLink(mi, type, ...) __AddMidiLink(CamdBase, (mi), (type), __VA_ARGS__)
#endif

void __RemoveMidiLink(void *, struct MidiLink * ml) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define RemoveMidiLink(ml) __RemoveMidiLink(CamdBase, (ml))

BOOL __SetMidiLinkAttrsA(void *, struct MidiLink * ml, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SetMidiLinkAttrsA(ml, tags) __SetMidiLinkAttrsA(CamdBase, (ml), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __SetMidiLinkAttrs(void *, struct MidiLink * ml, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SetMidiLinkAttrs(ml, ...) __SetMidiLinkAttrs(CamdBase, (ml), __VA_ARGS__)
#endif

ULONG __GetMidiLinkAttrsA(void *, struct MidiLink * ml, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define GetMidiLinkAttrsA(ml, tags) __GetMidiLinkAttrsA(CamdBase, (ml), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetMidiLinkAttrs(void *, struct MidiLink * ml, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define GetMidiLinkAttrs(ml, ...) __GetMidiLinkAttrs(CamdBase, (ml), __VA_ARGS__)
#endif

struct MidiLink * __NextClusterLink(void *, struct MidiCluster * mc, struct MidiLink * ml, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define NextClusterLink(mc, ml, type) __NextClusterLink(CamdBase, (mc), (ml), (type))

struct MidiLink * __NextMidiLink(void *, struct MidiNode * mi, struct MidiLink * ml, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define NextMidiLink(mi, ml, type) __NextMidiLink(CamdBase, (mi), (ml), (type))

BOOL __MidiLinkConnected(void *, struct MidiLink * ml) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define MidiLinkConnected(ml) __MidiLinkConnected(CamdBase, (ml))

struct MidiCluster * __NextCluster(void *, struct MidiCluster * mc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define NextCluster(mc) __NextCluster(CamdBase, (mc))

struct MidiCluster * __FindCluster(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define FindCluster(name) __FindCluster(CamdBase, (name))

void __PutMidi(void *, struct MidiLink * ml, ULONG msgdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define PutMidi(ml, msgdata) __PutMidi(CamdBase, (ml), (msgdata))

BOOL __GetMidi(void *, struct MidiNode * mi, MidiMsg * msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define GetMidi(mi, msg) __GetMidi(CamdBase, (mi), (msg))

BOOL __WaitMidi(void *, struct MidiNode * mi, MidiMsg * msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define WaitMidi(mi, msg) __WaitMidi(CamdBase, (mi), (msg))

void __PutSysEx(void *, struct MidiLink * ml, UBYTE * buffer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define PutSysEx(ml, buffer) __PutSysEx(CamdBase, (ml), (buffer))

ULONG __GetSysEx(void *, struct MidiNode * mi, UBYTE * buffer, ULONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define GetSysEx(mi, buffer, len) __GetSysEx(CamdBase, (mi), (buffer), (len))

ULONG __QuerySysEx(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define QuerySysEx(mi) __QuerySysEx(CamdBase, (mi))

void __SkipSysEx(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define SkipSysEx(mi) __SkipSysEx(CamdBase, (mi))

UBYTE __GetMidiErr(void *, struct MidiNode * mi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define GetMidiErr(mi) __GetMidiErr(CamdBase, (mi))

WORD __MidiMsgType(void *, MidiMsg * msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define MidiMsgType(msg) __MidiMsgType(CamdBase, (msg))

WORD __MidiMsgLen(void *, ULONG status) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define MidiMsgLen(status) __MidiMsgLen(CamdBase, (status))

void __ParseMidi(void *, struct MidiLink * ml, UBYTE * buffer, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define ParseMidi(ml, buffer, length) __ParseMidi(CamdBase, (ml), (buffer), (length))

struct MidiDeviceData * __OpenMidiDevice(void *, UBYTE * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define OpenMidiDevice(name) __OpenMidiDevice(CamdBase, (name))

void __CloseMidiDevice(void *, struct MidiDeviceData * mdd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define CloseMidiDevice(mdd) __CloseMidiDevice(CamdBase, (mdd))

int __RethinkCAMD(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define RethinkCAMD() __RethinkCAMD(CamdBase)

void __StartClusterNotify(void *, struct ClusterNotifyNode * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define StartClusterNotify(node) __StartClusterNotify(CamdBase, (node))

void __EndClusterNotify(void *, struct ClusterNotifyNode * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define EndClusterNotify(node) __EndClusterNotify(CamdBase, (node))

#endif /*  _VBCCINLINE_CAMD_H  */

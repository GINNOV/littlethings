/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_CAMD_H
#define _VBCCINLINE_CAMD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct MidiNode * __NextMidi(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tblrl";
#define NextMidi(__p0) __NextMidi(CamdBase, (__p0))

void  __StartClusterNotify(void *, struct ClusterNotifyNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tblrl";
#define StartClusterNotify(__p0) __StartClusterNotify(CamdBase, (__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL  __linearvarargs __SetMidiLinkAttrs(void *, struct MidiLink *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t4,1,8\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-96\n"
	"\tblrl";
#define SetMidiLinkAttrs(...) __SetMidiLinkAttrs(CamdBase, __VA_ARGS__)
#endif

ULONG  __GetMidiLinkAttrsA(void *, struct MidiLink *, CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tblrl";
#define GetMidiLinkAttrsA(__p0, __p1) __GetMidiLinkAttrsA(CamdBase, (__p0), (__p1))

void  __PutSysEx(void *, struct MidiLink *, UBYTE *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tblrl";
#define PutSysEx(__p0, __p1) __PutSysEx(CamdBase, (__p0), (__p1))

ULONG  __GetMidiAttrsA(void *, struct MidiNode *, CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tblrl";
#define GetMidiAttrsA(__p0, __p1) __GetMidiAttrsA(CamdBase, (__p0), (__p1))

BOOL  __MidiLinkConnected(void *, struct MidiLink *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-120\n"
	"\tblrl";
#define MidiLinkConnected(__p0) __MidiLinkConnected(CamdBase, (__p0))

struct MidiDeviceData * __OpenMidiDevice(void *, UBYTE *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tblrl";
#define OpenMidiDevice(__p0) __OpenMidiDevice(CamdBase, (__p0))

void  __DeleteMidi(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tblrl";
#define DeleteMidi(__p0) __DeleteMidi(CamdBase, (__p0))

WORD  __MidiMsgType(void *, MidiMsg *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-186\n"
	"\tblrl";
#define MidiMsgType(__p0) __MidiMsgType(CamdBase, (__p0))

ULONG  __GetSysEx(void *, struct MidiNode *, UBYTE *, ULONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-162\n"
	"\tblrl";
#define GetSysEx(__p0, __p1, __p2) __GetSysEx(CamdBase, (__p0), (__p1), (__p2))

BOOL  __SetMidiLinkAttrsA(void *, struct MidiLink *, CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tblrl";
#define SetMidiLinkAttrsA(__p0, __p1) __SetMidiLinkAttrsA(CamdBase, (__p0), (__p1))

struct MidiNode * __FindMidi(void *, CONST_STRPTR ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-72\n"
	"\tblrl";
#define FindMidi(__p0) __FindMidi(CamdBase, (__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG  __linearvarargs __GetMidiAttrs(void *, struct MidiNode *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t4,1,8\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-60\n"
	"\tblrl";
#define GetMidiAttrs(...) __GetMidiAttrs(CamdBase, __VA_ARGS__)
#endif

void  __RemoveMidiLink(void *, struct MidiLink *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tblrl";
#define RemoveMidiLink(__p0) __RemoveMidiLink(CamdBase, (__p0))

struct MidiLink * __AddMidiLinkA(void *, struct MidiNode *, LONG , CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-84\n"
	"\tblrl";
#define AddMidiLinkA(__p0, __p1, __p2) __AddMidiLinkA(CamdBase, (__p0), (__p1), (__p2))

APTR  __LockCAMD(void *, ULONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tblrl";
#define LockCAMD(__p0) __LockCAMD(CamdBase, (__p0))

struct MidiLink * __NextClusterLink(void *, struct MidiCluster *, struct MidiLink *, LONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-108\n"
	"\tblrl";
#define NextClusterLink(__p0, __p1, __p2) __NextClusterLink(CamdBase, (__p0), (__p1), (__p2))

WORD  __MidiMsgLen(void *, ULONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-192\n"
	"\tblrl";
#define MidiMsgLen(__p0) __MidiMsgLen(CamdBase, (__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct MidiLink * __linearvarargs __AddMidiLink(void *, struct MidiNode *, LONG , ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t5,1,8\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tblrl";
#define AddMidiLink(__p0, ...) __AddMidiLink(CamdBase, (__p0), __VA_ARGS__)
#endif

struct MidiNode * __CreateMidiA(void *, CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tblrl";
#define CreateMidiA(__p0) __CreateMidiA(CamdBase, (__p0))

void  __SkipSysEx(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tblrl";
#define SkipSysEx(__p0) __SkipSysEx(CamdBase, (__p0))

void  __ParseMidi(void *, struct MidiLink *, UBYTE *, ULONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-198\n"
	"\tblrl";
#define ParseMidi(__p0, __p1, __p2) __ParseMidi(CamdBase, (__p0), (__p1), (__p2))

BOOL  __SetMidiAttrsA(void *, struct MidiNode *, CONST struct TagItem *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tblrl";
#define SetMidiAttrsA(__p0, __p1) __SetMidiAttrsA(CamdBase, (__p0), (__p1))

void  __FlushMidi(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tblrl";
#define FlushMidi(__p0) __FlushMidi(CamdBase, (__p0))

UBYTE  __GetMidiErr(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tblrl";
#define GetMidiErr(__p0) __GetMidiErr(CamdBase, (__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL  __linearvarargs __SetMidiAttrs(void *, struct MidiNode *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t4,1,8\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-54\n"
	"\tblrl";
#define SetMidiAttrs(...) __SetMidiAttrs(CamdBase, __VA_ARGS__)
#endif

ULONG  __QuerySysEx(void *, struct MidiNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-168\n"
	"\tblrl";
#define QuerySysEx(__p0) __QuerySysEx(CamdBase, (__p0))

void  __CloseMidiDevice(void *, struct MidiDeviceData *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-210\n"
	"\tblrl";
#define CloseMidiDevice(__p0) __CloseMidiDevice(CamdBase, (__p0))

int  __RethinkCAMD(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-216\n"
	"\tblrl";
#define RethinkCAMD() __RethinkCAMD(CamdBase)

struct MidiLink * __NextMidiLink(void *, struct MidiNode *, struct MidiLink *, LONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-114\n"
	"\tblrl";
#define NextMidiLink(__p0, __p1, __p2) __NextMidiLink(CamdBase, (__p0), (__p1), (__p2))

struct MidiCluster * __FindCluster(void *, CONST_STRPTR ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tblrl";
#define FindCluster(__p0) __FindCluster(CamdBase, (__p0))

void  __PutMidi(void *, struct MidiLink *, LONG ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-138\n"
	"\tblrl";
#define PutMidi(__p0, __p1) __PutMidi(CamdBase, (__p0), (__p1))

BOOL  __GetMidi(void *, struct MidiNode *, MidiMsg *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tblrl";
#define GetMidi(__p0, __p1) __GetMidi(CamdBase, (__p0), (__p1))

void  __UnlockCAMD(void *, APTR ) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tblrl";
#define UnlockCAMD(__p0) __UnlockCAMD(CamdBase, (__p0))

BOOL  __WaitMidi(void *, struct MidiNode *, MidiMsg *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tblrl";
#define WaitMidi(__p0, __p1) __WaitMidi(CamdBase, (__p0), (__p1))

void  __EndClusterNotify(void *, struct ClusterNotifyNode *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-228\n"
	"\tblrl";
#define EndClusterNotify(__p0) __EndClusterNotify(CamdBase, (__p0))

struct MidiCluster * __NextCluster(void *, struct MidiCluster *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tblrl";
#define NextCluster(__p0) __NextCluster(CamdBase, (__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct MidiNode * __linearvarargs __CreateMidi(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\taddi\t3,1,8\n"
	"\tstw\t3,32(2)\n"
	"\tli\t3,-42\n"
	"\tblrl";
#define CreateMidi(...) __CreateMidi(CamdBase, __VA_ARGS__)
#endif

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG  __linearvarargs __GetMidiLinkAttrs(void *, struct MidiLink *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t4,1,8\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-102\n"
	"\tblrl";
#define GetMidiLinkAttrs(...) __GetMidiLinkAttrs(CamdBase, __VA_ARGS__)
#endif

#endif /* !_VBCCINLINE_CAMD_H */

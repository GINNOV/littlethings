#ifndef _VBCCINLINE_MULTIMEDIA_H
#define _VBCCINLINE_MULTIMEDIA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __MediaLog(void *, ULONG level, STRPTR cl, STRPTR fun, STRPTR event, ...) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaLog(level, cl, fun, ...) __MediaLog(MultimediaBase, (level), (cl), (fun), __VA_ARGS__)

BOOL __MediaConnectTagList(void *, Object* obj1, ULONG port1, Object* obj2, ULONG port2, struct TagItem* taglist) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaConnectTagList(obj1, port1, obj2, port2, taglist) __MediaConnectTagList(MultimediaBase, (obj1), (port1), (obj2), (port2), (taglist))

BOOL __MediaConnectTags(void *, Object* obj1, ULONG port1, Object* obj2, ULONG port2, ...) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaConnectTags(obj1, port1, obj2, port2, ...) __MediaConnectTags(MultimediaBase, (obj1), (port1), (obj2), (port2), __VA_ARGS__)

Object* __MediaNewObjectTagList(void *, struct TagItem* taglist) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaNewObjectTagList(taglist) __MediaNewObjectTagList(MultimediaBase, (taglist))

Object* __MediaNewObjectTags(void *, ...) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaNewObjectTags(...) __MediaNewObjectTags(MultimediaBase, __VA_ARGS__)

STRPTR __MediaFindClassTagList(void *, APTR pointer, struct TagItem* taglist) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaFindClassTagList(pointer, taglist) __MediaFindClassTagList(MultimediaBase, (pointer), (taglist))

STRPTR __MediaFindClassTags(void *, APTR pointer, ...) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaFindClassTags(pointer, ...) __MediaFindClassTags(MultimediaBase, (pointer), __VA_ARGS__)

BOOL __MediaGetClassAttr(void *, STRPTR clname, ULONG attr, ULONG* storage) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaGetClassAttr(clname, attr, storage) __MediaGetClassAttr(MultimediaBase, (clname), (attr), (storage))

APTR __MediaAllocVec(void *, ULONG size) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaAllocVec(size) __MediaAllocVec(MultimediaBase, (size))

void __MediaFreeVec(void *, APTR memory) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaFreeVec(memory) __MediaFreeVec(MultimediaBase, (memory))

ULONG __MediaSetLogLevel(void *, ULONG level) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaSetLogLevel(level) __MediaSetLogLevel(MultimediaBase, (level))

QUAD __MediaAudioFrameToTime(void *, QUAD frame, LONG samplerate) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaAudioFrameToTime(frame, samplerate) __MediaAudioFrameToTime(MultimediaBase, (frame), (samplerate))

QUAD __MediaTimeToAudioFrame(void *, QUAD time, LONG samplerate) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaTimeToAudioFrame(time, samplerate) __MediaTimeToAudioFrame(MultimediaBase, (time), (samplerate))

Object* __MediaGetGuiTagList(void *, struct TagItem* taglist) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaGetGuiTagList(taglist) __MediaGetGuiTagList(MultimediaBase, (taglist))

Object* __MediaGetGuiTags(void *, ...) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaGetGuiTags(...) __MediaGetGuiTags(MultimediaBase, __VA_ARGS__)

Object* __MediaBuildFromGuiTagList(void *, Object* guiobject, Object* srcobject, LONG srcport, struct TagItem* taglist) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaBuildFromGuiTagList(guiobject, srcobject, srcport, taglist) __MediaBuildFromGuiTagList(MultimediaBase, (guiobject), (srcobject), (srcport), (taglist))

Object* __MediaBuildFromGuiTags(void *, Object* guiobject, Object* srcobject, LONG srcport, ...) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaBuildFromGuiTags(guiobject, srcobject, srcport, ...) __MediaBuildFromGuiTags(MultimediaBase, (guiobject), (srcobject), (srcport), __VA_ARGS__)

CONST_STRPTR __MediaFault(void *, LONG error) =
	"\tlwz\t0,-106(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaFault(error) __MediaFault(MultimediaBase, (error))

Object* __MediaBuildFromArgsTagList(void *, STRPTR argstring, Object* srcobject, LONG srcport, struct TagItem* taglist) =
	"\tlwz\t0,-112(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaBuildFromArgsTagList(argstring, srcobject, srcport, taglist) __MediaBuildFromArgsTagList(MultimediaBase, (argstring), (srcobject), (srcport), (taglist))

Object* __MediaBuildFromArgsTags(void *, STRPTR argstring, Object* srcobject, LONG srcport, ...) =
	"\tlwz\t0,-112(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaBuildFromArgsTags(argstring, srcobject, srcport, ...) __MediaBuildFromArgsTags(MultimediaBase, (argstring), (srcobject), (srcport), __VA_ARGS__)

STRPTR __MediaGetArgsFromGui(void *, Object* guiobject) =
	"\tlwz\t0,-118(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MediaGetArgsFromGui(guiobject) __MediaGetArgsFromGui(MultimediaBase, (guiobject))

#endif /*  _VBCCINLINE_MULTIMEDIA_H  */

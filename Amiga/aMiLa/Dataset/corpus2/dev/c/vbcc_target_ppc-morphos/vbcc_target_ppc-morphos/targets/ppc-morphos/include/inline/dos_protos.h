#ifndef _VBCCINLINE_DOS_H
#define _VBCCINLINE_DOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

BPTR __Open(void *, CONST_STRPTR name, LONG accessMode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define Open(name, accessMode) __Open(DOSBase, (name), (accessMode))

LONG __Close(void *, BPTR file) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define Close(file) __Close(DOSBase, (file))

LONG __Read(void *, BPTR file, APTR buffer, LONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define Read(file, buffer, length) __Read(DOSBase, (file), (buffer), (length))

LONG __Write(void *, BPTR file, CONST APTR buffer, LONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define Write(file, buffer, length) __Write(DOSBase, (file), (buffer), (length))

BPTR __Input(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define Input() __Input(DOSBase)

BPTR __Output(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define Output() __Output(DOSBase)

LONG __Seek(void *, BPTR file, LONG position, LONG offset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define Seek(file, position, offset) __Seek(DOSBase, (file), (position), (offset))

LONG __DeleteFile(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define DeleteFile(name) __DeleteFile(DOSBase, (name))

LONG __Rename(void *, CONST_STRPTR oldName, CONST_STRPTR newName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define Rename(oldName, newName) __Rename(DOSBase, (oldName), (newName))

BPTR __Lock(void *, CONST_STRPTR name, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define Lock(name, type) __Lock(DOSBase, (name), (type))

VOID __UnLock(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define UnLock(lock) __UnLock(DOSBase, (lock))

BPTR __DupLock(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define DupLock(lock) __DupLock(DOSBase, (lock))

LONG __Examine(void *, BPTR lock, struct FileInfoBlock * fileInfoBlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define Examine(lock, fileInfoBlock) __Examine(DOSBase, (lock), (fileInfoBlock))

LONG __ExNext(void *, BPTR lock, struct FileInfoBlock * fileInfoBlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define ExNext(lock, fileInfoBlock) __ExNext(DOSBase, (lock), (fileInfoBlock))

LONG __Info(void *, BPTR lock, struct InfoData * parameterBlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define Info(lock, parameterBlock) __Info(DOSBase, (lock), (parameterBlock))

BPTR __CreateDir(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define CreateDir(name) __CreateDir(DOSBase, (name))

BPTR __CurrentDir(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define CurrentDir(lock) __CurrentDir(DOSBase, (lock))

LONG __IoErr(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define IoErr() __IoErr(DOSBase)

struct MsgPort * __CreateProc(void *, CONST_STRPTR name, LONG pri, BPTR segList, LONG stackSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define CreateProc(name, pri, segList, stackSize) __CreateProc(DOSBase, (name), (pri), (segList), (stackSize))

VOID __Exit(void *, LONG returnCode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define Exit(returnCode) __Exit(DOSBase, (returnCode))

BPTR __LoadSeg(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define LoadSeg(name) __LoadSeg(DOSBase, (name))

VOID __UnLoadSeg(void *, BPTR seglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define UnLoadSeg(seglist) __UnLoadSeg(DOSBase, (seglist))

struct MsgPort * __DeviceProc(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define DeviceProc(name) __DeviceProc(DOSBase, (name))

LONG __SetComment(void *, CONST_STRPTR name, CONST_STRPTR comment) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define SetComment(name, comment) __SetComment(DOSBase, (name), (comment))

LONG __SetProtection(void *, CONST_STRPTR name, LONG protect) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define SetProtection(name, protect) __SetProtection(DOSBase, (name), (protect))

struct DateStamp * __DateStamp(void *, struct DateStamp * date) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define DateStamp(date) __DateStamp(DOSBase, (date))

VOID __Delay(void *, LONG timeout) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define Delay(timeout) __Delay(DOSBase, (timeout))

LONG __WaitForChar(void *, BPTR file, LONG timeout) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define WaitForChar(file, timeout) __WaitForChar(DOSBase, (file), (timeout))

BPTR __ParentDir(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define ParentDir(lock) __ParentDir(DOSBase, (lock))

LONG __IsInteractive(void *, BPTR file) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define IsInteractive(file) __IsInteractive(DOSBase, (file))

LONG __Execute(void *, CONST_STRPTR string, BPTR file, BPTR file2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define Execute(string, file, file2) __Execute(DOSBase, (string), (file), (file2))

APTR __AllocDosObject(void *, ULONG type, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define AllocDosObject(type, tags) __AllocDosObject(DOSBase, (type), (tags))

#define AllocDosObjectTagList(type, tags) __AllocDosObject((type), (tags), DOSBase)

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AllocDosObjectTags(void *, ULONG type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,8(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define AllocDosObjectTags(type, ...) __AllocDosObjectTags(DOSBase, (type), __VA_ARGS__)
#endif

VOID __FreeDosObject(void *, ULONG type, APTR ptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define FreeDosObject(type, ptr) __FreeDosObject(DOSBase, (type), (ptr))

LONG __DoPkt(void *, struct MsgPort * port, LONG action, LONG arg1, LONG arg2, LONG arg3, LONG arg4, LONG arg5) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tstw\t9,24(2)\n"
	"\tstw\t10,28(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt(port, action, arg1, arg2, arg3, arg4, arg5) __DoPkt(DOSBase, (port), (action), (arg1), (arg2), (arg3), (arg4), (arg5))

LONG __DoPkt0(void *, struct MsgPort * port, LONG action) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt0(port, action) __DoPkt0(DOSBase, (port), (action))

LONG __DoPkt1(void *, struct MsgPort * port, LONG action, LONG arg1) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt1(port, action, arg1) __DoPkt1(DOSBase, (port), (action), (arg1))

LONG __DoPkt2(void *, struct MsgPort * port, LONG action, LONG arg1, LONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt2(port, action, arg1, arg2) __DoPkt2(DOSBase, (port), (action), (arg1), (arg2))

LONG __DoPkt3(void *, struct MsgPort * port, LONG action, LONG arg1, LONG arg2, LONG arg3) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt3(port, action, arg1, arg2, arg3) __DoPkt3(DOSBase, (port), (action), (arg1), (arg2), (arg3))

LONG __DoPkt4(void *, struct MsgPort * port, LONG action, LONG arg1, LONG arg2, LONG arg3, LONG arg4) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tstw\t9,24(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define DoPkt4(port, action, arg1, arg2, arg3, arg4) __DoPkt4(DOSBase, (port), (action), (arg1), (arg2), (arg3), (arg4))

VOID __SendPkt(void *, struct DosPacket * dp, struct MsgPort * port, struct MsgPort * replyport) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define SendPkt(dp, port, replyport) __SendPkt(DOSBase, (dp), (port), (replyport))

struct DosPacket * __WaitPkt(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define WaitPkt() __WaitPkt(DOSBase)

VOID __ReplyPkt(void *, struct DosPacket * dp, LONG res1, LONG res2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define ReplyPkt(dp, res1, res2) __ReplyPkt(DOSBase, (dp), (res1), (res2))

VOID __AbortPkt(void *, struct MsgPort * port, struct DosPacket * pkt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define AbortPkt(port, pkt) __AbortPkt(DOSBase, (port), (pkt))

BOOL __LockRecord(void *, BPTR fh, ULONG offset, ULONG length, ULONG mode, ULONG timeout) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define LockRecord(fh, offset, length, mode, timeout) __LockRecord(DOSBase, (fh), (offset), (length), (mode), (timeout))

BOOL __LockRecords(void *, struct RecordLock * recArray, ULONG timeout) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define LockRecords(recArray, timeout) __LockRecords(DOSBase, (recArray), (timeout))

BOOL __UnLockRecord(void *, BPTR fh, ULONG offset, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define UnLockRecord(fh, offset, length) __UnLockRecord(DOSBase, (fh), (offset), (length))

BOOL __UnLockRecords(void *, struct RecordLock * recArray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define UnLockRecords(recArray) __UnLockRecords(DOSBase, (recArray))

BPTR __SelectInput(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define SelectInput(fh) __SelectInput(DOSBase, (fh))

BPTR __SelectOutput(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define SelectOutput(fh) __SelectOutput(DOSBase, (fh))

LONG __FGetC(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define FGetC(fh) __FGetC(DOSBase, (fh))

LONG __FPutC(void *, BPTR fh, LONG ch) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define FPutC(fh, ch) __FPutC(DOSBase, (fh), (ch))

LONG __UnGetC(void *, BPTR fh, LONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define UnGetC(fh, character) __UnGetC(DOSBase, (fh), (character))

LONG __FRead(void *, BPTR fh, APTR block, ULONG blocklen, ULONG number) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define FRead(fh, block, blocklen, number) __FRead(DOSBase, (fh), (block), (blocklen), (number))

LONG __FWrite(void *, BPTR fh, CONST APTR block, ULONG blocklen, ULONG number) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define FWrite(fh, block, blocklen, number) __FWrite(DOSBase, (fh), (block), (blocklen), (number))

STRPTR __FGets(void *, BPTR fh, STRPTR buf, ULONG buflen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define FGets(fh, buf, buflen) __FGets(DOSBase, (fh), (buf), (buflen))

LONG __FPuts(void *, BPTR fh, CONST_STRPTR str) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define FPuts(fh, str) __FPuts(DOSBase, (fh), (str))

VOID __VFWritef(void *, BPTR fh, CONST_STRPTR format, CONST LONG * argarray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define VFWritef(fh, format, argarray) __VFWritef(DOSBase, (fh), (format), (argarray))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __FWritef(void *, BPTR fh, CONST_STRPTR format, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,12(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define FWritef(fh, ...) __FWritef(DOSBase, (fh), __VA_ARGS__)
#endif

LONG __VFPrintf(void *, BPTR fh, CONST_STRPTR format, CONST APTR argarray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define VFPrintf(fh, format, argarray) __VFPrintf(DOSBase, (fh), (format), (argarray))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __FPrintf(void *, BPTR fh, CONST_STRPTR format, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,12(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define FPrintf(fh, ...) __FPrintf(DOSBase, (fh), __VA_ARGS__)
#endif

LONG __Flush(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define Flush(fh) __Flush(DOSBase, (fh))

LONG __SetVBuf(void *, BPTR fh, STRPTR buff, LONG type, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define SetVBuf(fh, buff, type, size) __SetVBuf(DOSBase, (fh), (buff), (type), (size))

BPTR __DupLockFromFH(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define DupLockFromFH(fh) __DupLockFromFH(DOSBase, (fh))

BPTR __OpenFromLock(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define OpenFromLock(lock) __OpenFromLock(DOSBase, (lock))

BPTR __ParentOfFH(void *, BPTR fh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define ParentOfFH(fh) __ParentOfFH(DOSBase, (fh))

BOOL __ExamineFH(void *, BPTR fh, struct FileInfoBlock * fib) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define ExamineFH(fh, fib) __ExamineFH(DOSBase, (fh), (fib))

LONG __SetFileDate(void *, CONST_STRPTR name, CONST struct DateStamp * date) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define SetFileDate(name, date) __SetFileDate(DOSBase, (name), (date))

LONG __NameFromLock(void *, BPTR lock, STRPTR buffer, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define NameFromLock(lock, buffer, len) __NameFromLock(DOSBase, (lock), (buffer), (len))

LONG __NameFromFH(void *, BPTR fh, STRPTR buffer, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define NameFromFH(fh, buffer, len) __NameFromFH(DOSBase, (fh), (buffer), (len))

WORD __SplitName(void *, CONST_STRPTR name, ULONG separator, STRPTR buf, LONG oldpos, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define SplitName(name, separator, buf, oldpos, size) __SplitName(DOSBase, (name), (separator), (buf), (oldpos), (size))

LONG __SameLock(void *, BPTR lock1, BPTR lock2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-420\n"
	"\tbctrl";
#define SameLock(lock1, lock2) __SameLock(DOSBase, (lock1), (lock2))

LONG __SetMode(void *, BPTR fh, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-426\n"
	"\tbctrl";
#define SetMode(fh, mode) __SetMode(DOSBase, (fh), (mode))

LONG __ExAll(void *, BPTR lock, struct ExAllData * buffer, LONG size, LONG data, struct ExAllControl * control) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define ExAll(lock, buffer, size, data, control) __ExAll(DOSBase, (lock), (buffer), (size), (data), (control))

LONG __ReadLink(void *, struct MsgPort * port, BPTR lock, CONST_STRPTR path, STRPTR buffer, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-438\n"
	"\tbctrl";
#define ReadLink(port, lock, path, buffer, size) __ReadLink(DOSBase, (port), (lock), (path), (buffer), (size))

LONG __MakeLink(void *, CONST_STRPTR name, LONG dest, LONG soft) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-444\n"
	"\tbctrl";
#define MakeLink(name, dest, soft) __MakeLink(DOSBase, (name), (dest), (soft))

LONG __ChangeMode(void *, LONG type, BPTR fh, LONG newmode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define ChangeMode(type, fh, newmode) __ChangeMode(DOSBase, (type), (fh), (newmode))

LONG __SetFileSize(void *, BPTR fh, LONG pos, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define SetFileSize(fh, pos, mode) __SetFileSize(DOSBase, (fh), (pos), (mode))

LONG __SetIoErr(void *, LONG result) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-462\n"
	"\tbctrl";
#define SetIoErr(result) __SetIoErr(DOSBase, (result))

BOOL __Fault(void *, LONG code, STRPTR header, STRPTR buffer, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-468\n"
	"\tbctrl";
#define Fault(code, header, buffer, len) __Fault(DOSBase, (code), (header), (buffer), (len))

BOOL __PrintFault(void *, LONG code, CONST_STRPTR header) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-474\n"
	"\tbctrl";
#define PrintFault(code, header) __PrintFault(DOSBase, (code), (header))

LONG __ErrorReport(void *, LONG code, LONG type, ULONG arg1, struct MsgPort * device) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-480\n"
	"\tbctrl";
#define ErrorReport(code, type, arg1, device) __ErrorReport(DOSBase, (code), (type), (arg1), (device))

struct CommandLineInterface * __Cli(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-492\n"
	"\tbctrl";
#define Cli() __Cli(DOSBase)

struct Process * __CreateNewProc(void *, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define CreateNewProc(tags) __CreateNewProc(DOSBase, (tags))

#define CreateNewProcTagList(tags) __CreateNewProc((tags), DOSBase)

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Process * __linearvarargs __CreateNewProcTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,4(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define CreateNewProcTags(...) __CreateNewProcTags(DOSBase, __VA_ARGS__)
#endif

LONG __RunCommand(void *, BPTR seg, LONG stack, CONST_STRPTR paramptr, LONG paramlen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-504\n"
	"\tbctrl";
#define RunCommand(seg, stack, paramptr, paramlen) __RunCommand(DOSBase, (seg), (stack), (paramptr), (paramlen))

struct MsgPort * __GetConsoleTask(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-510\n"
	"\tbctrl";
#define GetConsoleTask() __GetConsoleTask(DOSBase)

struct MsgPort * __SetConsoleTask(void *, CONST struct MsgPort * task) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-516\n"
	"\tbctrl";
#define SetConsoleTask(task) __SetConsoleTask(DOSBase, (task))

struct MsgPort * __GetFileSysTask(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-522\n"
	"\tbctrl";
#define GetFileSysTask() __GetFileSysTask(DOSBase)

struct MsgPort * __SetFileSysTask(void *, CONST struct MsgPort * task) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-528\n"
	"\tbctrl";
#define SetFileSysTask(task) __SetFileSysTask(DOSBase, (task))

STRPTR __GetArgStr(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-534\n"
	"\tbctrl";
#define GetArgStr() __GetArgStr(DOSBase)

BOOL __SetArgStr(void *, CONST_STRPTR string) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-540\n"
	"\tbctrl";
#define SetArgStr(string) __SetArgStr(DOSBase, (string))

struct Process * __FindCliProc(void *, ULONG num) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define FindCliProc(num) __FindCliProc(DOSBase, (num))

ULONG __MaxCli(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define MaxCli() __MaxCli(DOSBase)

BOOL __SetCurrentDirName(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define SetCurrentDirName(name) __SetCurrentDirName(DOSBase, (name))

BOOL __GetCurrentDirName(void *, STRPTR buf, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-564\n"
	"\tbctrl";
#define GetCurrentDirName(buf, len) __GetCurrentDirName(DOSBase, (buf), (len))

BOOL __SetProgramName(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-570\n"
	"\tbctrl";
#define SetProgramName(name) __SetProgramName(DOSBase, (name))

BOOL __GetProgramName(void *, STRPTR buf, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-576\n"
	"\tbctrl";
#define GetProgramName(buf, len) __GetProgramName(DOSBase, (buf), (len))

BOOL __SetPrompt(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-582\n"
	"\tbctrl";
#define SetPrompt(name) __SetPrompt(DOSBase, (name))

BOOL __GetPrompt(void *, STRPTR buf, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-588\n"
	"\tbctrl";
#define GetPrompt(buf, len) __GetPrompt(DOSBase, (buf), (len))

BPTR __SetProgramDir(void *, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-594\n"
	"\tbctrl";
#define SetProgramDir(lock) __SetProgramDir(DOSBase, (lock))

BPTR __GetProgramDir(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-600\n"
	"\tbctrl";
#define GetProgramDir() __GetProgramDir(DOSBase)

LONG __SystemTagList(void *, CONST_STRPTR command, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define SystemTagList(command, tags) __SystemTagList(DOSBase, (command), (tags))

#define System(command, tags) __SystemTagList((command), (tags), DOSBase)

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SystemTags(void *, CONST_STRPTR command, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,8(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define SystemTags(command, ...) __SystemTags(DOSBase, (command), __VA_ARGS__)
#endif

LONG __AssignLock(void *, CONST_STRPTR name, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-612\n"
	"\tbctrl";
#define AssignLock(name, lock) __AssignLock(DOSBase, (name), (lock))

BOOL __AssignLate(void *, CONST_STRPTR name, CONST_STRPTR path) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-618\n"
	"\tbctrl";
#define AssignLate(name, path) __AssignLate(DOSBase, (name), (path))

BOOL __AssignPath(void *, CONST_STRPTR name, CONST_STRPTR path) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-624\n"
	"\tbctrl";
#define AssignPath(name, path) __AssignPath(DOSBase, (name), (path))

BOOL __AssignAdd(void *, CONST_STRPTR name, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-630\n"
	"\tbctrl";
#define AssignAdd(name, lock) __AssignAdd(DOSBase, (name), (lock))

LONG __RemAssignList(void *, CONST_STRPTR name, BPTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-636\n"
	"\tbctrl";
#define RemAssignList(name, lock) __RemAssignList(DOSBase, (name), (lock))

struct DevProc * __GetDeviceProc(void *, CONST_STRPTR name, struct DevProc * dp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-642\n"
	"\tbctrl";
#define GetDeviceProc(name, dp) __GetDeviceProc(DOSBase, (name), (dp))

VOID __FreeDeviceProc(void *, struct DevProc * dp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-648\n"
	"\tbctrl";
#define FreeDeviceProc(dp) __FreeDeviceProc(DOSBase, (dp))

struct DosList * __LockDosList(void *, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-654\n"
	"\tbctrl";
#define LockDosList(flags) __LockDosList(DOSBase, (flags))

VOID __UnLockDosList(void *, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-660\n"
	"\tbctrl";
#define UnLockDosList(flags) __UnLockDosList(DOSBase, (flags))

struct DosList * __AttemptLockDosList(void *, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-666\n"
	"\tbctrl";
#define AttemptLockDosList(flags) __AttemptLockDosList(DOSBase, (flags))

BOOL __RemDosEntry(void *, struct DosList * dlist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-672\n"
	"\tbctrl";
#define RemDosEntry(dlist) __RemDosEntry(DOSBase, (dlist))

LONG __AddDosEntry(void *, struct DosList * dlist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-678\n"
	"\tbctrl";
#define AddDosEntry(dlist) __AddDosEntry(DOSBase, (dlist))

struct DosList * __FindDosEntry(void *, CONST struct DosList * dlist, CONST_STRPTR name, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-684\n"
	"\tbctrl";
#define FindDosEntry(dlist, name, flags) __FindDosEntry(DOSBase, (dlist), (name), (flags))

struct DosList * __NextDosEntry(void *, CONST struct DosList * dlist, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-690\n"
	"\tbctrl";
#define NextDosEntry(dlist, flags) __NextDosEntry(DOSBase, (dlist), (flags))

struct DosList * __MakeDosEntry(void *, CONST_STRPTR name, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-696\n"
	"\tbctrl";
#define MakeDosEntry(name, type) __MakeDosEntry(DOSBase, (name), (type))

VOID __FreeDosEntry(void *, struct DosList * dlist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-702\n"
	"\tbctrl";
#define FreeDosEntry(dlist) __FreeDosEntry(DOSBase, (dlist))

BOOL __IsFileSystem(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-708\n"
	"\tbctrl";
#define IsFileSystem(name) __IsFileSystem(DOSBase, (name))

BOOL __Format(void *, CONST_STRPTR filesystem, CONST_STRPTR volumename, ULONG dostype) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-714\n"
	"\tbctrl";
#define Format(filesystem, volumename, dostype) __Format(DOSBase, (filesystem), (volumename), (dostype))

LONG __Relabel(void *, CONST_STRPTR drive, CONST_STRPTR newname) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-720\n"
	"\tbctrl";
#define Relabel(drive, newname) __Relabel(DOSBase, (drive), (newname))

LONG __Inhibit(void *, CONST_STRPTR name, LONG onoff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-726\n"
	"\tbctrl";
#define Inhibit(name, onoff) __Inhibit(DOSBase, (name), (onoff))

LONG __AddBuffers(void *, CONST_STRPTR name, LONG number) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-732\n"
	"\tbctrl";
#define AddBuffers(name, number) __AddBuffers(DOSBase, (name), (number))

LONG __CompareDates(void *, CONST struct DateStamp * date1, CONST struct DateStamp * date2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-738\n"
	"\tbctrl";
#define CompareDates(date1, date2) __CompareDates(DOSBase, (date1), (date2))

LONG __DateToStr(void *, struct DateTime * datetime) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-744\n"
	"\tbctrl";
#define DateToStr(datetime) __DateToStr(DOSBase, (datetime))

LONG __StrToDate(void *, struct DateTime * datetime) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-750\n"
	"\tbctrl";
#define StrToDate(datetime) __StrToDate(DOSBase, (datetime))

BPTR __InternalLoadSeg(void *, BPTR fh, BPTR table, CONST LONG * funcarray, LONG * stack) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-756\n"
	"\tbctrl";
#define InternalLoadSeg(fh, table, funcarray, stack) __InternalLoadSeg(DOSBase, (fh), (table), (funcarray), (stack))

BPTR __NewLoadSeg(void *, CONST_STRPTR file, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-768\n"
	"\tbctrl";
#define NewLoadSeg(file, tags) __NewLoadSeg(DOSBase, (file), (tags))

#define NewLoadSegTagList(file, tags) __NewLoadSeg((file), (tags), DOSBase)

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BPTR __linearvarargs __NewLoadSegTags(void *, CONST_STRPTR file, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,8(2)\n"
	"\tli\t3,-768\n"
	"\tbctrl";
#define NewLoadSegTags(file, ...) __NewLoadSegTags(DOSBase, (file), __VA_ARGS__)
#endif

LONG __AddSegment(void *, CONST_STRPTR name, BPTR seg, LONG system) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-774\n"
	"\tbctrl";
#define AddSegment(name, seg, system) __AddSegment(DOSBase, (name), (seg), (system))

struct Segment * __FindSegment(void *, CONST_STRPTR name, CONST struct Segment * seg, LONG system) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-780\n"
	"\tbctrl";
#define FindSegment(name, seg, system) __FindSegment(DOSBase, (name), (seg), (system))

LONG __RemSegment(void *, struct Segment * seg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-786\n"
	"\tbctrl";
#define RemSegment(seg) __RemSegment(DOSBase, (seg))

LONG __CheckSignal(void *, LONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-792\n"
	"\tbctrl";
#define CheckSignal(mask) __CheckSignal(DOSBase, (mask))

struct RDArgs * __ReadArgs(void *, CONST_STRPTR arg_template, LONG * array, struct RDArgs * args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-798\n"
	"\tbctrl";
#define ReadArgs(arg_template, array, args) __ReadArgs(DOSBase, (arg_template), (array), (args))

LONG __FindArg(void *, CONST_STRPTR keyword, CONST_STRPTR arg_template) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-804\n"
	"\tbctrl";
#define FindArg(keyword, arg_template) __FindArg(DOSBase, (keyword), (arg_template))

LONG __ReadItem(void *, CONST_STRPTR name, LONG maxchars, struct CSource * cSource) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-810\n"
	"\tbctrl";
#define ReadItem(name, maxchars, cSource) __ReadItem(DOSBase, (name), (maxchars), (cSource))

LONG __StrToLong(void *, CONST_STRPTR string, LONG * value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define StrToLong(string, value) __StrToLong(DOSBase, (string), (value))

LONG __MatchFirst(void *, CONST_STRPTR pat, struct AnchorPath * anchor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-822\n"
	"\tbctrl";
#define MatchFirst(pat, anchor) __MatchFirst(DOSBase, (pat), (anchor))

LONG __MatchNext(void *, struct AnchorPath * anchor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-828\n"
	"\tbctrl";
#define MatchNext(anchor) __MatchNext(DOSBase, (anchor))

VOID __MatchEnd(void *, struct AnchorPath * anchor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-834\n"
	"\tbctrl";
#define MatchEnd(anchor) __MatchEnd(DOSBase, (anchor))

LONG __ParsePattern(void *, CONST_STRPTR pat, STRPTR buf, LONG buflen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-840\n"
	"\tbctrl";
#define ParsePattern(pat, buf, buflen) __ParsePattern(DOSBase, (pat), (buf), (buflen))

BOOL __MatchPattern(void *, CONST_STRPTR pat, STRPTR str) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-846\n"
	"\tbctrl";
#define MatchPattern(pat, str) __MatchPattern(DOSBase, (pat), (str))

VOID __FreeArgs(void *, struct RDArgs * args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-858\n"
	"\tbctrl";
#define FreeArgs(args) __FreeArgs(DOSBase, (args))

STRPTR __FilePart(void *, CONST_STRPTR path) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-870\n"
	"\tbctrl";
#define FilePart(path) __FilePart(DOSBase, (path))

STRPTR __PathPart(void *, CONST_STRPTR path) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-876\n"
	"\tbctrl";
#define PathPart(path) __PathPart(DOSBase, (path))

BOOL __AddPart(void *, STRPTR dirname, CONST_STRPTR filename, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-882\n"
	"\tbctrl";
#define AddPart(dirname, filename, size) __AddPart(DOSBase, (dirname), (filename), (size))

BOOL __StartNotify(void *, struct NotifyRequest * notify) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-888\n"
	"\tbctrl";
#define StartNotify(notify) __StartNotify(DOSBase, (notify))

VOID __EndNotify(void *, struct NotifyRequest * notify) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-894\n"
	"\tbctrl";
#define EndNotify(notify) __EndNotify(DOSBase, (notify))

BOOL __SetVar(void *, CONST_STRPTR name, CONST_STRPTR buffer, LONG size, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-900\n"
	"\tbctrl";
#define SetVar(name, buffer, size, flags) __SetVar(DOSBase, (name), (buffer), (size), (flags))

LONG __GetVar(void *, CONST_STRPTR name, STRPTR buffer, LONG size, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tli\t3,-906\n"
	"\tbctrl";
#define GetVar(name, buffer, size, flags) __GetVar(DOSBase, (name), (buffer), (size), (flags))

LONG __DeleteVar(void *, CONST_STRPTR name, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-912\n"
	"\tbctrl";
#define DeleteVar(name, flags) __DeleteVar(DOSBase, (name), (flags))

struct LocalVar * __FindVar(void *, CONST_STRPTR name, ULONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define FindVar(name, type) __FindVar(DOSBase, (name), (type))

LONG __CliInitNewcli(void *, struct DosPacket * dp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-930\n"
	"\tbctrl";
#define CliInitNewcli(dp) __CliInitNewcli(DOSBase, (dp))

LONG __CliInitRun(void *, struct DosPacket * dp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-936\n"
	"\tbctrl";
#define CliInitRun(dp) __CliInitRun(DOSBase, (dp))

LONG __WriteChars(void *, CONST_STRPTR buf, ULONG buflen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-942\n"
	"\tbctrl";
#define WriteChars(buf, buflen) __WriteChars(DOSBase, (buf), (buflen))

LONG __PutStr(void *, CONST_STRPTR str) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-948\n"
	"\tbctrl";
#define PutStr(str) __PutStr(DOSBase, (str))

LONG __VPrintf(void *, CONST_STRPTR format, CONST APTR argarray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-954\n"
	"\tbctrl";
#define VPrintf(format, argarray) __VPrintf(DOSBase, (format), (argarray))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __Printf(void *, CONST_STRPTR format, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,8(2)\n"
	"\tli\t3,-954\n"
	"\tbctrl";
#define Printf(...) __Printf(DOSBase, __VA_ARGS__)
#endif

LONG __ParsePatternNoCase(void *, CONST_STRPTR pat, UBYTE * buf, LONG buflen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tli\t3,-966\n"
	"\tbctrl";
#define ParsePatternNoCase(pat, buf, buflen) __ParsePatternNoCase(DOSBase, (pat), (buf), (buflen))

BOOL __MatchPatternNoCase(void *, CONST_STRPTR pat, STRPTR str) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-972\n"
	"\tbctrl";
#define MatchPatternNoCase(pat, str) __MatchPatternNoCase(DOSBase, (pat), (str))

BOOL __SameDevice(void *, BPTR lock1, BPTR lock2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-984\n"
	"\tbctrl";
#define SameDevice(lock1, lock2) __SameDevice(DOSBase, (lock1), (lock2))

VOID __ExAllEnd(void *, BPTR lock, struct ExAllData * buffer, LONG size, LONG data, struct ExAllControl * control) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,12(2)\n"
	"\tstw\t7,16(2)\n"
	"\tstw\t8,20(2)\n"
	"\tli\t3,-990\n"
	"\tbctrl";
#define ExAllEnd(lock, buffer, size, data, control) __ExAllEnd(DOSBase, (lock), (buffer), (size), (data), (control))

BOOL __SetOwner(void *, CONST_STRPTR name, LONG owner_info) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,8(2)\n"
	"\tli\t3,-996\n"
	"\tbctrl";
#define SetOwner(name, owner_info) __SetOwner(DOSBase, (name), (owner_info))

LONG __AddSegmentTagList(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-1002\n"
	"\tbctrl";
#define AddSegmentTagList(tags) __AddSegmentTagList(DOSBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __AddSegmentTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-1002\n"
	"\tbctrl";
#define AddSegmentTags(...) __AddSegmentTags(DOSBase, __VA_ARGS__)
#endif

struct Segment * __FindSegmentTagList(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-1008\n"
	"\tbctrl";
#define FindSegmentTagList(tags) __FindSegmentTagList(DOSBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Segment * __linearvarargs __FindSegmentTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-1008\n"
	"\tbctrl";
#define FindSegmentTags(...) __FindSegmentTags(DOSBase, __VA_ARGS__)
#endif

QUAD __Seek64(void *, BPTR file, QUAD position, LONG mode) =
	"\tlwz\t0,-1066(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Seek64(file, position, mode) __Seek64(DOSBase, (file), (position), (mode))

QUAD __SetFileSize64(void *, BPTR fh, QUAD pos, LONG mode) =
	"\tlwz\t0,-1072(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SetFileSize64(fh, pos, mode) __SetFileSize64(DOSBase, (fh), (pos), (mode))

LONG __LockRecord64(void *, BPTR fh, UQUAD offset, UQUAD length, ULONG mode, ULONG timeout) =
	"\tlwz\t0,-1078(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LockRecord64(fh, offset, length, mode, timeout) __LockRecord64(DOSBase, (fh), (offset), (length), (mode), (timeout))

LONG __LockRecords64(void *, struct RecordLock64 * recArray, ULONG timeout) =
	"\tlwz\t0,-1084(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LockRecords64(recArray, timeout) __LockRecords64(DOSBase, (recArray), (timeout))

LONG __UnLockRecord64(void *, BPTR fh, UQUAD offset, UQUAD length) =
	"\tlwz\t0,-1090(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UnLockRecord64(fh, offset, length) __UnLockRecord64(DOSBase, (fh), (offset), (length))

LONG __UnLockRecords64(void *, struct RecordLock64 * recArray) =
	"\tlwz\t0,-1096(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UnLockRecords64(recArray) __UnLockRecords64(DOSBase, (recArray))

LONG __NewReadLink(void *, struct MsgPort * port, BPTR lock, CONST_STRPTR path, UBYTE * buffer, LONG size) =
	"\tlwz\t0,-1114(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewReadLink(port, lock, path, buffer, size) __NewReadLink(DOSBase, (port), (lock), (path), (buffer), (size))

LONG __GetFileSysAttr(void *, CONST_STRPTR devicename, LONG attr, APTR storage, LONG storage_size) =
	"\tlwz\t0,-1120(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetFileSysAttr(devicename, attr, storage, storage_size) __GetFileSysAttr(DOSBase, (devicename), (attr), (storage), (storage_size))

LONG __GetSegListAttr(void *, BPTR seglist, LONG attr, APTR storage, LONG storage_size) =
	"\tlwz\t0,-1126(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetSegListAttr(seglist, attr, storage, storage_size) __GetSegListAttr(DOSBase, (seglist), (attr), (storage), (storage_size))

LONG __SetDosObjectAttr(void *, ULONG type, APTR ptr, struct TagItem * tags) =
	"\tlwz\t0,-1132(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SetDosObjectAttr(type, ptr, tags) __SetDosObjectAttr(DOSBase, (type), (ptr), (tags))

LONG __SetDosObjectAttrTags(void *, ULONG type, APTR ptr, ...) =
	"\tlwz\t0,-1132(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SetDosObjectAttrTags(type, ...) __SetDosObjectAttrTags(DOSBase, (type), __VA_ARGS__)

LONG __GetDosObjectAttr(void *, ULONG type, APTR ptr, struct TagItem * tags) =
	"\tlwz\t0,-1138(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetDosObjectAttr(type, ptr, tags) __GetDosObjectAttr(DOSBase, (type), (ptr), (tags))

LONG __GetDosObjectAttrTags(void *, ULONG type, APTR ptr, ...) =
	"\tlwz\t0,-1138(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetDosObjectAttrTags(type, ...) __GetDosObjectAttrTags(DOSBase, (type), __VA_ARGS__)

LONG __Examine64(void *, BPTR lock, struct FileInfoBlock * fib, struct TagItem * tags) =
	"\tlwz\t0,-1144(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Examine64(lock, fib, tags) __Examine64(DOSBase, (lock), (fib), (tags))

LONG __Examine64Tags(void *, BPTR lock, struct FileInfoBlock * fib, ...) =
	"\tlwz\t0,-1144(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Examine64Tags(lock, ...) __Examine64Tags(DOSBase, (lock), __VA_ARGS__)

LONG __ExNext64(void *, BPTR lock, struct FileInfoBlock * fib, struct TagItem * tags) =
	"\tlwz\t0,-1150(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ExNext64(lock, fib, tags) __ExNext64(DOSBase, (lock), (fib), (tags))

LONG __ExNext64Tags(void *, BPTR lock, struct FileInfoBlock * fib, ...) =
	"\tlwz\t0,-1150(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ExNext64Tags(lock, ...) __ExNext64Tags(DOSBase, (lock), __VA_ARGS__)

LONG __ExamineFH64(void *, BPTR fh, struct FileInfoBlock * fib, struct TagItem * tags) =
	"\tlwz\t0,-1156(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ExamineFH64(fh, fib, tags) __ExamineFH64(DOSBase, (fh), (fib), (tags))

LONG __ExamineFH64Tags(void *, BPTR fh, struct FileInfoBlock * fib, ...) =
	"\tlwz\t0,-1156(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ExamineFH64Tags(fh, ...) __ExamineFH64Tags(DOSBase, (fh), __VA_ARGS__)

#endif /*  _VBCCINLINE_DOS_H  */

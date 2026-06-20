#ifndef _INLINE_DOS_H
#define _INLINE_DOS_H

#ifndef DOS_BASE_NAME
#define DOS_BASE_NAME DOSBase
#endif

#define Open(name, accessMode) \
	((BPTR (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 30))(name, accessMode, (struct Library *) DOS_BASE_NAME)

#define Close(file) \
	((LONG (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 36))(file, (struct Library *) DOS_BASE_NAME)

#define Read(file, buffer, length) \
	((LONG (*)(BPTR __asm("d1"), APTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 42))(file, buffer, length, (struct Library *) DOS_BASE_NAME)

#define Write(file, buffer, length) \
	((LONG (*)(BPTR __asm("d1"), CONST APTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 48))(file, buffer, length, (struct Library *) DOS_BASE_NAME)

#define Input() \
	((BPTR (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 54))((struct Library *) DOS_BASE_NAME)

#define Output() \
	((BPTR (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 60))((struct Library *) DOS_BASE_NAME)

#define Seek(file, position, offset) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 66))(file, position, offset, (struct Library *) DOS_BASE_NAME)

#define DeleteFile(name) \
	((LONG (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 72))(name, (struct Library *) DOS_BASE_NAME)

#define Rename(oldName, newName) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 78))(oldName, newName, (struct Library *) DOS_BASE_NAME)

#define Lock(name, type) \
	((BPTR (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 84))(name, type, (struct Library *) DOS_BASE_NAME)

#define UnLock(lock) \
	((VOID (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 90))(lock, (struct Library *) DOS_BASE_NAME)

#define DupLock(lock) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 96))(lock, (struct Library *) DOS_BASE_NAME)

#define Examine(lock, fileInfoBlock) \
	((LONG (*)(BPTR __asm("d1"), struct FileInfoBlock * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 102))(lock, fileInfoBlock, (struct Library *) DOS_BASE_NAME)

#define ExNext(lock, fileInfoBlock) \
	((LONG (*)(BPTR __asm("d1"), struct FileInfoBlock * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 108))(lock, fileInfoBlock, (struct Library *) DOS_BASE_NAME)

#define Info(lock, parameterBlock) \
	((LONG (*)(BPTR __asm("d1"), struct InfoData * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 114))(lock, parameterBlock, (struct Library *) DOS_BASE_NAME)

#define CreateDir(name) \
	((BPTR (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 120))(name, (struct Library *) DOS_BASE_NAME)

#define CurrentDir(lock) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 126))(lock, (struct Library *) DOS_BASE_NAME)

#define IoErr() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 132))((struct Library *) DOS_BASE_NAME)

#define CreateProc(name, pri, segList, stackSize) \
	((struct MsgPort * (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), BPTR __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 138))(name, pri, segList, stackSize, (struct Library *) DOS_BASE_NAME)

#define Exit(returnCode) \
	((VOID (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 144))(returnCode, (struct Library *) DOS_BASE_NAME)

#define LoadSeg(name) \
	((BPTR (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 150))(name, (struct Library *) DOS_BASE_NAME)

#define UnLoadSeg(seglist) \
	((VOID (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 156))(seglist, (struct Library *) DOS_BASE_NAME)

#define DeviceProc(name) \
	((struct MsgPort * (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 174))(name, (struct Library *) DOS_BASE_NAME)

#define SetComment(name, comment) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 180))(name, comment, (struct Library *) DOS_BASE_NAME)

#define SetProtection(name, protect) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 186))(name, protect, (struct Library *) DOS_BASE_NAME)

#define DateStamp(date) \
	((struct DateStamp * (*)(struct DateStamp * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 192))(date, (struct Library *) DOS_BASE_NAME)

#define Delay(timeout) \
	((VOID (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 198))(timeout, (struct Library *) DOS_BASE_NAME)

#define WaitForChar(file, timeout) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 204))(file, timeout, (struct Library *) DOS_BASE_NAME)

#define ParentDir(lock) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 210))(lock, (struct Library *) DOS_BASE_NAME)

#define IsInteractive(file) \
	((LONG (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 216))(file, (struct Library *) DOS_BASE_NAME)

#define Execute(string, file, file2) \
	((LONG (*)(CONST_STRPTR __asm("d1"), BPTR __asm("d2"), BPTR __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 222))(string, file, file2, (struct Library *) DOS_BASE_NAME)

#define AllocDosObject(type, tags) \
	((APTR (*)(ULONG __asm("d1"), CONST struct TagItem * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 228))(type, tags, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocDosObjectTags(type, tags...) \
	({ULONG _tags[] = {tags}; AllocDosObject((type), (ULONG) _tags);})
#endif

#define AllocDosObjectTagList(type, tags) AllocDosObject((type), (tags))

#define FreeDosObject(type, ptr) \
	((VOID (*)(ULONG __asm("d1"), APTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 234))(type, ptr, (struct Library *) DOS_BASE_NAME)

#define DoPkt(port, action, arg1, arg2, arg3, arg4, arg5) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), LONG __asm("d6"), LONG __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, arg1, arg2, arg3, arg4, arg5, (struct Library *) DOS_BASE_NAME)

#define DoPkt0(port, action) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, (struct Library *) DOS_BASE_NAME)

#define DoPkt1(port, action, arg1) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, arg1, (struct Library *) DOS_BASE_NAME)

#define DoPkt2(port, action, arg1, arg2) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, arg1, arg2, (struct Library *) DOS_BASE_NAME)

#define DoPkt3(port, action, arg1, arg2, arg3) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, arg1, arg2, arg3, (struct Library *) DOS_BASE_NAME)

#define DoPkt4(port, action, arg1, arg2, arg3, arg4) \
	((LONG (*)(struct MsgPort * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), LONG __asm("d6"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 240))(port, action, arg1, arg2, arg3, arg4, (struct Library *) DOS_BASE_NAME)

#define SendPkt(dp, port, replyport) \
	((VOID (*)(struct DosPacket * __asm("d1"), struct MsgPort * __asm("d2"), struct MsgPort * __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 246))(dp, port, replyport, (struct Library *) DOS_BASE_NAME)

#define WaitPkt() \
	((struct DosPacket * (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 252))((struct Library *) DOS_BASE_NAME)

#define ReplyPkt(dp, res1, res2) \
	((VOID (*)(struct DosPacket * __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 258))(dp, res1, res2, (struct Library *) DOS_BASE_NAME)

#define AbortPkt(port, pkt) \
	((VOID (*)(struct MsgPort * __asm("d1"), struct DosPacket * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 264))(port, pkt, (struct Library *) DOS_BASE_NAME)

#define LockRecord(fh, offset, length, mode, timeout) \
	((BOOL (*)(BPTR __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), ULONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 270))(fh, offset, length, mode, timeout, (struct Library *) DOS_BASE_NAME)

#define LockRecords(recArray, timeout) \
	((BOOL (*)(struct RecordLock * __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 276))(recArray, timeout, (struct Library *) DOS_BASE_NAME)

#define UnLockRecord(fh, offset, length) \
	((BOOL (*)(BPTR __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 282))(fh, offset, length, (struct Library *) DOS_BASE_NAME)

#define UnLockRecords(recArray) \
	((BOOL (*)(struct RecordLock * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 288))(recArray, (struct Library *) DOS_BASE_NAME)

#define SelectInput(fh) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 294))(fh, (struct Library *) DOS_BASE_NAME)

#define SelectOutput(fh) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 300))(fh, (struct Library *) DOS_BASE_NAME)

#define FGetC(fh) \
	((LONG (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 306))(fh, (struct Library *) DOS_BASE_NAME)

#define FPutC(fh, ch) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 312))(fh, ch, (struct Library *) DOS_BASE_NAME)

#define UnGetC(fh, character) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 318))(fh, character, (struct Library *) DOS_BASE_NAME)

#define FRead(fh, block, blocklen, number) \
	((LONG (*)(BPTR __asm("d1"), APTR __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 324))(fh, block, blocklen, number, (struct Library *) DOS_BASE_NAME)

#define FWrite(fh, block, blocklen, number) \
	((LONG (*)(BPTR __asm("d1"), CONST APTR __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 330))(fh, block, blocklen, number, (struct Library *) DOS_BASE_NAME)

#define FGets(fh, buf, buflen) \
	((STRPTR (*)(BPTR __asm("d1"), STRPTR __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 336))(fh, buf, buflen, (struct Library *) DOS_BASE_NAME)

#define FPuts(fh, str) \
	((LONG (*)(BPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 342))(fh, str, (struct Library *) DOS_BASE_NAME)

#define VFWritef(fh, format, argarray) \
	((VOID (*)(BPTR __asm("d1"), CONST_STRPTR __asm("d2"), CONST LONG * __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 348))(fh, format, argarray, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define FWritef(fh, format, tags...) \
	({ULONG _tags[] = {tags}; VFWritef((fh), (format), () _tags);})
#endif

#define VFPrintf(fh, format, argarray) \
	((LONG (*)(BPTR __asm("d1"), CONST_STRPTR __asm("d2"), CONST APTR __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 354))(fh, format, argarray, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define FPrintf(fh, format, tags...) \
	({ULONG _tags[] = {tags}; VFPrintf((fh), (format), () _tags);})
#endif

#define Flush(fh) \
	((LONG (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 360))(fh, (struct Library *) DOS_BASE_NAME)

#define SetVBuf(fh, buff, type, size) \
	((LONG (*)(BPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 366))(fh, buff, type, size, (struct Library *) DOS_BASE_NAME)

#define DupLockFromFH(fh) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 372))(fh, (struct Library *) DOS_BASE_NAME)

#define OpenFromLock(lock) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 378))(lock, (struct Library *) DOS_BASE_NAME)

#define ParentOfFH(fh) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 384))(fh, (struct Library *) DOS_BASE_NAME)

#define ExamineFH(fh, fib) \
	((BOOL (*)(BPTR __asm("d1"), struct FileInfoBlock * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 390))(fh, fib, (struct Library *) DOS_BASE_NAME)

#define SetFileDate(name, date) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST struct DateStamp * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 396))(name, date, (struct Library *) DOS_BASE_NAME)

#define NameFromLock(lock, buffer, len) \
	((LONG (*)(BPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 402))(lock, buffer, len, (struct Library *) DOS_BASE_NAME)

#define NameFromFH(fh, buffer, len) \
	((LONG (*)(BPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 408))(fh, buffer, len, (struct Library *) DOS_BASE_NAME)

#define SplitName(name, separator, buf, oldpos, size) \
	((WORD (*)(CONST_STRPTR __asm("d1"), ULONG __asm("d2"), STRPTR __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 414))(name, separator, buf, oldpos, size, (struct Library *) DOS_BASE_NAME)

#define SameLock(lock1, lock2) \
	((LONG (*)(BPTR __asm("d1"), BPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 420))(lock1, lock2, (struct Library *) DOS_BASE_NAME)

#define SetMode(fh, mode) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 426))(fh, mode, (struct Library *) DOS_BASE_NAME)

#define ExAll(lock, buffer, size, data, control) \
	((LONG (*)(BPTR __asm("d1"), struct ExAllData * __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct ExAllControl * __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 432))(lock, buffer, size, data, control, (struct Library *) DOS_BASE_NAME)

#define ReadLink(port, lock, path, buffer, size) \
	((LONG (*)(struct MsgPort * __asm("d1"), BPTR __asm("d2"), CONST_STRPTR __asm("d3"), STRPTR __asm("d4"), ULONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 438))(port, lock, path, buffer, size, (struct Library *) DOS_BASE_NAME)

#define MakeLink(name, dest, soft) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 444))(name, dest, soft, (struct Library *) DOS_BASE_NAME)

#define ChangeMode(type, fh, newmode) \
	((LONG (*)(LONG __asm("d1"), BPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 450))(type, fh, newmode, (struct Library *) DOS_BASE_NAME)

#define SetFileSize(fh, pos, mode) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 456))(fh, pos, mode, (struct Library *) DOS_BASE_NAME)

#define SetIoErr(result) \
	((LONG (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 462))(result, (struct Library *) DOS_BASE_NAME)

#define Fault(code, header, buffer, len) \
	((BOOL (*)(LONG __asm("d1"), STRPTR __asm("d2"), STRPTR __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 468))(code, header, buffer, len, (struct Library *) DOS_BASE_NAME)

#define PrintFault(code, header) \
	((BOOL (*)(LONG __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 474))(code, header, (struct Library *) DOS_BASE_NAME)

#define ErrorReport(code, type, arg1, device) \
	((LONG (*)(LONG __asm("d1"), LONG __asm("d2"), ULONG __asm("d3"), struct MsgPort * __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 480))(code, type, arg1, device, (struct Library *) DOS_BASE_NAME)

#define Cli() \
	((struct CommandLineInterface * (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 492))((struct Library *) DOS_BASE_NAME)

#define CreateNewProc(tags) \
	((struct Process * (*)(CONST struct TagItem * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 498))(tags, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateNewProcTags(tags...) \
	({ULONG _tags[] = {tags}; CreateNewProc((ULONG) _tags);})
#endif

#define CreateNewProcTagList(tags) CreateNewProc((tags))

#define RunCommand(seg, stack, paramptr, paramlen) \
	((LONG (*)(BPTR __asm("d1"), LONG __asm("d2"), CONST_STRPTR __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 504))(seg, stack, paramptr, paramlen, (struct Library *) DOS_BASE_NAME)

#define GetConsoleTask() \
	((struct MsgPort * (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 510))((struct Library *) DOS_BASE_NAME)

#define SetConsoleTask(task) \
	((struct MsgPort * (*)(CONST struct MsgPort * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 516))(task, (struct Library *) DOS_BASE_NAME)

#define GetFileSysTask() \
	((struct MsgPort * (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 522))((struct Library *) DOS_BASE_NAME)

#define SetFileSysTask(task) \
	((struct MsgPort * (*)(CONST struct MsgPort * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 528))(task, (struct Library *) DOS_BASE_NAME)

#define GetArgStr() \
	((STRPTR (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 534))((struct Library *) DOS_BASE_NAME)

#define SetArgStr(string) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 540))(string, (struct Library *) DOS_BASE_NAME)

#define FindCliProc(num) \
	((struct Process * (*)(ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 546))(num, (struct Library *) DOS_BASE_NAME)

#define MaxCli() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 552))((struct Library *) DOS_BASE_NAME)

#define SetCurrentDirName(name) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 558))(name, (struct Library *) DOS_BASE_NAME)

#define GetCurrentDirName(buf, len) \
	((BOOL (*)(STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 564))(buf, len, (struct Library *) DOS_BASE_NAME)

#define SetProgramName(name) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 570))(name, (struct Library *) DOS_BASE_NAME)

#define GetProgramName(buf, len) \
	((BOOL (*)(STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 576))(buf, len, (struct Library *) DOS_BASE_NAME)

#define SetPrompt(name) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 582))(name, (struct Library *) DOS_BASE_NAME)

#define GetPrompt(buf, len) \
	((BOOL (*)(STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 588))(buf, len, (struct Library *) DOS_BASE_NAME)

#define SetProgramDir(lock) \
	((BPTR (*)(BPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 594))(lock, (struct Library *) DOS_BASE_NAME)

#define GetProgramDir() \
	((BPTR (*)(struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 600))((struct Library *) DOS_BASE_NAME)

#define SystemTagList(command, tags) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST struct TagItem * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 606))(command, tags, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SystemTags(command, tags...) \
	({ULONG _tags[] = {tags}; SystemTagList((command), (ULONG) _tags);})
#endif

#define System(command, tags) SystemTagList((command), (tags))

#define AssignLock(name, lock) \
	((LONG (*)(CONST_STRPTR __asm("d1"), BPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 612))(name, lock, (struct Library *) DOS_BASE_NAME)

#define AssignLate(name, path) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 618))(name, path, (struct Library *) DOS_BASE_NAME)

#define AssignPath(name, path) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 624))(name, path, (struct Library *) DOS_BASE_NAME)

#define AssignAdd(name, lock) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), BPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 630))(name, lock, (struct Library *) DOS_BASE_NAME)

#define RemAssignList(name, lock) \
	((LONG (*)(CONST_STRPTR __asm("d1"), BPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 636))(name, lock, (struct Library *) DOS_BASE_NAME)

#define GetDeviceProc(name, dp) \
	((struct DevProc * (*)(CONST_STRPTR __asm("d1"), struct DevProc * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 642))(name, dp, (struct Library *) DOS_BASE_NAME)

#define FreeDeviceProc(dp) \
	((VOID (*)(struct DevProc * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 648))(dp, (struct Library *) DOS_BASE_NAME)

#define LockDosList(flags) \
	((struct DosList * (*)(ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 654))(flags, (struct Library *) DOS_BASE_NAME)

#define UnLockDosList(flags) \
	((VOID (*)(ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 660))(flags, (struct Library *) DOS_BASE_NAME)

#define AttemptLockDosList(flags) \
	((struct DosList * (*)(ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 666))(flags, (struct Library *) DOS_BASE_NAME)

#define RemDosEntry(dlist) \
	((BOOL (*)(struct DosList * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 672))(dlist, (struct Library *) DOS_BASE_NAME)

#define AddDosEntry(dlist) \
	((LONG (*)(struct DosList * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 678))(dlist, (struct Library *) DOS_BASE_NAME)

#define FindDosEntry(dlist, name, flags) \
	((struct DosList * (*)(CONST struct DosList * __asm("d1"), CONST_STRPTR __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 684))(dlist, name, flags, (struct Library *) DOS_BASE_NAME)

#define NextDosEntry(dlist, flags) \
	((struct DosList * (*)(CONST struct DosList * __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 690))(dlist, flags, (struct Library *) DOS_BASE_NAME)

#define MakeDosEntry(name, type) \
	((struct DosList * (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 696))(name, type, (struct Library *) DOS_BASE_NAME)

#define FreeDosEntry(dlist) \
	((VOID (*)(struct DosList * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 702))(dlist, (struct Library *) DOS_BASE_NAME)

#define IsFileSystem(name) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 708))(name, (struct Library *) DOS_BASE_NAME)

#define Format(filesystem, volumename, dostype) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 714))(filesystem, volumename, dostype, (struct Library *) DOS_BASE_NAME)

#define Relabel(drive, newname) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 720))(drive, newname, (struct Library *) DOS_BASE_NAME)

#define Inhibit(name, onoff) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 726))(name, onoff, (struct Library *) DOS_BASE_NAME)

#define AddBuffers(name, number) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 732))(name, number, (struct Library *) DOS_BASE_NAME)

#define CompareDates(date1, date2) \
	((LONG (*)(CONST struct DateStamp * __asm("d1"), CONST struct DateStamp * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 738))(date1, date2, (struct Library *) DOS_BASE_NAME)

#define DateToStr(datetime) \
	((LONG (*)(struct DateTime * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 744))(datetime, (struct Library *) DOS_BASE_NAME)

#define StrToDate(datetime) \
	((LONG (*)(struct DateTime * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 750))(datetime, (struct Library *) DOS_BASE_NAME)

#define InternalLoadSeg(fh, table, funcarray, stack) \
	((BPTR (*)(BPTR __asm("d0"), BPTR __asm("a0"), CONST LONG * __asm("a1"), LONG * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 756))(fh, table, funcarray, stack, (struct Library *) DOS_BASE_NAME)

#define InternalUnLoadSeg(seglist, freefunc) \
	((BOOL (*)(BPTR __asm("d1"), VOID (*)(VOID) __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 762))(seglist, freefunc, (struct Library *) DOS_BASE_NAME)

#define NewLoadSeg(file, tags) \
	((BPTR (*)(CONST_STRPTR __asm("d1"), CONST struct TagItem * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 768))(file, tags, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define NewLoadSegTags(file, tags...) \
	({ULONG _tags[] = {tags}; NewLoadSeg((file), (ULONG) _tags);})
#endif

#define NewLoadSegTagList(file, tags) NewLoadSeg((file), (tags))

#define AddSegment(name, seg, system) \
	((LONG (*)(CONST_STRPTR __asm("d1"), BPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 774))(name, seg, system, (struct Library *) DOS_BASE_NAME)

#define FindSegment(name, seg, system) \
	((struct Segment * (*)(CONST_STRPTR __asm("d1"), CONST struct Segment * __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 780))(name, seg, system, (struct Library *) DOS_BASE_NAME)

#define RemSegment(seg) \
	((LONG (*)(struct Segment * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 786))(seg, (struct Library *) DOS_BASE_NAME)

#define CheckSignal(mask) \
	((LONG (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 792))(mask, (struct Library *) DOS_BASE_NAME)

#define ReadArgs(arg_template, array, args) \
	((struct RDArgs * (*)(CONST_STRPTR __asm("d1"), LONG * __asm("d2"), struct RDArgs * __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 798))(arg_template, array, args, (struct Library *) DOS_BASE_NAME)

#define FindArg(keyword, arg_template) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 804))(keyword, arg_template, (struct Library *) DOS_BASE_NAME)

#define ReadItem(name, maxchars, cSource) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct CSource * __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 810))(name, maxchars, cSource, (struct Library *) DOS_BASE_NAME)

#define StrToLong(string, value) \
	((LONG (*)(CONST_STRPTR __asm("d1"), LONG * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 816))(string, value, (struct Library *) DOS_BASE_NAME)

#define MatchFirst(pat, anchor) \
	((LONG (*)(CONST_STRPTR __asm("d1"), struct AnchorPath * __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 822))(pat, anchor, (struct Library *) DOS_BASE_NAME)

#define MatchNext(anchor) \
	((LONG (*)(struct AnchorPath * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 828))(anchor, (struct Library *) DOS_BASE_NAME)

#define MatchEnd(anchor) \
	((VOID (*)(struct AnchorPath * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 834))(anchor, (struct Library *) DOS_BASE_NAME)

#define ParsePattern(pat, buf, buflen) \
	((LONG (*)(CONST_STRPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 840))(pat, buf, buflen, (struct Library *) DOS_BASE_NAME)

#define MatchPattern(pat, str) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 846))(pat, str, (struct Library *) DOS_BASE_NAME)

#define FreeArgs(args) \
	((VOID (*)(struct RDArgs * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 858))(args, (struct Library *) DOS_BASE_NAME)

#define FilePart(path) \
	((STRPTR (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 870))(path, (struct Library *) DOS_BASE_NAME)

#define PathPart(path) \
	((STRPTR (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 876))(path, (struct Library *) DOS_BASE_NAME)

#define AddPart(dirname, filename, size) \
	((BOOL (*)(STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 882))(dirname, filename, size, (struct Library *) DOS_BASE_NAME)

#define StartNotify(notify) \
	((BOOL (*)(struct NotifyRequest * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 888))(notify, (struct Library *) DOS_BASE_NAME)

#define EndNotify(notify) \
	((VOID (*)(struct NotifyRequest * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 894))(notify, (struct Library *) DOS_BASE_NAME)

#define SetVar(name, buffer, size, flags) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), CONST_STRPTR __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 900))(name, buffer, size, flags, (struct Library *) DOS_BASE_NAME)

#define GetVar(name, buffer, size, flags) \
	((LONG (*)(CONST_STRPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 906))(name, buffer, size, flags, (struct Library *) DOS_BASE_NAME)

#define DeleteVar(name, flags) \
	((LONG (*)(CONST_STRPTR __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 912))(name, flags, (struct Library *) DOS_BASE_NAME)

#define FindVar(name, type) \
	((struct LocalVar * (*)(CONST_STRPTR __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 918))(name, type, (struct Library *) DOS_BASE_NAME)

#define CliInitNewcli(dp) \
	((LONG (*)(struct DosPacket * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 930))(dp, (struct Library *) DOS_BASE_NAME)

#define CliInitRun(dp) \
	((LONG (*)(struct DosPacket * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 936))(dp, (struct Library *) DOS_BASE_NAME)

#define WriteChars(buf, buflen) \
	((LONG (*)(CONST_STRPTR __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 942))(buf, buflen, (struct Library *) DOS_BASE_NAME)

#define PutStr(str) \
	((LONG (*)(CONST_STRPTR __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 948))(str, (struct Library *) DOS_BASE_NAME)

#define VPrintf(format, argarray) \
	((LONG (*)(CONST_STRPTR __asm("d1"), CONST APTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 954))(format, argarray, (struct Library *) DOS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define Printf(format, tags...) \
	({ULONG _tags[] = {tags}; VPrintf((format), () _tags);})
#endif

#define ParsePatternNoCase(pat, buf, buflen) \
	((LONG (*)(CONST_STRPTR __asm("d1"), STRPTR __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 966))(pat, buf, buflen, (struct Library *) DOS_BASE_NAME)

#define MatchPatternNoCase(pat, str) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), STRPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 972))(pat, str, (struct Library *) DOS_BASE_NAME)

#define SameDevice(lock1, lock2) \
	((BOOL (*)(BPTR __asm("d1"), BPTR __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 984))(lock1, lock2, (struct Library *) DOS_BASE_NAME)

#define ExAllEnd(lock, buffer, size, data, control) \
	((VOID (*)(BPTR __asm("d1"), struct ExAllData * __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct ExAllControl * __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 990))(lock, buffer, size, data, control, (struct Library *) DOS_BASE_NAME)

#define SetOwner(name, owner_info) \
	((BOOL (*)(CONST_STRPTR __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DOS_BASE_NAME) - 996))(name, owner_info, (struct Library *) DOS_BASE_NAME)

#endif /*  _INLINE_DOS_H  */

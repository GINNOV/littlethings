#ifndef _INLINE_HDWRENCH_H
#define _INLINE_HDWRENCH_H

#ifndef HDWRENCH_BASE_NAME
#define HDWRENCH_BASE_NAME HDWBase
#endif

#define HDWOpenDevice(devName, unit) \
	((BOOL (*)(STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 30))(devName, unit, (struct Library *) HDWRENCH_BASE_NAME)

#define HDWCloseDevice() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 36))((struct Library *) HDWRENCH_BASE_NAME)

#define RawRead(bbk, size) \
	((UWORD (*)(BootBlock * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 42))(bbk, size, (struct Library *) HDWRENCH_BASE_NAME)

#define RawWrite(bb) \
	((UWORD (*)(BootBlock * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 48))(bb, (struct Library *) HDWRENCH_BASE_NAME)

#define WriteBlock(bb) \
	((UWORD (*)(BootBlock * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 54))(bb, (struct Library *) HDWRENCH_BASE_NAME)

#define ReadRDBs() \
	((UWORD (*)(struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 60))((struct Library *) HDWRENCH_BASE_NAME)

#define WriteRDBs() \
	((UWORD (*)(struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 66))((struct Library *) HDWRENCH_BASE_NAME)

#define QueryReady(errorcode) \
	((BOOL (*)(LONG * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 72))(errorcode, (struct Library *) HDWRENCH_BASE_NAME)

#define QueryInquiry(inqbuf, errorcode) \
	((BOOL (*)(BYTE * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 78))(inqbuf, errorcode, (struct Library *) HDWRENCH_BASE_NAME)

#define QueryModeSense(page, msbsize, msbuf, errorcode) \
	((BOOL (*)(LONG __asm("d0"), LONG __asm("d1"), BYTE * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 84))(page, msbsize, msbuf, errorcode, (struct Library *) HDWRENCH_BASE_NAME)

#define QueryCapacity(totalblocks, blocksize) \
	((BOOL (*)(ULONG * __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 96))(totalblocks, blocksize, (struct Library *) HDWRENCH_BASE_NAME)

#define ReadMountfile(unit, filename, controller) \
	((ULONG (*)(ULONG __asm("d0"), STRPTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 102))(unit, filename, controller, (struct Library *) HDWRENCH_BASE_NAME)

#define ReadRDBStructs(filename, unit) \
	((ULONG (*)(STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 108))(filename, unit, (struct Library *) HDWRENCH_BASE_NAME)

#define WriteMountfile(filename, ldir, unit) \
	((ULONG (*)(STRPTR __asm("a0"), STRPTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 114))(filename, ldir, unit, (struct Library *) HDWRENCH_BASE_NAME)

#define WriteRDBStructs(filename) \
	((ULONG (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 120))(filename, (struct Library *) HDWRENCH_BASE_NAME)

#define InMemMountfile(unit, mfdata, controller) \
	((ULONG (*)(ULONG __asm("d0"), STRPTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 126))(unit, mfdata, controller, (struct Library *) HDWRENCH_BASE_NAME)

#define InMemRDBStructs(rdbp, sizerdb, unit) \
	((ULONG (*)(STRPTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 132))(rdbp, sizerdb, unit, (struct Library *) HDWRENCH_BASE_NAME)

#define OutMemMountfile(mfp, sizew, sizeb, unit) \
	((ULONG (*)(STRPTR __asm("a0"), ULONG * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 138))(mfp, sizew, sizeb, unit, (struct Library *) HDWRENCH_BASE_NAME)

#define OutMemRDBStructs(rdbp, sizew, sizeb) \
	((ULONG (*)(STRPTR __asm("a0"), ULONG * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 144))(rdbp, sizew, sizeb, (struct Library *) HDWRENCH_BASE_NAME)

#define FindDiskName(diskname) \
	((BOOL (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 150))(diskname, (struct Library *) HDWRENCH_BASE_NAME)

#define FindControllerID(devname, selfid) \
	((BOOL (*)(STRPTR __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 156))(devname, selfid, (struct Library *) HDWRENCH_BASE_NAME)

#define FindLastSector() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 162))((struct Library *) HDWRENCH_BASE_NAME)

#define FindDefaults(optimize, result) \
	((ULONG (*)(ULONG __asm("d0"), struct DefaultsArray * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) HDWRENCH_BASE_NAME) - 168))(optimize, result, (struct Library *) HDWRENCH_BASE_NAME)

#endif /*  _INLINE_HDWRENCH_H  */

#ifndef _VBCCINLINE_TIFF_H
#define _VBCCINLINE_TIFF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

TIFF* __TIFFOpen(const char* val1, const char* val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFOpen(val1, val2) __TIFFOpen((val1), (val2))

TIFF* __TIFFOpenFH(BPTR val1, const char* val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFOpenFH(val1, val2) __TIFFOpenFH((val1), (val2))

int __TIFFGetField(TIFF* val1, ttag_t val2, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetField(val1, ...) __TIFFGetField((val1), __VA_ARGS__)

int __TIFFIsTiled(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsTiled(val1) __TIFFIsTiled((val1))

int __TIFFSetField(TIFF* val1, ttag_t val2, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetField(val1, ...) __TIFFSetField((val1), __VA_ARGS__)

int __TIFFReadRGBAImageOriented(TIFF* val1, uint32 val2, uint32 val3, uint32* val4, int val5, int val6) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRGBAImageOriented(val1, val2, val3, val4, val5, val6) __TIFFReadRGBAImageOriented((val1), (val2), (val3), (val4), (val5), (val6))

int __TIFFReadRGBATile(TIFF* val1, uint32 val2, uint32 val3, uint32 * val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRGBATile(val1, val2, val3, val4) __TIFFReadRGBATile((val1), (val2), (val3), (val4))

int __TIFFReadRGBAStrip(TIFF* val1, tstrip_t val2, uint32 * val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRGBAStrip(val1, val2, val3) __TIFFReadRGBAStrip((val1), (val2), (val3))

int __TIFFWriteScanline(TIFF* val1, tdata_t val2, uint32 val3, tsample_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteScanline(val1, val2, val3, val4) __TIFFWriteScanline((val1), (val2), (val3), (val4))

void __TIFFClose(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFClose(val1) __TIFFClose((val1))

const char* __TIFFGetVersion() =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetVersion() __TIFFGetVersion()

const TIFFCodec* __TIFFFindCODEC(uint16 val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFindCODEC(val1) __TIFFFindCODEC((val1))

TIFFCodec* __TIFFRegisterCODEC(uint16 val1, const char* val2, TIFFInitMethod val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRegisterCODEC(val1, val2, val3) __TIFFRegisterCODEC((val1), (val2), (val3))

void __TIFFUnRegisterCODEC(TIFFCodec* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFUnRegisterCODEC(val1) __TIFFUnRegisterCODEC((val1))

int __TIFFIsCODECConfigured(uint16 val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsCODECConfigured(val1) __TIFFIsCODECConfigured((val1))

tdata_t ___TIFFmalloc(tsize_t val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFmalloc(val1) ___TIFFmalloc((val1))

tdata_t ___TIFFrealloc(tdata_t val1, tsize_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFrealloc(val1, val2) ___TIFFrealloc((val1), (val2))

void ___TIFFfree(tdata_t val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFfree(val1) ___TIFFfree((val1))

void ___TIFFmemset(tdata_t val1, int val2, tsize_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFmemset(val1, val2, val3) ___TIFFmemset((val1), (val2), (val3))

void ___TIFFmemcpy(tdata_t val1, const tdata_t val2, tsize_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFmemcpy(val1, val2, val3) ___TIFFmemcpy((val1), (val2), (val3))

int ___TIFFmemcmp(const tdata_t val1, const tdata_t val2, tsize_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define _TIFFmemcmp(val1, val2, val3) ___TIFFmemcmp((val1), (val2), (val3))

int __TIFFFlush(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFlush(val1) __TIFFFlush((val1))

int __TIFFFlushData(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFlushData(val1) __TIFFFlushData((val1))

int __TIFFVGetField(TIFF* val1, ttag_t val2, va_list val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFVGetField(val1, val2, val3) __TIFFVGetField((val1), (val2), (val3))

int __TIFFGetFieldDefaulted(TIFF* val1, ttag_t val2, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetFieldDefaulted(val1, ...) __TIFFGetFieldDefaulted((val1), __VA_ARGS__)

int __TIFFVGetFieldDefaulted(TIFF* val1, ttag_t val2, va_list val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFVGetFieldDefaulted(val1, val2, val3) __TIFFVGetFieldDefaulted((val1), (val2), (val3))

int __TIFFReadDirectory(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadDirectory(val1) __TIFFReadDirectory((val1))

tsize_t __TIFFScanlineSize(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFScanlineSize(val1) __TIFFScanlineSize((val1))

tsize_t __TIFFRasterScanlineSize(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRasterScanlineSize(val1) __TIFFRasterScanlineSize((val1))

tsize_t __TIFFStripSize(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFStripSize(val1) __TIFFStripSize((val1))

tsize_t __TIFFRawStripSize(TIFF* val1, tstrip_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRawStripSize(val1, val2) __TIFFRawStripSize((val1), (val2))

tsize_t __TIFFVStripSize(TIFF* val1, uint32 val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFVStripSize(val1, val2) __TIFFVStripSize((val1), (val2))

tsize_t __TIFFTileRowSize(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFTileRowSize(val1) __TIFFTileRowSize((val1))

tsize_t __TIFFTileSize(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFTileSize(val1) __TIFFTileSize((val1))

tsize_t __TIFFVTileSize(TIFF* val1, uint32 val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFVTileSize(val1, val2) __TIFFVTileSize((val1), (val2))

uint32 __TIFFDefaultStripSize(TIFF* val1, uint32 val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFDefaultStripSize(val1, val2) __TIFFDefaultStripSize((val1), (val2))

void __TIFFDefaultTileSize(TIFF* val1, uint32* val2, uint32* val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFDefaultTileSize(val1, val2, val3) __TIFFDefaultTileSize((val1), (val2), (val3))

int __TIFFFileno(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFileno(val1) __TIFFFileno((val1))

int __TIFFGetMode(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetMode(val1) __TIFFGetMode((val1))

int __TIFFIsByteSwapped(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsByteSwapped(val1) __TIFFIsByteSwapped((val1))

int __TIFFIsUpSampled(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsUpSampled(val1) __TIFFIsUpSampled((val1))

int __TIFFIsMSB2LSB(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsMSB2LSB(val1) __TIFFIsMSB2LSB((val1))

uint32 __TIFFCurrentRow(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCurrentRow(val1) __TIFFCurrentRow((val1))

tdir_t __TIFFCurrentDirectory(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCurrentDirectory(val1) __TIFFCurrentDirectory((val1))

tdir_t __TIFFNumberOfDirectories(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFNumberOfDirectories(val1) __TIFFNumberOfDirectories((val1))

uint32 __TIFFCurrentDirOffset(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCurrentDirOffset(val1) __TIFFCurrentDirOffset((val1))

tstrip_t __TIFFCurrentStrip(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCurrentStrip(val1) __TIFFCurrentStrip((val1))

ttile_t __TIFFCurrentTile(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCurrentTile(val1) __TIFFCurrentTile((val1))

int __TIFFReadBufferSetup(TIFF* val1, tdata_t val2, tsize_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadBufferSetup(val1, val2, val3) __TIFFReadBufferSetup((val1), (val2), (val3))

int __TIFFWriteBufferSetup(TIFF* val1, tdata_t val2, tsize_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteBufferSetup(val1, val2, val3) __TIFFWriteBufferSetup((val1), (val2), (val3))

int __TIFFSetupStrips(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetupStrips(val1) __TIFFSetupStrips((val1))

int __TIFFWriteCheck(TIFF* val1, int val2, const char * val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteCheck(val1, val2, val3) __TIFFWriteCheck((val1), (val2), (val3))

int __TIFFCreateDirectory(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCreateDirectory(val1) __TIFFCreateDirectory((val1))

int __TIFFLastDirectory(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFLastDirectory(val1) __TIFFLastDirectory((val1))

int __TIFFSetDirectory(TIFF* val1, tdir_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetDirectory(val1, val2) __TIFFSetDirectory((val1), (val2))

int __TIFFSetSubDirectory(TIFF* val1, uint32 val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetSubDirectory(val1, val2) __TIFFSetSubDirectory((val1), (val2))

int __TIFFUnlinkDirectory(TIFF* val1, tdir_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFUnlinkDirectory(val1, val2) __TIFFUnlinkDirectory((val1), (val2))

int __TIFFVSetField(TIFF* val1, ttag_t val2, va_list val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFVSetField(val1, val2, val3) __TIFFVSetField((val1), (val2), (val3))

int __TIFFWriteDirectory(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteDirectory(val1) __TIFFWriteDirectory((val1))

int __TIFFCheckpointDirectory(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCheckpointDirectory(val1) __TIFFCheckpointDirectory((val1))

int __TIFFRewriteDirectory(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRewriteDirectory(val1) __TIFFRewriteDirectory((val1))

int __TIFFReassignTagToIgnore(int val1, int val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReassignTagToIgnore(val1, val2) __TIFFReassignTagToIgnore((val1), (val2))

int __TIFFReadScanline(TIFF* val1, tdata_t val2, uint32 val3, tsample_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadScanline(val1, val2, val3, val4) __TIFFReadScanline((val1), (val2), (val3), (val4))

int __TIFFReadRGBAImage(TIFF* val1, uint32 val2, uint32 val3, uint32* val4, int val5) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRGBAImage(val1, val2, val3, val4, val5) __TIFFReadRGBAImage((val1), (val2), (val3), (val4), (val5))

int __TIFFRGBAImageOK(TIFF* val1, char [1024] val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRGBAImageOK(val1, val2) __TIFFRGBAImageOK((val1), (val2))

int __TIFFRGBAImageBegin(TIFFRGBAImage* val1, TIFF* val2, int val3, char [1024] val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRGBAImageBegin(val1, val2, val3, val4) __TIFFRGBAImageBegin((val1), (val2), (val3), (val4))

int __TIFFRGBAImageGet(TIFFRGBAImage* val1, uint32* val2, uint32 val3, uint32 val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRGBAImageGet(val1, val2, val3, val4) __TIFFRGBAImageGet((val1), (val2), (val3), (val4))

void __TIFFRGBAImageEnd(TIFFRGBAImage* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFRGBAImageEnd(val1) __TIFFRGBAImageEnd((val1))

TIFF* __TIFFClientOpen(const char* val1, const char* val2, thandle_t val3, TIFFReadWriteProc val4, TIFFReadWriteProc val5, TIFFSeekProc val6, TIFFCloseProc val7, TIFFSizeProc val8, TIFFMapFileProc val9, TIFFUnmapFileProc val10) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFClientOpen(val1, val2, val3, val4, val5, val6, val7, val8, val9, val10) __TIFFClientOpen((val1), (val2), (val3), (val4), (val5), (val6), (val7), (val8), (val9), (val10))

const char* __TIFFFileName(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFileName(val1) __TIFFFileName((val1))

void __TIFFError(const char* val1, const char* val2, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFError(val1, ...) __TIFFError((val1), __VA_ARGS__)

void __TIFFWarning(const char* val1, const char* val2, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWarning(val1, ...) __TIFFWarning((val1), __VA_ARGS__)

TIFFErrorHandler __TIFFSetErrorHandler(TIFFErrorHandler val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetErrorHandler(val1) __TIFFSetErrorHandler((val1))

TIFFErrorHandler __TIFFSetWarningHandler(TIFFErrorHandler val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetWarningHandler(val1) __TIFFSetWarningHandler((val1))

TIFFExtendProc __TIFFSetTagExtender(TIFFExtendProc val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetTagExtender(val1) __TIFFSetTagExtender((val1))

ttile_t __TIFFComputeTile(TIFF* val1, uint32 val2, uint32 val3, uint32 val4, tsample_t val5) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFComputeTile(val1, val2, val3, val4, val5) __TIFFComputeTile((val1), (val2), (val3), (val4), (val5))

int __TIFFCheckTile(TIFF* val1, uint32 val2, uint32 val3, uint32 val4, tsample_t val5) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCheckTile(val1, val2, val3, val4, val5) __TIFFCheckTile((val1), (val2), (val3), (val4), (val5))

ttile_t __TIFFNumberOfTiles(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFNumberOfTiles(val1) __TIFFNumberOfTiles((val1))

tsize_t __TIFFReadTile(TIFF* val1, tdata_t val2, uint32 val3, uint32 val4, uint32 val5, tsample_t val6) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadTile(val1, val2, val3, val4, val5, val6) __TIFFReadTile((val1), (val2), (val3), (val4), (val5), (val6))

tsize_t __TIFFWriteTile(TIFF* val1, tdata_t val2, uint32 val3, uint32 val4, uint32 val5, tsample_t val6) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteTile(val1, val2, val3, val4, val5, val6) __TIFFWriteTile((val1), (val2), (val3), (val4), (val5), (val6))

tstrip_t __TIFFComputeStrip(TIFF* val1, uint32 val2, tsample_t val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFComputeStrip(val1, val2, val3) __TIFFComputeStrip((val1), (val2), (val3))

tstrip_t __TIFFNumberOfStrips(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFNumberOfStrips(val1) __TIFFNumberOfStrips((val1))

tsize_t __TIFFReadEncodedStrip(TIFF* val1, tstrip_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadEncodedStrip(val1, val2, val3, val4) __TIFFReadEncodedStrip((val1), (val2), (val3), (val4))

tsize_t __TIFFReadRawStrip(TIFF* val1, tstrip_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRawStrip(val1, val2, val3, val4) __TIFFReadRawStrip((val1), (val2), (val3), (val4))

tsize_t __TIFFReadEncodedTile(TIFF* val1, ttile_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadEncodedTile(val1, val2, val3, val4) __TIFFReadEncodedTile((val1), (val2), (val3), (val4))

tsize_t __TIFFReadRawTile(TIFF* val1, ttile_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadRawTile(val1, val2, val3, val4) __TIFFReadRawTile((val1), (val2), (val3), (val4))

tsize_t __TIFFWriteEncodedStrip(TIFF* val1, tstrip_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteEncodedStrip(val1, val2, val3, val4) __TIFFWriteEncodedStrip((val1), (val2), (val3), (val4))

tsize_t __TIFFWriteRawStrip(TIFF* val1, tstrip_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteRawStrip(val1, val2, val3, val4) __TIFFWriteRawStrip((val1), (val2), (val3), (val4))

tsize_t __TIFFWriteEncodedTile(TIFF* val1, ttile_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteEncodedTile(val1, val2, val3, val4) __TIFFWriteEncodedTile((val1), (val2), (val3), (val4))

tsize_t __TIFFWriteRawTile(TIFF* val1, ttile_t val2, tdata_t val3, tsize_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWriteRawTile(val1, val2, val3, val4) __TIFFWriteRawTile((val1), (val2), (val3), (val4))

int __TIFFDataWidth(TIFFDataType val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFDataWidth(val1) __TIFFDataWidth((val1))

void __TIFFSetWriteOffset(TIFF* val1, toff_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetWriteOffset(val1, val2) __TIFFSetWriteOffset((val1), (val2))

void __TIFFSwabShort(uint16* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabShort(val1) __TIFFSwabShort((val1))

void __TIFFSwabLong(uint32* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabLong(val1) __TIFFSwabLong((val1))

void __TIFFSwabDouble(double* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabDouble(val1) __TIFFSwabDouble((val1))

void __TIFFSwabArrayOfShort(uint16* val1, unsigned long val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabArrayOfShort(val1, val2) __TIFFSwabArrayOfShort((val1), (val2))

void __TIFFSwabArrayOfLong(uint32* val1, unsigned long val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabArrayOfLong(val1, val2) __TIFFSwabArrayOfLong((val1), (val2))

void __TIFFSwabArrayOfDouble(double* val1, unsigned long val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabArrayOfDouble(val1, val2) __TIFFSwabArrayOfDouble((val1), (val2))

void __TIFFReverseBits(unsigned char * val1, unsigned long val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReverseBits(val1, val2) __TIFFReverseBits((val1), (val2))

const unsigned char* __TIFFGetBitRevTable(int val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetBitRevTable(val1) __TIFFGetBitRevTable((val1))

int __TIFFGetTagListCount(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetTagListCount(val1) __TIFFGetTagListCount((val1))

ttag_t __TIFFGetTagListEntry(TIFF * val1, int val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetTagListEntry(val1, val2) __TIFFGetTagListEntry((val1), (val2))

void __TIFFMergeFieldInfo(TIFF* val1, const TIFFFieldInfo[] val2, int val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFMergeFieldInfo(val1, val2, val3) __TIFFMergeFieldInfo((val1), (val2), (val3))

const TIFFFieldInfo* __TIFFFindFieldInfo(TIFF* val1, ttag_t val2, TIFFDataType val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFindFieldInfo(val1, val2, val3) __TIFFFindFieldInfo((val1), (val2), (val3))

const TIFFFieldInfo* __TIFFFieldWithTag(TIFF* val1, ttag_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFieldWithTag(val1, val2) __TIFFFieldWithTag((val1), (val2))

TIFFTagMethods * __TIFFAccessTagMethods(TIFF * val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFAccessTagMethods(val1) __TIFFAccessTagMethods((val1))

void * __TIFFGetClientInfo(TIFF * val1, const char * val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetClientInfo(val1, val2) __TIFFGetClientInfo((val1), (val2))

void __TIFFSetClientInfo(TIFF * val1, void * val2, const char * val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetClientInfo(val1, val2, val3) __TIFFSetClientInfo((val1), (val2), (val3))

int __TIFFCIELabToRGBInit(TIFFCIELabToRGB* val1, TIFFDisplay * val2, float* val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCIELabToRGBInit(val1, val2, val3) __TIFFCIELabToRGBInit((val1), (val2), (val3))

void __TIFFCIELabToXYZ(TIFFCIELabToRGB * val1, uint32 val2, int32 val3, int32 val4, float * val5, float * val6, float * val7) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCIELabToXYZ(val1, val2, val3, val4, val5, val6, val7) __TIFFCIELabToXYZ((val1), (val2), (val3), (val4), (val5), (val6), (val7))

void __TIFFXYZToRGB(TIFFCIELabToRGB * val1, float val2, float val3, float val4, uint32 * val5, uint32 * val6, uint32 * val7) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFXYZToRGB(val1, val2, val3, val4, val5, val6, val7) __TIFFXYZToRGB((val1), (val2), (val3), (val4), (val5), (val6), (val7))

int __TIFFYCbCrToRGBInit(TIFFYCbCrToRGB* val1, float* val2, float* val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFYCbCrToRGBInit(val1, val2, val3) __TIFFYCbCrToRGBInit((val1), (val2), (val3))

void __TIFFYCbCrtoRGB(TIFFYCbCrToRGB * val1, uint32 val2, int32 val3, int32 val4, uint32 * val5, uint32 * val6, uint32 * val7) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFYCbCrtoRGB(val1, val2, val3, val4, val5, val6, val7) __TIFFYCbCrtoRGB((val1), (val2), (val3), (val4), (val5), (val6), (val7))

void __TIFFPrintDirectoryFH(TIFF* val1, BPTR val2, long val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFPrintDirectoryFH(val1, val2, val3) __TIFFPrintDirectoryFH((val1), (val2), (val3))

TIFFCodec* __TIFFGetConfiguredCODECs() =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetConfiguredCODECs() __TIFFGetConfiguredCODECs()

void __TIFFCleanup(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFCleanup(val1) __TIFFCleanup((val1))

int __TIFFSetFileno(TIFF* val1, int val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetFileno(val1, val2) __TIFFSetFileno((val1), (val2))

thandle_t __TIFFClientdata(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFClientdata(val1) __TIFFClientdata((val1))

thandle_t __TIFFSetClientdata(TIFF* val1, thandle_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetClientdata(val1, val2) __TIFFSetClientdata((val1), (val2))

int __TIFFSetMode(TIFF* val1, int val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetMode(val1, val2) __TIFFSetMode((val1), (val2))

int __TIFFIsBigEndian(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFIsBigEndian(val1) __TIFFIsBigEndian((val1))

TIFFReadWriteProc __TIFFGetReadProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetReadProc(val1) __TIFFGetReadProc((val1))

TIFFReadWriteProc __TIFFGetWriteProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetWriteProc(val1) __TIFFGetWriteProc((val1))

TIFFSeekProc __TIFFGetSeekProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetSeekProc(val1) __TIFFGetSeekProc((val1))

TIFFCloseProc __TIFFGetCloseProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetCloseProc(val1) __TIFFGetCloseProc((val1))

TIFFSizeProc __TIFFGetSizeProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetSizeProc(val1) __TIFFGetSizeProc((val1))

TIFFMapFileProc __TIFFGetMapFileProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetMapFileProc(val1) __TIFFGetMapFileProc((val1))

TIFFUnmapFileProc __TIFFGetUnmapFileProc(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFGetUnmapFileProc(val1) __TIFFGetUnmapFileProc((val1))

const char * __TIFFSetFileName(TIFF* val1, const char * val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetFileName(val1, val2) __TIFFSetFileName((val1), (val2))

const TIFFFieldInfo * __TIFFFindFieldInfoByName(TIFF* val1, const char * val2, TIFFDataType val3) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFindFieldInfoByName(val1, val2, val3) __TIFFFindFieldInfoByName((val1), (val2), (val3))

const TIFFFieldInfo * __TIFFFieldWithName(TIFF* val1, const char * val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFieldWithName(val1, val2) __TIFFFieldWithName((val1), (val2))

void __TIFFSwabArrayOfTriples(uint8* val1, unsigned long val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSwabArrayOfTriples(val1, val2) __TIFFSwabArrayOfTriples((val1), (val2))

int __TIFFReadCustomDirectory(TIFF* val1, toff_t val2, const TIFFFieldInfo[] val3, size_t val4) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadCustomDirectory(val1, val2, val3, val4) __TIFFReadCustomDirectory((val1), (val2), (val3), (val4))

int __TIFFReadEXIFDirectory(TIFF* val1, toff_t val2) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFReadEXIFDirectory(val1, val2) __TIFFReadEXIFDirectory((val1), (val2))

void __TIFFFreeDirectory(TIFF* val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFFreeDirectory(val1) __TIFFFreeDirectory((val1))

void __TIFFErrorExt(thandle_t val1, const char* val2, const char* val3, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFErrorExt(val1, val2, ...) __TIFFErrorExt((val1), (val2), __VA_ARGS__)

void __TIFFWarningExt(thandle_t val1, const char* val2, const char* val3, ...) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFWarningExt(val1, val2, ...) __TIFFWarningExt((val1), (val2), __VA_ARGS__)

TIFFErrorHandlerExt __TIFFSetErrorHandlerExt(TIFFErrorHandlerExt val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetErrorHandlerExt(val1) __TIFFSetErrorHandlerExt((val1))

TIFFErrorHandlerExt __TIFFSetWarningHandlerExt(TIFFErrorHandlerExt val1) =
	"\tlis\t11,TIFFBase@ha\n"
	"\tlwz\t12,TIFFBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TIFFSetWarningHandlerExt(val1) __TIFFSetWarningHandlerExt((val1))

#endif /*  _VBCCINLINE_TIFF_H  */

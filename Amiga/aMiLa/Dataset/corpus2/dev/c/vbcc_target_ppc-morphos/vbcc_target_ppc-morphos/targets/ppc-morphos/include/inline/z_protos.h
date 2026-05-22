#ifndef _VBCCINLINE_Z_H
#define _VBCCINLINE_Z_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

const char * __zlibVersion() =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define zlibVersion() __zlibVersion()

int __deflateInit_(z_streamp strm, int level, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateInit_(strm, level, version, stream_size) __deflateInit_((strm), (level), (version), (stream_size))

int __deflateInit2_(z_streamp strm, int level, int method, int windowBits, int memLevel, int strategy, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateInit2_(strm, level, method, windowBits, memLevel, strategy, version, stream_size) __deflateInit2_((strm), (level), (method), (windowBits), (memLevel), (strategy), (version), (stream_size))

int __deflate(z_streamp strm, int flush) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflate(strm, flush) __deflate((strm), (flush))

int __deflateEnd(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateEnd(strm) __deflateEnd((strm))

int __deflateSetDictionary(z_streamp strm, const Bytef * dictionary, uInt dictLength) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateSetDictionary(strm, dictionary, dictLength) __deflateSetDictionary((strm), (dictionary), (dictLength))

int __deflateCopy(z_streamp dest, z_streamp source) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateCopy(dest, source) __deflateCopy((dest), (source))

int __deflateReset(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateReset(strm) __deflateReset((strm))

int __deflateParams(z_streamp strm, int level, int strategy) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateParams(strm, level, strategy) __deflateParams((strm), (level), (strategy))

int __inflateInit_(z_streamp strm, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateInit_(strm, version, stream_size) __inflateInit_((strm), (version), (stream_size))

int __inflateInit2_(z_streamp strm, int windowBits, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateInit2_(strm, windowBits, version, stream_size) __inflateInit2_((strm), (windowBits), (version), (stream_size))

int __inflate(z_streamp strm, int flush) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflate(strm, flush) __inflate((strm), (flush))

int __inflateEnd(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateEnd(strm) __inflateEnd((strm))

int __inflateSetDictionary(z_streamp strm, const Bytef * dictionary, uInt dictLength) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateSetDictionary(strm, dictionary, dictLength) __inflateSetDictionary((strm), (dictionary), (dictLength))

int __inflateSync(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateSync(strm) __inflateSync((strm))

int __inflateReset(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateReset(strm) __inflateReset((strm))

int __compress(Bytef * dest, uLongf * destLen, const Bytef * source, uLong sourceLen) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define compress(dest, destLen, source, sourceLen) __compress((dest), (destLen), (source), (sourceLen))

int __compress2(Bytef * dest, uLongf * destLen, const Bytef * source, uLong sourceLen, int level) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define compress2(dest, destLen, source, sourceLen, level) __compress2((dest), (destLen), (source), (sourceLen), (level))

int __uncompress(Bytef * dest, uLongf * destLen, const Bytef * source, uLong sourceLen) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define uncompress(dest, destLen, source, sourceLen) __uncompress((dest), (destLen), (source), (sourceLen))

uLong __adler32(uLong adler, const Bytef * buf, uInt len) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define adler32(adler, buf, len) __adler32((adler), (buf), (len))

uLong __crc32(uLong crc, const Bytef * buf, uInt len) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define crc32(crc, buf, len) __crc32((crc), (buf), (len))

const char * __zError(int err) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define zError(err) __zError((err))

int __inflateSyncPoint(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateSyncPoint(strm) __inflateSyncPoint((strm))

const z_crc_t * __get_crc_table() =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define get_crc_table() __get_crc_table()

int __inflateCopy(z_streamp dest, z_streamp source) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateCopy(dest, source) __inflateCopy((dest), (source))

int __inflateBackInit_(z_streamp strm, int windowBits, unsigned char * window, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBackInit_(strm, windowBits, window, version, stream_size) __inflateBackInit_((strm), (windowBits), (window), (version), (stream_size))

int __inflateBack(z_streamp strm, in_func in, void * in_desc, out_func out, void * out_desc) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBack(strm, in, in_desc, out, out_desc) __inflateBack((strm), (in), (in_desc), (out), (out_desc))

int __inflateBackEnd(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBackEnd(strm) __inflateBackEnd((strm))

uLong __deflateBound(z_streamp strm, uLong sourceLen) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateBound(strm, sourceLen) __deflateBound((strm), (sourceLen))

int __deflatePrime(z_streamp strm, int bits, int value) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflatePrime(strm, bits, value) __deflatePrime((strm), (bits), (value))

uLong __compressBound(uLong sourceLen) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define compressBound(sourceLen) __compressBound((sourceLen))

uLong __zlibCompileFlags() =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define zlibCompileFlags() __zlibCompileFlags()

int __blast(blast_in infun, void * inhow, blast_out outfun, void * outhow) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define blast(infun, inhow, outfun, outhow) __blast((infun), (inhow), (outfun), (outhow))

int __inflateBack9(z_streamp strm, in_func in, void * in_desc, out_func out, void * out_desc) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBack9(strm, in, in_desc, out, out_desc) __inflateBack9((strm), (in), (in_desc), (out), (out_desc))

int __inflateBack9End(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBack9End(strm) __inflateBack9End((strm))

int __inflateBack9Init_(z_streamp strm, unsigned char * window, const char * version, int stream_size) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateBack9Init_(strm, window, version, stream_size) __inflateBack9Init_((strm), (window), (version), (stream_size))

int __deflateTune(z_streamp strm, int good_length, int max_lazy, int nice_length, int max_chain) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateTune(strm, good_length, max_lazy, nice_length, max_chain) __deflateTune((strm), (good_length), (max_lazy), (nice_length), (max_chain))

int __deflateSetHeader(z_streamp strm, gz_headerp head) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateSetHeader(strm, head) __deflateSetHeader((strm), (head))

int __inflatePrime(z_streamp strm, int bits, int value) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflatePrime(strm, bits, value) __inflatePrime((strm), (bits), (value))

int __inflateGetHeader(z_streamp strm, gz_headerp head) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateGetHeader(strm, head) __inflateGetHeader((strm), (head))

uLong __adler32_combine(uLong adler1, uLong adler2, z_off_t len2) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define adler32_combine(adler1, adler2, len2) __adler32_combine((adler1), (adler2), (len2))

uLong __crc32_combine(uLong crc1, uLong crc2, z_off_t len2) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define crc32_combine(crc1, crc2, len2) __crc32_combine((crc1), (crc2), (len2))

int __inflateReset2(z_streamp strm, int windowBits) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateReset2(strm, windowBits) __inflateReset2((strm), (windowBits))

long __inflateMark(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateMark(strm) __inflateMark((strm))

uLong __adler32_combine64(uLong adler1, uLong adler2, z_off64_t len2) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define adler32_combine64(adler1, adler2, len2) __adler32_combine64((adler1), (adler2), (len2))

uLong __crc32_combine64(uLong crc2, uLong d0arg, z_off64_t len2) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define crc32_combine64(crc2, d0arg, len2) __crc32_combine64((crc2), (d0arg), (len2))

int __inflateUndermine(z_streamp strm, int subvert) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateUndermine(strm, subvert) __inflateUndermine((strm), (subvert))

int __deflatePending(z_streamp strm, unsigned * pending, int * bits) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflatePending(strm, pending, bits) __deflatePending((strm), (pending), (bits))

int __inflateResetKeep(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateResetKeep(strm) __inflateResetKeep((strm))

int __deflateResetKeep(z_streamp strm) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define deflateResetKeep(strm) __deflateResetKeep((strm))

int __inflateGetDictionary(z_streamp strm, Bytef * dictionary, uInt  * dictLength) =
	"\tlis\t11,ZBase@ha\n"
	"\tlwz\t12,ZBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define inflateGetDictionary(strm, dictionary, dictLength) __inflateGetDictionary((strm), (dictionary), (dictLength))

#endif /*  _VBCCINLINE_Z_H  */

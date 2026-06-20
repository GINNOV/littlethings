#ifndef _VBCCINLINE_LZMA_H
#define _VBCCINLINE_LZMA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

uint32_t __lzma_version_number() =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_version_number() __lzma_version_number()

const char * __lzma_version_string() =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_version_string() __lzma_version_string()

lzma_ret __lzma_code(lzma_stream * strm, lzma_action action) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_code(strm, action) __lzma_code((strm), (action))

void __lzma_end(lzma_stream * strm) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_end(strm) __lzma_end((strm))

uint64_t __lzma_memusage(const lzma_stream * strm) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_memusage(strm) __lzma_memusage((strm))

uint64_t __lzma_memlimit_get(const lzma_stream * strm) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_memlimit_get(strm) __lzma_memlimit_get((strm))

lzma_ret __lzma_memlimit_set(lzma_stream * strm, uint64_t memlimit) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_memlimit_set(strm, memlimit) __lzma_memlimit_set((strm), (memlimit))

lzma_ret __lzma_vli_encode(lzma_vli vli, size_t * vli_pos, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_vli_encode(vli, vli_pos, out, out_pos, out_size) __lzma_vli_encode((vli), (vli_pos), (out), (out_pos), (out_size))

lzma_ret __lzma_vli_decode(lzma_vli * vli, size_t * vli_pos, const uint8_t * in, size_t * in_pos, size_t in_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_vli_decode(vli, vli_pos, in, in_pos, in_size) __lzma_vli_decode((vli), (vli_pos), (in), (in_pos), (in_size))

uint32_t __lzma_vli_size(lzma_vli vli) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_vli_size(vli) __lzma_vli_size((vli))

lzma_bool __lzma_check_is_supported(lzma_check check) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_check_is_supported(check) __lzma_check_is_supported((check))

uint32_t __lzma_check_size(lzma_check check) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_check_size(check) __lzma_check_size((check))

uint32_t __lzma_crc32(const uint8_t * buf, size_t size, uint32_t crc) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_crc32(buf, size, crc) __lzma_crc32((buf), (size), (crc))

uint64_t __lzma_crc64(const uint8_t * buf, size_t size, uint64_t crc) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_crc64(buf, size, crc) __lzma_crc64((buf), (size), (crc))

lzma_check __lzma_get_check(const lzma_stream * strm) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_get_check(strm) __lzma_get_check((strm))

lzma_bool __lzma_filter_encoder_is_supported(lzma_vli id) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filter_encoder_is_supported(id) __lzma_filter_encoder_is_supported((id))

lzma_bool __lzma_filter_decoder_is_supported(lzma_vli id) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filter_decoder_is_supported(id) __lzma_filter_decoder_is_supported((id))

lzma_ret __lzma_filters_copy(const lzma_filter * src, lzma_filter * dest, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filters_copy(src, dest, allocator) __lzma_filters_copy((src), (dest), (allocator))

uint64_t __lzma_raw_encoder_memusage(const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_encoder_memusage(filters) __lzma_raw_encoder_memusage((filters))

uint64_t __lzma_raw_decoder_memusage(const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_decoder_memusage(filters) __lzma_raw_decoder_memusage((filters))

lzma_ret __lzma_raw_encoder(lzma_stream * strm, const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_encoder(strm, filters) __lzma_raw_encoder((strm), (filters))

lzma_ret __lzma_raw_decoder(lzma_stream * strm, const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_decoder(strm, filters) __lzma_raw_decoder((strm), (filters))

lzma_ret __lzma_filters_update(lzma_stream * strm, const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filters_update(strm, filters) __lzma_filters_update((strm), (filters))

lzma_ret __lzma_raw_buffer_encode(const lzma_filter * filters, lzma_allocator * allocator, const uint8_t * in, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_buffer_encode(filters, allocator, in, in_size, out, out_pos, out_size) __lzma_raw_buffer_encode((filters), (allocator), (in), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_raw_buffer_decode(const lzma_filter * filters, lzma_allocator * allocator, const uint8_t * in, size_t * in_pos, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_raw_buffer_decode(filters, allocator, in, in_pos, in_size, out, out_pos, out_size) __lzma_raw_buffer_decode((filters), (allocator), (in), (in_pos), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_properties_size(uint32_t * size, const lzma_filter * filter) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_properties_size(size, filter) __lzma_properties_size((size), (filter))

lzma_ret __lzma_properties_encode(const lzma_filter * filter, uint8_t * props) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_properties_encode(filter, props) __lzma_properties_encode((filter), (props))

lzma_ret __lzma_properties_decode(lzma_filter * filter, lzma_allocator * allocator, const uint8_t * props, size_t props_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_properties_decode(filter, allocator, props, props_size) __lzma_properties_decode((filter), (allocator), (props), (props_size))

lzma_ret __lzma_filter_flags_size(uint32_t * size, const lzma_filter * filters) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filter_flags_size(size, filters) __lzma_filter_flags_size((size), (filters))

lzma_ret __lzma_filter_flags_encode(const lzma_filter * filters, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filter_flags_encode(filters, out, out_pos, out_size) __lzma_filter_flags_encode((filters), (out), (out_pos), (out_size))

lzma_ret __lzma_filter_flags_decode(lzma_filter * filters, lzma_allocator * allocator, const uint8_t * in, size_t * in_pos, size_t in_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_filter_flags_decode(filters, allocator, in, in_pos, in_size) __lzma_filter_flags_decode((filters), (allocator), (in), (in_pos), (in_size))

lzma_bool __lzma_mf_is_supported(lzma_match_finder match_finder) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_mf_is_supported(match_finder) __lzma_mf_is_supported((match_finder))

lzma_bool __lzma_mode_is_supported(lzma_mode mode) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_mode_is_supported(mode) __lzma_mode_is_supported((mode))

lzma_bool __lzma_lzma_preset(lzma_options_lzma * options, uint32_t preset) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_lzma_preset(options, preset) __lzma_lzma_preset((options), (preset))

uint64_t __lzma_easy_encoder_memusage(uint32_t preset) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_easy_encoder_memusage(preset) __lzma_easy_encoder_memusage((preset))

uint64_t __lzma_easy_decoder_memusage(uint32_t preset) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_easy_decoder_memusage(preset) __lzma_easy_decoder_memusage((preset))

lzma_ret __lzma_easy_encoder(lzma_stream * strm, uint32_t preset, lzma_check check) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_easy_encoder(strm, preset, check) __lzma_easy_encoder((strm), (preset), (check))

lzma_ret __lzma_easy_buffer_encode(uint32_t preset, lzma_check check, lzma_allocator * allocator, const uint8_t * in, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_easy_buffer_encode(preset, check, allocator, in, in_size, out, out_pos, out_size) __lzma_easy_buffer_encode((preset), (check), (allocator), (in), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_stream_encoder(lzma_stream * strm, const lzma_filter * filters, lzma_check check) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_encoder(strm, filters, check) __lzma_stream_encoder((strm), (filters), (check))

lzma_ret __lzma_alone_encoder(lzma_stream * strm, const lzma_options_lzma * options) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_alone_encoder(strm, options) __lzma_alone_encoder((strm), (options))

size_t __lzma_stream_buffer_bound(size_t uncompressed_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_buffer_bound(uncompressed_size) __lzma_stream_buffer_bound((uncompressed_size))

lzma_ret __lzma_stream_buffer_encode(lzma_filter * filters, lzma_check check, lzma_allocator * allocator, const uint8_t * in, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_buffer_encode(filters, check, allocator, in, in_size, out, out_pos, out_size) __lzma_stream_buffer_encode((filters), (check), (allocator), (in), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_stream_decoder(lzma_stream * strm, uint64_t memlimit, uint32_t flags) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_decoder(strm, memlimit, flags) __lzma_stream_decoder((strm), (memlimit), (flags))

lzma_ret __lzma_auto_decoder(lzma_stream * strm, uint64_t memlimit, uint32_t flags) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_auto_decoder(strm, memlimit, flags) __lzma_auto_decoder((strm), (memlimit), (flags))

lzma_ret __lzma_alone_decoder(lzma_stream * strm, uint64_t memlimit) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_alone_decoder(strm, memlimit) __lzma_alone_decoder((strm), (memlimit))

lzma_ret __lzma_stream_buffer_decode(uint64_t * memlimit, uint32_t flags, lzma_allocator * allocator, const uint8_t * in, size_t * in_pos, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_buffer_decode(memlimit, flags, allocator, in, in_pos, in_size, out, out_pos, out_size) __lzma_stream_buffer_decode((memlimit), (flags), (allocator), (in), (in_pos), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_stream_header_encode(const lzma_stream_flags * options, uint8_t * out) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_header_encode(options, out) __lzma_stream_header_encode((options), (out))

lzma_ret __lzma_stream_footer_encode(const lzma_stream_flags * options, uint8_t * out) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_footer_encode(options, out) __lzma_stream_footer_encode((options), (out))

lzma_ret __lzma_stream_header_decode(lzma_stream_flags * options, const uint8_t * in) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_header_decode(options, in) __lzma_stream_header_decode((options), (in))

lzma_ret __lzma_stream_footer_decode(lzma_stream_flags * options, const uint8_t * in) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_footer_decode(options, in) __lzma_stream_footer_decode((options), (in))

lzma_ret __lzma_stream_flags_compare(const lzma_stream_flags * a, const lzma_stream_flags * b) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_stream_flags_compare(a, b) __lzma_stream_flags_compare((a), (b))

lzma_ret __lzma_block_header_size(lzma_block * block) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_header_size(block) __lzma_block_header_size((block))

lzma_ret __lzma_block_header_encode(const lzma_block * block, uint8_t * out) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_header_encode(block, out) __lzma_block_header_encode((block), (out))

lzma_ret __lzma_block_header_decode(lzma_block * block, lzma_allocator * allocator, const uint8_t * in) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_header_decode(block, allocator, in) __lzma_block_header_decode((block), (allocator), (in))

lzma_ret __lzma_block_compressed_size(lzma_block * block, lzma_vli unpadded_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_compressed_size(block, unpadded_size) __lzma_block_compressed_size((block), (unpadded_size))

lzma_vli __lzma_block_unpadded_size(const lzma_block * block) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_unpadded_size(block) __lzma_block_unpadded_size((block))

lzma_vli __lzma_block_total_size(const lzma_block * block) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_total_size(block) __lzma_block_total_size((block))

lzma_ret __lzma_block_encoder(lzma_stream * strm, lzma_block * block) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_encoder(strm, block) __lzma_block_encoder((strm), (block))

lzma_ret __lzma_block_decoder(lzma_stream * strm, lzma_block * block) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_decoder(strm, block) __lzma_block_decoder((strm), (block))

size_t __lzma_block_buffer_bound(size_t uncompressed_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_buffer_bound(uncompressed_size) __lzma_block_buffer_bound((uncompressed_size))

lzma_ret __lzma_block_buffer_encode(lzma_block * block, lzma_allocator * allocator, const uint8_t * in, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_buffer_encode(block, allocator, in, in_size, out, out_pos, out_size) __lzma_block_buffer_encode((block), (allocator), (in), (in_size), (out), (out_pos), (out_size))

lzma_ret __lzma_block_buffer_decode(lzma_block * block, lzma_allocator * allocator, const uint8_t * in, size_t * in_pos, size_t in_size, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_block_buffer_decode(block, allocator, in, in_pos, in_size, out, out_pos, out_size) __lzma_block_buffer_decode((block), (allocator), (in), (in_pos), (in_size), (out), (out_pos), (out_size))

uint64_t __lzma_index_memusage(lzma_vli streams, lzma_vli blocks) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_memusage(streams, blocks) __lzma_index_memusage((streams), (blocks))

uint64_t __lzma_index_memused(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_memused(i) __lzma_index_memused((i))

lzma_index * __lzma_index_init(lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_init(allocator) __lzma_index_init((allocator))

void __lzma_index_end(lzma_index * i, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_end(i, allocator) __lzma_index_end((i), (allocator))

lzma_ret __lzma_index_append(lzma_index * i, lzma_allocator * allocator, lzma_vli unpadded_size, lzma_vli uncompressed_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_append(i, allocator, unpadded_size, uncompressed_size) __lzma_index_append((i), (allocator), (unpadded_size), (uncompressed_size))

lzma_ret __lzma_index_stream_flags(lzma_index * i, const lzma_stream_flags * stream_flags) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_stream_flags(i, stream_flags) __lzma_index_stream_flags((i), (stream_flags))

uint32_t __lzma_index_checks(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_checks(i) __lzma_index_checks((i))

lzma_ret __lzma_index_stream_padding(lzma_index * i, lzma_vli stream_padding) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_stream_padding(i, stream_padding) __lzma_index_stream_padding((i), (stream_padding))

lzma_vli __lzma_index_stream_count(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_stream_count(i) __lzma_index_stream_count((i))

lzma_vli __lzma_index_block_count(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_block_count(i) __lzma_index_block_count((i))

lzma_vli __lzma_index_size(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_size(i) __lzma_index_size((i))

lzma_vli __lzma_index_stream_size(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_stream_size(i) __lzma_index_stream_size((i))

lzma_vli __lzma_index_total_size(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_total_size(i) __lzma_index_total_size((i))

lzma_vli __lzma_index_file_size(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_file_size(i) __lzma_index_file_size((i))

lzma_vli __lzma_index_uncompressed_size(const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_uncompressed_size(i) __lzma_index_uncompressed_size((i))

void __lzma_index_iter_init(lzma_index_iter * iter, const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_iter_init(iter, i) __lzma_index_iter_init((iter), (i))

void __lzma_index_iter_rewind(lzma_index_iter * iter) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_iter_rewind(iter) __lzma_index_iter_rewind((iter))

lzma_bool __lzma_index_iter_next(lzma_index_iter * iter, lzma_index_iter_mode mode) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_iter_next(iter, mode) __lzma_index_iter_next((iter), (mode))

lzma_bool __lzma_index_iter_locate(lzma_index_iter * iter, lzma_vli target) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_iter_locate(iter, target) __lzma_index_iter_locate((iter), (target))

lzma_ret __lzma_index_cat(lzma_index * dest, lzma_index * src, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_cat(dest, src, allocator) __lzma_index_cat((dest), (src), (allocator))

lzma_index * __lzma_index_dup(const lzma_index * i, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_dup(i, allocator) __lzma_index_dup((i), (allocator))

lzma_ret __lzma_index_encoder(lzma_stream * strm, const lzma_index * i) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_encoder(strm, i) __lzma_index_encoder((strm), (i))

lzma_ret __lzma_index_decoder(lzma_stream * strm, lzma_index ** i, uint64_t memlimit) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_decoder(strm, i, memlimit) __lzma_index_decoder((strm), (i), (memlimit))

lzma_ret __lzma_index_buffer_encode(const lzma_index * i, uint8_t * out, size_t * out_pos, size_t out_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_buffer_encode(i, out, out_pos, out_size) __lzma_index_buffer_encode((i), (out), (out_pos), (out_size))

lzma_ret __lzma_index_buffer_decode(lzma_index ** i, uint64_t * memlimit, lzma_allocator * allocator, const uint8_t * in, size_t * in_pos, size_t in_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_buffer_decode(i, memlimit, allocator, in, in_pos, in_size) __lzma_index_buffer_decode((i), (memlimit), (allocator), (in), (in_pos), (in_size))

lzma_index_hash * __lzma_index_hash_init(lzma_index_hash * index_hash, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_hash_init(index_hash, allocator) __lzma_index_hash_init((index_hash), (allocator))

void __lzma_index_hash_end(lzma_index_hash * index_hash, lzma_allocator * allocator) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_hash_end(index_hash, allocator) __lzma_index_hash_end((index_hash), (allocator))

lzma_ret __lzma_index_hash_append(lzma_index_hash * index_hash, lzma_vli unpadded_size, lzma_vli uncompressed_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_hash_append(index_hash, unpadded_size, uncompressed_size) __lzma_index_hash_append((index_hash), (unpadded_size), (uncompressed_size))

lzma_ret __lzma_index_hash_decode(lzma_index_hash * index_hash, const uint8_t * in, size_t * in_pos, size_t in_size) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_hash_decode(index_hash, in, in_pos, in_size) __lzma_index_hash_decode((index_hash), (in), (in_pos), (in_size))

lzma_vli __lzma_index_hash_size(const lzma_index_hash * index_hash) =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_index_hash_size(index_hash) __lzma_index_hash_size((index_hash))

uint64_t __lzma_physmem() =
	"\tlis\t11,LZMABase@ha\n"
	"\tlwz\t12,LZMABase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_physmem() __lzma_physmem()

lzma_ret __lzma_EasyGetSize(void *, const void * src, size_t srclen, int64_t * size) =
	"\tlwz\t0,-592(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_EasyGetSize(src, srclen, size) __lzma_EasyGetSize(LZMABase, (src), (srclen), (size))

lzma_ret __lzma_EasyDecode(void *, void * dest, size_t * destlen, const void * src, size_t srclen, lzma_allocator * allocator) =
	"\tlwz\t0,-598(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define lzma_EasyDecode(dest, destlen, src, srclen, allocator) __lzma_EasyDecode(LZMABase, (dest), (destlen), (src), (srclen), (allocator))

#endif /*  _VBCCINLINE_LZMA_H  */

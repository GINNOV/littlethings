#ifndef _VBCCINLINE_HARFBUZZ_H
#define _VBCCINLINE_HARFBUZZ_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

hb_blob_t * __hb_blob_create(const char * data, unsigned int length, hb_memory_mode_t mode, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_create(data, length, mode, user_data, destroy) __hb_blob_create((data), (length), (mode), (user_data), (destroy))

hb_blob_t * __hb_blob_create_sub_blob(hb_blob_t * parent, unsigned int offset, unsigned int length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_create_sub_blob(parent, offset, length) __hb_blob_create_sub_blob((parent), (offset), (length))

hb_blob_t * __hb_blob_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_get_empty() __hb_blob_get_empty()

hb_blob_t * __hb_blob_reference(hb_blob_t * blob) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_reference(blob) __hb_blob_reference((blob))

void __hb_blob_destroy(hb_blob_t * blob) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_destroy(blob) __hb_blob_destroy((blob))

hb_bool_t __hb_blob_set_user_data(hb_blob_t * blob, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_set_user_data(blob, key, data, destroy, replace) __hb_blob_set_user_data((blob), (key), (data), (destroy), (replace))

void * __hb_blob_get_user_data(hb_blob_t * blob, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_get_user_data(blob, key) __hb_blob_get_user_data((blob), (key))

void __hb_blob_make_immutable(hb_blob_t * blob) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_make_immutable(blob) __hb_blob_make_immutable((blob))

hb_bool_t __hb_blob_is_immutable(hb_blob_t * blob) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_is_immutable(blob) __hb_blob_is_immutable((blob))

unsigned int __hb_blob_get_length(hb_blob_t * blob) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_get_length(blob) __hb_blob_get_length((blob))

const char * __hb_blob_get_data(hb_blob_t * blob, unsigned int * length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_get_data(blob, length) __hb_blob_get_data((blob), (length))

char * __hb_blob_get_data_writable(hb_blob_t * blob, unsigned int * length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_blob_get_data_writable(blob, length) __hb_blob_get_data_writable((blob), (length))

hb_bool_t __hb_segment_properties_equal(const hb_segment_properties_t * a, const hb_segment_properties_t * b) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_segment_properties_equal(a, b) __hb_segment_properties_equal((a), (b))

unsigned int __hb_segment_properties_hash(const hb_segment_properties_t * p) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_segment_properties_hash(p) __hb_segment_properties_hash((p))

hb_buffer_t * __hb_buffer_create() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_create() __hb_buffer_create()

hb_buffer_t * __hb_buffer_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_empty() __hb_buffer_get_empty()

hb_buffer_t * __hb_buffer_reference(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_reference(buffer) __hb_buffer_reference((buffer))

void __hb_buffer_destroy(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_destroy(buffer) __hb_buffer_destroy((buffer))

hb_bool_t __hb_buffer_set_user_data(hb_buffer_t * buffer, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_user_data(buffer, key, data, destroy, replace) __hb_buffer_set_user_data((buffer), (key), (data), (destroy), (replace))

void * __hb_buffer_get_user_data(hb_buffer_t * buffer, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_user_data(buffer, key) __hb_buffer_get_user_data((buffer), (key))

void __hb_buffer_set_content_type(hb_buffer_t * buffer, hb_buffer_content_type_t content_type) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_content_type(buffer, content_type) __hb_buffer_set_content_type((buffer), (content_type))

hb_buffer_content_type_t __hb_buffer_get_content_type(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_content_type(buffer) __hb_buffer_get_content_type((buffer))

void __hb_buffer_set_unicode_funcs(hb_buffer_t * buffer, hb_unicode_funcs_t * unicode_funcs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_unicode_funcs(buffer, unicode_funcs) __hb_buffer_set_unicode_funcs((buffer), (unicode_funcs))

hb_unicode_funcs_t * __hb_buffer_get_unicode_funcs(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_unicode_funcs(buffer) __hb_buffer_get_unicode_funcs((buffer))

void __hb_buffer_set_direction(hb_buffer_t * buffer, hb_direction_t direction) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_direction(buffer, direction) __hb_buffer_set_direction((buffer), (direction))

hb_direction_t __hb_buffer_get_direction(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_direction(buffer) __hb_buffer_get_direction((buffer))

void __hb_buffer_set_script(hb_buffer_t * buffer, hb_script_t script) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_script(buffer, script) __hb_buffer_set_script((buffer), (script))

hb_script_t __hb_buffer_get_script(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_script(buffer) __hb_buffer_get_script((buffer))

void __hb_buffer_set_language(hb_buffer_t * buffer, hb_language_t language) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_language(buffer, language) __hb_buffer_set_language((buffer), (language))

hb_language_t __hb_buffer_get_language(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_language(buffer) __hb_buffer_get_language((buffer))

void __hb_buffer_set_segment_properties(hb_buffer_t * buffer, const hb_segment_properties_t * props) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_segment_properties(buffer, props) __hb_buffer_set_segment_properties((buffer), (props))

void __hb_buffer_get_segment_properties(hb_buffer_t * buffer, hb_segment_properties_t * props) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_segment_properties(buffer, props) __hb_buffer_get_segment_properties((buffer), (props))

void __hb_buffer_guess_segment_properties(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_guess_segment_properties(buffer) __hb_buffer_guess_segment_properties((buffer))

void __hb_buffer_set_flags(hb_buffer_t * buffer, hb_buffer_flags_t flags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_flags(buffer, flags) __hb_buffer_set_flags((buffer), (flags))

hb_buffer_flags_t __hb_buffer_get_flags(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_flags(buffer) __hb_buffer_get_flags((buffer))

void __hb_buffer_set_cluster_level(hb_buffer_t * buffer, hb_buffer_cluster_level_t cluster_level) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_cluster_level(buffer, cluster_level) __hb_buffer_set_cluster_level((buffer), (cluster_level))

hb_buffer_cluster_level_t __hb_buffer_get_cluster_level(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_cluster_level(buffer) __hb_buffer_get_cluster_level((buffer))

void __hb_buffer_set_replacement_codepoint(hb_buffer_t * buffer, hb_codepoint_t replacement) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_replacement_codepoint(buffer, replacement) __hb_buffer_set_replacement_codepoint((buffer), (replacement))

hb_codepoint_t __hb_buffer_get_replacement_codepoint(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_replacement_codepoint(buffer) __hb_buffer_get_replacement_codepoint((buffer))

void __hb_buffer_reset(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_reset(buffer) __hb_buffer_reset((buffer))

void __hb_buffer_clear_contents(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_clear_contents(buffer) __hb_buffer_clear_contents((buffer))

hb_bool_t __hb_buffer_pre_allocate(hb_buffer_t * buffer, unsigned int size) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_pre_allocate(buffer, size) __hb_buffer_pre_allocate((buffer), (size))

hb_bool_t __hb_buffer_allocation_successful(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_allocation_successful(buffer) __hb_buffer_allocation_successful((buffer))

void __hb_buffer_reverse(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_reverse(buffer) __hb_buffer_reverse((buffer))

void __hb_buffer_reverse_range(hb_buffer_t * buffer, unsigned int start, unsigned int end) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_reverse_range(buffer, start, end) __hb_buffer_reverse_range((buffer), (start), (end))

void __hb_buffer_reverse_clusters(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_reverse_clusters(buffer) __hb_buffer_reverse_clusters((buffer))

void __hb_buffer_add(hb_buffer_t * buffer, hb_codepoint_t codepoint, unsigned int cluster) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add(buffer, codepoint, cluster) __hb_buffer_add((buffer), (codepoint), (cluster))

void __hb_buffer_add_utf8(hb_buffer_t * buffer, const char * text, int text_length, unsigned int item_offset, int item_length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add_utf8(buffer, text, text_length, item_offset, item_length) __hb_buffer_add_utf8((buffer), (text), (text_length), (item_offset), (item_length))

void __hb_buffer_add_utf16(hb_buffer_t * buffer, const uint16_t * text, int text_length, unsigned int item_offset, int item_length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add_utf16(buffer, text, text_length, item_offset, item_length) __hb_buffer_add_utf16((buffer), (text), (text_length), (item_offset), (item_length))

void __hb_buffer_add_utf32(hb_buffer_t * buffer, const uint32_t * text, int text_length, unsigned int item_offset, int item_length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add_utf32(buffer, text, text_length, item_offset, item_length) __hb_buffer_add_utf32((buffer), (text), (text_length), (item_offset), (item_length))

void __hb_buffer_add_latin1(hb_buffer_t * buffer, const uint8_t * text, int text_length, unsigned int item_offset, int item_length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add_latin1(buffer, text, text_length, item_offset, item_length) __hb_buffer_add_latin1((buffer), (text), (text_length), (item_offset), (item_length))

void __hb_buffer_add_codepoints(hb_buffer_t * buffer, const hb_codepoint_t * text, int text_length, unsigned int item_offset, int item_length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_add_codepoints(buffer, text, text_length, item_offset, item_length) __hb_buffer_add_codepoints((buffer), (text), (text_length), (item_offset), (item_length))

hb_bool_t __hb_buffer_set_length(hb_buffer_t * buffer, unsigned int length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_length(buffer, length) __hb_buffer_set_length((buffer), (length))

unsigned int __hb_buffer_get_length(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_length(buffer) __hb_buffer_get_length((buffer))

hb_glyph_info_t * __hb_buffer_get_glyph_infos(hb_buffer_t * buffer, unsigned int * length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_glyph_infos(buffer, length) __hb_buffer_get_glyph_infos((buffer), (length))

hb_glyph_position_t * __hb_buffer_get_glyph_positions(hb_buffer_t * buffer, unsigned int * length) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_get_glyph_positions(buffer, length) __hb_buffer_get_glyph_positions((buffer), (length))

void __hb_buffer_normalize_glyphs(hb_buffer_t * buffer) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_normalize_glyphs(buffer) __hb_buffer_normalize_glyphs((buffer))

hb_buffer_serialize_format_t __hb_buffer_serialize_format_from_string(const char * str, int len) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_serialize_format_from_string(str, len) __hb_buffer_serialize_format_from_string((str), (len))

const char * __hb_buffer_serialize_format_to_string(hb_buffer_serialize_format_t format) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_serialize_format_to_string(format) __hb_buffer_serialize_format_to_string((format))

const char ** __hb_buffer_serialize_list_formats() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_serialize_list_formats() __hb_buffer_serialize_list_formats()

unsigned int __hb_buffer_serialize_glyphs(hb_buffer_t * buffer, unsigned int start, unsigned int end, char * buf, unsigned int buf_size, unsigned int * buf_consumed, hb_font_t * font, hb_buffer_serialize_format_t format, hb_buffer_serialize_flags_t flags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_serialize_glyphs(buffer, start, end, buf, buf_size, buf_consumed, font, format, flags) __hb_buffer_serialize_glyphs((buffer), (start), (end), (buf), (buf_size), (buf_consumed), (font), (format), (flags))

hb_bool_t __hb_buffer_deserialize_glyphs(hb_buffer_t * buffer, const char * buf, int buf_len, const char ** end_ptr, hb_font_t * font, hb_buffer_serialize_format_t format) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_deserialize_glyphs(buffer, buf, buf_len, end_ptr, font, format) __hb_buffer_deserialize_glyphs((buffer), (buf), (buf_len), (end_ptr), (font), (format))

void __hb_buffer_set_message_func(hb_buffer_t * buffer, hb_buffer_message_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_buffer_set_message_func(buffer, func, user_data, destroy) __hb_buffer_set_message_func((buffer), (func), (user_data), (destroy))

hb_tag_t __hb_tag_from_string(const char * str, int len) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_tag_from_string(str, len) __hb_tag_from_string((str), (len))

void __hb_tag_to_string(hb_tag_t d0arg, char * buf) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_tag_to_string(d0arg, buf) __hb_tag_to_string((d0arg), (buf))

hb_direction_t __hb_direction_from_string(const char * str, int len) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_direction_from_string(str, len) __hb_direction_from_string((str), (len))

const char * __hb_direction_to_string(hb_direction_t direction) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_direction_to_string(direction) __hb_direction_to_string((direction))

hb_language_t __hb_language_from_string(const char * str, int len) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_language_from_string(str, len) __hb_language_from_string((str), (len))

const char * __hb_language_to_string(hb_language_t language) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_language_to_string(language) __hb_language_to_string((language))

hb_language_t __hb_language_get_default() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_language_get_default() __hb_language_get_default()

hb_script_t __hb_script_from_iso15924_tag(hb_tag_t d0arg) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_script_from_iso15924_tag(d0arg) __hb_script_from_iso15924_tag((d0arg))

hb_script_t __hb_script_from_string(const char * str, int len) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_script_from_string(str, len) __hb_script_from_string((str), (len))

hb_tag_t __hb_script_to_iso15924_tag(hb_script_t script) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_script_to_iso15924_tag(script) __hb_script_to_iso15924_tag((script))

hb_direction_t __hb_script_get_horizontal_direction(hb_script_t script) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_script_get_horizontal_direction(script) __hb_script_get_horizontal_direction((script))

hb_face_t * __hb_face_create(hb_blob_t * blob, unsigned int index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_create(blob, index) __hb_face_create((blob), (index))

hb_face_t * __hb_face_create_for_tables(hb_reference_table_func_t reference_table_func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_create_for_tables(reference_table_func, user_data, destroy) __hb_face_create_for_tables((reference_table_func), (user_data), (destroy))

hb_face_t * __hb_face_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_get_empty() __hb_face_get_empty()

hb_face_t * __hb_face_reference(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_reference(face) __hb_face_reference((face))

void __hb_face_destroy(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_destroy(face) __hb_face_destroy((face))

hb_bool_t __hb_face_set_user_data(hb_face_t * face, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_set_user_data(face, key, data, destroy, replace) __hb_face_set_user_data((face), (key), (data), (destroy), (replace))

void * __hb_face_get_user_data(hb_face_t * face, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_get_user_data(face, key) __hb_face_get_user_data((face), (key))

void __hb_face_make_immutable(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_make_immutable(face) __hb_face_make_immutable((face))

hb_bool_t __hb_face_is_immutable(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_is_immutable(face) __hb_face_is_immutable((face))

hb_blob_t * __hb_face_reference_table(hb_face_t * face, hb_tag_t d0arg) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_reference_table(face, d0arg) __hb_face_reference_table((face), (d0arg))

hb_blob_t * __hb_face_reference_blob(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_reference_blob(face) __hb_face_reference_blob((face))

void __hb_face_set_index(hb_face_t * face, unsigned int index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_set_index(face, index) __hb_face_set_index((face), (index))

unsigned int __hb_face_get_index(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_get_index(face) __hb_face_get_index((face))

void __hb_face_set_upem(hb_face_t * face, unsigned int upem) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_set_upem(face, upem) __hb_face_set_upem((face), (upem))

unsigned int __hb_face_get_upem(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_get_upem(face) __hb_face_get_upem((face))

void __hb_face_set_glyph_count(hb_face_t * face, unsigned int glyph_count) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_set_glyph_count(face, glyph_count) __hb_face_set_glyph_count((face), (glyph_count))

unsigned int __hb_face_get_glyph_count(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_face_get_glyph_count(face) __hb_face_get_glyph_count((face))

hb_font_funcs_t * __hb_font_funcs_create() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_create() __hb_font_funcs_create()

hb_font_funcs_t * __hb_font_funcs_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_get_empty() __hb_font_funcs_get_empty()

hb_font_funcs_t * __hb_font_funcs_reference(hb_font_funcs_t * ffuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_reference(ffuncs) __hb_font_funcs_reference((ffuncs))

void __hb_font_funcs_destroy(hb_font_funcs_t * ffuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_destroy(ffuncs) __hb_font_funcs_destroy((ffuncs))

hb_bool_t __hb_font_funcs_set_user_data(hb_font_funcs_t * ffuncs, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_user_data(ffuncs, key, data, destroy, replace) __hb_font_funcs_set_user_data((ffuncs), (key), (data), (destroy), (replace))

void * __hb_font_funcs_get_user_data(hb_font_funcs_t * ffuncs, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_get_user_data(ffuncs, key) __hb_font_funcs_get_user_data((ffuncs), (key))

void __hb_font_funcs_make_immutable(hb_font_funcs_t * ffuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_make_immutable(ffuncs) __hb_font_funcs_make_immutable((ffuncs))

hb_bool_t __hb_font_funcs_is_immutable(hb_font_funcs_t * ffuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_is_immutable(ffuncs) __hb_font_funcs_is_immutable((ffuncs))

void __hb_font_funcs_set_font_h_extents_func(hb_font_funcs_t * ffuncs, hb_font_get_font_h_extents_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_font_h_extents_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_font_h_extents_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_font_v_extents_func(hb_font_funcs_t * ffuncs, hb_font_get_font_v_extents_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_font_v_extents_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_font_v_extents_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_h_advance_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_h_advance_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_h_advance_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_h_advance_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_v_advance_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_v_advance_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_v_advance_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_v_advance_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_h_origin_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_h_origin_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_h_origin_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_h_origin_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_v_origin_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_v_origin_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_v_origin_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_v_origin_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_h_kerning_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_h_kerning_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_h_kerning_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_h_kerning_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_v_kerning_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_v_kerning_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_v_kerning_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_v_kerning_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_extents_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_extents_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_extents_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_extents_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_contour_point_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_contour_point_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_contour_point_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_contour_point_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_name_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_name_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_name_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_name_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_glyph_from_name_func(hb_font_funcs_t * ffuncs, hb_font_get_glyph_from_name_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_glyph_from_name_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_glyph_from_name_func((ffuncs), (func), (user_data), (destroy))

hb_bool_t __hb_font_get_h_extents(hb_font_t * font, hb_font_extents_t * extents) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_h_extents(font, extents) __hb_font_get_h_extents((font), (extents))

hb_bool_t __hb_font_get_v_extents(hb_font_t * font, hb_font_extents_t * extents) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_v_extents(font, extents) __hb_font_get_v_extents((font), (extents))

hb_bool_t __hb_font_get_glyph(hb_font_t * font, hb_codepoint_t unicode, hb_codepoint_t variation_selector, hb_codepoint_t * glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph(font, unicode, variation_selector, glyph) __hb_font_get_glyph((font), (unicode), (variation_selector), (glyph))

hb_position_t __hb_font_get_glyph_h_advance(hb_font_t * font, hb_codepoint_t glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_h_advance(font, glyph) __hb_font_get_glyph_h_advance((font), (glyph))

hb_position_t __hb_font_get_glyph_v_advance(hb_font_t * font, hb_codepoint_t glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_v_advance(font, glyph) __hb_font_get_glyph_v_advance((font), (glyph))

hb_bool_t __hb_font_get_glyph_h_origin(hb_font_t * font, hb_codepoint_t glyph, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_h_origin(font, glyph, x, y) __hb_font_get_glyph_h_origin((font), (glyph), (x), (y))

hb_bool_t __hb_font_get_glyph_v_origin(hb_font_t * font, hb_codepoint_t glyph, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_v_origin(font, glyph, x, y) __hb_font_get_glyph_v_origin((font), (glyph), (x), (y))

hb_position_t __hb_font_get_glyph_h_kerning(hb_font_t * font, hb_codepoint_t left_glyph, hb_codepoint_t right_glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_h_kerning(font, left_glyph, right_glyph) __hb_font_get_glyph_h_kerning((font), (left_glyph), (right_glyph))

hb_position_t __hb_font_get_glyph_v_kerning(hb_font_t * font, hb_codepoint_t top_glyph, hb_codepoint_t bottom_glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_v_kerning(font, top_glyph, bottom_glyph) __hb_font_get_glyph_v_kerning((font), (top_glyph), (bottom_glyph))

hb_bool_t __hb_font_get_glyph_extents(hb_font_t * font, hb_codepoint_t glyph, hb_glyph_extents_t * extents) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_extents(font, glyph, extents) __hb_font_get_glyph_extents((font), (glyph), (extents))

hb_bool_t __hb_font_get_glyph_contour_point(hb_font_t * font, hb_codepoint_t glyph, unsigned int point_index, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_contour_point(font, glyph, point_index, x, y) __hb_font_get_glyph_contour_point((font), (glyph), (point_index), (x), (y))

hb_bool_t __hb_font_get_glyph_name(hb_font_t * font, hb_codepoint_t glyph, char * name, unsigned int size) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_name(font, glyph, name, size) __hb_font_get_glyph_name((font), (glyph), (name), (size))

hb_bool_t __hb_font_get_glyph_from_name(hb_font_t * font, const char * name, int len, hb_codepoint_t * glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_from_name(font, name, len, glyph) __hb_font_get_glyph_from_name((font), (name), (len), (glyph))

void __hb_font_get_extents_for_direction(hb_font_t * font, hb_direction_t direction, hb_font_extents_t * extents) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_extents_for_direction(font, direction, extents) __hb_font_get_extents_for_direction((font), (direction), (extents))

void __hb_font_get_glyph_advance_for_direction(hb_font_t * font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_advance_for_direction(font, glyph, direction, x, y) __hb_font_get_glyph_advance_for_direction((font), (glyph), (direction), (x), (y))

void __hb_font_get_glyph_origin_for_direction(hb_font_t * font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_origin_for_direction(font, glyph, direction, x, y) __hb_font_get_glyph_origin_for_direction((font), (glyph), (direction), (x), (y))

void __hb_font_add_glyph_origin_for_direction(hb_font_t * font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_add_glyph_origin_for_direction(font, glyph, direction, x, y) __hb_font_add_glyph_origin_for_direction((font), (glyph), (direction), (x), (y))

void __hb_font_subtract_glyph_origin_for_direction(hb_font_t * font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_subtract_glyph_origin_for_direction(font, glyph, direction, x, y) __hb_font_subtract_glyph_origin_for_direction((font), (glyph), (direction), (x), (y))

void __hb_font_get_glyph_kerning_for_direction(hb_font_t * font, hb_codepoint_t first_glyph, hb_codepoint_t second_glyph, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_kerning_for_direction(font, first_glyph, second_glyph, direction, x, y) __hb_font_get_glyph_kerning_for_direction((font), (first_glyph), (second_glyph), (direction), (x), (y))

hb_bool_t __hb_font_get_glyph_extents_for_origin(hb_font_t * font, hb_codepoint_t glyph, hb_direction_t direction, hb_glyph_extents_t * extents) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_extents_for_origin(font, glyph, direction, extents) __hb_font_get_glyph_extents_for_origin((font), (glyph), (direction), (extents))

hb_bool_t __hb_font_get_glyph_contour_point_for_origin(hb_font_t * font, hb_codepoint_t glyph, unsigned int point_index, hb_direction_t direction, hb_position_t * x, hb_position_t * y) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_glyph_contour_point_for_origin(font, glyph, point_index, direction, x, y) __hb_font_get_glyph_contour_point_for_origin((font), (glyph), (point_index), (direction), (x), (y))

void __hb_font_glyph_to_string(hb_font_t * font, hb_codepoint_t glyph, char * s, unsigned int size) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_glyph_to_string(font, glyph, s, size) __hb_font_glyph_to_string((font), (glyph), (s), (size))

hb_bool_t __hb_font_glyph_from_string(hb_font_t * font, const char * s, int len, hb_codepoint_t * glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_glyph_from_string(font, s, len, glyph) __hb_font_glyph_from_string((font), (s), (len), (glyph))

hb_font_t * __hb_font_create(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_create(face) __hb_font_create((face))

hb_font_t * __hb_font_create_sub_font(hb_font_t * parent) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_create_sub_font(parent) __hb_font_create_sub_font((parent))

hb_font_t * __hb_font_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_empty() __hb_font_get_empty()

hb_font_t * __hb_font_reference(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_reference(font) __hb_font_reference((font))

void __hb_font_destroy(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_destroy(font) __hb_font_destroy((font))

hb_bool_t __hb_font_set_user_data(hb_font_t * font, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_user_data(font, key, data, destroy, replace) __hb_font_set_user_data((font), (key), (data), (destroy), (replace))

void * __hb_font_get_user_data(hb_font_t * font, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_user_data(font, key) __hb_font_get_user_data((font), (key))

void __hb_font_make_immutable(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_make_immutable(font) __hb_font_make_immutable((font))

hb_bool_t __hb_font_is_immutable(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_is_immutable(font) __hb_font_is_immutable((font))

void __hb_font_set_parent(hb_font_t * font, hb_font_t * parent) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_parent(font, parent) __hb_font_set_parent((font), (parent))

hb_font_t * __hb_font_get_parent(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_parent(font) __hb_font_get_parent((font))

hb_face_t * __hb_font_get_face(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_face(font) __hb_font_get_face((font))

void __hb_font_set_funcs(hb_font_t * font, hb_font_funcs_t * klass, void * font_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_funcs(font, klass, font_data, destroy) __hb_font_set_funcs((font), (klass), (font_data), (destroy))

void __hb_font_set_funcs_data(hb_font_t * font, void * font_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_funcs_data(font, font_data, destroy) __hb_font_set_funcs_data((font), (font_data), (destroy))

void __hb_font_set_scale(hb_font_t * font, int x_scale, int y_scale) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_scale(font, x_scale, y_scale) __hb_font_set_scale((font), (x_scale), (y_scale))

void __hb_font_get_scale(hb_font_t * font, int * x_scale, int * y_scale) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_scale(font, x_scale, y_scale) __hb_font_get_scale((font), (x_scale), (y_scale))

void __hb_font_set_ppem(hb_font_t * font, unsigned int x_ppem, unsigned int y_ppem) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_set_ppem(font, x_ppem, y_ppem) __hb_font_set_ppem((font), (x_ppem), (y_ppem))

void __hb_font_get_ppem(hb_font_t * font, unsigned int * x_ppem, unsigned int * y_ppem) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_ppem(font, x_ppem, y_ppem) __hb_font_get_ppem((font), (x_ppem), (y_ppem))

hb_set_t * __hb_set_create() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_create() __hb_set_create()

hb_set_t * __hb_set_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_get_empty() __hb_set_get_empty()

hb_set_t * __hb_set_reference(hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_reference(set) __hb_set_reference((set))

void __hb_set_destroy(hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_destroy(set) __hb_set_destroy((set))

hb_bool_t __hb_set_set_user_data(hb_set_t * set, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_set_user_data(set, key, data, destroy, replace) __hb_set_set_user_data((set), (key), (data), (destroy), (replace))

void * __hb_set_get_user_data(hb_set_t * set, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_get_user_data(set, key) __hb_set_get_user_data((set), (key))

hb_bool_t __hb_set_allocation_successful(const hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_allocation_successful(set) __hb_set_allocation_successful((set))

void __hb_set_clear(hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_clear(set) __hb_set_clear((set))

hb_bool_t __hb_set_is_empty(const hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_is_empty(set) __hb_set_is_empty((set))

hb_bool_t __hb_set_has(const hb_set_t * set, hb_codepoint_t codepoint) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1000(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_has(set, codepoint) __hb_set_has((set), (codepoint))

void __hb_set_add(hb_set_t * set, hb_codepoint_t codepoint) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1006(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_add(set, codepoint) __hb_set_add((set), (codepoint))

void __hb_set_add_range(hb_set_t * set, hb_codepoint_t first, hb_codepoint_t last) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1012(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_add_range(set, first, last) __hb_set_add_range((set), (first), (last))

void __hb_set_del(hb_set_t * set, hb_codepoint_t codepoint) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1018(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_del(set, codepoint) __hb_set_del((set), (codepoint))

void __hb_set_del_range(hb_set_t * set, hb_codepoint_t first, hb_codepoint_t last) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1024(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_del_range(set, first, last) __hb_set_del_range((set), (first), (last))

hb_bool_t __hb_set_is_equal(const hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_is_equal(set, other) __hb_set_is_equal((set), (other))

void __hb_set_set(hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_set(set, other) __hb_set_set((set), (other))

void __hb_set_union(hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_union(set, other) __hb_set_union((set), (other))

void __hb_set_intersect(hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1048(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_intersect(set, other) __hb_set_intersect((set), (other))

void __hb_set_subtract(hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1054(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_subtract(set, other) __hb_set_subtract((set), (other))

void __hb_set_symmetric_difference(hb_set_t * set, const hb_set_t * other) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_symmetric_difference(set, other) __hb_set_symmetric_difference((set), (other))

void __hb_set_invert(hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_invert(set) __hb_set_invert((set))

unsigned int __hb_set_get_population(const hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_get_population(set) __hb_set_get_population((set))

hb_codepoint_t __hb_set_get_min(const hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_get_min(set) __hb_set_get_min((set))

hb_codepoint_t __hb_set_get_max(const hb_set_t * set) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_get_max(set) __hb_set_get_max((set))

hb_bool_t __hb_set_next(const hb_set_t * set, hb_codepoint_t * codepoint) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_next(set, codepoint) __hb_set_next((set), (codepoint))

hb_bool_t __hb_set_next_range(const hb_set_t * set, hb_codepoint_t * first, hb_codepoint_t * last) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_set_next_range(set, first, last) __hb_set_next_range((set), (first), (last))

hb_shape_plan_t * __hb_shape_plan_create(hb_face_t * face, const hb_segment_properties_t * props, const hb_feature_t * user_features, unsigned int num_user_features, const char * const * shaper_list) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_create(face, props, user_features, num_user_features, shaper_list) __hb_shape_plan_create((face), (props), (user_features), (num_user_features), (shaper_list))

hb_shape_plan_t * __hb_shape_plan_create_cached(hb_face_t * face, const hb_segment_properties_t * props, const hb_feature_t * user_features, unsigned int num_user_features, const char * const * shaper_list) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_create_cached(face, props, user_features, num_user_features, shaper_list) __hb_shape_plan_create_cached((face), (props), (user_features), (num_user_features), (shaper_list))

hb_shape_plan_t * __hb_shape_plan_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_get_empty() __hb_shape_plan_get_empty()

hb_shape_plan_t * __hb_shape_plan_reference(hb_shape_plan_t * shape_plan) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1120(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_reference(shape_plan) __hb_shape_plan_reference((shape_plan))

void __hb_shape_plan_destroy(hb_shape_plan_t * shape_plan) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1126(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_destroy(shape_plan) __hb_shape_plan_destroy((shape_plan))

hb_bool_t __hb_shape_plan_set_user_data(hb_shape_plan_t * shape_plan, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1132(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_set_user_data(shape_plan, key, data, destroy, replace) __hb_shape_plan_set_user_data((shape_plan), (key), (data), (destroy), (replace))

void * __hb_shape_plan_get_user_data(hb_shape_plan_t * shape_plan, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1138(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_get_user_data(shape_plan, key) __hb_shape_plan_get_user_data((shape_plan), (key))

hb_bool_t __hb_shape_plan_execute(hb_shape_plan_t * shape_plan, hb_font_t * font, hb_buffer_t * buffer, const hb_feature_t * features, unsigned int num_features) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1144(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_execute(shape_plan, font, buffer, features, num_features) __hb_shape_plan_execute((shape_plan), (font), (buffer), (features), (num_features))

const char * __hb_shape_plan_get_shaper(hb_shape_plan_t * shape_plan) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1150(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_plan_get_shaper(shape_plan) __hb_shape_plan_get_shaper((shape_plan))

hb_bool_t __hb_feature_from_string(const char * str, int len, hb_feature_t * feature) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1156(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_feature_from_string(str, len, feature) __hb_feature_from_string((str), (len), (feature))

void __hb_feature_to_string(hb_feature_t * feature, char * buf, unsigned int size) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1162(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_feature_to_string(feature, buf, size) __hb_feature_to_string((feature), (buf), (size))

void __hb_shape(hb_font_t * font, hb_buffer_t * buffer, const hb_feature_t * features, unsigned int num_features) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1168(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape(font, buffer, features, num_features) __hb_shape((font), (buffer), (features), (num_features))

hb_bool_t __hb_shape_full(hb_font_t * font, hb_buffer_t * buffer, const hb_feature_t * features, unsigned int num_features, const char * const * shaper_list) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1174(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_full(font, buffer, features, num_features, shaper_list) __hb_shape_full((font), (buffer), (features), (num_features), (shaper_list))

const char ** __hb_shape_list_shapers() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1180(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_shape_list_shapers() __hb_shape_list_shapers()

hb_unicode_funcs_t * __hb_unicode_funcs_get_default() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1186(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_get_default() __hb_unicode_funcs_get_default()

hb_unicode_funcs_t * __hb_unicode_funcs_create(hb_unicode_funcs_t * parent) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1192(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_create(parent) __hb_unicode_funcs_create((parent))

hb_unicode_funcs_t * __hb_unicode_funcs_get_empty() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1198(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_get_empty() __hb_unicode_funcs_get_empty()

hb_unicode_funcs_t * __hb_unicode_funcs_reference(hb_unicode_funcs_t * ufuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1204(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_reference(ufuncs) __hb_unicode_funcs_reference((ufuncs))

void __hb_unicode_funcs_destroy(hb_unicode_funcs_t * ufuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1210(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_destroy(ufuncs) __hb_unicode_funcs_destroy((ufuncs))

hb_bool_t __hb_unicode_funcs_set_user_data(hb_unicode_funcs_t * ufuncs, hb_user_data_key_t * key, void * data, hb_destroy_func_t destroy, hb_bool_t replace) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1216(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_user_data(ufuncs, key, data, destroy, replace) __hb_unicode_funcs_set_user_data((ufuncs), (key), (data), (destroy), (replace))

void * __hb_unicode_funcs_get_user_data(hb_unicode_funcs_t * ufuncs, hb_user_data_key_t * key) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1222(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_get_user_data(ufuncs, key) __hb_unicode_funcs_get_user_data((ufuncs), (key))

void __hb_unicode_funcs_make_immutable(hb_unicode_funcs_t * ufuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1228(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_make_immutable(ufuncs) __hb_unicode_funcs_make_immutable((ufuncs))

hb_bool_t __hb_unicode_funcs_is_immutable(hb_unicode_funcs_t * ufuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1234(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_is_immutable(ufuncs) __hb_unicode_funcs_is_immutable((ufuncs))

hb_unicode_funcs_t * __hb_unicode_funcs_get_parent(hb_unicode_funcs_t * ufuncs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1240(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_get_parent(ufuncs) __hb_unicode_funcs_get_parent((ufuncs))

void __hb_unicode_funcs_set_combining_class_func(hb_unicode_funcs_t * ufuncs, hb_unicode_combining_class_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1246(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_combining_class_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_combining_class_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_eastasian_width_func(hb_unicode_funcs_t * ufuncs, hb_unicode_eastasian_width_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1252(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_eastasian_width_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_eastasian_width_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_general_category_func(hb_unicode_funcs_t * ufuncs, hb_unicode_general_category_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1258(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_general_category_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_general_category_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_mirroring_func(hb_unicode_funcs_t * ufuncs, hb_unicode_mirroring_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1264(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_mirroring_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_mirroring_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_script_func(hb_unicode_funcs_t * ufuncs, hb_unicode_script_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1270(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_script_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_script_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_compose_func(hb_unicode_funcs_t * ufuncs, hb_unicode_compose_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1276(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_compose_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_compose_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_decompose_func(hb_unicode_funcs_t * ufuncs, hb_unicode_decompose_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1282(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_decompose_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_decompose_func((ufuncs), (func), (user_data), (destroy))

void __hb_unicode_funcs_set_decompose_compatibility_func(hb_unicode_funcs_t * ufuncs, hb_unicode_decompose_compatibility_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1288(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_funcs_set_decompose_compatibility_func(ufuncs, func, user_data, destroy) __hb_unicode_funcs_set_decompose_compatibility_func((ufuncs), (func), (user_data), (destroy))

hb_unicode_combining_class_t __hb_unicode_combining_class(hb_unicode_funcs_t * ufuncs, hb_codepoint_t unicode) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1294(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_combining_class(ufuncs, unicode) __hb_unicode_combining_class((ufuncs), (unicode))

unsigned int __hb_unicode_eastasian_width(hb_unicode_funcs_t * ufuncs, hb_codepoint_t unicode) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1300(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_eastasian_width(ufuncs, unicode) __hb_unicode_eastasian_width((ufuncs), (unicode))

hb_unicode_general_category_t __hb_unicode_general_category(hb_unicode_funcs_t * ufuncs, hb_codepoint_t unicode) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1306(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_general_category(ufuncs, unicode) __hb_unicode_general_category((ufuncs), (unicode))

hb_codepoint_t __hb_unicode_mirroring(hb_unicode_funcs_t * ufuncs, hb_codepoint_t unicode) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1312(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_mirroring(ufuncs, unicode) __hb_unicode_mirroring((ufuncs), (unicode))

hb_script_t __hb_unicode_script(hb_unicode_funcs_t * ufuncs, hb_codepoint_t unicode) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1318(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_script(ufuncs, unicode) __hb_unicode_script((ufuncs), (unicode))

hb_bool_t __hb_unicode_compose(hb_unicode_funcs_t * ufuncs, hb_codepoint_t a, hb_codepoint_t b, hb_codepoint_t * ab) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1324(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_compose(ufuncs, a, b, ab) __hb_unicode_compose((ufuncs), (a), (b), (ab))

hb_bool_t __hb_unicode_decompose(hb_unicode_funcs_t * ufuncs, hb_codepoint_t ab, hb_codepoint_t * a, hb_codepoint_t * b) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1330(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_decompose(ufuncs, ab, a, b) __hb_unicode_decompose((ufuncs), (ab), (a), (b))

unsigned int __hb_unicode_decompose_compatibility(hb_unicode_funcs_t * ufuncs, hb_codepoint_t u, hb_codepoint_t * decomposed) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1336(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_unicode_decompose_compatibility(ufuncs, u, decomposed) __hb_unicode_decompose_compatibility((ufuncs), (u), (decomposed))

void __hb_version(unsigned int * major, unsigned int * minor, unsigned int * micro) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1342(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_version(major, minor, micro) __hb_version((major), (minor), (micro))

const char * __hb_version_string() =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1348(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_version_string() __hb_version_string()

hb_bool_t __hb_version_atleast(unsigned int major, unsigned int minor, unsigned int micro) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1354(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_version_atleast(major, minor, micro) __hb_version_atleast((major), (minor), (micro))

hb_face_t * __hb_ft_face_create(void * ft_face, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1360(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_face_create(ft_face, destroy) __hb_ft_face_create((ft_face), (destroy))

hb_face_t * __hb_ft_face_create_cached(void * ft_face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1366(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_face_create_cached(ft_face) __hb_ft_face_create_cached((ft_face))

hb_face_t * __hb_ft_face_create_referenced(void * ft_face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1372(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_face_create_referenced(ft_face) __hb_ft_face_create_referenced((ft_face))

hb_font_t * __hb_ft_font_create(void * ft_face, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1378(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_create(ft_face, destroy) __hb_ft_font_create((ft_face), (destroy))

hb_font_t * __hb_ft_font_create_referenced(void * ft_face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1384(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_create_referenced(ft_face) __hb_ft_font_create_referenced((ft_face))

void * __hb_ft_font_get_face(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1390(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_get_face(font) __hb_ft_font_get_face((font))

void __hb_ft_font_set_load_flags(hb_font_t * font, int load_flags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1396(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_set_load_flags(font, load_flags) __hb_ft_font_set_load_flags((font), (load_flags))

int __hb_ft_font_get_load_flags(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1402(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_get_load_flags(font) __hb_ft_font_get_load_flags((font))

void __hb_ft_font_set_funcs(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1408(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ft_font_set_funcs(font) __hb_ft_font_set_funcs((font))

void __hb_ot_font_set_funcs(hb_font_t * font) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1414(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_font_set_funcs(font) __hb_ot_font_set_funcs((font))

hb_bool_t __hb_ot_layout_has_glyph_classes(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1420(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_has_glyph_classes(face) __hb_ot_layout_has_glyph_classes((face))

hb_ot_layout_glyph_class_t __hb_ot_layout_get_glyph_class(hb_face_t * face, hb_codepoint_t glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1426(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_get_glyph_class(face, glyph) __hb_ot_layout_get_glyph_class((face), (glyph))

void __hb_ot_layout_get_glyphs_in_class(hb_face_t * face, hb_ot_layout_glyph_class_t klass, hb_set_t * glyphs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1432(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_get_glyphs_in_class(face, klass, glyphs) __hb_ot_layout_get_glyphs_in_class((face), (klass), (glyphs))

unsigned int __hb_ot_layout_get_attach_points(hb_face_t * face, hb_codepoint_t glyph, unsigned int start_offset, unsigned int * point_count, unsigned int * point_array) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1438(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_get_attach_points(face, glyph, start_offset, point_count, point_array) __hb_ot_layout_get_attach_points((face), (glyph), (start_offset), (point_count), (point_array))

unsigned int __hb_ot_layout_get_ligature_carets(hb_font_t * font, hb_direction_t direction, hb_codepoint_t glyph, unsigned int start_offset, unsigned int * caret_count, hb_position_t * caret_array) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1444(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_get_ligature_carets(font, direction, glyph, start_offset, caret_count, caret_array) __hb_ot_layout_get_ligature_carets((font), (direction), (glyph), (start_offset), (caret_count), (caret_array))

unsigned int __hb_ot_layout_table_get_script_tags(hb_face_t * face, hb_tag_t table_tag, unsigned int start_offset, unsigned int * script_count, hb_tag_t * script_tags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1450(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_table_get_script_tags(face, table_tag, start_offset, script_count, script_tags) __hb_ot_layout_table_get_script_tags((face), (table_tag), (start_offset), (script_count), (script_tags))

hb_bool_t __hb_ot_layout_table_find_script(hb_face_t * face, hb_tag_t table_tag, hb_tag_t script_tag, unsigned int * script_index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1456(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_table_find_script(face, table_tag, script_tag, script_index) __hb_ot_layout_table_find_script((face), (table_tag), (script_tag), (script_index))

hb_bool_t __hb_ot_layout_table_choose_script(hb_face_t * face, hb_tag_t table_tag, const hb_tag_t * script_tags, unsigned int * script_index, hb_tag_t * chosen_script) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1462(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_table_choose_script(face, table_tag, script_tags, script_index, chosen_script) __hb_ot_layout_table_choose_script((face), (table_tag), (script_tags), (script_index), (chosen_script))

unsigned int __hb_ot_layout_table_get_feature_tags(hb_face_t * face, hb_tag_t table_tag, unsigned int start_offset, unsigned int * feature_count, hb_tag_t * feature_tags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1468(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_table_get_feature_tags(face, table_tag, start_offset, feature_count, feature_tags) __hb_ot_layout_table_get_feature_tags((face), (table_tag), (start_offset), (feature_count), (feature_tags))

unsigned int __hb_ot_layout_script_get_language_tags(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int start_offset, unsigned int * language_count, hb_tag_t * language_tags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1474(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_script_get_language_tags(face, table_tag, script_index, start_offset, language_count, language_tags) __hb_ot_layout_script_get_language_tags((face), (table_tag), (script_index), (start_offset), (language_count), (language_tags))

hb_bool_t __hb_ot_layout_script_find_language(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, hb_tag_t language_tag, unsigned int * language_index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1480(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_script_find_language(face, table_tag, script_index, language_tag, language_index) __hb_ot_layout_script_find_language((face), (table_tag), (script_index), (language_tag), (language_index))

hb_bool_t __hb_ot_layout_language_get_required_feature_index(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int language_index, unsigned int * feature_index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1486(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_language_get_required_feature_index(face, table_tag, script_index, language_index, feature_index) __hb_ot_layout_language_get_required_feature_index((face), (table_tag), (script_index), (language_index), (feature_index))

hb_bool_t __hb_ot_layout_language_get_required_feature(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int language_index, unsigned int * feature_index, hb_tag_t * feature_tag) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1492(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_language_get_required_feature(face, table_tag, script_index, language_index, feature_index, feature_tag) __hb_ot_layout_language_get_required_feature((face), (table_tag), (script_index), (language_index), (feature_index), (feature_tag))

unsigned int __hb_ot_layout_language_get_feature_indexes(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int language_index, unsigned int start_offset, unsigned int * feature_count, unsigned int * feature_indexes) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1498(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_language_get_feature_indexes(face, table_tag, script_index, language_index, start_offset, feature_count, feature_indexes) __hb_ot_layout_language_get_feature_indexes((face), (table_tag), (script_index), (language_index), (start_offset), (feature_count), (feature_indexes))

unsigned int __hb_ot_layout_language_get_feature_tags(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int language_index, unsigned int start_offset, unsigned int * feature_count, hb_tag_t * feature_tags) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1504(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_language_get_feature_tags(face, table_tag, script_index, language_index, start_offset, feature_count, feature_tags) __hb_ot_layout_language_get_feature_tags((face), (table_tag), (script_index), (language_index), (start_offset), (feature_count), (feature_tags))

hb_bool_t __hb_ot_layout_language_find_feature(hb_face_t * face, hb_tag_t table_tag, unsigned int script_index, unsigned int language_index, hb_tag_t feature_tag, unsigned int * feature_index) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1510(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_language_find_feature(face, table_tag, script_index, language_index, feature_tag, feature_index) __hb_ot_layout_language_find_feature((face), (table_tag), (script_index), (language_index), (feature_tag), (feature_index))

unsigned int __hb_ot_layout_feature_get_lookups(hb_face_t * face, hb_tag_t table_tag, unsigned int feature_index, unsigned int start_offset, unsigned int * lookup_count, unsigned int * lookup_indexes) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1516(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_feature_get_lookups(face, table_tag, feature_index, start_offset, lookup_count, lookup_indexes) __hb_ot_layout_feature_get_lookups((face), (table_tag), (feature_index), (start_offset), (lookup_count), (lookup_indexes))

unsigned int __hb_ot_layout_table_get_lookup_count(hb_face_t * face, hb_tag_t table_tag) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1522(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_table_get_lookup_count(face, table_tag) __hb_ot_layout_table_get_lookup_count((face), (table_tag))

void __hb_ot_layout_collect_lookups(hb_face_t * face, hb_tag_t table_tag, const hb_tag_t * scripts, const hb_tag_t * languages, const hb_tag_t * features, hb_set_t * lookup_indexes) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1528(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_collect_lookups(face, table_tag, scripts, languages, features, lookup_indexes) __hb_ot_layout_collect_lookups((face), (table_tag), (scripts), (languages), (features), (lookup_indexes))

void __hb_ot_layout_lookup_collect_glyphs(hb_face_t * face, hb_tag_t table_tag, unsigned int lookup_index, hb_set_t * glyphs_before, hb_set_t * glyphs_input, hb_set_t * glyphs_after, hb_set_t * glyphs_output) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1534(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_lookup_collect_glyphs(face, table_tag, lookup_index, glyphs_before, glyphs_input, glyphs_after, glyphs_output) __hb_ot_layout_lookup_collect_glyphs((face), (table_tag), (lookup_index), (glyphs_before), (glyphs_input), (glyphs_after), (glyphs_output))

hb_bool_t __hb_ot_layout_has_substitution(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1540(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_has_substitution(face) __hb_ot_layout_has_substitution((face))

hb_bool_t __hb_ot_layout_lookup_would_substitute(hb_face_t * face, unsigned int lookup_index, const hb_codepoint_t * glyphs, unsigned int glyphs_length, hb_bool_t zero_context) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1546(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_lookup_would_substitute(face, lookup_index, glyphs, glyphs_length, zero_context) __hb_ot_layout_lookup_would_substitute((face), (lookup_index), (glyphs), (glyphs_length), (zero_context))

void __hb_ot_layout_lookup_substitute_closure(hb_face_t * face, unsigned int lookup_index, hb_set_t * glyphs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1552(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_lookup_substitute_closure(face, lookup_index, glyphs) __hb_ot_layout_lookup_substitute_closure((face), (lookup_index), (glyphs))

hb_bool_t __hb_ot_layout_has_positioning(hb_face_t * face) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1558(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_has_positioning(face) __hb_ot_layout_has_positioning((face))

hb_bool_t __hb_ot_layout_get_size_params(hb_face_t * face, unsigned int * design_size, unsigned int * subfamily_id, unsigned int * subfamily_name_id, unsigned int * range_start, unsigned int * range_end) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1564(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_layout_get_size_params(face, design_size, subfamily_id, subfamily_name_id, range_start, range_end) __hb_ot_layout_get_size_params((face), (design_size), (subfamily_id), (subfamily_name_id), (range_start), (range_end))

void __hb_ot_shape_glyphs_closure(hb_font_t * font, hb_buffer_t * buffer, const hb_feature_t * features, unsigned int num_features, hb_set_t * glyphs) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1570(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_shape_glyphs_closure(font, buffer, features, num_features, glyphs) __hb_ot_shape_glyphs_closure((font), (buffer), (features), (num_features), (glyphs))

void __hb_ot_shape_plan_collect_lookups(hb_shape_plan_t * shape_plan, hb_tag_t table_tag, hb_set_t * lookup_indexes) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1576(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_shape_plan_collect_lookups(shape_plan, table_tag, lookup_indexes) __hb_ot_shape_plan_collect_lookups((shape_plan), (table_tag), (lookup_indexes))

void __hb_ot_tags_from_script(hb_script_t script, hb_tag_t * script_tag_1, hb_tag_t * script_tag_2) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1582(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_tags_from_script(script, script_tag_1, script_tag_2) __hb_ot_tags_from_script((script), (script_tag_1), (script_tag_2))

hb_script_t __hb_ot_tag_to_script(hb_tag_t d0arg) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1588(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_tag_to_script(d0arg) __hb_ot_tag_to_script((d0arg))

hb_tag_t __hb_ot_tag_from_language(hb_language_t language) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1594(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_tag_from_language(language) __hb_ot_tag_from_language((language))

hb_language_t __hb_ot_tag_to_language(hb_tag_t d0arg) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1600(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_ot_tag_to_language(d0arg) __hb_ot_tag_to_language((d0arg))

void __hb_font_funcs_set_nominal_glyph_func(hb_font_funcs_t * ffuncs, hb_font_get_nominal_glyph_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1606(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_nominal_glyph_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_nominal_glyph_func((ffuncs), (func), (user_data), (destroy))

void __hb_font_funcs_set_variation_glyph_func(hb_font_funcs_t * ffuncs, hb_font_get_variation_glyph_func_t func, void * user_data, hb_destroy_func_t destroy) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1612(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_funcs_set_variation_glyph_func(ffuncs, func, user_data, destroy) __hb_font_funcs_set_variation_glyph_func((ffuncs), (func), (user_data), (destroy))

hb_bool_t __hb_font_get_nominal_glyph(hb_font_t * font, hb_codepoint_t unicode, hb_codepoint_t * glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1618(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_nominal_glyph(font, unicode, glyph) __hb_font_get_nominal_glyph((font), (unicode), (glyph))

hb_bool_t __hb_font_get_variation_glyph(hb_font_t * font, hb_codepoint_t unicode, hb_codepoint_t variation_selector, hb_codepoint_t * glyph) =
	"\tlis\t11,HarfbuzzBase@ha\n"
	"\tlwz\t12,HarfbuzzBase@l(11)\n"
	"\tlwz\t0,-1624(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define hb_font_get_variation_glyph(font, unicode, variation_selector, glyph) __hb_font_get_variation_glyph((font), (unicode), (variation_selector), (glyph))

#endif /*  _VBCCINLINE_HARFBUZZ_H  */

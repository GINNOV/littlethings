#ifndef _VBCCINLINE_PNG_H
#define _VBCCINLINE_PNG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __png_build_grayscale_palette(int bit_depth, png_colorp palette) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_build_grayscale_palette(bit_depth, palette) __png_build_grayscale_palette((bit_depth), (palette))

int __png_check_sig(png_bytep sig, int num) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_check_sig(sig, num) __png_check_sig((sig), (num))

void __png_chunk_error(png_structp png_ptr, png_const_charp error_message) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_chunk_error(png_ptr, error_message) __png_chunk_error((png_ptr), (error_message))

void __png_chunk_warning(png_structp png_ptr, png_const_charp warning_message) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_chunk_warning(png_ptr, warning_message) __png_chunk_warning((png_ptr), (warning_message))

void __png_convert_from_struct_tm(png_timep ptime, struct tm ttime) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_convert_from_struct_tm(ptime, ttime) __png_convert_from_struct_tm((ptime), (ttime))

void __png_convert_from_time_t(png_timep ptime, time_t ttime) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_convert_from_time_t(ptime, ttime) __png_convert_from_time_t((ptime), (ttime))

png_infop __png_create_info_struct(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_create_info_struct(png_ptr) __png_create_info_struct((png_ptr))

png_structp __png_create_read_struct(png_const_charp user_png_ver, png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_create_read_struct(user_png_ver, error_ptr, error_fn, warn_fn) __png_create_read_struct((user_png_ver), (error_ptr), (error_fn), (warn_fn))

png_structp __png_create_write_struct(png_const_charp user_png_ver, png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_create_write_struct(user_png_ver, error_ptr, error_fn, warn_fn) __png_create_write_struct((user_png_ver), (error_ptr), (error_fn), (warn_fn))

void __png_data_freer(png_structp png_ptr, png_infop info_ptr, int freer, png_uint_32 mask) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_data_freer(png_ptr, info_ptr, freer, mask) __png_data_freer((png_ptr), (info_ptr), (freer), (mask))

void __png_destroy_info_struct(png_structp png_ptr, png_infopp info_ptr_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_destroy_info_struct(png_ptr, info_ptr_ptr) __png_destroy_info_struct((png_ptr), (info_ptr_ptr))

void __png_destroy_read_struct(png_structpp png_ptr_ptr, png_infopp info_ptr_ptr, png_infopp end_info_ptr_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_destroy_read_struct(png_ptr_ptr, info_ptr_ptr, end_info_ptr_ptr) __png_destroy_read_struct((png_ptr_ptr), (info_ptr_ptr), (end_info_ptr_ptr))

void __png_destroy_write_struct(png_structpp png_ptr_ptr, png_infopp info_ptr_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_destroy_write_struct(png_ptr_ptr, info_ptr_ptr) __png_destroy_write_struct((png_ptr_ptr), (info_ptr_ptr))

void __png_error(png_structp png_ptr, png_const_charp error_message) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_error(png_ptr, error_message) __png_error((png_ptr), (error_message))

void __png_free(png_structp png_ptr, png_voidp ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_free(png_ptr, ptr) __png_free((png_ptr), (ptr))

void __png_free_data(png_structp png_ptr, png_infop info_ptr, png_uint_32 free_me, int num) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_free_data(png_ptr, info_ptr, free_me, num) __png_free_data((png_ptr), (info_ptr), (free_me), (num))

png_uint_32 __png_get_IHDR(png_structp png_ptr, png_infop info_ptr, png_uint_32 * width, png_uint_32 * height, int * bit_depth, int * color_type, int * interlace_method, int * compression_method, int * filter_method) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, interlace_method, compression_method, filter_method) __png_get_IHDR((png_ptr), (info_ptr), (width), (height), (bit_depth), (color_type), (interlace_method), (compression_method), (filter_method))

png_uint_32 __png_get_PLTE(png_structp png_ptr, png_infop info_ptr, png_colorp * palette, int * num_palette) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_PLTE(png_ptr, info_ptr, palette, num_palette) __png_get_PLTE((png_ptr), (info_ptr), (palette), (num_palette))

png_uint_32 __png_get_bKGD(png_structp png_ptr, png_infop info_ptr, png_color_16p * background) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_bKGD(png_ptr, info_ptr, background) __png_get_bKGD((png_ptr), (info_ptr), (background))

png_byte __png_get_bit_depth(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_bit_depth(png_ptr, info_ptr) __png_get_bit_depth((png_ptr), (info_ptr))

png_uint_32 __png_get_cHRM(png_structp png_ptr, png_infop info_ptr, double * white_x, double * white_y, double * red_x, double * red_y, double * green_x, double * green_y, double * blue_x, double * blue_y) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_cHRM(png_ptr, info_ptr, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) __png_get_cHRM((png_ptr), (info_ptr), (white_x), (white_y), (red_x), (red_y), (green_x), (green_y), (blue_x), (blue_y))

png_uint_32 __png_get_cHRM_fixed(png_structp png_ptr, png_infop info_ptr, png_fixed_point * int_white_x, png_fixed_point * int_white_y, png_fixed_point * int_red_x, png_fixed_point * int_red_y, png_fixed_point * int_green_x, png_fixed_point * int_green_y, png_fixed_point * int_blue_x, png_fixed_point * int_blue_y) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_cHRM_fixed(png_ptr, info_ptr, int_white_x, int_white_y, int_red_x, int_red_y, int_green_x, int_green_y, int_blue_x, int_blue_y) __png_get_cHRM_fixed((png_ptr), (info_ptr), (int_white_x), (int_white_y), (int_red_x), (int_red_y), (int_green_x), (int_green_y), (int_blue_x), (int_blue_y))

png_byte __png_get_channels(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_channels(png_ptr, info_ptr) __png_get_channels((png_ptr), (info_ptr))

png_byte __png_get_color_type(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_color_type(png_ptr, info_ptr) __png_get_color_type((png_ptr), (info_ptr))

png_uint_32 __png_get_compression_buffer_size(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_compression_buffer_size(png_ptr) __png_get_compression_buffer_size((png_ptr))

png_byte __png_get_compression_type(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_compression_type(png_ptr, info_ptr) __png_get_compression_type((png_ptr), (info_ptr))

png_charp __png_get_copyright(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_copyright(png_ptr) __png_get_copyright((png_ptr))

png_voidp __png_get_error_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_error_ptr(png_ptr) __png_get_error_ptr((png_ptr))

png_byte __png_get_filter_type(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_filter_type(png_ptr, info_ptr) __png_get_filter_type((png_ptr), (info_ptr))

png_uint_32 __png_get_gAMA(png_structp png_ptr, png_infop info_ptr, double * file_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_gAMA(png_ptr, info_ptr, file_gamma) __png_get_gAMA((png_ptr), (info_ptr), (file_gamma))

png_uint_32 __png_get_gAMA_fixed(png_structp png_ptr, png_infop info_ptr, png_fixed_point * int_file_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_gAMA_fixed(png_ptr, info_ptr, int_file_gamma) __png_get_gAMA_fixed((png_ptr), (info_ptr), (int_file_gamma))

png_uint_32 __png_get_hIST(png_structp png_ptr, png_infop info_ptr, png_uint_16p * hist) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_hIST(png_ptr, info_ptr, hist) __png_get_hIST((png_ptr), (info_ptr), (hist))

png_charp __png_get_header_ver(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_header_ver(png_ptr) __png_get_header_ver((png_ptr))

png_charp __png_get_header_version(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_header_version(png_ptr) __png_get_header_version((png_ptr))

png_uint_32 __png_get_iCCP(png_structp png_ptr, png_infop info_ptr, png_charpp name, int * compression_type, png_charpp profile, png_uint_32 * proflen) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_iCCP(png_ptr, info_ptr, name, compression_type, profile, proflen) __png_get_iCCP((png_ptr), (info_ptr), (name), (compression_type), (profile), (proflen))

png_uint_32 __png_get_image_height(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_image_height(png_ptr, info_ptr) __png_get_image_height((png_ptr), (info_ptr))

png_uint_32 __png_get_image_width(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_image_width(png_ptr, info_ptr) __png_get_image_width((png_ptr), (info_ptr))

png_byte __png_get_interlace_type(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_interlace_type(png_ptr, info_ptr) __png_get_interlace_type((png_ptr), (info_ptr))

png_voidp __png_get_io_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_io_ptr(png_ptr) __png_get_io_ptr((png_ptr))

png_charp __png_get_libpng_ver(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_libpng_ver(png_ptr) __png_get_libpng_ver((png_ptr))

png_uint_32 __png_get_oFFs(png_structp png_ptr, png_infop info_ptr, png_int_32 * offset_x, png_int_32 * offset_y, int * unit_type) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_oFFs(png_ptr, info_ptr, offset_x, offset_y, unit_type) __png_get_oFFs((png_ptr), (info_ptr), (offset_x), (offset_y), (unit_type))

png_uint_32 __png_get_pCAL(png_structp png_ptr, png_infop info_ptr, png_charp * purpose, png_int_32 * X0, png_int_32 * X1, int * type, int * nparams, png_charp * units, png_charpp * params) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_pCAL(png_ptr, info_ptr, purpose, X0, X1, type, nparams, units, params) __png_get_pCAL((png_ptr), (info_ptr), (purpose), (X0), (X1), (type), (nparams), (units), (params))

png_uint_32 __png_get_pHYs(png_structp png_ptr, png_infop info_ptr, png_uint_32 * res_x, png_uint_32 * res_y, int * unit_type) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_pHYs(png_ptr, info_ptr, res_x, res_y, unit_type) __png_get_pHYs((png_ptr), (info_ptr), (res_x), (res_y), (unit_type))

float __png_get_pixel_aspect_ratio(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_pixel_aspect_ratio(png_ptr, info_ptr) __png_get_pixel_aspect_ratio((png_ptr), (info_ptr))

png_uint_32 __png_get_pixels_per_meter(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_pixels_per_meter(png_ptr, info_ptr) __png_get_pixels_per_meter((png_ptr), (info_ptr))

png_voidp __png_get_progressive_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_progressive_ptr(png_ptr) __png_get_progressive_ptr((png_ptr))

png_byte __png_get_rgb_to_gray_status(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_rgb_to_gray_status(png_ptr) __png_get_rgb_to_gray_status((png_ptr))

png_uint_32 __png_get_rowbytes(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_rowbytes(png_ptr, info_ptr) __png_get_rowbytes((png_ptr), (info_ptr))

png_bytepp __png_get_rows(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_rows(png_ptr, info_ptr) __png_get_rows((png_ptr), (info_ptr))

png_uint_32 __png_get_sBIT(png_structp png_ptr, png_infop info_ptr, png_color_8p * sig_bit) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_sBIT(png_ptr, info_ptr, sig_bit) __png_get_sBIT((png_ptr), (info_ptr), (sig_bit))

png_uint_32 __png_get_sCAL(png_structp png_ptr, png_infop info_ptr, int * unit, double * width, double * height) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_sCAL(png_ptr, info_ptr, unit, width, height) __png_get_sCAL((png_ptr), (info_ptr), (unit), (width), (height))

png_uint_32 __png_get_sPLT(png_structp png_ptr, png_infop info_ptr, png_sPLT_tpp entries) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_sPLT(png_ptr, info_ptr, entries) __png_get_sPLT((png_ptr), (info_ptr), (entries))

png_uint_32 __png_get_sRGB(png_structp png_ptr, png_infop info_ptr, int * intent) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_sRGB(png_ptr, info_ptr, intent) __png_get_sRGB((png_ptr), (info_ptr), (intent))

png_bytep __png_get_signature(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_signature(png_ptr, info_ptr) __png_get_signature((png_ptr), (info_ptr))

png_uint_32 __png_get_tIME(png_structp png_ptr, png_infop info_ptr, png_timep * mod_time) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_tIME(png_ptr, info_ptr, mod_time) __png_get_tIME((png_ptr), (info_ptr), (mod_time))

png_uint_32 __png_get_tRNS(png_structp png_ptr, png_infop info_ptr, png_bytep * trans, int * num_trans, png_color_16p * trans_values) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_tRNS(png_ptr, info_ptr, trans, num_trans, trans_values) __png_get_tRNS((png_ptr), (info_ptr), (trans), (num_trans), (trans_values))

png_uint_32 __png_get_text(png_structp png_ptr, png_infop info_ptr, png_textp * text_ptr, int * num_text) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_text(png_ptr, info_ptr, text_ptr, num_text) __png_get_text((png_ptr), (info_ptr), (text_ptr), (num_text))

png_uint_32 __png_get_unknown_chunks(png_structp png_ptr, png_infop info_ptr, png_unknown_chunkpp entries) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_unknown_chunks(png_ptr, info_ptr, entries) __png_get_unknown_chunks((png_ptr), (info_ptr), (entries))

png_voidp __png_get_user_chunk_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_user_chunk_ptr(png_ptr) __png_get_user_chunk_ptr((png_ptr))

png_voidp __png_get_user_transform_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_user_transform_ptr(png_ptr) __png_get_user_transform_ptr((png_ptr))

png_uint_32 __png_get_valid(png_structp png_ptr, png_infop info_ptr, png_uint_32 flag) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_valid(png_ptr, info_ptr, flag) __png_get_valid((png_ptr), (info_ptr), (flag))

png_int_32 __png_get_x_offset_microns(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_x_offset_microns(png_ptr, info_ptr) __png_get_x_offset_microns((png_ptr), (info_ptr))

png_int_32 __png_get_x_offset_pixels(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_x_offset_pixels(png_ptr, info_ptr) __png_get_x_offset_pixels((png_ptr), (info_ptr))

png_uint_32 __png_get_x_pixels_per_meter(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_x_pixels_per_meter(png_ptr, info_ptr) __png_get_x_pixels_per_meter((png_ptr), (info_ptr))

png_int_32 __png_get_y_offset_microns(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_y_offset_microns(png_ptr, info_ptr) __png_get_y_offset_microns((png_ptr), (info_ptr))

png_int_32 __png_get_y_offset_pixels(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_y_offset_pixels(png_ptr, info_ptr) __png_get_y_offset_pixels((png_ptr), (info_ptr))

png_uint_32 __png_get_y_pixels_per_meter(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_y_pixels_per_meter(png_ptr, info_ptr) __png_get_y_pixels_per_meter((png_ptr), (info_ptr))

png_voidp __png_malloc(png_structp png_ptr, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_malloc(png_ptr, size) __png_malloc((png_ptr), (size))

png_voidp __png_memcpy_check(png_structp png_ptr, png_voidp s1, png_voidp s2, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_memcpy_check(png_ptr, s1, s2, size) __png_memcpy_check((png_ptr), (s1), (s2), (size))

png_voidp __png_memset_check(png_structp png_ptr, png_voidp s1, int value, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_memset_check(png_ptr, s1, value, size) __png_memset_check((png_ptr), (s1), (value), (size))

void __png_process_data(png_structp png_ptr, png_infop info_ptr, png_bytep buffer, png_size_t buffer_size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_process_data(png_ptr, info_ptr, buffer, buffer_size) __png_process_data((png_ptr), (info_ptr), (buffer), (buffer_size))

void __png_progressive_combine_row(png_structp png_ptr, png_bytep old_row, png_bytep new_row) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_progressive_combine_row(png_ptr, old_row, new_row) __png_progressive_combine_row((png_ptr), (old_row), (new_row))

void __png_read_end(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_end(png_ptr, info_ptr) __png_read_end((png_ptr), (info_ptr))

void __png_read_image(png_structp png_ptr, png_bytepp image) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_image(png_ptr, image) __png_read_image((png_ptr), (image))

void __png_read_info(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_info(png_ptr, info_ptr) __png_read_info((png_ptr), (info_ptr))

void __png_read_png(png_structp png_ptr, png_infop info_ptr, int transforms, png_voidp params) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_png(png_ptr, info_ptr, transforms, params) __png_read_png((png_ptr), (info_ptr), (transforms), (params))

void __png_read_row(png_structp png_ptr, png_bytep row, png_bytep display_row) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_row(png_ptr, row, display_row) __png_read_row((png_ptr), (row), (display_row))

void __png_read_rows(png_structp png_ptr, png_bytepp row, png_bytepp display_row, png_uint_32 num_rows) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_rows(png_ptr, row, display_row, num_rows) __png_read_rows((png_ptr), (row), (display_row), (num_rows))

void __png_read_update_info(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_read_update_info(png_ptr, info_ptr) __png_read_update_info((png_ptr), (info_ptr))

int __png_reset_zstream(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_reset_zstream(png_ptr) __png_reset_zstream((png_ptr))

void __png_set_IHDR(png_structp png_ptr, png_infop info_ptr, png_uint_32 width, png_uint_32 height, int bit_depth, int color_type, int interlace_method, int compression_method, int filter_method) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, interlace_method, compression_method, filter_method) __png_set_IHDR((png_ptr), (info_ptr), (width), (height), (bit_depth), (color_type), (interlace_method), (compression_method), (filter_method))

void __png_set_PLTE(png_structp png_ptr, png_infop info_ptr, png_colorp palette, int num_palette) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_PLTE(png_ptr, info_ptr, palette, num_palette) __png_set_PLTE((png_ptr), (info_ptr), (palette), (num_palette))

void __png_set_bKGD(png_structp png_ptr, png_infop info_ptr, png_color_16p background) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_bKGD(png_ptr, info_ptr, background) __png_set_bKGD((png_ptr), (info_ptr), (background))

void __png_set_background(png_structp png_ptr, png_color_16p background_color, int background_gamma_code, int need_expand, double background_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_background(png_ptr, background_color, background_gamma_code, need_expand, background_gamma) __png_set_background((png_ptr), (background_color), (background_gamma_code), (need_expand), (background_gamma))

void __png_set_bgr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_bgr(png_ptr) __png_set_bgr((png_ptr))

void __png_set_cHRM(png_structp png_ptr, png_infop info_ptr, double white_x, double white_y, double red_x, double red_y, double green_x, double green_y, double blue_x, double blue_y) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_cHRM(png_ptr, info_ptr, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) __png_set_cHRM((png_ptr), (info_ptr), (white_x), (white_y), (red_x), (red_y), (green_x), (green_y), (blue_x), (blue_y))

void __png_set_cHRM_fixed(png_structp png_ptr, png_infop info_ptr, png_fixed_point int_white_x, png_fixed_point int_white_y, png_fixed_point int_red_x, png_fixed_point int_red_y, png_fixed_point int_green_x, png_fixed_point int_green_y, png_fixed_point int_blue_x, png_fixed_point int_blue_y) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_cHRM_fixed(png_ptr, info_ptr, int_white_x, int_white_y, int_red_x, int_red_y, int_green_x, int_green_y, int_blue_x, int_blue_y) __png_set_cHRM_fixed((png_ptr), (info_ptr), (int_white_x), (int_white_y), (int_red_x), (int_red_y), (int_green_x), (int_green_y), (int_blue_x), (int_blue_y))

void __png_set_compression_buffer_size(png_structp png_ptr, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_buffer_size(png_ptr, size) __png_set_compression_buffer_size((png_ptr), (size))

void __png_set_compression_level(png_structp png_ptr, int level) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_level(png_ptr, level) __png_set_compression_level((png_ptr), (level))

void __png_set_compression_mem_level(png_structp png_ptr, int mem_level) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_mem_level(png_ptr, mem_level) __png_set_compression_mem_level((png_ptr), (mem_level))

void __png_set_compression_method(png_structp png_ptr, int method) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_method(png_ptr, method) __png_set_compression_method((png_ptr), (method))

void __png_set_compression_strategy(png_structp png_ptr, int strategy) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_strategy(png_ptr, strategy) __png_set_compression_strategy((png_ptr), (strategy))

void __png_set_compression_window_bits(png_structp png_ptr, int window_bits) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_compression_window_bits(png_ptr, window_bits) __png_set_compression_window_bits((png_ptr), (window_bits))

void __png_set_crc_action(png_structp png_ptr, int crit_action, int ancil_action) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_crc_action(png_ptr, crit_action, ancil_action) __png_set_crc_action((png_ptr), (crit_action), (ancil_action))

void __png_set_dither(png_structp png_ptr, png_colorp palette, int num_palette, int maximum_colors, png_uint_16p histogram, int full_dither) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_dither(png_ptr, palette, num_palette, maximum_colors, histogram, full_dither) __png_set_dither((png_ptr), (palette), (num_palette), (maximum_colors), (histogram), (full_dither))

void __png_set_error_fn(png_structp png_ptr, png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warning_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_error_fn(png_ptr, error_ptr, error_fn, warning_fn) __png_set_error_fn((png_ptr), (error_ptr), (error_fn), (warning_fn))

void __png_set_expand(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_expand(png_ptr) __png_set_expand((png_ptr))

void __png_set_filler(png_structp png_ptr, png_uint_32 filler, int flags) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_filler(png_ptr, filler, flags) __png_set_filler((png_ptr), (filler), (flags))

void __png_set_filter(png_structp png_ptr, int method, int filters) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_filter(png_ptr, method, filters) __png_set_filter((png_ptr), (method), (filters))

void __png_set_filter_heuristics(png_structp png_ptr, int heuristic_method, int num_weights, png_doublep filter_weights, png_doublep filter_costs) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_filter_heuristics(png_ptr, heuristic_method, num_weights, filter_weights, filter_costs) __png_set_filter_heuristics((png_ptr), (heuristic_method), (num_weights), (filter_weights), (filter_costs))

void __png_set_flush(png_structp png_ptr, int rows) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_flush(png_ptr, rows) __png_set_flush((png_ptr), (rows))

void __png_set_gAMA(png_structp png_ptr, png_infop info_ptr, double file_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_gAMA(png_ptr, info_ptr, file_gamma) __png_set_gAMA((png_ptr), (info_ptr), (file_gamma))

void __png_set_gAMA_fixed(png_structp png_ptr, png_infop info_ptr, png_fixed_point int_file_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_gAMA_fixed(png_ptr, info_ptr, int_file_gamma) __png_set_gAMA_fixed((png_ptr), (info_ptr), (int_file_gamma))

void __png_set_gamma(png_structp png_ptr, double screen_gamma, double default_file_gamma) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_gamma(png_ptr, screen_gamma, default_file_gamma) __png_set_gamma((png_ptr), (screen_gamma), (default_file_gamma))

void __png_set_gray_1_2_4_to_8(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_gray_1_2_4_to_8(png_ptr) __png_set_gray_1_2_4_to_8((png_ptr))

void __png_set_gray_to_rgb(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_gray_to_rgb(png_ptr) __png_set_gray_to_rgb((png_ptr))

void __png_set_hIST(png_structp png_ptr, png_infop info_ptr, png_uint_16p hist) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_hIST(png_ptr, info_ptr, hist) __png_set_hIST((png_ptr), (info_ptr), (hist))

void __png_set_iCCP(png_structp png_ptr, png_infop info_ptr, png_charp name, int compression_type, png_charp profile, png_uint_32 proflen) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_iCCP(png_ptr, info_ptr, name, compression_type, profile, proflen) __png_set_iCCP((png_ptr), (info_ptr), (name), (compression_type), (profile), (proflen))

int __png_set_interlace_handling(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_interlace_handling(png_ptr) __png_set_interlace_handling((png_ptr))

void __png_set_invert_alpha(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_invert_alpha(png_ptr) __png_set_invert_alpha((png_ptr))

void __png_set_invert_mono(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_invert_mono(png_ptr) __png_set_invert_mono((png_ptr))

void __png_set_keep_unknown_chunks(png_structp png_ptr, int keep, png_bytep chunk_list, int num_chunks) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_keep_unknown_chunks(png_ptr, keep, chunk_list, num_chunks) __png_set_keep_unknown_chunks((png_ptr), (keep), (chunk_list), (num_chunks))

void __png_set_oFFs(png_structp png_ptr, png_infop info_ptr, png_int_32 offset_x, png_int_32 offset_y, int unit_type) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_oFFs(png_ptr, info_ptr, offset_x, offset_y, unit_type) __png_set_oFFs((png_ptr), (info_ptr), (offset_x), (offset_y), (unit_type))

void __png_set_pCAL(png_structp png_ptr, png_infop info_ptr, png_charp purpose, png_int_32 X0, png_int_32 X1, int type, int nparams, png_charp units, png_charpp params) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_pCAL(png_ptr, info_ptr, purpose, X0, X1, type, nparams, units, params) __png_set_pCAL((png_ptr), (info_ptr), (purpose), (X0), (X1), (type), (nparams), (units), (params))

void __png_set_pHYs(png_structp png_ptr, png_infop info_ptr, png_uint_32 res_x, png_uint_32 res_y, int unit_type) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_pHYs(png_ptr, info_ptr, res_x, res_y, unit_type) __png_set_pHYs((png_ptr), (info_ptr), (res_x), (res_y), (unit_type))

void __png_set_packing(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_packing(png_ptr) __png_set_packing((png_ptr))

void __png_set_packswap(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_packswap(png_ptr) __png_set_packswap((png_ptr))

void __png_set_palette_to_rgb(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_palette_to_rgb(png_ptr) __png_set_palette_to_rgb((png_ptr))

void __png_set_progressive_read_fn(png_structp png_ptr, png_voidp progressive_ptr, png_progressive_info_ptr info_fn, png_progressive_row_ptr row_fn, png_progressive_end_ptr end_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_progressive_read_fn(png_ptr, progressive_ptr, info_fn, row_fn, end_fn) __png_set_progressive_read_fn((png_ptr), (progressive_ptr), (info_fn), (row_fn), (end_fn))

void __png_set_read_fn(png_structp png_ptr, png_voidp io_ptr, png_rw_ptr read_data_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_read_fn(png_ptr, io_ptr, read_data_fn) __png_set_read_fn((png_ptr), (io_ptr), (read_data_fn))

void __png_set_read_status_fn(png_structp png_ptr, png_read_status_ptr read_row_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_read_status_fn(png_ptr, read_row_fn) __png_set_read_status_fn((png_ptr), (read_row_fn))

void __png_set_read_user_chunk_fn(png_structp png_ptr, png_voidp user_chunk_ptr, png_user_chunk_ptr read_user_chunk_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_read_user_chunk_fn(png_ptr, user_chunk_ptr, read_user_chunk_fn) __png_set_read_user_chunk_fn((png_ptr), (user_chunk_ptr), (read_user_chunk_fn))

void __png_set_read_user_transform_fn(png_structp png_ptr, png_user_transform_ptr read_user_transform_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_read_user_transform_fn(png_ptr, read_user_transform_fn) __png_set_read_user_transform_fn((png_ptr), (read_user_transform_fn))

void __png_set_rgb_to_gray(png_structp png_ptr, int error_action, double red, double green) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_rgb_to_gray(png_ptr, error_action, red, green) __png_set_rgb_to_gray((png_ptr), (error_action), (red), (green))

void __png_set_rgb_to_gray_fixed(png_structp png_ptr, int error_action, png_fixed_point red, png_fixed_point green) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_rgb_to_gray_fixed(png_ptr, error_action, red, green) __png_set_rgb_to_gray_fixed((png_ptr), (error_action), (red), (green))

void __png_set_rows(png_structp png_ptr, png_infop info_ptr, png_bytepp row_pointers) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_rows(png_ptr, info_ptr, row_pointers) __png_set_rows((png_ptr), (info_ptr), (row_pointers))

void __png_set_sBIT(png_structp png_ptr, png_infop info_ptr, png_color_8p sig_bit) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_sBIT(png_ptr, info_ptr, sig_bit) __png_set_sBIT((png_ptr), (info_ptr), (sig_bit))

void __png_set_sCAL(png_structp png_ptr, png_infop info_ptr, int unit, double width, double height) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_sCAL(png_ptr, info_ptr, unit, width, height) __png_set_sCAL((png_ptr), (info_ptr), (unit), (width), (height))

void __png_set_sRGB(png_structp png_ptr, png_infop info_ptr, int intent) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_sRGB(png_ptr, info_ptr, intent) __png_set_sRGB((png_ptr), (info_ptr), (intent))

void __png_set_sRGB_gAMA_and_cHRM(png_structp png_ptr, png_infop info_ptr, int intent) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_sRGB_gAMA_and_cHRM(png_ptr, info_ptr, intent) __png_set_sRGB_gAMA_and_cHRM((png_ptr), (info_ptr), (intent))

void __png_set_shift(png_structp png_ptr, png_color_8p true_bits) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_shift(png_ptr, true_bits) __png_set_shift((png_ptr), (true_bits))

void __png_set_sig_bytes(png_structp png_ptr, int num_bytes) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_sig_bytes(png_ptr, num_bytes) __png_set_sig_bytes((png_ptr), (num_bytes))

void __png_set_strip_16(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_strip_16(png_ptr) __png_set_strip_16((png_ptr))

void __png_set_strip_alpha(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_strip_alpha(png_ptr) __png_set_strip_alpha((png_ptr))

void __png_set_swap(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_swap(png_ptr) __png_set_swap((png_ptr))

void __png_set_swap_alpha(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_swap_alpha(png_ptr) __png_set_swap_alpha((png_ptr))

void __png_set_tIME(png_structp png_ptr, png_infop info_ptr, png_timep mod_time) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_tIME(png_ptr, info_ptr, mod_time) __png_set_tIME((png_ptr), (info_ptr), (mod_time))

void __png_set_tRNS(png_structp png_ptr, png_infop info_ptr, png_bytep trans, int num_trans, png_color_16p trans_values) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_tRNS(png_ptr, info_ptr, trans, num_trans, trans_values) __png_set_tRNS((png_ptr), (info_ptr), (trans), (num_trans), (trans_values))

void __png_set_tRNS_to_alpha(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_tRNS_to_alpha(png_ptr) __png_set_tRNS_to_alpha((png_ptr))

void __png_set_text(png_structp png_ptr, png_infop info_ptr, png_textp text_ptr, int num_text) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_text(png_ptr, info_ptr, text_ptr, num_text) __png_set_text((png_ptr), (info_ptr), (text_ptr), (num_text))

void __png_set_unknown_chunk_location(png_structp png_ptr, png_infop info_ptr, int chunk, int location) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_unknown_chunk_location(png_ptr, info_ptr, chunk, location) __png_set_unknown_chunk_location((png_ptr), (info_ptr), (chunk), (location))

void __png_set_unknown_chunks(png_structp png_ptr, png_infop info_ptr, png_unknown_chunkp unknowns, int num_unknowns) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_unknown_chunks(png_ptr, info_ptr, unknowns, num_unknowns) __png_set_unknown_chunks((png_ptr), (info_ptr), (unknowns), (num_unknowns))

void __png_set_user_transform_info(png_structp png_ptr, png_voidp user_transform_ptr, int user_transform_depth, int user_transform_channels) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_user_transform_info(png_ptr, user_transform_ptr, user_transform_depth, user_transform_channels) __png_set_user_transform_info((png_ptr), (user_transform_ptr), (user_transform_depth), (user_transform_channels))

void __png_set_write_fn(png_structp png_ptr, png_voidp io_ptr, png_rw_ptr write_data_fn, png_flush_ptr output_flush_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_write_fn(png_ptr, io_ptr, write_data_fn, output_flush_fn) __png_set_write_fn((png_ptr), (io_ptr), (write_data_fn), (output_flush_fn))

void __png_set_write_status_fn(png_structp png_ptr, png_write_status_ptr write_row_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_write_status_fn(png_ptr, write_row_fn) __png_set_write_status_fn((png_ptr), (write_row_fn))

void __png_set_write_user_transform_fn(png_structp png_ptr, png_user_transform_ptr write_user_transform_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_write_user_transform_fn(png_ptr, write_user_transform_fn) __png_set_write_user_transform_fn((png_ptr), (write_user_transform_fn))

int __png_sig_cmp(png_bytep sig, png_size_t start, png_size_t num_to_check) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_sig_cmp(sig, start, num_to_check) __png_sig_cmp((sig), (start), (num_to_check))

void __png_start_read_image(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_start_read_image(png_ptr) __png_start_read_image((png_ptr))

void __png_warning(png_structp png_ptr, png_const_charp warning_message) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_warning(png_ptr, warning_message) __png_warning((png_ptr), (warning_message))

void __png_write_chunk(png_structp png_ptr, png_bytep chunk_name, png_bytep data, png_size_t length) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_chunk(png_ptr, chunk_name, data, length) __png_write_chunk((png_ptr), (chunk_name), (data), (length))

void __png_write_chunk_data(png_structp png_ptr, png_bytep data, png_size_t length) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_chunk_data(png_ptr, data, length) __png_write_chunk_data((png_ptr), (data), (length))

void __png_write_chunk_end(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_chunk_end(png_ptr) __png_write_chunk_end((png_ptr))

void __png_write_chunk_start(png_structp png_ptr, png_bytep chunk_name, png_uint_32 length) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_chunk_start(png_ptr, chunk_name, length) __png_write_chunk_start((png_ptr), (chunk_name), (length))

void __png_write_end(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_end(png_ptr, info_ptr) __png_write_end((png_ptr), (info_ptr))

void __png_write_flush(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_flush(png_ptr) __png_write_flush((png_ptr))

void __png_write_image(png_structp png_ptr, png_bytepp image) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_image(png_ptr, image) __png_write_image((png_ptr), (image))

void __png_write_info(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_info(png_ptr, info_ptr) __png_write_info((png_ptr), (info_ptr))

void __png_write_info_before_PLTE(png_structp png_ptr, png_infop info_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_info_before_PLTE(png_ptr, info_ptr) __png_write_info_before_PLTE((png_ptr), (info_ptr))

void __png_write_png(png_structp png_ptr, png_infop info_ptr, int transforms, png_voidp params) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_png(png_ptr, info_ptr, transforms, params) __png_write_png((png_ptr), (info_ptr), (transforms), (params))

void __png_write_row(png_structp png_ptr, png_bytep row) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_row(png_ptr, row) __png_write_row((png_ptr), (row))

void __png_write_rows(png_structp png_ptr, png_bytepp row, png_uint_32 num_rows) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_write_rows(png_ptr, row, num_rows) __png_write_rows((png_ptr), (row), (num_rows))

png_uint_32 __png_access_version_number() =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1000(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_access_version_number() __png_access_version_number()

png_charp __png_convert_to_rfc1123(png_structp png_ptr, png_timep ptime) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1006(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_convert_to_rfc1123(png_ptr, ptime) __png_convert_to_rfc1123((png_ptr), (ptime))

void __png_set_invalid(png_structp png_ptr, png_infop png_info, int mask) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1012(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_invalid(png_ptr, png_info, mask) __png_set_invalid((png_ptr), (png_info), (mask))

png_uint_32 __png_permit_mng_features(png_structp png_ptr, png_uint_32 mng_features_permitted) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1018(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_permit_mng_features(png_ptr, mng_features_permitted) __png_permit_mng_features((png_ptr), (mng_features_permitted))

int __png_mmx_support() =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1024(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_mmx_support() __png_mmx_support()

void __png_set_strip_error_numbers(png_structp png_ptr, png_uint_32 strip_mode) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_strip_error_numbers(png_ptr, strip_mode) __png_set_strip_error_numbers((png_ptr), (strip_mode))

int __png_handle_as_unknown(png_structp png_ptr, png_bytep chunk_name) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_handle_as_unknown(png_ptr, chunk_name) __png_handle_as_unknown((png_ptr), (chunk_name))

png_voidp __png_malloc_warn(png_structp png_ptr, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_malloc_warn(png_ptr, size) __png_malloc_warn((png_ptr), (size))

void __png_set_mem_fn(png_structp png_ptr, png_voidp mem_ptr, png_malloc_ptr malloc_fn, png_free_ptr free_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_mem_fn(png_ptr, mem_ptr, malloc_fn, free_fn) __png_set_mem_fn((png_ptr), (mem_ptr), (malloc_fn), (free_fn))

png_voidp __png_get_mem_ptr(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_mem_ptr(png_ptr) __png_get_mem_ptr((png_ptr))

png_structp __png_create_read_struct_2(png_const_charp user_png_ver, png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn, png_voidp mem_ptr, png_malloc_ptr malloc_fn, png_free_ptr free_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_create_read_struct_2(user_png_ver, error_ptr, error_fn, warn_fn, mem_ptr, malloc_fn, free_fn) __png_create_read_struct_2((user_png_ver), (error_ptr), (error_fn), (warn_fn), (mem_ptr), (malloc_fn), (free_fn))

png_structp __png_create_write_struct_2(png_const_charp user_png_ver, png_voidp error_ptr, png_error_ptr error_fn, png_error_ptr warn_fn, png_voidp mem_ptr, png_malloc_ptr malloc_fn, png_free_ptr free_fn) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_create_write_struct_2(user_png_ver, error_ptr, error_fn, warn_fn, mem_ptr, malloc_fn, free_fn) __png_create_write_struct_2((user_png_ver), (error_ptr), (error_fn), (warn_fn), (mem_ptr), (malloc_fn), (free_fn))

png_voidp __png_malloc_default(png_structp png_ptr, png_uint_32 size) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_malloc_default(png_ptr, size) __png_malloc_default((png_ptr), (size))

void __png_free_default(png_structp png_ptr, png_voidp ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_free_default(png_ptr, ptr) __png_free_default((png_ptr), (ptr))

void __png_set_user_limits(png_structp png_ptr, png_uint_32 user_width_max, png_uint_32 user_height_max) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_user_limits(png_ptr, user_width_max, user_height_max) __png_set_user_limits((png_ptr), (user_width_max), (user_height_max))

png_uint_32 __png_get_user_width_max(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_user_width_max(png_ptr) __png_get_user_width_max((png_ptr))

png_uint_32 __png_get_user_height_max(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_get_user_height_max(png_ptr) __png_get_user_height_max((png_ptr))

void __png_set_add_alpha(png_structp png_ptr, png_uint_32 filler, int filler_loc) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_add_alpha(png_ptr, filler, filler_loc) __png_set_add_alpha((png_ptr), (filler), (filler_loc))

void __png_set_expand_gray_1_2_4_to_8(png_structp png_ptr) =
	"\tlis\t11,PNGBase@ha\n"
	"\tlwz\t12,PNGBase@l(11)\n"
	"\tlwz\t0,-1120(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define png_set_expand_gray_1_2_4_to_8(png_ptr) __png_set_expand_gray_1_2_4_to_8((png_ptr))

#endif /*  _VBCCINLINE_PNG_H  */

#ifndef _VBCCINLINE_JFIF_H
#define _VBCCINLINE_JFIF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __jpeg_CreateCompress(j_compress_ptr cinfo, int version, size_t structsize) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_CreateCompress(cinfo, version, structsize) __jpeg_CreateCompress((cinfo), (version), (structsize))

void __jpeg_CreateDecompress(j_decompress_ptr cinfo, int version, size_t structsize) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_CreateDecompress(cinfo, version, structsize) __jpeg_CreateDecompress((cinfo), (version), (structsize))

void __jpeg_destroy_compress(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_destroy_compress(cinfo) __jpeg_destroy_compress((cinfo))

void __jpeg_destroy_decompress(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_destroy_decompress(cinfo) __jpeg_destroy_decompress((cinfo))

void __jpeg_set_defaults(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_set_defaults(cinfo) __jpeg_set_defaults((cinfo))

void __jpeg_set_colorspace(j_compress_ptr cinfo, J_COLOR_SPACE colorspace) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_set_colorspace(cinfo, colorspace) __jpeg_set_colorspace((cinfo), (colorspace))

void __jpeg_default_colorspace(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_default_colorspace(cinfo) __jpeg_default_colorspace((cinfo))

void __jpeg_set_quality(j_compress_ptr cinfo, int quality, boolean force_baseline) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_set_quality(cinfo, quality, force_baseline) __jpeg_set_quality((cinfo), (quality), (force_baseline))

void __jpeg_set_linear_quality(j_compress_ptr cinfo, int scale_factor, boolean force_baseline) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_set_linear_quality(cinfo, scale_factor, force_baseline) __jpeg_set_linear_quality((cinfo), (scale_factor), (force_baseline))

void __jpeg_add_quant_table(j_compress_ptr cinfo, int which_tbl, const unsigned int * basic_table, int scale_factor, boolean force_baseline) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_add_quant_table(cinfo, which_tbl, basic_table, scale_factor, force_baseline) __jpeg_add_quant_table((cinfo), (which_tbl), (basic_table), (scale_factor), (force_baseline))

int __jpeg_quality_scaling(int quality) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_quality_scaling(quality) __jpeg_quality_scaling((quality))

void __jpeg_simple_progression(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_simple_progression(cinfo) __jpeg_simple_progression((cinfo))

void __jpeg_suppress_tables(j_compress_ptr cinfo, boolean suppress) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_suppress_tables(cinfo, suppress) __jpeg_suppress_tables((cinfo), (suppress))

JQUANT_TBL * __jpeg_alloc_quant_table(j_common_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_alloc_quant_table(cinfo) __jpeg_alloc_quant_table((cinfo))

JHUFF_TBL * __jpeg_alloc_huff_table(j_common_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_alloc_huff_table(cinfo) __jpeg_alloc_huff_table((cinfo))

void __jpeg_start_compress(j_compress_ptr cinfo, boolean write_all_tables) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_start_compress(cinfo, write_all_tables) __jpeg_start_compress((cinfo), (write_all_tables))

JDIMENSION __jpeg_write_scanlines(j_compress_ptr cinfo, JSAMPARRAY scanlines, JDIMENSION num_lines) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_scanlines(cinfo, scanlines, num_lines) __jpeg_write_scanlines((cinfo), (scanlines), (num_lines))

void __jpeg_finish_compress(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_finish_compress(cinfo) __jpeg_finish_compress((cinfo))

JDIMENSION __jpeg_write_raw_data(j_compress_ptr cinfo, JSAMPIMAGE data, JDIMENSION num_lines) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_raw_data(cinfo, data, num_lines) __jpeg_write_raw_data((cinfo), (data), (num_lines))

void __jpeg_write_marker(j_compress_ptr cinfo, int marker, const JOCTET * dataptr, unsigned int datalen) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_marker(cinfo, marker, dataptr, datalen) __jpeg_write_marker((cinfo), (marker), (dataptr), (datalen))

void __jpeg_write_m_header(j_compress_ptr cinfo, int marker, unsigned int datalen) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_m_header(cinfo, marker, datalen) __jpeg_write_m_header((cinfo), (marker), (datalen))

void __jpeg_write_m_byte(j_compress_ptr cinfo, int val) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_m_byte(cinfo, val) __jpeg_write_m_byte((cinfo), (val))

void __jpeg_write_tables(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_tables(cinfo) __jpeg_write_tables((cinfo))

int __jpeg_read_header(j_decompress_ptr cinfo, boolean require_image) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_read_header(cinfo, require_image) __jpeg_read_header((cinfo), (require_image))

boolean __jpeg_start_decompress(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_start_decompress(cinfo) __jpeg_start_decompress((cinfo))

JDIMENSION __jpeg_read_scanlines(j_decompress_ptr cinfo, JSAMPARRAY scanlines, JDIMENSION max_lines) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_read_scanlines(cinfo, scanlines, max_lines) __jpeg_read_scanlines((cinfo), (scanlines), (max_lines))

boolean __jpeg_finish_decompress(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_finish_decompress(cinfo) __jpeg_finish_decompress((cinfo))

JDIMENSION __jpeg_read_raw_data(j_decompress_ptr cinfo, JSAMPIMAGE data, JDIMENSION max_lines) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_read_raw_data(cinfo, data, max_lines) __jpeg_read_raw_data((cinfo), (data), (max_lines))

boolean __jpeg_has_multiple_scans(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_has_multiple_scans(cinfo) __jpeg_has_multiple_scans((cinfo))

boolean __jpeg_start_output(j_decompress_ptr cinfo, int scan_number) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_start_output(cinfo, scan_number) __jpeg_start_output((cinfo), (scan_number))

boolean __jpeg_finish_output(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_finish_output(cinfo) __jpeg_finish_output((cinfo))

boolean __jpeg_input_complete(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_input_complete(cinfo) __jpeg_input_complete((cinfo))

void __jpeg_new_colormap(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_new_colormap(cinfo) __jpeg_new_colormap((cinfo))

int __jpeg_consume_input(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_consume_input(cinfo) __jpeg_consume_input((cinfo))

void __jpeg_calc_output_dimensions(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_calc_output_dimensions(cinfo) __jpeg_calc_output_dimensions((cinfo))

void __jpeg_save_markers(j_decompress_ptr cinfo, int marker_code, unsigned int routine) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_save_markers(cinfo, marker_code, routine) __jpeg_save_markers((cinfo), (marker_code), (routine))

void __jpeg_set_marker_processor(j_decompress_ptr cinfo, int marker_code, jpeg_marker_parser_method routine) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_set_marker_processor(cinfo, marker_code, routine) __jpeg_set_marker_processor((cinfo), (marker_code), (routine))

jvirt_barray_ptr * __jpeg_read_coefficients(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_read_coefficients(cinfo) __jpeg_read_coefficients((cinfo))

void __jpeg_write_coefficients(j_compress_ptr cinfo, jvirt_barray_ptr * coef_arrays) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_write_coefficients(cinfo, coef_arrays) __jpeg_write_coefficients((cinfo), (coef_arrays))

void __jpeg_copy_critical_parameters(j_decompress_ptr srcinfo, j_compress_ptr dstinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_copy_critical_parameters(srcinfo, dstinfo) __jpeg_copy_critical_parameters((srcinfo), (dstinfo))

void __jpeg_abort_compress(j_compress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_abort_compress(cinfo) __jpeg_abort_compress((cinfo))

void __jpeg_abort_decompress(j_decompress_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_abort_decompress(cinfo) __jpeg_abort_decompress((cinfo))

void __jpeg_abort(j_common_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_abort(cinfo) __jpeg_abort((cinfo))

void __jpeg_destroy(j_common_ptr cinfo) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_destroy(cinfo) __jpeg_destroy((cinfo))

boolean __jpeg_resync_to_restart(j_decompress_ptr cinfo, int desired) =
	"\tlis\t11,JFIFBase@ha\n"
	"\tlwz\t12,JFIFBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define jpeg_resync_to_restart(cinfo, desired) __jpeg_resync_to_restart((cinfo), (desired))

#endif /*  _VBCCINLINE_JFIF_H  */

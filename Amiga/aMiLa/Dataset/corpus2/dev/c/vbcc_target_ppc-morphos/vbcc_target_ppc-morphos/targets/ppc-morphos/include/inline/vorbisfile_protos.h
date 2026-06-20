#ifndef _VBCCINLINE_VORBISFILE_H
#define _VBCCINLINE_VORBISFILE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

int __ov_clear(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_clear(vf) __ov_clear((vf))

int __ov_open(BPTR f, OggVorbis_File * vf, char * initial, long ibytes) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_open(f, vf, initial, ibytes) __ov_open((f), (vf), (initial), (ibytes))

int __ov_open_callbacks(void * f, OggVorbis_File * vf, char * initial, long ibytes, ov_callbacks * callbacks) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_open_callbacks(f, vf, initial, ibytes, callbacks) __ov_open_callbacks((f), (vf), (initial), (ibytes), (callbacks))

int __ov_test(BPTR f, OggVorbis_File * vf, char * initial, long ibytes) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_test(f, vf, initial, ibytes) __ov_test((f), (vf), (initial), (ibytes))

int __ov_test_callbacks(void * f, OggVorbis_File * vf, char * initial, long ibytes, ov_callbacks * callbacks) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_test_callbacks(f, vf, initial, ibytes, callbacks) __ov_test_callbacks((f), (vf), (initial), (ibytes), (callbacks))

int __ov_test_open(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_test_open(vf) __ov_test_open((vf))

long __ov_bitrate(OggVorbis_File * vf, int i) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_bitrate(vf, i) __ov_bitrate((vf), (i))

long __ov_bitrate_instant(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_bitrate_instant(vf) __ov_bitrate_instant((vf))

long __ov_seekable(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_seekable(vf) __ov_seekable((vf))

long __ov_serialnumber(OggVorbis_File * vf, int i) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_serialnumber(vf, i) __ov_serialnumber((vf), (i))

ogg_int64_t __ov_raw_total(OggVorbis_File * vf, int i) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_raw_total(vf, i) __ov_raw_total((vf), (i))

ogg_int64_t __ov_pcm_total(OggVorbis_File * vf, int i) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_total(vf, i) __ov_pcm_total((vf), (i))

double __ov_time_total(OggVorbis_File * vf, int i) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_total(vf, i) __ov_time_total((vf), (i))

int __ov_raw_seek(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_raw_seek(vf, pos) __ov_raw_seek((vf), (pos))

int __ov_pcm_seek(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_seek(vf, pos) __ov_pcm_seek((vf), (pos))

int __ov_pcm_seek_page(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_seek_page(vf, pos) __ov_pcm_seek_page((vf), (pos))

int __ov_time_seek(OggVorbis_File * vf, double pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_seek(vf, pos) __ov_time_seek((vf), (pos))

int __ov_time_seek_page(OggVorbis_File * vf, double pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_seek_page(vf, pos) __ov_time_seek_page((vf), (pos))

ogg_int64_t __ov_raw_tell(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_raw_tell(vf) __ov_raw_tell((vf))

ogg_int64_t __ov_pcm_tell(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_tell(vf) __ov_pcm_tell((vf))

double __ov_time_tell(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_tell(vf) __ov_time_tell((vf))

vorbis_info * __ov_info(OggVorbis_File * vf, int link) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_info(vf, link) __ov_info((vf), (link))

vorbis_comment * __ov_comment(OggVorbis_File * vf, int link) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_comment(vf, link) __ov_comment((vf), (link))

long __ov_read(OggVorbis_File * vf, char * buffer, int length, int bigendianp, int word, int sgned, int * bitstream) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_read(vf, buffer, length, bigendianp, word, sgned, bitstream) __ov_read((vf), (buffer), (length), (bigendianp), (word), (sgned), (bitstream))

long __ov_read_float(OggVorbis_File * vf, float *** pcm_channels, int length, int * bitstream) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_read_float(vf, pcm_channels, length, bitstream) __ov_read_float((vf), (pcm_channels), (length), (bitstream))

long __ov_streams(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_streams(vf) __ov_streams((vf))

int __vorbis_encode_init(vorbis_info * vi, long channels, long rate, long max_bitrate, long nominal_bitrate, long min_bitrate) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_init(vi, channels, rate, max_bitrate, nominal_bitrate, min_bitrate) __vorbis_encode_init((vi), (channels), (rate), (max_bitrate), (nominal_bitrate), (min_bitrate))

int __vorbis_encode_setup_managed(vorbis_info * vi, long channels, long rate, long max_bitrate, long nominal_bitrate, long min_bitrate) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_setup_managed(vi, channels, rate, max_bitrate, nominal_bitrate, min_bitrate) __vorbis_encode_setup_managed((vi), (channels), (rate), (max_bitrate), (nominal_bitrate), (min_bitrate))

int __vorbis_encode_setup_vbr(vorbis_info * vi, long channels, long rate, float q) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_setup_vbr(vi, channels, rate, q) __vorbis_encode_setup_vbr((vi), (channels), (rate), (q))

int __vorbis_encode_init_vbr(vorbis_info * vi, long channels, long rate, float base_quality) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_init_vbr(vi, channels, rate, base_quality) __vorbis_encode_init_vbr((vi), (channels), (rate), (base_quality))

int __vorbis_encode_setup_init(vorbis_info * vi) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_setup_init(vi) __vorbis_encode_setup_init((vi))

int __vorbis_encode_ctl(vorbis_info * vi, int number, void * arg) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_encode_ctl(vi, number, arg) __vorbis_encode_ctl((vi), (number), (arg))

void __vorbis_info_init(vorbis_info * vi) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_info_init(vi) __vorbis_info_init((vi))

void __vorbis_info_clear(vorbis_info * vi) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_info_clear(vi) __vorbis_info_clear((vi))

void __vorbis_comment_init(vorbis_comment * vc) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_init(vc) __vorbis_comment_init((vc))

void __vorbis_comment_add_tag(vorbis_comment * vc, const char * d0arg, const char * contents) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_add_tag(vc, d0arg, contents) __vorbis_comment_add_tag((vc), (d0arg), (contents))

void __vorbis_comment_clear(vorbis_comment * vc) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_clear(vc) __vorbis_comment_clear((vc))

int __vorbis_analysis_init(vorbis_dsp_state * v, vorbis_info * vi) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis_init(v, vi) __vorbis_analysis_init((v), (vi))

int __vorbis_analysis_headerout(vorbis_dsp_state * v, vorbis_comment * vc, ogg_packet * op, ogg_packet * op_comm, ogg_packet * op_code) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis_headerout(v, vc, op, op_comm, op_code) __vorbis_analysis_headerout((v), (vc), (op), (op_comm), (op_code))

float ** __vorbis_analysis_buffer(vorbis_dsp_state * v, int vals) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis_buffer(v, vals) __vorbis_analysis_buffer((v), (vals))

int __vorbis_analysis_wrote(vorbis_dsp_state * v, int vals) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis_wrote(v, vals) __vorbis_analysis_wrote((v), (vals))

int __vorbis_analysis_blockout(vorbis_dsp_state * v, vorbis_block * vb) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis_blockout(v, vb) __vorbis_analysis_blockout((v), (vb))

int __vorbis_analysis(vorbis_block * vb, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_analysis(vb, op) __vorbis_analysis((vb), (op))

int __vorbis_synthesis_headerin(vorbis_info * vi, vorbis_comment * vc, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_headerin(vi, vc, op) __vorbis_synthesis_headerin((vi), (vc), (op))

int __vorbis_synthesis_init(vorbis_dsp_state * v, vorbis_info * vi) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_init(v, vi) __vorbis_synthesis_init((v), (vi))

int __vorbis_synthesis_restart(vorbis_dsp_state * v) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_restart(v) __vorbis_synthesis_restart((v))

int __vorbis_synthesis(vorbis_block * vb, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis(vb, op) __vorbis_synthesis((vb), (op))

int __vorbis_synthesis_trackonly(vorbis_block * vb, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_trackonly(vb, op) __vorbis_synthesis_trackonly((vb), (op))

int __vorbis_synthesis_blockin(vorbis_dsp_state * v, vorbis_block * vb) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_blockin(v, vb) __vorbis_synthesis_blockin((v), (vb))

int __vorbis_synthesis_pcmout(vorbis_dsp_state * v, float *** pcm) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_pcmout(v, pcm) __vorbis_synthesis_pcmout((v), (pcm))

int __vorbis_synthesis_lapout(vorbis_dsp_state * v, float *** pcm) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_lapout(v, pcm) __vorbis_synthesis_lapout((v), (pcm))

int __vorbis_synthesis_read(vorbis_dsp_state * v, int samples) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_read(v, samples) __vorbis_synthesis_read((v), (samples))

long __vorbis_packet_blocksize(vorbis_info * vi, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_packet_blocksize(vi, op) __vorbis_packet_blocksize((vi), (op))

int __vorbis_synthesis_halfrate(vorbis_info * v, int flag) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_halfrate(v, flag) __vorbis_synthesis_halfrate((v), (flag))

int __vorbis_synthesis_halfrate_p(vorbis_info * v) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_halfrate_p(v) __vorbis_synthesis_halfrate_p((v))

int __vorbis_block_init(vorbis_dsp_state * v, vorbis_block * vb) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_block_init(v, vb) __vorbis_block_init((v), (vb))

int __vorbis_block_clear(vorbis_block * vb) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_block_clear(vb) __vorbis_block_clear((vb))

void __vorbis_dsp_clear(vorbis_dsp_state * v) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_dsp_clear(v) __vorbis_dsp_clear((v))

int __ogg_stream_init(ogg_stream_state * os, int serialno) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_init(os, serialno) __ogg_stream_init((os), (serialno))

int __ogg_stream_packetin(ogg_stream_state * os, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_packetin(os, op) __ogg_stream_packetin((os), (op))

int __ogg_stream_packetout(ogg_stream_state * os, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_packetout(os, op) __ogg_stream_packetout((os), (op))

int __ogg_stream_packetpeek(ogg_stream_state * os, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_packetpeek(os, op) __ogg_stream_packetpeek((os), (op))

int __ogg_stream_pagein(ogg_stream_state * os, ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_pagein(os, og) __ogg_stream_pagein((os), (og))

int __ogg_stream_pageout(ogg_stream_state * os, ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_pageout(os, og) __ogg_stream_pageout((os), (og))

int __ogg_stream_flush(ogg_stream_state * os, ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_flush(os, og) __ogg_stream_flush((os), (og))

int __ogg_stream_clear(ogg_stream_state * os) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_clear(os) __ogg_stream_clear((os))

int __vorbis_bitrate_addblock(vorbis_block * vb) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_bitrate_addblock(vb) __vorbis_bitrate_addblock((vb))

int __vorbis_bitrate_flushpacket(vorbis_dsp_state * vd, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_bitrate_flushpacket(vd, op) __vorbis_bitrate_flushpacket((vd), (op))

void __ogg_page_checksum_set(ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_checksum_set(og) __ogg_page_checksum_set((og))

int __ogg_page_version(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_version(og) __ogg_page_version((og))

int __ogg_page_continued(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_continued(og) __ogg_page_continued((og))

int __ogg_page_bos(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_bos(og) __ogg_page_bos((og))

int __ogg_page_eos(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_eos(og) __ogg_page_eos((og))

ogg_int64_t __ogg_page_granulepos(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_granulepos(og) __ogg_page_granulepos((og))

int __ogg_page_serialno(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_serialno(og) __ogg_page_serialno((og))

long __ogg_page_pageno(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_pageno(og) __ogg_page_pageno((og))

int __ogg_page_packets(const ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_page_packets(og) __ogg_page_packets((og))

int __ogg_sync_init(ogg_sync_state * oy) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_init(oy) __ogg_sync_init((oy))

int __ogg_sync_clear(ogg_sync_state * oy) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_clear(oy) __ogg_sync_clear((oy))

int __ogg_sync_reset(ogg_sync_state * oy) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_reset(oy) __ogg_sync_reset((oy))

char * __ogg_sync_buffer(ogg_sync_state * oy, long size) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_buffer(oy, size) __ogg_sync_buffer((oy), (size))

int __ogg_sync_wrote(ogg_sync_state * oy, long bytes) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_wrote(oy, bytes) __ogg_sync_wrote((oy), (bytes))

long __ogg_sync_pageseek(ogg_sync_state * oy, ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_pageseek(oy, og) __ogg_sync_pageseek((oy), (og))

int __ogg_sync_pageout(ogg_sync_state * oy, ogg_page * og) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_pageout(oy, og) __ogg_sync_pageout((oy), (og))

int __ogg_stream_reset(ogg_stream_state * os) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_reset(os) __ogg_stream_reset((os))

int __ogg_stream_reset_serialno(ogg_stream_state * os, int serialno) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_reset_serialno(os, serialno) __ogg_stream_reset_serialno((os), (serialno))

int __ogg_stream_eos(ogg_stream_state * os) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_eos(os) __ogg_stream_eos((os))

int __vorbis_info_blocksize(vorbis_info * vi, int zo) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_info_blocksize(vi, zo) __vorbis_info_blocksize((vi), (zo))

void __vorbis_comment_add(vorbis_comment * vc, const char * comment) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_add(vc, comment) __vorbis_comment_add((vc), (comment))

char * __vorbis_comment_query(vorbis_comment * vc, const char * d0arg, int count) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_query(vc, d0arg, count) __vorbis_comment_query((vc), (d0arg), (count))

int __vorbis_comment_query_count(vorbis_comment * vc, const char * d0arg) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_comment_query_count(vc, d0arg) __vorbis_comment_query_count((vc), (d0arg))

int __vorbis_commentheader_out(vorbis_comment * vc, ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_commentheader_out(vc, op) __vorbis_commentheader_out((vc), (op))

double __vorbis_granule_time(vorbis_dsp_state * v, ogg_int64_t granulepos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_granule_time(v, granulepos) __vorbis_granule_time((v), (granulepos))

int __ov_raw_seek_lap(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_raw_seek_lap(vf, pos) __ov_raw_seek_lap((vf), (pos))

int __ov_pcm_seek_lap(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_seek_lap(vf, pos) __ov_pcm_seek_lap((vf), (pos))

int __ov_pcm_seek_page_lap(OggVorbis_File * vf, ogg_int64_t pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_pcm_seek_page_lap(vf, pos) __ov_pcm_seek_page_lap((vf), (pos))

int __ov_time_seek_lap(OggVorbis_File * vf, double pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_seek_lap(vf, pos) __ov_time_seek_lap((vf), (pos))

int __ov_time_seek_page_lap(OggVorbis_File * vf, double pos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_time_seek_page_lap(vf, pos) __ov_time_seek_page_lap((vf), (pos))

int __ov_crosslap(OggVorbis_File * vf1, OggVorbis_File * vf2) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_crosslap(vf1, vf2) __ov_crosslap((vf1), (vf2))

int __ov_halfrate(OggVorbis_File * vf, int flag) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_halfrate(vf, flag) __ov_halfrate((vf), (flag))

int __ov_halfrate_p(OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_halfrate_p(vf) __ov_halfrate_p((vf))

int __ov_fopen(char * path, OggVorbis_File * vf) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_fopen(path, vf) __ov_fopen((path), (vf))

int __vorbis_synthesis_idheader(ogg_packet * op) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_synthesis_idheader(op) __vorbis_synthesis_idheader((op))

const char * __vorbis_version_string() =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define vorbis_version_string() __vorbis_version_string()

int __ogg_stream_iovecin(ogg_stream_state * os, ogg_iovec_t * iov, int count, long e_o_s, ogg_int64_t granulepos) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_iovecin(os, iov, count, e_o_s, granulepos) __ogg_stream_iovecin((os), (iov), (count), (e_o_s), (granulepos))

int __ogg_sync_check(ogg_sync_state * oy) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_sync_check(oy) __ogg_sync_check((oy))

int __ogg_stream_check(ogg_stream_state * os) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ogg_stream_check(os) __ogg_stream_check((os))

long __ov_read_filter(OggVorbis_File * vf, char * buffer, int length, int bigendianp, int word, int sgned, int * bitstream, void (*filter)(float **pcm,long channels,long samples,void *filter_param), void * filter_param) =
	"\tlis\t11,VorbisFileBase@ha\n"
	"\tlwz\t12,VorbisFileBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ov_read_filter(vf, buffer, length, bigendianp, word, sgned, bitstream, filter, filter_param) __ov_read_filter((vf), (buffer), (length), (bigendianp), (word), (sgned), (bitstream), (filter), (filter_param))

#endif /*  _VBCCINLINE_VORBISFILE_H  */

#ifndef _VBCCINLINE_PIXMAN_H
#define _VBCCINLINE_PIXMAN_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __pixman_transform_init_identity(struct pixman_transform       * matrix) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_init_identity(matrix) __pixman_transform_init_identity((matrix))

pixman_bool_t __pixman_transform_point_3d(const struct pixman_transform * transform, struct pixman_vector          * v) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_point_3d(transform, v) __pixman_transform_point_3d((transform), (v))

pixman_bool_t __pixman_transform_point(const struct pixman_transform * transform, struct pixman_vector          * v) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_point(transform, v) __pixman_transform_point((transform), (v))

pixman_bool_t __pixman_transform_multiply(struct pixman_transform       * dst, const struct pixman_transform * l, const struct pixman_transform * r) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_multiply(dst, l, r) __pixman_transform_multiply((dst), (l), (r))

void __pixman_transform_init_scale(struct pixman_transform       * t, pixman_fixed_t sx, pixman_fixed_t sy) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_init_scale(t, sx, sy) __pixman_transform_init_scale((t), (sx), (sy))

pixman_bool_t __pixman_transform_scale(struct pixman_transform       * forward, struct pixman_transform       * reverse, pixman_fixed_t sx, pixman_fixed_t sy) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_scale(forward, reverse, sx, sy) __pixman_transform_scale((forward), (reverse), (sx), (sy))

void __pixman_transform_init_rotate(struct pixman_transform       * t, pixman_fixed_t cos, pixman_fixed_t sin) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_init_rotate(t, cos, sin) __pixman_transform_init_rotate((t), (cos), (sin))

pixman_bool_t __pixman_transform_rotate(struct pixman_transform       * forward, struct pixman_transform       * reverse, pixman_fixed_t c, pixman_fixed_t s) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_rotate(forward, reverse, c, s) __pixman_transform_rotate((forward), (reverse), (c), (s))

void __pixman_transform_init_translate(struct pixman_transform       * t, pixman_fixed_t tx, pixman_fixed_t ty) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_init_translate(t, tx, ty) __pixman_transform_init_translate((t), (tx), (ty))

pixman_bool_t __pixman_transform_translate(struct pixman_transform       * forward, struct pixman_transform       * reverse, pixman_fixed_t tx, pixman_fixed_t ty) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_translate(forward, reverse, tx, ty) __pixman_transform_translate((forward), (reverse), (tx), (ty))

pixman_bool_t __pixman_transform_bounds(const struct pixman_transform * matrix, struct pixman_box16           * b) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_bounds(matrix, b) __pixman_transform_bounds((matrix), (b))

pixman_bool_t __pixman_transform_invert(struct pixman_transform       * dst, const struct pixman_transform * src) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_invert(dst, src) __pixman_transform_invert((dst), (src))

pixman_bool_t __pixman_transform_is_identity(const struct pixman_transform * t) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_is_identity(t) __pixman_transform_is_identity((t))

pixman_bool_t __pixman_transform_is_scale(const struct pixman_transform * t) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_is_scale(t) __pixman_transform_is_scale((t))

pixman_bool_t __pixman_transform_is_int_translate(const struct pixman_transform * t) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_is_int_translate(t) __pixman_transform_is_int_translate((t))

pixman_bool_t __pixman_transform_is_inverse(const struct pixman_transform * a, const struct pixman_transform * b) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_is_inverse(a, b) __pixman_transform_is_inverse((a), (b))

pixman_bool_t __pixman_transform_from_pixman_f_transform(struct pixman_transform         * t, const struct pixman_f_transform * ft) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_transform_from_pixman_f_transform(t, ft) __pixman_transform_from_pixman_f_transform((t), (ft))

void __pixman_f_transform_from_pixman_transform(struct pixman_f_transform       * ft, const struct pixman_transform   * t) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_from_pixman_transform(ft, t) __pixman_f_transform_from_pixman_transform((ft), (t))

pixman_bool_t __pixman_f_transform_invert(struct pixman_f_transform       * dst, const struct pixman_f_transform * src) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_invert(dst, src) __pixman_f_transform_invert((dst), (src))

pixman_bool_t __pixman_f_transform_point(const struct pixman_f_transform * t, struct pixman_f_vector          * v) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_point(t, v) __pixman_f_transform_point((t), (v))

void __pixman_f_transform_point_3d(const struct pixman_f_transform * t, struct pixman_f_vector          * v) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_point_3d(t, v) __pixman_f_transform_point_3d((t), (v))

void __pixman_f_transform_multiply(struct pixman_f_transform       * dst, const struct pixman_f_transform * l, const struct pixman_f_transform * r) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_multiply(dst, l, r) __pixman_f_transform_multiply((dst), (l), (r))

void __pixman_f_transform_init_scale(struct pixman_f_transform       * t, double sx, double sy) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_init_scale(t, sx, sy) __pixman_f_transform_init_scale((t), (sx), (sy))

pixman_bool_t __pixman_f_transform_scale(struct pixman_f_transform       * forward, struct pixman_f_transform       * reverse, double sx, double sy) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_scale(forward, reverse, sx, sy) __pixman_f_transform_scale((forward), (reverse), (sx), (sy))

void __pixman_f_transform_init_rotate(struct pixman_f_transform       * t, double cos, double sin) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_init_rotate(t, cos, sin) __pixman_f_transform_init_rotate((t), (cos), (sin))

pixman_bool_t __pixman_f_transform_rotate(struct pixman_f_transform       * forward, struct pixman_f_transform       * reverse, double c, double s) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_rotate(forward, reverse, c, s) __pixman_f_transform_rotate((forward), (reverse), (c), (s))

void __pixman_f_transform_init_translate(struct pixman_f_transform       * t, double tx, double ty) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_init_translate(t, tx, ty) __pixman_f_transform_init_translate((t), (tx), (ty))

pixman_bool_t __pixman_f_transform_translate(struct pixman_f_transform       * forward, struct pixman_f_transform       * reverse, double tx, double ty) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_translate(forward, reverse, tx, ty) __pixman_f_transform_translate((forward), (reverse), (tx), (ty))

pixman_bool_t __pixman_f_transform_bounds(const struct pixman_f_transform * t, struct pixman_box16             * b) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_bounds(t, b) __pixman_f_transform_bounds((t), (b))

void __pixman_f_transform_init_identity(struct pixman_f_transform       * t) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_f_transform_init_identity(t) __pixman_f_transform_init_identity((t))

void __pixman_region_init(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_init(region) __pixman_region_init((region))

void __pixman_region_init_rect(pixman_region16_t * region, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_init_rect(region, x, y, width, height) __pixman_region_init_rect((region), (x), (y), (width), (height))

pixman_bool_t __pixman_region_init_rects(pixman_region16_t * region, const pixman_box16_t * boxes, int count) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_init_rects(region, boxes, count) __pixman_region_init_rects((region), (boxes), (count))

void __pixman_region_init_with_extents(pixman_region16_t * region, pixman_box16_t    * extents) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_init_with_extents(region, extents) __pixman_region_init_with_extents((region), (extents))

void __pixman_region_fini(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_fini(region) __pixman_region_fini((region))

void __pixman_region_translate(pixman_region16_t * region, int x, int y) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_translate(region, x, y) __pixman_region_translate((region), (x), (y))

pixman_bool_t __pixman_region_copy(pixman_region16_t * dest, pixman_region16_t * source) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_copy(dest, source) __pixman_region_copy((dest), (source))

pixman_bool_t __pixman_region_intersect(pixman_region16_t * new_reg, pixman_region16_t * reg1, pixman_region16_t * reg2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_intersect(new_reg, reg1, reg2) __pixman_region_intersect((new_reg), (reg1), (reg2))

pixman_bool_t __pixman_region_union(pixman_region16_t * new_reg, pixman_region16_t * reg1, pixman_region16_t * reg2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_union(new_reg, reg1, reg2) __pixman_region_union((new_reg), (reg1), (reg2))

pixman_bool_t __pixman_region_union_rect(pixman_region16_t * dest, pixman_region16_t * source, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_union_rect(dest, source, x, y, width, height) __pixman_region_union_rect((dest), (source), (x), (y), (width), (height))

pixman_bool_t __pixman_region_subtract(pixman_region16_t * reg_d, pixman_region16_t * reg_m, pixman_region16_t * reg_s) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_subtract(reg_d, reg_m, reg_s) __pixman_region_subtract((reg_d), (reg_m), (reg_s))

pixman_bool_t __pixman_region_inverse(pixman_region16_t * new_reg, pixman_region16_t * reg1, pixman_box16_t    * inv_rect) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_inverse(new_reg, reg1, inv_rect) __pixman_region_inverse((new_reg), (reg1), (inv_rect))

pixman_bool_t __pixman_region_contains_point(pixman_region16_t * region, int x, int y, pixman_box16_t    * box) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_contains_point(region, x, y, box) __pixman_region_contains_point((region), (x), (y), (box))

pixman_region_overlap_t __pixman_region_contains_rectangle(pixman_region16_t * pixman_region16_t, pixman_box16_t    * prect) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_contains_rectangle(pixman_region16_t, prect) __pixman_region_contains_rectangle((pixman_region16_t), (prect))

pixman_bool_t __pixman_region_not_empty(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_not_empty(region) __pixman_region_not_empty((region))

pixman_box16_t * __pixman_region_extents(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_extents(region) __pixman_region_extents((region))

int __pixman_region_n_rects(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_n_rects(region) __pixman_region_n_rects((region))

pixman_box16_t * __pixman_region_rectangles(pixman_region16_t * region, int               * n_rects) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_rectangles(region, n_rects) __pixman_region_rectangles((region), (n_rects))

pixman_bool_t __pixman_region_equal(pixman_region16_t * region1, pixman_region16_t * region2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_equal(region1, region2) __pixman_region_equal((region1), (region2))

pixman_bool_t __pixman_region_selfcheck(pixman_region16_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_selfcheck(region) __pixman_region_selfcheck((region))

void __pixman_region_reset(pixman_region16_t * region, pixman_box16_t    * box) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_reset(region, box) __pixman_region_reset((region), (box))

void __pixman_region32_init(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_init(region) __pixman_region32_init((region))

void __pixman_region32_init_rect(pixman_region32_t * region, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_init_rect(region, x, y, width, height) __pixman_region32_init_rect((region), (x), (y), (width), (height))

pixman_bool_t __pixman_region32_init_rects(pixman_region32_t * region, const pixman_box32_t * boxes, int count) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_init_rects(region, boxes, count) __pixman_region32_init_rects((region), (boxes), (count))

void __pixman_region32_init_with_extents(pixman_region32_t * region, pixman_box32_t    * extents) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_init_with_extents(region, extents) __pixman_region32_init_with_extents((region), (extents))

void __pixman_region32_fini(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_fini(region) __pixman_region32_fini((region))

void __pixman_region32_translate(pixman_region32_t * region, int x, int y) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_translate(region, x, y) __pixman_region32_translate((region), (x), (y))

pixman_bool_t __pixman_region32_copy(pixman_region32_t * dest, pixman_region32_t * source) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_copy(dest, source) __pixman_region32_copy((dest), (source))

pixman_bool_t __pixman_region32_intersect(pixman_region32_t * new_reg, pixman_region32_t * reg1, pixman_region32_t * reg2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_intersect(new_reg, reg1, reg2) __pixman_region32_intersect((new_reg), (reg1), (reg2))

pixman_bool_t __pixman_region32_union(pixman_region32_t * new_reg, pixman_region32_t * reg1, pixman_region32_t * reg2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_union(new_reg, reg1, reg2) __pixman_region32_union((new_reg), (reg1), (reg2))

pixman_bool_t __pixman_region32_union_rect(pixman_region32_t * dest, pixman_region32_t * source, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_union_rect(dest, source, x, y, width, height) __pixman_region32_union_rect((dest), (source), (x), (y), (width), (height))

pixman_bool_t __pixman_region32_subtract(pixman_region32_t * reg_d, pixman_region32_t * reg_m, pixman_region32_t * reg_s) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_subtract(reg_d, reg_m, reg_s) __pixman_region32_subtract((reg_d), (reg_m), (reg_s))

pixman_bool_t __pixman_region32_inverse(pixman_region32_t * new_reg, pixman_region32_t * reg1, pixman_box32_t    * inv_rect) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_inverse(new_reg, reg1, inv_rect) __pixman_region32_inverse((new_reg), (reg1), (inv_rect))

pixman_bool_t __pixman_region32_contains_point(pixman_region32_t * region, int x, int y, pixman_box32_t    * box) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_contains_point(region, x, y, box) __pixman_region32_contains_point((region), (x), (y), (box))

pixman_region_overlap_t __pixman_region32_contains_rectangle(pixman_region32_t * region, pixman_box32_t    * prect) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_contains_rectangle(region, prect) __pixman_region32_contains_rectangle((region), (prect))

pixman_bool_t __pixman_region32_not_empty(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_not_empty(region) __pixman_region32_not_empty((region))

pixman_box32_t * __pixman_region32_extents(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_extents(region) __pixman_region32_extents((region))

int __pixman_region32_n_rects(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_n_rects(region) __pixman_region32_n_rects((region))

pixman_box32_t * __pixman_region32_rectangles(pixman_region32_t * region, int               * n_rects) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_rectangles(region, n_rects) __pixman_region32_rectangles((region), (n_rects))

pixman_bool_t __pixman_region32_equal(pixman_region32_t * region1, pixman_region32_t * region2) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_equal(region1, region2) __pixman_region32_equal((region1), (region2))

pixman_bool_t __pixman_region32_selfcheck(pixman_region32_t * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_selfcheck(region) __pixman_region32_selfcheck((region))

void __pixman_region32_reset(pixman_region32_t * region, pixman_box32_t    * box) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_reset(region, box) __pixman_region32_reset((region), (box))

pixman_bool_t __pixman_blt(uint32_t           * src_bits, uint32_t           * dst_bits, int src_stride, int dst_stride, int src_bpp, int dst_bpp, int src_x, int src_y, int dst_x, int dst_y, int width, int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_blt(src_bits, dst_bits, src_stride, dst_stride, src_bpp, dst_bpp, src_x, src_y, dst_x, dst_y, width, height) __pixman_blt((src_bits), (dst_bits), (src_stride), (dst_stride), (src_bpp), (dst_bpp), (src_x), (src_y), (dst_x), (dst_y), (width), (height))

pixman_bool_t __pixman_fill(uint32_t           * bits, int stride, int bpp, int x, int y, int width, int height, uint32_t _xor) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_fill(bits, stride, bpp, x, y, width, height, _xor) __pixman_fill((bits), (stride), (bpp), (x), (y), (width), (height), (_xor))

int __pixman_version() =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_version() __pixman_version()

const char* __pixman_version_string() =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_version_string() __pixman_version_string()

pixman_bool_t __pixman_format_supported_destination(pixman_format_code_t format) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_format_supported_destination(format) __pixman_format_supported_destination((format))

pixman_bool_t __pixman_format_supported_source(pixman_format_code_t format) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_format_supported_source(format) __pixman_format_supported_source((format))

pixman_image_t * __pixman_image_create_solid_fill(pixman_color_t               * color) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_create_solid_fill(color) __pixman_image_create_solid_fill((color))

pixman_image_t * __pixman_image_create_linear_gradient(pixman_point_fixed_t         * p1, pixman_point_fixed_t         * p2, const pixman_gradient_stop_t * stops, int n_stops) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_create_linear_gradient(p1, p2, stops, n_stops) __pixman_image_create_linear_gradient((p1), (p2), (stops), (n_stops))

pixman_image_t * __pixman_image_create_radial_gradient(pixman_point_fixed_t         * inner, pixman_point_fixed_t         * outer, pixman_fixed_t inner_radius, pixman_fixed_t outer_radius, const pixman_gradient_stop_t * stops, int n_stops) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_create_radial_gradient(inner, outer, inner_radius, outer_radius, stops, n_stops) __pixman_image_create_radial_gradient((inner), (outer), (inner_radius), (outer_radius), (stops), (n_stops))

pixman_image_t * __pixman_image_create_conical_gradient(pixman_point_fixed_t         * center, pixman_fixed_t angle, const pixman_gradient_stop_t * stops, int n_stops) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_create_conical_gradient(center, angle, stops, n_stops) __pixman_image_create_conical_gradient((center), (angle), (stops), (n_stops))

pixman_image_t * __pixman_image_create_bits(pixman_format_code_t format, int width, int height, uint32_t                     * bits, int rowstride_bytes) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_create_bits(format, width, height, bits, rowstride_bytes) __pixman_image_create_bits((format), (width), (height), (bits), (rowstride_bytes))

pixman_image_t * __pixman_image_ref(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_ref(image) __pixman_image_ref((image))

pixman_bool_t __pixman_image_unref(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_unref(image) __pixman_image_unref((image))

pixman_bool_t __pixman_image_set_clip_region(pixman_image_t               * image, pixman_region16_t            * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_clip_region(image, region) __pixman_image_set_clip_region((image), (region))

pixman_bool_t __pixman_image_set_clip_region32(pixman_image_t               * image, pixman_region32_t            * region) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_clip_region32(image, region) __pixman_image_set_clip_region32((image), (region))

void __pixman_image_set_has_client_clip(pixman_image_t               * image, pixman_bool_t clien_clip) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_has_client_clip(image, clien_clip) __pixman_image_set_has_client_clip((image), (clien_clip))

pixman_bool_t __pixman_image_set_transform(pixman_image_t               * image, const pixman_transform_t     * transform) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_transform(image, transform) __pixman_image_set_transform((image), (transform))

void __pixman_image_set_repeat(pixman_image_t               * image, pixman_repeat_t repeat) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_repeat(image, repeat) __pixman_image_set_repeat((image), (repeat))

pixman_bool_t __pixman_image_set_filter(pixman_image_t               * image, pixman_filter_t filter, const pixman_fixed_t         * filter_params, int n_filter_params) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_filter(image, filter, filter_params, n_filter_params) __pixman_image_set_filter((image), (filter), (filter_params), (n_filter_params))

void __pixman_image_set_source_clipping(pixman_image_t     * image, pixman_bool_t source_clipping) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_source_clipping(image, source_clipping) __pixman_image_set_source_clipping((image), (source_clipping))

void __pixman_image_set_alpha_map(pixman_image_t               * image, pixman_image_t               * alpha_map, int16_t x, int16_t y) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_alpha_map(image, alpha_map, x, y) __pixman_image_set_alpha_map((image), (alpha_map), (x), (y))

void __pixman_image_set_component_alpha(pixman_image_t               * image, pixman_bool_t component_alpha) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_component_alpha(image, component_alpha) __pixman_image_set_component_alpha((image), (component_alpha))

void __pixman_image_set_accessors(pixman_image_t     * image, pixman_read_memory_func_t read_func, pixman_write_memory_func_t write_func) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_accessors(image, read_func, write_func) __pixman_image_set_accessors((image), (read_func), (write_func))

void __pixman_image_set_indexed(pixman_image_t     * image, const pixman_indexed_t    * indexed) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_indexed(image, indexed) __pixman_image_set_indexed((image), (indexed))

uint32_t       * __pixman_image_get_data(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_data(image) __pixman_image_get_data((image))

int __pixman_image_get_width(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_width(image) __pixman_image_get_width((image))

int __pixman_image_get_height(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_height(image) __pixman_image_get_height((image))

int __pixman_image_get_stride(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_stride(image) __pixman_image_get_stride((image))

int __pixman_image_get_depth(pixman_image_t     * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_depth(image) __pixman_image_get_depth((image))

pixman_bool_t __pixman_image_fill_rectangles(pixman_op_t op, pixman_image_t     * image, pixman_color_t     * color, int n_rects, const pixman_rectangle16_t   * rects) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_fill_rectangles(op, image, color, n_rects, rects) __pixman_image_fill_rectangles((op), (image), (color), (n_rects), (rects))

pixman_bool_t __pixman_compute_composite_region(pixman_region16_t * region, pixman_image_t    * src_image, pixman_image_t    * mask_image, pixman_image_t    * dst_image, int16_t src_x, int16_t src_y, int16_t mask_x, int16_t mask_y, int16_t dest_x, int16_t dest_y, uint16_t width, uint16_t height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_compute_composite_region(region, src_image, mask_image, dst_image, src_x, src_y, mask_x, mask_y, dest_x, dest_y, width, height) __pixman_compute_composite_region((region), (src_image), (mask_image), (dst_image), (src_x), (src_y), (mask_x), (mask_y), (dest_x), (dest_y), (width), (height))

void __pixman_image_composite(pixman_op_t op, pixman_image_t    * src, pixman_image_t    * mask, pixman_image_t    * dest, int16_t src_x, int16_t src_y, int16_t mask_x, int16_t mask_y, int16_t dest_x, int16_t dest_y, uint16_t width, uint16_t height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_composite(op, src, mask, dest, src_x, src_y, mask_x, mask_y, dest_x, dest_y, width, height) __pixman_image_composite((op), (src), (mask), (dest), (src_x), (src_y), (mask_x), (mask_y), (dest_x), (dest_y), (width), (height))

pixman_fixed_t __pixman_sample_ceil_y(pixman_fixed_t y, int bpp) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_sample_ceil_y(y, bpp) __pixman_sample_ceil_y((y), (bpp))

pixman_fixed_t __pixman_sample_floor_y(pixman_fixed_t y, int bpp) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_sample_floor_y(y, bpp) __pixman_sample_floor_y((y), (bpp))

void __pixman_edge_step(pixman_edge_t             * e, int n) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_edge_step(e, n) __pixman_edge_step((e), (n))

void __pixman_edge_init(pixman_edge_t             * e, int bpp, pixman_fixed_t y_start, pixman_fixed_t x_top, pixman_fixed_t y_top, pixman_fixed_t x_bot, pixman_fixed_t y_bot) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_edge_init(e, bpp, y_start, x_top, y_top, x_bot, y_bot) __pixman_edge_init((e), (bpp), (y_start), (x_top), (y_top), (x_bot), (y_bot))

void __pixman_line_fixed_edge_init(pixman_edge_t             * e, int bpp, pixman_fixed_t y, const pixman_line_fixed_t * line, int x_off, int y_off) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_line_fixed_edge_init(e, bpp, y, line, x_off, y_off) __pixman_line_fixed_edge_init((e), (bpp), (y), (line), (x_off), (y_off))

void __pixman_rasterize_edges(pixman_image_t            * image, pixman_edge_t             * l, pixman_edge_t             * r, pixman_fixed_t t, pixman_fixed_t b) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_rasterize_edges(image, l, r, t, b) __pixman_rasterize_edges((image), (l), (r), (t), (b))

void __pixman_add_traps(pixman_image_t            * image, int16_t x_off, int16_t y_off, int ntrap, pixman_trap_t             * traps) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_add_traps(image, x_off, y_off, ntrap, traps) __pixman_add_traps((image), (x_off), (y_off), (ntrap), (traps))

void __pixman_add_trapezoids(pixman_image_t            * image, int16_t x_off, int y_off, int ntraps, const pixman_trapezoid_t  * traps) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_add_trapezoids(image, x_off, y_off, ntraps, traps) __pixman_add_trapezoids((image), (x_off), (y_off), (ntraps), (traps))

void __pixman_rasterize_trapezoid(pixman_image_t            * image, const pixman_trapezoid_t  * trap, int x_off, int y_off) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_rasterize_trapezoid(image, trap, x_off, y_off) __pixman_rasterize_trapezoid((image), (trap), (x_off), (y_off))

void __pixman_image_set_destroy_function(pixman_image_t     * image, pixman_image_destroy_func_t function, void      * data) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_set_destroy_function(image, function, data) __pixman_image_set_destroy_function((image), (function), (data))

void __pixman_region_init_from_image(pixman_region16_t * region, pixman_image_t    * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_init_from_image(region, image) __pixman_region_init_from_image((region), (image))

pixman_bool_t __pixman_region_intersect_rect(pixman_region16_t * dest, pixman_region16_t * source, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region_intersect_rect(dest, source, x, y, width, height) __pixman_region_intersect_rect((dest), (source), (x), (y), (width), (height))

void __pixman_region32_init_from_image(pixman_region32_t * region, pixman_image_t    * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_init_from_image(region, image) __pixman_region32_init_from_image((region), (image))

pixman_bool_t __pixman_region32_intersect_rect(pixman_region32_t * dest, pixman_region32_t * source, int x, int y, unsigned int width, unsigned int height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_region32_intersect_rect(dest, source, x, y, width, height) __pixman_region32_intersect_rect((dest), (source), (x), (y), (width), (height))

void * __pixman_image_get_destroy_data(pixman_image_t     * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_destroy_data(image) __pixman_image_get_destroy_data((image))

pixman_bool_t __pixman_image_get_component_alpha(pixman_image_t               * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_component_alpha(image) __pixman_image_get_component_alpha((image))

pixman_format_code_t __pixman_image_get_format(pixman_image_t     * image) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_get_format(image) __pixman_image_get_format((image))

pixman_bool_t __pixman_image_fill_boxes(pixman_op_t op, pixman_image_t               * dest, pixman_color_t               * color, int n_boxes, const pixman_box32_t         * boxes) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_fill_boxes(op, dest, color, n_boxes, boxes) __pixman_image_fill_boxes((op), (dest), (color), (n_boxes), (boxes))

void __pixman_image_composite32(pixman_op_t op, pixman_image_t    * src, pixman_image_t    * mask, pixman_image_t    * dest, int32_t src_x, int32_t src_y, int32_t mask_x, int32_t mask_y, int32_t dest_x, int32_t dest_y, int32_t width, int32_t height) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_image_composite32(op, src, mask, dest, src_x, src_y, mask_x, mask_y, dest_x, dest_y, width, height) __pixman_image_composite32((op), (src), (mask), (dest), (src_x), (src_y), (mask_x), (mask_y), (dest_x), (dest_y), (width), (height))

void __pixman_composite_trapezoids(pixman_op_t op, pixman_image_t * src, pixman_image_t * dst, pixman_format_code_t mask_format, int x_src, int y_src, int x_dst, int y_dst, int n_traps, const pixman_trapezoid_t * traps) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_composite_trapezoids(op, src, dst, mask_format, x_src, y_src, x_dst, y_dst, n_traps, traps) __pixman_composite_trapezoids((op), (src), (dst), (mask_format), (x_src), (y_src), (x_dst), (y_dst), (n_traps), (traps))

void __pixman_composite_triangles(pixman_op_t op, pixman_image_t * src, pixman_image_t * dst, pixman_format_code_t mask_format, int x_src, int y_src, int x_dst, int y_dst, int n_tris, const pixman_triangle_t * tris) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_composite_triangles(op, src, dst, mask_format, x_src, y_src, x_dst, y_dst, n_tris, tris) __pixman_composite_triangles((op), (src), (dst), (mask_format), (x_src), (y_src), (x_dst), (y_dst), (n_tris), (tris))

void __pixman_add_triangles(pixman_image_t              * image, int32_t x_off, int32_t y_off, int n_tris, const pixman_triangle_t     * tris) =
	"\tlis\t11,PixManBase@ha\n"
	"\tlwz\t12,PixManBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define pixman_add_triangles(image, x_off, y_off, n_tris, tris) __pixman_add_triangles((image), (x_off), (y_off), (n_tris), (tris))

#endif /*  _VBCCINLINE_PIXMAN_H  */

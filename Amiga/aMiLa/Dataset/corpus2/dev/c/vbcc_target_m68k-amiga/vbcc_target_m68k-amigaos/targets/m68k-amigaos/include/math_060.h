/* $VER: math_060.h 1.1 (25.09.2021)
** math.h 68060 specific support, link with -lm060
*/

/* macros */
__regsused("d0/d1/fp0") int fpclassify(__reg("fp0")double) =
        "\tinline\n"
        "\tftst.x\tfp0\n"
        "\tmoveq\t#7,d1\n"
        "\tfmove.l\tfpsr,d0\n"
        "\trol.l\t#8,d0\n"
        "\tand.l\td1,d0\n"
        "\teinline";
__regsused("d0/fp0") int isfinite(__reg("fp0")double) =
        "\tinline\n"
        "\tftst.x\tfp0\n"
        "\tfmove.l\tfpsr,d0\n"
        "\tand.l\t#$03000000,d0\n"
        "\tseq\td0\n"
        "\textb.l\td0\n"
        "\teinline";
__regsused("d0/fp0") int isnormal(__reg("fp0")double) =
        "\tinline\n"
        "\tftst.x\tfp0\n"
        "\tfmove.l\tfpsr,d0\n"
        "\tand.l\t#$07000000,d0\n"
        "\tseq\td0\n"
        "\textb.l\td0\n"
        "\teinline";
__regsused("d0/fp0") int isnan(__reg("fp0")double) =
        "\tinline\n"
        "\tftst.x\tfp0\n"
        "\tmoveq\t#1,d0\n"
        "\tfbun\t.skip\n"
        "\tmoveq\t#0,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/d1/fp0") int isinf(__reg("fp0")double) =
        "\tinline\n"
        "\tftst.x\tfp0\n"
        "\tmoveq\t#1,d0\n"
        "\tfmove.l\tfpsr,d1\n"
        "\trol.l\t#7,d1\n"
        "\tand.l\td1,d0\n"
        "\teinline";
__regsused("d0/d1/fp0") int signbit(__reg("fp0")double) =
        "\tinline\n"
        "\tfmove.s\tfp0,d0\n"
        "\tmoveq\t#31,d1\n"
        "\tasr.l\td1,d0\n"
        "\teinline";
__regsused("d0/fp0/fp1") int isgreater(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#1,d0\n"
        "\tfbogt\t.skip\n"
        "\tmoveq\t#0,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") int isgreaterequal(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#0,d0\n"
        "\tfbult\t.skip\n"
        "\tmoveq\t#1,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") int isless(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#1,d0\n"
        "\tfbolt\t.skip\n"
        "\tmoveq\t#0,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") int islessequal(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#0,d0\n"
        "\tfbugt\t.skip\n"
        "\tmoveq\t#1,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") int islessgreater(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#0,d0\n"
        "\tfbueq\t.skip\n"
        "\tmoveq\t#1,d0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") int isunordered(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tmoveq\t#1,d0\n"
        "\tfbun\t.skip\n"
        "\tmoveq\t#0,d0\n"
        ".skip\n"
        "\teinline";

#ifndef __NOINLINE__
/* faster inline functions */
__regsused("fp0/fp1") __fp0ret double __asm_ceil(__reg("fp0")double) =
        "\tinline\n"
        "\tfmove.x\tfp0,fp1\n"
        "\tfintrz.x\tfp0\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tfboge\t.skip\n"
        "\tfadd.s\t#$3f800000,fp0\n"
        ".skip\n"
        "\teinline";
__regsused("d0/fp0/fp1") __fp0ret double __asm_copysign(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfmove.s\tfp1,d0\n"
        "\tfabs.x\tfp0\n"
        "\ttst.l\td0\n"
        "\tbpl\t.skip\n"
        "\tfneg.x\tfp0\n"
        ".skip\n"
        "\teinline";
__regsused("fp0") __fp0ret double __asm_fabs(__reg("fp0")double) =
        "\tinline\n"
        "\tfabs.x\tfp0\n"
        "\teinline";
__regsused("fp0/fp1") __fp0ret double __asm_fdim(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfsub.x\tfp1,fp0\n"
        "\tfabs.x\tfp0\n"
        "\teinline";
__regsused("fp0/fp1") __fp0ret double __asm_floor(__reg("fp0")double) =
        "\tinline\n"
        "\tfmove.x\tfp0,fp1\n"
        "\tfintrz.x\tfp0\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tfbole\t.skip\n"
        "\tfsub.s\t#$3f800000,fp0\n"
        ".skip\n"
        "\teinline";
__regsused("fp0/fp1/fp2") __fp0ret double __asm_fma(__reg("fp0")double,__reg("fp1")double,__reg("fp2")double) =
        "\tinline\n"
        "\tfmul.x\tfp1,fp0\n"
        "\tfadd.x\tfp2,fp0\n"
        "\teinline";
__regsused("fp0/fp1") __fp0ret double __asm_fmax(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tfboge\t.skip\n"
        "\tftst.x\tfp1\n"
        "\tfbun\t.skip\n"
        "\tfmove.x\tfp1,fp0\n"
        ".skip\n"
        "\teinline";
__regsused("fp0/fp1") __fp0ret double __asm_fmin(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfcmp.x\tfp1,fp0\n"
        "\tfbole\t.skip\n"
        "\tftst.x\tfp1\n"
        "\tfbun\t.skip\n"
        "\tfmove.x\tfp1,fp0\n"
        ".skip\n"
        "\teinline";
__regsused("fp0/fp1") __fp0ret double __asm_hypot(__reg("fp0")double,__reg("fp1")double) =
        "\tinline\n"
        "\tfmul.x\tfp0,fp0\n"
        "\tfmul.x\tfp1,fp1\n"
        "\tfadd.x\tfp1,fp0\n"
        "\tfsqrt.x\tfp0\n"
        "\teinline";
__regsused("d0/fp0") long __asm_lround(__reg("fp0")double) =
        "\tinline\n"
        "\tfmove.s\tfp0,d0\n"
        "\tand.l\t#$80000000,d0\n"
        "\tor.l\t#$3f000000,d0\n"
        "\tfadd.s\td0,fp0\n"
        "\tfintrz.x\tfp0\n"
        "\tfmove.l\tfp0,d0\n"
        "\teinline";
__regsused("fp0") __fp0ret double __asm_nan(__reg("a0")const char *) =
        "\tinline\n"
        "\tfmove.s\t#$7fc00000,fp0\n"
        "\teinline";
__regsused("fp0") __fp0ret double __asm_nearbyint(__reg("fp0")double) =
        "\tinline\n"
        "\tfint.x\tfp0\n"
        "\teinline";
__regsused("d0/fp0") __fp0ret double __asm_round(__reg("fp0")double) =
        "\tinline\n"
        "\tfmove.s\tfp0,d0\n"
        "\tand.l\t#$80000000,d0\n"
        "\tor.l\t#$3f000000,d0\n"
        "\tfadd.s\td0,fp0\n"
        "\tfintrz.x\tfp0\n"
        "\teinline";
__regsused("fp0") __fp0ret double __asm_sqrt(__reg("fp0")double) =
        "\tinline\n"
        "\tfsqrt.x\tfp0\n"
        "\teinline";
__regsused("fp0") __fp0ret double __asm_trunc(__reg("fp0")double) =
        "\tinline\n"
        "\tfintrz.x\tfp0\n"
        "\teinline";

/* double precision */
#define ceil(x) __asm_ceil(x)
#define copysign(x,y) __asm_copysign(x,y)
#define fabs(x) __asm_fabs(x)
#define fdim(x,y) __asm_fdim(x,y)
#define floor(x) __asm_floor(x)
#define fma(x,y) __asm_fma(x,y)
#define fmax(x,y) __asm_fmax(x,y)
#define fmin(x,y) __asm_fmin(x,y)
#define hypot(x,y) __asm_hypot(x,y)
#define lround(x) __asm_lround(x)
#define nan(x) __asm_nan(x)
#define nearbyint(x) __asm_nearbyint(x)
#define round(x) __asm_round(x)
#define sqrt(x) __asm_sqrt(x)
#define trunc(x) __asm_trunc(x)

/* single precision */
#define ceilf(x) __asm_ceil(x)
#define copysignf(x,y) __asm_copysign(x,y)
#define fabsf(x) __asm_fabs(x)
#define fdimf(x,y) __asm_fdim(x,y)
#define floorf(x) __asm_floor(x)
#define fmaf(x,y) __asm_fma(x,y)
#define fmaxf(x,y) __asm_fmax(x,y)
#define fminf(x,y) __asm_fmin(x,y)
#define hypotf(x,y) __asm_hypot(x,y)
#define lroundf(x) __asm_lround(x)
#define nanf(x) __asm_nan(x)
#define nearbyintf(x) __asm_nearbyint(x)
#define roundf(x) __asm_round(x)
#define sqrtf(x) __asm_sqrt(x)
#define truncf(x) __asm_trunc(x)
#endif /* __NOINLINE__ */

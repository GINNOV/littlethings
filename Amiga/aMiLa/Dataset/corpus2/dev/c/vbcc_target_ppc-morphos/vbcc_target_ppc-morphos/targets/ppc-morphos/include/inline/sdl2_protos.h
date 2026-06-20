#ifndef _VBCCINLINE_SDL2_H
#define _VBCCINLINE_SDL2_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __SDL_InitTGL(void *, void ** glcptr, struct Library ** tglptr) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_InitTGL(glcptr, tglptr) __SDL_InitTGL(SDL2Base, (glcptr), (tglptr))

void __SDL_SetExitPointer(void *, void (*exitfunc)(int)) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetExitPointer(exitfunc) __SDL_SetExitPointer(SDL2Base, (exitfunc))

int __SDL_VSetError(const char * fmt, va_list va_list) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_VSetError(fmt, va_list) __SDL_VSetError((fmt), (va_list))

const char * __SDL_GetPlatform() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPlatform() __SDL_GetPlatform()

int __SDL_Init(Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_Init(flags) __SDL_Init((flags))

int __SDL_InitSubSystem(Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_InitSubSystem(flags) __SDL_InitSubSystem((flags))

void __SDL_QuitSubSystem(Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_QuitSubSystem(flags) __SDL_QuitSubSystem((flags))

Uint32 __SDL_WasInit(Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WasInit(flags) __SDL_WasInit((flags))

void __SDL_Quit() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_Quit() __SDL_Quit()

void __SDL_SetMainReady() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetMainReady() __SDL_SetMainReady()

void * __SDL_malloc(size_t size) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_malloc(size) __SDL_malloc((size))

void * __SDL_calloc(size_t nmemb, size_t size) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_calloc(nmemb, size) __SDL_calloc((nmemb), (size))

void * __SDL_realloc(void * mem, size_t size) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_realloc(mem, size) __SDL_realloc((mem), (size))

void __SDL_free(void * mem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_free(mem) __SDL_free((mem))

void __SDL_qsort(void * base, size_t nmemb, size_t size, int (*compare)(const void *, const void *)) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_qsort(base, nmemb, size, compare) __SDL_qsort((base), (nmemb), (size), (compare))

int __SDL_abs(int x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_abs(x) __SDL_abs((x))

int __SDL_isdigit(int x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_isdigit(x) __SDL_isdigit((x))

int __SDL_isspace(int x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_isspace(x) __SDL_isspace((x))

int __SDL_toupper(int x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_toupper(x) __SDL_toupper((x))

int __SDL_tolower(int x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_tolower(x) __SDL_tolower((x))

void * __SDL_memset(void * dst, int c, size_t len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_memset(dst, c, len) __SDL_memset((dst), (c), (len))

void * __SDL_memcpy(void * dst, const void * src, size_t len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_memcpy(dst, src, len) __SDL_memcpy((dst), (src), (len))

void * __SDL_memmove(void * dst, const void * src, size_t len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_memmove(dst, src, len) __SDL_memmove((dst), (src), (len))

int __SDL_memcmp(const void * s1, const void * s2, size_t len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_memcmp(s1, s2, len) __SDL_memcmp((s1), (s2), (len))

size_t __SDL_wcslen(const wchar_t * wstr) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_wcslen(wstr) __SDL_wcslen((wstr))

size_t __SDL_wcslcpy(wchar_t * dst, const wchar_t * src, size_t maxlen) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_wcslcpy(dst, src, maxlen) __SDL_wcslcpy((dst), (src), (maxlen))

size_t __SDL_wcslcat(wchar_t * dst, const wchar_t * src, size_t maxlen) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_wcslcat(dst, src, maxlen) __SDL_wcslcat((dst), (src), (maxlen))

size_t __SDL_strlen(const char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strlen(str) __SDL_strlen((str))

size_t __SDL_strlcpy(char * dst, const char * src, size_t maxlen) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strlcpy(dst, src, maxlen) __SDL_strlcpy((dst), (src), (maxlen))

size_t __SDL_utf8strlcpy(char * dst, const char * src, size_t dst_bytes) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_utf8strlcpy(dst, src, dst_bytes) __SDL_utf8strlcpy((dst), (src), (dst_bytes))

size_t __SDL_strlcat(char * dst, const char * src, size_t maxlen) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strlcat(dst, src, maxlen) __SDL_strlcat((dst), (src), (maxlen))

char * __SDL_strdup(const char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strdup(str) __SDL_strdup((str))

char * __SDL_strrev(char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strrev(str) __SDL_strrev((str))

char * __SDL_strupr(char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strupr(str) __SDL_strupr((str))

char * __SDL_strlwr(char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strlwr(str) __SDL_strlwr((str))

char * __SDL_strchr(const char * str, int c) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strchr(str, c) __SDL_strchr((str), (c))

char * __SDL_strrchr(const char * str, int c) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strrchr(str, c) __SDL_strrchr((str), (c))

char * __SDL_strstr(const char * haystack, const char * needle) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strstr(haystack, needle) __SDL_strstr((haystack), (needle))

char * __SDL_itoa(int value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_itoa(value, str, radix) __SDL_itoa((value), (str), (radix))

char * __SDL_uitoa(unsigned int value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_uitoa(value, str, radix) __SDL_uitoa((value), (str), (radix))

char * __SDL_ltoa(long value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ltoa(value, str, radix) __SDL_ltoa((value), (str), (radix))

char * __SDL_ultoa(unsigned long value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ultoa(value, str, radix) __SDL_ultoa((value), (str), (radix))

char * __SDL_lltoa(Sint64 Sint64value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_lltoa(Sint64value, str, radix) __SDL_lltoa((Sint64value), (str), (radix))

char * __SDL_ulltoa(Uint64 value, char * str, int radix) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ulltoa(value, str, radix) __SDL_ulltoa((value), (str), (radix))

int __SDL_atoi(const char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_atoi(str) __SDL_atoi((str))

double __SDL_atof(const char * str) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_atof(str) __SDL_atof((str))

long __SDL_strtol(const char * str, char ** endp, int base) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strtol(str, endp, base) __SDL_strtol((str), (endp), (base))

unsigned long __SDL_strtoul(const char * str, char ** endp, int base) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strtoul(str, endp, base) __SDL_strtoul((str), (endp), (base))

Sint64 __SDL_strtoll(const char * str, char ** endp, int base) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strtoll(str, endp, base) __SDL_strtoll((str), (endp), (base))

Uint64 __SDL_strtoull(const char * str, char ** endp, int base) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strtoull(str, endp, base) __SDL_strtoull((str), (endp), (base))

double __SDL_strtod(const char * str, char ** endp) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strtod(str, endp) __SDL_strtod((str), (endp))

int __SDL_strcmp(const char * str1, const char * str2) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strcmp(str1, str2) __SDL_strcmp((str1), (str2))

int __SDL_strncmp(const char * str1, const char * str2, size_t maxlen) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strncmp(str1, str2, maxlen) __SDL_strncmp((str1), (str2), (maxlen))

int __SDL_strcasecmp(const char * str1, const char * str2) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strcasecmp(str1, str2) __SDL_strcasecmp((str1), (str2))

int __SDL_strncasecmp(const char * str1, const char * str2, size_t len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_strncasecmp(str1, str2, len) __SDL_strncasecmp((str1), (str2), (len))

int __SDL_vsscanf(const char * text, const char * fmt, va_list ap) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_vsscanf(text, fmt, ap) __SDL_vsscanf((text), (fmt), (ap))

int __SDL_vsnprintf(char * text, size_t maxlen, const char * fmt, va_list ap) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_vsnprintf(text, maxlen, fmt, ap) __SDL_vsnprintf((text), (maxlen), (fmt), (ap))

double __SDL_acos(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_acos(x) __SDL_acos((x))

double __SDL_asin(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_asin(x) __SDL_asin((x))

double __SDL_atan(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_atan(x) __SDL_atan((x))

double __SDL_atan2(double x, double y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_atan2(x, y) __SDL_atan2((x), (y))

double __SDL_ceil(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ceil(x) __SDL_ceil((x))

double __SDL_copysign(double x, double y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_copysign(x, y) __SDL_copysign((x), (y))

double __SDL_cos(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_cos(x) __SDL_cos((x))

float __SDL_cosf(float x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_cosf(x) __SDL_cosf((x))

double __SDL_fabs(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_fabs(x) __SDL_fabs((x))

double __SDL_floor(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_floor(x) __SDL_floor((x))

double __SDL_log(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_log(x) __SDL_log((x))

double __SDL_pow(double x, double y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_pow(x, y) __SDL_pow((x), (y))

double __SDL_scalbn(double x, int n) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_scalbn(x, n) __SDL_scalbn((x), (n))

double __SDL_sin(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_sin(x) __SDL_sin((x))

float __SDL_sinf(float x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_sinf(x) __SDL_sinf((x))

double __SDL_sqrt(double x) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_sqrt(x) __SDL_sqrt((x))

SDL_iconv_t __SDL_iconv_open(const char * tocode, const char * fromcode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_iconv_open(tocode, fromcode) __SDL_iconv_open((tocode), (fromcode))

int __SDL_iconv_close(SDL_iconv_t cd) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_iconv_close(cd) __SDL_iconv_close((cd))

size_t __SDL_iconv(SDL_iconv_t cd, const char ** inbuf, size_t * inbytesleft, char ** outbuf, size_t * outbytesleft) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_iconv(cd, inbuf, inbytesleft, outbuf, outbytesleft) __SDL_iconv((cd), (inbuf), (inbytesleft), (outbuf), (outbytesleft))

char * __SDL_iconv_string(const char * tocode, const char * fromcode, const char * inbuf, size_t inbytesleft) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_iconv_string(tocode, fromcode, inbuf, inbytesleft) __SDL_iconv_string((tocode), (fromcode), (inbuf), (inbytesleft))

SDL_assert_state __SDL_ReportAssertion(SDL_assert_data * a, const char * b, const char * c, int d) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReportAssertion(a, b, c, d) __SDL_ReportAssertion((a), (b), (c), (d))

void __SDL_SetAssertionHandler(SDL_AssertionHandler handler, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetAssertionHandler(handler, userdata) __SDL_SetAssertionHandler((handler), (userdata))

SDL_AssertionHandler __SDL_GetDefaultAssertionHandler() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDefaultAssertionHandler() __SDL_GetDefaultAssertionHandler()

SDL_AssertionHandler __SDL_GetAssertionHandler(void ** puserdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAssertionHandler(puserdata) __SDL_GetAssertionHandler((puserdata))

const SDL_assert_data * __SDL_GetAssertionReport() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAssertionReport() __SDL_GetAssertionReport()

void __SDL_ResetAssertionReport() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ResetAssertionReport() __SDL_ResetAssertionReport()

SDL_bool __SDL_AtomicTryLock(SDL_SpinLock * lock) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicTryLock(lock) __SDL_AtomicTryLock((lock))

void __SDL_AtomicLock(SDL_SpinLock * lock) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicLock(lock) __SDL_AtomicLock((lock))

void __SDL_AtomicUnlock(SDL_SpinLock * lock) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicUnlock(lock) __SDL_AtomicUnlock((lock))

SDL_bool __SDL_AtomicCAS(SDL_atomic_t * a, int oldval, int newval) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicCAS(a, oldval, newval) __SDL_AtomicCAS((a), (oldval), (newval))

int __SDL_AtomicSet(SDL_atomic_t * a, int v) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicSet(a, v) __SDL_AtomicSet((a), (v))

int __SDL_AtomicGet(SDL_atomic_t * a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicGet(a) __SDL_AtomicGet((a))

int __SDL_AtomicAdd(SDL_atomic_t * a, int v) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicAdd(a, v) __SDL_AtomicAdd((a), (v))

SDL_bool __SDL_AtomicCASPtr(void ** a, void * oldval, void * newval) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicCASPtr(a, oldval, newval) __SDL_AtomicCASPtr((a), (oldval), (newval))

void* __SDL_AtomicGetPtr(void ** a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AtomicGetPtr(a) __SDL_AtomicGetPtr((a))

int __SDL_GetNumAudioDrivers() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumAudioDrivers() __SDL_GetNumAudioDrivers()

const char * __SDL_GetAudioDriver(int index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAudioDriver(index) __SDL_GetAudioDriver((index))

int __SDL_AudioInit(const char * driver_name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AudioInit(driver_name) __SDL_AudioInit((driver_name))

void __SDL_AudioQuit() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AudioQuit() __SDL_AudioQuit()

const char * __SDL_GetCurrentAudioDriver() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCurrentAudioDriver() __SDL_GetCurrentAudioDriver()

int __SDL_OpenAudio(SDL_AudioSpec * desired, SDL_AudioSpec * obtained) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_OpenAudio(desired, obtained) __SDL_OpenAudio((desired), (obtained))

int __SDL_GetNumAudioDevices(int iscapture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumAudioDevices(iscapture) __SDL_GetNumAudioDevices((iscapture))

const char * __SDL_GetAudioDeviceName(int index, int iscapture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAudioDeviceName(index, iscapture) __SDL_GetAudioDeviceName((index), (iscapture))

SDL_AudioDeviceID __SDL_OpenAudioDevice(const char * device, int iscapture, const SDL_AudioSpec * desired, SDL_AudioSpec * obtained, int allowed_changes) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_OpenAudioDevice(device, iscapture, desired, obtained, allowed_changes) __SDL_OpenAudioDevice((device), (iscapture), (desired), (obtained), (allowed_changes))

SDL_AudioStatus __SDL_GetAudioStatus() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAudioStatus() __SDL_GetAudioStatus()

SDL_AudioStatus __SDL_GetAudioDeviceStatus(SDL_AudioDeviceID dev) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetAudioDeviceStatus(dev) __SDL_GetAudioDeviceStatus((dev))

void __SDL_PauseAudio(int pause_on) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PauseAudio(pause_on) __SDL_PauseAudio((pause_on))

void __SDL_PauseAudioDevice(SDL_AudioDeviceID dev, int pause_on) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PauseAudioDevice(dev, pause_on) __SDL_PauseAudioDevice((dev), (pause_on))

SDL_AudioSpec * __SDL_LoadWAV_RW(SDL_RWops * src, int freesrc, SDL_AudioSpec * spec, Uint8 ** audio_buf, Uint32 * audio_len) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LoadWAV_RW(src, freesrc, spec, audio_buf, audio_len) __SDL_LoadWAV_RW((src), (freesrc), (spec), (audio_buf), (audio_len))

void __SDL_FreeWAV(Uint8 * audio_buf) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreeWAV(audio_buf) __SDL_FreeWAV((audio_buf))

int __SDL_BuildAudioCVT(SDL_AudioCVT * cvt, SDL_AudioFormat src_format, Uint8 src_channels, int src_rate, SDL_AudioFormat dst_format, Uint8 dst_channels, int dst_rate) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_BuildAudioCVT(cvt, src_format, src_channels, src_rate, dst_format, dst_channels, dst_rate) __SDL_BuildAudioCVT((cvt), (src_format), (src_channels), (src_rate), (dst_format), (dst_channels), (dst_rate))

int __SDL_ConvertAudio(SDL_AudioCVT * cvt) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ConvertAudio(cvt) __SDL_ConvertAudio((cvt))

void __SDL_MixAudio(Uint8 * dst, const Uint8 * src, Uint32 len, int volume) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MixAudio(dst, src, len, volume) __SDL_MixAudio((dst), (src), (len), (volume))

void __SDL_MixAudioFormat(Uint8 * dst, const Uint8 * src, SDL_AudioFormat format, Uint32 len, int volume) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MixAudioFormat(dst, src, format, len, volume) __SDL_MixAudioFormat((dst), (src), (format), (len), (volume))

void __SDL_LockAudio() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LockAudio() __SDL_LockAudio()

void __SDL_LockAudioDevice(SDL_AudioDeviceID SDL_AudioDeviceIDdev) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LockAudioDevice(SDL_AudioDeviceIDdev) __SDL_LockAudioDevice((SDL_AudioDeviceIDdev))

void __SDL_UnlockAudio() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnlockAudio() __SDL_UnlockAudio()

void __SDL_UnlockAudioDevice(SDL_AudioDeviceID SDL_AudioDeviceIDdev) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnlockAudioDevice(SDL_AudioDeviceIDdev) __SDL_UnlockAudioDevice((SDL_AudioDeviceIDdev))

void __SDL_CloseAudio() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CloseAudio() __SDL_CloseAudio()

void __SDL_CloseAudioDevice(SDL_AudioDeviceID SDL_AudioDeviceIDdev) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CloseAudioDevice(SDL_AudioDeviceIDdev) __SDL_CloseAudioDevice((SDL_AudioDeviceIDdev))

int __SDL_SetClipboardText(const char * text) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetClipboardText(text) __SDL_SetClipboardText((text))

char * __SDL_GetClipboardText() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetClipboardText() __SDL_GetClipboardText()

SDL_bool __SDL_HasClipboardText() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasClipboardText() __SDL_HasClipboardText()

int __SDL_GetCPUCount() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCPUCount() __SDL_GetCPUCount()

int __SDL_GetCPUCacheLineSize() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCPUCacheLineSize() __SDL_GetCPUCacheLineSize()

SDL_bool __SDL_HasRDTSC() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasRDTSC() __SDL_HasRDTSC()

SDL_bool __SDL_HasAltiVec() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasAltiVec() __SDL_HasAltiVec()

SDL_bool __SDL_HasMMX() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasMMX() __SDL_HasMMX()

SDL_bool __SDL_Has3DNow() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_Has3DNow() __SDL_Has3DNow()

SDL_bool __SDL_HasSSE() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasSSE() __SDL_HasSSE()

SDL_bool __SDL_HasSSE2() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasSSE2() __SDL_HasSSE2()

SDL_bool __SDL_HasSSE3() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasSSE3() __SDL_HasSSE3()

SDL_bool __SDL_HasSSE41() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasSSE41() __SDL_HasSSE41()

SDL_bool __SDL_HasSSE42() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasSSE42() __SDL_HasSSE42()

SDL_bool __SDL_HasAVX() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasAVX() __SDL_HasAVX()

int __SDL_GetSystemRAM() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetSystemRAM() __SDL_GetSystemRAM()

const char * __SDL_GetError() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetError() __SDL_GetError()

void __SDL_ClearError() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ClearError() __SDL_ClearError()

int __SDL_Error(SDL_errorcode code) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_Error(code) __SDL_Error((code))

void __SDL_PumpEvents() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PumpEvents() __SDL_PumpEvents()

int __SDL_PeepEvents(SDL_Event * events, int numevents, SDL_eventaction SDL_eventactionaction, Uint32 minType, Uint32 maxType) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PeepEvents(events, numevents, SDL_eventactionaction, minType, maxType) __SDL_PeepEvents((events), (numevents), (SDL_eventactionaction), (minType), (maxType))

SDL_bool __SDL_HasEvent(Uint32 type) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasEvent(type) __SDL_HasEvent((type))

SDL_bool __SDL_HasEvents(Uint32 minType, Uint32 maxType) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasEvents(minType, maxType) __SDL_HasEvents((minType), (maxType))

void __SDL_FlushEvent(Uint32 type) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FlushEvent(type) __SDL_FlushEvent((type))

void __SDL_FlushEvents(Uint32 minType, Uint32 maxType) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FlushEvents(minType, maxType) __SDL_FlushEvents((minType), (maxType))

int __SDL_PollEvent(SDL_Event * event) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PollEvent(event) __SDL_PollEvent((event))

int __SDL_WaitEvent(SDL_Event * event) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WaitEvent(event) __SDL_WaitEvent((event))

int __SDL_WaitEventTimeout(SDL_Event * event, int timeout) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WaitEventTimeout(event, timeout) __SDL_WaitEventTimeout((event), (timeout))

int __SDL_PushEvent(SDL_Event * event) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PushEvent(event) __SDL_PushEvent((event))

void __SDL_SetEventFilter(SDL_EventFilter filter, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetEventFilter(filter, userdata) __SDL_SetEventFilter((filter), (userdata))

SDL_bool __SDL_GetEventFilter(SDL_EventFilter * filter, void ** userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetEventFilter(filter, userdata) __SDL_GetEventFilter((filter), (userdata))

void __SDL_AddEventWatch(SDL_EventFilter filter, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AddEventWatch(filter, userdata) __SDL_AddEventWatch((filter), (userdata))

void __SDL_DelEventWatch(SDL_EventFilter filter, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DelEventWatch(filter, userdata) __SDL_DelEventWatch((filter), (userdata))

void __SDL_FilterEvents(SDL_EventFilter filter, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FilterEvents(filter, userdata) __SDL_FilterEvents((filter), (userdata))

Uint8 __SDL_EventState(Uint32 type, int state) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_EventState(type, state) __SDL_EventState((type), (state))

Uint32 __SDL_RegisterEvents(int numevents) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RegisterEvents(numevents) __SDL_RegisterEvents((numevents))

char * __SDL_GetBasePath() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetBasePath() __SDL_GetBasePath()

char * __SDL_GetPrefPath(const char * org, const char * app) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPrefPath(org, app) __SDL_GetPrefPath((org), (app))

int __SDL_NumJoysticks() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_NumJoysticks() __SDL_NumJoysticks()

const char * __SDL_JoystickNameForIndex(int device_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickNameForIndex(device_index) __SDL_JoystickNameForIndex((device_index))

SDL_Joystick * __SDL_JoystickOpen(int device_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickOpen(device_index) __SDL_JoystickOpen((device_index))

const char * __SDL_JoystickName(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickName(joystick) __SDL_JoystickName((joystick))

SDL_JoystickGUID __SDL_JoystickGetDeviceGUID(int device_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetDeviceGUID(device_index) __SDL_JoystickGetDeviceGUID((device_index))

SDL_JoystickGUID __SDL_JoystickGetGUID(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetGUID(joystick) __SDL_JoystickGetGUID((joystick))

void __SDL_JoystickGetGUIDString(SDL_JoystickGUID guid, char * pszGUID, int cbGUID) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetGUIDString(guid, pszGUID, cbGUID) __SDL_JoystickGetGUIDString((guid), (pszGUID), (cbGUID))

SDL_JoystickGUID __SDL_JoystickGetGUIDFromString(const char * pchGUID) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1000(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetGUIDFromString(pchGUID) __SDL_JoystickGetGUIDFromString((pchGUID))

SDL_bool __SDL_JoystickGetAttached(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1006(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetAttached(joystick) __SDL_JoystickGetAttached((joystick))

SDL_JoystickID __SDL_JoystickInstanceID(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1012(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickInstanceID(joystick) __SDL_JoystickInstanceID((joystick))

int __SDL_JoystickNumAxes(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1018(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickNumAxes(joystick) __SDL_JoystickNumAxes((joystick))

int __SDL_JoystickNumBalls(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1024(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickNumBalls(joystick) __SDL_JoystickNumBalls((joystick))

int __SDL_JoystickNumHats(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickNumHats(joystick) __SDL_JoystickNumHats((joystick))

int __SDL_JoystickNumButtons(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickNumButtons(joystick) __SDL_JoystickNumButtons((joystick))

void __SDL_JoystickUpdate() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickUpdate() __SDL_JoystickUpdate()

int __SDL_JoystickEventState(int state) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1048(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickEventState(state) __SDL_JoystickEventState((state))

Sint16 __SDL_JoystickGetAxis(SDL_Joystick * joystick, int axis) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1054(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetAxis(joystick, axis) __SDL_JoystickGetAxis((joystick), (axis))

Uint8 __SDL_JoystickGetHat(SDL_Joystick * joystick, int hat) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetHat(joystick, hat) __SDL_JoystickGetHat((joystick), (hat))

int __SDL_JoystickGetBall(SDL_Joystick * joystick, int ball, int * dx, int * dy) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetBall(joystick, ball, dx, dy) __SDL_JoystickGetBall((joystick), (ball), (dx), (dy))

Uint8 __SDL_JoystickGetButton(SDL_Joystick * joystick, int button) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickGetButton(joystick, button) __SDL_JoystickGetButton((joystick), (button))

void __SDL_JoystickClose(SDL_Joystick * joystick) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_JoystickClose(joystick) __SDL_JoystickClose((joystick))

int __SDL_GameControllerAddMappingsFromRW(SDL_RWops * rw, int freerw) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerAddMappingsFromRW(rw, freerw) __SDL_GameControllerAddMappingsFromRW((rw), (freerw))

int __SDL_GameControllerAddMapping(const char* mappingString) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerAddMapping(mappingString) __SDL_GameControllerAddMapping((mappingString))

char * __SDL_GameControllerMappingForGUID(SDL_JoystickGUID guid) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerMappingForGUID(guid) __SDL_GameControllerMappingForGUID((guid))

char * __SDL_GameControllerMapping(SDL_GameController * gamecontroller) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerMapping(gamecontroller) __SDL_GameControllerMapping((gamecontroller))

SDL_bool __SDL_IsGameController(int joystick_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IsGameController(joystick_index) __SDL_IsGameController((joystick_index))

const char * __SDL_GameControllerNameForIndex(int joystick_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerNameForIndex(joystick_index) __SDL_GameControllerNameForIndex((joystick_index))

SDL_GameController * __SDL_GameControllerOpen(int joystick_index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1120(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerOpen(joystick_index) __SDL_GameControllerOpen((joystick_index))

const char * __SDL_GameControllerName(SDL_GameController * gamecontroller) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1126(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerName(gamecontroller) __SDL_GameControllerName((gamecontroller))

SDL_bool __SDL_GameControllerGetAttached(SDL_GameController * gamecontroller) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1132(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetAttached(gamecontroller) __SDL_GameControllerGetAttached((gamecontroller))

SDL_Joystick * __SDL_GameControllerGetJoystick(SDL_GameController * gamecontroller) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1138(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetJoystick(gamecontroller) __SDL_GameControllerGetJoystick((gamecontroller))

int __SDL_GameControllerEventState(int state) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1144(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerEventState(state) __SDL_GameControllerEventState((state))

void __SDL_GameControllerUpdate() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1150(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerUpdate() __SDL_GameControllerUpdate()

SDL_GameControllerAxis __SDL_GameControllerGetAxisFromString(const char * pchString) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1156(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetAxisFromString(pchString) __SDL_GameControllerGetAxisFromString((pchString))

const char* __SDL_GameControllerGetStringForAxis(SDL_GameControllerAxis axis) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1162(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetStringForAxis(axis) __SDL_GameControllerGetStringForAxis((axis))

SDL_GameControllerButtonBind __SDL_GameControllerGetBindForAxis(SDL_GameController * gamecontroller, SDL_GameControllerAxis axis) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1168(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetBindForAxis(gamecontroller, axis) __SDL_GameControllerGetBindForAxis((gamecontroller), (axis))

Sint16 __SDL_GameControllerGetAxis(SDL_GameController * gamecontroller, SDL_GameControllerAxis axis) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1174(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetAxis(gamecontroller, axis) __SDL_GameControllerGetAxis((gamecontroller), (axis))

SDL_GameControllerButton __SDL_GameControllerGetButtonFromString(const char * pchString) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1180(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetButtonFromString(pchString) __SDL_GameControllerGetButtonFromString((pchString))

const char* __SDL_GameControllerGetStringForButton(SDL_GameControllerButton button) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1186(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetStringForButton(button) __SDL_GameControllerGetStringForButton((button))

SDL_GameControllerButtonBind __SDL_GameControllerGetBindForButton(SDL_GameController * gamecontroller, SDL_GameControllerButton button) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1192(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetBindForButton(gamecontroller, button) __SDL_GameControllerGetBindForButton((gamecontroller), (button))

Uint8 __SDL_GameControllerGetButton(SDL_GameController * gamecontroller, SDL_GameControllerButton button) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1198(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerGetButton(gamecontroller, button) __SDL_GameControllerGetButton((gamecontroller), (button))

void __SDL_GameControllerClose(SDL_GameController * gamecontroller) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1204(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GameControllerClose(gamecontroller) __SDL_GameControllerClose((gamecontroller))

SDL_bool __SDL_SetHintWithPriority(const char * name, const char * value, SDL_HintPriority priority) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1210(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetHintWithPriority(name, value, priority) __SDL_SetHintWithPriority((name), (value), (priority))

SDL_bool __SDL_SetHint(const char * name, const char * value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1216(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetHint(name, value) __SDL_SetHint((name), (value))

const char * __SDL_GetHint(const char * name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1222(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetHint(name) __SDL_GetHint((name))

void __SDL_AddHintCallback(const char * name, SDL_HintCallback callback, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1228(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AddHintCallback(name, callback, userdata) __SDL_AddHintCallback((name), (callback), (userdata))

void __SDL_DelHintCallback(const char * name, SDL_HintCallback callback, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1234(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DelHintCallback(name, callback, userdata) __SDL_DelHintCallback((name), (callback), (userdata))

void __SDL_ClearHints() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1240(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ClearHints() __SDL_ClearHints()

void * __SDL_LoadObject(const char * sofile) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1246(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LoadObject(sofile) __SDL_LoadObject((sofile))

void * __SDL_LoadFunction(void * handle, const char * name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1252(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LoadFunction(handle, name) __SDL_LoadFunction((handle), (name))

void __SDL_UnloadObject(void * handle) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1258(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnloadObject(handle) __SDL_UnloadObject((handle))

void __SDL_LogSetAllPriority(SDL_LogPriority priority) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1264(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogSetAllPriority(priority) __SDL_LogSetAllPriority((priority))

void __SDL_LogSetPriority(int category, SDL_LogPriority priority) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1270(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogSetPriority(category, priority) __SDL_LogSetPriority((category), (priority))

SDL_LogPriority __SDL_LogGetPriority(int category) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1276(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogGetPriority(category) __SDL_LogGetPriority((category))

void __SDL_LogResetPriorities() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1282(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogResetPriorities() __SDL_LogResetPriorities()

void __SDL_LogMessageV(int category, SDL_LogPriority priority, const char * fmt, va_list ap) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1288(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogMessageV(category, priority, fmt, ap) __SDL_LogMessageV((category), (priority), (fmt), (ap))

void __SDL_LogGetOutputFunction(SDL_LogOutputFunction * callback, void ** userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1294(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogGetOutputFunction(callback, userdata) __SDL_LogGetOutputFunction((callback), (userdata))

void __SDL_LogSetOutputFunction(SDL_LogOutputFunction callback, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1300(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LogSetOutputFunction(callback, userdata) __SDL_LogSetOutputFunction((callback), (userdata))

int __SDL_ShowMessageBox(const SDL_MessageBoxData * messageboxdata, int * buttonid) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1306(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ShowMessageBox(messageboxdata, buttonid) __SDL_ShowMessageBox((messageboxdata), (buttonid))

int __SDL_ShowSimpleMessageBox(Uint32 flags, const char * title, const char * message, SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1312(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ShowSimpleMessageBox(flags, title, message, window) __SDL_ShowSimpleMessageBox((flags), (title), (message), (window))

SDL_mutex * __SDL_CreateMutex() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1318(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateMutex() __SDL_CreateMutex()

int __SDL_LockMutex(SDL_mutex * mutex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1324(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LockMutex(mutex) __SDL_LockMutex((mutex))

int __SDL_TryLockMutex(SDL_mutex * mutex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1330(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_TryLockMutex(mutex) __SDL_TryLockMutex((mutex))

int __SDL_UnlockMutex(SDL_mutex * mutex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1336(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnlockMutex(mutex) __SDL_UnlockMutex((mutex))

void __SDL_DestroyMutex(SDL_mutex * mutex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1342(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroyMutex(mutex) __SDL_DestroyMutex((mutex))

SDL_sem * __SDL_CreateSemaphore(Uint32 initial_value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1348(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateSemaphore(initial_value) __SDL_CreateSemaphore((initial_value))

void __SDL_DestroySemaphore(SDL_sem * sem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1354(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroySemaphore(sem) __SDL_DestroySemaphore((sem))

int __SDL_SemWait(SDL_sem * sem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1360(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SemWait(sem) __SDL_SemWait((sem))

int __SDL_SemTryWait(SDL_sem * sem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1366(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SemTryWait(sem) __SDL_SemTryWait((sem))

int __SDL_SemWaitTimeout(SDL_sem * sem, Uint32 ms) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1372(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SemWaitTimeout(sem, ms) __SDL_SemWaitTimeout((sem), (ms))

int __SDL_SemPost(SDL_sem * sem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1378(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SemPost(sem) __SDL_SemPost((sem))

Uint32 __SDL_SemValue(SDL_sem * sem) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1384(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SemValue(sem) __SDL_SemValue((sem))

SDL_cond * __SDL_CreateCond() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1390(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateCond() __SDL_CreateCond()

void __SDL_DestroyCond(SDL_cond * cond) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1396(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroyCond(cond) __SDL_DestroyCond((cond))

int __SDL_CondSignal(SDL_cond * cond) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1402(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CondSignal(cond) __SDL_CondSignal((cond))

int __SDL_CondBroadcast(SDL_cond * cond) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1408(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CondBroadcast(cond) __SDL_CondBroadcast((cond))

int __SDL_CondWait(SDL_cond * cond, SDL_mutex * mutex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1414(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CondWait(cond, mutex) __SDL_CondWait((cond), (mutex))

int __SDL_CondWaitTimeout(SDL_cond * cond, SDL_mutex * mutex, Uint32 ms) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1420(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CondWaitTimeout(cond, mutex, ms) __SDL_CondWaitTimeout((cond), (mutex), (ms))

SDL_PowerState __SDL_GetPowerInfo(int * secs, int * pct) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1426(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPowerInfo(secs, pct) __SDL_GetPowerInfo((secs), (pct))

int __SDL_GetNumRenderDrivers() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1432(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumRenderDrivers() __SDL_GetNumRenderDrivers()

int __SDL_GetRenderDriverInfo(int index, SDL_RendererInfo * info) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1438(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRenderDriverInfo(index, info) __SDL_GetRenderDriverInfo((index), (info))

int __SDL_CreateWindowAndRenderer(int width, int height, Uint32 window_flags, SDL_Window ** window, SDL_Renderer ** renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1444(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateWindowAndRenderer(width, height, window_flags, window, renderer) __SDL_CreateWindowAndRenderer((width), (height), (window_flags), (window), (renderer))

SDL_Renderer * __SDL_CreateRenderer(SDL_Window * window, int index, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1450(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateRenderer(window, index, flags) __SDL_CreateRenderer((window), (index), (flags))

SDL_Renderer * __SDL_CreateSoftwareRenderer(SDL_Surface * surface) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1456(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateSoftwareRenderer(surface) __SDL_CreateSoftwareRenderer((surface))

SDL_Renderer * __SDL_GetRenderer(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1462(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRenderer(window) __SDL_GetRenderer((window))

int __SDL_GetRendererInfo(SDL_Renderer * renderer, SDL_RendererInfo * info) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1468(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRendererInfo(renderer, info) __SDL_GetRendererInfo((renderer), (info))

int __SDL_GetRendererOutputSize(SDL_Renderer * renderer, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1474(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRendererOutputSize(renderer, w, h) __SDL_GetRendererOutputSize((renderer), (w), (h))

SDL_Texture * __SDL_CreateTexture(SDL_Renderer * renderer, Uint32 format, int access, int w, int h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1480(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateTexture(renderer, format, access, w, h) __SDL_CreateTexture((renderer), (format), (access), (w), (h))

SDL_Texture * __SDL_CreateTextureFromSurface(SDL_Renderer * renderer, SDL_Surface * surface) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1486(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateTextureFromSurface(renderer, surface) __SDL_CreateTextureFromSurface((renderer), (surface))

int __SDL_QueryTexture(SDL_Texture * texture, Uint32 * format, int * access, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1492(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_QueryTexture(texture, format, access, w, h) __SDL_QueryTexture((texture), (format), (access), (w), (h))

int __SDL_SetTextureColorMod(SDL_Texture * texture, Uint8 r, Uint8 g, Uint8 b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1498(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetTextureColorMod(texture, r, g, b) __SDL_SetTextureColorMod((texture), (r), (g), (b))

int __SDL_GetTextureColorMod(SDL_Texture * texture, Uint8 * r, Uint8 * g, Uint8 * b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1504(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetTextureColorMod(texture, r, g, b) __SDL_GetTextureColorMod((texture), (r), (g), (b))

int __SDL_SetTextureAlphaMod(SDL_Texture * texture, Uint8 alpha) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1510(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetTextureAlphaMod(texture, alpha) __SDL_SetTextureAlphaMod((texture), (alpha))

int __SDL_GetTextureAlphaMod(SDL_Texture * texture, Uint8 * alpha) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1516(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetTextureAlphaMod(texture, alpha) __SDL_GetTextureAlphaMod((texture), (alpha))

int __SDL_SetTextureBlendMode(SDL_Texture * texture, SDL_BlendMode blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1522(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetTextureBlendMode(texture, blendMode) __SDL_SetTextureBlendMode((texture), (blendMode))

int __SDL_GetTextureBlendMode(SDL_Texture * texture, SDL_BlendMode * blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1528(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetTextureBlendMode(texture, blendMode) __SDL_GetTextureBlendMode((texture), (blendMode))

int __SDL_UpdateTexture(SDL_Texture * texture, const SDL_Rect * rect, const void * pixels, int pitch) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1534(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpdateTexture(texture, rect, pixels, pitch) __SDL_UpdateTexture((texture), (rect), (pixels), (pitch))

int __SDL_UpdateYUVTexture(SDL_Texture * texture, const SDL_Rect * rect, const Uint8 * Yplane, int Ypitch, const Uint8 * Uplane, int Upitch, const Uint8 * Vplane, int Vpitch) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1540(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpdateYUVTexture(texture, rect, Yplane, Ypitch, Uplane, Upitch, Vplane, Vpitch) __SDL_UpdateYUVTexture((texture), (rect), (Yplane), (Ypitch), (Uplane), (Upitch), (Vplane), (Vpitch))

int __SDL_LockTexture(SDL_Texture * texture, const SDL_Rect * rect, void ** pixels, int * pitch) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1546(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LockTexture(texture, rect, pixels, pitch) __SDL_LockTexture((texture), (rect), (pixels), (pitch))

void __SDL_UnlockTexture(SDL_Texture * texture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1552(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnlockTexture(texture) __SDL_UnlockTexture((texture))

SDL_bool __SDL_RenderTargetSupported(SDL_Renderer * renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1558(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderTargetSupported(renderer) __SDL_RenderTargetSupported((renderer))

int __SDL_SetRenderTarget(SDL_Renderer * renderer, SDL_Texture * texture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1564(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetRenderTarget(renderer, texture) __SDL_SetRenderTarget((renderer), (texture))

SDL_Texture * __SDL_GetRenderTarget(SDL_Renderer * renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1570(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRenderTarget(renderer) __SDL_GetRenderTarget((renderer))

int __SDL_RenderSetLogicalSize(SDL_Renderer * renderer, int w, int h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1576(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderSetLogicalSize(renderer, w, h) __SDL_RenderSetLogicalSize((renderer), (w), (h))

void __SDL_RenderGetLogicalSize(SDL_Renderer * renderer, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1582(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderGetLogicalSize(renderer, w, h) __SDL_RenderGetLogicalSize((renderer), (w), (h))

int __SDL_RenderSetViewport(SDL_Renderer * renderer, const SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1588(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderSetViewport(renderer, rect) __SDL_RenderSetViewport((renderer), (rect))

void __SDL_RenderGetViewport(SDL_Renderer * renderer, SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1594(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderGetViewport(renderer, rect) __SDL_RenderGetViewport((renderer), (rect))

int __SDL_RenderSetClipRect(SDL_Renderer * renderer, const SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1600(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderSetClipRect(renderer, rect) __SDL_RenderSetClipRect((renderer), (rect))

void __SDL_RenderGetClipRect(SDL_Renderer * renderer, SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1606(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderGetClipRect(renderer, rect) __SDL_RenderGetClipRect((renderer), (rect))

int __SDL_RenderSetScale(SDL_Renderer * renderer, float scaleX, float scaleY) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1612(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderSetScale(renderer, scaleX, scaleY) __SDL_RenderSetScale((renderer), (scaleX), (scaleY))

void __SDL_RenderGetScale(SDL_Renderer * renderer, float * scaleX, float * scaleY) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1618(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderGetScale(renderer, scaleX, scaleY) __SDL_RenderGetScale((renderer), (scaleX), (scaleY))

int __SDL_SetRenderDrawColor(SDL_Renderer * renderer, Uint8 r, Uint8 g, Uint8 b, Uint8 a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1624(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetRenderDrawColor(renderer, r, g, b, a) __SDL_SetRenderDrawColor((renderer), (r), (g), (b), (a))

int __SDL_GetRenderDrawColor(SDL_Renderer * renderer, Uint8 * r, Uint8 * g, Uint8 * b, Uint8 * a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1630(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRenderDrawColor(renderer, r, g, b, a) __SDL_GetRenderDrawColor((renderer), (r), (g), (b), (a))

int __SDL_SetRenderDrawBlendMode(SDL_Renderer * renderer, SDL_BlendMode blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1636(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetRenderDrawBlendMode(renderer, blendMode) __SDL_SetRenderDrawBlendMode((renderer), (blendMode))

int __SDL_GetRenderDrawBlendMode(SDL_Renderer * renderer, SDL_BlendMode * blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1642(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRenderDrawBlendMode(renderer, blendMode) __SDL_GetRenderDrawBlendMode((renderer), (blendMode))

int __SDL_RenderClear(SDL_Renderer * renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1648(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderClear(renderer) __SDL_RenderClear((renderer))

int __SDL_RenderDrawPoint(SDL_Renderer * renderer, int x, int y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1654(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawPoint(renderer, x, y) __SDL_RenderDrawPoint((renderer), (x), (y))

int __SDL_RenderDrawPoints(SDL_Renderer * renderer, const SDL_Point * points, int count) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1660(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawPoints(renderer, points, count) __SDL_RenderDrawPoints((renderer), (points), (count))

int __SDL_RenderDrawLine(SDL_Renderer * renderer, int x1, int y1, int x2, int y2) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1666(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawLine(renderer, x1, y1, x2, y2) __SDL_RenderDrawLine((renderer), (x1), (y1), (x2), (y2))

int __SDL_RenderDrawLines(SDL_Renderer * renderer, const SDL_Point * points, int count) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1672(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawLines(renderer, points, count) __SDL_RenderDrawLines((renderer), (points), (count))

int __SDL_RenderDrawRect(SDL_Renderer * renderer, const SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1678(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawRect(renderer, rect) __SDL_RenderDrawRect((renderer), (rect))

int __SDL_RenderDrawRects(SDL_Renderer * renderer, const SDL_Rect * rects, int count) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1684(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderDrawRects(renderer, rects, count) __SDL_RenderDrawRects((renderer), (rects), (count))

int __SDL_RenderFillRect(SDL_Renderer * renderer, const SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1690(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderFillRect(renderer, rect) __SDL_RenderFillRect((renderer), (rect))

int __SDL_RenderFillRects(SDL_Renderer * renderer, const SDL_Rect * rects, int count) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1696(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderFillRects(renderer, rects, count) __SDL_RenderFillRects((renderer), (rects), (count))

int __SDL_RenderCopy(SDL_Renderer * renderer, SDL_Texture * texture, const SDL_Rect * srcrect, const SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1702(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderCopy(renderer, texture, srcrect, dstrect) __SDL_RenderCopy((renderer), (texture), (srcrect), (dstrect))

int __SDL_RenderCopyEx(SDL_Renderer * renderer, SDL_Texture * texture, const SDL_Rect * srcrect, const SDL_Rect * dstrect, const double angle, const SDL_Point * center, const SDL_RendererFlip flip) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1708(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderCopyEx(renderer, texture, srcrect, dstrect, angle, center, flip) __SDL_RenderCopyEx((renderer), (texture), (srcrect), (dstrect), (angle), (center), (flip))

int __SDL_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect, Uint32 format, void * pixels, int pitch) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1714(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderReadPixels(renderer, rect, format, pixels, pitch) __SDL_RenderReadPixels((renderer), (rect), (format), (pixels), (pitch))

void __SDL_RenderPresent(SDL_Renderer * renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1720(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RenderPresent(renderer) __SDL_RenderPresent((renderer))

void __SDL_DestroyTexture(SDL_Texture * texture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1726(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroyTexture(texture) __SDL_DestroyTexture((texture))

void __SDL_DestroyRenderer(SDL_Renderer * renderer) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1732(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroyRenderer(renderer) __SDL_DestroyRenderer((renderer))

int __SDL_GL_BindTexture(SDL_Texture * texture, float * texw, float * texh) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1738(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GL_BindTexture(texture, texw, texh) __SDL_GL_BindTexture((texture), (texw), (texh))

int __SDL_GL_UnbindTexture(SDL_Texture * texture) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1744(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GL_UnbindTexture(texture) __SDL_GL_UnbindTexture((texture))

SDL_RWops * __SDL_RWFromFile(const char * file, const char * mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1750(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RWFromFile(file, mode) __SDL_RWFromFile((file), (mode))

SDL_RWops * __SDL_RWFromFP_clib(void * fp, int autoclose, Sint64 (*size)(struct SDL_RWops *), Sint64 (*seek)(struct SDL_RWops *, Sint64, int), size_t (*read)(struct SDL_RWops *, void *, size_t, size_t), size_t (*write)(struct SDL_RWops *, const void *, size_t, size_t), int (*close)(struct SDL_RWops *)) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1756(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RWFromFP_clib(fp, autoclose, size, seek, read, write, close) __SDL_RWFromFP_clib((fp), (autoclose), (size), (seek), (read), (write), (close))

SDL_RWops * __SDL_RWFromMem(void * mem, int size) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1762(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RWFromMem(mem, size) __SDL_RWFromMem((mem), (size))

SDL_RWops * __SDL_RWFromConstMem(const void * mem, int size) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1768(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RWFromConstMem(mem, size) __SDL_RWFromConstMem((mem), (size))

SDL_RWops * __SDL_AllocRW() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1774(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AllocRW() __SDL_AllocRW()

void __SDL_FreeRW(SDL_RWops * area) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1780(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreeRW(area) __SDL_FreeRW((area))

Uint8 __SDL_ReadU8(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1786(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadU8(src) __SDL_ReadU8((src))

Uint16 __SDL_ReadLE16(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1792(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadLE16(src) __SDL_ReadLE16((src))

Uint16 __SDL_ReadBE16(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1798(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadBE16(src) __SDL_ReadBE16((src))

Uint32 __SDL_ReadLE32(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1804(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadLE32(src) __SDL_ReadLE32((src))

Uint32 __SDL_ReadBE32(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1810(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadBE32(src) __SDL_ReadBE32((src))

Uint64 __SDL_ReadLE64(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1816(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadLE64(src) __SDL_ReadLE64((src))

Uint64 __SDL_ReadBE64(SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1822(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ReadBE64(src) __SDL_ReadBE64((src))

size_t __SDL_WriteU8(SDL_RWops * dst, Uint8 svalue) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1828(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteU8(dst, svalue) __SDL_WriteU8((dst), (svalue))

size_t __SDL_WriteLE16(SDL_RWops * dst, Uint16 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1834(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteLE16(dst, value) __SDL_WriteLE16((dst), (value))

size_t __SDL_WriteBE16(SDL_RWops * dst, Uint16 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1840(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteBE16(dst, value) __SDL_WriteBE16((dst), (value))

size_t __SDL_WriteLE32(SDL_RWops * dst, Uint32 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1846(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteLE32(dst, value) __SDL_WriteLE32((dst), (value))

size_t __SDL_WriteBE32(SDL_RWops * dst, Uint32 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1852(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteBE32(dst, value) __SDL_WriteBE32((dst), (value))

size_t __SDL_WriteLE64(SDL_RWops * dst, Uint64 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1858(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteLE64(dst, value) __SDL_WriteLE64((dst), (value))

size_t __SDL_WriteBE64(SDL_RWops * dst, Uint64 value) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1864(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WriteBE64(dst, value) __SDL_WriteBE64((dst), (value))

SDL_Thread * __SDL_CreateThread(SDL_ThreadFunction fn, const char * name, void * data) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1870(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateThread(fn, name, data) __SDL_CreateThread((fn), (name), (data))

const char * __SDL_GetThreadName(SDL_Thread * thread) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1876(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetThreadName(thread) __SDL_GetThreadName((thread))

SDL_threadID __SDL_ThreadID() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1882(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ThreadID() __SDL_ThreadID()

SDL_threadID __SDL_GetThreadID(SDL_Thread * thread) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1888(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetThreadID(thread) __SDL_GetThreadID((thread))

int __SDL_SetThreadPriority(SDL_ThreadPriority priority) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1894(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetThreadPriority(priority) __SDL_SetThreadPriority((priority))

void __SDL_WaitThread(SDL_Thread * thread, int * status) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1900(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WaitThread(thread, status) __SDL_WaitThread((thread), (status))

void __SDL_DetachThread(SDL_Thread * thread) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1906(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DetachThread(thread) __SDL_DetachThread((thread))

SDL_TLSID __SDL_TLSCreate() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1912(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_TLSCreate() __SDL_TLSCreate()

void * __SDL_TLSGet(SDL_TLSID id) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1918(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_TLSGet(id) __SDL_TLSGet((id))

int __SDL_TLSSet(SDL_TLSID id, const void * value, void (*destructor)(void*)) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1924(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_TLSSet(id, value, destructor) __SDL_TLSSet((id), (value), (destructor))

Uint32 __SDL_GetTicks() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1930(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetTicks() __SDL_GetTicks()

Uint64 __SDL_GetPerformanceCounter() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1936(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPerformanceCounter() __SDL_GetPerformanceCounter()

Uint64 __SDL_GetPerformanceFrequency() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1942(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPerformanceFrequency() __SDL_GetPerformanceFrequency()

void __SDL_Delay(Uint32 ms) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1948(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_Delay(ms) __SDL_Delay((ms))

SDL_TimerID __SDL_AddTimer(Uint32 interval, SDL_TimerCallback (callback)(unsigned long), void * param) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1954(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AddTimer(interval, callback, param) __SDL_AddTimer((interval), (callback), (param))

SDL_bool __SDL_RemoveTimer(SDL_TimerID id) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1960(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RemoveTimer(id) __SDL_RemoveTimer((id))

void __SDL_GetVersion(SDL_version * ver) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1966(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetVersion(ver) __SDL_GetVersion((ver))

const char * __SDL_GetRevision() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1972(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRevision() __SDL_GetRevision()

int __SDL_GetRevisionNumber() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1978(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRevisionNumber() __SDL_GetRevisionNumber()

int __SDL_GetNumVideoDrivers() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1984(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumVideoDrivers() __SDL_GetNumVideoDrivers()

const char * __SDL_GetVideoDriver(int index) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1990(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetVideoDriver(index) __SDL_GetVideoDriver((index))

int __SDL_VideoInit(const char * driver_name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-1996(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_VideoInit(driver_name) __SDL_VideoInit((driver_name))

void __SDL_VideoQuit() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2002(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_VideoQuit() __SDL_VideoQuit()

const char * __SDL_GetCurrentVideoDriver() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2008(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCurrentVideoDriver() __SDL_GetCurrentVideoDriver()

int __SDL_GetNumVideoDisplays() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2014(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumVideoDisplays() __SDL_GetNumVideoDisplays()

const char * __SDL_GetDisplayName(int displayIndex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2020(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDisplayName(displayIndex) __SDL_GetDisplayName((displayIndex))

int __SDL_GetDisplayBounds(int displayIndex, SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2026(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDisplayBounds(displayIndex, rect) __SDL_GetDisplayBounds((displayIndex), (rect))

int __SDL_GetNumDisplayModes(int displayIndex) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2032(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetNumDisplayModes(displayIndex) __SDL_GetNumDisplayModes((displayIndex))

int __SDL_GetDisplayMode(int displayIndex, int modeIndex, SDL_DisplayMode * mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2038(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDisplayMode(displayIndex, modeIndex, mode) __SDL_GetDisplayMode((displayIndex), (modeIndex), (mode))

int __SDL_GetDesktopDisplayMode(int displayIndex, SDL_DisplayMode * mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2044(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDesktopDisplayMode(displayIndex, mode) __SDL_GetDesktopDisplayMode((displayIndex), (mode))

int __SDL_GetCurrentDisplayMode(int displayIndex, SDL_DisplayMode * mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2050(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCurrentDisplayMode(displayIndex, mode) __SDL_GetCurrentDisplayMode((displayIndex), (mode))

SDL_DisplayMode * __SDL_GetClosestDisplayMode(int displayIndex, const SDL_DisplayMode * mode, SDL_DisplayMode * closest) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2056(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetClosestDisplayMode(displayIndex, mode, closest) __SDL_GetClosestDisplayMode((displayIndex), (mode), (closest))

int __SDL_GetWindowDisplayIndex(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2062(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowDisplayIndex(window) __SDL_GetWindowDisplayIndex((window))

int __SDL_SetWindowDisplayMode(SDL_Window * window, const SDL_DisplayMode * SDL_DisplayModemode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2068(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowDisplayMode(window, SDL_DisplayModemode) __SDL_SetWindowDisplayMode((window), (SDL_DisplayModemode))

int __SDL_GetWindowDisplayMode(SDL_Window * window, SDL_DisplayMode * SDL_DisplayModemode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2074(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowDisplayMode(window, SDL_DisplayModemode) __SDL_GetWindowDisplayMode((window), (SDL_DisplayModemode))

Uint32 __SDL_GetWindowPixelFormat(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2080(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowPixelFormat(window) __SDL_GetWindowPixelFormat((window))

SDL_Window * __SDL_CreateWindow(const char * title, int x, int y, int w, int h, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2086(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateWindow(title, x, y, w, h, flags) __SDL_CreateWindow((title), (x), (y), (w), (h), (flags))

SDL_Window * __SDL_CreateWindowFrom(const void * data) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2092(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateWindowFrom(data) __SDL_CreateWindowFrom((data))

Uint32 __SDL_GetWindowID(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2098(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowID(window) __SDL_GetWindowID((window))

SDL_Window * __SDL_GetWindowFromID(Uint32 id) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2104(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowFromID(id) __SDL_GetWindowFromID((id))

Uint32 __SDL_GetWindowFlags(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2110(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowFlags(window) __SDL_GetWindowFlags((window))

void __SDL_SetWindowTitle(SDL_Window * window, const char * title) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2116(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowTitle(window, title) __SDL_SetWindowTitle((window), (title))

const char * __SDL_GetWindowTitle(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2122(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowTitle(window) __SDL_GetWindowTitle((window))

void __SDL_SetWindowIcon(SDL_Window * window, SDL_Surface * icon) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2128(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowIcon(window, icon) __SDL_SetWindowIcon((window), (icon))

void* __SDL_SetWindowData(SDL_Window * window, const char * name, void * userdata) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2134(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowData(window, name, userdata) __SDL_SetWindowData((window), (name), (userdata))

void * __SDL_GetWindowData(SDL_Window * window, const char * name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2140(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowData(window, name) __SDL_GetWindowData((window), (name))

void __SDL_SetWindowPosition(SDL_Window * window, int x, int y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2146(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowPosition(window, x, y) __SDL_SetWindowPosition((window), (x), (y))

void __SDL_GetWindowPosition(SDL_Window * window, int * x, int * y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2152(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowPosition(window, x, y) __SDL_GetWindowPosition((window), (x), (y))

void __SDL_SetWindowSize(SDL_Window * window, int w, int h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2158(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowSize(window, w, h) __SDL_SetWindowSize((window), (w), (h))

void __SDL_GetWindowSize(SDL_Window * window, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2164(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowSize(window, w, h) __SDL_GetWindowSize((window), (w), (h))

void __SDL_SetWindowMinimumSize(SDL_Window * window, int min_w, int min_h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2170(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowMinimumSize(window, min_w, min_h) __SDL_SetWindowMinimumSize((window), (min_w), (min_h))

void __SDL_GetWindowMinimumSize(SDL_Window * window, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2176(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowMinimumSize(window, w, h) __SDL_GetWindowMinimumSize((window), (w), (h))

void __SDL_SetWindowMaximumSize(SDL_Window * window, int max_w, int max_h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2182(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowMaximumSize(window, max_w, max_h) __SDL_SetWindowMaximumSize((window), (max_w), (max_h))

void __SDL_GetWindowMaximumSize(SDL_Window * window, int * w, int * h) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2188(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowMaximumSize(window, w, h) __SDL_GetWindowMaximumSize((window), (w), (h))

void __SDL_SetWindowBordered(SDL_Window * window, SDL_bool bordered) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2194(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowBordered(window, bordered) __SDL_SetWindowBordered((window), (bordered))

void __SDL_ShowWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2200(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ShowWindow(window) __SDL_ShowWindow((window))

void __SDL_HideWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2206(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HideWindow(window) __SDL_HideWindow((window))

void __SDL_RaiseWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2212(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RaiseWindow(window) __SDL_RaiseWindow((window))

void __SDL_MaximizeWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2218(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MaximizeWindow(window) __SDL_MaximizeWindow((window))

void __SDL_MinimizeWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2224(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MinimizeWindow(window) __SDL_MinimizeWindow((window))

void __SDL_RestoreWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2230(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RestoreWindow(window) __SDL_RestoreWindow((window))

int __SDL_SetWindowFullscreen(SDL_Window * window, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2236(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowFullscreen(window, flags) __SDL_SetWindowFullscreen((window), (flags))

SDL_Surface * __SDL_GetWindowSurface(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2242(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowSurface(window) __SDL_GetWindowSurface((window))

int __SDL_UpdateWindowSurface(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2248(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpdateWindowSurface(window) __SDL_UpdateWindowSurface((window))

int __SDL_UpdateWindowSurfaceRects(SDL_Window * window, const SDL_Rect * rects, int numrects) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2254(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpdateWindowSurfaceRects(window, rects, numrects) __SDL_UpdateWindowSurfaceRects((window), (rects), (numrects))

void __SDL_SetWindowGrab(SDL_Window * window, SDL_bool grabbed) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2260(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowGrab(window, grabbed) __SDL_SetWindowGrab((window), (grabbed))

SDL_bool __SDL_GetWindowGrab(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2266(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowGrab(window) __SDL_GetWindowGrab((window))

int __SDL_SetWindowBrightness(SDL_Window * window, float brightness) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2272(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowBrightness(window, brightness) __SDL_SetWindowBrightness((window), (brightness))

float __SDL_GetWindowBrightness(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2278(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowBrightness(window) __SDL_GetWindowBrightness((window))

int __SDL_SetWindowGammaRamp(SDL_Window * window, const Uint16 * red, const Uint16 * green, const Uint16 * blue) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2284(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowGammaRamp(window, red, green, blue) __SDL_SetWindowGammaRamp((window), (red), (green), (blue))

int __SDL_GetWindowGammaRamp(SDL_Window * window, Uint16 * red, Uint16 * green, Uint16 * blue) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2290(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowGammaRamp(window, red, green, blue) __SDL_GetWindowGammaRamp((window), (red), (green), (blue))

void __SDL_DestroyWindow(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2296(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DestroyWindow(window) __SDL_DestroyWindow((window))

SDL_bool __SDL_IsScreenSaverEnabled() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2302(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IsScreenSaverEnabled() __SDL_IsScreenSaverEnabled()

void __SDL_EnableScreenSaver() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2308(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_EnableScreenSaver() __SDL_EnableScreenSaver()

void __SDL_DisableScreenSaver() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2314(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_DisableScreenSaver() __SDL_DisableScreenSaver()

SDL_Window * __SDL_GetKeyboardFocus() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2320(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetKeyboardFocus() __SDL_GetKeyboardFocus()

const Uint8 * __SDL_GetKeyboardState(int * numkeys) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2326(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetKeyboardState(numkeys) __SDL_GetKeyboardState((numkeys))

SDL_Keymod __SDL_GetModState() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2332(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetModState() __SDL_GetModState()

void __SDL_SetModState(SDL_Keymod modstate) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2338(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetModState(modstate) __SDL_SetModState((modstate))

SDL_Keycode __SDL_GetKeyFromScancode(SDL_Scancode scancode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2344(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetKeyFromScancode(scancode) __SDL_GetKeyFromScancode((scancode))

SDL_Scancode __SDL_GetScancodeFromKey(SDL_Keycode key) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2350(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetScancodeFromKey(key) __SDL_GetScancodeFromKey((key))

const char * __SDL_GetScancodeName(SDL_Scancode scancode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2356(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetScancodeName(scancode) __SDL_GetScancodeName((scancode))

SDL_Scancode __SDL_GetScancodeFromName(const char * name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2362(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetScancodeFromName(name) __SDL_GetScancodeFromName((name))

const char * __SDL_GetKeyName(SDL_Keycode key) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2368(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetKeyName(key) __SDL_GetKeyName((key))

SDL_Keycode __SDL_GetKeyFromName(const char * name) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2374(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetKeyFromName(name) __SDL_GetKeyFromName((name))

void __SDL_StartTextInput() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2380(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_StartTextInput() __SDL_StartTextInput()

SDL_bool __SDL_IsTextInputActive() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2386(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IsTextInputActive() __SDL_IsTextInputActive()

void __SDL_StopTextInput() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2392(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_StopTextInput() __SDL_StopTextInput()

void __SDL_SetTextInputRect(SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2398(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetTextInputRect(rect) __SDL_SetTextInputRect((rect))

SDL_bool __SDL_HasScreenKeyboardSupport() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2404(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasScreenKeyboardSupport() __SDL_HasScreenKeyboardSupport()

SDL_bool __SDL_IsScreenKeyboardShown(SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2410(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IsScreenKeyboardShown(window) __SDL_IsScreenKeyboardShown((window))

SDL_Surface * __SDL_CreateRGBSurface(Uint32 flags, int width, int height, int depth, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2416(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, Amask) __SDL_CreateRGBSurface((flags), (width), (height), (depth), (Rmask), (Gmask), (Bmask), (Amask))

SDL_Surface * __SDL_CreateRGBSurfaceFrom(void * pixels, int width, int height, int depth, int pitch, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2422(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateRGBSurfaceFrom(pixels, width, height, depth, pitch, Rmask, Gmask, Bmask, Amask) __SDL_CreateRGBSurfaceFrom((pixels), (width), (height), (depth), (pitch), (Rmask), (Gmask), (Bmask), (Amask))

void __SDL_FreeSurface(SDL_Surface * surface) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2428(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreeSurface(surface) __SDL_FreeSurface((surface))

int __SDL_SetSurfacePalette(SDL_Surface * surface, SDL_Palette * palette) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2434(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetSurfacePalette(surface, palette) __SDL_SetSurfacePalette((surface), (palette))

int __SDL_LockSurface(SDL_Surface * surface) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2440(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LockSurface(surface) __SDL_LockSurface((surface))

void __SDL_UnlockSurface(SDL_Surface * surface) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2446(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnlockSurface(surface) __SDL_UnlockSurface((surface))

SDL_Surface * __SDL_LoadBMP_RW(SDL_RWops * src, int freesrc) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2452(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LoadBMP_RW(src, freesrc) __SDL_LoadBMP_RW((src), (freesrc))

int __SDL_SaveBMP_RW(SDL_Surface * surface, SDL_RWops * dst, int freedst) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2458(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SaveBMP_RW(surface, dst, freedst) __SDL_SaveBMP_RW((surface), (dst), (freedst))

int __SDL_SetSurfaceRLE(SDL_Surface * surface, int flag) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2464(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetSurfaceRLE(surface, flag) __SDL_SetSurfaceRLE((surface), (flag))

int __SDL_SetColorKey(SDL_Surface * surface, int flag, Uint32 key) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2470(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetColorKey(surface, flag, key) __SDL_SetColorKey((surface), (flag), (key))

int __SDL_GetColorKey(SDL_Surface * surface, Uint32 * key) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2476(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetColorKey(surface, key) __SDL_GetColorKey((surface), (key))

int __SDL_SetSurfaceColorMod(SDL_Surface * surface, Uint8 r, Uint8 g, Uint8 b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2482(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetSurfaceColorMod(surface, r, g, b) __SDL_SetSurfaceColorMod((surface), (r), (g), (b))

int __SDL_GetSurfaceColorMod(SDL_Surface * surface, Uint8 * r, Uint8 * g, Uint8 * b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2488(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetSurfaceColorMod(surface, r, g, b) __SDL_GetSurfaceColorMod((surface), (r), (g), (b))

int __SDL_SetSurfaceAlphaMod(SDL_Surface * surface, Uint8 alpha) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2494(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetSurfaceAlphaMod(surface, alpha) __SDL_SetSurfaceAlphaMod((surface), (alpha))

int __SDL_GetSurfaceAlphaMod(SDL_Surface * surface, Uint8 * alpha) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2500(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetSurfaceAlphaMod(surface, alpha) __SDL_GetSurfaceAlphaMod((surface), (alpha))

int __SDL_SetSurfaceBlendMode(SDL_Surface * surface, SDL_BlendMode blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2506(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetSurfaceBlendMode(surface, blendMode) __SDL_SetSurfaceBlendMode((surface), (blendMode))

int __SDL_GetSurfaceBlendMode(SDL_Surface * surface, SDL_BlendMode * blendMode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2512(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetSurfaceBlendMode(surface, blendMode) __SDL_GetSurfaceBlendMode((surface), (blendMode))

SDL_bool __SDL_SetClipRect(SDL_Surface * surface, const SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2518(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetClipRect(surface, rect) __SDL_SetClipRect((surface), (rect))

void __SDL_GetClipRect(SDL_Surface * surface, SDL_Rect * rect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2524(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetClipRect(surface, rect) __SDL_GetClipRect((surface), (rect))

SDL_Surface * __SDL_ConvertSurface(SDL_Surface * src, const SDL_PixelFormat * fmt, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2530(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ConvertSurface(src, fmt, flags) __SDL_ConvertSurface((src), (fmt), (flags))

SDL_Surface * __SDL_ConvertSurfaceFormat(SDL_Surface * src, Uint32 pixel_format, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2536(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ConvertSurfaceFormat(src, pixel_format, flags) __SDL_ConvertSurfaceFormat((src), (pixel_format), (flags))

int __SDL_ConvertPixels(int width, int height, Uint32 src_format, const void * src, int src_pitch, Uint32 dst_format, void * dst, int dst_pitch) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2542(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ConvertPixels(width, height, src_format, src, src_pitch, dst_format, dst, dst_pitch) __SDL_ConvertPixels((width), (height), (src_format), (src), (src_pitch), (dst_format), (dst), (dst_pitch))

int __SDL_FillRect(SDL_Surface * dst, const SDL_Rect * rect, Uint32 color) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2548(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FillRect(dst, rect, color) __SDL_FillRect((dst), (rect), (color))

int __SDL_FillRects(SDL_Surface * dst, const SDL_Rect * rects, int count, Uint32 color) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2554(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FillRects(dst, rects, count, color) __SDL_FillRects((dst), (rects), (count), (color))

int __SDL_UpperBlit(SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2560(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpperBlit(src, srcrect, dst, dstrect) __SDL_UpperBlit((src), (srcrect), (dst), (dstrect))

int __SDL_LowerBlit(SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2566(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LowerBlit(src, srcrect, dst, dstrect) __SDL_LowerBlit((src), (srcrect), (dst), (dstrect))

int __SDL_SoftStretch(SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, const SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2572(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SoftStretch(src, srcrect, dst, dstrect) __SDL_SoftStretch((src), (srcrect), (dst), (dstrect))

int __SDL_UpperBlitScaled(SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2578(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UpperBlitScaled(src, srcrect, dst, dstrect) __SDL_UpperBlitScaled((src), (srcrect), (dst), (dstrect))

int __SDL_LowerBlitScaled(SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2584(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LowerBlitScaled(src, srcrect, dst, dstrect) __SDL_LowerBlitScaled((src), (srcrect), (dst), (dstrect))

SDL_Window * __SDL_GetMouseFocus() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2590(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetMouseFocus() __SDL_GetMouseFocus()

Uint32 __SDL_GetMouseState(int * x, int * y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2596(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetMouseState(x, y) __SDL_GetMouseState((x), (y))

Uint32 __SDL_GetRelativeMouseState(int * x, int * y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2602(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRelativeMouseState(x, y) __SDL_GetRelativeMouseState((x), (y))

void __SDL_WarpMouseInWindow(SDL_Window * window, int x, int y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2608(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_WarpMouseInWindow(window, x, y) __SDL_WarpMouseInWindow((window), (x), (y))

int __SDL_SetRelativeMouseMode(SDL_bool enabled) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2614(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetRelativeMouseMode(enabled) __SDL_SetRelativeMouseMode((enabled))

SDL_bool __SDL_GetRelativeMouseMode() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2620(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRelativeMouseMode() __SDL_GetRelativeMouseMode()

SDL_Cursor * __SDL_CreateCursor(const Uint8 * data, const Uint8 * mask, int w, int h, int hot_x, int hot_y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2626(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateCursor(data, mask, w, h, hot_x, hot_y) __SDL_CreateCursor((data), (mask), (w), (h), (hot_x), (hot_y))

SDL_Cursor * __SDL_CreateColorCursor(SDL_Surface * surface, int hot_x, int hot_y) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2632(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateColorCursor(surface, hot_x, hot_y) __SDL_CreateColorCursor((surface), (hot_x), (hot_y))

SDL_Cursor * __SDL_CreateSystemCursor(SDL_SystemCursor id) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2638(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateSystemCursor(id) __SDL_CreateSystemCursor((id))

void __SDL_SetCursor(SDL_Cursor * cursor) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2644(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetCursor(cursor) __SDL_SetCursor((cursor))

SDL_Cursor * __SDL_GetCursor() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2650(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetCursor() __SDL_GetCursor()

SDL_Cursor * __SDL_GetDefaultCursor() =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2656(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetDefaultCursor() __SDL_GetDefaultCursor()

void __SDL_FreeCursor(SDL_Cursor * cursor) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2662(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreeCursor(cursor) __SDL_FreeCursor((cursor))

int __SDL_ShowCursor(int toggle) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2668(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_ShowCursor(toggle) __SDL_ShowCursor((toggle))

const char * __SDL_GetPixelFormatName(Uint32 format) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2674(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetPixelFormatName(format) __SDL_GetPixelFormatName((format))

SDL_bool __SDL_PixelFormatEnumToMasks(Uint32 format, int * bpp, Uint32 * Rmask, Uint32 * Gmask, Uint32 * Bmask, Uint32 * Amask) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2680(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_PixelFormatEnumToMasks(format, bpp, Rmask, Gmask, Bmask, Amask) __SDL_PixelFormatEnumToMasks((format), (bpp), (Rmask), (Gmask), (Bmask), (Amask))

Uint32 __SDL_MasksToPixelFormatEnum(int bpp, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2686(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MasksToPixelFormatEnum(bpp, Rmask, Gmask, Bmask, Amask) __SDL_MasksToPixelFormatEnum((bpp), (Rmask), (Gmask), (Bmask), (Amask))

SDL_PixelFormat * __SDL_AllocFormat(Uint32 pixel_format) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2692(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AllocFormat(pixel_format) __SDL_AllocFormat((pixel_format))

void __SDL_FreeFormat(SDL_PixelFormat * format) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2698(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreeFormat(format) __SDL_FreeFormat((format))

SDL_Palette * __SDL_AllocPalette(int ncolors) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2704(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_AllocPalette(ncolors) __SDL_AllocPalette((ncolors))

int __SDL_SetPixelFormatPalette(SDL_PixelFormat * format, SDL_Palette * palette) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2710(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetPixelFormatPalette(format, palette) __SDL_SetPixelFormatPalette((format), (palette))

int __SDL_SetPaletteColors(SDL_Palette * palette, const SDL_Color * colors, int firstcolor, int ncolors) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2716(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetPaletteColors(palette, colors, firstcolor, ncolors) __SDL_SetPaletteColors((palette), (colors), (firstcolor), (ncolors))

void __SDL_FreePalette(SDL_Palette * palette) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2722(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_FreePalette(palette) __SDL_FreePalette((palette))

Uint32 __SDL_MapRGB(const SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2728(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MapRGB(format, r, g, b) __SDL_MapRGB((format), (r), (g), (b))

Uint32 __SDL_MapRGBA(const SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b, Uint8 a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2734(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_MapRGBA(format, r, g, b, a) __SDL_MapRGBA((format), (r), (g), (b), (a))

void __SDL_GetRGB(Uint32 pixel, const SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2740(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRGB(pixel, format, r, g, b) __SDL_GetRGB((pixel), (format), (r), (g), (b))

void __SDL_GetRGBA(Uint32 pixel, const SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b, Uint8 * a) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2746(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetRGBA(pixel, format, r, g, b, a) __SDL_GetRGBA((pixel), (format), (r), (g), (b), (a))

void __SDL_CalculateGammaRamp(float gamma, Uint16 * ramp) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2752(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CalculateGammaRamp(gamma, ramp) __SDL_CalculateGammaRamp((gamma), (ramp))

SDL_bool __SDL_HasIntersection(const SDL_Rect * A, const SDL_Rect * B) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2758(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_HasIntersection(A, B) __SDL_HasIntersection((A), (B))

SDL_bool __SDL_IntersectRect(const SDL_Rect * A, const SDL_Rect * B, SDL_Rect * result) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2764(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IntersectRect(A, B, result) __SDL_IntersectRect((A), (B), (result))

void __SDL_UnionRect(const SDL_Rect * A, const SDL_Rect * B, SDL_Rect * result) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2770(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_UnionRect(A, B, result) __SDL_UnionRect((A), (B), (result))

SDL_bool __SDL_EnclosePoints(const SDL_Point * points, int count, const SDL_Rect * clip, SDL_Rect * result) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2776(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_EnclosePoints(points, count, clip, result) __SDL_EnclosePoints((points), (count), (clip), (result))

SDL_bool __SDL_IntersectRectAndLine(const SDL_Rect * rect, int * X1, int * Y1, int * X2, int * Y2) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2782(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IntersectRectAndLine(rect, X1, Y1, X2, Y2) __SDL_IntersectRectAndLine((rect), (X1), (Y1), (X2), (Y2))

SDL_bool __SDL_GetWindowWMInfo(SDL_Window * window, SDL_SysWMinfo * info) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2788(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetWindowWMInfo(window, info) __SDL_GetWindowWMInfo((window), (info))

int __SDL_RecordGesture(SDL_TouchID touchId) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2794(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_RecordGesture(touchId) __SDL_RecordGesture((touchId))

int __SDL_SaveAllDollarTemplates(SDL_RWops * dst) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2800(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SaveAllDollarTemplates(dst) __SDL_SaveAllDollarTemplates((dst))

int __SDL_SaveDollarTemplate(SDL_GestureID gestureId, SDL_RWops * dst) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2806(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SaveDollarTemplate(gestureId, dst) __SDL_SaveDollarTemplate((gestureId), (dst))

int __SDL_LoadDollarTemplates(SDL_TouchID touchId, SDL_RWops * src) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2812(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_LoadDollarTemplates(touchId, src) __SDL_LoadDollarTemplates((touchId), (src))

SDL_Window * __SDL_CreateShapedWindow(const char * title, unsigned int x, unsigned int y, unsigned int w, unsigned int h, Uint32 flags) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2818(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_CreateShapedWindow(title, x, y, w, h, flags) __SDL_CreateShapedWindow((title), (x), (y), (w), (h), (flags))

SDL_bool __SDL_IsShapedWindow(const SDL_Window * window) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2824(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_IsShapedWindow(window) __SDL_IsShapedWindow((window))

int __SDL_SetWindowShape(SDL_Window * window, SDL_Surface * shape, SDL_WindowShapeMode * shape_mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2830(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_SetWindowShape(window, shape, shape_mode) __SDL_SetWindowShape((window), (shape), (shape_mode))

int __SDL_GetShapedWindowMode(SDL_Window * window, SDL_WindowShapeMode * shape_mode) =
	"\tlis\t11,SDL2Base@ha\n"
	"\tlwz\t12,SDL2Base@l(11)\n"
	"\tlwz\t0,-2836(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SDL_GetShapedWindowMode(window, shape_mode) __SDL_GetShapedWindowMode((window), (shape_mode))

#endif /*  _VBCCINLINE_SDL2_H  */

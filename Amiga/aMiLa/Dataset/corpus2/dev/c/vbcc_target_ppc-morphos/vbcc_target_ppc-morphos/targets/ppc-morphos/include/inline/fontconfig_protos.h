#ifndef _VBCCINLINE_FONTCONFIG_H
#define _VBCCINLINE_FONTCONFIG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

FcBlanks * __FcBlanksCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcBlanksCreate() __FcBlanksCreate()

void __FcBlanksDestroy(FcBlanks * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcBlanksDestroy(b) __FcBlanksDestroy((b))

FcBool __FcBlanksAdd(FcBlanks * a, FcChar32 b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcBlanksAdd(a, b) __FcBlanksAdd((a), (b))

FcBool __FcBlanksIsMember(FcBlanks * a, FcChar32 b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcBlanksIsMember(a, b) __FcBlanksIsMember((a), (b))

const FcChar8 * __FcCacheDir(const FcCache * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheDir(b) __FcCacheDir((b))

FcFontSet * __FcCacheCopySet(const FcCache * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheCopySet(b) __FcCacheCopySet((b))

const FcChar8 * __FcCacheSubdir(const FcCache * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheSubdir(a, b) __FcCacheSubdir((a), (b))

int __FcCacheNumSubdir(const FcCache * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheNumSubdir(b) __FcCacheNumSubdir((b))

int __FcCacheNumFont(const FcCache * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheNumFont(b) __FcCacheNumFont((b))

FcBool __FcDirCacheUnlink(const FcChar8 * a, FcConfig * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheUnlink(a, b) __FcDirCacheUnlink((a), (b))

FcBool __FcDirCacheValid(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheValid(a) __FcDirCacheValid((a))

FcChar8 * __FcConfigHome() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigHome() __FcConfigHome()

FcBool __FcConfigEnableHome(FcBool a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigEnableHome(a) __FcConfigEnableHome((a))

FcChar8 * __FcConfigFilename(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigFilename(a) __FcConfigFilename((a))

FcConfig * __FcConfigCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigCreate() __FcConfigCreate()

FcConfig * __FcConfigReference(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigReference(a) __FcConfigReference((a))

void __FcConfigDestroy(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigDestroy(a) __FcConfigDestroy((a))

FcBool __FcConfigSetCurrent(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigSetCurrent(a) __FcConfigSetCurrent((a))

FcConfig * __FcConfigGetCurrent() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetCurrent() __FcConfigGetCurrent()

FcBool __FcConfigUptoDate(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigUptoDate(a) __FcConfigUptoDate((a))

FcBool __FcConfigBuildFonts(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigBuildFonts(a) __FcConfigBuildFonts((a))

FcStrList * __FcConfigGetFontDirs(FcConfig   * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetFontDirs(a) __FcConfigGetFontDirs((a))

FcStrList * __FcConfigGetConfigDirs(FcConfig   * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetConfigDirs(a) __FcConfigGetConfigDirs((a))

FcStrList * __FcConfigGetConfigFiles(FcConfig    * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetConfigFiles(a) __FcConfigGetConfigFiles((a))

FcChar8 * __FcConfigGetCache(FcConfig  * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetCache(a) __FcConfigGetCache((a))

FcBlanks * __FcConfigGetBlanks(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetBlanks(a) __FcConfigGetBlanks((a))

FcStrList * __FcConfigGetCacheDirs(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetCacheDirs(a) __FcConfigGetCacheDirs((a))

int __FcConfigGetRescanInterval(FcConfig * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetRescanInterval(a) __FcConfigGetRescanInterval((a))

FcBool __FcConfigSetRescanInterval(FcConfig * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigSetRescanInterval(a, b) __FcConfigSetRescanInterval((a), (b))

void __FcConfigAppFontClear(FcConfig     * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigAppFontClear(a) __FcConfigAppFontClear((a))

FcCharSet* __FcCharSetCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetCreate() __FcCharSetCreate()

void __FcCharSetDestroy(FcCharSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetDestroy(a) __FcCharSetDestroy((a))

FcCharSet* __FcCharSetCopy(FcCharSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetCopy(a) __FcCharSetCopy((a))

FcBool __FcCharSetEqual(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetEqual(a, b) __FcCharSetEqual((a), (b))

FcCharSet* __FcCharSetIntersect(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetIntersect(a, b) __FcCharSetIntersect((a), (b))

FcCharSet* __FcCharSetUnion(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetUnion(a, b) __FcCharSetUnion((a), (b))

FcCharSet* __FcCharSetSubtract(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetSubtract(a, b) __FcCharSetSubtract((a), (b))

FcBool __FcCharSetMerge(FcCharSet * a, const FcCharSet * b, FcBool * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetMerge(a, b, c) __FcCharSetMerge((a), (b), (c))

FcBool __FcCharSetHasChar(const FcCharSet * a, FcChar32 b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetHasChar(a, b) __FcCharSetHasChar((a), (b))

FcChar32 __FcCharSetCount(const FcCharSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetCount(a) __FcCharSetCount((a))

FcChar32 __FcCharSetIntersectCount(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetIntersectCount(a, b) __FcCharSetIntersectCount((a), (b))

FcChar32 __FcCharSetSubtractCount(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetSubtractCount(a, b) __FcCharSetSubtractCount((a), (b))

FcBool __FcCharSetIsSubset(const FcCharSet * a, const FcCharSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetIsSubset(a, b) __FcCharSetIsSubset((a), (b))

void __FcValuePrint(const FcValue a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcValuePrint(a) __FcValuePrint((a))

void __FcPatternPrint(const FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternPrint(a) __FcPatternPrint((a))

void __FcFontSetPrint(const FcFontSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFontSetPrint(a) __FcFontSetPrint((a))

void __FcDefaultSubstitute(FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDefaultSubstitute(a) __FcDefaultSubstitute((a))

FcBool __FcFileIsDir(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFileIsDir(a) __FcFileIsDir((a))

FcBool __FcDirSave(FcFontSet * a, FcStrSet * b, const FcChar8 * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirSave(a, b, c) __FcDirSave((a), (b), (c))

FcCache * __FcDirCacheLoad(const FcChar8 * a, FcConfig * b, FcChar8 ** c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheLoad(a, b, c) __FcDirCacheLoad((a), (b), (c))

FcCache * __FcDirCacheRead(const FcChar8 * a, FcBool b, FcConfig * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheRead(a, b, c) __FcDirCacheRead((a), (b), (c))

void __FcDirCacheUnload(FcCache * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheUnload(a) __FcDirCacheUnload((a))

FcPattern * __FcFreeTypeQuery(const FcChar8 * a, int b, FcBlanks * c, int * d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFreeTypeQuery(a, b, c, d) __FcFreeTypeQuery((a), (b), (c), (d))

FcFontSet * __FcFontSetCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFontSetCreate() __FcFontSetCreate()

void __FcFontSetDestroy(FcFontSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFontSetDestroy(a) __FcFontSetDestroy((a))

FcBool __FcFontSetAdd(FcFontSet * a, FcPattern * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFontSetAdd(a, b) __FcFontSetAdd((a), (b))

FcConfig * __FcInitLoadConfig() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcInitLoadConfig() __FcInitLoadConfig()

FcConfig * __FcInitLoadConfigAndFonts() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcInitLoadConfigAndFonts() __FcInitLoadConfigAndFonts()

FcBool __FcInit() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcInit() __FcInit()

void __FcFini() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFini() __FcFini()

int __FcGetVersion() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcGetVersion() __FcGetVersion()

FcBool __FcInitReinitialize() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcInitReinitialize() __FcInitReinitialize()

FcBool __FcInitBringUptoDate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcInitBringUptoDate() __FcInitBringUptoDate()

FcStrSet * __FcGetLangs() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcGetLangs() __FcGetLangs()

const FcCharSet * __FcLangGetCharSet(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangGetCharSet(a) __FcLangGetCharSet((a))

FcLangSet * __FcLangSetCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetCreate() __FcLangSetCreate()

void __FcLangSetDestroy(FcLangSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetDestroy(a) __FcLangSetDestroy((a))

FcLangSet* __FcLangSetCopy(const FcLangSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetCopy(a) __FcLangSetCopy((a))

FcBool __FcLangSetAdd(FcLangSet * ls, const FcChar8 * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetAdd(ls, lang) __FcLangSetAdd((ls), (lang))

FcLangResult __FcLangSetHasLang(const FcLangSet * ls, const FcChar8 * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetHasLang(ls, lang) __FcLangSetHasLang((ls), (lang))

FcLangResult __FcLangSetCompare(const FcLangSet * ls, const FcLangSet * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetCompare(ls, lang) __FcLangSetCompare((ls), (lang))

FcBool __FcLangSetContains(const FcLangSet * ls, const FcLangSet * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetContains(ls, lang) __FcLangSetContains((ls), (lang))

FcBool __FcLangSetEqual(const FcLangSet * ls, const FcLangSet * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetEqual(ls, lang) __FcLangSetEqual((ls), (lang))

FcChar32 __FcLangSetHash(const FcLangSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetHash(a) __FcLangSetHash((a))

FcStrSet * __FcLangSetGetLangs(const FcLangSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetGetLangs(a) __FcLangSetGetLangs((a))

FcObjectSet * __FcObjectSetCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcObjectSetCreate() __FcObjectSetCreate()

FcBool __FcObjectSetAdd(FcObjectSet * a, const char * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcObjectSetAdd(a, b) __FcObjectSetAdd((a), (b))

void __FcObjectSetDestroy(FcObjectSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcObjectSetDestroy(a) __FcObjectSetDestroy((a))

FcObjectSet * __FcObjectSetVaBuild(const char * a, va_list va) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcObjectSetVaBuild(a, va) __FcObjectSetVaBuild((a), (va))

FcAtomic * __FcAtomicCreate(const FcChar8   * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicCreate(a) __FcAtomicCreate((a))

FcBool __FcAtomicLock(FcAtomic * atomic) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicLock(atomic) __FcAtomicLock((atomic))

FcChar8 * __FcAtomicNewFile(FcAtomic * atomic) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicNewFile(atomic) __FcAtomicNewFile((atomic))

FcChar8 * __FcAtomicOrigFile(FcAtomic * atomic) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicOrigFile(atomic) __FcAtomicOrigFile((atomic))

FcBool __FcAtomicReplaceOrig(FcAtomic * atomic) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicReplaceOrig(atomic) __FcAtomicReplaceOrig((atomic))

void __FcAtomicDeleteNew(FcAtomic * atomic) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicDeleteNew(atomic) __FcAtomicDeleteNew((atomic))

void __FcAtomicUnlock(FcAtomic * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicUnlock(a) __FcAtomicUnlock((a))

void __FcAtomicDestroy(FcAtomic * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcAtomicDestroy(a) __FcAtomicDestroy((a))

void __FcFontSetSortDestroy(FcFontSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcFontSetSortDestroy(a) __FcFontSetSortDestroy((a))

FcMatrix * __FcMatrixCopy(const FcMatrix * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixCopy(a) __FcMatrixCopy((a))

FcBool __FcMatrixEqual(const FcMatrix * a, const FcMatrix * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixEqual(a, b) __FcMatrixEqual((a), (b))

void __FcMatrixMultiply(FcMatrix * a, const FcMatrix * b, const FcMatrix * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixMultiply(a, b, c) __FcMatrixMultiply((a), (b), (c))

void __FcMatrixRotate(FcMatrix * a, double b, double c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixRotate(a, b, c) __FcMatrixRotate((a), (b), (c))

void __FcMatrixScale(FcMatrix * a, double b, double c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixScale(a, b, c) __FcMatrixScale((a), (b), (c))

void __FcMatrixShear(FcMatrix * a, double b, double c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcMatrixShear(a, b, c) __FcMatrixShear((a), (b), (c))

FcBool __FcNameRegisterObjectTypes(const FcObjectType * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameRegisterObjectTypes(a, b) __FcNameRegisterObjectTypes((a), (b))

FcBool __FcNameUnregisterObjectTypes(const FcObjectType * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameUnregisterObjectTypes(a, b) __FcNameUnregisterObjectTypes((a), (b))

const FcObjectType * __FcNameGetObjectType(const char * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameGetObjectType(a) __FcNameGetObjectType((a))

FcBool __FcNameRegisterConstants(const FcConstant * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameRegisterConstants(a, b) __FcNameRegisterConstants((a), (b))

FcBool __FcNameUnregisterConstants(const FcConstant * a, int b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameUnregisterConstants(a, b) __FcNameUnregisterConstants((a), (b))

const FcConstant * __FcNameGetConstant(FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameGetConstant(a) __FcNameGetConstant((a))

FcBool __FcNameConstant(FcChar8 * a, int * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameConstant(a, b) __FcNameConstant((a), (b))

FcPattern * __FcNameParse(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameParse(a) __FcNameParse((a))

FcChar8 * __FcNameUnparse(FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcNameUnparse(a) __FcNameUnparse((a))

FcPattern * __FcPatternCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternCreate() __FcPatternCreate()

FcPattern * __FcPatternDuplicate(const FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternDuplicate(a) __FcPatternDuplicate((a))

void __FcPatternReference(FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternReference(a) __FcPatternReference((a))

FcPattern * __FcPatternFilter(FcPattern * a, const FcObjectSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternFilter(a, b) __FcPatternFilter((a), (b))

void __FcValueDestroy(FcValue a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcValueDestroy(a) __FcValueDestroy((a))

FcBool __FcValueEqual(FcValue a, FcValue b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcValueEqual(a, b) __FcValueEqual((a), (b))

FcValue __FcValueSave(FcValue a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcValueSave(a) __FcValueSave((a))

void __FcPatternDestroy(FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternDestroy(a) __FcPatternDestroy((a))

FcBool __FcPatternEqual(const FcPattern * a, const FcPattern * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternEqual(a, b) __FcPatternEqual((a), (b))

FcBool __FcPatternEqualSubset(const FcPattern * a, const FcPattern * b, const FcObjectSet * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternEqualSubset(a, b, c) __FcPatternEqualSubset((a), (b), (c))

FcChar32 __FcPatternHash(const FcPattern * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternHash(a) __FcPatternHash((a))

FcBool __FcPatternAdd(FcPattern * a, const char * b, FcValue c, FcBool d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAdd(a, b, c, d) __FcPatternAdd((a), (b), (c), (d))

FcBool __FcPatternAddWeak(FcPattern * a, const char * b, FcValue c, FcBool d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddWeak(a, b, c, d) __FcPatternAddWeak((a), (b), (c), (d))

FcResult __FcPatternGet(const FcPattern * a, const char * b, int c, FcValue * d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGet(a, b, c, d) __FcPatternGet((a), (b), (c), (d))

FcBool __FcPatternDel(FcPattern * a, const char * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternDel(a, b) __FcPatternDel((a), (b))

FcBool __FcPatternRemove(FcPattern * a, const char * b, int c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternRemove(a, b, c) __FcPatternRemove((a), (b), (c))

FcBool __FcPatternAddInteger(FcPattern * a, const char * b, int c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddInteger(a, b, c) __FcPatternAddInteger((a), (b), (c))

FcBool __FcPatternAddDouble(FcPattern * a, const char * b, double c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddDouble(a, b, c) __FcPatternAddDouble((a), (b), (c))

FcBool __FcPatternAddString(FcPattern * a, const char * b, const FcChar8 * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddString(a, b, c) __FcPatternAddString((a), (b), (c))

FcBool __FcPatternAddMatrix(FcPattern * a, const char * b, const FcMatrix * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddMatrix(a, b, c) __FcPatternAddMatrix((a), (b), (c))

FcBool __FcPatternAddCharSet(FcPattern * a, const char * b, const FcCharSet * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddCharSet(a, b, c) __FcPatternAddCharSet((a), (b), (c))

FcBool __FcPatternAddBool(FcPattern * a, const char * b, FcBool c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddBool(a, b, c) __FcPatternAddBool((a), (b), (c))

FcBool __FcPatternAddLangSet(FcPattern * a, const char * b, const FcLangSet * c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternAddLangSet(a, b, c) __FcPatternAddLangSet((a), (b), (c))

FcResult __FcPatternGetInteger(const FcPattern * a, const char * b, int c, int * d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetInteger(a, b, c, d) __FcPatternGetInteger((a), (b), (c), (d))

FcResult __FcPatternGetDouble(const FcPattern * a, const char * b, int c, double * d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetDouble(a, b, c, d) __FcPatternGetDouble((a), (b), (c), (d))

FcResult __FcPatternGetString(const FcPattern * a, const char * b, int c, FcChar8 ** d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetString(a, b, c, d) __FcPatternGetString((a), (b), (c), (d))

FcResult __FcPatternGetMatrix(const FcPattern * a, const char * b, int c, FcMatrix ** d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetMatrix(a, b, c, d) __FcPatternGetMatrix((a), (b), (c), (d))

FcResult __FcPatternGetCharSet(const FcPattern * a, const char * b, int c, FcCharSet ** d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetCharSet(a, b, c, d) __FcPatternGetCharSet((a), (b), (c), (d))

FcResult __FcPatternGetBool(const FcPattern * a, const char * b, int c, FcBool * d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetBool(a, b, c, d) __FcPatternGetBool((a), (b), (c), (d))

FcResult __FcPatternGetLangSet(const FcPattern * a, const char * b, int c, FcLangSet ** d) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternGetLangSet(a, b, c, d) __FcPatternGetLangSet((a), (b), (c), (d))

FcPattern * __FcPatternVaBuild(FcPattern * a, va_list va) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternVaBuild(a, va) __FcPatternVaBuild((a), (va))

FcChar8 * __FcPatternFormat(FcPattern * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternFormat(a, b) __FcPatternFormat((a), (b))

FcChar8 * __FcStrCopy(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrCopy(a) __FcStrCopy((a))

FcChar8 * __FcStrCopyFilename(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrCopyFilename(a) __FcStrCopyFilename((a))

FcChar8 * __FcStrPlus(const FcChar8 * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrPlus(a, b) __FcStrPlus((a), (b))

void __FcStrFree(FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrFree(a) __FcStrFree((a))

FcChar8 * __FcStrDowncase(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrDowncase(a) __FcStrDowncase((a))

int __FcStrCmpIgnoreCase(const FcChar8 * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrCmpIgnoreCase(a, b) __FcStrCmpIgnoreCase((a), (b))

int __FcStrCmp(const FcChar8 * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrCmp(a, b) __FcStrCmp((a), (b))

const FcChar8 * __FcStrStrIgnoreCase(const FcChar8 * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrStrIgnoreCase(a, b) __FcStrStrIgnoreCase((a), (b))

const FcChar8 * __FcStrStr(const FcChar8 * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrStr(a, b) __FcStrStr((a), (b))

FcChar8 * __FcStrDirname(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrDirname(a) __FcStrDirname((a))

FcChar8 * __FcStrBasename(const FcChar8 * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrBasename(a) __FcStrBasename((a))

FcStrSet * __FcStrSetCreate() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetCreate() __FcStrSetCreate()

FcBool __FcStrSetMember(FcStrSet * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1048(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetMember(a, b) __FcStrSetMember((a), (b))

FcBool __FcStrSetEqual(FcStrSet * a, FcStrSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1054(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetEqual(a, b) __FcStrSetEqual((a), (b))

FcBool __FcStrSetAdd(FcStrSet * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetAdd(a, b) __FcStrSetAdd((a), (b))

FcBool __FcStrSetAddFilename(FcStrSet * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetAddFilename(a, b) __FcStrSetAddFilename((a), (b))

FcBool __FcStrSetDel(FcStrSet * a, const FcChar8 * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetDel(a, b) __FcStrSetDel((a), (b))

void __FcStrSetDestroy(FcStrSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrSetDestroy(a) __FcStrSetDestroy((a))

FcStrList * __FcStrListCreate(FcStrSet * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrListCreate(a) __FcStrListCreate((a))

FcChar8 * __FcStrListNext(FcStrList * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrListNext(a) __FcStrListNext((a))

void __FcStrListDone(FcStrList * a) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcStrListDone(a) __FcStrListDone((a))

FcBool __FcConfigParseAndLoad(FcConfig * a, const FcChar8 * b, FcBool c) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigParseAndLoad(a, b, c) __FcConfigParseAndLoad((a), (b), (c))

FcObjectSet * __FcObjectSetBuild(const char * first, ...) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcObjectSetBuild(...) __FcObjectSetBuild(__VA_ARGS__)

FcPattern * __FcPatternBuild(FcPattern * p, ...) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcPatternBuild(...) __FcPatternBuild(__VA_ARGS__)

void __FcExtInsertProgressCallback(FcExtProgressCallback callback) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1156(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcExtInsertProgressCallback(callback) __FcExtInsertProgressCallback((callback))

void __FcExtRemoveProgressCallback(FcExtProgressCallback callback) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1162(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcExtRemoveProgressCallback(callback) __FcExtRemoveProgressCallback((callback))

FcBool __FcCharSetDelChar(FcCharSet * fcs, FcChar32 ucs4) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1168(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCharSetDelChar(fcs, ucs4) __FcCharSetDelChar((fcs), (ucs4))

FcBool __FcLangSetDel(FcLangSet * ls, const FcChar8 * lang) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1174(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetDel(ls, lang) __FcLangSetDel((ls), (lang))

FcLangSet * __FcLangSetUnion(const FcLangSet * a, const FcLangSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1180(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetUnion(a, b) __FcLangSetUnion((a), (b))

FcLangSet * __FcLangSetSubtract(const FcLangSet * a, const FcLangSet * b) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1186(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcLangSetSubtract(a, b) __FcLangSetSubtract((a), (b))

FcBool __FcDirCacheClean(const FcChar8 * cache_dir, FcBool verbose) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1192(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheClean(cache_dir, verbose) __FcDirCacheClean((cache_dir), (verbose))

void __FcCacheCreateTagFile(const FcConfig * config) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1198(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcCacheCreateTagFile(config) __FcCacheCreateTagFile((config))

FcStrSet * __FcGetDefaultLangs() =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1204(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcGetDefaultLangs() __FcGetDefaultLangs()

const FcChar8 * __FcConfigGetSysRoot(const FcConfig * config) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1210(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigGetSysRoot(config) __FcConfigGetSysRoot((config))

void __FcConfigSetSysRoot(FcConfig * config, const FcChar8 * sysroot) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1216(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcConfigSetSysRoot(config, sysroot) __FcConfigSetSysRoot((config), (sysroot))

FcCache * __FcDirCacheRescan(const FcChar8 * dir, FcConfig * config) =
	"\tlis\t11,FontConfigBase@ha\n"
	"\tlwz\t12,FontConfigBase@l(11)\n"
	"\tlwz\t0,-1222(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FcDirCacheRescan(dir, config) __FcDirCacheRescan((dir), (config))

#endif /*  _VBCCINLINE_FONTCONFIG_H  */

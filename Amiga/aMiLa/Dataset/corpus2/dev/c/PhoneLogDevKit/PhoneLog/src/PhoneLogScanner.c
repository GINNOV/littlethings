/* $Id: Scanner.c,v 2.16 1992/08/18 09:05:32 grosch rel $ */

# define bool		char
# define true		1
# define false		0
# define StdIn		0

# include "PhoneLogScanner.h"
# include "PhoneLogScannerSource.h"
# include "System.h"
# include "General.h"
# include "DynArray.h"
# include "Positions.h"
# include <stdio.h>

#  include <stdlib.h>

# define yyTabSpace	8

# define yyStart(State)	{ yyPreviousStart = yyStartState; yyStartState = State; }
# define yyPrevious	{ yyStateRange s = yyStartState; \
	 		yyStartState = yyPreviousStart; yyPreviousStart = s; }
# define yyEcho		{ char * yyEnd = PhoneLogScanner_TokenPtr + PhoneLogScanner_TokenLength; \
			char yyCh = * yyEnd; * yyEnd = '\0'; \
	 		(void) fputs (PhoneLogScanner_TokenPtr, stdout); * yyEnd = yyCh; }
# define yyLess(n)	{ yyChBufferIndex -= PhoneLogScanner_TokenLength - n; PhoneLogScanner_TokenLength = n; }
# define yyTab		yyLineStart -= yyTabSpace - 1 - ((unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart - 1) % yyTabSpace
# define yyTab1(a)	yyLineStart -= yyTabSpace - 1 - ((unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart + a - 1) % yyTabSpace
# define yyTab2(a,b)	yyLineStart -= yyTabSpace - 1 - ((unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart + a - 1) % yyTabSpace
# define yyEol(Column)	{ yyLineCount ++; yyLineStart = yyChBufferIndex - 1 - Column; }
# define output(c)	(void) putchar ((int) c)
# define unput(c)	* (-- yyChBufferIndex) = c

# define yyDNoState		0
# define yyFileStackSize	16
# define yyInitBufferSize	1024 * 8 + 256
# define yyFirstCh	(unsigned char) '\0'
# define yyLastCh	(unsigned char) '\377'
# define yyEolCh	(unsigned char) '\12'
# define yyEobCh	(unsigned char) '\177'
# define yyDStateCount	276
# define yyTableSize	761
# define yyEobState	8
# define yyDefaultState	9
# define STD	1
# define TEXT	3

static void yyExit (void) { Exit (1); }

typedef unsigned short	yyStateRange;
typedef struct { yyStateRange yyCheck, yyNext; } yyCombType;

	char *		PhoneLogScanner_TokenPtr	;
	short		PhoneLogScanner_TokenLength	;
	PhoneLogScanner_tScanAttribute	PhoneLogScanner_Attribute	;
	void		(* PhoneLogScanner_Exit) (void) = yyExit;

static	yyCombType	yyComb		[yyTableSize   + 1] = {{1, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{1, 12},
{1, 10},
{0, 0},
{3, 13},
{3, 11},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{1, 14},
{0, 0},
{0, 0},
{3, 15},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{16, 17},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{6, 6},
{0, 0},
{0, 0},
{1, 91},
{1, 75},
{1, 74},
{3, 16},
{24, 25},
{22, 23},
{27, 28},
{31, 32},
{17, 53},
{26, 27},
{18, 42},
{20, 21},
{17, 58},
{33, 34},
{37, 38},
{35, 36},
{39, 40},
{17, 33},
{17, 67},
{19, 20},
{17, 18},
{23, 24},
{17, 26},
{18, 19},
{17, 48},
{21, 22},
{28, 29},
{29, 30},
{30, 31},
{34, 35},
{36, 37},
{38, 39},
{40, 41},
{42, 43},
{43, 44},
{44, 45},
{45, 46},
{46, 47},
{48, 49},
{49, 50},
{50, 51},
{51, 52},
{53, 54},
{54, 55},
{55, 56},
{56, 57},
{58, 59},
{59, 60},
{60, 61},
{61, 62},
{62, 63},
{63, 64},
{64, 65},
{65, 66},
{1, 76},
{67, 68},
{68, 69},
{69, 70},
{1, 84},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{7, 8},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{70, 71},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{5, 5},
{71, 72},
{72, 73},
{76, 77},
{77, 78},
{78, 79},
{79, 80},
{80, 81},
{81, 82},
{82, 83},
{84, 85},
{85, 86},
{86, 87},
{87, 88},
{88, 89},
{89, 90},
{91, 92},
{93, 94},
{94, 95},
{95, 96},
{96, 97},
{97, 98},
{98, 99},
{93, 240},
{99, 100},
{100, 101},
{102, 103},
{103, 104},
{104, 105},
{105, 106},
{106, 107},
{107, 108},
{102, 246},
{108, 109},
{109, 110},
{91, 116},
{111, 112},
{91, 197},
{91, 206},
{112, 113},
{113, 114},
{91, 231},
{114, 115},
{116, 117},
{117, 118},
{118, 119},
{91, 144},
{91, 102},
{119, 120},
{91, 161},
{121, 122},
{91, 128},
{91, 216},
{91, 187},
{92, 111},
{122, 123},
{92, 192},
{92, 202},
{123, 124},
{124, 125},
{92, 222},
{125, 126},
{126, 127},
{128, 129},
{129, 130},
{92, 135},
{92, 93},
{130, 131},
{92, 153},
{131, 132},
{92, 121},
{92, 210},
{92, 182},
{132, 133},
{133, 134},
{135, 136},
{136, 137},
{137, 138},
{138, 168},
{139, 140},
{140, 141},
{141, 142},
{142, 143},
{144, 145},
{145, 146},
{146, 147},
{147, 169},
{148, 149},
{149, 150},
{150, 151},
{151, 152},
{154, 155},
{153, 170},
{155, 156},
{138, 139},
{153, 262},
{156, 157},
{157, 158},
{158, 159},
{159, 160},
{161, 176},
{162, 163},
{147, 148},
{161, 270},
{163, 164},
{153, 154},
{164, 165},
{165, 166},
{166, 167},
{170, 171},
{171, 172},
{172, 173},
{173, 174},
{161, 162},
{174, 175},
{176, 177},
{177, 178},
{178, 179},
{179, 180},
{180, 181},
{182, 183},
{183, 184},
{184, 185},
{185, 186},
{187, 188},
{188, 189},
{189, 190},
{190, 191},
{192, 193},
{193, 194},
{194, 195},
{195, 196},
{197, 198},
{198, 199},
{199, 200},
{200, 201},
{202, 203},
{203, 204},
{204, 205},
{206, 207},
{207, 208},
{208, 209},
{210, 211},
{211, 212},
{212, 213},
{213, 214},
{214, 215},
{216, 217},
{217, 218},
{218, 219},
{219, 220},
{220, 221},
{222, 223},
{203, 254},
{223, 224},
{224, 225},
{207, 258},
{225, 252},
{226, 227},
{227, 228},
{228, 229},
{229, 230},
{231, 232},
{232, 233},
{233, 234},
{234, 253},
{235, 236},
{236, 237},
{237, 238},
{238, 239},
{240, 241},
{241, 242},
{242, 243},
{225, 226},
{243, 244},
{244, 245},
{246, 247},
{247, 248},
{248, 249},
{249, 250},
{250, 251},
{234, 235},
{254, 255},
{255, 256},
{256, 257},
{258, 259},
{259, 260},
{260, 261},
{262, 263},
{263, 264},
{264, 265},
{265, 266},
{266, 267},
{267, 268},
{268, 269},
{270, 271},
{271, 272},
{272, 273},
{273, 274},
{274, 275},
{275, 276},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
};
static	yyCombType *	yyBasePtr	[yyDStateCount + 1] = {& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [3],
& yyComb [0],
& yyComb [119],
& yyComb [0],
& yyComb [52],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [1],
& yyComb [0],
& yyComb [0],
& yyComb [3],
& yyComb [0],
& yyComb [4],
& yyComb [2],
& yyComb [0],
& yyComb [0],
& yyComb [1],
& yyComb [3],
& yyComb [8],
& yyComb [10],
& yyComb [5],
& yyComb [0],
& yyComb [8],
& yyComb [7],
& yyComb [0],
& yyComb [12],
& yyComb [9],
& yyComb [14],
& yyComb [7],
& yyComb [30],
& yyComb [0],
& yyComb [11],
& yyComb [21],
& yyComb [16],
& yyComb [28],
& yyComb [35],
& yyComb [0],
& yyComb [25],
& yyComb [22],
& yyComb [31],
& yyComb [39],
& yyComb [0],
& yyComb [37],
& yyComb [19],
& yyComb [35],
& yyComb [43],
& yyComb [0],
& yyComb [27],
& yyComb [24],
& yyComb [24],
& yyComb [31],
& yyComb [45],
& yyComb [34],
& yyComb [43],
& yyComb [51],
& yyComb [0],
& yyComb [30],
& yyComb [39],
& yyComb [51],
& yyComb [177],
& yyComb [293],
& yyComb [314],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [276],
& yyComb [260],
& yyComb [274],
& yyComb [265],
& yyComb [276],
& yyComb [271],
& yyComb [273],
& yyComb [0],
& yyComb [283],
& yyComb [271],
& yyComb [271],
& yyComb [282],
& yyComb [277],
& yyComb [279],
& yyComb [0],
& yyComb [343],
& yyComb [362],
& yyComb [312],
& yyComb [327],
& yyComb [315],
& yyComb [311],
& yyComb [308],
& yyComb [327],
& yyComb [316],
& yyComb [337],
& yyComb [0],
& yyComb [321],
& yyComb [336],
& yyComb [324],
& yyComb [320],
& yyComb [317],
& yyComb [336],
& yyComb [325],
& yyComb [346],
& yyComb [0],
& yyComb [325],
& yyComb [330],
& yyComb [325],
& yyComb [354],
& yyComb [0],
& yyComb [332],
& yyComb [335],
& yyComb [330],
& yyComb [360],
& yyComb [0],
& yyComb [355],
& yyComb [364],
& yyComb [349],
& yyComb [354],
& yyComb [357],
& yyComb [374],
& yyComb [0],
& yyComb [368],
& yyComb [373],
& yyComb [358],
& yyComb [364],
& yyComb [369],
& yyComb [386],
& yyComb [0],
& yyComb [384],
& yyComb [368],
& yyComb [376],
& yyComb [390],
& yyComb [388],
& yyComb [377],
& yyComb [386],
& yyComb [394],
& yyComb [0],
& yyComb [392],
& yyComb [376],
& yyComb [384],
& yyComb [398],
& yyComb [396],
& yyComb [385],
& yyComb [394],
& yyComb [402],
& yyComb [0],
& yyComb [397],
& yyComb [386],
& yyComb [396],
& yyComb [388],
& yyComb [406],
& yyComb [395],
& yyComb [411],
& yyComb [0],
& yyComb [405],
& yyComb [396],
& yyComb [407],
& yyComb [398],
& yyComb [416],
& yyComb [405],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [401],
& yyComb [411],
& yyComb [406],
& yyComb [418],
& yyComb [426],
& yyComb [0],
& yyComb [407],
& yyComb [417],
& yyComb [412],
& yyComb [424],
& yyComb [431],
& yyComb [0],
& yyComb [421],
& yyComb [418],
& yyComb [427],
& yyComb [435],
& yyComb [0],
& yyComb [425],
& yyComb [422],
& yyComb [431],
& yyComb [439],
& yyComb [0],
& yyComb [437],
& yyComb [419],
& yyComb [435],
& yyComb [443],
& yyComb [0],
& yyComb [441],
& yyComb [423],
& yyComb [439],
& yyComb [447],
& yyComb [0],
& yyComb [432],
& yyComb [443],
& yyComb [450],
& yyComb [0],
& yyComb [435],
& yyComb [446],
& yyComb [453],
& yyComb [0],
& yyComb [432],
& yyComb [452],
& yyComb [436],
& yyComb [435],
& yyComb [458],
& yyComb [0],
& yyComb [437],
& yyComb [457],
& yyComb [441],
& yyComb [440],
& yyComb [463],
& yyComb [0],
& yyComb [447],
& yyComb [445],
& yyComb [445],
& yyComb [469],
& yyComb [467],
& yyComb [456],
& yyComb [465],
& yyComb [473],
& yyComb [0],
& yyComb [457],
& yyComb [454],
& yyComb [454],
& yyComb [477],
& yyComb [475],
& yyComb [464],
& yyComb [473],
& yyComb [481],
& yyComb [0],
& yyComb [467],
& yyComb [479],
& yyComb [477],
& yyComb [466],
& yyComb [487],
& yyComb [0],
& yyComb [473],
& yyComb [485],
& yyComb [483],
& yyComb [471],
& yyComb [492],
& yyComb [0],
& yyComb [0],
& yyComb [0],
& yyComb [474],
& yyComb [468],
& yyComb [496],
& yyComb [0],
& yyComb [477],
& yyComb [471],
& yyComb [499],
& yyComb [0],
& yyComb [483],
& yyComb [485],
& yyComb [495],
& yyComb [489],
& yyComb [487],
& yyComb [496],
& yyComb [506],
& yyComb [0],
& yyComb [490],
& yyComb [492],
& yyComb [502],
& yyComb [496],
& yyComb [494],
& yyComb [503],
& yyComb [0],
};
static	yyStateRange	yyDefault	[yyDStateCount + 1] = {0,
6,
1,
5,
3,
7,
7,
0,
0,
0,
0,
5,
0,
5,
0,
5,
7,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
0,
0,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
0,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
7,
0,
7,
7,
7,
0,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
0,
0,
0,
7,
7,
7,
0,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
7,
0,
7,
7,
7,
7,
7,
7,
0,
};
static	yyStateRange	yyEobTrans	[yyDStateCount + 1] = {0,
0,
0,
5,
5,
5,
0,
0,
0,
0,
0,
5,
0,
5,
0,
5,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
};

static	yyStateRange	yyInitStateStack [yyInitBufferSize] = {0};
static	yyStateRange *	yyStateStack	= yyInitStateStack;
static	unsigned long	yyStateStackSize= yyInitBufferSize;
static	yyStateRange	yyStartState	= 0;
static	yyStateRange	yyPreviousStart	= 1;

static  short		yySourceFile	;
static	bool		yyEof		;
static	unsigned char *	yyChBufferPtr	;
static	unsigned char *	yyChBufferStart	;
static	unsigned long	yyChBufferSize	;
static	unsigned char *	yyChBufferIndex	= ((unsigned char *) yyComb) + 2; /* dirty trick */
static	int		yyBytesRead	;
static	int		yyLineCount	;
static	unsigned char *	yyLineStart	;

static	struct {
	short		yySourceFile	;
	bool		yyEof		;
	unsigned char *	yyChBufferPtr	;
	unsigned char *	yyChBufferStart	;
	unsigned long	yyChBufferSize	;
	unsigned char *	yyChBufferIndex	;
	int		yyBytesRead	;
	int		yyLineCount	;
	unsigned char *	yyLineStart	;
	} yyFileStack [yyFileStackSize + 1], * yyFileStackPtr = yyFileStack;

static	char	yyToLower	[] = {
'\0', '\1', '\2', '\3', '\4', '\5', '\6', '\7',
'\10', '\11', '\12', '\13', '\14', '\15', '\16', '\17',
'\20', '\21', '\22', '\23', '\24', '\25', '\26', '\27',
'\30', '\31', '\32', '\33', '\34', '\35', '\36', '\37',
' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/',
'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?',
'@', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', '\\', ']', '^', '_',
'`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', '\177',
'\200', '\201', '\202', '\203', '\204', '\205', '\206', '\207',
'\210', '\211', '\212', '\213', '\214', '\215', '\216', '\217',
'\220', '\221', '\222', '\223', '\224', '\225', '\226', '\227',
'\230', '\231', '\232', '\233', '\234', '\235', '\236', '\237',
'\240', '\241', '\242', '\243', '\244', '\245', '\246', '\247',
'\250', '\251', '\252', '\253', '\254', '\255', '\256', '\257',
'\260', '\261', '\262', '\263', '\264', '\265', '\266', '\267',
'\270', '\271', '\272', '\273', '\274', '\275', '\276', '\277',
'\300', '\301', '\302', '\303', '\304', '\305', '\306', '\307',
'\310', '\311', '\312', '\313', '\314', '\315', '\316', '\317',
'\320', '\321', '\322', '\323', '\324', '\325', '\326', '\327',
'\330', '\331', '\332', '\333', '\334', '\335', '\336', '\337',
'\340', '\341', '\342', '\343', '\344', '\345', '\346', '\347',
'\350', '\351', '\352', '\353', '\354', '\355', '\356', '\357',
'\360', '\361', '\362', '\363', '\364', '\365', '\366', '\367',
'\370', '\371', '\372', '\373', '\374', '\375', '\376', '\377',
};

static	char	yyToUpper	[] = {
'\0', '\1', '\2', '\3', '\4', '\5', '\6', '\7',
'\10', '\11', '\12', '\13', '\14', '\15', '\16', '\17',
'\20', '\21', '\22', '\23', '\24', '\25', '\26', '\27',
'\30', '\31', '\32', '\33', '\34', '\35', '\36', '\37',
' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/',
'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?',
'@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_',
'`', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '~', '\177',
'\200', '\201', '\202', '\203', '\204', '\205', '\206', '\207',
'\210', '\211', '\212', '\213', '\214', '\215', '\216', '\217',
'\220', '\221', '\222', '\223', '\224', '\225', '\226', '\227',
'\230', '\231', '\232', '\233', '\234', '\235', '\236', '\237',
'\240', '\241', '\242', '\243', '\244', '\245', '\246', '\247',
'\250', '\251', '\252', '\253', '\254', '\255', '\256', '\257',
'\260', '\261', '\262', '\263', '\264', '\265', '\266', '\267',
'\270', '\271', '\272', '\273', '\274', '\275', '\276', '\277',
'\300', '\301', '\302', '\303', '\304', '\305', '\306', '\307',
'\310', '\311', '\312', '\313', '\314', '\315', '\316', '\317',
'\320', '\321', '\322', '\323', '\324', '\325', '\326', '\327',
'\330', '\331', '\332', '\333', '\334', '\335', '\336', '\337',
'\340', '\341', '\342', '\343', '\344', '\345', '\346', '\347',
'\350', '\351', '\352', '\353', '\354', '\355', '\356', '\357',
'\360', '\361', '\362', '\363', '\364', '\365', '\366', '\367',
'\370', '\371', '\372', '\373', '\374', '\375', '\376', '\377',
};

static	void	yyInitialize	(void);
static	void	yyErrorMessage	(int yyErrorCode);
static	char	input		(void);
/* line 19 "PhoneLogScanner.rex" */
/* GLOBAL */
         /* #include <stdio.h> */
         #include <stdlib.h>


         unsigned short program = 0;


         void PhoneLogScanner_ErrorAttribute(int Token, PhoneLogScanner_tScanAttribute *Attribute)
          {
           switch(Token)
            {
             case 1  : Attribute->number = 0;
                       break;
             case 2  : Attribute->lexstring = PutString("UNKNOWN",7);
                       break;
             default :
                       break;
            }
          }
         /* GLOBAL */

int PhoneLogScanner_GetToken (void)
{
   register	yyStateRange	yyState;
   register	yyStateRange *	yyStatePtr;
   register	unsigned char * yyChBufferIndexReg;
   register	yyCombType * *	yyBasePtrReg = yyBasePtr;
/* line 41 "PhoneLogScanner.rex" */
/* LOCAL */
         char Word[256];
         int  length;
         /* LOCAL */

yyBegin:
   yyState		= yyStartState;		/* initialize */
   yyStatePtr		= & yyStateStack [1];
   yyChBufferIndexReg 	= yyChBufferIndex;
   PhoneLogScanner_TokenPtr	 	= (char *) yyChBufferIndexReg;

   /* ASSERT yyChBuffer [yyChBufferIndex] == first character */

yyContinue:		/* continue after sentinel or skipping blanks */
   for (;;) {		/* execute as many state transitions as possible */
					/* determine next state and get next character */
      register yyCombType * yyTablePtr = (yyBasePtrReg [yyState] + * yyChBufferIndexReg ++);
      if (yyTablePtr->yyCheck == yyState) {
	 yyState = yyTablePtr->yyNext;
	 * yyStatePtr ++ = yyState;		/* push state */
	 goto yyContinue;
      }
      yyChBufferIndexReg --;			/* reconsider character */
      if ((yyState = yyDefault [yyState]) == yyDNoState) break;
   }

   for (;;) {					/* search for last final state */
      PhoneLogScanner_TokenLength = yyChBufferIndexReg - (unsigned char *) PhoneLogScanner_TokenPtr;
      yyChBufferIndex = yyChBufferIndexReg;
switch (* -- yyStatePtr) {
case 276:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 71 "PhoneLogScanner.rex" */
{return(20);
} yy1: goto yyBegin;
case 269:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 72 "PhoneLogScanner.rex" */
{return(21);
} yy2: goto yyBegin;
case 261:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 73 "PhoneLogScanner.rex" */
{return(22);
} yy3: goto yyBegin;
case 257:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 74 "PhoneLogScanner.rex" */
{return(23);
} yy4: goto yyBegin;
case 253:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 75 "PhoneLogScanner.rex" */
{return(24);
} yy5: goto yyBegin;
case 252:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 76 "PhoneLogScanner.rex" */
{return(25);
} yy6: goto yyBegin;
case 251:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 77 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(26);
                          
} yy7: goto yyBegin;
case 245:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 81 "PhoneLogScanner.rex" */
{return(27);
} yy8: goto yyBegin;
case 239:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 82 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(28);
                          
} yy9: goto yyBegin;
case 230:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 86 "PhoneLogScanner.rex" */
{return(29);
} yy10: goto yyBegin;
case 221:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 87 "PhoneLogScanner.rex" */
{return(30);
} yy11: goto yyBegin;
case 215:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 88 "PhoneLogScanner.rex" */
{return(31);
} yy12: goto yyBegin;
case 209:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 89 "PhoneLogScanner.rex" */
{return(32);
} yy13: goto yyBegin;
case 205:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 90 "PhoneLogScanner.rex" */
{return(33);
} yy14: goto yyBegin;
case 201:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 91 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(34);
                          
} yy15: goto yyBegin;
case 196:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 95 "PhoneLogScanner.rex" */
{return(35);
} yy16: goto yyBegin;
case 191:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 96 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(36);
                          
} yy17: goto yyBegin;
case 186:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 100 "PhoneLogScanner.rex" */
{return(37);
} yy18: goto yyBegin;
case 181:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 101 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(38);
                          
} yy19: goto yyBegin;
case 175:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 105 "PhoneLogScanner.rex" */
{return(39);
} yy20: goto yyBegin;
case 169:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 106 "PhoneLogScanner.rex" */
{return(40);
} yy21: goto yyBegin;
case 168:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 107 "PhoneLogScanner.rex" */
{return(41);
} yy22: goto yyBegin;
case 167:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 108 "PhoneLogScanner.rex" */
{
                           program=1;
                           return(42);
                          
} yy23: goto yyBegin;
case 160:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 112 "PhoneLogScanner.rex" */
{
                           program=0;
                           return(43);
                          
} yy24: goto yyBegin;
case 152:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 116 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(44);
                          
} yy25: goto yyBegin;
case 143:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 120 "PhoneLogScanner.rex" */
{return(45);
} yy26: goto yyBegin;
case 134:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 121 "PhoneLogScanner.rex" */
{
                           yyStart(TEXT);
                           return(46);
                          
} yy27: goto yyBegin;
case 127:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 125 "PhoneLogScanner.rex" */
{return(47);
} yy28: goto yyBegin;
case 120:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 126 "PhoneLogScanner.rex" */
{return(48);
} yy29: goto yyBegin;
case 115:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 127 "PhoneLogScanner.rex" */
{return(49);
} yy30: goto yyBegin;
case 110:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 128 "PhoneLogScanner.rex" */
{return(50);
} yy31: goto yyBegin;
case 101:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 129 "PhoneLogScanner.rex" */
{return(51);
} yy32: goto yyBegin;
case 90:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 133 "PhoneLogScanner.rex" */
{return(80);
} yy33: goto yyBegin;
case 83:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 134 "PhoneLogScanner.rex" */
{return(81);
} yy34: goto yyBegin;
case 75:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 138 "PhoneLogScanner.rex" */
{return(10);
} yy35: goto yyBegin;
case 74:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 139 "PhoneLogScanner.rex" */
{
                           if (program)
                             yyStart(TEXT);
                           return(11);
                          
} yy36: goto yyBegin;
case 6:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 147 "PhoneLogScanner.rex" */
{
                           length = PhoneLogScanner_GetWord(Word);
                           PhoneLogScanner_Attribute.number = atoi(Word);
                           /* sscanf(Word,"%d",&PhoneLogScanner_Attribute.number); */
                           return(1);
		          
} yy37: goto yyBegin;
case 5:;
case 11:;
case 13:;
case 15:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 155 "PhoneLogScanner.rex" */
{
                           length = PhoneLogScanner_GetWord(Word);
                           PhoneLogScanner_Attribute.lexstring = PutString(Word,length);
                           yyPrevious;
		 	   return(2);
     			  
} yy38: goto yyBegin;
case 73:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 161 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(27);
                          
} yy39: goto yyBegin;
case 66:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 166 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(29);
                          
} yy40: goto yyBegin;
case 57:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 171 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(35);
                          
} yy41: goto yyBegin;
case 52:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 176 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(37);
                          
} yy42: goto yyBegin;
case 47:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 181 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(39);
                          
} yy43: goto yyBegin;
case 41:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 186 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(45);
                          
} yy44: goto yyBegin;
case 32:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 191 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           return(47);
                          
} yy45: goto yyBegin;
case 25:;
PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
PhoneLogScanner_Attribute.Position.Column = (unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart;
/* line 196 "PhoneLogScanner.rex" */
{
                           PhoneLogScanner_Attribute.lexstring = PutString("",0);
                           yyPrevious;
                           program=0;
                           return(43);
                          
} yy46: goto yyBegin;
case 14:;
{/* BlankAction */
while (* yyChBufferIndexReg ++ == ' ') ;
PhoneLogScanner_TokenPtr = (char *) -- yyChBufferIndexReg;
yyState = yyStartState;
yyStatePtr = & yyStateStack [1];
goto yyContinue;
} yy47: goto yyBegin;
case 12:;
{/* TabAction */
yyLineStart -= 7 - ((unsigned char *) PhoneLogScanner_TokenPtr - yyLineStart - 1) & 0x7; /* % 8 */
} yy48: goto yyBegin;
case 10:;
{/* EolAction */
yyLineCount ++;
yyLineStart = yyChBufferIndexReg - 1;
} yy49: goto yyBegin;
case 1:;
case 2:;
case 3:;
case 4:;
case 7:;
case 16:;
case 17:;
case 18:;
case 19:;
case 20:;
case 21:;
case 22:;
case 23:;
case 24:;
case 26:;
case 27:;
case 28:;
case 29:;
case 30:;
case 31:;
case 33:;
case 34:;
case 35:;
case 36:;
case 37:;
case 38:;
case 39:;
case 40:;
case 42:;
case 43:;
case 44:;
case 45:;
case 46:;
case 48:;
case 49:;
case 50:;
case 51:;
case 53:;
case 54:;
case 55:;
case 56:;
case 58:;
case 59:;
case 60:;
case 61:;
case 62:;
case 63:;
case 64:;
case 65:;
case 67:;
case 68:;
case 69:;
case 70:;
case 71:;
case 72:;
case 76:;
case 77:;
case 78:;
case 79:;
case 80:;
case 81:;
case 82:;
case 84:;
case 85:;
case 86:;
case 87:;
case 88:;
case 89:;
case 91:;
case 92:;
case 93:;
case 94:;
case 95:;
case 96:;
case 97:;
case 98:;
case 99:;
case 100:;
case 102:;
case 103:;
case 104:;
case 105:;
case 106:;
case 107:;
case 108:;
case 109:;
case 111:;
case 112:;
case 113:;
case 114:;
case 116:;
case 117:;
case 118:;
case 119:;
case 121:;
case 122:;
case 123:;
case 124:;
case 125:;
case 126:;
case 128:;
case 129:;
case 130:;
case 131:;
case 132:;
case 133:;
case 135:;
case 136:;
case 137:;
case 138:;
case 139:;
case 140:;
case 141:;
case 142:;
case 144:;
case 145:;
case 146:;
case 147:;
case 148:;
case 149:;
case 150:;
case 151:;
case 153:;
case 154:;
case 155:;
case 156:;
case 157:;
case 158:;
case 159:;
case 161:;
case 162:;
case 163:;
case 164:;
case 165:;
case 166:;
case 170:;
case 171:;
case 172:;
case 173:;
case 174:;
case 176:;
case 177:;
case 178:;
case 179:;
case 180:;
case 182:;
case 183:;
case 184:;
case 185:;
case 187:;
case 188:;
case 189:;
case 190:;
case 192:;
case 193:;
case 194:;
case 195:;
case 197:;
case 198:;
case 199:;
case 200:;
case 202:;
case 203:;
case 204:;
case 206:;
case 207:;
case 208:;
case 210:;
case 211:;
case 212:;
case 213:;
case 214:;
case 216:;
case 217:;
case 218:;
case 219:;
case 220:;
case 222:;
case 223:;
case 224:;
case 225:;
case 226:;
case 227:;
case 228:;
case 229:;
case 231:;
case 232:;
case 233:;
case 234:;
case 235:;
case 236:;
case 237:;
case 238:;
case 240:;
case 241:;
case 242:;
case 243:;
case 244:;
case 246:;
case 247:;
case 248:;
case 249:;
case 250:;
case 254:;
case 255:;
case 256:;
case 258:;
case 259:;
case 260:;
case 262:;
case 263:;
case 264:;
case 265:;
case 266:;
case 267:;
case 268:;
case 270:;
case 271:;
case 272:;
case 273:;
case 274:;
case 275:;
	 /* non final states */
	 yyChBufferIndexReg --;			/* return character */
	 break;

case 9:
	 PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
	 PhoneLogScanner_Attribute.Position.Column = yyChBufferIndexReg - yyLineStart;
      /* PhoneLogScanner_TokenLength   = 1; */
	 yyChBufferIndex = ++ yyChBufferIndexReg;
	 {
/* line 50 "PhoneLogScanner.rex" */
/* DEFAULT */
         /* unmatched characters */
         printf("%d,%d : %c\n",PhoneLogScanner_Attribute.Position.Line,PhoneLogScanner_Attribute.Position.Column,yyChBufferIndexReg[-1]);
         /* DEFAULT */
	 }
	 goto yyBegin;

      case yyDNoState:				/* automatic initialization */
	 yyInitialize ();
	 yySourceFile = StdIn;
	 goto yyBegin;

case 8:
	 yyChBufferIndex = -- yyChBufferIndexReg; /* undo last state transition */
	 if (-- PhoneLogScanner_TokenLength == 0) {		/* get previous state */
	    yyState = yyStartState;
	 } else {
	    yyState = * (yyStatePtr - 1);
	 }

	 if (yyChBufferIndex != & yyChBufferStart [yyBytesRead]) {
						/* end of buffer sentinel in buffer */
	    if ((yyState = yyEobTrans [yyState]) == yyDNoState) continue;
	    yyChBufferIndexReg ++;
	    * yyStatePtr ++ = yyState;		/* push state */
	    goto yyContinue;
	 }
						/* end of buffer reached */
	 {  /* copy initial part of token in front of the input buffer */
	    register char * yySource = PhoneLogScanner_TokenPtr;
	    register char * yyTarget = PhoneLogScanner_TokenPtr = (char *) & yyChBufferPtr [yyMaxAlign - PhoneLogScanner_TokenLength % yyMaxAlign];
	    if (yySource != yyTarget) {
	       while (yySource < (char *) yyChBufferIndexReg) * yyTarget ++ = * yySource ++;
	       yyLineStart += (unsigned char *) yyTarget - yyChBufferStart - yyBytesRead;
	       yyChBufferStart = (unsigned char *) yyTarget;
	    } else {
	       yyChBufferStart = yyChBufferIndexReg;
	    }
	 }

	 if (! yyEof) {				/* read buffer and restart */
	    int yyChBufferFree = (int) Exp2 (Log2 (yyChBufferSize - 4 - yyMaxAlign - PhoneLogScanner_TokenLength));
	    if (yyChBufferFree < yyChBufferSize / 8) {
	       register int yyDelta;
	       register unsigned char * yyOldChBufferPtr = yyChBufferPtr;
	       ExtendArray ((char * *) & yyChBufferPtr, & yyChBufferSize, sizeof (char));
	       if (yyChBufferPtr == NULL) yyErrorMessage (1);
	       yyDelta = yyChBufferPtr - yyOldChBufferPtr;
	       yyChBufferStart	+= yyDelta;
	       yyLineStart	+= yyDelta;
	       PhoneLogScanner_TokenPtr	+= yyDelta;
	       yyChBufferFree = (int) Exp2 (Log2 (yyChBufferSize - 4 - yyMaxAlign - PhoneLogScanner_TokenLength));
	       if (yyStateStackSize < yyChBufferSize) {
		  yyStateRange * yyOldStateStack = yyStateStack;
		  ExtendArray ((char * *) & yyStateStack, & yyStateStackSize, sizeof (yyStateRange));
		  if (yyStateStack == NULL) yyErrorMessage (1);
		  yyStatePtr	+= yyStateStack - yyOldStateStack;
	       }
	    }
	    yyChBufferIndex = yyChBufferIndexReg = yyChBufferStart;
	    yyBytesRead = PhoneLogScanner_GetLine (yySourceFile, (char *) yyChBufferIndex, yyChBufferFree);
	    if (yyBytesRead <= 0) { yyBytesRead = 0; yyEof = true; }
	    yyChBufferStart [yyBytesRead    ] = yyEobCh;
	    yyChBufferStart [yyBytesRead + 1] = '\0';
	    goto yyContinue;
	 }

	 if (PhoneLogScanner_TokenLength == 0) {		/* end of file reached */
	    PhoneLogScanner_Attribute.Position.Line   = yyLineCount;
	    PhoneLogScanner_Attribute.Position.Column = yyChBufferIndexReg - yyLineStart;
	    PhoneLogScanner_CloseFile ();
	    if (yyFileStackPtr == yyFileStack) {
/* line 55 "PhoneLogScanner.rex" */
/* EOF */
         /* EOF */
	    }
	    if (yyFileStackPtr == yyFileStack) return PhoneLogScanner_EofToken;
	    goto yyBegin;
	 }
	 break;

      default:
	 yyErrorMessage (0);
      }
   }
}

void PhoneLogScanner_BeginFile(char * yyFileName)
   {
      yyInitialize ();
      yySourceFile = PhoneLogScanner_BeginSource (yyFileName);
   }

static void yyInitialize (void)
   {
      if (yyFileStackPtr >= yyFileStack + yyFileStackSize) yyErrorMessage (2);
      yyFileStackPtr ++;			/* push file */
      yyFileStackPtr->yySourceFile	= yySourceFile		;
      yyFileStackPtr->yyEof		= yyEof			;
      yyFileStackPtr->yyChBufferPtr	= yyChBufferPtr		;
      yyFileStackPtr->yyChBufferStart	= yyChBufferStart	;
      yyFileStackPtr->yyChBufferSize	= yyChBufferSize	;
      yyFileStackPtr->yyChBufferIndex	= yyChBufferIndex	;
      yyFileStackPtr->yyBytesRead	= yyBytesRead		;
      yyFileStackPtr->yyLineCount	= yyLineCount		;
      yyFileStackPtr->yyLineStart	= yyLineStart		;
						/* initialize file state */
      yyChBufferSize	   = yyInitBufferSize;
      MakeArray ((char * *) & yyChBufferPtr, & yyChBufferSize, sizeof (char));
      if (yyChBufferPtr == NULL) yyErrorMessage (1);
      yyChBufferStart	   = & yyChBufferPtr [yyMaxAlign];
      yyChBufferStart [-1] = yyEolCh;		/* begin of line indicator */
      yyChBufferStart [ 0] = yyEobCh;		/* end of buffer sentinel */
      yyChBufferStart [ 1] = '\0';
      yyChBufferIndex	   = yyChBufferStart;
      yyEof		   = false;
      yyBytesRead	   = 0;
      yyLineCount	   = 1;
      yyLineStart	   = & yyChBufferStart [-1];
      if (yyStartState == 0) {
	 yyStartState	   = STD;
	 yyStateStack [0]  = yyDefaultState;	/* stack underflow sentinel */
      }
   }

void PhoneLogScanner_CloseFile (void)
   {
      if (yyFileStackPtr == yyFileStack) yyErrorMessage (3);
      PhoneLogScanner_CloseSource (yySourceFile);
      ReleaseArray ((char * *) & yyChBufferPtr, & yyChBufferSize, sizeof (char));
						/* pop file */
      yySourceFile	= yyFileStackPtr->yySourceFile		;
      yyEof		= yyFileStackPtr->yyEof			;
      yyChBufferPtr	= yyFileStackPtr->yyChBufferPtr		;
      yyChBufferStart	= yyFileStackPtr->yyChBufferStart	;
      yyChBufferSize	= yyFileStackPtr->yyChBufferSize	;
      yyChBufferIndex	= yyFileStackPtr->yyChBufferIndex	;
      yyBytesRead	= yyFileStackPtr->yyBytesRead		;
      yyLineCount	= yyFileStackPtr->yyLineCount		;
      yyLineStart	= yyFileStackPtr->yyLineStart		;
      yyFileStackPtr --;
   }

int PhoneLogScanner_GetWord(char * yyWord)
   {
      register char * yySource			= PhoneLogScanner_TokenPtr;
      register char * yyTarget			= yyWord;
      register char * yyChBufferIndexReg	= (char *) yyChBufferIndex;

      do {				/* ASSERT word is not empty */
	 * yyTarget ++ = * yySource ++;
      } while (yySource < yyChBufferIndexReg);
      * yyTarget = '\0';
      return yyChBufferIndexReg - PhoneLogScanner_TokenPtr;
   }

int PhoneLogScanner_GetLower(char * yyWord)
   {
      register char * yySource			= PhoneLogScanner_TokenPtr;
      register char * yyTarget			= yyWord;
      register char * yyChBufferIndexReg	= (char *) yyChBufferIndex;

      do {				/* ASSERT word is not empty */
	 * yyTarget ++ = yyToLower [* yySource ++];
      } while (yySource < yyChBufferIndexReg);
      * yyTarget = '\0';
      return yyChBufferIndexReg - PhoneLogScanner_TokenPtr;
   }

int PhoneLogScanner_GetUpper(char * yyWord)
   {
      register char * yySource			= PhoneLogScanner_TokenPtr;
      register char * yyTarget			= yyWord;
      register char * yyChBufferIndexReg	= (char *) yyChBufferIndex;

      do {				/* ASSERT word is not empty */
	 * yyTarget ++ = yyToUpper [* yySource ++];
      } while (yySource < yyChBufferIndexReg);
      * yyTarget = '\0';
      return yyChBufferIndexReg - PhoneLogScanner_TokenPtr;
   }

static char input (void)
   {
      if (yyChBufferIndex == & yyChBufferStart [yyBytesRead]) {
	 if (! yyEof) {
	    yyLineStart -= yyBytesRead;
	    yyChBufferIndex = yyChBufferStart = yyChBufferPtr;
	    yyBytesRead = PhoneLogScanner_GetLine (yySourceFile, (char *) yyChBufferIndex,
	       (int) Exp2 (Log2 (yyChBufferSize)));
	    if (yyBytesRead <= 0) { yyBytesRead = 0; yyEof = true; }
	    yyChBufferStart [yyBytesRead    ] = yyEobCh;
	    yyChBufferStart [yyBytesRead + 1] = '\0';
	 }
      }
      if (yyChBufferIndex == & yyChBufferStart [yyBytesRead]) return '\0';
      else return((char)(*yyChBufferIndex++));
   }

void PhoneLogScanner_BeginScanner (void)
   {
/* line 46 "PhoneLogScanner.rex" */
/* BEGIN */
   }

void PhoneLogScanner_CloseScanner (void)
   {
/* line 48 "PhoneLogScanner.rex" */
/* CLOSE */
   }

static void yyErrorMessage(int yyErrorCode)
   {
      WritePosition (stderr, PhoneLogScanner_Attribute.Position);
      switch (yyErrorCode) {
      case 0: (void) fprintf (stderr, ": PhoneLogScanner: internal error\n"); break;
      case 1: (void) fprintf (stderr, ": PhoneLogScanner: out of memory\n"); break;
      case 2: (void) fprintf (stderr, ": PhoneLogScanner: too many nested include files\n"); break;
      case 3: (void) fprintf (stderr, ": PhoneLogScanner: file stack underflow (too many calls of PhoneLogScanner_CloseFile)\n"); break;
      }
     (*PhoneLogScanner_Exit)();
   }

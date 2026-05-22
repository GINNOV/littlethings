/* $Id: Parser.c,v 2.9 1992/08/07 15:28:42 grosch rel $ */

#define bool  char
#define true  1
#define false 0

#include "PhoneLogParser.h"
#include "Errors.h"
#include "Memory.h"
#include "DynArray.h"
#include "Sets.h"
#include <string.h>
#ifndef BCOPY
  #include <memory.h>
#endif


#ifdef lex_interface
 #define PhoneLogScanner_GetToken yylex
  extern int yylex(void);
  #ifndef AttributeDef
    #include "Positions.h"
   typedef struct {tPosition Position;} PhoneLogScanner_tScanAttribute;
   static PhoneLogScanner_tScanAttribute PhoneLogScanner_Attribute = {{0,0}};
  #endif
  #ifndef ErrorAttributeDef
   #define PhoneLogScanner_ErrorAttribute(Token,RepairAttribute)
  #endif
  #ifndef yyGetAttribute
    #define yyGetAttribute(yyAttrStackPtr,Attribute) *yyAttrStackPtr = yylval
  #endif
#else
 #include "PhoneLogScanner.h"
  #ifndef yyGetAttribute
    #define yyGetAttribute(yyAttrStackPtr,Attribute) (yyAttrStackPtr)->Scan = Attribute
  #endif
#endif


/* line 12 "t:lalr.tmp" */
/* line 12 "PhoneLogParser.lalr" */
/*GLOBAL*/
        #include <stdio.h>
        #include <stdlib.h>
        #include <string.h>
        #include "PhoneLog.h"
        #include "PhoneLogParserInterface.h"
        /*#include "date.h"*/
        /*#include "datetime.h"*/

        typedef struct {
                        PhoneLogScanner_tScanAttribute Scan;
                       } tParsAttribute;


        struct PhoneLogMarker Marker;
        struct PhoneLogEntry  Entry;

        static unsigned short Day,Month,Hour,Min,Sec;
        static int Year;
        /*GLOBAL*/


#if defined lex_interface & ! defined yylvalDef
  tParsAttribute yylval;
#endif
#ifndef yyInitStackSize
  #define yyInitStackSize 100
#endif
#define yyNoState 0


# define yyFirstTerminal	0
# define yyLastTerminal		81
# define yyTableMax		180
# define yyNTableMax		153
# define yyFirstReadState	1
# define yyLastReadState	84
# define yyFirstReadTermState	85
# define yyLastReadTermState	104
# define yyLastReadNontermState	123
# define yyFirstReduceState	124
# define yyLastReduceState	192
# define yyStartState		1
# define yyStopState		124


#define yyFirstFinalState yyFirstReadTermState


typedef unsigned short yyStateRange;
typedef unsigned short yySymbolRange;
typedef struct {yyStateRange Check, Next;} yyTCombType;


char *PhoneLogParser_TokenName[yyLastTerminal+1] = {
"_EndOfFile",
"digits",
"text",
0,
0,
0,
0,
0,
0,
0,
"=",
">",
0,
0,
0,
0,
0,
0,
0,
0,
"<PHONELOG",
"</PHONELOG>",
"<ENTRY>",
"</ENTRY>",
"<HOST>",
"</HOST>",
"<NUMBER>",
"</NUMBER>",
"<HOSTNAME>",
"</HOSTNAME>",
"<START>",
"</START>",
"<END>",
"</END>",
"<DATE>",
"</DATE>",
"<TIME>",
"</TIME>",
"<PERIOD>",
"</PERIOD>",
"<MARK>",
"</MARK>",
"<PROGRAM",
"</PROGRAM>",
"<MARKNAME>",
"</MARKNAME>",
"<REASON>",
"</REASON>",
"<BUSY>",
"</BUSY>",
"<NOANSWER>",
"</NOANSWER>",
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
"version",
"revision",
};
static yyTCombType yyTComb[yyTableMax+1] = {
{10, 128},
{4, 5},
{8, 85},
{11, 126},
{16, 17},
{20, 87},
{22, 23},
{26, 27},
{29, 30},
{32, 33},
{3, 4},
{2, 132},
{5, 137},
{6, 135},
{7, 8},
{9, 10},
{14, 177},
{15, 16},
{17, 182},
{18, 180},
{1, 2},
{10, 128},
{10, 128},
{19, 20},
{11, 86},
{11, 12},
{12, 147},
{13, 145},
{21, 22},
{24, 25},
{25, 26},
{27, 89},
{28, 151},
{30, 90},
{31, 149},
{28, 29},
{34, 92},
{36, 167},
{35, 36},
{38, 39},
{10, 128},
{39, 93},
{40, 166},
{11, 68},
{12, 147},
{13, 14},
{23, 88},
{33, 91},
{42, 43},
{43, 94},
{44, 165},
{45, 95},
{46, 159},
{28, 151},
{48, 158},
{31, 32},
{35, 46},
{50, 157},
{35, 52},
{51, 96},
{52, 163},
{53, 38},
{54, 162},
{56, 161},
{57, 97},
{58, 98},
{59, 60},
{60, 172},
{61, 170},
{60, 172},
{62, 42},
{63, 169},
{64, 99},
{66, 67},
{67, 100},
{65, 143},
{68, 184},
{69, 70},
{70, 186},
{71, 72},
{2, 3},
{72, 73},
{5, 137},
{6, 7},
{73, 191},
{14, 15},
{74, 189},
{75, 76},
{17, 182},
{18, 19},
{65, 66},
{76, 101},
{77, 78},
{78, 79},
{79, 102},
{80, 81},
{81, 82},
{82, 103},
{83, 104},
{84, 124},
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
{70, 71},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{0, 0},
{73, 191},
{0, 0},
{74, 75},
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
static unsigned short yyNComb[yyNTableMax - yyLastTerminal] = {
9,
11,
119,
84,
120,
121,
122,
123,
6,
105,
13,
24,
35,
58,
110,
111,
112,
59,
65,
114,
115,
116,
28,
31,
34,
108,
109,
47,
40,
48,
44,
49,
50,
51,
53,
37,
41,
45,
54,
55,
56,
21,
107,
18,
106,
57,
61,
113,
63,
64,
69,
80,
77,
118,
74,
117,
83,
0,
62,
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
static yyTCombType *yyTBasePtr[yyLastReadState+1] = {
& yyTComb [0],
& yyTComb [0],
& yyTComb [0],
& yyTComb [0],
& yyTComb [0],
& yyTComb [1],
& yyTComb [2],
& yyTComb [4],
& yyTComb [1],
& yyTComb [4],
& yyTComb [0],
& yyTComb [3],
& yyTComb [2],
& yyTComb [3],
& yyTComb [5],
& yyTComb [7],
& yyTComb [3],
& yyTComb [7],
& yyTComb [8],
& yyTComb [13],
& yyTComb [4],
& yyTComb [17],
& yyTComb [4],
& yyTComb [3],
& yyTComb [5],
& yyTComb [4],
& yyTComb [5],
& yyTComb [4],
& yyTComb [7],
& yyTComb [6],
& yyTComb [4],
& yyTComb [9],
& yyTComb [7],
& yyTComb [0],
& yyTComb [11],
& yyTComb [8],
& yyTComb [3],
& yyTComb [0],
& yyTComb [37],
& yyTComb [6],
& yyTComb [6],
& yyTComb [0],
& yyTComb [46],
& yyTComb [12],
& yyTComb [19],
& yyTComb [20],
& yyTComb [18],
& yyTComb [0],
& yyTComb [18],
& yyTComb [0],
& yyTComb [8],
& yyTComb [10],
& yyTComb [26],
& yyTComb [27],
& yyTComb [26],
& yyTComb [0],
& yyTComb [12],
& yyTComb [13],
& yyTComb [42],
& yyTComb [34],
& yyTComb [33],
& yyTComb [32],
& yyTComb [34],
& yyTComb [38],
& yyTComb [39],
& yyTComb [52],
& yyTComb [71],
& yyTComb [35],
& yyTComb [34],
& yyTComb [35],
& yyTComb [67],
& yyTComb [69],
& yyTComb [80],
& yyTComb [73],
& yyTComb [75],
& yyTComb [77],
& yyTComb [90],
& yyTComb [81],
& yyTComb [91],
& yyTComb [51],
& yyTComb [51],
& yyTComb [94],
& yyTComb [52],
& yyTComb [57],
& yyTComb [99],
};
static unsigned short* yyNBasePtr[yyLastReadState+1] = {
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-81],
& yyNComb [-80],
& yyNComb [-80],
& yyNComb [-80],
& yyNComb [-82],
& yyNComb [-80],
& yyNComb [-72],
& yyNComb [-76],
& yyNComb [-72],
& yyNComb [-71],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-74],
& yyNComb [-63],
& yyNComb [-64],
& yyNComb [-73],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-77],
& yyNComb [-77],
& yyNComb [-78],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-78],
& yyNComb [-78],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-73],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
& yyNComb [-82],
};
static unsigned short yyDefault[yyLastReadState+1] = {
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
53,
0,
0,
0,
62,
0,
0,
0,
0,
0,
53,
0,
62,
0,
0,
0,
0,
0,
62,
0,
0,
0,
0,
0,
53,
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
static unsigned char yyLength[yyLastReduceState - yyFirstReduceState+1] = {
2,
5,
0,
1,
0,
2,
1,
1,
0,
1,
5,
0,
3,
0,
6,
1,
1,
1,
3,
0,
1,
0,
1,
0,
5,
0,
1,
0,
1,
3,
3,
3,
7,
0,
0,
0,
7,
0,
0,
0,
7,
0,
0,
0,
6,
0,
0,
1,
0,
3,
3,
3,
5,
0,
1,
5,
0,
3,
0,
5,
0,
5,
0,
1,
5,
0,
3,
0,
3,
};
static yySymbolRange yyLeftHandSide[yyLastReduceState - yyFirstReduceState+1] = {
134,
85,
84,
84,
83,
83,
86,
86,
82,
82,
89,
91,
91,
90,
87,
95,
95,
95,
96,
101,
101,
93,
93,
92,
94,
106,
106,
105,
105,
104,
108,
107,
97,
113,
111,
109,
98,
116,
115,
114,
99,
119,
118,
117,
100,
122,
121,
121,
120,
110,
112,
102,
103,
123,
123,
124,
126,
126,
125,
88,
127,
128,
130,
130,
131,
133,
133,
132,
129,
};
static yySymbolRange yyContinuation[yyLastReadState+1] = {
0,
20,
11,
10,
1,
11,
11,
10,
1,
11,
0,
0,
24,
24,
11,
10,
1,
11,
11,
10,
1,
11,
2,
43,
24,
26,
2,
27,
25,
2,
29,
25,
2,
47,
25,
48,
34,
34,
2,
35,
36,
36,
2,
37,
31,
31,
34,
34,
36,
36,
49,
49,
34,
34,
36,
36,
51,
51,
23,
32,
34,
36,
36,
33,
33,
23,
2,
39,
42,
42,
11,
10,
1,
11,
11,
10,
1,
11,
2,
43,
44,
2,
45,
41,
0,
};
static unsigned short yyFinalToProd[yyLastReadNontermState - yyFirstReadTermState+1] = {
136,
127,
181,
176,
153,
154,
155,
148,
173,
174,
164,
156,
160,
138,
168,
175,
190,
185,
192,
183,
134,
179,
178,
150,
152,
139,
140,
141,
171,
142,
144,
146,
188,
187,
125,
129,
130,
131,
133,
};


static void yyErrorRecovery(yySymbolRange * yyTerminal, yyStateRange * yyStateStack, unsigned long yyStackSize, short yyStackPtr);
static void yyComputeContinuation(yyStateRange * yyStack, unsigned long yyStackSize, short yyStackPtr, tSet * yyContinueSet);
static bool yyIsContinuation(yySymbolRange yyTerminal, yyStateRange * yyStateStack, unsigned long yyStackSize, short yyStackPtr);
static void yyComputeRestartPoints(yyStateRange * yyStateStack, unsigned long yyStackSize, short yyStackPtr, tSet * yyRestartSet);
static yyStateRange yyNext(yyStateRange yyState, yySymbolRange yySymbol);
static void BeginPhoneLogParser(void);


int PhoneLogParser(void)
 {
  register yyStateRange yyState;
  register long yyTerminal;
  register yyStateRange *yyStateStackPtr;
  register tParsAttribute *yyAttrStackPtr;
  register bool yyIsRepairing;
  unsigned long yyStateStackSize= yyInitStackSize;
  unsigned long yyAttrStackSize = yyInitStackSize;
  yyStateRange *yyStateStack;
  tParsAttribute* yyAttributeStack;
  tParsAttribute yySynAttribute; /* synthesized attribute */ /* ??? */
  register yyStateRange *yyEndOfStack;
  int yyErrorCount = 0;

/* line 27 "t:lalr.tmp" */
/* line 27 "PhoneLogParser.lalr" */
/*LOCAL*/
       char Word[256];
       /*LOCAL*/

 BeginPhoneLogParser();
  yyState = yyStartState;
 yyTerminal = PhoneLogScanner_GetToken();
  MakeArray((char **)&yyStateStack,&yyStateStackSize,sizeof(yyStateRange));
  MakeArray((char **)&yyAttributeStack,&yyAttrStackSize,sizeof(tParsAttribute));
  yyEndOfStack      = &yyStateStack[yyStateStackSize];
  yyStateStackPtr   = yyStateStack;
  yyAttrStackPtr    = yyAttributeStack;
  yyIsRepairing     = false;
ParseLoop:
  for (;;)
   {
    if (yyStateStackPtr >= yyEndOfStack)
     {
      int yyyStateStackPtr = yyStateStackPtr - yyStateStack;
      int yyyAttrStackPtr = yyAttrStackPtr - yyAttributeStack;
      ExtendArray ((char **)&yyStateStack,&yyStateStackSize,sizeof (yyStateRange));
      ExtendArray ((char **)&yyAttributeStack,&yyAttrStackSize,sizeof (tParsAttribute));
      yyStateStackPtr = yyStateStack + yyyStateStackPtr;
      yyAttrStackPtr = yyAttributeStack + yyyAttrStackPtr;
      yyEndOfStack = &yyStateStack[yyStateStackSize];
     }
    *yyStateStackPtr = yyState;
TermTrans:
    for (;;)
     {/* SPEC State = Next (State, Terminal); terminal transition */
      register short *yyTCombPtr;

      yyTCombPtr = (short *)(yyTBasePtr[yyState] + yyTerminal);
      if (*yyTCombPtr++ == yyState)
       {
        yyState = *yyTCombPtr;
        break;
       }
      if ((yyState = yyDefault[yyState]) != yyNoState)
        goto TermTrans;
      /* syntax error */
      if (!yyIsRepairing)
       {/* report and recover */
        yySymbolRange yyyTerminal = yyTerminal;
        yyErrorCount++;
        yyErrorRecovery(&yyyTerminal,yyStateStack,yyStateStackSize,(short)(yyStateStackPtr-yyStateStack));
        yyTerminal = yyyTerminal;
        yyIsRepairing = true;
       }
      yyState = *yyStateStackPtr;
      for (;;)
       {
        if (yyNext(yyState,(yySymbolRange)yyTerminal) == yyNoState)
         {/* repair */
          yySymbolRange yyRepairToken;
         PhoneLogScanner_tScanAttribute yyRepairAttribute;
            yyRepairToken = yyContinuation[yyState];
            yyState = yyNext(yyState, yyRepairToken);
            if (yyState <= yyLastReadTermState)
             {/* read or read terminal reduce ? */
             PhoneLogScanner_ErrorAttribute((int)yyRepairToken,&yyRepairAttribute);
             ErrorMessageI(xxTokenInserted,xxRepair,PhoneLogScanner_Attribute.Position,xxString,PhoneLogParser_TokenName[yyRepairToken]);
              if (yyState >= yyFirstFinalState)
               {/* avoid second push */
                yyState = yyFinalToProd[yyState - yyFirstReadTermState];
               }
              yyGetAttribute(yyAttrStackPtr++,yyRepairAttribute);
              * ++yyStateStackPtr = yyState;
             }
            if (yyState >= yyFirstFinalState)
              goto Final; /* final state ? */
           }
          else
           {
            yyState = yyNext(yyState,(yySymbolRange)yyTerminal);
            goto Final;
           }
         }
       }
Final:
      if (yyState >= yyFirstFinalState)
       {/* final state ? */
        if (yyState <= yyLastReadTermState)
         {/* read terminal reduce ? */
          yyStateStackPtr++;
         yyGetAttribute(yyAttrStackPtr++,PhoneLogScanner_Attribute);
         yyTerminal = PhoneLogScanner_GetToken();
            yyIsRepairing = false;
         }
        for (;;)
         {/* left-hand side */
          #define yyNonterminal yyState

switch (yyState) {
case 124: /* _0000_ : PHONELOG _EndOfFile .*/
  ReleaseArray ((char * *) & yyStateStack, & yyStateStackSize, sizeof (yyStateRange));
  ReleaseArray ((char * *) & yyAttributeStack, & yyAttrStackSize, sizeof (tParsAttribute));
  return yyErrorCount;

case 125:
case 119: /* PHONELOG : "<PHONELOG" PHONELOG_1 ">" PHONELOG_2 PHONELOG_3 .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 85; {

} break;
case 126: /* PHONELOG_3 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 84; {

} break;
case 127:
case 86: /* PHONELOG_3 : "</PHONELOG>" .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 84; {

} break;
case 128: /* PHONELOG_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 83; {

} break;
case 129:
case 120: /* PHONELOG_2 : PHONELOG_2 PHONELOG_4 .*/
  yyStateStackPtr -=2; yyAttrStackPtr -=2; yyNonterminal = 83; {

} break;
case 130:
case 121: /* PHONELOG_4 : ENTRY .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 86; {

} break;
case 131:
case 122: /* PHONELOG_4 : MARK .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 86; {

} break;
case 132: /* PHONELOG_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 82; {

} break;
case 133:
case 123: /* PHONELOG_1 : PHONELOGATTR .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 82; {

} break;
case 134:
case 105: /* PHONELOGATTR : "version" "=" digits PHONELOGATTR_1 PHONELOGATTR_2 .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 89; {

} break;
case 135: /* PHONELOGATTR_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 91; {

} break;
case 136:
case 85: /* PHONELOGATTR_2 : "revision" "=" digits .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 91; {
/* line 95 "t:lalr.tmp" */
/* line 106 "PhoneLogParser.lalr" */

                   #ifdef DEBUG
                     printf("PhoneLog revision: %d\n",yyAttrStackPtr [3-1].Scan.number);
                   #endif
                    if ((yyAttrStackPtr [-1-1].Scan.number == 1) && (yyAttrStackPtr [3-1].Scan.number > 2))
                     {
                      ErrorMessage(xxSyntaxError,xxFatal,yyAttrStackPtr [3-1].Scan.Position);
                     }
                   
} break;
case 137: /* PHONELOGATTR_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 90; {
/* line 107 "t:lalr.tmp" */
/* line 95 "PhoneLogParser.lalr" */

                   #ifdef DEBUG
                     printf("PhoneLog version : %d\n",yyAttrStackPtr [0-1].Scan.number);
                   #endif
                   if (yyAttrStackPtr [0-1].Scan.number != 1)
                    {
                     ErrorMessage(xxSyntaxError,xxFatal,yyAttrStackPtr [0-1].Scan.Position);
                    }
                  
} break;
case 138:
case 98: /* ENTRY : "<ENTRY>" ENTRY_1 ENTRY_2 HOST ENTRY_3 "</ENTRY>" .*/
  yyStateStackPtr -=6; yyAttrStackPtr -=6; yyNonterminal = 87; {
/* line 117 "t:lalr.tmp" */
/* line 146 "PhoneLogParser.lalr" */

                   if ((Entry.Type == PhoneLog_NORMAL) && (Entry.Hours == 0) && (Entry.Mins == 0) && (Entry.Secs == 0))
                    {
                     /*
                     long days,secs;

                     days = date_HeisDayDiff(Entry.StartDay,Entry.StartMonth,Entry.StartYear,Entry.EndDay,Entry.EndMonth,Entry.EndYear);
                     secs = datetime_TimeDiff(Entry.EndHour,Entry.EndMin,Entry.EndSec,Entry.StartHour,Entry.StartMin,Entry.StartSec);
                     if (days == 0)
                      {
                       datetime_SecToTime(secs,&Entry.Hours,&Entry.Mins,&Entry.Secs);
                      }
                     else
                      {
                       if (secs < 0)
                        {
                         secs += 86400;
                         days--;
                        }
                       datetime_SecToTime(secs,&Entry.Hours,&Entry.Mins,&Entry.Secs);
                       Entry.Hours += days*24;
                      }
                     */
                    }
                   InsertPhoneLogEntry(&Entry);
                  
} break;
case 139:
case 110: /* ENTRY_3 : ENTRY_4 .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 95; {

} break;
case 140:
case 111: /* ENTRY_3 : BUSY .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 95; {

} break;
case 141:
case 112: /* ENTRY_3 : NOANSWER .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 95; {

} break;
case 142:
case 114: /* ENTRY_4 : START END ENTRY_5 .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 96; {

} break;
case 143: /* ENTRY_5 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 101; {

} break;
case 144:
case 115: /* ENTRY_5 : PERIOD .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 101; {

} break;
case 145: /* ENTRY_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 93; {

} break;
case 146:
case 116: /* ENTRY_2 : PROGRAM1 .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 93; {

} break;
case 147: /* ENTRY_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 92; {
/* line 179 "t:lalr.tmp" */
/* line 141 "PhoneLogParser.lalr" */

                   Entry.Number[0] = '\0';
                   Entry.Name[0] = '\0';
                   Entry.Reason[0] = '\0';
                   Entry.ProgramName[0] = '\0';
                   Entry.ProgramVersion = 0;
                   Entry.ProgramRevision = 0;
                   Entry.Type = PhoneLog_NORMAL;
                   Entry.StartDay = 0;
                   Entry.StartMonth = 0;
                   Entry.StartYear = 0;
                   Entry.StartHour = 0;
                   Entry.StartMin = 0;
                   Entry.StartSec = 0;
                   Entry.EndDay = 0;
                   Entry.EndMonth = 0;
                   Entry.EndYear = 0;
                   Entry.EndHour = 0;
                   Entry.EndMin = 0;
                   Entry.EndSec = 0;
                   Entry.Hours = 0;
                   Entry.Mins = 0;
                   Entry.Secs = 0;
                   #ifdef DEBUG
                     printf("\nENTRY\n");
                   #endif
                  
} break;
case 148:
case 92: /* HOST : "<HOST>" NUMBER HOST_1 HOST_2 "</HOST>" .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 94; {

} break;
case 149: /* HOST_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 106; {

} break;
case 150:
case 108: /* HOST_2 : REASON .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 106; {

} break;
case 151: /* HOST_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 105; {

} break;
case 152:
case 109: /* HOST_1 : HOSTNAME .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 105; {

} break;
case 153:
case 89: /* NUMBER : "<NUMBER>" text "</NUMBER>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 104; {
/* line 204 "t:lalr.tmp" */
/* line 190 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   if (strlen(Word) < 31)
                    {
                     strcpy(Entry.Number,Word);
                    }
                   else
                    {
                     strncpy(Entry.Number,Word,30);
                     Entry.Number[30] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  NUMBER  : %s\n",Word);
                   #endif
                  
} break;
case 154:
case 90: /* HOSTNAME : "<HOSTNAME>" text "</HOSTNAME>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 108; {
/* line 223 "t:lalr.tmp" */
/* line 208 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   if (strlen(Word) < 81)
                    {
                     strcpy(Entry.Name,Word);
                    }
                   else
                    {
                     strncpy(Entry.Name,Word,80);
                     Entry.Name[80] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  HOSTNAME: %s\n",Word);
                   #endif
                  
} break;
case 155:
case 91: /* REASON : "<REASON>" text "</REASON>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 107; {
/* line 242 "t:lalr.tmp" */
/* line 226 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   if (strlen(Word) < 81)
                    {
                     strcpy(Entry.Reason,Word);
                    }
                   else
                    {
                     strncpy(Entry.Reason,Word,80);
                     Entry.Reason[0] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  REASON: %s\n",Word);
                   #endif
                  
} break;
case 156:
case 96: /* BUSY : "<BUSY>" BUSY_1 DATE BUSY_2 TIME BUSY_3 "</BUSY>" .*/
  yyStateStackPtr -=7; yyAttrStackPtr -=7; yyNonterminal = 97; {

} break;
case 157: /* BUSY_3 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 113; {
/* line 249 "t:lalr.tmp" */
/* line 247 "PhoneLogParser.lalr" */

                   Entry.StartHour = Hour;
                   Entry.StartMin = Min;
                   Entry.StartSec = Sec;
                  
} break;
case 158: /* BUSY_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 111; {
/* line 257 "t:lalr.tmp" */
/* line 240 "PhoneLogParser.lalr" */

                   Entry.StartDay = Day;
                   Entry.StartMonth = Month;
                   Entry.StartYear = Year;
                  
} break;
case 159: /* BUSY_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 109; {
/* line 269 "t:lalr.tmp" */
/* line 235 "PhoneLogParser.lalr" */

                   Entry.Type = PhoneLog_BUSY;
                   #ifdef DEBUG
                     printf("  BUSY\n");
                   #endif
                  
} break;
case 160:
case 97: /* NOANSWER : "<NOANSWER>" NOANSWER_1 DATE NOANSWER_2 TIME NOANSWER_3 "</NOANSWER>" .*/
  yyStateStackPtr -=7; yyAttrStackPtr -=7; yyNonterminal = 98; {

} break;
case 161: /* NOANSWER_3 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 116; {
/* line 276 "t:lalr.tmp" */
/* line 271 "PhoneLogParser.lalr" */

                   Entry.StartHour = Hour;
                   Entry.StartMin = Min;
                   Entry.StartSec = Sec;
                  
} break;
case 162: /* NOANSWER_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 115; {
/* line 284 "t:lalr.tmp" */
/* line 264 "PhoneLogParser.lalr" */

                   Entry.StartDay = Day;
                   Entry.StartMonth = Month;
                   Entry.StartYear = Year;
                  
} break;
case 163: /* NOANSWER_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 114; {
/* line 296 "t:lalr.tmp" */
/* line 259 "PhoneLogParser.lalr" */

                   Entry.Type = PhoneLog_NOANSWER;
                   #ifdef DEBUG
                     printf("  NOANSWER\n");
                   #endif
                  
} break;
case 164:
case 95: /* START : "<START>" START_1 DATE START_2 TIME START_3 "</START>" .*/
  yyStateStackPtr -=7; yyAttrStackPtr -=7; yyNonterminal = 99; {

} break;
case 165: /* START_3 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 119; {
/* line 303 "t:lalr.tmp" */
/* line 294 "PhoneLogParser.lalr" */

                   Entry.StartHour = Hour;
                   Entry.StartMin = Min;
                   Entry.StartSec = Sec;
                  
} break;
case 166: /* START_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 118; {
/* line 311 "t:lalr.tmp" */
/* line 287 "PhoneLogParser.lalr" */

                   Entry.StartDay = Day;
                   Entry.StartMonth = Month;
                   Entry.StartYear = Year;
                  
} break;
case 167: /* START_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 117; {
/* line 322 "t:lalr.tmp" */
/* line 282 "PhoneLogParser.lalr" */

                   #ifdef DEBUG
                     printf("  START\n");
                   #endif
                  
} break;
case 168:
case 99: /* END : "<END>" END_1 END_2 TIME END_3 "</END>" .*/
  yyStateStackPtr -=6; yyAttrStackPtr -=6; yyNonterminal = 100; {

} break;
case 169: /* END_3 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 122; {
/* line 329 "t:lalr.tmp" */
/* line 320 "PhoneLogParser.lalr" */

                   Entry.EndHour = Hour;
                   Entry.EndMin = Min;
                   Entry.EndSec = Sec;
                  
} break;
case 170: /* END_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 121; {

} break;
case 171:
case 113: /* END_2 : DATE .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 121; {
/* line 338 "t:lalr.tmp" */
/* line 313 "PhoneLogParser.lalr" */

                   Entry.EndDay = Day;
                   Entry.EndMonth = Month;
                   Entry.EndYear = Year;
                  
} break;
case 172: /* END_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 120; {
/* line 352 "t:lalr.tmp" */
/* line 308 "PhoneLogParser.lalr" */

                   Entry.EndDay = Entry.StartDay;
                   Entry.EndMonth = Entry.StartMonth;
                   Entry.EndYear = Entry.StartYear;
                   #ifdef DEBUG
                     printf("  END\n");
                   #endif
                  
} break;
case 173:
case 93: /* DATE : "<DATE>" text "</DATE>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 110; {
/* line 363 "t:lalr.tmp" */
/* line 333 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   sscanf(Word,"%d-%hu-%hu",&Year,&Month,&Day);
                   #ifdef DEBUG
                     printf("    DATE  : %hu.%hu.%d\n",Day,Month,Year);
                   #endif
                  
} break;
case 174:
case 94: /* TIME : "<TIME>" text "</TIME>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 112; {
/* line 374 "t:lalr.tmp" */
/* line 343 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   sscanf(Word,"%hu:%hu:%hu",&Hour,&Min,&Sec);
                   #ifdef DEBUG
                     printf("    TIME  : %hu:%hu:%hu\n",Hour,Min,Sec);
                   #endif
                  
} break;
case 175:
case 100: /* PERIOD : "<PERIOD>" text "</PERIOD>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 102; {
/* line 405 "t:lalr.tmp" */
/* line 373 "PhoneLogParser.lalr" */

                   /*
                   char *h,*m,*s;

                   Entry.Hours = 0;
                   Entry.Mins = 0;
                   Entry.Secs = 0;
                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   h = strchr(Word,(int)'H');
                   m = strchr(Word,(int)'M');
                   s = strchr(Word,(int)'S');
                   if (h != NULL)
                    {
                     Entry.Hours = atoi(Word);
                    }
                   if (m != NULL)
                    {
                     Entry.Mins = atoi(++h);
                    }
                   if (s != NULL)
                    {
                     Entry.Secs = atoi(++m);
                    }
                   #ifdef DEBUG
                     printf("  PERIOD  : %huH%huM%huS\n",Entry.Hours,Entry.Mins,Entry.Secs);
                   #endif
                   */
                  
} break;
case 176:
case 88: /* PROGRAM1 : "<PROGRAM" PROGRAM1_1 ">" text "</PROGRAM>" .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 103; {
/* line 425 "t:lalr.tmp" */
/* line 393 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [4-1].Scan.lexstring,Word);
                   if (strlen(Word) < 32)
                    {
                     strcpy(Entry.ProgramName,Word);
                    }
                   else
                    {
                     strncpy(Entry.ProgramName,Word,31);
                     Entry.ProgramName[31] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  PROGRAM         : %s\n",Word);
                   #endif
                  
} break;
case 177: /* PROGRAM1_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 123; {

} break;
case 178:
case 107: /* PROGRAM1_1 : PROGRAM1ATTR .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 123; {

} break;
case 179:
case 106: /* PROGRAM1ATTR : "version" "=" digits PROGRAM1ATTR_1 PROGRAM1ATTR_2 .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 124; {

} break;
case 180: /* PROGRAM1ATTR_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 126; {

} break;
case 181:
case 87: /* PROGRAM1ATTR_2 : "revision" "=" digits .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 126; {
/* line 439 "t:lalr.tmp" */
/* line 410 "PhoneLogParser.lalr" */

                    Entry.ProgramRevision = (unsigned short)yyAttrStackPtr [3-1].Scan.number;
                    #ifdef DEBUG
                      printf("  PROGRAM revision: %d\n",yyAttrStackPtr [3-1].Scan.number);
                    #endif
                   
} break;
case 182: /* PROGRAM1ATTR_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 125; {
/* line 448 "t:lalr.tmp" */
/* line 402 "PhoneLogParser.lalr" */

                   Entry.ProgramVersion = (unsigned short)yyAttrStackPtr [0-1].Scan.number;
                   #ifdef DEBUG
                     printf("  PROGRAM version : %d\n",yyAttrStackPtr [0-1].Scan.number);
                   #endif
                  
} break;
case 183:
case 104: /* MARK : "<MARK>" MARK_1 PROGRAM2 MARKNAME "</MARK>" .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 88; {
/* line 454 "t:lalr.tmp" */
/* line 429 "PhoneLogParser.lalr" */

                   InsertPhoneLogMark(&Marker);
                  
} break;
case 184: /* MARK_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 127; {
/* line 467 "t:lalr.tmp" */
/* line 424 "PhoneLogParser.lalr" */

                   Marker.ProgramName[0] = '\0';
                   Marker.ProgramVersion = 0;
                   Marker.ProgramRevision = 0;
                   Marker.MarkName[0] = '\0';
                   #ifdef DEBUG
                     printf("\nMARK\n");
                   #endif
                  
} break;
case 185:
case 102: /* PROGRAM2 : "<PROGRAM" PROGRAM2_1 ">" text "</PROGRAM>" .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 128; {
/* line 486 "t:lalr.tmp" */
/* line 447 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [4-1].Scan.lexstring,Word);
                   if (strlen(Word) < 32)
                    {
                     strcpy(Marker.ProgramName,Word);
                    }
                   else
                    {
                     strncpy(Marker.ProgramName,Word,31);
                     Marker.ProgramName[31] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  PROGRAM         : %s\n",Word);
                   #endif
                  
} break;
case 186: /* PROGRAM2_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 130; {

} break;
case 187:
case 118: /* PROGRAM2_1 : PROGRAM2ATTR .*/
  yyStateStackPtr -=1; yyAttrStackPtr -=1; yyNonterminal = 130; {

} break;
case 188:
case 117: /* PROGRAM2ATTR : "version" "=" digits PROGRAM2ATTR_1 PROGRAM2ATTR_2 .*/
  yyStateStackPtr -=5; yyAttrStackPtr -=5; yyNonterminal = 131; {

} break;
case 189: /* PROGRAM2ATTR_2 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 133; {

} break;
case 190:
case 101: /* PROGRAM2ATTR_2 : "revision" "=" digits .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 133; {
/* line 500 "t:lalr.tmp" */
/* line 464 "PhoneLogParser.lalr" */

                    Marker.ProgramRevision = (unsigned short)yyAttrStackPtr [3-1].Scan.number;
                    #ifdef DEBUG
                      printf("  PROGRAM revision: %d\n",yyAttrStackPtr [3-1].Scan.number);
                    #endif
                   
} break;
case 191: /* PROGRAM2ATTR_1 : .*/
  yyStateStackPtr -=0; yyAttrStackPtr -=0; yyNonterminal = 132; {
/* line 509 "t:lalr.tmp" */
/* line 456 "PhoneLogParser.lalr" */

                   Marker.ProgramVersion = (unsigned short)yyAttrStackPtr [0-1].Scan.number;
                   #ifdef DEBUG
                     printf("  PROGRAM version : %d\n",yyAttrStackPtr [0-1].Scan.number);
                   #endif
                  
} break;
case 192:
case 103: /* MARKNAME : "<MARKNAME>" text "</MARKNAME>" .*/
  yyStateStackPtr -=3; yyAttrStackPtr -=3; yyNonterminal = 129; {
/* line 528 "t:lalr.tmp" */
/* line 483 "PhoneLogParser.lalr" */

                   StGetString(yyAttrStackPtr [2-1].Scan.lexstring,Word);
                   if (strlen(Word) < 256)
                    {
                     strcpy(Marker.MarkName,Word);
                    }
                   else
                    {
                     strncpy(Marker.MarkName,Word,255);
                     Marker.MarkName[255] = '\0';
                    }
                   #ifdef DEBUG
                     printf("  MARKNAME        : %s\n",Word);
                   #endif
                  
} break;
}
          /* SPEC State = Next(Top(),Nonterminal); nonterminal transition */
          yyState = *(yyNBasePtr[*yyStateStackPtr++] + yyNonterminal);
          *yyAttrStackPtr++ = yySynAttribute; /* ??? */
          if (yyState < yyFirstFinalState)
            goto ParseLoop; /* read nonterminal reduce ? */
         }
       }
      else
       {/* read */
        yyStateStackPtr++;
       yyGetAttribute(yyAttrStackPtr++,PhoneLogScanner_Attribute);
       yyTerminal = PhoneLogScanner_GetToken();
        yyIsRepairing = false;
       }
     }
 }


static void yyErrorRecovery(yySymbolRange *yyTerminal, yyStateRange *yyStateStack, unsigned long yyStackSize, short yyStackPtr)
 {
  bool yyTokensSkipped;
  tSet yyContinueSet;
  tSet yyRestartSet;
  int yyLength = 0;
  char yyContinueString[256];

  /* 1. report an error */
 ErrorMessage(xxSyntaxError,xxError,PhoneLogScanner_Attribute.Position);
  /* 2. report the set of expected terminal symbols */
  MakeSet(&yyContinueSet,(short)yyLastTerminal);
  yyComputeContinuation(yyStateStack,yyStackSize,yyStackPtr,&yyContinueSet);
  yyContinueString[0] = '\0';
  while (!IsEmpty(&yyContinueSet))
   {
   char *yyTokenString = PhoneLogParser_TokenName[Extract(&yyContinueSet)];
    if ((yyLength += strlen(yyTokenString)+1) >= 256)
      break;
    strcat(yyContinueString,yyTokenString);
    strcat(yyContinueString," ");
   }
 ErrorMessageI(xxExpectedTokens,xxInformation,PhoneLogScanner_Attribute.Position,xxString,yyContinueString);
  ReleaseSet(&yyContinueSet);
  /* 3. compute the set of terminal symbols for restart of the parse */
  MakeSet(&yyRestartSet,(short)yyLastTerminal);
  yyComputeRestartPoints(yyStateStack,yyStackSize,yyStackPtr,&yyRestartSet);
  /* 4. skip terminal symbols until a restart point is reached */
  yyTokensSkipped = false;
  while (!IsElement(*yyTerminal,&yyRestartSet))
   {
   *yyTerminal = PhoneLogScanner_GetToken();
    yyTokensSkipped = true;
   }
  ReleaseSet(&yyRestartSet);
  /* 5. report the restart point */
  if (yyTokensSkipped)
   {
   ErrorMessage(xxRestartPoint,xxInformation,PhoneLogScanner_Attribute.Position);
   }
 }


/* compute the set of terminal symbols that can be accepted (read)
   in a given stack configuration (eventually after reduce actions) */

static void yyComputeContinuation(yyStateRange *yyStack, unsigned long yyStackSize, short yyStackPtr, tSet *yyContinueSet)
 {
  register yySymbolRange yyTerminal;
  register yyStateRange yyState = yyStack[yyStackPtr];

  AssignEmpty(yyContinueSet);
  for (yyTerminal = yyFirstTerminal;yyTerminal <= yyLastTerminal;yyTerminal++)
   {
    if (yyNext(yyState,yyTerminal) != yyNoState && yyIsContinuation(yyTerminal,yyStack,yyStackSize,yyStackPtr))
      Include(yyContinueSet,(short)yyTerminal);
   }
 }


/* check whether a given terminal symbol can be accepted (read)
   in a certain stack configuration (eventually after reduce actions) */

static bool yyIsContinuation(yySymbolRange yyTerminal, yyStateRange *yyStateStack, unsigned long yyStackSize, short yyStackPtr)
 {
  register yyStateRange yState;
  register yySymbolRange yyNonterminal;
  yyStateRange *yyStack;

  MakeArray ((char **)&yyStack,&yyStackSize,sizeof(yyStateRange)); /* pass Stack by value */
  #ifdef BCOPY
    bcopy((char *)yyStateStack,(char *)yyStack,(int)sizeof(yyStateRange) * (yyStackPtr+1));
  #else
    memcpy((char *)yyStack,(char *)yyStateStack,(int)sizeof(yyStateRange) * (yyStackPtr+1));
  #endif
  yState = yyStack[yyStackPtr];
  for (;;)
   {
    yyStack[yyStackPtr] = yState;
    yState = yyNext(yState, yyTerminal);
    if (yState == yyNoState)
     {
      ReleaseArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
      return false;
     }
    if (yState <= yyLastReadTermState)
     {/* read or read terminal reduce ? */
      ReleaseArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
      return true;
     }
    for (;;)
     {/* reduce */
      if (yState == yyStopState)
       {
        ReleaseArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
        return true;
       }
      else
       {
        yyStackPtr -= yyLength[yState - yyFirstReduceState];
        yyNonterminal = yyLeftHandSide[yState - yyFirstReduceState];
       }
      yState = yyNext(yyStack[yyStackPtr],yyNonterminal);
      if (yyStackPtr >= yyStackSize)
       {
        ExtendArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
       }
      yyStackPtr++;
      if (yState < yyFirstFinalState)
        break; /* read nonterminal ? */
      yState = yyFinalToProd[yState - yyFirstReadTermState]; /* read nonterminal reduce */
     }
   }
 }


/* compute a set of terminal symbols that can be used to restart
   parsing in a given stack configuration. we simulate parsing until
   end of file using a suffix program synthesized by the function
   Continuation. All symbols acceptable in the states reached during
   the simulation can be used to restart parsing. */

static void yyComputeRestartPoints(yyStateRange *yyStateStack, unsigned long yyStackSize, short yyStackPtr, tSet *yyRestartSet)
 {
  register yyStateRange yState;
  register yySymbolRange yyNonterminal;
  yyStateRange *yyStack;
  tSet yyContinueSet;

  MakeArray ((char **)&yyStack,&yyStackSize,sizeof(yyStateRange)); /* pass Stack by value */
  #ifdef BCOPY
    bcopy((char *)yyStateStack,(char *)yyStack,(int)sizeof(yyStateRange) * (yyStackPtr+1));
  #else
    memcpy((char *)yyStack,(char *)yyStateStack,(int)sizeof(yyStateRange) * (yyStackPtr+1));
  #endif
  MakeSet(&yyContinueSet,(short)yyLastTerminal);
  AssignEmpty(yyRestartSet);
  yState = yyStack[yyStackPtr];
  for (;;)
   {
    if (yyStackPtr >= yyStackSize)
      ExtendArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
    yyStack[yyStackPtr] = yState;
    yyComputeContinuation(yyStack,yyStackSize,yyStackPtr,&yyContinueSet);
    Union(yyRestartSet,&yyContinueSet);
    yState = yyNext(yState,yyContinuation[yState]);
    if (yState >= yyFirstFinalState)
     {/* final state ? */
      if (yState <= yyLastReadTermState)
       {/* read terminal reduce ? */
        yyStackPtr++;
        yState = yyFinalToProd[yState - yyFirstReadTermState];
       }
      for (;;)
       {/* reduce */
        if (yState == yyStopState)
         {
          ReleaseSet(&yyContinueSet);
          ReleaseArray((char **)&yyStack,&yyStackSize,sizeof(yyStateRange));
          return;
         }
        else
         {
          yyStackPtr -= yyLength[yState - yyFirstReduceState];
          yyNonterminal = yyLeftHandSide[yState - yyFirstReduceState];
         }
        yState = yyNext(yyStack[yyStackPtr],yyNonterminal);
        yyStackPtr++;
        if (yState < yyFirstFinalState)
          break; /* read nonterminal ? */
        yState = yyFinalToProd[yState - yyFirstReadTermState]; /* read nonterminal reduce */
       }
     }
    else
     {/* read */
      yyStackPtr++;
     }
   }
 }


/* access the parse table:   Next : State x Symbol -> Action */

static yyStateRange yyNext(yyStateRange yyState,yySymbolRange yySymbol)
 {
  register yyTCombType *yyTCombPtr;

  if (yySymbol <= yyLastTerminal)
   {
    for (;;)
     {
      yyTCombPtr = yyTBasePtr[yyState] + yySymbol;
      if (yyTCombPtr->Check != yyState)
       {
        if ((yyState = yyDefault[yyState]) == yyNoState)
          return yyNoState;
       }
      else
        return yyTCombPtr->Next;
     }
   }
  else
    return *(yyNBasePtr[yyState] + yySymbol);
 }


static void BeginPhoneLogParser(void)
 {
/* line 33 "t:lalr.tmp" */
/* line 32 "PhoneLogParser.lalr" */
/* BEGIN */
        /* BEGIN */
 }


void ClosePhoneLogParser(void)
 {

 }

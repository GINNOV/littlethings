#ifndef _PATHS_H_
#define _PATHS_H_

#include <ace/types.h>

/*
[0] HorizontalLeft.json
[1] HorizontalRight.json
[2] LoopCenterLeft.json
[3] LoopCenterRight.json
[4] LoopDownLeft.json
[5] LoopDownRight.json
[6] LoopLeft.json
[7] LoopRight.json
[8] ParabolaLeft.json
[9] ParabolaRight.json
[10] SineLeft1.json
[11] SineLeft2.json
[12] SineLeft3.json
[13] SineLeft4.json
[14] SineRight4.json
[15] SineRight5.json
[16] SineRight6.json
[17] SineRight7.json
[18] SquiggleLeft.json
[19] SquiggleRight.json
[20] ZigzagLeft.json
[21] ZigzagRight.json
*/

UWORD g_uwPathOffset[] = {0, 514, 1028, 2054, 3080, 4106, 5132, 6414, 7696, 8722, 9748, 11286, 13080, 14874, 16668, 18462, 20000, 21538, 23076, 24614, 26152, 26922};
UWORD g_uwPathLength[] = {514, 514, 1026, 1026, 1026, 1026, 1282, 1282, 1026, 1026, 1538, 1794, 1794, 1794, 1794, 1538, 1538, 1538, 1538, 1538, 770, 770};
UBYTE g_ubPathData[27692] = {0};

#endif
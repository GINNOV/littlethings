#ifndef _AMINER_GROUND_LAYER_H_
#define _AMINER_GROUND_LAYER_H_

#include <ace/utils/extview.h>

void groundLayerCreate(const tVPort *pVp);

void groundLayerProcess(UWORD uwCameraY, UBYTE ubColorLevel, UWORD uwSecondaryColor);

void groundLayerReset(UBYTE ubLowerLayer, UWORD uwSecondaryColor);

UWORD groundLayerGetLowerAtDepth(UWORD uwY);

UBYTE groundLayerGetDifficultyAtDepth(UWORD uwDepth);

#endif // _AMINER_GROUND_LAYER_H_

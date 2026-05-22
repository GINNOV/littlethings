/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GUI_BORDER_H
#define GUI_BORDER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <ace/utils/bitmap.h>
#include "config.h"

static inline void guiDraw3dBorder(
	tBitMap *pBfr, UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight
) {
	const tGuiConfig *pCfg = guiGetConfig();
	// Draw border
	blitRect(pBfr, uwX, uwY, uwWidth, 1, pCfg->ubColorLight);
	blitRect(pBfr, uwX, uwY, 1, uwHeight, pCfg->ubColorLight);
	blitRect(pBfr, uwX + 1, uwY + uwHeight-1, uwWidth - 1, 1, pCfg->ubColorDark);
	blitRect(pBfr, uwX + uwWidth - 1, uwY + 1, 1, uwHeight - 1, pCfg->ubColorDark);
}

#ifdef __cplusplus
}
#endif

#endif // GUI_BORDER_H

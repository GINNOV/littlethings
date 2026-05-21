/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "utf8_remap.h"

char remapChar(const tCodeRemap *pRemap, ULONG ulCodepoint) {
	UWORD j;
	for(j = 0; pRemap[j].ulCodepoint != 0; ++j) {
		if(pRemap[j].ulCodepoint == ulCodepoint) {
			return pRemap[j].ubFontCode;
		}
	}
	return (char)ulCodepoint;
}

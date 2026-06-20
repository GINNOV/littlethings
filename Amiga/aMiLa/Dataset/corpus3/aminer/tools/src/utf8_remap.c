/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "utf8_remap.h"
#include <stdio.h>
#include <stdlib.h>
#include "utf8.h"

char remapChar(const tCodeRemap *pRemap, uint32_t ulCodepoint) {
	if(ulCodepoint < 128) {
		return (char)ulCodepoint;
	}
	for(uint16_t j = 0; pRemap[j].ulCodepoint != 0; ++j) {
		if(pRemap[j].ulCodepoint == ulCodepoint) {
			return pRemap[j].ubFontCode;
		}
	}

	return '\xFF';
}

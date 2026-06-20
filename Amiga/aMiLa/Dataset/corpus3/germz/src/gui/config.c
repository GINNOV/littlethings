/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "config.h"

tGuiConfig s_sConfig = {
	.ubColorLight = 12,
	.ubColorDark = 3,
	.ubColorFill = 7,
	.ubColorText = 13
};

tGuiConfig *guiGetConfig(void) {
	return &s_sConfig;
}

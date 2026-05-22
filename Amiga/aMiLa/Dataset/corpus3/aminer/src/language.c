/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "language.h"
#include <ace/managers/log.h>

static tLanguage s_eLanguage;

void languageSet(tLanguage eLanguage) {
	s_eLanguage = eLanguage;
	logWrite("Set language: %s", languageGetPrefix());
}

const char *languageGetPrefix(void) {
	switch (s_eLanguage) {
		case LANGUAGE_ENGLISH:
			return "en";
		case LANGUAGE_POLISH:
			return "pl";
		default:
			while(1) continue;
	}
}

tLanguage languageGet(void) {
	return s_eLanguage;
}

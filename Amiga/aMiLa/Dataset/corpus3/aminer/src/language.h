/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _LANGUAGE_H_
#define _LANGUAGE_H_

typedef enum tLanguage {
	LANGUAGE_ENGLISH,
	LANGUAGE_POLISH,
	LANGUAGE_COUNT
} tLanguage;

void languageSet(tLanguage eLanguage);

tLanguage languageGet(void);

const char *languageGetPrefix(void);

#endif // _LANGUAGE_H_

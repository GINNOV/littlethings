/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_ESCAPE_H_
#define _AMINER_COMM_PAGE_ESCAPE_H_

typedef enum tPageEscapeScenario {
	PAGE_ESCAPE_SCENARIO_AGENT,
	PAGE_ESCAPE_SCENARIO_TELEPORT,
} tPageEscapeScenario;

void pageEscapeCreate(tPageEscapeScenario eScenario);

#endif // _AMINER_COMM_PAGE_ESCAPE_H_

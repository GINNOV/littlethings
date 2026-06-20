/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_MSG_H_
#define _AMINER_COMM_PAGE_MSG_H_

#include "face_id.h"

typedef void (*tOnClose)(void);

void pageMsgCreate(
	tFaceId eFace, const char *szTitle, const char *szFile, tOnClose cbOnClose
);

#endif // _AMINER_COMM_PAGE_MSG_H_

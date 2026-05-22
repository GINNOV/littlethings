/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_GS_MSG_H_
#define _AMINER_COMM_GS_MSG_H_

#include "aminer.h"
#include "face_id.h"

extern tState g_sStateMsg;

void gsMsgInit(
	tFaceId eFace, const char *szMessageFile, const char *szMessageTitle
);

#endif // _AMINER_COMM_GS_MSG_H_

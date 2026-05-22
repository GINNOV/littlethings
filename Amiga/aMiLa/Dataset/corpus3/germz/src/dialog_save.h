/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_DIALOG_SAVE_H
#define GERMZ_DIALOG_SAVE_H

#include <ace/types.h>

void dialogSaveShow(UBYTE isQuitting);

void dialogSaveSetSaveName(const char *szPath, const char *szName);

#endif // GERMZ_DIALOG_SAVE_H

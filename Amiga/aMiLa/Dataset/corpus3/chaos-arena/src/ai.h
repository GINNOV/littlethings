/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_AI_H
#define INCLUDE_AI_H

#include <ace/types.h>
#include "anim.h"
#include "direction.h"

struct tWarrior;

typedef enum tAiState {
	AI_STATE_MOVING,
	AI_STATE_ATTACKING,
	AI_STATE_COUNT
} tAiState;

typedef struct tAi {
	struct tWarrior *pWarrior;
	tAiState eState;
	tAnimDirection eNextAttackDirection;
	tAnimDirection eNextMovementDirection;
	UBYTE ubMovementCooldown;
} tAi;

void aiInit(tAi *pAi, struct tWarrior *pWarrior);

tDirection aiProcess(tAi *pAi);

#endif // INCLUDE_AI_H

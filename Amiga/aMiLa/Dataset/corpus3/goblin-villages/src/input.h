#ifndef GUARD_MANAGER_INPUT_H
#define GUARD_MANAGER_INPUT_H

#include <clib/exec_protos.h> // Amiga typedefs
#include <clib/intuition_protos.h> // IDCMP_RAWKEY etc

#include "config.h"

#include "ACE:managers/window.h"
#include "ACE:managers/key.h"
#include "ACE:managers/mouse.h"
#include "ACE:managers/joy.h"
#include "ACE:managers/log.h"

/* Types */

/* Globals */

/* Functions */
void inputOpen(void);

void inputProcess(void);

void inputClose(void);

#endif
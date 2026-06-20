#include <exec/memory.h>
#include <proto/exec.h>
#include <ctype.h>

#define VBCC=1
#define MWDEBUG=1				/* To enable memlib, you must #define MWDEBUG to 1 */

#include "memwatch.h"

#include "stringlib.h"			/* ADOSLIB und STRINGLIB müssen gelinkt werden */


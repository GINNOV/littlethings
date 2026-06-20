/*
 *	File:					System.h
 *	Description:	
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef SYSTEM_H
#define	SYSTEM_H

/*** DEFINES *************************************************************************/
#define INTUI_V36_NAMES_ONLY
#define __USE_SYSBASE
#define USE_BUILTIN_MATH

/*** GLOBAL SYSTEM INCLUDES **********************************************************/
#include <utility/utility.h>
#include <utility/tagitem.h>
#include <exec/memory.h>
#include <exec/ports.h>

#include <string.h>
#include <stdlib.h>

/*** SYSTEM PROTOTYPES **************************************************************/
#include <clib/macros.h>
#include <clib/alib_stdio_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>
#include <clib/exec_protos.h>

/*** PRIVATE INCLUDES ****************************************************************/
#include "myinclude:BitMacros.h"
#include "Arexx Interface Designer_rev.h"

/*** APPLICATION INCLUDES ************************************************************/
//#include "myinclude:mydebug.h"
#include "GUI_Environment.h"
#include "TASK_Main.h"
#include "list.h"

#endif

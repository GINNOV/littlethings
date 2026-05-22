/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: PreInclude.c
**		$DESCRIPTION: Header file for the GST.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/libraries.h>

#include <dos.h>
#include <dos/dosextens.h>

#include "Register.h"
#include "LibBase.h"
#include "String.h"
#include "Misc.h"
#include "CFConv.h"
#include "OLibTagged.h"
#include <Libraries/ConfigFile.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/rexxsyslib_protos.h>
#include <clib/configfile_protos.h>

#include <rexx/storage.h>
#include <rexx/errors.h>
#include <rexx/rexxio.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/rexxsyslib_pragmas.h>
#include <pragmas/configfile_pragmas.h>

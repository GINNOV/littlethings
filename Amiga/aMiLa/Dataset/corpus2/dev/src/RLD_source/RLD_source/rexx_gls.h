/*
  $Id: rexx_gls.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
  
  $Log: rexx_gls.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(REXX_GLS_H)
#define REXX_GLS_H

/* Avoid the creation of global library base pointers, and refer them
   to copies hed in our own library base instead. */

#define DOS_BASE_NAME 		RglsBase->rgls_DOSBase
#define EXEC_BASE_NAME 		RglsBase->rgls_SYSBase
#define LOCALE_BASE_NAME        RglsBase->rgls_LocaleBase
#define REXXSYSLIB_BASE_NAME 	RglsBase->rgls_RexxSysBase
#define UTILITY_BASE_NAME 	RglsBase->rgls_UtilityBase

#include <proto/alib.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/rexxsyslib.h>
#include <proto/locale.h>
#include <proto/utility.h>
#include <rexx/errors.h>

#include "rexx_gls_base.h"
#include "debugstub.h"

#endif /* REXX_GLS_H */

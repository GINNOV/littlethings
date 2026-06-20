#ifndef _PROTO_WIZARD_H
#define _PROTO_WIZARD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_WIZARD_PROTOS_H
#include <clib/wizard_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *WizardBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/wizard.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/wizard_lib.h>
#endif
#endif

#endif	/*  _PROTO_WIZARD_H  */

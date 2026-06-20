#ifndef BOOPSISTUBS_H
#define BOOPSISTUBS_H
/*
**	$Id: BoopsiStubs.h,v 1.2 1999/02/07 14:41:01 bernie Exp $
**
**	Copyright (C) 1997,99 Bernardo Innocenti <bernie@cosmos.it>
**	All rights reserved.
**
**	Use 4 chars wide TABs to read this file
**
**	Using these inline versions of the amiga.lib boopsi support functions
**	results in faster and smaller code against their linked library
**	counterparts. When debug is active, these functions will also
**	validate the parameters you pass in.
*/

#ifndef COMPILERSPECIFIC_H
#include "CompilerSpecific.h"
#endif /* COMPILERSPECIFIC_H */

#ifndef DEBUGMACROS_H
#include "DebugMacros.h"
#endif /* DEBUGMACROS_H */

/* This definition will prevent the redefinition of the following stubs with
 * their amiga.lib equivalents. This trick only works if you are using a patched
 * version of <clib/alib_protos.h>
 */
#define USE_BOOPSI_STUBS



/* the _HookPtr type is a shortcut for a pointer to a hook function */

typedef ASMCALL ULONG (*HookPtr)
	(REG(a0, Class *), REG(a2, Object *), REG(a1, APTR));

INLINE ULONG CoerceMethodA(Class *cl, Object *o, Msg msg)
{
	ASSERT_VALID_PTR(cl)
	ASSERT_VALID_PTR_OR_NULL(o)

	return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)msg);
}

INLINE ULONG DoSuperMethodA(Class *cl, Object *o, Msg msg)
{
	ASSERT_VALID_PTR(cl)
	ASSERT_VALID_PTR_OR_NULL(o)

	cl = cl->cl_Super;
	return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)msg);
}

INLINE ULONG DoMethodA(Object *o, Msg msg)
{
	Class *cl;
	ASSERT_VALID_PTR(o)
	cl = OCLASS (o);
	ASSERT_VALID_PTR(cl)

	return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)msg);
}



/* Var-args versions of the above functions.  SAS/C is clever enough to inline these,
 * while gcc and egcs refuse to inline a function with '...' (yikes!).  The GCC
 * versions of these functions are macro blocks similar to those  used in the
 * inline/#?.h headers.
 */
#if defined(__SASC) || defined (__STORM__)

	INLINE ULONG CoerceMethod(Class *cl, Object *o, ULONG MethodID, ...)
	{
		ASSERT_VALID_PTR(cl)
		ASSERT_VALID_PTR_OR_NULL(o)

		return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)&MethodID);
	}

	INLINE ULONG DoSuperMethod(Class *cl, Object *o, ULONG MethodID, ...)
	{
		ASSERT_VALID_PTR(cl)
		ASSERT_VALID_PTR_OR_NULL(o)

		cl = cl->cl_Super;
		return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)&MethodID);
	}

	INLINE ULONG DoMethod(Object *o, ULONG MethodID, ...)
	{
		Class *cl;

		ASSERT_VALID_PTR(o)
		cl = OCLASS (o);
		ASSERT_VALID_PTR(cl)

		return ((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)&MethodID);
	}

	/* varargs stub for the OM_NOTIFY method */
	INLINE void NotifyAttrs(Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...)
	{
		ASSERT_VALID_PTR(o)
		ASSERT_VALID_PTR_OR_NULL(gi)

		DoMethod(o, OM_NOTIFY, &attr1, gi, flags);
	}

	/* varargs stub for the OM_UPDATE method */
	INLINE void UpdateAttrs(Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...)
	{
		ASSERT_VALID_PTR(o)
		ASSERT_VALID_PTR_OR_NULL(gi)

		DoMethod(o, OM_UPDATE, &attr1, gi, flags);
	}

	/* varargs stub for the OM_SET method. Similar to SetAttrs(), but allows
	 * to pass the GadgetInfo structure
	 */
	INLINE void SetAttrsGI(Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...)
	{
		ASSERT_VALID_PTR(o)
		ASSERT_VALID_PTR_OR_NULL(gi)

		DoMethod(o, OM_SET, &attr1, gi, flags);
	}

#elif defined(__GNUC__)

	#define CoerceMethod(cl, o, msg...)												\
	({																				\
		ULONG _msg[] = { msg };														\
		ASSERT_VALID_PTR(cl)														\
		ASSERT_VALID_PTR_OR_NULL(o)													\
		((HookPtr)cl->cl_Dispatcher.h_Entry) ((APTR)cl, (APTR)o, (APTR)_msg);		\
	})

	#define DoSuperMethod(cl, o, msg...)											\
	({																				\
		Class *_cl;																	\
		ULONG _msg[] = { msg };														\
		ASSERT_VALID_PTR(cl)														\
		ASSERT_VALID_PTR_OR_NULL(o)													\
		_cl = cl = cl->cl_Super;													\
		ASSERT_VALIDNO0(_cl)														\
		((HookPtr)_cl->cl_Dispatcher.h_Entry) ((APTR)_cl, (APTR)o, (APTR)_msg);		\
	})

	#define DoMethod(o, msg...)														\
	({																				\
		Class *_cl;																	\
		ULONG _msg[] = { msg };														\
		ASSERT_VALID_PTR(o)															\
		_cl = OCLASS(o);															\
		ASSERT_VALID_PTR_OR_NULL(_cl)												\
		((HookPtr)_cl->cl_Dispatcher.h_Entry) ((APTR)_cl, (APTR)o, (APTR)_msg);		\
	})

	/* Var-args stub for the OM_NOTIFY method */
	#define NotifyAttrs(o, gi, flags, attrs...)										\
	({																				\
		Class *_cl;																	\
		ULONG _attrs[] = { attrs };													\
		ULONG _msg[] = { OM_NOTIFY, (ULONG)_attrs, (ULONG)gi, flags };				\
		ASSERT_VALID_PTR(o)															\
		_cl = OCLASS(o);															\
		ASSERT_VALID_PTR(_cl)														\
		ASSERT_VALID_PTR_OR_NULL(gi)												\
		((HookPtr)_cl->cl_Dispatcher.h_Entry) ((APTR)_cl, (APTR)o, (APTR)_msg);		\
	})

	/* Var-args stub for the OM_UPDATE method */
	#define UpdateAttrs(o, gi, flags, attrs...)										\
	({																				\
		Class *_cl;																	\
		ULONG _attrs[] = { attrs };													\
		ULONG _msg[] = { OM_UPDATE, (ULONG)_attrs, (ULONG)gi, flags };				\
		ASSERT_VALID_PTR(o)															\
		_cl = OCLASS(o);															\
		ASSERT_VALID_PTR(_cl)														\
		ASSERT_VALID_PTR_OR_NULL(gi)												\
		((HookPtr)_cl->cl_Dispatcher.h_Entry) ((APTR)_cl, (APTR)o, (APTR)_msg);		\
	})
#endif

#endif /* !BOOPSISTUBS_H */

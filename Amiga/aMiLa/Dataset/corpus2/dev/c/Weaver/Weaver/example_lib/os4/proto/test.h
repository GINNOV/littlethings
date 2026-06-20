/*
 * PROTO file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef PROTO_TEST_H
#define PROTO_TEST_H

#if defined(__AROS__)
	#include	<exec/types.h>
	#include	<aros/system.h>

	#include	<clib/test_protos.h>

	#if !defined(TestBase) && !defined(__NOLIBBASE__) && !defined(__TEST_NOLIBBASE__)
		extern struct Library * TestBase;
	#endif

	#if !defined(NOLIBDEFINES) && !defined(TEST_NOLIBDEFINES)
		#include <defines/test.h>
	#endif

#else	/* End AROS definitions */
	/********************************************************************/
	#ifndef __NOLIBBASE__
		#ifndef __USE_BASETYPE__
			extern struct Library * TestBase;
		#else
			extern struct Library * TestBase;
		#endif /* __USE_BASETYPE__ */
	#endif /* __NOLIBBASE__ */
	/********************************************************************/
	#if defined(__amigaos4__)
		#include <interfaces/test.h>
		#if defined(__USE_INLINE__)
			#include <inline4/test.h>
		#endif /* End __USE_INLINE__ */
		#if !defined(CLIB_TEST_PROTOS_H)
			#define CLIB_TEST_PROTOS_H 1
		#endif /* End OS4 CLIB_TEST_PROTOS_H */
		#if !defined(__NOGLOBALIFACE__)
			extern struct TestIFace *ITest;
		#endif /* End __NOGLOBALIFACE__ */
	#else /* End AmigaOS4; start MorphOS and/or m68k */
	/********************************************************************/
		#if !defined(CLIB_TEST_PROTOS_H)
			#include <clib/test_protos.h>
		#endif /* End __ALL_OTHERS__ CLIB_TEST_PROTOS_H */
		#if defined(__GNUC__)
			#if !defined(__PPC__)
				#include <inline/test.h>
			#else		/* End __GNUC__ and m68k */
				#include <ppcinline/test.h>
			#endif /* End __GNUC__ and MorphOS */
		#else		/* End __GNUC__ */
			#if defined(__VBCC__)
				#include <inline/test_protos.h>
			#else		/* End __VBCC__ */
				#include <pragma/test_lib.h>
			#endif		/* End __ALL_OTHERS__ (m68k, SAS/C for example) */
		#endif		/* m68k and/or MorphOS */
	#endif		/* End all */
/********************************************************************/
#endif /* AROS, OS4, MORPHOS, OS3 */

#endif /* PROTO_TEST_H */

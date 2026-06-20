/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_ICONV_H
#define _PPCINLINE_ICONV_H

#ifndef __PPCINLINE_MACROS_H
#include <ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef ICONV_BASE_NAME
#define ICONV_BASE_NAME IConvBase
#endif /* !ICONV_BASE_NAME */

#define libiconvctl(__p0, __p1, __p2) \
	({ \
		iconv_t  __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((int (*)(iconv_t , int , void *))*(void**)(__base - 46))(__t__p0, __t__p1, __t__p2));\
	})

#define libiconvlist(__p0, __p1) \
	({ \
		int (* __t__p0) (unsigned int namescount, const char * const * names, void* data) = __p0;\
		void * __t__p1 = __p1;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(int (*) (unsigned int namescount, const char * const * names, void* data), void *))*(void**)(__base - 52))(__t__p0, __t__p1));\
	})

#define libiconv_close(__p0) \
	({ \
		iconv_t  __t__p0 = __p0;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((int (*)(iconv_t ))*(void**)(__base - 40))(__t__p0));\
	})

#define libiconv_set_relocation_prefix(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const char *, const char *))*(void**)(__base - 58))(__t__p0, __t__p1));\
	})

#define libiconv(__p0, __p1, __p2, __p3, __p4) \
	({ \
		iconv_t  __t__p0 = __p0;\
		const char ** __t__p1 = __p1;\
		size_t * __t__p2 = __p2;\
		char ** __t__p3 = __p3;\
		size_t * __t__p4 = __p4;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((size_t (*)(iconv_t , const char **, size_t *, char **, size_t *))*(void**)(__base - 34))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define iconv_canonicalize(__p0) \
	({ \
		const char * __t__p0 = __p0;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((const char *(*)(const char *))*(void**)(__base - 64))(__t__p0));\
	})

#define libiconv_open(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(ICONV_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((iconv_t (*)(const char *, const char *))*(void**)(__base - 28))(__t__p0, __t__p1));\
	})

#endif /* !_PPCINLINE_ICONV_H */

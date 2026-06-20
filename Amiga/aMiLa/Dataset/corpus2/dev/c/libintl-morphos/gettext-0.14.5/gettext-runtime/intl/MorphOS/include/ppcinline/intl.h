/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_INTL_H
#define _PPCINLINE_INTL_H

#ifndef __PPCINLINE_MACROS_H
#include <ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef INTL_BASE_NAME
#define INTL_BASE_NAME IntlBase
#endif /* !INTL_BASE_NAME */

#define libintl_ngettext(__p0, __p1, __p2) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		unsigned long int  __t__p2 = __p2;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, unsigned long int ))*(void**)(__base - 46))(__t__p0, __t__p1, __t__p2));\
	})

#define libintl_dngettext(__p0, __p1, __p2, __p3) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const char * __t__p2 = __p2;\
		unsigned long int  __t__p3 = __p3;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, const char *, unsigned long int ))*(void**)(__base - 52))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define gettext(__p0) \
	({ \
		const char * __t__p0 = __p0;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *))*(void**)(__base - 82))(__t__p0));\
	})

#define libintl_dcngettext(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const char * __t__p2 = __p2;\
		unsigned long int  __t__p3 = __p3;\
		int  __t__p4 = __p4;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, const char *, unsigned long int , int ))*(void**)(__base - 58))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define libintl_bindtextdomain(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 70))(__t__p0, __t__p1));\
	})

#define dgettext(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 88))(__t__p0, __t__p1));\
	})

#define libintl_textdomain(__p0) \
	({ \
		const char * __t__p0 = __p0;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *))*(void**)(__base - 64))(__t__p0));\
	})

#define dcgettext(__p0, __p1, __p2) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, int ))*(void**)(__base - 94))(__t__p0, __t__p1, __t__p2));\
	})

#define libintl_bind_textdomain_codeset(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 76))(__t__p0, __t__p1));\
	})

#define libintl_gettext(__p0) \
	({ \
		const char * __t__p0 = __p0;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *))*(void**)(__base - 28))(__t__p0));\
	})

#define ngettext(__p0, __p1, __p2) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		unsigned long int  __t__p2 = __p2;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, unsigned long int ))*(void**)(__base - 100))(__t__p0, __t__p1, __t__p2));\
	})

#define libintl_dgettext(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 34))(__t__p0, __t__p1));\
	})

#define dngettext(__p0, __p1, __p2, __p3) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const char * __t__p2 = __p2;\
		unsigned long int  __t__p3 = __p3;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, const char *, unsigned long int ))*(void**)(__base - 106))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define libintl_dcgettext(__p0, __p1, __p2) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, int ))*(void**)(__base - 40))(__t__p0, __t__p1, __t__p2));\
	})

#define bindtextdomain(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 124))(__t__p0, __t__p1));\
	})

#define dcngettext(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const char * __t__p2 = __p2;\
		unsigned long int  __t__p3 = __p3;\
		int  __t__p4 = __p4;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *, const char *, unsigned long int , int ))*(void**)(__base - 112))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define textdomain(__p0) \
	({ \
		const char * __t__p0 = __p0;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *))*(void**)(__base - 118))(__t__p0));\
	})

#define bind_textdomain_codeset(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(INTL_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const char *, const char *))*(void**)(__base - 130))(__t__p0, __t__p1));\
	})

#endif /* !_PPCINLINE_INTL_H */

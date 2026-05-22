/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_ICONV_H
#define _VBCCINLINE_ICONV_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

int  __libiconvctl(iconv_t , int , void *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconvctl(__p0, __p1, __p2) __libiconvctl((__p0), (__p1), (__p2))

void  __libiconvlist(int (*) (unsigned int namescount, const char * const * names, void* data), void *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconvlist(__p0, __p1) __libiconvlist((__p0), (__p1))

int  __libiconv_close(iconv_t ) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconv_close(__p0) __libiconv_close((__p0))

void  __libiconv_set_relocation_prefix(const char *, const char *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconv_set_relocation_prefix(__p0, __p1) __libiconv_set_relocation_prefix((__p0), (__p1))

size_t  __libiconv(iconv_t , const char **, size_t *, char **, size_t *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconv(__p0, __p1, __p2, __p3, __p4) __libiconv((__p0), (__p1), (__p2), (__p3), (__p4))

const char * __iconv_canonicalize(const char *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define iconv_canonicalize(__p0) __iconv_canonicalize((__p0))

iconv_t  __libiconv_open(const char *, const char *) =
	"\tlis\t11,IConvBase@ha\n"
	"\tlwz\t12,IConvBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libiconv_open(__p0, __p1) __libiconv_open((__p0), (__p1))

#endif /* !_VBCCINLINE_ICONV_H */

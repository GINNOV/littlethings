/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_INTL_H
#define _VBCCINLINE_INTL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

char * __libintl_ngettext(const char *, const char *, unsigned long int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_ngettext(__p0, __p1, __p2) __libintl_ngettext((__p0), (__p1), (__p2))

char * __libintl_dngettext(const char *, const char *, const char *, unsigned long int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_dngettext(__p0, __p1, __p2, __p3) __libintl_dngettext((__p0), (__p1), (__p2), (__p3))

char * __gettext(const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define gettext(__p0) __gettext((__p0))

char * __libintl_dcngettext(const char *, const char *, const char *, unsigned long int , int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_dcngettext(__p0, __p1, __p2, __p3, __p4) __libintl_dcngettext((__p0), (__p1), (__p2), (__p3), (__p4))

char * __libintl_bindtextdomain(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_bindtextdomain(__p0, __p1) __libintl_bindtextdomain((__p0), (__p1))

char * __dgettext(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define dgettext(__p0, __p1) __dgettext((__p0), (__p1))

char * __libintl_textdomain(const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_textdomain(__p0) __libintl_textdomain((__p0))

char * __dcgettext(const char *, const char *, int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define dcgettext(__p0, __p1, __p2) __dcgettext((__p0), (__p1), (__p2))

char * __libintl_bind_textdomain_codeset(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_bind_textdomain_codeset(__p0, __p1) __libintl_bind_textdomain_codeset((__p0), (__p1))

char * __libintl_gettext(const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_gettext(__p0) __libintl_gettext((__p0))

char * __ngettext(const char *, const char *, unsigned long int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define ngettext(__p0, __p1, __p2) __ngettext((__p0), (__p1), (__p2))

char * __libintl_dgettext(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_dgettext(__p0, __p1) __libintl_dgettext((__p0), (__p1))

char * __dngettext(const char *, const char *, const char *, unsigned long int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define dngettext(__p0, __p1, __p2, __p3) __dngettext((__p0), (__p1), (__p2), (__p3))

char * __libintl_dcgettext(const char *, const char *, int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define libintl_dcgettext(__p0, __p1, __p2) __libintl_dcgettext((__p0), (__p1), (__p2))

char * __bindtextdomain(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define bindtextdomain(__p0, __p1) __bindtextdomain((__p0), (__p1))

char * __dcngettext(const char *, const char *, const char *, unsigned long int , int ) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define dcngettext(__p0, __p1, __p2, __p3, __p4) __dcngettext((__p0), (__p1), (__p2), (__p3), (__p4))

char * __textdomain(const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define textdomain(__p0) __textdomain((__p0))

char * __bind_textdomain_codeset(const char *, const char *) =
	"\tlis\t11,IntlBase@ha\n"
	"\tlwz\t12,IntlBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define bind_textdomain_codeset(__p0, __p1) __bind_textdomain_codeset((__p0), (__p1))

#endif /* !_VBCCINLINE_INTL_H */

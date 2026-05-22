
/*
 *  LOCALE.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef LOCALE_H
#define LOCALE_H

typedef struct {
    char    *currency_symbol;
    char    *decimal_point;
    char    frac_digits;
    char    grouping;
    char    *int_curr_symbol;
    char    *mon_decimal_point;
    char    mon_grouping;
    char    *mon_thousands_sep;
    char    n_cs_precedes;
    char    n_sep_by_space;
    char    n_sign_posn;
    char    *negvative_sign;
    char    p_cs_precedes;
    char    p_sep_by_space;
    char    p_sign_posn;
    char    *positive_sign;
    char    *thousands_sep;
} lconv;

#define LC_ALL		-1
#define LC_COLLATE	1
#define LC_CTYPE	2
#define LC_MONETARY	3
#define LC_NUMERIC	4
#define LC_TIME 	5

extern struct lconv *localeconv(void);
extern char *setlocale(int, const char *);

#endif


/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	md.c
 *
 *	Machine dependant parts of first pass (parse)
 *	Also type checking subroutines.
 *
 * Modified by Detlef Wuerkner for AMIGA
 * Changes marked with TETISOFT
 * except 'size_i' instead of 'SIZE_I'
 *
 * Changes for Amiga version by Jeff Lydiatt marked by "Jal".
 *
 * 1993
 * Modified by Jason Petty to work with hce.
 * Changes marked with VANSOFT.
 */

#include <clib/stdio.h>
#include "h_inc/param.h"
#include "h_inc/tok.h"
#include "h_inc/nodes.h"
#include "h_inc/cookie.h"

/* ADDED BY TETISOFT */
extern int size_i;

NODEP bas_type();

int adjtab[] = {
	K_INT,		/* none */
	K_SHORT,	/* short */
	K_LONG,		/* long */
	0,		/* short long */
	K_UNSIGNED,	/* unsigned */

/* CHANGED BY TETISOFT */
/*	K_UNSIGNED, */	/* unsigned short */
	T_USHORT,	/* unsigned short */

	T_ULONG,	/* unsigned long */
	0,		/* unsigned short long */
};

adj_type(old, adj)
{
	int rv;

	switch (old) {
	case K_CHAR:
		if (adj & SAW_UNS)
			return T_UCHAR;
		break;

/* ADDED BY TETISOFT */
	case K_SHORT:
		if (adj & SAW_UNS)
			return T_USHORT;
		break;

	case K_INT:
		rv = adjtab[adj];
		if (rv == 0) {
			error("bad type spec");
			return K_INT;
		}
		return rv;
	case K_FLOAT:
		if (adj & SAW_LONG)
			return K_DOUBLE;
		break;
	}
	return old;
}

/* given ICON value, and flags SEE_L,SEE_U
	determine final type */
icon_ty(tp)
NODE *tp;
{
	int flags;
	long val;
	int islong, isuns;

	flags = tp->e_flags;
	val = tp->e_ival;

	islong = (flags & SEE_L);
	isuns = (flags & SEE_U);

	if (islong && isuns)
		return T_ULONG;
	if (islong || islongv(val))
		return K_LONG;

/* CHANGED BY TETISOFT */
/*	if (isuns) */
/*		return K_UNSIGNED; */
/*	return isintv((int)val) ? K_INT : K_CHAR; */
	if (isuns) {
		return isshortv(val) ? T_USHORT : K_UNSIGNED;
	}
	return isshortv(val) ? K_SHORT : K_CHAR;

}

/* CHANGED BY TETISOFT */
isshortv(i)
long i;
{
#define	HI_BITS	0xffffff80L

	if ((i & HI_BITS) == 0)		/* upper 9(!) bits zero */
		return 0;

	if ((i & HI_BITS) == HI_BITS)	/* upper bits all on */
		return 0;		/* upper bits aren't significant */

	return 1;
}

/* CHANGED BY TETISOFT */
islongv(l)
long l;
{
#ifndef NOLONGS
#define	HIBITS	0xffff8000L

	if ((l & HIBITS) == 0)		/* upper 17(!) bits zero */
		return 0;

	if ((l & HIBITS) == HIBITS)	/* upper bits all on */
		return 0;		/* upper bits aren't significant */

	return 1;
#else
	return 0;
#endif
}

/* COMMENT BY TETISOFT: This function is never used: */

mkint(l)
long l;
{
	return l;
}

lc_reg(rp, xp)
int *rp;
NODE *xp;
{
	switch (xp->n_tptr->t_token) {
	case STAR:
		return al_areg(rp,xp);
	case K_CHAR:
	case T_UCHAR:

/* ADDED BY TETISOFT */
	case T_USHORT:

	case T_ULONG:
	case K_INT:
	case K_UNSIGNED:
	case K_LONG:
		return al_dreg(rp,xp);
	default:
		return 0;
	}
}

al_areg(rp,xp)
int *rp;
NODEP xp;
{
	register rmask, n;

	rmask = *rp;
	for (n=ARV_START; n<=ARV_END; n++)
		if ((rmask & (1<<n)) == 0) {
			xp->e_rno = n;
			*rp |= (1<<n);
			return 1;
		}
	return 0;
}

al_dreg(rp,xp)
int *rp;
NODEP xp;
{
	register rmask, n;

	rmask = *rp;
	for (n=DRV_START; n<=DRV_END; n++)
		if ((rmask & (1<<n)) == 0) {
			xp->e_rno = n;
			*rp |= (1<<n);
			return 1;
		}
	return 0;
}

long
arg_size(sz,np)
long sz;
NODEP np;
{
	np->e_offs = 0;

	switch (np->n_tptr->t_token) {
	case '[':
		error("GAK! array arg "); /* Changed by VANSOFT. */
		return SIZE_P;
	case K_CHAR:
	case T_UCHAR:
		np->e_offs = size_i - SIZE_C;
		return size_i;


/* CHANGED BY TETISOFT */
/* #if SIZE_I != SIZE_S
 *	case K_SHORT:
 *		np->e_offs = SIZE_I - SIZE_S;
 *		return SIZE_I;
 * #endif */
	case K_SHORT:
	case T_USHORT:
		if (size_i != SIZE_S) {
			np->e_offs = size_i - SIZE_S;
			return size_i;
		}

	default:
		if (sz & 1)
			sz++;
		return sz;
	}
}

mustlval(np)
NODEP np;
{
	switch (np->e_token) {
	case ID:
	case STAR:
	case '.':
		break;
	default:
		errorn("not lvalue", np);
		return 1;
	}
	return 0;
}

mustty(np, flags)
NODEP np;
{
	switch (np->n_tptr->t_token) {
	case STAR:
		if (flags & R_POINTER)
			return 0;
		error("pointer not allowed");
		return 1;
	case K_STRUCT:
	case K_UNION:
		if (flags & R_STRUCT)
			return 0;
		error("struct/union not allowed");
		return 1;
	case K_CHAR:
	case K_SHORT:
	case K_INT:
	case K_UNSIGNED:
	case K_LONG:
	case T_UCHAR:

/* ADDED BY TETISOFT */
	case T_USHORT:

	case T_ULONG:
		if (flags & R_INTEGRAL)
			return 0;
		error("integral not allowed");
		return 1;
	case K_FLOAT:
	case K_DOUBLE:
		if (flags & R_FLOATING)
			return 0;
		error("floating not allowed");
		return 1;
	default:
		error("bad type");
		return 1;
	}
	return 0;
}

NODEP
functy(np)
NODEP np;
{
	int lt;

	lt = np->n_tptr->t_token;
	if (lt != K_VOID)
		mustty(np, R_ASSN);
	switch (lt) {
	case STAR:
	case K_STRUCT:
	case K_UNION:
		return np->n_tptr;
	}
	lt = widen(lt);
	return bas_type(lt);
}

NODEP
normalty(lp, rp)
NODEP lp, rp;
{
	/* already checked types are R_ARITH */
	/* rp may be NULL */
	int lt, rt, rett;

	lt = lp->n_tptr->t_token;
	if (rp)
		rt = rp->n_tptr->t_token;
	else
		rt = K_INT;
	rett = maxt(widen(lt), widen(rt));
	return bas_type(rett);
}

asn_chk(ltp, rp)
NODEP ltp, rp;
{
	register NODEP p;	/*Jal*/

	switch (ltp->t_token) {
	case K_STRUCT:
	case K_UNION:
		if (same_type(ltp, rp->n_tptr) == 0)
			error("bad struct assign");
		return;
	case STAR:
		if (mayzero(rp))
			return;
		if (mustty(rp, R_POINTER))
			return;
 		/*
		 * Jal - allow for ptr = (void *) ptr.
		 */
		p = rp->n_tptr->n_tptr;
		if (p->t_token != K_VOID
		  && same_type(ltp->n_tptr, p) == 0)
			warn("pointer types mismatch");
		return;
	default:
		if (mustty(rp, R_ARITH))
			return;
	}
}

chkcmp(np)
NODEP np;
{
	/* already checked types are R_SCALAR */
	int lt, rt;
	NODEP lp = np->n_left, rp = np->n_right;

	lt = lp->n_tptr->t_token;
	lt = (lt == STAR);
	rt = rp->n_tptr->t_token;
	rt = (rt == STAR);
	if (lt && rt) {		/* ptr cmp ptr */
		if (same_type(lp->n_tptr, rp->n_tptr) == 0) {
			warn("cmp of diff ptrs");
		}
	} else if (lt) {	/* ptr cmp intg */
		mustzero(rp);
	} else if (rt) {	/* intg +-[ ptr */
		mustzero(lp);
	} /* else both ARITH */
}

NODEP
colonty(np)
NODEP np;
{
	/* already checked types are R_SCALAR */
	int lt, rt;
	NODEP lp = np->n_left, rp = np->n_right;

	lt = lp->n_tptr->t_token;
	lt = (lt == STAR);
	rt = rp->n_tptr->t_token;
	rt = (rt == STAR);
	if (lt && rt) {		/* ptr : ptr */
		warn(": diff ptrs");
		return lp->n_tptr;
	} else if (lt) {	/* ptr : intg */
		mustzero(rp);
		return lp->n_tptr;
	} else if (rt) {
		mustzero(lp);
		return rp->n_tptr;
	} else
		return normalty(lp, rp);
}

NODEP
addty(np)
NODEP np;
{
	/* already checked types are R_SCALAR */
	/* op is '+' or '-' or '+=' or '-=' or '[' */
	int oop = np->e_token;
	int op;
	int lt, rt;
	NODEP lp = np->n_left, rp = np->n_right;

	op = oop;
	if (isassign(op))
		op -= ASSIGN 0;
	lt = lp->n_tptr->t_token;
	lt = (lt == STAR);
	rt = rp->n_tptr->t_token;
	rt = (rt == STAR);
	if (lt && rt) {		/* ptr - ptr */
		if (oop != '-' || same_type(lp->n_tptr, rp->n_tptr) == 0) {
			error("bad +/-");
			return lp->n_tptr;
		}
		np->e_token = PTRDIFF;
		np->e_offs = lp->n_tptr->n_tptr->t_size;
		return bas_type(K_INT);
	} else if (lt) {	/* ptr +-[ intg */
pandi:
		mustty(rp, R_INTEGRAL);
		np->e_offs = lp->n_tptr->n_tptr->t_size;
		if (op == '+')
			np->e_token += PTRADD-'+';
		else if (op == '-')
			np->e_token += PTRSUB-'-';
		return lp->n_tptr;
	} else if (rt) {	/* intg +-[ ptr */
		if (isassign(oop) || op == '-') {
			error("illegal int op ptr");
			return bas_type(K_INT);
		}
		/* switch sides so intg is on right */
		np->n_left = rp;
		np->n_right = lp;
		lp = rp;
		rp = np->n_right;
		goto pandi;
	} else {		/* intg +- intg */
		return normalty(lp, rp);
	}
}

mustzero(np)
NODEP np;
{
	if (np->e_token == ICON && np->e_ival == 0) {
		return;
	}
	error("bad ':' combination");
}

mayzero(np)
NODEP np;
{
	if (np->e_token == ICON && np->e_ival == 0) {
		return 1;
	}
	return 0;
}

widen(ty)
{
	switch (ty) {
	case K_CHAR:
	case T_UCHAR:
		return K_INT;
	case K_SHORT:

/* ADDED BY TETISOFT */
	case T_USHORT:

		return K_INT;
	case K_FLOAT:
		return K_DOUBLE;
	default:
		return ty;
	}
}

int pri_t[] = {

/* CHANGED BY TETISOFT */
/*	1, 6,	*/	/* uchar, ulong */
/*	5,2,4,3,0, */	/* long, short, uns, int, char */
/*	7,8,9   */	/* float, double, void */
	1,3,7,		/* uchar, ushort, ulong */
	6,2,5,4,0,	/* long, short, uns, int, char */
	8,9,10   	/* float, double, void */

};

maxt(t1, t2)
{
	extern nmerrors;

	if (nmerrors)
		return K_INT;
	if (pri_t[t1-FIRST_BAS] > pri_t[t2-FIRST_BAS])
		return t1;
	return t2;
}

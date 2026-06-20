/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 * Modified by Detlef Wuerkner for AMIGA
 * Changes marked with TETISOFT
 */
#include "top.h"

/* ADDED BY TETISOFT */
#include <ctype.h>

/*
 * Low-level i/o routines.
 */

/*
 * mode tells what kind of stuff we're reading at the moment.
 */
static	int	mode;

/* ADDED BY TETISOFT */
static int cseen, dseen, bseen;
#define	REFS	3

#define	BSS	0
#define	DATA	1
#define	TEXT	2

static	char	*mnames[] = {
	".bss",
	".data",
	".text"
};

/* ADDED BY TETISOFT: names for output */
static char	*outmnames[] = {
	"BSS",
	"DATA",
	"BSS\tCHIPBSS,CHIP",
	"DATA\tCHIPDATA,CHIP",
};

/* ADDED BY TETISOFT: reference flags */
#define XDEF	1		/* found .globl  (export) */
#define	PUBLIC	2		/* found .PUBLIC (import or export,
						  BUT NO STATICS) */
#define	STATIC	4		/* found .STATIC (DON'T EXPORT!) */

/* ADDED BY TETISOFT: reference list node */
struct refnode
{
	struct refnode *next;
	int type;		/* see above */
	char *name;
};

/* ADDED BY TETISOFT */
static struct refnode firstref;
static struct refnode *refsptr = &firstref;

/* ADDED BY TETISOFT */
static addref (s, type)
char *s;
{
	register struct refnode *rp;

	for (rp = refsptr; rp->next; rp = rp->next) {
	   if (strcmp(rp->name, s) == 0) {
		rp->type |= type;
		return;
	   }
	}
	if (strcmp(rp->name, s) == 0) {
		rp->type |= type;
		return;
	}
	rp->next = (struct refnode *)alloc(sizeof(struct refnode));
   	rp = rp->next;
	rp->name = alloc(strlen(s)+1);
	strcpy(rp->name, s);
	rp->type = type;
	rp->next = NULL;
}

/* ADDED BY TETISOFT */
static void printrefs()
{
	struct refnode *rp;

	rp = refsptr->next;
	while (rp) {
		if (rp->type == PUBLIC)
			fprintf(rfp, "\tXREF\t%s\n", rp->name);
		rp = rp->next;
	};
	fprintf(rfp, "\n");
	rp = refsptr->next;
	while (rp) {
		switch (rp->type) {
		case XDEF:
		case XDEF|PUBLIC:
			fprintf(rfp, "\tXDEF\t%s\n", rp->name);
			break;
		case XDEF|STATIC:
		case XDEF|STATIC|PUBLIC:
			fprintf(stderr, "invalid reftype combination of %s\n",
					 rp->name);
			exit(EXIT_FAILURE);
		}
		rp = rp->next;
	};
}

/*
 * Tokens from the current line...
 */
char	*t_line;		/* the entire line */
char	*t_lab;			/* label, if any */
char	*t_op;			/* opcode */
char	*t_arg;			/* arguments */

#define	ISWHITE(c)	((c) == '\t' || (c) == ' ' || (c) == '\n')

/* CHANGED BY TETISOFT (WAS 2048) */
#define	LSIZE	200	/* max. size of an input line */

/*
 * readline() - read the next line from the file
 *
 * readline passes data and bss through to the output, only returning
 * when a line of text has been read. Returns FALSE on end of file.
 *
 * This function heavily modified by TETISOFT
 */

bool
readline()
{
	char	*fgets();
	static	void	tokenize();
	static	char	buf[LSIZE];

	/*
	 * Keep looping until we get a line of text
	 */
	for (;;) {
		if (fgets(buf, LSIZE, ifp) == NULL) {
			ofp = cfp;	/* TETISOFT: last function to code */
			printrefs();	/* TETISOFT: Output references */
			return FALSE;
		}
	
		t_line = buf;
	
		/*
		 * Find out if the mode is changing.
		 */
		tokenize(buf);
	
		/*
		 * If we see a "var" hint from the compiler, call addvar()
		 * to remember it for later use.
		 */
		if (t_lab[0] == ';') {
			if (strcmp(t_lab, ";var") == 0)
				addvar(atoi(t_op), atoi(t_arg));
			continue;
		}

		if (t_op[0] == '.') {	/* is it a pseudo-op? */
			if (strcmp(t_op, mnames[BSS]) == 0) {
			   mode = BSS;
			   ofp = bfp;
			   if (!bseen) {
				bseen = TRUE;
				fprintf(ofp, "\n\t%s\n\n",
				       outmnames[(2*dest_hunk)+mode]);
			   }
			   continue;
			} else if (strcmp(t_op, mnames[DATA]) == 0) {
			   mode = DATA;
			   ofp = dfp;
			   if (!dseen) {
				dseen = TRUE;
				fprintf(ofp, "\n\t%s\n\n",
					outmnames[(2*dest_hunk)+mode]);
			   }
			   continue;
			} else if (strcmp(t_op, mnames[TEXT]) == 0) {
			   mode = TEXT;
			   ofp = cfp;
			   if (!cseen) {
				cseen = TRUE;
				fprintf(ofp, "\n\tCODE\n");
			   }
			   continue;
			} else if (strcmp(t_op, ".PUBLIC") == 0) {
				addref(t_arg, PUBLIC);
				continue;
			} else if (strcmp(t_op, ".STATIC") == 0) {
				addref(t_arg, STATIC);
				continue;
			}
		}
		if (mode == TEXT) {
		   if (t_op[0] == '.') {	/* is it a pseudo-op? */
			if (strcmp(t_op, ".globl") == 0) {
				addref(t_arg, XDEF);
				return TRUE;
			} else if (strcmp(t_op, ".dc.l") == 0) {
				sprintf(t_op, "DC.L");
				return TRUE;
			}
		   } else {
			if ( (strcmp(t_op, "jsr") == 0) && (t_arg[0]!='(') ) {
				addref(t_arg, PUBLIC);
			}
			return TRUE;
		   }
		} else {
		   if (t_op[0] == '.') {	/* is it a pseudo-op? */
			if (strcmp(t_op, ".globl") == 0) {
				addref(t_arg, XDEF);
			} else if (strcmp(t_op, ".comm") == 0) {
				for (; *t_arg != ','; t_arg++)
					fputc(*t_arg, ofp);
				fprintf(bfp, ":\n\tDS.B\t%s\n", ++t_arg);
			} else {
				fprintf(ofp, "%s\t", t_lab);
				for (t_op++; *t_op != 0; t_op++)
					fputc(toupper(*t_op), ofp);
				fprintf(ofp,"\t%s\n", t_arg);
			}

		   } else {
			fputs(buf, ofp);
		   }
		}
	}
}

static void
tokenize(s)
register char	*s;
{
	static	char	label[LSIZE], opcode[LSIZE], args[LSIZE];
	register int	i;

	/*
	 * Grab the label, if any
	 */
	i = 0;
	while (*s && !ISWHITE(*s) && *s != ':')
		label[i++] = *s++;
	label[i] = '\0';

	if (*s == ':')
		s++;

	while (ISWHITE(*s))
		s++;

	/*
	 * Grab the opcode
	 */
	i = 0;
	while (*s && !ISWHITE(*s))
		opcode[i++] = *s++;
	opcode[i] = '\0';

	while (ISWHITE(*s))
		s++;

	/*
	 * Grab the arguments
	 */
	i = 0;
	while (*s && !ISWHITE(*s))
		args[i++] = *s++;
	args[i] = '\0';

	t_lab = label;
	t_op = opcode;
	t_arg = args;
}

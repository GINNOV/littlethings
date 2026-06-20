/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)init.c	1.1 86/10/09";

#include	"id.h"
#include	"string.h"
#include	<stdio.h>
#include	<stdlib.h>
#include	"extern.h"

FILE *
initID(char *idFile,struct idhead *idhp,struct idarg **idArgs)
{
	FILE		*idFILE;
	register int	i;
	register char	*strings;
	register struct idarg	*idArg;

	if ((idFILE = fopen(idFile, "r")) == NULL)
		return NULL;

	fseek(idFILE, 0L, 0);
	fread(idhp, sizeof(struct idhead), 1, idFILE);
	if (!strnequ(idhp->idh_magic, IDH_MAGIC, sizeof(idhp->idh_magic))) {
		fprintf(stderr, "%s: Not an id file: `%s'\n", MyName, idFile);
		exit(1);
	}
	if (idhp->idh_vers != IDH_VERS) {
		fprintf(stderr, "%s: ID version mismatch (want: %d, got: %d)\n", MyName, IDH_VERS, idhp->idh_vers);
		exit(1);
	}

	fseek(idFILE, idhp->idh_argo, 0);
	strings = xmalloc(i = idhp->idh_namo - idhp->idh_argo);
	fread(strings, i, 1, idFILE);
	idArg = *idArgs = (struct idarg *)xcalloc(idhp->idh_pthc, sizeof(struct idarg));
	for (i = 0; i < idhp->idh_argc; i++) {
		if (*strings == '+' || *strings == '-')
			goto skip;
		idArg->ida_flags = (*strings) ? 0 : IDA_BLANK;
		idArg->ida_arg = strings;
		idArg->ida_next = idArg + 1;
		idArg++;
	skip:
		while (*strings++)
			;
	}
	return idFILE;
}

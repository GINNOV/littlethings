/* Copyright (c) 1986, Greg McGary */
/* @(#)id.h	1.1 86/10/09 */

#define	IDFILE	"ID"

struct idhead {
	char	idh_magic[2];	/* magic number */
#define	IDH_MAGIC "\311\304"	/* magic-number ("ID" with hi bits) */
	short	idh_vers;	/* id-file version number */
#define	IDH_VERS	2	/* current version */
	int	idh_argc;	/* # of args for mkid update */
	int	idh_pthc;	/* # of paths for mkid update */
	int	idh_namc;	/* # of identifiers */
	int	idh_vecc;	/* # of bytes in a path vector entry */
	int	idh_bsiz;	/* # of bytes in entry (bufsiz for lid) */
	long	idh_argo;	/* file offset of args for mkid update */
	long	idh_namo;	/* file offset of identifier names */
	long	idh_endo;	/* file offset of EOF */
};

struct idarg {
	struct idarg	*ida_next;
	char	*ida_arg;
	int	ida_index;
	char	ida_flags;
#define	IDA_ADJUST	0x01
#define	IDA_SCAN	0x02
#define	IDA_PATH	0x04
#define	IDA_ARG		0x08
#define	IDA_BLANK	0x10
};

struct idname {
	char	*idn_name;
	char	*idn_bitv;
	char	idn_flags;
#define	IDN_SOLO	0x01	/* occurs only once */
#define	IDN_NUMBER	0x02	/* is a number */
#define	IDN_NAME	0x04	/* is a name */
#define	IDN_STRING	0x08	/* is a string */
#define	IDN_LITERAL	0x10	/* occurs as a literal (not string) */
#define	IDN_NOISE	0x20	/* occurs very frequently */
};

/*
	Extract the various logical fields of a name:

	NAME: null-terminated ascii string
	TAG:  index of name within a sorted array of all names
	SOLO: boolean indicating that this name occurs exactly once
*/
#define	ID_PATHS(b) ((b)+strlen(b)+1)
#define	ID_FLAGS(b) (*(b))
#define	ID_STRING(b) ((b)+1)

#define	NEW(type)	((type *)xcalloc(1, sizeof(type)))

#define	GETARG(argc, argv)	((argc)--, *(argv)++)
#define	UNGETARG(argc, argv)	((argc)++, *--(argv))

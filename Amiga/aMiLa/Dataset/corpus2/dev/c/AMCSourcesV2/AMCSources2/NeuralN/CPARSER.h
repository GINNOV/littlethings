/*
*-----------------------------------------------------------------------------
*	file:	cparser.h
*	desc:	simple command parser
*	by:	patrick ko
*	date:	22 aug 91
*-----------------------------------------------------------------------------
*/

#define	CMD_NULL	0

typedef	struct	{
	int	cmdno;
	char	* cmdstr;
	}       CMDTBL;

/*
*	#define your own commands here starting from 1
*	-* modifiable *-
*/

#define	CMD_DIMINPUT		1
#define	CMD_DIMOUTPUT		2
#define	CMD_DIMHIDDENY		3
#define	CMD_DIMHIDDEN		4
#define	CMD_TRAINFILE		5
#define	CMD_TOTALPATT		6
#define	CMD_DUMPFILE		7
#define CMD_DUMPIN		8
#define	CMD_RECOGFILE		9
#define	CMD_OUTFILE		10
#define	CMD_TRAINERR		11
#define	CMD_TOLER		12
#define	CMD_REPORT		13
#define CMD_TIMER		14
#define CMD_TDUMP		15
#define	CMD_WPOS		16
#define	CMD_WNEG		17
#define	CMD_COMMENT		18

#ifdef	__TURBOC__

int	cmdsearch		(char *, char *);
int	cmdinit			(int, char **);
int 	cmdget			(char *);

#else

int	cmdsearch		( );
int	cmdinit			( );
int 	cmdget			( );

#endif

/*
 * Report.h, utility accessory header for GAP-Lib.
 *
 * (C)1998-1999 Peter Bengtsson
 */

#ifndef	__GAP_REPORT_H__
#define	__GAP_REPORT_H__

#include <GAP.h>

#define	REPFILES		6

#define	AVERAGE		(1<<0)
#define	MEDIAN		(1<<1)
#define	TYPECOUNT	(1<<2)
#define	MAX			(1<<3)
#define	MIN			(1<<4)
#define	STDDEV		(1<<5)

#define	ALL			(~0)

#define	REP_Generations	(TAG_DUMMY+0x01)
#define	REP_Multipass		(TAG_DUMMY+0x02)
#define	REP_Indexed			(TAG_DUMMY+0x03)

#define	RFLG_MPASS	(1<<0)
#define	RFLG_VBUF	(1<<1)
#define	RFLG_NOMEM	(1<<2)
#define	RFLG_INDXD	(1<<3)

struct Report {
	FILE	*files[REPFILES];
	char	*basename;
	int	used[REPFILES];
	int	flags,gencount,index;
	double	*vbuffer[REPFILES];
	int	cbuffer[REPFILES];
};

extern struct Report *MakeReport(char *,struct TagItem *);
extern void DoReport(struct Report *,struct Population *,unsigned int);
extern void EndReport(struct Report *rs);

#endif

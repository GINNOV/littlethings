/*
 * Report file generation utility code.
 * See report.doc for more info.
 *
 * (C)1998-1999 Peter Bengtsson
 *
 * 21/5-1999:
 *	Added indexed mode.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <errno.h>
#include <GAP.h>

#include "report.h"

#define	MAX_INDEX	2048	/* Generate at most 2048 indices. */

static const char * const exts[REPFILES] = {
	"avg",
	"med",
	"typ",
	"max",
	"min",
	"dev"
};

static const char * const descs[REPFILES] = {
	"Average",
	"Median",
	"TypeCount",
	"Max",
	"Min",
	"StdDev"
};

struct Report *MakeReport(char *,struct TagItem *);
void DoReport(struct Report *,struct Population *,unsigned int);
void EndReport(struct Report *rs);

struct Report *MakeReport(char *basename,struct TagItem *TagList)
{
struct Report *rs;
char	*buf=NULL;
int i,n,t;
int Index=MAX_INDEX;
Tag	tag=TAG_DONE;

rs = malloc(sizeof(struct Report));

rs->flags=0;
rs->gencount=0;

for(i=0;i!=REPFILES;i++) {
	rs->vbuffer[i]=NULL;
	rs->cbuffer[i] = 0;
}

i=0;

if(rs!=0) {

	if(TagList!=NULL) {
		tag = TagList[0].ti_Tag;
	}

	while(tag!=TAG_DONE) {	/* Handling of TAG_MORE & TAG_IGNORE is still missing. */

		switch(tag) {

		case	REP_Generations:
			rs->gencount = TagList[i].ti_Data;
		break;

		case	REP_Multipass:
			rs->flags &= ~RFLG_MPASS;
			if(TagList[i].ti_Data!=FALSE) {
				rs->flags |= RFLG_MPASS;
			}
		break;

		case	REP_Indexed:
			rs->flags &= ~RFLG_INDXD;
			if(TagList[i].ti_Data!=FALSE) {
				rs->flags |= RFLG_INDXD;
			}
		break;

		default:
			fprintf(stderr,"MakeReport: Unrecognized tag 0x%08lx.\n",tag);
		}

		tag = TagList[++i].ti_Tag;
	}

	if((rs->flags&RFLG_MPASS) && rs->gencount==0) {
		fprintf(stderr,"MakeReport: Multipass mode selected but number of generations undeclared.\nDisabling multipass mode.\n");
		rs->flags &= ~RFLG_MPASS;
	}

	if(basename!=NULL) {
		buf = malloc((strlen(basename)+8)*sizeof(char));
		rs->basename = malloc((strlen(basename)+1)*sizeof(char));
		strcpy(rs->basename,basename);

		if(rs!=NULL && rs->basename!=NULL && buf!=NULL) {
			if(rs->flags&RFLG_INDXD) {	/* Determine index of file. */
				struct stat State;
				i=-1;
				while(++i<MAX_INDEX) {
					t=1;
					for(n=0;n!=REPFILES;n++) {
						sprintf(buf,"%s%d.%s",basename,i,exts[n]);
						if((t=stat(buf,&State))==0) {
							break;
						}
					}
					if(t!=0) {
						if(errno==ENOENT) {
							Index=i;
							break;
						}
					}
				}
			}

			rs->index = Index;

			for(i=0;i!=REPFILES;i++) {
				if(rs->flags&RFLG_INDXD) {
					sprintf(buf,"%s%d.%s",basename,Index,exts[i]);
				} else {
					sprintf(buf,"%s.%s",basename,exts[i]);
				}

				if((rs->files[i]=fopen(buf,"wb"))==NULL) {
					while(--i>=0) {
						fclose(rs->files[i]);
					}
					free(rs->basename);
					free(rs);
					rs = NULL;
					fprintf(stderr,"MakeReport: Error opening files for writing.\n");
				}
				rs->used[i]=0;
				fprintf(rs->files[i],"# Generation, %s\n",descs[i]);
			}
		} else {
			if(rs!=NULL) {
				if(rs->basename!=NULL) {
					free(rs->basename);
				}
				free(rs);
				rs = NULL;
			}
			fprintf(stderr,"MakeReport: No free store (malloc() failed).\n");
		}
	} else {
		fprintf(stderr,"MakeReport: NULL basename.\n");
	}

	if(buf!=NULL) {
		free(buf);
	}

}

return(rs);
}

void EndReport(struct Report *rs)
{
int i,n;
char *buf=NULL;

if(rs!=NULL) {
	if(rs->flags&RFLG_MPASS) {
		for(i=0;i!=REPFILES;i++) {
			if(rs->used[i]!=0) {
				for(n=0;n!=rs->gencount;n++) {
					fprintf(rs->files[i],"%d %f\n",n+1,rs->vbuffer[i][n]/((double)rs->cbuffer[i]));
				}
			}
		}
	}
	buf=malloc((strlen(rs->basename)+8)*sizeof(char));
	for(i=0;i!=REPFILES;i++) {
		fclose(rs->files[i]);	/* fclose does an fflush. */
		if(rs->used[i]==0 && buf!=NULL) {
			if(rs->flags&RFLG_INDXD) {
				sprintf(buf,"%s%d.%s",rs->basename,rs->index,exts[i]);
			} else {
				sprintf(buf,"%s.%s",rs->basename,exts[i]);
			}

			remove(buf);
		}
	}

	if(rs->flags&RFLG_VBUF) {
		for(i=0;i!=REPFILES;i++) {
			if(rs->vbuffer[i]!=NULL) {
				free(rs->vbuffer[i]);
			}
		}
	}

	free(rs->basename);
	free(rs);
}

if(buf!=NULL) {
	free(buf);
} else {
	fprintf(stderr,"EndReport: No free store, continuing.\n");
}

}

void DoReport(struct Report *rs,struct Population *Pop,unsigned int flags)
{
int i,n,t;
struct Popstat *stat;

if(rs!=NULL && Pop!=NULL && flags!=0) {
	stat = &Pop->Stat;
	for(i=0;i!=REPFILES;i++) {
		n = flags&(1<<i);
		if(n!=0) {
			rs->used[i]=1;
			if(rs->flags&RFLG_MPASS) {
				if(stat->Generation==1) {
					rs->cbuffer[i]++;
				}
				if(stat->Generation>rs->gencount) {
					fprintf(stderr,"DoReport: Generation overflow.\n");
				} else {
					if(rs->vbuffer[i]==NULL) {
						if(rs->flags&RFLG_NOMEM) {
							break;
						}
						rs->flags |= RFLG_VBUF;
						rs->vbuffer[i] = malloc(rs->gencount*sizeof(double));
						if(rs->vbuffer[i]==NULL) {
							rs->flags |= RFLG_NOMEM;
							fprintf(stderr,"DoReport: No free store for multipass buffer.\n(Failed to allocate %ld bytes.)\n",rs->gencount*sizeof(double));
							break;
						} else {
							for(t=0;t!=rs->gencount;t++) {
								rs->vbuffer[i][t] = 0.0;
							}
						}
					}
					switch(n) {
					case	AVERAGE:
						rs->vbuffer[i][stat->Generation-1] += stat->AverageFitness;
					break;
					case	MEDIAN:
						rs->vbuffer[i][stat->Generation-1] += stat->MedianFitness;
					break;
					case	TYPECOUNT:
						rs->vbuffer[i][stat->Generation-1] += (double) stat->TypeCount;
					break;
					case	MAX:
						rs->vbuffer[i][stat->Generation-1] += stat->MaxFitness;
					break;
					case	MIN:
						rs->vbuffer[i][stat->Generation-1] += stat->MinFitness;
					break;
					case	STDDEV:
						rs->vbuffer[i][stat->Generation-1] += stat->StdDeviation;
					break;
					}
				}
			} else {
				switch(n) {
				case	AVERAGE:
					fprintf(rs->files[i],"%ld %f\n",stat->Generation,stat->AverageFitness);
				break;
				case	MEDIAN:
					fprintf(rs->files[i],"%ld %f\n",stat->Generation,stat->MedianFitness);
				break;
				case	TYPECOUNT:
					fprintf(rs->files[i],"%ld %ld\n",stat->Generation,stat->TypeCount);
				break;
				case	MAX:
					fprintf(rs->files[i],"%ld %f\n",stat->Generation,stat->MaxFitness);
				break;
				case	MIN:
					fprintf(rs->files[i],"%ld %f\n",stat->Generation,stat->MinFitness);
				break;
				case	STDDEV:
					fprintf(rs->files[i],"%ld %f\n",stat->Generation,stat->StdDeviation);
				break;
				}
			}
		}
	}
}

}

struct Report *MakeReportT(char *basename,...)
{
va_list ap;
int i=0;
struct TagItem TagList[64]; /* Assumed big enough */

va_start(ap,basename);

while((TagList[i].ti_Tag = va_arg(ap,Tag)),TagList[i].ti_Tag != TAG_DONE && TagList[i].ti_Tag != TAG_MORE) {
	TagList[i].ti_Data = va_arg(ap,IPTR);
	i++;
}

if(TagList[i].ti_Tag == TAG_MORE) {
	TagList[i].ti_Data = va_arg(ap,IPTR);
	if(TagList[i].ti_Data == 0) {
		fprintf(stderr,"MakeReportT: Illegal NULL value for TAG_MORE.\n");
		TagList[i].ti_Tag = TAG_DONE;
	}
}

va_end(ap);

return (MakeReport(basename,TagList));
}


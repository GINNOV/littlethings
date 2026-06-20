
#ifndef	NUQNEH_H__
#define	NUQNEH_H__

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

#ifndef	NQ_NO_64
#ifndef	NQ_64
#if	(defined(__GNUC__) && (__GNUC__ +0)>=3) || (defined(__STDC__) && defined(__STDC_VERSION__) && (__STDC_VERSION__ +0)>=199901L)
#define	NQ_64
#if defined(__GNUC__) && defined(__cplusplus)
#warning Warning: ISO C++ does not support long long. Possible portability problem.
#endif
#endif
#endif
#endif

#define	NONEFLAG_NQ	0
#define	LINEFLAG_NQ	(1<<0L)
#define	FILEFLAG_NQ	(1<<1L)

#ifdef	__GNUC__
#define	NQ_VUNUSED	__attribute__((unused))
#define	NQ_FUNUSED	__attribute__((unused))
#else
#define	NQ_VUNUSED	/* Nothing */
#define	NQ_FUNUSED	/* Nothing */
#endif

#ifdef	__SUNPRO_CC
#pragma	error_messages	off
#endif


static char **LSplit_gen_nq(char *,int,int *);
static void *MemTrackList_nq[128];
static int MemTrackIdx_nq=0;

static void atexithandler_nq(void)
{
int i;
for(i=0;i<MemTrackIdx_nq;i++) {
	free(MemTrackList_nq[i]);
}
}

#define	S_nq(x)	((x)==dchar)
#define	C_nq	lar[lp]
#define	MARG_nq	128

static char **LSplit_gen_nq(char *lar,int dchar,int *num)
{
int	c=0,lp= -1,bp=0,qm=0;
char	**W,*B0;

if(!lar) {
	*num=0;
	return(NULL);
}

W=(char **)malloc(strlen(lar)+MARG_nq*sizeof(char *)+1);
if(W) {
	B0=(char *)&W[MARG_nq];
	if(W) {
	 do{
	  while(lp++,S_nq(C_nq));
	  if(C_nq){
	   W[c++] = &B0[bp];
	   while(B0[bp++] = C_nq,(!S_nq(C_nq)||qm)&&(C_nq!=0)) {
			if(C_nq=='"' && lar[lp-1]!='\\') {
				qm^=1;
			}
			lp++;
		}
	   B0[bp-1] = 0;
	  }
	 }while(C_nq);
	 W[c]=0;
	}
	*num=c;
} else {
	fprintf(stderr,"Internal error! No free store!\n");
}
return(W);
}
#undef S_nq
#undef C_nq
#undef MARG_nq

#define	LSplit_nq(a,b)	LSplit_gen_nq(a,',',b)

NQ_FUNUSED static long atoi_nq(char *s)
{
if(s) {
	return(atol(s));
}
return(0);
}

NQ_FUNUSED static double atof_nq(char *s)
{
if(s) {
	return(atof(s));
}
return(0.0);
}

NQ_FUNUSED static void saveout_nq(long *Meta,unsigned char *Data,char *Filename,char *PName,char **Names,char **OptNames,int everything)
{
FILE *fp;
int i,n,l=0,nidx=-1;
void *p;
int *ep;
long int *ip,**ipp;
#ifdef	NQ_64
long long int *qp,**qpp;
#endif
double *dp,**dpp;
char **cpp,***cppp;
char *buf;
time_t tim;
struct tm *timep;
unsigned char isvalid;

if(strcmp(Filename,"-")) {
	fp=fopen(Filename,"wb");
} else {
	fp=stdout;
}

if(fp) {
	fprintf(fp,"The Frobozz Magic File Company: ");
	buf=(char *)malloc(256);
	if(!buf) {
		fprintf(stderr,"Internal error saving args! No free store!\n");
		return;
	}
	tim=time(0);
	timep=gmtime(&tim);
	strftime(buf,256,"%d/%m-%Y %H:%M:%S",timep);
	fprintf(fp,"%s (%s for %s)\n",buf,Filename,PName);
	free(buf);
	i=4;	/* Start of arg descriptors. */
	while(Meta[i]!=-1) {
		isvalid=Data[Meta[3+i]];
		nidx++;
		if(isvalid || everything) {
			fprintf(fp,"%s:",Names[nidx]);
			p=(void *)&Data[Meta[i+1]];
			if(Meta[i+2]>=0) {
				l=((int *)&Data[Meta[i+2]])[0];
			}		

			switch(Meta[i]) {
			case	0:	/* int */
				ip=(long int *)p;
				fprintf(fp,"%ld\n",ip[0]);
			break;
			case	1:	/* [int] */
				ipp=(long int **)p;
				if(l>0 && ipp[0]) {
					for(n=0;n<(l-1);n++) {
						fprintf(fp,"%ld,",ipp[0][n]);
					}
					fprintf(fp,"%ld\n",ipp[0][l-1]);
				} else {
					fprintf(fp,"\n");
				}
			break;
			case	2:	/* float */
				dp=(double *)p;
				fprintf(fp,"%f\n",dp[0]);	
			break;
			case	3:	/* [float] */
				dpp=(double **)p;
				if(l>0 && dpp[0]) {
					for(n=0;n<(l-1);n++) {
						fprintf(fp,"%f,",dpp[0][n]);
					}
					fprintf(fp,"%f\n",dpp[0][l-1]);
				} else {
					fprintf(fp,"\n");
				}	
			break;
			case	4:	/* string */
				cpp=(char **)p;
			fprintf(fp,"%s\n",(cpp[0])?cpp[0]:"");
			break;
			case	9:	/* rest */
			case	5:	/* [string] */
				cppp=(char ***)p;
				if(l>0 && cppp[0]) {
					for(n=0;n<(l-1);n++) {
						fprintf(fp,"%s,",cppp[0][n]);
					}
					fprintf(fp,"%s\n",cppp[0][l-1]);
				} else {
					fprintf(fp,"\n");
				}
			break;
#ifdef	NQ_64
			case	6: /* maxint */
				qp=(long long int *)p;
				fprintf(fp,"%lld\n",qp[0]);
			break;
			case	7: /* [maxint] */
				qpp=(long long int **)p;
				if(l>0 && qpp[0]) {
					for(n=0;n<(l-1);n++) {
						fprintf(fp,"%lld,",qpp[0][n]);
					}
					fprintf(fp,"%lld\n",qpp[0][l-1]);
				} else {
					fprintf(fp,"\n");
				}
			break;
#endif
			case	8:	/* bool */
				fprintf(fp,"%s\n",(isvalid)?"true":"false");
			break;
			case	10:	/* enum */
				ep=(int *)p;
				fprintf(fp,"%s\n",OptNames[ep[0]]);
			break;
			}
		} else {	/* isvalid. */
			fprintf(fp,"%s:\n",Names[nidx]);	/* Unspecified argument. */
		}
		i+=4;
	}
	if(fp!=stdout) {
		fclose(fp);
	}
} else {
	fprintf(stderr,"Unable to write arguments to \"%s\".\n",Filename);
}

}


NQ_FUNUSED static void readin_nq(long *Meta,unsigned char *Data,char *Filename,char **Names,char **OptNames)
{
FILE *fp;
int i,idx,nidx,n,*l=0;
void *p;
int *ep;
long int *ip,**ipp;
#ifdef	NQ_64
long long int *qp,**qpp;
#endif
double *dp,**dpp;
char *cp,**cpp,***cppp;
char *lbuf;

if(strcmp(Filename,"-")) {
	fp=fopen(Filename,"rb");
} else {
	fp=stdin;
}

if(fp) {
	lbuf=(char *)malloc(4096);
	if(!lbuf) {
		fprintf(stderr,"Internal error reading arguments! No free store!\n");
		return;
	}
	fgets(lbuf,4096,fp);
	if(strncmp(lbuf,"The Frobozz Magic File Company",30)) {
		fprintf(stderr,"Invalid argumentfile!\n");
		free(lbuf);
		return;
	}
	i=4;	/* Start of arg descriptors. */
	while(fgets(lbuf,4096,fp),!feof(fp)) {
		cp=strchr(lbuf,':');
		if(cp) {
			*cp++=0;
			idx=-1;
			while(Names[++idx]) {
				if(!strcmp(lbuf,Names[idx])) {
					break;
				}
			}
			if(!Names[idx]) {
				fprintf(stderr,"Warning! Unrecognised argument \"%s\" in file.\n",lbuf);
				continue;
			}
			nidx=idx;
			idx=4*idx+4;
			memmove(lbuf,cp,strlen(cp)+1);
		} else {
			/* Ignore. */
			continue;
		}
		lbuf[strlen(lbuf)-1]=0;	/* Remove \n at end. */
		if(lbuf[0]==0) {
			continue;	/* Unspecified arguments are ignored (not set). */
		}
		p=(void *)&Data[Meta[idx+1]];
		if(Meta[idx+2]>=0) {
			l=((int *)&Data[Meta[idx+2]]);
		}
		Data[Meta[idx+3]]=FILEFLAG_NQ;
		switch(Meta[idx]) {
		case	0:	/* int */
			ip=(long int *)p;
			ip[0]=atoi(lbuf);
		break;
		case	1:	/* [int] */
			ipp=(long int **)p;
			cpp=LSplit_nq(lbuf,l);
			ipp[0]=(long int *)malloc(*l*sizeof(long int));
   		MemTrackList_nq[MemTrackIdx_nq++]=ipp[0];
			for(n=0;n<*l;n++) {
				ipp[0][n]=atoi(cpp[n]);
			}
			free(cpp);
		break;
		case	2:	/* float */
			dp=(double *)p;
			dp[0]=atof(lbuf);
		break;
		case	3:	/* [float] */
			dpp=(double **)p;
			cpp=LSplit_nq(lbuf,l);
			dpp[0]=(double *)malloc(*l*sizeof(double));
			MemTrackList_nq[MemTrackIdx_nq++]=dpp[0];
			for(n=0;n<*l;n++) {
				dpp[0][n]=atof(cpp[n]);
			}
			free(cpp);
		break;
		case	4:	/* string */
			cpp=(char **)p;
			cpp[0]=0;
			if(lbuf[0]) {
				cpp[0]=strcpy((char *)malloc(strlen(lbuf)+1),lbuf); /*strdup(lbuf);*/
				MemTrackList_nq[MemTrackIdx_nq++]=cpp[0];
			}
		break;
		case	9:	/* rest */
		case	5:	/* [string] */
			cppp=(char ***)p;
			cpp=LSplit_nq(lbuf,l);
			MemTrackList_nq[MemTrackIdx_nq++]=cpp;
			cppp[0]=cpp;
		break;
#ifdef	NQ_64
		case	6:	/* maxint */
			qp=(long long int *)p;
			qp[0]=atoll(lbuf);
		break;
		case	7:	/* [maxint] */
			qpp=(long long int **)p;
			cpp=LSplit_nq(lbuf,l);
			qpp[0]=(long long int *)malloc(*l*sizeof(long long int));
   		MemTrackList_nq[MemTrackIdx_nq++]=qpp[0];
			for(n=0;n<*l;n++) {
				qpp[0][n]=atoll(cpp[n]);
			}
			free(cpp);
		break;
#endif
		case	8:	/* bool */
			if(!strcmp(lbuf,"false")) {
				Data[Meta[idx+3]]=NONEFLAG_NQ;
			}
		break;
		case	10:	/* enum */
			ep=(int *)p;
			n=-1;
			while(OptNames[++n]) {
				if(!strcmp(OptNames[n],lbuf)) {
					break;
				}
			}
			if(!OptNames[n]) {
				fprintf(stderr,"Invalid option to argument %s in file!\n",Names[nidx]);
				return;
			}
			ep[0]=n;
		break;
		}
		i+=4;
	}
	free(lbuf);
	if(fp!=stdin) {
		fclose(fp);
	}
} else {
	fprintf(stderr,"Unable to write arguments to \"%s\".\n",Filename);
}

}


#define	SaveArgs(x)		saveout_nq(Meta_nq,(unsigned char *)&ARGS,x,arg[0],Meta_names_nq,OptNames_nq,0)
#define	SaveAllArgs(x)		saveout_nq(Meta_nq,(unsigned char *)&ARGS,x,arg[0],Meta_names_nq,OptNames_nq,1)
#define	RescueArgs(x)	readin_nq(Meta_nq,(unsigned char *)&ARGS,x,Meta_names_nq,OptNames_nq)
#define	OptName(x)		OptNames_nq[x]

#ifdef	__SUNPRO_CC
#pragma	error_messages	default
#endif

#endif



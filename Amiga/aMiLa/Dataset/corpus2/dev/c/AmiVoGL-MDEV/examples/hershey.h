/* hershey.h: this file contains prototypes for the functions in
 *  the hershey font library (variously named hershey.lib, hershey.a, etc.)
 *
 *  If your compiler supports prototypes, do a #define __PROTOTYPE__
 *  before compiling (usually -D__PROTOTYPE__)
 *
 *  This little file courtesy of Dr. Charles E. Campbell, Jr.
 */
#ifndef HERSHEY_H
#define HERSHEY_H

#ifdef AZTEC_C
# ifndef AMIGA
#  define AMIGA
# endif
#else
# ifdef AMIGA
#  ifndef AZTEC_C
#   define AZTEC_C
#  endif
# endif
#endif

#ifndef __PROTOTYPE__
#ifdef AZTEC_C
#define __PROTOTYPE__
#endif
#ifdef sgi
#define __PROTOTYPE__
#endif
#endif

#ifdef __PROTOTYPE__

void check_loaded(char *);                             /* check.c         */
void hsetpath_( char *, int *, int);                   /* fhtext.c        */
void hsetpa_( char *, int *, int);                     /* fhtext.c        */
void hfont_( char *, int *, int);                      /* fhtext.c        */
void htextsize_( float *, float *);                    /* fhtext.c        */
void htexts_( float *, float *);                       /* fhtext.c        */
int hboxtext_( float *, float *, float *, float *,     /* fhtext.c        */
   char *, int *, int);
int hboxte_( float *, float *, float *, float *,       /* fhtext.c        */
   char *, int *, int);
int hboxfit_( float *, float *, int *);                /* fhtext.c        */
int hboxfi_( float *, float *, int *);                 /* fhtext.c        */
void htextang_(float *);                               /* fhtext.c        */
void htexta_(float *);                                 /* fhtext.c        */
int hdrawchar_(char *);                                /* fhtext.c        */
int hdrawc_(char *);                                   /* fhtext.c        */
int hcharstr_( char *, int *, int);                    /* fhtext.c        */
int hchars_( char *, int *, int);                      /* fhtext.c        */
float hgetfontheight_(void);                           /* fhtext.c        */
float hgetfh_(void);                                   /* fhtext.c        */
float hgetfontwidth_(void);                            /* fhtext.c        */
float hgetfw_(void);                                   /* fhtext.c        */
float hgetdecender_(void);                             /* fhtext.c        */
float hgetde_(void);                                   /* fhtext.c        */
float hgetascender_(void);                             /* fhtext.c        */
float hgetas_(void);                                   /* fhtext.c        */
void hgetfontsize_( float *, float *);                 /* fhtext.c        */
void hgetfs_( float *, float *);                       /* fhtext.c        */
void hgetcharsize_( char *, float *, float *);         /* fhtext.c        */
void hgetch_( char *, float *, float *);               /* fhtext.c        */
void hfixedwidth_(int *);                              /* fhtext.c        */
void hfixed_(int *);                                   /* fhtext.c        */
void hcentertext_(int *);                              /* fhtext.c        */
void hcente_(int *);                                   /* fhtext.c        */
void hrightjustify_(int *);                            /* fhtext.c        */
void hright_(int *);                                   /* fhtext.c        */
void hleftjustify_(int *);                             /* fhtext.c        */
void hleftj_(int *);                                   /* fhtext.c        */
int hnumchars_(void);                                  /* fhtext.c        */
int hnumch_(void);                                     /* fhtext.c        */
float hstrlength_( char *, int *, int);                /* fhtext.c        */
float hstrle_( char *, int);                           /* fhtext.c        */
char * hallocate(unsigned);                            /* halloc.c        */
void hfont(char *);                                    /* htext.c         */
int hnumchars(void);                                   /* htext.c         */
void hsetpath(char *);                                 /* htext.c         */
void hgetcharsize(char, float *, float *);             /* htext.c         */
void hdrawchar(int);                                   /* htext.c         */
void htextsize(float,float);                           /* htext.c         */
float hgetfontwidth(void);                             /* htext.c         */
float hgetfontheight(void);                            /* htext.c         */
void hgetfontsize(float *, float *);                   /* htext.c         */
float hgetdecender(void);                              /* htext.c         */
float hgetascender(void);                              /* htext.c         */
void hcharstr(char *);                                 /* htext.c         */
float hstrlength(char *);                              /* htext.c         */
void hboxtext(float, float, float, float, char *);     /* htext.c         */
void hboxfit(float, float, int);                       /* htext.c         */
void hcentertext(int);                                 /* htext.c         */
void hrightjustify(int);                               /* htext.c         */
void hleftjustify(int);                                /* htext.c         */
void hfixedwidth(int);                                 /* htext.c         */
void htextang(float);                                  /* htext.c         */

#else	/* __PROTOTYPE__ */

extern void check_loaded();                            /* check.c         */
extern void hsetpath_();                               /* fhtext.c        */
extern void hsetpa_();                                 /* fhtext.c        */
extern void hfont_();                                  /* fhtext.c        */
extern void htextsize_();                              /* fhtext.c        */
extern void htexts_();                                 /* fhtext.c        */
extern int hboxtext_();                                /* fhtext.c        */
extern int hboxte_();                                  /* fhtext.c        */
extern int hboxfit_();                                 /* fhtext.c        */
extern int hboxfi_();                                  /* fhtext.c        */
extern void htextang_();                               /* fhtext.c        */
extern void htexta_();                                 /* fhtext.c        */
extern int hdrawchar_();                               /* fhtext.c        */
extern int hdrawc_();                                  /* fhtext.c        */
extern int hcharstr_();                                /* fhtext.c        */
extern int hchars_();                                  /* fhtext.c        */
extern float hgetfontheight_();                        /* fhtext.c        */
extern float hgetfh_();                                /* fhtext.c        */
extern float hgetfontwidth_();                         /* fhtext.c        */
extern float hgetfw_();                                /* fhtext.c        */
extern float hgetdecender_();                          /* fhtext.c        */
extern float hgetde_();                                /* fhtext.c        */
extern float hgetascender_();                          /* fhtext.c        */
extern float hgetas_();                                /* fhtext.c        */
extern void hgetfontsize_();                           /* fhtext.c        */
extern void hgetfs_();                                 /* fhtext.c        */
extern void hgetcharsize_();                           /* fhtext.c        */
extern void hgetch_();                                 /* fhtext.c        */
extern void hfixedwidth_();                            /* fhtext.c        */
extern void hfixed_();                                 /* fhtext.c        */
extern void hcentertext_();                            /* fhtext.c        */
extern void hcente_();                                 /* fhtext.c        */
extern void hrightjustify_();                          /* fhtext.c        */
extern void hright_();                                 /* fhtext.c        */
extern void hleftjustify_();                           /* fhtext.c        */
extern void hleftj_();                                 /* fhtext.c        */
extern int hnumchars_();                               /* fhtext.c        */
extern int hnumch_();                                  /* fhtext.c        */
extern float hstrlength_();                            /* fhtext.c        */
extern float hstrle_();                                /* fhtext.c        */
extern char * hallocate();                             /* halloc.c        */
extern void hfont();                                   /* htext.c         */
extern int hnumchars();                                /* htext.c         */
extern void hsetpath();                                /* htext.c         */
extern void hgetcharsize();                            /* htext.c         */
extern void hdrawchar();                               /* htext.c         */
extern void htextsize();                               /* htext.c         */
extern float hgetfontwidth();                          /* htext.c         */
extern float hgetfontheight();                         /* htext.c         */
extern void hgetfontsize();                            /* htext.c         */
extern float hgetdecender();                           /* htext.c         */
extern float hgetascender();                           /* htext.c         */
extern void hcharstr();                                /* htext.c         */
extern float hstrlength();                             /* htext.c         */
extern void hboxtext();                                /* htext.c         */
extern void hboxfit();                                 /* htext.c         */
extern void hcentertext();                             /* htext.c         */
extern void hrightjustify();                           /* htext.c         */
extern void hleftjustify();                            /* htext.c         */
extern void hfixedwidth();                             /* htext.c         */
extern void htextang();                                /* htext.c         */

#endif	/* __PROTOTYPE__ */

#endif	/* HERSHEY_H */

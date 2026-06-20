/* fhtext.c: */
#include <stdio.h>
#include <string.h>
#include "hershey.h"

/* --------------------------------------------------------------------- */

/*
 * hsetpath_
 */
void hsetpath_(
  char *fpath,
  int *len1,
  int len2)
{
	char	buf[BUFSIZ];

	strncpy(buf, fpath, len2);
	buf[*len1] = 0;

	hsetpath(buf);
}

/*
 * hsetpa_
 */
void hsetpa_(
  char *fpath,
  int *len1,
  int len2)
{
	char	buf[BUFSIZ];

	strncpy(buf, fpath, len2);
	buf[*len1] = 0;

	hsetpath(buf);
}

/*
 * hfont_
 */
void hfont_(
  char *fontfile,
  int *len1,
  int len2)
{
	char	buf[BUFSIZ];

	strncpy(buf, fontfile, len2);
	buf[*len1] = 0;

	hfont(buf);
}

/*
 * htextsize_
 */
void htextsize_(
  float *width,
  float *height)
{
	htextsize(*width, *height);
}

/*
 * htexts_
 */
void htexts_(
  float *width,
  float *height)
{
	htextsize(*width, *height);
}

/*
 * hboxtext_
 */
int hboxtext_(
  float *x,
  float *y,
  float *l,
  float *h,
  char *s,
  int *length,
  int len)
{
	char		buf[BUFSIZ];
	register char   *p;

	strncpy(buf, s, len);
	buf[*length] = 0;

	hboxtext(*x, *y, *l, *h, buf);
}

/*
 * hboxte_	(same as hboxtext_)
 */
int hboxte_(
  float *x,
  float *y,
  float *l,
  float *h,
  char *s,
  int *length,
  int len)
{
	char		buf[BUFSIZ];
	register char   *p;

	strncpy(buf, s, len);
	buf[*length] = 0;

	hboxtext(*x, *y, *l, *h, buf);
}

/*
 * hboxfit_
 */
int hboxfit_(
  float *l,
  float *h,
  int *nchars)
{
	hboxfit(*l, *h, *nchars);
}

/*
 * hboxfi_
 */
int hboxfi_(
  float *l,
  float *h,
  int *nchars)
{
	hboxfit(*l, *h, *nchars);
}

/*
 * htextang_
 */
void htextang_(float *ang)
{
	htextang(*ang);
}

/*
 * htexta_
 */
void htexta_(float *ang)
{
	htextang(*ang);
}

/*
 * hdrawchar_
 */
int hdrawchar_(char *s)
{
	hdrawchar(*s);
}

/*
 * hdrawc_
 */
int hdrawc_(char *s)
{
	hdrawchar(*s);
}

/*
 * hcharstr_
 */
int hcharstr_(
  char *s,
  int *length,
  int len)
{
        char            buf[BUFSIZ];
	register char   *p;

	strncpy(buf, s, len);
	buf[*length] = 0;
	hcharstr(buf);
}

/*
 * hchars_
 */
int hchars_(
  char *s,
  int *length,
  int len)
{
        char            buf[BUFSIZ];
	register char   *p;

	strncpy(buf, s, len);
	buf[*length] = 0;
	hcharstr(buf);
}

/*
 * hgetfontheight_
 */
float hgetfontheight_(void)
{
	return(hgetfontheight());
}

/*
 * hgetfh_
 */
float hgetfh_(void)
{
	return(hgetfontheight());
}

/*
 * hgetfontwidth_
 */
float hgetfontwidth_(void)
{
	return(hgetfontwidth());
}

/*
 * hgetfw_
 */
float hgetfw_(void)
{
	return(hgetfontwidth());
}

/*
 * hgetdecender_
 */
float hgetdecender_(void)
{
	return(hgetdecender());
}

/*
 * hgetde_
 */
float hgetde_(void)
{
	return(hgetdecender());
}

/*
 * hgetascender_
 */
float hgetascender_(void)
{
	return(hgetascender());
}

/*
 * hgetas_
 */
float hgetas_(void)
{
	return(hgetascender());
}

/*
 * hgetfontsize_
 */
void hgetfontsize_(
  float *cw,
  float *ch)
{
	hgetfontsize(cw, ch);
}

/*
 * hgetfs_
 */
void hgetfs_(
  float *cw,
  float *ch)
{
	hgetfontsize(cw, ch);
}

/*
 * hgetcharsize_
 */
void hgetcharsize_(
  char *c,
  float *cw,
  float *ch)
{
	hgetcharsize(*c, cw, ch);
}

/*
 * hgetch_
 */
void hgetch_(
  char *c,
  float *cw,
  float *ch)
{
	hgetcharsize(*c, cw, ch);
}

/*
 * hfixedwidth
 */
void hfixedwidth_(int *i)
{
	hfixedwidth(*i);
}

/*
 * hfixed_
 */
void hfixed_(int *i)
{
	hfixedwidth(*i);
}

/*
 * hcentertext
 */
void hcentertext_(int *i)
{
	hcentertext(*i);
}

/*
 * hcente_
 */
void hcente_(int *i)
{
	hcentertext(*i);
}

/*
 * hrightjustify_
 */
void hrightjustify_(int *i)
{
	hrightjustify(*i);
}

/*
 * hright_
 */
void hright_(int *i)
{
	hrightjustify(*i);
}

/*
 * hleftjustify_
 */
void hleftjustify_(int *i)
{
	hleftjustify(*i);
}

/*
 * hleftj_
 */
void hleftj_(int *i)
{
	hleftjustify(*i);
}

/*
 * hnumchars_
 */
int hnumchars_(void)
{
	return(hnumchars());
}

/*
 * hnumch_
 */
int hnumch_(void)
{
	return(hnumchars());
}

/*
 * hstrlength_
 */
float hstrlength_(
  char *str,
  int *len0,
  int len1)
{
        char            buf[BUFSIZ];
	register char   *p;

	strncpy(buf, str, len1);
	buf[*len0] = 0;

	return(hstrlength(buf));
}

/*
 * hstrle_
 */
float hstrle_(
  char *str,
  int len)
{
        char            buf[BUFSIZ];
	register char   *p;

	strncpy(buf, str, len);
	buf[len] = 0;

	for (p = &buf[len - 1]; *p == ' '; p--)
		;

	*++p = 0;

	return(hstrlength(buf));
}

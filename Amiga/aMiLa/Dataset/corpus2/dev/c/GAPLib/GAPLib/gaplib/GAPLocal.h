
#ifndef __GAP_LOCAL_H__
#define __GAP_LOCAL_H__
#include <GAP.h>
#define STATIC_PBOX
#undef k2I
struct r5X {void *j1H;double c8Y;};extern IPTR l5T(struct Population *,unsigned long int);
extern void n9N(struct Population *,IPTR,unsigned long int);extern void f9P(struct Population *,IPTR,unsigned long int);
extern void y8E(struct Population *);extern double q2M(struct Population *,double);
extern void l3Z (void *,void *,int);extern double e6M(void *,void *,int);extern void y6C (void *,int);
extern double h5J(long int,long int);extern double z5P(struct Population *,double,void *,int);

#ifdef k2I
#define t7X(x) (*((unsigned long *)#x))
#else
#define t7X(x) ((unsigned long)((#x[0])<<24)|((#x[1])<<16)|((#x[2])<<8)|(#x[3]))
#endif
#define z3H(x) ((x)*(x))
#define l3B (1L<<0)
#define c4U (1L<<1)
#define x5L 1
#define g0U 7
#define f3P 0
#define m6C 1
#define c2Y 2
#endif

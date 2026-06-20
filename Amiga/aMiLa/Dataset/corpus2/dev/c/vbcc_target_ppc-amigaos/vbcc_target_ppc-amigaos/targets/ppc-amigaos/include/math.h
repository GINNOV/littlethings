/* math.h - PowerPC */

#ifndef __MATH_H
#define __MATH_H 1

extern const char __infinity[];
#define HUGE_VAL (*(const double *)(const void *)__infinity)

int    isinf(double);
int    isnan(double);

double sin(double);
double cos(double);
double tan(double);
double sinh(double);
double cosh(double);
double tanh(double);
double asin(double);
double acos(double);
double atan(double);
double exp(double);
double log(double);
double log10(double);
double pow(double,double);
double sqrt(double);
double ceil(double);
double floor(double);
double fabs(double);
double atan2(double,double);
double ldexp(double,int);
double frexp(double,int *);
double modf(double,double *);
double fmod(double,double);

#ifndef __NOINLINE__
double fabs(__reg("f1") double) = "\tfabs\t1,1";
#endif

#endif

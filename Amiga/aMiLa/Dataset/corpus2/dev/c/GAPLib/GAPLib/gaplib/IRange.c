
#include <limits.h>
double IRange(const unsigned long int,const double,const double);double IRange(const unsigned long int r7J,const double Lo,const double Hi)
{return(Lo+((r7J*(Hi-Lo))/((double)ULONG_MAX)));}
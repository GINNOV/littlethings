
#include <errno.h>

double nroot(long int,double);
static double root(long int,double);
static double rpow(double,long int);
static double sqr(double);

double nroot(long int n,double x)
{
double result;
int olderr=errno;

if (n<1)
	{
	errno=EDOM;
	return 0;
	}
if (x<0)
	{
	if (n%2) 
		{
		result= -root(n,-x);
		errno=olderr;
		}
	else
		{
		errno=EDOM;
		return 0;
		}
	}
else
	{
	result=root(n,x);
	errno=olderr;
	} 
return result;
}

/*****************************************************************/

static double root(long int n,double x)
{
double res,low=0,mid,upp=1;

if (n==1) return x;
if (x==0) return 0;

while ((res=rpow(upp,n))<x)
	{
	low=upp;
	upp*=2;
	}
if (res==x) return upp;

mid=low+((upp-low)/2);

do
	{
	res=rpow(mid,n);
	if (res<x)
		{
		low=mid;
		mid+=((upp-mid)/2);
		}
	else if (res>x)
		{
		upp=mid;
		mid-=((mid-low)/2);
		}
	else return mid;
	} while (upp-mid); 

return mid;
}

/*****************************************************************/
 
static double rpow(double a,long int n)
{
if (n==1) return a;
if (n%2) return (a*sqr(rpow(a,n/2)));
else return sqr(rpow(a,n/2));
}

/*****************************************************************/

static double sqr(double a)
{
return (a*a);
}

#include <iostream.h>
#include "Matrix.h"

int main(int argc,char **argv)
{
int i,j;
mtrxtype a[]={2.0,3.0,4.0,1.0,2.0,3.0,4.0,3.0,5.0};
mtrxtype b[]={7.0,8.0,9.0};
Vector v(3,b);
Matrix m(3,3,a);
LUmatrix c;
print(m);
cout << "\n";
c=LUdecompose(m);
print(transpose(getp(c))*getp(c));
cout <<"\n";
print(getp(c));
cout <<"\n";
print(getl(c));
cout <<"\n";
print(getu(c));
cout <<"\n";
print(LUsolve(c,v),1);
cout << "\n";
print(solve(m,v),1);
cout << "\n";
print(inverse(m));
cout << "\n";
print(m*inverse(m));
return(0);
}


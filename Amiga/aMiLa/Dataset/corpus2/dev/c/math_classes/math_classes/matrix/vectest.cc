#include <iostream.h>
#include "Matrix.h"

int main(int argc,char **argv)
{
int i,j;
vectype a[]={2.0,3.0,4.0,1.0,2.0,3.0,4.0,3.0,5.0};
vectype b[]={7.0,8.0,9.0};
Vector v(3,b);
Vector u(3,a);
print (u,0);
print (v,0);
cout << v.size() << endl;
cout << u*v << endl;
return(0);
}


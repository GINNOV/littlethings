
#include <iostream.h>
#include <stdio.h>
#include "bignum.h"

#define peol putchar('\n')

int main()
	{
	Bignum a;
	Bignum b;
/*	
	a=99;
	b=99;

	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
	print(a*b);
	peol;
	a=23;
	b=56;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;	
	print((-a)*b);
	peol;
	a=-5;
	b=73;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
	print(a*b);
	peol;
	a="-98654";
	b="32";
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
	print(a);
	peol;
	print(b);
	peol;
	print(a-b);	
	peol;
	
	a=-8;
	b=6;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl; 	
peol;
	a=-5;
	b=-6;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
peol;
	a=5;
	b=-5;
	
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
peol;
	
	a=-98;
	b=-75;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
peol;
	
	
	a=-37;
	b=a;
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
peol;
	
	a*=b;
	print(a);peol;
	print(b);peol;
	a=-5;
	b=-9;
	print(a*b);peol;
	print(a-b);peol;
	print(a+b);peol;
	
	a="-987651";
	b="-123469";
	cout << (a < b) << endl;
	cout << (a <= b) << endl;
	cout << (a >= b) << endl;
	cout << (a > b) << endl;
peol;

*/
	
	a=10;
	b=3;
	print(a/b);
	peol;
a=1234;b=24;
print(a/b);peol;
a=20;b=4;print(a/b);peol;
a="10000000000000";
b=2;
print(a/b);peol;


	a=2.34e5;
	b=7;
	print(a);peol;
	print(a*b);peol;
	cout << int(a) << endl;
	cout << double(a) << endl;
	printf("%f\n", 2.34e5 *7);
	return 0;
	}


/*
#include <iostream.h>
#include <iomanip.h>
*/

#include <stdio.h>
#include <stdlib.h>
#include "Matrix.h"

void error(char *s)	
	{
	puts(s);
	exit(EXIT_FAILURE);
	}
	
void print(const Matrix& m)
	{
	for(unsigned int i=1;i<=m.rows();i++)
		{
		for(unsigned int j=1;j<=m.cols();j++)
			{
			
/*			cout.setf(ios::left);
			cout.setf(ios::adjustfield);
			cout.setf(ios::fixed);
			cout <<setw(8) <<setprecision(4) <<m(i,j);
*/

			printf("%8.4f",(double)m(i,j));
			}
//		cout << "\n";
		printf("\n");
	
		}
	}

		

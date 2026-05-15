/* Data to raw */
#include <stdio.h>
#include <intuition/intuition.h>
#include "amigafuria.h"

int main()
{
	FILE *fp;

	fp = fopen( "amigafuria.raw" , "w" );
	fwrite(amigaFuriaData , 1 , sizeof(amigaFuriaData) , fp );

	fclose(fp);
	return (0);
}
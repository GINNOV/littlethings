#include <stdio.h>

void main( void ) 
{
FILE *fp;
int dato;

   fp = fopen("dati.dat", "w");
   if ( fp == NULL ) { 
       printf("ERROR: fopen fallita\n");
       return;
   }

   while ( scanf( "%d", &dato ) != EOF ) {
       fprintf( fp, "%2d ", dato );
   }

   fclose( fp );
}

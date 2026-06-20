#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MAX_SIZE_STACK  256

void main( int argc, char *argv[])
{
  double   *p, *head;

  head = ( double *)malloc( MAX_SIZE_STACK * sizeof( double )); 
  p = head; 
  
  while( --argc >0 )
    if(( *++argv)[0] == '_') {
        switch ( *++argv[0]) {
           case '+' :
                printf(" %f + %f\n", p[-2], p[-1] );
                p[-2] = p[-2] + p[-1];
                --p;
                break;
           case '-' :
                printf(" %f - %f\n", p[-2], p[-1] );
                p[-2] = p[-2] - p[-1];
                --p;
                break;
           case '/' :
                printf(" %f / %f\n", p[-2], p[-1] );
                p[-2] = p[-2] / p[-1];
                --p;
                break;
           case '*' :
                printf(" %f * %f\n", p[-2], p[-1] );
                p[-2] = p[-2] * p[-1];
                --p;
                break;
           default  :
                printf("\nERRORE\n");
                return;
                break;
        }
    }
    else
        *p++ = atof( *argv);
  
  printf("risultato: %f\n", *--p);
  return;
}

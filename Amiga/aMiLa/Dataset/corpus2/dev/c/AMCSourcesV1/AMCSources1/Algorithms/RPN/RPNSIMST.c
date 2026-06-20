#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MAX_SIZE_STACK  256

double *p;

void push( double );
double pop( void );

void main( int argc, char *argv[])
{
  double   *head;
  double   a, b;
  head = ( double *)malloc( MAX_SIZE_STACK * sizeof( double )); 
  p = head; 

  while( --argc >0 )
    if(( *++argv)[0] == '_') {
        switch ( *++argv[0]) {
           case '+' :
                a = pop();
                b = pop();
                printf(" %f + %f\n", b, a );
                push( b + a );
                break;
           case '-' :
                a = pop();
                b = pop();
                printf(" %f - %f\n", b, a );
                push( b - a );
                break;
           case '/' :
                a = pop();
                b = pop();
                printf(" %f / %f\n", b, a );
                push( b / a );
                break;
           case '*' :
                a = pop();
                b = pop();
                printf(" %f * %f\n", b, a );
                push( b * a );
                break;
           default  :
                printf("\nERRORE\n");
                return;
                break;
        }
    }
    else {
        push( atof( *argv));
    }

  printf("risultato: %f\n", pop() );
  return;
}

void push( double num )
{
    *p = num;
    p=p+1;
    return;
}

double pop( void )
{          
   p=p-1;
   return *p;
}

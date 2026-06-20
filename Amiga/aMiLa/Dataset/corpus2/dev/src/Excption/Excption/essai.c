/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION EXAMPLE                                       */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : essai.c                                                 */
/*  FONCTION    :                                                         */
/*                                                                        */
/*  RESPONSABLE : HEWES Gerald                                            */
/*  TEL         : 33 (1) 46 24 20 27                                      */
/*                                                                        */
/**************************************************************************/

/**************************************************************************/
/*                                                                        */
/* HEW 880324 Example file of exception handler                           */
/*                                                                        */
/**************************************************************************/



#include <stdio.h>
#include "local:excption.h"
#include <proto/exec.h>

ExcpGlobal;

void Subroutine();
void Subroutine2();

main()
{
  printf("Hello World! Watch:\n");

  MAIN
   {
     printf("protected code\n");
     Subroutine();
     Subroutine2();
     puts("Everything Works Fine To Here\n");
   }
  EXCEPTION
   {
     printf("Handler\n");
     printf("Exception : %d \n",Eclass);
   }
  OUT

  puts("Well Exception seems to work! Bye!\n");
  return(0);
}

void Subroutine()

{
 ExcpDeclare;
 FILE *handle;
 int x=1,z;
 int y = 0;

 printf("Still OK\n");

 BEGIN
  {
    printf("Before Divide\n");
    z = x/y;
    printf("After Divide\n");
    if (!(handle = fopen("tourt","w"))) RAISE(IO_WRITE_ERROR);
    if (!fprintf(handle,"Hello World!\n")) RAISE(IO_WRITE_ERROR);
    printf("We wrote into the file\n");
  }
 EXCEPTION
  {
   printf("Error Class = %d\n",Eclass);
   if (Eclass == 5) printf("Divide by Zero\n");
   else printf("IO ERROR\n");
  }
 END
}

void Subroutine2()

{
 int *x,y;
 ExcpDeclare;


 printf("Still OK\n");

 BEGIN
  {
    printf("Before Bad Address\n");
    x = (int *)1023;
    y = *x;
    printf("After Bad Address\n");
  }
 EXCEPTION
  {
   printf("Error Class = %d\n",Eclass);
   if (Eclass == 2) printf("Bus Error\n");
   if (Eclass == 3) printf("Bad Address\n");
   else printf("FATAL ERROR\n");
  }
 END
}


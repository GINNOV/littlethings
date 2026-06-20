/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION EXAMPLE                                       */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : fact.c                                                  */
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
static  ExcpClass FACT;

main()
{
  int n            ;
  int result       ;

  printf("Factorial?\n");
  scanf("%d",&n);
  FACT = AllocException(-1);
  if (FACT == -1) exit(20);

  MAIN
   {
     puts("protected code\n");
     result = fact(n);
   }
  EXCEPTION
   {
     puts("Handler\n");
     printf("Exception : %d \n",Eclass);
   }
  OUT
  printf("%d\n",result);
  puts("Done\n");
  FreeException(FACT);
  return(0);
}


int fact(n)
int n;

{
 ExcpDeclare;
 int result;

 BEGIN
  {
   if (n==0) RAISE(FACT);
   result = n*fact(n-1);
   if (result > 1000000000) RAISE(NUMERIC_ERROR);
  }
 EXCEPTION
  {
   if (Eclass == FACT) result = 1;
   else RAISE(Eclass);
  }
 END

 return result;
}


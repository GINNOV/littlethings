/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION HANDLER / CHIP STACK                          */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : EIAlloc.c                                               */
/*  FONCTION    :                                                         */
/*                                                                        */
/*  RESPONSABLE : HEWES Gerald                                            */
/*  TEL         : 33 (1) 46 24 20 27                                      */
/*                                                                        */
/**************************************************************************/

/**************************************************************************/
/*                                                                        */
/* HEW 880310 Ver 0.1 : First Soft Version                                */
/* HEW 880324 Ver 0.2 : Handle 68000 exceptions                           */
/* HEW 880413 Ver 0.3 : Handle 680X0 Formats                              */
/* HEW 880508 Ver 0.4 : First Released version : routines split           */
/*                      Major name changes for better homogeneity         */
/* HEW 880517 Ver 0.5 : include change. No more puts in library           */
/* HEW 880605 Ver 0.6 : Disable/Enable Function + Prototypes              */
/*                                                                        */
/**************************************************************************/

#include <stdio.h>
#include "local:excption.h"
#include <proto/exec.h>

extern E_ErrorStatus  E_global;  /* Declaration of Necessary Data */

/***************************** CODE ***************************************/


                /************************************************/
                /* Handle Excption Number Allocation            */
                /* No provision is currently made               */
                /************************************************/

extern ExcpClass E_excpfree;

extern ExcpClass AllocException(number)
ExcpClass number;

{
 if (number == -1) return(E_excpfree++);
 else return -1;
}


/*************************  CIVILISATION ENDS HERE  ***********************/



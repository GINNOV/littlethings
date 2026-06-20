/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION HANDLER / CHIP STACK                          */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : EIBlow.c                                                */
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

/**************************************************************************/

extern void EIBlow(dike,number)
E_ErrorStatus *dike;  /* Needed for the library version */
ExcpClass number;

                /************************************************/
                /* This Routine Blows an Exception, ie we pull  */
                /* out to outmost protected block, exit         */
                /************************************************/


{
  if ((dike->E_top.E_magic != EM_MAGIC))
   {
#if DEBUG
    fputs("Internal Error EXEERR03\n",stderr);
#endif
    exit(202);
   }
  else
   longjmp(dike->E_top.E_current,(int)number); /* We have to cast */
}


/*************************  CIVILISATION ENDS HERE  ***********************/


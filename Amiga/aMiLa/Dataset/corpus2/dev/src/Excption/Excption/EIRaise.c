/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION HANDLER / CHIP STACK                          */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : EIRaise.c                                               */
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
#include <exec/execbase.h>
#include <exec/tasks.h>
#include <proto/exec.h>

extern E_ErrorStatus  E_global;  /* Declaration of Necessary Data */

/***************************** CODE ***************************************/

extern void EIRaise(dike,number)
E_ErrorStatus *dike;  /* Needed for the library version */
ExcpClass number;

                /************************************************/
                /* This Routine Propagates an Exception         */
                /* depending on context                         */
                /************************************************/


{
  if ((dike->E_up == NULL)||(dike->E_up->E_magic != EM_MAGIC))
   {
#if DEBUG
    fputs("Internal Error EXEERR01\n",stderr);
#endif
    exit(200);
   }

  if (dike->E_up->E_state == E_PROTECTED)
   {
    dike->E_up->E_state = E_HANDLER;
    longjmp(dike->E_up->E_current,(int)number); /* we have to cast */
   }
  else
   {
    dike->E_up = dike->E_up->E_pred;
    if ((dike->E_up == NULL)||(dike->E_up->E_magic != EM_MAGIC))
     {
#if DEBUG
       fputs("Internal Error EXEERR02\n",stderr);
#endif
       exit(201);
     }
    else
     longjmp(dike->E_up->E_current,(int)number); /* we have to cast */
   }
}



/*************************  CIVILISATION ENDS HERE  ***********************/

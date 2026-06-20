/**************************************************************************/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*                EXCEPTION HANDLER / CHIP STACK                          */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : EIDis.c                                                 */
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
#include <exec/tasks.h>
#include <proto/exec.h>

extern E_ErrorStatus  E_global;  /* Declaration of Necessary Data */

/***************************** CODE ***************************************/

extern void ExcpDisable(dike)
E_ErrorStatus *dike;  /* Needed for the library version */

                /************************************************/
                /* Disables the trap routine for processor traps*/
                /* The only purpose is to permit debugging      */
                /* with an external debugger, like Wack,...     */
                /************************************************/


{
 struct Task *taskloc;

   taskloc = (struct Task *)FindTask(0);        /* Get Task Info      */
   taskloc->tc_TrapCode = (APTR)dike->E_OldTrapCode;
   taskloc->tc_TrapData = (APTR)dike->E_OldTrapData;

   return;
}

/*************************  CIVILISATION ENDS HERE  ***********************/


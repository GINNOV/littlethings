/**************************************************************************/
/*                                                                        */
/*                   EXCEPTION HANDLER                                    */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : E_private.h                                             */
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
/* HEW 880512 Ver 0.4 : Minor declaration changes and bug fixes           */
/* HEW 880517 Ver 0.5 : include change. No more puts in library           */
/*                                                                        */
/**************************************************************************/

#include "local:Boolean.h"
#include <exec/types.h>

/* Magic Number */

#define EM_MAGIC 640218


/*************************************************************************/


enum E_E_ERROR_STATE { E_PROTECTED, E_HANDLER };

struct E_S_ERRORLINK {
   int                    E_magic    ; /* Magic Number to test Validity */
   struct E_S_ERRORLINK   *E_pred    ; /* Previous link                 */
   jmp_buf                E_current  ; /* long jump data                */
   ExcpClass              E_number   ; /* Error Class                   */
   enum E_E_ERROR_STATE   E_state    ; /* Flag : protected/handler code */
                     };

typedef struct {
   struct E_S_ERRORLINK *E_up         ; /* Previous Handling Routine */
   struct E_S_ERRORLINK E_top         ; /* TopLevel Handling Routine */
   BOOLEAN              *E_authorised ; /* Exit authorisation        */
   APTR                 E_OldTrapCode ; /* Values pulled out of task */
   APTR                 E_OldTrapData ; /* Values pulled out of task */
                         } E_ErrorStatus;

extern E_ErrorStatus E_global;

/*************************  CIVILISATION ENDS HERE  ***********************/

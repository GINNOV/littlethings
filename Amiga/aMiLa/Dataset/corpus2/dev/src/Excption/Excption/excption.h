/**************************************************************************/
/*                                                                        */
/*                EXCEPTION HANDLER / CHIP STACK                          */
/*               ==========================================               */
/*                                                                        */
/*                                                                        */
/*  MODULE      : Exception                                               */
/*  NOM         : Exception.h                                             */
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


#ifndef E_EXCEPTION_H
#define E_EXCEPTION_H

typedef int   ExcpClass;

#include <setjmp.h>
#include "local:private/excppriv.h"

/*********** PREDEFINED  EXCEPTION CLASSES 0-2047 ************************/

                /************************************************/
                /*  All Values from 0-65535 are reserved and    */
                /*  should not be used by application programs  */
                /*  Since the class is an unsigned int that     */
                /*  still leaves 2**32-2*8 different values     */
                /*  That should satisfy every applications      */
                /*  Values 0-31 are resserved for trap          */
                /*  Handling.                                   */
                /************************************************/

#define  BUS_ERROR           2
#define  ADDRESS_ERROR       3
#define  ILLEGAL_INSTRUCTION 4
#define  ZERO_DIVIDE         5
#define  CHK_EXCP            6
#define  TRAPV_EXCP          7
#define  PRIVILEGE_ERROR     8
#define  TRACE               9
#define  EMUL1010           10
#define  EMUL1111           11


#define  NUMERIC_ERROR    1025
#define  CONSTRAINT_ERROR 1026
#define  STORAGE_ERROR    1027
#define  TASKING_ERROR    1028
#define  IO_READ_ERROR    1029
#define  IO_WRITE_ERROR   1030
#define  IO_ERROR         1031
#define  ABORT_ON_CTRLC   1032
#define  ABORT_ON_CTRLD   1033

/***************************** Functions *********************************/

extern void      EIRaise(E_ErrorStatus *,ExcpClass) ;
extern void      EIBlow(E_ErrorStatus *,ExcpClass)  ;
extern ExcpClass AllocException(ExcpClass)          ;
extern void      FreeException(ExcpClass)           ;
extern void      EIInit(E_ErrorStatus *)            ;
extern void      EIExcpHandler()                    ;
extern void      EIUnmount(E_ErrorStatus *)         ;
extern void      ExcpDisable(E_ErrorStatus *)       ;
extern void      ExcpEnable(E_ErrorStatus *)        ;

/***************************** Macros    *********************************/

#define ExcpDeclare struct E_S_ERRORLINK E_buffer

#define ExcpGlobal  E_ErrorStatus E_global;\
                    ExcpClass E_excpfree=65536

#define BEGIN  E_buffer.E_pred = E_global.E_up;\
E_global.E_up = &E_buffer;E_buffer.E_state = E_PROTECTED;\
E_buffer.E_magic = EM_MAGIC;\
if((E_buffer.E_number = setjmp(E_buffer.E_current))==0)

#define EXCEPTION else

#define END E_global.E_up = E_buffer.E_pred;

#define MAIN EIInit(&E_global);\
if((E_global.E_top.E_number = setjmp(E_global.E_top.E_current))==0)

#define OUT EIUnmount(&E_global);

#define Eclass E_global.E_up->E_number

#define RAISE(number) EIRaise(&E_global,number)
#define BLOW(number)  EIBlow(&E_global,number)

        /*   ---------- V 0.6 ----------  */

#define EXCPENABLE   ExcpEnable(&E_global)
#define EXCPDISABLE  ExcpDisable(&E_global)

#endif

/*************************  CIVILISATION ENDS HERE  ***********************/


#ifndef PRAGMAS_EASYREXX_PRAGMAS_H
#define PRAGMAS_EASYREXX_PRAGMAS_H

#ifndef CLIB_EASYREXX_PROTOS_H
#include <clib/easyrexx_protos.h>
#endif

#ifdef PRAGMAS_DECLARING_LIBBASE
extern struct Library *EasyRexxBase;
#endif

#pragma libcall EasyRexxBase FreeARexxContext 4e 801
#pragma libcall EasyRexxBase AllocARexxContextA 54 801
#pragma libcall EasyRexxBase GetARexxMsg 5a 801
#pragma libcall EasyRexxBase SendARexxCommandA 60 8902
#pragma libcall EasyRexxBase ReplyARexxMsgA 66 8902
#pragma libcall EasyRexxBase ARexxCommandShellA 6c 8902
#pragma libcall EasyRexxBase AllocARexxMacroA 72 801
#pragma libcall EasyRexxBase IsARexxMacroEmpty 78 801
#pragma libcall EasyRexxBase ClearARexxMacro 7e 801
#pragma libcall EasyRexxBase FreeARexxMacro 84 801
#pragma libcall EasyRexxBase AddARexxMacroCommandA 8a 8902
#pragma libcall EasyRexxBase WriteARexxMacroA 90 8BA904
#pragma libcall EasyRexxBase RunARexxMacroA 96 8902
#pragma libcall EasyRexxBase CreateARexxStemA 9c 8A903

#ifdef __SASC_60
#pragma tagcall EasyRexxBase AllocARexxContext 54 801
#pragma tagcall EasyRexxBase SendARexxCommand 60 8902
#pragma tagcall EasyRexxBase ReplyARexxMsg 66 8902
#pragma tagcall EasyRexxBase ARexxCommandShell 6c 8902
#pragma tagcall EasyRexxBase AllocARexxMacro 72 801
#pragma tagcall EasyRexxBase AddARexxMacroCommand 8a 8902
#pragma tagcall EasyRexxBase WriteARexxMacro 90 8BA904
#pragma tagcall EasyRexxBase RunARexxMacro 96 8902
#pragma tagcall EasyRexxBase CreateARexxStem 9c 8A903
#endif	/*  __SASC_60  */

#endif	/*  PRAGMAS_EASYREXX_PRAGMAS_H  */

/*
 *	File:					EasyRexx_protos.h
 *	Description:	
 *
 *	(C) 1994,1995, Ketil Hunn
 *
 */

#ifndef CLIB_EASYREXX_PROTOS_H
#define	CLIB_EASYREXX_PROTOS_H

#ifndef  CLIB_EXEC_PROTOS_H
#include <clib/exec_protos.h>
#endif

#ifndef ER_LIB
#ifndef PRAGMAS_EASYREXX_PRAGMAS_H
#include <pragmas/EasyRexx_pragmas.h>
#endif
#endif

#ifndef ER_LIB
#ifndef EASYREXX_H
#include <libraries/EasyRexx.h>
#endif
#endif

/*** PROTOTYPES **********************************************************************/
__asm __saveds struct ARexxContext *AllocARexxContextA(register __a0 struct TagItem	*taglist);
__asm __saveds void FreeARexxContext(register __a0 struct ARexxContext *context);
__asm __saveds BYTE GetARexxMsg(register __a0 struct ARexxContext *context);
__asm __saveds LONG SendARexxCommandA(register __a1 UBYTE						*command,
																			register __a0 struct TagItem	*taglist);
__asm __saveds void ReplyARexxMsgA(	register __a1 struct ARexxContext *context,
																		register __a0 struct TagItem			*taglist);

/*** PROTOTYPES V2.0 *****************************************************************/
__asm __saveds BYTE ARexxCommandShellA(	register __a1 struct ARexxContext *context,
																				register __a0 struct TagItem *taglist);

/*** PROTOTYPES V3.0 *****************************************************************/
__asm __saveds ARexxMacro AllocARexxMacroA(register __a0 struct TagItem *taglist);
__asm __saveds BYTE IsARexxMacroEmpty(register __a0 ARexxMacro macro);
__asm __saveds void ClearARexxMacro(register __a0 ARexxMacro macro);
__asm __saveds void FreeARexxMacro(register __a0 ARexxMacro macro);
__asm __saveds void AddARexxMacroCommandA(register __a1 ARexxMacro			macro,
																					register __a0 struct TagItem	*taglist);
__asm __saveds BYTE WriteARexxMacroA(register __a1 struct ARexxContext	*context,
																		 register __a2 ARexxMacro						macro,
																		 register __a3 UBYTE								*macroname,
																		 register __a0 struct TagItem				*taglist);
__asm __saveds UBYTE RunARexxMacroA(register __a1 struct ARexxContext	*context,
																		register __a0 struct TagItem			*taglist);
__asm __saveds BYTE CreateARexxStemA(	register __a1 struct ARexxContext *context,
																			register __a2 UBYTE *stemname,
																			register __a0 UBYTE **vars);

/*** PROTOTYPES FOR TAGCALLS *********************************************************/
struct ARexxContext *AllocARexxContext(Tag tag1, ...);
LONG SendARexxCommand(UBYTE *command, Tag tag1, ...);
void ReplyARexxMsg(struct ARexxContext *context, Tag tag1, ...);

/*** PROTOTYPES FOR TAGCALLS V2.0 ****************************************************/
BYTE ARexxCommandShell(struct ARexxContext *context, Tag tag1, ...);

/*** PROTOTYPES FOR TAGCALLS V3.0 ****************************************************/
ARexxMacro AllocARexxMacro(Tag tag1, ...);
void AddARexxMacroCommand(ARexxMacro macro, Tag tag1, ...);
BYTE RunARexxMacro(struct ARexxContext *context, Tag tag1, ...);
UBYTE WriteARexxMacro(struct ARexxContext *context, ARexxMacro macro, UBYTE *macroname, Tag tag1, ...);
BYTE CreateARexxStem(struct ARexxContext *context, UBYTE *stemname, UBYTE *vars, ...);

#endif

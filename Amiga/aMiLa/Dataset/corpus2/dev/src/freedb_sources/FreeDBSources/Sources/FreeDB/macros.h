#ifndef _MACROS_H
#define _MACROS_H

/****************************************************************************/
/*
** Usefull macros
*/

#ifndef SAVEDS
#define SAVEDS __saveds
#endif /* SAVEDS */

#ifndef ASM
#define ASM __asm
#endif /* ASM */

#ifndef REGARGS
#define REGARGS __regargs
#endif /* REGARGS */

#ifndef INLINE
#define INLINE __inline
#endif /* INLINE */

#ifndef REG
#define REG(x) register __ ## x
#endif /* REG */

#ifndef NODE
#define NODE(a) ((struct Node *)(a))
#endif /* NODE */

#ifndef MINNODE
#define MINNODE(a) ((struct MinNode *)(a))
#endif /* MINNODE */

#ifndef LIST
#define LIST(a) ((struct List *)(a))
#endif /* LIST */

#ifndef MINLIST
#define MINLIST(a) ((struct MinList *)(a))
#endif /* MINLIST */

#ifndef MESSAGE
#define MESSAGE(m) ((struct Message *)(m))
#endif /* MESSAGE */

#ifndef REQ
#define REQ(io) ((struct IORequest*)(io))
#endif /* REQ */

#ifndef NEWLIST
#define NEWLIST(l) (LIST(l)->lh_Head = NODE(&LIST(l)->lh_Tail), \
                    LIST(l)->lh_Tail = NULL, \
                    LIST(l)->lh_TailPred = NODE(&LIST(l)->lh_Head))
#endif /* NEWLIST */

#ifndef INITPORT
#define INITPORT(p,s) ((p)->mp_Flags = PA_SIGNAL, \
                       (p)->mp_SigBit = (UBYTE)(s), \
                       (p)->mp_SigTask = FindTask(NULL), \
                       NEWLIST(&((p)->mp_MsgList)))
#endif /* INITPORT */

#ifndef INITMESSAGE
#define INITMESSAGE(m,p,l) (MESSAGE(m)->mn_Node.ln_Type = NT_MESSAGE, \
                            MESSAGE(m)->mn_ReplyPort = (p), \
                            MESSAGE(m)->mn_Length = (l))
#endif /* INITMESSAGE */

#ifndef MAKE_ID
#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif /* MAKE_ID */

/****************************************************************************/

#endif /* _MACROS_H */

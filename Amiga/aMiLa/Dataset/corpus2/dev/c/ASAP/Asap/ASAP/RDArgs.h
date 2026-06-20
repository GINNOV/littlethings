/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARDArgs wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ARDArgs_H
#define ASAP_ARDArgs_H

#include <New.h>

extern "C"
{
 #include <Proto/DOS.h>
}

class ARDArgs : public RDArgs
{
 public:
 inline void FreeArgs();
 inline void operator delete(void *);
 inline static ARDArgs * ReadArgs(STRPTR arg_template, LONG * array, RDArgs * args = NULL);
 inline void * operator new(size_t, STRPTR arg_template, LONG * array, RDArgs * args = NULL);
};
//----------------------------------------------------------------------------
void ARDArgs::FreeArgs ()
{
 ::FreeArgs(this);
}
//----------------------------------------------------------------------------
void ARDArgs::operator delete(void *rdargs)
{
 ((ARDArgs *) rdargs)->FreeArgs();
}
//----------------------------------------------------------------------------
ARDArgs * ARDArgs::ReadArgs (STRPTR arg_template, LONG * array, RDArgs * args)
{
 return (ARDArgs *) ::ReadArgs(arg_template, array, args);
}
//----------------------------------------------------------------------------
void * ARDArgs::operator new(size_t, STRPTR arg_template, LONG * array, RDArgs * args)
{
 return ARDArgs::ReadArgs(arg_template, array, args);
}

#endif

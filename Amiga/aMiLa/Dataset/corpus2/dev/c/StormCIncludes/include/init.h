#ifndef _INIT_H
#define _INIT_H

#ifndef __GNUC__
you loose !
#endif

/*
 * support macros to declare and reference functions, that are automatically
 * called at init/finish time. This only works with gnu-ld, and is 
 * implemented with those SET_.. symbols
 */

#define DEF_INIT_FUNC(fname) \
	asm(".stabs \"___init_vector\", 22,0,0,_" #fname)
#define REF_INIT_FUNC(fname) asm(".globl _" #fname)
#define DEF_FINISH_FUNC(fname) \
	asm(".stabs \"___finish_vector\", 22,0,0,_" #fname)
#define REF_FINISH_FUNC(fname) asm(".globl _" #fname)

#endif /* _INIT_H */

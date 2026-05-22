
/*
 * Portable Object Compiler - PreLink Source File
 * (c) 1997 David Stes. All rights reserved.
 *
 * Just a dummy file with the symbols that "postlink"
 * is going to define.  The driver will link (a compiled version of)
 * this file into the program, for a first link.
 *
 * NOTE:
 *	This only applies to compiling with the -postlink option.
 *	By default, on UNIX K&R C compilers, postlink is not used, 
 *	and objcrt uses "auto-initialization code", which
 *	determines at run-time what classes are linked into the program.
 */

char *_objcModules = 0;


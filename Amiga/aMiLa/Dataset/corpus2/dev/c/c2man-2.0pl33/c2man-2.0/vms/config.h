/*
 * This file was produced by running the config_h.SH script, which
 * gets its values from config.sh, which is generally produced by
 * running Configure.
 *
 * Feel free to modify any of this as the need arises.  Note, however,
 * that running config.h.SH again will wipe out any changes you've made.
 * For a more permanent change edit config.sh and rerun config.h.SH.
 *
 * $Id: config.h,v 2.0.1.1 1994/05/19 01:10:45 greyham Exp $
 */

/* Configuration time: Tue Apr 26 09:56:37 PDT 1994
 * Configured by: flower
 * Target system: sunos flower 4.1.3 3 sun4 
 */

#ifndef _config_h_
#define _config_h_

#ifdef VMS
/*
 * Access call.  Also maintained in unistd.h
 */
#define F_OK            0       /* does file exist */
#define X_OK            1       /* is it executable by caller */
#define W_OK            2       /* writable by caller */
#define R_OK            4       /* readable by caller */

/* VMS does not have unlink() */
#define unlink(s)	delete(s)
#endif

/* BSD:
 *	This symbol, if defined, indicates that the program is running under
 *	a BSD system.
 */
/*#define BSD		*/

/* CPP_FILE_COM:
 *	This symbol contains the first part of the string which will invoke
 *	the C preprocessor a file and produce to standard output, preserving
 *	comments. Typical value of "cc -E -C" or "/lib/cpp -C".
 */
/* CPP_STDIN_FLAGS:
 *	This variable contains any flags necessary to get CPP_FILE_COM to
 *	read from the standard input.
 */
/* CPP_IGN_HDRS:
 *	This symbol is defined if CPP_FILE_COM ignores *.h files.
 */
/* CPP_CAN_STDIN:
 *	This symbol is defined if CPP_FILE_COM can read standard input
 *	directly.
 */
#define CPP_FILE_COM "cpp -\"C\""
#define CPP_STDIN_FLAGS "\"-\""
/*#define CPP_IGN_HDRS	*/	/* does CPP ignore .h files? */
#define CPP_CAN_STDIN 	        /* can CPP read stdin directly? */

/* HAS_ACCESS:
 *	This manifest constant lets the C program know that the access()
 *	system call is available to check for accessibility using real UID/GID.
 *	(always present on UNIX.)
 */
#define HAS_ACCESS		/**/

/* HASCONST:
 *	This symbol, if defined, indicates that this C compiler knows about
 *	the const type. There is no need to actually test for that symbol
 *	within your programs. The mere use of the "const" keyword will
 *	trigger the necessary tests.
 */
#define HASCONST	/**/
#ifndef HASCONST
#define const
#endif

/* FLEXFILENAMES:
 *	This symbol, if defined, indicates that the system supports filenames
 *	longer than 14 characters.
 */
#define	FLEXFILENAMES		/**/

/* HAS_LINK:
 *	This symbol, if defined, indicates that the link routine is
 *	available to create hard links.
 */
/*#define HAS_LINK	*/

/* HAS_OPEN3:
 *	This manifest constant lets the C program know that the three
 *	argument form of open(2) is available.
 */
#define HAS_OPEN3		/**/

/* HAS_STRCHR:
 *	This symbol is defined to indicate that the strchr()/strrchr()
 *	functions are available for string searching. If not, try the
 *	index()/rindex() pair.
 */
/* HAS_INDEX:
 *	This symbol is defined to indicate that the index()/rindex()
 *	functions are available for string searching.
 */
#define HAS_STRCHR	/**/
/*#define HAS_INDEX	/**/

/* HAS_STRFTIME:
 *	This symbol, if defined, indicates that the strftime routine is
 *	available to format locale-specific times.
 */
/*#define HAS_STRFTIME	*/

/* HAS_STRSTR:
 *	This symbol, if defined, indicates that the strstr routine is
 *	available to find substrings.
 */
#define HAS_STRSTR	/**/

/* HAS_SYMLINK:
 *	This symbol, if defined, indicates that the symlink routine is available
 *	to create symbolic links.
 */
/*#define HAS_SYMLINK	*/

/* Time_t:
 *	This symbol holds the type returned by time(). It can be long,
 *	or time_t on BSD sites (in which case <sys/types.h> should be
 *	included).
 */
#define Time_t long		/* Time type */

/* Signal_t:
 *	This symbol's value is either "void" or "int", corresponding to the
 *	appropriate return type of a signal handler.  Thus, you can declare
 *	a signal handler using "Signal_t (*handler)()", and define the
 *	handler using "Signal_t handler(sig)".
 */
#define Signal_t void	/* Signal handler's return type */

/* HASVOLATILE:
 *	This symbol, if defined, indicates that this C compiler knows about
 *	the volatile declaration.
 */
/*#define	HASVOLATILE	*/
#ifndef HASVOLATILE
#define volatile
#endif

/* I_FCNTL:
 *	This manifest constant tells the C program to include <fcntl.h>.
 */
/*#define I_FCNTL	/**/

/* I_STDARG:
 *	This symbol, if defined, indicates that <stdarg.h> exists and should
 *	be included.
 */
#define I_STDARG		/**/

/* I_STDDEF:
 *	This symbol, if defined, indicates that <stddef.h> exists and should
 *	be included.
 */
#define I_STDDEF	/**/

/* I_STDLIB:
 *	This symbol, if defined, indicates that <stdlib.h> exists and should
 *	be included.
 */
#define I_STDLIB		/**/

/* I_STRING:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <string.h> (USG systems) instead of <strings.h> (BSD systems).
 */
#define I_STRING		/**/

/* I_SYS_FILE:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <sys/file.h> to get definition of R_OK and friends.
 */
#define I_SYS_FILE		/**/

/* I_SYS_TYPES:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <sys/types.h>.
 */
/*#define	I_SYS_TYPES		*/

/* I_TIME:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <time.h>.
 */
/* I_SYS_TIME:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <sys/time.h>.
 */
#define I_TIME		/**/
/*#define I_SYS_TIME		*/

/* I_UNISTD:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <unistd.h>.
 */
/*#define I_UNISTD		*/

/* I_VARARGS:
 *	This symbol, if defined, indicates to the C program that it should
 *	include <varargs.h>.
 */
/*#define I_VARARGS		*/

/* CAN_PROTOTYPE:
 *	If defined, this macro indicates that the C compiler can handle
 *	function prototypes.
 */
/* DOTS:
 *	This macro is used to specify the ... in function prototypes which
 *	have arbitrary additional arguments.
 */
/* NXT_ARG:
 *	This macro is used to separate arguments in the declared argument list.
 */
/* P_FUNC:
 *	This macro is used to declare "private" (static) functions.
 *	It takes three arguments: the function type and name, a parenthesized
 *	traditional (comma separated) argument list, and the declared argument
 *	list (in which arguments are separated with NXT_ARG, and additional
 *	arbitrary arguments are specified with DOTS).  For example:
 *
 *		P_FUNC(int foo, (bar, baz), int bar NXT_ARG char *baz[])
 */
/* P_FUNC_VOID:
 *	This macro is used to declare "private" (static) functions that have
 *	no arguments.  The macro takes one argument: the function type and name.
 *	For example:
 *
 *		P_FUNC_VOID(int subr)
 */
/* V_FUNC:
 *	This macro is used to declare "public" (non-static) functions.
 *	It takes three arguments: the function type and name, a parenthesized
 *	traditional (comma separated) argument list, and the declared argument
 *	list (in which arguments are separated with NXT_ARG, and additional
 *	arbitrary arguments are specified with DOTS).  For example:
 *
 *		V_FUNC(int main, (argc, argv), int argc NXT_ARG char *argv[])
 */
/* V_FUNC_VOID:
 *	This macro is used to declare "public" (non-static) functions that have
 *	no arguments.  The macro takes one argument: the function type and name.
 *	For example:
 *
 *		V_FUNC_VOID(int fork)
 */
/* _:
 *	This macro is used to declare function parameters for folks who want
 *	to make declarations with prototypes using a different style than
 *	the above macros.  Use double parentheses.  For example:
 *
 *		int main _((int argc, char *argv[]));
 */
#define	CAN_PROTOTYPE	/**/
#ifdef CAN_PROTOTYPE
#define	NXT_ARG ,
#define	DOTS , ...
#define	V_FUNC(name, arglist, args)name(args)
#define	P_FUNC(name, arglist, args)static name(args)
#define	V_FUNC_VOID(name)name(void)
#define	P_FUNC_VOID(name)static name(void)
#define	_(args) args
#else
#define	NXT_ARG ;
#define	DOTS
#define	V_FUNC(name, arglist, args)name arglist args;
#define	P_FUNC(name, arglist, args)static name arglist args;
#define	V_FUNC_VOID(name)name()
#define	P_FUNC_VOID(name)static name()
#define	_(args) ()
#endif

/* CAN_VAPROTO:
 *	This variable is defined on systems supporting prototype declaration
 *	of functions with a variable number of arguments.
 */
/* _V:
 *	This macro is used to declare function parameters in prototypes for
 *	functions with a variable number of parameters. Use double parentheses.
 *	For example:
 *
 *		int printf _V((char *fmt, ...));
 *
 *	Remember to use the plain simple _() macro when declaring a function
 *	with no variable number of arguments, since it might be possible to
 *	have a non-effect _V() macro and still get prototypes via _().
 */
#define CAN_VAPROTO	/**/
#ifdef CAN_VAPROTO
#define	_V(args) args
#else
#define	_V(args) ()
#endif

/* VOIDFLAGS:
 *	This symbol indicates how much support of the void type is given by this
 *	compiler.  What various bits mean:
 *
 *	    1 = supports declaration of void
 *	    2 = supports arrays of pointers to functions returning void
 *	    4 = supports comparisons between pointers to void functions and
 *		    addresses of void functions
 *	    8 = suports declaration of generic void pointers
 *
 *	The package designer should define VOIDUSED to indicate the requirements
 *	of the package.  This can be done either by #defining VOIDUSED before
 *	including config.h, or by defining defvoidused in Myinit.U.  If the
 *	latter approach is taken, only those flags will be tested.  If the
 *	level of void support necessary is not present, defines void to int.
 */
#ifndef VOIDUSED
#define VOIDUSED 9
#endif
#define VOIDFLAGS 9
#if (VOIDFLAGS & VOIDUSED) != VOIDUSED
#define void int		/* is void to be avoided? */
#define M_VOID			/* Xenix strikes again */
#endif

#endif

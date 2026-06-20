/*
 *   cc.c   Unix compatible frontend for Amiga's C compilers
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *
 *   Compiler:  dcc V3.01
 *
 *   Computer:  Amiga 1200
 *
 *   Author:    Jochen Wiedmann
 *              Am Eisteich 9
 *              72555 Metzingen
 *              Germany
 *
 *              Phone: (49)7123 / 14881
 *              Internet: wiedmann@zdv.uni-tuebingen.de
 *
 *   Modifications and bug fixes:
 *              Enrico Forestieri 25-Ago-95
 *              e-mail: enrico@com.unipr.it
 *
 *
 *   This is a Unix compatible frontend for gcc, SAS/C and Dice. In fact,
 *   it does nothing than else than calling the appropriate frontends
 *   with the appropriate options.
 *
 *   Supported options are:
 *
 *      -v          Verbose
 *      -V          Much more verbose (try it :-)
 *      -w          No warning messages
 *      -c          Don't link
 *      -a          Compile only, don't assemble
 *      -E          Run preprocessor only
 *      -I<dir>     Look for include files in directory <dir>
 *      -L<dir>     Look for libraries in directory <dir>
 *      -o<file>    Set the name of the created file; it is recommended
 *                  to use this as the respective frontends might behave
 *                  differently in selecting default names.
 *      -D<symbol>  Defines preprocessor symbol; use -Dsymbol=var for
 *                  specific values.
 *      -U<symbol>  Undefine the preprocessor symbol <symbol>.
 *      -l<lib>     Link with library <lib>.
 *      -g          Turn debugging on.
 *      -O          Optimize
 *
 */

/*
 *   Version string
 */
#define VSTRING "cc 1.2 (25.8.95)"
#define VERSTAG "\0$VER: "VSTRING

char Version[] = VSTRING;
char AmigaVersion[] = VERSTAG;


/*
 *   Include files
 */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <exec/lists.h>
#include <exec/nodes.h>
#include <clib/alib_protos.h>
#include <proto/exec.h>
#include <proto/dos.h>

char *program;

#define EMPTYLIST(list) (list.mlh_Head == (struct MinNode *)&list.mlh_Tail)
typedef struct List     LIST;
typedef struct Node     NODE;
typedef struct MinList  MLIST;
typedef struct MinNode  MNODE;


/*
 *   List of options processed by cc:
 */
typedef enum {
    OPTION_UNKNOWN,
    OPTION_VERBOSE,
    OPTION_VERY_VERBOSE,
    OPTION_DEFINE,
    OPTION_UNDEFINE,
    OPTION_PREPROCESSOR_ONLY,
    OPTION_ASSEMBLER_ONLY,
    OPTION_NOLINK,
    OPTION_INCLUDEDIR,
    OPTION_LINKDIR,
    OPTION_OPTIMIZE,
    OPTION_DEBUGGING,
    OPTION_LIBRARY,
    OPTION_OUTPUT,
    OPTION_NOWARN
} CompilerOption;


/*
 *   This structure defines an element in the list of options.
 */
typedef struct {
    MNODE mn;
    CompilerOption Option;
    char *Arg;
} CurrentOption;

/*
 *   Compatibility mode (Default: gcc if named cc, or sas if named scc)
 */
enum {
    COMPATIBILITYMODE_GCC,
    COMPATIBILITYMODE_SAS,
    COMPATIBILITYMODE_DICE,
} CompatibilityMode = COMPATIBILITYMODE_GCC;

char *CompatibilityModeNames[] =
{
    "-gcc",
    "-sas",
    "-dice"
};


/*
 *   Compiler mode (Default: Everything)
 */
enum {
    COMPILERMODE_PREPROCESSOR_ONLY,
    COMPILERMODE_COMPILER_ONLY,
    COMPILERMODE_ASSEMBLER_ONLY,
    COMPILERMODE_EVERYTHING,
} CompilerMode = COMPILERMODE_EVERYTHING;

char *CompilerModeNames[] =
{
    "-E",
    "-a",
    "-c"
};


/*
 *   This list is used to hold the current options.
 */
MLIST OptionList;


/*
 *   This list is used to hold the link path (used for SAS/C).
 */

MLIST LinkDirList;


/*
 *   Guess, what this function does? :-)
 */

void Usage(void)
{
    PutStr("\nUsage: ");
    PutStr(program);
    PutStr(" [options] [files]\n\
\n\
Where options are:\n\
\n\
-gcc\trun as a front end of gcc (default if named cc)\n\
-sas\trun as a frontend of SAS/C (default if named scc)\n\
-dice\trun as a frontend of Dice\n\
\n\
-v\t\tbe verbose\n\
-w\t\tno warning messages\n\
-o<file>\tsend output to <file>\n\
-E\t\tstop after preprocessing, don't compile\n\
-a\t\tstop after compilation, don't assemble\n\
-c\t\tcompile or assemble, but don't link\n\
-I<dir>\t\tscan <dir> for include files\n\
-L<dir>\t\tscan <dir> for link libraries\n\
-l<lib>\t\tlink with library <lib>\n\
-g\t\tproduce debugging information\n\
-O\t\tturn optimization on\n\
-D<sym>\t\tdefine preprocessor symbol\n\
-U<sym>\t\tundefine preprocessor symbol\n\
-h,--help,?\tprint this message\n\
\n\
Everything else is bindly passed\n\
\n");
    exit(5);
}


/*
 *   This function adds a new element to the link path (used for SAS/C).
 */

void AddLinkDir(char *dir)
{
    NODE *node = malloc(sizeof(NODE));

    if (!node) {
	PutStr(program);
	PutStr(": out of memory!\n");
	exit(20);
    }
    AddTail((LIST *)&LinkDirList, node);
    node->ln_Name = dir;
}


/*
 *   This function adds a new option to the list of options.
 */

void AddOption(CompilerOption co, char *arg)
{
    CurrentOption *cu;

    if (!(cu = malloc(sizeof(*cu)))) {
	PutStr(program);
	PutStr(": out of memory!\n");
	exit(20);
    }
    cu->Option = co;
    cu->Arg = arg;
    AddTail((LIST *)&OptionList, (NODE *)cu);
    if (co == OPTION_LINKDIR)
	AddLinkDir(arg);
}


/*
 *   This function handles options which may be splitted into two
 *   arguments or not, like -I <dir> or -I<dir>.
 */

void AddOptionArg(CompilerOption co,
		  int *i,
		  int argc,
		  char *argv[])
{
    char *arg = &argv[*i][2];

    if (!*arg) {
	if (++(*i) >= argc) {
	    PutStr(program);
	    PutStr(": missing argument for ");
	    PutStr(argv[--(*i)]);
	    PutStr("\n");
	    exit(20);
	}
	arg = argv[*i];
    }
    AddOption(co, arg);
}


/*
 *   This function is used to set the compatibility mode.
 */

void SetCompatibilityMode(int mode, int *set)
{
    if (*set) {
	PutStr(program);
	PutStr(": error: ");
	PutStr(CompatibilityModeNames[mode]);
	PutStr(" overwrites ");
	PutStr(CompatibilityModeNames[CompatibilityMode]);
	PutStr("\n");
	exit(10);
    }
    *set = TRUE;
    CompatibilityMode = mode;
}


/*
 *   This function is used to set the compiler mode.
 */

void SetCompilerMode(int mode, int *set)
{
    if (*set) {
	PutStr(program);
	PutStr(": error: ");
	PutStr(CompilerModeNames[mode]);
	PutStr(" overwrites ");
	PutStr(CompilerModeNames[CompilerMode]);
	PutStr("\n");
	exit(10);
    }
    *set = TRUE;
    CompilerMode = mode;
}


/*
 *   This function finds the library in the link path and returns
 *   its full path name (used for SAS/C).
 */

char *
LibPath(char *libname, char *buffer)
{
    int  i;
    char c;
    long lock;
    NODE *node;

    for (node = (NODE *)LinkDirList.mlh_Head;
	 node->ln_Succ != NULL;
	 node = node->ln_Succ) {

	strcpy(buffer, node->ln_Name);
	if ((i = strlen(buffer)) != 0) {
	    c = buffer[i-1];
	    if (c != ':' && c != '/') {
		buffer[i++] = '/';
		buffer[i] = 0;
	    }
	}
	strcat(buffer, libname);
	strcat(buffer, ".lib");
	if ((lock = Lock(buffer, SHARED_LOCK)) != NULL) {
	    UnLock(lock);
	    break;
	}
    }
    return(buffer);
}

/*
 *   This function will be called by RawDoFmt() to output a char to a buffer.
 *   The char is passed in register d0, the address of the pointer to the
 *   buffer in register a3.
 */

void __asm putch(register __d0 char ch, register __a3 char **outbuf)
{
    *(*outbuf)++ = ch;
}


/*
 *   This function is used to build the string that is used to call
 *   the real frontend. It supports strings of any length, thus it
 *   may look somewhat complicated.
 */

void AddToString(char **strptr, char *format, char *data)
{
    static char buffer[256];   /*  Maximal length of *one* argument    */
    static int RealLen;
    static int MaxLen;
    int len;
    char *bufptr = buffer;

    RawDoFmt(format, &data, putch, &bufptr);
    len = strlen(buffer);

    if (!*strptr) {
	MaxLen = 0;
    }
    if (len + RealLen + 1 > MaxLen) {
	/*
	 *   Current buffer not sufficient, allocate a new buffer
	 */
	char *newstr;

	if (!(newstr = malloc(MaxLen + 1024))) {
	    PutStr(program);
	    PutStr(": out of memory!\n");
	    exit(20);
	}
	MaxLen += 1024;

	if (*strptr) {
	    strcpy(newstr, *strptr);
	} else {
	    *newstr = '\0';
	    RealLen = 0;
	}
	*strptr = newstr;
    }
    strcpy(*strptr + RealLen, buffer);
    RealLen += len;
}


/*
 *   This function is used to parse the arguments. Options will
 *   be included into OptionList, -L paths in LinkDirList.
 */

void ParseArgs(int argc,
	       char *argv[])
{
    int i;
    /*
     *   These variables are used for checking if arguments repeat.
     *   Note that we keep them local: This allows, for example,
     *   to use different settings in the environment and on the
     *   command line.
     */
    int CompatibilityModeIsSet = FALSE;
    int CompilerModeIsSet = FALSE;

    for (i = 0; i < argc; i++) {
	char *argvi = argv[i];

	if (argvi[0] == '-') {
	    /*
	     *   Assume this to be a compiler option.
	     */

	    switch (argvi[1]) {
		case '-':
		    if (strcmp(argvi, "--help") == 0) {
			Usage();
		    }
		    AddOption(OPTION_UNKNOWN, argvi);
		    break;
		case 'D':
		    AddOptionArg(OPTION_DEFINE, &i, argc, argv);
		    break;
		case 'E':
		    switch (argvi[2]) {
			case '\0':
			    SetCompilerMode(COMPILERMODE_PREPROCESSOR_ONLY,
					    &CompilerModeIsSet);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'I':
		    AddOptionArg(OPTION_INCLUDEDIR, &i, argc, argv);
		    break;
		case 'L':
		    /* current dir is the first in link path */
		    if (EMPTYLIST(LinkDirList))
			AddLinkDir("");
		    AddOptionArg(OPTION_LINKDIR, &i, argc, argv);
		    break;
		case 'O':
		    AddOption(OPTION_OPTIMIZE, &argvi[2]);
		    break;
		case 'U':
		    AddOptionArg(OPTION_UNDEFINE, &i, argc, argv);
		    break;
		case 'V':
		    switch (argvi[2]) {
			case '\0':
			    AddOption(OPTION_VERY_VERBOSE, argvi);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'a':
		    switch (argvi[2]) {
			case '\0':
			    SetCompilerMode(COMPILERMODE_COMPILER_ONLY,
					    &CompilerModeIsSet);
			    AddOption(OPTION_ASSEMBLER_ONLY, argvi);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'c':
		    switch (argvi[2]) {
			case '\0':
			    SetCompilerMode(COMPILERMODE_ASSEMBLER_ONLY,
					    &CompilerModeIsSet);
			    AddOption(OPTION_NOLINK, argvi);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'd':
		    if (strcmp(argvi,
			       CompatibilityModeNames[COMPATIBILITYMODE_DICE]) == 0) {
			SetCompatibilityMode(COMPATIBILITYMODE_DICE,
					     &CompatibilityModeIsSet);
		    } else {
			AddOption(OPTION_UNKNOWN, argvi);
		    }
		    break;
		case 'g':
		    switch (argvi[2]) {
			case '\0':
			    AddOption(OPTION_DEBUGGING, argvi);
			    break;
			default:
			    if (strcmp(argvi,
				       CompatibilityModeNames[COMPATIBILITYMODE_GCC]) == 0) {
				SetCompatibilityMode(COMPATIBILITYMODE_GCC,
						&CompatibilityModeIsSet);
			    } else {
				AddOption(OPTION_UNKNOWN, argvi);
			    }
			    break;
		    }
		    break;
		case 'h':
		    switch (argvi[2]) {
			case '\0':
			    Usage();
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'l':
		    /* current dir is the first in link path */
		    if (EMPTYLIST(LinkDirList))
			AddLinkDir("");
		    AddOptionArg(OPTION_LIBRARY, &i, argc, argv);
		    break;
		case 'o':
		    AddOptionArg(OPTION_OUTPUT, &i, argc, argv);
		    break;
		case 's':
		    if (strcmp(argvi,
		    CompatibilityModeNames[COMPATIBILITYMODE_SAS]) == 0) {
			SetCompatibilityMode(COMPATIBILITYMODE_SAS,
					     &CompatibilityModeIsSet);
		    } else {
			AddOption(OPTION_UNKNOWN, argvi);
		    }
		    break;
		case 'v':
		    switch (argvi[2]) {
			case '\0':
			    AddOption(OPTION_VERBOSE, argvi);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		case 'w':
		    switch (argvi[2]) {
			case '\0':
			    AddOption(OPTION_NOWARN, argvi);
			    break;
			default:
			    AddOption(OPTION_UNKNOWN, argvi);
			    break;
		    }
		    break;
		default:
		    AddOption(OPTION_UNKNOWN, argvi);
		    break;
	    }
	} else if (strcmp(argvi, "?") == 0) {
	    Usage();
	} else {
	    AddOption(OPTION_UNKNOWN, argvi);
	}
    }
}


/*
 *   This function calls gcc as a frontend.
 */

int CompileGcc(void)
{
    CurrentOption *co;
    char *ptr, *CompileString = NULL;
    int Verbose = FALSE;

    AddToString(&CompileString, "gcc", NULL);

    for (co = (CurrentOption *) OptionList.mlh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ) {

	switch (co->Option) {
	    case OPTION_UNKNOWN:
		AddToString(&CompileString, " %s", co->Arg);
		break;
	    case OPTION_VERY_VERBOSE:
		AddToString(&CompileString, " -v", NULL);
	    case OPTION_VERBOSE:
		Verbose = TRUE;
		break;
	    case OPTION_NOWARN:
		AddToString(&CompileString, " -w", NULL);
		break;
	    case OPTION_DEFINE:
		AddToString(&CompileString, " -D%s", co->Arg);
		break;
	    case OPTION_UNDEFINE:
		AddToString(&CompileString, " -U%s", co->Arg);
		break;
	    case OPTION_PREPROCESSOR_ONLY:
		AddToString(&CompileString, " -E", NULL);
		break;
	    case OPTION_ASSEMBLER_ONLY:
		AddToString(&CompileString, " -S", NULL);
		break;
	    case OPTION_NOLINK:
		AddToString(&CompileString, " -c", NULL);
		break;
	    case OPTION_INCLUDEDIR:
		AddToString(&CompileString, " -I%s", co->Arg);
		break;
	    case OPTION_LINKDIR:
		AddToString(&CompileString, " -L%s", co->Arg);
		break;
	    case OPTION_OPTIMIZE:
		AddToString(&CompileString, " -O%s", co->Arg);
		break;
	    case OPTION_DEBUGGING:
		AddToString(&CompileString, " -g", NULL);
		break;
	    case OPTION_LIBRARY:
		AddToString(&CompileString, " -l%s", co->Arg);
		break;
	    case OPTION_OUTPUT:
		AddToString(&CompileString, " -o %s", co->Arg);
		break;
	}
    }

    AddToString(&CompileString, "\n", NULL);
    /* We are calling gcc, so let's use the right escape character ... */
    for (ptr = CompileString; (ptr = strstr(ptr, "*\"")) != NULL; ++ptr)
	*ptr = '\\';
    if (Verbose) {
	PutStr(Version);
	PutStr("\n");
	PutStr(CompileString);
    }
    return(system(CompileString));
}

/*
 *   This function checks for the "math" option the files
 *   SCOPTIONS in the current directory and ENV:sc/scoptions
 */

int CheckSASopt(void)
{
    BPTR lock, fh;
    LONG ch;
    int state = 1;

    if (!(lock = Lock("SCOPTIONS", ACCESS_READ)))
	lock = Lock("ENV:sc/scoptions", ACCESS_READ);

    if (!lock)
    	return FALSE;

    if (!(fh = OpenFromLock(lock))) {
    	UnLock(lock);
	return FALSE;
    }

    while ((ch = FGetC(fh)) != -1) {
	switch (toupper(ch)) {
	    case ' ':
	    case '\t':
	    case '\n':
		if (state == 5) {
		    Close(fh);
		    return TRUE;
		}
		state = 1;
		break;
	    case 'M':
		if (state == 1) state = 2;
		else state = 0;
		break;
	    case 'A':
		if (state == 2) state = 3;
		else state = 0;
		break;
	    case 'T':
		if (state == 3) state = 4;
		else state = 0;
		break;
	    case 'H':
		if (state == 4) state = 5;
		else state = 0;
		break;
	    case '=':
		if (state == 5) {
		    Close(fh);
		    return TRUE;
		}
	    default:
		state = 0;
		break;
	}
    }

    Close(fh);
    return FALSE;
}

/*
 *   This function calls SAS/C as a frontend.
 */

int CompileSAS(void)
{
    CurrentOption *co;
    char *ptr, *CompileString = NULL;
    int Verbose = FALSE;
    char *OptionOutput = NULL;
    int Math = CheckSASopt();

    AddToString(&CompileString, "sc nover noicons", NULL);

    for (co = (CurrentOption *) OptionList.mlh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ) {

	switch (co->Option) {
	    case OPTION_UNKNOWN:
		AddToString(&CompileString, " %s", co->Arg);
		if (stricmp(co->Arg, "resetoptions") == 0
		       || stricmp(co->Arg, "resopt") == 0)
		    Math = FALSE;
		if (strnicmp(co->Arg, "math", 4) == 0) {
		    if (Math) {
		    	PutStr(program);
			PutStr(": warning: math option specified more than once\n");
		    }
		    Math = TRUE;
		}
		break;
	    case OPTION_VERY_VERBOSE:
		AddToString(&CompileString, " verbose", NULL);
	    case OPTION_VERBOSE:
		Verbose = TRUE;
		break;
	    case OPTION_NOWARN:
		AddToString(&CompileString, " ign=a", NULL);
		break;
	    case OPTION_DEFINE:
		AddToString(&CompileString, " def %s", co->Arg);
		break;
	    case OPTION_UNDEFINE:       /*  Not supported   */
		PutStr(program);
		PutStr(": warning: option -U not supported by SAS/C, ignored\n");
		break;
	    case OPTION_INCLUDEDIR:
		AddToString(&CompileString, " idir=%s", co->Arg);
		break;
	    case OPTION_LINKDIR:        /*  Is treated specially for SAS/C  */
		break;
	    case OPTION_OPTIMIZE:
		AddToString(&CompileString, " opt", NULL);
		break;
	    case OPTION_DEBUGGING:
		AddToString(&CompileString, " dbg=ff", NULL);
		break;
	    case OPTION_LIBRARY:
		if (strcmp(co->Arg, "m") == 0) {
		    if (!Math)
		    	AddToString(&CompileString, " math=s", NULL);
		    Math = TRUE;
		} else {
		    char buffer[256];
		    AddToString(&CompileString, " lib=%s",
				LibPath(co->Arg, buffer));
		}
		break;
	    case OPTION_OUTPUT:
		OptionOutput = co->Arg;
		break;
	}
    }

    switch (CompilerMode) {
	case COMPILERMODE_PREPROCESSOR_ONLY:
	    AddToString(&CompileString, " pponly", NULL);
	    if (!OptionOutput) {
		OptionOutput = "console:*";
	    }
	case COMPILERMODE_ASSEMBLER_ONLY:
	    if (OptionOutput) {
		AddToString(&CompileString, " objname=%s", OptionOutput);
	    }
	    break;
	case COMPILERMODE_COMPILER_ONLY:
	    if (!OptionOutput) {
		OptionOutput = "console:";
	    }
	    AddToString(&CompileString, " disasm=%s", OptionOutput);
	    break;
	case COMPILERMODE_EVERYTHING:
	    if (OptionOutput) {
		AddToString(&CompileString, " pname=%s", OptionOutput);
	    }
	    AddToString(&CompileString, " link batch", NULL);
	    break;
    }

    AddToString(&CompileString, "\n", NULL);
    /* We are calling sc, and not enclosing arguments in double quotes, */
    /* so let's eliminate the escaping * to double quotes ...           */
    for (ptr = CompileString; (ptr = strstr(ptr, "*\"")) != NULL; ++ptr)
	memmove(ptr, ptr+1, strlen(ptr));
    if (Verbose) {
	PutStr(Version);
	PutStr("\n");
	PutStr(CompileString);
    }
    return(system(CompileString));
}


/*
 *   This function calls Dice as a frontend.
 */

int CompileDice(void)
{
    CurrentOption *co;
    char *ptr, *CompileString = NULL;
    int Verbose = FALSE;

    switch (CompilerMode) {
	case COMPILERMODE_PREPROCESSOR_ONLY:
	    AddToString(&CompileString, "dcpp", NULL);
	    break;
	case COMPILERMODE_COMPILER_ONLY:
	    AddToString(&CompileString, "dcc -a", NULL);
	    break;
	case COMPILERMODE_ASSEMBLER_ONLY:
	    AddToString(&CompileString, "dcc -c", NULL);
	    break;
	default:
	    AddToString(&CompileString, "dcc", NULL);
	    break;
    }

    for (co = (CurrentOption *) OptionList.mlh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ) {
	switch (co->Option) {
	    case OPTION_UNKNOWN:
		AddToString(&CompileString, " %s", co->Arg);
		break;
	    case OPTION_VERY_VERBOSE:
		if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY) {
		    AddToString(&CompileString, " -v", co->Arg);
		}
	    case OPTION_VERBOSE:
		Verbose = TRUE;
		break;
	    case OPTION_NOWARN:
		PutStr(program);
		PutStr(": warning: option -w not supported by DICE, ignored\n");
		break;
	    case OPTION_DEFINE:
		AddToString(&CompileString, " -D%s", co->Arg);
		break;
	    case OPTION_UNDEFINE:       /*  Not supported   */
		PutStr(program);
		PutStr(": warning: option -U not supported by DICE, ignored\n");
		break;
	    case OPTION_INCLUDEDIR:
		AddToString(&CompileString, " -I%s", co->Arg);
		break;
	    case OPTION_LINKDIR:
		if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY) {
		    AddToString(&CompileString, " -L%s", co->Arg);
		}
		break;
	    case OPTION_OPTIMIZE:       /*  Not suported    */
		PutStr(program);
		PutStr(": warning: option -O not supported by DICE, ignored\n");
		break;
	    case OPTION_DEBUGGING:
		if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY) {
		    AddToString(&CompileString, " -s -d1", NULL);
		}
		break;
	    case OPTION_LIBRARY:
		if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY) {
		    AddToString(&CompileString, " -l%s", co->Arg);
		}
		break;
	    case OPTION_OUTPUT:
		AddToString(&CompileString, " -o %s", co->Arg);
		break;
	}
    }

    AddToString(&CompileString, "\n", NULL);
    /* We are calling dcc, and not enclosing arguments in double quotes, */
    /* so let's eliminate the escaping * to double quotes ...            */
    for (ptr = CompileString; (ptr = strstr(ptr, "*\"")) != NULL; ++ptr)
	memmove(ptr, ptr+1, strlen(ptr));
    if (Verbose) {
	PutStr(Version);
	PutStr("\n");
	PutStr(CompileString);
    }
    return(system(CompileString));
}


/*
 *   This function is used to split a string into arguments.
 *   It returns an array similar to argv.
 *
 *   I don't like doing things for myself, but as far as I
 *   can see neither SAS nor Dice offer a possibility of
 *   doing this.
 *
 *   Inputs: argstr - the string to split into arguments,
 *              for example an AmigaDOS command line;
 *              may contain arguments like
 *                  "This is one argument"
 *              or
 *                  "Note the "" inside this argument"
 *              where the double quotation mark will be
 *              changed into one.
 *          argc - pointer to an int where to store the
 *              number of arguments found in argstr
 *
 *   Result: an NULL terminated array of pointers to the
 *          arguments or NULL; note that the pointers go
 *          into argstr and argstr will be modified.
 */

char **SplitArgs(char *argstr, int *argcptr)
{
    int argc;
    char *argptr;
    char **argv;
    char **argvptr;

    /*
     *   Parse the string for the first time counting
     *   the number of arguments.
     */
    argptr = argstr;
    argc = 0;
    for (;;) {
	/*
	 *   Skip blanks
	 */
	while (*argptr == ' ' || *argptr == '\t') {
	    ++argptr;
	}

	if (*argptr == '\0' || *argptr == '\n' || *argptr == '\r') {
	    break;
	}
	++argc;

	if (*argptr == '\"') {
	    do {
		++argptr;
		if (*argptr == '\"') {
		    if (*(argptr + 1) == '\"') {
			++argptr;
		    } else {
			break;
		    }
		}
	    }
	    while (*argptr != '\0' && *argptr != '\r' && *argptr != '\n');
	} else {
	    while (*argptr != '\0' && *argptr != '\r' && *argptr != '\n' &&
		   *argptr != '\t' && *argptr != ' ') {
		++argptr;
	    }
	}
	{
	    char c;

	    c = *argptr;
	    *(argptr++) = '\0';

	    if (c == '\0' || c == '\r' || c == '\n') {
		break;
	    }
	}
    }

    *argcptr = argc;
    if (!(argv = malloc(sizeof(char *) * (argc + 1)))) {
	return (NULL);
    }
    /*
     *   Parse the string a second time
     */
    for (argvptr = argv, argptr = argstr; argc > 0; --argc, ++argvptr) {
	int inside;

	while (*argptr == ' ' || *argptr == '\t') {
	    ++argptr;
	}

	if (*argptr == '\"') {
	    ++argptr;
	    inside = TRUE;
	} else {
	    inside = FALSE;
	}
	*argvptr = argptr;

	while (*argptr) {
	    if (*argptr == '\"' && inside) {
		char *ptr;
		char *oldptr;

		/*
		 *   Found a "", remove the second ".
		 */
		for (ptr = argptr++, oldptr = *argvptr;
		     ptr >= oldptr; --ptr) {
		    *(ptr + 1) = *ptr;
		}
		*argvptr = oldptr + 1;
	    }
	    ++argptr;
	}
	++argptr;
    }
    *argvptr = NULL;

    return (argv);
}


/*
 *   Finally main().
 */

int main(int argc, char *argv[])
{
    int  i, j, l1, l2;
    int  rc = 20;
    char *ptr;
    char *cflags;

    program = FilePart(argv[0]);

    /*
     *  Correct escaped double quote when called by GNU make
     */
    for (i=1, j=1; i+1<argc; i++, j++) {
	argv[j] = argv[i];
	l1 = strlen(argv[i])-1;
	l2 = strlen(argv[i+1])-1;
	if (argv[i][l1] == '\\' && argv[i+1][l2] == '\"') {
	    if ((ptr = strstr(argv[i+1], "\\\"")) && (ptr-argv[i+1]+1<l2)) {
		argv[i][l1] = *ptr = '*';
		memmove(argv[i+1]+1, argv[i+1], l2);
		argv[i+1][0] = '\"';
		if (!(ptr = (char *)malloc(l1+l2+3))) {
		    PutStr(program);
		    PutStr(": out of memory!\n");
		    exit(20);
		}
		strcpy(ptr, argv[i]);
		strcat(ptr, argv[i+1]);
		argv[j] = ptr;
		i++;
	    }
	}
    }
    if (i+1 == argc)
	argv[j++] = argv[i];
    argc = j;
    argv[argc] = NULL;

    NewList((LIST *)&OptionList);
    NewList((LIST *)&LinkDirList);

    /*
     * If the executable name is scc, call SAS/C compiler
     */
    if (strcmp(FilePart(argv[0]), "scc") == 0)
	CompatibilityMode = COMPATIBILITYMODE_SAS;

    if ((cflags = getenv("CCOPT"))) {
	int envargc;
	char **envargv;

	if (!(envargv = SplitArgs(cflags, &envargc))) {
	    PutStr(program);
	    PutStr(": out of memory!\n");
	    exit(20);
	}
	ParseArgs(envargc, envargv);
    }
    ParseArgs(argc - 1, argv + 1);

    switch (CompatibilityMode) {
	case COMPATIBILITYMODE_GCC:
	    rc = CompileGcc();
	    break;
	case COMPATIBILITYMODE_SAS:
	    if (!EMPTYLIST(LinkDirList))
		AddLinkDir("lib:");    /* add standard link dir last */
	    rc = CompileSAS();
	    break;
	case COMPATIBILITYMODE_DICE:
	    rc = CompileDice();
	    break;
    }

    return(rc);
}

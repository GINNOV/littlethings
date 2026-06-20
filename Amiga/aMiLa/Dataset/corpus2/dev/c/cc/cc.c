/**
***  cc.c   Unix compatible frontend for Amiga's C compilers
***
***  This program is free software; you can redistribute it and/or modify
***  it under the terms of the GNU General Public License as published by
***  the Free Software Foundation; either version 2 of the License, or
***  (at your option) any later version.
***
***  This program is distributed in the hope that it will be useful,
***  but WITHOUT ANY WARRANTY; without even the implied warranty of
***  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***  GNU General Public License for more details.
***
***  You should have received a copy of the GNU General Public License
***  along with this program; if not, write to the Free Software
***  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
***
***
***  Compiler:	dcc V3.01
***
***  Computer:	Amiga 1200
***
***  Author:	Jochen Wiedmann
***		Am Eisteich 9
***		72555 Metzingen
***		Germany
***
***		Phone: (49)7123 / 14881
***		Internet: wiedmann@zdv.uni-tuebingen.de
***
***
***
***  This is a Unix compatible frontend for gcc, SAS/C and Dice. In fact,
***  it does nothing than else than calling the appropriate frontends
***  with the appropriate options.
***
***  Supported options are:
***
***	-v	    Verbose (try it :-)
***	-c	    Don't link
***	-a	    Compile only, don't assemble
***	-E	    Run preprocessor only
***	-I<dir>     Look for include files in directory <dir>
***	-L<dir>     Look for libraries in directory <dir>
***	-o<file>    Set the name of the created file; it is recommended
***		    to use this as the respective frontends might behave
***		    different in selecting default names.
***	-D<symbol>  Defines preprocessor symbol; use -Dsymbol=var for
***		    specific values.
***	-U<symbol>  Undefine the preprocessor symbol <symbol>.
***	-l<lib>     Link with library <lib>.
***	-g	    Turn debugging on.
***	-O	    Optimize
***
**/

/**
***  Version string
**/
#define VERSION        1
#define REVISION	 1
#define DATE	"11.10.94"
#define VERS	"cc 1.1"
#define VSTRING "cc 1.1 (11.10.94)"
#define VERSTAG "\0$VER: cc 1.1 (11.10.94)"
char Version[] = VSTRING;

char AmigaVersion[] = VERSTAG;




/**
***  Include files
**/
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <exec/lists.h>
#include <exec/nodes.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
extern struct Library *SysBase;
extern struct Library *DOSBase;





/**
***  List of options processed by cc:
**/
typedef enum
  {
    OPTION_UNKNOWN,
    OPTION_VERBOSE,
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
    OPTION_OUTPUT
  } CompilerOption;





/**
***  This structure defines an element in the list of options.
**/
typedef struct
  {
    struct MinNode mn;
    CompilerOption Option;
    char *Arg;
  } CurrentOption;





/**
***  Compatibility mode (Default: gcc)
**/
enum
  {
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




/**
***  Compiler mode (Default: Everything)
**/
enum
  {
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




/**
***  These lists are used to hold the current options.
**/
struct List OptionList;





/**
***  Guess, what this function does? :-)
**/
void Usage(void)

  {
    printf("%s%s%s", "Usage: cc [options] [files]\n\
\n\
Options known to cc are:\n\
\n\
-v\t\tbe verbose\n\
-o<file>\t\tsend output to <file> (usage is recommended)\n\
-E\t\trun preprocessor only\n\
-a\t\trun preprocessor and compiler only\n\
-c\t\trun preprocessor, compiler and assembler, don't link\n\
-I<dir>\t\tlook for include files in <dir>\n\
-L<dir>\t\took for link libraries in <dir>\n\
-l<lib>\t\tlink with library <lib>\n\
-g\t\tturn debugging on\n\
-O\t\tturn optimization on\n\
-D<sym>\t\tdefine preprocessor symbol\n\
-U<sym>\t\tundefine preprocessor symbol\n\
-h,--help,?\tprint this message\n\
\n\n", Version, "\n\
©1994  by Jochen Wiedmann, all rights reserved\n\n\
This program is governed by the terms and conditions of the GNU General\n\
Public License. A copy should have come with this distribution. (See the\n\
file COPYING.) In that license it is made clear that you are welcome to\n\
redistribute either verbatim or modified copies of the program and the\n\
documentation under certain conditions. Further you are told that this\n\
program comes with ABSOLUTELY NO WARRANTY!\n\n\n");
    exit(5);
  }





/**
***  This functions adds a new option to the list of options.
**/
void AddOption(CompilerOption co, char *arg)

  {
    CurrentOption *cu;

    if (!(cu = malloc(sizeof(*cu))))
      {
	fprintf(stderr, "Out of memory!");
	exit(20);
      }
    cu->Option = co;
    cu->Arg = arg;
    AddTail(&OptionList, (struct Node *) cu);
  }





/**
***  This function handles options which may be splitted into two
***  arguments or not, like -I <dir> or -I<dir>.
**/
void AddOptionArg(CompilerOption co,
		  int *i,
		  int argc,
		  char *argv[])

  {
    char *arg = &argv[*i][2];

    if (!*arg)
      {
	if (++(*i) >= argc)
	  {
	    fprintf(stderr, "%s: Missing argument: %s\n", argv[--(*i)]);
	    exit(20);
	  }
	arg = argv[*i];
      }

    AddOption(co, arg);
  }





/**
***  This function is used to set the compatibility mode.
**/
void SetCompatibilityMode(int mode, int *set)

  {
    if (*set)
      {
	fprintf(stderr, "cc, warning: %s overwrites %s\n",
		CompatibilityModeNames[mode],
		CompatibilityModeNames[CompatibilityMode]);
	exit(10);
      }
    *set = TRUE;
    CompatibilityMode = mode;
  }





/**
***  This function is used to set the compatibility mode.
**/
void SetCompilerMode(int mode, int *set)

  {
    if (*set)
      {
	fprintf(stderr, "cc warning: %s overwrites %s\n",
		CompilerModeNames[mode],
		CompilerModeNames[CompilerMode]);
	exit(10);
      }
    *set = TRUE;
    CompilerMode = mode;
  }





/**
***  This function is used to build the string that is used to call
***  the real frontend. It supports strings of any length, thus it
***  may look somewhat complicated.
**/
void AddToString(char **strptr, char *format, ...)

  {
    static char buffer[1024];	/*  Maximal length of *one* argument	*/
    static int RealLen;
    static int MaxLen;
    int len;
    va_list args;

    va_start(args, format);
    vsprintf(buffer, format, args);
    len = strlen(buffer);

    if (!*strptr)
      {
	MaxLen = 0;
      }

    if (len + RealLen + 1 > MaxLen)
      {
	/**
	***  Current buffer not sufficient, allocate a new buffer
	**/
	char *newstr;

	if (!(newstr = malloc(MaxLen+1024)))
	  {
	    fprintf(stderr, "Out of memory!");
	    exit(20);
	  }
	MaxLen += 1024;

	if (*strptr)
	  {
	    strcpy(newstr, *strptr);
	  }
	else
	  {
	    *newstr = '\0';
	    RealLen = 0;
	  }
	*strptr = newstr;
      }

    strcpy(*strptr + RealLen, buffer);
    RealLen += len;
  }






/**
***  This function is used to parse the arguments. Options will
***  be included into OptionList, files in FileList.
**/
void ParseArgs(int argc,
	       char *argv[])

  {
    int i;
    /**
    ***  These variables are used for checking if arguments repeat.
    ***  Note that we keep them local: This allows, for example,
    ***  to use different settings in the environment and on the
    ***  command line.
    **/
    int CompatibilityModeIsSet = FALSE;
    int CompilerModeIsSet = FALSE;

    for (i = 0;  i < argc;  i++)
      {
	char *argvi = argv[i];

	if (argvi[0] == '-')
	  {
	    /**
	    ***  Assume this to be a compiler option.
	    **/

	    switch(argvi[1])
	      {
		case '-':
		  if (strcmp(argvi, "--help") == 0)
		    {
		      Usage();
		    }
		  AddOption(OPTION_UNKNOWN, argvi);
		  break;
		case 'D':
		  AddOptionArg(OPTION_DEFINE, &i, argc, argv);
		  break;
		case 'E':
		  switch(argvi[2])
		    {
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
		  AddOptionArg(OPTION_LINKDIR, &i, argc, argv);
		  break;
		case 'O':
		  AddOption(OPTION_OPTIMIZE, &argvi[2]);
		  break;
		case 'U':
		  AddOptionArg(OPTION_UNDEFINE, &i, argc, argv);
		  break;
		case 'a':
		  switch(argvi[2])
		    {
		      case '\0':
			SetCompilerMode(COMPILERMODE_COMPILER_ONLY,
					&CompilerModeIsSet);
			break;
		      default:
			AddOption(OPTION_UNKNOWN, argvi);
			break;
		    }
		  break;
		case 'c':
		  switch(argvi[2])
		    {
		      case '\0':
			SetCompilerMode(COMPILERMODE_ASSEMBLER_ONLY,
					&CompilerModeIsSet);
			break;
		      default:
			AddOption(OPTION_UNKNOWN, argvi);
			break;
		    }
		  break;
		case 'd':
		  if (strcmp(argvi,
			     CompatibilityModeNames[COMPATIBILITYMODE_DICE]) == 0)
		    {
		      SetCompatibilityMode(COMPATIBILITYMODE_DICE,
					   &CompatibilityModeIsSet);
		    }
		  else
		    {
		      AddOption(OPTION_UNKNOWN, argvi);
		    }
		  break;
		case 'g':
		  switch(argvi[2])
		    {
		      case '\0':
			AddOption(OPTION_DEBUGGING, argvi);
			break;
		      default:
			if (strcmp(argvi,
				   CompatibilityModeNames[COMPATIBILITYMODE_GCC]) == 0)
			  {
			    SetCompatibilityMode(COMPATIBILITYMODE_GCC,
						 &CompatibilityModeIsSet);
			  }
			else
			  {
			    AddOption(OPTION_UNKNOWN, argvi);
			  }
			break;
		    }
		  break;
		case 'h':
		  switch(argvi[2])
		    {
		      case '\0':
			Usage();
		      default:
			AddOption(OPTION_UNKNOWN, argvi);
			break;
		    }
		  break;
		case 'l':
		  AddOptionArg(OPTION_LIBRARY, &i, argc, argv);
		  break;
		case 'o':
		  AddOptionArg(OPTION_OUTPUT, &i, argc, argv);
		  break;
		case 's':
		  if (strcmp(argvi,
			     CompatibilityModeNames[COMPATIBILITYMODE_SAS]) == 0)
		    {
		      SetCompatibilityMode(COMPATIBILITYMODE_SAS,
					   &CompatibilityModeIsSet);
		    }
		  else
		    {
		      AddOption(OPTION_UNKNOWN, argvi);
		    }
		  break;
		case 'v':
		  switch(argvi[2])
		    {
		      case '\0':
			AddOption(OPTION_VERBOSE, argvi);
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
	  }
	else if (strcmp(argvi, "?") == 0)
	  {
	    Usage();
	  }
	else
	  {
	    AddOption(OPTION_UNKNOWN, argvi);
	  }
      }
  }





/**
***  This function calls gcc as a frontend.
**/
int CompileGcc(void)

  {
    CurrentOption *co;
    char *CompileString = NULL;
    int Verbose = FALSE;

    AddToString(&CompileString, "gcc");

    for (co = (CurrentOption *) OptionList.lh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ)
      {
	switch (co->Option)
	  {
	    case OPTION_UNKNOWN:
	      AddToString(&CompileString, " \"%s\"", co->Arg);
	      break;
	    case OPTION_VERBOSE:
	      AddToString(&CompileString, " -v");
	      Verbose = TRUE;
	      break;
	    case OPTION_DEFINE:
	      AddToString(&CompileString, " \"-D%s\"", co->Arg);
	      break;
	    case OPTION_UNDEFINE:
	      AddToString(&CompileString, " \"-U%s\"", co->Arg);
	      break;
	    case OPTION_PREPROCESSOR_ONLY:
	      AddToString(&CompileString, " -E");
	      break;
	    case OPTION_ASSEMBLER_ONLY:
	      AddToString(&CompileString, " -a");
	      break;
	    case OPTION_NOLINK:
	      AddToString(&CompileString, " -c");
	      break;
	    case OPTION_INCLUDEDIR:
	      AddToString(&CompileString, " \"-I%s\"", co->Arg);
	      break;
	    case OPTION_LINKDIR:
	      AddToString(&CompileString, " \"-L%s\"", co->Arg);
	      break;
	    case OPTION_OPTIMIZE:
	      AddToString(&CompileString, " \"-O%s\"", co->Arg);
	      break;
	    case OPTION_DEBUGGING:
	      AddToString(&CompileString, " -g");
	      break;
	    case OPTION_LIBRARY:
	      AddToString(&CompileString, " \"-l%s\"", co->Arg);
	      break;
	    case OPTION_OUTPUT:
	      AddToString(&CompileString, " -o \"%s\"", co->Arg);
	      break;
	  }
      }

    AddToString(&CompileString, "\n");
    if (Verbose)
      {
	printf("%s\n%s", Version, CompileString);
      }

    return(system(CompileString));
  }





/**
***  This function calls SAS/C as a frontend.
**/
int CompileSAS(void)

  {
    CurrentOption *co;
    char *CompileString = NULL;
    int Verbose = FALSE;
    char *OptionOutput = NULL;

    AddToString(&CompileString, "sc");

    for (co = (CurrentOption *) OptionList.lh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ)
      {
	switch (co->Option)
	  {
	    case OPTION_UNKNOWN:
	      AddToString(&CompileString, " \"%s\"", co->Arg);
	      break;
	    case OPTION_VERBOSE:
	      AddToString(&CompileString, " VERBOSE");
	      Verbose = TRUE;
	      break;
	    case OPTION_DEFINE:
	      AddToString(&CompileString, " DEF \"%s\"", co->Arg);
	      break;
	    case OPTION_UNDEFINE:	/*  Not supported   */
	      break;
	    case OPTION_INCLUDEDIR:
	      AddToString(&CompileString, " IDIR\"%s\"", co->Arg);
	      break;
	    case OPTION_LINKDIR:	/*  Not supported   */
	      break;
	    case OPTION_OPTIMIZE:
	      AddToString(&CompileString, " OPTIMIZE");
	      break;
	    case OPTION_DEBUGGING:
	      AddToString(&CompileString, " DEBUG FULLFLUSH");
	      break;
	    case OPTION_LIBRARY:
	      AddToString(&CompileString, " LIBRARY \"%s.lib\"", co->Arg);
	      break;
	    case OPTION_OUTPUT:
	      OptionOutput = co->Arg;
	      break;
	  }
      }

    switch(CompilerMode)
      {
	case COMPILERMODE_PREPROCESSOR_ONLY:
	  AddToString(&CompileString, " PPONLY");
	case COMPILERMODE_ASSEMBLER_ONLY:
	  if (OptionOutput)
	    {
	      AddToString(&CompileString, " OBJNAME \"%s\"", OptionOutput);
	    }
	  break;
	case COMPILERMODE_COMPILER_ONLY:
	  if (!OptionOutput)
	    {
	      OptionOutput = "*";
	    }
	  AddToString(&CompileString, " \"DISASM=%s\"", OptionOutput);
	  break;
	case COMPILERMODE_EVERYTHING:
	  if (OptionOutput)
	    {
	      AddToString(&CompileString, " PNAME \"%s\"", OptionOutput);
	    }
	  AddToString(&CompileString, " LINK");
	  break;
      }

    AddToString(&CompileString, "\n");
    if (Verbose)
      {
	printf("%s\n%s", Version, CompileString);
      }

    return(system(CompileString));
  }






/**
***  This function calls Dice as a frontend.
**/
int CompileDice(void)

  {
    CurrentOption *co;
    char *CompileString = NULL;
    int Verbose = FALSE;

    switch(CompilerMode)
      {
	case COMPILERMODE_PREPROCESSOR_ONLY:
	  AddToString(&CompileString, "dcpp");
	  break;
	case COMPILERMODE_COMPILER_ONLY:
	  AddToString(&CompileString, "dcc -a");
	  break;
	case COMPILERMODE_ASSEMBLER_ONLY:
	  AddToString(&CompileString, "dcc -c");
	  break;
	default:
	  AddToString(&CompileString, "dcc");
	  break;
      }

    for (co = (CurrentOption *) OptionList.lh_Head;
	 co->mn.mln_Succ != NULL;
	 co = (CurrentOption *) co->mn.mln_Succ)
      {
	switch (co->Option)
	  {
	    case OPTION_UNKNOWN:
	      AddToString(&CompileString, " \"%s\"", co->Arg);
	      break;
	    case OPTION_VERBOSE:
	      if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY)
		{
		  AddToString(&CompileString, " -v", co->Arg);
		}
	      Verbose = TRUE;
	      break;
	    case OPTION_DEFINE:
	      AddToString(&CompileString, " \"-D%s\"", co->Arg);
	      break;
	    case OPTION_UNDEFINE:	    /*	Not supported	*/
	      break;
	    case OPTION_INCLUDEDIR:
	      AddToString(&CompileString, " \"-I%s\"", co->Arg);
	      break;
	    case OPTION_LINKDIR:
	      if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY)
		{
		  AddToString(&CompileString, " \"-L%s\"", co->Arg);
		}
	      break;
	    case OPTION_OPTIMIZE:	    /*	Not suported	*/
	      break;
	    case OPTION_DEBUGGING:
	      if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY)
		{
		  AddToString(&CompileString, " -s -d1");
		}
	      break;
	    case OPTION_LIBRARY:
	      if (CompilerMode != COMPILERMODE_PREPROCESSOR_ONLY)
		{
		  AddToString(&CompileString, " \"-l%s\"", co->Arg);
		}
	      break;
	    case OPTION_OUTPUT:
	      AddToString(&CompileString, " -o \"%s\"", co->Arg);
	      break;
	  }
      }

    AddToString(&CompileString, "\n");
    if (Verbose)
      {
	printf("%s\n%s", Version, CompileString);
      }

    return(system(CompileString));
  }





/**
***  This function is used to split a string into arguments.
***  It returns an array similar to argv.
***
***  I don't like doing things for myself, but as far as I
***  can see neither SAS nor Dice offer a possibility of
***  doing this.
***
***  Inputs: argstr - the string to split into arguments,
***		for example an AmigaDOS command line;
***		may contain arguments like
***		    "This is one argument"
***		or
***		    "Note the "" inside this argument"
***		where the double quotation mark will be
***		changed into one.
***	    argc - pointer to an int where to store the
***		number of arguments found in argstr
***
***  Result: an NULL terminated array of pointers to the
***	    arguments or NULL; note that the pointers go
***	    into argstr and argstr will be modified.
**/
char **SplitArgs(char *argstr, int *argcptr)

  {
    int argc;
    char *argptr;
    char **argv;
    char **argvptr;

    /**
    ***  Parse the string for the first time counting
    ***  the number of arguments.
    **/
    argptr = argstr;
    argc = 0;
    for(;;)
      {
	/**
	***  Skip blanks
	**/
	while (*argptr == ' '  ||  *argptr == '\t')
	  {
	    ++argptr;
	  }

	if (*argptr == '\0'  ||  *argptr == '\n'  ||  *argptr == '\r')
	  {
	    break;
	  }

	++argc;

	if (*argptr == '\"')
	  {
	    do
	      {
		++argptr;
		if (*argptr == '\"')
		  {
		    if (*(argptr+1) == '\"')
		      {
			++argptr;
		      }
		    else
		      {
			break;
		      }
		  }
	      }
	    while (*argptr != '\0'  &&  *argptr != '\r'  &&  *argptr != '\n');
	  }
	else
	  {
	    while (*argptr != '\0'  &&  *argptr != '\r'  &&  *argptr != '\n'  &&
		   *argptr != '\t'  &&  *argptr != ' ')
	      {
		++argptr;
	      }
	  }
	{
	  char c;

	  c = *argptr;
	  *(argptr++) = '\0';

	  if (c == '\0'  ||  c == '\r'  ||  c == '\n')
	    {
	      break;
	    }
	}
      }

    *argcptr = argc;
    if (!(argv = malloc(sizeof(char *) * (argc+1))))
      {
	return(NULL);
      }

    /**
    ***  Parse the string a second time
    **/
    for (argvptr = argv, argptr = argstr;  argc > 0;  --argc, ++argvptr)
      {
	int inside;

	while (*argptr == ' '  ||  *argptr == '\t')
	  {
	    ++argptr;
	  }

	if (*argptr == '\"')
	  {
	    ++argptr;
	    inside = TRUE;
	  }
	else
	  {
	    inside = FALSE;
	  }
	*argvptr = argptr;

	while (*argptr)
	  {
	    if (*argptr == '\"'  &&  inside)
	      {
		char *ptr;
		char *oldptr;

		/**
		***  Found a "", remove the second ".
		**/
		for(ptr = argptr++, oldptr = *argvptr;
		    ptr >= oldptr;  --ptr)
		  {
		    *(ptr+1) = *ptr;
		  }
		*argvptr = oldptr+1;
	      }
	    ++argptr;
	  }
	++argptr;
      }
    *argvptr = NULL;

    return(argv);
  }





/**
***  Finally main().
**/
int main(int argc, char *argv[])

  {
    char *cflags;

    NewList(&OptionList);

    if ((cflags = getenv("CCOPT")))
      {
	int envargc;
	char **envargv;

	if (!(envargv = SplitArgs(cflags, &envargc)))
	  {
	    fprintf(stderr, "Out of memory!\n");
	    exit(20);
	  }
	ParseArgs(envargc, envargv);
      }

    ParseArgs(argc-1, argv+1);

    switch(CompatibilityMode)
      {
	case COMPATIBILITYMODE_GCC:
	  CompileGcc();
	  break;
	case COMPATIBILITYMODE_SAS:
	  CompileSAS();
	  break;
	case COMPATIBILITYMODE_DICE:
	  CompileDice();
	  break;
      }
  }

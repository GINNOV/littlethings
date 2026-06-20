#ifndef yySystem
#define yySystem

/* $Id: System.h,v 1.3 1992/02/04 14:01:39 grosch rel $ */

/* $Log:
 */

/* Ich, Doktor Josef Grosch, Informatiker, Jan. 1992 */


/* interface for machine dependencies */

#ifndef bool
  #define bool char
#endif
#define tFile int


/* binary IO */

tFile OpenInput(char *FileName);
/* Opens the file whose name is given by the */
/* string parameter 'FileName' for input.    */
/* Returns an integer file descriptor.       */

tFile OpenOutput(char *FileName);
/* Opens the file whose name is given by the */
/* string parameter 'FileName' for output.   */
/* Returns an integer file descriptor.       */

int Read(tFile File, char *Buffer, int Size);
/* Reads 'Size' bytes from file 'tFile' and    */
/* stores them in a buffer starting at address */
/* 'Buffer'.                                   */
/* Returns the number of bytes actually read.  */

int Write(tFile File, char *Buffer, int Size);
/* Writes 'Size' bytes from a buffer starting    */
/* at address 'Buffer' to file 'tFile'.          */
/* Returns the number of bytes actually written. */

void Close(tFile File);
/* Closes file 'tFile'. */

bool IsCharacterSpecial(tFile File);
/* Returns TRUE when file 'tFile' is connected */
/* to a character device like a terminal.      */


/* calls other than IO */

char *SysAlloc(long ByteCount);
/* Returns a pointer to dynamically allocated */
/* memory space of size 'ByteCount' bytes.    */
/* Returns NIL if space is exhausted.         */

long Time(void);
/* Returns consumed cpu-time in milliseconds. */

int GetArgCount(void);
/* Returns number of arguments. */

void GetArgument(int ArgNum, char *Argument);
/* Stores a string-valued argument whose index */
/* is 'ArgNum' in the memory area 'Argument'.  */

void PutArgs(int Argc, char **Argv);
/* Dummy procedure that passes the values */
/* 'argc' and 'argv' from Modula-2 to C.  */

int ErrNum(void);
/* Returns the current system error code. */

int System(char *String);
/* Executes an operating system command given */
/* as the string 'String'. Returns an exit or */
/* return code.                               */

void Exit(int Status);
/* Terminates program execution and passes the */
/* value 'Status' to the operating system.     */

void BEGIN_System(void);
/* Dummy procedure with empty body. */

#endif

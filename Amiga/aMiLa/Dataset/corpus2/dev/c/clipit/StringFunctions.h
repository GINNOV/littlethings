/****h* StringFuncs.h [1.2] ************************************************
*
* NAME
*    StringFuncs.h
*
* DESCRIPTION
*    Since there are some problems associated with the string functions
*    that come with gcc, I had to write these functions which are a lot
*    more forgiving than the standard string functions.
*    link with -lstringfuncs.
*
* HISTORY
*    20-Sep-2005 - Added the stoi() function.
*
*    19-Feb-2005 - Added the StringNIComp() function.
*
*    12-Dec-2004 - Created this file.
*
* NOTES
*    $VER: StringFuncs.h 1.2 (20-Sep-2005) by J.T. Steichen
****************************************************************************
*
*/

#ifndef  STRINGFUNCTIONS_H
# define STRINGFUNCTIONS_H 1

# ifndef    EXEC_TYPES_H 
#  include <exec/types.h>
# endif

# ifndef    AMIGADOSERRS_H
#  include <AmigaDOSErrs.h>
# endif

IMPORT int stoi( char **inputString ); // NOTE well the double star!!

// Replacement for strncpy():
IMPORT void StringNCopy( UBYTE *dest, UBYTE *src, int size );

// Replacement for strcpy():
IMPORT int StringCopy( UBYTE *dest, UBYTE *src );

// Replacement for strlen():
IMPORT int StringLength( UBYTE *str );

// Replacement for strcmp():
IMPORT int StringComp( UBYTE *str1, UBYTE *str2 );

// Replacement for strncmp():
IMPORT int StringNComp( UBYTE *str1, UBYTE *str2, unsigned int size );

// Replacement for strnicmp():
IMPORT int StringNIComp( char *str1, char *str2, int length );

// Replacement for stricmp():
IMPORT int StringIComp( UBYTE *str1, UBYTE *str2 );

// Replacement for strnicmp():
IMPORT int StringNIComp( char *str1, char *str2, int length );

IMPORT UBYTE *SubString( UBYTE *str, UBYTE *end );

// Replacement for strcat():
IMPORT UBYTE *StringCat( char *string1, char *string2 );

// Replacement for strncat():
IMPORT UBYTE *StringNCat( char *string1, char *string2, int maxSize );

IMPORT int RemoveSubString( char *delstr, int first, int num_char );

IMPORT UBYTE *UpperCase( UBYTE *inputString );
IMPORT UBYTE *LowerCase( UBYTE *inputString );

IMPORT int StringIndex( char *string, char *substring );

IMPORT int FindChar( char *string, char letter );

IMPORT UBYTE *ReverseString( char *string );

IMPORT UBYTE *ReplaceChar( UBYTE *string, UBYTE old_char, UBYTE new_char );

#endif

/* ----------------------- END of StringFuncs.h file! ----------------------- */

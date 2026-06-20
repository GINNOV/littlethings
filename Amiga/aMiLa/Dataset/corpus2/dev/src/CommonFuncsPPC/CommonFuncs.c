/****h* CommonFuncs.c [4.0] *********************************************
*
* NAME
*    CommonFuncs.c
*
* DESCRIPTION
*    Functions that get used a lot for GUI programming, especially for
*    GadToolsBox-generated GUIs.  This file is used to generate 
*    CommonFuncs.o - a Link-able Object for the SAS-C (V6.58) compiler,
*    or CommonFuncsPPC.o for the gcc compiler, PowerPC & AmigaOS4.
*
*    This a link-able object because there are far too many shared 
*    libraries for the Amiga OS as it is, I couldn't see cluttering 
*    someone's hard drive with another one (especially my own!).
*
* HISTORY
*    26-Mar-2007 - Locale'ized the entire file.
*
*    03-Nov-2005 - Added the FileExists() function.
*
*    25-Oct-2005 - Added stringfunctions.c functions for SAS-C code.
*
*    31-Jan-2005 - Added GetUserString() Requester code.
*
*    24-Jan-2005 - Replaced all string.h functions with their
*                  equivalent functions in libstringfuncs.a.
*
*    21-Jan-2005 - Added OpenFile() & TrimSpaces() functions.
*    14-Jan-2005 - Added IsGadgetSelected() & IsMenuChecked() functions.
*    20-Oct-2004 - All functions are now independent of the User
*                  opening & closing the correct libraries for AmigaOS4.0.
*    17-Oct-2004 - Added AmigaOS4.0 conditional support (via gcc)
*    01-Oct-2003 - Added void strClear( char * ) function.L1054
*    24-Sep-2003 - Added GetActiveWindow() calls to all the Requesters.
*    09-Sep-2003 - Added the drawArc() function.
*    09-Apr-2002 - Added the getUserFont() function.
*
* AUTHOR
*    James T. Steichen
*    2217 N. Tamarack Dr.
*    Slayton, Mn. 56172-1155, USA
*    jimbot at frontiernet.net
*
* NOTES
*    $VER: CommonFuncs.c 4.0 (26-Mar-2007) by J.T. Steichen
*
* COPYRIGHT
*    CommonFuncs.c & CommonFuncs.h (c) 1999-2007 by J.T. Steichen,
*    All Rights Reserved.
*************************************************************************
*
*/

#include <stdio.h>

#include <fcntl.h> // For stuff used by FileExists().
#include <errno.h> // For stuff used by FileExists().

#include <math.h>  // For PI, cos() & sin().

#include <AmigaDOSErrs.h>

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/libraries.h>

#include <libraries/asl.h>
#include <libraries/gadtools.h>

#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>

#include <graphics/view.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>

#include <workbench/workbench.h>

#include <dos/dos.h>

#ifdef    __SASC
# include <clib/dos_protos.h>
# include <clib/exec_protos.h>
# include <clib/intuition_protos.h>
# include <clib/graphics_protos.h>

IMPORT __far struct IntuitionBase *IntuitionBase;
IMPORT __far struct GfxBase       *GfxBase;
IMPORT __far struct Library       *GadToolsBase;
IMPORT __far struct Library       *AslBase;
IMPORT __far struct Library       *UtilityBase;
IMPORT __far struct Library       *DiskfontBase;
IMPORT __far struct Library       *IconBase;

#else // __amigaos4__ declarations:

# define __USE_INLINE__

# include <proto/dos.h>
# include <proto/exec.h>
# include <proto/graphics.h>
# include <proto/gadtools.h>
# include <proto/asl.h>
# include <proto/icon.h>
# include <proto/utility.h>
# include <proto/intuition.h>
//# include <proto/diskfont.h>

IMPORT struct Library *IntuitionBase;
IMPORT struct Library *GfxBase;
IMPORT struct Library *GadToolsBase;

IMPORT struct IntuitionIFace *IIntuition;
IMPORT struct ExecIFace      *IExec;
IMPORT struct GadToolsIFace  *IGadTools;
IMPORT struct GraphicsIFace  *IGraphics;

IMPORT struct AslIFace       *IAsl;
IMPORT struct UtilityIFace   *IUtility;
IMPORT struct IconIFace      *IIcon;
//IMPORT struct DiskfontIFace  *IDiskfont;

IMPORT struct Library *AslBase;
IMPORT struct Library *UtilityBase;
IMPORT struct Library *IconBase;
//IMPORT struct Library *DiskfontBase;

#  define PI      3.14159265358979323846
#  define PID2    1.57079632679489661923       /*  PI/2  */
#  define PID4    0.78539816339744830962       /*  PI/4  */
#  define I_PI    0.31830988618379067154       /*  1/PI  */
#  define I_PID2  0.63661977236758134308       /*  1/(PI/2)  */

#endif // #ifdef __SASC

#include "CommonFuncs.h"

#ifdef __amigaos4__
# ifndef  INVISIBLE
#  define INVISIBLE // gcc generates "useless keyword or type name in empty declaration" for PRIVATE
# endif
#else
# define INVISIBLE PRIVATE
#endif


#ifdef __SASC
# include <clib/locale_protos.h>
IMPORT struct LocaleBase *LocaleBase;

#else // __amigaos4__
# include <proto/locale.h>

IMPORT struct Library     *LocaleBase;
IMPORT struct LocaleIFace *ILocale;
#endif

PRIVATE struct Catalog *CFCatalog = NULL;

#define   MY_LANGUAGE          "english"
#define   CATCOMP_ARRAY        1
#include "CommonFuncsLocale.h"

/*
Misc defines for SAS-C Compiler:

AMIGA
LPTR
LATTICE
LATTICE_50
_AMIGA
_M68000
__SASC
__SASC_60
__SASC_650
__VERSION__
__REVISION__
__STDC__
_STANDARD
_NOSHORTINT
_NOUNSCHAR
_MGST
__AMIGADATE__

*/

// V3.8 Functions added:

/****h* CMsg() [1.0] *************************************************
*
* NAME
*    STRPTR rval = CMsg( int index, char *defaultStr );
*
* DESCRIPTION
*    Obtain a string from the locale catalog file, failing that,
*    return the default string.
*
* WARNINGS
*    The function internally uses the name 'catalog' for the struct
*    Catalog that it will use, so make sure that your code uses
*    'catalog' for the name of the Catalog struct!!
**********************************************************************
*
*/

PUBLIC STRPTR CMsg( int strIndex, char *defaultString )
{
	IMPORT struct Catalog *catalog;
	
   if (catalog)
      return( (STRPTR) GetCatalogStr( catalog, strIndex, defaultString ) );
   else
      return( (STRPTR) defaultString );
}

/****h* pathIncluded() [1.0] *****************************************
*
* NAME
*    pathIncluded()
*
* DESCRIPTION
*    Check the given fileName to see if it contains path information.
**********************************************************************
*
*/

PUBLIC BOOL pathIncluded( char *fileName )
{
	BOOL rval = FALSE;
	
	if (StringIndex( fileName, ":" ) > 0)
	   rval = TRUE;
	else if (StringIndex( fileName, "/" ) > 0)
	   rval = TRUE; // Whether the path exists is a whole nother problemo!
		
	return( rval );
}

/****i* getCatalog() [3.8] **************************************************
*
* NAME
*    getCatalog()
*
* DESCRIPTION
*    Open the given catalog (if possible).
*****************************************************************************
*
*/

SUBFUNC struct Catalog *getCatalog( STRPTR catalogName )
{
	return( OpenCatalog( NULL, catalogName, OC_BuiltInLanguage, MY_LANGUAGE, TAG_DONE ) );
}

/****i* pvSetupCatalog() [3.8] **********************************************
*
* NAME
*    pvSetupCatalog()
*
* DESCRIPTION
*    Open LocaleBase if necessary, then try to open the commonfuncs.catalog
*****************************************************************************
*
*/

PRIVATE BOOL openedInternalLocale = FALSE;

SUBFUNC void pvSetupCatalog( void )
{
#  ifdef __SASC
   if (!LocaleBase)
	   {
		if ((LocaleBase = (struct LocaleBase *) OpenLibrary( "locale.library", 39L )))
		   {
			CFCatalog = getCatalog( "commonfuncs.catalog" );
			openedInternalLocale = TRUE;
			}
		else
		   {
		   CFCatalog            = NULL;
         openedInternalLocale = FALSE;
			}
		}
	else
	   {
		CFCatalog = getCatalog( "commonfuncs.catalog" );
      openedInternalLocale = FALSE;
	   }

#  else // __amigaos4__

   if (!LocaleBase)
	   {
		if ((LocaleBase = OpenLibrary( "locale.library", 50L )))
		   {
			if (!(ILocale = (struct LocaleIFace *) GetInterface( LocaleBase, "main", 1, NULL )))
			   {
				fprintf( stderr, "Could NOT obtain ILocale interface V50!\n" );
				CloseLibrary( LocaleBase );
				
            openedInternalLocale = FALSE;
				CFCatalog = NULL;
				}
			else
			   {
			   CFCatalog = getCatalog( "commonfuncs.catalog" );
            openedInternalLocale = TRUE;
			   }
			}
		else
		   {
		   CFCatalog            = NULL;
         openedInternalLocale = FALSE;
		   }
		}
	else
	   {
		if (ILocale)
		   {
		   CFCatalog = getCatalog( "commonfuncs.catalog" );
         openedInternalLocale = FALSE;
		   }
		else
		   {
			if (!(ILocale = (struct LocaleIFace *) GetInterface( LocaleBase, "main", 1, NULL )))
			   {
				fprintf( stderr, "Could NOT obtain ILocale interface V50!\n" );
			   CFCatalog = NULL;
			   }
			else
			   CFCatalog = getCatalog( "commonfuncs.catalog" );
			}

      openedInternalLocale = FALSE; // Already opened!
		}
#  endif

	return;
}

/****i* pvCloseCatalog() [3.8] **********************************************
*
* NAME
*    pvCloseCatalog()
*
* DESCRIPTION
*    Close the internal commonfuncs.catalog (if necessary).
*****************************************************************************
*
*/

SUBFUNC void pvCloseCatalog( void )
{
	if (CFCatalog)
	   {
	   CloseCatalog( CFCatalog );
		CFCatalog = NULL;
	   }

   if (openedInternalLocale == TRUE)
	   {
		CloseLibrary( (struct Library *) LocaleBase );

      openedInternalLocale = FALSE;

#     ifdef __amigaos4__
      if (ILocale)
		   {
			DropInterface( (struct Interface *) ILocale );
			ILocale = NULL;
			}
#     endif
		}
					
	return;
}

/****i* CFMsg() [1.0] *************************************************
*
* NAME
*    STRPTR rval = CFMsg( int index, STRPTR defaultStr );
*
* DESCRIPTION
*    Obtain a string from the locale catalog file, failing that,
*    return the default string.  This function is internal to the
*    CommonFuncs object only!!
**********************************************************************
*
*/

PRIVATE STRPTR CFMsg( int strIndex, STRPTR defaultString )
{
   BOOL   closeTheCatalog = FALSE;
   STRPTR rval            = defaultString;
	
	if (!CFCatalog)
	   {
		pvSetupCatalog();      // Ensure that locale.library & CFCatalog are open (if possible).
		closeTheCatalog = TRUE;
		}

   if (CFCatalog)
      rval = GetCatalogStr( CFCatalog, strIndex, defaultString );

   if (closeTheCatalog == TRUE)
	   pvCloseCatalog();
		
	return( rval );
}


/****h* RunMyCommand() [3.7] *****************************************************
*
* NAME
*    RunMyCommand()
*
* SYNOPSIS
*    int success = RunMyCommand( char *CommandString );
*
* DESCRIPTION
*    Tell the operating system to execute the given command string as if it were
*    being run from a shell/Cli.
*
* RETURNS
*    RETURN_OK if the command was successful.
**********************************************************************************
*
*/

PUBLIC int RunMyCommand( char *command )
{
   int chk = RETURN_OK;
   
   if ((chk = System( &command[0], TAG_DONE )) != RETURN_OK)
      {
		char ErrMsg[512] = { 0, };

		fprintf( stderr, CFMsg( MSG_FORMAT_CMD_ERR, MSG_FORMAT_CMD_ERR_STR ), &command[0], chk );

      sprintf( ErrMsg, CFMsg( MSG_FORMAT_CMD_ERR, MSG_FORMAT_CMD_ERR_STR ), &command[0], chk );

      UserInfo( ErrMsg, CFMsg( MSG_RQTITLE_TOOL_ERROR, MSG_RQTITLE_TOOL_ERROR_STR ) );
      }
      
   return( chk );
}

/****h* ClearNodeStrs() [3.7] *****************************************************
*
* NAME
*    ClearNodeStrs()
*
* SYNOPSIS
*    void ClearNodeStrs( struct ListViewMem *lvm, int numItems, int itemSize );
*
* DESCRIPTION
*    Set the internal buffer associated with a ListView Gadget to all nils.
***********************************************************************************
*
*/

PUBLIC void ClearNodeStrs( struct ListViewMem *lvm, int numitems, int itemsize )
{
   int i, len = itemsize * numitems;
   
   for (i = 0; i < len; i++)
      *(lvm->lvm_NodeStrs + i) = '\0'; 

   return;
}

/****h* removeNewLine() [3.7] *****************************************************
*
* NAME
*    removeNewLine()
*
* SYNOPSIS
*    void removeNewLine( char *inputLine );
*
* DESCRIPTION
*    If the supplied string has a newline at the end of it, replace it with a nil.
***********************************************************************************
*
*/

PUBLIC void removeNewLine( char *line )
{
   int len = StringLength( line );
   
   if (line[ len ] == '\n')
      line[ len ] = '\0';
   else if (line[ len - 1 ] == '\n')
      line[ len - 1 ] = '\0';
      
   return;
}

/****h* countFileLines() [3.7] *****************************************************
*
* NAME
*    countFileLines()
*
* SYNOPSIS
*    int numNewLines = countFileLines( FILE *inputFile );
*
* DESCRIPTION
*    count the number of newline characters in a file, then rewind() it.
************************************************************************************
*
*/

PUBLIC int countFileLines( FILE *input )
{
   int rval = 0, ch = 0;

   if (!input)
      return( rval );
         
   rewind( input );

   ch = fgetc( input );
   
   while (ch != EOF)
      {
      if (ch == '\n')
         rval++;
         
      ch = fgetc( input );
      }

   rewind( input );
   
   return( rval );
}

// V3.6 Functions added:

/****h* FileExists() [3.6] ***********************************************
*
* NAME
*    FileExists()
*
* SYNOPSIS
*    BOOL result = FileExists( UBYTE *fileName );
*
* DESCRIPTION
*    Check a fileName to see if it exists as a file in your Amiga PC.
*
* INPUTS
*    fileName - contains the file name of the file you wish to
*               verify.
* RETURN VALUE
*    TRUE if the fileName is present as a file or directory,
*    FALSE otherwise.
*
* COPYRIGHT
*    Copyright (C) 2005 by J.T. Steichen.  All rights reserved.
*    This function may be copied for personal, non-profit use only.
**************************************************************************
*
*/

PUBLIC BOOL FileExists( char *fileName )
{
   extern int errno;
   
   BOOL result = TRUE; // Assume the file exists.
   int  chk    = -1;

   errno = 0; // Reset errno first...
      
   if ((chk = open( fileName, O_RDONLY )) < 0)
      {
      switch (errno)
         {
	 case ENOENT:       // No such file or directory, therefore return FALSE.
	 case ENOTBLK:      // Block device required, therefore no file!
	 case ENXIO:        // Device not configured.

#        ifdef __amigaos4__ // SAS-C does not know about this one!
	 case EPERM:        // Operation NOT permitted, therefore the file might as well NOT exist!
#        endif
	    result = FALSE;
	    break;

	 case EEXIST:       // File exists, return TRUE (DUH!)
	 case EFBIG:        // File too large (implies that the file does exist!)
	 case EISDIR:       // Goofy User is checking for a directory, which apparently exists.
	    result = TRUE;
	    break;

         /* What to do about these????
	 case ENFILE:       // Too many open files in system.
	 case EMFILE:       // Too many open files.
	 case ENAMETOOLONG: // File name too long
	 case EINVAL:       // Invalid argument
	    break;
	 */

	 default:           // I'm NOT a total Guru, I give up!
	    break;
	 }
      }
   else
      close( chk );         // Undo the open() call.
         
   return( result );
}

// V3.5 functions added:

#ifndef __amigaos4__ // SAS-C does NOT have as many problems with its string functions:

/****h* stoi() [3.6] ***********************************************
*
* NAME
*    stoi()
*
* SYNOPSIS
*    int result = stoi( char **inputString );
*
* DESCRIPTION
*    Convert a string to integer.  If the string starts with 0x, it
*    is interpreted as a HexaDecimal number, else if it starts with
*    a 0 it is octal, else it is decimal.  Conversion stops on 
*    encountering the 1st character which is NOT a digit in the
*    indicated radix.  *inputString is updated to point to the end
*    of the numbers found.
*
* INPUTS
*    inputString - contains the string to convert.
*
* COPYRIGHT
*    Copyright (C) 1985 by Allen Holub.  All rights reserved.
*    This program may be copied for personal, non-profit use only.
*
* NOTES
*    From "Dr. Dobb's ToolBook of C", 1986, ISBN: 0-89303-599-8,
*    pgs 476-477.
********************************************************************
*
*/

PUBLIC int stoi( char **inputString )
{
   int   num  = 0;
   char *str  = *inputString;
   int   sign = 1;

   while (*str == ' ' || *str == '\t' || *str == '\n') 
      str++; // Skip over whitespace
      
   if (*str == '-')
      {
      sign = -1;
      str++;
      }

   if (*str == '0')
      {
      ++str;
      
      if (*str == 'x' || *str =='X')
         {
	 ++str; // Number is HexaDecimal:
	 
	 while (isxdigit( toupper( *str ) ))
	    {
	    num *= 16;
	    num += ('0' <= *str && *str <= '9') ? *str - '0' : toupper( *str ) - 'A' + 10;
	    str++;
	    }
	 }
      else  // Number could be Octal
         {
	 while ('0' <= *str && *str <= '7')
	    {
	    num *= 8;
	    num += *str++ - '0'; // Convert from ASCII to a number
	    }
	 }
      }
   else // Number is decimal number:
      {
      while ('0' <= *str && *str <= '9')
         {
	 num *= 10;
	 num += *str++ - '0'; // Convert from ASCII to a number
	 }
      }

   *inputString = str;
         
   return( num * sign );   
}

/****h* StringNCopy() [3.6] ****************************************
*
* NAME
*    StringNCopy()
*
* SYNOPSIS
*    void StringNCopy( char *dest, char *src, int size );
********************************************************************
*
*/

PUBLIC void StringNCopy( char *dest, char *src, int size )
{
   (void) strncpy( dest, src, size );

   return;
}

/****h* StringCopy() [3.6] *****************************************
*
* NAME
*    StringCopy()
*
* SYNOPSIS
*    int length = StringCopy( char *dest, char *src );
********************************************************************
*
*/

PUBLIC int StringCopy( char *dest, char *src )
{
   strcpy( dest, src );
   
   return( strlen( dest ) );
}

/****h* StringLength() [3.6] **************************************
*
* NAME
*    StringLength()
*
* SYNOPSIS
*    int length = StringLength( char *str );
*
* DESCRIPTION
*    The strlen() function does not handle a NULL parameter.
*    This function corrects this deficiency.
********************************************************************
*
*/

PUBLIC int StringLength( char *str )
{
   if (!str)
      return( 0 );
   else
      return( strlen( str ) );
}

/****h* StringComp() [3.6] *****************************************
*
* NAME
*    StringComp()
*
* SYNOPSIS
*    int result = StringComp( char *str1, char *str2 );
********************************************************************
*
*/

PUBLIC int StringComp( char *str1, char *str2 )
{
   return( strcmp( str1, str2 ) );
}

/****h* StringNComp() [3.6] ****************************************
*
* NAME
*    StringNComp()
*
* SYNOPSIS
*    int result = StringNComp( char *str1, char *str2, int size );
********************************************************************
*
*/

PUBLIC int StringNComp( char *str1, char *str2, unsigned int size )
{
   return( strncmp( str1, str2, size ) );
}

/****h* StringNIComp() [3.6] ***************************************
*
* NAME
*    StringNIComp()
*
* SYNOPSIS
*    int result = StringNIComp( char *str1, char *str2, int length );
*
* DESCRIPTION
*    Compare two strings without Case-sensitivity up to length chars
********************************************************************
*
*/

PUBLIC int StringNIComp( char *str1, char *str2, int length )
{
   return (strnicmp( str1, str2, length ) );
}

/****h* StringIComp() [3.6] ****************************************
*
* NAME
*    StringIComp()
*
* SYNOPSIS
*    int result = StringIComp( char *str1, char *str2 );
*
* DESCRIPTION
*    Compare two strings without Case-sensitivity
********************************************************************
*
*/

PUBLIC int StringIComp( char *str1, char *str2 )
{
   return( stricmp( str1, str2 ) );
}

/****h* SubString() [3.6] *****************************************
*
* NAME
*    SubString()
*
* SYNOPSIS
*    char *sub = SubString( char *str, char *end );
*
* DESCRIPTION
*    This function returns the partial string starting at *str &
*    ending at *end.
*
* WARNING
*    The buffer that this function uses is limited to BUFF_SIZE (512)
*    in StringFunctions.h.  Anything larger will result in a 
*    truncated answer.
********************************************************************
*
*/

# ifndef  BUFF_SIZE
#  define BUFF_SIZE 512
# endif

PRIVATE char gssBuff[ BUFF_SIZE ];

PUBLIC char *SubString( char *str, char *end )
{
   LONG start  = (LONG) str;
   LONG length = 0, i = 0;
   
   gssBuff[0] = '\0';

   if (!str || !end)
      return( &gssBuff[0] );

   length = (LONG) end - start;

   if (strlen( str ) < 1)
      return( &gssBuff[0] ); // Just in case

   while ((*(str + i) != '\0') && (&str[i] != end) && (i < BUFF_SIZE))
      {
      gssBuff[ i ] = *(str + i);

      i++;
      }

   gssBuff[i] = '\0';

   return( &gssBuff[0] );
}

/****h* StringCat() [3.6] ******************************************
*
* NAME
*    StringCat()
*
* SYNOPSIS
*    char *result = StringCat( char *string1, char *string2 );
*
* DESCRIPTION
*    Appends the contents of string2 to the contents of string1.
*
* INPUTS
*    string1 - string being appended to.
*    string2 - string to append.
********************************************************************
*
*/

PUBLIC char *StringCat( char *string1, char *string2 )
{
   (void) strcat( string1, string2 );

   return( string1 );
}

/****h* StringNCat() [3.6] *****************************************
*
* NAME
*    StringNCat()
*
* SYNOPSIS
*    char *result = StringNCat( char *string1, char *string2, int maxSize )
*
* DESCRIPTION
*    Appends the contents of string2 to the contents of string1.
*
* INPUTS
*    string1 - string being appended to.
*    string2 - string to append.
*    maxSize - maximum length of string1.
********************************************************************
*
*/

PUBLIC char *StringNCat( char *string1, char *string2, int maxSize )
{
   return( (char *) strncat( string1, string2, maxSize ) );
}

/****h* RemoveSubString() [3.6] ************************************
*
* NAME
*    RemoveSubString()
*
* DESCRIPTION
*    Removes the number of characters specified starting at the 
*    character location contained in first from the contents.
*
* SYNOPSIS
*    int chk = RemoveSubString( char *string, int first, int num_char )
*
* INPUTS
*    string   - contains the characters to delete.
*    first    - location (indexed) of 1st character to delete.
*    num_char - number of characters to delete.
*
* RETURNS
*    integer RETURN_OK or (-1) if error.
********************************************************************
*
*/

PUBLIC int RemoveSubString( char *delstr, int first, int num_char )
{
   int length, index1, index2;    /* index1 = start point */

   if (!delstr)
      return( -1 );
      
   if ((length = StringLength( delstr )) < 1)
      return( -1 );

   if (length == 1 && first == 1 && num_char == 1)  
      {
      *(delstr + 1) = *(delstr + 1);

      return( RETURN_OK );
      }

   if (first >= length || first < 0)
      return( -1 );

   if (first + num_char <= length)
      index2 = first + num_char;  // index2 is the end point
   else
      index2 = length;

   for (index1 = first; *(delstr + index1) = *(delstr + index2); index1++)
      index2++;

   index2 = StringLength( delstr );

   if (*(delstr + index2 + 1) != '\0')
       *(delstr + index2 + 1) = '\0';

   return( RETURN_OK );
}

/****h* UpperCase() [3.6] ************************************
*
* NAME
*    UpperCase()
*
* DESCRIPTION
*    Convert the input string into all UpperCase Letters.
*
* SYNOPSIS
*    char *result = UpperCase( char *inputString );
*
* INPUTS
*    inputString - contains the characters to convert (if any).
********************************************************************
*
*/

PUBLIC char *UpperCase( char *inputString )
{
   int i, len = StringLength( inputString );
   
   i = 0;
   while (i < len)
      {
      if (islower( *(inputString + i) ) == TRUE)
         *(inputString + i) = toupper( *(inputString + i) ); // - 0x20;
      
      i++;
      }
      
   return( inputString );
}

/****h* LowerCase() [3.6] ************************************
*
* NAME
*    LowerCase()
*
* DESCRIPTION
*    Convert the input string into all LowerCase Letters.
*
* SYNOPSIS
*    char *result = LowerCase( char *inputString );
*
* INPUTS
*    inputString - contains the characters to convert (if any).
********************************************************************
*
*/

PUBLIC char *LowerCase( char *inputString )
{
   int i, len = StringLength( inputString );
   
   i = 0;

   while (i < len)
      {
      if (isupper( *(inputString + i) ) == TRUE)
         *(inputString + i) = tolower( *(inputString + i) ); // + 0x20;
      
      i++;
      }
      
   return( inputString );
}

/****h* StringIndex() [3.6] ****************************************
*
* NAME
*    StringIndex()
*
* DESCRIPTION
*    Returns the starting location of the substring in the string, 
*    or -1 if not found.
*
* SYNOPSIS
*    int location = StringIndex( char *string, char *subString );
*
* INPUTS
*    string    - contains the string to search for subString.
*    subString - string to look for. 
********************************************************************
*
*/

PUBLIC int StringIndex( char *string, char *substring )
{
   int i, j, k;

   for (i = 0; *(string + i) != '\0'; i++)
      {
      for (j = i, k = 0; *(substring + k) == *(string + j); k++,j++)
         {
         if (*(substring + k + 1) == '\0')
            return( i );
         }
      }

   return( -1 );
}

/****h* FindChar() [3.6] *****************************************
*
* NAME
*    FindChar()
*
* DESCRIPTION
*    Returns the location of the 1st occurence of the character
*    contained within the string, or -1 if the letter was
*    not found.
*
* SYNOPSIS
*    int location = FindChar( string, letter );
*
* INPUTS
*    string - pointer to the string to be examined.
*    letter - contains the character we are searching for.
*
* RETURNS
*    integer, or -1 if not found.
******************************************************************
*
*/

PUBLIC int FindChar( char *string, char letter )
{
   int location;

   if (!string || letter == '\0')
      return( -1 );
      
   for (location = 0; *(string + location) != '\0'; location++)
      {
      if (*(string + location) == letter)
         return( location );
      }

   return( -1 );
}

/****h* ReverseString() [3.6] ***********************************
*
* NAME
*    ReverseString()
*
* DESCRIPTION
*    Reverses a string in place.
*
* SYNOPSIS
*    char *result = ReverseString( string );
*
* INPUTS
*    string - contains the string to reverse
**********************************************************
*
*/

PUBLIC char *ReverseString( char *string )
{
   int   c;
   char  *temp, *copy = string;

   if (!string)
      return( NULL );
      
   temp = copy + strlen( copy ) - 1;

   while (copy < temp)   
      {
      c       = *copy;
      *copy++ = *temp;
      *temp-- = c;
      }

   return( string );
}

/****h* ReplaceChar() [3.6] ******************************************
*
* NAME
*    ReplaceChar()
*
* DESCRIPTION
*    Replaces each occurence of the character contained in old_char 
*    with the character contained in new_char.
*
* SYNOPSIS
*    char *result = ReplaceChar( char *string, char old_char, char new_char );
*
* INPUTS
*    string   - contains the string to examine
*    old_char - contains the character to replace.
*    new_char - contains the character to replace old_char with.
***********************************************************************
*
*/

PUBLIC char *ReplaceChar( char *string, char old_char, char new_char )
{
   char *rval = string;
   
   while (*string)   
      {
      if (*string == old_char)
         *string = new_char;

      string++;
      }

   return( rval );
}

#endif // __amigaos4__
 
/****h* GetUserString() [3.4] ******************************************
*
* NAME
*    GetUserString()
*
* DESCRIPTION
*    Ask the user to supply a string to the calling program, NULL if
*    the User Cancels or enters a string with zero length.
*
* SYNOPSIS 
*    char *string = GetUserString( struct Window *parentW, char *msg, char *title );
*
* INPUTS
*   parentW - Address of the parent window from the calling program.
*    msg     - Inform the User what string to enter (Keep it short!).
*    title   - Requester title string (Keep it short!).
*
* RESULTS
*    This function returns the string the User entered, NULL if there's
*    an ERROR or if the User did NOT enter a string.
*
* WARNINGS
*    This function uses functions located in link object -lstringfuncs
*    for gcc.
*    This function does NOT adjust the requester width if you enter 
*    either a long msg or title & will clip them.
*
* COPYRIGHT
*    GetUserString() Jan-31-2005(C) by J.T. Steichen
*
* NOTES
*    Program set up to compile with gcc & AmigaOS4 also.
*
*    $VER: GetUserString() 3.4 (Jan-31-2005) by J.T. Steichen
************************************************************************
*
*/

#define ID_UserString 	0
#define ID_OkayBt 	   1
#define ID_CancelBt 	   2
#define GUS_CNT		   3

#define GUS_STRING_GAD  GUSGadgets[ ID_UserString ]
#define GUS_STRING      StrBfPtr( GUS_STRING_GAD )
    
// ----------------------------------------------------

PRIVATE int UserStringClicked( void );
PRIVATE int OkayBtClicked(     void );
PRIVATE int CancelBtClicked(   void );

PRIVATE struct NewGadget GUSNGad[ GUS_CNT ] = {

    17,  48, 400,  20, "Please Enter a String:", NULL,
   ID_UserString, NG_HIGHLABEL | PLACETEXT_ABOVE, NULL, (APTR) UserStringClicked,

    17,  80,  80,  20, "_OKAY!", NULL,
   ID_OkayBt, PLACETEXT_IN, NULL, (APTR) OkayBtClicked,

   337,  80,  80,  20, "_CANCEL!", NULL,
   ID_CancelBt, PLACETEXT_IN, NULL, (APTR) CancelBtClicked,
};

PRIVATE struct Window *GUSWnd                = NULL;
PRIVATE struct Gadget *GUSGadgets[ GUS_CNT ] = { NULL, };
PRIVATE struct Gadget *GUSGList              = NULL;
PRIVATE APTR           GUSVisualInfo         = (APTR) NULL;

PRIVATE void CloseGUSWindow( void )
{
   if (GUSVisualInfo)
      {
      FreeVisualInfo( GUSVisualInfo );
      GUSVisualInfo = NULL;
      }

   if (GUSWnd)
      {
      CloseWindow( GUSWnd );
      GUSWnd = NULL;
      }

   if (GUSGList)
      {
      FreeGadgets( GUSGList );
      GUSGList = NULL;
      }

   return;
}

// ----------------------------------------------------------------

#define GUS_MAX_STRING_SIZE 1024

PRIVATE char GUS[ GUS_MAX_STRING_SIZE ] = { 0, };
    
#define GUS_GOT_STRING (TRUE+1)

PRIVATE int UserStringClicked( void )
{
   if (StringLength( GUS_STRING ) > 0)
      {
      StringNCopy( &GUS[0], GUS_STRING, GUS_MAX_STRING_SIZE );

      CloseGUSWindow();
   
      return( GUS_GOT_STRING );
      }
   else
      return( TRUE );
}

PRIVATE int OkayBtClicked( void )
{
   int rval = FALSE;
   
   if (StringLength( GUS_STRING ) > 0)
      {
      StringNCopy( &GUS[0], GUS_STRING, GUS_MAX_STRING_SIZE );
      
      rval = GUS_GOT_STRING;
      }
   
   CloseGUSWindow();

   return( rval );
}

PRIVATE int CancelBtClicked( void )
{
   CloseGUSWindow();
      
   return( FALSE );
}

PRIVATE int OpenGUSWindow( struct Window *parent, UBYTE *wTitle )
{
   struct Screen    *GUSScr = NULL;
   struct NewGadget  ng;
   struct Gadget    *g;

   UWORD             GUSWidth  = 435;
   UWORD             GUSHeight = 115;

   UWORD GUSGTypes[ GUS_CNT ] = {

         STRING_KIND, BUTTON_KIND, BUTTON_KIND
   };

   ULONG GUSGTags[] = {

       GTST_MaxChars, GUS_MAX_STRING_SIZE, TAG_DONE,

       GT_Underscore, '_', TAG_DONE,

       GT_Underscore, '_', TAG_DONE
   };

   UWORD             lc, tc;
   UWORD             wleft, wtop, ww, wh;

   // --------------------- CODE Begins: -------------------------------------
   
   if (!parent)
      return( RETURN_ERROR );
   else
      GUSScr = parent->WScreen;

   if (!(GUSVisualInfo = GetVisualInfo( GUSScr, TAG_DONE )))
      return( RETURN_FAIL );
            
   ww = GUSWidth;
   wh = GUSHeight;

   wleft = (GUSScr->Width  - GUSWidth ) / 2;
   wtop  = (GUSScr->Height - GUSHeight) / 2;

   if (!(g = CreateContext( &GUSGList )))
      return( -1 );

   for (lc = 0, tc = 0; lc < GUS_CNT; lc++)
      {
      CopyMem( (char *) &GUSNGad[ lc ], (char *) &ng,
               (long) sizeof( struct NewGadget )
             );

      ng.ng_VisualInfo = GUSVisualInfo;
      ng.ng_TextAttr   = GUSScr->Font;

      GUSGadgets[ lc ] = g
                       = CreateGadgetA( (ULONG) GUSGTypes[ lc ],
                                        g,
					&ng,
                                        (struct TagItem *) &GUSGTags[ tc ]
                                      );

      while (GUSGTags[ tc ] != TAG_DONE)
         tc += 2;

      tc++;

      if (!g)
         return( -2 );
      }

   if (!(GUSWnd = OpenWindowTags( NULL,

         WA_Left,          wleft,
         WA_Top,           wtop,
         WA_Width,         ww,
         WA_Height,        wh,
	      WA_IDCMP,         STRINGIDCMP | BUTTONIDCMP | IDCMP_VANILLAKEY | IDCMP_REFRESHWINDOW,
	      WA_Flags,         WFLG_ACTIVATE | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_RMBTRAP,
	      WA_Gadgets,       GUSGList,
         WA_Title,         wTitle,
         WA_CustomScreen,  GUSScr,
         TAG_DONE )))
      {
      return( -4 );
      }

   GT_RefreshWindow( GUSWnd, NULL );

   return( 0 );
}

PRIVATE int GUSVanillaKey( int whichKey )
{
   int rval = TRUE;

   switch (whichKey)
      {
      case 'o':
      case 'O':
         rval = OkayBtClicked();
         break;

      case 'c':
      case 'C':
         rval = CancelBtClicked();
         break;

      default:
         break;
      }

   return( rval );
}

PRIVATE int HandleGUSIDCMP( void )
{
   struct IntuiMessage *m;
   int                (*func)( void );
   BOOL                 running = TRUE;

   while (running == TRUE)
      {
      if (!(m = GT_GetIMsg( GUSWnd->UserPort )))
         {
         (void) Wait( 1L << GUSWnd->UserPort->mp_SigBit );

         continue;
         }

      switch (m->Class)
         {
        case IDCMP_GADGETUP:
           if ((func = (int (*)( void )) ((struct Gadget *) m->IAddress)->UserData))
              running = func();

           break;

        case IDCMP_VANILLAKEY:
           running = GUSVanillaKey( m->Code );
           break;

        case IDCMP_REFRESHWINDOW:
           GT_BeginRefresh( GUSWnd );
           GT_EndRefresh( GUSWnd, TRUE );

           break;
         }

      GT_ReplyIMsg( m );
      }

   return( running );
}

PUBLIC char *GetUserString( struct Window *parentW, char *msg, char *title )
{
   char *userString = NULL;
   int    error      = RETURN_OK;

   // Set the default gadget texts...
	pvSetupCatalog();

   GUSNGad[0].ng_GadgetText = CFMsg( MSG_GAD_STRGAD,    MSG_GAD_STRGAD_STR    ); // "Please Enter a String:"
   GUSNGad[1].ng_GadgetText = CFMsg( MSG_GAD_OKAY_BT,   MSG_GAD_OKAY_BT_STR   ); // "_OKAY!"
   GUSNGad[2].ng_GadgetText = CFMsg( MSG_GAD_CANCEL_BT, MSG_GAD_CANCEL_BT_STR ); // "_CANCEL!"
	
   if (StringLength( msg ) > 0)
      GUSNGad[ ID_UserString ].ng_GadgetText = msg;
      
   if ((error = OpenGUSWindow( parentW, (UBYTE *) title )) != RETURN_OK)
      {
      return( userString ); // NULL returned on error!
      }
      
   SetNotifyWindow( GUSWnd );

   if ((error = HandleGUSIDCMP()) == GUS_GOT_STRING)
      userString = &GUS[0]; // User entered something for us to use.

   // GUSWnd already closed when we get here.

   SetNotifyWindow( parentW );

   pvCloseCatalog(); // If necessary
	      
   return( userString );
}

// ---------------- END of GetUserString() code! --------------------

/****h* TrimSpaces() [3.21] *****************************************
*
* NAME
*    TrimSpaces()
*
* SYNOPSIS
*    char *newString = TrimSpaces( char *oldString );
*
* DESCRIPTION
*    Removes Trailing & Leading spaces from oldString & returns the
*    result as newString.
*********************************************************************
*
*/

PUBLIC char *TrimSpaces( char *string )
{
   char *temp = string;
   int    len;
   
   if (!string)
      return( string ); // No point in going further with a NULL string!
      
   len = StringLength ( string );

   while (len > 0)   
      {  
      if (*(string + len) == '_' || isalnum( *(string + len) ))	
         break;     // found the real end of the string!

      else if (*(string + len) == ' ' || *(string + len) == '\t' 
                                      || *(string + len) == '\n')
         *(string + len) = '\0';
	 
      len--;
      }            // Trailing spaces all gone!!
   
   string = temp; // Restore the string pointer (if necessary)

   while (*string != '\0' && (*string == ' ' || *string == '\t' 
                                             || *string == '\n'))
      string++; // skip over leading spaces as well!
      
   return( string );
}

/****h* OpenFile() [3.2] ********************************************
*
* NAME
*    OpenFile()
*
* SYNOPSIS
*    FILE *fPtr = OpenFile( char *fileName, char *fileMode );
*
* DESCRIPTION
*    Improvement to the fopen() function in that OpenFile() first
*    checks that the arguments are valid, then calls fopen().
*
* WARNINGS
*    For the Amiga file system, spaces in a fileName are significant &
*    any leading or trailing spaces inadvertently contained in the 
*    fileName could lead to a failure of the fopen() function.
*    Since leading or trailing spaces are usually of no significance,
*    they are first removed BEFORE calling fopen().  If you wish to
*    open a file with leading or trailing spaces in the fileName,
*    DO NOT use this function.
*********************************************************************
*
*/

PUBLIC FILE *OpenFile( char *fileName, char *fileMode )
{
   FILE *filePointer = (FILE *) NULL;
   
   if ( !fileName || !fileMode )
      goto exitOpenFile;
      
   if (StringLength( fileName ) < 1 || StringLength( fileMode ) < 1)
      goto exitOpenFile;

   filePointer = fopen( TrimSpaces( fileName ), fileMode );
         
exitOpenFile:

   return( filePointer );      
}

/****h* IsMenuChecked() [3.1] ***************************************
*
* NAME
*    IsMenuChecked()
*
* SYNOPSIS
*    BOOL result = IsMenuChecked( struct MenuItem *m );
*
* DESCRIPTION
*    Returns TRUE if m is Checked, FALSE otherwise.
*********************************************************************
*
*/

PUBLIC BOOL IsMenuChecked( struct MenuItem *m )
{
   BOOL rval = FALSE;

   if ((m->Flags & CHECKED) == CHECKED)
      rval = TRUE;
      
   return( rval );
}

/****h* IsGadgetSelected() [3.1] ************************************
*
* NAME
*    IsGadgetSelected()
*
* SYNOPSIS
*    BOOL result = IsGadgetSelected( struct Gadget *g );
*
* DESCRIPTION
*    Returns TRUE if g is selected/checked, FALSE otherwise.
*********************************************************************
*
*/

PUBLIC BOOL IsGadgetSelected( struct Gadget *g )
{
   BOOL rval = FALSE;
   
   if ((g->Flags & GFLG_SELECTED) == GFLG_SELECTED)
      rval = TRUE;
      
   return( rval );
}

#ifdef __amigaos4__
PRIVATE void closeALib( struct Library *base, struct Interface *iface )
{
   if (iface)
      {
      DropInterface( iface );
      iface = NULL;
      }
#  else
PRIVATE void closeALib( struct Library *base )
{
#  endif
   if (base)
      {
      CloseLibrary( base );
      base = NULL;
      }
      
   return;
}

#ifndef __amigaos4__
PRIVATE BOOL openALib( struct Library *base, char *libName, long int version )
{
   BOOL rval = FALSE;
   
   // Don't open the library base twice!
   if (!base)
      {
      if ((base = OpenLibrary( libName, version )))
         {
         rval = TRUE;
         }
      }

   return( rval );
}
#endif

/****h* CloseLibs() [1.0] *******************************************
*
* NAME
*    CloseLibs()
*
* SYNOPSIS
*    void CloseLibs( void );
*
* DESCRIPTION
*    Close the three most-commonly used libraries - 
*
*       intuition.library, graphics.library & gadtools.library.
*********************************************************************
*
*/

PRIVATE BOOL openedIntuitionLib = FALSE;
PRIVATE BOOL openedGraphicsLib  = FALSE;
PRIVATE BOOL openedGadToolsLib  = FALSE;
PRIVATE BOOL openedLocaleLib    = FALSE;

#ifndef __amigaos4__
PUBLIC void CloseLibs( void )
#else
PRIVATE void CloseLibs( void )
#endif
{
#  ifdef __amigaos4__
   if (openedIntuitionLib == TRUE)
      {
      closeALib( IntuitionBase, (struct Interface *) IIntuition );
      openedIntuitionLib = FALSE;
      }

   if (openedGraphicsLib == TRUE)
      {
      closeALib( GfxBase, (struct Interface *) IGraphics  );
      openedGraphicsLib = FALSE;
      }

   if (openedGadToolsLib == TRUE)
      {
      closeALib( GadToolsBase,  (struct Interface *) IGadTools  );
      openedGadToolsLib = FALSE;
      }

   if (openedLocaleLib == TRUE)
      {
      closeALib( LocaleBase, (struct Interface *) ILocale );
      openedLocaleLib = FALSE;
      }

#  else
   closeALib( (struct Library *) IntuitionBase );
   closeALib( (struct Library *) GfxBase       );
   closeALib( (struct Library *) GadToolsBase  );
   closeALib( (struct Library *) LocaleBase    );
#  endif
      
   return;
}

#ifdef  __amigaos4__
PRIVATE int OpenIntuitionLib( void )
{
   if (!IntuitionBase)
      {
      if ((IntuitionBase = OpenLibrary( "intuition.library", 50L )))
         {
         if (!(IIntuition = (struct IntuitionIFace *) GetInterface( IntuitionBase, "main", 1, NULL )))
            {
            CloseLibrary( IntuitionBase );
         
	         openedIntuitionLib = FALSE;

	         return( -1 );
	         }
	      else
	         openedIntuitionLib = TRUE;
         }
      else
         {
         openedIntuitionLib = FALSE;
         
	      return( -1 );
	      }
      }
   else
	   openedIntuitionLib = FALSE;
		
   return( RETURN_OK );
}
#else

PRIVATE int OpenIntuitionLib( void )
{
   if (!IntuitionBase)
      {
      if ((IntuitionBase = OpenLibrary( "intuition.library", 39L )))
         openedIntuitionLib = TRUE;
      else
         {
         openedIntuitionLib = FALSE;
         
	      return( -1 );
	      }
      }

   return( RETURN_OK );
}

#endif // __amigaos4__

/****h* OpenLibs() [1.0] ********************************************
*
* NAME
*    OpenLibs()
*
* SYNOPSIS
*    int result = OpenLibs( void );
*
* DESCRIPTION
*    Open the four most-commonly used libraries (V39+) - 
*
*       intuition.library, graphics.library, gadtools.library &
*       locale.library.
*
* RETURN VALUE
*    Negative integer if a library could NOT be opened, zero if
*    all was successful.
*********************************************************************
*
*/

#ifdef  __SASC
PUBLIC int OpenLibs( void )
#else
PRIVATE int OpenLibs( void )
#endif
{
#  ifndef __amigaos4__
   if (openALib( (struct Library *) IntuitionBase, "intuition.library", 39L ) == FALSE)
      return( -1 );

   if (openALib( (struct Library *) GfxBase, "graphics.library", 39L ) == FALSE)
      {
      CloseLibs();
      
      return( -2 );
      }

   if (openALib( GadToolsBase, "gadtools.library", 39L ) == FALSE)
      {
      CloseLibs();

      return( -3 );
      }

   if (!LocaleBase)
	   {
      if (openALib( (struct Library *) LocaleBase, "locale.library", 39L ) == FALSE)
         {
         CloseLibs();

         return( -4 );
         }
		}
#  else
   /* For some reason, gcc does not return pointer arguments in the function call to 
   ** openALib(), so consequently we have to roll the openALib() code into this function
   ** & do it explicitly:
   */
   if (!IntuitionBase)
      {
      if ((IntuitionBase = OpenLibrary( "intuition.library", 50L )))
         {
         if (!(IIntuition = (struct IntuitionIFace *) GetInterface( IntuitionBase, "main", 1, NULL )))
            {
            CloseLibrary( IntuitionBase );
         
  	         openedIntuitionLib = FALSE;

	         return( -1 );
	         }
	      else
	         openedIntuitionLib = TRUE;
         }
      else
         {
         openedIntuitionLib = FALSE;
         
	      return( -1 );
	      }
      }
   else
	   openedIntuitionLib = FALSE;

   if (!GfxBase)
      {
      if ((GfxBase = OpenLibrary( "graphics.library", 50L )))
         {
         if (!(IGraphics = (struct GraphicsIFace *) GetInterface( GfxBase, "main", 1, NULL )))
            {
            CloseLibs();

	         openedGraphicsLib = FALSE;
      
            return( -2 );
            }
	      else
	         openedGraphicsLib = TRUE;
         }
      else
         {
         CloseLibs();

         openedGraphicsLib = FALSE;
      
         return( -2 );
         }
      }
   else
	   openedGraphicsLib = FALSE;

   if (!GadToolsBase)
      {
      if ((GadToolsBase = OpenLibrary( "gadtools.library", 50L )))
         {
         if (!(IGadTools = (struct GadToolsIFace *) GetInterface( GadToolsBase, "main", 1, NULL )))
            {
            CloseLibs();
      
	         openedGadToolsLib = FALSE;

            return( -3 );
            }
         else
	         openedGadToolsLib = TRUE;
         }
      else
         {
         CloseLibs();
      
         openedGadToolsLib = FALSE;

         return( -3 );
         }
      }
   else
	   openedGadToolsLib = FALSE;
		
   if (!LocaleBase)
      {
      if ((LocaleBase = OpenLibrary( "locale.library", 50L )))
         {
         if (!(ILocale = (struct LocaleIFace *) GetInterface( LocaleBase, "main", 1, NULL )))
            {
            CloseLibs();
      
	         openedLocaleLib = FALSE;

            return( -4 );
            }
         else
	         openedLocaleLib = TRUE;
         }
      else
         {
         CloseLibs();
      
         openedLocaleLib = FALSE;

         return( -4 );
         }
      }
	else
	   openedLocaleLib = FALSE;
		
#  endif

   return( 0 );
}

/****i* closeASLLib() ***************************************************
*
* NAME
*    closeASLLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE void closeASLLib( void )
{
#  ifdef __amigaos4__
   closeALib( AslBase, (struct Interface *) IAsl );
#  else
   closeALib( AslBase );
#  endif

   return;
}

/****i* openASLLib() ****************************************************
*
* NAME
*    openASLLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE int openASLLib( void )
{
   if (!AslBase)
      {
#     ifndef __amigaos4__
      if (openALib( AslBase, AslName, 37L ) == FALSE)
         {
         return( ERROR_INVALID_RESIDENT_LIBRARY ); 
         }
#     else
      if ((AslBase = OpenLibrary( AslName, 50L )))
         {
	      if (!(IAsl = (struct AslIFace *) GetInterface( AslBase, "main", 1, NULL )))
	         {
	         CloseLibrary( AslBase );

	         AslBase = NULL;

            return( ERROR_INVALID_RESIDENT_LIBRARY );
            }
	      }
      else
         return( ERROR_INVALID_RESIDENT_LIBRARY );
#     endif
      }

   return( RETURN_OK );
}

/****i* closeIconLib() ***************************************************
*
* NAME
*    closeIconLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE void closeIconLib( void )
{
#  ifdef __amigaos4__
   closeALib( IconBase, (struct Interface *) IIcon );
#  else
   closeALib( IconBase );
#  endif

   return;
}

/****i* openIconLib() ***************************************************
*
* NAME
*    openIconLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE int openIconLib( void )
{
   if (!IconBase)
      {
#     ifndef __amigaos4__
      if (openALib( IconBase, "icon.library", 37L ) == FALSE)
         {
         return( ERROR_INVALID_RESIDENT_LIBRARY ); 
         }
#     else
      if ((IconBase = OpenLibrary( "icon.library", 50L )))
         {
	      if (!(IIcon = (struct IconIFace *) GetInterface( IconBase, "main", 1, NULL )))
	         {
            CloseLibrary( IconBase );
	         IconBase = NULL;
            return( ERROR_INVALID_RESIDENT_LIBRARY );
            }
	      }
      else
         return( ERROR_INVALID_RESIDENT_LIBRARY );
#     endif
      }

   return( RETURN_OK );
}

/****i* closeUtilityLib() ***********************************************
*
* NAME
*    closeUtilityLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE void closeUtilityLib( void )
{
#  ifdef __amigaos4__
   closeALib( UtilityBase, (struct Interface *) IUtility );
#  else
   closeALib( UtilityBase );
#  endif

   return;
}

/****i* openUtilityLib() ****************************************************
*
* NAME
*    openUtilityLib( void )
*
* DESCRIPTION
*    gcc & AmigaOS4 require the explicit opening & closing of this
*    library.
*************************************************************************
*
*/

PRIVATE int openUtilityLib( void )
{
   if (!UtilityBase) // == NULL)
      {
#     ifndef __amigaos4__
      if (openALib( UtilityBase, "utility.library", 37L ) == FALSE)
         {
         return( ERROR_INVALID_RESIDENT_LIBRARY ); 
         }
#     else
      if ((UtilityBase = OpenLibrary( "utility.library", 50L ))) // != NULL
         {
	 if (!(IUtility = (struct UtilityIFace *) GetInterface( UtilityBase, "main", 1, NULL ))) // == NULL
	    {
	    CloseLibrary( UtilityBase );
	    UtilityBase = NULL;
            return( ERROR_INVALID_RESIDENT_LIBRARY );
            }
	 }
      else
         return( ERROR_INVALID_RESIDENT_LIBRARY );
#     endif
      }

   return( RETURN_OK );
}

// ----------------------------------------------------------------------

/****h* strClear() ******************************************************
*
* NAME
*    strClear()
*
* SYNOPSIS
*    void strClear( char *string );
*
* DESCRIPTION
*    Reset a strings's contents to all nils.
*
* INPUTS
*    string - The string to clear out.
*************************************************************************
*
*/

PUBLIC void strClear( char *str )
{
   int i, len = StringLength( str );
   
   for (i = 0; i < len; i++)
      *(str + i) = '\0';
      
   return;
}

PRIVATE BOOL checkForLibs( void )
{
   BOOL rval = TRUE;
   
   if (!IntuitionBase)
      {
      rval = FALSE;
      
      goto exitCheckForLibs;
      }
      
   if (!GfxBase)
      {
      rval = FALSE;
      
      goto exitCheckForLibs;
      }
      
   if (!GadToolsBase)
      {
      rval = FALSE;
      
      goto exitCheckForLibs;
      }

#  ifdef __amigaos4__
   if (!IIntuition)
      {
      rval = FALSE;
      
      goto exitCheckForLibs;
      }

   if (!IGraphics)
      {
      rval = FALSE;
      
      goto exitCheckForLibs;
      }
      
   if (!IGadTools)
      rval = FALSE;
#  endif
      
exitCheckForLibs:

   return( rval );
}

/****h* drawArc() *******************************************************
*
* NAME
*    drawArc()
*
* SYNOPSIS
*    void drawArc( struct Window *w, int xs, int ys, float angle, int xc, int yc ); 
*
* DESCRIPTION
*    Draw an Arc into the given Window using graphics functions.
*
* INPUTS
*    Xs    - starting Window Horizontal coordinate. 
*    Ys    - starting Window Vertical   coordinate. 
*    angle - the length of the arc in radians. 
*    Xc    - the Horizontal coordinate of the arc pivot point.
*    Yc    - the Vertical   coordinate of the arc pivot point.
*
* WARNINGS
*    Set the drawing Pen(s), draw Mode & Line Pattern BEFORE using this.
*************************************************************************
*
*/

PRIVATE const double TWO_PI = PI * 2.0;
PRIVATE const double PI_180 = PI / 180.0;

PUBLIC void drawArc( struct Window *w, int Xs, int Ys, 
                     float arcAngle,   int Xc, int Yc
                   )
{
   double xs, ys, xc, yc, angle, radius;
   BOOL   openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return;
      else
         openedLibs = TRUE;
      }
           
   if (w) // != NULL)
      {
      xs    = (double) Xs;
      ys    = (double) Ys;
      angle = (double) arcAngle;
      xc    = (double) Xc;
      yc    = (double) Yc;

      if (fabs( angle ) >= TWO_PI)
         {
         double xr, yr;
   
         xr     = fabs( xs - xc );
         yr     = fabs( ys - yc );
         radius = sqrt( xr * xr + yr * yr );

         DrawCircle( w->RPort, Xc, Yc, (int) radius );
         }
      else if (angle < 0)
         {
         double ax, ay;
         int    i; 
                  
         Move( w->RPort, Xs, Ys );

         for (i = 0; i > -360; i--)          
            {
            double tx, ty;
            
            tx = xs - xc;
            ty = ys - yc;
            
            ax = tx * cos( i * PI_180 ) - ty * sin( i * PI_180 );
            ay = tx * sin( i * PI_180 ) + ty * cos( i * PI_180 );
            
            tx = ax + xc;
            ty = ay + yc;
            
            Draw( w->RPort, (int) tx, (int) ty );

            if (fabs( ((double) i) * PI_180 ) > angle)
               break;
            }
         }
      else
         {
         double ax, ay;
         int    i; 

         Move( w->RPort, Xs, Ys );

         for (i = 0; i < 360; i++)          
            {
            double tx, ty;
            
            tx = xs - xc;
            ty = ys - yc;
            
            ax = tx * cos( i * PI_180 ) - ty * sin( i * PI_180 );
            ay = tx * sin( i * PI_180 ) + ty * cos( i * PI_180 );
            
            tx = ax + xc;
            ty = ay + yc;
            
            Draw( w->RPort, (int) tx, (int) ty );

            if (((double) i) * PI_180 > angle)
               break;
            }
         }
      }

   if (openedLibs == TRUE)
      CloseLibs();
      
   return;
}

/****h* getUserFont() ***************************************************
*
* NAME
*    getUserFont()
*
* SYNOPSIS
*    struct TextAttr *font = getUserFont( struct TagItem *taglist, 
*                                         struct Screen  *screen,
*                                         char           *req_title
*                                       ); 
*
* DESCRIPTION
*    Obtain a user-selected (via ASL) Font.  A NULL value for the FONT
*    is returned if you press & release the Cancel Gadget on the 
*    Requester.
*
* WARNINGS
*    Store the result BEFORE the next call to getUserFont()!!
*************************************************************************
*
*/

// Needed because CloseLibrary( AslBase ) will kill the fontName space:

PRIVATE char           fname[80] = { 0, };
PRIVATE struct TextAttr userFont  = { &fname[0], 0, };
    
PUBLIC struct TextAttr *getUserFont( struct TagItem *taglist, 
                                     struct Screen  *scr,
                                     char           *title 
                                   )
{
   struct FontRequester *fr      = NULL;
   struct TextAttr      *rval    = &userFont;
   BOOL                  result  = FALSE;
   BOOL                  libflag = FALSE;
   BOOL                  openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return( rval );
      else
         openedLibs = TRUE;
      }
   
   if (!scr)
      {
      scr = GetActiveScreen(); // Bonehead programmer!
      }

#  ifdef __amigaos4__
   if (openUtilityLib() == RETURN_OK)
      {
#  endif
      
      if (FindTagItem( ASLFO_Screen, taglist ) == NULL)
         {
#        ifdef __amigaos4__
         closeUtilityLib();
#        endif
         goto exitGetUserFont; // Missing the ONLY necessary tag!
         }
      else
         SetTagItem( taglist, ASLFO_Screen, (ULONG) scr );

      if (FindTagItem( ASLFO_TitleText, taglist ) != NULL)
         SetTagItem( taglist, ASLFO_TitleText, (ULONG) title );

#  ifdef __amigaos4__
      closeUtilityLib();
      }
   else
      goto exitGetUserFont;
#  endif
                  
   if (openASLLib() == RETURN_OK)
      libflag = TRUE;
   else
      goto exitGetUserFont;
      
   fr = (struct FontRequester *) AllocAslRequest( ASL_FontRequest, NULL );

   if (fr) // != NULL)
      {
      result = AslRequest( fr, taglist );

      if (result != 0) // != NULL)
         {
         // Got a groovy answer:
         StringNCopy( rval->ta_Name, fr->fo_Attr.ta_Name, 80 );

         rval->ta_YSize = fr->fo_Attr.ta_YSize;
         rval->ta_Style = fr->fo_Attr.ta_Style;
         rval->ta_Flags = fr->fo_Attr.ta_Flags;
         } 
      else
         {
         if (IoErr() == 0)
            rval =  NULL; // User pressed the Cancel Gadget.
         }
            
      FreeAslRequest( fr );
      }
   else                   // No FontRequester!
      {
      if (libflag != FALSE)
         closeASLLib();

      goto exitGetUserFont;
      }

exitGetUserFont:

   if (openedLibs == TRUE)
      CloseLibs();

   if (result != 0) // != NULL)
      return( rval );
   else
      return( NULL );
}

/****h* CFFindMenuPtr() *************************************************
*
* NAME
*    CFFindMenuPtr()
*
* DESCRIPTION
*    Return a pointer to a menu item that has the given title.
*
* HISTORY
*    24-Jan-2005 - Changed the calls to strcmp() to StringComp(), 
*                  which is in libstringfuncs.a
*************************************************************************
*
*/

PUBLIC void *CFFindMenuPtr( struct Menu *menustrip, char *searchForMI )
{
   struct Menu     *mp   = menustrip;
   struct MenuItem *mi   = mp->FirstItem;
   struct MenuItem *sub  = mi->SubItem;
   void            *rval = NULL;

   while (mp) // != NULL)
      {
      mi = mp->FirstItem;
      
      if (StringComp( mp->MenuName, searchForMI ) == 0)
         {
         rval = (void *) mp;

         goto ExitCFFindMenuPtr;
         }
      
      while (mi) // != NULL)
         {
         sub = mi->SubItem;
         
         if (StringComp( ((struct IntuiText *) mi->ItemFill)->IText, searchForMI ) == 0)
            {
            rval = (void *) mi;

            goto ExitCFFindMenuPtr;
            }
            
         while (sub) // != NULL)
            {
            if (StringComp( ((struct IntuiText *) sub->ItemFill)->IText, searchForMI ) == 0)
               {
               rval = (void *) sub;

               goto ExitCFFindMenuPtr;
               }
            
            sub = sub->NextItem;
            }
         
         mi = mi->NextItem;
         }
         
      mp = mp->NextMenu;
      }

ExitCFFindMenuPtr:

   return( rval );
}

#ifndef itoa

PRIVATE void reverse( char *string )
{
   int   c;
   char *temp;

   temp = string + StringLength( string ) - 1;
   
   while (string < temp)
      {
      c         = *string;
      *string++ = *temp;
      *temp--   = c;
      }   

   return;
}

/****h* itoa() **********************************************************
*
* NAME
*    itoa()
*
* SYNOPSIS
*    void itoa( int convertMe, char *stringbuffer );
*
* DESCRIPTION
*    convert an decimal integer to a string.
*
* WARNINGS
*    Make sure that stringbuffer is at least 20 characters long!
*************************************************************************
*
*/

PUBLIC void itoa( int convertMe, char *string )
{
#  ifdef SASC_650
#   ifndef _STRICT_ANSI
    (void) stci_d( string, convertMe );
   
    return;

#   else
    int  sign;
    char *ptr = string;

    if ((sign = convertMe) < 0)
       convertMe = - convertMe;

    do {
       *ptr++ = convertMe % 10 + '0';
       
       } while ((convertMe = convertMe / 10) > 0);       

    if (sign < 0)
       *ptr++ = '-';

    *ptr = '\0';
    
    reverse( string );
    return;
#   endif  // _STRICT_ANSI

#  else

   int  sign;
   char *ptr = string;

   if ((sign = convertMe) < 0)
      convertMe = - convertMe;

   do {
      *ptr++ = convertMe % 10 + '0';
       
      } while ((convertMe = convertMe / 10) > 0);       

   if (sign < 0)
      *ptr++ = '-';

   *ptr = '\0';
    
   reverse( string );
   return;
#  endif // SASC_650
}

#endif // itoa

/****h* SetupList() *****************************************************
*
* NAME
*    SetupList()
*
* SYNOPSIS
*    void SetupList( struct List *lst, struct ListViewMem *lvm );
*
* DESCRIPTION
*    Initialize a List structure for a ListView Gadget.
*************************************************************************
*
*/

PUBLIC void SetupList( struct List *list, struct ListViewMem *lvm )
{
   int i, len = lvm->lvm_NodeLength;

   if ( !list || !lvm )
      return;
      
   if (lvm->lvm_NumItems < 256)
      {
      // We can prioritize the nodes:
      for (i = 0; i < lvm->lvm_NumItems; i++)
         {
         lvm->lvm_Nodes[i].ln_Name = (STRPTR) &lvm->lvm_NodeStrs[ i * len ];
         lvm->lvm_Nodes[i].ln_Pri  = lvm->lvm_NumItems - i - 129;
         lvm->lvm_Nodes[i].ln_Type = NT_USER;
         }

      NewList( list );

      for (i = 0; i < lvm->lvm_NumItems; i++)
         Enqueue( list, &(lvm->lvm_Nodes[i]) );
      }
   else
      {
      // Too many nodes to use priorities:
      for (i = 0; i < lvm->lvm_NumItems; i++)
         {
         lvm->lvm_Nodes[i].ln_Name = (STRPTR) &lvm->lvm_NodeStrs[ i * len ];
         lvm->lvm_Nodes[i].ln_Pri  = 0;
         lvm->lvm_Nodes[i].ln_Type = NT_USER;
         }

      NewList( list );

      for (i = 0; i < lvm->lvm_NumItems; i++)
         AddTail( list, &(lvm->lvm_Nodes[i]) );
      }

   return;
}

/****h* GetActiveWindow() [2.3] *****************************************
*
* NAME
*    GetActiveWindow()
*
* SYNOPSIS
*    struct Window *active = GetActiveWindow( void );
*
* DESCRIPTION
*    Return a pointer to the Active Window.
*************************************************************************
*
*/

PUBLIC struct Window *GetActiveWindow( void )
{
   struct Window *rval  = NULL;
   ULONG          ilock = 0L;
   BOOL           openedLib = FALSE;

   if (!IntuitionBase)
      {
      if (OpenIntuitionLib() != RETURN_OK)
         {
	      fprintf( stderr, CFMsg( MSG_FMT_NO_INTUITION_LIBRARY, MSG_FMT_NO_INTUITION_LIBRARY_STR ), "GetActiveWindow()" );

         return( rval );
	      }
      else
         openedLib = TRUE;
      }

   ilock = (ULONG) LockIBase( 0 );

#     ifndef __amigaos4__
      rval = IntuitionBase->ActiveWindow;
#     else
      rval = ((struct IntuitionBase *) IIntuition->Data.LibBase)->ActiveWindow;
#     endif

   UnlockIBase( ilock );

   if (openedLib == TRUE)
      CloseLibs();
         
   return( rval );     
}

/****h* GetActiveScreen() ***********************************************
*
* NAME
*    GetActiveScreen()
*
* SYNOPSIS
*    struct Screen *active = GetActiveScreen( void );
*
* DESCRIPTION
*    Return a pointer to the Active Screen.
*************************************************************************
*
*/

PUBLIC struct Screen *GetActiveScreen( void )
{
   struct Screen *rval  = NULL;
   ULONG          ilock = 0L;
   BOOL           openedLib = FALSE;

   if (!IntuitionBase)
      {
      if (OpenIntuitionLib() != RETURN_OK)
         {
	      fprintf( stderr, CFMsg( MSG_FMT_NO_INTUITION_LIBRARY, MSG_FMT_NO_INTUITION_LIBRARY_STR ), "GetActiveScreen()" );

         return( rval );
	      }
      else
         openedLib = TRUE;
      }

   ilock = (ULONG) LockIBase( 0 );

#     ifdef __amigaos4__
      rval = ((struct IntuitionBase *) IIntuition->Data.LibBase)->ActiveScreen;
//      fprintf( stderr, "rval = 0x%08LX in GetActiveScreen!\n", rval );
#     else
      rval = IntuitionBase->ActiveScreen;
#     endif
      
   UnlockIBase( ilock );

   if (openedLib == TRUE)
      {
//      fprintf( stderr, "closed Libraries in getActiveScreen()!\n" );
      CloseLibs();
      }

//   fprintf( stderr, "got Active Screen!\n" );
         
   return( rval );     
}

/****h* DisplayTitle() **************************************************
*
* NAME
*    DisplayTitle()
*
* SYNOPSIS
*    void DisplayTitle( struct Window *wptr, char *windowTitle );
*
* DESCRIPTION
*    Display the given text as a title for the given Window.
*
* NOTES
*    The title is silently limited to 79 characters in length.
*************************************************************************
*
*/

PUBLIC void DisplayTitle( struct Window *wptr, char *txt )
{
   static char tbuf[80];
   BOOL        openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return;
      else
         openedLibs = TRUE;
      }

   if (!txt)
      goto exitDisplayTitle; // Stop bugs in their tracks!
      
   if (!wptr)
      goto exitDisplayTitle;     // Stop bugs in their tracks!

   StringNCopy( &tbuf[0], txt, 80 );

   tbuf[79] = '\0';
   
   SetWindowTitles( wptr, (STRPTR) &tbuf[0], (STRPTR) -1 );

exitDisplayTitle:

   if (openedLibs == TRUE)
      CloseLibs();
         
   return;
}

// ----------------------------------------------------------------------

PUBLIC int LVMError = 0; // Error # for Guarded_AllocLV() function.

/****h* Guarded_FreeLV() ************************************************
*
* NAME
*    Guarded_FreeLV()
*
* SYNOPSIS
*    void Guarded_FreeLV( struct ListViewMem *lvm );
*
* DESCRIPTION
*    Free the memory associated with a ListView Gadget & reset 
*    the Guard. 
*************************************************************************
*
*/

PUBLIC void Guarded_FreeLV( struct ListViewMem *lvm )
{
   if (!lvm) // == NULL)
      return;
      
   if (lvm->lvm_NodeStrs) // != NULL)
      {
      FreeVec( lvm->lvm_NodeStrs );
      lvm->lvm_NodeStrs = NULL;
      }

   if (lvm->lvm_Nodes) // != NULL)
      {
      FreeVec( lvm->lvm_Nodes );
      lvm->lvm_Nodes = NULL;
      }

   if (lvm) // != NULL)
      {
      FreeVec( lvm );
      lvm = NULL;
      }

   return;
}

/****h* ReportAllocLVError() ********************************************
*
* NAME
*    ReportAllocLVError()
*
* SYNOPSIS
*    void ReportAllocLVError( void );
*
* DESCRIPTION
*    Display a requester informing the User the error that 
*    Guarded_AllocLV() found.
*
* SEE ALSO
*    Guarded_AllocLV(), Guarded_FreeLV()
*************************************************************************
*
*/

PUBLIC void ReportAllocLVError( void )
{
   IMPORT int LVMError;

   char msg[256] = { 0, };
      
   switch (LVMError)
      {
      case LVM_ERROR_NONE:
         StringCopy( &msg[0], CFMsg( MSG_LVM_ERROR_NONE, MSG_LVM_ERROR_NONE_STR ) );
         break;
       
      case LVM_ERROR_WRONG_SIZE:
         StringCopy( &msg[0], CFMsg( MSG_LVM_ERROR_WRONG_SIZE, MSG_LVM_ERROR_WRONG_SIZE_STR ) );
         break;
         
      case LVM_ERROR_NOMEM:
         StringCopy( &msg[0], CFMsg( MSG_LVM_ERROR_NOMEM, MSG_LVM_ERROR_NOMEM_STR ) );
         break;
      } 

   UserInfo( &msg[0], CFMsg( MSG_RQTITLE_ERROR_REPORT, MSG_RQTITLE_ERROR_REPORT_STR ) );

   return;
}

/****h* Guarded_AllocLV() ***********************************************
*
* NAME
*    Guarded_AllocLV()
*
* SYNOPSIS
*    struct ListViewMem *lvm = Guarded_AllocLV( int numitems, 
*                                               int itemsize
*                                             );
*
* DESCRIPTION
*    Allocate the memory associated with a ListView Gadget.
*************************************************************************
*
*/

PUBLIC struct ListViewMem *Guarded_AllocLV( int numitems, int itemsize )
{
   IMPORT int LVMError;
   
   struct ListViewMem *rval = NULL;
   
   if ((numitems < 1) || (itemsize < 1))
      {
      LVMError = LVM_ERROR_WRONG_SIZE;
      
      return( NULL );
      }

   // --------- ALLOCATION SECTION: -----------------------------------

   rval = (struct ListViewMem *) AllocVec( sizeof( struct ListViewMem ),
                                           MEMF_CLEAR
                                         );  
   
   if (!rval)
      {
      LVMError = LVM_ERROR_NOMEM;

      return( NULL );
      }

   rval->lvm_Nodes = (struct Node *) 
                      AllocVec( numitems * sizeof( struct Node ),
                                MEMF_CLEAR 
                              );

   if (!rval->lvm_Nodes)
      {
      Guarded_FreeLV( rval );

      LVMError = LVM_ERROR_NOMEM;

      return( NULL );
      }

   rval->lvm_NodeStrs = (UBYTE *) AllocVec( numitems * itemsize, 
                                            MEMF_CLEAR
                                          );

   if (!rval->lvm_NodeStrs)
      {
      Guarded_FreeLV( rval );

      LVMError = LVM_ERROR_NOMEM;

      return( NULL );
      }

   // --------- END OF ALLOCATION SECTION: ----------------------------

   rval->lvm_NumItems   = numitems;
   rval->lvm_NodeLength = itemsize;   

   LVMError = LVM_ERROR_NONE; // Weesa be okey-dokey!

   return( rval );
}

/****h* GetPathName() ***************************************************
*
* NAME
*    GetPathName()
*  
* SYNOPSIS
*    char *path = GetPathName( char *pathbuf, char *filename, int size );
*
* DESCRIPTION
*    Return with the Path portion of a filename string.
*************************************************************************
*
*/

PUBLIC char *GetPathName( char *path, char *filename, int size )
{
   int   i;
   char *last = PathPart( filename );

   for (i = 0; (i < size) && (filename != last); i++, filename++)
      *(path + i) = *filename;
      
   *(path + i) = '\0';
   
   return( path ); 
}


/****h* FontXDim() ******************************************************
*
* NAME
*    FontXDim()
*
* SYNOPSIS
*    int length = FontXDim( struct TextAttr *font );
*
* DESCRIPTION
*    Determine the horizontal distance for one character in the given
*    font.
*************************************************************************
*
*/

PUBLIC int FontXDim( struct TextAttr *font )
{
   struct IntuiText t          = { 0, };
   int              length     = 0;
   BOOL             openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return( 0 );
      else
         openedLibs = TRUE;
      }
    
   t.IText     = " ";
   t.ITextFont = font;

   length = IntuiTextLength( &t );
   
   if (openedLibs == TRUE)
      CloseLibs();
      
   return( length  );
}

/****h* getScreenModeID() ***********************************************
*
* NAME
*    getScreenModeID()
*
* SYNOPSIS
*    ULONG mode = getScreenModeID( struct TagItem *taglist, 
*                                  struct Screen  *screen,
*                                  char           *req_title
*                                ); 
*
* DESCRIPTION
*    Obtain a user-selected (via ASL) ScreenModeID value.  NULL will
*    be returned if you supply a NULL value for the screen pointer,
*    or if you press & release the Cancel Gadget on the Requester.
*************************************************************************
*
*/

PUBLIC ULONG getScreenModeID( struct TagItem *taglist, 
                              struct Screen  *scr,
                              char           *title 
                            )
{
   struct ScreenModeRequester *smr = NULL;

   ULONG  rval    = 0L;
   BOOL   result  = FALSE;
   BOOL   libflag = FALSE;
   BOOL   openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return( 0 );
      else
         openedLibs = TRUE;
      }
   
   if (!scr)
      {
      scr = GetActiveScreen(); // Bonehead Programmer!!
      }
      
#  ifdef __amigaos4__
   if (openUtilityLib() == RETURN_OK)
      {
#  endif

      if (!FindTagItem( ASLSM_Screen, taglist ))
         {
#        ifdef __amigaos4__
         closeUtilityLib();
#        endif
         goto exitGetScreenModeID; // Missing the ONLY necessary tag!
         }
      else
         SetTagItem( taglist, ASLSM_Screen, (ULONG) scr );

      if (FindTagItem( ASLSM_TitleText, taglist ))
         SetTagItem( taglist, ASLSM_TitleText, (ULONG) title );

#  ifdef __amigaos4__
      closeUtilityLib();
      }
   else
      goto exitGetScreenModeID;
#  endif
                  
   if (openASLLib() == RETURN_OK)
      libflag = TRUE;
   else
      goto exitGetScreenModeID;
      
   smr = (struct ScreenModeRequester *) AllocAslRequest( ASL_ScreenModeRequest, NULL );

   if (smr)
      {
      result = AslRequest( smr, taglist );

      if (result != FALSE)
         {
         rval = smr->sm_DisplayID;
         } 

      FreeAslRequest( smr );
      }
   else                   // No ScreenModeRequester!
      {
      if (libflag != FALSE)
         closeASLLib();

      goto exitGetScreenModeID;
      }

   if (libflag == TRUE)
      closeASLLib();

exitGetScreenModeID:

   if (openedLibs == TRUE)
      CloseLibs();
            
   if (result != FALSE)
      return( rval );
   else
      return( 0 );
}
 
/****h* Byt2Str() ***************************************************
*
* NAME
*    Byt2Str()
*
* SYNOPSIS
*    char *hexstr = Byt2Str( char *output, char input_byte );
*
* DESCRIPTION
*    Take an input binary character & generate a displayable 
*    two-character ASCII 
*    string that displays the HexaDecimal value of each byte.
*
* WARNINGS
*    The output buffer has to be TWO times as long as the input
*    buffer (+ 1 for nil); in other words supply a buffer that's
*    three characters long!
*********************************************************************
*
*/

PUBLIC char *Byt2Str( char *out, char input )
{
   char hexch[] = "0123456789ABCDEF";

   char low     = hexch[  input & 0x0F       ];
   char high    = hexch[ (input & 0xF0) >> 4 ];

   *out       = high;
   *(out + 1) = low;
   *(out + 2) = '\0';

   return( out );
}

/****h* MakeHexASCIIStr() *******************************************
*
* NAME
*    MakeHexASCIIStr()
*
* SYNOPSIS
*    unsigned int length = MakeHexASCIIStr( char *output, 
*                                           char *input,
*                                           int   inputlength
*                                         );
*
* DESCRIPTION
*    Take an input binary string & generate a displayable ASCII 
*    string that displays the HexaDecimal value of each byte as
*    well as the ASCII representation (for characters >= 0x20 &
*    <= 0x7E).
*
*    Output will be as follows:
*
*    /------------ Hex Bytes ----------\ /--- ASCII ----\
*
*    22334455 22334455 A7223344 7F223344 "3DU"3DU."3D."3D 
*
* WARNINGS
*    The output buffer has to be FOUR times as long as the input
*    buffer!  The maximum value for inlen should be 20 bytes, with
*    16 being the nominal value.
*********************************************************************
*
*/

PUBLIC unsigned int MakeHexASCIIStr( char *out, char *input, int inlen )
{
   char hexch[] = "0123456789ABCDEF";
   int   i, j, k;

   for (i = 0; i < (4 * inlen); i++)
      *(out + i) = ' ';         // Initialize the output buffer.

   // Output the binary as ASCII characters:  

   for (i = 0, j = 0, k = 0; i < inlen; i++, j++, k++)
      {
      char low, high;
         
      low  = hexch[  *(input + i) & 0x0F       ];
      high = hexch[ (*(input + i) & 0xF0) >> 4 ];

      *(out + k + j)     = high;
      *(out + k + j + 1) = low;
      
      if ((i + 1) % 4 == 0) // Insert a space between each long word.
         k++;
      }

   *(out + k + j) = '\0';
   i = StringLength( out );      // compute the start of the ASCII string.
   *(out + k + j) = ' ';

   // Output the ASCII representation:   

   for (j = 0; j < inlen; j++, i++) 
      {
      if ((*(input + j) < 0x20) || (*(input + j) > 0x7E))
         *(out + i) = 0x2E; // Output an ASCII period.
      else
         *(out + i) = *(input + j);
      }

   return( (unsigned int) StringLength( out ) );
}

/****h* File_DirReq() ***************************************************
* 
* NAME
*    File_DirReq()
*
* SYNOPSIS
*    int len = File_DirReq( char           *filename, 
*                           char           *dirname,
*                           struct TagItem *taglist
*                         );
*
* DESCRIPTION
*    Display the ASL file requester with the given taglist.  Return
*    the size of the file selected as well as the filename & Directory.
*
*    The suggested taglist items should be:
*
*    ASLFR_Window,          (ULONG) WindowPointer // definitely needed!
*
*    ASLFR_TitleText,       (ULONG) "Example title..." 
*    ASLFR_InitialHeight,   200,
*    ASLFR_InitialWidth,    400,
*    ASLFR_InitialTopEdge,  16,
*    ASLFR_InitialLeftEdge, 50,
*    ASLFR_PositiveText,    (ULONG) "OKAY!",
*    ASLFR_NegativeText,    (ULONG) "CANCEL!",
*    ASLFR_InitialPattern,  (ULONG) "#?",
*    ASLFR_InitialFile,     (ULONG) "",
*    ASLFR_InitialDrawer,   (ULONG) "RAM:",
*    ASLFR_Flags1,          FRF_DOPATTERNS,
*    ASLFR_Flags2,          FRF_REJECTICONS,
*    ASLFR_SleepWindow,     1,
*    ASLFR_PrivateIDCMP,    1,
*    TAG_END
************************************************************************
*
*/

PUBLIC int File_DirReq( char           *filename, 
                        char           *dirname, 
                        struct TagItem *taglist
                      )
{
   struct FileRequester *fr;

   int    len, libflag = 0;

   if (!filename)
      {
      return( -4 ); // Better safe than sorry!
      }

#  ifdef __amigaos4__
   if (openUtilityLib() == RETURN_OK)
      {
#  endif

      if (!FindTagItem( ASLFR_Window, taglist ))
         {
         return( -3 ); // Missing the ONLY necessary tag!
         }

#  ifdef __amigaos4__
      closeUtilityLib();
      }
   else
      return( -3 );
#  endif
           
   if (openASLLib() == RETURN_OK)
      {
      libflag = TRUE;
      
      fr = (struct FileRequester *) 
                   AllocAslRequest( ASL_FileRequest, taglist );

      if (fr)
         {
         if (AslRequest( fr, NULL ) != DOSFALSE)
            {
            (void) StringCopy( filename, fr->fr_Drawer );
            len = StringLength( filename ) - 1;

            if (len <= 0)
               {
               FreeAslRequest( fr );

               if (libflag != FALSE)
                  closeASLLib();

               return( 0 );
               }

            if (*(filename + len) == '/' || *(filename + len) == ':')
               (void) StringCat( filename, fr->fr_File );
            else
               {      
               // Add a slash to the end of the Path:
               (void) StringCat( filename, "/" );
               (void) StringCat( filename, fr->fr_File );
               }
            }
         else
            {
            FreeAslRequest( fr );

            if (libflag != FALSE)
               closeASLLib();

            return( 0 );
            }
            
         if (dirname != NULL)
            StringCopy( dirname, fr->fr_Drawer );

         FreeAslRequest( fr );
         }
      else                   // No FileRequester!
         {
         if (libflag != FALSE)
            closeASLLib();

         return( -2 );
         }

      if (libflag != FALSE)
         closeASLLib();
      }
   else
      {
      return( -1 );          // AslBase couldn't be opened!
      }

   return( StringLength( filename ) );
}

/****h* FileReq() ******************************************************
* 
* NAME
*    FileReq()
*
* SYNOPSIS
*    int len = FileReq( char *filename, struct TagItem *taglist );
*
* DESCRIPTION
*    Display the ASL file requester with the given taglist.
*
* NOTES
*    This function is identical to File_DirReq() except that we
*    don't use the Directory parameter.
*
*    The suggested taglist items should be:
*
*    ASLFR_Window,          (ULONG) WindowPointer // definitely needed!
*
*    ASLFR_TitleText,       (ULONG) "Example title..." 
*    ASLFR_InitialHeight,   200,
*    ASLFR_InitialWidth,    400,
*    ASLFR_InitialTopEdge,  16,
*    ASLFR_InitialLeftEdge, 50,
*    ASLFR_PositiveText,    (ULONG) "OKAY!",
*    ASLFR_NegativeText,    (ULONG) "CANCEL!",
*    ASLFR_InitialPattern,  (ULONG) "#?",
*    ASLFR_InitialFile,     (ULONG) "",
*    ASLFR_InitialDrawer,   (ULONG) "RAM:",
*    ASLFR_Flags1,          FRF_DOPATTERNS,
*    ASLFR_Flags2,          FRF_REJECTICONS,
*    ASLFR_SleepWindow,     1,
*    ASLFR_PrivateIDCMP,    1,
*    TAG_END
************************************************************************
*
*/

PUBLIC int FileReq( char *filename, struct TagItem *taglist )
{
   return( File_DirReq( filename, NULL, taglist ) );
}

/* --------------------- User Notification: ------------------------ */

INVISIBLE struct usernotify { // INVISIBLE keeps gcc in the dark.
    
   struct EasyStruct un_ES;
   struct Window     *un_Window;
};

PRIVATE struct usernotify userinfo = {
    
   { sizeof( struct EasyStruct ), 0,
     "Program Problem!",
     "Problem (%ld) with Program.\nSelect 'ABORT' to quit:",
     "CONTINUE|ABORT",
   },

   NULL
};

/****h* SetNotifyWindow() [1.0] *************************************
*
* NAME
*    SetNotifyWindow()
*
* SYNOPSIS
*    (void) SetNotifyWindow( struct Window *wptr );
*
* DESCRIPTION
*    Set the window pointer that Handle_Problem() & other User-
*    Requesters will use for the EasyRequest() call.
*********************************************************************
*
*/

PUBLIC void SetNotifyWindow( struct Window *wptr )
{
   if (wptr)
      userinfo.un_Window = wptr;
   else
      userinfo.un_Window = GetActiveWindow();
               
   return;
}

/****h* SetReqButtons() [1.0] ***************************************
*
* NAME
*    SetReqButtons
*
* SYNOPSIS
*    (void) SetReqButtons( char *newbuttons );
*
* DESCRIPTION
*    Set the buttons for the Information requester to the given 
*    format string.
*
* NOTES
*    The user of this function should return the buttons to a
*    known string after Handle_Problem() or the other User-
*    requesters are called.
*********************************************************************
*
*/

PUBLIC void SetReqButtons( char *newbuttons )
{
   if (newbuttons)
      userinfo.un_ES.es_GadgetFormat = newbuttons;
   else
      userinfo.un_ES.es_GadgetFormat = CFMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ); //"CONTINUE|ABORT!";
      
   return;
}

/****i* NotifyUser() [1.0] ******************************************
*
* NAME
*    NotifyUser() - Internal to CommonFuncs.o only (PRIVATE!)
*
* SYNOPSIS
*    int ans = NotifyUser( char          *info, 
*                          char          *title,
*                          struct Window *wptr, 
*                          int           *errnum
*                        );
*
* DESCRIPTION
*    Get a response from the user.
*
* FUNCTION
*    Return -1 if the user selected the far-right button (ABORT?),
*    else return 0 (CONTINUE?).
*
* INPUTS
*    info   - Information string for the user to act on.
*    title  - Title of the Problem Requester.
*    wptr   - The window to open the Requester on.
*    errnum - Optional error number (normally NULL).
*********************************************************************
*
*/

PRIVATE int NotifyUser( char          *problem,
                        char          *title,
                        struct Window *wptr,
                        int           errnum
                      )
{
   int  rval = 0, answer = 0;
   int  oldflags, newflags = 0;
   BOOL openedLib = FALSE;

   if (!IntuitionBase)
      {
      if (OpenIntuitionLib() != RETURN_OK)
         return( ERROR_INVALID_RESIDENT_LIBRARY );
      else
         openedLib = TRUE;
      }

   if (!wptr)
      {
      fprintf( stderr, CFMsg( MSG_WARNING_NOTIFYUSER, MSG_WARNING_NOTIFYUSER_STR ) ); //"NotifyUser() Calling GetActiveWindow()...\n" );

      wptr = GetActiveWindow(); // myWin;
      }

   if (!wptr)
      {
      fprintf( stderr, CFMsg( MSG_FAILURE_GETACTIVEWINDOW, MSG_FAILURE_GETACTIVEWINDOW_STR ) ); // "GetActiveWindow() FAILED in NotifyUser()!\n" );
      
      return( -1 ); // Send out the ABORT! signal!!
      }
            
   newflags                     = wptr->IDCMPFlags;
   oldflags                     = newflags;
   userinfo.un_ES.es_TextFormat = problem;
   userinfo.un_ES.es_Title      = title;
   
   // Turn off verify IDCMP messages:
   newflags &= ~(IDCMP_SIZEVERIFY | IDCMP_REQVERIFY | IDCMP_MENUVERIFY);

   ModifyIDCMP( wptr, newflags );
   
   answer = EasyRequest( wptr, &userinfo.un_ES, NULL, errnum );

   switch (answer)
      {
      case 1:
         rval = RETURN_OK; // Continue Button.
         break;
         
      case 0:        // This is the far right button!
         rval = -1;
         break;
      }

   ModifyIDCMP( wptr, oldflags ); // Restore old IDCMP flags.

   if (openedLib == TRUE)
      CloseLibs();
      
   return( rval );
}

/****h* Handle_Problem() [1.0] **************************************
*
* NAME
*    Handle_Problem()
*
* SYNOPSIS
*    int ans = Handle_Problem( char *info, char *title, int *errnum );
*
* DESCRIPTION
*    Get a Yes/No Response from the user.
*
* FUNCTION
*    Return -1 if the user selected the ABORT (far-right) button,
*    else return the errnum value (normally 0).
*
* INPUTS
*    info   - Information string for the user to act on.
*    title  - Title of the Problem Requester.
*    errnum - Optional error number (normally NULL).
*
* NOTES
*    Be sure to call SetNotifyWindow( wptr ) BEFORE using this 
*    function for the first time!
*********************************************************************
*
*/

PUBLIC int Handle_Problem( char *info, char *title, int *errnum )
{
   int errornum = 0;
   
   if (errnum != NULL)
      errornum = *errnum;
      
//   if (userinfo.un_Window == NULL) // Corrected in SetNotifyWindow();
//      return( -2 );
      
   if (NotifyUser( info, title, userinfo.un_Window, errornum ) == -1)
      return( -1 );
   else
      return( errornum );  // User didn't press the ABORT button!
}

/****h* GetUserResponse() [1.0] *************************************
*
* NAME
*    GetUserResponse - Get a button response from the user.
*
* SYNOPSIS
*    int ans = GetUserResponse( char *info, char *title, int *errnum );
*
* FUNCTION
*    Return -1 if there's no window, otherwise return the ordinal
*    of the button the user pressed.  This means that there can be
*    more than two choice buttons for the User to choose from.
*
* INPUTS
*    info   - Information string for the user to act on.
*    title  - Title of the Problem Requester.
*    errnum - Optional error number.
*
* NOTES
*    GetUserResponse() will return 0 for the right-most button,
*    instead of n, where n is the number of buttons.  This is the
*    behavior of the EasyRequest() function (so don't blame me!).
*
*    Call SetReqButtons() before using this function &
*    be sure to call SetNotifyWindow( wptr ) BEFORE using this 
*    function for the first time!
*********************************************************************
*
*/

PUBLIC int  GetUserResponse( char *problem, char *title, int *errnum )
{
   struct Window *wptr = userinfo.un_Window;
   int            answer = 0;
   int            oldflags, newflags, errornum;
   BOOL           openedLib = FALSE;

   if (!IntuitionBase)
      {
      if (OpenIntuitionLib() != RETURN_OK)
         return( ERROR_INVALID_RESIDENT_LIBRARY );
      else
         openedLib = TRUE;
      }
   
   if (!wptr)
      wptr = GetActiveWindow(); // return( -1 );
      
   if (errnum)
      errornum = *errnum;
      
   newflags                     = wptr->IDCMPFlags;
   userinfo.un_ES.es_TextFormat = problem;
   userinfo.un_ES.es_Title      = title;
   oldflags                     = newflags;
   
   // Turn off verify IDCMP messages:
   newflags &= ~(IDCMP_SIZEVERIFY | IDCMP_REQVERIFY | IDCMP_MENUVERIFY);

   ModifyIDCMP( wptr, newflags );
   
   answer = EasyRequest( wptr, &userinfo.un_ES, NULL, errnum );

   ModifyIDCMP( wptr, oldflags ); // Restore old IDCMP flags.

   if (openedLib == TRUE)
      CloseLibs();
      
   return( answer );
}

/****h* SanityCheck() [1.0] **************************************
*
* NAME
*    SanityCheck - Get a Yes/No Response from the user.
*
* SYNOPSIS
*    Boolean answer = SanityCheck( char *question );
*
* FUNCTION
*    Return TRUE if the User pressed the 'YES' button.
*    Return FALSE if the User pressed the 'NO' button.
*
* INPUTS
*    question - question the User has to respond to.
*
* NOTES
*    Be sure to call SetNotifyWindow( wptr ) BEFORE using this 
*    function for the first time!
******************************************************************
*
*/

PUBLIC BOOL SanityCheck( char *question )
{
   BOOL rval = FALSE;

   SetReqButtons( CFMsg( MSG_YES_NO_BUTTONS, MSG_YES_NO_BUTTONS_STR ) ); // "YES|NO" );

   rval = Handle_Problem( question, CFMsg( MSG_USER_SANITY_CHECK, MSG_USER_SANITY_CHECK_STR ), NULL ); // "User SANITY CHECK:", NULL );

   SetReqButtons( CFMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) ); // "CONTINUE|ABORT" );

   if (rval == 0)
      rval = TRUE;
   else 
      rval = FALSE;
      
   return( rval ); 
}

/****h* UserInfo() [1.0] *****************************************
*
* NAME
*    UserInfo()
*
* SYNOPSIS
*    void UserInfo( char *message, char *windowtitle );
*
* DESCRIPTION
*    Tell user some information.
*
* NOTES
*    Be sure to call SetNotifyWindow( wptr ) BEFORE using this 
*    function for the first time!
******************************************************************
*
*/

PUBLIC void UserInfo( char *msg, char *title )
{
   SetReqButtons( CFMsg( MSG_OKAY_BUTTON, MSG_OKAY_BUTTON_STR ) ); // "OKAY" );   

   (void) Handle_Problem( msg, title, NULL );

   SetReqButtons( CFMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) ); // "CONTINUE|ABORT" );

   return; 
} 

/****h* ComputeX() [1.0] ********************************************
*
* NAME
*    ComputeX()
*
* SYNOPSIS
*    UWORD size = ComputeX( UWORD fontxsize, UWORD value );
*
* DESCRIPTION
*    This function returns 
*         (fontxsize * value + (fontxsize / 2)) / fontxsize
*
* NOTES
*    This function will probably be changed to private later.
*********************************************************************
*
*/

PUBLIC UWORD ComputeX( UWORD fontxsize, UWORD value )
{
   return( (UWORD) (((fontxsize * value) + (fontxsize / 2)) / fontxsize) );
}

/****h* ComputeY() [1.0] ********************************************
*
* NAME
*    ComputeY()
*
* SYNOPSIS
*    UWORD size = ComputeY( UWORD fontysize, UWORD value );
*
* DESCRIPTION
*    This function returns 
*         (fontysize * value + (fontysize / 2)) / fontysize
*
* NOTES
*    This function will probably be changed to private later.
*********************************************************************
*
*/

PUBLIC UWORD ComputeY( UWORD fontysize, UWORD value )
{
   return( (UWORD) (((fontysize * value) + (fontysize / 2)) / fontysize) );
}

/****h* ComputeFont() [1.0] *****************************************
*
* NAME
*    ComputeFont()
*
* SYNOPSIS
*    void ComputeFont( struct Screen   *screen,
*                      struct TextAttr *font,
*                      struct CompFont *cfont,
*                      UWORD            width,
*                      UWORD            height
*                    );
*
* DESCRIPTION
*    Initialize the CompFont structure according to the supplied
*    values in the font, width & height.  If the results won't fit
*    the screen dimensions, use topaz (8) in the computations
*    instead.
*
* NOTES
*    GfxBase has to be open BEFORE calling this function!
*********************************************************************
*
*/

PUBLIC void ComputeFont( struct Screen   *Scr, 
                         struct TextAttr *Font,
                         struct CompFont *cf,
                         UWORD            width, 
                         UWORD            height
                       )
{
#  ifndef __amigaos4__
   if (!GfxBase)
      goto UseTopaz;
      
   Forbid(); // ---------------------------------------------
     
     Font->ta_Name  = (STRPTR) 
                      GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name;
     
     Font->ta_YSize = GfxBase->DefaultFont->tf_YSize;
     
     cf->FontY = GfxBase->DefaultFont->tf_YSize; 
     cf->FontX = GfxBase->DefaultFont->tf_XSize; 
     
   Permit(); // ---------------------------------------------
#  else
   struct GfxBase *gptr = (struct GfxBase *) IGraphics->Data.LibBase;
   
   if (!gptr)
      goto UseTopaz;
      
   Forbid(); // ---------------------------------------------
     
     Font->ta_Name  = (STRPTR) gptr->DefaultFont->tf_Message.mn_Node.ln_Name;
     Font->ta_YSize =          gptr->DefaultFont->tf_YSize;
     cf->FontY      =          gptr->DefaultFont->tf_YSize; 
     cf->FontX      =          gptr->DefaultFont->tf_XSize; 
     
   Permit(); // ---------------------------------------------
#  endif

   cf->OffX = Scr->WBorLeft;
   cf->OffY = Scr->RastPort.TxHeight + Scr->WBorTop + 1;

   if ((width != 0) && (height != 0))
      {
      if ((ComputeX( cf->FontX, width ) 
           + cf->OffX + Scr->WBorRight) > Scr->Width)
         {  
         goto UseTopaz;
         }
         
      if ((ComputeY( cf->FontY, height ) 
           + cf->OffY + Scr->WBorBottom) > Scr->Height)
         {
         goto UseTopaz;
         }
      }

   return;
   
UseTopaz:

   Font->ta_Name  = (STRPTR) "topaz.font";
   Font->ta_YSize = 8;
   
   cf->FontX      = 8;
   cf->FontY      = 8;

   // These might be in error:
   cf->OffX       = Scr->WBorLeft;
   cf->OffY       = Scr->RastPort.TxHeight + Scr->WBorTop + 1;

   return;
}

/****h* FindTools() [1.0] *******************************************
*
* NAME
*    FindTools()
* 
* DESCRIPTION
*    Locate a tools array for a given name.
*
* SYNOPSIS
*    STRPTR *toolarray = FindTools( struct DiskObject *diskobj,
*                                   char              *filename,
*                                   BPTR               directory_lock
*                                 );
*
* INPUTS
*    filename = null-terminated name of file to look for.
*    lock     = directory to look for file in.
*    diskobj  = storage (for a later call to FreeDiskObject()) 
*
* WARNINGS
*    Be sure to call FreeDiskObject() later in your program.
*    FindTools() doesn't do this because it doesn't know what 
*    you're going to do with the ToolTypes. 
*********************************************************************
*
*/

PUBLIC STRPTR *FindTools( struct DiskObject *diskobj, 
                          char              *name, 
                          BPTR               lock 
                        )
{
   BPTR    olddir = (BPTR) NULL;
   STRPTR *tools  = NULL;

   if (!lock)
      return( NULL );
      
   olddir = CurrentDir( lock );

#  ifdef __amigaos4__   
   if (openIconLib() != RETURN_OK)
      return( NULL );
#  endif

   if ((diskobj = (struct DiskObject *) GetDiskObject( name )))
      tools = diskobj->do_ToolTypes;

#  ifdef __amigaos4__
   closeIconLib();
#  endif
   
   (void) CurrentDir( olddir );

   return( tools );
}

/****h* GetToolStr() [1.0] ******************************************
*
* NAME
*    GetToolStr()
*
* DESCRIPTION
*    Find the tooltype string that matches the given name.
*
* SYNOPSIS
*    toolstring = GetToolStr( STRPTR *toolarray,
*                             char   *toolname,
*                             char   *default_tool
*                           );
*
* INPUTS
*    toolarray    = pointer from FindTools() call.
*    toolname     = tool we're searching the icon for.
*    default_tool = default string to return if the tool isn't found.
*********************************************************************
*
*/

PUBLIC char *GetToolStr( STRPTR *toolptr, char *name, char *Default )
{
   char *found = NULL;
   
#  ifdef __amigaos4__   
   if (openIconLib() != RETURN_OK)
      return( NULL );
#  endif

   found = (char *) FindToolType( toolptr, (CONST_STRPTR) name );

#  ifdef __amigaos4__
   closeIconLib();
#  endif
   
   return( (found != NULL) ? found : Default );
}

/****h* GetToolInt() [1.0] ******************************************
*
* NAME
*    GetToolInt() 
*
* DESCRIPTION
*    Find the tooltype integer that matches the given name.
*
* SYNOPSIS
*    tool_int = GetToolInt( STRPTR *toolarray,
*                           char   *toolname,
*                           int     default_val
*                         );
*
* INPUTS
*    toolarray   = pointer from FindTools() call.
*    toolname    = tool we're searching the icon for.
*    default_val = default integer to return if the tool isn't found.
*********************************************************************
*
*/

PUBLIC int GetToolInt( STRPTR *toolptr, char *name, int defaultvalue )
{
   char *found = NULL;
   int   rval  = 0;
   
#  ifdef __amigaos4__   
   if (openIconLib() != RETURN_OK)
      return( 0 );
#  endif

   found = (char *) FindToolType( toolptr, (CONST_STRPTR) name );

#  ifdef __amigaos4__
   closeIconLib();
#  endif
   
   if (found)
      rval  = atoi( found );

   return( (found != NULL) ? rval : defaultvalue );
}

/****h* GetToolBoolean() [1.0] **************************************
*
* NAME
*    GetToolBoolean()
*
* DESCRIPTION
*    Find the tooltype boolean that matches the given name.
*
* SYNOPSIS
*    boolean ans = GetToolBoolean( STRPTR *toolptr,
*                                  char   *name,
*                                  int     defaultBool
*                                );
*
* INPUTS
*    toolptr     = pointer from FindTools() call.
*    name        = tool we're searching the icon for.
*    defaultBool = default boolean to return if the tool isn't found.
*
* NOTES
*    The following strings will return a Boolean value of TRUE:
*        
*        "TRUE", "YES", "1", "OK" & "OKAY"
*
*    any other value will return FALSE.
*********************************************************************
*
*/

PUBLIC BOOL GetToolBoolean( STRPTR *toolptr, char *name, int defaultBool )
{
   char *found = NULL;
   
#  ifdef __amigaos4__   
   if (openIconLib() != RETURN_OK)
      return( FALSE );
#  endif

   found = (char *) FindToolType( toolptr, (CONST_STRPTR) name );

#  ifdef __amigaos4__
   closeIconLib();
#  endif
   
   if (found)
      {
      if (StringComp( found, CFMsg( MSG_TRUE_STRING, MSG_TRUE_STRING_STR ) ) == 0)
         return( TRUE );
      else if (StringComp( found, CFMsg( MSG_YES_STRING, MSG_YES_STRING_STR ) ) == 0)
         return( TRUE );
      else if (StringComp( found, CFMsg( MSG_OK_STRING, MSG_OK_STRING_STR ) ) == 0)
         return( TRUE );
      else if (StringComp( found, CFMsg( MSG_OKAY_STRING, MSG_OKAY_STRING_STR ) ) == 0)
         return( TRUE );
      else if (StringComp( found, "1" ) == 0)
         return( TRUE );
      else
         return( FALSE );
      }
   else
      return( (BOOL) defaultBool );
}

/****h* FindIcon() [1.0] ********************************************
*
* NAME
*    FindIcon()
*
* DESCRIPTION
*    Find the icon associated with pgmname (if any) & process the
*    ToolTypes array in the icon with ToolProc().
*
* SYNOPSIS
*    void *rval = FindIcon( void              *(ToolProc)(char **), 
*                           struct DiskObject *dobj,
*                           char              *pgmname
*                         );
*
* INPUTS
*    ToolProc() - a Pointer to a function that will perform an
*                 operation on the ToolTypes array from the Icon
*                 if the icon was found.
*
*    dobj       - storage (for a later call to FreeDiskObject())
*
*    pgmname    - The name of the icon to look for (without the
*                 ".info" at the end of the string). 
*
* NOTES
*    If the user starts a program from the CLI, & the icon is in
*    the same directory, we will get the ToolTypes from the icon
*    instead of using the built-in defaults.
*********************************************************************
*
*/

PUBLIC void *FindIcon( void              *(ToolProc)(STRPTR *), 
                       struct DiskObject *dobj,
                       char              *pgmname
                     )
{
   BPTR    dirlock = (BPTR) NULL;
   STRPTR *toolptr = NULL;
   void   *rval    = NULL;
   
   dirlock = GetProgramDir(); // AmigaDOS function.
   
   if (dirlock)
      {
      toolptr = FindTools( dobj, pgmname, dirlock );
      rval    = ToolProc( toolptr ); // Do something with the tools!
      }

   return( rval );
}

/****h* RGB2HSV() ***************************************************
*
* NAME
*    RGB2HSV()
*
* SYNOPSIS
*    struct ColorCoords *ans = RGB2HSV( struct ColorCoords *input );
*
* DESCRIPTION
*    Convert an RGB color coordinate set into HSV (Hue,
*    Saturation & Luminance).
*
* NOTES
*    red, green & blue are values from 0 to 255 (normally).
*
* WARNINGS
*    If you want the input structure for later, save it before
*    passing it to this function, since it modifies it & returns it.
*********************************************************************
*
*/

PUBLIC struct ColorCoords *RGB2HSV( struct ColorCoords *input )
{
   float hue, saturation, luminance;
   float red, green, blue;
   float ma, mi, d;
   
   red   = (float) input->Red_Hue          / 15;
   green = (float) input->Green_Saturation / 15;
   blue  = (float) input->Blue_Luminance   / 15;

   ma = (red > blue)  ? red : blue;
   ma = (ma  > green) ? ma  : green;
   mi = (red < blue)  ? red : blue;
   mi = (mi  < green) ? mi  : green;

   luminance = ma;
   
   if (ma != 0)
      saturation = (ma - mi) / ma;
   else
      saturation = 0;
      
   if (saturation == 0)
      hue = 0;
   else
      {
      d = ma - mi;
      
      if (red == ma)
         hue = (green - blue) / d;
      else if (green == ma)
         hue = 2 + (blue - red) / d;
      else
         hue = 4 + (red - green) / d;

      hue *= 60;
      
      if (hue < 0)
         hue += 360;
      }

   input->Red_Hue          = (LONG) hue;
   input->Green_Saturation = (LONG) 100 * saturation;
   input->Blue_Luminance   = (LONG) 100 * luminance;

   return( input );
}

/****h* HSV2RGB() ***************************************************
*
* NAME
*    HSV2RGB()
*
* SYNOPSIS
*    struct ColorCoords *ans = HSV2RGB( struct ColorCoords *input );
*
* DESCRIPTION 
*    Convert an HSV (Hue, Saturation & Luminance) coordinate into
*    RGB (red, green & blue).
*
* NOTES
*    red, green & blue are values from 0 to 255 (normally).
*
* WARNINGS
*    If you want the input structure for later, save it before
*    passing it to this function, since it modifies it & returns it.
*
*********************************************************************
*
*/

PUBLIC struct ColorCoords *HSV2RGB( struct ColorCoords *input )
{
   float hue, saturation, luminance;
   float red, green, blue;
   float p1, p2, p3, f;
   int   i = 0;

  hue        = (float) input->Red_Hue          / 60;
  luminance  = (float) input->Blue_Luminance   / 100;
  saturation = (float) input->Green_Saturation / 100;

  while ((f = hue - i) > 1)
    i++;

  p1 = luminance * (1 - saturation);
  p2 = luminance * (1 - (saturation * f));
  p3 = luminance * (1 - (saturation * (1 - f)));

  switch (i)
    {
    case 0:
      red   = luminance;
      green = p3;
      blue  = p1;
      break;

    case 1:
      red   = p2;
      green = luminance;
      blue  = p1;
      break;

    case 2:
      red   = p1;
      green = luminance;
      blue  = p3;
      break;

    case 3:
      red   = p1;
      green = p2;
      blue  = luminance;
      break;

    case 4:
      red   = p3;
      green = p1;
      blue  = luminance;
      break;

    case 5:
      red   = luminance;
      green = p1;
      blue  = p2;
      break;
    }

  input->Red_Hue          = (UWORD) (red   * 15);
  input->Green_Saturation = (UWORD) (green * 15);
  input->Blue_Luminance   = (UWORD) (blue  * 15);

  return( input );

}

/****h* SetTagItem() [1.0] ******************************************
*
* NAME
*    SetTagItem()
*
* SYNOPSIS
*    void SetTagItem( struct TagItem *taglist, ULONG tag, ULONG value );
*
* DESCRIPTION
*    This function searches the given taglist for the given tag.  If
*    the tag is found, its value (ti_Data) is changed to the given
*    value.  This function completes the functionality for using 
*    TagLists.
*********************************************************************
*
*/

PUBLIC void SetTagItem( struct TagItem tagList[], ULONG tag, ULONG value )
{
   struct TagItem *item = NULL;
   int             i    = 0;
   
   if (!tagList)
      return;
   
   item = &tagList[0];
   
   while (item)
      {
      if (item->ti_Tag == tag)
         {
 	      item->ti_Data = value;
	
	      break;
         }
      else if (item->ti_Tag == TAG_END)
         break;
	       
      item = &tagList[ ++ i ];
      }

   return;
}

/* This code does not always work under AmigaOS4+:

   struct TagItem *item = NULL;

#  ifdef __amogaos4__   
   if (!UtilityBase) // == NULL
      {
      if (openUtilityLib() != RETURN_OK)
         return;
      }
#  endif

   if (UtilityBase)
      item = (struct TagItem *) FindTagItem( tag, taglist );

#  if (__amigaos4__)   
   closeUtilityLib();
#  endif
   
   if (item) // != NULL)
      item->ti_Data = value;
   
   return;
*/

/****h* SetTagPair() [1.0] ******************************************
*
* NAME
*    SetTagPair()
*
* SYNOPSIS
*    void SetTagPair( struct TagItem *taglist, ULONG tag, ULONG value );
*
* DESCRIPTION
*    Add a Tag & value to a TagItem list.  If taglist is NULL, 
*    nothing is done by this function.
*    This function completes the functionality for using TagLists.
*
* NOTES
*    taglist is really an array of ULONG values organized into pairs.
*
* WARNINGS
*    No check is done to see if there is space in the Tag list
*    for the added pair (so why not reserve space by using: 
*    {TAG_IGNORE, NULL} in the taglist you provide?).
*********************************************************************
*
*/

PUBLIC void SetTagPair( struct TagItem *taglist, ULONG tag, ULONG value )
{
   if (!taglist)
      return;            // Do NOT cause Enforcer hits.
      
   taglist->ti_Tag  = tag;
   taglist->ti_Data = value;   

   return;
}

/****h* FGetS() [1.0] **********************************************
*
* NAME
*    FGetS()
*
* SYNOPSIS
*    char *str = FGetS( char *buffer, int readlength, FILE *fptr );
*
* DESCRIPTION
*    This function is identical to the C library function fgets()
*    except that it changes the \n at the end of a line to a \0.
********************************************************************
*
*/

PUBLIC char *FGetS( char *buffer, int length, FILE *fileptr )
{
   char *rval = NULL, *cp = NULL;
   int   len  = 0;
   
   rval = fgets( buffer, length, fileptr );
   
   if (rval)
      {
      len = StringLength( buffer ) - 1;
      
      cp = &buffer[ len ];
      
      if (*cp == '\n')
         *cp = '\0';
      }

   return( rval );
}

/****h* HideListFromView() ******************************************
*
* NAME
*    HideListFromView()
*
* SYNOPSIS
*    void HideListFromView( struct Gadget *listview_gadget,
*                           struct Window *window_pointer
*                         );
*
* DESCRIPTION
*    Turn off the Given ListView Gadget for the window, so that it
*    can be modified elsewhere.
*
* SEE ALSO
*    ModifyListView()
*********************************************************************
*
*/ 

PUBLIC void HideListFromView( struct Gadget *lv, struct Window *w )
{
   BOOL openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return;
      else
         openedLibs = TRUE;
      }

   if ( !lv || !w )
      return; // Short-circuit NULL pointer problems!
      
   GT_SetGadgetAttrs( lv, w, NULL, GTLV_Labels, ~0, TAG_DONE );

   if (openedLibs == TRUE)
      CloseLibs();
      
   return;
}

/****h* ModifyListView() ********************************************
*
* NAME
*    ModifyListView()
*
* SYNOPSIS
*    void ModifyLsitView( struct Gadget *listview_gadget,
*                         struct Window *window_pointer,
*                         struct List   *listview_contents,
*                         struct Gadget *string_gadget
*                       ); 
*
* DESCRIPTION
*    Change the Given ListView Gadget for the window to the 
*    new parameters, which will re-display it.
*
* SEE ALSO
*    HideListFromView()
*********************************************************************
*
*/ 

PUBLIC void ModifyListView( struct Gadget *lv, 
                            struct Window *w,
                            struct List   *list,
                            struct Gadget *strgadget
                          )
{
   BOOL openedLibs = FALSE;

   if (checkForLibs() == FALSE)
      {
      if (OpenLibs() < 0)
         return;
      else
         openedLibs = TRUE;
      }

   if ( !lv || !w )
      return;
   
   if (!list)
      GT_SetGadgetAttrs( lv, w, NULL,
                         GTLV_Labels,       (ULONG) ~0,
                         GTLV_ShowSelected, strgadget,
                         GTLV_Selected,     0,
                         TAG_DONE
                       );
   else
      GT_SetGadgetAttrs( lv, w, NULL,
                         GTLV_Labels,       list,
                         GTLV_ShowSelected, strgadget,
                         GTLV_Selected,     0,
                         TAG_DONE
                       );

   if (openedLibs == TRUE)
      CloseLibs();

   return;
}

/* ---------------- END of CommonFuncs.c file! ----------------------- */

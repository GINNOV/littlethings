/****h* Author.h [1.0] ************************************************
*
* NAME
*    Author.h
*
* DESCRIPTION
*    Information strings about the Author.
*
* AUTHOR
*    James T. Steichen (jimbot@frontiernet.net)
***********************************************************************
*
*/

#ifndef  AUTHOR_H
# define AUTHOR_H  1

# ifndef  PUBLIC

#  define PUBLIC            // Aliases for global
#  define VISIBLE

#  define PRIVATE static    // Aliases for static 
#  define SUBFUNC PRIVATE

#  define IMPORT  extern    // Aliases for extern

# endif

# ifdef ALLOCATE

PUBLIC const char authorEMail[]     = "jimbot@frontiernet.net";

PUBLIC const char authorName[]      = "Jim Steichen";
PUBLIC const char authorAddress[]   = "2217 N. Tamarack Dr.";
PUBLIC const char authorCity[]      = "Slayton";
PUBLIC const char authorState[]     = "Mn., USA";
PUBLIC const char authorZipCode[]   = "56172-1155";

PUBLIC const char authorHomePhone[] = "(507) 836-6369";
PUBLIC const char authorFaxPhone[]  = "(507) 836-6694";

# else

IMPORT const char authorEMail[];

IMPORT const char authorName[];
IMPORT const char authorAddress[];
IMPORT const char authorCity[];
IMPORT const char authorState[];
IMPORT const char authorZipCode[];

IMPORT const char authorHomePhone[];
IMPORT const char authorFaxPhone[];

# endif
 
#endif

/* ------------------- END of Author.h file! ------------------------ */

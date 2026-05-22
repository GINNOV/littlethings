/***************************************************************************

   Program:    ansi
   File:       ansi.c
   
   Version:    V1.6
   Date:       16.12.91
   Function:   Convert C source to and from ANSI form.
   
   Copyright:  SciTech Software 1991
   Author:     Andrew C. R. Martin
   Address:    SciTech Software
               23, Stag Leys,
               Ashtead,
               Surrey,
               KT21 2TD.
   Phone:      +44 (0372) 275775
   EMail:      UUCP: cbmuk!cbmuka!scitec!amartin
               JANET: andrew@uk.ac.ox.biop
               
****************************************************************************

   This program is not in the public domain, but it may be freely copied
   and distributed for no charge providing this header is included.
   The code may be modified as required, but any modifications must be
   documented so that the person responsible can be identified. If someone
   else breaks this code, I don't want to be blamed for code that does not
   work! The code may not be sold commercially without prior permission from
   the author, although it may be given away free with commercial products,
   providing it is made clear that this program is free and that the source
   code is provided with the program.

****************************************************************************

   Description:
   ============

   This program alters function definitions to convert non-ANSI C code to 
   ANSI form. The -k and -p flags allow conversion from ANSI to K&R and
   generation of prototypes respectively.
   
   There are two *minor* problems:
   1. In generation of prototypes. If a function has been defined with no 
   explicit type it defaults to being int. Strictly the prototype should 
   explicitly state this is int, but doesn't.
   2. If a conversion actually occurs (either to or from ANSI) any comments
   which were in the definition will be lost.
   
   The only restriction (that I can think of!) on the code being processed
   is that a function definition must be the first thing on a line.
   i.e. if a comment is placed on the same line as the definition but before
   it, the program will think the whole line is a comment.
   
****************************************************************************

   Usage:
   ======

   ansi [-k -p] <in.c> <out.c>
         -k generates K&R form code from ANSI
         -p generates a set of prototypes

****************************************************************************

   Revision History:
   =================
   
   V1.0  17.12.91
   Added support for prototype and K&R code generation. Also reorganised 
   some code.
   
   V1.1  21.01.92
   A little tidying for VAX and slightly more useful error messages when
   making ANSI and failing to find parameter definition---this spots bugs!
   
   V1.2  14.02.92
   Fixed a bug whereby variable names which were subsets of the associated
   type were not being found correctly.
   e.g. func(o,w) struct obs *o; struct wor *w; { }
   did not inherit *'s correctly in the ANSI version.
   Introduced FindVarName() for this purpose.
   Also added version string.

   V1.3  19.02.92
   Fixed reported bug in Ansify() where KR definitions containing
   comments between variables with a single type declaration were handled 
   wrongly.
   
   V1.4  18.03.92
   Fixed bug reported by Bob Bruccoleri in process_file(). If a comment
   on the line of an external variable definition contained a (, the code
   would think this was a prototype definition and get very confused.
   Now kills the comments before testing for the presence of a (.
   Improved function definition comments.
   
   V1.5  26.03.92
   Fixed same bug as in V1.2, but for ANSI-->K&R; variable names, if a
   subset of a type name were getting picked up incorrectly.
   
   V1.6  01.04.92
   Small change to comments to work with my autodoc program.
   
***************************************************************************/
/* System includes
*/
#include <stdio.h>
#include <string.h>

#ifdef AMIGA
#include <exec/types.h>

#else /* Not an Amiga */
typedef short BOOL;
#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif
#endif

/**************************************************************************/
#define MAXBUFF      200   /* Max chars in a line                         */
#define MAXLINES     50    /* Max lines in a function definition          */
#define DIC          34    /* Double inverted commas                      */
#define SIC          39    /* Single inverted commas                      */
#define LF           10    /* Line feed                                   */
#define CR           13    /* Carriage return                             */
#define MakeANSI     1     /* K&R-->ANSI                                  */
#define MakeKR       2     /* ANSI-->K&R                                  */
#define MakeProtos   3     /* Make prototypes                             */

#define toggle(x) (x) = abs((x)-1)

/**************************************************************************/
/* Prototypes
*/
int   main(int argc,
           char **argv);
int   GetVarName(char *buffer,
                 char *strparam);
void  process_file(FILE *fp_in,
                   FILE *fp_out,
                   int mode);
int   isInteresting(char *buffer);
void  Ansify(FILE *fp,
             char funcdef[MAXLINES][MAXBUFF], 
             int ndef,
             int mode);
int   WriteANSI(FILE *fp,
              char *varname,
              char *definitions);
char  *FindString(char *buffer,
                  char *string);
char  *FindVarName(char *buffer,
                   char *string);
int   isFunc(char funcdef[MAXLINES][MAXBUFF], 
            int ndef);
void  terminate(char *string);
void  DeAnsify(FILE *fp_out, 
               char funcdef[MAXLINES][MAXBUFF], 
               int  ndef);
void  WriteKR(FILE *fp,
              char *varname,
              char *definitions);
void  KillComments(char *buffer);
/**************************************************************************/
/* Version string
*/
#ifdef AMIGA
UBYTE *vers="\0$VER: ansi 1.5";
#endif

/**************************************************************************/
main(int  argc,
     char **argv)
{
   int   mode        = MakeANSI;
   BOOL  noisy       = TRUE;
   FILE  *fp_in      = NULL,
         *fp_out     = NULL;
   
   if(argc < 3)
   {
      printf("\nUsage: ansi [-k -p -q] <in.c> <out.c>\n");
      printf("       Converts a K&R style C file to ANSI or vice versa\n");
      printf("       -k generates K&R form code from ANSI\n");
      printf("       -p generates a set of prototypes\n");
      printf("       -q quiet mode\n\n");
      
      exit(0);
   }
   
   /* Parse the command line */
   argv++;
   while(--argc > 2)
   {
      if(argv[0][0] == '-')
      {
         switch(argv[0][1])
         {
         case 'k':
         case 'K':
            mode = MakeKR;
            break;
         case 'p':
         case 'P':
            mode = MakeProtos;
            break;
         case 'q':
         case 'Q':
            noisy = FALSE;
            break;
         default:
            printf("Unknown switch %s\n",argv[0]);
            exit(0);
         }
      }
      else
      {
         printf("Invalid switch %s\n",argv[0]);
         exit(0);
      }
      argv++;
   }
   
   /* Open files */
   if((fp_in = fopen(argv[0],"r")) == NULL)
   {
      printf("Unable to open input file %s\n",argv[0]);
      exit(1);
   }
   if((fp_out = fopen(argv[1],"w")) == NULL)
   {
      printf("Unable to open output file %s\n",argv[1]);
      exit(1);
   }

   /* Give a message */
   if(noisy)
   {
      printf("SciTech Software ansi C converter V1.5\n");
      printf("Copyright (C) 1991 SciTech Software. All Rights Reserved.\n");
      printf("This program is freely distributable providing no profit is made in so doing.\n\n");
      switch(mode)
      {
      case MakeANSI:
         printf("Converting file %s to ANSI\n",argv[0]);
         break;
      case MakeKR:
         printf("Converting file %s to Kernighan and Ritchie\n",argv[0]);
         break;
      case MakeProtos:
         printf("Generating prototypes for file %s\n",argv[0]);
         break;
      default:
         break;
      }
   }

   /* Now process the files as required by the flags */
   process_file(fp_in, fp_out, mode);
   
   exit(0);    /* V1.1, for VAX clean-ness */
   return(0);
}

/*>**********************************************************************
GetVarName(buffer, strparam)
----------------------------
Input:   char     *buffer        A character string
Output:  char     *strparam      Returned character string
Returns: int                     Number of characters pulled out
                                 of the buffer string

This routine returns the first , or ) delimited group of characters
from character string `buffer'
*************************************************************************/
int GetVarName(char *buffer,
               char *strparam)
{
   int   i,
         j  = 0;

   for(i=0;buffer[i];i++)
   {
      /* Break out if we've got a , or ) */
      if(buffer[i]==',' || buffer[i]==')') break;

      /* Otherwise copy the character */
      strparam[j++] = buffer[i];
   }
   strparam[j]='\0';
   
   /* Strip any trailing spaces */
   for(j=strlen(strparam) - 1 ;
       j >= 0 && (strparam[j] == ' ' || strparam[j] == '\t');
       j--)
      strparam[j] = '\0';

   return(i);
}


/*>*************************************************************************
process_file(fp_in, fp_out, mode)
---------------------------------
Input:   FILE     *fp_in         File to be processed
         FILE     *fp_out        Output file being created
         int      mode           Processing mode.
                                 MakeANSI:   Create ANSI
                                 MakeKR:     Create K&R
                                 MakeProtos: Create prototypes
Returns: void

Does the work of processing the file. Calls routines to see if this line is
interesting. If so assembles the function or prototype definition. Calls
check to see if its really a function definition and, if so, routines to
process and convert.
***************************************************************************/
void process_file(FILE *fp_in,
                  FILE *fp_out,
                  int mode)
{
   /* These are static so they're not placed on the stack. This lets
      us run with the default stack size on the Amiga
   */
   static char buffer[MAXBUFF],
               buffer2[MAXBUFF],             /* V1.4 */
               funcdef[MAXLINES][MAXBUFF];
   int  i,
        ndef;
   
   while(fgets(buffer,MAXBUFF,fp_in))
   {
      terminate(buffer);

      /* See if this line is possibly a function definition */
      if(isInteresting(buffer))
      {
         /* It's one of:
            (a)   A function definition
            (b)   A prototype
            (c)   An external
            
            To be a function, it must contain a (, though this could be
            a prototype.
         */

         /* V1.4+: Previously would think the line was a function or
            prototype if there was a ( in a comment on the same line
         */
         strcpy(buffer2,buffer);
         KillComments(buffer2);
         /* V1.4- */
         
         if(strchr(buffer2,'(') != NULL)  /* V1.4 Test buffer2 */
         {
            /* It's a function or a prototype. Copy it into funcdef
               assembling additional strings up to the first ; or {
            */
            strcpy(funcdef[0], buffer);
            ndef=0;
            while(strchr(funcdef[ndef],';') == NULL  &&
                  strchr(funcdef[ndef],'{') == NULL)
            {
               if(!fgets(funcdef[++ndef],MAXBUFF,fp_in)) break;
               terminate(funcdef[ndef]);
               if(ndef >= MAXLINES)
               {
                  printf("Too many lines in function definition:\n");
                  for(i=0; i<MAXLINES; i++)
                     printf("%s\n",funcdef[i]);
                  exit(1);
               }
               /* Pass the string to isInteresting() to update internal
                  count of comments, brackets, etc. We don't care about
                  the return value.
               */
               isInteresting(funcdef[ndef]);
            }

            if(isFunc(funcdef,ndef))
            {
               /* It's actually a function.
                  If it was terminated by a ; we must assemble up to
                  a {
               */
               if(strchr(funcdef[ndef],';') != NULL  &&
                  strchr(funcdef[ndef],'{') == NULL)
               {
                  while(strchr(funcdef[ndef],'{') == NULL)
                  {
                     if(!fgets(funcdef[++ndef],MAXBUFF,fp_in)) break;
                     if(ndef >= MAXLINES)
                     {
                        printf("Too many lines in function definition:\n");
                        for(i=0; i<MAXLINES; i++)
                           printf("%s\n",funcdef[i]);
                        exit(1);
                     }
                     terminate(funcdef[ndef]);
                     /* Pass the string to isInteresting() to update 
                        internal count of comments, brackets, etc. We 
                        don't care about the return value.
                     */
                     isInteresting(funcdef[ndef]);
                  }
               }
               
               /* Now actually ANSIfy, deANSIfy, or generate prototypes.
                  Output to fp_out
               */
               switch(mode)
               {
               case MakeKR:
                  DeAnsify(fp_out, funcdef, ndef);
                  break;
               case MakeANSI:
               case MakeProtos:
                  Ansify(fp_out, funcdef, ndef, mode);
                  break;
               default:
                  printf("Internal confusion!!!\n");
                  break;
               }
            }
            else
            {
               /* It's a prototype, so copy each line out */
               if(mode != MakeProtos)
               {
                  for(i=0; i<=ndef; i++)
                     fprintf(fp_out,"%s\n",funcdef[i]);
               }
            }
         }
         else
         {
            /* It's an extern, so just copy it */
            if(mode != MakeProtos) fprintf(fp_out,"%s\n",buffer);
         }
      }
      else
      {
         /* We're in a #, comment, string, function or blank line.
            Simply copy the line to the output file.
         */
         if(mode != MakeProtos) fprintf(fp_out,"%s\n",buffer);
      }
   }
}

/*>*************************************************************************
isInteresting(buffer)
---------------------
Input:   char     *buffer        Line from file
Returns: int                     1: Line is interesting-may be a function
                                 0: Line not interesting

Tries to determine whether a line is possibly a function definition.
Does this by checking, on entry, that we're not a blank line, not in a 
comment, between double or single inverted commas and not already in a 
function definition.
***************************************************************************/
int isInteresting(char *buffer)
{
   static int  comment_count  = 0,
               bra_count      = 0,
               inSIC          = 0,
               inDIC          = 0;
   
   int i,
       retval  = 0,
       isBlank = TRUE;

   /* Not interested if it's a #define, etc. */
   if(buffer[0] == '#') return(0);

   /* If all of these are unset when we enter, we're interested */
   if(!bra_count && !inDIC && !inSIC && !comment_count) retval = 1;

   /* If the first thing in this string was a comment we're no longer
      interested.
   */
   for(i=0; buffer[i] && (buffer[i] == ' ' || buffer[i] == '\t'); i++);
   if(buffer[i] == '/' && buffer[i+1] == '*') retval = 0;

   /* Step along the line */
   for(i=0; i<strlen(buffer); i++)
   {
      /* We're not interested in anything else if this is a
         C++ style comment
      */
      if(buffer[i] == '/' && buffer[i+1] == '/') return(0);

      if(buffer[i] != ' ' && buffer[i] != '\t') isBlank = FALSE;
      
      /* See if we're moving into a string */
      if((buffer[i] == DIC) && (comment_count==0) && !inSIC) toggle(inDIC);
      if((buffer[i] == SIC) && (comment_count==0) && !inDIC) 
      {
         toggle(inSIC);
      }
      
      /* If we're not in a string */
      if(!inDIC && !inSIC)
      {
         /* See if we're moving into a comment */
         if((buffer[i] == '/') && (buffer[i+1] == '*')) comment_count++;
         /* See if we're moving out of a comment */
         if((buffer[i] == '*') && (buffer[i+1] == '/')) comment_count--;
         
         /* If we're not in a comment we must be in code.
            Update the curly bracket count
         */
         if(!comment_count)
         {
            if(buffer[i] == '{') bra_count++;
            if(buffer[i] == '}') bra_count--;
         }
      }
   }
   
   /* If it's a blank line, we're not interested */
   if(isBlank) retval = 0;

   return(retval);
}
         

/*>*************************************************************************
Ansify(fp, funcdef, ndef, mode)
-------------------------------
Input:   FILE     *fp            File to create
         char     funcdef[][]    Function definition lines
         int      ndef           Number of definition lines
         int      mode           Processing mode-generate ANSI or prototypes
                                 MakeANSI:   Create ANSI
                                 MakeProtos: Create prototypes

If it's already ANSI, just writes it; otherwise assembles function into
a single buffer line, writes the function name and calls WriteANSI() to
write the definition of each variable.
***************************************************************************/
void Ansify(FILE *fp,
            char funcdef[MAXLINES][MAXBUFF],
            int  ndef,
            int  mode)
{
   int   i,
         j,
         width,
         isANSI   = TRUE,
         bufflen  = 0,
         first    = TRUE;
   char  *buffer  = NULL,
         *bufptr,
         *funptr,
         temp[MAXBUFF],
         func[MAXBUFF],
         varname[80];
   
   ndef++;
   
   /* If none of the lines contains a ;, it's already ANSI */
   for(i=0; i<ndef; i++)
   {
      if(strchr(funcdef[i], ';') != NULL)
      {
         isANSI = FALSE;
         break;
      }
   }
   
   if(isANSI)
   {
      /* It's already ANSI */
      if(mode == MakeANSI)
      {
         /* We're making ANSI, so just output it */
         for(i=0; i<ndef; i++) fprintf(fp, "%s\n", funcdef[i]);
      }
      else  /* mode == makeProtos */
      {
         /* We're making prototypes, just output, but put a ; instead
            of a {
         */
         for(i=0; i<ndef; i++)
         {
            for(j=0; j<strlen(funcdef[i]); j++)
            {
               if(funcdef[i][j] != '{')
               {
                  putc(funcdef[i][j], fp);
               }
               else
               {
                  putc(';', fp);
                  i = ndef;
                  break;
               }
            }
            putc('\n', fp);
         }
      }
   }
   else     /* It's not ANSI, so we convert it. */
   {
      /* First allocate some memory */
      for(i=0; i<ndef; i++) bufflen += strlen(funcdef[i]);
      bufflen += 2;
      buffer = (char *)malloc(bufflen * sizeof(char));
      buffer[0] = '\0';
      
      /* Now build all the strings into the single buffer */
      for(i=0; i<ndef; i++) strcat(buffer, funcdef[i]);
      
      /* V1.3
         Remove comments
      */
      KillComments(buffer);

      /* Copy the function part into func */
      for(i=0; buffer[i] != ')'; i++) func[i] = buffer[i];
      func[i]     = ')';
      func[i+1]   = '\0';
      
      /* Find the first (, copy up to here and print it */
      for(i=0; func[i] != '('; i++) temp[i] = func[i];
      temp[i]     = '(';
      temp[i+1]   = '\0';
      width       = strlen(temp);
      fprintf(fp,"%s",temp);
      
      /* Set bufptr to point to the buffer excluding the function def */
      bufptr = strchr(buffer, ')') + 1;
      
      /* Set funptr to point to start of parameter list */
      funptr = strchr(func, '(') + 1;
      
      /* Step through the parameter list getting a parameter at a time */
      first = TRUE;
      while(*funptr && *funptr != ')')
      {
         if(!first)
         {
            fprintf(fp,",\n");
            for(i=0;i<width;i++) fprintf(fp," ");
         }
         first = FALSE;
         /* Kill spaces */
         for( ; funptr && (*funptr == ' ' || *funptr == '\t'); funptr++) ;
         /* Get a parameter */
         funptr += GetVarName(funptr, varname) + 1;
         /* Write the ANSI version */
         if(WriteANSI(fp, varname, bufptr))   /* V1.1 */
         {
            /* Returns 1, if there was a problem */
            temp[strlen(temp)-1] = '\0';
            printf("   %s()\n",temp);
         }
      }
      
      if(mode == MakeANSI)
         fprintf(fp,")\n{\n");
      else  /* mode == MakeProtos */
         fprintf(fp,");\n");
      
      /* Free memory */
      free(buffer);
   }
}

/*>*************************************************************************
WriteANSI(fp, varname, definitions)
-----------------------------------
Input:   FILE     *fp            File being written
         char     *varname       Variable name being processed
         char     *definitions   Assembled KR definitions.
Returns: int                     0: if all OK; 1: if a problem

Creates an ANSI definition from the KR definition and writes it into the
parameter list.
***************************************************************************/
int WriteANSI(FILE *fp,
              char *varname,
              char *definitions)
{
   char  *start,
         *stop,
         *ptr,
         buffer[MAXBUFF];
   int   i;
        
/*** Find the variable type ***/

   /* Set these to the position of varname in the definitions list */
   start = stop = FindVarName(definitions, varname);  /* V1.2 */
   
   if(!start)
   {
      printf("Parameter `%s' was not found in definitions for function:\n",varname);
      return(1);
   }
   
   /* Step start back to the start of the list, or the preceeding ; */
/***V1.3+
/ /   while(start > definitions && *start != ';' && *start != '/') start--;
/ /   if(*start == ';' || *start == '/') start++;
*/
   while(start > definitions && *start != ';') start--;
   if(*start == ';') start++;

/***V1.3-   */
   
   /* Kill any leading spaces */
   while(*start && (*start == ' ' || *start == '\t')) start++;
   
   /* If there are any commas between start and stop, move stop
      back to the first comma
   */
   for(ptr=start; ptr<=stop; ptr++)
   {
      if(*ptr == ',')
      {
         stop = ptr;
         break;
      }
   }
   
   /* Step stop on to the first , or ; */
   while(*stop && *stop != ',' && *stop != ';') stop++;

   /* Now step back over any spaces */
   stop--;
   while(stop > start && (*stop == ' ' || *stop == '\t')) stop--;
   
   /* Now step back over the first variable name */
   while(stop > start && *stop != ' ' && *stop != '\t') stop--;
   
   /* and over the spaces preceeding it */
   while(stop > start && (*stop == ' ' || *stop == '\t')) stop--;
   
   /* Now copy the string delimited by start and stop */
   for(i=0; i<MAXBUFF && start <= stop; i++, start++)
      buffer[i] = *start;

   /* Terminate and print it */
   buffer[i] = '\0';
   fprintf(fp,"%s ",buffer);
   
/*** Now print the variable name with *'s if appropriate ***/

   /* Set this to the position of varname in the definitions list */
   start = FindVarName(definitions, varname);  /* V1.2 */
   
   /* Step start back to the first non-space character */
   start--;
   while(start > definitions && (*start == ' ' || *start == '\t')) start--;
   
   while(*(start--) == '*')
      fprintf(fp,"*");

   fprintf(fp,"%s",varname);
   
/*** Finally see if it's a [] array ***/
   /* Set these to the position of varname in the definitions list */
   start = stop = FindVarName(definitions, varname);  /* V1.2 */

   /* Step stop on to the first , or ; */
   while(*stop && *stop != ',' && *stop != ';') stop++;

   /* Now step back over any spaces */
   stop--;
   while(stop > start && (*stop == ' ' || *stop == '\t')) stop--;
   
   /* See if there is a [ between start and stop */
   while(start<stop && *start != '[') start++;
   
   /* If a [ was found copy and print the string */
   if(start < stop)
   {
      for(i=0; i<MAXBUFF && start <= stop; i++, start++)
         buffer[i] = *start;

      /* Terminate and print it */
      buffer[i] = '\0';
      fprintf(fp,"%s",buffer);
   }
   
   return(0);  /* V1.1, all OK */
}

/*>*************************************************************************
FindString(buffer, string)
--------------------------
Input:   char     *buffer        Buffer being searched
         char     *string        String to search for
Returns: *char                   Pointer to start of string in buffer

Searches for a string in another string returning a pointer to the start
of the string.
***************************************************************************/
char *FindString(char *buffer,
                 char *string)
{
   char  *ptr;
   int   ok = FALSE,
         i;
   
   ptr = buffer;
   
   while(!ok)
   {
      /* Step ptr along buffer till we find first character of string */
      while(*ptr && *ptr != *string) ptr++;

      /* Return NULL if we didn't find it */
      if(*ptr == '\0') return((char *)NULL);
      
      /* Now compare the rest of the string */
      ok = TRUE;
      for(i=0; i<strlen(string); i++)
      {
         if(ptr[i] != string[i])
         {
            ok = FALSE;
            break;
         }
      }
      ptr++;
   }
   return(--ptr);
}
/*>*************************************************************************
FindVarName(buffer, string)
---------------------------
Input:   char     *buffer        Buffer being searched
         char     *string        String to search for
Returns: *char                   Pointer to start of string in buffer

Works like FindString(), but imposes the additional condition that the
string must be preceded by a space or * and must be followed by one of
space ; [ ) or ,

Added for V1.2
***************************************************************************/
char *FindVarName(char *buffer,
                  char *string)
{
   char  *ptr;
   int   ok = FALSE,
         i;
   
   ptr = buffer;
   
   while(!ok)
   {
      /* Step ptr along buffer till we find first character of string with
         a space or * before it.
      */
      ptr--;
      do
      {
         ptr++;
         while(*ptr && *ptr != *string) ptr++;
      }  while(*ptr && *(ptr-1) != ' ' && *(ptr-1) != '*' && *(ptr-1) != ',');

      /* Return NULL if we didn't find it */
      if(*ptr == '\0') return((char *)NULL);
      
      /* Now compare the rest of the string */
      ok = TRUE;
      for(i=0; i<strlen(string); i++)
      {
         if(ptr[i] != string[i])
         {
            ok = FALSE;
            break;
         }
      }
      
      /* Check the character after the string */
      if(*(ptr+i) != ';' && *(ptr+i) != '[' && 
         *(ptr+i) != ' ' && *(ptr+i) != ')' && *(ptr+i) != ',') ok = FALSE;

      ptr++;
   }
   return(--ptr);
}
/*>*************************************************************************
isFunc(funcdef, ndef)
---------------------
Input:   char     funcdef[][]    Array of lines forming function definition
         int      ndef           Number of lines
Returns: int                     1: This is a function
                                 0: Not a function

Determines whether a possible function definition identified by 
isInteresting() really is a function.
***************************************************************************/
int isFunc(char funcdef[MAXLINES][MAXBUFF],
           int  ndef)
{
   char  *termchar;
   int   line,
         retval;
   
   /* If it's a prototype, it will not be terminated by a { */
   if(strchr(funcdef[ndef],'{') != NULL) return(1);
   
   /* It's now either a prototype or a K&R function defintion.
      To be a prototype, the first non-space character before the
      ; must be a )
      
      Step backwards.
   */
   line = ndef;
   for(;;)
   {
      termchar = strchr(funcdef[line],';') - 1;
      while(termchar >= funcdef[line] && 
            (*termchar == ' ' || *termchar == '\t'))
         termchar--;
      
      /* If we stepped back beyond the start of the line, go to the
         previous line
      */
      if(termchar < funcdef[line])
      {
         line--;
         if(line < 0) break;
         termchar = funcdef[line] + strlen(funcdef[line]);
      }
      else
      {
         break;
      }
   }
   
   /* OK, see if the character was a ) */
   if(*termchar == ')')
      retval = 0;
   else
      retval = 1;
      
   return(retval);
}

/*>***********************************************************************
terminate(string)
-----------------
I/O:     char     *string        A character string
Returns: void

Terminates a string at the first \n
*************************************************************************/
void terminate(char *string)
{
   int i;
   
   for(i=0;string[i];i++)
   {
      if(string[i] == '\n')
      {
         string[i] = '\0';
         break;
      }
   }
}
/*>***********************************************************************
DeAnsify(fp, funcdef, ndef)
---------------------------
Input:   FILE     *fp            File being written
         char     funcdef[][]    Function definition array
         int      ndef           Number of definition lines
Returns: void

Writes a K&R function definition from the ANSI (or K&R) form in funcdef.
If it's already K&R, just writes it; otherwise assembles function into
a single buffer line, writes the function name and calls WriteKR() to
write the definition of each variable.
*************************************************************************/
void DeAnsify(FILE *fp, 
              char funcdef[MAXLINES][MAXBUFF], 
              int  ndef)
{
   int   i,
         j,
         nparam,
         isKR     = FALSE,
         bufflen  = 0,
         last     = FALSE;
   char  *buffer  = NULL,
         *bufptr,
         *funptr,
         *ptr,
         *start,
         *stop,
         temp[MAXBUFF],
         func[MAXBUFF],
         varname[80];
   
   ndef++;
   
   /* If any of the lines contains a ;, it's already KR */
   for(i=0; i<ndef; i++)
   {
      if(strchr(funcdef[i], ';') != NULL)
      {
         isKR = TRUE;
         break;
      }
   }
   
   if(isKR)
   {
      /* It's already KR, so just output it */
      for(i=0; i<ndef; i++) fprintf(fp, "%s\n", funcdef[i]);
   }
   else     /* It's not KR, so we convert it. */
   {
      /* First allocate some memory */
      for(i=0; i<ndef; i++) bufflen += strlen(funcdef[i]);
      bufflen += 2;
      buffer = (char *)malloc(bufflen * sizeof(char));
      buffer[0] = '\0';
      
      /* Now build all the strings into the single buffer ignoring comments */
      for(i=0; i<ndef; i++) strcat(buffer,funcdef[i]);

      /* Find the first (, copy up to here and print it */
      for(i=0; buffer[i] != '('; i++) temp[i] = buffer[i];
      temp[i]     = '(';
      temp[i+1]   = '\0';
      fprintf(fp,"%s",temp);
      
      /* Set bufptr to point to the buffer excluding the function name */
      bufptr = strchr(buffer, '(') + 1;
      
      /* Count the number of commas in the parameter list */
      nparam = 0;
      for(funptr = bufptr; *funptr && *funptr != ')'; funptr++)
         if(*funptr == ',') nparam++;
         
      if(nparam)
      {
         /* If there were *any* commas, the number of parameters is one
            more than the number of commas
         */
         nparam++;
      }
      else
      {
         /* If there weren't any commas, there are either 0 or 1 params.
            If there's only white space, or `void' between the ( and ) 
            there are 0 parameters. Otherwise, there's 1
         */
         if(FindString(bufptr,"void") || FindString(bufptr,"VOID"))
         {
            nparam = 0;
         }
         else
         {
            for(funptr = bufptr; *funptr && *funptr != ')'; funptr++)
            {
               if(*funptr != ' ' && *funptr != '\t')
               {
                  nparam = 1;
                  break;
               }
            }
         }
      }
      
      /* If there weren't any parameters we can just output a closing
         parenthesis an opening { and return.
      */
      if(nparam==0)
      {
         fprintf(fp,")\n{\n");
         free(buffer);
         return;
      }

      /* Step through the parameter list getting a parameter at a time.
         Assemble these into func.
         The variable names are delimited by a , a [ or the closing )
      */
      func[0] = '\0';
      funptr = bufptr;
      for(i=0; i<nparam; i++)
      {
         /* Step funptr on to the next , or ) */
         if((funptr = strchr(funptr,',')) == NULL)
         {
            funptr = strchr(bufptr,')');
            last = TRUE;
         }
         
         /* Step back over any spaces */
         stop = funptr-1;
         while(stop>bufptr && (*stop==' ' || *stop=='\t')) stop--;
         
         /* Step back to the start of the variable name */
         start = stop;
         while(start>=bufptr && *start!=' ' && *start!='\t' && *start != '*')
            start--;
         start++;
         
         /* Copy the variable name into our function buffer adding 
            a , and space or ) as appropriate.
         */
         for(j=0; start<=stop; start++, j++)
            temp[j] = *start;
         temp[j] = '\0';

         if((ptr = strchr(temp,'[')) != NULL)
            *ptr = '\0';
            
         if(last)
            strcat(temp,")");
         else
            strcat(temp,", ");
         
         strcat(func, temp);
         funptr++;
      }
      
      /* We can now echo the parameter list to the output file */
      fprintf(fp,"%s\n",func);

      /* Work through the parameter list writing the parameter 
         definition lines
      */
      funptr = func;
      while(*funptr && *funptr != ')')
      {
         /* Kill spaces */
         for( ; funptr && (*funptr == ' ' || *funptr == '\t'); funptr++) ;
         /* Get a parameter */
         funptr += GetVarName(funptr, varname) + 1;
         /* Write the K&R version */
         WriteKR(fp, varname, bufptr);
      }
      
      fprintf(fp,"{\n");

      /* Free memory */
      free(buffer);
   }
}

/*>*************************************************************************
WriteKR(fp, varname, definitions)
---------------------------------
Input:   FILE     *fp            File being written
         char     *varname       Variable being processed
         char     *definitions   ANSI style definitions
Returns: void

Writes a variable definition in K&R form by extracting information from
the ANSI definition.
***************************************************************************/
void WriteKR(FILE *fp,
             char *varname,
             char *definitions)
{
   char  *start,
         *stop,
         temp[MAXBUFF];
   int   i;
   
   /* Find the variable name in the definitions */
/*** V1.5+
/ / start = stop = FindString(definitions,varname);
*/
   start = stop = FindVarName(definitions,varname);
/*** V1.5- */
   
   /* Step start back to the preceeding , / or (, then forward 
      over any spaces
   */
   while(start >= definitions && *start != '(' && 
         *start != ',' && *start != '/')
      start--;
   start++;
   while(start<stop && (*start==' ' || *start=='\t')) start++;
   
   /* Step stop on to the following , or ) */
   while(*stop && *stop != ')' && *stop != ',') stop++;
   stop--;
   
   /* Copy the variable definition, add a ; and output. */
   for(i=0; start<=stop; start++, i++)
      temp[i] = *start;
   temp[i]     = ';';
   temp[i+1]   = '\0';

   fprintf(fp,"%s\n",temp);
}

/*>*************************************************************************
KillComments(buffer)
--------------------
I/O:     char     *buffer        String from which to remove any comments
Returns: void

Takes a string and removes any section enclosed in comments.

Added for V1.3
***************************************************************************/
void KillComments(char *buffer)
{
   int   in       = 0,
         out      = 0,
         comment  = 0,
         len;
   
   len = strlen(buffer);
   
   for(in=0;in<len;in++)
   {
      if(buffer[in]   == '/' && buffer[in+1] == '*') comment++;
      if(buffer[in-2] == '*' && buffer[in-1] == '/') comment--;
      
      if(!comment) buffer[out++] = buffer[in];
   }
   
   buffer[out] = '\0';
}


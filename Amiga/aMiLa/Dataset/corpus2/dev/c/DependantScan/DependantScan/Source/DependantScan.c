#define DEF_DEPENDANTSCAN_C

#include <exec/types.h>
#include <exec/memory.h>
#include <utility/tagitem.h>
#include <dos/dosasl.h>
#include <proto/icon.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>
#include <string.h>

#include "ProcessDirectory.h"
#include "DependantScan.h"
#include "RequesterError.h"
#include "LocaleSupport.h"

char *DPSArgument[DPS_ARG_COUNT];                              /* arguments parsed from the command line or our icon */
char DPSParsedPattern[255];                                    /* the file pattern we are matching */
int FilesOnLine;                                               /* number of files mentioned on the current line */
FILE *OutputStream = NULL;                                     /* the file we are writing to */
struct LOCALE_SUPPORT_CATALOG *DPSCatalog;                     /* alternate language catalog used by this program */

/*
   char *wrap_files(
      char *in_between)                                        what we are putting between files

   * Description
      This function will continue the make file on the next line if there are too many files on the current line.
*/
char *wrap_files(
   char *in_between)                                           /* what we are putting between files */
{
   if (FilesOnLine++ == *(LONG *)DPSArgument[DPS_ARG_FILESONLINE])                              /* if this is the last file to be printed on this line */
   {
      if (!strcmp(in_between," "))                             /* if we are building the project dependency list */
         fprintf(OutputStream,"\\\n");                         /* then, this is how to continue the line */
      else if (!strcmp(in_between," + "))                      /* if we are building the link object list */
         fprintf(OutputStream," +\\\n");                       /* continue the line this way */
      else                                                     /* we don't know what we are doing */
         fprintf(OutputStream,"%s\\\n",in_between);            /* continue the line in a generic way */

      in_between = "";                                         /* put the next file at the beginning of the next line */
      FilesOnLine = 1;                                         /* reset the counter */
   }

   return (in_between);                                        /* tell caller to use this before the next file */
}

/*
   int dpscan_pass1(
      struct AnchorPath *anchor,                               file being processed
      char *path,                                              the pathname (including trailing slash) that 'fib' resides in
      char *in_between)                                        what to put between each file

   * Description
      This function is used to build the project dependancy list and link object file list. It is designed to be called by
      process_directory(). The only difference in these two parts is what is placed between each file. The 'in_between' argument is used for
      this purpose.

      Note: This routine uses FilesOnLine and therefore, that value must be properly setup before this routine is called.
*/
int dpscan_pass1(
   struct AnchorPath *anchor,                                  /* file being processed */
   char *in_between)                                           /* what to put between each file */
{
   if (MatchPatternNoCase(DPSParsedPattern,anchor->ap_Info.fib_FileName))                       /* if this filename matches */
   {
      in_between = wrap_files(in_between);                     /* possibly move to the next line */

      if (strrchr(anchor->ap_Info.fib_FileName,'.'))           /* if the filename has an extension */
      {
         *strrchr(anchor->ap_Info.fib_FileName,'.') = '\0';    /* chop off the name at it's extension */
         fprintf(OutputStream,"%s$(obj)%s.o",in_between,anchor->ap_Info.fib_FileName);          /* put the current file into the make file */
         anchor->ap_Info.fib_FileName[strlen(anchor->ap_Info.fib_FileName)] = '.';              /* restore the file's extension */
      }
      else                                                     /* the filename has no extension */
      {
         fprintf(OutputStream,"%s$(obj)%s.o",in_between,anchor->ap_Info.fib_FileName);          /* use the filename as-is */
      }
   }

   if (*in_between && DPSArgument[DPS_ARG_VERBOSE])            /* if we should print stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_PASS1_PROGRESS));

   return (0);
}

/*
   int dpscan_pass2(
      struct AnchorPath *anchor,                               file being processed
      void *_not_used)                                         currently unused argument

   * Description
      This routine is designed to be called by process_directory(). It builds the dependancy list for the source modules in the make file.
      This function assumes that DPSParsedPattern has been created.
*/
int dpscan_pass2(
   struct AnchorPath *anchor,                                  /* file being processed */
   void *_not_used)                                            /* currently unused argument */
{
   FILE *input_stream = NULL;                                  /* connected to the file we are scanning for dependants */
   char temp_str[DPS_LINE_BUFFER_SIZE];                        /* for buffering lines of the #include file */
   char *include_name;                                         /* points to the file being included (a portion of 'temp_str') */
   int retval = 0;                                             /* 0 = good, other = bad */

   if (MatchPatternNoCase(DPSParsedPattern,anchor->ap_Info.fib_FileName) == FALSE)              /* if this filename does not match */
      goto _ABORT;

   fprintf(OutputStream,"\n\n");                               /* setup for the new target */

   FilesOnLine = 0;                                            /* setup for call to dpscan_pass1() */
   dpscan_pass1(anchor,"");                                    /* put the object file for this bit of source code at the start of the line */

   fprintf(OutputStream,": %s",anchor->ap_Buf);                /* put the file itself as a dependant into the makefile */

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should print stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_PASS2_FILE),anchor->ap_Buf);             /* show user which file we are processing what is happening */

   if ((input_stream = fopen(anchor->ap_Info.fib_FileName,"r")) == NULL)                        /* if we cannot open the file */
   {
      quick_requester_error(retval = DPS_ERROR_CANNOT_OPEN_FILE,DPS_ERROR_CANNOT_OPEN_FILE,anchor->ap_Info.fib_FileName);
      goto _ABORT;
   }

   while (fgets(temp_str,sizeof(temp_str),input_stream))       /* while we can get a line from the file */
   {
      if ((include_name = strstr(temp_str,"#include")) != NULL)                                 /* if this line includes something */
      {
         if ((include_name = strchr(include_name,'\"')) != NULL)                                /* if it is the type of #include that has quotes */
         {
            ++include_name;                                    /* skip the opening quote */

            if (strchr(include_name,'\"'))                     /* if there is a second quote on this line */
            {
               *strchr(include_name,'\"') = '\0';              /* cut off the name at the second quote */

               fprintf(OutputStream,"%s",wrap_files(" "));     /* separate this file from previous ones */

/* put the path of this #include file into the makefile */
               if (strrchr(anchor->ap_Buf,'/'))                /* if the full name has a slash in it */
                  fprintf(OutputStream,"%.*s",1 + (strrchr(anchor->ap_Buf,'/') - anchor->ap_Buf), anchor->ap_Buf);
                  else if (strrchr(anchor->ap_Buf,':'))        /* if the full name has a drive in it */
                     fprintf(OutputStream,"%.*s",1 + (strrchr(anchor->ap_Buf,':') - anchor->ap_Buf), anchor->ap_Buf);

               fprintf(OutputStream,"%s",include_name);        /* put the #include file into the makefile */

               if (DPSArgument[DPS_ARG_VERBOSE])               /* if we should print stuff */
                  printf(locale_support_string(DPSCatalog, DPS_MSG_PASS2_PROGRESS));            /* show user what is happening */
            }
         }
      }
      else if (strchr(temp_str,'{'))                           /* if this line is after the #include's */
      {
         break;                                                /* then, we are finished */
      }
   }

   if (strrchr(anchor->ap_Info.fib_FileName,'.'))              /* if the filename has a period in it */
      fprintf(OutputStream,"\n\t$(CC) $*%s",strrchr(anchor->ap_Info.fib_FileName,'.'));         /* tell the compiler how to compile this project */
   else                                                        /* no period in the file name */
      fprintf(OutputStream,"\n\t$(CC) $*");                    /* use default compilation???? */

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should print stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_PASS2_SEPARATOR));                       /* show user what is happening */

_ABORT:
   if (input_stream)                                           /* if we have a file open */
      fclose(input_stream);                                    /* then, clean up after ourselves */

   return (retval);
}

/*
   int dps_build_path(
      char *destination,                                       the resulting pathname may be stored here
      char *source)                                            the source pathname

   * Description
      If possible, this function will combine DPSArgument[DPS_ARG_PATH] with 'source' and store the result at 'destination'.

   * Return Value
      0 = could not combine the paths
      1 = paths combined
*/
int dps_build_path(
   char *destination,                                          /* the resulting pathname may be stored here */
   char *source)                                               /* the source pathname */
{
   char last_char;                                             /* the last character in 'source' */

   if (!strchr(source,':') && (source[0] != '/'))              /* if the source pathname does not have a directory specifier in it */
   {
      strcpy(destination,DPSArgument[DPS_ARG_PATH]);           /* start with the path for our operations */

      last_char = destination[strlen(destination)-1];          /* get the last character for examination */

      if ((last_char != ':') && (last_char != '/'))            /* if a directory separator is needed */
         strcat(destination,"/");                              /* put the directory separator */

      strcat(destination,source);                              /* create the remainder of the path */

      return (1);                                              /* let caller know that we could do it */
   }

   return (0);                                                 /* we didn't do it */
}

/*
   int dps_include_rules(
      char *filename)                                          the name of the rules file to be included

   * Description
      This function attempts to write the file specified by 'filename' to OutputStream (the makefile).

   * Return Value
      0 = OK
      other = bad
*/
int dps_include_rules(
   char *filename)                                             /* the name of the rules file to be included */
{
   int retval = 0;                                             /* another value is bad */
   FILE *stream;                                               /* connected to the rules file */
   char *line_buffer = NULL;                                   /* for buffering the input file */
   size_t bytes_read;                                          /* the number of bytes read on each pass */

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should say what is happening */
      printf(locale_support_string(DPSCatalog, DPS_MSG_INCLUDING_RULES),filename);

   if ((stream = fopen(filename,"r")) == NULL)                 /* if we cannot open the file */
/* then, we are done */
      {quick_requester_error(retval = DPS_ERROR_CANNOT_OPEN_FILE,DPS_ERROR_CANNOT_OPEN_FILE,filename); goto _ABORT;}

   if ((line_buffer = AllocVec(DPS_LINE_BUFFER_SIZE,0)) == NULL)                                /* if we cannot get some memory for our buffer */
      {quick_requester_error(retval = DPS_ERROR_CANNOT_ALLOCATE,DPS_ERROR_CANNOT_ALLOCATE,DPS_LINE_BUFFER_SIZE); goto _ABORT;}

   while (!feof(stream) && !ferror(stream))                    /* while we are not at the end of the file and there is no error with the file */
   {
      if ((bytes_read = fread(line_buffer,1,DPS_LINE_BUFFER_SIZE,stream)) == 0)                 /* if we have no more bytes to read */
         break;

      if (fwrite(line_buffer,1,bytes_read,OutputStream) != bytes_read)                          /* if we cannot write some bytes */
         {quick_requester_error(retval = DPS_ERROR_CANNOT_WRITE_FILE,DPS_ERROR_CANNOT_WRITE_FILE,bytes_read,filename); goto _ABORT;}
   }

_ABORT:
   if (stream)                                                 /* if we have a file open */
      fclose(stream);                                          /* clean up after ourselves */

   return (retval);                                            /* non-zero is bad */
}

/*
   int dependant_scan(void)

   * Description
      This function makes a makefile with the currently parsed arguments (mostly).
*/
int dependant_scan(void)
{
   char object_dir_path[PD_PATHMAX];                           /* if needed, the new value for DPSArgument[DPS_ARG_OBJECT_DIR] */
   int retval = 0;                                             /* other than this value is bad */

   if (DPSArgument[DPS_ARG_PATH])                              /* if we are scanning a different directory */
   {
      if (dps_build_path(object_dir_path,DPSArgument[DPS_ARG_OBJECT_DIR]))                      /* if the object directory can be expanded */
         DPSArgument[DPS_ARG_OBJECT_DIR] = object_dir_path;    /* then, use the fully-qualified path */
   }

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should say what is happening */
      printf(locale_support_string(DPSCatalog, DPS_MSG_CREATING_SMAKEFILE),DPSArgument[DPS_ARG_MAKEFILE]);

   if ((OutputStream = fopen(DPSArgument[DPS_ARG_MAKEFILE],"w")) == NULL)                       /* if we cannot open the output file */
      {quick_requester_error(retval = DPS_ERROR_CANNOT_OPEN_FILE,DPS_ERROR_CANNOT_OPEN_FILE,DPSArgument[DPS_ARG_MAKEFILE]); goto _ABORT;}

   if (DPSArgument[DPS_ARG_RULES])                             /* if we should include a "rules" file at the top of the makefile */
   {
      if ((retval = dps_include_rules(DPSArgument[DPS_ARG_RULES])) != 0)                        /* if we have difficulty including the rules file */
         goto _ABORT;
   }

   ParsePatternNoCase(DPSArgument[DPS_ARG_MATCH],DPSParsedPattern,sizeof(DPSParsedPattern));    /* convert the file pattern into something useful */

/* create the first part of the first couple of lines */
   fprintf(OutputStream,"obj = %s\n\n%s:",DPSArgument[DPS_ARG_OBJECT_DIR],DPSArgument[DPS_ARG_PROJECT]);
   FilesOnLine = 1;                                            /* only one file on this line */

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should print stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_PASS1_BEGINNING));

/* if we cannot perform the first pass */
   if (process_directory(DPSArgument[DPS_ARG_PATH],"#?",dpscan_pass1,process_directory_do_nothing," "))
      {quick_requester_error(retval = DPS_ERROR_PASS_UNSUCCESSFUL,DPS_ERROR_PASS_UNSUCCESSFUL,1); goto _ABORT;}

   fprintf(OutputStream,"\n\t$(LD) <WITH <\nFrom %s",DPSArgument[DPS_ARG_FROM]);                /* setup the link part */
   FilesOnLine = 1;                                            /* only one file on this line */

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we should print stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_BUILDING_LINK_LIST));

/* if we cannot perform the second pass */
   if (process_directory(DPSArgument[DPS_ARG_PATH],"#?",dpscan_pass1,process_directory_do_nothing," + "))
      {quick_requester_error(retval = DPS_ERROR_PASS_UNSUCCESSFUL,DPS_ERROR_PASS_UNSUCCESSFUL,2); goto _ABORT;}

   if (DPSArgument[DPS_ARG_VERBOSE])                           /* if we are printing stuff */
      printf(locale_support_string(DPSCatalog, DPS_MSG_PASS2_BEGINNING));

   fprintf(OutputStream,"\n\nTo %s\nLibrary %s\n<",DPSArgument[DPS_ARG_PROJECT],DPSArgument[DPS_ARG_LIBRARY]);

   if (process_directory(DPSArgument[DPS_ARG_PATH],"#?",dpscan_pass2,process_directory_do_nothing,NULL))
      {quick_requester_error(retval = DPS_ERROR_PASS_UNSUCCESSFUL,DPS_ERROR_PASS_UNSUCCESSFUL,3); goto _ABORT;}

_ABORT:
   if (OutputStream)                                           /* if we have a file open */
   {
      if (DPSArgument[DPS_ARG_VERBOSE])                        /* if we should say what is happening */
         printf(locale_support_string(DPSCatalog, DPS_MSG_CLOSING_SMAKEFILE),DPSArgument[DPS_ARG_MAKEFILE]);

      fclose(OutputStream);                                    /* then, close it */
      OutputStream = NULL;                                     /* note that it is closed */
   }

   return (retval);                                            /* let caller know what happened */
}

int main(
   int argc,
   char *argv)
{
   struct RDArgs *rdargs = NULL;                               /* for parsing the command line */
   BOOL free_args_needed = FALSE;                              /* true when we should call FreeArgs() */
   int retval = 0;

   if ((DPSCatalog = locale_support_open("DependantScan.catalog", DpSMessageText)) == NULL)     /* if we cannot open our language catalog */
      goto _ABORT;                                             /* we are outta here */

   requester_error_set_defaults(NULL,DPSCatalog, DPS_MSG_DEPENDANTSCAN_ERROR, DPS_MSG_DARN);    /* tell the RequesterError functions what should be used as the defaults */

   if (argc)                                                   /* if we were started from the shell */
   {
      if ((rdargs = (struct RDArgs *)AllocDosObject(DOS_RDARGS,TAG_DONE)) == NULL)              /* if we cannot get some memory for this DOS structure */
         {quick_requester_error(retval = DPS_ERROR_ALLOCDOSOBJECT,DPS_ERROR_ALLOCDOSOBJECT); goto _ABORT;}

      if ((free_args_needed = dps_get_shell_arguments(rdargs)) == FALSE)                        /* if we have an error while getting the command line arguments */
      {
         PrintFault(IoErr(), locale_support_string(DPSCatalog, DPS_MSG_DEPENDANTSCAN));         /* tell the user what went wrong */
         retval = DPS_ERROR_PASS_UNSUCCESSFUL;
         goto _ABORT;
      }

      retval = dependant_scan();                               /* actually do the scanning */
   }
   else                                                        /* must have been started from the WB */
   {
      retval = dps_process_workbench_arguments((struct WBStartup *)argv);                       /* parse the workbench arguments */
   }

_ABORT:
   if (retval == 0)                                            /* if this was a successful run */
   {
      if (DPSArgument[DPS_ARG_VERBOSE])                        /* if we are notifying the user */
/* notify the user of the successful run */
         requester_error(NULL, DPS_MSG_DEPENDANTSCAN_MSG, DPS_MSG_SUCCESSFUL, DPS_MSG_COOL, DPSArgument[DPS_ARG_MAKEFILE], DPSArgument[DPS_ARG_PROJECT]);
   }

   if (free_args_needed)                                       /* if we need to free any arguments allocated by DOS */
      FreeArgs(rdargs);                                        /* then, we don't need them anymore */

   if (rdargs)                                                 /* if we allocated this */
      FreeDosObject(DOS_RDARGS,rdargs);                        /* then, free it */
      
   if (DPSCatalog)                                             /* if we have a language catalog open */
      locale_support_close(DPSCatalog);                        /* free that puppy */

   return (retval);
}

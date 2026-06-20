#define DEF_ARGUMENTSDPS_C

#include <exec/types.h>
#include <workbench/startup.h>
#include <proto/icon.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "DependantScan.h"
#include "ProcessDirectory.h"
#include "RequesterError.h"
#include "LocaleSupport.h"

/*
   void parse_scoptions_for_argument(
      char *scoptions_variable,                                the string to look for in the scoptions file
      int argument_number,                                     the argument to assign it to
      char *line_buffer)                                       static buffer (of size PD_PATHMAX) to store lines and variable value

   * Description
      This function will attempt to build the name of the scoptions file and get the specified SAS/C variable's value from that file. If
      successful, the DPSArgument[argument_number] variable will be set to the value fetched from the scoptions file.
*/
void parse_scoptions_for_argument(
   char *scoptions_variable,                                   /* the string to look for in the scoptions file */
   int argument_number,                                        /* the argument to assign it to */
   char *line_buffer)                                          /* static buffer (of size PD_PATHMAX) to store lines and variable value */
{
   FILE *stream;                                               /* will be connected to the file specified by 'scoptions_name' */
   char scoptions_name[PD_PATHMAX];                            /* name of scoptions file */
   size_t variable_length = strlen(scoptions_variable);        /* remember how long the scoptions variable is */

   if (DPSArgument[DPS_ARG_PATH] == NULL)                      /* if the current directory is to be used */
      strcpy(scoptions_name,DPS_SCOPTIONS_FILENAME);           /* then, no path information for the scoptions file should be used */
   else                                                        /* either not the shell or the WB */
      dps_build_path(scoptions_name,DPS_SCOPTIONS_FILENAME);   /* build the name of the scoptions file */

   if ((stream = fopen(scoptions_name,"r")) != NULL)           /* if we can open the file */
   {
      while (fgets(line_buffer,PD_PATHMAX,stream))             /* while we can get a line from the file */
      {
         if (!memcmp(line_buffer,scoptions_variable,variable_length))                           /* if this line mentions the variable we are looking for */
         {
            DPSArgument[argument_number] = line_buffer + variable_length;                       /* get the variable's value */
            if (strchr(line_buffer,'\n'))                      /* if the line contains a new-line */
               *strchr(line_buffer,'\n') = '\0';               /* remove the new-line */

            break;                                             /* we are done */
         }
      }

      fclose(stream);                                          /* clean up after ourselves */
   }
}

/*
   void parse_scoptions_for_project(void)

   * Description
      This function will attempt to parse the value of DPSArgument[DPS_ARG_PROJECT] from the scoptions file. If successful, the
      DPSArgument[DPS_ARG_PROJECT] variable will be set to the value fetched from the scoptions file.
*/
void parse_scoptions_for_project(void)
{
   static char line_buffer[PD_PATHMAX];                        /* required by parse_scoptions_for_argument() */
   parse_scoptions_for_argument(DPS_PROGRAMNAME_STRING,DPS_ARG_PROJECT,line_buffer);            /* actually do the parsing */
}

/*
   void parse_scoptions_for_object_dir(void)

   * Description
      This function will attempt to parse the value of DPSArgument[DPS_ARG_OBJECT_DIR] from the scoptions file. If successful, the
      DPSArgument[DPS_ARG_OBJECT_DIR] variable will be set to the value fetched from the scoptions file.
*/
void parse_scoptions_for_object_dir(void)
{
   static char line_buffer[PD_PATHMAX];                        /* required by parse_scoptions_for_argument() */
   parse_scoptions_for_argument(DPS_OBJECTNAME_STRING,DPS_ARG_OBJECT_DIR,line_buffer);          /* actually do the parsing */
}

/*
   BOOL dps_get_shell_arguments(
      struct RDArgs *rdargs)                                   where to place the on-line help

   * Description
      This function gets the command-line arguments when the program is spawned from the shell.

   * Return Value
      TRUE = successful, a call to FreeArgs() is necessary
      FALSE = unsuccessful, a call to FreeArgs() is not necessary
*/
BOOL dps_get_shell_arguments(
   struct RDArgs *rdargs)                                      /* where to place the on-line help */
{
   BOOL free_args_needed = FALSE;                              /* value that is returned, TRUE is good, FALSE is bad */
   char *project;                                              /* tells if the user specified a project name */
   char *object_dir;                                           /* for determining if the user specified an object directory */
   static long files_on_line = DPS_DEFAULT_FILESONLINE;        /* the default number of files per line */
   int index;                                                  /* for accessing our messages */
   char arg_lower_name[40];                                    /* lower case version of a command line option */
   char *arg_type;                                             /* the type of the current argument */
   char *arg_name;                                             /* for pointing to various parts of the the current argument */
   char *next_text;                                            /* where the next bit of text should go */
   int longest_arg_name = 0;                                   /* the length of the longest argument name */
   char *template = NULL;                                      /* the template as supplied to DOS */

   if ((rdargs->RDA_ExtHelp = AllocVec(2048,0)) == NULL)       /* if we cannot get some memory for our help text */
      {quick_requester_error(DPS_ERROR_CANNOT_ALLOCATE,DPS_ERROR_CANNOT_ALLOCATE,2048); goto _ABORT;}

   if ((template = AllocVec(DPS_LINE_BUFFER_SIZE,0)) == NULL)  /* if we cannot get some memory for the DOS template */
      {quick_requester_error(DPS_ERROR_CANNOT_ALLOCATE,DPS_ERROR_CANNOT_ALLOCATE,DPS_LINE_BUFFER_SIZE); goto _ABORT;}

   strcpy(rdargs->RDA_ExtHelp,locale_support_string(DPSCatalog, DPS_MSG_USAGE));                /* intialize the help text */
   next_text = rdargs->RDA_ExtHelp + strlen(rdargs->RDA_ExtHelp);                               /* setup where to start appending information */

   for (index = 0; index < DPS_ARG_COUNT; ++index)             /* access all of the command line options */
   {
      arg_type = locale_support_string(DPSCatalog, DPS_ARG_COUNT+1+index);                      /* get the type of argument we are dealing with */
      arg_name = locale_support_string(DPSCatalog, index);     /* get the name of the argument */

      if (strlen(arg_name) > longest_arg_name)                 /* if this argument is even longer than the others */
         longest_arg_name = strlen(arg_name);                  /* remember which one is the longest */

      if (strstr(arg_type,"/K"))                               /* if this is a key word */
      {
         strcpy(arg_lower_name,arg_name);                      /* get a working copy of the argument name */
         strlwr(arg_lower_name);                               /* convert the copy to lower case */
         next_text += sprintf(next_text," [%s %s]",arg_name,arg_lower_name);
      }
      else if (strstr(arg_type,"/S"))                          /* if this is a switch type argument */
      {
         next_text += sprintf(next_text," [%s]",arg_name);
      }
      else                                                     /* NOTE: handle other cases as needed */
      {
         next_text += sprintf(next_text,"%s",arg_name);
      }

      if (index == (DPS_ARG_COUNT/2))                          /* if we are at the half way mark */
/* put a break in the arguments */
         next_text += sprintf(next_text,"\n%*s",strlen(locale_support_string(DPSCatalog, DPS_MSG_USAGE)),"");
   }

   next_text += sprintf(next_text,"\n");                       /* put the description of each argument starting on the next line */

   for (index = 0; index < DPS_ARG_COUNT; ++index)             /* access all of the command line options again */
   {
      strcpy(arg_lower_name,locale_support_string(DPSCatalog, index));                          /* get a working copy of the argument name */
      strlwr(arg_lower_name);                                  /* convert the copy to lower case */
/* display the help for this command line option on it's own line */
      next_text += sprintf(next_text,"\t%*s %s\n",longest_arg_name,arg_lower_name,locale_support_string(DPSCatalog, DPS_MSG_USAGE+1+index));
   }

   next_text = template;                                       /* let's start building the DOS template */

   for (index = 0; index < DPS_ARG_COUNT; ++index)             /* access all of the command line options One More Time */
      next_text += sprintf(next_text,locale_support_string(DPSCatalog, DPS_ARG_COUNT+1+index),locale_support_string(DPSCatalog, index));

   DPSArgument[DPS_ARG_PROJECT] = DPS_DEFAULT_PROJECT;         /* setup shell default arguments */
   DPSArgument[DPS_ARG_MATCH] = DPS_DEFAULT_MATCH;
   DPSArgument[DPS_ARG_MAKEFILE] = DPS_DEFAULT_MAKEFILE;
   DPSArgument[DPS_ARG_OBJECT_DIR] = DPS_DEFAULT_OBJECT_DIR;
   DPSArgument[DPS_ARG_FILESONLINE] = (char *)&files_on_line;
   DPSArgument[DPS_ARG_FROM] = DPS_DEFAULT_FROM;
   DPSArgument[DPS_ARG_LIBRARY] = DPS_DEFAULT_LIBRARY;

   project = DPSArgument[DPS_ARG_PROJECT];                     /* remember the default project name */
   object_dir = DPSArgument[DPS_ARG_OBJECT_DIR];               /* remember the default object directory */

   if (ReadArgs(template,(LONG *)DPSArgument,rdargs) == 0)     /* if we cannot read the arguments */
      goto _ABORT;

   free_args_needed = TRUE;                                    /* note that we did it */

   if (project == DPSArgument[DPS_ARG_PROJECT])                /* if the user did not specify a project */
      parse_scoptions_for_project();                           /* then, maybe the answer is in the scoptions file */

   if (object_dir == DPSArgument[DPS_ARG_OBJECT_DIR])          /* if the user did not specify an object directory */
      parse_scoptions_for_object_dir();                        /* then, maybe the value is in the scoptions file */

_ABORT:
   if (rdargs->RDA_ExtHelp)                                    /* if we allocated some help text */
      FreeVec(rdargs->RDA_ExtHelp);                            /* clean up after ourselves */

   if (template)                                               /* if we allocated this */
      FreeVec(template);                                       /* clean up after ourselves */

   return (free_args_needed);
}

/*
   int dps_process_workbench_arguments(
      struct WBStartup *wb_startup)                            the startup message that WorkBench sends us (argv under SAS/C)

   * Description
      This function parses the arguments from the tool types of each selected project (or the program's icon if need be) and generates a
      makefile for each.

   * Return Value
      0 = good
      other = error code from dependant_scan()
*/
int dps_process_workbench_arguments(
   struct WBStartup *wb_startup)                               /* the startup message that WorkBench sends us (argv under SAS/C) */
{
   BPTR startup_directory;                                     /* the main directory we should switch back to */
   struct DiskObject *icon = NULL;                             /* the icon we are examining */
   struct WBArg *wb_arg;                                       /* current argument from the wb_startup->sm_ArgList array */
   struct WBArg *last_wb_arg = wb_startup->sm_ArgList+wb_startup->sm_NumArgs;                   /* points to one past the last workbench argument */
   char *rvalue;                                               /* the value to the right of the equals sign on tool types */
   static long files_on_line = DPS_DEFAULT_FILESONLINE;        /* the default number of files per line */
   int retval;                                                 /* value from dependant_scan() */

   startup_directory = CurrentDir(wb_startup->sm_ArgList->wa_Lock);                             /* note the absolute directory to switch back to */

   if (wb_startup->sm_NumArgs > 1)                             /* if it is possible that a project icon was double clicked */
   {                                                           /* we are going to scan for project icons that we can process */
      for (wb_arg = wb_startup->sm_ArgList+1; wb_arg < last_wb_arg; ++wb_arg)                   /* access the icons that are not our program's icon */
      {
         if (wb_arg->wa_Name && (*wb_arg->wa_Name) && wb_arg->wa_Lock)                          /* if this icon is not a disk, directory or trashcan and the icon type supports locks */
            break;                                             /* then, there is at least one icon we can process */
      }

      if (wb_arg < last_wb_arg)                                /* if we found a valid project icon */
         wb_arg = wb_startup->sm_ArgList+1;                    /* start at the first project icon */
      else                                                     /* no valid project icons were selected */
         wb_arg = wb_startup->sm_ArgList;                      /* use our tool as if it were a project */
   }
   else                                                        /* only the tool icon was passed to us */
   {
      wb_arg = wb_startup->sm_ArgList;                         /* use the tool as if it were a project */
   }

   for (; wb_arg < last_wb_arg; ++wb_arg)                      /* access our icons */
   {
      if ((wb_arg->wa_Name == NULL) || (*wb_arg->wa_Name == '\0') || (wb_arg->wa_Lock == NULL)) /* if this icon is a disk, directory or trashcan or the icon type does not supports locks */
         continue;                                             /* then, ignore the icon */

      if (icon)                                                /* if we have a previous icon taking up memory */
      {
         FreeDiskObject(icon);                                 /* don't need the icon taking up memory anymore */
         icon = NULL;                                          /* note that it has been free'd */
      }

      CurrentDir(wb_arg->wa_Lock);                             /* switch to the icon's directory */

      if ((icon = GetDiskObject(wb_arg->wa_Name)) == NULL)     /* if we cannot get information on this icon */
         continue;                                             /* then, ignore the icon */

/* attempt to locate an alternate path to be scanned */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_PATH));
      if (rvalue && (*rvalue == '\0'))                         /* if zero length string was specified */
         DPSArgument[DPS_ARG_PATH] = NULL;                     /* use the current directory */
      else
         DPSArgument[DPS_ARG_PATH] = rvalue;                   /* otherwise use specified or non-existant path */

/* attempt to get the name of our project from the icon */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_PROJECT));
      if ((rvalue == NULL) || (rvalue[0] == '\0'))             /* if no project was supplied */
      {
         DPSArgument[DPS_ARG_PROJECT] = NULL;                  /* start with no project name */

         parse_scoptions_for_project();                        /* maybe the answer is in the scoptions file */
         if (DPSArgument[DPS_ARG_PROJECT] == NULL)             /* if we still don't have a project name */
            DPSArgument[DPS_ARG_PROJECT] = DPS_DEFAULT_PROJECT;                                 /* then, use the default name */
      }
      else                                                     /* a project name was supplied */
      {
         DPSArgument[DPS_ARG_PROJECT] = rvalue;                /* use the project name from the icon */
      }

/* search for the file pattern specifier */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_MATCH));
      if (rvalue && *rvalue)                                   /* if a valid file pattern was specified */
         DPSArgument[DPS_ARG_MATCH] = rvalue;                  /* use the specified file pattern */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_MATCH] = DPS_DEFAULT_MATCH;       /* use the default value */

/* search for the name of the makefile */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_MAKEFILE));
      if (rvalue && *rvalue)                                   /* if a valid value was specified */
         DPSArgument[DPS_ARG_MAKEFILE] = rvalue;               /* use the specified value */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_MAKEFILE] = DPS_DEFAULT_MAKEFILE; /* use the default value */

/* search for the name of a file to be inserted into the makefile */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_RULES));
      if (rvalue && *rvalue)                                   /* if a valid value was specified */
         DPSArgument[DPS_ARG_RULES] = rvalue;                  /* use the specified value */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_RULES] = NULL;                    /* use the default value */

/* search for the name of the object file directory */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_OBJECT_DIR));

      if ((rvalue == NULL) || (rvalue[0] == '\0'))             /* if no object directory was specified */
      {
         DPSArgument[DPS_ARG_OBJECT_DIR] = NULL;               /* start with no object directory */

         parse_scoptions_for_object_dir();                     /* try to get the object directory from the scoptions file */
         if (DPSArgument[DPS_ARG_OBJECT_DIR] == NULL)          /* if we still don't have an object directory name */
            DPSArgument[DPS_ARG_OBJECT_DIR] = DPS_DEFAULT_OBJECT_DIR;                           /* use the default object directory name */
      }
      else                                                     /* an object directory was specified */
      {
         DPSArgument[DPS_ARG_OBJECT_DIR] = rvalue;             /* use the specified value */
      }

/* search for the maximum number of files per line in the makefile */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_FILESONLINE));
      if (rvalue && *rvalue && atoi(rvalue))                   /* if a valid value was specified */
         files_on_line = atoi(rvalue);                         /* use the specified value */
      else                                                     /* nothing specified */
         files_on_line = DPS_DEFAULT_FILESONLINE;              /* use the default number of files per line */

      DPSArgument[DPS_ARG_FILESONLINE] = (char *)&files_on_line;                                /* always use our number of filesonline */

/* search for the bit of text that follows the linker FROM keyword */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_FROM));
      if (rvalue && *rvalue)                                   /* if a valid value was specified */
         DPSArgument[DPS_ARG_FROM] = rvalue;                   /* use the specified value */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_FROM] = DPS_DEFAULT_FROM;         /* use the default value */

/* search for the libraries to be included */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_LIBRARY));
      if (rvalue && *rvalue)                                   /* if a valid value was specified */
         DPSArgument[DPS_ARG_LIBRARY] = rvalue;                /* use the specified value */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_LIBRARY] = DPS_DEFAULT_LIBRARY;   /* use the default value */

/* search for the verbose switch */
      rvalue = FindToolType(icon->do_ToolTypes,locale_support_string(DPSCatalog, DPS_ARG_VERBOSE));
      if (rvalue)                                              /* if the keyword exists */
         DPSArgument[DPS_ARG_VERBOSE] = (char *)(TRUE);        /* note that it exists */
      else                                                     /* nothing specified */
         DPSArgument[DPS_ARG_VERBOSE] = (char *)(FALSE);       /* use the default value */

      if ((retval = dependant_scan()) != 0)                    /* if we have trouble doing this scan */
         break;                                                /* then, we are outta here */
   }

_ABORT:
   if (icon)                                                   /* if we have an icon taking up memory */
      FreeDiskObject(icon);                                    /* don't need the icon taking up memory */

   CurrentDir(startup_directory);                              /* switch back to the startup directory */
   return (retval);                                            /* here ya go */
}

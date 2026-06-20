#define DEF_LOCALEDPS_C

#include <stdio.h>

#include "DependantScan.h"

char *DpSMessageText[DPS_MSG_COUNT] =                          /* text that we use for various messages */
{
   "PATH",                                                     /* DPS_ARG_PATH */
   "PROJECT",                                                  /* DPS_ARG_PROJECT */
   "MATCH",                                                    /* DPS_ARG_MATCH */
   "MAKEFILE",                                                 /* DPS_ARG_MAKEFILE */
   "RULES",                                                    /* DPS_ARG_RULES */
   "OBJECT_DIR",                                               /* DPS_ARG_OBJECT_DIR */
   "FILESONLINE",                                              /* DPS_ARG_FILESONLINE */
   "FROM",                                                     /* DPS_ARG_FROM */
   "LIBRARY",                                                  /* DPS_ARG_LIBRARY */
   "VERBOSE",                                                  /* DPS_ARG_VERBOSE */
   NULL,                                                       /* DPS_ARG_COUNT */
   "%s/K,",                                                    /* DPS_TEMPLATE_PATH */
   "%s/K,",                                                    /* DPS_TEMPLATE_PROJECT */
   "%s/K,",                                                    /* DPS_TEMPLATE_MATCH */
   "MK=%s/K,",                                                 /* DPS_TEMPLATE_MAKEFILE */
   "%s/K,",                                                    /* DPS_TEMPLATE_RULES */
   "OBJ=%s/K,",                                                /* DPS_TEMPLATE_OBJECT_DIR */
   "N=%s/N/K,",                                                /* DPS_TEMPLATE_FILESONLINE */
   "%s/K,",                                                    /* DPS_TEMPLATE_FROM */
   "LIB=%s/K,",                                                /* DPS_TEMPLATE_LIBRARY */
   "%s/S",                                                     /* DPS_TEMPLATE_VERBOSE */

   "Usage: DependantScan",                                     /* DPS_MSG_USAGE */
    "- the directory to be scanned for files (default: current directory)",                     /* DPS_MSG_USE_PATH */
    "- primary target of 'filename' (default: from scoptions or \""DPS_DEFAULT_PROJECT"\")",    /* DPS_MSG_USE_PROJECT */
    "- file(s) to be scanned for inclusion (default: \""DPS_DEFAULT_MATCH"\")",                 /* DPS_MSG_USE_MATCH */
    "- make file to be created (default: \""DPS_DEFAULT_MAKEFILE"\")",                          /* DPS_MSG_USE_MAKEFILE */
    "- a file to be inserted at the top of the output makefile",                                /* DPS_MSG_USE_RULES */
    "- directory for temporary files, with trailing '/' or ':' (default: \""DPS_DEFAULT_OBJECT_DIR"\")",
    "- maximum number of files on a line of the makefile (default: \"5\")",                     /* DPS_MSG_USE_FILESONLINE */
    "- first item(s) (startup code) on the link line (default: \""DPS_DEFAULT_FROM"\")",        /* DPS_MSG_USE_FROM */
    "- first item(s) on the library line (default: \""DPS_DEFAULT_LIBRARY"\")",                 /* DPS_MSG_USE_LIBRARY */
    "- if specified, progress will be displayed",              /* DPS_MSG_USE_VERBOSE */

   "Building object file dependency list: ",                   /* DPS_MSG_PASS1_BEGINNING */
   ".",                                                        /* DPS_MSG_PASS1_PROGRESS */
   "\nBuilding link list: ",                                   /* DPS_MSG_BUILDING_LINK_LIST */
   "\nScanning source code for dependants:\n",                 /* DPS_MSG_PASS2_BEGINNING */
   "\"%s\" ",                                                  /* DPS_MSG_PASS2_FILE */
   "\x1b[42m+\x1b[40m",                                        /* DPS_MSG_PASS2_PROGRESS */
   "\n",                                                       /* DPS_MSG_PASS2_SEPARATOR */
   "including %s\n",                                           /* DPS_MSG_INCLUDING_RULES */
   "Creating %s\n",                                            /* DPS_MSG_CREATING_SMAKEFILE */
   "Closing %s\n",                                             /* DPS_MSG_CLOSING_SMAKEFILE */

   "\0$VER: DependantScan v1.1 by Ray Darrah III",             /* so that the 'version' program can print our version number */
   "DependantScan",                                            /* DPS_MSG_DEPENDANTSCAN */
   "DependantScan Error",                                      /* DPS_MSG_DEPENDANTSCAN_ERROR */
   "DARN!",                                                    /* DPS_MSG_DARN */
   "\"%s\" created for %s",                                    /* DPS_MSG_SUCCESSFUL */
   "DependantScan Message",                                    /* DPS_MSG_DEPENDANTSCAN_MSG */
   "COOL",                                                     /* DPS_MSG_COOL */

   "ERROR #%ld: could not open %s",                            /* DPS_ERROR_CANNOT_OPEN_FILE */
   "ERROR #%ld: could not write %ld bytes to %s",              /* DPS_ERROR_CANNOT_WRITE_FILE */
   "ERROR #%ld: could not allocate %ld bytes of memory",       /* DPS_ERROR_CANNOT_ALLOCATE */
   "ERROR #%ld: call to AllocDosObject() failed",              /* DPS_ERROR_ALLOCDOSOBJECT */
   "ERROR #%ld: pass %ld unsuccessful"                         /* DPS_ERROR_PASS_UNSUCCESSFUL */
};

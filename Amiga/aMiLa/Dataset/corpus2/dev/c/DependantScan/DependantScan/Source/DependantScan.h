#if !defined DEF_DEPENDANTSCAN_H
#define DEF_DEPENDANTSCAN_H

#define DPS_DEFAULT_PROJECT      "Executable"                  /* the defaults for our arguments */
#define DPS_DEFAULT_MATCH        "#?.c"
#define DPS_DEFAULT_MAKEFILE     "SMakeFile"
#define DPS_DEFAULT_OBJECT_DIR   "Object/"
#define DPS_DEFAULT_FILESONLINE  5

#define DPS_DEFAULT_FROM         "LIB:c.o"
#define DPS_DEFAULT_LIBRARY      "lib:sc.lib + lib:amiga.lib"

#define DPS_SCOPTIONS_FILENAME   "SCOptions"                   /* the name of the file that SAS/C puts it's options into */
#define DPS_PROGRAMNAME_STRING   "PROGRAMNAME="                /* the value in the scoptions file that specifies the project name */
#define DPS_OBJECTNAME_STRING    "OBJECTNAME="                 /* the value in the scoptions file that specifies the object file directory */

#define DPS_LINE_BUFFER_SIZE     256                           /* size of buffer for buffering file I/O */

enum DependantScanMessages                                     /* index into DPSMessageText[] */
{
   DPS_ARG_PATH,                                               /* [PATH path] the name of the directory to be scanned */
   DPS_ARG_PROJECT,                                            /* [PROJECT project] the name of the file the make file will create */
   DPS_ARG_MATCH,                                              /* [MATCH pattern] the files to be scanned */
   DPS_ARG_MAKEFILE,                                           /* [MAKEFILE makefile] the name of the file we create */
   DPS_ARG_RULES,                                              /* [RULES rules] a file to be inserted at the top of the makefile */
   DPS_ARG_OBJECT_DIR,                                         /* [OBJECT_DIR object_dir] the directory to hold temporary files */
   DPS_ARG_FILESONLINE,                                        /* [FILESONLINE filesonline] maximum number of files to put on each line of the makefile */
   DPS_ARG_FROM,                                               /* [FROM from] first item(s) (startup code) on the link line */
   DPS_ARG_LIBRARY,                                            /* [LIBRARY library] first item(s) on the library line */
   DPS_ARG_VERBOSE,                                            /* [VERBOSE] display progress */
   DPS_ARG_COUNT,                                              /* number of arguments above and below (twice) */
   DPS_TEMPLATE_PATH,                                          /* CLI template version of the path */
   DPS_TEMPLATE_PROJECT,                                       /* CLI template version of the project */
   DPS_TEMPLATE_MATCH,                                         /* CLI template version of the match */
   DPS_TEMPLATE_MAKEFILE,                                      /* CLI template version of the makefile */
   DPS_TEMPLATE_RULES,                                         /* CLI template version of the rules */
   DPS_TEMPLATE_OBJECT_DIR,                                    /* CLI template version of the object directory */
   DPS_TEMPLATE_FILESONLINE,                                   /* CLI template version of filesonline */
   DPS_TEMPLATE_FROM,                                          /* CLI template version of from */
   DPS_TEMPLATE_LIBRARY,                                       /* CLI template version of library */
   DPS_TEMPLATE_VERBOSE,                                       /* CLI template version of verbose */

   DPS_MSG_USAGE,                                              /* what we display when the user types ? twice */
   DPS_MSG_USE_PATH,                                           /* help text for the PATH argument */
   DPS_MSG_USE_PROJECT,                                        /* help text for PROJECT */
   DPS_MSG_USE_MATCH,                                          /* help text for MATCH */
   DPS_MSG_USE_MAKEFILE,                                       /* help text for MAKEFILE */
   DPS_MSG_USE_RULES,                                          /* help text for RULES */
   DPS_MSG_USE_OBJECT_DIR,                                     /* help text for OBJECT_DIR */
   DPS_MSG_USE_FILESONLINE,                                    /* help text for FILESONLINE */
   DPS_MSG_USE_FROM,                                           /* help text for FROM */
   DPS_MSG_USE_LIBRARY,                                        /* help text for LIBRARY */
   DPS_MSG_USE_VERBOSE,                                        /* help text for VERBOSE */

   DPS_MSG_PASS1_BEGINNING,                                    /* pass1 of the makefile generation is about to begin */
   DPS_MSG_PASS1_PROGRESS,                                     /* processed a file on pass1 */
   DPS_MSG_BUILDING_LINK_LIST,                                 /* the second part of pass1 is about to begin */
   DPS_MSG_PASS2_BEGINNING,                                    /* pass2 of the makefile generation is about to begin */
   DPS_MSG_PASS2_FILE,                                         /* file being processed on pass2 */
   DPS_MSG_PASS2_PROGRESS,                                     /* found a header file in pass2 */
   DPS_MSG_PASS2_SEPARATOR,                                    /* separation between files on pass2*/
   DPS_MSG_INCLUDING_RULES,                                    /* a rules file is being included into the makefile */
   DPS_MSG_CREATING_SMAKEFILE,                                 /* the name of the makefile being built */
   DPS_MSG_CLOSING_SMAKEFILE,                                  /* the makefile is being closed */

   DPS_MSG_VERSION_NUMBER,                                     /* so that the version program can print our version number */
   DPS_MSG_DEPENDANTSCAN,                                      /* name of our program */
   DPS_MSG_DEPENDANTSCAN_ERROR,                                /* the title of our error requester */
   DPS_MSG_DARN,                                               /* the button text of our error requester */
   DPS_MSG_SUCCESSFUL,                                         /* successful program operation */
   DPS_MSG_DEPENDANTSCAN_MSG,                                  /* the title of our successful verbose requester */
   DPS_MSG_COOL,                                               /* the button text of a successful run */

   DPS_ERROR_CANNOT_OPEN_FILE,                                 /* could not open a file */
   DPS_ERROR_CANNOT_WRITE_FILE,                                /* could not write to a file */
   DPS_ERROR_CANNOT_ALLOCATE,                                  /* could not allocate some memory */
   DPS_ERROR_ALLOCDOSOBJECT,                                   /* call to AllocDosObject() failed */
   DPS_ERROR_PASS_UNSUCCESSFUL,                                /* could not perform a pass */

   DPS_MSG_COUNT                                               /* number of messages above */
};
extern char *DpSMessageText[DPS_MSG_COUNT];                    /* text that we use for various messages */
extern char *DPSArgument[DPS_ARG_COUNT];                       /* arguments parsed from the command line or our icon */

extern struct LOCALE_SUPPORT_CATALOG *DPSCatalog;              /* alternate language catalog used by this program */

/* DependantScan.c */
extern char *wrap_files(char *in_between);
extern int dpscan_pass1(struct AnchorPath *anchor, char *in_between);
extern int dpscan_pass2(struct AnchorPath *anchor, void *_not_used);
extern int dps_build_path(char *destination, char *source);
extern int dps_include_rules(char *filename);
extern int dependant_scan(void);

/* ArgumentsDpS.c */
extern void parse_scoptions_for_argument(char *scoptions_variable,int argument_number, char *line_buffer);
extern void parse_scoptions_for_project(void);
extern void parse_scoptions_for_object_dir(void);
#if defined EXEC_TYPES_H
   extern BOOL dps_get_shell_arguments(struct RDArgs *rdargs);
   extern int dps_process_workbench_arguments(struct WBStartup *wb_startup);
#endif
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h> /* system() */
#include <unistd.h> /* getopt() */

#include "scanner.h"
#include "parser.h"
#include "node.h"

#include "enums.h"
#include "globals.h"

#include "ir_generator.h"

#include "backends.h"

#define VERSION "0.1.0"

struct cpu_info_type cpu_info;
int optimize_level=0;
int output_options=O_ASSEMBLY | O_OBJECT | O_EXECUTABLE;
int debug_level=D_ERRORS;


   /* Prints some help or version info */
void vmwHelp(char *command_line,int show_help) {
   
   printf("\nvmwcc version %s\n",VERSION);
   printf("    by Vince Weaver (vince@deater.net)\n");
   printf("       http://www.deater.net/weave\n");
   printf("    some code by Martin Burtscher (@cornell.edu)\n");
   printf("\n");
   if (show_help) {
	
      printf("Usage:\n");
      printf("  %s [-Ox] [-S] [-W] [-c] [-dom] [-h] [-m arch] [-o filename]\n"
	     "\t\t[-ssa] [-v] filename.c\n\n",command_line);
      printf("\t-Ox\t\t: Use optimization level x (0 means none)\n");
      printf("\t-S\t\t: Output assembly language file only\n");
      printf("\t-W\t\t: Enable warnings\n");
      printf("\t-c\t\t: Output object file only\n");
      printf("\t-dom\t\t: Output dominator tree in .dot format\n");
      printf("\t-g\t\t: Ignored.  For compatibility with gcc only\n");
      printf("\t-h\t\t: Help.  This help message\n");
      printf("\t-m arch\t\t: Output target.  Defaults to ppc-linux for now\n");
      printf("\t-o filename\t: Output object or executable to this filename\n");
      printf("\t-pg\t\t: Ignored.  For compatibility with gcc only\n");
      printf("\t-ssa\t\t: Output internal SSA information to file\n");
      printf("\t-v\t\t: Output version information\n\n");
   }
   
   exit(0);
}

   


/***********************************************************
*   THE MAIN FUNCTION                                      *
***********************************************************/


int main(int argc, char **argv) {

    char temp_string[BUFSIZ];
    char basename[BUFSIZ];
    char output_file[BUFSIZ],linker_options[BUFSIZ];
    char *name_ptr;
    int i,c;

   
    cpu_info.architecture=vmwPPC;
    cpu_info.char_size=1;
    cpu_info.int_size=4;
    cpu_info.long_size=4;
   
       /* Setup the built-in types */
    IRInit();

       /* Set default output filename */
    strncpy(output_file,"a.out",BUFSIZ);
    
    strncpy(linker_options,"",BUFSIZ);
   
       /* Parse Command Line Options */
    while ((c = getopt (argc,argv,"O::SW:cd:f::ghm:l:p:s::o:v"))!=-1) {
	
       switch (c) {
	     
	case 'O': if (optarg==NULL) optimize_level=1;
	          else optimize_level=optarg[0]-'0';
	          break;
	case 'S':   output_options=O_ASSEMBLY; break;
	case 'W':   debug_level=D_WARNINGS; break;
	case 'c': output_options=O_ASSEMBLY | O_OBJECT; break;
	case 'd': output_options|=O_DOMTREE;
	case 'f': printf("WARNING: Ignoring -f option\n"); break;
	case 'g': printf("WARNING: gdb debug not supported\n"); break;
	case 'h': vmwHelp(argv[0],1);
	case 'm': if (!strncmp(optarg,"ppc-linux",10)) {
                     cpu_info.architecture=vmwPPC;
	          }
		  else {
		     printf("\nUnknown architecture %s\n\n",optarg);
		     exit(1);
		  }		      
		  break;
	case 'l': sprintf(linker_options,"-l%s",optarg);	  
	          break;
	case 'p': printf("WARNING: Profiling not supported\n"); break;
	case 's': output_options|=O_SSAINITIAL;
	          output_options|=O_SSAFINAL;
	          break;
	case 'o': strncpy(output_file,optarg,BUFSIZ);
	          output_file[BUFSIZ-1]='\0';
	          break;
	case 'v': vmwHelp(argv[0],0); break;
	default: printf("Unknown command line option! Use -h for help!\n");
	  
       }
    }

    if (argv[optind]==NULL) {
       printf("Missing filename!\n");
       return -1;
    }
   
   
       /* Get the filename */
    strncpy(basename,argv[optind],BUFSIZ);
    basename[BUFSIZ-1]='\0';
   
       /* Read file in and parse it */
    vmwParse(basename);

       /* Find out the "base" name of the file compiling */
    i=strlen(basename);
    while(i>0) {
      if (basename[i]=='.') {
         basename[i]=0;
         break;
      }
      i--;
    }
    if (i==0) vmwError("Cowardly refusing to overwrite source!\n");

       /* Put result in current directory */
    name_ptr=basename+strlen(basename);
    while(name_ptr>basename) {
      if (*name_ptr == '/') {
	name_ptr++;
          break;
      }
       name_ptr--;
    }
    printf("COMPILING: source \"%s\" into output \"%s.s\"\n",argv[optind],name_ptr);
    printf("COMPILING: ");
    
    switch(cpu_info.architecture) {
     case vmwPPC: printf("PPC"); break;
     case vmwAlpha: printf("Alpha"); break;
     case vmwIa32: printf("ia32"); break;
     default: printf("Unknown");
    }
    printf(" architecture:  sizeof long=%i, sizeof int=%i, sizeof char=%i\n",
	   sizeof(long),sizeof(int),sizeof(char));
	 	
    IRGenerate(globscope,name_ptr);

    if (output_options & O_OBJECT) { 
	
       printf("ASSEMBLING: source \"%s.s\" into output \"%s.o\"\n",name_ptr,name_ptr);
       sprintf(temp_string,"as -o %s.o %s.s",name_ptr,name_ptr);
       system(temp_string);
       printf("%s\n",temp_string);
    }
   
   
    if (output_options & O_EXECUTABLE) {
	
       printf("LINKING: source \"%s.o\" into output \"%s\"\n",name_ptr,name_ptr);
       sprintf(temp_string,"ld -o %s %s.o -dynamic-linker /lib/ld.so.1 %s",
	       name_ptr,name_ptr,linker_options);
       system(temp_string);   
       printf("%s\n",temp_string);
    }
   
   
    return 0;
}

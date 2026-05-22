/* Include files */
#include <exec/types.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/* Fuctions */
void OutputBanner(FILE *out_file);
void OutputUsage(void);

/* Constants and shortcuts */
#define PROG_NAME    "FDI"
#define PROG_VERS    "2.2"
#define PROG_DATE    __DATE__

#define CTRL_C       (SetSignal(NULL,NULL) & SIGBREAKF_CTRL_C)
#define BREAK_TXT    "***Break - "PROG_NAME

#define MAXSTRING    256

#define MAXTABSDEF   4

/* Structures and related constants */

#define FA_TEMPLATE  "FROM/A,TO,MAXTABS/N,CALL/S,RCALL/S,SCALL/S,DEC/S,PRIV/S,NOBAN/S,QUIET/S"

struct FDIArgs {
  STRPTR  FD_NAME;
  STRPTR  INC_NAME;
  LONG  *MAXTABS;
  LONG  CALL;
  LONG  RCALL;
  LONG  SCALL;
  LONG  DEC;
  LONG  PRIV;
  LONG  NOBAN;
  LONG  QUIET;
};


/* Information for C:Version */
const char verstr[] = "$VER: "PROG_NAME" "PROG_VERS" ("PROG_DATE")";


void main()
{
  struct RDArgs *rdargs = NULL;
  struct FDIArgs FDIArgs = {NULL,NULL,NULL,
                            FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE};
  
  FILE *fd_file;
  FILE *inc_file;
  FILE *nil_file;
  FILE *out_file;
  
  char input_string[MAXSTRING];
  char base_string[MAXSTRING];
  char macro_string[MAXSTRING];
  
  BOOL end_def=FALSE;
  BOOL base_def=FALSE;
  BOOL private=FALSE;
  
  int lvo_bias=0;
  int maxtabs;
  int tabs;
  
  int i;
  
  
  /* Collect and analyse arguments */
  rdargs = ReadArgs(FA_TEMPLATE,(ULONG *)&FDIArgs,NULL);
  if (rdargs == NULL)
  {
    OutputUsage();
    exit(0);
  }
  
  nil_file = fopen("NIL:","w");

  /* Set output */
  if (FDIArgs.QUIET)
    out_file = nil_file;
  else
    out_file = stderr;


  if (!FDIArgs.NOBAN)
    OutputBanner(out_file);


  /* Open FD file for input */
  fd_file = fopen(FDIArgs.FD_NAME,"r");
  if (!fd_file)
  {
    fprintf(out_file,"Couldn't open %s for input\n",FDIArgs.FD_NAME);
    fclose(nil_file);
    FreeArgs(rdargs);
    exit(1);
  }
  
  /* Open Include file for output (if specified) */
  if (FDIArgs.INC_NAME)
  {
    inc_file = fopen(FDIArgs.INC_NAME,"w");
    if (!inc_file)
    {
      fprintf(out_file,"Couldn't open %s for output\n",FDIArgs.INC_NAME);
      fclose(nil_file);
      fclose(fd_file);
      FreeArgs(rdargs);
      exit(1);
    }
  }
  else
    inc_file = stdout;
  
  
  /* Set maximum number of tabs */
  if (FDIArgs.MAXTABS)
    maxtabs = *FDIArgs.MAXTABS;
  else
    maxtabs = MAXTABSDEF;
  
  
  /*--- Processing ---*/
  
  fprintf(out_file,"Processing %s\n",FDIArgs.FD_NAME);
  
  /* Write header comment to include file */
  fprintf(inc_file,"** Converted from \"%s\" by %s v%s\n",FDIArgs.FD_NAME,
                 PROG_NAME,
                 PROG_VERS);
  fprintf(inc_file,"** %s © %s Karl J. Ots\n\n",PROG_NAME,PROG_DATE);
  
  /* Process FD File */
  while(!feof(fd_file) && !end_def)
  {
    if (CTRL_C)
    {
      fputs(BREAK_TXT"\n",out_file);
      fclose(nil_file);
      fclose(fd_file);
      if (FDIArgs.INC_NAME)
        fclose(inc_file);
      FreeArgs(rdargs);
      exit(0);
    }
  
    fgets(input_string,MAXSTRING,fd_file);

    if (input_string[0] == '*')
      fputs(input_string,inc_file);
    
    else if (!strncmp("##base ",input_string,7))
    {
      strcpy(base_string,input_string+7);
      base_def = TRUE;
    }
    else if (!strncmp("##bias ",input_string,7))
      sscanf(input_string+7,"%d",&lvo_bias);
    
    else if (!strncmp("##public",input_string,8))
      private = FALSE;
    
    else if (!strncmp("##private",input_string,9))
      private = TRUE;
    
    else if (!strncmp("##end",input_string,5))
      end_def = TRUE;
    
    else if (strncmp("##",input_string,2))
    {
      if (!private || FDIArgs.PRIV)
      {
        for (i=0; input_string[i] != '('; i++);
        input_string[i]='\0';
        
        fprintf(inc_file,"_LVO%s ",input_string);

        tabs = maxtabs - ((i + 5) / 8);
        for (i=0; i < tabs; i++)
          fputs("\t",inc_file);
        
        fputs("EQU\t",inc_file);
        
        if (FDIArgs.DEC)
          fprintf(inc_file,"-%d\n",lvo_bias);
        else
          fprintf(inc_file,"-$%04X\n",lvo_bias);
      }
      lvo_bias += 6;
    }
  }
  

  /* Create macros */
  if (!base_def)
    fputs("\tWarning: Can't create CALL macros; no \"##base\" statment.\n",out_file);
  else if (FDIArgs.CALL || FDIArgs.RCALL || FDIArgs.SCALL)
  {
    for(i=0; base_string[i] != '\0'; i++)
      ;
    base_string[i-1] = '\0';
    
    strcpy(macro_string,base_string+1);
    
    for(i=0; macro_string[i] != 0; i++)
      macro_string[i] = toupper(macro_string[i]);
    macro_string[i-4] = '\0';
    
    /* Standard CALL macro */
    if (FDIArgs.CALL)
    {
      fprintf(inc_file,"\nCALL%s\tmacro\n",macro_string);
      fprintf(inc_file,"\tmove.l\t%s,a6\n",base_string);
      fprintf(inc_file,"\tjsr\t_LVO\\1(a6)\n");
      fprintf(inc_file,"\tendm\n");
    }
    
    /* PC Reletive CALL macro */
    if (FDIArgs.RCALL)
    {
      fprintf(inc_file,"\nRCALL%s\tmacro\n",macro_string);
      fprintf(inc_file,"\tmove.l\t%s(pc),a6\n",base_string);
      fprintf(inc_file,"\tjsr\t_LVO\\1(a6)\n");
      fprintf(inc_file,"\tendm\n");
    }
    
    /* Simple CALL macro */
    if (FDIArgs.SCALL)
    {
      fprintf(inc_file,"\nSCALL%s\tmacro\n",macro_string);
      fprintf(inc_file,"\tjsr\t_LVO\\1(a6)\n");
      fprintf(inc_file,"\tendm\n");
    }
  }
  
  fclose(nil_file);
  fclose(fd_file);
  if (FDIArgs.INC_NAME)
    fclose(inc_file);
  FreeArgs(rdargs);
}

/* Output program banner */
void OutputBanner(FILE *out_file)
{
  fputs("\033[1m",out_file);  /* Bold text */
  fputs(""PROG_NAME" v"PROG_VERS" © "PROG_DATE" Karl J. Ots\n",out_file);
  fputs("\033[0m",out_file);  /* Plain text */
  fputs("\n",out_file);
}

/* Output program usage */
void OutputUsage(void)
{
  OutputBanner(stderr);
  fputs("Bad Args!\n",stderr);
  fputs("Type \"FDI ?\" for template.\n",stderr);
  fputs("\n",stderr);
}

/* Disable automatic program abortion if present */
void chkabort(void)
{
  return;
}

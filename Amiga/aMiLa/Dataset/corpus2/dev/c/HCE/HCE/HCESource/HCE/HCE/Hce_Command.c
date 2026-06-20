/* Copyright (c) 1994, by Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *
 * Hce_Command.c:
 *               Functions to control the optimizer,assembler and linker.
 */

#include <intuition/intuition.h>
#include <clib/stdio.h>
#include <clib/string.h>
#include <dos/dos.h>
#include <dos/dostags.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"

#define OPT_SUFFIX   ".a"           /* Out suff. */
#define ASM_SUFFIX   ".o"           /* Out suff. */

#define OPTIMIZER    "Top"
#define ASSEMBLER    "A68k"
#define LINKER       "Blink"

#define COM_SIZE      1024      /* Command buffer size. (1K min). */

static char COMMAND[COM_SIZE];  /* Command buffer. */
static short undef_sym=0;       /* Linker found undefined symbol(s)? */

char LinkedFile[GB_MAX];        /* Copy of final output name from linker.*/
char *cli_ComF[3] = {OPTIMIZER,ASSEMBLER,LINKER};
char *def_LIBS = {"LIB:Misc.lib+LIB:Stdio.lib+LIB:String.lib+LIB:Ami.lib"};

struct TagItem cli_Tags[2];     /* For call to SystemTaglist(). */
extern int screen_flg;          /* Screen at front/back?. */
extern char *l_templist[56];    /* List of files to be linked. */


/* 'Ram Disk:<name>'  not allowed in some paths ,convert to RAM:<name> */
/* note: use of PR_BUF and PR_OTHER. */
void Fix_RAMDISK(s)
char *s;
{
  char *p,*v;
  int i;

  v = s;

   if(strlen(v) >= 7)
      {
         p = PR_OTHER;
         i=0;

         while(i++ <= 7)
               *p++ = *v++;
               *p = '\0';

      if((stricmp(PR_OTHER,"Ram Disk")) == 0) {
          strcpy(PR_BUF,"RAM");
          strcat(PR_BUF,v);
          strcpy(s,PR_BUF);
          }
      }
}

/* Add a slash to path name if required. */
/* note: the buffer pointed to by path must have space for an extra char. */
void Add_Slash(path)
char *path;
{
  int i;

  if(path && path[0] != '\0') {
       i = strlen(path);
    if(path[i-1] != '/' && path[i-1] != ':') {
       path[i++] = '/';
       path[i] = '\0';
       }
   }
}

/* Add or change a files suffix. */
void Add_Suff(fname,suf)
char *fname,*suf;
{
 char *p=fname;

 while((*p != '\0') && (*p != '.'))
       *p++;
    if((*suf != '.') && (*p != '\0')) /* If new suff missing '.' keep old.*/
       *p++;
    if((*p != ':') && (*p != '/')) {
       while(*suf != '\0') {
             *p++ = *suf++;
             }
        *p = '\0';
       }
}

/* Keep old filename but change path. */
/* note: the returned string must be freed by the caller. (free(str))*/
char *Fix_PATH(name,path)
char *name,*path;
{
    char *v;

  if(!(v = (char *)malloc((strlen(path) + strlen(name) + 2))))
     return(NULL);
     *v = '\0';
  if(path && path[0] != '\0') {
     strcpy(v,path);
     Add_Slash(v);         /* Add '/' if required. */
     }
     StripPATH(name);      /* Strip old path leaving filename. */
     strcat(v,name);       /* Append filename to new path. */

return(v);
}

/* Check 'fname' for '.a','.a' or '.o' suffix. */
int is_asm(fname)
char *fname;
{
  while(*fname != '.' && *fname != '\0')
         fname++;
  if(*fname == '.') {
     if((*++fname == 'a') || (*fname == 'o'))
        return(1);
    }
return(NULL);
}

long cli_SHOP()   /* Do a cli command using SystemTaglist(). */
{
  cli_Tags[0].ti_Tag = SYS_UserShell;   /* Use current shell. */
  cli_Tags[0].ti_Data = NULL;
  cli_Tags[1].ti_Tag = TAG_END;         /* No more Tags. */
  cli_Tags[1].ti_Data = TAG_END;

  return(((long)SystemTagList((UBYTE *)COMMAND,cli_Tags)));
}


char *Do_OPTIMIZER(fname)  /* Run optimizer and give oppropriate flags. */
char *fname;               /* Uses 'fname' for input and output file names */
{                          /* by switching the suffix. */
 char *s;                  /* If successful return output name else NULL. */
 int i;                    /* NOTE: Caller must free the returned string. */
  if(!(fname))
     return(NULL);  /* No filename? */

  strcpy(COMMAND,cli_ComF[0]);  /* Get optimizer name. */
  
  if(O_GadBN[0])
     strcat(COMMAND," -d");     /* Debug */
  if(O_GadBN[1])
     strcat(COMMAND," -v");     /* Verbose. */
  if(O_GadBN[2])
     strcat(COMMAND," -b");     /* Branch reversal off. */
  if(O_GadBN[3])
     strcat(COMMAND," -l");     /* Loop rotation off. */
  if(O_GadBN[4])
     strcat(COMMAND," -p");     /* Peephole optimization off. */
  if(O_GadBN[7])
     strcat(COMMAND," -r");     /* Variable Registerizing. */
  if(O_GadBN[5])
     strcat(COMMAND," -g");     /* No change of stack fix-ups. */
  if(O_GadBN[6])
     strcat(COMMAND," -c");     /* Data-Bss to chip memory. */

     strcat(COMMAND," ");
     strcat(COMMAND, fname);    /* Input filename.(path allowed)*/
     strcpy(PR_BUF, fname);
     Add_Suff(PR_BUF,OPT_SUFFIX);

     strcat(COMMAND," ");
     strcat(COMMAND, PR_BUF);   /* Output filename.(path allowed)*/

/********** DEBUG ************
     printf("%s\n",COMMAND);
     return(NULL);
******************************/

  if(cli_SHOP() > 0)
     return(NULL);                    /* Failure. */
   else
     return((char *)strdup(PR_BUF));  /* Success. */
}

char *Do_ASSEMBLER(fname)  /* Run assembler and give oppropriate flags. */
char *fname;               /* Uses 'fname' for input and output file names */
{                          /* by switching the suffix. */
 char *s;                  /* If successful return output name else NULL. */
 int i,l;
  if(!(fname))
     return(NULL);  /* No filename? */

  Fix_RAMDISK(fname);           /* Convert "Ram Disk" to "RAM" if present. */

  strcpy(COMMAND,cli_ComF[1]);  /* Get Assembler name. */
  
  if(A_GadBN[0])
     strcat(COMMAND," -d");     /* Sym table to obj. */
  if(A_GadBN[1])
     strcat(COMMAND," -e");     /* Write equate file. */

  if(!A_GadBN[2])
     strcat(COMMAND," -q");     /* Quiet*/
    else
     strcat(COMMAND," -q100");  /* VERBOSE. (Quiet 100 lines). */

  if(A_GadBN[3])
     strcat(COMMAND," -n");       /* Disable obj code optimization. */
  if(A_GadBN[4])
     strcat(COMMAND," -y");       /* Display hashing stats. */

  if(A_IncHeader[0] != '\0') {    /* Include header file. */
     strcat(COMMAND, " -h");
     strcat(COMMAND,A_IncHeader);
     }
  if(A_IDirList[0] != '\0') {     /* Include directery list. */
     strcat(COMMAND, " -i");
     strcat(COMMAND, A_IDirList);
     }
  if(A_CListFile[0] != '\0') {    /* Create a listing file. */
     strcat(COMMAND, " -l");
     strcat(COMMAND, A_CListFile);
     }
  if(A_Debug[0] != '\0') {        /* Debug. */
     strcat(COMMAND, " -z");
     strcat(COMMAND, A_Debug);
     }

     strcpy(PR_BUF, fname);
     Add_Suff(PR_BUF,ASM_SUFFIX);

  if(!(s = Fix_PATH(PR_BUF,A_OutPath))) /* Switch comp/opt path for asm path*/
     return(NULL);

     strcat(COMMAND," -o");
     strcat(COMMAND, s);               /* Output filename.*/

     strcat(COMMAND," ");
     strcat(COMMAND, fname);           /* Input filename. */

     strcpy(PR_BUF,s);
     free(s);

/********** DEBUG ************
     printf("%s\n",COMMAND);
     return(NULL);
******************************/

  if(cli_SHOP() > 0)
     return(NULL);                    /* Failure. */
   else {
     return((char *)strdup(PR_BUF));  /* Success. */
     }
}

int L_undefsym()      /* Check if linker found any undefined symbols, */
{                     /* and reset undef_sym flag. */
  short r=undef_sym;
  undef_sym=FALSE;
  return(r > 0 ? 1 : 0);
}

int Do_LINKER(fname)  /* Run linker and give oppropriate flags.          */
char *fname;          /* Uses 'fname' for input and output if outname,   */
{                     /* not specified. If asm suffix exists then this   */
 char *s,*v;          /* is removed to make the output name.             */
 BPTR lock;           /* If no suffix then '.ex' is appended to outname. */
 long i;              /* If no 'fname' then first argument of l_templist */
                      /* is used else first argument of L_LinkList.      */
                      /* 0=failure, 1=success.                           */

  if(!(lock = Lock(NULL, SHARED_LOCK)))  /* Keep original current dir. */
     return(NULL);
  if(!(DirToCurrent(A_OutPath,NULL)))    /* Make asm outpath current. */
     return(NULL);

     strcpy(COMMAND,cli_ComF[2]);  /* Get Linker name. */
     strcat(COMMAND," ");

  if(L_StartOBJ[0] != '\0')
     strcat(COMMAND,L_StartOBJ);   /* Startup object.  */
   else
     strcat(COMMAND,"begin.o");    /* default startup. */

  if(fname) {                      /* File to be linked. */
     strcat(COMMAND,"+");
     strcat(COMMAND, fname);
     }
  if(l_templist[0] != NULL && L_GadBN[3] != 1) { /* Get Files from compile*/
     i=0;                                        /* if not list only.[3]=1*/
         while(l_templist[i] != NULL) {
               strcat(COMMAND,"+");
               strcat(COMMAND, l_templist[i]);
               i++;
         }
     }
  if(L_LinkList[0] != '\0' && L_GadBN[3])   /* LinkList set in linker */
    {                                       /* options screen. */
     i=0;
     while((s = (char *)com_ARG(L_LinkList,&i)) != NULL)
         {
/* Add assembler OutPath. (currently not required)
          if(!(v = (char *)Fix_PATH(v,A_OutPath))) {
             free(s);
             return(NULL);
             }
*/
             strcat(COMMAND,"+");
             strcat(COMMAND,s);
             free(s);
          }
      }

     strcat(COMMAND, " LIB ");

  if(L_GadBN[4]) {                  /* Use, Math.lib? */
     strcat(COMMAND,L_MathLib);
     strcat(COMMAND,"+");
     }
  if(L_Libs[0] != '\0')            /* Other Libraries. */
     strcat(COMMAND,L_Libs);
   else
     strcat(COMMAND,def_LIBS);     /* Default libraries. */

     strcat(COMMAND," TO ");


  if(L_OutName[0] != '\0') {       /* Use specified outname. */
     strcat(COMMAND,L_OutName);
     strcpy(LinkedFile,L_OutName);
     }
    else                           /* Use default type outname. */
     {       
         i=0;
       if(!fname)   /* No file name at all. */
        {
          if(l_templist[0] && L_GadBN[3] != 1) {   /* Use first name from */
                 strcpy(LinkedFile,l_templist[0]); /* compiled. */
                 i=strlen(LinkedFile);
              if(LinkedFile[i-2] == '.')
                 LinkedFile[i-2] = '\0';
                else
                 strcat(LinkedFile,".ex");
                 strcat(COMMAND,LinkedFile);
               }
              else {                      /* else first name from LinkList */
                       v = NULL;
                   if(L_GadBN[3] && L_LinkList[0] != '\0') 
                      {
                        i=0;
                        if((v = com_ARG(L_LinkList,&i)))
                          {
                          if(!(s = (char *)Fix_PATH(v,A_OutPath))) {
                             free(v);
                             return(NULL);
                             }
                             strcpy(LinkedFile,s);
                             i=strlen(LinkedFile);
                          if(LinkedFile[i-2] == '.')
                             LinkedFile[i-2] = '\0';
                          else
                             strcat(LinkedFile,".ex");
                             strcat(COMMAND,LinkedFile);
                             free(s);
                           }
                        }
                   if(!v)                  /* or defualt as last resort.*/
                      {
                      if(C_QuadDev[0] != '\0')
                           strcpy(LinkedFile,C_QuadDev);   /* Out device.*/
                         else
                           strcpy(LinkedFile,"RAM:");      /* default*/
                           strcat(LinkedFile,"a.out");     /* def outname*/
                           strcat(COMMAND, LinkedFile);
                       }
                       else
                           free(v);
                    }
            } 
           else {                  /* filename exists!!. */
                  i=strlen(fname);
               if(fname[i-2] == '.') {      /* If suffix then remove it, */
                  strcpy(LinkedFile,fname); /* and outname is ready.     */
                  LinkedFile[i-2] = '\0';
                  strcat(COMMAND,LinkedFile);
                  }
                  else {           /* No suffix then must add '.ex' */
                        strcpy(LinkedFile,fname);
                        strcat(LinkedFile,".ex");
                        strcat(COMMAND,LinkedFile);
                        }
                 }
     }
    
     if(L_GadBN[0])
        strcat(COMMAND," VERBOSE");  /* VERBOSE. */
     if(L_GadBN[1])
        strcat(COMMAND," SD");       /* Small Data. */
     if(L_GadBN[2])
        strcat(COMMAND," SC");       /* Small Code. */

/********* DEBUG ***********
     printf("%s\n",COMMAND);
     return(NULL);
*****************************/

  if((i = cli_SHOP()) > 0) {
   if(i == 3) {           /* Allow undefined symbols but give warning. */
      i=1;
      Show_Status("WARNING: Linker found undefined symbol(s)");
      undef_sym=TRUE;
      } else {            /* Failure. */
              DeleteFile(LinkedFile);
              LinkedFile[0] = '\0';
              i=0;
              }
  } else {
          i=1;            /* Success. */
          }
  if(!(CurrentDir(lock))) /* Restore current dir. */
     i=0;

return(i);
}

/**************** These functions use the above functions. ***************/

int Do_QuickY(s)      /* Do simple cli command. 0=failure, 1=success. */
char *s;
{
    strcpy(COMMAND,s);
  
  if(cli_SHOP() > 0)
     return(NULL);    /* Failure. */
   else
     return(1);       /* Success. */
}

char *PROCESS_1(flg) /* Compile plus Optimize. keeping of compiler output */
char *flg;           /* is optional. Optimizer always kept. */
{                    /* NOTE: caller must free the returned string. */
 char *p,*s;
   if(!(p = (char *)Do_Compile(flg)))
        return(NULL);
        Show_StatV3("Optimizing:  %s ...", p);
   if(O_GadBN[1] && !screen_flg) {   /* [1].Optimizer-Verbose. */
        Scr_to_Back();
        screen_flg++;
        }
   if(!(s = (char *)Do_OPTIMIZER(p))) {
      if(!C_GadBN[0])                /* Keep Quad?. */
        DeleteFile(p);
        Show_Status("Optimizer file error!");
        free(p);
        return(NULL);
        }
   if(!C_GadBN[0])                   /* Keep Quad?. */
        DeleteFile(p);
        free(p);

 return(s); /* Return pointer to optimizer output filename. */
}

char *PROCESS_2(flg) /* Compile,Optimize and Assemble. */
char *flg;           /* Expects '.c' files but can also */
{                    /* accept '.asm' files. */
 char *p,*t,*strdup();
 WORD asmonly=0;     /* If file passed was an asm file set this so as */
                     /* to ensure it is not deleted. */

  if(is_asm(flg))    /* '.a' or '.asm' - Asm file? */
     {
      p = strdup(flg);
      asmonly++;
      }
    else {           /* Norm '.c' file. */
           if(!(p = (char *)PROCESS_1(flg)))
                return(NULL);
          }
   if(A_GadBN[2] && !screen_flg) {       /* [2].Assem-Verbose. */
      Scr_to_Back();
      screen_flg++;
      }
    else {
           if(!A_GadBN[2] && screen_flg) {
              Delay(MIN_DELAY);
              Scr_to_Front();
              screen_flg=0;
              }
          }

          Show_StatV3("Assembling:  %s ...", p);

   if(!(t = (char *)Do_ASSEMBLER(p))) {
          Show_Status("Assembler file error!");
       if(!asmonly && !C_GadBN[0])     /* Keep Quad?. */
          DeleteFile(p);
          free(p);
          return(NULL);
        }
   if(!asmonly && !C_GadBN[0])  /* Keep Quad?. */
        DeleteFile(p);          /* Optimizer out file. */
        free(p);

return(t);     /* Assembler out file. */
}

int PROCESS_3(s)      /* Link. */
char *s;
{
 char *p;
 int i=0;

/* No file no LinkList and no templist. */
  if(!s && (!L_GadBN[3] || L_LinkList[0] == '\0') && 
     l_templist[0] == NULL) {
     Show_Status("Nothing to link!");
     return(NULL);
     }

   if(L_GadBN[0] && !screen_flg) {   /* [0].Linker-Verbose. */
        Scr_to_Back();
        screen_flg++;
        }
      if(s) {
        Show_StatV3("Linking:  %s ...", s);
        }
       else {
             if(l_templist[0] != NULL) {
                Show_StatV3("Linking:  %s ...", l_templist[0]);
                }
               else {
                    if(L_GadBN[3] && L_LinkList[0] != '\0') {
                       if((p=com_ARG(L_LinkList, &i))) {
                            Show_StatV3("Linking:  %s ...", p);
                            free(p);
                            }
                       }
                      else
                       Show_Status("Linking ...");
                     }
        }
  if(!(Do_LINKER(s))) {
        Show_Status("FATAL: Linker file error!");
        return(NULL);
        }
return(1);
}

void Fix_SCREEN()   /* If screen was sent to back return it. */
{
 if(screen_flg) {
    Delay(STD_DELAY);
    Scr_to_Front();
    screen_flg=0;
    }
}

/* Duplicate a string of file arguments from 'src' to 'dst' and switch the */
/* suffix for each file  to 'suf'. Arguments are determined by words which */
/* are seperated by  "+" or " ". */
int dup_ARGLIST(dst,src,suf)
char *dst,*src,*suf;
{
 char *v,*p,*r;
 int i=0,l;

 dst[0] = '\0';

 if(!(src))    /* Not an error just nothing to copy. */
    return(1);


       while((v = (char *)com_ARG(src,&i)) != NULL) /* Try get arg. */
             {
              if(!(p = (char *)malloc((int)strlen(v) + 4))) {
                free(v);
                return(0);
                }
                r = v;
                strcpy(p,r);
                free(v);

              for(r = p; *r != '\0'; *r++) /* Remove old suffix, */
                  if(*r == '.')            /* if exists. */
                     *r = '\0';
                r = p;
                strcat(r,suf);             /* Add new suffix. */
                r = p;
                strcat(dst,r);             /* Copy changed file to dest.*/
                strcat(dst,"+");           /* Add a seperater. */
                free(p);
              }

 /* Last seperater ("+") not required. */
     r = dst;
     i = strlen(r);
   if(i)
     dst[i-1] = '\0';

return(1);
}

/* Check a file argument list to see if each file is found at the */
/* specified directory. Arguments are determined by words which   */
/* are seperated by  "+" or " ". */
/* If file is not found at 'dir',then the assembler outpath (A_OutPath) */
/* is prepended and file is checked again. */
void check_ARGLIST(list,dir)
char *list,*dir;
{
  char *v,*r,*p;
  int i=0,l;
  short status=0;

  if(!list || (list && *list == '\0')) { /* List buffer empty? */
     return;
     }
  while((v = (char *)com_ARG(list,&i)) != NULL) /* Try get arg. */
      {         
       if(!(r = Fix_PATH(v,dir))) { /* Add/change path to 'dir' */
            free(v);
            return;
            }
       if(!(file_exists(r,NULL)))             /* Try specified path. */
           {
           if(!(p = Fix_PATH(v,A_OutPath))) {
                free(r);
                free(v);
                return;
                }                             /* Retry with A_OutPath. */
           if(!(file_exists(p,NULL))) {
                sprintf(PR_OTHER,"File: %s not found! - (continue.?)",r);
              if(!(Do_ReqV2(PR_OTHER))) {
                     free(p);
                     free(r);
                     free(v);
                     return;
                     }
                   status++;
                free(p);
                }
            }
            free(r);
       free(v);
       }
 if(!status) {
    Do_ReqV1("List is OK!");
    } else {
           if(status > 1) {
              Do_ReqV3(PR_OTHER,"%d - files not found!",status);
            } else {
                    Do_ReqV1("1 - file not found!");
                    }
            }
}

char *com_ARG(s,p) /* Return next argument from string starting search */
char *s;           /* from *p.The arg-string returned must be freed by */
int *p;            /* the caller. Arguments are determined by words which */
{                  /* are seperated by  "+" or " ". */
  char *strdup();
  int i=0;

  s += *p;

  while(*s != '\0' && (*s == ' ' || *s == '+')) {
        *s++;
        ++*p;
        }

      if(*s != '\0') {

              do {
                  PR_BUF[i++] = *s++;
                  ++*p;
                  }
              while(*s != '\0' && *s != ' ' && *s != '+');

         PR_BUF[i] = '\0';
         return(strdup(PR_BUF));
         }

 return(NULL);
}

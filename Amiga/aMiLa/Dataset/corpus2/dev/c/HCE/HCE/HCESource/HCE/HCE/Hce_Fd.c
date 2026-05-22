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
 * This code was developed from 'FD2Stubs.c' by Detlef Wuerkner.
 * It was used to create interface stubs for HCC and CCLib.
 *
 * USE:
 *        Create libraries for HCE from FD/Object files.
 *
 * NOTES:
 *       1) Create 1 stub file per function found in the fd file.
 *       2) Assemble each stub and append to a temp lib.
 *       3) Any stubs marked as private are Ignored.
 *       4) When no funcs are left, append temp lib to main lib.
 *       5) Delete temp lib.
 *       6) Repeat (1-5) until no FD files are left.
 *
 *        A list of upto 55 FD files can be done in one call.
 *        The Linkers 'L_LinkList[]' buffer is used to store the list.
 *        The Assemblers 'A_OutPath[]' buffer is used for destination.
 *        If any of the files in the L_LinkList buffer are object files
 *        then they are simply appended to the main library.
 */

/* Original notes by Detlef:
 *          
 * written in 4/90 by
 *
 * Detlef Wuerkner
 * Asterweg 3
 * D-6301 Wettenberg-Launsbach
 * West Germany
 *
 * Version 1.1
 *
 * 15-01-91 TetiSoft Only A0,A1,D0,D1 are scratch (CClib.library V3.0)
 * 20-05-91 TetiSoft A2 now register variable
 *
 * This is Public Domain
 *
 * The following MUST be declared in the same manner than in
 * PARAM.H for the compiler itself!!!
 *
 * TetiSoft We will save D3 since CClib.library V3.0
 * no longer destroys it like V1.0, so we will use it for
 * register variables.
 *
 * D2 is used by HCC for Data Shifts (ASL etc).
 * So we must not save it, even when CClib.library V3.0 seems to keep it.
 */

#define ARV_START '2'	/* A0-A1 are allowed to be destroyed */
#define DRV_START '3'	/* D0-D2 are allowed to be destroyed */

#include <exec/types.h>
#include <exec/memory.h>
#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>

static FILE *fdfile, *stubfile, *libfile, *libfile2;
static char *fdname, *stubname, *basename, *libname;
static char *linebuf,*s1,*regsave,*regmove,*movem;
static char *f_buf1,*f_buf2,*f_buf3,*f_buf4;
static long liboffset, linenr, fderror;
static short public;

int get_FdMem()   /* Get large mem. */
{
   void free_FdMem();
   linebuf=s1=regsave=regmove=movem=f_buf1=f_buf2=f_buf3=f_buf4=NULL;

/* Get buf mem */
   if((linebuf = malloc(1000))) {
       if((s1 = malloc(1000))) {
           if((regsave = malloc(1000))) {
               if((regmove = malloc(1000))) {
                   movem = malloc(1000);
                }
            }
        }
     }
/* Disk buf mem */
  if((f_buf1 = malloc(BUFSIZ))) {
     if((f_buf2 = malloc(BUFSIZ))) {
        if((f_buf3 = malloc(BUFSIZ)))
            f_buf4 = malloc(BUFSIZ);
       }
     }

/* Mem failure? */
   if((!movem) || (!f_buf4)) {
      free_FdMem();
      return(NULL);
      }
}

void free_FdMem() /* Free mem, safely. */
{
  if(libfile)          /* Close main lib. */
     fclose(libfile);
  if(libfile2)         /* Close temp lib. */
     fclose(libfile2);
  if(stubname)         /* free stubname.  */
     free(stubname);
  if(fdname)           /* free fdname.    */
     free(fdname);
  if(basename)         /* free basename.  */
     free(basename);
  if(libname)          /* free libname.   */
     free(libname);
  if(f_buf1)           /* Free disk buffers. */
     free(f_buf1);
  if(f_buf2)
     free(f_buf2);
  if(f_buf3)
     free(f_buf3);
  if(f_buf4)
     free(f_buf4);
  if(linebuf)         /* Free other buffers. */
     free(linebuf);
  if(s1)
     free(s1);
  if(regsave)
     free(regsave);
  if(regmove)
     free(regmove);
  if(movem)
     free(movem);
}

/* This copies an FD filename, appends it to A_OutPath and also removes */
/* the '_lib' extension. (caller must free returned string) */
char *get_StubName()
{
 char *s,*v;

   if((v = strdup(fdname)) != NULL) {   /* Don`t want '_lib' extention. */
       s=v;
       while((*v != '_') && (*v != '\0'))
             v++;
          *v = '\0';
     }
    else goto gsout;

   if((v = Fix_PATH(s,A_OutPath)) != NULL) {
          free(s);
      if((s = malloc(strlen(v)+6)) != NULL) { /* Need extra space for */
          strcpy(s,v);                        /* suffix. (nameNNN.o)  */
          free(v);
          return(s);
          }
         else goto gsout;
     }
    else free(s);

gsout:
      fderror++;
      return(NULL);
}

/* Open stub file for write. */
int open_StubFile()
{
   if(!(stubfile = fopen (stubname, "w"))) {
        Do_ReqV3(PR_BUF,"Could not open file <%s>", stubname);
        fderror++;
        return(NULL);
        } 
        setbuf(stubfile, f_buf2);
return(1);
}

/* Open FD file for read. */
int open_FdFile()
{
    if(!(fdfile = fopen (fdname, "r"))) {
         Do_ReqV3(PR_BUF,"Could not open file <%s>", fdname);
         fderror++;
         return(NULL);
         }
         setbuf(fdfile, f_buf1);
return(1);
}

/* Open main library for write. */
int open_FdLib()
{
  if(!(libfile = fopen(L_LibOut, "wb"))) {
     Do_ReqV3(PR_BUF,"Could not open file <%s>",L_LibOut);
     free_FdMem();
     return(NULL);
     }
     setbuf(libfile,f_buf3);
return(1);
}

/* Open temp library for write. */
int open_TempLib(fname)
char *fname;
{
  if(!(libfile2 = fopen(fname, "wb"))) {
     Do_ReqV3(PR_BUF,"Could not open file <%s>",fname);
     fderror++;
     return(NULL);
     }
     setbuf(libfile2,f_buf4);
return(1);
}

/* Keep within max files. */
int max_fdfile(fdnum)
short fdnum;
{
   if(fdnum > 54) {
      Do_ReqV1("To many files - (Max-55)");
      fderror++;
      return(1);
      }
return(NULL);
}

/* Append file to main lib. */
int fd_append(fname)
char *fname;
{
  if(!fderror) {
     if(!(AppendFile(libfile,fname))) {
          Do_ReqV1("Append Error!");
          fderror++;
          return(NULL);
          }
  }
return(1);
}

/* Append file to temp lib. */
int fd_appendV2(fname)
char *fname;
{
  if(!fderror) {
     if(!(AppendFile(libfile2,fname))) {
          Do_ReqV1("Append Error!");
          fderror++;
          return(NULL);
          }
  }
return(1);
}

/* notes:
 *
 * Open main library (L_LibOut[]) for write.
 * Convert FD-func to asm stub.(name.NNN).
 * Call Do_ASSEMBLER() to assemble stub.
 * Call fd_appendV2() to append assembled stub to temp lib.
 * When all funcs for current fd file are done append templib
 * to main lib with fd_append().
 * Repeat until all FD files in 'L_LinkList[]' buffer are done.
 * If file in L_LinkList is an object then just append.
 * Stub/Object files are kept if the Compiler flag C_GadBN[0] is set.
 */
int FD_TO_LIB()
{
   register char *s,*v;
   char *strdup(),*malloc(),*itoa();
   char num[10];
   int fdnr,l,i=0;
   short r=0;
   fderror=0;

   fdfile=stubfile=libfile=libfile2=NULL;
   stubname=basename=libname=NULL;

  if(!(get_FdMem()))         /* Get buf mem. */
     return(NULL);

  if(!(open_FdLib()))        /* Open main library for write. */
     return(NULL);

/******* MAIN LOOP  *******/
  while((fdname = (char *)com_ARG(L_LinkList,&i)) != NULL)
   {
    liboffset=0;
    linenr=0;
    public=1;
    fdnr=1;
                                /* 55 files max.(0-54) */
    if(max_fdfile(r++))
       break;

                                /* '.o' object file, append to main lib. */
    if(is_asm(fdname)) {        /* Show user, file appended. */
            sprintf(PR_OTHER,"Adding %s",fdname);
            mod_StrGad(l_gadlist, (WORD)18, PR_OTHER);
         if(!(file_exists(fdname,NULL))) {
            if((s = Fix_PATH(fdname,A_OutPath)) != NULL) {
               free(fdname);    /* If file not at current path etc */
               fdname = s;      /* try A_OutPath. */
               }
            }
         if(!(fd_append(fdname)))
            break;
            Delay(10);
            free(fdname);
         continue;
        }
    if(!(open_FdFile()))        /* Open FD-file for read.*/
       break;
    if(basename != NULL) {      /* Free previous basename? */
       free(basename);
       basename=NULL;
       }
                                /* Get stubname without '_lib.fd' */
    if(stubname != NULL)        /* Free last!. */
        free(stubname);
    if(!(stubname = get_StubName()))
        break;
        l=strlen(stubname);

    if(libname != NULL)          /* Get temp libname. */
       free(libname);            /* Free last!. */
       libname = strdup(stubname);

    if(!(open_TempLib(libname))) /* Open temp lib .*/
        break;
                                 /* Show user current stub. */
        sprintf(PR_OTHER,"Adding %s.stubs", libname);
        mod_StrGad(l_gadlist, (WORD)18, PR_OTHER);

/****** LOOP UNTIL NO FUNCS, OR EOF ********/
       while((s=fd_getline()) && (!fderror))
            {
              stubname[l] = '\0';
              strcat(stubname,itoa(fdnr++,num,10));

                                      /* Open stub file for write.*/
            if(!(open_StubFile()))
               break;

               FD_FuncToAsm(s);       /* FD-func to asm stub. (name.NNN) */
               fclose(stubfile);
               s=NULL;
                                      /* Assemble stub. */
            if(!(fderror)) {
               if(!(s = (char *)Do_ASSEMBLER(stubname))) {
                    Do_ReqV1("Assembler file error!");
                    fderror++;
                    }
               }
                                      /* Append stub to temp lib. */
            if(public)                /* Only if public!. */
               fd_appendV2(s);

            if(!C_GadBN[0]) {         /* Keep stub/object files? */
                DeleteFile(stubname);
                DeleteFile(s);
                }
            if(s)
                free(s);
             }
/***** FUNC LOOP END **********************************************/

             fclose(libfile2);   /* Close temp lib. (write)      */
           fd_append(libname);   /* Append temp lib to main lib. */
        if(!C_GadBN[0])          /* Keep temp lib?. */
         DeleteFile(libname);
       fclose(fdfile);           /* Close fd file. (read).       */
     free(fdname);
  if(fderror)
     break;
     }
/***** MAIN LOOP END ***********************************************/

free_FdMem();        /* Free buffer memory, close files etc. */
return(fderror);
}

/* Loop until function. If EOF return NULL. */
/* If '*' comment line ,ignore. */
/* If any ##private funcs are found set 'public' to 0. (Do not append) */
char *fd_getline()
{
    register char *s;
    register int i;

 for(;;)
     {
      if(!(fgets(linebuf, 1000, fdfile))) {
 	   fd_warn("##end missing");
           return(NULL);
           }
      if(fderror)                      /* Quit if error */
         return(NULL);

         linenr++;
         s=linebuf;

      while (*s && isspace(*s))
         s++;
      if (*s == '\0')			/* Empty line */
         continue;
      if (*s == '*')			/* Comment line */
         continue;
      if (*s != '#')                    /* Function description? */
          return(s);

      i=0;				/* '##' Instruction line. */
      while (*s && !isspace(*s))
         s1[i++] = *s++;
      s1[i] = '\0';
      if (strcmp(s1, "##end") == 0)
         return NULL;
      if (strcmp(s1, "##public") == 0) {
         public=1;
         continue;
      }
      if (strcmp(s1, "##private") == 0) {
         public=0;
         continue;
      }
      if (strcmp(s1, "##bias") == 0) {
         if (liboffset != NULL)
            fd_error("Second decl of ##bias");
         else {
            while (*s && isspace(*s))
               s++;
            i = 0;
            while (*s && isdigit(*s))
               s1[i++] = *s++;
            s1[i] = '\0';
            if (s1[0] == '\0')
               fd_error("##bias: number expected");
            liboffset -= atol(s1);
            continue;
         }
      }
      if(strcmp(s1, "##base") == 0) {
         if(basename != NULL) {
            fd_error("Second decl of ##base");
            }
           else {
                 while(*s && isspace(*s))
                       s++;
                       i=0;
                 while(*s && !isspace(*s))
                       s1[i++] = *s++;
                       s1[i] = '\0';
                 if(s1[0] == '\0')
                     fd_error("##base: basename expected");
                   else
                     basename = strcpy((char *)malloc(strlen(s1)+1),s1);
                 }
         continue;
        }
      fd_error("Unknown # command");
   }
}

void fd_error(s)
char *s;
{   
   sprintf(PR_OTHER,"%s in %s on line %ld", s, fdname, linenr);
   fderror++;
   Do_ReqV1(PR_OTHER);
}

/* Warnings are not serious enough to halt program execution, so just */
/* show the warning in the 'OutName' gadget and the 'Link List' gadget.*/
void fd_warn(s)
char *s;
{
   sprintf(PR_OTHER,"WARN: %s", s);
   mod_StrGad(l_gadlist, (WORD)6, PR_OTHER);
   sprintf(PR_OTHER,"IN: %s-line %ld", fdname, linenr);
   mod_StrGad(l_gadlist, (WORD)10, PR_OTHER);
   Delay(MIN_DELAY);
}

/* Convert Function found in FD file to Assembler and place in stub file.*/
void FD_FuncToAsm(s)
register char	*s;
{
   char *rs, *rm, *move, *help;
   register int i;
   int savenr, slashnr, numargs1, numargs2;
   register char c;

   rs = regsave;
   *rs = '\0';
   rm = regmove;
   *rm = '\0';
   move = movem;
   *move = '\0';
   savenr = 0;
   slashnr = 0;
   numargs1 = 0;
   numargs2 = 0;

   if(liboffset == 0)
      fd_error("##bias expected");
   if(basename == NULL)
      fd_error("##base expected");

   i=0;
   while (*s && *s != '(')	/* get funcname */
      s1[i++] = *s++;
      s1[i] = '\0';

   if(s1[0] == '\0')
      fd_error("func name expected");
   if(*s != '(')
      fd_error("expected '('");

  if(basename)
     fprintf(stubfile, "\tXREF\t%s\n", basename);
     fprintf(stubfile, "\tXDEF\t_%s\n\n", s1);
     fprintf(stubfile, "_%s:\n", s1);
     fprintf(stubfile, "\tmove.l\t%s,A6\n", basename);

   *s++; 
   if(isalpha(*s))
      numargs1=1;
   else if(*s != ')')
           fd_error("expect letter or ')' or '('");

   while(*s && *s != ')') {	     /* count args */
      *s++;
      if(*s == ',') {
         numargs1++;
         *s++;
         while(*s == ' ')
               *s++;
         if(!isalpha(*s))
            fd_error("expected arg after ','");
       }
    }

   while(*s && *s != '(')	     /* get register list */
         *s++;
   if(*s == '\0') {
      if(numargs1 == 0) {
         fprintf(stubfile,"\tjmp\t%ld(A6)\n\n\tEND\n", liboffset);
         liboffset -= 6;
         return;
      }
      fd_error("expected reg list");
   }

   *s++;
   help=s;
   while(*s && *s != ')') {		/* count registers to save */
      c=toupper(*s);
      if(c != 'A' && c != 'D')
         fd_error("expected 'A' or 'D' reg");
         *s++;
      if(*s < '0' || *s > '7')
         fd_error("expect reg val from 0 to 7");
      if(c == 'A' && *s > '5')
         fd_error("illegal address reg");
      if((c == 'A' && *s >= ARV_START) || (c == 'D' && *s >= DRV_START))
         savenr++;
         *s++;
      if(!(*s == '/' || *s == ',' || *s == ')'))
         fd_error("expect '/' or ',' or ')'");
      if(*s != ')')
         *s++;
   }
   s=help;

   while(*s && *s != ')') { /* examine register list */
      c=toupper(*s);
      numargs2++;
      *s++;
      if((c == 'A' && *s >= ARV_START) || (c == 'D' && *s >= DRV_START)) {
         if(regsave[0])
            *rs++ = '/';
         *rs++ = c;
         *rs++ = *s;
         *rs = '\0';
      }
      if(regmove[0])
         *rm++ = '/';
      *rm++ = c;
      *rm++ = *s;
      *rm = '\0';
      *s++;
  if(*s != '/') { /* If a slash is found, we can moveM many regs at a time */
       strcat(movem, "\tmovem.l\t"); /* A68k will change single movem's */
         while (*move)		     /* into normal move's */
            *move++;
         ltoa(4*(numargs2 + savenr - slashnr), move, 10);
		/* On the stack are the arguments, the saved regs, and the
		   return address. If we didn't get some args separated from
		   this here by a slash yet, we must subtract that. The
		   return address must not be added, since we always count
		   one arg too much. */
         strcat(movem, "(sp),");
         strcat(movem, regmove);
         while(*move)
               *move++;
         *move++ = '\n';
         *move = '\0';
         rm = regmove;
         *rm = '\0';
         slashnr = 0;
      }
      else
         slashnr++;
      if(*s != ')')
         *s++;
   }
   if(numargs2 < numargs1)
      fd_error("more params than regs");
   if(numargs2 > numargs1)
      fd_warn("fewer params than regs");
   if(regsave[0])
      fprintf(stubfile, "\tmovem.l\t%s,-(sp)\n", regsave);
   if(movem[0])
      fprintf(stubfile, "%s", movem);
   if(regsave[0]) {
      fprintf(stubfile, "\tjsr\t%ld(A6)\n", liboffset);
      fprintf(stubfile, "\tmovem.l\t(sp)+,%s\n\trts\n", regsave);
   }
   else
      fprintf(stubfile, "\tjmp\t%ld(A6)\n", liboffset);
   liboffset -= 6;
   fprintf(stubfile, "\n\tEND\n");
}

/* Do more error checking and call FD_TO_LIB(). */
void DO_FDTOLIB()
{
 if(L_LinkList[0] != '\0') {
     if(FD_TO_LIB())
        Do_ReqV1("Cannot-Continue!");
      else
        Do_ReqV3(PR_BUF,"Created %s, No-Errors",L_LibOut);
      
        mod_StrGad(l_gadlist, (WORD)6, L_OutName);
        mod_StrGad(l_gadlist, (WORD)10, L_LinkList);
        mod_StrGad(l_gadlist, (WORD)18, L_LibOut);
       }
     else Do_ReqV1("List is Empty!");
}

/* Copyright (c) 1988,1989,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	main.c
 *
 *	Main routine, error handling, keyword lookup.
 *
 * Modified by Detlef Wuerkner for AMIGA
 * ALL Changes marked with TETISOFT (The flag FOR_AMIGA was already here!)
 * except '#ifdef DEBUG', 'size_i' instead of 'SIZE_I' and 'exit(EXIT_xxx)'
 *
 * 1993-1994.
 * Very heavily modified by Jason Petty to work with hce.
 * All changes marked (if feasible) with VANSOFT.
 * NOTE: 'main()' no longer useable. Converted to 'Do_Compile()'.
 */

#include <exec/types.h>
#include <clib/stdio.h>
#include <clib/string.h>
#include "h_inc/param.h"
#include "h_inc/nodes.h"
#include "h_inc/tok.h"
#include "h_inc/hce_defines.h"

#define PAUSE_HCC  60  /* Pause before returning to hce. VANSOFT.*/

extern char *got_env;  /* Env string or NULL if prob. (from Hce_Con.c).*/

/* ADDED BY TETISOFT */
int longflag;
int size_u;
int size_i;

/* The following structures are taken from other files. They contain the
 * sizes of int and unsigned and must be changed at runtime for the ability
 * to use 16 or 32 bit values.
 * Taken from gsub.c */

char bsz[] = {
	SIZE_C,
/* ADDED BY TETISOFT */
	SIZE_S,
	SIZE_L, SIZE_L, SIZE_S, SIZE_U_DEF,
	SIZE_I_DEF, SIZE_C, SIZE_F, SIZE_D, 0
};

/* Taken from d2.c */
struct bt {
	char	*name;
	int	size;
	char	align;
} btbl[] = {
	{"Uchar",       SIZE_C, ALN_C},
/* ADDED BY TETISOFT */
	{"Ushort",	SIZE_S, ALN_S},
	{"Ulong",       SIZE_L, ALN_L},
	{"Long",        SIZE_L, ALN_L},
	{"Short",       SIZE_S, ALN_S},
	{"Uns",         SIZE_U_DEF, ALN_U},
	{"Int",         SIZE_I_DEF, ALN_I},
	{"Char",        SIZE_C, ALN_C},
	{"Float",       SIZE_F, ALN_F},
	{"Dbl",         SIZE_D, ALN_D},
	{"Void",        0},
};

int msg_shown;           /* Number of error msgs shown.Added VANSOFT. */
int e_line[MAXERRS];     /* Keep line and error message for first five,*/
char *el_error[MAXERRS]; /* errors. VANSOFT. */
int lineno;
int nmerrors;
int nwarns;              /* Added VANSOFT. */
int pflag = 0;           /* enable profiling */
char ERR_BUF[128];       /* For printing error messages. VANSOFT.*/
char FirstERR[128];      /* Keep first error and first warning,  */
char FirstWARN[128];     /* for use after compile. VANSOFT. */

#ifdef	DEBUG
int oflags[26];
int xflags[26];
static int anydebug;
#define debug oflags['z'-'a']
#endif

FILE *input,*myinput;
FILE *output;

#if CC68
FILE *fopenb();
#define fopen fopenb
#endif
char *inname;

/* ADDED BY TETISOFT */
#ifdef FOR_AMIGA
char *outname;
int sawchip;
#endif

#if NEEDBUF
char my_ibuf[BUFSIZ];
#endif

#ifdef MINIX
#define strchr	index
#endif

NODEP cur;
#define MAXPREDEF  20
static int npred = 5;

struct def {
	char *dname, *dval;
} defines[MAXPREDEF] = {
	{"MC68000"},
	{"mc68000"},
	{"SOZOBON"},
#ifdef FOR_AMIGA
	{"AMIGA"},
	{"AMIGADOS"},
#else
	{"ATARI_ST"},
#ifdef MINIX
	{"MINIX"},
#else
	{"TOS"},
#endif
#endif
};

#ifndef FOR_AMIGA         /* TETISOFT */
char tmpdir[128] = ".";   /* Where the output goes */
#endif


/* This is called either by Do_Compile() below to free all */
/* hcc_calloc/hcc_malloc mem or when 'hce' exits.(Hce_Con.c). VANSOFT. */
void FreeForExit()
{
  extern NODE *freelist;
  free_hcc();
  freelist = NULL;
}

/* Do_Compile(*s):  This function was the 'main()' function.           */
/*                  Heavily modified to work with hce.                 */
/*                  Returns 0 on error else pointer to outname.        */
/*                  The caller must free the returned string.(free(s)) */

/* Note: '*s' is used to determine if input is taken from hce`s LINE[][] */
/*        buffer or from a file. None NULL = file. (see Hce_Command.c)   */
/* also:  The input file name 'inname' is now only used for error msgs,  */
/*        IO_FileName[] and '*s' are used in its place.                  */

char *Do_Compile(s)
char *s;
{
   extern NODE *freelist;
   char *getenv(),*strdup(), *v;
   void freeall_V2(),free_hcc(),clear_Eline();
   int i,l,t;

   msg_shown=0;         /* No error msgs shown yet. */
   input=NULL;          /* No input.  */
   myinput=NULL;        /* No input.  */
   output=NULL;         /* No output. */
   v=NULL;              /* No temp filename. */
   clear_Eline();       /* No error msgs/line numbers. */
   FirstERR[0] = '\0';
   FirstWARN[0] = '\0';

  if (sizeof(NODE) & 3) {
        Show_Status("COMPILER ERROR: sizeof NODE not mult of 4!!");
	return(NULL);
        }

  /* Set compiler flags. */
        doopt();
 
  /* Setup outname preceded by the quadfile device. (RAM: etc) */
  /* Also get inname without path for error msgs. */

     if(IO_FileName[0] == '\0')
        strcpy(IO_FileName,"(Untitled)");

     if(s != NULL) {             /* If new filename must keep old and*/
        v = strdup(IO_FileName); /* restore later. */
        strcpy(IO_FileName, s);
        }

        (void)StripPATH((inname = strdup(IO_FileName)));
        strcpy(PR_OTHER, C_QuadDev);
        strcat(PR_OTHER, inname);
        outname = PR_OTHER; /* Use inname for outname by switching suff */
        i = strlen(outname);

  if (!(i >= 2))      /* Check length and add '.q' if needed to outname.*/
      {
         Show_Status("Input name to short! - 3 chars min.");
         free(inname);
         return(NULL);
       }
  if (outname[i-2] == '.')
        {
         outname[i-1] = 'q';
         } 
       else {         /* Was no suffix at all?. */
                outname[i++] = '.';
                outname[i++] = 'q';
                outname[i] = '\0';
             }
      outname = strdup(outname);


 /* Use file for input?. default hce`s 'LINE[][]' buffer. */
      if(s != NULL) {
            if(!(input = fopen(IO_FileName, ROPEN))) {
                 Show_StatV3("Could not open %s for input!",IO_FileName);
                 free(inname);
                 free(outname);
              if(v != NULL) {          /* Restore IO_FileName. */
                 strcpy(IO_FileName,v);
                 free(v);
                 }
                 return(NULL);
                 }
                 myinput=input; /* Note original input handle. */
#if NEEDBUF
                 setbuf(input, my_ibuf);
#endif
            }

 /* 'INCLUDE' environment variable. Now parsed on hce`s startup.VANSOFT.*/
      if(got_env != NULL) {
           doincl(got_env);
           got_env=NULL;
           }

 /* If called while editor was marking out a block then test code between */
 /* the beginning and end markers.(Only if input is from 'LINE' buffer) */
 if((!input) && (BLOCK_ON || MOUSE_MARKED)) {
     if(blk_SY == LINE_Y) {         /* End line cannot be same as start. */ 
        i = blk_SY;
        l = blk_SY+1;
        } else {
               if(blk_SY < LINE_Y)  /* Start line. */
                  i = blk_SY;
                else i = LINE_Y;
                                    /* End line. */
                l = (i==blk_SY) ? LINE_Y+1 : blk_SY+1;
        }
      lineno = i+1;
      reset_bufxy(i,l);
     }
    else {                 /* Reset keepx and keepy to 0, */
       lineno=1;           /* so as hcc reads start of 'LINE' buffer. */
       reset_bufxy(0,0); 
      }

      (void)Reset_MMon();   /* Set memory monotoring variable to current */
                            /* freemem, and mem_keep flag to 1. */

    if(!C_GadBN[3])         /* Free-up flag. (set in Hce_GadCtrl.c).  */
      (void)SetMemFailed(); /* This will cause all memory to be freed,*/
                            /* (if required) ready for next compile.  */

 /* Show Files/line and memory during compile. */
                 Clear_MBox();
                 Any_Msg("Compiling : ", inname, 0);
             Show_StatV2("  Include : 0", 1);
             Show_StatV2("     Line : 1", 2);
        sprintf(PR_OTHER,"      Mem : %ld", (ULONG)TotalMemK());
        Show_StatV2(PR_OTHER,3);

  if(!dofile())         /* Compile infile '.c' to outfile '.q'. */
    {
     if(outname) {
        if(!C_GadBN[0])      /* Keep Quad?.*/
          remove(outname);
          free(outname);
          }
     if(v != NULL) {         /* Restore IO_FileName. */
          strcpy(IO_FileName,v);
          free(v);
          }
     if(!(CheckMemFail())) { /* If mem_keep==0L. (SetMemFailed() called?). */
          FreeForExit();     /* Free all hcc_calloc/hcc_malloc mem. VANSOFT*/
          }
                             /* Free all malloc_V2/calloc_V2 memory,*/
      freeall_V2();          /* ready for next compile.(see mem.c). VANSOFT*/ 
      return(NULL);
     }

   if(v != NULL) {          /* Restore IO_FileName. */
          strcpy(IO_FileName,v);
          free(v);
          }
   if(!(CheckMemFail())) {  /* Note: hcc memory is freed under two */
          FreeForExit();    /*       conditions: 1=if user requests it. */
          }                 /*                   2=if memory failure.   */
 
     freeall_V2();          /* Always free this. (Include file buf mem etc)*/
     Delay(PAUSE_HCC);      /* In case of quick compiles do a small pause. */

 return(outname);  /* OK!!. */
}


adddef(s)
char *s;
{
	char *as, *strchr();
        void Get_FstWARN();

	if (npred >= MAXPREDEF) { /* VANSOFT. */
		Show_ErrV1("Error: To Many Predefines!");
                nmerrors++;
		return;
	}
	if ((as = strchr(s,'=')) != NULL)
		*as++ = 0;
	else
		as = NULL;
	defines[npred].dname = s;
	defines[npred].dval = as;
	npred++;
}

subdef(s)
char *s;
{
	int i;

	for (i=0; i<npred; i++)
		if (strcmp(s, defines[i].dname) == 0)
			goto found;
	return;
found:
	while (i < npred) {
		defines[i] = defines[i+1];
		i++;
	}
	npred--;
}

dodefs()    /* Define the "built-in" macros. */
{
	int i;
	struct def *p;
	p = defines;

	for (i=0; i < npred; i++,p++)
		optdef(p->dname, p->dval ? p->dval : "1");
}

doincl(s)
char	*s;
{
	char	*hcc_malloc(), *strcpy();
	char	buf[256];
	char	dir[128];
	register char	*p;
	char c;

	strcpy(buf, s);

   /* Convert ',' and ';' to nulls. */
	for (p=buf; *p != '\0' ;p++)
		if (*p == ',' || *p == ';')
			*p = '\0';
	p[1] = '\0';	        /* double null terminated */

   /* Grab each directory, make sure it ends with a slash */
   /* and add it to the directory list.                   */

    for (p=buf; *p != '\0' ;p++) {
	strcpy(dir, p);
	c = dir[strlen(dir)-1];
	optincl( strcpy(malloc((unsigned) (strlen(dir) + 1)), dir) );

	while (*p != '\0')
                p++;
	}
}

int dofile() /* Heavily modified by VANSOFT to work with 'hce'. */
{            /* Returns 0 on error else 1. */
 extern int nodesmade, nodesavail;
 char *scopy(),*p;
 extern NODEP deflist[], symtab[], tagtab;
 extern NODEP strsave;
 extern int level;
 void Get_FstWARN();
 int i;

    if(!out_start(outname)) { /* Was inname. changed out_start(). VANSOFT.*/
        return(NULL);
        }
 
        p = inname;
	inname = scopy(inname); /* Make new copy. */
        free(p);                /* VANSOFT. free strdup`ed string. */

        nodesmade = 1;          /* VANSOFT. */
        nodesavail = 0;         /* VANSOFT. */
/*	lineno = 1;             set elswhere*/
	nmerrors = 0;
        nwarns = 0;             /* VANSOFT. */
	dodefs();
	advnode();

/* Called once in Do_Compile, must call again for accuracy!. */
        (void)Reset_MMon();
    if(!C_GadBN[3])
        (void)SetMemFailed();

	level = 0;
	program();
	dumpstrs(strsave);
#ifdef OUT_AZ
	xrefs();
#endif
     if(input && input != stdin)    /* Close input file. */
        fclose(input);
	out_end();                  /* Close output file. */
     if (cur && cur->e_token == EOFTOK)
        freenode(cur);
	sfree(inname);
	for (i=0; i<NHASH; i++) {
#ifdef	DEBUG
		if (debug>1 && deflist[i]) {
			printf("defines[%d]", i);
			printlist(deflist[i]);
		}
#endif
		freenode(deflist[i]);
		deflist[i] = NULL;
#ifdef	DEBUG
		if (debug && symtab[i]) {
			printf("gsyms[%d]", i);
			printlist(symtab[i]);
		}
#endif
		freenode(symtab[i]);
		symtab[i] = NULL;
	}
#ifdef	DEBUG
	if (debug) {
		printf("structs");
		printlist(tagtab);
	}
#endif
	freenode(tagtab);
	tagtab = NULL;
	freenode(strsave);
	strsave = NULL;

	if (nmerrors) {
/*
		sprintf(ERR_BUF,"%d errors", nmerrors);
                Show_StatV2(ERR_BUF,4);
*/
		return(0);
	}

	if (nodesmade != nodesavail) {             /* Changed-VANSOFT. */
            sprintf(ERR_BUF,"ERR: Lost %d nodes!!!",nodesmade-nodesavail);
            Show_Status(ERR_BUF);
            return(0);
	}
/*
	printf("Space = %ldK\n", ((long)nodesavail*sizeof(NODE))/1024);
*/

/* ADDED BY TETISOFT.  */ 
/* Modified by VANSOFT. */
/* If the word 'chip' was found and tops chip flag not set,'O_GadBN[6]' will*/
/* be set to 2. This will cause files with the 'chip' keyword to have  */
/* its data placed in chip memory. */

/* O_GadBN[6] = 1 - Make all files compiled use chip mem. (see top options)*/
/* O_GadBN[6] = 2 - Only files with 'chip' keyword. (set cleared below) */
/* O_GadBN[6] = 0 - No 'chip' keyword and not set in top options. */

#ifdef	FOR_AMIGA
	if (sawchip && O_GadBN[6] != 1) {
            O_GadBN[6] = 2;
            sawchip = 0;
            Get_FstWARN("WARN: Chip data present!");
	    } else {
                    if(O_GadBN[6] == 2) /* Reset */
                       O_GadBN[6] = 0;
                    }
#endif

return(1); /* OK!!.*/
}

doopt()  /* Set all compiler options. (Heavily modified by VANSOFT). */
{
  char c;

#ifdef	DEBUG
           c = (char)C_Debug[0];
       if (c >= 'a' && c <='z') {
           oflags[c-'a']++;
           anydebug++;
	   }
#endif

       if (C_DefSym[0] != '\0')      /* Define Symbol as if in c_source. */
           adddef(C_DefSym);
       if (C_UnDefSym[0] != '\0')    /* Undefine Symbol. */
           subdef(C_UnDefSym);
       if (C_IDirList[0] != '\0') {  /* Include directory. */
           doincl(C_IDirList);
           C_IDirList[0] = '\0';
           }

/* ADDED BY TETISOFT, use of 32 bit ints */
       if (!C_GadBN[1]) {                /* 32 Bit. */
           longflag = 1;
           size_u = SIZE_U_OPTL;
           size_i = SIZE_I_OPTL;
           bsz[5] = SIZE_U_OPTL;
           bsz[6] = SIZE_I_OPTL;
           btbl[5].size = SIZE_U_OPTL;
           btbl[6].size = SIZE_I_OPTL;
           }
         else {                          /* 16 Bit. */
           longflag = 0;
           size_u = SIZE_U_DEF;
           size_i = SIZE_I_DEF;
           bsz[5] = SIZE_U_DEF;
           bsz[6] = SIZE_I_DEF;
           btbl[5].size = SIZE_U_DEF;
           btbl[6].size = SIZE_I_DEF;
           }

#ifdef	DEBUG
       if (c >= 'a' && c <='z') {
           xflags[c-'A']++;
           anydebug++;
           }
#endif
}

/*************  All error messages modified by VANSOFT. ****************/

void get_Eline(s)  /* Keep error message and line number for first, */
char *s;           /* five errors. (0-4). */
{
 if(COMP_OK && !input) {
      e_line[nmerrors] = (lineno-1);
      el_error[nmerrors] = (char *)strdup(s);
    }
}

void clear_Eline()   /* Clear error msgs + line numbers for next compile. */
{
 short i;
   for(i=0;i < MAXERRS;i++) {
         e_line[i] = 0;
      if(el_error[i]) {
         free(el_error[i]); 
         el_error[i] = NULL;
         }
     }
}

void goto_Eline(ly)  /* Place cursor in editor to error no, 0-4 and show */
int ly;              /* error msg for that line. see Do_155() in main.c. */
{
  if(ly < MAXERRS && e_line[ly]) {
     curs_jump_TO(e_line[ly]);
     Show_Status(el_error[ly]);
     }
}

Show_ErrV1(s)  /* Used by error message routines. Allows just  */
char *s;       /* 5 errors to be shown in hce`s message BOX.   */
{              /* Any messages after the 5`th are not printed. */
  void Get_FstERR();

  if(!nmerrors) {
    if(!input) {                  /* Show in editor, line where 1st error */
        Check_MMARK();            /* Check not in mouse marked state. */
        Check_KMARK();            /* Check not in key marked state.   */
        curs_jump_TO((lineno-1)); /* ocurred or a close estimation. */
        }
     Clear_MBox();
     Get_FstERR(s);               /* Keep first error. */
     }

     get_Eline(s);                /* Keep first five errors+line numbers. */

/* Note: If greater than MB_MX chars, Show_StatV2 goes onto */
/* next line. (about 75). */

  if(MSG_OK && strlen(s) < MB_MX) {
     Show_StatV2(s, msg_shown);
     msg_shown++;
     } else {
             if((strlen(s) > MB_MX ) && MSG_LONG_OK) {
               Show_StatV2(s, msg_shown);
               msg_shown += 2;
               }
     }
}

Any_Msg(s,t,l) /* Not for error msg. Can be used for any msgs. */
char *s, *t;   /* This clears msg box line 'l' then prints on it.(0-4)*/
{
  Clear_MBL(l);
  sprintf(ERR_BUF,"%s%s", s,t);
  Show_StatV2(ERR_BUF,l);
}

Any_MsgV2(s,t) /* Same as Any_Msg but prints on next available line. */
char *s, *t;   /* This only clears top line of box if we are on top line. */
{
  if(!msg_shown)
     Clear_MBL(0);
   
     sprintf(ERR_BUF,"%s%s", s,t);

/* Note: If greater than MB_MX chars, Show_StatV2 goes onto */
/* next line. (about 77). */

  if(MSG_OK && strlen(ERR_BUF) < MB_MX) {
     Show_StatV2(ERR_BUF, msg_shown);
     msg_shown++;
     } else {
             if((strlen(ERR_BUF) > MB_MX) && MSG_LONG_OK) {
               Show_StatV2(ERR_BUF, msg_shown);
               msg_shown += 2;
               }
     }

}

errors(s,t)
char *s, *t;
{
   sprintf(ERR_BUF,"Error in %s on Line %d: %s %s", inname, lineno, s,t);
   Show_ErrV1(ERR_BUF);
   nmerrors++;
}

errorn(s,np)
char *s;
NODE *np;
{
   sprintf(ERR_BUF,"Error in %s on Line %d: %s %s", inname, lineno, s,
   np->n_name);
   Show_ErrV1(ERR_BUF);
   nmerrors++;
}

error(s)
char *s;
{
   sprintf(ERR_BUF,"Error in %s on Line %d: %s", inname, lineno, s);
   Show_ErrV1(ERR_BUF);
   nmerrors++;
}

error_v2(s,lin)
char *s;
int lin;
{
 int i=lineno;
   sprintf(ERR_BUF,"Error in %s on Line %d: %s", inname, lin, s);
   lineno=lin;
   Show_ErrV1(ERR_BUF);
   lineno=i;
   nmerrors++;
}

void Show_FstERR() /* If any errors occured this will show the first one. */
{
 if(FirstERR[0] != '\0')
   Show_Status(FirstERR);
  else
   Show_Status("No-Errors!...");
}

void Get_FstERR(s)  /* Copy string to first error buf. */
char *s;
{
 if(s) strcpy(FirstERR,s);
 else  FirstERR[0] = '\0';
}

warns(s,t)
char *s, *t;
{
   sprintf(ERR_BUF,"Warning in %s on Line %d: %s %s", inname, lineno, s,t);
   Show_StatV2(ERR_BUF, 4);
 if(!nwarns++)
    strcpy(FirstWARN,ERR_BUF);
}

warnn(s,np)
char *s;
NODE *np;
{
   sprintf(ERR_BUF,"Warning in %s on Line %d: %s %s", inname, lineno, s,
   np->n_name);
   Show_StatV2(ERR_BUF, 4);
 if(!nwarns++)
    strcpy(FirstWARN,ERR_BUF);
}

warn(s)
char *s;
{
   sprintf(ERR_BUF,"Warning in %s on Line %d: %s", inname, lineno, s);
   Show_StatV2(ERR_BUF, 4);
 if(!nwarns++)
    strcpy(FirstWARN,ERR_BUF);
}

void Get_FstWARN(s)  /* Get first warning msg. */
char *s;
{
 if(s) strcpy(FirstWARN,s);
 else  FirstWARN[0] = '\0';
}

void Show_FstWARN() /* If any warns occured this will show the first one. */
{
 if(FirstWARN[0] != '\0')
   Show_Status(FirstWARN);
  else
   Show_Status("No-Warnings!...");
}

fatals(s,t) /* Changed so as not to exit() while running under hce.VANSOFT.*/
char *s, *t;
{
   sprintf(ERR_BUF,"Fatal error in %s on Line %d: %s %s",inname,lineno,s,t);
 if(MSG_LONG_OK)
   Show_ErrV1(ERR_BUF);
  else
   Show_Status(ERR_BUF);

   nmerrors++;
 /* exit(EXIT_FAILURE); */
}

fataln(s,np) /* Changed, see fatals(). */
char *s;
NODE *np;
{
   sprintf(ERR_BUF,"Fatal error in %s on Line %d: %s %s",inname,lineno,s,
   np->n_name);
 if(MSG_LONG_OK)
   Show_ErrV1(ERR_BUF);
  else
   Show_Status(ERR_BUF);

   nmerrors++;
/* exit(EXIT_FAILURE); */
}

fatal(s)  /* Changed see fatals(). */
char *s;
{
   sprintf(ERR_BUF,"Fatal error in %s on Line %d: %s",inname,lineno,s);
 if(MSG_LONG_OK)
   Show_ErrV1(ERR_BUF);
  else
   Show_Status(ERR_BUF);
   nmerrors++;
/* exit(EXIT_FAILURE); */
}

static optnl() /* Optional newline. */
{
#ifdef	DEBUG
	if (anydebug)
		putchar('\n');
#endif
}

struct kwtbl {
	char *name;
	int	kwval;
	int	kflags;
} kwtab[] = {
	/* must be sorted */
	{"asm", K_ASM},
	{"auto", K_AUTO},
	{"break", K_BREAK},
	{"case", K_CASE},
	{"char", K_CHAR},
	{"continue", K_CONTINUE},
	{"default", K_DEFAULT},
	{"do", K_DO},
	{"double", K_DOUBLE},
	{"else", K_ELSE},
	{"enum", K_ENUM},
	{"extern", K_EXTERN},
	{"float", K_FLOAT},
	{"for", K_FOR},
	{"goto", K_GOTO},
	{"if", K_IF},
	{"int", K_INT},
	{"long", K_LONG},
	{"register", K_REGISTER},
	{"return", K_RETURN},
	{"short", K_SHORT},
	{"sizeof", K_SIZEOF},
	{"static", K_STATIC},
	{"struct", K_STRUCT},
	{"switch", K_SWITCH},
	{"typedef", K_TYPEDEF},
	{"union", K_UNION},
	{"unsigned", K_UNSIGNED},
	{"void", K_VOID},
	{"while", K_WHILE},

	{0,0}
};

#define FIRST_C	'a'
#define LAST_C	'z'
struct kwtbl *kwstart[LAST_C-FIRST_C+1];

kw_init()
{
	register struct kwtbl *p;
	register c;

	for (p=kwtab; p->name; p++) {
		c = p->name[0];
		if (kwstart[c-FIRST_C] == 0)
			kwstart[c-FIRST_C] = p;
	}
}

kw_tok(tp)
NODE *tp;
{
	register struct kwtbl *kp;
	register char *nm;
	register i;
	static first = 0;

	nm = tp->n_name;
	if (first == 0) {
		kw_init();
		first = 1;
	}
	i = nm[0];
	if (i < FIRST_C || i > LAST_C)
		return;
	kp = kwstart[i-FIRST_C];
	if (kp)
	for (; kp->name; kp++) {
		i = strcmp(nm, kp->name);
		if (i == 0) {
			tp->e_token = kp->kwval;
			tp->e_flags = kp->kflags;
			return;
		} else if (i < 0)
			return;
	}
}

#if CC68
/* fix args since stupid lib makes all lower case */
upstr(s)
char *s;
{
	while (*s) {
		if (*s >= 'a' && *s <= 'z')
			*s += 'A'-'a';
		s++;
	}
}
downstr(s)
char *s;
{
	while (*s) {
		if (*s >= 'A' && *s <= 'Z')
			*s -= 'A'-'a';
		s++;
	}
}
#endif

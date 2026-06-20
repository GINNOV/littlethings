/*
 * Program FD2Stubs
 * ----------------
 * Creates interface stubs for HCC and CClib.library from .fd-files
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
 */


/* The following MUST be declared in the same manner than in
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

FILE *fdfile, *script, *stubfile;
char *fdname, *stub, *stubs, *scriptname, *libname, *basename;
char linebuf[1000], s1[1000], regsave[1000], regmove[1000], movem[1000];
char *getline();
long liboffset, linenr;
int  warnings, nrprivates, public = 1;

main(argc, argv)
char *argv[];
{
  register int i,nr;
  register char *s;
  int first=1;

  if (argc==0)
     exit(); /* Don't run from Workbench */

  if (argc==1 || argc>2) {
     printf("FD2Stubs - create interface stubs from .fd-files\n\n");
     printf("Usage: %s libraryname (_lib.fd will be added)\n\n",argv[0]);
     printf("DON'T specify a path name, CD to the .fd-directory!\n");
     printf("The program creates many files 'T:librarynameNNN',\n");
     printf("one file for each library function, and a script file\n");
     printf("'T:Makelibraryname' which will, if called via Execute,\n");
     printf("generate the file 'T:libraryname.stubs'. You can 'Join'\n");
     printf("that file together with those generated from other .fd-files\n");
     printf("to the finally file 'stubs.lib'. Assign T: to RAM:T,\n");
     printf("copy A68k, Join, Rename and Delete to RAM: and type\n");
     printf("'path RAM: add' before running the produced scriptfile.\n");
     exit(EXIT_FAILURE);
  } else {
     printf("FD2Stubs - create interface stubs from .fd-files\n");
     printf("Version 1.1 by Detlef W\374rkner\n");
     printf("This is Public Domain.\n");
  }

  libname = argv[1];

  fdname = (char *)malloc (strlen(libname) + strlen("_lib.fd") + 1);
  fdname = strcpy (fdname, libname);
  fdname = strcat (fdname, "_lib.fd");

  stubs = (char *)malloc (strlen(libname) + strlen("T:") +1);
  stubs = strcpy (stubs, "T:");
  stubs = strcat (stubs, libname);

  if (!(fdfile = fopen (fdname, "r"))) {
     printf ("Fatal error: Can't open input file '%s'\n", fdname);
     exit (EXIT_FAILURE);
  };
  setbuf (fdfile, malloc(BUFSIZ));

  scriptname = (char *)malloc (strlen(libname) + strlen("T:Make") + 1);
  scriptname = strcpy (scriptname, "T:Make");
  scriptname = strcat (scriptname, libname);

  if (!(script = fopen(scriptname, "w"))) {
     printf ("Fatal error: Can't open output file '%s'\n", scriptname);
     exit (EXIT_FAILURE);
  };
  setbuf (script, malloc(BUFSIZ));

/* fprintf(script, "Echo >T:%s.stubs %c%c noline ;create empty file\n",
 *                                                           libname, 34, 34);
 */

  for(nr=1; s=getline(); nr++) {
     openstubfile(nr);
     dofunction(s);
     fclose(stubfile);
     if (public) {
       if (first) {
         first = 0;
         fprintf(script,"\nA68k -q %s %s.stubs\n", stub, stubs);
         fprintf(script,"Delete %s\n", stub);
       } else {
         fprintf(script,"\nA68k -q %s %s.o\n", stub, stub);
         fprintf(script,"Join %s.stubs %s.o as %s.new\n", stubs, stub, stubs);
         fprintf(script,"Delete %s.stubs %s.o %s\n", stubs, stub, stub);
         fprintf(script,"Rename %s.new %s.stubs\n", stubs, stubs);
       }
     }
     else {
        fprintf(script, "\nDelete %s\n", stub);
        nrprivates++;
     }
  }

  fclose(fdfile);
  fclose(script);
/* SetProtection(scriptname, 0x40L); */ /* set script bit */
  if (nrprivates) {
     printf("Access denied to %ld private functions of the %s.library.\n",
            nrprivates, libname);
  }
  printf("You made a simple program very happy.\n");
  if (warnings)
     exit(EXIT_WARN);
}


openstubfile(nr)
{
   stub = (char *)malloc (strlen(libname) + strlen("T:NNN") + 1);
   stub = strcpy (stub, "T:");
   stub = strcat (stub, libname);
   stub = strcat (stub, ltoa(nr,"NNN"));

   if (!(stubfile = fopen (stub, "w"))) {
      printf ("Fatal error: Can't open output file '%s'\n", stub);
      exit (EXIT_FAILURE);
   };
/*   setbuf (stubfile, malloc(BUFSIZ)); */
};


char *getline()
{
   register char *s;
   register int i;

   for (;;) {				/* loop until EOF or function */
      linenr++;
      if (!(fgets(linebuf, 1000, fdfile))) {
	 warn("##end missing");
         return NULL;
      }
      s = linebuf;
      while (*s && isspace(*s))
         s++;
      if (*s == '\0')			/* Empty line */
         continue;
      if (*s == '*')			/* Comment line */
         continue;

      if (*s != '#')
         return s;			/* Function description ? */

      i = 0;				/* Instruction line */
      while (*s && !isspace(*s))
         s1[i++] = *s++;
      s1[i] = '\0';
      if (strcmp(s1, "##end") == 0)
         return NULL;
      if (strcmp(s1, "##public") == 0) {
         public = 1;
         continue;
      }
      if (strcmp(s1, "##private") == 0) {
         public = 0;
         continue;
      }
      if (strcmp(s1, "##bias") == 0) {
         if (liboffset != NULL)
            error("Second declaration of ##bias");
         else {
            while (*s && isspace(*s))
               s++;
            i = 0;
            while (*s && isdigit(*s))
               s1[i++] = *s++;
            s1[i] = '\0';
            if (s1[0] == '\0')
               error("##bias: number expected");
            liboffset -= atol(s1);
            continue;
         }
      }
      if (strcmp(s1, "##base") == 0) {
         if (basename != NULL)
            error("Second declaration of ##base");
         else {
            while (*s && isspace(*s))
               s++;
            i = 0;
            while (*s && !isspace(*s))
               s1[i++] = *s++;
            s1[i] = '\0';
            if (s1[0] == '\0')
               error("##base: basename expected");
            basename = strcpy((char *)malloc(strlen(s1)+1),s1);
            continue;
         }
      }
      error("Unknown # command");
   }
}


error(s)
char *s;
{
   printf("Error in %s in line %ld:\n%s\n", fdname, linenr, s);
   exit(EXIT_ERROR);
}

warn(s)
char *s;
{
   printf("Warning in %s in line %ld:\n%s\n", fdname, linenr, s);
   warnings++;
}


dofunction(s)
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

   if (liboffset == 0)
      error("##bias expected");
   if (basename == NULL)
      error("##base expected");

   i = 0;
   while (*s && *s != '(')	/* get funcname */
      s1[i++] = *s++;
   s1[i] = '\0';

   if (s1[0] == '\0')
      error("functionname expected");
   if (*s != '(')
      error("'(' expected");

   fprintf(stubfile, "\tXREF\t%s\n", basename);
   fprintf(stubfile, "\tXDEF\t_%s\n\n", s1);
   fprintf(stubfile, "_%s:\n", s1);
   fprintf(stubfile, "\tmove.l\t%s,A6\n", basename);

   *s++; 
   if (isalpha(*s))
      numargs1 = 1;
   else if (*s != ')')
      error("expected a letter or ')' after '('");

   while (*s && *s != ')') {		/* count args */
      *s++;
      if (*s == ',') {
         numargs1++;
         *s++;
         while (*s == ' ')
           *s++;
         if (!isalpha(*s))
            error("expected an argument after ','");
      }
   }

   while (*s && *s != '(')		/* get register list */
      *s++;
   if (*s == '\0') {
      if( numargs1 == 0) {
         fprintf(stubfile,"\tjmp\t%ld(A6)\n\n\tEND\n", liboffset);
         liboffset -= 6;
         return;
      }
      error("expected register list");
   }

   *s++;
   help = s;
   while (*s && *s != ')') {		/* count registers to save */
      c = toupper(*s);
      if (c != 'A' && c != 'D')
         error("expected 'A' or 'D' in register list");
      *s++;
      if (*s < '0' || *s > '7')
         error("expected value between '0' and '7' in register list");
      if (c == 'A' && *s > '5')
         error("illegal address register");
      if ((c == 'A' && *s >= ARV_START) || (c == 'D' && *s >= DRV_START))
         savenr++;
      *s++;
      if (!(*s == '/' || *s == ',' || *s == ')'))
         error("expected '/', ',' or ')' in register list");
      if (*s != ')')
         *s++;
   }
   s = help;

   while (*s && *s != ')') {		/* examine register list */
      c = toupper(*s);
      numargs2++;
      *s++;
      if ((c == 'A' && *s >= ARV_START) || (c == 'D' && *s >= DRV_START)) {
         if (regsave[0])
            *rs++ = '/';
         *rs++ = c;
         *rs++ = *s;
         *rs = '\0';
      }
      if (regmove[0])
         *rm++ = '/';
      *rm++ = c;
      *rm++ = *s;
      *rm = '\0';
      *s++;
      if (*s != '/') {	/* If a slash is found, we can moveM many regs at a time */
         strcat(movem, "\tmovem.l\t");	/* A68k will change single movem's */
         while (*move)			/* into normal move's */
            *move++;
         ltoa(4*(numargs2 + savenr - slashnr), move);
		/* On the stack are the arguments, the saved regs, and the
		   return address. If we didn't get some args separated from
		   this here by a slash yet, we must subtract that. The
		   return address must not be added, since we always count
		   one arg too much. */
         strcat(movem, "(sp),");
         strcat(movem, regmove);
         while (*move)
            *move++;
         *move++ = '\n';
         *move = '\0';
         rm = regmove;
         *rm = '\0';
         slashnr = 0;
      }
      else
         slashnr++;
      if (*s != ')')
         *s++;
   }
   if (numargs2 < numargs1)
      error("more parameters than registers listed.");   
   if (numargs2 > numargs1)
      warn("fewer parameters than registers listed.");   
   if (regsave[0])
      fprintf(stubfile, "\tmovem.l\t%s,-(sp)\n", regsave);
   if (movem[0])
      fprintf(stubfile, "%s", movem);
   if (regsave[0]) {
      fprintf(stubfile, "\tjsr\t%ld(A6)\n", liboffset);
      fprintf(stubfile, "\tmovem.l\t(sp)+,%s\n\trts\n", regsave);
   }
   else
      fprintf(stubfile, "\tjmp\t%ld(A6)\n", liboffset);
   fprintf(stubfile, "\n\tEND\n");
   liboffset -= 6;
}

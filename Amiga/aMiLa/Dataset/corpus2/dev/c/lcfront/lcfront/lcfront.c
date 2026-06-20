/*
** Lattice C compiler driver - "lc", (c) 2016 Thomas Richter - thor software
** This is a "compiler frontend" for the Lattice 5.10.b compiler from the
** SAS institute. It is in no way associated to the original compiler driver
** and not related or based on the original work.
**
** The motivation for this replacement compiler driver is to avoid the
** CreateProc() function the original driver depends upon - which is not
** available under some simple forms of emulation.
*/

#include <stdio.h>
#include <string.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <pragmas/dos_pragmas.h>
#include <clib/dos_protos.h>
extern struct DosLibrary *DOSBase;

#define MAX_ARGLEN 512

static const char stack[] = "$STACK:32768";
static const char ver[] = "lcfront 1.00 (1.1.2016) © THOR";

static int system(char *cmdline)
{
  BPTR out = Open("*",MODE_OLDFILE);
  BPTR in  = Open("*",MODE_NEWFILE);
  int res;

  if (out && in) {
    res = SystemTags(cmdline,
                     SYS_Input,    in,
                     SYS_Output,   out,
                     NP_StackSize, 32768,
                     TAG_DONE);
  } else res = -1;

  if (out)
    Close(out);

  if (in)
    Close(in);

  return res;
}

static void addoption(char *buffer,const char *option,const char *args)
{
  strncat(buffer,option,MAX_ARGLEN);
  strncat(buffer,args,MAX_ARGLEN);
  strncat(buffer," ",MAX_ARGLEN);
}

int main(int argc,char **argv)
{
  char phase1[16];
  char phase2[16];
  char phase1args[MAX_ARGLEN];
  char phase2args[MAX_ARGLEN];
  char cmd[MAX_ARGLEN];
  char quaddir[256];
  char quadout[256];
  char **nargs= argv+1;
  int  nargc  = argc-1;
  int cont         = 0; /* continue after errors */
  int optimize     = 0; /* invoke "go" as optimizer */
  int runphase2    = 1; /* run phase 2 */
  int havedasho    = 0;
  int banner       = 1; /* print banner messages? */
  char **src;

  /* Initialize with default compiler chain commands */
  strcpy(phase1,"lc1");
  strcpy(phase2,"lc2");
  strcpy(quaddir,"QUAD:");
  phase1args[0] = 0;
  phase2args[0] = 0;
  cmd[0]        = 0;
  quadout[0]    = 0;

  while (nargc > 0 && *nargs) {
    char *narg = *nargs;
    char *ext;
    /* Filter out only arguments with compiler arguments */
    if (narg[0] == '-') {
      switch(narg[1]) {
      case 'a': /* place hunks in chip mem */
	addoption(phase2args,"-c",narg+2);
        break;
      case 'o': /* final output directory */
        havedasho = 1;
	ext = strrchr(narg+1,'.');
	/* If there is an extender, and the extender is .q, do not run phase 2 */
	if (ext && ext[1] == 'q') {
	  runphase2 = 0;
	  addoption(phase1args,"-",narg+1);
	  break;
	}
        /* runs into the following */
      case 'h': /* place hunks in fast memory */
      case 'm': /* machine type, unspecified as lc2 option in the original manual */
      case 's': /* hunk name generation */
      case 'v': /* disable stack checking */
      case 'y': /* load base register A4 even without __saveds */
	addoption(phase2args,"-",narg+1);
        break;
      case 'C':
        cont = 1;
        break;
      case 'g': /* switch to big version, generate cross-references */
        strcpy(phase1,"lc1b");
        /* runs into the following */
      case 'b': /* base-relative addressing */
      case 'c': /* compatibility options */
      case 'd': /* debugging settings */
      case 'e': /* extended code sets */
      case 'f': /* floating point settings */
      case 'i': /* include directory */
      case 'j': /* generation of errors */
      case 'l': /* long word alignment */
      case 'n': /* long symbol names */
      case 'r': /* registerized parameters */
      case 'u': /* undefine lattice compiler defines */
      case 'w': /* short integers */
      case 'x': /* implicit extern for globals */
      case 'z': /* set size of preprocessor buffer */
	addoption(phase1args,"-",narg+1);
        break;
      case 'H': /* precompiled headers. */
	addoption(phase1args,"-h",narg+2);
        break;
      case 'p': /* generate precompiled headers, do not invoke phase 2 */
	addoption(phase1args,"-",narg+1);
        runphase2 = 0;
        break;
      case 'O':
        optimize = 1;
        break;
      case 'q': /* quad file generation, generation of warnings */
        if ((narg[2] >= 'A' && narg[2] <= 'Z') || (narg[2] >= 'a' && narg[2] <= 'z')) {
          strncpy(quaddir,narg+2,sizeof(quaddir) - 1);
          quaddir[sizeof(quaddir) - 1] = 0;
        } else {
	  addoption(phase1args,"-",narg+1);
        }
        break;
      case '.': /* suppress banner */
	banner = 0;
	addoption(phase1args,"-",".");
	addoption(phase2args,"-",".");
	break;
      case 'D': /* officially, this option does not exist. It seems to define a symbol */
	addoption(phase1args,"-d",narg+2);
	break;
      case 'L': /* invoke linker. We currently don't do that... */
      case 'M': /* only rebuild changed files. Currently not supported... */
      case 'R': /* this invokes OML, currently not supported... */
      default:
        Printf("%s: %s argument is unsupported, sorry.\n",argv[0],narg);
        return 20;
      }
      nargs++;
      nargc--;
    } else {
      break;
    }
  }

  if (banner)
    Printf("Alternative Lattice C compiler driver, (c) THOR Software 2016.\n");
  
  /* First run phase 1 on all source files */
  for(src = nargs;*src;src++) {
    char *ext;
    int rc;
    strncpy(quadout,quaddir,sizeof(quadout) - 1);
    strncat(quadout,*src   ,sizeof(quadout) - 1);
    quadout[sizeof(quadout) - 1] = 0;
    ext = strrchr(quadout,'.'); /* the file extender */
    if (ext) {
      *ext = 0;
    }
    strncpy(ext,".q",quadout + sizeof(quadout) - 1 - ext);
    quadout[sizeof(quadout) - 1] = 0;
    ext = strrchr(*src,'.'); /* the identifier in the source */
    if (ext) {
      /* remove the extender, lc1 does not like it... */
      *ext = 0;
    }
    strncpy(cmd,phase1,MAX_ARGLEN);
    strncat(cmd," ",MAX_ARGLEN);
    strncat(cmd,phase1args,MAX_ARGLEN);
    if (runphase2 || !havedasho) {
      addoption(cmd,"-o",quadout);
    }
    strncat(cmd,*src,MAX_ARGLEN);
    if (strlen(cmd) > MAX_ARGLEN - 1) {
      Printf("argument too long, cannnot compile.\n");
      return 20;
    }
    if (banner)
      Printf("Running %s\n",cmd);
    rc = system(cmd);
    if (rc != 0 && !cont) {
      Printf("%s failed: Return code %d\n",cmd,rc);
      return rc;
    }
  }

  /* Run GO on all sources. */
  if (optimize) {
    for(src = nargs;*src;src++) {
      int rc;
      strncpy(cmd,"go ",MAX_ARGLEN);
      /* The file extender has already been removed */
      strncat(cmd,quaddir,MAX_ARGLEN);
      strncat(cmd,*src,MAX_ARGLEN);
      strncat(cmd,".q",MAX_ARGLEN);
      if (strlen(cmd) > MAX_ARGLEN - 1) {
        Printf("argument too long, cannnot compile.\n");
        return 20;
      }
      if (banner)
	Printf("Running %s\n",cmd);
      rc = system(cmd);
      if (rc != 0 && !cont) {
        Printf("%s failed: Return code %d\n",cmd,rc);
        return rc;
      }
    }
  }

  /* Run phase 2 */
  if (runphase2) {
    for(src = nargs;*src;src++) {
      int rc;
      strncpy(cmd,"lc2 ",MAX_ARGLEN);
      strncat(cmd,phase2args,MAX_ARGLEN);
      strncat(cmd," ",MAX_ARGLEN);
      if (!havedasho) {
        strncat(cmd,"-o",MAX_ARGLEN);
        strncat(cmd,*src,MAX_ARGLEN);
        strncat(cmd,".o ",MAX_ARGLEN);
      }
      strncat(cmd,quaddir,MAX_ARGLEN);
      strncat(cmd,*src,MAX_ARGLEN);
      strncat(cmd,".q",MAX_ARGLEN);
      if (strlen(cmd) > MAX_ARGLEN - 1) {
        Printf("argument too long, cannnot compile.\n");
        return 20;
      }
      if (banner)
	Printf("Running %s\n",cmd);
      rc = system(cmd);
      if (rc != 0 && !cont) {
        Printf("%s failed: Return code %d\n",cmd,rc);
        return rc;
      }
    }
  }

  return 0;
}

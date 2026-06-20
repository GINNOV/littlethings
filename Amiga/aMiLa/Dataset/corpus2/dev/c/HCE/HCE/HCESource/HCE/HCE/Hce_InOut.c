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
 * Hce_InOut.c:
 *               Does all basic file operations.
 *               Loads and saves the 'hce.config' file.
 */

/*
 * NOTE:  Requires asl.lib and dos.lib - V36 or higher.(WB-2.0)
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <clib/stdio.h>
#include <clib/ctype.h>
#include <clib/string.h>
#include <libraries/asl.h>
#include <libraries/dos.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"


/* Places searched for 'hce.config' file. */
#define  CONFIG_DNAME "SYS:devs/hce.config"
#define  CONFIG_SNAME "SYS:s/hce.config"
#define  CONFIG_CNAME "hce.config"

char IO_FileName[T_MAXSTR];   /* Stores '.c' file Name+path. */
chip char In_buffer[T_INLEN]; /* Buffer used for Read/Write. */
struct WBArg *io_arglist;     /* File argument list for multiple selection.*/

static FILE *io_fp = NULL;
static short retain_frdir=TRUE;
static short retain_frfile=TRUE;

/* FileRequester messages. */
char *gin_msg[14] = {
    "Load....","Save....","Delete....","Run....","Lock....",
    "Load-Config...","Save-Config...","Select Files To Be Copied...",
    "Enter Destination...","Makedir...","Assign...?","Path...?",
    "Rename...?","Rename as...?"};

enum pref_io {
    TOPLEV_ALL,  ENDOF_ALL,
    TOPLEV_COMP, ENDOF_COMP,
    TOPLEV_OPT,  ENDOF_OPT,
    TOPLEV_ASM,  ENDOF_ASM,
    TOPLEV_LINK, ENDOF_LINK,
    TOPLEV_OTH,  ENDOF_OTH
};

static void put_l_size(), put_s_size(), put_c_size(), put_strlist();
static long get_l_size(), get_c_size();
static int get_strlist();
static short get_s_size();

/* Check to see if file exists. 0=No, 1=Yes. */
/* 'mode':  0= read-lock,  1= write-lock.    */
int file_exists(fname, mode)
char *fname;
int mode;
{
 BPTR Lock();
 void UnLock();
 BPTR lock;

   if (mode)
       mode = ACCESS_WRITE;
     else
       mode = ACCESS_READ;

   if ((lock = Lock(fname, (long)mode)) == 0) {
        return(0);
        }

 UnLock(lock);
 return(1);
}

void Clear_FRDir()   /* When file requester is next used after this call, */
{                    /* the Directory draw will be cleared.  */
 retain_frdir = FALSE;
}

void Clear_FRFile()  /* When file requester is next used after this call, */
{                    /* the File draw will be cleared.  */
 retain_frfile = FALSE;
}

/* Use asl.lib V36 filerequester to select a file.
 * If multiple selection: put dirname in 'buf', get a pointer to
 * the filerequesters argument list then return number of args in list.
 * If single selection, put dirname+filename in 'buf' and return 1.
 * ops: determines which message is to be shown or if filerequester
 * should allow multiple selection.
 * On error/cancel 0 is returned.
 */
int Get_IO_NAME(ops,buf)
int ops;
char *buf;
{
 struct TagItem TxTags[10];
 char *p;
 WORD tagnum=6,mselect=0;

        TxTags[0].ti_Tag = ASL_Window; /* Attach freq to my_windows screen.*/
        TxTags[0].ti_Data = (ULONG)my_window;

        TxTags[1].ti_Tag = ASL_OKText;
        TxTags[1].ti_Data = NULL;
        
        TxTags[2].ti_Tag = ASL_Hail;


        switch(ops) {      /* ops: Message for ASL_Hail. */
          case IO_LOAD:
                       TxTags[2].ti_Data = (ULONG)gin_msg[0];
                       TxTags[1].ti_Data = (ULONG)"Load";
                       break;
          case IO_SAVE:
                       TxTags[2].ti_Data = (ULONG)gin_msg[1];
                       TxTags[1].ti_Data = (ULONG)"Save";
                       break;
          case IO_DELETE:
                       TxTags[2].ti_Data = (ULONG)gin_msg[2];
                       TxTags[1].ti_Data = (ULONG)"Delete";
                       mselect++;
                       break;
          case IO_RUN:
                       TxTags[2].ti_Data = (ULONG)gin_msg[3];
                       break;
          case IO_LOCK:
                       TxTags[2].ti_Data = (ULONG)gin_msg[4];
                       TxTags[1].ti_Data = (ULONG)"Lock";
                       break;
          case IO_LCONFIG:
                       TxTags[2].ti_Data = (ULONG)gin_msg[5];
                       TxTags[1].ti_Data = (ULONG)"Load";
                       break;
          case IO_SCONFIG:
                       TxTags[2].ti_Data = (ULONG)gin_msg[6];
                       TxTags[1].ti_Data = (ULONG)"Save";
                       break;
          case IO_SOURCE:
                       TxTags[2].ti_Data = (ULONG)gin_msg[7];
                       mselect++;
                       break;
          case IO_DEST:
                       TxTags[2].ti_Data = (ULONG)gin_msg[8];
                       break;
          case IO_MAKEDIR:
                       TxTags[2].ti_Data = (ULONG)gin_msg[9];
                       break;
          case IO_ASSIGN:
                       TxTags[2].ti_Data = (ULONG)gin_msg[10];
                       TxTags[1].ti_Data = (ULONG)"Assign";
                       break;
          case IO_PATH:
                       TxTags[2].ti_Data = (ULONG)gin_msg[11];
                       break;
          case IO_RENAME1:
                       TxTags[2].ti_Data = (ULONG)gin_msg[12];
                       break;
          case IO_RENAME2:
                       TxTags[2].ti_Data = (ULONG)gin_msg[13];
                       break;
          }

        TxTags[3].ti_Tag = ASL_FuncFlags;
        TxTags[3].ti_Data = NULL;
                              
        TxTags[4].ti_Tag = ASL_LeftEdge;
        TxTags[4].ti_Data = 110;
        TxTags[5].ti_Tag = ASL_TopEdge;
        TxTags[5].ti_Data = 40;

 /* Option requires multiple file selection. */
        TxTags[tagnum].ti_Tag = ASL_FuncFlags;
       if(mselect)
        TxTags[tagnum++].ti_Data = FILF_MULTISELECT;
       else
        TxTags[tagnum++].ti_Data = NULL;

/* Clear the directory draw?.*/
       if(!retain_frdir) {
        TxTags[tagnum].ti_Tag = ASL_Dir;
        TxTags[tagnum++].ti_Data = NULL;
        retain_frdir = TRUE;
        }

/* Clear the file draw?.*/
       if(!retain_frfile) {
        TxTags[tagnum].ti_Tag = ASL_File;
        TxTags[tagnum++].ti_Data = NULL;
        retain_frfile = TRUE;
        }

        TxTags[tagnum].ti_Tag = TAG_DONE;  /* No more Tags. */
        TxTags[tagnum].ti_Data = TAG_DONE;

        AssignPath("Libs","RAM:");         /* Stop requester looking for */
                                           /* 'libs:' on boot disk. */
      if(AslRequest(TxFileReq, TxTags))
       {
        AssignPath("Libs","SYS:Libs");     /* Restore 'libs:' */

        if((strlen(TxFileReq->rf_Dir) + strlen(TxFileReq->rf_File)) >
            (T_LINELEN-2)) {
            Do_ReqV1("File path to long!");
            return(0);
            }

         buf[0]='\0';
         p = TxFileReq->rf_Dir;

        if(*p != '\0')             /* No Dir means current Dir. */
           {
             if(strlen(p) == 1 && *p == '/') /* Root Dir. */
                {
                 strcpy(buf,"/");
                 }
               else                          /* Other Dir. */
                {
                 while(*p != '\0')           /* Copy dir. */
                       *buf++ = *p++;
                       *buf = '\0';
                       *p--;
                    if(*p != ':')          /* May need '/' after dir name. */
                       strcat(buf,"/");
                 }
            }

        /* Always get global pointer to arg list. */
           io_arglist = (struct WBArg *)TxFileReq->rf_ArgList;

         if(mselect)  { /* If multiple select, return numargs in arg list.*/
              return((int)TxFileReq->rf_NumArgs);
            }
          else {        /* Single selection, add filename to dir. */
            strcat(buf,TxFileReq->rf_File);
            }
        }
      else {
        AssignPath("Libs","SYS:Libs");   /* Restore 'libs:' */
        Show_Status("Cancelled...");
        return(0);                       /* No file selected. */
        }
 return(1);
}

/* Get files ending with 'pat' from 'path' and place them in 'buf'. */
/* Seperate each file name with '+' and do not exceed 'max_b' size. */
/* If buf is not empty then append files to existing files in 'buf'.*/
void DiskToList(path,pat,buf,max_b)
char *path,*pat,*buf;
int max_b;
{
  struct FileInfoBlock *fib_ptr;
  BPTR lock;
  char *p,*v;
  short yep=0;
  int i,l,counter=0;

  if(pat[0] == '\0') {
     Do_ReqV1("Must specify a valid pattern!");
     return;
     }
  if(buf[0] != '\0') { /* Append! */
      i=strlen(buf);
         if((i+2) > max_b) {
            Do_ReqV1("Not enough buffer space!");
            return;
            }
        strcat(buf,"+");
      yep++;
     }
     else i=0;

  if(!(fib_ptr = (struct FileInfoBlock *)AllocDosObject(DOS_FIB, NULL)))
       return;
  if(!(lock = (BPTR)Lock(path, SHARED_LOCK))) {
      (void)FreeDosObject(DOS_FIB, fib_ptr);
       return;
       }
  if(Examine(lock, fib_ptr))
     {
     if(fib_ptr->fib_DirEntryType > 0)
       {
         while(ExNext(lock, fib_ptr))
           {
            p=fib_ptr->fib_FileName;
            l=strlen(p)+2;
           if((fib_ptr->fib_DirEntryType < 0) && ((i+l) < max_b))
              {
                while(*p != '.' && *p != '\0')
                     p++;
                if(*p == '.') 
                  {
                   l=0;
                /* Check for more than one pattern: ".a .asm .c .o" etc.*/
                    while((v = (char *)com_ARG(pat,&l)) != NULL) {
                        if(stricmp(p,v) == 0) {
                           strcat(buf, fib_ptr->fib_FileName);
                           strcat(buf, "+");
                           i += strlen(fib_ptr->fib_FileName)+1;
                           counter++;
                           }
                     free(v);
                     }
                   }
               }
            }
         if(IoErr() != ERROR_NO_MORE_ENTRIES)
            Do_ReqV1("Read error!");
         }
        else  Do_ReqV1("Not a Device or Directory!");
      }
    else  Do_ReqV1("Could not Examine!");

  if(!i) {
      Do_ReqV3(PR_BUF,"No files found with <%s> pattern(s)", pat);
     } else {           /* Remove unwanted "+" from end. */
             if((i=strlen(buf)))
                 buf[i-1] = '\0';
             if(yep) { /* Appended. */            
                    if(counter == 1)
                       Do_ReqV1("Appended, 1 file");
                    if(counter > 1)
                       Do_ReqV3(PR_BUF,"Appended %d files",counter);
               }
              else {  /* Norm */
                    if(counter > 1)
                       Do_ReqV3(PR_BUF,"Found %d files",counter);
                    }
             }
  UnLock(lock);
(void)FreeDosObject(DOS_FIB, fib_ptr);
}

/* Make directory or device the current one. */
/* If an error occurs and flg  == 0 ,it will */
/* be printed in the message window. */
int DirToCurrent(name,flg)
char *name;
int flg;
{
  BPTR lock;

       if(!(lock = Lock((UBYTE *)name, SHARED_LOCK))) {
          if(!flg)
             Print_IO_ERR();
             return(NULL);
          }
       if(!(CurrentDir(lock))) {
          if(!flg)
             Print_IO_ERR();
             return(NULL);
          }
return(1); /* OK! */
}

char *StripFN(s)   /* Get file path from string. */
char *s;           /* note: caller must free returned string.(free(str)) */
{
  char *p,*v;
  int i;

  p = PR_OTHER;
  v = s;
  i = strlen(v);
  v += i;

  while(i && *v != ':' && *v != '/') {    /* Find end of path. */
        *v--;
        i--;
        }
     if(i > 0 || (i == 0 && *v == '/'))   /* Copy path to 'PR_OTHER' */
        {
           v = s;
         while(i-- >= 0) {
           *p++ = *v++;
           }
           *p = '\0';

/*        printf("<%s>\n",PR_OTHER); */
          return((char *)strdup(PR_OTHER));
         }
 return(NULL);
}

void StripPATH(s)   /* Remove path from string; leaving file name. */
char *s;
{
  register char *p;
  register int i;

     i = strlen(s);
  if(!i--) return;

  while(s[i] != '/' && s[i] != ':' && i > 0) /* search backover for path.*/
        i--;
  if(s[i] == '/' || s[i] == ':') /* If path found, skip '/' or ':' */
     i++;
  p = s + i;

  while(*p != '\0')  /* Write over path with filename. */
        *s++ = *p++;
  *s = '\0';
}


int IO_readfile(filename,flg)  /* Read a file using FGets().(dos-v36). */
char *filename;                /* Fills 'LINE[][]' buffer.   */
WORD flg;                      /* If 'flg' = 2; append file. */
{                              /* Returns 0 on error.        */
  struct FileInfoBlock *fp,*Open ();
  int mxl,lin,i;
  register char *s,*p,*r;

  mxl = c_ConCols();      /* Max chars per line. */
  

     if(!(fp=Open (filename, MODE_OLDFILE))) {
        Print_IO_ERR();   /* Show user what went wrong. */
      if(flg != 2)
        ClearTextBuf();
        return (0);
        } 

     if(flg == 2)         /* Append-File. */
       {
               Show_StatV3("Appending - %s",filename);
               lin = Buf_Used()+1;
       } 
       else {            /* New-File. */
               Show_StatV3("Loading - %s",filename);
               ClearTextBuf();
               lin = 0;  /* Reset line number. */
               }

        s = (char *)FGets(fp,In_buffer,(ULONG)T_INLEN);

  /* Remove any weird input and get line at the same time. */

     while(s && lin < (T_MAXLINE-2))
        {
            r=LINE[lin];
            p=s;
            i=0; 

            while(*p)
             {
              if(i++ >= mxl)        /* Keep within line limmit. */
                {
                    i=0;
                 if(*p != '\n') {   /* Line to long?, break it down. */
                    *r++ = '\n';
                    *r = '\0';
                    r = LINE[++lin];
                    }
                 }
               if(*p < ' ' && *p != '\0' && *p != '\n' && *p != (char)163) {
                  *p = ' ';  /* No weird stuff!. (163, allow pound sign)*/
                  }
                  *r++ = *p++;
              }
         *r = '\0';
         s = (char *)FGets(fp,In_buffer,(ULONG)T_INLEN);
         lin++;
         }
    LINE[lin][0] = '\0';

  if(s < 0) {      /* Must have been a disk error!. */
     Print_IO_ERR();
   if(flg != 2)
     ClearTextBuf();
     Close (fp);
     return(0);
     }
  if(s)
     Do_ReqV1("Could not fit all of file into buffer!");

 Close (fp);
 return (1);
}

int IO_Save_AS()  /* Write file under a new name. */
{
   if(Get_IO_NAME(IO_SAVE,IO_FileName)) {
      if(!IO_writefile(IO_FileName))
          return(0); /* Error */
   }
  else {
        return(0);    /* 0. Cancelled. */
        }
return(1); /* OK!. */
}

int IO_writefile(filename)  /* Write contents of 'LINE[][]' to disk as */
char *filename;             /* normal c-source file. */
{
  struct FileInfoBlock *fp,*Open ();
  register int i=0;
  int err;

     if (!(fp=Open (filename,MODE_NEWFILE))) {
            Print_IO_ERR();  /* Show user what went wrong. */
	    return(0); /* Error */
            }

     Show_StatV3("Saving - %s", filename);

     while(LINE[i][0] != '\0' && i < (T_MAXLINE-2)) {
             if (FPuts(fp,LINE[i]) == -1) { /* Dos-V36. */
                 Print_IO_ERR();  /* Show user what went wrong. */
                 Close(fp);
                 return(0); /* Error. */
                 }
            i++;
           }
Close(fp);
return(1); /* OK! */
}

int copy_FILE(to,from) /* Copy a file from 'from' path to 'to' path.  */
char *to,*from;        /* note: filename can be changed on 'to' path. */
{
  FILE *infp=NULL,*outfp=NULL;
  char *ib=NULL,*ob=NULL;
  register int c;
  short er=1;

 if((infp = fopen(from, "rb")) == NULL) {
     Print_IO_ERR();
     return(0);
     }
 if((outfp = fopen(to, "wb")) == NULL) {
     Print_IO_ERR();
     er=0;
     goto cpyout;
     }
     ib = malloc(BUFSIZ);
     ob = malloc(BUFSIZ);
  if((!ib) || (!ob)) {
     er=0;
     goto cpyout;
     }
     setbuf(infp,ib);
     setbuf(outfp,ob);
 
     Show_StatV3("Copying - %s",from);
 while((c = fgetc(infp)) != EOF) {
     fputc(c, outfp);
     }
cpyout:
   if(infp)  fclose(infp);
   if(outfp) fclose(outfp);
   if(ib)    free(ib);
   if(ob)    free(ob);
return(er);
}

/* Append file from 'from' to 'to'.*/
/* 'to' should be a valid 'FILE' already opened for binary write. */
int AppendFile(to,from)
FILE *to;
char *from;
{
  FILE *infp=NULL;
  char *ib=NULL,*malloc();
  register int c;

 if((infp = fopen(from, "rb")) == NULL) {
     return(NULL);
     }
 if(!(ib = malloc(BUFSIZ))) {
     fclose(infp);
     return(NULL);
     }
     setbuf(infp,ib);

 while((c = fgetc(infp)) != EOF) {
     fputc(c, to);
     }
   fclose(infp);
 free(ib);
return(1);
}

void Print_IO_ERR()  /* If you think an In/Out error happened call this */
{                    /* to show it in the message box.                  */
   long err;

   err = (long)IoErr();

   switch(err)
   {
        case ERROR_NO_FREE_STORE:
             Show_Status("ERROR: Device used has no Free Store!");
             break;
        case ERROR_OBJECT_IN_USE:
             Show_Status("ERROR: Object in use!");
             break;
        case ERROR_DIR_NOT_FOUND:
             Show_Status("ERROR: Directory not found!");
             break;
        case ERROR_OBJECT_NOT_FOUND:
             Show_Status("ERROR: Object not found!");
             break;
        case ERROR_DISK_NOT_VALIDATED:
             Show_Status("ERROR: Disk is not Validated!");
             break;
        case ERROR_DISK_WRITE_PROTECTED:
             Show_Status("ERROR: Disk is Write Protected!");
             break;
        case ERROR_DEVICE_NOT_MOUNTED:
             Show_Status("ERROR: Device is not Mounted!");
             break;
        case ERROR_DISK_FULL:
             Show_Status("ERROR: Disk is Full!");
             break;
        case ERROR_WRITE_PROTECTED:
             Show_Status("ERROR: Object is Write Protected!");
             break;
        case ERROR_READ_PROTECTED:
             Show_Status("ERROR: Object is Read Protected!");
             break;
        case ERROR_NOT_A_DOS_DISK:
             Show_Status("ERROR: Disk not an AMIGA DOS Disk!");
             break;
        case ERROR_NO_DISK:
             Show_Status("ERROR: No disk In Drive!");
             break;
        default:
             Show_Status("ERROR: Unkown file error has occured!");
             break;
    }
}

/* ************ FROM HERE = CONFIGURATION STUFF ****************/

/* Try find then lock default config name or specified config name. */
/* mode is either "rb" or "wb" */
WORD lock_HceConfig(index,name,mode)
WORD index;
char *name,*mode;
{
  io_fp = NULL;

    while(index < 5 && !io_fp) { /* Try three dif dirs for hce.config file,*/
       switch(index) {           /* or use 'name'. */
           case 1: name = CONFIG_CNAME; break;   /* ""        */
           case 2: name = CONFIG_DNAME; break;   /* SYS:devs/ */
           case 3: name = CONFIG_SNAME; break;   /* SYS:s/    */
           default: break;
           }
       if((io_fp = fopen(name, mode)) != NULL) {
           break;
           }
      index++;
      }
  if(!io_fp)
     return(0);

return(index);
}

int write_CONFIG(name) /* Write required buffers/flags to hce.config file. */
char *name;
{
 WORD i;

  if(name) {           /* New name ,don`t use default. */
     if(name[0] == '\0')
        return(NULL);
     if(!(lock_HceConfig(4,name,"wb")))
        return(NULL);
     }
   else {              /* Look for default. */
           if((i=lock_HceConfig(1,name,"rb")) != NULL) { /* Find config.*/
                  fclose(io_fp);                         /* (overwrite) */
               if(!(lock_HceConfig(i,NULL,"wb")))
                  return(NULL);
             } 
           else {     /* Default not found. (open new) */
                  if(!(lock_HceConfig(4,CONFIG_DNAME,"wb")))
                       return(NULL);
                 }
         }

     put_c_size(TOPLEV_ALL);
     dump_Cstuff();       /* Compiler.  */
     dump_Ostuff();       /* Optimizer. */
     dump_Astuff();       /* Assembler. */
     dump_Lstuff();       /* Linker.    */
     dump_Other();        /* Any stuff. */
     put_c_size(ENDOF_ALL);

     fclose(io_fp);
return(1);
}


int read_CONFIG(name) /* Read required buffers/flags from hce.config file.*/
char *name;
{
  WORD i=1;

  if(name) {             /* New name ,don`t use default. */
     if(name[0] == '\0')
        return(NULL);
     i=4;
     }
  if(!(lock_HceConfig(i,name,"rb")))
       return(NULL);

  if((long)get_c_size() != TOPLEV_ALL)   /* Must be start level. */
     goto rc_end;
  if(!read_Cstuff())    /* Compiler 1st.  */
     goto rc_end;
  if(!read_Ostuff())    /* Opt. */
     goto rc_end;
  if(!read_Astuff())    /* Asm. */
     goto rc_end;
  if(!read_Lstuff())    /* Link.*/
     goto rc_end;
  if(!read_Other())     /* Any stuff. */
     goto rc_end;
  if((long)get_c_size() != ENDOF_ALL)    /* Must be end level. */
     goto rc_end;

     fclose(io_fp);
     return(1);        /* Ok! */
rc_end:
     fclose(io_fp);
     Do_ReqV1("Error reading config file!");
     return(1);
}


void save_ALIST(name,flg) /* Save Compiler worklist buffer or linker */
char *name;               /* link list buffer. (flg=0=C or flg=1=L)  */
int flg;
{
 char *p=NULL;
 int i;

    for(i=strlen(name); i > 0;i--) /* Remove any suffix found even if */
      if(name[i] == '.')           /* correct type. */
         name[i] = '\0';

    if(!(p = (char *)malloc(strlen(name)+4))) {
        return;
        }
        strcpy(p,name);
      if(flg)
        strcat(p,".LL");
      else
        strcat(p,".CL");

    if((io_fp = fopen(p, "wb")) == NULL) {
        Do_ReqV1("Could not save file!");
        if(p)  free(p);
        return;
        }
        put_c_size(TOPLEV_ALL);
      if(flg) {
               put_strlist(L_LinkList);
               put_strlist(L_OutName);  /* Save outname for this list. */
               put_s_size(L_GadBN[4]);  /* Save 'use' Math.lib flag. */
       } else {
               put_strlist(C_WorkList);
               put_strlist(A_OutPath);  /* Save asm outpath for this list.*/
               put_strlist(C_DefSym);   /* Predefined symbol for this list*/
               }
        put_c_size(ENDOF_ALL);
 if(p)  free(p);
 fclose(io_fp);
}

void load_ALIST(name,flg) /* Load compiler worklist buffer or linker */
char *name;               /* linklist buffer. */
int flg;                  /* Note: buffer pointed to by 'name' must have*/
{                         /* space for a '.CL' or '.LL' extention.      */
 int i = strlen(name);

  if(flg)           /* LinkList? */
   {
     if(i > 2 && name[i-3] != '.') {
        strcat(name,".LL");
        }
        else {
              if(i > 1 && toupper(name[i-2]) != 'L') {
                 Do_ReqV1("Not a leagal 'Link List' file!");
                 return;
                 }
              }
    } else {        /* WorkList? */
            if(i > 2 && name[i-3] != '.') {
                strcat(name,".CL");
                }
               else {
                     if(i > 1 && toupper(name[i-2]) != 'C') {
                        Do_ReqV1("Not a leagal 'Compile List' file!");
                        return;
                        }
                     }
    }
  if((io_fp = fopen(name, "rb")) == NULL) {
     Do_ReqV1("Could not open file!");
     return;
     }
  if((long)get_c_size() == TOPLEV_ALL) {
         if(flg) {
                  get_strlist(L_LinkList);
                  get_strlist(L_OutName);
                  L_GadBN[4] = (int)get_s_size();
          } else {
                  get_strlist(C_WorkList);
                  get_strlist(A_OutPath);
                  get_strlist(C_DefSym);
                  }
          if((long)get_c_size() != ENDOF_ALL)
              Do_ReqV1("Error reading list file!");
     }
    else {
      Do_ReqV1("Error reading list file!");
     }
fclose(io_fp);
}

void dump_Cstuff()   /* Dump all compiler buffers/flags. */
{
 WORD i=0;
     put_c_size(TOPLEV_COMP);

     put_strlist(C_DefSym);
     put_strlist(C_UnDefSym);
     put_strlist(C_IDirList);
     put_strlist(C_QuadDev);
/*   put_strlist(C_WorkList); **** Has own options ****/
     put_strlist(C_Debug);

 while(i < 4) {
    if(i != 2)
       put_s_size(C_GadBN[i]);
       i++;
     }
     put_c_size(ENDOF_COMP);
}

int read_Cstuff()  /* Read all compiler buffers/flags. */
{
 int i=0;

  if((long)get_c_size() != TOPLEV_COMP)    /* Must be start of this level. */
     return(NULL);

     get_strlist(C_DefSym);
     get_strlist(C_UnDefSym);
     get_strlist(C_IDirList);
     get_strlist(C_QuadDev);
/*   get_strlist(C_WorkList); */
     get_strlist(C_Debug);

 while(i < 4) {
    if(i != 2)
       C_GadBN[i] = (int)get_s_size();
       i++;
     }

 if((long)get_c_size() != ENDOF_COMP)    /* Must be end of this level. */
     return(NULL);

return(1);
}

void dump_Ostuff()        /* Optimizer. */
{
 WORD i=0;

   put_c_size(TOPLEV_OPT);

   while(i < 8) {         /* Flags Only. */
       put_s_size(O_GadBN[i]);
       i++;
       }

   put_c_size(ENDOF_OPT);
}

int read_Ostuff()
{
 WORD i=0;

  if((long)get_c_size() != TOPLEV_OPT)
     return(NULL);

 while(i < 8) {          /* Flags Only. */
       O_GadBN[i] = (int)get_s_size();
       i++;
     }

 if((long)get_c_size() != ENDOF_OPT)
     return(NULL);

return(1);
}

void dump_Astuff()  /* Assembler. */
{
 WORD i=0;
     put_c_size(TOPLEV_ASM);

     put_strlist(A_IncHeader);
     put_strlist(A_IDirList);
     put_strlist(A_CListFile);
     put_strlist(A_OutPath);
     put_strlist(A_Debug);

 while(i < 5) {
       put_s_size(A_GadBN[i]);
       i++;
     }

     put_c_size(ENDOF_ASM);
}

int read_Astuff()
{
 WORD i=0;
  if((long)get_c_size() != TOPLEV_ASM)
     return(NULL);

     get_strlist(A_IncHeader);
     get_strlist(A_IDirList);
     get_strlist(A_CListFile);
     get_strlist(A_OutPath);
     get_strlist(A_Debug);

 while(i < 5) {
       A_GadBN[i] = (int)get_s_size();
       i++;
     }

  if((long)get_c_size() != ENDOF_ASM)
     return(NULL);
}

void dump_Lstuff()  /* Linker. */
{
 WORD i=0;
     put_c_size(TOPLEV_LINK);

     put_strlist(L_StartOBJ);
/*   put_strlist(L_LinkList); ** has own option ** */
     put_strlist(L_MathLib);
     put_strlist(L_Libs);
/*   put_strlist(L_OutName);  ** has own option ** */

 while(i < 5) {
      if(i != 3) /* 3=Link.(from) */
         put_s_size(L_GadBN[i]);
       i++;
     }

     put_c_size(ENDOF_LINK);
}

int read_Lstuff()
{
  WORD i=0;
  if((long)get_c_size() != TOPLEV_LINK)
     return(NULL);

     get_strlist(L_StartOBJ);
/*   get_strlist(L_LinkList);  ** has own option ** */
     get_strlist(L_MathLib);
     get_strlist(L_Libs);
/*   get_strlist(L_OutName);   ** has own option ** */

  while(i < 5) {
      if(i != 3)
         L_GadBN[i] = (int)get_s_size();
       i++;
     }

  if((long)get_c_size() != ENDOF_LINK)
     return(NULL);
}

void dump_Other()   /* Any stuff. */
{
 WORD i=0;
    put_c_size(TOPLEV_OTH);
    put_s_size(c_sensitive);
    put_s_size(P_GadBN[1]); /* [1]. tab_stop */

  while(i < 8) {    /* palette. */
    put_c_size((long)pref_c[i].red);
    put_c_size((long)pref_c[i].green);
    put_c_size((long)pref_c[i].blue);
    i++;
    }
    put_c_size((long)penshop[CON_PEN]);    /* [0]. Con win pen colour. */
    put_c_size((long)penshop[CON_PAPER]);  /* [1]. paper. */
    put_c_size((long)penshop[CON_MARKER]); /* [2]. mark. */

    put_c_size(ENDOF_OTH);
}

int read_Other()
{
 WORD i=0;
  if((long)get_c_size() != TOPLEV_OTH)
     return(NULL);

     c_sensitive = (int)get_s_size();
     P_GadBN[1] = (WORD)get_s_size(); /* [1]. tab_stop */

  while(i < 8) {
     pref_c[i].red = (UBYTE)get_c_size();
     pref_c[i].green = (UBYTE)get_c_size();
     pref_c[i].blue = (UBYTE)get_c_size();
     i++;
     }
     penshop[CON_PEN] = (UBYTE)get_c_size();
     penshop[CON_PAPER] = (UBYTE)get_c_size();
     penshop[CON_MARKER] = (UBYTE)get_c_size();

  if((long)get_c_size() != ENDOF_OTH)
     return(NULL);
}

/******** FROM HERE = ACTUAL CONFIG READ/WRITE FUNCTINS (binary) *********/

static void put_l_size(val)             /* Write long val. */
long val;
{
 fwrite(&val, sizeof(long), 1, io_fp);
}

static long get_l_size()                /* Read long val. */
{
 long val;
 fread(&val, sizeof(long), 1, io_fp);
 return(val);
}

static void put_s_size(val)             /* Write short. */
short val;
{
 fwrite(&val, sizeof(short), 1, io_fp);
}

static short get_s_size()               /* Read short. */
{
 short val;
 fread(&val, sizeof(short), 1, io_fp);
 return(val);
}

static void put_c_size(val)             /* Write char. */
long val;
{
 char data = val;
 fwrite(&data, sizeof(char), 1, io_fp);
}

static long get_c_size()                /* Read char. */
{
 char data;
 fread(&data, sizeof(char), 1, io_fp);
 return((long)data);
}

static void put_strlist(s)              /* Write string. */
char *s;
{
    long count;

    if (s == NULL)
        put_s_size(0);
    else {
        count = strlen(s) + 1;
        put_s_size(count);
        fwrite(s, sizeof(char), count, io_fp);
    }
}

static int get_strlist(to)             /* Read string. */
char *to;
{
    long count;

    count = get_s_size();
    if (count == 0)
        return (NULL);
    else {
        fread(to, sizeof(char), count, io_fp);
        return (1);
    }
}

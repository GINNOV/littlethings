/*
 * myupdate.c
 * (C) 1986 Software Solution, all rights reserved
 */

/* Myupdate is patterned after the Commodore update command. It takes as
 * its arguments a source directory and a destination directory. By default
 * it acts just like the update command, if the file exists in both the
 * source and destination directories, the file from the source directory is
 * copied to the destination directory. The program does not pay attention
 * to file dates. If the -c flag is used, the program will copy all files
 * from the source directory to the destination directory without checking
 * to see if the file exists in the destination directory. If the -s flag
 * is specified the files in the source directory are stripped of excess
 * whitespace as they are copied to the destination directory. Files in the
 * source directory are unmodified. This option is intended for use when
 * updating the include header files in a C development disk. The -i flag
 * is used to have the program inquire before updating each file. The -v
 * flag is the verbose flag and causes the program to print out the name
 * of each file as it's processed.
 *
 * Bug reports or suggestions should be sent to:
 *    The Software Solution
 *    16850 S.W. Timberland Dr.
 *    Aloha, Oregon 97007
 */

#include <stdio.h>
#include "libraries/dos.h"
#include "libraries/dosextens.h"
#include "exec/memory.h"

extern struct FileLock *Lock(), *CurrentDir(), *CreateDir();
extern struct FileHandle *Open();

void update(), do_update(), strip(), copy();

struct FileLock *src_dir_lock;  /* Lock on source dir    */
struct FileLock *dst_dir_lock;  /* Lock on destination dir  */

int s_flag = 0;   /* strip files of comments and excess white space */
int c_flag = 0;   /* create files if they don't exist in dest dir */
int i_flag = 0;   /* inquire for each file before action is taken */
int v_flag = 0;   /* verbose mode */

struct file_info {
   struct FileHandle *fh;
   unsigned char  buf[BUFSIZ];
   unsigned char *bp, *endp;
   int mode;
};     /* input and output file information */

struct file_info *myopen();
void myclose();

char *myname;     /* name by which this command has been called i.e."myupdate" */
main(argc, argv)
   int argc;
   char *argv[];
{
   int i, j;
   char *srcdir, *dstdir;  /* source and destination directory names */
   struct InfoData *src_id, *dst_id;
   struct FileLock *startlock; /* lock on the current directory      */

   myname = argv[0];

   if(argc < 3) {
      goto usage;
   }

   /* parse the arguments, and get source and destination directory */
   i = 1;
   while (i < (argc - 2)) {   /* last two arguments are src and dst dirs */
      if (argv[i][0] == '-') {   /* option */
         j = 1;               /* start past the "-" character */
         while (argv[i][j]) {
            switch (argv[i][j++]) {
               case 'c':
               case 'C':
                  c_flag++;   /* copy all files */
                  break;
               case 's':
               case 'S':
                  s_flag++;   /* strip whitespace */
                  break;
               case 'v':
               case 'V':
                  v_flag++;   /* verbose mode */
                  break;
               case 'i':
               case 'I':
                  i_flag++;   /* inquire first */
                  break;
               default:
                  goto usage;
            }
         }
      } else { /* screw up */
         goto usage;
      }
      i++;
   }

   srcdir = argv[i];
   dstdir = argv[i+1];

   /* Get a lock on the source directory */
   src_dir_lock = Lock(srcdir,ACCESS_READ);
   dst_dir_lock = Lock(dstdir,ACCESS_WRITE);

   if (src_dir_lock == NULL) {
      fprintf(stderr,"%s: unable to lock %s\n",myname,srcdir);
      exit(1);
   }

   if (dst_dir_lock == NULL) {
      fprintf(stderr,"%s: unable to lock %s\n",myname,dstdir);
      UnLock(src_dir_lock);
      exit(1);
   }

   /* Move into source directory and save current directory for later */
   startlock = CurrentDir(src_dir_lock);

   /* InfoData MUST BE LONGWORD ALIGNED, so allocate it     */
   src_id = (struct InfoData *)AllocMem(sizeof(struct InfoData),MEMF_CLEAR);
   dst_id = (struct InfoData *)AllocMem(sizeof(struct InfoData),MEMF_CLEAR);

   if (src_id != NULL) {
      /* Get info to see if disk is write protected */
      if (Info(src_dir_lock, src_id)) {
         if (src_id->id_DiskType == ID_NO_DISK_PRESENT || src_id->id_DiskType == ID_UNREADABLE_DISK) {
            fprintf(stderr,"%s: unable to access %s\n",myname,srcdir);
            UnLock(src_dir_lock);
            UnLock(dst_dir_lock);
            dst_dir_lock = CurrentDir(startlock);
            FreeMem(src_id, sizeof(struct InfoData));
            if (dst_id != NULL) {
               FreeMem(dst_id, sizeof(struct InfoData));
            }
            exit(1);
         }
      } else {
         fprintf(stderr,"%s: unable to get info about %s\n",myname,srcdir);
         UnLock(src_dir_lock);
         UnLock(dst_dir_lock);
         dst_dir_lock = CurrentDir(startlock);
         FreeMem(src_id, sizeof(struct InfoData));
         if (dst_id != NULL) {
            FreeMem(dst_id, sizeof(struct InfoData));
         }
         exit(1);
      }
   } else {
      fprintf(stderr,"%s: unable to allocate memory for diskinfo\n",myname);
      UnLock(src_dir_lock);
      UnLock(dst_dir_lock);
      dst_dir_lock = CurrentDir(startlock);
      FreeMem(src_id, sizeof(struct InfoData));
      if (dst_id != NULL) {
         FreeMem(dst_id, sizeof(struct InfoData));
      }
      exit (1);
   }

   if (dst_id != NULL) {
      if (Info(dst_dir_lock, dst_id)) {
         if(dst_id->id_DiskState == ID_WRITE_PROTECTED) {
            fprintf(stderr,"%s: %s is write protected\n",myname,dstdir);
            UnLock(src_dir_lock);
            UnLock(dst_dir_lock);
            dst_dir_lock = CurrentDir(startlock);
            FreeMem(src_id, sizeof(struct InfoData));
            FreeMem(dst_id, sizeof(struct InfoData));
            exit(1);
         }
      } else {
         fprintf(stderr,"%s: unable to get info about %s\n",myname,dstdir);
         UnLock(src_dir_lock);
         UnLock(dst_dir_lock);
         dst_dir_lock = CurrentDir(startlock);
         FreeMem(src_id, sizeof(struct InfoData));
         FreeMem(dst_id, sizeof(struct InfoData));
         exit(1);
      }
   } else {
      fprintf(stderr,"%s: unable to allocate memory for diskinfo\n",myname);
      UnLock(src_dir_lock);
      UnLock(dst_dir_lock);
      dst_dir_lock = CurrentDir(startlock);
      FreeMem(src_id, sizeof(struct InfoData));
      exit (1);
   }

   update(src_dir_lock, dst_dir_lock);    /* do the actual work */

   UnLock(src_dir_lock);
   UnLock(dst_dir_lock);

   /* put current directory back to where it was */
   dst_dir_lock = CurrentDir(startlock);

   FreeMem(src_id, sizeof(struct InfoData));
   FreeMem(dst_id, sizeof(struct InfoData));
   exit (0);

usage:
   fprintf(stderr,"%s: usage %s [-c] [-i] [-s] [-v] source destination\n", argv[0], argv[0]);
   exit (1);
}

void
update(sl, dl)
register struct FileLock *sl;
register struct FileLock *dl;  /* source and destination file locks */
{
   register struct FileInfoBlock *fib;
   register struct FileLock *nsl, *ndl;   /* new source and destination locks for subdirectories */

   fib = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock),MEMF_CLEAR);
   if (fib == NULL) {
      fprintf(stderr,"%s: unable to allocate space for fileinfo block\n",myname);
      return;
   }
   if (Examine(sl,fib)) {  /* take a look at the source directory */
      while (ExNext(sl, fib)) { /* found a file or directory */
         if (fib->fib_DirEntryType > 0) { /* found a subdirectory */
            nsl = Lock(fib->fib_FileName, ACCESS_READ);
            if (nsl == NULL) {
               fprintf(stderr,"%s: unable to lock %s\n", myname, fib->fib_FileName);
               continue;
            }
            CurrentDir(dl);               /* change dirs to destination */
            ndl = Lock(fib->fib_FileName, ACCESS_WRITE);
            if (ndl == 0) {
               ndl = CreateDir(fib->fib_FileName);
            }
            if (v_flag)
               fprintf(stdout,"Changing directories to %s\n", fib->fib_FileName);
            CurrentDir(nsl);
            if (ndl)
               update(nsl, ndl);          /* recurse */
            CurrentDir(sl);               /* change back to original source lock */
            UnLock(nsl);
            if (ndl) {
               UnLock(ndl);
            } else
               fprintf(stderr,"%s: unable to create %s\n", myname, fib->fib_FileName);
         } else {          /* normal file */
            if (c_flag || exists(dl,fib->fib_FileName))
               do_update(sl,dl,fib->fib_FileName);
         }
      }
      FreeMem(fib, sizeof(struct FileInfoBlock));
      return;
   }
}

/*
 * exists returns nonzero if file named fn exists in directory locked by dl
 */
exists(dl, fn)
struct FileLock *dl;
char *fn;
{
struct FileLock *ol, *tl;
int retval;

   ol = CurrentDir(dl);
   tl = Lock(fn, ACCESS_READ);
   if (tl)
      retval = 1;
   else
      retval = 0;
   if (tl) {
      UnLock(tl);
   }
   CurrentDir(ol);         /* change back directory */
   return retval;
}

void
do_update (sl,dl,fn)
struct FileLock *sl, *dl;  /* source and destination file locks */
char *fn;                  /* name of file in question */
{
int c;
struct file_info *ifi, *ofi;
struct FileLock *ofl;

   if (i_flag) {
      fprintf(stdout,"Update %s? (y/n)...", fn);
      c = getchar();
      if (c != 'y' && c != 'Y')
         return;
   }
   if (v_flag) {
      fprintf(stdout,"        %s\n",fn);
   }
   ofl = CurrentDir(sl);
   ifi = myopen(fn, MODE_OLDFILE);
   if (ifi == NULL) {
      fprintf(stderr, "%s: unable to open %s for reading\n", myname, fn);
      CurrentDir(ofl);
      return;
   }
   CurrentDir(dl);
   ofi = myopen(fn, MODE_NEWFILE);
   if (ofi == NULL) {
      fprintf(stderr, "%s: unable to open %s for writing\n", myname, fn);
      myclose(ifi);
      CurrentDir(ofl);
      return;
   }
   if (s_flag)
      strip(ifi, ofi);
   else
      copy(ifi, ofi);
   myclose(ifi);
   myclose(ofi);
}

void
strip(ifi, ofi)
register struct file_info *ifi, *ofi;
{
register int c, in_comment, doing_white, non_white_found;

   in_comment = 0;
   doing_white = 0;
   non_white_found = 0;
   while ((c = mygetc(ifi)) != EOF) {
      if (in_comment) {
chk_com: if (c == '*') {
            c = mygetc(ifi);
            if (c == '/') {
               in_comment = 0;
               if (!doing_white) {
                  /* convert comment to one white space */
                  if (myputc(' ', ofi) == EOF) {
                     return;
                  }
                  doing_white = 1;
               }
               continue;
            } else
               goto chk_com;
         }
         else
            continue;
      }
      if (c == '/') {
         c = mygetc(ifi);
         if (c == '*') {
            in_comment = 1;
            continue;
         }
         if(myputc('/', ofi) == EOF) {
            return;
         }
         if (c == EOF)
            break;
      }
      if (isspace(c)) {
         if (c == '\n') {
            if (non_white_found)
               if (myputc('\n', ofi) == EOF) {
                  return;
               }
            doing_white = 1;
            non_white_found = 0;
            continue;
         }
         if (doing_white)
            continue;
         else {
            /* colapse white space to single char */
            if (myputc(' ', ofi) == EOF) {
               return;
            }
            doing_white = 1;
            continue;
         }
      }
      else {
         doing_white = 0;
         non_white_found = 1;
      }
      if (myputc(c, ofi) == EOF) {
         return;
      }
   }
}

void
copy(ifi, ofi)
register struct file_info *ifi, *ofi;
{
register int c;

   while ((c = mygetc(ifi)) != EOF) {
      if (myputc(c,ofi) == EOF) {
         fprintf(stderr,"%s: file I/O error\n", myname);
         return;
      }
   }
}

struct file_info *
myopen(name,mode)
char *name;
int mode;
{
   register struct file_info *fi;

   fi = (struct file_info *)AllocMem(sizeof(struct file_info),MEMF_CLEAR);
   if (fi == NULL)
      return NULL;

   fi->fh = Open(name,mode);
   if (fi->fh == 0) {
      FreeMem(fi, sizeof(struct file_info));
      return NULL;
   }
   fi->mode = mode;
   fi->bp = fi->buf;
   fi->endp = fi->buf;
   return fi;
}

void
myclose(fi)
register struct file_info *fi;
{
   if (fi->mode == MODE_NEWFILE) {  /* open for writing? */
      if (fi->bp > fi->buf)         /* flush any buffers */
         Write(fi->fh, fi->buf, fi->bp - fi->buf);
   }
   Close(fi->fh);
   FreeMem(fi, sizeof(struct file_info));
}

int
mygetc(fi)
register struct file_info *fi;
{
   int actual;

   if (fi->bp >= fi->endp) {
      actual = Read(fi->fh, fi->buf, BUFSIZ);
      fi->bp = fi->buf;
      fi->endp = fi->buf + actual;
      if (actual == 0)
         return EOF;
      if (actual > 0)
         return ((int)*fi->bp++);
      else {
         fprintf(stderr,"%s: input error %d\n", myname, IoErr());
         return EOF;
      }
   }
   return ((int)*fi->bp++);
}

int
myputc(c, fi)
int c;
register struct file_info *fi;
{
   int actual;

   *(fi->bp++) = c;
   if (fi->bp >= fi->buf + BUFSIZ) {
      actual = Write(fi->fh, fi->buf,BUFSIZ);
      fi->bp = fi->buf;
   }
   if (actual < BUFSIZ) {
      if (actual == -1)
         fprintf(stderr,"%s: output error %d\n", myname, IoErr());
      else
         fprintf(stderr,"%s: short write, actual = %d, error %d\n", myname, actual, IoErr());
      return EOF;
   } else
      return c;
}

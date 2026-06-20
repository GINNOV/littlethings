/* $Revision Header *** Header built automatically - do not edit! ***********
 *
 *	(C) Copyright 1991 by Torsten Jürgeleit
 *
 *	Name .....: bumprev.c
 *	Created ..: Thursday 18-Dec-91 15:55:48
 *	Revision .: 0
 *
 *	Date        Author                 Comment
 *	=========   ====================   ====================
 *	18-Dec-91   Torsten Jürgeleit      Created this file!
 *
 ****************************************************************************
 *
 * 	This program is a completely rewritten version of DoRevision
 *	(Fish 325) from	Olaf Barthel.
 *
 * Differences to DoRevision:
 *
 *	It now can be used for assembler source files too, because BumpRev
 *	examines the file extension ('.c' or '.h' for C sources and '.asm'
 *	or '.i' for assembler sources).
 *	The size of the executable was reduced to 3.7 kb, but now the
 *	program is NOT portable anymore - it uses the ARP library and only
 *	three functions from c.lib (strrchr, strcpy and strlen).
 *	In this version the current day, date and time strings are
 *	generated with the function StampToStr from ARP library and so it
 *	does not require DClock.
 *
 * $Revision Header ********************************************************/

	/* Includes */

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/arpbase.h>
#include <functions.h>
#include <string.h>

	/* Defines */

#define MAX_READ_BUFFER_SIZE	2000
#define MAX_LINE_BUFFER_SIZE	300
#define MAX_FILE_NAME_LEN	108
#define MAX_AUTHOR_NAME_LEN	20
#define MAX_COMPANY_NAME_LEN	20
#define MAX_ARGUMENTS		2

#define ARGUMENT_FILE_NAME	0
#define ARGUMENT_COMMENT	1

#define TEMP_FILE_NAME		"T:Revision.temp"

#define FILE_TYPE_INVALID	0
#define FILE_TYPE_C		1
#define FILE_TYPE_ASM		2

#define ENV_DIR_NAME		"ENV:"

#define ENV_AUTHOR		"AUTHOR"
#define ENV_COMPANY		"COMPANY"

#define DEFAULT_AUTHOR		"- Unknown -"
#define DEFAULT_COMPANY		"???"

#define FILE_STATUS_NORMAL	0
#define FILE_STATUS_EOF		1

#define FILE_ERROR_LINE_TOO_LONG	-1
#define FILE_ERROR_READ_FAILED		-2
#define FILE_ERROR_WRITE_FAILED		-3

#define REVISION_HEADER_ID_START	3
#define REVISION_HEADER_ID		"$Revision Header"
#define REVISION_HEADER_ID_LEN		16

#define REVISION_COUNT_START		15

#define REVISION_DATE_START		3
#define REVISION_DATE_LEN		9

#define DEFAULT_COMMENT		"- Empty log message -"
#define FIRST_COMMENT		"Created this file!"

#define LINE_NUM_REVISION_COUNT		7
#define LINE_NUM_LAST_REVISION		11

	/* Structures */

struct RevisionData {
	BYTE	*rd_Comment;
	LONG	rd_FileProtection;	/* protection bits */
	USHORT	rd_FileType;
	BYTE	rd_FileName[MAX_FILE_NAME_LEN + 1];	/* real file name */
	BYTE	rd_Author[MAX_AUTHOR_NAME_LEN + 1];
	BYTE	rd_Company[MAX_COMPANY_NAME_LEN + 1];
	BYTE	rd_Day[LEN_DATSTRING];		/* needed for StampToStr() */
	BYTE	rd_Date[LEN_DATSTRING];		/* needed for StampToStr() */
	BYTE	rd_Time[LEN_DATSTRING];		/* needed for StampToStr() */
};
struct FileData {
	BPTR	fd_FileHandle;
	BYTE	*fd_ReadBuffer;
	BYTE	*fd_CurrentPtr;
	BYTE	*fd_EndPtr;
	BYTE	*fd_LineBuffer;
	USHORT	fd_LineLen;
	USHORT	fd_LineNum;
};
	/* Externals */

IMPORT struct DOSBase   *DOSBase;

	/* Globals */

struct ArpBase	*ArpBase;

BYTE template[]  = "File/a,Comment",
     xtra_help[] = "Usage: BumpRev <file> [comment]\n"
		   "\t<file>    = name of source file\n"
		   "\t[comment] = comment string for new revision";

	/* Static prototypes */

BOOL  revise_file(BYTE *name, BYTE *comment);
struct RevisionData  *get_revision_data(BYTE *name, BYTE *comment);
SHORT get_revision_env(BYTE *name, BYTE *buffer, USHORT buffer_size);
struct FileData  *open_file(BYTE *name, LONG mode);
SHORT read_line(struct FileData  *fd);
SHORT fill_read_buffer(struct FileData  *fd);
VOID  close_file(struct FileData  *fd);
BOOL  create_revision_header(struct RevisionData  *rd, BPTR fh);
BOOL  change_revision_header(struct RevisionData  *rd,
				    struct FileData  *rev_fd, BPTR temp_fh);
BOOL  append_rest_of_file(struct FileData  *rev_fd, BPTR temp_fh);
BOOL  copy_file(BPTR src_fh, BPTR dst_fh, BYTE *read_buffer);

	/* Static pragmas */

#pragma regcall(revise_file(a0,a1))
#pragma regcall(get_revision_data(a0,a1))
#pragma regcall(get_revision_env(a0,a1,d0))
#pragma regcall(open_file(a0,d0))
#pragma regcall(read_line(a0))
#pragma regcall(fill_read_buffer(a0))
#pragma regcall(close_file(a0))
#pragma regcall(create_revision_header(a0,a1))
#pragma regcall(change_revision_header(a0,a1,a2))
#pragma regcall(append_rest_of_file(a0,a1))
#pragma regcall(copy_file(a0,a1,a2))

	/* Main routine - no startup code */

   LONG
_main(LONG alen, BYTE *aptr)
{
   LONG return_code = RETURN_FAIL;

   /* First open ARP library */
   if (!(ArpBase = OpenLibrary(ArpName, ArpVersion))) {
      Write(Output(), "Need ARP library V39+\n", 22L);
   } else {
      BYTE   *argv[MAX_ARGUMENTS];
      LONG   count;
      USHORT i;

      /* Clear argument array */
      for (i = 0; i < MAX_ARGUMENTS; i++) {
	 argv[i] = NULL;
      }

      /* Parse command line arguments */
      if ((count = GADS(aptr, alen, &xtra_help[0], &argv[0],
						       &template[0])) < 0) {
	 Puts(argv[0]);
      } else {
	 if (!count) {
	    Puts(&xtra_help[0]);
	 } else {

	    /* Call revise function with file name and comment */
	    if (revise_file(argv[ARGUMENT_FILE_NAME],
					  argv[ARGUMENT_COMMENT]) == TRUE) {
	       return_code = RETURN_OK;
	    }
	 }
      }
      CloseLibrary(ArpBase);
   }

   /* MANX crt0.asm forget to close DOS library, so we have to do it */
   CloseLibrary(DOSBase);
   return(return_code);
}
	/* Revise given file */

   BOOL
revise_file(BYTE *name, BYTE *comment)
{
   struct RevisionData  *rd;
   struct FileData      *rev_fd;
   BPTR temp_fh;
   BOOL success = FALSE;

   /* If no comment then use default one */
   if (!comment) {
      comment = DEFAULT_COMMENT;
   }

   /* Get data needed for revision change and open files */
   if (rd = get_revision_data(name, comment)) {
      if (rev_fd = open_file(name, (LONG)MODE_READWRITE)) {
	 if (temp_fh = Open(TEMP_FILE_NAME, (LONG)MODE_NEWFILE)) {

	    /* Read first line of file and check for revision header */
	    if (read_line(rev_fd) == FILE_STATUS_NORMAL) {
	       if (rev_fd->fd_LineLen > REVISION_HEADER_ID_START &&
		   Strncmp(rev_fd->fd_LineBuffer + REVISION_HEADER_ID_START,
			REVISION_HEADER_ID, (LONG)REVISION_HEADER_ID_LEN)) {
		  if ((success = create_revision_header(rd, temp_fh)) ==
								     TRUE) {
		     /* Append line already read */
		     if (FPrintf(temp_fh, "%s\n", rev_fd->fd_LineBuffer) <
									0) {
			success = FALSE;
		     }
		  }
	       } else {
		  success = change_revision_header(rd, rev_fd, temp_fh);
	       }
	       if (success == TRUE) {

		  /* Copy rest of revision file to temp file */
		  if ((success = append_rest_of_file(rev_fd, temp_fh)) ==
								     TRUE) {
		     BPTR rev_fh = rev_fd->fd_FileHandle;

		     /* Copy revised temp file over original file */
		     if (Seek(rev_fh, 0L, (LONG)OFFSET_BEGINNING) == -1L ||
			 Seek(temp_fh, 0L, (LONG)OFFSET_BEGINNING) == -1L) {
			success = FALSE;
		     } else {
			success = copy_file(temp_fh, rev_fh,
						     rev_fd->fd_ReadBuffer);
		     }
		  }
	       }
	    }
	    Close(temp_fh);
	    DeleteFile(TEMP_FILE_NAME);
	 }
	 close_file(rev_fd);
	 if (success == TRUE) {

	    /* Set archive bit to mark file as revised */
	    SetProtection(name, rd->rd_FileProtection | FIBF_ARCHIVE);
	 }
      }
      FreeMem(rd, (LONG)sizeof(struct RevisionData));
   }
   return(success);
}
	/* Prepare structure with data needed for revision change */

   struct RevisionData  *
get_revision_data(BYTE *name, BYTE *comment)
{
   struct RevisionData  *rd = NULL;
   BYTE   *ptr;
   USHORT type;

   /* First get type of given file */
   if (ptr = strrchr(name, '.')) {
      if (!Strcmp(ptr, ".c") || !Strcmp(ptr, ".h")) {
	 type = FILE_TYPE_C;
      } else {
	 if (!Strcmp(ptr, ".asm") || !Strcmp(ptr, ".i")) {
	    type = FILE_TYPE_ASM;
	 } else {
	    type = FILE_TYPE_INVALID;
	 }
      }
      if (type != FILE_TYPE_INVALID) {
	 struct FileInfoBlock  *fib;
	 struct DateTime       dat;
	 struct DateStamp      *ds = &dat.dat_Stamp;
	 BPTR lock;

	 /* Get actual date and time into DateStamp and make range check */
	 DateStamp(ds);
	 if (ds->ds_Days <= 36500 && ds->ds_Minute <= 60 * 24 &&
						   ds->ds_Tick <= 50 * 60) {
	    /* Try to lock and examine selected file */
	    if (lock = Lock (name, (LONG)SHARED_LOCK)) {
	       if (fib = AllocMem((LONG)sizeof(struct FileInfoBlock),
						       (LONG)MEMF_PUBLIC)) {
		  if (Examine(lock, fib) != DOSFALSE) {
		     if (rd = AllocMem((LONG)sizeof(struct RevisionData),
					  (LONG)MEMF_PUBLIC | MEMF_CLEAR)) {
			/* Init revision data */
			rd->rd_Comment        = comment;
			rd->rd_FileProtection = fib->fib_Protection;
			rd->rd_FileType       = type;
			strcpy(&rd->rd_FileName[0], &fib->fib_FileName[0]);

			/* Get author and company name from environment variables */
			if (get_revision_env(ENV_AUTHOR, &rd->rd_Author[0],
						 MAX_AUTHOR_NAME_LEN) < 0) {
			   strcpy(&rd->rd_Author[0], DEFAULT_AUTHOR);
			}
			if (get_revision_env(ENV_COMPANY, &rd->rd_Company[0],
						MAX_COMPANY_NAME_LEN) < 0) {
			   strcpy(&rd->rd_Company[0], DEFAULT_COMPANY);
			}

			/* Convert DateStamp to strings in revision data */
			dat.dat_Format  = FORMAT_DOS;
			dat.dat_Flags   = 0;
			dat.dat_StrDay  = &rd->rd_Day[0];
			dat.dat_StrDate = &rd->rd_Date[0];
			dat.dat_StrTime = &rd->rd_Time[0];
			rd->rd_Time[8]  = '\0';   /* NULL terminate time string */
			StamptoStr(&dat);
		     }
		  }
		  FreeMem(fib, (LONG)sizeof(struct FileInfoBlock));
	       }
	       UnLock(lock);
	    }
	 }
      }
   }
   return(rd);
}
	/* Copy value of environment variable to given buffer */

   SHORT
get_revision_env(BYTE *name, BYTE *buffer, USHORT buffer_size)
{
   BPTR  lock, fh;
   SHORT len = -1;

   /* Change current directory to 'ENV:' */
   if (lock = Lock(ENV_DIR_NAME, (LONG)SHARED_LOCK)) {
      lock = CurrentDir(lock);

      /* Open and read env file */
      if (fh = Open(name, (LONG)MODE_OLDFILE)) {
	 if ((len = Read(fh, buffer, (LONG)buffer_size)) >= 0) {
	    *(buffer + len) = '\0';
	 }
	 Close(fh);
      }
      lock = CurrentDir(lock);
      UnLock(lock);
   }
   return(len);
}
	/* Open text file for buffered input */

   struct FileData *
open_file(BYTE *name, LONG mode)
{
   struct FileData  *fd = NULL;
   BPTR fh;

   if (fh = Open(name, mode)) {
      if (!(fd = AllocMem((LONG)(sizeof(struct FileData) +
			   MAX_READ_BUFFER_SIZE + MAX_LINE_BUFFER_SIZE + 1),
						      (LONG)MEMF_PUBLIC))) {
	 Close(fh);
      } else {

	 /* Init file data */
	 fd->fd_FileHandle = fh;
	 fd->fd_ReadBuffer = (BYTE *)(fd + 1);
	 fd->fd_CurrentPtr = NULL;
	 fd->fd_LineBuffer = fd->fd_ReadBuffer + MAX_READ_BUFFER_SIZE;
	 fd->fd_LineLen    = 0;
	 fd->fd_LineNum    = 0;
      }
   }
   return(fd);
}
	/* Read line from read buffer */

   SHORT
read_line(struct FileData  *fd)
{
   BYTE   c, *ptr, *line = fd->fd_LineBuffer;
   USHORT len = 0;
   SHORT  status = FILE_STATUS_NORMAL;

   /* Fill read buffer if necessary */
   if (!(ptr = fd->fd_CurrentPtr) || ptr >= fd->fd_EndPtr) {
      if ((status = fill_read_buffer(fd)) == FILE_STATUS_NORMAL) {
	 ptr = fd->fd_CurrentPtr;
      }
   }
   if (status == FILE_STATUS_NORMAL) {

      /* Copy line to buffer */
      while ((c = *ptr) != '\n') {

	 /* Write char to line buffer */
	 if (len >= MAX_LINE_BUFFER_SIZE) {
	    status = FILE_ERROR_LINE_TOO_LONG;
	    break;
	 } else {
	    *line++ = c;
	    len++;

	    /* Increment ptr and fill read buffer if neccessary */
	    if (++ptr == fd->fd_EndPtr) {
	       if ((status = fill_read_buffer(fd)) != FILE_STATUS_NORMAL) {
		  break;
	       } else {
		  ptr = fd->fd_CurrentPtr;
	       }
	    }
	 }
      }
      if (status == FILE_STATUS_NORMAL) {

	 /* Mark end of string */
	 *line             = '\0';
	 fd->fd_CurrentPtr = ptr + 1;   /* skip trailing '\n' */
	 fd->fd_LineLen    = len;
	 fd->fd_LineNum++;
      }
   }
   return(status);
}
	/* Fill read buffer from text file */

   SHORT
fill_read_buffer(struct FileData  *fd)
{
   LONG  len;
   SHORT status;

   if ((len = Read(fd->fd_FileHandle, fd->fd_ReadBuffer,
				      (LONG)MAX_READ_BUFFER_SIZE)) == -1L) {
      status = FILE_ERROR_READ_FAILED;
   } else {
      if (!len) {
	 status = FILE_STATUS_EOF;
      } else {
	 fd->fd_CurrentPtr = fd->fd_ReadBuffer;
	 fd->fd_EndPtr     = fd->fd_ReadBuffer + len;
	 status            = FILE_STATUS_NORMAL;
      }
   }
   return(status);
}
	/* Close text file and free read buffer */

   VOID
close_file(struct FileData  *fd)
{
   Close(fd->fd_FileHandle);
   FreeMem(fd, (LONG)(sizeof(struct FileData) + MAX_READ_BUFFER_SIZE +
						 MAX_LINE_BUFFER_SIZE + 1));
}
	/* Create new revision header */

   BOOL
create_revision_header(struct RevisionData  *rd, BPTR fh)
{
   BYTE c;
   BOOL success = FALSE;

   /* Get comment indicator depending on file type */
   if (rd->rd_FileType == FILE_TYPE_C) {
      c = '/';
   } else {
      c = ' ';
   }

   /* Insert revision header */
   if (FPrintf(fh, "%c* $Revision Header *** Header built automatically -"
				    " do not edit! ***********\n", c) > 0 &&
	FPrintf(fh, " *\n *\t(C) Copyright 19%s by %s\n *\n",
				 &rd->rd_Date[7], &rd->rd_Company[0]) > 0 &&
	FPrintf(fh, " *\tName .....: %s\n", &rd->rd_FileName[0]) > 0 &&
	FPrintf(fh, " *\tCreated ..: %s %s %s\n", &rd->rd_Day[0],
				    &rd->rd_Date[0], &rd->rd_Time[0]) > 0 &&
	FPrintf(fh, " *\tRevision .: 0\n *\n") > 0 &&
	FPrintf(fh, " *\tDate        Author                 "
							 "Comment\n") > 0 &&
	FPrintf(fh, " *\t=========   ===================="
					 "   ====================\n") > 0 &&
	FPrintf(fh, " *\t%s   %-20s   %s\n *\n", &rd->rd_Date[0],
				    &rd->rd_Author[0], FIRST_COMMENT) > 0 &&
	FPrintf(fh, " * $Revision Header **********************************"
					    "**********************") > 0) {
      /* Append comment end char and define or equate with revision num */
      if (rd->rd_FileType == FILE_TYPE_C) {
	 if (FPrintf(fh, "/\n#define REVISION\t0\n\n") > 0) {
	    success = TRUE;
	 }
      } else {
	 if (FPrintf(fh, "\nREVISION\tEQU\t0\n\n") > 0) {
	    success = TRUE;
	 }
      }
   }
   return(success);
}
	/* Change existing revision header */

   BOOL
change_revision_header(struct RevisionData  *rd, struct FileData  *rev_fd,
							       BPTR temp_fh)
{
   BYTE  *line = rev_fd->fd_LineBuffer;
   LONG  revision;
   SHORT status;
   BOOL  leave = FALSE, end = FALSE, success = TRUE;

   /* First write line read before */
   if (FPrintf(temp_fh, "%s\n", line) < 0) {
      status = FILE_ERROR_WRITE_FAILED;
   } else {

      /* Copy rest of header lines */
      while (leave == FALSE && (status = read_line(rev_fd)) ==
						       FILE_STATUS_NORMAL) {
	 USHORT len = rev_fd->fd_LineLen, num = rev_fd->fd_LineNum;

	 switch (num) {
	    case LINE_NUM_REVISION_COUNT :

	       /* Increment revision count */
	       revision = Atol(line + REVISION_COUNT_START) + 1;
	       if (IoErr()) {
		  leave = TRUE;
	       } else {
		  SPrintf(line + REVISION_COUNT_START, "%ld", revision);
	       }
	       break;

	    case LINE_NUM_LAST_REVISION :

	       /* Check date of last revision and leave if it was today */
	       if (len > REVISION_DATE_START && !Strncmp(line +
				       REVISION_DATE_START, &rd->rd_Date[0],
			(LONG)REVISION_DATE_LEN) && (rd->rd_FileProtection &
							    FIBF_ARCHIVE)) {
		  leave = TRUE;
	       } else {

		  /* Insert new revision comment line */
		  if (FPrintf(temp_fh, " *\t%s   %-20s   %s\n",
					 &rd->rd_Date[0], &rd->rd_Author[0],
						      rd->rd_Comment) < 0) {
		     leave = TRUE;
		  }
	       }
	       break;

	    default :

	       /* If end of revision header reached then leave */
	       if (end == TRUE) {
		  BYTE *text;

		  /* Check for line with define or equate */
		  if (rd->rd_FileType == FILE_TYPE_C) {
		     text = "#define REVISION\t";
		  } else {
		     text = "REVISION\tEQU\t";
		  }

		  /* If define or equate found then change revision */
		  if (!Strncmp(line, text, (LONG)strlen(text))) {
		     SPrintf(line, "%s%ld", text, revision);
		  }
		  status = FILE_STATUS_EOF;
		  leave  = TRUE;
	       } else {

		  /* Check for end of revision header */
		  if (len > REVISION_HEADER_ID_START && !Strncmp(line +
			       REVISION_HEADER_ID_START, REVISION_HEADER_ID,
					    (LONG)REVISION_HEADER_ID_LEN)) {
		     end = TRUE;
		  }
	       }
	       break;
	 }
	 if (leave == FALSE || end == TRUE) {

	    /* Write line to temp file */
	    if (FPrintf(temp_fh, "%s\n", line) < 0) {
	       status = FILE_ERROR_WRITE_FAILED;
	       leave  = TRUE;
	    }
	 }
      }
   }
   if (status != FILE_STATUS_EOF) {
      success = FALSE;
   }
   return(success);
}
	/* Copy file including rest from read buffer */

   BOOL
append_rest_of_file(struct FileData  *rev_fd, BPTR temp_fh)
{
   LONG len;
   BOOL success = TRUE;

   /* First copy contents of read buffer */
   if (len = rev_fd->fd_EndPtr - rev_fd->fd_CurrentPtr) {
      if (Write(temp_fh, rev_fd->fd_CurrentPtr, len) != len) {
	 success = FALSE;
      }
   }
   if (success == TRUE) {

      /* Copy rest of file */
      success = copy_file(rev_fd->fd_FileHandle, temp_fh,
						     rev_fd->fd_ReadBuffer);
   }
   return(success);
}
	/* Copy file */

   BOOL
copy_file(BPTR src_fh, BPTR dst_fh, BYTE *read_buffer)
{
   LONG len;
   BOOL success = TRUE;

   while ((len = Read(src_fh, read_buffer, (LONG)MAX_READ_BUFFER_SIZE)) > 0) {
      if (Write(dst_fh, read_buffer, len) != len) {
	 success = FALSE;
	 break;
      }
   }
   return(success);
}

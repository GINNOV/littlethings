/****** RecDirNext ***************************************************
*
*   NAME
*       RecDirNext -- Gets information about the next file (V10)
*       (dos V36)
*
*   SYNOPSIS
*       error = RecDirNext(RecDirInfo, RecDirFIB);
*
*       UBYTE = RecDirNext(struct RecDirInfo *, struct RecDirFIB *);
*
*   FUNCTION
*       Retrieves information about the next file in a scanning process.
*       Calling this function  will not provide a list of sorted files
*       niether by ASCII order nor by directory levels. That means
*       it will scan files as they have been stored on a disk drive.
*
*       The main advantage of using this function from using ExNext()
*       is that you don't have to program a recursive scanning routine
*       by yourself. You need only to provide lowest directory path,
*       how deep into subdirectories you want to scan, and which
*       information about files you need to be provided with.
*       RecDirNext() will only return files but no directories.
*       You are also able to select a matching pattern so that only
*       files which match it will be returned.
*
*       Please see RecDirInit() for more info.
*
*   INPUTS
*       RecDirInfo - pointer to RecDirInfo structure. You MUST call
*       RecDirInit(), providing it with this structure, before calling
*       any RecDirNext() function.
*
*       RecDirFIB - pointer to RecDirFIB structure which should be
*       previousely allocated. You only set those fields in the
*       structure that you want to have information about. Any field
*       should point to a variable into which information will be stored.
*       Check "struct RecDirFIB" to see what each field mean.
*       All field in RecDirFIB structure that are set to NULL will be
*       ignored.
*
*   RESULT
*       error - zero if no error. Otherwise one of the following:
*           DN_ERR_END - scanning is completed. You should not call
*                        any RecDirNext() again.
*           DN_ERR_EXAMINE - Failure while examining a file.
*           DN_ERR_MEM - not enough memory available to complete
*                        the operation.
*           IF any error will be resulted, RecDirFree will be called
*           internally.
*
*
*   EXAMPLE
*       This example will scan through the entire HD0: disk device, and
*       will print for each file: its dir path, its name, its size.
*
*
*   #include <stdio.h>
*   #include <stdlib.h>
*   #include <clib/exec_protos.h>
*   #include <clib/dos_protos.h>
*   #include <libraries/supra.h>
*
*   struct RecDirFIB rdf;
*   struct RecDirInfo rdi;
*   char name[30];
*   char path[100];
*   LONG size;
*   LONG err;
*
*   struct DosBase *DosBase;
*
*   void main()
*   {
*        if (DosBase = (struct DosBase *)OpenLibrary("dos.library",0)) {
*
*           rdi.rdi_Path = "RAM:";  \* from path "RAM:" *\
*           rdi.rdi_Num = -1;       \* Unlimited subdirs deep *\
*           rdi.rdi_Pattern = NULL; \* Don't match files for pattern *\
*
*           if (RecDirInit(&rdi) == 0) {
*               rdf.Path = path;  \* We want to get files' path, name and size *\
*               rdf.Name = name;
*               rdf.Size = &size;
*               while ((err = RecDirNext(&rdi, &rdf)) == 0) {
*                   printf("%s (%s) %ld\n", path, name, size);
*               }
*
*               \* Now check if DN_ERR_END or some other unexpected error *\
*               switch (err) {
*                   case DN_ERR_END:
*                       printf("Scanning completed\n");
*                       break;
*                   case DN_ERR_EXAMINE:
*                       printf("Error: trouble examining a file\n");
*                       break;
*                   case DN_ERR_MEM:
*                       printf("Error: not enough memory\n");
*               }
*           }
*
*           CloseLibrary((struct Library *)DosBase);
*       } else printf("Cannot open dos.library\n");
*   }
*
*
*   NOTES
*       If you want to end scanning earlier you have to call RecDirFree()!
*
*   BUGS
*       none found
*
*   SEE ALSO
*       RecDirInit(), RecDirTags(), RecDirFree(), libraries/supra.h
*
*
*   CHANGES
*        Expand function and if's for vbcc
*
**************************************************************************/

#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <string.h>
#include <libraries/supra.h>

UBYTE RecDirNext(struct RecDirInfo *rdi, struct RecDirFIB *rdf)
{
	struct LockNode *ln,*newln;
	struct FileInfoBlock *fib;
	BPTR lock=0;
	int len;
	char *path;
	int repeat;

	do {
		repeat = FALSE;
		ln = rdi->rdi_Node;
		fib = ln->ln_FIB;

		if (ExNext(ln->ln_Lock, fib))
		{
			len = strlen(ln->ln_Path)+strlen(fib->fib_FileName);
			if (fib->fib_DirEntryType < 0)   /* This is a file */
			{
				if (rdi->rdi_Pattern==NULL || MatchPattern(rdi->rdi_Pattern, fib->fib_FileName))
				{
					/* Start filling the RecDirFIB structure */
					if (rdf->Name) strcpy(rdf->Name, fib->fib_FileName);
					if (rdf->Path) strcpy(rdf->Path, ln->ln_Path);
					if (rdf->Full)
					{
						strcpy(rdf->Full, ln->ln_Path);
						strcat(rdf->Full, fib->fib_FileName);
					}
					if (rdf->Size) *rdf->Size = fib->fib_Size;
					if (rdf->Flags) *rdf->Flags = fib->fib_Protection;
					if (rdf->Comment) strcpy(rdf->Comment, fib->fib_Comment);
					if (rdf->Date) memcpy(rdf->Date, &fib->fib_Date, sizeof(struct DateStamp));
					if (rdf->Blocks) *rdf->Blocks = fib->fib_NumBlocks;
					if (rdf->UID) *rdf->UID = fib->fib_OwnerUID;
					if (rdf->GID) *rdf->GID = fib->fib_OwnerGID;
					if (rdf->FIB) memcpy(rdf->FIB, fib, sizeof(struct FileInfoBlock));
					return(0L);
				} /* Pattern matched */
				repeat = TRUE; /* Pattern not matched */
			}
			else if (rdi->rdi_Deep < rdi->rdi_Num || rdi->rdi_Num == -1) /* This is a directory */
			{
				if (path = AllocMem(len+2,0))
				{
					strcpy(path, ln->ln_Path);
					strcat(path, fib->fib_FileName);
					strcat(path, "/");

					fib = NULL;

					lock = Lock(path, ACCESS_READ);
					if (lock)
					{
						fib = AllocMem(sizeof(struct FileInfoBlock), 0L);
						if (fib)
						{
							if (Examine(lock, fib))
							{
								/* Set up a new LockNode */
								newln = AllocMem(sizeof(struct LockNode), 0L);
								if (newln)
								{
									rdi->rdi_Deep++;
									rdi->rdi_Node = newln;
									ln->ln_Succ = newln;
									newln->ln_Pred = ln;
									newln->ln_Succ = NULL;
									newln->ln_Lock = lock;
									newln->ln_FIB= fib;
									newln->ln_Path = path;
									newln->ln_Len= len+2;
									repeat = TRUE;
								}
							}
						}
					}
				}

				if (repeat == FALSE) 			/* MEMORY ERROR! */
				{
					if (fib) FreeMem(fib, sizeof(struct FileInfoBlock));
					if (lock) UnLock(lock);
					if (path) FreeMem(path, len+2);
					RecDirFree(rdi);
					return(DN_ERR_MEM);
				}
			} /*Examined file was file or dir */
		}
		else	/* ExNext failed: probably no more files in current dir */
		{
			if (IoErr() != ERROR_NO_MORE_ENTRIES)		/* Something very wrong */
			{
				RecDirFree(rdi);
				return(DN_ERR_EXAMINE);
			}
			else
			{			 /* Erase last LockNode */
				FreeMem(ln->ln_Path, ln->ln_Len);
				FreeMem(ln->ln_FIB, sizeof(struct FileInfoBlock));
				UnLock(ln->ln_Lock);
				newln=ln->ln_Pred;
				FreeMem(ln, sizeof(struct LockNode));
				newln->ln_Succ = NULL;
				rdi->rdi_Node = newln;
				rdi->rdi_Deep--;
				if (rdi->rdi_Deep == 0) return(DN_ERR_END); /* Scanning complete */

				repeat = TRUE;
			}
		}
	}
	while (repeat == TRUE);
}

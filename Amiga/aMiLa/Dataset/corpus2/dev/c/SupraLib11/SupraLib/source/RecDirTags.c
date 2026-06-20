/****** RecDirTags *****************************************************
*
*   NAME
*       RecDirNextTagList -- Gets information about next file (V10)
*       (dos V36)
*
*   SYNOPSIS
*       error = RecDirNextTagList(RecDirInfo, RecDirFIB, TagItems)
*
*       UBYTE = RecDirNextTagList(struct RecDirInfo *, struct RecDirFIB *,
*                   struct TagItem *);
*
*
*       error = RecDirNextTags(RecDirInfo, RecDirFIB, tag1, ...)
*
*       UBYTE = RecDirNextTags(struct RecDirInfo *, struct RecDirFIB *,
*                   ULONG tag1, ...);*
*
*
*   FUNCTION
*       This function does the same as RecDirNext() but it provides
*       a TagList extension. Any additional tags will override initial
*       settings in RecDirFIB structure.
*
*   INPUTS
*       RecDirInfo - pointer to RecDirInfo structure which has been
*                    called with RecDirInit()
*       RecDirFIB  - pointer to initialized and set RecDirFIB structure,
*                    or NULL.
*                    You can get files' information either by setting
*                    variables to this structure before calling
*                    RecDirNextTagList(), or by providing TagItems you
*                    want. 
*                    NOTE: If you provide any TagItem then RecDirFIB will
*                    be changed (if it's non-NULL)!
*
*       Tags - The following tags are available:
*
*           RD_NAME - File name will be provided. ti_Data should carry
*                     a pointer to a string buffer (char *)
*           RD_PATH - Directory path where scanned file is.
*           RD_FULL - Full directory path + file name
*           RD_SIZE - File lenght in bytes. ti_Data must have a pointer to
*                     a LONG number (LONG *).
*           RD_FLAGS - File's protection flags. ti_Data must have a pointer
*                     to LONG.
*           RD_COMMENT - File's comment note. ti_Data carries a pointer to
*                     a string buffer.
*           RD_DATE - File's DateStamp structure. Function will copy the
*                     entire DateStamp structure into struct DateStamp
*                     provided in ti_Data field that points to it.
*           RD_BLOCKS - File size in blocks. ti_Data should have a pointer
*                       to LONG
*           RD_UID - Owner's UID (not supported with all file systems).
*                    ti_Data should have a pointer to UWORD variable.
*           RD_GID - Owner's GID. ti_Data has a pointer to UWORD variable.
*           RD_FIB - FileInfoBlock. Function will copy examined file's
*                    FileInfoBlock to a provided struct FileInfoBlock
*                    via ti_Data (ti_Data has a pointer to an allocated
*                    FileInfoBlock structure).
*
*   RESULT
*       Same as for RecDirNext()
*
*   EXAMPLE
*
*       See an example for RecDirNext(). You can replace its line
*
*       RecDirNext(&rdi, &rdf);
*          *with*
*       RecDirNextTags(&rdi, NULL, RD_PATH, path,
*                                  RD_NAME, name,
*                                  RD_SIZE, &size,
*                                  TAG_DONE);
*   NOTES
*       If RecDirFIB is not NULL, and you provide some tags as well then
*       RecDirFIB will be changed. This may change in the future so
*       that provided RecDirFIB will not change.
*
*   BUGS
*       none found
*
*   SEE ALSO
*       RecDirNext(), RecDirInit(), libraries/supra.h
*
************************************************************************/

#include <proto/exec.h>
#include <proto/utility.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <utility/tagitem.h>
#include <libraries/supra.h>
 

UBYTE RecDirNextTagList(struct RecDirInfo *rdi, struct RecDirFIB *rdf,
                    struct TagItem *tagList)
{
ULONG data;
struct TagItem *tstate,*tag;
UBYTE suc;
UBYTE alloc = FALSE;

if (rdf == NULL) {
    if ((rdf = AllocMem(sizeof(struct RecDirFIB), MEMF_CLEAR)) == NULL) {
        return(RDI_ERR_MEM);
    }
    alloc = TRUE;
}

    tstate = tagList;

    while (tag = NextTagItem(&tstate)) {
        data = tag->ti_Data;
        switch(tag->ti_Tag) {
            case RD_NAME:
                rdf->Name = (char *)data;
                break;
            case RD_PATH:
                rdf->Path = (char *)data;
                break;
            case RD_FULL:
                rdf->Full = (char *)data;
                break;
            case RD_SIZE:
                rdf->Size = (ULONG *)data;
                break;
            case RD_FLAGS:
                rdf->Flags = (ULONG *)data;
                break;
            case RD_COMMENT:
                rdf->Comment = (char *)data;
                break;
            case RD_DATE:
                rdf->Date = (struct DateStamp *)data;
                break;
            case RD_BLOCKS:
                rdf->Blocks = (ULONG *)data;
                break;
            case RD_UID:
                rdf->UID = (UWORD *)data;
                break;
            case RD_GID:
                rdf->GID = (UWORD *)data;
                break;
            case RD_FIB:
                rdf->FIB = (struct FileInfoBlock *)data;
                break;
        }
    }

    suc = RecDirNext(rdi, rdf);
    if (alloc == TRUE) FreeMem(rdf, sizeof(struct RecDirFIB));
    return(suc);
}

UBYTE RecDirNextTags(struct RecDirInfo *rdi, struct RecDirFIB *rdf, ULONG tagItem1, ...)
{
    UBYTE suc;

    suc = RecDirNextTagList(rdi, rdf, (struct TagItem *)&tagItem1);
    return(suc);
}




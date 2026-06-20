/****** RecDirFree *************************************************
*
*   NAME
*       RecDirFree -- Unlocks all locked paths (V10)
*       (dos V36)
*
*   SYNOPSIS
*       void RecDirFree(RecDirInfo)
*
*       void RecDirFree(struct RecDirInfo *);
*
*   FUNCTION
*       This function is called internally when error occurs in
*       RecDirNext(), so you don't have to call it then!
*       You can only call it when you no longer want to use RecDirNext(),
*       before it finishes the scanning process.
*       You DO NOT have to call RecDirFree() when you get any error,
*       even DN_ERR_END (scanning process complete)!
*
*   INPUTS
*       RecDirInfo - pointer to struct RecDirInfo which has been
*                    called with RecDirInit()
*
*   RESULT
*       none
*
*   SEE ALSO
*       RecDirInit(), RecDirNext(), RecDirNextTagList()
*
*******************************************************************/

#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/memory.h>
#include <libraries/supra.h>

void RecDirFree(struct RecDirInfo *rdi)
{
    struct LockNode *ln;

    while (rdi->rdi_Deep > 0)
	{
        ln = rdi->rdi_Node;
        FreeMem(ln->ln_Path, ln->ln_Len);
        FreeMem(ln->ln_FIB, sizeof(struct FileInfoBlock));
        UnLock(ln->ln_Lock);
        rdi->rdi_Node = ln->ln_Pred;
        FreeMem(ln,sizeof(struct LockNode));
        rdi->rdi_Deep--;
    }
}

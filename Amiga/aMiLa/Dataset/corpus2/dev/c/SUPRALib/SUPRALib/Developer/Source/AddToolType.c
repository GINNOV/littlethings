/****** AddToolType *****************************************************
*
*   NAME
*       AddToolType -- Adds or changes a new/existing icon's tooltype (V10)
*       (icon)
*
*   SYNOPSIS
*       tool = AddToolType(diskobj, tooltype)
*
*       char * = AddToolType(struct DiskObject *, char *);
*
*   FUNCTION
*       This function lets you add a new tooltype to a disk object's
*       tooltype list, or change already existing one.
*       It is a smart routine that makes dealing with tooltypes very
*       straightforward.
*
*       The following is an example table about how a tooltype list gets
*       changed based on a provided tool:
*
*        existing tooltype | provided tooltype | result
*       ----------------------------------------------------------
*            NOGUI         |     (NOGUI)       | (NOGUI)
*            (NOGUI)       |     NOGUI         | NOGUI
*            NOGUI         |     NOGUI         | NOGUI
*            SIZE=10       |     SIZE=15       | SIZE=15
*            (SIZE=10)     |     SIZE=15       | SIZE=15
*            SIZE=10       |     (SIZE=15)     | (SIZE=15)
*            [a new one]   |     DONOTWAIT     | DONOTWAIT [added to a list]
*
*
*   INPUTS
*       diskobj - points to an allocated DiskObject structure (usually
*                 created by GetDiskObject() function).
*
*       tooltype - points to a new tooltype string to be added to a
*                  provided tooltype list
*
*   RESULT
*       tool = pointer to a provided tooltype string if succeeds, otherwise
*       NULL.
*
*   EXAMPLES
*       This example opens a ram:test.info icon and asks a user to enter
*       tooltypes to be added (until user enters 'end').
*
*
*   #include <libraries/supra.h>
*   #include <clib/exec_protos.h>
*   #include <clib/dos_protos.h>
*   #include <clib/icon_protos.h>
*   #include <stdio.h>
*   #include <string.h>
*
*   #define filename "ram:test"
*
*   struct Library *IconBase = NULL;
*
*   struct DiskObject *diskobj;
*
*   char icon[50];
*
*   main()
*   {
*       key = NULL;
*           if (IntuitionBase = OpenLibrary("intuition.library",0)) {
*               if (IconBase = OpenLibrary("icon.library",0)) {
*                   if (diskobj = GetDiskObject(filename)) {
*                       do {
*                           gets(icon);
*                           if (strcmp(icon, "end") == 0) break;
*                           AddToolType(diskobj, icon);
*                       } while (TRUE);
*
*                       PutDiskObject(filename, diskobj);
*                       FreeDiskObject(diskobj);
*                       FreeRemember(&key, TRUE);
*                   }
*               }
*           }
*
*       if (IconBase) CloseLibrary(IconBase);
*       if (IntuitionBase) CloseLibrary(IntuitionBase);
*   }
*
*
*   NOTES
*       All memory allocations used by AddToolType() will be stored in
*       FreeList structure that MUST be allocated right after the provided
*       DiskObject structure. If you called your DiskObject by GetDiskObject()
*       or GetDiskObjectNew() then FreeList is automaticly appended.
*       All allocated memory is freed when you call FreeDiskObject().
*
*       This function requires icon.library to be opened.
*
****************************************************************************/

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/icon.h>
#include <workbench/workbench.h>
#include <stdlib.h>
#include <string.h>

/* This compares a tooltype entry to a string
 * Returns: 0 if absolutely the same
 *          1 if string after '=' is different
 *          2 if different
 *          3 if different only in brackets
 *          4 if string after '=' is different, and dif. in brackets
 *          5 different in all (same as 2)
 */
int ToolMatch(char *s1, char *s2)
{
	int cmp = 2;
	int offs = 0;

    if ((*s1 == '(' || *s2 == '(') && *s1 != *s2) offs = 3;
    if (*s1 == '(') s1++;
    if (*s2 == '(') s2++;
    if (*s1 == ')')
	{
    	if (*(s1+1) == '\0') s1++;
    }

    if (*s2 == ')')
	{
        if (*(s2+1) == '\0') s2++;
    }


    while (*s1 && *s2)
	{
        if (*s1 == '\0' && *s2 == '\0') return(0+offs);
        if (*s1 != *s2) return(cmp+offs);
        if (*s1 == '=') cmp=1;
        s1++; s2++;
        if (*s1 == ')')
		{
            if (*(s1+1) == '\0') s1++;
        }

        if (*s2 == ')')
		{
            if (*(s2+1) == '\0') s2++;
        }

    }

    if (*s1 == '\0' && *s2 == '\0') return(0+offs);
    else return(cmp+offs);
}

char *AddToolType(struct DiskObject *dobj, char *tool)
{
	struct FreeList *flist = (struct FreeList *)dobj + sizeof(struct DiskObject);
	char ***ttypes = &(dobj->do_ToolTypes);
	char *item = (*ttypes)[0];
	int change = -1;
	int i=0;
	char *newmem;
	int len;

    while (item != NULL)
	{
      if (change == -1)  /* We haven't found any matching tooltype yet */
      {
        switch(ToolMatch(item, tool))
        {
            case 0: return(item);   /* This tooltype already defined */
            case 1:
            case 3:
            case 4: change = i;     /* Change this tooltype */
        }   /* 2,5 means different */
      }
      i++;
      item = (*ttypes)[i]; /* Get the next tooltype to be examined */
    }

    if (change != -1)
	{
        len = strlen(tool)+1;
        newmem = AllocMem(len, 0L);
        if (!newmem) return(NULL);
        else if (AddFreeList(flist, newmem, len) == FALSE)
        {
            FreeMem(newmem, len);
            return(NULL);
        }

        strcpy(newmem, tool);
        (*ttypes)[change] = newmem;
        return(newmem);
    }
    else
    {
        len = (i+2)*4;
        newmem = AllocMem(len, 0L);
        if (!newmem) return(NULL);
        else if (AddFreeList(flist, newmem, len) == FALSE)
        {
            FreeMem(newmem, len);
            return(NULL);
        }

        memcpy(newmem, *ttypes, len);
        *ttypes = (char **)newmem;

        len = strlen(tool)+1;
        newmem = AllocMem(len, 0L);
        if (!newmem) return(NULL);
        else if (AddFreeList(flist, newmem, len) == FALSE) {
            FreeMem(newmem, len);
            return(NULL);
        }

        strcpy(newmem, tool);
        (*ttypes)[i] = newmem;
        (*ttypes)[i+1] = NULL;
        return(newmem);
    }
}

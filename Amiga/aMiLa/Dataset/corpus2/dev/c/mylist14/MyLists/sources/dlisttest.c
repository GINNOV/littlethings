/* DListTest.c */
#include "dlist.h"
#include <stdio.h>
#include <exec/types.h>

/* this program is merely intended as a short demo of how to use
   the lists. It is wise to check the status after every operation.
   In this program not all are checked.
*/
   
/* Dumps an integer list to screen */
void DList_Dump_Integer(DLIST *theDList)
{
        int ok,data;
        
        if(IsDList_Empty(theDList))
        {
            printf("DList Empty !\n");
            return;
        }    
        printf("--- DUMP OF DLIST - SIZE: %2d nodes.\n",DList_Size(theDList));
                
        ok=DList_SetPos(theDList,0);
        while(ok==DLIST_OK)
        {
                DList_Retrieve(theDList,&data);
                printf("Pos:%2d Data:%d\n",DList_GetPos(theDList),data);
                ok=DList_FindNext(theDList);
        }
        printf("--- END OF DUMP.\n\n");
}
 
int main()
{
        DLIST *myDList=NULL;
        int fdata;
        
        if((myDList=DList_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create DList.\n");
            exit(0);
        }    

        /* current stays the same */
        fdata=1;            
        DList_InsertBefore(myDList,&fdata);
        fdata=5;            
        DList_InsertBefore(myDList,&fdata);
        fdata=9;
        DList_InsertAfter(myDList,&fdata);
                
        DList_Dump_Integer(myDList);

        printf("Nodes in list -> %d\n",DList_Size(myDList));

        DList_SetPos(myDList,1);
        DList_Retrieve(myDList,&fdata);
        printf("Node 1 retrieved: %d\n",fdata);
        printf("%d\n",DList_Delete(myDList));

        DList_Dump_Integer(myDList);
        printf("Nodes in list -> %d\n",DList_Size(myDList));

        DList_Free(myDList);
        exit(0);
}
/* End */
       

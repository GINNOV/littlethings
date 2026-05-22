/* SListTest.c */
#include "slist.h"
#include <stdio.h>
#include <exec/types.h>

/* this program is merely intended as a short demo of how to use
   the lists. It is wise to check the status after every operation.
   In this program not all are checked.
*/
   
/* Dumps an integer list to screen */
void SList_Dump_Integer(SLIST *theSList)
{
        int ok,data;
        
        if(IsSList_Empty(theSList))
        {
            printf("SList Empty !\n");
            return;
        }    
        printf("--- DUMP OF SLIST - SIZE: %2d nodes.\n",SList_Size(theSList));
                
        ok=SList_SetPos(theSList,0);
        while(ok==SLIST_OK)
        {
                SList_Retrieve(theSList,&data);
                printf("Pos:%2d Data:%d\n",SList_GetPos(theSList),data);
                ok=SList_FindNext(theSList);
        }
        printf("--- END OF DUMP.\n\n");
}
 
int main()
{
        SLIST *mySList=NULL;
        int fdata;
        
        if((mySList=SList_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create SList.\n");
            exit(0);
        }    

        /* current stays the same */
        fdata=1;            
        SList_InsertBefore(mySList,&fdata);
        fdata=5;            
        SList_InsertBefore(mySList,&fdata);
        fdata=9;
        SList_InsertAfter(mySList,&fdata);
                
        SList_Dump_Integer(mySList);
         
        SList_Free(mySList);
        exit(0);
}
/* End */
       

/* Btreetest.c */
#include "btree.h"
#include <stdio.h>
#include <string.h>
int main()
{
        BTREE *myBtree=NULL;
        int  fdata;
        char sdata[]="Turn around";
        
        if((myBtree=BTree_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create btree.\n");
            exit(0);
        }    
            
        printf("Testing an integer btree !\n");    
        fdata=9999;
        if((BTree_Insert(myBtree,&fdata))!=BTREE_OK)
        {
                printf("Couldn't insert.\n");
                BTree_Free(myBtree);
                exit(0);
        }    
        printf("Inserted   :%d\n",fdata);
        printf("Btree size :%d\n",BTree_Size(myBtree));
        printf("Btree empty:%d\tBtree full:%d\n",IsBTree_Empty(myBtree),IsBTree_Full(myBtree));
        
        fdata=0;
        if((BTree_Retrieve(myBtree,&fdata))!=BTREE_OK)
        {
                printf("Couldn't retrieve.\n");
                BTree_Free(myBtree);
                exit(0);
        }
        printf("Retrieved     :%d.\n",fdata);

        BTree_Free(myBtree);
        
        if((myBtree=BTree_Create(1))==NULL)
        {
            printf("Couldn't create btree.\n");
            exit(0);
        }
            
        printf("Testing char btree !\n");
        printf("Inserting string : %s\n",sdata);
                
        for(fdata=0;fdata<strlen(sdata);fdata++)
                printf("Insert:%d\n",BTree_Insert(myBtree,(void *)&sdata[fdata]));
        printf("Btree size : %d\n",BTree_Size(myBtree));

        printf("FindLeft:%d\n",BTree_FindLeft(myBtree));
        printf("DelLeaf:%d\n",BTree_DelLeaf(myBtree));
        printf("FindRight:%d\n",BTree_FindRight(myBtree));
        printf("DelLeaf:%d\n",BTree_DelLeaf(myBtree));

        printf("Btree size : %d\n",BTree_Size(myBtree));
        
        fdata=0;
        strcpy(sdata,"o");
        BTree_FindKey(myBtree,&sdata);
        printf("Found string  : %s\n",sdata);
        BTree_Free(myBtree);
       exit(0);
}
/* End */
                

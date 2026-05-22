/* StackTest.c */
#include "stack.h"
#include <stdio.h>
#include <exec/types.h>

int main()
{
        STACK *myStack=NULL;
        int  fdata;
        char sdata[]="Turn around";
        
        if((myStack=Stack_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create stack.\n");
            exit(0);
        }    
            
        printf("Testing an integer stack !\n");    
        fdata=9999;
        if((Stack_Push(myStack,&fdata))!=STACK_OK)
        {
                printf("Couldn't push.\n");
                Stack_Free(myStack);
                exit(0);
        }    
        printf("Pushed     :%d\n",fdata);
        printf("Stack size :%d\n",Stack_Size(myStack));
        printf("Stack empty:%d\tStack full:%d\n",IsStack_Empty(myStack),IsStack_Full(myStack));
        
        fdata=0;
        if((Stack_Pop(myStack,&fdata))!=STACK_OK)
        {
                printf("Couldn't pop.\n");
                Stack_Free(myStack);
                exit(0);
        }
        printf("Popped     :%d.\n",fdata);
        printf("Stack empty:%d\n",IsStack_Empty(myStack));

        Stack_Free(myStack);
        
        if((myStack=Stack_Create(1))==NULL)
        {
            printf("Couldn't create stack.\n");
            exit(0);
        }
            
        printf("Testing char stack !\n");
        printf("Pushing string : %s\n",sdata);
                
        for(fdata=0;fdata<strlen(sdata);fdata++)
                Stack_Push(myStack,&sdata[fdata]);
        printf("Stack size : %d\n",Stack_Size(myStack));

        fdata=0;
        while((IsStack_Empty(myStack))==FALSE)
        {
                Stack_Pop(myStack,&sdata[fdata]);
                fdata++;
        }
        printf("Popped string  : %s\n",sdata);
        printf("Stack size     : %d\n",Stack_Size(myStack));
        Stack_Free(myStack);
       exit(0);
}
/* End */
                

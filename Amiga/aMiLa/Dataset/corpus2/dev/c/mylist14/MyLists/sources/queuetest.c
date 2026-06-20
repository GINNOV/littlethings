/* QueueTest.c */
#include "queue.h"
#include <stdio.h>
#include <exec/types.h>

int main()
{
        QUEUE *myQueue=NULL;
        int fdata;
        
        if((myQueue=Queue_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create Queue.\n");
            exit(0);
        }    
            
        printf("Queue empty:%d\n",IsQueue_Empty(myQueue));
        printf("Queue full :%d\n",IsQueue_Full(myQueue));
        
        fdata=9999;
        if((Queue_Enqueue(myQueue,&fdata))!=QUEUE_OK)
        {
                printf("Couldn't enqueue.\n");
                Queue_Clear(myQueue);
                free(myQueue);
                exit(0);
        }    
        printf("Enqueued   :%d\n",fdata);
        printf("Queue size :%d\n",Queue_Size(myQueue));
        printf("Queue empty:%d\n",IsQueue_Empty(myQueue));
        printf("Queue full :%d\n",IsQueue_Full(myQueue));
        
        fdata=0;
        if((Queue_Serve(myQueue,&fdata))!=QUEUE_OK)
        {
                printf("Couldn't serve.\n");
                Queue_Clear(myQueue);
                free(myQueue);
                exit(0);
        }
        printf("Served     :%d.\n",fdata);
        printf("Queue empty:%d\n",IsQueue_Empty(myQueue));
        
        fdata=1;
        for(fdata=1;fdata<6;fdata++)
        {
                Queue_Enqueue(myQueue,&fdata);
                printf("Enqueued  :%d\n",fdata);
        }        

        printf("Queue size :%d\n",Queue_Size(myQueue));

        while((IsQueue_Empty(myQueue))==FALSE)
        {
                Queue_Serve(myQueue,&fdata);
                printf("Served  :%d\n",fdata);
        }
                                 
        Queue_Clear(myQueue);
        printf("Queue size :%d\n",Queue_Size(myQueue));
        Queue_Free(myQueue);
        exit(0);
}
/* End */
                

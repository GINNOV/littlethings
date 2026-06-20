/* PriQueueTest.c */
#include "priqueue.h"
#include <stdio.h>
#include <exec/types.h>

int main()
{
        PRIQUEUE *myQueue=NULL;
        int fdata;
        short priority,x;
        
        if((myQueue=PriQueue_Create(sizeof(int)))==NULL)
        {
            printf("Couldn't create PriQueue.\n");
            exit(0);
        }    
            
        printf("PriQueue empty:%d\n",IsPriQueue_Empty(myQueue));
        printf("PriQueue full :%d\n",IsPriQueue_Full(myQueue));
        
        fdata=0;
        priority=4;
        for(priority=4;priority>=0;priority--,fdata+=5)
        {
            if((PriQueue_Enqueue(myQueue,&fdata,priority))!=PRIQUEUE_OK)
            {
                printf("Couldn't enqueue.\n");
                PriQueue_Clear(myQueue);
                free(myQueue);
                exit(0);
            }
            printf("Enqueued   :%d\n",fdata);
            printf("Queue size :%d\n",PriQueue_Size(myQueue));
            printf("Queue empty:%d\n",IsPriQueue_Empty(myQueue));
            printf("Queue full :%d\n",IsPriQueue_Full(myQueue));
        }
        printf("Queue size :%d\n",PriQueue_Size(myQueue));
        
        for(x=0;x<3;x++)
        {
            fdata=0;
            if((PriQueue_Serve(myQueue,&fdata,&priority))!=PRIQUEUE_OK)
            {
                printf("Couldn't serve.\n");
                PriQueue_Clear(myQueue);
                free(myQueue);
                exit(0);
            }
            printf("Served     :%d. with pri %d\n",fdata,priority);
            printf("Queue empty:%d\n",IsPriQueue_Empty(myQueue));
        }
        printf("Queue size :%d\n",PriQueue_Size(myQueue));

        PriQueue_Clear(myQueue);
        PriQueue_Free(myQueue);
        exit(0);
}
/* End */
                

/* Unbounded PQueue implementation */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "PQueue.h"

struct Node
{
	ELEMENT 		elt;
	PRIORITY		pty;
	PTR_S_NODE	        next;
};

struct PQueueDescr
{
	long			currSize;
	PTR_S_NODE		head;
};

/**********************************************************/

PTR_S_PQUEUEDESCR Create(PTR_S_PQUEUEDESCR pq)
{
	if (pq=(PTR_S_PQUEUEDESCR) malloc(sizeof(S_PQUEUEDESCR)))
	{
		pq->currSize=0;
		pq->head=NULL;
		return(pq);
	}
	else
		return(pq);
}

/**********************************************************/

void Destroy(PTR_S_PQUEUEDESCR pq)
{
	ELEMENT e;
	
	while (IsEmpty(pq)==0)
		Dequeue(pq,&e);
	free(pq);
}


/**********************************************************/

BOOLEAN IsEmpty(PTR_S_PQUEUEDESCR pq)
{
	return(pq->currSize==0);
}

/**********************************************************/

long Size(PTR_S_PQUEUEDESCR pq)
{
	return(pq->currSize);
}

/**********************************************************/

BOOLEAN Enqueue(PTR_S_PQUEUEDESCR pq,ELEMENT elt,PRIORITY py)
{
	PTR_S_NODE currPtr,tempPtr,helpPtr;
	int isOnTop;
	
	if (currPtr=(PTR_S_NODE) malloc(sizeof(S_NODE)))
	{
		currPtr->elt=elt;
		currPtr->pty=py;
		helpPtr=pq->head;
		tempPtr=pq->head;
		isOnTop=1;
		while((tempPtr!=NULL) && (currPtr->pty<tempPtr->pty))
		{
			isOnTop=0;
			helpPtr=tempPtr;
			tempPtr=tempPtr->next;
		}
		if(IsEmpty(pq))
		{
			pq->head=currPtr;
			currPtr->next=NULL;
		}
		else
		{
			if(currPtr->pty<tempPtr->pty)
			{
				helpPtr->next=currPtr;
				currPtr->next=tempPtr;
			}
			else
			{
				currPtr->next=tempPtr;
				if(isOnTop)
					pq->head=currPtr;
				else
					helpPtr->next=currPtr;
			}
		}
		pq->currSize++;
		return(1);
	}
	else
		return(0);
}

/**********************************************************/

BOOLEAN Dequeue(PTR_S_PQUEUEDESCR pq,PTR_ELEMENT elt)
{
	PTR_S_NODE currPtr;
	
	if(IsEmpty(pq)==0)
	{
		currPtr=pq->head;
		*elt=currPtr->elt;
		pq->head=currPtr->next;
		free(currPtr);
		pq->currSize--;
		return(1);
	}
	else
		return(0);
}

/**********************************************************/

BOOLEAN IsMemoryAvailable(void)
{
	PTR_S_NODE currPtr;
	
	if((currPtr=((PTR_S_NODE) malloc(sizeof(S_NODE))))!=NULL)
	{
		free(currPtr);
		return(1);
	}
	else
		return(0);
}

/**********************************************************/

void GetRelease(PTR_CHAR release)
{
	strcpy(release," D1.0 I1.0");
}

/**********************************************************/


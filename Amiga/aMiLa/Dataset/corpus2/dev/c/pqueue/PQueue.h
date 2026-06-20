/* Unbounded PQueue specification */

typedef long	ELEMENT,*PTR_ELEMENT;

typedef long	PRIORITY;

typedef struct Node S_NODE,*PTR_S_NODE;

typedef struct PQueueDescr S_PQUEUEDESCR,*PTR_S_PQUEUEDESCR;

typedef char    *PTR_CHAR;

typedef int     BOOLEAN;

/**********************************************************/

PTR_S_PQUEUEDESCR Create(PTR_S_PQUEUEDESCR);

void Destroy(PTR_S_PQUEUEDESCR);

BOOLEAN IsEmpty(PTR_S_PQUEUEDESCR);

long Size(PTR_S_PQUEUEDESCR);

BOOLEAN Enqueue(PTR_S_PQUEUEDESCR,ELEMENT,PRIORITY);

BOOLEAN Dequeue(PTR_S_PQUEUEDESCR,PTR_ELEMENT);

BOOLEAN IsMemoryAvailable(void);

void GetRelease(PTR_CHAR);

/**********************************************************/


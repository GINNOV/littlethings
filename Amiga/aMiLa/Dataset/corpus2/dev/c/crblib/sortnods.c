#include <stdlib.h>
#include <crbinc/inc.h>

typedef struct SortNodeStruct SortNode;

struct SortNodeStruct
  {
  SortNode * Next;
  ulong Index;
  ubyte * MoreIndexPtr;
  void * Data;
  };

bool Sort_List(SortNode ** BasePtr);
bool Sort_Array(SortNode ** Array,int Num);

/* **/

bool Sort_List(SortNode ** BasePtr)
{
SortNode ** Array;
int ArraySize,i;
SortNode * CurNode;

ArraySize = 0;
CurNode = *BasePtr;
while(CurNode) { ArraySize++; CurNode = CurNode->Next; }

if ( ArraySize <= 1 ) return(1);

if ( (Array = malloc(sizeofpointer*ArraySize)) == NULL )
  return(0);

i = 0;
CurNode = *BasePtr;
while(CurNode) { Array[i++] = CurNode; CurNode = CurNode->Next; }

if ( ! Sort_Array(Array,ArraySize) )
  { free(Array); return(0); }

i = 0;
CurNode = Array[0];
*BasePtr = CurNode;
i++;
while(i<ArraySize)
  {
  CurNode->Next = Array[i++];
  CurNode = CurNode->Next;
  }
CurNode->Next = NULL;

free(Array);
return(1);
}

static SortNode ** QSArray;
static void QS(long L,long R);

bool Sort_Array(SortNode ** Array,int ArraySize)
{
if ( ArraySize <= 1 ) return(1);

/*

todo:

if ( ArraySize > 3000 ) radix on first word
else if ( ArraySize > 256 ) radix on first byte

QS each radix hunk

*/

QSArray = Array;
QS(0,ArraySize-1);

return(1);
}

static void QS(long Left,long Right)
{
if ( (Right - Left) > 1 )
  {
  long i;

    {
    long j;
    ulong pivot;
    SortNode *swapper;
    SortNode ** Array;
    bool KeepGoing;
    ubyte * morepivotptr;

    Array = QSArray;

    pivot = Array[Right]->Index;
    morepivotptr = Array[Right]->MoreIndexPtr;

    i = Left-1;
    j = Right;
    for(;;)
      {
      do
        {
        ++i;
        if ( i == Right ) KeepGoing = 0;
        else
          {
          if ( Array[i]->Index < pivot ) KeepGoing = 1;
          else if ( Array[i]->Index == pivot )
            {
            ubyte * MoreIndexPtr = Array[i]->MoreIndexPtr;
            ubyte * curmorepivotptr = morepivotptr;
  
            while(*MoreIndexPtr == *curmorepivotptr)
              { MoreIndexPtr++; curmorepivotptr++; }
  
            if ( *MoreIndexPtr < *curmorepivotptr )
              KeepGoing = 1;
            else
              KeepGoing = 0;
            }
          else KeepGoing = 0;
          }
        } while(KeepGoing);

      do
        {
        --j;
        if ( Array[j]->Index > pivot ) KeepGoing = 1;
        else if ( Array[j]->Index == pivot )
          {
          ubyte * MoreIndexPtr = Array[j]->MoreIndexPtr;
          ubyte * curmorepivotptr = morepivotptr;

          while(*MoreIndexPtr == *curmorepivotptr)
            { MoreIndexPtr++; curmorepivotptr++; }

          if ( *MoreIndexPtr > *curmorepivotptr )
            KeepGoing = 1;
          else
            KeepGoing = 0;
          }
        else KeepGoing = 0;
        } while(KeepGoing && j > Left);

      if (i >= j) break;
      swapper  = Array[i];
      Array[i] = Array[j];
      Array[j] = swapper;
      }
    swapper  = Array[i];
    Array[i] = Array[Right];
    Array[Right] = swapper;
    }

  QS(Left,i-1);
  QS(i+1,Right);
  }
else
  {
  if ( Right > Left )
    {
    if ( QSArray[Right]->Index < QSArray[Left]->Index )
      {
      SortNode *swapper;

      swapper  = QSArray[Left];
      QSArray[Left] = QSArray[Right];
      QSArray[Right] = swapper;
      }
    else if ( QSArray[Right]->Index == QSArray[Left]->Index )
      {
      ubyte *rptr=QSArray[Right]->MoreIndexPtr;
      ubyte *lptr=QSArray[Left]->MoreIndexPtr;

      while(*rptr == *lptr) { rptr++; lptr++; }
      if ( *rptr < *lptr )
        {
        SortNode *swapper;

        swapper  = QSArray[Left];
        QSArray[Left] = QSArray[Right];
        QSArray[Right] = swapper;
        }
      }
    }
  }
}

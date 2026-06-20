/* Program for testing the SkipList.library from GNU C.
 *
 * $Header: Big:Programming/C/SkipLists/RCS/Exercise.c,v 1.5 1996/08/19 16:08:45 AGMS Exp $
 *
 * By Alexander G. M. Smith, agmsmith@achilles.net, July 1996.
 * Compiled with GNU C version 2.7.0, command line:
 *   gcc -v -noixemul -O2 -Wall Exercise.c
 *
 * $Log: Exercise.c,v $
 * Revision 1.5  1996/08/19  16:08:45  AGMS
 * Cosmetics.
 *
 * Revision 1.4  1996/08/19  15:09:47  AGMS
 * Now has interactive skip list testing.
 *
 * Revision 1.3  1996/08/17  12:57:34  AGMS
 * Working but hard coded version, no interactivity yet.
 *
 * Revision 1.2  1996/08/14  14:34:11  AGMS
 * Added a header printing function.
 *
 * Revision 1.1  1996/08/11  13:14:05  AGMS
 * Initial revision
 */

#define LIBCALL_DECLARATION extern __inline

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <proto/exec.h>
#include "SkipList.h"

APTR SkipListBase;


#define NAMELENGTH 20

typedef struct FatNodeStruct
{
  SkipNodeRecord  skipNode;
  char name [NAMELENGTH];
} FatNodeRecord, *FatNodePointer;



/* Wait for the user to hit return. */

void WaitForKey (void)
{
  char TempString [80];

  printf ("\nPress the return key to continue.");
  fgets (TempString, sizeof (TempString), stdin);
}



void PrintSkipListHeader (SkipListPointer TheList)
{
  int   i;

  printf ("Skip list header at address %ld:\n", (ULONG) TheList);
  for (i = SKIPLISTLEVELCAP - TheList->activeLevels; i < SKIPLISTLEVELCAP; i++)
  {
    printf ("  Level %d\t[%d]->\t%ld\n", SKIPLISTLEVELCAP - i, i,
    (ULONG) TheList->levelPointers [i]);
  }

  printf ("ActiveLev: %d\tSize: %ld\tNextUp: %ld\tNextDown: %ld\t"
  "RandomIndex: %d\n", (int) TheList->activeLevels, TheList->size,
  TheList->nextSizeUp, TheList->nextSizeDown, (int) TheList->randomIndex);

  for (i = 0; i < RANDOMCACHESIZE; i++)
  {
    printf ("%08lx ", TheList->randomCache [i]);
  }
  printf ("\n");
}



void PrintFatNodesInList (SkipListPointer TheList)
{
  int i;
  FatNodePointer TheNode;

  printf ("List of names in list at %ld:\n", (ULONG) TheList);

  i = 8;
  TheNode = (FatNodePointer) TheList->levelPointers [SKIPLISTLEVELCAP-1];
  while (TheNode != NULL)
  {
    if (i <= 0)
    {
      i = 8;
      printf ("%s\n", TheNode->name);
    }
    else
    {
      --i;
      printf ("%s\t", TheNode->name);
    }

    TheNode = (FatNodePointer) TheNode->skipNode.next;
  }
  if (i != 8)
    printf ("\n");
}



void PrintFatListGraphically (SkipListPointer TheList)
{
  int             CurrentLevel;
  SkipNodePointer CurrentNode;
  int             CurrentNodeNumber;
  int             GapStartCount;
  int             GapEndCount;
  signed char     Letter;
  int             LetterIndex;
  int             LineNo;
  SkipNodePointer NextNode;
  const int       NodesPerLine = 35;
  SkipNodePointer PointedToNode;
  BOOL            PointerErrorFound;

  if (TheList->size >= NodesPerLine)
  {
    /* List too big to fit on screen, leave out middle part.  Print
       NodesPerLine / 2 nodes in first part including root node and gap.  Node
       number GapStartCount will be replaced by the gap marker.  Nodes are
       numbered from 0 to TheList->size (extra one for header node). */

    GapStartCount = NodesPerLine / 2 - 1;

    /* Resume printing at this node number. */

    GapEndCount = TheList->size - NodesPerLine + GapStartCount + 2;
  }
  else /* Printing all nodes. */
  {
    GapStartCount = GapEndCount = TheList->size + 1;
  }

  /* Each node gets printed in two columns.  The first few lines printed show
     the list pointers, with "-" if the pointer level passes over a node, ">"
     if a pointer points to a node, "*" for a node pointing somewhere, "?" for
     a bad pointer (one that points at some other node when it should point at
     this node or that points at this node when it should point somewhere
     else.  "0" for null pointers. */

  for (LineNo = 0; LineNo < TheList->activeLevels + 8; LineNo++)
  {
    if (LineNo < TheList->activeLevels)  /* Print pointer picture? */
    {
      CurrentLevel = TheList->activeLevels - LineNo;
      printf ("P%02d: ", CurrentLevel);

      /* Use skip list header as a fake first node. */

      CurrentNode =
      (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];
      CurrentNodeNumber = 0;

      PointedToNode = CurrentNode;
      PointerErrorFound = FALSE;

      while (CurrentNode != NULL)
      {
        if (CurrentLevel <= CurrentNode->size.asBytes.nodeLevel)
        {
          if (CurrentNode != PointedToNode)
            PointerErrorFound = TRUE;

          PointedToNode = ((&CurrentNode->next) + 1) [-CurrentLevel];
        }

        if (CurrentNodeNumber < GapStartCount ||
        CurrentNodeNumber >= GapEndCount)
        {
          /* Print the first character of the node's column. */

          if (CurrentNode->size.asBytes.nodeLevel < CurrentLevel)
            putchar ((PointedToNode == NULL) ? ' ' : '-');
          else
            putchar ((PointedToNode == NULL) ? '0' : '*');

          /* And now the second character, shows what it is pointing at. */

          NextNode = CurrentNode->next;

          if (PointedToNode == NULL)
            putchar (' ');
          else
          {
            if (NextNode == NULL)
              putchar ('?');  /* Where is PointedToNode pointing to, then? */
            else if (NextNode == PointedToNode)
              putchar ((NextNode->size.asBytes.nodeLevel < CurrentLevel) ?
              '?' : '>');
            else /* PointedToNode pointing at some other node. */
              putchar ((NextNode->size.asBytes.nodeLevel < CurrentLevel) ?
              '-' : '?');
          }
        }
        else if (CurrentNodeNumber == GapStartCount)
        {
          printf ("()");
        }
        else
        {
          /* Else not printing this node. */
        }

        CurrentNode = CurrentNode->next;
        ++CurrentNodeNumber;
      }
      if (PointerErrorFound)
        printf ("Err!");
    }
    else if (LineNo == TheList->activeLevels)  /* Print node level numbers. */
    {
      printf ("Lev: ");
      CurrentNode =
      (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];
      CurrentNodeNumber = 0;
      while (CurrentNode != NULL)
      {
        if (CurrentNodeNumber < GapStartCount ||
        CurrentNodeNumber >= GapEndCount)
        {
          printf ("%-2d", (int) CurrentNode->size.asBytes.nodeLevel);
        }
        else if (CurrentNodeNumber == GapStartCount)
        {
          printf ("  ");
        }
        else
        {
          /* Else not printing this node. */
        }
        CurrentNode = CurrentNode->next;
        ++CurrentNodeNumber;
      }
    }
    else /* Just printing the columns of names. */
    {
      LetterIndex = LineNo - 1 - TheList->activeLevels;
      printf ("       ");

      CurrentNode = TheList->levelPointers [SKIPLISTLEVELCAP-1];
      CurrentNodeNumber = 1;
      while (CurrentNode != NULL)
      {
        if (CurrentNodeNumber < GapStartCount ||
        CurrentNodeNumber >= GapEndCount)
        {
          Letter = ((FatNodePointer) CurrentNode)->name [LetterIndex];
          if (Letter < 32)  /* Note signed char. */
            Letter = '?';
          printf ("%c ", Letter);
        }
        else if (CurrentNodeNumber == GapStartCount)
        {
          printf ("  ");
        }
        else
        {
          /* Else not printing this node. */
        }

        CurrentNode = CurrentNode->next;
        ++CurrentNodeNumber;
      }
    }
    putchar ('\n');
  }
}



void RandomLevelTest (SkipListPointer SomeList)
{
  int Bins [SKIPLISTLEVELCAP];
  char FormatString [10];
  int i;
  unsigned int Max = 10000;
  ULONG RandomNo;

  for (i = 0; i < SKIPLISTLEVELCAP; i++)
    Bins [i] = 0;

  printf ("The first few random level numbers of %d:\n", Max);
  for (i = 1; i <= 64; i++)
  {
    RandomNo = GenerateRandomLevelNumber (SomeList);

    if (i & 7)
      printf ("%lu\t", RandomNo);
    else
      printf ("%lu\n", RandomNo);

    ++Bins [RandomNo - 1];
  }

  for (; i <= Max; i++)
  {
    RandomNo = GenerateRandomLevelNumber (SomeList);
    ++Bins [RandomNo - 1];
  }

  printf ("Number: ");
  for (i = 1; i <= SKIPLISTLEVELCAP; i++)
  {
    sprintf (FormatString, "%%%dd ", (i <= 3) ? 7 - i : 3);
    printf (FormatString, i);
  }
  printf ("\nNormal: ");
  for (i = 1; i <= SKIPLISTLEVELCAP; i++)
  {
    sprintf (FormatString, "%%%dd ", (i <= 3) ? 7 - i : 3);
    printf (FormatString, (3 * Max) >> (2 * i));
  }
  printf ("\nActual: ");
  for (i = 1; i <= SKIPLISTLEVELCAP; i++)
  {
    sprintf (FormatString, "%%%dd ", (i <= 3) ? 7 - i : 3);
    printf (FormatString, Bins [i-1]);
  }
  printf ("\n");
}



const char *NameArray [] =
{
  "Alexander",
  "G.",
  "M.",
  "Smith",
  "William",
  "Pugh",
  "Skip",
  "Lists",
  "are",
  "Optimal",
  "and",
  "that",
  "is",
  "all."
};


/* Add our list of canned names to the given list.  Allocate a FatNodeRecord
   for each name. */

void AddNamesToList (SkipListPointer TheList)
{
  int i;
  FatNodePointer MyNode;

  for (i = 0; i < sizeof (NameArray) / sizeof (char *); i++)
  {
    MyNode =  (FatNodePointer) AllocateSkipNode (TheList,
    sizeof (FatNodeRecord), MEMF_CLEAR);

    if (MyNode == NULL)
    {
      printf ("Oops, ran out of memory in AddNamesToList.\n");
      return;
    }

    strcpy (MyNode->name, NameArray [i]);

    InsertSkipNode (TheList, (SkipNodePointer) MyNode);
  }
}



/* Add a number of random nodes to the list. */

void AddRandomNodes (SkipListPointer TheList, int n)
{
  SkipNodePointer NewNode;

  while (--n >= 0)
  {
    NewNode = AllocateSkipNode (TheList, sizeof (FatNodeRecord), MEMF_CLEAR);

    if (NewNode == NULL)
    {
      printf ("Oops, ran out of memory in AddRandomNodes.\n");
      return;
    }

    sprintf (((FatNodePointer) NewNode)->name, "%06d",
    rand () % 1000000);

    InsertSkipNode (TheList, (SkipNodePointer) NewNode);
  }
}



/* Add a node with a particular name to the list. */

void AddNodeWithName (SkipListPointer TheList, char *String)
{
  SkipNodePointer NewNode;
  SkipNodePointer PreviousNode;

  NewNode = AllocateSkipNode (TheList, sizeof (FatNodeRecord), MEMF_CLEAR);

  if (NewNode == NULL)
  {
    printf ("Oops, ran out of memory in AddNodeWithName.\n");
    return;
  }

  strncpy (((FatNodePointer) NewNode)->name, String, NAMELENGTH);

  PreviousNode = InsertSkipNode (TheList, (SkipNodePointer) NewNode);

  printf ("Previous node after insert is %s.\n",
  (PreviousNode == NULL) ? "NULL" : ((FatNodePointer) PreviousNode)->name);
  WaitForKey ();
}



void DeleteNodeByName (SkipListPointer TheList, char *String)
{
  BOOL DeleteDone;
  FatNodeRecord SearchNode;

  strncpy (SearchNode.name, String, NAMELENGTH);
  SearchNode.skipNode.size.asLong = sizeof (SearchNode);

  DeleteDone = DeleteSkipNode (TheList, (SkipNodePointer) &SearchNode);

  printf ("Node named %s deleted %ssuccessfully.\n",
  SearchNode.name, DeleteDone ? "" : "un");
  WaitForKey ();
}



void FindNodeWithName (SkipListPointer TheList, char *String)
{
  FatNodePointer NodeAboveOrEqual;
  FatNodePointer NodeBelow;
  FatNodePointer NodeEqual;
  FatNodeRecord SearchNode;

  strncpy (SearchNode.name, String, NAMELENGTH);
  SearchNode.skipNode.size.asLong = sizeof (SearchNode);

  NodeBelow = (FatNodePointer) FindBelowSkipNode (TheList,
  (SkipNodePointer) &SearchNode);

  NodeEqual = (FatNodePointer) FindSkipNode (TheList,
  (SkipNodePointer) &SearchNode);

  NodeAboveOrEqual = (FatNodePointer) FindAboveOrEqualSkipNode (TheList,
  (SkipNodePointer) &SearchNode);

  printf ("Found these nodes related to \"%s\" --\n", String);
  printf ("Below:          %s\n", NodeBelow == NULL ? "NULL" : NodeBelow->name);
  printf ("Equal:          %s\n", NodeEqual == NULL ? "NULL" : NodeEqual->name);
  printf ("Above or equal: %s\n", NodeAboveOrEqual == NULL ? "NULL" : NodeAboveOrEqual->name);

  WaitForKey ();
}



int main (int argc, char *argv[])
{
  char CommandLine [80];
  SkipListRecord MyList;
  int n;
  BOOL StopRunning;
  BOOL Success;

  Success = TRUE;

  SkipListBase = OpenLibrary (SKIPLISTLIBRARYNAME, 0 /* version */);
  if (SkipListBase == NULL)
  {
    Success = FALSE;
    printf ("Unable to open " SKIPLISTLIBRARYNAME "\n");
  }

  /* Loop to read commands from the user and display the current list. */

  if (Success)
  {
    InitSkipList (&MyList);

    StopRunning = FALSE;
    while (!StopRunning)
    {
      putchar (12); /* Clear screen with a form feed character. */

      PrintFatListGraphically (&MyList);

      printf ("Command (An=Add name, C=Clear, Dn=Delete name, Fn=Find name, \n"
      "H=header, In=Insert n, L=List, N=Names, Q=quit, R[01]=randtest)? ");

      if (fgets (CommandLine, sizeof (CommandLine), stdin) == NULL)
        break;

      CommandLine [strlen (CommandLine) - 1] = 0; /* Remove LF character. */

      putchar ('\n');

      switch (tolower (CommandLine [0]))
      {
        case 'a':
          AddNodeWithName (&MyList, CommandLine+1);
          break;

        case 'c':
          DeleteAllSkipNodes (&MyList);
          break;

        case 'd':
          DeleteNodeByName (&MyList, CommandLine+1);
          break;

        case 'f':
          FindNodeWithName (&MyList, CommandLine+1);
          break;

        case 'h':
          PrintSkipListHeader (&MyList);
          WaitForKey ();
          break;

        case 'l':
          PrintFatNodesInList (&MyList);
          WaitForKey ();
          break;

        case 'i':
          n = atol (CommandLine + 1);
          printf ("Inserting %d random nodes.\n", n);
          AddRandomNodes (&MyList, n);
          break;

        case 'n':
          AddNamesToList (&MyList);
          break;

        case 'q':
          StopRunning = TRUE;
          break;

        case 'r':
          if (CommandLine[1] == '0')
          {
            printf ("Random number test with no cache, ");
            RandomLevelTest (NULL);
          }
          else
          {
            printf ("Random number test with list cache, ");
            RandomLevelTest (&MyList);
          }
          WaitForKey ();
          break;

        default:
          printf ("Unrecognized command letter in \"%s\".\n", CommandLine);
          WaitForKey ();
      }
    }
    printf ("Deallocating your list of %u nodes...\n", MyList.size);
    DeleteAllSkipNodes (&MyList);
  }

  if (SkipListBase != NULL)
    CloseLibrary (SkipListBase);
}

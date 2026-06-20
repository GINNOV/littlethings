/* Example program for using the SkipList.library from GNU C.  Given a file
 * name, it counts the number of different words in the file and shows how
 * many times each word is used.  Features an unlimited number of words
 * (except by free memory) and probabalisticly optimal counting.
 *
 * $Header: Big:Programming/C/SkipLists/RCS/WordCounter.c,v 1.2 1996/08/29 14:20:10 AGMS Exp $
 *
 * By Alexander G. M. Smith, agmsmith@achilles.net, July 1996.
 * Compiled with GNU C version 2.7.0, command line:
 *   gcc -v -noixemul -O2 -Wall WordCounter.c
 *
 * $Log: WordCounter.c,v $
 * Revision 1.2  1996/08/29  14:20:10  AGMS
 * Added sorted list of counts, showing how you can have a list with
 * duplicate key values by using a subkey.
 *
 * Revision 1.1  1996/08/19  17:45:38  AGMS
 * Initial revision
 */

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <proto/exec.h>
#include "SkipList.h"

APTR SkipListBase;


/* This structure is used in a list of all the words, in sorted order by word.
   Each one also has a counter for the number of times the word has been found
   in the input text. */

typedef struct WordCountStruct
{
  SkipNodeRecord  skipNode; /* Links skip nodes, must be at front of record. */
  ULONG count;   /* Number of times this word occurs in the input file. */
  char word [1]; /* A variable sized string, record size extended to fit. */
} WordCountRecord, *WordCountPointer;



/* This structure is used in a list of counts, with lower counts coming
   first.  For the cases with identical counts, the alphabetical order of the
   word being counted is used to determine the sub-order. */

typedef struct SortByCountStruct
{
  SkipNodeRecord  skipNode;  /* Links skip nodes, must be at front of record. */
  WordCountPointer wordPntr; /* Points to the word and count to use. */
} SortByCountRecord, *SortByCountPointer;



/******************************************************************************
 * This is a callback function that the skip list routines use to compare two
 * nodes in the sorted-by-word list.  Returns negative if word A < word B,
 * zero for A==B, and larger than zero for A>B.
 */

LONG CompareWordCountRecords (SkipNodePointer A, SkipNodePointer B)
{
  WordCountPointer WordA, WordB;

  WordA = (WordCountPointer) A;
  WordB = (WordCountPointer) B;

  return strcmp (WordA->word, WordB->word);
}



/******************************************************************************
 * This is a different callback function that the skip list routines use to
 * compare two nodes in the sorted-by-count list.  Returns negative if the
 * count of word A < count of word B, zero for A==B, and larger than zero for
 * A>B.  If two entries have the same count, the alphabetical order of the
 * associated words is used to break the tie.
 */

LONG CompareSortByCountRecords (SkipNodePointer A, SkipNodePointer B)
{
  SortByCountPointer SortA, SortB;
  long  CountDelta;

  SortA = (SortByCountPointer) A;
  SortB = (SortByCountPointer) B;

  CountDelta = SortA->wordPntr->count - SortB->wordPntr->count;

  if (CountDelta != 0)
    return CountDelta;

  return strcmp (SortA->wordPntr->word, SortB->wordPntr->word);
}



/******************************************************************************
 * Go through the input file parsing words and storing them in the given list.
 * Stops at end of file or when an IO error happens or when it runs out of
 * memory.
 */

void CountWords (SkipListPointer WordList, FILE *InputFile)
{
  WordCountPointer  ExistingWordNode;
  int               Letter;
  WordCountPointer  NewWordNode;
  int               WordSize;

  /* Create a search node record on the stack, with space for the longest
     possible word.  Also make a constant pointer to the Word string for easy
     access. */

  const int MAXWORDLENGTH = 511;
  struct
  {
    WordCountRecord countRecord;
    char spaceHolder [MAXWORDLENGTH];
  } SearchNode;
  char * const Word = SearchNode.countRecord.word;

  while (TRUE)
  {
    /* Read a word.  Skip over nonalphabetic characters, read alphabetic
       characters and stop when first nonalpha is hit. */

    WordSize = 0;

    while ((Letter = getc (InputFile)) != EOF && !ferror (InputFile))
    {
      Letter = tolower (Letter);
      if (isalpha (Letter))
      {
        if (WordSize < MAXWORDLENGTH)
          Word [WordSize++] = Letter;
      }
      else
      {
        /* Nonalphabetic, treat as word separators.  Skip over if no word yet,
           stop if there is a word. */

        if (WordSize > 0)
          break; /* This one signals end of the word. */
      }
    }

    if (WordSize == 0)
      return; /* Must have hit end of file, or an error. */

    Word [WordSize] = 0; /* End of string marker. */

    /* Is that word already in the list? */

    ExistingWordNode = (WordCountPointer) FindSkipNode (WordList,
    &SearchNode.countRecord.skipNode);

    if (ExistingWordNode != NULL)
      ExistingWordNode->count++;
    else
    {
      /* Allocate a list node with extra space past the end for the word
         string.  Note that the WordCountRecord already includes 1 character
         for the string size, which accounts for the NUL character at the end
         of the string. */

      NewWordNode = (WordCountPointer) AllocateSkipNode (WordList,
      sizeof (WordCountRecord) + WordSize, 0 /* Any memory type */);

      if (NewWordNode == NULL)
      {
        fprintf (stderr, "Ran out of memory while adding words.\n");
        return;
      }

      strcpy (NewWordNode->word, Word);
      NewWordNode->count = 1;

      InsertSkipNode (WordList, &NewWordNode->skipNode);
    }
  }
}



/******************************************************************************
 * Make a shadow list that has an entry for every word, except that the
 * entries are sorted by count, not word.
 */

void SortCounts (SkipListPointer WordList, SkipListPointer CountList)
{
  SortByCountPointer  CountNode;
  WordCountPointer    WordNode;

  WordNode = (WordCountPointer) WordList->levelPointers [SKIPLISTLEVELCAP-1];

  while (WordNode != NULL)
  {
    CountNode = (SortByCountPointer) AllocateSkipNode (CountList,
    sizeof (SortByCountRecord), 0 /* Any memory type */);

    if (CountNode == NULL)
    {
      fprintf (stderr, "Ran out of memory while sorting counts.\n");
      return;
    }

    CountNode->wordPntr = WordNode;

    InsertSkipNode (CountList, &CountNode->skipNode);

    WordNode = (WordCountPointer) WordNode->skipNode.next;
  }
}



/******************************************************************************
 * Print the list of words and their counts.  Also print the list of
 * sorted-by-counts words in a second column.
 */

void PrintWordsAndCounts (SkipListPointer WordList, SkipListPointer CountList)
{
  WordCountPointer WordNode;
  SortByCountPointer CountNode;

  WordNode = (WordCountPointer) WordList->levelPointers [SKIPLISTLEVELCAP-1];
  CountNode = (SortByCountPointer) CountList->levelPointers [SKIPLISTLEVELCAP-1];

  printf ("Sorted by Word                         Sorted by Count\n");
  printf ("=====================================  =====================================\n");

  while (WordNode != NULL && CountNode != NULL)
  {
    printf ("%-32s %4ld  %-32s %4ld\n", WordNode->word, WordNode->count,
    CountNode->wordPntr->word, CountNode->wordPntr->count);

    WordNode = (WordCountPointer) WordNode->skipNode.next;
    CountNode = (SortByCountPointer) CountNode->skipNode.next;
  }
}



int main (int argc, char *argv[])
{
  SkipListRecord CountList;
  FILE *InputFile;
  BOOL Success;
  SkipListRecord WordList;

  InputFile = NULL;
  Success = TRUE;

  SkipListBase = OpenLibrary (SKIPLISTLIBRARYNAME, 0 /* version */);
  if (SkipListBase == NULL)
  {
    Success = FALSE;
    fprintf (stderr, "Unable to open " SKIPLISTLIBRARYNAME "\n");
  }

  if (Success)
  {
    if (argc >= 2)
    {
      fprintf (stderr,
      "Opening file \"%s\" for input text to be word counted.\n", argv[1]);

      InputFile = fopen (argv[1], "r");

      if (InputFile == NULL)
      {
        Success = FALSE;
        fprintf (stderr, "Unable to open input file!\n");
      }
    }
    else /* No file name. */
    {
      Success = FALSE;
      fprintf (stderr, "Usage: %s filename\n"
      "Counts the number of times each word appears in the file.\n"
      "By Alexander G. M. Smith, 1996.  Public Domain.\n",
      argv[0]);
    }
  }

  if (Success)
  {
    InitSkipList (&WordList);
    WordList.compareUserData = CompareWordCountRecords;

    CountWords (&WordList, InputFile);

    InitSkipList (&CountList);
    CountList.compareUserData = CompareSortByCountRecords;

    SortCounts (&WordList, &CountList);

    PrintWordsAndCounts (&WordList, &CountList);

    fprintf (stderr, "Please wait, deallocating count list...\n");
    DeleteAllSkipNodes (&CountList);

    fprintf (stderr, "Please wait, deallocating word list...\n");
    DeleteAllSkipNodes (&WordList);
  }

  if (InputFile != NULL)
    fclose (InputFile);

  if (SkipListBase != NULL)
    CloseLibrary (SkipListBase);
}

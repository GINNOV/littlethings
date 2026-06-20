/*------------------------------------------------------------------
 * tokfile.h : tokenize the contents of a file
 *------------------------------------------------------------------
 * 02-13-93 originally by Patrick J. Mueller
 *------------------------------------------------------------------*/

#if !defined(TOKFILE_H_INCLUDED)
#define TOKFILE_H_INCLUDED

#define TOKFILE_MAX_LINE 512

typedef void * TokFileInfo;

TokFileInfo TokFileOpen(
   char *fileName
   );

char *TokFileNext(
   TokFileInfo tfi
   );

#endif

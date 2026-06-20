/*
 * binary.c
 *
 *  Created on: 1 may 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : binary.c
 *      Purpose  : Functions about binary source file
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2015 Frank Wille, (C)2015-2016 Nicolas Bastien
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "ira.h"
#include "amiga_hunks.h"
#include "ira_2.h"
#include "supp.h"

void Read68kBinary(ira_t *ira)
{
   /* In binary mode, sourceFile and binaryFile will be the same file.
    * IRA must keep it because we don't want to delete sourceFile at exit. */
   ira->params.pFlags |= KEEP_BINARY;

   /* Previously allocated string for binaryName is now useless,
    * because pointer will be overwritten by sourceName's */
   free(ira->filenames.binaryName);
   ira->filenames.binaryName = ira->filenames.sourceName;

   /* Let's behave like this:
    * The content of binary file IS the content of an unique HUNK_CODE hunk */
   ira->hunkCount = 1;
   ira->hunksMemoryType = mycalloc(sizeof(uint16_t));
   ira->hunksMemoryAttrs = mycalloc(sizeof(uint32_t));
   ira->hunksSize = mycalloc(sizeof(uint32_t));
   ira->hunksType = mycalloc(sizeof(uint32_t));
   ira->hunksOffs = mycalloc(sizeof(uint32_t));

   ira->hunksSize[0] = FileLength(ira->filenames.binaryName);
   ira->hunksOffs[0] = ira->params.prgStart;
   ira->hunksType[0] = HUNK_CODE;

   ira->firstHunk = 0;
   ira->lastHunk = 0;
}

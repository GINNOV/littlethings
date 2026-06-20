#ifndef FASTARITH_H
#define FASTARITH_H

#include <crbinc/bbitio.h>

/*
 * Notez:
 *
 *  "totrange" must be <= FAI->FastArithCumProbMax at all times !!
 *
 */

/*
 *
 * you must call BitIO_InitRead & BitIO_FlushWrite yourself!
 *
 */

struct FAI
  {
  long FastArithCumProbMax;
  long FastArithCumProbMaxSafe; /* 256 less than FastArithCumProbMax */

  long Private;
  };

extern struct FAI * FastArithInit(struct BitIOInfo * BII);
extern void FastArithCleanUp(struct FAI * FAI);

extern void FastArithEncodeCInit(struct FAI * FAI);
extern void FastArithEncodeRange(struct FAI * FAI,long low,long high,long totrange);
extern void FastArithEncodeCDone(struct FAI * FAI);

extern void FastArithDecodeCInit(struct FAI * FAI);
extern void FastArithDecodeRange(struct FAI * FAI,long *target,long totrange);
extern void FastArithDecodeRangeRemove(struct FAI * FAI,long low,long high,long totrange);
extern void FastArithDecodeCDone(struct FAI * FAI);

#endif

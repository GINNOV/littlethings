#ifndef CACMarith_H
#define CACMarith_H

#include <crbinc/bbitio.h>

/*
 * Notez:
 *
 *  "totrange" must be <= CACMFAI->CACMarithCumProbMax at all times !!
 *
 */

/*
 *
 * you must call BitIO_InitRead & BitIO_FlushWrite yourself!
 *
 */

typedef uword arithcode;

struct CACMFAI
  {
  long CACMarithCumProbMax;

  struct BitIOInfo * BII; 

  long underflow_bits;
  arithcode code;
  arithcode low; 
  arithcode high;
  };

extern struct CACMFAI * CACMarithInit(struct BitIOInfo * BII);
extern void CACMarithCleanUp(struct CACMFAI * CACMFAI);

extern void CACMarithEncodeCInit(struct CACMFAI * CACMFAI);
extern void CACMarithEncodeRange(struct CACMFAI * CACMFAI,long low,long high,long totrange);
extern void CACMarithEncodeCDone(struct CACMFAI * CACMFAI);

extern void CACMarithDecodeCInit(struct CACMFAI * CACMFAI);
extern void CACMarithDecodeRange(struct CACMFAI * CACMFAI,long *target,long totrange);
extern void CACMarithDecodeRangeRemove(struct CACMFAI * CACMFAI,long low,long high,long totrange);
extern void CACMarithDecodeCDone(struct CACMFAI * CACMFAI);


#ifndef FASTARITH_H
#define FASTARITH_H

/* patch to make CACM look like MACM */

#include <crbinc/cacmari.h>

#define FAI CACMFAI
#define FastArithInit CACMarithInit
#define FastArithCleanUp CACMarithCleanUp

#define FastArithCumProbMax CACMarithCumProbMax

#define FastArithEncodeCInit CACMarithEncodeCInit
#define FastArithEncodeRange CACMarithEncodeRange
#define FastArithEncodeCDone CACMarithEncodeCDone

#define FastArithDecodeCInit CACMarithDecodeCInit
#define FastArithDecodeRange CACMarithDecodeRange
#define FastArithDecodeRangeRemove CACMarithDecodeRangeRemove
#define FastArithDecodeCDone CACMarithDecodeCDone

#endif /* FASTARITH */

#endif /* CACM */

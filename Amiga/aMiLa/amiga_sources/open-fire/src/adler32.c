#include "adler32.h"
#include <ace/utils/file.h>
#include <ace/managers/log.h>
#include <ace/managers/system.h>

#define ADLER32_MODULO 65521

ULONG adler32array(const UBYTE *pData, ULONG ulDataSize) {
	ULONG a = 1, b = 0;
	for(ULONG i = 0; i < ulDataSize; ++i) {
		a += pData[i];
		if(a >= ADLER32_MODULO) {
			a -= ADLER32_MODULO;
		}
		b += a;
		if(b >= ADLER32_MODULO) {
			b -= ADLER32_MODULO;
		}
	}
	return (b << 16) | a;
}

ULONG adler32file(const char *szPath) {
	systemUse();
	logBlockBegin("adler32File(szPath: %s)", szPath);
	tFile *pFile = fileOpen(szPath, "rb");
	ULONG a = 1, b = 0;
	if(!pFile) {
		logWrite("ERR: File doesn't exist\n");
		goto fail;
	}
	UBYTE ubBfr;
	while(!fileIsEof(pFile)) {
		fileRead(pFile, &ubBfr, 1);
		a += ubBfr;
		if(a >= ADLER32_MODULO) {
			a -= ADLER32_MODULO;
		}
		b += a;
		if(b >= ADLER32_MODULO) {
			b -= ADLER32_MODULO;
		}
	}
fail:
	fileClose(pFile);
	logBlockEnd("adler32File()");
	systemUnuse();
	return (b << 16) | a;
}

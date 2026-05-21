#include "cache.h"
#include "adler32.h"
#include <ace/managers/log.h>
#include <ace/utils/file.h>

UBYTE cacheIsValid(const char *szPath) {
	char szFullPath[100];

	// Check for precalc
	sprintf(szFullPath, "precalc/%s.adl", szPath);
	tFile *pChecksumFile = fileOpen(szFullPath, "rb");
	if(!pChecksumFile) {
		logWrite("WARN: Checksum doesn't exist!\n");
		return 0;
	}
	ULONG ulAdlerPrev;
	fileRead(pChecksumFile, &ulAdlerPrev, sizeof(ULONG));
	fileClose(pChecksumFile);

	// Check if cached file exists
	sprintf(szFullPath, "precalc/%s", szPath);
	tFile *pFile = fileOpen(szFullPath, "rb");
	if(!pFile) {
		logWrite("WARN: Cached file doesn't exist!\n");
		return 0;
	}
	fileClose(pFile);

	// Calc source file checksum
	sprintf(szFullPath, "data/%s", szPath);
	ULONG ulAdlerCurr = adler32file(szFullPath);

	// Check if adler is same
	if(ulAdlerCurr == ulAdlerPrev) {
		return 1;
	}
	logWrite("WARN: Adler mismatch for %s!\n", szPath);
	return 0;
}

void cacheGenerateChecksum(const char *szPath) {
	char szFullPath[100];
	sprintf(szFullPath, "data/%s", szPath);
	ULONG ulAdler = adler32file(szFullPath);

	sprintf(szFullPath, "precalc/%s.adl", szPath);
	FILE *pChecksumFile = fileOpen(szFullPath, "wb");
	fileWrite(pChecksumFile, &ulAdler, sizeof(ULONG));
	fileClose(pChecksumFile);
}

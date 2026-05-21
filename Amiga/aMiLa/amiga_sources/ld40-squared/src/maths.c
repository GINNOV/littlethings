#include "maths.h"
#include <ace/types.h>
#include <ace/utils/file.h>

fix16_t g_pSin[256];

void mathsInit(void) {
	// Read sine table
	// Generated using libfixmath with floats enabled, dumped to file
	tFile *pSinFile = fileOpen("data/sin.dat", "rb");
	for(UWORD i = 0; i < 256; ++i) {
		fileRead(pSinFile, &g_pSin[i], sizeof(fix16_t));
	}
	fileClose(pSinFile);
}

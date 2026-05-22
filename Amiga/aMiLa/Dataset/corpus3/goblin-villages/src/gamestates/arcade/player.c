#include "player.h"

void playerListCreate(void) {
	UBYTE ubPlayer = g_sGameConfig.ubPlayerCount;
	tPlayer *pPlayer;
	tPlayer *pNext = 0;
	// musza byc dodawani w kolejnosci bo w takiej kolejnosci graja
	// czyli ostatnio dodany jest nastepny na liscie
	while (ubPlayer--) {
		if (g_sGameConfig.pPlayersSelected[ubPlayer]) {
			pPlayer = allocFastFirst(sizeof(tPlayer));
			pPlayer->ubIdx = ubPlayer;
			pPlayer->uwScore = 0;
			pPlayer->ubPawnsLeft = g_sGameConfig.ubPawnsPerPlayer;
			
			pPlayer->pNext = pNext;
			pNext = pPlayer;
		}
	}
	g_sGameConfig.pPlayerFirst = pPlayer;
}

void playerListDestroy(void) {
	tPlayer *pNext;
	tPlayer *pPlayer = g_sGameConfig.pPlayerFirst;
	while (pPlayer) {
		pNext = pPlayer->pNext;

		freeMem(pPlayer, sizeof(tPlayer));

		pPlayer = pNext;
	}
}
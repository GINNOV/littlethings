/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "blob_anim.h"
#include "map.h"
#include "game.h"
#include "assets.h"
#include "player.h"

#define QUEUE_ELEMENTS_MAX 10

typedef struct tQueueElement {
	tNode *pNode;
	UBYTE isDrawnOnce;
	BYTE bFrame;
} tQueueElement;

typedef struct tQueue {
	tQueueElement *pBeg, *pEnd, *pWrap;
	tQueueElement pElements[QUEUE_ELEMENTS_MAX];
} tQueue;

static tQueue s_sQueue;

static void advanceFrameForNode(tQueueElement *pElement) {
	if(pElement->isDrawnOnce) {
		pElement->isDrawnOnce = 0;
		if(++pElement->bFrame >= BLOB_FRAME_COUNT) {
			// The element which ends right now should always be a node
			// at the beginning of the queue.
			if(pElement != s_sQueue.pBeg) {
				logWrite("ERR: Queue element delete not on beginning of queue");
			}

			if(++s_sQueue.pBeg >= s_sQueue.pWrap) {
				s_sQueue.pBeg = &s_sQueue.pElements[0];
			}
		}
	}
	else {
		pElement->isDrawnOnce = 1;
	}
}

void blobAnimReset(void) {
	s_sQueue.pBeg = &s_sQueue.pElements[0];
	s_sQueue.pEnd = s_sQueue.pBeg;
	s_sQueue.pWrap = &s_sQueue.pElements[QUEUE_ELEMENTS_MAX];
}

void blobAnimQueueProcess(void) {
	tQueueElement *pElement = s_sQueue.pBeg;
	while(pElement != s_sQueue.pEnd) {
		const tNode *pNode = pElement->pNode;
		if(pElement->bFrame >= 0) {
			gameDrawBlobAt(
				nodeToTile(pNode), pElement->bFrame,
				pNode->sPosTile.ubX * MAP_TILE_SIZE, pNode->sPosTile.ubY * MAP_TILE_SIZE
			);
		}
		advanceFrameForNode(pElement);
		if(++pElement >= s_sQueue.pWrap) {
			pElement = &s_sQueue.pElements[0];
		}
	}
}

void blobAnimAddToQueue(tNode *pNode) {
	tQueueElement *pElement = s_sQueue.pEnd;
	pElement->pNode = pNode;
	pElement->bFrame = -4;
	pElement->isDrawnOnce = 0;
	if(++s_sQueue.pEnd >= s_sQueue.pWrap) {
		s_sQueue.pEnd = &s_sQueue.pElements[0];
	}
}

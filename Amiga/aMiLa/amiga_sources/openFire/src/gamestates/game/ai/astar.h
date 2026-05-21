#ifndef OF_GAMESTATES_GAME_AI_ASTAR_H
#define OF_GAMESTATES_GAME_AI_ASTAR_H

#include <ace/types.h>
#include "gamestates/game/ai/heap.h"
#include "gamestates/game/ai/ai.h"

#define ASTAR_STATE_OFF 0
#define ASTAR_STATE_LOOPING 1
#define ASTAR_STATE_DONE 2

#define ASTAR_ROUTE_NODE_MAX 20

/**
 * Pathfinding route struct.
 * TOOD implement as stack
 */
typedef struct _tRoute {
	UBYTE ubNodeCount; ///< Number of nodes in route.
	UBYTE ubCurrNode; ///< Currently processed route node idx.
	tAiNode *pNodes[ASTAR_ROUTE_NODE_MAX]; ///< First is dest
} tRoute;

typedef struct {
	UBYTE ubState; ///< See ASTAR_STATE_* defines
	tHeap *pFrontier;
	tAiNode *pCameFrom[AI_MAX_NODES];
	UWORD pCostSoFar[AI_MAX_NODES];
	tAiNode *pNodeDst;
	tAiNode *pNodeCurr;
	UWORD uwCurrNeighbourIdx;
	tRoute sRoute;
} tAstarData;

/**
 * Allocates data for A* algorithm.
 * @return Newly allocated A* data struct.
 */
tAstarData *astarCreate(void);

/**
 * Frees A* data structure.
 * @param pNav A* data structure to be freed.
 */
void astarDestroy(tAstarData *pNav);

/**
 * Prepares A* initial conditions.
 * @param pNav A* data struct to be used.
 * @param pNodeSrc Route's first node.
 * @param pNodeDst Route's destination node.
 */
void astarStart(tAstarData *pNav, tAiNode *pNodeSrc, tAiNode *pNodeDst);

/**
 *
 */
UBYTE astarProcess(tAstarData *pNav);

#endif // OF_GAMESTATES_GAME_AI_ASTAR_H

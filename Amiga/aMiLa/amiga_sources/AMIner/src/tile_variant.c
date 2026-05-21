#include "tile_variant.h"
#include <ace/utils/bitmap.h>
#include "core.h"
#include "tile.h"
#include "assets.h"

#define TILE_VARIANT_COUNT 10
#define BYTES_PER_TILE (TILE_SIZE * (TILE_SIZE / 8) * 5)

static tBitMap *s_pCheckpointTiles;
static tTileVariant s_eCurrentVariant;

void tileVariantManagerCreate(void) {
	s_pCheckpointTiles = bitmapCreateFromFd(GET_SUBFILE_PREFIX("checkpoint.bm"), 1);
	s_eCurrentVariant = TILE_VARIANT_DEFAULT;
}

void tileVariantManagerDestroy(void) {
	bitmapDestroy(s_pCheckpointTiles);
}

void tileVariantChangeTo(tTileVariant eVariant) {
	if(eVariant == s_eCurrentVariant) {
		return;
	}
	s_eCurrentVariant = eVariant;
	switch(eVariant) {
		case TILE_VARIANT_CHECKPOINT:
			memcpy(
				&g_pMainBuffer->pTileSet->Planes[0][TILE_CHECKPOINT_1 * BYTES_PER_TILE],
				s_pCheckpointTiles->Planes[0],
				TILE_VARIANT_COUNT * BYTES_PER_TILE
			);
			break;
		case TILE_VARIANT_FINISH:
			memcpy(
				&g_pMainBuffer->pTileSet->Planes[0][TILE_CHECKPOINT_1 * BYTES_PER_TILE],
				&s_pCheckpointTiles->Planes[0][TILE_VARIANT_COUNT * BYTES_PER_TILE],
				TILE_VARIANT_COUNT * BYTES_PER_TILE
			);
			break;
		case TILE_VARIANT_CAMPAIGN:
			bitmapLoadFromFd(
				g_pMainBuffer->pTileSet, GET_SUBFILE_PREFIX("campaign.bm"),
				0, TILE_CHECKPOINT_1 * TILE_SIZE
			);
			break;
		default:
			break;
	}
}

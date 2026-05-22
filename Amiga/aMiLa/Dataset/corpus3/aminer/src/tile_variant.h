/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _TILE_VARIANT_H_
#define _TILE_VARIANT_H_

typedef enum tTileVariant {
	TILE_VARIANT_DEFAULT, // Unpredictable - placeholder tiles loaded with tileset
	TILE_VARIANT_CHECKPOINT,
	TILE_VARIANT_FINISH,
	TILE_VARIANT_CAMPAIGN,
} tTileVariant;

void tileVariantManagerCreate(void);

void tileVariantManagerDestroy(void);

void tileVariantChangeTo(tTileVariant eVariant);

#endif // _TILE_VARIANT_H_

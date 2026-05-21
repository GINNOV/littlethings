/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef ASSETS_H
#define ASSETS_H

#include <ace/managers/ptplayer.h>
#include <ace/utils/bitmap.h>
#include <ace/utils/pak_file.h>
#include <ace/utils/disk_file.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ASSETS_GAME_MOD_COUNT 11

extern tPtplayerSfx *g_pSfxDrill;
extern tPtplayerSfx *g_pSfxOre;
extern tPtplayerSfx *g_pSfxPenalty;
extern tPtplayerSfx *g_pSfxFlyLoop;
extern tPtplayerSfx *g_pSfxThud;
extern tPtplayerSfx *g_pSfxGate;
extern tPtplayerSfx *g_pSfxRune;
extern tPtplayerSfx *g_pSfxQuake;

extern tPtplayerMod *g_pGameMods[ASSETS_GAME_MOD_COUNT];
extern tPtplayerMod *g_pMenuMod;
extern tPtplayerSamplePack *g_pModSampleData;

extern tBitMap *g_pBombMarker;
extern tBitMap *g_pBombMarkerMask;
extern tBitMap *g_pTileOverlays;
extern tBitMap *g_pTileOverlayMasks;
extern tFont *g_pFont;

#if defined(USE_PAK_FILE)
extern tPakFile *g_pPakFile;
#define SUBFILE_PREFIX ""
#define GET_SUBFILE(szPath) pakFileGetFile(g_pPakFile, szPath)
#else
#define SUBFILE_PREFIX "data/"
#define GET_SUBFILE(szPath) diskFileOpen(szPath, DISK_FILE_MODE_READ, 0)
#endif
#define GET_SUBFILE_PREFIX(szPath) GET_SUBFILE(SUBFILE_PREFIX szPath)

void assetsAudioCreate(void);

void assetsAudioDestroy(void);

void assetsMarkersCreate(void);

void assetsMarkersDestroy(void);

void assetsTileOverlayCreate(void);

void assetsTileOverlayDestroy(void);

#ifdef __cplusplus
}
#endif


#endif // ASSETS_H

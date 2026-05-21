/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_COLOR_H
#define GERMZ_COLOR_H

// Player colors in palette.
#define COLOR_P1_BRIGHT 10
#define COLOR_P2_BRIGHT 14
#define COLOR_P3_BRIGHT 18
#define COLOR_P4_BRIGHT 22

#define COLOR_CONSOLE_BG 2

// Special color. Used in battle menu for minimap background.
#define COLOR_SPECIAL_1 6
#define COLOR_SPECIAL_2 7

#define RGB8TO4(r,g,b) ((((r) / 17) << 8) | (((g) / 17) << 4) | (((b) / 17) << 0))

#endif // GERMZ_COLOR_H

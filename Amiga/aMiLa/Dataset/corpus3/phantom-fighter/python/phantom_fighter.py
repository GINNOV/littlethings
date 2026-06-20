#!/usr/bin/env python3
"""
Phantom Fighter — Python/Pygame recreation
All 5 Levels

Original game by Billy (Emerald Software, 1988)
Published by Martech (UK) / Broderbund (USA as "If It Moves, Shoot It")
"""

import pygame
import random
import math
import sys
import os
from pathlib import Path

# ── Constants ─────────────────────────────────────────────────────

INTERNAL_W = 320
INTERNAL_H = 200
SCALE = 3
SCREEN_W = INTERNAL_W * SCALE
SCREEN_H = INTERNAL_H * SCALE
FPS = 60

PANEL_H = 24
VIEW_W = INTERNAL_W
VIEW_H = INTERNAL_H - PANEL_H

SCROLL_TICKS = 3
SCROLL_SPEED = 1

PLAYER_START_X = 150
PLAYER_START_Y_H = 80   # Horizontal levels
PLAYER_START_Y_V = 130  # Vertical levels (near bottom)
PLAYER_CENTER_FRAME = 3
PLAYER_MAX_FRAMES = 11
PLAYER_BANK_DELAY = 6
STARTING_LIVES = 5
MAX_LIVES = 9

BULLET_SPEED = 9
MAX_BULLETS = 6

EXTRA_LIFE_FIRST = 10000
EXTRA_LIFE_INTERVAL = 20000
ALIEN_SCORE_FIRST = 200
ALIEN_SCORE_OTHER = 20
BUG_SCORE = 1000
BOSS_SCORE = 5000

WAVE_SPAWN_INTERVAL = 180
ALIEN_FIRE_CHANCE = 25
BOSS_FIRE_CHANCE = 50

TOKEN_SPAWN_INTERVAL = 500
TOKEN_TYPES = ["FASTER", "LASER", "DOUBLE", "PLASMA", "SIDES", "HOMERS"]

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
YELLOW = (255, 255, 0)
RED = (255, 0, 0)
CYAN = (0, 255, 255)
GREEN = (0, 255, 0)
PANEL_BG = (17, 17, 68)


# ── Wave Movement Patterns (from patterns.c) ─────────────────────
# Each element: (delay_ticks, frame, dx, dy)
# First element is initial position: (small_delay, frame, start_x, start_y)

PATTERN_0 = [
    (2, 5, 319, 11), (25, 5, -3, 5), (10, 6, -5, 3), (11, 6, -6, 0),
    (10, 7, -5, -3), (11, 0, -2, -5), (10, 1, 2, -6), (9, 2, 5, -3),
    (11, 2, 6, 0), (11, 3, 5, 3), (9, 4, 2, 6), (8, 5, -1, 6),
    (7, 6, -4, 3), (12, 6, -5, 1), (12, 7, -6, 0), (6, 7, -5, -3),
    (9, 0, -2, -6), (7, 0, 0, -6), (7, 1, 3, -5), (6, 2, 5, -3),
    (15, 3, 6, 0), (12, 3, 4, 3), (5, 4, 3, 5), (8, 4, 0, 6),
    (8, 5, -2, 5), (7, 6, -6, 2), (8, 6, -6, 0), (12, 7, -6, -1),
    (10, 7, -5, -3), (10, 7, -5, -3), (14, 7, -5, -3),
]

PATTERN_1 = [
    (2, 4, 135, -24), (21, 4, 0, 6), (7, 5, 0, 6), (6, 5, -2, 5),
    (7, 6, -5, 2), (4, 7, -6, 0), (3, 7, -7, -1), (3, 7, -5, -3),
    (3, 0, -3, -6), (3, 0, 0, -7), (3, 1, 3, -6), (4, 2, 4, -4),
    (4, 2, 6, -2), (4, 2, 6, 0), (5, 3, 6, 2), (6, 4, 3, 5),
    (6, 5, 0, 6), (4, 5, -3, 5), (3, 6, -6, 2), (7, 7, -6, 0),
    (3, 7, -6, -3), (3, 0, -4, -5), (5, 0, -1, -7), (11, 1, 0, -6),
    (5, 1, 4, -5), (9, 2, 6, -1), (7, 2, 6, -1), (29, 2, 6, 0),
    (29, 2, 6, 0), (33, 2, 6, 0),
]

PATTERN_2 = [
    (2, 4, 169, -24), (21, 4, 0, 6), (7, 4, 1, 6), (6, 4, 3, 5),
    (5, 3, 6, 2), (3, 3, 6, 0), (3, 2, 6, -4), (3, 2, 6, -3),
    (3, 1, 3, -5), (3, 1, 0, -6), (2, 0, -2, -8), (3, 7, -5, -3),
    (3, 7, -6, -2), (4, 6, -6, 0), (3, 6, -7, 3), (19, 6, -5, 3),
    (5, 6, -6, 1), (5, 7, -6, -1), (5, 0, -4, -5), (4, 0, 0, -6),
    (4, 1, 3, -6), (6, 2, 5, -3), (9, 2, 6, -1), (9, 2, 5, -1),
    (8, 2, 5, -3), (4, 1, 5, -5), (4, 1, 5, -5), (8, 1, 5, -5),
]

PATTERN_3 = [
    (2, 4, 144, -24), (11, 4, 0, 6), (3, 5, -2, 6), (2, 6, -6, 4),
    (14, 6, -6, 0), (2, 6, -7, 4), (2, 4, 3, 7), (4, 3, 6, 1),
    (32, 2, 6, 0), (3, 3, 6, 2), (2, 4, 3, 5), (1, 5, -5, 9),
    (2, 6, -8, 2), (38, 6, -6, 0), (3, 5, -3, 5), (3, 4, 4, 5),
    (12, 3, 5, 3), (6, 3, 6, 0), (4, 2, 6, -3), (3, 2, 5, -5),
    (4, 1, 2, -6), (7, 1, 2, -6), (16, 0, 0, -6), (16, 0, 0, -6),
    (20, 0, 0, -6),
]

PATTERN_4 = [
    (2, 3, -17, -8), (49, 3, 5, 2), (5, 4, 4, 5), (4, 4, 2, 6),
    (4, 5, 0, 6), (4, 6, -5, 5), (7, 6, -6, 0), (25, 6, -6, 0),
    (5, 7, -5, -1), (4, 0, -4, -4), (4, 0, 0, -6), (5, 2, 4, -4),
    (6, 2, 6, -2), (31, 2, 5, -1), (2, 1, 5, -6), (3, 1, 1, -6),
    (2, 0, -3, -8), (2, 7, -7, -2), (3, 6, -7, 0), (3, 6, -5, 3),
    (2, 5, -3, 7), (27, 5, 0, 6), (27, 5, 0, 6), (31, 5, 0, 6),
]

PATTERN_5 = [
    (2, 2, -24, 17), (44, 2, 6, 0), (5, 3, 6, 0), (2, 3, 8, 2),
    (2, 3, 5, 5), (2, 4, 1, 6), (2, 5, -3, 7), (2, 6, -7, 2),
    (2, 7, -8, -2), (2, 0, -5, -5), (2, 0, 0, -8), (2, 1, 3, -6),
    (2, 2, 7, -3), (2, 3, 6, 1), (2, 3, 6, 3), (2, 4, 5, 6),
    (20, 4, 0, 6), (4, 5, -1, 6), (3, 5, -4, 5), (24, 6, -6, 0),
    (11, 7, -6, -1), (5, 0, -4, -5), (5, 0, -1, -6), (5, 1, 1, -6),
    (4, 2, 5, -4), (5, 2, 7, -1), (6, 3, 6, 0), (5, 3, 6, 2),
    (3, 4, 4, 6), (4, 5, 0, 6), (3, 5, -4, 6), (5, 6, -5, 4),
    (7, 6, -6, 1), (16, 6, -6, 0), (16, 6, -6, 0), (61, 3, 4, 3),
]

PATTERN_6 = [
    (2, 0, 283, 199), (24, 0, 0, -6), (4, 0, -1, -6), (3, 7, -6, -4),
    (4, 7, -7, 0), (25, 6, -6, 0), (6, 6, -6, 0), (4, 5, -4, 4),
    (3, 5, -1, 7), (16, 4, 0, 6), (5, 4, 3, 5), (5, 3, 7, 1),
    (8, 3, 6, 0), (5, 2, 6, -2), (3, 1, 2, -5), (21, 1, 1, -6),
    (3, 1, 4, -6), (3, 2, 6, -2), (4, 3, 6, 1), (3, 3, 5, 2),
    (5, 4, 2, 5), (23, 4, 0, 6), (23, 4, 0, 6), (27, 4, 0, 6),
]

PATTERN_7 = [
    (2, 0, 17, 199), (14, 0, 0, -6), (3, 1, 3, -5), (3, 2, 6, -3),
    (7, 2, 6, -1), (13, 2, 6, 0), (12, 2, 6, 0), (5, 3, 6, 1),
    (3, 2, 6, -2), (4, 1, 1, -5), (2, 0, -1, -7), (3, 7, -5, -4),
    (3, 7, -7, 0), (16, 7, -6, 0), (4, 6, -6, 1), (3, 5, -4, 5),
    (5, 5, -2, 6), (8, 5, 0, 6), (3, 4, 1, 7), (5, 4, 4, 4),
    (6, 3, 4, 3), (11, 3, 5, 1), (11, 3, 5, 1), (15, 3, 5, 1),
]

PATTERN_8 = [
    (2, 0, 281, 199), (12, 0, 0, -6), (3, 0, -2, -5), (3, 7, -5, -5),
    (3, 7, -5, -3), (4, 7, -7, -1), (23, 6, -6, 0), (6, 7, -6, 0),
    (3, 7, -6, -3), (3, 0, -1, -7), (3, 1, 1, -6), (2, 2, 6, -5),
    (3, 2, 7, -1), (15, 2, 6, 0), (4, 3, 7, 1), (3, 4, 5, 5),
    (4, 4, 2, 5), (3, 4, 0, 7), (3, 5, -2, 6), (6, 5, -3, 5),
    (7, 6, -4, 3), (12, 6, -5, 3), (12, 6, -5, 3), (16, 6, -5, 3),
]

PATTERN_9 = [
    (2, 3, -16, 13), (26, 3, 4, 3), (7, 3, 6, 2), (5, 3, 6, 0),
    (5, 2, 5, -3), (5, 1, 3, -5), (3, 0, 0, -7), (4, 0, -3, -5),
    (4, 7, -6, -3), (6, 7, -6, 0), (5, 6, -7, 1), (4, 6, -5, 4),
    (4, 5, 0, 7), (15, 4, 0, 6), (4, 4, 4, 4), (3, 3, 6, 3),
    (12, 2, 6, 0), (11, 2, 5, -3), (4, 1, 4, -5), (11, 1, 1, -6),
    (4, 0, -2, -7), (7, 7, -5, -2), (27, 6, -6, 0), (5, 6, -5, 3),
    (4, 5, -4, 6), (4, 5, 0, 7), (8, 4, 1, 6), (5, 4, 1, 6),
    (9, 3, 5, 2), (37, 3, 6, 0), (37, 3, 6, 0), (41, 3, 6, 0),
]

PATTERN_10 = [
    (1, 2, 148, -15), (55, 2, 0, 3), (1, 2, 0, 4), (2, 2, 1, 3),
    (1, 2, 0, 4), (3, 1, 2, 2), (1, 2, 1, 3), (4, 1, 3, 1),
    (1, 1, 1, 1), (17, 7, 3, 0), (1, 7, 4, 0), (4, 7, 3, -1),
    (1, 6, 1, -3), (2, 6, 2, -2), (1, 6, 1, -2), (2, 5, 0, -3),
    (1, 6, 1, -4), (12, 5, 0, -3), (1, 5, 0, -4), (2, 5, -1, -3),
    (1, 5, -1, -4), (2, 5, -2, -3), (1, 5, -1, -2), (4, 4, -3, -1),
    (1, 4, -1, -1), (16, 3, -3, 0), (1, 3, -2, 0), (2, 4, -3, -1),
    (1, 4, -4, -1), (2, 4, -2, -2), (1, 4, -3, -1), (3, 5, -1, -3),
    (1, 6, 1, -2), (11, 5, 0, -3), (1, 5, 0, -4), (4, 5, -1, -3),
    (1, 4, -2, -1), (2, 4, -2, -2), (1, 4, -2, -2), (3, 4, -3, -1),
    (1, 3, -4, 0), (27, 3, -3, 0), (1, 3, -3, 0), (4, 3, -3, 1),
    (1, 3, -3, 0), (3, 3, -3, 2), (1, 2, -1, 2), (5, 2, -1, 3),
    (1, 2, -1, 1), (32, 2, 0, 3), (1, 2, 0, 2), (4, 2, 1, 3),
    (1, 2, 0, 3), (3, 2, 2, 3), (1, 1, 1, 1), (5, 1, 3, 1),
    (1, 7, 3, -1), (15, 7, 3, 0), (1, 1, 2, 1), (4, 7, 3, -1),
    (1, 6, 1, -3), (3, 6, 2, -2), (1, 6, 1, -3), (4, 6, 1, -3),
    (1, 5, -1, -2), (16, 5, 0, -3), (1, 5, 0, -2), (1, 5, -1, -4),
    (1, 5, 0, -3), (1, 4, -3, -3), (1, 4, -2, -2), (3, 4, -3, -1),
    (1, 3, -4, 0), (1, 4, -3, -2), (1, 4, -2, -2), (1, 5, 0, -4),
    (1, 5, 0, -3), (21, 5, 0, -3), (5, 5, 0, -4),
]

ALL_PATTERNS = [
    PATTERN_0, PATTERN_1, PATTERN_2, PATTERN_3, PATTERN_4, PATTERN_5,
    PATTERN_6, PATTERN_7, PATTERN_8, PATTERN_9, PATTERN_10,
]


# ── Boss Patterns ────────────────────────────────────────────────
# Format: (delay, unused, dx, dy) — first element is (0, 0, startX, startY)

BOSS_PATTERN_0 = [  # Level 0: rectangular patrol
    (0, 0, 240, 10), (90, 0, 0, 1), (115, 0, -2, 0),
    (90, 0, 0, -1), (115, 0, 2, 0),
]
BOSS_PATTERN_1A = [  # Level 1: vertical oscillation
    (0, 0, 10, 10), (50, 0, 0, 2), (10, 0, 0, 0), (50, 0, 0, -2),
]
BOSS_PATTERN_1B = [  # Level 1: horizontal oscillation
    (0, 0, 246, 10), (50, 0, -2, 0), (10, 0, 0, 0), (50, 0, 2, 0),
]
BOSS_PATTERN_4A = [  # Level 4: large rect CW
    (0, 0, 10, 10), (75, 0, 0, 2), (123, 0, 2, 0),
    (75, 0, 0, -2), (123, 0, -2, 0),
]
BOSS_PATTERN_4B = [  # Level 4: large rect CCW
    (0, 0, 246, 150), (75, 0, 0, -2), (123, 0, -2, 0),
    (75, 0, 0, 2), (123, 0, 2, 0),
]

# Lava ball paths (level 3) — parabolic arcs, loop_reset=True
LAVABALL_LEFT = [
    (2, 10, 41, 33),
    (1, 10, 1, 8), (1, 10, 1, 7), (1, 10, 2, 7), (1, 10, 1, 6),
    (1, 10, 2, 7), (1, 10, 1, 6), (1, 10, 2, 7), (1, 10, 1, 6),
    (1, 10, 2, 7), (1, 10, 1, 6), (1, 10, 2, 7), (1, 10, 2, 6),
    (1, 9, 3, 6), (1, 10, 2, 6), (1, 9, 3, 6), (1, 9, 3, 6),
    (1, 9, 5, 6), (1, 9, 4, 5), (1, 8, 5, 4), (1, 8, 5, 4),
    (1, 7, 7, 3), (1, 8, 6, 3), (1, 7, 8, 2), (1, 7, 8, 1),
    (1, 7, 8, 1), (1, 6, 8, 0), (1, 6, 8, -1), (1, 6, 8, 0),
    (1, 6, 8, -1), (1, 6, 8, 0), (1, 6, 8, -1), (1, 6, 7, -1),
    (2, 6, 8, -1), (1, 6, 7, -2), (13, 6, 8, -1), (1, 3, 2, -6),
]
LAVABALL_RIGHT = [
    (2, 10, 255, 33),
    (1, 10, -2, 7), (1, 9, -1, 7), (1, 10, -2, 7), (1, 10, -1, 6),
    (1, 10, -2, 8), (1, 9, -1, 7), (1, 10, -2, 8), (1, 10, -2, 8),
    (1, 10, -2, 8), (1, 10, -2, 8), (1, 10, -3, 8), (1, 10, -3, 7),
    (1, 10, -4, 7), (1, 10, -3, 7), (1, 11, -5, 7), (1, 11, -5, 6),
    (1, 12, -7, 4), (1, 12, -6, 4), (1, 13, -8, 2), (1, 12, -7, 2),
    (1, 12, -7, 2), (1, 13, -7, 1), (1, 13, -9, 0), (1, 13, -8, 0),
    (1, 14, -9, -1), (1, 13, -8, 0), (18, 14, -8, -1), (1, 15, -8, -7),
]


# ── Level Configuration ──────────────────────────────────────────

LEVELS = [
    {
        'name': 'Cavern', 'scroll_dir': 'horizontal',
        'max_aliens': 4, 'min_wave': 2, 'max_wave': 4,
        'boss_type': 'single', 'boss_hp': 40,
        'boss_patterns': [BOSS_PATTERN_0],
        'boss_sprites': ('Level-Zero', 'clockwork-bug', 8),
    },
    {
        'name': 'Sandstorm', 'scroll_dir': 'vertical', 'cycle': True,
        'max_aliens': 6, 'min_wave': 3, 'max_wave': 5,
        'boss_type': 'dual', 'boss_hp': 30,
        'boss_patterns': [BOSS_PATTERN_1A, BOSS_PATTERN_1B],
        'boss_sprites': ('Level-Zero', 'clockwork-bug', 8),
    },
    {
        'name': 'Cheese', 'scroll_dir': 'horizontal',
        'max_aliens': 6, 'min_wave': 2, 'max_wave': 6,
        'boss_type': 'circular', 'boss_hp': 15,
        'boss_patterns': [],
        'boss_sprites': ('Level-Zero', 'clockwork-bug', 8),
    },
    {
        'name': 'Lava', 'scroll_dir': 'vertical', 'cycle': True,
        'max_aliens': 6, 'min_wave': 2, 'max_wave': 5,
        'boss_type': 'lavaball', 'boss_hp': 20,
        'boss_patterns': [LAVABALL_LEFT, LAVABALL_RIGHT],
        'boss_sprites': ('Level-Three', 'FireBall-16', 16),
    },
    {
        'name': 'Hangar', 'scroll_dir': 'horizontal',
        'max_aliens': 8, 'min_wave': 2, 'max_wave': 6,
        'boss_type': 'dual', 'boss_hp': 30,
        'boss_patterns': [BOSS_PATTERN_4A, BOSS_PATTERN_4B],
        'boss_sprites': ('Level-Four', 'HangerBall', 16),
    },
]

# Background enemy positions per level (world coordinates)
LEVEL_BG_ENEMIES = {
    1: [  # Sandstorm eyes (320x1200 vertical)
        {'x': 228, 'y': 354, 'type': 'eye', 'hp': 4},
        {'x': 109, 'y': 616, 'type': 'eye', 'hp': 4},
        {'x': 267, 'y': 718, 'type': 'eye', 'hp': 4},
        {'x': 90, 'y': 823, 'type': 'eye', 'hp': 4},
        {'x': 186, 'y': 974, 'type': 'eye', 'hp': 4},
    ],
    3: [  # Lava irises + lava eyes (320x1200 vertical)
        {'x': 111, 'y': 59, 'type': 'lava_eye', 'hp': 8},
        {'x': 188, 'y': 59, 'type': 'lava_eye', 'hp': 8},
        {'x': 253, 'y': 692, 'type': 'iris', 'hp': 6},
        {'x': 72, 'y': 697, 'type': 'iris', 'hp': 6},
        {'x': 216, 'y': 860, 'type': 'iris', 'hp': 6},
        {'x': 19, 'y': 905, 'type': 'iris', 'hp': 6},
        {'x': 175, 'y': 1071, 'type': 'iris', 'hp': 6},
    ],
    4: [  # Hangar hex-guns + irises (1216x200 horizontal)
        {'x': 161, 'y': 91, 'type': 'iris', 'hp': 6},
        {'x': 259, 'y': 71, 'type': 'hexgun', 'hp': 4},
        {'x': 314, 'y': 122, 'type': 'hexgun', 'hp': 4},
        {'x': 335, 'y': 31, 'type': 'hexgun', 'hp': 4},
        {'x': 429, 'y': 102, 'type': 'hexgun', 'hp': 4},
        {'x': 562, 'y': 33, 'type': 'hexgun', 'hp': 4},
        {'x': 618, 'y': 63, 'type': 'hexgun', 'hp': 4},
        {'x': 618, 'y': 101, 'type': 'hexgun', 'hp': 4},
        {'x': 917, 'y': 41, 'type': 'iris', 'hp': 6},
        {'x': 917, 'y': 100, 'type': 'iris', 'hp': 6},
        {'x': 917, 'y': 162, 'type': 'iris', 'hp': 6},
    ],
}

# Map bg enemy types to sprite assets: (directory, name, frame_count)
BG_ENEMY_SPRITES = {
    1: {'eye': ('Level-One', 'Eye', 9)},
    3: {
        'lava_eye': ('Level-Three', 'Lava-Eye', 13),
        'iris': ('Level-Three', 'Iris-3D', 19),
    },
    4: {
        'hexgun': ('Level-Four', 'Hex-Gun', 15),
        'iris': ('Level-Four', 'HangerIris', 10),
    },
}

# Background names per level
LEVEL_BG = [
    ('Level-Zero', 'Back0'),
    ('Level-One', 'Back1'),
    ('Level-Two', 'Back2'),
    ('Level-Three', 'back3'),
    ('Level-Four', 'back4'),
]


# ── Asset Loading ─────────────────────────────────────────────────

def get_asset_path():
    return Path(__file__).parent.parent / 'modern-bitmaps'


def load_frames(subdir, name, count):
    base = get_asset_path() / subdir
    frames = []
    if count == 1:
        path = base / f"{name}.png"
        if path.exists():
            frames.append(pygame.image.load(str(path)).convert_alpha())
    else:
        for i in range(count):
            path = base / f"{name}_frame{i}.png"
            if path.exists():
                frames.append(pygame.image.load(str(path)).convert_alpha())
    return frames


def load_screen(subdir, name):
    path = get_asset_path() / subdir / f"{name}.png"
    if path.exists():
        return pygame.image.load(str(path)).convert()
    return None


def decode_hw_sprite(words, palette):
    """Decode an Amiga hardware sprite (16px wide) into a pygame Surface.

    words: list of UWORD values — [pos_ctl, pos_ctl, row0_p0, row0_p1, ..., end, end]
           36 words = 18 rows: 1 control + 16 image + 1 end marker.
    palette: 3-entry list of (R,G,B) tuples for color indices 1-3 (0=transparent).
    """
    surf = pygame.Surface((16, 16), pygame.SRCALPHA)
    for row in range(16):
        p0 = words[2 + row * 2]
        p1 = words[2 + row * 2 + 1]
        for x in range(16):
            bit = 15 - x
            c = ((p0 >> bit) & 1) | (((p1 >> bit) & 1) << 1)
            if c:
                surf.set_at((x, row), palette[c - 1])
    return surf


def make_bullet_sprites():
    """Decode player bullet sprites from original bulldata.c data."""
    # Amiga 12-bit color: 0x0RGB, expand 4-bit → 8-bit via *17
    # Pow0_Colors = {0x0F00, 0x0FC0, 0x0FFF} → Red, Yellow-Orange, White
    pal = [(255, 0, 0), (255, 204, 0), (255, 255, 255)]

    # Sprite_UpBullet[36] from bulldata.c — power 0 up-facing bullet
    up0 = [
        0x0000, 0x0000,
        0xe000, 0x0000, 0x1000, 0xe000, 0xf000, 0xe000,
        0x5000, 0xe000, 0xa000, 0x4000, 0xa000, 0x4000,
        0xa000, 0x4000, 0x4000, 0x0000, 0x0000, 0x4000,
        0x4000, 0x0000, 0x4000, 0x0000, 0x0000, 0x0000,
        0x4000, 0x0000, 0x0000, 0x0000, 0x4000, 0x0000,
        0x0000, 0x0000,
        0x0000, 0x0000,
    ]

    # Sprite_BUpBullet[36] from bulldata.c — power 1 up-facing bullet
    up1 = [
        0x0000, 0x0000,
        0x4000, 0x0000, 0xa000, 0x4000, 0x5000, 0xe000,
        0xf000, 0xe000, 0x5000, 0xe000, 0x5000, 0xe000,
        0x1000, 0xe000, 0x5000, 0xe000, 0x1000, 0xe000,
        0xe000, 0x4000, 0xa000, 0x4000, 0x0000, 0x4000,
        0x4000, 0x0000, 0x0000, 0x4000, 0x4000, 0x0000,
        0x0000, 0x0000,
        0x0000, 0x0000,
    ]

    # Sprite_RoundBullet[16] — homing missile (8 rows including control)
    round_data = [
        0x0000, 0x0000,
        0x7800, 0x0000, 0xfc00, 0x7800, 0xcc00, 0x7800,
        0xcc00, 0x7800, 0xfc00, 0x7800, 0x7800, 0x0000,
        0x0000, 0x0000,
    ]

    def crop_to_opaque(surf):
        """Crop surface to its opaque bounding box."""
        rect = surf.get_bounding_rect()
        if rect.width == 0 or rect.height == 0:
            return surf
        cropped = pygame.Surface((rect.width, rect.height), pygame.SRCALPHA)
        cropped.blit(surf, (0, 0), rect)
        return cropped

    sprites = {}
    for power, data in enumerate([up0, up1]):
        up_surf = crop_to_opaque(decode_hw_sprite(data, pal))
        sprites[(power, 'up')] = up_surf
        sprites[(power, 'right')] = crop_to_opaque(pygame.transform.rotate(up_surf, -90))
        sprites[(power, 'down')] = crop_to_opaque(pygame.transform.rotate(up_surf, 180))
        sprites[(power, 'left')] = crop_to_opaque(pygame.transform.rotate(up_surf, 90))

    # Round bullet (pad to 16 rows for decode_hw_sprite)
    padded = round_data + [0x0000, 0x0000] * 10  # pad to 36 words
    sprites['round'] = crop_to_opaque(decode_hw_sprite(padded, pal))

    return sprites


def load_sound(name):
    sfx_path = Path(__file__).parent.parent / 'NTSC' / 'graphics' / 'Sound' / name
    if not sfx_path.exists():
        return None
    try:
        import numpy as np
        raw = np.frombuffer(sfx_path.read_bytes(), dtype=np.int8).astype(np.int16)
        # Upsample 4x (11025→44100) using zero-order hold (matches Amiga DAC)
        raw = np.repeat(raw, 4) * 256   # scale 8-bit to 16-bit
        return pygame.mixer.Sound(buffer=raw.tobytes())
    except Exception:
        return None


# ── Game Objects ──────────────────────────────────────────────────

class Player:
    def __init__(self, frames_horiz, frames_vert):
        self.frames_horiz = frames_horiz
        self.frames_vert = frames_vert
        self.frames = frames_horiz
        self.scroll_dir = 'horizontal'
        self.x = float(PLAYER_START_X)
        self.y = float(PLAYER_START_Y_H)
        self.frame = PLAYER_CENTER_FRAME
        self.bank_timer = 0
        self.target_frame = PLAYER_CENTER_FRAME
        self.lives = STARTING_LIVES
        self.score = 0
        self.next_extra_life = EXTRA_LIFE_FIRST
        self.power = 1
        self.max_bullets = 4
        self.weapon = "LASER"
        self.speed_level = 1
        self.speeds = [(2, 1), (3, 2), (4, 3)]
        self.invincible_timer = 0
        self.alive = True
        self.respawn_timer = 0
        self.has_homers = False
        self.has_sides = False

    def set_scroll_dir(self, scroll_dir):
        self.scroll_dir = scroll_dir
        if scroll_dir == 'horizontal':
            self.frames = self.frames_horiz
            self.y = float(PLAYER_START_Y_H)
        else:
            self.frames = self.frames_vert
            self.y = float(PLAYER_START_Y_V)
        self.x = float(PLAYER_START_X)
        self.frame = PLAYER_CENTER_FRAME

    @property
    def horiz_speed(self):
        return self.speeds[self.speed_level][0]

    @property
    def vert_speed(self):
        return self.speeds[self.speed_level][1]

    def update(self, keys):
        if not self.alive:
            if self.lives <= 0:
                return
            self.respawn_timer -= 1
            if self.respawn_timer <= 0:
                self.alive = True
                self.x = float(PLAYER_START_X)
                self.y = float(PLAYER_START_Y_H if self.scroll_dir == 'horizontal'
                               else PLAYER_START_Y_V)
                self.frame = PLAYER_CENTER_FRAME
                self.invincible_timer = 120
            return

        if self.invincible_timer > 0:
            self.invincible_timer -= 1

        dx = dy = 0
        if keys[pygame.K_LEFT]:
            dx = -self.horiz_speed
        if keys[pygame.K_RIGHT]:
            dx = self.horiz_speed
        if keys[pygame.K_UP]:
            dy = -self.vert_speed
        if keys[pygame.K_DOWN]:
            dy = self.vert_speed

        self.x += dx
        self.y += dy
        self.x = max(3, min(295, self.x))
        self.y = max(0, min(VIEW_H - 24, self.y))

        # Banking: horizontal levels bank on dy, vertical on dx
        if self.scroll_dir == 'horizontal':
            bank_input = dy
        else:
            bank_input = dx

        if bank_input < 0:
            self.target_frame = 0
        elif bank_input > 0:
            self.target_frame = 6
        else:
            self.target_frame = PLAYER_CENTER_FRAME

        self.bank_timer += 1
        if self.bank_timer >= PLAYER_BANK_DELAY:
            self.bank_timer = 0
            if self.frame < self.target_frame:
                self.frame = min(self.frame + 1, PLAYER_MAX_FRAMES - 1)
            elif self.frame > self.target_frame:
                self.frame = max(self.frame - 1, 0)

    def add_score(self, points):
        self.score += points
        if self.score >= self.next_extra_life:
            if self.lives < MAX_LIVES:
                self.lives += 1
            self.next_extra_life += EXTRA_LIFE_INTERVAL

    def die(self):
        if self.invincible_timer > 0 or not self.alive:
            return False
        self.alive = False
        self.lives -= 1
        self.respawn_timer = 90
        self.power = 1
        self.max_bullets = 4
        self.weapon = "LASER"
        self.speed_level = 1
        self.has_homers = False
        self.has_sides = False
        return True

    def get_rect(self):
        return pygame.Rect(int(self.x) + 4, int(self.y) + 4, 23, 23)

    def draw(self, surface):
        if not self.alive:
            return
        if self.invincible_timer > 0 and (self.invincible_timer // 4) % 2:
            return
        if self.frame < len(self.frames):
            surface.blit(self.frames[self.frame], (int(self.x), int(self.y)))


class Bullet:
    sprites = None  # class-level, loaded once via make_bullet_sprites()

    def __init__(self, x, y, dx, dy):
        self.x, self.y = float(x), float(y)
        self.dx, self.dy = dx, dy
        self.alive = True
        self.power = 1

    def update(self):
        self.x += self.dx
        self.y += self.dy
        if self.x < -10 or self.x > INTERNAL_W + 10 or self.y < -10 or self.y > VIEW_H + 10:
            self.alive = False

    def _direction(self):
        if abs(self.dx) > abs(self.dy):
            return 'right' if self.dx > 0 else 'left'
        return 'down' if self.dy > 0 else 'up'

    def get_rect(self):
        if self.sprites:
            img = self.sprites.get((0, self._direction()))
            if img:
                return pygame.Rect(int(self.x) - img.get_width() // 2,
                                   int(self.y) - img.get_height() // 2,
                                   img.get_width(), img.get_height())
        if abs(self.dx) > abs(self.dy):
            return pygame.Rect(int(self.x), int(self.y), 16, 4)
        return pygame.Rect(int(self.x), int(self.y), 4, 16)

    def draw(self, surface):
        if self.sprites:
            power = min(self.power - 1, 1)
            img = self.sprites.get((power, self._direction()))
            if img:
                surface.blit(img, (int(self.x) - img.get_width() // 2,
                                   int(self.y) - img.get_height() // 2))
                return
        r = self.get_rect()
        pygame.draw.rect(surface, YELLOW, r)


class AlienBullet:
    def __init__(self, x, y, dx, dy):
        self.x, self.y = float(x), float(y)
        self.dx, self.dy = dx, dy
        self.alive = True

    def update(self):
        self.x += self.dx
        self.y += self.dy
        if self.x < -20 or self.x > INTERNAL_W + 20 or self.y < -20 or self.y > VIEW_H + 20:
            self.alive = False

    def get_rect(self):
        return pygame.Rect(int(self.x), int(self.y), 5, 5)

    def draw(self, surface, alien_bullet_frames):
        if alien_bullet_frames:
            surface.blit(alien_bullet_frames[0], (int(self.x), int(self.y)))
        else:
            pygame.draw.rect(surface, RED, (int(self.x), int(self.y), 5, 5))


class Alien:
    def __init__(self, pattern, frames, wave):
        self.pattern = pattern
        self.frames = frames
        self.wave = wave
        self.x = self.y = 0.0
        self.frame_idx = 0
        self.alive = True
        self.hp = 1
        self.step_idx = 0
        self.step_timer = 0
        self.visible = False

        if pattern:
            _, frame, sx, sy = pattern[0]
            self.x, self.y = float(sx), float(sy)
            self.frame_idx = frame % len(self.frames) if self.frames else 0
            self.step_idx = 1

    def update(self):
        if not self.alive or not self.pattern:
            return
        if self.step_idx >= len(self.pattern):
            self.alive = False
            return

        delay, frame, dx, dy = self.pattern[self.step_idx]
        self.x += dx * 0.5
        self.y += dy * 0.5
        if self.frames:
            self.frame_idx = frame % len(self.frames)

        self.step_timer += 1
        if self.step_timer >= delay:
            self.step_timer = 0
            self.step_idx += 1

        self.visible = (-32 < self.x < INTERNAL_W + 32 and -32 < self.y < VIEW_H + 32)
        if self.x < -100 or self.x > INTERNAL_W + 100 or self.y < -100 or self.y > VIEW_H + 100:
            self.alive = False

    def _draw_pos(self):
        """Top-left drawing position, centering sprite on logical position (GRAB hotspot)."""
        w = self.frames[0].get_width() if self.frames else 16
        h = self.frames[0].get_height() if self.frames else 16
        return int(self.x) - w // 2, int(self.y) - h // 2

    def get_rect(self):
        w = self.frames[0].get_width() if self.frames else 16
        h = self.frames[0].get_height() if self.frames else 16
        dx, dy = self._draw_pos()
        return pygame.Rect(dx, dy, w, h)

    def draw(self, surface):
        if self.alive and self.visible and self.frames:
            dx, dy = self._draw_pos()
            surface.blit(self.frames[self.frame_idx % len(self.frames)], (dx, dy))


class Wave:
    def __init__(self):
        self.aliens = []
        self.first_kill = True

    def all_dead(self):
        return all(not a.alive for a in self.aliens)


class Boss:
    """Generic boss — used for single, dual, and lava ball bosses."""

    def __init__(self, frames, pattern, hp=30, loop_reset=False):
        self.frames = frames
        self.pattern = pattern
        self.hp = hp
        self.max_hp = hp
        self.loop_reset = loop_reset
        self.alive = True
        self.anim_frame = 0
        self.anim_timer = 0
        self.pattern_step = 1
        self.step_timer = 0
        self.flash_timer = 0
        # Init position
        _, _, sx, sy = pattern[0]
        self.x, self.y = float(sx), float(sy)

    def update(self):
        if not self.alive:
            return
        if self.flash_timer > 0:
            self.flash_timer -= 1

        self.anim_timer += 1
        if self.anim_timer >= 6:
            self.anim_timer = 0
            self.anim_frame = (self.anim_frame + 1) % max(1, len(self.frames))

        if self.pattern_step >= len(self.pattern):
            if self.loop_reset:
                _, _, sx, sy = self.pattern[0]
                self.x, self.y = float(sx), float(sy)
            self.pattern_step = 1

        if self.pattern_step < len(self.pattern):
            delay, _, dx, dy = self.pattern[self.pattern_step]
            self.x += dx
            self.y += dy
            self.step_timer += 1
            if self.step_timer >= max(1, delay):
                self.step_timer = 0
                self.pattern_step += 1

    def _draw_pos(self):
        w = self.frames[0].get_width() if self.frames else 32
        h = self.frames[0].get_height() if self.frames else 32
        return int(self.x) - w // 2, int(self.y) - h // 2

    def get_rect(self):
        w = self.frames[0].get_width() if self.frames else 32
        h = self.frames[0].get_height() if self.frames else 32
        dx, dy = self._draw_pos()
        return pygame.Rect(dx, dy, w, h)

    def hit(self, power):
        self.hp -= power
        self.flash_timer = 6
        if self.hp <= 0:
            self.alive = False
            return True
        return False

    def draw(self, surface):
        if not self.alive or not self.frames:
            return
        dx, dy = self._draw_pos()
        img = self.frames[self.anim_frame % len(self.frames)]
        if self.flash_timer > 0 and (self.flash_timer // 2) % 2:
            flash = img.copy()
            flash.fill((255, 255, 255), special_flags=pygame.BLEND_RGB_ADD)
            surface.blit(flash, (dx, dy))
        else:
            surface.blit(img, (dx, dy))


class CircularBoss:
    """Level 2 boss — segments orbiting a drifting center point."""

    def __init__(self, frames, segment_hp=15, num_segments=2):
        self.frames = frames
        self.cx, self.cy = 160.0, 80.0
        self.radius = 40.0
        self.angle = 0.0
        self.angular_speed = 0.04
        self.center_dx, self.center_dy = 1.0, 0.5
        self.segments = [
            {'hp': segment_hp, 'max_hp': segment_hp, 'alive': True,
             'angle_offset': i * (2 * math.pi / num_segments)}
            for i in range(num_segments)
        ]
        self.alive = True
        self.anim_frame = 0
        self.anim_timer = 0

    def update(self):
        self.cx += self.center_dx
        self.cy += self.center_dy
        if self.cx < 40 or self.cx > 280:
            self.center_dx = -self.center_dx
        if self.cy < 30 or self.cy > 140:
            self.center_dy = -self.center_dy
        self.angle += self.angular_speed

        self.anim_timer += 1
        if self.anim_timer >= 6:
            self.anim_timer = 0
            self.anim_frame = (self.anim_frame + 1) % max(1, len(self.frames))

        if all(not s['alive'] for s in self.segments):
            self.alive = False

    def get_segment_pos(self, idx):
        off = self.segments[idx]['angle_offset']
        return (self.cx + self.radius * math.cos(self.angle + off),
                self.cy + self.radius * math.sin(self.angle + off))

    def get_segment_rect(self, idx):
        x, y = self.get_segment_pos(idx)
        w = self.frames[0].get_width() if self.frames else 32
        h = self.frames[0].get_height() if self.frames else 32
        return pygame.Rect(int(x) - w // 2, int(y) - h // 2, w, h)

    def hit_segment(self, idx, power):
        seg = self.segments[idx]
        seg['hp'] -= power
        if seg['hp'] <= 0:
            seg['alive'] = False
            return True
        return False

    @property
    def total_hp(self):
        return sum(s['hp'] for s in self.segments if s['alive'])

    @property
    def total_max_hp(self):
        return sum(s['max_hp'] for s in self.segments)

    def draw(self, surface):
        if not self.alive:
            return
        img = self.frames[self.anim_frame % len(self.frames)] if self.frames else None
        for i, seg in enumerate(self.segments):
            if not seg['alive'] or not img:
                continue
            x, y = self.get_segment_pos(i)
            surface.blit(img, (int(x) - img.get_width() // 2,
                               int(y) - img.get_height() // 2))


class BackgroundEnemy:
    """Stationary enemy at a fixed world position — eyes, turrets, hex-guns."""

    def __init__(self, world_x, world_y, frames, enemy_type='eye', hp=4):
        self.world_x, self.world_y = world_x, world_y
        self.frames = frames
        self.enemy_type = enemy_type
        self.hp = hp
        self.alive = True
        self.anim_frame = 0
        self.anim_timer = 0
        self.anim_dir = 1  # 1=opening, -1=closing
        self.visible = False
        self.flash_timer = 0

    def screen_pos(self, scroll_x, scroll_y, scroll_dir):
        # Center sprite on world position (accounts for GRAB hotspot offset)
        ox = self.frames[0].get_width() // 2 if self.frames else 0
        oy = self.frames[0].get_height() // 2 if self.frames else 0
        if scroll_dir == 'horizontal':
            return self.world_x - scroll_x - ox, self.world_y - oy
        return self.world_x - ox, self.world_y - scroll_y - oy

    def update(self, scroll_x, scroll_y, scroll_dir):
        if not self.alive:
            return
        sx, sy = self.screen_pos(scroll_x, scroll_y, scroll_dir)
        self.visible = (-32 < sx < INTERNAL_W + 32 and -32 < sy < VIEW_H + 32)
        if not self.visible:
            return
        if self.flash_timer > 0:
            self.flash_timer -= 1

        self.anim_timer += 1
        delay = 3 if self.enemy_type == 'hexgun' else 4
        if self.anim_timer >= delay:
            self.anim_timer = 0
            self.anim_frame += self.anim_dir
            mx = len(self.frames) - 1
            if self.anim_frame >= mx:
                self.anim_frame = mx
                self.anim_dir = -1
            elif self.anim_frame <= 0:
                self.anim_frame = 0
                self.anim_dir = 1

    def should_fire(self):
        if not self.alive or not self.visible:
            return False
        if self.enemy_type in ('eye', 'iris'):
            return self.anim_frame >= len(self.frames) - 2 and self.anim_dir == -1
        if self.enemy_type == 'hexgun':
            return self.anim_frame == 7 and self.anim_dir == 1
        if self.enemy_type == 'lava_eye':
            return self.anim_frame >= len(self.frames) - 2
        return False

    def get_rect(self, scroll_x, scroll_y, scroll_dir):
        sx, sy = self.screen_pos(scroll_x, scroll_y, scroll_dir)
        w = self.frames[0].get_width() if self.frames else 16
        h = self.frames[0].get_height() if self.frames else 16
        return pygame.Rect(int(sx), int(sy), w, h)

    def hit(self, power):
        self.hp -= power
        self.flash_timer = 6
        if self.hp <= 0:
            self.alive = False
            return True
        return False

    def draw(self, surface, scroll_x, scroll_y, scroll_dir):
        if not self.alive or not self.visible or not self.frames:
            return
        sx, sy = self.screen_pos(scroll_x, scroll_y, scroll_dir)
        img = self.frames[self.anim_frame % len(self.frames)]
        if self.flash_timer > 0 and (self.flash_timer // 2) % 2:
            flash = img.copy()
            flash.fill((255, 255, 255), special_flags=pygame.BLEND_RGB_ADD)
            surface.blit(flash, (int(sx), int(sy)))
        else:
            surface.blit(img, (int(sx), int(sy)))


class Explosion:
    def __init__(self, x, y, frames):
        self.x, self.y = x, y
        self.frames = frames
        self.frame_idx = 0
        self.timer = 0
        self.alive = True

    def update(self):
        self.timer += 1
        if self.timer >= 4:
            self.timer = 0
            self.frame_idx += 1
            if self.frame_idx >= len(self.frames):
                self.alive = False

    def draw(self, surface):
        if self.alive and self.frame_idx < len(self.frames):
            img = self.frames[self.frame_idx]
            surface.blit(img, (int(self.x) - img.get_width() // 2,
                               int(self.y) - img.get_height() // 2))


class Token:
    def __init__(self, x, y, token_type, frames):
        self.x, self.y = float(x), float(y)
        self.token_type = token_type
        self.frames = frames
        self.alive = True
        self.frame_idx = 0
        self.anim_timer = 0

    def update(self, scroll_dir='horizontal'):
        if scroll_dir == 'horizontal':
            self.x -= 1
        else:
            self.y += 1
        self.anim_timer += 1
        if self.anim_timer >= 10:
            self.anim_timer = 0
            self.frame_idx = (self.frame_idx + 1) % max(1, len(self.frames))
        if self.x < -32 or self.y > VIEW_H + 32:
            self.alive = False

    def get_rect(self):
        return pygame.Rect(int(self.x), int(self.y), 20, 15)

    def draw(self, surface):
        if self.alive and self.frames:
            surface.blit(self.frames[self.frame_idx % len(self.frames)],
                         (int(self.x), int(self.y)))


# ── Music Player (SMUS format) ───────────────────────────────────

class MusicPlayer:
    """Parse Amiga SMUS music file and pre-render to a looping pygame Sound.

    The original game stores music as an IFF SMUS (Simple Musical Score) file
    containing 3 tracks of 2-byte events. Each event is either a control code
    (instrument change, time signature, etc.) or a note/rest with duration flags.

    Instrument samples are the same .sfx files used for sound effects.
    Notes are pitched using Amiga period values from octave lookup tables —
    lower period = higher frequency. We resample each note to the mixer rate.
    """

    NTSC_CLOCK = 3_579_545
    NOTE_LENGTHS = [96, 48, 24, 12, 6, 3, 1, 0]

    # Amiga period tables (from sound.c) — index 0-126, lower value = higher pitch
    OCTAVE1 = [
        7550, 7127, 6727, 6349, 5993, 5656, 5339, 5039,
        4756, 4489, 4237, 4000, 3775, 3563, 3363, 3174,
        2996, 2828, 2669, 2519, 2378, 2244, 2118, 2000,
        1887, 1781, 1681, 1587, 1498, 1414, 1334, 1259,
        1189, 1122, 1059, 1000, 943, 890, 840, 793,
        749, 707, 667, 629, 594, 561, 529, 500,
        471, 445, 420, 396, 374, 353, 333, 314,
        297, 280, 264, 250, 235, 222, 210, 198,
        187, 176, 166, 157, 148, 140, 132, 125,
        117, 111, 105, 99, 93, 88, 83, 78,
        74, 70, 66, 62, 58, 55, 52, 49,
        46, 44, 41, 39, 37, 35, 33, 31,
        29, 27, 26, 24, 23, 22, 20, 19,
        18, 17, 16, 15, 14, 13, 13, 12,
        11, 11, 10, 9, 9, 8, 8, 7,
        7, 6, 6, 6, 5, 5, 5, 5,
    ]

    OCTAVE2 = [
        2595, 2449, 2312, 2182, 2060, 1944, 1835, 1732,
        1635, 1543, 1456, 1375, 1297, 1224, 1156, 1091,
        1030, 972, 917, 866, 817, 771, 728, 687,
        648, 612, 578, 545, 515, 486, 458, 433,
        408, 385, 364, 343, 324, 306, 289, 272,
        257, 243, 229, 216, 204, 192, 182, 171,
        162, 153, 144, 136, 128, 121, 114, 108,
        102, 96, 91, 85, 81, 76, 72, 68,
        64, 60, 57, 54, 51, 48, 45, 42,
        40, 38, 36, 34, 32, 30, 28, 27,
        25, 24, 22, 21, 20, 19, 18, 17,
        16, 15, 14, 13, 12, 12, 11, 10,
        10, 9, 9, 8, 8, 7, 7, 6,
        6, 6, 5, 5, 5, 4, 4, 4,
        4, 3, 3, 3, 3, 3, 2, 2,
        2, 2, 2, 2, 2, 1, 1, 1,
    ]

    # Instrument ID → (.sfx filename, octave table to switch to or None)
    INST_CONFIG = {
        0: ('bass1.sfx', OCTAVE1),
        1: ('cymbal.sfx', None),
        2: ('synthsnare.sfx', None),
        3: ('bassguitar.sfx', OCTAVE2),
        4: ('HighBass.sfx', None),
    }

    # Game's sample sizes from sound.c — LoadSample allocates exactly this many
    # bytes with MEMF_CLEAR, then reads the file (truncating or zero-padding).
    SAMPLE_SIZES = {
        0: 2000,   # BASS1SIZE
        1: 2000,   # CYMBALSIZE
        2: 2000,   # SYNTHSNARESIZE
        3: 2400,   # BASSGUITARSIZE
        4: 2000,   # HIGHBASSSIZE
    }

    def __init__(self, mixer_rate=11025):
        self.mixer_rate = mixer_rate
        self.samples_per_tick = mixer_rate / 50.0
        self.sound = None

    def load(self, smus_path, sound_dir):
        """Load an SMUS file and pre-render all tracks to a single pygame Sound."""
        import struct
        import numpy as np

        # Load instrument samples as float32 arrays, matching game's sizes
        raw_samples = {}
        for inst_id, (filename, _) in self.INST_CONFIG.items():
            path = sound_dir / filename
            if path.exists():
                raw = path.read_bytes()
                game_size = self.SAMPLE_SIZES.get(inst_id, len(raw))
                # Match original: AllocMem(Size, MEMF_CLEAR) then fread(buf, 1, Size)
                if len(raw) >= game_size:
                    raw = raw[:game_size]        # truncate extra data
                else:
                    raw = raw + b'\x00' * (game_size - len(raw))  # zero-pad
                raw_samples[inst_id] = (
                    np.frombuffer(raw, dtype=np.int8).astype(np.float32) / 128.0
                )

        if not raw_samples:
            return False

        # Parse SMUS chunks
        data = Path(smus_path).read_bytes()
        if len(data) < 12 or data[:4] != b'FORM' or data[8:12] != b'SMUS':
            return False

        pos = 12
        num_tracks = 3
        tracks = []

        while pos + 8 <= len(data):
            cid = data[pos:pos + 4]
            csz = struct.unpack('>I', data[pos + 4:pos + 8])[0]
            pos += 8

            if cid == b'SHDR' and csz >= 4:
                num_tracks = data[pos + 3]
            elif cid == b'TRAK':
                tracks.append(data[pos:pos + csz])
                if len(tracks) >= num_tracks:
                    pos += csz + (csz % 2)
                    break

            pos += csz
            if csz % 2:
                pos += 1

        if not tracks:
            return False

        # Per-track initial config (from StartMusic in sound.c)
        track_cfgs = [
            {'octave': self.OCTAVE1, 'volume': 50.0 / 64.0},
            {'octave': self.OCTAVE2, 'volume': 50.0 / 64.0},
            {'octave': self.OCTAVE2, 'volume': 50.0 / 64.0},
        ]

        rendered = []
        for i, tdata in enumerate(tracks[:3]):
            cfg = track_cfgs[i] if i < len(track_cfgs) else track_cfgs[-1]
            audio = self._render_track(tdata, raw_samples, cfg, np)
            rendered.append(audio)

        if not rendered:
            return False

        # Each track loops independently in the original game (MusicMachine
        # resets SndPC to 0 when it reaches the end). Tile shorter tracks
        # so all three align, then take one full cycle of the longest.
        max_len = max(len(a) for a in rendered)
        for i in range(len(rendered)):
            tlen = len(rendered[i])
            if tlen < max_len:
                reps = (max_len + tlen - 1) // tlen
                rendered[i] = np.tile(rendered[i], reps)[:max_len]

        # Mix all tracks together
        mixed = np.zeros(max_len, dtype=np.float32)
        for audio in rendered:
            mixed[:len(audio)] += audio

        # Normalize and convert to signed 16-bit
        peak = np.max(np.abs(mixed))
        if peak > 0:
            mixed = mixed / peak * 0.7
        out = (mixed * 32767.0).clip(-32768, 32767).astype(np.int16)

        self.sound = pygame.mixer.Sound(buffer=bytes(out))
        self.sound.set_volume(0.4)
        return True

    def _render_track(self, track_data, raw_samples, config, np):
        """Pre-render one SMUS track to a float32 audio buffer."""
        octave = list(config['octave'])
        volume = config['volume']
        cur_sample = raw_samples.get(0, np.zeros(100, dtype=np.float32))

        chunks = []
        n_events = len(track_data) // 2
        pc = 0

        while pc < n_events:
            sid = track_data[pc * 2]
            dat = track_data[pc * 2 + 1]
            pc += 1

            # Control events (sID > 128): instrument changes, time sig, etc.
            if sid > 128:
                if sid == 0x81:  # SID_Instrument
                    if dat in raw_samples:
                        cur_sample = raw_samples[dat]
                    cfg = self.INST_CONFIG.get(dat)
                    if cfg and cfg[1] is not None:
                        octave = cfg[1]
                continue

            # Note (0-127) or Rest (128)
            flags = dat
            division = flags & 0x07
            ticks = self.NOTE_LENGTHS[division]
            if flags & 0x08:  # Dotted note = 1.5x
                ticks = (ticks * 3) // 2
            duration = max(1, int(ticks * self.samples_per_tick))

            if sid == 0x80:  # Rest
                chunks.append(np.zeros(duration, dtype=np.float32))
            elif sid < 128:  # Note
                tone = sid
                idx = min(tone, len(octave) - 1)
                period = max(1, octave[idx])
                amiga_rate = self.NTSC_CLOCK / period
                ratio = amiga_rate / self.mixer_rate

                src_len = len(cur_sample)
                chunk = np.zeros(duration, dtype=np.float32)
                if duration > 0 and src_len > 1:
                    # Amiga DMA loops the sample for the note's full duration.
                    # Use modular wrapping + linear interpolation.
                    flt = np.arange(duration, dtype=np.float64) * ratio
                    flt = np.fmod(flt, src_len)
                    i0 = flt.astype(np.int64) % src_len
                    i1 = (i0 + 1) % src_len
                    frac = flt - np.floor(flt)
                    chunk[:] = (
                        cur_sample[i0] * (1.0 - frac) +
                        cur_sample[i1] * frac
                    ) * volume
                chunks.append(chunk)

        if chunks:
            return np.concatenate(chunks)
        return np.zeros(int(self.samples_per_tick), dtype=np.float32)

    def play(self):
        if self.sound:
            self.sound.play(loops=-1)

    def stop(self):
        if self.sound:
            self.sound.stop()

    @property
    def playing(self):
        if self.sound:
            import pygame
            return pygame.mixer.get_busy()
        return False


# ── Main Game ─────────────────────────────────────────────────────

class Game:
    def __init__(self):
        pygame.mixer.pre_init(frequency=44100, size=-16, channels=1, buffer=1024)
        pygame.init()
        self.screen = pygame.display.set_mode((SCREEN_W, SCREEN_H))
        self.internal = pygame.Surface((INTERNAL_W, INTERNAL_H))
        self.clock = pygame.time.Clock()
        self.tick = 0

        self.load_assets()
        self.state = "title"
        self.current_level = 0
        self.init_game()
        self.music.play()

    # ── Asset Loading ────────────────────────────────────────

    def load_assets(self):
        # Player ship frames
        raw = load_frames("Level-All", "just_me", 11)
        self.player_frames_horiz = [pygame.transform.rotate(f, -90) for f in raw]
        self.player_frames_vert = raw

        # Alien ship types (shared)
        self.alien_ship_frames = []
        counts = [12, 8, 8, 8, 8, 8, 12]
        for i in range(1, 8):
            name = f"ships{i}" if i < 7 else "Ships7"
            frames = load_frames("Level-All", name, counts[i - 1])
            if frames:
                self.alien_ship_frames.append(frames)

        self.explosion_frames = load_frames("Level-All", "bang", 8)
        self.token_frames = load_frames("Level-All", "token", 6)
        self.alien_bullet_frames = load_frames("Level-All", "AlienBullet", 3)
        Bullet.sprites = make_bullet_sprites()

        # Backgrounds for all levels
        # Cycling levels get rebuilt as 8-bit palette surfaces from original data
        self.backgrounds = {}
        for i, (d, n) in enumerate(LEVEL_BG):
            if LEVELS[i].get('cycle'):
                self.backgrounds[i] = self._load_cycling_bg(d, n)
            else:
                self.backgrounds[i] = load_screen(d, n)

        # Boss sprites per level (loaded on demand from config)
        self.boss_sprite_cache = {}

        # BG enemy sprites cache
        self.bg_sprite_cache = {}

        # Title screen — HAM6 with color cycling
        self.title_screens = self._load_title_ham6()
        self.title_cycle_idx = 0
        self.panel_img = load_screen("Level-All", "panel")

        self.font = pygame.font.SysFont("monospace", 14)
        self.small_font = pygame.font.SysFont("monospace", 10)

        # Sounds
        self.snd_laser = load_sound("laser.sfx")
        self.snd_explosion = load_sound("explosion.sfx")
        self.snd_token = load_sound("token.sfx")

        # Music (SMUS)
        self.music = MusicPlayer(mixer_rate=44100)
        sound_dir = Path(__file__).parent.parent / 'NTSC' / 'graphics' / 'Sound'
        smus_path = sound_dir / 'beat.smus'
        if smus_path.exists():
            self.music.load(smus_path, sound_dir)

    @staticmethod
    def _load_title_ham6():
        """Load title screen as HAM6, pre-rendering 3 cycling states.
        Cycles palette indices 13,14,15 (the cyan/white tones)."""
        import struct

        emrl_path = Path(__file__).parent.parent / 'NTSC' / 'graphics' / 'Screens' / 'Title-Screen'
        if not emrl_path.exists():
            fallback = load_screen("Screens", "Title-Screen")
            return [fallback] if fallback else []

        data = emrl_path.read_bytes()
        if len(data) < 12 or data[:4] != b'EMRL':
            fallback = load_screen("Screens", "Title-Screen")
            return [fallback] if fallback else []

        pos = 12
        # TOTL
        pos += 8 + 8  # skip TOTL header + data
        # COLR
        chunk_id = data[pos:pos+4]
        chunk_size = struct.unpack('>I', data[pos+4:pos+8])[0]
        pos += 8
        palette = []
        for j in range(0, chunk_size, 2):
            if j + 2 <= chunk_size:
                val = struct.unpack('>H', data[pos+j:pos+j+2])[0]
                r = ((val >> 8) & 0xF) * 17
                g = ((val >> 4) & 0xF) * 17
                b = (val & 0xF) * 17
                palette.append((r, g, b))
        pos += chunk_size

        # BMFO
        chunk_id = data[pos:pos+4]
        chunk_size = struct.unpack('>I', data[pos+4:pos+8])[0]
        bmfo_start = pos + 8
        width, height = struct.unpack('>HH', data[bmfo_start:bmfo_start+4])
        depth = data[bmfo_start+8]
        plane_pick = data[bmfo_start+12]
        plane_on_off = data[bmfo_start+13]
        pos = bmfo_start + chunk_size

        row_bytes = ((width + 15) // 16) * 2
        plane_size = row_bytes * height

        def _unpack_emrl_rle(data, offset, chunk_size, expected):
            """Unpack EMRL RLE-compressed bitplane data."""
            end = offset + chunk_size
            out = bytearray()
            if offset >= end:
                return bytes(out), offset
            rpos = offset
            count = data[rpos]; rpos += 1
            while rpos < end:
                val = data[rpos]; rpos += 1
                if count < 128:
                    if count == 0 and val == 0:
                        break
                    out.append(val)
                    for _ in range(count - 1):
                        if rpos >= end:
                            break
                        count = val
                        val = data[rpos]; rpos += 1
                        out.append(val)
                    if rpos >= end:
                        break
                    count = data[rpos]; rpos += 1
                else:
                    repeat = count & 127
                    out.extend([val] * repeat)
                    if rpos >= end:
                        break
                    count = data[rpos]; rpos += 1
            if len(out) < expected:
                out.extend(b'\x00' * (expected - len(out)))
            return bytes(out[:expected]), end

        # Read bitplanes
        planes = []
        for p in range(depth):
            if plane_pick & (1 << p):
                chunk_id = data[pos:pos+4]
                chunk_size = struct.unpack('>I', data[pos+4:pos+8])[0]
                pos += 8
                unpacked, pos = _unpack_emrl_rle(data, pos, chunk_size, plane_size)
                planes.append(unpacked)
            else:
                fill = b'\xff' if (plane_on_off & (1 << p)) else b'\x00'
                planes.append(fill * plane_size)

        if depth < 6 or len(planes) < 6:
            fallback = load_screen("Screens", "Title-Screen")
            return [fallback] if fallback else []

        def render_ham6(pal):
            """Render HAM6 to a pygame surface."""
            surf = pygame.Surface((width, height))
            pxa = pygame.surfarray.pixels3d(surf)  # (w, h, 3)
            for y in range(height):
                pr, pg, pb = pal[0]
                for x in range(width):
                    byte_idx = y * row_bytes + (x // 8)
                    bit_idx = 7 - (x % 8)
                    val = 0
                    for p in range(6):
                        if planes[p][byte_idx] & (1 << bit_idx):
                            val |= (1 << p)
                    ctrl = (val >> 4) & 3
                    d = val & 0xF
                    if ctrl == 0:
                        pr, pg, pb = pal[d] if d < len(pal) else (0, 0, 0)
                    elif ctrl == 1:
                        pb = d * 17
                    elif ctrl == 2:
                        pr = d * 17
                    else:
                        pg = d * 17
                    pxa[x, y] = (pr, pg, pb)
            del pxa  # unlock surface
            return surf

        # Pre-render 3 cycling states (rotating palette indices 13,14,15)
        surfaces = []
        pal = list(palette[:16])
        while len(pal) < 16:
            pal.append((0, 0, 0))
        for _ in range(3):
            surfaces.append(render_ham6(pal))
            # Rotate: [13,14,15] -> [15,13,14]
            pal[13], pal[14], pal[15] = pal[15], pal[13], pal[14]
        return surfaces

    @staticmethod
    def _load_cycling_bg(subdir, name):
        """Load a background as an 8-bit palette surface for color cycling.
        Reads the original EMRL palette, then maps the RGB PNG back to indices."""
        import struct
        # Read original palette from EMRL file
        emrl_path = Path(__file__).parent.parent / 'NTSC' / 'graphics' / subdir / name
        palette = []
        if emrl_path.exists():
            data = emrl_path.read_bytes()
            if data[:4] == b'EMRL':
                pos = 12
                while pos < len(data) - 8:
                    chunk = data[pos:pos+4]
                    size = struct.unpack('>I', data[pos+4:pos+8])[0]
                    pos += 8
                    if chunk == b'COLR':
                        for j in range(0, size, 2):
                            if j + 2 <= size:
                                val = struct.unpack('>H', data[pos+j:pos+j+2])[0]
                                r = ((val >> 8) & 0xF) * 17
                                g = ((val >> 4) & 0xF) * 17
                                b = (val & 0xF) * 17
                                palette.append((r, g, b))
                        break
                    pos += size + (size % 2)

        if not palette:
            return load_screen(subdir, name)  # fallback

        # Load the RGB PNG
        png_path = get_asset_path() / subdir / f"{name}.png"
        if not png_path.exists():
            return None
        rgb_surf = pygame.image.load(str(png_path))
        w, h = rgb_surf.get_size()

        # Build RGB→index lookup from palette
        color_to_idx = {}
        for idx, col in enumerate(palette):
            color_to_idx[col] = idx

        # Create 8-bit palette surface
        pal_surf = pygame.Surface((w, h), depth=8)
        flat_pal = []
        for c in palette:
            flat_pal.extend(c)
        flat_pal.extend([0, 0, 0] * (256 - len(palette)))
        pal_surf.set_palette([tuple(flat_pal[i:i+3]) for i in range(0, 768, 3)])

        # Map pixels (use surfarray for speed)
        try:
            arr_rgb = pygame.surfarray.array3d(rgb_surf)  # (w, h, 3)
            arr_idx = pygame.surfarray.pixels2d(pal_surf)  # (w, h)
            for idx, col in enumerate(palette):
                mask = ((arr_rgb[:, :, 0] == col[0]) &
                        (arr_rgb[:, :, 1] == col[1]) &
                        (arr_rgb[:, :, 2] == col[2]))
                arr_idx[mask] = idx
            del arr_idx  # unlock surface
        except Exception:
            # Slow fallback
            for y in range(h):
                for x in range(w):
                    c = rgb_surf.get_at((x, y))[:3]
                    pal_surf.set_at((x, y), color_to_idx.get(c, 0))

        return pal_surf

    def get_boss_sprites(self, level_idx):
        if level_idx not in self.boss_sprite_cache:
            d, n, c = LEVELS[level_idx]['boss_sprites']
            self.boss_sprite_cache[level_idx] = load_frames(d, n, c)
        return self.boss_sprite_cache[level_idx]

    def get_bg_enemy_sprites(self, level_idx, enemy_type):
        key = (level_idx, enemy_type)
        if key not in self.bg_sprite_cache:
            info = BG_ENEMY_SPRITES.get(level_idx, {}).get(enemy_type)
            if info:
                d, n, c = info
                self.bg_sprite_cache[key] = load_frames(d, n, c)
            else:
                self.bg_sprite_cache[key] = []
        return self.bg_sprite_cache[key]

    # ── Game State ───────────────────────────────────────────

    def init_game(self):
        self.player = Player(self.player_frames_horiz, self.player_frames_vert)
        self.current_level = 0
        self.load_level(0)

    def load_level(self, level_idx):
        self.current_level = level_idx
        level = LEVELS[level_idx]
        self.scroll_dir = level['scroll_dir']

        # Player
        self.player.set_scroll_dir(self.scroll_dir)

        # Background
        self.background = self.backgrounds.get(level_idx)

        # Scroll setup
        self.scroll_x = 0.0
        self.scroll_y = 0.0
        if self.scroll_dir == 'horizontal':
            self.max_scroll = (self.background.get_width() - INTERNAL_W
                               if self.background else 896)
        else:
            self.max_scroll = (self.background.get_height() - VIEW_H
                               if self.background else 1024)
            self.scroll_y = float(self.max_scroll)

        # Reset gameplay
        self.bullets = []
        self.alien_bullets = []
        self.waves = []
        self.explosions = []
        self.tokens = []
        self.bosses = []
        self.circular_boss = None
        self.boss_active = False
        self.boss_defeated = False
        self.scroll_paused = False
        self.level_complete = False
        self.level_complete_timer = 0
        self.scroll_timer = 0
        self.wave_timer = 60
        self.token_timer = TOKEN_SPAWN_INTERVAL
        self.token_cycle = 0
        self.last_pattern = -1
        self.announce_timer = 120  # 2 seconds showing level name
        self.cycle_timer = 0
        self.tick = 0

        # Background enemies
        self.bg_enemies = []
        for be in LEVEL_BG_ENEMIES.get(level_idx, []):
            frames = self.get_bg_enemy_sprites(level_idx, be['type'])
            if frames:
                self.bg_enemies.append(BackgroundEnemy(
                    be['x'], be['y'], frames, be['type'], be['hp']))

        pygame.display.set_caption(
            f"Phantom Fighter — Level {level_idx + 1}: {level['name']}")

    def play_sound(self, snd):
        if snd:
            try:
                snd.play()
            except Exception:
                pass

    # ── Spawning ─────────────────────────────────────────────

    @staticmethod
    def _mirror_pattern_h(pattern):
        """Mirror horizontally — aliens enter from the right half."""
        return [(d, f, INTERNAL_W - vx if i == 0 else -vx, vy)
                for i, (d, f, vx, vy) in enumerate(pattern)]

    @staticmethod
    def _mirror_pattern_v(pattern):
        """Mirror vertically — aliens enter from the top half."""
        return [(d, f, vx, VIEW_H - vy if i == 0 else -vy)
                for i, (d, f, vx, vy) in enumerate(pattern)]

    def spawn_wave(self):
        if self.boss_active or self.level_complete:
            return
        level = LEVELS[self.current_level]
        active = sum(1 for w in self.waves for a in w.aliens if a.alive)
        if active >= level['max_aliens']:
            return

        pat_idx = random.randint(0, len(ALL_PATTERNS) - 1)
        while pat_idx == self.last_pattern and len(ALL_PATTERNS) > 1:
            pat_idx = random.randint(0, len(ALL_PATTERNS) - 1)
        self.last_pattern = pat_idx
        pattern = ALL_PATTERNS[pat_idx]

        # Ensure aliens enter from in front of the player
        _, _, sx, sy = pattern[0]
        if self.scroll_dir == 'horizontal':
            if sx < INTERNAL_W // 2:
                pattern = self._mirror_pattern_h(pattern)
        else:
            if sy > VIEW_H // 2:
                pattern = self._mirror_pattern_v(pattern)

        if not self.alien_ship_frames:
            return
        ship_frames = random.choice(self.alien_ship_frames)

        remaining = level['max_aliens'] - active
        wave_size = min(remaining, random.randint(level['min_wave'], level['max_wave']))
        wave_size = max(2, wave_size)

        wave = Wave()
        for i in range(wave_size):
            alien = Alien(pattern, ship_frames, wave)
            alien.x += random.randint(-10, 10)
            alien.y += random.randint(-10, 10)
            alien.step_timer = -i * 10
            wave.aliens.append(alien)
        self.waves.append(wave)

    def spawn_boss(self):
        level = LEVELS[self.current_level]
        boss_frames = self.get_boss_sprites(self.current_level)
        boss_type = level['boss_type']
        hp = level['boss_hp']

        self.boss_active = True
        self.scroll_paused = True

        if boss_type in ('single', 'dual'):
            self.bosses = [Boss(boss_frames, p, hp)
                           for p in level['boss_patterns']]
        elif boss_type == 'circular':
            self.circular_boss = CircularBoss(boss_frames, segment_hp=hp)
        elif boss_type == 'lavaball':
            self.bosses = [Boss(boss_frames, p, hp, loop_reset=True)
                           for p in level['boss_patterns']]

    def spawn_explosion(self, x, y):
        if self.explosion_frames:
            self.explosions.append(Explosion(x, y, self.explosion_frames))
            self.play_sound(self.snd_explosion)

    def spawn_token(self, x, y):
        token_type = TOKEN_TYPES[self.token_cycle % len(TOKEN_TYPES)]
        self.token_cycle += 1
        if self.token_frames:
            idx = (self.token_cycle - 1) % len(self.token_frames)
            frames = [self.token_frames[idx]]
        else:
            frames = []
        self.tokens.append(Token(x, y, token_type, frames))

    def fire_alien_bullet(self, ax, ay):
        if not self.player.alive:
            return
        dx = self.player.x - ax
        dy = self.player.y - ay
        dist = max(1, (dx * dx + dy * dy) ** 0.5)
        speed = 3
        self.alien_bullets.append(AlienBullet(ax, ay, dx / dist * speed, dy / dist * speed))

    # ── Boss Status ──────────────────────────────────────────

    def all_bosses_dead(self):
        if self.circular_boss:
            return not self.circular_boss.alive
        return all(not b.alive for b in self.bosses)

    def get_boss_hp(self):
        """Returns (current_hp, max_hp) across all boss entities."""
        cur = mx = 0
        for b in self.bosses:
            mx += b.max_hp
            if b.alive:
                cur += max(0, b.hp)
        if self.circular_boss:
            cur += self.circular_boss.total_hp
            mx += self.circular_boss.total_max_hp
        return cur, mx

    # ── Color Cycling ────────────────────────────────────────

    @staticmethod
    def _cycle_palette(surface):
        """Rotate palette entries 5,6,7 on an 8-bit surface (matches original COLOR13-15 cycling)."""
        try:
            pal = list(surface.get_palette())
            pal[5], pal[6], pal[7] = pal[7], pal[5], pal[6]
            surface.set_palette(pal)
        except Exception:
            pass

    # ── Update ───────────────────────────────────────────────

    def update_gameplay(self):
        self.tick += 1

        # Color cycling (levels with cycle flag)
        if LEVELS[self.current_level].get('cycle') and self.background:
            self.cycle_timer += 1
            if self.cycle_timer >= 6:
                self.cycle_timer = 0
                self._cycle_palette(self.background)

        # Level announcement overlay (no gameplay pause — just cosmetic)
        if self.announce_timer > 0:
            self.announce_timer -= 1

        keys = pygame.key.get_pressed()
        self.player.update(keys)

        # Firing
        if (keys[pygame.K_SPACE] or keys[pygame.K_z]) and self.player.alive:
            if len(self.bullets) < self.player.max_bullets and self.tick % 6 == 0:
                if self.scroll_dir == 'horizontal':
                    bx, by = self.player.x + 28, self.player.y + 8
                    self.bullets.append(Bullet(bx, by, BULLET_SPEED, 0))
                    if self.player.has_sides:
                        self.bullets.append(Bullet(bx, by - 8, BULLET_SPEED, -2))
                        self.bullets.append(Bullet(bx, by + 8, BULLET_SPEED, 2))
                else:
                    bx, by = self.player.x + 8, self.player.y - 4
                    self.bullets.append(Bullet(bx, by, 0, -BULLET_SPEED))
                    if self.player.has_sides:
                        self.bullets.append(Bullet(bx - 8, by, -2, -BULLET_SPEED))
                        self.bullets.append(Bullet(bx + 8, by, 2, -BULLET_SPEED))
                self.play_sound(self.snd_laser)

        # Scrolling
        if not self.scroll_paused:
            self.scroll_timer += 1
            if self.scroll_timer >= SCROLL_TICKS:
                self.scroll_timer = 0
                scroll_done = False
                if self.scroll_dir == 'horizontal':
                    self.scroll_x += SCROLL_SPEED
                    if self.scroll_x >= self.max_scroll:
                        self.scroll_x = self.max_scroll
                        scroll_done = True
                else:
                    self.scroll_y -= SCROLL_SPEED
                    if self.scroll_y <= 0:
                        self.scroll_y = 0
                        scroll_done = True

                if scroll_done and not self.boss_active and not self.level_complete:
                    if not self.boss_defeated:
                        self.spawn_boss()
                    else:
                        self.level_complete = True
                        self.level_complete_timer = 180

        # Bullets
        for b in self.bullets:
            b.update()
        self.bullets = [b for b in self.bullets if b.alive]

        for b in self.alien_bullets:
            b.update()
        self.alien_bullets = [b for b in self.alien_bullets if b.alive]

        # Waves
        self.wave_timer -= 1
        if self.wave_timer <= 0:
            self.spawn_wave()
            self.wave_timer = WAVE_SPAWN_INTERVAL

        for wave in self.waves:
            for alien in wave.aliens:
                alien.update()
                if alien.alive and alien.visible and random.randint(0, 999) < ALIEN_FIRE_CHANCE:
                    self.fire_alien_bullet(alien.x, alien.y)
        self.waves = [w for w in self.waves if not w.all_dead()]

        # Bosses
        for boss in self.bosses:
            boss.update()
            if boss.alive and random.randint(0, 999) < BOSS_FIRE_CHANCE:
                cx = boss.x + (boss.frames[0].get_width() // 2 if boss.frames else 16)
                cy = boss.y + (boss.frames[0].get_height() // 2 if boss.frames else 16)
                self.fire_alien_bullet(cx, cy)

        if self.circular_boss and self.circular_boss.alive:
            self.circular_boss.update()
            for i, seg in enumerate(self.circular_boss.segments):
                if seg['alive'] and random.randint(0, 999) < BOSS_FIRE_CHANCE:
                    x, y = self.circular_boss.get_segment_pos(i)
                    self.fire_alien_bullet(x + 16, y + 16)

        # Check if boss fight is over
        if self.boss_active and self.all_bosses_dead():
            self.boss_active = False
            self.boss_defeated = True
            self.scroll_paused = False
            # If scroll was already at the end, level complete immediately
            at_end = (self.scroll_dir == 'horizontal' and self.scroll_x >= self.max_scroll) or \
                     (self.scroll_dir == 'vertical' and self.scroll_y <= 0)
            if at_end:
                self.level_complete = True
                self.level_complete_timer = 180

        # Background enemies
        sx = self.scroll_x
        sy = self.scroll_y
        for be in self.bg_enemies:
            be.update(sx, sy, self.scroll_dir)
            if be.should_fire() and random.randint(0, 999) < 150:
                bsx, bsy = be.screen_pos(sx, sy, self.scroll_dir)
                if be.enemy_type == 'lava_eye':
                    for ddx, ddy in [(0, -2), (2, -2), (2, 0), (2, 2),
                                     (0, 2), (-2, -2), (-2, 0), (-2, 2)]:
                        self.alien_bullets.append(AlienBullet(bsx + 8, bsy + 8, ddx, ddy))
                else:
                    self.fire_alien_bullet(bsx + 8, bsy + 8)

        # Explosions
        for exp in self.explosions:
            exp.update()
        self.explosions = [e for e in self.explosions if e.alive]

        # Tokens
        for token in self.tokens:
            token.update(self.scroll_dir)
        self.tokens = [t for t in self.tokens if t.alive]

        self.token_timer -= 1
        if self.token_timer <= 0:
            self.token_timer = TOKEN_SPAWN_INTERVAL
            if self.scroll_dir == 'horizontal':
                self.spawn_token(INTERNAL_W + 10, random.randint(20, VIEW_H - 30))
            else:
                self.spawn_token(random.randint(20, INTERNAL_W - 30), -10)

        # Collisions
        self.check_collisions()

        # Level complete countdown
        if self.level_complete:
            self.level_complete_timer -= 1
            if self.level_complete_timer <= 0:
                self.advance_level()

        # Game over
        if self.player.lives <= 0 and not self.player.alive:
            self.state = "game_over"

    def advance_level(self):
        if self.current_level >= len(LEVELS) - 1:
            self.state = "victory"
        else:
            self.load_level(self.current_level + 1)

    def check_collisions(self):
        if not self.player.alive:
            return
        player_rect = self.player.get_rect()
        sx, sy = self.scroll_x, self.scroll_y

        # Player bullets vs enemies
        for bullet in self.bullets:
            if not bullet.alive:
                continue
            brect = bullet.get_rect()

            # vs aliens
            for wave in self.waves:
                for alien in wave.aliens:
                    if not alien.alive or not alien.visible:
                        continue
                    if brect.colliderect(alien.get_rect()):
                        alien.hp -= self.player.power
                        bullet.alive = False
                        if alien.hp <= 0:
                            alien.alive = False
                            self.spawn_explosion(alien.x, alien.y)
                            if wave.first_kill:
                                wave.first_kill = False
                                self.player.add_score(ALIEN_SCORE_FIRST)
                                self.spawn_token(alien.x, alien.y)
                            else:
                                self.player.add_score(ALIEN_SCORE_OTHER)
                        break

            # vs bosses
            if bullet.alive:
                for boss in self.bosses:
                    if boss.alive and brect.colliderect(boss.get_rect()):
                        bullet.alive = False
                        if boss.hit(self.player.power):
                            self.player.add_score(BOSS_SCORE)
                            self.spawn_explosion(boss.x, boss.y)
                            self.spawn_explosion(boss.x + 20, boss.y + 10)
                        break

            # vs circular boss segments
            if bullet.alive and self.circular_boss and self.circular_boss.alive:
                for i, seg in enumerate(self.circular_boss.segments):
                    if seg['alive'] and brect.colliderect(
                            self.circular_boss.get_segment_rect(i)):
                        bullet.alive = False
                        if self.circular_boss.hit_segment(i, self.player.power):
                            x, y = self.circular_boss.get_segment_pos(i)
                            self.spawn_explosion(x, y)
                            self.player.add_score(BOSS_SCORE)
                        break

            # vs background enemies
            if bullet.alive:
                for be in self.bg_enemies:
                    if be.alive and be.visible and brect.colliderect(
                            be.get_rect(sx, sy, self.scroll_dir)):
                        bullet.alive = False
                        if be.hit(self.player.power):
                            bsx, bsy = be.screen_pos(sx, sy, self.scroll_dir)
                            self.spawn_explosion(bsx, bsy)
                            self.player.add_score(BUG_SCORE)
                        break

        # Alien bullets vs player
        for bullet in self.alien_bullets:
            if bullet.alive and bullet.get_rect().colliderect(player_rect):
                bullet.alive = False
                if self.player.die():
                    self.spawn_explosion(self.player.x + 16, self.player.y + 16)

        # Aliens vs player
        for wave in self.waves:
            for alien in wave.aliens:
                if alien.alive and alien.visible and alien.get_rect().colliderect(player_rect):
                    if self.player.die():
                        self.spawn_explosion(self.player.x + 16, self.player.y + 16)

        # Bosses vs player
        for boss in self.bosses:
            if boss.alive and boss.get_rect().colliderect(player_rect):
                if self.player.die():
                    self.spawn_explosion(self.player.x + 16, self.player.y + 16)

        if self.circular_boss and self.circular_boss.alive:
            for i, seg in enumerate(self.circular_boss.segments):
                if seg['alive'] and self.circular_boss.get_segment_rect(i).colliderect(player_rect):
                    if self.player.die():
                        self.spawn_explosion(self.player.x + 16, self.player.y + 16)

        # Tokens vs player
        for token in self.tokens:
            if token.alive and token.get_rect().colliderect(player_rect):
                token.alive = False
                self.apply_token(token.token_type)
                self.play_sound(self.snd_token)
                self.player.add_score(50)

    def apply_token(self, token_type):
        p = self.player
        if token_type == "FASTER":
            p.speed_level = min(2, p.speed_level + 1)
        elif token_type == "LASER":
            p.max_bullets = 6
            p.weapon = "LASER"
            p.has_sides = p.has_homers = False
        elif token_type == "DOUBLE":
            p.power = min(20, p.power + 1)
        elif token_type == "PLASMA":
            p.max_bullets = 6
            p.weapon = "PLASMA"
        elif token_type == "SIDES":
            p.has_sides = True
            p.max_bullets = 6
            p.weapon = "SIDES"
        elif token_type == "HOMERS":
            p.has_homers = True
            p.max_bullets = 6
            p.weapon = "HOMERS"

    # ── Drawing ──────────────────────────────────────────────

    def draw_gameplay(self):
        self.internal.fill(BLACK)

        # Background
        if self.background:
            if self.scroll_dir == 'horizontal':
                src = pygame.Rect(int(self.scroll_x), 0, INTERNAL_W, VIEW_H)
            else:
                src = pygame.Rect(0, int(self.scroll_y), INTERNAL_W, VIEW_H)
            self.internal.blit(self.background, (0, 0), src)

        # Background enemies
        sx, sy = self.scroll_x, self.scroll_y
        for be in self.bg_enemies:
            be.draw(self.internal, sx, sy, self.scroll_dir)

        # Aliens
        for wave in self.waves:
            for alien in wave.aliens:
                alien.draw(self.internal)

        # Bosses
        for boss in self.bosses:
            boss.draw(self.internal)
        if self.circular_boss:
            self.circular_boss.draw(self.internal)

        # Tokens
        for token in self.tokens:
            token.draw(self.internal)

        # Player
        self.player.draw(self.internal)

        # Bullets
        for b in self.bullets:
            b.draw(self.internal)
        for b in self.alien_bullets:
            b.draw(self.internal, self.alien_bullet_frames)

        # Explosions
        for exp in self.explosions:
            exp.draw(self.internal)

        # Panel
        self.draw_panel()

        # Level announcement overlay
        if self.announce_timer > 0:
            lvl = LEVELS[self.current_level]
            text = self.font.render(
                f"LEVEL {self.current_level + 1}: {lvl['name'].upper()}", True, YELLOW)
            tx = (INTERNAL_W - text.get_width()) // 2
            self.internal.blit(text, (tx, VIEW_H // 2 - 10))

        # Level complete overlay
        if self.level_complete:
            text = self.font.render(
                f"LEVEL {self.current_level + 1} COMPLETE!", True, YELLOW)
            tx = (INTERNAL_W - text.get_width()) // 2
            self.internal.blit(text, (tx, VIEW_H // 2 - 10))

        # Scale and display
        scaled = pygame.transform.scale(self.internal, (SCREEN_W, SCREEN_H))
        self.screen.blit(scaled, (0, 0))

    def draw_panel(self):
        py = VIEW_H
        pygame.draw.rect(self.internal, PANEL_BG, (0, py, INTERNAL_W, PANEL_H))

        # Level
        lvl_text = self.small_font.render(
            f"LVL:{self.current_level + 1}", True, GREEN)
        self.internal.blit(lvl_text, (4, py + 2))

        # Weapon
        wep_text = self.small_font.render(
            f"{self.player.weapon}", True, CYAN)
        self.internal.blit(wep_text, (42, py + 2))

        # Score
        score_text = self.small_font.render(
            f"SCORE:{self.player.score:06d}", True, WHITE)
        self.internal.blit(score_text, (110, py + 2))

        # Lives
        lives_text = self.small_font.render(
            f"LEFT:{self.player.lives}", True, WHITE)
        self.internal.blit(lives_text, (250, py + 2))

        # Power
        pwr_text = self.small_font.render(
            f"PWR:{self.player.power}", True, YELLOW)
        self.internal.blit(pwr_text, (4, py + 13))

        # Boss HP bar
        cur_hp, max_hp = self.get_boss_hp()
        if max_hp > 0 and self.boss_active:
            bar_text = self.small_font.render("BOSS:", True, RED)
            self.internal.blit(bar_text, (120, py + 13))
            bar_w = int(100 * cur_hp / max_hp)
            pygame.draw.rect(self.internal, RED, (160, py + 14, bar_w, 6))
            pygame.draw.rect(self.internal, WHITE, (160, py + 14, 100, 6), 1)

    def draw_title(self):
        self.internal.fill(BLACK)
        if self.title_screens:
            # Cycle every 6 frames
            if self.tick % 6 == 0:
                self.title_cycle_idx = (self.title_cycle_idx + 1) % len(self.title_screens)
            title = self.title_screens[self.title_cycle_idx]
            self.internal.blit(title, (0, 0),
                               pygame.Rect(0, 0, INTERNAL_W, INTERNAL_H))
        else:
            text = self.font.render("PHANTOM FIGHTER", True, WHITE)
            self.internal.blit(text, (80, 60))

        if (self.tick // 30) % 2:
            prompt = self.small_font.render("PRESS SPACE OR FIRE TO START", True, YELLOW)
            self.internal.blit(prompt, ((INTERNAL_W - prompt.get_width()) // 2,
                                        INTERNAL_H - 30))

        scaled = pygame.transform.scale(self.internal, (SCREEN_W, SCREEN_H))
        self.screen.blit(scaled, (0, 0))

    def draw_game_over(self):
        self.internal.fill(BLACK)
        text = self.font.render("GAME OVER", True, RED)
        self.internal.blit(text, ((INTERNAL_W - text.get_width()) // 2, 50))

        lvl_text = self.font.render(
            f"REACHED LEVEL {self.current_level + 1}: {LEVELS[self.current_level]['name'].upper()}",
            True, CYAN)
        self.internal.blit(lvl_text, ((INTERNAL_W - lvl_text.get_width()) // 2, 80))

        score_text = self.font.render(
            f"FINAL SCORE: {self.player.score:06d}", True, WHITE)
        self.internal.blit(score_text, ((INTERNAL_W - score_text.get_width()) // 2, 110))

        if (self.tick // 30) % 2:
            prompt = self.small_font.render("PRESS SPACE TO PLAY AGAIN", True, YELLOW)
            self.internal.blit(prompt, ((INTERNAL_W - prompt.get_width()) // 2, 150))

        scaled = pygame.transform.scale(self.internal, (SCREEN_W, SCREEN_H))
        self.screen.blit(scaled, (0, 0))

    def draw_victory(self):
        self.internal.fill(BLACK)
        text = self.font.render("CONGRATULATIONS!", True, YELLOW)
        self.internal.blit(text, ((INTERNAL_W - text.get_width()) // 2, 40))

        sub = self.font.render("ALL 5 LEVELS CLEARED!", True, GREEN)
        self.internal.blit(sub, ((INTERNAL_W - sub.get_width()) // 2, 70))

        score_text = self.font.render(
            f"FINAL SCORE: {self.player.score:06d}", True, WHITE)
        self.internal.blit(score_text, ((INTERNAL_W - score_text.get_width()) // 2, 110))

        if (self.tick // 30) % 2:
            prompt = self.small_font.render("PRESS SPACE TO PLAY AGAIN", True, YELLOW)
            self.internal.blit(prompt, ((INTERNAL_W - prompt.get_width()) // 2, 150))

        scaled = pygame.transform.scale(self.internal, (SCREEN_W, SCREEN_H))
        self.screen.blit(scaled, (0, 0))

    # ── Main Loop ────────────────────────────────────────────

    def run(self):
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                if event.type == pygame.KEYDOWN:
                    if event.key in (pygame.K_ESCAPE, pygame.K_q):
                        running = False

                    if self.state == "title":
                        if event.key in (pygame.K_SPACE, pygame.K_z, pygame.K_RETURN):
                            self.state = "playing"
                            self.init_game()

                    elif self.state in ("game_over", "victory"):
                        if event.key in (pygame.K_SPACE, pygame.K_z, pygame.K_RETURN):
                            self.state = "title"

            self.tick += 1

            if self.state == "title":
                self.draw_title()
            elif self.state == "playing":
                self.update_gameplay()
                self.draw_gameplay()
            elif self.state == "game_over":
                self.draw_game_over()
            elif self.state == "victory":
                self.draw_victory()

            pygame.display.flip()
            self.clock.tick(FPS)

        self.music.stop()
        pygame.quit()


if __name__ == '__main__':
    game = Game()
    game.run()

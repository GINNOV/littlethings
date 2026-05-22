// ── Constants ─────────────────────────────────────────────────────

export const INTERNAL_W = 320;
export const INTERNAL_H = 200;
export const SCALE = 3;
export const SCREEN_W = INTERNAL_W * SCALE;
export const SCREEN_H = INTERNAL_H * SCALE;
export const FPS = 60;

export const PANEL_H = 24;
export const VIEW_W = INTERNAL_W;
export const VIEW_H = INTERNAL_H - PANEL_H;

export const SCROLL_TICKS = 3;
export const SCROLL_SPEED = 1;

export const PLAYER_START_X = 150;
export const PLAYER_START_Y_H = 80;
export const PLAYER_START_Y_V = 130;
export const PLAYER_CENTER_FRAME = 3;
export const PLAYER_MAX_FRAMES = 11;
export const PLAYER_BANK_DELAY = 6;
export const STARTING_LIVES = 5;
export const MAX_LIVES = 9;

export const BULLET_SPEED = 9;
export const MAX_BULLETS = 6;

export const EXTRA_LIFE_FIRST = 10000;
export const EXTRA_LIFE_INTERVAL = 20000;
export const ALIEN_SCORE_FIRST = 200;
export const ALIEN_SCORE_OTHER = 20;
export const BUG_SCORE = 1000;
export const BOSS_SCORE = 5000;

export const WAVE_SPAWN_INTERVAL = 180;
export const ALIEN_FIRE_CHANCE = 25;
export const BOSS_FIRE_CHANCE = 50;

export const TOKEN_SPAWN_INTERVAL = 500;
export const TOKEN_TYPES = ["FASTER", "LASER", "DOUBLE", "PLASMA", "SIDES", "HOMERS"];

export const BLACK = '#000000';
export const WHITE = '#ffffff';
export const YELLOW = '#ffff00';
export const RED = '#ff0000';
export const CYAN = '#00ffff';
export const GREEN = '#00ff00';
export const PANEL_BG = '#111144';

// ── Wave Movement Patterns (from patterns.c) ─────────────────────
// Each element: [delay_ticks, frame, dx, dy]
// First element is initial position: [small_delay, frame, start_x, start_y]

export const PATTERN_0 = [
    [2, 5, 319, 11], [25, 5, -3, 5], [10, 6, -5, 3], [11, 6, -6, 0],
    [10, 7, -5, -3], [11, 0, -2, -5], [10, 1, 2, -6], [9, 2, 5, -3],
    [11, 2, 6, 0], [11, 3, 5, 3], [9, 4, 2, 6], [8, 5, -1, 6],
    [7, 6, -4, 3], [12, 6, -5, 1], [12, 7, -6, 0], [6, 7, -5, -3],
    [9, 0, -2, -6], [7, 0, 0, -6], [7, 1, 3, -5], [6, 2, 5, -3],
    [15, 3, 6, 0], [12, 3, 4, 3], [5, 4, 3, 5], [8, 4, 0, 6],
    [8, 5, -2, 5], [7, 6, -6, 2], [8, 6, -6, 0], [12, 7, -6, -1],
    [10, 7, -5, -3], [10, 7, -5, -3], [14, 7, -5, -3],
];

export const PATTERN_1 = [
    [2, 4, 135, -24], [21, 4, 0, 6], [7, 5, 0, 6], [6, 5, -2, 5],
    [7, 6, -5, 2], [4, 7, -6, 0], [3, 7, -7, -1], [3, 7, -5, -3],
    [3, 0, -3, -6], [3, 0, 0, -7], [3, 1, 3, -6], [4, 2, 4, -4],
    [4, 2, 6, -2], [4, 2, 6, 0], [5, 3, 6, 2], [6, 4, 3, 5],
    [6, 5, 0, 6], [4, 5, -3, 5], [3, 6, -6, 2], [7, 7, -6, 0],
    [3, 7, -6, -3], [3, 0, -4, -5], [5, 0, -1, -7], [11, 1, 0, -6],
    [5, 1, 4, -5], [9, 2, 6, -1], [7, 2, 6, -1], [29, 2, 6, 0],
    [29, 2, 6, 0], [33, 2, 6, 0],
];

export const PATTERN_2 = [
    [2, 4, 169, -24], [21, 4, 0, 6], [7, 4, 1, 6], [6, 4, 3, 5],
    [5, 3, 6, 2], [3, 3, 6, 0], [3, 2, 6, -4], [3, 2, 6, -3],
    [3, 1, 3, -5], [3, 1, 0, -6], [2, 0, -2, -8], [3, 7, -5, -3],
    [3, 7, -6, -2], [4, 6, -6, 0], [3, 6, -7, 3], [19, 6, -5, 3],
    [5, 6, -6, 1], [5, 7, -6, -1], [5, 0, -4, -5], [4, 0, 0, -6],
    [4, 1, 3, -6], [6, 2, 5, -3], [9, 2, 6, -1], [9, 2, 5, -1],
    [8, 2, 5, -3], [4, 1, 5, -5], [4, 1, 5, -5], [8, 1, 5, -5],
];

export const PATTERN_3 = [
    [2, 4, 144, -24], [11, 4, 0, 6], [3, 5, -2, 6], [2, 6, -6, 4],
    [14, 6, -6, 0], [2, 6, -7, 4], [2, 4, 3, 7], [4, 3, 6, 1],
    [32, 2, 6, 0], [3, 3, 6, 2], [2, 4, 3, 5], [1, 5, -5, 9],
    [2, 6, -8, 2], [38, 6, -6, 0], [3, 5, -3, 5], [3, 4, 4, 5],
    [12, 3, 5, 3], [6, 3, 6, 0], [4, 2, 6, -3], [3, 2, 5, -5],
    [4, 1, 2, -6], [7, 1, 2, -6], [16, 0, 0, -6], [16, 0, 0, -6],
    [20, 0, 0, -6],
];

export const PATTERN_4 = [
    [2, 3, -17, -8], [49, 3, 5, 2], [5, 4, 4, 5], [4, 4, 2, 6],
    [4, 5, 0, 6], [4, 6, -5, 5], [7, 6, -6, 0], [25, 6, -6, 0],
    [5, 7, -5, -1], [4, 0, -4, -4], [4, 0, 0, -6], [5, 2, 4, -4],
    [6, 2, 6, -2], [31, 2, 5, -1], [2, 1, 5, -6], [3, 1, 1, -6],
    [2, 0, -3, -8], [2, 7, -7, -2], [3, 6, -7, 0], [3, 6, -5, 3],
    [2, 5, -3, 7], [27, 5, 0, 6], [27, 5, 0, 6], [31, 5, 0, 6],
];

export const PATTERN_5 = [
    [2, 2, -24, 17], [44, 2, 6, 0], [5, 3, 6, 0], [2, 3, 8, 2],
    [2, 3, 5, 5], [2, 4, 1, 6], [2, 5, -3, 7], [2, 6, -7, 2],
    [2, 7, -8, -2], [2, 0, -5, -5], [2, 0, 0, -8], [2, 1, 3, -6],
    [2, 2, 7, -3], [2, 3, 6, 1], [2, 3, 6, 3], [2, 4, 5, 6],
    [20, 4, 0, 6], [4, 5, -1, 6], [3, 5, -4, 5], [24, 6, -6, 0],
    [11, 7, -6, -1], [5, 0, -4, -5], [5, 0, -1, -6], [5, 1, 1, -6],
    [4, 2, 5, -4], [5, 2, 7, -1], [6, 3, 6, 0], [5, 3, 6, 2],
    [3, 4, 4, 6], [4, 5, 0, 6], [3, 5, -4, 6], [5, 6, -5, 4],
    [7, 6, -6, 1], [16, 6, -6, 0], [16, 6, -6, 0], [61, 3, 4, 3],
];

export const PATTERN_6 = [
    [2, 0, 283, 199], [24, 0, 0, -6], [4, 0, -1, -6], [3, 7, -6, -4],
    [4, 7, -7, 0], [25, 6, -6, 0], [6, 6, -6, 0], [4, 5, -4, 4],
    [3, 5, -1, 7], [16, 4, 0, 6], [5, 4, 3, 5], [5, 3, 7, 1],
    [8, 3, 6, 0], [5, 2, 6, -2], [3, 1, 2, -5], [21, 1, 1, -6],
    [3, 1, 4, -6], [3, 2, 6, -2], [4, 3, 6, 1], [3, 3, 5, 2],
    [5, 4, 2, 5], [23, 4, 0, 6], [23, 4, 0, 6], [27, 4, 0, 6],
];

export const PATTERN_7 = [
    [2, 0, 17, 199], [14, 0, 0, -6], [3, 1, 3, -5], [3, 2, 6, -3],
    [7, 2, 6, -1], [13, 2, 6, 0], [12, 2, 6, 0], [5, 3, 6, 1],
    [3, 2, 6, -2], [4, 1, 1, -5], [2, 0, -1, -7], [3, 7, -5, -4],
    [3, 7, -7, 0], [16, 7, -6, 0], [4, 6, -6, 1], [3, 5, -4, 5],
    [5, 5, -2, 6], [8, 5, 0, 6], [3, 4, 1, 7], [5, 4, 4, 4],
    [6, 3, 4, 3], [11, 3, 5, 1], [11, 3, 5, 1], [15, 3, 5, 1],
];

export const PATTERN_8 = [
    [2, 0, 281, 199], [12, 0, 0, -6], [3, 0, -2, -5], [3, 7, -5, -5],
    [3, 7, -5, -3], [4, 7, -7, -1], [23, 6, -6, 0], [6, 7, -6, 0],
    [3, 7, -6, -3], [3, 0, -1, -7], [3, 1, 1, -6], [2, 2, 6, -5],
    [3, 2, 7, -1], [15, 2, 6, 0], [4, 3, 7, 1], [3, 4, 5, 5],
    [4, 4, 2, 5], [3, 4, 0, 7], [3, 5, -2, 6], [6, 5, -3, 5],
    [7, 6, -4, 3], [12, 6, -5, 3], [12, 6, -5, 3], [16, 6, -5, 3],
];

export const PATTERN_9 = [
    [2, 3, -16, 13], [26, 3, 4, 3], [7, 3, 6, 2], [5, 3, 6, 0],
    [5, 2, 5, -3], [5, 1, 3, -5], [3, 0, 0, -7], [4, 0, -3, -5],
    [4, 7, -6, -3], [6, 7, -6, 0], [5, 6, -7, 1], [4, 6, -5, 4],
    [4, 5, 0, 7], [15, 4, 0, 6], [4, 4, 4, 4], [3, 3, 6, 3],
    [12, 2, 6, 0], [11, 2, 5, -3], [4, 1, 4, -5], [11, 1, 1, -6],
    [4, 0, -2, -7], [7, 7, -5, -2], [27, 6, -6, 0], [5, 6, -5, 3],
    [4, 5, -4, 6], [4, 5, 0, 7], [8, 4, 1, 6], [5, 4, 1, 6],
    [9, 3, 5, 2], [37, 3, 6, 0], [37, 3, 6, 0], [41, 3, 6, 0],
];

export const PATTERN_10 = [
    [1, 2, 148, -15], [55, 2, 0, 3], [1, 2, 0, 4], [2, 2, 1, 3],
    [1, 2, 0, 4], [3, 1, 2, 2], [1, 2, 1, 3], [4, 1, 3, 1],
    [1, 1, 1, 1], [17, 7, 3, 0], [1, 7, 4, 0], [4, 7, 3, -1],
    [1, 6, 1, -3], [2, 6, 2, -2], [1, 6, 1, -2], [2, 5, 0, -3],
    [1, 6, 1, -4], [12, 5, 0, -3], [1, 5, 0, -4], [2, 5, -1, -3],
    [1, 5, -1, -4], [2, 5, -2, -3], [1, 5, -1, -2], [4, 4, -3, -1],
    [1, 4, -1, -1], [16, 3, -3, 0], [1, 3, -2, 0], [2, 4, -3, -1],
    [1, 4, -4, -1], [2, 4, -2, -2], [1, 4, -3, -1], [3, 5, -1, -3],
    [1, 6, 1, -2], [11, 5, 0, -3], [1, 5, 0, -4], [4, 5, -1, -3],
    [1, 4, -2, -1], [2, 4, -2, -2], [1, 4, -2, -2], [3, 4, -3, -1],
    [1, 3, -4, 0], [27, 3, -3, 0], [1, 3, -3, 0], [4, 3, -3, 1],
    [1, 3, -3, 0], [3, 3, -3, 2], [1, 2, -1, 2], [5, 2, -1, 3],
    [1, 2, -1, 1], [32, 2, 0, 3], [1, 2, 0, 2], [4, 2, 1, 3],
    [1, 2, 0, 3], [3, 2, 2, 3], [1, 1, 1, 1], [5, 1, 3, 1],
    [1, 7, 3, -1], [15, 7, 3, 0], [1, 1, 2, 1], [4, 7, 3, -1],
    [1, 6, 1, -3], [3, 6, 2, -2], [1, 6, 1, -3], [4, 6, 1, -3],
    [1, 5, -1, -2], [16, 5, 0, -3], [1, 5, 0, -2], [1, 5, -1, -4],
    [1, 5, 0, -3], [1, 4, -3, -3], [1, 4, -2, -2], [3, 4, -3, -1],
    [1, 3, -4, 0], [1, 4, -3, -2], [1, 4, -2, -2], [1, 5, 0, -4],
    [1, 5, 0, -3], [21, 5, 0, -3], [5, 5, 0, -4],
];

export const ALL_PATTERNS = [
    PATTERN_0, PATTERN_1, PATTERN_2, PATTERN_3, PATTERN_4, PATTERN_5,
    PATTERN_6, PATTERN_7, PATTERN_8, PATTERN_9, PATTERN_10,
];

// ── Boss Patterns ────────────────────────────────────────────────
// Format: [delay, unused, dx, dy] — first element is [0, 0, startX, startY]

export const BOSS_PATTERN_0 = [
    [0, 0, 240, 10], [90, 0, 0, 1], [115, 0, -2, 0],
    [90, 0, 0, -1], [115, 0, 2, 0],
];

export const BOSS_PATTERN_1A = [
    [0, 0, 10, 10], [50, 0, 0, 2], [10, 0, 0, 0], [50, 0, 0, -2],
];

export const BOSS_PATTERN_1B = [
    [0, 0, 246, 10], [50, 0, -2, 0], [10, 0, 0, 0], [50, 0, 2, 0],
];

export const BOSS_PATTERN_4A = [
    [0, 0, 10, 10], [75, 0, 0, 2], [123, 0, 2, 0],
    [75, 0, 0, -2], [123, 0, -2, 0],
];

export const BOSS_PATTERN_4B = [
    [0, 0, 246, 150], [75, 0, 0, -2], [123, 0, -2, 0],
    [75, 0, 0, 2], [123, 0, 2, 0],
];

export const LAVABALL_LEFT = [
    [2, 10, 41, 33],
    [1, 10, 1, 8], [1, 10, 1, 7], [1, 10, 2, 7], [1, 10, 1, 6],
    [1, 10, 2, 7], [1, 10, 1, 6], [1, 10, 2, 7], [1, 10, 1, 6],
    [1, 10, 2, 7], [1, 10, 1, 6], [1, 10, 2, 7], [1, 10, 2, 6],
    [1, 9, 3, 6], [1, 10, 2, 6], [1, 9, 3, 6], [1, 9, 3, 6],
    [1, 9, 5, 6], [1, 9, 4, 5], [1, 8, 5, 4], [1, 8, 5, 4],
    [1, 7, 7, 3], [1, 8, 6, 3], [1, 7, 8, 2], [1, 7, 8, 1],
    [1, 7, 8, 1], [1, 6, 8, 0], [1, 6, 8, -1], [1, 6, 8, 0],
    [1, 6, 8, -1], [1, 6, 8, 0], [1, 6, 8, -1], [1, 6, 7, -1],
    [2, 6, 8, -1], [1, 6, 7, -2], [13, 6, 8, -1], [1, 3, 2, -6],
];

export const LAVABALL_RIGHT = [
    [2, 10, 255, 33],
    [1, 10, -2, 7], [1, 9, -1, 7], [1, 10, -2, 7], [1, 10, -1, 6],
    [1, 10, -2, 8], [1, 9, -1, 7], [1, 10, -2, 8], [1, 10, -2, 8],
    [1, 10, -2, 8], [1, 10, -2, 8], [1, 10, -3, 8], [1, 10, -3, 7],
    [1, 10, -4, 7], [1, 10, -3, 7], [1, 11, -5, 7], [1, 11, -5, 6],
    [1, 12, -7, 4], [1, 12, -6, 4], [1, 13, -8, 2], [1, 12, -7, 2],
    [1, 12, -7, 2], [1, 13, -7, 1], [1, 13, -9, 0], [1, 13, -8, 0],
    [1, 14, -9, -1], [1, 13, -8, 0], [18, 14, -8, -1], [1, 15, -8, -7],
];

// ── Level Configuration ──────────────────────────────────────────

export const LEVELS = [
    {
        name: 'Cavern', scroll_dir: 'horizontal',
        max_aliens: 4, min_wave: 2, max_wave: 4,
        boss_type: 'single', boss_hp: 40,
        boss_patterns: [BOSS_PATTERN_0],
        boss_sprites: ['Level-Zero', 'clockwork-bug', 8],
    },
    {
        name: 'Sandstorm', scroll_dir: 'vertical', cycle: true,
        max_aliens: 6, min_wave: 3, max_wave: 5,
        boss_type: 'dual', boss_hp: 30,
        boss_patterns: [BOSS_PATTERN_1A, BOSS_PATTERN_1B],
        boss_sprites: ['Level-Zero', 'clockwork-bug', 8],
    },
    {
        name: 'Cheese', scroll_dir: 'horizontal',
        max_aliens: 6, min_wave: 2, max_wave: 6,
        boss_type: 'circular', boss_hp: 15,
        boss_patterns: [],
        boss_sprites: ['Level-Zero', 'clockwork-bug', 8],
    },
    {
        name: 'Lava', scroll_dir: 'vertical', cycle: true,
        max_aliens: 6, min_wave: 2, max_wave: 5,
        boss_type: 'lavaball', boss_hp: 20,
        boss_patterns: [LAVABALL_LEFT, LAVABALL_RIGHT],
        boss_sprites: ['Level-Three', 'FireBall-16', 16],
    },
    {
        name: 'Hangar', scroll_dir: 'horizontal',
        max_aliens: 8, min_wave: 2, max_wave: 6,
        boss_type: 'dual', boss_hp: 30,
        boss_patterns: [BOSS_PATTERN_4A, BOSS_PATTERN_4B],
        boss_sprites: ['Level-Four', 'HangerBall', 16],
    },
];

// Background enemy positions per level (world coordinates)
export const LEVEL_BG_ENEMIES = {
    1: [
        { x: 228, y: 354, type: 'eye', hp: 4 },
        { x: 109, y: 616, type: 'eye', hp: 4 },
        { x: 267, y: 718, type: 'eye', hp: 4 },
        { x: 90, y: 823, type: 'eye', hp: 4 },
        { x: 186, y: 974, type: 'eye', hp: 4 },
    ],
    3: [
        { x: 111, y: 59, type: 'lava_eye', hp: 8 },
        { x: 188, y: 59, type: 'lava_eye', hp: 8 },
        { x: 253, y: 692, type: 'iris', hp: 6 },
        { x: 72, y: 697, type: 'iris', hp: 6 },
        { x: 216, y: 860, type: 'iris', hp: 6 },
        { x: 19, y: 905, type: 'iris', hp: 6 },
        { x: 175, y: 1071, type: 'iris', hp: 6 },
    ],
    4: [
        { x: 161, y: 91, type: 'iris', hp: 6 },
        { x: 259, y: 71, type: 'hexgun', hp: 4 },
        { x: 314, y: 122, type: 'hexgun', hp: 4 },
        { x: 335, y: 31, type: 'hexgun', hp: 4 },
        { x: 429, y: 102, type: 'hexgun', hp: 4 },
        { x: 562, y: 33, type: 'hexgun', hp: 4 },
        { x: 618, y: 63, type: 'hexgun', hp: 4 },
        { x: 618, y: 101, type: 'hexgun', hp: 4 },
        { x: 917, y: 41, type: 'iris', hp: 6 },
        { x: 917, y: 100, type: 'iris', hp: 6 },
        { x: 917, y: 162, type: 'iris', hp: 6 },
    ],
};

// Map bg enemy types to sprite assets: [directory, name, frame_count]
export const BG_ENEMY_SPRITES = {
    1: { eye: ['Level-One', 'Eye', 9] },
    3: {
        lava_eye: ['Level-Three', 'Lava-Eye', 13],
        iris: ['Level-Three', 'Iris-3D', 19],
    },
    4: {
        hexgun: ['Level-Four', 'Hex-Gun', 15],
        iris: ['Level-Four', 'HangerIris', 10],
    },
};

// Background names per level
export const LEVEL_BG = [
    ['Level-Zero', 'Back0'],
    ['Level-One', 'Back1'],
    ['Level-Two', 'Back2'],
    ['Level-Three', 'back3'],
    ['Level-Four', 'back4'],
];

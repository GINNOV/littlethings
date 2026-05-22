typedef enum {
  MUSIC_OFF = 0,
  MUSIC_HEAVY = 1,
  MUSIC_AMBIENT_SFX = 2
} tMusicState;

typedef enum {
  AMIGA_MODE_OFF = 0,
  AMIGA_MODE_ON = 1,
  AMIGA_MODE_CHECK = 2, // check if amiga mode reached w/o cheating
} tAmigaMode;

typedef enum {
  FLY_OFF = 0,
  FLY_PREP = 1,
  FLY_ENDING = 2,
  FLY_DB = 3,
  FLY_PROCEED = 4,
} tFlyingState;

typedef enum {
  LEVEL_SCORE_OFF = 0,
  LEVEL_SCORE_COUNT = 1,
  LEVEL_SCORE_PORTAL_OPEN = 2,
  LEVEL_SCORE_PORTAL_ANIM = 3,
  LEVEL_SCORE_PORTAL_CLOSE = 4,
  LEVEL_SCORE_END = 5,
  LEVEL_SCORE_NOCOAL = 6
} tEndLevelState;

typedef enum {
  METEORITE = '3',
  COAL_2 = '4',
  COAL_3 = '5',
  COAL_4 = '6',
  COAL_5 = '7',
  CAPACITOR_BLUE = '8',
  CAPACITOR_RED = '9',
  PORTAL = 'E',
  ROBBO = 'R',
  CAPACITOR_BROKEN = 'B',
  SABERMANS_GUMBOOT = 'S',
  FALCON_START_POSITION = '1',
  EMPTY_TILE = '0' 
} tDrawingTilesetElements;

typedef enum {
  METEORITE_INT = 3,
  COAL_2_INT = 4,
  COAL_3_INT = 5,
  COAL_4_INT = 6,
  COAL_5_INT = 7,
  CAPACITOR_BLUE_INT = 8,
  CAPACITOR_RED_INT = 9,
  PORTAL_INT = 10,
  ROBBO_INT = 11,
  CAPACITOR_BROKEN_INT = 12,
  SABERMANS_GUMBOOT_INT = 13,
  FALCON_START_POSITION_INT = 1,
  EMPTY_TILE_INT = 0
} tIntTilesetElementsControl;

typedef enum {
  AMIGA_HUD_TICK_TEMPO = 60,
  PORTAL_TICK_TEMPO = 4,
  LEVEL_SCORE_TEMPO = 8,
  HUD_FONT_COLOR = 23,
  TEXT_BITMAP_WIDTH = 320
} tMiscSetupValues;

typedef enum {
  OFF = 0,
  END = 1,
  GAME_OVER = 2,
  CHEATER_GAME_OVER = 3
} tEndGameResult;

typedef enum {
  PRINT_ON_HUD = 0,
  HUD_SCROLL_UP = 1,
  HUD_SCROLL_DOWN = 2,
  HUD_ROBBO_MSG = 3
} tHUDScrollingHandler;
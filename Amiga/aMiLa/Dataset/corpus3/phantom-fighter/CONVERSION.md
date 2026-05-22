# Phantom Fighter - Amiga to Python/Pygame Conversion

## Overview

This document describes how the original 1988 Amiga game was converted to a modern Python/Pygame application, mapping each Amiga hardware subsystem and game mechanic to its Python equivalent.

The conversion consists of two tools:
- **`python/convert_graphics.py`** — Converts original Amiga graphic assets (EMRL/IFF formats) to PNG files
- **`python/phantom_fighter.py`** — The complete game reimplemented in Python/Pygame

---

## Display System

### Original: Amiga Custom Chipset

The Amiga's display is driven entirely by the **Copper** coprocessor — a programmable DMA engine that executes a "copper list" of instructions once per frame, synchronized to the video beam. The copper list programs:

- **Bitplane pointers** — Which memory addresses the video DMA reads for each bitplane
- **Color registers** — COLOR00 through COLOR31 (12-bit RGB each)
- **Display modes** — `BPLCON0` register sets resolution, number of bitplanes, HAM mode, dual playfield mode
- **Scroll offsets** — `BPLCON1` register sets per-pixel horizontal scroll
- **Display window** — `DIWSTRT`/`DIWSTOP` define the visible area
- **Data fetch** — `DDFSTRT`/`DDFSTOP` control when DMA fetches bitmap data

The game uses **three different copper lists** for different display contexts:

1. **`TitleCopper`** — HAM6 mode (6 bitplanes, 4096 colors) for the title screen
2. **`MainCopper`** — Dual Playfield mode during gameplay, split into:
   - Top section: Sprite pointers (hardware sprites)
   - Gameplay area: 3+2 bitplane dual playfield (background + foreground)
   - Status panel: Separate bitmap with different colors
3. **`LoadCopper`** — Simple display for the loading screen

The copper list switches display modes mid-screen by inserting **WAIT instructions** at specific scanlines. For example, `MainCopper` uses WAITs to transition from the gameplay area to the status panel 176 scanlines down.

### Conversion: Pygame Surfaces

```python
INTERNAL_W = 320    # Original Amiga low-res width
INTERNAL_H = 200    # Original Amiga screen height (NTSC)
SCALE = 3           # Display at 960x600
VIEW_H = 176        # Gameplay area (below this is the status panel)
PANEL_H = 24        # Status bar height
```

All rendering is done to an **internal 320x200 surface** matching the original resolution, then scaled 3x for display. This preserves the pixel-art aesthetic and ensures correct proportions.

| Amiga System | Pygame Equivalent |
|-------------|-------------------|
| Copper list color registers | Direct RGB values in code |
| Dual Playfield (3+2 bitplanes) | Layered surface blitting (background first, then sprites) |
| HAM6 title screen | Pre-rendered RGB surfaces via `_load_title_ham6()` |
| Hardware scroll registers | `pygame.Rect` source rectangle offset into background surface |
| Status panel (separate bitmap) | `draw_panel()` renders text directly onto the internal surface |
| Copper mid-screen mode switch | Single surface, gameplay drawn in top 176 rows, panel in bottom 24 |
| WAIT-based scanline sync | Not needed — full-frame rendering |

### Blitter vs Software Rendering

The original game renders all game objects (aliens, bullets, explosions) using the Amiga's **Blitter** — a DMA coprocessor that performs high-speed memory-to-memory copies with logical operations. The blitter handles:

- **Bob (Blitter Object) rendering** — Copy sprite data onto the playfield bitmap with masking (transparency)
- **Cookie-cut masking** — Logical AND/OR operations to properly overlay sprites
- **Save-and-restore** — Background under sprites is saved and restored for clean animation

In Pygame, this is replaced by simple `Surface.blit()` calls with alpha transparency (RGBA PNG sprites). The blitter queue system (`BLTListRead/BLTListWrite` in `ic.c`) is unnecessary since Pygame handles compositing automatically.

---

## Scrolling

### Original: Hardware Scroll

The Amiga scrolls by manipulating two registers:

1. **Bitplane pointers** (`BPLxPT`) — Coarse scroll by changing which memory row the display starts from
2. **`BPLCON1`** — Fine scroll (0-15 pixel horizontal offset)

The background bitmap is larger than the screen (1216x200 for horizontal, 320x1200 for vertical). Scrolling increments an offset and the copper list is updated to point to the appropriate memory location.

```c
#define SCROLLTICKS 3  // Move 1 pixel every 3 frames
```

Scrolling is event-driven — a scroll function is registered as a VBI task that fires every `SCROLLTICKS` frames.

### Conversion: Source Rectangle

```python
SCROLL_TICKS = 3
SCROLL_SPEED = 1

# Horizontal scrolling
if self.scroll_dir == 'horizontal':
    src = pygame.Rect(int(self.scroll_x), 0, INTERNAL_W, VIEW_H)
else:
    src = pygame.Rect(0, int(self.scroll_y), INTERNAL_W, VIEW_H)
self.internal.blit(self.background, (0, 0), src)
```

The background is loaded as a single large surface. Scrolling is achieved by moving a 320x176 source rectangle across it. The scroll counter increments every 3 frames, matching the original `SCROLLTICKS` timing.

---

## Color Cycling

### Original: Copper Register Rotation

The `_ColorCycler` in `isrs.asm` runs during the vertical blank interrupt every 6 frames. It directly manipulates copper list entries, rotating the values stored at offset 186 (which corresponds to COLOR13, COLOR14, COLOR15 in the gameplay copper list):

```asm
lea.l  186(a0),a0      ; &copper[COLOR13]
move.w 8(a0),d0        ; temp = COLOR15
move.w 4(a0),8(a0)     ; COLOR15 = COLOR14
move.w (a0),4(a0)      ; COLOR14 = COLOR13
move.w d0,(a0)         ; COLOR13 = temp
```

In Dual Playfield mode, COLOR13-15 map to **playfield 1 palette indices 5-7** (rear playfield colors). This creates a shimmering effect in the sand (Level 1) and lava (Level 3) backgrounds.

### Conversion: Palette Surface Manipulation

For cycling levels, the background PNG is converted back to an **8-bit indexed palette surface**:

```python
def _load_cycling_bg(subdir, name):
    # 1. Read original EMRL palette (12-bit Amiga colors)
    # 2. Load RGB PNG
    # 3. Map each pixel back to palette index via color matching
    # 4. Create pygame 8-bit surface with palette
    pal_surf = pygame.Surface((w, h), depth=8)
    pal_surf.set_palette(palette)
    # Map pixels using numpy-style masking for speed
    for idx, col in enumerate(palette):
        mask = (arr_rgb == col).all(axis=2)
        arr_idx[mask] = idx
    return pal_surf
```

Cycling then rotates palette entries:

```python
def _cycle_palette(surface):
    pal = list(surface.get_palette())
    pal[5], pal[6], pal[7] = pal[7], pal[5], pal[6]
    surface.set_palette(pal)
```

### Title Screen Color Cycling

The title screen uses HAM6 where palette manipulation changes the base colors that HAM pixels reference. Since HAM rendering depends on the palette, we **pre-render 3 complete frames** with rotated palettes at load time, then cycle between them:

```python
for _ in range(3):
    surfaces.append(render_ham6(pal))
    pal[13], pal[14], pal[15] = pal[15], pal[13], pal[14]
```

---

## Graphics Conversion Pipeline

### The Problem

Amiga graphics are stored as **interleaved bitplane data** — each pixel's color is spread across N separate memory planes. A 3-bitplane (8-color) image stores bit 0 of each pixel in plane 0, bit 1 in plane 1, etc. This is optimal for the Amiga's DMA hardware but requires conversion for modern displays.

### EMRL Format Decoding (`convert_graphics.py`)

The EMRL format stores graphics in a chunked binary format:

```
EMRL header → TOTL → COLR → [BMFO → PLNE × depth] × total_images
```

**Step 1: Parse palette** (COLR chunk)
- Read 16-32 Amiga 12-bit color words (0x0RGB)
- Expand to 8-bit: `r = ((word >> 8) & 0xF) * 17`

**Step 2: Read bitmap info** (BMFO chunk)
- Width, height, depth (bitplanes), PlanePick mask, PlaneOnOff defaults
- GRAB hotspot coordinates (HotX, HotY)

**Step 3: Decompress bitplanes** (PLNE chunks)
- Each bitplane is RLE compressed independently
- The RLE scheme alternates between literal and repeat runs
- `PlanePick` bitmask indicates which planes have data; missing planes are filled from `PlaneOnOff`

**Step 4: Assemble pixels**
- For each pixel (x, y), extract the corresponding bit from each bitplane
- Combine bits to form a palette index
- Look up the RGB color from the palette

**Step 5: Transparency**
- Sprite images (width < 320): palette index 0 becomes transparent (RGBA with alpha=0)
- Full-screen images: no transparency

### HAM6 Decoding

When `depth == 6`, the image uses Hold And Modify mode:

```python
for y in range(height):
    prev_r, prev_g, prev_b = palette[0]  # Scanline starts with color 0
    for x in range(width):
        val = extract_6_bits(planes, x, y)
        control = (val >> 4) & 3
        data = val & 0xF
        if control == 0:    # Palette lookup
            prev_r, prev_g, prev_b = palette[data]
        elif control == 1:  # Modify blue
            prev_b = data * 17
        elif control == 2:  # Modify red
            prev_r = data * 17
        elif control == 3:  # Modify green
            prev_g = data * 17
```

This produces a true-color image from the 6-bitplane source data. HAM6 is only used for the title screen — all gameplay graphics use standard indexed colors.

### IFF/ILBM Decoding

Animated sprites use the standard Amiga IFF format:

- **Single frames:** `FORM ILBM { BMHD, CMAP, BODY }` — header, palette, interleaved bitplane data
- **Animations:** `FORM ANBM { TOTL, LIST ILBM { PROP ILBM { shared BMHD, CMAP }, FORM ILBM ... } }` — shared palette/header, multiple frames

IFF BODY data uses **ByteRun1** compression (different from EMRL's RLE):
- Byte N < 128: copy next N+1 bytes literally
- Byte N > 128: repeat next byte (257-N) times
- Byte N = 128: no-op

IFF interleaves all bitplanes row by row (plane 0 row 0, plane 1 row 0, ..., plane 0 row 1, ...) whereas EMRL stores each complete plane as a separate chunk.

### Output

All converted graphics are saved as PNG files in `modern-bitmaps/`, organized by level:

```
modern-bitmaps/
  Level-All/        ships, explosions, tokens, player, bullets, panel
  Level-Zero/       Back0, clockwork-bug (8 frames)
  Level-One/        Back1, Eye (9 frames), DeadEye (12 frames)
  Level-Two/        Back2, Plant-A through Plant-E, Star-Bobs
  Level-Three/      back3, Iris-3D (19), Lava-Eye (13), FireBall-16 (16)
  Level-Four/       back4, Hex-Gun (15), HangerBall (16), HangerIris (10)
  Screens/          Title-Screen, LoadingScreen, Game-Over, EmeraldLogo
```

Multi-frame sprites are saved as `name_frame0.png`, `name_frame1.png`, etc.

---

## Sound System

### Original: Paula DMA Channels

The Amiga's Paula chip provides 4 DMA audio channels. The game's `sound.c` manages these with a round-robin allocator:

```c
custom.aud[ChanNo].ac_ptr = Sample;          // Pointer to sample data (chip RAM)
custom.aud[ChanNo].ac_len = SampleSize >> 1;  // Length in words
custom.aud[ChanNo].ac_vol = Volume;           // 0-63
custom.aud[ChanNo].ac_per = Period;           // Sample rate (clock / period)
custom.dmacon = 0x8000 + (1 << ChanNo);       // Enable DMA
```

Samples are 8-bit signed PCM stored as raw binary (`.sfx` files). The Amiga DMA plays `ac_len` words at the rate `NTSC_CLOCK / period` Hz, then loops the sample continuously until DMA is stopped.

### Conversion: Pygame Mixer

**Critical gotcha:** `pygame.init()` initializes the mixer with default settings (44100 Hz, 16-bit, stereo). A subsequent `pygame.mixer.init()` call is **silently ignored** if the mixer is already running. You must use `pygame.mixer.pre_init()` before `pygame.init()`:

```python
pygame.mixer.pre_init(frequency=44100, size=-16, channels=1, buffer=1024)
pygame.init()
```

The mixer runs at **44100 Hz, signed 16-bit, mono**. This is essential because the Amiga plays instrument samples at 14–28 kHz. An 11025 Hz mixer would downsample without anti-aliasing, destroying the waveforms and making nothing sound like an instrument.

### Sound Effects

```python
def load_sound(name):
    raw = np.frombuffer(sfx_path.read_bytes(), dtype=np.int8).astype(np.int16)
    raw = np.repeat(raw, 4) * 256   # upsample 4x to 44100 Hz, scale to 16-bit
    return pygame.mixer.Sound(buffer=raw.tobytes())
```

The original `.sfx` files are raw signed 8-bit PCM at approximately 8,949–11,046 Hz (depending on the playback period). For the 44100 Hz mixer, each sample is repeated 4× using zero-order hold (matching the Amiga DAC's behavior) and scaled from 8-bit to 16-bit.

### Music (SMUS Playback)

The `MusicPlayer` class parses the SMUS file and **pre-renders** all 3 tracks to a single looping buffer:

1. **Load instrument samples** — Read `.sfx` files, truncating or zero-padding to match the game's original `LoadSample()` sizes (e.g., `BASS1SIZE=2000`, `BASSGUITARSIZE=2400`)
2. **Parse SMUS events** — Walk each track's event stream, processing instrument changes (sID=0x81) and rendering notes/rests
3. **Resample notes** — For each note, compute `amiga_rate = 3,579,545 / period`, then resample the instrument sample from `amiga_rate` to 44100 Hz using **linear interpolation** with **modular wrapping** (simulating Amiga DMA's sample looping)
4. **Per-track looping** — Each track loops independently in the original. Shorter tracks are tiled (`np.tile`) to match the longest track's duration
5. **Mix and normalize** — Sum all tracks, normalize to 70% headroom, convert to signed 16-bit

The tick rate is set to **50 Hz** (PAL VBI rate), matching the original game's tempo:

```python
self.samples_per_tick = mixer_rate / 50.0  # PAL timing
```

Key implementation details:
- Octave tables (128-entry period lookup) are transcribed exactly from `sound.c`
- Instrument changes set both the sample data and optionally the octave table (instruments 0 and 3 switch octaves; 1, 2, 4 leave it unchanged)
- Control events other than SID_Instrument (TimeSig, KeySig, Dynamic) are consumed but **ignored**, matching the original game's behavior
- The SHDR tempo field (16047) is also ignored — timing is purely VBI tick-driven

---

## Game Architecture

### Original: Event-Driven Scheduler

The Amiga game uses a cooperative scheduler where game entities are independent **events** dispatched by a time-ordered queue. Each entity (alien, bullet, boss, scroll task) is a scheduled event with a callback function and next-execution time.

The vertical blank interrupt drives the system — each frame, events whose time has arrived are dispatched.

### Conversion: Traditional Game Loop

The Python version uses a conventional 60fps game loop:

```python
def run(self):
    while running:
        handle_events()       # Pygame event pump
        update_gameplay()     # All entity updates
        draw_gameplay()       # All rendering
        pygame.display.flip()
        self.clock.tick(FPS)  # 60 fps cap
```

Each entity class has `update()` and `draw()` methods called every frame, replacing the scheduler's event dispatch. This is simpler and more maintainable while achieving the same result.

---

## Entity Mapping

### Player Ship

| Original | Python |
|----------|--------|
| `OurShipData` struct with function pointers | `Player` class with properties |
| Hardware sprite or Bob | `Surface.blit()` with per-frame sprite |
| Joystick input via hardware register reads | `pygame.key.get_pressed()` |
| 11 banking frames with timed transitions | Same — `PLAYER_BANK_DELAY = 6` frame timer |
| Ship rotated per level (horiz=right, vert=up) | `pygame.transform.rotate(-90)` for horizontal frames |

### Alien Waves

| Original | Python |
|----------|--------|
| `WVE_DEF` struct + `AlienParam` struct | `Wave` class + `Alien` class |
| Pattern data in `patterns.c` | 11 `PATTERN_N` lists (exact data transcription) |
| `anm_element` {Count, FrameNo, Xoffset, Yoffset} | Tuple (delay, frame, dx, dy) |
| Movement at full speed | Movement at half speed (`dx * 0.5, dy * 0.5`) to match feel |
| Pattern mirroring in alien spawner | `_mirror_pattern_h()` / `_mirror_pattern_v()` |

### Bosses

| Original | Python |
|----------|--------|
| `bigguy.c` — AnimateAGuy, MakeLavaBall | `Boss` class, `CircularBoss` class |
| Boss patterns (rectangular, oscillating) | `BOSS_PATTERN_0` through `BOSS_PATTERN_4B` |
| Lava ball parabolic arcs | `LAVABALL_LEFT` / `LAVABALL_RIGHT` with `loop_reset=True` |
| Level 2 circular boss | `CircularBoss` — segments orbit with `math.cos`/`math.sin` |

### Background Enemies (Turrets)

| Original | Python |
|----------|--------|
| `eyes.c` — Eye turrets | `BackgroundEnemy` class with `enemy_type='eye'` |
| World position fixed in background | `world_x, world_y` — converted to screen coords via scroll offset |
| Open/close animation + fire when open | `anim_dir` ping-pong + `should_fire()` checks frame |
| 8-direction lava eye spread | 8 `AlienBullet` instances at 45-degree angles |
| GRAB hotspot centering | `screen_pos()` subtracts `width//2, height//2` |

### Collision Detection

| Original | Python |
|----------|--------|
| Blitter collision registers + `collchk.asm` | `pygame.Rect.colliderect()` bounding box tests |
| Hardware pixel-perfect via blitter | Rectangle approximation (close enough for gameplay) |

---

## Sprite Hotspot (GRAB) System

The EMRL format stores a **GRAB hotspot** (HotX, HotY) per sprite frame — the logical center point. On the Amiga, when rendering a Bob, the blitter subtracts the hotspot from the logical position to find the top-left corner for drawing.

In the Python version, all sprite classes center their drawing position:

```python
def _draw_pos(self):
    w = self.frames[0].get_width()
    h = self.frames[0].get_height()
    return int(self.x) - w // 2, int(self.y) - h // 2
```

This applies to `Alien`, `Boss`, `CircularBoss`, and `BackgroundEnemy` classes.

---

## Timing and Frame Rate

### Original: VBI-Driven

The Amiga game is driven by the vertical blank interrupt at the display refresh rate:
- NTSC: 60 Hz (60 VBIs per second)
- PAL: 50 Hz (50 VBIs per second)

All timing constants (scroll speed, animation delays, firing rates) are calibrated for this rate. The `sys_time` counter increments each VBI.

### Conversion: 60fps Clock

```python
FPS = 60
self.clock.tick(FPS)
```

The Python version targets 60fps to match NTSC timing. All timing constants from the original are used directly without conversion.

---

## Level Configuration

### Original: C Struct Array

```c
struct LevelBlock LevelBlk[5] = {
    { 0, 4, 4, 4, LB_BigAliens|LB_ScrollHoriz, 0, 0, 2 },
    { 1, 6, 5, 6, LB_BigAliens|LB_FireAlways|LB_Turrets|LB_Satellite|LB_CycleOn|LB_ScrollVert, 1, 2, 3 },
    // ...
};
```

### Conversion: Python Dicts

```python
LEVELS = [
    {
        'name': 'Cavern', 'scroll_dir': 'horizontal',
        'max_aliens': 4, 'min_wave': 2, 'max_wave': 4,
        'boss_type': 'single', 'boss_hp': 40,
        'boss_patterns': [BOSS_PATTERN_0],
        'boss_sprites': ('Level-Zero', 'clockwork-bug', 8),
    },
    // ...
]
```

The bit flags (`LB_ScrollHoriz`, `LB_CycleOn`, etc.) are replaced with descriptive dictionary keys (`'scroll_dir': 'horizontal'`, `'cycle': True`).

---

## What Was Simplified

Some Amiga-specific systems have no direct equivalent and were simplified or omitted:

| Original Feature | Conversion Approach |
|------------------|-------------------|
| Cooperative event scheduler | Standard game loop with `update()`/`draw()` per entity |
| Blitter queue (deferred rendering) | Immediate `Surface.blit()` calls |
| Hardware sprites (8 sprite channels) | All sprites rendered as surface blits |
| Chip RAM / Fast RAM distinction | N/A — modern systems have unified memory |
| Copper list mid-screen mode switches | Single surface, gameplay area above, panel below |
| Display list (z-ordered Bob rendering) | Explicit draw order in `draw_gameplay()` |
| Custom memory allocator | Python garbage collection |
| Interrupt-driven keyboard handler | `pygame.event` / `pygame.key.get_pressed()` |
| SMUS music format playback | `MusicPlayer` class — pre-renders 3 tracks to a looping buffer |
| Demo mode (attract sequence) | Not yet implemented |
| High score persistence | Not yet implemented |

---

## File Structure

```
PhantomFighter/
  NTSC/                          # Original NTSC source + assets
    scheduler/source/            # 55+ C files + assembly
    scheduler/header/            # 37 header files
    graphics/                    # Original Amiga format assets
      Level-All/                 # Shared assets (ships, explosions, tokens)
      Level-Zero/ through Level-Four/  # Per-level assets
      Screens/                   # Title, loading, game over screens
      Sound/                     # Raw 8-bit PCM samples (.sfx)
  PAL/                           # PAL version (50Hz) source + assets
  modern-bitmaps/                # Converted PNG assets (generated)
  python/
    phantom_fighter.py           # Complete game (~2150 lines)
    convert_graphics.py          # Asset converter (~570 lines)
    requirements.txt             # pygame, Pillow, numpy
    .venv/                       # Python virtual environment
```

---

## Running the Conversion

```bash
# Set up environment
cd python
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Convert original graphics to PNG
python convert_graphics.py

# Run the game
python phantom_fighter.py
```

The graphics converter reads from `NTSC/graphics/` and writes PNGs to `modern-bitmaps/`. The game reads from `modern-bitmaps/` for sprites and backgrounds, and directly from `NTSC/graphics/` for the title screen (HAM6 rendered at runtime), sound effects (raw PCM `.sfx` files), and music (`beat.smus` + instrument samples).

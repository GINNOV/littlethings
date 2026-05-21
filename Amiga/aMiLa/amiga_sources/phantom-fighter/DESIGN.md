# Phantom Fighter - Original Game Design Document

## Overview

**Phantom Fighter** was developed in 1988 for the Commodore Amiga by Billy Newport under the Emerald Software label. It was published by **Martech** in the UK and released in the USA by **Broderbund** under the title *"If It Moves, Shoot It"*.

It is a horizontally and vertically scrolling shoot-em-up with 5 distinct levels, weapon upgrades, boss battles, and a cooperative event-driven scheduler architecture.

---

## Hardware Target

- **Platform:** Commodore Amiga (A500/A1000/A2000)
- **CPU:** Motorola 68010 (tuned for 68010 instruction set)
- **Video:** OCS chipset — Agnus (blitter/copper/DMA), Denise (display)
- **Display:** 320x200, 60Hz NTSC / 50Hz PAL (separate builds)
- **Audio:** Paula — 4 hardware channels, 8-bit PCM
- **Language:** C with 68010 assembly for performance-critical paths

---

## Source Code Architecture

The game is split across 55+ C source files and several assembly modules in `NTSC/scheduler/source/`, with 37 header files in `NTSC/scheduler/header/`.

### Core Modules

| File | Purpose |
|------|---------|
| `main.c` | Entry point, system initialization, main game loop, memory allocation |
| `game.c` | Level definitions, keyboard/joystick handling, level setup |
| `view.c` | Display system — viewport allocation, scrolling, bitmap loading |
| `copperlist.c` | Copper list definitions for all display modes |
| `copper.c` | Copper list management (`SYS_UseCopper`, debug disassembly) |
| `ADOS.c` | AmigaDOS abstraction — file I/O, color register writes, system functions |
| `ic.c` | Vertical blank interrupt handler, blitter queue, scroll dispatch |
| `isrs.asm` | Interrupt service routines, color cycling, copper server |
| `loader.c` | Asset loading — EMRL format parser, RLE decompression |
| `schedule.c` | Event scheduler — cooperative multitasking system |
| `patterns.c` | All alien movement patterns (11 wave patterns + boss patterns) |

### Gameplay Modules

| File | Purpose |
|------|---------|
| `aliens.c` | Alien wave management, spawning, movement |
| `wave.c` | Wave lifecycle, alien counts, scoring |
| `bigguy.c` | Boss ("Big Guy") logic — animation, spawning, lava balls |
| `bullets.c` | Player bullet management |
| `bulletcode.asm` | Optimized bullet collision routines |
| `missile.c` | Alien bullet/missile system |
| `mymissile.c` | Player homing missile logic |
| `bugs.c` | Small enemy ("bug") behavior |
| `eyes.c` | Eye turret enemies (levels 1 and 3) |
| `FireBall.c` | Fireball projectiles (level 3) |
| `animate.c` | Sprite animation frame cycling |
| `Sprites.c` | Hardware sprite management |
| `sprite0.c` / `sprite1.c` | Individual sprite channel handlers |
| `sound.c` | Audio playback — sample loading, channel allocation |
| `scores.c` | High score table |
| `points.c` | Score display and bonus calculation |
| `specials.c` | Weapon token pickups |

### System Modules

| File | Purpose |
|------|---------|
| `blits.c` | Blitter operations — sprite rendering via Bob blitting |
| `blitter.asm` | Low-level blitter queue management |
| `collchk.asm` | Hardware-accelerated collision detection |
| `displist.c` | Display list management — z-ordered rendering |
| `queue.asm` | Event queue management (assembly) |
| `memory.c` | Custom memory allocator (chip RAM / fast RAM) |
| `joystick.c` | Joystick reading |
| `ReadKeys.asm` | Raw keyboard handler (interrupt-driven) |
| `debug.c` | Debug/diagnostic output |
| `serial.c` | Serial port debugging |

---

## Amiga Hardware Usage

The game makes deep use of the Amiga's custom chipset — three co-processors (Agnus, Denise, Paula) that operate independently of the CPU via DMA.

### The Copper (Display Coprocessor)

The **Copper** is a simple programmable processor that executes a list of instructions synchronized to the video beam. It runs once per frame and can:

- **MOVE** — Write a value to any custom chip register
- **WAIT** — Pause until the video beam reaches a specified position

The game defines three copper lists in `copperlist.c`:

#### MainCopper (Gameplay)

The main copper list is 113 instructions and orchestrates the entire gameplay display:

```
Lines 0-15:   Set hardware sprite pointers (8 sprites × 2 registers)
Line 16-31:   Null out sprite DMA channels not in use
WAIT $1D:     Wait for scanline $1D (top of gameplay area)
Lines 33-48:  Program 16 color registers (COLOR00-COLOR15)
              COLOR00=$444, COLOR01=$820, COLOR02=$D50, COLOR03=$F95...
              This is the background palette (fire tones + cyan accents)
Lines 49-69:  Configure display hardware:
              BPLCON0=$6600 (dual playfield, 3+3 bitplanes)
              BPLCON1 (scroll offset)
              DDFSTRT/DDFSTOP (data fetch timing)
              BPL1MOD/BPL2MOD (bitplane modulos for scroll)
              BPLxPT (6 bitplane pointers)
WAIT $C8:     Wait for scanline $C8 (bottom of gameplay area, line 176)
              Switch to single playfield mode for status panel
WAIT $CA:     Program panel colors (darker palette)
              Set panel bitplane pointers + display config
WAIT $CC:     Re-enable copper interrupt
Lines 96-111: Per-scanline color changes for the gradient at the very
              bottom of the panel (creates a colored band effect)
END:          $FFFF,$FFFE (end of copper list)
```

This achieves something impossible on most contemporary hardware — **different display modes and palettes on different parts of the screen**, all without CPU intervention.

#### TitleCopper (Title Screen)

```
WAIT $27:     Wait for top of display
Lines 1-16:   Program 16 color registers (replaced at runtime by EMRL palette)
Lines 17-38:  Configure display:
              BPLCON0=$200 (single playfield) initially
              6 bitplane pointers (for HAM6 data)
              DDFSTRT/DDFSTOP, DIWSTRT
WAIT $29:     Switch to BPLCON0=$6A00 (HAM mode + 6 bitplanes)
WAIT $F1:     Bottom of display (NTSC) — switch back to basic mode
END
```

The key trick: `BPLCON0 = $6A00` encodes:
- Bit 11 (`$800`) = HAM (Hold And Modify) mode enabled
- Bits 14-12 (`$6000`) = 6 bitplanes
- Bit 9 (`$200`) = color burst (composite color)

#### LoadCopper (Loading Screen)

Simpler version with the same loading-screen palette and a `BPLCON0=$4200` (4 bitplanes, color).

### The Blitter (Bulk Data Processor)

The **Blitter** is a DMA engine that performs memory-to-memory operations with logical combining. The game uses it extensively for:

#### Bob (Blitter Object) Rendering

Game sprites are not hardware sprites (limited to 16 pixels wide, 8 channels) — they are "Bobs" rendered by the blitter:

1. **Save background** — Copy the area under the sprite to a save buffer
2. **Cookie-cut blit** — Combine sprite data with the playfield using AND/OR logic:
   - Source A = sprite mask (1 where sprite is opaque)
   - Source B = sprite image data
   - Source C = playfield destination (current screen)
   - Destination = playfield
   - Minterm: `D = (A AND B) OR (NOT A AND C)` — sprite pixels replace background, transparent areas preserve background
3. **Restore background** — On the next frame, copy saved data back before drawing new positions

This is managed through a **blitter queue** (`BLTListRead/BLTListWrite` in `ic.c`, `blitter.asm`) that serializes blitter operations across the frame.

#### Display List Ordering

The game maintains a **display list** (`displist.c`) — a z-ordered list of all Bobs to render. Each Bob has a display list entry (DLE) with position, image data, and priority. The display list ensures objects are drawn back-to-front for correct overlapping.

### Hardware Sprites

The Amiga provides **8 hardware sprite channels**, each 16 pixels wide and any height. Sprites are positioned by writing to sprite control registers via the copper list. The game uses them sparingly (the player ship in some modes), while most objects are blitter Bobs.

Sprite pointers are the first 16 entries in `MainCopper`:

```c
0x120, 0x1,     // SPR0PTH (high word of sprite 0 pointer)
0x122, 0x2F8C,  // SPR0PTL (low word)
// ... 8 sprites total
```

### Paula (Audio DMA)

The **Paula** chip provides 4 independent DMA audio channels. Each channel plays an 8-bit PCM sample by:

1. Setting the sample pointer (`AUDxLCH/AUDxLCL`) — must be in Chip RAM
2. Setting the length in words (`AUDxLEN`)
3. Setting the volume (`AUDxVOL`, 0-64)
4. Setting the period (`AUDxPER`) — determines sample rate: `CLK / period` Hz
5. Enabling the channel's DMA bit in `DMACON`

The game uses a round-robin channel allocator:

```c
UBYTE ChannelLock[4];    // Which channels are in use
WORD ChannelPtr;         // Round-robin pointer

void GetChannel() {
    ChannelPtr = (ChannelPtr + 1) % 4;
    // ... lock the channel, stop any playing sound
}
```

Channels 0 and 3 are left-panned, channels 1 and 2 are right-panned (hardware constraint), providing stereo separation for sound effects.

### DMA and Memory Architecture

The Amiga has a critical distinction between **Chip RAM** and **Fast RAM**:

- **Chip RAM** (up to 512KB on A500) — Accessible by both CPU and custom chips (DMA). All graphics, sound samples, copper lists, and sprite data MUST reside here.
- **Fast RAM** (expansion) — CPU-only accessible, used for code and non-DMA data.

The game's memory allocator (`memory.c`) specifically requests Chip RAM for:
- Bitplane data for all playfield bitmaps
- Sprite/Bob image data
- Sound sample data
- Copper list arrays

And Fast RAM for:
- Game code
- Data structures (alien parameters, wave definitions, etc.)
- Save buffers (when Fast RAM is available)

### Vertical Blank Interrupt

The VBI is the heartbeat of the game. The interrupt handler in `isrs.asm` runs at 60Hz (NTSC) and orchestrates:

```asm
_AutoVectorISR:
    ; Level 3 interrupt (copper + VBI)
    btst.b #4,$dff01f       ; Check if VBI
    beq    CopperInt        ; If not, handle copper interrupt

    ; VBI handler:
    addq.l #1,_sys_time     ; Increment global tick counter
    jsr    _CopperServer    ; Update copper list for next frame
    jsr    PColorCycler     ; Title/portal color cycling
    jsr    _ColorCycler     ; Gameplay color cycling (if enabled)

    ; Dispatch scroll function based on VBFunc bitmask
    move.w _VBFunc,d0
    lea    _VFunctions,a0
    movea.l (a0,d0.w),a0
    jsr    (a0)             ; Call scroll handler

    ; Process blitter queue
    jsr    _BlitFace        ; Dequeue and execute next blit operation
```

The `VBFunc` dispatch table maps 16 combinations of scroll direction and screen section to handler functions:

```c
void (*VFunctions[])() = {
    NULL,
    ScrollVTop,           // Vertical scroll, top screen only
    ScrollHTop,           // Horizontal scroll, top screen only
    ScrollVTop_and_HTop,  // Both
    ScrollHBot,           // Horizontal scroll, bottom panel
    // ... 16 combinations
};
```

This allows the game to scroll different parts of the screen independently — the gameplay area scrolls while the status panel stays fixed.

---

## Event-Driven Scheduler

The game uses a **cooperative event-driven scheduler** rather than a traditional game loop. Game entities (aliens, bullets, scrolling, animation) are scheduled as **events** that fire at specific times.

```c
struct SCH_EQE {      // Event Queue Element
    ULONG Time;       // Scheduled execution time
    int (*Func)();    // Function to call
    char *param;      // Parameter pointer
    // ... linked list pointers
};
```

Events are inserted into a time-ordered queue. Each vertical blank, the scheduler checks for events whose time has arrived and dispatches them. This allows smooth animation of many independent entities without a monolithic update loop.

### Vertical Blank Interrupt

The VBI handler (`isrs.asm`) runs every frame (60Hz NTSC / 50Hz PAL) and:
1. Increments `sys_time` (global tick counter)
2. Dispatches the **Copper Server** (updates copper list for next frame)
3. Runs the **Color Cycler** (palette animation)
4. Processes the **Blitter Queue** (deferred sprite rendering)
5. Dispatches the **Scroll Function Table** based on `VBFunc` bitmask

---

## Display System

### Dual Playfield Mode

During gameplay, the Amiga runs in **Dual Playfield** mode:

- **Playfield 1 (rear):** 3 bitplanes = 8 colors (COLOR0-7) — scrolling background
- **Playfield 2 (front):** 2 bitplanes — game sprites rendered via blitter

The copper list (`MainCopper`) programs the display hardware per-scanline:
- Sets bitplane pointers for both playfields
- Configures scroll offsets (`BPLCON1`)
- Programs color registers
- Switches display modes at specific scanlines (gameplay area vs status panel)

### HAM6 Mode (Title Screen)

The title screen uses **Hold And Modify** mode — 6 bitplanes providing up to 4096 simultaneous colors:

- Top 2 bits of each pixel are control codes:
  - `00` = Direct palette lookup (bottom 4 bits = palette index 0-15)
  - `01` = Hold previous color, modify blue channel
  - `10` = Hold previous color, modify red channel
  - `11` = Hold previous color, modify green channel
- Each scanline starts with palette color 0 (black)
- The 4-bit data value maps to 0-255 via `value * 17`

The title screen `TitleCopper` programs `BPLCON0 = 0x6A00` (HAM + 6 bitplanes).

### Scrolling

Two scroll modes are used:

**Horizontal** (Levels 0, 2, 4): Background is 1216x200 pixels. `RxOffset` increments by 1 pixel every 3 frames. The player ship points right.

**Vertical** (Levels 1, 3): Background is 320x1200 pixels. `RyOffset` decrements (scrolls upward) by 1 pixel every 3 frames. The player ship points up.

```c
#define SCROLLTICKS 3  // Scroll one pixel every 3 frames
```

### Color Cycling

Levels 1 (Sandstorm) and 3 (Lava) have the `LB_CycleOn` flag set. The `_ColorCycler` routine in `isrs.asm` rotates copper list entries at offset 186 (COLOR13, COLOR14, COLOR15) every 6 VBlanks:

```asm
_ColorCycler:
    lea.l  186(a0),a0      ; Point to COLOR13 entry in copper
    move.w 8(a0),d0        ; Save COLOR15
    move.w 4(a0),8(a0)     ; COLOR15 = COLOR14
    move.w (a0),4(a0)      ; COLOR14 = COLOR13
    move.w d0,(a0)         ; COLOR13 = old COLOR15
```

This creates a shimmering animation effect in the sand/lava backgrounds.

---

## Level Design

### Level Table Structure

```c
struct LevelBlock {
    BYTE LevelNum;
    BYTE NumAliens;       // Max simultaneous aliens
    BYTE MinAliens;       // Minimum wave size
    BYTE MaxAliens;       // Maximum wave size
    ULONG flags;          // Feature flags (see below)
    BYTE NumSatellites;   // Orbiting enemies
    BYTE NumTurrets;      // Stationary turrets
    BYTE NumAlienBullets; // Max enemy projectiles
};
```

### Level Flag Bits

| Flag | Effect |
|------|--------|
| `LB_SmallAliens` | Spawn small alien ships |
| `LB_BigAliens` | Spawn large alien ships |
| `LB_Turrets` | Spawn stationary turret enemies |
| `LB_TurretHomers` | Turrets fire homing projectiles |
| `LB_Satellite` | Spawn orbiting satellite enemies |
| `LB_ScrollHoriz` | Horizontal scrolling |
| `LB_ScrollVert` | Vertical scrolling |
| `LB_FireAlways` | Aliens fire regardless of position |
| `LB_CycleOn` | Enable color cycling |
| `LB_ScreenMask` | Use screen masking |
| `LB_ShipDead` | Player ship destroyed flag |
| `LB_HoldScroll` | Pause scrolling (boss encounter) |

### The Five Levels

#### Level 0: Cavern
- **Scroll:** Horizontal (1216x200)
- **Aliens:** 4 max, Big aliens only
- **Turrets:** 0
- **Boss:** Single clockwork-bug, rectangular patrol pattern
- **Background:** Rocky cavern walls

#### Level 1: Sandstorm
- **Scroll:** Vertical (320x1200)
- **Aliens:** 6 max, Big aliens, fire always
- **Turrets:** 2 (Eye type — open/close animation, fire when open)
- **Satellites:** 1 orbiting enemy
- **Color Cycling:** Yes (sand shimmer effect)
- **Boss:** Two large enemies, vertical/horizontal oscillation patterns

#### Level 2: Cheese
- **Scroll:** Horizontal (1216x200)
- **Aliens:** 6 max, Small + Big aliens
- **Turrets:** 4 (Plant type — animated background objects)
- **Background:** Yellow-green organic/cheese terrain with animated plants
- **Boss:** Circular boss — segments orbit a drifting center point

#### Level 3: Lava
- **Scroll:** Vertical (320x1200)
- **Aliens:** 6 max, Small + Big, turret homers
- **Turrets:** 4 (Iris-3D + Lava-Eye types — Lava-Eye fires 8-direction spread)
- **Color Cycling:** Yes (lava glow effect)
- **Boss:** Two lava balls following parabolic arc paths (loop forever)

#### Level 4: Hangar
- **Scroll:** Horizontal (1216x200)
- **Aliens:** 8 max (hardest level)
- **Turrets:** 4 (Hex-Gun type — fire at animation frame 7)
- **Boss:** Two HangerBall enemies, large rectangular patrol patterns
- **Unique:** Boss spawns mid-level at scroll position 618

---

## Alien Wave System

### Movement Patterns

Alien waves follow pre-defined **movement patterns** — sequences of waypoints that define complex flight paths. Each pattern consists of 25-80+ waypoints:

```c
struct anm_element {
    UBYTE Count;    // Hold this step for N frames
    BYTE FrameNo;   // Animation frame to display (0-7)
    WORD Xoffset;   // Delta-X per frame
    WORD Yoffset;   // Delta-Y per frame
};
```

The first element of each pattern sets the **starting position** (Xoffset/Yoffset are absolute coordinates). Subsequent elements define velocity vectors applied for `Count` frames each.

There are **11 primary wave patterns** (PATTERN_0 through PATTERN_10), creating varied flight paths — swooping curves, figure-eights, diagonal dives, and tight spirals. Each pattern was hand-crafted to provide interesting and challenging movement.

Patterns are mirrored at runtime based on scroll direction so aliens always enter from the direction of travel.

### Wave Spawning

- A new wave spawns every ~3 seconds (`WAVE_SPAWN_INTERVAL = 180` frames)
- Wave size is random between `MinAliens` and `MaxAliens` for the current level
- Each alien in a wave follows the same pattern but offset in time (staggered entry)
- Aliens within a wave have small random position offsets for variation

---

## Boss System

### Boss Patterns

Bosses follow simpler repeating patterns (4-5 waypoints that loop):

- **Level 0:** Single boss, rectangular patrol (right side of screen)
- **Level 1:** Dual bosses, one oscillates vertically, one horizontally
- **Level 2:** Circular boss — segments orbit a center that bounces around
- **Level 3:** Lava balls — parabolic arc paths, loop reset to start position
- **Level 4:** Dual bosses, large rectangular clockwise/counter-clockwise paths

### Boss Encounters

The boss encounter triggers when scrolling reaches the end of the background. The scroll pauses (`LB_HoldScroll`), and the boss spawns. After defeating the boss, scrolling resumes briefly, then the level is marked complete.

---

## Player Ship

### Banking Animation

The player ship has **11 animation frames** representing different bank angles. The ship smoothly transitions between frames based on movement input:

- Center frame (3) = level flight
- Frames 0-2 = banking one direction (up for horizontal, left for vertical)
- Frames 4-6 = banking the other direction
- Frame transition is delayed by `PLAYER_BANK_DELAY` (6 frames) for smooth animation

### Ship Orientation

- **Horizontal levels:** Ship sprite rotated 90 degrees clockwise (points right)
- **Vertical levels:** Ship sprite unrotated (points up)

---

## Weapon System

Six weapon token types cycle in fixed order:

| Token | Effect |
|-------|--------|
| **FASTER** | Increase ship speed (3 levels) |
| **LASER** | Standard single-shot, increased fire rate |
| **DOUBLE** | Increase bullet power (more damage per hit) |
| **PLASMA** | Higher damage projectile |
| **SIDES** | Triple-shot spread fire |
| **HOMERS** | Homing missiles |

Tokens spawn:
- When the first alien in a wave is destroyed
- Periodically from the edge of the screen (every ~8 seconds)
- Tokens drift toward the player (leftward on horizontal levels, downward on vertical)

---

## Scoring

| Event | Points |
|-------|--------|
| First alien in a wave | 200 |
| Subsequent aliens | 20 |
| Bug/turret enemy | 1,000 |
| Boss defeated | 5,000 |
| Token collected | 50 |
| **Extra life** | Every 10,000 (first), then every 20,000 |

Maximum lives: 9. Starting lives: 5.

---

## Sound System

Audio uses the Amiga's **Paula** chip — 4 hardware DMA channels with round-robin allocation.

### Sound Effects

| Sample | File Size | Game Size | Period | Rate | Usage |
|--------|-----------|-----------|--------|------|-------|
| `laser.sfx` | 7,635 | 7,635 | 400 | 8,949 Hz | Player firing |
| `explosion.sfx` | 7,126 | 7,126 | 400 | 8,949 Hz | Alien/player death |
| `token.sfx` | 5,259 | 5,259 | 324 | 11,046 Hz | Token pickup |

Samples are raw 8-bit signed PCM. The game allocates fixed-size buffers with `AllocMem(Size, MEMF_CHIP|MEMF_CLEAR)` and reads up to `Size` bytes — files shorter than the buffer are zero-padded, files longer are truncated.

### Music System (SMUS)

The background music is stored as an IFF **SMUS** (Simple Musical Score) file (`beat.smus`) — a tracker-style format from the Amiga music editor **Sonix**.

#### SMUS File Structure

```
FORM SMUS {
    SHDR (4 bytes) — tempo=16047, volume=127, tracks=3
    NAME           — song title
    SNX1           — Sonix extension data (ignored by game)
    INS1 × 5       — instrument references (names only, game ignores)
    TRAK × 3       — track event data
}
```

#### Instruments

The game hard-codes 5 instruments mapped to `.sfx` sample files:

| ID | Name | Sample | Game Size | Octave Table |
|----|------|--------|-----------|-------------|
| 0 | BassDrum | `bass1.sfx` | 2,000 bytes | Octave1 |
| 1 | HighHat | `cymbal.sfx` | 2,000 bytes | (unchanged) |
| 2 | SnareDrum | `synthsnare.sfx` | 2,000 bytes | (unchanged) |
| 3 | LowBass | `bassguitar.sfx` | 2,400 bytes | Octave2 |
| 4 | Dave2 | `HighBass.sfx` | 2,000 bytes | (unchanged) |

Note: Some `.sfx` files on disk are larger than the game's buffer size (e.g., `HighBass.sfx` is 2,997 bytes but the game only reads 2,000). The game's `LoadSample()` uses `fread(buf, 1, Size, fp)` which truncates at `Size`.

#### Track Configuration (from `StartMusic()`)

| Track | Channel | Octave Table | Volume |
|-------|---------|-------------|--------|
| 0 | 1 | Octave1 | 50/64 |
| 1 | 2 | Octave2 | 50/64 |
| 2 | 3 | Octave2 | 50/64 |

Track 0 is the drum track (bass drum, hi-hat, snare). Tracks 1 and 2 are bass guitar patterns.

#### Event Format

Each track is a sequence of 2-byte events (`SEvent`):

```c
typedef struct { UBYTE sID; UBYTE data; } SEvent;
```

- `sID > 128`: Control event (instrument change, time signature, etc.)
  - `0x81` (SID_Instrument): `data` = instrument ID (0-4). Sets sample pointer, sample length, and optionally switches the octave table.
  - `0x82-0x84` (TimeSig, KeySig, Dynamic): Consumed but **ignored** by the game.
- `sID == 128` (SID_Rest): Silence for the note's duration. DMA is stopped.
- `sID < 128`: Note. `sID` = tone index (0-127), looked up in the track's current octave table to get an Amiga period value.

The `data` byte for notes/rests encodes duration flags:

```c
#define NOT_division 0x07   // bits 0-2: duration index
#define NOT_dot      0x08   // bit 3: dotted note (1.5x duration)
```

Duration in VBI ticks: `NoteLength[flags & 7]`, where `NoteLength = [96, 48, 24, 12, 6, 3, 1, 0]`. If dotted, multiply by 1.5.

#### Octave Tables

Two 128-entry lookup tables convert tone indices to Amiga period values:

- **Octave1**: Periods 7550 (tone 0, ~474 Hz) down to 5 (tone 127). Used by bass drum.
- **Octave2**: Periods 2595 (tone 0, ~1,379 Hz) down to 1 (tone 127). Used by bass guitar.

Playback rate = `NTSC_CLOCK (3,579,545) / period` Hz.

#### MusicMachine (Event-Driven Playback)

`MusicMachine()` is the music engine, called via the scheduler. For each invocation:

1. Stop DMA on the track's channel (brief silence between notes)
2. Loop through control events (`sID > 128`), processing instrument changes
3. When a note or rest is reached:
   - **Rest**: Keep DMA stopped, schedule next call after rest duration
   - **Note**: Set `ac_ptr` (sample), `ac_len` (length in words), `ac_vol` (volume), `ac_per` (period from octave table), enable DMA. Schedule next call after note duration.
4. The Amiga DMA **loops the sample** continuously until stopped at the next note.

Each track loops independently — when `SndPC` reaches the track length, it resets to 0.

#### Timing

The music runs at the VBI rate. With a PAL Amiga (50 Hz), a sixteenth note (6 ticks) = 0.12 seconds. The tempo field in the SHDR chunk (16047) is **ignored** by the game — all timing is purely VBI-driven.

---

## Graphics Asset Format

### EMRL Format (Emerald Custom)

All game graphics are stored in the custom **EMRL** packed format, designed for fast loading on floppy-based systems:

```
[EMRL] [total_size] [PACK]     — 12-byte header
[TOTL] [8]  [from] [total]     — Total image count
[COLR] [size] [palette_data]   — 12-bit Amiga palette (16-32 colors)
For each image:
  [BMFO] [size] [bitmap_info]  — Width, height, depth, hotspot, masking
  [PLNE] [size] [rle_data]     — RLE-compressed bitplane data (per plane)
```

#### RLE Compression

The EMRL RLE scheme (written by "_-=BN=-_ July 88") uses an interleaved count/value encoding:

- Read `count` byte
- Read `value` byte
- If `count < 128`: literal run — output `value`, then alternate reading count/value for `count-1` more bytes
- If `count >= 128`: repeat run — output `value` repeated `(count & 127)` times
- End marker: `count=0, value=0`

#### Bitmap Info (BMFO)

```c
struct BitMapInfo {
    UWORD Width, Height;    // Pixel dimensions
    WORD HotX, HotY;       // GRAB hotspot (center offset for rendering)
    UBYTE Depth;            // Number of bitplanes (2-6)
    UBYTE Masking;          // Mask type
    UBYTE Compression;      // Compression flag
    UBYTE TransparentColor; // Transparent palette index
    UBYTE PlanePick;        // Which planes have data (bitmask)
    UBYTE PlaneOnOff;       // Default state for missing planes
    WORD PageWidth, PageHeight;
};
```

The **GRAB hotspot** (`HotX, HotY`) defines the sprite's logical center. When rendering a Bob (blitter object), the hotspot offset is subtracted from the logical position to find the top-left drawing coordinate.

### IFF/ILBM Format

Some assets (particularly animated sprites) use the standard Amiga **IFF/ILBM** or **ANBM** (animated bitmap) format:

- `FORM ILBM` — single image with `BMHD`, `CMAP`, `BODY` chunks
- `FORM ANBM` — animated sequence with `LIST ILBM { PROP ILBM { shared BMHD, CMAP }, FORM ILBM, ... }`

ILBM uses standard **ByteRun1** compression (different from EMRL's RLE scheme).

---

## Amiga Color System

Colors are stored as **12-bit RGB** values (4 bits per channel):

```
Value: 0x0RGB
  R = (value >> 8) & 0xF  →  0-15
  G = (value >> 4) & 0xF  →  0-15
  B = value & 0xF          →  0-15
```

Expanded to 8-bit: `channel_8bit = channel_4bit * 17` (maps 0x0→0, 0xF→255).

The Amiga OCS chipset provides 32 color registers (COLOR00-COLOR31). In dual playfield mode, playfield 1 uses COLOR0-7 and playfield 2 uses COLOR8-15 (with COLOR8 being transparent).

---

## Collision Detection

Collision detection uses bounding rectangle intersection tests. The blitter hardware's collision detection capability is also used for pixel-level accuracy in some cases (via `collchk.asm`).

---

## Memory Management

The game uses a custom memory allocator (`memory.c`) that distinguishes between:
- **Chip RAM** — accessible by the Amiga's custom chips (DMA), required for graphics and sound data
- **Fast RAM** — CPU-only accessible, used for code and non-DMA data

All sprite/bitmap data must reside in chip RAM for blitter and DMA access.

---

## Cheat Code

The game includes a cheat code activated by a specific joystick/mouse button sequence:

```c
WORD CheatCodes[] = {JFIRE, LMOUSE, JFIRE, LMOUSE, JCHEAT};
```

Fire button, left mouse, fire button, left mouse — activates invincibility/level skip.

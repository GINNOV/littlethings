# Amiga Hardware Register Reference

Commonly used custom chip registers (offsets from `CUSTOM` / `$dff000`):

| Name | Offset | Description |
|---|---|---|
| `VPOSR` | `$004` | Vertical position of raster (read) |
| `VHPOSR`| `$006` | Vertical and horizontal position of raster (read) |
| `COP1LC`| `$080` | Copper list 1 location (write long) |
| `COPJMP1`| `$088` | Copper list 1 jump (write word, trigger) |
| `DMACON` | `$096` | DMA control write (set/clear bits) |
| `INTENA` | `$09a` | Interrupt enable write (set/clear bits) |
| `COLOR00`| `$180` | Background color (write word) |
| `COLOR01`| `$182` | Color 1 (write word) |

## DMA Control Bits (`DMACON`)
- `$8000`: Set bits
- `$0000`: Clear bits
- `$0400`: Master Enable
- `$0200`: Raster Enable
- `$0100`: Copper Enable
- `$0040`: Blitter Enable
- `$0020`: Sprite Enable

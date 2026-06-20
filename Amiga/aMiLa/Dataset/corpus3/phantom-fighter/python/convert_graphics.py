#!/usr/bin/env python3
"""
Convert PhantomFighter Amiga graphics to JPG files.

Handles two formats:
  - EMRL (Emerald custom packed format)
  - IFF/ILBM (standard Amiga image format)

Usage:
  python convert_graphics.py [input_dir] [output_dir]

Defaults:
  input_dir  = ../NTSC/graphics
  output_dir = ../modern-bitmaps
"""

import struct
import sys
import os
from pathlib import Path
from PIL import Image


# ── Amiga 12-bit colour to 8-bit RGB ──────────────────────────────

def amiga_color_to_rgb(color_word):
    """Convert a 12-bit Amiga colour word (0x0RGB) to (R8, G8, B8)."""
    r = (color_word >> 8) & 0xF
    g = (color_word >> 4) & 0xF
    b = color_word & 0xF
    return (r * 17, g * 17, b * 17)


# ── EMRL RLE Unpacker ─────────────────────────────────────────────
# Matches the "demand paged Unpacker written by _-=BN=-_ July 88"
# from loader.c

def unpack_emrl_plane(data, offset, chunk_size):
    """Unpack one EMRL RLE-compressed bitplane.

    Returns (unpacked_bytes, new_offset).
    """
    end = offset + chunk_size
    out = bytearray()

    if offset >= end:
        return bytes(out), offset

    pos = offset
    count = data[pos]; pos += 1

    while pos < end:
        val = data[pos]; pos += 1

        if count < 128:
            # Literal run: copy 'count' different bytes
            if count == 0 and val == 0:
                break  # End marker
            out.append(val)
            for _ in range(count - 1):
                if pos >= end:
                    break
                count = val
                val = data[pos]; pos += 1
                out.append(val)
            if pos >= end:
                break
            count = data[pos]; pos += 1
        else:
            # Repeat run: repeat val (count & 127) times
            repeat = count & 127
            out.extend([val] * repeat)
            if pos >= end:
                break
            count = data[pos]; pos += 1

    return bytes(out), end


# ── Bitplane to pixel conversion ──────────────────────────────────

def ham6_to_image(planes, width, height, palette):
    """Decode a HAM6 (Hold And Modify, 6 bitplanes) image to RGB.

    In HAM mode, the top 2 bitplanes are control bits:
      00 = direct palette lookup (bottom 4 bits = palette index)
      01 = modify blue channel (bottom 4 bits = new blue nibble)
      10 = modify red channel
      11 = modify green channel
    Each scanline starts with palette colour 0.
    """
    row_bytes = ((width + 15) // 16) * 2
    img = Image.new('RGB', (width, height))
    pixels = img.load()

    for y in range(height):
        prev_r, prev_g, prev_b = palette[0]

        for x in range(width):
            byte_idx = y * row_bytes + (x // 8)
            bit_idx = 7 - (x % 8)

            val = 0
            for p in range(6):
                if byte_idx < len(planes[p]):
                    if planes[p][byte_idx] & (1 << bit_idx):
                        val |= (1 << p)

            control = (val >> 4) & 3
            data = val & 0xF

            if control == 0:
                if data < len(palette):
                    prev_r, prev_g, prev_b = palette[data]
            elif control == 1:
                prev_b = data * 17
            elif control == 2:
                prev_r = data * 17
            elif control == 3:
                prev_g = data * 17

            pixels[x, y] = (prev_r, prev_g, prev_b)

    return img


def bitplanes_to_image(planes, width, height, palette, transparent_index=None):
    """Convert Amiga bitplane data to a PIL Image.

    planes: list of bytes objects, one per bitplane
    width, height: pixel dimensions
    palette: list of (R, G, B) tuples
    transparent_index: if set, this palette index becomes fully transparent
    """
    row_bytes = ((width + 15) // 16) * 2
    num_planes = len(planes)

    if transparent_index is not None:
        img = Image.new('RGBA', (width, height))
    else:
        img = Image.new('RGB', (width, height))
    pixels = img.load()

    for y in range(height):
        for x in range(width):
            byte_idx = y * row_bytes + (x // 8)
            bit_idx = 7 - (x % 8)

            color_idx = 0
            for p in range(num_planes):
                if byte_idx < len(planes[p]):
                    if planes[p][byte_idx] & (1 << bit_idx):
                        color_idx |= (1 << p)

            if transparent_index is not None and color_idx == transparent_index:
                pixels[x, y] = (0, 0, 0, 0)
            elif color_idx < len(palette):
                if transparent_index is not None:
                    r, g, b = palette[color_idx]
                    pixels[x, y] = (r, g, b, 255)
                else:
                    pixels[x, y] = palette[color_idx]
            else:
                if transparent_index is not None:
                    pixels[x, y] = (0, 0, 0, 0)
                else:
                    pixels[x, y] = (0, 0, 0)

    return img


# ── EMRL Format Decoder ───────────────────────────────────────────

def read_chunk_header(data, offset):
    """Read a chunk header (4-byte ID + 4-byte size)."""
    if offset + 8 > len(data):
        return None, None, offset
    chunk_id = data[offset:offset+4]
    chunk_size = struct.unpack('>I', data[offset+4:offset+8])[0]
    return chunk_id, chunk_size, offset + 8


def decode_emrl(filepath):
    """Decode an EMRL file. Returns list of (Image, name) tuples."""
    data = filepath.read_bytes()

    if len(data) < 12 or data[:4] != b'EMRL':
        return []

    # Skip EMRL header (12 bytes: EMRL + size + PACK)
    pos = 12

    # Read TOTL chunk
    chunk_id, chunk_size, pos = read_chunk_header(data, pos)
    if chunk_id != b'TOTL':
        print(f"  Warning: Expected TOTL, got {chunk_id}")
        return []

    from_val, total = struct.unpack('>ii', data[pos:pos+8])
    pos += chunk_size

    # Read COLR chunk
    chunk_id, chunk_size, pos = read_chunk_header(data, pos)
    if chunk_id != b'COLR':
        print(f"  Warning: Expected COLR, got {chunk_id}")
        return []

    # Parse Amiga 12-bit palette
    num_colors = chunk_size // 2
    palette = []
    for i in range(num_colors):
        cword = struct.unpack('>H', data[pos + i*2:pos + i*2 + 2])[0]
        palette.append(amiga_color_to_rgb(cword))
    pos += chunk_size

    # Pad palette to 256 entries
    while len(palette) < 256:
        palette.append((0, 0, 0))

    images = []

    for frame_idx in range(total):
        # Read BMFO chunk
        chunk_id, chunk_size, pos = read_chunk_header(data, pos)
        if chunk_id != b'BMFO':
            print(f"  Warning: Expected BMFO for frame {frame_idx}, got {chunk_id}")
            break

        # Parse BitMapInfo struct (20 bytes)
        bmfo_start = pos
        width, height = struct.unpack('>HH', data[pos:pos+4])
        hot_x, hot_y = struct.unpack('>hh', data[pos+4:pos+8])
        depth = data[pos+8]
        masking = data[pos+9]
        compression = data[pos+10]
        transparent_color = data[pos+11]
        plane_pick = data[pos+12]
        plane_on_off = data[pos+13]
        page_width, page_height = struct.unpack('>hh', data[pos+14:pos+18])
        pos = bmfo_start + chunk_size

        if width == 0 or height == 0:
            continue

        row_bytes = ((width + 15) // 16) * 2
        plane_size = row_bytes * height

        # Read bitplanes
        planes = []
        for plane_idx in range(depth):
            if plane_pick & (1 << plane_idx):
                # This plane has data
                chunk_id, chunk_size, pos = read_chunk_header(data, pos)
                if chunk_id != b'PLNE':
                    print(f"  Warning: Expected PLNE for frame {frame_idx} plane {plane_idx}, got {chunk_id}")
                    break

                unpacked, pos = unpack_emrl_plane(data, pos, chunk_size)
                # Pad or truncate to expected size
                if len(unpacked) < plane_size:
                    unpacked = unpacked + b'\x00' * (plane_size - len(unpacked))
                planes.append(unpacked[:plane_size])
            else:
                # Plane not present — fill based on PlaneOnOff
                if plane_on_off & (1 << plane_idx):
                    planes.append(b'\xff' * plane_size)
                else:
                    planes.append(b'\x00' * plane_size)

        if planes:
            if depth == 6:
                # HAM6 image (e.g. title screen) — decode Hold And Modify
                img = ham6_to_image(planes, width, height, palette)
            else:
                # Sprites (width < 320) get transparency on palette index 0
                trans = 0 if width < 320 else None
                img = bitplanes_to_image(planes, width, height, palette, transparent_index=trans)
            images.append(img)

    return images


# ── IFF/ILBM Format Decoder ───────────────────────────────────────

def unpack_byterun1(data, expected_size):
    """Unpack IFF ByteRun1 compressed data."""
    out = bytearray()
    pos = 0

    while pos < len(data) and len(out) < expected_size:
        n = data[pos]
        pos += 1

        if n < 128:
            # Copy next n+1 bytes literally
            count = n + 1
            out.extend(data[pos:pos+count])
            pos += count
        elif n > 128:
            # Repeat next byte (257 - n) times
            count = 257 - n
            if pos < len(data):
                out.extend([data[pos]] * count)
                pos += 1
        # n == 128: no-op

    return bytes(out)


def decode_ilbm_at(data, pos, end, shared_palette=None, shared_bmhd=None):
    """Decode a single ILBM FORM at position pos in data. Returns an Image or None."""
    width = height = depth = 0
    compression = 0
    masking = 0
    palette = list(shared_palette) if shared_palette else [(0, 0, 0)] * 256
    body_data = None

    if shared_bmhd:
        width, height, depth, masking, compression = shared_bmhd

    while pos < end:
        chunk_id, chunk_size, pos = read_chunk_header(data, pos)
        if chunk_id is None:
            break

        chunk_start = pos

        if chunk_id == b'BMHD':
            width = struct.unpack('>H', data[pos:pos+2])[0]
            height = struct.unpack('>H', data[pos+2:pos+4])[0]
            depth = data[pos+8]
            masking = data[pos+9]
            compression = data[pos+10]

        elif chunk_id == b'CMAP':
            num_colors = chunk_size // 3
            for i in range(num_colors):
                r = data[pos + i*3]
                g = data[pos + i*3 + 1]
                b = data[pos + i*3 + 2]
                palette[i] = (r, g, b)

        elif chunk_id == b'BODY':
            body_data = data[pos:pos+chunk_size]

        # Advance past chunk data (pad to even)
        pos = chunk_start + chunk_size
        if pos % 2:
            pos += 1

    if body_data is None or width == 0 or height == 0:
        return None

    row_bytes = ((width + 15) // 16) * 2
    total_planes = depth + (1 if masking == 1 else 0)
    expected_size = row_bytes * height * total_planes

    if compression == 1:
        raw = unpack_byterun1(body_data, expected_size)
    else:
        raw = body_data

    planes = [bytearray(row_bytes * height) for _ in range(depth)]

    src_pos = 0
    for y in range(height):
        for p in range(total_planes):
            if src_pos + row_bytes > len(raw):
                break
            if p < depth:
                dest_offset = y * row_bytes
                planes[p][dest_offset:dest_offset+row_bytes] = raw[src_pos:src_pos+row_bytes]
            src_pos += row_bytes

    planes = [bytes(p) for p in planes]
    trans = 0 if width < 320 else None
    return bitplanes_to_image(planes, width, height, palette, transparent_index=trans)


def decode_iff(filepath):
    """Decode an IFF file (ILBM or ANBM). Returns list of Images."""
    data = filepath.read_bytes()

    if len(data) < 12 or data[:4] != b'FORM':
        return []

    form_size = struct.unpack('>I', data[4:8])[0]
    form_type = data[8:12]

    if form_type == b'ILBM':
        img = decode_ilbm_at(data, 12, min(len(data), 8 + form_size))
        return [img] if img else []

    if form_type != b'ANBM':
        return []

    # ANBM: animated bitmap container
    # Structure: FORM ANBM { TOTL, LIST ILBM { PROP ILBM { shared BMHD, CMAP }, FORM ILBM, FORM ILBM, ... } }
    pos = 12
    images = []
    shared_palette = [(0, 0, 0)] * 256
    shared_bmhd = None

    while pos < min(len(data), 8 + form_size):
        chunk_id, chunk_size, pos = read_chunk_header(data, pos)
        if chunk_id is None:
            break
        chunk_start = pos
        chunk_end = chunk_start + chunk_size
        if chunk_size % 2:
            chunk_end_padded = chunk_end + 1
        else:
            chunk_end_padded = chunk_end

        if chunk_id == b'TOTL':
            # Skip TOTL, we just iterate the FORMs
            pass

        elif chunk_id == b'LIST':
            # LIST ILBM container — parse its contents
            list_type = data[pos:pos+4]  # should be ILBM
            inner_pos = pos + 4

            while inner_pos < chunk_end:
                inner_id, inner_size, inner_pos = read_chunk_header(data, inner_pos)
                if inner_id is None:
                    break
                inner_start = inner_pos
                inner_end = inner_start + inner_size

                if inner_id == b'PROP':
                    # Shared properties — parse BMHD and CMAP
                    prop_type = data[inner_pos:inner_pos+4]  # ILBM
                    prop_pos = inner_pos + 4
                    while prop_pos < inner_end:
                        pid, psize, prop_pos = read_chunk_header(data, prop_pos)
                        if pid is None:
                            break
                        pstart = prop_pos
                        if pid == b'BMHD':
                            w = struct.unpack('>H', data[prop_pos:prop_pos+2])[0]
                            h = struct.unpack('>H', data[prop_pos+2:prop_pos+4])[0]
                            d = data[prop_pos+8]
                            m = data[prop_pos+9]
                            c = data[prop_pos+10]
                            shared_bmhd = (w, h, d, m, c)
                        elif pid == b'CMAP':
                            nc = psize // 3
                            for i in range(nc):
                                r = data[prop_pos + i*3]
                                g = data[prop_pos + i*3 + 1]
                                b = data[prop_pos + i*3 + 2]
                                shared_palette[i] = (r, g, b)
                        prop_pos = pstart + psize
                        if prop_pos % 2:
                            prop_pos += 1

                elif inner_id == b'FORM':
                    # Individual ILBM frame
                    frame_type = data[inner_pos:inner_pos+4]
                    if frame_type == b'ILBM':
                        img = decode_ilbm_at(data, inner_pos + 4, inner_end,
                                             shared_palette, shared_bmhd)
                        if img:
                            images.append(img)

                # Advance past inner chunk
                inner_pos = inner_start + inner_size
                if inner_pos % 2:
                    inner_pos += 1

        pos = chunk_end_padded

    return images


# ── Main ──────────────────────────────────────────────────────────

SKIP_FILES = {'.DS_Store', 'Font.info', 'MusicFiles'}
SKIP_EXTENSIONS = {'.sfx', '.smus', '.info'}

def process_directory(input_dir, output_dir):
    """Walk the input directory and convert all graphics files."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)

    converted = 0
    failed = 0
    skipped = 0

    for filepath in sorted(input_path.rglob('*')):
        if not filepath.is_file():
            continue

        # Skip non-graphics files
        if filepath.name in SKIP_FILES:
            continue
        if filepath.suffix.lower() in SKIP_EXTENSIONS:
            continue
        if filepath.name.startswith('.'):
            continue

        # Skip empty files
        if filepath.stat().st_size == 0:
            print(f"  Skipping empty file: {filepath.name}")
            skipped += 1
            continue

        # Skip Sound directory entirely
        rel = filepath.relative_to(input_path)
        if rel.parts and rel.parts[0] == 'Sound':
            continue

        print(f"Processing: {rel}")

        # Try to determine format from first 4 bytes
        header = filepath.read_bytes()[:4]

        images = []
        try:
            if header == b'EMRL':
                images = decode_emrl(filepath)
            elif header == b'FORM':
                images = decode_iff(filepath)
            else:
                print(f"  Unknown format: {header.hex()}")
                skipped += 1
                continue
        except Exception as e:
            print(f"  ERROR: {e}")
            failed += 1
            continue

        if not images:
            print(f"  No images decoded")
            failed += 1
            continue

        # Create output subdirectory
        out_subdir = output_path / rel.parent
        out_subdir.mkdir(parents=True, exist_ok=True)

        # Save images
        for i, img in enumerate(images):
            if len(images) == 1:
                out_file = out_subdir / f"{filepath.name}.png"
            else:
                out_file = out_subdir / f"{filepath.name}_frame{i}.png"

            img.save(str(out_file), 'PNG')

        frame_str = f" ({len(images)} frames)" if len(images) > 1 else ""
        print(f"  OK: {images[0].size[0]}x{images[0].size[1]}{frame_str}")
        converted += 1

    print(f"\nDone: {converted} files converted, {failed} failed, {skipped} skipped")


if __name__ == '__main__':
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent

    input_dir = sys.argv[1] if len(sys.argv) > 1 else str(project_dir / 'NTSC' / 'graphics')
    output_dir = sys.argv[2] if len(sys.argv) > 2 else str(project_dir / 'modern-bitmaps')

    print(f"Input:  {input_dir}")
    print(f"Output: {output_dir}")
    print()

    process_directory(input_dir, output_dir)

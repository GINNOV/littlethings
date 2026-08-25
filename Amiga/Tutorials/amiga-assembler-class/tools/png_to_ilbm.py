#!/usr/bin/env python3
from __future__ import annotations

import argparse
import math
import struct
from pathlib import Path

from PIL import Image


def iff_chunk(chunk_id: bytes, payload: bytes) -> bytes:
    if len(chunk_id) != 4:
        raise ValueError("IFF chunk IDs must be four bytes")
    padding = b"\0" if len(payload) & 1 else b""
    return chunk_id + struct.pack(">I", len(payload)) + payload + padding


def write_ilbm(image_path: Path, output_path: Path, colour_count: int) -> None:
    if colour_count < 2 or colour_count > 32 or colour_count & (colour_count - 1):
        raise ValueError("colour count must be a power of two between 2 and 32")

    with Image.open(image_path) as image:
        image = image.convert("RGB")
        width, height = image.size
        if width > 0xFFFF or height > 0xFFFF:
            raise ValueError("ILBM dimensions must fit in 16 bits")

        indexed = image.quantize(
            colors=colour_count,
            method=Image.Quantize.MEDIANCUT,
            dither=Image.Dither.NONE,
        )
        pixels = list(indexed.get_flattened_data())
        depth = int(math.log2(colour_count))
        palette = indexed.getpalette() or []
        palette_bytes = bytearray()
        for index in range(colour_count):
            start = index * 3
            rgb = palette[start : start + 3]
            palette_bytes.extend((rgb + [0, 0, 0])[:3])

    bytes_per_row = ((width + 15) // 16) * 2
    body = bytearray()
    for y in range(height):
        row_start = y * width
        for plane in range(depth):
            row = bytearray(bytes_per_row)
            for x in range(width):
                colour_index = pixels[row_start + x]
                if (colour_index >> plane) & 1:
                    row[x // 8] |= 1 << (7 - (x & 7))
            body.extend(row)

    bmhd = struct.pack(
        ">HHhhBBBBHBBhh",
        width,
        height,
        0,
        0,
        depth,
        0,
        0,
        0,
        0,
        1,
        1,
        width,
        height,
    )
    form_data = b"ILBM" + iff_chunk(b"BMHD", bmhd) + iff_chunk(b"CMAP", bytes(palette_bytes)) + iff_chunk(b"BODY", bytes(body))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(b"FORM" + struct.pack(">I", len(form_data)) + form_data)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert an image to a simple uncompressed Amiga ILBM")
    parser.add_argument("input", type=Path, help="PNG, JPEG, or another Pillow-readable image")
    parser.add_argument("output", type=Path, help="output ILBM file")
    parser.add_argument("--colors", type=int, default=16, help="palette size: 2, 4, 8, 16, or 32")
    args = parser.parse_args()
    write_ilbm(args.input, args.output, args.colors)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
from __future__ import annotations

import argparse
import struct
import wave
from pathlib import Path


def iff_chunk(chunk_id: bytes, payload: bytes) -> bytes:
    if len(chunk_id) != 4:
        raise ValueError("IFF chunk IDs must be four bytes")
    padding = b"\0" if len(payload) & 1 else b""
    return chunk_id + struct.pack(">I", len(payload)) + payload + padding


def pcm_to_signed8(raw: bytes, channels: int, sample_width: int) -> bytes:
    if sample_width == 1:
        channel_samples = [value - 128 for value in raw]
    elif sample_width == 2:
        if len(raw) % 2:
            raise ValueError("16-bit WAV data has an odd byte count")
        values = struct.unpack("<{}h".format(len(raw) // 2), raw)
        channel_samples = [max(-128, min(127, value >> 8)) for value in values]
    else:
        raise ValueError("only 8-bit or 16-bit PCM WAV files are supported")

    if len(channel_samples) % channels:
        raise ValueError("WAV data does not contain complete audio frames")

    mono = []
    for offset in range(0, len(channel_samples), channels):
        average = round(sum(channel_samples[offset : offset + channels]) / channels)
        mono.append(max(-128, min(127, average)))
    return bytes(value & 0xFF for value in mono)


def write_8svx(input_path: Path, output_path: Path) -> None:
    with wave.open(str(input_path), "rb") as wav:
        channels = wav.getnchannels()
        sample_width = wav.getsampwidth()
        sample_rate = wav.getframerate()
        samples = pcm_to_signed8(wav.readframes(wav.getnframes()), channels, sample_width)

    if sample_rate > 0xFFFF:
        raise ValueError("8SVX sample rate must fit in 16 bits")

    vhdr = struct.pack(">IIIHBBI", len(samples), 0, 0, sample_rate, 1, 0, 0x10000)
    name = input_path.stem.encode("ascii", errors="replace") + b"\0"
    form_data = b"8SVX" + iff_chunk(b"VHDR", vhdr) + iff_chunk(b"NAME", name) + iff_chunk(b"BODY", samples)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(b"FORM" + struct.pack(">I", len(form_data)) + form_data)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert PCM WAV audio to an uncompressed IFF FORM 8SVX sample")
    parser.add_argument("input", type=Path, help="PCM WAV input")
    parser.add_argument("output", type=Path, help="output 8SVX file")
    args = parser.parse_args()
    write_8svx(args.input, args.output)


if __name__ == "__main__":
    main()

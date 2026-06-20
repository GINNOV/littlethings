#!/usr/bin/env python3
"""Pre-render beat.smus to a WAV file for the browser version."""
import sys
import wave
import struct
import numpy as np
from pathlib import Path

# Import MusicPlayer from the game
sys.path.insert(0, str(Path(__file__).parent))

# We need pygame mixer initialized for MusicPlayer, but we won't actually use it
# Instead, we'll extract the rendering logic directly

NTSC_CLOCK = 3_579_545
NOTE_LENGTHS = [96, 48, 24, 12, 6, 3, 1, 0]
MIXER_RATE = 44100
SAMPLES_PER_TICK = MIXER_RATE / 50.0

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

INST_CONFIG = {
    0: ('bass1.sfx', OCTAVE1),
    1: ('cymbal.sfx', None),
    2: ('synthsnare.sfx', None),
    3: ('bassguitar.sfx', OCTAVE2),
    4: ('HighBass.sfx', None),
}

SAMPLE_SIZES = {
    0: 2000, 1: 2000, 2: 2000, 3: 2400, 4: 2000,
}


def render_track(track_data, raw_samples, config):
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

        if sid > 128:
            if sid == 0x81:
                if dat in raw_samples:
                    cur_sample = raw_samples[dat]
                cfg = INST_CONFIG.get(dat)
                if cfg and cfg[1] is not None:
                    octave = cfg[1]
            continue

        flags = dat
        division = flags & 0x07
        ticks = NOTE_LENGTHS[division]
        if flags & 0x08:
            ticks = (ticks * 3) // 2
        duration = max(1, int(ticks * SAMPLES_PER_TICK))

        if sid == 0x80:
            chunks.append(np.zeros(duration, dtype=np.float32))
        elif sid < 128:
            tone = sid
            idx = min(tone, len(octave) - 1)
            period = max(1, octave[idx])
            amiga_rate = NTSC_CLOCK / period
            ratio = amiga_rate / MIXER_RATE
            src_len = len(cur_sample)
            chunk = np.zeros(duration, dtype=np.float32)
            if duration > 0 and src_len > 1:
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
    return np.zeros(int(SAMPLES_PER_TICK), dtype=np.float32)


def main():
    base = Path(__file__).parent.parent
    sound_dir = base / 'NTSC' / 'graphics' / 'Sound'
    smus_path = sound_dir / 'beat.smus'
    out_path = base / 'js' / 'music.wav'

    # Load instrument samples
    raw_samples = {}
    for inst_id, (filename, _) in INST_CONFIG.items():
        path = sound_dir / filename
        if path.exists():
            raw = path.read_bytes()
            game_size = SAMPLE_SIZES.get(inst_id, len(raw))
            if len(raw) >= game_size:
                raw = raw[:game_size]
            else:
                raw = raw + b'\x00' * (game_size - len(raw))
            raw_samples[inst_id] = (
                np.frombuffer(raw, dtype=np.int8).astype(np.float32) / 128.0
            )

    # Parse SMUS
    data = smus_path.read_bytes()
    assert data[:4] == b'FORM' and data[8:12] == b'SMUS'

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

    # Render tracks
    track_cfgs = [
        {'octave': OCTAVE1, 'volume': 50.0 / 64.0},
        {'octave': OCTAVE2, 'volume': 50.0 / 64.0},
        {'octave': OCTAVE2, 'volume': 50.0 / 64.0},
    ]

    rendered = []
    for i, tdata in enumerate(tracks[:3]):
        cfg = track_cfgs[i] if i < len(track_cfgs) else track_cfgs[-1]
        audio = render_track(tdata, raw_samples, cfg)
        rendered.append(audio)

    # Tile shorter tracks
    max_len = max(len(a) for a in rendered)
    for i in range(len(rendered)):
        tlen = len(rendered[i])
        if tlen < max_len:
            reps = (max_len + tlen - 1) // tlen
            rendered[i] = np.tile(rendered[i], reps)[:max_len]

    # Mix
    mixed = np.zeros(max_len, dtype=np.float32)
    for audio in rendered:
        mixed[:len(audio)] += audio

    # Normalize
    peak = np.max(np.abs(mixed))
    if peak > 0:
        mixed = mixed / peak * 0.7
    out = (mixed * 32767.0).clip(-32768, 32767).astype(np.int16)

    # Write WAV (stereo — some browsers have issues with mono decodeAudioData)
    stereo = np.column_stack([out, out]).flatten()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(out_path), 'w') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(MIXER_RATE)
        wf.writeframes(stereo.tobytes())

    print(f"Wrote {out_path} ({len(out)} frames, {len(out)/MIXER_RATE:.1f}s, stereo)")


if __name__ == '__main__':
    main()

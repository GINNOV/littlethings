import math


def compute_scene_timestamps(start_time: float, end_time: float, *, frame_count: int,
                             frame_interval: float, max_frames_per_scene: int):
    """Returns sorted timestamps to sample within a scene."""
    duration = end_time - start_time
    if duration <= 0:
        return []

    buffer = min(0.3, duration * 0.05)

    # Generate evenly spaced timestamps (baseline coverage).
    count = max(1, frame_count)
    timestamps = []
    if count == 1:
        timestamps = [start_time + (duration / 2)]
    else:
        step = (duration - 2 * buffer) / (count - 1)
        for i in range(count):
            timestamps.append(start_time + buffer + (i * step))

    # Add interval-based timestamps to catch short actions between samples.
    if frame_interval > 0:
        start_t = start_time + buffer
        end_t = end_time - buffer
        if end_t >= start_t:
            interval_count = int(math.floor((end_t - start_t) / frame_interval)) + 1
            for i in range(interval_count):
                timestamps.append(start_t + (i * frame_interval))

    # Deduplicate and sort timestamps.
    timestamps = sorted(list(set(timestamps)))

    # Cap total frames per scene to avoid runaway costs.
    if max_frames_per_scene > 0 and len(timestamps) > max_frames_per_scene:
        if max_frames_per_scene == 1:
            timestamps = [timestamps[len(timestamps) // 2]]
        else:
            max_count = max_frames_per_scene
            last_index = len(timestamps) - 1
            sampled = []
            for i in range(max_count):
                idx = int(round(i * last_index / (max_count - 1)))
                sampled.append(timestamps[idx])
            timestamps = sampled

    return timestamps

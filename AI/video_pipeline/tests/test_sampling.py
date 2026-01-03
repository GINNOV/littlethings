from utils.sampling import compute_scene_timestamps


def test_compute_scene_timestamps_invalid_duration():
    assert compute_scene_timestamps(
        5.0,
        5.0,
        frame_count=5,
        frame_interval=1.0,
        max_frames_per_scene=24,
    ) == []


def test_compute_scene_timestamps_interval_included():
    timestamps = compute_scene_timestamps(
        0.0,
        4.0,
        frame_count=1,
        frame_interval=1.0,
        max_frames_per_scene=0,
    )
    assert timestamps == sorted(timestamps)
    assert 0.2 in timestamps
    assert 2.0 in timestamps
    assert 3.2 in timestamps


def test_compute_scene_timestamps_cap_preserves_edges():
    full = compute_scene_timestamps(
        0.0,
        10.0,
        frame_count=5,
        frame_interval=0.5,
        max_frames_per_scene=0,
    )
    limited = compute_scene_timestamps(
        0.0,
        10.0,
        frame_count=5,
        frame_interval=0.5,
        max_frames_per_scene=4,
    )

    assert len(limited) == 4
    assert limited[0] == full[0]
    assert limited[-1] == full[-1]

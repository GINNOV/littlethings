"""
Vision-enabled demo (VEDO1) that couples YOLO object detection with Joe's Huenit arm.

The script captures frames from a camera, runs object detection, and repositions the
arm so its end effector tracks the highest-confidence detection. When the detection
occupies enough of the frame the arm descends to a configured pick height and can
optionally enable suction.

Requirements
------------
    uv add opencv-python numpy ultralytics

You also need a YOLOv5/YOLOv8 weights file (``.pt``). Ultralytics provides several
pre-trained checkpoints, for example ``yolov8n.pt``.

Example
-------
    uv run python vedo1.py --model yolov8n.pt --target-label cup --show-window

The demo assumes the camera is roughly aligned above the work area so that the X
axis of the image corresponds to the robot's X axis. Tune the CLI parameters to
match your physical layout before running the script next to hardware.
"""

from __future__ import annotations

import argparse
import signal
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Sequence, Tuple, Union

import numpy as np

try:
    import cv2
except ImportError as exc:  # pragma: no cover - informative runtime guard
    raise SystemExit(
        "vedo1.py requires OpenCV. Install it with `uv add opencv-python`."
    ) from exc

from joe_controller.direct_control import DirectController
from joe_controller.run_advanced_controller import (
    SUCTION_OFF_SEQUENCE,
    SUCTION_ON_SEQUENCE,
    SUCTION_VALVE_RELEASE_DELAY,
)


@dataclass
class Detection:
    """Normalized representation of a single detection."""

    label: str
    confidence: float
    bbox: Tuple[float, float, float, float]  # (x1, y1, x2, y2) normalized 0..1
    center: Tuple[float, float]  # (x, y) normalized 0..1
    area: float  # normalized area (width * height)


class YOLODetector:
    """Thin wrapper around Ultralytics YOLO models."""

    def __init__(self, model_path: Union[str, Path], *, device: str, conf_threshold: float):
        try:
            from ultralytics import YOLO
        except ImportError as exc:  # pragma: no cover - informative runtime guard
            raise RuntimeError(
                "Ultralytics is required. Install it with `uv add ultralytics`."
            ) from exc

        self._model = YOLO(str(model_path))
        self._model.to(device)
        self._names = self._model.names
        self._conf_threshold = conf_threshold

    def detect(self, frame: np.ndarray) -> List[Detection]:
        """Run inference on a frame and return normalized detections."""
        results = self._model(frame, verbose=False)[0]

        height, width = frame.shape[:2]
        detections: List[Detection] = []

        for box in results.boxes:
            conf = float(box.conf.item())
            if conf < self._conf_threshold:
                continue

            cls_idx = int(box.cls.item()) if box.cls is not None else -1
            label = self._names.get(cls_idx, str(cls_idx))
            x1, y1, x2, y2 = box.xyxy[0].tolist()

            x1 = float(np.clip(x1 / width, 0.0, 1.0))
            y1 = float(np.clip(y1 / height, 0.0, 1.0))
            x2 = float(np.clip(x2 / width, 0.0, 1.0))
            y2 = float(np.clip(y2 / height, 0.0, 1.0))

            width_norm = max(0.0, x2 - x1)
            height_norm = max(0.0, y2 - y1)
            center_x = x1 + width_norm / 2.0
            center_y = y1 + height_norm / 2.0

            detections.append(
                Detection(
                    label=label,
                    confidence=conf,
                    bbox=(x1, y1, x2, y2),
                    center=(center_x, center_y),
                    area=width_norm * height_norm,
                )
            )

        return detections


class ArmMotionPlanner:
    """Maps detections to arm movements with optional suction control."""

    def __init__(
        self,
        controller: DirectController,
        *,
        hover_position: Tuple[float, float, float],
        x_span: float,
        workspace: dict,
        command_interval: float,
        move_threshold: float,
        return_home_delay: float,
        suction_area_threshold: float,
        pick_height: float,
        enable_suction: bool,
        verbose: bool,
    ) -> None:
        self.controller = controller
        self.hover_position = {
            "x": hover_position[0],
            "y": hover_position[1],
            "z": hover_position[2],
        }
        self.current_target = dict(self.hover_position)
        self.x_span = x_span
        self.bounds = workspace
        self.command_interval = command_interval
        self.move_threshold = move_threshold
        self.return_home_delay = return_home_delay
        self.suction_area_threshold = suction_area_threshold
        self.pick_height = pick_height
        self.enable_suction = enable_suction
        self.verbose = verbose

        self.last_command_at = 0.0
        self.last_detection_at = time.monotonic()
        self.suction_state = False

    def move_home(self) -> None:
        """Return to the configured hover position."""
        self._issue_move(self.hover_position, force=True)
        self.current_target = dict(self.hover_position)

    def step(self, detection: Optional[Detection]) -> None:
        """Update the arm pose to follow the provided detection."""
        now = time.monotonic()

        if detection is None:
            if now - self.last_detection_at > self.return_home_delay:
                self._issue_move(self.hover_position)
                if self.enable_suction and self.suction_state:
                    self._set_suction(False)
            return

        self.last_detection_at = now
        target = self._pose_from_detection(detection)
        suction_required = (
            self.enable_suction and detection.area >= self.suction_area_threshold
        )

        if suction_required:
            target["z"] = max(self.bounds["z"][0], min(self.pick_height, self.bounds["z"][1]))

        self._issue_move(target)

        if not self.enable_suction:
            return

        if suction_required and not self.suction_state:
            self._set_suction(True)
        elif not suction_required and self.suction_state:
            self._set_suction(False)

    def shutdown(self) -> None:
        """Best-effort cleanup when the program exits."""
        if self.enable_suction and self.suction_state:
            self._set_suction(False)
        self._issue_move(self.hover_position)

    def _pose_from_detection(self, detection: Detection) -> dict:
        x_offset = (detection.center[0] - 0.5) * self.x_span
        pose = dict(self.hover_position)
        pose["x"] += x_offset
        return self._clamp(pose)

    def _clamp(self, pose: dict) -> dict:
        return {
            axis: float(np.clip(pose[axis], *self.bounds[axis]))
            for axis in ("x", "y", "z")
        }

    def _issue_move(self, target: dict, force: bool = False) -> None:
        now = time.monotonic()

        if not force:
            if now - self.last_command_at < self.command_interval:
                return
            if self._distance(target, self.current_target) < self.move_threshold:
                return

        gcode = "G0 X{0:.2f} Y{1:.2f} Z{2:.2f}".format(
            target["x"], target["y"], target["z"]
        )
        self.controller.send_command(gcode)
        if self.verbose:
            print(f"[MOVE] {gcode}")

        self.current_target = dict(target)
        self.last_command_at = now

    @staticmethod
    def _distance(a: dict, b: dict) -> float:
        return float(
            np.sqrt((a["x"] - b["x"]) ** 2 + (a["y"] - b["y"]) ** 2 + (a["z"] - b["z"]) ** 2)
        )

    def _set_suction(self, enable: bool) -> None:
        sequence = SUCTION_ON_SEQUENCE if enable else SUCTION_OFF_SEQUENCE
        for command in sequence:
            response = self.controller.send_command(command, wait_for_ok=True, read_timeout=2.5)
            if response is None:
                print(f"[WARN] No response for suction command {command!r}")
                return

            normalized = response.lower() if response else ""
            if "error" in normalized or "fail" in normalized:
                print(f"[WARN] Controller reported an error: {response}")
                return

            if not enable and command == "M1401 A1":
                time.sleep(SUCTION_VALVE_RELEASE_DELAY)

            time.sleep(0.05)

        self.suction_state = enable
        if self.verbose:
            state = "ON" if enable else "OFF"
            print(f"[SUCTION] {state}")


class VisionGuidedDemo:
    """High-level orchestration for the camera, detector, and motion planner."""

    def __init__(
        self,
        detector: YOLODetector,
        planner: ArmMotionPlanner,
        *,
        video_source: Union[int, str],
        target_label: Optional[str],
        show_window: bool,
        verbose: bool,
    ) -> None:
        self.detector = detector
        self.planner = planner
        self.target_label = target_label
        self.show_window = show_window
        self.verbose = verbose

        self.cap = cv2.VideoCapture(video_source)
        if not self.cap.isOpened():
            raise RuntimeError(f"Unable to open video source {video_source!r}")

        self.running = True
        self.frame_failures = 0

    def run(self) -> None:
        try:
            while self.running:
                ret, frame = self.cap.read()
                if not ret:
                    self.frame_failures += 1
                    if self.frame_failures >= 30:
                        raise RuntimeError(
                            "Failed to read frames from the camera. Verify the camera is connected, "
                            "not in use by another application, and allowed under System Settings > Privacy & Security > Camera."
                        )
                    time.sleep(0.1)
                    continue

                self.frame_failures = 0

                detections = self.detector.detect(frame)
                detection = self._select_detection(detections)

                if self.verbose:
                    info = (
                        f"{detection.label}@{detection.confidence:.2f}"
                        if detection
                        else "none"
                    )
                    print(f"[DETECTION] {info}")

                self.planner.step(detection)

                if self.show_window:
                    annotated = self._annotate_frame(frame.copy(), detections, detection)
                    cv2.imshow("Joe VEDO1", annotated)
                    if cv2.waitKey(1) & 0xFF == 27:
                        print("[INFO] ESC pressed. Exiting.")
                        break
        finally:
            self._cleanup()

    def _cleanup(self) -> None:
        self.planner.shutdown()
        self.cap.release()
        if self.show_window:
            cv2.destroyAllWindows()

    def stop(self, *_: object) -> None:
        """Signal handler support."""
        self.running = False

    def _select_detection(self, detections: Sequence[Detection]) -> Optional[Detection]:
        if not detections:
            return None

        if self.target_label is None:
            return max(detections, key=lambda det: det.confidence)

        candidates = [det for det in detections if det.label == self.target_label]
        if not candidates:
            return None
        return max(candidates, key=lambda det: det.confidence)

    @staticmethod
    def _annotate_frame(
        frame: np.ndarray, detections: Sequence[Detection], active: Optional[Detection]
    ) -> np.ndarray:
        height, width = frame.shape[:2]
        for det in detections:
            x1 = int(det.bbox[0] * width)
            y1 = int(det.bbox[1] * height)
            x2 = int(det.bbox[2] * width)
            y2 = int(det.bbox[3] * height)

            color = (0, 255, 0) if det is active else (128, 128, 128)
            cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)

            label = f"{det.label} {det.confidence:.2f}"
            cv2.putText(
                frame,
                label,
                (x1, max(15, y1 - 10)),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                color,
                2,
                cv2.LINE_AA,
            )

        cv2.putText(
            frame,
            "ESC to exit",
            (10, height - 10),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.5,
            (255, 255, 255),
            1,
            cv2.LINE_AA,
        )
        return frame


def parse_video_source(value: str) -> Union[int, str]:
    """Return an int index when possible, otherwise treat as path."""
    try:
        return int(value)
    except ValueError:
        return value


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Vision-guided pick demo for Joe.")

    parser.add_argument("--serial-port", default="/dev/tty.usbserial-10", help="Serial port for the arm.")
    parser.add_argument("--model", type=Path, required=True, help="Path to a YOLO checkpoint (.pt).")
    parser.add_argument("--device", default="cpu", help="Torch device identifier (cpu, mps, cuda:0, ...).")
    parser.add_argument("--confidence", type=float, default=0.35, help="Minimum detection confidence.")
    parser.add_argument("--target-label", help="Only react to detections with this label.")
    parser.add_argument("--video-source", default="0", help="Camera index or video file path.")
    parser.add_argument("--x-span", type=float, default=160.0, help="Range in mm that maps across the camera frame.")
    parser.add_argument("--hover-x", type=float, default=0.0, help="Home/hover X position in mm.")
    parser.add_argument("--hover-y", type=float, default=220.0, help="Home/hover Y position in mm.")
    parser.add_argument("--hover-z", type=float, default=80.0, help="Home/hover Z position in mm.")
    parser.add_argument("--z-limits", type=float, nargs=2, default=(5.0, 200.0), metavar=("Z_MIN", "Z_MAX"))
    parser.add_argument("--x-limits", type=float, nargs=2, default=(-180.0, 180.0), metavar=("X_MIN", "X_MAX"))
    parser.add_argument("--y-limits", type=float, nargs=2, default=(150.0, 300.0), metavar=("Y_MIN", "Y_MAX"))
    parser.add_argument("--command-interval", type=float, default=0.25, help="Minimum seconds between move commands.")
    parser.add_argument("--move-threshold", type=float, default=5.0, help="Minimum Euclidean delta (mm) to trigger a move.")
    parser.add_argument("--return-home-delay", type=float, default=2.0, help="Seconds without detections before homing.")
    parser.add_argument("--suction-area", type=float, default=0.18, help="Normalized area that triggers suction/pick.")
    parser.add_argument("--pick-height", type=float, default=12.0, help="Z coordinate (mm) used when picking.")
    parser.add_argument("--no-suction", action="store_true", help="Disable suction integration even when area threshold reached.")
    parser.add_argument("--show-window", action="store_true", help="Render an annotated OpenCV preview window.")
    parser.add_argument("--verbose", action="store_true", help="Print detector and motion events.")

    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    model_path = args.model
    if not model_path.exists():
        parser.error(f"Model file {model_path} does not exist.")

    controller = DirectController(port=args.serial_port)
    if not controller.connect():
        print("[ERROR] Unable to open the arm's serial connection.")
        return 1

    try:
        detector = YOLODetector(model_path, device=args.device, conf_threshold=args.confidence)
    except RuntimeError as exc:
        print(f"[ERROR] {exc}")
        controller.disconnect()
        return 1

    workspace = {
        "x": tuple(sorted(args.x_limits)),
        "y": tuple(sorted(args.y_limits)),
        "z": tuple(sorted(args.z_limits)),
    }

    planner = ArmMotionPlanner(
        controller,
        hover_position=(args.hover_x, args.hover_y, args.hover_z),
        x_span=args.x_span,
        workspace=workspace,
        command_interval=args.command_interval,
        move_threshold=args.move_threshold,
        return_home_delay=args.return_home_delay,
        suction_area_threshold=args.suction_area,
        pick_height=args.pick_height,
        enable_suction=not args.no_suction,
        verbose=args.verbose,
    )

    planner.move_home()

    video_source = parse_video_source(args.video_source)

    demo = VisionGuidedDemo(
        detector,
        planner,
        video_source=video_source,
        target_label=args.target_label,
        show_window=args.show_window,
        verbose=args.verbose,
    )

    signal.signal(signal.SIGINT, demo.stop)
    signal.signal(signal.SIGTERM, demo.stop)

    try:
        demo.run()
    finally:
        controller.disconnect()

    return 0


if __name__ == "__main__":
    sys.exit(main())

from __future__ import annotations

import argparse
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True, slots=True)
class Mutation:
    offset: int
    field: str


def parse_field(field: str, fixture: str, fixtures: Path, image: bytes) -> Mutation:
    name, separator, offset_text = field.rpartition(":")
    if not separator or not name or not offset_text.isdecimal():
        raise argparse.ArgumentTypeError("field must be NAME:BYTE_OFFSET")
    byte_offset = int(offset_text)
    if name == "bootblock":
        if byte_offset >= 1024:
            raise argparse.ArgumentTypeError("bootblock offset must be below 1024")
        return Mutation(offset=byte_offset, field=name)
    source = fixtures / fixture / name
    if not source.is_file():
        raise argparse.ArgumentTypeError(f"fixture field does not exist: {name}")
    payload = source.read_bytes()
    if byte_offset >= len(payload):
        raise argparse.ArgumentTypeError("file-data offset is outside fixture payload")
    first = image.find(payload)
    if first < 0 or image.find(payload, first + 1) >= 0:
        raise argparse.ArgumentTypeError("fixture payload is not unique in image")
    return Mutation(offset=first + byte_offset, field=name)


def generate_fixture_image(fixture: str, field: str, fixtures: Path) -> Path:
    project = Path(__file__).resolve().parent.parent
    send2adf = project / "build" / "ci" / "send2adf"
    suffix = field.replace("/", "_").replace(":", "_")
    output = project / "build" / "ci" / "tests" / "mutations" / f"{fixture}-{suffix}.adf"
    output.parent.mkdir(parents=True, exist_ok=True)
    source = fixtures / fixture / "input"
    completed = subprocess.run(
        [send2adf, "-o", output, "-N", "CHARACTERIZE", "-B", "1.3", source],
        check=False,
        capture_output=True,
        text=True,
    )
    if completed.returncode != 0:
        sys.stderr.write(completed.stdout)
        sys.stderr.write(completed.stderr)
        raise SystemExit(completed.returncode)
    return output


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=Path)
    parser.add_argument("--fixture", required=True)
    parser.add_argument("--field", required=True)
    parser.add_argument(
        "--fixtures",
        type=Path,
        default=Path(__file__).resolve().parent / "fixtures",
    )
    arguments = parser.parse_args()
    image_path = arguments.image or generate_fixture_image(
        arguments.fixture, arguments.field, arguments.fixtures
    )
    image = bytearray(image_path.read_bytes())
    try:
        mutation = parse_field(
            arguments.field, arguments.fixture, arguments.fixtures, image
        )
    except argparse.ArgumentTypeError as error:
        parser.error(str(error))
    image[mutation.offset] ^= 0x01
    image_path.write_bytes(image)
    print(
        f"mutation_applied field={mutation.field} image_offset={mutation.offset} image={image_path}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

# Joe - Huenit Robotic Arm Controller

Joe is a Python controller for the Huenit robotic arm. It bypasses the official HUENIT LAB software and talks to the robot directly over USB serial for real-time command-line control.

## Features

- Direct serial control over USB.
- Keyboard control for X/Y/Z movement.
- Curses-based terminal dashboard with connection status, coordinates, and logs.
- Suction end-effector toggles.
- Robot position query support.
- Programmable multi-step sequences.

## Requirements

- macOS.
- Python 3.9 or newer.
- [`uv`](https://docs.astral.sh/uv/) for environment and dependency management.
- Huenit robotic arm connected over USB.
- FTDI serial driver. macOS often has this built in; if no `/dev/tty.usbserial-*` device appears, install the official FTDI VCP driver.

## Setup

Install `uv` if needed:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Create the environment and install the project:

```bash
uv venv
source .venv/bin/activate
uv pip install -e .
```

## Serial Port

Connect and power on the robot, then list serial devices:

```bash
ls /dev/tty.*
```

Look for a device such as `/dev/tty.usbserial-10`. Update the `SERIAL_PORT` value in `run_advanced_controller.py` with that path.

## Run

From this folder:

```bash
uv run python run_advanced_controller.py
```

## Controls

| Key | Action |
| --- | --- |
| Arrow keys | Move in the X/Y plane. |
| Page Up / Page Down | Move in the Z plane. |
| Shift | Precision mode for finer movement. |
| `S` | Toggle suction on. |
| `D` | Toggle suction off. |
| `R` | Request current robot position. |
| `P` | Run the programmed sequence in the script. |
| Esc | Safely disconnect and exit. |

## Safety Notes

- Keep the arm clear of people, loose objects, and cables before running commands.
- Start with small movements after changing serial settings or code.
- Use Esc to disconnect cleanly before unplugging the robot.

## External Material

`external/` contains imported Huenit-related projects and reference material. Treat those READMEs as upstream/vendor documentation unless this repo says otherwise.

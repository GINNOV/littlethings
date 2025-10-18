Joe - A Huenit Robotic Arm Controller

This project provides a Python-based controller for the Huenit robotic arm, bypassing the official HUENIT LAB software for direct, real-time control from the command line.

It features an advanced terminal interface for manual control, status monitoring, and execution of pre-programmed sequences.

Features

Direct Serial Control: Communicates directly with the robot via USB, removing dependency on official software.

Real-time Keyboard Control: Smooth, responsive manual control using keyboard arrow keys.

Advanced Terminal UI: A clean, refreshing dashboard built with curses that shows connection status, real-time coordinates, and command logs.

Suction End-Effector Control: Toggle the suction module on and off with single key presses.

Status Reporting: Query the robot for its current XYZ coordinates.

Programmable Sequences: Define and execute simple, multi-step programs.

Setup and Installation (macOS)

This project is managed using uv, a fast Python package installer and resolver.

1. Prerequisites

Python 3.9+

uv: If you don't have it, install it:

curl -LsSf [https://astral.sh/uv/install.sh](https://astral.sh/uv/install.sh) | sh


FTDI Driver: macOS should have a built-in driver. Connect the robot via USB and check for it by running ls /dev/tty.*. You should see a device named /dev/tty.usbserial-XXXX. If not, download and install the official FTDI VCP driver.

2. Project Setup

Clone or Download the Project:
Get the project files onto your local machine.

Create and Activate the Virtual Environment:
Navigate to the project's root directory in your terminal and run:

# Create the virtual environment
uv venv

# Activate it (important for the next step)
source .venv/bin/activate


Install Dependencies:
uv will read the pyproject.toml file and install the necessary packages (pynput and pyserial).

uv pip install -e .


3. Configuration

Find the Serial Port:
With the robot connected and powered on, run this command in your terminal:

ls /dev/tty.*


Identify the correct device name (e.g., /dev/tty.usbserial-10).

Edit the Script:
Open the run_advanced_controller.py file and update the SERIAL_PORT variable at the top with the port name you found.

How to Run

Ensure your virtual environment is activated (source .venv/bin/activate) if you are using the traditional method.

Alternatively, you can use uv run which handles the environment automatically. From the project's root directory, run:

uv run python run_advanced_controller.py


The terminal will clear and the controller UI will appear.

Controls

Arrow Keys: Move the robot in the X/Y plane.

Page Up / Page Down: Move the robot in the Z plane.

Hold Shift: Activates precision mode for finer movements.

S: Toggles suction ON.

D: Toggles suction OFF.

R: Requests the robot's current position and updates the display.

P: Runs the pre-programmed sequence defined in the script.

ESC: Safely disconnects from the robot and exits the program.

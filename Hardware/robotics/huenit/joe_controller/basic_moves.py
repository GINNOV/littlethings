# Module: basic_moves
# Description: A script for real-time keyboard control of the Huenit "Joe" robotic arm.
#
# Controls:
#   - Arrow Keys (Up, Down, Left, Right): Move in the X/Y plane.
#   - Page Up / Page Down: Move along the Z-axis (height).
#   - Shift (Hold): Switch to precision mode (smaller movements).
#   - Home: Return the arm to its initial home position.
#   - Esc: Exit the program.

import subprocess
import json
import time
import threading
from pynput import keyboard

# --- CONFIGURATION ---
# IMPORTANT: You MUST set this to the absolute path of the python executable
# that is part of the Huenit software installation. This is a macOS example.
HUENIT_PYTHON_PATH = "/Applications/Huenit/python/bin/python3"
# The path to the communicator script from the community SDK.
COMMUNICATOR_SCRIPT_PATH = "/path/to/sdk/communicator.py"

# --- Movement Settings ---
HOME_POSITION = {"x": 0, "y": 250, "z": 50}
REGULAR_STEP = 10  # Movement distance in mm for normal mode
PRECISION_STEP = 1  # Movement distance in mm for precision mode (when Shift is held)
LOOP_INTERVAL = 0.1  # Time in seconds between movement updates


class RobotController:
    """Manages the robot's state and sends commands."""

    def __init__(self):
        self.current_position = HOME_POSITION.copy()
        self.target_position = HOME_POSITION.copy()
        self.keys_pressed = set()
        self.is_running = True
        self.lock = threading.Lock()  # To prevent race conditions on position updates

    def send_command(self, gcode_command):
        """
        Sends a G-code command to the robot using the SDK's Direct Method.
        """
        if not HUENIT_PYTHON_PATH or "path/to" in HUENIT_PYTHON_PATH:
            print("ERROR: Please set HUENIT_PYTHON_PATH in the script.")
            return

        print(f"Sending command: {gcode_command}")
        try:
            # Construct the JSON event payload
            event_payload = {"Event": "Console_Send", "Value": gcode_command}
            # The payload needs to be a string for the command line argument
            payload_str = json.dumps(event_payload)

            # Execute the communicator script as a subprocess
            subprocess.run(
                [HUENIT_PYTHON_PATH, COMMUNICATOR_SCRIPT_PATH, payload_str],
                capture_output=True,
                text=True,
                check=True,
            )
        except FileNotFoundError:
            print(f"ERROR: Could not find Huenit Python at '{HUENIT_PYTHON_PATH}'.")
            print("Please ensure the path is correct.")
        except subprocess.CalledProcessError as e:
            print(f"ERROR: The communicator script failed.")
            print(f"  Return code: {e.returncode}")
            print(f"  Output: {e.stdout}")
            print(f"  Error Output: {e.stderr}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

    def update_target_position(self):
        """Calculates the next target position based on currently pressed keys."""
        with self.lock:
            step = (
                PRECISION_STEP
                if keyboard.Key.shift in self.keys_pressed
                else REGULAR_STEP
            )

            # Create a temporary copy to modify
            next_pos = self.target_position.copy()

            if keyboard.Key.up in self.keys_pressed:
                next_pos["y"] += step
            if keyboard.Key.down in self.keys_pressed:
                next_pos["y"] -= step
            if keyboard.Key.left in self.keys_pressed:
                next_pos["x"] -= step
            if keyboard.Key.right in self.keys_pressed:
                next_pos["x"] += step
            if keyboard.Key.page_up in self.keys_pressed:
                next_pos["z"] += step
            if keyboard.Key.page_down in self.keys_pressed:
                next_pos["z"] -= step

            # Check if the position has actually changed before sending a command
            if next_pos != self.target_position:
                self.target_position = next_pos
                gcode = f"G0 X{self.target_position['x']} Y{self.target_position['y']} Z{self.target_position['z']}"
                self.send_command(gcode)

    def on_press(self, key):
        """Callback for when a key is pressed."""
        with self.lock:
            self.keys_pressed.add(key)

        # Handle single-press actions
        if key == keyboard.Key.esc:
            print("Escape key pressed. Exiting...")
            self.is_running = False
            return False  # Stop the listener
        if key == keyboard.Key.home:
            print("Home key pressed. Returning to home position...")
            with self.lock:
                self.target_position = HOME_POSITION.copy()
            gcode = f"G0 X{self.target_position['x']} Y{self.target_position['y']} Z{self.target_position['z']}"
            self.send_command(gcode)

    def on_release(self, key):
        """Callback for when a key is released."""
        try:
            with self.lock:
                self.keys_pressed.remove(key)
        except KeyError:
            pass  # Ignore if key was already removed

    def control_loop(self):
        """The main loop that continuously updates the robot's position."""
        while self.is_running:
            self.update_target_position()
            time.sleep(LOOP_INTERVAL)


def main():
    """Sets up the controller and starts the keyboard listener."""
    print("--- Joe's Keyboard Controller ---")
    print("Controls:")
    print("  - Arrow Keys: Move in X/Y plane")
    print("  - Page Up/Down: Move in Z plane")
    print("  - Hold Shift: Precision mode")
    print("  - Home: Return to start position")
    print("  - Esc: Exit")
    print("---------------------------------")

    controller = RobotController()

    # Start the control loop in a separate thread
    control_thread = threading.Thread(target=controller.control_loop)
    control_thread.daemon = (
        True  # Allows main thread to exit even if this one is running
    )
    control_thread.start()

    # Start listening for keyboard events in the main thread
    with keyboard.Listener(
        on_press=controller.on_press, on_release=controller.on_release
    ) as listener:
        listener.join()

    print("Program terminated.")


if __name__ == "__main__":
    main()

# Main Script: run_keyboard_direct
# Description: Combines the DirectController with the keyboard listener
#              for real-time, low-latency control of the Huenit arm.

import time
import threading
from pynput import keyboard
from joe_controller.direct_control import DirectController

# --- CONFIGURATION ---
# CRITICAL: You MUST update this path.
# Find the correct serial port for your robot.
#
# On macOS, it will likely start with '/dev/tty.usbmodem' or '/dev/tty.usbserial'.
# You can find it by running this command in your terminal: ls /dev/tty.*
SERIAL_PORT = "/dev/tty.usbserial-10"  # <-- Updated with your correct port

# --- Movement Settings ---
HOME_POSITION = {"x": 0, "y": 250, "z": 50}
REGULAR_STEP = 10  # Movement distance in mm for normal mode
PRECISION_STEP = 1  # Movement distance in mm for precision mode (when Shift is held)
LOOP_INTERVAL = 0.1  # Time in seconds between movement updates


class KeyboardHandler:
    """Manages keyboard input and translates it into robot commands."""

    def __init__(self, controller):
        self.controller = controller
        self.target_position = HOME_POSITION.copy()
        self.keys_pressed = set()
        self.is_running = True
        self.lock = threading.Lock()

    def update_target_position(self):
        """Calculates and sends the next target position based on pressed keys."""
        with self.lock:
            step = (
                PRECISION_STEP
                if keyboard.Key.shift in self.keys_pressed
                else REGULAR_STEP
            )

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

            if next_pos != self.target_position:
                self.target_position = next_pos
                gcode = f"G0 X{self.target_position['x']} Y{self.target_position['y']} Z{self.target_position['z']}"
                self.controller.send_command(gcode)

    def on_press(self, key):
        """Callback for when a key is pressed."""
        with self.lock:
            self.keys_pressed.add(key)

        if key == keyboard.Key.esc:
            print("Escape key pressed. Exiting...")
            self.is_running = False
            return False  # Stop the listener

        if key == keyboard.Key.home:
            print("Home key pressed. Returning to home position...")
            with self.lock:
                self.target_position = HOME_POSITION.copy()
            gcode = f"G0 X{self.target_position['x']} Y{self.target_position['y']} Z{self.target_position['z']}"
            self.controller.send_command(gcode)

    def on_release(self, key):
        """Callback for when a key is released."""
        try:
            with self.lock:
                self.keys_pressed.remove(key)
        except KeyError:
            pass

    def control_loop(self):
        """Main loop that continuously updates the robot's position."""
        while self.is_running:
            self.update_target_position()
            time.sleep(LOOP_INTERVAL)


def main():
    """Initializes the controller and starts the program."""
    controller = DirectController(port=SERIAL_PORT)

    # Use a try...finally block to ensure the connection is always closed
    try:
        if not controller.connect():
            # If connection fails, the connect method will print errors.
            return  # Exit the script.

        handler = KeyboardHandler(controller)

        control_thread = threading.Thread(target=handler.control_loop)
        control_thread.daemon = True
        control_thread.start()

        print("\n--- Joe's DIRECT Keyboard Controller ---")
        print("Controls:")
        print("  - Arrow Keys: Move in X/Y plane")
        print("  - Page Up/Down: Move in Z plane")
        print("  - Hold Shift: Precision mode")
        print("  - Home: Return to start position")
        print("  - Esc: Exit")
        print("--------------------------------------")

        with keyboard.Listener(
            on_press=handler.on_press, on_release=handler.on_release
        ) as listener:
            listener.join()

    finally:
        controller.disconnect()
        print("Program terminated.")


if __name__ == "__main__":
    main()

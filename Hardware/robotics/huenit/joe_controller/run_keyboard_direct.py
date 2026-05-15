# Module: run_keyboard_direct
# Description: Maintains the legacy pynput-based keyboard controller.

import threading
import time
from typing import Optional, Set

from pynput import keyboard

from .direct_control import DirectController

DEFAULT_SERIAL_PORT = "/dev/tty.usbserial-10"
HOME_POSITION = {"x": 0.0, "y": 250.0, "z": 50.0}
REGULAR_STEP = 10.0
PRECISION_STEP = 1.0
LOOP_INTERVAL = 0.1


class KeyboardHandler:
    """Translate pynput keyboard events into robot movements."""

    def __init__(self, controller: DirectController):
        self.controller = controller
        self.target_position = HOME_POSITION.copy()
        self.keys_pressed: Set[keyboard.Key] = set()
        self.is_running = True
        self.lock = threading.Lock()

    def update_target_position(self) -> None:
        """Calculate and send the next target position."""
        with self.lock:
            step = (
                PRECISION_STEP if keyboard.Key.shift in self.keys_pressed else REGULAR_STEP
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
                gcode = (
                    f"G0 X{self.target_position['x']} "
                    f"Y{self.target_position['y']} "
                    f"Z{self.target_position['z']}"
                )
                self.controller.send_command(gcode)

    def on_press(self, key: keyboard.Key) -> Optional[bool]:
        """Handle key press events."""
        with self.lock:
            self.keys_pressed.add(key)

        if key == keyboard.Key.esc:
            print("Escape key pressed. Exiting...")
            self.is_running = False
            return False

        if key == keyboard.Key.home:
            print("Home key pressed. Returning to home position...")
            with self.lock:
                self.target_position = HOME_POSITION.copy()
            gcode = (
                f"G0 X{self.target_position['x']} "
                f"Y{self.target_position['y']} "
                f"Z{self.target_position['z']}"
            )
            self.controller.send_command(gcode)
        return None

    def on_release(self, key: keyboard.Key) -> None:
        """Handle key release events."""
        with self.lock:
            self.keys_pressed.discard(key)

    def control_loop(self) -> None:
        """Main loop that continuously updates the robot's position."""
        while self.is_running:
            self.update_target_position()
            time.sleep(LOOP_INTERVAL)


def run(serial_port: str = DEFAULT_SERIAL_PORT, controller: Optional[DirectController] = None) -> None:
    """
    Launch the keyboard controller.

    Args:
        serial_port: Serial port to use when a controller is not provided.
        controller: Optional pre-connected controller instance.
    """
    local_controller = controller or DirectController(port=serial_port)
    owns_controller = controller is None

    try:
        if owns_controller and not local_controller.connect():
            return

        handler = KeyboardHandler(local_controller)
        control_thread = threading.Thread(target=handler.control_loop, daemon=True)
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
        if owns_controller:
            local_controller.disconnect()
            print("Program terminated.")


def main() -> None:
    """Console-script friendly wrapper used by CLI entry points."""
    run()


if __name__ == "__main__":
    main()

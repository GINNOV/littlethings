# Module: run_advanced_controller
# Description: Entry point for the advanced curses-based Huenit arm controller.

import curses
import threading
import time
from typing import Dict, Optional, List, Tuple

from .direct_control import DirectController
from .ui_manager import UIManager

DEFAULT_SERIAL_PORT = "/dev/tty.usbserial-10"
HOME_POSITION = {"x": 0.0, "y": 250.0, "z": 50.0}
STEP_SIZE = 10.0
LOOP_INTERVAL = 0.05

# Manufacturer-identical command sequences for vacuum control.
SUCTION_ON_SEQUENCE = ("M1401 A0", "M1400 A1023")
SUCTION_OFF_SEQUENCE = ("M1400 A0", "M1401 A1", "M1401 A0")
SUCTION_VALVE_RELEASE_DELAY = 0.3
SUCTION_ON_TOKEN = "<SUCTION_ON>"
SUCTION_OFF_TOKEN = "<SUCTION_OFF>"

# A simple pre-programmed sequence of G-code commands.
PROGRAM_SEQUENCE = [
    "G0 X50 Y250 Z50",
    "G0 X50 Y250 Z10",
    SUCTION_ON_TOKEN,
    "G0 X50 Y250 Z50",
    "G0 X-50 Y250 Z50",
    "G0 X-50 Y250 Z10",
    SUCTION_OFF_TOKEN,
    "G0 X-50 Y250 Z50",
]


class AdvancedControllerApp:
    """Connects the UI and the DirectController into a cohesive workflow."""

    def __init__(self, stdscr, controller: DirectController):
        self.ui = UIManager(stdscr)
        self.controller = controller
        self.is_running = True
        self.current_position: Dict[str, float] = HOME_POSITION.copy()
        self.target_position: Dict[str, float] = HOME_POSITION.copy()
        self.suction_on = False

    def run(self) -> None:
        """Main application loop."""
        self.ui.update_status("CONNECTED", "info")
        self.ui.update_suction_state(self.suction_on)
        self.ui.update_position(self.current_position)

        self.go_home()
        self.request_position_update()

        while self.is_running:
            key = self.ui.stdscr.getch()
            curses.flushinp()

            if key != -1:
                self.process_input(key)

            time.sleep(LOOP_INTERVAL)

    def process_input(self, key: int) -> None:
        """Handle keyboard input passed from curses."""
        if key == 27:  # ESC key
            self.is_running = False
            return
        if key in (ord("s"), ord("S")):
            self.toggle_suction(True)
            return
        if key in (ord("d"), ord("D")):
            self.toggle_suction(False)
            return
        if key in (ord("r"), ord("R")):
            self.request_position_update()
            return
        if key in (ord("p"), ord("P")):
            threading.Thread(target=self.run_sequence, daemon=True).start()
            return
        if key == curses.KEY_HOME:
            self.go_home()
            return

        moved = False
        if key == curses.KEY_UP:
            self.target_position["y"] += STEP_SIZE
            moved = True
        elif key == curses.KEY_DOWN:
            self.target_position["y"] -= STEP_SIZE
            moved = True
        elif key == curses.KEY_LEFT:
            self.target_position["x"] -= STEP_SIZE
            moved = True
        elif key == curses.KEY_RIGHT:
            self.target_position["x"] += STEP_SIZE
            moved = True
        elif key == curses.KEY_PPAGE:
            self.target_position["z"] += STEP_SIZE
            moved = True
        elif key == curses.KEY_NPAGE:
            self.target_position["z"] -= STEP_SIZE
            moved = True

        if moved:
            self.send_movement_command()

    def send_movement_command(self) -> None:
        """Emit the current target position as a G-code move."""
        gcode = f"G0 X{self.target_position['x']} Y{self.target_position['y']} Z{self.target_position['z']}"
        self.controller.send_command(gcode)
        self.ui.log_message(gcode)
        self.current_position = self.target_position.copy()
        self.ui.update_position(self.current_position)

    def toggle_suction(self, enable: bool, *, source: str = "manual") -> bool:
        """Toggle the suction accessory."""
        label = "ON" if enable else "OFF"
        self.ui.update_status(f"SUCTION {label}...", "warn")

        success, responses = self._execute_suction_sequence(enable)
        if not success:
            last_command, last_response = responses[-1]
            display_response = last_response if last_response else "NO RESPONSE"
            self.ui.log_message(last_command, display_response)
            self.ui.update_status("SUCTION ERROR", "error")
            return False

        self.suction_on = enable
        self.ui.update_suction_state(self.suction_on)
        last_command, last_response = responses[-1]
        display_response = last_response if last_response else "ok"
        self.ui.log_message(last_command, display_response)
        if source == "manual":
            self.ui.update_status("CONNECTED", "info")
        return True

    def go_home(self) -> None:
        """Return the robot to its configured home position."""
        self.target_position = HOME_POSITION.copy()
        self.send_movement_command()

    def request_position_update(self) -> None:
        """Fetch, parse, and display the robot's current position."""
        self.ui.update_status("REQUESTING POS...", "warn")
        pos = self.controller.get_position()
        if pos:
            self.current_position = pos
            self.target_position = pos.copy()
            self.ui.update_position(self.current_position)
            self.ui.update_status("CONNECTED", "info")
            self.ui.log_message("M114", str(pos))
        else:
            self.ui.update_status("POS READ FAILED", "error")

    def run_sequence(self) -> None:
        """Execute the pre-programmed command sequence."""
        self.ui.update_status("PROGRAM RUNNING...", "warn")
        sequence_failed = False
        for gcode in PROGRAM_SEQUENCE:
            if not self.is_running:
                break
            if gcode == SUCTION_ON_TOKEN:
                if not self.toggle_suction(True, source="program"):
                    sequence_failed = True
                    break
                self.ui.update_status("PROGRAM RUNNING...", "warn")
                continue
            if gcode == SUCTION_OFF_TOKEN:
                if not self.toggle_suction(False, source="program"):
                    sequence_failed = True
                    break
                self.ui.update_status("PROGRAM RUNNING...", "warn")
                continue

            response = self.controller.send_command(gcode, wait_for_ok=True)
            self.ui.log_message(gcode, response or "")

            time.sleep(1.0)
        if not sequence_failed and self.is_running:
            self.request_position_update()
            self.ui.update_status("PROGRAM FINISHED", "info")

    def _execute_suction_sequence(self, enable: bool) -> Tuple[bool, List[Tuple[str, Optional[str]]]]:
        """Execute the manufacturer sequence for enabling or disabling suction."""
        sequence = SUCTION_ON_SEQUENCE if enable else SUCTION_OFF_SEQUENCE
        results: List[Tuple[str, Optional[str]]] = []

        for index, command in enumerate(sequence):
            response = self.controller.send_command(command, wait_for_ok=True, read_timeout=3.0)
            results.append((command, response))

            if response is None:
                return False, results

            normalized = response.lower() if response else ""
            if "error" in normalized or "fail" in normalized:
                return False, results

            if not enable and command == "M1401 A1":
                time.sleep(SUCTION_VALVE_RELEASE_DELAY)

            time.sleep(0.05)

        return True, results


def _main(stdscr, controller: DirectController) -> None:
    """Wrapper used by curses.wrapper to launch the UI."""
    AdvancedControllerApp(stdscr, controller).run()


def run(serial_port: str = DEFAULT_SERIAL_PORT, controller: Optional[DirectController] = None) -> None:
    """
    Launch the advanced controller UI.

    Args:
        serial_port: Serial port to connect when controller is not provided.
        controller: Optional pre-configured DirectController, handy for tests.
    """
    local_controller = controller or DirectController(port=serial_port)
    owns_controller = controller is None

    if owns_controller and not local_controller.connect():
        print("Program aborted. Please check the port and cable connection.")
        return

    print("Initializing UI...")
    time.sleep(1)
    try:
        curses.wrapper(_main, local_controller)
    finally:
        if owns_controller:
            print("\nUI closed. Disconnecting from robot.")
            local_controller.disconnect()
            print("Program terminated.")


def main() -> None:
    """Console-script friendly wrapper that prints a banner before running."""
    print("--- Joe's Advanced Controller ---")
    run()


if __name__ == "__main__":
    main()

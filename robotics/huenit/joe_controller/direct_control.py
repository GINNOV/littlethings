# Module: direct_control
# Description: Handles direct serial communication with the Huenit robotic arm.
# This module bypasses the need for the HUENIT LAB software by sending
# G-code commands directly over a USB serial port.

import re
import threading
import time
from typing import Dict, List, Optional

import serial
import serial.tools.list_ports

_AXIS_PATTERN = re.compile(r"([XYZ])\s*[:=]\s*(-?\d+(?:\.\d+)?)", re.IGNORECASE)


class DirectController:
    """Manages a direct serial connection to the robot."""

    def __init__(self, port: str, baudrate: int = 115200, read_timeout: float = 1.0):
        """
        Initialize the controller with serial connection parameters.

        Args:
            port: Serial device path, for example '/dev/tty.usbserial-10'.
            baudrate: Serial baud rate; defaults to the arm's expected 115200.
            read_timeout: Default timeout (seconds) used when waiting for responses.
        """
        self.port = port
        self.baudrate = baudrate
        self.read_timeout = read_timeout
        self.ser: Optional[serial.Serial] = None
        self._lock = threading.Lock()

    @staticmethod
    def find_ports() -> List[str]:
        """Return a list of available serial port device names."""
        ports = serial.tools.list_ports.comports()
        return [port.device for port in ports]

    def connect(self) -> bool:
        """Establish the serial connection to the robot."""
        print(f"Attempting to connect to {self.port} at {self.baudrate} baud...")
        try:
            self.ser = serial.Serial(
                self.port,
                self.baudrate,
                timeout=self.read_timeout,
                write_timeout=self.read_timeout,
            )
            # Allow the controller time to reboot after opening the port.
            time.sleep(2)
            if self.ser.is_open:
                self.ser.reset_input_buffer()
                print("Connection successful.")
                return True

            print("Error: Could not open the serial port.")
            return False
        except serial.SerialException as exc:
            print(f"Error connecting to serial port: {exc}")
            print("Please check the following:")
            print("  1. Is the robot plugged in and powered on?")
            print(f"  2. Is '{self.port}' the correct port name?")
            available_ports = self.find_ports()
            if available_ports:
                print(f"  Available ports found: {', '.join(available_ports)}")
            else:
                print("  No available serial ports found.")
            return False

    def disconnect(self) -> None:
        """Close the serial connection."""
        with self._lock:
            if self.ser and self.ser.is_open:
                self.ser.close()
                print("Connection closed.")
            self.ser = None

    def send_command(
        self,
        gcode_command: str,
        wait_for_ok: bool = False,
        read_timeout: Optional[float] = None,
    ) -> Optional[str]:
        """
        Send a single G-code command to the robot.

        Args:
            gcode_command: Command to send, for example 'G0 X10 Y10 Z10'.
            wait_for_ok: When True, block until an 'ok' response (or timeout).
            read_timeout: Optional override for how long to wait for responses.

        Returns:
            Collected response lines joined with newlines when waiting for OK,
            otherwise None. Returns an empty string when no response arrived
            before timing out.
        """
        if not self._is_connected():
            print("Cannot send command: Not connected.")
            return None

        command = gcode_command.strip() + "\n"
        timeout = read_timeout if read_timeout is not None else self.read_timeout

        with self._lock:
            assert self.ser  # for type checkers
            self.ser.write(command.encode("utf-8"))
            self.ser.flush()
            # Short pause to keep the controller responsive when streaming.
            time.sleep(0.02)

            if not wait_for_ok:
                return None

            lines = self._read_until_ok(timeout)
            return "\n".join(lines) if lines else ""

    def get_position(self, read_timeout: float = 2.0) -> Optional[Dict[str, float]]:
        """
        Request the current XYZ position from the robot controller.

        Args:
            read_timeout: How long to wait for the response in seconds.

        Returns:
            Dictionary with 'x', 'y', and 'z' keys when parsing succeeds, or
            None when no position could be determined.
        """
        response = self.send_command("M114", wait_for_ok=True, read_timeout=read_timeout)
        if not response:
            return None

        axes: Dict[str, float] = {}
        for line in response.splitlines():
            axes.update(self._extract_axes(line))

        if not axes:
            return None

        # Default missing axes to zero so the UI retains a predictable shape.
        return {
            "x": axes.get("x", 0.0),
            "y": axes.get("y", 0.0),
            "z": axes.get("z", 0.0),
        }

    def _extract_axes(self, text: str) -> Dict[str, float]:
        """Extract axis values from a single response line."""
        result: Dict[str, float] = {}
        for axis, value in _AXIS_PATTERN.findall(text):
            try:
                result[axis.lower()] = float(value)
            except ValueError:
                continue
        return result

    def _read_until_ok(self, timeout: float) -> List[str]:
        """Read lines until an 'ok' token is observed or the timeout expires."""
        assert self.ser  # guarded by caller
        lines: List[str] = []
        deadline = time.time() + timeout

        while time.time() < deadline:
            raw = self.ser.readline()
            if not raw:
                continue

            decoded = raw.decode("utf-8", errors="ignore").strip()
            if not decoded:
                continue

            lines.append(decoded)

            lowered = decoded.lower()
            if lowered == "ok" or lowered.startswith("ok ") or lowered.endswith(" ok"):
                break

        return lines

    def _is_connected(self) -> bool:
        """Return True when the serial port is open and ready."""
        return bool(self.ser and self.ser.is_open)

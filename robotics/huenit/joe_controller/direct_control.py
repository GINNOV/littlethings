# Module: direct_control
# Description: Handles direct serial communication with the Huenit robotic arm.
# This module bypasses the need for the HUENIT LAB software by sending
# G-code commands directly over a USB serial port.

import serial
import serial.tools.list_ports
import time


class DirectController:
    """Manages a direct serial connection to the robot."""

    def __init__(self, port, baudrate=115200):
        """
        Initializes the controller.
        Args:
            port (str): The serial port to connect to (e.g., '/dev/tty.usbmodem14101').
            baudrate (int): The communication speed. Defaults to 115200.
        """
        self.port = port
        self.baudrate = baudrate
        self.ser = None  # Will hold the serial connection object

    @staticmethod
    def find_ports():
        """Lists available serial ports on the system."""
        ports = serial.tools.list_ports.comports()
        return [port.device for port in ports]

    def connect(self):
        """Establishes the serial connection to the robot."""
        print(f"Attempting to connect to {self.port} at {self.baudrate} baud...")
        try:
            self.ser = serial.Serial(self.port, self.baudrate, timeout=1)
            # Wait for the serial connection to initialize
            time.sleep(2)
            if self.ser.is_open:
                print("Connection successful.")
                return True
            else:
                print("Error: Could not open the serial port.")
                return False
        except serial.SerialException as e:
            print(f"Error connecting to serial port: {e}")
            print("Please check the following:")
            print("  1. Is the robot plugged in and powered on?")
            print(f"  2. Is '{self.port}' the correct port name?")
            available_ports = self.find_ports()
            if available_ports:
                print(f"  Available ports found: {', '.join(available_ports)}")
            else:
                print("  No available serial ports found.")
            return False

    def disconnect(self):
        """Closes the serial connection."""
        if self.ser and self.ser.is_open:
            self.ser.close()
            print("Connection closed.")

    def send_command(self, gcode_command):
        """
        Sends a G-code command to the robot.
        Args:
            gcode_command (str): The G-code string to send (e.g., "G0 X100 Y100").
        """
        if self.ser and self.ser.is_open:
            # The command must be encoded as bytes and terminated with a newline
            command = gcode_command.strip() + "\n"
            self.ser.write(command.encode("utf-8"))
            print(f"Sent: {gcode_command}")
            # A short delay can help the robot's controller keep up
            time.sleep(0.05)
        else:
            print("Cannot send command: Not connected.")

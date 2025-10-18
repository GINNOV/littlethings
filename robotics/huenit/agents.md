AI Instructions & Project Log for "Joe" the Huenit Robot

1. AI Persona & Role

You are an expert in robotics, Python, and software engineering. Your primary role is to assist in developing a modular, robust software suite to control "Joe," a Huenit robotic arm. You will operate on a macOS environment and utilize the uv tool for project and dependency management.

Your responses should be professional, clear, and proactive. When you identify potential issues or better architectural patterns, you should propose them, as you did with the curses UI. All code must be well-documented and tested in theory before being presented.

2. Project Architecture Overview

This project has evolved from initial discovery to a more robust architecture.

Control Method: We are using Direct Serial Control. We write raw G-code commands directly to the robot's USB serial port (e.g., /dev/tty.usbserial-10). This method is fast, reliable, and bypasses the need for the official HUENIT LAB software.

Core Library: The joe_controller Python package contains all the core logic.

direct_control.py: A class-based module for managing the serial connection and sending/receiving commands.

ui_manager.py: A dedicated module for managing the curses-based terminal user interface.

Main Executable: run_advanced_controller.py is the primary entry point for the application. It integrates the controller and UI modules to provide a real-time, interactive dashboard.

Environment: The project is managed using uv with all dependencies defined in pyproject.toml.

3. Project Log & Key Decisions

Module: basic_moves (Initial)

Decision: Started with keyboard control.

Method: Used the community SDK's subprocess method to interact with the HUENIT LAB software's internal Python.

Status: Superseded. This method was deemed too fragile and dependent on the official software's installation path.

Module: Direct Serial Control & run_keyboard_direct.py

Decision: Switched to a more direct and robust control method based on research into similar projects.

Method: Implemented direct G-code communication over a serial port using the pyserial library.

Status: Successful. This proved to be a stable foundation. This script is now superseded by the advanced controller.

Module: Advanced Controller & UI

Decision: Implement a modern, non-scrolling terminal UI for better real-time feedback. Add suction, status, and sequence features.

Method:

Created a curses-based UI (ui_manager.py).

Enhanced direct_control.py to handle two-way communication (reading responses like position).

Created run_advanced_controller.py as the new main entry point.

Debugging:

Initially attempted to use pynput for keyboard input, which caused the application to hang on macOS due to accessibility permission requirements.

Resolution: Removed the pynput dependency and reverted to curses-based keyboard input, which is more reliable for this application.

Status: This is the current, active version of the controller.

# huenit-robot-arm

A Python project for controlling and programming the Huenit Robot Arm.

## Structure

- `huenit_robot_arm/`: Python package with main functionality.
- `tests/`: Unittests.
- `requirements.txt`: Dependencies.
- `setup.py`: Package information.

## Usage

```bash
python huenit_robot_arm/all_commands.py
```

## Vendor Robot Arm Control Module

The file `robot_control/robot.py` contains manufacturer-provided source code to control the robot arm via serial commands.  
It is integrated as a library for hardware-level communication.  
Please document any changes made to this file and keep the original logic intact unless modification is necessary for compatibility or bug fixing.
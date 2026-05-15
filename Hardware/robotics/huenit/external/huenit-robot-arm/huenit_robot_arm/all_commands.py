"""
Demonstrates all arm and suction-related commands from robot_control/robot.py.
Each command is executed once with explanatory comments.
"""

import time
from robot_control.robot import (
    pumpOn, pumpOff, pump,
    valveOn, valveOff,
    suctionOn, suctionOff,
    gripper,
    set_current_position,
    moveAngle, moveAngle_noM400,
    moveZ0_M400, moveZ0,
    freeMod, unsetFreeMod,
    getLoc, getDeg,
    suctionAngle
)

def main():
    # Set the current position of the robot arm
    print("Setting current position...")
    set_current_position()

    # Move the arm to a specific angle (example values)
    print("Moving arm to angles (30, 45, 60)...")
    moveAngle(30, 45, 60)

    # Move the arm to a specific angle without sending M400
    print("Moving arm to angles (10, 20, 30) without M400...")
    moveAngle_noM400(10, 20, 30)

    # Move Z axis to 50 with M400
    print("Moving Z axis to 50 with M400...")
    moveZ0_M400(50)

    # Move Z axis to 10 without M400
    print("Moving Z axis to 10...")
    moveZ0(10)

    # Get current location (coordinates)
    print("Getting current location...")
    loc = getLoc()
    print("Location:", loc)

    # Get current angles (degrees)
    print("Getting current angles...")
    deg = getDeg()
    print("Angles:", deg)

    # Turn suction pump on
    print("Turning suction pump on...")
    pumpOn()
    time.sleep(1)

    # Enable suction (valve off, pump on)
    print("Enabling suction...")
    suctionOn()
    time.sleep(1)

    # Disable suction (pump off, valve on/off)
    print("Disabling suction...")
    suctionOff()
    time.sleep(1)

    # Enable free movement mode
    print("Enabling free movement mode (motors off)...")
    freeMod()

    # Disable free movement mode
    print("Disabling free movement mode (motors on)...")
    unsetFreeMod()


if __name__ == "__main__":
    main()
#!/usr/bin/env python3

import rospy
from rospy.service import ServiceException
import os

# Set the ROS master URI to point to your robot's IP address
robot_ip = "192.168.86.36"
os.environ["ROS_MASTER_URI"] = f"http://{robot_ip}:11311"


def call_service(service_name, request=None):
    rospy.wait_for_service(service_name)
    try:
        service_proxy = rospy.ServiceProxy(service_name, rospy.AnyMsg)
        if request is None:
            response = service_proxy()
        else:
            response = service_proxy(request)
        return response
    except ServiceException as e:
        rospy.logerr(f"Service call failed: {e}")
        return None


def get_nav_status():
    response = call_service("/NavPathNode/nav_get_status")
    if response is not None:
        # The actual structure of the response is unknown, so we're just returning it as is
        return response
    return None


def send_patrol_command(is_from_out_start, name):
    # Create a simple dictionary to represent the request
    request = {"isFromOutStart": is_from_out_start, "name": name}
    response = call_service("/NavPathNode/nav_patrol", request)
    if response is not None:
        # The actual structure of the response is unknown, so we're just returning it as is
        return response
    return None


def scout_go_home():
    rospy.init_node("scout_go_home", anonymous=True)

    # First, get the current navigation status
    status = get_nav_status()
    rospy.loginfo(f"Current navigation status: {status}")

    # Attempt to send a patrol command
    # We're using 1 for isFromOutStart and "home" for the name, but these might need adjustment
    result = send_patrol_command(1, "home")

    if result is not None:
        rospy.loginfo(f"Patrol command result: {result}")
        rospy.loginfo("Patrol command sent. The robot should be going home now.")
    else:
        rospy.logerr("Failed to send patrol command.")

    # Check the navigation status again after sending the command
    rospy.sleep(2)  # Wait a bit for the status to potentially change
    new_status = get_nav_status()
    rospy.loginfo(f"New navigation status after sending command: {new_status}")


if __name__ == "__main__":
    try:
        scout_go_home()
    except rospy.ROSInterruptException:
        pass

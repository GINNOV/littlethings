#!/usr/bin/env python3

import rospy


class AdjustLightRequest:
    _slot_types = ["int32"]

    def __init__(self):
        self.cmd = 0


class AdjustLightResponse:
    _slot_types = []

    def __init__(self):
        pass


class AdjustLightService:
    _type = "CoreNode/AdjustLight"
    _md5sum = None  # We don't know the md5sum, but it's not crucial for this use case
    _request_class = AdjustLightRequest
    _response_class = AdjustLightResponse


class AdjustLightServiceProxy:
    def __init__(self):
        self.service_name = "/CoreNode/adjust_light"
        self.service = rospy.ServiceProxy(self.service_name, AdjustLightService)

    def call(self, cmd):
        try:
            request = AdjustLightRequest()
            request.cmd = cmd
            response = self.service(request)
            return response
        except rospy.ServiceException as e:
            rospy.logerr(f"Service call failed: {e}")
            return None


def turn_on_light(light_value):
    rospy.init_node("scout_lights", anonymous=True)

    adjust_light_service = AdjustLightServiceProxy()

    try:
        response = adjust_light_service.call(light_value)
        if response is not None:
            rospy.loginfo("Light adjustment successful")
        else:
            rospy.logwarn("Light adjustment failed")
    except rospy.ROSInterruptException:
        rospy.logerr("ROS node interrupted")


if __name__ == "__main__":
    # Call the /CoreNode/adjust_light service with a value of 1 to turn on the light
    turn_on_light(1)

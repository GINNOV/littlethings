import rospy
from rospy.msg import AnyMsg

import numpy as np
import cv2
import pygame
import os
import traceback

from modules.jpgTranscoder import JPGFrame

latest_frame = None


def color_frame_callback(msg):
    global latest_frame
    try:
        frame = JPGFrame.parse_frame(msg)
        print(f"Received frame: type={frame.type}, length={len(frame.data)} bytes")

        img = JPGFrame.process_frame(frame.data)
        if img is not None:
            print(f"Successfully decoded image. Shape: {img.shape}")
            latest_frame = img
        else:
            print("Failed to decode image")

    except Exception as e:
        print(f"Error in callback: {str(e)}")
        traceback.print_exc()


def init_ros():
    try:
        rospy.init_node("scout_controller", anonymous=True)
        sub = rospy.Subscriber(
            "/CoreNode/jpg", AnyMsg, color_frame_callback, queue_size=10
        )
        print(f"Subscribed to topic: {sub.name}")
        print(f"Number of publishers: {sub.get_num_connections()}")
    except Exception as e:
        print(f"Error initializing ROS: {str(e)}")
        traceback.print_exc()


def main():
    try:
        print("Setting ROS MASTER to:", os.environ.get("ROS_MASTER_URI", "Not set"))
        init_ros()

        pygame.init()
        screen = pygame.display.set_mode((960, 540))  # Half of 1920x1080
        clock = pygame.time.Clock()

        rate = rospy.Rate(30)  # 30 Hz
        while not rospy.is_shutdown():
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return

            if latest_frame is not None:
                rgb_frame = cv2.cvtColor(latest_frame, cv2.COLOR_BGR2RGB)
                resized_frame = cv2.resize(rgb_frame, (960, 540))
                py_image = pygame.image.frombuffer(
                    resized_frame.tobytes(), (960, 540), "RGB"
                )
                screen.blit(py_image, (0, 0))
                pygame.display.flip()

            clock.tick(30)  # Limit to 30 FPS
            rate.sleep()

    except Exception as e:
        print(f"Error in main loop: {str(e)}")
        traceback.print_exc()
    finally:
        pygame.quit()


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Unhandled exception: {str(e)}")
        traceback.print_exc()

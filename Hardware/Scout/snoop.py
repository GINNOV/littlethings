# ROS libraries
import rospy
from geometry_msgs.msg import Twist
from rospy.msg import AnyMsg

from modules.jpgTranscoder import JPGFrame

# open CV
import cv2
from cv_bridge import CvBridge

# system libraries
import pygame
import numpy as np
import time
import os
import sys
import argparse

# Constants
ROS_HOST_ADDRESS = "192.168.86.36:11311"
LOCALHOST_ADDRESS = "127.0.0.1"
WINDOW_X, WINDOW_Y = 1920, 1080
FORWARD_SPEED = 0.2
MAX_FORWARD_SPEED = 1.0
MIN_FORWARD_SPEED = 0.1

# Global variables
bridge = CvBridge()
latest_frame = None
cmd_vel_pub = None
joystick_left_x, joystick_left_y = 0, 0
joystick_right_x, joystick_right_y = 0, 0
forward_speed = FORWARD_SPEED
args = None


def parse_arguments():
    global args
    parser = argparse.ArgumentParser(description="Scout Access Controller")
    parser.add_argument("--windowX", type=int, default=1920, help="window width")
    parser.add_argument("--windowY", type=int, default=1080, help="window height")
    parser.add_argument(
        "--host", default=ROS_HOST_ADDRESS, help="ROS endpoint such as IP_ADDRESS:PORT"
    )
    parser.add_argument(
        "--localhost", default=LOCALHOST_ADDRESS, help="localhost address"
    )
    parser.add_argument(
        "--control",
        default="keyboard",
        choices=["keyboard", "joystick"],
        help="control scheme",
    )
    parser.add_argument("--verbose", action="store_true", help="verbose output")
    parser.add_argument(
        "--topics", action="store_true", help="print all available ROS topics"
    )

    args = parser.parse_args()
    print(f"Setting ROS MASTER to: http://{args.host}")
    os.environ["ROS_MASTER_URI"] = "http://" + args.host


# Set up the display
screen = pygame.display.set_mode((WINDOW_X, WINDOW_Y))
pygame.display.set_caption("🥷 Scout 🤖")

# Initialize CvBridge for converting ROS images to OpenCV format
bridge = CvBridge()

# Global variables for joystick/keyboard input
joystick_left_x, joystick_left_y = 0, 0
joystick_right_x, joystick_right_y = 0, 0
forward_speed = FORWARD_SPEED

# Publisher for robot commands
cmd_vel_pub = None

# Variable to store the latest camera frame
latest_frame = None


def grey_frame_callback(msg):
    global latest_frame
    try:
        cv_image = bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")

        # Calculate scaling factor to fit the image to the window
        scale_x = args.windowX / cv_image.shape[1]
        scale_y = args.windowY / cv_image.shape[0]
        scale = min(scale_x, scale_y)

        # Calculate new dimensions
        new_width = int(cv_image.shape[1] * scale)
        new_height = int(cv_image.shape[0] * scale)

        resized_image = cv2.resize(
            cv_image, (new_width, new_height), interpolation=cv2.INTER_AREA
        )
        frame = cv2.cvtColor(resized_image, cv2.COLOR_BGR2RGB)
        latest_frame = pygame.surfarray.make_surface(frame.swapaxes(0, 1))

        if args.verbose:
            print(
                f"Original frame: {cv_image.shape}, Resized to: {resized_image.shape}"
            )
    except Exception as e:
        rospy.logerr(f"Error processing image: {str(e)}")


def color_frame_callback(msg):
    global latest_frame
    try:
        # Parse the incoming message to extract the frame
        frame = JPGFrame.parse_frame(msg)
        # print(f"Received frame: type={frame.type}, length={len(frame.data)} bytes")

        # Process the frame data to obtain the image
        img = JPGFrame.process_frame(frame.data)
        if img is not None:
            # print(f"Successfully decoded image. Shape: {img.shape}")

            # Calculate scaling factor to fit the image to the window
            scale_x = args.windowX / img.shape[1]
            scale_y = args.windowY / img.shape[0]
            scale = min(scale_x, scale_y)

            # Calculate new dimensions
            new_width = int(img.shape[1] * scale)
            new_height = int(img.shape[0] * scale)

            # Resize the image
            resized_image = cv2.resize(
                img, (new_width, new_height), interpolation=cv2.INTER_AREA
            )

            # Convert the resized image to RGB
            frame_rgb = cv2.cvtColor(resized_image, cv2.COLOR_BGR2RGB)

            # Create a pygame surface from the frame
            latest_frame = pygame.surfarray.make_surface(frame_rgb.swapaxes(0, 1))

            if args.verbose:
                print(f"Original frame: {img.shape}, Resized to: {resized_image.shape}")
        else:
            print("Failed to decode image")

    except Exception as e:
        print(f"Error in callback: {str(e)}")


def init_ros():
    """Initialize ROS node and publishers/subscribers"""
    global cmd_vel_pub

    try:
        rospy.init_node("SPIONE_NODE", anonymous=True)
        cmd_vel_pub = rospy.Publisher("/cmd_vel", Twist, queue_size=10)
        # rospy.Subscriber("/CoreNode/grey_img", Image, grey_frame_callback)
        sub = rospy.Subscriber(
            "/CoreNode/jpg", AnyMsg, color_frame_callback, queue_size=10
        )
        print(f"Subscribed to topic: {sub.name}")
        print(f"Number of publishers: {sub.get_num_connections()}")
    except Exception as e:
        print(f"Error initializing ROS: {str(e)}")


def send_robot_command(linear_x, linear_y, angular_z):
    """Send movement command to the robot"""
    twist = Twist()
    twist.linear.x = linear_x * 0.2  # strafe left/right
    twist.linear.y = linear_y * forward_speed  # move forward/backward
    twist.angular.z = angular_z * -2.9  # rotate left/right
    cmd_vel_pub.publish(twist)


def handle_input():
    global joystick_left_x, joystick_left_y, joystick_right_x, joystick_right_y, forward_speed

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            return False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                save_screenshot()
            elif event.key == pygame.K_h:
                scout_go_home()
            elif event.key == pygame.K_9:
                turn_on_light(0)
            elif event.key == pygame.K_0:
                turn_on_light(1)

    keys = pygame.key.get_pressed()
    if keys[pygame.K_ESCAPE]:
        return False

    joystick_left_x = keys[pygame.K_d] - keys[pygame.K_a]
    joystick_left_y = (
        keys[pygame.K_s] - keys[pygame.K_w]
    )  # Inverted for correct direction
    joystick_right_x = keys[pygame.K_e] - keys[pygame.K_q]

    if keys[pygame.K_p] and forward_speed < MAX_FORWARD_SPEED:
        forward_speed += 0.1
    if keys[pygame.K_o] and forward_speed > MIN_FORWARD_SPEED:
        forward_speed -= 0.1

    # Ensure joystick values are within -1 to 1 range
    joystick_left_x = max(-1, min(1, joystick_left_x))
    joystick_left_y = max(-1, min(1, joystick_left_y))
    joystick_right_x = max(-1, min(1, joystick_right_x))

    send_robot_command(joystick_right_x, joystick_left_y, joystick_left_x)
    return True


def save_screenshot():
    """Save the current frame as a screenshot"""
    if latest_frame:
        filename = f"scout-{time.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"
        pygame.image.save(latest_frame, filename)
        print(f"Screenshot saved: {filename}")


def scout_go_home():
    """Command the Scout to return to its home position"""
    # Implement the go home functionality
    print("Scout returning home")


def turn_on_light(light_id):
    """Turn on the specified light"""
    # Implement the light control functionality
    print(f"Turning on light {light_id}")


def main_loop():
    """Main game loop"""
    clock = pygame.time.Clock()
    running = True
    font = pygame.font.Font(None, 36)

    while running and not rospy.is_shutdown():
        running = handle_input()

        screen.fill((0, 0, 0))  # Clear the screen

        if latest_frame:
            # Calculate position to center the frame
            pos_x = (args.windowX - latest_frame.get_width()) // 2
            pos_y = (args.windowY - latest_frame.get_height()) // 2
            screen.blit(latest_frame, (pos_x, pos_y))

        # Display HUD
        hud_text = f"lX: {joystick_left_x:.2f} lY: {joystick_left_y:.2f} rX: {joystick_right_x:.2f} rY: {joystick_right_y:.2f}"
        speed_text = f"Speed: {forward_speed:.2f}"

        text_surface = font.render(hud_text, True, (255, 255, 255))
        speed_surface = font.render(speed_text, True, (255, 255, 255))

        # Position the HUD text at the top left
        screen.blit(text_surface, (10, 10))
        # Position the speed text below the HUD text
        screen.blit(speed_surface, (10, 50))

        pygame.display.flip()
        clock.tick(60)

    pygame.quit()


if __name__ == "__main__":
    parse_arguments()
    pygame.init()
    pygame.joystick.init()
    screen = pygame.display.set_mode((args.windowX, args.windowY))
    pygame.display.set_caption("🥷 SP1ONE 🤖")

    try:
        init_ros()
        main_loop()
    except rospy.ROSInterruptException:
        pass

import rospy
from geometry_msgs.msg import Twist
from sensor_msgs.msg import Image

import cv2
from cv_bridge import CvBridge
import numpy as np

from flask import (
    Flask,
    request,
    jsonify,
    send_from_directory,
    render_template,
    redirect,
    url_for,
    session,
)
import time
import os
import logging
from logging.handlers import RotatingFileHandler
from dotenv import load_dotenv


# Constants
ROS_HOST_ADDRESS = "192.168.86.36:11311"
LOCALHOST_ADDRESS = "127.0.0.1"
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

# Load environment variables
load_dotenv()

# Determine the environment
ENV = os.getenv("FLASK_ENV", "development")
app = Flask(__name__)
app.secret_key = "spione_secret_key"  # Set a secret key for the session

# Configure logging
log_file_path = "./logs/monitor.log"
os.makedirs(os.path.dirname(log_file_path), exist_ok=True)
handler = RotatingFileHandler(log_file_path, maxBytes=10000, backupCount=1)
handler.setLevel(logging.INFO)
formatter = logging.Formatter(
    "%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]"
)
handler.setFormatter(formatter)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)


def get_local_ip():
    import socket

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = "127.0.0.1"
    finally:
        s.close()
    return IP


def configNetwork():
    os.environ["ROS_MASTER_URI"] = f"http://linaro-alip:11311"
    os.environ["ROS_IP"] = get_local_ip()


def init_ros():
    global cmd_vel_pub
    print("Initializing ROS...")
    rospy.init_node("scout_controller", anonymous=True)
    print("Node initialized. Creating publisher...")

    cmd_vel_pub = rospy.Publisher("cmd_vel", Twist, queue_size=10)
    rospy.Subscriber("/CoreNode/grey_img", Image, image_callback)
    rospy.sleep(1)  # Give ROS time to initialize

    if cmd_vel_pub.get_num_connections() == 0:
        print("Publisher created but has no connections.")
    else:
        print("Publisher created and connected.")
    print(f"cmd_vel_pub: {cmd_vel_pub}")


def image_callback(data):
    global latest_frame
    cv_image = bridge.imgmsg_to_cv2(data, "bgr8")
    resized_image = cv2.resize(cv_image, (320, 240), interpolation=cv2.INTER_AREA)
    frame = cv2.cvtColor(resized_image, cv2.COLOR_BGR2RGB)
    latest_frame = frame
    # Print the shape of the latest frame to confirm it contains data
    # print(f"Received new frame with shape: {latest_frame.shape}")


def move_robot(
    linear_x=0.0,
    linear_y=0.0,
    linear_z=0.0,
    angular_x=0.0,
    angular_y=0.0,
    angular_z=0.0,
):
    global cmd_vel_pub
    if cmd_vel_pub is None:
        return {"success": False, "message": "ROS publisher not initialized"}

    print(f"Publishing Twist message: linear_x={linear_x}, angular_z={angular_z}")
    twist = Twist()
    twist.linear.x = linear_x
    twist.linear.y = linear_y
    twist.linear.z = linear_z
    twist.angular.x = angular_x
    twist.angular.y = angular_y
    twist.angular.z = angular_z
    cmd_vel_pub.publish(twist)
    return {"success": True}


@app.route("/move", methods=["POST"])
def move():
    data = request.json
    linear_x = data.get("linear_x", 0.0)
    linear_y = data.get("linear_y", 0.0)
    linear_z = data.get("linear_z", 0.0)
    angular_x = data.get("angular_x", 0.0)
    angular_y = data.get("angular_y", 0.0)
    angular_z = data.get("angular_z", 0.0)
    result = move_robot(linear_x, linear_y, linear_z, angular_x, angular_y, angular_z)
    return jsonify(result)


@app.route("/screenshot", methods=["GET"])
def screenshot():
    global latest_frame
    initial_frame = np.copy(latest_frame) if latest_frame is not None else None
    timeout = 5  # seconds
    start_time = time.time()

    # print(f"Initial frame: {initial_frame}")

    while (
        initial_frame is None or np.array_equal(latest_frame, initial_frame)
    ) and time.time() - start_time < timeout:
        rospy.sleep(0.1)  # Wait for a new frame

    print(f"Latest frame: {latest_frame}")

    if latest_frame is not None and not np.array_equal(latest_frame, initial_frame):
        # Determine the directory of the current script
        script_dir = os.path.dirname(os.path.abspath(__file__))
        static_dir = os.path.join(script_dir, "static")

        # Ensure the static directory exists
        if not os.path.exists(static_dir):
            os.makedirs(static_dir)

        # Print the current working directory
        print(f"Script directory: {script_dir}")

        filename = os.path.join(static_dir, "last_camera_shot.jpg")
        cv2.imwrite(filename, latest_frame)
        print(f"Saved new frame to {filename}")

        # Verify if the file exists
        if os.path.exists(filename):
            print(f"File {filename} exists after saving.")
        else:
            print(f"File {filename} does not exist after saving.")

        session["screenshot_taken"] = True
        return jsonify(
            success=True, message="Screenshot taken", filename="last_camera_shot.jpg"
        )
    else:
        print("No new frame available")
        return jsonify(success=False, message="No new frame available")


@app.route("/image")
def image():
    # Check if the screenshot button has been clicked
    if "screenshot_taken" in session and session["screenshot_taken"]:
        return send_from_directory("static", "last_camera_shot.jpg")
    else:
        return send_from_directory("images", "surprise.jpg")


@app.route("/images/<path:filename>")
def static_images(filename):
    return send_from_directory("images", filename)


@app.route("/")
def index():
    app.logger.info("Received index request")
    return render_template("index.html")


@app.route("/shutdown", methods=["POST"])
def shutdown():
    rospy.signal_shutdown("Server shutting down")
    return "Server shutting down..."


if __name__ == "__main__":
    configNetwork()
    try:
        init_ros()
        if ENV == "development":
            app.run(host="0.0.0.0", port=5001, debug=True, use_reloader=True)
        else:
            app.run(host="0.0.0.0", port=5001)
    except rospy.ROSInterruptException:
        pass

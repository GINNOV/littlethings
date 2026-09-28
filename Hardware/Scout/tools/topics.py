import rospy
from rostopic import get_topic_list
from tabulate import tabulate


def print_ros_topics():
    print("Available ROS topics:")
    try:
        topics = rospy.get_published_topics()
        formatted_topics = [[topic, topic_type] for topic, topic_type in topics]
        print(tabulate(formatted_topics, headers=["Topic", "Type"], tablefmt="grid"))
    except Exception as e:
        print(f"Error getting topic list: {e}")

    # Print ROS Master URI information
    try:
        print(f"ROS Master URI: {rospy.get_master().uri}")
    except Exception as e:
        print(f"Error getting ROS Master URI: {e}")

    print(
        f"ROS_MASTER_URI environment variable: {os.environ.get('ROS_MASTER_URI', 'Not set')}"
    )

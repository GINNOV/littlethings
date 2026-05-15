import unittest
from huenit_robot_arm.all_commands import main

class TestMain(unittest.TestCase):
    def test_main_runs(self):
        # Test if the main function runs without error
        try:
            main()
        except Exception as e:
            self.fail(f"main() raised {e}")

if __name__ == "__main__":
    unittest.main()
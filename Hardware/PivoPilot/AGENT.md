
# PivoPilot AGENT.md

Project: Wearable-controlled camera tracking for Pivo motorized stands.

Sensors:
- AirPods head tracking (CMHeadphoneMotionManager)
- Apple Watch motion streaming (CoreMotion + WatchConnectivity)
- iPhone IMU fallback

Pipeline:
sensor quaternion → delta vs reference → yaw extraction → smoothing → motor command → BLE → Pivo

Loop frequency: 30Hz
Target latency: <120ms

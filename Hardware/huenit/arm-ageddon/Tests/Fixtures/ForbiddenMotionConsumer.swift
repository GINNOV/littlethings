import ArmageddonCore
let raw = SerialPort()
raw.send("G28")
let permit = MotionPermit()

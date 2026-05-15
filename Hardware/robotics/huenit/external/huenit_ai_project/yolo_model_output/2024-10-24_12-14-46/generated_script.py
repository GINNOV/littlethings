
import ai
import time
import KPU as kpu
import sensor, lcd

# Initialize LCD and camera sensor
lcd.init()
sensor.reset()
sensor.set_pixformat(sensor.RGB565)
sensor.set_framesize(sensor.QVGA)
sensor.set_windowing((224, 224))
sensor.set_vflip(1)
sensor.run(1)

classes = ["Human_face", "Mobile_phone", "Pen", "Computer_mouse"]

task = kpu.load(0x500000)

anchors = (0.9174, 0.86123, 0.12227, 0.1411, 0.42561, 0.86039, 0.82585, 0.38838, 0.32382, 0.3719)

a = kpu.init_yolo2(task, 0.5, 0.5, 5, anchors)
a = kpu.set_outputs(task, 0, 7, 7, 45)

while True:
    img = sensor.snapshot()
    a = img.pix_to_ai()
    code = kpu.run_yolo2(task, img)

    if code:
        for i in code:
            x, y, w, h = i.rect()
            # manual modifciation for width, height
            new_w = w + 40
            new_h = h + 40
            new_x = x - (new_w - w) // 2
            new_y = y - (new_h - h) // 2
            a = img.draw_rectangle(new_x, new_y, new_w, new_h, color=(0, 255, 0))
            a = img.draw_string(new_x, new_y, classes[i.classid()], color=(255, 0, 0), scale=1.5)
        lcd.display(img)
    else:
        lcd.display(img)

a = kpu.deinit(task)
    
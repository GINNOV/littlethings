def generate_script(target_path, classes, anchors, obj_thresh, iou_thresh, set_outputs):
    classes_str = ", ".join([f'"{cls}"' for cls in classes])
    anchors_str = ", ".join(map(str, anchors))
    set_outputs_str = ", ".join(map(str, set_outputs))
    
    script = f"""
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

classes = [{classes_str}]

task = kpu.load(0x500000)

anchors = ({anchors_str})

a = kpu.init_yolo2(task, {obj_thresh}, {iou_thresh}, 5, anchors)
a = kpu.set_outputs(task, {set_outputs_str})

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
    """
    
    with open(target_path + "/generated_script.py", "w") as file:
        file.write(script)
    
    print("Script generated successfully as 'generated_script.py'.")


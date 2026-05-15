def generate_script(target_path, classes, anchors, obj_thresh, iou_thresh, set_outputs):
    classes_str = ", ".join([f'"{cls}"' for cls in classes])
    anchors_str = ", ".join(map(str, anchors))
    set_outputs_str = ", ".join(map(str, set_outputs))
    
    script = f"""
import sensor, image, time, lcd
from maix import KPU
import gc

# Initialize LCD and camera sensor
lcd.init() 
sensor.reset() 
sensor.set_pixformat(sensor.RGB565)  
sensor.set_framesize(sensor.QVGA)    
sensor.skip_frames(time=1000)        
clock = time.clock()               
sensor.set_vflip(1)  
od_img = image.Image(size=(224,224))  

classes = [{classes_str}]

kpu = KPU() 
print("ready load model")  

kpu.load_kmodel(0x700000, 892200)  
anchors = ({anchors_str})
anchors = tuple(anchor * 6.0 for anchor in anchors)

kpu.init_yolo2(anchors, anchor_num={int(len(anchors)/2)}, img_w=224, img_h=224, net_w=224, net_h=224, layer_w={set_outputs_str[3]}, 
               layer_h={set_outputs_str[6]}, threshold={obj_thresh}, nms_value={iou_thresh}, classes={int(len(classes))})  


while True:
    clock.tick()   
    img = sensor.snapshot()   
    a = od_img.draw_image(img, 0, 0)  
    od_img.pix_to_ai()  
    kpu.run_with_output(od_img)  
    dect = kpu.regionlayer_yolo2() 
    fps = clock.fps()   
    try:
        if len(dect) > 0:   
            print("dect:", dect, "\\n")  
            for l in dect:
                a = img.draw_rectangle(l[0], l[1], l[2], l[3], color=(0, 255, 0))
                a = img.draw_string(l[0], l[1], classes[l[4]], color=(255, 0, 0), scale=1.0)
        else:   
            pass
    except Exception as e:
        print("error", e, dect)   

    img.draw_string(0, 0, "%2.1f fps" % fps, color=(0, 60, 128), scale=2.0)   
    lcd.display(img)  
    gc.collect() 
    """
    
    with open(target_path + "/generate_detector_script_canMV.py", "w") as file:
        file.write(script)
    
    print("Script generated successfully as 'generate_detector_script_canMV.py'.")


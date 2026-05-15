
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

classes = ["Human_face", "Mobile_phone", "Pen", "Computer_mouse"]

kpu = KPU() 
print("ready load model")  

kpu.load_kmodel(0x700000, 892200)  
anchors = (1.889, 2.5245, 2.9465, 3.94056, 3.99987, 5.3658, 5.155437, 6.92275, 6.718375, 9.01025)
anchors = tuple(anchor * 6.0 for anchor in anchors)

kpu.init_yolo2(anchors, anchor_num=5, img_w=224, img_h=224, net_w=224, net_h=224, layer_w=7, 
               layer_h=7, threshold=0.5, nms_value=0.5, classes=4)  


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
            print("dect:", dect, "\n")  
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
    
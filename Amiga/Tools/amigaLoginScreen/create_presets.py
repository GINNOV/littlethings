#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont

def render_kickstart_20():
    # Resolution 640x400 scaled 2x -> 1280x800
    w, h = 1280, 800
    img = Image.new("RGB", (w, h), (85, 60, 130)) # Amiga 2.0 Purple #553C82
    draw = ImageDraw.Draw(img)
    
    # Draw Amiga Floppy Drive Housing
    drive_w = 600
    drive_h = 320
    drive_x = (w - drive_w) // 2
    drive_y = 380
    
    # Drive bezel (Beige / Platinum)
    draw.rectangle([drive_x, drive_y, drive_x + drive_w, drive_y + drive_h], fill=(210, 205, 195), outline=(160, 155, 145), width=6)
    
    # Drive slot
    slot_w = 460
    slot_h = 40
    slot_x = (w - slot_w) // 2
    slot_y = drive_y + 80
    draw.rectangle([slot_x, slot_y, slot_x + slot_w, slot_y + slot_h], fill=(30, 30, 35), outline=(120, 115, 110), width=4)
    
    # Eject button
    eject_x = slot_x + slot_w - 60
    eject_y = slot_y + slot_h + 30
    draw.rectangle([eject_x, eject_y, eject_x + 60, eject_y + 24], fill=(180, 175, 165), outline=(130, 125, 115), width=3)
    
    # Drive LED (green)
    led_x = slot_x
    led_y = eject_y + 4
    draw.rectangle([led_x, led_y, led_x + 36, led_y + 16], fill=(0, 220, 50), outline=(0, 140, 30), width=2)
    
    # Floppy Disk inserting into slot
    disk_w = 340
    disk_h = 320
    disk_x = (w - disk_w) // 2
    disk_y = 160
    
    # Disk body (Dark navy / charcoal)
    draw.rectangle([disk_x, disk_y, disk_x + disk_w, disk_y + disk_h], fill=(35, 40, 50), outline=(20, 25, 30), width=6)
    
    # Metal shutter (bottom going into drive)
    shutter_w = 200
    shutter_h = 130
    shutter_x = (w - shutter_w) // 2
    shutter_y = disk_y + disk_h - shutter_h
    draw.rectangle([shutter_x, shutter_y, shutter_x + shutter_w, shutter_y + shutter_h], fill=(190, 195, 205), outline=(140, 145, 155), width=4)
    
    # Shutter hole
    draw.rectangle([shutter_x + 40, shutter_y + 20, shutter_x + 90, shutter_y + 90], fill=(35, 40, 50))
    
    # White Disk Label
    label_w = 280
    label_h = 140
    label_x = (w - label_w) // 2
    label_y = disk_y + 30
    draw.rectangle([label_x, label_y, label_x + label_w, label_y + label_h], fill=(245, 245, 245), outline=(210, 210, 210), width=3)
    
    # Rainbow Stripe on label
    stripes = [(255, 0, 0), (255, 160, 0), (255, 230, 0), (0, 180, 50), (0, 120, 255)]
    for i, col in enumerate(stripes):
        sy = label_y + 16 + i * 8
        draw.rectangle([label_x + 14, sy, label_x + label_w - 14, sy + 8], fill=col)
        
    # Text placeholder / lines on label
    draw.rectangle([label_x + 20, label_y + 70, label_x + label_w - 20, label_y + 80], fill=(50, 50, 50))
    draw.rectangle([label_x + 20, label_y + 92, label_x + 180, label_y + 100], fill=(120, 120, 120))
    
    # Top Text Banner
    # Commodore Checkmark / Rainbow Logo
    logo_y = 60
    # Amiga Release 2.0 text banner
    draw.rectangle([w//2 - 260, logo_y, w//2 + 260, logo_y + 50], fill=(245, 245, 245), outline=(20, 20, 20), width=4)
    
    # Rainbow checkmark on top left
    for i, col in enumerate(stripes):
        draw.rectangle([w//2 - 240 + i * 8, logo_y + 10, w//2 - 232 + i * 8, logo_y + 40], fill=col)
        
    # Text block simulation for Amiga Release 2.0
    draw.rectangle([w//2 - 180, logo_y + 16, w//2 + 240, logo_y + 34], fill=(30, 30, 30))
    
    return img

def render_kickstart_31():
    # Resolution 640x400 scaled 2x -> 1280x800
    w, h = 1280, 800
    img = Image.new("RGB", (w, h), (0, 85, 140)) # Amiga 3.1 Deep Blue/Teal #00558C
    draw = ImageDraw.Draw(img)
    
    # Drive housing
    drive_w = 620
    drive_h = 330
    drive_x = (w - drive_w) // 2
    drive_y = 370
    
    # Drive bezel (Amiga 1200 / 4000 sleek styling)
    draw.rectangle([drive_x, drive_y, drive_x + drive_w, drive_y + drive_h], fill=(225, 220, 210), outline=(170, 165, 155), width=6)
    
    # Drive slot
    slot_w = 480
    slot_h = 42
    slot_x = (w - slot_w) // 2
    slot_y = drive_y + 75
    draw.rectangle([slot_x, slot_y, slot_x + slot_w, slot_y + slot_h], fill=(25, 25, 30), outline=(130, 125, 120), width=4)
    
    # Eject button
    eject_x = slot_x + slot_w - 65
    eject_y = slot_y + slot_h + 32
    draw.rectangle([eject_x, eject_y, eject_x + 65, eject_y + 26], fill=(190, 185, 175), outline=(140, 135, 125), width=3)
    
    # Power/Drive LED (Orange/Green dual)
    led_x = slot_x
    led_y = eject_y + 4
    draw.rectangle([led_x, led_y, led_x + 24, led_y + 18], fill=(255, 160, 0), outline=(180, 100, 0), width=2)
    draw.rectangle([led_x + 30, led_y, led_x + 54, led_y + 18], fill=(0, 230, 60), outline=(0, 150, 40), width=2)
    
    # Floppy Disk inserting
    disk_w = 350
    disk_h = 320
    disk_x = (w - disk_w) // 2
    disk_y = 150
    
    # High-density Amiga Disk Body
    draw.rectangle([disk_x, disk_y, disk_x + disk_w, disk_y + disk_h], fill=(30, 32, 40), outline=(15, 18, 22), width=6)
    
    # Metal shutter
    shutter_w = 210
    shutter_h = 135
    shutter_x = (w - shutter_w) // 2
    shutter_y = disk_y + disk_h - shutter_h
    draw.rectangle([shutter_x, shutter_y, shutter_x + shutter_w, shutter_y + shutter_h], fill=(200, 205, 215), outline=(150, 155, 165), width=4)
    draw.rectangle([shutter_x + 45, shutter_y + 22, shutter_x + 95, shutter_y + 92], fill=(30, 32, 40))
    
    # White Disk Label
    label_w = 290
    label_h = 145
    label_x = (w - label_w) // 2
    label_y = disk_y + 28
    draw.rectangle([label_x, label_y, label_x + label_w, label_y + label_h], fill=(248, 248, 248), outline=(215, 215, 215), width=3)
    
    # Rainbow Stripe on label
    stripes = [(255, 0, 0), (255, 150, 0), (255, 225, 0), (0, 190, 50), (0, 130, 255)]
    for i, col in enumerate(stripes):
        sy = label_y + 18 + i * 8
        draw.rectangle([label_x + 16, sy, label_x + label_w - 16, sy + 8], fill=col)
        
    # Text lines on label
    draw.rectangle([label_x + 22, label_y + 74, label_x + label_w - 22, label_y + 86], fill=(45, 45, 45))
    draw.rectangle([label_x + 22, label_y + 98, label_x + 190, label_y + 108], fill=(130, 130, 130))
    
    # Top Text Banner for 3.1
    logo_y = 55
    draw.rectangle([w//2 - 280, logo_y, w//2 + 280, logo_y + 54], fill=(248, 248, 248), outline=(20, 20, 20), width=4)
    
    for i, col in enumerate(stripes):
        draw.rectangle([w//2 - 255 + i * 8, logo_y + 12, w//2 - 247 + i * 8, logo_y + 42], fill=col)
        
    draw.rectangle([w//2 - 190, logo_y + 18, w//2 + 255, logo_y + 38], fill=(30, 30, 30))
    
    return img

def main():
    presets_dir = "/Volumes/AIWork/code/littlethings/Amiga/Tools/amigaLoginScreen/Presets"
    os.makedirs(presets_dir, exist_ok=True)
    
    img20 = render_kickstart_20()
    img20.save(os.path.join(presets_dir, "kickstart20.png"), "PNG")
    print("Saved kickstart20.png")
    
    img31 = render_kickstart_31()
    img31.save(os.path.join(presets_dir, "kickstart31.png"), "PNG")
    print("Saved kickstart31.png")

if __name__ == "__main__":
    main()

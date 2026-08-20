#!/usr/bin/env python3
import os
import struct
import io
from PIL import Image, ImageDraw

def create_amiga_icon(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    s = size / 1024.0
    
    # Background squircle / rounded rect with Amiga Blue
    bg_margin = int(48 * s)
    radius = int(220 * s)
    draw.rounded_rectangle(
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin],
        radius=radius,
        fill=(0, 85, 170, 255), # Amiga Blue
        outline=(255, 255, 255, 180),
        width=int(12 * s)
    )
    
    # Floppy Disk Body
    disk_left = int(200 * s)
    disk_top = int(180 * s)
    disk_right = int(824 * s)
    disk_bottom = int(840 * s)
    disk_radius = int(32 * s)
    
    # Dark Amiga floppy body (dark charcoal/navy)
    draw.rounded_rectangle(
        [disk_left, disk_top, disk_right, disk_bottom],
        radius=disk_radius,
        fill=(30, 35, 45, 255),
        outline=(15, 18, 24, 255),
        width=int(8 * s)
    )
    
    # Shutter (top metal slider)
    shutter_left = int(320 * s)
    shutter_top = int(180 * s)
    shutter_right = int(704 * s)
    shutter_bottom = int(420 * s)
    draw.rounded_rectangle(
        [shutter_left, shutter_top, shutter_right, shutter_bottom],
        radius=int(16 * s),
        fill=(180, 185, 195, 255),
        outline=(120, 125, 135, 255),
        width=int(6 * s)
    )
    
    # Shutter slot
    slot_left = int(370 * s)
    slot_top = int(240 * s)
    slot_right = int(460 * s)
    slot_bottom = int(360 * s)
    draw.rounded_rectangle(
        [slot_left, slot_top, slot_right, slot_bottom],
        radius=int(8 * s),
        fill=(30, 35, 45, 255)
    )
    
    # White Floppy Label
    label_left = int(260 * s)
    label_top = int(470 * s)
    label_right = int(764 * s)
    label_bottom = int(780 * s)
    draw.rounded_rectangle(
        [label_left, label_top, label_right, label_bottom],
        radius=int(16 * s),
        fill=(245, 245, 245, 255),
        outline=(200, 200, 200, 255),
        width=int(4 * s)
    )
    
    # Top rainbow stripe on floppy label (Amiga classic colors)
    stripe_height = max(1, int(14 * s))
    colors = [
        (255, 0, 0, 255),    # Red
        (255, 165, 0, 255),  # Orange
        (255, 255, 0, 255),  # Yellow
        (0, 180, 0, 255),    # Green
        (0, 100, 255, 255)   # Blue
    ]
    for i, c in enumerate(colors):
        y1 = label_top + int(16 * s) + i * stripe_height
        y2 = y1 + stripe_height
        draw.rectangle([label_left + int(20 * s), y1, label_right - int(20 * s), y2], fill=c)
        
    # Text lines on label
    text_y = label_top + int(110 * s)
    draw.rectangle([label_left + int(30 * s), text_y, label_right - int(30 * s), text_y + max(1, int(12 * s))], fill=(40, 40, 40, 255))
    text_y2 = text_y + int(30 * s)
    draw.rectangle([label_left + int(30 * s), text_y2, label_left + int(320 * s), text_y2 + max(1, int(10 * s))], fill=(120, 120, 120, 255))
    
    return img

def main():
    icon_entries = [
        (b'icp4', 16),
        (b'icp5', 32),
        (b'icp6', 64),
        (b'ic07', 128),
        (b'ic08', 256),
        (b'ic09', 512),
        (b'ic10', 1024),
    ]
    
    body = bytearray()
    
    for tag, dim in icon_entries:
        img = create_amiga_icon(dim)
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        png_data = buf.getvalue()
        
        chunk_len = 8 + len(png_data)
        body += tag
        body += struct.pack(">I", chunk_len)
        body += png_data
        
    total_len = 8 + len(body)
    header = b'icns' + struct.pack(">I", total_len)
    
    with open("AppIcon.icns", "wb") as f:
        f.write(header + body)
        
    print(f"Successfully generated pure-Python AppIcon.icns ({len(header + body)} bytes)")

if __name__ == "__main__":
    main()

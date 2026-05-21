#!/usr/bin/env python

import os
import struct
import argparse
from PIL import Image

# Standard Amiga icon palettes
PALETTES = {
    '1.x': [
        (0x55, 0xAA, 0xFF),   # color 0 - light blue
        (0xFF, 0xFF, 0xFF),   # color 1 - white
        (0x00, 0x00, 0x00),   # color 2 - black
        (0xFF, 0x88, 0x00)    # color 3 - orange
    ],
    '2.x': [
        (0x95, 0x95, 0x95),   # color 0 - gray
        (0x00, 0x00, 0x00),   # color 1 - black
        (0xFF, 0xFF, 0xFF),   # color 2 - white
        (0x3B, 0x67, 0xA2)    # color 3 - blue
    ]
}

def closest_color(pixel, palette):
    """Find the closest color in the palette."""
    return min(range(len(palette)), 
               key=lambda i: sum((a-b)**2 for a, b in zip(pixel[:3], palette[i])))

def convert_to_bitplanes(image, palette):
    """Convert PIL Image to Amiga bitplane format."""
    width, height = image.width, image.height
    padded_width = ((width + 15) >> 4) << 4  # Pad to 16-bit word boundary
    bitplanes = []

    for plane in range(2):  # 2 bitplanes = 4 colors
        plane_data = bytearray(padded_width * height // 8)
        for y in range(height):
            for x in range(width):
                pixel = image.getpixel((x, y))
                color_index = closest_color(pixel, palette)
                
                # Check if this color's bit is set in this bitplane
                if color_index & (1 << plane):
                    byte_index = (y * padded_width + x) // 8
                    bit_offset = 7 - (x % 8)
                    plane_data[byte_index] |= (1 << bit_offset)
        
        bitplanes.append(plane_data)
    
    return padded_width, bitplanes

def create_amiga_icon(input_image_path, icon_type=3, icon_width=48, icon_height=48, output_path=None, palette_version=2):
    """Create an Amiga Workbench icon from an input image."""
    # Open input image and resize/convert
    img = Image.open(input_image_path).convert('RGB')
    
    # Resize image to specified icon size
    img = img.resize((icon_width, icon_height), Image.LANCZOS)

    # Select palette based on version
    palette_key = f'{palette_version}.x'
    if palette_key not in PALETTES:
        raise ValueError(f"Invalid palette version. Choose 1 or 2.")
    palette = PALETTES[palette_key]

    # Convert image to bitplanes
    padded_width, bitplanes = convert_to_bitplanes(img, palette)

    # Prepare icon file path
    if output_path is None:
        # Default behavior: base name of input image with .info extension
        icon_path = os.path.splitext(input_image_path)[0] + '.info'
    else:
        # Use specified output path
        icon_path = output_path

    # Create icon file
    with open(icon_path, 'wb') as f:
        # DiskObject structure
        # Magic number and version
        f.write(struct.pack('>H', 0xE310))  # do_Magic
        f.write(struct.pack('>H', 1))       # do_Version

        # Gadget details
        f.write(struct.pack('>I', 0))       # do_Gadget.NextGadget (unused)
        f.write(struct.pack('>h', 0))       # do_Gadget.LeftEdge
        f.write(struct.pack('>h', 0))       # do_Gadget.TopEdge
        f.write(struct.pack('>H', icon_width))   # do_Gadget.Width
        f.write(struct.pack('>H', icon_height))  # do_Gadget.Height
        f.write(struct.pack('>H', 5))       # do_Gadget.Flags
        f.write(struct.pack('>H', 3))       # do_Gadget.Activation
        f.write(struct.pack('>H', 1))       # do_Gadget.GadgetType
        f.write(struct.pack('>I', 1))       # do_Gadget.GadgetRender (non-zero)
        f.write(struct.pack('>I', 0))       # do_Gadget.SelectRender
        f.write(struct.pack('>I', 0))       # do_Gadget.GadgetText
        f.write(struct.pack('>I', 0))       # do_Gadget.MutualExclude
        f.write(struct.pack('>I', 0))       # do_Gadget.SpecialInfo
        f.write(struct.pack('>H', 0))       # do_Gadget.GadgetID
        f.write(struct.pack('>I', 1))       # do_Gadget.UserData (OS 2.x revision)

        # Icon type
        f.write(struct.pack('>B', icon_type))
        f.write(b'\x00')  # padding

        # No default tool or tooltypes
        f.write(struct.pack('>I', 0))       # do_DefaultTool
        f.write(struct.pack('>I', 0))       # do_ToolTypes

        # Icon position
        f.write(struct.pack('>i', 0))       # do_CurrentX
        f.write(struct.pack('>i', 0))       # do_CurrentY

        # No DrawerData
        f.write(struct.pack('>I', 0))       # do_DrawerData

        # No ToolWindow
        f.write(struct.pack('>I', 0))       # do_ToolWindow

        # Default stack size
        f.write(struct.pack('>I', 4096))    # do_StackSize

        # Image structure for normal state
        f.write(struct.pack('>h', 0))       # LeftEdge
        f.write(struct.pack('>h', 0))       # TopEdge
        f.write(struct.pack('>H', icon_width))   # Width
        f.write(struct.pack('>H', icon_height))  # Height
        f.write(struct.pack('>H', 2))       # Depth (2 bitplanes)
        f.write(struct.pack('>I', 1))       # ImageData presence flag
        f.write(struct.pack('>B', 0b11))    # PlanePick
        f.write(struct.pack('>B', 0))       # PlaneOnOff
        f.write(struct.pack('>I', 0))       # NextImage

        # Write bitplane data
        for bitplane in bitplanes:
            f.write(bitplane)

    print(f"Amiga Workbench icon created at: {icon_path}")

def main():
    parser = argparse.ArgumentParser(description='Convert image to Amiga Workbench icon')
    parser.add_argument('input_image', help='Path to input image file')
    
    # Make icon type optional with default of 3 (Tool)
    parser.add_argument('--type', type=int, choices=range(1, 9), default=3, 
                        help='Icon type (1: Disk, 2: Drawer, 3: Tool, 4: Project, 5: Trashcan, 6: Device, 7: Kickstart ROM, 8: Appicon, default: 3)')
    
    # Add configurable icon size arguments with defaults
    parser.add_argument('--width', type=int, default=48, 
                        help='Icon width in pixels (default: 48)')
    parser.add_argument('--height', type=int, default=48, 
                        help='Icon height in pixels (default: 48)')
    
    # Add optional output path argument
    parser.add_argument('--output', type=str, 
                        help='Optional output path for the .info file')
    
    # Add optional palette version argument
    parser.add_argument('--palette', type=int, choices=[1, 2], default=2, 
                        help='Palette version (1 for 1.x, 2 for 2.x, default: 2)')
    
    args = parser.parse_args()
    
    create_amiga_icon(
        args.input_image, 
        args.type, 
        args.width, 
        args.height, 
        args.output,
        args.palette
    )

if __name__ == '__main__':
    main()

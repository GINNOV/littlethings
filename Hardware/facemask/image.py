import os
import logging
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from Crypto.Cipher import AES
import binascii

logger = logging.getLogger(__name__)

def get_text_image(text):
    # Find the font file
    font_path = "./NotoSans-Regular.ttf"  # Default path for macOS
    if not os.path.exists(font_path):
        font_path = "/System/Library/Fonts/Supplemental/Arial.ttf"  # Default path for many Linux distributions
    if not os.path.exists(font_path):
        raise FileNotFoundError("Arial.ttf or DejaVuSans.ttf not found. Please specify the correct font path.")

    # Load the font
    font_size = 14
    font = ImageFont.truetype(font_path, font_size)

    # Calculate text size
    dummy_img = Image.new('RGB', (1, 1))
    dummy_draw = ImageDraw.Draw(dummy_img)
    bbox = dummy_draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Create the image
    img = Image.new('L', (text_width, 16), color=255)
    draw = ImageDraw.Draw(img)

    # Draw the text
    draw.text((0, 0), text, font=font, fill=0)

    # Save test images
    img.save("test.png")

    # Convert to binary map
    binary_map = np.array(img) < 128
    binary_map = binary_map.astype(np.uint8)

    # Create gray image
    gray_img = Image.fromarray((binary_map * 255).astype(np.uint8), 'L')
    gray_img.save("gray.png")

    logger.info(f"Text pixel len: {text_width}")
    logger.debug(f"Binary map shape: {binary_map.shape}")

    return binary_map.T.tolist()  # Transpose to match Go's column-major order

def encode_bitmap_for_mask(bitmap):
    results = bytearray()
    for column in bitmap:
        if len(column) != 16:
            logger.error(f"Column {len(results)} wrong len {len(column)}")
        
        val = 0
        for j, pixel in enumerate(column):
            if pixel == 1:
                val |= 1 << (7 - (j % 8)) << (8 * (j // 8))
        
        results.extend(val.to_bytes(2, 'little'))
    
    return results

def encode_color_array_for_mask(columns):
    return b'\xFF\xFF\xFF' * columns

# Encryption functions (unchanged)

def encrypt_aes_128_hex(hexstring):
    data = binascii.unhexlify(hexstring)
    return encrypt_aes_128(data)

def encrypt_aes_128(data):
    block_size = 16
    if len(data) != block_size:
        raise ValueError("Data length must be 16 bytes")

    key = binascii.unhexlify("32672f7974ad43451d9c6c894a0e8764")
    cipher = AES.new(key, AES.MODE_ECB)
    return cipher.encrypt(data)

def decrypt_aes_128_ecb(data):
    key = binascii.unhexlify("32672f7974ad43451d9c6c894a0e8764")
    cipher = AES.new(key, AES.MODE_ECB)
    return cipher.decrypt(data)

# Example usage
if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    text = "Hello, World!"
    bitmap = get_text_image(text)
    encoded_bitmap = encode_bitmap_for_mask(bitmap)
    color_array = encode_color_array_for_mask(len(bitmap))

    print(f"Encoded bitmap length: {len(encoded_bitmap)}")
    print(f"Color array length: {len(color_array)}")

    # Encryption example
    test_data = b"1234567890123456"  # 16 bytes
    encrypted = encrypt_aes_128(test_data)
    decrypted = decrypt_aes_128_ecb(encrypted)
    print(f"Original: {test_data}")
    print(f"Encrypted: {binascii.hexlify(encrypted)}")
    print(f"Decrypted: {decrypted}")
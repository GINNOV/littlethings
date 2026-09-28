import asyncio
import logging
import argparse
from bleak import BleakClient, BleakScanner
from bleak.exc import BleakError
from Crypto.Cipher import AES
from PIL import Image, ImageDraw, ImageFont
import binascii
import os

logger = logging.getLogger(__name__)

class LEDMask:
    MASK_SERVICE_UUID = "0000fff0-0000-1000-8000-00805f9b34fb"
    GENERAL_CHAR_UUID = "d44bc439-abfd-45a2-b575-925416129600"
    UPLOAD_NOTIFY_CHAR_UUID = "d44bc439-abfd-45a2-b575-925416129601"
    UPLOAD_CHAR_UUID = "d44bc439-abfd-45a2-b575-92541612960a"

    def __init__(self):
        self.client = None
        self.aes_key = bytes.fromhex("32672f7974ad43451d9c6c894a0e8764")
        self.cipher = AES.new(self.aes_key, AES.MODE_ECB)
        self.upload_running = False
        self.current_upload = None

    async def connect(self):
        try:
            logger.debug("Starting device discovery...")
            devices = await BleakScanner.discover()
            for d in devices:
                logger.debug(f"Found device: {d.name} ({d.address})")
                if d.name and d.name.startswith("MASK"):
                    logger.debug(f"Attempting to connect to {d.name} ({d.address})")
                    self.client = BleakClient(d.address, timeout=20.0)
                    await self.client.connect()
                    print(f"Connected to the mask ({d.name})")
                    logger.debug(f"Connected to {d.name}")
                    return
            raise Exception("No MASK device found")
        except BleakError as e:
            logger.error(f"Error during connection: {str(e)}")
            raise

    async def disconnect(self):
        if self.client:
            await self.client.disconnect()
            print("Disconnected from the mask")
            logger.debug("Disconnected from the mask")

    def encrypt_aes_128(self, data):
        return self.cipher.encrypt(data)

    def decrypt_aes_128(self, data):
        return self.cipher.decrypt(data)

    async def send_command(self, command, data):
        if not self.client:
            raise Exception("Not connected to a mask")
        
        buf = bytearray([len(command) + len(data) + 1])  # +1 for the length byte itself
        buf.extend(command.encode())
        buf.extend(data)
        
        # Pad to 16 bytes
        while len(buf) % 16 != 0:
            buf.append(0)
        
        encrypted = self.encrypt_aes_128(buf)
        try:
            await self.client.write_gatt_char(self.GENERAL_CHAR_UUID, encrypted)
            logger.debug(f"Sent command: {command}")
        except BleakError as e:
            logger.error(f"Error sending command {command}: {str(e)}")
            raise

    async def set_mode(self, mode):
        await self.send_command("MODE", bytes([mode]))
        print(f"Set mode to {mode}")

    async def set_light(self, brightness):
        await self.send_command("LIGHT", bytes([brightness]))
        print(f"Set brightness to {brightness}")

    async def set_image(self, image):
        await self.send_command("IMAG", bytes([image]))
        print(f"Set image to {image}")

    async def set_animation(self, animation):
        await self.send_command("ANIM", bytes([animation]))
        print(f"Set animation to {animation}")

    async def set_text_speed(self, speed):
        await self.send_command("SPEED", bytes([speed]))
        print(f"Set text speed to {speed}")

    async def set_diy_image(self, image):
        await self.send_command("PLAY", bytes([1, image]))
        print(f"Set DIY image to {image}")

    async def set_text_color_mode(self, enable, mode):
        await self.send_command("M", bytes([enable, mode]))
        print(f"Set text color mode: enable={enable}, mode={mode}")

    async def set_text_front_color(self, enable, r, g, b):
        await self.send_command("FC", bytes([enable, r, g, b]))
        print(f"Set text front color: enable={enable}, R={r}, G={g}, B={b}")

    async def set_text_background_color(self, enable, r, g, b):
        await self.send_command("BG", bytes([enable, r, g, b]))
        print(f"Set text background color: enable={enable}, R={r}, G={g}, B={b}")

    def get_text_image(self, text):
        # This is a simplified version. You might need to adjust the size and font
        img = Image.new('1', (64, 16), color=0)
        draw = ImageDraw.Draw(img)
        font = ImageFont.load_default()
        draw.text((0, 0), text, font=font, fill=1)
        return list(img.getdata())

    def encode_bitmap_for_mask(self, pixel_map):
        # This is a simplified version. You might need to adjust the encoding
        return bytes(pixel_map)

    def encode_color_array_for_mask(self, length):
        # This is a simplified version. You might need to adjust the encoding
        return bytes([255, 255, 255] * length)  # White color for all pixels

    async def set_text(self, text):
        pixel_map = self.get_text_image(text)
        bitmap = self.encode_bitmap_for_mask(pixel_map)
        color_array = self.encode_color_array_for_mask(len(pixel_map))
        await self.init_upload(bitmap, color_array)
        print(f"Set text to '{text}'")

    async def init_upload(self, bitmap, color_array):
        if self.upload_running:
            raise Exception("Mask upload is already running!")

        self.current_upload = {
            'bitmap': bitmap,
            'color_array': color_array,
            'total_len': len(bitmap) + len(color_array),
            'bytes_sent': 0,
            'complete_buffer': bitmap + color_array,
            'packet_count': 0
        }

        buf = bytearray([9])  # length
        buf.extend(b"DATS")
        buf.extend(self.current_upload['total_len'].to_bytes(2, 'big'))
        buf.extend(len(bitmap).to_bytes(2, 'big'))
        buf.append(0)

        while len(buf) % 16 != 0:
            buf.append(0)

        encrypted = self.encrypt_aes_128(buf)
        await self.client.write_gatt_char(self.GENERAL_CHAR_UUID, encrypted)
        self.upload_running = True

    async def upload_part(self):
        if self.current_upload['bytes_sent'] == self.current_upload['total_len']:
            return

        max_size = 98  # btMaxPacketSize - 2
        bytes_to_send = min(max_size, self.current_upload['total_len'] - self.current_upload['bytes_sent'])
        data = self.current_upload['complete_buffer'][self.current_upload['bytes_sent']:self.current_upload['bytes_sent'] + bytes_to_send]

        buf = bytearray([bytes_to_send + 1, self.current_upload['packet_count']])
        buf.extend(data)

        await self.client.write_gatt_char(self.UPLOAD_CHAR_UUID, buf)

        self.current_upload['bytes_sent'] += bytes_to_send
        self.current_upload['packet_count'] += 1

    async def finish_upload(self):
        buf = bytearray([5])  # length
        buf.extend(b"DATCP")

        while len(buf) % 16 != 0:
            buf.append(0)

        encrypted = self.encrypt_aes_128(buf)
        await self.client.write_gatt_char(self.GENERAL_CHAR_UUID, encrypted)

    async def handle_upload_notification(self, sender, data):
        decrypted = self.decrypt_aes_128(data)
        str_len = decrypted[0]
        resp = decrypted[1:str_len+1].decode()

        if resp == "DATSOK":
            await self.upload_part()
        elif resp == "REOK":
            if self.current_upload['bytes_sent'] < self.current_upload['total_len']:
                await self.upload_part()
            else:
                await self.finish_upload()
        elif resp == "DATCPOK":
            self.upload_running = False
        elif resp == "PLAYOK":
            pass  # Do nothing, response to DIY image
        else:
            logger.warning(f"Unknown notify response: {resp}")

# Sets the scroll mode
# 01 = steady
# 02 = blink
# 03 = scroll left
# 04 = scroll right
# 05 = steady
async def demo_control_loop(mask):
    while True:
        print("Input cmd please:")
        cmd = input().strip().split()

        if not cmd:
            continue

        try:
            if cmd[0] == "connect":
                await mask.connect()
            elif cmd[0] == "allmode":
                for i in range(1, 5):
                    print(f"trying to send mode {i}")
                    await mask.set_mode(i)
                    await asyncio.sleep(5)
            elif cmd[0] == "mode":
                await mask.set_mode(int(cmd[1]))
            elif cmd[0] == "light":
                await mask.set_light(int(cmd[1]))
            elif cmd[0] == "image":
                await mask.set_image(int(cmd[1]))
            elif cmd[0] == "diy":
                await mask.set_diy_image(int(cmd[1]))
            elif cmd[0] == "speed":
                await mask.set_text_speed(int(cmd[1]))
            elif cmd[0] == "color":
                await mask.set_text_color_mode(1, int(cmd[1]))
            elif cmd[0] == "fg":
                color = int(cmd[1].lstrip('#'), 16)
                r, g, b = color >> 16, (color >> 8) & 255, color & 255
                await mask.set_text_front_color(1, r, g, b)
            elif cmd[0] == "bg":
                color = int(cmd[1].lstrip('#'), 16)
                r, g, b = color >> 16, (color >> 8) & 255, color & 255
                await mask.set_text_background_color(1, r, g, b)
            elif cmd[0] == "text":
                bitmap = bytes([0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00])
                color_array = bytes([0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00,
                                     0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00,
                                     0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00,
                                     0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00])
                await mask.init_upload(bitmap, color_array)
            elif cmd[0] == "text2":
                bitmap = binascii.unhexlify("020002003ff83ffc020402040000000000f001f8034c0244034401cc00c80000018803cc024402640224033c01180000020002003ff83ffc0204020400000000")
                color_array = binascii.unhexlify("fffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffcfffffc")
                await mask.init_upload(bitmap, color_array)
            elif cmd[0] == "text3":
                text = " ".join(cmd[1:])
                await mask.set_text(text)
            elif cmd[0] == "exit":
                await mask.disconnect()
                sys.exit(0)
            else:
                print("Unknown cmd")
        except Exception as e:
            print(f"Error executing command: {e}")

async def main():
    parser = argparse.ArgumentParser(description="LED Mask Control")
    parser.add_argument('--debug', action='store_true', help='Enable debug logging')
    parser.add_argument('--draw', action='store_true', help='Send images to the mask')
    parser.add_argument('--text', type=str, default="test", help='Render text over the mask.')
    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    if args.draw:
        print(f"Drawing '{args.text}'")
        mask = LEDMask()
        image = mask.get_text_image(args.text)
        # You might want to save or display the image here
        return

    mask = LEDMask()
    try:
        await mask.connect()
        await demo_control_loop(mask)
    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
    finally:
        await mask.disconnect()

if __name__ == "__main__":
    asyncio.run(main())
import struct
import cv2
import numpy as np


class JPGFrame:
    VIDEO_STREAM_H264 = 0
    VIDEO_STREAM_JPG = 1
    AUDIO_STREAM_AAC = 2

    def __init__(self):
        self.seq = 0
        self.stamp = 0
        self.session = 0
        self.type = 0
        self.oseq = 0
        self.par1 = 0
        self.par2 = 0
        self.par3 = 0
        self.par4 = 0
        self.data = bytearray()

    def parse_frame(msg):
        frame = JPGFrame()
        buffer = msg._buff
        offset = 0

        (frame.seq,) = struct.unpack_from("<I", buffer, offset)
        offset += 4
        (frame.stamp,) = struct.unpack_from("<Q", buffer, offset)
        offset += 8
        offset += 4  # Skip frame_id

        frame.session, frame.type, frame.oseq = struct.unpack_from(
            "<IbI", buffer, offset
        )
        offset += 9
        frame.par1, frame.par2, frame.par3, frame.par4 = struct.unpack_from(
            "<iiii", buffer, offset
        )
        offset += 16
        frame.data = buffer[offset:]

        return frame

    def process_frame(frame_data):
        np_arr = np.frombuffer(frame_data, np.uint8)
        img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        return img

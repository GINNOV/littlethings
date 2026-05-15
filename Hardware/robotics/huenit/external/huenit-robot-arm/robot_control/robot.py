# paul update 23.10.18
# paul udpate 24.01.04 (bug fix)

import math
import serial
from serial.tools import list_ports
from typing import Tuple
import time
import sys

'''
구성 플로우

1. serial port 스캔 -> 여러개일 경우에, 예외처리 유념
2. serial 오픈
3. serial 에 보낼 커맨드 정의
4. 커맨드 전송

check list
- 라이브러리 app의 사전 파일로 위치필요
- 캠 때와는 다르게, generated.py 분리 필요
- 

'''


def extract_floats(text):
    floats = []
    current_number = ""

    for char in text:
        if char.isdigit() or char in ".+-":
            current_number += char
        else:
            if current_number:
                try:
                    floats.append(float(current_number))
                except ValueError:
                    pass  # Ignore invalid format
                current_number = ""

    if current_number:
        try:
            floats.append(float(current_number))
        except ValueError:
            pass

    return floats


def scan_ports():
    ports = list(serial.tools.list_ports.comports())
    available_ports = [(port.device, port.description, port.vid, port.pid, port.manufacturer, port.serial_number) for
                       port in ports]
    return available_ports


def get_my_device():
    port_list = scan_ports()
    for item in port_list:
        if 'FTDI' in item:
            return (item[0], item[1])


def openSerial(baudrate=115200, timeout=1000):
    return serial.Serial(get_my_device()[0], baudrate, timeout=timeout)


def checkConnection():
    command = "M400\n"
    ser = openSerial()
    ser.write(str.encode(command))
    # sys.stdout.flush()
    strt = time.time()
    while True:
        if (time.time() - strt > 0.1):
            ser.close()
            return False
        read_data = ser.readline().decode("utf-8")
        if read_data:
            if read_data.find("ok") > -1:
                break
            else:
                pass
    ser.close()
    return True


def sendCommand(command: str) -> Tuple[bool, str, str]:
    ser = openSerial()
    ser.rts = False
    is_success = True
    error_msg = ""
    additional_info = ""
    ser.write(str.encode(command))
    print('command = ', command)
    # sys.stdout.flush()
    while True:
        try:
            inputLine = ser.readline().decode("utf-8")

            if len(inputLine) > 0:
                if inputLine.find("ok") > -1:
                    print("read ok")
                    break
                elif inputLine.find("Unknown") > -1:
                    print(inputLine)
                    print("unknown command recevied")
                    error_msg = "unknown command received"
                    is_success = False
                elif inputLine.find("Current Point") > -1:  # temp: for the current point parsing
                    additional_info = inputLine
                elif inputLine.find("Module Type") > -1:  # temp: for the module type
                    additional_info = inputLine
                else:
                    additional_info = inputLine  # temp: for save current point update #TODO refactoring
                    print(inputLine)
            else:
                print("No lines to read")
                is_success = False
                error_msg = "No lines to read"
                break

        except Exception as e:
            print(e)
            is_success = False
            error_msg = str(e)
            break
        time.sleep(0.00001)

    ser.close()

    return is_success, error_msg, additional_info


def goHome():
    command = "M1008 A5\n"
    sendCommand(command)


def sendCommandNoReturn(command: str):
    ser = openSerial()
    ser.write(str.encode(command))
    # sys.stdout.flush()


def checkXYZ(x, y, z):
    """
    지정된 x, y, z 좌표로 로봇이 움직일 수 있는지(G0) 검사하는 함수입니다.

    :param x: float, x 좌표
    :param y: float, y 좌표
    :param z: float, z 좌표

    :return: int, 참이면 1, 거짓이면 0을 리턴합니다.
    """
    leng = math.sqrt(x * x + y * y)
    if (leng <= 213.44 and z >= 2.182):
        if (z <= 9.066):
            if (not (leng > 61 + math.pow((55 * 55 - (z - 30) ** 2), (0.5)))):
                # print('first err')
                return 0
        elif (z <= 100.1):
            if (not (leng > math.pow((152 ** 2 - (z - 147) ** 2), (0.5)) + 48)):
                # print('second err')
                return 0
        else:
            if (not (leng > math.pow((3600 - (z - 148) ** 2), (0.5)) + 153.5)):
                # print('third err')
                return 0
    elif (leng <= 224.566 and z <= 3.241):
        if (not (leng > math.pow((144 ** 2 - (z + 138) ** 2), (0.5)) + 81)):
            # print('fourth err')
            return 0
    else:
        if (not ((leng < (16500 + 100 * z) / 17) and ((leng - 228) ** 2 + (z + 4) ** 2 < 150 ** 2))):
            # print('fifth err')
            return 0

    if (y < 0):
        ix = (-1 * y) / leng
        # print("ix: ",ix)
        if 0.98 < ix:
            return 0

    # print('cango')
    return 1


def moveG0(*args):
    if len(args) == 1 and isinstance(args[0], (tuple, list)):  # 튜플이나 리스트 하나를 받았을 경우
        x, y, z = args[0]
    elif len(args) == 3:  # 개별 인자로 받은 경우
        x, y, z = args
    else:
        raise ValueError("moveG0 함수는 (x, y, z)를 개별 인자로 받거나, 하나의 튜플/리스트로 받아야 합니다.")

    command = f"G0 X{x} Y{y} Z{z}\n"
    sendCommand(command)
    sendCommand("M400\n")


def moveG1(*args):
    if len(args) == 1 and isinstance(args[0], (tuple, list)):  # 튜플이나 리스트 하나를 받았을 경우
        x, y, z = args[0]
    elif len(args) == 3:  # 개별 인자로 받은 경우
        x, y, z = args
    else:
        raise ValueError("moveG0 함수는 (x, y, z)를 개별 인자로 받거나, 하나의 튜플/리스트로 받아야 합니다.")

    command = f"G1 X{x} Y{y} Z{z}\n"
    sendCommand(command)
    sendCommand("M400\n")


def pumpOn():
    command = "M1401 A0" + "\n"
    sendCommand(command)
    command = "M1400 A1023" + "\n"
    sendCommand(command)


def pumpOff():
    command = "M1400 A0" + "\n"
    sendCommand(command)


def pump(power):
    command = "M1400 A" + str(power) + "\n"
    sendCommand(command)


def valveOn():
    command = "M1401 A1" + "\n"
    sendCommand(command)


def valveOff():
    command = "M1401 A0" + "\n"
    sendCommand(command)


def suctionOn():
    valveOff()
    pumpOn()


def suctionOff():
    pumpOff()
    valveOn()
    time.sleep(0.3)
    valveOff()


def gripper(state):
    if state == 0:
        pumpOff()
        valveOn()
        time.sleep(0.3)
        valveOff()
    elif state == 1:
        valveOff()
        # pumpOn()
        pump(623)
    elif state == 2:
        valveOn()
        # pumpOn()
        pump(623)


def set_current_position():
    sendCommand("M1500 B4\n")


def moveAngle(a, b, c):
    command = "M1005 A" + str(a) + " B" + str(b) + " C" + str(c) + "\n"
    sendCommand(command)
    sendCommand("M400\n")


def moveAngle_noM400(a, b, c):
    command = "M1005 A" + str(a) + " B" + str(b) + " C" + str(c) + "\n"
    sendCommand(command)


def moveZ0_M400(z):
    command = "G0 Z" + str(z) + "\n"
    sendCommand(command)
    sendCommand("M400\n")


def moveZ0(z):
    command = "G0 Z" + str(z) + "\n"
    sendCommand(command)


def freeMod():
    sendCommand("M84\n")


def unsetFreeMod():
    sendCommand("M17\n")
    sendCommand("M1008 A1\n")
    sendCommand("G90\n")


def getLoc():
    info1, info2, info3 = sendCommand("M1008 A3\n")
    withFlt = extract_floats(info3)
    # print("gganada",withFlt)
    return withFlt


def getDeg():
    info1, info2, info3 = sendCommand("M1008 A2\n")
    withFlt = extract_floats(info3)
    # print("gganada",withFlt)
    return withFlt


def suctionAngle(angle, speed=60):
    # 각도를 0~360 범위로 변환
    normalized_angle = angle % 360
    if normalized_angle < 0:  # 음수일 경우 보정
        normalized_angle += 360

    # 180 이상인지 확인
    if (normalized_angle >= 270):
        print("Unsupported degree")
        return

    if (speed <= 0):
        print("Unsupported speed")
        return

    sendCommand("M9996 A1B" + str(normalized_angle) + "C" + str(speed) + "\n")


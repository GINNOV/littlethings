import pyspacemouse
from robot_control.robot import moveAngle, getDeg, unsetFreeMod, openSerial, extract_floats, getLoc
import time


class SpaceMouseControl:
    def __init__(self):
        print("Initialisiere Roboter...")
        self.serial = openSerial()
        self.serial.rts = False
        unsetFreeMod()

        # Aktuelle Position auslesen
        current_angles = getDeg()
        if len(current_angles) < 3:
            raise RuntimeError("Konnte aktuelle Position nicht auslesen")
        self.current_angles = tuple(current_angles[0:3])

        print("Verbinde mit SpaceMouse...")
        if not pyspacemouse.open(callback=self.on_movement, set_nonblocking_loop=True):
            raise RuntimeError("Failed to connect to SpaceMouse")
        print("SpaceMouse verbunden.")

        self.speed_factor = 10.0
        self.input_threshold = 0.1
        self.target_angles = self.current_angles
        self.is_moving = False
        self.last_move_time = time.time()
        self.move_cooldown = 0.1  # Minimale Zeit zwischen Bewegungen

    def get_current_angles(self):
        """Liest aktuelle Position aus"""
        self.send_command("M1008 A2\n")

        # Lese Zeilen bis wir die Position finden oder timeout
        start_time = time.time()
        while time.time() - start_time < 1.0:  # 1 Sekunde Timeout
            response = self.serial.readline().decode("utf-8").strip()
            if not response:
                continue

            # Suche nach einer Zeile, die mit "A:" beginnt
            if response.startswith("A:"):
                angles = extract_floats(response)
                if len(angles) >= 3:
                    return angles[:3]

        print(f"Warnung: Keine gültige Positionsantwort erhalten")
        return None

    def send_command(self, command: str) -> str:
        """Sendet Kommando direkt über die serielle Verbindung"""
        self.serial.write(str.encode(command))
        return command  # Für Debug-Zwecke

    def on_movement(self, state):
        if self.is_moving:
            return

        current_time = time.time()
        if current_time - self.last_move_time < self.move_cooldown:
            return

        # Hole aktuelle Position
        current_pos = getLoc()
        if not current_pos or len(current_pos) < 3:
            return

        has_movement = False
        new_pos = list(current_pos)

        # Vor/Zurück bewegt Y-Koordinate
        if abs(state.pitch) > self.input_threshold:
            new_pos[1] = current_pos[1] + state.pitch * self.speed_factor  # Vorzeichen geändert
            has_movement = True

        # Links/Rechts bewegt X-Koordinate
        if abs(state.yaw) > self.input_threshold:
            new_pos[0] = current_pos[0] + state.yaw * self.speed_factor
            has_movement = True

        # Hoch/Runter bewegt Z-Koordinate
        if abs(state.z) > self.input_threshold:
            new_pos[2] = current_pos[2] + state.z * self.speed_factor
            has_movement = True

        if not has_movement:
            return

        self.is_moving = True
        try:
            command = f"G0 X{new_pos[0]} Y{new_pos[1]} Z{new_pos[2]}\n"
            self.send_command(command)
            self.send_command("M400\n")
            self.last_move_time = current_time
        finally:
            self.is_moving = False

    def __del__(self):
        if hasattr(self, 'serial'):
            self.serial.close()
        pyspacemouse.close()


if __name__ == "__main__":
    control = SpaceMouseControl()
    print("SpaceMouse Control gestartet. Strg+C zum Beenden.")
    try:
        while True:
            pyspacemouse.read()
    except KeyboardInterrupt:
        print("\nProgramm beendet.")
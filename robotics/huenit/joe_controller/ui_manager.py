# Module: ui_manager
# Description: Manages the terminal user interface using the curses library.

import curses


class UIManager:
    """Handles drawing and updating the terminal UI."""

    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.height, self.width = self.stdscr.getmaxyx()
        self.status_text = "INITIALIZING"
        self.status_type = "info"
        self.suction_on = False
        self.setup_windows()
        self.setup_colors()
        self.draw_static_layout()

    def setup_windows(self):
        """Create curses windows for different UI sections."""
        self.status_win = curses.newwin(4, self.width // 2, 1, 1)
        self.position_win = curses.newwin(4, self.width // 2, 1, self.width // 2)
        self.log_win = curses.newwin(4, self.width, 6, 1)
        self.controls_win = curses.newwin(6, self.width, 11, 1)

    def setup_colors(self):
        """Initialize color pairs for the UI."""
        curses.start_color()
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.curs_set(0)  # Hide the cursor
        self.stdscr.nodelay(True)  # Non-blocking input

    def draw_static_layout(self):
        """Draw the main layout and titles that don't change."""
        self.stdscr.clear()
        self.stdscr.addstr(0, 1, "--- Joe's Advanced Controller ---", curses.A_BOLD)

        self.status_win.box()
        self.status_win.addstr(0, 2, " STATUS ", curses.A_BOLD)

        self.position_win.box()
        self.position_win.addstr(0, 2, " POSITION (mm) ", curses.A_BOLD)

        self.log_win.box()
        self.log_win.addstr(0, 2, " LOG ", curses.A_BOLD)

        self.controls_win.box()
        self.controls_win.addstr(0, 2, " CONTROLS ", curses.A_BOLD)

        controls_text = [
            "ARROWS: Move XY   PGUP/PGDN: Move Z",
            "HOME: Go Home     S: Suction ON     D: Suction OFF",
            "R: Request Status  P: Run Program      ESC: Quit",
        ]
        for i, text in enumerate(controls_text, 1):
            self.controls_win.addstr(i, 2, text, curses.color_pair(4))

        self.refresh_all()
        self._render_status()

    def update_status(self, text, status_type="info"):
        """Update the status window."""
        self.status_text = self._sanitize(text)
        self.status_type = status_type
        self._render_status()

    def update_position(self, pos_dict):
        """Update the position window."""
        self.position_win.clear()
        self.position_win.box()
        self.position_win.addstr(0, 2, " POSITION (mm) ", curses.A_BOLD)
        if pos_dict:
            pos_str = f"X: {pos_dict.get('x', 0.0):<6.1f} Y: {pos_dict.get('y', 0.0):<6.1f} Z: {pos_dict.get('z', 0.0):<6.1f}"
            self.position_win.addstr(1, 2, pos_str, curses.color_pair(2))
        else:
            self.position_win.addstr(1, 2, "Position unknown.", curses.color_pair(3))
        self.position_win.refresh()

    def log_message(self, sent, received=""):
        """Update the log window with the last sent/received messages."""
        self.log_win.clear()
        self.log_win.box()
        self.log_win.addstr(0, 2, " LOG ", curses.A_BOLD)

        sent_str = f"SENT: {self._sanitize(sent)}"
        self._safe_addstr(self.log_win, 1, 2, sent_str)

        if received:
            rcv_str = f"RECV: {self._sanitize(received)}"
            self._safe_addstr(self.log_win, 2, 2, rcv_str)
        self.log_win.refresh()

    def refresh_all(self):
        """Refresh all windows."""
        self.stdscr.refresh()
        self.status_win.refresh()
        self.position_win.refresh()
        self.log_win.refresh()
        self.controls_win.refresh()

    def teardown(self):
        """Restore terminal to its original state."""
        curses.curs_set(1)
        self.stdscr.nodelay(False)
        curses.endwin()

    def _sanitize(self, text):
        """Remove control characters and collapse newlines for safer rendering."""
        cleaned = text.replace("\n", " | ").replace("\r", "")
        return "".join(ch if 32 <= ord(ch) < 127 else " " for ch in cleaned)

    def _safe_addstr(self, window, y, x, text, color=None):
        """Write text to a window, truncating to the available width."""
        _, win_width = window.getmaxyx()
        max_len = max(0, win_width - (x + 1))
        truncated = text[:max_len]
        try:
            if color is None:
                window.addstr(y, x, truncated)
            else:
                window.addstr(y, x, truncated, color)
        except curses.error:
            # Best effort fallback; ensure the window still updates.
            pass

    def update_suction_state(self, enabled):
        """Persist the suction state and refresh the status window."""
        self.suction_on = bool(enabled)
        self._render_status()

    def _render_status(self):
        """Redraw the status window with connection and suction info."""
        self.status_win.clear()
        self.status_win.box()
        self.status_win.addstr(0, 2, " STATUS ", curses.A_BOLD)

        color = curses.color_pair(1)  # Default green
        if self.status_type == "warn":
            color = curses.color_pair(2)
        elif self.status_type == "error":
            color = curses.color_pair(3)

        suction_color = curses.color_pair(1 if self.suction_on else 2)
        suction_label = "ON" if self.suction_on else "OFF"

        self._safe_addstr(self.status_win, 1, 2, self.status_text, color)
        self._safe_addstr(
            self.status_win,
            2,
            2,
            f"SUCTION: {suction_label}",
            suction_color,
        )
        self.status_win.refresh()

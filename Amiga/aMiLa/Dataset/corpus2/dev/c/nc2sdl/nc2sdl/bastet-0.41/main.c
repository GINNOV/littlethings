/* main.c
   
   Bastet, an "evil" clone of tetris(R)

   (c) 2004 Federico Poloni <fphthirtyseven@ngi.it>,<f.thirtysevenpoloni@sns.it>
   (remove 37's to get the real e-mails)

   Based on Petris by Peter Seidler: here is his original disclaimer:
   Peter's Tetris (hmm...)
   By Peter Seidler <seidler@phys.au.dk> */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
//#include <curses.h>
//#include <term.h>
#include <pdcurses/curses.h>
#include <pdcurses/term.h>
#include "bastet.h"
#include "main.h"
#include "game.h"
#include "highscore.h"

/* Placement and size of different elements on the screen. */
COORDS coords;


/* Initialize struct with coordinates for different elements.
   The function's argument is a string of the form [width]x[height]. */
void init_coords(char *size)
{
	char *endptr;	
	short totw;	/* Total width. */
	
	/* "Constants" */
	WELL_Y = 2;
	STAT_Y = 2;
	STAT_WIDTH = 18;
	
	/* Dependant on constants */
	WELL_WIDTH = strtol(size, &endptr, 10);
	if (endptr == size || *endptr != 'x' || WELL_WIDTH < BLOCK_DOTS) {
		endwin();
		fprintf(stderr, "bastet: bad [width]x[height] format.\n");
		exit(1);
	}
	
	WELL_HEIGHT = strtol(endptr + 1, 0, 10);
	if (WELL_HEIGHT < BLOCK_DOTS) {
		endwin();
		fprintf(stderr, "bastet: bad [width]x[height] format.\n");
		exit(1);
	}

	totw = 2 * WELL_WIDTH + 2 + STAT_WIDTH + 2;

	/* This is only a basic check of the terminal size. If the status
	   window is taller than the well, or if some of the other windows
	   used during the game are bigger than the space occupied by
	   the well or status display things will go wrong. */
	if (totw > COLS || WELL_Y + WELL_HEIGHT >= LINES) {
		endwin();
		fprintf(stderr, "bastet: terminal too small. Aborting.\n");
		exit(1);
	}
	
	/* Place everything in the center of the screen. */
	WELL_X = COLS / 2 - totw / 2 + 1;	/* +1 because of frame. */
	STAT_X = WELL_X + 2 * WELL_WIDTH + 3;
}

void parse_args(int argc, char **argv)
{
  /* If arg. 2 is there assume it's a well size. If not use default size. */
  if (argc >= 2)
    init_coords(*(argv + 1));
  else
    init_coords("10x20");
}

void init_colors()
{
  if (!has_colors()) {
    endwin();
    fprintf(stderr, "bastet: your terminal doesn't support colors. Aborting \n"); //XXX:
    exit(1);
  }

  /* We assume this goes ok - we should check, really. */
  start_color();

  /* 1 - 16 is for blocks (we just don't have 16 blocks yet) */
  init_pair(1, COLOR_BLACK, COLOR_RED);
  init_pair(2, COLOR_BLACK, COLOR_YELLOW);
  init_pair(3, COLOR_BLACK, COLOR_GREEN);
  init_pair(4, COLOR_BLACK, COLOR_CYAN);
  init_pair(5, COLOR_BLACK, COLOR_MAGENTA);
  init_pair(6, COLOR_BLACK, COLOR_BLUE);
  init_pair(7, COLOR_BLACK, COLOR_WHITE);

  /* 17 - ? is for other things */
  init_pair(COLOR_POINTS, COLOR_RED, COLOR_BLACK);
  init_pair(COLOR_LINES, COLOR_YELLOW, COLOR_BLACK);
  init_pair(COLOR_LEVEL, COLOR_GREEN, COLOR_BLACK);
  init_pair(COLOR_MSG, COLOR_YELLOW, COLOR_BLACK);
}

/* Redraw static parts of the screen. */
void update_screen()
{
  /* Remember: Each dot in well is two chars wide! */

  clear();
  //XXX:ugly!
        /*Draw frame around well window. */
  attrset(COLOR_PAIR(0));
  move(WELL_Y, WELL_X - 1);
  vline(ACS_VLINE, WELL_HEIGHT);
  move(WELL_Y, WELL_X + (2 * WELL_WIDTH));
  vline(ACS_VLINE, WELL_HEIGHT);
  move(WELL_Y + WELL_HEIGHT, WELL_X - 1);
  addch(ACS_LLCORNER);
  hline(ACS_HLINE, 2 * WELL_WIDTH);
  move(WELL_Y + WELL_HEIGHT, WELL_X + (2 * WELL_WIDTH));
  addch(ACS_LRCORNER);

        /* This is for the status stuff. */
  move(STAT_Y, STAT_X);
  addch(ACS_ULCORNER);
  hline(ACS_HLINE, STAT_WIDTH - 2);

	//writing
  move(STAT_Y-1, STAT_X-1);
  addstr("Won't give you this one!");

  move(STAT_Y, STAT_X + STAT_WIDTH - 1);
  addch(ACS_URCORNER);
  move(STAT_Y + 1, STAT_X);
  vline(ACS_VLINE, BLOCK_DOTS + 7);
  move(STAT_Y + 1, STAT_X + STAT_WIDTH - 1);
  vline(ACS_VLINE, BLOCK_DOTS + 7);
  move(STAT_Y + BLOCK_DOTS + 8, STAT_X);
  addch(ACS_LLCORNER);
  hline(ACS_HLINE, STAT_WIDTH - 2);
  move(STAT_Y + BLOCK_DOTS + 8, STAT_X + STAT_WIDTH - 1);
  addch(ACS_LRCORNER);
  move(STAT_Y + BLOCK_DOTS + 2, STAT_X);
  addch(ACS_LTEE);
  hline(ACS_HLINE, STAT_WIDTH - 2);
  move(STAT_Y + BLOCK_DOTS + 2, STAT_X + STAT_WIDTH - 1);
  addch(ACS_RTEE);

  refresh();
}

int get_level(int level)
{
  WINDOW *win;
  int ch = 0;

  /* Place window in the middle of the screen. */
  win = newwin(12, 16, LINES / 2 - 6, COLS / 2 - 8);
  box(win, 0, 0);

  wattrset(win, COLOR_PAIR(COLOR_MSG));
  mvwprintw(win, 2, 2, "Choose level");
  mvwprintw(win, 3, 2, "(0 - %d)", NO_LEVELS - 1);
  mvwprintw(win, 5, 2, "Up arrow");
  mvwprintw(win, 7, 2, "Down arrow");
  mvwprintw(win, 9, 2, "Space for OK");
  wattrset(win, COLOR_PAIR(COLOR_LEVEL));
  mvwprintw(win, 6, 4, "%d ", level);

  update_screen();
  wrefresh(win);

  nodelay(stdscr, FALSE);

  while(ch != ' ' && ch != KEY_ENTER) {
    ch = getch();
    switch (ch) {
    case KEY_UP:
      level = (level + 1 > NO_LEVELS - 1)? 0 : level + 1;
      mvwprintw(win, 6, 4, "%d ", level);
      wrefresh(win);
      break;
    case KEY_DOWN:
      level = (level - 1 < 0)? NO_LEVELS - 1: level - 1;
      mvwprintw(win, 6, 4, "%d ", level);
      wrefresh(win);
      break;
    }
  }

  nodelay(stdscr, TRUE);
  delwin(win);

  return level;
}

/* If use_hs != 0 check for new highscore. */
int show_score(POINTS points, int use_hs)
{
  WINDOW *win;
  int ranking;    /* Highscore ranking. */
  int ch;
  int ret = 1;

  /* Place window in the middle of the screen. */
  win = newwin(20, 28, LINES / 2 - 10, COLS / 2 - 14);
  box(win, 0, 0);

  wattrset(win, COLOR_PAIR(COLOR_MSG) | A_BOLD);
  mvwprintw(win, 2, 6, "*** GAME OVER ***");
  wattrset(win, COLOR_PAIR(COLOR_MSG));
  mvwprintw(win, 4, 2, "You scored:");
  wattrset(win, COLOR_PAIR(COLOR_POINTS));
  mvwprintw(win, 6, 5, "Points: %d", points.points);
  wattrset(win, COLOR_PAIR(COLOR_LINES));
  mvwprintw(win, 7, 5, "Lines:  %d", points.lines);
  wattrset(win, COLOR_PAIR(COLOR_LEVEL));
  mvwprintw(win, 8, 5, "Level:  %d", points.level);

  wattrset(win, COLOR_PAIR(COLOR_POINTS) | A_BOLD);
  if (use_hs) {
    ranking = check_highscores(points.points);
    if (ranking) {
      mvwprintw(win, 10, 2, "Congratulations!");
      wattrset(win, COLOR_PAIR(COLOR_MSG));
      mvwprintw(win, 12, 5, "You're on the high-");
      mvwprintw(win, 13, 5, "score list as no. %d", ranking);
    } else
      mvwprintw(win, 11, 5, "Che scarso!");
  } else {
    mvwprintw(win, 10, 2, "Highscore disabled!");
  }

  wattrset(win, COLOR_PAIR(COLOR_MSG));
  mvwprintw(win, 15, 2, "Press q to quit, h to");
  mvwprintw(win, 16, 2, "view highscores or any");
  mvwprintw(win, 17, 2, "other key to play again.");

  update_screen();
  wrefresh(win);

  if (ch != ERR)
    while (getch() != ERR);

  nodelay(stdscr, FALSE);

  ch = getch();
  if (ch == 'q' || ch == 'Q')
    ret = 0;
  else if (ch == 'h' || ch == 'H')
    ret = view_highscores();

  nodelay(stdscr, TRUE);
  delwin(win);

  return ret;
}

/* Displays a message in the top left corner for a couple
 * of seconds. Used for displaying "global" messages like
 * errors */
void message(char *msg)
{
  attrset(COLOR_PAIR(COLOR_MSG) | A_BLINK);
  mvprintw(0,0, msg);
  refresh();
  sleep(3);
}

int main(int argc, char **argv)
{
  int play = 1;
  int level = 0;
  POINTS points;
  int use_highscore = 1;

  /* Initialize screen */
  if (0 == initscr()) {
    fprintf(stderr, "bastet: error initializing ncurses.\n");
    exit(1);
  }

  parse_args(argc, argv);

  /* We only use highscore list if the size of the well is
     standard 10x20. */
  if (WELL_WIDTH != 10 || WELL_HEIGHT != 20)
    use_highscore = 0;

  /* Turn off cursor. */
  curs_set(0);
  atexit((void *)endwin); /*make sure curses are properly stopped*/

  /* Setup keyboard. We'd like to get each and every character, but
     not to display them on the terminal. */
  keypad(stdscr, TRUE);
  nodelay(stdscr, TRUE);
  nonl();
  noecho();
  cbreak();

  init_colors();

  /* Set random seed. */
  srandom(time(NULL)+37); /*37: the magic number!*/

  /* This is where the game begins! */
  while (play) {
    level = get_level(level);
    points = play_game(level);
    play = show_score(points, use_highscore);
  }

  return 0;
}

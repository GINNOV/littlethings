/* game.c
   The functions relevant to the game itself. */

#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
//#include <curses.h>
#include <pdcurses/curses.h>
#include <string.h>
#include "bastet.h"
#include "config.h"
#include "game.h"
#include "main.h"
#include "bast.h"

const DOT block_data[BLOCK_TYPES][BLOCK_ORIENTS][BLOCK_DOTS] =
{
        {
                {{2,0,1},{2,1,1},{2,2,1},{2,3,1}},      /*      */
                {{0,1,1},{1,1,1},{2,1,1},{3,1,1}},      /*      */
                {{2,0,1},{2,1,1},{2,2,1},{2,3,1}},      /* XXXX */
                {{0,1,1},{1,1,1},{2,1,1},{3,1,1}}       /*      */
        },
        {
                {{1,1,2},{2,1,2},{1,2,2},{2,2,2}},      /*      */
                {{1,1,2},{2,1,2},{1,2,2},{2,2,2}},      /*  XX  */
                {{1,1,2},{2,1,2},{1,2,2},{2,2,2}},      /*  XX  */
                {{1,1,2},{2,1,2},{1,2,2},{2,2,2}}       /*      */
        },
        {
                {{1,0,3},{1,1,3},{1,2,3},{2,2,3}},      /*      */
                {{2,0,3},{0,1,3},{1,1,3},{2,1,3}},      /* XXX  */
                {{0,0,3},{1,0,3},{1,1,3},{1,2,3}},      /*   X  */
                {{0,1,3},{1,1,3},{2,1,3},{0,2,3}}       /*      */
        },
        {
                {{1,0,4},{2,0,4},{1,1,4},{1,2,4}},      /*      */
                {{0,0,4},{0,1,4},{1,1,4},{2,1,4}},      /* XXX  */
                {{1,0,4},{1,1,4},{0,2,4},{1,2,4}},      /* X    */
                {{0,1,4},{1,1,4},{2,1,4},{2,2,4}}       /*      */
        },
        {
                {{1,0,5},{1,1,5},{2,1,5},{2,2,5}},      /*      */
                {{1,0,5},{2,0,5},{0,1,5},{1,1,5}},      /* XX   */
                {{1,0,5},{1,1,5},{2,1,5},{2,2,5}},      /*  XX  */
                {{1,0,5},{2,0,5},{0,1,5},{1,1,5}}       /*      */
        },
        {
                {{2,0,6},{1,1,6},{2,1,6},{1,2,6}},      /*      */
                {{0,0,6},{1,0,6},{1,1,6},{2,1,6}},      /*  XX  */
                {{2,0,6},{1,1,6},{2,1,6},{1,2,6}},      /* XX   */
                {{0,0,6},{1,0,6},{1,1,6},{2,1,6}}       /*      */
        },
        {
                {{1,0,7},{1,1,7},{2,1,7},{1,2,7}},      /*  X   */
                {{1,0,7},{0,1,7},{1,1,7},{2,1,7}},      /* XXX  */
                {{1,0,7},{0,1,7},{1,1,7},{1,2,7}},      /*      */
                {{0,1,7},{1,1,7},{2,1,7},{1,2,7}}       /*      */
        }
};

/* This is a pointer to the well data which will be allocated later.
   The block of data pointed to is a simple (y,x)-coordinate system. At
   each point is stored a color (0 means there's space for new blocks). */
unsigned char *well_data;

/* Delay before block drop one step down (usec).
   We start at one sec. and then decreases the delay by 23% at each level. */
const int delay[NO_LEVELS] = {1000000, 770000, 593000, 457000, 352000, 271000, 208000, 160000, 124000, 95000};

/* Window in which the action takes place. */
WINDOW *well_win;

/* Convert (y, x)-coordinates in well to a pointer. */
unsigned char *yx2pointer(int y, int x)
{
        return well_data + (y * WELL_WIDTH) + x;
}

/* Used to plot the blocks. Each point is two characters wide
   - this looks better on my terminal. */
void draw_block(WINDOW *win, int y, int x, int type, int orient, char erase)
{
        int i;
        DOT dot;

        /* We have BLOCK_DOTS points to paste on the screen. Read each DOT,
           get color and draw it relative to y and x. */

        for (i = 0; i < BLOCK_DOTS; i++) {
                dot = block_data[type][orient][i];
                wattrset(win, COLOR_PAIR(erase? 0 : dot.color));
                mvwprintw(win, y + dot.y, 2*(x + dot.x), "  ");
        }

        /* An erase operation will most likely (always) be followed by a new
           drawing. To avoid flickering, we don't update the screen in this
           case. */
        if (0 == erase)
                wrefresh(win);
}

/* This redraws the well window with data in well_data. */
void update_well(int start, int lines)
{
        int y, x;

        for (y = start; y < start + lines; y++) {
                wmove(well_win, y, 0);
                for (x = 0; x < WELL_WIDTH; x++) {
                        wattrset(well_win, COLOR_PAIR(*yx2pointer(y, x)));
                        mvwprintw(well_win, y, 2 * x, "  ");
                }
        }
        wrefresh(well_win);
}

/* Check if a position for a block is valid, i.e. it doesn't overlap a point
   which is already occupied or goes outside the well borders. */
int check_block_pos(int y, int x, int type, int orient)
{
        int i;
        DOT dot;

        for (i = 0; i < BLOCK_DOTS; i++) {
                dot = block_data[type][orient][i];
                if ((y + dot.y > WELL_HEIGHT - 1)               ||
                    (x + dot.x < 0)                             ||
                    (x + dot.x > WELL_WIDTH - 1)                ||
                    (*yx2pointer(y + dot.y, x + dot.x) > 0) )
                        return 0;
        }

        return 1;
}

/* Put the points a block occupies into well_data and update. */
void set_block(int y, int x, int type, int orient)
{
        int i;
        DOT dot;

        for (i = 0; i < BLOCK_DOTS; i++) {
                dot = block_data[type][orient][i];
                *yx2pointer(y + dot.y, x + dot.x) = dot.color;
        }
        update_well(y, BLOCK_DOTS);
}

/* Helper for check_lines(). Visualize a new line by some "nice effects". */
void visualize_lines(int start, short line_stat)
{
        int i, y;
        short tmp;      /* For comparison with line_stat. */

        wattrset(well_win, COLOR_PAIR(0));

        for (i = 0; i < 6; i++) {
                tmp = 0x0001;
                for (y = BLOCK_DOTS - 1; y >= 0; y--) {
                        if (line_stat & tmp) {
                                wmove(well_win, start + y, 0);
                                whline(well_win, i % 2? ' ' : ':', WELL_WIDTH * 2);
                        }
                        tmp <<= 1;
                }
                wrefresh(well_win);
                usleep(500000 / 6);
        }
}

/* Another helper function. Remove lines specified in line_stat (relative to
   start) from well_data. Then update display. */
void remove_lines(int start, short line_stat)
{
        unsigned char *tmp_well;
        short tmp;      /* Used for comparison with line_stat. */
        int y;
        int lines = 0;  /* No. of full lines. */

        tmp_well=malloc(WELL_HEIGHT * WELL_WIDTH);
        memset(tmp_well, 0, BLOCK_DOTS * WELL_WIDTH);

        /* Copy part below the point where thing may change. */
        memcpy(tmp_well + (start + BLOCK_DOTS) * WELL_WIDTH,
                well_data + (start + BLOCK_DOTS) * WELL_WIDTH,
                (WELL_HEIGHT - start - BLOCK_DOTS) * WELL_WIDTH);

        /* Copy the lines that are not full. */
        /* We check from bottom and upwards because this makes it easier
           to take care op moving (not full) lines down. */
        tmp = 0x0001;
        for (y = BLOCK_DOTS - 1; y >= 0; y--) {
                if (!(line_stat & tmp)) {
                        memcpy(tmp_well + (start + y + lines) * WELL_WIDTH,
                               well_data + (start + y) * WELL_WIDTH,
                               WELL_WIDTH);
                } else
                        lines++;

                tmp <<= 1;
        }

        /* Copy the rest, i.e. the upper part of the well. */
        memcpy(tmp_well + (lines * WELL_WIDTH), well_data, WELL_WIDTH * start);

        memcpy(well_data, tmp_well, WELL_HEIGHT * WELL_WIDTH);

        update_well(0, WELL_HEIGHT);
}

/* Check for complete lines. Update display and well_data.
   Return number of point obtained.
   We check from line start to start + BLOCK_DOTS - 1. */
POINTS check_lines(int start)
{
        int y, x;
        short line;
        short line_stat = 0; /* Each bit indicates the status for a
                                tested line. If set line is full.
                                Lower bit is lower line. */
        POINTS points;

        points.points = 0;
        points.lines = 0;

        /* Avoid reading beyond end of well_data. */
        if (start > WELL_HEIGHT - BLOCK_DOTS)
                start = WELL_HEIGHT - BLOCK_DOTS;

        for (y = start; y < start + BLOCK_DOTS; y++) {
                line_stat <<= 1;
                line = TRUE;

                for (x = 0; x < WELL_WIDTH; x++)
                        if (*yx2pointer(y, x) == 0) {
                                line = FALSE;
                                break;
                        }

                if (TRUE == line) {
                        if (0 == line_stat)     /* First line. */
                                points.points = 50;
                        else                    /* Multiply points by two. */
                                points.points *= 2;

                        points.lines++;

                        line_stat = line_stat | 0x0001;
                }
        }

        if (line_stat) {
                visualize_lines(start, line_stat);
                remove_lines(start, line_stat);
        }

        return points;
}

void update_stat(POINTS points, int block)
{
        static int prev_block = 0;      /* This is preserved between calls and make
                                           us able to erase last block. */

        draw_block(stdscr, STAT_Y + 2, STAT_X / 2 + 2 , prev_block, 0, 1);
        draw_block(stdscr, STAT_Y + 2, STAT_X / 2 + 2 , block, 0, 0);

        attrset(COLOR_PAIR(COLOR_POINTS));
        mvprintw(STAT_Y + BLOCK_DOTS + 3, STAT_X + 2, "Points: %d", points.points);
        attrset(COLOR_PAIR(COLOR_LINES));
        mvprintw(STAT_Y + BLOCK_DOTS + 5, STAT_X + 2, "Lines:  %d", points.lines);
        attrset(COLOR_PAIR(COLOR_LEVEL));
        mvprintw(STAT_Y + BLOCK_DOTS + 7, STAT_X + 2, "Level:  %d", points.level);

        prev_block = block;

        refresh();
}

/* Drop a block in the well. When done return y-cord. of where block
   ended. If it's not possible to even start with a new block return -1. */
int drop_block(int type, int level)
{
        int defx = WELL_WIDTH / 2 - BLOCK_DOTS / 2;
        int y = 0;
        int x = defx;
        int orient = 0;
        int ch;
        fd_set inputs, test_fds;
        struct timeval timeout;
        int sel_ret;

        if (0 == check_block_pos(y, x, type, orient))
                return -1;      /* Oh no, game over. */

        timeout.tv_sec = 0;
        timeout.tv_usec = delay[level];

        FD_ZERO(&inputs);
        FD_SET(0, &inputs);

        if (ch != ERR)
                while (getch() != ERR);

        draw_block(well_win, y, x, type, orient, 0);

        while(1) {
                test_fds = inputs;

                sel_ret = select(FD_SETSIZE, &test_fds, (fd_set *) 0, (fd_set *) 0, &timeout);

                ch = getch();

                switch (ch) {
                case CONTROL_LEFT:
                        if (check_block_pos(y, x - 1, type, orient)) {
                          draw_block(well_win, y, x, type, orient, 1);
                          draw_block(well_win, y, --x, type, orient, 0);
                        }
                        break;

                case CONTROL_RIGHT:
                        if (check_block_pos(y, x + 1, type, orient)) {
                         draw_block(well_win, y, x, type, orient, 1);
                         draw_block(well_win, y, ++x, type, orient, 0);
                        }
                        break;

                case CONTROL_ROT_CW:
                        if (check_block_pos(y, x, type,
                                        orient + 1 == BLOCK_ORIENTS? 0 : orient + 1)) {
                                draw_block(well_win, y, x, type, orient, 1);
                                ++orient == BLOCK_ORIENTS? orient = 0: 0;
                                draw_block(well_win, y, x, type, orient, 0);
                        }
                        break;

                case CONTROL_ROT_CCW:
                        if (check_block_pos(y, x, type,
                                        orient - 1 == -1? BLOCK_ORIENTS -1 : orient - 1)) {
                                draw_block(well_win, y, x, type, orient, 1);
                                --orient == -1? orient = BLOCK_ORIENTS - 1: 0;
                                draw_block(well_win, y, x, type, orient, 0);
                        }
                        break;

                case CONTROL_DOWN:
                        sel_ret = 0;
                        break;

                case CONTROL_REFRESH:   /* Refresh well. */
                        update_screen();
                        update_well(0, WELL_HEIGHT);
                        draw_block(well_win, y, x, type, orient, 0);
                        break;
                case CONTROL_DROP:
                  draw_block(well_win,y,x,type,orient,1);
                  while(check_block_pos(y+1,x,type,orient)) y++;
                  set_block(y,x,type,orient);
                  return y;
                  break;

                case CONTROL_QUIT:
                  return -1;
                  break;
                case CONTROL_PAUSE:
                  {
                    // int c;
                    wclear(well_win);
                    wattrset(well_win,COLOR_PAIR(0));
                    mvwaddstr(well_win,WELL_HEIGHT/2,WELL_WIDTH-7,"Press any key");
                    mvwaddstr(well_win,WELL_HEIGHT/2+1,WELL_WIDTH-6,"to continue");
                    wrefresh(well_win);
                    nodelay(stdscr,FALSE);
                    getch();
                    nodelay(stdscr,TRUE);
                    update_well(0,WELL_HEIGHT);
                    draw_block(well_win, y, x, type, orient, 0);
                    wrefresh(well_win);
                  }
                }
                /* If time has expired we need to move block down.
                   Check if block-pos. is ok if we move it down. If it's
                   not, paste block in well and return. */
                if (0 == sel_ret) {
                        if (check_block_pos(y + 1, x, type, orient)) {
                                draw_block(well_win, y, x, type, orient, 1);
                                draw_block(well_win, ++y, x, type, orient, 0);
                        } else {
                                set_block(y, x, type, orient);
                                return y;
                        }
                        timeout.tv_sec = 0;
                        timeout.tv_usec = delay[level];
                }
        }
}

int bl_next=0;

/* Plays a single game.
   That is: Drop a block. Test for new lines. Update score.
   Repeat until game over. */
POINTS play_game(int level)
{
        POINTS points;
        POINTS tmp;
        int cur;
        int y;    /* y-cord. of last-placed block. */

        /* Create window used in game. */
        well_win = newwin(WELL_HEIGHT, 2 * WELL_WIDTH, WELL_Y, WELL_X);

        /* Clear and reset. */
        well_data = (unsigned char *)malloc(WELL_HEIGHT * WELL_WIDTH);
        memset(well_data, 0, WELL_HEIGHT * WELL_WIDTH);
        update_screen();
        wclear(well_win);

        bast_init();
        points.points = 0;
        points.lines = 0;
        points.level = level;
				cur=choose_piece();
				
        update_stat(points, bl_next);

        while(1) {
                y = drop_block(cur, points.level);
                if (y >= 0) {
                        tmp = check_lines(y);
                        points.points += (tmp.points + points.level);
                        points.lines += tmp.lines;
                        if (points.lines / 10 > level &&
                            points.lines / 10 < NO_LEVELS)
													points.level = points.lines / 10;
												cur=choose_piece();
												update_stat(points, bl_next);
                } else {
									message("Game over!");
									break;
                }
        }
				
				bast_clear();
        free(well_data);
        delwin(well_win);
				
        return points;
}

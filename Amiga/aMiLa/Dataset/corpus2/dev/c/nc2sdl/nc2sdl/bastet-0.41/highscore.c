/* highscore.c
   Highscore functionality. */

#include <stdio.h>
#include <stdlib.h>
#include <pdcurses/curses.h>
#include <string.h>
#include "bastet.h"
#include "config.h"
#include "highscore.h"
#include "main.h"

#define NAMELEN 11

/* "Highscore entry" type. */
typedef struct _hs_entry {
	        char name[NAMELEN];
	        unsigned int points;
} hs_entry;

/* Array of highscore entries. */
hs_entry hs_list[SIZE_HS_LIST];

int load_highscores()
{
	FILE *file;
	int i;
	size_t items;
	
	if ((file = fopen(HIGHSCORE_FILE, "r")) == NULL) {
		/* Failed opening file, give array sane values. */
		message("Failed to open highscore file. Creating empty list.");
		for (i = 0; i < SIZE_HS_LIST; i++) {
			hs_list[i].name[0] = (char)0;
			hs_list[i].points  = 0;
		}
		return 1;
	}
	
	/* Open ok, read file. */
	items = fread(hs_list, sizeof(hs_entry), SIZE_HS_LIST, file);
	
	/* Fill rest of array if file was too small. */
	for (i = items; i < SIZE_HS_LIST; i++) {
		hs_list[i].name[0] = '\0';
		hs_list[i].points  = 0;
	}

	fclose(file);
	return 1;
}

int save_highscores()
{
	FILE *file;

	if ((file = fopen(HIGHSCORE_FILE, "w")) == NULL) {
		message("Error saving highscore file. Your new highscore entry is lost :-(");
		return 0;
	}
				
	fwrite(hs_list, sizeof(hs_entry), SIZE_HS_LIST, file);
	
	fclose(file);
	return 1;
}

void insert_hs_entry(int index, char *name, unsigned int points)
{
	int i; 

	/* Move entries one position down starting at index. */
	for (i = SIZE_HS_LIST - 1; i > index; i--) {
		strncpy(hs_list[i].name, hs_list[i-1].name,NAMELEN-1);
		hs_list[i].points = hs_list[i-1].points;
	}

	/* Insert new entry. */
	strncpy(hs_list[index].name, name,NAMELEN-1);
	hs_list[index].points = points;
}

int check_highscores(unsigned int points)
{
	int i;
	char *name;

	name = getenv("USER");

	if (NULL == name)
		name = "nobody";
	
	load_highscores();
	
	/* Check for new highscore. */	
	for (i = 0; i < SIZE_HS_LIST; i++)
		if (points >= hs_list[i].points) {
			insert_hs_entry(i, name, points);
			save_highscores();
			return i + 1;
		}
	
	return 0;
}

int view_highscores()
{
	WINDOW *win;
	char *name;
	int i;
	int ch;

	/* Get username */
	name = getenv("USER");

	if (NULL == name)
		name = "nobody";
	
	load_highscores();
	
	/* Place window in the middle of the screen. */
	win = newwin(21, 24,
			LINES / 2 - (10 + SIZE_HS_LIST) / 2, COLS / 2 - 12);
	box(win, 0, 0);
	
	wattrset(win, COLOR_PAIR(COLOR_MSG) | A_BOLD);
	mvwprintw(win, 2, 6, "Highscores:");
	wattroff(win, A_BOLD);
	mvwprintw(win, 4, 2, "%-12sPoints:", "Name:");
	
	/* Print highscore list. */
	wattrset(win, COLOR_PAIR(COLOR_POINTS));
	for (i = 0; i < SIZE_HS_LIST; i++) {
		if (0 == strncmp(hs_list[i].name, name,NAMELEN-1))
			wattron(win, A_BOLD);
		else
			wattroff(win, A_BOLD);
			
		mvwprintw(win, 6 + i, 2, "%-12s%7d",
				hs_list[i].name, hs_list[i].points);
	}
	
	wattrset(win, COLOR_PAIR(COLOR_MSG));
	mvwprintw(win, 6 + SIZE_HS_LIST + 1, 2, "Press q to quit, any");
	mvwprintw(win, 6 + SIZE_HS_LIST + 2, 2, "other key to cont.");

	update_screen();
	wrefresh(win);
	
	nodelay(stdscr, FALSE);
	
	ch = getch();
	if (ch == 'q' || ch == 'Q')
		return 0;
	else
		return 1;
	
	nodelay(stdscr, TRUE);
	delwin(win);
}

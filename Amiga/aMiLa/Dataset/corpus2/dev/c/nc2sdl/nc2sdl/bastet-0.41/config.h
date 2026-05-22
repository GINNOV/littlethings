/* config.h */

#ifndef _CONFIG_H_
#define _CONFIG_H_

/* Control keys. These should be something ncurses understands. */
#define CONTROL_LEFT	KEY_LEFT	/* Move left */
#define CONTROL_RIGHT	KEY_RIGHT	/* Move right */
#define CONTROL_ROT_CW	KEY_UP		/* Rotate clock-wise */
#define CONTROL_ROT_CCW	'0'		/* Rotate counter-clock-wise */
#define CONTROL_DOWN	KEY_DOWN	/* Drop one line*/
#define CONTROL_REFRESH	'r'		/* Refresh screen */
#define CONTROL_DROP    ' '             /* Drop (completely!) piece*/
#define CONTROL_QUIT    'q'             /* Quits game*/
#define CONTROL_PAUSE   'p'             /*pause*/


/* Highscore file. */
//#define HIGHSCORE_FILE	"/var/local/petris/highscores"

/* Number of entries in highscore list. */
#define SIZE_HS_LIST	10

#endif /* _CONFIG_H_ */

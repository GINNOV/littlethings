/* bastet.h
   #defines and data types that are (or can be) usefull in most places. */

#ifndef _PETRIS_H_
#define _PETRIS_H_

/* In term.h is a "#define lines ...". We don't want that one
 * since we use a variable called lines in the POINTS struct.
 * Also, the number of terminal line may be accessed as LINES. */
#ifdef lines
#undef lines
#endif

/* Different colors for different things. */
#define COLOR_POINTS	17
#define COLOR_LINES	18
#define COLOR_LEVEL	19
#define COLOR_MSG	20

/* We will set the coordinates / sizes of different elements
   dynamically. To avoid a big mess we put all this in a struct.
   NOTE: There should only be _one_ instance of this struct: coords,
   which is defined and initialized in main.c */
typedef struct _coords {                              
	int well_x;                                           
	int well_y;                                                 
	int well_width;                                      
	int well_height;
	int stat_x;
	int stat_y;
	int stat_width;
} COORDS;

/* Make the one and only instance, coords, extern so everyone can
   use and love it. */
extern COORDS coords;

/* Macros for easy reference to the members of the coords struct. */
#define WELL_X          coords.well_x
#define WELL_Y          coords.well_y
#define WELL_HEIGHT     coords.well_height
#define WELL_WIDTH      coords.well_width
#define STAT_Y          coords.stat_y
#define STAT_X          coords.stat_x
#define STAT_WIDTH      coords.stat_width

#define NO_LEVELS	10 	/* Level 0 - 9 */

/* Make it easy to pass points, lines and level around as a whole. */
typedef struct _points {
	unsigned int points;
	unsigned char lines;
	unsigned char level;
} POINTS;

#endif /* _PETRIS_H_ */

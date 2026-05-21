/*
 * All the module parameters for Phantom Fighter are or should be in this
 * file for ease of location to the untrained eye.
 *
 */
 

#ifndef GAMEPARAM_H

#define GAMEPARAM_H

/* Numof Segments in Hangar Big guy */
#define NUMSEGHANGER 8

/* Number of aliens loaded */
#define NUMALIENSHAPES 7

/* Number of 12 dir patterns */
#define NUM12PAT 4
#define MAXPATTERNS 11

/* Number of ticks between scrolling backdrop one pixel */
#define SCROLLTICKS 3

/* Move rate for alien missiles */
#define AMISSILERATE 2

/* Move rate for bigguy missiles */
#define BMISSILERATE 3

/* Number of Bullets to allocate BUL_Missiles for */
#define MAXBULLETS 40

/* Number of Tokens block to allow for */
#define MAXTOKEN 8

/* Number of explosions to allow for */
#define MAXEXPLOSIONS 30

/* Number of big guys to allow for */
#define MAXBIGGUYS 4

/* Number of DLEs to allocate */
#define MAXDLE 100

/* Number of COLs to allocate */
#define MAXCOL 50

/* Number of EQE's to allocate */
#define MAXEVENTS 150

/* Max number of waves of aliens onscreen */
#define MAXWAVES 15

/* Max number of alien onscreen ever */
#define MAXALIENS 15

/* Max number of baby bugs */
#define MAXBABYBUGS 12

/* MAx number of Squeeze bugs */
#define MAXSQUEEZEBUGS 5

/* Num channels allowed for sound effects */
#define NUMCHANNELS 1

/* Num Eyes Active on Screen */
#define NUMEYES 32
#endif

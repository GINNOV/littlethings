#ifndef DEFINE_HEADER
#define DEFINE_HEADER

#define DIM_H	800
#define DIM_V	600
#define BUTTON_SX 1
#define BUTTON_DX 3

#define CELL_SIDE 40
#define NUM_ROWS (DIM_V - CELL_SIDE) / CELL_SIDE
#define NUM_COLS (DIM_H - CELL_SIDE) / CELL_SIDE

#define GRIND_X CELL_SIDE/2
#define GRIND_Y CELL_SIDE/2

#define ROBOT_DIST 10
#define ROBOT_SPEED 2

#define WALK_COST 10

#define MAX_GEN_NODES 4
	
#endif

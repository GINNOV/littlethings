#ifndef PATHFIND_HEADER
#define PATHFIND_HEADER

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <SDL/SDL.h>
#include "define.h"
#include "graphic.h"
#include "grind.h"
#include "struct.h"

/* 	
  	F = G + H
	G = previous movement cost
	H = euristic future movement cost
*/


using namespace std;

typedef struct list_node 
{
	int row;
	int col;
	int f;
	int g;
	int h;
	struct list_node *next;
	struct list_node *father;
} l_node;

int pathfind(int map[][NUM_COLS], cell_indexes start, cell_indexes end, cell_ind * *path);
int gen_nodes(cell_ind center, cell_ind * *gen);
int manhattan(cell_ind n, cell_ind dest);
void insert_node(l_node * *list, l_node * node);
void insert_head_node(l_node * *list, l_node * node);
l_node * get_node(l_node * list, cell_ind node);
l_node * extract_head(l_node * *list);
void sort_node(l_node * *list, l_node * node);
void del_list(l_node * *list);

#endif

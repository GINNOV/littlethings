#include "pathfind.h"

//this function calculates a pathfind from start to end cells using A* algorithm 
//based on "manhattan distance" heuristic
int pathfind(int map[][NUM_COLS], cell_indexes start, cell_indexes end, cell_ind * *path)
{
	//start or end not walkable or start == end
	if(!map[start.row][start.col] || !map[end.row][end.col] 
	|| start.row == end.row && start.col == end.col)
		return 0;
	
	//A* listes
	l_node * open = NULL;
	l_node * closed = NULL;
	//current node
	l_node * cur = NULL;
	//generated node
	l_node * gen = NULL;
	//node already present into OPEN list
	l_node * already_ins = NULL;
	//travel node
	l_node * trav = NULL;

	//node extracted from OPEN
	cell_ind cur_ind;
	//expanded nodes
	cell_ind * exp;
	//management cell_ind
	cell_ind temp;
	
	//init first node 
	l_node * first = (l_node *)malloc(sizeof(l_node));
	first->row = start.row; 
	first->col = start.col;
	first->f = 0;
	first->g = 0;
	first->h = 0;
	first->next = NULL;
	first->father = NULL;

	//add first node to OPEN
	insert_node(&open,first);

	//local counter 
	int i;
	//nodes expanded at every cycle
	int num_exp_nodes = 0;

	//found a path
	bool found = false;

	//go on until found a path or open is empty
	while(!found && open) 
	{
		//extract the node with lowest f value
		cur = extract_head(&open);
		cur_ind.row = cur->row;
		cur_ind.col = cur->col;

		//expand nodes from the current obtaining cell indexes
		num_exp_nodes = gen_nodes(cur_ind,&exp);

		//insert current into CLOSED list
		insert_head_node(&closed,cur);
		
		//manage expanded nodes
		for(i = 0; i < num_exp_nodes; i++) 
		{
			temp.row = (exp+i)->row;
			temp.col = (exp+i)->col;
				
			//walkable node & not yet into CLOSED (not yet analized)
			if(map[temp.row][temp.col] && get_node(closed,temp) == NULL)
			{
				//check if temp is already into OPEN
				already_ins = get_node(open,temp);
				
				//generated node is not yet into OPEN
				if(already_ins == NULL)
				{
					gen = (l_node *)malloc(sizeof(l_node));
					gen->row = temp.row;
					gen->col = temp.col;
					gen->g = cur->g + WALK_COST; 
					gen->h = manhattan(temp,end);
					gen->f = gen->g + gen->h;
					gen->father = cur;

					//insert generated node into OPEN
					insert_node(&open,gen);

					// h(n)= 0 ==> END NODE!!! get out!
					if(!gen->h)
					{
						found = true;
						break;
					}
				}
				//found a better path
				else if(already_ins->g > (cur->g + WALK_COST))
				{
					//recalculate node fields
					already_ins->row = temp.row;
					already_ins->col = temp.col;
					already_ins->g = cur->g + WALK_COST;
					already_ins->h = manhattan(temp,end);
					already_ins->f = already_ins->g + already_ins->h;
					//resort updated node
					sort_node(&open,already_ins);
				}
			}
		}
		//free expanded cell_ind
		free(exp);
	}

	//no path found... it's a defeat :(
	if(!found)
	{
		//free open & closed lists
		del_list(&open);
		del_list(&closed);

		return 0;
	}

	//calculate path length
	int	len_path = ((gen->g)/WALK_COST) + 1;
	int len_bk = len_path;

	//allocate memory for path
	*path = (cell_ind *)malloc(sizeof(cell_ind)*len_path);

	//fill path array with data from nodes
	trav = gen;
	while(trav != NULL) 
	{
		len_path--;
		((*path)+len_path)->row = trav->row;
		((*path)+len_path)->col = trav->col;
		trav = trav->father;
	}
	
	//free open & closed lists
	del_list(&open);
	del_list(&closed);

	return len_bk;
}

//this function expands nodes from a initial one
int gen_nodes(cell_ind center, cell_ind * *gen)
{
	int num_nodes = MAX_GEN_NODES;
	int c = 0;
	
	*gen = (cell_ind *)malloc(sizeof(cell_ind)*num_nodes);
	
	//initial node is on first or last row
	if(!center.row || center.row == NUM_ROWS)	
		num_nodes--;
	//initial node is on first or last col
	if(!center.col || center.col == NUM_COLS)
		num_nodes--;
	
	//row > 0 => upper cell IN
	if(center.row)
	{
		(*gen)[c].row = center.row - 1;
		(*gen)[c].col = center.col; 

		c++;
	}

	//col < NUM_COLS-1 => right cell IN
	if(center.col < (NUM_COLS - 1))
	{
		(*gen)[c].row = center.row;
		(*gen)[c].col = center.col + 1; 
		
		c++;
	}
	
	//row < NUM_ROWS-1 => bottom cell IN
	if(center.row < (NUM_ROWS - 1))
	{
		(*gen)[c].row = center.row + 1;
		(*gen)[c].col = center.col; 
		
		c++;
	}

	//col > 0 => left cell IN
	if(center.col)
	{
		(*gen)[c].row = center.row;
		(*gen)[c].col = center.col - 1; 
		
		c++;
	}

	return c;
}

//this function calculates the "manhattan distance" between two cells 
//just the orthogonal distance ;)
int manhattan(cell_ind n, cell_ind dest)
{
	return WALK_COST * (abs(n.row-dest.row) + abs(n.col-dest.col));
}

//this function inserts node into a list of l_node ordering it by f and
//then by g values (for equal f nodes)
void insert_node(l_node * *list, l_node * node)
{
	l_node * trav = *list;
	
	//new first node
	if(trav == NULL || trav->f > node->f)
	{
		node->next = trav;
		*list = node;
		return ;
	}

	while(trav->next != NULL)
	{
		//middle insertion
		if((trav->next->f >= node->f))		
		{
			//move on for equal f value
			while(trav->next->f == node->f && trav->next->g < node->g)
			{
				trav = trav->next;

				if(trav->next == NULL)
						break;
			}
			
			node->next = trav->next;
			trav->next = node;

			return ;
		}

		trav = trav->next;
	}

	//new last node
	node->next = NULL;
	trav->next = node;
}

//this function insert a node as head of a list of l_node  
void insert_head_node(l_node * *list, l_node * node)
{
	//new first node
	node->next = *list;
	*list = node;
}

//this function looks for a node into a list 
l_node * get_node(l_node * list, cell_ind node)
{
	//empy list
	if(list == NULL)
		return NULL;

	//movin on!
	while(list->next != NULL)
	{
		if(list->row == node.row && list->col == node.col)
			return list;

		list = list->next;
	}

	return NULL;
}

//this function extract the first node from a list
l_node * extract_head(l_node * *list)
{
	l_node * head = *list;
	
	//empy list
	if(list == NULL)
		return NULL;
	
	*list = (*list)->next;

	return head;
}

//this function sort a node into a list according f and then g values
void sort_node(l_node * *list, l_node * node)
{
	l_node * trav = *list;
	
	//look for the predecessor of node
	while(trav->next != node && trav->next != NULL)
		trav = trav->next;
	
	//connect previous and next nodes
	trav->next = node->next;

	//reinsert the node to obtain the right order
	insert_node(list,node);
}

//this function deallocate all elements of a list of l_node
void del_list(l_node * *list)
{
	l_node * trav;

	//move along list and free elements
	while(*list)
	{
		trav = *list;
		*list = (*list)->next;
		free(trav);
	}
}

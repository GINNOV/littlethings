/*
 * vtktest.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vistk.h"

int done = 0;
int rebuild = 1;
int seed = 1;
vtk_object_t *root = 0;
char buf[256];


static VTK_H(eh_keytrapper)
  case viseKeyDown:
  case viseKeyRepeat:
  {
	vtk_object_t *o;
	printf("KeyDown %d came back to display Root.\n",event->data.key.unicode);
	switch(event->data.key.control)
	{
	  case VTKC_ESCAPE:
		done = 1;
		break;
	  case VTKC_UP:
		o = root->children;
		while(o)
		{
			++o->rect.w;
			++o->rect.h;
			o = o->next;
		}
		break;
	  case VTKC_DOWN:
		o = root->children;
		while(o)
		{
			--o->rect.w;
			--o->rect.h;
			o = o->next;
		}
		break;
	  case VTKC_LEFT:
		seed--;
	  	srand(seed);
		rebuild = 1;
		break;
	  case VTKC_RIGHT:
	  case VTKC_ENTER:
		seed++;
	  	srand(seed);
		rebuild = 1;
		break;
	  default:
		switch(event->data.key.unicode)
		{
		  case ' ':
			seed = 1;
		  	srand(seed);
			rebuild = 1;
			break;
		}
	}
  }
VTK_ENDH

static VTK_H(eh_button)
  case viseButtonUp:
	printf("Button %d received a ButtonUp.\n",object->tag);
  	break;
  case viseButtonDown:
	printf("Button %d received a ButtonDown.\n",object->tag);
  	break;
  case viseKeyDown:
  case viseKeyRepeat:
  case viseKeyUp:
	printf("Button %d received a key.\n",object->tag);
  	break;
VTK_ENDH

static VTK_H(eh_exit)
  case viseButtonUp:
	done = 1;
  	break;
VTK_ENDH


int main(int argc, char *argv[])
{
	int i;
	int tag = 0;
	vis_visual_t *vis;
	vtk_object_t *o, *win;

	if(!(vis = vis_open(640, 480, 0)))
		exit(1);

	vis_cls(vis);

	done = 0;
	while(!done)
	{
		if(rebuild)
		{
			vtk_free(root);
			root = vtk_new_root(vis, vis->rect);
			if(!root)
				exit(2);
			root->tag = tag++;
			root->event_handler = eh_keytrapper;
			o = vtk_new(root, vis_rect(0,0,32,16), vtkoButton);
			if(!o)
				exit(5);
			o->tag = tag++;
			o->event_handler = eh_exit;
			o->value.text = "EXIT";

//			win = vtk_new_window(root, vis_rect(64,50,512,360));
			win = vtk_new(root, vis_rect(64,50,512,100), vtkoPanel);
			if(!win)
				exit(3);
			win->tag = tag++;
//			win = win->children;
			for(i=0; i<5; ++i)
			{
				o = vtk_new(win, vis_rect(3+i*27,3,27,16), vtkoButton);
				if(!o)
					exit(4);
				o->tag = tag++;
				o->event_handler = eh_button;
				o->value.text = "BTN";
			}

			o = vtk_new(win, vis_rect(300,10,60,40), vtkoButton);
			if(!o)
				exit(100);
			o->tag = tag++;
			o->event_handler = eh_button;
			o->value.text = "Silliest";
			o = vtk_new(win, vis_rect(310,20,60,40), vtkoButton);
			if(!o)
				exit(100);
			o->tag = tag++;
			o->event_handler = eh_button;
			o->value.text = "Sillier";
			o = vtk_new(win, vis_rect(320,30,60,40), vtkoButton);
			if(!o)
				exit(100);
			o->tag = tag++;
			o->event_handler = eh_button;
			o->value.text = "Silly";
			o = vtk_new(win, vis_rect(330,40,60,40), vtkoButton);
			if(!o)
				exit(100);
			o->tag = tag++;
			o->event_handler = eh_button;
			o->value.text = "Front";

			o = vtk_new(win, vis_rect(3,3+3+15,200,16), vtkoEditor);
			if(!o)
				exit(6);
			o->tag = tag++;
			o->event_handler = vtk_eh_editor;
			o->value.text = buf;
			o->value.size = sizeof(buf);

			win = vtk_new(root, vis_rect(50,200,300,50), vtkoPanel);
			if(!win)
				exit(3);
			win->tag = tag++;
			for(i=0; i<5; ++i)
			{
				o = vtk_new(win, vis_rect(3+i*50,3,50,16), vtkoDisplay);
				if(!o)
					exit(4);
				o->tag = tag++;
				o->event_handler = eh_button;
				o->value.text = "DISPLAY";
			}
			rebuild = 0;
		}
		vtk_rethink(root);
		vtk_render(root);
		vis_refresh(vis);
		vtk_wait_event(root, -1);
		vtk_process_events(root);
	}
	vtk_free(root);

	vis_close(vis);
	exit(0);
}

/*
 * gfxtest.c
 */

#include <stdlib.h>

#include "visualize.h"
#include "sgfx.h"

int main(int argc, char *argv[])
{
	vis_visual_t *root_vis, *vis;
	int update = 0;
	int done;
	int x=2,y=2,x2=15,y2=10;

	if(!(root_vis=vis_open(640, 480, VIS_FULLSCREEN)))
		exit(1);

	if( !(vis=vis_open_window(root_vis, vis_rect(64,50,512,360))) )
		exit(2);


	root_vis->context->pen.bgcolor = VISCL_GRAY25;
	sg_cls(root_vis->context);
	root_vis->context->pen.bgcolor = VISCL_BLACK;

	update = 1;
	done = 0;
	while(!done)
	{
		vis_event_t ev;

		if(update)
		{
			sg_cls(vis->context);	/* Clear buffer only */
			vis->context->pen.fgcolor = VISCL_RED;
			sg_locate(vis->context,x<<4,y<<4);
			sg_line(vis->context,(x+x2)<<3,(y+y2)<<3);
			vis->context->pen.fgcolor = VISCL_BLUE;
			sg_line(vis->context,x2<<4,y2<<4);
			vis_refresh(root_vis);
			update = 0;
		}

		while(vis_get_event(vis, &ev, 10))
		{
			if(ev.kind != viseKeyDown)
				continue;
			switch(ev.data.key.unicode)
			{
			  case 27:
				done = 1;
				break;
			  case ' ': update=1; break;
			  case 'e': --x; goto aoeu;
			  case 'i': ++x; goto aoeu;
			  case 'p': --y; goto aoeu;
			  case 'u': ++y; goto aoeu;
			  case 'd': --x2; goto aoeu;
			  case 't': ++x2; goto aoeu;
			  case 'g': --y2; goto aoeu;
			  case 'h': ++y2; goto aoeu;
			  aoeu:
				update = 1;
				break;
			}
		}
	}

	vis_close(vis);
	vis_close(root_vis);
	exit(0);
}

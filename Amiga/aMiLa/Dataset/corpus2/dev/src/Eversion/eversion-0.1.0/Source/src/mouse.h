#ifndef EVERSION__MOUSE_H
# define EVERSION__MOUSE_H

////////////////////////////////////////////////////////////////////////////////


// INCLUDES ////////////////////////////////////////////////////////////////////

# include <SDL/SDL.h>
# include "input_device.h"
# include "types.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {
	namespace io_device {

// CLASSES /////////////////////////////////////////////////////////////////////

class mouse : public input_device
{
public:
	mouse();
	~mouse();

	void update();

	bool button_pressed(u8 button) { return (mouseState&SDL_BUTTON(button)) != 0; }
	void get_pos(int& x, int &y) { x=pos_x; y=pos_y; }
	void get_mov(int& x, int &y) { x=mov_x; y=mov_y; }
	void warp(int x, int y) { ::SDL_WarpMouse((u16)x, (u16)y); pos_x=x; pos_y=y; }

private:
	u8 mouseState;
	//bool update_rel;

	int pos_x, pos_y;
	int mov_x, mov_y;
};

////////////////////////////////////////////////////////////////////////////////

	}
}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__MOUSE_H

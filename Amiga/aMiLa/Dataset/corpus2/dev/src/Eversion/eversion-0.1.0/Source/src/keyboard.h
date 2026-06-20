#ifndef EVERSION__KEYBOARD_H
# define EVERSION__KEYBOARD_H

////////////////////////////////////////////////////////////////////////////////


// INCLUDES ////////////////////////////////////////////////////////////////////

# include <SDL/SDL.h>
# include "control_device.h"
# include "types.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {
	namespace io_device {

// CLASSES /////////////////////////////////////////////////////////////////////

class keyboard : public control_device
{
public:
	keyboard();
	~keyboard();

	void update() { keyBuffer = ::SDL_GetKeyState(NULL); }

	bool key_pressed(SDLKey key) { return keyBuffer[key]?true:false; }
	void unpress_key(SDLKey key) { keyBuffer[key]=false; }

	bool key_pressed(control_device::button_t button) { return key_pressed( buttons[button] ); }
	void unpress_key(control_device::button_t button) { unpress_key( buttons[button] ); }

private:
	u8* keyBuffer;
};

////////////////////////////////////////////////////////////////////////////////

	}
}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__KEYBOARD_H

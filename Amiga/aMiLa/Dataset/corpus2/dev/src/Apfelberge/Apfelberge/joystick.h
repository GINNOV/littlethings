/* CC65's new joystick API */

#ifndef _JOYSTICK_H
#define _JOYSTICK_H

#define __JOYSTICK__
#ifndef __SASC
#include <proto/exec.h>
struct Library *LowLevelBase;
#endif
#include <proto/lowlevel.h>
enum {JOY_ERR_OK, JOY_ERR_NO_DRIVER, JOY_ERR_CANNOT_LOAD, JOY_ERR_INV_DRIVER, JOY_ERR_NO_DEVICE};
enum {JOY_1, JOY_2};
#define JOY_BTN_UP(v)		((v) & JPF_JOY_UP)
#define JOY_BTN_DOWN(v)		((v) & JPF_JOY_DOWN)
#define JOY_BTN_LEFT(v)		((v) & JPF_JOY_LEFT)
#define JOY_BTN_RIGHT(v)	((v) & JPF_JOY_RIGHT)
#define JOY_BTN_FIRE(v)		((v) & JPF_BUTTON_RED)

const char joy_stddrv[]="";

__inline char joy_load_driver(const char *driver)
{
#ifndef __SASC
LowLevelBase=OldOpenLibrary("lowlevel.library");
#endif
return driver=="" ? JOY_ERR_OK : JOY_ERR_NO_DRIVER;
}

__inline char joy_count(void)
{
return 2;
}

__inline joy_read(char port)
{
return (int) ReadJoyPort(port);
}

__inline void joy_unload(void)
{
#ifndef __SASC
CloseLibrary(LowLevelBase);
#endif
}

#endif

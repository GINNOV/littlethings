/*
------------------------------------------------------------
   control.h - Visualize toolkit control symbols
------------------------------------------------------------
 * © David Olofson, 2001
 *
 * This code is released under the terms of the LGPL.
 *
 * VTK control symbols resemble the keyboard scan codes of
 * other toolkits. However, they're not strictly bound to
 * the keyboard, but may be the result of other input, such
 * as mouse clicks in certain locations, or joystick input.
 *
 * VTK control symbols are delivered as keyboard event,
 * along with the corresponding ASCII character, if one
 * exists. This means that both the ASCII code and the
 * control symbol well be available in the same event,
 * whenever applicable, which is andy when it's desirable
 * that mode affects how keyboard input is interpreted.
 */

#ifndef _VTK_CONTROL_H_
#define _VTK_CONTROL_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
	VTKC_NONE	= 0,

	/* Editing */
	VTKC_BACKSPACE,
	VTKC_DELETE,
	VTKC_INSERT,
	VTKC_CLEAR,
	VTKC_ENTER,
	VTKC_ESCAPE,

	/* Global control */
	VTKC_PAUSE,
	VTKC_HELP,
	VTKC_PRINT,
	VTKC_SYSREQ,
	VTKC_BREAK,
	VTKC_MENU,

	/* Navigation */
	VTKC_UP,	/* Arrow keys */
	VTKC_DOWN,
	VTKC_RIGHT,
	VTKC_LEFT,
	VTKC_RETREAT,	/* Shift + Tab */
	VTKC_ADVANCE,	/* Tab */
	VTKC_HOME,	/* Home */
	VTKC_END,	/* End */
	VTKC_PREV,	/* Page Up */
	VTKC_NEXT,	/* Page Down */
	VTKC_FIRST,	/* Shift + Page Up */
	VTKC_LAST,	/* Shift + Page Down */

	/*
	 * Function keys
	 * Note: These will *not* wrap if there are
	 *       less than 15 physical function keys.
	 *       Modifiers don't affect which of
	 *       these codes the application gets.
	 */
	VTKC_F1,
	VTKC_F2,
	VTKC_F3,
	VTKC_F4,
	VTKC_F5,
	VTKC_F6,
	VTKC_F7,
	VTKC_F8,
	VTKC_F9,
	VTKC_F10,
	VTKC_F11,
	VTKC_F12,
	VTKC_F13,
	VTKC_F14,
	VTKC_F15
} vtk_control_t;


/* Control modifiers */
#define	VTKCM_SCROLLOCK	0x0001
#define	VTKCM_SHIFT	0x0002
#define	VTKCM_CTRL	0x0004
#define	VTKCM_ALT	0x0008
#define	VTKCM_META	0x0010
#define	VTKCM_SUPER	0x0020
#define	VTKCM_MODE	0x0040

#ifdef __cplusplus
};
#endif

#endif /* _VTK_KEYSYM_H_ */

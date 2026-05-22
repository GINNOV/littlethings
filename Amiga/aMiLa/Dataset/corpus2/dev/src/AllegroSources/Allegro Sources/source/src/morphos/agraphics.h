/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS graphics driver.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#ifndef AGRAPHICS_H
#define AGRAPHICS_H

/* Variables exported from graphics.c */

extern struct AmiThread gGraphicsThread;
extern struct Window *gMainWindow;

extern void system_set_window_title(const char *aTitle);

extern int system_set_close_button_callback(void (*aCloseButtonCallback)());

#endif /* ! AGRAPHICS_H */

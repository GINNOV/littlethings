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
 *      Amiga OS mouse module.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#ifndef AMOUSE_H
#define AMOUSE_H

/* Variable exported from graphics.c */

extern int gCustomMouse;

void mouse_handle_buttons(int aCode);

void mouse_handle_move(int aX, int aY);

void mouse_handle_wheel(int aZ);

void mouse_set_hardware_imagery(int aX, int aY);

#endif /* ! AMOUSE_H */

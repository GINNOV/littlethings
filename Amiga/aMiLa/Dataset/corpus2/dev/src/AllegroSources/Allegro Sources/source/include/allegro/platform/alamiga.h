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
 *      Amiga OS specific driver definitions.
 *
 *      By René W. Olsen and Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#ifndef ALAMIGA_H
#define ALAMIGA_H

// TODO: CAW - Can I use pack_igetl() instead of this?  Why is it called AL_ITON()?
#define AL_ITON(dest, source) \
	dest = (((source & 0xff) << 24) | ((source & 0xff00) << 8) | ((source & 0xff0000) >> 8) | (source >> 24))

/* Function to get the version of the Amiga shared object, for checking that it is new enough */

unsigned int al_get_sobj_version();

#define AL_CURR_SOBJ_VERSION 0x010001

/* =========================================== */
/* ============= system drivers ============== */
/* =========================================== */
#define SYSTEM_AMIGA          AL_ID('A','M','O','S')

/* =========================================== */
/* ============ keyboard drivers ============= */
/* =========================================== */
#define KEYBOARD_AMIGA       AL_ID('A','M','K','B')

/* =========================================== */
/* ============= mouse drivers =============== */
/* =========================================== */
#define MOUSE_AMIGA          AL_ID('A','M','M','S')

/* =========================================== */
/* =============== gfx drivers =============== */
/* =========================================== */
#define GFX_AMIGA_FULLSCREEN AL_ID('A','M','G','F')
#define GFX_AMIGA_WINDOWED   AL_ID('A','M','G','W')

/* ============================================ */
/* =============== sound drivers ============== */
/* ============================================ */
#define DIGI_AMIGA           AL_ID('A','M','D','G')

/* =========================================== */
/* ============= timer drivers =============== */
/* =========================================== */
#define TIMER_AMIGA          AL_ID('A','M','T','M')

/* =========================================== */
/* ============ joystick drivers ============= */
/* =========================================== */
#define JOYSTICK_AMIGA       AL_ID('A','M','J','Y')

#endif /* ! ALAMIGA_H */

/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 10/24/2005
 *---------------------------------------------------------------------
 * Copyright (c) 2005 BITbyBIT Software Group, All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * BITbyBIT Software Group (Confidential Information).  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with BITbyBIT Software Group.
 *
 * BITbyBIT SOFTWARE GROUP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
 * SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * BITbyBIT Software Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 * Project: AVD_Template
 *
 * OS Specific Data and Functions (os_gui.h)
 *
 * $VER: os_gui.h 1.0
 * 
 */
 
#ifndef __OS_GUI_H__
#define __OS_GUI_H__

#include <classes/arexx.h>
#include <classes/popupmenu.h>
#include <classes/requester.h>
#include <classes/window.h>

#include <gadgets/button.h>
#include <gadgets/checkbox.h>
#include <gadgets/chooser.h>
#include <gadgets/clicktab.h>
#include <gadgets/colorwheel.h>
#include <gadgets/datebrowser.h>
#include <gadgets/fuelgauge.h>
#include <gadgets/getfile.h>
#include <gadgets/getfont.h>
#include <gadgets/getscreenmode.h>
#include <gadgets/gradientslider.h>
#include <gadgets/integer.h>
#include <gadgets/layout.h>
#include <gadgets/listbrowser.h>
#include <gadgets/page.h>
#include <gadgets/palette.h>
#include <gadgets/partition.h>
#include <gadgets/radiobutton.h>
#include <gadgets/scroller.h>
#include <gadgets/sketchboard.h>
#include <gadgets/slider.h>
#include <gadgets/space.h>
#include <gadgets/speedbar.h>
#include <gadgets/string.h>
#include <gadgets/tapedeck.h>
#include <gadgets/texteditor.h>
#include <gadgets/virtual.h>

#include <images/bevel.h>
#include <images/bitmap.h>
#include <images/drawlist.h>
#include <images/filler.h>
#include <images/glyph.h>
#include <images/label.h>
#include <images/penmap.h>

#include <reaction/reaction.h> /* Building with -DALL_REACTION_CLASSES */
#include <reaction/reaction_macros.h>

/* Quite handy Reaction "Add Space" macro statement */
#define SPACE LAYOUT_AddChild, SpaceObject, End

/*
 * This enum generates the unique ID's we need both for 
 * GadgetID's as well as for the index into our objects
 * array. You might want to use separate variables or
 * use this method.
 *
 * Note that not all objects need an id, and not all
 * objects need to be stored (Layout groups for example).
 * Essentially only store object pointers that you need
 * to manipulate from your program.
 */

/* This value provides a starting point for the auto-generated GUI Objects */
enum OBJ_User_IDs
{
	/* Place any object IDs for MANUALLY created objects here that you want included in Object Array */
	OBJ_USER_TOTAL
};

/*AVD_START_HERE
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This section of the file is automatically read and updated at build time,
 * do not make any changes or add anything between here and the 'AVD_END_HERE'
 * header, or the end of this file if no 'END'ing header is found.
 ************************* DO NOT EDIT THIS HEADER *************************
 */
enum GUI_Objects_IDs
{
	OBJ1_WINDOW = OBJ_USER_TOTAL,
	OBJ3_BUTTON,
	OBJ5_BUTTON,
	OBJ6_BUTTON,
	OBJ_NUM
};
/*
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This completes this reserved section of the file.
 * You are free to modify or add any custom code from this point.
 ************************* DO NOT EDIT THIS HEADER *************************
 AVD_END_HERE*/

#endif  /* End of __OS_GUI_H__ */

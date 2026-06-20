**********************************************
* The AVD Template Project v1.2.0.0 (11/18/2005)
*
* Copyright (c)2005 by BITbyBIT Software Group LLC,
* All Rights Reserved.
*
**********************************************

LICENSE TO USE:
---------------
See the LICENSE.txt file distributed with this archive.

INSTALLING The Source
---------------------
Simply unpack the archive to any directory or path.

The contents of the archive should unpack as follows:

include          (Global includes for every project based on the Template)
AVD_Template     (The Actual application source tree)
README_FIRST.txt
increment_version.amigaos4-ppc
increment_version.linux-i386

First, copy the version of the "increment_version" program
you need for this system to somewhere in your path and rename
it to simply "increment_version". So, if you are compiling
on the AmigaONE directory, you need the "increment_version.amigaos4-ppc"
version. In this case SDK:Local/C in a good place for this file:

copy increment_version.amigaos4-ppc TO SDK:Local/C/increment_version

Once you have unpacked the archive, you should make
a duplicate copy of the AVD_Template directory in the
same path like this:

copy AVD_Template TO MyFirstProject CLONE ALL

Your working directory should now look like this:

include
AVD_Template
MyFirstProject
README_FIRST.txt

Now you are ready to build your first working AmigaOS4 application.

cd MyFirstProject/amigaos4/make
make

If all went well you should now have a bunch of object files (*.o)
and an executable program called "avd_template".

You can go ahead and run the program now like so:

avd_template

or

avd_template --help


RENAMING your project
---------------------
Once you've run this basic app, you'll probably want
to change the name being displayed in title bar and
such and make this project your own. This is as easy
as a couple of renamed files are some quick search and
replace of "avd_template" for your project name:

First off (still assuming we are working in the new project dir - MyFirstProject),
rename the two main project files like so:

cd MyFirstProject/common
rename avd_template.c TO myfirstproject.c
rename avd_template.h TO myfirstproject.h


Now edit your newly renamed "myfirstproject.c" and change the
include of it's main header file (now myfirstproject.h):

MyFirstProject/common/myfirstproject.c (BEFORE)
-----------------------------------------------
/* Include project header file */
#include "avd_template.h"   <----- HERE

MyFirstProject/common/myfirstproject.c (AFTER)
----------------------------------------------
/* Include project header file */
#include "myfirstproject.h"   <----- HERE


Next edit the Makefile under amigaos4/make/ and replace all instances
of "avd_template" with "myfirstproject". You should find 4 cases right
in the top of the file:

MyFirstProject/amigaos4/make/Makefile (BEFORE)
----------------------------------------------
all: avd_template   <----- HERE

#-------------------------------------------------------------------
# Define the Project name and objects to be built here
#
PROJECTNAME       = avd_template   <----- HERE
PROJECTNAME_DEBUG = $(PROJECTNAME)_debug
PROJECT_SRC       = $(CMN_PROJECTSRC)avd_template.c   <----- HERE
PROJECT_H         = $(CMN_PROJECTSRC)avd_template.h   <----- HERE

MyFirstProject/amigaos4/make/Makefile (AFTER)
---------------------------------------------
all: myfirstproject   <----- HERE

#-------------------------------------------------------------------
# Define the Project name and objects to be built here
#
PROJECTNAME       = myfirstproject   <----- HERE
PROJECTNAME_DEBUG = $(PROJECTNAME)_debug
PROJECT_SRC       = $(CMN_PROJECTSRC)myfirstproject.c   <----- HERE
PROJECT_H         = $(CMN_PROJECTSRC)myfirstproject.h   <----- HERE


Now, with the source files renamed and the Makefile fixed up to match,
you can go into the avd_ver.h file and update the version defines:

NOTE: The AVD Template now provides automatic version number updating,
      So it is no longer necessary to manually edit the version numbers
      in this file (avd_ver.h) when making your builds. The version
      numbers are bumped automatically every time the Make file runs
      the "increment_version" tool on this file. Increment_Version
      reads in and then rewrites the bottom of this file. So it's
      important not to make editing changes below the marked section.

MyFirstProject/common/include/avd_ver.h (BEFORE)
------------------------------------------------
#define COMPANY_NAME "BITbyBIT Software Group"   <----- EDIT HERE
#define PRODUCT_NAME "avd_template"              <----- EDIT HERE
#define PRODUCT_TITLE "AVD Template"             <----- EDIT HERE
#define PRODUCT_DESCRIPTION "AVD_TEMPLATE provides a standardized rapid development path for writing applications."    <----- EDIT HERE
#define COPYRIGHT "Copyright 2005 BITbyBIT Software Group"    <----- EDIT HERE

/*
 * This section of the file is automatically read and updated at build time,
 * do not touch or put anything else at the end of this file.
 */
#define PRODUCT_VER "0.0.0.0"
#define VER_MAJOR 0
#define VER_MINOR 0
#define VER_MAINTENANCE 0
#define VER_BUILD 0


MyFirstProject/common/include/avd_ver.h (AFTER)
-----------------------------------------------
#define COMPANY_NAME "My Cool Software Company!" <----- AFTER YOUR EDITS
#define PRODUCT_NAME "myfirstproject"            <----- AFTER YOUR EDITS
#define PRODUCT_TITLE "My First Project"         <----- AFTER YOUR EDITS
#define PRODUCT_DESCRIPTION "MY FIRST PROJECT Lets me have fun programming quickly! :)."   <----- AFTER YOUR EDITS
#define COPYRIGHT "Copyright 2005 My Cool Software"   <----- AFTER YOUR EDITS

/*
 * This section of the file is automatically read and updated at build time,
 * do not touch or put anything else at the end of this file.
 */
#define PRODUCT_VER "0.0.0.0"
#define VER_MAJOR 0
#define VER_MINOR 0
#define VER_MAINTENANCE 0
#define VER_BUILD 0


Finally, we edit the Operating Specific main header file (os_main.h).
Here we find such strings as the title from our window and icon:

NOTE that WINTITLE and VERSION_STRING are constructed using defines
picked up from avd_ver.h. This is also part of the automatic versioning
system.

MyFirstProject/amigaos4/include/os_main.h (BEFORE)
--------------------------------------------------
/* Window Title String (Constant and Global Pointer) */
#define WINTITLE "AVD Template v" PRODUCT_VER " ©2005 BITbyBIT Software Group LLC"   <----- EDIT HERE
#define VERSION_STRING "$VER:" WINTITLE
#define MAX_WINTITLE_LENGTH 80
#define MAX_POPKEY_LENGTH 128
#define MAX_HIDEKEY_LENGTH 128
#define DEFAULT_ICONTITLE_STR "AVD_Template"   <----- EDIT HERE
#define DEFAULT_POPKEY_STR    "f1"
#define DEFAULT_HIDEKEY_STR   "esc"

MyFirstProject/amigaos4/include/os_main.h (AFTER)
-------------------------------------------------
/* Window Title String (Constant and Global Pointer) */
#define WINTITLE "My First Project v" PRODUCT_VER " ©2005 My Cool Software"  <----- AFTER YOUR EDITS
#define VERSION_STRING "$VER:" WINTITLE
#define MAX_WINTITLE_LENGTH 80
#define MAX_POPKEY_LENGTH 128
#define MAX_HIDEKEY_LENGTH 128
#define DEFAULT_ICONTITLE_STR "My_First_Project"   <----- AFTER YOUR EDITS
#define DEFAULT_POPKEY_STR    "f1"   (Could change the default show/hide keys right now as well)
#define DEFAULT_HIDEKEY_STR   "esc"


AVD Template File Structure
---------------------------
$HOME (Your Working directory)
 |
 +--AVD_Template
 |   |
 |   +--amigaos4
 |   |   |
 |   |   +--bin
 |   |   |   |
 |   |   |   +--avd_template (final executable is copied here on "make install")
 |   |   +--include
 |   |   |   |
 |   |   |   +--os_main.h
 |   |   |   +--os_types.h
 |   |   +--lib
 |   |   |   (This is where you can place libraries you need to link to)
 |   |   +--make
 |   |   |   |
 |   |   |   +--Makefile
 |   |   +--source
 |   |       |
 |   |       +--functions
 |   |       |   |
 |   |       |   +--os_allocobjs.c
 |   |       |   +--os_closelibs.c
 |   |       |   +--os_creategui.c
 |   |       |   +--os_displaygui.c
 |   |       |   +--os_freeobjs.c
 |   |       |   +--os_functions.h
 |   |       |   +--os_hidegui.c
 |   |       |   +--os_openlibs.c
 |   |       |   +--os_processevents.c
 |   |       |   +--os_returnallsigmasks.c
 |   |       |   +--os_returnlist.c
 |   |       +--os_dispapp.c
 |   |       +--os_initapp.c
 |   |       +--os_initargs.c
 |   |       +--os_init.c
 |   |       +--os_main.c (This is the actual entry point for the C compiler)
 |   |       +--os_outputstr.c
 |   |       +--os_returnerr.c
 |   |       +--os_usage.c
 |   +--common
 |   |   |
 |   |   +--avd_template.c (This is the virtual "main()" for your application)
 |   |   +--avd_template.h
 |   |   +--include
 |   |   |   |
 |   |   |   +--avd_ver.h
 |   |   |   +--common.h
 |   |   +--source
 |   |       |
 |   |       +--dispapp.c
 |   |       +--initapp.c
 |   |       +--initargs.c
 |   |       +--usage.c
 |   +--documents
 |       |
 |       +--html
 |       |   (AVD Template Documentation - HTML Supporting files)
 |       +--index.html
 |       |   (Starting page for AVD Template Docs)
 |       +--AVDTemplate.xml(Click here to view "as XML")
 |           (The source XML file created by AVD's GUI Builder, which was used to generate the ReAction GUI for this project)
 +--include
     |
     +-- avd_types.h
     +-- debug.h

Above is the file tree of the source code for the AVD Template.
As you can see it is not just a simple "hello world" program,
but rather a well structured program designed to address several
problems that arise later on as your program grows in size
and complexity by setting things up properly right from the start.

Open the AVD_Template/documents/amigaos4/index.html in your favorite
browser to browse the source tree in a nice context-sensitive format.
(Unfortunately you can't see the colors in IBrowse2) :( however,
it is still a nicely readable way to browse the source code.

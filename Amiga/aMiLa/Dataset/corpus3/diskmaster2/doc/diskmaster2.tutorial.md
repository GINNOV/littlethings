Amiga "Unofficial" DiskMaster2 5RC10 Beginner's Tutorial
by Bonnie Dalzell 2003

Part I. Introduction and Overview.

What can you do with it?

Disk Master is an application manager and file utility for the Amiga OS which
is fast, configurable and very sparing of system resources. You can use it in a
manner similar to the useful linux "Midnight Commander" and x86 DOS
XTreeGold ZTree programs to view files and launch many applications. I find its
text-in-a-list window based file management format to be easier to use than
GUI/Icon based file management tools. The program was originally written by
Greg Cunningham and originally released by Progressive Peripherals and
Software, Inc as a commercial product. Greg turned the source code over to
Rudolph Riedel who currently maintains the program, which is now freeware.

When fully configured DM2 has most of the capablities of GUI utilities such as
Konqueror, M$Desktop Explorer or DirOpus. It is very system friendly and
consumes few resources. It can be opened on the Workbench or on its own screen
and it can open as many Lister windows as you wish. It can also open multiple
Command windows each containing a different command set.

In addition to its basic functions, I have my DM2 configured to display text
and image files, launch the web browser to view web pages, and - via ftp - to
manage files on remote sites.

About the tutorial:

This tutorial is designed for beginners using DiskMaster2 as a quick start, as
a basic introduction to the more complete information in the Diskmaster
documentation file, DM2.guide.

NOTE: This tutorial applies to DM2.5RC10beta and its matching document file
DM25RC10.guide. There are some important changes between earlier versions of
DM2 and DM2.5RC10 in configuring the AddAutoCmd part of the Startup.DM script.

Make sure your set of documents matches your version of DM2.

To begin:

Start Diskmaster2 with the default configuration which is defined in the
Startup.DM file.

The default setup gives you three windows: two of the windows list directory
contents (called List or Lister windows), the third is a control window (called
Command window).

There is also a set of drop down menus at the top of your workbench that can be
accessed by pressing your right mouse button.

Using DM2 is fairly straight forward. If you double click with your left mouse
button on an item in one of the list windows, some action occurs, depending on
the DM2 setup.

DM2 has internal text display and internal graphics viewing utilities. The
simplest actions are, in response to the left mouse double click, to display a
file, and to open a subdirectory.

DM2 also manages creation and deletion of subdirectories and movement,
renaming, copying and deleting of files.

When you click on an item in a window, DM2 makes that window the Source
(indicated by an "S"in a small status box just below the front to back gadget
at the top right of the window) while the other window becomes the Destination
(indicated by a "D" in the status box). Sets of files can be selected in a
window and copied, moved, deleted or renamed depending on which control window
option or menu option is selected.


You can learn the basics of how to configure a DM2 Startup.DM script with this
tutorial.

Part II. Configuring a Startup.DM file

Open a text editor that produces plain text files (ed, vinced, turbotext) and
name your experimental script myscript.DM.

You can then test your script by opening a CLI window and changing to your
diskmaster subdirectory and typing:

 DM "myscript.dm"

If you keep your text editor window open and your DM2 example running, and you
change the tutorial configuration as you are learning about DM, the running DM
example will automatically change after save the changed script.

An important NOTE: Advanced DM2 script commands may contain paths. If DM2 is to
be launched from an icon the PATH settings that were created by your
user-startup file are not part of the Workbench and complete paths to all
executable files need to be provided in the command string.

 A Basic Startup.DM script configuraton:

These steps construct a simple DM2 startup script that opens DM2 on your
workbench with three windows. Call it myscript.dm.

The minimal DM2 startup script will have:

(1) a. description of the font and pencolors
    b. BarFormat description - what diskmaster displays in the WB action bar when
       selected.
    c. TitleFormat cdescription - what DM displays in the bar at the top of its
       lister windows.

(2) description of the menus opened when DM2 starts.

(3) description of the windows opened when DM2 starts.

(4) commands that are available in the Command Window when DM2 starts.

(5) the Autocommands - actions that occur when you double click on an item in
a Lister window.



(1.a.) Font and pen color set up:


Here is Startup.Dm file which makes a 4 menu setup (Project, Tools, Sort,
Archives) with three items in each menu. Since this is a simple tutorial
startup file, we will use these first 3 lines, which are needed to set it up,
without discussing them in detail, at this time. This DM will open on the
workbench screen. Begin the startup.DM file below.

 Reset
 Font DIRWIN=topaz.font 8 DIRGAD=topaz.font 8
 SetX digits=5 BPen=0 DPen=2 FPen=1 SPen=3

(1.b.) BarFormat

Here is a BarFormat line that displays this information:

 Diskmaster 2.5RC10 Time Date Chip memory Fast memory

about ongoing Diskmaster processes in the Workbench title bar when dismaster is
selected.

BarFormat "DiskMaster %V  %T   %W %D %M %Y    Chip:%C    Fast:%F"

The Barformat command in the DM2Guide will give you a more complete description
of this function and its capabilitieds.

(1.c) TitleFormat 

Titleformat displays information about the lister window in the bar at the top of the
lister window.

This:
 TitleFormat "Selected: %I of %C. %B of %A in dir"

displays a line reading:
 Selected: 10 of 38. 145 B of 17 K in dir
(translation =
    Selected: (num files selected) of (tot num files).
              (tot size in bytes) of (tot size) in dir.

(2) Configuring the top menus (the AddMenu Command).

DM2 has a large number of built in commands, called Functions, that can be
implemented as menu items. The DM2.Guide document lists all of the functions
and their syntax. I will only discuss a few here.

To construct a simple menu you use the AddMenu function.

Each drop down menu will have a name which immediately follows the AddMenu
command and then is followed by a comma (,). Next on the menu line comes  the
menu item's name followed by a comma, the hot key followed by a comma and the
DM2 Function.

This is a basic menu line:

  AddMenu menu_name, menu_item_name, hotkey (not required), DM_Function
          (A) menu name (B) menu item name (C) hotkey (D) Diskmaster function.
So there are four menus in our tutorial Startup.DM file, Project, Tools, Sort
 and Archives.


AddMenu Project, Palette, P, Color
AddMenu Project, Printer Setup, SetPrinter
AddMenu Project, Quit DM, Q, Quit

AddMenu Tools, Execute Selected, Single;Extern Execute %s
AddMenu Tools, Run Selected, Single;Extern Run %s
AddMenu Tools, New Window, N, OpenWindow 240 40 260 120
AddMenu Tools, Swap S<->D, Swap

AddMenu Sort, Sort by Date, Sort D
AddMenu Sort, Sort by Name, Sort N
AddMenu Sort, Sort by Size, Sort S
AddMenu Sort, Sort by Comment, Sort C

AddMenu Archives, Lharc List, StdIO "CON:0/12/640/160/List Window"; Extern Bin:LhA -N v %s; Wait ;StdIO CLOSE
AddMenu Archives, Lharc Add, StdIO "CON:0/12/640/100/Add Window"; Archive "Bin:LhA <* -r -x -a -2 a";StdIO CLOSE
AddMenu Archives, Lharc Extract, StdIO "CON:0/12/640/100/Extract Window";Extern Bin:LhA <* -m -x -a x %s ;StdIO CLOSE

(3) Defining the windows (the OpenWindow command):

For example:

  OpenWindow LEFT=1 TOP=12 WIDTH=340 HEIGHT=400 PATH=SYS:

and

  OpenWindow LEFT=341 TOP=12 WIDTH=109 HEIGHT=400 CMD


The OpenWindow command takes the following variables (arguements):

OpenWindow LEFT TOP WIDTH HEIGHT PATH ZOOML ZOOMT ZOOMW ZOOMH ZOOMED NODRAG NOCLOSE

For the basic dimensions of the window, the values of LEFT, TOP, WIDTH, and
HEIGHT are in pixels. They determine the placement of the window at DM2 startup
and its size. All of the attribute commands must be used in DM2Beta25RC10. In
previous versions of DM2 the LEFT TOP WIDTH HEIGHT and PATH attributes did not
have to be labled.


PATH is the dos path for the default directory to be displayed when DM2 starts.

CMD is the "COMMAND FLAG" which determines if the window is a list window or if
it contains DM2 Commands.

NODRAG and NOCLOSE are flags which, if present, prevent you from moving
(NODRAG) and closing (NOCLOSE) the window.

The ZOOM commands affect the alternate size and position of the window if you
click on the zoom gadget in its upper control bar. The zoom gadget is the one
that has a small rectangle inside a larger rectange and sits just to the right
of the window front-to-back gadget.


ZOOML is the alternate pixel coordinate of the left edge of the window.
ZOOMT is the alternate pixel coordinate of the top of the window.
ZOOMW is the alternate width in pixels of the window.
ZOOMH is the alternate heigth in pixels of the window.

ZOOMED is a flag that sets the windows to the alternate state when DM2 starts up.

If no values are set for the zoom commands they default to the following
values:


ZOOML - LEFT, ZOOMT = TOP, ZOOMW = 65 (pixels), ZOOMH = 65 (pixels)

Here is a simple three window startup with the control window in the center:


OpenWindow LEFT=1 TOP=12 WIDTH=340 HEIGHT=400 PATH=ram:
OpenWindow LEFT=341 TOP=12 WIDTH=109 HEIGHT=400 PATH=CMD
OpenWindow LEFT=452 TOP=12 WIDTH=340 HEIGHT=400 PATH=Sys:

Here is the 3 window startup with custom zoom capabilites:


OpenWindow LEFT=1 TOP=12 WIDTH=340 HEIGHT=400 PATH=ram: ZOOMT=400 ZOOMH=600 ZOOMED OpenWindow LEFT=301 TOP=12 WIDTH=109 HEIGHT=200 PATH=CMD OpenWindow LEFT=410 TOP=12 WIDTH=300 HEIGHT=300 PATH=sys: ZOOMT=400 ZOOMH=600

(4) Configuring the commands that are listed in the COMMAND WINDOW and
can be applied to a file (or files) that are highlighted in the Lister window
by clicking on the command in the Command window (the AddCmd).

Here is a sample entry which allows you to open the ram directory in a Lister window.

AddCmd RAM:, 12, 21, NewDir RAMDISK:
       (A) title, (B)fgcolor,(C)bgcolor,(D)command (E)path

       (A) string id of command to appear in Command Window
       (B) two digit foreground color - relates to system pen colors
       (C) two digit background color - relates to system pen colors
       (D) command line, may contain several internal or external functions
          separated by a semicolon. ;
       (E) Path - in this case it is the volume name

Many of the possible commands are DM2 functions. The DM2.guide does a good job
of explaining the various functions and how to use them. You should use the DM2.Guide
for further instruction.


(5) Configuring commands that respond to a double click on an item in a Lister
window (the AddAutoCommand command):

AddAutoCmd [data or pattern to match,command]

This is the most elaborate Startup.DM script line.

'DATA or pattern to match' refers to information that is found within the first
500 bytes of the file that is highlighted.

This means that you may need to use a hex viewer to find things in a binary
file that identifies the file type.

Here is an entry that allows me to launch my web browser, IBrowse, when I click
on an html file.

  AddAutoCmd #?<HTML#?, Extern run Sys:Internet/Ibrowse/Ibrowse %s


  This has the following components:

  AddAutoCmd #?>HTML#?, Extern run Internet:Ibrowse/Ibrowse %s
             (A)DATA  , (B)extern or intern (C)run (D)path:to/(E)application (F)% argument

(A) DATA
The AddAutoCommand depends on the assumption that the file has the ascii characters
<HTML in the first 500 bytes. The character search is case insensitive.

You can als use two predefined values for DATA: (1)TEXT and (2) DEFAULT.

About pattern matching:

  DM2 uses the pattern matching used by the Amiga system. This is found in The
  Amiga Users Guide book on DOS.

  In my copy of the HTML manual for OS3.9 pattern matching is discussed at:

  OS3.9 Manual/dos/book-main21.html#pgfId=1016381 This gives a lot of examples.

  In my printed (English) Version of the DOS manual for OS3.1
    pattern matching is discussed at page 3-16.

  In brief, the wildcards in Amiga OS are:

  ? (question mark) will match any single character.
       ?AT  would match CAT, BAT, RAT, etc.

  #x  would match zero to any number of occurances of "x"
      as in  x,xx,xxxxxxxxxxxxxx, etc.

  ~      is not or negation
     ~x    matches anything but x

  ( )    parens group characters together (ABC)

  [ - ] square brackets with a hypen between the characters, delineates a range [a-c]

  %      matches the null string (ie no characters)

  'character   allows a wild card character to be 'escaped' so you can search for it also.
      for example '? allows you to search for the question mark.


In DM2.5RC10 the DATA part of the autocommand must be terminated by the #? wild cards
which basically indicate that anything after the specified pattern is matched.

(B) extern switch. If you use this the application is launched by an external system
command.

(C) 'run' for programs, 'execute' for scripts. If you include this then you can
continue to use DM2 to do other things without having to close down the application
you just launced.

(D) Path. If you launched DM2 from your workbench, the paths assigned in the user start up
do not work, you have to give full paths to the applications. In this example IBrowse is
on my system partition in the subdirectory Internet and it its subdirectory
Ibrowse.

(E) The program or script. In this example the browser program IBrowse.

(F) the DiskMaster arguement flag.
    %s the selected file or drawer with full path. In this example the file highlighted in
the Lister window supplies the full path to the %s flag.

some others are:
    %n name of file or directory
    %d the destination path.


Part III. Misc Notes -
Esc is suppossed to stop ongoing processes

(A) DM2 does not recognize paths added from the path command unless it
is launched from a shell rather than the workbench, so configure the icon to
launch from a shell.

This won't work:

 c:path c: sys:Utilities/

-< extern some_command_in_sys:utilities

While this will work with no problem at all.

 c:assign c: sys:Utilities/ add

-&ly; extern some_command_in_sys:utilities

(B) Some notes on  AmigaGuide:

Amigaguide files start with @database as the first entry.
AmigaGuide does not handle crunched guide files correctly. Decrunch them first
Guide files are plain text. You can look at them in a simple text editor such as Ed or TurboText to see if they are binary files.




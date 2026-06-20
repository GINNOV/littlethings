
ConMan & GfxSys README

by Charles Bloom cbloom@mail.utexas.edu

6-25-96

These are two, rather old, source libraries.

ConMan does CON: IO but gives the calling task complete control
over the Gfx and the character IO.  i.e. character can be filtered,
you can put multiple cons in one window, you can do an iskbhit() etc. etc.

	( ConMan has a little bug : the cursor doesn't show up when it's
		at position Zero )

GfxSys is a scalable graphics interface.  I wrote this about 4 years ago
when it occured to me that writing all these programs at 640x400 wasn't
very future-minded.  Of course, here I am now, still running at 640x400
and GfxSys still isn't bug-free.  The bugs here are that the refresh
is messy - i.e. it doesn't properly redraw all the time.  The idea
behind GfxSys is for the User Program to do all IO in a 10,000 X 10,000
virtual coordinate system.  GfxSys converts this to screen coordinates,
no matter what the screen resolution is.  The virtual scaling has
all kinds of options like PRESERVE_ASPECT and that kind of thing.  I
wanted to incorporate scalable fonts (wouldn't that be cool) but
never got around to it.

Note: you must create the <simple/> and <crblib/> directories as
requested and copy *.h into them.

To build a test app using SAS/C of either one, simple run 'smake'.

If using something else (gcc/DICE) just do something like

	gcc *.c -o test

and you'll be fine - i.e. just mash 'em all together.


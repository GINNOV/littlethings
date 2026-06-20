
                                Prog_Bar.Lib
                                ============

             A progress bar link library for Amiga Programmers
             =================================================

                       Written by Allan Savage © 1996
                       ==============================


Introduction
------------

Prog_Bar.lib  is  a  progress  bar  link library designed to make it easy to
create, manage and delete progress bars within a C program.

The  library  is  easy to use and provides a large range of options for your
progress  bars.   It  has  been  designed to operate in a similar way to the
GadTools functions for managing gadgets, so the ideas involved should not be
new to anyone who might be using them.

The  library  is  capable of producing many different types of progress bars
using  a simple set of parameters.  These allow the programmer to completely
customise  a  progress  bar by changing its border, colours, size, location,
dimensions, direction and text.

To  give you an idea of what is possible using this system I have included a
demonstration program  in  this  archive.   This  program  creates a single
progress  bar  and  then  lets  you  change the various settings to see what
effect  they  actually  have.   I have also supplied the source code for the
demonstration  program  so  that  you  can learn from the techniques used to
control a progress bar.



The  library can currently only be used by C programmers because I have only
written  the  prog_bar.h  definition file.  If anyone would be interested in
using  the library from assembly language, or indeed any other language such
as  Amiga  E,  then please let me know.  I might be able to include suitable
definition files in future versions.



Installation
------------

How  to install the library really depends on the compiler you are using and
your  own personal preferences.  Since the library is aimed at programmers I
will  assume that you already know how your compiler works and will describe
the installation in a general way.  As an example I will also describe how I
installed it for use with Dice C.


The system is comprised of two files, "prog_bar.h" and "prog_bar.lib".

"prog_bar.h"  should  be  copied to anywhere on your compiler's include file
search path.  Just make sure you know where you put it because you will need
to  #include it any time you want to use prog_bar.  In Dice I copied it into
the "DINCLUDE:pd/" directory.

"prog_bar.lib"  should  be  copied  to  anywhere  on your compiler's library
search  path.   Alternatively you could put it anywhere and then specify its
full pathname when linking.  In Dice I copied it to "DCC:dlib/"

The documentation includes an Amigaguide file called "prog_bar.guide".  This
can  be  copied to your compiler's document directory, or can be linked into
the  Autodocs  documentation if you have it installed.  A plain text version
of this file is also supplied.  It is called "prog_bar.doc".



Usage
-----

Using  the  system  should  now  be  as simple as using any of the operating
system  libraries.  When you write a program which needs a progress bar just
include  prog_bar.h  at  the  top  of  your source and remember to link your
object file to prog_bar.lib.  In Dice I use "#include <pd/prog_bar.h>" in my
source and just add prog_bar.lib to the end of my compile command.

To  actually  create  and handle a progress bar within your program you will
need  to  follow  the  rough guide given below.  However, every situation is
different  so  you  might  need  to  vary  your approach.  All the available
functions are documented in the document prog_bar.doc.


Step 1.

Work  out  what  size  your  bar has to be.  Note that the size is the value
represented  by  the  full  bar.   It  is  not  related  to the bar's actual
dimensions.

How you do this will depend on what you are using the bar for.  For example,
if  you want to represent a percentage the size would be 100.  If you wanted
to  use  a progress bar while printing the size might be the number of lines
to be printed.


Step 2.

Create a suitable progress bar using CreateProgBarA() or CreateProgBar().


Step 3.

Every  time  your  program  completes  one unit of whatever it is doing, you
should  use  UpdateProgBar()  to display the new position.  For the examples
above  this would mean updating the bar after one percent, or after printing
each line.

If  the  value  of  the  bar  is  decreasing  and you have the text function
activated,  it  will  probably  be necessary to call ClearText() immediately
before updating the bar.


Step 4.

When  you  have  finished you should delete the progress bar and release the
memory used by calling FreeProgBar().


Step 5.

When your window needs refreshed you should call RefreshProgBar().



Distribution
------------

Prog_Bar is Copyright © Allan Savage 1996.  All rights reserved.

Prog_Bar  is freely distributable, providing that no commercial gain is made
from its distribution, and no modification is made to the original archive.

Anyone  wishing to include Prog_Bar on a magazine coverdisk or other similar
collection,  or  use it in any application, commercial or otherwise, have my
full permission.  All I ask in return is to be acknowledged somewhere in the
documentation  and  to be told about it, preferably by e-mail (see below for
details).



Disclaimer
----------

This  software  is  provided  "AS  IS"  without warranty of any kind, either
expressed  or implied, including, but not limited to, the implied warranties
of  merchantability  and  fitness for a particular purpose.  The author does
not guarantee the use of, or the results of the use of, this software in any
way.   In  no  way  will  the  author  be  held liable for direct, indirect,
incidental, or consequential damages to data or equipment resulting from the
use of this software.



Acknowledgements
----------------

The  Prog_Bar  library  was written in C and compiled using DICE v2.07.56 R.
Thanks to Matthew Dillon for this excellent compiler.

The Demonstration program was also compiled using DICE and its interface was
designed  using GadToolsBox v37.300.  My thanks also go to Jan van den Baard
of Jaba Developments for this program.



How to contact me
-----------------

If  you  have  any  suggestions  for  improving  Prog_Bar, bugs to report or
queries  about  the  program, please send them to me at one of the addresses
below.

        E-Mail :  asavage@bitsmart.com         (preferred option)
                  asavage@enterprise.net

        Post   :  Mr. Allan Savage
                  2 Navar Drive
                  Gransha Road
                  Bangor
                  N. Ireland
                  BT19 7SW


If using e-mail please include a subject line of "Prog_Bar".

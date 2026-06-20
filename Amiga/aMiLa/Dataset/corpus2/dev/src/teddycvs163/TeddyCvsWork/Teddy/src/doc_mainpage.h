
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!

\mainpage Teddy Reference Manual


\section mp_introduction Introduction


While original plan was to create OpenGL version of Elite,
current development is focused on making modular, generic
opensource space-roleplaying framework. <i>Teddy</i> is
project name for the framework. <i>glElite</i> is project
name for the spacegame of original idea.

Teddy (while also being acronym for something..) stands
for <b>General graphics application library</b>. It is
called such because it is 'just' a collection of routines
related to graphics applications that use OpenGL and are
capable of doing simulation.

Teddy is acronym for 'The Embassy Demo Development
Ympäristö'. Ympäristö is Finnish word meaning environment.
Original plan for TEDDY is to be implemented later, if
ever.

glElite is project plan to create OpenGL version of Elite.
Since Elite is copyrighted, and glElite clearly would contain
material from Elite, it will be impossible to publish glElite
under Gnu Public license. Currently I am not working on glElite.
If someone does the boring job for me and tells me which license
to use, and how, it will be possible to continue work on glElite.
Based on Elite - The New Kind and Teddy, it should be possible to
finish glElite.


\section mp_current_status Current status


<p>
Teddy currently uses
<a href="http://www.devolution.com/~slouken/SDL/">Simple Directmedia %Layer</a>
to access OpenGL in platform independent way.
</p>

<p>
Currently implemented features is moved to the README.TXT file.
TODO features are in CHANGES file.
</p>


\section mp_developer_documentation Developer documentation


This documentation does not cover C++, STL, SDL or OpenGL -
You have to use other resources if you need information about them.
<a href="http://www.opengl.org>http://www.opengl.org</a>
OpenGL homepage is good startingpoint for OpenGL, for example.

Teddy / glElite is developed concurrently in Microsoft Visual
Studio C++ version 6 and linux using g++. Workspace and Project
files are included for VC, and autoconf/configure/make tools
are supported for linux.

Generally, SDL and a C++ compiler with STL support is required.
Native OpenGL will improve graphics speed and quality.

<ul>
<li><a href="GettingStarted.html">GettingStarted.html</a> - read this very first
<li>\link p_program_flow Program Flow\endlink A little about startup
<li>\link p_diary Diary\endlink
<li>\link p_links Links\endlink
</ul>


\section mp_contact_information Contact Information


Timo Suoranta<br>
Kilonrinne 10 E 101<br>
02610 Espoo<br>
Finland<br>

Email: <a href="mailto:tksuoran@cc.helsinki.fi>tksuoran@cc.helsinki.fi</a><br>
My Homepage: <a href="http://www.helsinki.fi/~tksuoran/">http://www.helsinki.fi/~tksuoran/</a><br>
glElite Homepage: <a href="http://glelite.sf.net">http://glelite.sf.net</a><br>
Gsm: +358-40-5629512


\section mp_about_this_documentation About This Documentation


This documentation has been extracted from source files with
<a href="http://www.stack.nl/~dimitri/doxygen/index.html">Doxygen</a>
version 1.2.11 by <a href=mailto:dimitri@stack.nl>Dimitri van Heeschs</a>.

*/
 

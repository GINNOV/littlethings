
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
	\defgroup g_physical_components Physical Components (User Interface)
*/

/*!

\page p_physical_components Physical Components

Physical components are user interface classes. On popular
operating environments these are also known as gadgets,
window gadgets, widgets, controls and so on.

Physical components also contain and implement
the windowing system in Teddy.

Area is base class for all Physical Components. See 
documentation of Area for details about this base class.

Currently many features are under testing, and behave differently than
they are purposed to behave due to missing features. For example, it is
not desirable for Console to specify LayoutConstraint, or attach background
Fills.

Most components are not yet interactive. To make component interactive,
it will have to implement either MouseListener or KeyListener. This scheme
may change later when LogicalComponents and ComponentMapping are introduced.

See documentation for Area for more about the interface.

*/



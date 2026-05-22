
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
	\defgroup g_maths Maths
*/

/*!

\page p_maths Maths

The Maths module contains mathematical tools useful in three
dimensional work. Included are Vector, four-vector (Vector4)
and Matrix. OpenGL Matrix interface is way too limited for
serious Matrix operations, so I have replaces the whole modelview
Matrix manipulation. Same might happen to the projection
Matrix later.

There is not much to say about the methods in the classes - either
you are familiar with them or not. In the latter case you have to
look elsewhere for support. Again I have used subclass constructors
for number methods for fluent usage.

Some Vector and Matrix methods are not yet included, and not all of the
included are yet properly tested. I am using doubles because the original
idea was and still could be an object modeler.

Classes which are prefixed in Microsoft style with C are Sean O'Neils
versions, including 3D and noise fractals.

*/



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
	\defgroup g_models Models
*/

/*!

\page p_models Models

Models module contains classes to maintain model
modeling and rendering data. While at the moment
distinction between <i>modeling</i> and <i>rendering</i>
data is not well arranged yet, it will be.

Modeling data is to be flexible, but not optimized.
For example, there is only a single vertex class for
modeling, which contains data for normal, color and
texture coordinates, even if they do not exist for
some vertices.

Modeling data can be rendered directly, which is
called immediate rendering. This is how the current
scene is drawn in Teddy. It is planned but not yet
implemented to include optimizer that converts
modeling data into optimized rendering data. For
static objects this means using vertex arrays and
displaylists.

Mesh is baseclass for all modeling and rendering.
Important method of Mesh is drawElements().
Mesh holds a collection of Elements. For example,
a Sphere consists of QuadStrip Elements. A QuadStrip
Element further contains ordered collection of Vertices.
A Sphere draws itself by drawing all QuadStrip Elements.
Each QuadStrip element further draws itself by giving
graphics system (currently OpenGL) instructions that
incoming is a quad strip, and then asks all vertices to
draw temselves. Each vertex checks if they have normal,
color or texture coordinates set, and applies those to
graphics system if so. The vertex coordinate itself
is always applied to graphics system.

Some ther Elements are Face, TriangleFan and Line. All
of these further contain Vertices. Face simply is a polygon.
While Face class currently has subclasses, these will be
integrated to a single class soon..

There can be several \link ModelInstance ModelInstances\endlink 
of Mesh, each having some extra properties
(like Material) for the Mesh.

*/

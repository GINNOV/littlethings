
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

\page p_program_flow Program Flow


At startup a single instance of UI class is created.
It creates a number of instances of some classes. 
Some important instances are:

<ul>

<li>WindowManager *window_manager

The main execution thread eventually calls
inputLoop() -method of WindowManager. The inputLoop()
method never returns.

In the inputLoop() the window manager draws the
display and polls for input events.

Window manager knows about displayable windows.
Not all windows in Teddy are fullfeatured. The
base class for all windowing entities is the
Area class. The window manager knows about all
Areas which should be drawn to the display. These
Areas are arrange into Layers.

Area itself is an abstract class. Only subclasses
of Area can be displayed.

Any Area subclass can listen to input messages, if
it implements EventListener. 

When Teddy receives input message from host system, it is
processed by WindowManager. WindowManager maintains focus. 
Focus is Area that implements EventListener and to which
the window manager sends incoming events. At the moment
there is fixed policy that focus can be changed
by clicking on top of Area. Will be fixed later to more
flexible and configurable policy.

<li>View *view

View is a single OpenGL window in host environment running
Teddy. Inside this View Teddy can manage multiple virtual
windows, Areas, managed by the Window Manager.

Areas can be both three- and two-dimensional. More precisely, 
Projection is subclass of Area such that it can apply
custom projection matrix, while Area is plain two-dimensional
Area.

<li>Layer *layer

Layers are collections of Areas. Drawing a layer means
drawing Areas that below to that Layer. 

<li>Scene *scene

Scene is collection of Lights and ModelInstances.

<li>FrontCamera *front_camera

Although name suggest, FrontCamera class is not subclass of
Camera. It is subclass of Projection. Projection is a special
subclass of Area which can apply a projection matrix to vertices
when they are drawn.

Every projection can display use a single Camera
at time to show some view of some scene.

<li>Camera *camera

Camera is a tool which can be used to display a scene.
Camera is separated from Projection, because a single
camera can be viewed in multiple projections. Each
projection may also have different rendering preferences.

Camera is subclass of ModelInstance. This means
that each camera has location and attitude.

Additionally camera specifies near and far planes and
field of vision. Camera can do view frustum culling
to ModelInstances if they have valid clipRange.

Camera will also support skybox and starfield. Currently
they may not work properly.

<li>Sight *sight

Sight is example of derived Area. It is a simple one.
It uses LayoutConstraint so that it will always be
positioned to the center of its parent Area.


<li>Console *console

Console is work-in-progress cout like string buffer.
It has basic output, input and editing features, and
some bugs, but no advanced editing features like
selection.

<li>Hud *hud

Hud is another derived Area that displays some textual
information. It is simpler than Console, and the data
it displays is more fixed.

<li>Scanner *scanner

Scanner is yet another simple derived Area which
displays ModelInstances of the scene in Elite like
radar.

</ul>


*/


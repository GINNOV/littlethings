

TEDDY RELEASE VERSION 1.63


This is early development version of Teddy.

Starting from this version, the Teddy framework has
been separated from the application. In addition to
the glElite main application, there are several smaller
demonstration applications. The purpose of these
applications is to help getting used with Teddy easier.
I will try to write a tutorial around these example
programs.

Rest of this file is about glElite.

Please read through test scene instructions and keyboard
controls before trying the program.

While original plan was to create OpenGL version of Elite,
current development is focused on making modular, generic
opensource space-roleplaying framework. Teddy is project
name for the framework. glElite is project name for the
spacegame of original idea.

As the project grows, I might eventually split some libraries
out of Teddy and make standalone libraries from them. The
lightwave object loader would be a good candidate for such
library project.


I am working alone on Teddy at the moment. If you would
like to join to help me with the development, I will be
happy to receive e-mail from you. Also mail me if you
have comments or suggestions.

See GettingStarted.html for building instructions.
See currently implemeted features below to see what Teddy can do.


COMMAND LINE ARGUMENTS:


Following commandline arguments are in use:
	--width <int> 
	--height <int>
	--fullscreen
	--background, 
	--no-background
	--no-audio
	--no-windows
	--no-cabin

For example:
	
	Teddy --width 1024 --height 768 --fullscreen --no-audio


KEYBOARD CONTROLS:


	a    : autopilot (key needs to be held down)
	s x  : control pitch
	, .  : control roll
	space: more speed
	tab  : less speed
	esc  : brakes
	
	1    : toggle inside / outside ship camera
	f1-f6: choose inside ship camera direction
	
	5    : cycle scanner range
	6    : turn off ROAM update
	7    : turn on ROAM update
	8    : decrease ROAM error tolerance
	9    : increase ROAM error tolerance

	n    : narrower view
	m    : wider view
	k    : lighting disabled
	l    : lighting enabled
	v    : culling disabled
	b    : culling enabled
	u    : point vectors
	i    : wireframe vectors
	o    : filled vectors
	p    : outlined filled vectors
	d    : debug selected target

Numeric keyboard:

	8, 2 : control camera pitch
	4, 6 : control camera heading
	7, 9 : control camera roll
	1, 3 : control camera roll
	-    : move camera further
	+    : move camera closer


TEST SCENE INSTRUCTIONS


Test scene starts with outside ship
camera active. You can control the outside ship
camera with mouse while controlling your ship with
keyboard (sx,. etc.). Your ship is a textured
Cobra Mk III, initially near center of the outside
ship camera. Notice that the outside ship camera
    does not follow your ship.

    You should start testing by getting familiar with the
    controls, one by one. First test turning the outside
    ship camera. You can do this by dragging around with
    the mouse while holding left mouse button down. You
    will notice that uou can only control pitch and roll.
    This is the way original Elite controlled ships.

    Then you can try moving the outside ship camera. Do this
    by dragging mouse around while holding down right mouse
    button.

    Next you can try controlling your ship. Before doing so,
    either restart the program, or make sure that you can
    see the texture cobra which was initially shown. Then
    try controlling ship pitch with s and x keys. Then try
    controlling roll with , and . keys.

    Next it is worth trying inside ship cameras before
    actually flying with the ship. Press 1 repeatedly to
    see how you can toggle between inside and outside ship
    cameras. Then while inside ship camera, press f1-f4 to
    select front-rear view cameras.

    Finally get into inside ship front view camera. Then try
    again pitch and roll controls sx,. and then speed controls.
    You can gain (more) speed by pressing space. You can get
    less speed by pressing esc. You can also move backwards by
    pressing tab.

    Now you should be able to fly your Cobra Mk III. Try
    looking at your f1-f4 views while moving and try to spot
    your wingmen, two Vipers.

    While you are looking through outside ship camera, you
    can select autopilot target for your ship by clicking on
    ships. The HUD display on top of the view should display
    name and distance to the target if you have succesfully
    selected one. For the moment target can not be selected
    while inside ship camera (this will be fixed in next
    release). You can activate the autopilot by holding down
    the a-key.


	CREDITS:


	Timo K. Suoranta  Main programming and design
	Sean O'Neil       ROAM                 (not used in this release)
	Russell L. Smith  Open Dynamics Engine (not used in this release)
	Fabrice Bellard   TinyGL               (not used in this release)


	CONTACT INFORMATION:

	
	glElite homepage:  http://glelite.sf.net
	Author:            Timo.Suoranta@Helsinki.FI


	---- CURRENTLY IMPLEMENTED FEATURES ----


	- OpenGL rendering of textured and smoothed objects
	- Userinterface with hierarchial components, input focus,
	  layout management and logical styles
	- Multiple 2D and 3D windows inside single OpenGL context
	- Object loader for Lightwave LWOB, LWLO and LWO2 file formats
	- Vector, matrix and quaternion math classes
	- Vertex, Face, Mesh, elements for object parts
	- Flexible vertex API with hierarchial inheritance
	- Mesh structures for object representation (can be hierarchial)
	- Material class to maintain lighting and texture mapping properties for surfaces
	- Light class to maintain light properties
	- ModelInstance class to define objects
	- Scene as collection of ModelInstances and Lights
	- Cameras for scenes
	- Flexible camera management; separate rendering preferences for each camera
	- Optional skybox and star/dustfield for cameras
	- Simple font rendering system													
	- Simple scene animation/physics system to animate ModelInstances in physics System
	- Spline interpolation, perlin noise and multifractal routines (Sean O'Neil)
	- Realtime optimally adapting mesh planet rendering (Sean O'Neil)
	- Based on Simple Directmedia Library
	- Heavy use of STL on most data structures
	- Some custom memory management for timecritical structures (memorypools) (Sean O'Neil)
	- System support routines for precise timer, directory scanning and endian intelligent IO


	---- TO DO ----


	- Texture reuse
	- Graphics back-end optimizer
	- Experiment with alpha blending effects
	- Implement console variables, improve console component
	- Improve GUI Physical components
	- Early startup/splash window
	- Lightwave scene reader and player
	- Ship AI, Autopilot
	- Polar and Celestial Coordinates for Navigation
	- Navigation data display (to skybox?)
	- Solar system plane
	- Orbit Calculations?
	- Line cull: use triangle (can be culled) & edgeflag
	- Fog effect for ships?
	- Map Editor
	- Race Editor
	- Equipment Editor


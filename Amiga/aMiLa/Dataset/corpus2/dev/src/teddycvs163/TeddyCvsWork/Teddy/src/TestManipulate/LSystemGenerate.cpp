
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
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
	\file   LSystem.cpp
	\author Timo Suoranta
	\brief  LSystems parsing and mesh generation
	\date   2001
*/


#include "LSystem.h"
#include "Models/Vertex.h"
#include "Models/Line.h"
#include "SysSupport/StdString.h"
#include "SysSupport/Messages.h"
#include <cstdio>
#include <cstring>
using namespace Models;


#define SD 4


void LSystem::generate(){
	const char *str	= cur_data.c_str();

	for( cursor=0; cursor<cur_data.size(); cursor++ ){
		char c  = str[cursor];
		char lu = str[cursor+1];

		use_param = false;
		if( lu=='(' ){
			int count = sscanf( str+cursor+1, "(%f)", &param );
			if( count == 1 ){
				use_param = true;
			}
		}

		switch( c ){

		//  Turtle Orientation commands 
		case '+' : heading  (  -1 ); break;  //  +  turn left around up vector                           
		case '-' : heading  (   1 ); break;  //  -  turn right around up vector                          
		case '&' : pitch    (  -1 ); break;  //  &  pitch down around left vector                        
		case '^' : pitch    (   1 ); break;  //  ^  pitch up around left vector                          
		case '>' : roll     (  -1 ); break;  //  >  roll left (counter clockwise) around forward vector  
		case '<' : roll     (   1 ); break;  //  <  roll right (clockwise) around forward vector         

		//  Special Orientation commands  
		case '|' : heading  ( 180.0f ); break;  //  |    turn 180 deg around up vector                                             
		case '%' : roll     ( 180.0f ); break;  //  %    roll 180 deg around forward vector                                        
		case '$' : rollHoriz( 180.0f ); break;  //  $    roll until horizontal                                                     
		case '~' : randomDir(  90.0f ); break;  //  ~    turn/pitch/roll in a random direction                                     
		case 't' : gravity  (   0.2f ); break;  //  t    correction for gravity with 0.2                                           

		//  Movement commands      draw?  vertex?
		case 'F' : move     (   1.0, true,  true  ); break;  //  F     move forward and draw full length   record vertex       
		case 'Z' : move     (   0.5, true,  true  ); break;  //  Z     move forward and draw half length   record vertex       
		case 'f' : move     (   1.0, false, true  ); break;  //  f     move forward with full length       record vertex       
		case 'z' : move     (   0.5, false, true  ); break;  //  z     move forward with half length       record vertex       
		case 'g' : move     (   1.0, false, false ); break;  //  g     move forward with full length       don't record vertex 
		case '.' : move     (   0.0, false, true  ); break;  //  .     don't move                          record vertex       

		//  Structure commands
		case '[' : push     ();      break;  //  [ push current state 
		case ']' : pop      ();      break;  //  ] pop current state  
		case '{' : polyBegin();      break;  //  { start polygon shape
		case '}' : polyEnd  ();      break;  //  } end polygon shape  

		//  Inc/Dec commands
		case '\'': length   ( 0.9f ); break;  //  '    decrement length with 0.9                 
		case '\"': length   ( 1.1f ); break;  //  "(x) multiply length with x also '(x)   (1.1)  
		case ';' : angle    ( 1.1f ); break;  //  ;    increment angle with 1.1                  
		case ':' : angle    ( 0.9f ); break;  //  :(x) multiply angle with x also ;(x)  (0.9)    
		case '!' : thickness( 0.7f ); break;  //  !    decrement thickness with 0.7              
		case '?' : thickness( 1.4f ); break;  //  ?(x) multiply thickness with x also !(x)  (1,4)

		//  c    increment color index  
		//  c(x) set color index to x   (increment by 1)
		//case 'c' : color    (); break;

		default: break;
		}
	}

}





/*

For those who are already familiar with l-systems, here are the commands
and their functions for this lparser's 'dialect'. All commands are 1 char
only and simpler then for most lparsers. This is to keep them from getting
'broken' by the mutation process and speeds up the parsing.

There is also the posibilty to add an argument to a command. Instead of
doing +++ one can do +(30) if the basic angle was 10 degrees. The argument
can be a real value.

The tropism command will allow you to let gravity pull branches downward by
adding a 't' element togeter with and 'F'. See the file 'tropism.ls' and
'tree*.ls' for examples. When you are not sure about the current 'down'
direction do a '$' command first. This will roll the turtle horizontal and
make sure the current up vector is oriented in the positive z-axis direction.

The turtle will start at the origin with the Z-axis as forward direction and
Y-axis as left direction. See the file 'axis.ls' for an detailed example. Here
you can experiment with the basic orientations and see how the 3d turtle is
using a 'right-handed' coordinate system. Use your right hand with your thumb
as up, forefinger as forward and an other finger as left direction.

By adding &(90) in front of an axiom the turtle axis will align with the right
handed coordinate system used in the viewer. Adding an additional +(90) will
make it easier when working with 2d l-systems. See the 'fract*.ls' files for
examples.

Values can have some randomness automatically added to them. Using ~(xx) will
now add a random direction component to the current orientation with maximum
of xx in all three directions. This way you can mark at which locations in
your l-system 'jitter' needs to be introduced. Using this option no two
'instances' of the same l-system will look the same. See fern.ls for an
example.

Turtle Orientation commands 

+     turn left around up vector  
+(x)  turn x left around up vector  
-     turn right around up vector  
-(x)  turn x right around up vector  
&     pitch down around left vector 
&(x)  pitch x down around left vector 
^     pitch up around left vector  
^(x)  pitch x up around left vector  
>     roll left (counter clockwise) around forward vector 
>(x)  roll x left around forward vector  
<     roll right (clockwise) around forward vector 
<(x)  roll x right around forward vector  

Special Orientation commands  

|    turn 180 deg around up vector  
%    roll 180 deg around forward vector  
$    roll until horizontal  
~    turn/pitch/roll in a random direction  
~(x) turn/pitch/roll in a random direction with a maximum of x degrees 
t    correction for gravity with 0.2  
t(x) correction for gravity with x  

Movement commands                         when {} active 

F     move forward and draw full length   record vertex 
F(x)  move x forward and draw             record vertex 
Z     move forward and draw half length   record vertex 
Z(x)  move x forward and draw             record vertex 
f     move forward with full length       record vertex  
f(x)  move x forward                      record vertex 
z     move forward with half length       record vertex 
z(x)  move x forward                      record vertex 
g     move forward with full length       don't record vertex 
g(x)  move x forward                      don't record vertex 
.     don't move                          record vertex 

Structure commands 

[ push current state  
] pop current state  
{ start polygon shape 
} end polygon shape  

Inc/Dec commands 

"    increment length with 1.1  
'    decrement length with 0.9  
"(x) multiply length with x also '(x)  
;    increment angle with 1.1  
:    decrement angle with 0.9  
:(x) multiply angle with x also ;(x)  
?    increment thickness with 1.4  
!    decrement thickness with 0.7  
?(x) multiply thickness with x also !(x) 

Additional commands  

c    increment color index  
c(x) set color index to x  
@    end of object  


*/


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


#include "Imports/LWFile.h"
#include "Imports/LWMesh.h"
#include "Imports/LWLayer.h"
#include "Models/Mesh.h"
#include "Models/Face.h"
#include "Models/Vertex.h"
#include "SysSupport/Exception.h"
#include "SysSupport/Messages.h"
#include "SysSupport/StdMaths.h"
#include <cstdio>
#include <algorithm>
using namespace std;


#define USE_LIGHTWAVE_SCALE   1
#define SCALE				  1


namespace Imports {


//!  Constructor for submeshes, simply calls Mesh constructor
LWMesh::LWMesh( char *name ):Mesh(name){
	lwo_debug_msg( "LWMesh constructor" );
}


//!  Constructor which loads LightWave object file
LWMesh::LWMesh( char *fname, Uint32 options ):Mesh(fname){
	f        = NULL;
	num_tags = 0;
	
	try{
		f = new LWFile( fname, options );
		
		f->pushDomain( 8 );              // Master domain only allows reading of first 8 bytes of FORM and length
		ID4 form     = f->read_ID4();    // FORM
		f->setLen    ( f->read_U4 () );
		f->pushDomain( f->getLen  () );  // file length-8; File data domain allows reading of rest of the file
		f->setType   ( f->read_ID4() );  // LWOB, LWLO, LWO2
		
		lwo_debug_msg(
			"%s lwo file %s length %ld ",
			did( f->getType() ),
			fname,
			f->getLen()
		);
		
		LWLayer *new_layer = new LWLayer( this, fname, 0, Vector(0,0,0), -1 );
		layers.insert( pair<U4,LWLayer*>(0,new_layer) );
		insert( new_layer );  //  add to submeshes
		new_layer->processLayer();
		float lr = new_layer->getClipRadius();
		if( lr > this->getClipRadius() ){
			this->setClipRadius( lr );
		}

	}catch( .../*Exception &e*/ ){
		lwo_debug_msg( "Exception" );
	}

	if( f != NULL ){
		f->close();
	}else{
		return;
	}

	disableOptions( MS_SELF_VISIBLE );  //  Root node is invisible
}


//!  Destructor
/*virtual*/ LWMesh::~LWMesh(){
	//	FIX
}



LWFile *LWMesh::getFile() const {
	return f;
}

LWLayer *LWMesh::getLayer( int layer_number ){
	U4_to_LWLayer::iterator  l_it  = layers.find( layer_number );
	LWLayer                 *layer = NULL;

	if( l_it != layers.end() ){
		layer = (*l_it).second;
		if( layer == NULL ){
			lwo_debug_msg( "Layer found as NULL" );
		}
	}else{
		lwo_debug_msg( "Layer not found" );
	}
	return layer;
}


/*!  LWLO LAYR Chunk

	An LAYR chunk must precede each set of PNTS, POLS and CRVS data
	chunks and indicates to which layer those data belong.	An LAYR
	chunk consists of two unsigned short values and a string.  The first
	is the layer number which should be from 1 to 10 to operate
	correctly in Modeler.  This restriction may be lifted in future
	versions of the format.  The second value is a bitfield where only
	the lowest order bit is defined and all others should be zero.	This
	bit is one if this is an active layer and zero if it is a background
	layer.	The string which follows is the name of the layer and should
	be null-terminated and padded to even length.
*/
void LWMesh::layer_U2_U2_S0(){
	U2	  layer_number = f->read_U2();
	U2	  layer_flags  = f->read_U2();
	char *layer_name   = f->read_S0();
	
	lwo_debug_msg( "LAYER %s number %d", layer_name, layer_number );

	LWLayer *new_layer = 
		new LWLayer( this, layer_name, layer_flags, Vector(0,0,0), -1 );
	layers.insert( pair<U4,LWLayer*>(layer_number,new_layer) );
	insert( new_layer );  //  add to submeshes
	f->popDomain( true );
	new_layer->processLayer();
	float lr = new_layer->getClipRadius();
	if( lr > this->getClipRadius() ){
		this->setClipRadius( lr );
	}
}


/*!
	LWO2 Start Layer 

	LAYR { number[U2], flags[U2], pivot[VEC12], name[S0], parent[U2] } 

	Signals the start of a new layer. All the data chunks
	which follow will be included in this layer until
	another layer chunk is encountered. If data is encountered
	before a layer chunk, it goes into an arbitrary layer.
	If the least significant bit of flags is set, the layer
	is hidden. The parent index indicates the default parent
	for this layer and can be -1 or missing to indicate no
	parent. 
*/
void LWMesh::layer_U2_U2_VEC12_S0_U2(){
	U2	    layer_number = f->read_U2();
	U2	    layer_flags	 = f->read_U2();
	Vector  layer_pivot	 = f->read_VEC12();
	char   *layer_name	 = f->read_S0();
	U2      layer_parent = 1;

	if( f->domainLeft() >= 2 ){
		int lp = f->read_I2();
		if( lp>1 ){
			layer_parent = lp;
		}
	}

	lwo_debug_msg( "LAYER %s number %d parent %d",
		layer_name,
		layer_number,
		layer_parent
	);

	LWLayer *new_layer = 
		new LWLayer( this, layer_name, layer_flags, layer_pivot, layer_parent );
	layers.insert( pair<U4,LWLayer*>(layer_number,new_layer) );
	insert( new_layer );  //  add to submeshes

	f->popDomain( true );

	new_layer->processLayer();
	float lr = new_layer->getClipRadius();
	if( lr > this->getClipRadius() ){
		this->setClipRadius( lr );
	}
}


/*!
	LWO2 Tag Strings 

	TAGS { tag-string[S0] * }
	 
	This chunk lists the tags strings that can be associated with polygons by the PTAG chunk.
	Strings should be read until as many bytes as the chunk size specifies have been read, and
	each string is assigned an index starting from zero. 
*/
void LWMesh::tags_d(){
	while( f->domainLeft() > 0 ){	
		char *tag = f->read_S0();
//		cout << "Tag " << num_tags << " " << tag << endl;
		tags.insert( pair<U4,char*>(num_tags,tag) );
		num_tags++;
	}
	lwo_debug_msg( "Tags found: %d", num_tags );
}


char *LWMesh::getTag( VX tag_index ){
	U4_to_string::iterator  t_it      = tags.find( tag_index );
	char                   *tag_value = NULL;

	if( t_it != tags.end() ){
		tag_value  = (*t_it).second;
	}

	if( tag_value == NULL ){
		lwo_debug_msg( "Tag not found" );
	}

	return tag_value;
}


};	//	namespace Imports



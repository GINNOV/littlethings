
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


#include "glElite/FrontierMesh.h"
#include "glElite/FrontierFile.h"
#include "Graphics/Features.h"
#include "Materials/Material.h"
#include "Materials/Render.h"
#include "Models/Line.h"
#include "Models/LineMesh.h"
#include "Models/PointMesh.h"
#include "Models/Vertex.h"
#include "Models/Face.h"
#include "SysSupport/Exception.h"
#include "SysSupport/Messages.h"
using namespace Materials;


#define USE_FRONTIER_SCALE	 1
#define SCALE				 1.0f


namespace Application {


void FrontierMesh::faceBegin(){
	face_good = true;
	face_open = true;
	face      = new Face();
}

void FrontierMesh::faceInsertVertex( int index ){
	if( !face_open ){
		faceBegin();
//		return;
	}
	Vertex                  *vertex;
	int_to_Vertex::iterator  v_it;

	v_it = vertices.find( index );
	if( v_it!=vertices.end() ){
		vertex = (*v_it).second;
		if( vertex == NULL ){
			face_good = false;
		}
	}else{
		vertex = NULL;
		face_good = false;
	}

	if( face_good ){
		face_num_vertices++;
		face->append( vertex );
		last_vertex_index = index;
	}

}

void FrontierMesh::faceInsertSpline( int pi1, int pi2, int ci1, int ci2 ){
	if( !face_open ){
//		faceBegin();
		ffe_debug_msg( "face not open" );
		return;
	}
	int_to_Vertex::iterator  v_it;
	bool					 spline_good = true;
	Vertex					*p1 		 = NULL;
	Vertex					*p2 		 = NULL;
	Vertex					*c1 		 = NULL;
	Vertex					*c2 		 = NULL;

	v_it = vertices.find( pi1 );
	if( v_it!=vertices.end() ){
		p1 = (*v_it).second;
		if( p1 == NULL ){
			spline_good = false;
		}
	}else{
		spline_good = false;
	}

	v_it = vertices.find( pi2 );
	if( v_it!=vertices.end() ){
		p2 = (*v_it).second;
		if( p2 == NULL ){
			spline_good = false;
		}
	}else{
		spline_good = false;
	}

	v_it = vertices.find( ci1 );
	if( v_it!=vertices.end() ){
		c1 = (*v_it).second;
		if( c1 == NULL ){
			spline_good = false;
		}
	}else{
		spline_good = false;
	}

	v_it = vertices.find( ci2 );
	if( v_it!=vertices.end() ){
		c2 = (*v_it).second;
		if( c2 == NULL ){
			spline_good = false;
		}
	}else{
		spline_good = false;
	}

	if( spline_good == false ){
		ffe_debug_msg( "spline is not good" );
		return;
	}

	for( int i=1; i<=16; i++ ){
		double u = (double)(i)/(16.0f);

		Vertex a = (*p1) * (				  ::pow(	   u , 3.0f )  );
		Vertex b = (*c1) * (3.0f * (1.0f-u) * ::pow(	   u , 2.0f )  );
		Vertex c = (*c2) * (3.0f *		 u	* ::pow( (1.0f-u), 2.0f )  );
		Vertex d = (*p2) * (				  ::pow( (1.0f-u), 3.0f )  );

		Vertex *v = new Vertex();
		*v = a + b + c + d;
		face_num_vertices++;
		face->append( v );
	}
	last_vertex_index = pi2;
}

void FrontierMesh::faceClose( int normal_index ){
	if( face_open ){
		if( face_good ){
			if( normal_index == -1 ){
				face->makeNormal();
			}else{
				Vertex					*normal;
				int_to_Vertex::iterator  v_it;

				v_it = normals.find( normal_index );
				if( v_it!=normals.end() ){
					normal = (*v_it).second;
					if( normal != NULL ){
						face->setNormal( &normal->getVertex() );
					}else{
						ffe_debug_msg( "null normal" );
						face->makeNormal();
					}
				}else{
					ffe_debug_msg( "normal %d not found", normal_index );
					face->makeNormal();
				}
			}
			this->insert( face );
			face	  = NULL;
			face_open = false;
			face_good = false;
		}else{
//			cout << "Face not good" << endl;
		}
	}else{
//		cout << "Face not open" << endl;
	}
}

void FrontierMesh::makeVertex( Vertex &v1, Vertex &v2 ){
	int_to_Vertex::iterator  v_it;
	int b0;
	int b1;
	int b2;
	int b3;
	int b4;
	int b5;

	int mode_1;
	int mode_2;
	int x;
	int y;
	int z;
	int w;

	mode_1 = b0 = f->get_byte_low( false );
	mode_2 = b1 = f->get_byte();
	x	   = b2 = f->read_Sint8();
	y	   = b3 = f->read_Sint8();
	z	   = b4 = f->read_Sint8();
	w	   = b5 = f->read_Sint8();

	switch( mode_1 ){
	case 0x00:	//	Normal vertex, b2 = x, b3 = y, b4 = z
	case 0x01:
	case 0x02:
		v1 = Vertex(  x, y, z );
		v2 = Vertex( -x, y, z );
		break;
	case 0x09:	//	3d average of vertices indexed by b3, b4
	case 0x0a:
	case 0x03:	//	2d average of vertices indexed by b3, b4
	case 0x04:
	case 0x0b:	//	2d average of vertices indexed by b3, b4
	case 0x0c:
		v_it = vertices.find( b3 );
		if( v_it==vertices.end() ){
			//printf( "!" );
			return;
		}
		v1 = *(*v_it).second;
		v_it = vertices.find( b4 );
		if( v_it==vertices.end() ){
			//printf( "!" );
			return;
		}
		v1 += *(*v_it).second;
		v1 *= 0.5;
		v2 = v1;
		v2.flipX();
		break;

	case 0x05:	//	Negative of vertex indexed by b3
	case 0x06:
		v_it = vertices.find( b3 );
		if( v_it==vertices.end() ){
//			cout << "!";
			return;
		}
		v1 = *(*v_it).second;  //  Copy vertex
		v1.neg();
		v2	 = v1;
		v2.flipX();
		break;

	case 0x07:
	case 0x08:
		v1 = Vertex(  x, y, z );
		v2 = Vertex(  0, y, z );
		break;

	case 0x0d:	//	3d arith: vertex b2 + vertex b3 - vertex b4
	case 0x0e:
		v_it = vertices.find( b2 );
		if( v_it==vertices.end() ){
			//printf( "!" );
			return;
		}
		v1 = *(*v_it).second;  //  Copy vertex
		v_it = vertices.find( b3 );
		if( v_it==vertices.end() ){
			//printf( "!" );
			return;
		}
		v1   += *(*v_it).second;
		v_it  = vertices.find( b4 );
		if( v_it==vertices.end() ){
			//printf( "!" );
			return;
		}
		v1 -= *(*v_it).second;
		v2 = v1;
		v2.flipX();
		break;

	case 0x0f:	//	3d arith: vertex b3 + vertex b4 
	case 0x10:
		v_it = vertices.find( b3 );
		if( v_it==vertices.end() ){
//			cout << "!";
			return;
		}
		v1   = *(*v_it).second;
		v_it = vertices.find( b4 );
		if( v_it==vertices.end() ){
//			cout << "!";
			return;
		}
		v1 += *(*v_it).second;
		v2  = v1;
		v2.flipX();
		break;
	default:
	case 0x13:	//	Linear interpolation between vertices b3, b4
	case 0x14:
		//	cout << "!";
		v1 = Vertex( 0, 0, 0 );
		v2 = Vertex( 0, 0, 0 );
		break;
	}
}

//!  Debugging information
/*virtual*/ void FrontierMesh::debug( Uint32 command, void *data ){
	debug_selected_element_it++;
	if( debug_selected_element_it==elements.end() ){
		debug_selected_element_it = elements.begin();
	}
}


//!  Constructor
FrontierMesh::FrontierMesh( FrontierFile *f, int ob_id, const char *name ):Mesh(name){
	int   object_index;

	material = new Material(
		"Frontier Test Material",
		RENDER_MODE_LINE,
		RENDER_LIGHTING_COLOR,
		RENDER_OPTION_DEPTH_TEST_M |
		RENDER_OPTION_DIFFUSE_M    
	);
	material->setAmbient  ( Color::BLACK );
	material->setDiffuse  ( Color::GRAY_75 );
	material->setSpecular ( Color::WHITE );
	material->setShininess( 8.0f );

	this->f = f;

	object_index = ob_id-1;

	parseObject  ( object_index );
	parseSpecs	 ();
	parseVertices();
	parseNormals ();
	parseElements();

	this->setClipRadius( 2*radius );
	debug_selected_element_it = this->elements.begin();

//	printf(cout << name << " has " << submeshes.size() << " submeshes" << endl;
}


//!  Parse object structure from file
void FrontierMesh::parseObject( const int object_index ){
	char *object_pointer = "";
	char *tmp;
	int   i;

	//	Seek to object directory
	f->reset();
	f->seek( "DATA_004681:" ); tmp = f->get_label_def();

	//	Skip until we are at correct object index
	for( i=0; i<object_index+1; i++ ){
		object_pointer = f->get_label_ref();
	}
	strcat( object_pointer,  ":" );

	f->reset();
	f->seek( object_pointer ); tmp = f->get_label_def();

	mesh_pointer	  = f->get_label_ref();
	vertex_pointer	  = f->get_label_ref();
	vertex_count	  = f->read_Uint32	();
	normal_pointer	  = f->get_label_ref();
	normal_count	  = f->read_Uint32	();  //  normals + 2
	unknown_2		  = f->read_Uint32	();
	unknown_3		  = f->read_Uint32	();
	radius			  = f->read_Uint32	();
	primitive_count   = f->read_Uint32	();
	unknown_4		  = f->read_Uint32	();
	unknown_5		  = f->read_Uint32	();
	unknown_6		  = f->read_Uint32	();
	unknown_7		  = f->read_Uint32	();
	collision_pointer = f->get_label_ref();
	spec_pointer	  = f->get_label_ref();
	unknown_8		  = f->read_Uint32	();
	unknown_9		  = f->read_Uint32	();

	strcat( mesh_pointer,      ":" );
	strcat( vertex_pointer,    ":" );
	strcat( normal_pointer,    ":" );
	strcat( collision_pointer, ":" );
	strcat( spec_pointer,      ":" );

/*
	cout << "\n-- OBJECT -- " << ob_name << " --" << endl;	
	cout << "Mesh			" << mesh_pointer	   << endl;
	cout << "Vertices		" << vertex_pointer    << endl;
	cout << "Vertices		" << vertex_count	   << endl;
	cout << "Normals		" << normal_pointer    << endl;
	cout << "Normals		" << normal_count	   << endl;
	cout << "unknown_2		" << unknown_2		   << endl;
	cout << "unknown_3		" << unknown_3		   << endl;
	cout << "Radius 		" << radius 		   << endl;
	cout << "Primitives 	" << primitive_count   << endl;
	cout << "unknown_4		" << unknown_4		   << endl;
	cout << "unknown_5		" << unknown_5		   << endl;
	cout << "unknown_6		" << unknown_6		   << endl;
	cout << "unknown_7		" << unknown_7		   << endl;
	cout << "Collision data " << collision_pointer << endl;
	cout << "Specifications " << spec_pointer	   << endl;
	cout << "unknown_8		" << unknown_8		   << endl;
	cout << "unknown_9		" << unknown_9		   << endl;
*/
}


void FrontierMesh::parseSpecs(){
	char *name_pointer = "";
	char *tmp;
	int   i;

	if( strcmp( spec_pointer, "NULL:" ) == 0 ){
		// cout << "Object has no ship specifications" << endl;
		return;
	}

	f->reset(); 				 //  Rewind to start of file
	f->seek( spec_pointer ); tmp = f->get_label_def();

	Uint16 foward_thrust	 = f->read_Uint16();  // 0 1
	Uint16 reverse_thrust	 = f->read_Uint16();  // 2 3
	Uint8  gm				 = f->read_Uint8();   // 4
	Uint8  sm				 = f->read_Uint8();   // 5
	Uint16 mass 			 = f->read_Uint16();  // 6 7
	Uint16 internal_capacity = f->read_Uint16();  // 8 9
	Uint16 price			 = f->read_Uint16();  // a b  10 11
	Uint16 zoom_factor		 = f->read_Uint16();  // c d  12 13
	Uint8  id				 = f->read_Uint8();   // e	  14
	Uint8  s_unknown_1		 = f->read_Uint8();   // f	  15
	Uint8  crew 			 = f->read_Uint8();   // 10   16
	Uint8  s_unknown_2		 = f->read_Uint8();   // 11   17
	Uint8  missiles 		 = f->read_Uint8();   // 12   18
	Uint8  s_unknown_3		 = f->read_Uint8();   // 13   19
	Uint8  drive			 = f->read_Uint8();   // 14   20
	Uint8  integral_drive	 = f->read_Uint8();   // 15   21
	/*
DATA_002568: ; StowMaster Fighter
			[F.Thrust]	  [R.Thrust]   [GM]   [SM]	   [Mass]
		db [0xef, 0x1f], [0xb6, 0xea], [0x1], [0x0], [0xe, 0x0]
		   [Int.Cap.]	 [Price]	  [ZoomF]	 [ID]
		db [0xc, 0x0], [0x19, 0x0], [0x2d, 0x0], [0xc], 0x40
		   [Crew]	   [Mis]	  [Drive] [IntegralDrive]
		db [0x1], 0x0, [0x0], 0x0, [0x2],	   [0x80], 0x0, 0x1
		db 0xc0, 0x3, 0x0, 0x0, 0x80, 0x2, 0x0, 0x0
		db 0x60, 0x3, 0xa0, 0xff, 0x5c, 0x0, 0x1e, 0x0
		db 0xc0, 0x2, 0x4a, 0x0, 0x14, 0x0, 0x7, 0x0
*/
	f->reset(); 				 //  Rewind to start of file
	f->seek( "DATA_004682:" );	 //  Seek to name directory
	for( i=0; i<id+2; i++ ){
		name_pointer = f->get_label_ref();
	}
	strcat( name_pointer, ":" );
	f->reset(); 				 //  Rewind to start of file
	f->seek( name_pointer );
	tmp = f->get_label_def();
	char *object_name = f->get_string();
	setName( object_name );
}


//!
void FrontierMesh::parseVertices(){
	Vertex *v1;
	Vertex *v2;
	char   *tmp;
	int     i;

	f->reset();
	f->seek( vertex_pointer ); tmp = f->get_label_def();
	for( i=0; i<vertex_count; i++ ){
		if( f->get_type() == FF_BYTE ){
			v1 = new Vertex();
			v2 = new Vertex();
			makeVertex( *v1, *v2 );
			this->vertices.insert( pair<int,Vertex*>(i,v1) ); i++;
			this->vertices.insert( pair<int,Vertex*>(i,v2) ); 
		}else{
			ffe_debug_msg( "Problems at %d", i );
			break;
		}
	}
}


//!  Parse normals
void FrontierMesh::parseNormals(){
	Vertex *v1;
	Vertex *v2;
	char   *tmp;
	int 	i;

	if( strcmp( normal_pointer, "NULL:" ) != 0 ){
		f->reset();
		f->seek( normal_pointer ); tmp = f->get_label_def();
		i = 0;
		v1 = new Vertex(  0,  1, 0 );
		v2 = new Vertex(  0, -1, 0 );
		this->normals.insert( pair<int,Vertex*>(i,v1) ); i++;
		this->normals.insert( pair<int,Vertex*>(i,v2) ); i++;
		while( f->get_type() == FF_BYTE ){
			v1 = new Vertex();
			v2 = new Vertex();
			makeVertex( *v1, *v2 );
			v1->normalize();
			v2->normalize();
			this->normals.insert( pair<int,Vertex*>(i,v1) ); i++;
			this->normals.insert( pair<int,Vertex*>(i,v2) ); i++;
		}
	}
}


void FrontierMesh::printVertices(){
	int_to_Vertex::iterator  v_it;
	Vertex					*vertex;
	int 					 i;

	for( i=0; i<vertex_count; i++ ){
		v_it = vertices.find( i );
		vertex = (*v_it).second;
		ffe_debug_msg( "Vertex %d is ", i );
//		vertex->debug();
	}
}

void FrontierMesh::parseElements(){
	int        byte;
	int        count         =  0;     //  Pos on line for formatted output
	int        par_count     =  0;     //  Parameter number
	int        prev_block_id =  0;     //  ID of previous (finished) block
	int        block_id      =  0;     //  ID of current block
	int        block_left    =  0;     //  How many bytes are left in this block
	int        elements      =  0;     //  How many elements we have found in this model?
	bool       null_term     = false;  //  Is current block null-terminating?
	bool       out_of_sync   = false;  //  Have we lost sync in the file?
	int        par[256];               //  Parameter buffer
	bool       open;                   //  For 0500 primitive: is the face closed or open?
	bool       good;                   //  Are all face vertices good?
	Face      *face          = NULL;   //  Face to be added
	char      *tmp;

	//	Read in elements
	f->reset();
	f->seek( mesh_pointer ); tmp = f->get_label_def();

	while( f->get_type() == FF_BYTE ){
		byte = f->get_byte_low( false );

		if( !out_of_sync && !null_term ){
			//	If we are in sync, simply get next byte
			block_left--;

			//	If was first after last block, store first byte of next block id
			if( (block_left == -1) ){
//				cout << endl;
				count = 0;
				block_id = byte;
			}
		}

		//	Null terminating element?
		if( null_term && par_count>1 ){
			if( byte==0 ){				 //  Zero?
				if( (par_count&1)==0 && (block_left == -1) ){  //  First zero?
					block_left = -3;
				}else if( (par_count&1)==1 && (block_left == -3) ){
					block_left = 0;
					null_term = false;
				}else{
					block_left = -1;
				}
			}else{						 //  Not zero?
				block_left = -1;
			}
		}

		//	Printing with formatting
/*		  char out[80];
		sprintf( out, "%02x ", byte );
		if( count&1 == 1 ){
			cout << out << " ";
		}else{
			cout << out;
		}*/
		count++;

		//	Formatting
		if( out_of_sync ){
			if( count >= 8 ){
//				cout << endl;
				count = 0;
			}
			continue;
		}else{
			if( count >= 16 ){
//				cout << endl << "				"; cout.flush();
				count = 0;
			}
		}

		//	Are we getting (last byte of) ID of next block?
		//	This would be case of second byte after previous block
		if( (block_left == -2) && (!null_term) ){

//	Material
			Uint16 mat				= (par[0]) + (par[1]<<8);
			Uint32 texture_id		= 0;
			bool   use_texture		= false;
			bool   use_lighting 	= true;
			bool   use_object_color = false;
			Uint8  r = 128;
			Uint8  g = 128;
			Uint8  b = 128;

			if( ((mat & 0x4000) == 0x4000) ){ // 0x4000  - if set, low twelve bits are texture index, otherwise RGB
				use_texture = true;
				texture_id	= (mat & 0x0fff);
			}else{
				r = (mat & 0x0f00)>>16;
				g = (mat & 0x00f0)>> 8;
				b = (mat & 0x000f);
				float rf = (float)(r)/16.0f;
				float gf = (float)(g)/16.0f;
				float bf = (float)(b)/16.0f;
//				material->setDiffuse( Color(rf,gf,bf) );
//				cout << "Set diffuse to " << (int)(r) << ", " << int(g) << ", " << int(b) << endl;
			}
			if( ((mat & 0x2000) == 0x2000) ){ // 0x2000  - if set, surface should not be lit
				use_lighting = false;
			}
			if( ((mat & 0x1000) == 0x1000) ){ // 0x1000  - if set, surface colours should depend on object colour
				use_object_color = true;
			}

//	Process previous block
			switch( prev_block_id ){
			case 0x0200:   //  ThinLine
			case 0x1100: { //  WideLine
				bool line_good = true;

				Vertex					*v1;
				Vertex					*v2;
				int_to_Vertex::iterator  v_it;

				v_it = vertices.find( par[2] );
				if( v_it!=vertices.end() ){
					v1 = (*v_it).second;
					if( v1 == NULL ){
						line_good = false;
					}
				}else{
					v1 = NULL;
					line_good = false;
				}

				v_it = vertices.find( par[2+1] );
				if( v_it!=vertices.end() ){
					v2 = (*v_it).second;
					if( v2 == NULL ){
						line_good = false;
					}
				}else{
					v2 = NULL;
					line_good = false;
				}

				if( line_good ){
					LineMesh *lm = new LineMesh("");
					Line	 *l  = new Line( v1, v2 );
					lm->setMaterial( material );
					this->insert( lm );
//					cout << "ok line" << endl;
				}else{
//					cout << "line not ok" << endl;
				}
				break;
			}
			case 0x0300:  //  Triangle				
				faceBegin();
				faceInsertVertex( par[2+0] );
				faceInsertVertex( par[2+3] );
				faceInsertVertex( par[2+1] );
				faceClose( par[2+2] );
				break;

			case 0x0700:  //  MirrorTriangle				
				faceBegin();
				faceInsertVertex( par[2+0] );
				faceInsertVertex( par[2+3] );
				faceInsertVertex( par[2+1] );
				faceClose( par[2+2] );
				faceBegin();
				faceInsertVertex( par[2+0]+1 );
				faceInsertVertex( par[2+3]+1 );
				faceInsertVertex( par[2+1]+1 );
				faceClose( par[2+2]+1 );
				break;

			case 0x0400:  //  Quad
				faceBegin();
				faceInsertVertex( par[2+0] );
				faceInsertVertex( par[2+2] );
				faceInsertVertex( par[2+1] );
				faceInsertVertex( par[2+3] );
				faceClose( par[2+4] );
				break;

			case 0x0800:  //  MirrorQuad
				faceBegin();
				faceInsertVertex( par[2+0] );
				faceInsertVertex( par[2+2] );
				faceInsertVertex( par[2+1] );
				faceInsertVertex( par[2+3] );
				faceClose( par[2+4] );
				faceBegin();
				faceInsertVertex( par[2+0]+1 );
				faceInsertVertex( par[2+2]+1 );
				faceInsertVertex( par[2+1]+1 );
				faceInsertVertex( par[2+3]+1 );
				faceClose( par[2+4]+1 );
				break;

			case 0:
				break;

			case 0x0500: {	//	Complex
				Uint8 code;
				Uint8 ppos = 2;
				open	   = true;
				good	   = true;

				while( ppos<par_count ){
					ppos += 2;
					code = par[ppos+1];
/*					cout.setf( ios::hex, ios::basefield );
					cout.width( 2 );
					cout << "par[" << (int)(ppos+1) << "] = " << (int)(code) << endl;
*/
					switch( code ){
					case 0x00:
						// Type 0x0: Length 2 bytes. Terminates stream.
						// Surface will be closed off if not already terminated.
						faceClose();
						break;

					case 0x02:
						// Type 0x2: Length 6 bytes. Format v1, 02, v2, v1, v4, v3
						// Starts a surface with a spline. v1 and v4 are end points, v2 and v3 are
						// intermediate control points. Note that the first byte is a copy of the
						// third. Only the third is used for processing, but the first can be used
						// as the depth-sort index.
						faceBegin();
						faceInsertSpline( par[ppos], par[ppos+4], par[ppos+2], par[ppos+5] );
//						faceInsertVertex( par[ppos] );
						ppos += 2;
						ppos += 2;
//						faceInsertVertex( par[ppos] );
						break;

					case 0x04:
						// Type 0x4: Length 4 bytes. Format v1, 04, v2, 00
						// Starts a surface with a line. v1 and v2 are end points.
						faceBegin();
						faceInsertVertex( par[ppos] );
						ppos += 2;
						faceInsertVertex( par[ppos] );
						break;

					case 0x06:
						// Type 0x6: Length 2 bytes. Format v2, 06
						// Continues a surface with a line. v1 is taken from the previous element
						// in the stream. v1 and v2 are end points.
						faceInsertVertex( par[ppos] );
						break;

					case 0x08:
						// Type 0x8: Length 4 bytes. Format v2, 08, v4, v3
						// Continues a surface with a spline. v1 is taken from the previous element
						// in the stream. v1 and v4 are end points, v2 and v3 are intermediate
						// control points.
						faceInsertSpline( last_vertex_index, par[ppos+2], par[ppos], par[ppos+4] );
//						faceInsertVertex( par[ppos] );
						ppos += 2;
//						faceInsertVertex( par[ppos] );
						break;

					case 0x0a:
						// Type 0xa: Length 2 bytes. Format 00, 0a
						// Terminates a surface, completing with a line as necessary. Note that
						// multiple surfaces can be defined in a single stream as a result.
						faceClose();
						break;

					case 0x0c:
						// Type 0xc: Length 4 bytes. Format vc, 0c, n, r
						// Creates a complete 3d circle surface (ellipse in 2d) using two splines.
						// vc is centre vertex index, n is surface normal index, r is radius in
						// model units.
						break;
					}
				}
				break;
			}
			case 0x1600:  //  Basic spline
				// Basic spline: (0x)16, 00, m1, m2, v2, v4, v1, v3, n, 00
				// Used for powerlines etc. m1, m2 are the material word (should be simple
				// colour), v1 and v4 are end vertices, v2 and v3 are control points, n is
				// normal index for lighting only (no culling).
				break;

			case 0x0900:  //  Engine glow
				// Thrust-jet effect: 09, 00, m1, m2, v1, v2, s1, s2
				// m1 and m2 are the material word, usually 0xee, 0x20. v1 and v2 are
				// vertices for start and end of the thrust jet - v2 is generally a linear
				// animated vertex. s1 and s2 are a size word, probably representing the
				// width of the jet.
				break;
	
			default:
				break;
			}

			par_count	   = 0;
			prev_block_id  = block_id = (block_id<<8) + byte;
			null_term	   = false;

			int primitive = block_id & 0x1f00;
/*			sprintf( out, ":%04x: ", primitive );
			cout << "" << out << " "; cout.flush();*/

			if( (block_id & 0xff) == 0xff ){
				block_left = 0;
			}else{
			
			switch( primitive ){
			case 0x0000: block_left = 0 ; break;  //   set
			case 0x0100:
				block_left = 3; 
				break;
			case 0x0200: block_left = 2 ; break;  //   set ThinLine 																																										 
			case 0x0300: block_left = 3 ; break;  //   set
			case 0x0400: block_left = 4 ; break;  //   set Quad
			case 0x0500: null_term = true;break;  //   set Complex
			case 0x0600: block_left = 0 ; break;  //   set
			case 0x0700: block_left = 3 ; break;  //   set
			case 0x0800: block_left = 4 ; break;  //   set MirrorQuad
			case 0x0900: block_left = 3 ; break;  //   set
			case 0x0a00: block_left = 4 ; break;  //   set
			case 0x0b00: block_left = 1 ; break;  //   set
			case 0x0c00: block_left = 1 ; break;  //   set
			case 0x0d00: block_left = 1 ; break;  //   set?
			case 0x0e00: block_left = 1 ; break;  //   set?
			case 0x0f00: block_left = 1 ; break;  //
			case 0x1000: block_left = 1 ; break;  //   set
			case 0x1100: block_left = 6 ; break;  //   set WideLine
			case 0x1200: block_left = 1 ; break;  //   
			case 0x1300: block_left = 1 ; break;  //   set
			case 0x1400: block_left = 1 ; break;  //   set
			case 0x1500: block_left = 0 ; break;  //   set
			case 0x1600: block_left = 12; break;  //
			case 0x1700: block_left = 1 ; break;  //
			case 0x1800: block_left = 0 ; break;  //   set
			case 0x1900: block_left = 0 ; break;  //   set
			case 0x1a00:
				if( block_id==0x1a00 ){
					block_left = 9;
				}else{
					block_left = 1;
				}
				break;
			case 0x1b00: block_left = 3 ; break;  //   set
			case 0x1c00: block_left = 3 ; break;  //   set
			case 0x1d00: block_left = 1 ; break;  //   set
			case 0x1e00: block_left = 0 ; break;  //   set
			case 0x1f00: block_left = 1 ; break;  //   set
			default:
				ffe_debug_msg( "Unknown block ID - out of sync" );
				out_of_sync = true;
				break;
			}

			}

			count = 0;
			if( null_term ){
				block_left = -1;
			}else{
				block_left *= 2;
			}
		}else{	//	Not end -- //  Store parameters 		
			par[par_count++] = byte;
			if( null_term && (par_count>4) ){
				if( par[3] == 0xc0 ){
					block_left = 0;
					null_term = false;
				}
			}
		}
	}

}


};	//	namespace Application


/*

Finally, Stone-D did some work on the specs section:

DATA_002568: ; StowMaster Fighter
			[F.Thrust]	  [R.Thrust]   [GM]   [SM]	   [Mass]
		db [0xef, 0x1f], [0xb6, 0xea], [0x1], [0x0], [0xe, 0x0]
		   [Int.Cap.]	 [Price]	  [ZoomF]	 [ID]
		db [0xc, 0x0], [0x19, 0x0], [0x2d, 0x0], [0xc], 0x40
		   [Crew]	   [Mis]	  [Drive] [IntegralDrive]
		db [0x1], 0x0, [0x0], 0x0, [0x2],	   [0x80], 0x0, 0x1

		db 0xc0, 0x3, 0x0, 0x0, 0x80, 0x2, 0x0, 0x0
		db 0x60, 0x3, 0xa0, 0xff, 0x5c, 0x0, 0x1e, 0x0
		db 0xc0, 0x2, 0x4a, 0x0, 0x14, 0x0, 0x7, 0x0


Ok, I've finished decoding the mysterious primitive 05. As expected, its
purpose is to draw flat-colour complex surfaces with a mixture of spline
and straight-line edges.

The first six bytes of the primitive are as follows:

Offset:
0x0 	word 0005, primitive identifier
0x2 	word for material type, should always be a single colour
0x4 	byte containing culling/lighting normal for whole surface in low
7 bits. Top bit is a flag to disable complex z-clipping.
0x5 	byte for length of following stream. Only used with normal
culling.

A stream of sub-primitives of varying lengths follows. The second byte
of each identifies the subfunction. The very first byte of the stream is
used for depth-sorting the entire surface:

Type 0x2: Length 6 bytes. Format v1, 02, v2, v1, v4, v3
Starts a surface with a spline. v1 and v4 are end points, v2 and v3 are
intermediate control points. Note that the first byte is a copy of the
third. Only the third is used for processing, but the first can be used
as the depth-sort index.

Type 0x4: Length 4 bytes. Format v1, 04, v2, 00
Starts a surface with a line. v1 and v2 are end points.

Type 0x6: Length 2 bytes. Format v2, 06
Continues a surface with a line. v1 is taken from the previous element
in the stream. v1 and v2 are end points.

Type 0x8: Length 4 bytes. Format v2, 08, v4, v3
Continues a surface with a spline. v1 is taken from the previous element
in the stream. v1 and v4 are end points, v2 and v3 are intermediate
control points.

Type 0xa: Length 2 bytes. Format 00, 0a
Terminates a surface, completing with a line as necessary. Note that
multiple surfaces can be defined in a single stream as a result.

Type 0xc: Length 4 bytes. Format vc, 0c, n, r
Creates a complete 3d circle surface (ellipse in 2d) using two splines.
vc is centre vertex index, n is surface normal index, r is radius in
model units.

A little caveat - spline segment vertex order isn't absolutely certain.
I'd need to go through a massive chain of functions to check.

A little bonus piece on the mysterious material word:

The material word, used in many primitive types, appears to have a
consistent format independent of the primitive. The top four bits of the
word, or the four most significant bits of the second byte are flags,
while the low twelve bits are either a texture index or a 4.4.4 RGB
colour. Details follow:

0x4000	- if set, low twelve bits are texture index, otherwise RGB
0x2000	- if set, surface should not be lit
0x1000	- if set, surface colours should depend on object colour

Texture indices relate to the set of 30-byte structures at D7811. These
structures each contain the following:

struct TextureData
{
long rawTextureIndex;			; Index into main bitmap array
long numColours;				; Usually 7
char pColors[7*3];				; RGB, only uses 3 bits per byte
char filler = 0;				; Rounds structure to 30 bytes
};

Colour operations are all additive (not even lookup table) and truncated
to 4 bits per channel, which is very low precision. This limit is
largely a result of the RGB->dynamic palette conversion routines which
can only handle 4 bits per channel at any speed.

Example material words:

0x20f0	- Bright green surface unmodified by light or object colour
0x0707	- Purple surface modified by light but not object colour
0x5009	- Textured surface, index 9, modified by light and object colour
*/

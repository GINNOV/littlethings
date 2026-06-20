
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


#include "Models/Face.h"
#include "Models/Vertex.h"
#include "PhysicalComponents/Projection.h"
#include "SysSupport/Messages.h"
#include <cstdio>
#include <algorithm>
using namespace std;


namespace Models {


#define FACE_NORMAL_EPSILON (double)(0.0002)


//!  Face constructor
Face::Face():
Options(0),
normal (0,1,0)
{
}

//!  Virtual destructor
/*virtual*/ Face::~Face(){
}


//!  Insert a vertex to the face, pointer version
/*!
	\param v Vertex which is added to this Face
*/
void Face::insert( Vertex *v ){
	vertices.push_front( v );
	v->addFace( this );
}


//!  Insert a vertex to the face, component version
/*!
	\param 
*/
void Face::insert( const float x, const float y, const float z ){
	Vertex *v = new Vertex(x,y,z);
	vertices.push_front( v );
	v->addFace( this );
}


//!  Insert a vertex to the face - pointer version, reverse order
void Face::append( Vertex *v ){
	vertices.push_back( v );
	v->addFace( this );
}


//!  Drawing a Face Element
/*virtual*/ void Face::draw( Projection *p ){
	p->beginPolygon();

	if( isEnabled(FC_USE_FACE_NORMAL|FC_HAS_FACE_NORMAL) ){
		vert_debug_msg( "Drawing flat face" );
		p->normal( normal.v[0], normal.v[1], normal.v[2] );
	}else{
		vert_debug_msg( "Drawing smoothed face" );
	}

	list<Vertex*>::const_iterator v_it = vertices.begin();
	while( v_it != vertices.end() ){
		(*v_it)->draw( p );
		v_it++;
	}

	p->end();
}


//!  Query
bool Face::contains( const Vertex *v ) const {
	if(  find( vertices.begin(), vertices.end(), v ) 
		 != vertices.end()  ){
		return true;
	}else{
		return false;
	}
}


/*!
	Reverse order of vertices in Face.
	Remember to update normal as well if needed - that is not done by this.
*/
void Face::reverse(){
	vertices.reverse();
}


//!  Set face normal
void Face::setNormal( const Vector *normal ){
	enableOptions( FC_HAS_FACE_NORMAL );
	this->normal = *normal;
}


/*!
	Calculate a normal for the FlatFace.
	This requires at least three vertices,
	and the vertices must not be on a single line.
*/
void Face::makeNormal(){
	list<Vertex*>::iterator v_i1 = vertices.begin();
	list<Vertex*>::iterator v_i2 = v_i1;

	if( vertices.size()<3 ){
		debug_msg(
			"Face does not have enough vertices for normal calculation (%d vertices found)",
			vertices.size()
		);
		normal = Vector(0,1,0);
		return;
	}

	float len;

	//  This loop makes sure that we use proper vertices to
	//  get face normal calculated correctly. If we would blindly
	//  take three first vertices, they might be on a straight
	//  line, which is not good for normal calculation
	do{
		v_i2 = v_i1++;

		if( v_i2 == vertices.end() ){ error_msg( "Can not calculate normal" ); return; }
		Vector a  = (*v_i2++)->getVertex();

		if( v_i2 == vertices.end() ){ error_msg( "Can not calculate normal" ); return; }
		Vector b  = (*v_i2++)->getVertex();

		if( v_i2 == vertices.end() ){ error_msg( "Can not calculate normal" ); return; }
		Vector c  = (*v_i2++)->getVertex();

		normal    = (a-c)^(a-b);
		normal.normalize();
		len = normal.magnitude();
	}while( len < 0.9f || len > 1.1f );

	enableOptions( FC_HAS_FACE_NORMAL | FC_USE_FACE_NORMAL );
}


//!  Query
const Vector &Face::getNormal() const {
	return normal;
}


/*!
	Smooth face normals.

	Adjacent faces which normal difference is less or equal
	than max smoothing angle participate to the smoothed vertex
	normals.

	If the specified max smoothing angle is less or equal to
	zero, smoothing will not be done.

	If all adjacent faces either have normal difference more
	than the max smoothing angle or have equal normal, the face
	will remain Flat.

	This process calculates a normal for each vertex in the
	Face.

	If the existing Vertex has no normal set, the normal
	will set to existing Vertex.
	
	If the Vertex normal is already set to the same value, the
	Vertex will not be changed.

	If the Vertex has a different normal set it means that
	the Vertex is shared with some other Face which has already
	been processed. In this case a new Vertex will be created,
	and it will point to the old Vertex, or parent of the old
	Vertex, if it has such. The new normal will be set to the
	new Vertex.
*/
void Face::smooth( float max_smoothing_angle ){
	//  Face which has no normal calculated can not be smoothed
	//  Face normal is needed even if face is not smoothed
	if( isDisabled(FC_HAS_FACE_NORMAL) ){
		makeNormal();
	}

	//  If the max smoothing angle is set to less or equal to zero,
	//  smoothing can not be applied.
	if( max_smoothing_angle <= 0 ){
		enableOptions( FC_USE_FACE_NORMAL );
		disableOptions( FC_USE_VERTEX_NORMALS );
		return;
	}

	int  flat_count   = 0;
	int  share_count  = 0;
	int  smooth_count = 0;
	bool flat         = true;

	//  For each vertex in the Face
	list<Vertex*>::iterator  v_it = vertices.begin();
	while( v_it != vertices.end() ){
		Vertex *old_vertex = *v_it;

		//  Make a new Vertex. We will add each normal of
		//  Faces that participate in the smoothing and
		//  normalize the normal in the end.
		Vertex *new_vertex = new Vertex( old_vertex );

		//  Set the normal of each vertex to the normal of this face in the start
		new_vertex->setNormal( this->getNormal() );

		//  For each other Face that use this Vertex,
		//  test the normal difference. On the way we
		//  also calculate the new normal the the new
		//  Vertex
		share_count  = 1;
		smooth_count = 0;
		flat_count   = 0;
		list<Face*>::iterator f_it = old_vertex->getFaces().begin();
		while( f_it != old_vertex->getFaces().end() ){
			Face *other = *f_it;

			//  Skip if same Face
			if( other == this ){
				f_it++;				
				continue;
			}

			//  Bad Face?
			if( other == NULL ){
				warn_msg( MSG_HEAD "NULL face in vertex cross-reference" );
				f_it++;
				continue;
			}

			//  The other face must have a normal as well
			if( other->isDisabled(FC_HAS_FACE_NORMAL) ){
				other->makeNormal();
			}

			//  Calculate Face normal difference.
			//  We have earlier ensured that both Faces do have a normal.
			share_count++;
			Vector n1      = this ->getNormal();
			Vector n2      = other->getNormal();
			float  fn_ang  = (float)(  fabs( n1.angle(n2) )  );
			float  fn_diff = max_smoothing_angle - fn_ang;

			//  Is the enough different and not too much different?
			if( fn_ang > FACE_NORMAL_EPSILON && fn_diff > FLT_MIN ){
				new_vertex->addNormal( n2 );
				smooth_count++;
				//  If the face was considered flat earlier,
				//  we need to set normal to the vertices processed
				//  so far
				if( flat == true ){
					flat = false;

					Vector                  normal   = this->getNormal();
					list<Vertex*>::iterator v_it_fix = vertices.begin();
					if( v_it_fix != v_it ){
						Vertex *v = *v_it_fix;
						v->setNormal( normal );
						v_it_fix++;
					}
				}
			}else{  //  Otherwise it is too close or too different
				flat_count++;
			}
			f_it++;
		}

		//  Finalize the new Vertex normal; normalize it
		new_vertex->normNormal();

		//  If the Face is not flat, we will need to store the new Vertex normal
//		if( flat == false ){
			vert_debug_msg(
				"Face %ld smoothed vertices %ld flat vertices %ld faces share",
				smooth_count,
				flat_count,
				share_count
			);
			//  If the old Vertex has no normal, we can store the normal information there
			if( old_vertex->isDisabled(VX_HAS_NORMAL) ){
				old_vertex->setNormal( new_vertex->getNormal() );
				vert_debug_msg(
					"Old vertex %ld had no normal, setting it to (%.5f, %.5f, %.5f)",
					(unsigned long)(old_vertex),
					new_vertex->getNormal().v[0],
					new_vertex->getNormal().v[1],
					new_vertex->getNormal().v[2]
					);
				delete new_vertex;
			}else{
				//  If the old Vertex normal different, replace the
				//  Vertex in this Faces vertex list with the new Vertex
				//  This will not change the old Vertex, and other Faces'
				//  Vertex lists will not be changed.
				Vector old_normal = old_vertex->getNormal();
				Vector new_normal = new_vertex->getNormal();
				float vn_ang  = (float)(  fabs( old_normal.angle(new_normal) )  );
				if( vn_ang > FACE_NORMAL_EPSILON /*&& vn_diff > FLT_MIN*/ ){
					vert_debug_msg(
						"Old vertex %ld had different %.5f normal, replacing with copy (%.5f, %.5f, %.5f)",
						old_vertex,
						vn_ang,
						new_vertex->getNormal().v[0],
						new_vertex->getNormal().v[1],
						new_vertex->getNormal().v[2]
					);
					//new_vertex->debug();
					*v_it = new_vertex;
				}else{
					vert_debug_msg(
						"Old vertex %ld had the same normal %.5f",
						vn_ang,
						old_vertex
					);
					delete new_vertex;

				}
				//  Otherwise, the old vertex has the same normal as the new
				//  vertex and we do nothing
			}
		/*}else{
			delete new_vertex;
		} */
		
		v_it++;
	}


	if( flat == false ){
		disableOptions( FC_USE_FACE_NORMAL );
		enableOptions ( FC_USE_VERTEX_NORMALS );

		list<Vertex*>::iterator  v_it_check = vertices.begin();
		while( v_it_check != vertices.end() ){
			Vertex *check_vertex = *v_it_check;
			if( check_vertex->isDisabled(VX_HAS_NORMAL) ){
				check_vertex->debug();
				vert_debug_msg( "This smooth Face has Vertex with no normal!" );
			}
			v_it_check++;
		}
	}else{
		list<Vertex*>::iterator  v_it_check = vertices.begin();
		while( v_it_check != vertices.end() ){
			Vertex *check_vertex = *v_it_check;
			check_vertex->setNormal( this->getNormal() );
/*			if( check_vertex->isDisabled(VX_HAS_NORMAL) ){
				check_vertex->debug();
				vert_debug_msg( "This smooth Face has Vertex with no normal!" );
			}*/
			v_it_check++;
		}

//?		v->disableOptions( VX_USE_THIS_NORMAL | VX_USE_PARENT_NORMAL );
		enableOptions( FC_HAS_FACE_NORMAL | FC_USE_FACE_NORMAL );
		//debug_msg( "This face is now FLAT" );
		//debug_msg( "This face is now SMOOTH" );
	}
}


};  //  namespace Models



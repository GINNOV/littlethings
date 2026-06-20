
/*!
	\file
	\ingroup
	\author
	\brief
	\date    2001
*/


#include "TinyGL/gl_zgl.h"
#include "TinyGL/gl_msghandling.h"
#include <math.h>
#include <stdlib.h>


static void calc_buf( GLSpecBuf *buf, const float shininess ){
	int   i;
	float val = 0;
	float inc = 1/SPECULAR_BUFFER_SIZE;

	for( i=0; i <= SPECULAR_BUFFER_SIZE; i++ ){
		buf->buf[i] = (float)(  pow( val, shininess )  );
		val += inc;
	}
}

GLSpecBuf *specbuf_get_buffer( GLContext *c, const int shininess_i, const float shininess ){
	GLSpecBuf *found;
	GLSpecBuf *oldest;

	found = oldest = c->specbuf_first;
	while( found && found->shininess_i != shininess_i ){
		if( found->last_used < oldest->last_used ){
			oldest = found;
		}
		found = found->next; 
	}

	if( found ){ /* hey, found one! */
		found->last_used = c->specbuf_used_counter++;
		return found;
	}

	if (oldest == NULL || c->specbuf_num_buffers < MAX_SPECULAR_BUFFERS) {
		/* create new buffer */
		GLSpecBuf *buf = (GLSpecBuf *)malloc( sizeof(GLSpecBuf) );
		if( buf == NULL){
			gl_fatal_error( "could not allocate specular buffer" );
		}
		c  ->specbuf_num_buffers++;
		buf->next          = c->specbuf_first;
		c  ->specbuf_first = buf;
		buf->last_used     = c->specbuf_used_counter++;
		buf->shininess_i   = shininess_i;
		calc_buf( buf, shininess );
		return buf;     
	}
	/* overwrite the lru buffer */
	/*tgl_trace("overwriting spec buffer :(\n");*/
	oldest->shininess_i = shininess_i;
	oldest->last_used   = c->specbuf_used_counter++;
	calc_buf( oldest, shininess );
	return oldest;
}


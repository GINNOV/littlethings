
/*!
	\file
	\ingroup
	\author
	\brief
	\date    2001
*/


#ifndef _tgl_specbuf_h_
#define _tgl_specbuf_h_


#ifdef __cplusplus
extern "C" {
#endif

#define MAX_SPECULAR_BUFFERS          8  /* Max # of specular light pow buffers */
#define SPECULAR_BUFFER_SIZE       1024  /* # of entries in specular buffer */
#define SPECULAR_BUFFER_RESOLUTION 1024  /* specular buffer granularity */

typedef struct GLSpecBuf {
	int    shininess_i;
	int    last_used;
	float  buf[SPECULAR_BUFFER_SIZE+1];
	struct GLSpecBuf *next;
} GLSpecBuf;

GLSpecBuf *specbuf_get_buffer( GLContext *c, const int shininess_i, const float shininess );
void       specbuf_cleanup   ( GLContext *c ); /* free all memory used */


#ifdef __cplusplus
}
#endif


#endif /* _tgl_specbuf_h_ */


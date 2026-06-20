
/*!
	\file
	\ingroup
	\author
	\brief
	\date    2001
*/


#ifndef TEDDY_TINYGL_OSBUFFER_H
#define TEDDY_TINYGL_OSBUFFER_H


#ifdef __cplusplus
extern "C" {
#endif


typedef struct {
	void **zbs;
	void **framebuffers;
	int    numbuffers;
	int    xsize;
	int    ysize;
} ostgl_context;

ostgl_context *ostgl_create_context(
	const int   xsize,
	const int   ysize,
	const int   depth,
	void      **framebuffers,
	const int   numbuffers
);

extern void ostgl_delete_context( ostgl_context *context );
extern void ostgl_make_current  ( ostgl_context *context, const int index );
extern void ostgl_resize        ( ostgl_context *context, const int xsize, const int ysize, void **framebuffers );

#ifdef __cplusplus
}
#endif


#endif  /* TEDDY_TINYGL_OSBUFFER_H */



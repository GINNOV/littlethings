
/*!
	\file
	\ingroup
	\author
	\brief
	\date    2001
*/


#ifndef _msghandling_h_
#define _msghandling_h_


#ifdef __cplusplus
extern "C" {
#endif

extern void tgl_warning( const char *text, ... );
extern void tgl_trace  ( const char *text, ... );
extern void tgl_fixme  ( const char *text, ... );

#ifdef __cplusplus
}
#endif


#endif /* _msghandling_h_ */


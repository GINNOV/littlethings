
/*!
	\file
	\ingroup
	\brief
	\author
	\date
*/


#ifndef TEDDY_GRAPHICS_GLU_MIPMAP_H
#define TEDDY_GRAPHICS_GLU_MIPMAP_H


#include "Graphics/Device.h"


/* ErrorCode */
#define GLU_ERROR                          100103
#define GLU_INVALID_ENUM                   100900
#define GLU_INVALID_VALUE                  100901
#define GLU_OUT_OF_MEMORY                  100902
#define GLU_INVALID_OPERATION              100904


GLint glu_ScaleImage(
	GLenum      format,
	GLsizei     widthin,
	GLsizei     heightin,
	GLenum      typein,
	const void *datain,
	GLsizei     widthout,
	GLsizei     heightout,
	GLenum      typeout,
	void       *dataout
);


GLint glu_Build1DMipmaps(
	GLenum      target,
	GLint       components,
	GLsizei     width,
	GLenum      format,
	GLenum      type,
	const void *data
);


GLint glu_Build2DMipmaps(
	GLenum      target,
	GLint       components,
	GLsizei     width,
	GLsizei     height,
	GLenum      format,
	GLenum      type,
	const void *data
);


#endif  /*  TEDDY_GRAPHICS_GLU_MIPMAP_H  */



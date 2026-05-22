#ifndef _TEXLOAD_H_
#define _TEXLOAD_H_

GLuint mglMakeTextureFromFile(GLenum internalFormat, 
	const char *fileName, 
	uint32 *Width, 
	uint32 *Height);

GLuint mglMakeMipMapFromFiles(GLenum internalFormat, 
	const char *fileName, 
	uint32 *Width, 
	uint32 *Height);

#endif //_TEXLOAD_H_

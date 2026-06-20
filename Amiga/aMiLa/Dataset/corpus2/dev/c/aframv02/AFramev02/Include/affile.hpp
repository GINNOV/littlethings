
#ifndef __AFFILE_HPP__
#define __AFFILE_HPP__

#include "aframe:include/string.hpp"
#include "exec/types.h"

class AFFile : public AFObject
{
public:
	AFFile(char* filename, char* mode = "rb");
	~AFFile();

	BOOL IsValid();

	unsigned int Read(char* buffer, unsigned int length);
	unsigned int Read(long* buffer, unsigned int length);

	unsigned int Write(char* buffer, unsigned int length);
	unsigned int Write(long* buffer, unsigned int length);

	char GetChar();
 
private:
	AFString m_filename;
	FILE * m_handle;
};

#endif // __AFFILE_HPP__

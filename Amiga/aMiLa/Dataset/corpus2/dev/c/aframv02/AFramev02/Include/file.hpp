//////////////////////////////////////////////////////////////////////////////
// File.hpp
//
// Jeffry A Worth
//////////////////////////////////////////////////////////////////////////////

#ifndef __FILE_HPP__
#define __FILE_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/object.hpp"
#include <exec/types.h>
#include <stdio.h>
#include <stdlib.h>

//////////////////////////////////////////////////////////////////////////////
// File Class

class AFFile : public AFObject
{
public:
    AFFile(char *filename, char* mode);
    ~AFFile();

    virtual BOOL IsValid();
    unsigned int Read(char *buffer, unsigned int length);
    unsigned int Read(long *buffer, unsigned int length);
    unsigned int Write(char *buffer, unsigned int length);
    unsigned int Write(long *buffer, unsigned int length);

private:
    FILE *m_handle;
    char *m_filename;
};
//////////////////////////////////////////////////////////////////////////////
#endif // __FILE_HPP__

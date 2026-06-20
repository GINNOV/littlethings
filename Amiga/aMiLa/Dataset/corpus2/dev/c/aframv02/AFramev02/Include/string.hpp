#ifndef __AFSTRING_HPP__
#define __AFSTRING_HPP__

#include "aframe:include/object.hpp"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

class AFString
{
    public:
        AFString(char* string=NULL);
		AFString(AFString* string);

		AFString* operator=(char* string);
		AFString* operator=(AFString* string);

		AFString operator+=(char* string);
		AFString operator+=(AFString* string);

        char operator[](int i);
        int operator!=(char* string);
        int operator!=(AFString* string);
        int operator==(char* string);
        int operator==(char string);

		int length();
		AFString* upper();
		AFString* lower();

		char* data();

        void DestroyObject();

		// Type Conversions

        operator const char*() { return data(); };

  private:
		char* m_data;
};

#endif // __AFSTRING_HPP__

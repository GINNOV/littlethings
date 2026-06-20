#include "aframe:include/string.hpp"

AFString::AFString(char* string)
    :m_data(NULL)
{
	if(string) {
		m_data = new char[strlen(string)+1];
    	strcpy(m_data,string);
	}
}

AFString::AFString(AFString* string)
	:m_data(NULL)
{
	m_data = new char[string->length()+1];
	strcpy(m_data,string->data());
}

AFString*
AFString::operator=(char* string)
{
	if(m_data)
		delete m_data;
	m_data = new char[strlen(string)+1];
	strcpy(m_data,string);
	
	return this;
}

AFString
AFString::operator+=(char* string)
{
	char* temp;

	temp=m_data;
	m_data = new char[strlen(temp)+strlen(string)+1];
	strcpy(m_data,temp);
	strcpy(&m_data[strlen(m_data)],string);

	delete temp;
	
	return this;
}

AFString*
AFString::operator=(AFString* string)
{
	return (*this)=string->data();
}

AFString
AFString::operator+=(AFString* string)
{
	return (*this)+=string->data();
}

int
AFString::length()
{
	return strlen(m_data);
}

AFString*
AFString::upper()
{
	int i;

	for(i=0;i<length();i++)
		m_data[i] = toupper(m_data[i]);

	return this;
}

AFString*
AFString::lower()
{
	int i;

	for(i=0;i<length();i++)
		m_data[i] = tolower(m_data[i]);

	return this;
}


char*
AFString::data()
{
	return m_data;
}

char
AFString::operator[]    // Added Feb 15, 1996
    (int i
    )
{
    return (m_data[i]);
}

int
AFString::operator!=    // Added Feb 16, 1996
    (AFString* string
    )
{
    return (strcmp((char *)this,string->data()));
}

int
AFString::operator!=    // Added Feb 16, 1996
    (char* string
    )
{
    return (strcmp((char *)this,string));
}

int
AFString::operator==    // Added Feb 16, 1996
    (char* string
    )
{
    return (strcmp((char *)this,string));
}

int
AFString::operator==    // Added Feb 16, 1996
    (char string
    )
{
    return (strcmp((char *)this,(char *)string));
}

///////////////////////////////////////////////////////////
// DestroyObject
//	Do not call DestroyObject from the Destructor.  This
//	routine is called by AFPtrDlist when the item is
//  removed or cleanAndDestroy is called.
void
AFString::DestroyObject()
{
	delete this;
}

#ifndef _INCLUDE_NEW_H
#define _INCLUDE_NEW_H

/*
**  $VER: new.h 2.00 (28.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef __cplusplus
#error <fstream.h> must be compiled in C++ mode.
#pragma +
#endif

#ifdef __GNUC__
#pragma interface "new.h"
#endif

#include <stddef.h>
#include <exception.h>

#ifndef NULL
#define NULL 0
#endif


#ifdef __STORM__

void (*set_new_handler(void(*)(void)))(void);

#endif	/* __STORM__ */



#ifdef __GNUC__

extern "C++" {

#ifdef __HONOR_STD
namespace std {
#endif

class bad_alloc : public exception
{
public:
    virtual const char* what() const throw() { return "bad_alloc"; }
};

struct nothrow_t {};
extern const nothrow_t nothrow;
typedef void (*new_handler)();
new_handler set_new_handler (new_handler);

#ifdef __HONOR_STD
} // namespace std

using std::new_handler;
using std::set_new_handler;
#endif

// replaceable signatures
void *operator new (size_t);// throw (std::bad_alloc);
void *operator new[] (size_t);// throw (std::bad_alloc);
void operator delete (void *);// throw();
void operator delete[] (void *);// throw();
void *operator new (size_t, const std::nothrow_t&);// throw();
void *operator new[] (size_t, const std::nothrow_t&);// throw();
void operator delete (void *, const std::nothrow_t&);// throw();
void operator delete[] (void *, const std::nothrow_t&);// throw();

// default placement versions of operator new
inline void *operator new(size_t, void *place) /*throw()*/ { return place; }
inline void *operator new[](size_t, void *place) /*throw()*/ { return place; }

} // extern "C++"

#endif	/* __GNUC__ */

#endif	/* _INCLUDE_NEW_H */

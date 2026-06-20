#ifndef _INCLUDE_EXCEPTION_H
#define _INCLUDE_EXCEPTION_H

/*
**  $VER: exception.h 2.00 (28.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef __cplusplus
#error <exception.h> must be compiled in C++ mode.
#pragma +
#endif



#ifdef __STORM__
class Exception
{
public:
    virtual ~Exception() { }
};

void unexpected();
void terminate();

void (*set_unexpected(void(*)()))();
void (*set_terminate(void(*)()))();
#endif  /* __STORM__ */


#ifdef __GNUC__

#pragma interface "exception.h"

extern "C++" {

#ifdef __HONOR_STD
namespace std {
#endif

class exception
{
public:
    exception () { }
    virtual ~exception () { }
    virtual const char* what () const;
};


class bad_exception : public exception
{
public:
    bad_exception () { }
    virtual ~bad_exception () { }
};


typedef void (*terminate_handler) ();
typedef void (*unexpected_handler) ();

terminate_handler set_terminate (terminate_handler);
void terminate () __attribute__ ((__noreturn__));
unexpected_handler set_unexpected (unexpected_handler);
void unexpected () __attribute__ ((__noreturn__));
bool uncaught_exception ();

#ifdef __HONOR_STD
} // namespace std


class Exception : public std::exception
{
public:
    Exception () { }
    virtual ~Exception () { }
};
#else

class Exception : public exception
{
public:
    Exception () { }
    virtual ~Exception () { }
};

#endif

} // extern "C++"

#endif  /* __GNUC__ */

#endif  /* _INCLUDE_EXCEPTION_H */

#ifndef APPObject_H
#define APPObject_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/environment/APPObject.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <exec/types.h>
//#include <stdlib.h>
#include <stdio.h>
//#include <string.h>
}
#include <APlusPlus/environment/Classes.h>
#include <APlusPlus/environment/TypeInfo.h>


#if !defined(__IOSTREAM_H) && !defined(_IOSTREAM_H)
class ostream;
#endif


#define APPOBJECT_INVALID 0

#ifndef abs
#define abs(x) ((x)<0?-(x):(x))
#endif

#ifndef max
#define max(x,y) ((x)>(y)?(x):(y))
#endif

#ifndef min
#define min(x,y) ((x)<=(y)?(x):(y))
#endif


/******************************************************************************
      » APPObject class «

   The APPObject class is one root class for the A++ classes, actually it's the
   root class for most A++ classes.
   It provides an object status report and introduces a runtime type inquiry
   mechanism. All derived classes have to support this runtime type inquiry, too.
   
   The APPObject plays an important role during the constructor execution of
   any object: 
   
   -  constructors are invoked in order from base class towards derived 
      classes. So, APPObject::APPObject is called first and sets object status
      to APPOBJECT_INVALID which is no error status! 
   -  Each derived class' constructor now has to check for the validity of the 
      object in construction.
      - if Ok() returns TRUE do the constructor work and on successfull 
        initialisation set the object to a valid state with 'setID(id_number)',
        where 'id_number' is >0. If your constructor failed to allocate some
        resources etc., use 'setError(error_number)' to set a class specific
        error code.
      - if Ok() returns FALSE only initialise for safe destruction (do not 
        allocate any resources) and keep off the 'setID' method so that
        the error code can be read from the class using code.
        
   Avoid multiple inheritance of APPObject!
   See for a tutorial below.

 ******************************************************************************/

class APPObject
{
   public:
      BOOL Ok() // object' methods are allowed to be invoked only on TRUE return.
         { return (_status > 0); }

      ULONG error()
         { return _status < 0 ? -_status : 0; }
      // returns the error number specific for the failed class constructor
      // or 0 if no error ocurred

      ULONG ID() // returns the class ID if the object is valid
         { return _status > 0 ? _status : 0; }

      LONG status()
         { return _status; }

      BOOL isClass(LONG id) // check for class membership
         { return id==_status; }

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const    // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()             // get the 'type_id' of a specific class
         { return info_obj; }

   protected:      
      APPObject() 
         { _status = APPOBJECT_INVALID; }
      virtual ~APPObject() 
         { _status = APPOBJECT_INVALID; }
      void setError(LONG code) 
         { _status = -abs(code); }
      void setID(LONG id) 
         { _status = abs(id); }
         
   private:      
      long _status;
};


// check with APPOK(object) if object points to an object and if this object is Ok
// On uncertainties wether to invoke a method on an object is safe check with APPOK(object).
#define APPOK(obj) (obj!=NULL && obj->Ok())

#define puterr(string)  puts(string)

#define CHECK(obj) if((obj->status<=0) puts("Object: invalid in "__FILE__" at "__LINE__"\n");

// set error code within constructors.
#define _ierror(code) { setError(code); puts(#code "\\"); }

#define BUGOUT puts(__FILE__ __LINE__"\n")

#ifdef DEBUG
#include <stdio.h>
#define _dout(msg) { cout << msg; }
#define _dprintf  printf
#else
#define _dout(msg) {;}
#define _dprintf  //
#endif

/*****************************************************************************************/
/*  Some standard error types following:                                                 */

#define OUT_OF_MEMORY 103


/******************************************************************************
      » APPObject class «

   This is a virtual base class for all APlusPlus classes. It is used to 
   detect constructor failures within the inheritance path of an object. 
   Therefore each constructor of a derived class should check for the proper 
   initialisation of its super classes and in case of failure should not 
   allocate any resources but let the user see the occured error. 
   The class user who creates an object should test it for valid with obj->Ok().

   myProcedure( )
   {
      DerivedObject *obj = new DerivedObject( );

      if (obj)          // check for memory allocation failure
      {
         if (obj->Ok())    // check validity of the created object
         {
            ....  // work on the object
         }
         else
         {
            _dout(cerr << "Initialisation error occured: " << obj->IError() << endl;)
            delete obj;    // free the memory allocated for the object data
         }
      }
   }

   Class implementors ought to check the base class validity within their constructor:

   class MyClass : private InheritedClass, virtual public APPObject
   {
      public:
         MyClass( )
         {
            if (Ok())   // has an error already occured ?
            {
               // at this point the object has the class ID of the last class in the
               // inheritance list.
               if (initialise( )==FALSE)    // class initialisation
               {
                  #define MYCLASS_SOMETHING_FAILED (MY_CLASS+1)
                  _ierror(MYCLASS_SOMETHING_FAILED);
                  // set the error variable to a value and
                  // print the error string "MYCLASS_SOMETHING_FAILED" to stderr
               }
               else setID(MY_CLASS);
            }
            else  // initialise only for SAFE destruction, no resource allocation
            {
            }
         }
   }

 *****************************************************************************************/
#endif

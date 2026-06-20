#ifndef APP_TypeInfo_H
#define APP_TypeInfo_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/environment/TypeInfo.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

#if defined(_AMIGA) || defined(AMIGA)
#include <APlusPlus/exec/List.h>
#endif


/******************************************************************************
 *
 * This file contains a runtime type-inquiry mechanism according to the
 * ideas of Bjarne Stroutrup as described in his book
 *    "The C++ Programming Language".
 *
 * The purposes of the runtime type-inquiry mechanim are:
 * 1. dynamic casting, ie the ability to cast an object into another class with
 *    verifying IF that object has that class as base class or is that very class.
 * 2. persistent class identifiers that allow to store an object to disk
 *    and reconstruct it from disk.
 * 3. a class may add some specific class information to its Type_info structure.
 *
 * For the very details refer to Stroustrup's book which is generally recommended!
 ******************************************************************************/


#if defined(_AMIGA) || defined(AMIGA)
class Ti_list;
class LoL_iterator;

class Ti_listnode : private NodeC
{
   friend class Ti_list;   // Ti_list needs to know that NodeC is a base class of Ti_listnode
   friend class LoL_iterator;
   public:
      Ti_listnode(const char* name) : NodeC((const UBYTE*)name) {}
      virtual ~Ti_listnode() {}
      Ti_listnode* succ() const { return (Ti_listnode*)NodeC::succ(); }
};

#if !defined(__SASC) && !defined(__GNUG__)
class Ti_list : private ListC
{
   public:
      Ti_list() : ListC() {}
      virtual ~Ti_list() {}

      Ti_listnode* head()
         { return (Ti_listnode*)ListC::head(); }
      Ti_list& enqueue(Ti_listnode* node,const char* name)
         { //cout << "Ti_list::enqueue start(node="<<(APTR)node<<")\n";
           ListC::enqueue((NodeC*)node); //cout << "Ti_list::enqueue done.\n";
           return *this; }
      Ti_listnode* findName(const char* name)
         { return (Ti_listnode*)ListC::findName((const UBYTE*)name); }
};
#else
class Ti_list : private List
{
   public:
      Ti_list();
      virtual ~Ti_list() { }

      Ti_listnode* head()
         { return (Ti_listnode*) ((ListC*)this)->ListC::head(); }
      Ti_list& enqueue(Ti_listnode* node,const char* name);
      Ti_listnode* findName(const char* name)
         { return (Ti_listnode*)((ListC*)this)->ListC::findName((const UBYTE*)name); }
};
#endif

#endif

/******************************************************************************
 *
 *    class 'LoL_iterator'
 *
 ******************************************************************************/
class Type_info;

class LoL_iterator
{
   private:
      const Type_info* current;
   public:
      LoL_iterator();
      const Type_info* operator () ();    // iterate through the list
      const Type_info* find_info(const char* name);  // find the named class
};

/******************************************************************************

      class 'Type_info'

   Each class has to declare a static member of type 'Type_Info' and initialise
   it with, at least, its class name.
   Additional information that is stored in Type_Info can differ from class to
   class, derived 'Type_info' classes can be distinguished again by means of the
   runtime type-inquiry mechanism.

 ******************************************************************************/

class Type_info : private Ti_listnode
{
   friend class LoL_iterator;
   public:
      Type_info(const char *name, const Type_info* bases[],const char* id = NULL);
      virtual ~Type_info();

      int operator==(const Type_info& t) const 
         { return ((long)this==(long)&t); }
      int operator!=(const Type_info& t) const 
         { return ((long)this!=(long)&t); }
      
      const char* name() const 
         { return n; }
      const char* id() const 
         { return s; }

      int same(const Type_info& p) const;
      int has_base(const Type_info& base_ti, int direct=0) const;
      // returns TRUE if the 'base_ti' 'Type_info' object belongs to a class
      // that is base class to 'this' 'Type_info', either direct (=TRUE) or
      // at least indirect ('direct'=FALSE) base class.

      int can_cast(const Type_info& p) const;

      static const Type_info* find_class(const char* name);
      
      // each class within the 'Type_info' system needs to declare the following:
      static const Type_info info_obj;     // the class' 'Type_info' object
      virtual const Type_info& get_info() const     // get info to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the info of a specific class
         { return info_obj; }

   private:
      Type_info(const Type_info&);           // render copy constructor..
      Type_info& operator=(const Type_info&);// and assignment operator inoperable
      
      static Ti_list listOfLists;   // all 'Type_info' objects are linked in that list
      
      const char* n; // pointer to a string that holds a very unique class name
      const Type_info** b;    // list of base classes
      const char* s; // this string slot may be used for a version string etc.
};

// obtain a reference to the Type_info object from a pointer or reference 
// to an object of a class that supports the Type_info class.
#define type_id(tc) ((tc)->get_info())
#define ptr_type_id(tc) type_id(tc)
#define ref_type_id(tc) ((tc).get_info())

// When seeking out information about a class name the NULL return indicates
// that the wanted class could not be found.
#define name_type_id(name) (Type_info::find_class(name))

// get a reference to the Type_info object of class 'T'.
#define class_type_id(T) (T::info())


#define ptr_cast(T,p) (T::info().can_cast(type_id(p))?(T*)(p):0)
// T is the name of a known 'Typed_class'-derived class.
// p is a pointer of a 'Typed_class'-derived class.

// Note: a 'ref_cast' is not available because exceptions are not available 
// to 'throw' a BAD_CAST.


#define from(T) &T::info_obj,
#define derived(bb) bb 0
#define no_bases 0
#define typeinfo(T,bases,id) \
   static const Type_info* T ## _b[] = { bases }; \
   const Type_info T::info_obj(#T,T ## _b,id);


/*
   construct a Type_info definition to a class like this:

   class Fred : public Barny, private Wilma
   { .. };
   typeinfo(Fred, derived(from(Barny) from(Wilma)) ,"$VER: Version 68.23 (23.02.94)$")

*/

#endif

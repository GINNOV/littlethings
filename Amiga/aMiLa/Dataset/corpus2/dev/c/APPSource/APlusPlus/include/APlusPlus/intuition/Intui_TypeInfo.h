#ifndef APP_Intui_Type_info_H
#define APP_Intui_Type_info_H
/******************************************************************************
 **
 **	C++ Class Library for the Amiga© system software.
 **
 **	Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **	All Rights Reserved.
 **
 **	$VER: apphome:APlusPlus/intuition/Intui_TypeInfo.h 1.10 (27.07.94) $
 **	
 ******************************************************************************/


#include <APlusPlus/environment/TypeInfo.h>

class Intui_Type_info : public Type_info
{
	public:
		Intui_Type_info(const char *name, const Type_info* bases[],const char* id);
		~Intui_Type_info();
      
      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }


};


#define intui_typeinfo(T,bases,id) \
   static const Type_info* T ## _b[] = { bases }; \
   const Intui_Type_info T::info_obj(#T,T ## _b,id);

/*
   construct a Type_info definition to a class like this:

   class Fred : public Barny, private Wilma
   { .. };
   typeinfo(Fred, derived(from(Barny) from(Wilma)) ,"$VER: Version 68.23 (23.02.94)$")

   Add the following to each .cxx file (example):

// runtime type inquiry support
intui_typeinfo(IntuiObject, no_bases, rcs_id)

*/

#endif

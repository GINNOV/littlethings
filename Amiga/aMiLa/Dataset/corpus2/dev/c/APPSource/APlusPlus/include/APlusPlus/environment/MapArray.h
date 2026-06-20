#ifndef APP_MapArray_H
#define APP_MapArray_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/environment/MapArray.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <exec/types.h>
}
#include <APlusPlus/environment/APPObject.h>


/******************************************************************************************

      » MapArray class «

 ******************************************************************************************/
typedef void* MA_T;
typedef ULONG MapKey;
typedef int (*MapArray_comp)(MapKey, MapKey);

class MapArrayIterator;
class MapArray
{
   friend class MapArrayIterator;
   public:
      MapArray();
      ~MapArray();

      MA_T& operator [] (MapKey tag);
      // returns reference to the MA_T object associated with 'tag'
      // or, if 'tag' was not found, new MA_T object
      
      MA_T find(MapKey tag,MapArray_comp compareFunction=NULL);  
      // returns pointer to associated MA_T object or NULL if not found

   private:
      struct Pair
      {
         MapKey key;
         MA_T entry;
      }* pairs;

      int arraySize;
      static Pair empty;
};

class MapArrayIterator
{
   private:
      MapArray* mapArray;
      int cIndex;

   public:
      MapArrayIterator(MapArray& ma) { cIndex = -1; mapArray = &ma; }

      void reset()
         { cIndex = -1; }
      MA_T operator ()();
      MA_T& operator [](int dummy)
         { return mapArray->pairs[cIndex].entry; }

      MapKey key()
         { return mapArray->pairs[cIndex].key; }
};

inline MA_T MapArrayIterator::operator ()()
{
   MapArray::Pair* p = &mapArray->pairs[++cIndex];
   if (p->key) return p->entry; else return(MA_T)NULL;
}


#undef MA_T
#endif

#ifndef APP_AttrList_H
#define APP_AttrList_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/AttrList.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <utility/tagitem.h>
#ifdef __GNUG__
#include <inline/utility.h>
#endif
#ifdef __SASC
#include <proto/utility.h>
#endif
}
#include <APlusPlus/environment/APPObject.h>


/******************************************************************************

      AttrList class

   This class handles Amiga® TagItem lists (arrays) for the uniform usage
   throughout the A++ Library.

   Common terms for understanding TagItem lists:
   A 'tag list' is an array of 'tag items' each consisting of a 'tag value' 
   indicating the 'type' of the tag (therefore called 'TagValue' or 'TagType', 
   sometimes 'Tag') and a 'tag data' describing the 'data value' of the tag 
   (refered to as 'DataValue' or 'TagData').

 ******************************************************************************/

typedef struct TagItem* TagList;
// pointer to the first TagItem element of a TagItem array terminated with {TAG_END,0}
// divided into several array chunks that are linked with {TAG_MORE,<TagList>}.

class AttrIterator;
class AttrList
{
   friend class AttrIterator;
   public:
      AttrList(TagList tl=NULL);
      AttrList(LONG tag1Type,...);
      AttrList(const AttrList& from);
      ~AttrList();

      AttrList& operator=(const AttrList& from);   // assignment is copying

      operator struct TagItem*() const { return taglist; }

      BOOL addAttrs(AttrList& attrlist);
      // Those tags in 'attrlist' that are NOT already  present in 'this'
      // are added to 'this' WITH the attribute values specified in 'attrlist'.
      // For those tags which are already present the attribute value in
      // 'attrlist' is NOT considered. Already present tags are deleted from
      // 'attrlist' (set to TAG_IGNORE).
      // For overwriting these values use 'updateAttrs()'.
      // Returns TRUE if any tags have been added - hence returns FALSE if
      // ALL tags in 'attrlist' were already present in 'this'.

      BOOL updateAttrs(const AttrList& attrlist);
      // tags in 'this' that are present in both 'this' and 'attrlist'
      // are updated to the tag data value found in 'attrlist'.
      // Returns TRUE if any tags adopted new values.

      LONG getTagData(Tag tag,LONG defaultValue=0) const {
         return (LONG)GetTagData(tag,defaultValue,taglist); }

      ULONG mapAttrs(const AttrList& mapAt);
      ULONG filterAttrs(const AttrList& filterAt, int filter = TAGFILTER_AND);
      // removed those tags from 'this' list that are 

      ULONG mapAttrs(TagList mapList);
      ULONG filterAttrs(TagList filterList);

      ULONG mapAttrs(Tag tag1Type,...)
         { return mapAttrs((struct TagItem*)&tag1Type); }
      ULONG filterAttrs(Tag tag1Type,...)
         { return filterAttrs((struct TagItem*)&tag1Type); }

      void print();  // print the contents of this taglist to stdout
      // tag names must have been defined in taglist.cxx to be printed.

   protected:
      TagList taglist;

   private:
      TagList cloneTagItems(TagList);
      void freeTagItems(TagList tlist);
};

class AttrIterator
{
   public:
      AttrIterator(const AttrList& alist);

      BOOL operator () ()
         { return ((atTag = NextTagItem(&tstate))!=NULL); }
      void reset()
         { atTag = tstate = al->taglist; }

      BOOL findTagItem(Tag tagVal);
      // Find next occurancy of 'tagVal' tag item and set iterator to its position
      // If 'tagVal' could not be found the iterator remains at its position
      // and the method returns FALSE.

      Tag tag()
         { return atTag->ti_Tag; }
      LONG data()
         { return atTag->ti_Data; }

   protected:
      const AttrList* al;
      TagList tstate,atTag;


};

class AttrManipulator : public AttrIterator
{
   public:
      AttrManipulator(AttrList& calist);

      void writeTag(Tag tagValue)
         { atTag->ti_Tag = tagValue; }
      void writeData(LONG tagData)
         { atTag->ti_Data = tagData; }
};

#endif

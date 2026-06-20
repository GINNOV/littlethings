/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACatalog wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Catalog_H
#define ASAP_Catalog_H

#include <New.h>

extern "C"
{
 #include <Proto/Locale.h>
}

class ACatalog : public Catalog
{
 inline void CloseCatalog();
 inline void operator delete (void *catalog);
 inline STRPTR GetCatalogStr(long stringNum, STRPTR defaultString );
 inline static ACatalog * OpenCatalogA(Locale *locale, STRPTR name, TagItem *tags );
 inline void * operator new (size_t, Locale *locale, STRPTR name, TagItem *tags);
 inline static ACatalog * OpenCatalog( Locale *locale, STRPTR name, Tag tag1, ... );
 inline void * operator new (size_t, Locale *locale, STRPTR name, Tag tag1, ...);
};
//-----------------------------------------------------------------------------
void ACatalog::CloseCatalog ()
{
 ::CloseCatalog(this);
}
//-----------------------------------------------------------------------------
void ACatalog::operator delete (void *catalog)
{
 ((ACatalog *) catalog)->CloseCatalog();
}
//-----------------------------------------------------------------------------
STRPTR ACatalog::GetCatalogStr (long stringNum, STRPTR defaultString )
{
 return ::GetCatalogStr(this, stringNum, defaultString);
}
//-----------------------------------------------------------------------------
ACatalog * ACatalog::OpenCatalogA (Locale *locale, STRPTR name, TagItem *tags )
{
 return (ACatalog *) ::OpenCatalogA(locale, name, tags);
}
//-----------------------------------------------------------------------------
void * ACatalog::operator new (size_t, Locale *locale, STRPTR name, TagItem *tags)
{
 return ACatalog::OpenCatalogA(locale, name, tags);
}
//-----------------------------------------------------------------------------
ACatalog * ACatalog::OpenCatalog (Locale *locale, STRPTR name, Tag tag1, ... )
{
 return ACatalog::OpenCatalogA(locale, name, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
void * ACatalog::operator new (size_t, Locale *locale, STRPTR name, Tag tag1, ...)
{
 return ACatalog::OpenCatalogA(locale, name, (TagItem *) &tag1);
}

#endif

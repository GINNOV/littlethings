/*
 * localize.c
 * ==========
 * Utility functions for localization.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <proto/exec.h>
#include <proto/locale.h>

#include "apputil.h"


struct LocaleInfo {
  APTR li_LocaleBase;
  APTR li_Catalog;
};


extern STRPTR __asm GetString(register __a0 struct LocaleInfo *li,
			      register __d0 ULONG id);


static struct LocaleInfo li;

#define LocaleBase li.li_LocaleBase


VOID InitLocaleInfo(STRPTR catalog, STRPTR language, UWORD version) {
  li.li_LocaleBase = OpenLibrary("locale.library", 38L);
  if (li.li_LocaleBase != NULL) {
    li.li_Catalog = OpenCatalog(NULL, catalog,
				OC_Language, language,
				OC_Version, version,
				TAG_DONE);
  }
}


VOID DisposeLocaleInfo(VOID) {
  if (li.li_LocaleBase != NULL) {
    CloseCatalog(li.li_Catalog);
    CloseLibrary(li.li_LocaleBase);
  }
}


STRPTR GetLocString(ULONG strId) {
  return GetString(&li, strId);
}

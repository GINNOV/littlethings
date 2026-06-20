#define DEF_LOCALESUPPORT_C

#if defined AMIGA                                              /* if we are being compiled for AmigaOS */
   #include <clib/exec_protos.h>
   #include <clib/locale_protos.h>
#endif

#include <stdio.h>
#include <stdlib.h>

#include "LocaleSupport.h"

struct LocaleBase *LocaleBase = NULL;                          /* connected to the locale.library */

/*
   struct LOCALE_SUPPORT_CATALOG *locale_support_open(
      char *catalog_name,                                      the name of the catalog to be used - if available
      char *default_text[])                                    if no catalog, use this array of strings

   * Description
      This function must be called before any of the other locale_support class of functions is called. It registers the program's catalog and built-in strings. If the program is running on a system
      which pre-dates the use of catalog files, the built in strings will be used.

   * Return Value
       NULL = error, out of memory
      other = tThe Catalog that was opened - to be passed to other locale_support functions
*/
struct LOCALE_SUPPORT_CATALOG *locale_support_open(
   char *catalog_name,                                         /* the name of the catalog to be used - if available */
   char *default_text[])                                       /* if no catalog, use this array of strings */
{
   struct LOCALE_SUPPORT_CATALOG *retval;                      /* value that is returned, assume that we have to use the built in strings */

   if ((retval = calloc(1, sizeof(*retval))) == NULL)          /* if we cannot get some memory for another instance of this structure */
      goto _ABORT;                                             /* we are outta here */

   retval->lsc_default_text = default_text;                    /* remember where the built-in strings are */

#if defined AMIGA                                              /* if we are being compiled on AmigaOS */
   if (catalog_name)                                           /* if we should attempt to open a multi-language catalog file */
   {
      LocaleBase = (struct LocaleBase *)OpenLibrary("locale.library",0);                        /* attempt to open the locale library */

      if (LocaleBase)                                          /* if have the local.library open */
      {
/* attempt to open the specified catalog file */
         retval->lsc_catalog = OpenCatalog(NULL, catalog_name, OC_BuiltInLanguage, "english", TAG_DONE);
      }
   }
#endif

_ABORT:
   return (retval);                                            /* here you go! */
}

/*
   char *locale_support_string(
      struct LOCALE_SUPPORT_CATALOG *catalog,                  previous return value from locale_support_open()
      int message_index)                                       the index of the message to be fetched

   * Description
      This routine fetches the specified string from either the currently active catalog file or from the built in strings.

   * Return Value
      the specified string
*/
char *locale_support_string(
   struct LOCALE_SUPPORT_CATALOG *catalog,                     /* previous return value from locale_support_open() */
   int message_index)                                          /* the index of the message to be fetched */
{
   char *retval;                                               /* value that is returned */

   if (catalog)                                                /* if a valid catalog was passed to us */
   {
#if defined AMIGA                                              /* if we are being compiled on AmigaOS */
      if (LocaleBase)                                          /* if we have the locale.library open */
      {
/* use the locale.library to attempt to fetch the specified string */
         retval = GetCatalogStr(catalog->lsc_catalog, message_index, catalog->lsc_default_text[message_index]);
      }
      else                                                     /* we couldn't open the locale.library */
#endif
      {
         retval = catalog->lsc_default_text[message_index];    /* use the built-in string */
      }
   }
   else                                                        /* an invalid pointer was passed */
   {
      retval = "";                                             /* you really shouldn't call this with a NULL catalog pointer */
   }

   return (retval);
}

/*
   struct LOCALE_SUPPORT_CATALOG *locale_support_close(
      struct LOCALE_SUPPORT_CATALOG *catalog)                  previous return value from locale_support_open()

   * Description
      This routine frees the resources previously allocated by the locale_support_open() function.
      It should be called before the program exits.

   * Return Value
      NULL (set your LOCALE_SUPPORT_CATALOG pointer to this value)
*/
struct LOCALE_SUPPORT_CATALOG *locale_support_close(
   struct LOCALE_SUPPORT_CATALOG *catalog)                     /* previous return value from locale_support_open() */
{
   if (catalog)                                                /* if a valid pointer was passed to us */
   {
#if defined AMIGA                                              /* if we are being compiled for AmigaOS */
      if (LocaleBase)                                          /* if we have the locale.library open */
      {
         CloseCatalog(catalog->lsc_catalog);                   /* close the catalog */
         CloseLibrary((struct Library *)LocaleBase);           /* close the library */
      }
#endif

      free(catalog);                                           /* free the structure itself */
   }

   return (NULL);                                              /* your catalog file is no longer in effect */
}

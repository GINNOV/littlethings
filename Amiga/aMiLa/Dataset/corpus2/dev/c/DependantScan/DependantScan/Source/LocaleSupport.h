#define DEF_LOCALESUPPORT_H

struct LOCALE_SUPPORT_CATALOG
{
#if defined AMIGA                                              /* if this is being compiled for AmigaOS */
   struct Catalog *lsc_catalog;                                /* the multi-language catalog for this process */
#endif

   char **lsc_default_text;                                    /* the built-in strings of the process */
};

/* LocaleSupport.c */
extern struct LOCALE_SUPPORT_CATALOG *locale_support_open( char *catalog_name, char *default_text[]);
extern char *locale_support_string( struct LOCALE_SUPPORT_CATALOG *catalog, int message_index);
extern struct LOCALE_SUPPORT_CATALOG *locale_support_close( struct LOCALE_SUPPORT_CATALOG *catalog);

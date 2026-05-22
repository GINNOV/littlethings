#if 0
char *libintl_gettext(const char *__msgid);
char *libintl_dgettext(const char *__domainname, const char *__msgid);
char *libintl_dcgettext(const char *__domainname, const char *__msgid, int __category);
char *libintl_ngettext(const char *__msgid1, const char *__msgid2, unsigned long int __n);
char *libintl_dngettext(const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n);
char *libintl_dcngettext(const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n, int __category);
char *libintl_textdomain(const char *__domainname);
char *libintl_bindtextdomain (const char *__domainname, const char *__dirname);
char *libintl_bind_textdomain_codeset (const char *__domainname, const char *__codeset);
char *gettext(const char *__msgid);
char *dgettext(const char *__domainname, const char *__msgid);
char *dcgettext(const char *__domainname, const char *__msgid, int __category);
char *ngettext(const char *__msgid1, const char *__msgid2, unsigned long int __n);
char *dngettext(const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n);
char *dcngettext(const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n, int __category);
char *textdomain(const char *__domainname);
char *bindtextdomain (const char *__domainname, const char *__dirname);
char *bind_textdomain_codeset (const char *__domainname, const char *__codeset);
#endif
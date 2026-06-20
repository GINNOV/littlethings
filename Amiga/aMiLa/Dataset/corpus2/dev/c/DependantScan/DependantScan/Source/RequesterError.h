#define DEF_REQUESTERERROR_H

#if defined AMIGA                                              /* if this is being compiled on an Amiga */

/* RequesterError.c */
extern void requester_error_set_defaults( struct Window *window, struct LOCALE_SUPPORT_CATALOG *catalog, int title, int gadget_text);
#if defined _STDARG_H
   extern int vrequester_error(struct Window *window, int title, int error_text, int gadget_text, va_list arg_ptr);
#endif
extern int requester_error(struct Window *window, int title, int error_text, int gadget_text, ...);
extern int quick_requester_error(int error_text, ...);

#else                                                          /* not being compiled for AmigaOS */
#define requester_error_set_defaults(a, b, c, d)
#endif

#include <sys/cdefs.h>

#include <stdlib.h>

__BEGIN_DECLS
extern size_t wcslen(const wchar_t *);
extern wchar_t *wcscpy(wchar_t *, const wchar_t *);
extern wchar_t *wcsncpy(wchar_t *, const wchar_t *, int);
extern wchar_t *wcscat(wchar_t *, const wchar_t *);
extern int wcscmp(const wchar_t *, const wchar_t *);
extern int wcsncmp(const wchar_t *, const wchar_t *, int);
__END_DECLS

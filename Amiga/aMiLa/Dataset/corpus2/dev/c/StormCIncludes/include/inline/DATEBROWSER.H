#ifndef _INLINE_DATEBROWSER_H
#define _INLINE_DATEBROWSER_H

#ifndef DATEBROWSER_BASE_NAME
#define DATEBROWSER_BASE_NAME DateBrowserBase
#endif

#define DATEBROWSER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) DATEBROWSER_BASE_NAME) - 30))((struct Library *) DATEBROWSER_BASE_NAME)

#define JulianWeekDay(day, month, year) \
	((UWORD (*)(UWORD __asm("d0"), UWORD __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) DATEBROWSER_BASE_NAME) - 36))(day, month, year, (struct Library *) DATEBROWSER_BASE_NAME)

#define JulianMonthDays(month, year) \
	((UWORD (*)(UWORD __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DATEBROWSER_BASE_NAME) - 42))(month, year, (struct Library *) DATEBROWSER_BASE_NAME)

#define JulianLeapYear(year) \
	((BOOL (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DATEBROWSER_BASE_NAME) - 48))(year, (struct Library *) DATEBROWSER_BASE_NAME)

#endif /*  _INLINE_DATEBROWSER_H  */

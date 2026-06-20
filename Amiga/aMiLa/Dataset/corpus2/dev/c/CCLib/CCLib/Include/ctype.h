#ifndef CTYPE_H
#define CTYPE_H 1

/* this baby lives in CClib.library so don't mess with it */
extern char *type;

/* C type macros a-la K&R (For the ASCII character set) */
#define isalpha(X)  (type[(X)+1] & 0x03)
#define isupper(X)  (type[(X)+1] & 0x01)
#define islower(X)  (type[(X)+1] & 0x02)
#define isdigit(X)  (type[(X)+1] & 0x04)
#define isxdigit(X) (type[(X)+1] & 0x08)
#define isalnum(X)  (type[(X)+1] & 0x07)
#define isspace(X)  (type[(X)+1] & 0x10)
#define ispunct(X)  (type[(X)+1] & 0x40)
#define iscntrl(X)  (type[(X)+1] & 0x20)
#define isprint(X)  (type[(X)+1] & 0xc7)
#define isgraph(X)  (type[(X)+1] & 0x47)
#define isascii(X)  (!((X) & 0x80))

#define toascii(X)  ((X) & 127)
#define _tolower(X) ((X) | 0x20)
#define _toupper(X) ((X) & 0x5f)

long toupper(long c);
long tolower(long c);


#endif


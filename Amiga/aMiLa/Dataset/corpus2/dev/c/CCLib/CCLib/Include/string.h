#ifndef STRING_H
#define STRING_H 1

#ifdef ANSIC

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

long bcmp(void *, void *, long);
void bcopy(void *, void *, long);
void bzero(void *, long);
void *memccpy(void *, void *, unsigned long, long);
void *memchr(void *, unsigned long, long);
long memcmp(void *, void *, long);
void *memcpy(void *, void *, long);
void *memset(void *, unsigned long, long);
void memswap(void *, void *, long);

char *index(char *, long);
char *rindex(char *,long);
char *strupr(char *);
char *stpcrlf(char *);
char *strcat(char *, char *);
char *strchr(char *, long);
long strcmp(char *, char *);
char *strcpy(char *, char *);
long strcspn(char *, char *);
long strlen(char *);
char *strncat(char *, char *, long);
long strcmpa(char *, char *);
long strncmp(char *, char *, long);
char *strncpy(char *, char *, long);
char *strpbrk(char *, char *);
char *strrchr(char *, long);
long strspn(char *, char *);
char *strstr(char *, char *);
char *strtok(char *, char *);
char *strrv(char *);
char *strnrv(char *, long);
char *bcpl_strcpy(char *, BSTR);
char *strerror(long);

#else

long bcmp();
void bcopy();
void bzero();
void *memccpy();
void *memchr();
long memcmp();
void *memcpy();
void *memset();
void memswap();
char *index();
char *rindex();
char *strupr();
char *stpcrlf();
char *strcat();
char *strchr();
long strcmp();
char *strcpy();
long strcspn();
long strlen();
char *strncat();
long strcmpa();
long strncmp();
char *strncpy();
char *strpbrk();
char *strrchr();
long strspn();
char *strstr();
char *strtok();
char *strrv();
char *strnrv();
char *bcpl_strcpy();
char *strerror();

#endif

#endif


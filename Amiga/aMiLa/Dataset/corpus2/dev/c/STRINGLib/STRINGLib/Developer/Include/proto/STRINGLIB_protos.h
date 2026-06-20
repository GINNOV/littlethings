char	Tolower (char c);		/* Tolower.c	*/
char	Toupper (char c);		/* Toupper.c	*/
char *	Index (char *s, char charwanted);		/* Index.c	*/
char *	Lmemmove (register char *dest, register char *source, register long len);		/* Lmemmove.c	*/
char *	Memccpy (char *dst, const char *src, char ucharstop, int size);		/* Memccpy.c	*/
char *	Memchr (char *s, register char uc, int size);		/* Memchr.c	*/
char *	Memcpy (char *dst, const char * src, int size);		/* Memcpy.c	*/
char *	Memset (char *s, register char ucharfill, int size);		/* Memset.c	*/
char *	Rindex (char *s, char charwanted);		/* Rindex.c	*/
char *	Stpcpy (char *d, const char *s);		/* Stpcpy.c	*/
char *	Stradj (register char *string, register int dir);		/* Stradj.c	*/
char *	Strcat (char *dst, const char *src);		/* Strcat.c	*/
char *	Strchr (char *s, register char charwanted);		/* Strchr.c	*/
char *	Strcpy (char *dst, const char *src);		/* Strcpy.c	*/
char *	Strdcat (char *s1, char *s2);		/* Strdcat.c	*/
char *	Strdup (char *string);		/* Strdup.c	*/
char *	Stristr (register char *string, register char *pattern);		/* Stristr.c	*/
char *	Strlower (char *s);		/* Strlower.c	*/
char *	Strlwr (register char *string);		/* Strlwr.c	*/
char *	Strncat (char *dst, const char *src, int n);		/* Strncat.c	*/
char *	Strncpy (char *dst, const char *src, int n);		/* Strncpy.c	*/
char *	Strndup (char *string, int n);		/* Strndup.c	*/
char *	Strnset (char *string, register char c, register int n);		/* Strnset.c	*/
char *	Strpbrk (char *s, char *breakat);		/* Strpbrk.c	*/
char *	Strpcpy (register char *dest, register char *start, register char *end);		/* Strpcpy.c	*/
char *	Strrchr (char *s, register char charwanted);		/* Strrchr.c	*/
char *	Strrev (char *string);		/* Strrev.c	*/
char *	Strrpbrk (register char *string, register char *set);		/* Strrpbrk.c	*/
char *	Strset (char *string, register char c);		/* Strset.c	*/
char *	Strstr (char *s, char *wanted);		/* Strstr.c	*/
char *	Strtok (char *s, register const char *delim);		/* Strtok.c	*/
char *	Strtrim (register char *string, register char *junk);		/* Strtrim.c	*/
char *	Strupper (char *s);		/* Strupper.c	*/
char *	Strupr (register char *string);		/* Strupr.c	*/
char *	Subnstr (register char *dest, register char *source, register int start, register int end,register int length);		/* Subnstr.c	*/
char *	Substr (register char *dest, register char *source, register int start, register int end);		/* Substr.c	*/
const char *	Stpchr (const char *str, char c);		/* Stpchr.c	*/
double	Strtod (char *string, char **ptr);		/* Strtod.c	*/
double	Strtosd (char *string, char **ptr, double base);		/* Strtosd.c	*/
double	Strtosud (char *string, char **ptr, double base);		/* Strtosud.c	*/
int	Bcmp (const char *s1, const char *s2, int length);		/* Bcmp.c	*/
int	Memcmp (const char *s1, const char * s2, int size);		/* Memcmp.c	*/
int	Memicmp (register char *mem1, register char *mem2, register int len);		/* Memicmp.c	*/
int	Memncmp (char *a, char *b, int length);		/* Memncmp.c	*/
int	Strbpl (char **av, int max, char *sary);		/* Strbpl.c	*/
int	Strcasecmp (const char *s, const char *d);		/* Strcasecmp.c	*/
int	Strcmp (const char *s1, const char *s2);		/* Strcmp.c	*/
int	Strcspn (const char *s, const char *reject);		/* Strcspn.c	*/
int	Stricmp (const char *str1, const char *str2);		/* Stricmp.c	*/
int	Strinstr (char *s, int c);		/* Strinstr.c	*/
int	Strirpl (char *string, char *ptrn, register char *rpl, register int n);		/* Strirpl.c	*/
int	Strlen (const char *s);		/* Strlen.c	*/
int	Strlencmp (char *s, char *t, int n);		/* Strlencmp.c	*/
int	Strncasecmp (const char *s, const char *d, int n);		/* Strncasecmp.c	*/
int	Strncmp (const char *s1, const char *s2, int n);		/* Strncmp.c	*/
int	Strnicmp (const char *str1, const char *str2, int n);		/* Strnicmp.c	*/
int	Strpos (register char *string, register char symbol);		/* Strpos.c	*/
int	Strrpl (char *string, char *ptrn, register char *rpl, register int n);		/* Strrpl.c	*/
int	Strrpos (register char *string, register char symbol);		/* Strrpos.c	*/
int	Strspn (const char *s, const char *accept);		/* Strspn.c	*/
long	Strtol (char *ptr, char **tail, int base);		/* Strtol.c	*/
long	Strtolong (char *string, long *value);		/* Strtolong.c	*/
unsigned long	Strtoul (char *ptr,char **tail, int base);		/* Strtoul.c	*/
void	Bcopy (const char *src, char *dst, int length);		/* Bcopy.c	*/
void	Bzero (char *dst, int length);		/* Bzero.c	*/
void	Strins (char *d, const char *s);		/* Strins.c	*/
void	Strupp (char *pc);		/* Strupp.c	*/
void	Swap (register char *s1, register char *s2, register int n);		/* Swap.c	*/
void *	Memmove (void *s1, const void *s2, int n);		/* Memmove.c	*/

/* edlib  version 1.0 of 04/08/88 */
#define STRING_END	'\0'
#ifndef NULL
#define NULL	0L
#endif

char *strtok(buf, separators)
char *buf, *separators;
{
	register char *token, *end;	/* Start and end of token. */
	extern char *strpbrk();
	static char *fromLastTime;

	if (token = buf ? buf : fromLastTime) {
		token += strspn(token, separators);	/* Find token! */
		if (*token == STRING_END)
			return(NULL);
		fromLastTime = ((end = strpbrk(token,separators))
				? &end[1]
				: NULL);
		*end = STRING_END;			/* Cut it short! */
	}
	return(token);
}

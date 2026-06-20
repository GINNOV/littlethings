/* ctype.h - character classification functions */

/* character is alphanumeric
 * returns 0 if the character doesn't fit the
 * classification; non-zero (but not necessarily 1)
 * if it does.
 */
inline int isalnum(int c	/* the character to classify */);

/* character is a letter */
inline int isalpha(int c);

/* character is a control character */
inline int iscntrl(int c);

/* character is a digit */
inline int isdigit(int c);

/* character is a graphic */
inline int isgraph(int c);

/* character is a lower case letter */
inline int islower(int c);

/* character is printable */
inline int isprint(int c);

/* character is punctuation */
inline int ispunct(int c);

/* character is a a form of whitespace */
inline int isspace(int c);

/* character is an upper case letter */
inline int isupper(int c);

/* character is a hexadecimal digit */
inline int isxdigit(int c);

/*** excluded for vbcc, see below
*MP* _cli_parse(){return;}
*MP* _wb_parse(){return;}
***/

/*
 * Test program for string(3) routines.
 * 
 * Note that at least one Bell Labs implementation of the string
 * routines flunks a couple of these tests -- the ones which test
 * behavior on "negative" characters.
 */

/* 10.12.1998 Michaela Prüß, patches vor actual stringlib and vbcc
 *
 * see patches direct in source. documented in comments after *MP*
 * most incomplete declarations (must corrected for useing prototypes
 *
 */

#define VBCC		/*MP* lock in stringlib.h for more detail */

#include <stdio.h>
#include "stringlib.h"

#define	STREQ(a, b)	(Strcmp((a), (b)) == 0)

char *it = "<UNSET>";		/* Routine name for message routines. */
int waserror = 0;		/* For exit status. */

char uctest[] = "\004\203";	/* For testing signedness of chars. */
int charsigned;			/* Result. */

/*
 - check - complain if condition is not true
 -
*MP* no return also uses void, not int
*MP* int number must printed with %d, not %ld
 -
 */

void check(int thing, int number)			/* Test number for error message. */
{
	if (!thing) {
		printf("%s flunked test %d\n", it, number);
		waserror = 1;
	}
}

/*
 - equal - complain if first two args don't Strcmp as equal
 -
*MP* no return also uses void, not int
 -
 */

void equal(char *a, char *b, int number)			/* Test number for error message. */
{
	check(a != NULL && b != NULL && STREQ(a, b), number);
}

char one[50];
char two[50];

#ifdef UNIXERR
#define ERR 1
#endif
#ifdef BERKERR
#define ERR 1
#endif
#ifdef ERR
int f;
#ifdef unix
extern char *sys_errlist[];
extern int sys_nerr;
#else
char *sys_errlist[1] = {"dummy entry to keep compilers happy"};
int sys_nerr = 1;
#endif
extern int errno;
#endif

/* ARGSUSED
 -
*MP* prototyp without any returntype, added int
 -
 */

int main(int argc, char *argv[])
{
	/*
	 * First, establish whether chars are signed.
	 */
	if (uctest[0] < uctest[1])
		charsigned = 0;
	else
		charsigned = 1;

	/*
	 * Then, do the rest of the work.  Split into two functions because
	 * some compilers get unhappy about a single immense function.
	 */
	first();
	second();

	exit((waserror) ? 1 : 0);
}

/*MP* added void */

void first()
{
	/*
	 * Test Strcmp first because we use it to test other things.
	 */
	it = "Strcmp";
	check(Strcmp("", "") == 0, 1);		/* Trivial case. */
	check(Strcmp("a", "a") == 0, 2);	/* Identity. */
	check(Strcmp("abc", "abc") == 0, 3);	/* Multicharacter. */
	check(Strcmp("abc", "abcd") < 0, 4);	/* Length mismatches. */
	check(Strcmp("abcd", "abc") > 0, 5);
	check(Strcmp("abcd", "abce") < 0, 6);	/* Honest miscompares. */
	check(Strcmp("abce", "abcd") > 0, 7);
	check(Strcmp("a\203", "a") > 0, 8);	/* Tricky if char signed. */
	if (charsigned)				/* Sign-bit comparison. */
		check(Strcmp("a\203", "a\003") < 0, 9);
	else
		check(Strcmp("a\203", "a\003") > 0, 9);

	/*
	 * Test Strcpy next because we need it to set up other tests.
	 */
	it = "Strcpy";
	check(Strcpy(one, "abcd") == one, 1);	/* Returned value. */
	equal(one, "abcd", 2);			/* Basic test. */

	/*int*/ Strcpy(one, "x");
	equal(one, "x", 3);			/* Writeover. */
	equal(one+2, "cd", 4);			/* Wrote too much? */

	/*void*/ Strcpy(two, "hi there");
	/*void*/ Strcpy(one, two);
	equal(one, "hi there", 5);		/* Basic test encore. */
	equal(two, "hi there", 6);		/* Stomped on source? */

	/*void*/ Strcpy(one, "");
	equal(one, "", 7);			/* Boundary condition. */

	/*
	 * Strcat
	 */
	it = "Strcat";
	/*void*/ Strcpy(one, "ijk");
	check(Strcat(one, "lmn") == one, 1);	/* Returned value. */
	equal(one, "ijklmn", 2);		/* Basic test. */

	/*void*/ Strcpy(one, "x");
	/*void*/ Strcat(one, "yz");
	equal(one, "xyz", 3);			/* Writeover. */
	equal(one+4, "mn", 4);			/* Wrote too much? */

	/*void*/ Strcpy(one, "gh");
	/*void*/ Strcpy(two, "ef");
	/*void*/ Strcat(one, two);
	equal(one, "ghef", 5);			/* Basic test encore. */
	equal(two, "ef", 6);			/* Stomped on source? */

	/*void*/ Strcpy(one, "");
	/*void*/ Strcat(one, "");
	equal(one, "", 7);			/* Boundary conditions. */
	/*void*/ Strcpy(one, "ab");
	/*void*/ Strcat(one, "");
	equal(one, "ab", 8);
	/*void*/ Strcpy(one, "");
	/*void*/ Strcat(one, "cd");
	equal(one, "cd", 9);

	/*
	 * Strncat - first test it as Strcat, with big counts, then
	 * test the count mechanism.
	 */
	it = "Strncat";
	/*void*/ Strcpy(one, "ijk");
	check(Strncat(one, "lmn", 99) == one, 1);	/* Returned value. */
	equal(one, "ijklmn", 2);		/* Basic test. */

	/*void*/ Strcpy(one, "x");
	/*void*/ Strncat(one, "yz", 99);
	equal(one, "xyz", 3);			/* Writeover. */
	equal(one+4, "mn", 4);			/* Wrote too much? */

	/*void*/ Strcpy(one, "gh");
	/*void*/ Strcpy(two, "ef");
	/*void*/ Strncat(one, two, 99);
	equal(one, "ghef", 5);			/* Basic test encore. */
	equal(two, "ef", 6);			/* Stomped on source? */

	/*void*/ Strcpy(one, "");
	/*void*/ Strncat(one, "", 99);
	equal(one, "", 7);			/* Boundary conditions. */
	/*void*/ Strcpy(one, "ab");
	/*void*/ Strncat(one, "", 99);
	equal(one, "ab", 8);
	/*void*/ Strcpy(one, "");
	/*void*/ Strncat(one, "cd", 99);
	equal(one, "cd", 9);

	/*void*/ Strcpy(one, "ab");
	/*void*/ Strncat(one, "cdef", 2);
	equal(one, "abcd", 10);			/* Count-limited. */

	/*void*/ Strncat(one, "gh", 0);
	equal(one, "abcd", 11);			/* Zero count. */

	/*void*/ Strncat(one, "gh", 2);
	equal(one, "abcdgh", 12);		/* Count and length equal. */

	/*
	 * Strncmp - first test as Strcmp with big counts, then test
	 * count code.
	 */
	it = "Strncmp";
	check(Strncmp("", "", 99) == 0, 1);	/* Trivial case. */
	check(Strncmp("a", "a", 99) == 0, 2);	/* Identity. */
	check(Strncmp("abc", "abc", 99) == 0, 3);	/* Multicharacter. */
	check(Strncmp("abc", "abcd", 99) < 0, 4);	/* Length unequal. */
	check(Strncmp("abcd", "abc", 99) > 0, 5);
	check(Strncmp("abcd", "abce", 99) < 0, 6);	/* Honestly unequal. */
	check(Strncmp("abce", "abcd", 99) > 0, 7);
	check(Strncmp("a\203", "a", 2) > 0, 8);	/* Tricky if '\203' < 0 */
	if (charsigned)				/* Sign-bit comparison. */
		check(Strncmp("a\203", "a\003", 2) < 0, 9);
	else
		check(Strncmp("a\203", "a\003", 2) > 0, 9);
	check(Strncmp("abce", "abcd", 3) == 0, 10);	/* Count limited. */
	check(Strncmp("abce", "abc", 3) == 0, 11);	/* Count == length. */
	check(Strncmp("abcd", "abce", 4) < 0, 12);	/* Nudging limit. */
	check(Strncmp("abc", "def", 0) == 0, 13);	/* Zero count. */

	/*
	 * Strncpy - testing is a bit different because of odd semantics
	 */
	it = "Strncpy";
	check(Strncpy(one, "abc", 4) == one, 1);	/* Returned value. */
	equal(one, "abc", 2);			/* Did the copy go right? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strncpy(one, "xyz", 2);
	equal(one, "xycdefgh", 3);		/* Copy cut by count. */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strncpy(one, "xyz", 3);		/* Copy cut just before NUL. */
	equal(one, "xyzdefgh", 4);

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strncpy(one, "xyz", 4);		/* Copy just includes NUL. */
	equal(one, "xyz", 5);
	equal(one+4, "efgh", 6);		/* Wrote too much? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strncpy(one, "xyz", 5);		/* Copy includes padding. */
	equal(one, "xyz", 7);
	equal(one+4, "", 8);
	equal(one+5, "fgh", 9);

	/*void*/ Strcpy(one, "abc");
	/*void*/ Strncpy(one, "xyz", 0);		/* Zero-length copy. */
	equal(one, "abc", 10);	

	/*void*/ Strncpy(one, "", 2);		/* Zero-length source. */
	equal(one, "", 11);
	equal(one+1, "", 12);	
	equal(one+2, "c", 13);

	/*void*/ Strcpy(one, "hi there");
	/*void*/ Strncpy(two, one, 9);
	equal(two, "hi there", 14);		/* Just paranoia. */
	equal(one, "hi there", 15);		/* Stomped on source? */

	/*
	 * Strlen
	 */
	it = "Strlen";
	check(Strlen("") == 0, 1);		/* Empty. */
	check(Strlen("a") == 1, 2);		/* Single char. */
	check(Strlen("abcd") == 4, 3);		/* Multiple chars. */

	/*
	 * Strchr
	 */
	it = "Strchr";
	check(Strchr("abcd", 'z') == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Strchr(one, 'c') == one+2, 2);	/* Basic test. */
	check(Strchr(one, 'd') == one+3, 3);	/* End of String. */
	check(Strchr(one, 'a') == one, 4);	/* Beginning. */
	check(Strchr(one, '\0') == one+4, 5);	/* Finding NUL. */
	/*void*/ Strcpy(one, "ababa");
	check(Strchr(one, 'b') == one+1, 6);	/* Finding first. */
	/*void*/ Strcpy(one, "");
	check(Strchr(one, 'b') == NULL, 7);	/* Empty String. */
	check(Strchr(one, '\0') == one, 8);	/* NUL in empty String. */

	/*
	 * Index - just like Strchr
	 */
	it = "Index";
	check(Index("abcd", 'z') == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Index(one, 'c') == one+2, 2);	/* Basic test. */
	check(Index(one, 'd') == one+3, 3);	/* End of String. */
	check(Index(one, 'a') == one, 4);	/* Beginning. */
	check(Index(one, '\0') == one+4, 5);	/* Finding NUL. */
	/*void*/ Strcpy(one, "ababa");
	check(Index(one, 'b') == one+1, 6);	/* Finding first. */
	/*void*/ Strcpy(one, "");
	check(Index(one, 'b') == NULL, 7);	/* Empty String. */
	check(Index(one, '\0') == one, 8);	/* NUL in empty String. */

	/*
	 * Strrchr
	 */
	it = "Strrchr";
	check(Strrchr("abcd", 'z') == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Strrchr(one, 'c') == one+2, 2);	/* Basic test. */
	check(Strrchr(one, 'd') == one+3, 3);	/* End of String. */
	check(Strrchr(one, 'a') == one, 4);	/* Beginning. */
	check(Strrchr(one, '\0') == one+4, 5);	/* Finding NUL. */
	/*void*/ Strcpy(one, "ababa");
	check(Strrchr(one, 'b') == one+3, 6);	/* Finding last. */
	/*void*/ Strcpy(one, "");
	check(Strrchr(one, 'b') == NULL, 7);	/* Empty String. */
	check(Strrchr(one, '\0') == one, 8);	/* NUL in empty String. */

	/*
	 * Rindex - just like Strrchr
	 */
	it = "Rindex";
	check(Rindex("abcd", 'z') == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Rindex(one, 'c') == one+2, 2);	/* Basic test. */
	check(Rindex(one, 'd') == one+3, 3);	/* End of String. */
	check(Rindex(one, 'a') == one, 4);	/* Beginning. */
	check(Rindex(one, '\0') == one+4, 5);	/* Finding NUL. */
	/*void*/ Strcpy(one, "ababa");
	check(Rindex(one, 'b') == one+3, 6);	/* Finding last. */
	/*void*/ Strcpy(one, "");
	check(Rindex(one, 'b') == NULL, 7);	/* Empty String. */
	check(Rindex(one, '\0') == one, 8);	/* NUL in empty String. */
}

/*MP* added void */

void second()
{
	/*
	 * Strpbrk - somewhat like Strchr
	 */
	it = "Strpbrk";
	check(Strpbrk("abcd", "z") == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Strpbrk(one, "c") == one+2, 2);	/* Basic test. */
	check(Strpbrk(one, "d") == one+3, 3);	/* End of String. */
	check(Strpbrk(one, "a") == one, 4);	/* Beginning. */
	check(Strpbrk(one, "") == NULL, 5);	/* Empty search list. */
	check(Strpbrk(one, "cb") == one+1, 6);	/* Multiple search. */
	/*void*/ Strcpy(one, "abcabdea");
	check(Strpbrk(one, "b") == one+1, 7);	/* Finding first. */
	check(Strpbrk(one, "cb") == one+1, 8);	/* With multiple search. */
	check(Strpbrk(one, "db") == one+1, 9);	/* Another variant. */
	/*void*/ Strcpy(one, "");
	check(Strpbrk(one, "bc") == NULL, 10);	/* Empty String. */
	check(Strpbrk(one, "") == NULL, 11);	/* Both Strings empty. */

	/*
	 * Strstr - somewhat like Strchr
	 */
	it = "Strstr";
	check(Strstr("abcd", "z") == NULL, 1);	/* Not found. */
	check(Strstr("abcd", "abx") == NULL, 2);	/* Dead end. */
	/*void*/ Strcpy(one, "abcd");
	check(Strstr(one, "c") == one+2, 3);	/* Basic test. */
	check(Strstr(one, "bc") == one+1, 4);	/* Multichar. */
	check(Strstr(one, "d") == one+3, 5);	/* End of String. */
	check(Strstr(one, "cd") == one+2, 6);	/* Tail of String. */
	check(Strstr(one, "abc") == one, 7);	/* Beginning. */
	check(Strstr(one, "abcd") == one, 8);	/* Exact match. */
	check(Strstr(one, "abcde") == NULL, 9);	/* Too long. */
	check(Strstr(one, "de") == NULL, 10);	/* Past end. */
	check(Strstr(one, "") == one+4, 11);	/* Finding empty. */
	/*void*/ Strcpy(one, "ababa");
	check(Strstr(one, "ba") == one+1, 12);	/* Finding first. */
	/*void*/ Strcpy(one, "");
	check(Strstr(one, "b") == NULL, 13);	/* Empty String. */
	check(Strstr(one, "") == one, 14);	/* Empty in empty String. */
	/*void*/ Strcpy(one, "bcbca");
	check(Strstr(one, "bca") == one+2, 15);	/* False start. */
	/*void*/ Strcpy(one, "bbbcabbca");
	check(Strstr(one, "bbca") == one+1, 16);	/* With overlap. */

	/*
	 * Strspn
	 */
	it = "Strspn";
	check(Strspn("abcba", "abc") == 5, 1);	/* Whole String. */
	check(Strspn("abcba", "ab") == 2, 2);	/* Partial. */
	check(Strspn("abc", "qx") == 0, 3);	/* None. */
	check(Strspn("", "ab") == 0, 4);	/* Null String. */
	check(Strspn("abc", "") == 0, 5);	/* Null search list. */

	/*
	 * Strcspn
	 */
	it = "Strcspn";
	check(Strcspn("abcba", "qx") == 5, 1);	/* Whole String. */
	check(Strcspn("abcba", "cx") == 2, 2);	/* Partial. */
	check(Strcspn("abc", "abc") == 0, 3);	/* None. */
	check(Strcspn("", "ab") == 0, 4);	/* Null String. */
	check(Strcspn("abc", "") == 3, 5);	/* Null search list. */

	/*
	 * Strtok - the hard one
	 */
	it = "Strtok";
	/*void*/ Strcpy(one, "first, second, third");
	equal(Strtok(one, ", "), "first", 1);	/* Basic test. */
	equal(one, "first", 2);
	equal(Strtok((char *)NULL, ", "), "second", 3);
	equal(Strtok((char *)NULL, ", "), "third", 4);
	check(Strtok((char *)NULL, ", ") == NULL, 5);
	/*void*/ Strcpy(one, ", first, ");
	equal(Strtok(one, ", "), "first", 6);	/* Extra delims, 1 tok. */
	check(Strtok((char *)NULL, ", ") == NULL, 7);
	/*void*/ Strcpy(one, "1a, 1b; 2a, 2b");
	equal(Strtok(one, ", "), "1a", 8);	/* Changing delim lists. */
	equal(Strtok((char *)NULL, "; "), "1b", 9);
	equal(Strtok((char *)NULL, ", "), "2a", 10);
	/*void*/ Strcpy(two, "x-y");
	equal(Strtok(two, "-"), "x", 11);	/* New String before done. */
	equal(Strtok((char *)NULL, "-"), "y", 12);
	check(Strtok((char *)NULL, "-") == NULL, 13);
	/*void*/ Strcpy(one, "a,b, c,, ,d");
	equal(Strtok(one, ", "), "a", 14);	/* Different separators. */
	equal(Strtok((char *)NULL, ", "), "b", 15);
	equal(Strtok((char *)NULL, " ,"), "c", 16);	/* Permute list too. */
	equal(Strtok((char *)NULL, " ,"), "d", 17);
	check(Strtok((char *)NULL, ", ") == NULL, 18);
	check(Strtok((char *)NULL, ", ") == NULL, 19);	/* Persistence. */
	/*void*/ Strcpy(one, ", ");
	check(Strtok(one, ", ") == NULL, 20);	/* No tokens. */
	/*void*/ Strcpy(one, "");
	check(Strtok(one, ", ") == NULL, 21);	/* Empty String. */
	/*void*/ Strcpy(one, "abc");
	equal(Strtok(one, ", "), "abc", 22);	/* No delimiters. */
	check(Strtok((char *)NULL, ", ") == NULL, 23);
	/*void*/ Strcpy(one, "abc");
	equal(Strtok(one, ""), "abc", 24);	/* Empty delimiter list. */
	check(Strtok((char *)NULL, "") == NULL, 25);
	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strcpy(one, "a,b,c");
	equal(Strtok(one, ","), "a", 26);	/* Basics again... */
	equal(Strtok((char *)NULL, ","), "b", 27);
	equal(Strtok((char *)NULL, ","), "c", 28);
	check(Strtok((char *)NULL, ",") == NULL, 29);
	equal(one+6, "gh", 30);			/* Stomped past end? */
	equal(one, "a", 31);			/* Stomped old tokens? */
	equal(one+2, "b", 32);
	equal(one+4, "c", 33);

	/*
	 * Memcmp
	 */
	it = "Memcmp";
	check(Memcmp("a", "a", 1) == 0, 1);	/* Identity. */
	check(Memcmp("abc", "abc", 3) == 0, 2);	/* Multicharacter. */
	check(Memcmp("abcd", "abce", 4) < 0, 3);	/* Honestly unequal. */
	check(Memcmp("abce", "abcd", 4) > 0, 4);
	check(Memcmp("alph", "beta", 4) < 0, 5);
	if (charsigned)				/* Sign-bit comparison. */
		check(Memcmp("a\203", "a\003", 2) < 0, 6);
	else
		check(Memcmp("a\203", "a\003", 2) > 0, 6);
	check(Memcmp("abce", "abcd", 3) == 0, 7);	/* Count limited. */
	check(Memcmp("abc", "def", 0) == 0, 8);	/* Zero count. */

	/*
	 * Memchr
	 */
	it = "Memchr";
	check(Memchr("abcd", 'z', 4) == NULL, 1);	/* Not found. */
	/*void*/ Strcpy(one, "abcd");
	check(Memchr(one, 'c', 4) == one+2, 2);	/* Basic test. */
	check(Memchr(one, 'd', 4) == one+3, 3);	/* End of String. */
	check(Memchr(one, 'a', 4) == one, 4);	/* Beginning. */
	check(Memchr(one, '\0', 5) == one+4, 5);	/* Finding NUL. */
	/*void*/ Strcpy(one, "ababa");
	check(Memchr(one, 'b', 5) == one+1, 6);	/* Finding first. */
	check(Memchr(one, 'b', 0) == NULL, 7);	/* Zero count. */
	check(Memchr(one, 'a', 1) == one, 8);	/* Singleton case. */
	/*void*/ Strcpy(one, "a\203b");
	check(Memchr(one, (char)0203, 3) == one+1, 9);	/* Unsignedness. */

	/*
	 * Memcpy
	 *
	 * Note that X3J11 says Memcpy must work regardless of overlap.
	 * The SVID says it might fail.
	 */
	it = "Memcpy";
	check(Memcpy(one, "abc", 4) == one, 1);	/* Returned value. */
	equal(one, "abc", 2);			/* Did the copy go right? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Memcpy(one+1, "xyz", 2);
	equal(one, "axydefgh", 3);		/* Basic test. */

	/*void*/ Strcpy(one, "abc");
	/*void*/ Memcpy(one, "xyz", 0);
	equal(one, "abc", 4);			/* Zero-length copy. */

	/*void*/ Strcpy(one, "hi there");
	/*void*/ Strcpy(two, "foo");
	/*void*/ Memcpy(two, one, 9);
	equal(two, "hi there", 5);		/* Just paranoia. */
	equal(one, "hi there", 6);		/* Stomped on source? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Memcpy(one+1, one, 9);
	equal(one, "aabcdefgh", 7);		/* Overlap, right-to-left. */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Memcpy(one+1, one+2, 7);
	equal(one, "acdefgh", 8);		/* Overlap, left-to-right. */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Memcpy(one, one, 9);
	equal(one, "abcdefgh", 9);		/* 100% overlap. */

	/*
	 * Memccpy - first test like Memcpy, then the search part
	 *
	 * The SVID, the only place where Memccpy is mentioned, says
	 * overlap might fail, so we don't try it.  Besides, it's hard
	 * to see the rationale for a non-left-to-right Memccpy.
	 */
	it =(char *)"Memccpy";
	check(Memccpy(one, "abc", 'q', 4) == NULL, 1);	/* Returned value. */
	equal(one, "abc", 2);			/* Did the copy go right? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Memccpy(one+1, "xyz", 'q', 2);
	equal(one, "axydefgh", 3);		/* Basic test. */

	/*void*/ Strcpy(one, "abc");
	/*void*/ Memccpy(one, "xyz", 'q', 0);
	equal(one, "abc", 4);			/* Zero-length copy. */

	/*void*/ Strcpy(one, "hi there");
	/*void*/ Strcpy(two, "foo");
	/*void*/ Memccpy(two, one, 'q', 9);
	equal(two, "hi there", 5);		/* Just paranoia. */
	equal(one, "hi there", 6);		/* Stomped on source? */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Strcpy(two, "horsefeathers");
	check(Memccpy(two, one, 'f', 9) == two+6, 7);	/* Returned value. */
	equal(one, "abcdefgh", 8);		/* Source intact? */
	equal(two, "abcdefeathers", 9);		/* Copy correct? */

	/*void*/ Strcpy(one, "abcd");
	/*void*/ Strcpy(two, "bumblebee");
	check(Memccpy(two, one, 'a', 4) == two+1, 10);	/* First char. */
	equal(two, "aumblebee", 11);
	check(Memccpy(two, one, 'd', 4) == two+4, 12);	/* Last char. */
	equal(two, "abcdlebee", 13);
	/*void*/ Strcpy(one, "xyz");
	check(Memccpy(two, one, 'x', 1) == two+1, 14);	/* Singleton. */
	equal(two, "xbcdlebee", 15);

	/*
	 * Memset
	 */
	it = "Memset";
	/*void*/ Strcpy(one, "abcdefgh");
	check(Memset(one+1, 'x', 3) == one+1, 1);	/* Return value. */
	equal(one, "axxxefgh", 2);		/* Basic test. */

	/*void*/ Memset(one+2, 'y', 0);
	equal(one, "axxxefgh", 3);		/* Zero-length set. */

	/*void*/ Memset(one+5, '\0', 1);
	equal(one, "axxxe", 4);			/* Zero fill. */
	equal(one+6, "gh", 5);			/* And the leftover. */

	/*void*/ Memset(one+2, (char)010045, 1);
	equal(one, "ax\045xe", 6);		/* Unsigned char convert. */

	/*
	 * Bcopy - much like Memcpy
	 *
	 * Berklix manual is silent about overlap, so don't test it.
	 */
	it = "Bcopy";
	/*void*/ Bcopy("abc", one, 4);
	equal(one, "abc", 1);			/* Simple copy. */

	/*void*/ Strcpy(one, "abcdefgh");
	/*void*/ Bcopy("xyz", one+1, 2);
	equal(one, "axydefgh", 2);		/* Basic test. */

	/*void*/ Strcpy(one, "abc");
	/*void*/ Bcopy("xyz", one, 0);
	equal(one, "abc", 3);			/* Zero-length copy. */

	/*void*/ Strcpy(one, "hi there");
	/*void*/ Strcpy(two, "foo");
	/*void*/ Bcopy(one, two, 9);
	equal(two, "hi there", 4);		/* Just paranoia. */
	equal(one, "hi there", 5);		/* Stomped on source? */

	/*
	 * Bzero
	 */
	it = "Bzero";
	/*void*/ Strcpy(one, "abcdef");
	Bzero(one+2, 2);
	equal(one, "ab", 1);			/* Basic test. */
	equal(one+3, "", 2);
	equal(one+4, "ef", 3);

	/*void*/ Strcpy(one, "abcdef");
	Bzero(one+2, 0);
	equal(one, "abcdef", 4);		/* Zero-length copy. */

	/*
	 * Bcmp - somewhat like Memcmp
	 */
	it = "Bcmp";
	check(Bcmp("a", "a", 1) == 0, 1);	/* Identity. */
	check(Bcmp("abc", "abc", 3) == 0, 2);	/* Multicharacter. */
	check(Bcmp("abcd", "abce", 4) != 0, 3);	/* Honestly unequal. */
	check(Bcmp("abce", "abcd", 4) != 0, 4);
	check(Bcmp("alph", "beta", 4) != 0, 5);
	check(Bcmp("abce", "abcd", 3) == 0, 6);	/* Count limited. */
	check(Bcmp("abc", "def", 0) == 0, 8);	/* Zero count. */

}

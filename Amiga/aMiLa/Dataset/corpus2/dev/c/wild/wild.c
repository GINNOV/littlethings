/*	Last updated 02.09.95
**
**  Wild.c   -	 Matches strings using wildcards
**
**  Call as:	 MatchWild(char *string, char *sought);
**
**	Where string is the string to be checked (containing wilds)
**	and sought is the string to compare it against.
**	Case-insensitive.
**
**  Note for bored people:
**	You may be asking why I explicitly included a routine for #? when
**	the code for # and ? can cope with it fine, and this is why:
**	i) I originally only wanted #? support
**	ii) When I added ? and # support I also added * support so there
**	    wasn't any point in getting rid of the #? bit.
**
**  Further note for everyone:
**	Chances are when you are dealing with wildcards you're not going
**	to have to test things like *a*r*t*i*c*h*o*k*e#?#?#?#? but maybe
**	you will. Since the routine is recursive for  multiple wildcards
**	your program may crash due to stack overflow. In which case either
**	run it with a bigger stack or compile it in such a way that it
**	dynamically allocates stack memory. To do this with dice add the
**	-gs switch.
*/

#include <stdio.h>
#include <exec/types.h>
#include <dos/dos.h>

BOOL MatchWild(char *, char *);
LONG ToUpper(LONG c)
{

/* This is an international ToUpper. */

	if(c >= 224 && c <= 254)
		c -= 32;
	else
		c = toupper(c);

	return(c);
}


BOOL MatchWild(char *string, char *sought)
{

    char pattern[256], ref[256];
    int i, j, k;

    i=0;
    while ((pattern[i] = ToUpper(*string++)) != '\0')
	i++;
    i=0;
    while ((ref[i] = ToUpper(*sought++)) != '\0')
	i++;

    i=0;    /* i now becomes index of array pattern */
    j=0;    /* j is the same for array ref */

    while(pattern[i] != '\0')
    {
	if( (pattern[i] != '#') && (pattern[i] != '?') && (pattern[i] != '*') )
	{
	    if( pattern[i] != ref[j] )
		return FALSE;
	}
	else
	{
/* there is a wild-card in pattern. We interpret it here. */

	    if( ((pattern[i] == '#') && (pattern[i+1] == '?')) || pattern[i] == '*' )

/* We have a #?-type wildcard.
** This means _zero_ or more arbitrary characters.
*/

	    {
		pattern[i]=='#'?i+=2:i++;
		if(pattern[i] == '\0')  /* Kinda fudgy: needs to work for the   */
		    return TRUE;	/* case of #? followd by nothing.	*/
		k=j;
		while(ref[k] != '\0')
		{
		    if (MatchWild(&pattern[i], &ref[k]))
			return TRUE;
		    else
			k++;
		}
		return FALSE;
	    }

/* Code to deal with #. I bet noboby ever uses this except when followed by
** a ?, but for completeness I guess I'd better include it...
*/
	    else if(pattern[i]=='#')
	    {
		i++;
		if(pattern[i] == '\0')  /* same fudge as before */
		    return TRUE;
		k=j;
		while(ref[k] == pattern[i])
		{
		    if (MatchWild(&pattern[i], &ref[k]))
			return TRUE;
		    else
			k++;
		}
		/* The loop increases i&j later on but j is already in the
		** right place for the next test so... */
		j--;
	    }
	    else
	    {
	    /*
	    ** Gotta be a '?'
	    */
	    if(ref[j]=='\0')
		return FALSE;
	    }
	}
    i++;
    j++;
    }

    /* We arrive here if we reach the end of our pattern and it is
    ** consistent with our reference. All is the fine if we have also
    ** reached the end of our reference
    */

if( ref[j] == '\0' )
    return TRUE;
else
    return FALSE;
}



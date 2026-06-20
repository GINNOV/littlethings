/*
 * Libraries and headers for PDC release 3.3 (C) 1989 Lionel Hummel.
 * PDC Software Distribution (C) 1989 Lionel Hummel and Paul Petersen.
 * PDC I/O Library (C) 1987 by J.A. Lydiatt.
 *
 * This code is freely redistributable upon the conditions that this 
 * notice remains intact and that modified versions of this file not
 * be included as part of the PDC Software Distribution without the
 * express consent of the copyright holders.  No warrantee of any
 * kind is provided with this code.  For further information, contact:
 *
 *  PDC Software Distribution    Internet:                     BIX:
 *  P.O. Box 4006             or hummel@cs.uiuc.edu            lhummel
 *  Urbana, IL  61801-8801       petersen@uicsrd.csrd.uiuc.edu
 */

/* Environment.c - Functions to aid in dealing with environment variables
 *
 *	getenv(v)	Returns the string value of environment variable v
 *	setenv(v, s)	Sets environment variable v to string s
 *	putenv(s)	s is in form "variable=value", calls setenv()
 *	ParseEnv(s)	Places the next parsed entry in String or NULL if 
 *                      no more.  String is set to s if s is non-NULL.
 */

/* Misc. notes on environment variables:
 * To embed a space in a file name, precede it with the escape delimiter
 * (usually a backslash).
 */

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>
#include <string.h>

#define MAX_ENV_LENGTH (1024)

#define ARG_DELIM	';'
#define ESC_DELIM	'\\'
#define QUOTE_CHAR	'"'

char *String = NULL;
char *currChar = NULL;
char  lastChar = '\0';


char *getenv(v)
char *v;
{
    int  env_file;
    int  size = 0;
    char *tmp_buf, *value;       /* Used for environment filename and input buffer */
    char *return_buf;
    char *ptr;

    value = tmp_buf = (char *) malloc(MAX_ENV_LENGTH);
    if (!tmp_buf)
        exit(ENOMEM);

    
    if (strncmp(v, "ENV:", 4) == 0)
        strcpy(value, v);
    else
        sprintf(value, "ENV:%s", v);

    if ((env_file = open(value, O_RDONLY)) != -1)	{
        size = read(env_file, value, MAX_ENV_LENGTH);
        close(env_file);
    }
    else {
        return(NULL);
    }

    value[size] = '\0';

    ptr = return_buf = (char *) malloc(size+1);
    if (return_buf)
        while (*ptr++ = *value++);
    else
        exit(ENOMEM);

    free(tmp_buf);

    return(return_buf);
}


int setenv(v, s)
char *v;
char *s;
{
    int  env_file;
    char *tmp_buf;

    tmp_buf = (char *) malloc(MAX_ENV_LENGTH);
    if (!tmp_buf)
        return(0);
    
    if (strncmp(v, "ENV:", 4) == 0)
        strcpy(tmp_buf, v);
    else
        sprintf(tmp_buf, "ENV:%s", v);

    if ((env_file = open(tmp_buf, O_CREAT+O_WRONLY)) != -1)	{
        write(env_file, s, strlen(s));
        close(env_file);
        }

    free(tmp_buf);
}


int putenv(s)
char *s;
{
    char *variable;
    char *value;

    variable = strdup(s);
    if (variable)  {
        value = strchr(s, '=');
        if (value != NULL)  {
            *value++ = '\0';
            setenv(variable, value);
            }
        free(variable);
        }
}


char *ParseEnv(s)
char *s;
{
    char *ptr;
    int   in_quote = 0;

    if (s != NULL)  {
        if (String != NULL)
            free(String);
        currChar = String = strdup(s);
        }

    s = ptr = currChar;

    if (*currChar == '\0')
        return(NULL);

    while ( (*currChar != '\0') && (*currChar != ARG_DELIM))	{
        if (*currChar == ESC_DELIM)
             switch (*(currChar+1))	{
                 case QUOTE_CHAR:
                 case ESC_DELIM:
                 case ARG_DELIM:  *ptr++ = *++currChar;
                                   currChar++;
                                   break;
                 default:  *ptr++ = *currChar++;
                            break;
                 }
        else if (isspace(*currChar) && !in_quote)
            currChar++;
        else if (*currChar == QUOTE_CHAR) {
            in_quote = !in_quote;
            currChar++;
            }
        else
            *ptr++ = *currChar++;
        }

    if (*currChar == ARG_DELIM)
        currChar++;

    *ptr = '\0';

    return(s);
}

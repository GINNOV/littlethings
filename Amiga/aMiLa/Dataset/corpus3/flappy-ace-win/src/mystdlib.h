#ifndef _MYSTDLIB_H_
#define _MYSTDLIB_H_

#include <ace/utils/file.h>
#include <stdio.h>

char *strtok(char *str, const char *delim);
long strtol(const char *str, char **endptr, int base);
char *fgets(char *str, int num, FILE *stream);
char mfgetc(FILE *stream);

#endif
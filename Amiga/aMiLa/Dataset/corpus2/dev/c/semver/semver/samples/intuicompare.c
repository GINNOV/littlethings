/*
The MIT License

Copyright (c) Carsten Sonne Larsen

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

#include <stdio.h>
#include <string.h>
#include <semver.h>

#include <proto/exec.h>
#include <intuition/intuitionbase.h>

#ifndef INTUITIONNAME
#define INTUITIONNAME "intuition.library"
#endif

const char *vers = "\0$VER: intuicompare 1.0 (29.04.2020) semver sample program";
const char *copy = "Copyright (c) Carsten Sonne Larsen";

struct IntuitionBase *IntuitionBase = NULL;

char compare[] = "50.1";
char *current;

void ExtractVersion(char *string, char **version)
{
    char *c = string;
    char *d = AllocVec(strlen(string) + 1, MEMF_CLEAR);
    *version = d;

    while (*c != '\0' && (*c < '0' || *c > '9'))
    {
        c++;
    }

    if (*c != '\0')
    {
        do
        {
            *d++ = *c++;
            /* code */
        } while (*c != '\0' && *c != ' ');
    }
}

int main()
{
    semver_t current_version = {0, 0, 0, 0, 0};
    semver_t compare_version = {0, 0, 0, 0, 0};

    printf("Comparing to " INTUITIONNAME " version %s\n", compare);

    if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary((STRPTR)INTUITIONNAME, 0)))
    {
        printf("Could not open " INTUITIONNAME "\n");
        return -1;
    }

    printf("Found " INTUITIONNAME "\n");
    printf("Found library string: %s", (char *)IntuitionBase->LibNode.lib_IdString);
    ExtractVersion((char *)IntuitionBase->LibNode.lib_IdString, &current);

    if (semver_parse(current, &current_version) || semver_parse(compare, &compare_version))
    {
        fprintf(stderr, "Invalid semver string\n");
        FreeVec(compare);
        CloseLibrary((struct Library *)IntuitionBase);
        return -1;
    }

    printf("Extracted version from library string: %s\n", current);
    int resolution = semver_compare(current_version, compare_version);

    if (resolution == 0)
    {
        printf(INTUITIONNAME " version is equal to %s\n", compare);
    }
    else if (resolution == -1)
    {
        printf(INTUITIONNAME " version is lower than %s\n", compare);
    }
    else
    {
        printf(INTUITIONNAME " version is higher than %s\n", compare);
    }

    // Free allocated memory when we're done
    semver_free(&current_version);
    semver_free(&compare_version);
    FreeVec(current);
    CloseLibrary((struct Library *)IntuitionBase);
    return 0;
}
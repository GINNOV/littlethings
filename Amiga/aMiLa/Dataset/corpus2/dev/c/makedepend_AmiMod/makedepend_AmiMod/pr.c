/*

Copyright (c) 1993, 1994, 1998 The Open Group
Copyright (c) 2023, 2025 Hagbard Celine

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

*/

#include "def.h"

#include <dos.h>
#include <proto/dos.h>

void
add_include(struct filepointer *filep, struct inclist *file,
	    struct inclist *file_red, const char *include, int type,
	    boolean failOK)
{
    struct inclist *newfile;

    /*
     * First decide what the pathname of this include file really is.
     */
    newfile = inc_path(file->i_file, include, type);
    if (newfile == NULL) {
	if (failOK || (type == INCLUDE && ignoresyserr))
	    return;
	if (file != file_red)
	    warning("%s (reading %s, line %ld): ",
		    file_red->i_file, file->i_file, filep->f_line);
	else
	    warning("%s, line %ld: ", file->i_file, filep->f_line);
	warning1("cannot find include file \"%s\"\n", include);
	show_where_not = TRUE;
	newfile = inc_path(file->i_file, include, type);
	show_where_not = FALSE;
    }

    if (newfile) {
	included_by(file, newfile);
	if (!(newfile->i_flags & SEARCHED)) {
	    struct filepointer *content;

	    newfile->i_flags |= SEARCHED;
	    content = getfile(newfile->i_file);
	    find_includes(content, newfile, file_red, 0, failOK);
	    freefile(content);
	}
    }
}

static void
pr(struct inclist *ip, const char *file, const char *base)
{
    static const char *lastfile;
    static int current_len;
    int len;
    static const char *lastbase;

    printed = TRUE;

    len = strlen(ip->i_file)+1;
    if (current_len + len > width || file != lastfile) {
	const char *filebase;

	lastfile = file;

	if (outbaseonly)
    	    filebase=FilePart(base);
	else
	    filebase=base;

	if (base != lastbase)
	{
	    if (depself)
	    {
		current_len = fprintf(stdout, "\n%s%s.o: %s.c %s",
			objprefix, filebase, base, ip->i_file);
	    }
	    else
	    {
		current_len = fprintf(stdout, "\n%s%s.o: %s",
	 		objprefix, filebase, ip->i_file);
	    }
	    lastbase = base;
	}
	else
	{
	    current_len = fprintf(stdout, "\n%s%s.o: %s",
		objprefix, filebase, ip->i_file);
	}
    }
    else {
	    fprintf(stdout, " %s", ip->i_file);
	    current_len += len;
    }

    /*
     * If verbose is set, then print out what this file includes.
     */
    if (!verbose || ip->i_list == NULL || ip->i_flags & NOTIFIED)
	return;
    ip->i_flags |= NOTIFIED;
    lastfile = NULL;
    printf("\n# %s includes:", ip->i_file);
    {
	unsigned int i;

	for (i = 0; i < ip->i_listlen; i++)
	    printf("\n#\t%s", ip->i_list[i]->i_incstring);
    }
}

void
recursive_pr_include(struct inclist *head, const char *file, const char *base)
{
    if (head->i_flags & MARKED)
	return;
    head->i_flags |= MARKED;
    if (head->i_file != file)
	pr(head, file, base);
    {
	unsigned int i;

	for (i = 0; i < head->i_listlen; i++)
	    recursive_pr_include(head->i_list[i], file, base);
    }
}

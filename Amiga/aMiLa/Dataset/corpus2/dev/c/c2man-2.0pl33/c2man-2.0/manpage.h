/* $Id: manpage.h,v 2.0.1.5 1993/11/08 00:01:38 greyham Exp $
 * stuff to do with manual page outputing
 */
#ifndef MANPAGE_H
#define MANPAGE_H

#include "c2man.h"

typedef struct Section Section;
struct Section
{
    Section *next;
    char *name;
    char *text;
    boolean been_output;
};

typedef struct ManualPage ManualPage;
struct ManualPage
{
    DeclSpec *decl_spec;
    Declarator *declarator;
    ManualPage *next;
    Section *first_section;
    char *description;
    char *returns;
    char *sourcefile;
    Time_t sourcetime;
};

enum LinkType
{
#ifdef HAS_LINK
    LINK_HARD,	/* filesystem hard link */
#endif
#ifdef HAS_SYMLINK
    LINK_SOFT,	/* filesystem soft link */
#endif
    LINK_FILE,	/* nroff file with .so directive */
    LINK_NONE,	/* don't create extra links for it */
    LINK_REMOVE	/* don't create extra links & remove existing ones */
};

/* list of manual pages */
extern ManualPage *firstpage;

void
new_manual_page _((char *comment, DeclSpec *decl_spec, Declarator *declarator));

/* remember the terse description from the first comment in a file */
void remember_terse _((char *comment));

void output_manual_pages _((ManualPage *first, int num_input_files,
    enum LinkType link_type));

void free_manual_pages _((ManualPage *first));

void output_format_string _((const char *fmt));

void output_warning _((void));

void output_comment _((const char *comment));

#endif

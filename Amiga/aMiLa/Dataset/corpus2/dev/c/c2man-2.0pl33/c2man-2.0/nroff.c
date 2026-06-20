/* $Id: nroff.c,v 2.0.1.13 1994/07/25 11:47:26 greyham Exp greyham $
 * functions for nroff style output.
 */
#include "c2man.h"
#include "manpage.h"
#include "output.h"


void nroff_text(text)
const char *text;
{
    put_string(text);
}

void nroff_char(c)
const int c;
{
    putchar(c);
}

void nroff_comment() { put_string(".\\\" "); }

void nroff_header(firstpage, input_files, grouped, name, section)
ManualPage *firstpage;
int input_files;
boolean grouped;
const char *name;
const char *section;
{
#ifdef HAS_STRFTIME
    char month[20];
#else
    char *month;
    static char *month_list[] =
    { "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December" };
#endif
    Time_t raw_time;
    struct tm *filetime;
    
    if (make_embeddable) return;

    output_warning();
    put_string(".TH \"");

    /* if lots of files contributed, use the current time; otherwise use the
     * time of the source file they came from.
     */
    raw_time = (grouped && input_files > 1) ? time((Time_t *)NULL)
					    : firstpage->sourcetime;

    filetime = localtime(&raw_time);

#ifdef HAS_STRFTIME
    /* generate the date format string */
    strftime(month, sizeof month,"%B",filetime);
#else
    month = month_list[filetime->tm_mon];
#endif

    nroff_text(name);

    printf("\" %s \"%d %s %d\"",
		section,filetime->tm_mday,month,filetime->tm_year+1900);

/* I have conflicting info about how the .TH macro works.... */
#ifdef HENRYS_TH /* As per Henry Spencer's "How to write a manual page" */
    if (manual_name) printf(" \"%s\"", manual_name);
    put_string("\n.BY");    
#endif
    printf(" \"%s",progname);
    if ((input_files <= 1 || !grouped) && firstpage->sourcefile)
    {
	const char *basename = strrchr(firstpage->sourcefile, '/');
	if (basename == NULL)
	    basename = firstpage->sourcefile;
	else
	    basename++;
	printf(" %s", basename);
    }
#ifndef HENRYS_TH
    if (manual_name) printf("\" \"%s", manual_name);
#endif
    put_string("\"\n");    

#ifdef NeXT
    /* define our own .SS on packages (such as NeXT's) where it doesn't move
     * left a little. Sorry, awf doesn't support .SS.
     */
    put_string(".de SS\n.}X .25i \"\" \"\"\n.nr )E 2\n");
    put_string("\\&\\\\$1\n.br\n..\n");
#endif
}

void nroff_dash()	{ put_string("\\-"); }

void nroff_section(name)
const char *name;
{
    put_string(".SH \"");
    nroff_text(name);
    put_string("\"\n");
}

void nroff_sub_section(name)
const char *name;
{
    put_string(".SS \"");
    nroff_text(name);
    put_string("\"\n");
}

void nroff_break_line()	{ put_string(".br\n"); }
void nroff_blank_line() { put_string(".sp\n"); }

void nroff_code_start() { put_string(".ft B\n"); }
void nroff_code_end()	{ put_string(".ft R\n"); }

void nroff_code(text)
const char *text;
{
    put_string("\\fB");
    nroff_text(text);
    put_string("\\fR");
}

void nroff_tag_entry_start()		{ put_string(".TP\n.B \""); }
void nroff_tag_entry_start_extra()	{ put_string(".TP\n.BR \""); }
void nroff_tag_entry_end()		{ put_string("\"\n"); }
void nroff_tag_entry_end_extra(text)
const char *text;
{
    put_string("\" \"\t(");
    nroff_text(text);
    put_string(")\"\n");
}
	
void nroff_table_start(longestag)
const char *longestag;
{
    void nroff_list_start();
    nroff_list_start();

    /* We measure the length of the longest tag in the table by changing to the
     * code font, taking it's width with \w'string' and adding a little for
     * the space between the tag and description.  This gets stored in the TL
     * number register, where the nroff_table_entry can find it.
     * This isn't foolproof, because a shorter tag may be longer if it contains
     * wider characters, but the extra space gives a little head room anyway.
     */
    nroff_code_start();
    printf(".nr TL \\w'%s'u+0.2i\n", longestag);
    nroff_code_end();
}

void nroff_table_entry(name, description)
const char *name;
const char *description;
{
    put_string(".TP \\n(TLu\n");

    nroff_code(name);
    nroff_char('\n');
    if (description)
	output_comment(description);
    else
	nroff_char('\n');
}

void nroff_table_end()	{ put_string(".RE\n.PD\n"); }

void nroff_indent()	{ put_string(".IP\n"); }

void nroff_list_start() { put_string(".RS 0.75in\n.PD 0\n"); }

void nroff_list_entry(name)
const char *name;
{
    nroff_code(name);
}

void nroff_list_separator() { put_string(",\n"); }
void nroff_list_end()	{ nroff_char('\n'); nroff_table_end(); }

void nroff_include(filename)
const char *filename;
{
    printf(".so %s\n", filename);
}

void nroff_name(name)
const char *name;
{
    if (name) nroff_text(name);
    else      nroff_section("NAME");
}

void nroff_terse_sep()
{
    nroff_char(' ');
    nroff_dash();
    nroff_char(' ');
}

void nroff_emphasized(text)
const char *text;
{
    put_string("\\fI");
    nroff_text(text);
    put_string("\\fR");
}

void nroff_reference(text)
const char *text;
{
    nroff_text(text);
    nroff_char('(');
    nroff_text(manual_section);
    nroff_char(')');
}

struct Output nroff_output =
{
    nroff_comment,
    nroff_header,
    nroff_dash,
    nroff_section,
    nroff_sub_section,
    nroff_break_line,
    nroff_blank_line,
    nroff_code_start,
    nroff_code_end,
    nroff_code,
    dummy,		/* nroff_tag_list_start */
    dummy,		/* nroff_tag_list_end */
    nroff_tag_entry_start,
    nroff_tag_entry_start_extra,
    nroff_tag_entry_end,
    nroff_tag_entry_end_extra,
    nroff_table_start,
    nroff_table_entry,
    nroff_table_end,
    nroff_indent,
    nroff_list_start,
    nroff_code,		/* nroff_list_entry */
    nroff_list_separator,
    nroff_list_end,
    nroff_include,
    dummy,       /* nroff_file_end */
    nroff_text,
    nroff_char,
    NULL,	/* nroff_parse_option */
    dummy,	/* nroff_print_options */
    nroff_name,
    nroff_terse_sep,
    nroff_reference,
    nroff_emphasized
};

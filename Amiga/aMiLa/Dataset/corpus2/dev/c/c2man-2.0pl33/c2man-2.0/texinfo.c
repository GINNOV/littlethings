/* $Id: texinfo.c,v 2.0.1.10 1994/09/16 05:55:19 greyham Exp $
 * functions for texinfo style output.
 */
#include "c2man.h"
#include "manpage.h"
#include "output.h"

static char *heading_not_in_contents[] =
	 {"@chapheading ", "@heading ", "@subheading ", "@subsubheading "};
static char *heading_in_contents[] =
	 {"@chapter ", "@section ", "@subsection ", "@subsubsection "};

#define n_levels  (sizeof(heading_not_in_contents) / sizeof(char *))

#define level(n) ((n) >= n_levels ? n_levels - 1 : (n))

/* section level for man page entry */
static int top_level = 1;

/* always output node for manpage, even if embedded */
static int embed_node_info = 0;

/* use title as name of section, rather than "NAME" */
static int title_name = 0;

/* the section title, filled in by texinfo_header */
static const char *title = "INTERNAL ERROR, BOGUS TITLE DUDE!";

void texinfo_char(c)
const int c;
{
    int i;

    switch(c)
    {
    case '\t':
	for (i = 0; i < NUM_TAB_SPACES; i++)
	    putchar(' ');
	break;
    default:
    	putchar(c);
	break;
    }
}

void texinfo_text(text)
const char *text;
{
    while (*text)
	texinfo_char(*text++);
}

void texinfo_comment() { put_string("@c "); }

void texinfo_header(firstpage, input_files, grouped, name, section)
ManualPage *firstpage;
int input_files;
boolean grouped;
const char *name;
const char *section;
{
    if (! make_embeddable)
    {
	put_string("\\input texinfo @c -*-texinfo-*-\n");
	output_warning();
	put_string("@c %**start of header\n");
	put_string("@setfilename ");
	texinfo_text(name);
	put_string(".info\n@settitle ");
	texinfo_text(name);
	putchar('\n');
	put_string("@c %**end of header\n");

	put_string("@node Top, ");
	texinfo_text(name);
	put_string(", (dir), (dir)\n");
    }

    if (! make_embeddable || embed_node_info)
    {
      put_string("@node ");
      texinfo_text(name);
      put_string(", (dir), Top, (dir)\n");
    }

    title = name;
}

void texinfo_dash()	{ put_string("---"); }

void texinfo_section(name)
const char *name;
{
    put_string(heading_not_in_contents[level(top_level)]);
    texinfo_text(name);
    putchar('\n');
    put_string("@noindent\n");
}

void texinfo_section_in_contents(name)
const char *name;
{
    put_string(heading_in_contents[level(top_level)]);
    texinfo_text(name);
    putchar('\n');
    put_string("@noindent\n");
}

void texinfo_sub_section(name)
const char *name;
{
    put_string(heading_not_in_contents[level(top_level+1)]);
    texinfo_text(name);
    putchar('\n');
    put_string("@noindent\n");
}

void texinfo_break_line() { /* put_string("@*\n"); */ }
void texinfo_blank_line() { put_string("@sp 1\n"); }

void texinfo_code_start() { put_string("@example\n"); }
void texinfo_code_end()	{ put_string("@end example\n"); }

void texinfo_code(text)
const char *text;
{
    put_string("@code{");
    texinfo_text(text);
    put_string("}");
}

void texinfo_tag_list_start()	{ put_string("@display\n@table @code\n"); }
void texinfo_tag_entry_start()	{ put_string("@item "); }
void texinfo_tag_entry_end()	{ putchar('\n'); }

void texinfo_tag_entry_end_extra(text)
const char *text;
{
    putchar('(');
    texinfo_text(text);
    putchar(')');
    texinfo_tag_entry_end();
}
void texinfo_tag_list_end()	{ put_string("@end table\n@end display\n"); }
	
void texinfo_table_start(longestag)
const char *longestag;
{ put_string("@display\n@table @code\n"); }

void texinfo_table_entry(name, description)
const char *name;
const char *description;
{
    put_string("@item ");
    texinfo_text(name);
    putchar('\n');
    if (description)
	output_comment(description);
    else
	putchar('\n');
}

void texinfo_table_end()	{ put_string("@end table\n@end display\n"); }

void texinfo_list_start()	{ }
void texinfo_list_entry(text)
const char *text;
{
    texinfo_code(text);
}
void texinfo_list_separator() { put_string(",\n"); }
void texinfo_list_end()	{ putchar('\n'); }

void texinfo_include(filename)
const char *filename;
{
	put_string("@include ");
	texinfo_text(filename);
	put_string("\n");
}

void texinfo_file_end() { put_string("@bye\n"); }

static first_name = 1;
void texinfo_name(name)
char *name;
{
    if (name)
    {
	if (!first_name || !title_name || strcmp(title,name))
	   texinfo_text(name);
	first_name = 0;
    }
    else
    {
	first_name = 1;
	if (title_name)
	    texinfo_section_in_contents(title);
	else
	    texinfo_section("NAME");
    }
}

void texinfo_terse_sep()
{
    if (!title_name || group_together)
    {
	texinfo_char(' ');
	texinfo_dash();
	texinfo_char(' ');
    }
}

void texinfo_reference(text)
const char *text;
{
    texinfo_text(text);
    texinfo_char('(');
    texinfo_text(manual_section);
    texinfo_char(')');
}



int texinfo_parse_option(option)
char *option;
{
    if	    (option[0] == 't')
	title_name = 1;
    else if (option[0] == 'n')
	embed_node_info = 1;
    else if (option[0] == 's')
    {
	top_level = atoi(&option[1]);
	if (top_level < 0) return 1;
    }
    else return 1;

    return 0;
}

void texinfo_print_options()
{
    fputs("\ttexinfo options:\n", stderr);
    fputs("\tt\tuse manpage title as NAME title\n", stderr);
    fputs("\tn\toutput node info if embedded output\n", stderr);
    fputs("\ts<n>\tset top heading level to <n>\n", stderr);
}


struct Output texinfo_output =
{
    texinfo_comment,
    texinfo_header,
    texinfo_dash,
    texinfo_section,
    texinfo_sub_section,
    texinfo_break_line,
    texinfo_blank_line,
    texinfo_code_start,
    texinfo_code_end,
    texinfo_code,
    texinfo_tag_list_start,
    texinfo_tag_list_end,
    texinfo_tag_entry_start,
    texinfo_tag_entry_start,	/* entry_start_extra */
    texinfo_tag_entry_end,
    texinfo_tag_entry_end_extra,
    texinfo_table_start,
    texinfo_table_entry,
    texinfo_table_end,
    dummy,		/* texinfo_indent */
    texinfo_list_start,
    texinfo_list_entry,
    texinfo_list_separator,
    texinfo_list_end,
    texinfo_include,
    texinfo_file_end,
    texinfo_text,
    texinfo_char,
    texinfo_parse_option,
    texinfo_print_options,
    texinfo_name,
    texinfo_terse_sep,
    texinfo_reference,
    texinfo_text
};

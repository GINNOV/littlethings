/* $Id: latex.c,v 2.0.1.8 1994/09/16 05:55:23 greyham Exp $
 * functions for LaTeX style output.
 */
#include "c2man.h"
#include "manpage.h"
#include "output.h"

static boolean verbatim = FALSE;	/* skip quoting in verbatim section */

void latex_char(c)
const int c;
{
    int i;

    switch (c)
    {
    case '$':
    case '#':
    case '&':
    case '^':
    case '_':
	if (!verbatim)
	    putchar('\\');
	putchar(c);
	break;
    case '>':
    case '<':
	if (!verbatim)
	    putchar('$');
	putchar(c);
	if (!verbatim)
	    putchar('$');
	break;
    case '\t':
	for (i = 0; i < NUM_TAB_SPACES; i++)
	    putchar(' ');
	break;
    default:
	putchar(c);
	break;
    }
}

void latex_text(text)
const char *text;
{
    while(*text)
	latex_char(*text++);
}

void latex_comment() { put_string("% "); }

void latex_header(firstpage, input_files, grouped, name, section)
ManualPage *firstpage;
int input_files;
boolean grouped;
const char *name;
const char *section;
{
    if (make_embeddable) return;

    put_string("\\documentstyle{article}\n");
    output_warning();
	put_string("\\begin{document}\n");
}

void latex_dash()	{ put_string("---"); }

void latex_section(name)
const char *name;
{
    put_string("\\section*{");
    latex_text(name);
    put_string("}\n");
}

void latex_sub_section(name)
const char *name;
{
    put_string("\\subsection*{");
    latex_text(name);
    put_string("}\n");
}

void latex_break_line() { /* put_string("\\newline\n"); */ }
void latex_blank_line() { put_string("\n"); }

void latex_code_start() { put_string("\\begin{verbatim}\n"); verbatim = TRUE; }
void latex_code_end()	{ put_string("\\end{verbatim}\n"); verbatim = FALSE; }

void latex_code(text)
const char *text;
{
    put_string("\\verb`");
    put_string(text);
    put_string("`");
}

void latex_tag_list_start()	{ put_string("\\begin{description}\n"); }
void latex_tag_entry_start()	{ put_string("\\item["); }
void latex_tag_entry_end()	{ put_string("]\\hfill\\newline\n"); }
void latex_tag_entry_end_extra(text)
const char *text;
{
    put_string("(");
    latex_text(text);
    put_string(")");
	latex_tag_entry_end();
}
void latex_tag_list_end()	{ put_string("\\end{description}\n"); }
	
void latex_table_start(longestag)
const char *longestag;
{ put_string("\\begin{description}\n"); }

void latex_table_entry(name, description)
const char *name;
const char *description;
{
    put_string("\\item[");
    latex_text(name);
    put_string("]\n");
    if (description)
	output_comment(description);
    else
	latex_char('\n');
}

void latex_table_end()	{ put_string("\\end{description}\n"); }

void latex_list_entry(text)
const char *text;
{
    latex_text(text);
}
void latex_list_separator() { put_string(",\n"); }
void latex_list_end()	{ latex_char('\n'); }

void latex_include(filename)
const char *filename;
{
	put_string("\\include{");
	latex_text(filename);
	put_string("}\n");
}

void latex_file_end() { put_string("\\end{document}\n"); }

void latex_name(name)
const char *name;
{
    if (name) latex_text(name);
    else      latex_section("NAME");
}

void latex_terse_sep()
{
    latex_char(' ');
    latex_dash();
    latex_char(' ');
}

void latex_reference(text)
const char *text;
{
    latex_text(text);
    latex_char('(');
    latex_text(manual_section);
    latex_char(')');
}


struct Output latex_output =
{
    latex_comment,
    latex_header,
    latex_dash,
    latex_section,
    latex_sub_section,
    latex_break_line,
    latex_blank_line,
    latex_code_start,
    latex_code_end,
    latex_code,
    latex_tag_list_start,
    latex_tag_list_end,
    latex_tag_entry_start,
    latex_tag_entry_start,	/* entry_start_extra */
    latex_tag_entry_end,
    latex_tag_entry_end_extra,
    latex_table_start,
    latex_table_entry,
    latex_table_end,
    dummy,		/* latex_indent */
    dummy,		/* latex_list_start */
    latex_list_entry,
    latex_list_separator,
    latex_list_end,
    latex_include,
    latex_file_end,
    latex_text,
    latex_char,
    NULL,		/* latex_parse_option */
    dummy,		/* latex_print_option */
    latex_name,
    latex_terse_sep,
    latex_reference,
    latex_text
};

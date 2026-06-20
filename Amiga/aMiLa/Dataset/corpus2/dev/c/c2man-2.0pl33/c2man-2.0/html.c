/* $Id: html.c,v 2.0.1.1 1994/09/23 08:20:46 greyham Exp $
 * functions for html style output.
 */
#include "c2man.h"
#include "manpage.h"
#include "output.h"

static int html_in_code = 0;

void html_char(c)
const int c;
{
  switch (c)
  {
  case '<':
    put_string("&lt;");
    break;
  case '>':
    put_string("&gt;");
    break;
  case '&':
    put_string("&amp;");
    break;
  case '"':
    put_string("&quot;");
    break;
  default:
    putchar(c);
    break;
  }
}

void html_text(text)
const char *text;
{
  while(*text)
  {
    html_char(*text++);
  }
}


void html_comment()
{
  put_string("<!");
}

void html_header(firstpage, input_files, grouped, name, section)
   ManualPage         *firstpage;
   int                 input_files;
   boolean             grouped;
   const char         *name;
   const char         *section;
{

  output_warning();
  put_string("<header>\n");
  put_string("<title>");
  html_text(name);
  printf("%s\n",firstpage->description);
  put_string("</title>\n");
  put_string("</header>\n");
  put_string("<body>\n");
}

void html_file_end()
{
  put_string("\n</body>\n");
}

void html_dash()
{
  put_string("-");
}

void html_section(name)
const char         *name;
{
  put_string("<h1>");
  html_text(name);
  put_string("</h1>\n");
}

void html_sub_section(name)
const char *name;
{
  put_string("<h2>");
  html_text(name);
  put_string("</h2>");
}

void html_break_line()
{
  if (!html_in_code)
  {
    put_string("<br>\n");
  }
}

void html_blank_line()
{
  if (!html_in_code)
  {
    put_string("<p>\n");
  }
  else
  {
    putchar('\n');
  }
}

void html_code_start()
{
  put_string("<pre>");
  html_in_code = 1;
}

void html_code_end()
{
  put_string("</pre>\n");
  html_in_code = 0;
}

void html_code(text)
const char *text;
{
  html_code_start();
  html_text(text);
  html_code_end();
}

void html_tag_list_start()
{
  put_string("<dl>");
}

void html_tag_list_end()
{
  put_string("</dl>\n");
}

void html_tag_entry_start()
{   
  put_string("<dt>\n");
}   
    
void html_tag_entry_start_extra()
{   
  put_string("<dt>\n");
}   
    
void html_tag_entry_end()
{
  put_string("<dd>\n");
}

void html_tag_entry_end_extra(text)
const char *text;
{
  put_string(" <em>");
  put_string(text);
  put_string("</em>)");
  put_string("<dd>\n");
}

void html_table_start(longestag)
const char *longestag;
{
  put_string("<ul>");
}

void html_table_entry(name, description)
const char         *name;
const char         *description;
{
  put_string("<li>");
}

void html_table_end()
{
  put_string("</ul>");
}

void html_indent()
{
  put_string("\t");
}

void html_list_start()
{
  put_string("<ul>");
}


void html_list_end()
{
  put_string("</ul>");
}

void html_list_entry(name)
const char *name;
{
  put_string("<li>");
  put_string(name);
  put_string("\n");
}

void html_list_separator()
{
  put_string(",\n");
}

void html_include(filename)
const char *filename;
{
  printf(".so %s\n", filename);
}

void html_name(name)
const char *name;
{
  if (name)
    html_text(name);
  else
    html_section("NAME");
}

void html_terse_sep()
{
  html_char(' ');
  html_dash();
  html_char(' ');
}

void html_reference(name)
const char *name;
{
  put_string("<a href=");
  put_string(name);
  put_string(".html>");
  put_string(name);
  put_string("</a>\n");
}  

void html_emphasized(text)
const char *text;
{
  put_string("<em>");
  put_string(text);
  put_string("</em>");
}

struct Output       html_output =
{
  html_comment,
  html_header,
  html_dash,
  html_section,
  html_sub_section,
  html_break_line,
  html_blank_line,
  html_code_start,
  html_code_end,
  html_code,
  html_tag_list_start,
  html_tag_list_end,
  html_tag_entry_start,
  html_tag_entry_start_extra,
  html_tag_entry_end,
  html_tag_entry_end_extra,
  html_table_start,
  html_table_entry,
  html_table_end,
  html_indent,
  html_list_start,
  html_list_entry,
  html_list_separator,
  html_list_end,
  html_include,
  html_file_end,
  html_text,
  html_char,
  NULL,				/* html_parse_option */
  dummy,			/* html_print_options */
  html_name,
  html_terse_sep,
  html_reference,      
  html_emphasized
  };

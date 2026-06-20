#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* texinfo2man.
 * Convert a texinfo document to man format.
 * Author: Carlo Wood <carlo@alinoe.com>.
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation, advertising
 * materials, and other materials related to such distribution and use
 * acknowledge that the software was developed by Carlo Wood.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES
 * OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 * HISTORY
 * 2002 Jan 17 Carlo Wood. Fixed handling of @@ within an @email{}.
 */
   
int at_start_of_line = 1;
int at_start_of_line_for_dot = 1;
int to_upper = 0;
int ignore = 0;
int disabled = 0;
int in_section = 0;
int in_item = 0;
int in_table = 0;
int no_break = 0;
int indentation = 0;

int bold = 0;
int underlined = 0;

char *texinfoname;

static char * where(
   int line_no)
{
   static char b[256];

   sprintf (b, "%s line %-3d", texinfoname, line_no);
   return b;
}

static void start_bold(void)
{
   if (!bold && !underlined)
   {
      if (at_start_of_line)
      {
         printf (".B ");
         at_start_of_line_for_dot = 0;
      }
      else
      {
         printf ("\\fB");
         at_start_of_line_for_dot = at_start_of_line;
      }
      at_start_of_line = 0;
   }
   ++bold;
}

static void stop_bold(void)
{
   if (--bold == 0 && !underlined)
   {
      printf ("\\fR");
      at_start_of_line_for_dot = at_start_of_line;
      at_start_of_line = 0;
   }
}

static void start_I(void)
{
   if (!underlined)
   {
      if (at_start_of_line)
      {
         printf (".I ");
         at_start_of_line_for_dot = 0;
      }
      else
      {
         printf ("\\fI");
         at_start_of_line_for_dot = at_start_of_line;
      }
      at_start_of_line = 0;
   }
   ++underlined;
}

static void stop_I(void)
{
   if (--underlined == 0)
   {
      if (bold)
      {
         if (at_start_of_line)
         {
            printf (".B ");
            at_start_of_line_for_dot = 0;
         }
         else
         {
            printf ("\\fB");
            at_start_of_line_for_dot = at_start_of_line;
         }
      }
      else
      {
         printf ("\\fR");
         at_start_of_line_for_dot = at_start_of_line;
      }
   }
   at_start_of_line = 0;
}

static void putone(
   char c)
{
   if (disabled || (in_item && c == ' '))
   {
      return;
   }
   if (at_start_of_line_for_dot && c == '.')
   {
      if (!at_start_of_line)
      {
         printf (" .");
      }
      else if (underlined)
      {
         printf (".I .\fI");
      }
      else if (bold)
      {
         printf (".B .\fB");
      }
      else
      {
         printf (" .");
      }
      return;
   }

   if (c == '\'')
   {
      printf("\\(cq");
      return;
   }

   if (c == '`')
   {
      printf("\\(oq");
      return;
   }

   if (no_break && (c == '\n'))
   {
      c = ' ';
   }

   if (no_break && (c == ' '))
   {
      putchar ('\\');
   }

   if (to_upper)
   {
      c = toupper (c);
   }

   if (c == '\\')
   {
      putchar ('\\');
   }

   putchar (c);
   at_start_of_line = at_start_of_line_for_dot = (c == '\n');
}

/* Replacement stack */
int         nr = 0;
char      * vars[256] = {NULL};
char      * replacement[256] = {NULL};
int         start_line[256] = {0};

static char value_updated[64] = "";
static char value_edition[64] = "";
static char value_version[64] = "";

static void process_texi(
   FILE * in)
{
   char buf[1024];
   int in_block = 0;
   int line_no = 0;

   while (fgets (buf, sizeof (buf), in))
   {
      ++line_no;
      if (strncmp (buf, "@include ", 9) == 0)
      {
         FILE *in2;
         char *p = strchr (buf, '\n');

         if (!p) continue;
         *p = 0;

         in2 = fopen (buf + 9, "r");
         *p = '\n';
         if (in2)
         {
            process_texi (in2);
            fclose (in2);
         }
      }
      else if (strncmp (buf, "@set ", 5) == 0)
      {
         char *p = strchr(buf, '\n');
         if (!p) continue;
         *p = 0;

         if (!strncmp(buf + 5, "UPDATED ", 8)) {
             memset(value_updated, 0, sizeof(value_updated));
             strncpy(value_updated, buf + 13, sizeof(value_updated) - 1);
         }

         if (!strncmp(buf + 5, "EDITION ", 8)) {
             memset(value_updated, 0, sizeof(value_updated));
             strncpy(value_edition, buf + 13, sizeof(value_edition) - 1);
         }

         if (!strncmp(buf + 5, "VERSION ", 8)) {
             memset(value_updated, 0, sizeof(value_updated));
             strncpy(value_version, buf + 13, sizeof(value_version) - 1);
         }

         *p = '\n';
      }
      if (strncmp (buf, "@c !BEGIN ", 10) == 0)
      {
         char *p = buf + 10;
         size_t len = strlen (p);

         if (nr == 256) exit (-1);
         vars[nr] = malloc (len + 1);
         replacement[nr] = malloc (131072);
         start_line[nr] = line_no + 1;
         strcpy (vars[nr], p);
         p = strchr(vars[nr], '\n');
         if (p) *p = 0;
         p = strchr(vars[nr], ' ' );
         if (p) *p = 0;
         in_block = 1;
      }
      else if (strncmp (buf, "@c !END", 7) == 0)
      {
         size_t len = strlen (replacement[nr]);

         if (replacement[nr][len - 1] == '\n')
         {
            replacement[nr][len - 1] = 0;
            --len;
         }
         in_block = 0;
         replacement[nr] = realloc (replacement[nr], len + 1);
         ++nr;
      }
      else if (in_block)
      {
         if (in_block == 1)
         {
            strcpy (replacement[nr], buf);
            in_block = 2;
         }
         else
         strcat (replacement[nr], buf);
      }
   }
}

int main(int argc, char *argv[])
{
   FILE *in;
   char buf[1024];
   int line_no = 0;

   texinfoname = argv[2];

   in = fopen (argv[2], "r");
   process_texi (in);
   fclose (in);

   in = fopen (argv[1], "r");

   while (fgets (buf, sizeof (buf), in))
   {
      char *p;

      for (p = buf; *p; ++p)
      {
         if (*p != '@')
         {
            putchar (*p);
         }
         else
         {
            int i;

            for (i = 0; i < nr; ++i)
            {
               size_t len = strlen (vars[i]);

               if (strncmp (p + 1, vars[i], len) == 0 && p[len + 1] == '@')
               {
                  int stack[16];
                  int *what = stack;
                  int at_start_of_input_line = 1;
                  char *q;

                  *what = 0;
                  p += strlen (vars[i]) + 1;
                  line_no = start_line[i];

                  for (q = replacement[i]; q && *q; ++q)
                  {
                     if (*q != '@')
                     {
                        int was_at_start_of_input_line = at_start_of_input_line;

                        at_start_of_input_line = (*q == '\n');
                        if (at_start_of_input_line) ++line_no;
                        if (ignore)
                        {
                           continue;
                        }

                        if (in_section && *q == '\n')
                        {
                           in_section = 0;
                           to_upper = 0;
                           putone ('"');
                        }

                        if (in_item && *q == '\n')
                        {
                           in_item = 0;
                           stop_bold ();
                        }

                        if (in_table && *q == '\n')
                        {
                           continue;
                        }

                        if (*what && *q == '}')
                        {
                           switch (*what--)
                           {
                           case 6:
                              to_upper = 0;
                              --no_break;
                             /* fall through */
                           case 1:
                              if (!in_section)
                              stop_bold ();
                              break;
                           case 2:
                              putone ('"');
                              break;
                           case 3:
                              stop_I ();
                              break;
                           case 4:
                              putone (']');
                              break;
                           case 5:	/* Emphasis */
                             /* putone('*'); */
                              stop_I ();
                              break;
                           case 7:
                              putone ('\'');
                              break;
                           case 8:
                              --no_break;
                              break;
                           case 9:
                              break;
                           }
                        }
                        else
                        {
                           if (in_table && was_at_start_of_input_line && !in_item)
                           {
                              putone ('\n');	/* Kludge :/ */
                           }
                           putone (*q);
                        }
                     }
                     else
                     {
                        if (at_start_of_input_line)
                        {
                           if (!strncmp (q, "@end ignore", 11) || !strncmp (q, "@end menu", 9)
                               || !strncmp (q, "@end iftex", 10) || !strncmp (q, "@end tex", 8)
                               || !strncmp (q, "@end direntry", 13))
                           {
                              --ignore;
                              q = strchr(q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@ignore\n", 8) || !strncmp (q, "@menu\n", 6)
                                    || !strncmp (q, "@iftex\n", 7) || !strncmp (q, "@tex\n", 5)
                                    || !strncmp (q, "@direntry\n", 10))
                           {
                              ++ignore;
                              q = strchr(q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (ignore)
                           {
                              continue;
                           }
                           else if (!strncmp (q, "@author ", 8))
                           {
                              printf (".br\n");
                              q += 7;
                              continue;
                           }
                           else if (!strncmp (q, "@example\n", 9) || !strncmp (q, "@smallexample\n", 14))
                           {
                              if (!at_start_of_line)
                              {
                                 putchar ('\n');
                              }
                              printf (".in +5\n");
                              indentation += 5;
                              printf (".nf\n.na\n");
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@end example", 12) || !strncmp (q, "@end smallexample", 17))
                           {
                              if (!at_start_of_line)
                              {
                                 putchar ('\n');
                              }

                              printf (".in -5\n");
                              indentation -= 5;
                              printf (".ad\n.fi\n");
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@noindent", 9))
                           {
                              if (indentation)
                              {
                                 if (!at_start_of_line)
                                 {
                                    putchar ('\n');
                                 }

                                 printf (".in -%d\n", indentation);
                                 at_start_of_line = at_start_of_line_for_dot = 1;
                                 indentation = 0;
                              }
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@display\n", 9))
                           {
                              if (!at_start_of_line)
                              {
                                 putchar ('\n');
                              }
                              printf (".nf\n.na\n");
                              q += 8;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@end display", 12))
                           {
                              if (!at_start_of_line)
                              putchar ('\n');
                              printf (".ad\n.fi\n");
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@section ", 9) || !strncmp (q, "@appendix ", 10)
                                    || !strncmp (q, "@subsection ", 12) || !strncmp (q, "@subheading ", 12))
                           {
                              if (!at_start_of_line)
                              {
                                 putchar ('\n');
                              }

                              printf (".SH \"");
                              at_start_of_line = at_start_of_line_for_dot = 0;
                              in_section = 1;
                              to_upper = 1;
                              if (q[2] == 'e')
                              {
                                 q += 8;
                              }
                              else if (q[2] == 'p')
                              {
                                 q += 9;
                              }
                              else
                              {
                                 q += 11;
                                 to_upper = 0;
                              }
                              continue;
                           }
                           else if (!strncmp (q, "@table", 6))
                           {
                              in_table = 1;
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@end table", 10))
                           {
                              disabled = 0;
                              in_table = 0;
                              q = strchr (q, '\n');
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                           else if (!strncmp (q, "@item ", 6) || !strncmp (q, "@itemx ", 7))
                           {
                              disabled = 0;
                              if (in_table && q[5] == ' ')
                              {
                                 if (!at_start_of_line)
                                 {
                                    putchar ('\n');
                                 }
                                 if (in_table == 1)
                                 {
                                    in_table = 2;
                                    printf (".TP 4\n");
                                    at_start_of_line = at_start_of_line_for_dot = 1;
                                 }
                                 else
                                 {
                                    printf (".TP\n");
                                    at_start_of_line = at_start_of_line_for_dot = 1;
                                 }
                              }
                              if (in_table && q[5] == 'x')
                              {
                                 printf (", ");
                                 at_start_of_line = at_start_of_line_for_dot = 0;
                              }
                              in_item = 1;
                              q = strchr (q, ' ');
                              if (!q) break;
                              start_bold();
                              continue;
                           }
                        }
                        else if (ignore)
                        {
                           continue;
                        }
                        if (!strncmp (q, "@code{", 6) || !strncmp (q, "@env{", 5) || !strncmp (q, "@command{", 9))
                        {
                           if (!in_section)
                           {
                              start_bold ();
                           }
                           *++what = 1;
                           if (q[1] == 'e')
                           {
                              q += 4;
                           }
                           else if (q[3] == 'd')
                           {
                              q += 5;
                           }
                           else
                           {
                              q += 8;
                           }
                        }
                        else if (!strncmp (q, "@samp{", 6) || !strncmp (q, "@option{", 8)
                                 || !strncmp (q, "@file{", 6))
                        {
                           putone ('`');
                           *++what = 7;
                           if (q[1] == 'o')
                           {
                              q += 7;
                           }
                           else
                           {
                              q += 5;
                           }
                        }
                        else if (!strncmp (q, "@cite{", 6))
                        {
                           putone ('"');
                           *++what = 2;
                           q += 5;
                        }
                        else if (!strncmp (q, "@var{", 5) || !strncmp (q, "@dfn{", 5))
                        {
                           start_I ();
                           *++what = 3;
                           q += 4;
                        }
                        else if (!strncmp (q, "@copyright{}", 12))
                        {
                           printf ("(c)");
                           q += 11;
                        }
                        else if (!strncmp (q, "@value{UPDATED}", 15))
                        {
                           printf ("%s", value_updated);
                           q += 14;
                        }
                        else if (!strncmp (q, "@value{VERSION}", 15))
                        {
                           printf ("%s", value_version);
                           q += 14;
                        }
                        else if (!strncmp (q, "@value{EDITION}", 15))
                        {
                           printf ("%s", value_edition);
                           q += 14;
                        }
                        else if (!strncmp (q, "@refill", 7))
                        {
                           q += 6;
                        }
                        else if (!strncmp (q, "@footnote{", 10))
                        {
                           if (!at_start_of_line)
                           {
                              putone (' ');
                           }
                           putone ('[');
                           *++what = 4;
                           q += 9;
                        }
                        else if (!strncmp (q, "@emph{", 6))
                        {
                          /* putone('*'); */
                           start_I ();
                           *++what = 5;
                           q += 5;
                        }
                        else if (!strncmp (q, "@xref{", 6) || !strncmp (q, "@pxref{", 7))
                        {
                           if (!disabled)
                           {
                              printf ("See ");
                              at_start_of_line = at_start_of_line_for_dot = 0;
                              start_bold ();
                              to_upper = 1;
                              ++no_break;
                              *++what = 6;
                           }
                           if (q[1] == 'p')
                           {
                              q += 6;
                           }
                           else
                           {
                              q += 5;
                           }
                        }
                        else if (!strncmp (q, "@w{", 3))
                        {
                           ++no_break;
                           *++what = 8;
                           q += 2;
                        }
                        else if (!strncmp (q, "@email{", 7))
                        {
                           *++what = 9;
                           q += 6;
                        }
                        else if (!strncmp (q, "@{", 2))
                        {
                           putone ('{');
                           ++q;
                        }
                        else if (!strncmp (q, "@}", 2))
                        {
                           putone ('}');
                           ++q;
                        }
                        else if (!strncmp (q, "@*", 2))
                        {
                           if (!at_start_of_line_for_dot)
                           {
                              putchar ('\n');
                           }
                           printf (".br\n");
                           at_start_of_line = at_start_of_line_for_dot = 1;
                           ++q;
                        }
                        else if (!strncmp (q, "@@", 2))
                        {
                           putone ('@');
                           ++q;
                        }
                        else
                        {
                           char *s = strchr (q, ' ');
                           char *a = strchr (q, '{');

                           if (!s || !a || s < a)
                           {
                              char *q2 = strchr (q, '\n');

                              if (strncmp (q, "@ifinfo", 7) && strncmp (q, "@end ifinfo", 11)
                                  && strncmp (q, "@cindex", 7) && strncmp (q, "@kindex", 7)
                                  && strncmp (q, "@refill", 7) && strncmp (q, "@include", 8)
                                  && strncmp (q, "@set", 4) && strncmp (q, "@group", 6)
                                  && strncmp (q, "@end group", 10) && strncmp (q, "@node", 5)
                                  && strncmp (q, "@comment", 8) && strncmp (q, "@c\n", 3)
                                  && strncmp (q, "@c ", 3) && strncmp (q, "@need", 5)
                                  && strncmp (q, "@dircategory", 12))
                              {
                                 if (a)
                                 {
                                    *a = 0;
                                 }

                                 if (q2)
                                 {
                                    *q2 = 0;
                                 }
                                 fprintf (stderr, "%s: Unknown texinfo command %s\n", where (line_no), q);
                                 if (a)
                                 {
                                    *a = '{';
                                 }
                              }
                              q = q2;
                              if (!q) break;
                              ++line_no;
                              continue;
                           }
                        }
                     }
                  }
                  break;
               }
            }
            if (i == nr)
            {
               putone ('@');
            }
         }
      }
   }
   return 0;
}

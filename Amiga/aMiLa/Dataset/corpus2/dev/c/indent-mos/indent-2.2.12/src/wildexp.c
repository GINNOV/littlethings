/** \file
 * Wildcard expansion for WIN32 version
 *
 * Copyright (c) 2000 John Bridges.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * - 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * - 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.<br>
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Please send bug reports about this file to indent@peekpoke.com
 */

#if defined (_WIN32) && !defined (__CYGWIN__)
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <direct.h>
#include <malloc.h>
#include <ctype.h>

#include "sys.h"
#include "code_io.h"
#include "indent.h"

#define MAX_PATH 1024

struct arginfo
{
   int nargc;
   int argpos;
   char *argbuf;
   int bufsize;
};

/**
 *
 */

static void myabort (
   char *str)
{
   puts ("");
   puts (str);
   exit (1);
}

static void fparms (struct arginfo *arg, char *fname);
static void chkparm (struct arginfo *arg, char *str);

/**
 *
 */

static void addarg (
   struct arginfo *arg, 
   char *str)
{
   int cnt;

   if (*str == '@')
   {
      fparms (arg, str + 1);
   }
   else
   {
      cnt = strlen (str) + 1;
      if (arg->argpos + cnt >= arg->bufsize)
      {
         arg->bufsize += 8192;
         arg->argbuf = realloc (arg->argbuf, arg->bufsize);
      }
      strcpy (arg->argbuf + arg->argpos, str);
      arg->argpos += cnt;
      ++arg->nargc;
   }
}

/**
 *
 */

static void fparms (
   struct arginfo *arg, 
   char *fname)
{
   char         * buf    = NULL;
   char         * cp     = NULL;
   char         * ecp    = NULL;
   unsigned int   cnt;
   short          quoted = 0;
   FILE         * fs     = fopen (fname, "rb");
  
   if (!fs)
   {
      myabort (_("CANNOT FIND '@' FILE!"));
   }

   fseek (fs, 0l, 2);
   cnt = ftell (fs);
   fseek (fs, 0l, 0);
   buf = malloc (cnt + 1);
   fread (buf, 1, cnt, fs);
   fclose (fs);
   *(ecp = buf + cnt) = 0;
   cp = buf;

   while (cp < ecp)
   {
      if (*cp == ';')
      {
         while (cp < ecp && *cp != '\r' && *cp != '\n')
         {
            *cp++ = 0;
         }
      }
      if (*cp < ' ')
      {
         *cp = 0;
      }

      if (*cp == '"')
      {
         *cp = 0;
         quoted = !quoted;
      }

      if (!quoted)
      {
         if (*cp == ' ')
         {
	    *cp = 0;		/* set spaces to null */
         }

         if (*cp >= 'A' && *cp <= 'Z')
         {
	    *cp += 32;
         }
      }

      ++cp;
   }

   cp = buf;
   while (cp < ecp)
   {
      if (*cp)
      {
         chkparm (arg, cp);
         cp += strlen (cp);
      }

      ++cp;
   }
   
   free (buf);
}

/**
 *
 */

static int wildmatch(
   const char *s1, 
   const char *s2)
{
   if (s1 == NULL)
   {
      s1 = "";
   }

   if (s2 == NULL)
   {
      s2 = "";
   }

   while (*s1 && (*s2 || *s1 == '*'))
   {
      if (tolower (*s1) != tolower (*s2) && *s1 != '?' && *s1 != '*')
      {
         return 0;
      }

      if (*s2)
      {
         if (*s1 == '*')
         {
            ++s1;

            if (!*s1)
            {
               return 1;
            }

            while (*s2)
            {
               if (wildmatch (s1, s2))
               {
                  return 1;
               }

               ++s2;
            }

            return 0;
         }
         ++s2;
      }

      ++s1;
   }

   if (*s1 || *s2)
   {
      return 0;
   }
   else
   {
      return 1;
   }
}

/**
 *
 */

static short removearg (
   struct arginfo *arg, 
   char *str)
{
   char *cp    = NULL;
   int i;
   int cnt;

   i = arg->nargc;
   cp = arg->argbuf;

   while (i-- > 0)
   {
      cnt = strlen (cp) + 1;

      if (wildmatch (str, cp))
      {
         arg->argpos -= cnt;
         memcpy (cp, cp + cnt, arg->argpos - (cp - arg->argbuf));
         --arg->nargc;
      }
      else
      {
         cp += cnt;
      }
   }
   
   return 0;
}

/**
 *
 */

static void chkparm (
   struct arginfo *arg, 
   char *str)
{
   char                 tmpstr[MAX_PATH + 1];
   char               * cp     = NULL;
   char               * pnt2   = NULL;
   short                remarg = 0;
   long                 hFile;
   struct _finddata_t   c_file;
   
   if (*str == '!')
   {
      remarg = 1;
      ++str;
   }
  
   if (strchr (str, '?') || strchr (str, '*'))
   {
      if (remarg)
      {
         removearg (arg, str);
      }
      else
      {
         strcpy (tmpstr, str);
         if (!(cp = strrchr (tmpstr, '\\')))
         {
            if (!(cp = strrchr (tmpstr, '/')))
            {
               if (!(cp = strrchr (tmpstr, ':')))
               {
                  cp = tmpstr - 1;
               }
            }
         }
         
         pnt2 = cp + 1;
         hFile = _findfirst (str, &c_file);

         while (hFile > 0)
         {
            if (!(c_file.attrib & _A_SUBDIR))
            {
               cp = pnt2;
               strcpy (pnt2, c_file.name);

               while (*cp)
               {
                  if (islower (*cp))
                  {
                     strcpy (pnt2, c_file.name);
                     break;
                  }

                  *cp = tolower (*cp);
                  ++cp;
               }

               addarg (arg, tmpstr);
            }

            if (_findnext (hFile, &c_file))
            {
               _findclose (hFile);
               hFile = 0;
            }
         }
      }
   }
   else
   {
      if (remarg)
      {
         removearg (arg, str);
      }
      else
      {
         addarg (arg, str);
      }
   }
}

/**
 *
 */

extern void wildexp (
   int *argc, 
   char ***argv)
{
   char           * cp = NULL;
   char          ** pnt;
   char          ** nargv;
   struct arginfo   arg;
   int              i;

   arg.bufsize = 8192;
   arg.argpos  = 0;
   arg.argbuf  = malloc (arg.bufsize);
   arg.nargc   = 0;
  
   i = *argc;
   pnt = *argv;

   while (i--)
   {
      chkparm (&arg, *pnt++);
   }

   arg.argbuf = realloc (arg.argbuf, arg.argpos);
   cp = arg.argbuf;
   i = *argc = arg.nargc;
  
   if (arg.nargc < 32)
   {
      arg.nargc = 32;
   }
  
   *argv = nargv = malloc (arg.nargc * sizeof (nargv[0]));

   while (i--)
   {
      *nargv++ = cp;
      cp += strlen (cp) + 1;
   }
}

#endif /* defined (_WIN32) && !defined (__CYGWIN__) */

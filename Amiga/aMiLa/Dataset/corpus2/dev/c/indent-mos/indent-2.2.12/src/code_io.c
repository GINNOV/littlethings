/** \file
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1994 Joseph Arceneaux.  All rights reserved.<br>
 * Copyright (c) 1992 Free Software Foundation, Inc.  All rights reserved.<br>
 *
 * Copyright (c) 1985 Sun Microsystems, Inc. <br
 * Copyright (c) 1980 The Regents of the University of California.<br
 * Copyright (c) 1976 Board of Trustees of
 * the University of Illinois. All rights reserved.<br>
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
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * HISTORY
 * - 2002-01-17 D.Ingamells Add a final newline if not present in file.
 */

#include "sys.h"

#include <ctype.h>
#include <stdlib.h>
#if defined (HAVE_UNISTD_H)
   #include <unistd.h>
#endif
#include <string.h>
#include <errno.h>
#include <limits.h>

#include <sys/types.h>
#include <sys/stat.h>
/* POSIX says that <fcntl.h> should exist.  Some systems might need to use
* <sys/fcntl.h> or <sys/file.h> instead.  */
#include <fcntl.h>
#if defined (_WIN32) && !defined (__CYGWIN__)
  #include <io.h>
#endif

#include "indent.h"
#include "code_io.h"
#include "globs.h"
#include "output.h"

RCSTAG_CC ("$Id$");

/**
 * Stuff that needs to be shared with the rest of indent. Documented in
 * indent.h.
 */

char          * in_prog_pos    = NULL;  /*!< used in output.c        code_io.c indent.c */
char          * buf_ptr        = NULL;  /*!< used in output.c lexi.c code_io.c indent.c comments.c */
char          * buf_end        = NULL;  /*!< used in output.c lexi.c code_io.c indent.c comments.c */
BOOLEAN         had_eof        = false; /*!< used in output.c        code_io.c          comments.c parse.c */
char          * cur_line       = NULL;  /*!< used in output.c        code_io.c */

/**
 *
 */

extern char * skip_horiz_space(
   const char * p)
{
    while ((*p == ' ') || (*p == TAB))
    {
        p++;
    }

    return (char *)p;
}

/******************************************************************************/

extern void skip_buffered_space(void)
{
    while ((*buf_ptr == ' ') ||
           (*buf_ptr == TAB))
    {
        buf_ptr++;
        
        if (buf_ptr >= buf_end)
        {
            fill_buffer();
        }
    }
}

/**
 *
 */

static BOOLEAN is_comment_start(const char * p)
{
    BOOLEAN ret;
    
    if ((*p == '/') && ((*(p + 1) == '*') ||
                        (*(p + 1) == '/')))
    {
        ret = true;
    }
    else
    {
        ret = false;
    }
    
    return ret;
}

/**
 * Return the column we are at in the input line.
 */

extern int current_column (void)
{
    char *p;
    int column;

    /* Use save_com.size here instead of save_com.end, because save_com is
     * already emptied at this point. */
  
    if ((buf_ptr >= save_com.ptr) && (buf_ptr <= save_com.ptr + save_com.len))
    {
        p = save_com.ptr;
        column = save_com.start_column;
    }
    else
    {
        p = cur_line;
        column = 1;
    }

    while (p < buf_ptr)
    {
        switch (*p)
        {
            case EOL:
            case 014:           /* form feed */
                column = 1;
                break;

            case TAB:
                column += settings.tabsize - (column - 1) % settings.tabsize;
                break;

            case '\b':          /* backspace */
                column--;
                break;

            default:
                column++;
                break;
        }

        p++;
    }

    return column;
}

/**
 * Read file FILENAME into a `fileptr' structure, and return a pointer to
 * that structure. 
 */

extern file_buffer_ty * read_file(
    char        * filename,
    struct stat * file_stats)
{
    static file_buffer_ty fileptr = {NULL, 0, NULL};
    
#if defined(__MSDOS__)
    /*
     * size is required to be unsigned for MSDOS,
     * in order to read files larger than 32767
     * bytes in a 16-bit world...
     */
  
    unsigned int size = 0, size_to_read = 0;
#else
    ssize_t size = 0;
    size_t size_to_read = 0;
#endif

    unsigned int namelen = strlen(filename);
    int          fd      = open(filename, O_RDONLY, 0777);

    if (fd < 0)
    {
        fatal (_("Can't open input file %s"), filename);
    }

    if (fstat(fd, file_stats) < 0)
    {
        fatal (_("Can't stat input file %s"), filename);
    }

    if (file_stats->st_size == 0)
    {
        ERROR (_("Zero-length file %s"), filename, 0);
    }

#if !defined(__DJGPP__)
    if (sizeof (int) == 2)      /* Old MSDOS */
    {
        if ((file_stats->st_size < 0) || (file_stats->st_size > (0xffff - 1)))
        {
            fatal(_("File %s is too big to read"), filename);
        }
    }
    else
#endif
    {
        if (file_stats->st_size < 0)
        {
            fatal(_("System problem reading file %s"), filename);
        }
    }

    if ((size_t)file_stats->st_size >= SSIZE_MAX)
    {
        fatal(_("File %s is too big to read"), filename);
    }
    fileptr.size = file_stats->st_size;
    
    if (fileptr.data != 0)
    {
        fileptr.data = xrealloc(fileptr.data,
                                 (unsigned)file_stats->st_size + 2); /* add 1 for '\0' and 1 for
                                                                                * potential final added
                                                                                * newline. */
    }
    else
    {
        fileptr.data = xmalloc((unsigned)file_stats->st_size + 2); /* add 1 for '\0' and 1 for
                                                                               * potential final added
                                                                               * newline. */
    }

    size_to_read = fileptr.size;
    while (size_to_read > 0) {
        size = read (fd, fileptr.data + fileptr.size - size_to_read,
                size_to_read);
        
        if (size ==
#if defined(__MSDOS__)
                (unsigned int)
#endif
                -1)
        {
#if !defined(__MSDOS__)
            if (errno == EINTR)
            {
                continue;
            }
#endif
            xfree(fileptr.data);
            fatal (_("Error reading input file %s"), filename);
        }
        size_to_read -= size;
    }
    
    if (close(fd) < 0)
    {
        xfree(fileptr.data);
        fatal (_("Error closing input file %s"), filename);
    }
    

    /* Apparently, the DOS stores files using CR-LF for newlines, but
     * then the DOS `read' changes them into '\n'.  Thus, the size of the
     * file on disc is larger than what is read into memory.  Thanks, Bill. */
    
    if ((size_t)size < fileptr.size)
    {
        fileptr.size = size;
    }

    if (fileptr.name != NULL)
    {
        fileptr.name = xrealloc(fileptr.name, (unsigned)namelen + 1);
    }
    else
    {
        fileptr.name = xmalloc(namelen + 1);
    }
    
    memcpy(fileptr.name, filename, namelen);
    fileptr.name[namelen] = EOS;

    if ((fileptr.size>0) && (fileptr.data[fileptr.size - 1] != EOL))
    {
        fileptr.data[fileptr.size] = EOL;
        fileptr.size++;
    }

    fileptr.data[fileptr.size] = EOS;

    return &fileptr;
}

/**
 * This should come from stdio.h and be some system-optimal number 
 */
#ifndef BUFSIZ
#define BUFSIZ 1024
#endif

/**
 * Suck the standard input into a file_buffer structure, and
 *  return a pointer to that structure.
 */

file_buffer_ty * read_stdin(void)
{
    static file_buffer_ty stdinptr = {NULL, 0, NULL};

    unsigned int          size = 15 * BUFSIZ;
    int                   ch = EOF;
    char                * p = NULL;

    if (stdinptr.data != 0)
    {
        free (stdinptr.data);
    }

    stdinptr.data = xmalloc(size + 1);
    stdinptr.size = 0;
    
    p = stdinptr.data;
    
    do
    {
        while (stdinptr.size < size)
        {
            ch = getc (stdin);
            
            if (ch == EOF)
            {
                break;
            }

            *p++ = ch;
            stdinptr.size++;
        }

        if (ch != EOF)
        {
            size += (2 * BUFSIZ);
            stdinptr.data = xrealloc (stdinptr.data, (unsigned) size);
            p = stdinptr.data + stdinptr.size;
        }
    } while (ch != EOF);

    stdinptr.name = "Standard Input";
    stdinptr.data[stdinptr.size] = EOS;

    return &stdinptr;
}

/*
 * Advance `buf_ptr' so that it points to the next line of input.
 *
 * If the next input line contains an indent control comment turning
 * off formatting (a comment, C or C++, beginning with *INDENT-OFF*),
 * disable indenting by calling inhibit_indenting() which will cause
 * `dump_line ()' to simply print out all input lines without formatting
 * until it finds a corresponding comment containing *INDENT-0N* which
 * re-enables formatting.
 *
 * Note that if this is a C comment we do not look for the closing
 * delimiter.  Note also that older versions of this program also
 * skipped lines containing *INDENT** which represented errors
 * generated by indent in some previous formatting.  This version does
 * not recognize such lines. 
 */

void fill_buffer(void)
{
    char    * p = NULL;
    BOOLEAN   finished_a_line = false;

    /* indent() may be saving the text between "if (...)" and the following
     * statement.  To do so, it uses another buffer (`save_com').  Switch
     * back to the previous buffer here. */
    
    if (bp_save != 0)
    {
        buf_ptr = bp_save;
        buf_end = be_save;
        bp_save = be_save = 0;

        /* only return if there is really something in this buffer */
        
        if (buf_ptr < buf_end)
        {
            return;
        }
    }

    if (*in_prog_pos == EOS)
    {
        buf_ptr = in_prog_pos;
        cur_line = buf_ptr;
        had_eof = true;
    }
    else
    {
      /* Here if we know there are chars to read.  The file is
       * NULL-terminated, so we can always look one character ahead
       * safely. */
    
       cur_line = in_prog_pos;
       p = cur_line;
       finished_a_line = false;
    
       do
       {
          p = skip_horiz_space(p);

         /* If we are looking at the beginning of a comment, see
          * if it turns off formatting with off-on directives. */
        
          if (is_comment_start(p))
          {
             p += 2;
            
             p = skip_horiz_space(p);
            
            /* Skip all lines between the indent off and on directives. */
            
             if (strncmp (p, "*INDENT-OFF*", 12) == 0)
             {
                inhibit_indenting(true);
             }
          }

          while ((*p != EOS) && *p != EOL)
          {
             p++;
          }

         /* Here for newline -- finish up unless formatting is off */
        
          if (*p == EOL)
          {
             finished_a_line = true;
             in_prog_pos = p + 1;
          }
        
         /* Here for embedded NULLs */
        
          else if ((unsigned int) (p - current_input->data) < current_input->size)
          {
             fatal(_("File %s contains NULL-characters: cannot proceed\n"),
                   current_input->name);
          }
        
         /* Here for EOF with no terminating newline char. */
          else
          {
             in_prog_pos = p;
             finished_a_line = true;
          }
       } while (!finished_a_line);

       buf_ptr = cur_line;
       buf_end = in_prog_pos;
    }
}



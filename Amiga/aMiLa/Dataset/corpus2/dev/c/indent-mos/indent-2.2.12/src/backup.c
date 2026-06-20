/** \file
 * Copyright (c) 1993,1994, Joseph Arceneaux.  All rights reserved.
 * Copyright (c) 1994 Joseph Arceneaux.  All rights reserved.<br>
 * Copyright (c) 1992, 2002, 2008 Free Software Foundation, Inc. 
 *   All rights reserved.<br>
 *
 * Copyright (c) 1980, 1993
 *	 The Regents of the University of California.<br>
 * Copyright (c) 1976 Board of Trustees of the University of Illinois.<br>
 * Copyright (c) 1985 Sun Microsystems, Inc.
 *   All rights reserved.<br>
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
 */
/* GNU/Emacs style backups --
 * This behaviour is controlled by two environment variables,
 * VERSION_CONTROL and SIMPLE_BACKUP_SUFFIX.
 *
 * VERSION_CONTROL determines what kinds of backups are made.  If it's
 * value is "numbered", then the first modification of some file
 * "eraserhead.c" will yield a backup file "eraserhead.c.~1~", the
 * second modification will yield "eraserhead.c.~2~", and so on.  It
 * does not matter if the version numbers are not a sequence;  the next
 * version will be one greater than the highest in that directory.
 *
 * If the value of VERSION_CONTROL is "numbered_existing", then such
 * numbered backups will be made if there are already numbered backup
 * versions of the file.  Otherwise, the backup name will be that of
 * the original file with "~" (tilde) appended.  E.g., "eraserhead.c~".
 *
 * If the value of VERSION_CONTROL is "simple", then the backup name
 * will be that of the original file with "~" appended, regardless of
 * whether or not there exist numbered versions in the directory.
 *
 * For simple backups, the value of SIMPLE_BACKUP_SUFFIX will be used
 * rather than "~" if it is set.
 *
 * If VERSION_CONTROL is unset, "numbered_existing" is assumed.  For
 * Emacs lovers, "nil" is equivalent to "numbered_existing" and "t" is
 * equivalent to "numbered".
 *
 * Finally, if VERSION_CONTROL is "none" or "never", backups are not
 * made.  I suggest you avoid this behaviour.
 *
 * Added, october 1999 (by Chris F.A. Johnson):
 *
 * If VERSION_WIDTH is set, then it controls zero padding of a numbered
 * suffix.
 *
 * Written by jla, based on code from djm (see `patch')
 */

#include "sys.h"

#include <ctype.h>
#include <stdlib.h>

#ifdef HAVE_UNISTD_H
   #include <unistd.h>
#endif

#ifdef PRESERVE_MTIME

   #include <time.h>

   #ifdef HAVE_UTIME_H
      #include <utime.h>
   #elif defined(HAVE_SYS_UTIME_H)
      #include <sys/utime.h>
   #endif
#endif

#include <sys/stat.h>

#if defined (_WIN32) && !defined (__CYGWIN__)
   #include <io.h>
#else
   #include <fcntl.h>
#endif

#include <string.h>

#ifndef isascii
   #define ISDIGIT(c) (isdigit ((unsigned char) (c)))
#else
   #define ISDIGIT(c) (isascii (c) && isdigit (c))
#endif

#include <sys/types.h>

#ifdef HAVE_DIRENT_H
   #include <dirent.h>
   #define NAMLEN(dirent) strlen((dirent)->d_name)
#else
   #define dirent direct
   #define NAMLEN(dirent) (dirent)->d_namlen

   #ifdef HAVE_SYS_NDIR_H
      #include <sys/ndir.h>
   #endif

   #ifdef HAVE_SYS_DIR_H
      #include <sys/dir.h>
   #endif

   #ifdef HAVE_NDIR_H
      #include <ndir.h>
   #endif

   #if !defined(HAVE_SYS_NDIR_H) && !defined(HAVE_SYS_DIR_H) && !defined(HAVE_NDIR_H)
      #define NODIR 1
   #endif
#endif

#include "indent.h"
#include "globs.h"
#include "code_io.h"
#include "backup.h"

RCSTAG_CC ("$Id$");

#ifndef NODIR
   #if defined (_POSIX_VERSION) /* Might be defined in unistd.h.  */
      /* POSIX does not require that the d_ino field be present, and some
       * systems do not provide it. */
      #define REAL_DIR_ENTRY(dp) 1
   #else
      #define REAL_DIR_ENTRY(dp) ((dp)->d_ino != 0)
   #endif
#else /* NODIR */
   #define generate_backup_filename(v,f) simple_backup_name((f))
#endif /* NODIR */

#ifndef BACKUP_SUFFIX_STR
   #define BACKUP_SUFFIX_STR    "~"
#endif

#ifndef BACKUP_SUFFIX_CHAR
   #define BACKUP_SUFFIX_CHAR   '~'
#endif

#ifndef BACKUP_SUFFIX_FORMAT
   #define BACKUP_SUFFIX_FORMAT "%s.~%0*d~"
#endif

/**
 * Default backup file suffix to use
 */
static char   * simple_backup_suffix = BACKUP_SUFFIX_STR;

/* What kinds of backup files to make -- see
 * table `version_control_values' below. */

backup_mode_ty  version_control = unknown;
int             version_width = 1;

/**
 * Construct a simple backup name for PATHNAME by appending
 * the value of `simple_backup_suffix'.
 */

static char * simple_backup_name (
   char *pathname)
{
    char *backup_name;

    backup_name = xmalloc(strlen (pathname) + strlen (simple_backup_suffix) + 2);
    sprintf (backup_name, "%s%s", pathname, simple_backup_suffix);
    return backup_name;
}

#ifndef NODIR
/**
 * If DIRENTRY is a numbered backup version of file BASE, return
 * that number.  BASE_LENGTH is the string length of BASE.
 */

static int version_number(
    char * base,
    char * direntry,
    int    base_length)
{
    int    version;
    char * p = NULL;

    version = 0;

    if (!strncmp (base, direntry, base_length) && ISDIGIT (direntry[base_length + 2]))
    {
        for (p = &direntry[base_length + 2]; ISDIGIT (*p); ++p)
        {
            version = version * 10 + *p - '0';
        }

        if (p[0] != BACKUP_SUFFIX_CHAR || p[1])
        {
            version = 0;
        }
    }

    return version;
}


/**
 * Return the highest version of file FILENAME in directory
 * DIRNAME.  Return 0 if there are no numbered versions.
 */

static int highest_version (
     char * filename,
     char * dirname)
{
    DIR           * dirp = opendir (dirname);
    struct dirent * dp = NULL;
    int             highestVersion;

    if (!dirp)
    {
        highestVersion = 0;
    }
    else
    {
       int             this_version;
       unsigned int    file_name_length = strlen(filename);

       highestVersion = 0;

       while ((dp = readdir (dirp)) != 0)
       {
          if (!REAL_DIR_ENTRY (dp) || NAMLEN (dp) <= file_name_length + 2)
          {
             continue;
          }


          this_version = version_number (filename, dp->d_name, file_name_length);

          if (this_version > highestVersion)
          {
             highestVersion = this_version;
          }
       }

       closedir (dirp);
    }

    return highestVersion;
}


/**
 * Return the highest version number for file PATHNAME.  If there
 * are no backups, or only a simple backup, return 0.
 */

static int max_version (
    char * pathname)
{
    char * p;
    char * filename;
    int    pathlen = strlen (pathname);
    int    version;

    p = pathname + pathlen - 1;

    while ((p > pathname) && (*p != '/'))
    {
        p--;
    }

    if (*p == '/')
    {
        int dirlen = p - pathname;
        char *dirname;

        filename = p + 1;
        dirname = xmalloc(dirlen + 1);
        strncpy (dirname, pathname, (dirlen));
        dirname[dirlen] = '\0';
        version = highest_version (filename, dirname);
        xfree(dirname);
    }
    else
    {
       filename = pathname;
       version = highest_version (filename, ".");
    }

    return version;
}


/**
 * Generate a backup filename for PATHNAME, dependent on the
 * value of VERSION_CONTROL.
 */

static char * generate_backup_filename (
    backup_mode_ty   versionControl,
    char           * pathname)
{
    int last_numbered_version;
    char *backup_name;

    if (versionControl == none)
    {
        backup_name = NULL;
    }
    else
    {
       if (versionControl == simple)
       {
           backup_name = simple_backup_name (pathname);
       }
       else
       {
          last_numbered_version = max_version (pathname);

          if ((versionControl == numbered_existing) && (last_numbered_version == 0))
          {
             backup_name = simple_backup_name (pathname);
          }
          else
          {
             last_numbered_version++;
             backup_name = xmalloc(strlen (pathname) + 16);

             if (backup_name)
             {
                sprintf (backup_name, BACKUP_SUFFIX_FORMAT, pathname,
                         version_width, (int) last_numbered_version);
             }
          }
       }
    }

    return backup_name;
}

#endif /* !NODIR */

static version_control_values_ty values[] =
{
    {none,              "never"},    /*!< Don't make backups. */
    {none,              "none"},     /*!< Ditto */
    {simple,            "simple"},   /*!< Only simple backups */
    {numbered_existing, "existing"}, /*!< Numbered if they already exist */
    {numbered_existing, "nil"},      /*!< Ditto */
    {numbered,          "numbered"}, /*!< Numbered backups */
    {numbered,          "t"},        /*!< Ditto */
    {unknown,           0}           /*!< Initial, undefined value. */
};


/**
 * Determine the value of `version_control' by looking in the
 * environment variable "VERSION_CONTROL".  Defaults to
 * numbered_existing.
 */

backup_mode_ty version_control_value(void)
{
    char                      * version = getenv("VERSION_CONTROL");
    version_control_values_ty * v;
    backup_mode_ty              ret = unknown;

    if ((version == NULL) || (*version == 0))
    {
        ret = numbered_existing;
    }
    else
    {
        v = &values[0];

        while (v->name)
        {
            if (strcmp(version, v->name) == 0)
            {
                ret = v->value;
                break;
            }
            else
            {
                v++;
            }
        }
    }

    return ret;
}


/**
 * Initialize information used in determining backup filenames.
 */

static void set_version_width(void)
{
    char *v = getenv ("VERSION_WIDTH");

    if (v && ISDIGIT (*v))
    {
        version_width = atoi (v);
    }

    if (version_width > 16)
    {
        version_width = 16;
    }
}

/**
 *
 */

void initialize_backups(void)
{
    char *v = getenv ("SIMPLE_BACKUP_SUFFIX");

    if (v && *v)
    {
        simple_backup_suffix = v;
    }

#ifdef NODIR
    version_control = simple;
#else /* !NODIR */
    version_control = version_control_value ();

    if (version_control == unknown)
    {
        fprintf (stderr, _("indent:  Strange version-control value\n"));
        fprintf (stderr, _("indent:  Using numbered-existing\n"));
        version_control = numbered_existing;
    }
#endif /* !NODIR */

    set_version_width ();
}


/**
 * Make a backup copy of FILE, taking into account version-control.
 * See the description at the beginning of the file for details.
 */

void make_backup(
    file_buffer_ty     * file,
    const struct stat  * file_stats)
{
    FILE         * bf;
    char         * backup_filename;
    unsigned int   size;

    if (version_control == none)
    {
    }
    else
    {
       backup_filename = generate_backup_filename (version_control, file->name);

       if (!backup_filename)
       {
          fprintf (stderr, _("indent: Can't make backup filename of %s\n"), file->name);
          exit (system_error);
       }

       bf = fopen (backup_filename, "w");

       if (!bf)
       {
          fatal (_("Can't open backup file %s"), backup_filename);
       }

       size = fwrite (file->data, file->size, 1, bf);

       if (size != 1)
       {
          fatal (_("Can't write to backup file %s"), backup_filename);
       }

       fclose (bf);
#ifdef PRESERVE_MTIME
       {
          struct utimbuf buf;

          buf.actime = time (NULL);
          buf.modtime = file_stats->st_mtime;

          if (utime (backup_filename, &buf) != 0)
          {
             WARNING(_("Can't preserve modification time on backup file %s"),
                     backup_filename, NULL);
          }
       }
#endif

       xfree(backup_filename);
    }
}

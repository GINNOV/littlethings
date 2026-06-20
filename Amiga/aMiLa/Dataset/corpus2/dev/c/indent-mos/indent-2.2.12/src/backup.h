/**
 * Copyright (c) 1999, Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1993,1994, Joseph Arceneaux.  All rights reserved.
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

#ifndef INDENT_BACKUP_H
#define INDENT_BACKUP_H

#include "sys.h" /* for RCSTAG_H */

RCSTAG_H (backup, "$Id$");

#include <sys/stat.h>
#include "code_io.h"

/**
 * When to make backup files.  Analagous to 'version-control' in Emacs. */
typedef enum
{
    unknown,    /*!< Uninitialized or indeterminate value */
    none,       /*!< Never make backups. */
    simple,     /*!< Make simple backups of every file. */
    numbered_existing,    /*!< Make numbered backups of files that already have numbered backups,
                           *   and simple backups of the others. */
    numbered    /*!< Make numbered backups of every file. */
} backup_mode_ty;

typedef struct
{
    backup_mode_ty value;
    char *name;
} version_control_values_ty;

/**
 * Determine the value of `version_control' by looking in the environment
 * variable "VERSION_CONTROL".  Defaults to numbered_existing. */

extern backup_mode_ty version_control_value(void);

/**
 * Initialize information used in determining backup filenames. 
 */

extern void initialize_backups(void);

/**
 * Make a backup copy of FILE, taking into account version-control.
 * See the description at the beginning of the file for details. 
 */

extern void make_backup(
    file_buffer_ty * file, 
    const struct stat * file_stats);

#endif /* INDENT_BACKUP_H */

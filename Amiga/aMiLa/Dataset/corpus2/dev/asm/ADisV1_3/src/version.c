/*
 * Overall change history:
 * $Log:	version.c,v $
 * Revision 3.0  93/09/24  17:54:32  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.7  93/07/28  23:37:47  Martin_Apel
 * Bug fix: Enabled null-sized data hunks
 * 
 * Revision 2.6  93/07/18  22:57:03  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.5  93/07/13  11:41:53  Martin_Apel
 * Bug fix: Abortion with CTRL-D now handled correctly
 * 
 * Revision 2.4  93/07/11  21:40:28  Martin_Apel
 * Major mod.: Jump table support tested and changed
 * Major mod.: Deleted -ce option
 * 
 * Revision 2.3  93/07/10  13:02:49  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well.
 * 
 * Revision 2.2  93/07/08  22:29:48  Martin_Apel
 * Bug fix: Fixed PFLUSH bug. Mode and mask bits were confused
 * 
 * Revision 2.1  93/07/08  20:51:53  Martin_Apel
 * Fixed various bugs in first beta version
 * 
 * Revision 2.0  93/07/01  11:55:01  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.21  93/07/01  11:47:42  Martin_Apel
 * Minor mods.: Bug fixes
 * 
 * Revision 1.20  93/06/19  19:02:39  Martin_Apel
 * Bug fix: Upon non-FPU disassembly the first opcodes in the opcode table   
 *          were marked illegal.
 * 
 * Revision 1.19  93/06/19  12:12:33  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.18  93/06/16  20:32:40  Martin_Apel
 * Minor mod.: Added 68030 / 040 support. UNTESTED !!!
 * Minor mod.: Added preliminary jump table support. UNTESTED !!!
 * Bug fix in ref_table.c
 * 
 * Revision 1.17  93/06/06  13:49:34  Martin_Apel
 * Minor mod.: Added preliminary support for jump tables recognition
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.16  93/06/06  00:17:32  Martin_Apel
 * Bug fix: Small change regarding recognition of jump tables 
 * Bug fix: DC.B $80 was printed as DC.B -$7F
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.15  93/06/04  11:54:04  Martin_Apel
 * New feature: Added -ln option for generation of ascending label numbers
 * 
 * Revision 1.14  93/06/03  20:31:46  Martin_Apel
 * Minor mod.: Additional linefeed generation for end instructions has been
 *             moved to format_line
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.13  93/06/03  17:01:24  Martin_Apel
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C)
 * 
 * Revision 1.12  93/06/03  15:50:56  Martin_Apel
 * Major mod.: Rewritten part of the hunk handling routines.
 *             Overlay files are now handled correctly
 * Minor mod.: Table size for symbol table is now derived from the size of
 *             the load file instead of from the sum of the hunk sizes
 * 
 * Revision 1.11  93/05/27  20:51:30  Martin_Apel
 * Bug fix: Register list was misinterpreted for MOVEM / FMOVEM
 *          instructions.
 * 
 */

#include <exec/types.h>
#include <string.h>
#include "defs.h"

static char *rcsid = "$Id: version.c,v 3.0 93/09/24 17:54:32 Martin_Apel Exp $";
static char *version = "1.";
static char *revision = "$Revision: 3.0 $";
static char *last_modified = "$Date: 93/09/24 17:54:32 $";

void print_version ()

{
*(last_modified + strlen (last_modified) - 2) = 0;
*(revision + 12) = 0;
printf ("\nADis Version %s%s (%s)\n", version , revision + 11,
         last_modified + 7);
printf ("Copyright by Martin Apel\n");
printf ("A Freely-Redistributable Program\n\n");
}


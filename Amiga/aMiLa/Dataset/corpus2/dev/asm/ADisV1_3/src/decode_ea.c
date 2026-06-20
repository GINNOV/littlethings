/*
 * Change history
 * $Log:	decode_ea.c,v $
 * Revision 3.0  93/09/24  17:53:50  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.5  93/07/18  22:55:43  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.4  93/07/11  21:38:04  Martin_Apel
 * Major mod.: Jump table support tested and changed
 * 
 * Revision 2.3  93/07/10  13:01:56  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.2  93/07/08  22:27:46  Martin_Apel
 * 
 * Minor mod.: Displacements below 4 used with pc indirect indexed are
 *             not entered into the symbol table anymore
 * 
 * Revision 2.1  93/07/08  20:47:04  Martin_Apel
 * Bug fix: Extended precision reals were printed wrong
 * 
 * Revision 2.0  93/07/01  11:53:45  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.12  93/07/01  11:38:28  Martin_Apel
 * Minor mod.: PC relative addressing is now marked as such
 * 
 * Revision 1.11  93/06/16  20:26:17  Martin_Apel
 * Minor mod.: Added jump table support. UNTESTED !!!
 * 
 * Revision 1.10  93/06/06  13:45:34  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.9  93/06/03  18:22:12  Martin_Apel
 * Minor mod.: Addressing relative to hunk end changed
 * 
 */

#include <exec/types.h>
#include <string.h>
#include <stdlib.h>
#include "defs.h"

static char rcsid [] = "$Id: decode_ea.c,v 3.0 93/09/24 17:53:50 Martin_Apel Exp $";

int decode_ea (short mode, short reg, char *where_to, 
               short access, short first_ext)

/* returns the number of extension words used for ea */
{
ULONG ref;
register UWORD first_word;
/* Used for jump table disassembly */
static ULONG last_code_reference = UNSET;


if (pass2 && mode <= 4)
  return (0);

first_word = *(code + first_ext);
switch (mode)
  {
  /********************** data register direct ************************/

  case 0:
    strcpy (where_to, reg_names [reg]);
    return (0);

  /********************* address register direct **********************/

  case 1:
    if (access & ACC_BYTE)
      {
      detected_illegal = TRUE;
      return (0);
      }
    strcpy (where_to, reg_names [reg + 8]);
    return (0);

  /********************** address register indirect *******************/

  case 2:
    indirect (where_to, (short)(reg + 8));
    return (0);

  /************ address register indirect post-increment **************/

  case 3:
    post_inc (where_to, (short)(reg + 8));
    return (0);

  /************* address register indirect pre-decrement **************/

  case 4:
    pre_dec (where_to, (short)(reg + 8));
    return (0);

  /************* address register indirect with displacement **********/

  case 5:
    if (try_small && reg == 4)
      {
      ref = (short)first_word + a4_offset;
      if (pass3)
        gen_label (where_to, ref, TRUE);
      else
        enter_ref (ref, 0L, access);
      }
    else if (pass3)
      disp_an (where_to, (short)(reg + 8), (short)first_word);
    return (1);

  /****************** address register indirect indexed ***************/

  case 6:
    if (first_word & 0x100)
      {
      if (mc68020 && ext_68020_modes)
        return (full_extension (where_to, code + first_ext, mode, reg));
      else
        {
        detected_illegal = TRUE;
        return (0);
        }
      }
    else
      {
      short size = (first_word >> 9) & 0x3;

      if (!mc68020 && size != 0)        /* Only size of 1 allowed for 68000 */
        {
        detected_illegal = TRUE;
        return (0);
        }
      if (pass3)
        {
        /* To get the sign right */
        disp_an_indexed (where_to, (short)(reg + 8),
                         (char)first_word,
                         (short)(first_word >> 12),
                         (short)(1 << size),
                         (first_word & 0x0800) ? ACC_LONG : ACC_WORD);
        }
      return (1);
      }

  /************************* Mode 7 with submodes *********************/

  case 7:
    switch (reg)
      {
      /*********************** absolute short *********************/

      case 0:
        if (pass3)
          format_d (where_to, first_word, FALSE);
        return (1);

      /*********************** absolute long **********************/

      case 1:
        ref = (first_word << 16) + *(code + first_ext + 1);
        if (IS_RELOCATED (current_address + first_ext * 2))
          {
          if (pass2)
            {
            enter_ref (ref, NULL, access);
            if (ref >= first_address && ref < last_address && EVEN (ref))
              last_code_reference = ref;
            }
          else
            /* This reference is relocated and thus needs a label */
            gen_label (where_to, ref, TRUE);
          }
        else if (pass3)
          format_ld (where_to, ref, FALSE);
        return (2);

      /************************** d16(PC) *************************/

      case 2:
/* It's possible, that a program accesses its hunk structure PC relative,
   thus it generates a reference to a location outside valid code addresses */
        ref = current_address + 2 + (short)first_word;
        if (pass3)
          {
          if ((long)ref < (long)first_address)
            {
            gen_label (where_to, first_address, TRUE);
            strcat (where_to, "-");
            format_ld (where_to + strlen (where_to), 
                       *(hunk_start + current_hunk) - ref, TRUE);
            }
          else if (ref >= last_address)
            {
            gen_label (where_to, last_address, TRUE);
            strcat (where_to, "+");
            format_ld (where_to + strlen (where_to), 
                       ref - *(hunk_end + current_hunk), TRUE);
            }
          else
            gen_label (where_to, ref, TRUE);
          strcat (where_to, "(");
          strcat (where_to, reg_names [PC]);
          strcat (where_to, ")");
          }
        else if (ref >= first_address && ref < last_address)
          {
          enter_ref (ref, NULL, access);
          if (EVEN (ref))
            last_code_reference = ref;
          }
            
        return (1);

      /***************** PC memory indirect with index ************/

      case 3:
        if (first_word & 0x0100)
          {
          /* long extension word */
          if (mc68020 && ext_68020_modes)
            return (full_extension (where_to, code + first_ext, mode, reg));
          else
            {
            detected_illegal = TRUE;
            return (0);
            }
          }
        else
          {
          /* short extension word */
          short size = (first_word >> 9) & 0x3;

          if (!mc68020 && size != 0)        /* Only size of 1 allowed for 68000 */
            {
            detected_illegal = TRUE;
            return (0);
            }
         if (pass3)
           disp_an_indexed (where_to, PC, (char)first_word,
                            (short)(first_word >> 12),
                            (short)(1 << size),
                            (first_word & 0x0800) ? ACC_LONG : ACC_WORD);
         else
           {
           ref = current_address + (char)first_word + 2;
           /* Check for JMP (PC,Dx) opcode */
           if (*code == 0x4efb)
             {
             enter_jmptab (last_code_reference, (ULONG)((char)first_word));
             enter_ref (current_address, NULL, ACC_CODE);
             }
           else
             {
             if (ref >= first_address && ref < last_address)
               {
               enter_ref (ref, NULL, access);
               last_code_reference = ref;
               }
             }
           }
          return (1);
          }

      /************************ immediate *************************/

      case 4:
        if (access & ACC_BYTE)
          {
          if (pass3)
            {
            *where_to = '#';
            format_d (where_to + 1, (short)(first_word & 0xff), TRUE);
            }
          return (1);
          }
        else if (access & ACC_WORD)
          {
          if (pass3)
            {
            *where_to = '#';
            format_d (where_to + 1, (short)first_word, TRUE);
            }
          return (1);
          }
        else if (access & ACC_LONG)
          {
          ref = (first_word << 16) + *(code + first_ext + 1);
          if (IS_RELOCATED (current_address + first_ext * 2))
            {
            if (pass2)
              {
              enter_ref (ref, NULL, access);
              if (ref >= first_address && ref < last_address && EVEN (ref))
                last_code_reference = ref;
              }
            else
              {
              /* This reference is relocated and thus needs a label */
              *where_to++ = '#';
              *where_to++ = '(';
              gen_label (where_to, ref, TRUE);
              strcat (where_to, ")");
              }
            }
          else if (pass3)
            {
            *where_to = '#';
            format_ld (where_to + 1, ref, TRUE);
            }
          return (2);
          }
        else if (access & ACC_DOUBLE)
          {
          if (pass3)
            {
            sprintf (where_to, "#$%lx%08lx", *(ULONG*)(code + first_ext),
                     *(ULONG*)(code + first_ext + 2));
            }
          return (4);
          }
        else if (access & ACC_EXTEND)
          {
          if (pass3)
            {
            sprintf (where_to, "#$%lx%08lx%08lx", *(ULONG*)(code + first_ext),
                     *(ULONG*)(code + first_ext + 2), 
                     *(ULONG*)(code + first_ext + 4));
            }
          return (6);
          }
        else
          {
          fprintf (stderr, "INTERNAL ERROR: decode_ea: immediate addressing with unknown size\n");
          fprintf (stderr, "    Current address is: %lx\n", current_address);
          }
        break;
      default:
        /* Should not occur, as it should be caught by the submode test
           in disasm.c */
        detected_illegal = TRUE;
        fprintf (stderr, "INTERNAL ERROR: decode_ea: illegal submode\n");
        fprintf (stderr, "    Current address is: %lx\n", current_address);
      }
    break;    
  }
return (0);
}

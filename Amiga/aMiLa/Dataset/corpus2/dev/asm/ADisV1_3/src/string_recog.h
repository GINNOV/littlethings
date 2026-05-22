/*
 * Change history
 * $Log:	string_recog.h,v $
 * Revision 3.0  93/09/24  17:54:41  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:57:12  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:55:11  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.4  93/06/03  20:31:25  Martin_Apel
 * 
 * 
 */

/* $Id: string_recog.h,v 3.0 93/09/24 17:54:41 Martin_Apel Exp $ */

#define C_PRINTABLE 0x1       /* It's a printable character, including
                                 german umlauts... */
#define C_VALID     0x2       /* It's a valid character, such as C_PRINTABLE,
                                 CR, LF,... */

#define IS_PRINTABLE(c) (c_table[c] & C_PRINTABLE)
#define IS_VALID(c)     (c_table[c] & C_VALID)

static UBYTE c_table [256] =
  {
  0,                          /* $0 */
  0,                          /* $1 */
  0,                          /* $2 */
  0,                          /* $3 */
  0,                          /* $4 */
  0,                          /* $5 */
  0,                          /* $6 */
  C_VALID,                    /* bell */
  C_VALID,                    /* BS */
  C_VALID,                    /* TAB */
  C_VALID,                    /* LF */
  0,                          /* $B */
  C_VALID,                    /* FF */
  C_VALID,                    /* CR */
  0,                          /* $E */
  0,                          /* $F */

  0,                          /* $10 */
  0,                          /* $11 */
  0,                          /* $12 */
  0,                          /* $13 */
  0,                          /* $14 */
  0,                          /* $15 */
  0,                          /* $16 */
  0,                          /* $17 */
  0,                          /* $18 */
  0,                          /* $19 */
  0,                          /* $1A */
  C_VALID,                    /* ESC */
  0,                          /* $1C */
  0,                          /* $1D */
  0,                          /* $1E */
  0,                          /* $1F */

  C_VALID | C_PRINTABLE,      /* BLANK */
  C_VALID | C_PRINTABLE,      /* ! */
  C_VALID | C_PRINTABLE,      /* " */
  C_VALID | C_PRINTABLE,      /* # */
  C_VALID | C_PRINTABLE,      /* $ */
  C_VALID | C_PRINTABLE,      /* % */
  C_VALID | C_PRINTABLE,      /* & */
  C_VALID | C_PRINTABLE,      /* ' */
  C_VALID | C_PRINTABLE,      /* ( */
  C_VALID | C_PRINTABLE,      /* ) */
  C_VALID | C_PRINTABLE,      /* * */
  C_VALID | C_PRINTABLE,      /* + */
  C_VALID | C_PRINTABLE,      /* , */
  C_VALID | C_PRINTABLE,      /* - */
  C_VALID | C_PRINTABLE,      /* . */
  C_VALID | C_PRINTABLE,      /* / */

  C_VALID | C_PRINTABLE,      /* 0 */
  C_VALID | C_PRINTABLE,      /* 1 */
  C_VALID | C_PRINTABLE,      /* 2 */
  C_VALID | C_PRINTABLE,      /* 3 */
  C_VALID | C_PRINTABLE,      /* 4 */
  C_VALID | C_PRINTABLE,      /* 5 */
  C_VALID | C_PRINTABLE,      /* 6 */
  C_VALID | C_PRINTABLE,      /* 7 */
  C_VALID | C_PRINTABLE,      /* 8 */
  C_VALID | C_PRINTABLE,      /* 9 */
  C_VALID | C_PRINTABLE,      /* : */
  C_VALID | C_PRINTABLE,      /* ; */
  C_VALID | C_PRINTABLE,      /* < */
  C_VALID | C_PRINTABLE,      /* = */
  C_VALID | C_PRINTABLE,      /* > */
  C_VALID | C_PRINTABLE,      /* ? */

  C_VALID | C_PRINTABLE,      /* @ */
  C_VALID | C_PRINTABLE,      /* A */
  C_VALID | C_PRINTABLE,      /* B */
  C_VALID | C_PRINTABLE,      /* C */
  C_VALID | C_PRINTABLE,      /* D */
  C_VALID | C_PRINTABLE,      /* E */
  C_VALID | C_PRINTABLE,      /* F */
  C_VALID | C_PRINTABLE,      /* G */
  C_VALID | C_PRINTABLE,      /* H */
  C_VALID | C_PRINTABLE,      /* I */
  C_VALID | C_PRINTABLE,      /* J */
  C_VALID | C_PRINTABLE,      /* K */
  C_VALID | C_PRINTABLE,      /* L */
  C_VALID | C_PRINTABLE,      /* M */
  C_VALID | C_PRINTABLE,      /* N */
  C_VALID | C_PRINTABLE,      /* O */

  C_VALID | C_PRINTABLE,      /* P */
  C_VALID | C_PRINTABLE,      /* Q */
  C_VALID | C_PRINTABLE,      /* R */
  C_VALID | C_PRINTABLE,      /* S */
  C_VALID | C_PRINTABLE,      /* T */
  C_VALID | C_PRINTABLE,      /* U */
  C_VALID | C_PRINTABLE,      /* V */
  C_VALID | C_PRINTABLE,      /* W */
  C_VALID | C_PRINTABLE,      /* X */
  C_VALID | C_PRINTABLE,      /* Y */
  C_VALID | C_PRINTABLE,      /* Z */
  C_VALID | C_PRINTABLE,      /* [ */
  C_VALID | C_PRINTABLE,      /* \ */
  C_VALID | C_PRINTABLE,      /* ] */
  C_VALID | C_PRINTABLE,      /* ^ */
  C_VALID | C_PRINTABLE,      /* _ */

  C_VALID | C_PRINTABLE,      /* ` */
  C_VALID | C_PRINTABLE,      /* a */
  C_VALID | C_PRINTABLE,      /* b */
  C_VALID | C_PRINTABLE,      /* c */
  C_VALID | C_PRINTABLE,      /* d */
  C_VALID | C_PRINTABLE,      /* e */
  C_VALID | C_PRINTABLE,      /* f */
  C_VALID | C_PRINTABLE,      /* g */
  C_VALID | C_PRINTABLE,      /* h */
  C_VALID | C_PRINTABLE,      /* i */
  C_VALID | C_PRINTABLE,      /* j */
  C_VALID | C_PRINTABLE,      /* k */
  C_VALID | C_PRINTABLE,      /* l */
  C_VALID | C_PRINTABLE,      /* m */
  C_VALID | C_PRINTABLE,      /* n */
  C_VALID | C_PRINTABLE,      /* o */

  C_VALID | C_PRINTABLE,      /* p */
  C_VALID | C_PRINTABLE,      /* q */
  C_VALID | C_PRINTABLE,      /* r */
  C_VALID | C_PRINTABLE,      /* s */
  C_VALID | C_PRINTABLE,      /* t */
  C_VALID | C_PRINTABLE,      /* u */
  C_VALID | C_PRINTABLE,      /* v */
  C_VALID | C_PRINTABLE,      /* w */
  C_VALID | C_PRINTABLE,      /* x */
  C_VALID | C_PRINTABLE,      /* y */
  C_VALID | C_PRINTABLE,      /* z */
  C_VALID | C_PRINTABLE,      /* { */
  C_VALID | C_PRINTABLE,      /* | */
  C_VALID | C_PRINTABLE,      /* } */
  C_VALID | C_PRINTABLE,      /* ~ */
  0,                          /* DEL */

  0,                          /* $80 */
  0,                          /* $81 */
  0,                          /* $82 */
  0,                          /* $83 */
  0,                          /* $84 */
  0,                          /* $85 */
  0,                          /* $86 */
  0,                          /* $87 */
  0,                          /* $88 */
  0,                          /* $89 */
  0,                          /* $8A */
  0,                          /* $8B */
  0,                          /* $8C */
  0,                          /* $8D */
  0,                          /* $8E */
  0,                          /* $8F */

  0,                          /* $90 */
  0,                          /* $91 */
  0,                          /* $92 */
  0,                          /* $93 */
  0,                          /* $94 */
  0,                          /* $95 */
  0,                          /* $96 */
  0,                          /* $97 */
  0,                          /* $98 */
  0,                          /* $99 */
  0,                          /* $9A */
  0,                          /* $9B */
  0,                          /* $9C */
  0,                          /* $9D */
  0,                          /* $9E */
  0,                          /* $9F */

  0,                          /* $A0 */
  0,                          /* $A1 */
  0,                          /* $A2 */
  0,                          /* $A3 */
  0,                          /* $A4 */
  0,                          /* $A5 */
  0,                          /* $A6 */
  0,                          /* $A7 */
  0,                          /* $A8 */
  C_VALID | C_PRINTABLE,      /* $A9 */
  0,                          /* $AA */
  0,                          /* $AB */
  0,                          /* $AC */
  0,                          /* $AD */
  0,                          /* $AE */
  0,                          /* $AF */

  0,                          /* $B0 */
  0,                          /* $B1 */
  0,                          /* $B2 */
  0,                          /* $B3 */
  0,                          /* $B4 */
  0,                          /* $B5 */
  0,                          /* $B6 */
  0,                          /* $B7 */
  0,                          /* $B8 */
  0,                          /* $B9 */
  0,                          /* $BA */
  0,                          /* $BB */
  0,                          /* $BC */
  0,                          /* $BD */
  0,                          /* $BE */
  0,                          /* $BF */

  0,                          /* $C0 */
  0,                          /* $C1 */
  0,                          /* $C2 */
  0,                          /* $C3 */
  C_VALID | C_PRINTABLE,      /* Ä */
  0,                          /* $C5 */
  0,                          /* $C6 */
  0,                          /* $C7 */
  0,                          /* $C8 */
  0,                          /* $C9 */
  0,                          /* $CA */
  0,                          /* $CB */
  0,                          /* $CC */
  0,                          /* $CD */
  0,                          /* $CE */
  0,                          /* $CF */

  0,                          /* $D0 */
  0,                          /* $D1 */
  0,                          /* $D2 */
  0,                          /* $D3 */
  0,                          /* $D4 */
  0,                          /* $D5 */
  C_VALID | C_PRINTABLE,      /* Ö */
  0,                          /* $D7 */
  0,                          /* $D8 */
  0,                          /* $D9 */
  0,                          /* $DA */
  0,                          /* $DB */
  C_VALID | C_PRINTABLE,      /* Ü */
  0,                          /* $DD */
  0,                          /* $DE */
  C_VALID | C_PRINTABLE,      /* ß */

  0,                          /* $E0 */
  0,                          /* $E1 */
  0,                          /* $E2 */
  0,                          /* $E3 */
  C_VALID | C_PRINTABLE,      /* ä */
  0,                          /* $E5 */
  0,                          /* $E6 */
  0,                          /* $E7 */
  0,                          /* $E8 */
  0,                          /* $E9 */
  0,                          /* $EA */
  0,                          /* $EB */
  0,                          /* $EC */
  0,                          /* $ED */
  0,                          /* $EE */
  0,                          /* $EF */

  0,                          /* $F0 */
  0,                          /* $F1 */
  0,                          /* $F2 */
  0,                          /* $F3 */
  0,                          /* $F4 */
  0,                          /* $F5 */
  C_VALID | C_PRINTABLE,      /* ö */
  0,                          /* $F7 */
  0,                          /* $F8 */
  0,                          /* $F9 */
  0,                          /* $FA */
  0,                          /* $FB */
  C_VALID | C_PRINTABLE,      /* ü */
  0,                          /* $FD */
  0,                          /* $FE */
  0                           /* $FF */
  };

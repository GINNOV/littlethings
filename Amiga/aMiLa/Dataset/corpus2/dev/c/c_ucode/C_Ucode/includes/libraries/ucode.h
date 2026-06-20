/*****************************************************************************/
/*                                                                           */
/* ucode.h    Include file with structures for ucode.library                 */
/* ~~~~~~~                                                                   */
/* Version  0.03     September 1, 2008 Gilles Pelletier                      */
/*                                                                           */
/* Version  0.02     October 13, 2000                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef LIBRARIES_UCODE_INCLUDED
/* for stopping further includes of ucode.h */
#define LIBRARIES_UCODE_INCLUDED

#include <exec/types.h>
#include <dos/dosextens.h>
#include <intuition/intuition.h>

/* set version of ucode.library */
#define xxp_uver 1

/****
 *
 * structures made by ucode.library TLUmake
 *
 ****/

#define ucode_group   1  /* (private) glyph group                         */
#define ucode_rport   2  /* rastport for a glyph                          */
#define ucode_glyph   3  /* glyph record                                  */
#define ucode_list    4  /* file list                                     */
#define ucode_blok    5  /* collection of in-memory ucode_glyphs          */
#define ucode_preview 6  /* preview                                       */
#define ucode_font    7  /* fill ucode_blok glyphs with font glyphs       */
#define ucode_kill    8  /* kill ucode_blok records with ucode_list items */



/****
 *
 * structure of a ucode_path
 *
 ****
 * this structure is returned by TLUstart */
struct xxp_path
{
 struct Library *xxp_dosp ; /* dos.library base       */
 struct Library *xxp_gfxp ; /* graphics.library base  */
 struct Library *xxp_intp ; /* intuition.library base */
 struct Library *xxp_amem ; /* AllocRemember pointer  */

 BYTE xxp_gle1 ; /* ascender expand  (pixels) }             */
 BYTE xxp_gle2 ; /* descender expand (pixels) } warper data */
 WORD xxp_gle3 ; /* width expand     (en %)   }             */
 BYTE xxp_gle4 ; /* (unused)                  }             */
 BYTE xxp_gle5 ; /* (unused)                  }             */
 BYTE xxp_glvw ; /* vertical embold           }             */
 BYTE xxp_glhw ; /* horizontal embold         }             */
 WORD xxp_uwac ; /* -1 if warper non-null                   */

 APTR xxp_base ; /* base of ucode_path chain */
 APTR xxp_clon ; /* next ucode_path in chain */

 BYTE xxp_pthc[24] ; /* path of 'UCODE:' + its subdirs / files */
 LONG xxp_uhnd ; /* handle for TLUgrab */
 WORD xxp_eror ; /* error code from a TLU routine */

 WORD xxp_uasb ; /* bytes per scanline in xxp_uhnd file  } from file */
 WORD xxp_uasl ; /* scanlines per glyph in xxp_uhnd file } header */
 WORD xxp_uabl ; /* baseline of glyph in xxp_uhnd file */
 WORD xxp_uade ; /* descender of glyph in xxp_uhnd file */

 WORD xxp_uwsl ; /* scanlines of glyph as warped */
 WORD xxp_uwbl ; /* baseline of glyph as warped */
 WORD xxp_uwde ; /*descender of glyph as warped */

 WORD xxp_page ; /* msw if>FFFF }                              */
 WORD xxp_uaun ; /* unicode     }                              */
 WORD xxp_uasz ; /* height      }  attributes of xxp_uhnd, &c  */
 BYTE xxp_uawd ; /* width       }                              */
 BYTE xxp_uabo ; /* weight      }                              */
 WORD xxp_uast ; /* style       }                              */

 BYTE xxp_inht ; /* indic joiner ht above baseline  }              */
 BYTE xxp_arht ; /* arabic joiner ht above baseline }              */
 BYTE xxp_ijht ; /* indic joiner line ht            }              */
 BYTE xxp_ajht ; /* arabic joiner line ht           } drawing data */
 BYTE xxp_drwv ; /* misc drawing line ht            }              */
 BYTE xxp_drwh ; /* misc drawing line wd            }              */
 BYTE xxp_bohw ; /* horz weight to add if bold      }              */
 BYTE xxp_bovw ; /* vert weight to add if bold      }              */
 BYTE xxp_itdx ; /* italic dx                       }              */
 BYTE xxp_itdy ; /* italic dy                       }              */
 BYTE xxp_iker ; /* indic kern width laps           }              */
 BYTE xxp_ikes ; /* (unused)                        }              */

 BYTE xxp_spcx[6] ; /* width of  M,n,3,DC28,002D,002E */
 BYTE xxp_spcy[6] ; /* height of M,n,3,DC28,002D,002E */
 BYTE xxp_trnc ;    /* <> to cause TLUgrab to grab only header */
 BYTE xxp_kapt ;    /* 0 if any of spcx,y are null (couldn't grab) */

 APTR xxp_lang ;    /* private use by TLUcharset */
 BYTE xxp_cset[16] ; /* see "language data" below */

 APTR xxp_list ; /* ucode_list for current xxp_page */
 APTR xxp_lsts ; /* linked list of available xxp_lists - see below */

 APTR xxp_glyf ; /* ucode_glyph */
 APTR xxp_rprt ; /* ucode_rport */
 APTR xxp_blok ; /* ucode_block, 0 if none */
 APTR xxp_grup ; /* ucode_group, 0 if none */
} ;


/****
 *
 * Setting ucode_path attributes
 *
 ****

 ; A ucode_path's attributes are set as follows:
 ;
 ;  1. When the ucode_path is first made, by TLUstart or TLUclone
 ;  2. by calling TLUset
 ;  3. by calling TLUcharset
 ;  4. TLUset sets default values for drawing data (xxp_inht to xxp_ikes).
 ;     Applications poke different values into these.
 */

/****
 *
 * Loading glyph files
 *
 ****

 ; Glyph files can be loaded by these routines:
 ;
 ;  1. TLUgrabrport (and TLUdims)
 ;  2. TLUstring    (and TLUbreak)
 ;  3. TLUpreview
 ;
 ; When they want a glyph, they call an internal routine called TLUgrab
 ; which loads from the glyph files (or memory buffers pointed to by the
 ; ucode_path), using the ucode_path to see what glyph attributes are
 ; required. The glyph may also be warped, if ucode_path's warper is
 ; set. When a glyph is loaded, it is loaded into a sub-structure of the
 ; ucode_path pointed to by xxp_glyf. When a glyph is to be printed, it is
 ; moved to a little rastport in the ucode_path pointed to by xxp_rprt,
 ; whence it can be blitted to whatever rastport it is to be printed to.
 ; An internal routine called TLUtransfer copes from xxp_glyf to xxp_rprt.
 */

/****
 *
 * xxp_lists and pages
 *
 ****

 ; 'Ucode:pages' is a list of all extant Uxxxx directories, each of which
 ; has its own '/List' made by UcodeFix. TLUstart fills xxp_lsts with 0 if
 ; there is no Ucode:pages, else it points xxp_lsts to a list of items, with
 ; format:
 ;
 ;    bytes 0-1  high word (0000-FFFF)
 ;          2-4  name of surrogate directory in ASCII } For each extant surr,
 ;          5    0                                    } first U0000, then
 ;          6-9  address of list                      } U0001 - UFFFF
 ;
 ; after that, a $0000 delimiter, then the lists, pointed to by bytes 6-9 of
 ; the above records. When TLUset is called, it sets xxp_list to point to
 ; the list for U0000, xxp_page = 0, and xxp_pathc to 'U0000'. If TLUgrab
 ; sets xxp_page to a new value, it uses xxp_lsts to set xxp_list to the
 ; ucode_list for that page, sets xxp_page to whichever, and replaces
 ; 'U0000' in xxp_pthc by whichever.
 */

/****
 *
 * flags
 *
 ****

 * flags for TLUset (OR them together)
 */
#define xxp_bkill  1 /* bloklist to kill in A1 (else A1 ignored)       */
#define xxp_bmake  2 /* bloklist to make in A2 (else A2 ignored)       */
#define xxp_fmake  4 /* fontlist to make in A3 (else A3 ignored)       */
#define xxp_lwarp  8 /* if set, leave warp data alone, else clear      */
#define xxp_gmake 16 /* if set, make/refill ucode_group, unicode in D5 */

/* width */
#define TLU_WIDTH_ULTRA_CONDENSED 0
#define TLU_WIDTH_EXTRA_CONDENSED 1
#define TLU_WIDTH_CONDENSED       2
#define TLU_WIDTH_SEMI_CONDENSED  3
#define TLU_WIDTH_NORMAL          4
#define TLU_WIDTH_SEMI_EXPANDED   5
#define TLU_WIDTH_EXPANDED        6
#define TLU_WIDTH_EXTRA_EXPANDED  7
#define TLU_WIDTH_ULTRA_EXPANDED  8

/* style are 2 characters from AA to ZZ */
#define TLU_STYLE_SS ('S'<<8)|('S'<<0)
#define TLU_STYLE_WS ('W'<<8)|('S'<<0)
#define TLU_STYLE_TT ('T'<<8)|('T'<<0)
#define TLU_STYLE_SC ('S'<<8)|('C'<<0)
#define TLU_STYLE_FA ('F'<<8)|('A'<<0)

/****
 *
 * language data  (as set by TLUcharset)
 *
 ****

 ; xxp_lang is 0, or a linked list shared by all clones. It is for private
 ; use by TLUcharset. xxp_cset is a set of up to 4 pointers to operative
 ; character sets. The csets have the following format:
 ;   bytes  0-11 unused
 ;         12-13 1st input byte/word in range e.g. 00A1 for ISO8859-2, etc.
 ;         14-15 end input byte/word in range e.g. 00FF for ISO8859-2, etc.
 ;           16+ 1 word for each input byte/word, being the unicode
 ;               corresponding to each input in the range. So if e.g. the
 ;               range was 00A1 to 00FF, then the word at 18 would be the
 ;               unicode corresponding to input 00A2. In the case of
 ;               ISO8859-2 that would be 02D8.
 ; There need to be up to 4 pointers, because some input formats (such as
 ; shift-jis) have several different ranges.
 */

/****
 *
 * structure of individual glyph records
 *
 ****

 ; If the record is in memory, there are 60 scanlines, each with 6 bytes.
 ; If in a file, the scanlines have 2,4 or 6 bytes,as per the file header's
 ; xxp_glsb, and scanlines as per the file header's xxp_glsl.

 ; xxp_glys (= header size) MUST be divisible by 4
 */
#if 0
 STRUCTURE xxp_glws,0
 BYTE xxp_vtx1             ;vertical expanders (above basline)
 BYTE xxp_vtx2
 BYTE xxp_vtx3
 BYTE xxp_vtx4
 BYTE xxp_vtx5             ;                   (below baseline)
 BYTE xxp_hrx1             ;horizontal expanders
 BYTE xxp_hrx2
 BYTE xxp_xsz0             ;width in pixels
 BYTE xxp_ysz1             ;height in pixels above baseline
 BYTE xxp_ysz2             ;height in pixels below baseline
 BYTE xxp_gybl             ;baseline of glyph
 BYTE xxp_gysl             ;scanlines in glyph (actual ht)
 BYTE xxp_ext1             ;ext byte 1  }
 BYTE xxp_ext2             ;ext byte 2  } see
 BYTE xxp_ext3             ;ext byte 3  } below
 BYTE xxp_ext4             ;ext byte 4  }
 STRUCT xxp_glys,360       ; 60 scanlines, each 6 bytes = 360 bytes
 LABEL xxp_glyt            ;(header = 16 bytes, total size 376 bytes)

; xxp_ext1 - xxp_ext4  are for additional attributes used by TLUpreview.
;
; xxp_ext1    bit  0  .dkom  Double decomposer
;                  1  .trip  Triple decomposer
;                  2  .alfm  Ligates to lam (alif, &c)
;                  3  .blc1/2/3,.indb,.indl        Left joiner
;                  4  .blc1/2/3,.indb,.indr,.arbr  Right joiner
;                  5
;                  6  .mirr  Mirrors - one of pair
;                  7  .mrle  Mirrors - lone
;
; xxp_ext2    bit  0  .arab  Arabic
;                  1  .indc  Indic
;                  2  .hbrw  Hebrew
;                  3  .ifar  If in .arbr Arabic right joiners
;                  4  .ifab  If in .arbd Arabic double joiners
;                  5  .bidl  Bidi strong left
;                  6  .bidr  Bidi strong right
;                  7  .weak  Bidi weak
;
; xxp_ext3         .cods code
;
; xxp_ext4         .diax code
#endif

#if 0
****
*
* structure of data files / ucode_groups
*
****

; If in a file, scanlines have length 2,4 or 6 as per xxp_glsb. If in
;    a ucode_group, xxp_glsb = 6
; If in a file, records each have xxp_glsl scanlines. If in a ucode_group,
;    records each have 60 scanlines, those below xxp_glsl being undefined.
; xxp_glrc = xxp_glys + (xxp_glsl * xxp_glsb). In a file, this is the record
;    size, but in a ucode_group record size is xxp_glys + (6 * 60) = 376.

; xxp_glhl (=header size) MUST be divisible by 4

 STRUCTURE xxp_gldf,0
 BYTE xxp_glwd             ;width 0-8   4=NM
 BYTE xxp_glwt             ;weight 1-9  4=normal 7=bold
 WORD xxp_glss             ;style       SS=sans serif
 WORD xxp_glrk             ;records in file - always 1024
 WORD xxp_glbl             ;baseline
 WORD xxp_glrc             ;glyph record length = xxp_glsl*xxp_glsb+xxp_glys
 WORD xxp_glsl             ;scanlines per glyph
 WORD xxp_glsb             ;bytes per scanline  2/4/6
 WORD xxp_glun             ;Unicode of 1st glyph - always 0 modulo 1024
 LABEL xxp_glhl            ;size of header = 16

; then follow xxp_glrk records each heaving a xxp_glws header, then xxp_glsl
; scanlines, each xxp_glsb bytes, if in a file. If in a ucode_group, the
; scanlines are padded to make total actual record len = 376.



****
*
* structure of ucode_preview
*
****

 STRUCTURE xxp_prvw,0


; IMPORTANT!!!
; ~~~~~~~~~
; All addresses in the ucode_preview except xxp_pvxe, xxp_pvtx and xxp_prip
; are relative to the origin of the ucode_preview.


; overall data about words & boxes - set by TLUpreview

 LONG xxp_prvl             ;total size of ucode_preview
 WORD xxp_libv             ;xxp_uver of library from which TLUpreview called

 WORD xxp_delm             ;delimiter code (see below) } transitory
 APTR xxp_pvxe             ;end of input text          } data returned by
 BYTE xxp_bicf             ;bidi level c/f             } TLUpreview
 BYTE xxp_unus             ;(unused)                   }

 WORD xxp_pvbn             ;number of boxes (letters)
 BYTE xxp_pvbu             ;max box ascender
 BYTE xxp_pvbd             ;max box descender

 WORD xxp_pvv0             ;widest word if can break at SHY    }
 WORD xxp_pvv1             ;no. of inter-chr gaps in pvv0 word } currently
 WORD xxp_pvv2             ;widest word if SHY forbid          } inoperative
 WORD xxp_pvv3             ;no. of inter-chr gaps in pvv2 word }

; overall data about lines - set by TLUformat

 APTR xxp_linf             ;end of xxp_linds ( = end of all data in preview)
 WORD xxp_pwln             ;number of lines
 WORD xxp_pwht             ;total height of all lines
 WORD xxp_lgap             ;total gaps between lines (exc paras,ffs)
 WORD xxp_pgap             ;total gaps between paras
 WORD xxp_fgap             ;total gaps between ffs
 WORD xxp_pwwl             ;width of widest line
 WORD xxp_pwhl             ;height of highest line
 WORD xxp_pack             ;min lspc if lines kerned w. each other (0=undef)
 WORD xxp_tlxy             ;tilt dx,dy (dy can be -ve, 0 if none)
 WORD xxp_laps             ;max tilt lhs, rhs laps
 APTR xxp_lin0             ;addr of 1st xxp_lind

; next line to be printed - init by TLUformat, reset by each TLUprint call

 APTR xxp_linc             ;next xxp_lind to be printed
 STRUCT xxp_hili,12        ;hilighted: (line,box)-(line,box),(init) -1=none

 LABEL xxp_prvs


; The following data are replicated if TLUpreview is re-called with append.
; xxp_link links forward to the next xxp_rend if any
;
; e.g. if there were 2 calls to TLUpreview, you would have:
;
; xxp_prvw
; xxp_rend, boxes, scanlines (1st call)(xxp_link points to 2nd xxp_rend)
; xxp_rend, boxes, scanlines (2nd call)(xxp_link = 0)
; xxp_linds (lines)

 STRUCTURE xxp_rend,0
 APTR xxp_link             ;0, or pointer to next xxp_rend if any

 BYTE xxp_indh             ;height of top of Indic joiners above bline  }
 BYTE xxp_arbh             ;height of top of Arabic joiners above bline }
 BYTE xxp_indi             ;height of indic joiners  } joiner           }
 BYTE xxp_arab             ;height of arabic joiners } rendering        }
 BYTE xxp_pvdy             ;vertical height of horiz lines  } misc diac }
 BYTE xxp_pvdx             ;horizontal width of vert lines  } rendering }

 STRUCT xxp_spmx,6         ;width of  M,n,3,DC28,002D,002E
 STRUCT xxp_spmy,6         ;height of M,n,3,DC28,002D,002E

 APTR xxp_scln             ;address of scanlines
 APTR xxp_dubl             ;address of DC28-B scanlines (undef if no 0360-1)
 APTR xxp_dash             ;address of 002D (hyphen)    (undef if no SHYs)
 LABEL xxp_pvs2            ;size = 34


; then follow 0 or more boxes, each with structure...

 STRUCTURE xxp_ubox,0

; overall data about box - set by TLUpreview

 APTR xxp_pvtx             ;link number, rel address of  input text } trans-
 APTR xxp_renp             ;rel address of xxp_rend for this box    } itory

 BYTE xxp_pvnm             ;number of constituents (0+)
 BYTE xxp_pvwd             ;width of box
 BYTE xxp_pvyu             ;ascender of box
 BYTE xxp_pvyd             ;descender of box

 BYTE xxp_join             ;join to prev box:  bit 6arab 5indi
                           ;und/overlines: bit 4ov 3und 2dbov 1dbund 0thru
                           ;bit 7 set if box begins "word"
 BYTE xxp_joi2             ;join to next box:  bit 5=0338 6=20D2
                           ; 0=0360 1=0361  2=indi  7=arab
                           ;bits 3,4 set if either of bits 5,6 set
 BYTE xxp_ltil             ;lhs lap if chr tilted
 BYTE xxp_rtil             ;rhs lap if chr tilted

 BYTE xxp_bidi             ;bidi embed level (0-15 as pr Unicode bidi)
 BYTE xxp_bits             ;style bit 0 = bold, 1 = tilt
 STRUCT xxp_unis,16        ;up to 7 constituents - 1st long, others word
                           ;constits can include non-glyph unicodes &c
                           ;constits may include dummy glyphs
 WORD xxp_norm             ;0, or unshaped form of ist item in xxp_unis
 LONG xxp_scns             ;pointer to scanlines, 0 if none
 LONG xxp_forc             ;byte 0 bits 0-3 to force Uformat d3 bits 8-11
                           ;            4   1 if bits 0-3 operative
                           ;            5   1 if byte 1 operative
                           ;            6   1 if byte 2 operative
                           ;            7   1 if byte 3 bit 7 operative
                           ;byte 1          forced fpen (if byte 0 bit 5)
                           ;byte 2          forced bpen (if byte 0 bit 6)
                           ;byte 3 bits 0-5 fixx bits (0-31) if bit 6 set
                           ;            6   set if bits 0-5 operative
                           ;            7   1=small caps if byte 0 bit 7 set


; box posn in line - set by TLUformat

 WORD xxp_pvxp             ;pixel xpos of this box in line
 LONG xxp_fllk             ;bytes disp to next box printed
 LABEL xxp_pvsz            ;48 bytes


; after all boxes come scanlines; bytes per line for a box's scanlines
; = int((pvwd+7)/8), scanlines = pvyu+pvyd.


; (if TLUpreview is called more than once with append, there will be
;  more lots of xxp_rend + boxes + scanlines linked together here)


; after all scanlines come 0 or more line data structures, set by TLUformat

 STRUCTURE xxp_lind,0

 APTR xxp_box0             ;address of first xxp_ubox in line
 APTR xxp_boxp             ;address of first xxp_ubox printed
 WORD xxp_pwlw             ;width of line
 BYTE xxp_pwla             ;ascender of line
 BYTE xxp_pwld             ;descender of line
 BYTE xxp_wdjn             ;OR of all xxp_joins in line + bits 3,4 of joi2
 BYTE xxp_wdj2             ;forced under/overline codes for line
 WORD xxp_term             ;how line ended  0=eot 1=line full 2=2028 3=2029
 BYTE xxp_lapl             ;lhs tilt lap
 BYTE xxp_lapr             ;rhs tilt lap

; data filled in each time TLUprint called for this line

 STRUCT xxp_prid,38        ;0-3   xpos,ypos  22   jam       }
                           ;4-11  wbox       23-27 und pens } data from
                           ;12-19 wint       28-37 und patts} last TLUprint
                           ;20-21 pens                      } call. Undefind
                           ;22    jam                       } if xxp_prip= 0
 APTR xxp_prip             ;rastport when TLUprint called   }

 LABEL xxp_lnsz            ;size of xxp_lind (=60)

; xxp_delm codes...
; -8 bad: xxp_scpx/spcy kaput  3 xshyq               8 xaddr
; -4 bad: out of public mem    4 xanyq               9 xtabq
;  0 end of text reached       5 xeolq              10 xpreq
;  1 xxp_xwspc                 6 xeopq              11 xboxl
;  2 xspcc                     7 xanyq + unrec chr  12 insuff mem to append



****
*
* structure of ucode_blok
*
****

; A ucode_blok has 1 or more linked memory blocks. The first is pointed
; to by xxp_blok in ucode_path. Then, each memory structure has the
; following header:

; Bytes 0-3  address of the end of this memory block
; Bytes 4-7  address of next memory block (0 if none)

; Then each memory block has 1 or more records, each with the structure

  STRUCTURE xxp_bhed,0

  APTR xxp_bhnx            ;address of next record, 0 if none
  WORD xxp_bhoo            ;-1 = set, 0 = not set
  WORD xxp_bhht            ;nominal ht }
  BYTE xxp_bhwd            ;width      }  attributes of glyphs in record,
  BYTE xxp_bhwt            ;weight     }  to be matched with ucode_path
  WORD xxp_bhst            ;style      }  attributes.
  STRUCT xxp_bhwp,8        ;warp data  }
  LONG xxp_bhua            ;unicode of 1st glyph in blok
  LONG xxp_bhuz            ;           last glyph in blok + 1
  WORD xxp_bhbg            ;bytes per glyph of glyphs following
  WORD xxp_bhbs            ;bytes per scanline of glyphs following
  LABEL xxp_bhsz           ;=34

; Then follow xxp_bhnm glyphs, all of length xxp_bhbg bytes, with xxp_bhbs
; bytes in their scanlines.

; if xxp_bhoo of the first record is +1, the memory blok is empty


****
*
* structure of ucode_list
*
****

; The ucode_list structure has a longword at the start, being the number
; of records which follow. Then, there is a xxp_lrec for each glyph file in
; the Ucode/U0000 structure. Finally, a longword checksum.

 STRUCTURE xxp_lrec,0      ;represents a file in U0000
 WORD xxp_uhgt             ;the nominal glyph height, if hh, in dir Uhh
 BYTE xxp_uwid             ;the width descriptor, from 0 to 8
 BYTE xxp_uwgt             ;the weight descriptor, from 1 to 9
 WORD xxp_uuni             ;the unicode of the 1st glyph in the file
 WORD xxp_usty             ;the style descriptor, e.g. "SS"
 LABEL xxp_ulss            ;size of xxp_lrec = 8

; The records are sorted with sort keys in decreasing order of importance:
;
;    Height, Width, Weight, Unicode.
;
; A  maximum of 2048 glyph files in each subdirectory will be included.



/****
 *
 * tags for TLUpreview
 *
 ****/

#define xxp_xwspc  1 /* stop if white space exc 0020 found        dflt F */
#define xxp_xspcc  2 /* stop if 0020 found                        dflt F */
#define xxp_xshyq  3 /* stop if SHY found                         dflt F */
#define xxp_xanyq  4 /* stop if anything but chr/diac found       dflt F */
#define xxp_xaddr  5           ;stop after address reached or 0           dflt 0
#define xxp_xeolq  6           ;stop if 000A 000D 2028 found              dflt F
#define xxp_xeopq  7           ;stop if 000C 000F 2029 found              dflt F
#define xxp_xboxl  8           ;stop if no. of boxes exceeded or 0        dflt 0
#define xxp_xtabq  9           ;stop if 0009 found                        dflt F
#define xxp_xbidt 10          ;bidi override 0ltr +1rtl -1none           dflt 0
#define xxp_xfixx 11          ;0=none, 1-32=pixels, 33+=Unicode          dflt 0
#define xxp_xsmal 12          ;T=small caps                              dflt F
#define xxp_xoldn 13          ;T=old style numerals                      dflt F
#define xxp_xdcom 14          ;T=decompose                               dflt T
#define xxp_xfrmt 15          ;0=ASCII 1=UTF16 -1=UTF8                   dflt 0
#define xxp_xlang 16          ;0 or address of 00A1-00FF language table  dflt 0
#define xxp_xbibf 17          ;bidi N1 data from prev block's xxp_bicf   dflt 0
#define xxp_xfpre 18          ;what to sub for whitespace if xescs bt3  dflt 20
#define xxp_xmirq 19          ;T="mirror" 00AB-00BB,2018-201F if RTL     dflt T
#define xxp_xescs 20          ;embeds:  0esc  1&,stop< 2< 3remove whit   dflt 0
#define xxp_xalli 21          ;T = all boxes italic                      dflt F
#define xxp_xallb 22          ;T = all boxes bold                        dflt F
#define xxp_xtilt 23          ;clone number for italic, else -1         dflt -1
#define xxp_xemph 24          ;clone number for bold, else -1           dflt -1
#define xxp_xappe 25          ;T=append to existing boxes                dflt F
#define xxp_xclon 26          ;clone number of plain chrs, else -1      dflt -1
#define xxp_xboit 27          ;clone number of bold+italilc, else -1    dflt -1
#define xxp_xfile 28          ;0 or read input from a file               dflt 0
#define xxp_xut16 29          ;0 or read input from next UT16 chunk      dflt 0


/****
 *
 * TLUprint underline data (supplied in D7)
 *
 ****

; underline data - length 16 bytes
;   byte  0    = caller use
;   bytes 1-5  = colours for  }  thru, dbund, dbov, und, ov
;   bytes 6-15 = patterns for }
 */
#endif

/* end of ucode.h */
#endif

#include <iffp/ilbmapp.h>

struct   NewWindow      mynw = {
   0, 0,                                  /* LeftEdge and TopEdge */
   0, 0,                                  /* Width and Height */
   (UBYTE)-1, (UBYTE)-1,                  /* DetailPen and BlockPen */
   IDCMP_RAWKEY | IDCMP_MENUPICK | IDCMP_MOUSEBUTTONS, /* IDCMP Flags with Flags below */
   WFLG_BACKDROP | WFLG_BORDERLESS |
   WFLG_SMART_REFRESH | WFLG_NOCAREREFRESH |
   WFLG_ACTIVATE | WFLG_NEWLOOKMENUS,
   NULL, NULL,                            /* Gadget and Image pointers */
   NULL,                                  /* Title string */
   NULL,                                  /* Screen ptr null till opened */
   NULL,                                  /* BitMap pointer */
   50, 20,                                /* MinWidth and MinHeight */
   0 , 0,                                 /* MaxWidth and MaxHeight */
   CUSTOMSCREEN                           /* Type of window */
   };


/* ILBM Property chunks to be grabbed
 * List BMHD, CMAP and CAMG first so we can skip them when we write
 * the file back out (they will be written out with separate code)
 */
LONG    ilbmprops[] = {
                ID_ILBM, ID_BMHD,
                ID_ILBM, ID_CMAP,
                ID_ILBM, ID_CAMG,
                ID_ILBM, ID_CCRT,
                ID_ILBM, ID_AUTH,
                ID_ILBM, ID_Copyright,
                TAG_DONE
                };

/* ILBM Collection chunks (more than one in file) to be gathered */
LONG    ilbmcollects[] = {
                ID_ILBM, ID_CRNG,
                TAG_DONE
                };

/* ILBM Chunk to stop on */
LONG    ilbmstops[] = {
                ID_ILBM, ID_BODY,
                TAG_DONE
                };

/* For our allocated ILBM frame */
struct  ILBMInfo  *ilbm;
UBYTE   ilbmname[256];


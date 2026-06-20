/* 2/15/88 */

/*      Now reserve some storage words          */


char    exttab[extblsz];        /* external symbols */
char    *extptr;                /* pointer to next available entry */


char    symtab[symtbsz];        /* symbol table */
char    *glbptr,*locptr;                /* ptrs to next entries */


int     wq[wqtabsz];            /* while queue */
int     *wqptr;                 /* ptr to next entry */


char    litq[litabsz];          /* literal pool */
int     litptr;                 /* ptr to next entry */


char    macq[macqsize];         /* macro string buffer */
int     macptr;                 /* and its index */


char    line[linesize];         /* parsing buffer */
char    mline[linesize];        /* temp macro buffer */
int     lptr,mptr;              /* ptrs into each */


/*      Misc storage    */


int     nxtlab,         /* next avail label # */
        litlab,         /* label # assigned to literal pool */
        cextern,        /* collecting external names flag */
        Zsp,            /* compiler relative stk ptr */
        argstk,         /* function arg sp */
        ncmp,           /* # open compound statements */
        errcnt,         /* # errors in compilation */
        errstop,        /* stop on error                        gtf 7/17/80 */
        eof,            /* set non-zero on final input eof */
        input,          /* iob # for input file */
        output,         /* iob # for output file (if any) */
        input2,         /* iob # for "include" file */
        ctext,          /* non-zero to intermix c-source */
        cmode,          /* non-zero while parsing c-code */
                        /* zero when passing assembly code */
        mainmode,
        lastst,         /* last executed statement type */
        saveout,        /* holds output ptr when diverted to console       */
                        /*                                      gtf 7/16/80 */
        fnstart,        /* line# of start of current fn.        gtf 7/2/80 */
        lineno,         /* line# in current file                gtf 7/2/80 */
        infunc,         /* "inside function" flag               gtf 7/2/80 */
        savestart,      /* copy of fnstart "    "               gtf 7/16/80 */
        saveline,       /* copy of lineno  "    "               gtf 7/16/80 */
        saveinfn;       /* copy of infunc  "    "               gtf 7/16/80 */


char   *currfn,         /* ptr to symtab entry for current fn.  gtf 7/17/80 */
       *savecurr;       /* copy of currfn for #include          gtf 7/17/80 */
char    quote[2];       /* literal string for '"' */
char    *cptr;          /* work ptr to any char buffer */
int     *iptr;          /* work ptr to any int buffer */


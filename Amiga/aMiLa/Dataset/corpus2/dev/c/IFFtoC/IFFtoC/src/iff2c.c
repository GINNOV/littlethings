#include <stdio.h>
#include <exec/types.h>
#include "iff2c.h"

VOID BMap2C(FILE *stream, UBYTE *name, UBYTE *base,
            UWORD x, UWORD y, UWORD width,
            UWORD height, UWORD depth, ULONG flags)
{
    BOOL    empty;
    UBYTE   i, temp[10], pl_pick=0x00, pl_onoff=0x00;
    UWORD   rows, bpr, d_word, d, r, b;    /* bpr = bytes per row   */
    WORD    firstprinted=-1;

    if ( (bpr=((width&7? width+8 : width)>>3))&1 ) bpr++;  /* word align   */
    rows = height;

    fprintf(stream, "\nUWORD %sData[] = \n{\n", name);
    if (flags & SPRITE_HEADER)
    {
        fprintf(stream, "   0x0000, 0x0000,%ls\n\n",
            (flags & PRINT_COMMENTS ? " /* position control */" : "") );
    }

    for(d=0; d<depth; d++)
    {

        if (flags & COMPUTE_ONOFF)
        {
            r=0;
            empty = 1;
            while (r<rows && empty)
            {
                b=0;
                while (b<bpr && empty)
                {
                    if (*(UWORD *)(base+d*rows*bpr+r*bpr+b)) empty=0;
                    b+=2;
                }
                r++;
            }
            if (!empty) pl_pick |= 1<<d;
        }
        else pl_pick |= 1<<d;
        if (!(flags & COMPUTE_ONOFF) ||
           ((flags & COMPUTE_ONOFF) && !empty))
        {
            if (firstprinted==-1) firstprinted=d;
            if (d!=firstprinted) fputc('\n', stream);
            for(r=0; r<rows; r++)
            {
                fputs("   ", stream);
                for(b=0; b<bpr; b+=2)
                {
                     d_word = *(UWORD *)(base+d*rows*bpr+r*bpr+b);
                     sprintf(temp, "0000%x\0", d_word);
                     fprintf(stream, "0x%s, ", &temp[strlen(temp)-4]);
                }
                if (flags & PRINT_COMMENTS)
                {
                    fputs("   /* ", stream);
                    for(b=0; b<bpr; b+=2)
                    {
                        d_word = *(UWORD *)(base+d*rows*bpr+r*bpr+b);
                        for(i=0xf; i!=0xff; i--)
                        {
                           if (d_word & (1<<i)) fputc('#', stream);
                           else fputc('.', stream);
                        }
                    }
                    fputs(" */", stream);
                 }
                fputc('\n', stream);
            }
        }
    }
    if (flags & SPRITE_HEADER)
    {
        fprintf(stream, "\n   0x0000, 0x0000%ls\n",
            (flags & PRINT_COMMENTS ? " /* next sprite field */" : "") );
    }
    fputs("};\n\n", stream);
    if (flags & PRINT_IMAGE)
    {
        if(flags & XYNULL)
        {
            x = y = 0;
        }
        fprintf(stream,
                "struct Image %sImage = \n{\n    %d,%d,\n    %d,%d,\n    %d,\n    %sData,\n    0x%x,0x%x,\n    NULL\n};\n",
                name, x, y, width, height, depth, name, pl_pick, pl_onoff);
    }
}


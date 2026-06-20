/**********************************************************
*                                                         *
*   gi - a DeluxePaint to C data converter                *
*                                                         *
*   Copyright (c) 1986,  Michael J. Farren                *
*   This program may be freely distributed by any means   *
*   desired, but may not be sold in any form.             *
*                                                         *
**********************************************************/

#include <stdio.h>
#undef NULL
#include <exec/types.h>

struct BitMapHeader {
   UWORD w,h;      /* raster width, height, in pixels */
   WORD  x,y;      /* pixel position for saved image  */
   UBYTE nplanes;   /* number of bit planes in source  */
   UBYTE masking;   /* masking technique         */
   UBYTE compression;   /* compression algorithm      */
   UBYTE pad1;      /* padding to justify next entry   */
   UWORD transColor;   /* transparent "color number"      */
   UBYTE xAsp, yAsp;   /* x:y aspect ratio         */
   WORD  pageW, pageH;   /* source "page" size in pixels    */
   }  bmhd;
UBYTE Cmap[96],old_cmap[96];   /*  32 color storage */
APTR *(raster_lines[400][6]);   /* pointers to raster lines in bit planes */
LONG colors_in_byte[8], colors_used[32], tran_table[32];
LONG twopowers[7] = { 1, 2, 4, 8, 16, 32, 64 };
BOOL check;

main(argc, argv)
int argc;
char *argv[];
{
   WORD bytes_per_line;    /* Number of bytes per raster line */
   FILE *i_file, *o_file;
   UBYTE *buff_pointer, *body_data;    /* storage pointers */
   UBYTE *data_pointer, *buff_pointer_save;
   LONG body_data_size, buff_size;     /* size storage */
   LONG i, j, k, temp;     /* various temporary variables */
   UBYTE tempbyte;

   /*  Check arguments, and try to open i/o files  */

   if(argc != 3) {
      printf("\nUsage -> getimage <input file> <output file>\n");
      exit(20);
   }

   if((i_file = fopen(argv[1], "r")) == 0 ) {
      printf("\nCould not open input file %s!\n", argv[1]);
      exit(20);
   }

   if((o_file = fopen(argv[2], "w")) == 0 ) {
      printf("\nCould not open output file %s!\n", argv[2]);
      exit(20);
   }

   /* Files are O.K. - skip over first 20 bytes ("FORM", length, "ILBM",
      "BMHD", length) */

   printf("\nReading input file...\n");
   if(fseek(i_file, 20L, 0)) read_error();

   /* Now, read in the BMHD structure */

   chkread(&bmhd, sizeof(struct BitMapHeader), i_file);

   /* Skip the CMAP label, and read in the color map length, then the color
      map data.  We assume that the color map length accurately reflects
      the number of bit planes, so don't bother to check the header entry
      bmhd.nplanes.  Also, all Amiga color maps will have an even number of
      entries, so don't bother padding the read out.  */

   if(fseek(i_file, 4L, 1)) read_error();    /* skip the label */
   chkread(&temp, sizeof(LONG), i_file);          /* read the length */

   i = 0;                  /* and read in the map */
   while( i < temp)
      chkread(&Cmap[i++], 1, i_file);

   /* Now, check the next header.  If it isn't "GRAB", this isn't a
      brush file, so get out  */

   chkread(&temp, sizeof(LONG), i_file);
   if(temp != ('G'<<24 | 'R'<<16 | 'A'<<8 | 'B')) {
      printf("\nThe input file is not a DeluxePaint brush file!\n");
      exit(20);
   }

   /* It's probably a brush file.  Search to find the BODY label, then
      get the body length, then read the body data into body_data[] */

   check = FALSE;
   while(check != TRUE) {
      chkread(&temp, sizeof(LONG), i_file);
      if(temp == ('B'<<24 | 'O'<<16 | 'D'<<8 | 'Y')) check = TRUE;
   }

   chkread(&body_data_size, sizeof(LONG), i_file);
   body_data = AllocMem(body_data_size, NULL);
   chkread(body_data, body_data_size, i_file);

   /* Now, start the good stuff.  First, allocate enough memory to hold
      the entire bitmap for the image. */

   bytes_per_line = (bmhd.w & 7 ? bmhd.w+8 : bmhd.w) >> 3;
   if(bytes_per_line & 1) bytes_per_line++;

   buff_size = bytes_per_line * bmhd.h * bmhd.nplanes;
   buff_pointer = AllocMem(buff_size, NULL );
   buff_pointer_save = buff_pointer;
   data_pointer = body_data;

   /* Next, go through the file line by line, bit plane by bit plane,
      and extract the image data, putting it into bitmap.  As this is
      being done, save pointers to each line in the raster_lines array. */

   for(i=0; i!=bmhd.h; i++) {         /* # of lines high */
      for(j=0; j!=bmhd.nplanes; j++) {      /* # of planes      */
         raster_lines[i][j] = buff_pointer;   /* set the pointer */
         if(bmhd.compression == 1) {

    /* if compressed, decompress */

            expand_map(bytes_per_line, buff_pointer, &data_pointer);
         }
         else {
            for(k=0; k!=bytes_per_line; k++) {
               *(buff_pointer+k) = *(data_pointer++);
            }
         }
         buff_pointer += bytes_per_line;
      }
   }

   FreeMem(body_data, body_data_size);   /* deallocate the body data block */

/* Now, go through the data, determining the different colors used  */

calc_color:

   printf("\nAnalyzing data...");
   for(i=0; i!=twopowers[bmhd.nplanes]; colors_used[i++]=0);
   for(i=0; i!=bmhd.h; i++) {
      for(j=0; j!=bmhd.w; j++) {
         colors_used[get_a_bit(i,j)] = 1;
      }
   }

/*  Show the current color register stuff */

start_over:

   printf("\nCurrent color register assignments for this picture are:\n");

   for(i=0; i!=twopowers[bmhd.nplanes]; i++) {
      if(colors_used[i]) {
         printf("%2d -> R:%2d G:%2d B:%2d      ",
            i, Cmap[i*3]>>4, Cmap[i*3+1]>>4, Cmap[i*3+2]>>4);
      }
      else {
         printf("%2d -> Not Used            ",i);
      }
      if(i&1) printf("\n");
   }

/*  Check to see if the user wants to change any of the register assignments.
    If so, do the appropriate transformations of the data base. */

   printf("\nDo you wish to change assignments (y or n)? ");
   do {
      tempbyte = getchar();
   }
   while( (tempbyte!='y')
       && (tempbyte!='Y')
       && (tempbyte!='n')
       && (tempbyte!='N'));

   if((tempbyte == 'y') || (tempbyte == 'Y')) {
      if(get_new_colors()) goto start_over; /* If invalid change, loop */
      printf("\nProcessing color change...");
      for(i=0; i!=96; old_cmap[i] = Cmap[i++]);   /* Save old colors */
      for(i=0; i!=bmhd.h; i++) {      /* lines */
         for(j=0; j!=bmhd.w; j++) {      /* bits */
            temp = get_a_bit(i,j);
            if(tran_table[temp]!=-1) {
               put_a_bit(i,j,tran_table[temp]);
               for(k=0; k!=3; k++) {            /* swap colors */
                  Cmap[tran_table[temp]*3+k] = old_cmap[temp*3+k];
               }
            }
         }
      }
      goto calc_color;    /* show the new arrangement */
   }

/* Now, write the data to the output file, color map first, then data,
   plane by plane, line by line */

   printf("\nWriting output file...");

/* Add #include, for compiler */

   fprintf(o_file,"#include <exec/types.h>\n");

/* Output a few statistics */

   fprintf(o_file, "/*   Image %s  \n",argv[1]);
   fprintf(o_file, "     Width:    %d\n",bmhd.w);
   fprintf(o_file, "     Height:   %d\n",bmhd.h);
   fprintf(o_file, "     Depth:    %d  */\n",bmhd.nplanes);

/* Start with the color map */

   fprintf(o_file, "/* Color Map */\n\n");
   fprintf(o_file, "USHORT map[] = {\n");
   for(i=0; i!=twopowers[bmhd.nplanes]; i++) {
      fprintf(o_file, "   ");
      make_word((Cmap[i*3]<<4)+Cmap[i*3+1]+(Cmap[i*3+2]>>4), o_file);
      if(i!=twopowers[bmhd.nplanes]-1) fprintf(o_file, ",");
      if(colors_used[i]) fprintf(o_file, "    /* USED */");
      fprintf(o_file, "\n");
   }
   fprintf(o_file, "};\n\n");

/* Now, do the data */

   fprintf(o_file, "/* Image Data */\n\n");
   fprintf(o_file, "UWORD %s[%d] = {\n", argv[1], buff_size/2);
   for(i=0; i!=bmhd.nplanes; i++) {
      fprintf(o_file, "/* Bit Plane #%d */\n\n", i);
      for(j=0; j!=bmhd.h; j++) {
         fprintf(o_file, "   ");
         buff_pointer = raster_lines[j][i];
         for(k=0; k<bytes_per_line; ) {
            tempbyte = *(buff_pointer+(k++));
            make_word((tempbyte << 8) | *(buff_pointer+(k++)), o_file);
            fprintf(o_file, ",");
         }
         fprintf(o_file, "\n");
      }
      fprintf(o_file, "\n");
   }
   fseek(o_file, -3, 1);     /* back up to wipe out the last comma */
   fprintf(o_file, "\n};\n");

/* Close up, clean up, and get out */

   fclose(o_file);
   fclose(i_file);
   printf("\n");
   FreeMem(buff_pointer_save, buff_size);
}

/*  read_error - called if a read error occured */

read_error()
{
   printf("\nRead error in input file, aborting\n");
   exit(20);
}

/* chkread - reads from input file, checking for errors */

chkread(ptr, size, fd)
APTR *ptr;
WORD size;
FILE *fd;
{
   WORD readin;
   readin = fread(ptr, size, 1, fd);
   if(readin != 1) read_error();
}

/* expand_map - decompresses data compressed with the byte_run encoding
                scheme described in the IFF document.  A signed byte, x,
                is read from the input block.  If the signed value of x
                is negative, but not -128 ( 0x80 ), the next byte is read
                and is placed in the output block (-x+1) times.  If the
                signed value is positive, the next (x+1) bytes are copied
                directly to the output block.  If the signed value is -128,
                no operation is performed.
*/


expand_map(length, pointer, data_pointer)
WORD length;
UBYTE *pointer;
UBYTE **data_pointer;
{

   WORD minus128 = -128;
   WORD temp;
   BYTE tempbyte;
   UBYTE tempubyte;

   while( length > 0 )   {
      tempbyte = *((*data_pointer)++);
      temp = tempbyte;
      if (temp >= 0) {
         temp += 1;
         length-=temp;
         do {
            *(pointer++) = *((*data_pointer)++);
         }
         while (--temp > 0);
      }
      else if (temp != minus128) {
         temp = (-temp) + 1;
         length -= temp;
         tempubyte = *((*data_pointer)++);
         do {
            *(pointer++) = tempubyte;
         }
         while (--temp > 0);
      }
   }
}

/* get_a_bit - returns the color value of the bit at location x,y in the
               image.
*/

get_a_bit(y, x)
LONG y, x;
{
   LONG xbyte, xbit,i;
   UBYTE tempbyte, color;
   UBYTE *pointer;

   color = 0;                         /* start with no color */
   xbyte =x>>3;                       /* xbyte = the byte location of x */
   xbit = (1<<(x&7));                 /* xbit = the mask for the bit */
   for(i=0; i!=bmhd.nplanes; i++) {   /* do all the planes */
      pointer = raster_lines[y][i];          /* get the base address */
      tempbyte = *(pointer + xbyte);         /* get the proper byte  */
      if(tempbyte & xbit) color |= (1 << i); /* OR in the color bit  */
   }
   return color;
}

/* put_a_bit - sets a given bit to a given color */

put_a_bit(y, x, color)
LONG y, x, color;
{
   LONG xbyte, xbit, i;
   UBYTE *pointer;
   UBYTE tempbyte;

   for(i=0; i!=bmhd.nplanes; i++) {
      xbyte = x>>3;
      xbit = (1 << (x & 7));
      pointer = raster_lines[y][i];
      tempbyte = *(pointer + xbyte);   /* get the appropriate byte */
      tempbyte &= 0xff-xbit;           /* mask off the proper bit  */
      if(color & twopowers[i]) {       /* if the color bit is set, */
         tempbyte |= xbit;             /* set the bit in the byte  */
      }
      *(pointer + xbyte) = tempbyte;   /* save the modified byte   */
   }
}

/* get_new_colors - get the users choices for register assignments */

get_new_colors()
{
   int i,j;

   for(i=0; i!=twopowers[bmhd.nplanes]; tran_table[i++]=-1); /* reset */
   for(i=1; i!=twopowers[bmhd.nplanes]; i++) {
      if(colors_used[i]) {     /* for each color used in the original */
getnew:
         printf("\nOld color register %2d (R:%2d G:%2d B:%2d) new number:",
            i, Cmap[i*3]>>4, Cmap[i*3+1]>>4, Cmap[i*3+2]>>4);
         scanf("%d", &j);
         if((j<1) || (j>=twopowers[bmhd.nplanes])) {
            printf("\nRegister number must be greater than zero, and less than %2d.",
               twopowers[bmhd.nplanes]);
            printf("\nTry again.");
            goto getnew;
         }
         tran_table[i] = j;
      }
   }

/* Check the translation table for duplicated register assignments. */

   for(i=1; i!=twopowers[bmhd.nplanes]-1; i++) {
      for(j=i+1; j!=twopowers[bmhd.nplanes]; j++) {
         if((tran_table[i]==-1) || (tran_table[j]==-1)) continue;
         if(tran_table[i] == tran_table[j]) {
            printf("\nDuplicate color register assignment - try again.");
            return -1;
         }
      }
   }
   return 0;
}

/* make_word - outputs a string representing a four-digit hex number */

make_word(num, fp)
UWORD num;
FILE *fp;
{
   char temp[10];

   sprintf(temp, "0000%x\0", num);
   fprintf(fp, "0x%s", &temp[strlen(temp)-4]);
}


/****h* GetImage.c [1.0] ****************************************
*
* NAME
*    GetImage.c
*
* DESCRIPTION
*    A DeluxePaint Brush to C data converter (formerly gi.c)
*
* SYNOPSIS
*    GetImage brushfile [outputfile] <cr>
*
* COPYRIGHT
*    (C) 1986 by Michael J. Farren
*
* NOTES
*    With the appropriate modifications to readFileHeader(),
*    this program can be made to read in regular ILBM files as
*    well as brushes (provided you have enough CHIP memory for 
*    large pictures!).
*
*    exit() was removed from this program because using it
*    allows a programmer to start leaning on it as a crutch to
*    take care of cleaning up open files, etc.  It's far better
*    & more readable to make the end of main() the only valid
*    exit point of a program.
*
*    In case a future user of this program wants to use Input
*    redirection, all user instructions now go to stderr, via
*    fprintf() (JTS).
*
*    This Program was heavily modified/refactored to be more
*    readable & maintainable by Jim Steichen (JTS).  The original
*    source file had virtually no whitespace & main() was doing
*    everything.  It's much more practical to separate out
*    distinct functions from main() & call them.  The overhead 
*    of doing function calls is insignificant compared to the 
*    amount of time spent trying to figure out what a program is
*    doing!
*
*    He can be reached at jimbot@frontiernet.net
*
*    $VER: GetImage.c V1.0 (09-Jan-2004) By J.T. Steichen
*
* TO DO
*    Localize the source file.
*
*****************************************************************
*
*/

#include <stdio.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>    // Contact JTS for this header (if not present)

#include <intuition/intuition.h>

#define NUM_COLORS 256

// This struct is probably in an IFF header file somewhere:

struct BitMapHeader {

   UWORD w, h;                  // raster width, height, in pixels
   WORD  x, y;                  // pixel position for saved image
   UBYTE nplanes;               // number of bit planes in source
   UBYTE masking;               // masking technique
   UBYTE compression;           // compression algorithm
   UBYTE pad1;                  // padding to justify next entry
   UWORD transColor;            // transparent "color number"
   UBYTE xAsp, yAsp;            // x:y aspect ratio
   WORD  pageW, pageH;          // source "page" size in pixels

} bmhd = { 0, };

PRIVATE UBYTE Cmap[     3 * NUM_COLORS ] = { 0, }; // (R,G,B) * NUM_COLORS
PRIVATE UBYTE old_cmap[ 3 * NUM_COLORS ] = { 0, }; // color storage

// Used to be APTR *, which is redundant: 

PRIVATE APTR  raster_lines[400][6];    // pointers to raster lines in bit planes

PRIVATE LONG  colors_in_byte[ 8  ] = { 0, };

PRIVATE LONG  colors_used[ NUM_COLORS ] = { 0, };
PRIVATE LONG  tran_table[  NUM_COLORS ] = { 0, };

PRIVATE LONG  powers_2[] = { 1, 2, 4, 8, 16, 32, 64, 128, 256 };

PRIVATE WORD  planes_used[8] = { 0, };
PRIVATE UBYTE PlanePik       = 0;
PRIVATE int   num_planes     = 0;

// You should always have a version string in an executable.

PRIVATE char v[] = "\0$VER: GetImage V1.0 " __AMIGADATE__ " by Michael J. Farren (JTS)\0";

// --------------------------------------------------------------

// make_word - outputs a string representing a 4-digit hex number

PRIVATE void make_word( UWORD num, FILE *fp )
{
   fprintf( fp, "0x%04LX", num );
   
   return;
}

//  read_error - called if a read error occured

PRIVATE void read_error( void )
{
   fprintf( stderr, "\nRead error in input file, aborting\n" );

   return;
}

// chkread - reads from input file, checking for errors

PRIVATE int chkread( APTR ptr, WORD numBytes, FILE *fd ) // used to be APTR *
{
   WORD readChk = -1;
   int  rval    = RETURN_OK;
   
   readChk = fread( ptr, numBytes, 1, fd );

   if (readChk != 1)
      {
      rval = IoErr();
      
      read_error();
      }
      
   return( rval );
}

/* expand_map - decompresses data compressed with the byte_run encoding
** scheme described in the IFF document.  A signed byte, x,
** is read from the input block.  If the signed value of x
** is negative, but not -128 ( 0x80 ), the next byte is read
** and is placed in the output block (-x+1) times.  If the
** signed value is positive, the next (x+1) bytes are copied
** directly to the output block.  If the signed value is -128,
** no operation is performed.
*/

// But why the extra layer of Indirection?? (JTS)

PRIVATE void expand_map( WORD length, UBYTE *pointer, UBYTE **data_pointer )
{
   WORD  minus128  = -128;
   WORD  temp      = 0;
   BYTE  tempbyte  = 0;
   UBYTE tempubyte = 0;

   while (length > 0)
      {
      tempbyte = *((*data_pointer)++);
      temp     = tempbyte;

      if (temp >= 0)
         {
         temp   += 1;
         length -= temp;

         do {
            *(pointer++) = *((*data_pointer)++);

            } while (--temp > 0);
         }
      else if (temp != minus128)
         {
         temp      = (-temp) + 1;
         length   -= temp;
         tempubyte = *((*data_pointer)++);

         do {
            *(pointer++) = tempubyte;

            } while (--temp > 0);
         }
      }

   return;
}

// Determine which bit-planes are not used and set-up PlanePick value

PRIVATE void setupViaPlanePick( WORD bpl ) // bytes_per_line
{
   UBYTE *bodyData;
   int    i, j, k;

   // SAS-C Compiler can take care of this in the definition:

   for ( i = 0; i < bmhd.nplanes; i++)
      planes_used[i] = 0;

   // Now determine if bit plane is all 0's

   for (i = 0; i < bmhd.nplanes; i++)      // Traverse via Depth
      {
      for (j = 0; j < bmhd.h; j++)         // Traverse Vertically
         {
         bodyData = raster_lines[j][i];

         for (k = 0; k < bpl; k++)         // Traverse Horizontally
            planes_used[i] |= *(bodyData++);
         }
      }

   // Set-up PlanePick value and number of planes actually used

   num_planes = 0;
   PlanePik   = 0; // Zero PlanePick variable
   
   for (i = bmhd.nplanes - 1; i >= 0; i--)
      {
      PlanePik = (PlanePik << 1);

      if (planes_used[i] == TRUE)
         {
         PlanePik   += 1;

         num_planes += 1;
         }
      }

   return;
}

/* get_a_bit - returns the color value of the bit at location x,y in the
** image.
*/

PRIVATE int get_a_bit( LONG y, LONG x )
{
   UBYTE *pointer;
   UBYTE  tempbyte, color;
   LONG   xbyte, xbit, i;

   color = 0;                // start with no color
   xbyte = x >> 3;           // xbyte = the byte location of x
   xbit  = (1 << (x & 7));   // xbit = the mask for the bit

   for (i = 0; i < bmhd.nplanes; i++)
      {
      pointer  = raster_lines[y][i]; // get the base address

      tempbyte = *(pointer + xbyte); // get the proper byte

      if ((tempbyte & xbit) != 0)
         color |= (1 << i);          // OR in the color bit
      }

   return color;
}

/*  These Three commented-out functions are NOT used anywhere! ==========

// put_a_bit - sets a given bit to a given color

PRIVATE void put_a_bit( LONG y, LONG x, LONG color )
{
   UBYTE *pointer;
   UBYTE  tempbyte;
   LONG   xbyte, xbit, i;

   for (i = 0; i < bmhd.nplanes; i++)
      {
      xbyte = x >> 3;
      xbit  = (1 << (x & 7));

      pointer = raster_lines[y][i];

      tempbyte  = *(pointer + xbyte); // get the appropriate byte
      tempbyte &= 0xFF - xbit;        // mask off the proper bit

      if ((color & powers_2[i]) != 0)
         {                   

         tempbyte |= xbit; // if the color bit is set, set the bit in the byte
         }
 
      *(pointer + xbyte) = tempbyte;  // save the modified byte
      }

   return;
}

PRIVATE int getColorNumberFromUser( void )
{
   char temp[10] = "";
   int  rval     = 0;

   // Never use scanf(), a User can easily choke & hangup scanf()!

   fgets( &temp[0], 6, stdin );
   
   if (strlen( temp ) > 0)
      {
      rval = atoi( &temp[0] );
      }
   
   // We'll bounce back to this function if rval is out of range.   

   return( rval );
}

// get_new_colors - get the users choices for register assignments

PRIVATE int get_new_colors( void )
{
   int i, j;

   for (i = 0; i < powers_2[bmhd.nplanes]; tran_table[i++] = -1)
      ;  // reset

   for (i = 1; i <= powers_2[bmhd.nplanes]; i++)
      {
      if (colors_used[i] != FALSE)
         {                   
         int red, green, blue;
         
         // for each color used in the original, remove duplications
getnew:
         red   = (Cmap[ i * 3     ] & 0xF0) >> 4;  
         green = (Cmap[ i * 3 + 1 ] & 0xF0) >> 4;  
         blue  = (Cmap[ i * 3 + 2 ] & 0xF0) >> 4;  

         fprintf( stderr, "\nOld color register %03d (R:%02d G:%02d B:%02d)"
                          " enter new number:",
                          i, red, green, blue
                );

         j = getColorNumberFromUser(); // scanf( "%d", &j ); // Aaarrgghh!!

         if ((j < 1) || (j >= powers_2[bmhd.nplanes]))
            {
            fprintf( stderr, "\nRegister number must > 0, and <= %03d.",
                              powers_2[ bmhd.nplanes ] 
                   );

            fprintf( stderr, "\nTry again." );

            goto getnew;
            }

         tran_table[i] = j;
         }
      }

   // Check the translation table for duplicated register assignments.

   for (i = 1; i < powers_2[bmhd.nplanes] - 1; i++)
      {
      for (j = i + 1; j < powers_2[bmhd.nplanes]; j++)
         {
         if ((tran_table[i] == -1) || (tran_table[j] == -1))
            continue;

         if (tran_table[i] == tran_table[j])
            {
            fprintf( stderr, "\nDuplicate color register assignment - try again." );

            return( -1 );
            }
         }
      }

   return( 0 );
}
** =========================================================================
*/

/****i* writeImageStruct() [1.0] ***********************************
*
* NOTES
*    Originally, the image struct was named with the name variable
*    However, the name variable can contain illegal variable
*    characters in it, such as '.', or '&', which would necessitate
*    filtering the name variable & removing illegal characters.
*    If you're going to use this program to create more than
*    one Image struct (& the corresponding imageData[]), then
*    you'll have to hand-edit the output of this function, as
*    well as the output from the printImageData() function.
******************************************************************** 
*
*/

PRIVATE void writeImageStruct( FILE *o_file, char *name )
{
   /* Large images (> near address representation) have to have
   ** the __far keyword present, os we may as well use it always:
   */
   fprintf( o_file, "PUBLIC __far struct Image myImage = {\n\n" );  // %s_image = {\n\n", name );
   fprintf( o_file, "   0, 0,            // LeftEdge, TopEdge\n" );
   fprintf( o_file, "   %d, %d, %d,       // Width, Height, Depth\n", 
                        bmhd.w, bmhd.h, bmhd.nplanes 
          );

   fprintf( o_file, "   &imageData[0],\n" ); //&%s_Data[0], // Ptr to Image data\n", name );

   fprintf( o_file, "   0x%02LX, 0,         // PlanePick, PlaneOnOff\n", PlanePik );
   fprintf( o_file, "   NULL,            // NextImage pointer\n};\n\n" );
   
   fprintf( o_file, "/* ------------- ENB of %s file! --------------- */", name );
   
   return;
}

/****i* readFileHeader() [1.0] ***************************************
*
* NAME
*    readFileHeader()
*
* NOTES
*    This should be done using iffparse.library functions, which might
*    simplify things.  At least it would be more flexible (JTS).
**********************************************************************
*
*/

PRIVATE int readFileHeader( FILE *i_file )
{
   BOOL check = FALSE;     // Change name to foundBODY later
   int  temp  = -1;
   int  rval  = RETURN_OK;
   
   // Skip over 1st 20 bytes ("FORM", length, "ILBM", "BMHD", length)

   if (fseek( i_file, 20L, 0 ) != 0)
      {
      read_error();
      
      rval = -1;
      
      goto readFileHeaderExit;
      }

   // Now, read in the BMHD structure

   if (chkread( &bmhd, sizeof( struct BitMapHeader ), i_file ) != RETURN_OK)
      {
      rval = -2;
      
      goto readFileHeaderExit;
      }

   /* Skip the CMAP label, and read in the color map length, then the color
   ** map data.  We assume that the color map length accurately reflects
   ** the number of bit planes, so don't bother to check the header entry
   ** bmhd.nplanes.  Also, all Amiga color maps will have an even number of
   ** entries, so don't bother padding the read out.  
   */

   if (fseek( i_file, 4L, 1 ) != 0)
      {
      read_error();           // skipping the CMAP label failed!

      rval = -3;
           
      goto readFileHeaderExit;
      }
    
   if (chkread( &temp, sizeof( LONG ), i_file ) != RETURN_OK) // read the CMAP length
      {
      rval = -4;
      
      goto readFileHeaderExit;
      }

   fprintf( stderr, "# of Colors in CMAP is %d\n", temp / 3 );
   
   // and read in the Color map

   if (chkread( &Cmap[0], temp, i_file ) != RETURN_OK) // Slurp the entire CMAP
      {
      rval = -5;
         
      goto readFileHeaderExit;
      }

   /* Now, check the next header.  If it isn't "GRAB", this isn't a
   ** brush file, so get out  
   */

   if (chkread( &temp, sizeof( LONG ), i_file ) != RETURN_OK)
      {
      rval = -6;
      
      goto readFileHeaderExit;
      }
   
   if (temp != ('G' << 24 | 'R' << 16 | 'A' << 8 | 'B'))
      {
      fprintf( stderr, "\nThe input file is not a DeluxePaint brush file!\n" );
      
      rval = -7; // IoErr();
      
      goto readFileHeaderExit;
      }

   /* It's probably a brush file.  Search for the BODY label, then get
   ** the body length,then read the body data into body_data[] 
   */

   check = FALSE;

   while (check != TRUE)
      {
      if (chkread( &temp, sizeof( LONG ), i_file ) != RETURN_OK)
         {
         rval = -8;
         
         goto readFileHeaderExit;
         }
 
      if (temp == ('B' << 24 | 'O' << 16 | 'D' << 8 | 'Y'))
         check = TRUE;
      }

   if (chkread( &rval, sizeof( LONG ), i_file ) != RETURN_OK)
      {
      rval = -9;
      }

readFileHeaderExit:

   return( rval );
}

PRIVATE void writeFileHeader( FILE *o_file, char *name )
{
   // Put #include statements in source file.

   fprintf( o_file, "/* ------- Automatically generated by GetImage! -------- */\n\n" );

   fprintf( o_file, "#ifndef    EXEC_TYPES_H\n"  );
   fprintf( o_file, "# include <exec/types.h>\n" );
   fprintf( o_file, "#endif\n\n\n" );
   
   // Output a few statistics

   fprintf( o_file, "/*   Image %s\n", name );
   fprintf( o_file, "**          Width:    %d\n", bmhd.w );
   fprintf( o_file, "**         Height:    %d\n", bmhd.h );
   fprintf( o_file, "**          Depth:    %d\n", bmhd.nplanes );
   fprintf( o_file, "**     TransColor:    %d\n", bmhd.transColor );
   fprintf( o_file, "*/\n\n" );

   return;
}

PRIVATE void writeColorMap( FILE *o_file )
{
   UWORD color;
   UBYTE red, green, blue;
   int   i;

   fprintf( o_file, "// Color Map: -------------------\n\n" );

   fprintf( o_file, "UWORD Colormap[ %d ] = {\n\n", powers_2[bmhd.nplanes] );

   for (i = 0; i < powers_2[bmhd.nplanes]; i++)
      {
      fprintf( o_file, "   " );
      
      red   = Cmap[ i * 3     ] & 0xF0;
      green = Cmap[ i * 3 + 1 ] & 0xF0;
      blue  = Cmap[ i * 3 + 2 ] & 0xF0;
      
      color = (((red << 4) + green + (blue >> 4)) & 0x0FFF);
      
      make_word( color, o_file );

      /* In case the Colormap[] is not completely filled due to duplicate
      ** RGB values in the map, there has to be a comma after the last
      ** valid table entry so that the SAS-C compiler will initialize
      ** the rest of the array with zeroes!
      */
      if (i < powers_2[ bmhd.nplanes ]) // - 1)
         fprintf( o_file, "," );

      if (colors_used[i] == TRUE)
         fprintf( o_file, "  // USED!" );

      fprintf( o_file, "\n" );
      }

   fprintf( o_file, "};\n\n" );

   return;
}

PRIVATE void extractImageDataToBuffer( UBYTE *buff_pointer, 
                                       UBYTE *data_pointer, 
                                       WORD   bytes_per_line 
                                     )
{   
   int i, j, k;
   
   /* Go through the file line by line, bit plane by bit plane,
   ** and extract the image data, putting it into bitmap.  As this is
   ** being done, save pointers to each line in the raster_lines array. 
   */

   for (i = 0; i < bmhd.h; i++)              // Traverse Vertically
      {
      for (j = 0; j < bmhd.nplanes; j++)     // Traverse via Depth
         {
         raster_lines[i][j] = buff_pointer;  // set the pointer

         if (bmhd.compression == TRUE)
            {
            // De-compress data
            expand_map( bytes_per_line, buff_pointer, &data_pointer );
            }
         else
            {
            for (k = 0; k < bytes_per_line; k++) // Traverse Horizontally
               {
               *(buff_pointer + k) = *(data_pointer++);
               }
            }

         buff_pointer += bytes_per_line;
         }
      }

   return;
}

/****i* printImageData() [1.0] *************************************
*
* NOTES
*    Originally, the imageData was named with the name variable
*    However, the name variable can contain illegal variable
*    characters in it, such as '.', or '&', which would necessitate
*    filtering the name variable & removing illegal characters.
*    If you're going to use this program to create more than
*    one Image struct (& the corresponding imageData[]), then
*    you'll have to hand-edit the output of this function, as
*    well as the output from the writeImageStruct() function.
******************************************************************** 
*
*/

PRIVATE void writeImageData( FILE  *o_file, 
                             UBYTE *imageBuffer, 
                             char  *name, 
                             WORD   bytes_per_line 
                           )
{
   UBYTE  tempbyte;
   int    i, j, k;

   /* The actual Image data has to reside in CHIP memory, so use
   ** the SAS-C __chip memory type specifier:
   */   
   fprintf( o_file, "// Image Data: -----------------\n\n" );

   fprintf( o_file, "UWORD __chip imageData[] = {\n\n" ); // %s_Data[] = {\n\n", name );

   for (i = 0; i < bmhd.nplanes; i++)        // Traverse via Depth
      {
      fprintf( o_file, "   // Bit Plane #%d \n\n", i );

      for (j = 0; j < bmhd.h; j++)           // Traverse Vertically
         { 
         fprintf( o_file, "   " );

         imageBuffer = raster_lines[j][i];

         for (k = 0; k < bytes_per_line;  )  // Traverse Horizontally
            {
            tempbyte = *(imageBuffer + (k++));

            make_word( (tempbyte << 8) | *(imageBuffer + (k++)), o_file );

            fprintf( o_file, "," );
            }

         fprintf( o_file, "\n" );
         }

      fprintf( o_file, "\n" );
      }

   fseek( o_file, -3, 1 ); // back up to wipe out the last comma

   fprintf( o_file, "\n};\n\n" );

   return;
}

// Go through the data, determining the different colors used

PRIVATE void analyzeColorData( void )
{
   int i, j;
   
   fprintf( stderr, "\nAnalyzing data..." );
 
   // The Compiler does this if you initialize the definition!

   for (i = 0; i < powers_2[ bmhd.nplanes ]; colors_used[i] = FALSE, i++)
      ;

   // Setup the colors_used[] array:

   for (i = 0; i < bmhd.h; i++)
      {
      for (j = 0; j < bmhd.w; j++)
         {
         colors_used[ get_a_bit( i, j ) ] = TRUE;
         }
      }

   //  Show the current color register stuff

   fprintf( stderr, "\nCurrent color register assignments for this picture are:\n" );

   for (i = 0; i < powers_2[bmhd.nplanes]; i++)
      {
      if (colors_used[i] == TRUE)
         {
         int red, green, blue;
         
         red   = (Cmap[ i * 3     ] & 0xF0) >> 4;
         green = (Cmap[ i * 3 + 1 ] & 0xF0) >> 4;
         blue  = (Cmap[ i * 3 + 2 ] & 0xF0) >> 4;
         
         fprintf( stderr, "%03d -> RGB (%02d,%02d,%02d)      ",
                          i, red, green, blue
                );
         }
      else
         {
         fprintf( stderr, "%03d -> NOT USED               ", i );
         }

      if (i & 1)
         fprintf( stderr, "\n" );
      }

   return;
}

PRIVATE LONG computeBufferSize( int bytes_per_line )
{
   LONG buff_size = bytes_per_line * bmhd.h * bmhd.nplanes;

   return( buff_size );
}
       
// -------------------------------------------------------------------

PUBLIC int main( int argc, char **argv )
{
   FILE  *i_file, *o_file;

   UBYTE *buff_pointer, *body_data;          // storage pointers
   UBYTE *data_pointer, *buff_pointer_save;

   LONG   body_data_size, buff_size;         // size storage
   WORD   bytes_per_line;                    // # of bytes per raster line

   int    rval = RETURN_OK;

   //  Check arguments, and try to open i/o files

   if (argc > 3 || argc < 2)
      {
      fprintf( stderr, "\nUsage -> %s <input file> [output file]\n", argv[0] );

      rval = RETURN_ERROR;
      
      goto exitProgram;
      }

   if ((i_file = fopen( argv[1], "r" )) == 0)
      {
      fprintf( stderr, "\nCould not open input file %s!\n", argv[1] );

      rval = IoErr();
      
      goto exitProgram;
      }

   if (argc == 2)
      {
      char samename[256] = "";
      
      strncpy( samename, argv[1], 253 );
      strcat(  samename, ".c"         );

      if ((o_file = fopen( samename, "w" )) == 0)
         {
         fprintf( stderr, "\nCould not open output file %s!\n", samename );
         
         rval = IoErr();
         
         fclose( i_file );
         
         goto exitProgram;
         }
      }
   else if ((o_file = fopen( argv[2], "w" )) == 0)
      {
      fprintf( stderr, "\nCould not open output file %s!\n", argv[2] );
      
      rval = IoErr();
      
      fclose( i_file );
      
      goto exitProgram;
      }

   fprintf( stderr, "\nReading input file...\n" );

   if ((body_data_size = readFileHeader( i_file )) < 0)
      {
      goto fileCloseExit; // Error already reported
      }

   if ((body_data = AllocVec( body_data_size, MEMF_CLEAR | MEMF_ANY )) == NULL)
      {
      fprintf( stderr, "Ran out of Memory in %s\n", argv[0] );
      
      rval = ERROR_NO_FREE_STORE;
      
      goto fileCloseExit;
      }

   if ((rval = chkread( body_data, body_data_size, i_file )) != RETURN_OK)
      {
      FreeVec( body_data );
      
      goto fileCloseExit;
      }

   // Is this to round up to a Nybble or what?? (JTS)

   bytes_per_line = (((bmhd.w & 7) != 0) ? bmhd.w + 8 : bmhd.w) >> 3;

   if ((bytes_per_line & 1) != 0)
      bytes_per_line++;

   buff_size = computeBufferSize( bytes_per_line );
   
   /* Now, start the good stuff.  First, allocate enough memory to hold
   ** the entire bitmap for the image. 
   */

   buff_pointer = AllocVec( buff_size, MEMF_CLEAR | MEMF_ANY );
   
   buff_pointer_save = buff_pointer;
   data_pointer      = body_data;

   extractImageDataToBuffer( buff_pointer, data_pointer, bytes_per_line );

   setupViaPlanePick( bytes_per_line );

   FreeVec( body_data ); // Done with body_data, throw it back to System.
   body_data = NULL;

   analyzeColorData();

   /* Now, write the data to the output file, color map first, then data,
   ** plane by plane, line by line 
   */

   fprintf( stderr, "\nWriting output file..." );

   writeFileHeader(  o_file, argv[1]                               );
   writeColorMap(    o_file                                        );
   writeImageData(   o_file, buff_pointer, argv[1], bytes_per_line );
   writeImageStruct( o_file, argv[1]                               );

   // Close up, clean up, and get out

   FreeVec( buff_pointer_save );

fileCloseExit:

   if (o_file != NULL)
      fclose( o_file );
   
   if (i_file != NULL)
      fclose( i_file );

   fprintf( stderr, "\n" );

exitProgram:
   
   return( rval );
}

/* ---------------------- END of GetImage.c file! -------------------- */

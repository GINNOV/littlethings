/************************************************************************/
/* cmp, compare 2 files and prints the position of differing bytes.	*/
/* 03/02/1997 by Nicolas Pomarede, pomarede@isty-info.uvsq.fr		*/
/*									*/
/* v1.0		03/02/97	OK					*/
/*									*/
/* Usage: cmp [-q] file1 file2						*/
/*	-q : quiet, turns display off.					*/
/* return value:	 0 if files are the same			*/
/*			 5 if files are different			*/
/*			10 if an error occured				*/
/* If files have different lengths, only the common part is checked.	*/
/* Files are read in 2 buffer of BUFFERSIZE (=20000) bytes.		*/
/************************************************************************/


#include <stdio.h>
#include <stdlib.h>


#define		TRUE	1
#define		FALSE	0

						/* return codes */
#define		SAME_CODE	0		/* AmigaDOS OK */
#define		DIFF_CODE	5		/* AmigaDOS WARN */
#define		ERROR_CODE	10		/* AmigaDOS ERROR */

#define		BUFFERSIZE	20000		/* in bytes */


FILE		*File1 , *File2;
char		*File1Name , *File2Name;
int		File1Size , File2Size , CmpSize;

char		*Buffer1 , *Buffer2;

int		NbDiff;
int		SysError = FALSE;	/* FALSE=normal exit */
int		Quiet = FALSE;



/*----------------------------------------------------------------------*/
/* Function to free everything when exiting (error, ctrl-c, ...)	*/
/*----------------------------------------------------------------------*/

void	MyExit ( void )
{
  if ( !SysError && !Quiet)
    if ( NbDiff )
      printf ( "\n%d differences between %s and %s\n\n" , NbDiff , File1Name , File2Name );
    else
      printf ( "\n%s and %s are identical\n\n" , File1Name , File2Name );

  if ( File1 )		fclose ( File1 );
  if ( File2 )		fclose ( File2 );
  if ( Buffer1 )	free ( Buffer1 );
  if ( Buffer2 )	free ( Buffer2 );
}



/*----------------------------------------------------------------------*/
/* Main function. Opens files, allocs buffers, read/compare chunks.	*/
/*----------------------------------------------------------------------*/

int	main ( int argc , char ** argv )
{
  int		Index = 1;		/* filenames in argv */

  int		InLen;			/* bytes read in buffers */
  int		Pos;			/* current pos in files */
  char		*a , *b;
  int		i;


  if ( argv[1][0] == '-' && argv[1][1] == 'q' )
    {
      Quiet = TRUE;
      Index++;
    }

  if ( argc - Index != 2 )
    {
      printf ( "Usage: %s [-q] file1 file2\n", argv[0] );
      printf ( " -q = quiet, only returns error code.\n" );
      printf ( "Returns 0 if OK, 5 if files are different, 10 if error.\n" );
      printf ( "v1.0 © 03/02/1997 by Nicolas Pomarede\n" );
      return ERROR_CODE;
    }

  if ( atexit ( MyExit ) )
    {
      printf ( "Can't install exit function\n" );
      return ERROR_CODE;
    }


  File1Name = argv[ Index++ ];
  File2Name = argv[ Index ];

  File1 = fopen ( File1Name , "rb" );
  if ( !File1 )
    {
      printf ( "Error opening %s\n" , File1Name );
      SysError = TRUE;
      exit ( ERROR_CODE );
    }

  File2 = fopen ( File2Name , "rb" );
  if ( !File2 )
    {
      printf ( "Error opening %s\n" , File2Name );
      SysError = TRUE;
      exit ( ERROR_CODE );
    }

  Buffer1 = (char *) malloc ( BUFFERSIZE );
  if ( !Buffer1 )
    {
      printf ( "Error allocating %d bytes\n" , BUFFERSIZE );
      SysError = TRUE;
      exit ( ERROR_CODE );
    }

  Buffer2 = (char *) malloc ( BUFFERSIZE );
  if ( !Buffer2 )
    {
      printf ( "Error allocating %d bytes\n" , BUFFERSIZE );
      SysError = TRUE;
      exit ( ERROR_CODE );
    }

  fseek ( File1 , 0 , SEEK_END );
  File1Size = ftell ( File1 );
  rewind ( File1 );

  fseek ( File2 , 0 , SEEK_END );
  File2Size = ftell ( File2 );
  rewind ( File2 );

  if ( File1Size != File2Size && !Quiet )
    printf ( "Warning, different file lengths\n" );
  CmpSize = ( File1Size < File2Size ? File1Size : File2Size );

/*  printf ( "size1=%d size2=%d\n" , File1Size , File2Size );
*/

  Pos = 0;
  while ( CmpSize > 0 )
    {
      if ( CmpSize > BUFFERSIZE )
        InLen = BUFFERSIZE;
      else
        InLen = CmpSize;

      fread ( Buffer1 , 1 , InLen , File1 );
      fread ( Buffer2 , 1 , InLen , File2 );
      if ( ferror ( File1 ) || ferror ( File2 ) )
	{
	  printf ( "Error reading\n" );
	  SysError = TRUE;
	  exit ( ERROR_CODE );
	}

      a = Buffer1;
      b = Buffer2;
      for ( i=0 ; i < InLen ; i++)
	{
	  if ( *a++ != *b++ )
	    {
	      NbDiff++;
	      if ( !Quiet )		/* 11 positions per line */
		printf ( "%06x%s" , Pos , (NbDiff-1)%11==10?"\n":" " );
	    }
	  Pos++;
	}

      CmpSize -= InLen;	  
    }	  


  if ( NbDiff )
    exit ( DIFF_CODE );
  else
    exit ( SAME_CODE );
}


/************************************************************************/
/*				END OF cmp.c				*/
/************************************************************************/

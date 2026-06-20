/* Example1                                                             */
/* This program collects ten integer values from the user, and saves    */
/* them in a file ("HighScore.dat") on the RAM disk. The memory is then */
/* cleared, and the file cursor is moved to the beginning of the file.  */
/* The file is then loaded into the memory again, and printed out.      */



#include <libraries/dos.h>


void main();

void main()
{
  struct FileHandle *file_handle;
  int highscore[ 10 ];
  long bytes_written;
  long bytes_read;
  int loop;  



  /* Let the user enter ten integer values: */
  for( loop=0; loop < 10; loop++ )
  {
    printf("Highscore[%d]: ", loop );
    scanf("%d", &highscore[ loop ] );
  }



  /* Try to open file "HighScore.dat" as a new file:  */
  /* (If the file does not exist, it will be created. */
  /* If it, on the the other hand, exist, it will be  */
  /* overwritten.)                                    */
  file_handle = (struct FileHandle *)
    Open( "RAM:HighScore.dat", MODE_NEWFILE );
  
  /* Have we opened the file successfully? */
  if( file_handle == NULL )
  {
    printf("Could not open the file!\n");
    exit();
  }



  /* We have now opened a file, and are ready to start writing: */
  bytes_written = Write( file_handle, highscore, sizeof( highscore ) );

  if( bytes_written != sizeof( highscore ) )
  {
    printf("Could not save the Highscore list!\n");
    Close( file_handle );
    exit();
  }
  else
    printf("Highscore saved successfully!\n");



  printf("Memory cleared!\n");
  
  for( loop=0; loop < 10; loop++ )
    highscore[ loop ] = 0;  



  printf("Loading Highscore!\n");

  Seek( file_handle, 0, OFFSET_BEGINNING );

  bytes_read = Read( file_handle, highscore, sizeof( highscore ) );

  if( bytes_written != sizeof( highscore ) )
  {
    printf("Could not read the Highscore list!\n");
    Close( file_handle );
    exit();
  }



  /* Print out the numbers: */
  for( loop=0; loop < 10; loop++ )
    printf("Highscore[%d] = %5d\n", loop, highscore[ loop ] );



  /* Close the file: */
  Close( file_handle );
}

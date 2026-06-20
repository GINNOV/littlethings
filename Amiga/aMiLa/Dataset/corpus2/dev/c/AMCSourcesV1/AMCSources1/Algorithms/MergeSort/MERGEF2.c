#include <stdio.h>

void ord_file( char *file_name );
void stampa_f( char *file_name );

void main( void )
{
FILE *finp;

  ord_file( "dati.dat" );
  return;
}

void ord_file( char *file_name )
{
FILE *f1, *f2, *f, *f3;
int sf1, sf2;
int x, y, old_x, old_y, ordinato;

  stampa_f( file_name );

  do {
    f1 = fopen( "~f1.dat", "w" );
    f2 = fopen( "~f2.dat", "w" );
    f3 = fopen( file_name, "r" );
    f = f1;
    ordinato = 1;
    if ( fscanf( f3, "%d", &x ) != EOF ) 
      do {
        fprintf( f, "%2d ", x );
        old_x = x;
        sf1 = fscanf( f3, "%d", &x );
        if ( sf1 != EOF && old_x > x ) {
             f = (( f == f1 ) ? f2 : f1 );
             ordinato = 0;
        } 
      } while ( sf1 != EOF );
  
    fclose( f1 ); fclose( f2 ); fclose( f3 );
    if ( ! ordinato ) {
      stampa_f( "~f1.dat" ); stampa_f( "~f2.dat" ); 
      f1 = fopen( "~f1.dat", "r" );
      f2 = fopen( "~f2.dat", "r" );
      f3 = fopen( file_name, "w" );
    
      sf1 = fscanf( f1, "%d", &x );
      sf2 = fscanf( f2, "%d", &y );
      for ( ; sf1 != EOF && sf2 != EOF ; ) {
        if ( x < y ) { 
          fprintf( f3, "%2d ", x );
          old_x = x;
          sf1 = fscanf( f1, "%d", &x );
          if ( sf1 == EOF || old_x > x ) 
            do {
              fprintf( f3, "%2d ", y );
              old_y = y;
              sf2 = fscanf( f2, "%d", &y );
            } while ( sf2 != EOF && old_y <= y );
        }
        else {
          fprintf( f3, "%2d ", y );
          old_y = y;
          sf2 = fscanf( f2, "%d", &y );
          if ( sf2 == EOF || old_y > y ) 
            do {
              fprintf( f3, "%2d ", x );
              old_x = x;
              sf1 = fscanf( f1, "%d", &x );
            } while ( sf1 != EOF && old_x <= x );
        }
      }
      for ( ; sf1 != EOF ; ) {
        fprintf( f3, "%2d ", x );
        sf1 = fscanf( f1, "%d", &x );
      }
      for ( ; sf2 != EOF ; ) {
        fprintf( f3, "%2d ", y );
        sf2 = fscanf( f2, "%d", &y );
      }
      fclose( f1 ); fclose( f2 ); fclose( f3 );
    }  
    stampa_f( file_name ); 
  } while ( !ordinato );
  remove( "~f1.dat"); remove( "~f2.dat");
  return;
}

void stampa_f( char *file_name )
{
FILE *fp;
int x;
  fp = fopen( file_name, "r" );
  while ( fscanf( fp, "%d", &x ) != EOF )
    printf( "%2d ", x );
  printf("\n");
  fclose( fp );
  return;
}


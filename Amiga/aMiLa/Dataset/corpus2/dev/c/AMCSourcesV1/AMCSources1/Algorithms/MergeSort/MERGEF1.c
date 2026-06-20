#include <stdio.h>

int ord_file( FILE *fp );
void merge( FILE *f1, FILE *f2, FILE *g1, FILE *g2, const k, const n );
void merge_run( FILE *f1, FILE *f2, FILE *g, const k1, const k2 ); 
void reset_and_swap( FILE *f1, FILE *f2, FILE *g1, FILE *g2 );
void stampa_f( FILE *fd, int num );

void main( void )
{
FILE *finp;
int n_elem;

  finp = fopen( "dati.dat", "r+" ); 
  n_elem = ord_file( finp );
  stampa_f( finp, n_elem );
  fclose( finp );
  return;
}

int ord_file( FILE *fp )
{
FILE *f1, *f2, *g1, *g2;
int conta, dato, k;

  f1 = fopen( "~f1.dat", "w+" );
  f2 = fopen( "~f2.dat", "w+" );
  g1 = fopen( "~g1.dat", "w+" );
  g2 = fopen( "~g2.dat", "w+" );
  conta = 0;
  
  while ( fscanf( fp, "%d", &dato ) != EOF )
    (++conta % 2) ? fprintf( f1, "%2d ", dato) : fprintf( f2, "%2d ", dato);
  rewind( f1 ); rewind( f2 );

  for ( k = 1; k < conta; k *= 2 ) {
    merge( f1, f2, g1, g2, k, conta );
    reset_and_swap( f1, f2, g1, g2 );
  }
  
  rewind( f1 ); rewind( fp );
  for ( k = 0; k < conta; k++ ) {
    fscanf( f1, "%d", &dato );
    fprintf( fp, "%2d ", dato );
  }
  
  fclose( f1 ); fclose( f2 ); fclose( g1 ); fclose( g2 );
  remove( "~f1.dat" ); remove( "~f2.dat" );
  remove( "~g1.dat" ); remove( "~g2.dat" );

  return conta;
}

void merge( FILE *f1, FILE *f2, FILE *g1, FILE *g2, const k, const n )
{
  int i, k1, k2, tot_run;
  FILE *tmp;
  
  tot_run = n/k;
  k1 = (( tot_run % 2 ) ? k : n - k * tot_run );
  k2 = (( tot_run % 2 ) ? n - k * tot_run : 0 );
  
  printf("\nk1: %2d\tk2: %2d\n", k1, k2 );
  stampa_f( f1, k * ( n / ( 2 * k )) + (( tot_run % 2 ) ? k : n - k * tot_run ));
  stampa_f( f2, k * ( n / ( 2 * k )) + (( tot_run % 2 ) ? n - k * tot_run : 0 ));
 
  tmp = g2;
  for ( i = 1 ; i <= n/(2*k) ; i++ ) {
    tmp = (( tmp == g2 ) ? g1 : g2);
    merge_run( f1, f2, tmp, k, k );
  }
  tmp = (( tmp == g2 ) ? g1 : g2);
  merge_run( f1, f2, tmp, k1, k2 );

  return;
}

void merge_run( FILE *f1, FILE *f2, FILE *g, const k1, const k2 )
{
  int x, y, p, q;

  fscanf( f1, "%d", &x);
  fscanf( f2, "%d", &y);
  for ( p = q = 1; p <= k1 && q <= k2 ; )
    if ( x < y ) {
      fprintf( g, "%2d ", x );
      if ( p++ < k1 ) fscanf( f1, "%d", &x );
      else break;
    }
    else {
      fprintf( g, "%2d ", y );
      if ( q++ < k2 ) fscanf( f2, "%d", &y );
      else break;
    }
  for ( ; p <= k1; ) {
    fprintf( g, "%2d ", x );
    if ( p++ < k1 ) fscanf( f1, "%d", &x );
    else break;
  }
  for ( ; q <= k2; ) {
    fprintf( g, "%2d ", y );
    if ( q++ < k2 ) fscanf( f2, "%d", &y );
    else break;
  }
  return;
}

void reset_and_swap( FILE *f1, FILE *f2, FILE *g1, FILE *g2 )
{
  FILE ftmp;

  rewind( f1 ); rewind( f2 ); rewind( g1 ); rewind( g2 );
  ftmp = *f1; *f1 = *g1; *g1 = ftmp;
  ftmp = *f2; *f2 = *g2; *g2 = ftmp;

  return;
}

void stampa_f( FILE *fd, int num )
{
int x, i;
  rewind( fd );
  for ( i = 0; i < num ; i++ ) {
    fscanf( fd, "%d", &x );
    printf( "%2d ", x );
  }
  printf("\n");
  rewind( fd );
  return;
}


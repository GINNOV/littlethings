#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>

#include <proto/exec.h>
#include <proto/dos.h>

#include <stdio.h>
#include <stdlib.h>

extern BOOL __asm DecrunchBR2( register __a0 char *, register __a1 char * );
extern BOOL __asm DecrunchBR3( register __a0 char *, register __a1 char * );

void main( int argc, char **argv )
{
BPTR l, h;
struct FileInfoBlock fib;
char *mptr, *expldptr;
ULONG dlen;

if ( argc != 2 )
	{
	puts( "Usage: Explode <filename>" );
	exit( 5 );
	}

if ( !(l = Lock( argv[1], ACCESS_READ )) )
	{
	puts( "File not found." );
	exit( 5 );
	}

if ( !Examine( l, &fib ) )
	{
	UnLock( l );
	exit( 5 );
	}

UnLock( l );

printf( "Exploding %s - ", argv[1] );

h = Open( argv[1], MODE_OLDFILE );

if ( !(mptr = AllocVec( fib.fib_Size, MEMF_ANY ) ) )
	{
	puts( "No memory." );
	Close( h );
	exit( 0 );
	}

Read( h, mptr, fib.fib_Size );
Close( h );

dlen = *((ULONG*)(mptr + 4));

printf( "original length %lx bytes\n", dlen );

if ( !(expldptr = AllocVec( dlen, MEMF_ANY ) ) )
	{
	puts( "No memory." );
	FreeVec( mptr );
	exit( 5 );
	}

printf( "Exploding - " );
if ( !DecrunchBR2( expldptr, mptr ) )
	if ( !DecrunchBR3( expldptr, mptr ) )
		{
		puts( "Unknown compression." );
		FreeVec( mptr );
		FreeVec( expldptr );
		exit( 5 );
		}
puts( "done.\nWriting file..." );

if ( h = Open( "RAM:Xpl", MODE_NEWFILE ) )
	{
	Write( h, expldptr, dlen );
	Close( h );
	puts( "Done." );
	}
else puts( "Couldn't write Xpl file." );

FreeVec( mptr );
FreeVec( expldptr );
exit( 0 );
}

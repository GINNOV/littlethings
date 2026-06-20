/*
**
**	CreateTTArray.c 
**	© 1998 by Stephan Rupprecht
**
**	email: stephan.rupprecht@primus-online.de
**
**	FREEWARE - I am not responsible for any damage 
**	that is caused by the (mis)use of this program.
**
**	Compiler: MAXON-C++
**
**	NOTE: This code uses the pool functions of OS3
**	to keep track on the allocated memory.
**
*/

#include <exec/types.h>
#include <exec/memory.h>

#include <pragma/exec_lib.h>
#include <pragma/utility_lib.h>

#ifndef MAX_TEMPLATE_ITEMS
#define MAX_TEMPLATE_ITEMS 100
#endif

/****************************************************************************/

char **CreateTTArray( STRPTR template, LONG *array, APTR *pool, char **orig );

/****************************************************************************/

char **CreateTTArray( STRPTR template, LONG *array, APTR *poolp, char **orig )
{
	char 	**tta, **oldtta = NULL;
	APTR	pool;
	
	if( pool = *poolp = CreatePool( MEMF_ANY, 4096, 4096 ) )
	{
		if( oldtta = tta = AllocPooled( pool, sizeof(STRPTR) * (MAX_TEMPLATE_ITEMS+1) ) )
		{
			UBYTE	bufstart[32], 
					*buf = bufstart,
					kind = 0;
				
			*tta++ = "DONOTWAIT";

			if( orig )
			{
				STRPTR	p;
				
				while( p = *orig++ )
				{
					if( ! Strnicmp( "STARTPRI", p, sizeof( "STARTPRI" ) -1 ) )
					{
						*tta++ = p;
					}
					else if( ! Strnicmp( "TOOLPRI", p, sizeof( "TOOLPRI" ) -1 ) )
					{
						*tta++ = p;
					}
				}
			}

			while( TRUE )
			{
				UBYTE	ch = *template++;
				
				if( ch == '\0' || ch == ',' )
				{
					LONG	curr = *array;
					ULONG	allocsz;
					
					*buf = 0;
					
					allocsz = ( (ULONG)buf - (ULONG)bufstart ) + 16L;
					
					if( kind == '\0' && curr )
					{
						allocsz += strlen( curr );
					}
					
					if( *tta = AllocPooled( pool, allocsz ) )
					{
						STRPTR	data, fmt;
				
						switch( kind )
						{						
							case 'M':
								/*- not supported yet (does anyone need it?) -*/
								fmt = "(%s=?)";
							break;
							
							case 'N':
								fmt = curr ? "%s=%ld" : "(%s=?)";
								if( curr )
								{
									data = (STRPTR) *(LONG **)curr;
								}
							break;
							
							case 'T':
								fmt = "%s=%s";
								data = curr ? "YES" : "NO";
							break;
							
							case 'S':
								fmt = curr ? "%s" : "(%s)";
							break;
							
							default:								
								fmt = curr ? "%s=%s" : "(%s=?)";
								data = (STRPTR) curr;
							break;
						}
						
						sprintf( *tta++, fmt, bufstart, data );
					}
					else
					{						
						oldtta = NULL;
						break;
					}
					
					if( ! ch )
					{
						break;
					}
					
					kind = 0;
					buf = bufstart;
					array++;
				}
				else if( ch == '=' )
				{
					buf = bufstart;
				}
				else if( ch == '/' )
				{
					while( ( ch = *template++ ) && ( ch != ',' ) )
					{
						switch( ch )
						{
							case 'M':
							case 'N':
							case 'T':
							case 'S':
								kind = ch;
							break;
						}
					}
					
					template--;
				}
				else 
				{
					*buf++ = ch;
				}
			}
		}
		
		if( oldtta )
		{
			*tta = NULL;
		}
		else
		{
			DeletePool( pool );
			*poolp = NULL;
		}
	}
	
	return oldtta;
}

/****************************************************************************/

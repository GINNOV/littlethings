/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*
 * Ce programme analyse le résultat du profiling
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <exec/types.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/nodes.h>
#include <proto/exec.h>

/****************************************************************************/

#define TIME_POS	0
#define FLAG_POS	7
#define FUNC_POS	9

#define STR_MAXLEN	256

struct StackElem
{
  struct Node	se_Node ;
  UBYTE 	se_Name[STR_MAXLEN+1] ;
  ULONG 	se_EntryTime ;
  ULONG 	se_SubFuncTime ;
} ;

struct ListElem
{
  struct Node	le_Node ;
  UBYTE 	le_Name[STR_MAXLEN+1] ;
  ULONG 	le_CallsCount ;
  ULONG 	le_TotalTime, le_MinTime, le_MaxTime ;
} ;

static UBYTE Line[STR_MAXLEN+1] ;
static struct List Stack, Funcs ;

/****************************************************************************/

static void Setup( void )
{
  NewList( &Stack ) ;
  NewList( &Funcs ) ;
}

/****************************************************************************/

static void Cleanup( void )
{
  struct Node *p, *q ;
  struct ListElem *l ;

  for ( p = (struct Node *)Stack.lh_Head ; q = p->ln_Succ ; p = q ) FreeVec( p ) ;
  printf( "\n Total  Count    Min    Max  Aver. Name\n" ) ;
  for ( l = (struct ListElem *)Funcs.lh_Head  ; q = l->le_Node.ln_Succ ; l = (struct ListElem *)q )
  {
    printf( "%6ld %6ld %6ld %6ld %6ld %s\n" , l->le_TotalTime , l->le_CallsCount , l->le_MinTime ,
	    l->le_MaxTime , l->le_TotalTime / l->le_CallsCount , l->le_Name ) ;
    FreeVec( l ) ;
  }
}

/****************************************************************************/

void main( void )
{
  struct StackElem *s ;
  struct ListElem  *l ;
  LONG lnum, time, etime ;

  Setup() ;

  for ( lnum = 0 ; gets( Line ) ; lnum++ )
  {
    /* Function prolog : pushes a new node onto the function calls stack */
    if ( Line[FLAG_POS] == 'P' )
    {
      if ( s = AllocVec( sizeof(struct StackElem) , MEMF_PUBLIC|MEMF_CLEAR ) )
      {
	s->se_Node.ln_Name = s->se_Name ;
	strcpy( s->se_Name , &Line[FUNC_POS] ) ;
	s->se_EntryTime = atol( &Line[TIME_POS] ) ;
	AddHead( &Stack , (struct Node *)s ) ;
      }
      else
      {
	fprintf( stderr , "\n%ld: Not enough memory !\n" , lnum ) ;
	break ;
      }
    }
    /* Function epilog : pops the function calls stack */
    else if ( Line[FLAG_POS] == 'E' )
    {
      s = (struct StackElem *)Stack.lh_Head ;
      if ( s->se_Node.ln_Succ && (! strcmp( s->se_Name , &Line[FUNC_POS] )) )
      {
	/* finds/allocates the corresponding node in the Funcs list */
	l = (struct ListElem *)FindName( &Funcs , s->se_Name ) ;
	if ( ! l )
	{
	  if ( l = AllocVec( sizeof(struct ListElem) , MEMF_PUBLIC|MEMF_CLEAR ) )
	  {
	    l->le_Node.ln_Name = l->le_Name ;
	    l->le_MinTime      = 0x7FFFFFFF ;
	    strcpy( l->le_Name , &Line[FUNC_POS] ) ;
	    AddHead( &Funcs , (struct Node *)l ) ;
	  }
	  else
	  {
	    fprintf( stderr , "\n%ld: Not enough memory !\n" , lnum ) ;
	    break ;
	  }
	}

	/* compute time spent in the function */
	time  = atol( &Line[TIME_POS] ) - s->se_EntryTime ;
	etime = time - s->se_SubFuncTime ;

	/* update the node in the Funcs list */
	l->le_CallsCount++ ;
	l->le_TotalTime += etime ;
	if ( etime < l->le_MinTime ) l->le_MinTime = etime ;
	if ( etime > l->le_MaxTime ) l->le_MaxTime = etime ;

	/* remove the node from the function calls stack */
	RemHead( &Stack ) ;
	s = (struct StackElem *)Stack.lh_Head ;
	if ( s->se_Node.ln_Succ ) s->se_SubFuncTime += time ;
      }
      else
      {
	fprintf( stderr , "\n%ld: No prolog found for %s\n" , lnum , &Line[FUNC_POS] ) ;
	break ;
      }
    }
  }

  Cleanup() ;
}


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
/*  _______________________________________________________________________

    ABackup 5.0
    bitrequest.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Apr-95
    Modified: 09-Apr-95
    _______________________________________________________________________
*/

#include "headers.h"
#include "bitrequest.h"

//______________________________________________________________________________

VOID
PrepareBitRequest()
{
  LONG k, l, w, t ;

  // erases all gadget definitions

  memset( PGadgets , '\0' , sizeof(PGadgets) ) ;
  memset( NGadgets , '\0' , sizeof(NGadgets) ) ;

  // computes window size and position

  w = ( ScrFontX * 2 ) + 2 ;
  t = ( Scr->WBorTop + ScrFontY + 1 ) + ( ScrFontY * 2 ) + 14 ;

  k = t + ( ScrFontY * 2 ) + 24 ;
  FTags[FTT_HEIGHT].ti_Data = k ;

  l = ( ScrFontX * 40 ) + Scr->WBorLeft + Scr->WBorRight ;
  k *= 3 ;
  if ( l < k ) l = k ;

  FTags[FTT_WIDTH].ti_Data = l ;

  // computes gadget positions and sizes

  k = 8 * ( w + 2 ) ;
  l = ( l - k ) / 2 ;

  for ( k = 0 ; k < 8 ; k++ )
  {
    NGadgets[k].ng_LeftEdge = l ;
    NGadgets[k].ng_TopEdge  = t ;
    NGadgets[k].ng_Width    = w ;
    NGadgets[k].ng_Height   = ScrFontY + 2 ;

    IText[k].ITextFont	    = ScrFont ;
    IText[k].LeftEdge	    = ( w - IntuiTextLength( &IText[k] ) ) / 2 ;
    IText[k].TopEdge	    = - ( ScrFontY + 2 ) ;

    l += NGadgets[k].ng_Width + 2 ;
  }

  for ( k = VAL_SET ; k <= VAL_IGNORE ; k++ )
  {
    VText[k].LeftEdge = 1 + ( ScrFontX / 2 ) ;
    VText[k].TopEdge  = 1 ;
  }

  NGadgets[GID_OK].ng_LeftEdge	   = Scr->WBorLeft + 6 ;
  NGadgets[GID_OK].ng_TopEdge	   = NGadgets[0].ng_TopEdge + NGadgets[0].ng_Height + 12 ;
  NGadgets[GID_OK].ng_Width	   = FTags[FTT_WIDTH].ti_Data / 3 ;
  NGadgets[GID_OK].ng_Height	   = ScrFontY + 4 ;

  NGadgets[GID_CANCEL].ng_TopEdge  = NGadgets[GID_OK].ng_TopEdge ;
  NGadgets[GID_CANCEL].ng_Width    = FTags[FTT_WIDTH].ti_Data / 3 ;
  NGadgets[GID_CANCEL].ng_LeftEdge = FTags[FTT_WIDTH].ti_Data - NGadgets[GID_CANCEL].ng_Width - 6 - Scr->WBorRight ;
  NGadgets[GID_CANCEL].ng_Height   = ScrFontY + 4 ;

  DBBTags[DBBT_VINFO].ti_Data	   = (ULONG)VInfo ;
}

//______________________________________________________________________________

STATIC BOOL
SetupBitRequest( struct Window *pFen )
{
  BYTE *p ;
  LONG k, l ;
  struct Gadget *pGadget ;

  // creates "context" for gadtools

  if (! CreateContext( &Context )) return( FALSE ) ;

  // allocates all the gadgets

  pGadget = Context ;
  for ( k = 0 ; k < NUMGAD ; k++ )
  {
    NGadgets[k].ng_VisualInfo = VInfo ;
    NGadgets[k].ng_TextAttr   = ScrFont ;
    NGadgets[k].ng_GadgetID   = k < GID_OK ? GID_BITH - k : k ;
    if ( k == GID_OK ) NGadgets[k].ng_GadgetText = GetStr( MSG_OK ) ;
    else if ( k == GID_CANCEL ) NGadgets[k].ng_GadgetText = GetStr( MSG_CANCEL ) ;

    pGadget = CreateGadgetA( k < GID_OK ? GENERIC_KIND : BUTTON_KIND , pGadget , &NGadgets[k] , NGTags ) ;
    if ( ! pGadget ) return( FALSE ) ;
    PGadgets[k] = pGadget ;

    if ( k < GID_OK )
    {
      pGadget->Flags	    = GFLG_GADGHCOMP ;
      pGadget->Activation   = GACT_RELVERIFY ;
      pGadget->GadgetType  |= BOOLGADGET ;
      pGadget->GadgetText   = &IText[k] ;
      pGadget->GadgetText->NextText = NULL ;
      pGadget->UserData     = (APTR)VAL_IGNORE ;
    }
  }

  // adds the gadgets to the window

  AddGList( pFen , Context , -1 , -1 , NULL ) ;
  RefreshGadgets( Context , pFen , NULL ) ;

  // draws bevel boxes

  for ( k = 0 ; k < 8 ; k++ )
    DrawBevelBoxA( pFen->RPort , PGadgets[k]->LeftEdge , PGadgets[k]->TopEdge , PGadgets[k]->Width , PGadgets[k]->Height , DBBTags ) ;

  k = pFen->Width - pFen->BorderRight - pFen->BorderLeft ;
  DrawBevelBoxA( pFen->RPort , pFen->BorderLeft , PGadgets[GID_OK]->TopEdge - 5 ,
			       k , PGadgets[GID_OK]->Height + 9 , DBBTags ) ;

  DrawBevelBoxA( pFen->RPort , pFen->BorderLeft , pFen->BorderTop ,
			       k , PGadgets[GID_OK]->TopEdge - pFen->BorderTop - 5 , DBBTags ) ;

  // displays request text

  SetAPen( pFen->RPort , 2 ) ;
  p = GetStr( MSG_REQ_BITS ) ;
  l = strlen( p ) ;
  k = pFen->Width - TextLength( pFen->RPort , p , l ) ;
  Move( pFen->RPort , k / 2 , pFen->BorderTop + ScrTFont->tf_Baseline + 6 ) ;
  Text( pFen->RPort , p , l ) ;
  SetAPen( pFen->RPort , 1 ) ;

  return( TRUE ) ;
}

/**************************************************************************/

static BOOL
HandleBitRequest( struct Window *pFen , LONG *pBMask , LONG *pBVal )
{
  ULONG gid ;
  USHORT code ;
  LONG k, b, v ;
  struct Gadget *pGadget ;
  struct IntuiMessage *pMsg, Msg ;

  FOREVER
  {
    WaitPort( pFen->UserPort ) ;

    while ( pMsg = GT_GetIMsg( pFen->UserPort ) )
    {
      memcpy( &Msg , pMsg , sizeof(struct IntuiMessage) ) ;
      GT_ReplyIMsg( pMsg ) ;

      switch ( Msg.Class )
      {
	case IDCMP_REFRESHWINDOW :

	  GT_BeginRefresh( pFen ) ;
	  GT_EndRefresh( pFen , TRUE ) ;
	  break ;

	case IDCMP_CLOSEWINDOW :

	  return( FALSE ) ;

	case IDCMP_VANILLAKEY :

	  code = Msg.Code ;
	  if ( (code == 0x0D) || SHCUT( MSG_OK ) ) return( TRUE ) ;
	  if ( SHCUT( MSG_CANCEL ) ) return( FALSE ) ;
	  break ;

	case IDCMP_GADGETUP :

	  pGadget = (struct Gadget *)Msg.IAddress ;
	  gid = pGadget->GadgetID ;

	  if ( gid == GID_OK ) return( TRUE ) ;
	  if ( gid == GID_CANCEL ) return( FALSE ) ;

	  k = (LONG)pGadget->UserData + 1 ;
	  if ( k > VAL_IGNORE ) k = VAL_SET ;
	  pGadget->UserData = (APTR)k ;
	  pGadget->GadgetText->NextText = &VText[k] ;
	  RefreshGList( pGadget , pFen , NULL , 1 ) ;

	  b = 1 << gid ;
	  if ( k != VAL_IGNORE )
	  {
	    v = b ;
	    if ( k == VAL_SET )
	    {
	      if ( gid <= GID_BITR ) v = ~v ; // "rwed" are in negative logic
	    }
	    else
	    {
	      if ( gid >  GID_BITR ) v = ~v ; // "hspa" are in positive logic
	    }
	    *pBVal   = ( *pBVal & ~b ) | ( v & b ) ;
	    *pBMask |= b ;
	  }
	  else
	  {
	    *pBMask &= ~b ;
	    *pBVal  &= *pBMask ;
	  }
      }
    }
  }
}

/**************************************************************************/

BOOL BitRequest( LONG *pBMask, LONG *pBVal )
{
  WORD	 x ;
  BOOL	 Res ;
  struct Window *pFen ;
  struct IntuiMessage *pMsg ;

  // opens the window

  x = Win->LeftEdge + ( Win->Width  - FTags[FTT_WIDTH].ti_Data  ) / 2 ;
  FTags[FTT_LEFT].ti_Data   = x < 0 ? 0 : x ;
  x = Win->TopEdge  + ( Win->Height - FTags[FTT_HEIGHT].ti_Data ) / 2 ;
  FTags[FTT_TOP].ti_Data    = x < 0 ? 0 : x ;
  FTags[FTT_PUBSCR].ti_Data = (ULONG)Scr ;
  FTags[FTT_TITLE].ti_Data  = (ULONG)GetStr( MSG_REQUEST ) ;

  pFen = OpenWindowTagList( NULL , FTags ) ;
  if ( ! pFen )
  {
    Warning( MSG_WARN_OPEN_WINDOW ) ;
    return( FALSE ) ;
  }

  SetDrMd( pFen->RPort , JAM2 ) ;
  SetFont( pFen->RPort , ScrTFont ) ;

  // handles IDCMP messages

  if ( SetupBitRequest( pFen ) )
  {
    *pBMask = 0 ;
    *pBVal  = 0 ;
    BlockWinInput() ;
    Res = HandleBitRequest( pFen , pBMask , pBVal ) ;
    ReleaseWinInput() ;
  }
  else
  {
    Warning( MSG_WARN_MEMORY ) ;
    Res = FALSE ;
  }

  // closes the window

  if ( pFen->FirstGadget ) RemoveGList( pFen , pFen->FirstGadget , -1 ) ;
  if ( Context ) FreeGadgets( Context ) ;

  while ( pMsg = GT_GetIMsg( pFen->UserPort ) ) GT_ReplyIMsg( pMsg ) ;
  CloseWindow( pFen ) ;

  return( Res ) ;
}


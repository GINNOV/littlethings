
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
	tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\class	 Area
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief	 Base class for physical userinterface components
	\date	 2000, 2001

	Area is the basic base class for all Physical Components.

	Area provides a drawing context. Drawing is not
	currently clipped.

	Area can contain subareas, thus areas can be hierarchial.
	When Area is drawn, all subareas are also drawn.

	Area knows how to determine size and position for
	itself. This is called layout. The layout is
	determined through LayoutConstraints when place
	method is called.

	setPos() and setSize() methods are protected low level
	methods; to actually set position or size of area you
	must use LayoutConstraint of that Area. At the moment
	it is public member, but that will change later.

	Notice that you should use drawSelf() method for drawing
	in subclasses and leave draw() method as it is. The draw()
	method will take care of rendering children as well.

	Area can also be interactive such that they can be operated
	with input device. Area is not interactive by default.
	To make Area interactive, it must be registered (as potential
	focus area) to WindowManager. See WindowManager for details on this.

	Visual Area properties link font, color and size should be
	stored in Style.
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_AREA_H
#define TEDDY_PHYSICAL_COMPONENTS_AREA_H


#include "Graphics/ViewClient.h"
#include "MixIn/Named.h"
#include "SysSupport/Types.h"
#include "SysSupport/StdList.h"
namespace Graphics           { class Font;          };
namespace PhysicalComponents { class WindowManager; };
using namespace Graphics;


namespace PhysicalComponents {


class Projection;
class LayoutConstraint;
class Style;


class Area : public Named, public ViewClient {
public:
	Area( char *name );
	Area( const char *name );
	virtual ~Area();

	enum e_ordering {
		pre_self,      //!<  Draw self first, before children
		post_self,     //!<  Draw self last, after children
		separate_self  //!<  Separate drawSelf() invovation
	};

	//	Area Input Interface
	virtual Area *getHit       ( const int x, const int y );

	//	Area Graphics Interface
	virtual void  draw         ();
	virtual void  drawSelf     ();  //!<  Will render only self
	virtual void  vertex2i     ( const int    x,        const int    y ) const;
	virtual void  drawString   ( Font        *font,     const char  *str,          const int xp, const int yp );
	virtual void  drawFillRect ( const int    x1,       const int    y1,           const int x2, const int y2 );
	virtual void  drawRect     ( const int    x1,       const int    y1,           const int x2, const int y2 );
	virtual void  drawBiColRect( const Color &top_left, const Color &bottom_right, const int x1, const int y1, const int x2, const int y2 );

	//	Area Layout Interface
	virtual void  insert       ( Area      *area );
	virtual void  place        ( int        offset_x=0, int        offset_y=0 );
	virtual void  getMinSize   ( int       &min_width,  int       &min_height ) const;
	virtual void  moveDelta    ( const int  x_delta,    const int  y_delta );
	virtual void  sizeDelta    ( const int  x_delta,    const int  y_delta );

	//	Area depth oredering interface
	virtual void  toFront      ();  //!<  Move this Area to front of all other Areas
	virtual void  toBack       ();  //!<  Mobe this Area behind all other Areas

	virtual void  childToFront ( Area *child );  //!<  Move a child Area to front of all other Areas
	virtual void  childToBack  ( Area *child );  //!<  Move a child Area behind all other Areas

	void          begin2d      ();
	void          end2d        ();

	void              setLayoutConstraint( LayoutConstraint *lc );
	LayoutConstraint *getLayoutConstraint();

	virtual void  debug        ( int depth=0 );
	void          getSize      ( int &width, int &height ) const;          //!<  Query float size of Area excluding outer spacings
	void          getPos       ( int &x,     int &y ) const;               //!<  Quary float position of Area
	float         getRatio     () const;                                   //!<  Return aspect ratio of Area
	View         *getView      () const;                                   //!<  Return View of Area
	int          *getViewport  ();
	void          setOrdering  ( const e_ordering ordering );
	virtual void  setParent    ( Area *parent, View *view = NULL );
	Area         *getParent    ();
	virtual Area *getTarget    ( const Uint8 e );

	static void   setDefaultWindowManager( WindowManager *wm );

protected:
	//	LowLevel Layout
	virtual void  beginPlace();
	virtual void  endPlace	();
	virtual void  placeOne	( Area      *area );
	virtual void  setSize	( const int  width,  const int height );
	virtual void  setPos	( const int  x,      const int y );

protected:
	static WindowManager *default_window_manager;  //!<  Window Manager

	WindowManager    *window_manager;  //!<  Window manager
	LayoutConstraint *constraint;
	Style            *style;
	Area             *parent;          //!<  Parent Area hosting this Area
	list<Area*>       areas;           //!<  Child Areas
	e_ordering	      ordering;        //!<  Draw before or after children?
	int               viewport[4];     //!<  OpenGL Viewport for this Area
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_AREA_H


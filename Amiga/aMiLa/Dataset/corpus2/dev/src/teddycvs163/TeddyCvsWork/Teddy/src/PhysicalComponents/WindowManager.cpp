
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
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


#include "config.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/Dock.h"
#include "PhysicalComponents/Layer.h"
#include "Graphics/View.h"
#include "Graphics/Features.h"
#include "Materials/SdlTexture.h"
#include "SysSupport/Messages.h"
#include "SDL.h"
#include <cstdio>
using namespace Graphics;
using namespace Materials;


namespace PhysicalComponents {


//! Constructor
WindowManager::WindowManager( View *view ):EventListener(0){
	this->view      = view;
	this->focus     = NULL;
	this->skip_warp = false;

	SDL_EnableUNICODE( 1 );
	SDL_EnableKeyRepeat( SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL );

#	if !defined( USE_TINY_GL )
	this->cursor    = new SdlTexture( "gui/frontier_cursor.png" );
	if( cursor != NULL ){
		if( cursor->isGood() == true ){
			SDL_ShowCursor( SDL_DISABLE );
		}
	}
#	else
	this->cursor = NULL;
#	endif

	int *vp = view->getViewport();

	skip_warp = true;
	mx        = vp[0] + (vp[2] - vp[0]) / 2;
	my        = vp[1] + (vp[3] - vp[1]) / 2;
	SDL_WarpMouse( mx, my );
}


//!  Destructor
WindowManager::~WindowManager(){
}


//!  Never returning input loop forwarding host system messages to application
void WindowManager::inputLoop(){
	for( ; ; ){
		SDL_Event event;

		SDL_Delay( 1 );  // FIX some kind of delay is needed if going faster than 100 fps
		view->display();

		while( SDL_PollEvent(&event) ) {
			switch( event.type ){

			case SDL_QUIT:
				exit( 0 );
				break;

			case SDL_KEYDOWN:
				keyDown( event.key.keysym );
				break;

			case SDL_KEYUP:
				keyUp( event.key.keysym );
				break;

			case SDL_MOUSEMOTION:
				mouseMotion( event.motion.x, event.motion.y, 0, 0 );
				break;

			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP:
				mouseKey( event.button.button, event.button.state, event.button.x, event.button.y );
				break;

			case SDL_VIDEORESIZE:
				//	This messes OpenGL contexts; destroys the old one and creates a new one.
				//	We need to reupload textures and redo displaylists
				if( SDL_SetVideoMode(event.resize.w, event.resize.h, 0, SDL_OPENGL|SDL_RESIZABLE/*|SDL_FULLSCREEN*/) == NULL ) {
					fprintf( stderr, "Unable to resize OpenGL screen: %s\n", SDL_GetError() );
					exit( 2 );
				}
				break;
			}
		}
	}
}


//!  Insert Layer to View
void WindowManager::insert( Layer *layer ){
	layers.push_back( layer );
}


//!  Draw layers
void WindowManager::draw(){
	list<Layer*>::iterator l_it = layers.begin();
	while( l_it != layers.end() ){
		Layer *l = (*l_it);
		l->drawLayer();
		l_it++;
	}

	view->begin2d();
	view->enable( TEXTURE_2D );
	view->enable( BLEND );

#	if !defined( USE_TINY_GL )
	if( cursor != NULL ){
		if( cursor->isGood() == true ){
			view->color( C_WHITE );
			view->blit( cursor, mx - cursor->getWidth()/2, my-cursor->getHeight()/2 );
			//printf( "%d, %d\n", mx, my );
		}
	}
#	endif
}


//!  Update all windows, after view resize etc.
void WindowManager::update(){
	list<Layer*>::iterator l_it = layers.begin();
	while( l_it != layers.end() ){
		(*l_it)->update(view);
		l_it++;
	}
}


//!  Process window event
void WindowManager::event( Event e, Area *source, Area *target, int x, int y ){
	switch( e ){

	case EVENT_MOVE:
		target->moveDelta( x, y );
		break;

	case EVENT_SIZE:
		target->sizeDelta( x,  y );
		target->moveDelta( x,  y );
		break;

	case EVENT_TO_FRONT: {
		Area *visual = target;//->getParent();
		if( visual != NULL ){
			visual->toFront();
		}
		break;
	}

	case EVENT_TO_BACK: {
		Area *visual = target;//->getParent();
		if( visual != NULL ){
			visual->toBack();
		}
		break;
	}

	case EVENT_SPLIT_UPDATE: {
		Dock *dock = dynamic_cast<Dock*>(target);
		if( dock != NULL ){
			dock->splitDelta( source, x, y );
		}
	}

	default:
		break;
	}
}


//!  Received key message from device
/*virtual*/ void WindowManager::keyDown( const SDL_keysym key ){
	if( focus != NULL ){
		if(  focus->doesEvent(EVENT_KEY_DOWN_M)  ){
			focus->keyDown( key );
		}
	}
};


//!  Received key message from device
/*virtual*/ void WindowManager::keyUp( const SDL_keysym key ){
	if( focus != NULL ){
		if(  focus->doesEvent(EVENT_KEY_UP_M)  ){
			focus->keyUp( key );
		}
	}
};


//!  MouseListener interface
/*virtual*/ void WindowManager::mouseKey( int button, int state, int x, int y ){
	EventListener *focus_try      = NULL;
	Area          *focus_try_area = NULL;

	mouse_b[button] = state;

#	if defined( USE_TINY_GL )
	bool all_released = true;
	for( int i=1; i<=3; i++ ){
		if( mouse_b[i] == SDL_PRESSED ){
			all_released = false;
		}
	}

	if( all_released == true ){
		SDL_ShowCursor( SDL_ENABLE );
	}
#	endif


	//  Every click checks if area needs to be changed
	//  This is click to focus policy
	//  Should be configurable; do later
	if( state==SDL_PRESSED ){
		Area *hit = NULL;

		list<Layer*>::iterator l_it = layers.begin();
		while( l_it != layers.end() ){
			Layer *l = (*l_it);
			hit = l->getHit( x, y );
			if( hit != NULL ){
				break;
			}
			l_it++;
		}

		if( hit == NULL ){
			wm_debug_msg( "No area there" );
		}else{
			wm_debug_msg( "Click over %s", hit->getName() );
	
			Named *focus_name = dynamic_cast<Named *>( hit );
			char  *name       = "[unnamed]";
			if( focus_name != NULL ){
				name = focus_name->getName();
			}
			//  Is this Area an EventListener one?
			focus_try  = dynamic_cast<EventListener*>( hit   );
			if( focus_try == NULL ){
				wm_debug_msg( "%s is not listening to events", name );
			}

			this->setFocus( focus_try );
		}

	}

	Named *focus_name = dynamic_cast<Named *>( focus );
	char  *name       = "[unnamed]";
	if( focus_name != NULL ){
		name = focus_name->getName();
	}
		
	//  FIX It is unclear - should use style or something - if
	//  Area wants to receive the event that activated it.
	if( focus != NULL ){
		if( focus->doesEvent(EVENT_MOUSE_KEY_M) ){
			focus->mouseKey( button, state, x, y );
			wm_debug_msg( "MouseKey sent to %s", name );
		}
	}else{
		wm_debug_msg( "No Area has the focus" );
	}

}


//  MouseListener interface
/*virtual*/ void WindowManager::mouseMotion( int x, int y, int dx, int dy ){
	//cout << "Motion" << endl;
	//  Motion does not currently check for
	//  focus change; Click to focus policy is used
	//  Should be able to change focus with motion
	//  only too; Add later

	//  If warping, don't process mouse motion
	//  Actually here may be some cases which want the
	//  motion
	if( skip_warp ){
		skip_warp = false;
		return;
	}

	//  Update last button drag positions
	int  x_delta   = 0;
	int  y_delta   = 0;
	for( int b=1; b<4; b++ ){
		if( mouse_b[b]==SDL_PRESSED ){
			x_delta = x - mx;
			y_delta = y - my;
			if( focus != NULL ){
				if( focus->doesEvent(EVENT_MOUSE_HOLD_DRAG_M) ){
#					if defined( USE_TINY_GL )
					SDL_ShowCursor( SDL_DISABLE );
#					endif
					skip_warp = true;
					focus->mouseDrag( b, mx, my, x_delta, y_delta );
				}else if( focus->doesEvent(EVENT_MOUSE_DRAG_M) ){
					focus->mouseDrag( b, mx, my, x_delta, y_delta );
				}
			}
		}
	}

	if( skip_warp == true ){
		SDL_WarpMouse( mx, my );
//		printf( "-- HOLD -- %d, %d\n", x_delta, y_delta );
	}else{
//		printf( "%d, %d\n", x_delta, y_delta );
		mx = x;
		my = y;
	}

	if( focus != NULL ){
		focus->mouseMotion( mx, my, x_delta, y_delta );
	}
}


//!  Set focus
void WindowManager::setFocus( EventListener *focus_try ){
	Area *focus_area = dynamic_cast<Area*>( focus );
	if( focus != focus_try ){
		if( focus != NULL ){
			focus->focusActive( false );
			//printf( "Focus de-active sent to %s\n", focus_area->getName() );
		}
		focus      = focus_try;
		focus_area = dynamic_cast<Area*>( focus );
		if( focus != NULL ){
			focus->focusActive( true );
			//printf( "Focus active sent to %s\n", focus_area->getName() );
		}
	}else{
		if( focus != NULL ){
			//printf( "%s already	has the focus\n", focus_area->getName() );
		}
	}
}


//!  Return View
View *WindowManager::getView(){
	return this->view;
}


};  //  namespace PhysicalComponents


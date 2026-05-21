/*
* This file is part of Abacus.
* Copyright (C) 1997 Kai Nickel
* 
* Abacus is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Abacus is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Abacus.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/****************************************************************************************
  BoardClass.cpp
-----------------------------------------------------------------------------------------

  CL_Board (Area)

-----------------------------------------------------------------------------------------
  01.01.1997
****************************************************************************************/

#include <graphics/gfxmacros.h>
#include <pragma/graphics_lib.h>
#include <pragma/exec_lib.h> 			// Wait
#include <stdio.h>

#include "BoardClass.hpp"
#include "BoardWindow.hpp"
#include "Abacus.hpp"
#include "Tools.hpp"
#include "Settings.hpp"
#include "StatusWin.hpp"
#include "MsgWin.hpp"

MUI_CustomClass *CL_Board;



/****************************************************************************************
  Board_Data
****************************************************************************************/

const int ALLDRAW   = 1;    //  Kugeln und Auskugeln zeichnen
const int SELSDRAW  = 3;    //  Selektionen zeichnen

void Board_Data::GetCenterOf(int nr, int &cx, int &cy)
{
  float x = nr, y;
  if      (nr <  5) {y = 0.1;          x += 2.1;};
  else if (nr < 11) {y = 1.1; x -=  5; x += 1.6;};
  else if (nr < 18) {y = 2.1; x -= 11; x += 1.1;};
  else if (nr < 26) {y = 3.1; x -= 18; x += 0.6;};
  else if (nr < 35) {y = 4.1; x -= 26; x += 0.1;};
  else if (nr < 43) {y = 5.1; x -= 35; x += 0.6;};
  else if (nr < 50) {y = 6.1; x -= 43; x += 1.1;};
  else if (nr < 56) {y = 7.1; x -= 50; x += 1.6;};
  else              {y = 8.1; x -= 56; x += 2.1;};
  cx = left + rx + int(x * dx),
  cy = top  + ry + int(y * dy);
}

int Board_Data::GetNrOf(int x, int y)
{
  float my = float(y - top ) / float(dy);
  if (my < 0 || my >= 9) return -1;
  int ball, maxx;
  switch(my)
  {
    case 0: ball =  0; maxx = 4; break;
    case 1: ball =  5; maxx = 5; break;
    case 2: ball = 11; maxx = 6; break;
    case 3: ball = 18; maxx = 7; break;
    case 4: ball = 26; maxx = 8; break;
    case 5: ball = 35; maxx = 7; break;
    case 6: ball = 43; maxx = 6; break;
    case 7: ball = 50; maxx = 5; break;
    case 8: ball = 56; maxx = 4; break;
  }
  float mx = float(x - left - (8-maxx) * dx / 2) / float(dx);
  if (mx < 0 || mx >= maxx + 1) return -1;
  ball += mx;
  return ball;
}

ULONG Board_Data::ActivePlayerNr()
{
	if (board.me == Board::white)
		return 1;
	else
		return 2;
}


/****************************************************************************************
  NewSettings
****************************************************************************************/

ULONG Board_NewSettings(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);
  data->newsettings = TRUE;
  data->diff        = FALSE;
  data->update_mode = ALLDRAW;
  MUI_Redraw(obj, MADF_DRAWUPDATE);
  data->setsels     = TRUE;
  data->update_mode = SELSDRAW;
  MUI_Redraw(obj, MADF_DRAWUPDATE);
  return 0;
}

/****************************************************************************************
	NewGame
****************************************************************************************/

ULONG Board_NewGame(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);
	Board b;
	setatt(obj, MUIA_Board_Board, &b);
	return 0;
}


/****************************************************************************************
	Load / Save
****************************************************************************************/

ULONG Board_Load(struct IClass* cl, Object* obj, Msg msg)
{
	struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
	Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
	char* fname = GetFilename(_win(obj), FALSE, MSG_LOAD_TITLE, "", "Games/");
	if (fname)
	{
		Board b;
		if (b.Load(fname))
			setatt(obj, MUIA_Board_Board, &b);
		else
 			ShowError(app, obj, MSG_LOAD_ERROR);
	}

	return 0;
}

ULONG Board_Save(struct IClass* cl, Object* obj, Msg msg)
{
	struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
	Object* app = (Object*)xget(obj, MUIA_ApplicationObject);

	char* fname = GetFilename(_win(obj), TRUE, MSG_SAVE_TITLE, "", "Games/");
	if (fname)
	{
		if (!data->board.Save(fname)) 
			ShowError(app, obj, MSG_SAVE_ERROR);
	}
	return 0;
}


/****************************************************************************************
  Undo
****************************************************************************************/

ULONG Board_Undo(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);
  Board n = data->last_board;
  setatt(obj, MUIA_Board_Board, &n);
  return 0;
}


/****************************************************************************************
  TogglePlayer
****************************************************************************************/

ULONG Board_Winner(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
  Object* win = (Object*)xget(obj, MUIA_WindowObject);
  Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
  Settings* s = (Settings*)xget(app, MUIA_Abacus_Settings);

	setatt(win, MUIA_Window_Sleep, TRUE);

  char buffer[100];
  if (data->board.outBalls(Board::black) == 6)
    sprintf(buffer, GetStr(MSG_WINNER_TEXT), s->name1); 
  else
    sprintf(buffer, GetStr(MSG_WINNER_TEXT), s->name2); 

	Object* mwin = (Object*)NewObject(CL_MsgWin->mcc_Class, NULL,
			MUIA_Window_RefWindow	, win,
			MUIA_MsgWin_MsgBig  	, GetStr(MSG_WINNER_TITLE),
			MUIA_MsgWin_MsgSmall	, buffer,
			TAG_DONE);
	if (!mwin) return 0;

	DoMethod(app, OM_ADDMEMBER, mwin);
	setatt(mwin, MUIA_Window_Open, TRUE);

	ULONG sigs = 0;
	while (DoMethod(app, MUIM_Application_NewInput, &sigs) != MUIV_MsgWin_Close)
	{
		if (sigs)	sigs = Wait(sigs);
	}

	setatt(mwin, MUIA_Window_Open, FALSE);
	DoMethod(app, OM_REMMEMBER, mwin);
	DisposeObject(mwin);

	DoMethod(obj, MUIM_Board_NewGame);

	setatt(win, MUIA_Window_Sleep, FALSE);
  return 0;
}


/****************************************************************************************
  ComputerMove
****************************************************************************************/

ULONG Board_ComputerMove(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
  Object* win = (Object*)xget(obj, MUIA_WindowObject);
  Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
  Settings* s = (Settings*)xget(app, MUIA_Abacus_Settings);

	setatt(app, MUIA_Application_Sleep, TRUE);

  Board undo = data->last_board;
  data->last_board  = data->board;		//wg. Diffsdraw

	if (s->depth2 > 2)
	{
    StatusWin_Status status(app, win);
		status.Init();
	  data->board.Computer_Move(status, s->depth2);
		status.Exit();
	}
	else
	{
	  Status status;
	  data->board.Computer_Move(status, s->depth2);
	}

  data->diff        = TRUE;
  data->update_mode = ALLDRAW;
  MUI_Redraw(obj, MADF_DRAWUPDATE);

  if (data->board.outBalls(data->board.me) == 6)
	{
    DoMethod(obj, MUIM_Board_Winner);
	}
	else
	{
  	setatt(win, MUIA_BoardWindow_ActivePlayer, data->ActivePlayerNr());

		if (s->auto2)
		{
	    if (data->ActivePlayerNr() == 2)
  	  {
				DoMethod(app, MUIM_Application_PushMethod,
								 obj, 1, MUIM_Board_ComputerMove);
	    }
			else
			  data->last_board  = undo;
		}
	}

	setatt(app, MUIA_Application_Sleep, FALSE);
	return 0;
}


/****************************************************************************************
  AskMinMax
****************************************************************************************/

SAVEDS ULONG Board_AskMinMax(struct IClass*         cl, 
                             Object*                obj, 
                             struct MUIP_AskMinMax* msg)
{
  DoSuperMethodA(cl, obj, (Msg)msg);
  msg->MinMaxInfo->MinWidth  += 200;
  msg->MinMaxInfo->DefWidth  += 300;
  msg->MinMaxInfo->MaxWidth  += MUI_MAXMAX;
  msg->MinMaxInfo->MinHeight += 100;
  msg->MinMaxInfo->DefHeight += 200;
  msg->MinMaxInfo->MaxHeight += MUI_MAXMAX;
  return 0;
}


/****************************************************************************************
  Setup / Cleanup
****************************************************************************************/

SAVEDS ULONG Board_Setup(struct IClass* cl, Object* obj, Msg msg)
{
  if (!DoSuperMethodA(cl, obj, msg)) return(FALSE);
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);

  MUI_RequestIDCMP(obj, IDCMP_MOUSEBUTTONS);
  return TRUE;
}

SAVEDS ULONG Board_Cleanup(struct IClass* cl, Object* obj, Msg msg)
{
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);
  MUI_ReleasePen(muiRenderInfo(obj), data->pen1); data->pen1 = -1;
  MUI_ReleasePen(muiRenderInfo(obj), data->pen2); data->pen2 = -1;
  MUI_ReleasePen(muiRenderInfo(obj), data->pen3); data->pen3 = -1;
  MUI_ReleasePen(muiRenderInfo(obj), data->pen4); data->pen4 = -1;
  data->newsettings = TRUE; // damit die Pens nachher wieder allokiert werden

  MUI_RejectIDCMP(obj,IDCMP_MOUSEBUTTONS);
  return(DoSuperMethodA(cl, obj, msg));
}


/****************************************************************************************
  Handle_Input
****************************************************************************************/

SAVEDS ULONG Board_HandleInput(struct IClass*           cl,
                               Object*                  obj, 
                               struct MUIP_HandleInput* msg)
{
  Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
  Object* win = (Object*)xget(obj, MUIA_WindowObject);
  struct Board_Data *data = (Board_Data*)INST_DATA(cl,obj);

  if (  !msg->imsg ||
       (!(msg->imsg->Class == IDCMP_MOUSEBUTTONS) && 
        !(msg->imsg->Class == IDCMP_MOUSEMOVE   ))
     )  return(DoSuperMethodA(cl, obj, (Msg)msg));

  int ball = data->GetNrOf(msg->imsg->MouseX, msg->imsg->MouseY);
  if (ball == -1) return(DoSuperMethodA(cl, obj, (Msg)msg));

  switch (msg->imsg->Class)
  {
    /*
    **
    **  IDCMP_MOUSEBUTTONS
    **
    */

    case IDCMP_MOUSEBUTTONS:
    {     
      switch (msg->imsg->Code)
      {
        /*
        **  SELECTDOWN
        */

        case SELECTDOWN:
        {
          /*
          **  Erste Selektion
          */

          if (data->ball[0] == -1)
          {
            if (data->board.field[ball] == data->board.me)
            {
              data->ball[0]  			 = ball;
              data->update_mode    = SELSDRAW;
              data->setsels        = TRUE;
              MUI_Redraw(obj, MADF_DRAWUPDATE);
              MUI_RequestIDCMP(obj, IDCMP_MOUSEMOVE);
            }
          }

          /*
          **  Selektion canceln
          */
                    
          else if (data->ball[0] == ball || 
                   data->ball[1] == ball || 
                   data->ball[2] == ball)
          {
            data->setsels       = FALSE;
            data->update_mode   = SELSDRAW;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
            data->ball[0] = -1;
            data->ball[1] = -1;
            data->ball[2] = -1;
          }
          
          /*
          **  Zweite Selektion (Richtung)
          */
          
          else
          {
            int dir = Board::Dir(data->ball[0], ball);
            if (dir != -1 && 
            		data->board.Test(data->ball[0], dir, data->ball[1], data->ball[2]) >= 0)
            {             
              //  Selektionen löschen

              data->setsels     = FALSE;
              data->update_mode = SELSDRAW;
              MUI_Redraw(obj, MADF_DRAWUPDATE);

              //  Zug ausführen

              data->last_board = data->board;
              data->board.Move(data->ball[0], dir, data->ball[1], data->ball[2]);
              data->ball[0] = -1;
              data->ball[1] = -1;
              data->ball[2] = -1;
              data->diff          = TRUE;
              data->update_mode   = ALLDRAW;
              MUI_Redraw(obj, MADF_DRAWUPDATE);

					    if (data->board.outBalls(data->board.me) == 6)
							{
	              DoMethod(obj, MUIM_Board_Winner);
							}
							else
							{
					      setatt(win, MUIA_BoardWindow_ActivePlayer, data->ActivePlayerNr());

  	            Settings* s = (Settings*)xget(app, MUIA_Abacus_Settings);
    	          if (s->auto2)
      	        {
									DoMethod(app, MUIM_Application_PushMethod,
													 obj, 1, MUIM_Board_ComputerMove);
              	}
							}

            }
          }
          
          break;
        } // End SELECTDOWN

        /*
        **  SELECTUP
        */

        case SELECTUP:
        {
          MUI_RejectIDCMP(obj, IDCMP_MOUSEMOVE);
          break;
        } // End SELECTUP

      } // End UP/DOWN case
      break;
    } //  End IDCMP_MOUSEBUTTONS


    /*
    **
    **  IDCMP_MOUSEMOVE
    **
    */

    case IDCMP_MOUSEMOVE:
    {
      char me = data->board.me;
      int b1 = -1, b2 = -1;
      for (int i = 0; i < 6; i++)
      {
        int n = Board::next[data->ball[0]][i];
        if (n == ball) 
        {
          b1 = ball;
          if (data->board.field[b1] != me) b1 = -1;             //  nur eigene
        }
        else if (n != -1 && Board::next[n][i] == ball)
        {
          b1 = n;
          b2 = ball;
          if (data->board.field[b1] != me) {b1 = -1; b2 = -1;}  //  nicht über
          if (data->board.field[b2] != me) b2 = -1;             //  Lücken
        }
      }

      if (data->ball[1] != b1 || data->ball[2] != b2)
      {
        //  Selektionen löschen

        data->setsels       = FALSE;
        data->update_mode   = SELSDRAW;
        MUI_Redraw(obj, MADF_DRAWUPDATE);

        //  Neue setzen

        data->ball[1] = b1;
        data->ball[2] = b2;
        data->setsels       = TRUE;
        data->update_mode   = SELSDRAW;
        MUI_Redraw(obj, MADF_DRAWUPDATE);
      }

      break;
    } // End IDCMP_MOUSEMOVE

  } // End switch Class
  return(DoSuperMethodA(cl, obj, (Msg)msg));
}


/****************************************************************************************
  Draw
****************************************************************************************/

SAVEDS ULONG Board_Draw(struct IClass* cl, Object* obj, struct MUIP_Draw* msg)
{
  DoSuperMethodA(cl, obj, (Msg)msg);
  if (!(msg->flags & (MADF_DRAWUPDATE + MADF_DRAWOBJECT))) return 0; // Überflüssig?

  struct Board_Data* data = (Board_Data*)INST_DATA(cl,obj);
  RastPort* rp  = _rp(obj);
  struct AreaInfo areainfo;
  struct TmpRas   tmp;

  //APTR      cliphandle  = MUI_AddClipping(muiRenderInfo(obj), _mleft (obj), _mtop(obj), 
  //                                                            _mwidth(obj), _mheight(obj)); // Überflüssig?
  int       w           = rp->BitMap->BytesPerRow * 8,
            h           = rp->BitMap->Rows;
  PLANEPTR  mem         = AllocRaster(w, h);

  InitArea(&areainfo, &data->areabuffer, 400);
  rp->TmpRas   = (struct TmpRas*)InitTmpRas(&tmp, mem, RASSIZE(w, h));
  rp->AreaInfo = &areainfo;

  /*
  **
  **  DRAWOBJECT
  **
  */

  if (msg->flags & MADF_DRAWOBJECT)
  {
    data->left   = _mleft  (obj) + 5;
    data->right  = _mright (obj) - 5;
    data->top    = _mtop   (obj) + 5;
    data->bottom = _mbottom(obj) - 5;
    data->width  = data->right  - data->left + 1;
    data->height = data->bottom - data->top  + 1;
    data->mdx    = _mwidth (obj) / 21;          // Abstand zwischen Minikugelmittelpunkten
    data->mdy    = _mheight(obj) / 21;          //
    data->mrx    = int((0.8 * data->mdx) / 2);  // Minikugelradius
    data->mry    = int((0.8 * data->mdy) / 2);  //
    data->dx     = data->width  / 9;            // Abstand zwischen Kugelmittelpunkten
    data->dy     = data->height / 9;            //
    data->rx     = int((0.8 * data->dx) / 2);   // Kugelradius
    data->ry     = int((0.8 * data->dy) / 2);   //

    data->diff        = FALSE;
    data->setsels     = TRUE;
  }


  /*
  **
  **  ALLDRAW
  **
  */

  if (data->update_mode == ALLDRAW || msg->flags & MADF_DRAWOBJECT)
  {
    /*
    **  New settings?
    */

    if (data->newsettings)
    {
      Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
      Settings* s = (Settings*)xget(app, MUIA_Abacus_Settings);

      if (data->pen1 != -1) MUI_ReleasePen(muiRenderInfo(obj), data->pen1);
      if (data->pen2 != -1) MUI_ReleasePen(muiRenderInfo(obj), data->pen2);
      if (data->pen3 != -1) MUI_ReleasePen(muiRenderInfo(obj), data->pen3);
      if (data->pen4 != -1) MUI_ReleasePen(muiRenderInfo(obj), data->pen4);
      data->pen1 = MUI_ObtainPen(muiRenderInfo(obj), &s->color1, 0);
      data->pen2 = MUI_ObtainPen(muiRenderInfo(obj), &s->color2, 0);
      data->pen3 = MUI_ObtainPen(muiRenderInfo(obj), &s->color3, 0);
      data->pen4 = MUI_ObtainPen(muiRenderInfo(obj), &s->color4, 0);

      data->dirs        = s->dirs;
      data->newsettings = FALSE;
    }

    /*
    **  Spielfeld
    */

    for (int color = 0; color < 3; color++)
    {
      BOOL draw = FALSE;
      for (int f = 0; f < 61; f++)
      {
        if (data->board.field[f] != data->last_board.field[f] || !data->diff)
        {
          if (color == 1 && data->board.field[f] == Board::white  ||
              color == 2 && data->board.field[f] == Board::black  ||
              color == 0 && data->board.field[f] == Board::empty   ) 
          {
            int cx, cy;
            data->GetCenterOf(f, cx, cy);
            AreaEllipse(rp, cx, cy, data->rx, data->ry);
            draw = TRUE;
          }
        }
      }
      if (draw) 
      {
        switch(color)
        {
          case 0: SetAPen (rp, MUIPEN(data->pen3)); break;
          case 1: SetAPen (rp, MUIPEN(data->pen1)); break;
          case 2: SetAPen (rp, MUIPEN(data->pen2)); break;
        }
        AreaEnd(rp);
      }
    }

    /*
    **  Minikugeln
    */

    BYTE o = rp->AOlPen;
    int mx = data->right - data->mrx, my ,i;

    if (data->board.outBalls(Board::white) != data->last_board.outBalls(Board::white) || !data->diff)
    {
      SetAPen(rp, MUIPEN(data->pen1));
      SetOPen(rp, MUIPEN(data->pen1));
      my = data->top   + data->mry;
      for (i = 0; i < 6; i++)
      {
        if (i == data->board.outBalls(Board::white)) SetAPen(rp, 0);
        AreaEllipse(rp, mx, my + data->mdy * i, data->mrx, data->mry);
        AreaEnd(rp);
      }
    }

    if (data->board.outBalls(Board::black) != data->last_board.outBalls(Board::black) || !data->diff)
    {
      SetAPen(rp, MUIPEN(data->pen2));
      SetOPen(rp, MUIPEN(data->pen2));
      my = data->bottom - data->mry;
      for (i = 0; i < 6; i++)
      {
        if (i == data->board.outBalls(Board::black)) SetAPen(rp, 0);
        AreaEllipse(rp, mx, my - data->mdy * i, data->mrx, data->mry);
        AreaEnd(rp);
      }
    }

    SetOPen(rp, o);

  }

  /*
  **
  **  SELSDRAW
  **
  */

  if (data->update_mode == SELSDRAW || msg->flags & MADF_DRAWOBJECT)
  {
    /*
    **  Selektiere (de-)markieren
    */

    for (int i = 0; i < 3; i++)
    {
      if (data->ball[i] != -1)
      {
        int cx, cy;
        data->GetCenterOf(data->ball[i], cx, cy);
        if (data->setsels)
        {
          SetAPen(rp, MUIPEN(data->pen4));
          AreaEllipse(rp, cx, cy, int(data->rx / 2.5), int(data->ry / 2.5));
        }
        else
        {
					char c = data->board.field[data->ball[i]];

          if 			(c == Board::white)	SetAPen(rp, MUIPEN(data->pen1));
					else if (c == Board::black) SetAPen(rp, MUIPEN(data->pen2));
					else											 	SetAPen(rp, MUIPEN(data->pen3));
 
          AreaEllipse(rp, cx, cy, data->rx, data->ry);
        }
        AreaEnd(rp);
      }
    }

    /*
    **  Zugmöglichkeiten anzeigen/löschen
    */

    if (data->dirs && data->ball[0] != -1)
    {
      for (int dir = 0; dir < 6; dir++)
      {
        if (data->board.Test(data->ball[0], dir, data->ball[1], data->ball[2]) >= 0)
        {
          int n = Board::next[data->ball[0]][dir];
          if (n != -1)
          {
            int cx, cy;
            data->GetCenterOf(n, cx, cy);

            if (data->setsels)
            {
              SetAPen(rp, MUIPEN(data->pen4));
              AreaEllipse(rp, cx, cy, data->rx, data->ry);
              AreaEnd(rp);
            }

						char c = data->board.field[n];
    	      if 			(c == Board::white)	SetAPen(rp, MUIPEN(data->pen1));
						else if (c == Board::black) SetAPen(rp, MUIPEN(data->pen2));
						else											 	SetAPen(rp, MUIPEN(data->pen3));

            if (data->setsels)
              AreaEllipse(rp, cx, cy, data->rx - 2, data->ry - 2);
            else
              AreaEllipse(rp, cx, cy, data->rx, data->ry);
            AreaEnd(rp);

          }
        }
      }
    }

  }

  
  rp->TmpRas = NULL;
  rp->AreaInfo = NULL;
  FreeRaster(mem, w, h);
  rp->Flags &= ~AREAOUTLINE;
  //MUI_RemoveClipping(muiRenderInfo(obj), cliphandle);

  return(0);
}


/****************************************************************************************
  New / Dispose
****************************************************************************************/

ULONG Board_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
  Board_Data tmp;

  obj = (Object*)DoSuperNew(cl, obj, TAG_MORE, msg->ops_AttrList);
  if (obj)
  {
    tmp.last_board = tmp.board;
    tmp.pen1       = -1;
    tmp.pen2       = -1;
    tmp.pen3       = -1;
    tmp.pen4       = -1;
		tmp.ball[0]    = -1;
		tmp.ball[1]    = -1;
		tmp.ball[2]    = -1;
    struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
    *data = tmp;
  }
  return (ULONG)obj;
}


/****************************************************************************************
  Set
****************************************************************************************/

ULONG Board_Set(struct IClass* cl, Object* obj, struct opSet* msg)
{
  struct Board_Data* data = (Board_Data*)INST_DATA(cl, obj);
  struct TagItem *tag;
  tag = FindTagItem(MUIA_Board_Board, msg->ops_AttrList);
  if (tag)
  {
    /*
    **  Selektionen löschen
    */

    data->setsels     = FALSE;
    data->update_mode = SELSDRAW;
    MUI_Redraw(obj, MADF_DRAWUPDATE);

    /*
    **  Board zeichnen
    */

    data->last_board  = data->board;
    data->board       = *(Board*)tag->ti_Data;
    data->diff        = TRUE;
    data->update_mode = ALLDRAW;
		data->ball[0]    	= -1;
		data->ball[1]    	= -1;
		data->ball[2]    	= -1;
    MUI_Redraw(obj, MADF_DRAWUPDATE);

    /*
    **  Selektionen setzen
    */

    data->setsels     = TRUE;
    data->update_mode = SELSDRAW;
    MUI_Redraw(obj, MADF_DRAWUPDATE);

    /*
    **  Richtigen Spieler setzen
    */

    Object* win = (Object*)xget(obj, MUIA_WindowObject);
    if (data->board.me == Board::white)
      setatt(win, MUIA_BoardWindow_ActivePlayer, 1);
    else
      setatt(win, MUIA_BoardWindow_ActivePlayer, 2);

    return TRUE;
  }
  return DoSuperMethodA(cl, obj, (Msg)msg);
}


/****************************************************************************************
  Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG Board_Dispatcher(REG(a0) struct IClass* cl, 
                                  REG(a2) Object*        obj, 
                                  REG(a1) Msg            msg)
{
  switch(msg->MethodID)
  {
    case OM_NEW                 : return(Board_New         (cl, obj, (opSet*)msg));
    case OM_SET                 : return(Board_Set         (cl, obj, (opSet*)msg));
    case MUIM_Cleanup           : return(Board_Cleanup     (cl, obj, msg));
    case MUIM_Setup             : return(Board_Setup       (cl, obj, msg));
    case MUIM_HandleInput       : return(Board_HandleInput (cl, obj, (MUIP_HandleInput*)msg));
    case MUIM_AskMinMax         : return(Board_AskMinMax   (cl, obj, (MUIP_AskMinMax*)msg));
    case MUIM_Draw              : return(Board_Draw        (cl, obj, (MUIP_Draw*)msg));

    case MUIM_Board_NewSettings : return(Board_NewSettings (cl, obj, msg));
    case MUIM_Board_Undo        : return(Board_Undo        (cl, obj, msg));
    case MUIM_Board_Load        : return(Board_Load        (cl, obj, msg));
    case MUIM_Board_Save        : return(Board_Save        (cl, obj, msg));
    case MUIM_Board_NewGame     : return(Board_NewGame     (cl, obj, msg));
    case MUIM_Board_Winner			: return(Board_Winner			 (cl, obj, msg));
    case MUIM_Board_ComputerMove: return(Board_ComputerMove(cl, obj, msg));
  }
  return(DoSuperMethodA(cl, obj, msg));
}

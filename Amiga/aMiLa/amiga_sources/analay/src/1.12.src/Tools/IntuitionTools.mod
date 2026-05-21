(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE IntuitionTools;

IMPORT I  : Intuition,
(*       oi : OldIntuition,*)
       ni : NewIntuition,
       g  : Graphics,
       s  : SYSTEM,
       e  : Exec;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

VAR os2 : BOOLEAN;
    lm  : I.IntuiMessagePtr;

PROCEDURE SetScreen*(width,height,depth:INTEGER;title:e.STRPTR;ntsc,oscan,a4:BOOLEAN):I.ScreenPtr;

VAR screen : I.ScreenPtr;

BEGIN
(*  IF os2 THEN*)
    screen:=ni.SetScreen(width,height,depth,title,ntsc,oscan,a4);
(*(*  ELSE
    screen:=oi.SetScreen(width,height,depth,title);*)
  END;*)
  RETURN screen;
END SetScreen;

PROCEDURE SetWindow*(xpos,ypos,width,height:INTEGER;title:e.STRPTR;idcmp,flags:LONGSET;screen:I.ScreenPtr):I.WindowPtr;

VAR window : I.WindowPtr;

BEGIN
  IF (width>screen.width) AND (I.windowSizing IN idcmp) THEN
    width:=screen.width;
  END;
  IF xpos+width>screen.width THEN
    xpos:=screen.width-width;
  END;
  IF xpos<0 THEN
    xpos:=0;
  END;
  IF (height>screen.height) AND (I.windowSizing IN idcmp) THEN
    height:=screen.height;
  END;
  IF ypos+height>screen.height THEN
    ypos:=screen.height-height;
  END;
  IF ypos<0 THEN
    ypos:=0;
  END;
(*  IF os2 THEN*)
    window:=ni.SetWindow(xpos,ypos,width,height,title,idcmp,flags,NIL,screen);
(*(*  ELSE
    window:=oi.SetWindow(xpos,ypos,width,height,title,idcmp,flags,NIL,screen);*)
  END;*)
  RETURN window;
END SetWindow;

PROCEDURE SetGadgetWindow*(xpos,ypos,width,height:INTEGER;title:e.STRPTR;idcmp,flags:LONGSET;gadgetList:I.GadgetPtr;screen:I.ScreenPtr):I.WindowPtr;

VAR window : I.WindowPtr;

BEGIN
  IF (width>screen.width) AND (I.windowSizing IN flags) THEN
    width:=screen.width;
  END;
  IF xpos+width>screen.width THEN
    xpos:=screen.width-width;
  END;
  IF xpos<0 THEN
    xpos:=0;
  END;
  IF (height>screen.height) AND (I.windowSizing IN flags) THEN
    height:=screen.height;
  END;
  IF ypos+height>screen.height THEN
    ypos:=screen.height-height;
  END;
  IF ypos<0 THEN
    ypos:=0;
  END;
(*  IF os2 THEN*)
    window:=ni.SetWindow(xpos,ypos,width,height,title,idcmp,flags,gadgetList,screen);
(*(*  ELSE
    window:=oi.SetWindow(xpos,ypos,width,height,title,idcmp,flags,gadgetList,screen);*)
  END;*)
  RETURN window;
END SetGadgetWindow;

PROCEDURE GetIMes*(wind:I.WindowPtr;VAR class:LONGSET;VAR code:INTEGER;VAR address:s.ADDRESS);

VAR message : I.IntuiMessagePtr;

BEGIN
  class:=LONGSET{};
  code:=0;
  address:=NIL;
  message:=e.GetMsg(wind.userPort);
  lm:=message;
  IF message#NIL THEN
    class:=message.class;
    code:=message.code;
    address:=message.iAddress;
    e.ReplyMsg(message);
  END;
END GetIMes;

PROCEDURE GetIMesTime*(wind:I.WindowPtr;VAR class:LONGSET;VAR code:INTEGER;VAR address:s.ADDRESS;VAR secs,micros:LONGINT);

VAR message : I.IntuiMessagePtr;

BEGIN
  class:=LONGSET{};
  code:=0;
  address:=NIL;
  message:=e.GetMsg(wind.userPort);
  lm:=message;
  IF message#NIL THEN
    class:=message.class;
    code:=message.code;
    address:=message.iAddress;
    secs:=message.time.secs;
    micros:=message.time.micro;
    e.ReplyMsg(message);
  END;
END GetIMesTime;

PROCEDURE GetMousePos*(wi:I.WindowPtr;VAR x,y:INTEGER);

BEGIN
  x:=wi.mouseX;
  y:=wi.mouseY;
END GetMousePos;

PROCEDURE GetMousePosLM*(wi:I.WindowPtr;VAR x,y:INTEGER);

BEGIN
  IF lm#NIL THEN
    x:=lm.mouseX;
    y:=lm.mouseY;
  ELSE
    GetMousePos(wi,x,y);
  END;
END GetMousePosLM;

PROCEDURE AllocRastPort*(width,height,depth:INTEGER):g.RastPortPtr;

VAR rast : g.RastPortPtr;
    map  : g.BitMapPtr;
    i    : INTEGER;

BEGIN
  width:=(width+7) DIV 8;
  width:=width*8;
  rast:=NIL;
  rast:=e.AllocMem(s.SIZE(g.RastPort),LONGSET{e.chip,e.memClear});
  IF rast#NIL THEN
    map:=e.AllocMem(s.SIZE(g.BitMap),LONGSET{e.chip,e.memClear});
    IF map#NIL THEN
      g.InitRastPort(rast^);
      g.InitBitMap(map^,depth,width,height);
      FOR i:=0 TO depth-1 DO
        map.planes[i]:=NIL;
        map.planes[i]:=g.AllocRaster(map.bytesPerRow*8,map.rows);
        IF map.planes[i]=NIL THEN
          WHILE i>0 DO
            DEC(i);
            g.FreeRaster(map.planes[i],map.bytesPerRow*8,map.rows);
          END;
          i:=depth+1;
        END;
      END;
      IF i>=depth+1 THEN
        e.FreeMem(map,s.SIZE(g.BitMap));
        e.FreeMem(rast,s.SIZE(g.RastPort));
        rast:=NIL;
      ELSE
        rast.bitMap:=map;
      END;
    ELSE
      e.FreeMem(rast,s.SIZE(g.RastPort));
      rast:=NIL;
    END;
  END;
  RETURN rast;
END AllocRastPort;

PROCEDURE FreeRastPort*(VAR rast:g.RastPortPtr);

VAR map    : g.BitMapPtr;
    width,
    height,
    depth,i: INTEGER;

BEGIN
  map:=rast.bitMap;
  width:=map.bytesPerRow*8;
  height:=map.rows;
  depth:=map.depth;
  FOR i:=0 TO depth-1 DO
    g.FreeRaster(map.planes[i],width,height);
  END;
  e.FreeMem(map,s.SIZE(g.BitMap));
  e.FreeMem(rast,s.SIZE(g.RastPort));
END FreeRastPort;

PROCEDURE DrawBevelBorder*(rast:g.RastPortPtr;x1,y1,wi,he:INTEGER);

VAR x2,y2 : INTEGER;

BEGIN
  x2:=x1+wi-1;
  y2:=y1+he-1;
  g.SetAPen(rast,2);
  g.Move(rast,x1,y1);
  g.Draw(rast,x1,y2);
  g.Draw(rast,x1,y2-1);
  g.Draw(rast,x1+1,y2-1);
  g.Draw(rast,x1+1,y1);
  g.Draw(rast,x2-1,y1);

  g.SetAPen(rast,1);
  g.Move(rast,x2,y2);
  g.Draw(rast,x2,y1);
  g.Draw(rast,x2,y1+1);
  g.Draw(rast,x2-1,y1+1);
  g.Draw(rast,x2-1,y2);
  g.Draw(rast,x1+1,y2);
END DrawBevelBorder;

PROCEDURE DrawBevelBorderIn*(rast:g.RastPortPtr;x1,y1,wi,he:INTEGER);

VAR x2,y2 : INTEGER;

BEGIN
  x2:=x1+wi-1;
  y2:=y1+he-1;
  g.SetAPen(rast,1);
  g.Move(rast,x1,y1);
  g.Draw(rast,x1,y2);
  g.Draw(rast,x1,y2-1);
  g.Draw(rast,x1+1,y2-1);
  g.Draw(rast,x1+1,y1);
  g.Draw(rast,x2-1,y1);

  g.SetAPen(rast,2);
  g.Move(rast,x2,y2);
  g.Draw(rast,x2,y1);
  g.Draw(rast,x2,y1+1);
  g.Draw(rast,x2-1,y1+1);
  g.Draw(rast,x2-1,y2);
  g.Draw(rast,x1+1,y2);
END DrawBevelBorderIn;

PROCEDURE DrawBorder*(rast:g.RastPortPtr;x1,y1,wi,he:INTEGER);

BEGIN
  DrawBevelBorder(rast,x1,y1,wi,he);
END DrawBorder;

PROCEDURE DrawBorderIn*(rast:g.RastPortPtr;x1,y1,wi,he:INTEGER);

BEGIN
  DrawBevelBorderIn(rast,x1,y1,wi,he);
END DrawBorderIn;

BEGIN
(*  IF I.int.libNode.version>=36 THEN
    os2:=TRUE;
  ELSE
    os2:=FALSE;
  END;*)
END IntuitionTools.


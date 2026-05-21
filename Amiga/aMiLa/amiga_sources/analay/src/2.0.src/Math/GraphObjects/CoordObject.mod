(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
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


MODULE CoordObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       tt : TextTools,
       ft : FunctionTrees,
       w  : Window,
       co : Coords,
       c  : Conversions,
       m  : Multitasking,
       lrc: LongRealConversions,
       NoGuruRq;

TYPE CoordObject * = POINTER TO CoordObjectDesc;
     CoordObjectDesc * = RECORD(m.ChangeAbleDesc)
       window         - : w.Window;
       coords           : co.CoordSystem;
       worldx,worldy    : LONGREAL;
       picx,picy        : LONGINT;
       worldxs,worldys,
       picxs,picys      : ARRAY 80 OF CHAR;
       snaptype       - : INTEGER; (* One of the snaptypes. *)
       world            : BOOLEAN;
     END;

(* Snaptypes for GraphObject.snaptype *)

CONST snapToNowhere * = 0;
      snapToFunc    * = 1;
      snapToGrid    * = 2;

PROCEDURE (coordobj:CoordObject) Init*;

BEGIN
  coordobj.window:=NIL;
  coordobj.coords:=NIL;
  coordobj.worldx:=0;
  coordobj.worldy:=0;
  coordobj.worldxs:="0";
  coordobj.worldys:="0";
  coordobj.picxs:="0";
  coordobj.picys:="0";
  coordobj.world:=TRUE;
  coordobj.snaptype:=snapToNowhere;
  coordobj.Init^;
END Init;

PROCEDURE (coordobj:CoordObject) Copy*(dest:l.Node);

BEGIN
  WITH dest: CoordObject DO
    dest.window:=coordobj.window;
    dest.coords:=coordobj.coords;
    dest.worldx:=coordobj.worldx;
    dest.worldy:=coordobj.worldy;
    dest.picx:=coordobj.picx;
    dest.picy:=coordobj.picy;
    COPY(coordobj.worldxs,dest.worldxs);
    COPY(coordobj.worldys,dest.worldys);
    COPY(coordobj.picxs,dest.picxs);
    COPY(coordobj.picys,dest.picys);
    dest.snaptype:=coordobj.snaptype;
    dest.world:=coordobj.world;
  END;
END Copy;

PROCEDURE (coordobj:CoordObject) AllocNew*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(CoordObject));
  RETURN node;
END AllocNew;

PROCEDURE (coordobj:CoordObject) RefreshXWorldString*;

VAR bool : BOOLEAN;

BEGIN
  bool:=lrc.RealToString(coordobj.worldx,coordobj.worldxs,7,7,FALSE);
  tt.Clear(coordobj.worldxs);
END RefreshXWorldString;

PROCEDURE (coordobj:CoordObject) RefreshYWorldString*;

VAR bool : BOOLEAN;

BEGIN
  bool:=lrc.RealToString(coordobj.worldy,coordobj.worldys,7,7,FALSE);
  tt.Clear(coordobj.worldys);
END RefreshYWorldString;

PROCEDURE (coordobj:CoordObject) RefreshXPicString*;

VAR bool      : BOOLEAN;

BEGIN
  bool:=c.IntToString(coordobj.picx,coordobj.picxs,7);
  tt.Clear(coordobj.picxs);
END RefreshXPicString;

PROCEDURE (coordobj:CoordObject) RefreshYPicString*;

VAR bool      : BOOLEAN;

BEGIN
  bool:=c.IntToString(coordobj.picy,coordobj.picys,7);
  tt.Clear(coordobj.picys);
END RefreshYPicString;

PROCEDURE (coordobj:CoordObject) SetWindow*(window:w.Window);

BEGIN
  coordobj.window:=window;
END SetWindow;

PROCEDURE (coordobj:CoordObject) GetWindow*():w.Window;

BEGIN
  RETURN coordobj.window;
END GetWindow;

PROCEDURE (coordobj:CoordObject) SetCoordSystem*(coords:co.CoordSystem);

BEGIN
  coordobj.coords:=coords;
END SetCoordSystem;

PROCEDURE (coordobj:CoordObject) GetCoordSystem*():co.CoordSystem;

BEGIN
  RETURN coordobj.coords;
END GetCoordSystem;

PROCEDURE (coordobj:CoordObject) RefreshOtherCoord*(rect:co.Rectangle);

(* Refreshes either the world or the pic coordinates. *)

VAR worldx,worldy : LONGREAL;
    picx,picy     : INTEGER;

BEGIN
  IF (coordobj.coords#NIL) & (rect#NIL) THEN
    IF coordobj.world THEN
      coordobj.coords.WorldToPic(rect,coordobj.worldx,coordobj.worldy,picx,picy);
      IF picx#coordobj.picx THEN
        coordobj.picx:=picx;
        coordobj.RefreshXPicString;
      END;
      IF picy#coordobj.picy THEN
        coordobj.picy:=picy;
        coordobj.RefreshYPicString;
      END;
    ELSE
      coordobj.coords.PicToWorld(rect,SHORT(coordobj.picx),SHORT(coordobj.picy),worldx,worldy);
      IF worldx#coordobj.worldx THEN
        coordobj.worldx:=worldx;
        coordobj.RefreshXWorldString;
      END;
      IF worldy#coordobj.worldy THEN
        coordobj.worldy:=worldy;
        coordobj.RefreshYWorldString;
      END;
    END;
  END;
END RefreshOtherCoord;

PROCEDURE (coordobj:CoordObject) RefreshCoordWorld*(rect:co.Rectangle);

VAR worldx,worldy : LONGREAL;

BEGIN
  IF (coordobj.coords#NIL) & (rect#NIL) THEN
    coordobj.coords.PicToWorld(rect,SHORT(coordobj.picx),SHORT(coordobj.picy),worldx,worldy);
    IF worldx#coordobj.worldx THEN
      coordobj.worldx:=worldx;
      coordobj.RefreshXWorldString;
    END;
    IF worldy#coordobj.worldy THEN
      coordobj.worldy:=worldy;
      coordobj.RefreshYWorldString;
    END;
  END;
END RefreshCoordWorld;

PROCEDURE (coordobj:CoordObject) RefreshCoordPic*(rect:co.Rectangle);

VAR picx,picy     : INTEGER;

BEGIN
  IF (coordobj.coords#NIL) & (rect#NIL) THEN
    coordobj.coords.WorldToPic(rect,coordobj.worldx,coordobj.worldy,picx,picy);
    IF picx#coordobj.picx THEN
      coordobj.picx:=picx;
      coordobj.RefreshXPicString;
    END;
    IF picy#coordobj.picy THEN
      coordobj.picy:=picy;
      coordobj.RefreshYPicString;
    END;
  END;
END RefreshCoordPic;

PROCEDURE (coordobj:CoordObject) GetCoordsWorld*(rect:co.Rectangle;VAR worldx,worldy:LONGREAL);

BEGIN
  IF ~coordobj.world THEN
    coordobj.RefreshCoordWorld(rect);
  END;
  worldx:=coordobj.worldx;
  worldy:=coordobj.worldy;
END GetCoordsWorld;

PROCEDURE (coordobj:CoordObject) GetCoordsPic*(rect:co.Rectangle;VAR picx,picy:INTEGER);

BEGIN
  IF coordobj.world THEN
    coordobj.RefreshCoordPic(rect);
  END;
  picx:=SHORT(coordobj.picx);
  picy:=SHORT(coordobj.picy);
END GetCoordsPic;

PROCEDURE (coordobj:CoordObject) SetCoordsWorld*(rect:co.Rectangle;worldx,worldy:LONGREAL);

BEGIN
  IF coordobj.worldx#worldx THEN
    coordobj.worldx:=worldx;
    coordobj.RefreshXWorldString;
  END;
  IF coordobj.worldy#worldy THEN
    coordobj.worldy:=worldy;
    coordobj.RefreshYWorldString;
  END;
  coordobj.RefreshCoordPic(rect);
END SetCoordsWorld;

PROCEDURE (coordobj:CoordObject) SetCoordsPic*(rect:co.Rectangle;picx,picy:INTEGER);

BEGIN
  IF coordobj.picx#picx THEN
    coordobj.picx:=picx;
    coordobj.RefreshXPicString;
  END;
  IF coordobj.picy#picy THEN
    coordobj.picy:=picy;
    coordobj.RefreshYPicString;
  END;
  coordobj.RefreshCoordWorld(rect);
END SetCoordsPic;

PROCEDURE (coordobj:CoordObject) GetCoordStrings*(VAR xstr,ystr:ARRAY OF CHAR);

BEGIN
  IF coordobj.world THEN
    COPY(coordobj.worldxs,xstr);
    COPY(coordobj.worldys,ystr);
  ELSE
    COPY(coordobj.picxs,xstr);
    COPY(coordobj.picys,ystr);
  END;
END GetCoordStrings;

PROCEDURE (coordobj:CoordObject) SetCoordStrings*(rect:co.Rectangle;xstr,ystr:ARRAY OF CHAR);

VAR real : LONGREAL;

BEGIN
  IF coordobj.world THEN
    IF ~tt.Compare(xstr,coordobj.worldxs) THEN
      COPY(xstr,coordobj.worldxs);
      coordobj.worldx:=ft.ExpressionToReal(coordobj.worldxs);
    END;
    IF ~tt.Compare(ystr,coordobj.worldys) THEN
      COPY(ystr,coordobj.worldys);
      coordobj.worldy:=ft.ExpressionToReal(coordobj.worldys);
    END;
  ELSE
    IF ~tt.Compare(xstr,coordobj.picxs) THEN
      COPY(xstr,coordobj.picxs);
      coordobj.picx:=SHORT(SHORT(ft.ExpressionToReal(coordobj.picxs)));
    END;
    IF ~tt.Compare(ystr,coordobj.picys) THEN
      COPY(ystr,coordobj.picys);
      coordobj.picy:=SHORT(SHORT(ft.ExpressionToReal(coordobj.picys)));
    END;
  END;
  coordobj.RefreshOtherCoord(rect); (* Actually this call could be left away,
                                       because the proper coordinate (according to CoordObject.world) is refreshed above. *)
END SetCoordStrings;

PROCEDURE (coordobj:CoordObject) GetWorld*():BOOLEAN;

BEGIN
  RETURN coordobj.world;
END GetWorld;

PROCEDURE (coordobj:CoordObject) SetWorld*(rect:co.Rectangle;world:BOOLEAN);

BEGIN
  coordobj.RefreshOtherCoord(rect);
  coordobj.world:=world;
END SetWorld;



PROCEDURE (coordobj:CoordObject) SetSnapType*(snap:INTEGER);

BEGIN
  coordobj.snaptype:=snap;
END SetSnapType;

PROCEDURE (coordobj:CoordObject) GetSnapType*():INTEGER;

BEGIN
  RETURN coordobj.snaptype;
END GetSnapType;

PROCEDURE (coordobj:CoordObject) Snap*;

VAR xcoord,ycoord : LONGREAL;

BEGIN
  IF coordobj.window#NIL THEN
    coordobj.GetCoordsWorld(coordobj.window.rect,xcoord,ycoord);
    IF coordobj.snaptype=snapToFunc THEN
      coordobj.window.SnapToFunction(xcoord,ycoord);
      coordobj.SetCoordsWorld(coordobj.window.rect,xcoord,ycoord);
    END;
  END;
END Snap;

END CoordObject.


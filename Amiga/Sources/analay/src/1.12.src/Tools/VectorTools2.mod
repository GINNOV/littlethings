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


MODULE VectorTools;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       mdt: MathIEEEDoubTrans,
       l  : LinkedLists,
       it : IntuitionTools,
       NoGuruRq;

TYPE VectorObject * = RECORD(l.NodeDesc)
       polies,
       lines  : l.List;
     END;
     Vector * = RECORD(l.NodeDesc)
       xpos,
       ypos,
       oxpos,
       oypos : LONGREAL;
       move  : BOOLEAN;
     END;
     Point * = RECORD(l.NodeDesc)
       xpos,
       ypos  : LONGREAL;
       picx,
       picy  : INTEGER;
       setmove : BOOLEAN;
     END;

VAR screen : I.ScreenPtr;
    wind   : I.WindowPtr;
    rast   : g.RastPortPtr;
    obj    : l.Node;
    bool   : BOOLEAN;
    class  : LONGSET;
    code   : INTEGER;
    address: s.ADDRESS;
    angle  : LONGREAL;
    x,y    : INTEGER;

PROCEDURE NewVectorObject*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(VectorObject));
  WITH node: VectorObject DO
    node.polies:=l.Create();
    node.lines:=l.Create();
  END;
  RETURN node;
END NewVectorObject;

PROCEDURE MovePoly*(obj:l.Node;x,y:LONGREAL);

VAR node : l.Node;

BEGIN
  NEW(node(Vector));
  WITH node: Vector DO
    node.oxpos:=x;
    node.oypos:=y;
    node.move:=TRUE;
  END;
  obj(VectorObject).polies.AddTail(node);
END MovePoly;

PROCEDURE DrawPoly*(obj:l.Node;x,y:LONGREAL);

VAR node : l.Node;

BEGIN
  NEW(node(Vector));
  WITH node: Vector DO
    node.oxpos:=x;
    node.oypos:=y;
    node.move:=FALSE;
  END;
  obj(VectorObject).polies.AddTail(node);
END DrawPoly;

PROCEDURE MoveLine*(obj:l.Node;x,y:LONGREAL);

VAR node : l.Node;

BEGIN
  NEW(node(Vector));
  WITH node: Vector DO
    node.oxpos:=x;
    node.oypos:=y;
    node.move:=TRUE;
  END;
  obj(VectorObject).lines.AddTail(node);
END MoveLine;

PROCEDURE DrawLine*(obj:l.Node;x,y:LONGREAL);

VAR node : l.Node;

BEGIN
  NEW(node(Vector));
  WITH node: Vector DO
    node.oxpos:=x;
    node.oypos:=y;
    node.move:=FALSE;
  END;
  obj(VectorObject).lines.AddTail(node);
END DrawLine;

PROCEDURE Sort*(list:l.List);

VAR node,node2,next : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    next:=node.next;
    node2:=list.head;
    WHILE node2#NIL DO
      IF node(Point).ypos>node2(Point).ypos THEN
        node.Remove;
        node2.AddBefore(node);
        node2:=NIL;
      END;
      IF node2#NIL THEN
        node2:=node2.next;
      END;
    END;
    node:=next;
  END;
END Sort;

PROCEDURE ScaleVector*(vector:l.Node;scalex,scaley:LONGREAL);

BEGIN
  WITH vector: Vector DO
    vector.xpos:=vector.xpos*scalex;
    vector.ypos:=vector.ypos*scaley;
  END;
END ScaleVector;

PROCEDURE RotateVector*(vector:l.Node;angle:LONGREAL);

VAR rad    : LONGREAL;
    angle2 : LONGREAL;

BEGIN
  WITH vector: Vector DO
(*    rad:=mdt.Sqrt(vector.xpos*vector.xpos+vector.ypos*vector.ypos);
    angle:=(angle/180)*3.1415;
    angle2:=angle;
    angle:=angle+mdt.Asin(vector.ypos/rad);
    angle2:=angle2+mdt.Acos(vector.xpos/rad);
    vector.ypos:=mdt.Sin(angle)*rad;
    vector.xpos:=mdt.Cos(angle2)*rad;*)
    angle2:=vector.ypos;
    vector.ypos:=mdt.Cos(angle)*vector.ypos+mdt.Sin(angle)*vector.xpos;
    vector.xpos:=mdt.Cos(angle)*vector.xpos-mdt.Sin(angle)*angle2;
  END;
END RotateVector;

PROCEDURE GetPointList(pointlist:l.List;vector:l.Node;xpos:LONGREAL);

VAR node,last,node2 : l.Node;

BEGIN
  last:=NIL;
  node:=vector;
  WHILE node#NIL DO
    IF (node#NIL) AND (last#NIL) THEN
      WITH node: Vector DO
        WITH last: Vector DO
          node2:=NIL;
          IF node.xpos=xpos THEN
            NEW(node2(Point));
            node2(Point).xpos:=xpos;
            node2(Point).ypos:=node.ypos;
            IF pointlist.tail#NIL THEN
              node2(Point).setmove:=NOT(pointlist.tail(Point).setmove);
              IF (pointlist.tail(Point).xpos=node2(Point).xpos) AND (pointlist.tail(Point).ypos=node2(Point).ypos) THEN
                node2(Point).setmove:=TRUE;
              END;
            ELSE
              node2(Point).setmove:=TRUE;
            END;
            IF (node.next#NIL) AND NOT(node.next(Vector).move) THEN
              IF ((last.xpos>xpos) AND (node.next(Vector).xpos>xpos)) OR ((last.xpos<xpos) AND (node.next(Vector).xpos<xpos)) THEN
                node2(Point).setmove:=TRUE;
              END;
            END;
(*            ELSIF (pointlist.head#NIL) AND (node.xpos=pointlist.head(Point).xpos) THEN
              node2(Point).setmove:=TRUE;
            END;*)
          ELSIF ((node.xpos<xpos) AND (last.xpos>xpos)) OR ((node.xpos>xpos) AND (last.xpos<xpos)) THEN
            NEW(node2(Point));
            node2(Point).xpos:=xpos;
            node2(Point).ypos:=((node.ypos-last.ypos)/(node.xpos-last.xpos))*(xpos-last.xpos)+last.ypos;
            IF pointlist.tail=NIL THEN
              node2(Point).setmove:=TRUE;
            END;
            IF (node.next#NIL) AND NOT(node.next(Vector).move) THEN
              IF ((last.xpos>xpos) AND (node.next(Vector).xpos>xpos)) OR ((last.xpos<xpos) AND (node.next(Vector).xpos<xpos)) THEN
                node2(Point).setmove:=TRUE;
              END;
            END;
          END;
          IF node2#NIL THEN
            pointlist.AddTail(node2);
          END;
        END;
      END;
    ELSE
      WITH node: Vector DO
        node2:=NIL;
        IF node.xpos=xpos THEN
          NEW(node2(Point));
          node2(Point).xpos:=xpos;
          node2(Point).ypos:=node.ypos;
          IF pointlist.tail=NIL THEN
            node2(Point).setmove:=TRUE;
          END;
          pointlist.AddTail(node2);
        END;
      END;
    END;
    last:=node;
    node:=node.next;
    IF (node#NIL) AND (node(Vector).move) THEN
      node:=NIL;
    END;
  END;
(*  IF last#NIL THEN
    WITH last: Vector DO
      IF last.xpos=xpos THEN
        NEW(node2(Point));
        node2(Point).xpos:=xpos;
        node2(Point).ypos:=last.ypos;
        pointlist.AddTail(node2);
      END;
    END;
  END;*)
END GetPointList;

PROCEDURE GetMinMax(vector:l.Node;VAR minx,maxx:LONGREAL);

BEGIN
  maxx:=-100000;
  minx:=100000;
  WHILE vector#NIL DO
    WITH vector: Vector DO
      IF vector.xpos>maxx THEN
        maxx:=vector.xpos;
      END;
      IF vector.xpos<minx THEN
        minx:=vector.xpos;
      END;
    END;
    vector:=vector.next;
    IF (vector#NIL) AND (vector(Vector).move) THEN
      vector:=NIL;
    END;
  END;
END GetMinMax;

PROCEDURE DrawVectorObject*(rast:g.RastPortPtr;obj:l.Node;picx,picy,picwi,piche:INTEGER;angle:LONGREAL;linewidth:INTEGER);

VAR node : l.Node;

PROCEDURE PlotPoly(vector:l.Node);

VAR pointlist : l.List;
    x,y,maxx  : LONGREAL;
    px,py     : INTEGER;
    node      : l.Node;
    move      : BOOLEAN;

BEGIN
  pointlist:=l.Create();
  GetMinMax(vector,x,maxx);
  px:=SHORT(SHORT(SHORT(x-2)));
  WHILE px<maxx DO
    px:=px+1;
    pointlist.Init;
    GetPointList(pointlist,vector,px);
(*    Sort(pointlist);*)
    move:=TRUE;
    node:=pointlist.head;
    WHILE node#NIL DO
      WITH node: Point DO
        move:=node.setmove;
        IF node=pointlist.head THEN
          move:=TRUE;
        END;
        IF move THEN
          g.Move(rast,picx+SHORT(SHORT(SHORT(node.xpos))),picy-SHORT(SHORT(SHORT(node.ypos))));
          bool:=g.WritePixel(rast,picx+SHORT(SHORT(SHORT(node.xpos))),picy-SHORT(SHORT(SHORT(node.ypos))));
        ELSE
          g.Draw(rast,picx+SHORT(SHORT(SHORT(node.xpos))),picy-SHORT(SHORT(SHORT(node.ypos))));
        END;
        IF node.setmove THEN
          move:=FALSE;
        END;
      END;
      move:=NOT(move);
      node:=node.next;
    END;
  END;
END PlotPoly;

BEGIN
  WITH obj: VectorObject DO
    node:=obj.polies.head;
    WHILE node#NIL DO
      WITH node: Vector DO
        node.xpos:=node.oxpos;
        node.ypos:=node.oypos;
      END;
      ScaleVector(node,picwi,piche);
      RotateVector(node,angle);
      node:=node.next;
    END;
    node:=obj.lines.head;
    WHILE node#NIL DO
      WITH node: Vector DO
        node.xpos:=node.oxpos;
        node.ypos:=node.oypos;
      END;
      ScaleVector(node,picwi,piche);
      RotateVector(node,angle);
      node:=node.next;
    END;

    node:=obj.polies.head;
    WHILE node#NIL DO
      PlotPoly(node);
      REPEAT
        node:=node.next;
      UNTIL (node=NIL) OR (node(Vector).move);
    END;
  END;
END DrawVectorObject;

BEGIN
  screen:=it.SetScreen(640,200,2,s.ADR("VectorTools"),TRUE,TRUE,FALSE);
  wind:=it.SetWindow(100,20,400,150,s.ADR("VectorTools"),LONGSET{I.windowDrag,I.windowDepth,I.windowClose,I.windowSizing},LONGSET{I.closeWindow,I.mouseButtons,I.newSize},screen);
  rast:=wind.rPort;

  obj:=NewVectorObject();
  MovePoly(obj,1,0);
  DrawPoly(obj,-1,1);
  DrawPoly(obj,-0.5,0);
  DrawPoly(obj,-1,-1);
  DrawPoly(obj,1,0);
  g.SetAPen(rast,2);
  FOR x:=0 TO 270 BY 30 DO
    g.SetRast(rast,0);
    I.RefreshWindowFrame(wind);
    g.SetAPen(rast,2);
    DrawVectorObject(rast,obj,200,100,20,20,3.1415*x/180,1);
  END;

  LOOP
    e.WaitPort(wind.userPort);
    it.GetIMes(wind,class,code,address);
    IF I.closeWindow IN class THEN
      EXIT;
    ELSIF I.mouseButtons IN class THEN
      it.GetMousePos(wind,x,y);
      angle:=(180/3.1415)*mdt.Atan((((wind.height DIV 2)+10)-y)/(x-((wind.width DIV 2)+10)));
    END;
    g.SetRast(rast,0);
    I.RefreshWindowFrame(wind);
    g.SetAPen(rast,2);
    DrawVectorObject(rast,obj,(wind.width DIV 2)+10,(wind.height DIV 2)+10,(wind.width DIV 2)-20,(wind.height DIV 2)-20,angle,1);
  END;
CLOSE
  I.CloseWindow(wind);
  bool:=I.CloseScreen(screen);
END VectorTools.


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
       d  : Dos,
       s  : SYSTEM,
       mdt: MathIEEEDoubTrans,
       l  : LinkedLists,
       it : IntuitionTools,
       gt : GraphicsTools,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE VectorObject * = RECORD(l.NodeDesc)
       polies,
       lines  : l.List;
       locked : BOOLEAN;
       maxheight * ,
       maxwidth  * : LONGREAL;
     END;
     Vector * = RECORD(l.NodeDesc)
       xpos,
       ypos,
       oxpos,
       oypos : LONGREAL;
       move  : BOOLEAN;
     END;
     Polygon * = RECORD(l.NodeDesc)
       vectors : ARRAY 3 OF l.Node;
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
    x,y,
    x1,y1  : INTEGER;

PROCEDURE NewVectorObject*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(VectorObject));
  WITH node: VectorObject DO
    node.polies:=l.Create();
    node.lines:=l.Create();
    node.locked:=FALSE;
  END;
  RETURN node;
END NewVectorObject;

PROCEDURE NewPolygon*(obj:l.Node;x1,y1,x2,y2,x3,y3:LONGREAL);

VAR node : l.Node;

BEGIN
  NEW(node(Polygon));
  WITH node: Polygon DO
    NEW(node.vectors[0](Vector));
    node.vectors[0](Vector).oxpos:=x1;
    node.vectors[0](Vector).oypos:=y1;
    NEW(node.vectors[1](Vector));
    node.vectors[1](Vector).oxpos:=x2;
    node.vectors[1](Vector).oypos:=y2;
    NEW(node.vectors[2](Vector));
    node.vectors[2](Vector).oxpos:=x3;
    node.vectors[2](Vector).oypos:=y3;
  END;
  obj(VectorObject).polies.AddTail(node);
END NewPolygon;

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

PROCEDURE GetMinMax(poly:l.Node;VAR minx,maxx:LONGREAL);

VAR vector : l.Node;
    i      : INTEGER;

BEGIN
  maxx:=-100000;
  minx:=100000;
  FOR i:=0 TO 2 DO
    vector:=poly(Polygon).vectors[i];
    WITH vector: Vector DO
      IF vector.xpos>maxx THEN
        maxx:=vector.xpos;
      END;
      IF vector.xpos<minx THEN
        minx:=vector.xpos;
      END;
    END;
  END;
END GetMinMax;

PROCEDURE GetBorders(poly:l.Node;x:LONGREAL;VAR y1,y2:LONGREAL);

VAR i,act,a : INTEGER;
    yarray  : ARRAY 2 OF LONGREAL;
    dx,dy   : LONGREAL;

BEGIN
  WITH poly: Polygon DO
    yarray[0]:=MAX(LONGREAL);
    yarray[1]:=MAX(LONGREAL);
    act:=0;
    FOR i:=0 TO 2 DO
      IF (poly.vectors[i](Vector).xpos=x) AND (act<2) THEN
        yarray[act]:=poly.vectors[i](Vector).ypos;
        INC(act);
      END;
    END;
    IF act<1 THEN
      FOR i:=0 TO 2 DO
        a:=i+1;
        IF a>2 THEN
          a:=0;
        END;
        IF (((poly.vectors[i](Vector).xpos<x) AND (poly.vectors[a](Vector).xpos>x)) OR ((poly.vectors[i](Vector).xpos>x) AND (poly.vectors[a](Vector).xpos<x))) AND (act<2) THEN
          dy:=poly.vectors[i](Vector).ypos-poly.vectors[a](Vector).ypos;
          dx:=poly.vectors[i](Vector).xpos-poly.vectors[a](Vector).xpos;
          yarray[act]:=poly.vectors[a](Vector).ypos+(dy/dx)*(x-poly.vectors[a](Vector).xpos);
          INC(act);
        END;
      END;
    END;
    y1:=yarray[0];
    y2:=yarray[1];
  END;
END GetBorders;

PROCEDURE DrawVectorObject*(rast:g.RastPortPtr;obj:l.Node;picx,picy,picwi,piche:INTEGER;angle:LONGREAL;linewidth,lineheight:INTEGER);

VAR node : l.Node;
    i    : INTEGER;
    exit : BOOLEAN;

PROCEDURE PlotPoly(poly:l.Node);

VAR pointlist : l.List;
    x,y1,y2,
    maxx      : LONGREAL;
    px,py     : INTEGER;
    node      : l.Node;
    move      : BOOLEAN;

BEGIN
  GetMinMax(poly,x,maxx);
  px:=SHORT(SHORT(SHORT(x-1)));
  WHILE px<maxx DO
    INC(px);
    GetBorders(poly,px,y1,y2);
    IF (y1<MAX(INTEGER)) AND (y2<MAX(INTEGER)) THEN
      IF y1>=0 THEN
        y1:=y1+0.5;
      ELSE
        y1:=y1-0.5;
      END;
      IF y2>=0 THEN
        y2:=y2+0.5;
      ELSE
        y2:=y2-0.5;
      END;
      g.Move(rast,picx+px,picy-SHORT(SHORT(SHORT(y1))));
      g.Draw(rast,picx+px,picy-SHORT(SHORT(SHORT(y2))));
    END;
  END;
END PlotPoly;

BEGIN
  WITH obj: VectorObject DO
    exit:=FALSE;
    REPEAT
      WHILE obj.locked DO
        d.Delay(10);
      END;
      e.Forbid();
      IF NOT(obj.locked) THEN
        obj.locked:=TRUE;
        exit:=TRUE;
      END;
      e.Permit();
    UNTIL exit;

    angle:=angle*3.141592654/180;
    node:=obj.polies.head;
    WHILE node#NIL DO
      FOR i:=0 TO 2 DO
        WITH node: Polygon DO
          node.vectors[i](Vector).xpos:=node.vectors[i](Vector).oxpos;
          node.vectors[i](Vector).ypos:=node.vectors[i](Vector).oypos;
          RotateVector(node.vectors[i],angle);
          ScaleVector(node.vectors[i],picwi,piche);
        END;
      END;
      node:=node.next;
    END;
    node:=obj.lines.head;
    WHILE node#NIL DO
      WITH node: Vector DO
        node.xpos:=node.oxpos;
        node.ypos:=node.oypos;
      END;
      RotateVector(node,angle);
      ScaleVector(node,picwi,piche);
      node:=node.next;
    END;

    node:=obj.polies.head;
    WHILE node#NIL DO
      PlotPoly(node);
      node:=node.next;
    END;
    gt.SetLineAttrs(rast,linewidth,lineheight,NIL);
    node:=obj.lines.head;
    WHILE node#NIL DO
      IF node(Vector).move THEN
        gt.Move(rast,picx+SHORT(SHORT(SHORT(node(Vector).xpos))),picy-SHORT(SHORT(SHORT(node(Vector).ypos))));
      ELSE
        gt.Draw(rast,picx+SHORT(SHORT(SHORT(node(Vector).xpos))),picy-SHORT(SHORT(SHORT(node(Vector).ypos))));
      END;
      node:=node.next;
    END;
    gt.FreeRastPortNode(rast);
    obj.locked:=FALSE;
  END;
END DrawVectorObject;

PROCEDURE DrawArrowLine*(rast:g.RastPortPtr;obj:l.Node;x1,y1,x2,y2,arrowwidth,arrowheight,linewidth,lineheight:INTEGER);

VAR angle,rad,dx,dy,
    top,bottom,t,b,
    lx2,ly2         : LONGREAL;
    stepx,stepy     : INTEGER;
    node            : l.Node;

BEGIN
  dx:=x2-x1;
  dy:=y2-y1;
  rad:=mdt.Sqrt(dx*dx+dy*dy);
  angle:=mdt.Acos(dx/rad);
  angle:=angle*180/3.141592654;
  IF dy>0 THEN
    angle:=180+angle;
  END;
  DrawVectorObject(rast,obj,x2,y2,arrowwidth,arrowheight,angle,linewidth,lineheight);
  IF x1>x2 THEN
    stepx:=1;
  ELSIF x1<x2 THEN
    stepx:=-1;
  END;
  IF y1>y2 THEN
    stepy:=1;
  ELSIF y1<y2 THEN
    stepy:=-1;
  END;
  IF ABS(dx)>ABS(dy) THEN
    lx2:=x2;
    ly2:=y2;
    LOOP
      top:=ly2;
      bottom:=ly2;
      node:=obj(VectorObject).polies.head;
      WHILE node#NIL DO
        GetBorders(node,lx2+(linewidth DIV 2),t,b);
        IF t>top THEN
          top:=t;
        END;
        IF b<bottom THEN
          bottom:=b;
        END;
        GetBorders(node,lx2-(linewidth DIV 2),t,b);
        IF t>top THEN
          top:=t;
        END;
        IF b<bottom THEN
          bottom:=b;
        END;
        node:=node.next;
      END;
      IF ((stepy>=0) AND (ly2+(lineheight DIV 2)<=-top+y2)) OR ((stepy<0) AND (ly2+(lineheight DIV 2)>=-bottom+y2)) THEN
        lx2:=lx2+stepx;
(*        ly2:=(lx2/(lx2-stepx))*ly2;*)
      ELSE
        EXIT;
      END;
    END;
    ly2:=(lx2/x2)*y2;
  ELSE
    lx2:=x2;
    ly2:=y2;
    LOOP
      top:=MIN(LONGREAL);
      bottom:=MAX(LONGREAL);
      node:=obj(VectorObject).polies.head;
      WHILE node#NIL DO
        GetBorders(node,lx2+(linewidth DIV 2),t,b);
        IF t>top THEN
          top:=t;
        END;
        IF b<bottom THEN
          bottom:=b;
        END;
        GetBorders(node,lx2-(linewidth DIV 2),t,b);
        IF t>top THEN
          top:=t;
        END;
        IF b<bottom THEN
          bottom:=b;
        END;
        node:=node.next;
      END;
      IF ((stepy>0) AND (ly2+(lineheight DIV 2)<=-top+y2)) OR ((stepy<0) AND (ly2+(lineheight DIV 2)>=-bottom+y2)) THEN
        ly2:=ly2+stepy;
(*        lx2:=(ly2/(ly2-stepy))*lx2;*)
      ELSE
        EXIT;
      END;
    END;
    lx2:=(ly2/y2)*x2;
  END;
  gt.SetLineAttrs(rast,linewidth,lineheight,NIL);
  gt.Move(rast,x1,y1);
  gt.Draw(rast,SHORT(SHORT(SHORT(lx2+0.5))),SHORT(SHORT(SHORT(ly2+0.5))));
  gt.FreeRastPortNode(rast);
END DrawArrowLine;

BEGIN
(*  screen:=it.SetScreen(640,200,2,s.ADR("VectorTools"),TRUE,TRUE,FALSE);
  wind:=it.SetWindow(100,20,400,150,s.ADR("VectorTools"),LONGSET{I.windowDrag,I.windowDepth,I.windowClose,I.windowSizing},LONGSET{I.closeWindow,I.mouseButtons,I.newSize},screen);
  rast:=wind.rPort;

  obj:=NewVectorObject();
  NewPolygon(obj,1,0,-1,1,-1,0);
  NewPolygon(obj,1,0,-1,-1,-1,0);
(*  MoveLine(obj,2,0);
  DrawLine(obj,-2,2);
  DrawLine(obj,-1,0);
  DrawLine(obj,-2,-2);
  DrawLine(obj,2,0);*)
  g.SetAPen(rast,2);
  y:=0;
  FOR x:=-100 TO 100 BY 10 DO
    INC(y);
    g.SetRast(rast,0);
    I.RefreshWindowFrame(wind);
    g.SetAPen(rast,2);
    DrawArrowLine(rast,obj,200,100,200-x,100-50,20,10,10,10);
(*    DrawVectorObject(rast,obj,200,100,2*x,x,90,1);*)
  END;

  LOOP
    e.WaitPort(wind.userPort);
    it.GetIMes(wind,class,code,address);
    IF I.closeWindow IN class THEN
      EXIT;
    ELSIF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
      x1:=x;
      y1:=y;
      it.GetMousePos(wind,x,y);
(*      angle:=180/3.1415*mdt.Atan((((wind.height DIV 2)+10)-y)/(x-((wind.width DIV 2)+10)));*)
      g.SetRast(rast,0);
      I.RefreshWindowFrame(wind);
      g.SetAPen(rast,2);
      DrawArrowLine(rast,obj,x1,y1,x,y,20,10,10,10);
    END;
(*    DrawVectorObject(rast,obj,(wind.width DIV 2)+10,(wind.height DIV 2)+10,(wind.width DIV 4)-20,(wind.height DIV 4)-20,angle,1,1);*)
  END;
CLOSE
  I.CloseWindow(wind);
  bool:=I.CloseScreen(screen);*)
END VectorTools.


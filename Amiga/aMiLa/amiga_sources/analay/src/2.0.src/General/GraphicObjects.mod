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


MODULE GraphicObjects;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gt : GraphicsTools,
       vt : VectorTools,
       gmb: GuiManagerBasics,
       mg : MathGUI,
       NoGuruRq;

TYPE Label * = POINTER TO LabelDesc;
     LabelDesc * = RECORD(l.NodeDesc)
       string  * : ARRAY 256 OF CHAR;
     END;

     PointData * = POINTER TO PointDataDesc;
     PointDataDesc * = RECORD
       data  * : vt.VectorObject;
       textx * ,
       texty * : LONGREAL;
     END;

     AreaPattern * = POINTER TO AreaPatternDesc;
     AreaPatternDesc * = RECORD
       pattern  * ,
       widepat  * : ARRAY 16 OF SET;
       pixelpat * : ARRAY 16 OF ARRAY 16 OF CHAR;
     END;



(* TYPE LineMatrix * = POINTER TO LineMatrixDesc;
     LineMatrixDesc * = RECORD
       matrix    * : ARRAY 16 OF BOOLEAN;
       breite    * : INTEGER;
     END;*)

(*     ArrowMatrix * = POINTER TO ArrowMatrixDesc;
     ArrowMatrixDesc * = RECORD
       matrix    * : ARRAY 9 OF ARRAY 16 OF CHAR;
       hotx*,hoty* : INTEGER;
     END;*)

(*     PointMatrix * = POINTER TO PointMatrixDesc;
     PointMatrixDesc * = RECORD
       feld * : ARRAY 16 OF ARRAY 16 OF CHAR; (* ! ACHTUNG ! ARRAY !Y! OF ARRAY !X! ! *)
       hotx * ,
       hoty * : INTEGER;
       textx* ,
       texty* : INTEGER;
     END;*)

(* Obsolete. LineMatrix used instead. *)

(*     MarkMust * = RECORD
       feld * : ARRAY 16 OF ARRAY 3 OF CHAR; (* ! ACHTUNG ! ARRAY !Y! OF ARRAY !X! ! *)
       hotx * ,
       hoty * : INTEGER;
       textx* ,
       texty* : INTEGER;
       bott * : INTEGER;
       last * : INTEGER;
     END;*)



VAR lines     * : POINTER TO ARRAY OF gt.Line;
    arrows    * : POINTER TO ARRAY OF vt.VectorObject;
    points    * : POINTER TO ARRAY OF PointData;
    areas     * : POINTER TO ARRAY OF AreaPattern;
    labels    * : l.List;



(*PROCEDURE CreateAreaPattern*(VAR areapat:s1.AreaPattern);

VAR x,y,incl : INTEGER;
    set      : SET;

BEGIN
(*  y:=-1;
  WHILE y<15 DO
    INC(y);
    set:={};
    x:=-1;
    incl:=16;
    WHILE x<15 DO
      INC(x);
      DEC(incl);
      IF areapat.pixelpat[y,x]="1" THEN
        INCL(set,incl);
      END;
    END;
    areapat.pattern[y]:=set;
(*    FOR x:=0 TO 15 DO
      areapat.pattern[y,x]:=s.VAL(INTEGER,set);
    END;*)
  END;*)
END CreateAreaPattern;*)

PROCEDURE PlotPoint*(rast:g.RastPortPtr;x,y,stdpicx,stdpicy,linex,liney:INTEGER;fill:BOOLEAN;num:LONGINT);

VAR x1,y1,x2,y2,pen : INTEGER;

BEGIN
  IF (num=4) OR (num=5) THEN
    IF num=4 THEN
      x1:=x-SHORT(SHORT(0.2*stdpicx+0.5));
      y1:=y-SHORT(SHORT(0.2*stdpicy+0.5));
      x2:=x+SHORT(SHORT(0.2*stdpicx+0.5));
      y2:=y+SHORT(SHORT(0.2*stdpicy+0.5));
    ELSIF num=5 THEN
      x1:=x-SHORT(SHORT(0.1*stdpicx+0.5));
      y1:=y-SHORT(SHORT(0.1*stdpicy+0.5));
      x2:=x+SHORT(SHORT(0.1*stdpicx+0.5));
      y2:=y+SHORT(SHORT(0.1*stdpicy+0.5));
    END;
    IF fill THEN
      pen:=rast.fgPen;
      g.SetAPen(rast,rast.bgPen);
      g.RectFill(rast,x1,y1,x2,y2);
      g.SetAPen(rast,pen);
    END;
    gt.SetLineAttrs(rast,linex,liney,lines[0]);
    gt.Move(rast,x1,y1);
    gt.Draw(rast,x2,y1);
    gt.Draw(rast,x2,y2);
    gt.Draw(rast,x1,y2);
    gt.Draw(rast,x1,y1);
    gt.FreeRastPortNode(rast);
  ELSIF (num=6) OR (num=7) THEN
    IF num=6 THEN
      x1:=SHORT(SHORT(0.2*stdpicx+0.5+1));
      y1:=SHORT(SHORT(0.2*stdpicy+0.5+1));
    ELSIF num=7 THEN
      x1:=SHORT(SHORT(0.1*stdpicx+0.5+1));
      y1:=SHORT(SHORT(0.1*stdpicy+0.5+1));
    END;
    IF x1<2 THEN
      x1:=2;
    END;
    IF y1<2 THEN
      y1:=2;
    END;
    IF fill THEN
      pen:=rast.fgPen;
      g.SetAPen(rast,rast.bgPen);
      gt.DrawFilledEllipse(rast,x,y,x1,y1);
      g.SetAPen(rast,pen);
    END;
    gt.DrawEllipse(rast,x,y,x1,y1,linex,liney,lines[0]);
  ELSE
    vt.DrawVectorObject(rast,points[num].data,x,y,stdpicx,stdpicy,0,linex,liney);
  END;
END PlotPoint;

PROCEDURE PlotPointSimple*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

BEGIN
  PlotPoint(rast,x+(width DIV 2),y+(height DIV 2),width,height,1,1,FALSE,num);
END PlotPointSimple;

PROCEDURE PlotPatternLine*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

VAR i,pos : INTEGER;

BEGIN
  i:=SHORT(SHORT((height/2)-0.5));
  pos:=0;
  g.SetAPen(rast,color);
  IF lines[num].width=16 THEN
    gt.SetLinePattern(rast,lines[num]);
    g.Move(rast,x,y+i);
    g.Draw(rast,x+width-1,y+i);
  ELSE
    gt.DrawLine(rast,x,y+i,x+width-1,y+i,1,1,lines[num],pos);
  END;
END PlotPatternLine;

PROCEDURE PlotThicknessLine*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

VAR i : INTEGER;

BEGIN
  i:=SHORT(SHORT((height/2)-((num+1)/2)));
  g.SetAPen(rast,color);
  g.RectFill(rast,x,y+i,x+width-1,SHORT(y+i+num+1-1));
END PlotThicknessLine;

PROCEDURE PlotArrow*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

BEGIN
  g.SetAPen(rast,color);
  vt.DrawVectorObject(rast,arrows[num],x+width-1,y+(height DIV 2)-1,width,height,0,1,1);
END PlotArrow;

PROCEDURE PlotAreaPattern*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

VAR i,pos : INTEGER;

BEGIN
  g.SetAPen(rast,color);
  g.SetAfPt(rast,s.ADR(areas[num].pattern),4);
  g.RectFill(rast,x,y,x+width-1,y+height-1);
  g.SetAfPt(rast,NIL,4);
END PlotAreaPattern;

PROCEDURE PlotLegendField*(rast:g.RastPortPtr;x,y,width,height,linex,liney,pattern,color:INTEGER;num:LONGINT);

VAR bord : I.BorderPtr;
    pos  : INTEGER;

BEGIN
  g.SetAPen(rast,color);
  pos:=0;
  IF num=0 THEN
    gt.DrawLine(rast,x,y+(height DIV 2),x+width-1,y+(height DIV 2),linex,liney,lines[pattern],pos);
  ELSIF num=1 THEN
    gt.DrawLine(rast,x+2,y+(height DIV 2),x+width-1-2,y+(height DIV 2),linex,liney,lines[pattern],pos);
    gmb.DrawBevelBox(mg.screen,rast,x,y,width,height,FALSE);
  ELSIF num=2 THEN
    g.SetAPen(rast,gmb.std.shadowcol);
    g.RectFill(rast,x+2,y+2,x+width-1,y+height-1);
    g.SetAPen(rast,gmb.std.lightcol);
    g.RectFill(rast,x,y,x+width-1-2,y+height-1-2);
    g.SetAPen(rast,color);
    g.RectFill(rast,x+2,y+1,x+width-1-4,y+height-1-3);
  ELSIF num=3 THEN
    g.RectFill(rast,x+2,y+1,x+width-1-2,y+height-1-1);
    gmb.DrawBevelBox(mg.screen,rast,x,y,width,height,FALSE);
  ELSIF num=4 THEN
    g.SetAPen(rast,gmb.std.lightcol);
    g.RectFill(rast,x,y,x+width-1,y+height-1);
    g.SetAPen(rast,color);
    g.RectFill(rast,x+2,y+1,x+width-1-2,y+height-1-1);
  ELSIF num=5 THEN
    g.RectFill(rast,x,y,x+width-1,y+height-1);
  END;
END PlotLegendField;

PROCEDURE PlotLegendFieldSimple*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

BEGIN
  PlotLegendField(rast,x,y,width,height,1,1,0,color,num);
END PlotLegendFieldSimple;

PROCEDURE Init*;

VAR node : l.Node;
    i    : INTEGER;

BEGIN
  labels:=l.Create();
  NEW(lines,20);
  NEW(arrows,10);
  NEW(points,15);
  NEW(areas,15);
  FOR i:=0 TO 19 DO
    NEW(lines[i]);
  END;
  FOR i:=0 TO 9 DO
    arrows[i]:=vt.NewVectorObject();
  END;
  FOR i:=0 TO 14 DO
    NEW(points[i]);
    points[i].data:=vt.NewVectorObject();
  END;
  FOR i:=0 TO 14 DO
    NEW(areas[i]);
  END;



  NEW(node(Label));
  node(Label).string:="$x,$y";
  labels.AddTail(node);
  NEW(node(Label));
  node(Label).string:="($x|$y)";
  labels.AddTail(node);
  NEW(node(Label));
  node(Label).string:="($x,$y)";
  labels.AddTail(node);
  NEW(node(Label));
  node(Label).string:="x=$x y=$y";
  labels.AddTail(node);

  vt.MoveLine(points[0].data,0.5,0.5);
  vt.DrawLine(points[0].data,-0.5,-0.5);
  vt.MoveLine(points[0].data,0.5,-0.5);
  vt.DrawLine(points[0].data,-0.5,0.5);
  points[0].textx:=0.6;
  points[0].texty:=0;

  vt.MoveLine(points[1].data,0.25,0.25);
  vt.DrawLine(points[1].data,-0.25,-0.25);
  vt.MoveLine(points[1].data,0.25,-0.25);
  vt.DrawLine(points[1].data,-0.25,0.25);
  points[1].textx:=0.3;
  points[1].texty:=0;

  vt.MoveLine(points[2].data,0,0.5);
  vt.DrawLine(points[2].data,0,-0.5);
  vt.MoveLine(points[2].data,0.5,0);
  vt.DrawLine(points[2].data,-0.5,0);
  points[2].textx:=0.6;
  points[2].texty:=0;

  vt.MoveLine(points[3].data,0,0.25);
  vt.DrawLine(points[3].data,0,-0.25);
  vt.MoveLine(points[3].data,0.25,0);
  vt.DrawLine(points[3].data,-0.25,0);
  points[3].textx:=0.3;
  points[3].texty:=0;

(* Points 4 to 7 have a special design. *)

  points[4].textx:=0.3;
  points[4].texty:=0;

  points[5].textx:=0.2;
  points[5].texty:=0;

  points[6].textx:=0.3;
  points[6].texty:=0;

  points[7].textx:=0.2;
  points[7].texty:=0;

  lines[0].pattern:=SET{0..15};
  lines[0].width:=16;

  lines[1].pattern:=SET{8..15};
  lines[1].width:=16;

  lines[2].pattern:=SET{12..15,4..7};
  lines[2].width:=16;

  lines[3].pattern:=SET{15,14,11,10,7,6,3,2};
  lines[3].width:=16;

  lines[4].pattern:=SET{15,13,11,9,7,5,3,1};
  lines[4].width:=16;

  lines[5].pattern:=SET{12..15,9,8};
  lines[5].width:=10;

  arrows[0].NewPolygon(0,0,-1,0.25,-0.75,0);
  arrows[0].NewPolygon(0,0,-1,-0.25,-0.75,0);
  arrows[0].maxwidth:=1;
  arrows[0].maxheight:=0.5;

  arrows[1].NewPolygon(0,0,-1,0.5,-0.75,0);
  arrows[1].NewPolygon(0,0,-1,-0.5,-0.75,0);
  arrows[1].maxwidth:=1;
  arrows[1].maxheight:=1;

  arrows[2].NewPolygon(0,0,-1,0.25,-1,0);
  arrows[2].NewPolygon(0,0,-1,-0.25,-1,0);
  arrows[2].maxwidth:=1;
  arrows[2].maxheight:=0.5;

  arrows[3].NewPolygon(0,0,-1,0.5,-1,0);
  arrows[3].NewPolygon(0,0,-1,-0.5,-1,0);
  arrows[3].maxwidth:=1;
  arrows[3].maxheight:=1;

  arrows[4].NewPolygon(0,0,-0.5,0.125,-0.375,0);
  arrows[4].NewPolygon(0,0,-0.5,-0.125,-0.375,0);
  arrows[4].maxwidth:=0.5;
  arrows[4].maxheight:=0.25;

  arrows[5].NewPolygon(0,0,-0.5,0.25,-0.375,0);
  arrows[5].NewPolygon(0,0,-0.5,-0.25,-0.375,0);
  arrows[5].maxwidth:=0.5;
  arrows[5].maxheight:=0.5;

  arrows[6].NewPolygon(0,0,-0.5,0.125,-0.5,0);
  arrows[6].NewPolygon(0,0,-0.5,-0.125,-0.5,0);
  arrows[6].maxwidth:=0.5;
  arrows[6].maxheight:=0.25;

  arrows[7].NewPolygon(0,0,-0.5,0.25,-0.5,0);
  arrows[7].NewPolygon(0,0,-0.5,-0.25,-0.5,0);
  arrows[7].maxwidth:=0.5;
  arrows[7].maxheight:=0.5;

  areas[0].pattern[0]:=SET{8,0};
  areas[0].pattern[1]:=SET{9,1};
  areas[0].pattern[2]:=SET{10,2};
  areas[0].pattern[3]:=SET{11,3};
  areas[0].pattern[4]:=SET{12,4};
  areas[0].pattern[5]:=SET{13,5};
  areas[0].pattern[6]:=SET{14,6};
  areas[0].pattern[7]:=SET{15,7};
  areas[0].pattern[8]:=SET{8,0};
  areas[0].pattern[9]:=SET{9,1};
  areas[0].pattern[10]:=SET{10,2};
  areas[0].pattern[11]:=SET{11,3};
  areas[0].pattern[12]:=SET{12,4};
  areas[0].pattern[13]:=SET{13,5};
  areas[0].pattern[14]:=SET{14,6};
  areas[0].pattern[15]:=SET{15,7};
  areas[0].widepat[0]:=SET{0};
  areas[0].widepat[1]:=SET{1};
  areas[0].widepat[2]:=SET{2};
  areas[0].widepat[3]:=SET{3};
  areas[0].widepat[4]:=SET{4};
  areas[0].widepat[5]:=SET{5};
  areas[0].widepat[6]:=SET{6};
  areas[0].widepat[7]:=SET{7};
  areas[0].widepat[8]:=SET{8};
  areas[0].widepat[9]:=SET{9};
  areas[0].widepat[10]:=SET{10};
  areas[0].widepat[11]:=SET{11};
  areas[0].widepat[12]:=SET{12};
  areas[0].widepat[13]:=SET{13};
  areas[0].widepat[14]:=SET{14};
  areas[0].widepat[15]:=SET{15};

  areas[1].pattern[0]:=SET{15,7};
  areas[1].pattern[1]:=SET{14,6};
  areas[1].pattern[2]:=SET{13,5};
  areas[1].pattern[3]:=SET{12,4};
  areas[1].pattern[4]:=SET{11,3};
  areas[1].pattern[5]:=SET{10,2};
  areas[1].pattern[6]:=SET{9,1};
  areas[1].pattern[7]:=SET{8,0};
  areas[1].pattern[8]:=SET{15,7};
  areas[1].pattern[9]:=SET{14,6};
  areas[1].pattern[10]:=SET{13,5};
  areas[1].pattern[11]:=SET{12,4};
  areas[1].pattern[12]:=SET{11,3};
  areas[1].pattern[13]:=SET{10,2};
  areas[1].pattern[14]:=SET{9,1};
  areas[1].pattern[15]:=SET{8,0};
  areas[1].widepat[0]:=SET{15};
  areas[1].widepat[1]:=SET{14};
  areas[1].widepat[2]:=SET{13};
  areas[1].widepat[3]:=SET{12};
  areas[1].widepat[4]:=SET{11};
  areas[1].widepat[5]:=SET{10};
  areas[1].widepat[6]:=SET{9};
  areas[1].widepat[7]:=SET{8};
  areas[1].widepat[8]:=SET{7};
  areas[1].widepat[9]:=SET{6};
  areas[1].widepat[10]:=SET{5};
  areas[1].widepat[11]:=SET{4};
  areas[1].widepat[12]:=SET{3};
  areas[1].widepat[13]:=SET{2};
  areas[1].widepat[14]:=SET{1};
  areas[1].widepat[15]:=SET{0};

  areas[2].pattern[0]:=SET{15,7};
  areas[2].pattern[1]:=SET{15,7};
  areas[2].pattern[2]:=SET{15,7};
  areas[2].pattern[3]:=SET{15,7};
  areas[2].pattern[4]:=SET{15,7};
  areas[2].pattern[5]:=SET{15,7};
  areas[2].pattern[6]:=SET{15,7};
  areas[2].pattern[7]:=SET{15,7};
  areas[2].pattern[8]:=SET{15,7};
  areas[2].pattern[9]:=SET{15,7};
  areas[2].pattern[10]:=SET{15,7};
  areas[2].pattern[11]:=SET{15,7};
  areas[2].pattern[12]:=SET{15,7};
  areas[2].pattern[13]:=SET{15,7};
  areas[2].pattern[14]:=SET{15,7};
  areas[2].pattern[15]:=SET{15,7};
  areas[2].widepat[0]:=SET{15};
  areas[2].widepat[1]:=SET{15};
  areas[2].widepat[2]:=SET{15};
  areas[2].widepat[3]:=SET{15};
  areas[2].widepat[4]:=SET{15};
  areas[2].widepat[5]:=SET{15};
  areas[2].widepat[6]:=SET{15};
  areas[2].widepat[7]:=SET{15};
  areas[2].widepat[8]:=SET{15};
  areas[2].widepat[9]:=SET{15};
  areas[2].widepat[10]:=SET{15};
  areas[2].widepat[11]:=SET{15};
  areas[2].widepat[12]:=SET{15};
  areas[2].widepat[13]:=SET{15};
  areas[2].widepat[14]:=SET{15};
  areas[2].widepat[15]:=SET{15};

  areas[3].pattern[0]:=SET{0..15};
  areas[3].pattern[1]:=SET{};
  areas[3].pattern[2]:=SET{};
  areas[3].pattern[3]:=SET{};
  areas[3].pattern[4]:=SET{};
  areas[3].pattern[5]:=SET{};
  areas[3].pattern[6]:=SET{};
  areas[3].pattern[7]:=SET{};
  areas[3].pattern[8]:=SET{0..15};
  areas[3].pattern[9]:=SET{};
  areas[3].pattern[10]:=SET{};
  areas[3].pattern[11]:=SET{};
  areas[3].pattern[12]:=SET{};
  areas[3].pattern[13]:=SET{};
  areas[3].pattern[14]:=SET{};
  areas[3].pattern[15]:=SET{};
  areas[3].widepat[0]:=SET{0..15};
  areas[3].widepat[1]:=SET{};
  areas[3].widepat[2]:=SET{};
  areas[3].widepat[3]:=SET{};
  areas[3].widepat[4]:=SET{};
  areas[3].widepat[5]:=SET{};
  areas[3].widepat[6]:=SET{};
  areas[3].widepat[7]:=SET{};
  areas[3].widepat[8]:=SET{};
  areas[3].widepat[9]:=SET{};
  areas[3].widepat[10]:=SET{};
  areas[3].widepat[11]:=SET{};
  areas[3].widepat[12]:=SET{};
  areas[3].widepat[13]:=SET{};
  areas[3].widepat[14]:=SET{};
  areas[3].widepat[15]:=SET{};

  areas[4].pattern[0]:=SET{8,0,12,4};
  areas[4].pattern[1]:=SET{9,1,11,3};
  areas[4].pattern[2]:=SET{10,2,10,2};
  areas[4].pattern[3]:=SET{11,3,9,1};
  areas[4].pattern[4]:=SET{12,4,8,0};
  areas[4].pattern[5]:=SET{13,5,15,7};
  areas[4].pattern[6]:=SET{14,6,14,6};
  areas[4].pattern[7]:=SET{15,7,13,5};
  areas[4].pattern[8]:=SET{8,0,12,4};
  areas[4].pattern[9]:=SET{9,1,11,3};
  areas[4].pattern[10]:=SET{10,2,10,2};
  areas[4].pattern[11]:=SET{11,3,9,1};
  areas[4].pattern[12]:=SET{12,4,8,0};
  areas[4].pattern[13]:=SET{13,5,15,7};
  areas[4].pattern[14]:=SET{14,6,14,6};
  areas[4].pattern[15]:=SET{15,7,13,5};
  areas[4].widepat[0]:=SET{8,12};
  areas[4].widepat[1]:=SET{9,11};
  areas[4].widepat[2]:=SET{10,10};
  areas[4].widepat[3]:=SET{11,9};
  areas[4].widepat[4]:=SET{12,8};
  areas[4].widepat[5]:=SET{13,7};
  areas[4].widepat[6]:=SET{14,6};
  areas[4].widepat[7]:=SET{15,5};
  areas[4].widepat[8]:=SET{0,4};
  areas[4].widepat[9]:=SET{1,3};
  areas[4].widepat[10]:=SET{2,2};
  areas[4].widepat[11]:=SET{3,1};
  areas[4].widepat[12]:=SET{4,0};
  areas[4].widepat[13]:=SET{5,15};
  areas[4].widepat[14]:=SET{6,14};
  areas[4].widepat[15]:=SET{7,13};

  areas[5].pattern[0]:=SET{0..15};
  areas[5].pattern[1]:=SET{15,7};
  areas[5].pattern[2]:=SET{15,7};
  areas[5].pattern[3]:=SET{15,7};
  areas[5].pattern[4]:=SET{15,7};
  areas[5].pattern[5]:=SET{15,7};
  areas[5].pattern[6]:=SET{15,7};
  areas[5].pattern[7]:=SET{15,7};
  areas[5].pattern[8]:=SET{0..15};
  areas[5].pattern[9]:=SET{15,7};
  areas[5].pattern[10]:=SET{15,7};
  areas[5].pattern[11]:=SET{15,7};
  areas[5].pattern[12]:=SET{15,7};
  areas[5].pattern[13]:=SET{15,7};
  areas[5].pattern[14]:=SET{15,7};
  areas[5].pattern[15]:=SET{15,7};
  areas[5].widepat[0]:=SET{0..15};
  areas[5].widepat[1]:=SET{15};
  areas[5].widepat[2]:=SET{15};
  areas[5].widepat[3]:=SET{15};
  areas[5].widepat[4]:=SET{15};
  areas[5].widepat[5]:=SET{15};
  areas[5].widepat[6]:=SET{15};
  areas[5].widepat[7]:=SET{15};
  areas[5].widepat[8]:=SET{15};
  areas[5].widepat[9]:=SET{15};
  areas[5].widepat[10]:=SET{15};
  areas[5].widepat[11]:=SET{15};
  areas[5].widepat[12]:=SET{15};
  areas[5].widepat[13]:=SET{15};
  areas[5].widepat[14]:=SET{15};
  areas[5].widepat[15]:=SET{15};

  areas[6].pattern[0]:=SET{0..15};
  areas[6].pattern[1]:=SET{0..15};
  areas[6].pattern[2]:=SET{0..15};
  areas[6].pattern[3]:=SET{0..15};
  areas[6].pattern[4]:=SET{0..15};
  areas[6].pattern[5]:=SET{0..15};
  areas[6].pattern[6]:=SET{0..15};
  areas[6].pattern[7]:=SET{0..15};
  areas[6].pattern[8]:=SET{0..15};
  areas[6].pattern[9]:=SET{0..15};
  areas[6].pattern[10]:=SET{0..15};
  areas[6].pattern[11]:=SET{0..15};
  areas[6].pattern[12]:=SET{0..15};
  areas[6].pattern[13]:=SET{0..15};
  areas[6].pattern[14]:=SET{0..15};
  areas[6].pattern[15]:=SET{0..15};
  areas[6].widepat[0]:=SET{0..15};
  areas[6].widepat[1]:=SET{0..15};
  areas[6].widepat[2]:=SET{0..15};
  areas[6].widepat[3]:=SET{0..15};
  areas[6].widepat[4]:=SET{0..15};
  areas[6].widepat[5]:=SET{0..15};
  areas[6].widepat[6]:=SET{0..15};
  areas[6].widepat[7]:=SET{0..15};
  areas[6].widepat[8]:=SET{0..15};
  areas[6].widepat[9]:=SET{0..15};
  areas[6].widepat[10]:=SET{0..15};
  areas[6].widepat[11]:=SET{0..15};
  areas[6].widepat[12]:=SET{0..15};
  areas[6].widepat[13]:=SET{0..15};
  areas[6].widepat[14]:=SET{0..15};
  areas[6].widepat[15]:=SET{0..15};
END Init;

PROCEDURE Destruct*;

VAR i : INTEGER;

BEGIN
  labels.Destruct;
  FOR i:=0 TO 19 DO
    lines[i].Destruct;
  END;
  DISPOSE(lines);
  FOR i:=0 TO 9 DO
    arrows[i].Destruct;
  END;
  DISPOSE(arrows);
  FOR i:=0 TO 14 DO
    points[i].data.Destruct;
    DISPOSE(points[i]);
  END;
  DISPOSE(points);
  FOR i:=0 TO 14 DO
    DISPOSE(areas[i]);
  END;
  DISPOSE(areas);
END Destruct;

BEGIN
  Init;
CLOSE
  Destruct;
END GraphicObjects.


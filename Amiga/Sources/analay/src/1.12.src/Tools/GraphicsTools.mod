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


MODULE GraphicsTools;

IMPORT I  : Intuition,
       g  : Graphics,
       s  : SYSTEM,
       l  : LinkedLists,
       df : DiskFont,
       mt : MathTrans,
       mdt: MathIEEEDoubTrans,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

TYPE Line * = RECORD(l.NodeDesc)
       pattern * : SET;
       width   * : INTEGER;
     END;
     MoveDrawNode * = RECORD(l.NodeDesc)
       rast      * : g.RastPortPtr;
       width     * ,
       height    * ,
       pos       * : INTEGER;
       line      * : l.Node;
     END;

VAR pos      : INTEGER;
    movedraw : l.List;

PROCEDURE SetLinePattern*(r:g.RastPortPtr;line:l.Node);

BEGIN
  r.linePtrn:=s.VAL(INTEGER,line(Line).pattern);
END SetLinePattern;

PROCEDURE SetFullPattern*(r:g.RastPortPtr);

BEGIN
  r.linePtrn:=s.VAL(INTEGER,SET{0..15});
END SetFullPattern;

PROCEDURE DrawLine*(r:g.RastPortPtr;x1,y1,x2,y2,width,height:INTEGER;line:l.Node;VAR pos:INTEGER);

VAR bool,
    ok    : BOOLEAN;
    cx,cy,
    px,py,
    px2,py2,i : INTEGER;
    cffp,
    cf    : REAL;
    step  : INTEGER;
    ub    : INTEGER;
    long  : LONGINT;

BEGIN
  IF height=-1 THEN
    height:=width;
  END;
  IF line=NIL THEN
    NEW(line(Line));
    line(Line).pattern:=SET{0..15};
    line(Line).width:=16;
  END;
  WITH line: Line DO
    IF pos<-1 THEN
      pos:=-1;
    END;
    IF (x1#x2) OR (y1#y2) THEN
      IF (ABS(x2-x1))>=(ABS(y2-y1)) THEN
        IF (x2-x1)>0 THEN
          step:=1;
        ELSE
          step:=-1;
        END;
        ub:=ABS(x2-x1);
        cffp:=(y2-y1)/(ub);
        cf:=y1;
        cx:=x1;
        cy:=SHORT(SHORT(cf+0.5));
        LOOP
          INC(pos);
          IF cx=x2 THEN
            DEC(pos);
            IF pos<0 THEN
              pos:=0;
            END;
          END;
          i:=pos DIV width;
          IF i>=line.width THEN
            pos:=0;
            i:=0;
          END;
          IF 15-i IN line.pattern THEN
            IF width<=1 THEN
              ok:=g.WritePixel(r,cx,cy);
            ELSE
              px:=cx-(width DIV 2);
              py:=cy-(height DIV 2);
              px2:=px+width-1;
              py2:=py+height-1;
              g.RectFill(r,px,py,px2,py2);
            END;
          END;
          IF cx=x2 THEN EXIT;END;
          cx:=cx+step;
          cf:=cf+cffp;
          cy:=SHORT(SHORT(cf+0.5));
        END;
      ELSE
        IF (y2-y1)>0 THEN
          step:=1;
        ELSE
          step:=-1;
        END;
        ub:=ABS(y2-y1);
        cffp:=(x2-x1)/(ub);
        cf:=x1;
        cy:=y1;
        cx:=SHORT(SHORT(cf+0.5));
        LOOP
          INC(pos);
          IF cy=y2 THEN
            DEC(pos);
            IF pos<0 THEN
              pos:=0;
            END;
          END;
          i:=pos DIV height;
          IF i>=line.width THEN
            pos:=0;
            i:=0;
          END;
          IF 15-i IN line.pattern THEN
            IF width<=1 THEN
              ok:=g.WritePixel(r,cx,cy);
            ELSE
              px:=cx-(width DIV 2);
              py:=cy-(height DIV 2);
              px2:=px+width-1;
              py2:=py+height-1;
              g.RectFill(r,px,py,px2,py2);
            END;
          END;
          IF cy=y2 THEN EXIT;END;
          cy:=cy+step;
          cf:=cf+cffp;
          cx:=SHORT(SHORT(cf+0.5));
        END;
      END;
    END;
(*    DEC(pos);*)
  END;
END DrawLine;

PROCEDURE GetMoveDrawNode*(rast:g.RastPortPtr):l.Node;

VAR node,ret : l.Node;

BEGIN
  ret:=NIL;
  node:=movedraw.head;
  WHILE node#NIL DO
    IF node(MoveDrawNode).rast=rast THEN
      ret:=node;
    END;
    node:=node.next;
    IF ret#NIL THEN
      node:=NIL;
    END;
  END;
  RETURN ret;
END GetMoveDrawNode;

PROCEDURE Move*(rast:g.RastPortPtr;x,y:INTEGER);

VAR node : l.Node;

BEGIN
  g.Move(rast,x,y);
  pos:=0;
  node:=GetMoveDrawNode(rast);
  IF node#NIL THEN
    node(MoveDrawNode).pos:=0;
  ELSE
    NEW(node(MoveDrawNode));
    node(MoveDrawNode).rast:=rast;
    node(MoveDrawNode).width:=1;
    node(MoveDrawNode).height:=1;
    node(MoveDrawNode).line:=NIL;
    node(MoveDrawNode).pos:=0;
    movedraw.AddTail(node);
  END;
END Move;

PROCEDURE Draw*(rast:g.RastPortPtr;x,y:INTEGER);

VAR node : l.Node;
    wi,he,
    m    : INTEGER;
    line : l.Node;

BEGIN
  node:=GetMoveDrawNode(rast);
  IF node#NIL THEN
    wi:=node(MoveDrawNode).width;
    he:=node(MoveDrawNode).height;
    line:=node(MoveDrawNode).line;
    m:=node(MoveDrawNode).pos;
  END;
  IF (line#NIL) AND (wi=1) AND (line(Line).width=16) THEN
    SetLinePattern(rast,line);
    g.Draw(rast,x,y);
  ELSIF (line=NIL) AND (wi=1) THEN
    g.Draw(rast,x,y);
  ELSE
    DrawLine(rast,rast.x,rast.y,x,y,wi,he,line,m);
    g.Move(rast,x,y);
    IF node#NIL THEN
      node(MoveDrawNode).pos:=m;
    ELSE
      pos:=m;
    END;
  END;
END Draw;

PROCEDURE SetLineAttrs*(rast:g.RastPortPtr;width,height:INTEGER;line:l.Node);

VAR node : l.Node;

BEGIN
  node:=GetMoveDrawNode(rast);
  IF node#NIL THEN
    node(MoveDrawNode).width:=width;
    node(MoveDrawNode).line:=line;
  ELSE
    NEW(node(MoveDrawNode));
    node(MoveDrawNode).rast:=rast;
    node(MoveDrawNode).width:=width;
    node(MoveDrawNode).height:=height;
    node(MoveDrawNode).line:=line;
    node(MoveDrawNode).pos:=0;
    movedraw.AddTail(node);
  END;
END SetLineAttrs;

PROCEDURE FreeRastPortNode*(rast:g.RastPortPtr);

VAR node : l.Node;

BEGIN
  node:=GetMoveDrawNode(rast);
  IF node#NIL THEN
    node.Remove;
  END;
  SetFullPattern(rast);
END FreeRastPortNode;

PROCEDURE DrawEllipse*(rast:g.RastPortPtr;xpos,ypos,radx,rady,linewidth,lineheight:INTEGER;line:l.Node);

VAR x,maxy,miny,
    oldmaxy,oldminy,
    pos1,pos2       : INTEGER;
    first           : BOOLEAN;

BEGIN
  first:=TRUE;
  pos1:=0;
  pos2:=0;
  x:=xpos-radx;
  WHILE x<xpos+radx-1 DO
    INC(x);
    oldmaxy:=maxy;
    oldminy:=miny;
    maxy:=SHORT(SHORT(mt.Sqrt(1-(x-xpos)/(radx-1)*((x-xpos)/(radx-1)))*(rady-1)+0.5));
    miny:=ypos+maxy;
    maxy:=ypos-maxy;
    IF NOT(first) THEN
      IF (linewidth=1) AND (lineheight=1) THEN
        g.Move(rast,x-1,oldmaxy);
        g.Draw(rast,x,maxy);
        g.Move(rast,x-1,oldminy);
        g.Draw(rast,x,miny);
      ELSE
        DrawLine(rast,x-1,oldmaxy,x,maxy,linewidth,lineheight,line,pos1);
        DrawLine(rast,x-1,oldminy,x,miny,linewidth,lineheight,line,pos2);
      END;
    END;
    first:=FALSE;
  END;
END DrawEllipse;

PROCEDURE DrawFilledEllipse*(rast:g.RastPortPtr;xpos,ypos,radx,rady:INTEGER);

VAR x,maxy,miny : INTEGER;

BEGIN
  x:=xpos-radx;
  WHILE x<xpos+radx-1 DO
    INC(x);
    maxy:=SHORT(SHORT(mt.Sqrt(1-(x-xpos)/(radx-1)*((x-xpos)/(radx-1)))*(rady-1)+0.5));
    miny:=ypos+maxy;
    maxy:=ypos-maxy;
    g.RectFill(rast,x,maxy,x,miny);
  END;
END DrawFilledEllipse;

PROCEDURE SetFont*(rast:g.RastPortPtr;attr:g.TextAttrPtr):g.TextFontPtr;

VAR font : g.TextFontPtr;

BEGIN
  font:=NIL;
  font:=df.OpenDiskFont(attr^);
  g.SetFont(rast,font);
  RETURN font;
END SetFont;

PROCEDURE CloseFont*(font:g.TextFontPtr);

BEGIN
  IF font#NIL THEN
    g.CloseFont(font);
  END;
END CloseFont;

PROCEDURE GetModeDims*(modeId,oscan:LONGINT;VAR width,height,depth:INTEGER);

VAR diminfo : g.DimensionInfoPtr;
    long    : LONGINT;

BEGIN
  IF I.int.libNode.version>=36 THEN
    diminfo:=NIL;
    NEW(diminfo);
    IF diminfo#NIL THEN
      long:=g.GetDisplayInfoData(NIL,diminfo^,s.SIZE(g.DimensionInfo),g.dtagDims,modeId);
      IF long>0 THEN
        depth:=diminfo.maxDepth;
        IF oscan=I.oScanText THEN
          width:=diminfo.txtOScan.maxX-diminfo.txtOScan.minX+1;
          height:=diminfo.txtOScan.maxY-diminfo.txtOScan.minY+1;
        ELSIF oscan=I.oScanStandard THEN
          width:=diminfo.stdOScan.maxX-diminfo.stdOScan.minX+1;
          height:=diminfo.stdOScan.maxY-diminfo.stdOScan.minY+1;
        ELSIF oscan=I.oScanMax THEN
          width:=diminfo.maxOScan.maxX-diminfo.maxOScan.minX+1;
          height:=diminfo.maxOScan.maxY-diminfo.maxOScan.minY+1;
        ELSIF oscan=I.oScanVideo THEN
          width:=diminfo.videoOScan.maxX-diminfo.videoOScan.minX+1;
          height:=diminfo.videoOScan.maxY-diminfo.videoOScan.minY+1;
        END;
      END;
      DISPOSE(diminfo);
    END;
  END;
END GetModeDims;

BEGIN
  movedraw:=l.Create();
END GraphicsTools.


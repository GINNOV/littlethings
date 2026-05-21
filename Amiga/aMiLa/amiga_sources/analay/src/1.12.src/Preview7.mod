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


MODULE Preview7;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       p  : Printer,
       es : ExecSupport,
       df : DiskFont,
       fr : FileReq,
       it : IntuitionTools,
       tt : TextTools,
       gt : GraphicsTools,
       ag : AmigaGuideTools,
       gm : GadgetManager,
       wm : WindowManager,
       pi : PreviewImages,
       pt : Pointers,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       s6 : SuperCalcTools6,
       s7 : SuperCalcTools7,
       s8 : SuperCalcTools8,
       s9 : SuperCalcTools9,
       s10: SuperCalcTools10,
       s11: SuperCalcTools11,
       s12: SuperCalcTools12,
       s13: SuperCalcTools13,
       s14: SuperCalcTools14,
       p1 : Preview1,
       p2 : Preview2,
       p3 : Preview3,
       p4 : Preview4,
       p5 : Preview5,
       p6 : Preview6,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j     : INTEGER;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    bool      : BOOLEAN;
    printerId*,
    changefontsId*,
    changedisplayId*: INTEGER;

PROCEDURE PlotRect*(rast:g.RastPortPtr;node:l.Node;print:BOOLEAN);

VAR fast  : BOOLEAN;
    x,y,
    width,
    height,
    wi,he : INTEGER;
    real  : LONGREAL;

BEGIN
  WITH node: p1.Rect DO
    IF (print) OR NOT(node.fastdraw) THEN
      fast:=FALSE;
    ELSE
      fast:=TRUE;
    END;
    p1.PageToPagePicC(node.xpos,node.ypos,x,y);
    p1.PageToPagePic(node.width,node.height,width,height);
    IF node.linewidth>0 THEN
      real:=p1.PointToCent(node.linewidth);
      p1.PageToPagePic(real,real,wi,he);
      IF wi<1 THEN
        wi:=1;
      END;
      IF he<1 THEN
        he:=1;
      END;
    ELSE
      wi:=1;
      he:=1;
    END;
(*    INC(x,offx);
    INC(y,offy);*)
(*    RawPlotRect(rast,node,x,y,width,height,fast);*)
    IF fast THEN
      p5.DrawFastBorder(rast,x,y,width,height);
    ELSE
      DEC(wi);
      DEC(he);
      p3.SetColor(rast,node.linecolor,TRUE);
      g.RectFill(rast,x,y,x+width,y+he);
      g.RectFill(rast,x+width-wi,y,x+width,y+height);
      g.RectFill(rast,x,y+height-he,x+width,y+height);
      g.RectFill(rast,x,y,x+wi,y+height);
      IF node.dofill THEN
        p3.SetColor(rast,node.fillcolor,TRUE);
        g.RectFill(rast,x+wi+1,y+he+1,x+width-wi-1,y+height-he-1);
      END;
    END;
  END;
END PlotRect;

PROCEDURE PlotLine*(rast:g.RastPortPtr;node:l.Node;print:BOOLEAN);

VAR fast  : BOOLEAN;
    x,y,
    width,
    height,
    wi,he,
    pos   : INTEGER;
    real  : LONGREAL;

BEGIN
  WITH node: p1.Line DO
    IF (print) OR NOT(node.fastdraw) THEN
      fast:=FALSE;
    ELSE
      fast:=TRUE;
    END;
    p1.PageToPagePicC(node.xpos,node.ypos,x,y);
    p1.PageToPagePic(node.width,node.height,width,height);
    IF node.linewidth>0 THEN
      real:=p1.PointToCent(node.linewidth);
      p1.PageToPagePic(real,real,wi,he);
      IF wi<1 THEN
        wi:=1;
      END;
      IF he<1 THEN
        he:=1;
      END;
    ELSE
      wi:=1;
      he:=1;
    END;
(*    INC(x,offx);
    INC(y,offy);*)
(*    RawPlotRect(rast,node,x,y,width,height,fast);*)
    IF fast THEN
      g.SetAPen(rast,1);
      g.Move(rast,x,y);
      g.Draw(rast,x+width,y+height);
    ELSE
(*      IF node.width>node.height THEN
        wi:=he;
      END;*)
      p3.SetColor(rast,node.linecolor,TRUE);
(*      he:=0;*)
      pos:=0;
      gt.DrawLine(rast,x,y,x+width,y+height,wi,he,s1.lines[0],pos);
    END;
  END;
END PlotLine;

PROCEDURE PlotCircle*(rast:g.RastPortPtr;node:l.Node;print:BOOLEAN);

VAR fast  : BOOLEAN;
    x,y,
    width,
    height,
    wi,he : INTEGER;
    real  : LONGREAL;

BEGIN
  WITH node: p1.Circle DO
    IF (print) OR NOT(node.fastdraw) THEN
      fast:=FALSE;
    ELSE
      fast:=TRUE;
    END;
    p1.PageToPagePicC(node.xpos,node.ypos,x,y);
    p1.PageToPagePic(node.width,node.height,width,height);
    IF node.linewidth>0 THEN
      real:=p1.PointToCent(node.linewidth);
      p1.PageToPagePic(real,real,wi,he);
      IF wi<1 THEN
        wi:=1;
      END;
      IF he<1 THEN
        he:=1;
      END;
    ELSE
      wi:=1;
      he:=1;
    END;
(*    INC(x,offx);
    INC(y,offy);*)
(*    RawPlotRect(rast,node,x,y,width,height,fast);*)
    IF fast THEN
      p5.DrawFastBorder(rast,x,y,width,height);
    ELSE
      INC(width);
      INC(height);
      p3.SetColor(rast,node.linecolor,TRUE);
      IF node.dofill THEN
        gt.DrawFilledEllipse(rast,x+((width-1) DIV 2),y+((height-1) DIV 2),(width+1) DIV 2,(height+1) DIV 2);
        IF node.linecolor#node.fillcolor THEN
          p3.SetColor(rast,node.fillcolor,TRUE);
          gt.DrawFilledEllipse(rast,x+((width-1) DIV 2),y+((height-1) DIV 2),((width+1) DIV 2)-wi,((height+1) DIV 2)-he);
        END;
      ELSE
        gt.DrawEllipse(rast,x+((width-1) DIV 2),y+((height-1) DIV 2),(width+1) DIV 2,(height+1) DIV 2,wi,he,s1.lines[0]);
      END;
    END;
  END;
END PlotCircle;

PROCEDURE PlotPage*(wind:I.WindowPtr;rast:g.RastPortPtr;ruler,print:BOOLEAN);

VAR node,node2,
    font,size  : l.Node;
    x,y,width,
    height,
    x2,y2,xb,yb,
    xs,ys,
    linex,liney: INTEGER;
    xpos,ypos  : LONGREAL;
    stdwidth,
    stdheight  : INTEGER;

PROCEDURE PlotFenster(box,p:l.Node);

VAR node,node2,newnode,actgraph : l.Node;
    sizechanged,sizebool        : BOOLEAN;
    highest,acthigh             : INTEGER;

PROCEDURE CreateGraphs(VAR list:l.List;node:l.Node);

VAR node2,newnode : l.Node;

BEGIN
  node2:=node(s1.Depend).var;
  WITH node2: f1.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF node.next#NIL THEN
        CreateGraphs(list,node.next);
      ELSE
        newnode:=NIL;
        NEW(newnode(s1.FunctionGraph));
        NEW(newnode(s1.FunctionGraph).table,p(s1.Fenster).stutz);
        newnode(s1.FunctionGraph).bordervals:=l.Create();
        s1.ClearGraph(newnode);
        list.AddTail(newnode);
      END;
      node2.real:=node2.real+node2.stepx;
      IF node2.stepx>0 THEN
        IF node2.real>node2.endx THEN
          EXIT;
        END;
      ELSIF node2.stepx<0 THEN
        IF node2.real<node2.endx THEN
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END;
  END;
END CreateGraphs;

PROCEDURE PlotGraphs(windnode,windfunc:l.Node;node:l.Node):BOOLEAN;

VAR node2,newnode : l.Node;
    sizebool,
    sizechanged   : BOOLEAN;

BEGIN
  sizebool:=FALSE;
  sizechanged:=FALSE;
  node2:=node(s1.Depend).var;
  WITH node2: f1.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF node.next#NIL THEN
        sizebool:=PlotGraphs(windnode,windfunc,node.next);
      ELSE
        p1.PointToPic(p1.widthconv[actgraph(s1.FunctionGraph).width-1],linex,liney);
        p3.SetColor(rast,p1.colorconv[actgraph(s1.FunctionGraph).col],TRUE);
        IF NOT(actgraph(s1.FunctionGraph).calced) THEN
          sizebool:=s3.RawPlotGraph(rast,windnode,windfunc(s1.FensterFunc).func,actgraph,x,y,width,height,linex,liney,TRUE,FALSE);
        ELSE
          sizebool:=s3.RawPlotGraph(rast,windnode,windfunc(s1.FensterFunc).func,actgraph,x,y,width,height,linex,liney,FALSE,FALSE);
        END;
        actgraph:=actgraph.next;
      END;
      IF sizebool THEN
        sizechanged:=TRUE;
      END;
      node2.real:=node2.real+node2.stepx;
      IF node2.stepx>0 THEN
        IF node2.real>node2.endx THEN
          EXIT;
        END;
      ELSIF node2.stepx<0 THEN
        IF node2.real<node2.endx THEN
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END;
  END;
  RETURN sizechanged;
END PlotGraphs;

BEGIN
  IF p IS s1.Fenster THEN
    WITH p: s1.Fenster DO
      highest:=0;
(*      SetAllPointers(TRUE);*)
      REPEAT
        IF NOT(p.transparent) THEN
          p3.SetColor(rast,p1.colorconv[p.backcol],TRUE);
(*          g.SetAPen(rast,p.backcol);*)
          p1.RectFill(rast,x,y,x+width-1,y+height-1);
        END;
        IF p.grid2.on THEN
          IF box(p1.Fenster).stdgrid THEN
            IF p1.gridconv.stdcolor THEN
              p3.SetColor(rast,p1.colorconv[p.grid2.col],TRUE);
            ELSE
              p3.SetColor(rast,p1.gridconv.color,TRUE);
            END;
            IF p1.gridconv.stdwidth THEN
              p1.PointToPic(p1.widthconv[p.grid2.width-1],linex,liney);
            ELSE
              p1.PointToPic(p1.gridconv.width,linex,liney);
            END;
          ELSE
            p3.SetColor(rast,box(p1.Fenster).grid.color,TRUE);
            p1.PointToPic(box(p1.Fenster).grid.width,linex,liney);
          END;
          s3.RawPlotGrid(rast,p,s.ADR(p.grid2),x,y,width,height,linex,liney);
        END;
        IF p.grid1.on THEN
          IF box(p1.Fenster).stdgrid THEN
            IF p1.gridconv.stdcolor THEN
              p3.SetColor(rast,p1.colorconv[p.grid1.col],TRUE);
            ELSE
              p3.SetColor(rast,p1.gridconv.color,TRUE);
            END;
            IF p1.gridconv.stdwidth THEN
              p1.PointToPic(p1.widthconv[p.grid1.width-1],linex,liney);
            ELSE
              p1.PointToPic(p1.gridconv.width,linex,liney);
            END;
          ELSE
            p3.SetColor(rast,box(p1.Fenster).grid.color,TRUE);
            p1.PointToPic(box(p1.Fenster).grid.width,linex,liney);
          END;
          s3.RawPlotGrid(rast,p,s.ADR(p.grid1),x,y,width,height,linex,liney);
        END;
        node:=p.areas.head;
        WHILE node#NIL DO
          IF node(s1.Area).areab THEN
            IF stdwidth>30 THEN
              bool:=TRUE;
            ELSE
              bool:=FALSE;
            END;
            IF box(p1.MathBox).stdgraphcolor THEN
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colf],TRUE);
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colb],FALSE);
            ELSE
              p3.SetColor(rast,box(p1.MathBox).graphcolor,TRUE);
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colb],FALSE);
            END;
            s4.RawPlotArea(rast,p,node,x,y,width,height,FALSE,bool);
          END;
          node:=node.next;
        END;
        IF p.scale.on THEN
          IF box(p1.Fenster).stdscale THEN
            IF p1.scaleconv.stdfont THEN
              p2.GetConvertFont(s.ADR(p.scale.attr),font,size);
            ELSE
              font:=p1.scaleconv.font;
              size:=p1.scaleconv.size;
            END;
            p2.SetFont(rast,font,size);
            IF p1.scaleconv.stdcolor THEN
              p3.SetColor(rast,p1.colorconv[p.scale.col],TRUE);
            ELSE
              p3.SetColor(rast,p1.scaleconv.color,TRUE);
            END;
            IF p1.scaleconv.stdwidth THEN
              p1.PointToPic(p1.widthconv[p.scale.width-1],linex,liney);
            ELSE
              p1.PointToPic(p1.scaleconv.width,linex,liney);
            END;
          ELSE
            font:=box(p1.Fenster).scale.font;
            size:=box(p1.Fenster).scale.size;
            p2.SetFont(rast,font,size);
            p3.SetColor(rast,box(p1.Fenster).scale.color,TRUE);
            p1.PointToPic(box(p1.Fenster).scale.width,linex,liney);
          END;
          IF linex MOD 2=0 THEN
            INC(linex);
          END;
          IF liney MOD 2=0 THEN
            INC(liney);
          END;
          s3.RawPlotScale(rast,p,x,y,width,height,linex,liney,stdwidth,stdheight);
        END;

        node:=p.funcs.head;
        bool:=FALSE;
        sizechanged:=FALSE;
        acthigh:=0;
        WHILE node#NIL DO
          s2.LockFunction(node(s1.FensterFunc).func);
          sizebool:=FALSE;
          INC(acthigh);
          IF (node(s1.FensterFunc).func(s1.Function).changed) OR (node(s1.FensterFunc).changed) AND (acthigh>highest) THEN
            INC(highest);
            node(s1.FensterFunc).changed:=FALSE;
            node(s1.FensterFunc).graphs.Init;
            IF node(s1.FensterFunc).func(s1.Function).depend.isEmpty() THEN
              newnode:=NIL;
              NEW(newnode(s1.FunctionGraph));
              NEW(newnode(s1.FunctionGraph).table,p.stutz);
              newnode(s1.FunctionGraph).bordervals:=l.Create();
              s1.ClearGraph(newnode);
              node(s1.FensterFunc).graphs.AddTail(newnode);
              bool:=TRUE;
            ELSE
              CreateGraphs(node(s1.FensterFunc).graphs,node(s1.FensterFunc).func(s1.Function).depend.head);
              bool:=TRUE;
            END;
          END;
          IF node(s1.FensterFunc).func(s1.Function).depend.isEmpty() THEN
            p1.PointToPic(p1.widthconv[node(s1.FensterFunc).graphs.head(s1.FunctionGraph).width-1],linex,liney);
            p3.SetColor(rast,p1.colorconv[node(s1.FensterFunc).graphs.head(s1.FunctionGraph).col],TRUE);
            IF NOT(node(s1.FensterFunc).graphs.head(s1.FunctionGraph).calced) THEN
              sizebool:=s3.RawPlotGraph(rast,p,node(s1.FensterFunc).func,node(s1.FensterFunc).graphs.head,x,y,width,height,linex,liney,TRUE,FALSE);
            ELSE
              sizebool:=s3.RawPlotGraph(rast,p,node(s1.FensterFunc).func,node(s1.FensterFunc).graphs.head,x,y,width,height,linex,liney,FALSE,FALSE);
            END;
          ELSE
            actgraph:=node(s1.FensterFunc).graphs.head;
            sizebool:=PlotGraphs(p,node,node(s1.FensterFunc).func(s1.Function).depend.head);
          END;
          IF sizebool THEN
            sizechanged:=TRUE;
          END;

          s2.UnLockFunction(node(s1.FensterFunc).func);
          node:=node.next;
(*          IF sizechanged THEN
            ResizeWindow(p,TRUE);
            node:=NIL;
          END;*)
        END;
        node:=p.texts.head;
        WHILE node#NIL DO
          IF box(p1.MathBox).stdtextcolor THEN
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colf],TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          ELSE
            p3.SetColor(rast,box(p1.MathBox).textcolor,TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          END;
          IF box(p1.MathBox).stdfont THEN
            p2.GetConvertFont(s.ADR(node(s1.GraphObject).attr),font,size);
          ELSE
            font:=box(p1.MathBox).font;
            size:=box(p1.MathBox).size;
          END;
          p2.SetFont(rast,font,size);
          p1.WindowXYToPage(box,node(s1.Coord).weltx,node(s1.Coord).welty,xpos,ypos);
          p1.PageToPagePicC(xpos,ypos,x2,y2);
          s4.RawPlotObject(rast,p,node,TRUE,x2,y2,y,height,stdwidth,stdheight,1,1,FALSE);
          node:=node.next;
        END;
        node:=p.marks.head;
        WHILE node#NIL DO
          IF box(p1.MathBox).stdtextcolor THEN
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colf],TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          ELSE
            p3.SetColor(rast,box(p1.MathBox).textcolor,TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          END;
          IF box(p1.MathBox).stdfont THEN
            p2.GetConvertFont(s.ADR(node(s1.GraphObject).attr),font,size);
          ELSE
            font:=box(p1.MathBox).font;
            size:=box(p1.MathBox).size;
          END;
          p2.SetFont(rast,font,size);
          p1.PointToPic(p1.widthconv[node(s1.Mark).width-1],linex,liney);
          p1.WindowXYToPage(box,node(s1.Coord).weltx,node(s1.Coord).welty,xpos,ypos);
          p1.PageToPagePicC(xpos,ypos,x2,y2);
          s4.RawPlotObject(rast,p,node,TRUE,x2,y2,y,height,stdwidth,stdheight,linex,liney,FALSE);
          node:=node.next;
        END;
        node:=p.points.head;
        WHILE node#NIL DO
          IF box(p1.MathBox).stdtextcolor THEN
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colf],TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          ELSE
            p3.SetColor(rast,box(p1.MathBox).textcolor,TRUE);
            p3.SetColor(rast,p1.colorconv[node(s1.GraphObject).colb],FALSE);
          END;
          IF box(p1.MathBox).stdfont THEN
            p2.GetConvertFont(s.ADR(node(s1.GraphObject).attr),font,size);
          ELSE
            font:=box(p1.MathBox).font;
            size:=box(p1.MathBox).size;
          END;
          p2.SetFont(rast,font,size);
          p1.WindowXYToPage(box,node(s1.Coord).weltx,node(s1.Coord).welty,xpos,ypos);
          p1.PageToPagePicC(xpos,ypos,x2,y2);
          s4.RawPlotObject(rast,p,node,TRUE,x2,y2,y,height,stdwidth,stdheight,1,1,FALSE);
          node:=node.next;
        END;
        node:=p.areas.head;
        WHILE node#NIL DO
          IF NOT(node(s1.Area).areab) THEN
            IF stdwidth>30 THEN
              bool:=TRUE;
            ELSE
              bool:=FALSE;
            END;
            IF box(p1.MathBox).stdgraphcolor THEN
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colf],TRUE);
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colb],FALSE);
            ELSE
              p3.SetColor(rast,box(p1.MathBox).graphcolor,TRUE);
              p3.SetColor(rast,p1.colorconv[node(s1.Area).colb],FALSE);
            END;
            s4.RawPlotArea(rast,p,node,x,y,width,height,FALSE,bool);
          END;
          node:=node.next;
        END;
        IF sizechanged THEN
(*          SetAllPointers(TRUE);*)
        END;
      UNTIL NOT(sizechanged);
(*      SetAllPointers(FALSE);*)
(*      I.RefreshWindowFrame(p.wind);*)
    END;
  END;
END PlotFenster;

(*PROCEDURE PlotLine(node:l.Node);

VAR fast : BOOLEAN;

BEGIN
(*  WITH node: p1.Line DO
    IF (print) OR NOT(node.fastdraw) THEN
      fast:=FALSE;
    ELSE
      fast:=TRUE;
    END;
    p1.PageToPagePicC(node.xpos,node.ypos,x,y);
    p1.PageToPagePic(node.width,node.height,width,height);
(*    INC(x,offx);
    INC(y,offy);*)
    RawPlotLine(rast,node,x,y,width,height,fast);
  END;*)
END PlotLine;

PROCEDURE PlotCircle(node:l.Node);

VAR fast : BOOLEAN;

BEGIN
(*  WITH node: p1.Circle DO
    IF (print) OR NOT(node.fastdraw) THEN
      fast:=FALSE;
    ELSE
      fast:=TRUE;
    END;
    p1.PageToPagePicC(node.xpos,node.ypos,x,y);
    p1.PageToPagePic(node.width,node.height,width,height);
(*    INC(x,offx);
    INC(y,offy);*)
    RawPlotCircle(rast,node,x,y,width,height,fast);
  END;*)
END PlotCircle;*)

BEGIN
  node:=p1.fonts.head;
  WHILE node#NIL DO
    node(p1.Font).notfound:=FALSE;
    node(p1.Font).used:=FALSE;
    node(p1.Font).fsizes.Init;
    node2:=node(p1.Font).sizes.head;
    WHILE node2#NIL DO
      node2(p1.FontSize).notfound:=FALSE;
      node2(p1.FontSize).used:=FALSE;
      node2:=node2.next;
    END;
    node:=node.next;
  END;
  node:=p1.colors.head;
  WHILE node#NIL DO
    node(p1.Color).used:=FALSE;
    node:=node.next;
  END;
(*  IF ruler THEN
    g.SetRast(rast,0);
  END;*)
(*  IF print THEN
    INC(offx,p1.stdoffx);
    INC(offy,p1.stdoffy);
    INC(offx,4);
    INC(offy,p1.top);
  END;*)
  p1.PageToPagePicC(0,0,x,y);
  p1.PageToPagePic(p1.globals.pagewidth,p1.globals.pageheight,width,height);
(*  DEC(x,offx);
  DEC(y,offy);*)
  IF x<p1.stdoffx+4 THEN
    x:=p1.stdoffx+4;
  END;
  IF y<p1.stdoffy+p1.top THEN
    y:=p1.stdoffy+p1.top;
  END;
(*  IF (ruler) AND (wind#NIL) THEN
    g.SetAPen(rast,0);
    p1.RectFill(rast,0,0,x-1,wind.height-1);
    p1.RectFill(rast,0,0,wind.width-1,y-1);
    p1.RectFill(rast,x+width-p1.offx+1,0,wind.width-1,wind.height-1);
    p1.RectFill(rast,0,y+height-p1.offy+1,wind.width-1,wind.height-1);
  END;*)
  IF NOT(print) AND (wind#NIL) THEN
    x2:=x+width-p1.offx;
    y2:=y+height-p1.offy;
    xb:=x+p1.EditWidth()-1;
    yb:=y+p1.EditHeight()-1;
    xs:=x2+10;
    ys:=y2+5;
    IF xs>xb THEN
      xs:=xb;
    END;
    IF ys>yb THEN
      ys:=yb;
    END;
    IF x2>=xb THEN
      x2:=xb;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,x2+1,p1.top,xb,yb);
      g.SetAPen(rast,1);
      liney:=y+5-p1.offy;
      IF liney<y THEN
        liney:=y;
      END;
      g.RectFill(rast,x2+1,liney,xs,ys);
    END;
    IF y2>=yb THEN
      y2:=yb;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,4,y2+1,xb,yb);
      g.SetAPen(rast,1);
      linex:=x+10-p1.offx;
      IF linex<x THEN
        linex:=x;
      END;
      g.RectFill(rast,linex,y2+1,xs,ys);
    END;
    g.SetBPen(rast,p1.globals.backcolor);
    g.SetAPen(rast,p1.globals.backcolor);
    p1.RectFill(rast,x,y,x2,y2);
  END;
  IF (p1.rasteron) AND NOT(print) THEN
    p2.PlotRaster;
  END;
  p1.PageToPagePic(0.5,0.5,stdwidth,stdheight);
  IF stdwidth<1 THEN
    stdwidth:=1;
  END;
  IF stdheight<1 THEN
    stdheight:=1;
  END;
  IF NOT(print) THEN
    p3.ReleaseColorPens;
  END;
  g.SetDrMd(rast,g.jam1);
  node:=p1.boxes.head;
  WHILE node#NIL DO
    IF NOT(node(p1.Box).fastdraw) OR (print) THEN
      IF node IS p1.Fenster THEN
        node2:=node(p1.Fenster).node;
        IF node2 IS s1.Fenster THEN
          WITH node2: s1.Fenster DO
            p1.PageToPagePicC(node(p1.Box).xpos,node(p1.Box).ypos,x,y);
            p1.PageToPagePic(node(p1.Box).width,node(p1.Box).height,width,height);
  (*          DEC(x,offx);
            DEC(y,offy);*)
            IF (print) OR NOT(node(p1.Box).fastdraw) THEN
              p2.SetBoxFont(rast,node);
              s1.WaitMathPri(node2);
              s1.LockNode(node2);
              PlotFenster(node,node2);
              s1.UnLockNode(node2);
(*            ELSE
              p5.DrawFastBorder(rast,x,y,width,height);*)
  (*            g.SetAPen(rast,1);
              g.Move(rast,x,y);
              g.Draw(rast,x+width-1,y);
              g.Draw(rast,x+width-1,y+height-1);
              g.Draw(rast,x,y+height-1);
              g.Draw(rast,x,y);
              g.Draw(rast,x+width-1,y+height-1);
              g.Move(rast,x+width-1,y);
              g.Draw(rast,x,y+height-1);*)
            END;
          END;
        END;
      ELSIF node IS p1.Table THEN
        s1.WaitMathPri(node(p1.Table).node);
        s1.LockNode(node(p1.Table).node);
        p6.PlotTable(rast,node);
        s1.UnLockNode(node(p1.Table).node);
  (*      p1.PageToPagePicC(node(p1.Box).xpos,node(p1.Box).ypos,x,y);
        p2.SetBoxFont(rast,node);
        s9.RawPlotTable(rast,node(p1.Table).node,x,y,node(p1.Table).node(s1.Table).lwidth,node(p1.Table).node(s1.Table).lheight);*)
      ELSIF node IS p1.List THEN
        s1.WaitMathPri(node(p1.List).node);
        s1.LockNode(node(p1.List).node);
        p6.PlotList(rast,node);
        s1.UnLockNode(node(p1.List).node);
      ELSIF node IS p1.Legend THEN
        s1.WaitMathPri(node(p1.Legend).node);
        s1.LockNode(node(p1.Legend).node);
        p6.PlotLegend(rast,node);
        s1.UnLockNode(node(p1.Legend).node);
      ELSIF node IS p1.Line THEN
        PlotLine(rast,node,print);
      ELSIF node IS p1.Rect THEN
        PlotRect(rast,node,print);
      ELSIF node IS p1.Circle THEN
        PlotCircle(rast,node,print);
      ELSIF node IS p1.TextLine THEN
        p4.PlotTextLine(rast,node,TRUE);
      ELSIF node IS p1.TextBlock THEN
        bool:=p4.PlotTextBlock(wind,rast,node,NIL,TRUE,FALSE);
      END;
    ELSE
      p1.PageToPagePicC(node(p1.Box).xpos,node(p1.Box).ypos,x,y);
      p1.PageToPagePic(node(p1.Box).width,node(p1.Box).height,width,height);
      p5.DrawFastBorder(rast,x,y,width,height);
    END;
    node:=node.next;
  END;
  IF ruler THEN
    p2.PlotRuler(FALSE);
  END;
  IF wind#NIL THEN
    I.RefreshWindowFrame(wind);
  END;

  p1.numcolors:=0;
  bool:=FALSE;
  node:=p1.colors.head;
  WHILE node#NIL DO
    IF node(p1.Color).used THEN
      INC(p1.numcolors);
    END;
    IF node=p1.white THEN
      bool:=TRUE;
    END;
    node:=node.next;
  END;
  IF NOT(bool) THEN
    INC(p1.numcolors);
  END;
END PlotPage;

PROCEDURE PrefsToPPrefs*(prefs:I.PreferencesPtr;pprefs:p1.PrinterPrefsPtr);

BEGIN
  pprefs.printDensity:=prefs.printDensity;
  pprefs.printQuality:=prefs.printQuality;
  pprefs.printAspect:=prefs.printAspect;
  pprefs.printShade:=prefs.printShade;
  pprefs.paperSize:=prefs.paperSize;
  pprefs.printFlags:=prefs.printFlags;
END PrefsToPPrefs;

PROCEDURE PPrefsToPrefs*(pprefs:p1.PrinterPrefsPtr;prefs:I.PreferencesPtr);

BEGIN
  prefs.printDensity:=pprefs.printDensity;
  prefs.printQuality:=pprefs.printQuality;
  prefs.printAspect:=pprefs.printAspect;
  prefs.printShade:=pprefs.printShade;
  prefs.paperSize:=pprefs.paperSize;
  prefs.printFlags:=pprefs.printFlags;
END PPrefsToPrefs;

PROCEDURE PrinterSettings*(VAR pprefs:p1.PrinterPrefsPtr):BOOLEAN;

VAR wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    ok,ca,
    help,
    resslide,
    quality,
    aspect,
    blackwhite,
    grey,
    color,
    ordered,
    halftone,
    colstr,
    colslide,
    floyd,red,
    green,blue  : I.GadgetPtr;
    ret         : BOOLEAN;
    qualitytext,
    aspecttext  : ARRAY 2 OF ARRAY 80 OF CHAR;
    qualitypos,
    aspectpos,
    olddepth,
    maxCols     : INTEGER;
    port        : e.MsgPortPtr;
    req         : p.IODRPReqPtr;
    pd          : p.PrinterDataPtr;
    ped         : p.PrinterExtendedDataPtr;
    prefs       : I.PreferencesPtr;
    short,
    olddensity  : SHORTINT;
    string      : ARRAY 80 OF CHAR;
    long        : LONGINT;

PROCEDURE RefreshResolution;

VAR str : ARRAY 10 OF CHAR;

BEGIN
  g.SetDrMd(rast,g.jam2);
  g.SetAPen(rast,2);
  bool:=c.IntToString(ped.xDotsInch,string,4);
  st.Delete(string,0,1);
  bool:=c.IntToString(ped.yDotsInch,str,4);
  st.Delete(str,0,1);
  st.AppendChar(string,"x");
  st.Append(string,str);
  tt.Print(30,58,s.ADR(string),rast);
END RefreshResolution;

PROCEDURE RefreshGadgets;

BEGIN
  EXCL(blackwhite.flags,I.selected);
  EXCL(grey.flags,I.selected);
  EXCL(color.flags,I.selected);
  IF prefs.printShade=I.shadeBW THEN
    INCL(blackwhite.flags,I.selected);
  END;
  IF prefs.printShade=I.shadeGreyScale THEN
    INCL(grey.flags,I.selected);
  END;
  IF prefs.printShade=I.shadeColor THEN
    INCL(color.flags,I.selected);
  END;

  EXCL(ordered.flags,I.selected);
  EXCL(halftone.flags,I.selected);
  EXCL(floyd.flags,I.selected);
  IF I.halftoneDithering IN prefs.printFlags THEN
    INCL(halftone.flags,I.selected);
  ELSIF I.floydDithering IN prefs.printFlags THEN
    INCL(floyd.flags,I.selected);
  ELSE
    INCL(ordered.flags,I.selected);
  END;

  EXCL(red.flags,I.selected);
  EXCL(green.flags,I.selected);
  EXCL(blue.flags,I.selected);
  IF I.correctRed IN prefs.printFlags THEN
    INCL(red.flags,I.selected);
  END;
  IF I.correctGreen IN prefs.printFlags THEN
    INCL(green.flags,I.selected);
  END;
  IF I.correctBlue IN prefs.printFlags THEN
    INCL(blue.flags,I.selected);
  END;
  IF wind#NIL THEN
    I.RefreshGList(blackwhite,wind,NIL,9);
  END;
END RefreshGadgets;

PROCEDURE RefreshCol;

BEGIN
  olddepth:=s.LSH(1,pprefs.numGreyColors);
  bool:=c.IntToString(olddepth,string,3);
  tt.Clear(string);
  gm.PutGadgetText(colstr,string);
  I.RefreshGList(colstr,wind,NIL,1);
  gm.SetSlider(colslide,wind,2,maxCols,pprefs.numGreyColors);
  bool:=I.ActivateGadget(colstr^,wind,NIL);
END RefreshCol;

BEGIN
  ret:=FALSE;
  port:=es.CreatePort("",0);
  req:=es.CreateExtIO(port,s.SIZE(p.IODRPReq));
  short:=e.OpenDevice("printer.device",0,req,LONGSET{});
  IF short=0 THEN
    pd:=s.VAL(p.PrinterDataPtr,req.device);
    ped:=s.ADR(pd.segmentData.ped);
    prefs:=s.ADR(pd.preferences);

    IF pprefs.printDensity=-1 THEN
      PrefsToPPrefs(prefs,pprefs);
      pprefs.numGreyColors:=3;
    ELSE
      PPrefsToPrefs(pprefs,prefs);
    END;
  
    IF printerId=-1 THEN
      printerId:=wm.InitWindow(20,20,462,168,ac.GetString(ac.PrinterSettings),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
    END;
    gm.StartGadgets(s1.window);
    ok:=gm.SetBooleanGadget(14,147,100,14,ac.GetString(ac.OK));
    ca:=gm.SetBooleanGadget(348,147,100,14,ac.GetString(ac.Cancel));
    help:=gm.SetBooleanGadget(120,147,100,14,ac.GetString(ac.Help));
    resslide:=gm.SetPropGadget(110,50,168,12,0,0,32767,0);
    COPY(ac.GetString(ac.QualityPrintout)^,qualitytext[0]);
    COPY(ac.GetString(ac.DraftPrintout)^,qualitytext[1]);
    quality:=gm.SetCycleGadget(26,64,252,14,qualitytext[0]);
    COPY(ac.GetString(ac.Portrait)^,aspecttext[0]);
    COPY(ac.GetString(ac.Landscape)^,aspecttext[1]);
    aspect:=gm.SetCycleGadget(26,79,252,14,aspecttext[0]);
    blackwhite:=gm.SetRadioGadget(150,95);
    grey:=gm.SetRadioGadget(150,105);
    color:=gm.SetRadioGadget(150,115);
    ordered:=gm.SetRadioGadget(419,40);
    halftone:=gm.SetRadioGadget(419,50);
    floyd:=gm.SetRadioGadget(419,60);
    colstr:=gm.SetStringGadget(282,80,32,14,5);
    colslide:=gm.SetPropGadget(330,81,106,12,0,0,32767,0);
    red:=gm.SetCheckBoxGadget(410,105,26,9,FALSE);
    green:=gm.SetCheckBoxGadget(410,116,26,9,FALSE);
    blue:=gm.SetCheckBoxGadget(410,127,26,9,FALSE);
    gm.EndGadgets;
    wm.SetGadgets(printerId,ok);
    wm.ChangeScreen(printerId,p1.previewscreen);
    RefreshGadgets;
    wind:=wm.OpenWindow(printerId);
    IF wind#NIL THEN
      rast:=wind.rPort;
  
      gm.DrawPropBorders(wind);
  
      it.DrawBorder(rast,14,16,434,128);
      it.DrawBorder(rast,20,28,422,113);
      it.DrawBorder(rast,26,50,80,12);
  
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.PrinterSettings),rast);
      tt.Print(26,47,ac.GetString(ac.ResolutionPrinter),rast);
      tt.Print(282,37,ac.GetString(ac.GrayScaleRastering),rast);
      tt.Print(282,102,ac.GetString(ac.ColorCorrection),rast);
      tt.Print(282,77,ac.GetString(ac.NumberGraySteps),rast);
      COPY(ac.GetString(ac.Driver)^,string);
      st.Append(string,": ");
      st.Append(string,ped.printerName^);
      tt.Print(26,37,s.ADR(string),rast);
      g.SetAPen(rast,2);
      tt.Print(26,102,ac.GetString(ac.BlackAndWhite),rast);
      tt.Print(26,112,ac.GetString(ac.GrayScale),rast);
      tt.Print(26,122,ac.GetString(ac.Color),rast);
      tt.Print(282,47,ac.GetString(ac.Ordered),rast);
      tt.Print(282,57,ac.GetString(ac.Halftone),rast);
      tt.Print(282,67,ac.GetString(ac.FloydSteinberg),rast);
      tt.Print(282,113,ac.GetString(ac.Red),rast);
      tt.Print(282,124,ac.GetString(ac.Green),rast);
      tt.Print(282,135,ac.GetString(ac.Blue),rast);

      gt.GetModeDims(g.ntscMonitorID+g.loresKey,I.oScanText,i,i,maxCols);
      IF (maxCols=5) OR (maxCols=6) THEN
        maxCols:=4;
      END;

      req.command:=p.dumpRPort;
      req.rastPort:=rast;
      req.colorMap:=p1.previewscreen.viewPort.colorMap;
      req.srcX:=0;
      req.srcY:=0;
      req.srcWidth:=16;
      req.srcHeight:=1;
      req.destCols:=16;
      req.destRows:=1;
      req.special:=SET{p.noFormFeed,p.aspect,p.center,p.noPrint};
      short:=e.DoIO(req);
      gm.SetSlider(resslide,wind,1,7,prefs.printDensity);
      RefreshResolution;
      IF prefs.printQuality=I.draft THEN
        gm.CyclePressed(quality,wind,qualitytext,qualitypos);
      END;
      IF prefs.printAspect=I.aspectVert THEN
        gm.CyclePressed(aspect,wind,aspecttext,aspectpos);
      END;
      RefreshCol;

      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        olddensity:=prefs.printDensity;
        prefs.printDensity:=SHORT(gm.GetSlider(resslide,1,7));
        IF olddensity#prefs.printDensity THEN
          short:=e.DoIO(req);
          RefreshResolution;
        END;
        olddepth:=pprefs.numGreyColors;
        pprefs.numGreyColors:=gm.GetSlider(colslide,2,maxCols);
        IF olddepth#pprefs.numGreyColors THEN
          RefreshCol;
          bool:=I.ActivateGadget(colslide^,wind,NIL);
        END;
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            PrefsToPPrefs(prefs,pprefs);
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            EXIT;
          ELSIF address=quality THEN
            gm.CyclePressed(quality,wind,qualitytext,qualitypos);
            IF prefs.printQuality=I.draft THEN
              prefs.printQuality:=I.letter;
            ELSE
              prefs.printQuality:=I.draft;
            END;
          ELSIF address=aspect THEN
            gm.CyclePressed(aspect,wind,aspecttext,aspectpos);
            IF prefs.printAspect=I.aspectHoriz THEN
              prefs.printAspect:=I.aspectVert;
            ELSE
              prefs.printAspect:=I.aspectHoriz;
            END;
          ELSIF address=colstr THEN
            gm.GetGadgetText(colstr,string);
            bool:=c.StringToInt(string,long);
            long:=long DIV 4;
            pprefs.numGreyColors:=2;
            WHILE long>1 DO
              long:=long DIV 2;
              INC(pprefs.numGreyColors);
            END;
            IF pprefs.numGreyColors>maxCols THEN
              pprefs.numGreyColors:=maxCols;
            END;
            RefreshCol;
            bool:=I.ActivateGadget(colstr^,wind,NIL);
          ELSIF address=blackwhite THEN
            prefs.printShade:=I.shadeBW;
            RefreshGadgets;
          ELSIF address=grey THEN
            prefs.printShade:=I.shadeGreyScale;
            RefreshGadgets;
          ELSIF address=color THEN
            prefs.printShade:=I.shadeColor;
            RefreshGadgets;
          ELSIF address=ordered THEN
            EXCL(prefs.printFlags,I.halftoneDithering);
            EXCL(prefs.printFlags,I.floydDithering);
            RefreshGadgets;
          ELSIF address=halftone THEN
            INCL(prefs.printFlags,I.halftoneDithering);
            EXCL(prefs.printFlags,I.floydDithering);
            RefreshGadgets;
          ELSIF address=floyd THEN
            EXCL(prefs.printFlags,I.halftoneDithering);
            INCL(prefs.printFlags,I.floydDithering);
            RefreshGadgets;
          ELSIF address=red THEN
            IF I.correctRed IN prefs.printFlags THEN
              EXCL(prefs.printFlags,I.correctRed);
            ELSE
              INCL(prefs.printFlags,I.correctRed);
            END;
          ELSIF address=green THEN
            IF I.correctGreen IN prefs.printFlags THEN
              EXCL(prefs.printFlags,I.correctGreen);
            ELSE
              INCL(prefs.printFlags,I.correctGreen);
            END;
          ELSIF address=blue THEN
            IF I.correctBlue IN prefs.printFlags THEN
              EXCL(prefs.printFlags,I.correctBlue);
            ELSE
              INCL(prefs.printFlags,I.correctBlue);
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"printersettings",wind);
        END;
      END;
  
      wm.CloseWindow(printerId);
    END;
    wm.FreeGadgets(printerId);

    e.CloseDevice(req);
    es.DeleteExtIO(req);
    es.DeletePort(port);
  END;
  RETURN ret;
END PrinterSettings;

PROCEDURE * PrintPath*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(p1.paths,num);
  IF node#NIL THEN
    WITH node: p1.Path DO
      NEW(str);
      COPY(node.path,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintPath;

PROCEDURE Lower(str1,str2:ARRAY OF CHAR):BOOLEAN;

VAR ret   : BOOLEAN;
    i,len1,
    len2  : INTEGER;

BEGIN
  len1:=SHORT(st.Length(str1));
  len2:=SHORT(st.Length(str2));
  i:=0;
  WHILE (i<len1) AND (i<len2) AND (CAP(str1[i])=CAP(str2[i])) DO
    INC(i);
  END;
  ret:=FALSE;
  IF (i<len1) AND (i<len2) THEN
    IF CAP(str1[i])<CAP(str2[i]) THEN
      ret:=TRUE;
    END;
  END;
  RETURN ret;
END Lower;

PROCEDURE Sort;

VAR node,node2,node3 : l.Node;

BEGIN
  node:=p1.fonts.head;
  WHILE node#NIL DO
    node2:=node.next;
    WHILE node2#NIL DO
      node3:=node2.next;
      IF Lower(node2(p1.Font).name,node(p1.Font).name) THEN
        node2.Remove;
        node.AddBefore(node2);
        node:=node2;
      END;
      node2:=node3;
    END;
    node:=node.next;
  END;
END Sort;

PROCEDURE ChangeFonts*():BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    addf,delf,
    sortf,
    addp,delp,
    font,path: I.GadgetPtr;
    ret      : BOOLEAN;
    fontlist,
    pathlist,
    actfont,
    actpath,
    node     : l.Node;

PROCEDURE RefreshFont;

BEGIN
  IF actfont#NIL THEN
    gm.PutGadgetText(font,actfont(p1.Font).name);
    I.RefreshGList(font,wind,NIL,1);
    bool:=I.ActivateGadget(font^,wind,NIL);
  END;
END RefreshFont;

PROCEDURE NewFontList;

BEGIN
  gm.SetListViewParams(fontlist,20,28,260,84,SHORT(p1.fonts.nbElements()),s1.GetNodeNumber(p1.fonts,actfont),p2.PrintFontName);
  gm.SetCorrectPosition(fontlist);
  gm.RefreshListView(fontlist);
END NewFontList;

PROCEDURE RefreshPath;

BEGIN
  IF actpath#NIL THEN
    gm.PutGadgetText(path,actpath(p1.Path).path);
    I.RefreshGList(path,wind,NIL,1);
    bool:=I.ActivateGadget(path^,wind,NIL);
  END;
END RefreshPath;

PROCEDURE NewPathList;

BEGIN
  gm.SetListViewParams(pathlist,286,28,260,84,SHORT(p1.paths.nbElements()),s1.GetNodeNumber(p1.paths,actpath),PrintPath);
  gm.SetCorrectPosition(pathlist);
  gm.RefreshListView(pathlist);
END NewPathList;

BEGIN
  ret:=FALSE;
  IF changefontsId=-1 THEN
    changefontsId:=wm.InitWindow(20,20,564,199,ac.GetString(ac.Fonts),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,178,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(452,178,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,178,100,14,ac.GetString(ac.Help));
  addf:=gm.SetBooleanGadget(20,128,260,14,ac.GetString(ac.NewFont));
  delf:=gm.SetBooleanGadget(20,143,260,14,ac.GetString(ac.DelFont));
  sortf:=gm.SetBooleanGadget(20,158,260,14,ac.GetString(ac.SortFonts));
  addp:=gm.SetBooleanGadget(286,128,260,14,ac.GetString(ac.NewPath));
  delp:=gm.SetBooleanGadget(286,143,260,14,ac.GetString(ac.DelPath));
  font:=gm.SetStringGadget(20,112,248,14,255);
  path:=gm.SetStringGadget(286,112,248,14,255);
  fontlist:=gm.SetListView(20,28,260,84,0,0,p2.PrintFontName);
  pathlist:=gm.SetListView(286,28,260,84,0,0,PrintPath);
  gm.EndGadgets;
  wm.SetGadgets(changefontsId,ok);
  wm.ChangeScreen(changefontsId,p1.previewscreen);
  wind:=wm.OpenWindow(changefontsId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    it.DrawBorder(rast,14,16,538,159);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.Fonts),rast);
    tt.Print(288,25,ac.GetString(ac.PathCurrentFont),rast);

    gm.SetCorrectWindow(fontlist,wind);
    gm.SetCorrectWindow(pathlist,wind);
    gm.SetNoEntryText(fontlist,ac.GetString(ac.None),ac.GetString(ac.FontsEx));
    gm.SetNoEntryText(pathlist,ac.GetString(ac.None),ac.GetString(ac.PathsEx));

    actfont:=p1.fonts.head;
    IF actfont#NIL THEN
      actpath:=actfont(p1.Font).path;
    ELSE
      actpath:=p1.paths.head;
    END;
    NewFontList;
    NewPathList;
    RefreshFont;
    RefreshPath;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF actfont#NIL THEN
        gm.GetGadgetText(font,actfont(p1.Font).name);
      END;
      IF actpath#NIL THEN
        gm.GetGadgetText(path,actpath(p1.Path).path);
      END;
      bool:=gm.CheckListView(fontlist,class,code,address);
      IF bool THEN
        actfont:=s1.GetNode(p1.fonts,gm.ActEl(fontlist));
        IF (actfont#NIL) AND (actfont(p1.Font).path#NIL) THEN
          actpath:=actfont(p1.Font).path;
        END;
        RefreshFont;
        RefreshPath;
        NewPathList;
      END;
      bool:=gm.CheckListView(pathlist,class,code,address);
      IF bool THEN
        actpath:=s1.GetNode(p1.paths,gm.ActEl(pathlist));
        IF actfont#NIL THEN
          actfont(p1.Font).path:=actpath;
        END;
        RefreshPath;
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=addf THEN
          actfont:=NIL;
          NEW(actfont(p1.Font));
          actfont(p1.Font).name:="";
          actfont(p1.Font).path:=p1.paths.head;
          actfont(p1.Font).sizes:=l.Create();
          actfont(p1.Font).fsizes:=l.Create();
          actfont(p1.Font).outline:=TRUE;
          p1.fonts.AddTail(actfont);
          node:=NIL;
          NEW(node(p1.FontSize));
          node(p1.FontSize).size:=12;
          node(p1.FontSize).ideal:=TRUE;
          actfont(p1.Font).sizes.AddTail(node);
          RefreshFont;
          NewFontList;
        ELSIF address=delf THEN
          IF actfont#NIL THEN
            node:=actfont.next;
            IF node=NIL THEN
              node:=actfont.prev;
            END;
            actfont.Remove;
            actfont:=node;
            RefreshFont;
            NewFontList;
          END;
        ELSIF address=sortf THEN
          Sort;
          RefreshFont;
          NewFontList;
        ELSIF address=addp THEN
          actpath:=NIL;
          NEW(actpath(p1.Path));
          actpath(p1.Path).path:="";
          p1.paths.AddTail(actpath);
          IF actfont#NIL THEN
            actfont(p1.Font).path:=actpath;
          END;
          RefreshPath;
          NewPathList;
        ELSIF address=delp THEN
          IF actpath#NIL THEN
            node:=actpath.next;
            IF node=NIL THEN
              node:=actpath.prev;
            END;
            actpath.Remove;
            actpath:=node;
            IF actfont#NIL THEN
              actfont(p1.Font).path:=actpath;
            END;
            RefreshPath;
            NewPathList;
          END;
        ELSIF address=font THEN
          NewFontList;
          bool:=I.ActivateGadget(path^,wind,NIL);
        ELSIF address=path THEN
          NewPathList;
          bool:=I.ActivateGadget(font^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"changefonts",wind);
      END;
    END;

    wm.CloseWindow(changefontsId);
  END;
  wm.FreeGadgets(changefontsId);
  RETURN ret;
END ChangeFonts;

(*PROCEDURE ChangeDisplay*():BOOLEAN;

VAR wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    ok,ca,
    help,
    maxtolgad,
    maxtolstr : I.GadgetPtr;
    string    : ARRAY 10 OF CHAR;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    old       : INTEGER;
    long      : LONGINT;
    ret       : BOOLEAN;
    save      : INTEGER;
    bool      : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF changedisplayId=-1 THEN
    changedisplayId:=wm.InitWindow(20,20,232,68,ac.GetString(ac.ScreenPresentation),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,47,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(118,47,100,14,ac.GetString(ac.Cancel));
  maxtolstr:=gm.SetStringGadget(20,28,32,14,4);
  maxtolgad:=gm.SetPropGadget(68,29,144,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(changedisplayId,ok);
  wm.ChangeScreen(changedisplayId,p1.previewscreen);
  wind:=wm.OpenWindow(changedisplayId);
  IF wind#NIL THEN
    rast:=wind.rPort;
(*    ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,46,100,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),116,46,100,
                      SET{I.gadgImmediate,I.relVerify});*)

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,204,28);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.MaximumDistortionInPerCent),rast);
(*    ig.SetPlastStringGadget(zoomstr,wind,32,4,20,28,FALSE);
    ig.SetPlastProp(zoomgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},70,30,140,8,
                    0,4096,wind);*)

    save:=p1.maxtol;

    bool:=c.IntToString(p1.maxtol,string,3);
    tt.Clear(string);
    gm.PutGadgetText(maxtolstr,string);
    I.RefreshGList(maxtolstr,wind,NIL,1);
    bool:=I.ActivateGadget(maxtolstr^,wind,NIL);
    gm.SetSlider(maxtolgad,wind,0,50,p1.maxtol);

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      old:=p1.maxtol;
      gm.GetGadgetText(maxtolstr,string);
      p1.maxtol:=gm.GetSlider(maxtolgad,0,50);
      IF old#p1.maxtol THEN
        bool:=c.IntToString(p1.maxtol,string,3);
        tt.Clear(string);
        gm.PutGadgetText(maxtolstr,string);
        I.RefreshGList(maxtolstr,wind,NIL,1);
        bool:=I.ActivateGadget(maxtolstr^,wind,NIL);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          bool:=c.StringToInt(string,long);
          p1.maxtol:=SHORT(long);
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          p1.maxtol:=save;
          EXIT;
        ELSIF address=maxtolstr THEN
          bool:=c.StringToInt(string,long);
          p1.maxtol:=SHORT(long);
          IF p1.maxtol<0 THEN
            p1.maxtol:=0;
            bool:=c.IntToString(p1.maxtol,string,3);
            tt.Clear(string);
            gm.PutGadgetText(maxtolstr,string);
            I.RefreshGList(maxtolstr,wind,NIL,1);
          ELSIF p1.maxtol>50 THEN
            p1.maxtol:=50;
            bool:=c.IntToString(p1.maxtol,string,3);
            tt.Clear(string);
            gm.PutGadgetText(maxtolstr,string);
            I.RefreshGList(maxtolstr,wind,NIL,1);
          END;
          gm.SetSlider(maxtolgad,wind,0,50,p1.maxtol);
          bool:=I.ActivateGadget(maxtolstr^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"changedisplay",wind);
      END;
    END;

(*    ig.FreePlastPropGadget(zoomgad,wind);
    ig.FreeStringGadget(zoomstr,wind);
    ig.FreePlastHighBooleanGadget(ca,wind);
    ig.FreePlastHighBooleanGadget(ok,wind);*)
    wm.CloseWindow(changedisplayId);
  END;
  wm.FreeGadgets(changedisplayId);
  RETURN ret;
END ChangeDisplay;*)

PROCEDURE ZoomIn*():BOOLEAN;

VAR x1,y1,x2,y2,
    dx,dy,editx,
    edity         : INTEGER;
    ret           : BOOLEAN;
    pagex,pagey,
    pagewi,pagehe,
    editwi,edithe,
    zoom          : LONGREAL;

PROCEDURE DrawRect;

BEGIN
  g.Move(p1.previewrast,x1,y1);
  g.Draw(p1.previewrast,x2,y1);
  g.Draw(p1.previewrast,x2,y2);
  g.Draw(p1.previewrast,x1,y2);
  g.Draw(p1.previewrast,x1,y1);
END DrawRect;

BEGIN
  ret:=FALSE;
  g.SetDrMd(p1.previewrast,SHORTSET{g.complement});
  editx:=p1.EditWidth();
  edity:=p1.EditHeight();
  p1.PagePicToPage(editx,edity,editwi,edithe);
  it.GetMousePos(p1.previewwindow,x1,y1);
  x2:=x1;
  y2:=y1;
  DrawRect;
  REPEAT
    e.WaitPort(p1.previewwindow.userPort);
    REPEAT
      it.GetIMes(p1.previewwindow,class,code,address);
    UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class) OR (I.intuiTicks IN class) OR (class=LONGSET{});
    IF NOT(I.intuiTicks IN class) THEN
      DrawRect;
      it.GetMousePos(p1.previewwindow,x2,y2);
(*      IF x2<x1 THEN
        dx:=x1;
        x1:=x2;
        x2:=dx;
      END;
      IF y2<y1 THEN
        dy:=y1;
        y1:=y2;
        y2:=dy;
      END;*)
      dx:=x2-x1;
      dy:=y2-y1;
(*      p1.PagePicToPage(dx,dy,pagex,pagey);
      IF pagex<pagey THEN*)
        dy:=SHORT(SHORT(LONG(dx)*edity/editx));
(*      ELSE
        dx:=SHORT(SHORT(LONG(dy)*editx/edity));
      END;*)
      x2:=x1+dx;
      y2:=y1+dy;
      DrawRect;
    END;
  UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class);
  DrawRect;
  IF NOT(I.menuPick IN class) THEN
(*    IF dx=0 THEN
      dx:=1;
    END;
    IF dy=0 THEN
      dy:=1;
    END;*)
    IF x2<x1 THEN
      x1:=x2;
    END;
    IF y2<y1 THEN
      y1:=y2;
    END;
    p1.PagePicToPageC(x1,y1,pagex,pagey);
    p1.PagePicToPage(ABS(dx),ABS(dy),pagewi,pagehe);
    IF pagewi<=0 THEN
      pagewi:=0.01;
    END;
    zoom:=editwi/pagewi*p1.zoom;
    IF zoom<20 THEN
      zoom:=20;
    END;
    IF zoom>500 THEN
      zoom:=500;
    END;
    p1.zoom:=SHORT(SHORT(SHORT(zoom)));
    p1.CorrectPageDimensions;
    p1.PageToPagePic(pagex,pagey,p1.offx,p1.offy);
    p1.rulerchanged:=TRUE;
    ret:=TRUE;
  END;
  g.SetDrMd(p1.previewrast,g.jam1);
  RETURN ret;
END ZoomIn;

BEGIN
  printerId:=-1;
  changefontsId:=-1;
  changedisplayId:=-1;
END Preview7.


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


MODULE SuperCalcTools16;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       gd : GadTools,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       p  : Printer,
       l  : LinkedLists,
       es : ExecSupport,
       st : Strings,
       pt : Pointers,
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       gt : GraphicsTools,
       rt : RequesterTools,
       wm : WindowManager,
       gm : GadgetManager,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
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
       s15: SuperCalcTools15,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j     : INTEGER;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    bool      : BOOLEAN;
    integId * ,
    quickId * : INTEGER;
    ifunc1,
    ifunc2      : l.Node;
    istring1,
    istring2    : ARRAY 256 OF CHAR;
    ixmin,ixmax : ARRAY 80 OF CHAR;
    iintegpos,
    iareapos,
    isteppos    : INTEGER;
    iarea       : BOOLEAN;

PROCEDURE MausBereich*(node:l.Node):BOOLEAN;

VAR px1,py1,px2,py2 : INTEGER;
    wx1,wy1,wx2,wy2 : LONGREAL;
    class           : LONGSET;
    code            : INTEGER;
    address         : s.ADDRESS;
    ret             : BOOLEAN;
    node2,node3     : l.Node;

PROCEDURE DrawRect;

BEGIN
  WITH node: s1.Fenster DO
    g.Move(node.wind.rPort,px1,py1);
    g.Draw(node.wind.rPort,px2,py1);
    g.Draw(node.wind.rPort,px2,py2);
    g.Draw(node.wind.rPort,px1,py2);
    g.Draw(node.wind.rPort,px1,py1);
  END;
END DrawRect;

BEGIN
  ret:=FALSE;
  IF node#NIL THEN
    WITH node: s1.Fenster DO
      g.SetDrMd(node.wind.rPort,SHORTSET{g.complement});
      it.GetMousePos(node.wind,px1,py1);
      px2:=px1;
      py2:=py1;
      DrawRect;
      REPEAT
        e.WaitPort(node.wind.userPort);
        it.GetIMes(node.wind,class,code,address);
        DrawRect;
        it.GetMousePos(node.wind,px2,py2);
        DrawRect;
      UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class);
      DrawRect;
      g.SetDrMd(node.wind.rPort,g.jam1);
      IF (code=I.selectUp) AND (px1#px2) AND (py1#py2) THEN
        ret:=TRUE;
(*        px1:=px1-node.inx;
        px2:=px2-node.inx;
        py1:=py1-node.iny;
(*        py1:=node.height-py1;*)
        py2:=py2-node.iny;
(*        py2:=node.height-py2;*)*)
(*        s1.PicToWelt(wx1,wy1,px1,py1,node.xmin,node.xmax,node.ymin,node.ymax,node.width,node.height);
        s1.PicToWelt(wx2,wy2,px2,py2,node.xmin,node.xmax,node.ymin,node.ymax,node.width,node.height);*)
        s1.PicToWorld(wx1,wy1,px1,py1,node);
        s1.PicToWorld(wx2,wy2,px2,py2,node);
        IF wx2>wx1 THEN
          node.xmin:=SHORT(wx1);
          node.xmax:=SHORT(wx2);
        ELSE
          node.xmin:=SHORT(wx2);
          node.xmax:=SHORT(wx1);
        END;
        IF wy2>wy1 THEN
          node.ymax:=SHORT(wy2);
          node.ymin:=SHORT(wy1);
        ELSE
          node.ymax:=SHORT(wy1);
          node.ymin:=SHORT(wy2);
        END;
        bool:=lrc.RealToString(node.xmin,node.xmins,7,7,FALSE);
        tt.Clear(node.xmins);
        bool:=lrc.RealToString(node.xmax,node.xmaxs,7,7,FALSE);
        tt.Clear(node.xmaxs);
        bool:=lrc.RealToString(node.ymin,node.ymins,7,7,FALSE);
        tt.Clear(node.ymins);
        bool:=lrc.RealToString(node.ymax,node.ymaxs,7,7,FALSE);
        tt.Clear(node.ymaxs);
        node.refresh:=TRUE;
        node2:=node(s1.Fenster).funcs.head;
        WHILE node2#NIL DO
          node3:=node2(s1.FensterFunc).graphs.head;
          WHILE node3#NIL DO
            node3(s1.FunctionGraph).calced:=FALSE;
            node3:=node3.next;
          END;
          node2:=node2.next;
        END;
        s7.CheckAxesLimits(node);
(*        Auto(node);
        PlotWind(node(s1.Fenster));*)
      END;
    END;
  END;
  RETURN ret;
END MausBereich;

PROCEDURE DrawRect*(rast:g.RastPortPtr;px1,py1,px2,py2:INTEGER);

BEGIN
  g.Move(rast,px1,py1);
  g.Draw(rast,px2,py1);
  g.Draw(rast,px2,py2);
  g.Draw(rast,px1,py2);
  g.Draw(rast,px1,py1);
END DrawRect;

PROCEDURE GetText*(p:l.Node;x,y:INTEGER):l.Node;

VAR node,node2 : l.Node;
    xpos,ypos  : INTEGER;
    yhighborder,
    ylowborder : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    node:=NIL;
    node2:=p.texts.head;
    WHILE node2#NIL DO
      WITH node2: s1.Text DO
        IF node2.welt THEN
          s1.WorldToPic(node2.weltx,node2.welty,xpos,ypos,p);
        ELSE
          xpos:=node2.picx;
          ypos:=node2.picy;
        END;
        yhighborder:=ypos;
        ylowborder:=ypos+(p.wind.rPort.txHeight)-1;
        IF (x>=xpos) AND (x<=xpos+g.TextLength(p.rast,node2.string,st.Length(node2.string))) AND (y>=yhighborder) AND (y<=ylowborder) THEN
          node:=node2;
        END;
      END;
      node2:=node2.next;
      IF node#NIL THEN
        node2:=NIL;
      END;
    END;
  END;
  RETURN node;
END GetText;

PROCEDURE SelectText*(p:l.Node):l.Node;

VAR node,
    node2   : l.Node;
    x,y,
    xpos,
    ypos    : INTEGER;
    class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;

PROCEDURE DrawActRect;

VAR xpos,ypos : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    WITH node: s1.Text DO
      IF node.welt THEN
        s1.WorldToPic(node.weltx,node.welty,xpos,ypos,p);
      ELSE
        xpos:=node.picx;
        ypos:=node.picy;
      END;
      DrawRect(p.rast,xpos,ypos-p.rast.txBaseline,xpos+g.TextLength(p.rast,node.string,st.Length(node.string)),ypos+(p.rast.txHeight-p.rast.txBaseline)-1);
    END;
  END;
END DrawActRect;

BEGIN
  WITH p: s1.Fenster DO
    g.SetDrMd(p.rast,SHORTSET{g.complement});
    node:=NIL;
    REPEAT
      IF node#NIL THEN
        DrawActRect;
      END;
      e.WaitPort(p.wind.userPort);
      IF node#NIL THEN
        DrawActRect;
      END;
      it.GetMousePos(p.wind,x,y);
      node:=GetText(p,x,y);
      it.GetIMes(p.wind,class,code,address);
      IF I.menuPick IN class THEN
        node:=NIL;
      END;
    UNTIL ((I.mouseButtons IN class) AND (code=I.selectDown)) OR (I.menuPick IN class);
    g.SetDrMd(p.rast,g.jam1);
  END;
  RETURN node;
END SelectText;

PROCEDURE MoveText*(p,text:l.Node);

VAR node   : l.Node;
    x,y    : INTEGER;
    realx,
    realy  : REAL;
    longx,
    longy  : LONGREAL;
    offx,
    offy   : INTEGER;
    roffx,
    roffy  : LONGREAL;
    opicx,
    opicy  : INTEGER;
    oweltx,
    owelty : LONGREAL;

BEGIN
  node:=p;
  WITH p: s1.Fenster DO
    WITH text: s1.Text DO
      opicx:=text.picx;
      opicy:=text.picy;
      oweltx:=text.weltx;
      owelty:=text.welty;
      it.GetMousePos(p.wind,x,y);
      offx:=text.picx-x;
      offy:=text.picy-y;
      INC(x,offx);
      INC(y,offy);
      s1.PicToWorld(longx,longy,x,y,p);
      IF text.snap THEN
        s2.SnapToFunktion(node,longx,longy);
        s1.WorldToPic(longx,longy,x,y,p);
      END;
(*      roffx:=text.weltx-realx;
      roffy:=text.welty-realy;
      IF text.snap THEN
        offy:=0;
        roffy:=0;
      END;*)
      text.picx:=x;
      text.picy:=y;
      text.weltx:=longx;
      text.welty:=longy;
      g.SetDrMd(p.rast,SHORTSET{g.complement});
      REPEAT
        s4.PlotObject(p,text,FALSE);
        e.WaitPort(p.wind.userPort);
        it.GetMousePos(p.wind,x,y);
        INC(x,offx);
        INC(y,offy);
        s4.PlotObject(p,text,FALSE);
        s1.PicToWorld(longx,longy,x,y,p);
        IF text.snap THEN
          s2.SnapToFunktion(node,longx,longy);
          s1.WorldToPic(longx,longy,x,y,p);
        END;
        text.picx:=x;
        text.picy:=y;
        text.weltx:=longx;
        text.welty:=longy;
        it.GetIMes(p.wind,class,code,address);
        IF NOT(I.mouseButtons IN class) AND NOT(I.menuPick IN class) THEN
          REPEAT
            it.GetIMes(p.wind,class,code,address);
          UNTIL NOT(I.mouseMove IN class);
        END;
      UNTIL ((I.mouseButtons IN class) AND (code=I.selectUp)) OR (I.menuPick IN class);
      IF I.menuPick IN class THEN
        text.picx:=opicx;
        text.picy:=opicy;
        text.weltx:=oweltx;
        text.welty:=owelty;
      ELSE
        IF text.welt THEN
          bool:=lrc.RealToString(text.weltx,text.xkstr,7,7,FALSE);
          bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
          tt.Clear(text.xkstr);
          tt.Clear(text.ykstr);
        ELSE
          bool:=c.IntToString(text.picx,text.xkstr,7);
          bool:=c.IntToString(text.picy,text.ykstr,7);
          tt.Clear(text.xkstr);
          tt.Clear(text.ykstr);
        END;
      END;
    END;
    g.SetDrMd(p.rast,g.jam1);
  END;
END MoveText;

PROCEDURE GetPoint*(p:l.Node;x,y:INTEGER;VAR xl,xr,yh,yl:INTEGER):l.Node;

VAR node,node2 : l.Node;
    xpos,ypos  : INTEGER;
    point      : s1.PointDataPtr;
    xleftborder,
    xrightborder,
    yhighborder,
    ylowborder,i : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    node:=NIL;
    node2:=p.points.head;
    WHILE node2#NIL DO
      WITH node2: s1.Point DO
        point:=s1.points[node2.point];
        IF node2.welt THEN
          s1.WorldToPic(node2.weltx,node2.welty,xpos,ypos,p);
        ELSE
          xpos:=node2.picx;
          ypos:=node2.picy;
        END;
        xleftborder:=xpos-s1.stdpicx;
        xrightborder:=xpos+SHORT(SHORT(SHORT(point.textx*s1.stdpicx)))+tt.TextLength(s.ADR(node2.label(s1.Label).string),p.rast,node2.weltx,node2.welty,0,node2.nach,node2.exp);
        INC(xrightborder,g.TextLength(p.rast,node2.string,st.Length(node2.string)));
(*        IF xrightborder<xpos-point.hotx+16 THEN
          xrightborder:=xpos-point.hotx+16;
        END;*)
        i:=ypos-s1.stdpicy;
        yhighborder:=ypos-SHORT(SHORT(SHORT(point.texty*s1.stdpicy)))-p.wind.rPort.txBaseline;
        IF i<yhighborder THEN
          yhighborder:=i;
        END;
        i:=ypos+s1.stdpicy;
        ylowborder:=ypos-s1.stdpicy+SHORT(SHORT(SHORT(point.texty*s1.stdpicy)))+(p.wind.rPort.txHeight-p.wind.rPort.txBaseline)-1;
        IF i>ylowborder THEN
          ylowborder:=i;
        END;
(*        IF ylowborder<ypos-point.hoty+16 THEN
          ylowborder:=ypos-point.hoty+16;
        END;*)
        IF (x>=xleftborder) AND (x<=xrightborder) AND (y>=yhighborder) AND (y<=ylowborder) THEN
          node:=node2;
        END;
      END;
      node2:=node2.next;
      IF node#NIL THEN
        node2:=NIL;
      END;
    END;
  END;
  xr:=xrightborder;
  xl:=xleftborder;
  yh:=yhighborder;
  yl:=ylowborder;
  RETURN node;
END GetPoint;

PROCEDURE SelectPoint*(p:l.Node):l.Node;

VAR node,
    node2,
    oldnode : l.Node;
    x,y,
    xpos,
    ypos    : INTEGER;
    class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    xr,xl,
    yh,yl,
    oxr,oxl,
    oyh,oyl : INTEGER;

PROCEDURE DrawActRect;

VAR xpos,ypos : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    DrawRect(p.rast,xl,yh,xr,yl);
  END;
END DrawActRect;

PROCEDURE DrawOldRect;

VAR xpos,ypos : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    DrawRect(p.rast,oxl,oyh,oxr,oyl);
  END;
END DrawOldRect;

BEGIN
  WITH p: s1.Fenster DO
    g.SetDrMd(p.rast,SHORTSET{g.complement});
    node:=NIL;
    REPEAT
      IF node#NIL THEN
        DrawActRect;
      END;
      e.WaitPort(p.wind.userPort);
      it.GetMousePos(p.wind,x,y);
      oxl:=xl;
      oxr:=xr;
      oyh:=yh;
      oyl:=yl;
      oldnode:=node;
      node:=GetPoint(p,x,y,xl,xr,yh,yl);
      it.GetIMes(p.wind,class,code,address);
      IF I.menuPick IN class THEN
        node:=NIL;
      END;
      IF oldnode#NIL THEN
        DrawOldRect;
      END;
    UNTIL ((I.mouseButtons IN class) AND (code=I.selectDown)) OR (I.menuPick IN class);
    g.SetDrMd(p.rast,g.jam1);
  END;
  RETURN node;
END SelectPoint;

PROCEDURE MovePoint*(p,point:l.Node);

VAR node : l.Node;
    x,y  : INTEGER;
    realx,
    realy: REAL;
    longx,
    longy: LONGREAL;
    offx,
    offy : INTEGER;
    roffx,
    roffy: LONGREAL;
    opicx,
    opicy  : INTEGER;
    oweltx,
    owelty : LONGREAL;

BEGIN
  node:=p;
  WITH p: s1.Fenster DO
    WITH point: s1.GraphObject DO
      opicx:=point.picx;
      opicy:=point.picy;
      oweltx:=point.weltx;
      owelty:=point.welty;
      it.GetMousePos(p.wind,x,y);
      offx:=point.picx-x;
      offy:=point.picy-y;
      INC(x,offx);
      INC(y,offy);
      s1.PicToWorld(longx,longy,x,y,p);
      IF point.snap THEN
        s2.SnapToFunktion(node,longx,longy);
        s1.WorldToPic(longx,longy,x,y,p);
      END;
(*      roffx:=text.weltx-realx;
      roffy:=text.welty-realy;
      IF text.snap THEN
        offy:=0;
        roffy:=0;
      END;*)
      point.picx:=x;
      point.picy:=y;
      point.weltx:=longx;
      point.welty:=longy;
      g.SetDrMd(p.rast,SHORTSET{g.complement});
      REPEAT
        s4.PlotObject(p,point,FALSE);
        e.WaitPort(p.wind.userPort);
        it.GetMousePos(p.wind,x,y);
        INC(x,offx);
        INC(y,offy);
        s4.PlotObject(p,point,FALSE);
        s1.PicToWorld(longx,longy,x,y,p);
        IF point.snap THEN
          s2.SnapToFunktion(node,longx,longy);
          s1.WorldToPic(longx,longy,x,y,p);
        END;
        point.picx:=x;
        point.picy:=y;
        point.weltx:=longx;
        point.welty:=longy;
        it.GetIMes(p.wind,class,code,address);
        IF NOT(I.mouseButtons IN class) AND NOT(I.menuPick IN class) THEN
          REPEAT
            it.GetIMes(p.wind,class,code,address);
          UNTIL NOT(I.mouseMove IN class);
        END;
      UNTIL ((I.mouseButtons IN class) AND (code=I.selectUp)) OR (I.menuPick IN class);
      IF I.menuPick IN class THEN
        point.picx:=opicx;
        point.picy:=opicy;
        point.weltx:=oweltx;
        point.welty:=owelty;
      ELSE
        IF point.welt THEN
          bool:=lrc.RealToString(point.weltx,point.xkstr,7,7,FALSE);
          bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
          tt.Clear(point.xkstr);
          tt.Clear(point.ykstr);
        ELSE
          bool:=c.IntToString(point.picx,point.xkstr,7);
          bool:=c.IntToString(point.picy,point.ykstr,7);
          tt.Clear(point.xkstr);
          tt.Clear(point.ykstr);
        END;
      END;
    END;
    g.SetDrMd(p.rast,g.jam1);
  END;
END MovePoint;

PROCEDURE GetMark*(p:l.Node;x,y:INTEGER;VAR xl,xr,yh,yl:INTEGER):l.Node;

VAR node,node2 : l.Node;
    xpos,ypos,
    wi,pos     : INTEGER;
    xleftborder,
    xrightborder,
    yhighborder,
    ylowborder,i : INTEGER;
    string     : e.STRPTR;
    str        : ARRAY 2 OF CHAR;

BEGIN
  WITH p: s1.Fenster DO
    node:=NIL;
    node2:=p.marks.head;
    WHILE node2#NIL DO
      WITH node2: s1.Mark DO
        IF node2.welt THEN
          s1.WorldToPic(node2.weltx,node2.welty,xpos,ypos,p);
        ELSE
          xpos:=node2.picx;
          ypos:=node2.picy;
        END;
        xleftborder:=xpos-(node2.width DIV 2)-2;
        xrightborder:=xpos+(node2.width DIV 2)+2;
        IF node2.textdir=0 THEN
          wi:=tt.TextLength(s.ADR(node2.label(s1.Label).string),p.rast,node2.weltx,node2.welty,0,node2.nach,node2.exp);
          INC(wi,g.TextLength(p.rast,node2.string,st.Length(node2.string)));
          yhighborder:=ypos-p.rast.txBaseline;
          ylowborder:=ypos+p.rast.txHeight-p.rast.txBaseline;
        ELSIF node2.textdir=1 THEN
          NEW(string);
          COPY(node2.string,string^);
          st.Append(string^,node2.label(s1.Label).string);
          wi:=0;
          str[1]:=0X;
          FOR pos:=0 TO SHORT(st.Length(string^)-1) DO
            str[0]:=string[pos];
            i:=g.TextLength(p.rast,str,1);
            IF i>wi THEN
              wi:=i;
            END;
          END;
          yhighborder:=ypos;
          ylowborder:=ypos+SHORT(st.Length(string^))*p.rast.txHeight;
          DISPOSE(string);
        ELSIF (node2.textdir=2) OR (node2.textdir=3) THEN
          NEW(string);
          COPY(node2.string,string^);
          st.Append(string^,node2.label(s1.Label).string);
          wi:=p.rast.txHeight;
          yhighborder:=ypos;
          ylowborder:=ypos+tt.TextLength(string,p.rast,node2.weltx,node2.welty,0,node2.nach,node2.exp);
          DISPOSE(string);
        END;
        IF node2.textside=1 THEN
          INC(xrightborder,wi);
        ELSIF node2.textside=-1 THEN
          DEC(xleftborder,wi);
        END;
        IF ((x>=xleftborder) AND (x<=xrightborder) AND (y>=yhighborder) AND (y<ylowborder)) OR ((x>=xpos-(node2.width DIV 2)-2) AND (x<=xpos+(node2.width DIV 2)+2) AND (y>=p.iny) AND (y<p.iny+p.height)) THEN
          node:=node2;
        END;
      END;
      node2:=node2.next;
      IF node#NIL THEN
        node2:=NIL;
      END;
    END;
  END;
  xr:=xrightborder;
  xl:=xleftborder;
  yh:=yhighborder;
  yl:=ylowborder;
  RETURN node;
END GetMark;

PROCEDURE SelectMark*(p:l.Node):l.Node;

VAR node,
    node2,
    oldnode : l.Node;
    x,y,
    xpos,
    ypos    : INTEGER;
    class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    xr,xl,
    yh,yl,
    oxr,oxl,
    oyh,oyl : INTEGER;

PROCEDURE DrawRect(node:l.Node;xl,xr,yh,yl:INTEGER);

VAR xpos,ypos,x : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    WITH node: s1.Mark DO
      IF node.welt THEN
        s1.WorldToPic(node.weltx,node.welty,xpos,ypos,p);
      ELSE
        xpos:=node.picx;
        ypos:=node.picy;
      END;
      x:=xpos-(node.width DIV 2)-2;
      g.Move(p.rast,x,p.iny);
      g.Draw(p.rast,x,yh);
      g.Draw(p.rast,xl,yh);
      g.Draw(p.rast,xl,yl);
      g.Draw(p.rast,x,yl);
      g.Draw(p.rast,x,p.iny+p.height);
      x:=xpos+(node.width DIV 2)+2;
      g.Move(p.rast,x,p.iny);
      g.Draw(p.rast,x,yh);
      g.Draw(p.rast,xr,yh);
      g.Draw(p.rast,xr,yl);
      g.Draw(p.rast,x,yl);
      g.Draw(p.rast,x,p.iny+p.height);
    END;
(*    DrawRect(p.rast,xl,yh,xr,yl);*)
  END;
END DrawRect;

(*PROCEDURE DrawOldRect;

VAR xpos,ypos : INTEGER;

BEGIN
  WITH p: s1.Fenster DO
    DrawRect(p.rast,oxl,oyh,oxr,oyl);
  END;
END DrawOldRect;*)

BEGIN
  WITH p: s1.Fenster DO
    g.SetDrMd(p.rast,SHORTSET{g.complement});
    node:=NIL;
    REPEAT
      IF node#NIL THEN
        DrawRect(node,xl,xr,yh,yl);
      END;
      e.WaitPort(p.wind.userPort);
      it.GetMousePos(p.wind,x,y);
      oxl:=xl;
      oxr:=xr;
      oyh:=yh;
      oyl:=yl;
      oldnode:=node;
      node:=GetMark(p,x,y,xl,xr,yh,yl);
      it.GetIMes(p.wind,class,code,address);
      IF I.menuPick IN class THEN
        node:=NIL;
      END;
      IF oldnode#NIL THEN
        DrawRect(oldnode,oxl,oxr,oyh,oyl);
      END;
    UNTIL ((I.mouseButtons IN class) AND (code=I.selectDown)) OR (I.menuPick IN class);
    g.SetDrMd(p.rast,g.jam1);
  END;
  RETURN node;
END SelectMark;

PROCEDURE Integrate*():BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    funcstr1,
    funcstr2,
    selfunc1,
    selfunc2,
    xmingad,
    xmaxgad,
    integtype,
    stepwidth,
    calc,
    areagad,
    areatype,
    varname  : I.GadgetPtr;
    func1,
    func2,node,
    node2,dim,
    area     : l.Node;
    string,
    downstr,
    upstr    : ARRAY 80 OF CHAR;
    integtext: ARRAY 3 OF ARRAY 80 OF CHAR;
    areatext : ARRAY 2 OF ARRAY 80 OF CHAR;
    steptext : ARRAY 4 OF ARRAY 10 OF CHAR;
    integpos,
    areapos,
    steppos  : INTEGER;
    xmin,xmax,
    integral,
    step     : LONGREAL;
    abs,
    createarea,
    ret      : BOOLEAN;
    error    : INTEGER;

PROCEDURE NewDim(area:l.Node):l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(s1.AreaDim));
  node(s1.AreaDim).type:=0;
  COPY(ac.GetString(ac.XAxis)^,node(s1.AreaDim).name);
  node(s1.AreaDim).object:=NIL;
  COPY(ac.GetString(ac.YAxis)^,node(s1.AreaDim).string);
  node(s1.AreaDim).xcoord:=0;
  node(s1.AreaDim).ycoord:=0;
  node(s1.AreaDim).xcoords:="0";
  node(s1.AreaDim).ycoords:="0";
  node(s1.AreaDim).up:=TRUE;
  node(s1.AreaDim).down:=FALSE;
  node(s1.AreaDim).left:=FALSE;
  node(s1.AreaDim).right:=FALSE;
  node(s1.AreaDim).include:=FALSE;
  area(s1.Area).dims.AddTail(node);
  RETURN node;
END NewDim;

PROCEDURE CreateFunc(VAR func:l.Node;string:ARRAY OF CHAR);

BEGIN
  node:=NIL;
  NEW(node(s1.Term));
  COPY(string,node(s1.Term).string);
  node(s1.Term).tree:=NIL;
  node(s1.Term).define:=l.Create();
  node(s1.Term).depend:=l.Create();
  node(s1.Term).changed:=TRUE;
  func:=NIL;
  NEW(func(s1.Function));
  COPY(string,func(s1.Function).name);
  func(s1.Function).terms:=l.Create();
  func(s1.Function).define:=l.Create();
  func(s1.Function).depend:=l.Create();
  func(s1.Function).changed:=TRUE;
  func(s1.Function).isbase:=TRUE;
  node2:=NIL;
  NEW(node2(s1.FuncTerm));
  node2(s1.FuncTerm).term:=node;
  func(s1.Function).terms.AddTail(node2);
  node(s1.Term).basefunc:=func;
END CreateFunc;

BEGIN
  ret:=FALSE;
  IF integId=-1 THEN
    integId:=wm.InitWindow(20,10,264,201,ac.GetString(ac.CalcArea),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,180,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(150,180,100,14,ac.GetString(ac.Cancel));
  funcstr1:=gm.SetStringGadget(26,40,184,14,255);
  funcstr2:=gm.SetStringGadget(26,55,184,14,255);
  xmingad:=gm.SetStringGadget(54,71,64,14,80);
  xmaxgad:=gm.SetStringGadget(162,71,64,14,80);
  selfunc1:=gm.SetBooleanGadget(222,40,16,14,s.ADR("A"));
  selfunc2:=gm.SetBooleanGadget(222,55,16,14,s.ADR("A"));
  COPY(ac.GetString(ac.Absolute)^,integtext[0]);
  COPY(ac.GetString(ac.Oriented)^,integtext[1]);
  COPY(ac.GetString(ac.Rotation)^,integtext[2]);
  integtype:=gm.SetCycleGadget(26,87,128,14,integtext[0]);
  steptext[0]:="0.1";
  steptext[1]:="0.01";
  steptext[2]:="0.001";
  steptext[3]:="0.0001";
  stepwidth:=gm.SetCycleGadget(158,87,80,14,steptext[0]);
  calc:=gm.SetBooleanGadget(26,102,212,14,ac.GetString(ac.Calculate));
  areagad:=gm.SetCheckBoxGadget(212,145,26,9,iarea);
  COPY(ac.GetString(ac.DefaultHatching)^,areatext[0]);
  COPY(ac.GetString(ac.CustomHatching)^,areatext[1]);
  areatype:=gm.SetCycleGadget(26,157,212,14,areatext[0]);
  gm.EndGadgets;
  wm.SetGadgets(integId,ok);
  wm.ChangeScreen(integId,s1.screen);
  wind:=wm.OpenWindow(integId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.SurfaceBetweenFunctions),rast);
    tt.Print(20,140,ac.GetString(ac.HatchSurface),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.Functions),rast);
    tt.Print(26,80,ac.GetString(ac.From),rast);
    tt.Print(134,80,ac.GetString(ac.To),rast);
    tt.Print(26,125,ac.GetString(ac.ResultDP),rast);
    tt.Print(26,153,ac.GetString(ac.HatchSurface),rast);

    it.DrawBorder(rast,14,16,236,161);
    it.DrawBorder(rast,20,28,224,104);
    it.DrawBorder(rast,20,143,224,31);
    it.DrawBorderIn(rast,110,117,128,12);

    WHILE integpos#iintegpos DO
      gm.CyclePressed(integtype,wind,integtext,integpos);
    END;
    WHILE steppos#isteppos DO
      gm.CyclePressed(stepwidth,wind,steptext,steppos);
    END;
    WHILE areapos#iareapos DO
      gm.CyclePressed(areatype,wind,areatext,areapos);
    END;

    func1:=ifunc1;
    func2:=ifunc2;
    createarea:=iarea;
(*    IF createarea THEN
      gm.ActivateBool(areagad,wind);
    END;*)
    gm.PutGadgetText(funcstr1,istring1);
    gm.PutGadgetText(funcstr2,istring2);
    gm.PutGadgetText(xmingad,ixmin);
    gm.PutGadgetText(xmaxgad,ixmax);
    I.RefreshGList(funcstr1,wind,NIL,4);
    bool:=I.ActivateGadget(funcstr1^,wind,NIL);

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ifunc1:=func1;
          ifunc2:=func2;
          gm.GetGadgetText(funcstr1,istring1);
          gm.GetGadgetText(funcstr2,istring2);
          gm.GetGadgetText(xmingad,ixmin);
          gm.GetGadgetText(xmaxgad,ixmax);
          iarea:=createarea;
          iintegpos:=integpos;
          isteppos:=steppos;
          iareapos:=areapos;
          IF createarea THEN
            gm.GetGadgetText(funcstr1,string);
            IF func1=NIL THEN
              CreateFunc(func1,string);
            ELSIF NOT(tt.Compare(func1(s1.Function).name,string)) THEN
              CreateFunc(func1,string);
            END;
            gm.GetGadgetText(funcstr2,string);
            IF func2=NIL THEN
              CreateFunc(func2,string);
            ELSIF NOT(tt.Compare(func2(s1.Function).name,string)) THEN
              CreateFunc(func2,string);
            END;
            gm.GetGadgetText(xmingad,downstr);
            xmin:=f.ExpressionToReal(downstr);
            gm.GetGadgetText(xmaxgad,upstr);
            xmax:=f.ExpressionToReal(upstr);
            IF xmax>=xmin THEN
              node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
              IF node#NIL THEN
                NEW(area(s1.Area));
                area(s1.Area).dims:=l.Create();
                s1.CopyNode(s1.std.area,area);
                IF areapos=1 THEN
                  bool:=s15.ChangeArea(node,area);
                ELSE
                  bool:=TRUE;
                END;
                IF bool THEN
                  node2:=NIL;
                  NEW(node2(s1.Area));
                  node2(s1.Area).dims:=l.Create();
                  s1.CopyNode(area,node2);
                  COPY(ac.GetString(ac.Below)^,node2(s1.Area).name);
                  st.AppendChar(node2(s1.Area).name," ");
                  st.Append(node2(s1.Area).name,func1(s1.Function).name);
                  node(s1.Fenster).areas.AddTail(node2);
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=4;
                    dim.up:=FALSE;
                    dim.down:=TRUE;
                    dim.name:="1. ";
                    st.Append(dim.name,ac.GetString(ac.Function)^);
                    COPY(func1(s1.Function).name,dim.string);
                    dim.object:=func1;
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=4;
                    dim.name:="2. ";
                    st.Append(dim.name,ac.GetString(ac.Function)^);
                    COPY(func2(s1.Function).name,dim.string);
                    dim.object:=func2;
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=2;
                    dim.up:=FALSE;
                    dim.right:=TRUE;
                    COPY(downstr,dim.xcoords);
                    dim.xcoord:=xmin;
                    COPY(ac.GetString(ac.LowerLimit)^,dim.name);
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=2;
                    dim.up:=FALSE;
                    dim.left:=TRUE;
                    COPY(upstr,dim.xcoords);
                    dim.xcoord:=xmax;
                    COPY(ac.GetString(ac.UpperLimit)^,dim.name);
                  END;

                  node2:=NIL;
                  NEW(node2(s1.Area));
                  node2(s1.Area).dims:=l.Create();
                  s1.CopyNode(area,node2);
                  COPY(ac.GetString(ac.Above)^,node2(s1.Area).name);
                  st.AppendChar(node2(s1.Area).name," ");
                  st.Append(node2(s1.Area).name,func1(s1.Function).name);
                  node(s1.Fenster).areas.AddTail(node2);
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=4;
                    dim.name:="1. ";
                    st.Append(dim.name,ac.GetString(ac.Function)^);
                    COPY(func1(s1.Function).name,dim.string);
                    dim.object:=func1;
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=4;
                    dim.up:=FALSE;
                    dim.down:=TRUE;
                    dim.name:="2. ";
                    st.Append(dim.name,ac.GetString(ac.Function)^);
                    COPY(func2(s1.Function).name,dim.string);
                    dim.object:=func2;
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=2;
                    dim.up:=FALSE;
                    dim.right:=TRUE;
                    COPY(downstr,dim.xcoords);
                    dim.xcoord:=xmin;
                    COPY(ac.GetString(ac.LowerLimit)^,dim.name);
                  END;
                  dim:=NewDim(node2);
                  WITH dim: s1.AreaDim DO
                    dim.type:=2;
                    dim.up:=FALSE;
                    dim.left:=TRUE;
                    COPY(upstr,dim.xcoords);
                    dim.xcoord:=xmax;
                    COPY(ac.GetString(ac.UpperLimit)^,dim.name);
                  END;
                  node(s1.Fenster).refresh:=TRUE;
(*                  pt.SetBusyPointer(node(s1.Fenster).wind);
                  pt.SetBusyPointer(wind);
                  s3.PlotArea(node,area);
                  s3.PlotArea(node,node2);
                  pt.ClearPointer(wind);
                  pt.ClearPointer(node(s1.Fenster).wind);*)
                END;
              END;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.TheUpperLimitMustBe),ac.GetString(ac.HigherThanTheLowerLimit),s.ADR(""),ac.GetString(ac.OK),s1.window);
            END;
          END;
          EXIT;
        ELSIF address=ca THEN
          EXIT;
        ELSIF address=calc THEN
          gm.GetGadgetText(xmingad,string);
          xmin:=f.ExpressionToReal(string);
          gm.GetGadgetText(xmaxgad,string);
          xmax:=f.ExpressionToReal(string);
          IF xmax>=xmin THEN
            pt.SetBusyPointer(wind);
(*            IF integpos=0 THEN
              abs:=TRUE;
            ELSE
              abs:=FALSE;
            END;*)
            IF steppos=0 THEN
              step:=0.1;
            ELSIF steppos=1 THEN
              step:=0.01;
            ELSIF steppos=2 THEN
              step:=0.001;
            ELSIF steppos=3 THEN
              step:=0.0001;
            END;
            gm.GetGadgetText(funcstr1,string);
            IF func1=NIL THEN
              CreateFunc(func1,string);
            ELSIF NOT(tt.Compare(func1(s1.Function).name,string)) THEN
              CreateFunc(func1,string);
            END;
            gm.GetGadgetText(funcstr2,string);
            IF func2=NIL THEN
              CreateFunc(func2,string);
            ELSIF NOT(tt.Compare(func2(s1.Function).name,string)) THEN
              CreateFunc(func2,string);
            END;
            error:=0;
            integral:=s4.IntegrateFunc(func1,func2,xmin,xmax,integpos,step,wind,error);
            g.SetAPen(rast,0);
            g.RectFill(rast,112,118,235,127);
            g.SetAPen(rast,1);
            IF error=0 THEN
              IF integral<10000000 THEN
                bool:=lrc.RealToString(integral,string,7,7,FALSE);
              ELSE
                bool:=lrc.RealToString(integral,string,4,4,TRUE);
              END;
              tt.Clear(string);
              tt.Print(114,125,s.ADR(string),rast);
            ELSIF error=1 THEN
              bool:=rt.RequestWin(ac.GetString(ac.ItCannotBeIntegrated),ac.GetString(ac.OverADefinitionGap),s.ADR(""),ac.GetString(ac.OK),s1.window);
            END;
            pt.ClearPointer(wind);
          ELSE
            bool:=rt.RequestWin(ac.GetString(ac.TheUpperLimitMustBe),ac.GetString(ac.HigherThanTheLowerLimit),s.ADR(""),ac.GetString(ac.OK),s1.window);
          END;
        ELSIF address=selfunc1 THEN
          node:=s2.SelectNode(s1.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.FunctionsAreEntered));
          IF node#NIL THEN
            func1:=node;
            gm.PutGadgetText(funcstr1,func1(s1.Function).name);
            bool:=I.ActivateGadget(funcstr1^,wind,NIL);
          END;
        ELSIF address=selfunc2 THEN
          node:=s2.SelectNode(s1.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.FunctionsAreEntered));
          IF node#NIL THEN
            func2:=node;
            gm.PutGadgetText(funcstr2,func2(s1.Function).name);
            bool:=I.ActivateGadget(funcstr2^,wind,NIL);
          END;
        ELSIF address=integtype THEN
          gm.CyclePressed(integtype,wind,integtext,integpos);
        ELSIF address=stepwidth THEN
          gm.CyclePressed(stepwidth,wind,steptext,steppos);
        ELSIF address=areatype THEN
          gm.CyclePressed(areatype,wind,areatext,areapos);
        ELSIF address=areagad THEN
          createarea:=NOT(createarea);
        ELSIF address=funcstr1 THEN
          bool:=I.ActivateGadget(funcstr2^,wind,NIL);
        ELSIF address=funcstr2 THEN
          bool:=I.ActivateGadget(xmingad^,wind,NIL);
        ELSIF address=xmingad THEN
          bool:=I.ActivateGadget(xmaxgad^,wind,NIL);
        ELSIF address=xmaxgad THEN
          bool:=I.ActivateGadget(funcstr1^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"calcarea",wind);
      END;
    END;

    wm.CloseWindow(integId);
  END;
  wm.FreeGadgets(integId);
  RETURN ret;
END Integrate;

PROCEDURE PlotWind*(p:l.Node);

VAR node,node2,newnode,actgraph : l.Node;
    sizechanged,sizebool        : BOOLEAN;
    highest,acthigh             : INTEGER;

PROCEDURE CreateGraphs(VAR list:l.List;node:l.Node);

VAR node2 : l.Node;

BEGIN
  node2:=node(s1.Depend).var;
  WITH node2: f1.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF node.next#NIL THEN
        CreateGraphs(list,node.next);
      ELSE
        IF newnode=NIL THEN
          NEW(newnode(s1.FunctionGraph));
          NEW(newnode(s1.FunctionGraph).table,p(s1.Fenster).stutz);
          newnode(s1.FunctionGraph).bordervals:=l.Create();
          s1.ClearGraph(newnode);
          list.AddTail(newnode);
        END;
        newnode(s1.FunctionGraph).calced:=FALSE;
        newnode:=newnode.next;
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

PROCEDURE PlotGraphs(wind,windfunc:l.Node;node:l.Node):BOOLEAN;

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
        sizebool:=PlotGraphs(wind,windfunc,node.next);
      ELSE
        IF NOT(actgraph(s1.FunctionGraph).calced) THEN
          sizebool:=s3.CalcGraph(wind,windfunc,actgraph);
        ELSE
          sizebool:=s3.PlotGraph(wind,windfunc,actgraph);
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

PROCEDURE RefreshArea(area,p:l.Node);

VAR actdim,node : l.Node;

BEGIN
  WITH area: s1.Area DO
    actdim:=area(s1.Area).dims.head;
    WHILE actdim#NIL DO
      WITH actdim: s1.AreaDim DO
        IF actdim.type=5 THEN
          IF actdim.object#NIL THEN
            node:=actdim.object;
            COPY(node(s1.Point).string,actdim.string);
            IF node(s1.Point).welt THEN
              COPY(node(s1.Point).xkstr,actdim.xcoords);
              COPY(node(s1.Point).ykstr,actdim.ycoords);
              actdim.xcoord:=node(s1.Point).weltx;
              actdim.ycoord:=node(s1.Point).welty;
            ELSE
              s1.PicToWorld(actdim.xcoord,actdim.ycoord,node(s1.Point).picx,node(s1.Point).picy,p);
              bool:=lrc.RealToString(actdim.xcoord,actdim.xcoords,7,7,FALSE);
              bool:=lrc.RealToString(actdim.ycoord,actdim.ycoords,7,7,FALSE);
              tt.Clear(actdim.xcoords);
              tt.Clear(actdim.ycoords);
            END;
          END;
        ELSIF actdim.type=6 THEN
          IF actdim.object#NIL THEN
            node:=actdim.object;
            COPY(actdim.object(s1.Mark).string,actdim.string);
            IF node(s1.Mark).welt THEN
              COPY(node(s1.Point).xkstr,actdim.xcoords);
              COPY(node(s1.Point).ykstr,actdim.ycoords);
              actdim.xcoord:=node(s1.Point).weltx;
              actdim.ycoord:=node(s1.Point).welty;
            ELSE
              s1.PicToWorld(actdim.xcoord,actdim.ycoord,node(s1.Mark).picx,node(s1.Mark).picy,p);
              bool:=lrc.RealToString(actdim.xcoord,actdim.xcoords,7,7,FALSE);
              bool:=lrc.RealToString(actdim.ycoord,actdim.ycoords,7,7,FALSE);
              tt.Clear(actdim.xcoords);
              tt.Clear(actdim.ycoords);
            END;
          END;
        END;
      END;
      actdim:=actdim.next;
    END;
  END;
END RefreshArea;

BEGIN
  p(s1.Fenster).refresh:=FALSE;
  IF p IS s1.Fenster THEN
    WITH p: s1.Fenster DO
(*      IF s1.eon[a] THEN*)
(*        IF s1.einz[a]=NIL THEN
          NEW(s1.einz[a]);
          s1.einz[a].xpos:=100+a*20;
          s1.einz[a].ypos:=20;
          s1.einz[a].width:=320;
          s1.einz[a].height:=150;
          s1.einz[a].xmin:=-10;
          s1.einz[a].xmax:=10;
          s1.einz[a].ymin:=-10;
          s1.einz[a].ymax:=10;
          s1.einz[a].col:=2;
          s1.einz[a].grid1.col:=3;
          s1.einz[a].grid1.xspace:=1;
          s1.einz[a].grid1.yspace:=1;
          s1.einz[a].grid1.on:=TRUE;
          s1.einz[a].grid1.muster:=0;
          s1.einz[a].scale.xspace:=1;
          s1.einz[a].scale.yspace:=1;
          s1.einz[a].scale.col:=1;
          s1.einz[a].scale.muster:=0;
          s1.einz[a].scale.on:=TRUE;
        END;*)
        IF p.wind=NIL THEN
          s4.InitWindow(p);
        END;
        highest:=0;
        s2.SetAllPointers(TRUE);
(*        pt.SetBusyPointer(p.wind);*)
        REPEAT
          p.refresh:=FALSE;
          g.SetRast(p.rast,p.backcol);
          IF p.grid2.on THEN
            s3.PlotGrid(p,s.ADR(p.grid2));
          END;
          IF p.grid1.on THEN
            s3.PlotGrid(p,s.ADR(p.grid1));
          END;
          node:=p.areas.head;
          WHILE node#NIL DO
            RefreshArea(node,p);
            IF node(s1.Area).areab THEN
              s4.PlotArea(p,node);
            END;
            node:=node.next;
          END;
          IF p.scale.on THEN
            s3.PlotScale(p);
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
(*              node(s1.FensterFunc).graphs.Init;*)
              IF node(s1.FensterFunc).func(s1.Function).depend.isEmpty() THEN
                newnode:=node(s1.FensterFunc).graphs.head;
                IF newnode=NIL THEN
                  NEW(newnode(s1.FunctionGraph));
                  NEW(newnode(s1.FunctionGraph).table,p.stutz);
                  newnode(s1.FunctionGraph).bordervals:=l.Create();
                  s1.ClearGraph(newnode);
                  node(s1.FensterFunc).graphs.AddTail(newnode);
                END;
                newnode(s1.FunctionGraph).calced:=FALSE;
                bool:=TRUE;
              ELSE
                newnode:=node(s1.FensterFunc).graphs.head;
                CreateGraphs(node(s1.FensterFunc).graphs,node(s1.FensterFunc).func(s1.Function).depend.head);
                WHILE newnode#NIL DO
                  node2:=newnode.next;
                  DISPOSE(newnode(s1.FunctionGraph).table);
                  newnode.Remove;
                  newnode:=node2;
                END;
                bool:=TRUE;
              END;
            END;
            IF node(s1.FensterFunc).func(s1.Function).depend.isEmpty() THEN
              IF NOT(node(s1.FensterFunc).graphs.head(s1.FunctionGraph).calced) THEN
                sizebool:=s3.CalcGraph(p,node,node(s1.FensterFunc).graphs.head);
              ELSE
                sizebool:=s3.PlotGraph(p,node,node(s1.FensterFunc).graphs.head);
              END;
            ELSE
              actgraph:=node(s1.FensterFunc).graphs.head;
              sizebool:=PlotGraphs(p,node,node(s1.FensterFunc).func(s1.Function).depend.head);
            END;
            IF sizebool THEN
              sizechanged:=TRUE;
            END;
  (*          IF bool THEN
              Auto(p);
              p.refresh:=TRUE;
              PlotWind(p);
            END;*)
  
  (*          node2:=node(s1.FensterFunc).graphs.head;
            WHILE node2#NIL DO
              IF NOT(node2(s1.SubFunction).calced) THEN
                CalcGraph(p,node,node2);
              ELSE
                PlotGraph(p,node,node2);
              END;
              node2:=node2.next;
            END;*)
  (*          WHILE node2#NIL DO
              newnode:=NIL;
              NEW(newnode(s1.SubFunction));
              s1.ClearFunc(newnode);
              IF NOT(node(s1.FensterFunc).calced) THEN
                CalcGraph(p,node);
              ELSE
                PlotGraph(p,node);
              END;
              node2:=node2.next;
            END;*)
            s2.UnLockFunction(node(s1.FensterFunc).func);
            node:=node.next;
            IF sizechanged THEN
              s2.ResizeWindow(p);
              node:=NIL;
            END;
          END;
          node:=p.texts.head;
          WHILE node#NIL DO
            s4.PlotObject(p,node,TRUE);
            node:=node.next;
          END;
          node:=p.marks.head;
          WHILE node#NIL DO
            s4.PlotObject(p,node,TRUE);
            node:=node.next;
          END;
          node:=p.points.head;
          WHILE node#NIL DO
            s4.PlotObject(p,node,TRUE);
            node:=node.next;
          END;
          node:=p.areas.head;
          WHILE node#NIL DO
            IF NOT(node(s1.Area).areab) THEN
              s4.PlotArea(p,node);
            END;
            node:=node.next;
          END;
          IF sizechanged THEN
            s2.SetAllPointers(TRUE);
          END;
        UNTIL NOT(sizechanged);
        s2.SetAllPointers(FALSE);
(*        pt.ClearPointer(p.wind);*)
(*        i:=-1;
        WHILE i<99 DO
          INC(i);
          IF p.points[i]#NIL THEN
            s1.PlotPoint(p,p.points[i],TRUE);
          END;
        END;
        i:=-1;
        WHILE i<9 DO
          INC(i);
          IF p.bereichs[i]#NIL THEN
            s1.PlotBereich(p,p.bereichs[i]);
          END;
        END;*)
        I.RefreshWindowFrame(p.wind);
    (*  ELSE
        IF s1.einz[a]#NIL THEN
          IF s1.einz[a].wind#NIL THEN
            I.ClearMenuStrip(s1.einz[a].wind);
            I.CloseWindow(s1.einz[a].wind);
          END;
          DISPOSE(s1.einz[a]);
        END;
      END;*)
    END;
  END;
(*  ELSIF p IS s1.MishPtr THEN
    WITH p: s1.Mish DO
      IF p.wind=NIL THEN
        InitWindow(p);
      END;
      g.SetRast(p.rast,0);
      IF p.grid1.on THEN
        s1.PlotGrid(p,p.grid1);
      END;
      IF p.grid2.on THEN
        s1.PlotGrid(p,p.grid2);
      END;
      IF p.scale.numson THEN
        s1.PlotScale(p);
      END;
      i:=-1;
      WHILE i<9 DO
        INC(i);
        IF s1.ton[p.num,i] THEN
          p.on[i]:=TRUE;
          IF NOT(p.calced[i]) THEN
            CalcGraph(p,i);
          ELSE
            PlotGraph(p,i);
          END;
        END;
      END;
      i:=-1;
      WHILE i<99 DO
        INC(i);
        IF p.points[i]#NIL THEN
          s1.PlotPoint(p,p.points[i],TRUE);
        END;
      END;
      I.RefreshWindowFrame(p.wind);
    END;
  END;*)
END PlotWind;

PROCEDURE QuickEingabe*;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    term     : I.GadgetPtr;
    bool     : BOOLEAN;
    node,
    node2,
    termnode,
    windnode : l.Node;
    pos,bcount,
    err      : INTEGER;
    sinfo    : I.StringInfoPtr;
    text     : POINTER TO ARRAY OF ARRAY OF CHAR;

BEGIN
  IF quickId=-1 THEN
    quickId:=wm.InitWindow(20,20,428,69,ac.GetString(ac.QuickEnter),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},s1.screen,FALSE);
  END;
  wm.ChangeScreen(quickId,s1.screen);
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,48,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(314,48,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,48,100,14,ac.GetString(ac.Help));
  term:=gm.SetStringGadget(20,28,376,14,255);
  gm.EndGadgets;
  wm.SetGadgets(quickId,ok);
  wind:=wm.OpenWindow(quickId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    it.DrawBorder(rast,14,16,400,29);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.EnterFunction),rast);

    bool:=I.ActivateGadget(term^,wind,NIL);

    NEW(text,4,80);

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF I.gadgetUp IN class THEN
        IF (address=ok) OR (address=term) THEN
          termnode:=NIL;
          NEW(termnode(s1.Term));
          termnode(s1.Term).depend:=l.Create();
          termnode(s1.Term).define:=l.Create();
          termnode(s1.Term).changed:=TRUE;
          gm.GetGadgetText(term,termnode(s1.Term).string);
          f.SyntaxCheck(termnode(s1.Term).string,pos,bcount,err);
          IF err=0 THEN
            s1.terms.AddTail(termnode);
            node2:=NIL;
            NEW(node2(s1.Function));
            node2(s1.Function).terms:=l.Create();
            node2(s1.Function).depend:=l.Create();
            node2(s1.Function).define:=l.Create();
            node2(s1.Function).isbase:=TRUE;
            node:=NIL;
            NEW(node(s1.FuncTerm));
            node(s1.FuncTerm).term:=termnode;
            node2(s1.Function).terms.AddTail(node);
            termnode(s1.Term).basefunc:=node2;
            COPY(termnode(s1.Term).string,node2(s1.Function).name);
            node2(s1.Function).changed:=TRUE;
            s1.functions.AddTail(node2);
            s2.RefreshDepends(node2);
            windnode:=NIL;
            NEW(windnode(s1.Fenster));
            s1.InitNode(windnode);
            s5.InitFenster(windnode);
            COPY(termnode(s1.Term).string,windnode(s1.Fenster).name);
            s1.fenster.AddTail(windnode);
            node:=NIL;
            NEW(node(s1.FensterFunc));
            node(s1.FensterFunc).func:=node2(s1.Function);
            node(s1.FensterFunc).changed:=TRUE;
            windnode(s1.Fenster).funcs.AddTail(node);
            windnode(s1.Fenster).refresh:=TRUE;
            s5.InitFunc(node);
            s1.SendNewObject(windnode);
            EXIT;
          ELSE
            s5.BuildUpFuncErrorReq(node2,err,pos,text^);
            bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
            sinfo:=term.specialInfo;
            sinfo.dispPos:=pos;
            sinfo.bufferPos:=pos;
            I.RefreshGList(term,wind,NIL,1);
            bool:=I.ActivateGadget(term^,wind,NIL);
            termnode:=NIL;
          END;
        ELSIF address=ca THEN
          EXIT;
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"quickenter",wind);
      END;
    END;

    wm.CloseWindow(quickId);
  END;
  wm.FreeGadgets(quickId);
END QuickEingabe;

BEGIN
  integId:=-1;
  quickId:=-1;
  ifunc1:=NIL;
  ifunc2:=NIL;
  istring1:="";
  istring2:="0";
  ixmin:="0";
  ixmax:="1";
  iintegpos:=0;
  isteppos:=1;
  iareapos:=0;
  iarea:=TRUE;
END SuperCalcTools16.

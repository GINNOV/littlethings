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


MODULE SuperCalcTools5;

IMPORT I  : Intuqtqon,
       g  : Graphics,
       d  : Dos,
       }  : Exec,
       s  : SYSTEM,
       f  : õnction0
       f1 : Function1,
       c  : onversqons,
       l  < LinkedLists,
       pt : Pointers,
       gm : GadepManager0
8      wmD* WindowManager,
       it : ntuqtionTools,
       tt : TextTools,
      !òt ;`RequesterTools,
       ag : AmigaGuideTools,
       ac : AnaláyCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
   P   NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- $StackChk- $ReturnChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;


PROCEDURE GetNextValue(VAR r:REAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
(*  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;*)
  END;
END GetNextValue;

PROCEDURE FindLuck(real,add:REAL;func:l.Node):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : f1.NodePtr;

BEGIN
  term:=s2.GetFunctionTerm(func,real);
  IF term#NIL THEN
    root:=term(s1.Term).tree;
    real:=real-add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real+add;
        error:=0;
        wert:=s2.GetFunctionValueShort(func,real,add,error);
(*        wert:=f.Calc(root,real,add,error);*)
        IF error#0 THEN
          EXIT;
        END;
      END;
      IF add>0.00001 THEN
        real:=real-add;
        real:=real-add;
      END;
    UNTIL add<=0.00001;
  END;
  RETURN real;
END FindLuck;

PROCEDURE FindLuckRight(real,add:REAL;func:l.Node):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : f1.NodePtr;

BEGIN
  term:=s2.GetFunctionTerm(func,real);
  IF term#NIL THEN
    root:=term(s1.Term).tree;
    real:=real+add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real-add;
        error:=0;
        wert:=s2.GetFunctionValueShort(func,real,add,error);
(*        wert:=f.Calc(root,real,-add,error);*)
        IF error#0 THEN
          EXIT;
        END;
      END;
      IF add>0.00001 THEN
        real:=real+add;
        real:=real+add;
      END;
    UNTIL add<=0.00001;
  END;
  RETURN real;
END FindLuckRight;

PROCEDURE CheckChanged(p:l.Node;checksize:BOOLEAN):BOOLEAN;

VAR changed : BOOLEAN;

BEGIN
  changed:=FALSE;
  class:=e.SetSignal(LONGSET{},LONGSET{});
  IF s1.changesig IN class THEN
    IF p(s1.Fenster).refresh THEN
      changed:=TRUE;
    END;
  END;
  IF checksize THEN
    REPEAT
      it.GetIMes(p(s1.Fenster).wind,class,code,address);
      IF I.newSize IN class THEN
        changed:=TRUE;
      END;
    UNTIL class=LONGSET{};
  END;
  RETURN changed;
END CheckChanged;

PROCEDURE RawPlotGraph*(rast:g.RastPortPtr;p,func,funcg:l.Node;xpos,ypos,width,height,linex,liney:INTEGER;calc,checksize:BOOLEAN):BOOLEAN;

VAR (*rast       : g.RastPortPtr;*)
    root       : f1.NodePtr;
    pos,
    len,i      : INTEGER;
    x,y,addx,
    x2,y2,savex,
    lastx,lasty: REAL;
    real,real2 : REAL;
    error,
    updown,
    lasterror,
    lefterror,
    righterror : INTEGER;
    picx,picy  : INTEGER;
    left,right : REAL;
    notdraw,
    movenext,
    move,
    isup,isdown,
    nextisup,
    nextisdown : BOOLEAN;
    distx,disty,
    factx,facty,
    wx,wy      : REAL;
    fatline    : BOOLEAN;
    term,
    actbord    : l.Node;
    changed,
    doborder,
    doright,
    nextnotcalc: BOOLEAN;

PROCEDURE WorldToPic(wx,wy:REAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : REAL;
    factx,facty : REAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    wx:=factx*width;
    wy:=facty*height;
    IF wx>=0 THEN
      px:=SHORT(SHORT(wx+0.5));
    ELSE
      px:=SHORT(SHORT(wx-0.5));
    END;
    IF wy>32000 THEN
      py:=32000;
    ELSIF wy<-32000 THEN
      py:=-32000;
    ELSE
      IF wy>=0 THEN
        py:=SHORT(SHORT(wy+0.5));
      ELSE
        py:=SHORT(SHORT(wy-0.5));
      END;
    END;
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

BEGIN
(*  rast:=wind.rPort;*)
  changed:=FALSE;
  WITH p: s1.Fenster DO
    WITH funcg: s1.FunctionGraph DO
      WITH func: s1.Function DO
(*        g.SetAPen(rast,funcg.col);*)
        gt.SetLinePattern(rast,s1.lines[funcg.line]);
        IF (linex>1) OR (liney>1) OR (s1.lines[funcg.line](gt.Line).width<16) THEN
          fatline:=TRUE;
(*          s1.width:=funcg.width;
          s1.line:=funcg.line;*)
          gt.SetLineAttrs(rast,linex,liney,s1.lines[funcg.line]);
        ELSE
          fatline:=FALSE;
        END;

        IF calc THEN
          s2.CreateAllTrees(func);
(*          pos:=0;
          root:=f.Parse(term.string,pos);*)
          IF funcg.table#NIL THEN
            DISPOSE(funcg.table);
          END;
          funcg.table:=NIL;
          NEW(funcg.table,p.stutz);
          funcg.bordervals.Init;
        END;

        distx:=p.xmax-p.xmin;
        disty:=p.ymax-p.ymin;

        movenext:=FALSE;
        addx:=distx/(p.stutz-1);
        x:=p.xmin-addx;
        actbord:=funcg.bordervals.head;
        WHILE (actbord#NIL) AND (actbord(s1.BorderVal).x<x) DO
          actbord:=actbord.next;
        END;
        doborder:=FALSE;
        isup:=FALSE;
        isdown:=FALSE;
        nextnotcalc:=FALSE;
        i:=-1;
        WHILE i<p.stutz-1 DO
          INC(i);
          IF (actbord#NIL) AND (x<=actbord(s1.BorderVal).x) AND (actbord(s1.BorderVal).x<x+addx) THEN
            savex:=x;
            x:=actbord(s1.BorderVal).x;
            doborder:=TRUE;
            DEC(i);
          ELSE
            x:=x+addx;
          END;
          IF (calc) AND NOT(doborder) AND NOT(nextnotcalc) THEN
            funcg.table[i].real:=s2.GetFunctionValueShort(func,x,addx,funcg.table[i].error);
            IF (i>0) AND (funcg.table[i].error=0) AND (funcg.table[i-1].error=3) THEN
              funcg.table[i].real:=s2.GetFunctionValueShort(func,x,0,error);
              x2:=FindLuckRight(x,addx,func);
              actbord:=NIL;
              NEW(actbord(s1.BorderVal));
              actbord(s1.BorderVal).x:=x2;
              actbord(s1.BorderVal).left:=s2.GetFunctionValueShort(func,x2-0.00001,0,lefterror);
              actbord(s1.BorderVal).right:=s2.GetFunctionValueShort(func,x2+0.00001,0,righterror);
              funcg.bordervals.AddTail(actbord);
              x:=x-addx;
              DEC(i);
              nextnotcalc:=TRUE;
(*              savex:=x;
              x:=actbord(s1.BorderVal).x;
              doborder:=TRUE;*)
            ELSIF ((funcg.table[i].error>0) AND (funcg.table[i].error#3)) OR ((i>0) AND (funcg.table[i].error=3) AND (funcg.table[i-1].error=0)) THEN
              funcg.table[i].real:=s2.GetFunctionValueShort(func,x,0,error);
              IF funcg.table[i].error=3 THEN
                x2:=x-addx;
              ELSE
                x2:=x;
              END;
              x2:=FindLuck(x2,addx,func);
              actbord:=NIL;
              NEW(actbord(s1.BorderVal));
              actbord(s1.BorderVal).x:=x2;
              actbord(s1.BorderVal).left:=s2.GetFunctionValueShort(func,x2-0.00001,0,lefterror);
              actbord(s1.BorderVal).right:=s2.GetFunctionValueShort(func,x2+0.00001,0,righterror);
              funcg.bordervals.AddTail(actbord);
              IF funcg.table[i].error=3 THEN
                x:=x-addx;
                DEC(i);
                nextnotcalc:=TRUE;
              END;
(*              savex:=x;
              x:=actbord(s1.BorderVal).x;
              doborder:=TRUE;*)
            END;
          ELSIF (nextnotcalc) AND NOT(doborder) THEN
            nextnotcalc:=FALSE;
          END;

          IF (funcg.table[i].error=0) OR (funcg.table[i].error=2) OR (doborder) THEN
            doright:=FALSE;
            LOOP
              IF doborder THEN
                IF NOT(doright) THEN
                  y:=actbord(s1.BorderVal).left;
                ELSE
                  y:=actbord(s1.BorderVal).right;
                END;
              ELSE
                y:=funcg.table[i].real;
              END;
              IF (isup) OR (isdown) OR ((doborder) AND (doright)) THEN
                move:=TRUE;
              ELSE
                move:=FALSE;
              END;
              IF y<p.ymin THEN
                IF NOT(isdown) THEN
                  isdown:=TRUE;
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-p.ymin))-p.xmin;
                    wy:=0;
                  ELSE
                    wx:=x+addx-p.ymin;
                    wy:=0;
                  END;
                END;
                isup:=FALSE;
              ELSIF y>p.ymax THEN
                IF NOT(isup) THEN
                  isup:=TRUE;
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-p.ymax))-p.xmin;
                    wy:=p.ymax-p.ymin;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=p.ymax-p.ymin;
                  END;
                END;
                isdown:=FALSE;
              ELSE
                IF isdown THEN
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)/(lasty-y)*(lasty-p.ymin)-p.xmin;
                    wy:=0;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=0;
                  END;
                ELSIF isup THEN
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)/(lasty-y)*(lasty-p.ymax)-p.xmin;
                    wy:=p.ymax-p.ymin;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=p.ymax-p.ymin;
                  END;
                ELSE
                  wx:=x-p.xmin;
                  wy:=y-p.ymin;
                END;
                isdown:=FALSE;
                isup:=FALSE;
              END;
              IF i=0 THEN
                move:=TRUE;
              ELSIF (lasterror#0) AND NOT((lasterror=2) AND (doborder)) THEN
                move:=TRUE;
              END;
              factx:=wx/distx;
              facty:=wy/disty;
              wx:=factx*width;
              wy:=facty*height;
              IF wx>=0 THEN
                picx:=SHORT(SHORT(wx+0.5));
              ELSE
                picx:=SHORT(SHORT(wx-0.5));
              END;
              IF wy>32000 THEN
                picy:=32000;
              ELSIF wy<-32000 THEN
                picy:=-32000;
              ELSE
                IF wy>=0 THEN
                  picy:=SHORT(SHORT(wy+0.5));
                ELSE
                  picy:=SHORT(SHORT(wy-0.5));
                END;
              END;
              picy:=height-picy;
              INC(picx,xpos);
              INC(picy,ypos);
  
              IF move THEN
                IF fatline THEN
                  gt.Move(rast,picx,picy);
                ELSE
                  g.Move(rast,picx,picy);
                END;
              ELSE
                IF fatline THEN
                  gt.Draw(rast,picx,picy);
                ELSE
                  g.Draw(rast,picx,picy);
                END;
              END;
              lastx:=x;
              lasty:=y;

              IF NOT(doborder) OR (doright) THEN
                EXIT;
              END;
              doright:=TRUE;
            END;

            lasterror:=funcg.table[i].error;
            IF doborder THEN
              x:=savex;
              actbord:=actbord.next;
              doborder:=FALSE;
              lasterror:=0;
            END;
  
            IF i MOD 10=0 THEN
              changed:=CheckChanged(p,checksize);
              IF changed THEN
                i:=p.stutz;
              END;
            END;
          ELSE
            lasterror:=funcg.table[i].error;
          END;

(*          x:=x+addx;
          IF calc THEN
            funcg.table[i].real:=s2.GetFunctionValueShort(func,x,addx,funcg.table[i].error);
(*            func.table[i].real:=f.Rechen(root,x,x+addx,func.table[i].error);*)
            IF funcg.table[i].error#0 THEN
              error:=funcg.table[i].error;
(*              func.table[i].updown:=0;*)
              IF error#3 THEN
                x2:=FindLuck(x,addx,func);
                left:=s2.GetFunctionValueShort(func,x2-0.00001,0,pos);
                right:=s2.GetFunctionValueShort(func,x2+0.00001,0,pos);
                IF left>=p.ymax THEN
                  IF error=1 THEN
                    IF i>0 THEN
                      funcg.table[i-1].updown:=1;
                    END;
                  ELSIF error=2 THEN
                    funcg.table[i].updown:=1;
                  END;
                ELSIF left<=p.ymin THEN
                  IF error=1 THEN
                    IF i>0 THEN
                      funcg.table[i-1].updown:=-1;
                    END;
                  ELSIF error=2 THEN
                    funcg.table[i].updown:=-1;
                  END;
                END;
                IF right>=p.ymax THEN
                  IF i<p.stutz-1 THEN
                    funcg.table[i+1].updown:=1;
                  END;
                ELSIF right<=p.ymin THEN
                  IF i<p.stutz-1 THEN
                    funcg.table[i+1].updown:=-1;
                  END;
                END;
              END;
            END;
          END;

          wx:=x-p.xmin;
          wy:=funcg.table[i].real-p.ymin;
          factx:=wx/distx;
          facty:=wy/disty;
          wx:=factx*width;
          wy:=facty*height;
          IF wx>=0 THEN
            picx:=SHORT(SHORT(wx+0.5));
          ELSE
            picx:=SHORT(SHORT(wx-0.5));
          END;
          IF wy>32000 THEN
            picy:=32000;
          ELSIF wy<-32000 THEN
            picy:=-32000;
          ELSE
            IF wy>=0 THEN
              picy:=SHORT(SHORT(wy+0.5));
            ELSE
              picy:=SHORT(SHORT(wy-0.5));
            END;
          END;
          picy:=height-picy;
          INC(picx,xpos);
          INC(picy,ypos);
          move:=FALSE;
          IF funcg.table[i].real>p.ymax THEN
            IF isup THEN
              move:=TRUE;
              WorldToPic(x+addx,p.ymax,picx,picy,p);
            ELSE
              move:=FALSE;
              isup:=TRUE;
              WorldToPic(x-addx,p.ymax,picx,picy,p);
            END;
          ELSIF funcg.table[i].real<p.ymin THEN
            IF isdown THEN
              move:=TRUE;
              WorldToPic(x+addx,p.ymin,picx,picy,p);
            ELSE
              move:=FALSE;
              isdown:=TRUE;
              WorldToPic(x-addx,p.ymin,picx,picy,p);
            END;
          ELSIF funcg.table[i].updown=0 THEN
            isup:=FALSE;
            isdown:=FALSE;
          END;
          IF funcg.table[i].updown=1 THEN
            IF isup THEN
              move:=TRUE;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymax,picx,picy,p);
              ELSE
                WorldToPic(x+addx,p.ymax,picx,picy,p);
              END;
            ELSE
              move:=FALSE;
              isup:=TRUE;
              pos:=1;
              IF i=p.stutz-1 THEN
                pos:=0;
              END;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymax,picx,picy,p);
              ELSE
                move:=TRUE;
                WorldToPic(x+addx,p.ymax,picx,picy,p);
              END;
            END;
          ELSIF funcg.table[i].updown=-1 THEN
            IF isdown THEN
              move:=TRUE;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymin,picx,picy,p);
              ELSE
                WorldToPic(x+addx,p.ymin,picx,picy,p);
              END;
            ELSE
              move:=FALSE;
              isdown:=TRUE;
              pos:=1;
              IF i=p.stutz-1 THEN
                pos:=0;
              END;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymin,picx,picy,p);
              ELSE
                move:=TRUE;
                WorldToPic(x+addx,p.ymin,picx,picy,p);
              END;
            END;
          END;
          IF (funcg.table[i].error=1) OR (funcg.table[i].error=3) THEN
            move:=TRUE;
          END;
          IF i=0 THEN
            move:=TRUE;
          ELSIF funcg.table[i-1].error#0 THEN
            move:=TRUE;
          END;
          IF move THEN
            IF fatline THEN
              gt.Move(rast,picx,picy);
            ELSE
              g.Move(rast,picx,picy);
            END;
          ELSE
            IF fatline THEN
              gt.Draw(rast,picx,picy);
            ELSE
              g.Draw(rast,picx,picy);
            END;
          END;

          IF i MOD 10=0 THEN
            changed:=CheckChanged(p,checksize);
            IF changed THEN
              i:=p.stutz;
            END;
          END;*)
        END;
        IF (calc) AND NOT(changed) THEN
          funcg.calced:=TRUE;
        END;
        gt.SetFullPattern(rast);
        gt.FreeRastPortNode(rast);
      END;
    END;
  END;
  RETURN changed;
END RawPlotGraph;

PROCEDURE PlotGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,FALSE,TRUE);
END PlotGraph;

PROCEDURE CalcGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,TRUE,TRUE);
END CalcGraph;

PROCEDURE RawPlotGrid*(rast:g.RastPortPtr;p:s1.FensterPtr;pg:s1.GitterPtr;xpos,ypos,width,height,linex,liney:INTEGER);

VAR r     : LONGREAL;
    px,py,
    ux,uy : INTEGER;
    pos   : INTEGER;
(*    rast  : g.RastPortPtr;*)

PROCEDURE WorldToPic(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    px:=SHORT(SHORT(SHORT(factx*width+0.5)));
    py:=SHORT(SHORT(SHORT(facty*height+0.5)));
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

BEGIN
(*  rast:=wind.rPort;*)
  IF p.mode=0 THEN
(*    g.SetAPen(rast,pg.col);*)
    gt.SetLinePattern(rast,s1.lines[pg.muster]);
    g.SetDrMd(rast,g.jam1);
    r:=pg.xstart;
    IF r<p.xmin THEN
      r:=pg.xstart+SHORT(SHORT((p.xmin-pg.xstart)/pg.xspace))*pg.xspace;
    END;
    r:=r-pg.xspace;
    pos:=0;
    WHILE r<=p.xmax-pg.xspace DO
      r:=r+pg.xspace;
      IF r>=p.xmin THEN
        WorldToPic(r,0,px,py,p);
        IF linex=1 THEN
          g.Move(rast,px,ypos);
          g.Draw(rast,px,height+ypos);
        ELSE
          gt.DrawLine(rast,px,ypos,px,height+ypos,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.xstart;
    IF r>p.xmax THEN
      r:=pg.xstart-SHORT(SHORT((pg.xstart-p.xmax)/pg.xspace))*pg.xspace;
    END;
    r:=r+pg.xspace;
    pos:=0;
    WHILE r>=p.xmin+pg.xspace DO
      r:=r-pg.xspace;
      IF r<=p.xmax THEN
        WorldToPic(r,0,px,py,p);
        IF linex=1 THEN
          g.Move(rast,px,ypos);
          g.Draw(rast,px,height+ypos);
        ELSE
          gt.DrawLine(rast,px,ypos,px,height+ypos,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.ystart;
    IF r<p.ymin THEN
      r:=pg.ystart+SHORT(SHORT((p.ymin-pg.ystart)/pg.yspace))*pg.yspace;
    END;
    r:=r-pg.yspace;
    pos:=0;
    WHILE r<=p.ymax-pg.yspace DO
      r:=r+pg.yspace;
      IF r>=p.ymin THEN
        WorldToPic(0,r,px,py,p);
        IF liney=1 THEN
          g.Move(rast,xpos,py);
          g.Draw(rast,width+xpos,py);
        ELSE
          gt.DrawLine(rast,xpos,py,width+xpos,py,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,0,py,p.width,py,linie[pg.muster],pos);*)
    END;
    r:=pg.ystart;
    IF r>p.ymax THEN
      r:=pg.ystart-SHORT(SHORT((pg.ystart-p.ymax)/pg.yspace))*pg.yspace;
    END;
    r:=r+pg.yspace;
    pos:=0;
    WHILE r>=p.ymin+pg.yspace DO
      r:=r-pg.yspace;
      IF r<=p.ymax THEN
        WorldToPic(0,r,px,py,p);
        IF liney=1 THEN
          g.Move(rast,xpos,py);
          g.Draw(rast,width+xpos,py);
        ELSE
          gt.DrawLine(rast,xpos,py,width+xpos,py,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,0,py,p.width,py,linie[pg.muster],pos);*)
    END;
    gt.SetFullPattern(rast);
(*  ELSIF p.mode=1 THEN
    g.SetAPen(rast,pg.col);
    gt.SetLinePattern(rast,s1.lines[pg.muster]);
    r:=pg.ystart;
    r:=r-pg.yspace;
    pos:=0;
    s1.PolarToPic(0,0,ux,uy,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
    WHILE r<=p.ymax-pg.yspace DO
      r:=r+pg.yspace;
      s1.PolarToPic(0,SHORT(r),px,pos,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
      s1.PolarToPic(1.5*f1.PI,SHORT(r),pos,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
      px:=px-(width DIV 2);
      py:=py-(height DIV 2);
      g.DrawEllipse(rast,ux+xpos,uy+ypos,px,py);
(*      g.Move(p.rast,px+p.inx,p.iny);
      g.Draw(rast,px+p.inx,p.height+p.iny);*)
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.xstart;
    r:=r-pg.xspace;
    pos:=0;
    WHILE r<=p.xmax-pg.xspace DO
      r:=r+pg.xspace;
      s1.PolarToPic(SHORT(r),p.ymax,px,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
(*      px:=px-(p.width DIV 2);
      py:=py-(p.height DIV 2);*)
(*      g.DrawEllipse(p.rast,(p.width DIV 2)+p.inx,(p.height DIV 2)+p.iny,px,py);*)
      g.Move(rast,ux+xpos,uy+ypos);
      g.Draw(rast,px+xpos,py+ypos);
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;*)
    gt.FreeRastPortNode(rast);
  END;
END RawPlotGrid;

PROCEDURE GetValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step+step;
END GetValueAfter;

PROCEDURE GetValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step-step;
END GetValueBefore;

PROCEDURE GetNextValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step+step;
  ELSE
    RETURN x;
  END;
END GetNextValueAfter;

PROCEDURE GetNextValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step-step;
  ELSE
    RETURN x;
  END;
END GetNextValueBefore;

PROCEDURE RawPlotScale*(rast:g.RastPortPtr;p:s1.FensterPtr;xpos,ypos,width,height,linex,liney,stdpicx,stdpicy:INTEGER);

VAR r     : LONGREAL;
    px,py,
    gx,gy,
    x,y   : INTEGER;
    str   : ARRAY 80 OF CHAR;
    v,n,j : LONGINT;
    pos   : INTEGER;
    ux,uy,
    stopx,
    stopy : LONGREAL;
(*    rast  : g.RastPortPtr;*)

PROCEDURE WorldToPic(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    px:=SHORT(SHORT(SHORT(factx*width+0.5)));
    py:=SHORT(SHORT(SHORT(facty*height+0.5)));
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

PROCEDURE SetUrsprung;

BEGIN
  ux:=0;
  uy:=0;
  IF p.xmin>=0 THEN
    ux:=GetValueAfter(p.xmin,p.scale.numsx);
  END;
  IF p.ymin>=0 THEN
    uy:=GetValueAfter(p.ymin,p.scale.numsy);
  END;
  IF p.xmax<=0 THEN
    ux:=GetValueBefore(p.xmax,p.scale.numsx);
  END;
  IF p.ymax<=0 THEN
    uy:=GetValueBefore(p.ymax,p.scale.numsy);
  END;
END SetUrsprung;

PROCEDURE DrawLine(rast:g.RastPortPtr;x1,y1,x2,y2,width:INTEGER);

VAR x : INTEGER;

BEGIN
  IF width<1 THEN
    width:=1;
  END;
  IF width MOD 2=0 THEN
    INC(width);
  END;
  IF x1-x2=0 THEN
    x:=x1-(width DIV 2)-1;
    WHILE x<x1+width DIV 2 DO
      INC(x);
      g.Move(rast,x,y1);
      g.Draw(rast,x,y2);
    END;
  ELSE
    x:=y1-(width DIV 2)-1;
    WHILE x<y1+width DIV 2 DO
      INC(x);
      g.Move(rast,x1,x);
      g.Draw(rast,x2,x);
    END;
  END;
END DrawLine;

BEGIN
(*  rast:=wind.rPort;*)
  IF p.mode=0 THEN
    IF p.scale.on THEN
      IF stdpicx MOD 2=0 THEN
        INC(stdpicx);
      END;
      IF stdpicy MOD 2=0 THEN
        INC(stdpicy);
      END;
      SetUrsprung;
      WorldToPic(ux,uy,gx,gy,p);
      IF uy>0 THEN
        WHILE gy+rast.txHeight>height+ypos DO
          uy:=GetValueAfter(uy,p.scale.numsy);
          WorldToPic(ux,uy,gx,gy,p);
        END;
      ELSIF uy<0 THEN
        WHILE gy-rast.txBaseline<ypos DO
          uy:=GetValueBefore(uy,p.scale.numsy);
          WorldToPic(ux,uy,gx,gy,p);
        END;
      END;
      px:=0;
      IF p.scale.numson THEN
        r:=p.xmin-p.scale.numsx;
        WHILE r<p.xmax DO
          r:=r+p.scale.numsx;
          bool:=lrc.RealToString(r,str,7,4,FALSE);
          tt.Clear(str);
          x:=g.TextLength(rast,str,st.Length(str));
          IF x>px THEN
            px:=x;
          END;
        END;
      END;
      IF p.scale.xbezon THEN
        x:=g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname));
        IF x>px THEN
          px:=x;
        END;
      END;
      WHILE gx-px<=4 DO
        ux:=GetValueAfter(ux,p.scale.numsx);
        WorldToPic(ux,uy,gx,gy,p);
      END;
      g.SetDrMd(rast,g.jam1);
      gt.SetLinePattern(rast,s1.lines[p.scale.muster]);
(*      g.SetAPen(rast,p.scale.col);*)
      IF liney=1 THEN
        g.Move(rast,xpos,gy);
        g.Draw(rast,width+xpos,gy);
      ELSE
        pos:=0;
        gt.DrawLine(rast,xpos,gy,width+xpos-SHORT(SHORT(stdpicx*liney/10)),gy,linex,liney,s1.lines[p.scale.muster],pos);
      END;
      vt.DrawVectorObject(rast,s1.arrows[p.scale.arrow],width+xpos,gy,stdpicx,stdpicy,0,1,1);
(*      s1.DrawArrow(rast,width+xpos,gy,p.scale.arrow,1,p.scale.col);*)
(*      g.Draw(p.rast,p.width-4+p.inx,gy-4+ypos);
      g.Move(rast,p.width+p.inx,gy+p.iny);
      g.Draw(rast,p.width-4+p.inx,gy+4+p.iny);*)
      IF p.scale.xbezon THEN
        tt.Print(width-g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname))-2+xpos,gy+SHORT(SHORT(SHORT((s1.arrows[p.scale.arrow](vt.VectorObject).maxheight*stdpicy)/2+0.5)))+SHORT(SHORT(rast.txHeight*1/20+0.5))+1+rast.txBaseline,s.ADR(p.scale.xname),rast);
      END;
      IF linex=1 THEN
        g.Move(rast,gx,height+ypos);
        g.Draw(rast,gx,ypos);
      ELSE
        pos:=0;
        gt.DrawLine(rast,gx,height+ypos,gx,ypos+SHORT(SHORT(stdpicy*linex/10)),linex,liney,s1.lines[p.scale.muster],pos);
      END;
      vt.DrawVectorObject(rast,s1.arrows[p.scale.arrow],gx,ypos,stdpicx,stdpicy,90,1,1);
(*      s1.DrawArrow(rast,gx,ypos,p.scale.arrow,0,p.scale.col);*)
(*      g.Draw(rast,gx-4+xpos,4+ypos);
      g.Move(rast,gx+xpos,ypos);
      g.Draw(rast,gx+4+xpos,4+ypos);*)
      IF p.scale.ybezon THEN
        tt.Print(gx-g.TextLength(rast,p.scale.yname,st.Length(p.scale.yname))-SHORT(SHORT(SHORT((s1.arrows[p.scale.arrow](vt.VectorObject).maxheight*stdpicx)/2+0.5))),SHORT(SHORT(rast.txHeight*1.2+0.5))+ypos,s.ADR(p.scale.yname),rast);
      END;
  (*    s2.DrawLine(rast,0,gy,p.width,gy,linie[p.scale.muster],pos);
      s2.DrawLine(rast,gx,0,gx,p.height,linie[p.scale.muster],pos);*)
      gt.SetFullPattern(rast);
  
      IF p.scale.numson THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.numsx;
        WHILE r<=p.xmax-p.scale.numsx DO
          r:=r+p.scale.numsx;
          WorldToPic(r,uy,px,py,p);
          v:=1;
          j:=10;
          WHILE j<100000 DO
            IF r>=j THEN
              v:=v+1;
            END;
            j:=j*10;
          END;
          IF SHORT(SHORT(r))=r THEN
            n:=0;
          ELSE
            n:=2;
          END;
          bool:=lrc.RealToString(r,str,SHORT(v),SHORT(n),FALSE);
          tt.Clear(str);
(*          IF NOT((r>p.xmax-p.scale.numsx) AND p.scale.xbezon) THEN*)
          IF ((px+(g.TextLength(rast,str,st.Length(str)) DIV 2)<width+xpos-g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname))-8) AND (p.scale.xbezon)) OR NOT(p.scale.xbezon) THEN
            tt.PrintMid(px,gy+2*liney+rast.txBaseline+1+SHORT(SHORT(rast.txHeight*1/20+0.5)),r,rast);
            DrawLine(rast,px,gy-2*liney,px,gy+2*liney,SHORT(SHORT(linex/2+0.5)));
(*            y:=linex DIV 2;
            x:=-y-1;
            WHILE x<y DO
              INC(x);
              g.Move(rast,px+x,gy-2*liney);
              g.Draw(rast,px+x,gy+2*liney);
            END;*)
            stopx:=r;
          END;
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.numsx;
        WHILE r>=p.xmin+p.scale.numsx DO
          r:=r-p.scale.numsx;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-2*liney,px,gy+2*liney,SHORT(SHORT(linex/2+0.5)));
(*          y:=linex DIV 2;
          x:=-y-1;
          WHILE x<y DO
            INC(x);
            g.Move(rast,px+x,gy-2*liney);
            g.Draw(rast,px+x,gy+2*liney);
          END;*)
          tt.PrintMid(px,gy+2*liney+rast.txBaseline+1+SHORT(SHORT(rast.txHeight*1/20+0.5)),r,rast);
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE r<=p.ymax-p.scale.numsy DO
          r:=r+p.scale.numsy;
          WorldToPic(ux,r,px,py,p);
(*          IF NOT((r>p.ymax-p.scale.numsy) AND p.scale.ybezon) THEN*)
          IF (NOT(py<ypos+14) AND (p.scale.ybezon)) OR NOT(p.scale.ybezon) THEN
            tt.PrintRight(gx-2*linex-1,py+(rast.txBaseline DIV 2),r,rast);
            DrawLine(rast,gx-2*linex,py,gx+2*linex,py,SHORT(SHORT(liney/2+0.5)));
(*            y:=liney DIV 2;
            x:=-y-1;
            WHILE x<y DO
              INC(x);
              g.Move(rast,gx-2*linex,py+x);
              g.Draw(rast,gx+2*linex,py+x);
            END;*)
            stopy:=r;
          END;
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.numsy DO
          r:=r-p.scale.numsy;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-2*linex,py,gx+2*linex,py,SHORT(SHORT(liney/2+0.5)));
(*          y:=liney DIV 2;
          x:=-y-1;
          WHILE x<y DO
            INC(x);
            g.Move(rast,gx-2*linex,py+x);
            g.Draw(rast,gx+2*linex,py+x);
          END;*)
          tt.PrintRight(gx-2*linex-1,py+(rast.txBaseline DIV 2),r,rast);
        END;
      END;
      IF p.scale.mark1on THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.mark1x;
        WHILE (r<=p.xmax-p.scale.mark1x) AND (r<=stopx) DO
          r:=r+p.scale.mark1x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-liney,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy-liney);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.mark1x;
        WHILE r>=p.xmin+p.scale.mark1x DO
          r:=r-p.scale.mark1x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-liney,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy-liney);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE (r<=p.ymax-p.scale.mark1y) AND (r<=stopy) DO
          r:=r+p.scale.mark1y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx+linex,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx+linex,py);*)
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.mark1y DO
          r:=r-p.scale.mark1y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx+linex,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx+linex,py);*)
        END;
      END;
      IF p.scale.mark2on THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.mark2x;
        WHILE (r<=p.xmax-p.scale.mark2x) AND (r<=stopx) DO
          r:=r+p.scale.mark2x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.mark2x;
        WHILE r>=p.xmin+p.scale.mark2x DO
          r:=r-p.scale.mark2x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE (r<=p.ymax-p.scale.mark2y) AND (r<=stopy) DO
          r:=r+p.scale.mark2y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx,py);*)
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.mark2y DO
          r:=r-p.scale.mark2y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx,py);*)
        END;
      END;
      gt.FreeRastPortNode(rast);
    END;
  END;
END RawPlotScale;

PROCEDURE PlotGrid*(p:s1.FensterPtr;grid:s1.GitterPtr);

BEGIN
  g.SetAPen(p.wind.rPort,grid.col);
  RawPlotGrid(p.wind.rPort,p,grid,p.inx,p.iny,p.width,p.height,grid.width,grid.width);
END PlotGrid;

PROCEDURE PlotScale*(p:s1.FensterPtr);

VAR font  : g.TextFontPtr;
    mask,
    style : SHORTSET;

BEGIN
  font:=gt.SetFont(p.wind.rPort,s.ADR(p.scale.attr));
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,p.scale.attr.style,mask);
  g.SetAPen(p.wind.rPort,p.scale.col);
  RawPlotScale(p.wind.rPort,p,p.inx,p.iny,p.width,p.height,p.scale.width,p.scale.width,s1.stdpicx,s1.stdpicy);
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,SHORTSET{},mask);
  gt.CloseFont(font);
END PlotScale;

PROCEDURE CreateAreaPattern*(VAR areapat:s1.AreaPattern);

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
END CreateAreaPattern;

PROCEDURE InitVars*;

VAR node : l.Node;

BEGIN
(*  NEW(node(s1.RawString));
  node(s1.RawString).string:="$x,$y";
  s1.form.AddTail(node);
  NEW(node(s1.RawString));
  node(s1.RawString).string:="($x|$y)";
  s1.form.AddTail(node);
  NEW(node(s1.RawString));
  node(s1.RawString).string:="x=$x y=$y";
  s1.form.AddTail(node);*)

  NEW(node(s1.Label));
  node(s1.Label).string:="$x,$y";
  s1.labels.AddTail(node);
  NEW(node(s1.Label));
  node(s1.Label).string:="($x|$y)";
  s1.labels.AddTail(node);
  NEW(node(s1.Label));
  node(s1.Label).string:="($x,$y)";
  s1.labels.AddTai              pos:=0;
  (*            pos:=0;
              nodef:=f.Parse(pys,pos);
              py:=f.RechenLong(nodef,0,0,pos);*)
              pos:=0;
              nodef:=f.Parse(term(s1.Term).string);
              pos:=0;
              py:=s2.GetFunctionValue(actfunc,px,0,pos);
              IF pos=0 THEN
                nodef2:=f1.CopyTree(nodef);
                f.Simplify(nodef2);
                f.Derive(nodef2,"x");
                f.Simplify(nodef2);
                ReplaceX(nodef2,nodex);
                nodef2.parent:=NIL;
                NEW(nodef2.parent(f1.Sign));
                nodef2.parent.right:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(f1.Sign).sign:="/";
                NEW(nodef2.left(f1.Number));
                nodef2.left.parent:=nodef2;
                nodef2.left(f1.Number).real:=1;
                NEW(nodef2.parent(f1.Sign));
                nodef2.parent.right:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(f1.Sign).sign:="-";
                NEW(nodef2.left(f1.Number));
                nodef2.left.parent:=nodef2;
                nodef2.left(f1.Number).real:=0;
                NEW(nodef2.parent(f1.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(f1.Sign).sign:="*";
                nodef2.right:=NIL;
                NEW(nodef2.right(f1.Sign));
                nodef2.right.parent:=nodef2;
                nodef3:=nodef2.right;
                nodef3(f1.Sign).sign:="-";
                NEW(nodef3.left(f1.TreeObj));
                nodef3.left.parent:=nodef3;
                NEW(nodef3.left(f1.TreeObj).object(f1.XYObject));
                nodef3.left(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                NEW(nodef3.left(f1.TreeObj).object(f1.XYObject).name,2);
                nodef3.left(f1.TreeObj).object(f1.XYObject).name^:="x";
                nodef3.right:=f1.CopyTree(nodex);
                nodef3.right.parent:=nodef3;
                NEW(nodef2.parent(f1.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(f1.Sign).sign:="+";
                nodef2.right:=f1.CopyTree(nodef);
                nodef2.right.parent:=nodef2;
                ReplaceX(nodef2.right,nodex);
                f.Simplify(nodef2);
(*(*                NEW(nodef2(f2.Bracket));
                nodef2(f2.Bracket).root:=nodef;*)
                NEW(nodef2(f1.Sign));
                nodef2(f1.Sign).sign:="/";
                nodef2.right:=nodef;
                nodef.parent:=nodef2;
                NEW(nodef2.left(f1.Number));
                nodef2.left(f1.Number).real:=-1;
                nodef2.left.parent:=nodef2;
                nodef:=nodef2;
                nodef2:=NIL;
                ReplaceX(nodef,px);
                f.Simplify(nodef);
                NEW(nodef2(f1.Sign));
                nodef2(f1.Sign).sign:="*";
                NEW(nodef2.right(f1.TreeObj));
                NEW(nodef2.right(f1.TreeObj).object(f1.XYObject));
                NEW(nodef2.right(f1.TreeObj).object(f1.Object).name,2);
                nodef2.right(f1.TreeObj).object(f1.Object).name^:="x";
                nodef2.right(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                nodef2.right.parent:=nodef2;
                nodef2.left:=nodef;
                NEW(nodef3(f1.Sign));
                nodef3(f1.Sign).sign:="+";
                nodef3.left:=nodef2;
                nodef2.parent:=nodef3;
                NEW(nodef3.right(f1.Number));
                nodef3.right.parent:=nodef3;
(*                NEW(nodef2(f2.Bracket));
                nodef2(f2.Bracket).root:=nodef;
                NEW(nodef2.parent(f2.Sign));
                nodef2.parent(f2.Sign).sign:="*";
                NEW(nodef2.parent.right(f2.Constant));
                nodef2.parent.right(f2.Constant).isX:=TRUE;
                nodef2.parent.right.parent:=nodef2.parent;
                nodef2.parent.left:=nodef2;
                NEW(nodef3(f2.Sign));
                nodef3(f2.Sign).sign:="+";
                nodef3.left:=nodef2.parent;
                nodef2.parent.parent:=nodef3;
                NEW(nodef3.right(f2.Number));
                nodef3.right.parent:=nodef3;*)
                alpha:=f.CalcLong(nodef,px,0,pos);
                IF alpha#0 THEN
  (*                alpha:=mdt.Atan(alpha);*)
                  dy1:=py;
                  dx1:=py/alpha;
                  dx2:=px-dx1;
                  dy2:=-alpha*dx2;
                  IF dy2<0 THEN
                    dy2:=-dy2;
                    nodef3(f1.Sign).sign:="-";
                  END;
                  nodef3.right(f1.Number).real:=dy2;
                ELSE
                  nodef3:=NIL;
                  NEW(nodef3(f1.Number));
                  nodef3(f1.Number).real:=py;
                END;
                f.Simplify(nodef3);*)
(*                py:=f.CalcLong(nodef2,px,0.0001,pos);
                IF pos=0 THEN*)
                  node:=NIL;
                  NEW(node(s1.Term));
                  f.TreeToString(nodef2,node(s1.Term).string);
                  node(s1.Term).tree:=NIL;
                  node(s1.Term).define:=l.Create();
                  node(s1.Term).depend:=l.Create();
                  node(s1.Term).changed:=TRUE;
                  IF (term.next#NIL) OR (term.prev#NIL) OR (s1.terms.head=term) OR (s1.terms.tail=term) THEN
                    term.AddBehind(node);
                  END;
                  node2:=NIL;
                  NEW(node2(s1.Function));
                  COPY(node(s1.Term).string,node2(s1.Function).name);
                  node2(s1.Function).terms:=l.Create();
                  node2(s1.Function).define:=l.Create();
                  node2(s1.Function).depend:=l.Create();
                  node2(s1.Function).changed:=TRUE;
                  node2(s1.Function).isbase:=TRUE;
                  node3:=NIL;
                  NEW(node3(s1.FuncTerm));
                  node3(s1.FuncTerm).term:=node;
                  node2(s1.Function).terms.AddTail(node3);
                  actfunc.AddBehind(node2);
                  node(s1.Term).basefunc:=node2;
                  actfunc:=node2;
                  s2.MakeDepend(node);
                  NewTermList;
(*                ELSE
                  bool:=r.RequestWin("Normale darf nicht","senkrecht sein!","","   OK   ",wind);
                END;*)
              ELSE
                bool:=rt.RequestWin(ac.GetString(ac.NormalCannotBe),ac.GetString(ac.DrawnAtAGapNormal),s.ADR(""),ac.GetString(ac.OK),wind);
              END;
            END;
            pt.ClearPointer(wind);
          END;
(*        ELSIF address=switch THEN
          gm.CyclePressed(switch,wind,switchtext,switchpos);
          listterms:=NOT(listterms);
          NewTermList;*)
        ELSIF address=mir THEN
          IF actfunc#NIL THEN
            bool:=s4.MirrorFunc(xstr,ystr,pxstr,pystr,type);
            IF bool THEN
              node:=NIL;
              NEW(node(s1.Function));
              WITH node: s1.Function DO
                COPY(ac.GetString(ac.ReflectionOf)^,node.name);
                st.Append(node.name,actfunc(s1.Function).name);
                node.terms:=l.Create();
                s1.CopyList(actfunc(s1.Function).terms,node.terms);
                node.define:=l.Create();
                s1.CopyList(actfunc(s1.Function).define,node.define);
                node.depend:=l.Create();
                s1.CopyList(actfunc(s1.Function).depend,node.depend);
                node.changed:=TRUE;
                node.isbase:=actfunc(s1.Function).isbase;
                s2.CreateAllTrees(node);
                IF (type=0) OR (type=2) THEN
                  IF type=0 THEN
                    nodef3:=f.Parse(xstr);
                  ELSE
                    nodef3:=f.Parse(pxstr);
                  END;
                  f.Simplify(nodef3);
                  node2:=node.terms.head;
                  WHILE node2#NIL DO
                    IF node2(s1.FuncTerm).term(s1.Term).basefunc=actfunc THEN
                      node2(s1.FuncTerm).term(s1.Term).basefunc:=node;
                    END;
                    term:=node2(s1.FuncTerm).term;
                    f.Simplify(term(s1.Term).tree);
                    Mirror(term(s1.Term).tree,nodef3);
                    f.Simplify(term(s1.Term).tree);
                    f.TreeToString(term(s1.Term).tree,term(s1.Term).string);
                    s2.MakeDepend(node2);
                    node2:=node2.next;
                  END;
                END;
                IF (type=1) OR (type=2) THEN
                  IF type=1 THEN
                    nodef3:=f.Parse(ystr);
                  ELSE
                    nodef3:=f.Parse(pystr);
                  END;
                  f.Simplify(nodef3);
                  node2:=node.terms.head;
                  WHILE node2#NIL DO
                    IF node2(s1.FuncTerm).term(s1.Term).basefunc=actfunc THEN
                      node2(s1.FuncTerm).term(s1.Term).basefunc:=node;
                    END;
                    term:=node2(s1.FuncTerm).term;
                    f.Simplify(term(s1.Term).tree);
                    MirrorNode(term(s1.Term).tree,nodef3);
                    f.Simplify(term(s1.Term).tree);
                    f.TreeToString(term(s1.Term).tree,term(s1.Term).string);
                    s2.MakeDepend(node2);
                    node2:=node2.next;
                  END;
                END;
                IF node.isbase THEN
                  IF term#NIL THEN
                    COPY(node.terms.head(s1.FuncTerm).term(s1.Term).string,node.name);
                    actfunc(s1.Function).terms.head(s1.FuncTerm).term.AddBehind(term);
                  END;
                END;
              END;
              actfunc.AddBehind(node);
              actfunc:=node;
              NewTermList;
            END;
          END;
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"funcsymb",wind);
      END;
    END;

    wm.CloseWindow(workId);
  END;
  wm.FreeGadgets(workId);
  gm.FreeListView(funclist);
  RETURN ret;
END BearbeitFunctions;

(*PROCEDURE Eingabe*;

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    newf,
    delf,
    copyf,
    appf,
    ablf,
    newc,
    delc,
    copyc,
    appc,
    ablc,
    scrollf,
    upf,downf,
    scrollc,
    upc,downc,
    stringf,
    stringc : I.Gadget;
    bord1,
    bord2,
    bord3 : I.BorderPtr;
    node,
    node2,
    node3,
    oldnode : l.Node;
    actf,
    actc,
    posf,
    posc,
    oposf,
    oposc,
    x,y,pos : INTEGER;
    copyfb,
    copycb,
    appfb,
    appcb : BOOLEAN;
    boolfup,
    boolfdown,
    boolcup,
    boolcdown,
    pressedf,
    pressedc : BOOLEAN;
    aerr,err : INTEGER;
    bool     : BOOLEAN;
    text     : POINTER TO ARRAY OF ARRAY OF CHAR;
    startnode,
    endnode  : l.Node;
    nodef,anode : f2.NodePtr;
    string   : ARRAY 256 OF CHAR;


(*PROCEDURE GetNode(list:l.List;num:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  node:=list.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=num) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetNode;*)

PROCEDURE RefreshFunktions;

VAR node : l.Node;
    str  : ARRAY 39 OF CHAR;

BEGIN
  node:=s1.terms.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=posf) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;

  g.SetAPen(rast,1);
  i:=-1;
  LOOP
    INC(i);
    IF i>7 THEN
      EXIT;
    END;
    IF node#NIL THEN
      IF posf+i=actf THEN
        g.SetAPen(rast,3);
        g.RectFill(rast,24,30+i*10,340,39+i*10);
        g.SetAPen(rast,2);
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,24,30+i*10,340,39+i*10);
        g.SetAPen(rast,1);
      END;
      str:="                                       ";
      COPY(node(s1.Term).string,str);
      b.Print(24,37+i*10,str,rast);
      node:=node.next;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,24,30+i*10,340,39+i*10);
    END;
  END;
  IF s1.terms.nbElements()=0 THEN
    g.SetAPen(rast,2);
    b.Print(40,59,"Keine Funktionen",rast);
  END;
END RefreshFunktions;

PROCEDURE RefreshVariables;

VAR node : l.Node;
    str  : ARRAY 24 OF CHAR;

BEGIN
  node:=s1.variables.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=posc) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;

  g.SetAPen(rast,1);
  i:=-1;
  LOOP
    INC(i);
    IF i>7 THEN
      EXIT;
    END;
    IF node#NIL THEN
      IF posc+i=actc THEN
        g.SetAPen(rast,3);
        g.RectFill(rast,370,30+i*10,566,39+i*10);
        g.SetAPen(rast,2);
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,370,30+i*10,566,39+i*10);
        g.SetAPen(rast,1);
      END;
      str:="                        ";
      COPY(node(f2.Variable).string,str);
      b.Print(370,37+i*10,str,rast);
      node:=node.next;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,370,30+i*10,566,39+i*10);
    END;
  END;
  IF s1.variables.nbElements()=0 THEN
    g.SetAPen(rast,2);
    b.Print(386,59,"Keine Konstanten",rast);
  END;
END RefreshVariables;

PROCEDURE SetListPos;

BEGIN
  IF actf<posf THEN
    DEC(posf);
    IF posf<0 THEN
      posf:=0;
    END;
  ELSIF actf>posf+10 THEN
    INC(posf);
  END;
  IF actc<posc THEN
    DEC(posc);
    IF posc<0 THEN
      posc:=0;
    END;
  ELSIF actc>posc+10 THEN
    INC(posc);
  END;
END SetListPos;

(*PROCEDURE MakeConstant(node:l.Node):INTEGER;

VAR namelen,
    termlen,
    ret,i,a,
    pos     : INTEGER;
    name,
    bool    : BOOLEAN;
    str     : POINTER TO ARRAY OF CHAR;
    node2   : l.Node;

PROCEDURE GetElement(pos:INTEGER);

VAR i,a : INTEGER;

BEGIN
  str:=NIL;
  a:=pos;
  i:=0;
  LOOP
    IF (f.isSign(node(s1.Constant).term^[a])) OR (f.isNumber(node(s1.Constant).term^[a])) THEN
      EXIT;
    END;
    INC(i);
    INC(a);
    IF a=st.Length(node(s1.Constant).term^) THEN
      EXIT;
    END;
  END;
  NEW(str,i);
  st.Cut(node(s1.Constant).term^,pos,i,str^);
END GetElement;

BEGIN
  WITH node: s1.Constant DO
    i:=-1;
    namelen:=0;
    termlen:=0;
    name:=TRUE;
    ret:=0;
    LOOP
      INC(i);
      IF i>=st.Length(node.string) THEN
        IF name THEN
          ret:=3;
        END;
        EXIT;
      END;
      IF node.string[i]="=" THEN
        name:=FALSE;
        DEC(termlen);
      END;
      IF name THEN
        INC(namelen);
      ELSE
        INC(termlen);
      END;
    END;
    IF namelen>0 THEN
      node.name:=NIL;
      NEW(node.name,namelen);
      st.Cut(node.string,0,namelen,node.name^);
    ELSE
      IF ret=0 THEN
        ret:=1;
      END;
    END;
    IF termlen>0 THEN
      node.term:=NIL;
      NEW(node.term,termlen);
      st.Cut(node.string,namelen+1,termlen,node.term^);
    ELSE
      IF ret=0 THEN
        ret:=2;
      END;
    END;
(*    IF ret=0 THEN
      node.depend.Init;
      i:=-1;
      WHILE i<termlen-1 DO
        INC(i);
        bool:=TRUE;
        IF f.isSign(node.term^[i]) THEN
          bool:=FALSE;
        ELSIF f.isNumber(node.term^[i]) THEN
          bool:=FALSE;
        END;
        a:=f.isOperation(node.term^,i);
        IF a#0 THEN
          bool:=FALSE;
          INC(i,a-2);
        END;
        IF bool THEN
  (* Konstantenname gefunden *)
          GetElement(i);
          node2:=s1.constants.head;
          WHILE node2#NIL DO
            bool:=FALSE;
            a:=-1;
            pos:=i;
            WHILE a<st.Length(str^)-1 DO
              IF CAP(str^[a])#CAP(node2(s1.Constant).name[pos]) THEN
                bool:=TRUE;
              END;
              INC(pos);
            END;
            node2:=node2.next;
          END;
        END;
      END;
    END;*)
  END;
  RETURN ret;
END MakeConstant;

PROCEDURE Compare(str1,str2:ARRAY OF CHAR):BOOLEAN;

VAR i   : INTEGER;
    ret : BOOLEAN;

BEGIN
  ret:=TRUE;
  IF st.Length(str1)=st.Length(str2) THEN
    FOR i:=0 TO SHORT(st.Length(str1)-1) DO
      str1[i]:=st.CapIntl(str1[i]);
      str2[i]:=st.CapIntl(str2[i]);
      IF str1[i]#str2[i] THEN
        ret:=FALSE;
      END;
    END;
  ELSE
    ret:=FALSE;
  END;
  RETURN ret;
END Compare;

PROCEDURE MakeDepend(node:l.Node);

VAR i,a   : INTEGER;
    bool,
    bool2 : BOOLEAN;
    str   : POINTER TO ARRAY OF CHAR;
    node2,
    nodenew : l.Node;

PROCEDURE GetElement(pos:INTEGER);

VAR i,a : INTEGER;

BEGIN
  str:=NIL;
  a:=pos;
  i:=0;
  LOOP
    IF (f.isSign(node(s1.Constant).term^[a])) OR (f.isNumber(node(s1.Constant).term^[a])) THEN
      EXIT;
    END;
    INC(i);
    INC(a);
    IF a=st.Length(node(s1.Constant).term^) THEN
      EXIT;
    END;
  END;
  NEW(str,i);
  st.Cut(node(s1.Constant).term^,pos,i,str^);
END GetElement;

BEGIN
  WITH node: s1.Constant DO
    node.depend.Init;
    i:=-1;
    WHILE i<st.Length(node.term^)-1 DO
      INC(i);
      bool:=TRUE;
      IF f.isSign(node.term^[i]) THEN
        bool:=FALSE;
      ELSIF f.isNumber(node.term^[i]) THEN
        bool:=FALSE;
      END;
      bool2:=f.isOperation(node.term^,i,a,x);
      IF a#0 THEN
        bool:=FALSE;
        INC(i,a-2);
      END;
      IF bool THEN
  (* Konstantenname gefunden *)
        GetElement(i);
        node2:=s1.constants.head;
        WHILE node2#NIL DO
          IF Compare(str^,node2(s1.Constant).name^) THEN
            NEW(nodenew(Depend));
            nodenew(Depend).node:=node2;
            node.depend.AddTail(nodenew);
          END;
          node2:=node2.next;
        END;
      END;
    END;
  END;
END MakeDepend;*)

PROCEDURE MakeDepend(node:l.Node);

VAR str,str2 : POINTER TO ARRAY OF CHAR;
    node2,
    newnode  : l.Node;
    long     : LONGINT;

BEGIN
  WITH node: s1.Term DO
    node.depend.Init;
    NEW(str,st.Length(node.string)+1);
    COPY(node.string,str^);
    st.Upper(str^);
    node2:=s1.variables.head;
    WHILE node2#NIL DO
      str2:=NIL;
      NEW(str2,st.Length(node2(f2.Variable).name^)+1);
      COPY(node2(f2.Variable).name^,str2^);
      st.Upper(str2^);
      long:=st.Occurs(str^,str2^);
      IF long#-1 THEN
        newnode:=NIL;
        NEW(newnode(s1.Depend));
        newnode(s1.Depend).var:=node2;
        node.depend.AddTail(newnode);
      END;
      node2:=node2.next;
    END;
  END;
END MakeDepend;

PROCEDURE MakeVariable(node:l.Node):INTEGER;

VAR i,a,ret : INTEGER;
    str     : ARRAY 100 OF CHAR;
    root    : f2.NodePtr;
    endreal : BOOLEAN;
    oldstart,
    oldend,
    oldstep : LONGREAL;
    oldname : POINTER TO ARRAY OF CHAR;
    changed : BOOLEAN;
    node2,
    node3   : l.Node;

BEGIN
  ret:=0;
  WITH node: f2.Variable DO
    oldstart:=node.startx;
    oldend:=node.endx;
    oldstep:=node.stepx;
    IF node.name#NIL THEN
      NEW(oldname,st.Length(node.name^)+1);
      COPY(node.name^,oldname^);
    ELSE
      NEW(oldname,1);
      oldname^[0]:=0X;
    END;
    i:=-1;
    LOOP
      INC(i);
      IF i>=st.Length(node.string) THEN
        ret:=1;
        EXIT;
      END;
      IF node.string[i]="=" THEN
        IF i=0 THEN
          ret:=1;
        END;
        str[i]:=0X;
        EXIT;
      END;
      str[i]:=node.string[i];
    END;
    NEW(node.name,st.Length(str)+1);
    COPY(str,node.name^);
    endreal:=FALSE;
    IF ret=0 THEN
      st.Delete(str,0,100);
      a:=-1;
      LOOP
        INC(i);
        INC(a);
        IF i>=st.Length(node.string)-1 THEN
          IF a=0 THEN
            ret:=2;
          ELSE
            str[a]:=0X;
            endreal:=TRUE;
          END;
          EXIT;
        END;
        IF (node.string[i]=".") AND (node.string[i+1]=".") THEN
          IF a=0 THEN
            ret:=2;
          END;
          str[a]:=0X;
          endreal:=TRUE;
          EXIT;
        END;
        str[a]:=node.string[i];
      END;
(*      bool:=lrc.StringToReal(str,node.startx);*)
      a:=0;
      root:=f.Parse(str,a);
      node.startx:=f.Rechen(root,0,0,a);
      IF NOT(endreal) THEN
        node.endx:=node.startx;
        node.stepx:=0;
      END;
      IF (ret=0) AND (endreal) THEN
        st.Delete(str,0,100);
        INC(i);
        a:=-1;
        LOOP
          INC(i);
          INC(a);
          IF i>=st.Length(node.string) THEN
            IF a=0 THEN
              ret:=3;
            END;
            str[a]:=0X;
            EXIT;
          END;
          IF i<st.Length(node.string)-1 THEN
            IF (CAP(node.string[i])="B") AND (CAP(node.string[i+1])="Y") THEN
              IF a=0 THEN
                ret:=3;
              END;
              str[a]:=0X;
              EXIT;
            END;
          END;
          str[a]:=node.string[i];
        END;
(*        bool:=lrc.StringToReal(str,node.endx);*)
        a:=0;
        root:=f.Parse(str,a);
        node.endx:=f.Rechen(root,0,0,a);
        node.stepx:=1;
        IF ret=0 THEN
          IF i<st.Length(node.string)-1 THEN
            IF (CAP(node.string[i])="B") AND (CAP(node.string[i+1])="Y") THEN
              st.Delete(str,0,100);
              INC(i);
              a:=-1;
              LOOP
                INC(i);
                INC(a);
                IF i>=st.Length(node.string) THEN
                  str[a]:=0X;
                  EXIT;
                END;
                str[a]:=node.string[i];
              END;
              IF a#0 THEN
(*                bool:=lrc.StringToReal(str,node.stepx);*)
                a:=0;
                root:=f.Parse(str,a);
                node.stepx:=f.Rechen(root,0,0,a);
              END;
            END;
          END;
        END;
      END;
    END;
    IF ret=0 THEN
      changed:=TRUE;
      IF (oldstart=node.startx) AND (oldend=node.endx) AND (oldstep=node.stepx) THEN
        st.Upper(oldname^);
        COPY(node.name^,str);
        st.Upper(str);
        IF st.Length(str)=st.Length(oldname^) THEN
          IF st.Occurs(oldname^,str)#-1 THEN
            changed:=FALSE;
            node.changed:=TRUE;
          END;
        END;
      END;
    END;
  END;
  RETURN ret;
END MakeVariable;

PROCEDURE CheckChanged(node:l.Node);

VAR node2 : l.Node;

BEGIN
  node2:=node(s1.Term).depend.head;
  WHILE node2#NIL DO
    IF node2(s1.Depend).var(f2.Variable).changed THEN
      node(s1.Term).changed:=TRUE;
    END;
    node2:=node2.next;
  END;
END CheckChanged;

(*PROCEDURE CheckDepend(node:l.Node):BOOLEAN;

VAR done    : l.List;
    nodenew : l.Node;
    ret     : BOOLEAN;

PROCEDURE Check(list:l.List);

VAR node,node2,nodenew : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    node2:=done.head;
    WHILE node2#NIL DO
      IF node(Depend).node=node2(Depend).node THEN
        startnode:=node(Depend).node;
        endnode:=s1.constants.head;
        LOOP
          IF endnode(s1.Constant).depend=list THEN
            EXIT;
          END;
          endnode:=endnode.next;
        END;
        ret:=TRUE;
      END;
      node2:=node2.next;
    END;
    IF NOT(ret) THEN
      NEW(nodenew(Depend));
      nodenew(Depend).node:=node(Depend).node;
      done.AddTail(nodenew);
      Check(node(Depend).node(s1.Constant).depend);
      nodenew:=done.RemTail();
    END;
    node:=node.next;
  END;
END Check;

BEGIN
  ret:=FALSE;
  WITH node: s1.Constant DO
    done:=l.Create();
    NEW(nodenew(Depend));
    nodenew(Depend).node:=node;
    done.AddTail(nodenew);
    Check(node.depend);
  END;
  RETURN ret;
END CheckDepend;*)

PROCEDURE MakeAllVariables;

VAR i,err : INTEGER;
    node  : l.Node;

BEGIN
  err:=0;
  node:=s1.variables.head;
  WHILE node#NIL DO
    aerr:=MakeVariable(node);
    node:=node.next;
  END;
END MakeAllVariables;

BEGIN
  IF eingabeId=-1 THEN
    eingabeId:=wm.InitWindow(20,0,606,229,"Eingabe",LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},s1.screen,FALSE);
  END;
  wm.ChangeScreen(eingabeId,s1.screen);
  wind:=wm.OpenWindow(eingabeId);
(*  wind:=is.SetWindow(20,(*10*)0,606,(*216*)228,s.ADR("Eingabe"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                     LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},s1.screen);*)
  IF wind#NIL THEN
    rast:=wind.rPort;
    ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,207,100,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),490,207,100,
                      SET{I.gadgImmediate,I.relVerify});

    ig.SetPlastHighGadget(newf,wind,s.ADR("Neue Funktion"),18,127,340,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(delf,wind,s.ADR("Funktion löschen"),18,142,340,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(copyf,wind,s.ADR("Funktion kopieren"),18,157,340,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastHighGadget(appf,wind,s.ADR("Funktion anhängen"),18,172,340,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastHighGadget(ablf,wind,s.ADR("Funktion ableiten"),18,187,340,
                      SET{I.gadgImmediate,I.relVerify});

    ig.SetPlastHighGadget(newc,wind,s.ADR("Neue Variable"),364,127,220,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(delc,wind,s.ADR("Variable löschen"),364,142,220,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(copyc,wind,s.ADR("Variable kopieren"),364,157,220,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
(*    ig.SetPlastHighGadget(appc,wind,s.ADR("Variable anhängen"),364,171,220,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastHighGadget(ablc,wind,s.ADR("Variable ableiten"),364,186,220,
                      SET{I.gadgImmediate,I.relVerify});*)

    ig.SetArrowUpGadget(upf,wind,344,92,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetArrowDownGadget(downf,wind,344,102,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastStringGadget(stringf,wind,328,255,20,112,FALSE);
    ig.SetArrowUpGadget(upc,wind,570,92,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetArrowDownGadget(downc,wind,570,102,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastStringGadget(stringc,wind,208,255,366,112,FALSE);

    ig.SetPlastProp(scrollf,SET{I.autoKnob,I.freeVert,I.knobHit},346,29,12,60,
                    0,4096,wind);
    ig.SetPlastProp(scrollc,SET{I.autoKnob,I.freeVert,I.knobHit},572,29,12,60,
                    0,4096,wind);

    g.SetAPen(rast,2);
    b.Print(20,25,"Funktionen",rast);
    b.Print(366,25,"Variablen",rast);

    bord1:=ig.SetPlastBorder(185,574);
    I.DrawBorder(rast,bord1,16,17);
(*    I.DrawBorder(rast,bord1,238,17);*)

    bord2:=ig.SetPlastBorder(80,320);
    I.DrawBorder(rast,bord2,22,29);
    bord3:=ig.SetPlastBorder(80,200);
    I.DrawBorder(rast,bord3,368,29);

    g.SetDrMd(rast,g.jam1);
    actf:=0;
    actc:=0;
    posf:=0;
    posc:=0;
    RefreshFunktions;
    RefreshVariables;
    s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
    s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
    node:=s1.GetNode(s1.terms,actf);
    IF node#NIL THEN
      ig.PutGadgetText(s.ADR(stringf),s.ADR(node(s1.Term).string));
      I.RefreshGList(s.ADR(stringf),wind,NIL,1);
      bool:=TRUE;
    END;
    node:=s1.GetNode(s1.variables,actc);
    IF node#NIL THEN
      ig.PutGadgetText(s.ADR(stringc),s.ADR(node(f2.Variable).string));
      I.RefreshGList(s.ADR(stringc),wind,NIL,1);
    END;
    IF bool THEN
      bool:=I.ActivateGadget(stringf,wind,NIL);
    END;

    LOOP
      IF NOT(pressedf) AND NOT(boolfup) AND NOT(boolfdown) AND NOT(pressedc) AND NOT(boolcup) AND NOT(boolcdown) THEN
        e.WaitPort(wind.userPort);
      END;
      it.GetIMes(wind,class,code,address);
      IF I.gadgetDown IN class THEN
        IF address=s.ADR(scrollf) THEN
          pressedf:=TRUE;
        ELSIF address=s.ADR(upf) THEN
          boolfup:=TRUE;
        ELSIF address=s.ADR(downf) THEN
          boolfdown:=TRUE;
        ELSIF address=s.ADR(scrollc) THEN
          pressedc:=TRUE;
        ELSIF address=s.ADR(upc) THEN
          boolcup:=TRUE;
        ELSIF address=s.ADR(downc) THEN
          boolcdown:=TRUE;
        END;
      ELSIF I.gadgetUp IN class THEN
        IF address=s.ADR(scrollf) THEN
          pressedf:=FALSE;
        ELSIF address=s.ADR(upf) THEN
          boolfup:=FALSE;
        ELSIF address=s.ADR(downf) THEN
          boolfdown:=FALSE;
        ELSIF address=s.ADR(scrollc) THEN
          pressedc:=FALSE;
        ELSIF address=s.ADR(upc) THEN
          boolcup:=FALSE;
        ELSIF address=s.ADR(downc) THEN
          boolcdown:=FALSE;
        END;
      ELSIF I.mouseButtons IN class THEN
        IF code=I.selectUp THEN
          boolfup:=FALSE;
          boolfdown:=FALSE;
          boolcup:=FALSE;
          boolcdown:=FALSE;
        END;
      END;
      oposf:=posf;
      oposc:=posc;
      s1.GetProp(scrollf,SHORT(s1.terms.nbElements()),8,posf);
      IF boolfup THEN
        DEC(posf);
        IF posf<0 THEN
          posf:=0;
        END;
        IF oposf#posf THEN
          s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
        END;
      ELSIF boolfdown THEN
        INC(posf);
        IF posf>SHORT(s1.terms.nbElements())-8 THEN
          DEC(posf);
        END;
        IF oposf#posf THEN
          s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
        END;
      END;
      s1.GetProp(scrollc,SHORT(s1.variables.nbElements()),8,posc);
      IF boolcup THEN
        DEC(posc);
        IF posc<0 THEN
          posc:=0;
        END;
        IF oposc#posc THEN
          s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
        END;
      ELSIF boolcdown THEN
        INC(posc);
        IF posc>SHORT(s1.variables.nbElements())-8 THEN
          DEC(posc);
        END;
        IF oposc#posc THEN
          s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
        END;
      END;
      IF oposf#posf THEN
        s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
        RefreshFunktions;
      END;
      IF oposc#posc THEN
        s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
        RefreshVariables;
      END;
      IF I.gadgetUp IN class THEN
        IF address=s.ADR(ok) THEN
          f.varhead:=s1.variables.head;
          err:=0;
          i:=0;
          node:=s1.variables.head;
          WHILE node#NIL DO
            aerr:=MakeVariable(node);
            IF (aerr#0) AND (err=0) THEN
              err:=aerr;
              actc:=i;
            END;
            node:=node.next;
            INC(i);
          END;
          IF err=0 THEN
(*            node:=s1.variables.head;
            WHILE node#NIL DO
              MakeDepend(node);
              node:=node.next;
            END;
            node:=s1.variables.head;
            WHILE node#NIL DO
              bool:=CheckDepend(node);
              IF bool THEN
                err:=4;
              END;
              node:=node.next;
              IF bool THEN
                node:=NIL;
              END;
            END;*)
          END;
          IF err=0 THEN
            node:=s1.terms.head;
            WHILE node#NIL DO
              MakeDepend(node);
              CheckChanged(node);
              node:=node.next;
            END;
            node:=s1.variables.head;
            WHILE node#NIL DO
              node(f2.Variable).changed:=FALSE;
              node:=node.next;
            END;
            f.varhead:=s1.variables.head;

            node:=s1.functions.head;
            WHILE node#NIL DO
              node2:=s1.terms.head;
              WHILE node2#NIL DO
                IF node2(s1.Term).changed THEN
                  node3:=node(s1.Function).terms.head;
                  WHILE node3#NIL DO
                    IF node3(s1.FuncTerm).term=node2 THEN
                      node(s1.Function).changed:=TRUE;
                    END;
                    node3:=node3.next;
                  END;
                END;
                node2:=node2.next;
              END;
              s1.RefreshDefines(node);
              node:=node.next;
            END;

            node:=s1.fenster.head;
            WHILE node#NIL DO
              node2:=node(s1.Fenster).funcs.head;
              WHILE node2#NIL DO
                IF node2(s1.FensterFunc).func.changed THEN
                  node(s1.Fenster).refresh:=TRUE;
                END;
                node2:=node2.next;
              END;
              node:=node.next;
            END;
            s1.RemoveEmptyFunctions;
            EXIT;
          ELSIF err=1 THEN
            node:=s1.GetNode(s1.variables,actc);
            NEW(text,4,80);
            text[0]:="Fehler bei Variablendefinition:";
            text[1]:="Variablenname fehlt!";
            text[2]:="";
            COPY(node(f2.Variable).string,text[3]);
            bool:=s1.Request(text^,"","    OK    ",wind);
(*            bool:=r.RequestWin("Fehler bei Konstantendefinition:","Konstantenname fehlt!","","    OK    ",wind);*)
          ELSIF err=2 THEN
            node:=s1.GetNode(s1.variables,actc);
            NEW(text,4,80);
            text[0]:="Fehler bei Variablendefinition:";
            text[1]:="Startwert fehlt!";
            text[2]:="";
            COPY(node(f2.Variable).string,text[3]);
            bool:=s1.Request(text^,"","    OK    ",wind);
(*            bool:=r.RequestWin("Fehler bei Konstantendefinition:","Konstantenterm fehlt!","","    OK    ",wind);*)
          ELSIF err=3 THEN
            node:=s1.GetNode(s1.variables,actc);
            NEW(text,4,80);
            text[0]:="Fehler bei Variablendefinition:";
            text[1]:="Endwert fehlt!";
            text[2]:="";
            COPY(node(f2.Variable).string,text[3]);
            bool:=s1.Request(text^,"","    OK    ",wind);
(*            bool:=r.RequestWin("Fehler bei Konstantendefinition:","Gleichheitszeichen fehlt!","","    OK    ",wind);*)
          ELSIF err=4 THEN
            NEW(text,5,80);
            text[0]:="Fehler bei Konstantendefinition:";
            text[1]:="Konstantenabhängigkeiten überlappen sich!";
            text[2]:="";
            text[3]:="Anfang bei: ";
            text[4]:="Ende   bei: ";
            st.Append(text[3],startnode(f2.Variable).string);
            st.Append(text[4],endnode(f2.Variable).string);
            bool:=s1.Request(text^,"","    OK    ",wind);
(*            bool:=r.RequestWin("Fehler bei Konstantendefinition:","Konstantenabhängigkeiten überlappen sich!","","    OK    ",wind);*)
          END;
          SetListPos;
          node:=s1.GetNode(s1.variables,actc);
          IF node#NIL THEN
            ig.PutGadgetText(s.ADR(stringc),s.ADR(node(f2.Variable).string));
          END;
          RefreshVariables;

  (* Funktionen *)

        ELSIF address=s.ADR(newf) THEN
          node:=NIL;
          NEW(node(s1.Term));
          node(s1.Term).depend:=l.Create();
          node(s1.Term).define:=l.Create();
          node(s1.Term).string:="";
          node(s1.Term).changed:=TRUE;
          s1.terms.AddTail(node);
          node2:=NIL;
          NEW(node2(s1.Function));
          node2(s1.Function).terms:=l.Create();
          node2(s1.Function).depend:=l.Create();
          node2(s1.Function).define:=l.Create();
          node3:=NIL;
          NEW(node3(s1.FuncTerm));
          node3(s1.FuncTerm).term:=node;
          node2(s1.Function).terms.AddTail(node3);
          node2(s1.Function).name:="";
(*          COPY(node(s1.Term).string,node2(s1.Function).name);*)
          node2(s1.Function).changed:=TRUE;
          s1.functions.AddTail(node2);
          s1.RefreshDefines(node2);
          ig.PutGadgetText(s.ADR(stringf),s.ADR(node(s1.Term).string));
          bool:=I.ActivateGadget(stringf,wind,NIL);
          actf:=SHORT(s1.terms.nbElements()-1);
          IF actf<posf THEN
            DEC(posf);
            IF posf<0 THEN
              posf:=0;
            END;
          ELSIF actf>posf+7 THEN
            INC(posf);
          END;
          s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
          RefreshFunktions;
        ELSIF address=s.ADR(delf) THEN
          node:=s1.GetNode(s1.terms,actf);
          IF node#NIL THEN
            node.Remove;
          END;
          IF actf>SHORT(s1.terms.nbElements()-1) THEN
            DEC(actf);
            IF actf<0 THEN
              actf:=0;
            END;
          END;
          SetListPos;
          s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
          node:=s1.GetNode(s1.terms,actf);
          IF node#NIL THEN
            ig.PutGadgetText(s.ADR(stringf),s.ADR(node(s1.Term).string));
            bool:=I.ActivateGadget(stringf,wind,NIL);
          END;
          RefreshFunktions;
        ELSIF address=s.ADR(copyf) THEN
          copyfb:=NOT(copyfb);
          appfb:=FALSE;
          gm.DeActivateBool(s.ADR(appf),wind);
        ELSIF address=s.ADR(appf) THEN
          appfb:=NOT(appfb);
          copyfb:=FALSE;
          gm.DeActivateBool(s.ADR(copyf),wind);
        ELSIF address=s.ADR(ablf) THEN
          node:=s1.GetNode(s1.terms,actf);
          IF node#NIL THEN
            MakeAllVariables;
            f.varhead:=s1.variables.head;
            pos:=0;
            nodef:=f.Parse(node(s1.Term).string,pos);
            f.Vereinfache(nodef);
            f.Ableit(nodef,"X");
            f.Vereinfache(nodef);
            node2:=NIL;
            NEW(node2(s1.Term));
            node2(s1.Term).depend:=l.Create();
            node2(s1.Term).define:=l.Create();
            node2(s1.Term).changed:=TRUE;
            node.AddBehind(node2);
            node3:=NIL;
            NEW(node3(s1.Function));
            node3(s1.Function).terms:=l.Create();
            node3(s1.Function).depend:=l.Create();
            node3(s1.Function).define:=l.Create();
            COPY(node(s1.Term).string,node3(s1.Function).name);
            node:=NIL;
            NEW(node(s1.FuncTerm));
            node(s1.FuncTerm).term:=node2;
            node3(s1.Function).terms.AddTail(node);
            node3(s1.Function).changed:=TRUE;
            s1.functions.AddTail(node3);
            s1.RefreshDefines(node3);
            ig.PutGadgetText(s.ADR(stringf),s.ADR(node2(s1.Term).string));
            bool:=I.ActivateGadget(stringf,wind,NIL);
            INC(actf);
            SetListPos;
(*            IF actf<posf THEN
              DEC(posf);
              IF posf<0 THEN
                posf:=0;
              END;
            ELSIF actf>posf+7 THEN
              INC(posf);
            END;*)
            s1.RefrScroll(scrollf,wind,SHORT(s1.terms.nbElements()),posf,8);
            node:=node2;
            st.Delete(node(s1.Term).string,0,st.Length(node(s1.Term).string));
            f.TreeToString(nodef,node(s1.Term).string,FALSE);
            ig.PutGadgetText(s.ADR(stringf),s.ADR(node(s1.Term).string));
            I.RefreshGList(s.ADR(stringf),wind,NIL,1);
            bool:=I.ActivateGadget(stringf,wind,NIL);
            node(s1.Term).changed:=TRUE;
            RefreshFunktions;
          END;
        ELSIF address=s.ADR(stringf) THEN
          RefreshFunktions;
          bool:=I.ActivateGadget(stringf,wind,NIL);
          node:=s1.GetNode(s1.terms,actf);
          IF node#NIL THEN
            node(s1.Term).changed:=TRUE;
          END;

  (* Konstanten *)

        ELSIF address=s.ADR(newc) THEN
          node:=NIL;
          NEW(node(f2.Variable));
(*          node(s1.Constant).depend:=l.Create();*)
          s1.variables.AddTail(node);
          ig.PutGadgetText(s.ADR(stringc),s.ADR(node(f2.Variable).string));
          bool:=I.ActivateGadget(stringc,wind,NIL);
          actc:=SHORT(s1.variables.nbElements()-1);
          IF actc<posc THEN
            DEC(posc);
            IF posc<0 THEN
              posc:=0;
            END;
          ELSIF actc>posc+7 THEN
            INC(posc);
          END;
          s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
          RefreshVariables;
        ELSIF address=s.ADR(delc) THEN
          node:=s1.GetNode(s1.variables,actc);
          IF node#NIL THEN
            node.Remove;
          END;
          IF actc>SHORT(s1.variables.nbElements()-1) THEN
            DEC(actc);
            IF actc<0 THEN
              actc:=0;
            END;
          END;
          SetListPos;
          s1.RefrScroll(scrollc,wind,SHORT(s1.variables.nbElements()),posc,8);
          node:=s1.GetNode(s1.variables,actc);
          IF node#NIL THEN
            ig.PutGadgetText(s.ADR(stringc),s.ADR(node(f2.Variable).string));
            bool:=I.ActivateGadget(stringc,wind,NIL);
          END;
          RefreshVariables;
        ELSIF address=s.ADR(copyc) THEN
          copycb:=NOT(copycb);
          appcb:=FALSE;
          gm.DeActivateBool(s.ADR(appc),wind);
        ELSIF address=s.ADR(appc) THEN
          appcb:=NOT(appcb);
          copycb:=FALSE;
          gm.DeActivateBool(s.ADR(copyc),wind);
        ELSIF address=s.ADR(stringc) THEN
          RefreshVariables;
          bool:=I.ActivateGadget(stringc,wind,NIL);
        END;
      ELSIF I.mouseButtons IN class THEN
        IF code=I.selectDown THEN
          it.GetMousePos(wind,x,y);
          IF (x>22) AND (x<342) AND (y>29) AND (y<110) THEN
            IF copyfb OR appfb THEN
              oldnode:=s1.GetNode(s1.terms,actf);
            END;
            y:=y-30;
            y:=y DIV 10;
            actf:=y+posf;
            INC(actf);
            REPEAT
              DEC(actf);
              node:=s1.GetNode(s1.terms,actf);
            UNTIL (node#NIL) OR (actf=-1);
            WITH node: s1.Term DO
              IF copyfb THEN
                st.Delete(node.string,0,st.Length(node.string));
                COPY(oldnode(s1.Term).string,node.string);
                copyfb:=FALSE;
                gm.DeActivateBool(s.ADR(copyf),wind);
                node.changed:=TRUE;
              ELSIF appfb THEN
                st.Append(node.string,oldnode(s1.Term).string);
                appfb:=FALSE;
                gm.DeActivateBool(s.ADR(appf),wind);
                node.changed:=TRUE;
              END;
              IF actf#-1 THEN
                SetListPos;
                ig.PutGadgetText(s.ADR(stringf),s.ADR(node.string));
                bool:=I.ActivateGadget(stringf,wind,NIL);
              END;
            END;
            RefreshFunktions;
          ELSIF (x>368) AND (x<568) AND (y>29) AND (y<110) THEN
            IF copycb OR appcb THEN
              oldnode:=s1.GetNode(s1.variables,actc);
            END;
            y:=y-30;
            y:=y DIV 10;
            actc:=y+posc;
            INC(actc);
            REPEAT
              DEC(actc);
              node:=s1.GetNode(s1.variables,actc);
            UNTIL (node#NIL) OR (actc=-1);
            WITH node: f2.Variable DO
              IF copycb THEN
                st.Delete(node.string,0,st.Length(node.string));
                COPY(oldnode(f2.Variable).string,node.string);
                copycb:=FALSE;
                gm.DeActivateBool(s.ADR(copyc),wind);
              ELSIF appcb THEN
                st.Append(node.string,oldnode(f2.Variable).string);
                appcb:=FALSE;
                gm.DeActivateBool(s.ADR(appc),wind);
              END;
              IF actc#-1 THEN
                SetListPos;
                ig.PutGadgetText(s.ADR(stringc),s.ADR(node.string));
                bool:=I.ActivateGadget(stringc,wind,NIL);
              END;
            END;
            RefreshVariables;
          END;
        END;
      END;
    END;

    ig.FreePlastPropGadget(scrollc,wind);
    ig.FreePlastPropGadget(scrollf,wind);
    ig.FreeStringGadget(stringc,wind);
    ig.FreePlastArrowGadget(downc,wind);
    ig.FreePlastArrowGadget(upc,wind);
    ig.FreeStringGadget(stringf,wind);
    ig.FreePlastArrowGadget(downf,wind);
    ig.FreePlastArrowGadget(upf,wind);
(*    ig.FreePlastHighBooleanGadget(ablc,wind);
    ig.FreePlastHighBooleanGadget(appc,wind);*)
    ig.FreePlastHighBooleanGadget(copyc,wind);
    ig.FreePlastHighBooleanGadget(delc,wind);
    ig.FreePlastHighBooleanGadget(newc,wind);
    ig.FreePlastHighBooleanGadget(ablf,wind);
    ig.FreePlastHighBooleanGadget(appf,wind);
    ig.FreePlastHighBooleanGadget(copyf,wind);
    ig.FreePlastHighBooleanGadget(delf,wind);
    ig.FreePlastHighBooleanGadget(newf,wind);
    ig.FreePlastHighBooleanGadget(ca,wind);
    ig.FreePlastHighBooleanGadget(ok,wind);
    ig.FreePlastBorder(bord1);
    ig.FreePlastBorder(bord2);
    ig.FreePlastBorder(bord3);
    wm.CloseWindow(eingabeId);
(*  ELSE
    s1.NoMem;*)
  END;
(*
VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    gad,
    num  : ARRAY 10 OF I.Gadget;
    ok,ca,
    copy,
    ableit : I.Gadget;
    str  : ARRAY 4 OF CHAR;
    point: e.STRPTR(*POINTER TO ARRAY 1000 OF CHAR*);
    bool : BOOLEAN;
    check: ARRAY 10 OF ARRAY 500 OF CHAR;
    strp : ARRAY 10 OF ARRAY 500 OF CHAR;

BEGIN
  wind:=is.SetWindow(50,10,540,187,s.ADR("Eingabe"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                     LONGSET{I.menuPick,I.rawKey,I.gadgetUp},s1.screen);
  rast:=wind.rPort;
  i:=-1;
  WHILE i<9 DO
    i:=i+1;
    ig.SetPlastStringGadget(gad[i],wind,360,1000,14,16+i*15,FALSE);
    ig.PutGadgetText(s.ADR(gad[i]),s.ADR(s1.funcstr[i]));
    a:=-1;
    WHILE a<SHORT(st.Length(s1.funcstr[i]))-1 DO
      a:=a+1;
      check[i,a]:=s1.funcstr[i,a];
    END;
  END;
  ig.SetPlastGadget(num[0],wind,NIL,s.ADR(" 01 "),390,17,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[1],wind,NIL,s.ADR(" 02 "),390,32,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[2],wind,NIL,s.ADR(" 03 "),390,47,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[3],wind,NIL,s.ADR(" 04 "),390,62,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[4],wind,NIL,s.ADR(" 05 "),390,77,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[5],wind,NIL,s.ADR(" 06 "),390,92,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[6],wind,NIL,s.ADR(" 07 "),390,107,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[7],wind,NIL,s.ADR(" 08 "),390,122,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[8],wind,NIL,s.ADR(" 09 "),390,137,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(num[9],wind,NIL,s.ADR(" 10 "),390,152,
                    SET{I.gadgImmediate,I.relVerify});

  ig.SetPlastGadget(ok,wind,NIL,s.ADR("   OK   "),14,168,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(ca,wind,NIL,s.ADR(" Cancel "),280,168,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(copy,wind,NIL,s.ADR(" Kopieren "),436,17,
                    SET{I.gadgImmediate,I.relVerify});
  ig.SetPlastGadget(ableit,wind,NIL,s.ADR(" Ableiten "),436,32,
                    SET{I.gadgImmediate,I.relVerify});
  I.RefreshGadgets(s.ADR(gad[0]),wind,NIL);
  bool:=I.ActivateGadget(gad[0],wind,NIL);
  LOOP
    e.WaitPort(wind.userPort);
    is.GetIMes(wind,class,code,address);
    IF I.gadgetUp IN class THEN
      IF address=s.ADR(ok) THEN
        i:=10;
        WHILE i>0 DO
          DEC(i);
          ig.GetGadgetText(s.ADR(gad[i]),point);
          (*COPY(func[i],point^);*)
          bool:=TRUE;
          a:=-1;
          LOOP
            INC(a);
            IF (a>SHORT(st.Length(check[i]))) AND (a>SHORT(st.Length(s1.funcstr[i]))) THEN
              bool:=FALSE;
              EXIT;
            END;
            IF check[i,a]#s1.funcstr[i,a] THEN
              bool:=TRUE;
              EXIT;
            END;
            IF check[i,a]="\n" THEN
              bool:=FALSE;
              EXIT;
            END;
          END;
          IF bool (*(st.Occurs(s1.funcstr[i],point^)#0) OR (SHORT(st.Length(s1.funcstr[i]))#SHORT(st.Length(point^)))*) THEN
            IF s1.einz[i]#NIL THEN
              s1.einz[i].calced:=FALSE;
              s1.einz[i].refresh:=TRUE;
            END;
            a:=-1;
            WHILE a<4 DO
              INC(a);
              IF s1.ton[a,i] THEN
                IF s1.mish[i]#NIL THEN
                  s1.mish[i].refresh:=TRUE;
                END;
              END;
            END;
          END;
          a:=-1;
          WHILE a<SHORT(st.Length(point^))-1 DO
            a:=a+1;
      (*      IF s1.funcstr[i,a]#point[a] THEN
              IF s1.einz[i]#NIL THEN
                s1.einz[i].calced:=FALSE;
              END;
            END;*)
            s1.funcstr[i,a]:=point[a];
          END;
          ig.FreePlastStringGadget(gad[i],wind);
          ig.FreePlastBooleanGadget(num[i],wind);
        END;
        EXIT;
      ELSIF address=s.ADR(ca) THEN
        EXIT;
      ELSIF address=s.ADR(copy) THEN
        REPEAT
          e.WaitPort(wind.userPort);
          is.GetIMes(wind,class,code,address);
        UNTIL I.gadgetUp IN class;
        i:=-1;
        WHILE i<9 DO
          i:=i+1;
          IF address=s.ADR(num[i]) THEN
            a:=i;
            REPEAT
              e.WaitPort(wind.userPort);
              is.GetIMes(wind,class,code,address);
            UNTIL I.gadgetUp IN class;
            i:=-1;
            WHILE i<9 DO
              i:=i+1;
              IF address=s.ADR(num[i]) THEN
                ig.GetGadgetText(s.ADR(gad[a]),point);
                COPY(point^,strp[i]);
                ig.PutGadgetText(s.ADR(gad[i]),s.ADR(strp));
                I.RefreshGList(s.ADR(gad[i]),wind,NIL,1);
              END;
            END;
          END;
        END;
      END;
      i:=-1;
      WHILE i<9 DO
        i:=i+1;
        IF address=s.ADR(gad[i]) THEN
          IF i<9 THEN
            bool:=I.ActivateGadget(gad[i+1],wind,NIL);
          ELSE
            bool:=I.ActivateGadget(gad[0],wind,NIL);
          END;
        END;
      END;
    END;
  END;
  point:=NIL;
  ig.FreePlastBooleanGadget(ableit,wind);
  ig.FreePlastBooleanGadget(copy,wind);
  ig.FreePlastBooleanGadget(ca,wind);
  ig.FreePlastBooleanGadget(ok,wind);
  I.CloseWindow(wind);*)
END Eingabe;*)

PROCEDURE InitFenster*(node:l.Node);

BEGIN
  WITH node: s1.Fenster DO
    COPY(ac.GetString(ac.Window)^,node.name);
    node.wind:=NIL;
    node.xpos:=100;
    node.ypos:=20;
    node.width:=320;
    node.height:=152;
    node.inx:=4;
    node.iny:=11;
    node.xmin:=-10;
    node.xmax:=10;
    node.ymin:=-10;
    node.ymax:=10;
    node.xmins:="-10";
    node.xmaxs:="10";
    node.ymins:="-10";
    node.ymaxs:="10";
    node.oldxmin:=-10;
    node.oldxmax:=10;
    node.oldymin:=-10;
    node.oldymax:=10;
    node.oldxmins:="-10";
    node.oldxmaxs:="10";
    node.oldymins:="-10";
    node.oldymaxs:="10";
    node.grid1.col:=3;
    node.grid1.width:=1;
    node.grid1.xspace:=1;
    node.grid1.yspace:=1;
    node.grid1.xstart:=0;
    node.grid1.ystart:=0;
    node.grid1.xspaces:="1";
    node.grid1.yspaces:="1";
    node.grid1.xstarts:="0";
    node.grid1.ystarts:="0";
    node.grid2.col:=3;
    node.grid2.width:=1;
    node.grid2.muster:=3;
    node.grid2.xspace:=1;
    node.grid2.yspace:=1;
    node.grid2.xstart:=0;
    node.grid2.ystart:=0;
    node.grid2.xspaces:="1";
    node.grid2.yspaces:="1";
    node.grid2.xstarts:="0";
    node.grid2.ystarts:="0";
    node.grid1.on:=TRUE;
    node.grid1.muster:=0;
    node.scale.numsx:=1;
    node.scale.numsy:=1;
    node.scale.mark1x:=0.5;
    node.scale.mark1y:=0.5;
    node.scale.mark2x:=0.25;
    node.scale.mark2y:=0.25;
    node.scale.numsxs:="1";
    node.scale.numsys:="1";
    node.scale.mark1xs:="0.5";
    node.scale.mark1ys:="0.5";
    node.scale.mark2xs:="0.25";
    node.scale.mark2ys:="0.25";
    node.scale.col:=1;
    node.scale.muster:=0;
    node.scale.width:=1;
    node.scale.arrow:=0;
    node.scale.numson:=TRUE;
    node.scale.on:=TRUE;
    node.scale.xbezon:=TRUE;
    node.scale.ybezon:=TRUE;
    node.scale.xname:="X";
    node.scale.yname:="Y";
    node.refresh:=TRUE;
    node.funcs:=l.Create();
    node.texts:=l.Create();
    node.points:=l.Create();
    node.marks:=l.Create();
    node.areas:=l.Create();
    node.transparent:=TRUE;
    node.freeborder:=TRUE;
    node.autofuncscale:=FALSE;
    node.autoskalascale:=TRUE;
    node.autogridscale:=TRUE;
    node.mode:=0;
    node.drawmode:=0;
    node.stutz:=640;
  END;
END InitFenster;

PROCEDURE InitFunc*(node:l.Node);

BEGIN
  WITH node: s1.FensterFunc DO
    node.graphs:=l.Create();
  END;
END InitFunc;

BEGIN
  eingabeId:=-1;
  workId:=-1;
  derstr:="x";
  pxs:="0";
  COPY(ac.GetString(ac.Auto)^,pys);
  autopy:=TRUE;
  xstr:="0";
  ystr:="0";
  pxstr:="0";
  pystr:="0";
END SuperCalcTools5.


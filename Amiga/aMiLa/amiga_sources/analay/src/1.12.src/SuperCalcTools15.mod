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


MODULE SuperCalcTools15;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       p  : Printer,
       l  : LinkedLists,
       ol : OberonLib,
       mt : MathTrans,
       es : ExecSupport,
       wm : WindowManager,
       gm : GadgetManager,
       it : IntuitionTools,
       tt : TextTools,
       vt : VectorTools,
       ag : AmigaGuideTools,
       ac : AnalayCatalog,
       st : Strings,
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
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    i,a     : INTEGER;
    areaId* : INTEGER;
    actarea : l.List;


PROCEDURE * PrintAreaDim(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(actarea,num);
  IF node#NIL THEN
    WITH node: s1.AreaDim DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintAreaDim;

PROCEDURE ChangeArea*(p,area:l.Node):BOOLEAN;

VAR wind   : I.WindowPtr;
    rast   : g.RastPortPtr;
    ok,ca,
    help,
    add,del,
    xachse,
    yachse,
    xval,yval,
    func,point,
    mark,line,
    location,
    select,
    funcstr,
    xcoord,
    ycoord,
    include,
    string,
    bername,
    clearb,
    back,
    up,down,
    scroll : I.GadgetPtr;
    arealist,
    palette: l.Node;
(*    palette: ARRAY 16 OF I.GadgetPtr;*)
    ret    : BOOLEAN;
    loctext : ARRAY 2 OF ARRAY 80 OF CHAR;
    loctext4: ARRAY 4 OF ARRAY 80 OF CHAR;
    do4    : BOOLEAN;
    node,
    node2,
    actdim,
    savearea : l.Node;
    pose,
    acte   : INTEGER;
    sintab : ARRAY 300 OF INTEGER;
    locpos,
    x,y    : INTEGER;
    bool   : BOOLEAN;

PROCEDURE RefreshRadios;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      IF actdim.type#0 THEN
        EXCL(xachse.flags,I.selected);
(*        gm.DeActivateBool(xachse,wind);*)
      END;
      IF actdim.type#1 THEN
        EXCL(yachse.flags,I.selected);
(*        gm.DeActivateBool(yachse,wind);*)
      END;
      IF actdim.type#2 THEN
        EXCL(xval.flags,I.selected);
(*        gm.DeActivateBool(xval,wind);*)
      END;
      IF actdim.type#3 THEN
        EXCL(yval.flags,I.selected);
(*        gm.DeActivateBool(yval,wind);*)
      END;
      IF actdim.type#4 THEN
        EXCL(func.flags,I.selected);
(*        gm.DeActivateBool(func,wind);*)
      END;
      IF actdim.type#5 THEN
        EXCL(point.flags,I.selected);
(*        gm.DeActivateBool(point,wind);*)
      END;
      IF actdim.type#6 THEN
        EXCL(mark.flags,I.selected);
(*        gm.DeActivateBool(mark,wind);*)
      END;
(*      IF actdim.type#7 THEN
        gm.DeActivateBool(line,wind);
      END;*)
    END;
  ELSE
    EXCL(xachse.flags,I.selected);
    EXCL(yachse.flags,I.selected);
    EXCL(xval.flags,I.selected);
    EXCL(yval.flags,I.selected);
    EXCL(func.flags,I.selected);
    EXCL(point.flags,I.selected);
    EXCL(mark.flags,I.selected);
(*    gm.DeActivateBool(xachse,wind);
    gm.DeActivateBool(yachse,wind);
    gm.DeActivateBool(xval,wind);
    gm.DeActivateBool(yval,wind);
    gm.DeActivateBool(func,wind);
    gm.DeActivateBool(point,wind);
    gm.DeActivateBool(mark,wind);
(*    gm.DeActivateBool(line,wind);*)*)
  END;
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      IF actdim.type=0 THEN
        INCL(xachse.flags,I.selected);
(*        gm.ActivateBool(xachse,wind);*)
      ELSIF actdim.type=1 THEN
        INCL(yachse.flags,I.selected);
(*        gm.ActivateBool(yachse,wind);*)
      ELSIF actdim.type=2 THEN
        INCL(xval.flags,I.selected);
(*        gm.ActivateBool(xval,wind);*)
      ELSIF actdim.type=3 THEN
        INCL(yval.flags,I.selected);
(*        gm.ActivateBool(yval,wind);*)
      ELSIF actdim.type=4 THEN
        INCL(func.flags,I.selected);
(*        gm.ActivateBool(func,wind);*)
      ELSIF actdim.type=5 THEN
        INCL(point.flags,I.selected);
(*        gm.ActivateBool(point,wind);*)
      ELSIF actdim.type=6 THEN
        INCL(mark.flags,I.selected);
(*        gm.ActivateBool(mark,wind);*)
(*      ELSIF actdim.type=7 THEN
        gm.ActivateBool(line,wind);*)
      END;
    END;
  END;
  I.RefreshGList(xachse,wind,NIL,7);
END RefreshRadios;

(*PROCEDURE RefreshDims;

VAR node : l.Node;
    str  : ARRAY 24 OF CHAR;

BEGIN
  node:=area(s1.Area).dims.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=pose) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;

  g.SetAPen(rast,1);
  i:=-1;
  LOOP
    INC(i);
    IF i>4 THEN
      EXIT;
    END;
    IF node#NIL THEN
      IF node=actdim THEN
        g.SetAPen(rast,3);
        g.RectFill(rast,30,42+i*10,266,51+i*10);
        g.SetAPen(rast,2);
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,30,42+i*10,266,51+i*10);
        g.SetAPen(rast,1);
      END;
      str:="                        ";
      COPY(node(s1.AreaDim).name,str);
      tt.Print(30,49+i*10,str,rast);
      node:=node.next;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,30,42+i*10,266,51+i*10);
    END;
  END;
  IF area(s1.Area).dims.nbElements()=0 THEN
    g.SetAPen(rast,0);
    g.RectFill(rast,30,42,266,91);
    g.SetAPen(rast,2);
    tt.Print(46,70,"Keine Elemente",rast);
  END;
END RefreshDims;*)

PROCEDURE RefreshData;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      g.SetAPen(rast,0);
      g.RectFill(rast,292,143,370,150);
      g.SetAPen(rast,2);
      IF actdim.type=4 THEN
        tt.Print(292,149,ac.GetString(ac.Function),rast);
      ELSIF actdim.type=5 THEN
        tt.Print(292,149,ac.GetString(ac.Point),rast);
      ELSIF actdim.type=6 THEN
        tt.Print(292,149,ac.GetString(ac.Marker),rast);
(*      ELSIF actdim.type=7 THEN
        tt.Print(292,149,ac.GetString(ac.Line),rast);*)
      END;
      gm.PutGadgetText(string,actdim.name);
      gm.PutGadgetText(funcstr,actdim.string);
      gm.PutGadgetText(xcoord,actdim.xcoords);
      gm.PutGadgetText(ycoord,actdim.ycoords);
      IF actdim.type<=1 THEN
        INCL(select.flags,I.gadgDisabled);
        INCL(funcstr.flags,I.gadgDisabled);
        INCL(xcoord.flags,I.gadgDisabled);
        INCL(ycoord.flags,I.gadgDisabled);
      ELSIF actdim.type=2 THEN
        INCL(select.flags,I.gadgDisabled);
        INCL(funcstr.flags,I.gadgDisabled);
        EXCL(xcoord.flags,I.gadgDisabled);
        INCL(ycoord.flags,I.gadgDisabled);
      ELSIF actdim.type=3 THEN
        INCL(select.flags,I.gadgDisabled);
        INCL(funcstr.flags,I.gadgDisabled);
        INCL(xcoord.flags,I.gadgDisabled);
        EXCL(ycoord.flags,I.gadgDisabled);
      ELSIF actdim.type=4 THEN
(*        select.gadgetText.iText:=s.ADR("Funktion auswählen");*)
        EXCL(select.flags,I.gadgDisabled);
        EXCL(funcstr.flags,I.gadgDisabled);
        INCL(xcoord.flags,I.gadgDisabled);
        INCL(ycoord.flags,I.gadgDisabled);
      ELSIF actdim.type=6 THEN
(*        select.gadgetText.iText:=s.ADR("Markierung auswählen");*)
        EXCL(select.flags,I.gadgDisabled);
        EXCL(funcstr.flags,I.gadgDisabled);
        EXCL(xcoord.flags,I.gadgDisabled);
        INCL(ycoord.flags,I.gadgDisabled);
      ELSIF actdim.type>=5 THEN
(*        IF actdim.type=5 THEN
          select.gadgetText.iText:=s.ADR("Punkt auswählen");
        ELSE
          select.gadgetText.iText:=s.ADR("Linie auswählen");
        END;*)
        EXCL(select.flags,I.gadgDisabled);
        EXCL(funcstr.flags,I.gadgDisabled);
        EXCL(xcoord.flags,I.gadgDisabled);
        EXCL(ycoord.flags,I.gadgDisabled);
      END;
      I.RefreshGList(select,wind,NIL,5);
    END;
  END;
END RefreshData;

PROCEDURE GetData;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      gm.GetGadgetText(string,actdim.name);
      gm.GetGadgetText(funcstr,actdim.string);
      gm.GetGadgetText(xcoord,actdim.xcoords);
      gm.GetGadgetText(ycoord,actdim.ycoords);
      actdim.xcoord:=f.ExpressionToReal(actdim.xcoords);
      actdim.ycoord:=f.ExpressionToReal(actdim.ycoords);
    END;
  END;
END GetData;

PROCEDURE RefreshLocText;

VAR i : INTEGER;

BEGIN
  do4:=FALSE;
  IF actdim=NIL THEN
    COPY(ac.GetString(ac.NoElementSelected)^,loctext[0]);
    COPY(ac.GetString(ac.NoElementSelected)^,loctext[1]);
    locpos:=0;
  ELSE
    WITH actdim: s1.AreaDim DO
      IF actdim.type=0 THEN
        COPY(ac.GetString(ac.AboveXAxis)^,loctext[0]);
        COPY(ac.GetString(ac.BelowXAxis)^,loctext[1]);
        IF actdim.up THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
      ELSIF actdim.type=1 THEN
        COPY(ac.GetString(ac.RightOfYAxis)^,loctext[0]);
        COPY(ac.GetString(ac.LeftOfYAxis)^,loctext[1]);
        IF actdim.right THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
      ELSIF actdim.type=2 THEN
        COPY(ac.GetString(ac.RightOfXValue)^,loctext[0]);
        COPY(ac.GetString(ac.LeftOfXValue)^,loctext[1]);
        IF actdim.right THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
      ELSIF actdim.type=3 THEN
        COPY(ac.GetString(ac.AboveYValue)^,loctext[0]);
        COPY(ac.GetString(ac.BelowYValue)^,loctext[1]);
        IF actdim.up THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
      ELSIF actdim.type=4 THEN
        COPY(ac.GetString(ac.AboveFunction)^,loctext[0]);
        COPY(ac.GetString(ac.BelowFunction)^,loctext[1]);
        IF actdim.up THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
      ELSIF actdim.type=5 THEN
        do4:=TRUE;
        COPY(ac.GetString(ac.RightAboveP)^,loctext4[0]);
        COPY(ac.GetString(ac.LeftAboveP)^,loctext4[1]);
        COPY(ac.GetString(ac.RightBelowP)^,loctext4[2]);
        COPY(ac.GetString(ac.LeftBelowP)^,loctext4[3]);
        IF actdim.up THEN
          IF actdim.right THEN
            locpos:=0;
          ELSE
            locpos:=1;
          END;
        ELSE
          IF actdim.right THEN
            locpos:=2;
          ELSE
            locpos:=3;
          END;
        END;
      ELSIF actdim.type=6 THEN
        COPY(ac.GetString(ac.RightOfMarker)^,loctext[0]);
        COPY(ac.GetString(ac.LeftOfMarker)^,loctext[1]);
        IF actdim.right THEN
          locpos:=0;
        ELSE
          locpos:=1;
        END;
(*      ELSIF actdim.type=7 THEN
        loctext[0]:="Überhalb der Linie";
        loctext[1]:="Unterhalb der Linie";
        locpos:=0;*)
      END;
    END;
  END;
  i:=0;
  REPEAT
    IF do4 THEN
      gm.CyclePressed(location,wind,loctext4,i);
    ELSE
      gm.CyclePressed(location,wind,loctext,i);
    END;
  UNTIL i=locpos;
END RefreshLocText;

PROCEDURE PlotField;

VAR x,y  : INTEGER;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      g.SetAPen(rast,0);
      g.RectFill(rast,296,57,533,122);
      IF actdim.type=0 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.SetAPen(rast,2);
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
(*        s1.DrawArrow(rast,533,89,0,1,2);*)
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
      ELSIF actdim.type=1 THEN
        g.SetAPen(rast,2);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,2);*)
        g.SetAPen(rast,1);
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
      ELSIF actdim.type=2 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
        g.SetAPen(rast,2);
        g.Move(rast,450,57);
        g.Draw(rast,450,122);
      ELSIF actdim.type=3 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
        g.SetAPen(rast,2);
        g.Move(rast,296,79);
        g.Draw(rast,533,79);
      ELSIF actdim.type=4 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
        g.SetAPen(rast,2);
        IF sintab[0]=-1 THEN
          FOR x:=296 TO 533 DO
            sintab[x-296]:=89+SHORT(SHORT(10*mt.Sin(x/10)));
          END;
        END;
        g.Move(rast,296,sintab[0]);
        FOR x:=297 TO 533 DO
          g.Draw(rast,x,sintab[x-296]);
        END;
      ELSIF actdim.type=5 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
        g.SetAPen(rast,2);
        g.Move(rast,450,57);
        g.Draw(rast,450,122);
        g.Move(rast,296,79);
        g.Draw(rast,533,79);
        tt.Print(452,77,s.ADR("P(x|y)"),rast);
        g.SetAPen(rast,1);
        g.Move(rast,450,77);
        g.Draw(rast,450,81);
        g.Move(rast,446,79);
        g.Draw(rast,454,79);
      ELSIF actdim.type=6 THEN
        g.SetAPen(rast,1);
        g.Move(rast,410,57);
        g.Draw(rast,410,122);
        vt.DrawVectorObject(rast,s1.arrows[0],410,57,21,11,90,1,1);
(*        s1.DrawArrow(rast,410,57,0,0,1);*)
        g.SetAPen(rast,1);
        g.Move(rast,296,89);
        g.Draw(rast,533,89);
        vt.DrawVectorObject(rast,s1.arrows[0],533,89,21,11,0,1,1);
(*        s1.DrawArrow(rast,533,89,0,1,1);*)
        g.SetAPen(rast,2);
        g.Move(rast,450,57);
        g.Draw(rast,450,122);
        tt.Print(452,67,s.ADR("M x=a"),rast);
      END;
    END;
  ELSE
    g.SetAPen(rast,0);
    g.RectFill(rast,296,57,533,122);
  END;
END PlotField;

PROCEDURE RefreshField;

VAR x,y  : INTEGER;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      g.SetDrMd(rast,SHORTSET{g.complement});
      IF actdim.type=0 THEN
        IF actdim.up THEN
          g.RectFill(rast,296,57,533,88);
        ELSIF actdim.down THEN
          g.RectFill(rast,296,90,533,122);
        END;
      ELSIF actdim.type=1 THEN
        IF actdim.right THEN
          g.RectFill(rast,411,57,533,122);
        ELSIF actdim.left THEN
          g.RectFill(rast,296,57,409,122);
        END;
      ELSIF actdim.type=2 THEN
        IF actdim.right THEN
          g.RectFill(rast,451,57,533,122);
        ELSIF actdim.left THEN
          g.RectFill(rast,296,57,449,122);
        END;
      ELSIF actdim.type=3 THEN
        IF actdim.up THEN
          g.RectFill(rast,296,57,533,78);
        ELSIF actdim.down THEN
          g.RectFill(rast,296,80,533,122);
        END;
      ELSIF actdim.type=4 THEN
        IF actdim.up THEN
          FOR x:=296 TO 533 DO
            g.Move(rast,x,sintab[x-296]-1);
            g.Draw(rast,x,57);
          END;
        ELSIF actdim.down THEN
          FOR x:=296 TO 533 DO
            g.Move(rast,x,sintab[x-296]+1);
            g.Draw(rast,x,122);
          END;
        END;
      ELSIF actdim.type=5 THEN
        IF actdim.up THEN
          IF actdim.right THEN
            g.RectFill(rast,451,57,533,78);
          ELSIF actdim.left THEN
            g.RectFill(rast,296,57,449,78);
          END;
        ELSIF actdim.down THEN
          IF actdim.right THEN
            g.RectFill(rast,451,80,533,122);
          ELSIF actdim.left THEN
            g.RectFill(rast,296,80,449,122);
          END;
        END;
      ELSIF actdim.type=6 THEN
        IF actdim.right THEN
          g.RectFill(rast,451,57,533,122);
        ELSIF actdim.left THEN
          g.RectFill(rast,296,57,449,122);
        END;
      END;
      g.SetDrMd(rast,g.jam1);
    END;
  END;
END RefreshField;

PROCEDURE CheckField(x,y:INTEGER);

BEGIN
  IF actdim#NIL THEN
    WITH actdim: s1.AreaDim DO
      IF (x>=296) AND (x<=533) AND (y>=57) AND(y<=122) THEN
        RefreshField;
        IF actdim.type=0 THEN
          IF y<89 THEN
            actdim.up:=TRUE;
            actdim.down:=FALSE;
          ELSIF y>89 THEN
            actdim.up:=FALSE;
            actdim.down:=TRUE;
          END;
        ELSIF actdim.type=1 THEN
          IF x>410 THEN
            actdim.right:=TRUE;
            actdim.left:=FALSE;
          ELSIF x<410 THEN
            actdim.right:=FALSE;
            actdim.left:=TRUE;
          END;
        ELSIF actdim.type=2 THEN
          IF x>450 THEN
            actdim.right:=TRUE;
            actdim.left:=FALSE;
          ELSIF x<450 THEN
            actdim.right:=FALSE;
            actdim.left:=TRUE;
          END;
        ELSIF actdim.type=3 THEN
          IF y<79 THEN
            actdim.up:=TRUE;
            actdim.down:=FALSE;
          ELSIF y>79 THEN
            actdim.up:=FALSE;
            actdim.down:=TRUE;
          END;
        ELSIF actdim.type=4 THEN
          IF y<sintab[x-296] THEN
            actdim.up:=TRUE;
            actdim.down:=FALSE;
          ELSIF y>sintab[x-296] THEN
            actdim.up:=FALSE;
            actdim.down:=TRUE;
          END;
        ELSIF actdim.type=5 THEN
          IF y<79 THEN
            actdim.up:=TRUE;
            actdim.down:=FALSE;
            IF x>450 THEN
              actdim.right:=TRUE;
              actdim.left:=FALSE;
            ELSIF x<450 THEN
              actdim.right:=FALSE;
              actdim.left:=TRUE;
            END;
          ELSIF y>79 THEN
            actdim.up:=FALSE;
            actdim.down:=TRUE;
            IF x>450 THEN
              actdim.right:=TRUE;
              actdim.left:=FALSE;
            ELSIF x<450 THEN
              actdim.right:=FALSE;
              actdim.left:=TRUE;
            END;
          END;
        ELSIF actdim.type=6 THEN
          IF x>450 THEN
            actdim.right:=TRUE;
            actdim.left:=FALSE;
          ELSIF x<450 THEN
            actdim.right:=FALSE;
            actdim.left:=TRUE;
          END;
        END;
        RefreshField;
      END;
    END;
  END;
END CheckField;

PROCEDURE RefreshAreaDim;

BEGIN
  IF actdim#NIL THEN
    gm.PutGadgetText(string,actdim(s1.AreaDim).name);
    I.RefreshGList(string,wind,NIL,1);
    bool:=I.ActivateGadget(string^,wind,NIL);
  END;
END RefreshAreaDim;

PROCEDURE NewAreaDimList;

BEGIN
  gm.SetListViewParams(arealist,26,40,260,44,SHORT(area(s1.Area).dims.nbElements()),s1.GetNodeNumber(area(s1.Area).dims,actdim),PrintAreaDim);
  gm.SetCorrectPosition(arealist);
  gm.RefreshListView(arealist);
END NewAreaDimList;

PROCEDURE RefreshAll;

BEGIN
  RefreshRadios;
  RefreshAreaDim;
  NewAreaDimList;
(*  RefreshDims;*)
  RefreshData;
  RefreshLocText;
  PlotField;
  RefreshField;
END RefreshAll;

PROCEDURE RefreshPatternBorders;

BEGIN
  FOR i:=0 TO 6 DO
    IF area(s1.Area).pattern=i THEN
      it.DrawBorderIn(rast,292+i*34,194,30,20);
    ELSE
      it.DrawBorder(rast,292+i*34,194,30,20);
    END;
  END;
END RefreshPatternBorders;

BEGIN
  ret:=FALSE;
  IF areaId=-1 THEN
    areaId:=wm.InitWindow(20,10,564,256,ac.GetString(ac.ChangeHatching),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove,I.intuiTicks},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,235,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(450,235,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,235,100,14,ac.GetString(ac.Help));
  add:=gm.SetBooleanGadget(26,99,260,14,ac.GetString(ac.NewElement));
  del:=gm.SetBooleanGadget(26,114,260,14,ac.GetString(ac.DelElement));
  COPY(ac.GetString(ac.NoElementSelected)^,loctext[0]);
  COPY(ac.GetString(ac.NoElementSelected)^,loctext[1]);
  location:=gm.SetCycleGadget(292,125,246,14,loctext[0]);
  xachse:=gm.SetRadioGadget(136,129);
  yachse:=gm.SetRadioGadget(136,139);
  xval:=gm.SetRadioGadget(136,149);
  yval:=gm.SetRadioGadget(136,159);
  func:=gm.SetRadioGadget(269,129);
  point:=gm.SetRadioGadget(269,139);
  mark:=gm.SetRadioGadget(269,149);
(*  line:=gm.SetRadioGadget(269,159);*)
  palette:=gm.SetPaletteGadget(26,194,240,20,s1.screen.rastPort.bitMap.depth,area(s1.Area).colf);
(*  gm.SetPaletteGadgetOld(26,207,s1.screen.bitMap.depth,palette);*)
  select:=gm.SetBooleanGadget(522,140,16,14,s.ADR("A"));
  string:=gm.SetStringGadget(26,84,248,14,255);
  funcstr:=gm.SetStringGadget(382,140,128,14,255);
  xcoord:=gm.SetStringGadget(302,155,96,14,255);
  ycoord:=gm.SetStringGadget(430,155,96,14,255);
  bername:=gm.SetStringGadget(398,30,128,14,255);
  clearb:=gm.SetCheckBoxGadget(240,215,26,9,area(s1.Area).clearb);
  back:=gm.SetCheckBoxGadget(500,215,26,9,area(s1.Area).areab);
  arealist:=gm.SetListView(26,40,260,44,0,0,PrintAreaDim);
(*  up:=gm.SetArrowUpGadget(270,74);
  down:=gm.SetArrowDownGadget(270,84);
  scroll:=gm.SetPropGadget(270,40,16,34,0,0,0,32767);*)
  gm.EndGadgets;
  wm.SetGadgets(areaId,ok);
  wm.ChangeScreen(areaId,s1.screen);
  wind:=wm.OpenWindow(areaId);
  IF wind#NIL THEN
    WITH area: s1.Area DO
      rast:=wind.rPort;
      g.SetDrMd(rast,g.jam1);

      NEW(savearea(s1.Area));
      s1.InitNode(savearea);
      s1.CopyNode(area,savearea);

      gm.DrawPropBorders(wind);
(*      gm.DrawPaletteBorders(rast,26,207);*)

      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.HatchingBounds),rast);
      tt.Print(20,179,ac.GetString(ac.HatchingDesign),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.BoundaryElements),rast);
      tt.Print(292,52,ac.GetString(ac.CurrentElement),rast);
      tt.Print(26,136,ac.GetString(ac.XAxis),rast);
      tt.Print(26,146,ac.GetString(ac.YAxis),rast);
      tt.Print(26,156,ac.GetString(ac.XValue),rast);
      tt.Print(26,166,ac.GetString(ac.YValue),rast);
      tt.Print(159,136,ac.GetString(ac.Function),rast);
      tt.Print(159,146,ac.GetString(ac.Point),rast);
      tt.Print(159,156,ac.GetString(ac.Marker),rast);
(*      tt.Print(159,166,"Linie",rast);*)
      tt.Print(292,149,ac.GetString(ac.Function),rast);
      tt.Print(292,164,s.ADR("x"),rast);
      tt.Print(420,164,s.ADR("y"),rast);
      tt.Print(292,39,ac.GetString(ac.HatchingName),rast);
      tt.Print(26,191,ac.GetString(ac.Color),rast);
      tt.Print(292,191,ac.GetString(ac.Pattern),rast);
      tt.Print(26,223,ac.GetString(ac.ClearBackground),rast);
      tt.Print(292,223,ac.GetString(ac.HatchingToTheBack),rast);

      it.DrawBorder(rast,14,16,536,216);
      it.DrawBorder(rast,20,28,524,143);
(*      it.DrawBorder(rast,26,40,244,54);*)
      it.DrawBorder(rast,292,55,246,70);
      it.DrawBorder(rast,20,182,524,47);

      g.SetAPen(rast,1);
      FOR i:=0 TO 6 DO
        g.SetAfPt(rast,s.ADR(s1.areas[i].pattern),4);
        g.RectFill(rast,292+i*34,194,321+i*34,213);
      END;
      g.SetAfPt(rast,NIL,4);
      RefreshPatternBorders;

      gm.SetCorrectWindow(arealist,wind);
      gm.SetNoEntryText(arealist,ac.GetString(ac.None),ac.GetString(ac.ElementsEx));
      gm.SetCorrectWindow(palette,wind);
      gm.RefreshPaletteGadget(palette);

      sintab[0]:=-1;
      actarea:=area.dims;
      actdim:=area.dims.head;
      RefreshAll;
      IF actdim#NIL THEN
(*        IF actdim(s1.AreaDim).include THEN
          gm.ActivateBool(include,wind);
        END;*)
        bool:=I.ActivateGadget(string^,wind,NIL);
      END;
      gm.PutGadgetText(bername,area.name);
      I.RefreshGList(bername,wind,NIL,1);
(*      IF area.clearb THEN
        gm.ActivateBool(clearb,wind);
      END;*)

      RefreshAreaDim;
      NewAreaDimList;

      LOOP
        REPEAT
          e.WaitPort(wind.userPort);
          it.GetIMes(wind,class,code,address);
        UNTIL NOT(I.mouseMove IN class) AND NOT(I.intuiTicks IN class);
        GetData;
        gm.GetGadgetText(bername,area.name);
        bool:=gm.CheckListView(arealist,class,code,address);
        IF bool THEN
          actdim:=s1.GetNode(area.dims,gm.ActEl(arealist));
          RefreshAll;
        END;
        bool:=gm.CheckPaletteGadget(palette,class,code,address);
        IF bool THEN
          area(s1.Area).colf:=gm.ActCol(palette);
        END;
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            EXIT;
          ELSIF address=add THEN
            NEW(node(s1.AreaDim));
            node(s1.AreaDim).type:=0;
            COPY(ac.GetString(ac.XAxis)^,node(s1.AreaDim).name);
            node(s1.AreaDim).object:=NIL;
            COPY(ac.GetString(ac.XAxis)^,node(s1.AreaDim).string);
            node(s1.AreaDim).xcoord:=0;
            node(s1.AreaDim).ycoord:=0;
            node(s1.AreaDim).xcoords:="0";
            node(s1.AreaDim).ycoords:="0";
            node(s1.AreaDim).up:=TRUE;
            node(s1.AreaDim).down:=FALSE;
            node(s1.AreaDim).left:=FALSE;
            node(s1.AreaDim).right:=FALSE;
            node(s1.AreaDim).include:=FALSE;
            area.dims.AddTail(node);
            actdim:=node;
            RefreshAll;
          ELSIF address=del THEN
            IF actdim#NIL THEN
              node:=NIL;
              IF actdim.next#NIL THEN
                node:=actdim.next;
              ELSIF actdim.prev#NIL THEN
                node:=actdim.prev;
              END;
              actdim.Remove;
              actdim:=node;
            END;
            RefreshAll;
          ELSIF address=select THEN
            IF actdim#NIL THEN
              WITH actdim: s1.AreaDim DO
                IF actdim.type=4 THEN
                  actdim.object:=s2.SelectNode(s1.terms,ac.GetString(ac.SelectFunction),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.FunctionsAreEntered));
                  IF actdim.object#NIL THEN
                    COPY(actdim.object(s1.Term).string,actdim.string);
                  END;
                ELSIF actdim.type=5 THEN
                  actdim.object:=s2.SelectNode(p(s1.Fenster).points,ac.GetString(ac.SelectPoint),ac.GetString(ac.InThisWindowNo),ac.GetString(ac.PointsAreDisplayed));
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
                  actdim.object:=s2.SelectNode(p(s1.Fenster).marks,ac.GetString(ac.SelectMarker),ac.GetString(ac.InThisWindowNo),ac.GetString(ac.MarkersAreDisplayed));
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
                RefreshAll;
              END;
            END;
          ELSIF address=bername THEN
            IF actdim#NIL THEN
              bool:=I.ActivateGadget(string^,wind,NIL);
            ELSE
              bool:=I.ActivateGadget(bername^,wind,NIL);
            END;
          ELSIF address=string THEN
            IF actdim#NIL THEN
              WITH actdim: s1.AreaDim DO
                IF actdim.type>=4 THEN
                  bool:=I.ActivateGadget(funcstr^,wind,NIL);
                ELSIF actdim.type=2 THEN
                  bool:=I.ActivateGadget(xcoord^,wind,NIL);
                ELSIF actdim.type=3 THEN
                  bool:=I.ActivateGadget(ycoord^,wind,NIL);
                ELSE
                  bool:=I.ActivateGadget(string^,wind,NIL);
                END;
              END;
            END;
          ELSIF address=funcstr THEN
            IF actdim#NIL THEN
              WITH actdim: s1.AreaDim DO
                IF (actdim.type>=5) THEN
                  bool:=I.ActivateGadget(xcoord^,wind,NIL);
                ELSE
                  bool:=I.ActivateGadget(string^,wind,NIL);
                END;
                IF actdim.type=4 THEN
                  actdim.object:=NIL;
                END;
              END;
            END;
          ELSIF address=xcoord THEN
            IF actdim#NIL THEN
              WITH actdim: s1.AreaDim DO
                IF (actdim.type=5) OR (actdim.type=7) THEN
                  bool:=I.ActivateGadget(ycoord^,wind,NIL);
                ELSE
                  bool:=I.ActivateGadget(string^,wind,NIL);
                END;
              END;
            END;
          ELSIF address=ycoord THEN
            IF actdim#NIL THEN
              WITH actdim: s1.AreaDim DO
                bool:=I.ActivateGadget(string^,wind,NIL);
              END;
            END;
          ELSIF address=location THEN
            IF do4 THEN
              gm.CyclePressed(location,wind,loctext4,locpos);
            ELSE
              gm.CyclePressed(location,wind,loctext,locpos);
            END;
            IF actdim#NIL THEN
              RefreshField;
              WITH actdim: s1.AreaDim DO
                IF (actdim.type=0) OR (actdim.type=3) OR (actdim.type=4) THEN
                  IF locpos=0 THEN
                    actdim.up:=TRUE;
                    actdim.down:=FALSE;
                  ELSIF locpos=1 THEN
                    actdim.up:=FALSE;
                    actdim.down:=TRUE;
                  END;
                ELSIF actdim.type#5 THEN
                  IF locpos=0 THEN
                    actdim.right:=TRUE;
                    actdim.left:=FALSE;
                  ELSIF locpos=1 THEN
                    actdim.right:=FALSE;
                    actdim.left:=TRUE;
                  END;
                ELSIF actdim.type=5 THEN
                  IF locpos=0 THEN
                    actdim.up:=TRUE;
                    actdim.down:=FALSE;
                    actdim.right:=TRUE;
                    actdim.left:=FALSE;
                  ELSIF locpos=1 THEN
                    actdim.up:=TRUE;
                    actdim.down:=FALSE;
                    actdim.right:=FALSE;
                    actdim.left:=TRUE;
                  ELSIF locpos=2 THEN
                    actdim.up:=FALSE;
                    actdim.down:=TRUE;
                    actdim.right:=TRUE;
                    actdim.left:=FALSE;
                  ELSIF locpos=3 THEN
                    actdim.up:=FALSE;
                    actdim.down:=TRUE;
                    actdim.right:=FALSE;
                    actdim.left:=TRUE;
                  END;
                END;
              END;
(*              PlotField;*)
              RefreshField;
            END;
(*          ELSIF address=include THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).include:=NOT(actdim(s1.AreaDim).include);
            END;*)
          ELSIF address=clearb THEN
            area.clearb:=NOT(area.clearb);
          ELSIF address=back THEN
            area.areab:=NOT(area.areab);
          ELSIF address=xachse THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=0;
              COPY(ac.GetString(ac.XAxis)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=TRUE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=FALSE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=yachse THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=1;
              COPY(ac.GetString(ac.YAxis)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=FALSE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=TRUE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=xval THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=2;
              COPY(ac.GetString(ac.XValue)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=FALSE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=TRUE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=yval THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=3;
              COPY(ac.GetString(ac.YValue)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=TRUE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=FALSE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=func THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=4;
              COPY(ac.GetString(ac.Function)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=TRUE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=FALSE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=point THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=5;
              COPY(ac.GetString(ac.Point)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=TRUE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=TRUE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
          ELSIF address=mark THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=6;
              COPY(ac.GetString(ac.Marker)^,actdim(s1.AreaDim).name);
              actdim(s1.AreaDim).up:=FALSE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=TRUE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;
(*          ELSIF address=line THEN
            IF actdim#NIL THEN
              actdim(s1.AreaDim).type:=7;
              actdim(s1.AreaDim).name:="Linie";
              actdim(s1.AreaDim).up:=TRUE;
              actdim(s1.AreaDim).down:=FALSE;
              actdim(s1.AreaDim).right:=TRUE;
              actdim(s1.AreaDim).left:=FALSE;
            END;
            RefreshAll;*)
          END;
        ELSIF I.mouseButtons IN class THEN
          IF code=I.selectDown THEN
            it.GetMousePos(wind,x,y);
(*            IF (x>28) AND (x<268) AND (y>41) AND (y<93) THEN
              y:=y-41;
              y:=y DIV 10;
              acte:=y+pose;
              INC(acte);
              REPEAT
                DEC(acte);
                node:=s1.GetNode(area.dims,acte);
              UNTIL (node#NIL) OR (acte=-1);
              actdim:=node;
              RefreshAll;
            END;*)
            IF (x>=296) AND (x<=533) AND (y>=57) AND(y<=122) THEN
              CheckField(x,y);
              RefreshLocText;
            ELSIF (x>=292) AND (x<526) AND (y>=194) AND (y<214) THEN
              DEC(x,292);
              x:=x DIV 34;
              area.pattern:=x;
              RefreshPatternBorders;
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"areas",wind);
        END;
      END;

      wm.CloseWindow(areaId);
    END;
  END;
  wm.FreeGadgets(areaId);
  IF NOT(ret) THEN
    s1.CopyNode(savearea,area);
  END;
  RETURN ret;
END ChangeArea;

BEGIN
  areaId:=-1;
END SuperCalcTools15.







































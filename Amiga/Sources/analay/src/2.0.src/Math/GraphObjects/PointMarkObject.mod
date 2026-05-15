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


MODULE PointMarkObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       st : Strings,
       as : ASL,
       ac : AnalayCatalog,
       at : AslTools,
       tt : TextTools,
       gt : GraphicsTools,
       wm : WindowManager,
       fm : FontManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       co : Coords,
       dc : DisplayConversion,
       go : GraphicObjects,
       cf : CoordFormat,
       cb : CoordObject,
       gb : GraphObject,
       NoGuruRq;

TYPE PointMarkObject * = POINTER TO PointMarkObjectDesc;
     PointMarkObjectDesc * = RECORD(gb.GraphObjectDesc);
     END;

     PointObject * = POINTER TO PointObjectDesc;
     PointObjectDesc * = RECORD(PointMarkObjectDesc)
       point   * : INTEGER;
       fill    * : BOOLEAN;
     END;

     MarkObject * = POINTER TO MarkObjectDesc;
     MarkObjectDesc * = RECORD(PointMarkObjectDesc)
       pattern    * ,
       thickness  * ,
       textdir    * ,
       textside   * : INTEGER;
     END;

PROCEDURE (pointobj:PointObject) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable);

VAR worldx,worldy   : LONGREAL;
    font            : fm.Font;
    string          : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    stdpicx,stdpicy,
    linex,liney     : INTEGER;
    xp,yp           : INTEGER;
    real            : LONGREAL;
    txBaseline      : INTEGER;
    bool            : BOOLEAN;

BEGIN
  IF pointobj.window#NIL THEN
    pointobj.GetCoordsWorld(pointobj.window.rect,worldx,worldy);
    IF pointobj.movingobject THEN
      g.SetDrMd(rast,SHORTSET{g.complement});
    ELSE
      pointobj.SetDrawModes(rast);
    END;
    font:=conv.GetFont(pointobj.font);
    bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
    stdpicx:=conv.GetStdPicX();   stdpicy:=conv.GetStdPicY();
    linex:=conv.GetThicknessX(1); liney:=conv.GetThicknessY(1);

    COPY(pointobj.string,string);
    IF pointobj.coordformat#NIL THEN
      st.Append(string,pointobj.coordformat.formatstr);
    END;
    pointobj.numberformat.ParseString(string,worldx,worldy,0);
    pointobj.GetCoordsPic(pointobj.window.rect,xp,yp);

    go.PlotPoint(rast,xp,yp,stdpicx,stdpicy,linex,liney,pointobj.fill,pointobj.point);
    font.Print(rast,xp+SHORT(SHORT(SHORT(go.points[pointobj.point].textx*stdpicx))),yp-SHORT(SHORT(SHORT(go.points[pointobj.point].texty*stdpicy))),s.ADR(string));
    IF font#pointobj.font THEN
      font.Destruct;
    END;
    g.SetDrMd(rast,g.jam1);
  END;
END Plot;

PROCEDURE (pointobj:PointObject) PlotBorder*(rast:g.RastPortPtr);

VAR real,
    worldx,worldy  : LONGREAL;
    string         : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    font           : fm.Font;
    xpos,ypos,
    width,height,i : INTEGER;
    txBaseline,
    txHeight       : INTEGER;
    bool           : BOOLEAN;

BEGIN
  font:=pointobj.font;
  bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
  bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
  pointobj.GetCoordsPic(pointobj.window.rect,xpos,ypos);
  pointobj.GetCoordsWorld(pointobj.window.rect,worldx,worldy);

  COPY(pointobj.string,string);
  IF pointobj.coordformat#NIL THEN
    st.Append(string,pointobj.coordformat.formatstr);
  END;
  pointobj.numberformat.ParseString(string,worldx,worldy,0);

  xpos:=xpos-SHORT(SHORT(SHORT(mg.mathconv.GetStdPicX()*go.points[pointobj.point].textx)));

  i:=ypos-SHORT(SHORT(SHORT(go.points[pointobj.point].texty*mg.mathconv.GetStdPicY())))-txBaseline;
  ypos:=ypos-mg.mathconv.GetStdPicY();
  IF i<ypos THEN
    ypos:=i;
  END;

  width:=SHORT(SHORT(SHORT(2*go.points[pointobj.point].textx*mg.mathconv.GetStdPicX())))+SHORT(SHORT(SHORT(font.TextWidthPix(pointobj.window.rast,s.ADR(string)))));

  i:=-mg.mathconv.GetStdPicY()+SHORT(SHORT(SHORT(go.points[pointobj.point].texty*mg.mathconv.GetStdPicY())))+(txHeight-txBaseline)-1;
  height:=2*mg.mathconv.GetStdPicY();
  IF i>height THEN
    height:=i;
  END;

  g.SetDrMd(rast,SHORTSET{g.complement});

  g.Move(rast,xpos,ypos);
  g.Draw(rast,xpos+width,ypos);
  g.Draw(rast,xpos+width,ypos+height);
  g.Draw(rast,xpos,ypos+height);
  g.Draw(rast,xpos,ypos);

  g.SetDrMd(rast,g.jam1);
END PlotBorder;

PROCEDURE (pointobj:PointObject) Clicked*(mouseX,mouseY:LONGINT):BOOLEAN;

VAR real,
    worldx,worldy  : LONGREAL;
    string         : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    font           : fm.Font;
    xpos,ypos,
    width,height,i : INTEGER;
    txBaseline,
    txHeight       : INTEGER;
    bool           : BOOLEAN;

BEGIN
  font:=pointobj.font;
  bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
  bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
  pointobj.GetCoordsPic(pointobj.window.rect,xpos,ypos);
  pointobj.GetCoordsWorld(pointobj.window.rect,worldx,worldy);

  COPY(pointobj.string,string);
  IF pointobj.coordformat#NIL THEN
    st.Append(string,pointobj.coordformat.formatstr);
  END;
  pointobj.numberformat.ParseString(string,worldx,worldy,0);

  xpos:=xpos-SHORT(SHORT(SHORT(mg.mathconv.GetStdPicX()*go.points[pointobj.point].textx)));

  i:=ypos-SHORT(SHORT(SHORT(go.points[pointobj.point].texty*mg.mathconv.GetStdPicY())))-txBaseline;
  ypos:=ypos-mg.mathconv.GetStdPicY();
  IF i<ypos THEN
    ypos:=i;
  END;

  width:=SHORT(SHORT(SHORT(2*go.points[pointobj.point].textx*mg.mathconv.GetStdPicX())))+SHORT(SHORT(SHORT(font.TextWidthPix(pointobj.window.rast,s.ADR(string)))));

  i:=-mg.mathconv.GetStdPicY()+SHORT(SHORT(SHORT(go.points[pointobj.point].texty*mg.mathconv.GetStdPicY())))+(txHeight-txBaseline)-1;
  height:=2*mg.mathconv.GetStdPicY();
  IF i>height THEN
    height:=i;
  END;

  IF (mouseX>=xpos) AND (mouseX<xpos+width) AND (mouseY>=ypos) AND (mouseY<ypos+height) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Clicked;

(*PROCEDURE (pointobj:TextObject) InitClickRect*;

VAR real       : LONGREAL;
    font       : fm.Font;
    txBaseline,
    txHeight   : INTEGER;
    bool       : BOOLEAN;

BEGIN
  IF pointobj.window.rast#NIL THEN
    font:=pointobj.font;
    bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
    bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));

    pointobj.clickrect.xoff:=0;
    pointobj.clickrect.yoff:=txBaseline-1;
    pointobj.clickrect.width:=SHORT(SHORT(SHORT(font.TextWidthPix(pointobj.window.rast,s.ADR(pointobj.string)))));
    pointobj.clickrect.height:=txHeight;
  END;
END InitClickRect;*)

PROCEDURE (markobj:MarkObject) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable);

VAR worldx,worldy   : LONGREAL;
    font            : fm.Font;
    string          : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    stdpicx,stdpicy,
    linex,liney     : INTEGER;
    xpos,ypos,i,wi,
    pos             : INTEGER;
    real            : LONGREAL;
    txBaseline      : INTEGER;
    bool            : BOOLEAN;

BEGIN
(*  IF markobj.window#NIL THEN
    markobj.GetCoordsWorld(markobj.window.rect,worldx,worldy);
    IF markobj.movingobject THEN
      g.SetDrMd(rast,SHORTSET{g.complement});
    ELSE
      markobj.SetDrawModes(rast);
    END;
    font:=conv.GetFont(markobj.font);
    bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
    stdpicx:=conv.GetStdPicX();   stdpicy:=conv.GetStdPicY();
    linex:=conv.GetThicknessX(1); liney:=conv.GetThicknessY(1);

    COPY(markobj.string,string);
    IF markobj.coordformat#NIL THEN
      st.Append(string,markobj.coordformat.formatstr);
    END;
    markobj.numberformat.ParseString(string,worldx,worldy,0);
    markobj.GetCoordsPic(markobj.window.rect,xpos,ypos);

    pos:=0;
    IF linex<0 THEN
      linex:=markobj.width;
    END;
    gt.DrawLine(rast,x,topy,x,topy+height,linex,1,go.lines[markobj.line],pos);
    xpos:=x+markobj.textside*((markobj.thickness DIV 2)+2);
    IF markobj.textdir=0 THEN
      IF markobj.textside=-1 THEN
        DEC(xpos,SHORT(SHORT(SHORT(font.TextWidthPix(rast,s.ADR(string))))));
      END;
      font.Print(rast,xpos,ypos,s.ADR(string);
    ELSIF markobj.textdir=1 THEN
      wi:=0;
      FOR i:=0 TO SHORT(st.Length(string^)-1) DO
        real:=font.CharWidthPix(rast,string[pos]," ");
        IF real>wi THEN
          wi:=SHORT(SHORT(SHORT(real)));
        END;
      END;
      IF obj.textside=-1 THEN
        DEC(xpos,wi);
      END;
(*      tt.PrintTextDown(xpos,y,string,rast,obj.weltx,obj.welty,0,obj.nach,obj.exp);*)
(*    ELSIF markobj.textdir=2 THEN
      IF markobj.textside=-1 THEN
        DEC(xpos,rast.txHeight);
      END;
      IF NOT(obj.trans) THEN
        g.SetAPen(rast,obj.colb);
        g.RectFill(rast,xpos,y,xpos+rast.txHeight,y+tt.TextLength(string,rast,obj.weltx,obj.welty,0,obj.nach,obj.exp));
        g.SetAPen(rast,obj.colf);
      END;
      tt.PrintRotatedText(xpos,y,string,rast,-90,obj.weltx,obj.welty,0,obj.nach,obj.exp);
    ELSIF obj.textdir=3 THEN
      IF obj.textside=-1 THEN
        DEC(xpos,rast.txHeight);
      END;
      IF NOT(obj.trans) THEN
        g.SetAPen(rast,obj.colb);
        g.RectFill(rast,xpos,y,xpos+rast.txHeight,y+tt.TextLength(string,rast,obj.weltx,obj.welty,0,obj.nach,obj.exp));
        g.SetAPen(rast,obj.colf);
      END;
      tt.PrintRotatedText(xpos,y,string,rast,90,obj.weltx,obj.welty,0,obj.nach,obj.exp);*)
    END;

    IF font#markobj.font THEN
      font.Destruct;
    END;
    g.SetDrMd(rast,g.jam1);
  END;*)
END Plot;



VAR pointwind    * ,
    pointdeswind * ,
    markdeswind  * : wm.Window;

PROCEDURE PlotTextDir*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

VAR i,pos : INTEGER;

BEGIN
  g.SetAPen(rast,color);
  g.Move(rast,x+14,y+2);
  g.Draw(rast,x+14,y+37);
(*  gt.DrawLine(rast,40+num*52,124,40+num*52,159,1,1,s1.lines[0],pos);*)
  IF num=0 THEN
    tt.Print(x+16,y+10,s.ADR("x=1"),rast);
  ELSIF num=1 THEN
    tt.PrintDown(x+16,y+10,s.ADR("x=1"),rast);
  ELSIF num=2 THEN
    tt.PrintRotated(x+16,y+10-rast.txBaseline,"x=1",rast,-90);
  ELSIF num=3 THEN
    tt.PrintRotated(x+16,y+10-rast.txBaseline,"x=1",rast,90);
  END;
END PlotTextDir;

PROCEDURE PlotTextSide*(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);

VAR i,pos : INTEGER;

BEGIN
  g.SetAPen(rast,color);
  g.Move(rast,x+48,y+2);
  g.Draw(rast,x+48,y+17);
(*  gt.DrawLine(rast,74+i*106,175,74+i*106,190,1,1,s1.lines[0],pos);*)
  IF num=0 THEN
    tt.Print(x+22,y+12,s.ADR("x=0"),rast);
  ELSIF num=1 THEN
    tt.Print(x+54,y+12,s.ADR("x=0"),rast);
  END;
END PlotTextSide;

PROCEDURE (object:PointMarkObject) Change*(changetask:m.Task):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    textgad     : gmo.StringGadget;
    formatlv    : gmo.ListView;
    addformat,
    delformat   : gmo.BooleanGadget;
    palettef,
    paletteb    : gmo.PaletteGadget;
    trans       : gmo.CheckboxGadget;
    changedesign,
    font,
    numberformat: gmo.BooleanGadget;
    xpos,ypos   : gmo.StringGadget;
    snap,(*        : gmo.CheckboxGadget;*)
    coords      : gmo.CycleGadget;
    mouse       : gmo.BooleanGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    class       : LONGSET;
    msg         : m.Message;
    snaparray   : ARRAY 4 OF e.STRPTR;
    coordsarray : ARRAY 3 OF e.STRPTR;
    objname,
    windowtitle : e.STRPTR;
    node        : l.Node;
    i           : INTEGER;
    ret,bool,
    didchange   : BOOLEAN;
(*    node,
    savepoint : l.Node;
    cols      : INTEGER;
    boundpos  : INTEGER;
    table     : ARRAY 2 OF ARRAY 28 OF CHAR;
    x,y       : INTEGER;
    longx,
    longy     : LONGREAL;
    objname   : ARRAY 20 OF CHAR;
    str       : ARRAY 80 OF CHAR;*)


PROCEDURE RefreshCoords;

(* Refreshs the GADGETS! *)

VAR xcoords,ycoords : ARRAY 80 OF CHAR;

BEGIN
  object.GetCoordStrings(xcoords,ycoords);
  xpos.SetString(xcoords);
  ypos.SetString(ycoords);
  IF object.snaptype=cb.snapToFunc THEN
    ypos.Disable(TRUE);
  ELSE
    ypos.Disable(FALSE);
  END;
END RefreshCoords;

PROCEDURE GetCoords;

VAR xcoords,ycoords : ARRAY 80 OF CHAR;

BEGIN
  xpos.GetString(xcoords);
  ypos.GetString(ycoords);
  object.SetCoordStrings(NIL,xcoords,ycoords);
  object.Snap;
END GetCoords;

PROCEDURE GetInput;

BEGIN
  object.Lock(FALSE);
  textgad.GetString(object.string);
  IF object.coordformat#NIL THEN
    formatlv.GetString(object.coordformat.formatstr);
  END;
  object.colorf:=SHORT(palettef.GetValue());
  object.colorb:=SHORT(paletteb.GetValue());
  object.transparent:=trans.Checked();

  object.SetSnapType(SHORT(snap.GetValue()));
(*  IF snap.Checked() THEN
    object.SetSnapType(cb.snapToNowhere);
  ELSE
    object.SetSnapType(cb.snapToFunc);
  END;*)
  GetCoords;
  object.UnLock;
END GetInput;

PROCEDURE SetData;

BEGIN
  RefreshCoords;
END SetData;

PROCEDURE RefreshLabel;

BEGIN
  IF object.coordformat#NIL THEN
    formatlv.SetValue(cf.coordformats.GetNodeNumber(object.coordformat));
    formatlv.SetString(object.coordformat.formatstr);
  ELSE
    formatlv.Refresh;
  END;
END RefreshLabel;



PROCEDURE ChangePointDes(point:PointObject):BOOLEAN;

VAR subwind  : wm.SubWindow;
    wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    root     : gmb.Root;
    points   : gmo.SelectBox;
    fill     : gmo.CheckboxGadget;
    gadobj   : gmb.Object;
    glist    : I.GadgetPtr;
    mes      : I.IntuiMessagePtr;
    oldpoint : INTEGER;
    ret      : BOOLEAN;

PROCEDURE RefreshFillCheckbox;

BEGIN
  IF (point.point=6) OR (point.point=7) THEN
    fill.Disable(FALSE);
  ELSE
    fill.Disable(TRUE);
  END;
END RefreshFillCheckbox;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF pointdeswind=NIL THEN
    pointdeswind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.PointDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=pointdeswind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.PointDesign));
      points:=gmo.SetSelectBox(ac.GetString(ac.Point),10,point.point,10,1,mg.mathconv.GetStdPicX(),mg.mathconv.GetStdPicY(),-1,gmo.horizOrient,go.PlotPointSimple);
      fill:=gmo.SetCheckboxGadget(ac.GetString(ac.FillPoint),point.fill);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  textgad.SetString(object.string);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    RefreshFillCheckbox;
    oldpoint:=point.point;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          point.fill:=fill.Checked();
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          point.point:=oldpoint;
          EXIT;
        ELSIF mes.iAddress=points THEN
          point.point:=SHORT(points.GetValue());
          RefreshFillCheckbox;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"pointdesreq",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangePointDes;

PROCEDURE ChangeMarkDes(mark:MarkObject):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    pattern,
    thickness,
    textdir,
    textside    : gmo.SelectBox;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    oldpattern,
    oldthickness,
    oldtextdir,
    oldtextside,
    i           : INTEGER;
    ret         : BOOLEAN;

PROCEDURE GetInput;

BEGIN
  mark.pattern:=SHORT(pattern.GetValue());
  mark.thickness:=SHORT(thickness.GetValue());
  mark.textdir:=SHORT(textdir.GetValue());
  mark.textside:=SHORT(textside.GetValue());
  IF mark.textside=0 THEN mark.textside:=-1; END;
END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF markdeswind=NIL THEN
    markdeswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.MarkerDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=pointwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.MarkerDesign));
      pattern:=gmo.SetSelectBox(ac.GetString(ac.MarkerPattern),10,mark.pattern,5,2,16,1,-1,gmo.horizOrient,go.PlotPatternLine);
      thickness:=gmo.SetSelectBox(ac.GetString(ac.MarkerWidth),5,mark.thickness-1,2,3,16*4,5,-1,gmo.vertOrient,go.PlotThicknessLine);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.MarkerLegend));
      textdir:=gmo.SetSelectBox(ac.GetString(ac.TextOrientation),4,mark.textdir,4,1,50,40,-1,gmo.horizOrient,PlotTextDir);
      i:=mark.textside;
      IF i=-1 THEN i:=0; END;
      textside:=gmo.SetSelectBox(ac.GetString(ac.TextSide),2,i,2,1,100,20,-1,gmo.horizOrient,PlotTextSide);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    oldpattern:=mark.pattern;
    oldthickness:=mark.thickness;
    oldtextdir:=mark.textdir;
    oldtextside:=mark.textside;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          GetInput;

          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          mark.pattern:=oldpattern;
          mark.thickness:=oldthickness;
          mark.textdir:=oldtextdir;
          mark.textside:=oldtextside;
          EXIT;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"markdesreq",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangeMarkDes;

BEGIN
  IF object IS PointObject THEN
    objname:=ac.GetString(ac.Point);
    windowtitle:=ac.GetString(ac.ChangePoint);
  ELSIF object IS MarkObject THEN
    objname:=ac.GetString(ac.Marker);
    windowtitle:=ac.GetString(ac.ChangeMarker);
  END;
  NEW(mes);
  ret:=FALSE;
  IF pointwind=NIL THEN
    pointwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,windowtitle,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=pointwind.InitSub(mg.screen);
  subwind.SetTitle(windowtitle);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,objname);
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        textgad:=gmo.SetStringGadget(ac.GetString(ac.Name),255,gmo.stringType);
        formatlv:=gmo.SetListView(ac.GetString(ac.Pattern),cf.coordformats,cf.PrintCoordFormat,SHORT(cf.coordformats.GetNodeNumber(object.coordformat)),TRUE,255);
        addformat:=gmo.SetBooleanGadget(ac.GetString(ac.NewPattern),FALSE);
        delformat:=gmo.SetBooleanGadget(ac.GetString(ac.DelPattern),FALSE);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        palettef:=gmo.SetPaletteGadget(ac.GetString(ac.ForegroundColor),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),object.colorf);
        paletteb:=gmo.SetPaletteGadget(ac.GetString(ac.BackgroundColor),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),object.colorb);
        trans:=gmo.SetCheckboxGadget(ac.GetString(ac.Transparent),object.transparent);
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,NIL);
          IF object IS PointObject THEN changedesign:=gmo.SetBooleanGadget(ac.GetString(ac.PointDesign),FALSE);
                                   ELSE changedesign:=gmo.SetBooleanGadget(ac.GetString(ac.MarkerDesign),FALSE); END;
        gmb.EndBox;
        font:=gmo.SetBooleanGadget(ac.GetString(ac.Font),FALSE);
        numberformat:=gmo.SetBooleanGadget(ac.GetString(ac.NumberFormat),FALSE);
      gmb.EndBox;
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Coordinates));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        xpos:=gmo.SetStringGadget(ac.GetString(ac.XCoord),79,gmo.realType);
        xpos.SetMinVisible(5);
        ypos:=gmo.SetStringGadget(ac.GetString(ac.YCoord),79,gmo.realType);
        ypos.SetMinVisible(5);
(*          IF object.snaptype=cb.snapToNowhere THEN bool:=FALSE; ELSE bool:=TRUE; END;
        snap:=gmo.SetCheckboxGadget(ac.GetString(ac.SnapToGraph),bool);*)
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
(*        mouse:=gmo.SetBooleanGadget(ac.GetString(ac.Mouse),FALSE);*)
        coordsarray[0]:=ac.GetString(ac.AxesCoordinates);
        coordsarray[1]:=ac.GetString(ac.ScreenCoordinates);
        coordsarray[2]:=NIL;
          IF object.GetWorld() THEN i:=0; ELSE i:=1; END;
        coords:=gmo.SetCycleGadget(NIL,s.ADR(coordsarray),i);

        snaparray[0]:=s.ADR("Snap to nowhere");
        snaparray[1]:=ac.GetString(ac.SnapToGraph);
        snaparray[2]:=NIL;
        snap:=gmo.SetCycleGadget(NIL,s.ADR(snaparray),object.snaptype);
      gmb.EndBox;
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  textgad.SetString(object.string);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    RefreshCoords;
    textgad.Activate;
    IF object.coordformat#NIL THEN
      formatlv.SetString(object.coordformat.formatstr);
    END;

(*    attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
    COPY(p.scale.attr.name^,attr.name^);
    attr.ySize:=p.scale.attr.ySize;
    attr.style:=p.scale.attr.style;*)

(* node:=p *)

(*    auto:="Auto";*)

    RefreshLabel;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF changetask.msgsig IN class THEN
        REPEAT
          msg:=changetask.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              subwind.SetScreen(mg.screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
                textgad.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
(*        GetInput;*)
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            object.window.SendNewMsg(m.msgNodeChanged,NIL);
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            IF didchange THEN
              object.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;

            EXIT;
          ELSIF mes.iAddress=addformat.gadget THEN
            node:=NIL;
            NEW(node(cf.CoordFormat));
            node.Init;
            cf.coordformats.AddTail(node);
            object.coordformat:=node(cf.CoordFormat);
            RefreshLabel;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=delformat.gadget THEN
            IF object.coordformat#NIL THEN
              node:=NIL;
              node:=object.coordformat.next;
              IF node=NIL THEN
                node:=object.coordformat.prev;
              END;
              object.coordformat.Remove;
              IF node#NIL THEN object.coordformat:=node(cf.CoordFormat);
                          ELSE object.coordformat:=NIL; END;
              RefreshLabel;
              didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF mes.iAddress=changedesign.gadget THEN
            bool:=FALSE;
            IF object IS PointObject THEN
              bool:=ChangePointDes(object(PointObject));
            ELSIF object IS MarkObject THEN
              bool:=ChangeMarkDes(object(MarkObject));
            END;
            IF bool THEN
              didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF mes.iAddress=numberformat.gadget THEN
  (*          bool:=s8.NumberFormat(point.nach,point.exp);*)
          ELSIF mes.iAddress=font.gadget THEN
  (*          bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectFontForPoint),wind,s.ADR(point.attr),at.nocols,at.nocols);*)
(*          ELSIF mes.iAddress=mouse.gadget THEN
            IF object.window#NIL THEN
              object.window.Lock(FALSE);
              REPEAT
                object.window.GetIMes(mes);
              UNTIL mes.class=LONGSET{};
              I.WindowToFront(object.window.iwind);
              I.ActivateWindow(object.window.iwind);
  
              bool:=object.Move(mes);
  
              RefreshCoords;
              I.WindowToFront(wind);
              I.ActivateWindow(wind);
              object.window.UnLock;
            END;*)
          ELSIF mes.iAddress=snap.gadget THEN
            object.SetSnapType(SHORT(snap.GetValue()));
(*            IF snap.Checked() THEN
              object.SetSnapType(cb.snapToFunc);
            ELSE
              object.SetSnapType(cb.snapToNowhere);
            END;*)
            IF object.snaptype=cb.snapToNowhere THEN
              ypos.Disable(FALSE);
            ELSE
              object.Snap;
              RefreshCoords;
              ypos.Disable(TRUE);
            END;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=coords.gadget THEN
            IF object.window#NIL THEN
              object.SetWorld(object.window.rect,~object.GetWorld());
            ELSE
              object.SetWorld(NIL,~object.GetWorld());
            END;
            RefreshCoords;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=xpos.gadget THEN
            GetCoords;
            RefreshCoords;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=ypos.gadget THEN
            GetCoords;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=formatlv.stringgad THEN
            IF object.coordformat#NIL THEN
              formatlv.GetString(object.coordformat.formatstr);
              RefreshLabel;
              didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF mes.iAddress=formatlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              object.coordformat:=cf.coordformats.GetNode(formatlv.GetValue())(cf.CoordFormat);
              RefreshLabel;
              didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF ~(mes.iAddress=root.help) THEN
            GetInput;
            didchange:=TRUE; object.window.SendNewMsg(m.msgNodeChanged,NIL);
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"points",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

(*    IF fontrequest#NIL THEN
      as.FreeAslRequest(fontrequest);
    END;
    e.FreeMem(attr.name,s.SIZE(CHAR)*256);*)

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END Change;

(*PROCEDURE RawPlotObject*(rast:g.RastPortPtr;p,obj:l.Node;setfont:BOOLEAN;x,y,topy,height,scalex,scaley,linex,liney:INTEGER;setstyle:BOOLEAN);

VAR mask,style : SHORTSET;
    xpos,ypos,
    pos,wi,i   : INTEGER;
    realx,realy: LONGREAL;
    pmat       : s1.PointMatrixPtr;
    string     : e.STRPTR;
    str        : ARRAY 2 OF CHAR;
    font       : g.TextFontPtr;

BEGIN
  WITH p: s1.Fenster DO
    WITH obj: s1.GraphObject DO
      IF setfont THEN
        IF obj.trans THEN
          g.SetDrMd(rast,g.jam1);
        ELSE
          g.SetDrMd(rast,g.jam2);
        END;
      END;
      IF setstyle THEN
        font:=gt.SetFont(rast,s.ADR(obj.attr));
        mask:=g.AskSoftStyle(rast);
        style:=g.SetSoftStyle(rast,obj.attr.style,mask);
        g.SetAPen(rast,obj.colf);
        g.SetBPen(rast,obj.colb);
      END;
      IF obj IS s1.Text THEN
        WITH obj: s1.Text DO
          tt.PrintText(x,y+rast.txBaseline,s.ADR(obj.string),rast,obj.weltx,obj.welty,0,7,FALSE);
        END;
      ELSIF obj IS s1.Point THEN
        WITH obj: s1.Point DO
          NEW(string);
          RawPlotPoint(rast,obj,x,y,scalex,scaley,linex,liney,obj.colf,obj.colb);
(*          pmat:=s1.points[obj.point];*)
(*          vt.DrawVectorObject(rast,s1.points[obj.point].data,x,y,scalex,scaley,0,1,1);*)
(*          PlotPointMatrix(p.rast,obj.picx-pmat.hotx,obj.picy-pmat.hoty,obj.point);*)
          COPY(obj.string,string^);
          st.Append(string^,obj.label(s1.Label).string);
          tt.PrintText(x+SHORT(SHORT(SHORT(s1.points[obj.point].textx*scalex))),y-SHORT(SHORT(SHORT(s1.points[obj.point].texty*scaley))),string,rast,obj.weltx,obj.welty,0,obj.nach,obj.exp);
          DISPOSE(string);
        END;
      IF setfont THEN
        g.SetDrMd(rast,g.jam1);
      END;
      IF setstyle THEN
        mask:=g.AskSoftStyle(rast);
        style:=g.SetSoftStyle(rast,SHORTSET{},mask);
        gt.CloseFont(font);
      END;
    END;
  END;
END RawPlotObject;*)

END PointMarkObject.


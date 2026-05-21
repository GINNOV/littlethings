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


MODULE Preview3;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       u  : Utility,
       gd : Gadgets,
       df : DiskFont,
       fr : FileReq,
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       rt : RequesterTools,
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
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j     : INTEGER;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    bool      : BOOLEAN;
    listId  * ,
    chcolsId* ,
    changetextId  * ,
    changegraphId * ,
    colorconvId * ,
    widthconvId * ,
    scaleconvId * ,
    gridconvId  * ,
    chmathboxId* : INTEGER;

(*PROCEDURE IntToRGB*(i:LONGINT):LONGINT;

VAR set : LONGSET;

BEGIN
  set:=s.VAL(LONGSET,i);
  RETURN s.VAL(LONGINT,s.LSH(set,24));
END IntToRGB;*)

PROCEDURE SetColor*(rast:g.RastPortPtr;node:l.Node;front:BOOLEAN);

VAR pen,bright,numpens : INTEGER;

BEGIN
  IF node#NIL THEN
    WITH node: p1.Color DO
      node.used:=TRUE;
      IF p1.greyscale<0 THEN
        IF node.pen=-1 THEN
          node.pen:=g.ObtainBestPen(p1.colormap,s2.IntToRGB(node.red),s2.IntToRGB(node.green),s2.IntToRGB(node.blue),u.done);
        END;
        pen:=SHORT(node.pen);
      ELSE
        bright:=(node.red+node.green+node.blue) DIV 3;
        numpens:=p1.greyscale-1;
        IF p1.blackpen>=0 THEN
          INC(numpens);
        END;
        IF p1.whitepen>=0 THEN
          INC(numpens);
        END;
        pen:=SHORT(SHORT(bright/255*numpens+0.5));
        IF p1.blackpen>=0 THEN
          DEC(pen);
        END;
        IF pen<0 THEN
          pen:=p1.blackpen;
        ELSIF pen>=p1.greyscale THEN
          pen:=p1.whitepen;
        ELSE
          INC(pen,p1.startcolor);
        END;
      END;
      IF front THEN
        g.SetAPen(rast,pen);
      ELSE
        g.SetBPen(rast,pen);
      END;
    END;
  END;
END SetColor;

PROCEDURE InitGreyScale*(view:g.ViewPortPtr);

VAR pen,numpens,intbright : INTEGER;
    bright,step           : LONGREAL;

BEGIN
  IF p1.greyscale>=0 THEN
    numpens:=p1.greyscale-1;
    IF p1.blackpen>=0 THEN
      INC(numpens);
    END;
    IF p1.whitepen>=0 THEN
      INC(numpens);
    END;
    step:=15/numpens;
    bright:=0;
    IF p1.blackpen>=0 THEN
      bright:=bright+step;
    END;
    pen:=-1;
    WHILE pen<p1.greyscale-1 DO
      INC(pen);
      intbright:=SHORT(SHORT(SHORT(bright+0.5)));
      g.SetRGB4(view,pen+p1.startcolor,intbright,intbright,intbright);
      bright:=bright+step;
    END;
  END;
END InitGreyScale;

PROCEDURE * PrintColor(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(p1.colors,num);
  IF node#NIL THEN
    WITH node: p1.Color DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width-22);
      tt.Print(x+22,y,str,rast);

      g.SetAPen(rast,1);
      g.RectFill(rast,x,y-rast.txBaseline,x+18,y+rast.txHeight-rast.txBaseline-1);
      IF (node.selectpen>=0) AND (s1.os>=39) THEN
        g.SetAPen(rast,SHORT(node.selectpen));
      ELSE
        SetColor(rast,node,TRUE);
      END;
      g.RectFill(rast,x+2,y+1-rast.txBaseline,x+16,y+rast.txHeight-rast.txBaseline-2);
      DISPOSE(str);
    END;
  END;
END PrintColor;

PROCEDURE SelectColor*(VAR color:l.Node;title,select:e.STRPTR):BOOLEAN;
(* $CopyArrays- *)

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca    : I.GadgetPtr;
    listview,
    node,
    actel,
    oldel    : l.Node;
(*    string   : ARRAY 80 OF CHAR;*)
    i,x,y    : INTEGER;
    bool     : BOOLEAN;
    sec1,mic1,
    sec2,mic2: LONGINT;
    ret      : BOOLEAN;

PROCEDURE NewWindowSize;

BEGIN
  gm.SetListViewParams(listview,20,28,wind.width-54,wind.height-55,SHORT(p1.colors.nbElements()),s1.GetNodeNumber(p1.colors,actel),PrintColor);
  gm.SetCorrectPosition(listview);
  I.RefreshGList(listview(gm.ListView).scroll,wind,NIL,1);

  g.SetAPen(rast,0);
  g.RectFill(rast,4,11,wind.width-19,wind.height-3);
  it.DrawBevelBorder(rast,14,16,wind.width-42,wind.height-40);
  I.RefreshGList(ok,wind,NIL,2);

  g.SetAPen(rast,2);
  tt.Print(20,25,select,rast);

  gm.RefreshListView(listview);
  I.RefreshWindowFrame(wind);
END NewWindowSize;

BEGIN
  actel:=NIL;
  IF NOT(p1.colors.isEmpty()) THEN
    IF s1.os>=39 THEN
      node:=p1.colors.head;
      WHILE node#NIL DO
        WITH node: p1.Color DO
          node.selectpen:=g.ObtainBestPen(p1.colormap,s2.IntToRGB(node.red),s2.IntToRGB(node.green),s2.IntToRGB(node.blue),u.done);
        END;
        node:=node.next;
      END;
    END;
    IF listId=-1 THEN
      listId:=wm.InitWindow(100,10,280,159,title,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks,I.newSize,I.mouseMove},s1.screen,FALSE);
      wm.SetMinMax(listId,248,99,-1,-1);
    END;
    wm.ChangeTitle(listId,title);
    gm.StartGadgets(s1.window);
    ok:=gm.SetBooleanGadget(14,-20,100,14,ac.GetString(ac.OK));
    INCL(ok.flags,I.gRelBottom);
    ca:=gm.SetBooleanGadget(-127,-20,100,14,ac.GetString(ac.Cancel));
    INCL(ca.flags,I.gRelBottom);
    INCL(ca.flags,I.gRelRight);
    listview:=gm.SetListView(20,28,340,84,SHORT(p1.colors.nbElements()),s1.GetNodeNumber(p1.colors,actel),PrintColor);
    gm.EndGadgets;
    wm.SetGadgets(listId,ok);
    wm.ChangeScreen(listId,p1.previewscreen);
    wind:=wm.OpenWindow(listId);
    IF wind#NIL THEN
      rast:=wind.rPort;
      g.SetDrMd(rast,g.jam1);
  
      g.SetAPen(rast,2);
(*      string:="";
      i:=0;
      WHILE (title[i]#" ") AND (title[i]#0X) DO
        string[i]:=title[i];
        INC(i);
      END;
      string[i+1]:=0X;*)
      tt.Print(20,25,select,rast);
  
      gm.SetCorrectWindow(listview,wind);
(*      COPY(elnamep,string);
      st.AppendChar(string,"!");
      gm.SetNoEntryText(listview,"Keine",string);*)

      actel:=color;
  
      NewWindowSize;

      sec2:=0;
      mic2:=0;
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            EXIT;
          ELSIF address=ca THEN
            actel:=NIL;
            EXIT;
          END;
        ELSIF I.mouseButtons IN class THEN
          it.GetMousePos(wind,x,y);
          IF (x>=20) AND (x<=2+wind.width-53) AND (y>=28) AND (y<=26+wind.height-54) THEN
            oldel:=actel;
            bool:=gm.CheckListView(listview,class,code,address);
            IF bool THEN
              actel:=s1.GetNode(p1.colors,gm.ActEl(listview));
            END;
            IF oldel=actel THEN
              sec1:=sec2;
              mic1:=mic2;
              I.CurrentTime(sec2,mic2);
              IF I.DoubleClick(sec1,mic1,sec2,mic2) THEN
                EXIT;
              END;
            ELSE
              I.CurrentTime(sec2,mic2);
            END;
          END;
        ELSIF I.newSize IN class THEN
          NewWindowSize;
        END;
        bool:=gm.CheckListView(listview,class,code,address);
        IF bool THEN
          actel:=s1.GetNode(p1.colors,gm.ActEl(listview));
        END;
      END;
  
      wm.CloseWindow(listId);
    END;
    wm.FreeGadgets(listId);
    gm.FreeListView(listview);
    IF s1.os>=39 THEN
      node:=p1.colors.head;
      WHILE node#NIL DO
        WITH node: p1.Color DO
          g.ReleasePen(p1.colormap,node.selectpen);
        END;
        node:=node.next;
      END;
    END;
  ELSE
    bool:=rt.RequestWin(ac.GetString(ac.NoColorsEntered1),ac.GetString(ac.NoColorsEntered2),s.ADR(""),ac.GetString(ac.OK),s1.window);
  END;
  ret:=FALSE;
  IF actel#NIL THEN
    IF actel#color THEN
      color:=actel;
      ret:=TRUE;
    END;
  END;
  RETURN ret;
END SelectColor;

PROCEDURE AddNewColor*(name:ARRAY OF CHAR;red,green,blue:INTEGER);

VAR node : l.Node;

BEGIN
  NEW(node(p1.Color));
  WITH node: p1.Color DO
    COPY(name,node.name);
    node.red:=red;
    node.green:=green;
    node.blue:=blue;
    node.pen:=-1;
  END;
  p1.colors.AddTail(node);
END AddNewColor;

PROCEDURE FreeColor*(node:l.Node);

BEGIN
  WITH node: p1.Color DO
    IF node.pen#-1 THEN
      g.ReleasePen(p1.colormap,node.pen);
      node.pen:=-1;
    END;
  END;
  node.Remove;
END FreeColor;

PROCEDURE ReleaseColorPens*;

VAR node : l.Node;

BEGIN
  node:=p1.colors.head;
  WHILE node#NIL DO
    WITH node: p1.Color DO
      IF node.pen#-1 THEN
        g.ReleasePen(p1.colormap,node.pen);
        node.pen:=-1;
      END;
    END;
    node:=node.next;
  END;
END ReleaseColorPens;

PROCEDURE ChangeColors*():BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    string,
    add,del,
    wheel,
    slider,
    red,green,
    blue     : I.GadgetPtr;
    oldred,
    oldgreen,
    oldblue  : INTEGER;
    listview,
    actcol,
    node     : l.Node;
    pens     : ARRAY 10 OF INTEGER;
    ret,bool,
    pressed  : BOOLEAN;
    long     : LONGINT;

PROCEDURE FreePalette;

BEGIN
  IF s1.os>=39 THEN
    node:=p1.colors.head;
    WHILE node#NIL DO
      WITH node: p1.Color DO
        g.ReleasePen(p1.colormap,node.selectpen);
      END;
      node:=node.next;
    END;
  END;
END FreePalette;

PROCEDURE AllocPalette;

BEGIN
  IF s1.os>=39 THEN
    node:=p1.colors.head;
    WHILE node#NIL DO
      WITH node: p1.Color DO
        node.selectpen:=g.ObtainBestPen(p1.colormap,s2.IntToRGB(node.red),s2.IntToRGB(node.green),s2.IntToRGB(node.blue),u.done);
      END;
      node:=node.next;
    END;
  END;
END AllocPalette;

PROCEDURE RefreshPens(view:g.ViewPortPtr;wheel:I.GadgetPtr;pens:ARRAY OF INTEGER);

VAR numpens,
    actpen  : INTEGER;
    long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;

BEGIN
  IF s1.os>=39 THEN
    numpens:=0;
    WHILE pens[numpens]#-1 DO
      INC(numpens);
    END;
  
    long:=I.GetAttr(gd.wheelHSB,wheel,hsb);
    actpen:=0;
    WHILE actpen<numpens DO
      long:=SHORT(255-(255/(numpens-1))*actpen);
      hsb.brightness:=s.LSH(long,24);
      gd.ConvertHSBToRGB(hsb,rgb);
      g.SetRGB32(view,pens[actpen],rgb.red,rgb.green,rgb.blue);
      INC(actpen);
    END;
  END;
END RefreshPens;

PROCEDURE PreparePens(view:g.ViewPortPtr;VAR pens:ARRAY OF INTEGER;num:INTEGER);

VAR actpen : INTEGER;

BEGIN
  IF s1.os>=39 THEN
    IF num<0 THEN
      num:=200;
    END;
    actpen:=0;
    WHILE (actpen<num) AND (actpen<LEN(pens)-1) DO
      pens[actpen]:=SHORT(g.ObtainPen(view.colorMap,-1,0,0,0,s.VAL(LONGINT,LONGSET{g.penbExclusive})));
      INC(actpen);
    END;
    pens[actpen]:=-1;
  END;
END PreparePens;

PROCEDURE ReleasePens(view:g.ViewPortPtr;pens:ARRAY OF INTEGER);

VAR actpen : INTEGER;

BEGIN
  IF s1.os>=39 THEN
    actpen:=0;
    WHILE actpen<LEN(pens) DO
      IF pens[actpen]>=0 THEN
        g.ReleasePen(view.colorMap,pens[actpen]);
      ELSE
        actpen:=SHORT(LEN(pens));
      END;
      INC(actpen);
    END;
  END;
END ReleasePens;

PROCEDURE RefreshWheel;

VAR rgb : gd.ColorWheelRGB;
    hsb : gd.ColorWheelHSB;

BEGIN
  IF s1.os>=39 THEN
    IF actcol#NIL THEN
      WITH actcol: p1.Color DO
        rgb.red:=s2.IntToRGB(actcol.red);
        rgb.green:=s2.IntToRGB(actcol.green);
        rgb.blue:=s2.IntToRGB(actcol.blue);
        gd.ConvertRGBToHSB(rgb,hsb);
        long:=I.SetGadgetAttrs(wheel^,wind,NIL,gd.wheelRGB,s.ADR(rgb),u.done);
  (*      long:=I.SetGadgetAttrs(wheel^,wind,NIL,gd.wheelRed,IntToRGB(actcol.red),
                                               gd.wheelGreen,IntToRGB(actcol.green),
                                               gd.wheelBlue,IntToRGB(actcol.blue));*)
  (*      I.RefreshGList(slider,wind,NIL,2);*)
        RefreshPens(p1.previewview,wheel,pens);
      END;
    END;
  END;
END RefreshWheel;

PROCEDURE RefreshSliderText;

BEGIN
  IF actcol#NIL THEN
    WITH actcol: p1.Color DO
      g.SetDrMd(rast,g.jam2);
      g.SetAPen(rast,2);
      tt.PrintInt(74,163,actcol.red,3,rast);
      tt.PrintInt(74,176,actcol.green,3,rast);
      tt.PrintInt(74,189,actcol.blue,3,rast);
    END;
  END;
END RefreshSliderText;

PROCEDURE RefreshSliders;

BEGIN
  IF actcol#NIL THEN
    WITH actcol: p1.Color DO
      gm.SetSlider(red,wind,0,255,actcol.red);
      gm.SetSlider(green,wind,0,255,actcol.green);
      gm.SetSlider(blue,wind,0,255,actcol.blue);
      RefreshSliderText;
    END;
  END;
END RefreshSliders;

PROCEDURE NewColor;

BEGIN
  IF actcol#NIL THEN
    WITH actcol: p1.Color DO
      RefreshWheel;
      RefreshSliders;
      gm.PutGadgetText(string,actcol.name);
      I.RefreshGList(string,wind,NIL,1);
      bool:=I.ActivateGadget(string^,wind,NIL);
    END;
  END;
END NewColor;

PROCEDURE NewColorAdded;

BEGIN
  gm.SetListViewParams(listview,270,28,212,124,SHORT(p1.colors.nbElements()),s1.GetNodeNumber(p1.colors,actcol),PrintColor);
  gm.SetCorrectPosition(listview);
  gm.RefreshListView(listview);

  NewColor;
END NewColorAdded;

PROCEDURE GetColor;

VAR long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;

BEGIN
  IF actcol#NIL THEN
    WITH actcol: p1.Color DO
      IF s1.os>=39 THEN
        long:=I.GetAttr(gd.wheelRGB,wheel,rgb);
  (*      gd.ConvertHSBToRGB(hsb,rgb);*)
        actcol.red:=SHORT(s.LSH(rgb.red,-24));
        actcol.green:=SHORT(s.LSH(rgb.green,-24));
        actcol.blue:=SHORT(s.LSH(rgb.blue,-24));
  (*      gm.SetSlider(red,wind,0,255,actcol.red);
        gm.SetSlider(green,wind,0,255,actcol.green);
        gm.SetSlider(blue,wind,0,255,actcol.blue);
        g.SetDrMd(rast,g.jam2);
        g.SetAPen(rast,2);
        tt.PrintInt(74,163,actcol.red,3,rast);
        tt.PrintInt(74,176,actcol.green,3,rast);
        tt.PrintInt(74,189,actcol.blue,3,rast);*)
      END;
    END;
  END;
END GetColor;

BEGIN
  PreparePens(p1.previewview,pens,4);
  AllocPalette;
  ret:=FALSE;
  IF chcolsId=-1 THEN
    chcolsId:=wm.InitWindow(20,20,502,223,ac.GetString(ac.ChangeColors),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove,I.intuiTicks,I.idcmpUpdate},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,202,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(388,202,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,202,100,14,ac.GetString(ac.Help));
  add:=gm.SetBooleanGadget(270,167,212,14,ac.GetString(ac.NewColor));
  del:=gm.SetBooleanGadget(270,182,212,14,ac.GetString(ac.DelColor));
  string:=gm.SetStringGadget(270,152,200,14,255);
  red:=gm.SetPropGadget(110,155,148,12,0,0,32767,0);
  green:=gm.SetPropGadget(110,168,148,12,0,0,32767,0);
  blue:=gm.SetPropGadget(110,181,148,12,0,0,32767,0);
  listview:=gm.SetListView(270,28,212,124,SHORT(p1.colors.nbElements()),s1.GetNodeNumber(p1.colors,actcol),PrintColor);
  IF s1.os>=39 THEN
    slider:=I.NewObject(NIL,"gradientslider.gadget",I.gaTop,31,
                                                    I.gaLeft,238,
                                                    I.gaWidth,20,
                                                    I.gaHeight,119,
                                                    I.gaImmediate,I.LTRUE,
                                                    I.gaRelVerify,I.LTRUE,
                                                    I.gaPrevious,listview(gm.ListView).down,
                                                    I.pgaFreedom,I.freeVert,
                                                    gd.gradPenArray,s.ADR(pens));
    wheel:=I.NewObject(NIL,gd.colorWheelName,I.gaTop,31,
                                             I.gaLeft,26,
                                             I.gaWidth,200,
                                             I.gaHeight,119,
                                             I.gaFollowMouse,I.LTRUE,
                                             I.gaImmediate,I.LTRUE,
                                             I.gaRelVerify,I.LTRUE,
                                             I.gaPrevious,slider,
                                             gd.wheelGradientSlider,slider,
                                             gd.wheelScreen,p1.previewscreen,
                                             gd.wheelRed,-1,
                                             gd.wheelGreen,-1,
                                             gd.wheelBlue,-1,
                                             u.done);
  END;
  gm.EndGadgets;
  wm.SetGadgets(chcolsId,ok);
  wm.ChangeScreen(chcolsId,p1.previewscreen);
  wind:=wm.OpenWindow(chcolsId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,474,183);
    it.DrawBorder(rast,20,28,244,168);

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.CurrentColor),rast);
    tt.Print(270,25,ac.GetString(ac.SelectColor),rast);
    g.SetAPen(rast,2);
    tt.Print(26,163,ac.GetString(ac.RedDP),rast);
    tt.Print(26,176,ac.GetString(ac.GreenDP),rast);
    tt.Print(26,189,ac.GetString(ac.BlueDP),rast);

    IF s1.os<39 THEN
      it.DrawBorder(rast,26,50,232,22);
      g.SetAPen(rast,2);
      tt.Print(30,58,ac.GetString(ac.ColorwheelNotAvailable1),rast);
      tt.Print(30,68,ac.GetString(ac.ColorwheelNotAvailable2),rast);
    END;

    gm.SetCorrectWindow(listview,wind);
    gm.SetNoEntryText(listview,ac.GetString(ac.None),ac.GetString(ac.ColorsEx));

    actcol:=p1.colors.head;
    NewColorAdded;

    RefreshPens(p1.previewview,wheel,pens);
    pressed:=FALSE;
    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      bool:=gm.CheckListView(listview,class,code,address);
      IF bool THEN
        actcol:=s1.GetNode(p1.colors,gm.ActEl(listview));
        NewColor;
      END;
      IF actcol#NIL THEN
        WITH actcol: p1.Color DO
          gm.GetGadgetText(string,actcol.name);
          oldred:=actcol.red;
          oldgreen:=actcol.green;
          oldblue:=actcol.blue;
          actcol.red:=gm.GetSlider(red,0,255);
          actcol.green:=gm.GetSlider(green,0,255);
          actcol.blue:=gm.GetSlider(blue,0,255);
          IF (oldred#actcol.red) OR (oldgreen#actcol.green) OR (oldblue#actcol.blue) THEN
            RefreshWheel;
            RefreshSliderText;
          END;
        END;
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=add THEN
          FreePalette;
          AddNewColor(ac.GetString(ac.White)^,255,255,255);
          actcol:=p1.colors.tail;
          AllocPalette;
          NewColorAdded;
        ELSIF address=del THEN
          IF actcol#NIL THEN
            FreePalette;
            node:=actcol.next;
            IF node=NIL THEN
              node:=actcol.prev;
            END;
            FreeColor(actcol);
            actcol:=node;
            AllocPalette;
            NewColorAdded;
          END;
        ELSIF (address=wheel) OR (address=slider) THEN
          IF actcol#NIL THEN
            RefreshPens(p1.previewview,wheel,pens);
            GetColor;
            RefreshSliders;
            FreePalette;
            AllocPalette;
            gm.RefreshListView(listview);
            pressed:=FALSE;
          END;
        ELSIF (address=red) OR (address=green) OR (address=blue) THEN
          IF actcol#NIL THEN
            WITH actcol: p1.Color DO
              actcol.red:=gm.GetSlider(red,0,255);
              actcol.green:=gm.GetSlider(green,0,255);
              actcol.blue:=gm.GetSlider(blue,0,255);
            END;
            RefreshWheel;
            RefreshPens(p1.previewview,wheel,pens);
            FreePalette;
            AllocPalette;
            gm.RefreshListView(listview);
          END;
        END;
      ELSIF I.gadgetDown IN class THEN
        IF (address=wheel) OR (address=slider) THEN
          RefreshPens(p1.previewview,wheel,pens);
          GetColor;
          RefreshSliders;
          pressed:=TRUE;
        END;
      ELSIF I.mouseMove IN class THEN
        IF pressed THEN
          RefreshPens(p1.previewview,wheel,pens);
          GetColor;
          RefreshSliders;
        END;
(*      ELSIF I.idcmpUpdate IN class THEN
        GetColor;
        FreePalette;
        AllocPalette;
        NewColorAdded;*)
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"documentcolors",wind);
      END;
    END;
    wm.CloseWindow(chcolsId);
    IF s1.os>=39 THEN
      listview(gm.ListView).down.nextGadget:=NIL;
      wheel.nextGadget:=NIL;
      slider.nextGadget:=NIL;
      I.DisposeObject(wheel);
      I.DisposeObject(slider);
    END;
  END;
  wm.FreeGadgets(chcolsId);
  ReleasePens(p1.previewview,pens);
  FreePalette;
  RETURN ret;
END ChangeColors;

PROCEDURE RefreshColor*(rast:g.RastPortPtr;x,y,width,height:INTEGER;node:l.Node);

VAR str : e.STRPTR;

BEGIN
  WITH node: p1.Color DO
    g.SetAPen(rast,0);
    g.RectFill(rast,x+2,y+1,x+width-3,y+height-2);
    g.SetAPen(rast,2);
    NEW(str);
    COPY(node.name,str^);
    tt.CutStringToLength(rast,str^,width-8-22);
    tt.Print(x+4+22,y+3+rast.txBaseline,str,rast);
    g.SetAPen(rast,1);
    g.RectFill(rast,x+4,y+3,x+4+18,y+3+rast.txHeight-1);
    SetColor(rast,node,TRUE);
    g.RectFill(rast,x+6,y+4,x+4+16,y+3+rast.txHeight-2);
    DISPOSE(str);
  END;
END RefreshColor;

PROCEDURE PrintFontName*(rast:g.RastPortPtr;x,y,width,height:INTEGER;font,size:l.Node);

VAR str : e.STRPTR;

BEGIN
  NEW(str);
  bool:=lrc.RealToString(size(p1.FontSize).size,str^,7,7,FALSE);
  tt.Clear(str^);
  st.Append(str^,"Pt");
  st.InsertChar(str^,0," ");
  st.Insert(str^,0,font(p1.Font).name);
  g.SetAPen(rast,0);
  g.RectFill(rast,x+2,y+1,x+width-3,y+height-2);
  g.SetAPen(rast,2);
  tt.CutStringToLength(rast,str^,width-8);
  tt.Print(x+4,y+3+rast.txBaseline,str,rast);
  DISPOSE(str);
END PrintFontName;

PROCEDURE PrintLineString*(rast:g.RastPortPtr;x,y,width:INTEGER);

VAR string : ARRAY 10 OF CHAR;

BEGIN
  IF width>0 THEN
    bool:=c.IntToString(width,string,3);
    tt.Clear(string);
    st.Append(string," Pt");
  ELSE
    COPY(ac.GetString(ac.Hair)^,string);
  END;
  g.SetAPen(rast,2);
  tt.Print(x,y,s.ADR(string),rast);
END PrintLineString;

PROCEDURE ChangeTextLine*(text:l.Node):BOOLEAN;

VAR wind   : I.WindowPtr;
    rast   : g.RastPortPtr;
    ok,ca,
    help,
    string,
    trans,
    font,
    colorf,
    colorb,
    bold,
    italic,
    under  : I.GadgetPtr;
    ret,
    bool   : BOOLEAN;
    ostring: ARRAY 256 OF CHAR;
    ocolf,
    ocolb  : l.Node;
    otrans : BOOLEAN;

PROCEDURE RefreshColor;

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=text(p1.TextLine).colf;
  WITH node: p1.Color DO
    g.SetAPen(rast,0);
    g.RectFill(rast,28,57,219,68);
    g.SetAPen(rast,2);
    NEW(str);
    COPY(node.name,str^);
    tt.CutStringToLength(rast,str^,208-22);
    tt.Print(30+22,59+rast.txBaseline,str,rast);
    g.SetAPen(rast,1);
    g.RectFill(rast,30,59,30+18,59+rast.txHeight-1);
    SetColor(rast,node,TRUE);
    g.RectFill(rast,30+2,59+1,30+16,59+rast.txHeight-2);
    DISPOSE(str);
  END;
  node:=text(p1.TextLine).colb;
  WITH node: p1.Color DO
    g.SetAPen(rast,0);
    g.RectFill(rast,28,72,219,83);
    g.SetAPen(rast,2);
    NEW(str);
    COPY(node.name,str^);
    tt.CutStringToLength(rast,str^,208-22);
    tt.Print(30+22,74+rast.txBaseline,str,rast);
    g.SetAPen(rast,1);
    g.RectFill(rast,30,74,30+18,74+rast.txHeight-1);
    SetColor(rast,node,TRUE);
    g.RectFill(rast,30+2,74+1,30+16,74+rast.txHeight-2);
    DISPOSE(str);
  END;
END RefreshColor;

PROCEDURE RefreshFont;

VAR str : e.STRPTR;

BEGIN
  WITH text: p1.TextLine DO
    NEW(str);
    bool:=lrc.RealToString(text.fontsize(p1.FontSize).size,str^,7,7,FALSE);
    tt.Clear(str^);
    st.Append(str^,"Pt");
    st.InsertChar(str^,0," ");
    st.Insert(str^,0,text.font(p1.Font).name);
    g.SetAPen(rast,0);
    g.RectFill(rast,28,87,219,98);
    g.SetAPen(rast,2);
    tt.CutStringToLength(rast,str^,208);
    tt.Print(30,89+rast.txBaseline,str,rast);
    DISPOSE(str);
  END;
END RefreshFont;

BEGIN
  ret:=FALSE;
  IF changetextId=-1 THEN
    changetextId:=wm.InitWindow(20,20,480,130,ac.GetString(ac.ChangeTextLine),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},p1.previewscreen,FALSE);
  END;
(*  IF func THEN
    wm.ChangeTitle(changetextId,"Formel verändern");
  ELSE
    wm.ChangeTitle(changetextId,"Textzeile verändern");
  END;*)
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,109,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(366,109,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,109,100,14,ac.GetString(ac.Help));
  colorf:=gm.SetBooleanGadget(222,56,16,14,s.ADR("A"));
  colorb:=gm.SetBooleanGadget(222,71,16,14,s.ADR("A"));
  font:=gm.SetBooleanGadget(222,86,16,14,s.ADR("A"));
  IF g.bold IN text(p1.TextLine).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  bold:=gm.SetCheckBoxGadget(428,56,26,9,bool);
  IF g.italic IN text(p1.TextLine).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  italic:=gm.SetCheckBoxGadget(428,67,26,9,bool);
  IF g.underlined IN text(p1.TextLine).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  under:=gm.SetCheckBoxGadget(428,78,26,9,bool);
  trans:=gm.SetCheckBoxGadget(428,89,26,9,text(p1.TextLine).trans);
(*  trans:=gm.SetCheckBoxGadget(428,55);*)
(*  gm.SetPaletteGadgetOld(26,65,s1.screen.bitMap.depth,colf);
  gm.SetPaletteGadgetOld(26,96,s1.screen.bitMap.depth,colb);*)
  string:=gm.SetStringGadget(26,40,416,14,255);
  gm.EndGadgets;
  wm.SetGadgets(changetextId,ok);
  wm.ChangeScreen(changetextId,p1.previewscreen);
  wind:=wm.OpenWindow(changetextId);
  IF wind#NIL THEN
    WITH text: p1.TextLine DO
      rast:=wind.rPort;

(*      gm.DrawPaletteBorders(rast,26,65);
      gm.DrawPaletteBorders(rast,26,96);*)

      it.DrawBorder(rast,14,16,452,90);
      it.DrawBorder(rast,20,28,440,75);
      it.DrawBorderIn(rast,26,56,196,14);
      it.DrawBorderIn(rast,26,71,196,14);
      it.DrawBorderIn(rast,26,86,196,14);
(*      it.DrawBorder(rast,26,96,40,20);*)
  
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.TextLine),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.TextInput),rast);
      tt.Print(246,63,ac.GetString(ac.Bold),rast);
      tt.Print(246,74,ac.GetString(ac.Italic),rast);
      tt.Print(246,85,ac.GetString(ac.Underlined),rast);
      tt.Print(246,96,ac.GetString(ac.Transparent),rast);
(*      tt.Print(26,62,"Textfarbe",rast);*)
(*      tt.Print(26,93,"Hintergrundfarbe",rast);*)
(*      tt.Print(242,62,"Text transparent",rast);*)

      RefreshColor;
      RefreshFont;
(*      IF text.trans THEN
        gm.ActivateBool(trans,wind);
      END;*)
      gm.PutGadgetText(string,text.string);
      I.RefreshGList(string,wind,NIL,1);
      bool:=I.ActivateGadget(string^,wind,NIL);

      COPY(text.string,ostring);
      ocolf:=text.colf;
      ocolb:=text.colb;
      otrans:=text.trans;
  
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            gm.GetGadgetText(string,text.string);
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            COPY(ostring,text.string);
            text.colf:=ocolf;
            text.colb:=ocolb;
            text.trans:=otrans;
            EXIT;
          ELSIF address=string THEN
            bool:=I.ActivateGadget(string^,wind,NIL);
          ELSIF address=colorf THEN
            bool:=SelectColor(text.colf,ac.GetString(ac.SelectTextColor),ac.GetString(ac.TextColor));
            IF bool THEN
              RefreshColor;
            END;
          ELSIF address=colorb THEN
            bool:=SelectColor(text.colb,ac.GetString(ac.SelectBackgroundColor),ac.GetString(ac.BackgroundColor));
            IF bool THEN
              RefreshColor;
            END;
          ELSIF address=font THEN
            bool:=p2.SelectFont(text.font,text.fontsize,NIL);
            IF bool THEN
              RefreshFont;
            END;
          ELSIF address=bold THEN
            IF g.bold IN text.style THEN
              EXCL(text.style,g.bold);
            ELSE
              INCL(text.style,g.bold);
            END;
          ELSIF address=italic THEN
            IF g.italic IN text.style THEN
              EXCL(text.style,g.italic);
            ELSE
              INCL(text.style,g.italic);
            END;
          ELSIF address=under THEN
            IF g.underlined IN text.style THEN
              EXCL(text.style,g.underlined);
            ELSE
              INCL(text.style,g.underlined);
            END;
          ELSIF address=trans THEN
            text.trans:=NOT(text.trans);
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"textlinereq",wind);
        END;
      END;
      wm.CloseWindow(changetextId);
    END;
  END;
  wm.FreeGadgets(changetextId);
  RETURN ret;
END ChangeTextLine;

PROCEDURE ChangeGraph*(text:l.Node):BOOLEAN;

VAR wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    ok,ca,
    help,
    string,
    fill,
    lcolor,
    fcolor,
    linestr,
    lineslide : I.GadgetPtr;
    ret,
    bool      : BOOLEAN;
    oldwidth  : INTEGER;
    ocoll,
    ocolf     : l.Node;
    ofill     : BOOLEAN;
    owidth    : INTEGER;
    add1,add2,
    x,y       : INTEGER;
    line      : BOOLEAN;

PROCEDURE RefreshColor;

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=text(p1.Graph).linecolor;
  WITH node: p1.Color DO
    g.SetAPen(rast,0);
    g.RectFill(rast,144,31,335,42);
    g.SetAPen(rast,2);
    NEW(str);
    COPY(node.name,str^);
    tt.CutStringToLength(rast,str^,208-22);
    tt.Print(146+22,33+rast.txBaseline,str,rast);
    g.SetAPen(rast,1);
    g.RectFill(rast,146,33,146+18,33+rast.txHeight-1);
    SetColor(rast,node,TRUE);
    g.RectFill(rast,146+2,33+1,146+16,33+rast.txHeight-2);
    DISPOSE(str);
  END;
  IF NOT(line) THEN
    node:=text(p1.Graph).fillcolor;
    WITH node: p1.Color DO
      g.SetAPen(rast,0);
      g.RectFill(rast,144,46,335,57);
      g.SetAPen(rast,2);
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,208-22);
      tt.Print(146+22,48+rast.txBaseline,str,rast);
      g.SetAPen(rast,1);
      g.RectFill(rast,146,48,146+18,48+rast.txHeight-1);
      SetColor(rast,node,TRUE);
      g.RectFill(rast,146+2,48+1,146+16,48+rast.txHeight-2);
      DISPOSE(str);
    END;
  END;
END RefreshColor;

PROCEDURE RefreshLine;

VAR string : ARRAY 20 OF CHAR;

BEGIN
  IF text(p1.Graph).linewidth>0 THEN
    bool:=c.IntToString(text(p1.Graph).linewidth,string,3);
    tt.Clear(string);
    st.Append(string," Pt");
  ELSE
    string:="Haar";
  END;
  g.SetAPen(rast,2);
  tt.Print(146,53+add1,s.ADR(string),rast);
  gm.SetSlider(lineslide,wind,0,5,text(p1.Graph).linewidth);
END RefreshLine;

BEGIN
  IF NOT(text IS p1.Line) THEN
    line:=FALSE;
    add1:=15;
    add2:=27;
  ELSE
    line:=TRUE;
    add1:=0;
    add2:=0;
  END;
  ret:=FALSE;
  IF changegraphId=-1 THEN
    changegraphId:=wm.InitWindow(20,20,360,86+add2,ac.GetString(ac.ChangeGraphic),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  wm.GetDimensions(changegraphId,x,y,i,a);
  wm.SetDimensions(changegraphId,x,y,364,86+add2);
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,65+add2,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(266,65+add2,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,65+add2,100,14,ac.GetString(ac.Help));
  lcolor:=gm.SetBooleanGadget(338,30,16,14,s.ADR("A"));
  IF NOT(line) THEN
    fcolor:=gm.SetBooleanGadget(338,45,16,14,s.ADR("A"));
    fill:=gm.SetCheckBoxGadget(142,73,26,9,text(p1.Graph).dofill);
  END;
(*  linestr:=gm.SetStringGadget(320,28,32,14,5);*)
  lineslide:=gm.SetPropGadget(186,45+add1,168,12,0,0,32767,0);
(*  gm.SetPaletteGadgetOld(26,65,s1.screen.bitMap.depth,colf);
  gm.SetPaletteGadgetOld(26,96,s1.screen.bitMap.depth,colb);*)
  gm.EndGadgets;
  wm.SetGadgets(changegraphId,ok);
  wm.ChangeScreen(changegraphId,p1.previewscreen);
  wind:=wm.OpenWindow(changegraphId);
  IF wind#NIL THEN
    WITH text: p1.Graph DO
      rast:=wind.rPort;

      gm.DrawPropBorders(wind);

(*      gm.DrawPaletteBorders(rast,26,65);
      gm.DrawPaletteBorders(rast,26,96);*)

      it.DrawBorder(rast,14,16,352,46+add2);
      it.DrawBorder(rast,20,28,340,31+add2);
      it.DrawBorderIn(rast,142,30,196,14);
      IF NOT(line) THEN
        it.DrawBorderIn(rast,142,45,196,14);
      END;
      it.DrawBorder(rast,142,45+add1,40,12);

      g.SetDrMd(rast,g.jam2);
      g.SetAPen(rast,1);
      IF text IS p1.Circle THEN
        tt.Print(20,25,ac.GetString(ac.Ellipse),rast);
      ELSIF text IS p1.Rect THEN
        tt.Print(20,25,ac.GetString(ac.Rectangle),rast);
      ELSIF line THEN
        tt.Print(20,25,ac.GetString(ac.LayoutLine),rast);
      END;
      g.SetAPen(rast,2);
      IF NOT(line) THEN
        tt.Print(26,39,ac.GetString(ac.OutlineColor),rast);
        tt.Print(26,54,ac.GetString(ac.FillColor),rast);
        tt.Print(26,80,ac.GetString(ac.FillUp),rast);
      ELSE
        tt.Print(26,39,ac.GetString(ac.LineColor),rast);
      END;
      tt.Print(26,53+add1,ac.GetString(ac.LineThickness),rast);

      RefreshColor;
      RefreshLine;
(*      IF text.dofill THEN
        gm.ActivateBool(fill,wind);
      END;*)

      ocoll:=text.linecolor;
      ocolf:=text.fillcolor;
      ofill:=text.dofill;
      owidth:=text.linewidth;
  
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        oldwidth:=text.linewidth;
        text.linewidth:=gm.GetSlider(lineslide,0,5);
        IF oldwidth#text.linewidth THEN
          RefreshLine;
        END;
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            text.linecolor:=ocoll;
            text.fillcolor:=ocolf;
            text.dofill:=ofill;
            text.linewidth:=owidth;
            EXIT;
          ELSIF address=lcolor THEN
            bool:=SelectColor(text.linecolor,ac.GetString(ac.SelectOutlineColor),ac.GetString(ac.OutlineColor));
            IF bool THEN
              RefreshColor;
            END;
          ELSIF address=fcolor THEN
            bool:=SelectColor(text.fillcolor,ac.GetString(ac.SelectFillColor),ac.GetString(ac.FillColor));
            IF bool THEN
              RefreshColor;
            END;
          ELSIF address=fill THEN
            text.dofill:=NOT(text.dofill);
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"graphiccontents",wind);
        END;
      END;
      wm.CloseWindow(changegraphId);
    END;
  END;
  wm.FreeGadgets(changegraphId);
  RETURN ret;
END ChangeGraph;

PROCEDURE ColorConvert*():BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    selcol   : I.GadgetPtr;
    pal      : l.Node;
    actcol   : INTEGER;
    ret      : BOOLEAN;
    savecols : POINTER TO ARRAY OF l.Node;

BEGIN
  ret:=FALSE;
  IF colorconvId=-1 THEN
    colorconvId:=wm.InitWindow(20,20,264,115,ac.GetString(ac.ColorConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,94,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(150,94,100,14,ac.GetString(ac.Cancel));
  selcol:=gm.SetBooleanGadget(222,71,16,14,s.ADR("A"));
  pal:=gm.SetPaletteGadget(26,40,200,20,3,0);
  gm.EndGadgets;
  wm.SetGadgets(colorconvId,ok);
  wm.ChangeScreen(colorconvId,p1.previewscreen);
  wind:=wm.OpenWindow(colorconvId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    it.DrawBorder(rast,14,16,236,75);
    it.DrawBorder(rast,20,28,224,60);
    it.DrawBorderIn(rast,26,71,196,14);

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.ColorConversion),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.MathModeColor),rast);
    tt.Print(26,68,ac.GetString(ac.DocumentColor),rast);

    actcol:=0;

    gm.SetCorrectWindow(pal,wind);
    gm.RefreshPaletteGadget(pal);
    RefreshColor(rast,26,71,196,14,p1.colorconv[actcol]);

    NEW(savecols,LEN(p1.colorconv^));
    FOR i:=0 TO SHORT(LEN(p1.colorconv^)-1) DO
      savecols[i]:=p1.colorconv[i];
    END;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      bool:=gm.CheckPaletteGadget(pal,class,code,address);
      IF bool THEN
        actcol:=gm.ActCol(pal);
        RefreshColor(rast,26,71,196,14,p1.colorconv[actcol]);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          FOR i:=0 TO SHORT(LEN(p1.colorconv^)-1) DO
            p1.colorconv[i]:=savecols[i];
          END;
          EXIT;
        ELSIF address=selcol THEN
          bool:=SelectColor(p1.colorconv[actcol],ac.GetString(ac.SelectDocumentColor),ac.GetString(ac.DocumentColor));
          IF bool THEN
            RefreshColor(rast,26,71,196,14,p1.colorconv[actcol]);
          END;
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"colorconvert",wind);
      END;
    END;

    wm.CloseWindow(colorconvId);
  END;
  wm.FreeGadgets(colorconvId);
  RETURN ret;
END ColorConvert;

PROCEDURE LineConvert*():BOOLEAN;

VAR wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    ok,ca,
    help,
    lineslide : I.GadgetPtr;
    actwi,
    oldwidth  : INTEGER;
    ret       : BOOLEAN;
    savewidth : POINTER TO ARRAY OF INTEGER;

BEGIN
  ret:=FALSE;
  IF widthconvId=-1 THEN
    widthconvId:=wm.InitWindow(20,20,264,122,ac.GetString(ac.LineThicknessConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,101,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(150,101,100,14,ac.GetString(ac.Cancel));
  lineslide:=gm.SetPropGadget(70,80,168,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(widthconvId,ok);
  wm.ChangeScreen(widthconvId,p1.previewscreen);
  wind:=wm.OpenWindow(widthconvId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,236,82);
    it.DrawBorder(rast,20,28,224,67);
    it.DrawBorder(rast,26,80,40,12);

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.LineThicknessConversion),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.MathModeThickness),rast);
    tt.Print(26,77,ac.GetString(ac.PrintThickness),rast);

    actwi:=1;
    s7.RefreshWidthLines(rast,26,40);
    s7.RefreshWidthBorders(rast,26,40,actwi);
    gm.SetSlider(lineslide,wind,0,5,p1.widthconv[actwi-1]);
    PrintLineString(rast,30,88,p1.widthconv[actwi-1]);

    NEW(savewidth,LEN(p1.widthconv^));
    FOR i:=0 TO SHORT(LEN(p1.widthconv^)-1) DO
      savewidth[i]:=p1.widthconv[i];
    END;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      oldwidth:=p1.widthconv[actwi-1];
      p1.widthconv[actwi-1]:=gm.GetSlider(lineslide,0,5);
      IF oldwidth#p1.widthconv[actwi-1] THEN
        PrintLineString(rast,30,88,p1.widthconv[actwi-1]);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          FOR i:=0 TO SHORT(LEN(p1.widthconv^)-1) DO
            p1.widthconv[i]:=savewidth[i];
          END;
          EXIT;
        END;
      ELSIF I.mouseButtons IN class THEN
        bool:=s7.CheckWidths(wind,26,40,actwi);
        IF bool THEN
          gm.SetSlider(lineslide,wind,0,5,p1.widthconv[actwi-1]);
          PrintLineString(rast,30,88,p1.widthconv[actwi-1]);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"widthconvert",wind);
      END;
    END;

    wm.CloseWindow(widthconvId);
  END;
  wm.FreeGadgets(widthconvId);
  RETURN ret;
END LineConvert;

PROCEDURE ScaleConvert*(scale:p1.ScaleConvertPtr):BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    lineslide,
    selcol,
    selfont,
    stdfont,
    stdwidth,
    stdcolor : I.GadgetPtr;
    oldwidth : INTEGER;
    ret      : BOOLEAN;
    savefont,
    savesize,
    savecolor: l.Node;
    savewidth: INTEGER;
    savestdfont,
    savestdcolor,
    savestdwidth : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF scaleconvId=-1 THEN
    scaleconvId:=wm.InitWindow(20,20,364,132,ac.GetString(ac.AxisSystemConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,111,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(250,111,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,111,100,14,ac.GetString(ac.Help));
  selfont:=gm.SetBooleanGadget(222,40,16,14,s.ADR("A"));
  selcol:=gm.SetBooleanGadget(222,65,16,14,s.ADR("A"));
  stdfont:=gm.SetCheckBoxGadget(312,41,26,9,scale.stdfont);
  stdcolor:=gm.SetCheckBoxGadget(312,66,26,9,scale.stdcolor);
  stdwidth:=gm.SetCheckBoxGadget(312,90,26,9,scale.stdwidth);
  lineslide:=gm.SetPropGadget(70,90,168,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(scaleconvId,ok);
  wm.ChangeScreen(scaleconvId,p1.previewscreen);
  wind:=wm.OpenWindow(scaleconvId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,336,92);
    it.DrawBorder(rast,20,28,324,77);
    it.DrawBorderIn(rast,26,40,196,14);
    it.DrawBorderIn(rast,26,65,196,14);
    it.DrawBorder(rast,26,90,40,12);

    g.SetDrMd(rast,g.jam2);
    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.AxisSystemConversion),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.Font),rast);
    tt.Print(26,62,ac.GetString(ac.Color),rast);
    tt.Print(26,87,ac.GetString(ac.LineThickness),rast);
    tt.Print(242,49,ac.GetString(ac.Default),rast);
    tt.Print(242,74,ac.GetString(ac.Default),rast);
    tt.Print(242,98,ac.GetString(ac.Default),rast);

    PrintFontName(rast,26,40,196,14,scale.font,scale.size);
    RefreshColor(rast,26,65,196,14,scale.color);
    gm.SetSlider(lineslide,wind,0,5,scale.width);
    PrintLineString(rast,30,98,scale.width);

    savefont:=scale.font;
    savesize:=scale.size;
    savecolor:=scale.color;
    savewidth:=scale.width;
    savestdfont:=scale.stdfont;
    savestdcolor:=scale.stdcolor;
    savestdwidth:=scale.stdwidth;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      oldwidth:=scale.width;
      scale.width:=gm.GetSlider(lineslide,0,5);
      IF oldwidth#scale.width THEN
        PrintLineString(rast,30,98,scale.width);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          scale.font:=savefont;
          scale.size:=savesize;
          scale.color:=savecolor;
          scale.width:=savewidth;
          scale.stdfont:=savestdfont;
          scale.stdcolor:=savestdcolor;
          scale.stdwidth:=savestdwidth;
          EXIT;
        ELSIF address=selcol THEN
          bool:=SelectColor(scale.color,ac.GetString(ac.SelectAxisSystemColor),ac.GetString(ac.AxisSystemColor));
          IF bool THEN
            RefreshColor(rast,26,65,196,14,scale.color);
          END;
        ELSIF address=selfont THEN
          bool:=p2.SelectFont(scale.font,scale.size,NIL);
          IF bool THEN
            PrintFontName(rast,26,40,196,14,scale.font,scale.size);
          END;
        ELSIF address=stdfont THEN
          scale.stdfont:=NOT(scale.stdfont);
        ELSIF address=stdwidth THEN
          scale.stdwidth:=NOT(scale.stdwidth);
        ELSIF address=stdcolor THEN
          scale.stdcolor:=NOT(scale.stdcolor);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"axesconvert",wind);
      END;
    END;

    wm.CloseWindow(scaleconvId);
  END;
  wm.FreeGadgets(scaleconvId);
  RETURN ret;
END ScaleConvert;

PROCEDURE GridConvert*(grid:p1.GridConvertPtr):BOOLEAN;

VAR wind         : I.WindowPtr;
    rast         : g.RastPortPtr;
    ok,ca,
    help,
    selcol,
    stdcolor,
    stdwidth,
    lineslide    : I.GadgetPtr;
    ret          : BOOLEAN;
    oldwidth     : INTEGER;
    savecolor    : l.Node;
    savewidth    : INTEGER;
    savestdcolor,
    savestdwidth : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF gridconvId=-1 THEN
    gridconvId:=wm.InitWindow(20,20,364,107,ac.GetString(ac.BackgroundGridConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,86,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(250,86,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,86,100,14,ac.GetString(ac.Help));
  selcol:=gm.SetBooleanGadget(222,40,16,14,s.ADR("A"));
  stdcolor:=gm.SetCheckBoxGadget(312,41,26,9,grid.stdcolor);
  stdwidth:=gm.SetCheckBoxGadget(312,65,26,9,grid.stdwidth);
  lineslide:=gm.SetPropGadget(70,65,168,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(gridconvId,ok);
  wm.ChangeScreen(gridconvId,p1.previewscreen);
  wind:=wm.OpenWindow(gridconvId);
  IF wind#NIL THEN
    rast:=wind.rPort;

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,336,67);
    it.DrawBorder(rast,20,28,324,52);
    it.DrawBorderIn(rast,26,40,196,14);
    it.DrawBorder(rast,26,65,40,12);

    g.SetDrMd(rast,g.jam2);
    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.BackgroundGridConversion),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.Color),rast);
    tt.Print(26,62,ac.GetString(ac.LineThickness),rast);
    tt.Print(242,49,ac.GetString(ac.Default),rast);
    tt.Print(242,73,ac.GetString(ac.Default),rast);

    RefreshColor(rast,26,40,196,14,grid.color);
    gm.SetSlider(lineslide,wind,0,5,grid.width);
    PrintLineString(rast,30,73,grid.width);

    savecolor:=grid.color;
    savewidth:=grid.width;
    savestdcolor:=grid.stdcolor;
    savestdwidth:=grid.stdwidth;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      oldwidth:=grid.width;
      grid.width:=gm.GetSlider(lineslide,0,5);
      IF oldwidth#grid.width THEN
        PrintLineString(rast,30,73,grid.width);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          grid.color:=savecolor;
          grid.width:=savewidth;
          grid.stdcolor:=savestdcolor;
          grid.stdwidth:=savestdwidth;
          EXIT;
        ELSIF address=selcol THEN
          bool:=SelectColor(grid.color,ac.GetString(ac.SelectGridColor),ac.GetString(ac.GridColor));
          IF bool THEN
            RefreshColor(rast,26,40,196,14,grid.color);
          END;
        ELSIF address=stdwidth THEN
          grid.stdwidth:=NOT(grid.stdwidth);
        ELSIF address=stdcolor THEN
          grid.stdcolor:=NOT(grid.stdcolor);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"gridconvert",wind);
      END;
    END;

    wm.CloseWindow(gridconvId);
  END;
  wm.FreeGadgets(gridconvId);
  RETURN ret;
END GridConvert;

PROCEDURE ChangeMathBox*(box:l.Node):BOOLEAN;

VAR wind    : I.WindowPtr;
    rast    : g.RastPortPtr;
    ok,ca,
    help,
    selfont,
    selcolt,
    selcolg,
    chscale,
    chgrid,
    stdfont,
    stdcolt,
    stdcolg,
    stdscale,
    stdgrid : I.GadgetPtr;
    ret,
    fenster : BOOLEAN;
    height  : INTEGER;
    savefont,
    savesize,
    savetextcolor,
    savegraphcolor : l.Node;
    savescale : p1.ScaleConvertPtr;
    savegrid  : p1.GridConvertPtr;
    savestdfont,
    savestdsize,
    savestdtextcolor,
    savestdgraphcolor,
    savestdscale,
    savestdgrid : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF box IS p1.Fenster THEN
    fenster:=TRUE;
    height:=164;
  ELSE
    fenster:=FALSE;
    height:=134;
  END;
  IF chmathboxId=-1 THEN
    chmathboxId:=wm.InitWindow(20,20,364,height,ac.GetString(ac.ChangeBoxContents),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},p1.previewscreen,FALSE);
  END;
  wm.SetDimensions(chmathboxId,-1,-1,364,height);
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,height-21,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(250,height-21,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,height-21,100,14,ac.GetString(ac.Help));
  selfont:=gm.SetBooleanGadget(222,40,16,14,s.ADR("A"));
  selcolt:=gm.SetBooleanGadget(222,65,16,14,s.ADR("A"));
  selcolg:=gm.SetBooleanGadget(222,90,16,14,s.ADR("A"));
  stdfont:=gm.SetCheckBoxGadget(312,41,26,9,box(p1.MathBox).stdfont);
  stdcolt:=gm.SetCheckBoxGadget(312,66,26,9,box(p1.MathBox).stdtextcolor);
  stdcolg:=gm.SetCheckBoxGadget(312,91,26,9,box(p1.MathBox).stdgraphcolor);
  IF fenster THEN
    chscale:=gm.SetBooleanGadget(26,105,212,14,ac.GetString(ac.AxisSystem));
    chgrid:=gm.SetBooleanGadget(26,120,212,14,ac.GetString(ac.BackgroundGrid));
    stdscale:=gm.SetCheckBoxGadget(312,106,26,9,box(p1.MathBox).stdscale);
    stdgrid:=gm.SetCheckBoxGadget(312,121,26,9,box(p1.MathBox).stdgrid);
  END;
  gm.EndGadgets;
  wm.SetGadgets(chmathboxId,ok);
  wm.ChangeScreen(chmathboxId,p1.previewscreen);
  wind:=wm.OpenWindow(chmathboxId);
  IF wind#NIL THEN
    WITH box: p1.MathBox DO
      rast:=wind.rPort;
  
      gm.DrawPropBorders(wind);
  
      it.DrawBorder(rast,14,16,336,height-40);
      it.DrawBorder(rast,20,28,324,height-55);
      it.DrawBorderIn(rast,26,40,196,14);
      it.DrawBorderIn(rast,26,65,196,14);
      it.DrawBorderIn(rast,26,90,196,14);
  
      g.SetDrMd(rast,g.jam2);
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.BoxContents),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.Font),rast);
      tt.Print(26,62,ac.GetString(ac.TextColor),rast);
      tt.Print(26,87,ac.GetString(ac.GraphicColor),rast);
      tt.Print(242,49,ac.GetString(ac.Default),rast);
      tt.Print(242,74,ac.GetString(ac.Default),rast);
      tt.Print(242,99,ac.GetString(ac.Default),rast);
      IF fenster THEN
        tt.Print(242,114,ac.GetString(ac.Default),rast);
        tt.Print(242,129,ac.GetString(ac.Default),rast);
      END;
  
      PrintFontName(rast,26,40,196,14,box.font,box.size);
      RefreshColor(rast,26,65,196,14,box.textcolor);
      RefreshColor(rast,26,90,196,14,box.graphcolor);

      NEW(savescale);
      NEW(savegrid);
      savescale.font:=box.scale.font;
      savescale.size:=box.scale.size;
      savescale.color:=box.scale.color;
      savescale.width:=box.scale.width;
      savescale.stdfont:=box.scale.stdfont;
      savescale.stdcolor:=box.scale.stdcolor;
      savescale.stdwidth:=box.scale.stdwidth;
      savegrid.color:=box.grid.color;
      savegrid.width:=box.grid.width;
      savegrid.stdcolor:=box.grid.stdcolor;
      savegrid.stdwidth:=box.grid.stdwidth;
      savefont:=box.font;
      savesize:=box.size;
      savetextcolor:=box.textcolor;
      savegraphcolor:=box.graphcolor;
      savestdscale:=box.stdscale;
      savestdgrid:=box.stdgrid;
      savestdfont:=box.stdfont;
      savestdtextcolor:=box.stdtextcolor;
      savestdgraphcolor:=box.stdgraphcolor;
  
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            box.scale.font:=savescale.font;
            box.scale.size:=savescale.size;
            box.scale.color:=savescale.color;
            box.scale.width:=savescale.width;
            box.scale.stdfont:=savescale.stdfont;
            box.scale.stdcolor:=savescale.stdcolor;
            box.scale.stdwidth:=savescale.stdwidth;
            box.grid.color:=savegrid.color;
            box.grid.width:=savegrid.width;
            box.grid.stdcolor:=savegrid.stdcolor;
            box.grid.stdwidth:=savegrid.stdwidth;
            box.font:=savefont;
            box.size:=savesize;
            box.textcolor:=savetextcolor;
            box.graphcolor:=savegraphcolor;
            box.stdscale:=savestdscale;
            box.stdgrid:=savestdgrid;
            box.stdfont:=savestdfont;
            box.stdtextcolor:=savestdtextcolor;
            box.stdgraphcolor:=savestdgraphcolor;
            EXIT;
          ELSIF address=selcolt THEN
            bool:=SelectColor(box.textcolor,ac.GetString(ac.SelectTextColor),ac.GetString(ac.TextColor));
            IF bool THEN
              RefreshColor(rast,26,65,196,14,box.textcolor);
            END;
          ELSIF address=selcolg THEN
            bool:=SelectColor(box.graphcolor,ac.GetString(ac.SelectGraphicColor),ac.GetString(ac.GraphicColor));
            IF bool THEN
              RefreshColor(rast,26,90,196,14,box.graphcolor);
            END;
          ELSIF address=selfont THEN
            bool:=p2.SelectFont(box.font,box.size,NIL);
            IF bool THEN
              PrintFontName(rast,26,40,196,14,box.font,box.size);
            END;
          ELSIF address=chscale THEN
            bool:=ScaleConvert(box.scale);
          ELSIF address=chgrid THEN
            bool:=GridConvert(box.grid);
          ELSIF address=stdfont THEN
            box.stdfont:=NOT(box.stdfont);
          ELSIF address=stdcolt THEN
            box.stdtextcolor:=NOT(box.stdtextcolor);
          ELSIF address=stdcolg THEN
            box.stdgraphcolor:=NOT(box.stdgraphcolor);
          ELSIF address=stdscale THEN
            box.stdscale:=NOT(box.stdscale);
          ELSIF address=stdgrid THEN
            box.stdgrid:=NOT(box.stdgrid);
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"mathboxcontents",wind);
        END;
      END;
    END;

    wm.CloseWindow(chmathboxId);
  END;
  wm.FreeGadgets(chmathboxId);
  RETURN ret;
END ChangeMathBox;

BEGIN
  listId:=-1;
  chcolsId:=-1;
  changetextId:=-1;
  changegraphId:=-1;
  colorconvId:=-1;
  widthconvId:=-1;
  scaleconvId:=-1;
  gridconvId:=-1;
  chmathboxId:=-1;
END Preview3.


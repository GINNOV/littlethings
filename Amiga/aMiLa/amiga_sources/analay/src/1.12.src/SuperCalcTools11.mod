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


MODULE SuperCalcTools11;

IMPORT I  : Intuition,
       g  : Graqèics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Functqon,
       f1 : Functqon1,
       c  : Converwions,
       l  : LinkedLists,
       as : ASL,
       df : oskFont,
       lrc: LongRealConversqons,
       pt : Pointers,
       it : IntuitionTools,
       tt < TextTools,
       at : AslTools,
       ag : AmigaGuideTools,
       rt < RequesterTools,
       wm : WqndowManuger,
       gm : ÇadgetManager,
       ac : AlConversions,
       mdt: MathIEEEDoubTrans,
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
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    listId    * ,
    designId  * : INTEGER;
    bearbeitId  : INTEGER;
    pxs,pys     : ARRAY 80 OF CHAR;
    actspalt    : l.Node;

PROCEDURE DrawField*(rast:g.RastPortPtr;design:s1.Design;x,y,width,height:INTEGER);

BEGIN
  INC(width,design.width);
  INC(height,design.height);
  IF (design.hindex>=2) AND (design.hindex<=4) THEN
    INC(height,1);
  END;
  IF (design.vindex>=2) AND (design.vindex<=4) THEN
    INC(width,1);
  END;
  g.SetAPen(rast,design.col);
  IF design.hindex=1 THEN
    g.Move(rast,x,y);
    g.Draw(rast,x+width,y);
    g.Move(rast,x,y+height);
    g.Draw(rast,x+width,y+height);
  ELSIF design.hindex=2 THEN
    g.Move(rast,x,y);
    g.Draw(rast,x+width,y);
    g.Move(rast,x,y+height);
    g.Draw(rast,x+width,y+height);
    g.Move(rast,x,y+1);
    g.Draw(rast,x+width,y+1);
    g.Move(rast,x,y+height-1);
    g.Draw(rast,x+width,y+height-1);
  END;
  IF design.vindex=1 THEN
    g.Move(rast,x,y);
    g.Draw(rast,x,y+height);
    g.Move(rast,x+width,y);
    g.Draw(rast,x+width,y+height);
  ELSIF design.vindex=2 THEN
    g.Move(rast,x,y);
    g.Draw(rast,x,y+height);
    g.Move(rast,x+width,y);
    g.Draw(rast,x+width,y+height);
    g.Move(rast,x+1,y);
    g.Draw(rast,x+1,y+height);
    g.Move(rast,x+width-1,y);
    g.Draw(rast,x+width-1,y+height);
  END;
  IF design.hindex=3 THEN
    g.SetAPen(rast,1);
    g.Move(rast,x,y);
    g.Draw(rast,x+width,y);
    g.Move(rast,x,y+height-1);
    g.Draw(rast,x+width,y+height-1);
    g.SetAPen(rast,2);
    g.Move(rast,x,y+1);
    g.Draw(rast,x+width,y+1);
    g.Move(rast,x,y+height);
    g.Draw(rast,x+width,y+height);
  ELSIF design.hindex=4 THEN
    g.SetAPen(rast,2);
    g.Move(rast,x,y);
    g.Draw(rast,x+width,y);
    g.Move(rast,x,y+height-1);
    g.Draw(rast,x+width,y+height-1);
    g.SetAPen(rast,1);
    g.Move(rast,x,y+1);
    g.Draw(rast,x+width,y+1);
    g.Move(rast,x,y+height);
    g.Draw(rast,x+width,y+height);
  END;
  IF design.vindex=3 THEN
    g.SetAPen(rast,1);
    g.Move(rast,x,y);
    g.Draw(rast,x,y+height);
    g.Move(rast,x+width-1,y);
    g.Draw(rast,x+width-1,y+height);
    g.SetAPen(rast,2);
    g.Move(rast,x+1,y);
    g.Draw(rast,x+1,y+height);
    g.Move(rast,x+width,y);
    g.Draw(rast,x+width,y+height);
  ELSIF design.vindex=4 THEN
    g.SetAPen(rast,2);
    g.Move(rast,x,y);
    g.Draw(rast,x,y+height);
    g.Move(rast,x+width-1,y);
    g.Draw(rast,x+width-1,y+height);
    g.SetAPen(rast,1);
    g.Move(rast,x+1,y);
    g.Draw(rast,x+1,y+height);
    g.Move(rast,x+width,y);
    g.Draw(rast,x+width,y+height);
  END;
  IF (design.hindex=5) AND (design.vindex=5) THEN
    it.DrawBorder(rast,x,y,width,height);
  END;
END DrawField;

PROCEDURE DrawHoriz*(rast:g.RastPortPtr;design:s1.Design;x,y,width,height:INTEGER);

BEGIN
(*  INC(width,design.width);
  INC(height,design.height);
  IF (design.hindex>=2) AND (design.hindex<=4) THEN
    INC(height,1);
  END;
  IF (design.vindex>=2) AND (design.vindex<=4) THEN
    INC(width,1);
  END;*)
  g.SetAPen(rast,design.col);
  IF (design.hindex=5) AND (design.vindex#5) THEN
    it.DrawBorder(rast,x,y,width,height);
  END;
END DrawHoriz;

PROCEDURE DrawVert*(rast:g.RastPortPtr;design:s1.Design;x,y,width,height:INTEGER);

BEGIN
(*  INC(width,design.width);
  INC(height,design.height);
  IF (design.hindex>=2) AND (design.hindex<=4) THEN
    INC(height,1);
  END;
  IF (design.vindex>=2) AND (design.vindex<=4) THEN
    INC(width,1);
  END;*)
  g.SetAPen(rast,design.col);
  IF (design.vindex=5) AND (design.hindex#5) THEN
    it.DrawBorder(rast,x,y,width,height);
  END;
END DrawVert;

PROCEDURE ChangeDesign*(VAR design:s1.Design);

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca: I.GadgetPtr;
    pal  : l.Node;
    acth,
    actv,
    x,y  : INTEGER;
    savedes : s1.Design;

PROCEDURE RefreshData;

BEGIN
  design.width:=8;
  design.left:=4;
  IF (design.hindex>=2) AND (design.hindex<=5) THEN
    design.height:=4;
    IF design.hindex#5 THEN
      design.top:=3;
    ELSE
      design.top:=2;
    END;
  ELSE
    design.height:=3;
    design.top:=2;
  END;
END RefreshData;

PROCEDURE RefreshLines(vert:BOOLEAN);

VAR y : INTEGER;

BEGIN
  IF vert THEN
    y:=73;
  ELSE
    y:=47;
  END;
  g.SetAPen(rast,1);
  g.Move(rast,70,y);
  g.Draw(rast,99,y);

  g.Move(rast,110,y);
  g.Draw(rast,139,y);
  g.Move(rast,110,y+1);
  g.Draw(rast,139,y+1);

  g.Move(rast,150,y);
  g.Draw(rast,179,y);
  g.SetAPen(rast,2);
  g.Move(rast,150,y+1);
  g.Draw(rast,179,y+1);

  g.Move(rast,190,y);
  g.Draw(rast,219,y);
  g.SetAPen(rast,1);
  g.Move(rast,190,y+1);
  g.Draw(rast,219,y+1);

  it.DrawBorder(rast,230,y-5,30,11);
END RefreshLines;

PROCEDURE RefreshBorders;

BEGIN
  FOR i:=0 TO 5 DO
    IF acth=i THEN
      it.DrawBorderIn(rast,26+i*40,40,38,15);
    ELSE
      it.DrawBorder(rast,26+i*40,40,38,15);
    END;
  END;
  FOR i:=0 TO 5 DO
    IF actv=i THEN
      it.DrawBorderIn(rast,26+i*40,66,38,15);
    ELSE
      it.DrawBorder(rast,26+i*40,66,38,15);
    END;
  END;
END RefreshBorders;

PROCEDURE RefreshPreview;

VAR width,height : INTEGER;

BEGIN
  height:=rast.txHeight+design.height;
  width:=SHORT(g.TextLength(rast,"XxXx",4))+design.width;
  g.SetAPen(rast,0);
  g.RectFill(rast,280,30,473,100);
  FOR x:=0 TO 3 DO
    FOR y:=0 TO 4 DO
      g.SetAPen(rast,1);
      tt.Print(280+x*width+design.left,30+y*height+design.top+rast.txBaseline,s.ADR("XxXx"),rast);
      DrawField(rast,design,280+x*width,30+y*height,width-design.width,rast.txHeight);
      DrawHoriz(rast,design,280,30+y*height,width*4,height);
    END;
    DrawVert(rast,design,280+x*width,30,width,height*5);
  END;
END RefreshPreview;

BEGIN
  IF designId=-1 THEN
    designId:=wm.InitWindow(20,10,496,142,ac.GetString(ac.ChangeDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,121,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(382,121,100,14,ac.GetString(ac.Cancel));
  pal:=gm.SetPaletteGadget(26,92,200,20,s1.screen.rastPort.bitMap.depth,design(s1.Design).col);
  gm.EndGadgets;
  wm.SetGadgets(designId,ok);
  wm.ChangeScreen(designId,s1.screen);
  wind:=wm.OpenWindow(designId);
  IF wind#NIL THEN
    WITH design: s1.Design DO
      rast:=wind.rPort;
(*      ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,120,100,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),380,120,100,
                        SET{I.gadgImmediate,I.relVerify});*)

      s1.CopyDesign(s.ADR(design),s.ADR(savedes));

      it.DrawBorder(rast,14,16,468,102);
      it.DrawBorder(rast,20,28,250,87);
      it.DrawBorder(rast,276,28,200,87);

      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.Design),rast);
      tt.Print(276,25,ac.GetString(ac.Preview),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.HorizontalSeparation),rast);
      tt.Print(26,63,ac.GetString(ac.VerticalSeparation),rast);
      tt.Print(26,89,ac.GetString(ac.Color),rast);

      gm.SetCorrectWindow(pal,wind);
      gm.RefreshPaletteGadget(pal);

(*      cols:=SHORT(ig.Hoch(2,s1.screen.bitMap.depth));
      s1.SetPalette(col,cols,wind,78,93);
      bordcol:=ig.SetPlastInBorder(16,38);
      I.DrawBorder(rast,bordcol,28,93);*)

(*      g.SetAPen(rast,design.col);
      g.RectFill(rast,30,94,63,109);*)
      acth:=design.hindex;
      actv:=design.vindex;

      RefreshLines(FALSE);
      RefreshLines(TRUE);
      RefreshBorders;
      RefreshPreview;

      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        bool:=gm.CheckPaletteGadget(pal,class,code,address);
        IF bool THEN
          design.col:=gm.ActCol(pal);
          RefreshPreview;
        END;
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            EXIT;
          ELSIF address=ca THEN
            s1.CopyDesign(s.ADR(savedes),s.ADR(design));
            EXIT;
(*          ELSE
            i:=-1;
            WHILE i<cols-1 DO
              INC(i);
              IF address=s.ADR(col[i]) THEN
                g.SetAPen(rast,i);
                g.RectFill(rast,30,94,63,109);
                design.col:=i;
                RefreshPreview;
              END;
            END;*)
          END;
        ELSIF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
          it.GetMousePos(wind,x,y);
          IF (x>=26) AND (x<=265) THEN
            x:=x-26;
            x:=x DIV 40;
            IF (y>=40) AND (y<=54) THEN
              acth:=x;
              design.hindex:=x;
              RefreshBorders;
              RefreshData;
              RefreshPreview;
            ELSIF (y>=66) AND (y<=80) THEN
              actv:=x;
              design.vindex:=x;
              RefreshBorders;
              RefreshData;
              RefreshPreview;
            END;
          END;
        END;
      END;

(*      ig.FreePlastHighBooleanGadget(ca,wind);
      ig.FreePlastHighBooleanGadget(ok,wind);
      ig.FreePlastBorder(bordcol);*)
      wm.CloseWindow(designId);
    END;
  END;
  wm.FreeGadgets(designId);
END ChangeDesign;

PROCEDURE GetDecTabStrings*(string:ARRAY OF CHAR;VAR integ,float,point:ARRAY OF CHAR);

VAR i,pos : INTEGER;

BEGIN
  pos:=0;
  WHILE (pos<st.Length(string)) AND (string[pos]#".") DO
    integ[pos]:=string[pos];
    INC(pos);
  END;
  integ[pos]:=0X;
  point[0]:=string[pos];
  point[1]:=0X;
  INC(pos);
  i:=0;
  WHILE pos<st.Length(string) DO
    float[i]:=string[pos];
    INC(pos);
    INC(i);
  END;
  float[i]:=0X;
END GetDecTabStrings;

PROCEDURE RefreshListDatas*(rast:g.RastPortPtr;list:l.Node);

VAR width,height,
    width2,
    integwi,
    floatwi,
    pointwi      : INTEGER;
    node,node2,
    zeil,spalt   : l.Node;
    x,y          : INTEGER;
    first        : BOOLEAN;
    integstr,
    floatstr,
    pointstr     : ARRAY 256 OF CHAR;

BEGIN
  WITH list: s1.List DO
    spalt:=list.spalten.head;
    width2:=0;
    WHILE spalt#NIL DO
      spalt(s1.ListSpalt).width:=list.design.width;
      spalt(s1.ListSpalt).integwidth:=0;
      spalt(s1.ListSpalt).floatwidth:=0;
      spalt(s1.ListSpalt).pointwidth:=0;
      width:=0;
      zeil:=spalt(s1.ListSpalt).zeilen.head;
      WHILE zeil#NIL DO
        width:=g.TextLength(rast,zeil(s1.ListZeil).string,st.Length(zeil(s1.ListZeil).string));
        INC(width,list.design.width);
        IF width>spalt(s1.ListSpalt).width THEN
          spalt(s1.ListSpalt).width:=width;
        END;
        IF width>width2 THEN
          width2:=width;
        END;
        IF (list.dectab) AND NOT((list.topsep) AND (zeil=spalt(s1.ListSpalt).zeilen.head)) THEN
          GetDecTabStrings(zeil(s1.ListZeil).string,integstr,floatstr,pointstr);
          integwi:=g.TextLength(rast,integstr,st.Length(integstr));
          IF integwi>spalt(s1.ListSpalt).integwidth THEN
            spalt(s1.ListSpalt).integwidth:=integwi;
          END;
          floatwi:=g.TextLength(rast,floatstr,st.Length(floatstr));
          IF floatwi>spalt(s1.ListSpalt).floatwidth THEN
            spalt(s1.ListSpalt).floatwidth:=floatwi;
          END;
          pointwi:=g.TextLength(rast,pointstr,st.Length(pointstr));
          IF pointwi>spalt(s1.ListSpalt).pointwidth THEN
            spalt(s1.ListSpalt).pointwidth:=pointwi;
          END;
        END;
        zeil:=zeil.next;
      END;
      IF list.dectab THEN
        width:=spalt(s1.ListSpalt).integwidth+spalt(s1.ListSpalt).floatwidth+spalt(s1.ListSpalt).pointwidth+list.design.width;
        IF width>spalt(s1.ListSpalt).width THEN
          spalt(s1.ListSpalt).width:=width;
        END;
      END;
      spalt:=spalt.next;
    END;
    IF list.samewi THEN
      spalt:=list.spalten.head;
      WHILE spalt#NIL DO
        spalt(s1.ListSpalt).width:=width2;
        spalt:=spalt.next;
      END;
    END;
    height:=rast.txHeight+list.design.height;

    list.lwidth:=0;
    list.lheight:=0;
    spalt:=list.spalten.head;
    x:=0;
    WHILE spalt#NIL DO
      zeil:=spalt(s1.ListSpalt).zeilen.head;
      y:=0;
      IF list.topsep THEN
        first:=TRUE;
      END;
      WHILE zeil#NIL DO
        INC(y,height);
        IF first THEN
          INC(y,list.design.height);
          first:=FALSE;
        END;
        zeil:=zeil.next;
      END;
      IF y>list.lheight THEN
        list.lheight:=y;
      END;
      INC(x,spalt(s1.ListSpalt).width);
      spalt:=spalt.next;
    END;
    list.lwidth:=x;
    IF list.design.hindex<5 THEN
      INC(list.lheight);
    END;
    IF (list.design.hindex=3) OR (list.design.hindex=4) THEN
      INC(list.lheight);
    END;
  END;
END RefreshListDatas;

PROCEDURE RawPlotList*(rast:g.RastPortPtr;list:l.Node;xpos,ypos,wi,he:INTEGER);

VAR width,height,
    width2,
    integwi,
    floatwi,
    pointwi      : INTEGER;
    node,node2,
    zeil,spalt,
    breaknode    : l.Node;
    x,y,x2,xoff  : INTEGER;
    first        : BOOLEAN;
    integstr,
    floatstr,
    pointstr     : ARRAY 256 OF CHAR;

BEGIN
  WITH list: s1.List DO
    spalt:=list.spalten.head;
    width2:=0;
    WHILE spalt#NIL DO
      spalt(s1.ListSpalt).width:=list.design.width;
      spalt(s1.ListSpalt).integwidth:=0;
      spalt(s1.ListSpalt).floatwidth:=0;
      spalt(s1.ListSpalt).pointwidth:=0;
      width:=0;
      zeil:=spalt(s1.ListSpalt).zeilen.head;
      WHILE zeil#NIL DO
        width:=g.TextLength(rast,zeil(s1.ListZeil).string,st.Length(zeil(s1.ListZeil).string));
        INC(width,list.design.width);
        IF width>spalt(s1.ListSpalt).width THEN
          spalt(s1.ListSpalt).width:=width;
        END;
        IF width>width2 THEN
          width2:=width;
        END;
        IF (list.dectab) AND NOT((list.topsep) AND (zeil=spalt(s1.ListSpalt).zeilen.head)) THEN
          GetDecTabStrings(zeil(s1.ListZeil).string,integstr,floatstr,pointstr);
          integwi:=g.TextLength(rast,integstr,st.Length(integstr));
          IF integwi>spalt(s1.ListSpalt).integwidth THEN
            spalt(s1.ListSpalt).integwidth:=integwi;
          END;
          floatwi:=g.TextLength(rast,floatstr,st.Length(floatstr));
          IF floatwi>spalt(s1.ListSpalt).floatwidth THEN
            spalt(s1.ListSpalt).floatwidth:=floatwi;
          END;
          pointwi:=g.TextLength(rast,pointstr,st.Length(pointstr));
          IF pointwi>spalt(s1.ListSpalt).pointwidth THEN
            spalt(s1.ListSpalt).pointwidth:=pointwi;
          END;
        END;
        zeil:=zeil.next;
      END;
      IF list.dectab THEN
        width:=spalt(s1.ListSpalt).integwidth+spalt(s1.ListSpalt).floatwidth+spalt(s1.ListSpalt).pointwidth+list.design.width;
        IF width>spalt(s1.ListSpalt).width THEN
          spalt(s1.ListSpalt).width:=width;
        END;
      END;
      spalt:=spalt.next;
    END;
    xoff:=0;
    spalt:=list.spalten.head;
    WHILE spalt#NIL DO
      IF list.samewi THEN
        spalt(s1.ListSpalt).width:=width2;
      END;
      INC(xoff,spalt(s1.ListSpalt).width);
      spalt:=spalt.next;
    END;
    height:=rast.txHeight+list.design.height;

    (*list.lwidth:=0;
    list.lheight:=0;*)
    spalt:=list.spalten.head;
    x2:=xpos;
    WHILE spalt#NIL DO
      zeil:=spalt(s1.ListSpalt).zeilen.head;
      x:=x2;
      y:=ypos;
      IF list.topsep THEN
        first:=TRUE;
      END;
      breaknode:=NIL;
      WHILE zeil#NIL DO
        IF (y+height>=ypos+he) AND NOT(first) AND (breaknode=NIL) THEN
          y:=ypos;
          INC(x,xoff+10);
          IF list.topsep THEN
            breaknode:=zeil;
            zeil:=spalt(s1.ListSpalt).zeilen.head;
          END;
        ELSE
          breaknode:=NIL;
        END;
        IF x+spalt(s1.ListSpalt).width<=xpos+wi THEN
          g.SetAPen(rast,list.colf);
          g.SetBPen(rast,list.colb);
(*          g.SetAPen(rast,zeil(s1.ListZeil).color);*)
          IF list.center THEN
            tt.Print(x+list.design.left+(((spalt(s1.ListSpalt).width-list.design.width) DIV 2)-(g.TextLength(rast,zeil(s1.ListZeil).string,st.Length(zeil(s1.ListZeil).string)) DIV 2)),y+list.design.top+rast.txBaseline,s.ADR(zeil(s1.ListZeil).string),rast);
          ELSIF (list.dectab) AND NOT((list.topsep) AND (zeil=spalt(s1.ListSpalt).zeilen.head)) THEN
            GetDecTabStrings(zeil(s1.ListZeil).string,integstr,floatstr,pointstr);
            integwi:=g.TextLength(rast,integstr,st.Length(integstr));
            tt.Print(x+list.design.left+(spalt(s1.ListSpalt).integwidth-integwi),y+list.design.top+rast.txBaseline,s.ADR(zeil(s1.ListZeil).string),rast);
          ELSE
            tt.Print(x+list.design.left,y+list.design.top+rast.txBaseline,s.ADR(zeil(s1.ListZeil).string),rast);
          END;
          DrawField(rast,list.design,x,y,spalt(s1.ListSpalt).width-list.design.width,rast.txHeight);
          DrawHoriz(rast,list.design,xpos,y,list.lwidth,height);
          INC(y,height);
          IF (first) OR (breaknode#NIL) THEN
            INC(y,list.design.height);
            first:=FALSE;
          END;
          zeil:=zeil.next;
          IF breaknode#NIL THEN
            zeil:=breaknode;
          END;
        ELSE
          zeil:=NIL;
        END;
      END;
(*      IF y>list.lheight THEN
        list.lheight:=y-ypos;
      END;*)
      DrawVert(rast,list.design,x,ypos,spalt(s1.ListSpalt).width,list.lheight);
      INC(x2,spalt(s1.ListSpalt).width);
      spalt:=spalt.next;
      IF spalt#NIL THEN
        IF x2+spalt(s1.ListSpalt).width>xpos+wi THEN
          spalt:=NIL;
        END;
      END;
    END;
(*    list.lwidth:=x-xpos;
    IF list.design.hindex<5 THEN
      INC(list.lheight);
    END;
    IF (list.design.hindex=3) OR (list.design.hindex=4) THEN
      INC(list.lheight);
    END;*)
  END;
END RawPlotList;

PROCEDURE MarkListSpalt(rast:g.RastPortPtr;list:l.Node;xpos,ypos:INTEGER;actspalt:l.Node);

VAR width,height,
    width2       : INTEGER;
    node,node2,
    zeil,spalt   : l.Node;
    x,y,x2,y2    : INTEGER;
    must         : ARRAY 4 OF INTEGER;

BEGIN
  WITH list: s1.List DO
    must[0]:=0AAAAU;
    must[2]:=0AAAAU;
    must[1]:=05555U;
    must[3]:=05555U;
    g.SetAfPt(rast,s.ADR(must),2);
    spalt:=list.spalten.head;
    x:=xpos;
    WHILE spalt#NIL DO
      zeil:=spalt(s1.ListSpalt).zeilen.head;
      IF spalt=actspalt THEN
        g.SetAPen(rast,3);
        x2:=x+spalt(s1.ListSpalt).width-1;
        y2:=ypos+list.lheight-1;
        IF x2<x THEN
          x2:=x;
        END;
        IF y2<ypos THEN
          y2:=ypos;
        END;
        g.RectFill(rast,x,ypos,x2,y2);
      END;
      INC(x,spalt(s1.ListSpalt).width);
      spalt:=spalt.next;
    END;
    g.SetAfPt(rast,NIL,0);
  END;
END MarkListSpalt;

PROCEDURE PlotList*(list:l.Node);

VAR font   : g.TextFontPtr;

BEGIN
  WITH list: s1.List DO
    IF list.wind=NIL THEN
      IF list.width=-1 THEN
        list.width:=list.lwidth+26;
        list.height:=list.lheight+15;
      END;
      IF list.width<100 THEN
        list.width:=100;
      END;
      IF list.height<25 THEN
        list.height:=25;
      END;
      IF list.xpos+list.width>s1.screen.width THEN
        list.width:=s1.screen.width-list.xpos;
      END;
      IF list.ypos+list.height>s1.screen.height THEN
        list.height:=s1.screen.height-list.ypos;
      END;
      list.wind:=it.SetWindow(list.xpos,list.ypos,list.width,list.height,s.ADR(list.name),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.windowClose,I.noCareRefresh,I.reportMouse},
                              LONGSET{I.menuPick,I.rawKey,I.gadgetUp,I.gadgetDown,I.closeWindow,I.newSize,I.mouseButtons,I.mouseMove,I.activeWindow,I.inactiveWindow,I.vanillaKey},s1.screen);
      ok:=I.WindowLimits(list.wind,100,25,-1,-1);
      list.xpos:=list.wind.leftEdge;
      list.ypos:=list.wind.topEdge;
      list.width:=list.wind.width;
      list.height:=list.wind.height;
      list.rast:=list.wind.rPort;
      ok:=I.SetMenuStrip(list.wind,s1.menu^);
    END;
    pt.SetBusyPointer(list.wind);
    font:=df.OpenDiskFont(list.attr);
    g.SetFont(list.rast,font);
    g.SetRast(list.rast,0);
    RawPlotList(list.rast,list,6,12,list.width-26,list.height-15);
    I.RefreshWindowFrame(list.wind);
    g.CloseFont(font);
    pt.ClearPointer(list.wind);
  END;
END PlotList;

PROCEDURE * PrintZeil(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF actspalt#NIL THEN
    node:=s1.GetNode(actspalt(s1.ListSpalt).zeilen,num);
    IF node#NIL THEN
      WITH node: s1.ListZeil DO
        NEW(str);
        COPY(node.string,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str);
      END;
    END;
  END;
END PrintZeil;

PROCEDURE ChangeList*(list:l.Node):BOOLEAN;

VAR wind,listwind : I.WindowPtr;
    rast,listrast : g.RastPortPtr;
    ok,ca,
    help,
    anhsp,
    einfsp,
    delsp,
    design,
    copysp,
    samewi,
    center,
    dectab,
    separate,
    samefield,
    name,
    entry,
    anhze,
    einfze,
    delze,
    desze,
    range,
    calc,
    upe,downe,
    scrolle,
    leftx,rightx,
    scrollx,
    upy,downy,
    scrolly  : I.GadgetPtr;
    zeillist : l.Node;
    node,node2,
    node3,
    spalt,
    zeil,func: l.Node;
    actzeil,
    savelist : l.Node;
    actsp,
    acte,
    opose,
    pose,
    ypos,oypos,
    xpos,oxpos : INTEGER;
    pressede,
    booledown,
    booleup,
    pressedx,
    boolxright,
    boolxleft,
    pressedy,
    boolydown,
    boolyup  : BOOLEAN;
    x,y,x2,y2: INTEGER;
    nach     : INTEGER;
    exp      : BOOLEAN;
    start,end,
    step     : LONGREAL;
    text     : ARRAY 4 OF ARRAY 80 OF CHAR;
    root     : f1.NodePtr;
    real     : LONGREAL;
    ret      : BOOLEAN;
    nullstr  : ARRAY 256 OF CHAR;
    fontrequest : as.FontRequesterPtr;
    intui    : I.IntuiTextPtr;

PROCEDURE RefreshZeil;

BEGIN
  IF actzeil#NIL THEN
    gm.PutGadgetText(entry,actzeil(s1.ListZeil).string);
    I.RefreshGList(entry,wind,NIL,1);
    bool:=I.ActivateGadget(entry^,wind,NIL);
  END;
END RefreshZeil;

PROCEDURE NewZeilList;

BEGIN
  IF actspalt#NIL THEN
    gm.SetListViewParams(zeillist,26,131,204,54,SHORT(actspalt(s1.ListSpalt).zeilen.nbElements()),s1.GetNodeNumber(actspalt(s1.ListSpalt).zeilen,actzeil),PrintZeil);
    gm.SetNoEntryText(zeillist,ac.GetString(ac.None),ac.GetString(ac.RowsEx));
    gm.SetCorrectPosition(zeillist);
  ELSE
    gm.SetListViewParams(zeillist,26,131,204,54,0,0,PrintZeil);
    gm.SetNoEntryText(zeillist,ac.GetString(ac.None),ac.GetString(ac.ColumnsEx));
    gm.SetCorrectPosition(zeillist);
  END;
  gm.RefreshListView(zeillist);
END NewZeilList;

(*PROCEDURE RefreshZeilen;

VAR node : l.Node;
    str  : ARRAY 22 OF CHAR;

BEGIN
  IF actspalt#NIL THEN
    node:=actspalt(s1.ListSpalt).zeilen.head;
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
      IF i>5 THEN
        EXIT;
      END;
      IF node#NIL THEN
        IF node=actzeil THEN
          g.SetAPen(rast,3);
          g.RectFill(rast,30,118+i*10,209,127+i*10);
          g.SetAPen(rast,2);
        ELSE
          g.SetAPen(rast,0);
          g.RectFill(rast,30,118+i*10,209,127+i*10);
          g.SetAPen(rast,1);
        END;
        str:="                      ";
        COPY(node(s1.ListZeil).string,str);
        tt.Print(30,125+i*10,s.ADR(str),rast);
        node:=node.next;
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,30,118+i*10,209,127+i*10);
      END;
    END;
    IF actspalt(s1.ListSpalt).zeilen.nbElements()=0 THEN
      g.SetAPen(rast,2);
      tt.Print(46,146,ac.GetString(ac.NoLines),rast);
    END;
  ELSE
    g.SetAPen(rast,2);
    tt.Print(46,146,ac.GetString(ac.NoColumns),rast);
  END;
END RefreshZeilen;

PROCEDURE SetListPos;

BEGIN
  IF acte<pose THEN
    DEC(pose);
    IF pose<0 THEN
      pose:=0;
    END;
  ELSIF acte>pose+4 THEN
    INC(pose);
  END;
END SetListPos;*)

PROCEDURE SetNewListWindow(wi,he:INTEGER);

BEGIN
  IF listrast#NIL THEN
    it.FreeRastPort(listrast);
(*    is.CloseBitMapWindow(listwind);*)
  END;
  IF wi<209 THEN
    wi:=209;
  END;
  IF he<159 THEN
    he:=159;
  END;
  IF wi>1000 THEN
    wi:=1000;
  END;
  IF he>1000 THEN
    he:=1000;
  END;
  listrast:=it.AllocRastPort(wi,he,s1.screen.bitMap.depth);
(*  listwind:=is.SetBitMapWindow(s1.screen.width-1,s1.screen.height-1,1,1,wi,he,NIL,LONGSET{I.borderless,I.backDrop},LONGSET{},s1.screen);
  listrast:=listwind.rPort;*)
  g.SetDrMd(listrast,g.jam1);
END SetNewListWindow;

PROCEDURE RefreshList;

VAR font : g.TextFontPtr;

BEGIN
  pt.SetBusyPointer(wind);
  font:=df.OpenDiskFont(list(s1.List).attr);
  g.SetFont(listrast,font);
  RefreshListDatas(listrast,list);
  SetNewListWindow(list(s1.List).lwidth+4,list(s1.List).lheight+3);
  g.SetFont(listrast,font);
  g.SetRast(listrast,0);
(*  g.SetAPen(listrast,0);
  g.RectFill(listrast,392,30,500,100);
  g.SetAPen(listrast,1);*)
  MarkListSpalt(listrast,list,1,1,actspalt);
  RawPlotList(listrast,list,1,1,list(s1.List).lwidth+1,list(s1.List).lheight+1);
  IF ypos>list(s1.List).lheight-157 THEN
    ypos:=list(s1.List).lheight-157;
  END;
  IF ypos<0 THEN
    ypos:=0;
  END;
  g.ClipBlit(listrast,1+xpos,1+ypos,rast,392,30,208,158,s.VAL(s.BYTE,0C0H));
  g.CloseFont(font);
  pt.ClearPointer(wind);
END RefreshList;

PROCEDURE RefreshScrollers;

BEGIN
  gm.SetScroller(scrollx,wind,list(s1.List).lwidth+2,208,xpos);
  gm.SetScroller(scrolly,wind,list(s1.List).lheight+1,158,ypos);
END RefreshScrollers;

PROCEDURE SetToMaxFields;

VAR node,node2 : l.Node;
    max,i      : INTEGER;

BEGIN
  WITH list: s1.List DO
    max:=0;
    node:=list.spalten.head;
    WHILE node#NIL DO
      i:=SHORT(node(s1.ListSpalt).zeilen.nbElements());
      IF i>max THEN
        max:=i;
      END;
      node:=node.next;
    END;
    node:=list.spalten.head;
    WHILE node#NIL DO
      i:=SHORT(node(s1.ListSpalt).zeilen.nbElements());
      WHILE i<max DO
        INC(i);
        node2:=NIL;
        NEW(node2(s1.ListZeil));
        node2(s1.ListZeil).string:="";
        node2(s1.ListZeil).color:=1;
        node(s1.ListSpalt).zeilen.AddTail(node2);
      END;
      node:=node.next;
    END;
  END;
END SetToMaxFields;

PROCEDURE SetToMinFields;

VAR node,node2 : l.Node;
    max,i      : INTEGER;

BEGIN
  WITH list: s1.List DO
    max:=-1;
    node:=list.spalten.head;
    WHILE node#NIL DO
      i:=SHORT(node(s1.ListSpalt).zeilen.nbElements());
      IF max=-1 THEN
        max:=i;
      ELSIF i<max THEN
        max:=i;
      END;
      node:=node.next;
    END;
    node:=list.spalten.head;
    WHILE node#NIL DO
      i:=SHORT(node(s1.ListSpalt).zeilen.nbElements());
      WHILE i>max DO
        DEC(i);
        node(s1.ListSpalt).zeilen.tail.Remove;
      END;
      node:=node.next;
    END;
  END;
END SetToMinFields;

BEGIN
  ret:=FALSE;
  IF listId=-1 THEN
    listId:=wm.InitWindow(20,10,640,229,ac.GetString(ac.ChangeList),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,208,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(526,208,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,208,100,14,ac.GetString(ac.Help));
  anhsp:=gm.SetBooleanGadget(26,31,150,14,ac.GetString(ac.AddColumn));
  einfsp:=gm.SetBooleanGadget(26,46,150,14,ac.GetString(ac.InsertColumn));
  delsp:=gm.SetBooleanGadget(26,61,150,14,ac.GetString(ac.DeleteColumn));
  design:=gm.SetBooleanGadget(26,76,150,14,ac.GetString(ac.ListDesign));
  desze:=gm.SetBooleanGadget(26,91,150,14,ac.GetString(ac.Font));
  anhze:=gm.SetBooleanGadget(234,122,142,14,ac.GetString(ac.AppendField));
  einfze:=gm.SetBooleanGadget(234,137,142,14,ac.GetString(ac.InsertField));
  delze:=gm.SetBooleanGadget(234,152,142,14,ac.GetString(ac.DeleteField));
  range:=gm.SetBooleanGadget(234,167,142,14,ac.GetString(ac.ValueRange));
  calc:=gm.SetBooleanGadget(234,182,142,14,ac.GetString(ac.CalcColumn));
  INCL(calc.activation,I.toggleSelect);
  samewi:=gm.SetCheckBoxGadget(350,31,26,9,list(s1.List).samewi);
  center:=gm.SetCheckBoxGadget(350,42,26,9,list(s1.List).center);
  dectab:=gm.SetCheckBoxGadget(350,53,26,9,list(s1.List).dectab);
  separate:=gm.SetCheckBoxGadget(350,64,26,9,list(s1.List).topsep);
  samefield:=gm.SetCheckBoxGadget(350,75,26,9,list(s1.List).samefield);
  name:=gm.SetStringGadget(216,91,148,14,255);
  entry:=gm.SetStringGadget(26,185,192,14,255);
  zeillist:=gm.SetListView(26,131,204,54,0,0,PrintZeil);
  scrollx:=gm.SetPropGadget(388,190,216,12,0,0,32767,0);
  upy:=gm.SetArrowUpGadget(604,170);
  downy:=gm.SetArrowDownGadget(604,180);
  scrolly:=gm.SetPropGadget(604,28,16,142,0,0,0,32767);
  gm.EndGadgets;
  wm.SetGadgets(listId,ok);
  wm.ChangeScreen(listId,s1.screen);
  wind:=wm.OpenWindow(listId);
  IF wind#NIL THEN
    WITH list: s1.List DO
      rast:=wind.rPort;
(*      ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,204,100,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),524,204,100,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(anhsp,wind,s.ADR("Spalte anhängen"),24,30,150,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(einfsp,wind,s.ADR("Spalte einfügen"),24,45,150,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(delsp,wind,s.ADR("Spalte löschen"),24,60,150,
                        SET{I.gadgImmediate,I.relVerify});
(*      ig.SetPlastHighGadget(copysp,wind,s.ADR("Spalte kopieren"),24,75,150,
                        SET{I.gadgImmediate,I.relVerify});*)
      ig.SetPlastHighGadget(design,wind,s.ADR("Listenaussehen"),24,75,150,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(anhze,wind,s.ADR("Feld anhängen"),232,106,142,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(einfze,wind,s.ADR("Feld einfügen"),232,121,142,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(delze,wind,s.ADR("Feld löschen"),232,136,142,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(range,wind,s.ADR("Wertebereich"),232,151,142,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(calc,wind,s.ADR("Spalte berechnen"),232,166,142,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastHighGadget(desze,wind,s.ADR("Zeilenaussehen"),232,181,142,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetCheckBoxGadget(samewy,wind,350,31,
                        SET{I.gadgImmediate,I.sålVerqfy,I.toggleSelect});
      qg.SetCheckBoxGadget(center,wqnd,350,42,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSel}ct});
      qg.UetCheckBoxGadget1sepapate,wqnd,350,53,\¸8                      UET{I.gadgImmediate,I.relVerify,I.toggleUeleet});
&     ig.SetCheckBoxGadget1sameield,wind,350,V4,
                        SET{I.gadgImmediate,I.relVerify,I.toggleUelect});
    DO
      WITH node2: Table DO
        COPY(node.name,node2.name);
        CopyList(node.zeilen,node2.zeilen);
        node2.samewi:=node.samewi;
        node2.samecol:=node.samecol;
        node2.center:=node.center;
        node2.dectab:=node.dectab;
        node2.firstsep:=node.firstsep;
        CopyDesign(s.ADR(node.design),s.ADR(node2.design));
        CopyTextAttr(s.ADR(node.attr),s.ADR(node2.attr));
        node2.colf:=node.colf;
        node2.colb:=node.colb;
        node2.xpos:=node.xpos;
        node2.ypos:=node.ypos;
        node2.width:=node.width;
        node2.height:=node.height;
        node2.lwidth:=node.lwidth;
        node2.lheight:=node.lheight;
        node2.pwidth:=node.pwidth;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS List THEN
    WITH node: List DO
      WITH node2: List DO
        COPY(node.name,node2.name);
        CopyList(node.spalten,node2.spalten);
        node2.samewi:=node.samewi;
        node2.samecol:=node.samecol;
        node2.center:=node.center;
        node2.dectab:=node.dectab;
        node2.topsep:=node.topsep;
        node2.samefield:=node.samefield;
        CopyDesign(s.ADR(node.design),s.ADR(node2.design));
        node2.colf:=node.colf;
        node2.colb:=node.colb;
        node2.xpos:=node.xpos;
        node2.ypos:=node.ypos;
        node2.width:=node.width;
        node2.height:=node.height;
        node2.lwidth:=node.lwidth;
        node2.lheight:=node.lheight;
        node2.pwidth:=node.pheight;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS LegendElement THEN
    WITH node: LegendElement DO
      WITH node2: LegendElement DO
        COPY(node.term,node2.term);
        node2.col:=node.col;
        node2.line:=node.line;
        node2.width:=node.width;
        node2.point:=node.point;
        node2.sub:=node.sub;
      END;
    END;
  ELSIF node IS TableSpalt THEN
    WITH node: TableSpalt DO
      WITH node2: TableSpalt DO
        COPY(node.string,node2.string);
        node2.color:=node.color;
        node2.style:=node.style;
        node2.width:=node.width;
        node2.integwidth:=node.integwidth;
        node2.floatwidth:=node.floatwidth;
        node2.pointwidth:=node.pointwidth;
        node2.pwidth:=node.pwidth;
        node2.pintegwidth:=node.pintegwidth;
        node2.pfloatwidth:=node.pfloatwidth;
        node2.ppointwidth:=node.ppointwidth;
      END;
    END;
  ELSIF node IS TableZeil THEN
    WITH node: TableZeil DO
      WITH node2: TableZeil DO
        CopyList(node.spalten,node2.spalten);
        node2.samecol:=node.samecol;
        node2.samefont:=node.samefont;
        node2.height:=node.height;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS ListZeil THEN
    WITH node: ListZeil DO
      WITH node2: ListZeil DO
        COPY(node.string,node2.string);
        node2.color:=node.color;
        node2.style:=node.style;
      END;
    END;
  ELSIF node IS ListSpalt THEN
    WITH node: ListSpalt DO
      WITH node2: ListSpalt DO
        CopyList(node.zeilen,node2.zeilen);
        node2.samecol:=node.samecol;
        node2.samefont:=node.samefont;
        node2.width:=node.width;
        node2.integwidth:=node.integwidth;
        node2.floatwidth:=node.floatwidth;
        node2.pointwidth:=node.pointwidth;
        node2.pwidth:=node.pwidth;
        node2.pintegwidth:=node.pintegwidth;
        node2.pfloatwidth:=node.pfloatwidth;
        node2.ppointwidth:=node.ppointwidth;
      END;
    END;
  END;
END CopyNode;

PROCEDURE CopyList*(list:l.List;VAR list2:l.List);

VAR node,node2 : l.Node;

BEGIN
  IF list#NIL THEN
    node:=list.head;
    node2:=list2.head;
    WHILE node#NIL DO
      IF node2=NIL THEN
        IF node IS Term THEN
          NEW(node2(Term));
        ELSIF node IS Depend THEN
          NEW(node2(Depend));
        ELSIF node IS Define THEN
          NEW(node2(Define));
        ELSIF node IS FuncTerm THEN
          NEW(node2(FuncTerm));
        ELSIF node IS LegendElement THEN
          NEW(node2(LegendElement));
        ELSIF node IS TableZeil THEN
          NEW(node2(TableZeil));
        ELSIF node IS TableSpalt THEN
          NEW(node2(TableSpalt));
        ELSIF node IS ListZeil THEN
          NEW(node2(ListZeil));
        ELSIF node IS ListSpalt THEN
          NEW(node2(ListSpalt));
        END;
        list2.AddTail(node2);
      END;
      CopyNode(node,node2);
      node:=node.next;
      node2:=node2.next;
    END;
  END;
END CopyList;

(*PROCEDURE CopyNodeNew*(node:l.Node):l.Node;

VAR node2 : l.Node;

PROCEDURE CopyList(node:l.List):l.List;

VAR list  : node(s1.TableSpalt).string:="";
              node(s1.TableSpalt).color:=1;
              IF actspalt#NIL THEN
                actspalt.AddBefore(node);
              ELSE
                actzeil(s1.TableZeil).spalten.AddTail(node);
              END;
              actspalt:=node;
              AddInEveryLine(actzeil,actspalt);
              NewSpaltList;
              RefreshSpalt;
(*              SetListPos;
              RefreshSpalten;*)
              RefreshTable;
              RefreshScrollers;
(*              gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
              bool:=I.ActivateGadget(string^,wind,NIL);*)
            END;
          ELSIF address=delsp THEN
            IF actzeil#NIL THEN
              IF actspalt#NIL THEN
                node:=NIL;
                IF actspalt.next#NIL THEN
                  node:=actspalt.next;
                ELSIF actspalt.prev#NIL THEN
                  node:=actspalt.prev;
                END;
                DeleteInEveryLine(actzeil,actspalt);
                actspalt.Remove;
                actspalt:=node;
                NewSpaltList;
                RefreshSpalt;
(*                SetListPos;
                RefreshSpalten;*)
                RefreshTable;
                RefreshScrollers;
(*                IF actspalt#NIL THEN
                  gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
                  I.RefreshGList(string,wind,NIL,1);
                  bool:=I.ActivateGadget(string^,wind,NIL);
                END;*)
              END;
            END;
          ELSIF address=range THEN
            IF actzeil#NIL THEN
              bool:=s8.NumberRange(s8.nach,s8.exp,s8.start,s8.end,s8.step);
              IF bool THEN
                pt.SetBusyPointer(wind);
                start:=s8.start;
                end:=s8.end;
                step:=s8.step;
                start:=start-step;
                WHILE start<end DO
                  start:=start+step;
                  node:=NIL;
                  NEW(node(s1.TableSpalt));
                  bool:=lrc.RealToString(start,node(s1.TableSpalt).string,7,s8.nach,s8.exp);
                  tt.Clear(node(s1.TableSpalt).string);
                  node(s1.TableSpalt).color:=1;
                  IF actspalt#NIL THEN
                    actspalt.AddBefore(node);
                  ELSIF actspalt=NIL THEN
                    actzeil(s1.TableZeil).spalten.AddTail(node);
                  END;
                  AddInEveryLine(actzeil,node);
                  INC(acte);
                END;
                actspalt:=node;
                NewSpaltList;
                RefreshSpalt;
  (*              SetListPos;
                RefreshSpalten;*)
                RefreshTable;
                RefreshScrollers;
  (*              gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
                I.RefreshGList(string,wind,NIL,1);
                bool:=I.ActivateGadget(string^,wind,NIL);*)
                pt.ClearPointer(wind);
              END;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.TheTableMustContainAtLeast),ac.GetString(ac.OneRowForThisFunction),s.ADR(""),ac.GetString(ac.OK),wind);
            END;
          ELSIF address=calc THEN
            IF (actzeil#NIL) AND (table.zeilen.nbElements()>1) THEN
(*              text[0]:="Wählen Sie zuerst die Spalte aus, die die x-Werte";
              text[1]:="für die zu berechnenden Stellen enthält.";
              text[2]:="Danach wählen Sie die Funktion, mit der die";
              text[3]:="Stellen berechnet werden sollen.";
              bool:=s1.Request(text,"Weiter","Abbruch",wind);*)
              bool:=TRUE;
              IF bool THEN
                intui:=calc.gadgetText;
                intui.iText:=ac.GetString(ac.SelectRowWithXValues);
                I.RefreshGList(calc,wind,NIL,1);
                node:=NIL;
                REPEAT
                  e.WaitPort(wind.userPort);
                  it.GetIMes(wind,class,code,address);
                  IF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
                    it.GetMousePos(wind,x,y);
                    IF (x>=24) AND (x<=612) AND (y>=30) AND (y<=103) THEN
                      x2:=x-24;
                      y2:=y-30;
                      INC(x2,xpos);
                      INC(y2,ypos);
                      zeil:=table.zeilen.head;
                      y:=0;
                      WHILE zeil#NIL DO
                        IF (y2>=y) AND (y2<y+zeil(s1.TableZeil).height) THEN
                          node:=zeil;
                        END;
                        INC(y,zeil(s1.TableZeil).height);
                        zeil:=zeil.next;
                      END;
                    END;
                  END;
                UNTIL (node#NIL) OR (code=I.menuPick) OR ((I.gadgetUp IN class) AND (address=calc));
                intui.iText:=ac.GetString(ac.CalcRow);
                I.RefreshGList(calc,wind,NIL,1);
                gm.DeActivateBool(calc,wind);
                IF node#NIL THEN
                  func:=NIL;
                  func:=s2.SelectNode(s1.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.FunctionsAreEntered));
                  IF func#NIL THEN
                    bool:=s8.NumberFormat(s8.nach,s8.exp);
                    pt.SetBusyPointer(wind);
(*                    i:=0;
                    root:=f.Parse(node2(s1.Term).string,i);*)
                    node:=node(s1.TableZeil).spalten.head;
                    node2:=actzeil(s1.TableZeil).spalten.head;
(*                    actspalt(s1.ListSpalt).zeilen.Init;*)
                    WHILE node#NIL DO
                      IF node2=NIL THEN
                        NEW(node2(s1.TableSpalt));
                        node2(s1.TableSpalt).string:="";
                        node2(s1.TableSpalt).color:=1;
                        actzeil(s1.TableZeil).spalten.AddTail(node2);
                      END;
                      bool:=lrc.StringToReal(node(s1.TableSpalt).string,real);
                      IF bool THEN
                        i:=0;
                        real:=s2.GetFunctionValue(func,real,0,i);
                        IF i=0 THEN
                          bool:=lrc.RealToString(real,node2(s1.TableSpalt).string,7,s8.nach,s8.exp);
                          tt.Clear(node2(s1.TableSpalt).string);
                        ELSE
                          node2(s1.TableSpalt).string:="--";
                        END;
                      END;
                      node:=node.next;
                      node2:=node2.next;
                    END;
                    actspalt:=actzeil(s1.TableZeil).spalten.head;
                    NewSpaltList;
                    RefreshSpalt;
(*                    SetListPos;
                    RefreshSpalten;*)
                    RefreshTable;
                    RefreshScrollers;
(*                    IF actspalt#NIL THEN
                      gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
                      I.RefreshGList(string,wind,NIL,1);
                      bool:=I.ActivateGadget(string^,wind,NIL);
                    END;*)
                    pt.ClearPointer(wind);
                  END;
                END;
              END;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.TheTableMustContainAtLeast),ac.GetString(ac.TwoRowsForThisFunction),s.ADR(""),ac.GetString(ac.OK),wind);
            END;
            gm.DeActivateBool(calc,wind);
          ELSIF address=string THEN
            NewSpaltList;
(*            RefreshSpalten;*)
            RefreshTable;
            RefreshScrollers;
            bool:=I.ActivateGadget(string^,wind,NIL);
          ELSIF address=samewi THEN
            table.samewi:=NOT(table.samewi);
            RefreshTable;
            RefreshScrollers;
          ELSIF address=center THEN
            table.center:=NOT(table.center);
            IF table.center THEN
              table.dectab:=FALSE;
              gm.DeActivateBool(dectab,wind);
            END;
            RefreshTable;
            RefreshScrollers;
          ELSIF address=dectab THEN
            table.dectab:=NOT(table.dectab);
            IF table.dectab THEN
              table.center:=FALSE;
              gm.DeActivateBool(center,wind);
            END;
            RefreshTable;
            RefreshScrollers;
          ELSIF address=firstsep THEN
            table.firstsep:=NOT(table.firstsep);
            RefreshTable;
            RefreshScrollers;
          END;
        ELSIF I.mouseButtons IN class THEN
          IF code=I.selectDown THEN
            it.GetMousePos(wind,x,y);
(*            IF (x>488) AND (x<592) AND (y>122) AND (y<173) THEN
              IF actspalt#NIL THEN
                y:=y-122;
                y:=y DIV 10;
                acte:=y+pose;
                INC(acte);
                REPEAT
                  DEC(acte);
                  node:=s1.GetNode(actzeil(s1.TableZeil).spalten,acte);
                UNTIL (node#NIL) OR (acte=-1);
                actspalt:=node;
                RefreshSpalten;
                IF actspalt#NIL THEN
                  RefreshSpalten;
                  gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
                  I.RefreshGList(string,wind,NIL,1);
                  bool:=I.ActivateGadget(string^,wind,NIL);
                END;
              END;*)
            IF (x>=24) AND (x<=618) AND (y>=30) AND (y<=103) THEN
              x2:=x-24;
              y2:=y-30;
              INC(x2,xpos);
              INC(y2,ypos);
              zeil:=table.zeilen.head;
              y:=0;
              WHILE zeil#NIL DO
                IF (y2>=y) AND (y2<y+zeil(s1.TableZeil).height) THEN
                  actzeil:=zeil;
                  actspalt:=actzeil(s1.TableZeil).spalten.head;
(*                  IF actspalt#NIL THEN
                    RefreshSpalten;
                    gm.PutGadgetText(string,actspalt(s1.TableSpalt).string);
                    I.RefreshGList(string,wind,NIL,1);
                    bool:=I.ActivateGadget(string^,wind,NIL);
                  END;*)
                  acte:=0;
                  NewSpaltList;
                  RefreshSpalt;
(*                  RefreshSpalten;*)
                  RefreshTable;
                  RefreshScrollers;
                END;
                INC(y,zeil(s1.TableZeil).height);
                zeil:=zeil.next;
              END;
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"tables",wind);
        END;
      END;

      IF tablerast#NIL THEN
        it.FreeRastPort(tablerast);
      END;
(*      IF tablewind#NIL THEN
        is.CloseBitMapWindow(tablewind);
      END;*)
      IF fontrequest#NIL THEN
        as.FreeAslRequest(fontrequest);
      END;
      wm.CloseWindow(tableId);
      s1.FreeNode(savetable);
    END;
  END;
  wm.FreeGadgets(tableId);
  RETURN ret;
END ChangeTable;

BEGIN
  tableId:=-1;
END SuperCalcTools11.

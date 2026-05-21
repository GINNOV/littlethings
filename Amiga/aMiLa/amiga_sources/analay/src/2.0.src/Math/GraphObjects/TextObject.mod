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


MODULE TextObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       as : ASL,
       ac : AnalayCatalog,
       at : AslTools,
       wm : WindowManager,
       fm : FontManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mg : MathGUI,
       co : Coords,
       dc : DisplayConversion,
       cb : CoordObject,
       go : GraphObject,
       NoGuruRq;

TYPE TextObject * = POINTER TO TextObjectDesc;
     TextObjectDesc * = RECORD(go.GraphObjectDesc)
     END;

VAR stdtextobj * : TextObject;

PROCEDURE (textobj:TextObject) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable);

VAR worldx,worldy : LONGREAL;
    font          : fm.Font;
    string        : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    xp,yp         : INTEGER;
    real          : LONGREAL;
    txBaseline    : INTEGER;
    bool          : BOOLEAN;

BEGIN
  IF textobj.window#NIL THEN
    textobj.GetCoordsWorld(textobj.window.rect,worldx,worldy);
    IF textobj.movingobject THEN
      g.SetDrMd(rast,SHORTSET{g.complement});
    ELSE
      textobj.SetDrawModes(rast);
    END;

(* Font stuff *)

    IF (textobj.fontinfo.changed) OR (textobj.font=NIL) THEN
      IF textobj.font#NIL THEN textobj.font.Destruct; END;
      textobj.font:=textobj.fontinfo.Open();
    END;
    font:=conv.GetFont(textobj.font);
    bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
  
    COPY(textobj.string,string);
    textobj.numberformat.ParseString(string,worldx,worldy,0);
    textobj.GetCoordsPic(textobj.window.rect,xp,yp);
    font.Print(rast,xp,yp+txBaseline,s.ADR(string));
    IF font#textobj.font THEN
      font.Destruct;
    END;
    g.SetDrMd(rast,g.jam1);
  END;
END Plot;

PROCEDURE (textobj:TextObject) PlotBorder*(rast:g.RastPortPtr);

VAR real,
    worldx,worldy: LONGREAL;
    string       : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    font         : fm.Font;
    xpos,ypos,
    width,height : INTEGER;
    txBaseline,
    txHeight     : INTEGER;
    bool         : BOOLEAN;

BEGIN
  font:=textobj.font;
  bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
  bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
  textobj.GetCoordsWorld(textobj.window.rect,worldx,worldy);
  textobj.GetCoordsPic(textobj.window.rect,xpos,ypos);

  COPY(textobj.string,string);
  textobj.numberformat.ParseString(string,worldx,worldy,0);

  width:=SHORT(SHORT(SHORT(font.TextWidthPix(textobj.window.rast,s.ADR(textobj.string)))));
  height:=txHeight;

  g.SetDrMd(rast,SHORTSET{g.complement});

  g.Move(rast,xpos,ypos);
  g.Draw(rast,xpos+width,ypos);
  g.Draw(rast,xpos+width,ypos+height);
  g.Draw(rast,xpos,ypos+height);
  g.Draw(rast,xpos,ypos);

  g.SetDrMd(rast,g.jam1);
END PlotBorder;

PROCEDURE (textobj:TextObject) Clicked*(mouseX,mouseY:LONGINT):BOOLEAN;

VAR real,
    worldx,worldy: LONGREAL;
    string       : ARRAY 2048 OF CHAR; (* Pay attention with the stack size! *)
    font         : fm.Font;
    xpos,ypos,
    width,height : INTEGER;
    txBaseline,
    txHeight     : INTEGER;
    bool         : BOOLEAN;

BEGIN
  font:=textobj.font;
  bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
  bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));
  textobj.GetCoordsWorld(textobj.window.rect,worldx,worldy);
  textobj.GetCoordsPic(textobj.window.rect,xpos,ypos);

  COPY(textobj.string,string);
  textobj.numberformat.ParseString(string,worldx,worldy,0);

  width:=SHORT(SHORT(SHORT(font.TextWidthPix(textobj.window.rast,s.ADR(textobj.string)))));
  height:=txHeight;

  IF (mouseX>=xpos) AND (mouseX<xpos+width) AND (mouseY>=ypos) AND (mouseY<ypos+height) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Clicked;

(*PROCEDURE (textobj:TextObject) InitClickRect*;

VAR real       : LONGREAL;
    font       : fm.Font;
    txBaseline,
    txHeight   : INTEGER;
    bool       : BOOLEAN;

BEGIN
  IF textobj.window.rast#NIL THEN
    font:=textobj.font;
    bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
    bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));

    textobj.clickrect.xoff:=0;
    textobj.clickrect.yoff:=txBaseline-1;
    textobj.clickrect.width:=SHORT(SHORT(SHORT(font.TextWidthPix(textobj.window.rast,s.ADR(textobj.string)))));
    textobj.clickrect.height:=txHeight;
  END;
END InitClickRect;*)



VAR textwind : wm.Window;

PROCEDURE (textobj:TextObject) Change*(changetask:m.Task):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    textgad     : gmo.StringGadget;
    font        : gmo.BooleanGadget;
    palettef,
    paletteb    : gmo.PaletteGadget;
    bold,italic,
    under,trans : gmo.CheckboxGadget;
    xpos,ypos   : gmo.StringGadget;
    snap,(*        : gmo.CheckboxGadget;*)
    coords      : gmo.CycleGadget;
    mouse       : gmo.BooleanGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    msg         : m.Message;
    class       : LONGSET;
    snaparray   : ARRAY 4 OF e.STRPTR;
    coordsarray : ARRAY 3 OF e.STRPTR;
    string      : ARRAY 256 OF CHAR;
    i           : INTEGER;
    fontstyle   : SHORTSET;
    didchange,
    bool,ret    : BOOLEAN;
(*    textstr : ARRAY 256 OF CHAR;
    xposstr,
    yposstr : ARRAY 80 OF CHAR;
    actcolf,
    actcolb : INTEGER;
    style   : SHORTSET;
    transb,
    snap    : BOOLEAN;
    x,y     : INTEGER;
    realx,
    realy   : REAL;
    longx,
    longy   : LONGREAL;
    auto    : ARRAY 5 OF CHAR;
    node,
    savetext: l.Node;*)

PROCEDURE RefreshCoords;

(* Refreshs the GADGETS! *)

VAR xcoords,ycoords : ARRAY 80 OF CHAR;

BEGIN
  textobj.GetCoordStrings(xcoords,ycoords);
  xpos.SetString(xcoords);
  ypos.SetString(ycoords);
  IF textobj.snaptype=cb.snapToFunc THEN
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
  textobj.SetCoordStrings(NIL,xcoords,ycoords);
  textobj.Snap;
END GetCoords;

PROCEDURE GetInput;

BEGIN
  textobj.Lock(FALSE);
  textgad.GetString(textobj.string);
  textobj.colorf:=SHORT(palettef.GetValue());
  textobj.colorb:=SHORT(paletteb.GetValue());
  bool:=bold.Checked();
  IF bool THEN INCL(fontstyle,g.bold);
          ELSE EXCL(fontstyle,g.bold); END;
  bool:=italic.Checked();
  IF bool THEN INCL(fontstyle,g.italic);
          ELSE EXCL(fontstyle,g.italic); END;
  bool:=under.Checked();
  IF bool THEN INCL(fontstyle,g.underlined);
          ELSE EXCL(fontstyle,g.underlined); END;
  textobj.font.SetStyle(fontstyle);
  textobj.transparent:=trans.Checked();

  textobj.SetSnapType(SHORT(snap.GetValue()));
(*  IF snap.Checked() THEN
    textobj.SetSnapType(cb.snapToFunc);
  ELSE
    textobj.SetSnapType(cb.snapToNowhere);
  END;*)
  GetCoords;
  textobj.UnLock;
END GetInput;

PROCEDURE SetData;

BEGIN
  RefreshCoords;
END SetData;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF textwind=NIL THEN
    textwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeText),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=textwind.InitSub(mg.screen);

  fontstyle:=textobj.font.GetStyle();

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Text));
      textgad:=gmo.SetStringGadget(ac.GetString(ac.Input),255,gmo.stringType);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          palettef:=gmo.SetPaletteGadget(ac.GetString(ac.ForegroundColor),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),textobj.colorf);
          paletteb:=gmo.SetPaletteGadget(ac.GetString(ac.BackgroundColor),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),textobj.colorb);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          font:=gmo.SetBooleanGadget(ac.GetString(ac.Font),FALSE);
            IF g.bold IN fontstyle THEN bool:=TRUE; ELSE bool:=FALSE; END;
          bold:=gmo.SetCheckboxGadget(ac.GetString(ac.Bold),bool);
            IF g.italic IN fontstyle THEN bool:=TRUE; ELSE bool:=FALSE; END;
          italic:=gmo.SetCheckboxGadget(ac.GetString(ac.Italic),bool);
            IF g.underlined IN fontstyle THEN bool:=TRUE; ELSE bool:=FALSE; END;
          under:=gmo.SetCheckboxGadget(ac.GetString(ac.Underlined),bool);
          trans:=gmo.SetCheckboxGadget(ac.GetString(ac.Transparent),textobj.transparent);
          root.NewSameTextWidth;
            root.AddSameTextWidth(bold);
            root.AddSameTextWidth(italic);
            root.AddSameTextWidth(under);
            root.AddSameTextWidth(trans);
        gmb.EndBox;
      gmb.EndBox;
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Coordinates));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        xpos:=gmo.SetStringGadget(ac.GetString(ac.XCoord),79,gmo.realType);
        xpos.SetMinVisible(10);
        ypos:=gmo.SetStringGadget(ac.GetString(ac.YCoord),79,gmo.realType);
        ypos.SetMinVisible(10);
(*          IF textobj.snaptype=cb.snapToFunc THEN bool:=TRUE; ELSE bool:=FALSE; END;
        snap:=gmo.SetCheckboxGadget(ac.GetString(ac.SnapToGraph),bool);*)
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
(*        mouse:=gmo.SetBooleanGadget(ac.GetString(ac.Mouse),FALSE);*)
        coordsarray[0]:=ac.GetString(ac.AxesCoordinates);
        coordsarray[1]:=ac.GetString(ac.ScreenCoordinates);
        coordsarray[2]:=NIL;
          IF textobj.GetWorld() THEN i:=0; ELSE i:=1; END;
        coords:=gmo.SetCycleGadget(NIL,s.ADR(coordsarray),i);

        snaparray[0]:=s.ADR("Snap to nowhere");
        snaparray[1]:=ac.GetString(ac.SnapToGraph);
        snaparray[2]:=NIL;
        snap:=gmo.SetCycleGadget(NIL,s.ADR(snaparray),textobj.snaptype);
      gmb.EndBox;
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  textgad.SetString(textobj.string);
(*  mouse.Disable(TRUE);*)
  IF textobj.snaptype=cb.snapToFunc THEN
    ypos.Disable(TRUE);
  END;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    RefreshCoords;
    textgad.Activate;

(*    attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
    COPY(p.scale.attr.name^,attr.name^);
    attr.ySize:=p.scale.attr.ySize;
    attr.style:=p.scale.attr.style;*)
(*    fontrequest:=NIL;*)

(* node:=p *)

(*    auto:="Auto";*)

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
            textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            IF didchange THEN
              textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
  
            EXIT;
(*          ELSIF mes.iAddress=mouse.gadget THEN
            IF textobj.window#NIL THEN
              GetInput;
              textobj.window.Lock(FALSE);
              REPEAT
                textobj.window.GetIMes(mes);
              UNTIL mes.class=LONGSET{};
              I.WindowToFront(textobj.window.iwind);
              I.ActivateWindow(textobj.window.iwind);
  
              bool:=textobj.Move(mes);

              IF bool THEN
                didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
              END;
              RefreshCoords;
              I.WindowToFront(wind);
              I.ActivateWindow(wind);
              textobj.window.UnLock;
            END;*)
          ELSIF mes.iAddress=font.gadget THEN
  (*          bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectFontForText),wind,s.ADR(textobj.attr),at.nocols,at.nocols);*)
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=snap.gadget THEN
            textobj.SetSnapType(SHORT(snap.GetValue()));
(*            IF snap.Checked() THEN
              textobj.SetSnapType(cb.snapToFunc);
            ELSE
              textobj.SetSnapType(cb.snapToNowhere);
            END;*)
            IF textobj.snaptype=cb.snapToNowhere THEN
              ypos.Disable(FALSE);
            ELSE
              textobj.Snap;
              RefreshCoords;
              ypos.Disable(TRUE);
            END;
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=coords.gadget THEN
            IF textobj.window#NIL THEN
              textobj.SetWorld(textobj.window.rect,~textobj.GetWorld());
            ELSE
              textobj.SetWorld(NIL,~textobj.GetWorld());
            END;
            RefreshCoords;
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=xpos.gadget THEN
            GetCoords;
            RefreshCoords;
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF mes.iAddress=ypos.gadget THEN
            GetCoords;
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetInput;
            didchange:=TRUE; textobj.window.SendNewMsg(m.msgNodeChanged,NIL);
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"texts",wind);
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

BEGIN
  stdtextobj:=NIL;
  NEW(stdtextobj); stdtextobj.Init;
CLOSE
  IF stdtextobj#NIL THEN stdtextobj.Destruct; END;
END TextObject.


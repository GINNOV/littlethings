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


MODULE Page;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       ag : AmigaGuideTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       lb : LayoutBasics,
       pi : PlotInfo,
       col: Colors,
       ra : Raster,
       bo : Box,
       ru : Ruler,
       ac : AnalayCatalog,
       NoGuruRq;

(*TYPE PageDims * = POINTER TO PageDimsDesc;
     PageDimsDesc * = RECORD(l.NodeDesc);
     END;*)

TYPE Page * = POINTER TO PageDesc;
     PageDesc * = RECORD(l.NodeDesc)
       boxes         * : l.List;     (* Head element in list lies behind all other boxes, tail element in front of all. *)
       width*,height * : LONGREAL;   (* in cm *)
       widths*,heights*: ARRAY 256 OF CHAR;
(*       backcol       * : c.Color;*)
       actbox        * : bo.Box;     (* Currently active box on page *)
       sec1,mic1,
       sec2,mic2       : LONGINT;    (* To check doubleclick *)
     END;

VAR stdpage * : Page;

PROCEDURE (page:Page) Init*;

BEGIN
  page.Init^;
  page.boxes:=l.Create();
  page.actbox:=NIL;
  page.width:=stdpage.width;
  page.height:=stdpage.height;
  COPY(stdpage.widths,page.widths);
  COPY(stdpage.heights,page.heights);
  page.sec1:=0; page.mic1:=0;
  page.sec2:=0; page.mic2:=0;
END Init;

PROCEDURE (page:Page) Destruct*;

BEGIN
  IF page.boxes#NIL THEN page.boxes.Destruct; END;
  page.Destruct^;
END Destruct;

PROCEDURE (page:Page) CopyB*(dest:l.Node);

BEGIN
  WITH dest: Page DO
    dest.width:=page.width;
    dest.height:=page.height;
    COPY(page.widths,dest.widths);
    COPY(page.heights,dest.heights);
  END;
END CopyB;

PROCEDURE (page:Page) AllocNew*():l.Node;

VAR node : Page;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE (page:Page) AddBox*(box:bo.Box);

BEGIN
  page.boxes.AddTail(box);
END AddBox;

PROCEDURE (page:Page) DeleteBox*(box:bo.Box);

BEGIN
  box.Remove;
  box.Destruct;
END DeleteBox;

PROCEDURE (page:Page) AdaptRuler*(ruler:ru.Ruler);

BEGIN
  ruler.xmin:=0;
  ruler.xmax:=page.width;
  ruler.ymin:=0;
  ruler.ymax:=page.height;
END AdaptRuler;

PROCEDURE (page:Page) PlotPlain*(plotinfo:pi.PlotInfo);

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche : LONGINT;
    i           : INTEGER;

BEGIN
  rast:=plotinfo.rast;
  plotinfo.rect.SetClipRegion(plotinfo.subwind);

  plotinfo.CMToPicRect(0,0,picx,picy,NIL);
  plotinfo.CMToPic(page.width,page.height,picwi,piche);

(* Plotting background of page *)
  i:=col.white.SetColor(plotinfo,col.setFrontPen);
  g.RectFill(rast,SHORT(picx),SHORT(picy),SHORT(picx+picwi),SHORT(picy+piche));

(* Clearing outsides *)
  g.SetAPen(rast,0);
  g.RectFill(rast,SHORT(picx+picwi+1),SHORT(picy),SHORT(picx+plotinfo.rect.width-1),SHORT(picy+plotinfo.rect.height-1));
  g.RectFill(rast,SHORT(picx),SHORT(picy+piche+1),SHORT(picx+plotinfo.rect.width-1),SHORT(picy+plotinfo.rect.height-1));

(* Plotting shadow of page *)
  i:=col.black.SetColor(plotinfo,col.setFrontPen);
  g.RectFill(rast,SHORT(picx+10),SHORT(picy+piche+1),SHORT(picx+picwi+10),SHORT(picy+piche+10));
  g.RectFill(rast,SHORT(picx+picwi+1),SHORT(picy+10),SHORT(picx+picwi+10),SHORT(picy+piche+10));

  plotinfo.rect.RemoveClipRegion(plotinfo.subwind);
END PlotPlain;

PROCEDURE (page:Page) Plot*(plotinfo:pi.PlotInfo);

VAR rast : g.RastPortPtr;
    box  : l.Node;

BEGIN
  rast:=plotinfo.rast;
  plotinfo.rect.SetClipRegion(plotinfo.subwind);

(* Plotting boxes *)

  box:=page.boxes.head;
  WHILE box#NIL DO
    box(bo.Box).Plot(plotinfo);
    box:=box.next;
  END;

  plotinfo.rect.RemoveClipRegion(plotinfo.subwind);
END Plot;

PROCEDURE (page:Page) PlotBoxBorders*(plotinfo:pi.PlotInfo);

VAR box : l.Node;

BEGIN
  plotinfo.rect.SetClipRegion(plotinfo.subwind);
  box:=page.boxes.head;
  WHILE box#NIL DO
    IF box=page.actbox THEN
      box(bo.Box).PlotBorder(plotinfo,bo.standardBorder,TRUE);
    ELSIF lb.layoutoptions.showinact THEN
      box(bo.Box).PlotBorder(plotinfo,bo.standardBorder,FALSE);
    END;
    box:=box.next;
  END;
  plotinfo.rect.RemoveClipRegion(plotinfo.subwind);
END PlotBoxBorders;

PROCEDURE (page:Page) PlotAll*(plotinfo:pi.PlotInfo);

BEGIN
  page.PlotPlain(plotinfo);
  page.Plot(plotinfo);
  page.PlotBoxBorders(plotinfo);
END PlotAll;

PROCEDURE (page:Page) InputEvent*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr);

VAR box,next : l.Node;
    clicked  : BOOLEAN;
    bool,
    refresh  : BOOLEAN;

BEGIN
  plotinfo.rect.SetClipRegion(plotinfo.subwind);
  refresh:=FALSE;
  IF (I.mouseButtons IN mes.class) & (mes.code=I.selectDown) THEN
    clicked:=FALSE;
    box:=page.boxes.tail;
    WHILE box#NIL DO
      next:=box.prev;
      IF box(bo.Box).CheckClicked(plotinfo,mes.mouseX,mes.mouseY) THEN
        clicked:=TRUE;
        page.sec1:=page.sec2; page.mic1:=page.mic2;
        I.CurrentTime(page.sec2,page.mic2);
        IF box=page.actbox THEN
          bool:=box(bo.Box).Clicked(plotinfo,raster,mes);
          IF ~bool & I.DoubleClick(page.sec1,page.mic1,page.sec2,page.mic2) THEN
            (* Double clicked on page *)
            page.sec2:=0; page.mic2:=0;
            refresh:=box(bo.Box).ChangeCoords();
          ELSIF bool THEN refresh:=TRUE;
          END;
        ELSE
          IF page.actbox#NIL THEN
            page.actbox.PlotBorder(plotinfo,bo.standardBorder,TRUE);
            IF lb.layoutoptions.showinact THEN
              page.actbox.PlotBorder(plotinfo,bo.standardBorder,FALSE);
            END;
          END;
          page.actbox:=box(bo.Box);
          IF lb.layoutoptions.showinact THEN
            box(bo.Box).PlotBorder(plotinfo,bo.standardBorder,FALSE);
          END;
          box(bo.Box).PlotBorder(plotinfo,bo.standardBorder,TRUE);
          bool:=box(bo.Box).Clicked(plotinfo,raster,mes);
          IF bool THEN refresh:=TRUE; END;
        END;
        next:=NIL;
      END;
      box:=next;
    END;
    IF ~clicked THEN
      IF page.actbox#NIL THEN
        page.actbox.PlotBorder(plotinfo,bo.standardBorder,TRUE);
        IF lb.layoutoptions.showinact THEN
          page.actbox.PlotBorder(plotinfo,bo.standardBorder,FALSE);
        END;
        page.actbox:=NIL;
      END;
    END;
  END;
  plotinfo.rect.RemoveClipRegion(plotinfo.subwind);
  IF refresh THEN
    page.PlotPlain(plotinfo);
    raster.Plot(plotinfo);
    page.Plot(plotinfo);
    page.PlotBoxBorders(plotinfo);
    page.sec2:=0; page.mic2:=0;
  END;
END InputEvent;



VAR changepagedimswind * : wm.Window;

PROCEDURE (page:Page) ChangeDims*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    text       : gmo.Text;
    widthgad,
    heightgad  : gmo.StringGadget;
    defaultgad : gmo.RadioButtons;
    gadbox     : gmb.Box;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    msg        : m.Message;
    class      : LONGSET;
    defaultarray:ARRAY 7 OF e.STRPTR;
    backup     : Page;
    bool,ret,
    didchange  : BOOLEAN;

  PROCEDURE SetData;

  BEGIN
    widthgad.SetString(page.widths);
    heightgad.SetString(page.heights);
  END SetData;

  PROCEDURE Equal(real1,real2:LONGREAL):BOOLEAN;

  BEGIN
    real1:=real1*100; real2:=real2*100;
    IF SHORT(SHORT(real1))=SHORT(SHORT(real2)) THEN RETURN TRUE;
                                               ELSE RETURN FALSE; END;
  END Equal;

  PROCEDURE SetRadioData;
  (* Updates radio gadgets *)

  BEGIN
    IF Equal(page.width,29.7) & Equal(page.height,42) THEN
      defaultgad.SetValue(0);
    ELSIF Equal(page.width,21) & Equal(page.height,29.7) THEN
      defaultgad.SetValue(1);
    ELSIF Equal(page.width,14.85) & Equal(page.height,21) THEN
      defaultgad.SetValue(2);
    ELSIF Equal(page.width,21.59) & Equal(page.height,27.94) THEN
      defaultgad.SetValue(3);
    ELSIF Equal(page.width,21.59) & Equal(page.height,35.56) THEN
      defaultgad.SetValue(4);
    ELSE
      defaultgad.SetValue(5);
    END;
  END SetRadioData;

  PROCEDURE GetRadioData;
  (* Updates page.width/height to radio gadgets *)

  VAR long : LONGINT;

  BEGIN
    long:=defaultgad.GetValue();
    CASE long OF
    | 0 : page.width := 29.7 ; page.height := 42 ;
          page.widths:="29.7"; page.heights:="42";
    | 1 : page.width := 21 ; page.height := 29.7 ;
          page.widths:="21"; page.heights:="29.7";
    | 2 : page.width := 14.85 ; page.height := 21 ;
          page.widths:="14.85"; page.heights:="21";
    | 3 : page.width := 21.59 ; page.height := 27.94 ;
          page.widths:="21.59"; page.heights:="27.94";
    | 4 : page.width := 21.59 ; page.height := 35.56 ;
          page.widths:="21.59"; page.heights:="35.56";
    | 5 : SetRadioData;
    ELSE END;
    SetData;
  END GetRadioData;

  PROCEDURE GetInput;

  BEGIN
    widthgad.GetString(page.widths); page.width:=widthgad.real;
    heightgad.GetString(page.heights); page.height:=heightgad.real;
    SetRadioData;
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF changepagedimswind=NIL THEN
    changepagedimswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.GlobalPageSettings),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changepagedimswind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadbox:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.PageDimensions));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Input));
        widthgad:=gmo.SetStringGadget(ac.GetString(ac.Width),255,gmo.realType);
        widthgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
        heightgad:=gmo.SetStringGadget(ac.GetString(ac.Height),255,gmo.realType);
        heightgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Defaults));
        gmb.FillSpace;
        defaultarray[0]:=s.ADR("DinA 3");
        defaultarray[1]:=s.ADR("DinA 4");
        defaultarray[2]:=s.ADR("DinA 5");
        defaultarray[3]:=s.ADR("Standard");
        defaultarray[4]:=s.ADR("Legal");
        defaultarray[5]:=ac.GetString(ac.custom);
        defaultarray[6]:=NIL;
        defaultgad:=gmo.SetRadioButtons(s.ADR(defaultarray),0);
        gmb.FillSpace;
      gmb.EndBox;
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;


  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    SetData;
    SetRadioData;

    widthgad.Activate;

    NEW(backup); backup.Init;
    page.CopyB(backup);

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
(*      IF gridtask.msgsig IN class THEN
        REPEAT
          msg:=gridtask.ReceiveMsg();
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
                xspace1.Activate;
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
      END;*)
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            backup.CopyB(page);
            ret:=FALSE;
            EXIT;
          END;
        ELSIF I.gadgetDown IN mes.class THEN
          IF mes.iAddress=defaultgad.gadget THEN
            GetRadioData;
          END;
        ELSE
          GetInput;
        END;
        IF (I.gadgetUp IN mes.class) AND (mes.iAddress=root.help) THEN
          ag.ShowFile(ag.guidename,"pagedimensions",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;

    IF backup#NIL THEN backup.Destruct; END;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangeDims;



BEGIN
  changepagedimswind:=NIL;
  NEW(stdpage);
  IF stdpage=NIL THEN HALT(20); END;
  stdpage.Init;
  stdpage.width:=21; stdpage.height:=29.7;
  stdpage.widths:="21"; stdpage.heights:="29.7";
CLOSE
  IF stdpage#NIL THEN stdpage.Destruct; END;
END Page.


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


MODULE Document;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       la : Layers,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       l  : LinkedLists,
       c  : Conversions,
       st : Strings,
       rt : RequesterTools,
       tt : TextTools,
       m  : Multitasking,
       mem: MemoryManager,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       fo : FontOrganizer,
       mg : MathGUI,
       co : Coords,
       gw : GraphWindow,
       gb : GeneralBasics,
       lg : LayoutGUI,
       lc : LayoutConversion,
       pc : PageCoords,
       pi : PlotInfo,
       col: Colors,
       ru : Ruler,
       ra : Raster,
       im : Images,
       p  : Page,
       bo : Box,
       re : Rectangle,
       ci : Circle,
       li : Line,
       gwb: GraphWindowBox,
       bt : BasicTypes,
       ac : AnalayCatalog,
       NoGuruRq;

CONST minZoom * = 20;  (* Program restrictions *)
      maxZoom * = 500;

TYPE Document * = POINTER TO DocumentDesc;
     DocumentDesc * = RECORD(m.ChangeAbleDesc)
       name       * : ARRAY 256 OF CHAR;
       pages      * : l.List;
       actpage    * : p.Page;
       window     * : wm.Window;
       subwindow  * : wm.SubWindow;
       iwindow    * : I.WindowPtr;
       screen     * : I.ScreenPtr;   (* The screen this window was opened on. *)
       rast       * : g.RastPortPtr;
       view       * : g.ViewPortPtr;

       root       * : gmb.Root;
       zoomgad    * : gmo.BooleanGadget;
       zoomstring * : ARRAY 8 OF CHAR;
       glassgad   * : gmo.ImageGadget;
       pointergad * ,
       cursorgad  * ,
       depthgad   * ,
       deletegad  * ,
       rectgad    * ,
       circlegad  * ,
       linegad    * ,
       textboxgad * ,
       textlinegad* : gmo.ImageGadget;
       fontgad    * : gmo.BooleanGadget;
       fontsizegad* : gmo.StringGadget;
       scrollerx  * ,
       scrollery  * : gmo.ScrollerGadget;
       plotspace  * : gme.Space;
       gadobj     * : gmb.Object;

       plotrect   * : co.Rectangle;  (* The rectangle reserved for plotting the page incl. rulers *)
       pagerect   * : co.Rectangle;  (* The rectangle reserved for plotting the page *)
       plotinfo   * : pi.PlotInfo;
       ruler      * : ru.Ruler;
       raster     * : ra.Raster;
       fontinfo   * : fo.FontInfo;   (* This field never points to the fontinfo field of a box, etc.
                                        Whenever the font is changed via the font field it is copied from this
                                        fontinfo field to the boxes fontinfo field. *)
       open       * : BOOLEAN;       (* Window opened or hidden? *)
     END;

VAR documents * : m.MTList;

PROCEDURE (doc:Document) Init*;

VAR gadobj,textobj : gmb.Object;
    glist          : I.GadgetPtr;

BEGIN
  doc.Init^;
  doc.name:="Unnamed";
  doc.open:=TRUE;
  doc.pages:=l.Create();
  NEW(doc.actpage); doc.actpage.Init;
  doc.pages.AddTail(doc.actpage);

  doc.window:=wm.InitWindow(wm.centered,wm.centered,600,200,TRUE,s.ADR(doc.name),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing,I.windowClose},gmb.stdIDCMP);
  doc.subwindow:=doc.window.InitSub(mg.screen);
  doc.subwindow.SetMinMax(200,100,-1,-1);
  doc.screen:=NIL;
  doc.rast:=NIL;
  doc.view:=NIL;
  NEW(doc.plotrect);
  NEW(doc.pagerect);
  NEW(doc.plotinfo); doc.plotinfo.Init; NEW(doc.plotinfo.conv(lc.LayoutConversionTable)); doc.plotinfo.conv.Init(doc);
    doc.plotinfo.SetRect(doc.pagerect);
    doc.plotinfo.rast:=NIL;
    doc.plotinfo.subwind:=doc.subwindow;
    doc.plotinfo.vinfo:=NIL;
    doc.plotinfo.display:=lg.maindisp;
    lg.layoutconv.Copy(doc.plotinfo.conv);
    doc.plotinfo.conv(lc.LayoutConversionTable).SetPlotInfo(doc.plotinfo);
    doc.plotinfo.SetRect(doc.pagerect);

  NEW(doc.ruler); doc.ruler.Init;
    doc.ruler.rect:=doc.plotrect;

  NEW(doc.raster); doc.raster.Init;
  NEW(doc.fontinfo); doc.fontinfo.Init;

  doc.root:=gmb.SetRootBox(gmb.vertBox,gmb.noBorder,FALSE,NIL,LONGSET{},doc.subwindow);
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,TRUE,NIL);
      doc.pointergad:=gmo.SetImageGadget(32,19,2,im.pointerimg,im.pointerselimg,TRUE);
      doc.cursorgad:=gmo.SetImageGadget(32,19,2,im.cursorimg,im.cursorselimg,TRUE);
      doc.cursorgad.SetOutValues(0,0);
      doc.depthgad:=gmo.SetImageGadget(32,19,2,im.depthimg,im.depthselimg,FALSE);
      doc.depthgad.SetOutValues(0,0);
      doc.deletegad:=gmo.SetImageGadget(32,19,2,im.deleteimg,im.deleteselimg,FALSE);
      doc.deletegad.SetOutValues(0,0);

      doc.textboxgad:=gmo.SetImageGadget(32,19,2,im.textimg,im.textselimg,TRUE);
      doc.textlinegad:=gmo.SetImageGadget(32,19,2,im.textlineimg,im.textlineselimg,TRUE);
      doc.textlinegad.SetOutValues(0,0);
      doc.rectgad:=gmo.SetImageGadget(32,19,2,im.rectimg,im.rectselimg,TRUE);
      doc.rectgad.SetOutValues(0,0);
      doc.circlegad:=gmo.SetImageGadget(32,19,2,im.circleimg,im.circleselimg,TRUE);
      doc.circlegad.SetOutValues(0,0);
      doc.linegad:=gmo.SetImageGadget(32,19,2,im.lineimg,im.lineselimg,TRUE);
      doc.linegad.SetOutValues(0,0);

      doc.fontgad:=gmo.SetBooleanGadget(s.ADR("Font"),FALSE);
      doc.fontgad.SetMinVisible(15);
      doc.fontgad.SetSizeX(5);
      doc.fontsizegad:=gmo.SetStringGadget(NIL,6,gmo.realType);
      doc.fontsizegad.SetMinVisible(4);
      doc.fontsizegad.SetSizeX(1);
      doc.fontsizegad.SetOutValues(0,0);
      doc.fontsizegad.SetMinMaxReal(1,500);
      textobj:=gmo.SetText(s.ADR("pt"),-1);

      doc.glassgad:=gmo.SetImageGadget(32,19,2,im.glassimg,im.glassselimg,TRUE);
      doc.zoomgad:=gmo.SetBooleanGadget(s.ADR("8888 %"),FALSE);
      doc.zoomgad.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      doc.plotspace:=gme.SetSpace(gmb.noBorder,FALSE,-1,-1,FALSE);
      doc.plotspace.SetSizeY(1);
      doc.scrollery:=gmo.SetScrollerGadget(100,10,0,TRUE,I.lorientVert,-1);
    gmb.EndBox;
    doc.scrollerx:=gmo.SetScrollerGadget(100,10,0,TRUE,I.lorientHoriz,-1);
  glist:=doc.root.EndRoot();
  doc.root.Init;
  doc.root.SetOutValues(0,0);
  doc.root.Resize;

  doc.plotinfo.root:=doc.root;
END Init;

PROCEDURE (doc:Document) Destruct*;

BEGIN
  IF doc.window#NIL THEN doc.window.Destruct; END;
  IF doc.root#NIL THEN doc.root.Destruct; END;
  IF doc.pages#NIL THEN doc.pages.Destruct; END;
  IF doc.plotrect#NIL THEN doc.plotrect.Destruct; END;
  IF doc.pagerect#NIL THEN doc.pagerect.Destruct; END;
  IF doc.plotinfo#NIL THEN
    doc.plotinfo.conv.Destruct(doc);
    doc.plotinfo.Destruct;
  END;
  IF doc.raster#NIL THEN doc.raster.Destruct; END;
  IF doc.fontinfo#NIL THEN doc.fontinfo.Destruct; END;
  IF doc.ruler#NIL THEN doc.ruler.Destruct; END; (* Has been in brackets. Why? *)
  doc.Destruct^;
END Destruct;

PROCEDURE (doc:Document) Open*():BOOLEAN;

BEGIN
  doc.window.SetMenu(lg.menu);
  doc.subwindow.SetScreen(lg.screen);
  doc.iwindow:=doc.subwindow.Open(NIL);
  IF doc.iwindow#NIL THEN
    doc.root.Resize;
    doc.screen:=lg.screen;
    doc.rast:=doc.iwindow.rPort;
    doc.view:=s.ADR(doc.screen.viewPort);

(* Refreshing plotinfo *)

    doc.plotinfo.rast:=doc.rast;
    doc.plotinfo.view:=doc.view;
    doc.plotinfo.colormap:=doc.plotinfo.view.colorMap;
    doc.plotinfo.iwindow:=doc.iwindow;
    IF doc.plotinfo.vinfo#NIL THEN gd.FreeVisualInfo(doc.plotinfo.vinfo); END;
    doc.plotinfo.vinfo:=gd.GetVisualInfo(lg.screen,u.done);

    doc.actpage.AdaptRuler(doc.ruler);
    doc.ruler.RefreshInternal(doc.plotinfo);
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Open;

PROCEDURE (doc:Document) Close*;

BEGIN
  doc.Lock(FALSE);
  IF doc.iwindow#NIL THEN
    doc.subwindow.Close; doc.iwindow:=NIL;
    doc.root.Resize;
  END;
  doc.UnLock;
END Close;

PROCEDURE * PrintDocument*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=documents.GetNode(num);
  IF node#NIL THEN
    WITH node: Document DO
      NEW(str);
      COPY(node.name,str^);
      st.AppendChar(str^," ");
      IF ~node.open THEN st.Append(str^,"(hidden)"); END;
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintDocument;

(* Plotting methods *)



PROCEDURE (doc:Document) BoxFontToDocFont*;
(* Refreshes the font gadget. *)

BEGIN
  IF doc.actpage.actbox#NIL THEN
    IF doc.actpage.actbox.FontAble() THEN
      doc.actpage.actbox.GetFontInfo(doc.fontinfo);
      IF ~doc.actpage.actbox.GetUseStdFont() THEN
        doc.fontgad.SetText(s.ADR(doc.fontinfo.name));
        doc.fontsizegad.SetReal(doc.fontinfo.ySize);
        doc.fontsizegad.Disable(FALSE);
      ELSE
        doc.fontgad.SetText(ac.GetString(ac.Default));
        doc.fontsizegad.Disable(TRUE);
      END;
      doc.fontgad.Disable(FALSE);
      doc.fontgad.Refresh;
    ELSE
      doc.fontgad.Disable(TRUE);
      doc.fontsizegad.Disable(TRUE);
    END;
  ELSE
    doc.fontgad.Disable(TRUE);
    doc.fontsizegad.Disable(TRUE);
  END;
END BoxFontToDocFont;

PROCEDURE (doc:Document) RefreshZoomField*;

VAR str  : ARRAY 80 OF CHAR;
    bool : BOOLEAN;

BEGIN
  bool:=c.IntToString(SHORT(SHORT(doc.plotinfo.zoom)),str,5);
  tt.Clear(str);
  st.Append(str," %");
  COPY(str,doc.zoomstring);
  doc.zoomgad.SetText(s.ADR(doc.zoomstring));
  doc.zoomgad.Refresh;
END RefreshZoomField;

PROCEDURE (doc:Document) RefreshScrollers*;
(* Refreshes the scrollers to scroll on page. *)

BEGIN
  doc.scrollerx.Change(doc.plotinfo.picwidth,doc.pagerect.width,doc.plotinfo.offx);
  doc.scrollery.Change(doc.plotinfo.picheight,doc.pagerect.height,doc.plotinfo.offy);
END RefreshScrollers;

PROCEDURE (doc:Document) Resize*;
(* Call this procedure whenever either the size of the documentwindows or
   the zoom has been changed. *)

VAR x,y : LONGINT;

BEGIN
  doc.plotrect.xoff:=doc.plotspace.xpos;
  doc.plotrect.yoff:=doc.plotspace.ypos;
  doc.plotrect.width:=doc.plotspace.width;
  doc.plotrect.height:=doc.plotspace.height;

  doc.pagerect.xoff:=SHORT(doc.plotrect.xoff+doc.ruler.vertwidth);
  doc.pagerect.yoff:=SHORT(doc.plotrect.yoff+doc.ruler.horizheight);
  doc.pagerect.width:=SHORT(doc.plotspace.width-doc.ruler.vertwidth);
  doc.pagerect.height:=SHORT(doc.plotspace.height-doc.ruler.horizheight);

(* Updating plotinfo *)

  lg.layoutconv.Copy(doc.plotinfo.conv);
  doc.plotinfo.CMToPic(0.5,0.5,x,y);
  doc.plotinfo.conv.stdpicx:=SHORT(x);
  doc.plotinfo.conv.stdpicy:=SHORT(y);

(* Actually this method only needs to be called when a new page
   was selected. *)

  IF doc.actpage#NIL THEN
    doc.plotinfo.SetPageDims(doc.actpage.width,doc.actpage.height);
  END;

  doc.plotinfo.CheckOffset;
END Resize;

PROCEDURE (doc:Document) Refresh*;

BEGIN
  IF doc.iwindow#NIL THEN
    doc.subwindow.SetBusyPointer;
    col.FreePens(doc.plotinfo.display);
    doc.Resize;
    doc.ruler.Plot(doc.plotinfo);
    doc.BoxFontToDocFont;
    doc.RefreshZoomField;
    doc.RefreshScrollers;
    IF doc.actpage#NIL THEN
      doc.actpage.PlotPlain(doc.plotinfo);
      doc.raster.Plot(doc.plotinfo);
      doc.actpage.Plot(doc.plotinfo);
      doc.actpage.PlotBoxBorders(doc.plotinfo);
    END;
    doc.subwindow.ClearPointer;
  END;
END Refresh;

PROCEDURE (doc:Document) PlotPage*;
(* Faster refresh: Only quickly refreshes ruler and plots page *)

BEGIN
  IF doc.iwindow#NIL THEN
    doc.subwindow.SetBusyPointer;
    doc.ruler.Plot(doc.plotinfo);
    IF doc.actpage#NIL THEN
      doc.actpage.PlotPlain(doc.plotinfo);
      doc.raster.Plot(doc.plotinfo);
      doc.actpage.Plot(doc.plotinfo);
      doc.actpage.PlotBoxBorders(doc.plotinfo);
    END;
    doc.subwindow.ClearPointer;
  END;
END PlotPage;

(* Control methods *)



PROCEDURE (doc:Document) PlaceBox(box:bo.Box;mes:I.IntuiMessagePtr);
(* After you have created a new box call this function to let the
   user size it on the display. Adds it to the page's boxlist or
   destructs the box on user break. box is actbox afterwards. *)
(* box : Box to be placed
   mes : Last IntuiMessage *)

VAR bool : BOOLEAN;

BEGIN
  doc.plotinfo.rect.SetClipRegion(doc.plotinfo.subwind);
  bool:=box.Place(doc.plotinfo,doc.raster,mes);
  IF bool THEN
    doc.actpage.AddBox(box);
    IF doc.actpage.actbox#NIL THEN doc.actpage.actbox.PlotBorder(doc.plotinfo,bo.standardBorder,TRUE); END;
    box.Plot(doc.plotinfo);
    doc.actpage.actbox:=box;
    IF doc.actpage.actbox#NIL THEN doc.actpage.actbox.PlotBorder(doc.plotinfo,bo.standardBorder,TRUE); END;
  ELSE
    box.Destruct;
  END;
  doc.plotinfo.rect.RemoveClipRegion(doc.plotinfo.subwind);
END PlaceBox;

PROCEDURE (doc:Document) BoxDropped(node:m.LockAble);

VAR box  : bo.Box;
    mes  : I.IntuiMessagePtr;
    bool : BOOLEAN;

BEGIN
  IF doc.actpage#NIL THEN
    NEW(mes);
    box:=NIL;
    IF node IS gw.GraphWindow THEN
      node(gw.GraphWindow).NewUser(doc);
      NEW(box(gwb.GraphWindowBox)); box.task:=doc; box.Init;
      box(gwb.GraphWindowBox).graphwind:=node(gw.GraphWindow);
      box.xpos:=0;  box.ypos:=0;
      box.InitCoords(doc.actpage.width,doc.actpage.height);
    END;
    IF box#NIL THEN
      doc.subwindow.ToFront; doc.subwindow.Activate;
      doc.plotinfo.rect.SetClipRegion(doc.plotinfo.subwind);
      bool:=box.Move(doc.plotinfo,doc.raster,mes,TRUE);
      IF bool THEN
        doc.actpage.AddBox(box);
        IF doc.actpage.actbox#NIL THEN doc.actpage.actbox.PlotBorder(doc.plotinfo,bo.standardBorder,TRUE); END;
        box.Plot(doc.plotinfo);
        doc.actpage.actbox:=box;
        IF doc.actpage.actbox#NIL THEN doc.actpage.actbox.PlotBorder(doc.plotinfo,bo.standardBorder,TRUE); END;
      ELSE
        box.Destruct;
      END;
      doc.plotinfo.rect.RemoveClipRegion(doc.plotinfo.subwind);
    END;
    DISPOSE(mes);
  END;
END BoxDropped;

PROCEDURE (doc:Document) DoScrollers*(mes:I.IntuiMessagePtr);
(* Call when a scroller was pressed. *)

VAR offx,offy   : LONGINT;
    x1,y1,x2,y2,
    dx,dy       : INTEGER;
    didchange   : BOOLEAN;

BEGIN
  didchange:=FALSE;
  IF I.gadgetDown IN mes.class THEN
    IF (mes.iAddress=doc.scrollerx.gadget) OR (mes.iAddress=doc.scrollery.gadget) THEN
      doc.plotinfo.rect.SetClipRegion(doc.plotinfo.subwind);
      x1:=doc.pagerect.xoff;
      y1:=doc.pagerect.yoff;
      x2:=x1+doc.pagerect.width-1;
      y2:=y1+doc.pagerect.height-1;
      LOOP
        d.Delay(1);
(*        doc.subwindow.WaitPort;*)
(*        REPEAT*)
          doc.root.GetIMes(mes);
          offx:=doc.scrollerx.GetValue();
          offy:=doc.scrollery.GetValue();
          IF (doc.plotinfo.offx#offx) OR (doc.plotinfo.offy#offy) THEN
            dx:=SHORT(offx-doc.plotinfo.offx); dy:=SHORT(offy-doc.plotinfo.offy);
            doc.plotinfo.SetOffset(offx,offy);
            doc.ruler.Plot(doc.plotinfo);
            IF dx>x2-x1 THEN dx:=x2-x1; END;
            IF dy>y2-y1 THEN dy:=y2-y1; END;
            IF dx<x1-x2 THEN dx:=x1-x2; END;
            IF dy<y1-y2 THEN dy:=y1-y2; END;
            g.ScrollRaster(doc.rast,dx,dy,x1,y1,x2,y2);
            didchange:=TRUE;
          END;
          IF I.gadgetUp IN mes.class THEN EXIT; END;
(*        UNTIL mes.class=LONGSET{};*)
      END;
      doc.plotinfo.rect.RemoveClipRegion(doc.plotinfo.subwind);
      IF didchange THEN
        doc.Refresh;
      END;
    END;
  END;
END DoScrollers;

PROCEDURE (doc:Document) DoGadgets(mes:I.IntuiMessagePtr);

VAR real : LONGREAL;
    long : LONGINT;
    box  : bo.Box;
    bool : BOOLEAN;

BEGIN
  box:=NIL;
  IF doc.actpage#NIL THEN
    IF I.gadgetDown IN mes.class THEN
      IF (mes.iAddress=doc.scrollerx.gadget) OR (mes.iAddress=doc.scrollery.gadget) THEN
        doc.DoScrollers(mes);
      ELSIF mes.iAddress=doc.rectgad.gadget THEN
        NEW(box(re.Rectangle)); box.task:=doc; box.Init;
        doc.PlaceBox(box,mes);
        doc.rectgad.SetSelected(FALSE);
        IF (I.gadgetDown IN mes.class) & (mes.iAddress#doc.rectgad.gadget) THEN
          doc.DoGadgets(mes);
        END;
      ELSIF mes.iAddress=doc.circlegad.gadget THEN
        NEW(box(ci.Circle)); box.task:=doc; box.Init;
        doc.PlaceBox(box,mes);
        doc.circlegad.SetSelected(FALSE);
        IF (I.gadgetDown IN mes.class) & (mes.iAddress#doc.circlegad.gadget) THEN
          doc.DoGadgets(mes);
        END;
      ELSIF mes.iAddress=doc.linegad.gadget THEN
        NEW(box(li.Line)); box.task:=doc; box.Init;
        doc.PlaceBox(box,mes);
        doc.linegad.SetSelected(FALSE);
        IF (I.gadgetDown IN mes.class) & (mes.iAddress#doc.linegad.gadget) THEN
          doc.DoGadgets(mes);
        END;
      ELSIF mes.iAddress=doc.zoomgad.gadget THEN
        long:=SHORT(SHORT(doc.plotinfo.zoom));
        bool:=gb.EnterInteger(lg.screen,ac.GetString(ac.ChangeZoom),ac.GetString(ac.ZoomInPerCent),minZoom,maxZoom,long,"pagezoom");
        IF bool THEN
          doc.plotinfo.SetZoom(long);
          doc.ruler.RefreshInternal(doc.plotinfo);
          doc.Refresh;
        END;
      ELSIF mes.iAddress=doc.glassgad.gadget THEN
        NEW(box); box.Init;
        doc.plotinfo.rect.SetClipRegion(doc.plotinfo.subwind);
        bool:=box.Place(doc.plotinfo,doc.raster,mes);
        IF bool THEN
          box.Zoom(doc.plotinfo);
          doc.ruler.RefreshInternal(doc.plotinfo);
          doc.Refresh;
        END;
        box.Destruct;
        doc.plotinfo.rect.RemoveClipRegion(doc.plotinfo.subwind);
      ELSIF doc.actpage.actbox#NIL THEN
        IF mes.iAddress=doc.depthgad.gadget THEN
          IF doc.actpage.boxes.nbElements()>1 THEN
            IF doc.actpage.actbox.next=NIL THEN (* Move box to back *)
              doc.actpage.actbox.Remove;
              doc.actpage.boxes.AddHead(doc.actpage.actbox);
            ELSE
              doc.actpage.actbox.Remove;
              doc.actpage.boxes.AddTail(doc.actpage.actbox);
            END;
            doc.PlotPage;
          END;
        ELSIF mes.iAddress=doc.deletegad.gadget THEN
          doc.actpage.DeleteBox(doc.actpage.actbox);
          doc.actpage.actbox:=NIL;
          doc.PlotPage;
        ELSIF mes.iAddress=doc.fontgad.gadget THEN
          IF doc.actpage.actbox.FontAble() THEN
            bool:=doc.fontinfo.SelectFont(doc,doc.screen);
            IF bool THEN
              doc.actpage.actbox.SetFontInfo(doc.fontinfo);
              doc.BoxFontToDocFont;
              doc.Refresh;
            END;
          END;
        ELSIF mes.iAddress=doc.fontsizegad.gadget THEN
          IF doc.actpage.actbox.FontAble() THEN
            real:=doc.fontsizegad.GetReal();
            IF real#doc.fontinfo.ySize THEN
              doc.fontinfo.ySize:=real;
              doc.actpage.actbox.SetFontInfo(doc.fontinfo);
              doc.Refresh;
            END;
          END;
        END;
      END;
    END;
  END;
END DoGadgets;

PROCEDURE (doc:Document) DoDocument();

VAR mes   : I.IntuiMessagePtr;
    msg   : m.Message;
    class : LONGSET;
    node  : l.Node;
    bool  : BOOLEAN;

  PROCEDURE DoMenu(code:INTEGER);
  (* Check based upon LayoutGUI.menu *)

  VAR strip,item,sub : LONGINT;
      bool           : BOOLEAN;

  BEGIN
    strip:=I.MenuNum(code);
    item:=I.ItemNum(code);
    sub:=I.SubNum(code);
    IF doc.actpage#NIL THEN
      IF doc.actpage.actbox#NIL THEN
        IF strip=2 THEN
          IF item=2 THEN (* Change boxcoords *)
            doc.subwindow.SetBusyPointer;
            bool:=doc.actpage.actbox.ChangeCoords();
            doc.subwindow.ClearPointer;
            IF bool THEN
              doc.Refresh;
            END;
          ELSIF item=3 THEN (* Change adapt *)
            doc.subwindow.SetBusyPointer;
            IF doc.actpage.actbox IS gwb.GraphWindowBox THEN
              bool:=doc.actpage.actbox(gwb.GraphWindowBox).ChangeAdaptCoords();
              IF bool THEN
                doc.Refresh;
              END;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.FunctionOnlyOnFunctionBoxes1),ac.GetString(ac.FunctionOnlyOnFunctionBoxes2),s.ADR(""),ac.GetString(ac.OK),doc.iwindow);
            END;
            doc.subwindow.ClearPointer;
          ELSIF item=4 THEN (* Change boxcontents *)
            doc.subwindow.SetBusyPointer;
            bool:=doc.actpage.actbox.ChangeContents(doc);
            doc.subwindow.ClearPointer;
            IF bool THEN
              doc.Refresh;
            END;
          END;
        END;
      ELSE
        IF strip=2 THEN (* Work *)
          IF item=6 THEN
            doc.subwindow.SetBusyPointer;
            bool:=doc.actpage.ChangeDims();
            IF bool THEN
              doc.ruler.RefreshInternal(doc.plotinfo);
              doc.Refresh;
            END;
            doc.subwindow.ClearPointer;
          END;
        END;
      END;
    END;

    IF strip=0 THEN
      IF item=4 THEN (* Hide this document *)
        doc.SendNewMsg(m.msgClose,NIL); (* Send msg to oneself *)
      ELSIF item=5 THEN (* Reveal any document *)
        m.taskdata.layouttask.SendNewMsg(m.msgMenuAction,code);
      END;
    ELSIF strip=1 THEN (* Create boxes *)
      IF item=2 THEN (* Set line *)
        doc.linegad.SetSelected(TRUE);
        mes.class:=LONGSET{I.gadgetDown};
        mes.iAddress:=doc.linegad.gadget;
        doc.DoGadgets(mes);
      ELSIF item=3 THEN (* Set rect *)
        doc.rectgad.SetSelected(TRUE);
        mes.class:=LONGSET{I.gadgetDown};
        mes.iAddress:=doc.rectgad.gadget;
        doc.DoGadgets(mes);
      ELSIF item=4 THEN (* Set circle *)
        doc.circlegad.SetSelected(TRUE);
        mes.class:=LONGSET{I.gadgetDown};
        mes.iAddress:=doc.circlegad.gadget;
        doc.DoGadgets(mes);
      END;
    ELSIF strip=4 THEN
      IF item=1 THEN
        bool:=doc.raster.Change();
        IF bool THEN
          doc.Refresh;
        END;
      END;
    END;
  END DoMenu;

BEGIN
  NEW(mes);
  LOOP
    class:=e.Wait(LONGSET{0..31});
    IF doc.root#NIL THEN
      REPEAT
        doc.root.GetIMes(mes);
        IF I.closeWindow IN mes.class THEN
          doc.Close; doc.open:=FALSE;
        ELSIF I.newSize IN mes.class THEN
          doc.Refresh;
        ELSIF I.gadgetDown IN mes.class THEN
          doc.DoGadgets(mes);
        ELSIF I.menuPick IN mes.class THEN
          DoMenu(mes.code);
        ELSIF I.mouseButtons IN mes.class THEN
          IF mes.code=I.selectDown THEN
            IF doc.actpage#NIL THEN
              node:=doc.actpage.actbox;
              doc.actpage.InputEvent(doc.plotinfo,doc.raster,mes);
              IF node#doc.actpage.actbox THEN
                doc.BoxFontToDocFont;
              END;
            END;
          END;
        END;
      UNTIL mes.class=LONGSET{};
    END;

(*    IF doc.msgsig IN class THEN*)
      REPEAT
        msg:=doc.ReceiveMsg();
        IF msg#NIL THEN
          IF msg.type=m.msgQuit THEN
            msg.Reply;
            EXIT;
          ELSIF msg.type=m.msgClose THEN
            doc.Close;
            IF ~(msg.data=m.typeScreenMode) THEN
              doc.open:=FALSE;
            END;
          ELSIF msg.type=m.msgOpen THEN
            IF msg.data=m.typeScreenMode THEN
              IF doc.open THEN
                bool:=doc.Open();
              END;
            ELSE
              doc.open:=TRUE;
              bool:=doc.Open();
            END;
          ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgSizeChanged) THEN
            IF msg.data=lg.layoutconv THEN
              lg.layoutconv.Copy(doc.plotinfo.conv);
              doc.Refresh;
            ELSE
              doc.Refresh;
            END;
          ELSIF msg.type=m.msgNewNodeDropped THEN
            doc.BoxDropped(s.VAL(m.LockAble,msg.data));
(*            doc.FollowNewNode(s.VAL(m.LockAble,msg.data));*)
          ELSIF msg.type=m.msgActivate THEN
            doc.subwindow.ToFront;
          END;
          msg.Reply;
        END;
      UNTIL msg=NIL;
(*    END;*)
  END;
  DISPOSE(mes);
END DoDocument;

PROCEDURE DocumentTask*(doctask:bt.ANY):bt.ANY;
                                        
VAR data : Document;
    bool : BOOLEAN;

BEGIN
  WITH doctask: Document DO
    doctask.InitCommunication;
    bool:=doctask.Open();
    doctask.Refresh;
    IF bool THEN
      doctask.DoDocument;
      doctask.Close;
    END;
    IF doctask.list#NIL THEN
      doctask.Remove;
    END;
    m.taskdata.layouttask.FreeUser(doctask);
    doctask.ReplyAllMessages;
    doctask.DestructCommunication;
    mem.NodeToGarbage(doctask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END DocumentTask;



PROCEDURE GetLayerDocument*(layer:g.LayerPtr):Document;

VAR doc : l.Node;

BEGIN
  documents.Lock(TRUE);
  doc:=documents.head;
  WHILE doc#NIL DO
    WITH doc: Document DO
      doc.Lock(TRUE);
      IF doc.iwindow#NIL THEN
        IF doc.iwindow.wLayer=layer THEN
          doc.UnLock;
          documents.UnLock;
          RETURN doc;
        END;
      END;
      doc.UnLock;
    END;
    doc:=doc.next;
  END;
  documents.UnLock;
  RETURN NIL;
END GetLayerDocument;

PROCEDURE GetDocument*(x,y:INTEGER):Document;

VAR layer : g.LayerPtr;

BEGIN
  layer:=la.WhichLayer(s.ADR(lg.screen.layerInfo),x,y);
  IF layer#NIL THEN
    RETURN GetLayerDocument(layer);
  ELSE
    RETURN NIL;
  END;
END GetDocument;



BEGIN
  documents:=m.Create();
  IF documents=NIL THEN HALT(20); END;
CLOSE
  IF documents#NIL THEN documents.Destruct; END;
END Document.


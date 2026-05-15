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
       st : Strings,
       rt : RequesterTools,
       m  : Multitasking,
       mem: MemoryManager,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       fo : FontInfo;
       mg : MathGUI,
       co : Coords,
       gw : GraphWindow,
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
       gwb: GraphWindowBox,
       bt : BasicTypes,
       ac : AnalayCatalog,
       NoGuruRq;

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
     END;

VAR documents * : m.MTList;

PROCEDURE (doc:Document) Init*;

VAR gadobj,textobj : gmb.Object;
    glist          : I.GadgetPtr;

BEGIN
  doc.Init^;
  doc.name:="Unnamed";
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
  NEW(doc.plotinfo); doc.plotinfo.Init; NEW(doc.plotinfo.conv(lc.LayoutConversionTable)); doc.plotinfo.conv.Init;
    doc.plotinfo.SetRect(doc.pagerect);
    doc.plotinfo.rast:=NIL;
    doc.plotinfo.subwind:=doc.subwindow;
    doc.plotinfo.vinfo:=NIL;
    doc.plotinfo.display:=lg.maindisp;
    lg.layoutconv.Copy(doc.plotinfo.conv);
    doc.plotinfo.conv(lc.LayoutConversionTable).plotinfo:=doc.plotinfo;

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
      doc.fontgad.SetSizeX(5);
      doc.fontsizegad:=gmo.SetStringGadget(NIL,6,gmo.realType);
      doc.fontsizegad.SetMinVisible(4);
      doc.fontsizegad.SetSizeX(1);
      doc.fontsizegad.SetOutValues(0,0);
      textobj:=gmo.SetText(s.ADR("pt"),-1);

      doc.glassgad:=gmo.SetImageGadget(32,19,2,im.glassimg,im.glassselimg,TRUE);
      doc.zoomgad:=gmo.SetBooleanGadget(s.ADR("100 %"),FALSE);
      doc.zoomgad.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    doc.plotspace:=gme.SetSpace(gmb.noBorder,FALSE,-1,-1,FALSE);
    doc.plotspace.SetSizeY(1);
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
  IF doc.plotinfo#NIL THEN doc.plotinfo.Destruct; END;
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

(* Plotting methods *)



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
END Resize;

PROCEDURE (doc:Document) Refresh*;

BEGIN
  col.FreePens(doc.plotinfo.display);
  doc.Resize;
  doc.ruler.Plot(doc.plotinfo);
  IF doc.actpage#NIL THEN
    doc.actpage.PlotPlain(doc.plotinfo);
    doc.raster.Plot(doc.plotinfo);
    doc.actpage.Plot(doc.plotinfo);
    doc.actpage.PlotBoxBorders(doc.plotinfo);
  END;
END Refresh;

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
      NEW(box(gwb.GraphWindowBox)); box.Init;
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

(*PROCEDURE (doc:Document) FollowNewNode(node:m.LockAble);
(* Called whenever an icon is dragged over the document window. *)

VAR box  : bo.Box;
    mes  : I.IntuiMessagePtr;
    bool : BOOLEAN;

BEGIN
  NEW(mes);
  IF node IS gw.GraphWindow THEN
    doc.plotinfo.rect.SetClipRegion(doc.plotinfo.subwind);
    NEW(box(re.Rectangle)); box.Init;
    box(bo.Box).xpos:=0; box(bo.Box).ypos:=0;
    box(bo.Box).width:=2; box(bo.Box).height:=2;

    bool:=box.Move(doc.plotinfo,mes,TRUE,doc);

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
END FollowNewNode;*)

PROCEDURE (doc:Document) DoGadgets(mes:I.IntuiMessagePtr);

VAR box  : bo.Box;
    bool : BOOLEAN;

BEGIN
  box:=NIL;
  IF doc.actpage#NIL THEN
    IF I.gadgetDown IN mes.class THEN
      IF mes.iAddress=doc.depthgad.gadget THEN
        IF (doc.actpage.actbox#NIL) & (doc.actpage.boxes.nbElements()>1) THEN
          IF doc.actpage.actbox.next=NIL THEN (* Move box to back *)
            doc.actpage.actbox.Remove;
            doc.actpage.boxes.AddHead(doc.actpage.actbox);
          ELSE
            doc.actpage.actbox.Remove;
            doc.actpage.boxes.AddTail(doc.actpage.actbox);
          END;
          doc.actpage.PlotAll(doc.plotinfo);
        END;
      ELSIF mes.iAddress=doc.deletegad.gadget THEN
        IF doc.actpage.actbox#NIL THEN
          doc.actpage.DeleteBox(doc.actpage.actbox);
          doc.actpage.actbox:=NIL;
          doc.actpage.PlotAll(doc.plotinfo);
        END;
      ELSIF mes.iAddress=doc.rectgad.gadget THEN
        NEW(box(re.Rectangle)); box.Init;
        doc.PlaceBox(box,mes);
        doc.rectgad.SetSelected(FALSE);
        IF (I.gadgetDown IN mes.class) & (mes.iAddress#doc.rectgad.gadget) THEN
          doc.DoGadgets(mes);
        END;
      ELSIF mes.iAddress=doc.circlegad.gadget THEN
        NEW(box(ci.Circle)); box.Init;
        doc.PlaceBox(box,mes);
        doc.circlegad.SetSelected(FALSE);
        IF (I.gadgetDown IN mes.class) & (mes.iAddress#doc.circlegad.gadget) THEN
          doc.DoGadgets(mes);
        END;
      END;
    END;
  END;
END DoGadgets;

PROCEDURE (doc:Document) DoDocument();

VAR mes   : I.IntuiMessagePtr;
    msg   : m.Message;
    class : LONGSET;
    bool  : BOOLEAN;

  PROCEDURE DoMenu(code:INTEGER);
  (* Check based upon LayoutGUI.menu *)

  VAR strip,item,sub : LONGINT;
      bool           : BOOLEAN;

  BEGIN
    strip:=I.MenuNum(code);
    item:=I.ItemNum(code);
    sub:=I.SubNum(code);
    IF strip=2 THEN
      IF item=2 THEN (* Change boxcoords *)
        IF doc.actpage#NIL THEN
          IF doc.actpage.actbox#NIL THEN
            bool:=doc.actpage.actbox.ChangeCoords();
            IF bool THEN
              doc.Refresh;
            END;
          END;
        END;
      ELSIF item=3 THEN (* Change adapt *)
        IF doc.actpage#NIL THEN
          IF doc.actpage.actbox#NIL THEN
            IF doc.actpage.actbox IS gwb.GraphWindowBox THEN
              bool:=doc.actpage.actbox(gwb.GraphWindowBox).ChangeAdaptCoords();
              IF bool THEN
                doc.Refresh;
              END;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.FunctionOnlyOnFunctionBoxes1),ac.GetString(ac.FunctionOnlyOnFunctionBoxes2),s.ADR(""),ac.GetString(ac.OK),doc.iwindow);
            END;
          END;
        END;
      ELSIF item=4 THEN (* Change boxcontents *)
        IF doc.actpage#NIL THEN
          IF doc.actpage.actbox#NIL THEN
            bool:=doc.actpage.actbox.ChangeContents();
            IF bool THEN
              doc.Refresh;
            END;
          END;
        END;
      END;
    ELSIF strip=5 THEN
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
          EXIT;
        ELSIF I.newSize IN mes.class THEN
          doc.Refresh;
        ELSIF I.gadgetDown IN mes.class THEN
          doc.DoGadgets(mes);
        ELSIF I.menuPick IN mes.class THEN
          DoMenu(mes.code);
        ELSIF I.mouseButtons IN mes.class THEN
          IF mes.code=I.selectDown THEN
            IF doc.actpage#NIL THEN
              doc.actpage.InputEvent(doc.plotinfo,doc.raster,mes);
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
          ELSIF msg.type=m.msgOpen THEN
            bool:=doc.Open();
          ELSIF msg.type=m.msgNodeChanged THEN
            doc.subwindow.ToFront;
          ELSIF msg.type=m.msgNewNodeDropped THEN
            doc.BoxDropped(s.VAL(m.LockAble,msg.data));
(*            doc.FollowNewNode(s.VAL(m.LockAble,msg.data));*)
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


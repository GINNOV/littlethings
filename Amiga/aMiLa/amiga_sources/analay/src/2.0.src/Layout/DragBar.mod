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


MODULE DragBar;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       h  : Hardware,
       s  : SYSTEM,
       l  : LinkedLists,
       c  : Conversions,
       gd : GadTools,
       st : Strings,
       tt : TextTools,
       wm : WindowManager,
       lrp: LayerRastPort,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       im : Images,
       gb : GeneralBasics,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       co : Coords,
       wf : WindowFunction,
       gw : GraphWindow,
       lg : LayoutGUI,
       dc : DisplayConversion,
       lc : LayoutConversion,
       do : Document,
       ac : AnalayCatalog,
       io,
       NoGuruRq;

TYPE IconPicture * = POINTER TO IconPictureDesc;
     IconPictureDesc * = RECORD(l.NodeDesc)
       layerrast,
       backuprast: lrp.LayerRastPort;
       convtable : dc.ConversionTable;
       window    : l.Node;          (* The window whose icon is held here *)
       gadget    : gmb.Gadget;      (* The gadget in which the icon is displayed *)
       width,
       height,
       depth     : INTEGER;
       xpos,ypos : INTEGER; (* Position on screen when moving around *)
       changed * ,
       used      : BOOLEAN; (* Needed to recognize whether the window of a Icon still does exist. *)
     END;

PROCEDURE (icon:IconPicture) Init*;

BEGIN
  icon.layerrast:=NIL;
  icon.backuprast:=NIL;
  icon.window:=NIL;
  icon.width:=0;
  icon.height:=0;
  icon.changed:=TRUE;
END Init;

PROCEDURE (icon:IconPicture) Destruct*;

BEGIN
  IF icon.window#NIL THEN icon.window(m.ShareAble).FreeUser(m.taskdata.layouttask); END;
  IF icon.layerrast#NIL THEN lrp.FreeLayerRast(icon.layerrast); END;
  IF icon.backuprast#NIL THEN lrp.FreeLayerRast(icon.backuprast); END;
  icon.Destruct^;
END Destruct;

PROCEDURE (icon:IconPicture) Update*;

VAR actwind : l.Node;
    rect    : co.Rectangle;

BEGIN
  IF icon.depth#lg.screen.rastPort.bitMap.depth THEN
    icon.depth:=lg.screen.rastPort.bitMap.depth;
    icon.changed:=TRUE;
  END;
  IF icon.changed THEN
    io.WriteString("UIcon1\n");
    IF icon.layerrast#NIL THEN lrp.FreeLayerRast(icon.layerrast); icon.layerrast:=NIL; END;
    IF icon.backuprast#NIL THEN lrp.FreeLayerRast(icon.backuprast); icon.backuprast:=NIL; END;
    io.WriteString("UIcon2\n");
    io.WriteInt(icon.width,7); io.WriteLn;
    io.WriteInt(icon.height,7); io.WriteLn;
    io.WriteInt(icon.depth,7); io.WriteLn;
    icon.layerrast:=lrp.AllocLayerRast(icon.width,icon.height,icon.depth);
    icon.backuprast:=lrp.AllocLayerRast(icon.width,icon.height,icon.depth);
    io.WriteString("UIcon3\n");
    rect:=NIL; NEW(rect);
    io.WriteString("UIcon4\n");
    rect.xoff:=2;
    rect.yoff:=1;
    rect.width:=icon.width-4;
    rect.height:=icon.height-2;
    io.WriteString("UIcon5\n");

(* Recreating icon *)

    actwind:=icon.window;
    io.WriteString("UIcon6\n");
    WITH actwind: gw.GraphWindow DO
    io.WriteString("UIcon7\n");
      actwind.Lock(FALSE);
      actwind.Plot(icon.layerrast.rast,rect,icon.convtable,TRUE);
      actwind.UnLock;
    END;
    io.WriteString("UIcon8\n");

    IF rect#NIL THEN rect.Destruct; END;
    io.WriteString("UIcon9\n");
    icon.changed:=FALSE;
  END;
END Update;

PROCEDURE (icon:IconPicture) Backup*;
(* Copies screen contents at current icon position to backup buffer of icon *)

VAR bool : BOOLEAN;

BEGIN
  g.BltBitMapRastPort(lg.screen.rastPort.bitMap,icon.xpos,icon.ypos,icon.backuprast.rast,0,0,icon.width,icon.height,s.VAL(s.BYTE,0C0H));
END Backup;

PROCEDURE (icon:IconPicture) Restore*;
(* Restores screen contents when moving icon around (opposite of icon.Backup) *)

VAR long : LONGINT;

BEGIN
  long:=g.BltBitMap(icon.backuprast.bitmap,0,0,lg.screen.rastPort.bitMap,icon.xpos,icon.ypos,icon.width,icon.height,s.VAL(s.BYTE,0C0H),SHORTSET{0..7},NIL);
END Restore;

PROCEDURE (icon:IconPicture) Plot*;

VAR long : LONGINT;

BEGIN
  long:=g.BltBitMap(icon.layerrast.bitmap,0,0,lg.screen.rastPort.bitMap,icon.xpos,icon.ypos,icon.width,icon.height,s.VAL(s.BYTE,0C0H),SHORTSET{0..7},NIL);
END Plot;

PROCEDURE (icon:IconPicture) CorrectCoords*;

VAR maxwidth,maxheight : INTEGER;

BEGIN
  maxwidth:=lg.screen.width; maxheight:=lg.screen.height;
  IF icon.xpos<0 THEN icon.xpos:=0; END;
  IF icon.ypos<0 THEN icon.ypos:=0; END;
  IF icon.xpos+icon.width>=maxwidth THEN icon.xpos:=maxwidth-icon.width; END;
  IF icon.ypos+icon.height>=maxheight THEN icon.ypos:=maxheight-icon.height; END;
END CorrectCoords;

PROCEDURE (icon:IconPicture) Move*(mes:I.IntuiMessagePtr;subwind:wm.SubWindow);

VAR class     : LONGSET;
    xpos,ypos,
    offx,offy : INTEGER;
    doc,olddoc: do.Document;

BEGIN
  doc:=NIL;
  offx:=mes.mouseX-icon.gadget.xpos;
  offy:=mes.mouseY-icon.gadget.ypos;
  xpos:=mes.mouseX-offx; ypos:=mes.mouseY-offy;
  icon.xpos:=xpos; icon.ypos:=ypos;
  icon.CorrectCoords;
  icon.Backup;
  icon.Plot;
  LOOP
    class:=e.Wait(LONGSET{0..31});
    REPEAT
      subwind.GetIMes(mes);
      xpos:=lg.screen.mouseX-offx; ypos:=lg.screen.mouseY-offy;
      IF (icon.xpos#xpos) OR (icon.ypos#ypos) THEN
        icon.Restore;
        icon.xpos:=xpos; icon.ypos:=ypos;
        icon.CorrectCoords;
        icon.Backup;
        icon.Plot;
      END;
(*      olddoc:=doc;
      doc:=do.GetDocument(icon.xpos,icon.ypos);
      IF (doc#NIL) & (doc#olddoc) THEN
        IF olddoc#NIL THEN
(*          doc.SendNewMsg(m.msgNewNodeCancelled,icon.window);*)
        END;
        doc.SendNewMsg(m.msgNewNodeFollow,icon.window);
      END;*)

      IF I.mouseButtons IN mes.class THEN
        doc:=do.GetDocument(icon.xpos,icon.ypos);
        IF doc#NIL THEN
          doc.SendNewMsg(m.msgNewNodeDropped,icon.window);
        END;
        EXIT;
      ELSIF I.menuPick IN mes.class THEN
        EXIT;
      END;
    UNTIL mes.class=LONGSET{};
  END;
  icon.Restore;
END Move;



TYPE DragBar * = POINTER TO DragBarDesc;
     DragBarDesc * = RECORD
       window     - : wm.Window;
       subwindow  - : wm.SubWindow;
       iwindow    - : I.WindowPtr;
       root       - : gmb.Root;
       convtable    : dc.ConversionTable;
       icons        : POINTER TO ARRAY OF gme.Space;
       scroller     : gmo.ScrollerGadget;
       trashcan     : gmo.ImageGadget;
       infolv       : gmo.ListView;
       iconwi,iconhe,
       iconcols,      (* Nº of columns displayed as icons *)
       iconrows,      (* Nº of rows displayed as icons *)
       numicons,      (* Nº of icons display, NOT the number of icons available by scrolling *)
       totalrows,     (* Total nº of rows through which one can scroll *)
       totalicons,    (* Total number of icons! *)
       toprow,        (* Top row displayed *)
       acticon      : INTEGER; (* Currently this window's info is displayed *)
       actwind      : l.Node;

(* All windows in the DragBar, not depending on whether they are displayed as icon at the moment or not. *)

       infolist     : l.List;  (* Text displayed in infolv *)
       iconpics     : l.List;
       movingicon,             (* Set to TRUE if the current icon is moved *)
       fastcomputer : BOOLEAN; (* Icons are get created new every time the user resizes the window if set to TRUE *)
     END;

TYPE DragBarSpace * = POINTER TO DragBarSpaceDesc;
     DragBarSpaceDesc * = RECORD(gme.SpaceDesc)
       dragbar  : DragBar;
       spacenum : INTEGER;
     END;

PROCEDURE (space:DragBarSpace) FillSpace*(rast:g.RastPortPtr;x,y,width,height:LONGINT);

VAR icon : l.Node;

BEGIN
  icon:=space.dragbar.iconpics.GetNode(space.spacenum+space.dragbar.toprow*space.dragbar.iconcols);
  IF icon#NIL THEN
    WITH icon: IconPicture DO
      g.ClipBlit(icon.layerrast.rast,0,0,rast,SHORT(x),SHORT(y),SHORT(width),SHORT(height),s.VAL(s.BYTE,0C0H));
    END;
  END;
END FillSpace;

PROCEDURE SetDragBarSpace*(bordertype:LONGINT;recessed:BOOLEAN;width,height:INTEGER;dragbar:DragBar;spacenum:INTEGER):DragBarSpace;

VAR gad  : I.GadgetPtr;
    node : l.Node;

BEGIN
  node:=NIL;
  NEW(node(DragBarSpace));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: DragBarSpace DO
      node.text:=NIL;
      node.dragbar:=dragbar;
      node.spacenum:=spacenum;
      node.bordertype:=bordertype;
      node.recessed:=recessed;
      node.clickable:=TRUE;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=-1;
      node.sizey:=-1;
      node.minwi:=width;
      node.minhe:=height;
      node.userminwi:=0;
      node.userminhe:=0;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
    END;
  END;
  RETURN node(DragBarSpace);
END SetDragBarSpace;



PROCEDURE (dragbar:DragBar) GetIcon*(window:l.Node):IconPicture;

VAR icon : l.Node;

BEGIN
  icon:=dragbar.iconpics.head;
  WHILE icon#NIL DO
    IF icon(IconPicture).window=window THEN
      RETURN icon(IconPicture);
    END;
    icon:=icon.next;
  END;
  RETURN NIL;
END GetIcon;

PROCEDURE (dragbar:DragBar) CreateIcons*;

VAR window,
    node,next : l.Node;
    icon,
    previcon  : IconPicture;

  PROCEDURE Create(list:l.List);
  (* list must be a list of windows, e.g. gw.graphwindows *)

  BEGIN
    IF list IS m.MTList THEN
      list(m.MTList).Lock(FALSE);
    END;

    window:=list.head;
    WHILE window#NIL DO
  
  (* Creating icon if not present *)
      icon:=dragbar.GetIcon(window);
      IF icon=NIL THEN
        window(m.ShareAble).NewUser(m.taskdata.layouttask);
        NEW(icon); icon.Init;
        icon.window:=window;
        icon.convtable:=dragbar.convtable;
        previcon:=dragbar.GetIcon(window.prev);
        IF previcon#NIL THEN
          previcon.AddBehind(icon);
        ELSE
          dragbar.iconpics.AddTail(icon);
        END;
      END;

      IF icon#NIL THEN
        IF icon.width#dragbar.iconwi THEN
          icon.width:=dragbar.iconwi;
          icon.changed:=TRUE;
        END;
        IF icon.height#dragbar.iconhe THEN
          icon.height:=dragbar.iconhe;
          icon.changed:=TRUE;
        END;
        icon.Update;
        icon.used:=TRUE;
      END;
      window:=window.next;
    END;

    IF list IS m.MTList THEN
      list(m.MTList).UnLock;
    END;
  END Create;

BEGIN
  node:=dragbar.iconpics.head;
  WHILE node#NIL DO
    node(IconPicture).used:=FALSE;
    node:=node.next;
  END;

  Create(gw.graphwindows);

  node:=dragbar.iconpics.head;
  WHILE node#NIL DO
    next:=node.next;
    IF ~node(IconPicture).used THEN
      node(IconPicture).Destruct;
    ELSE
      node(IconPicture).convtable:=dragbar.convtable;
    END;
    node:=next;
  END;
  dragbar.totalicons:=SHORT(dragbar.iconpics.nbElements());
END CreateIcons;

PROCEDURE (dragbar:DragBar) UpdateInfoText*;

VAR actwind,
    func    : l.Node;
    string  : ARRAY 512 OF CHAR;
    bool    : BOOLEAN;

BEGIN
  dragbar.subwindow.SetBusyPointer;
  dragbar.infolist.Init;
  IF dragbar.actwind#NIL THEN
    actwind:=dragbar.actwind;
    WITH actwind: gw.GraphWindow DO
      actwind.Lock(TRUE);
      COPY("Name: ",string);
      st.Append(string,actwind.windname);
      gb.AddString(dragbar.infolist,string,SHORTSET{});

      COPY("Type: ",string);
      st.Append(string,"Functionwindow");
      gb.AddString(dragbar.infolist,string,SHORTSET{});

      COPY(ac.GetString(ac.XAxisDomain)^,string);
      st.Append(string,actwind.coordsystem(co.CartesianSystem).xmins);
      st.Append(string,"..");
      st.Append(string,actwind.coordsystem(co.CartesianSystem).xmaxs);
      gb.AddString(dragbar.infolist,string,SHORTSET{});

      bool:=c.IntToString(actwind.funcs.nbElements(),string,5);
      tt.Clear(string);
      st.AppendChar(string," ");
      IF actwind.funcs.nbElements()=1 THEN
        st.Append(string,ac.GetString(ac.FunctionDisplayed)^);
      ELSE
        st.Append(string,ac.GetString(ac.FunctionsDisplayed)^);
      END;
      gb.AddString(dragbar.infolist,string,SHORTSET{});

      gb.AddString(dragbar.infolist,"",SHORTSET{});
      gb.AddString(dragbar.infolist,"List of displayed functions:",SHORTSET{g.bold});
      func:=actwind.funcs.head;
      WHILE func#NIL DO
        IF func(wf.WindowFunction).func#NIL THEN
          string:="f(x)=";
          st.Append(string,func(wf.WindowFunction).func.name);
          gb.AddString(dragbar.infolist,string,SHORTSET{});
        END;
        func:=func.next;
      END;
      actwind.UnLock;
    ELSE
    END;
  ELSE
  END;
  dragbar.infolv.Refresh;
  dragbar.subwindow.ClearPointer;
END UpdateInfoText;

PROCEDURE (dragbar:DragBar) InitGadgets*;
(* Attention: lg.Init MUST be called before this method! And
              the dragbar window MUST already be open! *)

VAR iconwi,iconhe  : INTEGER;
    width,height,
    x,y,i          : INTEGER;
    gadobj,gadobj2 : gmb.Object;
    glist          : I.GadgetPtr;
    icon           : l.Node;

BEGIN
  IF dragbar.subwindow#NIL THEN dragbar.subwindow.SetBusyPointer; END;

  dragbar.convtable.stdpicx:=4;
  dragbar.convtable.stdpicy:=3;
  iconwi:=gb.GetStdPicX(lg.screen.width)*4;
  iconhe:=gb.GetStdPicY(lg.screen.height)*4;
  height:=dragbar.iwindow.height-dragbar.iwindow.borderTop-dragbar.iwindow.borderBottom;
  IF dragbar.fastcomputer THEN
    IF height DIV iconhe>0 THEN
      iconhe:=(height DIV (height DIV iconhe));
    END;
  END;
  dragbar.iconwi:=iconwi;
  dragbar.iconhe:=iconhe;
(*  IF iconhe#dragbar.iconhe THEN*)
    dragbar.CreateIcons;
(*  END;*)

  dragbar.iconcols:=SHORT(SHORT(((dragbar.iwindow.width*3/5)/iconwi)));
  IF dragbar.iconcols<=4 THEN DEC(dragbar.iconcols); END;
  dragbar.iconrows:=height DIV iconhe;
  IF dragbar.iconrows<1 THEN dragbar.iconrows:=1; END;
  IF dragbar.iconcols*dragbar.iconrows>dragbar.totalicons THEN
    dragbar.iconcols:=((dragbar.totalicons-1) DIV dragbar.iconrows)+1;
  END;
(*  IF dragbar.iconcols>dragbar.totalicons THEN
    dragbar.iconcols:=dragbar.totalicons;
  END;*)
  IF dragbar.iconcols<1 THEN dragbar.iconcols:=1; END;
  IF dragbar.iconrows<1 THEN dragbar.iconrows:=1; END;
  i:=dragbar.numicons;
  dragbar.numicons:=dragbar.iconrows*dragbar.iconcols;
  IF dragbar.iconcols>0 THEN
    dragbar.totalrows:=((dragbar.totalicons-1) DIV dragbar.iconcols)+1;
    IF dragbar.toprow>dragbar.totalrows-dragbar.iconrows THEN
      dragbar.toprow:=dragbar.totalrows-dragbar.iconrows;
      IF dragbar.toprow<0 THEN dragbar.toprow:=0; END;
    END;
  ELSE
    dragbar.totalrows:=0;
  END;

  IF (dragbar.acticon>=dragbar.totalicons) OR ((dragbar.actwind#NIL) & (dragbar.actwind.list=NIL)) THEN
    dragbar.acticon:=dragbar.totalicons-1;
    IF dragbar.acticon>-1 THEN
      icon:=dragbar.iconpics.GetNode(dragbar.acticon);
      IF icon#NIL THEN
        dragbar.actwind:=icon(IconPicture).window;
      ELSE
        dragbar.acticon:=-1;
        dragbar.actwind:=NIL;
      END;
    ELSE
      dragbar.actwind:=NIL;
    END;
  END;

  IF dragbar.numicons#i THEN
    IF dragbar.icons#NIL THEN DISPOSE(dragbar.icons); dragbar.icons:=NIL; END;
    IF dragbar.numicons>0 THEN
      NEW(dragbar.icons,dragbar.numicons);
    END;
  END;

  IF dragbar.root#NIL THEN
    dragbar.subwindow.RemoveGadgets;
    dragbar.root.Destruct; dragbar.root:=NIL;
  END;

  dragbar.root:=gmb.SetRootBox(gmb.horizBox,gmb.noBorder,FALSE,NIL,LONGSET{},dragbar.subwindow);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      gadobj2:=gadobj;
      gadobj.SetSizeY(0);
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        i:=0;
        FOR y:=1 TO dragbar.iconrows DO
          gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
            FOR x:=1 TO dragbar.iconcols DO
              dragbar.icons[i]:=SetDragBarSpace(gd.bbftButton,FALSE,dragbar.iconwi,dragbar.iconhe,dragbar,i);
              dragbar.icons[i].SetOutValues(0,0);
              IF i=dragbar.acticon THEN
                dragbar.icons[i].pressed:=TRUE;
              END;
              IF i>=dragbar.totalicons THEN
                dragbar.icons[i].Disable(TRUE);
              END;
              icon:=dragbar.iconpics.GetNode(i);
              IF icon#NIL THEN icon(IconPicture).gadget:=dragbar.icons[i]; END;
              INC(i);
            END;
          gmb.EndBox;
          gadobj.SetOutValues(0,0);
          gadobj.SetSizeY(0);
        END;
      gmb.EndBox;
      gadobj2.SetSizeY(0);
      dragbar.scroller:=gmo.SetScrollerGadget(dragbar.totalrows,dragbar.iconrows,dragbar.toprow*10,TRUE,I.lorientVert,-1);
      io.WriteString("dragbar.totalrows");
      io.WriteInt(dragbar.totalrows,7);
      io.WriteLn;
      io.WriteString("dragbar.iconrows");
      io.WriteInt(dragbar.iconrows,7);
      io.WriteLn;
      io.WriteString("dragbar.toprows");
      io.WriteInt(dragbar.toprow,7);
      io.WriteLn;
      dragbar.scroller.SetSizeY(0);
      dragbar.scroller.SetOutValues(0,0);
    gmb.EndBox;
    dragbar.infolv:=gmo.SetListView(s.ADR("Drag'n Drop"),dragbar.infolist,gb.PrintString,0,FALSE,255);
    dragbar.infolv.SetNoEntryText(s.ADR("No info"));
    dragbar.infolv.SetMinWidth(SHORT(SHORT(dragbar.iwindow.width*1/5)));
  glist:=dragbar.root.EndRoot();
  dragbar.root.SetOutValues(0,0);
  dragbar.root.Init;
  dragbar.root.Resize;
  dragbar.UpdateInfoText;

  IF dragbar.subwindow#NIL THEN dragbar.subwindow.ClearPointer; END;
END InitGadgets;

PROCEDURE (dragbar:DragBar) Init*;

VAR gadobj : gmb.Object;
    glist  : I.GadgetPtr;

BEGIN
  dragbar.window:=wm.InitWindow(wm.centered,wm.centered,500,50,TRUE,s.ADR("Drag'N Drop"),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.reportMouse},gmb.stdIDCMP);
  dragbar.subwindow:=dragbar.window.InitSub(mg.screen); (* lg.screen is probably not properly set yet! *)
  dragbar.root:=NIL;
  dragbar.icons:=NIL;
  dragbar.toprow:=0;
  dragbar.acticon:=-1;
  dragbar.actwind:=NIL;
  dragbar.infolist:=l.Create();
  dragbar.iconpics:=l.Create();
  NEW(dragbar.convtable); dragbar.convtable.Init(m.taskdata.layouttask);
END Init;

PROCEDURE (dragbar:DragBar) Destruct*;

BEGIN
  IF dragbar.root#NIL THEN dragbar.root.Destruct; END;
  IF dragbar.window#NIL THEN dragbar.window.Destruct; END;
  IF dragbar.infolist#NIL THEN dragbar.infolist.Destruct; END;
  IF dragbar.iconpics#NIL THEN dragbar.iconpics.Destruct; END;
  IF dragbar.convtable#NIL THEN dragbar.convtable.Destruct(m.taskdata.layouttask); END;
END Destruct;

PROCEDURE (dragbar:DragBar) Open*;

BEGIN
  dragbar.window.SetMenu(lg.dragbarmenu);
  dragbar.subwindow.SetScreen(lg.screen);
  dragbar.subwindow.SetMinMax(gb.GetStdPicX(lg.screen.width)*4*5,gb.GetStdPicY(lg.screen.height)*4,-1,-1);
  dragbar.iwindow:=dragbar.subwindow.Open(NIL);
  dragbar.InitGadgets;
  dragbar.UpdateInfoText;
END Open;

PROCEDURE (dragbar:DragBar) Close*;

BEGIN
  IF dragbar.iwindow#NIL THEN
    dragbar.subwindow.Close;
    dragbar.root.Destruct; dragbar.root:=NIL;
    dragbar.iwindow:=NIL;
  END;
END Close;

PROCEDURE (dragbar:DragBar) InputEvent*(mes:I.IntuiMessagePtr);

VAR i    : INTEGER;
    icon : l.Node;

BEGIN
  IF I.newSize IN mes.class THEN
    dragbar.InitGadgets;
  ELSIF I.gadgetDown IN mes.class THEN
    FOR i:=0 TO dragbar.numicons-1 DO
      IF mes.iAddress=dragbar.icons[i] THEN
        icon:=dragbar.iconpics.GetNode(i);
        IF icon#NIL THEN
          IF (dragbar.acticon>=0) & (dragbar.acticon<LEN(dragbar.icons^)) & (dragbar.acticon#i) THEN
            dragbar.icons[dragbar.acticon].pressed:=FALSE;
            dragbar.icons[dragbar.acticon].Refresh;
          END;
          dragbar.acticon:=i;
          dragbar.actwind:=icon(IconPicture).window;
          dragbar.UpdateInfoText;
          icon(IconPicture).Move(mes,dragbar.subwindow);
        END;
      END;
    END;
(*  ELSIF I.gadgetUp IN mes.class THEN
    FOR i:=0 TO dragbar.numicons-1 DO
      IF mes.iAddress=dragbar.icons[i] THEN
        IF dragbar.acticon=i THEN
          dragbar.acticon:=-1;
          dragbar.actwind:=NIL;
        END;
      END;
    END;
    dragbar.UpdateInfoText;*)
  END;
END InputEvent;

END DragBar.


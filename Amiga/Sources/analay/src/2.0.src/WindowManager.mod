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


MODULE WindowManager;

IMPORT I : Intuition,
       g : Graphics,
       d : Dos,
       e : Exec,
       u : Utility,
       l : LinkedLists,
       s : SYSTEM,
       r : Requests,
       a : Alerts,
       df: DiskFont,
       la: Layers,
       st: Strings,
       pt: Pointers,
       m : Multitasking,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE Window *= POINTER TO WindowDesc;
     WindowDesc * = RECORD(m.MTNodeDesc)
       xpos,ypos,
       width,height,
       minwi,minhe,
       maxwi,maxhe  : INTEGER;
       inner        : BOOLEAN;
       scale        : BOOLEAN;
       title        : e.STRPTR;
       flags,idcmp  : LONGSET;
       menu         : I.MenuPtr;
       sublist      : l.List;
     END;
     SubWindow * = POINTER TO SubWindowDesc;
     SubWindowDesc * = RECORD(m.MTNodeDesc)
       window     - : Window;
       iwindow    - : I.WindowPtr;
       rast       - : g.RastPortPtr;
       screen     - : I.ScreenPtr;
       gadgets      : I.GadgetPtr;
       attr         : g.TextAttrPtr;
       font         : g.TextFontPtr;
       title        : e.STRPTR;
       clipreg      : g.RegionPtr;
       clipregused  : BOOLEAN;
       screenback   : BOOLEAN;       (* For easy creation of backdrop windows on screens. *)
     END;

CONST centered * = -1;

VAR windowlist      : m.MTList;

PROCEDURE InitWindow*(xpos,ypos,width,height:INTEGER;inner:BOOLEAN;title:e.STRPTR;flags,idcmp:LONGSET):Window;

VAR node : Window;

BEGIN
  NEW(node); node.Init;
  IF node#NIL THEN
    node.xpos:=xpos;
    node.ypos:=ypos;
    node.inner:=inner;
    node.width:=width;
    node.height:=height;
    node.minwi:=width;
    node.minhe:=height;
    node.maxwi:=-1;
    node.maxhe:=-1;
    node.title:=title;
    node.flags:=flags;
    node.idcmp:=idcmp;
    node.menu:=NIL;
    node.sublist:=l.Create();
    IF node.sublist=NIL THEN
      DISPOSE(node); RETURN NIL;
    END;
    windowlist.AddTail(node);
  END;
  RETURN node;
END InitWindow;

PROCEDURE (window:Window) InitSub*(screen:I.ScreenPtr):SubWindow;

(* Always check screen for NIL! *)

VAR sub : SubWindow;

BEGIN
  NEW(sub); sub.Init;
  IF sub#NIL THEN
    sub.window:=window;
    sub.iwindow:=NIL;
    sub.rast:=NIL;
    sub.screen:=screen;
    IF screen#NIL THEN
      sub.attr:=screen.font;
    ELSE
      sub.attr:=NIL;
    END;
    sub.font:=NIL;
    sub.gadgets:=NIL;
    sub.title:=window.title;
    sub.screenback:=FALSE;
    sub.clipreg:=g.NewRegion();
    NEW(sub.clipreg.regionRectangle);
    sub.clipreg.regionRectangle.prev:=NIL;
    sub.clipreg.regionRectangle.next:=NIL;
    sub.clipregused:=FALSE;
  END;
  window.sublist.AddTail(sub);
  RETURN sub;
END InitSub;

PROCEDURE (sub:SubWindow) Open*(gadgets:I.GadgetPtr):I.WindowPtr;

VAR iwind        : I.WindowPtr;
    wind         : Window;
    new          : I.ExtNewWindow;
    title        : e.STRPTR;
    reg          : g.RegionPtr;
    xpos,ypos,
    width,height : LONGINT;
    flags        : LONGSET;
    bool         : BOOLEAN;

BEGIN
  iwind:=NIL;
  INCL(new.nw.flags,I.nwExtended);
  new.nw.detailPen:=0;
  new.nw.blockPen:=1;
  wind:=sub.window;
(*  IF gadgets#NIL THEN*)
    sub.gadgets:=gadgets;
(*  END;*)

  IF wind.xpos=centered THEN
    wind.xpos:=(sub.screen.width-wind.width) DIV 2;
  END;
  IF wind.ypos=centered THEN
    wind.ypos:=(sub.screen.height-wind.height) DIV 2;
  END;
  xpos:=wind.xpos;
  ypos:=wind.ypos;
  width:=wind.width;
  height:=wind.height;
  flags:=wind.flags;
  title:=sub.title;
  IF sub.screenback THEN
    xpos:=0;
    ypos:=sub.screen.barHeight+1;
    width:=sub.screen.width;
    height:=sub.screen.height-sub.screen.barHeight-1;
    flags:=LONGSET{I.borderless,I.backDrop,I.simpleRefresh,I.noCareRefresh,I.activate};
    title:=NIL;
  END;

  IF (wind.inner) AND NOT(sub.screenback) THEN
    iwind:=I.OpenWindowTags(new,I.waLeft,xpos,
                                I.waTop,ypos,
                                I.waInnerWidth,width,
                                I.waInnerHeight,height,
                                I.waDetailPen,0,
                                I.waBlockPen,1,
                                I.waIDCMP,wind.idcmp,
                                I.waFlags,flags,
                                I.waGadgets,sub.gadgets,
                                I.waNewLookMenus,I.LTRUE,
                                I.waTitle,title,
                                I.waCustomScreen,sub.screen,
                                I.waMinWidth,wind.minwi,
                                I.waMinHeight,wind.minhe,
                                I.waMaxWidth,wind.maxwi,
                                I.waMaxHeight,wind.maxhe,
                                I.waAutoAdjust,I.LTRUE,
                                u.done);
(*    IF iwind#NIL THEN
      wind.xpos:=iwind.leftEdge;
      wind.ypos:=iwind.topEdge;
      wind.width:=iwind.width-iwind.borderLeft-iwind.borderRight;
      wind.height:=iwind.height-iwind.borderTop-iwind.borderBottom;
    END;*)
  ELSE
    iwind:=I.OpenWindowTags(new,I.waLeft,xpos,
                                I.waTop,ypos,
                                I.waWidth,width,
                                I.waHeight,height,
                                I.waDetailPen,0,
                                I.waBlockPen,1,
                                I.waIDCMP,wind.idcmp,
                                I.waFlags,flags,
                                I.waGadgets,sub.gadgets,
                                I.waNewLookMenus,I.LTRUE,
                                I.waTitle,title,
                                I.waCustomScreen,sub.screen,
                                I.waMinWidth,wind.minwi,
                                I.waMinHeight,wind.minhe,
                                I.waMaxWidth,wind.maxwi,
                                I.waMaxHeight,wind.maxhe,
                                I.waAutoAdjust,I.LTRUE,
                                u.done);
(*    IF iwind#NIL THEN
      wind.xpos:=iwind.leftEdge;
      wind.ypos:=iwind.topEdge;
      wind.width:=iwind.width;
      wind.height:=iwind.height;
    END;*)
  END;
  IF sub.iwindow#NIL THEN
    I.CloseWindow(sub.iwindow);
  END;
  sub.iwindow:=iwind;
  IF iwind=NIL THEN
    bool:=a.Alert("Memory shortage:\nThe window cannot be opened!",NIL);
  ELSE
    IF wind.menu#NIL THEN
      bool:=I.SetMenuStrip(iwind,wind.menu^);
    END;
    sub.rast:=iwind.rPort;
    IF wind.inner THEN
      bool:=I.WindowLimits(iwind,wind.minwi+iwind.borderLeft+iwind.borderRight,wind.minhe+iwind.borderTop+iwind.borderBottom,-1,-1);
    END;
    IF sub.clipregused THEN
      reg:=la.InstallClipRegion(iwind.rPort.layer,sub.clipreg);
    END;
  END;
  RETURN iwind;
END Open;

PROCEDURE (window:Window) SetTitle*(title:e.STRPTR);

BEGIN
  window.title:=title;
END SetTitle;

PROCEDURE (sub:SubWindow) SetTitle*(title:e.STRPTR);

BEGIN
  sub.title:=title;
END SetTitle;

PROCEDURE (sub:SubWindow) SetScreen*(screen:I.ScreenPtr);

BEGIN
  sub.screen:=screen;
  sub.attr:=screen.font;
END SetScreen;

PROCEDURE (window:Window) SetFlags*(flags:LONGSET);

BEGIN
  window.flags:=flags;
END SetFlags;

PROCEDURE (window:Window) GetFlags*():LONGSET;

BEGIN
  RETURN window.flags;
END GetFlags;

PROCEDURE (window:Window) SetIDCMP*(idcmp:LONGSET);

BEGIN
  window.idcmp:=idcmp;
END SetIDCMP;

PROCEDURE (window:Window) GetIDCMP*():LONGSET;

BEGIN
  RETURN window.idcmp;
END GetIDCMP;

PROCEDURE (sub:SubWindow) GetScreen*():I.ScreenPtr;

BEGIN
  RETURN sub.screen;
END GetScreen;

PROCEDURE (window:Window) SetMinMax*(minwi,minhe,maxwi,maxhe:INTEGER);

BEGIN
  window.minwi:=minwi;
  window.minhe:=minhe;
  window.maxwi:=maxwi;
  window.maxhe:=maxhe;
  IF window.width<minwi THEN
    window.width:=minwi;
  ELSIF (window.width>maxwi) AND (maxwi#-1) THEN
    window.width:=maxwi;
  END;
  IF window.height<minhe THEN
    window.height:=minhe;
  ELSIF (window.height>maxhe) AND (maxhe#-1) THEN
    window.height:=maxhe;
  END;
END SetMinMax;

PROCEDURE (sub:SubWindow) SetMinMax*(minwi,minhe,maxwi,maxhe:INTEGER);

BEGIN
  sub.window.SetMinMax(minwi,minhe,maxwi,maxhe);
END SetMinMax;

PROCEDURE (sub:SubWindow) SetGadgets*(gadget:I.GadgetPtr);

VAR i : INTEGER;

BEGIN
  sub.gadgets:=gadget;
  IF sub.iwindow#NIL THEN
    i:=I.AddGList(sub.iwindow,gadget,-1,-1,NIL);
  END;
END SetGadgets;

PROCEDURE (sub:SubWindow) RemoveGadgets*;
(* Remove, NOT free them *)

VAR i : INTEGER;

BEGIN
  IF (sub.iwindow#NIL) & (sub.gadgets#NIL) THEN
    i:=I.RemoveGList(sub.iwindow,sub.gadgets,-1);
  END;
END RemoveGadgets;

PROCEDURE (window:Window) SetDimensions*(xpos,ypos,width,height:INTEGER);

BEGIN
  IF xpos>=0 THEN
    window.xpos:=xpos;
  END;
  IF ypos>=0 THEN
    window.ypos:=ypos;
  END;
  IF width>0 THEN
    window.width:=width;
  END;
  IF height>0 THEN
    window.height:=height;
  END;
END SetDimensions;

PROCEDURE (window:Window) GetDimensions*(VAR xpos,ypos,width,height:INTEGER);

BEGIN
  xpos:=window.xpos;
  ypos:=window.ypos;
  width:=window.width;
  height:=window.height;
END GetDimensions;

PROCEDURE (sub:SubWindow) SetDimensions*(xpos,ypos,width,height:INTEGER);

VAR window : Window;

BEGIN
  window:=sub.window;
  IF xpos>=0 THEN
    window.xpos:=xpos;
  END;
  IF ypos>=0 THEN
    window.ypos:=ypos;
  END;
  IF width>0 THEN
    window.width:=width;
  END;
  IF height>0 THEN
    window.height:=height;
  END;
  IF sub.iwindow#NIL THEN
    I.ChangeWindowBox(sub.iwindow,window.xpos,window.ypos,window.width,window.height);
  END;
END SetDimensions;

PROCEDURE (window:Window) SetMenu*(menu:I.MenuPtr);

VAR bool : BOOLEAN;

BEGIN
  window.menu:=menu;
END SetMenu;

PROCEDURE (sub:SubWindow) SetClipRegion*(xmin,ymin,xmax,ymax:INTEGER);

VAR reg : g.RegionPtr;

BEGIN
  IF sub.clipreg#NIL THEN
    sub.clipreg.bounds.minX:=0;
    sub.clipreg.bounds.minY:=0;
    sub.clipreg.bounds.maxX:=sub.iwindow.width-1;
    sub.clipreg.bounds.maxY:=sub.iwindow.height-1;
    sub.clipreg.regionRectangle.bounds.minX:=xmin;
    sub.clipreg.regionRectangle.bounds.minY:=ymin;
    sub.clipreg.regionRectangle.bounds.maxX:=xmax;
    sub.clipreg.regionRectangle.bounds.maxY:=ymax;
    sub.clipregused:=TRUE;
    IF sub.iwindow#NIL THEN
      reg:=la.InstallClipRegion(sub.iwindow.rPort.layer,sub.clipreg);
    END;
  END;
END SetClipRegion;

PROCEDURE (sub:SubWindow) RemoveClipRegion*;

VAR reg : g.RegionPtr;

BEGIN
  sub.clipregused:=FALSE;
  IF sub.iwindow#NIL THEN
    reg:=la.InstallClipRegion(sub.iwindow.rPort.layer,NIL);
  END;
END RemoveClipRegion;

PROCEDURE (sub:SubWindow) SetFontAttr*(attr:g.TextAttrPtr);

BEGIN
  sub.attr:=attr;
  IF sub.font#NIL THEN
    g.CloseFont(sub.font);
  END;
  sub.font:=df.OpenDiskFont(attr^);
  g.SetFont(sub.rast,sub.font);
END SetFontAttr;

PROCEDURE (sub:SubWindow) GetFontAttr*():g.TextAttrPtr;

BEGIN
  RETURN sub.attr;
END GetFontAttr;

PROCEDURE (sub:SubWindow) GetWindow*():I.WindowPtr;

BEGIN
  RETURN sub.iwindow;
END GetWindow;

PROCEDURE (sub:SubWindow) SetScreenBack*(screenback:BOOLEAN);

BEGIN
  sub.screenback:=screenback;
END SetScreenBack;

PROCEDURE (sub:SubWindow) GetMousePos*(VAR x,y:INTEGER);

BEGIN
  IF sub.iwindow#NIL THEN
    x:=sub.iwindow.mouseX;
    y:=sub.iwindow.mouseY;
  END;
END GetMousePos;

PROCEDURE (sub:SubWindow) ToFront*;

BEGIN
  IF sub.iwindow#NIL THEN
    I.WindowToFront(sub.iwindow);
  END;
END ToFront;

PROCEDURE (sub:SubWindow) ToBack*;

BEGIN
  IF sub.iwindow#NIL THEN
    I.WindowToBack(sub.iwindow);
  END;
END ToBack;

PROCEDURE (sub:SubWindow) Activate*;

BEGIN
  IF sub.iwindow#NIL THEN
    I.ActivateWindow(sub.iwindow);
  END;
END Activate;

PROCEDURE (sub:SubWindow) WaitPort*;

BEGIN
  e.WaitPort(sub.iwindow.userPort);
END WaitPort;

PROCEDURE (sub:SubWindow) GetIMes*(mes:I.IntuiMessagePtr);

VAR message : I.IntuiMessagePtr;

BEGIN
  IF mes#NIL THEN
    mes.class:=LONGSET{};
    mes.code:=0;
    mes.iAddress:=NIL;
    mes.qualifier:=SET{};
    IF sub.iwindow#NIL THEN
      message:=e.GetMsg(sub.iwindow.userPort);
      IF message#NIL THEN
        e.CopyMemAPTR(message,mes,SIZE(I.IntuiMessage));
        e.ReplyMsg(message);
      END;
    END;
  END;
END GetIMes;

PROCEDURE (sub:SubWindow) SetBusyPointer*;
(* Must be save to call more than once! *)

BEGIN
  IF sub.iwindow#NIL THEN
    pt.SetBusyPointer(sub.iwindow);
  END;
END SetBusyPointer;

PROCEDURE (sub:SubWindow) ClearPointer*;
(* Must be save to call more than once! *)

BEGIN
  IF sub.iwindow#NIL THEN
    pt.ClearPointer(sub.iwindow);
  END;
END ClearPointer;

PROCEDURE (sub:SubWindow) Refresh*;

BEGIN
  IF sub.iwindow#NIL THEN
    sub.window.xpos:=sub.iwindow.leftEdge;
    sub.window.ypos:=sub.iwindow.topEdge;
    sub.window.width:=sub.iwindow.width;
    sub.window.height:=sub.iwindow.height;
    IF sub.window.inner THEN
      sub.window.width:=sub.window.width-sub.iwindow.borderLeft-sub.iwindow.borderRight;
      sub.window.height:=sub.window.height-sub.iwindow.borderTop-sub.iwindow.borderBottom;
    END;
  END;
END Refresh;

PROCEDURE RefreshAllWindows*;

VAR wind,sub : l.Node;

BEGIN
  wind:=windowlist.head;
  WHILE wind#NIL DO
    WITH wind: Window DO
      sub:=wind.sublist.head;
      WHILE sub#NIL DO
        sub(SubWindow).Refresh;
        sub:=sub.next;
      END;
    END;
    wind:=wind.next;
  END;
END RefreshAllWindows;

PROCEDURE (sub:SubWindow) NoGadgets*():BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  IF sub.gadgets#NIL THEN
    ret:=FALSE;
  END;
  RETURN ret;
END NoGadgets;

PROCEDURE (sub:SubWindow) Close*;

VAR reg : g.RegionPtr;

BEGIN
  IF sub.iwindow#NIL THEN
    sub.Refresh;
    IF sub.font#NIL THEN
      g.CloseFont(sub.font);
    END;
    IF sub.window.menu#NIL THEN
      I.ClearMenuStrip(sub.iwindow);
    END;
    sub.RemoveGadgets;
(*    reg:=la.InstallClipRegion(sub.iwindow.rPort.layer,NIL);*)
    I.CloseWindow(sub.iwindow);
    sub.iwindow:=NIL;
  END;
END Close;

PROCEDURE (wind:Window) Close*;

VAR sub : l.Node;

BEGIN
  sub:=wind.sublist.head;
  WHILE sub#NIL DO
    sub(SubWindow).Close;
    sub:=sub.next;
  END;
END Close;

PROCEDURE (sub:SubWindow) Destruct*;

BEGIN
  sub.Close;
  IF sub.clipreg#NIL THEN
    IF sub.clipreg.regionRectangle#NIL THEN DISPOSE(sub.clipreg.regionRectangle); END;
    g.DisposeRegion(sub.clipreg);
  END;
  sub.Remove;
  sub.Destruct^;
END Destruct;

PROCEDURE (wind:Window) Destruct*;

VAR sub,next : l.Node;

BEGIN
  sub:=wind.sublist.head;
  WHILE sub#NIL DO
    next:=sub.next;
    sub.Destruct;
    sub:=next;
  END;
  wind.sublist.Destruct;
  wind.Remove;
  wind.Destruct^;
END Destruct;

PROCEDURE CloseAllWindows*;

VAR wind : l.Node;

BEGIN
  wind:=windowlist.head;
  WHILE wind#NIL DO
    wind(Window).Close;
    wind:=wind.next;
  END;
END CloseAllWindows;

PROCEDURE DestructAllWindows*;

VAR wind,next : l.Node;

BEGIN
  wind:=windowlist.head;
  WHILE wind#NIL DO
    next:=wind.next;
    wind(Window).Destruct;
    wind:=next;
  END;
END DestructAllWindows;

BEGIN
  windowlist:=m.Create();
  IF windowlist=NIL THEN
    HALT(20);
  END;

CLOSE
  IF windowlist#NIL THEN
(*    DestructAllWindows;*) (* Must be called by application! *)
    windowlist.Destruct;
  END;
END WindowManager.

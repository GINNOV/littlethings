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


MODULE WindowManager;

IMPORT I : Intuition,
       g : Graphics,
       d : Dos,
       e : Exec,
       l : LinkedLists,
       s : SYSTEM,
       r : Requests,
       a : Alerts,
       st: Strings,
       it: IntuitionTools,
       gm: GadgetManager,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE WindowListEl = RECORD(l.NodeDesc)
       wind : I.WindowPtr;
     END;
     Window = RECORD(l.NodeDesc)
       wind : I.WindowPtr;
       windl  : l.List;
       xpos,
       ypos,
       width,
       height,
       minwi,
       minhe,
       maxwi,
       maxhe  : INTEGER;
       title  : e.STRPTR;
       flags,
       idcmp  : LONGSET;
       screen : I.ScreenPtr;
       windId : INTEGER;
       scale  : BOOLEAN;
       gadgets: I.GadgetPtr;
     END;

VAR windowlist      : l.List;
    node            : l.Node;
    requestwindow * : I.WindowPtr;
    topaz           : g.TextFontPtr;
    topazattr       : g.TextAttr;

PROCEDURE GetFreeId():INTEGER;

VAR node : l.Node;
    ret  : INTEGER;
    ok   : BOOLEAN;

BEGIN
  ret:=-1;
  LOOP
    INC(ret);
    ok:=TRUE;
    node:=windowlist.head;
    WHILE node#NIL DO
      IF node(Window).windId=ret THEN
        node:=NIL;
        ok:=FALSE;
      ELSE
        node:=node.next;
      END;
    END;
    IF ok THEN
      EXIT;
    END;
  END;
  RETURN ret;
END GetFreeId;

PROCEDURE GetWindow(id:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  node:=windowlist.head;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF node(Window).windId=id THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetWindow;

PROCEDURE SetFont(wind:I.WindowPtr);

BEGIN
  IF ((wind.rPort.font.xSize>8) OR (wind.rPort.font.ySize>8)) AND (topaz#NIL) THEN
    g.SetFont(wind.rPort,topaz);
  END;
END SetFont;

PROCEDURE InitWindow*(xpos,ypos,width,height:INTEGER;title:e.STRPTR;flags,idcmp:LONGSET;screen:I.ScreenPtr;scale:BOOLEAN):INTEGER;

VAR ret  : INTEGER;
    node : l.Node;

BEGIN
  ret:=GetFreeId();
  NEW(node(Window));
  WITH node: Window DO
    node.xpos:=xpos;
    node.ypos:=ypos;
    node.width:=width;
    node.height:=height;
    node.minwi:=width;
    node.minhe:=height;
    node.maxwi:=-1;
    node.maxhe:=-1;
    node.title:=title;
(*    NEW(node.title,st.Length(title)+1);
    COPY(title,node.title^);*)
    node.flags:=flags;
    node.idcmp:=idcmp;
    node.screen:=screen;
    node.windId:=ret;
    node.scale:=scale;
    node.gadgets:=NIL;
    node.windl:=l.Create();
  END;
  windowlist.AddTail(node);
  RETURN ret;
END InitWindow;

PROCEDURE OpenWindow*(id:INTEGER):I.WindowPtr;

VAR wind   : I.WindowPtr;
    node   : l.Node;
    xpos,
    ypos,
    width,
    height : INTEGER;
    bool   : BOOLEAN;

BEGIN
  wind:=NIL;
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      xpos:=node.xpos;
      ypos:=node.ypos;
      width:=node.width;
      height:=node.height;
      IF node.xpos>node.screen.width-node.width THEN
        xpos:=node.screen.width-node.width;
      END;
      IF node.ypos>node.screen.height-node.height THEN
        ypos:=node.screen.height-node.height;
      END;
      IF node.scale THEN
        IF xpos<0 THEN
          xpos:=0;
        END;
        IF ypos<0 THEN
          ypos:=0;
        END;
        IF xpos>node.screen.width-node.width THEN
          width:=node.screen.width-xpos;
        END;
        IF ypos>node.screen.height-node.height THEN
          height:=node.screen.height-ypos;
        END;
        IF (width<node.minwi) OR (height<node.minhe) THEN
          xpos:=-1;
        END;
      END;
      IF (xpos>=0) AND (ypos>=0) THEN
        node.xpos:=xpos;
        node.ypos:=ypos;
        node.width:=width;
        node.height:=height;
        IF node.gadgets=NIL THEN
          wind:=it.SetWindow(node.xpos,node.ypos,node.width,node.height,s.ADR(node.title^),node.flags,node.idcmp,node.screen);
        ELSE
          wind:=it.SetGadgetWindow(node.xpos,node.ypos,node.width,node.height,s.ADR(node.title^),node.flags,node.idcmp,node.gadgets,node.screen);
        END;
        IF node.wind#NIL THEN
          I.CloseWindow(node.wind);
        END;
        node.wind:=wind;
        IF wind=NIL THEN
          bool:=a.Alert("Memory shortage:\nThe window cannot be opened!",NIL);
        ELSE
          SetFont(wind);
          bool:=I.WindowLimits(wind,node.minwi,node.minhe,node.maxwi,node.maxhe);
        END;
      ELSE
        IF requestwindow#NIL THEN
          bool:=r.RequestWin("The window is too big to","open it on this screen!","","    OK    ",requestwindow);
        ELSE
          bool:=r.Request("The window is too big to","open it on this screen!","","    OK    ");
        END;
      END;
    END;
  END;
  RETURN wind;
END OpenWindow;

PROCEDURE OpenMultiWindow*(id:INTEGER;gadgets:I.GadgetPtr):I.WindowPtr;

VAR wind   : I.WindowPtr;
    node,
    node2  : l.Node;
    xpos,
    ypos,
    width,
    height : INTEGER;
    bool   : BOOLEAN;

BEGIN
  wind:=NIL;
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      xpos:=node.xpos;
      ypos:=node.ypos;
      width:=node.width;
      height:=node.height;
      IF node.xpos>node.screen.width-node.width THEN
        xpos:=node.screen.width-node.width;
      END;
      IF node.ypos>node.screen.height-node.height THEN
        ypos:=node.screen.height-node.height;
      END;
      IF node.scale THEN
        IF xpos<0 THEN
          xpos:=0;
        END;
        IF ypos<0 THEN
          ypos:=0;
        END;
        IF xpos>node.screen.width-node.width THEN
          width:=node.screen.width-xpos;
        END;
        IF ypos>node.screen.height-node.height THEN
          height:=node.screen.height-ypos;
        END;
        IF (width<node.minwi) OR (height<node.minhe) THEN
          xpos:=-1;
        END;
      END;
      IF (xpos>=0) AND (ypos>=0) THEN
        node.xpos:=xpos;
        node.ypos:=ypos;
        node.width:=width;
        node.height:=height;
        IF gadgets=NIL THEN
          wind:=it.SetWindow(node.xpos,node.ypos,node.width,node.height,s.ADR(node.title^),node.flags,node.idcmp,node.screen);
        ELSE
          wind:=it.SetGadgetWindow(node.xpos,node.ypos,node.width,node.height,s.ADR(node.title^),node.flags,node.idcmp,gadgets,node.screen);
        END;
        IF wind#NIL THEN
          NEW(node2(WindowListEl));
          node2(WindowListEl).wind:=wind;
          node(Window).windl.AddTail(node2);
        END;
        IF wind=NIL THEN
          bool:=a.Alert("Memory shortage:\nThe window cannot be opened",NIL);
        ELSE
          SetFont(wind);
          bool:=I.WindowLimits(wind,node.minwi,node.minhe,node.maxwi,node.maxhe);
        END;
      ELSE
        IF requestwindow#NIL THEN
          bool:=r.RequestWin("The window is too big to","open it on this screen!","","    OK    ",requestwindow);
        ELSE
          bool:=r.Request("The window is too big to","open it on this screen!","","    OK    ");
        END;
      END;
    END;
  END;
  RETURN wind;
END OpenMultiWindow;

PROCEDURE ChangeTitle*(id:INTEGER;title:e.STRPTR);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    node(Window).title:=title;
(*    node(Window).title:=NIL;
    NEW(node(Window).title,st.Length(title)+1);
    COPY(title,node(Window).title^);*)
  END;
END ChangeTitle;

PROCEDURE ChangeScreen*(id:INTEGER;screen:I.ScreenPtr);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    node(Window).screen:=screen;
  END;
END ChangeScreen;

PROCEDURE SetMinMax*(id:INTEGER;minwi,minhe,maxwi,maxhe:INTEGER);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      node.minwi:=minwi;
      node.minhe:=minhe;
      node.maxwi:=maxwi;
      node.maxhe:=maxhe;
    END;
  END;
END SetMinMax;

PROCEDURE SetGadgets*(id:INTEGER;gadget:I.GadgetPtr);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      node.gadgets:=gadget;
    END;
  END;
END SetGadgets;

PROCEDURE SetDimensions*(id:INTEGER;xpos,ypos,width,height:INTEGER);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      IF xpos>=0 THEN
        node.xpos:=xpos;
      END;
      IF ypos>=0 THEN
        node.ypos:=ypos;
      END;
      node.width:=width;
      node.height:=height;
    END;
  END;
END SetDimensions;

PROCEDURE GetDimensions*(id:INTEGER;VAR xpos,ypos,width,height:INTEGER);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      xpos:=node.xpos;
      ypos:=node.ypos;
      width:=node.width;
      height:=node.height;
    END;
  END;
END GetDimensions;

PROCEDURE RefreshWindow*(id:INTEGER);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      IF node.wind#NIL THEN
        node.xpos:=node.wind.leftEdge;
        node.ypos:=node.wind.topEdge;
        node.width:=node.wind.width;
        node.height:=node.wind.height;
      END;
    END;
  END;
END RefreshWindow;

PROCEDURE RefreshAllWindows*;

VAR node,node2 : l.Node;

BEGIN
  node:=windowlist.head;
  WHILE node#NIL DO
    WITH node: Window DO
      IF node.wind#NIL THEN
        node.xpos:=node.wind.leftEdge;
        node.ypos:=node.wind.topEdge;
        node.width:=node.wind.width;
        node.height:=node.wind.height;
      END;
      node2:=node.windl.head;
      WHILE node2#NIL DO
        WITH node2: WindowListEl DO
          IF node2.wind#NIL THEN
            node.xpos:=node2.wind.leftEdge;
            node.ypos:=node2.wind.topEdge;
            node.width:=node2.wind.width;
            node.height:=node2.wind.height;
          END;
        END;
        node2:=node2.next;
      END;
    END;
    node:=node.next;
  END;
END RefreshAllWindows;

PROCEDURE FreeGadgets*(id:INTEGER);

VAR node,node2 : l.Node;
    free       : BOOLEAN;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      free:=TRUE;
      IF node.wind#NIL THEN
        free:=FALSE;
      END;
      node2:=node.windl.head;
      WHILE node2#NIL DO
        IF node2(WindowListEl).wind#NIL THEN
          free:=FALSE;
        END;
        node2:=NIL;
      END;
      IF (node.gadgets#NIL) AND (free) THEN
        gm.FreeGadgetList(node.gadgets);
        node.gadgets:=NIL;
      END;
    END;
  END;
END FreeGadgets;

PROCEDURE NoGadgets*(id:INTEGER):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=TRUE;
  node:=GetWindow(id);
  IF node(Window).gadgets#NIL THEN
    ret:=FALSE;
  END;
  RETURN ret;
END NoGadgets;

PROCEDURE CloseWindow*(id:INTEGER);

VAR node : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      IF node.wind#NIL THEN
        node.xpos:=node.wind.leftEdge;
        node.ypos:=node.wind.topEdge;
        node.width:=node.wind.width;
        node.height:=node.wind.height;
        I.CloseWindow(node.wind);
        node.wind:=NIL;
      END;
    END;
  END;
END CloseWindow;

PROCEDURE CloseMultiWindow*(id:INTEGER;wind:I.WindowPtr);

VAR node,node2 : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      node2:=node.windl.head;
      WHILE node2#NIL DO
        WITH node2: WindowListEl DO
          IF node2.wind=wind THEN
            node.xpos:=node2.wind.leftEdge;
            node.ypos:=node2.wind.topEdge;
            node.width:=node2.wind.width;
            node.height:=node2.wind.height;
            I.CloseWindow(node2.wind);
            node2.Remove;
            node2:=NIL;
          END;
        END;
        IF node2#NIL THEN
          node2:=node2.next;
        END;
      END;
    END;
  END;
END CloseMultiWindow;

PROCEDURE FreeWindow*(id:INTEGER);

VAR node,node2 : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    IF node(Window).wind#NIL THEN
      I.CloseWindow(node(Window).wind);
    END;
    node2:=node(Window).windl.head;
    WHILE node2#NIL DO
      I.CloseWindow(node2(WindowListEl).wind);
      node2:=node2.next;
    END;
    IF node(Window).gadgets#NIL THEN
      gm.FreeGadgetList(node(Window).gadgets);
    END;
    node.Remove;
  END;
END FreeWindow;

PROCEDURE CloseAllWindows*;

VAR node2 : l.Node;

BEGIN
  node:=windowlist.head;
  WHILE node#NIL DO
    WITH node: Window DO
      IF node.wind#NIL THEN
        node.xpos:=node.wind.leftEdge;
        node.ypos:=node.wind.topEdge;
        node.width:=node.wind.width;
        node.height:=node.wind.height;
        I.CloseWindow(node.wind);
        node.wind:=NIL;
      END;
      node2:=node.windl.head;
      WHILE node2#NIL DO
        IF node2(WindowListEl).wind#NIL THEN
          I.CloseWindow(node2(WindowListEl).wind);
        END;
        node2:=node2.next;
      END;
    END;
    node:=node.next;
  END;
END CloseAllWindows;

PROCEDURE FreeAllWindows*;

VAR node2 : l.Node;

BEGIN
  node:=windowlist.head;
  WHILE node#NIL DO
    IF node(Window).wind#NIL THEN
      I.CloseWindow(node(Window).wind);
    END;
    node2:=node(Window).windl.head;
    WHILE node2#NIL DO
      IF node2(WindowListEl).wind#NIL THEN
        I.CloseWindow(node2(WindowListEl).wind);
      END;
      node2:=node2.next;
    END;
    IF node(Window).gadgets#NIL THEN
      gm.FreeGadgetList(node(Window).gadgets);
    END;
    node.Remove;
    node:=node.next;
  END;
END FreeAllWindows;

BEGIN
  windowlist:=l.Create();
  topazattr.name:=s.ADR("topaz.font");
  topazattr.ySize:=8;
  topazattr.style:=SHORTSET{};
  topazattr.flags:=SHORTSET{};
  topaz:=NIL;
  topaz:=g.OpenFont(topazattr);
CLOSE
  node:=windowlist.head;
  WHILE node#NIL DO
    IF node(Window).wind#NIL THEN
      I.CloseWindow(node(Window).wind);
    END;
    IF node(Window).gadgets#NIL THEN
      gm.FreeGadgetList(node(Window).gadgets);
    END;
    node.Remove;
    node:=node.next;
  END;
  g.CloseFont(topaz);
END WindowManager.

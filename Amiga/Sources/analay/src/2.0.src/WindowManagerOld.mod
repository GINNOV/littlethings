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
       st: Strings,
       it: IntuitionTools,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE WindowListEl = RECORD(l.NodeDesc)
       wind    : I.WindowPtr;
       gadgets : I.GadgetPtr;
     END;
     Window = RECORD(l.NodeDesc)
       wind   : I.WindowPtr;
       windl  : l.List;
       xpos,
       ypos,
       width,
       height,
       minwi,
       minhe,
       maxwi,
       maxhe  : INTEGER;
       inner  : BOOLEAN;
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
    new             : I.ExtNewWindow;

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

PROCEDURE InitWindow*(xpos,ypos,width,height:INTEGER;inner:BOOLEAN;title:e.STRPTR;flags,idcmp:LONGSET;screen:I.ScreenPtr):INTEGER;

VAR ret  : INTEGER;
    node : l.Node;

BEGIN
  ret:=GetFreeId();
  NEW(node(Window));
  WITH node: Window DO
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
    node.screen:=screen;
    node.windId:=ret;
    node.gadgets:=NIL;
    node.windl:=l.Create();
  END;
  windowlist.AddTail(node);
  RETURN ret;
END InitWindow;

PROCEDURE OpenWindow*(id:INTEGER;gadgets:I.GadgetPtr):I.WindowPtr;

VAR wind   : I.WindowPtr;
    node   : l.Node;
    bool   : BOOLEAN;

BEGIN
  wind:=NIL;
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      node.gadgets:=gadgets;
      IF node.inner THEN
        wind:=I.OpenWindowTags(new,I.waLeft,node.xpos,
                                   I.waTop,node.ypos,
                                   I.waInnerWidth,node.width,
                                   I.waInnerHeight,node.height,
                                   I.waDetailPen,0,
                                   I.waBlockPen,1,
                                   I.waIDCMP,node.idcmp,
                                   I.waFlags,node.flags,
                                   I.waGadgets,node.gadgets,
                                   I.waNewLookMenus,I.LTRUE,
                                   I.waTitle,node.title,
                                   I.waCustomScreen,node.screen,
                                   I.waMinWidth,node.minwi,
                                   I.waMinHeight,node.minhe,
                                   I.waMaxWidth,node.maxwi,
                                   I.waMaxHeight,node.maxhe,
                                   I.waAutoAdjust,I.LTRUE,
                                   u.done);
(*        IF wind#NIL THEN
          node.width:=node.innerwi+wind.borderLeft+wind.borderRight;
          node.height:=node.innerhe+wind.borderTop+wind.borderBottom;
        END;*)
      ELSE
        wind:=I.OpenWindowTags(new,I.waLeft,node.xpos,
                                   I.waTop,node.ypos,
                                   I.waWidth,node.width,
                                   I.waHeight,node.height,
                                   I.waDetailPen,0,
                                   I.waBlockPen,1,
                                   I.waIDCMP,node.idcmp,
                                   I.waFlags,node.flags,
                                   I.waGadgets,node.gadgets,
                                   I.waNewLookMenus,I.LTRUE,
                                   I.waTitle,node.title,
                                   I.waCustomScreen,node.screen,
                                   I.waMinWidth,node.minwi,
                                   I.waMinHeight,node.minhe,
                                   I.waMaxWidth,node.maxwi,
                                   I.waMaxHeight,node.maxhe,
                                   I.waAutoAdjust,I.LTRUE,
                                   u.done);
(*        IF wind#NIL THEN
          node.innerwi:=node.width-wind.borderLeft-wind.borderRight;
          node.innerhe:=node.height-wind.borderTop-wind.borderBottom;
        END;*)
      END;
      IF node.wind#NIL THEN
        I.CloseWindow(node.wind);
      END;
      node.wind:=wind;
      IF wind=NIL THEN
        bool:=a.Alert("Memory shortage:\nThe window cannot be opened!",NIL);
      ELSE
        IF node.inner THEN
          bool:=I.WindowLimits(wind,node.minwi+wind.borderLeft+wind.borderRight,node.minhe+wind.borderTop+wind.borderBottom,-1,-1);
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
    bool   : BOOLEAN;

BEGIN
  wind:=NIL;
  node:=GetWindow(id);
  IF node#NIL THEN
    WITH node: Window DO
      IF node.inner THEN
        wind:=I.OpenWindowTags(new,I.waLeft,node.xpos,
                                   I.waTop,node.ypos,
                                   I.waInnerWidth,node.width,
                                   I.waInnerHeight,node.height,
                                   I.waDetailPen,0,
                                   I.waBlockPen,1,
                                   I.waIDCMP,node.idcmp,
                                   I.waFlags,node.flags,
                                   I.waGadgets,gadgets,
                                   I.waNewLookMenus,I.LTRUE,
                                   I.waTitle,node.title,
                                   I.waCustomScreen,node.screen,
                                   I.waMinWidth,node.minwi,
                                   I.waMinHeight,node.minhe,
                                   I.waMaxWidth,node.maxwi,
                                   I.waMaxHeight,node.maxhe,
                                   I.waAutoAdjust,I.LTRUE,
                                   u.done);
(*        IF wind#NIL THEN
          node.width:=node.innerwi+wind.borderLeft+wind.borderRight;
          node.height:=node.innerhe+wind.borderTop+wind.borderBottom;
        END;*)
      ELSE
        wind:=I.OpenWindowTags(new,I.waLeft,node.xpos,
                                   I.waTop,node.ypos,
                                   I.waWidth,node.width,
                                   I.waHeight,node.height,
                                   I.waDetailPen,0,
                                   I.waBlockPen,1,
                                   I.waIDCMP,node.idcmp,
                                   I.waFlags,node.flags,
                                   I.waGadgets,gadgets,
                                   I.waNewLookMenus,I.LTRUE,
                                   I.waTitle,node.title,
                                   I.waCustomScreen,node.screen,
                                   I.waMinWidth,node.minwi,
                                   I.waMinHeight,node.minhe,
                                   I.waMaxWidth,node.maxwi,
                                   I.waMaxHeight,node.maxhe,
                                   I.waAutoAdjust,I.LTRUE,
                                   u.done);
(*        IF wind#NIL THEN
          node.innerwi:=node.width-wind.borderLeft-wind.borderRight;
          node.innerhe:=node.height-wind.borderTop-wind.borderBottom;
        END;*)
      END;
      IF wind#NIL THEN
        NEW(node2(WindowListEl));
        node2(WindowListEl).wind:=wind;
        node2(WindowListEl).gadgets:=gadgets;
        node(Window).windl.AddTail(node2);
      END;
      IF wind=NIL THEN
        bool:=a.Alert("Memory shortage:\nThe window cannot be opened",NIL);
      ELSE
        IF node.inner THEN
          bool:=I.WindowLimits(wind,node.minwi+wind.borderLeft+wind.borderRight,node.minhe+wind.borderTop+wind.borderBottom,-1,-1);
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
        IF node.inner THEN
          node.width:=node.width-node.wind.borderLeft-node.wind.borderRight;
          node.height:=node.height-node.wind.borderTop-node.wind.borderBottom;
        END;
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
        IF node.inner THEN
          node.width:=node.width-node.wind.borderLeft-node.wind.borderRight;
          node.height:=node.height-node.wind.borderTop-node.wind.borderBottom;
        END;
      END;
      node2:=node.windl.head;
      WHILE node2#NIL DO
        WITH node2: WindowListEl DO
          IF node2.wind#NIL THEN
            node.xpos:=node2.wind.leftEdge;
            node.ypos:=node2.wind.topEdge;
            node.width:=node2.wind.width;
            node.height:=node2.wind.height;
            IF node.inner THEN
              node.width:=node.width-node2.wind.borderLeft-node2.wind.borderRight;
              node.height:=node.height-node2.wind.borderTop-node2.wind.borderBottom;
            END;
          END;
        END;
        node2:=node2.next;
      END;
    END;
    node:=node.next;
  END;
END RefreshAllWindows;

(*PROCEDURE FreeGadgets*(id:INTEGER);

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
END FreeGadgets;*)

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
        IF node.inner THEN
          node.width:=node.width-node.wind.borderLeft-node.wind.borderRight;
          node.height:=node.height-node.wind.borderTop-node.wind.borderBottom;
        END;
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
            IF node.inner THEN
              node.width:=node.width-node2.wind.borderLeft-node2.wind.borderRight;
              node.height:=node.height-node2.wind.borderTop-node2.wind.borderBottom;
            END;
            I.CloseWindow(node2.wind);
            node2.Remove;
            (* $IFNOT GarbageCollector *)
              DISPOSE(node2);
            (* $END *)
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

VAR node,node2,node3 : l.Node;

BEGIN
  node:=GetWindow(id);
  IF node#NIL THEN
    IF node(Window).wind#NIL THEN
      I.CloseWindow(node(Window).wind);
    END;
    node2:=node(Window).windl.head;
    WHILE node2#NIL DO
      I.CloseWindow(node2(WindowListEl).wind);
      node3:=node2;
      node2:=node2.next;
      (* $IFNOT GarbageCollector *)
        DISPOSE(node3);
      (* $END *)
    END;
    node.Remove;
    (* $IFNOT GarbageCollector *)
      DISPOSE(node(Window).windl);
      DISPOSE(node);
    (* $END *)
  END;
END FreeWindow;

PROCEDURE CloseAllWindows*;

VAR node,node2,node3 : l.Node;

BEGIN
  node:=windowlist.head;
  WHILE node#NIL DO
    WITH node: Window DO
      IF node.wind#NIL THEN
        node.xpos:=node.wind.leftEdge;
        node.ypos:=node.wind.topEdge;
        node.width:=node.wind.width;
        node.height:=node.wind.height;
        IF node.inner THEN
          node.width:=node.width-node.wind.borderLeft-node.wind.borderRight;
          node.height:=node.height-node.wind.borderTop-node.wind.borderBottom;
        END;
        I.CloseWindow(node.wind);
        node.wind:=NIL;
      END;
      node2:=node.windl.head;
      WHILE node2#NIL DO
        IF node2(WindowListEl).wind#NIL THEN
          I.CloseWindow(node2(WindowListEl).wind);
        END;
        node3:=node2;
        node2:=node2.next;
        (* $IFNOT GarbageCollector *)
          DISPOSE(node3);
        (* $END *)
      END;
    END;
    node:=node.next;
  END;
END CloseAllWindows;

PROCEDURE FreeAllWindows*;

VAR node,node2,node3 : l.Node;

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
      node3:=node2;
      node2:=node2.next;
      (* $IFNOT GarbageCollector *)
        DISPOSE(node3);
      (* $END *)
    END;
    node2:=node.next;
    node.Remove;
    (* $IFNOT GarbageCollector *)
      DISPOSE(node(Window).windl);
      DISPOSE(node);
    (* $END *)
    node:=node2;
  END;
END FreeAllWindows;

BEGIN
  windowlist:=l.Create();

  INCL(new.nw.flags,I.nwExtended);
  new.nw.detailPen:=0;
  new.nw.blockPen:=1;
CLOSE
  FreeAllWindows;
END WindowManager.

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


MODULE Preview5;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       df : DiskFont,
       fr : FileReq,
       it : IntuitionTools,
       tt : TextTools,
       gt : GraphicsTools,
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
       p3 : Preview3,
       p4 : Preview4,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j     : INTEGER;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    bool      : BOOLEAN;
    listId  * : INTEGER;

PROCEDURE CreateGraph*(VAR node:l.Node;waitmouse:BOOLEAN):BOOLEAN;

VAR x,y : INTEGER;
    ret : BOOLEAN;

PROCEDURE DrawBorder;

VAR x,y,width,height : INTEGER;

BEGIN
  IF node IS p1.Line THEN
    p1.PageToPagePicC(node(p1.Box).xpos,node(p1.Box).ypos,x,y);
    p1.PageToPagePic(node(p1.Box).width,node(p1.Box).height,width,height);
    g.Move(p1.previewwindow.rPort,x,y);
    g.Draw(p1.previewwindow.rPort,x+width,y+height);
  ELSE
    p1.DrawSimpleBorder(node,FALSE);
  END;
END DrawBorder;

BEGIN
  IF node IS p1.Line THEN
    g.SetDrMd(p1.previewwindow.rPort,SHORTSET{g.complement});
  END;
  WITH node: p1.Graph DO
    node.linecolor:=p1.black;
    node.fillcolor:=p1.black;
    node.dofill:=FALSE;
    node.linewidth:=0;
  END;
  ret:=TRUE;
  IF waitmouse THEN
    REPEAT
      e.WaitPort(p1.previewwindow.userPort);
      it.GetIMes(p1.previewwindow,class,code,address);
    UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class);
  END;
  IF (code=I.selectDown) OR NOT(waitmouse) THEN
    WITH node: p1.Box DO
      it.GetMousePos(p1.previewwindow,x,y);
      p1.RemovePagePicOffsets(x,y);
(*      INC(x,p1.offx);
      INC(y,p1.offy);*)
      node.pagepicx:=x;
      node.pagepicy:=y;
      p1.CorrectBoxPages(node);
      IF p1.snaptoras THEN
        p1.SnapToRas(node.xpos,node.ypos);
        p1.SnapToRas(node.width,node.height);
        p1.CorrectBoxPagePics(node);
      END;
      DrawBorder;
      REPEAT
        e.WaitPort(p1.previewwindow.userPort);
        REPEAT
          it.GetIMes(p1.previewwindow,class,code,address);
        UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class) OR (I.intuiTicks IN class) OR (class=LONGSET{});
        IF NOT(I.intuiTicks IN class) THEN
          it.GetMousePos(p1.previewwindow,x,y);
          p1.RemovePagePicOffsets(x,y);
  (*        INC(x,p1.offx);
          INC(y,p1.offy);*)
          DrawBorder;
          node.pagepicwi:=x-node.pagepicx;
          node.pagepiche:=y-node.pagepicy;
          p1.CorrectBoxPages(node);
          IF p1.snaptoras THEN
            p1.SnapToRas(node.xpos,node.ypos);
            p1.SnapToRas(node.width,node.height);
            p1.CorrectBoxPagePics(node);
          END;
          DrawBorder;
        END;
      UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class);
      DrawBorder;
      IF I.menuPick IN class THEN
        ret:=FALSE;
      ELSE
(*        IF (node.pagepicwi>=0) AND (node.pagepiche<0) THEN
          node(p1.Line).turnround:=TRUE;
        ELSE
          node(p1.Line).turnround:=FALSE;
        END;*)
        IF NOT(node IS p1.Line) THEN
          IF node.pagepicwi<0 THEN
            node.pagepicwi:=-node.pagepicwi;
            node.pagepicx:=node.pagepicx-node.pagepicwi;
          END;
          IF node.pagepiche<0 THEN
            node.pagepiche:=-node.pagepiche;
            node.pagepicy:=node.pagepicy-node.pagepiche;
          END;
        END;
        p1.CorrectBoxPages(node);
        IF p1.snaptoras THEN
          p1.SnapToRas(node.xpos,node.ypos);
          p1.SnapToRas(node.width,node.height);
          p1.CorrectBoxPagePics(node);
        END;
        node.sizechanged:=TRUE;
        node.poschanged:=TRUE;
        node.locked:=FALSE;
        node.fastdraw:=FALSE;
        p1.boxes.AddTail(node);
      END;
    END;
  ELSE
    ret:=FALSE;
  END;
  IF node IS p1.Line THEN
    g.SetDrMd(p1.previewwindow.rPort,g.jam1);
  END;
  RETURN ret;
END CreateGraph;

PROCEDURE CreateTextLine*;

VAR node,node2 : l.Node;
    x,y        : INTEGER;
    bool,ret   : BOOLEAN;

BEGIN
  ret:=TRUE;
  node:=NIL;
  NEW(node(p1.TextLine));
  WITH node: p1.TextLine DO
    node.string:="";
    node.font:=p1.fonts.head;
    IF node.font#NIL THEN
      node.fontsize:=node.font(p1.Font).sizes.head;
    END;
    node.colf:=p1.black;
    node.colb:=p1.white;
    node.style:=SHORTSET{};
    node.trans:=TRUE;
  END;
  ret:=p3.ChangeTextLine(node);
  IF ret THEN
    WITH node: p1.Box DO
      I.ActivateWindow(p1.previewwindow);
      g.SetDrMd(p1.previewwindow.rPort,SHORTSET{g.complement});
      p4.PlotTextLine(p1.previewrast,node,FALSE);
      REPEAT
        e.WaitPort(p1.previewwindow.userPort);
        REPEAT
          it.GetIMes(p1.previewwindow,class,code,address);
        UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class) OR (I.intuiTicks IN class) OR (class=LONGSET{});
        IF NOT(I.intuiTicks IN class) THEN
          it.GetMousePos(p1.previewwindow,x,y);
          p1.RemovePagePicOffsets(x,y);
    (*      INC(x,p1.offx);
          INC(y,p1.offy);*)
          p4.PlotTextLine(p1.previewrast,node,FALSE);
          node(p1.Box).pagepicx:=x;
          node(p1.Box).pagepicy:=y;
          p1.CorrectBoxPages(node);
          IF p1.snaptoras THEN
            p1.SnapToRas(node(p1.Box).xpos,node(p1.Box).ypos);
            p1.SnapToRas(node(p1.Box).width,node(p1.Box).height);
            p1.CorrectBoxPagePics(node);
          END;
          p4.PlotTextLine(p1.previewrast,node,FALSE);
        END;
      UNTIL (I.mouseButtons IN class) OR (I.menuPick IN class);
      p4.PlotTextLine(p1.previewrast,node,FALSE);
      g.SetDrMd(p1.previewrast,g.jam1);
      IF I.mouseButtons IN class THEN
        node.sizechanged:=TRUE;
        node.poschanged:=TRUE;
        node.locked:=FALSE;
        node.fastdraw:=FALSE;
        p1.boxes.AddTail(node);
        p4.PlotTextLine(p1.previewrast,node,TRUE);
        p1.CorrectBoxPagePics(node);
      ELSIF I.menuPick IN class THEN
        ret:=FALSE;
      END;
    END;
  END;
END CreateTextLine;

PROCEDURE DrawFastBorder*(rast:g.RastPortPtr;x,y,wi,he:INTEGER);

BEGIN
  g.SetAPen(rast,1);
  g.Move(rast,x,y);
  g.Draw(rast,x+wi,y);
  g.Draw(rast,x+wi,y+he);
  g.Draw(rast,x,y+he);
  g.Draw(rast,x,y);
  g.Draw(rast,x+wi,y+he);
  g.Move(rast,x+wi,y);
  g.Draw(rast,x,y+he);
END DrawFastBorder;

PROCEDURE InitWindows*;

BEGIN
  p1.toolId:=wm.InitWindow(MIN(INTEGER),0,100,100,s.ADR(""),LONGSET{I.windowDrag,I.windowDepth,I.windowClose},LONGSET{I.closeWindow,I.gadgetUp,I.menuPick},p1.previewscreen,FALSE);
  p1.mainId:=wm.InitWindow(MIN(INTEGER),0,100,100,ac.GetString(ac.LayoutWorkingWindowTitle),LONGSET{I.activate,I.noCareRefresh,I.windowDrag,I.windowDepth,I.windowSizing,I.windowClose,I.reportMouse,I.sizeBRight,I.sizeBBottom},LONGSET{I.gadgetDown,I.gadgetUp,I.closeWindow,I.menuPick,I.newSize,I.mouseButtons,I.mouseMove,I.rawKey,I.vanillaKey,I.activeWindow,I.inactiveWindow,I.intuiTicks},p1.previewscreen,TRUE);
  wm.SetMinMax(p1.mainId,100,100,-1,-1);
  p1.printId:=wm.InitWindow(MIN(INTEGER),0,100,100,ac.GetString(ac.PrintingPage),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},p1.previewscreen,FALSE);
END InitWindows;

PROCEDURE CreateTextBox*(textline:l.Node):l.Node;

VAR node,abs,
    char     : l.Node;
    i        : INTEGER;

BEGIN
  node:=NIL;
  NEW(node(p1.TextBlock));
  node(p1.TextBlock).absatz:=l.Create();
  WHILE textline#NIL DO
    WITH textline: s14.TextLine DO
      NEW(abs(p1.TextAbsatz));
      abs(p1.TextAbsatz).charlist:=l.Create();
      node(p1.TextBlock).absatz.AddTail(abs);
      char:=NIL;
      NEW(char(p1.TextDesigner));
      char(p1.TextDesigner).font:=p1.fonts.head;
      char(p1.TextDesigner).size:=p1.fonts.head(p1.Font).sizes.head;
      char(p1.TextDesigner).colf:=p1.colorconv[textline.color];
      char(p1.TextDesigner).style:=textline.style;
      abs(p1.TextAbsatz).charlist.AddTail(char);
      char:=NIL;
      i:=0;
      WHILE i<st.Length(textline.string^) DO
        NEW(char(p1.TextChar));
        char(p1.TextChar).char:=textline.string[i];
        abs(p1.TextAbsatz).charlist.AddTail(char);
        INC(i);
      END;
      NEW(char(p1.TextChar));
      char(p1.TextChar).char:=" ";
      abs(p1.TextAbsatz).charlist.AddTail(char);
    END;
    textline:=textline.next;
  END;
  NEW(abs(p1.TextAbsatz));
  abs(p1.TextAbsatz).charlist:=l.Create();
  node(p1.TextBlock).absatz.AddTail(abs);
  char:=NIL;
  NEW(char(p1.TextDesigner));
  char(p1.TextDesigner).font:=p1.fonts.head;
  char(p1.TextDesigner).size:=p1.fonts.head(p1.Font).sizes.head;
  char(p1.TextDesigner).colf:=p1.black;
  abs(p1.TextAbsatz).charlist.AddTail(char);
  char:=NIL;
  NEW(char(p1.TextChar));
  char(p1.TextChar).char:=" ";
  abs(p1.TextAbsatz).charlist.AddTail(char);
  RETURN node;
END CreateTextBox;

PROCEDURE GetChar*(text:l.Node;x,y:LONGREAL):l.Node;

VAR abs,char,actchar : l.Node;
    exit             : BOOLEAN;
    oldx,oldy        : LONGREAL;

PROCEDURE GetCharLoc(text:l.Node;x,y:LONGREAL):l.Node;

VAR abs,char,actchar,lastchar : l.Node;
    exit                      : BOOLEAN;

BEGIN
  exit:=FALSE;
  actchar:=NIL;
  lastchar:=NIL;
  abs:=text(p1.TextBlock).absatz.head;
  WHILE abs#NIL DO
    char:=abs(p1.TextAbsatz).charlist.head;
    WHILE char#NIL DO
      IF char IS p1.TextChar THEN
        IF (y>=char(p1.TextChar).y) AND (y<char(p1.TextChar).y+char(p1.TextChar).height+char(p1.TextChar).overtop+char(p1.TextChar).underbottom) THEN
          lastchar:=char;
          IF (x>=char(p1.TextChar).x) AND (x<char(p1.TextChar).x+char(p1.TextChar).width) THEN
            actchar:=char;
          END;
        END;
(*        IF (y>=char(p1.TextChar).y) AND (y<char(p1.TextChar).y+char(p1.TextChar).height) THEN
          lastchar:=char;
          IF (x>=char(p1.TextChar).x) AND (x<char(p1.TextChar).x+char(p1.TextChar).width) THEN
            actchar:=char;
            exit:=TRUE;
          END;
        ELSIF lastchar#NIL THEN
          actchar:=lastchar;
        END;*)
      END;
      char:=char.next;
      IF actchar#NIL THEN
        char:=NIL;
      END;
(*      IF exit THEN
        char:=NIL;
      END;*)
    END;
    abs:=abs.next;
    IF actchar#NIL THEN
      abs:=NIL;
    END;
(*    IF exit THEN
      abs:=NIL;
    END;*)
  END;
  IF actchar=NIL THEN
    IF lastchar=NIL THEN
      actchar:=text(p1.TextBlock).absatz.tail(p1.TextAbsatz).charlist.tail;
      p4.GetPrevTextChar(actchar);
    ELSE
      actchar:=lastchar;
    END;
  END;
  RETURN actchar;
END GetCharLoc;

BEGIN
  actchar:=GetCharLoc(text,x,y);
(*  oldx:=x;
  oldy:=y;
  IF y>text(p1.TextBlock).theight THEN
    y:=text(p1.TextBlock).theight;
  END;
  actchar:=NIL;
  REPEAT
    x:=oldx;
    REPEAT
      actchar:=GetCharLoc(text,x,y);
      x:=x-0.1;
    UNTIL (actchar#NIL) OR (x<text(p1.TextBlock).xpos);
    y:=y-0.1;
  UNTIL (actchar#NIL) OR (y<text(p1.TextBlock).ypos);*)
  RETURN actchar;
END GetChar;

PROCEDURE PlotCursor*(wind:I.WindowPtr;text,actchar:l.Node);

VAR picx,picy,width,height,
    oldoffx,oldoffy        : INTEGER;
    message                : BOOLEAN;

BEGIN
  IF (text#NIL) AND (actchar#NIL) THEN
    p1.PageToPagePicC(actchar(p1.TextChar).x,actchar(p1.TextChar).y+actchar(p1.TextChar).overtop,picx,picy);
    p1.PageToPagePic(actchar(p1.TextChar).width,actchar(p1.TextChar).height,width,height);
    oldoffx:=p1.offx;
    oldoffy:=p1.offy;
    IF picx>=wind.width-wind.borderRight THEN
      p1.offx:=p1.offx+picx-(wind.width-wind.borderRight)+1;
    END;
    IF picx<wind.borderLeft+p1.stdoffx THEN
      p1.offx:=p1.offx-(wind.borderLeft+p1.stdoffx-picx);
    END;
    IF picy+height>=wind.height-wind.borderBottom THEN
      p1.offy:=p1.offy+picy+height-(wind.height-wind.borderBottom)+1;
    END;
    IF picy<=wind.borderTop+p1.stdoffy THEN
      p1.offy:=p1.offy-(wind.borderTop+p1.stdoffy-picy)-1;
    END;
    p1.CheckOffset;
    IF (oldoffx#p1.offx) OR (oldoffy#p1.offy) THEN
      g.ScrollRaster(p1.previewwindow.rPort,p1.offx-oldoffx,p1.offy-oldoffy,4+p1.stdoffx,p1.top+p1.stdoffy,p1.previewwindow.width-19,p1.previewwindow.height-11);
      IF (p1.offx<oldoffx) OR (p1.offy<oldoffy) THEN
        message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,NIL,TRUE,TRUE);
      END;
      IF p1.ruler THEN
        p2.PlotRuler(FALSE);
      END;
      p1.RefreshScrollers;
      I.RefreshWindowFrame(p1.previewwindow);
      picx:=picx-(p1.offx-oldoffx);
      picy:=picy-(p1.offy-oldoffy);
(*      p1.PageToPagePicC(actchar(p1.TextChar).x,actchar(p1.TextChar).y,picx,picy);
      p1.PageToPagePic(actchar(p1.TextChar).width,actchar(p1.TextChar).height,width,height);*)
      p1.DrawTextEditBorder(text,FALSE);
    END;
    g.SetDrMd(wind.rPort,SHORTSET{g.complement});
    IF NOT(actchar IS p1.TextFunc) THEN
      g.Move(wind.rPort,picx,picy);
      g.Draw(wind.rPort,picx,picy+height-1);
    ELSE
      g.RectFill(wind.rPort,picx,picy,picx+width-1,picy+height-1);
    END;
    g.SetDrMd(wind.rPort,g.jam1);
  END;
END PlotCursor;

PROCEDURE SplitAbsatz(VAR abs1:l.Node;char:l.Node);

VAR node,abs2 : l.Node;

BEGIN
  NEW(abs2(p1.TextAbsatz));
  abs2(p1.TextAbsatz).charlist:=l.Create();
  abs2(p1.TextAbsatz).type:=0;
  WHILE char#NIL DO
    node:=char.next;
    char.Remove;
    abs2(p1.TextAbsatz).charlist.AddTail(char);
    char:=node;
  END;
  abs1.AddBehind(abs2);
END SplitAbsatz;

PROCEDURE ReadASCII*(file:d.FileHandlePtr;text,actchar:l.Node);

VAR i        : INTEGER;
    string   : ARRAY 2 OF CHAR;
    abs,node : l.Node;

BEGIN
  abs:=p4.GetAbsatz(text,actchar);
  LOOP
    i:=SHORT(d.Read(file,string,1));
    IF i=0 THEN
      EXIT;
    END;
    IF string[0]="\n" THEN
(*      node:=abs(p1.TextAbsatz).charlist.head;
      LOOP
        IF node=NIL THEN
          EXIT;
        END;
        IF node IS p1.TextChar THEN
          EXIT;
        END;
        node:=node.next;
      END;
      IF node#actchar THEN
        node:=actchar;
        GetPrevTextChar(node);
        IF node#NIL THEN
          IF node(p1.TextChar).char#" " THEN
            NEW(node(p1.TextChar));
            node(p1.TextChar).char:=" ";
            node(p1.TextChar).changed:=TRUE;
            actchar.AddBefore(node);
          END;
        END;
      ELSE
        NEW(node(p1.TextChar));
        node(p1.TextChar).char:=" ";
        node(p1.TextChar).changed:=TRUE;
        actchar.AddBefore(node);
      END;*)
      NEW(node(p1.TextChar));
      node(p1.TextChar).char:=" ";
      node(p1.TextChar).changed:=TRUE;
      actchar.AddBefore(node);
      SplitAbsatz(abs,actchar);
      abs:=abs.next;
    ELSE
      NEW(node(p1.TextChar));
      node(p1.TextChar).char:=string[0];
      node(p1.TextChar).changed:=TRUE;
      actchar.AddBefore(node);
    END;
  END;
END ReadASCII;

PROCEDURE ImportASCII*(text,actchar:l.Node):BOOLEAN;

VAR string : ARRAY 256 OF CHAR;
    file   : d.FileHandlePtr;
    bool   : BOOLEAN;

BEGIN
  bool:=fr.FileReqWin(ac.GetString(ac.SelectASCIIFile)^,string,p1.previewwindow);
  IF bool THEN
    file:=NIL;
    file:=d.Open(string,d.oldFile);
    IF file#NIL THEN
      ReadASCII(file,text,actchar);
      bool:=d.Close(file);
    ELSE
      bool:=rt.RequestWin(ac.GetString(ac.CouldntOpenFile1),ac.GetString(ac.CouldntOpenFile2),s.ADR(""),ac.GetString(ac.OK),p1.previewwindow);
    END;
  END;
  RETURN bool;
END ImportASCII;

PROCEDURE EditTextBlock*(wind:I.WindowPtr;text:l.Node;VAR actchar:l.Node);

VAR node,node2,abs,char,
    font,size,markstart,
    markend             : l.Node;
    x,y,width,height,
    x2,y2               : LONGREAL;
    message,pressed,bool,
    bordershown         : BOOLEAN;
    mx,my,ticks         : INTEGER;
    strip,item,sub      : LONGINT;
    picx1,picy1,picx2,
    picy2               : INTEGER;
    first               : BOOLEAN;

PROCEDURE GetPrevChar(text,char:l.Node):l.Node;

VAR node,abs : l.Node;

BEGIN
  node:=char;
  REPEAT
    node:=node.prev;
  UNTIL (node=NIL) OR (node IS p1.TextChar);
  IF node=NIL THEN
    abs:=p4.GetAbsatz(text,char);
    abs:=abs.prev;
    IF abs#NIL THEN
      node:=abs(p1.TextAbsatz).charlist.tail;
      p4.GetPrevTextChar(node);
(*      REPEAT
        node:=node.prev;
      UNTIL (node=NIL) OR (node IS p1.TextChar);*)
    END;
  END;
  IF node=NIL THEN
    node:=char;
  END;
  RETURN node;
END GetPrevChar;

PROCEDURE GetNextChar(text,char:l.Node):l.Node;

VAR node,abs : l.Node;

BEGIN
  node:=char;
  REPEAT
    node:=node.next;
  UNTIL (node=NIL) OR (node IS p1.TextChar);
  IF node=NIL THEN
    abs:=p4.GetAbsatz(text,char);
    abs:=abs.next;
    IF abs#NIL THEN
      node:=abs(p1.TextAbsatz).charlist.head;
      p4.GetNextTextChar(node);
(*      REPEAT
        node:=node.next;
      UNTIL (node=NIL) OR (node IS p1.TextChar);*)
    END;
  END;
  IF node=NIL THEN
    node:=char;
  END;
  RETURN node;
END GetNextChar;

PROCEDURE CursorRight;

BEGIN
  actchar:=GetNextChar(text,actchar);
(*  node:=actchar;
  REPEAT
    node2:=node;
    node:=node.next;
  UNTIL (node IS p1.TextChar) OR (node=NIL);
  IF node=NIL THEN
    abs:=text(p1.TextBlock).absatz.head;
    WHILE (abs#NIL) AND (node=NIL) DO
      IF abs(p1.TextAbsatz).charlist.tail=node2 THEN
        IF abs.next#NIL THEN
          node:=abs.next(p1.TextAbsatz).charlist.head;
          REPEAT
            node2:=node;
            node:=node.next;
          UNTIL (node IS p1.TextChar) OR (node=NIL);
        END;
      END;
      abs:=abs.next;
    END;
  END;
  IF node#NIL THEN
    actchar:=node;
  END;*)
END CursorRight;

PROCEDURE CursorLeft;

BEGIN
  actchar:=GetPrevChar(text,actchar);
(*  node:=actchar;
  REPEAT
    node2:=node;
    node:=node.prev;
  UNTIL (node IS p1.TextChar) OR (node=NIL);
  IF node=NIL THEN
    abs:=text(p1.TextBlock).absatz.tail;
    WHILE (abs#NIL) AND (node=NIL) DO
      IF abs(p1.TextAbsatz).charlist.head=node2 THEN
        IF abs.next#NIL THEN
          node:=abs.next(p1.TextAbsatz).charlist.tail;
          REPEAT
            node2:=node;
            node:=node.prev;
          UNTIL (node IS p1.TextChar) OR (node=NIL);
        END;
      END;
      abs:=abs.prev;
    END;
  END;
  IF node#NIL THEN
    actchar:=node;
  END;*)
END CursorLeft;

PROCEDURE CursorUp;

BEGIN
  x:=actchar(p1.TextChar).x;
  y:=actchar(p1.TextChar).y;
  width:=actchar(p1.TextChar).width;
  height:=actchar(p1.TextChar).height+actchar(p1.TextChar).overtop+actchar(p1.TextChar).underbottom;
  y:=y-0.01;
  IF y>=text(p1.TextBlock).ypos THEN
    node2:=actchar.prev;
    node:=NIL;
    REPEAT
      node:=GetChar(text,x,y);
      IF node2#NIL THEN
        IF node2 IS p1.TextChar THEN
          x:=x-node2(p1.TextChar).width;
        END;
      ELSE
        x:=x-0.01;
      END;
      IF node2#NIL THEN
        node2:=node2.prev;
      END;
    UNTIL (node#NIL) OR (x<text(p1.TextBlock).xpos);
    IF node#NIL THEN
      actchar:=node;
    END;
  END;
END CursorUp;

PROCEDURE CursorDown;

BEGIN
  x:=actchar(p1.TextChar).x;
  y:=actchar(p1.TextChar).y;
  width:=actchar(p1.TextChar).width;
  height:=actchar(p1.TextChar).height+actchar(p1.TextChar).overtop+actchar(p1.TextChar).underbottom;
  y:=y+height+0.01;
  IF y<=text(p1.TextBlock).ypos+text(p1.TextBlock).height THEN
    node2:=actchar.prev;
    node:=NIL;
    REPEAT
      node:=GetChar(text,x,y);
      IF node2#NIL THEN
        IF node2 IS p1.TextChar THEN
          x:=x-node2(p1.TextChar).width;
        END;
      ELSE
        x:=x-0.01;
      END;
      IF node2#NIL THEN
        node2:=node2.prev;
      END;
    UNTIL (node#NIL) OR (x<text(p1.TextBlock).xpos);
    IF node#NIL THEN
      actchar:=node;
    END;
  END;
END CursorDown;

PROCEDURE InsertChar(VAR actchar:l.Node;node:l.Node);

VAR node2 : l.Node;

BEGIN
  actchar.AddBefore(node);
(*  RefreshCharWidth(text,node);*)
  node2:=node;
  p4.GetPrevTextChar(node2);
  IF node2#NIL THEN
    node:=node2;
  END;
  PlotCursor(p1.previewwindow,text,actchar);
(*  IF bordershown THEN
    p1.DrawSimpleBorder(text,TRUE);
    bordershown:=FALSE;
  END;*)
  message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,node,TRUE,TRUE);
  IF NOT(message) THEN
    p1.DrawTextEditBorder(text,FALSE);
(*    p1.DrawSimpleBorder(text,TRUE);
    bordershown:=TRUE;*)
  END;
  PlotCursor(p1.previewwindow,text,actchar);
END InsertChar;

PROCEDURE LinkAbsatz(VAR abs1,abs2:l.Node);

VAR node,node2 : l.Node;

BEGIN
  node:=abs2(p1.TextAbsatz).charlist.head;
  WHILE node#NIL DO
    node2:=node.next;
    node.Remove;
    abs1(p1.TextAbsatz).charlist.AddTail(node);
    node:=node2;
  END;
  abs2.Remove;
END LinkAbsatz;

PROCEDURE DeleteChar(VAR actchar:l.Node);

VAR node,abs1,abs2 : l.Node;

BEGIN
(*  node:=GetNextChar(text,actchar);*)
  node:=actchar.next;
  p4.GetNextTextChar(node);
  IF node#NIL THEN
    actchar.Remove;
    actchar:=node;
    actchar(p1.TextChar).changed:=TRUE;
    node:=actchar.prev;
    p4.GetPrevTextChar(node);
    IF node=NIL THEN
      node:=actchar;
    END;
    message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,node,TRUE,TRUE);
  ELSE
    abs1:=p4.GetAbsatz(text,actchar);
    abs2:=abs1.next;
    IF abs2#NIL THEN
      LinkAbsatz(abs1,abs2);
      node:=actchar;
(*      actchar:=abs2(p1.TextAbsatz).charlist.head;*)
      actchar:=GetNextChar(text,actchar);
      node.Remove;
      message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,NIL,TRUE,TRUE);
    END;
  END;
(*  IF bordershown THEN
    p1.DrawSimpleBorder(text,TRUE);
    bordershown:=FALSE;
  END;*)
  IF NOT(message) THEN
    p1.DrawTextEditBorder(text,FALSE);
(*    p1.DrawSimpleBorder(text,TRUE);
    bordershown:=TRUE;*)
  END;
END DeleteChar;

PROCEDURE CopyDesigner(VAR des1,des2:l.Node);

BEGIN
  WITH des1: p1.TextDesigner DO
    WITH des2: p1.TextDesigner DO
      des2.style:=des1.style;
      des2.colf:=des1.colf;
      des2.colb:=des1.colb;
      des2.font:=des1.font;
      des2.size:=des1.size;
    END;
  END;
END CopyDesigner;

PROCEDURE PlotMark;

VAR height,height2 : LONGREAL;

BEGIN
  WITH text: p1.TextBlock DO
    IF (text.markstart#NIL) AND (text.markend#NIL) THEN
      g.SetDrMd(p1.previewwindow.rPort,SHORTSET{g.complement});
      x:=text.markstart(p1.TextChar).x;
      y:=text.markstart(p1.TextChar).y;
      x2:=text.markend(p1.TextChar).x;
      y2:=text.markend(p1.TextChar).y;
      height:=text.markstart(p1.TextChar).height+text.markstart(p1.TextChar).overtop+text.markstart(p1.TextChar).underbottom;
      height2:=text.markend(p1.TextChar).height+text.markend(p1.TextChar).overtop+text.markend(p1.TextChar).underbottom;
  (*    p1.PageToPagePicC(text.xpos,y,picx1,picy1);
      p1.PageToPagePicC(text.xpos+text.width,y2+height,picx2,picy2);
      p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2);
      p1.PageToPagePicC(text.xpos,y,picx1,picy1);
      p1.PageToPagePicC(x,y+height,picx2,picy2);
      p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2);
      p1.PageToPagePicC(x2,y2,picx1,picy1);
      p1.PageToPagePicC(text.xpos+text.width,y2+height,picx2,picy2);
      p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2);*)
      p1.PageToPagePicC(x,y+height,picx1,picy1);
      p1.PageToPagePicC(x2,y2,picx2,picy2);
      IF y=y2 THEN
        p1.PageToPagePicC(x,y,picx1,picy1);
        p1.PageToPagePicC(x2+text.markend(p1.TextChar).width,y2+height2,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
      ELSIF picy1=picy2 THEN
        p1.PageToPagePicC(x,y,picx1,picy1);
        p1.PageToPagePicC(text.xpos+text.width,y+height,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
        p1.PageToPagePicC(text.xpos,y2,picx1,picy1);
        p1.PageToPagePicC(x2+text.markend(p1.TextChar).width,y2+height2,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
      ELSE
        p1.PageToPagePicC(x,y,picx1,picy1);
        p1.PageToPagePicC(text.xpos+text.width,y+height,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
        p1.PageToPagePicC(text.xpos,y2,picx1,picy1);
        p1.PageToPagePicC(x2+text.markend(p1.TextChar).width,y2+height2,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
        p1.PageToPagePicC(text.xpos,y+height,picx1,picy1);
        p1.PageToPagePicC(text.xpos+text.width,y2,picx2,picy2);
        p1.RectFill(p1.previewwindow.rPort,picx1,picy1,picx2,picy2-1);
      END;
      g.SetDrMd(p1.previewwindow.rPort,g.jam1);
    END;
  END;
END PlotMark;

PROCEDURE RefreshMenu(des,abs:l.Node);

VAR i : INTEGER;

BEGIN
  IF des#NIL THEN
    WITH des: p1.TextDesigner DO
      IF g.bold IN des.style THEN
        INCL(p1.bold.flags,I.checked);
      ELSE
        EXCL(p1.bold.flags,I.checked);
      END;
      IF g.italic IN des.style THEN
        INCL(p1.italic.flags,I.checked);
      ELSE
        EXCL(p1.italic.flags,I.checked);
      END;
      IF g.underlined IN des.style THEN
        INCL(p1.underline.flags,I.checked);
      ELSE
        EXCL(p1.underline.flags,I.checked);
      END;
    END;
  END;
  IF abs#NIL THEN
    WITH abs: p1.TextAbsatz DO
      IF abs.type=0 THEN
        INCL(p1.left.flags,I.checked);
      ELSE
        EXCL(p1.left.flags,I.checked);
      END;
      IF abs.type=1 THEN
        INCL(p1.right.flags,I.checked);
      ELSE
        EXCL(p1.right.flags,I.checked);
      END;
      IF abs.type=2 THEN
        INCL(p1.center.flags,I.checked);
      ELSE
        EXCL(p1.center.flags,I.checked);
      END;
      IF abs.type=3 THEN
        INCL(p1.block.flags,I.checked);
      ELSE
        EXCL(p1.block.flags,I.checked);
      END;
    END;
  END;
END RefreshMenu;

PROCEDURE SetToDes(start,end,des:l.Node;type:INTEGER);

VAR node : l.Node;

BEGIN
  IF type#3 THEN
    WITH des: p1.TextDesigner DO
      node:=start;
      WHILE node#end.next DO
        IF node IS p1.TextDesigner THEN
          IF type=0 THEN
            node(p1.TextDesigner).style:=des.style;
          ELSIF type=1 THEN
            node(p1.TextDesigner).font:=des.font;
            node(p1.TextDesigner).size:=des.size;
          ELSIF type=4 THEN
            node(p1.TextDesigner).colf:=des.colf;
          END;
        END;
        node:=node.next;
      END;
    END;
  ELSE
    WITH des: p1.TextAbsatz DO
      start:=p4.GetAbsatz(text,start);
      end:=p4.GetAbsatz(text,end);
      WHILE start#end.next DO
        start(p1.TextAbsatz).type:=des.type;
        start:=start.next;
      END;
    END;
  END;
END SetToDes;

PROCEDURE CompareDesigner(des1,des2:l.Node):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=TRUE;
  WITH des1: p1.TextDesigner DO
    WITH des2: p1.TextDesigner DO
      IF des1.style#des2.style THEN
        ret:=FALSE;
      ELSIF des1.font#des2.font THEN
        ret:=FALSE;
      ELSIF des1.size#des2.size THEN
        ret:=FALSE;
      END;
    END;
  END;
  RETURN ret;
END CompareDesigner;

PROCEDURE OptimizeDes(text:l.Node);

VAR abs,char,lastdes : l.Node;

BEGIN
  WITH text: p1.TextBlock DO
    lastdes:=NIL;
    abs:=text.absatz.head;
    WHILE abs#NIL DO
      char:=abs(p1.TextAbsatz).charlist.head;
      WHILE char#NIL DO
        IF char IS p1.TextDesigner THEN
          IF lastdes#NIL THEN
            IF CompareDesigner(char,lastdes) THEN
              char.Remove;
            END;
          END;
        END;
        char:=char.next;
      END;
      abs:=abs.next;
    END;
  END;
END OptimizeDes;

PROCEDURE SetChanged(start,end:l.Node);

VAR abs : l.Node;

BEGIN
  abs:=p4.GetAbsatz(text,start);
  WHILE start#end DO
    IF start IS p1.TextChar THEN
      start(p1.TextChar).changed:=TRUE;
    END;
    start:=start.next;
    IF start=NIL THEN
      abs:=abs.next;
      start:=abs(p1.TextAbsatz).charlist.head;
    END;
  END;
END SetChanged;

BEGIN
  WITH text: p1.TextBlock DO
    ticks:=0;
    pressed:=FALSE;
    first:=FALSE;
    g.SetAPen(wind.rPort,1);
    p1.DrawTextEditBorder(text,FALSE);
(*    bordershown:=TRUE;
    p1.DrawSimpleBorder(text,TRUE);*)
    PlotCursor(p1.previewwindow,text,actchar);
    message:=TRUE;
    LOOP
      IF NOT(message) THEN
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,p4.class,p4.code,p4.address);
      END;
      message:=FALSE;
      IF I.rawKey IN p4.class THEN
        PlotMark;
        text.markstart:=NIL;
        text.markend:=NIL;
        IF p4.code=I.cursorRight THEN
          PlotCursor(p1.previewwindow,text,actchar);
          CursorRight;
          PlotCursor(p1.previewwindow,text,actchar);
        ELSIF p4.code=I.cursorLeft THEN
          PlotCursor(p1.previewwindow,text,actchar);
          CursorLeft;
          PlotCursor(p1.previewwindow,text,actchar);
        ELSIF p4.code=I.cursorUp THEN
          PlotCursor(p1.previewwindow,text,actchar);
          CursorUp;
          PlotCursor(p1.previewwindow,text,actchar);
        ELSIF p4.code=I.cursorDown THEN
          PlotCursor(p1.previewwindow,text,actchar);
          CursorDown;
          PlotCursor(p1.previewwindow,text,actchar);
        END;
      ELSIF I.vanillaKey IN p4.class THEN
        PlotMark;
        text.markstart:=NIL;
        text.markend:=NIL;
        IF p4.code=8 THEN
          PlotCursor(p1.previewwindow,text,actchar);
          node:=actchar;
          actchar:=GetPrevChar(text,actchar);
          IF node#actchar THEN
            DeleteChar(actchar);
          ELSE
            message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,NIL,TRUE,TRUE);
            IF NOT(message) THEN
              p1.DrawTextEditBorder(text,FALSE);
            END;
          END;
          PlotCursor(p1.previewwindow,text,actchar);
        ELSIF p4.code=127 THEN
          PlotCursor(p1.prevqewwindow,text,actchar);
          DeleteChar(actchar);
          PlotCursor(p1.previewwindow,text,actchar);
        ELSIF p4.code=13 RÈEN
          PltCursor(p1.previewwindow,text,actc(ar);
          abs:=p4.GetAbsatz(text,actchar);
          IF abs#NIL THEN
   88       nodeZ=abs(p1.TextAbsatz)*charlist.tail<
            p4.GetPrevTextChar(node);
            node(p1.TextChar).changed:=TRUE;
            no$e:=abs(p1.TextAdsatz).chyWÑëW3‚Óíïi`×“‚Ÿ-óší       g.SetAPen(rast,2);
        g.SetBPen(rast,1);
      END;
      IF char=startchar THEN
        realactive:=TRUE;
      END;
      IF char IS p1.TextChar THEN
        IF char(p1.TextChar).char#" " THEN
          EXIT;
        END;
        IF active THEN
          char(p1.TextChar).x:=x;
          char(p1.TextChar).y:=y;
          char(p1.TextChar).height:=cent;
          char(p1.TextChar).overtop:=overtop;
          char(p1.TextChar).underbottom:=underbottom;
          char(p1.TextChar).changed:=FALSE;
        END;
      ELSIF char IS p1.TextDesigner THEN
        SetNewDesign(char);
      END;
      IF char=text(p1.TextBlock).markend THEN
        mark:=FALSE;
        g.SetAPen(rast,1);
        g.SetBPen(rast,2);
      END;
      char:=char.next;
    END;
  END;
END JumpSpaces;

PROCEDURE QuickJumpToLine(VAR start,end:l.Node);

VAR linestart,lineend,
    lastchar,actline,
    lastdes,lastline : l.Node;
    lasty            : LONGREAL;

BEGIN
  lastchar:=start;
  lastdes:=NIL;
  actline:=start;
  lastline:=actline;
  lasty:=y;
  LOOP
    IF start=NIL THEN
      EXIT;
    END;
    IF start IS p1.TextChar THEN
      IF (start(p1.TextChar).y>y) AND NOT(start(p1.TextChar).changed) AND NOT(start=startchar) THEN
        actline:=start;
        y:=start(p1.TextChar).y;
      ELSIF (start(p1.TextChar).changed) OR (char=startchar) THEN
        EXIT;
      END;
      IF (start(p1.TextChar).char=" ") AND (NOT(start(p1.TextChar).changed) AND NOT(start=startchar)) THEN
        lastline:=actline;
        lasty:=y;
      END;
    ELSIF start IS p1.TextDesigner THEN
      lastdes:=start;
    END;
    start:=start.next;
  END;
  start:=lastline;
  y:=lasty;
  active:=TRUE;
  GetNextLine(start,end);
END QuickJumpToLine;

BEGIN
  WITH text: p1.TextBlock DO
    exit:=FALSE;
    IF (edit) AND (wind#NIL) AND NOT((startchar=NIL) AND (refrwidths)) AND NOT(exit) THEN
      it.GetIMes(wind,class,code,address);
      IF (class#LONGSET{}) AND NOT(I.intuiTicks IN class) AND NOT(I.mouseMove IN class) AND NOT(I.rawKey IN class) THEN
        exit:=TRUE;
        char:=NIL;
      END;
    END;
    IF NOT(exit) THEN
      x:=text.xpos;
      y:=text.ypos;
      width:=text.width;
      height:=text.height;
      xmax:=x+width;
      ymax:=y+height;
      maxheight:=0;
      actheight:=0;
      IF edit THEN
        class:=LONGSET{};
      END;
      mark:=FALSE;
      IF startchar=NIL THEN
        active:=TRUE;
      ELSE
        active:=FALSE;
      END;
      realactive:=active;
      g.SetAPen(rast,1);
      g.SetDrMd(rast,g.jam1);
      IF startchar=NIL THEN
        abs:=text.absatz.head;
      ELSE
        abs:=GetChangedAbsatz(text,startchar);
        node:=abs(p1.TextAbsatz).charlist.head;
        node:=GetDesigner(text,node);
        SetNewDesign(node);
        node:=abs(p1.TextAbsatz).charlist.head;
        GetNextTextChar(node);
(*        IF NOT(node(p1.TextChar).changed) THEN*)
          y:=node(p1.TextChar).y;
(*        END;*)
      END;
      WHILE abs#NIL DO
        char:=abs(p1.TextAbsatz).charlist.head;
        WHILE char#NIL DO
          x:=text.xpos;
          start:=char;
  (*        IF NOT(active) AND (start IS p1.TextChar) THEN
            y:=start(p1.TextChar).y;
          END;*)
  (*        active:=TRUE;*)
          cent:=actcent;
          overtop:=0;
          underbottom:=0;
  (*        maxheight:=actheight;*)
(*          REPEAT*)
          IF NOT(edit) OR (active) THEN
            GetNextLine(start,end);
          ELSE
            QuickJumpToLine(start,end);
          END;
(*            IF (edit) AND NOT(start(p1.TextChar).changed) THEN
              y:=start(p1.TextChar).y;
            END;
            IF (edit) AND NOT(active) THEN
              start:=end.next;
              JumpSpaces(start,x,0,0);
            END;
          UNTIL NOT(edit) OR (active);*)
  (*        cent:=p1.PointToCent(maxheight);*)
          IF (edit) AND (active) THEN
            p1.PageToPagePicC(x,y,xpos,ypos);
            p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+overtop,x2,y2);
            IF x2>=wind.width-wind.borderLeft THEN
              x2:=wind.width-wind.borderLeft-1;
            END;
            IF y2>=wind.height-wind.borderBottom THEN
              y2:=wind.height-wind.borderBottom-1;
            END;
            g.SetAPen(rast,2);
            IF (xpos<x2) AND (ypos<y2) THEN
              g.RectFill(rast,xpos,ypos,x2-1,y2-1);
            END;
            p1.PageToPagePicC(x,y+overtop+cent,xpos,ypos);
            p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+overtop+cent+underbottom,x2,y2);
            IF x2>=wind.width-wind.borderLeft THEN
              x2:=wind.width-wind.borderLeft-1;
            END;
            IF y2>=wind.height-wind.borderBottom THEN
              y2:=wind.height-wind.borderBottom-1;
            END;
            g.SetAPen(rast,2);
            IF (xpos<x2) AND (ypos<y2) THEN
              g.RectFill(rast,xpos,ypos,x2-1,y2-1);
            END;
            g.SetAPen(rast,1);
          END;
          y:=y+overtop;
  (*        IF active THEN*)
    (*        RefreshWidths(start,end);*)
            MakeType(start,end,abs(p1.TextAbsatz).type);
            char:=end;
  (*          IF NOT(edit) OR (active) THEN*)
              PrintText(start,end,x,y,maxheight,abs(p1.TextAbsatz).type);
  (*          ELSE
            END;*)
            IF NOT(active) THEN
              node:=start;
              GetNextTextChar(node);
              IF node#NIL THEN
                cent:=node(p1.TextChar).height;
              END;
            END;
            y:=y+cent+underbottom;
            IF active THEN
              WHILE (start#end.next) AND (start#NIL) DO
                IF start IS p1.TextChar THEN
                  start(p1.TextChar).height:=cent;
                  start(p1.TextChar).overtop:=overtop;
                  start(p1.TextChar).underbottom:=underbottom;
                END;
                start:=start.next;
              END;
            END;
            char:=char.next;
  (*        ELSE
            cent:=start(p1.TextChar).height;
            y:=y+cent;
            char:=end.next;AT
    8             it.GetIMes(wind,p4.class,p4.code,p4.address);
                UNRÉL p4.class=LONGSET{};
                message:=p4.PlotTextBlock(p1.previewwindow,p1.previewrast,text,NOL,TRUE,TRUE);
      D         IF NOT(mes3age) THEN
                  p1.DrawTextEditBorder(text,FALSE);
(*                  p1.DrawSimpleBordeshtext,TRUE);
                  bordershown:=ÐSÕ;*)
                END;
                PlotCursor(p1.previewwindow,text,actchar);
    8           PlotMasë;
              END;
 Pxit THEN
            char:=NIL;
          END;
        END;
        abs:=abs.next;
        IF (y>=ymax) OR (exit) THEN
          abs:=NIL;
        END;
      END;
      IF (edit) AND NOT(y>=ymax) AND NOT(exit) THEN
        p1.PageToPagePicC(text.xpos,y,xpos,ypos);
        p1.PageToPagePicC(text.xpos+text.width,text.ypos+text.height,x2,y2);
        IF x2>=wind.width-wind.borderLeft THEN
          x2:=wind.width-wind.borderLeft-1;
        END;
        IF y2>=wind.height-wind.borderBottom THEN
          y2:=wind.height-wind.borderBottom-1;
        END;
        g.SetAPen(rast,2);
        IF (xpos<=x2) AND (ypos<=y2) THEN
          g.RectFill(rast,xpos,ypos,x2,y2);
        END;
        g.SetAPen(rast,1);
      END;
      text.theight:=y;
    END;
  END;
  RETURN exit;
END PlotTextBlock;

BEGIN
END Preview4.

efreshColor(rast,26,71,196,14,p1.colorconv[actcol]);
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
        own IN p4.class) OR (I.closeWindow IN p4*clasqi&THEN
        EXIT;
      END;
    END;
    PlotMark;
    text.markstart:=NL<
    text.markEnd:=NIL;
    PlotCursor(p1.previewwindow,text,actchar);
(*    IF bordershown THEN
      p1.rawSqmpleBorder(text,TRUE);      bordershown:=FALUE;
    END[*)
  END;
END EditTextBlock;

BEG©N
  listId:=-1;
END Pretiew5.


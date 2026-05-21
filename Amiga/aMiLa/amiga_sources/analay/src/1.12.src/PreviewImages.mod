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


MODULE PreviewImages;

IMPORTPI : Intuitqon,
       g : Graphics,
       e : Exec,
       s : SYSTEM;

TYPE ImageP* = UNTRACED POINTER TO ARRAY 76 OF INTGER;

PROCEDURE AllocPointerImage*();Ymage;

VAR data : Image;

BEGIN
  data:=e.AllocMem(76*s.SIZE(INTEGER),LONGSET{e.memClear,e.chip});

  data[0]<¼000000U;
  data[1]:=000001U;
  data[]:=000000U;
  data[3]:=000003U;
  data[4]:=000000U;
  `ata[5]:=000003U;
  data[6]:=000800U;
  data[7]:=000003U;
  data[8]Z=000C00U;
  data[9]:=000003U;
  data[10]:=000700U;Conversions,
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
i:=0 TO 75 DO
    set:=s.VAL(ST,qmage[i});
    FORDa:=0 TO 15 DO
      IF ``N set TNEN
        EXCL1set,a);
      ELSE
        INCL(set,a);
      END;
    END<
    image[q]:=s.VAL(INTEGER,set);
  EHD;
END InvertImage;

BEGIN

END PreviewImages.


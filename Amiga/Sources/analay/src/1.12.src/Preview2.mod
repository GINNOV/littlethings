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


MODULE Preview2;

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
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
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
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j       : INTEGER;
    class       : LONGSET;
    code        : INTEGER;
    address     : s.ADDRESS;
    font        : g.TextFontPtr;
    actfont     : l.Node;
    selectfontId*,
    convertId * : INTEGER;

PROCEDURE GetFontPixelSize*(punkt:LONGREAL):INTEGER;

VAR x,y          : LONGREAL;
    width,height : INTEGER;

BEGIN
  y:=p1.PointToCent(punkt);
  p1.PageToPagePic(x,y,width,height);
  RETURN height;
END GetFontPixelSize;

PROCEDURE InsertPath*(VAR font:ARRAY OF CHAR;path:ARRAY OF CHAR);

VAR bool : BOOLEAN;
    len  : INTEGER;

BEGIN
  len:=SHORT(st.Length(path));
  IF (path[len-1]#":") AND (path[len-1]#"/") THEN
    bool:=FALSE;
    FOR i:=0 TO len-1 DO
      IF path[i]=":" THEN
        bool:=TRUE;
      END;
    END;
    IF bool THEN
      st.AppendChar(path,"/");
    ELSE
      st.AppendChar(path,":");
    END;
  END;
  IF st.Occurs(font,".font")#len-5 THEN
    st.Append(font,".font");
  END;
  st.Insert(font,0,path);
END InsertPath;

PROCEDURE SetFont*(rast:g.RastPortPtr;name,size:l.Node);

VAR pixelsize : INTEGER;
    attr      : g.TextAttr;
    inc       : INTEGER;
    text      : POINTER TO ARRAY OF ARRAY OF CHAR;
    bool      : BOOLEAN;
    file      : d.FileHandlePtr;

BEGIN
  IF font#NIL THEN
    g.CloseFont(font);
    font:=NIL;
  END;
  IF (name#NIL) AND (size#NIL) AND NOT(name(p1.Font).notfound) AND NOT(size(p1.FontSize).notfound) THEN
    name(p1.Font).used:=TRUE;
    size(p1.FontSize).used:=TRUE;
    attr.name:=e.AllocMem(80,LONGSET{e.memClear});
    COPY(name(p1.Font).name,attr.name^);
    pixelsize:=GetFontPixelSize(size(p1.FontSize).size);
  (*  IF p1.globals.halfheight THEN
      st.Append(attr.name^,"HalfHeight");
    END;*)
    InsertPath(attr.name^,name(p1.Font).path(p1.Path).path);
  (*  st.Append(attr.name^,".font");*)
    attr.ySize:=pixelsize;
    font:=NIL;
    IF s1.os<36 THEN
      file:=NIL;
      file:=d.Open(attr.name^,d.oldFile);
      IF file#NIL THEN
        bool:=d.Close(file);
        inc:=-1;
        LOOP
          font:=df.OpenDiskFont(attr);
          IF font#NIL THEN
            EXIT;
          END;
          INC(attr.ySize,inc);
          IF attr.ySize=0 THEN
            attr.ySize:=pixelsize+1;
            inc:=1;
          ELSIF (attr.ySize>1000) AND (inc=1) THEN
            EXIT;
          END;
        END;
      END;
    ELSE
      font:=df.OpenDiskFont(attr);
    END;
    IF font#NIL THEN
      g.SetFont(rast,font);
    ELSE
      name(p1.Font).notfound:=TRUE;
      NEW(text,3,50);
      COPY(ac.GetString(ac.CouldntLoadFont1)^,text[0]);
      COPY(attr.name^,text[1]);
      COPY(ac.GetString(ac.CouldntLoadFont2)^,text[2]);
      bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,p1.previewwindow);
    END;
    e.FreeMem(attr.name,80);
  END;
(*  io.WriteString(attr.name^);
  io.WriteString(": ");
  io.WriteInt(pixelsize,4);
  io.WriteLn;*)
END SetFont;

PROCEDURE SetFontRast*(rast:g.RastPortPtr;name,size:l.Node);

VAR pixelsize : INTEGER;
    attr      : g.TextAttr;
    text      : POINTER TO ARRAY OF ARRAY OF CHAR;
    bool      : BOOLEAN;

BEGIN
  IF font#NIL THEN
    g.CloseFont(font);
    font:=NIL;
  END;
  IF (name#NIL) AND (size#NIL) AND NOT(name(p1.Font).notfound) AND NOT(size(p1.FontSize).notfound) THEN
    name(p1.Font).used:=TRUE;
    size(p1.FontSize).used:=TRUE;
    attr.name:=e.AllocMem(80,LONGSET{e.memClear});
    COPY(name(p1.Font).name,attr.name^);
    pixelsize:=SHORT(SHORT(SHORT(size(p1.FontSize).size)));
  (*  IF p1.globals.halfheight THEN
      st.Append(attr.name^,"HalfHeight");
    END;*)
    InsertPath(attr.name^,name(p1.Font).path(p1.Path).path);
  (*  st.Append(attr.name^,".font");*)
    attr.ySize:=pixelsize;
    font:=df.OpenDiskFont(attr);
    IF font#NIL THEN
      g.SetFont(rast,font);
    ELSE
      name(p1.Font).notfound:=TRUE;
      NEW(text,3,50);
      COPY(ac.GetString(ac.CouldntLoadFont1)^,text[0]);
      COPY(attr.name^,text[1]);
      COPY(ac.GetString(ac.CouldntLoadFont2)^,text[2]);
      bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,p1.previewwindow);
    END;
    e.FreeMem(attr.name,80);
  END;
END SetFontRast;

PROCEDURE PrintScaledChar*(rast:g.RastPortPtr;char:CHAR;xpos,ypos:INTEGER;factx,facty:LONGREAL);

VAR buffer,
    maskrast: g.RastPortPtr;
    wi,he,
    width,
    height,
    x,y,
    x2,y2,
    plane  : INTEGER;
    string : ARRAY 2 OF CHAR;
    bool   : BOOLEAN;
    mask   : SHORTSET;

BEGIN
  string[0]:=char;
  string[1]:=0X;
  wi:=g.TextLength(rast,string,1);
  he:=rast.txHeight;
  IF wi<1 THEN
    wi:=1;
  END;
  IF he<1 THEN
    he:=1;
  END;
  buffer:=it.AllocRastPort(wi,he,p1.previewscreen.rastPort.bitMap.depth);
  maskrast:=it.AllocRastPort(wi,he,1);
  g.SetDrMd(buffer,g.jam1);
  g.SetFont(buffer,rast.font);
  mask:=g.AskSoftStyle(buffer);
  mask:=g.SetSoftStyle(buffer,rast.algoStyle,mask);
  g.SetAPen(buffer,rast.bgPen);
  g.SetBPen(buffer,rast.bgPen);
  g.RectFill(buffer,0,0,wi-1,he-1);
  g.SetAPen(buffer,rast.fgPen);
  tt.Print(0,rast.txBaseline,s.ADR(string),buffer);
  g.SetDrMd(maskrast,g.jam1);
  g.SetFont(maskrast,rast.font);
  mask:=g.AskSoftStyle(maskrast);
  mask:=g.SetSoftStyle(maskrast,rast.algoStyle,mask);
  g.SetAPen(maskrast,0);
  g.RectFill(maskrast,0,0,wi-1,he-1);
  g.SetAPen(maskrast,1);
  tt.Print(0,rast.txBaseline,s.ADR(string),maskrast);
  width:=SHORT(SHORT(SHORT(wi*factx+0.5)));
  height:=SHORT(SHORT(SHORT(he*facty+0.5)));
(*  plane:=0;
  LOOP
    IF plane IN s.VAL(SHORTSET,rast.fgPen) THEN
      EXIT;
    END;
    IF plane>p1.previewscreen.rastPort.bitMap.depth-1 THEN
      plane:=0;
      EXIT;
    END;
    INC(plane);
  END;*)
  IF factx=1 THEN
    y:=-1;
    WHILE y<height-1 DO
      INC(y);
      y2:=SHORT(SHORT(SHORT(y/facty+0.5)));
      IF y2>he-1 THEN
        y2:=he-1;
      END;
      g.BltMaskBitMapRastPort(buffer.bitMap,0,y2,rast,xpos,ypos+y,wi,1,s.VAL(s.BYTE,224),maskrast.bitMap.planes[0]);
    END;
  ELSE
    x:=-1;
    WHILE x<width-1 DO
      INC(x);
      x2:=SHORT(SHORT(SHORT(x/factx+0.5)));
      IF x2>wi-1 THEN
        x2:=wi-1;
      END;
      IF facty=1 THEN
        g.BltMaskBitMapRastPort(buffer.bitMap,x2,0,rast,xpos+x,ypos,1,he,s.VAL(s.BYTE,224),maskrast.bitMap.planes[0]);
      ELSE
        y:=-1;
        WHILE y<height-1 DO
          INC(y);
          y2:=SHORT(SHORT(SHORT(y/facty+0.5)));
          IF y2>he-1 THEN
            y2:=he-1;
          END;
          IF g.ReadPixel(buffer,x2,y2)>0 THEN
            bool:=g.WritePixel(rast,xpos+x,ypos+y);
          END;
        END;
      END;
    END;
  END;
  it.FreeRastPort(maskrast);
  it.FreeRastPort(buffer);
END PrintScaledChar;

PROCEDURE PrintChar*(rast:g.RastPortPtr;char:CHAR;x,y:INTEGER;font,size:l.Node);

VAR height : INTEGER;
    string : ARRAY 2 OF CHAR;
    factx,
    facty  : LONGREAL;
    attr   : g.TextAttr;
    textfont : g.TextFontPtr;
    mask,
    style  : SHORTSET;

BEGIN
  height:=GetFontPixelSize(size(p1.FontSize).size);
  style:=rast.algoStyle;
  IF (p1.globals.facty>0.99) AND (p1.globals.facty<1.01) AND (height=rast.txHeight) THEN
    string[0]:=char;
    string[1]:=0X;
    tt.Print(x,y+rast.txBaseline,s.ADR(string),rast);
  ELSE
    IF p1.globals.facty<1 THEN
      factx:=p1.globals.factx;
      facty:=1;
    ELSE
      factx:=1;
      facty:=p1.globals.facty;
      height:=SHORT(SHORT(SHORT(height/facty+0.5)));
    END;
    attr.name:=e.AllocMem(80,LONGSET{e.memClear});
    COPY(font(p1.Font).name,attr.name^);
    st.Append(attr.name^,".font");
    attr.ySize:=height;
    textfont:=df.OpenDiskFont(attr);
    g.SetFont(rast,textfont);
    e.FreeMem(attr.name,80);
    IF height#rast.txHeight THEN
      factx:=factx*height/rast.txHeight;
      facty:=facty*height/rast.txHeight;
    END;
    PrintScaledChar(rast,char,x,y,factx,facty);
    IF textfont#NIL THEN
      g.CloseFont(textfont);
    END;
    SetFont(rast,font,size);
    mask:=g.AskSoftStyle(rast);
    style:=g.SetSoftStyle(rast,style,mask);
  END;
END PrintChar;

PROCEDURE ScanFonts*(path:ARRAY OF CHAR);

VAR node,node2 : l.Node;

BEGIN
  NEW(node(p1.Path));
  node(p1.Path).path:="fonts";
  p1.paths.AddTail(node);

  node:=NIL;
  NEW(node(p1.Font));
  p1.fonts.AddTail(node);
  node(p1.Font).name:="CGTimes";
  node(p1.Font).path:=p1.paths.head;
  node(p1.Font).sizes:=l.Create();
  node(p1.Font).fsizes:=l.Create();
  node(p1.Font).outline:=TRUE;
  NEW(node2(p1.FontSize));
  node2(p1.FontSize).size:=12;
  node2(p1.FontSize).ideal:=TRUE;
  node(p1.Font).sizes.AddTail(node2);

  NEW(node(p1.Font));
  p1.fonts.AddTail(node);
  node(p1.Font).name:="CGTriumvirate";
  node(p1.Font).path:=p1.paths.head;
  node(p1.Font).sizes:=l.Create();
  node(p1.Font).fsizes:=l.Create();
  node(p1.Font).outline:=TRUE;
  NEW(node2(p1.FontSize));
  node2(p1.FontSize).size:=12;
  node2(p1.FontSize).ideal:=TRUE;
  node(p1.Font).sizes.AddTail(node2);

  NEW(node(p1.Font));
  p1.fonts.AddTail(node);
  node(p1.Font).name:="LetterGothic";
  node(p1.Font).path:=p1.paths.head;
  node(p1.Font).sizes:=l.Create();
  node(p1.Font).fsizes:=l.Create();
  node(p1.Font).outline:=TRUE;
  NEW(node2(p1.FontSize));
  node2(p1.FontSize).size:=12;
  node2(p1.FontSize).ideal:=TRUE;
  node(p1.Font).sizes.AddTail(node2);

  NEW(node(p1.Font));
  p1.fonts.AddTail(node);
  node(p1.Font).name:="topaz";
  node(p1.Font).path:=p1.paths.head;
  node(p1.Font).sizes:=l.Create();
  node(p1.Font).fsizes:=l.Create();
  node(p1.Font).outline:=FALSE;
  NEW(node2(p1.FontSize));
  node2(p1.FontSize).size:=12;
  node2(p1.FontSize).ideal:=FALSE;
  node(p1.Font).sizes.AddTail(node2);
END ScanFonts;

PROCEDURE * PrintFontName*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(p1.fonts,num);
  IF node#NIL THEN
    WITH node: p1.Font DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFontName;

PROCEDURE * PrintFontSize*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : ARRAY 5 OF CHAR;
    bool : BOOLEAN;

BEGIN
  IF datalist#NIL THEN
    node:=s1.GetNode(datalist,num);
    IF node#NIL THEN
      WITH node: p1.FontSize DO
        str:="    ";
        bool:=lrc.RealToString(node.size,str,3,0,FALSE);
        tt.Clear(str);
(*        IF NOT(node.ideal) THEN
          st.AppendChar(str,"-");
        END;*)
        tt.CutStringToLength(rast,str,width);
        tt.Print(x,y,s.ADR(str),rast);
      END;
    END;
  END;
END PrintFontSize;

PROCEDURE SelectFont*(VAR font,size:l.Node;box:l.Node):BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    upn,downn,
    scrolln,
    ups,downs,
    scrolls,
    fontname,
    fontsize,
    private  : I.GadgetPtr;
    ret      : BOOLEAN;
    posn,poss,
    actn,acts: INTEGER;
    actsize,
    node,
    node2,
    fontlist,
    sizelist : l.Node;
    bool     : BOOLEAN;
    x,y,ext  : INTEGER;
    string   : ARRAY 80 OF CHAR;
    real     : LONGREAL;

(*PROCEDURE RefreshNames;

VAR node : l.Node;
    str  : ARRAY 24 OF CHAR;

BEGIN
  node:=p1.fonts.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=posn) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;

  g.SetAPen(rast,1);
  i:=-1;
  LOOP
    INC(i);
    IF i>4 THEN
      EXIT;
    END;
    IF node#NIL THEN
      IF node=actfont THEN
        g.SetAPen(rast,3);
        g.RectFill(rast,30,42+i*10,266,51+i*10);
        g.SetAPen(rast,2);
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,30,42+i*10,266,51+i*10);
        g.SetAPen(rast,1);
      END;
      str:="                        ";
      COPY(node(p1.Font).name,str);
      tt.Print(30,49+i*10,str,rast);
      node:=node.next;
    ELSE
      g.SetAPen(rast,0);
      g.RectFill(rast,30,42+i*10,266,51+i*10);
    END;
  END;
  IF p1.fonts.nbElements()=0 THEN
    g.SetAPen(rast,0);
    g.RectFill(rast,30,42,266,91);
    g.SetAPen(rast,2);
    tt.Print(46,70,"Keine Zeichensätze",rast);
  END;
END RefreshNames;

PROCEDURE RefreshSizes;

VAR node : l.Node;
    str  : ARRAY 5 OF CHAR;

BEGIN
  IF actfont#NIL THEN
    node:=actfont(p1.Font).sizes.head;
    i:=-1;
    LOOP
      INC(i);
      IF (i=poss) OR (node=NIL) THEN
        EXIT;
      END;
      node:=node.next;
    END;
  
    g.SetAPen(rast,1);
    i:=-1;
    LOOP
      INC(i);
      IF i>4 THEN
        EXIT;
      END;
      IF node#NIL THEN
        IF node=actsize THEN
          g.SetAPen(rast,3);
          g.RectFill(rast,296,42+i*10,332,51+i*10);
          g.SetAPen(rast,2);
        ELSE
          g.SetAPen(rast,0);
          g.RectFill(rast,296,42+i*10,332,51+i*10);
          g.SetAPen(rast,1);
        END;
        str:="    ";
        bool:=lrc.RealToString(node(p1.FontSize).size,str,3,0,FALSE);
        tt.Clear(str);
        IF NOT(node(p1.FontSize).ideal) THEN
          st.AppendChar(str,"-");
        END;
        tt.Print(296,49+i*10,str,rast);
        node:=node.next;
      ELSE
        g.SetAPen(rast,0);
        g.RectFill(rast,296,42+i*10,332,51+i*10);
      END;
    END;
    IF p1.fonts.nbElements()=0 THEN
      g.SetAPen(rast,0);
      g.RectFill(rast,296,42,332,91);
    END;
  ELSE
    g.SetAPen(rast,0);
    g.RectFill(rast,296,42,332,91);
  END;
END RefreshSizes;

PROCEDURE RefreshScrollers;

BEGIN
  gm.SetScroller(scrolln,wind,SHORT(p1.fonts.nbElements()),5,posn);
  IF actfont#NIL THEN
    gm.SetScroller(scrolls,wind,SHORT(actfont(p1.Font).sizes.nbElements()),5,poss);
  END;
END RefreshScrollers;

PROCEDURE ScrollArrows(incname,incsize:INTEGER);

VAR class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;

BEGIN
  LOOP
    it.GetIMes(wind,class,code,address);
    IF (I.gadgetUp IN class) OR (I.mouseButtons IN class) THEN
      EXIT;
    END;
    INC(posn,incname);
    INC(poss,incsize);
    IF posn>p1.fonts.nbElements()-5 THEN
      posn:=SHORT(p1.fonts.nbElements()-5);
    END;
    IF posn<0 THEN
      posn:=0;
    END;
    IF actfont#NIL THEN
      IF poss>actfont(p1.Font).sizes.nbElements()-5 THEN
        poss:=SHORT(actfont(p1.Font).sizes.nbElements()-5);
      END;
      IF poss<0 THEN
        poss:=0;
      END;
    ELSE
      poss:=0;
    END;
    IF incname#NIL THEN
      RefreshNames;
    END;
    IF incsize#NIL THEN
      RefreshSizes;
    END;
    RefreshScrollers;
  END;
END ScrollArrows;

PROCEDURE ScrollProps;

VAR class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    first   : BOOLEAN;

BEGIN
  first:=TRUE;
  LOOP
    IF NOT(first) THEN
      it.GetIMes(wind,class,code,address);
      IF (I.gadgetUp IN class) OR (I.mouseButtons IN class) THEN
        EXIT;
      END;
    END;
    posn:=gm.GetScroller(scrolln,SHORT(p1.fonts.nbElements()),5);
    IF actfont#NIL THEN
      poss:=gm.GetScroller(scrolls,SHORT(actfont(p1.Font).sizes.nbElements()),5);
    END;
    IF posn>p1.fonts.nbElements()-5 THEN
      posn:=SHORT(p1.fonts.nbElements()-5);
    END;
    IF posn<0 THEN
      posn:=0;
    END;
    IF actfont#NIL THEN
      IF poss>actfont(p1.Font).sizes.nbElements()-5 THEN
        poss:=SHORT(actfont(p1.Font).sizes.nbElements()-5);
      END;
      IF poss<0 THEN
        poss:=0;
      END;
    ELSE
      poss:=0;
    END;
    RefreshNames;
    RefreshSizes;
    first:=FALSE;
  END;
END ScrollProps;*)

PROCEDURE RefreshGadgets;

VAR str : ARRAY 5 OF CHAR;

BEGIN
  IF actfont#NIL THEN
    gm.PutGadgetText(fontname,actfont(p1.Font).name);
  END;
  IF actsize#NIL THEN
    str:="    ";
    bool:=lrc.RealToString(actsize(p1.FontSize).size,str,3,0,FALSE);
    tt.Clear(str);
    gm.PutGadgetText(fontsize,str);
  END;
  I.RefreshGList(fontname,wind,NIL,2);
END RefreshGadgets;

PROCEDURE NewFontList;

BEGIN
  gm.SetListViewParams(fontlist,26,40,260,54,SHORT(p1.fonts.nbElements()),s1.GetNodeNumber(p1.fonts,actfont),PrintFontName);
  gm.SetCorrectPosition(fontlist);
  gm.RefreshListView(fontlist);
END NewFontList;

PROCEDURE NewSizeList;

BEGIN
  IF actfont#NIL THEN
    gm.SetListViewParams(sizelist,292,40,60,54,SHORT(actfont(p1.Font).sizes.nbElements()),s1.GetNodeNumber(actfont(p1.Font).sizes,actsize),PrintFontSize);
    gm.SetDataList(sizelist,actfont(p1.Font).sizes);
  ELSE
    gm.SetListViewParams(sizelist,292,40,60,54,0,0,PrintFontSize);
  END;
  gm.SetCorrectPosition(sizelist);
  gm.RefreshListView(sizelist);
END NewSizeList;

BEGIN
  ret:=FALSE;
  IF box#NIL THEN
    ext:=13;
  ELSE
    ext:=0;
  END;
  IF selectfontId=-1 THEN
    selectfontId:=wm.InitWindow(20,20,378,138+ext,ac.GetString(ac.SelectFont),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},p1.previewscreen,FALSE);
  END;
  wm.GetDimensions(selectfontId,x,y,i,a);
  wm.SetDimensions(selectfontId,x,y,378,138+ext);
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,117+ext,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(264,117+ext,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,117+ext,100,14,ac.GetString(ac.Help));
  fontname:=gm.SetStringGadget(26,94,248,14,255);
  fontsize:=gm.SetStringGadget(292,94,48,14,255);
  IF box#NIL THEN
    private:=gm.SetCheckBoxGadget(326,110,26,9,NOT(box(p1.MathBox).stdfont));
  END;
  fontlist:=gm.SetListView(26,40,260,54,0,0,PrintFontName);
  sizelist:=gm.SetListView(292,40,60,54,0,0,PrintFontSize);
(*  upn:=gm.SetArrowUpGadget(270,74);
  downn:=gm.SetArrowDownGadget(270,84);
  scrolln:=gm.SetPropGadget(270,40,16,34,0,0,0,32767);
  ups:=gm.SetArrowUpGadget(336,74);
  downs:=gm.SetArrowDownGadget(336,84);
  scrolls:=gm.SetPropGadget(336,40,16,34,0,0,0,32767);*)
  gm.EndGadgets;
  wm.SetGadgets(selectfontId,ok);
  wm.ChangeScreen(selectfontId,p1.previewscreen);
  wind:=wm.OpenWindow(selectfontId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

(*    gm.DrawPropBorders(wind);*)

    it.DrawBorder(rast,14,16,350,98+ext);
    it.DrawBorder(rast,20,28,338,83+ext);
(*    it.DrawBorder(rast,26,40,244,54);
    it.DrawBorder(rast,292,40,44,54);*)

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.Selection),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.Font),rast);
    tt.Print(292,37,ac.GetString(ac.Size),rast);
    IF box#NIL THEN
      tt.Print(26,118,ac.GetString(ac.UseAutoFont),rast);
    END;

    gm.SetCorrectWindow(fontlist,wind);
    gm.SetCorrectWindow(sizelist,wind);
    gm.SetNoEntryText(fontlist,ac.GetString(ac.None),ac.GetString(ac.FontsEx));
    gm.SetNoEntryText(sizelist,s.ADR(" "),s.ADR(" "));

(*    IF box#NIL THEN
      IF NOT(box(p1.MathBox).private) THEN
        gm.ActivateBool(private,wind);
      END;
    END;*)

    IF font#NIL THEN
      actfont:=font;
    ELSE
      actfont:=p1.fonts.head;
    END;
    IF size#NIL THEN
      actsize:=size;
    ELSE
      IF actfont#NIL THEN
        actsize:=actfont(p1.Font).sizes.head;
        IF actsize=NIL THEN
          node:=NIL;
          NEW(node(p1.FontSize));
          node(p1.FontSize).size:=12;
          node(p1.FontSize).ideal:=actfont(p1.Font).outline;
          actfont(p1.Font).sizes.AddTail(node);
          actsize:=node;
        END;
      END;
    END;
    NewFontList;
    NewSizeList;

    posn:=0;
    poss:=0;
(*    RefreshNames;
    RefreshSizes;*)
    RefreshGadgets;
    IF actfont#NIL THEN
      bool:=I.ActivateGadget(fontname^,wind,NIL);
    END;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      bool:=gm.CheckListView(fontlist,class,code,address);
      IF bool THEN
        actfont:=s1.GetNode(p1.fonts,gm.ActEl(fontlist));
        IF actfont#NIL THEN
          actsize:=actfont(p1.Font).sizes.head;
        END;
        NewSizeList;
        RefreshGadgets;
      END;
      bool:=gm.CheckListView(sizelist,class,code,address);
      IF bool THEN
        IF actfont#NIL THEN
          actsize:=s1.GetNode(actfont(p1.Font).sizes,gm.ActEl(sizelist));
          RefreshGadgets;
        END;
      END;
(*      IF I.gadgetDown IN class THEN
        IF address=upn THEN
          ScrollArrows(-1,0);
        ELSIF address=downn THEN
          ScrollArrows(1,0);
        ELSIF address=ups THEN
          ScrollArrows(0,-1);
        ELSIF address=downs THEN
          ScrollArrows(0,1);
        ELSIF (address=scrolln) OR (address=scrolls) THEN
          ScrollProps;
        END;*)
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          font:=actfont;
          size:=actsize;
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          EXIT;
        ELSIF address=fontname THEN
          gm.GetGadgetText(fontname,string);
          bool:=I.ActivateGadget(fontsize^,wind,NIL);
        ELSIF address=fontsize THEN
          IF actfont#NIL THEN
            gm.GetGadgetText(fontsize,string);
            bool:=lrc.StringToReal(string,real);
            node:=NIL;
            NEW(node(p1.FontSize));
            node(p1.FontSize).size:=real;
            node(p1.FontSize).ideal:=actfont(p1.Font).outline;
            node2:=actfont(p1.Font).sizes.head;
            IF node2#NIL THEN
              poss:=-1;
              WHILE node2#NIL DO
                INC(poss);
                IF node2(p1.FontSize).size=real THEN
                  actsize:=node2;
                  node2:=NIL;
                ELSIF node2(p1.FontSize).size>real THEN
                  node2.AddBefore(node);
                  actsize:=node;
                  node2:=NIL;
                END;
                IF node2#NIL THEN
                  IF node2.next=NIL THEN
                    node2.AddBehind(node);
                    actsize:=node;
                  END;
                  node2:=node2.next;
                END;
              END;
            ELSE
              actfont(p1.Font).sizes.AddTail(node);
              actsize:=node;
            END;
            IF poss>actfont(p1.Font).sizes.nbElements()-5 THEN
              poss:=SHORT(actfont(p1.Font).sizes.nbElements()-5);
            END;
            IF poss<0 THEN
              poss:=0;
            END;
            NewSizeList;
(*            RefreshSizes;
            RefreshScrollers;*)
          END;
          bool:=I.ActivateGadget(fontname^,wind,NIL);
        ELSIF (address=private) AND (box#NIL) THEN
          box(p1.MathBox).stdfont:=NOT(box(p1.MathBox).stdfont);
        END;
(*      ELSIF I.mouseButtons IN class THEN
        IF code=I.selectDown THEN
          it.GetMousePos(wind,x,y);
          IF (x>28) AND (x<268) AND (y>41) AND (y<93) THEN
            y:=y-41;
            y:=y DIV 10;
            actn:=y+posn;
            INC(actn);
            REPEAT
              DEC(actn);
              node:=s1.GetNode(p1.fonts,actn);
            UNTIL (node#NIL) OR (actn=-1);
            actfont:=node;
            RefreshNames;
            RefreshSizes;
          ELSIF (x>294) AND (x<334) AND (y>41) AND (y<93) AND (actfont#NIL) THEN
            y:=y-41;
            y:=y DIV 10;
            acts:=y+poss;
            INC(acts);
            REPEAT
              DEC(acts);
              node:=s1.GetNode(actfont(p1.Font).sizes,acts);
            UNTIL (node#NIL) OR (acts=-1);
            actsize:=node;
            RefreshSizes;
          END;
          RefreshGadgets;
        END;*)
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"fontreq",wind);
      END;
    END;
    wm.CloseWindow(selectfontId);
  END;
  wm.FreeGadgets(selectfontId);
  RETURN ret;
END SelectFont;

PROCEDURE * PrintConvertPoint(rast:g.RastPortPtr;x,y,width,num:INTEGER);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(p1.convlist,num);
  IF node#NIL THEN
    node:=node(p1.FontConvert).pointfont;
    WITH node: p1.Font DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintConvertPoint;

PROCEDURE * PrintConvertPix(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(p1.convlist,num);
  IF node#NIL THEN
    WITH node: p1.FontConvert DO
      NEW(str);
      COPY(node.pixname,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintConvertPix;

PROCEDURE FontConvert*():BOOLEAN;

VAR wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    ok,ca,
    help,
    add,del,
    conv,
    pixsize,
    pointsize,
    type      : I.GadgetPtr;
    convlist,
    fontlist,
    actconv,
    actfont,
    node      : l.Node;
    ret,bool  : BOOLEAN;
    string    : ARRAY 80 OF CHAR;
    long      : LONGINT;
    typetext  : ARRAY 5 OF ARRAY 80 OF CHAR;
    typepos   : INTEGER;

PROCEDURE NewConvList;

BEGIN
  gm.SetListViewParams(convlist,26,40,260,54,SHORT(p1.convlist.nbElements()),s1.GetNodeNumber(p1.convlist,actconv),PrintConvertPix);
  gm.SetCorrectPosition(convlist);
  gm.RefreshListView(convlist);
END NewConvList;

PROCEDURE NewFontList;

BEGIN
  gm.SetListViewParams(fontlist,292,40,260,54,SHORT(p1.fonts.nbElements()),s1.GetNodeNumber(p1.fonts,actfont),PrintFontName);
  gm.SetCorrectPosition(fontlist);
  gm.RefreshListView(fontlist);
END NewFontList;

PROCEDURE RefreshConv;

BEGIN
  IF actconv#NIL THEN
    gm.PutGadgetText(conv,actconv(p1.FontConvert).pixname);
    I.RefreshGList(conv,wind,NIL,1);
    bool:=I.ActivateGadget(conv^,wind,NIL);
  END;
END RefreshConv;

(*PROCEDURE NewTypeGadget;

BEGIN

END NewTypeGadget;*)

BEGIN
  ret:=FALSE;
  IF convertId=-1 THEN
    convertId:=wm.InitWindow(20,20,578,200,ac.GetString(ac.FontConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons},p1.previewscreen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,179,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(464,179,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,179,100,14,ac.GetString(ac.Help));
  add:=gm.SetBooleanGadget(26,110,260,14,ac.GetString(ac.NewFont));
  del:=gm.SetBooleanGadget(26,125,260,14,ac.GetString(ac.DelFont));
  conv:=gm.SetStringGadget(26,94,248,14,255);
  pixsize:=gm.SetStringGadget(170,156,48,14,255);
  pointsize:=gm.SetStringGadget(436,156,48,14,255);
(*  typetext[0]:="Generell gültig";
  typetext[1]:="Nur Funktionsfenster";
  typetext[2]:="Nur Legenden";
  typetext[3]:="Nur Tabellen";
  typetext[4]:="Nur Listen";
  type:=gm.SetCycleGadget(292,110,260,14,s.ADR(typetext[0]));*)
  convlist:=gm.SetListView(26,40,260,54,0,0,PrintConvertPix);
  fontlist:=gm.SetListView(292,40,260,54,0,0,PrintFontName);
  gm.EndGadgets;
  wm.SetGadgets(convertId,ok);
  wm.ChangeScreen(convertId,p1.previewscreen);
  wind:=wm.OpenWindow(convertId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    it.DrawBorder(rast,14,16,550,160);
    it.DrawBorder(rast,20,28,538,114);
    it.DrawBorder(rast,20,153,538,20);

    g.SetAPen(rast,1);
    tt.Print(20,25,ac.GetString(ac.Font),rast);
    tt.Print(20,150,ac.GetString(ac.Size),rast);
    g.SetAPen(rast,2);
    tt.Print(26,37,ac.GetString(ac.MathModeFont),rast);
    tt.Print(292,37,ac.GetString(ac.LayoutModeFont),rast);
    tt.Print(26,165,ac.GetString(ac.MathModeSize),rast);
    tt.Print(292,165,ac.GetString(ac.LayoutModeSize),rast);
    tt.Print(234,165,ac.GetString(ac.Pixels),rast);
    tt.Print(500,165,ac.GetString(ac.PicaPoints),rast);

    gm.SetCorrectWindow(convlist,wind);
    gm.SetCorrectWindow(fontlist,wind);
    gm.SetNoEntryText(convlist,ac.GetString(ac.None),ac.GetString(ac.FontsEx));
    gm.SetNoEntryText(fontlist,ac.GetString(ac.None),ac.GetString(ac.FontsEx));

    actconv:=p1.convlist.head;
    actfont:=p1.fonts.head;
    NewConvList;
    NewFontList;

    bool:=c.IntToString(p1.pixsize,string,5);
    tt.Clear(string);
    gm.PutGadgetText(pixsize,string);
    bool:=c.IntToString(p1.pointsize,string,5);
    tt.Clear(string);
    gm.PutGadgetText(pointsize,string);
    I.RefreshGList(pixsize,wind,NIL,2);

    RefreshConv;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF actconv#NIL THEN
        gm.GetGadgetText(conv,actconv(p1.FontConvert).pixname);
      END;
      bool:=gm.CheckListView(convlist,class,code,address);
      IF bool THEN
        actconv:=s1.GetNode(p1.convlist,gm.ActEl(convlist));
        IF actconv#NIL THEN
          actfont:=actconv(p1.FontConvert).pointfont;
        END;
        NewFontList;
        RefreshConv;
        class:=LONGSET{};
      END;
      bool:=gm.CheckListView(fontlist,class,code,address);
      IF bool THEN
        IF actconv#NIL THEN
          actfont:=s1.GetNode(p1.fonts,gm.ActEl(fontlist));
          actconv(p1.FontConvert).pointfont:=actfont;
        END;
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          gm.GetGadgetText(pixsize,string);
          bool:=c.StringToInt(string,long);
          p1.pixsize:=SHORT(long);
          gm.GetGadgetText(pointsize,string);
          bool:=c.StringToInt(string,long);
          p1.pointsize:=SHORT(long);
          ret:=TRUE;
          EXIT;
        ELSIF address=add THEN
          NEW(node(p1.FontConvert));
          node(p1.FontConvert).pixname:="";
          node(p1.FontConvert).pointfont:=p1.fonts.head;
          node(p1.FontConvert).standard:=FALSE;
          p1.convlist.AddTail(node);
          actconv:=node;
          actfont:=actconv(p1.FontConvert).pointfont;
          NewConvList;
          NewFontList;
          RefreshConv;
        ELSIF address=del THEN
          IF actconv#NIL THEN
            IF NOT(actconv(p1.FontConvert).standard) THEN
              node:=actconv.next;
              IF node=NIL THEN
                node:=actconv.prev;
              END;
              actconv.Remove;
              actconv:=node;
              RefreshConv;
              NewConvList;
              NewFontList;
            END;
          END;
(*        ELSIF address=conv THEN
          bool:=I.ActivateGadget(pixsize^,wind,NIL);
          NewConvList;*)
        ELSIF address=pixsize THEN
          bool:=I.ActivateGadget(pointsize^,wind,NIL);
        ELSIF address=pointsize THEN
          bool:=I.ActivateGadget(conv^,wind,NIL);
        ELSIF address=type THEN
          gm.CyclePressed(type,wind,typetext,typepos);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"fontconvert",wind);
      END;
    END;
    wm.CloseWindow(convertId);
  END;
  wm.FreeGadgets(convertId);
  RETURN ret;
END FontConvert;

PROCEDURE GetConvertFont*(attr:g.TextAttrPtr;VAR font,fontsize:l.Node);

VAR node,node2    : l.Node;
    size          : LONGREAL;

BEGIN
  font:=NIL;
  node:=p1.convlist.head;
  WHILE node#NIL DO
    IF tt.Compare(node(p1.FontConvert).pixname,attr.name^) AND NOT(node(p1.FontConvert).standard) THEN
      font:=node(p1.FontConvert).pointfont;
    ELSIF node(p1.FontConvert).standard THEN
      node2:=node;
    END;
    node:=node.next;
    IF font#NIL THEN
      node:=NIL;
    END;
  END;
  IF font=NIL THEN
    font:=node2(p1.FontConvert).pointfont;
  END;
  size:=attr.ySize*p1.pointsize/p1.pixsize;
  NEW(fontsize(p1.FontSize));
  fontsize(p1.FontSize).size:=size;
END GetConvertFont;

(*PROCEDURE ConvertFont*(attr1,attr2:g.TextAttrPtr);

VAR node : l.Node;

BEGIN
  node:=GetConvertFont(attr1);
  COPY(node(p1.Font).name,attr2.name^);
  attr2.ySize:=SHORT(SHORT(attr1.ySize*p1.pointsize/p1.pixsize));
END ConvertFont;*)

PROCEDURE ConvertBoxFonts*;

VAR node : l.Node;

BEGIN
  node:=p1.boxes.head;
  WHILE node#NIL DO
    IF node IS p1.MathBox THEN
      IF NOT(node(p1.MathBox).stdfont) THEN
        IF node IS p1.Legend THEN
          GetConvertFont(s.ADR(node(p1.Legend).node(s1.Legend).attr),node(p1.MathBox).font,node(p1.MathBox).font);
    (*      ConvertFont(s.ADR(node(p1.Legend).node(s1.FontNode).font),s.ADR(node(p1.MathBox).font));*)
        ELSIF node IS p1.Table THEN
          GetConvertFont(s.ADR(node(p1.Table).node(s1.Table).attr),node(p1.MathBox).font,node(p1.MathBox).font);
    (*      ConvertFont(s.ADR(node(p1.Table).node(s1.FontNode).font),s.ADR(node(p1.MathBox).font));*)
        ELSIF node IS p1.List THEN
          GetConvertFont(s.ADR(node(p1.List).node(s1.List).attr),node(p1.MathBox).font,node(p1.MathBox).font);
    (*      ConvertFont(s.ADR(node(p1.List).node(s1.FontNode).font),s.ADR(node(p1.MathBox).font));*)
        ELSIF node IS p1.Fenster THEN
          GetConvertFont(s.ADR(node(p1.Fenster).node(s1.Fenster).scale.attr),node(p1.MathBox).font,node(p1.MathBox).font);
        END;
      END;
    END;
    node:=node.next;
  END;
END ConvertBoxFonts;

PROCEDURE SetBoxFont*(rast:g.RastPortPtr;node:l.Node);

BEGIN
  WITH node: p1.MathBox DO
    SetFont(rast,node.font,node.size);
  END;
END SetBoxFont;

PROCEDURE PlotRuler*(blitonly:BOOLEAN);

VAR i,addx,addy : LONGREAL;
    x,y,wi,he   : INTEGER;
    longdraw    : BOOLEAN;

PROCEDURE GetRoundNumber(VAR add:LONGREAL);

BEGIN
  IF add>2 THEN add:=4;
  ELSIF add>1 THEN add:=2;
(*  ELSIF add>0.5 THEN add:=1;
  ELSIF add>0.2 THEN add:=0.5;
  ELSIF add>0.1 THEN add:=0.2;*)
  ELSE add:=1;
  END;
END GetRoundNumber;

BEGIN
  p1.PageToPagePic(p1.globals.pagewidth,p1.globals.pageheight,x,y);
  IF p1.rulerchanged THEN
    IF p1.xrulerrast#NIL THEN
      it.FreeRastPort(p1.xrulerrast);
    END;
    IF p1.yrulerrast#NIL THEN
      it.FreeRastPort(p1.yrulerrast);
    END;
    p1.xrulerrast:=it.AllocRastPort(x,p1.stdoffy,2);
    p1.yrulerrast:=it.AllocRastPort(p1.stdoffx,y,2);
  END;
  IF p1.rulerchanged THEN
    p1.rulerchanged:=FALSE;
    g.SetRast(p1.xrulerrast,0);
    g.SetRast(p1.yrulerrast,0);
    g.SetAPen(p1.xrulerrast,1);
    g.SetAPen(p1.yrulerrast,1);
    p1.PagePicToPage(20,10,addx,addy);
    GetRoundNumber(addx);
    GetRoundNumber(addy);
    longdraw:=FALSE;
    i:=0;
    WHILE i<p1.globals.pagewidth-addx/4 DO
      i:=i+addx/4;
      p1.PageToPagePic(i,0,x,y);
      INC(y,p1.stdoffy);
  (*    p1.CorrectPagePicOffsets(x,y);
      INC(y,p1.offy);*)
      IF longdraw THEN
        g.Move(p1.xrulerrast,x,y-1);
        g.Draw(p1.xrulerrast,x,y-4);
      ELSE
        g.Move(p1.xrulerrast,x,y-1);
        g.Draw(p1.xrulerrast,x,y-3);
      END;
      longdraw:=NOT(longdraw);
    END;
    i:=0;
    longdraw:=FALSE;
    WHILE i<p1.globals.pageheight-addy/4 DO
      i:=i+addy/4;
      p1.PageToPagePic(0,i,x,y);
      INC(x,p1.stdoffx);
  (*    p1.CorrectPagePicOffsets(x,y);
      INC(x,p1.offx);*)
      IF longdraw THEN
        g.Move(p1.yrulerrast,x-3,y);
        g.Draw(p1.yrulerrast,x-6,y);
      ELSE
        g.Move(p1.yrulerrast,x-3,y);
        g.Draw(p1.yrulerrast,x-5,y);
      END;
      longdraw:=NOT(longdraw);
    END;
    i:=0;
    WHILE i<p1.globals.pagewidth-addx DO
      i:=i+addx;
      p1.PageToPagePic(i,0,x,y);
      INC(y,p1.stdoffy);
  (*    p1.CorrectPagePicOffsets(x,y);
      INC(y,p1.offy);*)
      tt.PrintMid(x,y-p1.stdoffy+8,i,p1.xrulerrast);
      g.Move(p1.xrulerrast,x,y-1);
      g.Draw(p1.xrulerrast,x,y-5);
    END;
    i:=0;
    WHILE i<p1.globals.pageheight-addy DO
      i:=i+addy;
      p1.PageToPagePic(0,i,x,y);
      INC(x,p1.stdoffx);
  (*    p1.CorrectPagePicOffsets(x,y);
      INC(x,p1.offx);*)
      tt.PrintRight(x-8,y+3,i,p1.yrulerrast);
      g.Move(p1.yrulerrast,x-3,y);
      g.Draw(p1.yrulerrast,x-7,y);
    END;
  END;
  p1.PageToPagePic(p1.globals.pagewidth,p1.globals.pageheight,x,y);
  INC(x);
  INC(y);
  wi:=p1.previewwindow.width-8-p1.stdoffx-14;
  he:=p1.previewwindow.height-10-p1.top-p1.stdoffy;
  IF x<wi THEN
    wi:=x;
  END;
  IF y<he THEN
    he:=y;
  END;
  x:=4+p1.stdoffx;
  y:=p1.top+p1.stdoffy;
  g.ClipBlit(p1.xrulerrast,p1.offx+2,1,p1.previewwindow.rPort,x+2,y-p1.stdoffy+1,wi-4,p1.stdoffy-2,s.VAL(s.BYTE,0C0H));
  g.ClipBlit(p1.yrulerrast,2,p1.offy+1,p1.previewwindow.rPort,x-p1.stdoffx+2,y+1,p1.stdoffx-4,he-2,s.VAL(s.BYTE,0C0H));
  IF NOT(blitonly) THEN
    g.SetAPen(p1.previewwindow.rPort,0);
    g.RectFill(p1.previewwindow.rPort,x-p1.stdoffx+2,y-p1.stdoffy+1,x-3,y-2);
    it.DrawBorder(p1.previewwindow.rPort,x,y-p1.stdoffy,wi,p1.stdoffy);
    it.DrawBorder(p1.previewwindow.rPort,x-p1.stdoffx,y,p1.stdoffx,he);
    it.DrawBorder(p1.previewwindow.rPort,x-p1.stdoffx,y-p1.stdoffy,p1.stdoffx,p1.stdoffy);

    g.SetAPen(p1.previewwindow.rPort,s.LSH(1,p1.previewscreen.rastPort.bitMap.depth));
    g.SafeSetWriteMask(p1.previewwindow.rPort,SHORTSET{2..7});
    g.RectFill(p1.previewwindow.rPort,x+2,y-p1.stdoffy+1,x+2+wi-4-1,y-p1.stdoffy+p1.stdoffy-2);
    g.RectFill(p1.previewwindow.rPort,x-p1.stdoffx+2,y+1,x-p1.stdoffx+2-1+p1.stdoffx-4,y+he-2);
    g.SafeSetWriteMask(p1.previewwindow.rPort,SHORTSET{0..7});
  END;
END PlotRuler;

PROCEDURE PlotRaster*;

VAR x,y,
    maxx,maxy,
    minx,miny : LONGREAL;
    picx,picy : INTEGER;
    bool      : BOOLEAN;

BEGIN
  p1.PagePicToPage(p1.EditWidth()+p1.offx,p1.EditHeight()+p1.offy,maxx,maxy);
  p1.PagePicToPage(p1.offx,p1.offy,minx,miny);
  g.SetAPen(p1.previewwindow.rPort,1);
  y:=-p1.rastery;
  WHILE (y<=p1.globals.pageheight-p1.rastery) AND (y<=maxy) DO
    y:=y+p1.rastery;
    picy:=SHORT(SHORT(SHORT(y/p1.globals.pageheight*p1.globals.pagepicy+0.5)));
    DEC(picy,p1.offy);
    INC(picy,p1.top);
    IF p1.ruler THEN
      INC(picy,p1.stdoffy);
    END;
    x:=-p1.rasterx;
    WHILE (x<=p1.globals.pagewidth-p1.rasterx) AND (x<=maxx) AND (y>=miny) DO
      x:=x+p1.rasterx;
      IF x>=minx THEN
        picx:=SHORT(SHORT(SHORT(x/p1.globals.pagewidth*p1.globals.pagepicx+0.5)));
        DEC(picx,p1.offx);
        INC(picx,4);
        IF p1.ruler THEN
          INC(picx,p1.stdoffx);
        END;
(*        p1.PageToPagePicC(x,y,picx,picy);*)
        bool:=g.WritePixel(p1.previewwindow.rPort,picx,picy);
      END;
    END;
  END;
END PlotRaster;

(*PROCEDURE PlotTextBlock*(wind:I.WindowPtr;text:l.Node);

VAR x,y,width,height,
    xmax,ymax,
    charheight       : LONGREAL;
    pixx,pixy        : INTEGER;
    node,node2,abs,
    char             : l.Node;
    bool             : BOOLEAN;
    string           : ARRAY 256 OF CHAR;

PROCEDURE GetNextWord(char:l.Node;VAR string:ARRAY OF CHAR):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  IF char=NIL THEN
    ret:=FALSE;
  ELSE
    ret:=TRUE;
    string:="";
    LOOP
      IF char=NIL THEN
        EXIT;
      END;
      IF char(p1.TextChar).char=" " THEN
        EXIT;
      END;
      st.AppendChar(string,char(p1.TextChar).char);
      char:=char.next;
    END;
  END;
  RETURN ret;
END GetNextWord;

PROCEDURE GetTextLength(char:l.Node;len:INTEGER):LONGREAL;

VAR length,oldsize,fact,width : LONGREAL;
    string                    : ARRAY 2 OF CHAR;

BEGIN
  length:=0;
  string[1]:=0X;
  WHILE len>0 DO
    WITH char: p1.TextChar DO
      oldsize:=char.size(p1.FontSize).size;
      IF char.size(p1.FontSize).size<50 THEN
        fact:=char.size(p1.FontSize).size/50;
        char.size(p1.FontSize).size:=50;
      END;
      SetFontRast(p1.fontrast,char.font,char.size);
      char.size(p1.FontSize).size:=oldsize;
      string[0]:=char.char;
      length:=length+(fact*g.TextLength(p1.fontrast,string,1));
    END;
    char:=char.next;
    DEC(len);
  END;
  p1.PagePicToPage(SHORT(SHORT(SHORT(length))),0,width,fact);
  RETURN width;
END GetTextLength;

PROCEDURE PrintText(VAR char:l.Node;len:INTEGER;x,y:LONGREAL);

VAR picx,picy           : INTEGER;
    oldsize,fact,length : LONGREAL;
    string              : ARRAY 2 OF CHAR;

BEGIN
  string[1]:=0X;
  WHILE len>0 DO
    WITH char: p1.TextChar DO
      oldsize:=char.size(p1.FontSize).size;
      IF char.size(p1.FontSize).size<50 THEN
        fact:=char.size(p1.FontSize).size/50;
        char.size(p1.FontSize).size:=50;
      END;
      SetFontRast(p1.fontrast,char.font,char.size);
      char.size(p1.FontSize).size:=oldsize;
      string[1]:=char.char;
      length:=length+(fact*g.TextLength(p1.fontrast,string,1));
      p1.PageToPagePicC(x,y,picx,picy);
      tt.Print(picx,picy,string,wind.rPort);
      x:=x+length;
    END;
    char:=char.next;
    DEC(len);
  END;
END PrintText;

BEGIN
  WITH text: p1.TextBlock DO
    x:=text.xpos;
    y:=text.ypos;
    xmax:=text.xpos+text.width;
    ymax:=text.ypos+text.height;
    abs:=text.absatz.head;
    WHILE abs#NIL DO
      char:=abs(p1.TextAbsatz).charlist.head;
      charheight:=0;
      WHILE char#NIL DO
        IF char(p1.TextChar).size(p1.FontSize).size>charheight THEN
          charheight:=char(p1.TextChar).size(p1.FontSize).size;
        END;
        bool:=GetNextWord(char,string);
        IF bool THEN
          IF char(p1.TextChar).char=" " THEN
            width:=GetTextLength(char,1);
            x:=width;
          ELSE
            width:=GetTextLength(char,SHORT(st.Length(string)));
            IF x+width>xmax THEN
              height:=p1.PointToCent(charheight);
              y:=height;
              charheight:=0;
            END;
            PrintText(char,SHORT(st.Length(string)),x,y);
            x:=x+width;
          END;
        END;
        char:=char.next;
      END;
      abs:=abs.next;
    END;
  END;
END PlotTextBlock;*)

BEGIN
  selectfontId:=-1;
  convertId:=-1;
  font:=NIL;
CLOSE
  IF font#NIL THEN
    g.CloseFont(font);
  END;
END Preview2.

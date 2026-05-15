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


MODULE FormelEdit;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       l  : LinkedLists,
       st : Strings,
       df : DiskFont,
       it : IntuitionTools,
       tt : TextTools,
       at : AslTools,
       gm : GadgetManager,
       wm : WindowManager,
       mm : MenuManager,
       io,
       NoGuruRq;

TYPE FormelPart = RECORD(l.NodeDesc)
       elements    : l.List;
       width,height,
       toptotop,
       bottobot    : INTEGER;
     END;
     Element = RECORD(l.NodeDesc)
       index,power : l.Node;
       width,height,
       wholewidth  ,
       wholeheight : INTEGER;
       level       : INTEGER;
     END;
     Text = RECORD(Element)
       string      : ARRAY 256 OF CHAR;
       numchars    : INTEGER;
     END;
     Fraction = RECORD(Element)
       numerator,
       denominator : l.Node;
     END;
     Root = RECORD(Element)
       term        : l.Node;
       n           : LONGREAL;
     END;
     Formel = RECORD(FormelPart)
       size        : INTEGER;
       levelfact   : ARRAY 20 OF LONGREAL;
       attr        : g.TextAttr;
     END;

VAR screen : I.ScreenPtr;
    window : I.WindowPtr;
    rast   : g.RastPortPtr;
    view   : g.ViewPortPtr;
    editId : INTEGER;
    class  : LONGSET;
    code   : INTEGER;
    address: s.ADDRESS;
    ok,bool: BOOLEAN;
    levelfact : ARRAY 20 OF LONGREAL;

PROCEDURE Init;

BEGIN
  screen:=it.SetScreen(640,200,2,s.ADR("FormelEdit V0.5  © 1993 Marc Necker"),TRUE,TRUE,FALSE);
  window:=it.SetWindow(0,11,screen.width,screen.height-11,NIL,LONGSET{I.backDrop,I.borderless,I.activate,I.simpleRefresh,I.noCareRefresh},
                       LONGSET{I.menuPick,I.rawKey,I.inactiveWindow},screen);

  view:=s.ADR(screen.viewPort);
END Init;

PROCEDURE Close;

BEGIN
  I.CloseWindow(window);
  ok:=I.CloseScreen(screen);
END Close;

PROCEDURE RealToInt(real:LONGREAL):INTEGER;

BEGIN
  RETURN SHORT(SHORT(SHORT(real+0.5)));
END RealToInt;

PROCEDURE SetFont(rast:g.RastPortPtr;term,node:l.Node;VAR font:g.TextFontPtr);

VAR size : INTEGER;

BEGIN
  size:=RealToInt(term(Formel).size*term(Formel).levelfact[node(Element).level]);
  term(Formel).attr.ySize:=size;
  font:=df.OpenDiskFont(term(Formel).attr);
  g.SetFont(rast,font);
END SetFont;

PROCEDURE CloseFont(VAR font:g.TextFontPtr);

BEGIN
  g.CloseFont(font);
END CloseFont;

PROCEDURE RawPlotFormel(rast:g.RastPortPtr;xpos,ypos:INTEGER;term,actnode:l.Node;actpos:INTEGER);

VAR node : l.Node;

PROCEDURE PlotList(VAR xpos,ypos:INTEGER;data:l.Node);

VAR node : l.Node;
    x,y  : INTEGER;

PROCEDURE PlotElement(VAR x,y:INTEGER;node:l.Node);

VAR nextsize  : INTEGER;
    locx,locy : INTEGER;
    font      : g.TextFontPtr;

BEGIN
  nextsize:=RealToInt(term(Formel).size*term(Formel).levelfact[node(Element).level+1]);
  SetFont(rast,term,node,font);
  IF node IS Text THEN
    tt.Print(x,y,node(Text).string,rast);
  ELSIF node IS Fraction THEN
  END;
  IF node(Element).index#NIL THEN
    locx:=x+node(Element).width;
    locy:=y+(nextsize DIV 3);
    PlotList(locx,locy,node(Element).index);
  END;
  IF node(Element).power#NIL THEN
    locx:=x+node(Element).width;
    locy:=y-(nextsize DIV 3)-rast.txBaseline;
    PlotList(locx,locy,node(Element).power);
  END;
  INC(x,node(Element).wholewidth);
  CloseFont(font);
END PlotElement;

BEGIN
  WITH data: FormelPart DO
    x:=xpos;
    y:=ypos;
    node:=data.elements.head;
    WHILE node#NIL DO
      PlotElement(x,y,node);
      node:=node.next;
    END;
  END;
END PlotList;

BEGIN
  PlotList(xpos,ypos,term);
END RawPlotFormel;

PROCEDURE Edit;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    size,
    sizescroll,
    font,
    settings : I.GadgetPtr;
    term     : l.Node;
    node,node2 : l.Node;
    actnode  : l.Node;
    actpos   : INTEGER;

PROCEDURE RefreshSize;

VAR tfont : g.TextFontPtr;
    attr  : g.TextAttr;

BEGIN
  attr.name:=s.ADR("topaz.font");
  attr.ySize:=8;
  tfont:=df.OpenDiskFont(attr);
  g.SetFont(rast,tfont);

  g.SetRast(rast,0);
  I.RefreshWindowFrame(wind);
  I.RefreshGList(font,wind,NIL,4);
  gm.DrawPropBorders(wind);

  g.SetAPen(rast,1);
  tt.Print(20,25,"Formel editieren",rast);
  tt.Print(20,wind.height-62,"Formeleinstellungen",rast);
  g.SetAPen(rast,2);
  tt.Print(26,wind.height-48,"Größe:",rast);
  it.DrawBorder(rast,14,16,wind.width-42,wind.height-23);
  it.DrawBorder(rast,20,28,wind.width-54,wind.height-98);
  it.DrawBorder(rast,20,wind.height-59,wind.width-54,49);
  g.CloseFont(tfont);
END RefreshSize;

PROCEDURE InitElement(node:l.Node);

BEGIN
  node(Element).index:=NIL;
  node(Element).power:=NIL;
  node(Element).width:=0;
  node(Element).height:=0;
  node(Element).wholewidth:=0;
  node(Element).wholeheight:=0;
  node(Element).level:=0;
  IF node IS Text THEN
    node(Text).string:=" ";
    node(Text).numchars:=1;
  ELSIF node IS Fraction THEN
    NEW(node(Fraction).numerator(Text));
    NEW(node(Fraction).denominator(Text));
    InitElement(node(Fraction).numerator);
    InitElement(node(Fraction).denominator);
  ELSIF node IS Root THEN
    NEW(node(Root).term(Text));
    InitElement(node(Root).term);
    node(Root).n:=2;
  END;
END InitElement;

PROCEDURE InitFormel(term:l.Node);

BEGIN
  NEW(node(Text));
  InitElement(node);
  term(Formel).elements:=l.Create();
  term(Formel).elements.AddTail(node);
  term(Formel).size:=48;
  term(Formel).levelfact[0]:=1;
  term(Formel).levelfact[1]:=0.5;
  term(Formel).levelfact[2]:=0.25;
  term(Formel).levelfact[3]:=0.125;
  term(Formel).levelfact[4]:=0.1;
  term(Formel).attr.name:=s.ADR("times.font");
END InitFormel;

PROCEDURE RefreshLocals(data:l.Node);

VAR node : l.Node;

PROCEDURE SetLocalDims(node:l.Node);

VAR width,height : INTEGER;
    font         : g.TextFontPtr;

BEGIN
  SetFont(rast,term,node,font);
  IF node IS Text THEN
    WITH node: Text DO
      node.width:=g.TextLength(rast,node.string,st.Length(node.string));
      node.height:=rast.txHeight;
    END;
  ELSIF node IS Fraction THEN
    WITH node: Fraction DO
      RefreshLocals(node.numerator);
      RefreshLocals(node.denominator);
      node.width:=0;
      node.height:=0;
    END;
  ELSIF node IS Root THEN
    WITH node: Root DO
      RefreshLocals(node.term);
      node.width:=0;
      node.height:=0;
    END;
  END;
  IF node(Element).index#NIL THEN
    RefreshLocals(node(Element).index);
  END;
  IF node(Element).power#NIL THEN
    RefreshLocals(node(Element).power);
  END;
  CloseFont(font);
END SetLocalDims;

BEGIN
  node:=data(FormelPart).elements.head;
  WHILE node#NIL DO
    SetLocalDims(node);
    node:=node.next;
  END;
END RefreshLocals;

PROCEDURE RefreshDimensions(data:l.Node);

VAR node : l.Node;

PROCEDURE SetDimensions(node:l.Node;VAR width:INTEGER);

VAR wi,wi2 : INTEGER;

BEGIN
  width:=0;
  wi:=0;
  wi2:=0;
  IF node(Element).index#NIL THEN
    RefreshDimensions(node(Element).index);
    wi:=node(Element).index(FormelPart).width;
  END;
  IF node(Element).power#NIL THEN
    RefreshDimensions(node(Element).power);
    wi2:=node(Element).power(FormelPart).width;
  END;
  IF wi>wi2 THEN
    INC(width,wi);
  ELSE
    INC(width,wi2);
  END;
  IF node IS Text THEN
    WITH node: Text DO
      INC(width,node.width);
    END;
  ELSIF node IS Fraction THEN
    WITH node: Fraction DO
      wi:=0;
      wi2:=0;
      IF node.numerator#NIL THEN
        RefreshDimensions(node.numerator);
        wi:=node.numerator(FormelPart).width;
      END;
      IF node.denominator#NIL THEN
        RefreshDimensions(node.denominator);
        wi2:=node.denominator(FormelPart).width;
      END;
      IF wi>wi2 THEN
        node.width:=wi;
        INC(width,wi);
      ELSE
        node.width:=wi2;
        INC(width,wi2);
      END;
      node.wholewidth:=node.width;
    END;
  END;
END SetDimensions;

BEGIN
  node:=data(FormelPart).elements.head;
  data(FormelPart).width:=0;
  WHILE node#NIL DO
    node(Element).wholewidth:=0;
    SetDimensions(node,node(Element).wholewidth);
    INC(data(FormelPart).width,node(Element).wholewidth);
    node:=node.next;
  END;
END RefreshDimensions;

PROCEDURE RefreshLevels(data:l.Node;level:INTEGER);

VAR node : l.Node;

PROCEDURE DoLevel(node:l.Node;level:INTEGER);

BEGIN
  IF node(Element).index#NIL THEN
    RefreshLevels(node(Element).index,level+1);
  END;
  IF node(Element).power#NIL THEN
    RefreshLevels(node(Element).power,level+1);
  END;
  node(Element).level:=level;
  IF node IS Fraction THEN
    RefreshLevels(node(Fraction).numerator,level+1);
    RefreshLevels(node(Fraction).denominator,level+1);
  END;
END DoLevel;

BEGIN
  node:=data(FormelPart).elements.head;
  WHILE node#NIL DO
    DoLevel(node,level);
    node:=node.next;
  END;
END RefreshLevels;

PROCEDURE RefreshFormel;

BEGIN
  RefreshLevels(term,0);
  RefreshLocals(term);
  RefreshDimensions(term);
END RefreshFormel;

BEGIN
  IF editId=-1 THEN
    editId:=wm.InitWindow(20,10,600,178,"Formeleditor",LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowClose,I.windowSizing},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.newSize,I.closeWindow},screen,FALSE);
  END;
  gm.StartGadgets(window);
  font:=gm.SetBooleanGadget(26,-41,200,14,s.ADR("Formelzeichensatz"));
  INCL(font.flags,I.gRelBottom);
  settings:=gm.SetBooleanGadget(26,-26,200,14,s.ADR("Zusatzeinstellungen"));
  INCL(settings.flags,I.gRelBottom);
  size:=gm.SetStringGadget(76,-56,40,14,255);
  INCL(size.flags,I.gRelBottom);
  sizescroll:=gm.SetPropGadget(132,-55,94,12,0,0,32767,0);
  INCL(sizescroll.flags,I.gRelBottom);
  wm.SetGadgets(editId,font);
  wm.ChangeScreen(editId,screen);
  wind:=wm.OpenWindow(editId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    gm.DrawPropBorders(wind);

    g.SetAPen(rast,1);
    tt.Print(20,25,"Formel editieren",rast);
    tt.Print(20,wind.height-62,"Formeleinstellungen",rast);
    g.SetAPen(rast,2);
    tt.Print(26,wind.height-48,"Größe:",rast);
    it.DrawBorder(rast,14,16,wind.width-42,wind.height-23);
    it.DrawBorder(rast,20,28,wind.width-54,wind.height-98);
    it.DrawBorder(rast,20,wind.height-59,wind.width-54,49);

    NEW(term(Formel));
    InitFormel(term);
    actnode:=term(Formel).elements.head;
    actpos:=0;
    node:=term(Formel).elements.head;
    node(Text).string:="2xt";
    NEW(node(Text).power(FormelPart));
    node(Text).power(FormelPart).elements:=l.Create();
    NEW(node2(Text));
    node2(Text).string:="a";
    node(Text).power(FormelPart).elements.AddTail(node2);
    NEW(node2(Text));
    node2(Text).string:="t";
    NEW(node(Text).power(FormelPart).elements.head(Element).index(FormelPart));
    node(Text).power(FormelPart).elements.head(Element).index(FormelPart).elements:=l.Create();
    node(Text).power(FormelPart).elements.head(Element).index(FormelPart).elements.AddTail(node2);
    NEW(node(Text).index(FormelPart));
    node(Text).index(FormelPart).elements:=l.Create();
    NEW(node2(Text));
    node2(Text).string:="1";
    node(Text).index(FormelPart).elements.AddTail(node2);
    NEW(node2(Text));
    term(Formel).elements.AddTail(node2);
    node:=node.next;
    node(Text).string:="+xt";
    NEW(node(Text).power(FormelPart));
    node(Text).power(FormelPart).elements:=l.Create();
    NEW(node2(Text));
    node2(Text).string:="a+1";
    node(Text).power(FormelPart).elements.AddTail(node2);;
    NEW(node(Text).index(FormelPart));
    node(Text).index(FormelPart).elements:=l.Create();
    NEW(node2(Text));
    node2(Text).string:="2";
    node(Text).index(FormelPart).elements.AddTail(node2);

    RefreshFormel;
    RawPlotFormel(rast,26,70,term,NIL,0);

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF I.closeWindow IN class THEN
        EXIT;
      ELSIF I.newSize IN class THEN
        RefreshSize;
        RawPlotFormel(rast,26,70,term,NIL,0);
      ELSIF I.gadgetUp IN class THEN
        IF address=font THEN
          at.minHeight:=1;
          at.maxHeight:=100;
          term(Formel).attr.ySize:=term(Formel).size;
          at.attr:=s.ADR(term(Formel).attr);
          at.frontPen:=1;
          at.backPen:=0;
          at.drawMode:=SHORTSET{};
          at.FontRequest(s.ADR("Zeichensatz für Formel auswählen"),wind);
          term(Formel).size:=term(Formel).attr.ySize;
          RefreshFormel;
          g.SetAPen(rast,0);
          g.RectFill(rast,22,29,wind.width-58,wind.height-100);
          g.SetAPen(rast,1);
          RawPlotFormel(rast,26,70,term,NIL,0);
        END;
      END;
    END;
    wm.CloseWindow(editId);
  END;
  wm.FreeGadgets(editId);
END Edit;

BEGIN
  editId:=-1;
  levelfact[0]:=1;
  levelfact[1]:=0.75;
  levelfact[2]:=0.5;
  levelfact[3]:=0.25;
  levelfact[4]:=0.125;
  at.fontxpos:=100;
  at.fontypos:=20;
  at.fontwidth:=400;
  at.fontheight:=150;
  Init;
  Edit;
  Close;
END FormelEdit.


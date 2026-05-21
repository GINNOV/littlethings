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


MODULE GuiManagerExtendedObjects;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       c  : Conversions,
       gt : GadTools,
       gd : Gadgets,
       st : Strings,
       rg : RawGadgets,
       bt : BasicTools,
       it : IntuitionTools,
       gr : GraphicsTools,
       tt : TextTools,
       ft : FunctionTrees,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       im : Images,
       l  : LinkedLists,
       Beep,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

VAR gradpens : ARRAY 1 OF INTEGER; (* Colorpen array for gradient slider *)



TYPE StatusBar * = POINTER TO StatusBarDesc;
     StatusBarDesc * = RECORD(gmb.GadgetDesc)
       titlehe,
       barcol,
       min,max,
       act       : INTEGER;
       formatstr : e.STRPTR;
     END;

PROCEDURE (gad:StatusBar) Init*;

VAR wi : INTEGER;

BEGIN
  gad.minwi:=gad.font.ySize*20;
  gad.minhe:=gad.font.ySize+6;
  gad.titlehe:=0;
  IF gad.text#NIL THEN
    wi:=gmb.TextLength(gad,gad.text);
    IF wi>gad.minwi THEN
      gad.minwi:=wi;
    END;
    gad.titlehe:=SHORT(SHORT(gad.font.ySize*1.1+0.5));
    gad.minhe:=gad.minhe+gad.titlehe;
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:StatusBar) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
END Resize;

PROCEDURE (gad:StatusBar) Refresh*;

VAR rast  : g.RastPortPtr;
    width : INTEGER;

BEGIN
  IF gad.iwind#NIL THEN
    rast:=gad.iwind.rPort;
    g.SetAPen(rast,gad.color);
    g.Move(rast,gad.xpos,gad.ypos+rast.font.baseline);
    g.Text(rast,gad.text^,st.Length(gad.text^));
    gt.DrawBevelBox(rast,gad.xpos,gad.ypos+gad.titlehe,gad.width,gad.height-gad.titlehe,
                                          gt.bbFrameType,gt.bbftButton,
                                          gt.visualInfo,gad.root.vinfo,
                                          u.done);
    width:=gad.width-5;
    width:=SHORT(SHORT(width*(gad.act-gad.min)/(gad.max-gad.min)));
    IF width<0 THEN width:=0; END;
    IF width>gad.width-5 THEN width:=gad.width-5; END;

    g.SetAPen(rast,gad.barcol);
    g.RectFill(rast,gad.xpos+2,gad.ypos+gad.titlehe+1,gad.xpos+2+width,gad.ypos+gad.height-2);
  END;
END Refresh;

PROCEDURE (gad:StatusBar) QuickRefresh*;

VAR rast  : g.RastPortPtr;
    width : INTEGER;

BEGIN
  IF gad.iwind#NIL THEN
    rast:=gad.iwind.rPort;
    width:=gad.width-5;
    width:=SHORT(SHORT(LONG(width)*(gad.act-gad.min)/(gad.max-gad.min)));
    IF width<0 THEN width:=0; END;
    IF width>gad.width-5 THEN width:=gad.width-5; END;

    g.SetAPen(rast,gad.barcol);
    g.RectFill(rast,gad.xpos+2,gad.ypos+gad.titlehe+1,gad.xpos+2+width,gad.ypos+gad.height-2);
    g.SetAPen(rast,0);
    g.RectFill(rast,gad.xpos+2+width+1,gad.ypos+gad.titlehe+1,gad.xpos+gad.width-3,gad.ypos+gad.height-2);
  END;
END QuickRefresh;

PROCEDURE (gad:StatusBar) SetValue*(act:LONGINT);

BEGIN
  gad.act:=SHORT(act);
  gad.QuickRefresh;
END SetValue;

PROCEDURE (gad:StatusBar) GetValue*():LONGINT;

BEGIN
  RETURN gad.act;
END GetValue;

PROCEDURE SetStatusBar*(text:e.STRPTR;min,max,act,barcol:INTEGER;formatstr:e.STRPTR):StatusBar;

VAR node : gmb.Gadget;

BEGIN
  node:=NIL;
  NEW(node(StatusBar));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: StatusBar DO
      node.text:=text;
      node.gadget:=NIL;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.min:=min;
      node.max:=max;
      node.act:=act;
      node.color:=gmb.std.textcol;
      IF barcol>-1 THEN
        node.barcol:=barcol;
      ELSE
        node.barcol:=3;
      END;
      node.formatstr:=formatstr;
      node.sizex:=10;
      node.sizey:=1;
      node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^))+8;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(StatusBar);
END SetStatusBar;



(* Spaceobject *)

TYPE Space * = POINTER TO SpaceDesc;
     SpaceDesc * = RECORD(gmb.GadgetDesc)
       bordertype * : LONGINT;
       recessed   * : BOOLEAN;
       clickable  * : BOOLEAN;
       pressed    * : BOOLEAN;
     END;

PROCEDURE (text:Space) Init*;

BEGIN
  text.width:=text.minwi;
  text.height:=text.minhe;
  IF text.autoout THEN
    text.topout:=SHORT(SHORT(text.font.ySize/8+0.5));
    text.leftout:=SHORT(SHORT(text.font.ySize/2+0.5));
  END;
  text.Init^;
END Init;

PROCEDURE (text:Space) Resize*;

(*VAR rast : g.RastPortPtr;*)

BEGIN
(*  text.iwind:=text.root.iwind;
  rast:=text.iwind.rPort;
  g.SetAPen(rast,text.color);
  g.Move(rast,text.xpos,text.ypos+text.iwind.rPort.font.baseline);
  g.Text(rast,text.text^,st.Length(text.text^));*)
END Resize;

PROCEDURE (space:Space) FillSpace*(rast:g.RastPortPtr;x,y,width,height:LONGINT);

BEGIN

END FillSpace;

PROCEDURE (space:Space) Refresh*;

VAR rast    : g.RastPortPtr;
    str     : UNTRACED POINTER TO ARRAY OF CHAR;
    i       : LONGINT;
    pattern : ARRAY 4 OF INTEGER;

BEGIN
  IF space.root.iwind#NIL THEN
    space.iwind:=space.root.iwind;
    rast:=space.iwind.rPort;

(*    g.SetAPen(rast,3);
    g.RectFill(rast,space.xpos-20,space.ypos-10,space.xpos+20,space.ypos+10);*)
    g.SetAPen(rast,0);
    g.RectFill(rast,space.xpos+2,space.ypos+1,space.xpos+space.width-5,space.ypos+space.height-3);

    space.FillSpace(rast,space.xpos,space.ypos,space.width,space.height);

    IF space.bordertype#gmb.noBorder THEN
      IF (space.recessed) OR ((space.pressed) & ~space.recessed) THEN
        gt.DrawBevelBox(rast,space.xpos,space.ypos,space.width,space.height,
                                              gt.bbFrameType,space.bordertype,
                                              gt.bbRecessed,I.LTRUE,
                                              gt.visualInfo,space.root.vinfo,
                                              u.done);
      ELSE
        gt.DrawBevelBox(rast,space.xpos,space.ypos,space.width,space.height,
                                              gt.bbFrameType,space.bordertype,
                                              gt.visualInfo,space.root.vinfo,
                                              u.done);
      END;
    END;

    IF space.disabled THEN
      pattern[0]:=0AAAAU;
      pattern[2]:=0AAAAU;
      pattern[1]:=05555U;
      pattern[3]:=05555U;
      g.SetAfPt(rast,s.ADR(pattern),1);
      g.SetAPen(rast,3);
      g.RectFill(rast,space.xpos+2,space.ypos+1,space.xpos+space.width-5,space.ypos+space.height-3);
      g.SetAfPt(rast,NIL,0);
    END;
  END;
END Refresh;

PROCEDURE SetSpace*(bordertype:LONGINT;recessed:BOOLEAN;width,height:INTEGER;clickable:BOOLEAN):Space;

VAR gad       : I.GadgetPtr;
    node      : l.Node;
    maxx,maxy : BOOLEAN;

BEGIN
  IF width=-1 THEN maxx:=TRUE; ELSE maxx:=FALSE; END;
  IF height=-1 THEN maxy:=TRUE; ELSE maxy:=FALSE; END;
  IF width<10 THEN width:=8; END;
  IF height<10 THEN height:=8; END;
  node:=NIL;
  NEW(node(Space));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: Space DO
      node.text:=NIL;
      node.bordertype:=bordertype;
      node.recessed:=recessed;
      node.clickable:=clickable;
      node.pressed:=FALSE;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      IF maxx THEN node.sizex:=0;
              ELSE node.sizex:=-1; END;
      IF maxy THEN node.sizey:=0;
              ELSE node.sizey:=-1; END;
      node.minwi:=width;
      node.minhe:=height;
      node.userminwi:=0;
      node.userminhe:=0;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
    END;
  END;
  RETURN node(Space);
END SetSpace;

PROCEDURE (space:Space) InputEvent*(mes:I.IntuiMessagePtr);

BEGIN
  IF ~space.disabled & space.clickable THEN
    IF I.mouseButtons IN mes.class THEN
      IF mes.code=I.selectDown THEN
        IF (mes.mouseX>=space.xpos) AND (mes.mouseX<space.xpos+space.width) AND (mes.mouseY>=space.ypos) AND (mes.mouseY<space.ypos+space.height) THEN
          space.pressed:=TRUE;
          space.Refresh;
          mes.iAddress:=space;
          mes.class:=LONGSET{I.gadgetDown};
  (*      ELSE
          IF space.pressed THEN
            space.pressed:=FALSE;
            space.Refresh;
            mes.iAddress:=space;
            mes.class:=LONGSET{I.gadgetUp};
          END;*)
        END;
      END;
    END;
  END;
END InputEvent;



(* Fieldselectobject *)

TYPE FieldSelect * = POINTER TO FieldSelectDesc;
     FieldSelectDesc * = RECORD(gmb.GadgetDesc)
       printproc  - : gmo.PrintProc;
       datalist   - : l.List;
       actentry   - : LONGINT;
       user       - : e.APTR;
       selectwi   * : INTEGER;
       recessed   * : BOOLEAN;
     END;

PROCEDURE (gad:FieldSelect) Init*;

BEGIN
  gad.selectwi:=gad.font.ySize+8;
  gad.minwi:=gad.textwi+gad.userminwi+gad.selectwi;
  gad.minhe:=gad.font.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:FieldSelect) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetBooleanGadget(gad.xpos+gad.width-gad.selectwi+1,gad.ypos,gad.selectwi,gad.height,s.ADR("A"),gmb.prev);
END Resize;

PROCEDURE (gad:FieldSelect) Refresh*;

VAR rast         : g.RastPortPtr;
    x,y,
    width,height : INTEGER;

BEGIN
  IF gad.iwind#NIL THEN
    rast:=gad.iwind.rPort;
    x:=gad.xpos+gad.textwi;
    y:=gad.ypos;
    width:=gad.width-gad.selectwi-gad.textwi+1;
    height:=gad.height;

    g.SetAPen(rast,0);
    g.RectFill(rast,x+2,y+1,x+width-3,y+height-2);
    IF gad.recessed THEN
      gt.DrawBevelBox(rast,x,y,width,height,
                                            gt.bbFrameType,gt.bbftButton,
                                            gt.bbRecessed,I.LTRUE,
                                            gt.visualInfo,gad.root.vinfo,
                                            u.done);
    ELSE
      gt.DrawBevelBox(rast,x,y,width,height,
                                            gt.bbFrameType,gt.bbftButton,
                                            gt.visualInfo,gad.root.vinfo,
                                            u.done);
    END;
    g.SetAPen(rast,1);
    tt.Print(gad.xpos,y+((gad.height-rast.txHeight) DIV 2)+gmb.tfont.baseline+1,gad.text,rast);
    gad.printproc(rast,x+4,y+((gad.height-rast.txHeight) DIV 2)+gmb.tfont.baseline,width-8,gad.actentry,gad.datalist,gad.user);
  END;
END Refresh;

PROCEDURE (gad:FieldSelect) SetValue*(actentry:LONGINT);

BEGIN
  gad.actentry:=actentry;
  gad.Refresh;
END SetValue;

PROCEDURE (gad:FieldSelect) GetValue*():LONGINT;

BEGIN
  RETURN gad.actentry;
END GetValue;

PROCEDURE (gad:FieldSelect) SetUser*(user:e.APTR);

BEGIN
  gad.user:=user;
END SetUser;

PROCEDURE SetFieldSelect*(text:e.STRPTR;datalist:l.List;printproc:gmo.PrintProc;actentry:INTEGER;recessed:BOOLEAN;user:e.APTR):FieldSelect;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetBooleanGadget(-gmb.tfont.ySize*10-10,-gmb.tfont.ySize*2-10,gmb.tfont.ySize*10,gmb.tfont.ySize*2,text,gmb.prev);
  node:=NIL;
  NEW(node(FieldSelect));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: FieldSelect DO
      node.text:=text;
      node.datalist:=datalist;
      node.printproc:=printproc;
      node.actentry:=actentry;
      node.user:=user;
      node.recessed:=recessed;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=1;
      node.sizey:=-1;
      node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^))+8;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(FieldSelect);
END SetFieldSelect;

PROCEDURE (gad:FieldSelect) InputEvent*(mes:I.IntuiMessagePtr);

BEGIN
  IF I.vanillaKey IN mes.class THEN
    IF (gad.shortcut#0X) AND (st.CapIntl(CHR(mes.code))=st.CapIntl(gad.shortcut)) THEN
      gad.KeyboardAction;
      mes.iAddress:=gad.gadget;
      mes.class:=LONGSET{I.gadgetUp};
      mes.code:=0;
    END;
  END;
END InputEvent;



BEGIN
  gradpens[0]:=-1;
END GuiManagerExtendedObjects.


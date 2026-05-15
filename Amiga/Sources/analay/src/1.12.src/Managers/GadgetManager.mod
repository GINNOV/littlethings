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


MODULE GadgetManager;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       l  : LinkedLists,
       f  : Function,
       st : Strings,
       it : IntuitionTools,
       tt : TextTools,
       gt : GadTools,
       og : OldGadgets(*,
       ng : NewGadgets*);

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE PrintProc * = PROCEDURE(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);
     ListView * = RECORD(l.NodeDesc)
       window     * : I.WindowPtr;
       rast       * : g.RastPortPtr;
       xpos*,ypos * ,
       width      * ,
       height     * ,
       numitems   * ,
       numviewed  * ,
       itemheight * ,
       actpos     * ,
       actitem    * : INTEGER;
       up*,down   * ,
       scroll     * : I.GadgetPtr;
       printproc  * : PrintProc;
       noentry1   * ,
       noentry2   * : e.STRPTR;
       datalist   * : l.List;
     END;
     PaletteGadget * = RECORD(l.NodeDesc)
       window     * : I.WindowPtr;
       rast       * : g.RastPortPtr;
       xpos*,ypos * ,
       width      * ,
       height     * ,
       depth      * ,
       xnum*,ynum * ,
       pwidth     * ,
       pheight    * ,
       numcols    * ,
       actcol     * : INTEGER;
     END;

VAR os2    : BOOLEAN;
    vinfo  : gt.VisualInfo;
    prev   : I.GadgetPtr;
    window : I.WindowPtr;
    listviews : l.List;
    busy   : BOOLEAN;


PROCEDURE SetVisualInfo*(screen:I.ScreenPtr);

BEGIN
(*  IF os2 THEN
    vinfo:=gt.GetVisualInfo(screen,u.done);
  END;*)
END SetVisualInfo;

PROCEDURE FreeVisualInfo*;

BEGIN
(*  IF (vinfo#NIL) AND (os2) THEN
    gt.FreeVisualInfo(vinfo);
  END;*)
END FreeVisualInfo;

PROCEDURE StartGadgets*(wind:I.WindowPtr);

VAR gadget : I.GadgetPtr;
    exit   : BOOLEAN;

BEGIN
  REPEAT
    WHILE busy DO
      d.Delay(10);
    END;
    e.Forbid();
    IF NOT(busy) THEN
      busy:=TRUE;
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;
(*  IF os2 THEN
    prev:=gt.CreateContext(gadget);
  ELSE*)
    prev:=NIL;
(*  END;*)
  window:=wind;
END StartGadgets;

PROCEDURE EndGadgets*;

BEGIN
  busy:=FALSE;
END EndGadgets;

PROCEDURE SetBooleanGadget*(xpos,ypos,width,height:INTEGER;text:e.STRPTR):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);
  ELSE*)
    gadget:=og.SetBooleanGadget(xpos,ypos,width,text,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetBooleanGadget;

PROCEDURE SetStringGadget*(xpos,ypos,width,height,chars:INTEGER):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
    gadget:=ng.SetStringGadget(xpos,ypos,width,height,chars,vinfo,prev,window);
  ELSE*)
    gadget:=og.SetStringGadget(xpos,ypos,width,height,chars,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetStringGadget;

PROCEDURE SetPropGadget*(xpos,ypos,width,height:INTEGER;hPos,vPos,hBody,vBody:LONGINT):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetPropGadget(xpos,ypos,width,height,hPos,vPos,hBody,vBody,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetPropGadget;

PROCEDURE SetCheckBoxGadget*(xpos,ypos,width,height:INTEGER;sel:BOOLEAN):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
    gadget:=ng.SetCheckBoxGadget(xpos,ypos,26,9,vinfo,prev,window);
  ELSE*)
    gadget:=og.SetCheckBoxGadget(xpos,ypos,prev,window);
    IF sel THEN
      INCL(gadget.flags,I.selected);
    END;
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetCheckBoxGadget;

PROCEDURE SetArrowUpGadget*(xpos,ypos:INTEGER):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetArrowUpGadget(xpos,ypos,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetArrowUpGadget;

PROCEDURE SetArrowDownGadget*(xpos,ypos:INTEGER):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetArrowDownGadget(xpos,ypos,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetArrowDownGadget;

PROCEDURE SetArrowWideGadget*(xpos,ypos,direction:INTEGER):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetArrowWideGadget(xpos,ypos,direction,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetArrowWideGadget;

PROCEDURE SetRadioGadget*(xpos,ypos:INTEGER):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetRadioGadget(xpos,ypos,26,9,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetRadioGadget(xpos,ypos,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetRadioGadget;

PROCEDURE SetCycleGadget*(xpos,ypos,width,height:INTEGER;text:ARRAY OF CHAR):I.GadgetPtr;
(* $CopyArrays- *)

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
(*    gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetCycleGadget(xpos,ypos,width,text,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetCycleGadget;

PROCEDURE SetImageGadget*(xpos,ypos,width,height,depth:INTEGER;data,datasel:s.ADDRESS):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
(*  IF os2 THEN
 (*   gadget:=ng.SetBooleanGadget(xpos,ypos,width,height,text,vinfo,prev,window);*)
  ELSE*)
    gadget:=og.SetImageGadget(xpos,ypos,width,height,depth,data,datasel,prev,window);
(*  END;*)
  prev:=gadget;
  RETURN gadget;
END SetImageGadget;

PROCEDURE SetPaletteGadgetOld*(x,y,depth:INTEGER;VAR gads:ARRAY OF I.GadgetPtr);

VAR rows,
    wid,n,
    he,wi,
    px,py,
    num,i : INTEGER;
    pi    : SHORTINT;

BEGIN
  num:=2;
  i:=1;
  WHILE i<=depth-1 DO
    INC(i);
    num:=num*2;
  END;
  INC(x,50);
  IF num>8 THEN
    rows:=2;
    he:=8;
  ELSE
    rows:=1;
    he:=16;
  END;
  IF num>=8 THEN
    wi:=19;
    n:=8;
  ELSE
    wi:=38;
    n:=num;
  END;
  IF num=2 THEN
    wi:=76;
    n:=num;
  END;
  py:=-1;
  pi:=-1;
  WHILE py<rows-1 DO
    INC(py);
    px:=-1;
    WHILE px<n-1 DO
      INC(px);
      INC(pi);
      gads[pi]:=og.SetColorGadget(x+px*wi+4,y+py*he+2,wi,he,pi,prev,window);
      prev:=gads[pi];
    END;
  END;
END SetPaletteGadgetOld;

PROCEDURE Pow(b,e:INTEGER):INTEGER;

VAR oldb : INTEGER;

BEGIN
  oldb:=b;
  WHILE e-1#0 DO
    b:=b*oldb;
    DEC(e);
  END;
  RETURN b;
END Pow;

PROCEDURE RefreshPaletteData(VAR node:l.Node);

BEGIN
  IF node#NIL THEN
    WITH node: PaletteGadget DO
      node.xnum:=node.numcols;
      node.ynum:=1;
      IF node.numcols=16 THEN
        node.ynum:=2;
        node.xnum:=node.numcols DIV 2;
      END;
      node.pwidth:=(node.width-6) DIV node.xnum;
      node.width:=node.pwidth*node.xnum+6;
      node.pheight:=(node.height-4) DIV node.ynum;
      node.height:=node.pheight*node.ynum+4;
    END;
  END;
END RefreshPaletteData;

PROCEDURE SetPaletteGadget*(xpos,ypos,width,height,depth,actcol:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(PaletteGadget));
  WITH node: PaletteGadget DO
    node.window:=window;
    node.rast:=window.rPort;
    node.xpos:=xpos;
    node.ypos:=ypos;
    node.width:=width;
    node.height:=height;
    IF depth>4 THEN
      depth:=4;
    END;
    node.depth:=depth;
    node.numcols:=Pow(2,depth);
    node.actcol:=actcol;
  END;
  RefreshPaletteData(node);
  RETURN node;
END SetPaletteGadget;

PROCEDURE SetListView*(xpos,ypos,width,height,numitems,actitem:INTEGER;printproc:PrintProc):l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(ListView));
  WITH node: ListView DO
    node.window:=window;
    node.rast:=window.rPort;
    node.xpos:=xpos;
    node.ypos:=ypos;
    node.width:=width;
    node.height:=height;
    node.numitems:=numitems;
    node.actitem:=actitem;
    node.actpos:=0;
    node.printproc:=printproc;
    node.scroll:=SetPropGadget(xpos+width-16,ypos,16,height-20,0,0,0,32767);
    node.up:=SetArrowUpGadget(xpos+width-16,ypos+height-20);
    node.down:=SetArrowDownGadget(xpos+width-16,ypos+height-10);
  END;
  RETURN node;
END SetListView;

PROCEDURE DrawPaletteBorders*(rast:g.RastPortPtr;x,y:INTEGER);

BEGIN
  it.DrawBorderIn(rast,x,y,42,20);
  it.DrawBorder(rast,x+50,y,160,20);
END DrawPaletteBorders;

PROCEDURE FreeGadgetList*(VAR gadget:I.GadgetPtr);

VAR next : I.GadgetPtr;
    bord : I.BorderPtr;

BEGIN
(*  IF os2 THEN
    gt.FreeGadgets(gadget);
  ELSE*)
    WHILE gadget#NIL DO
      next:=gadget.nextGadget;
      IF gadget.gadgetType=I.boolGadget THEN
        IF gadget.gadgetText#NIL THEN
          bord:=s.VAL(I.BorderPtr,gadget.gadgetRender);
          IF bord.nextBorder.nextBorder.nextBorder=NIL THEN
            og.FreeBooleanGadget(gadget);
          ELSE
            og.FreeCycleGadget(gadget);
          END;
        ELSE
          IF gadget.selectRender#NIL THEN
            IF gadget.width=26 THEN
              og.FreeCheckBoxGadget(gadget);
            ELSIF gadget.width=16 THEN
              og.FreeArrowGadget(gadget);
            ELSIF gadget.width=17 THEN
              og.FreeRadioGadget(gadget);
            ELSIF gadget.width=18 THEN
              og.FreeArrowWideGadget(gadget);
            END;
          ELSE
            og.FreeImageGadget(gadget);
          END;
        END;
      ELSIF gadget.gadgetType=I.strGadget THEN
        og.FreeStringGadget(gadget);
      ELSIF gadget.gadgetType=I.propGadget THEN
        og.FreePropGadget(gadget);
      END;
      gadget:=next;
    END;
(*  END;*)
END FreeGadgetList;

PROCEDURE DrawPropBorders*(wind:I.WindowPtr);

VAR gadget       : I.GadgetPtr;
    xpos,ypos,
    width,height : INTEGER;

BEGIN
  gadget:=wind.firstGadget;
  WHILE gadget#NIL DO
    IF gadget.gadgetType=I.propGadget THEN
      xpos:=gadget.leftEdge-4;
      ypos:=gadget.topEdge-2;
      width:=gadget.width+8;
      height:=gadget.height+4;
      IF I.gRelRight IN gadget.flags THEN
        xpos:=wind.width+xpos-1;
      END;
      IF I.gRelBottom IN gadget.flags THEN
        ypos:=wind.height+ypos-1;
      END;
      IF I.gRelWidth IN gadget.flags THEN
        width:=wind.width+width;
      END;
      IF I.gRelHeight IN gadget.flags THEN
        height:=wind.height+height;
      END;
      it.DrawBorder(wind.rPort,xpos,ypos,width,height);
    END;
    gadget:=gadget.nextGadget;
  END;
END DrawPropBorders;

PROCEDURE ActivateBool*(gad:I.GadgetPtr;wind:I.WindowPtr);

BEGIN
  INCL(gad.flags,I.selected);
  IF wind#NIL THEN
    I.RefreshGList(gad,wind,NIL,1);
  END;
END ActivateBool;

PROCEDURE DeActivateBool*(gad:I.GadgetPtr;wind:I.WindowPtr);

BEGIN
  EXCL(gad.flags,I.selected);
  IF wind#NIL THEN
    I.RefreshGList(gad,wind,NIL,1);
  END;
END DeActivateBool;

PROCEDURE PutGadgetText*(gadget:I.GadgetPtr;text:ARRAY OF CHAR);
(* $CopyArrays- *)

BEGIN
(*  IF os2 THEN
  ELSE*)
    og.PutGadgetText(gadget,text);
(*  END;*)
END PutGadgetText;

PROCEDURE GetGadgetText*(gadget:I.GadgetPtr;VAR text:ARRAY OF CHAR);

BEGIN
(*  IF os2 THEN
  ELSE*)
    og.GetGadgetText(gadget,text);
(*  END;*)
END GetGadgetText;

PROCEDURE GetGadgetExpression*(gadget:I.GadgetPtr;VAR exp:ARRAY OF CHAR;VAR real:LONGREAL):BOOLEAN;

VAR save     : UNTRACED POINTER TO ARRAY OF CHAR;
    savereal : LONGREAL;

BEGIN
  NEW(save,LEN(exp)+1);
  COPY(exp,save^);
  savereal:=real;
(*  IF os2 THEN
  ELSE*)
    og.GetGadgetText(gadget,exp);
    real:=f.ExpressionToReal(exp);
(*  END;*)
  DISPOSE(save);
END GetGadgetExpression;

PROCEDURE SetSlider*(gadget:I.GadgetPtr;wind:I.WindowPtr;min,max,act:INTEGER);

VAR anz  : INTEGER;
    step : LONGINT;

BEGIN
  anz:=ABS(max-min);
  step:=65536 DIV (anz+1);
  IF anz=0 THEN
    anz:=1;
    step:=65535;
  END;
  I.NewModifyProp(gadget^,wind,NIL,SET{I.autoKnob,I.freeHoriz,I.knobHit,I.propBorderless},(65535 DIV (anz))*(act-min),0,step,0,1);
END SetSlider;

PROCEDURE GetSlider*(gadget:I.GadgetPtr;min,max:INTEGER):INTEGER;

VAR info    : I.PropInfoPtr;
    anz,ret : INTEGER;

BEGIN
  info:=gadget.specialInfo;
  anz:=ABS(max-min)+1;
  IF anz=0 THEN
    anz:=1;
  END;
  IF I.UIntToLong(info.horizBody)#0 THEN
    ret:=SHORT((I.UIntToLong(info.horizPot) DIV I.UIntToLong(info.horizBody))+min);
  ELSE
    ret:=0;
  END;
  IF ret<min THEN
    ret:=min;
  ELSIF ret>max THEN
    ret:=max;
  END;
  RETURN ret;
END GetSlider;

PROCEDURE SetScroller*(gadget:I.GadgetPtr;wind:I.WindowPtr;nums,view,pos:INTEGER);

VAR st,numsub,i : LONGINT;
    step        : REAL;
    info        : I.PropInfoPtr;

BEGIN
  IF nums<view THEN
    nums:=view;
  END;
  step:=(100/nums)*view;
  numsub:=nums;
  IF numsub<view THEN numsub:=view;END;
  IF numsub-(view-1)>0 THEN
    st:=0;
    st:=SHORT(SHORT(65535/100)*step);
    i:=numsub-view;
    IF i=0 THEN
      i:=1;
    END;
    info:=gadget.specialInfo;
    IF I.freeVert IN info.flags THEN
      I.NewModifyProp(gadget^,wind,NIL,SET{I.autoKnob,I.freeVert,I.knobHit,I.propBorderless},
                      0,SHORT(SHORT(65535/LONG(LONG(i)))*LONG(LONG(pos))),0,st,1);
    ELSE
      I.NewModifyProp(gadget^,wind,NIL,SET{I.autoKnob,I.freeHoriz,I.knobHit,I.propBorderless},
                      SHORT(SHORT(65535/LONG(LONG(i)))*LONG(LONG(pos))),0,st,0,1);
    END;
  END;
END SetScroller;

PROCEDURE GetScroller*(gadget:I.GadgetPtr;nums,view:INTEGER):INTEGER;

VAR info   : I.PropInfoPtr;
    u1,u2  : LONGINT;
    ret    : INTEGER;

BEGIN
  IF nums>view THEN
    info:=gadget.specialInfo;
    u1:=65535 DIV (nums-view);
    IF I.freeVert IN info.flags THEN
      u2:=I.UIntToLong(info.vertPot);
    ELSE
      u2:=I.UIntToLong(info.horizPot);
    END;
    ret:=SHORT(u2 DIV u1);
  ELSE
    ret:=0;
  END;
  RETURN ret;
END GetScroller;

PROCEDURE CyclePressed*(VAR gad:I.GadgetPtr;wind:I.WindowPtr;table:ARRAY OF ARRAY OF CHAR;VAR pos:INTEGER);
(* $CopyArrays- *)

BEGIN
(*  IF NOT(os2) THEN*)
    og.CyclePressed(gad,wind,table,pos);
(*  END;*)
END CyclePressed;

PROCEDURE SetGadgetDims*(gad:I.GadgetPtr;xpos,ypos,width,height:INTEGER);

BEGIN

END SetGadgetDims;

PROCEDURE CheckListView*(list:l.Node;VAR class:LONGSET;code:INTEGER;address:s.ADDRESS):BOOLEAN;

VAR olditem : INTEGER;
    ret     : BOOLEAN;

PROCEDURE Scroll(dir:INTEGER);

VAR class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    x,y,i,
    ticks,
    oldpos  : INTEGER;
    first   : BOOLEAN;

BEGIN
  WITH list: ListView DO
    first:=TRUE;
    ticks:=10000;
    LOOP
      IF (I.intuiTicks IN list.window.idcmpFlags) AND NOT(first) THEN
        e.WaitPort(list.window.userPort);
      END;
      INC(ticks);
      IF ticks>10000 THEN
        ticks:=10000;
      END;
      IF NOT(first) THEN
        it.GetIMes(list.window,class,code,address);
        IF (I.gadgetUp IN class) OR (I.mouseButtons IN class) THEN
          EXIT;
        END;
      END;
      oldpos:=list.actpos;
      IF (dir=-1) AND (ticks>3) THEN
        it.GetMousePos(list.window,x,y);
        IF (x>=list.up.leftEdge) AND (x<=list.up.leftEdge+list.up.width-1) AND (y>=list.up.topEdge) AND (y<=list.up.topEdge+list.up.height-1) THEN
          DEC(list.actpos);
        END;
      ELSIF (dir=1) AND (ticks>3) THEN
        it.GetMousePos(list.window,x,y);
        IF (x>=list.down.leftEdge) AND (x<=list.down.leftEdge+list.down.width-1) AND (y>=list.down.topEdge) AND (y<=list.down.topEdge+list.down.height-1) THEN
          INC(list.actpos);
        END;
      ELSIF dir=0 THEN
        list.actpos:=GetScroller(list.scroll,list.numitems,list.numviewed);
      END;
      IF (oldpos#list.actpos) AND (list.numitems>0) THEN
        IF list.actpos>list.numitems-list.numviewed THEN
          list.actpos:=list.numitems-list.numviewed;
        END;
        IF list.actpos<0 THEN
          list.actpos:=0;
        END;
        IF oldpos#list.actpos THEN
          IF dir#0 THEN
            SetScroller(list.scroll,list.window,list.numitems,list.numviewed,list.actpos);
          END;
          y:=list.ypos+2;
          i:=list.actpos;
          list.numviewed:=0;
          WHILE y<=list.ypos+list.height-2-list.itemheight DO
            INC(list.numviewed);
            IF (i=list.actitem) AND (i<list.numitems) THEN
              g.SetAPen(list.rast,3);
              g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
              g.SetAPen(list.rast,2);
            ELSE
              g.SetAPen(list.rast,0);
              g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
              g.SetAPen(list.rast,1);
            END;
            list.printproc(list.rast,list.xpos+4,y+1+list.rast.txBaseline,list.width-24,i,list.datalist);
            INC(y,list.itemheight);
            INC(i);
          END;
        END;
      END;
      IF first THEN
        ticks:=0;
      END;
      first:=FALSE;
    END;
  END;
END Scroll;

PROCEDURE MouseSelect;

VAR lclass  : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    x,y,i,
    olditem,
    oldpos,
    saveitem,
    savepos : INTEGER;

BEGIN
  WITH list: ListView DO
    g.SetDrMd(list.rast,g.jam1);
    it.GetMousePos(list.window,x,y);
    IF (x>=list.xpos) AND (x<=list.xpos+list.width-17) AND (y>=list.ypos) AND (y<=list.ypos+list.height-1) AND (list.numviewed>0) AND (list.numitems>0) THEN
      class:=LONGSET{};
      saveitem:=list.actitem;
      savepos:=list.actpos;
      LOOP
        it.GetIMes(list.window,lclass,code,address);
        olditem:=list.actitem;
        it.GetMousePos(list.window,x,y);
        oldpos:=list.actpos;
        olditem:=list.actitem;
        IF y<list.ypos+2 THEN
          DEC(list.actpos);
          list.actitem:=list.actpos;
        ELSIF y>list.ypos+list.itemheight*list.numviewed+1 THEN
          INC(list.actpos);
          list.actitem:=list.actpos+list.numviewed-1;
        ELSE
          DEC(y,list.ypos+2);
          list.actitem:=(y DIV list.itemheight)+list.actpos;
          IF list.actitem>list.numitems-1 THEN
            list.actitem:=list.numitems-1;
          END;
          IF list.actitem<0 THEN
            list.actitem:=0;
          END;
        END;
        IF oldpos#list.actpos THEN
          i:=list.actpos;
          IF list.actpos>list.numitems-list.numviewed THEN
            list.actpos:=list.numitems-list.numviewed;
          END;
          IF list.actpos<0 THEN
            list.actpos:=0;
          END;
          INC(list.actitem,list.actpos-i);
          IF list.actitem>=list.numitems THEN
            list.actitem:=list.numitems-1;
          END;
        END;
        IF I.menuPick IN lclass THEN
          list.actitem:=saveitem;
          list.actpos:=savepos;
        END;
        IF (olditem#list.actitem) AND (list.numitems>0) THEN
(*          IF oldpos=list.actpos THEN
            g.SetAPen(list.rast,0);
            g.RectFill(list.rast,list.xpos+2,list.ypos+2+list.itemheight*(olditem-list.actpos),list.xpos+list.width-19,list.ypos+2+list.itemheight*(olditem-list.actpos+1)-1);
            g.SetAPen(list.rast,1);
            list.printproc(list.rast,list.xpos+4,list.ypos+2+list.itemheight*(olditem-list.actpos)+1+list.rast.txBaseline,list.width-20,olditem);
            g.SetAPen(list.rast,3);
            g.RectFill(list.rast,list.xpos+2,list.ypos+2+list.itemheight*(list.actitem-list.actpos),list.xpos+list.width-19,list.ypos+2+list.itemheight*(list.actitem-list.actpos+1)-1);
            g.SetAPen(list.rast,2);
            list.printproc(list.rast,list.xpos+4,list.ypos+2+list.itemheight*(list.actitem-list.actpos)+1+list.rast.txBaseline,list.width-20,list.actitem);
          ELSE*)
            y:=list.ypos+2;
            i:=list.actpos;
            list.numviewed:=0;
            WHILE y<=list.ypos+list.height-2-list.itemheight DO
              INC(list.numviewed);
              IF (i=list.actitem) AND (i<list.numitems) THEN
                g.SetAPen(list.rast,3);
                g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
                g.SetAPen(list.rast,2);
              ELSE
                g.SetAPen(list.rast,0);
                g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
                g.SetAPen(list.rast,1);
              END;
              list.printproc(list.rast,list.xpos+4,y+1+list.rast.txBaseline,list.width-24,i,list.datalist);
              INC(y,list.itemheight);
              INC(i);
            END;
(*          END;*)
        END;
        IF oldpos#list.actpos THEN
          SetScroller(list.scroll,list.window,list.numitems,list.numviewed,list.actpos);
        END;
        IF (I.mouseButtons IN lclass) OR (I.menuPick IN lclass) THEN
          EXIT;
        END;
      END;
    END;
  END;
END MouseSelect;

BEGIN
  ret:=FALSE;
  IF list#NIL THEN
    WITH list: ListView DO
      olditem:=list.actitem;
      IF I.gadgetDown IN class THEN
        IF address=list.up THEN
          Scroll(-1);
          class:=LONGSET{};
        ELSIF address=list.down THEN
          Scroll(1);
          class:=LONGSET{};
        ELSIF address=list.scroll THEN
          Scroll(0);
          class:=LONGSET{};
        END;
      ELSIF I.gadgetUp IN class THEN
        IF address=list.scroll THEN
          Scroll(0);
          class:=LONGSET{};
        END;
      ELSIF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
        MouseSelect;
      END;
      IF olditem#list.actitem THEN
        ret:=TRUE;
      END;
    END;
  END;
  RETURN ret;
END CheckListView;

PROCEDURE SetListViewParams*(node:l.Node;xpos,ypos,width,height,numitems,actitem:INTEGER;printitem:PrintProc);

BEGIN
  IF node#NIL THEN
    WITH node: ListView DO
      node.xpos:=xpos;
      node.ypos:=ypos;
      node.width:=width;
      node.height:=height;
      node.numitems:=numitems;
      node.numviewed:=(height-4) DIV (node.rast.txHeight+2);
      node.actitem:=actitem;
      node.actpos:=0;
      node.printproc:=printitem;
      node.scroll.leftEdge:=xpos+width-16+4;
      node.scroll.topEdge:=ypos+2;
      node.scroll.height:=height-20-4;
      node.up.leftEdge:=xpos+width-16;
      node.up.topEdge:=ypos+height-20;
      node.down.leftEdge:=xpos+width-16;
      node.down.topEdge:=ypos+height-10;
    END;
  END;
END SetListViewParams;

PROCEDURE SetDataList*(node:l.Node;datalist:l.List);

BEGIN
  IF node#NIL THEN
    WITH node: ListView DO
      node.datalist:=datalist;
    END;
  END;
END SetDataList;

PROCEDURE SetCorrectWindow*(list:l.Node;window:I.WindowPtr);

BEGIN
  IF list#NIL THEN
    IF list IS ListView THEN
      WITH list: ListView DO
        list.window:=window;
        list.rast:=list.window.rPort;
      END;
    ELSIF list IS PaletteGadget THEN
      WITH list: PaletteGadget DO
        list.window:=window;
        list.rast:=list.window.rPort;
      END;
    END;
  END;
END SetCorrectWindow;

PROCEDURE SetCorrectPosition*(list:l.Node);

BEGIN
  IF list#NIL THEN
    WITH list: ListView DO
      IF list.actitem>=list.actpos+list.numviewed THEN
        list.actpos:=list.actitem-list.numviewed+1;
      END;
      IF list.actitem<list.actpos THEN
        list.actpos:=list.actitem;
      END;
      IF list.actpos>list.numitems-list.numviewed THEN
        list.actpos:=list.numitems-list.numviewed;
      END;
      IF list.actpos<0 THEN
        list.actpos:=0;
      END;
    END;
  END;
END SetCorrectPosition;

PROCEDURE SetNoEntryText*(list:l.Node;text1,text2:e.STRPTR);

BEGIN
  IF list#NIL THEN
    WITH list: ListView DO
      list.noentry1:=NIL;
      list.noentry2:=NIL;
      NEW(list.noentry1);
      NEW(list.noentry2);
      COPY(text1^,list.noentry1^);
      COPY(text2^,list.noentry2^);
      st.AppendChar(list.noentry1^," ");
    END;
  END;
END SetNoEntryText;

PROCEDURE RefreshListView*(list:l.Node);

VAR i,y,w1,w2 : INTEGER;

BEGIN
  IF list#NIL THEN
    WITH list: ListView DO
      list.rast:=list.window.rPort;
      g.SetDrMd(list.rast,g.jam1);
      it.DrawBorder(list.rast,list.xpos,list.ypos,list.width-16,list.height);
      it.DrawBorder(list.rast,list.scroll.leftEdge-4,list.scroll.topEdge-2,list.scroll.width+8,list.scroll.height+4);
      list.itemheight:=list.rast.txHeight+2;
      y:=list.ypos+2;
      i:=list.actpos;
      list.numviewed:=0;
      WHILE y<=list.ypos+list.height-2-list.itemheight DO
        INC(list.numviewed);
        IF (i=list.actitem) AND (i<list.numitems) THEN
          g.SetAPen(list.rast,3);
          g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
          g.SetAPen(list.rast,2);
        ELSE
          g.SetAPen(list.rast,0);
          g.RectFill(list.rast,list.xpos+2,y,list.xpos+list.width-19,y+list.itemheight-1);
          g.SetAPen(list.rast,1);
        END;
        list.printproc(list.rast,list.xpos+4,y+1+list.rast.txBaseline,list.width-24,i,list.datalist);
        INC(y,list.itemheight);
        INC(i);
      END;
      IF list.numitems=0 THEN
        g.SetAPen(list.rast,2);
        w1:=g.TextLength(list.rast,list.noentry1^,st.Length(list.noentry1^));
        w2:=g.TextLength(list.rast,list.noentry2^,st.Length(list.noentry2^));
        y:=list.ypos+((list.height-4) DIV 2)-list.itemheight;
        IF w1+w2>list.width-24 THEN
          IF w1>w2 THEN
            i:=w1;
          ELSE
            i:=w2;
          END;
          i:=list.width-16-i;
          IF i>20 THEN
            i:=20;
          ELSIF i<0 THEN
            i:=0;
          END;
          tt.Print(list.xpos+4+i,y+list.rast.txBaseline,list.noentry1,list.rast);
          y:=y+list.itemheight;
          tt.Print(list.xpos+4+i,y+list.rast.txBaseline,list.noentry2,list.rast);
        ELSE
          i:=(list.width-16-w1-w2) DIV 2;
          tt.Print(list.xpos+4+i,y+list.rast.txBaseline,list.noentry1,list.rast);
          tt.Print(list.xpos+4+w1+i,y+list.rast.txBaseline,list.noentry2,list.rast);
        END;
      END;
      SetScroller(list.scroll,list.window,list.numitems,list.numviewed,list.actpos);
    END;
  END;
END RefreshListView;

PROCEDURE ActEl*(list:l.Node):INTEGER;

BEGIN
  IF list#NIL THEN
    RETURN list(ListView).actitem;
  ELSE
    RETURN 0;
  END;
END ActEl;

PROCEDURE FreeListView*(list:l.Node);

BEGIN
  IF list#NIL THEN
    DISPOSE(list(ListView).noentry1);
    DISPOSE(list(ListView).noentry2);
(*    list.Remove;*)
  END;
END FreeListView;

PROCEDURE SetPaletteParams*(VAR node:l.Node;xpos,ypos,width,height,depth,actcol:INTEGER);

BEGIN
  WITH node: PaletteGadget DO
    node.xpos:=xpos;
    node.ypos:=ypos;
    node.width:=width;
    node.height:=height;
    IF depth>4 THEN
      depth:=4;
    END;
    node.depth:=depth;
    node.numcols:=Pow(2,depth);
    node.actcol:=actcol;
  END;
  RefreshPaletteData(node);
END SetPaletteParams;

PROCEDURE DrawClearBorder(rast:g.RastPortPtr;x1,y1,wi,he:INTEGER);

VAR x2,y2 : INTEGER;

BEGIN
  g.SetAPen(rast,0);
  x2:=x1+wi-1;
  y2:=y1+he-1;
  g.Move(rast,x1,y1);
  g.Draw(rast,x1,y2);
  g.Draw(rast,x1,y2-1);
  g.Draw(rast,x1+1,y2-1);
  g.Draw(rast,x1+1,y1);
  g.Draw(rast,x2-1,y1);

  g.Move(rast,x2,y2);
  g.Draw(rast,x2,y1);
  g.Draw(rast,x2,y1+1);
  g.Draw(rast,x2-1,y1+1);
  g.Draw(rast,x2-1,y2);
  g.Draw(rast,x1+1,y2);
END DrawClearBorder;

PROCEDURE CheckPaletteGadget*(pal:l.Node;VAR class:LONGSET;code:INTEGER;address:s.ADDRESS):BOOLEAN;

VAR ret    : BOOLEAN;
    oldcol,
    x,y    : INTEGER;

PROCEDURE MouseSelect;

VAR x,y,oldcol,
    xpos,ypos,
    x2,y2,
    savecol    : INTEGER;
    first      : BOOLEAN;

BEGIN
  WITH pal: PaletteGadget DO
    first:=TRUE;
    savecol:=pal.actcol;
    LOOP
      IF NOT(first) THEN
        e.WaitPort(pal.window.userPort);
      END;
      it.GetIMes(pal.window,class,code,address);
      it.GetMousePos(pal.window,x,y);
      x:=(x-pal.xpos-2) DIV pal.pwidth;
      y:=(y-pal.ypos-1) DIV pal.pheight;
      IF x>pal.xnum-1 THEN
        x:=pal.xnum-1;
      END;
      IF x<0 THEN
        x:=0;
      END;
      IF y>pal.ynum-1 THEN
        y:=pal.ynum-1;
      END;
      IF y<0 THEN
        y:=0;
      END;
      oldcol:=pal.actcol;
      pal.actcol:=y*pal.xnum+x;
      IF I.menuPick IN class THEN
        pal.actcol:=savecol;
        y:=savecol DIV pal.pheight;
        x:=savecol-y*pal.pheight;
      END;
      IF oldcol#pal.actcol THEN
        y2:=oldcol DIV pal.pheight;
        x2:=oldcol-y2*pal.pheight;
        xpos:=pal.xpos+2+pal.pwidth*x2;
        ypos:=pal.ypos+1+pal.pheight*y2;
        DrawClearBorder(pal.rast,xpos,ypos,pal.pwidth+1,pal.pheight+2);
        g.SetAPen(pal.rast,oldcol);
        g.RectFill(pal.rast,xpos+2,ypos+1,xpos+pal.pwidth-2,ypos+pal.pheight);
        xpos:=pal.xpos+2+pal.pwidth*x;
        ypos:=pal.ypos+1+pal.pheight*y;
        g.SetAPen(pal.rast,pal.actcol);
        g.RectFill(pal.rast,xpos+3,ypos+2,xpos+pal.pwidth-3,ypos+pal.pheight-1);
        it.DrawBevelBorderIn(pal.rast,xpos,ypos,pal.pwidth+1,pal.pheight+2);
        g.SetAPen(pal.rast,0);
        g.Move(pal.rast,xpos+2,ypos+1);
        g.Draw(pal.rast,xpos+pal.pwidth-2,ypos+1);
        g.Draw(pal.rast,xpos+pal.pwidth-2,ypos+pal.pheight);
        g.Draw(pal.rast,xpos+2,ypos+pal.pheight);
        g.Draw(pal.rast,xpos+2,ypos+1);
      END;
      first:=FALSE;
      IF (I.mouseButtons IN class) OR (I.menuPick IN class) THEN
        EXIT;
      END;
    END;
  END;
END MouseSelect;

BEGIN
  ret:=FALSE;
  WITH pal: PaletteGadget DO
    oldcol:=pal.actcol;
    IF I.mouseButtons IN class THEN
      IF code=I.selectDown THEN
        it.GetMousePos(pal.window,x,y);
        IF (x>=pal.xpos) AND (x<=pal.xpos+pal.width-1) AND (y>=pal.ypos) AND (y<=pal.ypos+pal.height-1) THEN
          class:=LONGSET{};
          MouseSelect;
          class:=LONGSET{};
        END;
      END;
    END;
    IF oldcol#pal.actcol THEN
      ret:=TRUE;
    END;
  END;
  RETURN ret;
END CheckPaletteGadget;

PROCEDURE RefreshPaletteGadget*(pal:l.Node);

VAR x,y,col,xpos,ypos : INTEGER;

BEGIN
  IF pal#NIL THEN
    WITH pal: PaletteGadget DO
      pal.rast:=pal.window.rPort;
      it.DrawBevelBorder(pal.rast,pal.xpos,pal.ypos,pal.width-1,pal.height);
      col:=-1;
      FOR y:=0 TO pal.ynum-1 DO
        FOR x:=0 TO pal.xnum-1 DO
          INC(col);
          g.SetAPen(pal.rast,col);
          xpos:=pal.xpos+2+pal.pwidth*x;
          ypos:=pal.ypos+1+pal.pheight*y;
          IF col=pal.actcol THEN
            g.RectFill(pal.rast,xpos+3,ypos+2,xpos+pal.pwidth-3,ypos+pal.pheight-1);
            it.DrawBevelBorderIn(pal.rast,xpos,ypos,pal.pwidth+1,pal.pheight+2);
            g.SetAPen(pal.rast,0);
            g.Move(pal.rast,xpos+2,ypos+1);
            g.Draw(pal.rast,xpos+pal.pwidth-2,ypos+1);
            g.Draw(pal.rast,xpos+pal.pwidth-2,ypos+pal.pheight);
            g.Draw(pal.rast,xpos+2,ypos+pal.pheight);
            g.Draw(pal.rast,xpos+2,ypos+1);
          ELSE
            DrawClearBorder(pal.rast,xpos,ypos,pal.pwidth+1,pal.pheight+2);
            g.SetAPen(pal.rast,col);
            g.RectFill(pal.rast,xpos+2,ypos+1,xpos+pal.pwidth-2,ypos+pal.pheight);
          END;
        END;
      END;
      y:=pal.actcol DIV pal.pheight;
      x:=pal.actcol-y;
      xpos:=pal.xpos+2+pal.pwidth*x;
      ypos:=pal.ypos+1+pal.pheight*y;
      it.DrawBevelBorderIn(pal.rast,xpos,ypos,pal.pwidth+1,pal.pheight+2);
    END;
  END;
END RefreshPaletteGadget;

PROCEDURE ActCol*(pal:l.Node):INTEGER;

BEGIN
  IF pal#NIL THEN
    RETURN pal(PaletteGadget).actcol;
  ELSE
    RETURN 0;
  END;
END ActCol;

BEGIN
(*  IF gt.base#NIL THEN
    os2:=TRUE;
  ELSE
    os2:=FALSE;
  END;*)
  os2:=FALSE;
  busy:=FALSE;
END GadgetManager.


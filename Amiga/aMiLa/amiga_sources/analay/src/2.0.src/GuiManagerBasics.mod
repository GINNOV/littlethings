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


MODULE GuiManagerBasics;

(* Update Destruct to ImageGadgets. Also change Root.Resize since
   it calls GadTools.FreeGadgets. *)

(* Note: When calling Root.Destruct the gadgets do not get removed
         from the associated window. So close the window before calling
         Root.Destruct! *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gt : GadTools,
       gd : Gadgets,
       st : Strings,
       rg : RawGadgets,
       it : IntuitionTools,
       gr : GraphicsTools,
       wm : WindowManager,
       l  : LinkedLists,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

TYPE Root * = POINTER TO RootDesc;

     (* General Record for any Object *)
     Object * = POINTER TO ObjectDesc;
     ObjectDesc * = RECORD(l.NodeDesc)
       xpos*,ypos   * ,
       width*,height* ,
       topout*,leftout*: INTEGER;
       autoout      * : BOOLEAN;
       minwi*,minhe * : INTEGER;
       userminwi    *,
       userminhe    * : INTEGER;
       sizex*,sizey * : INTEGER;
       font         * : g.TextAttrPtr;
       subwind      * : wm.SubWindow;
       iwind        * : I.WindowPtr;
       fontx        * : INTEGER;          (* Size of char in x-dir *)
       disabled     * : BOOLEAN;
       root         * : Root;             (* Pointer to root box this object belongs to *)
     END;

     (* The following object just represents a free space. *)
     Space * = POINTER TO SpaceDesc;
     SpaceDesc * = RECORD(ObjectDesc)
       pixels : INTEGER;     (* Use either direct input via pixels or the *)
       fact   : REAL;        (* fact-value to multiply the already existing *)
     END;                    (* space. Set the other to 0. *)

     (* Gadget *)
     Gadget * = POINTER TO GadgetDesc;
     GadgetDesc * = RECORD(ObjectDesc)
       text     * : e.STRPTR;
       alttext  * : POINTER TO ARRAY OF CHAR; (* Alternative text replacing text-entry. *)
       textwi   * : INTEGER;
       color    * : INTEGER;
       gadget   * : I.GadgetPtr;
       shortcut * : CHAR;
     END;

     (* Standard parameters for gadget creation *)
     Standard * = UNTRACED POINTER TO StandardDesc;
     StandardDesc * = RECORD
       leftin*,rightin*,
       topin*,bottomin*: INTEGER;
       outtop*,outleft*: INTEGER;
       textcol      * ,
       hightextcol  * ,
       lightcol     * ,
       shadowcol    * : INTEGER;
       oktext       * ,
       canceltext   * ,
       helptext     * : e.STRPTR;
     END;

     (* Box that contains gadgets and other boxes.
        Either it is a horizontal orientated box (boxorient=horizBox) or a
        vertical orientated box (boxorient=vertBox).
        Set bordertype to any type of DrawBevelBox, or to -1 for no border. *)
TYPE Box * = POINTER TO BoxDesc;
     BoxDesc * = RECORD(ObjectDesc)
       boxorient    * : INTEGER;
       bordertype   * : LONGINT;
       recessed     * : BOOLEAN;
       leftin*,rightin*,
       topin*,bottomin*: INTEGER;
       objectlist   * : l.List;
       title        * : e.STRPTR;
       color        * : INTEGER;
     END;

     (* Basic box in a window *)
     RootDesc * = RECORD(BoxDesc)
       gadgets * : LONGSET;
       ok*,ca*,
       help    * : I.GadgetPtr;
       oksc*,casc*,
       helpsc  * : CHAR;
       vinfo   * : gt.VisualInfo;
       screen  * : I.ScreenPtr;
       glist   * : I.GadgetPtr;
       std     * : Standard;
       sametextwi*: l.List;
       nogadtoolsrefresh * : BOOLEAN;
     END;

     (* Internal stuff *)
     BoxListEl * = RECORD(l.NodeDesc)
       box : l.Node;
     END;

     SameTextWi = RECORD(l.NodeDesc)
       nodelist : l.List;
     END;

     SameTextWiNode = RECORD(l.NodeDesc)
       gad  : Gadget;
     END;

CONST horizBox * = 0; (* Orientation of box *)
      vertBox  * = 1;

      okGad     * = 0; (* Show which gadget in root box ? *)
      cancelGad * = 1;
      helpGad   * = 2;

      stdSizing * = -1;
      noBorder * = -1;
      autoOut * = -1;

      stdIDCMP * = LONGSET{I.menuPick,I.rawKey,I.vanillaKey,I.gadgetDown,I.gadgetUp,I.intuiTicks,I.mouseMove,I.mouseButtons,I.newSize,I.closeWindow,I.idcmpUpdate};

      outOfMem * = 1; (* Errors *)

VAR prev*,glist * : I.GadgetPtr;
    font        * : g.TextAttrPtr;
    tfont       * : g.TextFontPtr;
    fontrast    * : g.RastPortPtr;

    mainsem     * : e.SignalSemaphorePtr;
    error         : INTEGER;
    busy          : BOOLEAN;
    std         * ,
    standard    * : Standard;
    firststring * ,                     (* First and last string gadget to create *)
    laststring  * : Gadget;             (* cycle chain properly. *)
    actroot     * : Root;               (* Root object of currently generated GUI *)
    actbox      * : l.Node;
    actsametextwi : l.Node;
    boxlist       : l.List;

    drawinfo      : I.DrawInfoPtr;
    pens          : UNTRACED POINTER TO ARRAY 9 OF INTEGER;


PROCEDURE StartGui*;

VAR exit : BOOLEAN;

BEGIN
  e.ObtainSemaphore(mainsem^);
  busy:=TRUE;
(*  exit:=FALSE;
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
  UNTIL exit;*)
END StartGui;

PROCEDURE EndGui*;

BEGIN
  busy:=FALSE;
  e.ReleaseSemaphore(mainsem^);
END EndGui;

PROCEDURE SetFont*(ffont:g.TextAttrPtr);

BEGIN
  IF ffont#NIL THEN
    font:=ffont;
    IF tfont#NIL THEN
      gr.CloseFont(tfont);
      tfont:=NIL;
    END;
    tfont:=gr.SetFont(fontrast,font);
  END;
END SetFont;

PROCEDURE CopyStandard*(std1,std2:Standard);

BEGIN
  std2.leftin:=std1.leftin;
  std2.rightin:=std1.rightin;
  std2.topin:=std1.topin;
  std2.bottomin:=std1.bottomin;
  std2.outtop:=std1.outtop;
  std2.outleft:=std1.outleft;
  std2.textcol:=std1.textcol;
  std2.hightextcol:=std1.hightextcol;
  std2.lightcol:=std1.lightcol;
  std2.shadowcol:=std1.shadowcol;
  std2.oktext:=std1.oktext;
  std2.canceltext:=std1.canceltext;
  std2.helptext:=std1.helptext;
END CopyStandard;

PROCEDURE TextLength*(gad:Gadget;text:e.STRPTR):INTEGER;

VAR i   : INTEGER;
    str : ARRAY 2 OF CHAR;

BEGIN
  i:=g.TextLength(fontrast,text^,st.Length(text^));
  IF gad.shortcut#0X THEN
    str[0]:=gad.shortcut;
    str[1]:=0X;
    i:=i-g.TextLength(fontrast,str,st.Length(str));
  END;
  RETURN i;
END TextLength;

PROCEDURE GetShortcut*(string:e.STRPTR):CHAR;

VAR i    : INTEGER;
    char : CHAR;

BEGIN
  char:=0X;
  i:=0;
  WHILE i<st.Length(string^) DO
    IF string[i]="_" THEN
      char:=string[i+1];
      i:=SHORT(st.Length(string^));
    END;
    INC(i);
  END;
  RETURN char;
END GetShortcut;

PROCEDURE (node:Object) UpdateShortcut*;
END UpdateShortcut;

PROCEDURE (gad:Gadget) UpdateShortcut*;

VAR i : INTEGER;

BEGIN
  IF gad.text#NIL THEN
    gad.shortcut:=GetShortcut(gad.text);
  ELSE
    gad.shortcut:=0X;
  END;
END UpdateShortcut;

PROCEDURE (obj:Object) SetOutValues*(topout,leftout:INTEGER);

BEGIN
  IF topout=autoOut THEN
    obj.autoout:=TRUE;
  ELSE
    obj.autoout:=FALSE;
    obj.topout:=topout;
    obj.leftout:=leftout;
  END;
END SetOutValues;

PROCEDURE (obj:Object) SetSizeX*(sizex:INTEGER);

BEGIN
  obj.sizex:=sizex;
END SetSizeX;

PROCEDURE (obj:Object) SetSizeY*(sizey:INTEGER);

BEGIN
  obj.sizey:=sizey;
END SetSizeY;

PROCEDURE (obj:Object) SetSizeXY*(sizex,sizey:INTEGER);

BEGIN
  obj.sizex:=sizex;
  obj.sizey:=sizey;
END SetSizeXY;

PROCEDURE (obj:Object) SetMinVisible*(min:INTEGER);

(* Minimum number of characters to be displayed in x-dir. *)

BEGIN
  obj.userminwi:=fontrast.txWidth*min;
END SetMinVisible;

PROCEDURE (obj:Object) SetMinWidth*(minwi:INTEGER);

BEGIN
  obj.minwi:=minwi;
  obj.userminwi:=minwi;
END SetMinWidth;

PROCEDURE (obj:Object) SetMinHeight*(minhe:INTEGER);

BEGIN
  obj.minhe:=minhe;
  obj.userminhe:=minhe;
END SetMinHeight;

PROCEDURE (obj:Object) SetMinDims*(minwi,minhe:INTEGER);

BEGIN
  obj.minwi:=minwi;
  obj.userminwi:=minwi;
  obj.minhe:=minhe;
  obj.userminhe:=minhe;
END SetMinDims;

(* General stuff for gadgets *)

PROCEDURE (object:Object) Disable*(disabled:BOOLEAN);
END Disable;

PROCEDURE (gad:Gadget) Disable*(disable:BOOLEAN);

(* MUST call gad.Refresh after this if the window is open! *)

VAR long : LONGINT;

BEGIN
  gad.disabled:=disable;
  IF disable THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  IF (gad.gadget#NIL) AND ((gad.iwind#NIL) OR (gt.base.version>=39)) THEN
    gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,I.gaDisabled,long,
                                                u.done);
  END;
END Disable;

PROCEDURE (box:Box) Disable*(disable:BOOLEAN);

VAR node : Object;

BEGIN
  node:=box.objectlist.head(Object);
  WHILE node#NIL DO
    node.Disable(disable);
    node:=node.next(Object);
  END;
END Disable;

PROCEDURE (gad:Gadget) Activate*;

VAR bool : BOOLEAN;

BEGIN
  bool:=I.ActivateGadget(gad.gadget^,gad.iwind,NIL);
END Activate;

PROCEDURE (object:Object) Refresh*;
END Refresh;

PROCEDURE (gad:Gadget) Refresh*;

VAR long : LONGINT;

BEGIN
  IF (gad.iwind#NIL) AND NOT(gad.root.nogadtoolsrefresh) THEN
    I.RefreshGList(gad.gadget,gad.iwind,NIL,1);
  ELSIF gad.root.nogadtoolsrefresh THEN (* Means that this function was called by Root.Resize *)
    IF gad.disabled THEN
      long:=I.LTRUE;
    ELSE
      long:=I.LFALSE;
    END;
    IF gad.gadget#NIL THEN
      gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,I.gaDisabled,long,
                                                  u.done);
    END;
  END;
END Refresh;

PROCEDURE (box:Box) Refresh*;

VAR rast   : g.RastPortPtr;
    x,y,
    width,
    height,
    i      : INTEGER;
    node   : l.Node;

BEGIN
  IF box.iwind#NIL THEN
    rast:=box.iwind.rPort;
    x:=box.xpos;
    y:=box.ypos;
    width:=box.width;
    height:=box.height;
  
    IF box.title#NIL THEN
      g.SetAPen(rast,rast.bgPen);
      g.RectFill(rast,x,y,x+width-1,y+rast.font.ySize-1);
      g.SetAPen(rast,box.color);
      g.Move(rast,x,y+rast.font.baseline);
      g.Text(rast,box.title^,st.Length(box.title^));
      i:=SHORT(SHORT(rast.font.ySize*1.1+0.5));
      y:=y+i;
      height:=height-i;
    END;
    IF box.bordertype#noBorder THEN
      IF box.recessed THEN
        gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                              gt.bbRecessed,I.LTRUE,
                                              gt.visualInfo,box.root.vinfo,
                                              u.done);
      ELSE
        gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                              gt.visualInfo,box.root.vinfo,
                                              u.done);
      END;
    END;
    node:=box.objectlist.head;
    WHILE node#NIL DO
      node(Object).Refresh;
      node:=node.next;
    END;
  END;
END Refresh;

(* Init is for preparing objects. No gadgets are created properly. *)

PROCEDURE (object:Object) Init*;

BEGIN
  IF object.userminwi>object.minwi THEN
    object.minwi:=object.userminwi;
    IF object.minwi>object.width THEN
      object.width:=object.minwi;
    END;
  END;
  IF object.userminhe>object.minhe THEN
    object.minhe:=object.userminhe;
    IF object.minhe>object.height THEN
      object.height:=object.minhe;
    END;
  END;
END Init;

(* Resize is for adapting an object to a new size. You have to provide the
   sizes in the object record. If the object is a gadget it will be created,
   border will be drawn.
   Use ResizeRoot to resize the Gui of a window. *)

PROCEDURE (object:Object) Resize*;
END Resize;

PROCEDURE (box:Box) Init*;

VAR width,height,
    topout,leftout,
    i              : INTEGER;
    node,node2     : l.Node;

BEGIN
  IF box.bordertype=noBorder THEN
    topout:=SHORT(SHORT(tfont.ySize/8+0.5));
    leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  ELSE
    topout:=SHORT(SHORT(tfont.ySize/3+0.5));
    leftout:=SHORT(SHORT(tfont.ySize/1.5+0.5));
  END;

(* Initializing *)

  node:=box.objectlist.head;
  WHILE node#NIL DO
    WITH node: Object DO
      node.Init;

(* If the previous object was a box with a border the distance to this box
   must be greater than normal. *)

      IF (node.autoout) AND (node.prev#NIL) THEN
        IF node.prev IS Box THEN
          IF node.prev(Box).bordertype#noBorder THEN
            IF box.boxorient=vertBox THEN
              node.topout:=SHORT(SHORT(tfont.ySize/3+0.5));
            ELSIF box.boxorient=horizBox THEN
              node.leftout:=SHORT(SHORT(tfont.ySize/1.5+0.5));
            END;
          END;
        END;
      END;

      IF box.boxorient=vertBox THEN
        IF node.width>width THEN
          width:=node.width;
        END;
        height:=height+node.height;
        IF node#box.objectlist.head THEN
          height:=height+node.topout;
        END;
        IF node.leftout>leftout THEN
          leftout:=node.leftout;
        END;
      ELSIF box.boxorient=horizBox THEN
        IF node.height>height THEN
          height:=node.height;
        END;
        width:=width+node.width;
        IF node#box.objectlist.head THEN
          width:=width+node.leftout;
        END;
        IF node.topout>topout THEN
          topout:=node.topout;
        END;
      END;
      IF node.sizex>box.sizex THEN
        box.sizex:=node.sizex;
      END;
      IF node.sizey>box.sizey THEN
        box.sizey:=node.sizey;
      END;
    END;
    node:=node.next;
  END;
  IF box.title#NIL THEN
    height:=height+SHORT(SHORT(tfont.ySize*1.1+0.5));
  END;
  IF box.bordertype#noBorder THEN
    width:=width+box.leftin+box.rightin;
    height:=height+box.topin+box.bottomin;
  END;
  box.width:=width;
  box.height:=height;
  box.minwi:=width;
  box.minhe:=height;
  IF box.title#NIL THEN
    i:=g.TextLength(fontrast,box.title^,st.Length(box.title^));
    IF i>box.width THEN
      box.width:=i;
    END;
  END;
  IF box.autoout THEN
    box.topout:=topout;
    box.leftout:=leftout;
  END;
END Init;

PROCEDURE (object:Object) SetTextWidth;
END SetTextWidth;

PROCEDURE (gad:Gadget) SetTextWidth;

BEGIN
  IF gad.text#NIL THEN
    gad.textwi:=TextLength(gad,gad.text)+g.TextLength(fontrast," ",1);
  ELSE gad.textwi:=0;
  END;
END SetTextWidth;

PROCEDURE (box:Box) SetTextWidth;

VAR node : l.Node;

BEGIN
  node:=box.objectlist.head;
  WHILE node#NIL DO
    node(Object).SetTextWidth;
    node:=node.next;
  END;
END SetTextWidth;

PROCEDURE (root:Root) Init*;

VAR node,node2 : l.Node;
    minwi,minhe,
    width      : INTEGER;
    str        : ARRAY 2 OF CHAR;

BEGIN
  minwi:=0;
  minhe:=0;
  StartGui;
  std:=root.std;
  font:=root.font;
  IF tfont#NIL THEN
    gr.CloseFont(tfont);
    tfont:=NIL;
  END;
  tfont:=gr.SetFont(fontrast,font);
  root.SetTextWidth;

(* Same text width *)

  WITH root: Root DO
    node:=root.sametextwi.head;
    WHILE node#NIL DO
      width:=0;
      node2:=node(SameTextWi).nodelist.head;
      WHILE node2#NIL DO
        IF node2(SameTextWiNode).gad.textwi>width THEN
          width:=node2(SameTextWiNode).gad.textwi;
        END;
        node2:=node2.next;
      END;
      node2:=node(SameTextWi).nodelist.head;
      WHILE node2#NIL DO
        node2(SameTextWiNode).gad.textwi:=width;
        node2:=node2.next;
      END;
      node:=node.next;
    END;
  END;

  root.Init^;
  width:=0;
  IF okGad IN root.gadgets THEN
    width:=g.TextLength(fontrast,std.oktext^,st.Length(std.oktext^))+8;
    IF root.oksc#0X THEN
      str[0]:=root.oksc;
      str[1]:=0X;
      width:=width-g.TextLength(fontrast,str,st.Length(str));
    END;
  END;
  IF cancelGad IN root.gadgets THEN
    width:=width+g.TextLength(fontrast,std.canceltext^,st.Length(std.canceltext^))+8+SHORT(SHORT(tfont.ySize/2+0.5));
    IF root.casc#0X THEN
      str[0]:=root.casc;
      str[1]:=0X;
      width:=width-g.TextLength(fontrast,str,st.Length(str));
    END;
  END;
  IF helpGad IN root.gadgets THEN
    width:=width+g.TextLength(fontrast,std.helptext^,st.Length(std.helptext^))+8+SHORT(SHORT(tfont.ySize/2+0.5));
    IF root.helpsc#0X THEN
      str[0]:=root.helpsc;
      str[1]:=0X;
      width:=width-g.TextLength(fontrast,str,st.Length(str));
    END;
  END;
  IF width>root.minwi THEN
    root.minwi:=width;
  END;
  minwi:=root.minwi;
  minhe:=root.minhe;
  IF root.autoout THEN
    minwi:=minwi+tfont.ySize*2;
    minhe:=minhe+tfont.ySize;
  END;
  IF root.gadgets#LONGSET{} THEN
    minhe:=minhe+(tfont.ySize+6)+SHORT(SHORT(tfont.ySize/3+0.5));
  END;
  EndGui;
  root.subwind.SetMinMax(minwi,minhe,-1,-1);
END Init;

PROCEDURE (box:Box) Resize*;

VAR addwi,addhe,size,
    availx,availy,i,
    width,height,x,y,
    numsize          : INTEGER;
    node             : l.Node;
    rast             : g.RastPortPtr;

BEGIN
  IF box.root#NIL THEN         (* Maybe box is RootBox *)
    box.iwind:=box.root.iwind;
  END;
  rast:=box.iwind.rPort;

(* Drawing area *)

  x:=box.xpos;
  y:=box.ypos;
  width:=box.width;
  height:=box.height;

(* Drawing box *)

  IF box.title#NIL THEN
(*    g.SetAPen(rast,box.color);
    g.Move(rast,x,y+tfont.baseline);
    g.Text(rast,box.title^,st.Length(box.title^));*)
    i:=SHORT(SHORT(tfont.ySize*1.1+0.5));
    y:=y+i;
    height:=height-i;
  END;
  IF box.bordertype#noBorder THEN
(*    IF box.recessed THEN
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                            gt.bbRecessed,I.LTRUE,
                                            gt.visualInfo,box.root.vinfo,
                                            u.done);
    ELSE
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                            gt.visualInfo,box.root.vinfo,
                                            u.done);
    END;*)
    x:=x+box.leftin;
    y:=y+box.topin;
    width:=width-box.leftin-box.rightin;
    height:=height-box.topin-box.bottomin;
  END;

(* Alternating box sizes *)

  IF box.width>box.minwi THEN
    addwi:=box.width-box.minwi;
  END;
  IF box.height>box.minhe THEN
    addhe:=box.height-box.minhe;
  END;
  availx:=addwi;
  availy:=addhe;
  size:=0;
  IF box.boxorient=vertBox THEN
    numsize:=0;
    node:=box.objectlist.head;
    WHILE node#NIL DO
      IF node(Object).sizey>=0 THEN
        size:=size+node(Object).sizey;
        INC(numsize);
      END;
      node(Object).width:=node(Object).minwi;
      node(Object).height:=node(Object).minhe;
      node:=node.next;
    END;
    IF numsize=0 THEN
      numsize:=SHORT(box.objectlist.nbElements());
    END;
    node:=box.objectlist.head;
    WHILE node#NIL DO
      IF node(Object).sizex>=0 THEN
        node(Object).width:=width;
      END;
      IF size>0 THEN
        i:=SHORT(SHORT(addhe/size*node(Object).sizey+0.5));
      ELSE
        i:=SHORT(SHORT(addhe/numsize+0.5));
      END;
      IF node(Object).sizey=-1 THEN
        i:=0;
      END;
      IF i>availy THEN
        i:=availy;
        availy:=0;
      ELSE
        availy:=availy-i;
      END;
      IF (node.next=NIL) AND (node(Object).sizey>=0) THEN
        i:=i+availy;
      END;
      node(Object).height:=node(Object).height+i;
      node:=node.next;
    END;
  ELSIF box.boxorient=horizBox THEN
    numsize:=0;
    node:=box.objectlist.head;
    WHILE node#NIL DO
      IF node(Object).sizex>=0 THEN
        size:=size+node(Object).sizex;
        INC(numsize);
      END;
      node(Object).width:=node(Object).minwi;
      node(Object).height:=node(Object).minhe;
      node:=node.next;
    END;
    IF numsize=0 THEN
      numsize:=SHORT(box.objectlist.nbElements());
    END;
    node:=box.objectlist.head;
    WHILE node#NIL DO
      IF node(Object).sizey>=0 THEN
        node(Object).height:=height;
      END;
      IF size>0 THEN
        i:=SHORT(SHORT(addwi/size*node(Object).sizex+0.5));
      ELSE
        i:=SHORT(SHORT(addwi/numsize+0.5));
      END;
      IF node(Object).sizex=-1 THEN
        i:=0;
      END;
      IF i>availx THEN
        i:=availx;
        availx:=0;
      ELSE
        availx:=availx-i;
      END;
      IF (node.next=NIL) AND (node(Object).sizex>=0) THEN
        i:=i+availx;
      END;
      node(Object).width:=node(Object).width+i;
      node:=node.next;
    END;
  END;

(* Resizing objects *)

  node:=box.objectlist.head;
  WHILE node#NIL DO
    WITH node: Object DO
      IF node#box.objectlist.head THEN
        IF box.boxorient=vertBox THEN
          y:=y+node.topout;
        ELSIF box.boxorient=horizBox THEN
          x:=x+node.leftout;
        END;
      END;
      node.xpos:=x;
      node.ypos:=y;
      node.Resize;
(*      node.Disable(node.disabled);*)
      IF box.boxorient=vertBox THEN
        y:=y+node.height;
      ELSIF box.boxorient=horizBox THEN
        x:=x+node.width;
      END;
    END;
    node:=node.next;
  END;
END Resize;

PROCEDURE (root:Root) Resize*;

VAR x,y,
    width,
    height,
    i,dx,addwi,
    fillwi,
    maxwi,
    minokwi,
    mincawi,
    minhelpwi : INTEGER;
    node      : l.Node;
    str       : ARRAY 2 OF CHAR;
    wind      : I.WindowPtr;
    oldglist  : I.GadgetPtr;

(*PROCEDURE RefreshListView(list:l.List);

VAR node : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    IF node IS ListView THEN
      node(ListView).Refresh;
    ELSIF node IS Box THEN
      RefreshListView(node(Box).objectlist);
    END;
    node:=node.next;
  END;
END RefreshListView;*)

BEGIN
  StartGui;

(* Removing old gadgets from window *)
  oldglist:=root.glist;
  IF root.glist#NIL THEN
    root.subwind.RemoveGadgets;
    (* If root.glist#NIL, the gadgets should always be connected to
       a window, maybe via subwind.Open(glist). *)
(*    IF root.iwind=NIL THEN
      root.iwind:=root.subwind.GetWindow();
    END;
    IF root.iwind#NIL THEN
      subwind.RemoveGadgets;
      i:=I.RemoveGList(root.iwind,root.glist,-1);
      (* FreeGadgets comes below! *)
    ELSE
    END;*)
  END;

(* Creating new gadgets *)
  root.iwind:=root.subwind.GetWindow();
  IF root.iwind#NIL THEN
    wind:=root.iwind;
    std:=root.std;
    font:=root.font;
    IF tfont#NIL THEN
      gr.CloseFont(tfont);
      tfont:=NIL;
    END;
    root.subwind.SetFontAttr(font);
    tfont:=gr.SetFont(fontrast,font);
    glist:=NIL;
    IF root.vinfo#NIL THEN
      gt.FreeVisualInfo(root.vinfo);
      root.vinfo:=NIL;
    END;
    root.vinfo:=rg.StartGadgets(wind.wScreen,font);
(*    rg.StartGadgetsAgain(wind.wScreen,font,root.vinfo);*)
    prev:=gt.CreateContext(glist);
    x:=wind.borderLeft+tfont.ySize;
    y:=wind.borderTop+(tfont.ySize DIV 2);
    width:=wind.width-wind.borderLeft-wind.borderRight-tfont.ySize*2;
    height:=wind.height-wind.borderTop-wind.borderBottom-tfont.ySize;
  
  (* Check for standard gadgets *)
  
    IF root.gadgets#LONGSET{} THEN
      height:=height-(tfont.ySize+6)-SHORT(SHORT(tfont.ySize/3+0.5));
      minokwi:=0;
      mincawi:=0;
      minhelpwi:=0;
      IF okGad IN root.gadgets THEN
        minokwi:=g.TextLength(fontrast,std.oktext^,st.Length(std.oktext^))+8;
        IF root.oksc#0X THEN
          str[0]:=root.oksc;
          str[1]:=0X;
          minokwi:=minokwi-g.TextLength(fontrast,str,st.Length(str));
        END;
      END;
      IF helpGad IN root.gadgets THEN
        minhelpwi:=g.TextLength(fontrast,std.helptext^,st.Length(std.helptext^))+8;
        IF root.helpsc#0X THEN
          str[0]:=root.helpsc;
          str[1]:=0X;
          minhelpwi:=minhelpwi-g.TextLength(fontrast,str,st.Length(str));
        END;
      END;
      IF cancelGad IN root.gadgets THEN
        mincawi:=g.TextLength(fontrast,std.canceltext^,st.Length(std.canceltext^))+8;
        IF root.casc#0X THEN
          str[0]:=root.casc;
          str[1]:=0X;
          mincawi:=mincawi-g.TextLength(fontrast,str,st.Length(str));
        END;
      END;
      dx:=SHORT(SHORT(tfont.ySize/2+0.5));
      addwi:=width-(minokwi+mincawi+minhelpwi+2*dx);
      IF addwi>0 THEN
        maxwi:=mincawi;
        IF minhelpwi>maxwi THEN
          maxwi:=minhelpwi;
        END;
        IF minokwi>maxwi THEN
          maxwi:=minokwi;
        END;
        IF minokwi<maxwi THEN
          i:=maxwi-minokwi;
          IF i>addwi THEN
            i:=addwi;
          END;
          minokwi:=minokwi+i;
          addwi:=addwi-i;
        END;
        IF minhelpwi<maxwi THEN
          i:=maxwi-minhelpwi;
          IF i>addwi THEN
            i:=addwi;
          END;
          minhelpwi:=minhelpwi+i;
          addwi:=addwi-i;
        END;
        fillwi:=addwi DIV 10;
        minokwi:=minokwi+fillwi;
        minhelpwi:=minhelpwi+fillwi;
        mincawi:=mincawi+fillwi;
      END;
      y:=wind.height-wind.borderBottom-(tfont.ySize DIV 2)-(tfont.ySize+6);
      IF okGad IN root.gadgets THEN
        root.ok:=rg.SetBooleanGadget(x,y,minokwi,tfont.ySize+6,std.oktext,prev);
        x:=x+minokwi+dx;
      END;
      IF helpGad IN root.gadgets THEN
        root.help:=rg.SetBooleanGadget(x,y,minhelpwi,tfont.ySize+6,std.helptext,prev);
      END;
      IF cancelGad IN root.gadgets THEN
        x:=wind.width-wind.borderRight-tfont.ySize-mincawi;
        root.ca:=rg.SetBooleanGadget(x,y,mincawi,tfont.ySize+6,std.canceltext,prev);
      END;
  
      x:=wind.borderLeft+tfont.ySize;
      y:=wind.borderTop+(tfont.ySize DIV 2);
    END;

    IF ~root.autoout THEN
      x:=wind.borderLeft+root.leftout;
      width:=wind.width-wind.borderLeft-wind.borderRight+root.leftout*2;
      y:=wind.borderTop+root.topout;
      height:=wind.height-wind.borderTop-wind.borderBottom+root.topout*2;
    END;
    root.xpos:=x;
    root.ypos:=y;
    root.width:=width;
    root.height:=height;

    root.Resize^;
    root.glist:=glist;
    g.SetAPen(root.iwind.rPort,0);
    g.RectFill(root.iwind.rPort,wind.borderLeft,wind.borderTop,wind.width-wind.borderRight-1,wind.height-wind.borderBottom-1);
    root.subwind.SetGadgets(glist);
(*    i:=I.AddGList(wind,glist,-1,-1,NIL);*)
    I.RefreshWindowFrame(wind);
    gt.RefreshWindow(wind,NIL);
    root.nogadtoolsrefresh:=TRUE;
    root.Refresh;
    root.nogadtoolsrefresh:=FALSE;
    rg.EndGadgets;
    IF oldglist#NIL THEN gt.FreeGadgets(oldglist); END;
  ELSE
(*    root.glist:=NIL;*)
  END;
(*  root.Disable(root.disabled,NIL);*)
(*  IF root.ok#NIL THEN
    I.RefreshGList(root.ok,wind,NIL,1);
  END;
  IF root.help#NIL THEN
    I.RefreshGList(root.help,wind,NIL,1);
  END;
  IF root.ca#NIL THEN
    I.RefreshGList(root.ca,wind,NIL,1);
  END;*)
  EndGui;
END Resize;

PROCEDURE AddObject*(object:l.Node);

BEGIN
  IF actbox#NIL THEN
    actbox(BoxListEl).box(Box).objectlist.AddTail(object);
  END;
END AddObject;

(* Additional procedures to work with existing gadgets *)

(* Standard-procedure to change a gadget and check the state *)

PROCEDURE (gad:Gadget) SetValue*(active:LONGINT);
END SetValue;

PROCEDURE (gad:Gadget) GetValue*():LONGINT;
END GetValue;

(* Special procedures *)

PROCEDURE (obj:Object) SetText*(string:e.STRPTR);
END SetText;

PROCEDURE (box:Box) SetText*(string:e.STRPTR);

BEGIN
  box.title:=string;
END SetText;

PROCEDURE (obj:Object) SetString*(string:ARRAY OF CHAR);
END SetString;

PROCEDURE (obj:Object) GetString*(VAR string:ARRAY OF CHAR);
END GetString;

PROCEDURE (obj:Gadget) SetText*(string:e.STRPTR);

BEGIN
  obj.text:=string;
END SetText;

PROCEDURE PressBoolean*(gad:I.GadgetPtr;wind:I.WindowPtr);

BEGIN
  INCL(gad.activation,I.toggleSelect);
  INCL(gad.flags,I.selected);
  I.RefreshGList(gad,wind,NIL,1);
  d.Delay(3);
  EXCL(gad.flags,I.selected);
  EXCL(gad.activation,I.toggleSelect);
  I.RefreshGList(gad,wind,NIL,1);
END PressBoolean;

PROCEDURE (gad:Gadget) KeyboardAction*;
END KeyboardAction;

PROCEDURE (object:Gadget) Destruct*;

BEGIN
  object.Destruct^;
END Destruct;

PROCEDURE (object:Box) Destruct*;

VAR node,next : l.Node;

BEGIN
  node:=object.objectlist.head;
  WHILE node#NIL DO
    next:=node.next;
    node.Destruct;
    node:=next;
  END;
  (* $IFNOT GarbageCollector *)
    DISPOSE(object.objectlist);
  (* $END *)
  object.Destruct^;
END Destruct;

PROCEDURE (object:Root) Destruct*;

VAR node,node2,next : l.Node;

BEGIN
  (* $IFNOT GarbageCollector *)
    node:=object.sametextwi.head;
    WHILE node#NIL DO
      node2:=node(SameTextWi).nodelist.head;
      WHILE node2#NIL DO
        next:=node2.next;
        node2.Destruct;
        node2:=next;
      END;
      node(SameTextWi).nodelist.Destruct;
      next:=node.next;
      node.Destruct;
      node:=next;
    END;
    DISPOSE(object.sametextwi);

    DISPOSE(object.std);
  (* $END *)
  IF object.glist#NIL THEN
    gt.FreeGadgets(object.glist);
  END;
  IF object.vinfo#NIL THEN
    gt.FreeVisualInfo(object.vinfo);
  END;
  object.Destruct^;
END Destruct;



(* Procedures to initialze boxes *)

PROCEDURE SetRootBox*(boxorient:INTEGER;bordertype:LONGINT;recessed:BOOLEAN;title:e.STRPTR;gadgets:LONGSET;subwind:wm.SubWindow):Root;

VAR vi   : gt.VisualInfo;
    root,
    node : l.Node;

BEGIN
  StartGui;
  firststring:=NIL;
  laststring:=NIL;
  root:=NIL;
  vi:=NIL;
  font:=subwind.GetFontAttr();
  IF tfont#NIL THEN
    gr.CloseFont(tfont);
    tfont:=NIL;
  END;
  tfont:=gr.SetFont(fontrast,font);
  vi:=rg.StartGadgets(subwind.GetScreen(),font);
  IF vi#NIL THEN
    NEW(root(Root));
    WITH root: Root DO
      NEW(root.std);
      CopyStandard(standard,root.std);
      std:=root.std;
      drawinfo:=I.GetScreenDrawInfo(subwind.GetScreen());
      pens:=drawinfo.pens;
      std.textcol:=pens[I.textPen];
      std.hightextcol:=pens[I.highLightTextPen];
      std.lightcol:=pens[I.shinePen];
      std.shadowcol:=pens[I.shadowPen];
      I.FreeScreenDrawInfo(subwind.GetScreen(),drawinfo);
      root.gadgets:=gadgets;
      root.boxorient:=boxorient;
      root.bordertype:=bordertype;
      root.recessed:=recessed;
      root.objectlist:=l.Create();
      root.sametextwi:=l.Create();
      root.title:=title;
      root.leftin:=std.leftin;
      root.rightin:=std.rightin;
      root.topin:=std.topin;
      root.bottomin:=std.bottomin;
      root.leftout:=autoOut;
      root.topout:=autoOut;
      root.vinfo:=vi;
      root.screen:=subwind.GetScreen();
      root.font:=subwind.GetFontAttr();
      root.fontx:=fontrast.txWidth;
      IF root.fontx<=0 THEN root.fontx:=fontrast.txHeight; END;
      IF root.fontx>fontrast.txHeight THEN root.fontx:=fontrast.txHeight; END;
      IF root.fontx>10 THEN root.fontx:=10; END;
      root.color:=std.hightextcol;
      root.autoout:=TRUE;   (* Either set this to true here, or don't check for root.topout=autoOut, but for root.autoout in root.Init and root.Resize. *)
      root.subwind:=subwind;
      root.iwind:=subwind.GetWindow();
      root.root:=root;                  (* Makes things easier when a Box-method *)
                                        (* is used with a Root-Object. *)
    END;
    boxlist.Init;
    NEW(node(BoxListEl));
    node(BoxListEl).box:=root;
    boxlist.AddTail(node);
    actbox:=node;
    prev:=NIL;
    glist:=NIL;
    prev:=gt.CreateContext(glist);
    IF prev=NIL THEN
      (* $IFNOT GarbageCollector *)
        DISPOSE(root(Root));
      (* $END *)
      root:=NIL;
      rg.EndGadgets();
      gt.FreeVisualInfo(vi);
    ELSE
      root(Root).oksc:=0X;
      root(Root).casc:=0X;
      root(Root).helpsc:=0X;
      IF okGad IN gadgets THEN
        root(Root).ok:=rg.SetBooleanGadget(-20,-20,10,10,std.oktext,prev);
        root(Root).oksc:=GetShortcut(std.oktext);
      END;
      IF cancelGad IN gadgets THEN
        root(Root).ca:=rg.SetBooleanGadget(-20,-20,10,10,std.canceltext,prev);
        root(Root).casc:=GetShortcut(std.canceltext);
      END;
      IF helpGad IN gadgets THEN
        root(Root).help:=rg.SetBooleanGadget(-20,-20,10,10,std.helptext,prev);
        root(Root).helpsc:=GetShortcut(std.helptext);
      END;
    END;
  END;
  IF root#NIL THEN
    actroot:=root(Root);
    RETURN root(Root);
  ELSE
    RETURN NIL;
  END;
END SetRootBox;

PROCEDURE (root:Root) EndRoot*():I.GadgetPtr;

VAR node : l.Node;

BEGIN
  IF actbox#NIL THEN
    node:=actbox.prev;
    actbox.Remove;

    (* $IFNOT GarbageCollector *)
      DISPOSE(actbox(BoxListEl));
    (* $END *)

    IF node#NIL THEN
      actbox:=node;
    END;
  END;
  root.glist:=glist;
  rg.EndGadgets;
  EndGui;
  RETURN glist;
END EndRoot;

PROCEDURE NewBox*(boxorient:INTEGER;bordertype:LONGINT;recessed:BOOLEAN;title:e.STRPTR):Box;

VAR box,node : l.Node;

BEGIN
  box:=NIL;
  NEW(box(Box));
  IF box#NIL THEN
    AddObject(box);
    NEW(node(BoxListEl));
    node(BoxListEl).box:=box;
    boxlist.AddTail(node);
    actbox:=node;

    WITH box: Box DO
      box.boxorient:=boxorient;
      box.bordertype:=bordertype;
      box.recessed:=recessed;
      box.title:=title;
      box.leftin:=std.leftin;
      box.rightin:=std.rightin;
      box.topin:=std.topin;
      box.bottomin:=std.bottomin;
      box.objectlist:=l.Create();
      box.font:=actroot.font;
      box.sizex:=-1;
      box.sizey:=-1;
      box.color:=std.hightextcol;
      box.autoout:=TRUE;
      box.root:=actroot;
      box.iwind:=NIL;
      box.subwind:=box.root.subwind;
    END;
  ELSE
    error:=outOfMem;
  END;
  RETURN box(Box);
END NewBox;

PROCEDURE EndBox*;

VAR node : l.Node;

BEGIN
  IF actbox#NIL THEN
    node:=actbox.prev;
    actbox.Remove;

    (* $IFNOT GarbageCollector *)
      DISPOSE(actbox(BoxListEl));
    (* $END *)
    IF node#NIL THEN
      actbox:=node;
    END;
  END;
END EndBox;

PROCEDURE FillSpace*;

VAR gadobj : Object;

BEGIN
  gadobj:=NewBox(horizBox,noBorder,FALSE,NIL);
  EndBox;
  gadobj.SetSizeXY(1000,1000);
END FillSpace;

PROCEDURE (root:Root) NewSameTextWidth*;

VAR node : l.Node;

BEGIN
  NEW(node(SameTextWi));
  node(SameTextWi).nodelist:=l.Create();
  root(Root).sametextwi.AddTail(node);
END NewSameTextWidth;

PROCEDURE (root:Root) AddSameTextWidth*(gad:Gadget);

VAR node : l.Node;

BEGIN
  IF root.sametextwi.tail#NIL THEN
    NEW(node(SameTextWiNode));
    node(SameTextWiNode).gad:=gad;
    root.sametextwi.tail(SameTextWi).nodelist.AddTail(node);
  END;
END AddSameTextWidth;



PROCEDURE (obj:Object) InputEvent*(mes:I.IntuiMessagePtr);
END InputEvent;

PROCEDURE (box:Box) InputEvent*(mes:I.IntuiMessagePtr);

VAR node : l.Node;

BEGIN
  node:=box.objectlist.head;
  WHILE node#NIL DO
    node(Object).InputEvent(mes);
    node:=node.next;
  END;
END InputEvent;

PROCEDURE (root:Root) InputEvent*(mes:I.IntuiMessagePtr);

VAR wind  : I.WindowPtr;
    check : BOOLEAN;

BEGIN
  wind:=root.iwind;
  IF I.newSize IN mes.class THEN
    root.Resize;
  ELSE
    check:=TRUE;
    IF I.vanillaKey IN mes.class THEN
      IF (root(Root).oksc#0X) AND (st.CapIntl(CHR(mes.code))=st.CapIntl(root(Root).oksc)) THEN
        PressBoolean(root(Root).ok,wind);
        mes.class:=LONGSET{I.gadgetUp};
        mes.code:=0;
        mes.iAddress:=root(Root).ok;
        check:=FALSE;
      ELSIF (root(Root).casc#0X) AND (st.CapIntl(CHR(mes.code))=st.CapIntl(root(Root).casc)) THEN
        PressBoolean(root(Root).ca,wind);
        mes.class:=LONGSET{I.gadgetUp};
        mes.code:=0;
        mes.iAddress:=root(Root).ca;
        check:=FALSE;
      ELSIF (root(Root).helpsc#0X) AND (st.CapIntl(CHR(mes.code))=st.CapIntl(root(Root).helpsc)) THEN
        PressBoolean(root(Root).help,wind);
        mes.class:=LONGSET{I.gadgetUp};
        mes.code:=0;
        mes.iAddress:=root(Root).help;
        check:=FALSE;
      END;
    ELSIF (I.rawKey IN mes.class) OR (I.gadgetUp IN mes.class) THEN
      IF (helpGad IN root(Root).gadgets) AND (root(Root).help#NIL) THEN
        IF mes.code=95 THEN
          PressBoolean(root(Root).help,wind);
          mes.class:=LONGSET{I.gadgetUp};
          mes.code:=0;
          mes.iAddress:=root(Root).help;
          check:=FALSE;
        END;
      END;
    END;
    IF check THEN
      root.InputEvent^(mes);
    END;
  END;
END InputEvent;

PROCEDURE (gad:Gadget) InputEvent*(mes:I.IntuiMessagePtr);

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.SetValue(mes.code);
    END;
  ELSIF I.gadgetDown IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.SetValue(mes.code);
    END;
  ELSIF I.vanillaKey IN mes.class THEN
    IF (gad.shortcut#0X) AND (st.CapIntl(CHR(mes.code))=st.CapIntl(gad.shortcut)) THEN
      gad.KeyboardAction;
      mes.iAddress:=gad.gadget;
      mes.class:=LONGSET{I.gadgetUp};
      mes.code:=0;
    END;
  END;
END InputEvent;

PROCEDURE (root:Root) GetIMes*(mes:I.IntuiMessagePtr);

VAR message : I.IntuiMessagePtr;

BEGIN
  IF root.iwind#NIL THEN
    message:=gt.GetIMsg(root.iwind.userPort);
    IF message#NIL THEN
      e.CopyMemAPTR(message,mes,s.SIZE(I.IntuiMessage));
      gt.ReplyIMsg(message);
  
      root.InputEvent(mes);
    ELSE
      mes.class:=LONGSET{};
      mes.code:=0;
      mes.iAddress:=NIL;
    END;
  ELSE
    mes.class:=LONGSET{};
    mes.code:=0;
    mes.iAddress:=NIL;
  END;
END GetIMes;

PROCEDURE DrawBevelBox*(screen:I.ScreenPtr;rast:g.RastPortPtr;x,y,width,height:INTEGER;recessed:BOOLEAN);

VAR vinfo : gt.VisualInfo;

BEGIN
  vinfo:=NIL;
  vinfo:=gt.GetVisualInfo(screen,u.done);
  IF vinfo#NIL THEN
    IF recessed THEN
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,gt.bbftButton,
                                            gt.bbRecessed,I.LTRUE,
                                            gt.visualInfo,vinfo,
                                            u.done);
    ELSE
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,gt.bbftButton,
                                            gt.visualInfo,vinfo,
                                            u.done);
    END;
    gt.FreeVisualInfo(vinfo);
  END;
END DrawBevelBox;

BEGIN
  mainsem:=NIL;
  NEW(mainsem); e.InitSemaphore(mainsem^);

  boxlist:=NIL;
  boxlist:=l.Create();
  NEW(standard);
  standard.leftin:=6;
  standard.rightin:=6;
  standard.topin:=3;
  standard.bottomin:=3;
  standard.textcol:=1;
  standard.hightextcol:=2;
  standard.lightcol:=2;
  standard.shadowcol:=1;
  standard.oktext:=s.ADR("_OK");
  standard.canceltext:=s.ADR("_Cancel");
  standard.helptext:=s.ADR("Help");
  fontrast:=NIL;
  fontrast:=it.AllocRastPort(32,10,1);
  tfont:=NIL;
CLOSE
  (* $IFNOT GarbageCollector *)
    IF boxlist#NIL THEN
      DISPOSE(boxlist);
    END;
    IF standard#NIL THEN
      DISPOSE(standard);
    END;
  (* $END *)
  IF fontrast#NIL THEN
    it.FreeRastPort(fontrast);
  END;
  IF tfont#NIL THEN
    gr.CloseFont(tfont);
  END;
  IF mainsem#NIL THEN DISPOSE(mainsem); END;
END GuiManagerBasics.


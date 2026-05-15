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


MODULE GuiManager;

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
       l  : LinkedLists,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

TYPE RootPtr * = POINTER TO Root;

     (* General Record for any Object *)
     ObjectPtr * = POINTER TO Object;
     Object * = RECORD(l.NodeDesc)
       xpos-,ypos   - ,
       width-,height- ,
       topout-,leftout-: INTEGER;
       autoout      * : BOOLEAN;
       font         * : g.TextAttrPtr;
       xSize          : INTEGER;
       minwi*,minhe * : INTEGER;
       sizex*,sizey * : INTEGER;
       rast           : g.RastPortPtr;
       window         : I.WindowPtr;
       color        * : INTEGER;
       disabled     - : BOOLEAN;
       root           : RootPtr;          (* Pointer to root box this object belongs to *)
     END;

     (* The following object just represents a free space. *)
     SpacePtr * = POINTER TO Space;
     Space * = RECORD(Object)
       pixels : INTEGER;     (* Use either direct input via pixels or the *)
       fact   : REAL;        (* fact-value to multiply the already existing *)
     END;                    (* space. Set the other to 0. *)

     (* Text *)
     TextPtr * = POINTER TO Text;
     Text * = RECORD(Object)
       text * : e.STRPTR;
     END;

     (* Gadget *)
     GadgetPtr * = POINTER TO Gadget;
     Gadget * = RECORD(Object)
       text       : e.STRPTR;
       textwi     : INTEGER;
       gadget   - : I.GadgetPtr;
       shortcut - : CHAR;
     END;

     (* BooleanGadget *)
     BooleanGadgetPtr * = POINTER TO BooleanGadget;
     BooleanGadget * = RECORD(Gadget)
       toggle   - ,
       selected - : BOOLEAN;
     END;

     (* StringGadget *)
     StringGadgetPtr * = POINTER TO StringGadget;
     StringGadget * = RECORD(Gadget)
       string   - : POINTER TO ARRAY OF CHAR;
       maxchars - ,
       minvisible-: INTEGER;
       nextstring : StringGadgetPtr;
       autoactive*: BOOLEAN;
     END;

     (* CycleGadget *)
     CycleGadgetPtr * = POINTER TO CycleGadget;
     CycleGadget * = RECORD(Gadget)
       textarray   : UNTRACED POINTER TO ARRAY MAX(INTEGER) OF e.STRPTR;
       numactive - : INTEGER;
     END;

     (* CheckboxGadget *)
     CheckboxGadgetPtr * = POINTER TO CheckboxGadget;
     CheckboxGadget * = RECORD(Gadget)
       checked - : BOOLEAN;
     END;

     (* PaletteGadget *)
     PaletteGadgetPtr * = POINTER TO PaletteGadget;
     PaletteGadget * = RECORD(Gadget)
       depth,
       numcolors,
       actcolor - : INTEGER;
     END;

     (* RadioButtons *)
     RadioButtonsPtr * = POINTER TO RadioButtons;
     RadioButtons * = RECORD(Gadget)
       textarray   : UNTRACED POINTER TO ARRAY MAX(INTEGER) OF e.STRPTR;
       numactive - : INTEGER;
     END;

     (* SliderGadget *)
     SliderGadgetPtr * = POINTER TO SliderGadget;
     SliderGadget * = RECORD(Gadget)
       min          - ,
       max          - ,
       level        - ,
       levellen     - ,
       orientation  - : LONGINT;
       formatstring - : e.STRPTR;
     END;

     (* ScrollGadget *)
     ScrollerGadgetPtr * = POINTER TO ScrollerGadget;
     ScrollerGadget * = RECORD(Gadget)
       total       - ,
       visible     - ,
       top         - : LONGINT;
       arrows      - : BOOLEAN;
       orientation - : LONGINT;
     END;

     (* Listview *)
     PrintProc * = PROCEDURE(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);
     ListViewPtr * = POINTER TO ListView;
     ListView * = RECORD(Gadget)
       scrollgad  - ,
       stringgad  - : I.GadgetPtr;
       scrollerwi -,
       stringhe   - : INTEGER;
       stringgadact-: BOOLEAN;
       maxchars   - : INTEGER;
       total      - ,
       visible    - ,
       top        - ,
       actentry   - : INTEGER;
       itemheight - : INTEGER;
       datalist   - : l.List;
       printproc  - : PrintProc;
       standard   - : BOOLEAN;
       noentry    - : e.STRPTR;
       string     - : POINTER TO ARRAY OF CHAR;
       sec-,mic   - : LONGINT;
       titlehe    - : INTEGER;
     END;

     (* Colorwheel *)
     ColorWheelPtr * = POINTER TO ColorWheel;
     ColorWheel * = RECORD(Gadget)
       slider * : GadgetPtr;
       red    - ,
       green  - ,
       blue   - : INTEGER;
     END;

     (* GradientSlider *)
     GradientSliderPtr * = POINTER TO GradientSlider;
     GradientSlider * = RECORD(Gadget)
       pens        - : ARRAY 101 OF INTEGER;
       numpens     - : INTEGER;
       orientation - : LONGINT;
     END;

     (* Box that contains gadgets and other boxes.
        Either it is a horizontal orientated box (boxorient=horizBox) or a
        vertical orientated box (boxorient=vertBox).
        Set bordertype to any type of DrawBevelBox, or to -1 for no border. *)
TYPE BoxPtr * = POINTER TO Box;
     Box * = RECORD(Object)
       boxorient      : INTEGER;
       bordertype     : LONGINT;
       recessed       : BOOLEAN;
       leftin,rightin,
       topin,bottomin : INTEGER;
       objectlist     : l.List;
       title        * : e.STRPTR;
     END;

     (* Standard parameters for gadget creation *)
     StandardPtr * = UNTRACED POINTER TO Standard;
     Standard * = RECORD
       leftin,rightin,
       topin,bottomin : INTEGER;
       outtop,outleft : INTEGER;
       textcol      * ,
       hightextcol  * : INTEGER;
       oktext       * ,
       canceltext   * ,
       helptext     * : e.STRPTR;
     END;

     (* Basic box in a window *)
     Root * = RECORD(Box)
       gadgets : LONGSET;
       ok-,ca-,
       help  - : I.GadgetPtr;
       oksc,
       casc,
       helpsc  : CHAR;
       vinfo   : gt.VisualInfo;
       screen  : I.ScreenPtr;
       glist - : I.GadgetPtr;
       std     : StandardPtr;
       sametextwi : l.List;
     END;

     (* Internal stuff *)
     BoxListEl * = RECORD(l.NodeDesc)
       box : l.Node;
     END;

     SameTextWi = RECORD(l.NodeDesc)
       list : l.List;
     END;

     SameTextWiNode = RECORD(l.NodeDesc)
       gad  : GadgetPtr;
     END;

CONST horizBox * = 0; (* Orientation of box *)
      vertBox  * = 1;

      okGad     * = 0; (* Show which gadget in root box ? *)
      cancelGad * = 1;
      helpGad   * = 2;

      stdSizing * = -1;
      noBorder * = -1;
      autoOut * = -1;

      newActEntry   * = 1;
      doubleClicked * = 2;
      newString     * = 3;
      posChanged    * = 4;

      stdIDCMP * = LONGSET{I.menuPick,I.rawKey,I.vanillaKey,I.gadgetDown,I.gadgetUp,I.intuiTicks,I.mouseMove,I.mouseButtons,I.newSize,I.closeWindow,I.idcmpUpdate};

      outOfMem * = 1; (* Errors *)

VAR vinfo   : gt.VisualInfo;
    rast    : g.RastPortPtr;
    window  : I.WindowPtr;
    prev,
    glist   : I.GadgetPtr;
    font    : g.TextAttrPtr;
    tfont   : g.TextFontPtr;
    fontrast: g.RastPortPtr;
    error   : INTEGER;
    boxlist : l.List;
    actbox  : l.Node;
    actsametextwi : l.Node;
    firststring,
    laststring : StringGadgetPtr;
    actroot : RootPtr;           (* Root object of currently generated GUI *)
    std,
    standard*: StandardPtr;
    drawinfo: I.DrawInfoPtr;
    pens    : UNTRACED POINTER TO ARRAY 9 OF INTEGER;
    busy    : BOOLEAN;
    gradpens: ARRAY 1 OF INTEGER;


PROCEDURE StartGui*;

VAR exit : BOOLEAN;

BEGIN
  exit:=FALSE;
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
END StartGui;

PROCEDURE EndGui*;

BEGIN
  busy:=FALSE;
END EndGui;

PROCEDURE CopyStandard(std1,std2:StandardPtr);

BEGIN
  std2.leftin:=std1.leftin;
  std2.rightin:=std1.rightin;
  std2.topin:=std1.topin;
  std2.bottomin:=std1.bottomin;
  std2.outtop:=std1.outtop;
  std2.outleft:=std1.outleft;
  std2.textcol:=std1.textcol;
  std2.hightextcol:=std1.hightextcol;
  std2.oktext:=std1.oktext;
  std2.canceltext:=std1.canceltext;
  std2.helptext:=std1.helptext;
END CopyStandard;

PROCEDURE GetNode*(list:l.List;num:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  node:=list.head;
  WHILE (num>0) AND (node#NIL) DO
    node:=node.next;
    DEC(num);
  END;
  RETURN node;
END GetNode;

PROCEDURE IntToRGB*(i:LONGINT):LONGINT;

VAR set : LONGSET;

BEGIN
  set:=s.VAL(LONGSET,i);
  RETURN s.VAL(LONGINT,s.LSH(set,24));
END IntToRGB;

PROCEDURE RGBToInt*(rgb:LONGINT):INTEGER;

VAR set : LONGSET;

BEGIN
  set:=s.VAL(LONGSET,rgb);
  RETURN SHORT(s.VAL(LONGINT,s.LSH(set,-24)));
END RGBToInt;

(* General stuff for gadgets *)

PROCEDURE (object:ObjectPtr) Refresh*;
END Refresh;

PROCEDURE (gad:GadgetPtr) Refresh*;

BEGIN
  IF gad.window#NIL THEN
    I.RefreshGList(gad.gadget,gad.window,NIL,1);
  END;
END Refresh;

PROCEDURE (gad:ListViewPtr) Refresh*;

VAR i,x,y,
    width : INTEGER;
    rast  : g.RastPortPtr;

BEGIN
  IF gad.window#NIL THEN
    rast:=gad.window.rPort;
  (*  g.SetAPen(rast,0);*)
    g.SetDrMd(rast,g.jam1);
  (*  g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-gad.scrollerwi-3,gad.ypos+gad.height-gad.stringhe-2);*)
    gt.DrawBevelBox(rast,gad.xpos,gad.ypos+gad.titlehe,gad.width-gad.scrollerwi,gad.height-gad.stringhe-gad.titlehe,
                                          gt.bbFrameType,gt.bbftButton,
                                          gt.visualInfo,gad.root.vinfo,
                                          u.done);
    IF (gad.standard) AND (gad.datalist#NIL) THEN
      gad.total:=SHORT(gad.datalist.nbElements());
    END;
    rg.SetScroller(gad.scrollgad,gad.window,gad.total,gad.visible,gad.top);
    width:=gad.width-gad.scrollerwi-4;
    x:=gad.xpos+2;
    y:=gad.ypos+gad.titlehe+2;
    i:=gad.top;
    WHILE (i<gad.total) AND (y+gad.itemheight<gad.ypos+gad.height-gad.stringhe-1) DO
      IF i=gad.actentry THEN
        g.SetAPen(rast,3);
      ELSE
        g.SetAPen(rast,0);
      END;
      g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
      g.SetAPen(rast,1);
      gad.printproc(rast,x+2,y+tfont.baseline+1,width-4,i,gad.datalist);
      INC(y,gad.itemheight);
      INC(i);
    END;
    g.SetAPen(rast,0);
    g.RectFill(rast,x,y,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
  END;
END Refresh;

PROCEDURE (gad:ListViewPtr) BackFill(el:INTEGER;highlight:BOOLEAN);

VAR rast      : g.RastPortPtr;
    x,y,width : INTEGER;

BEGIN
  IF gad.window#NIL THEN
    rast:=gad.window.rPort;
    IF (el>=gad.top) AND (el<gad.top+gad.visible) THEN
      IF highlight THEN
        g.SetAPen(rast,3);
      ELSE
        g.SetAPen(rast,0);
      END;
      width:=gad.width-gad.scrollerwi-4;
      x:=gad.xpos+2;
      y:=gad.ypos+gad.titlehe+2;
      y:=y+(el-gad.top)*gad.itemheight;
      g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
      g.SetAPen(rast,1);
      gad.printproc(rast,x+2,y+tfont.baseline+1,width-4,el,gad.datalist);
    END;
  END;
END BackFill;

PROCEDURE (gad:ListViewPtr) Scroll(dir:INTEGER);

VAR rast        : g.RastPortPtr;
    x,y,i,width : INTEGER;

BEGIN
  IF gad.window#NIL THEN
    IF ((dir<0) AND (gad.top+dir>=0)) OR ((dir>0) AND (gad.top+dir<=gad.total-gad.visible)) THEN
      rast:=gad.window.rPort;
      g.SetDrMd(rast,g.jam1);
      width:=gad.width-gad.scrollerwi-4;
      x:=gad.xpos+2;
      y:=gad.ypos+gad.titlehe+2;
      g.ScrollRaster(rast,0,dir*gad.itemheight,x,y,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
      gad.top:=gad.top+dir;
      IF dir=1 THEN
        y:=y+(gad.visible-1)*gad.itemheight;
        i:=gad.top+gad.visible-1;
        IF i=gad.actentry THEN
          g.SetAPen(rast,3);
        ELSE
          g.SetAPen(rast,0);
        END;
        g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
        g.SetAPen(rast,1);
        gad.printproc(rast,x+2,y+tfont.baseline+1,width-4,i,gad.datalist);
      ELSIF dir=-1 THEN
        g.SetAPen(rast,0);
        g.RectFill(rast,x,y+gad.visible*gad.itemheight,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
        i:=gad.top;
        IF i=gad.actentry THEN
          g.SetAPen(rast,3);
        ELSE
          g.SetAPen(rast,0);
        END;
        g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
        g.SetAPen(rast,1);
        gad.printproc(rast,x+2,y+tfont.baseline+1,width-4,i,gad.datalist);
      END;
    END;
  END;
END Scroll;

PROCEDURE (box:BoxPtr) Refresh*;

VAR rast   : g.RastPortPtr;
    x,y,
    width,
    height,
    i      : INTEGER;

BEGIN
  IF box.window#NIL THEN
    rast:=box.window.rPort;
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
  END;
END Refresh;

PROCEDURE (gad:ListViewPtr) RefreshString*;

VAR bool : BOOLEAN;

BEGIN
  rg.SetString(gad.stringgad,gad.string^);
  IF gad.window#NIL THEN
    I.RefreshGList(gad.stringgad,gad.window,NIL,1);
    bool:=I.ActivateGadget(gad.stringgad^,gad.window,NIL);
  END;
END RefreshString;

PROCEDURE (object:ObjectPtr) Disable*(disabled:BOOLEAN;wind:I.WindowPtr);
END Disable;

PROCEDURE (gad:GadgetPtr) Disable*(disable:BOOLEAN;wind:I.WindowPtr);

VAR long : LONGINT;

BEGIN
  gad.disabled:=disable;
  IF disable THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gt.SetGadgetAttrs(gad.gadget^,wind,NIL,I.gaDisabled,long,
                                         u.done);
END Disable;

PROCEDURE (gad:ListViewPtr) Disable*(disable:BOOLEAN;wind:I.WindowPtr);

VAR long : LONGINT;

BEGIN
  gad.disabled:=disable;
  IF disable THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gt.SetGadgetAttrs(gad.scrollgad^,wind,NIL,I.gaDisabled,long,
                                            u.done);
  gt.SetGadgetAttrs(gad.stringgad^,wind,NIL,I.gaDisabled,long,
                                            u.done);
END Disable;

PROCEDURE (gad:GadgetPtr) Update*;
END Update;

PROCEDURE (gad:ListViewPtr) Update*;

BEGIN
  IF gad.actentry<gad.top THEN
    gad.top:=gad.actentry;
  ELSIF gad.actentry>=gad.top+gad.visible THEN
    gad.top:=gad.actentry-gad.visible+1;
  END;
  IF gad.top+gad.visible>gad.total THEN
    gad.top:=gad.total-gad.visible;
    IF gad.top<0 THEN
      gad.top:=0;
    END;
  END;
  rg.SetScroller(gad.gadget,gad.window,gad.total,gad.visible,gad.top);
  gad.Refresh;
END Update;

PROCEDURE (gad:GadgetPtr) Activate*;

VAR bool : BOOLEAN;

BEGIN
  bool:=I.ActivateGadget(gad.gadget^,gad.window,NIL);
END Activate;

PROCEDURE (gad:ListViewPtr) Activate*;

VAR bool : BOOLEAN;

BEGIN
  bool:=I.ActivateGadget(gad.stringgad^,gad.window,NIL);
END Activate;

PROCEDURE (obj:ObjectPtr) SetOutValues*(topout,leftout:INTEGER);

BEGIN
  IF topout=autoOut THEN
    obj.autoout:=TRUE;
  ELSE
    obj.autoout:=FALSE;
    obj.topout:=topout;
    obj.leftout:=leftout;
  END;
END SetOutValues;

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

PROCEDURE (node:ObjectPtr) UpdateShortcut*;
END UpdateShortcut;

PROCEDURE (gad:GadgetPtr) UpdateShortcut*;

VAR i : INTEGER;

BEGIN
  IF gad.text#NIL THEN
    gad.shortcut:=GetShortcut(gad.text);
  ELSE
    gad.shortcut:=0X;
  END;
END UpdateShortcut;

PROCEDURE TextLength(gad:GadgetPtr;text:e.STRPTR):INTEGER;

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

(* Init is for preparing objects. No gadgets are created properly. *)

PROCEDURE (object:ObjectPtr) Init;
END Init;

(* Resize is for adapting an object to a new size. You have to provide the
   sizes in the object record. If the object is a gadget it will be created,
   border will be drawn.
   Use ResizeRoot to resize the Gui of a window. *)

PROCEDURE (object:ObjectPtr) Resize*;
END Resize;

PROCEDURE (text:TextPtr) Init;

BEGIN
  text.minwi:=g.TextLength(fontrast,text.text^,st.Length(text.text^));
  text.minhe:=tfont.ySize;
  text.width:=text.minwi;
  text.height:=text.minhe;
  IF text.autoout THEN
    text.topout:=SHORT(SHORT(text.font.ySize/8+0.5));
    text.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:BooleanGadgetPtr) Init;

BEGIN
  gad.minwi:=TextLength(gad,gad.text)+8;
  gad.minhe:=tfont.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:StringGadgetPtr) Init;

VAR i : INTEGER;

BEGIN
  IF gad.text#NIL THEN
    gad.minwi:=gad.textwi;
  ELSE
    gad.minwi:=0;
  END;
  i:=gad.minvisible;
  gad.minwi:=gad.minwi+i*tfont.ySize+12;
  gad.minhe:=tfont.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:CycleGadgetPtr) Init;

VAR maxwi,wi,i : INTEGER;

BEGIN
  i:=0;
  WHILE gad.textarray[i]#NIL DO
    wi:=g.TextLength(fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    INC(i);
  END;
  IF gad.text#NIL THEN
    gad.minwi:=gad.textwi+wi+28;
  ELSE
    gad.minwi:=wi+28;
  END;
  gad.minhe:=tfont.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:CheckboxGadgetPtr) Init;

BEGIN
  gad.minwi:=gad.textwi;
  gad.minwi:=gad.minwi+SHORT(SHORT(gt.checkboxWidth/8*tfont.ySize));
  gad.minhe:=SHORT(SHORT(gt.checkboxHeight/8*tfont.ySize));
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:PaletteGadgetPtr) Init;

BEGIN
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  gad.minwi:=100;
  gad.minhe:=tfont.ySize*2;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:RadioButtonsPtr) Init;

VAR maxwi,wi,i : INTEGER;

BEGIN
  i:=0;
  WHILE gad.textarray[i]#NIL DO
    wi:=g.TextLength(fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    INC(i);
  END;
  gad.minwi:=wi+SHORT(SHORT(gt.mxWidth/8*tfont.ySize))+tfont.ySize; (* +tfont.xSize *)
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize+wi+28;
  ELSE
    gad.minwi:=wi+28;
  END;*)
  gad.minhe:=(SHORT(SHORT(gt.mxHeight/8*tfont.ySize))+(tfont.ySize DIV 8))*i-(tfont.ySize DIV 8);
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:SliderGadgetPtr) Init;

BEGIN
(*  IF gad.text#NIL THEN
    gad.minwi:=TextLength(gad,gad.text)+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  gad.minwi:=SHORT(2*gad.levellen*tfont.ySize)+tfont.ySize;
  gad.minhe:=tfont.ySize+2;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ScrollerGadgetPtr) Init;

BEGIN
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  IF gad.orientation=I.lorientVert THEN
    gad.minhe:=(tfont.ySize+2)*3
  ELSIF gad.orientation=I.lorientHoriz THEN
    gad.minwi:=(tfont.ySize+2)*3;
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ListViewPtr) Init;

VAR i,wi : INTEGER;

BEGIN
  i:=gad.maxchars;
  IF i>10 THEN
    i:=10;
  ELSIF i<4 THEN
    i:=4;
  END;
  gad.minwi:=tfont.ySize*2+tfont.ySize*i;
  gad.minhe:=(tfont.ySize+2)*3+4;
  IF gad.stringgadact THEN
    gad.minhe:=gad.minhe+tfont.ySize+6;
  END;
  gad.titlehe:=0;
  IF gad.text#NIL THEN
    wi:=TextLength(gad,gad.text);
    IF wi>gad.minwi THEN
      gad.minwi:=wi;
    END;
    gad.titlehe:=SHORT(SHORT(tfont.ySize*1.1+0.5));
    gad.minhe:=gad.minhe+gad.titlehe;
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:GradientSliderPtr) Init;

BEGIN
  IF gad.orientation=I.freeVert THEN
    gad.minhe:=(tfont.ySize+2)*3
  ELSIF gad.orientation=I.freeHoriz THEN
    gad.minwi:=(tfont.ySize+2)*3;
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ColorWheelPtr) Init;

BEGIN
  gad.minwi:=100;
  gad.minhe:=70;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(tfont.ySize/2+0.5));
  END;
END Init;

PROCEDURE (box:BoxPtr) Init;

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

PROCEDURE (object:ObjectPtr) SetTextWidth;
END SetTextWidth;

PROCEDURE (gad:GadgetPtr) SetTextWidth;

BEGIN
  IF gad.text#NIL THEN
    gad.textwi:=TextLength(gad,gad.text)+tfont.ySize;
  ELSE gad.textwi:=0;
  END;
END SetTextWidth;

PROCEDURE (box:BoxPtr) SetTextWidth;

VAR node : l.Node;

BEGIN
  node:=box.objectlist.head;
  WHILE node#NIL DO
    node(Object).SetTextWidth;
    node:=node.next;
  END;
END SetTextWidth;

PROCEDURE (root:RootPtr) InitRoot*(VAR minwi,minhe:INTEGER);

VAR node,node2 : l.Node;
    width      : INTEGER;
    str        : ARRAY 2 OF CHAR;

BEGIN
  StartGui;
  std:=root.std;
  vinfo:=root.vinfo;
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
      node2:=node(SameTextWi).list.head;
      WHILE node2#NIL DO
        IF node2(SameTextWiNode).gad.textwi>width THEN
          width:=node2(SameTextWiNode).gad.textwi;
        END;
        node2:=node2.next;
      END;
      node2:=node(SameTextWi).list.head;
      WHILE node2#NIL DO
        node2(SameTextWiNode).gad.textwi:=width;
        node2:=node2.next;
      END;
      node:=node.next;
    END;
  END;

  root.Init;
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
  minwi:=root.minwi+tfont.ySize*2;
  minhe:=root.minhe+tfont.ySize;
  IF root.gadgets#LONGSET{} THEN
    minhe:=minhe+(tfont.ySize+6)+SHORT(SHORT(tfont.ySize/3+0.5));
  END;
  EndGui;
END InitRoot;

PROCEDURE (text:TextPtr) Resize*;

BEGIN
  text.window:=window;
  g.SetAPen(rast,text.color);
  g.Move(rast,text.xpos,text.ypos+tfont.baseline);
  g.Text(rast,text.text^,st.Length(text.text^));
END Resize;

PROCEDURE (gad:BooleanGadgetPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetBooleanGadget(gad.xpos,gad.ypos,gad.width,gad.height,gad.text,prev);
END Resize;

PROCEDURE (gad:StringGadgetPtr) Resize*;

BEGIN
  gad.window:=window;
  rg.GetString(gad.gadget,gad.string^);
  gad.gadget:=rg.SetStringGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.maxchars,prev);
  rg.SetString(gad.gadget,gad.string^);
END Resize;

PROCEDURE (gad:CycleGadgetPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetCycleGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.textarray,gad.numactive,prev);
END Resize;

PROCEDURE (gad:CheckboxGadgetPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetCheckBoxGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.checked,prev);
END Resize;

PROCEDURE (gad:PaletteGadgetPtr) Resize*;

VAR i : INTEGER;

BEGIN
  gad.window:=window;
  i:=0;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  gad.gadget:=rg.SetPaletteGadget(gad.xpos+i,gad.ypos,gad.width-i,gad.height,gad.text,gad.depth,gad.numcolors,gad.actcolor,prev);
END Resize;

PROCEDURE (gad:RadioButtonsPtr) Resize*;

VAR i,wi : INTEGER;

BEGIN
  gad.window:=window;
  i:=0;
  WHILE gad.textarray[i]#NIL DO
    wi:=g.TextLength(fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    INC(i);
  END;
  wi:=wi+tfont.ySize;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  gad.gadget:=rg.SetRadioGadget(gad.xpos+wi,gad.ypos,gad.width-wi,SHORT(SHORT(gt.mxHeight/8*tfont.ySize)),gad.text,gad.textarray,gad.numactive,SHORT(SHORT(gt.mxHeight/8*tfont.ySize))-tfont.ySize+(tfont.ySize DIV 8),prev);
END Resize;

PROCEDURE (gad:SliderGadgetPtr) Resize*;

VAR i,ydif : INTEGER;

BEGIN
  gad.window:=window;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  i:=SHORT(gad.levellen*tfont.ySize)+tfont.ySize;
  ydif:=SHORT(SHORT(tfont.ySize/8+0.5));
  gad.gadget:=rg.SetSliderGadget(gad.xpos+i,gad.ypos+ydif,gad.width-i,gad.height-2*ydif,gad.text,gad.min,gad.max,gad.level,gad.levellen,gad.orientation,gad.formatstring,prev);
END Resize;

PROCEDURE (gad:ScrollerGadgetPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetScrollerGadget(gad.xpos,gad.ypos,gad.width,gad.height,gad.text,gad.total,gad.visible,gad.top,gad.arrows,gad.orientation,prev);
END Resize;

PROCEDURE (gad:ListViewPtr) Resize*;

VAR i : INTEGER;

BEGIN
  gad.window:=window;
  gad.scrollerwi:=tfont.ySize*2;
  gad.itemheight:=tfont.ySize+2;
  i:=0;
  gad.stringhe:=0;
  IF gad.stringgadact THEN
    gad.stringhe:=tfont.ySize+6;
    i:=gad.stringhe;
    rg.GetString(gad.stringgad,gad.string^);
    gad.stringgad:=rg.SetStringGadget(gad.xpos,gad.ypos+gad.height-i,gad.width,i,NIL,gad.maxchars,prev);
    rg.SetString(gad.stringgad,gad.string^);
  END;
  gad.titlehe:=0;
  IF gad.text#NIL THEN
    gad.titlehe:=SHORT(SHORT(tfont.ySize*1.1+0.5));
    g.SetAPen(rast,gad.color);
    g.Move(rast,gad.xpos,gad.ypos+tfont.baseline);
    g.Text(rast,gad.text^,st.Length(gad.text^));
  END;
  gad.visible:=(gad.height-gad.stringhe-gad.titlehe-4) DIV (gad.itemheight);
  IF gad.actentry<gad.top THEN
    gad.top:=gad.actentry;
  ELSIF gad.actentry>=gad.top+gad.visible THEN
    gad.top:=gad.actentry-gad.visible+1;
  END;
  IF gad.top+gad.visible>gad.total THEN
    gad.top:=gad.total-gad.visible;
    IF gad.top<0 THEN
      gad.top:=0;
    END;
  END;
  gt.DrawBevelBox(rast,gad.xpos,gad.ypos+gad.titlehe,gad.width-gad.scrollerwi,gad.height-i-gad.titlehe,
                                        gt.bbFrameType,gt.bbftButton,
                                        gt.visualInfo,vinfo,
                                        u.done);
  gad.scrollgad:=rg.SetScrollerGadget(gad.xpos+gad.width-gad.scrollerwi,gad.ypos+gad.titlehe,gad.scrollerwi,gad.height-i-gad.titlehe,NIL,gad.total,gad.visible,gad.top,TRUE,I.lorientVert,prev);
(*  gad.window:=NIL;*)
(*  gad.Refresh;*)
END Resize;

PROCEDURE (gad:GradientSliderPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetGradientSlider(gad.xpos,gad.ypos,gad.width,gad.height,s.ADR(gad.pens),gad.orientation,prev);
END Resize;

PROCEDURE (gad:ColorWheelPtr) Resize*;

BEGIN
  gad.window:=window;
  gad.gadget:=rg.SetColorWheel(gad.xpos,gad.ypos,gad.width,gad.height,gad.slider.gadget,prev);
END Resize;

PROCEDURE (box:BoxPtr) Resize*;

VAR addwi,addhe,size,
    availx,availy,i,
    width,height,x,y,
    numsize          : INTEGER;
    node             : l.Node;

BEGIN
  box.window:=window;

(* Drawing area *)

  x:=box.xpos;
  y:=box.ypos;
  width:=box.width;
  height:=box.height;

(* Drawing box *)

  IF box.title#NIL THEN
    g.SetAPen(rast,box.color);
    g.Move(rast,x,y+tfont.baseline);
    g.Text(rast,box.title^,st.Length(box.title^));
    i:=SHORT(SHORT(tfont.ySize*1.1+0.5));
    y:=y+i;
    height:=height-i;
  END;
  IF box.bordertype#noBorder THEN
    IF box.recessed THEN
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                            gt.bbRecessed,I.LTRUE,
                                            gt.visualInfo,vinfo,
                                            u.done);
    ELSE
      gt.DrawBevelBox(rast,x,y,width,height,gt.bbFrameType,box.bordertype,
                                            gt.visualInfo,vinfo,
                                            u.done);
    END;
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
      node.Disable(node.disabled,NIL);
      IF box.boxorient=vertBox THEN
        y:=y+node.height;
      ELSIF box.boxorient=horizBox THEN
        x:=x+node.width;
      END;
    END;
    node:=node.next;
  END;
END Resize;

PROCEDURE (root:RootPtr) ResizeRoot*(wind:I.WindowPtr);

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

PROCEDURE RefreshListView(list:l.List);

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
END RefreshListView;

BEGIN
  StartGui;
  std:=root.std;
  vinfo:=root.vinfo;
  font:=root.font;
  IF tfont#NIL THEN
    gr.CloseFont(tfont);
    tfont:=NIL;
  END;
  tfont:=gr.SetFont(wind.rPort,font);
  tfont:=gr.SetFont(fontrast,font);
  glist:=NIL;
  rg.StartGadgetsAgain(wind.wScreen,font,vinfo);
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

  root.rast:=wind.rPort;
  rast:=wind.rPort;
  window:=wind;

  root.xpos:=x;
  root.ypos:=y;
  root.width:=width;
  root.height:=height;

  g.SetAPen(rast,0);
  g.RectFill(rast,wind.borderLeft,wind.borderTop,wind.width-wind.borderRight-1,wind.height-wind.borderBottom-1);
  root.Resize;
  RefreshListView(root.objectlist);
  root.Disable(root.disabled,NIL);
  i:=I.RemoveGList(wind,root.glist,-1);
  gt.FreeGadgets(root.glist);
  I.RefreshWindowFrame(wind);
  root.glist:=glist;
  i:=I.AddGList(wind,glist,-1,-1,NIL);
  I.RefreshGList(glist,wind,NIL,-1);
  rg.EndGadgets;
  EndGui;
END ResizeRoot;

PROCEDURE AddObject(object:l.Node);

BEGIN
  IF actbox#NIL THEN
    actbox(BoxListEl).box(Box).objectlist.AddTail(object);
  END;
END AddObject;

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

(* Additional procedures to work with existing gadgets *)

(* Standard-procedure to change a gadget *)

PROCEDURE (gad:GadgetPtr) SetValue*(active:LONGINT);
END SetValue;

PROCEDURE (gad:CycleGadgetPtr) SetValue*(numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.cyActive,numactive,
                                               u.done);
  gad.numactive:=SHORT(numactive);
END SetValue;

PROCEDURE (gad:RadioButtonsPtr) SetValue*(numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.mxActive,numactive,
                                               u.done);
  gad.numactive:=SHORT(numactive);
END SetValue;

PROCEDURE (gad:PaletteGadgetPtr) SetValue*(actcolor:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.paColor,actcolor,
                                               u.done);
  gad.actcolor:=SHORT(actcolor);
END SetValue;

PROCEDURE (gad:SliderGadgetPtr) SetValue*(level:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.slLevel,level,
                                               u.done);
  gad.level:=level;
END SetValue;

PROCEDURE (gad:ScrollerGadgetPtr) SetValue*(top:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.scTop,top,
                                               u.done);
  gad.top:=top;
END SetValue;

(* Special procedures *)

PROCEDURE (gad:ListViewPtr) SetValue*(actentry:LONGINT);

BEGIN
  IF (gad.standard) AND (gad.datalist#NIL) THEN
    gad.total:=SHORT(gad.datalist.nbElements());
  END;
  gad.actentry:=SHORT(actentry);
  IF gad.actentry<gad.top THEN
    gad.top:=gad.actentry;
  ELSIF gad.actentry>=gad.top+gad.visible THEN
    gad.top:=gad.actentry-gad.visible+1;
  END;
  IF gad.top+gad.visible>gad.total THEN
    gad.top:=gad.total-gad.visible;
    IF gad.top<0 THEN
      gad.top:=0;
    END;
  END;
  gad.Refresh;
END SetValue;

PROCEDURE (gad:CycleGadgetPtr) ChangeCycleGadget*(texts:s.ADDRESS;numactive:INTEGER);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.cyLabels,texts,
                                               gt.cyActive,numactive,
                                               u.done);
  gad.numactive:=numactive;
  gad.textarray:=texts;
END ChangeCycleGadget;

PROCEDURE (gad:SliderGadgetPtr) ChangeSliderGadget*(min,max,level:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.slMin,min,
                                               gt.slMax,max,
                                               gt.slLevel,level,
                                               u.done);
  gad.min:=min;
  gad.max:=max;
  gad.level:=level;
END ChangeSliderGadget;

PROCEDURE (obj:ObjectPtr) SetText*(string:e.STRPTR);
END SetText;

PROCEDURE (text:TextPtr) SetText*(string:e.STRPTR);

BEGIN
  text.text:=string;
END SetText;

PROCEDURE (box:BoxPtr) SetText*(string:e.STRPTR);

BEGIN
  box.title:=string;
END SetText;

PROCEDURE (gad:StringGadgetPtr) GetString*(VAR string:ARRAY OF CHAR);

BEGIN
  rg.GetString(gad.gadget,gad.string^);
  COPY(gad.string^,string);
END GetString;

PROCEDURE (gad:StringGadgetPtr) SetString*(string:ARRAY OF CHAR);

BEGIN
  COPY(string,gad.string^);
  rg.SetString(gad.gadget,gad.string^);
  gad.Refresh;
END SetString;

PROCEDURE (gad:StringGadgetPtr) SetMinVisible*(minvisible:INTEGER);

BEGIN
  gad.minvisible:=minvisible;
END SetMinVisible;

PROCEDURE (gad:CheckboxGadgetPtr) Check*(checked:BOOLEAN);

VAR long : LONGINT;

BEGIN
  gad.checked:=checked;
  IF checked THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gt.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gt.cbChecked,long,
                                               u.done);
END Check;

PROCEDURE (gad:ColorWheelPtr) RefreshPens*(view:g.ViewPortPtr);

VAR numpens,
    actpen  : INTEGER;
    long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;
    slider  : GradientSliderPtr;

BEGIN
  slider:=gad.slider(GradientSlider);
  numpens:=0;
  WHILE slider.pens[numpens]#-1 DO
    INC(numpens);
  END;

  long:=I.GetAttr(gd.wheelHSB,gad.gadget,hsb);
  actpen:=0;
  WHILE actpen<numpens DO
    long:=SHORT(255-(255/(numpens-1))*actpen);
    hsb.brightness:=s.LSH(long,24);
    gd.ConvertHSBToRGB(hsb,rgb);
    g.SetRGB32(view,slider.pens[actpen],rgb.red,rgb.green,rgb.blue);
    INC(actpen);
  END;
END RefreshPens;

PROCEDURE (gad:ColorWheelPtr) PreparePens*(view:g.ViewPortPtr);

VAR actpen : INTEGER;
    slider : GradientSliderPtr;

BEGIN
  slider:=gad.slider(GradientSlider);
  IF slider.numpens<0 THEN
    slider.numpens:=100;
  END;
  actpen:=0;
  WHILE (actpen<slider.numpens) DO
    slider.pens[actpen]:=SHORT(g.ObtainPen(view.colorMap,-1,0,0,0,s.VAL(LONGINT,LONGSET{g.penbExclusive})));
    INC(actpen);
  END;
  slider.pens[actpen]:=-1;
END PreparePens;

PROCEDURE (gad:ColorWheelPtr) ReleasePens*(view:g.ViewPortPtr);

VAR actpen : INTEGER;
    slider : GradientSliderPtr;

BEGIN
  slider:=gad.slider(GradientSlider);
  actpen:=0;
  WHILE actpen<LEN(slider.pens) DO
    IF slider.pens[actpen]>=0 THEN
      g.ReleasePen(view.colorMap,slider.pens[actpen]);
    ELSE
      actpen:=SHORT(LEN(slider.pens));
    END;
    INC(actpen);
  END;
END ReleasePens;

PROCEDURE (gad:ColorWheelPtr) RefreshWheel*(red,green,blue:LONGINT;view:g.ViewPortPtr);

VAR rgb  : gd.ColorWheelRGB;
    hsb  : gd.ColorWheelHSB;
    long : LONGINT;

BEGIN
  rgb.red:=IntToRGB(red);
  rgb.green:=IntToRGB(green);
  rgb.blue:=IntToRGB(blue);
  gd.ConvertRGBToHSB(rgb,hsb);
  long:=I.SetGadgetAttrs(gad.gadget^,gad.window,NIL,gd.wheelRGB,s.ADR(rgb),u.done);
  gad.RefreshPens(view);
END RefreshWheel;

PROCEDURE (gad:ColorWheelPtr) GetColor*(VAR red,green,blue:INTEGER);

VAR long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;

BEGIN
  long:=I.GetAttr(gd.wheelRGB,gad.gadget,rgb);
  red:=RGBToInt(rgb.red);
  green:=RGBToInt(rgb.green);
  blue:=RGBToInt(rgb.blue);
END GetColor;

PROCEDURE (gad:ListViewPtr) SetNoEntryText*(text:e.STRPTR);

BEGIN
  gad.noentry:=text;
END SetNoEntryText;

PROCEDURE (gad:ListViewPtr) SetString*(string:ARRAY OF CHAR);

VAR bool : BOOLEAN;

BEGIN
  IF gad.stringgad#NIL THEN
    COPY(string,gad.string^);
    gad.RefreshString;
  END;
END SetString;

PROCEDURE (gad:ListViewPtr) GetString*(VAR string:ARRAY OF CHAR);

BEGIN
  IF gad.stringgad#NIL THEN
    rg.GetString(gad.stringgad,string);
  END;
END GetString;

PROCEDURE (gad:ListViewPtr) ChangeListView*(datalist:l.List;actentry:INTEGER);

BEGIN
  gad.datalist:=datalist;
  gad.actentry:=actentry;
  gad.Refresh;
END ChangeListView;

PROCEDURE (gad:ListViewPtr) ChangeListViewSpecial*(total:INTEGER;printproc:PrintProc);

BEGIN
  IF gad.total>=0 THEN
    gad.total:=total;
    gad.standard:=FALSE;
  ELSE
    gad.standard:=TRUE;
  END;
  gad.printproc:=printproc;
  gad.Refresh;
END ChangeListViewSpecial;

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

PROCEDURE (gad:GadgetPtr) KeyboardAction*;
END KeyboardAction;

PROCEDURE (gad:BooleanGadgetPtr) KeyboardAction*;

BEGIN
  IF I.toggleSelect IN gad.gadget.flags THEN
    gad.selected:=NOT(gad.selected);
    IF gad.selected THEN
      INCL(gad.gadget.flags,I.selected);
    ELSE
      EXCL(gad.gadget.flags,I.selected);
    END;
    I.RefreshGList(gad.gadget,gad.window,NIL,1);
  ELSE
    PressBoolean(gad.gadget,gad.window);
  END;
END KeyboardAction;

PROCEDURE (gad:StringGadgetPtr) KeyboardAction*;

VAR bool : BOOLEAN;

BEGIN
  bool:=I.ActivateGadget(gad.gadget^,gad.window,NIL);
END KeyboardAction;

PROCEDURE (gad:CycleGadgetPtr) KeyboardAction*;

BEGIN
  INC(gad.numactive);
  IF gad.textarray[gad.numactive]=NIL THEN
    gad.numactive:=0;
  END;
  gad.SetValue(gad.numactive);
  PressBoolean(gad.gadget,gad.window);
END KeyboardAction;

PROCEDURE (gad:CheckboxGadgetPtr) KeyboardAction*;

BEGIN
  gad.checked:=NOT(gad.checked);
  gad.Check(gad.checked);
  I.RefreshGList(gad.gadget,gad.window,NIL,1);
END KeyboardAction;

PROCEDURE Destruct*(object:l.Node);

VAR node,node2,
    next      : l.Node;
    long      : LONGINT;

BEGIN
  IF object IS Box THEN
    node:=object(Box).objectlist.head;
    WHILE node#NIL DO
      next:=node.next;
      Destruct(node);
      node:=next;
    END;
    (* $IFNOT GarbageCollector *)
      DISPOSE(object(Box).objectlist);
    (* $END *)

    IF object IS Root THEN
      (* $IFNOT GarbageCollector *)
        node:=object(Root).sametextwi.head;
        WHILE node#NIL DO
          node2:=node(SameTextWi).list.head;
          WHILE node2#NIL DO
            next:=node2.next;
            DISPOSE(node2);
            node2:=next;
          END;
          DISPOSE(node(SameTextWi).list);
          next:=node.next;
          DISPOSE(node);
          node:=next;
        END;
        DISPOSE(object(Root).sametextwi);

        DISPOSE(object(Root).std);
      (* $END *)
      IF object(Root).glist#NIL THEN
        gt.FreeGadgets(object(Root).glist);
      END;
      IF object(Root).vinfo#NIL THEN
        gt.FreeVisualInfo(object(Root).vinfo);
      END;
    END;
  ELSIF object IS StringGadget THEN
    (* $IFNOT GarbageCollector *)
      IF object(StringGadget).string#NIL THEN
        DISPOSE(object(StringGadget).string);
      END;
    (* $END *)
  ELSIF object IS ListView THEN
    (* $IFNOT GarbageCollector *)
      IF object(ListView).string#NIL THEN
        DISPOSE(object(ListView).string);
      END;
    (* $END *)
  ELSIF object IS GradientSlider THEN
    long:=I.RemoveGadget(object(Gadget).window,object(Gadget).gadget^);
    object(Gadget).gadget.nextGadget:=NIL;
    I.DisposeObject(object(Gadget).gadget);
  ELSIF object IS ColorWheel THEN
    long:=I.RemoveGadget(object(Gadget).window,object(Gadget).gadget^);
    object(Gadget).gadget.nextGadget:=NIL;
    I.DisposeObject(object(Gadget).gadget);
  END;
  (* $IFNOT GarbageCollector *)
    DISPOSE(object);
  (* $END *)
END Destruct;

BEGIN
  boxlist:=NIL;
  boxlist:=l.Create();
  NEW(standard);
  standard.leftin:=6;
  standard.rightin:=6;
  standard.topin:=3;
  standard.bottomin:=3;
  standard.textcol:=1;
  standard.hightextcol:=2;
  standard.oktext:=s.ADR("_OK");
  standard.canceltext:=s.ADR("_Cancel");
  standard.helptext:=s.ADR("Help");
  fontrast:=NIL;
  fontrast:=it.AllocRastPort(32,10,1);
  tfont:=NIL;
  gradpens[0]:=-1;
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
END GuiManager.


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


MODULE GuiManagerObjects;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       c  : Conversions,
       lrc: LongRealConversions,
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
       im : Images,
       l  : LinkedLists,
       Beep,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

VAR gradpens : ARRAY 1 OF INTEGER; (* Colorpen array for gradient slider *)



(* Textobject *)

TYPE Text * = POINTER TO TextDesc;
     TextDesc * = RECORD(gmb.GadgetDesc)
     END;
(*TYPE Text * = POINTER TO TextDesc;
     TextDesc * = RECORD(gmb.ObjectDesc)
       text * : e.STRPTR;
       color* : INTEGER;
     END;*)

CONST shadowText * = -2; (* Use as color to get a shadowed text. *)

PROCEDURE (text:Text) Init*;

BEGIN
  text.minwi:=text.textwi;
(*  text.minwi:=g.TextLength(gmb.fontrast,text.text^,st.Length(text.text^));*)
  IF text.userminwi>0 THEN text.minwi:=text.userminwi; END;
  text.minhe:=text.font.ySize;
  IF text.color=shadowText THEN
    INC(text.minwi,2);
    INC(text.minhe,1);
  END;
  text.width:=text.minwi;
  text.height:=text.minhe;
  IF text.autoout THEN
    text.topout:=SHORT(SHORT(text.font.ySize/8+0.5));
    text.leftout:=SHORT(SHORT(text.font.ySize/2+0.5));
  END;
  text.Init^;
END Init;

PROCEDURE (text:Text) Resize*;

(*VAR rast : g.RastPortPtr;*)

BEGIN
(*  text.iwind:=text.root.iwind;
  rast:=text.iwind.rPort;
  g.SetAPen(rast,text.color);
  g.Move(rast,text.xpos,text.ypos+((text.height-text.iwind.rPort.txHeight) DIV 2)+text.iwind.rPort.font.baseline);
  g.Text(rast,text.text^,st.Length(text.text^));*)
END Resize;

PROCEDURE (text:Text) Refresh*;

VAR rast : g.RastPortPtr;
    str  : UNTRACED POINTER TO ARRAY OF CHAR;
    i    : LONGINT;

BEGIN
  IF text.root.iwind#NIL THEN
    text.iwind:=text.root.iwind;
    rast:=text.iwind.rPort;

    NEW(str,st.Length(text.text^)+1);
    COPY(text.text^,str^);
    tt.CutStringToLength(rast,str^,text.width);
    IF st.Length(str^)<st.Length(text.text^) THEN
      i:=st.Length(str^);
      IF i>2 THEN
        str[i-1]:=".";
        str[i-2]:=".";
      END;
    END;

    g.SetAPen(rast,0);
    g.RectFill(rast,text.xpos,text.ypos,text.xpos+text.width-1,text.ypos+text.height-1);
    IF text.color#shadowText THEN
      g.SetAPen(rast,text.color);
      g.Move(rast,text.xpos,text.ypos+((text.height-text.iwind.rPort.txHeight) DIV 2)+text.iwind.rPort.font.baseline);
      g.Text(rast,str^,st.Length(str^));
    ELSE
      g.SetDrMd(rast,g.jam1);
      g.SetAPen(rast,gmb.std.shadowcol);
      g.Move(rast,text.xpos,text.ypos+((text.height-text.iwind.rPort.txHeight) DIV 2)+text.iwind.rPort.font.baseline);
      g.Text(rast,str^,st.Length(str^));
      g.SetAPen(rast,gmb.std.lightcol);
      g.Move(rast,text.xpos-2,text.ypos+((text.height-text.iwind.rPort.txHeight) DIV 2)+text.iwind.rPort.font.baseline-1);
      g.Text(rast,str^,st.Length(str^));
    END;
    DISPOSE(str);
  END;
END Refresh;

PROCEDURE (text:Text) SetText*(string:e.STRPTR);

BEGIN
  text.text:=string;
END SetText;

PROCEDURE SetText*(text:e.STRPTR;color:INTEGER):Text;

VAR gad  : I.GadgetPtr;
    node : l.Node;

BEGIN
  IF color=-1 THEN
    color:=gmb.std.textcol;
  END;
  node:=NIL;
  NEW(node(Text));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: Text DO
      node.text:=text;
      node.color:=color;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=-1;
      node.sizey:=0;  (* So the text can be centered vertically! *)
      node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^));
      node.minhe:=node.font.ySize;
      node.userminwi:=0;
      node.userminhe:=0;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
    END;
  END;
  RETURN node(Text);
END SetText;



(* BooleanGadget *)

TYPE BooleanGadget * = POINTER TO BooleanGadgetDesc;
     BooleanGadgetDesc * = RECORD(gmb.GadgetDesc)
       toggle   - ,
       selected - : BOOLEAN;
     END;

PROCEDURE (gad:BooleanGadget) Init*;

BEGIN
  gad.minwi:=gmb.TextLength(gad,gad.text)+8;
  gad.minhe:=gad.font.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:BooleanGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetBooleanGadget(gad.xpos,gad.ypos,gad.width,gad.height,gad.text,gmb.prev);
  IF gad.toggle THEN INCL(gad.gadget.activation,I.toggleSelect); END;
  IF gad.selected THEN INCL(gad.gadget.flags,I.selected); END;
END Resize;

PROCEDURE (gad:BooleanGadget) SetSelected*(selected:BOOLEAN);

BEGIN
  gad.selected:=selected;
  IF gad.selected THEN INCL(gad.gadget.flags,I.selected);
                  ELSE EXCL(gad.gadget.flags,I.selected); END;
  gad.Refresh;
END SetSelected;

PROCEDURE (gad:BooleanGadget) KeyboardAction*;

BEGIN
  IF I.toggleSelect IN gad.gadget.flags THEN
    gad.selected:=NOT(gad.selected);
    IF gad.selected THEN
      INCL(gad.gadget.flags,I.selected);
    ELSE
      EXCL(gad.gadget.flags,I.selected);
    END;
    I.RefreshGList(gad.gadget,gad.iwind,NIL,1);
  ELSE
    gmb.PressBoolean(gad.gadget,gad.iwind);
  END;
END KeyboardAction;

PROCEDURE SetBooleanGadget*(text:e.STRPTR;toggle:BOOLEAN):BooleanGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetBooleanGadget(-gmb.tfont.ySize*10-10,-gmb.tfont.ySize*2-10,gmb.tfont.ySize*10,gmb.tfont.ySize*2,text,gmb.prev);
  node:=NIL;
  NEW(node(BooleanGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: BooleanGadget DO
      node.text:=text;
      node.toggle:=toggle;
      node.selected:=FALSE;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=0;
      node.sizey:=0;
      node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^))+8;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(BooleanGadget);
END SetBooleanGadget;

PROCEDURE (gad:BooleanGadget) InputEvent*(mes:I.IntuiMessagePtr);

VAR bool : BOOLEAN;

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      IF I.toggleSelect IN gad.gadget.flags THEN
        gad.selected:=NOT(gad.selected);
      END;
    END;
  END;
  gad.InputEvent^(mes);
END InputEvent;



(* StringGadget *)

TYPE StringGadget * = POINTER TO StringGadgetDesc;
     StringGadgetDesc * = RECORD(gmb.GadgetDesc)
       string   - : POINTER TO ARRAY OF CHAR;
       long     - : LONGINT;
       real     - : LONGREAL;
       minint   - ,
       maxint   - : LONGINT;
       minreal  - ,
       maxreal  - : LONGREAL;
       maxchars - ,
       minvisible-,
       type     - : INTEGER;
       nextstring : StringGadget;
       autoactive*: BOOLEAN;
     END;

CONST stringType  * = 0;
      integerType * = 1;
      realType    * = 2;

PROCEDURE (gad:StringGadget) Init*;

VAR i,charwi : INTEGER;

BEGIN
  IF gad.text#NIL THEN
    gad.minwi:=gad.textwi;
  ELSE
    gad.minwi:=0;
  END;
  i:=gad.minvisible;
  charwi:=gmb.fontrast.txWidth;
  IF charwi<=0 THEN charwi:=gad.font.ySize; END;
  gad.minwi:=gad.minwi+i*charwi+12;
  gad.minhe:=gad.font.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:StringGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  rg.GetString(gad.gadget,gad.string^);
  gad.gadget:=rg.SetStringGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.maxchars,gmb.prev);
  rg.SetString(gad.gadget,gad.string^);
END Resize;

PROCEDURE (object:StringGadget) Destruct*;

BEGIN
  (* $IFNOT GarbageCollector *)
    IF object.string#NIL THEN
      DISPOSE(object.string);
    END;
  (* $END *)
  object.Destruct^;
END Destruct;

PROCEDURE (gad:StringGadget) KeyboardAction*;

VAR bool : BOOLEAN;

BEGIN
  bool:=I.ActivateGadget(gad.gadget^,gad.iwind,NIL);
END KeyboardAction;

PROCEDURE (gad:StringGadget) CheckInput*():BOOLEAN;
(* FALSE if error. *)

VAR string     : POINTER TO ARRAY OF CHAR;
    long       : LONGINT;
    pos,bcount,
    err        : INTEGER;
    ret,changed: BOOLEAN;

BEGIN
  long:=LEN(gad.string^)+1; IF long<10 THEN long:=10; END;
  NEW(string,long);
  rg.GetString(gad.gadget,string^);
  ret:=TRUE;
  IF gad.type=stringType THEN
  ELSIF gad.type=integerType THEN
    ret:=c.StringToInt(string^,long);
    changed:=FALSE;
    IF long<gad.minint    THEN long:=gad.minint; changed:=TRUE;
    ELSIF long>gad.maxint THEN long:=gad.maxint; changed:=TRUE; END;
    IF ret THEN
      gad.long:=long;
      IF changed THEN
        changed:=c.IntToString(long,string^,7);
        tt.Clear(string^);
        gad.SetString(string^);
      END;
    END;
  ELSIF gad.type=realType THEN
    pos:=0; bcount:=0; err:=0;
    ft.SyntaxCheck(string^,pos,bcount,err);
    IF err=0 THEN
      gad.real:=ft.ExpressionToReal(string^);
      changed:=FALSE;
      IF gad.real<gad.minreal THEN gad.real:=gad.minreal; changed:=TRUE;
      ELSIF gad.real>gad.maxreal THEN gad.real:=gad.maxreal; changed:=TRUE; END;
      IF changed THEN
        changed:=lrc.RealToString(gad.real,string^,7,7,FALSE);
        tt.Clear(string^);
        gad.SetString(string^);
      END;
      ret:=TRUE;
    ELSE
      ret:=FALSE;
    END;
  END;
  DISPOSE(string);
  RETURN ret;
END CheckInput;

PROCEDURE (gad:StringGadget) GetString*(VAR string:ARRAY OF CHAR);

BEGIN
  IF gad.CheckInput() THEN
    rg.GetString(gad.gadget,gad.string^);
    COPY(gad.string^,string);
  ELSE
    rg.SetString(gad.gadget,gad.string^);
  END;
END GetString;

PROCEDURE (gad:StringGadget) SetString*(string:ARRAY OF CHAR);

BEGIN
  COPY(string,gad.string^);
  rg.SetString(gad.gadget,gad.string^);
  gad.Refresh;
  gad.real:=ft.ExpressionToReal(gad.string^);
END SetString;

(* Don't use SetValue() here! This will cause problems with
   gmb.InputEvent. *)

PROCEDURE (gad:StringGadget) SetMinMaxInt*(min,max:LONGINT);

BEGIN
  gad.minint:=min;
  gad.maxint:=max;
END SetMinMaxInt;

PROCEDURE (gad:StringGadget) SetMinMaxReal*(min,max:LONGREAL);

BEGIN
  gad.minreal:=min;
  gad.maxreal:=max;
END SetMinMaxReal;

PROCEDURE (gad:StringGadget) SetInteger*(long:LONGINT);

VAR string : ARRAY 80 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  IF long<gad.minint    THEN long:=gad.minint;
  ELSIF long>gad.maxint THEN long:=gad.maxint; END;
  gad.long:=long;
  bool:=c.IntToString(long,string,7);
  tt.Clear(string);
  IF bool THEN
    gad.SetString(string);
  END;
END SetInteger;

PROCEDURE (gad:StringGadget) GetInteger*():LONGINT;

VAR string : ARRAY 80 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  bool:=gad.CheckInput();
  gad.GetString(string);  (* Must be outside IF-construction to set up old gadget text on error. *)
  IF bool THEN
    RETURN gad.long;
  END;
END GetInteger;

PROCEDURE (gad:StringGadget) SetReal*(real:LONGREAL);

VAR string : ARRAY 80 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  IF gad.real<gad.minreal    THEN gad.real:=gad.minreal;
  ELSIF gad.real>gad.maxreal THEN gad.real:=gad.maxreal; END;
  gad.real:=real;
  bool:=lrc.RealToString(real,string,7,7,FALSE);
  tt.Clear(string);
  IF bool THEN
    gad.SetString(string);
  END;
END SetReal;

PROCEDURE (gad:StringGadget) GetReal*():LONGREAL;

VAR string : ARRAY 80 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  bool:=gad.CheckInput();
  gad.GetString(string);
  IF bool THEN
    RETURN gad.real;
  END;
END GetReal;

PROCEDURE (gad:StringGadget) SetType*(type:INTEGER);

BEGIN
  gad.type:=type;
END SetType;

PROCEDURE (gad:StringGadget) SetMinVisible*(minvisible:INTEGER);

BEGIN
  gad.minvisible:=minvisible;
END SetMinVisible;

PROCEDURE SetStringGadget*(text:e.STRPTR;maxchars,type:INTEGER):StringGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetStringGadget(-gmb.tfont.ySize*10-10,-gmb.tfont.ySize*2-10,gmb.tfont.ySize*10,gmb.tfont.ySize*2,text,maxchars,gmb.prev);
  node:=NIL;
  NEW(node(StringGadget));
  IF node#NIL THEN
    IF gmb.laststring#NIL THEN
      gmb.laststring(StringGadget).nextstring:=node(StringGadget);
    ELSE
      gmb.firststring:=node;
    END;
    node(StringGadget).nextstring:=gmb.firststring(StringGadget);
    gmb.laststring:=node(StringGadget);
    gmb.AddObject(node);
    WITH node: StringGadget DO
      NEW(node.string,maxchars+1);
      node.text:=text;
      node.maxchars:=maxchars;
      node.minvisible:=maxchars;
      node.type:=type;
      node.minint:=MIN(LONGINT);
      node.maxint:=MAX(LONGINT);
      node.minreal:=MIN(LONGREAL);
      node.maxreal:=MAX(LONGREAL);
      IF node.minvisible>20 THEN
        node.minvisible:=20;
      END;
      node.color:=gmb.std.textcol;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.autoactive:=TRUE;
      node.sizex:=5;
      node.sizey:=-1;
      IF text#NIL THEN
        node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^))+12;
      ELSE
        node.minwi:=0;
      END;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(StringGadget);
END SetStringGadget;

PROCEDURE (gad:StringGadget) InputEvent*(mes:I.IntuiMessagePtr);

VAR strgad : StringGadget;
    bool   : BOOLEAN;

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      IF ~gad.CheckInput() THEN
        Beep.Beep(TRUE);
        bool:=I.ActivateGadget(gad.gadget^,gad.iwind,NIL);
      ELSE
        strgad:=gad.nextstring;
        LOOP
          IF strgad=NIL THEN EXIT; END;
          IF NOT(strgad.disabled) THEN
            bool:=I.ActivateGadget(strgad.gadget^,strgad.iwind,NIL);
            EXIT;
          END;
          IF strgad=gad THEN EXIT; END;
          strgad:=strgad.nextstring;
        END;
      END;
    END;
  END;
  gad.InputEvent^(mes);
END InputEvent;



(* CycleGadget *)

TYPE CycleGadget * = POINTER TO CycleGadgetDesc;
     CycleGadgetDesc * = RECORD(gmb.GadgetDesc)
       textarray   : UNTRACED POINTER TO ARRAY MAX(INTEGER) OF e.STRPTR;
       numactive - : INTEGER;
     END;

PROCEDURE (gad:CycleGadget) Init*;

VAR maxwi,wi,i : INTEGER;

BEGIN
  i:=0;
  WHILE gad.textarray[i]#NIL DO
    wi:=g.TextLength(gmb.fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    INC(i);
  END;
  IF gad.text#NIL THEN
    gad.minwi:=gad.textwi+wi+gad.font.ySize*4; (* was: +wi+28 *)
  ELSE
    gad.minwi:=wi+28;
  END;
  gad.minhe:=gad.font.ySize+6;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:CycleGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetCycleGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.textarray,gad.numactive,gmb.prev);
END Resize;

PROCEDURE (gad:CycleGadget) KeyboardAction*;

BEGIN
  INC(gad.numactive);
  IF gad.textarray[gad.numactive]=NIL THEN
    gad.numactive:=0;
  END;
  gad.SetValue(gad.numactive);
  gmb.PressBoolean(gad.gadget,gad.iwind);
END KeyboardAction;

PROCEDURE (gad:CycleGadget) SetValue*(numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.cyActive,numactive,
                                              u.done);
  gad.numactive:=SHORT(numactive);
END SetValue;

PROCEDURE (gad:CycleGadget) GetValue*():LONGINT;

BEGIN
  RETURN gad.numactive;
END GetValue;

PROCEDURE (gad:CycleGadget) Change*(texts:s.ADDRESS;numactive:INTEGER);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.cyLabels,texts,
                                              gt.cyActive,numactive,
                                              u.done);
  gad.numactive:=numactive;
  gad.textarray:=texts;
END Change;

PROCEDURE SetCycleGadget*(text:e.STRPTR;textarray:s.ADDRESS;numactive:INTEGER):CycleGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetCycleGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*10,gmb.font.ySize*2,text,textarray,numactive,gmb.prev);
  node:=NIL;
  NEW(node(CycleGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: CycleGadget DO
      node.text:=text;
      node.textarray:=textarray;
      node.numactive:=numactive;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=0;
      node.sizey:=0;
      node.minwi:=10;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(CycleGadget);
END SetCycleGadget;



(* CheckboxGadget *)

TYPE CheckboxGadget * = POINTER TO CheckboxGadgetDesc;
     CheckboxGadgetDesc * = RECORD(gmb.GadgetDesc)
       checked - : BOOLEAN;
     END;

PROCEDURE (gad:CheckboxGadget) Init*;

BEGIN
  gad.minwi:=gad.textwi;
  gad.minwi:=gad.minwi+SHORT(SHORT(gt.checkboxWidth/8*gad.fontx));
  gad.minhe:=SHORT(SHORT(gt.checkboxHeight/8*gad.font.ySize));
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:CheckboxGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetCheckBoxGadget(gad.xpos+gad.textwi,gad.ypos,gad.width-gad.textwi,gad.height,gad.text,gad.checked,gmb.prev);
END Resize;

PROCEDURE (gad:CheckboxGadget) Check*(checked:BOOLEAN);

VAR long : LONGINT;

BEGIN
  gad.checked:=checked;
  IF checked THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.cbChecked,long,
                                              u.done);
END Check;

PROCEDURE (gad:CheckboxGadget) Checked*():BOOLEAN;

BEGIN
  RETURN gad.checked;
END Checked;

PROCEDURE (gad:CheckboxGadget) KeyboardAction*;

BEGIN
  gad.checked:=NOT(gad.checked);
  gad.Check(gad.checked);
  I.RefreshGList(gad.gadget,gad.iwind,NIL,1);
END KeyboardAction;

PROCEDURE SetCheckboxGadget*(text:e.STRPTR;checked:BOOLEAN):CheckboxGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetBooleanGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*2,gmb.font.ySize,text,gmb.prev);
  node:=NIL;
  NEW(node(CheckboxGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: CheckboxGadget DO
      node.root:=gmb.actroot;
      node.text:=text;
      node.checked:=checked;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.fontx:=node.root.fontx;
      node.disabled:=FALSE;
      node.sizex:=-1;
      node.sizey:=-1;
      node.minwi:=10;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(CheckboxGadget);
END SetCheckboxGadget;

PROCEDURE (gad:CheckboxGadget) InputEvent*(mes:I.IntuiMessagePtr);

VAR bool : BOOLEAN;

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.checked:=NOT(gad.checked);
    END;
  END;
  gad.InputEvent^(mes);
END InputEvent;



(* PaletteGadget *)

TYPE PaletteGadget * = POINTER TO PaletteGadgetDesc;
     PaletteGadgetDesc * = RECORD(gmb.GadgetDesc)
       depth,
       numcolors,
       actcolor - ,
       titlehe    : INTEGER;
     END;

PROCEDURE (gad:PaletteGadget) Init*;

BEGIN
  gad.titlehe:=SHORT(SHORT(gad.font.ySize*1.1+0.5));
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  gad.minwi:=100;
  gad.minhe:=gad.font.ySize*2+gad.titlehe;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:PaletteGadget) Resize*;

VAR i : INTEGER;

BEGIN
  gad.iwind:=gad.root.iwind;
  i:=0;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  gad.gadget:=rg.SetPaletteGadget(gad.xpos+i,gad.ypos+gad.titlehe,gad.width-i,gad.height-gad.titlehe,NIL,gad.depth,gad.numcolors,gad.actcolor,gmb.prev);
END Resize;

PROCEDURE (gad:PaletteGadget) Refresh*;

VAR rast : g.RastPortPtr;

BEGIN
  rast:=gad.iwind.rPort;
  g.SetAPen(rast,gad.color);
  g.Move(rast,gad.xpos,gad.ypos+rast.font.baseline);
  g.Text(rast,gad.text^,st.Length(gad.text^));
  gad.Refresh^;
END Refresh;

PROCEDURE (gad:PaletteGadget) SetValue*(actcolor:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.paColor,actcolor,
                                              u.done);
  gad.actcolor:=SHORT(actcolor);
END SetValue;

PROCEDURE (gad:PaletteGadget) GetValue*():LONGINT;

BEGIN
  RETURN gad.actcolor;
END GetValue;

PROCEDURE SetPaletteGadget*(text:e.STRPTR;depth,numcols,actcol:INTEGER):PaletteGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetPaletteGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*10,gmb.font.ySize*2,NIL,depth,numcols,actcol,gmb.prev);
  node:=NIL;
  NEW(node(PaletteGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: PaletteGadget DO
      node.text:=text;
      node.color:=gmb.std.textcol;
      node.depth:=depth;
      node.numcolors:=numcols;
      node.actcolor:=actcol;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=5;
      node.sizey:=5;
      node.minwi:=100;
      node.minhe:=node.font.ySize*2;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(PaletteGadget);
END SetPaletteGadget;



(* RadioButtons *)

TYPE RadioButtons * = POINTER TO RadioButtonsDesc;
     RadioButtonsDesc * = RECORD(gmb.GadgetDesc)
       textarray   : UNTRACED POINTER TO ARRAY MAX(INTEGER) OF e.STRPTR;
       numactive - : INTEGER;
     END;

PROCEDURE (gad:RadioButtons) Init*;

VAR maxwi,wi,wi2,i : INTEGER;

BEGIN
  i:=0;
  wi:=0;
  WHILE gad.textarray[i]#NIL DO
    wi2:=g.TextLength(gmb.fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    IF wi2>wi THEN
      wi:=wi2;
    END;
    INC(i);
  END;
  gad.minwi:=wi+SHORT(SHORT(gt.mxWidth/8*gad.font.ySize))+gad.font.ySize; (* +tfont.xSize *)
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize+wi+28;
  ELSE
    gad.minwi:=wi+28;
  END;*)
  gad.minhe:=(SHORT(SHORT(gt.mxHeight/8*gad.font.ySize))+(gad.font.ySize DIV 8))*i-(gad.font.ySize DIV 8);
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:RadioButtons) Resize*;

VAR i,wi,wi2 : INTEGER;

BEGIN
  gad.iwind:=gad.root.iwind;
  i:=0;
  wi:=0;
  WHILE gad.textarray[i]#NIL DO
    wi2:=g.TextLength(gmb.fontrast,gad.textarray[i]^,st.Length(gad.textarray[i]^));
    IF wi2>wi THEN
      wi:=wi2;
    END;
    INC(i);
  END;
  wi:=wi+gad.font.ySize;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  gad.gadget:=rg.SetRadioGadget(gad.xpos+wi,gad.ypos,gad.width-wi,SHORT(SHORT(gt.mxHeight/8*gad.font.ySize)),gad.text,gad.textarray,gad.numactive,SHORT(SHORT(gt.mxHeight/8*gad.font.ySize))-gad.font.ySize+(gad.font.ySize DIV 8),gmb.prev);
END Resize;

PROCEDURE (gad:RadioButtons) SetValue*(numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.mxActive,numactive,
                                              u.done);
  gad.numactive:=SHORT(numactive);
END SetValue;

PROCEDURE (gad:RadioButtons) GetValue*():LONGINT;

BEGIN
  RETURN gad.numactive;
END GetValue;

PROCEDURE SetRadioButtons*(textarray:s.ADDRESS;numactive:INTEGER):RadioButtons;

(* NULL-terminated textarray ARRAY OF Exec.STRPTR. *)

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetRadioGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*10,gmb.font.ySize*2,NIL,textarray,numactive,1,gmb.prev);
  node:=NIL;
  NEW(node(RadioButtons));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: RadioButtons DO
      node.text:=NIL;
      node.textarray:=textarray;
      node.numactive:=numactive;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=-1;
      node.sizey:=-1;
      node.minwi:=gt.mxWidth;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(RadioButtons);
END SetRadioButtons;



(* SliderGadget *)

TYPE SliderGadget * = POINTER TO SliderGadgetDesc;
     SliderGadgetDesc * = RECORD(gmb.GadgetDesc)
       min          - ,
       max          - ,
       level        - ,
       levellen     - ,
       orientation  - : LONGINT;
       formatstring - : e.STRPTR;
     END;

PROCEDURE (gad:SliderGadget) Init*;

BEGIN
(*  IF gad.text#NIL THEN
    gad.minwi:=TextLength(gad,gad.text)+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  gad.minwi:=SHORT((gad.levellen+1)*gad.font.ySize)+10*gad.font.ySize;
  gad.minhe:=gad.font.ySize+2;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:SliderGadget) Resize*;

VAR i,ydif : INTEGER;

BEGIN
  gad.iwind:=gad.root.iwind;
(*  IF gad.text#NIL THEN
    i:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    i:=0;
  END;*)
  IF gad.levellen>0 THEN
    i:=SHORT(gad.levellen*gad.font.ySize)+gad.font.ySize;
  ELSE i:=0; END;
  ydif:=SHORT(SHORT(gad.font.ySize/8+0.5));
  gad.gadget:=rg.SetSliderGadget(gad.xpos+i,gad.ypos+ydif,gad.width-i,gad.height-2*ydif,gad.text,gad.min,gad.max,gad.level,gad.levellen,gad.orientation,gad.formatstring,gmb.prev);
END Resize;

PROCEDURE (gad:SliderGadget) SetValue*(level:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.slLevel,level,
                                              u.done);
  gad.level:=level;
END SetValue;

PROCEDURE (gad:SliderGadget) GetValue*():LONGINT;

BEGIN
  RETURN gad.level;
END GetValue;

PROCEDURE (gad:SliderGadget) Change*(min,max,level:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.slMin,min,
                                              gt.slMax,max,
                                              gt.slLevel,level,
                                              u.done);
  gad.min:=min;
  gad.max:=max;
  gad.level:=level;
END Change;

PROCEDURE SetSliderGadget*(min,max,level,levellen:LONGINT;formatstring:e.STRPTR):SliderGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetSliderGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*10,gmb.font.ySize*2,NIL,min,max,level,levellen,I.lorientHoriz,formatstring,gmb.prev);
  node:=NIL;
  NEW(node(SliderGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: SliderGadget DO
      node.text:=NIL;
      node.min:=min;
      node.max:=max;
      node.level:=level;
      node.levellen:=levellen;
      node.formatstring:=formatstring;
      node.orientation:=I.lorientHoriz;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=5;
      node.sizey:=0;
      node.minwi:=SHORT(2*levellen*node.font.ySize);
      node.minhe:=node.font.ySize+2;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(SliderGadget);
END SetSliderGadget;



(* ScrollGadget *)

TYPE ScrollerGadget * = POINTER TO ScrollerGadgetDesc;
     ScrollerGadgetDesc * = RECORD(gmb.GadgetDesc)
       total       - ,
       visible     - ,
       top         - : LONGINT;
       arrows      - ,
       pressed       : BOOLEAN;
       orientation - : LONGINT;
     END;

PROCEDURE (gad:ScrollerGadget) Init*;

BEGIN
(*  IF gad.text#NIL THEN
    gad.minwi:=g.TextLength(fontrast,gad.text^,st.Length(gad.text^))+tfont.xSize;
  ELSE
    gad.minwi:=0;
  END;*)
  IF gad.orientation=I.lorientVert THEN
    gad.minhe:=(gad.font.ySize+2)*3;
  ELSIF gad.orientation=I.lorientHoriz THEN
    gad.minwi:=gad.fontx*2;
    IF gad.minwi>20 THEN gad.minwi:=SHORT(SHORT(gad.minwi*0.8)); END;
(*    gad.minwi:=(gad.font.ySize+2)*3;*)
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ScrollerGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetScrollerGadget(gad.xpos,gad.ypos,gad.width,gad.height,gad.text,gad.total,gad.visible,gad.top,gad.arrows,gad.orientation,gmb.prev);
END Resize;

PROCEDURE (gad:ScrollerGadget) SetValue*(top:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gt.scTop,top,
                                              u.done);
  gad.top:=top;
END SetValue;

PROCEDURE (gad:ScrollerGadget) GetValue*():LONGINT;

BEGIN
  IF gt.base.version>=39 THEN gad.top:=rg.GetScroller(gad.gadget,gad.iwind); END;
  RETURN gad.top;
END GetValue;

PROCEDURE (gad:ScrollerGadget) Change*(total,visible,top:LONGINT);

BEGIN
  gad.total:=total;
  gad.visible:=visible;
  gad.top:=top;
  rg.SetScroller(gad.gadget,gad.iwind,gad.total,gad.visible,gad.top);
END Change;

PROCEDURE SetScrollerGadget*(total,visible,top:LONGINT;arrows:BOOLEAN;orientation:LONGINT;thickness:INTEGER):ScrollerGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetScrollerGadget(-gmb.font.ySize*10-10,-gmb.font.ySize*2-10,gmb.font.ySize*10,gmb.font.ySize*2,NIL,total,visible,top,arrows,orientation,gmb.prev);
  node:=NIL;
  NEW(node(ScrollerGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: ScrollerGadget DO
      node.root:=gmb.actroot;
      node.text:=NIL;
      node.total:=total;
      node.visible:=visible;
      node.top:=top;
      node.arrows:=arrows;
      node.orientation:=orientation;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.fontx:=node.root.fontx;
      node.disabled:=FALSE;
      node.pressed:=FALSE;
      node.sizex:=5;
      node.sizey:=5;
      IF orientation=I.lorientVert THEN
        node.sizex:=-1;
      ELSIF orientation=I.lorientHoriz THEN
        node.sizey:=-1;
      END;
      IF thickness=-1 THEN
        node.minwi:=node.font.ySize*2;
        node.minhe:=node.font.ySize;
      ELSE
        node.minwi:=thickness;
        node.minhe:=thickness;
      END;
      node.autoout:=TRUE;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(ScrollerGadget);
END SetScrollerGadget;

PROCEDURE (gad:ScrollerGadget) InputEvent*(mes:I.IntuiMessagePtr);

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.SetValue(mes.code);
      gad.pressed:=FALSE;
    END;
  ELSIF I.gadgetDown IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.SetValue(mes.code);
      gad.pressed:=TRUE;
    END;
  ELSIF (I.mouseMove IN mes.class) & (gad.pressed) THEN
    gad.SetValue(mes.code);
  END;
END InputEvent;



(* Listview *)

TYPE PrintProc * = PROCEDURE(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);
     ListView * = POINTER TO ListViewDesc;
     ListViewDesc * = RECORD(gmb.GadgetDesc)
       scrollgad  - ,
       stringgad  - : I.GadgetPtr;
       scrollerwi -,
       stringhe   - : INTEGER;
       stringgadact-: BOOLEAN;
       maxchars   - : INTEGER;
       total      - ,
       visible    - ,
       top        - ,
       actentry   - : LONGINT;
       itemheight - : INTEGER;
       datalist   - : l.List;
       user       - : e.APTR;
       printproc  - : PrintProc;
       standard   - : BOOLEAN;
       noentry    - : e.STRPTR;
       string     - : POINTER TO ARRAY OF CHAR;
       sec-,mic   - : LONGINT;
       titlehe    - : INTEGER;
     END;

CONST newActEntry   * = 1;
      doubleClicked * = 2;
      newString     * = 3;
      posChanged    * = 4;

PROCEDURE (gad:ListView) Init*;

VAR i,wi : INTEGER;

BEGIN
  i:=gad.maxchars;
  IF i>10 THEN
    i:=10;
  ELSIF i<4 THEN
    i:=4;
  END;
  gad.minwi:=gad.font.ySize*2+gad.font.ySize*i;
  IF gad.userminwi>0 THEN gad.minwi:=gad.userminwi; END;
  gad.minhe:=(gad.font.ySize+2)*3+4;
  IF gad.stringgadact THEN
    gad.minhe:=gad.minhe+gad.font.ySize+6;
  END;
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

PROCEDURE (gad:ListView) Resize*;

VAR rast : g.RastPortPtr;
    i    : INTEGER;

BEGIN
  gad.iwind:=gad.root.iwind;
  rast:=gad.iwind.rPort;
  gad.scrollerwi:=gad.fontx*2;
  IF gad.scrollerwi>20 THEN gad.scrollerwi:=SHORT(SHORT(gad.scrollerwi*0.8)); END;
  gad.itemheight:=gad.font.ySize+2;
  i:=0;
  gad.stringhe:=0;
  IF gad.stringgadact THEN
    gad.stringhe:=gad.font.ySize+6;
    i:=gad.stringhe;
    rg.GetString(gad.stringgad,gad.string^);
    gad.stringgad:=rg.SetStringGadget(gad.xpos,gad.ypos+gad.height-i,gad.width,i,NIL,gad.maxchars,gmb.prev);
    rg.SetString(gad.stringgad,gad.string^);
  END;
  gad.titlehe:=0;
  IF gad.text#NIL THEN
    gad.titlehe:=SHORT(SHORT(gad.font.ySize*1.1+0.5));
(*    g.SetAPen(rast,gad.color);
    g.Move(rast,gad.xpos,gad.ypos+rast.font.baseline);
    g.Text(rast,gad.text^,st.Length(gad.text^));*)
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
(*  gt.DrawBevelBox(rast,gad.xpos,gad.ypos+gad.titlehe,gad.width-gad.scrollerwi,gad.height-i-gad.titlehe,
                                        gt.bbFrameType,gt.bbftButton,
                                        gt.visualInfo,gad.root.vinfo,
                                        u.done);*)
  gad.scrollgad:=rg.SetScrollerGadget(gad.xpos+gad.width-gad.scrollerwi,gad.ypos+gad.titlehe,gad.scrollerwi,gad.height-i-gad.titlehe,NIL,gad.total,gad.visible,gad.top,TRUE,I.lorientVert,gmb.prev);
(*  gad.window:=NIL;*)
(*  gad.Refresh;*)
END Resize;

PROCEDURE (object:ListView) Destruct*;

BEGIN
  (* $IFNOT GarbageCollector *)
    IF object.string#NIL THEN
      DISPOSE(object.string);
    END;
  (* $END *)
  object.Destruct^;
END Destruct;

PROCEDURE (gad:ListView) SetValue*(actentry:LONGINT);

BEGIN
  IF (gad.standard) AND (gad.datalist#NIL) THEN
    gad.total:=gad.datalist.nbElements();
  END;
  gad.actentry:=actentry;
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

PROCEDURE (gad:ListView) GetValue*():LONGINT;

BEGIN
  RETURN gad.actentry;
END GetValue;

PROCEDURE (gad:ListView) SetNoEntryText*(text:e.STRPTR);

BEGIN
  gad.noentry:=text;
END SetNoEntryText;

PROCEDURE (gad:ListView) ChangeListView*(datalist:l.List;actentry:INTEGER);

BEGIN
  gad.datalist:=datalist;
  IF gad.datalist=NIL THEN
    gad.total:=0;
  END;
  gad.SetValue(actentry);
END ChangeListView;

PROCEDURE (gad:ListView) ChangeListViewSpecial*(total:INTEGER;printproc:PrintProc);

BEGIN
  IF total>=0 THEN
    gad.total:=total;
    gad.standard:=FALSE;
  ELSE
    gad.standard:=TRUE;
  END;
  gad.printproc:=printproc;
  gad.Refresh;
END ChangeListViewSpecial;

PROCEDURE (gad:ListView) Refresh*;

VAR i         : LONGINT;
    x,y,
    width     : INTEGER;
    rast      : g.RastPortPtr;
    noentry,
    string    : UNTRACED POINTER TO ARRAY OF CHAR;
    textlines : UNTRACED POINTER TO ARRAY OF e.STRPTR;
    length,
    linenum,
    maxlines  : INTEGER;

  PROCEDURE Space(string:ARRAY OF CHAR):INTEGER;

  VAR i     : INTEGER;

  BEGIN
    i:=0;
    LOOP
      IF string[i]=0X THEN RETURN -1; END;
      IF string[i]=" " THEN
        RETURN i;
      END;
      INC(i);
    END;
  END Space;

BEGIN
  IF gad.iwind#NIL THEN
    rast:=gad.iwind.rPort;
  (*  g.SetAPen(rast,0);*)
    g.SetDrMd(rast,g.jam1);
  (*  g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-gad.scrollerwi-3,gad.ypos+gad.height-gad.stringhe-2);*)
    IF gad.text#NIL THEN
      g.SetAPen(rast,gad.color);
      g.Move(rast,gad.xpos,gad.ypos+rast.font.baseline);
      g.Text(rast,gad.text^,st.Length(gad.text^));
    END;
    gt.DrawBevelBox(rast,gad.xpos,gad.ypos+gad.titlehe,gad.width-gad.scrollerwi,gad.height-gad.stringhe-gad.titlehe,
                                          gt.bbFrameType,gt.bbftButton,
                                          gt.visualInfo,gad.root.vinfo,
                                          u.done);
    IF (gad.standard) AND (gad.datalist#NIL) THEN
      gad.total:=gad.datalist.nbElements();
    END;
    IF gad.stringgad#NIL THEN
      I.RefreshGList(gad.stringgad,gad.iwind,NIL,1);
    END;
    rg.SetScroller(gad.scrollgad,gad.iwind,gad.total,gad.visible,gad.top);
    width:=gad.width-gad.scrollerwi-4;
    x:=gad.xpos+2;
    y:=gad.ypos+gad.titlehe+2;
    IF gad.total>0 THEN
      IF gad.stringgad#NIL THEN
        gt.SetGadgetAttrs(gad.stringgad^,gad.iwind,NIL,I.gaDisabled,I.LFALSE,
                                                       u.done);
      END;

      i:=gad.top;
      WHILE (i<gad.total) AND (y+gad.itemheight<gad.ypos+gad.height-gad.stringhe-1) DO
        IF i=gad.actentry THEN
          g.SetAPen(rast,3);
        ELSE
          g.SetAPen(rast,0);
        END;
        g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
        g.SetAPen(rast,1);
        gad.printproc(rast,x+2,y+gmb.tfont.baseline+1,width-4,i,gad.datalist,gad.user);
        INC(y,gad.itemheight);
        INC(i);
      END;
      g.SetAPen(rast,0);
      g.RectFill(rast,x,y,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
    ELSE
      IF gad.stringgad#NIL THEN
        gt.SetGadgetAttrs(gad.stringgad^,gad.iwind,NIL,I.gaDisabled,I.LTRUE,
                                                       u.done);
      END;

      g.SetAPen(rast,0);
      g.RectFill(rast,x,y,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
      g.SetAPen(rast,1);
      NEW(noentry,st.Length(gad.noentry^)+1);
      NEW(string,st.Length(gad.noentry^)+1);
      COPY(gad.noentry^,noentry^);

      maxlines:=(gad.height-gad.stringhe-4) DIV gad.font.ySize;
      NEW(textlines,maxlines);
      FOR i:=0 TO maxlines-1 DO
        textlines[i]:=NIL;
      END;

      linenum:=0;
      WHILE (st.Length(noentry^)>0) AND (linenum<maxlines) DO
        COPY(noentry^,string^);
        tt.CutStringToLength(rast,string^,width);
        IF st.Length(string^)<st.Length(noentry^) THEN
          i:=Space(string^);
        ELSE
          i:=-1;
        END;
        IF i=-1 THEN
          i:=SHORT(st.Length(string^)-1);
        ELSE
          string[i]:=0X;
        END;
        st.Delete(noentry^,0,i+1);
        NEW(textlines[linenum]);
        COPY(string^,textlines[linenum]^);
        INC(linenum);
      END;
      y:=y+((gad.height-gad.stringhe-4) DIV 2)-(((linenum+1)*gad.font.ySize) DIV 2)+rast.font.baseline;
      FOR i:=0 TO linenum-1 DO
        length:=g.TextLength(rast,textlines[i]^,st.Length(textlines[i]^));
        tt.Print(x+(width DIV 2)-(length DIV 2),y,textlines[i],rast);
        INC(y,gad.font.ySize);
      END;

      FOR i:=0 TO maxlines-1 DO
        DISPOSE(textlines[i]);
      END;
      DISPOSE(textlines);
      DISPOSE(string);
      DISPOSE(noentry);
    END;
  END;
END Refresh;

PROCEDURE (gad:ListView) BackFill(el:LONGINT;highlight:BOOLEAN);

VAR rast      : g.RastPortPtr;
    x,y,width : INTEGER;

BEGIN
  IF gad.iwind#NIL THEN
    rast:=gad.iwind.rPort;
    IF (el>=gad.top) AND (el<gad.top+gad.visible) THEN
      IF highlight THEN
        g.SetAPen(rast,3);
      ELSE
        g.SetAPen(rast,0);
      END;
      width:=gad.width-gad.scrollerwi-4;
      x:=gad.xpos+2;
      y:=gad.ypos+gad.titlehe+2;
      y:=SHORT(y+(el-gad.top)*gad.itemheight);
      g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
      g.SetAPen(rast,1);
      gad.printproc(rast,x+2,y+gmb.tfont.baseline+1,width-4,el,gad.datalist,gad.user);
    END;
  END;
END BackFill;

PROCEDURE (gad:ListView) Scroll(dir:INTEGER);

VAR rast        : g.RastPortPtr;
    i           : LONGINT;
    x,y,width   : INTEGER;

BEGIN
  IF gad.iwind#NIL THEN
    IF ((dir<0) AND (gad.top+dir>=0)) OR ((dir>0) AND (gad.top+dir<=gad.total-gad.visible)) THEN
      rast:=gad.iwind.rPort;
      g.SetDrMd(rast,g.jam1);
      width:=gad.width-gad.scrollerwi-4;
      x:=gad.xpos+2;
      y:=gad.ypos+gad.titlehe+2;
      g.ScrollRaster(rast,0,dir*gad.itemheight,x,y,x+width-1,gad.ypos+gad.height-gad.stringhe-2);
      gad.top:=gad.top+dir;
      IF dir=1 THEN
        y:=SHORT(y+(gad.visible-1)*gad.itemheight);
        i:=gad.top+gad.visible-1;
        IF i=gad.actentry THEN
          g.SetAPen(rast,3);
        ELSE
          g.SetAPen(rast,0);
        END;
        g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
        g.SetAPen(rast,1);
        gad.printproc(rast,x+2,y+gmb.tfont.baseline+1,width-4,i,gad.datalist,gad.user);
      ELSIF dir=-1 THEN
        g.SetAPen(rast,0);
        g.RectFill(rast,x,SHORT(y+gad.visible*gad.itemheight),x+width-1,gad.ypos+gad.height-gad.stringhe-2);
        i:=gad.top;
        IF i=gad.actentry THEN
          g.SetAPen(rast,3);
        ELSE
          g.SetAPen(rast,0);
        END;
        g.RectFill(rast,x,y,x+width-1,y+gad.itemheight-1);
        g.SetAPen(rast,1);
        gad.printproc(rast,x+2,y+gmb.tfont.baseline+1,width-4,i,gad.datalist,gad.user);
      END;
    END;
  END;
END Scroll;

PROCEDURE (gad:ListView) RefreshString*;

VAR bool : BOOLEAN;

BEGIN
  rg.SetString(gad.stringgad,gad.string^);
  IF gad.iwind#NIL THEN
    I.RefreshGList(gad.stringgad,gad.iwind,NIL,1);
    bool:=I.ActivateGadget(gad.stringgad^,gad.iwind,NIL);
  END;
END RefreshString;

PROCEDURE (gad:ListView) Disable*(disable:BOOLEAN);

VAR long : LONGINT;

BEGIN
  gad.disabled:=disable;
  IF disable THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gt.SetGadgetAttrs(gad.scrollgad^,gad.iwind,NIL,I.gaDisabled,long,
                                                 u.done);
  gt.SetGadgetAttrs(gad.stringgad^,gad.iwind,NIL,I.gaDisabled,long,
                                                 u.done);
END Disable;

(*PROCEDURE (gad:ListView) Update*;

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
  rg.SetScroller(gad.gadget,gad.iwind,gad.total,gad.visible,gad.top);
  gad.Refresh;
END Update;
*)
PROCEDURE (gad:ListView) Activate*;

VAR bool : BOOLEAN;

BEGIN
  IF gad.total>0 THEN
    bool:=I.ActivateGadget(gad.stringgad^,gad.iwind,NIL);
  END;
END Activate;

PROCEDURE (gad:ListView) SetString*(string:ARRAY OF CHAR);
(* Activates string gadget, too! *)

VAR bool : BOOLEAN;

BEGIN
  IF gad.stringgad#NIL THEN
    COPY(string,gad.string^);
    gad.RefreshString;
  END;
END SetString;

PROCEDURE (gad:ListView) GetString*(VAR string:ARRAY OF CHAR);

BEGIN
  IF gad.stringgad#NIL THEN
    rg.GetString(gad.stringgad,string);
  END;
END GetString;

PROCEDURE (gad:ListView) SetUser*(user:e.APTR);

BEGIN
  gad.user:=user;
  gad.Refresh;
END SetUser;

PROCEDURE SetListView*(title:e.STRPTR;datalist:l.List;printproc:PrintProc;actentry:INTEGER;stringgadact:BOOLEAN;maxchars:INTEGER):ListView;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  node:=NIL;
  NEW(node(ListView));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: ListView DO
      node.root:=gmb.actroot;
      node.text:=title;
      node.noentry:=s.ADR("No entries!");
      node.gadget:=NIL;
      node.font:=gmb.font;
      node.fontx:=node.root.fontx;
      node.color:=gmb.std.textcol;
      node.disabled:=FALSE;
      node.stringgadact:=stringgadact;
      node.maxchars:=maxchars;
      NEW(node.string,maxchars);
      IF datalist#NIL THEN
        node.total:=datalist.nbElements();
      END;
      node.standard:=TRUE;
      node.visible:=2;
      node.top:=0;
      node.datalist:=datalist;
      node.user:=NIL;
      node.printproc:=printproc;
      node.actentry:=actentry;
      node.itemheight:=node.font.ySize+2;
      node.scrollgad:=rg.SetScrollerGadget(-node.font.ySize*10-10,-node.font.ySize*2-10,node.font.ySize*10,node.font.ySize*2,NIL,node.total,node.visible,node.top,TRUE,I.lorientVert,gmb.prev);
      IF stringgadact THEN
        node.stringgad:=rg.SetStringGadget(-node.font.ySize*10-10,-node.font.ySize*2-10,node.font.ySize*10,node.font.ySize*2,NIL,maxchars,gmb.prev);
      END;
      node.sizex:=10;
      node.sizey:=20;
      node.minwi:=node.font.ySize*2;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(ListView);
END SetListView;

PROCEDURE (gad:ListView) InputEvent*(mes:I.IntuiMessagePtr);

VAR old,x,y,
    oldtop,
    oldact   : LONGINT;
    sec,mic  : LONGINT;
    message  : I.IntuiMessagePtr;

BEGIN
  IF gad.total>0 THEN
    IF I.gadgetDown IN mes.class THEN
      IF mes.iAddress=gad.scrollgad THEN
        gad.top:=mes.code;
        gad.Refresh;
        old:=mes.code;
        REPEAT
          d.Delay(1);
          mes.class:=LONGSET{};
          mes.code:=0;
          mes.iAddress:=NIL;
          REPEAT
            message:=gt.GetIMsg(gad.iwind.userPort);
            IF message#NIL THEN
              e.CopyMemAPTR(message,mes,SIZE(I.IntuiMessage));
              gt.ReplyIMsg(message);
            END;
          UNTIL (message=NIL) OR (I.gadgetUp IN mes.class);
  (*        io.WriteString("New event: ");
          IF I.mouseMove IN class THEN io.WriteString("mouseMove "); END;
          IF I.mouseButtons IN class THEN io.WriteString("mouseButtons "); END;
          IF I.intuiTicks IN class THEN io.WriteString("intuiTicks "); END;
          IF I.gadgetDown IN class THEN io.WriteString("gadgetDown "); END;
          IF I.gadgetUp IN class THEN io.WriteString("gadgetUp "); END;
          IF I.idcmpUpdate IN class THEN io.WriteString("idcmpUpdate "); END;
          io.WriteString(" Code: ");
          io.WriteInt(code,7);
          io.WriteLn;*)
          IF gt.base.version>=39 THEN
            gad.top:=rg.GetScroller(gad.scrollgad,gad.iwind);
          ELSE
            IF (I.mouseMove IN mes.class) AND (mes.code#255) THEN
              gad.top:=mes.code;
            END;
          END;
          IF old#gad.top THEN
            gad.Refresh;
            old:=gad.top;
          END;
        UNTIL I.gadgetUp IN mes.class;
        gad.top:=mes.code;
        gad.Refresh;
        mes.code:=0;
      END;
    ELSIF I.gadgetUp IN mes.class THEN
      IF mes.iAddress=gad.scrollgad THEN
        gad.top:=mes.code;
        gad.Refresh;
      END;
    ELSIF I.mouseButtons IN mes.class THEN
      IF mes.code=I.selectDown THEN
        I.CurrentTime(sec,mic);
        x:=mes.mouseX;
        y:=mes.mouseY-gad.titlehe;
        IF (x>=gad.xpos) AND (x<gad.xpos+gad.width-gad.scrollerwi) AND (y>=gad.ypos) AND (y<gad.ypos+gad.height-gad.stringhe) THEN
          oldact:=gad.actentry;
          REPEAT
            e.WaitPort(gad.iwind.userPort);
            mes.class:=LONGSET{};
            mes.code:=0;
            mes.iAddress:=NIL;
            message:=gt.GetIMsg(gad.iwind.userPort);
            IF message#NIL THEN
              e.CopyMemAPTR(message,mes,SIZE(I.IntuiMessage));
              gt.ReplyIMsg(message);
              IF I.mouseButtons IN mes.class THEN
                x:=mes.mouseX;
                y:=mes.mouseY-gad.titlehe;
              ELSE
                x:=gad.iwind.mouseX;
                y:=gad.iwind.mouseY-gad.titlehe;
              END;
            END;
            old:=gad.actentry;
            oldtop:=gad.top;
            gad.actentry:=gad.top+((y-gad.ypos-2) DIV gad.itemheight);
            IF y>=gad.ypos+2+gad.itemheight*gad.visible THEN
              gad.actentry:=gad.top+gad.visible;
            ELSIF y<gad.ypos+2 THEN
              gad.actentry:=gad.top-1;
            END;
            IF gad.actentry>=gad.total THEN
              gad.actentry:=gad.total-1;
            END;
            IF gad.actentry<0 THEN
              gad.actentry:=0;
            END;
            IF old#gad.actentry THEN
              gad.BackFill(old,FALSE);
              gad.BackFill(gad.actentry,TRUE);
            END;
            IF gad.actentry<gad.top THEN
  (*            gad.top:=gad.actentry;*)
              gad.Scroll(-1);
            ELSIF gad.actentry>=gad.top+gad.visible THEN
  (*            gad.top:=gad.actentry-gad.visible+1;*)
              gad.Scroll(1);
            END;
            IF oldtop#gad.top THEN
  (*            gad.Refresh;*)
              IF oldtop#gad.top THEN
                gt.SetGadgetAttrs(gad.scrollgad^,gad.iwind,NIL,gt.scTop,gad.top,
                                                               u.done);
                d.Delay(3);
              END;
            END;
          UNTIL I.mouseButtons IN mes.class;
          mes.class:=LONGSET{};
          IF oldact#gad.actentry THEN
            mes.iAddress:=gad.scrollgad;
            mes.class:=LONGSET{I.gadgetUp};
            mes.code:=newActEntry;
            gad.sec:=sec;
            gad.mic:=mic;
          ELSE
            IF I.DoubleClick(gad.sec,gad.mic,sec,mic) THEN
              mes.iAddress:=gad.scrollgad;
              mes.class:=LONGSET{I.gadgetUp};
              mes.code:=doubleClicked;
              gad.sec:=0;
              gad.mic:=0;
            ELSE
              gad.sec:=sec;
              gad.mic:=mic;
            END;
          END;
        END;
      END;
    END;
  END;
END InputEvent;



(* GradientSlider *)

TYPE GradientSlider * = POINTER TO GradientSliderDesc;
     GradientSliderDesc * = RECORD(gmb.GadgetDesc)
       pens        - : ARRAY 101 OF INTEGER;
       numpens     - : INTEGER;
       orientation - : LONGINT;
     END;

PROCEDURE (gad:GradientSlider) Init*;

BEGIN
  IF gad.orientation=I.freeVert THEN
    gad.minhe:=(gad.font.ySize+2)*3;
  ELSIF gad.orientation=I.freeHoriz THEN
    gad.minwi:=(gad.font.ySize+2)*3;
  END;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:GradientSlider) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetGradientSlider(gad.xpos,gad.ypos,gad.width,gad.height,s.ADR(gad.pens),gad.orientation,gmb.prev);
END Resize;

PROCEDURE (object:GradientSlider) Destruct*;

VAR long : LONGINT;

BEGIN
  long:=I.RemoveGadget(object.iwind,object.gadget^);
  object.gadget.nextGadget:=NIL;
  I.DisposeObject(object.gadget);
  object.Destruct^;
END Destruct;

PROCEDURE SetGradientSlider*(numpens:INTEGER;thickness:INTEGER):GradientSlider;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetGradientSlider(-50,-50,10,40,s.ADR(gradpens),I.freeVert,gmb.prev);
  node:=NIL;
  NEW(node(GradientSlider));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: GradientSlider DO
      node.text:=NIL;
      IF numpens<=0 THEN
        numpens:=100;
      END;
      node.numpens:=numpens;
      node.pens[0]:=-1;
      node.orientation:=I.freeVert;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=5;
      node.sizey:=5;
      IF node.orientation=I.freeVert THEN
        node.sizex:=-1;
      ELSIF node.orientation=I.freeHoriz THEN
        node.sizey:=-1;
      END;
      IF thickness=-1 THEN
        node.minwi:=node.font.ySize*2;
        node.minhe:=node.font.ySize;
      ELSE
        node.minwi:=thickness;
        node.minhe:=thickness;
      END;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(GradientSlider);
END SetGradientSlider;



(* Colorwheel *)

TYPE ColorWheel * = POINTER TO ColorWheelDesc;
     ColorWheelDesc * = RECORD(gmb.GadgetDesc)
       slider * : gmb.Gadget;
       red    - ,
       green  - ,
       blue   - : INTEGER; (* 0..255 *)
     END;

PROCEDURE (gad:ColorWheel) Init*;

BEGIN
  gad.minwi:=100;
  gad.minhe:=70;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ColorWheel) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetColorWheel(gad.xpos,gad.ypos,gad.width,gad.height,gad.slider.gadget,gmb.prev);
END Resize;

PROCEDURE (object:ColorWheel) Destruct*;

VAR long : LONGINT;

BEGIN
  long:=I.RemoveGadget(object.iwind,object.gadget^);
  object.gadget.nextGadget:=NIL;
  I.DisposeObject(object.gadget);
  object.Destruct^;
END Destruct;

PROCEDURE (gad:ColorWheel) RefreshPens*(view:g.ViewPortPtr);
(* Refreshes color range in gradiet slider. Call PreparePens
   before. *)

VAR numpens,
    actpen  : INTEGER;
    long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;
    slider  : GradientSlider;

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

PROCEDURE (gad:ColorWheel) PreparePens*(view:g.ViewPortPtr);
(* See above *)

VAR actpen : INTEGER;
    slider : GradientSlider;

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

PROCEDURE (gad:ColorWheel) ReleasePens*(view:g.ViewPortPtr);
(* Call when finished. *)

VAR actpen : INTEGER;
    slider : GradientSlider;

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

PROCEDURE (gad:ColorWheel) RefreshWheel*(red,green,blue:LONGINT;view:g.ViewPortPtr);
(* Same as SetColor would do if it exists. *)

VAR rgb  : gd.ColorWheelRGB;
    hsb  : gd.ColorWheelHSB;
    long : LONGINT;

BEGIN
  rgb.red:=bt.IntToRGB(red);
  rgb.green:=bt.IntToRGB(green);
  rgb.blue:=bt.IntToRGB(blue);
  gd.ConvertRGBToHSB(rgb,hsb);
  long:=I.SetGadgetAttrs(gad.gadget^,gad.iwind,NIL,gd.wheelRGB,s.ADR(rgb),u.done);
  gad.RefreshPens(view);
END RefreshWheel;

PROCEDURE (gad:ColorWheel) GetColor*(VAR red,green,blue:LONGINT);

VAR long    : LONGINT;
    hsb     : gd.ColorWheelHSB;
    rgb     : gd.ColorWheelRGB;

BEGIN
  long:=I.GetAttr(gd.wheelRGB,gad.gadget,rgb);
  red:=bt.RGBToInt(rgb.red);
  green:=bt.RGBToInt(rgb.green);
  blue:=bt.RGBToInt(rgb.blue);
END GetColor;

PROCEDURE SetColorWheel*(slider:gmb.Gadget):ColorWheel;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  IF slider#NIL THEN
    gad:=rg.SetColorWheel(-50,-50,40,40,slider.gadget,gmb.prev);
  ELSE
    gad:=rg.SetColorWheel(-50,-50,40,40,NIL,gmb.prev);
  END;
  node:=NIL;
  NEW(node(ColorWheel));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: ColorWheel DO
      node.text:=NIL;
      node.slider:=slider;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=10;
      node.sizey:=10;
      node.minwi:=100;
      node.minhe:=70;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(ColorWheel);
END SetColorWheel;



(* SelectBox *)

TYPE PlotProc * = PROCEDURE(rast:g.RastPortPtr;x,y,width,height,color:INTEGER;num:LONGINT);
     SelectBox * = POINTER TO SelectBoxDesc;
     SelectBoxDesc * = RECORD(gmb.GadgetDesc);
       total,
       active,
       cols,rows,
       titlehe,
       minfieldwi,
       minfieldhe,            (* of one field *)
       spacex,spacey,
       fieldwi,
       fieldhe,
       plotcolor   : INTEGER;
       plotproc    : PlotProc;
       orientation : INTEGER;
     END;

CONST horizOrient * = 0;
      vertOrient  * = 1;

PROCEDURE (gad:SelectBox) Init*;

VAR width : INTEGER;

BEGIN
  gad.titlehe:=SHORT(SHORT(gad.font.ySize*1.1+0.5));
  width:=(gad.minfieldwi+gad.spacex)*gad.cols-gad.spacex;
  gad.minwi:=gmb.TextLength(gad,gad.text)+gad.font.ySize;
  IF width>gad.minwi THEN
    gad.minwi:=width;
  END;
  gad.minhe:=gad.titlehe+(gad.minfieldhe+gad.spacey)*gad.rows-gad.spacey;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:SelectBox) Resize*;

BEGIN
  gad.fieldwi:=(gad.width+gad.spacex) DIV gad.cols;
  DEC(gad.fieldwi,gad.spacex);
  gad.fieldhe:=(gad.height-gad.titlehe+gad.spacey) DIV gad.rows;
  DEC(gad.fieldhe,gad.spacey);
  gad.iwind:=gad.root.iwind;
END Resize;

PROCEDURE (gad:SelectBox) PlotField*(num:INTEGER;active:BOOLEAN);

VAR rast : g.RastPortPtr;
    x,y : INTEGER;

BEGIN
  rast:=gad.iwind.rPort;
  IF gad.orientation=horizOrient THEN
    x:=num MOD gad.cols;
    y:=num DIV gad.cols;
  ELSIF gad.orientation=vertOrient THEN
    y:=num MOD gad.rows;
    x:=num DIV gad.rows;
  END;
  x:=x*(gad.fieldwi+gad.spacex);
  y:=y*(gad.fieldhe+gad.spacey);
  INC(x,gad.xpos);
  INC(y,gad.ypos+gad.titlehe);

  IF active THEN
    gt.DrawBevelBox(rast,x,y,gad.fieldwi,gad.fieldhe,gt.bbFrameType,gt.bbftButton,
                                                     gt.visualInfo,gad.root.vinfo,
                                                     gt.bbRecessed,I.LTRUE,
                                                     u.done);
  ELSE
    gt.DrawBevelBox(rast,x,y,gad.fieldwi,gad.fieldhe,gt.bbFrameType,gt.bbftButton,
                                                     gt.visualInfo,gad.root.vinfo,
                                                     u.done);
  END;
  gad.plotproc(rast,x+4,y+2,gad.fieldwi-8,gad.fieldhe-4,gad.plotcolor,num);
END PlotField;

PROCEDURE (gad:SelectBox) Refresh*;

VAR rast : g.RastPortPtr;
    i    : INTEGER;
    bool : BOOLEAN;

BEGIN
  rast:=gad.iwind.rPort;
  g.SetAPen(rast,gmb.std.textcol);
  g.Move(rast,gad.xpos,gad.ypos+rast.font.baseline);
  g.Text(rast,gad.text^,st.Length(gad.text^));

  FOR i:=0 TO (gad.total-1) DO
    IF i=gad.active THEN
      bool:=TRUE;
    ELSE
      bool:=FALSE;
    END;
    gad.PlotField(i,bool);
  END;
END Refresh;

PROCEDURE (gad:SelectBox) SetValue*(active:LONGINT);

BEGIN
  gad.PlotField(gad.active,FALSE);
  gad.active:=SHORT(active);
  IF gad.active>=gad.total THEN
    gad.active:=gad.total-1;
  END;
  gad.PlotField(gad.active,TRUE);
END SetValue;

PROCEDURE (gad:SelectBox) GetValue*():LONGINT;

BEGIN
  RETURN gad.active;
END GetValue;

PROCEDURE SetSelectBox*(text:e.STRPTR;total,active,cols,rows:INTEGER;minwi,minhe,plotcolor:INTEGER;orientation:INTEGER;plotproc:PlotProc):SelectBox;

VAR node : SelectBox;

BEGIN
  IF plotcolor=-1 THEN
    plotcolor:=gmb.std.textcol;
  END;
  INC(minwi,8);
  INC(minhe,4);
  node:=NIL;
  NEW(node);
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: SelectBox DO
      node.text:=text;
      node.total:=total;
      node.gadget:=NIL;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.active:=active;
      node.cols:=cols;
      node.rows:=rows;
      node.minfieldwi:=minwi;
      node.minfieldhe:=minhe;
      node.fieldwi:=minwi;
      node.fieldhe:=minhe;
      node.spacex:=node.font.ySize DIV 4;
      node.spacey:=node.font.ySize DIV 8;
      node.titlehe:=0;
      node.orientation:=orientation;
      node.plotproc:=plotproc;
      node.plotcolor:=plotcolor;
      node.color:=plotcolor;
      node.sizex:=5;
      node.sizey:=5;
      node.minwi:=g.TextLength(gmb.fontrast,text^,st.Length(text^))+8;
      node.minhe:=node.font.ySize+6;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node;
END SetSelectBox;

PROCEDURE (gad:SelectBox) InputEvent*(mes:I.IntuiMessagePtr);

VAR message        : I.IntuiMessagePtr;
    x,y,oldact,act : INTEGER;

BEGIN
  IF (I.mouseButtons IN mes.class) AND (mes.code=I.selectDown) THEN
    IF (mes.mouseX>=gad.xpos) AND (mes.mouseX<gad.xpos+gad.width) AND (mes.mouseY>=gad.ypos+gad.titlehe) AND (mes.mouseY<gad.ypos+gad.height) THEN
      NEW(message);
      oldact:=gad.active;
      x:=(mes.mouseX-gad.xpos) DIV (gad.fieldwi+gad.spacex);
      y:=(mes.mouseY-gad.ypos-gad.titlehe) DIV (gad.fieldhe+gad.spacey);
      gad.PlotField(gad.active,FALSE);
      IF gad.orientation=horizOrient THEN
        gad.active:=x+y*gad.cols;
      ELSIF gad.orientation=vertOrient THEN
        gad.active:=x*gad.rows+y;
      END;
      IF gad.active>=gad.total THEN
        gad.active:=gad.total-1;
      END;
      io.WriteString("GMO1\n");
      gad.PlotField(gad.active,TRUE);
      io.WriteString("GMO2\n");

      REPEAT
      io.WriteString("GMO3\n");
        gad.subwind.GetIMes(message);
      io.WriteString("GMO4\n");
        IF (I.mouseMove IN message.class) OR (I.menuPick IN message.class) THEN
          IF message.mouseX<gad.xpos THEN message.mouseX:=gad.xpos; END;
          IF message.mouseX>=gad.xpos+gad.width THEN message.mouseX:=gad.xpos+gad.width-1; END;
          IF message.mouseY<gad.ypos+gad.titlehe THEN message.mouseY:=gad.ypos+gad.titlehe; END;
          IF message.mouseY>=gad.ypos+gad.height THEN message.mouseY:=gad.ypos+gad.height-1; END;
      io.WriteString("GMO5\n");
  
          x:=(message.mouseX-gad.xpos) DIV (gad.fieldwi+gad.spacex);
          y:=(message.mouseY-gad.ypos-gad.titlehe) DIV (gad.fieldhe+gad.spacey);
          act:=gad.active;
          IF gad.orientation=horizOrient THEN
            gad.active:=x+y*gad.cols;
          ELSIF gad.orientation=vertOrient THEN
            gad.active:=x*gad.rows+y;
          END;
          IF gad.active>=gad.total THEN
            gad.active:=gad.total-1;
          END;
          IF I.menuPick IN message.class THEN
            gad.active:=oldact;
          END;
      io.WriteString("GMO6\n");
          IF act#gad.active THEN
            gad.PlotField(act,FALSE);
            gad.PlotField(gad.active,TRUE);
          END;
      io.WriteString("GMO7\n");
        END;
      UNTIL ((I.mouseButtons IN message.class) AND (message.code=I.selectUp)) OR (I.menuPick IN message.class);
      IF I.mouseButtons IN message.class THEN
        mes.class:=LONGSET{I.gadgetUp};
        mes.code:=0;
        mes.iAddress:=gad;
      END;
      DISPOSE(message);
    END;
  END;
END InputEvent;



(* ImageGadget *)

TYPE ImageGadget * = POINTER TO ImageGadgetDesc;
     ImageGadgetDesc * = RECORD(gmb.GadgetDesc)
       imwi,imhe,
       depth      : INTEGER;
       image    - ,
       imagesel - : im.Image;
       toggle   - ,
       selected - : BOOLEAN;
     END;

PROCEDURE (gad:ImageGadget) Init*;

BEGIN
  gad.minwi:=gad.imwi;
  gad.minhe:=gad.imhe;
  gad.width:=gad.minwi;
  gad.height:=gad.minhe;
  IF gad.autoout THEN
    gad.topout:=SHORT(SHORT(gad.font.ySize/8+0.5));
    gad.leftout:=SHORT(SHORT(gad.font.ySize/2+0.5));
  END;
END Init;

PROCEDURE (gad:ImageGadget) Resize*;

BEGIN
  gad.iwind:=gad.root.iwind;
  gad.gadget:=rg.SetImageGadget(gad.xpos,gad.ypos+((gad.height-gad.imhe) DIV 2),gad.imwi,gad.imhe,gad.depth,gad.image,gad.imagesel,gmb.prev);
  IF gad.toggle THEN INCL(gad.gadget.activation,I.toggleSelect); END;
  IF gad.selected THEN INCL(gad.gadget.flags,I.selected); END;
END Resize;

PROCEDURE (gad:ImageGadget) SetSelected*(selected:BOOLEAN);

BEGIN
  gad.selected:=selected;
  IF gad.selected THEN INCL(gad.gadget.flags,I.selected);
                  ELSE EXCL(gad.gadget.flags,I.selected); END;
  gad.Refresh;
END SetSelected;

PROCEDURE (gad:ImageGadget) KeyboardAction*;

BEGIN
  IF I.toggleSelect IN gad.gadget.flags THEN
    gad.selected:=NOT(gad.selected);
    IF gad.selected THEN
      INCL(gad.gadget.flags,I.selected);
    ELSE
      EXCL(gad.gadget.flags,I.selected);
    END;
    I.RefreshGList(gad.gadget,gad.iwind,NIL,1);
  ELSE
    gmb.PressBoolean(gad.gadget,gad.iwind);
  END;
END KeyboardAction;

PROCEDURE SetImageGadget*(width,height,depth:INTEGER;image,imagesel:im.Image;toggle:BOOLEAN):ImageGadget;

VAR gad  : I.GadgetPtr;
    node : gmb.Gadget;

BEGIN
  gad:=rg.SetImageGadget(0,0,width,height,depth,image,imagesel,gmb.prev);
  node:=NIL;
  NEW(node(ImageGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: ImageGadget DO
      node.text:=NIL;
      node.imwi:=width;
      node.imhe:=height;
      node.depth:=depth;
      node.image:=image;
      node.imagesel:=imagesel;
      node.toggle:=toggle;
      node.selected:=FALSE;
      node.gadget:=gad;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=-1;
      node.sizey:=0; (* So it can be centered vertically! *)
      node.minwi:=width;
      node.minhe:=height;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
      node.iwind:=NIL;
    END;
  END;
  node.UpdateShortcut;
  RETURN node(ImageGadget);
END SetImageGadget;

PROCEDURE (gad:ImageGadget) InputEvent*(mes:I.IntuiMessagePtr);

VAR bool : BOOLEAN;

BEGIN
  IF I.gadgetUp IN mes.class THEN
    IF mes.iAddress=gad.gadget THEN
      gad.selected:=NOT(gad.selected);
    END;
  END;
  gad.InputEvent^(mes);
END InputEvent;

PROCEDURE (gad:ImageGadget) Destruct*;

BEGIN
  rg.DestructImageGadget(gad.gadget);
  DISPOSE(gad.gadget);
  gad.Destruct^;
END Destruct;



BEGIN
  gradpens[0]:=-1;
END GuiManagerObjects.


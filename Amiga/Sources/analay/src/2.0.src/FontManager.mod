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


MODULE FontManager;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       l  : LinkedLists,
       df : DiskFont,
       b  : Bullet,
       o  : OutlineFonts,
       st : Strings,
       wm : WindowManager,
       bt : BasicTools,
       tt : TextTools,
       NoGuruRq;



CONST fmBase = 1000;     (* Base for tags *)
      minSize * = 1.0;   (* Minimum font size *)
      maxSize * = 200.0; (* ;aximun font size *)

TYPE FontStyle * = POINTER TO FontStyleDesc;
     FontStyleDesc * = RECORD
       shearAngle  * ,
       rotateAngle * ,
       emboldenX   * ,
       emboldenY   * : LONGREAL;
       underlined  * : LONGINT;
     END;

PROCEDURE (style:FontStyle) Init*;

BEGIN
  style.shearAngle:=0;
  style.rotateAngle:=0;
  style.emboldenX:=0;
  style.emboldenY:=0;
  style.underlined:=df.ulNone;
END Init;

PROCEDURE (style:FontStyle) Destruct*;

BEGIN
  DISPOSE(style);
END Destruct;



(* Style tags *)

CONST shearAngle  * = o.shearAngle;
      rotateAngle * = o.rotateAngle;
      emboldenX   * = o.emboldenX;
      emboldenY   * = o.emboldenY;
      underLined  * = o.underLined;
      kerning     * = 100;
      fontStyle   * = fmBase+2;

(* Attribute tags *)

      txHeight    * = fmBase+3;
      txBaseline  * = o.txBaseline;
      textKerning * = o.textKerning;
      designKerning*= o.designKerning;
      noKerning   * = -1;              (* Kerning data tag *)

(* Font class *)

TYPE Font * = POINTER TO FontDesc;
     FontDesc * = RECORD(l.NodeDesc);
       path,name : ARRAY 256 OF CHAR;
       size      : LONGREAL;  (* Size in pt. With bitmapfonts usually equal to size in pixels (dpi=72). *)
(*                         (* Size requested in pt *)
       realsize  : LONGINT;   (* Real size in pt considering dpi values, because internal only 72dpi are used due to the bad DPI-capabilities of Diskfont *)*)
       dpi       : df.FIXED;
       xdpi,ydpi : LONGINT;
       kerning   : LONGINT;   (* Either df.textKernPair or df.designKernPair *)
       style     : FontStyle;
     END;

     BitmapFont * = POINTER TO BitmapFontDesc;
     BitmapFontDesc * = RECORD(FontDesc);
       attr : g.TTextAttrPtr;
       font : g.TextFontPtr;
       tags : u.Tags2;        (* Tags for attr.tags field *)
     END;

     OutlineFont * = POINTER TO OutlineFontDesc;
     OutlineFontDesc * = RECORD(FontDesc);
       font : o.Font;
     END;

PROCEDURE (font:Font) Init*;

BEGIN
  NEW(font.style);
  IF font.style#NIL THEN font.style.Init; END;
  font.Init^;
END Init;

PROCEDURE (font:Font) Destruct*;

BEGIN
  IF font.style#NIL THEN font.style.Destruct; END;
  font.Destruct^;
END Destruct;

PROCEDURE OpenFont*(path,name:ARRAY OF CHAR;size:LONGREAL):Font;

VAR font      : Font;
    attr      : g.TextAttrPtr;
    isoutline,
    bool      : BOOLEAN;

BEGIN
  font:=NIL;
  IF path[0]#0X THEN
    isoutline:=o.FontIsOutline(path,name);
  ELSE
    isoutline:=FALSE;
  END;
  IF isoutline THEN
    NEW(font(OutlineFont));
    IF font#NIL THEN
      font.Init;
      COPY(path,font.path);
      COPY(name,font.name);
      font.size:=size;
      WITH font: OutlineFont DO
        font.dpi:=bt.highBits*72+bt.lowBits*72;
        font.xdpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,font.dpi),-16));
        font.ydpi:=s.VAL(LONGINT,s.VAL(LONGSET,font.dpi)*LONGSET{0..15});
        font.kerning:=textKerning;

        font.font:=o.NewFont(path,name);
        IF font.font=NIL THEN
          st.Append(font.name,".font"); st.Append(name,".font");
          font.font:=o.NewFont(path,name);
        END;
        IF font.font#NIL THEN
          bool:=font.font.Set(df.deviceDPI,font.dpi);
          bool:=font.font.Set64(df.pointHeight,size);
        ELSE
          font.Destruct;
          isoutline:=FALSE;        (* Retry using Diskfont *)
        END;
      END;
    END;
  END;
  IF NOT(isoutline) THEN      (* Could be a retry when OutlineFonts.NewFont() *)
    NEW(font(BitmapFont));    (* fails. *)
    IF font#NIL THEN
      font.Init;
      COPY(path,font.path);
      COPY(name,font.name);
      font.size:=size;
      font.dpi:=bt.highBits*72+bt.lowBits*72;
      font.xdpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,font.dpi),-16));
      font.ydpi:=s.VAL(LONGINT,s.VAL(LONGSET,font.dpi)*LONGSET{0..15});
      font.kerning:=textKerning;
      WITH font: BitmapFont DO
        NEW(font.attr);
        IF font.attr=NIL THEN
          font.Destruct; RETURN NIL;
        END;
        font.attr.name:=s.ADR(font.name);
        font.attr.ySize:=SHORT(SHORT(SHORT(size)));
        font.tags[0].tag:=g.deviceDPI; font.tags[0].data:=font.dpi;
        font.tags[1].tag:=u.done;      font.tags[0].data:=u.done;
        font.attr.tags:=s.ADR(font.tags);
        attr:=s.VAL(g.TextAttrPtr,font.attr);
        font.font:=df.OpenDiskFont(attr^);
        IF font.font=NIL THEN
          st.Append(font.name,".font");
          font.font:=df.OpenDiskFont(attr^);
          IF font.font=NIL THEN
            DISPOSE(font.attr); font.Destruct; RETURN NIL;
          END;
        END;
      END;
    END;
  END;
  RETURN font;
END OpenFont;

PROCEDURE (font:OutlineFont) Destruct*;

BEGIN
  IF font.font#NIL THEN
    font.font.Destruct;
  END;
  font.Destruct^;
END Destruct;

PROCEDURE (font:BitmapFont) Destruct*;

BEGIN
  IF font.font#NIL THEN
    g.CloseFont(font.font);
  END;
  font.Destruct^;
END Destruct;



PROCEDURE (font:Font) Set*(tag,data:e.APTR):BOOLEAN;
END Set;

PROCEDURE (font:Font) Set64*(tag:e.APTR;data:LONGREAL):BOOLEAN;
END Set64;

PROCEDURE (font:OutlineFont) Set*(tag,data:e.APTR):BOOLEAN;

BEGIN
  CASE s.VAL(LONGINT,tag) OF
  | kerning      : font.kerning:=data;
                   RETURN TRUE;
  | df.deviceDPI : font.dpi:=data;
                   font.xdpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));
                   font.ydpi:=s.VAL(LONGINT,s.VAL(LONGSET,data)*LONGSET{0..15});
                   (*    font.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),16));
                       font.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));*)
                   (*    data:=font.xdpi*o.highBits+72/font.ydpi*font.xdpi*o.lowBits;*)
                   RETURN font.font.Set(tag,data);
  | underLined   : font.style.underlined:=s.VAL(LONGINT,data);
                   RETURN font.font.Set(tag,data);
  ELSE
    RETURN font.font.Set(tag,data);
  END;
END Set;

PROCEDURE (font:OutlineFont) Set64*(tag:e.APTR;data:LONGREAL):BOOLEAN;

BEGIN
  CASE s.VAL(LONGINT,tag) OF
  | df.pointHeight : font.size:=data;
  | shearAngle     : font.style.shearAngle:=data;
  | rotateAngle    : font.style.rotateAngle:=data;
  | emboldenX      : font.style.emboldenX:=data;
  | emboldenY      : font.style.emboldenY:=data;
  END;
  RETURN font.font.Set64(tag,data);
END Set64;

PROCEDURE (font:BitmapFont) Set*(tag:e.APTR;data:e.APTR):BOOLEAN;

BEGIN
  CASE s.VAL(LONGINT,tag) OF
  | df.deviceDPI : font.dpi:=data;
                   font.xdpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));
                   font.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),16));
                   font.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));
                   font.tags[0].data:=SHORT(72/font.ydpi*font.xdpi*o.highBits+72*o.lowBits);
                   RETURN TRUE;
  | underLined   : font.style.underlined:=s.VAL(LONGINT,data);
  ELSE
    RETURN FALSE;
  END;
  RETURN TRUE;
END Set;

PROCEDURE (font:BitmapFont) Set64*(tag:e.APTR;data:LONGREAL):BOOLEAN;

VAR attr : g.TextAttrPtr;

BEGIN
  CASE s.VAL(LONGINT,tag) OF
  | df.pointHeight : IF font.font#NIL THEN
                       g.CloseFont(font.font);
                     END;
                     font.size:=data;
                     font.attr.ySize:=SHORT(SHORT(SHORT(font.size*font.ydpi/72)));
                     attr:=s.VAL(g.TextAttrPtr,font.attr);
                     font.font:=df.OpenDiskFont(attr^);
                     IF font.font#NIL THEN
                       RETURN TRUE;
                     END;
  | shearAngle     : font.style.shearAngle:=data;
  | rotateAngle    : font.style.rotateAngle:=data;
  | emboldenX      : font.style.emboldenX:=data;
  | emboldenY      : font.style.emboldenY:=data;
  ELSE
    RETURN FALSE;
  END;
  RETURN TRUE;
END Set64;

PROCEDURE (font:Font) Get*(tag:e.APTR;VAR data:e.APTR):BOOLEAN;

BEGIN
  CASE s.VAL(LONGINT,tag) OF
  | fontStyle : data:=font.style;
  ELSE
    RETURN FALSE;
  END;
  RETURN TRUE;
END Get;

PROCEDURE (font:Font) Get64*(tag:e.APTR;VAR data:LONGREAL):BOOLEAN;
END Get64;

PROCEDURE (font:OutlineFont) Get64*(tag:e.APTR;VAR data:LONGREAL):BOOLEAN;

VAR aptr : e.APTR;
    bool : BOOLEAN;

BEGIN
  bool:=TRUE;
  data:=0;
  CASE s.VAL(LONGINT,tag) OF
  | df.pointHeight : data:=font.size;
  | txHeight       : data:=font.size/72*font.ydpi;
  | txBaseline     : bool:=font.font.Get(o.txBaseline,aptr);
                     data:=s.VAL(LONGINT,aptr);
(*                     bool:=font.font.Get64(o.txBaseline,data);*)
  ELSE bool:=FALSE;
  END;
  RETURN bool;
END Get64;

PROCEDURE (font:BitmapFont) Get64*(tag:e.APTR;VAR data:LONGREAL):BOOLEAN;

VAR bool : BOOLEAN;

BEGIN
  bool:=TRUE;
  data:=0;
  CASE s.VAL(LONGINT,tag) OF
  | df.pointHeight : data:=font.size;
  | txHeight       : data:=font.size/72*font.ydpi;
  | txBaseline     : data:=font.font.baseline;
  ELSE bool:=FALSE;
  END;
  RETURN bool;
END Get64;



(* For ease Graphics compatible use. *)

PROCEDURE (font:Font) SetStyle*(style:SHORTSET);

VAR bool : BOOLEAN;

BEGIN
  IF g.italic IN style THEN
    bool:=font.Set64(shearAngle,5);
  ELSE
    bool:=font.Set64(shearAngle,0);
  END;
  IF g.bold IN style THEN
    bool:=font.Set64(emboldenX,0.1);
  ELSE
    bool:=font.Set64(emboldenX,0);
  END;
  IF g.underlined IN style THEN
    bool:=font.Set64(underLined,df.ulSolid);
  ELSE
    bool:=font.Set64(underLined,df.ulNone);
  END;
END SetStyle;

PROCEDURE (font:Font) GetStyle*():SHORTSET;

VAR style : SHORTSET;

BEGIN
  style:=SHORTSET{};
  IF font.style.shearAngle#0 THEN
    INCL(style,g.italic);
  END;
  IF (font.style.emboldenX#0) OR (font.style.emboldenY#0) THEN
    INCL(style,g.bold);
  END;
  IF font.style.underlined#df.ulNone THEN
    INCL(style,g.underlined);
  END;
  RETURN style;
END GetStyle;

PROCEDURE (font:BitmapFont) SetRPStyle*(rast:g.RastPortPtr);

VAR mask,style : SHORTSET;

BEGIN
  style:=font.GetStyle();
  mask:=g.AskSoftStyle(rast);
  style:=g.SetSoftStyle(rast,style,mask);
END SetRPStyle;



(* Printing tools *)

PROCEDURE (font:Font) CharWidthPix*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;
END CharWidthPix;

PROCEDURE (font:BitmapFont) CharWidthPix*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;

VAR string : ARRAY 2 OF CHAR;

BEGIN
  IF font.font#rast.font THEN
    g.SetFont(rast,font.font);
  END;
  font.SetRPStyle(rast);
  string[0]:=char1;
  string[1]:=char2;
  RETURN g.TextLength(rast,string,1);
END CharWidthPix;

PROCEDURE (font:OutlineFont) CharWidthPix*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;

VAR real,real2 : LONGREAL;
    bool : BOOLEAN;

BEGIN
  IF font.font#NIL THEN
    bool:=font.Set(df.glyphCode,ORD(char1));
    bool:=font.Set(df.glyphCode2,ORD(char2));
  bool:=font.font.Get64(o.charWidth,real2);
    IF font.kerning#noKerning THEN
      bool:=font.font.Get64(font.kerning,real);
      real:=real2-real;
    ELSE (* no kerning *)
      bool:=font.font.Get64(o.charWidth,real);
    END; (* real [mm] *)
    real:=real/25.4; (* [in] *)
    real:=real*font.xdpi; (* [Pixels] *)
    RETURN real;
  ELSE
    RETURN 0;
  END;
END CharWidthPix;

PROCEDURE (font:Font) CharWidthMM*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;
END CharWidthMM;

PROCEDURE (font:BitmapFont) CharWidthMM*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;

VAR string : ARRAY 2 OF CHAR;

BEGIN
  IF font.font#rast.font THEN
    g.SetFont(rast,font.font);
  END;
  font.SetRPStyle(rast);
  string[0]:=char1;
  string[1]:=char2;
  RETURN g.TextLength(rast,string,1)/font.xdpi*25.4;
END CharWidthMM;

PROCEDURE (font:OutlineFont) CharWidthMM*(rast:g.RastPortPtr;char1,char2:CHAR):LONGREAL;

VAR real : LONGREAL;
    bool : BOOLEAN;

BEGIN
  IF font.font#NIL THEN
    bool:=font.Set(df.glyphCode,ORD(char1));
    bool:=font.Set(df.glyphCode2,ORD(char2));
    IF font.kerning#noKerning THEN
      bool:=font.font.Get64(font.kerning,real);
    ELSE (* no kerning *)
      bool:=font.font.Get64(o.charWidth,real);
    END; (* real [mm] *)
    RETURN real;
  ELSE
    RETURN 0;
  END;
END CharWidthMM;



PROCEDURE (font:Font) TextWidthPix*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;
END TextWidthPix;

PROCEDURE (font:OutlineFont) TextWidthPix*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;

VAR len : LONGREAL;
    i   : INTEGER;

BEGIN
  i:=0;
  len:=0;
  WHILE string[i]#0X DO
    len:=len+font.CharWidthPix(rast,string[i],string[i+1]);
    INC(i);
  END;
  RETURN len;
END TextWidthPix;

PROCEDURE (font:BitmapFont) TextWidthPix*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;

BEGIN
  IF font.font#rast.font THEN
    g.SetFont(rast,font.font);
  END;
  font.SetRPStyle(rast);
  RETURN g.TextLength(rast,string^,st.Length(string^));
END TextWidthPix;

PROCEDURE (font:Font) TextWidthMM*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;
END TextWidthMM;

PROCEDURE (font:OutlineFont) TextWidthMM*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;

VAR len : LONGREAL;
    i   : INTEGER;

BEGIN
  i:=0;
  WHILE string[i]#0X DO
    len:=len+font.CharWidthMM(rast,string[i],string[i+1]);
    INC(i);
  END;
  RETURN len;
END TextWidthMM;

PROCEDURE (font:BitmapFont) TextWidthMM*(rast:g.RastPortPtr;string:e.STRPTR):LONGREAL;

BEGIN
  IF font.font#rast.font THEN
    g.SetFont(rast,font.font);
  END;
  font.SetRPStyle(rast);
  RETURN g.TextLength(rast,string^,st.Length(string^))/font.xdpi*25.4;
END TextWidthMM;



(* Printing methods *)

PROCEDURE (font:Font) PrintChar*(rast:g.RastPortPtr;x,y:INTEGER;char:CHAR);
END PrintChar;

PROCEDURE (font:BitmapFont) PrintChar*(rast:g.RastPortPtr;x,y:INTEGER;char:CHAR);

VAR string : ARRAY 2 OF CHAR;

BEGIN
  IF font.font#NIL THEN
    IF font.font#rast.font THEN
      g.SetFont(rast,font.font);
    END;
    font.SetRPStyle(rast);
    string[0]:=char;
    string[1]:=0X;
    g.Move(rast,x,y);
    g.Text(rast,string,1);
(*    RETURN SHORT(g.TextLength(rast,string,1));
  ELSE
    RETURN -1;*)
  END;
END PrintChar;

PROCEDURE (font:OutlineFont) PrintChar*(rast:g.RastPortPtr;x,y:INTEGER;char:CHAR);

VAR real : LONGREAL;
    bool : BOOLEAN;

BEGIN
  bool:=font.font.Set(df.glyphCode,ORD(char));
  IF bool THEN
    real:=font.font.BlitCharPix(rast,x,y);
(*  ELSE
    RETURN -1;*)
  END;
END PrintChar;



PROCEDURE (font:Font) Print*(rast:g.RastPortPtr;x,y:INTEGER;string:e.STRPTR);
END Print;

PROCEDURE (font:BitmapFont) Print*(rast:g.RastPortPtr;x,y:INTEGER;string:e.STRPTR);

BEGIN
  IF font.font#NIL THEN
    IF font.font#rast.font THEN
      g.SetFont(rast,font.font);
    END;
    font.SetRPStyle(rast);
    g.Move(rast,x,y);
    g.Text(rast,string^,st.Length(string^));
  END;
END Print;

PROCEDURE (font:OutlineFont) Print*(rast:g.RastPortPtr;x,y:INTEGER;string:e.STRPTR);

VAR rx,addx : LONGREAL;
    i       : INTEGER;
    bool    : BOOLEAN;

BEGIN
  IF font.font#NIL THEN
    rx:=x;
    FOR i:=0 TO SHORT(st.Length(string^)-1) DO
      bool:=font.font.Set(df.glyphCode,ORD(string[i]));
      bool:=font.font.Set(df.glyphCode2,ORD(string[i+1]));
      addx:=font.font.BlitCharPix(rast,SHORT(SHORT(SHORT(rx))),y);
      IF font.kerning#noKerning THEN
        addx:=font.CharWidthPix(rast,string[i],string[i+1]);
      END;
      rx:=rx+addx;
    END;
  END;
END Print;



PROCEDURE (font:Font) PrintMid*(rast:g.RastPortPtr;x,y:INTEGER;string:e.STRPTR);

VAR real  : LONGREAL;
    width : INTEGER;

BEGIN
  real:=font.TextWidthPix(rast,string); width:=SHORT(SHORT(SHORT(real)));
  x:=x-(width DIV 2);
  font.Print(rast,x,y,string);
END PrintMid;

PROCEDURE (font:Font) PrintRight*(rast:g.RastPortPtr;x,y:INTEGER;string:e.STRPTR);

VAR real  : LONGREAL;
    width : INTEGER;

BEGIN
  real:=font.TextWidthPix(rast,string); width:=SHORT(SHORT(SHORT(real)));
  x:=x-width+1;
  font.Print(rast,x,y,string);
END PrintRight;

END FontManager.


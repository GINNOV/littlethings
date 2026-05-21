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


MODULE ImageCreator;

IMPORT I   : Intuition,
       g   : Graphics,
       d   : Dos,
       e   : Exec,
       s   : SYSTEM,
       c   : Conversions,
       st  : Strings,
       tt  : TextTools,
       iff : IFFSupport,
       io,
       NoGuruRq;

VAR screen      : I.ScreenPtr;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    iffname,
    imagename,
    string      : ARRAY 80 OF CHAR;
    width,
    height,
    depth,
    long        : LONGINT;
    i,datacount : INTEGER;
    bool,inline : BOOLEAN;
    file        : d.FileHandlePtr;

PROCEDURE WriteWord(x,y,plane:INTEGER);

VAR long : LONGSET;
    col  : LONGINT;
    i    : INTEGER;
    hex,
    count: ARRAY 10 OF CHAR;
    write: ARRAY 80 OF CHAR;

BEGIN
  long:=LONGSET{};
  FOR i:=0 TO 15 DO
    col:=g.ReadPixel(rast,x+i,y);
    IF plane IN s.VAL(LONGSET,col) THEN
      INCL(long,15-i);
    END;
  END;
  bool:=c.IntToHex(s.VAL(LONGINT,long),hex,4);
  hex[4]:="U";
(*  st.AppendChar(hex,"U");*)
  IF NOT(inline) THEN
    write:="  data[";
    bool:=c.IntToString(datacount,count,4);
    tt.Clear(count);
    st.Append(write,count);
    st.Append(write,"]:=00");
    st.Append(write,hex);
    st.AppendChar(write,";");
    col:=d.Write(file,write,st.Length(write));
    col:=d.Write(file,"\n",1);
    INC(datacount);
  ELSE
    st.Insert(hex,0,"00");
    col:=d.Write(file,hex,st.Length(hex));
  END;
END WriteWord;

PROCEDURE WriteBitPlane(plane:INTEGER);

VAR x,y : INTEGER;

BEGIN
  FOR y:=0 TO SHORT(height)-1 DO
(*    IF inline THEN
      long:=d.Write(file,"  s.INLINE(",st.Length("  s.INLINE("));
    END;*)
    FOR x:=0 TO SHORT(width)-1 BY 16 DO
      WriteWord(x,y,plane);
      IF (inline) AND ((x<((width-1) DIV 16)*16)) OR (y<height-1) THEN
        long:=d.Write(file,",",1);
      END;
    END;
    long:=d.Write(file,"\n",1);
(*    IF inline THEN
      long:=d.Write(file,");\n",st.Length(");")+1);
    END;*)
    IF (y+1) MOD 10=0 THEN
      io.WriteString("Zeile ");
      io.WriteInt(y+1,5);
      io.WriteString(" von ");
      io.WriteInt(height,5);
      io.WriteString(", BitPlane ");
      io.WriteInt(plane+1,3);
      io.WriteString(" von ");
      io.WriteInt(depth,3);
      io.WriteLn;
    END;
  END;
  long:=d.Write(file,"\n",1);
END WriteBitPlane;

BEGIN
  io.WriteString("IFF-Datei: ");
  io.ReadString(iffname);
  io.WriteString("Image-Datei: ");
  io.ReadString(imagename);
  io.WriteString("Breite: ");
  bool:=io.ReadInt(width);
  io.WriteString("Höhe: ");
  bool:=io.ReadInt(height);
  io.WriteString("Tiefe: ");
  bool:=io.ReadInt(depth);
  io.WriteString("Const/Array-Code (c/a): ");
  io.ReadString(string);
  IF CAP(string[0])="C" THEN
    inline:=TRUE;
  ELSE
    inline:=FALSE;
  END;

  bool:=iff.ReadILBM(iffname,SET{iff.window,iff.front},screen,wind);
  IF bool THEN
    rast:=wind.rPort;
    file:=d.Open(imagename,d.newFile);
    datacount:=0;
    FOR i:=0 TO SHORT(depth)-1 DO
      WriteBitPlane(i);
    END;
    bool:=d.Close(file);
    I.CloseWindow(wind);
    bool:=I.CloseScreen(screen);
  END;
END ImageCreator.


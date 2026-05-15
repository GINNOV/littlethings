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


MODULE LayoutConversion;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       fm : FontManager,
       NoGuruRq;

TYPE ConversionTable * = POINTER TO ConversionTableDesc;
     ConversionTableDesc * = RECORD
       linethicknessx * ,
       linethicknessy * : POINTER TO ARRAY OF INTEGER;
       colors         * : POINTER TO ARRAY OF INTEGER;
       stdpicx        * ,
       stdpicy        * : INTEGER;
       fontlist       * : l.List;
     END;

TYPE FontNode * = POINTER TO FontNodeDesc;
     FontNodeDesc * = RECORD(l.NodeDesc)
       origname * ,
       convname * : ARRAY 128 OF CHAR;
       origpath * ,
       convpath * : ARRAY 128 OF CHAR;
     END;

PROCEDURE (convtable:ConversionTable) Init*;

VAR i : INTEGER;

BEGIN
  NEW(convtable.linethicknessx,10);
  FOR i:=0 TO 9 DO convtable.linethicknessx[i]:=i+1; END;
  NEW(convtable.linethicknessy,10);
  FOR i:=0 TO 9 DO convtable.linethicknessy[i]:=i+1; END;
  convtable.colors:=NIL;
  convtable.stdpicx:=10;
  convtable.stdpicy:=10;
  convtable.fontlist:=NIL;
END Init;

PROCEDURE (convtable:ConversionTable) Destruct*;

BEGIN
  IF convtable.linethicknessx#NIL THEN DISPOSE(convtable.linethicknessx) END;
  IF convtable.linethicknessy#NIL THEN DISPOSE(convtable.linethicknessy) END;
  IF convtable.colors#NIL THEN DISPOSE(convtable.colors); END;
  IF convtable.fontlist#NIL THEN convtable.fontlist.Destruct; END;
END Destruct;

PROCEDURE (convtable:ConversionTable) Copy*(dest:ConversionTable);

VAR i : LONGINT;

BEGIN
  IF convtable.linethicknessx#NIL THEN
    FOR i:=0 TO LEN(convtable.linethicknessx^)-1 DO
      dest.linethicknessx[i]:=convtable.linethicknessx[i];
    END;
  ELSE
    dest.linethicknessx:=NIL;
  END;
  IF convtable.linethicknessy#NIL THEN
    FOR i:=0 TO LEN(convtable.linethicknessy^)-1 DO
      dest.linethicknessy[i]:=convtable.linethicknessy[i];
    END;
  ELSE
    dest.linethicknessy:=NIL;
  END;
  IF convtable.colors#NIL THEN
    FOR i:=0 TO LEN(convtable.colors^)-1 DO
      dest.colors[i]:=convtable.colors[i];
    END;
  ELSE
    dest.colors:=NIL;
  END;
  dest.stdpicx:=convtable.stdpicx;
  dest.stdpicy:=convtable.stdpicy;
END Copy;

PROCEDURE (convtable:ConversionTable) GetThicknessX*(thick:INTEGER):INTEGER;

BEGIN
  IF convtable.linethicknessx#NIL THEN
    IF LEN(convtable.linethicknessx^)>thick THEN
      RETURN convtable.linethicknessx[thick];
    ELSE
      RETURN convtable.linethicknessx[0];
    END;
  ELSE
    RETURN thick;
  END;
END GetThicknessX;

PROCEDURE (convtable:ConversionTable) GetThicknessY*(thick:INTEGER):INTEGER;

BEGIN
  IF convtable.linethicknessy#NIL THEN
    IF LEN(convtable.linethicknessy^)>thick THEN
      RETURN convtable.linethicknessy[thick];
    ELSE
      RETURN convtable.linethicknessy[0];
    END;
  ELSE
    RETURN thick;
  END;
END GetThicknessY;

PROCEDURE (convtable:ConversionTable) GetColor*(color:INTEGER):INTEGER;

BEGIN
  IF convtable.colors#NIL THEN
    IF LEN(convtable.colors^)>color THEN
      RETURN convtable.colors[color];
    ELSE
      RETURN convtable.colors[0];
    END;
  ELSE
    RETURN color;
  END;
END GetColor;

PROCEDURE (convtable:ConversionTable) GetStdPicX*():INTEGER;

BEGIN
  RETURN convtable.stdpicx;
END GetStdPicX;

PROCEDURE (convtable:ConversionTable) GetStdPicY*():INTEGER;

BEGIN
  RETURN convtable.stdpicy;
END GetStdPicY;

PROCEDURE (convtable:ConversionTable) GetFont*(font:fm.Font):fm.Font;

BEGIN
  IF convtable.fontlist=NIL THEN
    RETURN font;
  ELSE
    RETURN font;
  END;
END GetFont;

END LayoutConversion.


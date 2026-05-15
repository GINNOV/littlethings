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


MODULE DisplayConversion;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       fm : FontManager,
       m  : Multitasking,
       bas: BasicTypes,
       NoGuruRq;

TYPE ConversionTable * = POINTER TO ConversionTableDesc;
     ConversionTableDesc * = RECORD(bas.ANYDesc)
       task           * : m.Task;          (* The task this table is used by. Needed for some NewUser() calls. *)
       gridconv       * ,                  (* Used to plot grid or *)
       labelsconv     * : ConversionTable; (* axislabels when #NIL. *)
       stdpicx        * ,
       stdpicy        * : INTEGER;
     END;

TYPE FontNode * = POINTER TO FontNodeDesc;
     FontNodeDesc * = RECORD(l.NodeDesc)
       origname * ,
       convname * : ARRAY 128 OF CHAR;
       origpath * ,
       convpath * : ARRAY 128 OF CHAR;
     END;

CONST standardType * = 0;
      textType     * = 1;
      graphType    * = 2;

PROCEDURE (convtable:ConversionTable) Init*(task:m.Task);

VAR i : INTEGER;

BEGIN
  convtable.task:=task;
  convtable.stdpicx:=10;
  convtable.stdpicy:=10;
END Init;

PROCEDURE (convtable:ConversionTable) Destruct*(task:m.Task);

BEGIN
  DISPOSE(convtable);
END Destruct;

PROCEDURE (convtable:ConversionTable) Copy*(dest:ConversionTable);

VAR i : LONGINT;

BEGIN
  dest.stdpicx:=convtable.stdpicx;
  dest.stdpicy:=convtable.stdpicy;
END Copy;

PROCEDURE (convtable:ConversionTable) GetThicknessX*(thick:INTEGER):INTEGER;

BEGIN
  RETURN thick;
END GetThicknessX;

PROCEDURE (convtable:ConversionTable) GetThicknessY*(thick:INTEGER):INTEGER;

BEGIN
  RETURN thick;
END GetThicknessY;

PROCEDURE (convtable:ConversionTable) GetColor*(color:INTEGER;type:INTEGER):INTEGER;

BEGIN
  RETURN color;
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
(* Note: The returned fm.Font may get destructed by the calling task! *)

BEGIN
  RETURN font;
END GetFont;

END DisplayConversion.


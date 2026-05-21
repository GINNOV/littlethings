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


MODULE BasicTools;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       l  : LinkedLists,
       NoGuruRq;



CONST highBits * = s.VAL(LONGINT,LONGSET{16});
      lowBits  * = 1;



VAR os * : INTEGER;



(* Graphic tools *)

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

BEGIN
  os:=I.int.libNode.version;
END BasicTools.


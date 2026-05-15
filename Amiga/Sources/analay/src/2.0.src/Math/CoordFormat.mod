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


MODULE CoordFormat;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       tt : TextTools,
       NoGuruRq;

TYPE CoordFormat * = POINTER TO CoordFormatDesc;
     CoordFormatDesc * = RECORD(l.NodeDesc)
       formatstr * : ARRAY 256 OF CHAR;
     END;

VAR coordformats * : l.List;

PROCEDURE (coordformat:CoordFormat) Init*;

BEGIN
  coordformat.formatstr:="";
END Init;

PROCEDURE * PrintCoordFormat*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=coordformats.GetNode(num);
  IF node#NIL THEN
    WITH node: CoordFormat DO
      NEW(str);
      COPY(node.formatstr,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintCoordFormat;

VAR coordf : CoordFormat;

BEGIN
  coordformats:=l.Create();
  IF coordformats=NIL THEN HALT(20); END;

  NEW(coordf);
  coordf.formatstr:="$x,$y";
  coordformats.AddTail(coordf);
  NEW(coordf);
  coordf.formatstr:="($x|$y)";
  coordformats.AddTail(coordf);
  NEW(coordf);
  coordf.formatstr:="($x,$y)";
  coordformats.AddTail(coordf);
  NEW(coordf);
  coordf.formatstr:="x=$x y=$y";
  coordformats.AddTail(coordf);

CLOSE
  IF coordformats#NIL THEN coordformats.Destruct; END;
END CoordFormat.


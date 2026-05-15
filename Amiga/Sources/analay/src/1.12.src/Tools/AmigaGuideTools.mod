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


MODULE AmigaGuideTools;

IMPORT I  : Intuition,
       s  : SYSTEM,
       st : Strings,
       ag : AmigaGuide,
       pt : Pointers;

PROCEDURE ShowFile*(name,node:ARRAY OF CHAR;wind:I.WindowPtr);

VAR nag    : ag.NewAmigaGuide;
    handle : ag.AGContext;
    name2  : ARRAY 80 OF CHAR;

BEGIN
  IF ag.base#NIL THEN
    pt.SetBusyPointer(wind);
    COPY(name,name2);
    nag.name:=s.ADR(name2);
    nag.screen:=wind.wScreen;
    nag.node:=s.ADR(node);
    handle:=ag.OpenAmigaGuide(nag,NIL);
    IF handle=NIL THEN
      st.Insert(name2,0,"Analay:");
      handle:=ag.OpenAmigaGuide(nag,NIL);
      IF handle=NIL THEN
        COPY(name,name2);
        st.Insert(name2,0,"Analay:");
        st.InsertChar(name2,9,"2");
        handle:=ag.OpenAmigaGuide(nag,NIL);
      END;
    END;
    IF handle#NIL THEN
      ag.CloseAmigaGuide(handle);
    END;
    pt.ClearPointer(wind);
  END;
END ShowFile;

END AmigaGuideTools.


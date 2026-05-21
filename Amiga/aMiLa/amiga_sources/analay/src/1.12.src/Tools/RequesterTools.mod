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


MODULE RequesterTools;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       r  : Requests,
       st : Strings;

PROCEDURE Request*(text:ARRAY OF ARRAY OF CHAR;pos,neg:ARRAY OF CHAR;wind:I.WindowPtr):BOOLEAN;
(* $CopyArrays- *)

VAR texts : POINTER TO ARRAY OF I.IntuiText;
    ok,ca : I.IntuiText;
    okadr : I.IntuiTextPtr;
    w1,w2,
    add,i : INTEGER;
    screen: I.ScreenPtr;

BEGIN
(*  IF I.int.libNode.version<36 THEN
    w1:=SHORT(st.Length(pos));
    w2:=SHORT(st.Length(neg));
    IF w2>w1 THEN
      w1:=w2;
    END;
    w1:=w1*8+80;
    IF w1<320 THEN
      w1:=320;
    END;
    IF wind.wScreen#NIL THEN
      add:=wind.wScreen.font.ySize+2;
    ELSE
      add:=10;
    END;
  ELSE*)
    IF wind#NIL THEN
      screen:=wind.wScreen;
    ELSE
      screen:=I.LockPubScreen(NIL);
    END;
    IF screen#NIL THEN
      add:=screen.font.ySize+2;
      IF wind=NIL THEN
        I.UnlockPubScreen(NIL,screen);
      END;
    END;
(*  END;*)
  NEW(texts,LEN(text));
  FOR i:=0 TO SHORT(LEN(text)-1) DO
    texts[i].frontPen:=0;
    texts[i].backPen:=1;
    texts[i].drawMode:=g.jam2;
    texts[i].leftEdge:=12;
    texts[i].topEdge:=8+i*add;
    texts[i].iTextFont:=NIL;
    texts[i].iText:=s.ADR(text[i]);
    IF i<LEN(text)-1 THEN
      texts[i].nextText:=s.ADR(texts[i+1]);
    END;
  END;
  ok.leftEdge:=6;
  ok.topEdge:=3;
  ok.iText:=s.ADR(pos);
  ca.leftEdge:=6;
  ca.topEdge:=3;
  ca.iText:=s.ADR(neg);
  okadr:=s.ADR(ok);
  IF pos[0]=0X THEN
    okadr:=NIL;
  END;
  RETURN I.AutoRequest(wind,s.ADR(texts[0]),okadr,s.ADR(ca),LONGSET{},LONGSET{},w1,41+LEN(text)*14);
END Request;

PROCEDURE RequestWin*(text1,text2,pos,neg:e.STRPTR;wind:I.WindowPtr):BOOLEAN;

BEGIN
  RETURN r.RequestWin(text1^,text2^,pos^,neg^,wind);
END RequestWin;

END RequesterTools.


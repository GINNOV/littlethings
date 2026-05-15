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


MODULE MuiTools;

IMPORT I  : Intuition,
       e  : Exec,
       u  : Utility,
       s  : SYSTEM,
       l  : LinkedLists,
       mui: Mui,
       mb : MuiBasics;

VAR okstr      * ,
    helpstr    * ,
    cancelstr  * : e.STRPTR;
    oksc*,helpsc*,
    casc       * : CHAR;

PROCEDURE StdBottom*(VAR ok,help,ca:mui.Object);

BEGIN
  mb.Child; mb.HGroup(mui.aGroupSameSize,e.true,u.done);
    mb.Child; ok:=mb.KeyButton(okstr^,oksc,mui.aWeight,100,u.done);
    mb.Child; help:=mb.SimpleButton(helpstr^,mui.aWeight,100,u.done);
    mb.Child; mb.RectangleObject(mui.aWeight,400,u.done); mb.end;
    mb.Child; ca:=mb.KeyButton(cancelstr^,casc,mui.aWeight,100,u.done);
  mb.end;
END StdBottom;

PROCEDURE CheckMark*(checked:BOOLEAN):mui.Object;

VAR gad : mui.Object;

BEGIN
  mb.HGroup(mui.aWeight,0); (* mb.Child before calling this function *)
    mb.Child; gad:=mb.CheckMark(checked);
    mb.Child; mb.RectangleObject; mb.end;
  mb.end;
  RETURN gad;
END CheckMark;

PROCEDURE KeyCheckMark*(checked:BOOLEAN;short:CHAR):mui.Object;

VAR gad   : mui.Object;
    lbool : e.LONGBOOL;

BEGIN
  IF checked THEN
    lbool:=e.true;
  ELSE
    lbool:=e.false;
  END;
  mb.HGroup(mui.aWeight,0); (* Remember to call mb.Child before this function *)
    mb.Child; gad:=mb.KeyCheckMark(lbool,short);
    mb.Child; mb.RectangleObject; mb.end;
  mb.end;
  RETURN gad;
END KeyCheckMark;

PROCEDURE LabelCheckMark*(checked:BOOLEAN;label:ARRAY OF CHAR):mui.Object;

VAR gad : mui.Object;

BEGIN
  mb.label1(label); mb.Child; gad:=CheckMark(checked);
  RETURN gad;
END LabelCheckMark;

PROCEDURE KeyLabelCheckMark*(checked:BOOLEAN;label:ARRAY OF CHAR;short:CHAR):mui.Object;

VAR gad : mui.Object;

BEGIN
  mb.keyLabel1(label,short); mb.Child; gad:=KeyCheckMark(checked,short);
  RETURN gad;
END KeyLabelCheckMark;

PROCEDURE ID*(adr:s.ADDRESS):LONGINT;

BEGIN
  RETURN s.VAL(LONGINT,adr);
END ID;

PROCEDURE IDS*(str:ARRAY 4 OF CHAR):LONGINT;

BEGIN
  RETURN s.VAL(LONGINT,str);
END IDS;

PROCEDURE ReturnID*(app,muiobj:mui.Object);

BEGIN
  mui.DoMethod(muiobj,mui.mNotify,mui.aPressed,e.false,app,2,mui.mApplicationReturnID,ID(muiobj));
END ReturnID;

PROCEDURE GetString*(stringgad:mui.Object;string:e.STRPTR);

VAR strptr : e.STRPTR;

BEGIN
  mb.Get(stringgad,mui.aStringContents,strptr);
  COPY(strptr^,string^);
END GetString;

PROCEDURE GetCheckmark*(checkgad:mui.Object;VAR bool:BOOLEAN);

VAR lbool : e.LONGBOOL;

BEGIN
  mb.Get(checkgad,mui.aSelected,lbool);
  IF lbool=e.true THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
END GetCheckmark;

PROCEDURE InsertList*(muilist:mui.Object;list:l.List);

VAR node : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    mui.DoMethod(muilist,mui.mListInsertSingle,node,mui.vListInsertBottom);
    node:=node.next;
  END;
END InsertList;

BEGIN
  okstr:=s.ADR("OK"); oksc:="o";
  helpstr:=s.ADR("Hilfe"); helpsc:=0X;
  cancelstr:=s.ADR("Abbrechen"); casc:="a";
END MuiTools.


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


MODULE LocaleTools;

IMPORT l : Locale,
       e : Exec;

VAR os2       : BOOLEAN;
    strbuffer : e.STRPTR;
    catalog * : l.CatalogPtr;

PROCEDURE GetCatalogStr*(catalog:l.CatalogPtr;stringNum:LONGINT;defaultString:ARRAY OF CHAR):e.STRPTR;

VAR str : e.STRPTR;

BEGIN
  IF (os2) AND (catalog#NIL) THEN
    str:=l.GetCatalogStr(catalog,stringNum,defaultString);
  ELSE
    COPY(defaultString,strbuffer^);
    str:=strbuffer
  END;
  RETURN str;
END GetCatalogStr;

PROCEDURE GetCatStr*(stringNum:LONGINT;defaultString:ARRAY OF CHAR):e.STRPTR;

VAR str : e.STRPTR;

BEGIN
  IF (os2) AND (catalog#NIL) THEN
    str:=l.GetCatalogStr(catalog,stringNum,defaultString);
  ELSE
    COPY(defaultString,strbuffer^);
    str:=strbuffer
  END;
  RETURN str;
END GetCatStr;

BEGIN
  IF l.base#NIL THEN
    os2:=TRUE;
  ELSE
    os2:=FALSE;
  END;
  strbuffer:=e.AllocMem(256,LONGSET{e.memClear});
CLOSE
  e.FreeMem(strbuffer,256);
END LocaleTools.


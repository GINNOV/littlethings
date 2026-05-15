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


MODULE VersionStrings;

IMPORT e  : Exec,
       s  : SYSTEM,
       st : Strings,
       ac : AnalayCatalog,
       NoGuruRq;

VAR versionstring      * ,
    version            * ,
    progversion        * ,
    copyright          * ,
    mainscreentitle    * ,
    mainwindtitle      * ,
    layoutscreentitle  * : e.STRPTR;
    layoutscreentitlestr : ARRAY 256 OF CHAR;

BEGIN
  versionstring:=s.ADR("$VER: Analay V2.0ß2 16.03.96");
  version:=s.ADR("2.0ß2");
  progversion:=s.ADR("Analay V2.0ß2");
  copyright:=s.ADR("© 1996 Marc Necker");
  mainscreentitle:=s.ADR("Analay V2.0ß2 © 1991-1996 Marc Necker");
  mainwindtitle:=s.ADR("Analay V2.0ß2 © 1991-1996 Marc Necker");
  layoutscreentitlestr:="Analay V2.0ß2 © 1991-1996 Marc Necker  ";
  st.Append(layoutscreentitlestr,ac.GetString(ac.LayoutWorkingScreenTitle)^);
  layoutscreentitle:=s.ADR(layoutscreentitlestr);
END VersionStrings.


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


MODULE LayoutBasics;

IMPORT I  : Intuition,
       l  : LinkedLists,
       btp: BasicTypes,
       NoGuruRq;

TYPE LayoutOptions * = POINTER TO LayoutOptionsDesc;
     LayoutOptionsDesc * = RECORD
       toolbox    * ,
       showinact  * ,
       ownscreen  * : BOOLEAN;
     END;

VAR layoutoptions * : LayoutOptions;
    screen        * : I.ScreenPtr;   (* Always contains a valid pointer to the Layout screen *)
    maindisp      * : btp.ANY;       (* Valid pointer to mg.maindisp *)

BEGIN
  layoutoptions:=NIL;
  NEW(layoutoptions);
  layoutoptions.toolbox:=TRUE;
  layoutoptions.showinact:=FALSE;
  layoutoptions.ownscreen:=FALSE;
CLOSE
  IF layoutoptions#NIL THEN DISPOSE(layoutoptions); END;
END LayoutBasics.


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


MODULE TabularWindow;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       w  : Window,
       NoGuruRq;

(* This class is root class for tables and lists *)

TYPE TabularWindow * = POINTER TO TabularWindowDesc;
     TabularWindowDesc * = RECORD(w.WindowDesc);
       hindex     * ,
       vindex     * ,
       linewidth  * ,
       lineheight * ,
       left       * ,
       top        * ,
       color      * : INTEGER;
     END;

END TabularWindow.


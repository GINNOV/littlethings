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


MODULE TableWindow;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       tw : TabularWindow,
       NoGuruRq;

TYPE TableSpalt * = RECORD(l.NodeDesc);
       string   * : ARRAY 256 OF CHAR;
       color    * : INTEGER;
       style    * : SHORTSET;
       width    * ,
       integwidth*,
       floatwidth*,
       pointwidth*: INTEGER;
       pwidth   * ,
       pintegwidth*,
       pfloatwidth*,
       ppointwidth*: LONGREAL;
     END;
     TableZeil * = RECORD(l.NodeDesc);
       spalten  * : l.List;
       samecol  * ,
       samefont * : BOOLEAN;
       height   * : INTEGER;
       pheight  * : LONGREAL;
     END;
     Table * = RECORD(tw.TabularWindowDesc);
       zeilen   * : l.List;
       samewi   * ,
       samecol  * ,
       center   * ,
       dectab   * ,
       firstsep * : BOOLEAN;
       attr     * : g.TextAttr;
       colf     * ,
       colb     * : INTEGER;
       xpos     * ,
       ypos     * ,
       width    * ,
       height   * ,
       lwidth   * ,
       lheight  * : INTEGER;
       pwidth   * ,
       pheight  * : LONGREAL;
     END;

END TableWindow.


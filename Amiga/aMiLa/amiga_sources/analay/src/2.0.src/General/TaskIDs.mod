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


MODULE TaskIDs;

CONST noID              * = 0;   (* If a task does not need to be identified *)

      axisRangeTaskID   * = 1;
      gridTaskID        * = 2;
      axisLabelsTaskID  * = 3;
      graphDesignTaskID * = 4;
      changeTaskID      * = 5;

      enterTermsTaskID  * = 6;
      defineTaskID      * = 7;
      connectTaskID     * = 8;
      quickInputTaskID  * = 9;
      processTermsTaskID* = 10;
      plotMenuTaskID    * = 11;

      changeLegendTaskID* = 18;
      changeTableTaskID * = 19;

      analayInfoTaskID  * = 12;
      changeResTaskID   * = 13;
      changeFontsTaskID * = 14;
      changePrisTaskID  * = 20;
      integTaskID       * = 15;

      layoutMainTaskID  * = 16;
      layoutChangeColorsID*=17;
      layoutColorConvID * = 18;
      layoutLineConvID  * = 19;
      layoutGridConvID  * = 20;
      layoutLabelsConvID* = 21;
      layoutFontConvID  * = 22;

END TaskIDs.


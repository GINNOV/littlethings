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


MODULE InflectionObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       st : Strings,
       l  : LinkedLists,
       lrc: LongRealConversions,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       gb : GeneralBasics,
       mb : MathBasics,
       mg : MathGUI,
       w  : Window,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       do : DiscussionObject,
       zo : ZeroObject,
       ac : AnalayCatalog,
       NoGuruRq;


TYPE InflectionObject * = POINTER TO InflectionObjectDesc;
     InflectionObjectDesc * = RECORD(zo.ZeroObjectDesc)
       funcgraph * : fg.FunctionGraph;
       stutz     * : LONGINT;
     END;

PROCEDURE (dobj:InflectionObject) Init*;

BEGIN
  dobj.Init^;
  dobj.reqtitle:=ac.GetString(ac.PointsOfInflection);
  dobj.discusstitle:=s.ADR("Points of inflection of function");
  dobj.statustitle:=ac.GetString(ac.FindingPointsOfInflection);
END Init;

PROCEDURE (discussobj:InflectionObject) InitDiscObject*(window:w.Window;funcs:l.List;coords:c.CoordSystem):BOOLEAN;

VAR func      : l.Node;

BEGIN
  func:=gb.SelectNode(funcs,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,mg.mainsub.GetWindow());
  IF func#NIL THEN
    WITH func: wf.WindowFunction DO
      discussobj.stutz:=func.graphs.head(fg.FunctionGraph).stutz;
      discussobj.funcgraph:=NIL;

(* Fill variables of function family here *)

      discussobj.window:=window;
      discussobj.func:=func.func.AbleitFunction("x");
      discussobj.table:=NIL;
      discussobj.coords:=coords.CopyNew()(c.CoordSystem);
    END;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END InitDiscObject;

PROCEDURE (discussobj:InflectionObject) InitDiscussion*;

VAR funcgraph : fg.FunctionGraph;

BEGIN
  discussobj.InitDiscussion^;
  IF discussobj.funcgraph=NIL THEN
    NEW(funcgraph); funcgraph.Init;
    funcgraph.InitGraph(discussobj.stutz);
    funcgraph.CalcTable(discussobj.func,discussobj.coords,discussobj.statusbar);
    discussobj.funcgraph:=funcgraph;
    discussobj.table:=funcgraph.table;
  END;
END InitDiscussion;

PROCEDURE (discussobj:InflectionObject) Destruct*;

BEGIN
  IF discussobj.funcgraph#NIL THEN discussobj.funcgraph.Destruct; END;
  IF discussobj.func#NIL THEN discussobj.func.Destruct; END;
  IF discussobj.coords#NIL THEN discussobj.coords.Destruct; END;
  discussobj.Destruct^;
END Destruct;

PROCEDURE (dobj:InflectionObject) FindNext*():do.Result;

VAR result : do.Result;

BEGIN
  result:=dobj.FindNext^();
  IF result#NIL THEN
    result.comment:="";
    IF (result.left>0) AND (result.right<0) THEN
      COPY(ac.GetString(ac.CurvatureLeftRight)^,result.comment);
    ELSIF (result.left<0) AND (result.right>0) THEN
      COPY(ac.GetString(ac.CurvatureRightLeft)^,result.comment);
    END;
  END;

  RETURN result;
END FindNext;

END InflectionObject.


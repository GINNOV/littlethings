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


MODULE IntersectionObject;

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

TYPE IntersectionObject * = POINTER TO IntersectionObjectDesc;
     IntersectionObjectDesc * = RECORD(zo.ZeroObjectDesc)
       func1,func2 : t.Function;
       funcgraph   : fg.FunctionGraph;
       stutz       : LONGINT;
     END;

PROCEDURE (dobj:IntersectionObject) Init*;

BEGIN
  dobj.Init^;
  dobj.reqtitle:=ac.GetString(ac.Intersections);
  dobj.discusstitle:=s.ADR("Intersections of functions");
  dobj.statustitle:=ac.GetString(ac.FindingIntersections);
END Init;

PROCEDURE (discussobj:IntersectionObject) InitDiscObject*(window:w.Window;funcs:l.List;coords:c.CoordSystem):BOOLEAN;

VAR func1,func2 : l.Node;

BEGIN
  func1:=gb.SelectNode(funcs,ac.GetString(ac.SelectFunction1),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,mg.mainsub.GetWindow());
  IF func1#NIL THEN
    func2:=gb.SelectNode(funcs,ac.GetString(ac.SelectFunction2),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,mg.mainsub.GetWindow());
    IF func2#NIL THEN
      WITH func1: wf.WindowFunction DO
        WITH func2: wf.WindowFunction DO
          discussobj.stutz:=func1.graphs.head(fg.FunctionGraph).stutz;
          discussobj.funcgraph:=NIL;
    
    (* Fill variables of function family here *)
    
          discussobj.window:=window;
          discussobj.func1:=func1.func.CopyNew()(t.Function);
          discussobj.func2:=func2.func.CopyNew()(t.Function);
          discussobj.func:=discussobj.func1;
          discussobj.func.diffunc:=discussobj.func2;
          discussobj.table:=NIL;
          discussobj.coords:=coords.CopyNew()(c.CoordSystem);

(*
          discussobj.window:=window;
          discussobj.func1:=func1.func.CopyNew()(t.Function);
          discussobj.func2:=func2.func.CopyNew()(t.Function);
          NEW(discussobj.func); discussobj.func.Init;
          discussobj.func1.Copy(discussobj.func);
          discussobj.func.diffunc:=discussobj.func2;
          discussobj.table:=NIL;
          discussobj.coords:=coords.CopyNew()(c.CoordSystem);
*)
          RETURN TRUE;
        END;
      END;
    END;
  END;
  RETURN FALSE;
END InitDiscObject;

PROCEDURE (discussobj:IntersectionObject) InitDiscussion*;

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

PROCEDURE (discussobj:IntersectionObject) Destruct*;

BEGIN
  IF discussobj.funcgraph#NIL THEN discussobj.funcgraph.Destruct; END;
  IF discussobj.func1#NIL THEN discussobj.func1.Destruct; END;
  IF discussobj.func2#NIL THEN discussobj.func2.Destruct; END;
  IF discussobj.coords#NIL THEN discussobj.coords.Destruct; END;
  discussobj.Destruct^;
END Destruct;

PROCEDURE (discussobj:IntersectionObject) FindNext*():do.Result;

VAR result : do.Result;

BEGIN
  result:=discussobj.FindNext^();
  result.comment:="";
  RETURN result;
END FindNext;

END IntersectionObject.


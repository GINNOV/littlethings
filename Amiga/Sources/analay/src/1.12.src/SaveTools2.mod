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


MODULE SaveTools2;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       p  : Printer,
       bt : BasicTypes,
       es : ExecSupport,
       fr : FileReq,
       it : IntuitionTools,
       tt : TextTools,
       at : AslTools,
       gm : GadgetManager,
       wm : WindowManager,
       mm : MenuManager,
       pi : PreviewImages,
       pt : Pointers,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       s6 : SuperCalcTools6,
       s7 : SuperCalcTools7,
       s8 : SuperCalcTools8,
       s9 : SuperCalcTools9,
       s10: SuperCalcTools10,
       s11: SuperCalcTools11,
       s12: SuperCalcTools12,
       s13: SuperCalcTools13,
       s14: SuperCalcTools14,
       s15: SuperCalcTools15,
       s16: SuperCalcTools16,
       p1 : Preview1,
       p2 : Preview2,
       p3 : Preview3,
       p4 : Preview4,
       sv1: SaveTools1,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- ReturnChk- *)

VAR i,a,j     : INTEGER;
    class     : LONGSET;
    code      : INTEGER;
    address   : s.ADDRESS;
    long      : LONGINT;
    bool      : BOOLEAN;
    string    : ARRAY 20 OF CHAR;
    sample    : l.Node;
    short     : SHORTINT;

PROCEDURE ReadNode*(VAR node:l.Node);

VAR i      : INTEGER;
    sample : l.Node;
    bool   : BOOLEAN;
    type   : SHORTINT;

PROCEDURE ReadList(VAR list:l.List;sample:l.Node);

VAR node : l.Node;
    bool : BOOLEAN;

BEGIN
  list:=l.Create();
  sv1.ReadBoolean(bool);
  WHILE bool DO
    IF sample#NIL THEN
      IF sample IS s1.Term THEN
        NEW(node(s1.Term));
      ELSIF sample IS s1.Function THEN
        NEW(node(s1.Function));
      ELSIF sample IS s1.FuncTerm THEN
        NEW(node(s1.FuncTerm));
      ELSIF sample IS s1.Define THEN
        NEW(node(s1.Define));
      ELSIF sample IS s1.Depend THEN
        NEW(node(s1.Depend));
      ELSIF sample IS s1.AreaDim THEN
        NEW(node(s1.AreaDim));
      ELSIF sample IS s1.LegendElement THEN
        NEW(node(s1.LegendElement));
      ELSIF sample IS s1.TableZeil THEN
        NEW(node(s1.TableZeil));
      ELSIF sample IS s1.TableSpalt THEN
        NEW(node(s1.TableSpalt));
      ELSIF sample IS s1.ListSpalt THEN
        NEW(node(s1.ListSpalt));
      ELSIF sample IS s1.ListZeil THEN
        NEW(node(s1.ListZeil));
      ELSIF sample IS s1.FensterFunc THEN
        NEW(node(s1.FensterFunc));
      ELSIF sample IS s1.FunctionGraph THEN
        NEW(node(s1.FunctionGraph));
      ELSIF sample IS s1.Text THEN
        NEW(node(s1.Text));
      ELSIF sample IS s1.Point THEN
        NEW(node(s1.Point));
      ELSIF sample IS s1.Mark THEN
        NEW(node(s1.Mark));
      ELSIF sample IS s1.Area THEN
        NEW(node(s1.Area));
      ELSIF sample IS s1.Legend THEN
        NEW(node(s1.Legend));
      ELSIF sample IS s1.Table THEN
        NEW(node(s1.Table));
      ELSIF sample IS s1.List THEN
        NEW(node(s1.List));
      ELSIF sample IS s1.Fenster THEN
        NEW(node(s1.Fenster));
      ELSIF sample IS f1.Variable THEN
        NEW(node(f1.Variable));
      ELSIF sample IS s1.Constant THEN
        NEW(node(s1.Constant));
      ELSIF sample IS s1.Label THEN
        NEW(node(s1.Label));
(*      ELSIF sample IS p1.TextAbsatz THEN
        NEW(node(p1.TextAbsatz));
      ELSIF sample IS p1.TextChar THEN
        NEW(node(p1.TextChar));
      ELSIF sample IS p1.Font THEN
        NEW(node(p1.Font));
      ELSIF sample IS p1.FontSize THEN
        NEW(node(p1.FontSize));
      ELSIF sample IS p1.Color THEN
        NEW(node(p1.Color));
      ELSIF sample IS p1.FontConvert THEN
        NEW(node(p1.FontConvert));*)
      END;
      s1.InitNode(node);
    ELSE
      node:=NIL;
    END;
    ReadNode(node);
    list.AddTail(node);
    sv1.ReadBoolean(bool);
  END;
END ReadList;

PROCEDURE ReadListNode(list:l.List;VAR node:l.Node);

VAR i : INTEGER;

BEGIN
  sv1.ReadBoolean(bool);
  IF bool THEN
    sv1.ReadInt(i);
    IF i>=0 THEN
      node:=s1.GetNode(list,i);
    ELSE
      node:=NIL;
    END;
  ELSE
    ReadNode(node);
  END;
END ReadListNode;

PROCEDURE ReadScaleConvert(conv:p1.ScaleConvertPtr);

BEGIN
  ReadListNode(p1.fonts,conv.font);
  ReadListNode(conv.font(p1.Font).sizes,conv.size);
  ReadListNode(p1.colors,conv.color);
  sv1.ReadInt(conv.width);
  sv1.ReadBoolean(conv.stdfont);
  sv1.ReadBoolean(conv.stdcolor);
  sv1.ReadBoolean(conv.stdwidth);
END ReadScaleConvert;

PROCEDURE ReadGridConvert(conv:p1.GridConvertPtr);

BEGIN
  ReadListNode(p1.colors,conv.color);
  sv1.ReadInt(conv.width);
  sv1.ReadBoolean(conv.stdcolor);
  sv1.ReadBoolean(conv.stdwidth);
END ReadGridConvert;

BEGIN
  IF node#NIL THEN
    IF node IS s1.Coord THEN
      WITH node: s1.Coord DO
        sv1.ReadString(node.xkstr);
        sv1.ReadString(node.ykstr);
        sv1.ReadBoolean(node.welt);
      END;
      IF node IS s1.GraphObject THEN
        WITH node: s1.GraphObject DO
          sv1.ReadInt(node.colf);
          sv1.ReadInt(node.colb);
          sv1.ReadBoolean(node.trans);
          sv1.ReadInt(i);
          node.style:=s.VAL(SHORTSET,SHORT(i));
          sv1.ReadTextAttr(s.ADR(node.attr));
        END;
        IF node IS s1.Text THEN
          WITH node: s1.Text DO
            sv1.ReadString(node.string);
            sv1.ReadBoolean(node.snap);
          END;
        ELSIF node IS s1.Point THEN
          WITH node: s1.Point DO
            sv1.ReadString(node.string);
            NEW(node.label(s1.Label));
            ReadListNode(s1.labels,node.label);
(*            sv1.ReadBoolean(bool);
            IF bool THEN
              sv1.ReadInt(i);
              node.label:=s1.GetNode(s1.labels,i);
            ELSE
              NEW(node.label(s1.Label));
              ReadNode(node.label);
            END;*)
            sv1.ReadInt(node.point);
            sv1.ReadBoolean(node.snap);
            sv1.ReadBoolean(node.exp);
            sv1.ReadInt(node.nach);
            sv1.ReadBoolean(node.fill);
          END;
        ELSIF node IS s1.Mark THEN
          WITH node: s1.Mark DO
            sv1.ReadString(node.string);
            NEW(node.label(s1.Label));
            ReadListNode(s1.labels,node.label);
(*            sv1.ReadBoolean(bool);
            IF bool THEN
              sv1.ReadInt(i);
              node.label:=s1.GetNode(s1.labels,i);
            ELSE
              NEW(node.label(s1.Label));
              ReadNode(node.label);
            END;*)
            sv1.ReadInt(node.line);
            sv1.ReadInt(node.width);
            sv1.ReadInt(node.textdir);
            sv1.ReadInt(node.textside);
            sv1.ReadBoolean(node.snap);
            sv1.ReadBoolean(node.exp);
            sv1.ReadInt(node.nach);
          END;
        END;
      END;
    ELSIF node IS s1.Area THEN
      WITH node: s1.Area DO
        sv1.ReadString(node.name);
        NEW(sample(s1.AreaDim));
        ReadList(node.dims,sample);
        sv1.ReadInt(node.pattern);
        sv1.ReadInt(node.colf);
        sv1.ReadInt(node.colb);
        sv1.ReadBoolean(node.clearb);
        sv1.ReadBoolean(node.areab);
      END;
    ELSIF node IS s1.AreaDim THEN
      WITH node: s1.AreaDim DO
        sv1.ReadInt(node.type);
        sv1.ReadString(node.name);
        sv1.ReadString(node.string);
        sv1.ReadString(node.xcoords);
        sv1.ReadString(node.ycoords);
        node.xcoord:=f.ExpressionToReal(node.xcoords);
        node.ycoord:=f.ExpressionToReal(node.ycoords);
        sv1.ReadBoolean(node.up);
        sv1.ReadBoolean(node.down);
        sv1.ReadBoolean(node.left);
        sv1.ReadBoolean(node.right);
        sv1.ReadBoolean(node.include);
      END;
    ELSIF node IS s1.Legend THEN
      WITH node: s1.Legend DO
        sv1.ReadString(node.name);
        NEW(sample(s1.LegendElement));
        ReadList(node.elements,sample);
        sv1.ReadBoolean(node.outsame);
        sv1.ReadBoolean(node.insame);
        sv1.ReadBoolean(node.fontsame);
        sv1.ReadBoolean(node.einruck);
        sv1.ReadBoolean(node.vorbild);
        sv1.ReadInt(i);
        IF i>=0 THEN
          node.default:=s1.GetNode(s1.fenster,i);
        ELSE
          node.default:=NIL;
        END;
        sv1.ReadInt(node.xpos);
        sv1.ReadInt(node.ypos);
        sv1.ReadInt(node.width);
        sv1.ReadInt(node.height);
        sv1.ReadTextAttr(s.ADR(node.attr));
        node.refresh:=TRUE;
      END;
    ELSIF node IS s1.LegendElement THEN
      WITH node: s1.LegendElement DO
        sv1.ReadString(node.term);
        sv1.ReadInt(node.col);
        sv1.ReadInt(node.line);
        sv1.ReadInt(node.width);
        sv1.ReadInt(node.point);
        sv1.ReadBoolean(node.sub);
      END;
    ELSIF node IS s1.Table THEN
      WITH node: s1.Table DO
        sv1.ReadString(node.name);
        NEW(sample(s1.TableZeil));
        ReadList(node.zeilen,sample);
        sv1.ReadBoolean(node.samewi);
        sv1.ReadBoolean(node.samecol);
        sv1.ReadBoolean(node.center);
        sv1.ReadBoolean(node.dectab);
        sv1.ReadBoolean(node.firstsep);
        sv1.ReadDesign(s.ADR(node.design));
        sv1.ReadTextAttr(s.ADR(node.attr));
        sv1.ReadInt(node.colf);
        sv1.ReadInt(node.colb);
        sv1.ReadInt(node.xpos);
        sv1.ReadInt(node.ypos);
        sv1.ReadInt(node.width);
        sv1.ReadInt(node.height);
  (*      sv1.ReadInt(node.lwidth);
        sv1.ReadInt(node.lheight);
        sv1.ReadReal(node.pwidth);
        sv1.ReadReal(node.pheight);*)
        node.refresh:=TRUE;
        IF s1.window#NIL THEN
          s11.RefreshTableDatas(s1.window.rPort,node);
        END;
      END;
    ELSIF node IS s1.TableZeil THEN
      WITH node: s1.TableZeil DO
        NEW(sample(s1.TableSpalt));
        ReadList(node.spalten,sample);
        sv1.ReadBoolean(node.samecol);
        sv1.ReadBoolean(node.samefont);
  (*      sv1.ReadInt(node.height);
        sv1.ReadReal(node.pheight);*)
      END;
    ELSIF node IS s1.TableSpalt THEN
      WITH node: s1.TableSpalt DO
        sv1.ReadString(node.string);
        sv1.ReadInt(node.color);
        sv1.ReadInt(i);
        node.style:=s.VAL(SHORTSET,SHORT(i));
  (*      sv1.ReadInt(node.width);
        sv1.ReadReal(node.pwidth);*)
      END;
    ELSIF node IS s1.List THEN
      WITH node: s1.List DO
        sv1.ReadString(node.name);
        NEW(sample(s1.ListSpalt));
        ReadList(node.spalten,sample);
        sv1.ReadBoolean(node.samewi);
        sv1.ReadBoolean(node.samecol);
        sv1.ReadBoolean(node.center);
        sv1.ReadBoolean(node.dectab);
        sv1.ReadBoolean(node.topsep);
        sv1.ReadBoolean(node.samefield);
        sv1.ReadDesign(s.ADR(node.design));
        sv1.ReadTextAttr(s.ADR(node.attr));
        sv1.ReadInt(node.colf);
        sv1.ReadInt(node.colb);
        sv1.ReadInt(node.xpos);
        sv1.ReadInt(node.ypos);
        sv1.ReadInt(node.width);
        sv1.ReadInt(node.height);
  (*      sv1.ReadInt(node.lwidth);
        sv1.ReadInt(node.lheight);
        sv1.ReadReal(node.pwidth);
        sv1.ReadReal(node.pheight);*)
        node.refresh:=TRUE;
        IF s1.window#NIL THEN
          s10.RefreshListDatas(s1.window.rPort,node);
        END;
      END;
    ELSIF node IS s1.ListSpalt THEN
      WITH node: s1.ListSpalt DO
        NEW(sample(s1.ListZeil));
        ReadList(node.zeilen,sample);
        sv1.ReadBoolean(node.samecol);
        sv1.ReadBoolean(node.samefont);
  (*      sv1.ReadInt(node.width);
        sv1.ReadReal(node.pwidth);*)
      END;
    ELSIF node IS s1.ListZeil THEN
      WITH node: s1.ListZeil DO
        sv1.ReadString(node.string);
        sv1.ReadInt(node.color);
        sv1.ReadInt(i);
        node.style:=s.VAL(SHORTSET,SHORT(i));
      END;
    ELSIF node IS s1.Label THEN
      WITH node: s1.Label DO
        sv1.ReadString(node.string);
      END;
    ELSIF node IS s1.Function THEN
      WITH node: s1.Function DO
        sv1.ReadString(node.name);
        NEW(sample(s1.FuncTerm));
        ReadList(node.terms,sample);
        sample:=NIL;
        NEW(sample(s1.Depend));
        ReadList(node.depend,sample);
        sample:=NIL;
        NEW(sample(s1.Define));
        ReadList(node.define,sample);
        sv1.ReadBoolean(node.isbase);
        node.changed:=TRUE;
      END;
    ELSIF node IS s1.FuncTerm THEN
      WITH node: s1.FuncTerm DO
        sv1.ReadBoolean(bool);
        IF bool THEN
          sv1.ReadInt(i);
          node.termnum:=i;
  (*        node.term:=s1.GetNode(s1.terms,i);*)
        ELSE
          node.termnum:=-1;
          NEW(node.term(s1.Term));
          node.term(s1.Term).define:=l.Create();
          node.term(s1.Term).depend:=l.Create();
          ReadNode(node.term);
        END;
      END;
    ELSIF node IS s1.Term THEN
      WITH node: s1.Term DO
        sv1.ReadString(node.string);
        NEW(sample(s1.Depend));
        ReadList(node.depend,sample);
        sample:=NIL;
        NEW(sample(s1.Define));
        ReadList(node.define,sample);
        sv1.ReadInt(i);
        IF i>=0 THEN
          node.basefunc:=s1.GetNode(s1.functions,i);
        ELSE
          node.basefunc:=NIL;
        END;
        node.changed:=TRUE;
      END;
    ELSIF node IS s1.Depend THEN
      WITH node: s1.Depend DO
        NEW(node.var(f1.Variable));
        ReadListNode(f.objects,node.var);
(*        sv1.ReadBoolean(bool);
        IF bool THEN
          sv1.ReadInt(i);
          node.var:=s1.GetNode(s1.variables,i);
        ELSE
          NEW(node.var(f1.Variable));
          ReadNode(node.var);
        END;*)
      END;
    ELSIF node IS s1.Define THEN
      WITH node: s1.Define DO
        sv1.ReadString(node.string);
      END;
      i:=s6.MakeDefine(node);
    ELSIF node IS f1.Variable THEN
      WITH node: f1.Variable DO
        sv1.ReadString(node.string);
      END;
    ELSIF node IS f1.Constant THEN
      WITH node: f1.Constant DO
        NEW(node.name,256);
        sv1.ReadString(node.name^);
        NEW(node.comment,256);
        sv1.ReadString(node.comment^);
        sv1.ReadReal(node.real);
        sv1.ReadString(node.realstr);
        sv1.ReadInt(node.internal);
        sv1.ReadBoolean(node.isInternal);
      END;
    ELSIF node IS s1. Fenster THEN
      WITH node: s1.Fenster DO
        s5.InitFenster(node);
        sv1.ReadString(node.name);
        sv1.ReadInt(node.xpos);
        sv1.ReadInt(node.ypos);
        sv1.ReadInt(node.width);
        sv1.ReadInt(node.height);
        sv1.ReadString(node.xmins);
        sv1.ReadString(node.xmaxs);
        sv1.ReadString(node.ymins);
        sv1.ReadString(node.ymaxs);
        sv1.ReadString(node.oldxmins);
        sv1.ReadString(node.oldxmaxs);
        sv1.ReadString(node.oldymins);
        sv1.ReadString(node.oldymaxs);
        sv1.ReadGrid(s.ADR(node.grid1));
        sv1.ReadGrid(s.ADR(node.grid2));
        sv1.ReadSkala(s.ADR(node.scale));
        NEW(sample(s1.FensterFunc));
        ReadList(node.funcs,sample);
        sample:=NIL;
        NEW(sample(s1.Text));
        ReadList(node.texts,sample);
        sample:=NIL;
        NEW(sample(s1.Point));
        ReadList(node.points,sample);
        sample:=NIL;
        NEW(sample(s1.Mark));
        ReadList(node.marks,sample);
        sample:=NIL;
        NEW(sample(s1.Area));
        ReadList(node.areas,sample);
        sv1.ReadInt(node.mode);
        sv1.ReadInt(node.backcol);
        sv1.ReadBoolean(node.transparent);
        sv1.ReadBoolean(node.freeborder);
        sv1.ReadBoolean(node.autofuncscale);
        sv1.ReadBoolean(node.autoskalascale);
        sv1.ReadBoolean(node.autogridscale);
        sv1.ReadInt(node.stutz);
        s2.RefreshWindowData(node);
        node.refresh:=TRUE;
      END;
    ELSIF node IS s1.FensterFunc THEN
      WITH node: s1.FensterFunc DO
        NEW(node.func(s1.Function));
        ReadListNode(s1.functions,node.func);
(*        sv1.ReadBoolean(bool);
        IF bool THEN
          sv1.ReadInt(i);
          node.func:=s1.GetNode(s1.functions,i);
        ELSE
          NEW(node.func(s1.Function));
          ReadNode(node.func);
        END;*)
        NEW(sample(s1.FunctionGraph));
        ReadList(node.graphs,sample);
      END;
    ELSIF node IS s1.FunctionGraph THEN
      WITH node: s1.FunctionGraph DO
        node.bordervals:=l.Create();
        sv1.ReadInt(node.col);
        sv1.ReadInt(node.line);
        sv1.ReadInt(node.width);
      END;
    END;
  ELSE
    sv1.ReadShort(type);
    IF type=1 THEN
      NEW(node(p1.Fenster));
    ELSIF type=2 THEN
      NEW(node(p1.Legend));
    ELSIF type=3 THEN
      NEW(node(p1.Table));
    ELSIF type=4 THEN
      NEW(node(p1.List));
    ELSIF type=5 THEN
      NEW(node(p1.MathBox));
    ELSIF type=6 THEN
      NEW(node(p1.Line));
    ELSIF type=7 THEN
      NEW(node(p1.Rect));
    ELSIF type=8 THEN
      NEW(node(p1.Circle));
    ELSIF type=9 THEN
      NEW(node(p1.Graph));
    ELSIF type=10 THEN
      NEW(node(p1.TextLine));
    ELSIF type=11 THEN
      NEW(node(p1.TextBlock));
    ELSIF type=12 THEN
      NEW(node(p1.Box));
    ELSIF type=13 THEN
      NEW(node(p1.TextAbsatz));
    ELSIF type=20 THEN
      NEW(node(p1.TextFunc));
    ELSIF type=14 THEN
      NEW(node(p1.TextChar));
    ELSIF type=15 THEN
      NEW(node(p1.TextDesigner));
    ELSIF type=16 THEN
      NEW(node(p1.Font));
    ELSIF type=17 THEN
      NEW(node(p1.FontSize));
    ELSIF type=21 THEN
      NEW(node(p1.Path));
    ELSIF type=18 THEN
      NEW(node(p1.Color));
    ELSIF type=19 THEN
      NEW(node(p1.FontConvert));
    END;
    IF node IS p1.Box THEN
      WITH node: p1.Box DO
        sv1.ReadReal(node.xpos);
        sv1.ReadReal(node.ypos);
        sv1.ReadReal(node.width);
        sv1.ReadReal(node.height);
        sv1.ReadInt(node.pagepicx);
        sv1.ReadInt(node.pagepicy);
        sv1.ReadInt(node.pagepicwi);
        sv1.ReadInt(node.pagepiche);
        sv1.ReadString(node.sxpos);
        sv1.ReadString(node.sypos);
        sv1.ReadString(node.swidth);
        sv1.ReadString(node.sheight);
        sv1.ReadBoolean(node.locked);
        sv1.ReadBoolean(node.fastdraw);
        node.poschanged:=TRUE;
        node.sizechanged:=TRUE;
(*        node.xpos:=f.ExpressionToReal(node.sxpos);
        node.ypos:=f.ExpressionToReal(node.sypos);
        node.width:=f.ExpressionToReal(node.swidth);
        node.height:=f.ExpressionToReal(node.sheight);*)
      END;
      IF node IS p1.MathBox THEN
        WITH node: p1.MathBox DO
          NEW(node.scale);
          ReadScaleConvert(node.scale);
          NEW(node.grid);
          ReadGridConvert(node.grid);
          ReadListNode(p1.fonts,node.font);
          ReadListNode(node.font(p1.Font).sizes,node.size);
          ReadListNode(p1.colors,node.textcolor);
          ReadListNode(p1.colors,node.graphcolor);
          sv1.ReadInt(node.linewidth);
          sv1.ReadBoolean(node.stdscale);
          sv1.ReadBoolean(node.stdgrid);
          sv1.ReadBoolean(node.stdfont);
          sv1.ReadBoolean(node.stdtextcolor);
          sv1.ReadBoolean(node.stdgraphcolor);
          sv1.ReadBoolean(node.stdwidth);
        END;
        IF node IS p1.Fenster THEN
          WITH node: p1.Fenster DO
            ReadListNode(s1.fenster,node.node);
            s1.NewNodeShare(node.node);
            sv1.ReadString(node.xsource);
            sv1.ReadString(node.xdest);
            sv1.ReadString(node.ysource);
            sv1.ReadString(node.ydest);
            node.adaptchanged:=TRUE;
          END;
        ELSIF node IS p1.Legend THEN
          WITH node: p1.Legend DO
            ReadListNode(s1.legends,node.node);
            s1.NewNodeShare(node.node);
          END;
        ELSIF node IS p1.Table THEN
          WITH node: p1.Table DO
            ReadListNode(s1.tables,node.node);
            s1.NewNodeShare(node.node);
          END;
        ELSIF node IS p1.List THEN
          WITH node: p1.List DO
            ReadListNode(s1.lists,node.node);
            s1.NewNodeShare(node.node);
          END;
        END;
      ELSIF node IS p1.Graph THEN
        WITH node: p1.Graph DO
          ReadListNode(p1.colors,node.linecolor);
          ReadListNode(p1.colors,node.fillcolor);
          sv1.ReadBoolean(node.dofill);
          sv1.ReadInt(node.linewidth);
        END;
(*        IF node IS p1.Line THEN
          WITH node: p1.Line DO
          END;
        ELSIF node IS p1.Rect THEN
          WITH node: p1.Rect DO
          END;
        ELSIF node IS p1.Circle THEN
          WITH node: p1.Circle DO
          END;
        END;*)
      ELSIF node IS p1.TextLine THEN
        WITH node: p1.TextLine DO
          sv1.ReadString(node.string);
          ReadListNode(p1.fonts,node.font);
          ReadListNode(node.font(p1.Font).sizes,node.fontsize);
          ReadListNode(p1.colors,node.colf);
          ReadListNode(p1.colors,node.colb);
          sv1.ReadBoolean(node.trans);
        END;
      ELSIF node IS p1.TextBlock THEN
        WITH node: p1.TextBlock DO
(*          sample:=NIL;*)
(*          NEW(sample(p1.TextAbsatz));*)
          ReadList(node.absatz,NIL);
        END;
      END;
    ELSIF node IS p1.TextAbsatz THEN
      WITH node: p1.TextAbsatz DO
(*        sample:=NIL;*)
(*        NEW(sample(p1.TextChar));*)
        ReadList(node.charlist,NIL);
        sv1.ReadInt(node.type);
      END;
    ELSIF node IS p1.TextFunc THEN
      WITH node: p1.TextFunc DO
        sv1.ReadString(node.func);
      END;
    ELSIF node IS p1.TextChar THEN
      WITH node: p1.TextChar DO
        sv1.ReadShort(short);
        node.char:=s.VAL(CHAR,short);
      END;
    ELSIF node IS p1.TextDesigner THEN
      WITH node: p1.TextDesigner DO
        sv1.ReadShort(short);
        node.style:=s.VAL(SHORTSET,short);
        ReadListNode(p1.colors,node.colf);
        ReadListNode(p1.colors,node.colb);
        ReadListNode(p1.fonts,node.font);
        ReadListNode(node.font(p1.Font).sizes,node.size);
      END;
    ELSIF node IS p1.Font THEN
      WITH node: p1.Font DO
        sv1.ReadString(node.name);
        ReadListNode(p1.paths,node.path);
(*        sv1.ReadString(string);*)
(*        sv1.ReadString(node.path);*)
(*        sample:=NIL;*)
(*        NEW(sample(p1.FontSize));*)
        ReadList(node.sizes,NIL);
        node.fsizes:=l.Create();
        sv1.ReadBoolean(node.outline);
      END;
    ELSIF node IS p1.FontSize THEN
      WITH node: p1.FontSize DO
        sv1.ReadReal(node.size);
        sv1.ReadBoolean(node.ideal);
      END;
    ELSIF node IS p1.Path THEN
      WITH node: p1.Path DO
        sv1.ReadString(node.path);
      END;
    ELSIF node IS p1.Color THEN
      WITH node: p1.Color DO
        sv1.ReadString(node.name);
        sv1.ReadInt(node.red);
        sv1.ReadInt(node.green);
        sv1.ReadInt(node.blue);
        node.pen:=-1;
      END;
    ELSIF node IS p1.FontConvert THEN
      WITH node: p1.FontConvert DO
        sv1.ReadString(node.pixname);
        ReadListNode(p1.fonts,node.pointfont);
        sv1.ReadBoolean(node.standard);
      END;
    END;
  END;
END ReadNode;

END SaveTools2.


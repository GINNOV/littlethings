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


MODULE Function2;

IMPORT f1 : Function1,
       l  : LinkedLists,
       st : Strings,
       tt : TextTools,
       mt : MathTrans,
       lrc: LongRealConversions,
(*       rio: RealInOut,
       io,*)
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

PROCEDURE Calc(root:f1.NodePtr;VAR error:BOOLEAN):LONGREAL;

VAR left,right : LONGREAL;
    err        : INTEGER;

BEGIN
  error:=TRUE;
  IF (root#NIL) AND (root IS f1.Sign) AND (root.left#NIL) AND (root.right#NIL) AND (root.left IS f1.Number) AND (root.right IS f1.Number) THEN
    error:=FALSE;
    WITH root: f1.Sign DO
      left:=root.left(f1.Number).real;
      right:=root.right(f1.Number).real;
      IF root.sign="+" THEN
        left:=left+right;
      ELSIF root.sign="-" THEN
        left:=left-right;
      ELSIF root.sign="*" THEN
        left:=left*right;
      ELSIF root.sign="/" THEN
        IF right=0 THEN
          error:=TRUE;
        ELSE
          left:=left/right;
        END;
      ELSIF root.sign="^" THEN
        err:=0;
        left:=f1.PowLong(right,left,err);
        IF err#0 THEN
          error:=TRUE;
        END;
      END;
    END;
  END;
  RETURN left;
END Calc;

PROCEDURE Optimize*(VAR root:f1.NodePtr):BOOLEAN;

VAR node : f1.NodePtr;
    ret,
    bool : BOOLEAN;
    real : LONGREAL;

PROCEDURE CheckRemove(node:f1.NodePtr;real:LONGREAL):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF node#NIL THEN
    IF node IS f1.Number THEN
      IF node(f1.Number).real=real THEN
        ret:=TRUE;
        IF root.left=node THEN
          root.right.parent:=root.parent;
          root:=root.right;
        ELSE
          root.left.parent:=root.parent;
          root:=root.left;
        END;
      END;
    END;
  END;
  RETURN ret;
END CheckRemove;

PROCEDURE CheckRemoveOther(node:f1.NodePtr;real:LONGREAL):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF node#NIL THEN
    IF node IS f1.Number THEN
      IF node(f1.Number).real=real THEN
        ret:=TRUE;
        node.parent:=root.parent;
        root:=node;
      END;
    END;
  END;
  RETURN ret;
END CheckRemoveOther;

BEGIN
  IF root#NIL THEN
    ret:=Optimize(root.left);
    ret:=Optimize(root.right);
    IF root IS f1.Operation THEN
      ret:=Optimize(root(f1.Operation).root);
      ret:=Optimize(root(f1.Operation).data);
    END;
    IF root IS f1.Sign THEN
      IF (root(f1.Sign).sign="+") OR (root(f1.Sign).sign="-") THEN
        bool:=CheckRemove(root.right,0);
        IF NOT(bool) AND (root(f1.Sign).sign#"-") THEN
          bool:=CheckRemove(root.left,0);
        END;
      ELSIF root(f1.Sign).sign="*" THEN
        bool:=CheckRemove(root.left,1);
        IF NOT(bool) THEN
          bool:=CheckRemove(root.right,1);
          IF NOT(bool) THEN
            bool:=CheckRemoveOther(root.left,0);
            IF NOT(bool) THEN
              bool:=CheckRemoveOther(root.right,0);
            END;
          END;
        END;
      ELSIF root(f1.Sign).sign="/" THEN
        bool:=CheckRemove(root.right,1);
        IF NOT(bool) THEN
          bool:=CheckRemoveOther(root.left,0);
        END;
      END;
    END;
    IF root IS f1.Sign THEN
      real:=Calc(root,bool);
      IF NOT(bool) THEN
        IF SHORT(SHORT(real*10))=real*10 THEN
          node:=root;
          root:=NIL;
          NEW(root(f1.Number));
          root.parent:=node.parent;
          root(f1.Number).real:=real;
        END;
      END;
    END;
    IF root IS f1.Sign THEN
      IF root(f1.Sign).sign="^" THEN
        bool:=CheckRemove(root.right,1);
        IF NOT(bool) THEN
          bool:=CheckRemoveOther(root.right,0);
          IF bool THEN
            root(f1.Number).real:=1;
          END;
        END;
      END;
    END;
  END;
  ret:=FALSE;
  RETURN ret;
END Optimize;

END Function2.

